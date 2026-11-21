"""Digest every working-copy file, run one command once, then digest again.

Usage: python3 measure.py OUTPUT -- COMMAND...

The subjects are every tracked file and every untracked file that Git does not
ignore, from `git ls-files --cached --others --exclude-standard`. The command
output goes to OUTPUT. OUTPUT.json keeps the command, the exit status, the tool
versions, the subject count and a digest of each subject manifest. OUTPUT.subjects
keeps the complete manifest from before the run. Ignored build outputs and caches
are not subjects. OUTPUT and its two companions are excluded, because this
script writes them.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

TOOLS = {
    "bats": ["bats", "--version"],
    "jq": ["jq", "--version"],
    "python3": ["python3", "--version"],
    "shellcheck": ["shellcheck", "--version"],
    "shfmt": ["shfmt", "--version"],
    "task": ["mise", "exec", "--", "task", "--version"],
    "git": ["git", "--version"],
}


def now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def listing(excluded: set[str]) -> list[str]:
    raw = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        check=True,
        capture_output=True,
    ).stdout.decode()
    return sorted({name for name in raw.split("\0") if name and name not in excluded})


def entry(name: str) -> str:
    path = Path(name)
    if path.is_symlink():
        return f"link:{os.readlink(path)}  {name}"
    if not path.exists():
        return f"absent  {name}"
    if path.is_dir():
        return f"directory  {name}"
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return f"{digest.hexdigest()}  {name}"


def manifest(names: list[str]) -> list[str]:
    return [entry(name) for name in names]


def version(argv: list[str]) -> str:
    try:
        result = subprocess.run(argv, capture_output=True, text=True, check=False)
    except OSError as error:
        return f"unavailable: {error}"
    text = (result.stdout or result.stderr).strip().splitlines()
    return text[0] if text else f"exit {result.returncode}"


def main() -> int:
    output = Path(sys.argv[1])
    command = sys.argv[2:]
    if command[:1] == ["--"]:
        command = command[1:]
    relative = os.path.relpath(output.absolute(), Path.cwd())
    excluded = {relative, relative + ".json", relative + ".subjects"}
    names = listing(excluded)
    before = manifest(names)
    Path(relative + ".subjects").write_text("".join(f"{line}\n" for line in before))
    started = now()
    with output.open("xb") as stream:
        status = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT, check=False)
    ended = now()
    after = manifest(names)
    names_after = listing(excluded)
    changed = [b for b, a in zip(before, after, strict=True) if a != b]
    record = {
        "command": command,
        "started": started,
        "ended": ended,
        "status": status.returncode,
        "output_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "subject_count": len(names),
        "before_manifest_sha256": hashlib.sha256("\n".join(before).encode()).hexdigest(),
        "after_manifest_sha256": hashlib.sha256("\n".join(after).encode()).hexdigest(),
        "changed_subjects": changed,
        "added_files": sorted(set(names_after) - set(names)),
        "removed_files": sorted(set(names) - set(names_after)),
        "tools": {name: version(argv) for name, argv in TOOLS.items()},
    }
    record["subjects_unchanged"] = not (
        changed or record["added_files"] or record["removed_files"]
    )
    Path(relative + ".json").write_text(json.dumps(record, indent=2) + "\n")
    return status.returncode


if __name__ == "__main__":
    sys.exit(main())
