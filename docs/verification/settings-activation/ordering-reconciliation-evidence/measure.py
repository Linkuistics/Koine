#!/usr/bin/env python3
"""Run the affected checks once, between two digests of every tracked file.

The receipt excludes only its own three output files. Usage: measure.py REPOSITORY
"""

# pyright: strict
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path

CHECKS = (
    "check:vm-exec-one-shot-evidence",
    "check:vm-exec-one-shot-host",
    "check:vm-sysevents-evidence",
    "check:vm-sysevents-host",
    "check:vm-exec-read-evidence",
    "check:vm-exec-read-host",
    "check:vm-file-lifecycle-evidence",
    "check:vm-guest-exec",
    "check:vm-capture-evidence",
    "check:vm-window-evidence",
    "check:vm-input-evidence",
    "check:vm-ui-evidence",
    "check:vm-click-evidence",
    "check:vm-physical-evidence",
    "check:vm-menu-pointer",
    "check:vm-verify-start",
    "check:vm-window-resize",
    "check:vm-settings-scenario",
    "check:vm-settings-prefix",
    "check:vm-settings-sequence",
    "check:vm-settings-containment",
    "check:vm-settings-audits",
    "check:settings-duty-ledger",
)
EVIDENCE = "docs/verification/settings-activation/ordering-reconciliation-evidence"
OUTPUTS = {
    f"{EVIDENCE}/final-verification.txt",
    f"{EVIDENCE}/final-verification.txt.json",
    f"{EVIDENCE}/final-verification.txt.subjects",
}


def subjects(repository: Path) -> dict[str, str]:
    names = subprocess.run(
        ["jj", "file", "list", "--no-pager"],
        cwd=repository,
        capture_output=True,
        text=True,
        check=True,
    ).stdout.splitlines()
    return {
        name: hashlib.sha256((repository / name).read_bytes()).hexdigest()
        for name in sorted(names)
        if name not in OUTPUTS and (repository / name).is_file()
    }


def main() -> int:
    repository = Path(sys.argv[1]).resolve()
    before = subjects(repository)
    started = datetime.now(UTC).isoformat()
    transcript: list[str] = []
    statuses: dict[str, int] = {}
    for check in CHECKS:
        run = subprocess.run(
            ["mise", "exec", "--", "task", check],
            cwd=repository,
            capture_output=True,
            text=True,
            check=False,
        )
        statuses[check] = run.returncode
        transcript += [
            f"$ task {check}",
            run.stdout,
            run.stderr,
            f"status {run.returncode}",
        ]
    after = subjects(repository)
    text = "\n".join(transcript) + "\n"
    output = repository / EVIDENCE / "final-verification.txt"
    output.write_text(text)
    listing = "".join(f"{digest}  {name}\n" for name, digest in before.items())
    output.with_name(output.name + ".subjects").write_text(listing)
    changed = sorted(n for n in before.keys() & after.keys() if before[n] != after[n])
    receipt = {
        "started": started,
        "ended": datetime.now(UTC).isoformat(),
        "statuses": statuses,
        "subject_count": len(before),
        "subjects_unchanged": before == after,
        "changed_subjects": changed,
        "added_files": sorted(after.keys() - before.keys()),
        "removed_files": sorted(before.keys() - after.keys()),
        "output_sha256": hashlib.sha256(text.encode()).hexdigest(),
    }
    output.with_name(output.name + ".json").write_text(
        json.dumps(receipt, indent=2) + "\n"
    )
    print(json.dumps(receipt, indent=2))
    return 0 if before == after and not any(statuses.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
