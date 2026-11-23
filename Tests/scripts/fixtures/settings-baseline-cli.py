"""Simulated `testanyware` CLI for the baseline Settings scenario. No VM is used.

The baseline scenario of commit f019161b calls the CLI directly. This fixture
answers those calls from the guest model of settings-scenario-backend.py, so the
baseline and the current scenario run against one model. It appends each input,
window action, submission and upload to `$settings_sim/calls.jsonl` as one
`{"event": TEXT}` line. Reads and screenshots add no event.

An unknown command exits 98 and logs `{"unsimulated": ARGUMENTS}`, so a gap in
this fixture cannot pass as a clean guest answer.
"""

from __future__ import annotations

import importlib.util
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

SIM = Path(os.environ["settings_sim"])
_SPEC = importlib.util.spec_from_file_location(
    "settings_scenario_backend",
    os.environ["settings_backend"],
)
assert _SPEC is not None and _SPEC.loader is not None
model: Any = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(model)

ITEM = 'menu bar item 1 of menu bar 2 of process "Koine"'
SYSTEM_EVENTS = re.compile(r"""tell application "System Events" to (.*)'$""")
ROW = re.compile(
    r'get \{position, size\} of menu item "(.*)" of menu 1 of ' + re.escape(ITEM)
)
ENROL = re.compile(r'vm-verify-enrollment-client\.py "(.*)" enrol "(.*)" desktop:read')
SUBMISSIONS = (
    ("open /Applications/Koine.app", "open-koine"),
    ("open -a TextEdit", "open-textedit"),
    (
        """osascript -e 'tell application "TextEdit" to quit saving no'""",
        "quit-textedit",
    ),
    ('open "x-apple.systempreferences:', "open-accessibility-pane"),
    ("ditto -x -k /tmp/Koine.zip /Applications", "extract-bundle"),
    ("echo admin | sudo -S shutdown -r now", "restart"),
)


def event(text: str) -> None:
    with (SIM / "calls.jsonl").open("a") as stream:
        stream.write(json.dumps({"event": text}) + "\n")


def unsimulated(arguments: list[str]) -> int:
    with (SIM / "calls.jsonl").open("a") as stream:
        stream.write(json.dumps({"unsimulated": arguments}) + "\n")
    print(f"unsimulated CLI command: {arguments}", file=sys.stderr)
    return 98


def rendered(record: dict[str, Any]) -> tuple[str, int]:
    """One System Events record, as osascript prints it."""
    if record["absent"]:
        return "execution error: Invalid index. (-1719)", 1
    value = record["value"]
    if "text" in record:
        return str(record["text"]), 0
    if isinstance(value, list):
        return ", ".join(str(part) for part in value), 0
    if isinstance(value, bool):
        return str(value).lower(), 0
    return str(value), 0


def system_events(state: dict[str, Any], expression: str) -> tuple[str, int] | None:
    row = ROW.fullmatch(expression)
    if row:
        return rendered(model.sysevents(state, "menu-row-frame", [row.group(1)]))
    names = {
        "get name of every process": "sysevents-processes",
        'get count of menu bar items of menu bar 2 of process "Koine"': "menu-item-count",
        f"get description of {ITEM}": "menu-item-label",
        f"get {{position, size}} of {ITEM}": "menu-item-frame",
        f"get title of every menu item of menu 1 of {ITEM}": "menu-titles",
        'get background only of process "Koine"': "background-only",
        'get name of every UI element of list 1 of process "Dock"': "dock-items",
        "get name of first process whose frontmost is true": "front-application",
    }
    name = names.get(expression)
    if name is None:
        return None
    return rendered(model.sysevents(state, name, []))


def present(state: dict[str, Any]) -> bool:
    return bool(model.read(state, "endpoint", [])["present"])


def guest_read(state: dict[str, Any], command: str) -> tuple[str, int] | None:
    if command.startswith("nohup osascript") and "System Events" in command:
        model.read(state, "request-automation", [])
        event("submit request-automation")
        return "", 0
    matched = SYSTEM_EVENTS.search(command)
    if matched:
        return system_events(state, matched.group(1))
    enrol = ENROL.search(command)
    if enrol:
        model.read(state, "enrol", [enrol.group(1), enrol.group(2)])
        event(f"submit enrol {enrol.group(2)}")
        return json.dumps({"status": 200, "response": {"data": {}}}), 0
    if command.startswith("[ -e ") and command.endswith('endpoint.json" ]'):
        return "", 0 if present(state) else 1
    if command.startswith("[ ! -e ") and command.endswith('endpoint.json" ]'):
        return "", 1 if present(state) else 0
    if command.startswith("! pgrep -f "):
        return "", 1 if state["koine"] else 0
    if command.startswith("pgrep -lf "):
        return (f"{state['pid']} {model.INSTALLED}", 0) if state["koine"] else ("", 1)
    if command.startswith("jq -r .port "):
        return str(model.descriptor(state)["port"]), 0
    if command.startswith("curl -s -m 3 "):
        return str(model.read(state, "port-refusal", [])["curl_exit"]), 0
    if command == "sysctl -n kern.boottime":
        sec, usec = state["boot"]
        return f"{{ sec = {sec}, usec = {usec} }} Sun Nov 22 10:00:00 2026", 0
    if command.startswith("set -euo pipefail; cd "):
        return f"{'a' * 64}  ./Contents/Info.plist\nKOINE_INVENTORY_COMPLETE", 0
    fixed = {
        "sw_vers; uname -m": "ProductVersion: 27.2.1\narm64",
        "spctl --status": "assessments enabled",
    }
    if command in fixed:
        return fixed[command], 0
    if command.startswith("xattr -p com.apple.quarantine "):
        return "xattr: no such xattr", 0
    if command.startswith("codesign --verify "):
        return "valid on disk", 0
    if command.startswith("codesign --display "):
        return "Identifier=dev.antony.Koine", 0
    if command.startswith("spctl -a "):
        return "rejected", 3
    return None


def guest_exec(state: dict[str, Any], command: str) -> tuple[str, int] | None:
    for prefix, name in SUBMISSIONS:
        if command.startswith(prefix):
            model.read(state, name, [])
            event(f"submit {name}")
            return "", 0
    return guest_read(state, command)


def normalised_input(action: str, rest: list[str]) -> str:
    if action == "key":
        modifiers = rest[rest.index("--modifiers") + 1] if "--modifiers" in rest else ""
        return " ".join(filter(None, ["input key", rest[0], modifiers]))
    return " ".join(["input", action, *rest])


def run(state: dict[str, Any], arguments: list[str], root: Path) -> int:
    family, action, rest = arguments[0], arguments[1], arguments[2:]
    if (family, action) == ("vm", "stop"):
        return 0
    if (family, action) == ("vm", "start"):
        model.cli(state, ["", "--", family, action, *rest], root)
        return 0
    if (family, action) == ("file", "upload"):
        event(f"upload {rest[1]}")
        return 0
    if (family, action) == ("file", "exec"):
        answer = guest_exec(state, rest[0])
        if answer is None:
            return unsimulated(arguments)
        if answer[0]:
            print(answer[0])
        return answer[1]
    if (family, action) == ("screen", "capture"):
        Path(rest[rest.index("-o") + 1]).touch()
        return 0
    if (family, action) == ("screen", "find-text"):
        event(" ".join(["bound find-text", rest[0], *rest[1:3]]))
    if family == "screen" or (family, action) in {
        ("agent", "windows"),
        ("agent", "snapshot"),
    }:
        print(model.cli(state, ["", "--", family, action, *rest], root))
        return 0
    if family == "agent" and action.startswith("window-"):
        window = rest[rest.index("--window") + 1]
        where = [rest[rest.index(name) + 1] for name in ("--x", "--y") if name in rest]
        model.cli(state, ["", "--", family, action, *rest], root)
        event(" ".join(["window", action.removeprefix("window-"), window, *where]))
        return 0
    if family == "input":
        model.cli(state, ["", "--", family, action, *rest], root)
        event(normalised_input(action, rest))
        return 0
    return unsimulated(arguments)


def main() -> int:
    arguments = sys.argv[1:]
    root = SIM / "baseline-root"
    root.mkdir(exist_ok=True)
    subject = root / "subject.json"
    if not subject.exists():
        subject.write_text(json.dumps({"vm": os.environ["KOINE_VM_ID"]}))
    state = model.load()
    status = run(state, arguments, root)
    model.save(state)
    return status


if __name__ == "__main__":
    sys.exit(main())
