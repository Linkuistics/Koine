"""Controls at the actual protocol reader and raw transport boundaries; no GUI."""

import copy
import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "causal_protocol", ROOT / "docs/verification/settings-activation/causal-protocol.py"
)
assert SPEC and SPEC.loader
protocol = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(protocol)
BOOT = "2C83AC73-0855-44FD-A8A4-E03E227E1A01"
NONCE = "20f73e7f-1632-4c27-8c2c-35ab61bbcaac"


@pytest.fixture
def highlight():
    return {
        "format": "koine-menu-probe/1",
        "requestUUID": NONCE,
        "pid": 814,
        "menuSession": 3,
        "sampleTicks": "9007199254740993",
        "highlightedSettings": True,
    }


@pytest.fixture
def snapshot(highlight):
    direct = {
        "menuSession": 3,
        "requestUUID": NONCE,
        "inputSerial": 7,
        "type": 10,
        "keyCode": 36,
        "modifierFlags": 0,
        "isARepeat": False,
        "highlightedSettings": True,
        "sameEvent": True,
    }
    clock = {"bootSessionUUID": BOOT, "numerator": 125, "denominator": 3}
    rows = [
        {"event": "menu.input", "selection": 1, "menuProbe": direct},
        {
            "event": "callback.settings",
            "selection": 2,
            "menuProbe": copy.deepcopy(direct),
        },
        {
            "event": "application.activate.interval",
            "selection": 2,
            "activationInterval": {
                "beforeTicks": "9007199254741000",
                "afterTicks": "9007199254741010",
            },
            "nativeClock": clock,
        },
        {"event": "buffer.dump", "selection": 2},
    ]
    for index, row in enumerate(rows, 1):
        row.update(sequence=index, pid=814)
    return {
        "format": "koine-settings-events/1",
        "capacity": 4096,
        "dropped": 0,
        "records": rows,
    }


@pytest.fixture
def native():
    clients = [
        {
            "processID": 814,
            "processImagePath": "/Applications/Koine.app/Contents/MacOS/Koine",
            "processImageUUID": "D1AF277B-BFEE-3EA8-9B15-F071B31B69F1",
            "bootUUID": BOOT,
            "machTimestamp": 9007199254741005,
            "eventMessage": "0[outside of RPC]: SLSSetFrontProcessWithInfo(...)",
        }
    ]
    # The whole-process model retains a separate launch-prefix row.
    return [dict(clients[0], machTimestamp=50), *clients]


@pytest.fixture
def identity():
    return {
        "guestBootBefore": BOOT,
        "guestBootAfter": BOOT,
        "archiveBoot": BOOT,
        "timesyncBoot": BOOT,
        "numerator": 125,
        "denominator": 3,
        "pid": 814,
        "imageUUID": "D1AF277B-BFEE-3EA8-9B15-F071B31B69F1",
    }


def test_normalized_raw_highlight_transport(highlight):
    raw = {
        "ok": True,
        "exit_code": 0,
        "timed_out": False,
        "stderr": "",
        "stdout": json.dumps(highlight),
    }
    assert (
        protocol.read_highlight(protocol.read_transport(raw, 0), NONCE, 814)
        == highlight
    )


@pytest.mark.parametrize(
    "change",
    [
        {"ok": False},
        {"exit_code": -1},
        {"timed_out": True},
        {"timed_out": None},
        {"stderr": "partial"},
        {"stdout": "{}\n{}"},
    ],
)
def test_transport_rejects_failed_or_partial_envelopes(highlight, change):
    raw = {
        "ok": True,
        "exit_code": 0,
        "timed_out": False,
        "stderr": "",
        "stdout": json.dumps(highlight),
    }
    raw.update(change)
    with pytest.raises(ValueError):
        protocol.read_transport(raw, 0)


def test_cli_failure_cannot_be_rescued_by_matching_text(highlight):
    with pytest.raises(ValueError):
        protocol.read_transport(
            {
                "ok": True,
                "exit_code": 0,
                "timed_out": False,
                "stderr": "",
                "stdout": json.dumps(highlight),
            },
            1,
        )


@pytest.mark.parametrize(
    "change",
    [
        {"requestUUID": BOOT},
        {"pid": 815},
        {"highlightedSettings": False},
        {"menuSession": 0},
        {"sampleTicks": 9007199254740993},
        {"sampleTicks": "1e10"},
    ],
)
def test_highlight_requires_fresh_nonce_identity_and_actual_highlight(
    highlight, change
):
    highlight.update(change)
    with pytest.raises(ValueError):
        protocol.read_highlight(highlight, NONCE, 814)


def test_positive_return_requires_direct_input_and_same_callback_event(
    snapshot, highlight
):
    assert (
        protocol.return_invocation(snapshot, highlight, 2, NONCE)["qualified"] is True
    )


@pytest.mark.parametrize(
    "defect",
    [
        "missing",
        "stale",
        "repeat",
        "wrong-key",
        "modifier",
        "unhighlighted",
        "wrong-session",
        "duplicate",
        "intervening",
    ],
)
def test_return_rejects_transport_only_and_stale_current_event(
    snapshot, highlight, defect
):
    rows = snapshot["records"]
    direct = rows[0]["menuProbe"]
    callback = rows[1]["menuProbe"]
    if defect == "missing":
        rows.pop(0)
    elif defect == "stale":
        callback["sameEvent"] = False
    elif defect == "repeat":
        direct["isARepeat"] = callback["isARepeat"] = True
    elif defect == "wrong-key":
        direct["keyCode"] = callback["keyCode"] = 76
    elif defect == "modifier":
        direct["modifierFlags"] = callback["modifierFlags"] = 1048576
    elif defect == "unhighlighted":
        direct["highlightedSettings"] = callback["highlightedSettings"] = False
    elif defect == "wrong-session":
        direct["menuSession"] = callback["menuSession"] = 4
    else:
        inserted = copy.deepcopy(rows[0])
        if defect == "intervening":
            inserted["menuProbe"]["inputSerial"] = 8
        rows.insert(1, inserted)
    for index, row in enumerate(rows, 1):
        row["sequence"] = index
    with pytest.raises(ValueError):
        protocol.return_invocation(snapshot, highlight, 2, NONCE)


@pytest.mark.parametrize(
    "tick, outcome",
    [
        (9007199254741000, "ENCLOSED"),
        (9007199254741010, "ENCLOSED"),
        (9007199254740999, "OUTSIDE"),
        (9007199254741011, "OUTSIDE"),
    ],
)
def test_exact_closed_containment_above_double_precision(
    snapshot, native, identity, tick, outcome
):
    native[1]["machTimestamp"] = tick
    result = protocol.containment(snapshot, native, identity, 2)
    assert result["outcome"] == outcome
    assert result["qualified"] is (outcome == "ENCLOSED")
    if outcome == "OUTSIDE":
        assert result["distanceTicks"] == "1"


@pytest.mark.parametrize("count, outcome", [(0, "MISSING"), (2, "AMBIGUOUS")])
def test_missing_and_ambiguous_are_not_refusals(
    snapshot, native, identity, count, outcome
):
    assert (
        protocol.containment(snapshot, native * count, identity, 2)["outcome"]
        == outcome
    )


@pytest.mark.parametrize(
    "defect",
    [
        "boot",
        "guest-boot",
        "scale",
        "reversed",
        "metadata",
        "float",
        "pid",
        "image",
        "dropped",
        "sequence",
        "dump",
    ],
)
def test_invalid_instruments_stop_interpretation(snapshot, native, identity, defect):
    interval = snapshot["records"][2]
    if defect == "boot":
        interval["nativeClock"]["bootSessionUUID"] = NONCE
    elif defect == "guest-boot":
        identity["guestBootAfter"] = NONCE
    elif defect == "scale":
        identity["numerator"] = 1
    elif defect == "reversed":
        interval["activationInterval"]["afterTicks"] = "0"
    elif defect == "metadata":
        interval["nativeClockError"] = "failed"
    elif defect == "float":
        native[0]["machTimestamp"] = float(native[0]["machTimestamp"])
    elif defect == "pid":
        native[0]["processID"] = 815
    elif defect == "image":
        native[0]["processImageUUID"] = NONCE
    elif defect == "dropped":
        snapshot["dropped"] = 1
    elif defect == "sequence":
        snapshot["records"][0]["sequence"] = 2
    else:
        snapshot["records"].pop()
    result = protocol.containment(snapshot, native, identity, 2)
    assert result["outcome"] == "INVALID"
    assert result["qualified"] is False


@pytest.mark.parametrize(
    "failure", ["none", "move", "request", "highlight", "key", "timeout"]
)
@pytest.mark.parametrize("mode", ["mouse", "Return"])
def test_real_route_stops_at_each_transport_without_replaying_input(
    tmp_path, highlight, failure, mode
):
    calls = []

    def runner(command, **kwargs):
        calls.append(command)
        action = command[1:3]
        selection_action = ["input", "key" if mode == "Return" else "click"]
        if failure == "timeout" and action == selection_action:
            raise subprocess.TimeoutExpired(command, 30, output=b"partial")
        raw = {"ok": True, "schema_version": "1.0"}
        status = 0
        if action == ["file", "exec"]:
            guest = command[3]
            if "osascript" in guest:
                output = [1880, 60, 30, 22]
            elif "cat " in guest:
                output = highlight
                if failure == "highlight":
                    output = dict(highlight, highlightedSettings=False)
            else:
                output = {"requestUUID": NONCE.upper()}
            raw.update(
                exit_code=0, timed_out=False, stderr="", stdout=json.dumps(output)
            )
            if failure == "request" and "printf" in guest:
                raw.update(timed_out=True, exit_code=-1)
        if failure == "move" and action == ["input", "move"]:
            status = 7
        if failure == "key" and action == selection_action:
            raw["ok"] = False
        return subprocess.CompletedProcess(command, status, json.dumps(raw), "")

    # The real function drives exactly the same command/parser seam as the CLI.
    if failure == "none":
        protocol.select_row(
            mode,
            NONCE,
            814,
            "frozen-vm-id",
            tmp_path / "route",
            runner=runner,
            pause=lambda _: None,
        )
    else:
        with pytest.raises(ValueError):
            protocol.select_row(
                mode,
                NONCE,
                814,
                "frozen-vm-id",
                tmp_path / "route",
                runner=runner,
                pause=lambda _: None,
            )
    keys = [c for c in calls if c[1:3] in [["input", "key"], ["input", "click"]]]
    assert len(keys) == (1 if failure in {"none", "key", "timeout"} else 0)
    if keys:
        assert keys[0][1:-3] == (
            ["input", "key", "Return"]
            if mode == "Return"
            else ["input", "click", "1895", "71"]
        )
    assert all(c[-2:] == ["--vm", "frozen-vm-id"] for c in calls)
    assert (tmp_path / "route").exists()


@pytest.mark.parametrize(
    "stage, success, joined, next_action",
    [
        ("launch", True, "PENDING", "SETUP_PROVISIONAL"),
        ("launch", True, "ENCLOSED", "SETUP_PROVISIONAL"),
        ("setup", True, "PENDING", "MEASURE_PROVISIONAL"),
        ("launch", False, "PENDING", "STOP_SLOT"),
        ("setup", False, "ENCLOSED", "STOP_SLOT"),
        ("launch", True, "OUTSIDE", "STOP_SLOT"),
        ("launch", True, "MISSING", "STOP_SLOT"),
        ("launch", True, "AMBIGUOUS", "STOP_SLOT"),
        ("setup", True, "INVALID", "STOP_SLOT"),
    ],
)
def test_control_policy_never_retries_setup(stage, success, joined, next_action):
    assert protocol.control_policy(stage, success, joined)["next"] == next_action


def test_final_credit_requires_both_positive_native_controls():
    assert protocol.control_policy("final", None, "ENCLOSED", "ENCLOSED")["qualified"]
    for result in ["PENDING", "OUTSIDE", "MISSING", "AMBIGUOUS", "INVALID"]:
        assert (
            protocol.control_policy("final", None, "ENCLOSED", result)["next"]
            == "STOP_SLOT"
        )


@pytest.mark.parametrize("defect", ["none", "partial", "count", "duplicate"])
def test_native_completion_is_required_before_any_join(native, defect):
    rows = native + [{"count": len(native), "finished": 1}]
    if defect == "partial":
        rows.pop()
    elif defect == "count":
        rows[-1]["count"] += 1
    elif defect == "duplicate":
        rows.append(rows[-1])
    text = "\n".join(json.dumps(row) for row in rows)
    if defect == "none":
        assert protocol.read_native(text) == native
    else:
        with pytest.raises(ValueError):
            protocol.read_native(text)


def test_complete_process_clients_are_matched_in_order_not_filtered_for_enclosure(
    snapshot, native, identity
):
    earlier = copy.deepcopy(snapshot["records"][2])
    earlier["selection"] = 0
    earlier["activationInterval"] = {"beforeTicks": "100", "afterTicks": "110"}
    snapshot["records"].insert(0, earlier)
    for index, row in enumerate(snapshot["records"], 1):
        row["sequence"] = index
    prior_client = dict(native[0], machTimestamp=105)
    whole_process = native + [prior_client]
    assert (
        protocol.containment(snapshot, whole_process, identity, 0)["selectedTick"]
        == "105"
    )
    assert protocol.containment(snapshot, whole_process, identity, 2)["qualified"]
    whole_process.append(dict(native[0], machTimestamp=999))
    assert (
        protocol.containment(snapshot, whole_process, identity, 2)["outcome"]
        == "AMBIGUOUS"
    )


def test_control_cli_returns_provisional_progress_without_claiming_qualification():
    result = subprocess.run(
        [sys.executable, str(SPEC.origin), "control", "launch", "--focus-success"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0
    assert json.loads(result.stdout) == {
        "qualified": False,
        "next": "SETUP_PROVISIONAL",
        "nativeControlsPending": True,
    }


def test_retained_whole_process_rendering_has_explicit_launch_prefix(
    snapshot, identity
):
    """Real retained rows; synthetic brackets do NOT qualify the old app clock."""
    evidence = ROOT / "docs/verification/settings-activation/persisted-01"
    native = [
        json.loads(line)
        for line in (evidence / "native-path-records.jsonl").read_text().splitlines()
    ]
    actual = [
        r
        for r in native
        if r.get("processImagePath") == protocol.IMAGE
        and "SLSSetFrontProcessWithInfo" in r.get("eventMessage", "")
    ]
    historical = [
        json.loads(line)
        for line in (evidence / "events.jsonl").read_text().splitlines()
    ]
    calls = [r for r in historical if r["event"] == "application.activate.before"]
    assert len(actual) == len(calls) + 1 == 4
    template = snapshot["records"][2]
    snapshot["records"] = []
    for selection, client in enumerate(actual[1:]):
        interval = copy.deepcopy(template)
        interval.update(selection=selection, sequence=selection + 1)
        interval["activationInterval"] = {
            "beforeTicks": str(client["machTimestamp"] - 1),
            "afterTicks": str(client["machTimestamp"] + 1),
        }
        snapshot["records"].append(interval)
    snapshot["records"].append(
        {"event": "buffer.dump", "sequence": 4, "pid": 814, "selection": 2}
    )
    for selection in range(3):
        result = protocol.containment(snapshot, native, identity, selection)
        assert result["outcome"] == "ENCLOSED"
        assert result["launchPrefixTick"] == str(actual[0]["machTimestamp"])
        assert len(result["candidateTicks"]) == 4
        assert result["selectedTick"] == str(actual[selection + 1]["machTimestamp"])
    # A missing wrapped-call row must not be hidden by the launch-prefix row.
    without_call = [r for r in native if r is not actual[2]]
    assert (
        protocol.containment(snapshot, without_call, identity, 2)["outcome"]
        == "MISSING"
    )


def test_prefix_is_required_and_must_precede_first_bracket(snapshot, native, identity):
    assert (
        protocol.containment(snapshot, native[1:], identity, 2)["outcome"] == "MISSING"
    )
    native[0]["machTimestamp"] = 9007199254741000
    assert protocol.containment(snapshot, native, identity, 2)["outcome"] == "AMBIGUOUS"


def test_final_focus_input_is_rejected_instead_of_testing_measured_success():
    for measured in [True, False]:
        with pytest.raises(ValueError, match="final.*focus"):
            protocol.control_policy("final", measured, "ENCLOSED", "ENCLOSED")


def test_final_cli_needs_no_measured_focus_input():
    result = subprocess.run(
        [
            sys.executable,
            str(SPEC.origin),
            "control",
            "final",
            "--launch-join",
            "ENCLOSED",
            "--setup-join",
            "ENCLOSED",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0
    assert json.loads(result.stdout)["next"] == "CLASSIFY_MEASURED"


def test_return_rejects_highlight_from_another_route_nonce(snapshot, highlight):
    with pytest.raises(ValueError, match="nonce"):
        protocol.return_invocation(snapshot, highlight, 2, BOOT)


@pytest.fixture
def mouse_snapshot(snapshot):
    snapshot = copy.deepcopy(snapshot)
    down = snapshot["records"][0]
    down["menuProbe"].update(type=1, keyCode=None, inputSerial=8)
    up = copy.deepcopy(down)
    up["menuProbe"].update(type=2, inputSerial=9)
    snapshot["records"].insert(1, up)
    callback = snapshot["records"][2]
    callback["menuProbe"] = dict(up["menuProbe"], sameEvent=False)
    for index, row in enumerate(snapshot["records"], 1):
        row["sequence"] = index
    return snapshot


def test_mouse_delivery_uses_direct_pair_even_with_saved_stale_current_event(
    mouse_snapshot, highlight
):
    result = protocol.mouse_invocation(mouse_snapshot, highlight, 2, NONCE)
    assert result["qualified"] is True
    assert result["inputSerials"] == [8, 9]
    assert result["scope"] == "observed mouse-pair-to-callback correlation"


@pytest.mark.parametrize(
    "defect",
    [
        "missing-down",
        "missing-up",
        "reversed",
        "intervening",
        "wrong-session",
        "wrong-nonce",
        "unhighlighted",
        "modifier",
        "wrong-callback",
        "serial",
        "pid",
    ],
)
def test_mouse_delivery_rejects_unqualified_pair(mouse_snapshot, highlight, defect):
    rows = mouse_snapshot["records"]
    if defect == "missing-down":
        rows.pop(0)
    elif defect == "missing-up":
        rows.pop(1)
    elif defect == "reversed":
        rows[0], rows[1] = rows[1], rows[0]
    elif defect == "intervening":
        rows.insert(1, copy.deepcopy(rows[0]))
    elif defect == "wrong-session":
        rows[0]["menuProbe"]["menuSession"] += 1
    elif defect == "wrong-nonce":
        rows[0]["menuProbe"]["requestUUID"] = BOOT
    elif defect == "unhighlighted":
        rows[0]["menuProbe"]["highlightedSettings"] = False
    elif defect == "modifier":
        rows[0]["menuProbe"]["modifierFlags"] = 1
    elif defect == "wrong-callback":
        rows[2]["menuProbe"]["inputSerial"] = 8
    elif defect == "serial":
        rows[1]["menuProbe"]["inputSerial"] = 10
        rows[2]["menuProbe"]["inputSerial"] = 10
    else:
        rows[0]["pid"] = 815
    for index, row in enumerate(rows, 1):
        row["sequence"] = index
    with pytest.raises(ValueError):
        protocol.mouse_invocation(mouse_snapshot, highlight, 2, NONCE)


@pytest.mark.parametrize(
    "frame",
    [
        [-1, 10, 30, 22],
        [1900, 10, 30, 22],
        [10, 1070, 30, 22],
        [10, 10, 0, 22],
        [10, 10, 30, -1],
        [10, 10, 30],
        [10, 10, True, 22],
    ],
)
def test_bad_geometry_stops_before_any_input(tmp_path, frame):
    calls = []

    def runner(command, **kwargs):
        calls.append(command)
        return subprocess.CompletedProcess(
            command,
            0,
            json.dumps(
                {
                    "ok": True,
                    "exit_code": 0,
                    "timed_out": False,
                    "stderr": "",
                    "stdout": json.dumps(frame),
                }
            ),
            "",
        )

    with pytest.raises(ValueError):
        protocol.select_row(
            "mouse",
            NONCE,
            814,
            "frozen-vm-id",
            tmp_path / "route",
            runner=runner,
            pause=lambda _: None,
        )
    assert len(calls) == 1
    assert calls[0][1:3] == ["file", "exec"]


def test_existing_output_is_refused_before_transport(tmp_path):
    output = tmp_path / "route"
    output.mkdir()
    (output / "original").write_text("preserve")

    def forbidden(*args, **kwargs):
        pytest.fail("an existing route must send no command")

    with pytest.raises(FileExistsError):
        protocol.select_row(
            "mouse",
            NONCE,
            814,
            "frozen-vm-id",
            output,
            runner=forbidden,
            pause=forbidden,
        )
    assert (output / "original").read_text() == "preserve"


@pytest.mark.parametrize("mode", ["return", "mouse"])
@pytest.mark.parametrize("nonce", [NONCE, BOOT, None])
def test_delivery_cli_binds_expected_nonce(
    tmp_path, snapshot, mouse_snapshot, highlight, mode, nonce
):
    snapshot = mouse_snapshot if mode == "mouse" else snapshot
    events = tmp_path / "events.json"
    receipt = tmp_path / "highlight.json"
    events.write_text(json.dumps(snapshot))
    receipt.write_text(json.dumps(highlight))
    command = [
        sys.executable,
        str(SPEC.origin),
        mode,
        str(events),
        "--highlight",
        str(receipt),
        "--selection",
        "2",
    ]
    if nonce is not None:
        command.extend(["--nonce", nonce])
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    assert result.returncode == (0 if nonce == NONCE else 2 if nonce is None else 1)


@pytest.mark.parametrize("defect", ["overlap", "duplicate-selection", "other-metadata"])
def test_entire_interval_sequence_is_validated(snapshot, native, identity, defect):
    earlier = copy.deepcopy(snapshot["records"][2])
    earlier.update(selection=0, sequence=1)
    earlier["activationInterval"] = {"beforeTicks": "100", "afterTicks": "110"}
    snapshot["records"].insert(0, earlier)
    native.append(dict(native[0], machTimestamp=105))
    for index, row in enumerate(snapshot["records"], 1):
        row["sequence"] = index
    if defect == "overlap":
        earlier["activationInterval"]["afterTicks"] = "9007199254741000"
    elif defect == "duplicate-selection":
        earlier["selection"] = 2
    else:
        earlier["nativeClockError"] = "failure in nonselected interval"
    assert protocol.containment(snapshot, native, identity, 2)["outcome"] == "INVALID"
