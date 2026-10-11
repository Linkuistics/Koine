"""Evidence comparisons must reject shape/association loss without claiming qualification."""

# pyright: strict
from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import cast

import pytest
from application_population_metadata_shape import (
    build_report,
    check_controls,
    projection_errors,
    report_errors,
)

ROOT = Path(__file__).resolve().parents[1]


def test_saved_projection_cannot_qualify_and_controls_discriminate() -> None:
    result = build_report()
    assert result["outcome"] == "CORPUS_INSUFFICIENT"
    assert result["qualificationShapeEstablished"] is False
    assert result["nativeVerdict"] == "PENDING"
    assert len(cast(list[object], result["perCopyEvidence"])) == 640
    counts = cast(dict[str, int], result["missingEvidence"])
    assert counts["fixedFilePayloads"] > 0
    assert counts["formatTags"] == counts["fixedFilePayloads"]
    assert counts["completeTableTypedValues"] > 0
    check_controls()


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
