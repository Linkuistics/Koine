"""Read frozen menu/Return/containment evidence. No guest calls or clock fitting.

All commands emit JSON. Exit 0 means qualified, 1 means unavailable/invalid,
2 means usage error. An unavailable result never authorizes an input retry.
"""

# pyright: strict, reportUnnecessaryIsInstance=false

import argparse
import json
import re
import subprocess
import time
from collections.abc import Callable
from pathlib import Path
from typing import Any
from uuid import UUID

IMAGE = "/Applications/Koine.app/Contents/MacOS/Koine"
# Read-only geometry of the already-open system-managed status menu. No AXPress,
# highlight assignment, foreground change, key equivalent or exploration input.
FRAME_COMMAND = (
    'osascript -l JavaScript -e \'const s=Application("System Events"); '
    'const p=s.processes.byName("Koine"); '
    'const i=p.menuBars[1].menuBarItems[0].menus[0].menuItems.byName("Settings…"); '
    "JSON.stringify([...i.position(),...i.size()])'"
)


def require(condition: bool, reason: str) -> None:
    if not condition:
        raise ValueError(reason)


def ticks(value: Any) -> int:
    require(
        isinstance(value, str) and re.fullmatch(r"0|[1-9][0-9]*", value) is not None,
        "tick endpoints must be exact decimal strings",
    )
    result = int(value)
    require(result <= 2**64 - 1, "tick exceeds UInt64")
    return result


def read_transport(raw: dict[str, Any], cli_status: int) -> Any:
    """Matching stdout cannot rescue a timeout, nonzero CLI or guest exit."""
    require(
        cli_status == 0
        and raw.get("ok") is True
        and raw.get("timed_out") is False
        and type(raw.get("exit_code")) is int
        and raw["exit_code"] == 0
        and raw.get("stderr") == "",
        "failed/partial raw transport; retain and stop slot",
    )
    result = json.loads(raw["stdout"])
    return result


def read_highlight(raw: dict[str, Any], nonce: str, pid: int) -> dict[str, Any]:
    require(
        raw.get("format") == "koine-menu-probe/1"
        and UUID(raw["requestUUID"]) == UUID(nonce)
        and type(raw.get("pid")) is int
        and raw["pid"] == pid
        and type(raw.get("menuSession")) is int
        and raw["menuSession"] > 0
        and raw.get("highlightedSettings") is True,
        "unavailable highlight/nonce/process; stop without selection",
    )
    ticks(raw["sampleTicks"])
    return raw


def records(snapshot: dict[str, Any]) -> list[dict[str, Any]]:
    rows = snapshot["records"]
    require(
        snapshot["format"] == "koine-settings-events/1"
        and type(snapshot["dropped"]) is int
        and snapshot["dropped"] == 0
        and 0 < len(rows) <= snapshot["capacity"] <= 4096
        and [r["sequence"] for r in rows] == list(range(1, len(rows) + 1))
        and rows[-1]["event"] == "buffer.dump",
        "dropped, incomplete or invalid buffer",
    )
    return rows


def return_invocation(
    snapshot: dict[str, Any],
    highlight: dict[str, Any],
    selection: int,
) -> dict[str, Any]:
    rows = records(snapshot)
    callbacks = [
        r
        for r in rows
        if r["selection"] == selection and r["event"].startswith("callback.")
    ]
    require(
        len(callbacks) == 1 and callbacks[0]["event"] == "callback.settings",
        "missing/ambiguous Settings callback",
    )
    callback = callbacks[0]
    read_highlight(highlight, highlight["requestUUID"], callback["pid"])
    invoked = callback["menuProbe"]
    # These fields come from the monitor's actual NSEvent argument, not currentEvent.
    require(
        invoked["type"] == 10
        and invoked["keyCode"] == 36
        and invoked["modifierFlags"] == 0
        and invoked["isARepeat"] is False
        and invoked["highlightedSettings"] is True
        and invoked["sameEvent"] is True
        and invoked["menuSession"] == highlight["menuSession"]
        and UUID(invoked["requestUUID"]) == UUID(highlight["requestUUID"]),
        "Return origin unqualified; stale currentEvent/clean transport is insufficient",
    )
    inputs = [
        r
        for r in rows
        if r["event"] == "menu.input"
        and r["menuProbe"]["menuSession"] == highlight["menuSession"]
        and UUID(r["menuProbe"]["requestUUID"]) == UUID(highlight["requestUUID"])
        and r["sequence"] < callback["sequence"]
    ]
    require(
        len(inputs) == 1
        and inputs[0]["pid"] == callback["pid"]
        and inputs[0]["menuProbe"] == invoked,
        "missing, duplicate or intervening direct input; stop interpretation",
    )
    return {
        "qualified": True,
        "selection": selection,
        "menuSession": highlight["menuSession"],
        "inputSerial": invoked["inputSerial"],
        "scope": "observed Return-to-callback route",
    }


def read_native(text: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = [
        json.loads(line) for line in text.splitlines() if line.strip()
    ]
    require(
        bool(rows)
        and isinstance(rows[-1], dict)
        and type(rows[-1].get("finished")) is int
        and rows[-1]["finished"] == 1
        and type(rows[-1].get("count")) is int
        and rows[-1]["count"] == len(rows) - 1
        and all(isinstance(row, dict) and "finished" not in row for row in rows[:-1]),
        "native rendering incomplete/ambiguous; retain raw completion failure",
    )
    return rows[:-1]


def control_policy(
    stage: str,
    focus_success: bool,
    launch_join: str,
    setup_join: str = "PENDING",
) -> dict[str, Any]:
    require(stage in {"launch", "setup", "final"}, "invalid control stage")
    allowed = {"PENDING", "ENCLOSED"} if stage != "final" else {"ENCLOSED"}
    valid = focus_success and launch_join in allowed
    if stage in {"setup", "final"}:
        valid = valid and setup_join in allowed
    action = "STOP_SLOT"
    if valid:
        action = {
            "launch": "SETUP_PROVISIONAL",
            "setup": "MEASURE_PROVISIONAL",
            "final": "CLASSIFY_MEASURED",
        }[stage]
    return {
        "qualified": bool(valid and stage == "final"),
        "next": action,
        "nativeControlsPending": stage != "final" and valid,
    }


def containment(
    snapshot: dict[str, Any],
    native: list[dict[str, Any]],
    identity: dict[str, Any],
    selection: int,
) -> dict[str, Any]:
    """Exact bounds only. A sole outside candidate is retained, never widened in."""
    try:
        rows = records(snapshot)
        intervals = [
            r
            for r in rows
            if r["selection"] == selection
            and r["event"] == "application.activate.interval"
        ]
        require(len(intervals) == 1, "missing/ambiguous interval")
        row = intervals[0]
        require(not row.get("nativeClockError"), "native metadata error")
        clock = row["nativeClock"]
        boot = UUID(clock["bootSessionUUID"])
        require(
            all(
                UUID(identity[key]) == boot
                for key in (
                    "guestBootBefore",
                    "guestBootAfter",
                    "archiveBoot",
                    "timesyncBoot",
                )
            ),
            "guest/archive/timesync boot mismatch",
        )
        for key in ("numerator", "denominator"):
            require(
                type(clock[key]) is int
                and type(identity[key]) is int
                and 0 < clock[key] == identity[key] <= 2**32 - 1,
                "guest/archive timebase mismatch",
            )
        require(
            type(identity["pid"]) is int and 0 < identity["pid"] == row["pid"],
            "process identity mismatch",
        )
        image = UUID(identity["imageUUID"])
        before = ticks(row["activationInterval"]["beforeTicks"])
        after = ticks(row["activationInterval"]["afterTicks"])
        require(before <= after, "reversed interval")
        # Retain the entire process rendering. Match a complete equal-cardinality
        # list by native order, never by filtering to desired enclosure endpoints.
        clients = [
            r
            for r in native
            if "SLSSetFrontProcessWithInfo" in r.get("eventMessage", "")
            and r.get("processImagePath") == IMAGE
        ]
        for client in clients:
            require(
                client["processID"] == row["pid"]
                and UUID(client["bootUUID"]) == boot
                and UUID(client["processImageUUID"]) == image,
                "native client identity mismatch",
            )
            require(
                type(client["machTimestamp"]) is int
                and 0 <= client["machTimestamp"] <= 2**64 - 1,
                "invalid native tick",
            )
        common = {
            "qualified": False,
            "selection": selection,
            "beforeTicks": str(before),
            "afterTicks": str(after),
            "candidateTicks": [str(c["machTimestamp"]) for c in clients],
        }
        all_intervals = [
            r for r in rows if r["event"] == "application.activate.interval"
        ]
        if len(clients) != len(all_intervals):
            return dict(
                common,
                outcome="MISSING" if len(clients) < len(all_intervals) else "AMBIGUOUS",
            )
        ordered = sorted(clients, key=lambda c: c["machTimestamp"])
        if len({c["machTimestamp"] for c in ordered}) != len(ordered):
            return dict(common, outcome="AMBIGUOUS")
        tick = ordered[all_intervals.index(row)]["machTimestamp"]
        common["selectedTick"] = str(tick)
        if not before <= tick <= after:
            return dict(
                common,
                outcome="OUTSIDE",
                distanceTicks=str(max(before - tick, tick - after)),
            )
        return dict(common, qualified=True, outcome="ENCLOSED")
    except (ValueError, KeyError, TypeError, AttributeError) as error:
        return {
            "qualified": False,
            "selection": selection,
            "outcome": "INVALID",
            "reason": str(error),
        }


def select_row(
    mode: str,
    nonce: str,
    pid: int,
    vm: str,
    output: Path,
    *,
    runner: Callable[..., subprocess.CompletedProcess[str]] = subprocess.run,
    pause: Callable[[float], None] = time.sleep,
) -> dict[str, Any]:
    """One already-open-menu selection; no VM lifecycle, retry or focus action.

    The caller owns the frozen subject, display, first-launch/setup controls,
    readiness and untouched outcome capture. Input success is not delivery proof.
    """
    require(
        mode in {"mouse", "Return"} and pid > 0 and bool(vm),
        "invalid route identity/mode",
    )
    nonce = str(UUID(nonce)).upper()
    output.mkdir(parents=True, exist_ok=False)
    counter = 0

    def call(tag: str, arguments: list[str]) -> Any:
        nonlocal counter
        counter += 1
        base = output / f"{counter:02d}-{tag}"
        command = ["testanyware", *arguments, "--json", "--vm", vm]
        base.with_suffix(".command.json").write_text(json.dumps(command))
        try:
            result = runner(
                command, capture_output=True, text=True, timeout=30, check=False
            )
        except subprocess.TimeoutExpired as error:
            for suffix, partial in ((".json", error.stdout), (".stderr", error.stderr)):
                text = (
                    partial.decode(errors="replace")
                    if isinstance(partial, bytes)
                    else partial or ""
                )
                base.with_suffix(suffix).write_text(text)
            base.with_suffix(".exit").write_text("timeout\n")
            raise ValueError(
                "host transport timeout; keep partial output and stop without retry"
            ) from error
        base.with_suffix(".json").write_text(result.stdout)
        base.with_suffix(".stderr").write_text(result.stderr)
        base.with_suffix(".exit").write_text(str(result.returncode) + "\n")
        raw = json.loads(result.stdout)
        require(
            result.returncode == 0
            and not result.stderr
            and raw.get("ok") is True
            and raw.get("dry_run", False) is False,
            "failed input/CLI envelope; stop slot",
        )
        return read_transport(raw, result.returncode) if arguments[0] == "file" else raw

    frame: list[int] = call("frame", ["file", "exec", FRAME_COMMAND])
    require(
        isinstance(frame, list)
        and len(frame) == 4
        and all(type(n) is int for n in frame),
        "malformed menu geometry; no input",
    )
    x, y, width, height = frame
    require(
        0 <= x < x + width <= 1920 and 0 <= y < y + height <= 1080,
        "row outside frozen 1920x1080 display; no input",
    )
    x += width // 2
    y += height // 2
    (output / "coordinates.json").write_text(
        json.dumps({"frame": frame, "target": [x, y]})
    )
    call("approach", ["input", "move", str(max(0, x - 12)), str(max(0, y - 8))])
    pause(0.3)
    call("hover", ["input", "move", str(x), str(y)])
    pause(0.3)
    request = call(
        "request",
        [
            "file",
            "exec",
            (
                f"set -eu; printf '%s\\n' '{nonce}' > /Users/admin/settings-menu-probe/request; "
                f'printf \'{{"requestUUID":"{nonce}"}}\''
            ),
        ],
    )
    require(request == {"requestUUID": nonce}, "request acknowledgement mismatch")
    pause(1.0)
    receipt = call(
        "highlight",
        ["file", "exec", f"cat /Users/admin/settings-menu-probe/{nonce}.json"],
    )
    read_highlight(receipt, nonce, pid)
    (output / "highlight.json").write_text(json.dumps(receipt, indent=2))
    # No move after the highlight receipt. Exactly one selection command.
    action = (
        ["input", "key", "Return"]
        if mode == "Return"
        else ["input", "click", str(x), str(y)]
    )
    call("select", action)
    return {
        "qualified": False,
        "transportComplete": True,
        "reason": "input sent once; direct invocation and outcome remain unqualified",
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog=(
            "Examples: causal-protocol.py highlight raw.json --cli-status 0 --nonce UUID --pid 814; "
            "causal-protocol.py return events.json --highlight highlight.json --selection 2; "
            "causal-protocol.py containment events.json --native slice.json --identity identity.json --selection 2"
        ),
    )
    commands = parser.add_subparsers(dest="command", required=True)
    highlight = commands.add_parser("highlight", help="validate one raw highlight read")
    highlight.add_argument("input", type=Path)
    highlight.add_argument("--cli-status", required=True, type=int)
    highlight.add_argument("--nonce", required=True)
    highlight.add_argument("--pid", required=True, type=int)
    invocation = commands.add_parser(
        "return", help="qualify observed direct Return and callback"
    )
    invocation.add_argument("input", type=Path)
    invocation.add_argument("--highlight", required=True, type=Path)
    invocation.add_argument("--selection", required=True, type=int)
    join = commands.add_parser("containment", help="classify exact native containment")
    join.add_argument("input", type=Path)
    join.add_argument("--native", required=True, type=Path)
    join.add_argument("--identity", required=True, type=Path)
    join.add_argument("--selection", required=True, type=int)
    policy = commands.add_parser(
        "control", help="evaluate fixed control/stop policy; never sends input"
    )
    policy.add_argument("stage", choices=["launch", "setup", "final"])
    policy.add_argument("--focus-success", action="store_true")
    policy.add_argument("--launch-join", default="PENDING")
    policy.add_argument("--setup-join", default="PENDING")
    route = commands.add_parser(
        "select",
        help=(
            "send one selection to an already-open menu in an explicitly selected guest; "
            "NOT retry-safe; requires reviewed protocol and frozen caller readiness"
        ),
    )
    route.add_argument("mode", choices=["mouse", "Return"])
    route.add_argument("--nonce", required=True)
    route.add_argument("--pid", required=True, type=int)
    route.add_argument("--vm", required=True)
    route.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        source: dict[str, Any] = (
            {}
            if args.command in {"select", "control"}
            else json.loads(args.input.read_text())
        )
        if args.command == "control":
            result = control_policy(
                args.stage, args.focus_success, args.launch_join, args.setup_join
            )
        elif args.command == "select":
            result = select_row(args.mode, args.nonce, args.pid, args.vm, args.output)
        elif args.command == "highlight":
            result = {
                "qualified": True,
                "highlight": read_highlight(
                    read_transport(source, args.cli_status), args.nonce, args.pid
                ),
            }
        elif args.command == "return":
            result = return_invocation(
                source, json.loads(args.highlight.read_text()), args.selection
            )
        else:
            result = containment(
                source,
                read_native(args.native.read_text()),
                json.loads(args.identity.read_text()),
                args.selection,
            )
    except (ValueError, KeyError, TypeError, AttributeError, OSError) as error:
        result = {"qualified": False, "reason": str(error)}
    print(json.dumps(result, indent=2))
    # The selection subcommand reports transport completion without claiming
    # delivery qualification. Offline evidence commands require qualification.
    completed = result.get("transportComplete", result["qualified"])
    if args.command == "control":
        completed = result.get("next", "STOP_SLOT") != "STOP_SLOT"
    raise SystemExit(0 if completed else 1)


if __name__ == "__main__":
    main()
