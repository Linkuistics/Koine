#!/usr/bin/env python3
"""Show that each decision of the declaration guard has a failing control.

Each case changes one decision in a private copy of the tool and runs the
declaration controls there. The unchanged copy must pass. Each mutation must
fail at least one control.

Usage: guard-mutations.py REPOSITORY WORK_DIRECTORY
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

TOOL = "scripts/settings-ordering-sequence.py"
SUITE = "Tests/scripts/vm-settings-sequence.bats"
# The control on this repository's own paths needs the real tree.
FILTER = "a declaration (refuses a|accepts)"
MUTATIONS = {
    "unchanged": None,
    "ignore a tracked path": (
        '        if tracked:\n            return f"Git tracks',
        '        if False:\n            return f"Git tracks',
    ),
    "ignore a jj tracked path": (
        '            if tracked:\n                return f"jj tracks',
        '            if False:\n                return f"jj tracks',
    ),
    "accept an unignored path": (
        '        if status == 1:\n            return f"this path',
        '        if False:\n            return f"this path',
    ),
    "accept unreadable ignore rules": (
        '        if status != 0:\n            return f"Git cannot read the ignore',
        '        if False:\n            return f"Git cannot read the ignore',
    ),
    "accept an unreadable index": (
        '        if status != 0:\n            return f"Git cannot read the index',
        '        if False:\n            return f"Git cannot read the index',
    ),
    "accept an unreadable jj working copy": (
        '            if status != 0:\n                return f"jj cannot read',
        '            if False:\n                return f"jj cannot read',
    ),
    "accept a jj tree with no Git view": (
        '        if not has_git:\n            return f"the jj',
        '        if not has_git:\n            continue\n            return f"the jj',
    ),
    "check only the innermost tree": (
        '            return f"Git cannot read the ignore rules of {root}"\n    return None',
        '            return f"Git cannot read the ignore rules of {root}"\n        return None\n    return None',
    ),
    "keep the unresolved parent": (
        "target = absolute.parent.resolve(strict=True) / absolute.name",
        "target = absolute",
    ),
    "drop the directory slash": ('f"./{relative}/"', 'f"./{relative}"'),
    "skip the guard": (
        '    if problem is not None:\n        raise Refusal(f"the sequence directory could',
        '    if False:\n        raise Refusal(f"the sequence directory could',
    ),
}


def main() -> int:
    repo, work = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    work.mkdir()
    source = (repo / TOOL).read_text()
    results: dict[str, object] = {}
    for index, (name, change) in enumerate(MUTATIONS.items()):
        copy = work / f"m{index:02d}"
        (copy / "scripts").mkdir(parents=True)
        (copy / "Tests/scripts").mkdir(parents=True)
        shutil.copy(repo / SUITE, copy / SUITE)
        shutil.copytree(
            repo / "Tests/scripts/fixtures", copy / "Tests/scripts/fixtures"
        )
        text = source
        if change is not None:
            if text.count(change[0]) != 1:
                raise SystemExit(f"{name}: the mutation site is not unique")
            text = text.replace(*change)
        (copy / TOOL).write_text(text)
        done = subprocess.run(
            ["bats", "--tap", "-f", FILTER, str(copy / SUITE)],
            capture_output=True,
            text=True,
            timeout=240,
            check=False,
        )
        lines = done.stdout.splitlines()
        failed = [line.split(" ", 3)[3] for line in lines if line.startswith("not ok")]
        passed = sum(1 for line in lines if line.startswith("ok "))
        results[name] = {"status": done.returncode, "passed": passed, "failed": failed}
    print(json.dumps(results, indent=1))
    clean = results["unchanged"]
    good = clean["status"] == 0 and clean["passed"] > 0  # type: ignore[index]
    red = all(item["failed"] for key, item in results.items() if key != "unchanged")  # type: ignore[index]
    return 0 if good and red else 1


if __name__ == "__main__":
    sys.exit(main())
