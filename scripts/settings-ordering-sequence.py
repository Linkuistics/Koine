#!/usr/bin/env python3
"""Hold the finite Settings ordering sequence.

The tool declares the five fixed slots, admits them in order and classifies the
receipts of each evidence root. It settles each slot and reports every slot that
did not run. Only the run verb starts a Task entry. That verb audits the frozen
inputs, collects the evidence of its slot and contains the exact clone. The
settle-run verb then takes the screenshot audit and settles the slot. The close
verb rechecks the stopped golden image. The protocol is
docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md.

Exit 0: the step completed. 2: invalid arguments. 3: the step was refused, and
the ledger did not change.
"""

# pyright: strict
from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import os
import re
import select
import shlex
import shutil
import signal
import stat
import subprocess
import sys
import time
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path
from types import FrameType
from typing import cast

BASE = "testanyware-golden-macos-27"
FOCUSED = "focused"
ORDINARY = "ordinary"
PREFIX_ENTRY = "app:vm-verify-menu-bar-prefix"
COMPLETE_ENTRY = "app:vm-verify-menu-bar"
# (slot, set, namespace, clone, entry), in the only admitted order.
SLOTS = (
    ("E01", FOCUSED, "ordering-evaluation", "koine-k49-ordering-e01", PREFIX_ENTRY),
    ("E02", FOCUSED, "ordering-evaluation", "koine-k49-ordering-e02", PREFIX_ENTRY),
    ("A01", ORDINARY, "ordering-ordinary", "koine-k49-ordinary-a01", COMPLETE_ENTRY),
    ("A02", ORDINARY, "ordering-ordinary", "koine-k49-ordinary-a02", COMPLETE_ENTRY),
    ("A03", ORDINARY, "ordering-ordinary", "koine-k49-ordinary-a03", COMPLETE_ENTRY),
)
SLOT_NAMES = tuple(slot[0] for slot in SLOTS)
# The last receipt of a complete run of each entry point.
TERMINAL = {FOCUSED: "textedit-quit-absence-state", ORDINARY: "installed-after"}
# Each menu return, with the operation of its selection.
MENU_RETURNS = {
    "first-selection": "first-selection",
    "reopen-1": "reopen-1-selection",
    "reopen-2": "reopen-2-selection",
    "reopen-3": "reopen-3-selection",
    "requests": "requests-selection",
    "accessibility": "accessibility-selection",
    "quit": "quit-selection",
}
RECURRENCE_CLASSES = {"zero-window-same-process", "multiple-windows", "not-front"}
ASSERTION = "scenario-assertion"
SIGNAL = "scenario-signal-"
# A restart poll that runs out is a test-driver or guest failure.
BOOT_EXHAUSTED = "restart-boot-exhausted"
RESULTS = {"passed", "failed", "unavailable", "not-run"}
RESULT_PHASES = (
    "collection",
    "subject",
    "environment",
    "endpoint",
    "audit",
    "stop",
    "inventory",
    "screenshots",
)
LEDGER_NAME = re.compile(r"([0-9]{6})-(ready|started|settled|held|closed)\.json")
ORDINAL_GAP = "the ordinals have a gap"
REPOSITORY = Path(__file__).resolve().parents[1]
LIFECYCLE = REPOSITORY / "scripts" / "vm-lifecycle-evidence-lib.sh"
CONTAINMENT = "containment"
STOP_OPERATION = "containment-stop"
INVENTORY_OPERATION = "containment-inventory"
EXEC_READS = REPOSITORY / "scripts" / "vm-exec-read-evidence-lib.sh"
# The caller's own guest reads. They run after the class freezes and before the
# stop. The prefix has no process read while Koine runs, so G5 needs this one.
INSTALLED_BEFORE = "installed-before"
INSTALLED_READ = "audit-installed-after"
DEFAULTS_READ = "audit-defaults-after"
PROCESS_READ = "audit-process-after"
AWAITING = "awaiting-screenshot-audit"
SHA256 = re.compile(r"[0-9a-f]{64}")
SYSTEM_FIELDS = ("product_version", "product_version_extra", "build_version", "arch")
# The files that a clean attempt of each transport always holds. The backend
# writes them before its clean result, in run_locked of scripts/vm-guest-exec.py.
CLI_MEMBERS = ("raw.stdout", "raw.stderr", "cli.exit")
PAYLOAD_MEMBERS = ("payload.stdout", "payload.stderr")
REQUIRED_MEMBERS: dict[str, tuple[str, ...]] = {
    "exec": (*CLI_MEMBERS, *PAYLOAD_MEMBERS, "guest.stdout", "guest.stderr"),
    "read": (*CLI_MEMBERS, "guest.stdout", "guest.stderr", "read.json"),
    "cli": (*CLI_MEMBERS, *PAYLOAD_MEMBERS),
    "capture": (*CLI_MEMBERS, *PAYLOAD_MEMBERS, "artifact.json", "screen.png"),
    "upload": (
        *CLI_MEMBERS,
        *PAYLOAD_MEMBERS,
        "local-before.json",
        "local-after.json",
        "transfer.json",
    ),
    "download": (*CLI_MEMBERS, *PAYLOAD_MEMBERS, "transfer.json", "download.bin"),
    "poll-step": (),
    "confirmation": (),
}
ITEM_FIELDS = {
    "file": {"path", "kind", "bytes", "sha256"},
    "symlink": {"path", "kind", "target"},
    "directory": {"path", "kind"},
}
# Each request would change what the protocol declares, so a run refuses it.
OVERRIDES = ("KOINE_VM_KEEP", "KOINE_VM_DISPLAY", "KOINE_SETTINGS_TRACE")
# Seconds. The tagged `vm stop` runs `tart stop` with no bound of its own:
# https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/tart.rs
DEFAULT_BOUNDS = {
    "holder": 30.0,
    "term": 10.0,
    "kill": 5.0,
    "stop": 180.0,
    "inventory": 60.0,
    "audit": 120.0,
}
# The child waits here until the caller has recorded its process group.
GATE = 'IFS= read -r go && [ "$go" = start ] || exit 125; exec </dev/null; exec "$@"'

Json = dict[str, object]
# One guest read: its parsed record, when it is clean, and its result.
GuestRead = tuple[Json | None, Json]


class Refusal(Exception):
    """A step that the sequence does not admit."""


def timestamp() -> str:
    return datetime.now(UTC).isoformat()


def unique_object(pairs: list[tuple[str, object]]) -> Json:
    result: Json = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON field: {key}")
        result[key] = value
    return result


def reject_constant(value: str) -> object:
    raise ValueError(f"non-JSON numeric constant: {value}")


def read_object(path: Path) -> Json:
    value: object = json.loads(
        path.read_bytes(),
        object_pairs_hook=unique_object,
        parse_constant=reject_constant,
    )
    if not isinstance(value, dict):
        raise ValueError(f"{path.name} is not one JSON object")  # noqa: TRY004
    return cast(Json, value)


def write_exclusive(path: Path, value: object) -> None:
    """Publish one complete file, and never replace an existing one."""
    partial = path.with_name(path.name + ".partial")
    with partial.open("x") as stream:
        json.dump(value, stream, indent=2, ensure_ascii=True)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.link(partial, path)
    partial.unlink()


# --- the declaration ---------------------------------------------------------


def declaration(directory: Path) -> Json:
    slots: list[Json] = []
    for slot, slot_set, namespace, clone, entry in SLOTS:
        output = directory / namespace / slot
        slots.append(
            {
                "slot": slot,
                "set": slot_set,
                "namespace": namespace,
                "clone": clone,
                "entry": entry,
                "output": str(output),
                "evidence_root": str(output / "evidence"),
            }
        )
    return {"schema": 1, "base": BASE, "slots": slots}


def declare(directory: Path) -> int:
    absolute = directory.absolute()
    try:
        absolute.mkdir(mode=0o700)
    except FileExistsError as error:
        raise Refusal(f"the sequence directory already exists: {absolute}") from error
    # The roots can hold KOINE_VM_PASSWORD, so only the owner can enter.
    os.chmod(absolute, 0o700)
    resolved = absolute.resolve()
    (resolved / "ledger").mkdir(mode=0o700)
    value = declaration(resolved)
    for namespace in {slot[2] for slot in SLOTS}:
        (resolved / namespace).mkdir(mode=0o700)
    for slot, _, namespace, _, _ in SLOTS:
        (resolved / namespace / slot).mkdir(mode=0o700)
    write_exclusive(resolved / "sequence.json", value)
    print(json.dumps(value, indent=2))
    return 0


# --- the ledger --------------------------------------------------------------


class Sequence:
    """The sequence state, rebuilt by replaying the ledger through its rules."""

    def __init__(self, directory: Path) -> None:
        self.directory = directory
        self.ready: dict[str, Json] = {}
        self.started: dict[str, Json] = {}
        self.settled: dict[str, Json] = {}
        self.held: Json | None = None
        self.closed: Json | None = None
        self.count = 0
        self.slots: dict[str, Json] = {}
        try:
            declared = read_object(directory / "sequence.json")
        except (OSError, ValueError) as error:
            raise Refusal(f"the declaration is unreadable: {error}") from error
        if declared != declaration(directory):
            raise Refusal("the declaration differs from the fixed sequence")
        for slot in cast(list[Json], declared["slots"]):
            self.slots[cast(str, slot["slot"])] = slot
        self._replay()

    def _replay(self) -> None:
        ledger = self.directory / "ledger"
        try:
            names = sorted(path.name for path in ledger.iterdir())
        except OSError as error:
            raise Refusal(f"the ledger is unreadable: {error}") from error
        for index, name in enumerate(names, 1):
            match = LEDGER_NAME.fullmatch(name)
            if match is None or int(match[1]) != index:
                raise Refusal(f"the ledger holds an unexpected entry: {name}")
            try:
                record = read_object(ledger / name)
                if record.get("ordinal") != index or record.get("event") != match[2]:
                    raise ValueError("its ordinal or event differs from its name")
                self._apply(record)
            except (ValueError, KeyError, TypeError, Refusal) as error:
                raise Refusal(f"the ledger entry {name} is invalid: {error}") from error
            self.count = index

    def _apply(self, record: Json) -> None:
        event = record["event"]
        if event == "ready":
            slot_set = cast(str, record["set"])
            self.check_ready(slot_set)
            self.ready[slot_set] = record
        elif event == "started":
            slot = cast(str, record["slot"])
            self.check_admit(slot)
            self.started[slot] = record
        elif event == "held":
            self.check_admit(cast(str, record["slot"]))
            self.held = record
        elif event == "closed":
            self.check_close()
            self.closed = record
        else:
            slot = cast(str, record["slot"])
            self.check_settle(slot)
            # A settled entry must follow from its own recorded inputs.
            phases = cast(Json, record["phases"])
            validate_phases(phases)
            decided = decide(cast(Json, record["classification"]), phases)
            if decided != (record["disposition"], record["conflicts"]):
                raise Refusal("its disposition does not follow from its inputs")
            self.settled[slot] = record

    def stopped(self) -> str | None:
        if self.held is not None:
            return cast(str, self.held["slot"])
        for slot in SLOT_NAMES:
            record = self.settled.get(slot)
            if record is not None and record.get("disposition") != "qualified":
                return slot
        return None

    def check_ready(self, slot_set: str) -> None:
        if slot_set not in {FOCUSED, ORDINARY}:
            raise Refusal(f"unknown set: {slot_set}")
        if slot_set in self.ready:
            raise Refusal(f"the {slot_set} set is already ready")
        stopped = self.stopped()
        if stopped is not None:
            raise Refusal(f"the sequence stopped at {stopped}")
        if slot_set == ORDINARY and not all(
            self.settled.get(slot, {}).get("disposition") == "qualified"
            for slot in ("E01", "E02")
        ):
            raise Refusal("the ordinary set needs both focused slots qualified")

    def check_admit(self, slot: str) -> None:
        stopped = self.stopped()
        if stopped is not None:
            raise Refusal(f"the sequence stopped at {stopped}")
        for name in SLOT_NAMES:
            if name in self.started and name not in self.settled:
                raise Refusal(f"{name} is unsettled")
        expected = next((n for n in SLOT_NAMES if n not in self.started), None)
        if expected is None:
            raise Refusal("no slot remains")
        if slot != expected:
            raise Refusal(f"the next slot is {expected}, not {slot}")
        slot_set = cast(str, self.slots[slot]["set"])
        if slot_set not in self.ready:
            raise Refusal(f"the {slot_set} set is not ready")

    def check_settle(self, slot: str) -> None:
        if slot not in self.started or slot in self.settled:
            raise Refusal(f"{slot} is not awaiting settlement")

    def check_close(self) -> None:
        if self.closed is not None:
            raise Refusal("the sequence is already closed")
        if FOCUSED not in self.ready:
            raise Refusal("the focused set is not ready")
        for name in SLOT_NAMES:
            if name in self.started and name not in self.settled:
                raise Refusal(f"{name} is unsettled")
        if self.stopped() is None and len(self.settled) != len(SLOT_NAMES):
            raise Refusal("the sequence is not over")

    def append(self, event: str, fields: Json) -> Json:
        ordinal = self.count + 1
        record: Json = {"ordinal": ordinal, "event": event, "at": timestamp(), **fields}
        write_exclusive(
            self.directory / "ledger" / f"{ordinal:06d}-{event}.json", record
        )
        self._apply(record)
        self.count = ordinal
        return record


def with_writer(directory: Path, action: str, step: Callable[[Sequence], Json]) -> Json:
    """Run one step as the only writer. A contender is refused and recorded."""
    resolved = directory.absolute().resolve()
    if not (resolved / "sequence.json").is_file():
        raise Refusal(f"no declared sequence at {resolved}")
    with (resolved / ".writer").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            record_refusal(resolved, action, "competing sequence writer")
            raise Refusal("competing sequence writer") from None
        try:
            return step(Sequence(resolved))
        except Refusal as error:
            record_refusal(resolved, action, str(error))
            raise
        except OSError as error:
            reason = f"the step could not read or write its files: {error}"
            record_refusal(resolved, action, reason)
            raise Refusal(reason) from error


def record_refusal(directory: Path, action: str, reason: str) -> None:
    line = json.dumps({"at": timestamp(), "action": action, "reason": reason}) + "\n"
    with (directory / "refusals.jsonl").open("ab", buffering=0) as stream:
        stream.write(line.encode("ascii"))
        os.fsync(stream.fileno())


# --- readiness and admission -------------------------------------------------


def digest_regular(path: Path) -> Json:
    descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(descriptor, "rb") as stream:
        status = os.fstat(stream.fileno())
        if not stat.S_ISREG(status.st_mode):
            raise ValueError("not a regular file")
        digest = hashlib.sha256()
        size = 0
        while block := stream.read(1 << 20):
            digest.update(block)
            size += len(block)
    return {"path": str(path.absolute()), "bytes": size, "sha256": digest.hexdigest()}


def ready(directory: Path, slot_set: str, receipt: Path) -> int:
    def step(sequence: Sequence) -> Json:
        sequence.check_ready(slot_set)
        try:
            identity = digest_regular(receipt)
        except (OSError, ValueError) as error:
            raise Refusal(f"the readiness receipt is unreadable: {error}") from error
        return sequence.append("ready", {"set": slot_set, "receipt": identity})

    print(json.dumps(with_writer(directory, "ready", step), indent=2))
    return 0


def admit_slot(directory: Path, slot: str) -> Json:
    """Consume the slot. The caller invokes its clone start immediately after."""

    def step(sequence: Sequence) -> Json:
        sequence.check_admit(slot)
        declared = sequence.slots[slot]
        output = Path(cast(str, declared["output"]))
        if Path(cast(str, declared["evidence_root"])).exists():
            raise Refusal(f"the evidence root of {slot} already exists")
        try:
            used = any(output.iterdir())
        except OSError as error:
            raise Refusal(
                f"the output directory of {slot} is unreadable: {error}"
            ) from error
        if used:
            raise Refusal(f"the output directory of {slot} is not empty")
        sequence.append("started", {"slot": slot, "clone": declared["clone"]})
        return declared

    return with_writer(directory, "admit", step)


def admit(directory: Path, slot: str) -> int:
    print(json.dumps(admit_slot(directory, slot), indent=2))
    return 0


# --- classification ----------------------------------------------------------


def read_attempts(root: Path) -> tuple[list[Json], list[str]]:
    """The ordered attempts. A missing or invalid receipt is an unfinished one."""
    attempts: list[Json] = []
    unfinished: list[str] = []
    names = sorted(p.name for p in root.iterdir() if re.fullmatch(r"[0-9]{6}", p.name))
    for index, name in enumerate(names, 1):
        if int(name) != index:
            unfinished.append(f"{name}: {ORDINAL_GAP}")
        operation: object = None
        outcome: object = "partial"
        try:
            operation = read_object(root / name / "request.json")["operation"]
            outcome = read_object(root / name / "result.json")["outcome"]
            if outcome not in {"clean", "state-failed", "unavailable", "interrupted"}:
                raise ValueError(f"unknown outcome {outcome}")
        except (OSError, ValueError, KeyError) as error:
            outcome = "partial"
            unfinished.append(f"{name}: {error}")
        attempts.append({"ordinal": name, "operation": operation, "outcome": outcome})
    return attempts, unfinished


def pointer_state(attempts: list[Json]) -> str:
    """None, held, released or uncertain, from the held-point receipts only."""
    state = "none"
    for attempt in attempts:
        operation = attempt["operation"]
        if not isinstance(operation, str):
            # An unreadable request could be a held point or a release.
            state = "uncertain"
            continue
        if not (operation.startswith("resize-down-") or operation == "resize-release"):
            continue
        if attempt["outcome"] != "clean":
            state = "uncertain"
        elif state != "uncertain":
            state = "released" if operation == "resize-release" else "held"
    return state


def refused_signals(root: Path) -> list[str]:
    """Signals whose record met a held lock and became a backend refusal."""
    path = root / "refusals.jsonl"
    if not path.exists():
        return []
    signals: list[str] = []
    for line in path.read_bytes().splitlines():
        try:
            record: object = json.loads(line)
        except ValueError:
            continue  # A truncated record still counts as a refusal.
        if not isinstance(record, dict):
            continue
        arguments = cast(Json, record).get("arguments")
        if not isinstance(arguments, list) or len(cast(list[object], arguments)) < 3:
            continue
        action, operation = (
            cast(list[object], arguments)[0],
            cast(list[object], arguments)[2],
        )
        if (
            action == "fail"
            and isinstance(operation, str)
            and operation.startswith(SIGNAL)
        ):
            signals.append(operation.removeprefix(SIGNAL))
    return signals


def is_supplemental(operation: object) -> bool:
    """The failure observer, window list and screenshot supplement a failure."""
    return isinstance(operation, str) and (
        operation == "failure-capture"
        or operation.endswith(("-front-application", "-failure-windows"))
    )


def find_clean(attempts: list[Json], operation: str, start: int = 0) -> int | None:
    for index in range(start, len(attempts)):
        if (
            attempts[index]["operation"] == operation
            and attempts[index]["outcome"] == "clean"
        ):
            return index
    return None


def recurrence_blockers(
    before: list[Json], class_name: str
) -> tuple[str | None, list[str]]:
    """What stops this classified failure from being a recurrence candidate."""
    returned: str | None = None
    for attempt in reversed(before):
        operation = attempt["operation"]
        if isinstance(operation, str) and operation.endswith("-failure-windows"):
            returned = operation.removesuffix("-failure-windows")
            break
    if returned is None or returned not in MENU_RETURNS:
        return returned, [f"the failure is not at a menu return: {returned}"]
    selection = MENU_RETURNS[returned]
    exhausted = f"{returned}-window-exhausted"
    blockers = [
        f"{attempt['operation']} is {attempt['outcome']}"
        for attempt in before
        if attempt["outcome"] != "clean"
        and not (
            attempt["operation"] == exhausted and attempt["outcome"] == "state-failed"
        )
    ]
    enabled = find_clean(before, f"{selection}-enabled")
    required = [
        f"{selection}-identity",
        f"{selection}-enabled",
        f"screenshot-menu-{selection}",
        f"{returned}-front-application",
        f"{returned}-failure-windows",
        "failure-capture",
        f"{returned}-menu-closed",
    ]
    if class_name == "zero-window-same-process":
        required.append(f"{returned}-liveness")
    if class_name == "not-front":
        required += [f"{returned}-front-state", f"{returned}-front-title-state"]
    blockers += [
        f"no clean {operation} receipt"
        for operation in required
        if find_clean(before, operation) is None
    ]
    if class_name != "not-front" and not any(
        a["operation"] == exhausted and a["outcome"] == "state-failed" for a in before
    ):
        blockers.append(f"no {exhausted} receipt")
    clicks = (
        [
            a
            for a in before[enabled + 1 :]
            if a["operation"] == "menu-click" and a["outcome"] == "clean"
        ]
        if enabled is not None
        else []
    )
    if len(clicks) != 1:
        blockers.append(
            f"expected one clean row click after the enabled read, saw {len(clicks)}"
        )
    return returned, blockers


def classify_root(root: Path, slot_set: str, clone: str) -> Json:
    result: Json = {
        "kind": "no-root",
        "class": None,
        "return": None,
        "blockers": [],
        "first_failure": None,
        "signals": [],
        "exhausted": [],
        "supplemental_failures": [],
        "unfinished": [],
        "latch": None,
        "refusals": 0,
        "facade_refusals": 0,
        "pointer": "none",
        "attempts": 0,
    }
    try:
        subject = read_object(root / "subject.json")
    except (OSError, ValueError) as error:
        result["unfinished"] = [f"subject: {error}"]
        return result
    try:
        attempts, unfinished = read_attempts(root)
        latch_path = root / "unavailable"
        result["latch"] = (
            latch_path.read_text(errors="replace").strip()
            if latch_path.exists()
            else None
        )
        for key, name in (
            ("refusals", "refusals.jsonl"),
            ("facade_refusals", "facade-refusals.log"),
        ):
            path = root / name
            result[key] = len(path.read_bytes().splitlines()) if path.exists() else 0
        refused = refused_signals(root)
    except OSError as error:
        result["kind"] = "unavailable"
        result["unfinished"] = [f"root: {error}"]
        result["pointer"] = "uncertain"
        return result
    result["attempts"] = len(attempts)
    result["unfinished"] = unfinished
    # A missing receipt could be a held point or a release.
    result["pointer"] = (
        "uncertain"
        if any(ORDINAL_GAP in entry for entry in unfinished)
        else pointer_state(attempts)
    )
    signals = [
        a["operation"].removeprefix(SIGNAL)
        for a in attempts
        if isinstance(a["operation"], str) and a["operation"].startswith(SIGNAL)
    ] + refused
    result["signals"] = signals
    result["exhausted"] = [
        a["operation"]
        for a in attempts
        if a["outcome"] == "state-failed"
        and isinstance(a["operation"], str)
        and not a["operation"].startswith(ASSERTION)
    ]
    result["supplemental_failures"] = [
        a["operation"]
        for a in attempts
        if a["outcome"] != "clean" and is_supplemental(a["operation"])
    ]
    failures = [a for a in attempts if a["outcome"] != "clean"]
    result["first_failure"] = failures[0] if failures else None
    if subject.get("vm") != clone:
        result["kind"] = "unavailable"
        result["blockers"] = [f"the root belongs to {subject.get('vm')}, not {clone}"]
        return result
    classified = [
        index
        for index, attempt in enumerate(attempts)
        if attempt["outcome"] == "state-failed"
        and isinstance(attempt["operation"], str)
        and (
            attempt["operation"] == ASSERTION
            or attempt["operation"].startswith(f"{ASSERTION}-")
        )
    ]
    if len(classified) > 1:
        result["kind"] = "unavailable"
        result["blockers"] = ["more than one classified assertion receipt"]
        return result
    if classified:
        # Receipts after the class are retained, and they cannot erase it.
        index = classified[0]
        name = (
            cast(str, attempts[index]["operation"]).removeprefix(ASSERTION).lstrip("-")
        )
        class_name = name or "assertion"
        result["class"] = class_name
        if class_name == "menu-open":
            result["kind"] = "unresolved-outcome"
        elif class_name in RECURRENCE_CLASSES:
            returned, blockers = recurrence_blockers(attempts[:index], class_name)
            # A gap or partial at or before the class can hide a failed attempt.
            # One after the class is retained and cannot erase the candidate.
            ordinal = cast(str, attempts[index]["ordinal"])
            blockers += [entry for entry in unfinished if entry[:6] <= ordinal]
            result["return"] = returned
            result["blockers"] = blockers
            if not blockers:
                result["kind"] = "recurrence-candidate"
            elif returned in MENU_RETURNS:
                result["kind"] = "unresolved-outcome"
            else:
                result["kind"] = "assertion-failed"
        else:
            result["kind"] = "assertion-failed"
        return result
    essential = [a for a in failures if not is_supplemental(a["operation"])]
    if essential:
        first = essential[0]
        operation = first["operation"]
        if first["outcome"] == "interrupted" or (
            isinstance(operation, str) and operation.startswith(SIGNAL)
        ):
            # A local wait can end by a signal and leave no signal record.
            result["kind"] = "interrupted"
        elif first["outcome"] != "state-failed":
            result["kind"] = "interrupted" if signals else "unavailable"
        elif operation == BOOT_EXHAUSTED:
            result["kind"] = "test-driver"
        elif isinstance(operation, str) and any(
            operation == f"{name}-window-exhausted"
            for name in (*MENU_RETURNS, "reopen")
        ):
            # A return's deferred exhaustion with no class has no settled outcome.
            result["kind"] = "unresolved-outcome"
        else:
            result["kind"] = "assertion-failed"
        return result
    if signals:
        result["kind"] = "interrupted"
    elif (
        failures
        or unfinished
        or result["latch"]
        or result["refusals"]
        or result["facade_refusals"]
    ):
        result["kind"] = "unavailable"
    elif attempts and attempts[-1]["operation"] == TERMINAL[slot_set]:
        result["kind"] = "complete"
    else:
        result["kind"] = "incomplete"
    return result


def classify(root: Path, slot_set: str, clone: str) -> int:
    print(json.dumps(classify_root(root.absolute(), slot_set, clone), indent=2))
    return 0


# --- settlement --------------------------------------------------------------


def valid_status(value: object) -> bool:
    return value is None or (type(value) is int and 0 <= value <= 255)


def read_phases(path: Path) -> Json:
    try:
        phases = read_object(path)
    except (OSError, ValueError) as error:
        raise Refusal(f"the phases are unreadable: {error}") from error
    validate_phases(phases)
    return phases


def validate_phases(phases: Json) -> None:
    if set(phases) != {"scenario", "task", *RESULT_PHASES}:
        raise Refusal("the phases need exactly the declared keys")
    for name in ("scenario", "task"):
        phase = phases[name]
        if (
            not isinstance(phase, dict)
            or set(cast(Json, phase)) != {"status"}
            or not valid_status(cast(Json, phase)["status"])
        ):
            raise Refusal(f"the phases hold an invalid {name} status")
    for name in RESULT_PHASES:
        phase = phases[name]
        if (
            not isinstance(phase, dict)
            or set(cast(Json, phase)) != {"result", "detail"}
            or cast(Json, phase)["result"] not in RESULTS
            or not isinstance(cast(Json, phase)["detail"], str)
        ):
            raise Refusal(f"the phases hold an invalid {name} result")


def phase_status(phases: Json, name: str) -> object:
    return cast(Json, phases[name])["status"]


def phase_result(phases: Json, name: str) -> object:
    return cast(Json, phases[name])["result"]


def decide(classification: Json, phases: Json) -> tuple[str, list[str]]:
    """The disposition, by the protocol's precedence, and any status conflict."""
    kind = classification["kind"]
    scenario = phase_status(phases, "scenario")
    conflicts: list[str] = []
    if kind in {"recurrence-candidate", "assertion-failed"}:
        # A classified assertion exits 1. An exhausted facade poll has no class,
        # and it keeps the status 125 of its state-failed receipt.
        expected = 1 if classification["class"] is not None else 125
        if scenario != expected:
            conflicts.append(
                f"a failed assertion with scenario status {scenario}, not {expected}"
            )
    if kind == "complete" and scenario != 0:
        conflicts.append(f"a complete run with scenario status {scenario}")
    if conflicts:
        return "unresolved", conflicts
    if kind == "recurrence-candidate":
        # A recurrence needs the admitted subject and setup before its selection.
        # A later failed collection or cleanup cannot erase the rejection.
        corroborated = all(
            phase_result(phases, name) == "passed"
            for name in ("subject", "screenshots")
        )
        return ("rejected" if corroborated else "unresolved"), conflicts
    if kind == "assertion-failed":
        return "failed", conflicts
    if (
        kind == "complete"
        and classification["pointer"] in {"none", "released"}
        and phase_status(phases, "task") == 0
        and all(phase_result(phases, name) == "passed" for name in RESULT_PHASES)
    ):
        return "qualified", conflicts
    return "unresolved", conflicts


def cleanup_state(phases: Json) -> str:
    """Confirmed, not requested (no start and a clean absence) or unresolved."""
    stop, inventory = phase_result(phases, "stop"), phase_result(phases, "inventory")
    if inventory == "passed" and stop == "passed":
        return "confirmed"
    if inventory == "passed" and stop == "not-run":
        return "not-requested"
    return "unresolved"


def record_settlement(
    sequence: Sequence, slot: str, phases: Json, classification: Json
) -> Json:
    disposition, conflicts = decide(classification, phases)
    return sequence.append(
        "settled",
        {
            "slot": slot,
            "disposition": disposition,
            "cleanup": cleanup_state(phases),
            "conflicts": conflicts,
            "classification": classification,
            "phases": phases,
        },
    )


def run_is_live(directory: Path) -> bool:
    try:
        descriptor = os.open(directory / ".runner", os.O_RDONLY | os.O_NOFOLLOW)
    except FileNotFoundError:
        return False
    try:
        fcntl.flock(descriptor, fcntl.LOCK_SH | fcntl.LOCK_NB)
    except BlockingIOError:
        return True
    finally:
        os.close(descriptor)
    return False


def settled_classification(declared: Json) -> Json:
    """The class that a run froze before containment wrote to the root."""
    frozen = Path(cast(str, declared["output"])) / CONTAINMENT / "classification.json"
    if frozen.exists():
        try:
            return read_object(frozen)
        except (OSError, ValueError) as error:
            raise Refusal(
                f"the frozen classification is unreadable: {error}"
            ) from error
    return classify_root(
        Path(cast(str, declared["evidence_root"])),
        cast(str, declared["set"]),
        cast(str, declared["clone"]),
    )


def recovery_phases(output: Path) -> Json:
    """The phases of a run that ended before it collected them.

    Only the strict scenario status can survive. No audit, stop or inventory
    result exists, so this route cannot qualify a slot or confirm its cleanup.
    """
    status, state = read_scenario_exit(output / "scenario.exit")
    missing = phase(
        "unavailable", f"the caller ended before this phase (scenario file {state})"
    )
    return {
        "scenario": {"status": status},
        "task": {"status": None},
        **dict.fromkeys(RESULT_PHASES, missing),
    }


def settle(directory: Path, slot: str) -> int:
    """Close a slot whose caller ended before it wrote its collected phases."""

    def step(sequence: Sequence) -> Json:
        sequence.check_settle(slot)
        if run_is_live(sequence.directory):
            raise Refusal(f"a live run owns {slot}")
        output = Path(cast(str, sequence.slots[slot]["output"]))
        if (output / CONTAINMENT / "phases.json").exists():
            raise Refusal(f"{slot} has collected phases, so use settle-run")
        phases = recovery_phases(output)
        return record_settlement(
            sequence, slot, phases, settled_classification(sequence.slots[slot])
        )

    print(json.dumps(with_writer(directory, "settle", step), indent=2))
    return 0


# --- the audits --------------------------------------------------------------


def scan_entry(path: Path, relative: str) -> Json:
    mode = path.lstat().st_mode
    if stat.S_ISLNK(mode):
        return {"path": relative, "kind": "symlink", "target": os.readlink(path)}
    if stat.S_ISREG(mode):
        digest = digest_regular(path)
        return {
            "path": relative,
            "kind": "file",
            "bytes": digest["bytes"],
            "sha256": digest["sha256"],
        }
    if stat.S_ISDIR(mode):
        return {"path": relative, "kind": "directory"}
    return {"path": relative, "kind": "special"}


def scan_tree(root: Path) -> tuple[list[Json], list[Json]]:
    """Each item under the root, by relative path. A failed read stays named."""
    items: list[Json] = []
    errors: list[Json] = []

    def add(path: Path, relative: str) -> None:
        try:
            items.append(scan_entry(path, relative))
        except (OSError, ValueError) as error:
            errors.append({"path": relative, "error": str(error)})

    def failed(error: OSError) -> None:
        relative = os.path.relpath(cast(str, error.filename), root)
        errors.append({"path": relative, "error": str(error)})

    try:
        mode = root.lstat().st_mode
    except FileNotFoundError:
        return [], []
    except OSError as error:
        return [], [{"path": ".", "error": str(error)}]
    if not stat.S_ISDIR(mode):
        add(root, ".")
        return items, errors
    for current, directories, files in os.walk(root, onerror=failed):
        for name in [*directories, *files]:
            entry = Path(current) / name
            add(entry, str(entry.relative_to(root)))
    items.sort(key=lambda item: cast(str, item["path"]))
    return items, errors


def compare_items(expected: list[Json], observed: list[Json]) -> Json:
    """Compare by path and identity. Equal counts prove nothing here."""
    wanted = {cast(str, item["path"]): item for item in expected}
    seen = {cast(str, item["path"]): item for item in observed}
    return {
        "missing": sorted(wanted.keys() - seen.keys()),
        "extra": sorted(seen.keys() - wanted.keys()),
        "changed": sorted(
            path for path in wanted.keys() & seen.keys() if wanted[path] != seen[path]
        ),
    }


def comparison_result(comparison: Json, errors: list[Json]) -> str:
    """A clean difference is a failure. A failed read alone is unavailable."""
    if any(comparison[key] for key in ("missing", "extra", "changed")):
        return "failed"
    return "unavailable" if errors else "passed"


def audit_tree(tree: Json) -> Json:
    items, errors = scan_tree(Path(cast(str, tree["root"])))
    comparison = compare_items(cast(list[Json], tree["items"]), items)
    # An item that could not be read is unavailable. It is not a missing item.
    unread = [cast(str, error["path"]) for error in errors]
    comparison["missing"] = [
        path
        for path in cast(list[str], comparison["missing"])
        if not any(
            name == "." or path == name or path.startswith(f"{name}/")
            for name in unread
        )
    ]
    return {
        "name": tree["name"],
        "root": tree["root"],
        "result": comparison_result(comparison, errors),
        **comparison,
        "errors": errors,
    }


def combined(results: list[tuple[str, object]]) -> Json:
    """The worst named result: failed, then unavailable, then not-run."""
    for wanted in ("failed", "unavailable", "not-run"):
        names = [name for name, result in results if result == wanted]
        if names:
            return phase(wanted, f"{wanted}: {', '.join(names)}")
    return phase("passed", f"passed: {', '.join(name for name, _ in results)}")


def valid_item(value: object) -> bool:
    if not isinstance(value, dict):
        return False
    item = cast(Json, value)
    fields = ITEM_FIELDS.get(cast(str, item.get("kind")))
    path = item.get("path")
    if fields is None or set(item) != fields or not isinstance(path, str):
        return False
    parts = path.split("/")
    if path != "." and ("" in parts or "." in parts or ".." in parts):
        return False
    if item["kind"] == "file":
        size, digest = item["bytes"], item["sha256"]
        return (
            type(size) is int
            and size >= 0
            and isinstance(digest, str)
            and SHA256.fullmatch(digest) is not None
        )
    if item["kind"] == "symlink":
        return isinstance(item["target"], str) and item["target"] != ""
    return True


def valid_tree(value: object) -> bool:
    if not isinstance(value, dict):
        return False
    tree = cast(Json, value)
    if set(tree) != {"name", "root", "items"}:
        return False
    name, root, items = tree["name"], tree["root"], tree["items"]
    if not (isinstance(name, str) and name and isinstance(root, str)):
        return False
    if not (Path(root).is_absolute() and isinstance(items, list) and items):
        return False
    entries = cast(list[object], items)
    if not all(valid_item(entry) for entry in entries):
        return False
    paths = [cast(Json, entry)["path"] for entry in entries]
    return len({cast(str, path) for path in paths}) == len(paths)


def frozen_problem(value: Json, slot_set: str) -> str | None:
    """Why this value is not the frozen declaration of the set, if it is not."""
    if set(value) != {
        "schema",
        "set",
        "environment",
        "process_arguments",
        "inputs",
        "golden",
    }:
        return "it needs exactly the declared fields"
    if value["schema"] != 1 or value["set"] != slot_set:
        return f"it needs schema 1 and the set {slot_set}"
    environment = value["environment"]
    if not isinstance(environment, dict) or set(cast(Json, environment)) != {
        *SYSTEM_FIELDS,
        "assessments",
    }:
        return "its environment needs exactly the declared fields"
    declared = cast(Json, environment)
    for name in ("product_version", "build_version", "arch"):
        if not isinstance(declared[name], str) or not declared[name]:
            return f"its environment needs {name}"
    extra = declared["product_version_extra"]
    if extra is not None and not isinstance(extra, str):
        return "its product_version_extra is invalid"
    if declared["assessments"] not in {"enabled", "disabled"}:
        return "its Gatekeeper state is invalid"
    arguments = value["process_arguments"]
    if not isinstance(arguments, str) or not arguments:
        return "it needs the process arguments"
    inputs = value["inputs"]
    if not isinstance(inputs, list) or not all(
        valid_tree(tree) for tree in cast(list[object], inputs)
    ):
        return "its inputs are invalid"
    names = [cast(str, cast(Json, tree)["name"]) for tree in cast(list[object], inputs)]
    if len(set(names)) != len(names) or names.count("bundle") != 1:
        return "its inputs need unique names and one bundle"
    bundle = next(
        cast(Json, tree)
        for tree in cast(list[object], inputs)
        if cast(Json, tree)["name"] == "bundle"
    )
    if any(
        cast(Json, item)["path"] == "." for item in cast(list[object], bundle["items"])
    ):
        return "its bundle must be a directory"
    if not valid_tree(value["golden"]):
        return "its golden image is invalid"
    return None


def read_frozen(sequence: Sequence, slot_set: str) -> Json:
    """The declaration in the readiness receipt that the ledger digested."""
    record = sequence.ready.get(slot_set)
    if record is None:
        raise Refusal(f"the {slot_set} set is not ready")
    receipt = cast(Json, record["receipt"])
    path = Path(cast(str, receipt["path"]))
    try:
        identity = digest_regular(path)
        value = read_object(path)
    except (OSError, ValueError) as error:
        raise Refusal(f"the readiness receipt is unreadable: {error}") from error
    if identity != receipt:
        raise Refusal(f"the {slot_set} receipt changed since its readiness record")
    problem = frozen_problem(value, slot_set)
    if problem is not None:
        raise Refusal(f"the receipt holds no valid frozen declaration: {problem}")
    return value


def frozen_core(frozen: Json) -> Json:
    return {key: value for key, value in frozen.items() if key != "set"}


def audit_before(directory: Path, slot: str) -> tuple[Json, Json]:
    """Audit the host before admission, which consumes the slot."""

    def load(sequence: Sequence) -> Json:
        sequence.check_admit(slot)
        slot_set = cast(str, sequence.slots[slot]["set"])
        frozen = read_frozen(sequence, slot_set)
        same = slot_set == FOCUSED or frozen_core(frozen) == frozen_core(
            read_frozen(sequence, FOCUSED)
        )
        return {"frozen": frozen, "same": same}

    loaded = with_writer(directory, "audit-before", load)
    frozen = cast(Json, loaded["frozen"])
    inputs = [audit_tree(tree) for tree in cast(list[Json], frozen["inputs"])]
    results: Json = {
        "receipt": "passed" if loaded["same"] else "failed",
        "inputs": inputs,
    }
    named: list[tuple[str, object]] = [("receipt", results["receipt"])]
    named += [(cast(str, tree["name"]), tree["result"]) for tree in inputs]
    if slot == "A01":
        golden = audit_tree(cast(Json, frozen["golden"]))
        results["golden"] = golden
        named.append(("golden", golden["result"]))
    verdict = combined(named)
    if verdict["result"] != "passed":

        def hold(sequence: Sequence) -> Json:
            sequence.check_admit(slot)
            sequence.append("held", {"slot": slot, "audit": results})
            raise Refusal(
                f"the audit before {slot} did not pass, so the sequence holds: "
                f"{verdict['detail']}"
            )

        with_writer(directory, "audit-before", hold)
    return frozen, results


def receipt_record(root: Path, operation: str) -> Json | None:
    """The parsed record of the last attempt of this read, when it is clean."""
    try:
        attempts, _ = read_attempts(root)
        matching = [a for a in attempts if a["operation"] == operation]
        if not matching or matching[-1]["outcome"] != "clean":
            return None
        return read_object(root / cast(str, matching[-1]["ordinal"]) / "read.json")
    except (OSError, ValueError):
        return None


def check(result: object, detail: str, **fields: object) -> Json:
    return {"result": result, "detail": detail, **fields}


def observed_arguments(root: Path) -> tuple[list[str], list[str]]:
    """The arguments of each Koine process row, and each read that failed."""
    rows: list[str] = []
    problems: list[str] = []
    try:
        attempts, _ = read_attempts(root)
    except OSError as error:
        return [], [f"root: {error}"]
    for attempt in attempts:
        ordinal = cast(str, attempt["ordinal"])
        try:
            request = read_object(root / ordinal / "request.json")
            if request.get("read") != "process" or request.get("read_arguments") == [
                "textedit"
            ]:
                continue
            if attempt["outcome"] != "clean":
                problems.append(f"{attempt['operation']} is {attempt['outcome']}")
                continue
            record = read_object(root / ordinal / "read.json")
            rows += [
                cast(str, entry["arguments"])
                for entry in cast(list[Json], record["processes"])
            ]
        except (OSError, ValueError, KeyError) as error:
            problems.append(f"{ordinal}: {error}")
    return rows, problems


def audit_process(root: Path, declared: object, read_phase: Json) -> Json:
    rows, problems = observed_arguments(root)
    different = sorted({row for row in rows if row != declared})
    if different:
        return check("failed", "a process has undeclared arguments", observed=different)
    if problems:
        return check("unavailable", ", ".join(problems))
    if not rows:
        result = read_phase["result"] if read_phase["result"] != "passed" else None
        return check(result or "unavailable", "no Koine process was observed")
    return check("passed", f"{len(rows)} process rows match")


def system_check(root: Path, declared: Json, absent: str) -> Json:
    system = receipt_record(root, "system")
    if system is None:
        return check(absent, "no clean system receipt")
    wanted = {name: declared[name] for name in SYSTEM_FIELDS}
    seen = {name: system.get(name) for name in SYSTEM_FIELDS}
    return check(
        "passed" if wanted == seen else "failed",
        "the guest system against the declared image",
        expected=wanted,
        observed=seen,
    )


def gatekeeper_check(root: Path, declared: Json, absent: str) -> Json:
    gatekeeper = receipt_record(root, "gatekeeper")
    if gatekeeper is None:
        return check(absent, "no clean gatekeeper receipt")
    same = gatekeeper.get("assessments") == declared["assessments"]
    return check(
        "passed" if same else "failed",
        "the Gatekeeper state against the declared image",
        expected=declared["assessments"],
        observed=gatekeeper.get("assessments"),
    )


def audit_environment(root: Path, frozen: Json, guest: dict[str, GuestRead]) -> Json:
    """G5 and the defaults. Each comparison keeps its own result."""
    declared = cast(Json, frozen["environment"])
    # With no guest read, the receipts of a run that never reached a guest are
    # not failures of the environment.
    absent = "not-run" if guest["process"][1]["result"] == "not-run" else "unavailable"
    system_result = system_check(root, declared, absent)
    gatekeeper_result = gatekeeper_check(root, declared, absent)
    defaults, defaults_phase = guest["defaults"]
    if defaults is None:
        defaults_check = check(defaults_phase["result"], str(defaults_phase["detail"]))
    elif defaults.get("diagnostics_disabled") is True:
        defaults_check = check("passed", "a clean read shows diagnostics disabled")
    else:
        defaults_check = check("failed", "a diagnostic key is present")
    return {
        "system": system_result,
        "gatekeeper": gatekeeper_result,
        "process": audit_process(
            root, frozen["process_arguments"], guest["process"][1]
        ),
        "defaults": defaults_check,
    }


def bundle_items(frozen: Json) -> list[Json]:
    """The frozen bundle, in the shape of the installed inventory."""
    tree = next(
        tree for tree in cast(list[Json], frozen["inputs"]) if tree["name"] == "bundle"
    )
    items: list[Json] = []
    for item in cast(list[Json], tree["items"]):
        path = f"./{item['path']}"
        if item["kind"] == "file":
            items.append({"path": path, "kind": "file", "sha256": item["sha256"]})
        elif item["kind"] == "symlink":
            items.append({"path": path, "kind": "symlink", "target": item["target"]})
    return items


def installed_items(record: Json) -> list[Json]:
    files = [
        {"path": entry["path"], "kind": "file", "sha256": entry["sha256"]}
        for entry in cast(list[Json], record["files"])
    ]
    links = [
        {"path": entry["path"], "kind": "symlink", "target": entry["target"]}
        for entry in cast(list[Json], record["symlinks"])
    ]
    return files + links


def installed_endpoint(
    expected: list[Json], record: Json | None, result: object, detail: str
) -> Json:
    if record is None:
        return check(result, detail, missing=[], extra=[], changed=[])
    comparison = compare_items(expected, installed_items(record))
    return check(
        comparison_result(comparison, []),
        "the installed bundle against the frozen bundle",
        **comparison,
    )


def audit_installed(root: Path, frozen: Json, guest: dict[str, GuestRead]) -> Json:
    """Each endpoint against the frozen bundle, so a stable wrong bundle fails."""
    expected = bundle_items(frozen)
    after, after_phase = guest["installed"]
    absent = "not-run" if after_phase["result"] == "not-run" else "unavailable"
    return {
        "before": installed_endpoint(
            expected,
            receipt_record(root, INSTALLED_BEFORE),
            absent,
            f"no clean {INSTALLED_BEFORE} receipt",
        ),
        "after": installed_endpoint(
            expected, after, after_phase["result"], str(after_phase["detail"])
        ),
    }


def audit_subject(root: Path, frozen: Json, absent: str) -> Json:
    """The admitted subject and setup, which a recurrence needs.

    The system, Gatekeeper and first installed receipts precede each selection.
    Undeclared process arguments show a wrong launch. A later failed read says
    nothing about this setup, so it cannot remove a recurrence.
    """
    declared = cast(Json, frozen["environment"])
    rows, _ = observed_arguments(root)
    different = any(row != frozen["process_arguments"] for row in rows)
    try:
        before = installed_endpoint(
            bundle_items(frozen),
            receipt_record(root, INSTALLED_BEFORE),
            absent,
            f"no clean {INSTALLED_BEFORE} receipt",
        )
    except (KeyError, TypeError) as error:
        before = check("unavailable", f"malformed {INSTALLED_BEFORE}: {error}")
    return combined(
        [
            ("system", system_check(root, declared, absent)["result"]),
            ("gatekeeper", gatekeeper_check(root, declared, absent)["result"]),
            (INSTALLED_BEFORE, before["result"]),
            ("process arguments", "failed" if different else "passed"),
        ]
    )


def guest_streams(
    attempt: Path, transport: object, clean: bool
) -> tuple[Json | None, list[str]]:
    """The raw envelope, and each guest stream that the backend owes from it."""
    names = ("stdout", "stderr")
    saved = [name for name in names if (attempt / f"guest.{name}").exists()]
    if transport not in {"exec", "read"}:
        return (read_object(attempt / "raw.stdout"), saved) if saved else (None, [])
    try:
        envelope = read_object(attempt / "raw.stdout")
    except (OSError, ValueError):
        # A failed attempt can hold a partial response, which owes no stream.
        if clean or saved:
            raise
        return None, []
    return envelope, [
        name for name in names if name in saved or isinstance(envelope.get(name), str)
    ]


def audit_originals(root: Path) -> Json:
    """Compare each saved artifact with its original, and require each member."""
    compared = 0
    mismatched: list[str] = []
    missing: list[str] = []
    unreadable: list[str] = []
    partials: list[str] = []

    def compare(path: Path, size: object, digest: object) -> None:
        nonlocal compared
        compared += 1
        try:
            saved = digest_regular(path)
        except FileNotFoundError:
            mismatched.append(str(path))
        except (OSError, ValueError) as error:
            unreadable.append(f"{path}: {error}")
        else:
            if (saved["bytes"], saved["sha256"]) != (size, digest):
                mismatched.append(str(path))

    try:
        attempts = sorted(
            path for path in root.iterdir() if re.fullmatch(r"[0-9]{6}", path.name)
        )
    except OSError as error:
        return check(
            "unavailable",
            f"no readable root: {error}",
            compared=0,
            mismatched=[],
            missing=[],
            unreadable=[],
            partials=[],
        )
    for attempt in attempts:
        # A partial has no completed original to compare. The manifest keeps it.
        if not (attempt / "result.json").exists():
            partials.append(attempt.name)
            continue
        try:
            transport = read_object(attempt / "request.json").get("transport")
            clean = read_object(attempt / "result.json").get("outcome") == "clean"
            if clean:
                if not isinstance(transport, str) or transport not in REQUIRED_MEMBERS:
                    unreadable.append(f"{attempt.name}: unknown transport {transport}")
                    continue
                # Membership comes from the receipt, so a lost file cannot agree
                # with a manifest that was written after the loss.
                missing += [
                    f"{attempt.name}/{name}"
                    for name in REQUIRED_MEMBERS[transport]
                    if not (attempt / name).is_file()
                ]
            if (attempt / "artifact.json").exists():
                artifact = read_object(attempt / "artifact.json")
                compare(
                    attempt / "screen.png",
                    artifact.get("bytes"),
                    artifact.get("sha256"),
                )
            if (attempt / "transfer.json").exists():
                transfer = read_object(attempt / "transfer.json")
                if transfer.get("direction") == "download":
                    compare(
                        attempt / "download.bin",
                        transfer.get("bytes"),
                        transfer.get("sha256"),
                    )
            envelope, streams = guest_streams(attempt, transport, clean)
            for name in streams:
                path = attempt / f"guest.{name}"
                if clean and not path.exists():
                    continue  # The member check above already names this loss.
                value = cast(Json, envelope).get(name)
                data = value.encode() if isinstance(value, str) else b""
                compare(
                    path,
                    len(data) if isinstance(value, str) else None,
                    hashlib.sha256(data).hexdigest(),
                )
        except (OSError, ValueError) as error:
            unreadable.append(f"{attempt.name}: {error}")
    result = (
        "failed" if mismatched or missing else "unavailable" if unreadable else "passed"
    )
    return check(
        result,
        f"{compared} saved artifacts compared, {len(partials)} partial attempts kept",
        compared=compared,
        mismatched=mismatched,
        missing=missing,
        unreadable=unreadable,
        partials=partials,
    )


def retained_files(output: Path) -> tuple[list[Json], list[Json]]:
    """Each retained file with its identity. A failed read stays named."""
    files: list[Json] = []
    errors: list[Json] = []
    for path in sorted(output.rglob("*")):
        try:
            mode = path.lstat().st_mode
            if stat.S_ISDIR(mode):
                continue
            if stat.S_ISLNK(mode):
                files.append({"path": str(path), "symlink": os.readlink(path)})
            elif stat.S_ISREG(mode):
                files.append(digest_regular(path))
            else:
                files.append({"path": str(path), "kind": "special"})
        except (OSError, ValueError) as error:
            errors.append({"path": str(path), "error": str(error)})
    return files, errors


def recheck_manifest(output: Path) -> Json:
    """Compare the evidence with its manifest. The run's own records keep growing."""
    records = f"{output / CONTAINMENT}/"

    def evidence(items: list[Json]) -> list[Json]:
        return [
            item for item in items if not cast(str, item["path"]).startswith(records)
        ]

    try:
        manifest = read_object(output / CONTAINMENT / "manifest.json")
        recorded = cast(list[Json], manifest["files"])
    except (OSError, ValueError, KeyError) as error:
        return phase("unavailable", f"the manifest is unreadable: {error}")
    files, errors = retained_files(output)
    comparison = compare_items(evidence(recorded), evidence(files))
    result = comparison_result(comparison, errors)
    if result == "passed":
        return phase("passed", "the evidence matches its manifest")
    return phase(result, f"the evidence differs from its manifest: {comparison}")


def inventory_tree(root: Path, name: str) -> int:
    """Print one frozen tree, in the exact form of the readiness receipt."""
    absolute = root.absolute()
    items, errors = scan_tree(absolute)
    if errors:
        raise Refusal(f"the tree has unreadable items: {errors}")
    if not items:
        raise Refusal(f"the tree has no items: {absolute}")
    print(json.dumps({"name": name, "root": str(absolute), "items": items}, indent=2))
    return 0


def read_screenshot_audit(path: Path) -> Json:
    try:
        audit = read_object(path)
    except (OSError, ValueError) as error:
        raise Refusal(f"the screenshot audit is unreadable: {error}") from error
    detail = audit.get("detail")
    if (
        set(audit) != {"result", "detail"}
        or audit["result"] not in RESULTS
        or not isinstance(detail, str)
        or not detail
    ):
        raise Refusal("the screenshot audit needs exactly a result and a detail")
    return audit


def settle_collected(directory: Path, slot: str, audit_path: Path) -> int:
    """Settle a collected run with its screenshot audit. Nothing else can change."""

    def step(sequence: Sequence) -> Json:
        sequence.check_settle(slot)
        if run_is_live(sequence.directory):
            raise Refusal(f"a live run owns {slot}")
        declared = sequence.slots[slot]
        output = Path(cast(str, declared["output"]))
        records = output / CONTAINMENT
        if not (records / "phases.json").exists():
            raise Refusal(f"{slot} has no collected phases")
        phases = read_phases(records / "phases.json")
        audit = read_screenshot_audit(audit_path)
        target = records / "screenshots.json"
        if target.exists():
            # A settlement that stopped here can run again with the same audit.
            if read_screenshot_audit(target) != audit:
                raise Refusal("a different screenshot audit is already recorded")
        else:
            write_exclusive(target, audit)
        phases["screenshots"] = phase(
            cast(str, audit["result"]), cast(str, audit["detail"])
        )
        recheck = recheck_manifest(output)
        if recheck["result"] != "passed" and phase_result(phases, "audit") == "passed":
            phases["audit"] = recheck
        return record_settlement(
            sequence, slot, phases, settled_classification(declared)
        )

    print(json.dumps(with_writer(directory, "settle-run", step), indent=2))
    return 0


def close_sequence(directory: Path) -> int:
    """Recheck the stopped golden image once, after the last slot."""

    def step(sequence: Sequence) -> Json:
        sequence.check_close()
        frozen = read_frozen(sequence, FOCUSED)
        return sequence.append(
            "closed", {"golden": audit_tree(cast(Json, frozen["golden"]))}
        )

    print(json.dumps(with_writer(directory, "close", step), indent=2))
    return 0


# --- the slot run and its containment ----------------------------------------


def read_bounds() -> dict[str, float]:
    """The fixed bounds. The controls shorten them, and the record keeps them."""
    bounds = dict(DEFAULT_BOUNDS)
    text = os.environ.get("KOINE_SEQUENCE_BOUNDS")
    if text is None:
        return bounds
    for item in text.split(","):
        key, _, value = item.partition("=")
        if key not in bounds or float(value) <= 0:
            raise ValueError(f"invalid bound: {item}")
        bounds[key] = float(value)
    return bounds


def read_scenario_exit(path: Path) -> tuple[int | None, str]:
    """The strict status that the Task entry wrote. Anything else is no status."""
    try:
        data = path.read_bytes()
    except FileNotFoundError:
        return None, "missing"
    except OSError:
        return None, "unreadable"
    if re.fullmatch(rb"(0|[1-9][0-9]{0,2})\n", data) and int(data) <= 255:
        return int(data), "read"
    return None, "malformed"


def group_members(group: int) -> list[int] | None:
    """The live members of the group. None means the listing is unavailable."""
    try:
        listing = subprocess.run(
            ["/bin/ps", "-axo", "pid=,pgid=,stat="],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if listing.returncode != 0:
        return None
    members: list[int] = []
    for line in listing.stdout.splitlines():
        fields = line.split()
        if len(fields) != 3 or not (fields[0].isdigit() and fields[1].isdigit()):
            return None
        # The unreaped leader stays a zombie, which keeps the group ID reserved.
        if int(fields[1]) == group and not fields[2].startswith("Z"):
            members.append(int(fields[0]))
    return members


def writer_free(root: Path) -> bool | None:
    """Test the evidence writer lock. Closing the descriptor releases the test."""
    try:
        descriptor = os.open(root / ".writer", os.O_RDONLY | os.O_NOFOLLOW)
    except FileNotFoundError:
        return True
    except OSError:
        return None
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return False
    except OSError:
        return None
    finally:
        os.close(descriptor)
    return True


def start_evidence(root: Path) -> tuple[bool, bool]:
    """Whether a start may have been requested, and whether its creation is open."""
    if not root.exists():
        return False, False
    try:
        attempts, unfinished = read_attempts(root)
    except OSError:
        return True, True
    # An unreadable request or a missing ordinal could hide the start.
    hidden = any(not isinstance(a["operation"], str) for a in attempts) or any(
        ORDINAL_GAP in entry for entry in unfinished
    )
    starts = [a for a in attempts if a["operation"] == "vm-start"]
    return bool(starts) or hidden, hidden or any(
        a["outcome"] != "clean" for a in starts
    )


def refusal_class(arguments: list[str]) -> str:
    if arguments[:1] in (["fail"], ["poll-step"]):
        return "confirmation"
    if "--" in arguments and arguments[arguments.index("--") + 1 :][:2] == [
        "vm",
        "stop",
    ]:
        return "stop"
    return "collection" if arguments[2:3] == ["evidence"] else "other"


def read_refusals(root: Path) -> list[Json]:
    """Each refused request of both logs, with its class and reason."""
    refusals: list[Json] = []

    def unreadable(source: str, line: bytes) -> None:
        refusals.append(
            {
                "source": source,
                "class": "unreadable",
                "reason": "the refusal record is unreadable",
                "raw": line.decode("utf-8", "replace"),
            }
        )

    path = root / "refusals.jsonl"
    for line in path.read_bytes().splitlines() if path.exists() else []:
        try:
            record: object = json.loads(line)
        except ValueError:
            unreadable("backend", line)
            continue
        fields = cast(Json, record) if isinstance(record, dict) else {}
        arguments = fields.get("arguments")
        reason = fields.get("reason")
        if not isinstance(arguments, list) or not isinstance(reason, str):
            unreadable("backend", line)
            continue
        words = [str(word) for word in cast(list[object], arguments)]
        refusals.append(
            {
                "source": "backend",
                "class": refusal_class(words),
                "reason": reason,
                "arguments": words,
            }
        )
    path = root / "facade-refusals.log"
    for line in path.read_bytes().splitlines() if path.exists() else []:
        match = re.fullmatch(rb"backend_exit=([0-9]+) argv=(.*)", line)
        try:
            words = shlex.split(match[2].decode()) if match else None
        except (ValueError, UnicodeDecodeError):
            words = None
        if match is None or words is None:
            unreadable("facade", line)
            continue
        refusals.append(
            {
                "source": "facade",
                "class": refusal_class(words),
                "reason": f"backend exit {match[1].decode()}",
                "arguments": words,
            }
        )
    return refusals


def phase(result: str, detail: str) -> Json:
    return {"result": result, "detail": detail}


class Containment:
    """One slot's Task, its evidence and the containment of its exact clone."""

    def __init__(
        self,
        declared: Json,
        bounds: dict[str, float],
        received: list[int],
        frozen: Json,
        before: Json,
    ) -> None:
        self.declared = declared
        self.frozen = frozen
        self.before = before
        self.clone = cast(str, declared["clone"])
        self.output = Path(cast(str, declared["output"]))
        self.root = Path(cast(str, declared["evidence_root"]))
        self.records = self.output / CONTAINMENT
        self.bounds = bounds
        self.received = received
        self.record_errors: list[str] = []
        self.released = False
        self.exits: select.kqueue | None = None
        self.environment = {
            key: value for key, value in os.environ.items() if key not in OVERRIDES
        }
        self.environment.update(
            KOINE_VM_ID=self.clone,
            KOINE_VM_BASE=BASE,
            KOINE_VM_EVIDENCE_ROOT=str(self.root),
            KOINE_K4_OUT=str(self.output),
        )
        self.records.mkdir(mode=0o700)

    def action(self, name: str, **fields: object) -> None:
        """Keep one containment action. A lost record never stops containment."""
        line = json.dumps({"at": timestamp(), "action": name, **fields}) + "\n"
        try:
            with (self.records / "actions.jsonl").open("ab", buffering=0) as stream:
                stream.write(line.encode("ascii"))
                os.fsync(stream.fileno())
        except OSError as error:
            self.record_errors.append(f"{name}: {error}")

    def keep(self, name: str, value: object) -> None:
        try:
            write_exclusive(self.records / name, value)
        except OSError as error:
            self.record_errors.append(f"{name}: {error}")

    def start_task(self, task: str) -> subprocess.Popen[bytes] | None:
        """Start the entry behind a gate, and open it once the group is recorded."""
        entry = cast(str, self.declared["entry"])
        read_end, write_end = os.pipe()
        try:
            with (
                (self.records / "task.stdout").open("xb") as stdout,
                (self.records / "task.stderr").open("xb") as stderr,
            ):
                process = subprocess.Popen(
                    ["/bin/bash", "-c", GATE, "gate", task, entry],
                    cwd=REPOSITORY,
                    env=self.environment,
                    stdin=read_end,
                    stdout=stdout,
                    stderr=stderr,
                    start_new_session=True,
                )
        except OSError as error:
            os.close(write_end)
            self.action("task-not-started", reason=str(error))
            return None
        finally:
            os.close(read_end)
        try:
            # The gate keeps the child alive, so this registration cannot miss its
            # exit. A kqueue event reports the exit and leaves the leader unreaped.
            self.exits = select.kqueue()
            self.exits.control(
                [
                    select.kevent(
                        process.pid,
                        select.KQ_FILTER_PROC,
                        select.KQ_EV_ADD | select.KQ_EV_ONESHOT,
                        select.KQ_NOTE_EXIT,
                    )
                ],
                0,
            )
            write_exclusive(
                self.records / "process.json",
                {
                    "pid": process.pid,
                    "pgid": os.getpgid(process.pid),
                    "task": task,
                    "entry": entry,
                    "bounds": self.bounds,
                },
            )
            if not self.received:
                os.write(write_end, b"start\n")
                self.released = True
        except OSError as error:
            self.record_errors.append(f"process.json: {error}")
        finally:
            os.close(write_end)
        self.action("task-released" if self.released else "task-withheld")
        return process

    def signal_group(self, group: int, name: str, number: int) -> None:
        try:
            os.killpg(group, number)
            self.action(name, group=group, signal=signal.Signals(number).name)
        except OSError as error:
            self.action(name, group=group, error=str(error))

    def await_task(self, process: subprocess.Popen[bytes]) -> None:
        """Wait without reaping, so the group ID stays reserved. Forward one signal."""
        if not self.released or self.exits is None:
            return  # The closed gate ends the child, and the group wait sees it.
        deadline: float | None = None
        while not self.exits.control(None, 1, 0.02):
            if self.received and deadline is None:
                deadline = time.monotonic() + self.bounds["holder"]
                self.signal_group(process.pid, "signal-forwarded", self.received[0])
            if deadline is not None and time.monotonic() >= deadline:
                return

    def await_group(self, group: int, seconds: float) -> list[int] | None:
        deadline = time.monotonic() + seconds
        while True:
            members = group_members(group)
            if members is None or not members or time.monotonic() >= deadline:
                return members
            time.sleep(0.02)

    def end_group(self, group: int, prefix: str = "") -> list[int] | None:
        """TERM, then KILL, each with its own bound and record."""
        members: list[int] | None = None
        for name, number, bound in (
            ("group-term", signal.SIGTERM, "term"),
            ("group-kill", signal.SIGKILL, "kill"),
        ):
            self.signal_group(group, f"{prefix}{name}", number)
            members = self.await_group(group, self.bounds[bound])
            if members == []:
                break
        return members

    def resolve_holders(self, group: int) -> Json:
        """Wait for the recorded group, then end it. Never touch the lock or latch."""
        result = "none"
        members = group_members(group)
        if members:
            self.action("holder-wait", members=members)
            members = self.await_group(group, self.bounds["holder"])
            result = "waited"
            if members:
                members = self.end_group(group)
                result = "ended"
        if members is None:
            return phase("unresolved", "the process listing is unavailable")
        if members:
            return phase("unresolved", f"the group still has members: {members}")
        deadline = time.monotonic() + self.bounds["holder"]
        while (free := writer_free(self.root)) is False:
            if time.monotonic() >= deadline:
                break
            time.sleep(0.02)
        if free is not True:
            self.action("lock-held")
            return phase("unresolved", "a process outside the group holds the lock")
        return phase(result, "the recorded group is empty and the lock is free")

    def facade(
        self, function: str, operation: str, limit: float, *arguments: str
    ) -> tuple[int | None, bool]:
        """One bounded helper call, in its own group, through the writer domain."""
        command = [
            "/bin/bash",
            "-c",
            'source "$1"; source "$2"; shift 2; "$@"',
            CONTAINMENT,
            str(LIFECYCLE),
            str(EXEC_READS),
            function,
            str(self.root),
            *arguments,
        ]
        try:
            with (
                (self.records / f"{operation}.stdout").open("xb") as stdout,
                (self.records / f"{operation}.stderr").open("xb") as stderr,
            ):
                process = subprocess.Popen(
                    command,
                    cwd=REPOSITORY,
                    env=self.environment,
                    stdin=subprocess.DEVNULL,
                    stdout=stdout,
                    stderr=stderr,
                    start_new_session=True,
                )
        except OSError as error:
            self.action(f"{operation}-not-started", reason=str(error))
            return None, False
        try:
            return process.wait(timeout=limit), False
        except subprocess.TimeoutExpired:
            self.action(f"{operation}-timeout", bound=limit)
        # The leader stays unreaped here, so its group ID cannot be reused.
        self.end_group(process.pid, f"{operation}-")
        process.poll()
        return None, True

    def attempt_result(self, operation: str, status: int | None, late: bool) -> Json:
        """Classify one containment attempt from its own receipt and status."""
        fields: Json = {"sent": True, "status": status, "timed_out": late}
        if late:
            return {**fields, **phase("unavailable", "the attempt outlasted its bound")}
        try:
            attempts, _ = read_attempts(self.root)
        except OSError as error:
            return {**fields, **phase("unavailable", f"no readable root: {error}")}
        matching = [a for a in attempts if a["operation"] == operation]
        if not matching:
            return {**fields, **phase("unavailable", f"no receipt, status {status}")}
        outcome = matching[-1]["outcome"]
        if outcome == "clean" and status == 0:
            return {**fields, **phase("passed", "a clean receipt and status 0")}
        if outcome in {"clean", "partial"}:
            detail = f"receipt {outcome} with status {status}"
            return {**fields, **phase("unavailable", detail)}
        return {**fields, **phase("failed", f"receipt {outcome}, status {status}")}

    def contain(self, requested: bool, holder: Json) -> tuple[Json, Json, bool]:
        """At most one exact stop, then one independent inventory."""
        idle: Json = {"sent": False, "status": None, "timed_out": False}
        if holder["result"] == "unresolved":
            detail = f"the lock holder is unresolved: {holder['detail']}"
            return (
                {**idle, **phase("not-run", detail)},
                {
                    **idle,
                    **phase("not-run", detail),
                },
                False,
            )
        created = False
        if not self.root.exists():
            # The inventory needs a root in the same writer domain.
            status, _ = self.facade(
                "init_guest_evidence",
                "containment-init",
                self.bounds["kill"],
                self.clone,
            )
            created = status == 0
            self.action(
                "root-created" if created else "root-not-created", status=status
            )
        if requested:
            self.action("stop-sent", clone=self.clone)
            status, late = self.facade(
                "stop_guest_vm", STOP_OPERATION, self.bounds["stop"], STOP_OPERATION
            )
            stop = self.attempt_result(STOP_OPERATION, status, late)
        else:
            stop = {**idle, **phase("not-run", "no start attempt to contain")}
        status, late = self.facade(
            "inventory_guest_vms",
            INVENTORY_OPERATION,
            self.bounds["inventory"],
            "evidence",
            INVENTORY_OPERATION,
            "absent",
        )
        return stop, self.attempt_result(INVENTORY_OPERATION, status, late), created

    def read_guest(self, operation: str, name: str, *arguments: str) -> GuestRead:
        """One bounded evidence read. A failed read is never a negative fact."""
        status, late = self.facade(
            "read_guest_exec",
            operation,
            self.bounds["audit"],
            "evidence",
            operation,
            name,
            *arguments,
        )
        if late:
            return None, phase("unavailable", f"{operation} outlasted its bound")
        record = receipt_record(self.root, operation)
        if status != 0 or record is None:
            return None, phase("unavailable", f"{operation}: status {status}")
        return record, phase("passed", f"{operation} is clean")

    def read_guest_state(
        self, requested: bool, uncertain: bool, holder: Json
    ) -> dict[str, GuestRead]:
        """Read the guest before the stop, when a guest can have been reached."""
        reason = None
        if holder["result"] == "unresolved":
            reason = f"the lock holder is unresolved: {holder['detail']}"
        elif not requested:
            reason = "no start attempt"
        elif uncertain:
            reason = "the start did not complete"
        if reason is not None:
            skipped: GuestRead = (None, phase("not-run", reason))
            return {"installed": skipped, "defaults": skipped, "process": skipped}
        return {
            "installed": self.read_guest(INSTALLED_READ, "installed-inventory"),
            "defaults": self.read_guest(DEFAULTS_READ, "defaults"),
            "process": self.read_guest(PROCESS_READ, "process", "executable"),
        }

    def run_audits(self, guest: dict[str, GuestRead]) -> tuple[Json, Json]:
        """Run each audit after the stop. Each result stays separate."""
        environment = audit_environment(self.root, self.frozen, guest)
        installed = audit_installed(self.root, self.frozen, guest)
        after = [audit_tree(tree) for tree in cast(list[Json], self.frozen["inputs"])]
        originals = audit_originals(self.root)
        inputs = cast(list[Json], self.before["inputs"])
        audits: Json = {
            "host_before": inputs,
            "host_after": after,
            "installed": installed,
            "originals": originals,
            "environment": environment,
        }
        if "golden" in self.before:
            audits["golden_before"] = self.before["golden"]
        host: list[tuple[str, object]] = [
            (f"{tree['name']} before", tree["result"]) for tree in inputs
        ]
        host += [(f"{tree['name']} after", tree["result"]) for tree in after]
        host.append(("originals", originals["result"]))
        phases: Json = {
            "environment": combined(
                [(name, cast(Json, c)["result"]) for name, c in environment.items()]
            ),
            "endpoint": combined(
                [(name, cast(Json, c)["result"]) for name, c in installed.items()]
            ),
            "audit": combined(host),
        }
        return audits, phases

    def write_manifest(self) -> Json:
        """Digest every retained file. A file that cannot be read stays named."""
        files, errors = retained_files(self.output)
        manifest: Json = {"files": files, "errors": errors}
        self.keep("manifest.json", manifest)
        return manifest

    def execute(self, task: str) -> tuple[Json, Json]:
        """Run the entry, then collect and contain. Each result stays separate."""
        process = self.start_task(task)
        holder = phase("none", "no Task process")
        if process is not None:
            self.await_task(process)
            holder = self.resolve_holders(process.pid)
        code = process.poll() if process is not None else None
        code = code if self.released else None
        task_status = code if code is None or code >= 0 else 128 - code
        scenario_status, scenario_file = read_scenario_exit(
            self.output / "scenario.exit"
        )
        # Freeze the class before any containment receipt enters the root.
        left_root = self.root.exists()
        classification = classify_root(
            self.root, cast(str, self.declared["set"]), self.clone
        )
        self.keep("classification.json", classification)
        requested, uncertain = start_evidence(self.root)
        # The guest reads need the clone, so they come before its stop.
        guest = self.read_guest_state(requested, uncertain, holder)
        stop, inventory, created = self.contain(requested, holder)
        try:
            refusals = read_refusals(self.root)
        except OSError as error:
            refusals = [
                {
                    "source": "caller",
                    "class": "unreadable",
                    "reason": f"the refusal logs are unreadable: {error}",
                }
            ]
        self.keep("refusals.json", refusals)
        manifest = self.write_manifest()
        refused = [r for r in refusals if r["class"] in {"collection", "unreadable"}]
        if not left_root:
            collection = phase("unavailable", "the scenario left no evidence root")
        elif manifest["errors"]:
            collection = phase("unavailable", "the manifest names unreadable files")
        elif refused:
            collection = phase("failed", f"{len(refused)} refused collection records")
        else:
            collection = phase("passed", f"{len(refusals)} refusals recorded")
        try:
            audits, audit_phases = self.run_audits(guest)
        except (OSError, ValueError, KeyError, TypeError) as error:
            # A malformed record must not stop the settlement of this slot.
            detail = f"the audit could not complete: {error}"
            audits = {"error": detail}
            audit_phases = cast(
                Json,
                dict.fromkeys(
                    ("environment", "endpoint", "audit"), phase("unavailable", detail)
                ),
            )
        # This audit stands alone, so a malformed later record cannot remove it.
        absent = (
            "not-run" if guest["process"][1]["result"] == "not-run" else "unavailable"
        )
        try:
            subject = audit_subject(self.root, self.frozen, absent)
        except (OSError, ValueError, KeyError, TypeError) as error:
            subject = phase("unavailable", f"the subject audit failed: {error}")
        self.keep("audits.json", {**audits, "subject": subject})
        phases: Json = {
            "scenario": {"status": scenario_status},
            "task": {"status": task_status},
            "collection": collection,
            "subject": subject,
            "stop": phase(cast(str, stop["result"]), cast(str, stop["detail"])),
            "inventory": phase(
                cast(str, inventory["result"]), cast(str, inventory["detail"])
            ),
            **audit_phases,
            "screenshots": phase(
                "not-run", "settle-run takes the k54 screenshot audit"
            ),
        }
        self.keep("phases.json", phases)
        self.keep(
            "result.json",
            {
                "slot": self.declared["slot"],
                "clone": self.clone,
                "task": {"status": task_status, "released": self.released},
                "scenario": {"status": scenario_status, "file": scenario_file},
                "start": {"requested": requested, "uncertain": uncertain},
                "root_created_by_caller": created,
                "holder": holder,
                "held_input": classification["pointer"],
                "stop": stop,
                "inventory": inventory,
                "refusals": len(refusals),
                "interruptions": [
                    signal.Signals(number).name for number in self.received
                ],
                "manifest": {
                    "files": len(cast(list[Json], manifest["files"])),
                    "errors": len(cast(list[Json], manifest["errors"])),
                },
                "record_errors": self.record_errors,
            },
        )
        return phases, classification


def settle_run(directory: Path, slot: str, phases: Json, classification: Json) -> Json:
    """Settle through the ledger. A short-lived contender does not lose the result."""

    def step(sequence: Sequence) -> Json:
        sequence.check_settle(slot)
        validate_phases(phases)
        return record_settlement(sequence, slot, phases, classification)

    for remaining in range(49, -1, -1):
        try:
            return with_writer(directory, "settle", step)
        except Refusal as error:
            if "competing" not in str(error) or remaining == 0:
                raise
            time.sleep(0.1)
    raise Refusal("the settlement did not complete")


def unstarted_phases(reason: str) -> Json:
    missing = phase("unavailable", reason)
    return {
        "scenario": {"status": None},
        "task": {"status": None},
        **dict.fromkeys(RESULT_PHASES, missing),
    }


def run_slot(directory: Path, slot: str) -> int:
    """Admit one slot, run its entry once, contain its clone and settle it."""
    resolved = directory.absolute().resolve()
    if not (resolved / "sequence.json").is_file():
        raise Refusal(f"no declared sequence at {resolved}")

    def refuse(reason: str) -> Refusal:
        record_refusal(resolved, "run", reason)
        return Refusal(reason)

    present = [name for name in OVERRIDES if name in os.environ]
    if present:
        raise refuse(f"the run does not honour {', '.join(present)}")
    try:
        bounds = read_bounds()
    except ValueError as error:
        raise refuse(str(error)) from error
    task = shutil.which("task")
    if task is None:
        raise refuse("the task executable is not on PATH")
    received: list[int] = []

    def receive(number: int, _frame: FrameType | None) -> None:
        received.append(number)

    with (resolved / ".runner").open("a") as runner:
        try:
            fcntl.flock(runner, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise refuse("another run is live") from None
        for number in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
            signal.signal(number, receive)
        if received:
            raise refuse("interrupted before admission")
        # Admission consumes the slot, so the host audit comes first.
        frozen, before = audit_before(resolved, slot)
        if received:
            raise refuse("interrupted before admission")
        declared = admit_slot(resolved, slot)
        try:
            containment = Containment(declared, bounds, received, frozen, before)
        except OSError as error:
            # No Task started, so the slot settles with nothing to contain.
            phases = unstarted_phases(f"the run records are unavailable: {error}")
            classification = classify_root(
                Path(cast(str, declared["evidence_root"])),
                cast(str, declared["set"]),
                cast(str, declared["clone"]),
            )
            settled = settle_run(resolved, slot, phases, classification)
            print(json.dumps(settled, indent=2))
            return 0
        phases, _ = containment.execute(task)
    # The screenshot audit needs a judgement, so settle-run ends this slot.
    print(json.dumps({"slot": slot, "state": AWAITING, "phases": phases}, indent=2))
    return 0


# --- the report --------------------------------------------------------------


def overall(sequence: Sequence) -> str:
    dispositions = {
        slot: record["disposition"] for slot, record in sequence.settled.items()
    }
    if "rejected" in dispositions.values():
        return "rejected"
    if sequence.stopped() is not None:
        return "no-acceptance"
    if len(dispositions) == len(SLOT_NAMES):
        if sequence.closed is None:
            return "awaiting-golden-audit"
        golden = cast(Json, sequence.closed["golden"])
        return (
            "accepted-finite-sample"
            if golden["result"] == "passed"
            else "no-acceptance"
        )
    if {"E01", "E02"} <= set(dispositions):
        return "focused-sample-passed"
    return "in-progress"


def report(directory: Path) -> int:
    def step(sequence: Sequence) -> Json:
        slots: Json = {}
        for slot in SLOT_NAMES:
            settled = sequence.settled.get(slot)
            if settled is not None:
                slots[slot] = {
                    "state": "settled",
                    **{
                        key: settled[key]
                        for key in (
                            "disposition",
                            "cleanup",
                            "conflicts",
                            "classification",
                            "phases",
                        )
                    },
                }
            elif slot in sequence.started:
                slots[slot] = {"state": "started-unsettled"}
            else:
                slots[slot] = {"state": "NOT RUN"}
        return {
            "outcome": overall(sequence),
            "stopped_at": sequence.stopped(),
            "ready": sorted(sequence.ready),
            "held": sequence.held,
            "closed": sequence.closed,
            "slots": slots,
        }

    print(json.dumps(with_writer(directory, "report", step), indent=2))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    commands = parser.add_subparsers(dest="action", required=True)
    declare_parser = commands.add_parser(
        "declare", help="create a new declared sequence"
    )
    declare_parser.add_argument("directory", type=Path)
    ready_parser = commands.add_parser(
        "ready", help="record one set's readiness receipt"
    )
    ready_parser.add_argument("directory", type=Path)
    ready_parser.add_argument("set", choices=[FOCUSED, ORDINARY])
    ready_parser.add_argument("receipt", type=Path)
    admit_parser = commands.add_parser("admit", help="consume the next slot")
    admit_parser.add_argument("directory", type=Path)
    admit_parser.add_argument("slot", choices=SLOT_NAMES)
    classify_parser = commands.add_parser("classify", help="classify one evidence root")
    classify_parser.add_argument("root", type=Path)
    classify_parser.add_argument("set", choices=[FOCUSED, ORDINARY])
    classify_parser.add_argument("clone")
    settle_parser = commands.add_parser(
        "settle", help="close a slot whose caller ended before it collected phases"
    )
    settle_parser.add_argument("directory", type=Path)
    settle_parser.add_argument("slot", choices=SLOT_NAMES)
    run_parser = commands.add_parser(
        "run", help="admit one slot, run its entry, contain its clone and settle it"
    )
    run_parser.add_argument("directory", type=Path)
    run_parser.add_argument("slot", choices=SLOT_NAMES)
    inventory_parser = commands.add_parser(
        "inventory", help="print one frozen tree for a readiness receipt"
    )
    inventory_parser.add_argument("root", type=Path)
    inventory_parser.add_argument("name")
    settle_run_parser = commands.add_parser(
        "settle-run", help="settle a collected run with its screenshot audit"
    )
    settle_run_parser.add_argument("directory", type=Path)
    settle_run_parser.add_argument("slot", choices=SLOT_NAMES)
    settle_run_parser.add_argument("audit", type=Path)
    close_parser = commands.add_parser(
        "close", help="recheck the stopped golden image after the sequence"
    )
    close_parser.add_argument("directory", type=Path)
    report_parser = commands.add_parser(
        "report", help="report every slot and the outcome"
    )
    report_parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    action = cast(str, args.action)
    try:
        if action == "declare":
            return declare(cast(Path, args.directory))
        if action == "ready":
            return ready(
                cast(Path, args.directory),
                cast(str, args.set),
                cast(Path, args.receipt),
            )
        if action == "admit":
            return admit(cast(Path, args.directory), cast(str, args.slot))
        if action == "classify":
            return classify(
                cast(Path, args.root), cast(str, args.set), cast(str, args.clone)
            )
        if action == "settle":
            return settle(cast(Path, args.directory), cast(str, args.slot))
        if action == "run":
            return run_slot(cast(Path, args.directory), cast(str, args.slot))
        if action == "inventory":
            return inventory_tree(cast(Path, args.root), cast(str, args.name))
        if action == "settle-run":
            return settle_collected(
                cast(Path, args.directory), cast(str, args.slot), cast(Path, args.audit)
            )
        if action == "close":
            return close_sequence(cast(Path, args.directory))
        return report(cast(Path, args.directory))
    except Refusal as error:
        print(f"refused: {error}", file=sys.stderr)
        return 3


if __name__ == "__main__":
    sys.exit(main())
