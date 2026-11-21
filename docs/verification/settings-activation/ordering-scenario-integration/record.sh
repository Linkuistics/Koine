#!/bin/bash
# Run one command and record it with the digests of its subjects.
# The subjects are every file that jj tracks in the working copy, digested
# before and after the run. The record goes to a scratch directory first, so
# writing it changes no subject. Run from the repository root.
# Usage: record.sh SCRATCH NAME COMMAND...
# It writes NAME (the transcript), NAME.subjects (the manifest before the run)
# and NAME.json (the summary) into SCRATCH.
set -euo pipefail
scratch="$1" name="$2"
shift 2
mkdir -p "${scratch}"
manifest() { jj file list | LC_ALL=C sort | tr '\n' '\0' | xargs -0 shasum -a 256; }
manifest >"${scratch}/${name}.subjects"
started="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
status=0
"$@" >"${scratch}/${name}" 2>&1 || status=$?
ended="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
manifest >"${scratch}/${name}.after"
python3 -I - "${scratch}" "${name}" "${started}" "${ended}" "${status}" "$@" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

scratch, name, started, ended, status, *command = sys.argv[1:]
root = pathlib.Path(scratch)


def entries(path: pathlib.Path) -> dict[str, str]:
    lines = path.read_text().splitlines()
    return {line[66:]: line[:64] for line in lines}


def digest(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def version(*argv: str) -> str:
    result = subprocess.run(argv, capture_output=True, text=True, check=False)
    return (result.stdout or result.stderr).strip().splitlines()[0]


before_path = root / f"{name}.subjects"
after_path = root / f"{name}.after"
before, after = entries(before_path), entries(after_path)
summary = {
    "command": command,
    "started": started,
    "ended": ended,
    "status": int(status),
    "output_sha256": digest(root / name),
    "subject_count": len(before),
    "before_manifest_sha256": digest(before_path),
    "after_manifest_sha256": digest(after_path),
    "changed_subjects": sorted(k for k in before.keys() & after.keys() if before[k] != after[k]),
    "added_files": sorted(after.keys() - before.keys()),
    "removed_files": sorted(before.keys() - after.keys()),
    "tools": {
        "bash": version("/bin/bash", "--version"),
        "bats": version("bats", "--version"),
        "jq": version("jq", "--version"),
        "python3": version("python3", "--version"),
        "shellcheck": version("shellcheck", "--version"),
        "shfmt": version("shfmt", "--version"),
        "task": version("task", "--version"),
        "jj": version("jj", "--version"),
    },
}
summary["subjects_unchanged"] = summary["before_manifest_sha256"] == summary["after_manifest_sha256"]
after_path.unlink()
(root / f"{name}.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k: summary[k] for k in ("status", "subject_count", "subjects_unchanged")}))
PY
