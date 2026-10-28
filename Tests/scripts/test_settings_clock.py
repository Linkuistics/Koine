"""Catch false clock qualification, wrong-boot scale and broken evidence admission."""

import copy
import importlib.util
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "docs/verification/settings-activation"
SPEC = importlib.util.spec_from_file_location("clock_report", EVIDENCE / "clock-report.py")
assert SPEC is not None and SPEC.loader is not None
READER = importlib.util.module_from_spec(SPEC)


@pytest.fixture
def inputs():
    return (
        json.loads((EVIDENCE / "persisted-01/settings-events.json").read_text()),
        [json.loads(s) for s in (EVIDENCE / "persisted-01/native-path-records.jsonl")
         .read_text().splitlines()],
        (EVIDENCE / "clock-evidence/timesync.txt").read_text(),
        "2C83AC73-0855-44FD-A8A4-E03E227E1A01",
    )


def report(inputs):
    assert SPEC is not None and SPEC.loader is not None
    SPEC.loader.exec_module(READER)
    return READER.report(*inputs)


def test_real_sample_retains_false_qualification_despite_numeric_enclosure(inputs):
    result = report(inputs)
    assert result["nativeTimebase"] == {"numerator": 125, "denominator": 3}
    assert result["qualified"] is False
    assert result["joinedSelections"] == []
    assert [r["selection"] for r in result["conditionalZeroSleepCandidates"]] == [1, 2]
    assert [r["machTimestamp"] for r in result["conditionalZeroSleepCandidates"]] == [
        4338579225, 4476843871,
    ]


@pytest.mark.parametrize("mutation", ["boot", "denominator", "missing", "duplicate"])
def test_wrong_or_ambiguous_native_boot_metadata_rejected(inputs, mutation):
    snapshot, native, dump, boot = copy.deepcopy(inputs)
    if mutation == "boot":
        boot = "00000000-0000-0000-0000-000000000000"
    elif mutation == "denominator":
        dump = dump.replace("125 / 3", "125 / 0")
    elif mutation == "missing":
        dump = ""
    else:
        dump += dump
    with pytest.raises(ValueError):
        report((snapshot, native, dump, boot))


@pytest.mark.parametrize("mutation", ["lost", "sequence", "after", "pid", "reversed"])
def test_broken_buffers_cannot_supply_intervals(inputs, mutation):
    snapshot, native, dump, boot = copy.deepcopy(inputs)
    if mutation == "lost":
        snapshot["dropped"] = 1
    elif mutation == "sequence":
        snapshot["records"][2]["sequence"] = 99
    else:
        after = next(r for r in snapshot["records"]
                     if r["event"] == "application.activate.after" and r["selection"] == 2)
        if mutation == "after":
            after["event"] = "other"
        elif mutation == "pid":
            after["pid"] += 1
        else:
            after["uptime"] = 0
    with pytest.raises(ValueError):
        report((snapshot, native, dump, boot))


def test_wrong_native_boot_cannot_match_by_pid_and_tick_fit(inputs):
    snapshot, native, dump, boot = copy.deepcopy(inputs)
    for row in native:
        if row["processImagePath"].endswith("/Koine"):
            row["bootUUID"] = "00000000-0000-0000-0000-000000000000"
    with pytest.raises(ValueError):
        report((snapshot, native, dump, boot))


def test_wrong_scale_has_no_candidates_but_never_becomes_qualified(inputs):
    snapshot, native, dump, boot = copy.deepcopy(inputs)
    result = report((snapshot, native, dump.replace("125 / 3", "1 / 1"), boot))
    assert result["conditionalZeroSleepCandidates"] == []
    assert result["qualified"] is False
