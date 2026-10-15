"""Pure design controls: missing receipts, unstable borrowers and fabricated fit."""
# pyright: strict
from __future__ import annotations

from pathlib import Path
from typing import cast

import pytest
from application_metadata_grouped_storage import (
    Group,
    assess,
    compact,
    group_cost,
    validate,
)
from application_metadata_operation_ledger import ContractViolation, Limit


def test_empty_inventory_still_owns_and_retires_its_descriptor() -> None:
    # Removing empty ownership or either final state write must fail.
    result = group_cost([], [])
    assert (result["gross"], result["attempts"]) == (432, 10)


def test_one_direct_key_charges_payload_spans_classification_and_cleanup() -> None:
    # No per-key owner, but no free header, cursor, suffix view or cleanup either.
    result = group_cost(["de.lproj"], ["de.lproj"])
    # Descriptor 432; slabs 432+816; prefix 8; bytes 9; record 40;
    # four 8-byte updates; exact selector length and accepted count 16.
    assert result["gross"] == 1785
    assert result["attempts"] == 37
    assert result["records"] == [[0, 0, 8, 2, "DIRECT", 0]]


def test_growth_keeps_old_spans_stable_without_refunding_slabs() -> None:
    group = Group()
    group.append("a" * 255)
    first = group.records[0].copy()
    before = group.spent_gross
    group.append("b")
    assert group.records[0] == first
    assert group.byte_slabs == 2
    assert group.spent_gross > before
    group.freeze()
    group.close()
    assert group.spent_gross == 2778


def test_pending_borrower_retains_owner_and_slot_after_cancellation() -> None:
    group = Group()
    group.append("LocProvenance")
    group.freeze()
    group.begin_call()
    group.cancel()
    with pytest.raises(ContractViolation, match="borrow"):
        group.close()
    assert group.slot_held
    group.return_call()
    group.close()
    assert not group.slot_held


def test_frozen_inventory_cannot_grow_even_without_a_pending_call() -> None:
    group = Group()
    group.freeze()
    with pytest.raises(ContractViolation, match="frozen"):
        group.append("en")


def test_failed_admission_retains_old_generation_and_reserves_cleanup() -> None:
    group = Group(gross_limit=1784)
    with pytest.raises(Limit):
        group.append("de.lproj", direct=True)
    assert group.records == []
    assert group.spent_gross == 400
    group.close()
    assert group.spent_gross == 416


def test_exact_gate_equality_admits_but_one_attempt_short_refuses() -> None:
    group = Group(gross_limit=1785, attempt_limit=37)
    group.append("de.lproj", direct=True)
    group.freeze()
    group.close()
    assert (group.spent_gross, group.spent_attempts) == (1785, 37)
    short = Group(attempt_limit=36)
    with pytest.raises(Limit):
        short.append("de.lproj", direct=True)
    assert short.records == []
    short.close()


def test_native_call_cannot_spend_its_borrower_cleanup_reservation() -> None:
    group = Group(gross_limit=1785)
    group.append("de.lproj", direct=True)
    group.freeze()
    with pytest.raises(Limit):
        group.begin_call()
    assert not group.pending
    group.close()


@pytest.mark.parametrize("prefix", range(24))
def test_every_failed_append_prefix_can_unwind_without_a_refund(prefix: int) -> None:
    group = Group()
    group.append("de.lproj", direct=True, fail_after=prefix)
    spent = group.spent_gross
    group.close()
    assert group.spent_gross >= spent
    assert not group.slot_held
    assert group.live_blocks == 0


def test_reserved_table_key_and_duplicate_slots_remain_in_literal_inventory() -> None:
    result = group_cost(["LocProvenance", "de", "de"], [])
    assert [row[2] for row in result["records"]] == [13, 2, 2]
    assert result["keyCount"] == 3


@pytest.mark.parametrize("prefix", range(25))
def test_every_growth_failure_keeps_the_prior_key_and_can_retire(prefix: int) -> None:
    group = Group()
    group.append("a" * 255)
    first = group.records[0].copy()
    group.append("b", fail_after=prefix)
    assert group.records[0] == first
    spent = group.spent_gross
    group.close()
    assert group.spent_gross >= spent
    assert group.live_blocks == 0


def test_all_saved_associations_and_non_grouped_terms_remain_conditional() -> None:
    result = assess(Path(__file__).resolve().parents[1], freeze=False)
    assert len(result["episodeSpellings"]) == 2043
    assert len(result["outsidePaths"]) == 149
    assert result["systemSeedGroups"] == 2
    validate(result)
    for run in result["runs"].values():
        assert len(run["rows"]) == 2043
        assert run["completeGross"] is None
        assert run["actualResponseBytes"] is None
        assert run["withControlledWalkSubtotal"] > 20971520


def test_compact_storage_roundtrips_every_receipt_and_logical_owner_cost() -> None:
    from application_metadata_episode_certificate import integer, record, texts

    result = assess(Path(__file__).resolve().parents[1], freeze=False)
    saved = compact(result)
    profiles = saved["inventoryProfiles"]
    assert isinstance(profiles, list)
    for target, index in record(saved["inventories"]).items():
        assert profiles[integer(index)] == result["inventories"][target]
    nested = record(saved["nestedColumns"])
    for name, encoded in record(saved["runs"]).items():
        run = record(encoded)
        columns = texts(run["columns"])
        rows = run["rows"]
        assert isinstance(rows, list)
        for original, values in zip(result["runs"][name]["rows"],
                                    cast(list[object], rows), strict=True):
            assert isinstance(values, list)
            decoded: dict[str, object] = dict(zip(columns, cast(list[object], values), strict=True))
            decoded["spelling"] = result["episodeSpellings"][integer(decoded["ordinal"])]
            for key, labels in nested.items():
                cells = decoded[key]
                assert isinstance(cells, list)
                decoded[key] = dict(zip(texts(labels), cast(list[object], cells), strict=True))
            assert decoded == original


def test_report_validator_rejects_missing_rows_receipts_and_unknown_to_zero() -> None:
    import copy

    result = assess(Path(__file__).resolve().parents[1], freeze=False)
    for mutation in ("association", "replacement", "unknown", "wire", "outside", "fit"):
        changed = copy.deepcopy(result)
        run = changed["runs"]["de"]
        if mutation == "association":
            changed["episodeSpellings"].reverse()
        elif mutation == "replacement":
            run["rows"][0]["replacementReceipts"].pop("rawEntryProjectionGross")
        elif mutation == "unknown":
            run["completeGross"] = 0
        elif mutation == "wire":
            run["actualResponseBytes"] = 0
        elif mutation == "outside":
            changed["outsidePaths"].pop()
        else:
            changed["usefulFitEstablished"] = True
        with pytest.raises(ContractViolation):
            validate(changed)
