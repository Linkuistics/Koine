"""Controls for omitted charges, unsafe cleanup admission and incomplete branches."""
# pyright: strict

from __future__ import annotations

import hashlib
from pathlib import Path

import pytest
from application_metadata_operation_ledger import (
    ContractViolation,
    Ledger,
    Limit,
    Resource,
    file_trace,
    listing_trace,
    parser_trace,
    returned_keys_trace,
)
from application_metadata_reader_plan import MetadataRefusal


def test_reusing_a_buffer_cannot_erase_a_second_read_charge() -> None:
    ledger = Ledger()
    ledger.read(4)
    ledger.read(4)
    assert ledger.spent_bytes == 8


def test_cleanup_capacity_is_required_before_acquisition() -> None:
    ledger = Ledger(attempts=1)
    with pytest.raises(Limit, match="CALL_LIMIT"):
        ledger.begin("openat", (Resource("fd", "close"),))
    assert ledger.operations == []
    assert ledger.resources == {}


def test_exact_limit_still_permits_reserved_cleanup_after_cancellation() -> None:
    ledger = Ledger(attempts=2)
    ledger.begin("openat", (Resource("fd", "close"),))
    ledger.finish(("fd",))
    ledger.freeze("CALLER_CANCELLED")
    with pytest.raises(ContractViolation):
        ledger.begin("optional getter")
    ledger.dispose("fd")
    ledger.return_slot()
    assert ledger.spent_attempts == 2
    assert not ledger.slot_held


def test_cancelled_inflight_call_holds_buffer_and_slot_until_actual_return() -> None:
    ledger = Ledger()
    ledger.allocate("buffer", 8)
    ledger.begin("pread", gross_upper=8)
    ledger.freeze("DEADLINE")
    with pytest.raises(ContractViolation):
        ledger.dispose("buffer")
    with pytest.raises(ContractViolation):
        ledger.return_slot()
    ledger.finish(bytes_written=3)
    ledger.dispose("buffer")
    ledger.return_slot()
    assert ledger.spent_bytes == 11


def test_unperformed_reservation_is_distinct_from_a_refund_of_spent_bytes() -> None:
    ledger = Ledger(gross=12)
    ledger.read(4)
    ledger.begin("pread", gross_upper=8)
    ledger.finish(bytes_written=2)
    ledger.copy(6)
    assert ledger.spent_bytes == 12
    with pytest.raises(Limit, match="COPY_LIMIT"):
        ledger.copy(1)


def test_allocation_copy_and_read_are_separate_cumulative_receipts() -> None:
    ledger = Ledger()
    ledger.allocate("vector", 16)
    ledger.copy(16)
    ledger.read(16)
    ledger.dispose("vector")
    assert ledger.spent_bytes == 48


def test_borrowed_key_blocks_owner_retirement_without_acquiring_ownership() -> None:
    ledger = Ledger()
    ledger.begin("parse", (Resource("dict", "CFRelease"),))
    ledger.finish(("dict",))
    ledger.borrow("key", "dict")
    with pytest.raises(ContractViolation):
        ledger.dispose("dict")
    assert ledger.spent_bytes == 0
    ledger.end_borrow("key")
    ledger.dispose("dict")
    assert ledger.spent_attempts == 2


@pytest.mark.parametrize(
    ("branch", "attempts", "gross"),
    [
        ("PARENT_LIMIT_REFUSED", 1, 0),
        ("ABSENT", 2, 0),
        ("NAMED_REFUSED", 2, 0),
        ("OVERSIZE_NAMED", 2, 0),
        ("OPEN_FAILED", 3, 0),
        ("HELD_REFUSED", 5, 0),
        ("OVERSIZE_HELD", 5, 0),
        ("READ_ERROR", 6, 0),
        ("SHORT_READ", 6, 3),
        ("EOF_ERROR", 7, 4),
        ("EOF_EXTRA", 7, 5),
        ("HELD_CHANGED", 8, 4),
        ("NAMED_CHANGED", 9, 4),
        ("OK", 9, 4),
    ],
)
def test_every_file_exit_spends_performed_calls_reads_and_retires_fd(
    branch: str, attempts: int, gross: int
) -> None:
    ledger = Ledger()
    file_trace(ledger, branch, 4)
    assert (ledger.spent_attempts, ledger.spent_bytes) == (attempts, gross)
    assert ledger.resources == {}
    ledger.return_slot()


@pytest.mark.parametrize("branch", ["FAILED", "EOF", "READDIR_ERROR"])
def test_listing_fd_transfers_only_on_success_and_is_disposed_once(branch: str) -> None:
    ledger = Ledger()
    listing_trace(ledger, branch)
    assert ledger.operations == [
        "dup", "fdopendir", *([] if branch == "FAILED" else ["readdir"]),
        "close" if branch == "FAILED" else "closedir",
    ]
    assert ledger.resources == {}


@pytest.mark.parametrize(
    ("branch", "parse_attempts"),
    [("DATA_NIL", 1), ("NIL_NO_ERROR", 3), ("ERROR", 4), ("BOTH", 5),
     ("WRONG_TYPE", 5), ("KEY_LIMIT", 6), ("OK", 6)],
)
def test_parser_result_and_error_reservations_cover_all_actual_return_shapes(
    branch: str, parse_attempts: int
) -> None:
    ledger = Ledger()
    ledger.allocate("buffer", 16)
    before = ledger.spent_attempts
    parser_trace(ledger, branch)
    assert ledger.spent_attempts - before == parse_attempts
    assert set(ledger.resources) == {"buffer"}
    ledger.dispose("buffer")
    assert ledger.spent_bytes == 16
    ledger.return_slot()


def test_parser_reserves_both_possible_out_parameters_before_the_call() -> None:
    ledger = Ledger(attempts=6)
    ledger.allocate("buffer", 1)  # one spent + one cleanup
    ledger.begin("CFDataCreateWithBytesNoCopy", (Resource("data", "CFRelease", ("buffer",)),))
    ledger.finish(("data",))  # two spent + two cleanup
    with pytest.raises(Limit):
        ledger.begin("CFPropertyListCreateWithData", (
            Resource("plist", "CFRelease", ("data",)), Resource("error", "CFRelease"),
        ))  # needs one call + two potential disposals
    ledger.dispose("data")
    ledger.dispose("buffer")
    assert "CFPropertyListCreateWithData" not in ledger.operations


def test_direct_return_duplicates_are_charged_before_deduplication() -> None:
    ledger = Ledger()
    result = returned_keys_trace(ledger, ("en_AU", "en_GB", "en"), ("en_AU", "en_AU", "en"))
    assert result == ("en_AU", "en")
    assert ledger.spent_attempts == 15
    assert ledger.spent_bytes == 12


def test_foreign_return_refuses_instead_of_normalizing_or_advancing() -> None:
    ledger = Ledger()
    with pytest.raises(MetadataRefusal):
        returned_keys_trace(ledger, ("en_AU",), ("en-AU",))
    assert ledger.spent_attempts == 5
    assert ledger.spent_bytes == 5


def test_missing_call_charge_and_missing_cleanup_controls_are_observable() -> None:
    ledger = Ledger()
    ledger.begin("openat", (Resource("fd", "close"),))
    ledger.finish(("fd",))
    with pytest.raises(ContractViolation):
        ledger.return_slot()  # deliberate omitted-close trace
    ledger.dispose("fd")
    assert ledger.spent_attempts == 2  # treating close or open as free fails


@pytest.mark.parametrize("amount", [-1, 1])
def test_returned_byte_count_cannot_underflow_or_exceed_its_admission(amount: int) -> None:
    ledger = Ledger()
    ledger.begin("pread", gross_upper=0)
    with pytest.raises(ContractViolation):
        ledger.finish(bytes_written=amount)


def test_invalid_branch_cannot_silently_take_a_success_trace() -> None:
    with pytest.raises(ContractViolation):
        file_trace(Ledger(), "UNKNOWN", 4)


def test_zero_declared_bytes_still_perform_payload_and_eof_calls() -> None:
    ledger = Ledger()
    file_trace(ledger, "OK", 0)
    assert ledger.spent_attempts == 9
    assert ledger.spent_bytes == 0
    assert ledger.operations[4:6] == ["pread.payload", "pread.eof"]


@pytest.mark.parametrize("attempts", range(10))
def test_every_file_call_limit_exit_has_admitted_capacity_to_retire(attempts: int) -> None:
    ledger = Ledger(attempts=attempts)
    try:
        file_trace(ledger, "OK", 4)
    except Limit:
        assert ledger.frozen == "CALL_LIMIT"
    ledger.retire_all()
    ledger.return_slot()
    assert ledger.spent_attempts <= attempts
    assert ledger.resources == {}


@pytest.mark.parametrize("attempts", range(10))
def test_every_parser_admission_exit_can_retire_actual_acquisitions(attempts: int) -> None:
    ledger = Ledger(attempts=attempts)
    try:
        ledger.allocate("buffer", 4)
        parser_trace(ledger, "OK")
    except Limit:
        assert ledger.frozen == "CALL_LIMIT"
    ledger.retire_all()
    ledger.return_slot()
    assert ledger.spent_attempts <= attempts


@pytest.mark.parametrize("gross", range(6))
def test_payload_and_eof_gross_admission_failures_keep_actual_cleanup(gross: int) -> None:
    ledger = Ledger(gross=gross)
    try:
        file_trace(ledger, "OK", 4)
    except Limit:
        assert ledger.frozen == "COPY_LIMIT"
    ledger.retire_all()
    ledger.return_slot()
    assert ledger.spent_bytes <= gross


def test_checked_repository_subjects_remain_frozen_during_all_branch_replay() -> None:
    root = Path(__file__).resolve().parent.parent
    paths = [
        root / "docs/design/application-metadata-subject.json",
        root / "docs/design/application-metadata-budget-proposal.json",
        root / "docs/verification/application-metadata-reader-plan.md",
        root / "docs/verification/application-metadata-operation-ledger.md",
        root / "scripts/application_metadata_reader_plan.py",
        root / "scripts/application_metadata_operation_ledger.py",
        root / "Taskfile.yml", Path(__file__),
    ]
    before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    ledger = Ledger()
    file_trace(ledger, "OK", 131072)
    file_trace(ledger, "EOF_EXTRA", 131072)
    ledger.allocate("buffer", 131072)
    parser_trace(ledger, "ERROR")
    ledger.dispose("buffer")
    ledger.return_slot()
    assert ledger.spent_bytes == 393217
    assert before == {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
