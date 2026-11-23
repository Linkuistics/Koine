#!/usr/bin/env python3
"""Compare the Settings classifier before and after the k174 repair.

Usage: interrupted-outcome-differential.py BEFORE AFTER

The script enumerates each order of up to three attempts over a fixed set of
operations and outcomes. Each order runs with a plain, a latched and a refused
root, for both slot sets. Only one change is allowed: the kind moves from
`unavailable` to `interrupted` when the first essential failure is an
`interrupted` receipt and no signal record exists. Each changed case must also
settle `unresolved` with no conflict, for each status in a fixed grid.

The script starts no clone, and it establishes no native behaviour.
"""

from __future__ import annotations

import hashlib
import importlib.util
import itertools
import json
import sys
import tempfile
from pathlib import Path
from types import ModuleType
from typing import Any

Json = dict[str, Any]

OPERATIONS = (
    "first-selection-identity",
    "resize-down-1",
    "resize-hold-1-wait",
    "failure-capture",
    "scenario-signal-TERM",
    "scenario-assertion-menu-open",
    "scenario-assertion-not-front",
    "restart-boot-exhausted",
    "reopen-1-window-exhausted",
    "installed-after",
    "textedit-quit-absence-state",
)
OUTCOMES = ("clean", "state-failed", "unavailable", "interrupted", "partial")
SLOT_SETS = ("focused", "ordinary")
LONGEST = 3
SCENARIO_STATUSES = (None, 0, 1, 125, 130, 143)
TASK_STATUSES = (None, 0, 201)
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


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise SystemExit(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def make_roots(base: Path) -> list[Path]:
    roots = [base / name for name in ("plain", "latched", "refused")]
    for root in roots:
        root.mkdir()
        (root / "subject.json").write_text('{"vm": "exact-clone"}\n')
    (roots[1] / "unavailable").write_text("control\n")
    record = {"arguments": ["fail", "root", "scenario-signal-TERM"]}
    (roots[2] / "refusals.jsonl").write_text(json.dumps(record) + "\n")
    return roots


def attempt_choices() -> list[tuple[object, str]]:
    choices: list[tuple[object, str]] = [
        (operation, outcome) for operation in OPERATIONS for outcome in OUTCOMES
    ]
    choices.append((None, "partial"))
    return choices


def build(case: tuple[tuple[object, str], ...]) -> tuple[list[Json], list[str]]:
    attempts: list[Json] = []
    unfinished: list[str] = []
    for index, (operation, outcome) in enumerate(case, 1):
        ordinal = f"{index:06d}"
        attempts.append(
            {"ordinal": ordinal, "operation": operation, "outcome": outcome}
        )
        if outcome == "partial":
            unfinished.append(f"{ordinal}: control")
    return attempts, unfinished


def phase_grid() -> list[Json]:
    grid: list[Json] = []
    for scenario, task, collection in itertools.product(
        SCENARIO_STATUSES, TASK_STATUSES, ("passed", "failed")
    ):
        phases: Json = {
            name: {"result": "passed", "detail": "control"} for name in RESULT_PHASES
        }
        phases["collection"] = {"result": collection, "detail": "control"}
        phases["scenario"] = {"status": scenario}
        phases["task"] = {"status": task}
        grid.append(phases)
    return grid


def repair_applies(module: ModuleType, attempts: list[Json], result: Json) -> bool:
    if result["class"] is not None or result["signals"] or result["blockers"]:
        return False
    essential = [
        attempt
        for attempt in attempts
        if attempt["outcome"] != "clean"
        and not module.is_supplemental(attempt["operation"])
    ]
    return bool(essential) and essential[0]["outcome"] == "interrupted"


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    paths = [Path(sys.argv[1]), Path(sys.argv[2])]
    before, after = load("sequence_before", paths[0]), load("sequence_after", paths[1])
    grid = phase_grid()
    current: list[tuple[list[Json], list[str]]] = [([], [])]

    def read_current(_root: Path) -> tuple[list[Json], list[str]]:
        attempts, unfinished = current[0]
        return [dict(attempt) for attempt in attempts], list(unfinished)

    before.read_attempts = read_current
    after.read_attempts = read_current
    total = changed = 0
    violations: list[str] = []
    settled: set[tuple[object, object, object]] = set()
    choices = attempt_choices()
    with tempfile.TemporaryDirectory() as directory:
        roots = make_roots(Path(directory))
        for length in range(LONGEST + 1):
            for case in itertools.product(choices, repeat=length):
                current[0] = build(case)
                for root, slot_set in itertools.product(roots, SLOT_SETS):
                    total += 1
                    old = before.classify_root(root, slot_set, "exact-clone")
                    new = after.classify_root(root, slot_set, "exact-clone")
                    applies = repair_applies(before, current[0][0], old)
                    if not applies:
                        if old != new:
                            violations.append(f"unexpected change: {case} {root.name}")
                        continue
                    changed += 1
                    expected = {**old, "kind": "interrupted"}
                    if old["kind"] != "unavailable" or new != expected:
                        violations.append(f"wrong change: {case} {root.name}")
                        continue
                    key = (new["kind"], new["class"], new["pointer"])
                    if key in settled:
                        continue
                    settled.add(key)
                    for phases in grid:
                        for module, record in ((before, old), (after, new)):
                            if module.decide(record, phases) != ("unresolved", []):
                                violations.append(f"settlement: {case} {phases}")
    for path in paths:
        print(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}")
    print(f"cases {total}")
    print(f"changed {changed}")
    print(f"unchanged {total - changed}")
    print(f"violations {len(violations)}")
    for violation in violations[:5]:
        print(violation)
    return 1 if violations or not changed else 0


if __name__ == "__main__":
    raise SystemExit(main())
