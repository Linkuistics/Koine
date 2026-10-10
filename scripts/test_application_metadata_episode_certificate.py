"""Detect lost episodes, uncharged branches and fabricated certificate closure."""
# pyright: strict

from __future__ import annotations

import json
from pathlib import Path

import pytest
from application_metadata_episode_certificate import (
    assess,
    explicit_calls,
    file_envelope,
    json_string_upper,
)
from application_metadata_operation_ledger import FILE_BRANCHES, Ledger, file_trace


def test_file_envelope_keeps_cleanup_and_extra_eof_input() -> None:
    # One present 8-byte file and two absent candidates: 9+2+2 calls,
    # six parser calls, and a possible ninth byte from the EOF check.
    assert file_envelope(3, [8]) == (13, 6, 9)


def test_empty_file_still_reads_payload_and_eof_and_retires_parser() -> None:
    assert file_envelope(1, [0]) == (9, 6, 1)


def test_repeated_input_is_cumulative_even_when_a_buffer_can_be_reused() -> None:
    assert file_envelope(3, [8, 5]) == (20, 12, 15)


@pytest.mark.parametrize("branch", sorted(FILE_BRANCHES))
def test_every_file_branch_fits_the_closed_envelope_with_actual_cleanup(branch: str) -> None:
    ledger = Ledger()
    file_trace(ledger, branch, 8)
    calls = {
        "PARENT_LIMIT_REFUSED": 1, "ABSENT": 2, "NAMED_REFUSED": 2,
        "OVERSIZE_NAMED": 2, "OPEN_FAILED": 3, "HELD_REFUSED": 5,
        "OVERSIZE_HELD": 5, "READ_ERROR": 6, "SHORT_READ": 6,
        "EOF_ERROR": 7, "EOF_EXTRA": 7, "HELD_CHANGED": 8,
        "NAMED_CHANGED": 9, "OK": 9,
    }
    assert ledger.spent_attempts == calls[branch]
    upper_calls, _, upper_bytes = file_envelope(1, [8])
    assert ledger.spent_attempts <= upper_calls and ledger.spent_bytes <= upper_bytes
    assert not ledger.resources


def test_explicit_calls_charge_duplicate_slots_and_complete_table_validation() -> None:
    # No files/layout: listing's dup/fdopendir/terminal/closedir = 4;
    # one valid locale descent = 6; two materialized CF keys = 4;
    # two independent selectors = 12; three raw returns = 15;
    # a table extraction = 1; two raw table pairs = 12;
    # one selected dictionary GetValue plus two four-call name getters = 11.
    assert explicit_calls(
        raw=0, locales=1, rejected=0, probes=0, sizes=[], layout_calls=0,
        information=False, strings=0, table_keys=2, tables=1,
        selectors=2, direct_keys=2, returns=3, table_plans=1,
    ) == 65


def test_rejected_locale_is_charged_and_never_a_healthy_empty_inventory() -> None:
    assert explicit_calls(
        raw=1, locales=0, rejected=1, probes=0, sizes=[], layout_calls=0,
        information=False, strings=0, table_keys=0, tables=0,
        selectors=0, direct_keys=0, returns=0, table_plans=0,
    ) == 11


def test_escaping_and_alias_multiplicity_cannot_be_refunded() -> None:
    assert json_string_upper(3, 2) == 40
    assert json_string_upper(1500, 1) == 9002


@pytest.mark.parametrize("value", [-1])
def test_negative_wire_dimension_is_not_a_zero_charge(value: int) -> None:
    with pytest.raises(ValueError):
        json_string_upper(value)


def test_all_saved_episodes_keep_missing_dimensions_and_independent_totals() -> None:
    root = Path(__file__).resolve().parent.parent
    subject = root / "docs/design/application-metadata-subject.json"
    proposal = root / "docs/design/application-metadata-budget-proposal.json"
    result = assess(subject, proposal)
    assert all(not path.startswith("/") for path in result["inputHashes"])
    dimensions = result["dimensions"]
    assert dimensions["episodes"] == 2043
    assert dimensions["distinctSpellings"] == 2043
    assert dimensions["aliasEpisodes"] == 128
    assert dimensions["outsideQueryPaths"] == 149
    assert dimensions["censusInputBytes"] == 7438626
    assert dimensions["validLocaleDirectories"] == 17881
    assert dimensions["rawTableKeys"] == 10024
    assert dimensions["rejectedLocaleEntries"] == 16
    assert dimensions["maximumNameBytes"] == 129
    assert dimensions["maximumRootBytes"] == 1500
    assert result["usefulSubjectCertificateEstablished"] is False
    assert result["grossBytes"] is None
    assert result["totalAttempts"] is None
    assert result["responseBytes"] is None
    assert result["nativeVerdict"] == "PENDING"
    assert result["source"]["controlledRawURLSlots"] == 7862
    assert result["source"]["actualIndexedTuples"] is None
    assert result["source"]["controlledIdentifierGroupsIncludingSystem"] == 1873
    rows = result["commonRows"]
    assert len(rows) == 2043
    # Independent summation of the saved census is the aggregate's second instrument.
    assert sum(row[1] for row in rows) == dimensions["censusInputBytes"]
    assert sum(row[5] for row in rows) == dimensions["rawTableKeys"]
    for run in result["runs"].values():
        assert len(run["rows"]) == 2043
        assert sum(row[-1] for row in run["rows"]) == run["explicitReaderCallsUpper"]
    saved = json.loads(subject.read_bytes())
    assert result["episodeSpellings"] == saved["episodeSpellings"]


def test_missing_proposal_episode_refuses_instead_of_zipping_a_shorter_population(
    tmp_path: Path,
) -> None:
    root = Path(__file__).resolve().parent.parent
    subject = root / "docs/design/application-metadata-subject.json"
    proposal = json.loads(
        (root / "docs/design/application-metadata-budget-proposal.json").read_bytes()
    )
    proposal["selectionRuns"]["de"]["rows"].pop()
    changed = tmp_path / "proposal.json"
    changed.write_text(json.dumps(proposal))
    with pytest.raises(ValueError, match="episode"):
        assess(subject, changed)
