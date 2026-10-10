"""Pure source/root contracts, with no target reads or platform invocations."""
# pyright: strict

from __future__ import annotations

import importlib.util
from pathlib import Path
from typing import cast

import pytest
from application_metadata_operation_ledger import ContractViolation, Limit, Resource
from application_metadata_source_root import (
    Batch,
    IndexedItem,
    NativeRefusal,
    RunningItem,
    Scalar,
    Trace,
    Visit,
    indexed,
    preferences,
    registration,
    root_pair,
    running,
    setup,
    walk,
)


def test_source_root_contract_is_available() -> None:
    assert importlib.util.find_spec("application_metadata_source_root") is not None


def test_exact_walker_is_an_explicit_contract_input() -> None:
    root = Path(__file__).resolve().parent.parent
    assert (root / "Providers/WorkspaceProvider/Logic/LocationWalk.swift").is_file()


def test_unknown_capacity_is_not_a_zero_gross_sum() -> None:
    trace = Trace()
    trace.bytes("projection", b"abcd")
    assert trace.known_writes == 4
    assert trace.gross is None
    assert trace.unresolved == ["projection.capacity"]


def test_type_id_setup_is_once_per_job_and_has_no_hidden_free_getters() -> None:
    trace = Trace()
    setup(trace)
    assert trace.operations == [name + "GetTypeID" for name in (
        "CFString", "CFArray", "CFURL", "CFError", "CFBoolean", "CFDictionary"
    )]
    with pytest.raises(ContractViolation):
        setup(trace)


def test_explicit_capacity_and_every_repeated_write_are_charged() -> None:
    trace = Trace()
    trace.bytes("projection", b"abcd", capacity=4)
    trace.write("second-copy", 4)
    assert trace.gross == 12
    trace.cleanup()
    assert trace.gross == 12


def test_source_result_and_error_cleanup_are_reserved_before_cf_call() -> None:
    trace = Trace(attempts=9)
    with pytest.raises(Limit):
        registration(trace, Batch("BOTH"), Batch("EMPTY"), None, b"org.example.app")
    assert "LSCopyApplicationURLsForBundleIdentifier" not in trace.operations
    assert "autoreleasepool.push.registration" in trace.operations
    trace.cleanup()
    assert trace.ledger.spent_attempts <= 9


@pytest.mark.parametrize("branch", ["POSITIVE", "EMPTY", "NOT_FOUND", "ERROR", "BOTH",
                                    "NIL", "WRONG_TYPE", "INCOMPLETE"])
def test_registration_branches_retire_all_actual_outputs(branch: str) -> None:
    trace = Trace()
    result = registration(
        trace, Batch(branch, (Scalar(b"/A.app"),)), Batch("EMPTY"), None, b"org.a"
    )
    assert trace.operations.count("LSCopyApplicationURLsForBundleIdentifier") == 1
    assert trace.operations.count("NSWorkspace.urlsForApplications") == 1
    assert trace.operations.count("NSWorkspace.urlForApplication") == 1
    assert result == ("CHECKED_NOT_FOUND" if branch == "NOT_FOUND" else
                      "COMPLETE" if branch == "POSITIVE" else "UNKNOWN")
    if branch in {"NOT_FOUND", "ERROR", "BOTH"}:
        assert "CFRelease.registration-error" in trace.operations
        assert trace.operations.index("CFRelease.registration-error") < trace.operations.index(
            "NSWorkspace.urlsForApplications"
        )
    trace.cleanup()
    assert not trace.ledger.resources


def test_duplicate_url_slots_are_inspected_before_deduplication() -> None:
    trace = Trace()
    registration(trace, Batch("POSITIVE", (Scalar(b"/A.app"),) * 2),
                 Batch("POSITIVE", (Scalar(b"/A.app"),)), Scalar(b"/A.app"), b"org.a")
    assert trace.operations.count("CFURLCopyFileSystemPath") == 4
    assert trace.operations.count("raw.url.admit") == 4


def test_malformed_error_is_retired_without_error_getters_or_negative_fact() -> None:
    trace = Trace()
    result = registration(trace, Batch("NOT_FOUND", error_state="TYPE"),
                          Batch("EMPTY"), None, b"org.a")
    assert result == "UNKNOWN"
    assert "CFGetTypeID.registration-error" in trace.operations
    assert "CFErrorGetDomain" not in trace.operations
    assert "CFErrorGetCode" not in trace.operations
    assert "CFRelease.registration-error" in trace.operations
    assert any(item.label == "cf-error.native-footprint" for item in trace.receipts)
    trace.cleanup()


@pytest.mark.parametrize("state", ["OK", "MISSING", "TYPE", "ENCODING", "INCOMPLETE"])
def test_indexed_projection_observes_fixed_tuple_and_complete_type_tree(state: str) -> None:
    trace = Trace()
    indexed(trace, (IndexedItem(Scalar(b"/A.app", state),
                               (Scalar(b"public.item"), Scalar(b"com.apple.application-bundle")),
                               Scalar(b"org.a"), Scalar(b"A")),))
    for field in ("kMDItemPath", "kMDItemContentTypeTree", "kMDItemCFBundleIdentifier",
                  "kMDItemDisplayName"):
        assert trace.operations.count("NSMetadataItem.valueForAttribute." + field) == 1
    assert trace.operations.count("CFArrayGetValueAtIndex.type-tree") == 2
    assert "NSMetadataQuery.stop" in trace.operations
    assert trace.operations.index("NotificationCenter.removeObserver") < trace.operations.index(
        "ARC.release.query"
    )


@pytest.mark.parametrize("branch", ["INIT_NIL", "START_FALSE", "ERROR", "INCOMPLETE",
                                    "EMPTY", "POSITIVE"])
def test_query_failure_and_empty_prefixes(branch: str) -> None:
    trace = Trace()
    indexed(trace, (), branch=branch)
    trace.cleanup()
    assert not trace.ledger.resources
    assert trace.operations.count("NSMetadataQuery.resultCount") == int(
        branch in {"EMPTY", "POSITIVE"}
    )


def test_running_slots_have_url_identifier_policy_and_bridge_receipts() -> None:
    trace = Trace()
    running(trace, (RunningItem(Scalar(b"/A.app"), Scalar(b"org.a")),) * 2)
    assert trace.operations.count("NSRunningApplication.activationPolicy") == 2
    assert trace.operations.count("raw.running.access") == 2
    assert "running.swift-vector.capacity" in trace.unresolved


def test_preferences_empty_is_explicit_once_and_not_an_implicit_bundle_default() -> None:
    trace = Trace()
    preferences(trace, ())
    assert trace.operations.count("Locale.preferredLanguages") == 1
    assert trace.operations.count("CFArrayCreate.preferences") == 1
    assert "CFBundle.main" not in trace.operations
    assert "preference-array" in trace.ledger.resources
    with pytest.raises(ContractViolation):
        preferences(trace, ())
    trace.cleanup()


def test_preferences_construction_failure_retires_created_prefix() -> None:
    trace = Trace()
    preferences(trace, (Scalar(b"en-AU"), Scalar(b"de")), fail_at=1)
    assert trace.operations.count("CFStringCreateWithBytes.preference") == 2
    assert trace.operations.count("CFRelease.preference") == 1
    trace.cleanup()
    assert not trace.ledger.resources


def test_two_walk_terminal_transfer_has_independent_second_check_and_no_third_walk() -> None:
    trace = Trace()
    outcome = root_pair(trace, b"/A.app", (Visit(b"A.app", "DIRECTORY"),),
                        (Visit(b"A.app", "DIRECTORY"),))
    assert outcome == "ORDINARY"
    assert trace.operations.count("openat.root") == 2
    assert trace.operations.count("openat.terminal") == 1
    assert trace.operations.count("fstat.terminal") == 1
    assert trace.operations.count("fstatat.terminal-after") == 1
    assert trace.operations.count("URL.resourceValues.isApplication") == 1
    assert trace.operations.count("close") == 3
    trace.cleanup()


@pytest.mark.parametrize("resource", ["FALSE", "MISSING", "TYPE", "ERROR"])
def test_root_resource_refusal_still_checks_identity_without_reader_rescue(resource: str) -> None:
    trace = Trace()
    visits = (Visit(b"A.app", "DIRECTORY"),)
    assert root_pair(trace, b"/A.app", visits, visits, resource=resource) == "METADATA_REFUSED"
    assert trace.operations.count("openat.root") == 2
    assert "metadata.reader-contract-boundary" not in trace.operations


@pytest.mark.parametrize("second", [Visit(b"A.app", "DIRECTORY", identity=2),
                                    Visit(b"A.app", "FILE"), Visit(b"A.app", "ERROR")])
def test_independent_second_failure_or_replacement_refuses_copy(second: Visit) -> None:
    trace = Trace()
    assert root_pair(trace, b"/A.app", (Visit(b"A.app", "DIRECTORY"),),
                     (second,)) == "REFUSED"


def test_registration_identifier_expansion_cannot_recur_per_copy() -> None:
    trace = Trace()
    registration(trace, Batch("EMPTY"), Batch("EMPTY"), None, b"org.a")
    with pytest.raises(ContractViolation):
        registration(trace, Batch("EMPTY"), Batch("EMPTY"), None, b"org.a")


def test_each_received_query_event_is_an_operation_not_a_fixed_setup_reserve() -> None:
    trace = Trace()
    indexed(trace, (), events=3)
    assert trace.operations.count("owner-runloop.wait-event") == 3
    assert trace.operations.count("notification.object.type-and-query-identity") == 3


@pytest.mark.parametrize("stage", ["NSPredicate.construct.fixed", "NSMetadataQuery.alloc.init",
                                    "NotificationCenter.addObserver.didFinishGathering"])
def test_nil_query_construction_prefix_retires_actual_owners(stage: str) -> None:
    trace = Trace(nil_acquisition=stage)
    with pytest.raises(NativeRefusal):
        indexed(trace, ())
    assert "NSMetadataQuery.start" not in trace.operations
    trace.cleanup()
    assert not trace.ledger.resources


@pytest.mark.parametrize("state", ["MISSING", "TYPE", "INCOMPLETE"])
def test_missing_or_wrong_tree_has_no_array_count_or_member_access(state: str) -> None:
    trace = Trace()
    indexed(trace, (IndexedItem(Scalar(b"/A.app"), (), tree_state=state),))
    assert "CFArrayGetCount.type-tree" not in trace.operations
    assert trace.operations.count("CFGetTypeID.type-tree") == int(state != "MISSING")


@pytest.mark.parametrize("stage", [
    "CFStringCreateWithBytes.seed", "NSWorkspace.urlsForApplications",
    "NSWorkspace.urlForApplication", "CFURLCopyFileSystemPath",
])
def test_nil_registration_construction_has_actual_prefix_cleanup(stage: str) -> None:
    trace = Trace(nil_acquisition=stage)
    with pytest.raises(NativeRefusal):
        registration(trace, Batch("POSITIVE", (Scalar(b"/A.app"),)),
                     Batch("POSITIVE", (Scalar(b"/B.app"),)), Scalar(b"/C.app"), b"org.a")
    trace.cleanup()
    assert not trace.ledger.resources


def test_long_finalized_root_performs_no_root_resource_or_reader_call() -> None:
    literal = b"/" + b"a" * 1023
    trace = Trace()
    assert root_pair(trace, literal, (Visit(literal[1:], "DIRECTORY"),),
                     (Visit(literal[1:], "DIRECTORY"),)) == "INDEXED_REQUIRED"
    assert "URL.resourceValues.isApplication" not in trace.operations
    assert trace.operations.count("openat.root") == 2


def test_vector_population_and_arc_retention_are_explicit_attempts() -> None:
    trace = Trace()
    trace.vector("pointers", 3)
    assert trace.known_writes == 24
    assert trace.unresolved == ["pointers.capacity"]
    trace.opaque("native-getter", "native", disposer="ARC.release.native")
    assert "ARC.retain-projection.native" in trace.operations


def test_expanded_visits_are_derived_from_link_text_not_lexical_count() -> None:
    trace = Trace()
    result = walk(trace, b"/alias/A.app", (
        Visit(b"alias", "LINK", text=b"x/y"), Visit(b"x", "DIRECTORY"),
        Visit(b"y", "DIRECTORY"), Visit(b"A.app", "DIRECTORY"),
    ), transfer=False)
    assert result is not None and result.resolved == b"/x/y/A.app"
    assert result.visits == 4
    assert trace.operations.count("readlinkat") == 1
    assert any("suffix" in item.label for item in trace.receipts)
    assert any("expansion" in item.label for item in trace.receipts)
    assert sum(r.amount or 0 for r in trace.receipts
               if r.label == "walk.suffix-array" and r.kind == "write") == 6


@pytest.mark.parametrize("terminal", [b"/", b"/.", b"/.."])
def test_current_and_parent_terminal_branches_transfer_the_correct_handle(terminal: bytes) -> None:
    trace = Trace()
    visits = () if terminal == b"/" else (Visit(terminal[1:], "DOT"),)
    assert walk(trace, terminal, visits, transfer=True) is not None
    assert "root" in trace.ledger.resources
    assert [item.amount for item in trace.receipts
            if item.label == "walk.final-component-vector.population"] == [0]
    trace.cleanup()


@pytest.mark.parametrize("failure", ["OPEN", "HELD", "HELD_TYPE", "NAMED", "CHANGED",
                                     "ENAMETOOLONG"])
def test_terminal_transfer_failure_closes_both_possible_descriptors(failure: str) -> None:
    trace = Trace()
    assert walk(trace, b"/A.app", (Visit(b"A.app", "DIRECTORY", failure=failure),),
                transfer=True) is None
    assert not any(item.disposer == "close" for item in trace.ledger.resources.values())


@pytest.mark.parametrize("failure", ["LINK", "CONTAINING", "EMPTY", "CHANGED"])
def test_failed_link_prefixes_leave_no_directory_handle(failure: str) -> None:
    trace = Trace()
    visits = (Visit(b"alias", "LINK", text=b"x", failure=failure),)
    assert walk(trace, b"/alias", visits, transfer=False) is None
    assert not any(item.disposer == "close" for item in trace.ledger.resources.values())


def test_absolute_link_reopens_root_and_cycle_and_link_limit_do_not_expand_again() -> None:
    trace = Trace()
    result = walk(trace, b"/alias", (Visit(b"alias", "LINK", text=b"/A.app"),
                                    Visit(b"A.app", "DIRECTORY")), transfer=False)
    assert result is not None
    assert trace.operations.count("openat.root") == 2
    cycle = Trace()
    assert walk(cycle, b"/a", (Visit(b"a", "LINK", text=b"a"),) * 2,
                transfer=False) is None
    limit = Trace()
    assert walk(limit, b"/a", tuple(Visit(b"a", "LINK", text=b"a/.") for _ in range(33)),
                transfer=False) is None
    assert limit.operations.count("readlinkat") == 33


@pytest.mark.parametrize("kind", ["MISSING", "DENIED", "ENAMETOOLONG"])
def test_lookup_errors_classify_only_name_length_with_fpathconf(kind: str) -> None:
    trace = Trace()
    assert walk(trace, b"/a", (Visit(b"a", "ERROR", failure=kind),), transfer=False) is None
    assert trace.operations.count("fpathconf") == int(kind == "ENAMETOOLONG")


def test_dot_dot_is_physical_and_trailing_slash_requires_directory() -> None:
    trace = Trace()
    result = walk(trace, b"/a/../b", (Visit(b"a", "DIRECTORY"), Visit(b"..", "DOT"),
                                     Visit(b"b", "DIRECTORY")), transfer=False)
    assert result is not None and result.resolved == b"/b"
    assert trace.operations.count("openat.parent") == 1
    other = Trace()
    assert walk(other, b"/file/", (Visit(b"file", "FILE"),), transfer=False) is None


def test_initial_root_and_absolute_reopen_failures_retire_actual_handles() -> None:
    trace = Trace()
    assert walk(trace, b"/", (), transfer=False, root_failure=True) is None
    assert trace.operations.count("close") == 0
    other = Trace()
    assert walk(other, b"/a", (Visit(b"a", "LINK", text=b"/b", failure="ROOT"),),
                transfer=False) is None
    assert other.operations.count("close") == 1


def test_current_status_and_final_parent_named_failures_retire_root() -> None:
    trace = Trace()
    assert walk(trace, b"/", (), transfer=True, current_status_failure=True) is None
    assert trace.operations.count("close") == 1
    other = Trace()
    assert walk(other, b"/..", (Visit(b"..", "DOT", failure="STATUS"),),
                transfer=True) is None
    assert other.operations.count("openat.terminal") == 0


@pytest.mark.parametrize("length", [1025, 1026])
def test_link_limit_failure_charges_only_buffer_prefix_and_classifies_without_expanding(
    length: int,
) -> None:
    trace = Trace()
    assert walk(trace, b"/a", (Visit(b"a", "LINK", text=b"x" * length),),
                transfer=False) is None
    assert sum(r.amount or 0 for r in trace.receipts
               if r.label == "walk.link-read-prefix") == 1025
    assert trace.operations.count("fpathconf") == 1
    assert not any(r.label == "walk.expansion" for r in trace.receipts)


@pytest.mark.parametrize("stage", ["preferences", "running", "registration", "root"])
def test_each_source_and_root_cancellation_prefix_keeps_cleanup_reserved(stage: str) -> None:
    def exercise(trace: Trace) -> None:
        if stage == "preferences":
            preferences(trace, (Scalar(b"en"), Scalar(b"de")))
        elif stage == "running":
            running(trace, (RunningItem(Scalar(b"/A.app"), Scalar(b"org.a")),))
        elif stage == "registration":
            registration(trace, Batch("BOTH", (Scalar(b"/A.app"),)),
                         Batch("POSITIVE", (Scalar(b"/B.app"),)), Scalar(b"/C.app"), b"org.a")
        else:
            visits = (Visit(b"alias", "LINK", text=b"/A.app"), Visit(b"A.app", "DIRECTORY"))
            root_pair(trace, b"/alias", visits, visits)
    full = Trace()
    exercise(full)
    for boundary in range(full.invocations):
        trace = Trace(cut=boundary)
        with pytest.raises(Limit):
            exercise(trace)
        trace.cleanup()
        assert not trace.ledger.resources and not trace.ledger.slot_held


def test_all_cancellation_prefixes_unwind_and_never_return_slot_inflight() -> None:
    full = Trace()
    indexed(full, ())
    length = full.invocations
    for boundary in range(length):
        trace = Trace(cut=boundary)
        with pytest.raises(Limit):
            indexed(trace, ())
        trace.cleanup()
        assert not trace.ledger.resources and not trace.ledger.slot_held
    trace = Trace()
    trace.ledger.begin("source.inflight", (Resource("result", "CFRelease"),))
    trace.ledger.freeze("DEADLINE")
    with pytest.raises(ContractViolation):
        trace.cleanup()
    trace.ledger.finish(("result",))
    trace.cleanup()
    assert not trace.ledger.slot_held


def test_controlled_dimensions_leave_native_and_whole_sums_unknown() -> None:
    from application_metadata_source_root_certificate import assess

    root = Path(__file__).resolve().parent.parent
    result = assess(root)
    controlled = result["controlledPathOnly"]
    assert isinstance(controlled, dict)
    assert controlled["rawURLSlots"] == 7862
    assert controlled["runningSlots"] == 128
    assert controlled["identifierGroupsIncludingSystemReserve"] == 1873
    outside = result["outsideCensusPaths"]
    assert isinstance(outside, list) and len(cast(list[object], outside)) == 149
    for name in ("sourceRootGrossBytes", "sourceRootAttempts", "sourceRootOwnedStorage",
                 "wholeJobGrossBytes", "wholeJobAttempts", "responseBytes"):
        assert result[name] is None
