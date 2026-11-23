#!/usr/bin/env python3
"""Disable one containment guard at a time and run its named control.

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
SUITE = "Tests/scripts/vm-settings-containment.bats"
# (name, exact source text, replacement, control filter)
MUTATIONS = (
    (
        "override-refusal",
        "    if present:\n",
        "    if False:\n",
        "keep, display or trace",
    ),
    (
        "declared-base",
        "KOINE_VM_BASE=BASE,",
        'KOINE_VM_BASE="other-base",',
        "passes the declared clone",
    ),
    (
        "recorded-group",
        "start_new_session=True,\n                )\n        except OSError as error:\n            os.close(write_end)",
        "start_new_session=False,\n                )\n        except OSError as error:\n            os.close(write_end)",
        "runs its declared entry once",
    ),
    (
        "gate-withhold",
        "if not self.received:\n                os.write",
        "if True:\n                os.write",
        "signal before the gate",
    ),
    (
        "exit-watch",
        "if not self.released or self.exits is None:",
        "if False:",
        "failed exit watch",
    ),
    (
        "signal-forward",
        'self.signal_group(process.pid, "signal-forwarded", self.received[0])',
        "pass",
        "a signal reaches the recorded group",
    ),
    ("holder-end", "members = self.end_group(group)\n", "pass\n", "stuck owned holder"),
    (
        "stop-escalation",
        'self.end_group(process.pid, f"{operation}-")',
        'self.signal_group(process.pid, f"{operation}-group-term", signal.SIGTERM)',
        "timed-out stop whose CLI",
    ),
    ("lock-test", "if free is not True:", "if False:", "holder outside the group"),
    (
        "holder-blocks-stop",
        'if holder["result"] == "unresolved":',
        "if False:",
        "holder outside the group",
    ),
    (
        "stop-needs-start",
        'if requested:\n            self.action("stop-sent"',
        'if True:\n            self.action("stop-sent"',
        "ends before its start",
    ),
    (
        "start-evidence",
        'starts = [a for a in attempts if a["operation"] == "vm-start"]',
        "starts = []",
        "failed start keeps",
    ),
    (
        "frozen-class",
        "return record_settlement(sequence, slot, phases, classification)",
        'return record_settlement(sequence, slot, phases, classify_root(Path(cast(str, sequence.slots[slot]["evidence_root"])), cast(str, sequence.slots[slot]["set"]), cast(str, sequence.slots[slot]["clone"])))',
        "complete run keeps its classification",
    ),
    (
        "stop-result",
        'if outcome == "clean" and status == 0:',
        "if True:",
        "nonzero stop",
    ),
    ("late-result", "return None, True", "return 0, False", "stop that outlasts"),
    (
        "strict-exit",
        'return None, "malformed"',
        'return 0, "malformed"',
        "malformed scenario",
    ),
    (
        "pointer-gap",
        "if any(ORDINAL_GAP in entry for entry in unfinished)\n        else pointer_state",
        "if False\n        else pointer_state",
        "missing receipt",
    ),
    (
        "held-record",
        '"held_input": classification["pointer"],',
        '"held_input": "none",',
        "clean down without",
    ),
    (
        "cleanup-needs-inventory",
        'if inventory == "passed" and stop == "not-run":',
        'if stop == "not-run":',
        "holder outside the group",
    ),
    (
        "live-run-guard",
        "if run_is_live(sequence.directory):",
        "if False:",
        "manual settle",
    ),
    (
        "refusal-record",
        "refusals = read_refusals(self.root)",
        "refusals = []",
        "each refused",
    ),
    (
        "manifest-digest",
        "files.append(digest_regular(path))",
        'files.append({"path": str(path)})',
        "manifest digests",
    ),
    (
        "inventory-read",
        "return stop, self.attempt_result(INVENTORY_OPERATION, status, late), created",
        'return stop, {**idle, **phase("passed", "mutated")}, created',
        "clone still listed",
    ),
)


def run_control(copy: Path, control: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["bats", "-f", control, SUITE],
        cwd=copy,
        capture_output=True,
        text=True,
        check=False,
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
            for part in ("scripts", "Tests/scripts"):
                shutil.copytree(repository / part, copy / part)
            # The same control must pass on the same copy before the mutation.
            baseline = run_control(copy, control)
            baseline_passed = baseline.returncode == 0 and "\nok " in baseline.stdout
            mutated = source.replace(old, new)
            (copy / TOOL).write_text(mutated)
            run = run_control(copy, control)
        detected = baseline_passed and run.returncode != 0 and "not ok" in run.stdout
        survived += not detected
        records.append(
            json.dumps(
                {
                    "mutation": name,
                    "control": control,
                    "baseline_passed": baseline_passed,
                    "detected": detected,
                    "status": run.returncode,
                    "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
                    "mutated_sha256": hashlib.sha256(mutated.encode()).hexdigest(),
                }
            )
        )
        print(f"{name}: {'detected' if detected else 'SURVIVED'}", flush=True)
    output.write_text("\n".join(records) + "\n")
    return 1 if survived else 0


if __name__ == "__main__":
    sys.exit(main())
