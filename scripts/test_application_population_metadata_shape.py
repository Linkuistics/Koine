"""Evidence comparisons must reject shape/association loss without claiming qualification."""

# pyright: strict
from __future__ import annotations

import copy
import json
from collections.abc import Callable
from pathlib import Path
from typing import cast

import application_population_metadata_shape as audit
import pytest
from application_population_metadata_shape import (
    build_report,
    check_controls,
    projection_errors,
    report_errors,
)

ROOT = Path(__file__).resolve().parents[1]


def test_saved_projection_cannot_qualify_and_integrity_controls_reject_edits() -> None:
    result = build_report()
    assert result["outcome"] == "CORPUS_INSUFFICIENT"
    assert result["qualificationShapeEstablished"] is False
    assert result["nativeVerdict"] == "PENDING"
    assert len(cast(list[object], result["perCopyEvidence"])) == 640
    counts = cast(dict[str, int], result["missingEvidence"])
    assert counts["fixedFilePayloads"] > 0
    assert counts["completeTableTypedValues"] > 0
    check_controls()


def test_loss_inventory_enumerates_fields_and_ambiguous_information_flags() -> None:
    result = build_report()
    assert "fileProjectionInventory" in result
    inventory = cast(dict[str, object], result["fileProjectionInventory"])
    fields = cast(list[dict[str, object]], inventory["fields"])
    assert {field["field"] for field in fields} == {
        "relative", "role", "state", "bytes", "sha256", "identity", "parsed",
        "dictionaryKeys", "localeKeys", "otherKeys", "localeDictionaryKeys",
        "names", "maximumNameBytes", "name", "identifier", "identifierNativeType",
        "developmentRegion", "developmentRegionNativeType", "flags",
    }
    missing = cast(dict[str, object], result["missingEvidence"])
    assert missing["ambiguousInformationFlags"] == {
        "LSUIElement": 474, "LSBackgroundOnly": 614,
    }


def test_supplied_facts_are_counted_present_and_unknown_fields_refuse() -> None:
    summarize = getattr(audit, "projection_inventory", None)
    assert callable(summarize), "the loss inventory must enumerate and classify supplied facts"
    inventory = cast(
        Callable[[list[dict[str, object]]], dict[str, object]], summarize,
    )
    information: dict[str, object] = {
        "relative": "Info.plist", "role": "INFORMATION", "state": "REGULAR",
        "flags": {"LSUIElement": None, "LSBackgroundOnly": None},
    }
    table: dict[str, object] = {
        "relative": "InfoPlist.loctable", "role": "GLOBAL_NAME", "state": "REGULAR",
    }
    missing = cast(dict[str, object], inventory([information, table])["missingEvidence"])
    assert missing["fixedFilePayloads"] == 2
    assert missing["formatTags"] == 2
    assert missing["completeTableTypedValues"] == 1
    assert missing["ambiguousInformationFlags"] == {
        "LSUIElement": 1, "LSBackgroundOnly": 1,
    }
    # Illustrative supplied facts are not a selected packaging format or verified replay.
    supplied = [
        {**file, "payload": "controlled bytes", "format": "controlled format",
         "typedEntries": {"LSUIElement": "malformed"}}
        for file in (information, table)
    ]
    present = cast(dict[str, object], inventory(supplied)["missingEvidence"])
    assert present == {
        "fixedFilePayloads": 0, "formatTags": 0, "completeTableTypedValues": 0,
        "individualNameKeyCandidates": 0,
        "ambiguousInformationFlags": {"LSUIElement": 0, "LSBackgroundOnly": 0},
    }
    with pytest.raises(ValueError, match="unclassified projection field"):
        inventory([{**information, "newUnclassifiedFact": True}])


def test_same_marginals_with_wrong_copy_associations_fail() -> None:
    subject = cast(
        dict[str, object],
        json.loads((ROOT / "docs/design/application-metadata-subject.json").read_text()),
    )
    rows = cast(list[dict[str, object]], subject["baseline"])
    changed = copy.deepcopy(rows)
    changed[0]["files"], changed[1]["files"] = changed[1]["files"], changed[0]["files"]
    assert projection_errors(rows, changed)
    assert not projection_errors(rows, rows)


@pytest.mark.parametrize("annotation,payloads,formats", [("payload", 0, 1), ("format", 1, 0)])
def test_payload_and_format_presence_are_independent(
    annotation: str, payloads: int, formats: int,
) -> None:
    summarize = cast(
        Callable[[list[dict[str, object]]], dict[str, object]],
        getattr(audit, "projection_inventory"),
    )
    file: dict[str, object] = {
        "relative": "Info.plist", "role": "INFORMATION", "state": "REGULAR",
        annotation: "controlled fact",
    }
    missing = cast(dict[str, object], summarize([file])["missingEvidence"])
    assert missing["fixedFilePayloads"] == payloads
    assert missing["formatTags"] == formats


def test_duplicate_or_missing_copy_is_rejected() -> None:
    subject = cast(
        dict[str, object],
        json.loads((ROOT / "docs/design/application-metadata-subject.json").read_text()),
    )
    rows = cast(list[dict[str, object]], subject["baseline"])
    for changed in (rows[:-1], [rows[0], *rows[1:-1], rows[0]]):
        assert projection_errors(rows, changed)


@pytest.mark.parametrize("claim", ["qualificationShapeEstablished", "nativeVerdict"])
def test_saved_manifest_cannot_lift_evidence_holds(claim: str) -> None:
    report = build_report()
    changed = copy.deepcopy(report)
    changed[claim] = True if claim == "qualificationShapeEstablished" else "PASSED"
    assert report_errors(changed)
