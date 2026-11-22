#!/usr/bin/env python3
"""Hold the finite Settings ordering sequence.

The tool declares the five fixed slots, admits them in order and classifies the
receipts of each evidence root. It settles each slot and reports every slot that
did not run. It starts no clone and sends no guest command. The protocol is
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
import stat
import sys
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path
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
    "environment",
    "endpoint",
    "audit",
    "stop",
    "inventory",
    "screenshots",
)
LEDGER_NAME = re.compile(r"([0-9]{6})-(ready|started|settled)\.json")

Json = dict[str, object]


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


def admit(directory: Path, slot: str) -> int:
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

    print(json.dumps(with_writer(directory, "admit", step), indent=2))
    return 0


# --- classification ----------------------------------------------------------


def read_attempts(root: Path) -> tuple[list[Json], list[str]]:
    """The ordered attempts. A missing or invalid receipt is an unfinished one."""
    attempts: list[Json] = []
    unfinished: list[str] = []
    names = sorted(p.name for p in root.iterdir() if re.fullmatch(r"[0-9]{6}", p.name))
    for index, name in enumerate(names, 1):
        if int(name) != index:
            unfinished.append(f"{name}: the ordinals have a gap")
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
    result["pointer"] = pointer_state(attempts)
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
        if isinstance(operation, str) and operation.startswith(SIGNAL):
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
        # A later failed collection or cleanup cannot erase the rejection.
        corroborated = phase_result(phases, "screenshots") == "passed"
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


def settle(directory: Path, slot: str, phases_path: Path) -> int:
    def step(sequence: Sequence) -> Json:
        sequence.check_settle(slot)
        phases = read_phases(phases_path)
        declared = sequence.slots[slot]
        classification = classify_root(
            Path(cast(str, declared["evidence_root"])),
            cast(str, declared["set"]),
            cast(str, declared["clone"]),
        )
        disposition, conflicts = decide(classification, phases)
        cleanup = (
            "confirmed"
            if phase_result(phases, "stop") == "passed"
            and phase_result(phases, "inventory") == "passed"
            else "unresolved"
        )
        return sequence.append(
            "settled",
            {
                "slot": slot,
                "disposition": disposition,
                "cleanup": cleanup,
                "conflicts": conflicts,
                "classification": classification,
                "phases": phases,
            },
        )

    print(json.dumps(with_writer(directory, "settle", step), indent=2))
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
        return "accepted-finite-sample"
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
        "settle", help="record one slot's terminal result"
    )
    settle_parser.add_argument("directory", type=Path)
    settle_parser.add_argument("slot", choices=SLOT_NAMES)
    settle_parser.add_argument("phases", type=Path)
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
            return settle(
                cast(Path, args.directory),
                cast(str, args.slot),
                cast(Path, args.phases),
            )
        return report(cast(Path, args.directory))
    except Refusal as error:
        print(f"refused: {error}", file=sys.stderr)
        return 3


if __name__ == "__main__":
    sys.exit(main())
