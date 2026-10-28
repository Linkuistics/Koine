"""Protect the offline extract against silent loss and false context matching."""

import json
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
PROGRAM = ROOT / "docs/verification/settings-activation/focus-extract.jq"
HEADER = ('Filtering the log data using "process IN {"Koine", "WindowServer", "Dock", '
          '"TextEdit", "runningboardd", "loginwindow", "lsd", "coreservicesd"}"')


def extract(text: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["jq", "-Rnc", "-f", str(PROGRAM)], input=text, text=True, capture_output=True, check=False,
    )


def test_native_chains_and_client_context_retain_original_line_and_fields():
    events = [
        {"eventMessage": "unrelated", "processID": 9},
        {"eventMessage": "chain did update (setDeferringRules) <keyboardFocus>",
         "processID": 164, "machTimestamp": 17, "bootUUID": "saved-boot"},
        {"eventMessage": "SLSSetFrontProcessWithInfo request", "processID": 814},
        {"eventMessage": "SetFrontProcessInternal resume", "processID": 164},
        {"eventMessage": "isActivationTokenActive result=-50", "processID": 164},
    ]
    result = extract(HEADER + "\n" + "\n".join(json.dumps(row) for row in events))
    assert result.returncode == 0, result.stderr
    rows = [json.loads(line) for line in result.stdout.splitlines()]
    assert rows == [{"sourceLine": 1, "header": HEADER}] + [
        {"sourceLine": number, "record": row} for number, row in enumerate(events[1:], 3)
    ]


@pytest.mark.parametrize("bad", ["corrupt", HEADER, "[]", '{"eventMessage":null}'])
def test_bad_or_repeated_header_cannot_silently_disappear(bad: str):
    result = extract('{"eventMessage":"unrelated"}\n' + bad + "\n")
    assert result.returncode != 0


def test_unknown_first_header_is_an_error():
    assert extract("Filtering the log data using unknown predicate\n").returncode != 0


def test_archive_completion_is_preserved_without_claiming_qualification():
    result = extract('{"eventMessage":"unrelated"}\n{"count":1,"finished":1}\n')
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout) == {
        "sourceLine": 2, "record": {"count": 1, "finished": 1},
    }


@pytest.mark.parametrize("count", ["corrupt", None, -1, 0.5, True, 1])
def test_corrupt_or_mismatched_completion_count_is_rejected(count: object):
    assert extract(json.dumps({"count": count, "finished": 1})).returncode != 0


@pytest.mark.parametrize("suffix", ['{"count":0,"finished":1}',
                                   '{"eventMessage":"unrelated"}'])
def test_completion_is_unique_and_terminal(suffix: str):
    assert extract('{"count":0,"finished":1}\n' + suffix + "\n").returncode != 0
