#!/usr/bin/env python3
"""Disable one guard of the sequence tool at a time and run its named control.

Each mutation works in an isolated copy. A mutation that its control does not
detect makes this script exit 1. Usage: mutate.py REPOSITORY OUTPUT.jsonl
"""

# pyright: strict
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TOOL = "scripts/settings-ordering-sequence.py"
SUITE = "Tests/scripts/vm-settings-sequence.bats"
# (name, exact source text, replacement, control filter)
MUTATIONS = (
    (
        "first-failure-stop",
        'if record is not None and record.get("disposition") != "qualified":',
        "if False:",
        "first failure stops",
    ),
    (
        "slot-order",
        "if slot != expected:",
        "if False:",
        "admission takes only the next slot",
    ),
    (
        "ordinary-readiness",
        "if slot_set not in self.ready:",
        "if False:",
        "ordinary set needs both",
    ),
    (
        "one-writer",
        "fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)",
        "pass",
        "one writer",
    ),
    (
        "ledger-replay-decision",
        'if decided != (record["disposition"], record["conflicts"]):',
        "if False:",
        "hand-edited disposition",
    ),
    (
        "terminal-receipt",
        'attempts[-1]["operation"] == TERMINAL[slot_set]',
        "True",
        "stops before its terminal receipt",
    ),
    (
        "one-clean-click",
        "if len(clicks) != 1:",
        "if False:",
        "one clean click",
    ),
    (
        "gap-before-class",
        "entry[:6] <= ordinal",
        "False",
        "ordinal gap before",
    ),
    (
        "gap-after-class",
        "entry[:6] <= ordinal",
        "True",
        "failure after the class",
    ),
    (
        "screenshot-corroboration",
        'corroborated = phase_result(phases, "screenshots") == "passed"',
        "corroborated = True",
        "without a corroborating screenshot",
    ),
    (
        "exhausted-status",
        "expected = 1 if classification",
        "expected = 1 if True or classification",
        "exhausted poll keeps its status",
    ),
    (
        "every-phase",
        'all(phase_result(phases, name) == "passed" for name in RESULT_PHASES)',
        "True",
        "every phase and status",
    ),
    (
        "refused-signal",
        "] + refused",
        "]",
        "signal that met a held lock",
    ),
    (
        "unreadable-held-point",
        '# An unreadable request could be a held point or a release.\n            state = "uncertain"',
        "pass",
        "unreadable request",
    ),
    (
        "held-input",
        'classification["pointer"] in {"none", "released"}',
        "True",
        "held input prevents",
    ),
)


def main() -> int:
    repository, output = Path(sys.argv[1]).resolve(), Path(sys.argv[2])
    source = (repository / TOOL).read_text()
    survived = 0
    records: list[str] = []
    for name, old, new, control in MUTATIONS:
        if source.count(old) != 1:
            print(f"{name}: the source text occurs {source.count(old)} times")
            return 2
        with tempfile.TemporaryDirectory() as temporary:
            copy = Path(temporary) / "repo"
            for part in ("scripts", "Tests/scripts", "App"):
                shutil.copytree(repository / part, copy / part)
            # The same control must pass on the same copy before the mutation.
            baseline = subprocess.run(
                ["bats", "-f", control, SUITE],
                cwd=copy,
                capture_output=True,
                text=True,
                check=False,
            )
            baseline_passed = baseline.returncode == 0 and "\nok " in baseline.stdout
            mutated = source.replace(old, new)
            (copy / TOOL).write_text(mutated)
            run = subprocess.run(
                ["bats", "-f", control, SUITE],
                cwd=copy,
                capture_output=True,
                text=True,
                check=False,
            )
        ran = "not ok" in run.stdout or "\nok " in run.stdout
        detected = baseline_passed and run.returncode != 0 and "not ok" in run.stdout
        survived += not detected
        records.append(
            json.dumps(
                {
                    "mutation": name,
                    "control": control,
                    "baseline_passed": baseline_passed,
                    "control_ran": ran,
                    "detected": detected,
                    "status": run.returncode,
                    "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
                    "mutated_sha256": hashlib.sha256(mutated.encode()).hexdigest(),
                }
            )
        )
        print(f"{name}: {'detected' if detected else 'SURVIVED'}")
    output.write_text("\n".join(records) + "\n")
    return 1 if survived else 0


if __name__ == "__main__":
    sys.exit(main())
