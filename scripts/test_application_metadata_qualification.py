"""Pure private-qualification controls; synthetic evidence is never native acceptance."""
# pyright: strict
from __future__ import annotations

import copy

import check_application_metadata_reconciliation as controls
import pytest
from application_metadata_episode_certificate import record
from application_metadata_operation_ledger import ContractViolation, Ledger, Resource


@pytest.mark.parametrize("key,value", [
    ("reserveFailureEnvelope", False), ("reserveRawCleanupWrites", False),
    ("unknownExplicitOperand", "EXCLUDE"), ("guardBookkeepingCharged", False),
    ("snapshotCountsBeforeDedup", False), ("pendingSlotEnds", "CALLER_TIMEOUT"),
    ("prerequisiteDesignRequiresUsefulQualification", True),
    ("planningOwner", "NEW_CAPTURE_PROGRAMME"),
    ("ordinaryConsumptionBeforeQualification", True),
    ("reserveTerminalGuardEvaluation", False),
    ("cleanupFailure", "PUBLISH_USEFUL_TREE"),
])
def test_incomplete_guard_or_circular_sequence_is_rejected(key: str, value: object) -> None:
    # Removing cleanup/failure funding or gating the producer on its consumer
    # must stop the machine-readable contract from being accepted.
    subject = copy.deepcopy(controls.load(controls.CONTRACT))
    assert not controls.contract_errors(subject)
    guard = record(subject.setdefault("privateGuard", {}))
    guard[key] = value
    assert any(f"privateGuard.{key}" in error for error in controls.contract_errors(subject))


def test_guard_cannot_omit_one_of_the_nine_conditional_tapes() -> None:
    subject = copy.deepcopy(controls.load(controls.CONTRACT))
    assert not controls.contract_errors(subject)
    record(subject.setdefault("privateGuard", {}))["episodeTapes"] = []
    assert any("privateGuard.episodeTapes" in error for error in controls.contract_errors(subject))


def test_unknown_explicit_write_prevents_optional_invocation() -> None:
    calls: list[str] = []
    if controls.transition_admitted((0, 0), (8, 1), (16, 2), (None, 1), (8, 1)):
        calls.append("source")
    assert calls == []


@pytest.mark.parametrize("short", [0, 1])
def test_raw_cleanup_and_failure_envelope_are_reserved_before_call(short: int) -> None:
    # Hand-derived: ordinary terms 100/10 plus terminal guard credit 4/2.
    assert controls.transition_admitted((20, 2), (8, 1), (16, 2), (40, 3), (16, 2),
                 terminal_guard=(4, 2), limits=(104 - short, 12)) is (short == 0)
    assert controls.transition_admitted((20, 2), (8, 1), (16, 2), (40, 3), (16, 2),
                 terminal_guard=(4, 2), limits=(104, 12 - short)) is (short == 0)


def test_frozen_transition_cannot_start_even_with_remaining_capacity() -> None:
    assert not controls.transition_admitted((0, 0), (0, 0), (0, 0), (1, 1), (0, 0), frozen=True)


def test_performed_failed_prefix_is_irrevocable() -> None:
    assert controls.settle_prefix((20, 2), (7, 1), (40, 3)) == (27, 3)
    with pytest.raises(ContractViolation):
        controls.settle_prefix((20, 2), (41, 1), (40, 3))


def test_private_eligibility_requires_all_prerequisites_but_no_analytic_fit() -> None:
    complete = {"DESIGN", "WHOLE_REVIEW_INTEGRATION", "REVIEWED_FINITE_SUBJECT",
                "SOURCE_ACCESS_REVIEW", "OWNERSHIP_IMAGE_REVIEW", "NORMALIZATION_REVIEW",
                "WHOLE_DISCOVERY_DESIGN_REVIEW", "QUALIFICATION_PLAN"}
    assert controls.private_eligible(complete)
    for prerequisite in complete:
        assert not controls.private_eligible(complete - {prerequisite})


@pytest.mark.parametrize("missing", [
    "subjects", "nine_tapes", "full_response", "useful_witnesses", "serviceability",
    "read_policy", "authority_images_disclosures_compatibility", "gates_deadlines_slots",
    "population_shape", "release_image_correspondence", "cleanup_outcomes",
])
def test_partial_refused_unknown_or_missing_evidence_never_releases(missing: str) -> None:
    evidence: dict[str, bool | None] = dict.fromkeys([
        "subjects", "nine_tapes", "full_response", "useful_witnesses", "serviceability",
        "read_policy", "authority_images_disclosures_compatibility", "gates_deadlines_slots",
        "population_shape", "release_image_correspondence", "cleanup_outcomes",
    ], True)
    assert controls.useful_release(True, evidence)
    assert not controls.useful_release(False, evidence)
    for outcome in (False, None):
        evidence[missing] = outcome
        assert not controls.useful_release(True, evidence)
    del evidence[missing]
    assert not controls.useful_release(True, evidence)


def test_late_call_return_keeps_inputs_cleanup_and_slot_after_freeze() -> None:
    ledger = Ledger()
    ledger.allocate("input", 16)
    ledger.begin("selector", (Resource("result", "CFRelease", ("input",)),))
    ledger.freeze("DEADLINE")
    with pytest.raises(ContractViolation):
        ledger.return_slot()
    with pytest.raises(ContractViolation):
        ledger.retire_all()
    ledger.finish(("result",))
    ledger.retire_all()
    ledger.return_slot()
    assert (ledger.spent_bytes, ledger.spent_attempts, ledger.slot_held) == (16, 4, False)


def test_exact_gate_without_terminal_guard_credit_cannot_admit() -> None:
    # The old model admits exactly 100/10, then a rejecting evaluation exceeds it.
    assert not controls.transition_admitted(
        (20, 2), (8, 1), (16, 2), (40, 3), (16, 2), limits=(100, 10),
    )


def test_metadata_shape_and_release_image_are_required_evidence() -> None:
    evidence: dict[str, bool | None] = dict.fromkeys([
        "subjects", "nine_tapes", "full_response", "useful_witnesses", "serviceability",
        "read_policy", "authority_images_disclosures_compatibility", "gates_deadlines_slots",
    ], True)
    assert not controls.useful_release(True, evidence)


def test_leaf_names_cannot_supply_durable_release_prerequisites() -> None:
    historical = {"DESIGN", "WHOLE_REVIEW_INTEGRATION", "REVIEWED_FINITE_SUBJECT",
                  "SOURCE_ACCESS_REVIEW", "OWNERSHIP_IMAGE_REVIEW", "NORMALIZATION_REVIEW",
                  "WHOLE_K19_REVIEW", "K30_QUALIFICATION_PLACEMENT"}
    assert not controls.private_eligible(historical)


def test_guard_settlement_charges_refusal_once_and_freezes() -> None:
    assert hasattr(controls, "settle_guard")
    spent, credit, frozen = controls.settle_guard(
        (90, 8), (4, 2), (3, 1), admitted=False,
    )
    assert (spent, credit, frozen) == ((93, 9), (0, 0), True)
    assert not controls.transition_admitted(
        spent, (0, 0), (0, 0), (0, 0), (0, 0), terminal_guard=credit, frozen=frozen,
    )
    with pytest.raises(ContractViolation):
        controls.settle_guard(spent, credit, (1, 1), admitted=False, frozen=frozen)


def test_guard_settlement_keeps_credit_on_admission_and_checks_prefix() -> None:
    assert hasattr(controls, "settle_guard")
    assert controls.settle_guard((20, 2), (4, 2), (3, 1), admitted=True) == (
        (23, 3), (4, 2), False,
    )
    with pytest.raises(ContractViolation):
        controls.settle_guard((20, 2), (4, 2), (5, 1), admitted=False)


def test_family_prose_rejects_original_weak_eligibility() -> None:
    assert hasattr(controls, "prose_errors")
    repaired = (
        "## Grouped refinement and retained hold\nPrivate construction requires the complete\n"
        "[eligibility conjunction](application-metadata-private-qualification.md"
        "#eligibility-and-existing-qualification-sequence).\n"
    )
    assert not controls.prose_errors("docs/specs/example.md", repaired)
    weak = repaired + (
        "The selected order permits a private guarded implementation for qualification\n"
        "before analytic fit, after complete design, whole-producer review and earned\n"
        "integration.\n"
    )
    assert controls.prose_errors("docs/specs/example.md", weak)
