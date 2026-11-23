#!/usr/bin/env python3
"""Disable one audit guard at a time and run its named control.

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
SUITE = "Tests/scripts/vm-settings-audits.bats"
# (name, exact source text, replacement, control filter)
MUTATIONS = (
    (
        "compare-changed",
        "path for path in wanted.keys() & seen.keys() if wanted[path] != seen[path]",
        "path for path in wanted.keys() & seen.keys() if False",
        "a changed input item before",
    ),
    (
        "compare-extra",
        '"extra": sorted(seen.keys() - wanted.keys()),',
        '"extra": [],',
        "an extra input item before",
    ),
    (
        "compare-missing",
        '"missing": sorted(wanted.keys() - seen.keys()),',
        '"missing": [],',
        "a missing input item before",
    ),
    (
        "unread-not-missing",
        'name == "." or path == name or path.startswith(f"{name}/")',
        "False",
        "unreadable input directory",
    ),
    (
        "failed-read-unavailable",
        'return "unavailable" if errors else "passed"',
        'return "passed"',
        "unreadable input before",
    ),
    (
        "hold-record",
        'sequence.append("held", {"slot": slot, "audit": results})',
        "pass",
        "held sequence refuses",
    ),
    (
        "hold-stops",
        'if self.held is not None:\n            return cast(str, self.held["slot"])',
        "if False:\n            return None",
        "held sequence refuses",
    ),
    (
        "receipt-digest",
        "if identity != receipt:",
        "if False:",
        "changed after readiness",
    ),
    (
        "receipt-schema",
        'if problem is not None:\n        raise Refusal(f"the receipt holds',
        'if False:\n        raise Refusal(f"the receipt holds',
        "without a frozen declaration",
    ),
    (
        "item-path",
        'if path != "." and ("" in parts or "." in parts or ".." in parts):',
        "if False:",
        "path outside its root",
    ),
    (
        "ordinary-same",
        '"receipt": "passed" if loaded["same"] else "failed",',
        '"receipt": "passed",',
        "ordinary receipt that differs",
    ),
    (
        "golden-before-a01",
        'if slot == "A01":',
        "if False:",
        "golden item that changes before A01",
    ),
    (
        "golden-only-a01",
        'if slot == "A01":',
        "if True:",
        "an E slot does not read",
    ),
    (
        "close-needed",
        'if sequence.closed is None:\n            return "awaiting-golden-audit"',
        'if sequence.closed is None:\n            return "accepted-finite-sample"',
        "five clean slots wait",
    ),
    (
        "close-result",
        'if golden["result"] == "passed"\n            else "no-acceptance"',
        'if True\n            else "no-acceptance"',
        "changes after A01",
    ),
    (
        "close-unsettled",
        "if self.stopped() is None and len(self.settled) != len(SLOT_NAMES):",
        "if False:",
        "close refuses while",
    ),
    (
        "host-after",
        'after = [audit_tree(tree) for tree in cast(list[Json], self.frozen["inputs"])]',
        'after = cast(list[Json], self.before["inputs"])',
        "an input that changes during",
    ),
    (
        "installed-frozen",
        "comparison = compare_items(expected, installed_items(record))",
        "comparison = compare_items(installed_items(record), installed_items(record))",
        "differs from the frozen bundle",
    ),
    (
        "installed-after-read",
        '"installed": self.read_guest(INSTALLED_READ, "installed-inventory"),',
        '"installed": (receipt_record(self.root, INSTALLED_BEFORE), phase("passed", "m")),',
        "guest file that changes",
    ),
    (
        "reads-before-stop",
        "guest = self.read_guest_state(requested, uncertain, holder)\n        stop, inventory, created = self.contain(requested, holder)",
        "stop, inventory, created = self.contain(requested, holder)\n        guest = self.read_guest_state(requested, uncertain, holder)",
        "reads the installed bundle itself",
    ),
    (
        "no-guest-no-read",
        'elif not requested:\n            reason = "no start attempt"',
        'elif False:\n            reason = "no start attempt"',
        "no start attempt reads nothing",
    ),
    (
        "saved-artifact",
        'if (saved["bytes"], saved["sha256"]) != (size, digest):',
        "if False:",
        "saved artifact that differs",
    ),
    (
        "saved-stream",
        'if (attempt / f"guest.{name}").exists()',
        "if False",
        "saved guest stream",
    ),
    (
        "partial-kept",
        "partials.append(attempt.name)",
        "pass",
        "partial original stays",
    ),
    (
        "manifest-recheck",
        'if recheck["result"] != "passed" and phase_result(phases, "audit") == "passed":',
        "if False:",
        "retained file that changes before",
    ),
    (
        "system-compare",
        '"passed" if wanted == seen else "failed",',
        '"passed",',
        "different guest build",
    ),
    (
        "gatekeeper-compare",
        'same = gatekeeper.get("assessments") == declared["assessments"]',
        "same = True",
        "different Gatekeeper",
    ),
    (
        "process-compare",
        "different = sorted({row for row in rows if row != declared})",
        "different: list[str] = []",
        "injected process argument",
    ),
    (
        "process-needed",
        "if not rows:\n",
        "if False:\n",
        "no observed Koine process",
    ),
    (
        "process-read-failed",
        "problems.append(f\"{attempt['operation']} is {attempt['outcome']}\")",
        "pass",
        "cannot hide a later failed",
    ),
    (
        "defaults-compare",
        'elif defaults.get("diagnostics_disabled") is True:',
        "elif True:",
        "diagnostic key after the slot",
    ),
    (
        "defaults-read-failed",
        'if defaults is None:\n        defaults_check = check(defaults_phase["result"], str(defaults_phase["detail"]))',
        'if defaults is None:\n        defaults_check = check("passed", "mutated")',
        "failed defaults read",
    ),
    (
        "run-settles",
        '    print(json.dumps({"slot": slot, "state": AWAITING, "phases": phases}, indent=2))',
        '    settle_run(resolved, slot, phases, _)\n    print(json.dumps({"slot": slot, "state": AWAITING, "phases": phases}, indent=2))',
        "run stops before settlement",
    ),
    (
        "screenshot-phase",
        'phases["screenshots"] = phase(\n            cast(str, audit["result"]), cast(str, audit["detail"])\n        )',
        'phases["screenshots"] = phase("passed", "mutated")',
        "unpassed screenshot audit",
    ),
    (
        "screenshot-schema",
        'set(audit) != {"result", "detail"}\n        or audit["result"] not in RESULTS',
        "False",
        "refuses a malformed audit",
    ),
    (
        "manual-settle",
        'if (output / CONTAINMENT / "phases.json").exists():\n            raise Refusal(f"{slot} has collected phases, so use settle-run")',
        "pass",
        "manual settle cannot replace",
    ),
    (
        "audit-crash",
        "except (OSError, ValueError, KeyError, TypeError) as error:\n            # A malformed record",
        "except ZeroDivisionError as error:\n            # A malformed record",
        "malformed read record",
    ),
    (
        "bundle-directory",
        'return "its bundle must be a directory"',
        "pass",
        "bundle that is one file",
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
    for name, old, new, control in MUTATIONS:
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
