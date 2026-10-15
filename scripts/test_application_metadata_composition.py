"""Catch overlap double charging, fabricated fit and unsafe pre-call admission."""
# pyright: strict
from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import cast

import application_metadata_composition as composition
import pytest
from application_metadata_composition import (
    INPUTS,
    assess,
    begin_owned,
    compose_episode,
    sum_terms,
)
from application_metadata_episode_certificate import integer, objects, record, texts
from application_metadata_operation_ledger import ContractViolation, Ledger, Limit


def test_scoped_runtime_call_is_provider_work_even_with_excluded_backing() -> None:
    assert hasattr(composition, "explicit_cost")
    assert composition.explicit_cost("RUNTIME_CALL", None) == (0, 1)
    with pytest.raises(ContractViolation, match="provider"):
        composition.explicit_cost("RUNTIME_CALL", None, owner="HOST")
    with pytest.raises(ContractViolation, match="unknown explicit"):
        composition.explicit_cost("RAW_WRITE", None)


def test_scoped_reservation_includes_raw_cleanup_writes_and_calls() -> None:
    assert hasattr(composition, "reserve_explicit")
    # Allocation, header and population: 80+64+10. Disposal writes an
    # eight-byte state field and frees: two additional explicit operations.
    assert composition.reserve_explicit([(154, 3)], [(8, 2)], 162, 5) == (162, 5)
    with pytest.raises(Limit, match="COPY_LIMIT"):
        composition.reserve_explicit([(154, 3)], [(8, 2)], 161, 5)
    with pytest.raises(Limit, match="CALL_LIMIT"):
        composition.reserve_explicit([(154, 3)], [(8, 2)], 162, 4)


def test_raw_recipe_has_explicit_owner_fields_and_no_reuse_refund() -> None:
    assert hasattr(composition, "raw_block_cost")
    assert composition.raw_block_cost(10) == (162, 5)
    # A second independently allocated block costs the same after disposing the
    # first. Nothing refunds the first request, initialization or disposal write.
    assert sum(composition.raw_block_cost(10)[0] for _ in range(2)) == 324


def test_every_scoped_receipt_has_a_recipe_and_explicit_operation_disposition() -> None:
    result = assess(Path(__file__).resolve().parents[1])
    packet = record(result["runtimeAdmission"])
    assert packet["accountingChangeAdopted"] is True
    dispositions = record(packet["receiptDisposition"])
    assert len(dispositions) == 65
    for value in dispositions.values():
        receipt = record(value)
        assert receipt.get("scope") in {"CONTROLLED_RAW", "EXCLUDED_RUNTIME_INTERNAL"}
        assert receipt.get("recipe")
        assert receipt.get("explicitCallerCharged") is True


def test_controlled_path_enclosure_does_not_certify_native_overflow_or_fit() -> None:
    result = assess(Path(__file__).resolve().parents[1])
    assert "controlledPathComparison" in result
    comparison = record(result["controlledPathComparison"])
    assert comparison["rawSlots"] == 7862
    assert comparison["pathProjectionGross"] == 3633104
    assert comparison["nativeObservation"] is False
    for value in record(result["runs"]).values():
        run = record(value)
        assert integer(run["controlledPathEnclosureGross"]) > integer(result["grossGate"])
        assert run["scopedWholeJobGrossBytes"] is None
        assert run["usefulFit"] == "UNESTABLISHED"


def test_unknown_operand_cannot_buy_admission_or_fit() -> None:
    assert sum_terms([17, None, 0]) is None
    assert sum_terms([17, 0, 4]) == 21
    with pytest.raises(ContractViolation):
        sum_terms([-1])


def test_read_attempts_overlap_once_but_gross_writes_remain() -> None:
    row = compose_episode(30, 3, 20, 6, 100)
    assert row["knownAttemptsUpper"] == 44
    assert row["knownGrossSubterms"] == 100
    assert row["wholeEpisodeAttempts"] is None
    assert row["wholeEpisodeGrossBytes"] is None
    with pytest.raises(ContractViolation):
        compose_episode(30, 3, 20, 5, 100)


def test_unknown_capacity_stops_before_acquisition() -> None:
    ledger = Ledger(gross=100)
    with pytest.raises(ContractViolation, match="unbound"):
        begin_owned(ledger, "swift.result-vector", None, 16)
    assert ledger.operations == []
    assert ledger.spent_attempts == 0
    assert ledger.spent_bytes == 0
    assert ledger.pending is None


@pytest.mark.parametrize("evidence", [
    "ABI_LAYOUT", "MINIMUM_CAPACITY", "POST_CALL_CAPACITY", "WIRE_BODY",
])
def test_numeric_payload_or_layout_is_not_a_runtime_allocation_upper(evidence: str) -> None:
    # Break: admit a Swift constructor on a number that proves only payload,
    # value layout, or the result of the already-performed allocation.
    ledger = Ledger(gross=100)
    with pytest.raises(ContractViolation, match="capacity evidence"):
        begin_owned(ledger, "public.swift-value", 64, 16, evidence=evidence)
    assert ledger.operations == []
    assert ledger.spent_bytes == ledger.spent_attempts == 0
    assert ledger.pending is None


def test_capacity_and_initialization_share_pre_call_reservation() -> None:
    ledger = Ledger(attempts=3, gross=80)
    begin_owned(ledger, "result", 64, 16)
    assert ledger.pending is not None and ledger.pending.gross_upper == 80
    ledger.finish(("result",), bytes_written=80)
    ledger.freeze("CANCELLED")
    ledger.dispose("result")
    ledger.return_slot()
    assert ledger.spent_bytes == 80
    assert ledger.spent_attempts == 2
    assert not ledger.slot_held
    refused = Ledger(gross=79)
    with pytest.raises(Limit, match="COPY_LIMIT"):
        begin_owned(refused, "result", 64, 16)
    assert refused.operations == []


def test_failed_return_keeps_its_actual_prefix_and_cleanup_credit() -> None:
    ledger = Ledger(gross=80)
    begin_owned(ledger, "result", 64, 16)
    ledger.finish((), bytes_written=7)
    ledger.return_slot()
    assert ledger.spent_bytes == 7
    assert ledger.spent_attempts == 1
    assert not ledger.resources


@pytest.mark.parametrize("label", [
    "walk.state.field-values", "walk.expansion-vector-append.capacity",
    "indexed.tuple-record.field-values",
])
def test_receipt_disposition_cannot_omit_owner_growth_or_initialization(
    tmp_path: Path, label: str
) -> None:
    # Break: omit real ownership/growth/population work from the proposed
    # replacement inventory and then present that incomplete contract as whole.
    root = Path(__file__).resolve().parents[1]
    for item in INPUTS:
        target = tmp_path / item
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(root / item, target)
    path = tmp_path / "docs/design/application-metadata-runtime-admission.json"
    packet = record(json.loads(path.read_bytes()))
    del record(packet["receiptDisposition"])[label]
    path.write_text(json.dumps(packet))
    with pytest.raises(ContractViolation, match="receipt"):
        assess(tmp_path)


def test_every_saved_association_and_outside_record_survives() -> None:
    result = assess(Path(__file__).resolve().parents[1])
    assert record(result["runtimeAdmission"])["selection"] == "SELECTED_SCOPED_EXPLICIT_WORK"
    assert result["nativeVerdict"] == "PENDING"
    assert result["usefulSubjectCertificateEstablished"] is False
    assert len(texts(result["episodeSpellings"])) == 2043
    assert len(objects(result["outsidePaths"])) == 149
    assert result["systemSeedGroups"] == 2
    runs = record(result["runs"])
    assert record(runs["en-AU,en"])["knownAttemptsUpper"] == 871255
    assert record(runs["de"])["knownAttemptsUpper"] == 904386
    assert record(runs["en-AU,en"])["knownGrossSubterms"] == 14181924
    assert record(runs["de"])["knownGrossSubterms"] == 14356031
    for value in runs.values():
        run = record(value)
        rows = run["rows"]
        assert isinstance(rows, list) and len(cast(list[object], rows)) == 2043
        assert run["wholeJobAttempts"] is None
        assert run["wholeJobGrossBytes"] is None
        assert run["scopedWholeJobGrossBytes"] is None
        assert run["scopedWholeJobAttempts"] is None
        assert len(objects(run["scopedEpisodeExpressions"])) == 2043
        assert integer(run["scopedKnownGrossSubterms"]) > integer(run["knownGrossSubterms"])
        assert run["actualResponseBytes"] is None
        assert run["usefulFit"] == "UNESTABLISHED"
    assert result["unboundReceiptLabels"]
