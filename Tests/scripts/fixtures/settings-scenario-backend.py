"""Simulated evidence backend for the Settings scenario. No VM or CLI is used.

A test copies the repository and puts this file in place of
scripts/vm-guest-exec.py. The real shell facades then call it with the real
backend's actions and arguments. It answers each action with the record shape
that the real backend prints, from a small model of the guest. It does not
validate payloads: the facade tests own the schemas. It checks the scenario's
use of the domain instead:

- Every call is appended to `$settings_sim/calls.jsonl`.
- A latched root refuses every non-evidence call with status 125, as the real
  backend does.
- `settings_fault=OPERATION` makes that call unavailable: it latches the root
  and returns 125 (or `settings_fault_status`) without changing the model. The
  operation can name a read or a local poll record.
- The flag `menu-title-wrong` adds one unexpected title to each menu read.
- `settings_flags` holds comma-separated model variations for state controls.
- A snapshot answer must satisfy the facade's predicate, as in the real
  backend. Otherwise the call is unavailable: it latches and returns 125.
- `settings_at=N` (default 1) chooses the return that a setup, route or
  outcome flag affects. A return is a Settings, requests or Accessibility
  selection. A setup or route flag acts before the Nth return, and an outcome
  flag acts from the Nth return on.
- `settings_untitled_behind=OPERATION` answers that one window read with a
  focused Finder window in front of each Koine window, and each Koine window
  loses its title.
- `settings_finder_front=OPERATION` answers that one window read with a focused
  Finder window in front of each window. Each window keeps its title.
- The flag `resize-ignored` leaves the window frame unchanged after a release,
  `scroll-ignored` leaves the content where it is after a scroll, and
  `signature-invalid` makes the signature read invalid.
- `settings_close_ignored=OPERATION` leaves Koine's window open after that one
  window close.
- Each of these flags makes one poll of a facade exhaust cleanly (k166):
  `endpoint-absent` for the launch descriptor, `label-stuck` for the menu label,
  `item-frame-absent` for the item frame, `row-absent` for the row of the
  chosen return, `quit-row-absent` for the Quit row, `textedit-no-window` for
  the TextEdit window and `allow-substring` for the exact Allow target. Under
  `label-stuck`, each read also keeps the record that the failure message reads.
- Each of these flags drives one scenario-level control (k164). `add-absent`
  removes the Add button of the Accessibility pane. `silent-launch-window` shows
  a window at a launch after setup. `requests-off-screen` leaves the request
  rows above the visible content after their selection. `element-no-height`
  omits the height of `login-launch`. `element-no-position` omits the vertical
  position of `grant-label`.
- Two flags exhaust the restart polls for the baseline control (k175).
  `boot-stuck` keeps the boot time after a restart. `login-not-started` starts
  no Koine at login.
- `settings_no_value=OPERATION` omits AXValue from `grant-label` in that one
  snapshot (k175). A failed AX copy omits it, so the field is not empty.
- Each menu bar item has one menu. A closed menu has the size {0, 0}, and an
  open menu has a positive size. A guest qualified this signal (k5,
  scripts/vm-probe-menu-open.sh).
- A close of Koine's window while Koine is the active application leaves no
  window focused, until an application comes to the front. The agent's
  window-focus brings its target to the front. A guest showed both (k6,
  scripts/vm-probe-reopen-focus.sh). The flag `focus-ignored` makes each
  window-focus change nothing.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

SIM = Path(os.environ["settings_sim"])
FLAGS = set(filter(None, os.environ.get("settings_flags", "").split(",")))
AT = int(os.environ.get("settings_at", "1"))
# The operation of the current call, for an operation-scoped answer.
OPERATION = ""
TEXTEDIT_PID = 909
# The TextEdit menu bar items that the menu-bar-menu-sizes read names.
TEXTEDIT_MENUS = [
    "Apple",
    "TextEdit",
    "File",
    "Edit",
    "Format",
    "View",
    "Window",
    "Help",
]
TITLE = "Koine Settings"
INSTALLED = "/Applications/Koine.app"
# Menu bar item, and menu rows below it, in input coordinates.
ITEM = (1700, 0, 22, 24)
ROW_X, ROW_Y, ROW_W, ROW_H = 1650, 30, 200, 22
ALLOW = (900, 500, 60, 24)
# Content positions below the title bar, before scrolling.
CONTENT = {
    "grant-label": 100,
    "request-label-1": 300,
    "deny-1": 330,
    "request-label-2": 360,
    "deny-2": 390,
    "accessibility-status": 500,
    "login-launch": 600,
    "login-launch-status": 630,
}
CONTENT_HEIGHT = 800


def load() -> dict[str, Any]:
    path = SIM / "state.json"
    if path.exists():
        return json.loads(path.read_text())
    return {
        "vm": "absent",
        "boot": [1000, 1],
        "koine": False,
        "pid": 0,
        "instance": 0,
        "window": False,
        "frame": [300, 120, 480, 712],
        "offset": 0,
        "order": [],
        "textedit": False,
        "textedit_frame": [650, 80, 603, 505],
        "settings_app": False,
        "menu": False,
        "pending": 0,
        "granted": False,
        "automation": "none",
        "consent": 0,
        "login": False,
        "field": "",
        "field_focus": False,
        "clipboard": "",
        "selected": False,
        "drag": None,
        "returns": 0,
        "closes": 0,
        "unfocused": False,
    }


def save(state: dict[str, Any]) -> None:
    (SIM / "state.json").write_text(json.dumps(state))


def log(entry: dict[str, Any]) -> None:
    with (SIM / "calls.jsonl").open("a") as stream:
        stream.write(json.dumps(entry) + "\n")


def front(state: dict[str, Any], app: str) -> None:
    state["order"] = [app] + [name for name in state["order"] if name != app]
    state["unfocused"] = False


def drop(state: dict[str, Any], app: str) -> None:
    state["order"] = [name for name in state["order"] if name != app]


def before_return(state: dict[str, Any], flag: str) -> bool:
    """A setup or route flag, before the chosen return."""
    return flag in FLAGS and state["returns"] == AT - 1


def from_return(state: dict[str, Any], flag: str) -> bool:
    """An outcome flag, from the chosen return on."""
    return flag in FLAGS and state["returns"] >= AT


def label(state: dict[str, Any]) -> str:
    if "label-stuck" in FLAGS:
        return "Koine, stuck"
    parts = ["Koine"]
    if state["pending"]:
        noun = "request" if state["pending"] == 1 else "requests"
        parts.append(f"{state['pending']} grant {noun} waiting")
    if not state["granted"]:
        parts.append("Accessibility not granted")
    return ", ".join(parts)


def titles(state: dict[str, Any]) -> list[str]:
    rows: list[str] = []
    if state["pending"]:
        noun = "Request" if state["pending"] == 1 else "Requests"
        rows.append(f"Review {state['pending']} Grant {noun}…")
    if not state["granted"]:
        rows.append("Accessibility Not Granted…")
    if rows:
        rows.append("")
    return [*rows, "Settings…", "Quit Koine"]


def row_frame(state: dict[str, Any], title: str) -> list[list[int]] | None:
    rows = titles(state)
    if not state["menu"] or title not in rows:
        return None
    if before_return(state, "row-absent") or (
        "quit-row-absent" in FLAGS and title == "Quit Koine"
    ):
        return None
    index = rows.index(title)
    return [[ROW_X, ROW_Y + ROW_H * index], [ROW_W, ROW_H]]


def element_ids(state: dict[str, Any]) -> list[str]:
    ids = ["grant-label", "accessibility-status", "login-launch", "login-launch-status"]
    for number in range(1, state["pending"] + 1):
        ids += [f"request-label-{number}", f"deny-{number}"]
    return ids


def koine_elements(state: dict[str, Any]) -> list[dict[str, Any]]:
    x, y, w, h = state["frame"]
    elements = [
        {
            "role": "scrollArea",
            "platformRole": "AXScrollArea",
            "positionX": x,
            "positionY": y + 32,
            "sizeWidth": w,
            "sizeHeight": h - 32,
        }
    ]
    for ident in element_ids(state):
        value = ""
        if ident == "grant-label":
            value = state["field"]
        elif ident == "login-launch-status":
            value = (
                "Koine will start when you log in."
                if state["login"]
                else "Koine will not start when you log in."
            )
        elif ident.startswith("request-label-"):
            value = "vm-editor"
        element: dict[str, Any] = {
            "role": "textField" if ident == "grant-label" else "staticText",
            "platformRole": "AXTextField" if ident == "grant-label" else "AXStaticText",
            "id": ident,
            "value": value,
            "positionX": x + 20,
            "positionY": y + 30 + CONTENT[ident] - state["offset"],
            "sizeWidth": 200,
            "sizeHeight": 20,
        }
        # A failed AX copy omits the value. It is not an empty string.
        if "request-label-no-value" in FLAGS and ident.startswith("request-label-"):
            del element["value"]
        if ident == "grant-label" and OPERATION == os.environ.get("settings_no_value"):
            del element["value"]
        if "element-no-height" in FLAGS and ident == "login-launch":
            del element["sizeHeight"]
        if "element-no-position" in FLAGS and ident == "grant-label":
            del element["positionY"]
        elements.append(element)
    for element in elements:
        element.update(enabled=True, focused=False, childCount=0, actions=[])
    return elements


def settings_elements(state: dict[str, Any]) -> list[dict[str, Any]]:
    elements: list[dict[str, Any]] = []
    if "add-absent" not in FLAGS:
        elements.append(
            {
                "role": "button",
                "platformRole": "AXButton",
                "label": "Add",
                "positionX": 500,
                "positionY": 600,
                "sizeWidth": 30,
                "sizeHeight": 20,
            }
        )
    if state["granted"]:
        elements.append(
            {
                "role": "row",
                "platformRole": "AXRow",
                "label": "Koine",
                "positionX": 400,
                "positionY": 400,
                "sizeWidth": 300,
                "sizeHeight": 20,
            }
        )
    for element in elements:
        element.update(enabled=True, focused=False, childCount=0, actions=[])
    return elements


def window_entry(state: dict[str, Any], app: str) -> dict[str, Any]:
    focused = (
        bool(state["order"])
        and state["order"][0] == app
        and not state.get("unfocused", False)
    )
    if app == "Koine":
        x, y, w, h = state["frame"]
        entry: dict[str, Any] = {
            "title": "Koine" if from_return(state, "wrong-title") else TITLE,
            "appName": "Koine",
            "windowType": "standard",
            "focused": focused,
            "positionX": x,
            "positionY": y,
            "sizeWidth": w,
            "sizeHeight": h,
        }
        if from_return(state, "no-title"):
            del entry["title"]
        return entry
    if app == "TextEdit":
        x, y, w, h = state["textedit_frame"]
        # A setup flag changes the list only after the first close, so the
        # frame that the preparation records stays the original one.
        late = state["closes"] >= 1
        if late and before_return(state, "textedit-moved"):
            x += 40
        entry = {
            "title": "Document"
            if late and before_return(state, "textedit-title")
            else "Untitled",
            "appName": "TextEdit",
            "windowType": "standard",
            "focused": focused,
            "positionX": x,
            "positionY": y,
            "sizeWidth": w,
            "sizeHeight": h,
        }
        if late and before_return(state, "textedit-no-title"):
            del entry["title"]
        # The positive setup judges the front application by this flag.
        if late and before_return(state, "textedit-not-focused"):
            entry["focused"] = False
        if late and before_return(state, "textedit-no-focus"):
            del entry["focused"]
        return entry
    return {
        "title": "Accessibility",
        "appName": "System Settings",
        "windowType": "standard",
        "focused": focused,
        "positionX": 200,
        "positionY": 200,
        "sizeWidth": 700,
        "sizeHeight": 600,
    }


def finder_in_front(
    entries: list[dict[str, Any]], untitled: bool
) -> list[dict[str, Any]]:
    """A focused Finder window, then each window, untitled on Koine's if asked."""
    finder = {
        "title": "Desktop",
        "appName": "Finder",
        "windowType": "standard",
        "focused": True,
        "positionX": 40,
        "positionY": 60,
        "sizeWidth": 600,
        "sizeHeight": 400,
    }
    rest = []
    for entry in entries:
        entry = {**entry, "focused": False}
        if untitled and entry["appName"] == "Koine":
            entry.pop("title", None)
        rest.append(entry)
    return [finder, *rest]


def open_window(state: dict[str, Any], app: str) -> bool:
    return {
        "Koine": state["window"],
        "TextEdit": state["textedit"] and "textedit-no-window" not in FLAGS,
        "System Settings": state["settings_app"],
    }[app]


def windows(state: dict[str, Any]) -> list[dict[str, Any]]:
    entries = [
        window_entry(state, app) for app in state["order"] if open_window(state, app)
    ]
    if state["window"] and from_return(state, "two-windows"):
        entries.append({**window_entry(state, "Koine"), "focused": False})
    return entries


def show_koine(state: dict[str, Any], offset: int = 0) -> None:
    if "no-front-after-settings" in FLAGS and state["textedit"]:
        state["window"] = True
        state["order"] = [name for name in state["order"] if name != "Koine"] + [
            "Koine"
        ]
        return
    state["window"], state["offset"] = True, offset
    front(state, "Koine")


def quit_koine(state: dict[str, Any]) -> None:
    state.update(koine=False, window=False, menu=False)
    drop(state, "Koine")


def start_koine(state: dict[str, Any], window: bool) -> None:
    state["koine"] = True
    state["pid"] += 101
    state["instance"] += 1
    if window:
        show_koine(state)


def choose(state: dict[str, Any], title: str) -> None:
    state["menu"] = False
    if title != "Quit Koine":
        state["returns"] += 1
        if from_return(state, "menu-stays-open") and state["returns"] == AT:
            state["menu"] = True
        if state["returns"] == AT and FLAGS & {
            "zero-window-alive",
            "zero-window-crash",
            "zero-window-reused",
        }:
            # The selection shows no window. The process lives, ends or is
            # replaced under the same PID.
            if "zero-window-crash" in FLAGS:
                state.update(koine=False, menu=False)
            elif "zero-window-reused" in FLAGS:
                state["instance"] += 1
            return
    if title == "Settings…":
        show_koine(state)
    elif title.startswith("Review "):
        offset = CONTENT["request-label-1"]
        if "requests-off-screen" in FLAGS:
            offset = CONTENT_HEIGHT - (state["frame"][3] - 30)
        show_koine(state, offset)
    elif title == "Accessibility Not Granted…":
        show_koine(state, CONTENT["accessibility-status"])
    elif title == "Quit Koine":
        quit_koine(state)


def inside(x: int, y: int, box: tuple[int, int, int, int]) -> bool:
    return box[0] <= x < box[0] + box[2] and box[1] <= y < box[1] + box[3]


def click(state: dict[str, Any], x: int, y: int) -> None:
    if inside(x, y, ITEM):
        state["menu"] = True
        return
    if state["menu"]:
        for title in titles(state):
            frame = row_frame(state, title)
            if (
                frame
                and title
                and inside(x, y, (frame[0][0], frame[0][1], frame[1][0], frame[1][1]))
            ):
                choose(state, title)
                return
        return
    if state["automation"] == "prompt" and inside(x, y, ALLOW):
        state["automation"] = "granted"
        return
    if state["settings_app"] and state["order"][:1] == ["System Settings"]:
        if inside(x, y, (500, 600, 30, 20)):
            state["consent"] = 1
        return
    if not state["window"]:
        return
    for element in koine_elements(state):
        box = (
            element["positionX"],
            element["positionY"],
            element["sizeWidth"],
            element["sizeHeight"],
        )
        ident = element.get("id", "")
        if ident and inside(x, y, box):
            if ident == "grant-label":
                state["field_focus"] = True
            elif ident == "login-launch":
                state["login"] = True
            elif ident.startswith("deny-"):
                state["pending"] -= 1
            return


def key(state: dict[str, Any], name: str, modifiers: list[str]) -> None:
    top = state["order"][:1]
    if name == "escape":
        state["menu"] = False
    elif modifiers == ["cmd"] and name == "w" and top == ["Koine"]:
        state["window"] = False
        drop(state, "Koine")
    elif modifiers == ["cmd"] and name == "q" and top == ["Koine"]:
        quit_koine(state)
    elif modifiers == ["cmd"] and name == "q" and top == ["System Settings"]:
        state["settings_app"] = False
        drop(state, "System Settings")
    elif state["consent"] and name in {"return", "g"}:
        state["consent"] += 1
        if state["consent"] >= 5:
            state["granted"] = True
    elif state["field_focus"] and modifiers == ["cmd"]:
        if name == "a":
            state["selected"] = True
        elif name == "c" and state["selected"]:
            state["clipboard"] = state["field"]
        elif name == "x" and state["selected"]:
            state["clipboard"], state["field"], state["selected"] = (
                state["field"],
                "",
                False,
            )
        elif name == "v":
            state["field"] = state["clipboard"]


def scroll(state: dict[str, Any], dy: int) -> None:
    if "scroll-ignored" in FLAGS:
        return
    visible = state["frame"][3] - 30
    state["offset"] = max(0, min(CONTENT_HEIGHT - visible, state["offset"] - 5 * dy))


def release(state: dict[str, Any], x: int, y: int) -> None:
    if "resize-ignored" in FLAGS:
        return
    left, top = state["frame"][:2]
    state["frame"][2] = max(440, x - left + 3)
    state["frame"][3] = max(352, y - top + 3)
    visible = state["frame"][3] - 30
    state["offset"] = max(0, min(CONTENT_HEIGHT - visible, state["offset"]))


def envelope(payload: dict[str, Any]) -> str:
    return json.dumps({"schema_version": "1.0", "ok": True, **payload})


def option(arguments: list[str], name: str) -> str:
    for index, argument in enumerate(arguments):
        if argument == name:
            return arguments[index + 1]
        if argument.startswith(name + "="):
            return argument.split("=", 1)[1]
    raise SystemExit(f"missing {name}: {arguments}")


def cli(state: dict[str, Any], arguments: list[str], root: Path) -> str:
    # PREDICATE -- COMMAND SUBCOMMAND ARGS, as the facades pass them.
    arguments = arguments[1:]
    if arguments[:1] == ["--"]:
        arguments = arguments[1:]
    family, action, rest = arguments[0], arguments[1], arguments[2:]
    vm = json.loads((root / "subject.json").read_text())["vm"]
    if (family, action) == ("vm", "list"):
        items = [
            {
                "name": "testanyware-golden-macos-27",
                "kind": "golden",
                "platform": "macos",
                "backend": "tart",
                "pid": None,
                "vnc": None,
                "agent": None,
            }
        ]
        if state["vm"] == "running":
            items.append(
                {
                    "name": vm,
                    "kind": "running",
                    "platform": "macos",
                    "backend": "tart",
                    "pid": 4242,
                    "vnc": "127.0.0.1:5901",
                    "agent": "127.0.0.1:8648",
                }
            )
        return envelope(
            {
                "items": items,
                "returned": len(items),
                "total": len(items),
                "truncated": False,
            }
        )
    if (family, action) == ("vm", "start"):
        state["vm"] = "running"
        endpoint = {"host": "127.0.0.1", "port": 8648}
        return envelope(
            {
                "id": vm,
                "platform": "macos",
                "base": option(rest, "--base"),
                "vnc": {"host": "127.0.0.1", "port": 5901},
                "agent": endpoint,
                "spec_path": "/tmp/spec.json",
                "meta_path": "/tmp/meta.json",
            }
        )
    if (family, action) == ("screen", "size"):
        return envelope({"width": 1920, "height": 1080})
    if (family, action) == ("screen", "find-text"):
        found = state["automation"] == "prompt"
        detections = (
            [
                {
                    "text": "Don't Allow" if "allow-substring" in FLAGS else "Allow",
                    "x": ALLOW[0],
                    "y": ALLOW[1],
                    "width": ALLOW[2],
                    "height": ALLOW[3],
                    "confidence": 0.9,
                }
            ]
            if found
            else []
        )
        return envelope(
            {
                "query": rest[0],
                "engine": "vision",
                "detections": detections,
                "returned": len(detections),
                "total": len(detections),
                "truncated": False,
            }
        )
    if (family, action) == ("agent", "windows"):
        entries = windows(state)
        if OPERATION == os.environ.get("settings_untitled_behind"):
            entries = finder_in_front(entries, untitled=True)
        elif OPERATION == os.environ.get("settings_finder_front"):
            entries = finder_in_front(entries, untitled=False)
        return envelope({"windows": entries})
    if (family, action) == ("agent", "snapshot"):
        target = option(rest, "--window")
        entries = []
        for entry in windows(state):
            if entry["appName"] == target or entry.get("title") == target:
                tree = (
                    koine_elements(state)
                    if entry["appName"] == "Koine"
                    else (
                        settings_elements(state)
                        if entry["appName"] == "System Settings"
                        else []
                    )
                )
                entries.append({**entry, "elements": tree})
        return envelope({"windows": entries})
    if family == "agent":
        target = option(rest, "--window")
        app = "Koine" if target in {TITLE, "Koine"} else target
        if action == "window-move":
            frame = state["frame"] if app == "Koine" else state["textedit_frame"]
            frame[0], frame[1] = int(option(rest, "--x")), int(option(rest, "--y"))
        elif action == "window-focus":
            if "focus-ignored" not in FLAGS:
                front(state, app)
        elif action == "window-close" and app == "Koine":
            if OPERATION == os.environ.get("settings_close_ignored"):
                return envelope({"action": action, "success": True, "message": None})
            # Closed while Koine is active, no window keeps the focus (k6).
            if state["order"][:1] == ["Koine"]:
                state["unfocused"] = True
            state["window"] = False
            state["closes"] += 1
            drop(state, "Koine")
        return envelope({"action": action, "success": True, "message": None})
    if family == "input":
        if action in {"click", "move", "mouse-down", "mouse-up"}:
            x, y = int(rest[0]), int(rest[1])
            if action == "click":
                click(state, x, y)
            elif action == "mouse-up":
                release(state, x, y)
            payload: dict[str, Any] = {"x": x, "y": y}
            if action == "click":
                payload.update(button="left", count=1)
            elif action != "move":
                payload["button"] = "left"
            return envelope(payload)
        if action == "key":
            modifiers = (
                option(rest, "--modifiers").split(",") if "--modifiers" in rest else []
            )
            key(state, rest[0], modifiers)
            return envelope({"key": rest[0], "modifiers": modifiers})
        if action == "type":
            if state["field_focus"] and not state["consent"]:
                state["field"] = rest[0]
            elif state["consent"]:
                state["consent"] += 1
            return envelope({"text": rest[0], "chars": len(rest[0])})
        if action == "scroll":
            dy = int(rest[2].split("=", 1)[1])
            scroll(state, dy)
            return envelope({"x": int(rest[0]), "y": int(rest[1]), "dx": 0, "dy": dy})
    raise SystemExit(f"unsimulated CLI command: {arguments}")


def descriptor(state: dict[str, Any]) -> dict[str, Any]:
    return {
        "contractVersion": "1.0",
        "descriptorVersion": 1,
        "instanceId": f"instance-{state['instance']}",
        "path": "/graphql",
        "pid": state["pid"],
        "port": 7650,
    }


def process(state: dict[str, Any]) -> dict[str, Any]:
    return {
        "pid": state["pid"],
        "start_sec": 2000 + state["instance"],
        "start_usec": 5,
        "executable": f"{INSTALLED}/Contents/MacOS/Koine",
    }


# The size of a closed menu, and the sizes that the guest showed for an open
# File menu and an open Koine menu (k5).
CLOSED_MENU = [0, 0]
OPEN_FILE_MENU = [269, 425]
OPEN_KOINE_MENU = [242, 93]


def koine_menu_sizes(state: dict[str, Any]) -> list[list[int]]:
    return [OPEN_KOINE_MENU if state["menu"] else CLOSED_MENU]


def sysevents(state: dict[str, Any], name: str, arguments: list[str]) -> dict[str, Any]:
    if name == "sysevents-processes":
        value: Any = (
            ["Finder", "Dock", "Koine"] if state["automation"] == "granted" else []
        )
    elif name == "menu-item-count":
        value = 1
    elif name == "menu-item-label":
        value = label(state)
    elif name == "menu-item-frame":
        if "item-frame-absent" in FLAGS:
            return {"absent": True, "error": -1719, "message": "Invalid index."}
        value = [[ITEM[0], ITEM[1]], [ITEM[2], ITEM[3]]]
    elif name == "menu-row-frame":
        frame = row_frame(state, arguments[0])
        if frame is None:
            return {"absent": True, "error": -1719, "message": "Invalid index."}
        value = frame
    elif name == "menu-titles":
        value = titles(state)
        if "menu-title-wrong" in FLAGS:
            value = [*value, "Unexpected"]
    elif name == "dock-items":
        value = ["Finder", "TextEdit"]
    elif name == "background-only":
        value = True
    elif name == "front-process":
        top = state["order"][0] if state["order"] else "Finder"
        pid = {"TextEdit": TEXTEDIT_PID, "Koine": state["pid"]}.get(top, 77)
        if top == "TextEdit" and before_return(state, "front-other-pid"):
            pid += 1
        value = [top, pid]
    elif name == "textedit-windows":
        value = [["AXStandardWindow"], [[]]]
        if before_return(state, "textedit-sheet"):
            value = [["AXStandardWindow"], [["AXSheet"]]]
        elif before_return(state, "textedit-dialog"):
            value = [["AXStandardWindow", "AXDialog"], [[], []]]
    elif name == "menu-bar-menu-sizes":
        # The sizes of the menus under each item. A setup flag opens the File
        # menu of TextEdit or Koine's menu for this read only.
        sizes = [[CLOSED_MENU] for _ in TEXTEDIT_MENUS]
        if before_return(state, "menu-open-at-setup"):
            sizes[2] = [OPEN_FILE_MENU]
        koine = koine_menu_sizes(state)
        if before_return(state, "koine-menu-open-at-setup"):
            koine = [OPEN_KOINE_MENU]
        value = [TEXTEDIT_MENUS, sizes, koine]
    elif name == "menu-row-enabled":
        value = not before_return(state, "row-disabled")
    elif name == "koine-menu-sizes":
        value = koine_menu_sizes(state)
    else:
        value = state["order"][0] if state["order"] else "Finder"
    record: dict[str, Any] = {"absent": False, "value": value}
    if name in {"menu-item-frame", "menu-row-frame"}:
        record["text"] = ", ".join(str(part) for pair in value for part in pair)
    return record


def read(state: dict[str, Any], name: str, arguments: list[str]) -> dict[str, Any]:
    fields: dict[str, Any]
    if name == "endpoint":
        fields = (
            {"present": True, "descriptor": descriptor(state)}
            if state["koine"] and "endpoint-absent" not in FLAGS
            else {"present": False}
        )
    elif name == "launch-identity":
        if not state["koine"]:
            fields = {"present": False, "joined": False}
        else:
            fields = {
                "present": True,
                "selected": [state["pid"]],
                "descriptor": descriptor(state),
                "process": process(state),
                "joined": True,
            }
    elif name == "process-identity":
        pid = int(arguments[0])
        alive = state["koine"] and pid == state["pid"]
        fields = {"pid": pid, "process": process(state) if alive else None}
    elif name == "process":
        live = state["textedit"] if arguments == ["textedit"] else state["koine"]
        pids = [TEXTEDIT_PID] if arguments == ["textedit"] else [state["pid"]]
        if arguments == ["textedit"] and "textedit-pids" in FLAGS:
            pids.append(TEXTEDIT_PID + 1)
        fields = {
            "selected": pids if live else [],
            "processes": [
                {
                    "pid": pid,
                    "started": "Sun Nov 22 10:00:00 2026",
                    "argv0": "/x",
                    "arguments": "/x",
                }
                for pid in pids
            ]
            if live
            else [],
        }
    elif name == "boot":
        sec, usec = state["boot"]
        fields = {"sec": sec, "usec": usec, "text": "Sun Nov 22 10:00:00 2026"}
    elif name == "port-refusal":
        fields = {"curl_exit": 0 if state["koine"] else 7}
    elif name == "defaults":
        disabled = "diagnostics-enabled" not in FLAGS
        fields = {"user": "admin", "sources": [], "diagnostics_disabled": disabled}
    elif name == "installed-inventory":
        fields = {
            "files": [{"path": "./Contents/Info.plist", "sha256": "a" * 64}],
            "symlinks": [
                {"path": "./Contents/Frameworks/link", "target": "Versions/A"}
            ],
        }
    elif name == "system":
        fields = {
            "product_version": "27.2.1",
            "product_version_extra": None,
            "build_version": "26B131",
            "arch": "arm64",
        }
    elif name == "gatekeeper":
        fields = {"assessments": "enabled"}
    elif name == "quarantine":
        fields = {"present": False}
    elif name == "signature":
        valid = "signature-invalid" not in FLAGS
        fields = {"valid": valid, "status": 0, "text": [f"{INSTALLED}: valid on disk"]}
    elif name == "signature-display":
        fields = {
            "authorities": ["Developer ID Application"],
            "shown": ["Identifier=dev.antony.Koine", "TeamIdentifier=TA43A4RUP3"],
            "text": [],
        }
    elif name == "assessment":
        fields = {"accepted": False, "status": 3, "text": [f"{INSTALLED}: rejected"]}
    elif name == "enrol":
        state["pending"] += 1
        fields = {"case": "enrol", "status": 200, "response": {"data": {}}}
    elif name in {
        "sysevents-processes",
        "menu-item-count",
        "menu-item-label",
        "menu-item-frame",
        "menu-row-frame",
        "menu-titles",
        "dock-items",
        "background-only",
        "front-application",
        "front-process",
        "textedit-windows",
        "menu-bar-menu-sizes",
        "menu-row-enabled",
        "koine-menu-sizes",
    }:
        fields = sysevents(state, name, arguments)
    else:
        fields = submission(state, name)
    return {"read": name, "arguments": arguments, **fields}


def submission(state: dict[str, Any], name: str) -> dict[str, Any]:
    if name == "open-koine":
        if state["koine"]:
            # The reopen of a running Koine shows its window, unless a control
            # asks for a reopen that shows none.
            if "reopen-no-window" not in FLAGS:
                show_koine(state)
        else:
            start_koine(
                state,
                window=not state["granted"] or "silent-launch-window" in FLAGS,
            )
    elif name == "open-textedit":
        state["textedit"] = True
        front(state, "TextEdit")
    elif name == "quit-textedit":
        state["textedit"] = False
        drop(state, "TextEdit")
    elif name == "request-automation":
        state["automation"] = "prompt"
    elif name == "open-accessibility-pane":
        state["settings_app"] = True
        front(state, "System Settings")
    elif name == "restart":
        quit_koine(state)
        if "boot-stuck" not in FLAGS:
            state["boot"] = [state["boot"][0] + 600, 2]
        if state["login"] and "login-not-started" not in FLAGS:
            start_koine(state, window=False)
    elif name != "extract-bundle":
        raise SystemExit(f"unsimulated read: {name}")
    return {"stdout": ""}


def holds(predicate: str, output: str) -> bool:
    """The real backend's test of a payload predicate, on the same envelope."""
    result = subprocess.run(
        ["jq", "-e", f"[({predicate})] == [true]"],
        input=output,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def latch(root: Path, reason: str) -> None:
    if not (root / "unavailable").exists():
        (root / "unavailable").write_text(reason + "\n")


def main() -> int:
    global OPERATION
    action, arguments = sys.argv[1], sys.argv[2:]
    if action == "init":
        root = Path(arguments[0])
        root.mkdir()
        (root / "subject.json").write_text(json.dumps({"vm": arguments[1]}))
        log({"action": "init", "root": str(root.absolute()), "vm": arguments[1]})
        return 0
    root = Path(arguments[0])
    entry: dict[str, Any] = {"action": action, "root": str(root.absolute())}
    if action in {"cli", "read", "capture", "upload", "download"}:
        kind, operation = arguments[1], arguments[2]
        entry.update(kind=kind, operation=operation, arguments=arguments[3:])
    elif action in {"fail", "poll-step"}:
        kind, operation = "evidence", arguments[1]
        entry.update(kind=kind, operation=operation, arguments=arguments[2:])
    elif action == "provenance":
        kind, operation = "read-poll", arguments[1]
        entry.update(kind=kind, operation=operation, arguments=arguments[2:])
    else:
        raise SystemExit(f"unsimulated backend action: {action}")
    if not (root / "subject.json").is_file():
        entry["outcome"] = "no-root"
        log(entry)
        return 125
    if action == "fail":
        latch(root, f"{operation}: {arguments[2]}")
        entry["outcome"] = "failed-confirmation"
        log(entry)
        return 125
    if action == "poll-step":
        phase, status = arguments[2], int(arguments[3])
        if operation == os.environ.get("settings_fault"):
            latch(root, f"{operation}: injected unavailable answer")
            entry["outcome"] = "unavailable"
            log(entry)
            return int(os.environ.get("settings_fault_status", "125"))
        if phase == "exhausted":
            latch(root, f"{operation}: state-failed")
            entry["outcome"] = "state-failed"
            log(entry)
            return 125
        if phase == "sleep" or status not in (0, 1):
            latch(root, f"{operation}: {phase} exit {status}")
            entry["outcome"] = "unavailable"
            log(entry)
            return status if 128 < status <= 192 else 125
        entry["outcome"] = "clean"
        log(entry)
        return 0
    if (root / "unavailable").exists() and kind != "evidence":
        entry["outcome"] = "refused"
        log(entry)
        return 125
    if operation == os.environ.get("settings_fault"):
        latch(root, f"{operation}: injected unavailable answer")
        entry["outcome"] = "unavailable"
        log(entry)
        return int(os.environ.get("settings_fault_status", "125"))
    if action == "provenance":
        # A host file read of the clone's spec. The facade tests own its checks.
        entry["outcome"] = "clean"
        log(entry)
        return 0
    OPERATION = operation
    state = load()
    if action == "cli":
        output = cli(state, arguments[3:], root)
        if arguments[5:7] == ["agent", "snapshot"] and not holds(arguments[3], output):
            latch(root, f"{operation}: command payload predicate did not yield true")
            entry["outcome"] = "unavailable"
            log(entry)
            return 125
    elif action == "read":
        output = json.dumps(read(state, arguments[3], arguments[4:]))
    elif action == "capture":
        output = envelope(
            {
                "path": str(root.absolute() / f"{operation}.png"),
                "width": 1920,
                "height": 1080,
            }
        )
    elif action == "upload":
        local, remote = arguments[3], arguments[4]
        output = envelope(
            {
                "local": str(Path(local).absolute()),
                "remote": remote,
                "bytes": Path(local).stat().st_size,
            }
        )
    else:
        raise SystemExit("the Settings scenario takes no download")
    save(state)
    if action == "read" and FLAGS & {"label-stuck", "menu-title-wrong"}:
        # A failure message of a label or menu read uses the newest read record.
        ordinal = (SIM / "calls.jsonl").read_text().count("\n") + 1
        attempt = root / f"{ordinal:06d}"
        attempt.mkdir()
        (attempt / "request.json").write_text(json.dumps({"operation": operation}))
        (attempt / "read.json").write_text(output)
    entry["outcome"] = "clean"
    log(entry)
    print(output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
