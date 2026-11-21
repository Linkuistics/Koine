"""Apply one named k158 mutation to an isolated copy and run both k152 suites.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one part of the k158 identity decision. Its record names the controls
that must then fail. The fake_libproc controls run the real identity script
with a fake libSystem. No guest or Koine process is involved.
"""

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

repo = Path.cwd()
READS = "scripts/vm_exec_reads.py"
SUITES = (
    "Tests/scripts/vm-exec-one-shot-evidence.bats",
    "Tests/scripts/vm-exec-one-shot-host.bats",
)
UNAVAILABLE = "a path read that fails with ESRCH while the process lives makes the identity unavailable"
ABSENT = "the identity script reports an absent process only from a process-info read"
MUTATIONS = {
    # A failed path read gives no process, as before k158.
    "N01-path-gates-process": (
        READS,
        "if first is not None and second is not None:\n",
        "if first is not None and executable is not None and second is not None:\n",
        [UNAVAILABLE],
    ),
    # A live process with no path reaches the record. The parser refuses the
    # record, but the script status is no longer the distinct status 7.
    "N02-no-status-7": (
        READS,
        "    if executable is None:\n        sys.exit(7)\n",
        "",
        [UNAVAILABLE],
    ),
    # Any failed process-info read becomes an absent process.
    "N03-any-info-error-absent": (
        READS,
        "    if size <= 0 and ctypes.get_errno() == errno.ESRCH:\n",
        "    if size <= 0:\n",
        [UNAVAILABLE],
    ),
    # Only the first process-info read can report the absence.
    "N04-first-read-only": (
        READS,
        "if first is not None and second is not None:\n",
        "if first is not None:\n",
        [ABSENT],
    ),
}


def failed_name(line: str) -> str:
    # "not ok 7 name" -> "name"
    return line.split(" ", 3)[3] if line.count(" ") >= 3 else line


name = sys.argv[1]
target, old, new, expected = MUTATIONS[name]
work = Path(sys.argv[2]) / name
shutil.rmtree(work, ignore_errors=True)
for part in ("scripts", "Tests/scripts"):
    shutil.copytree(repo / part, work / part, symlinks=True)
path = work / target
text = path.read_text()
assert text.count(old) == 1, (name, text.count(old))
path.write_text(text.replace(old, new))
run = subprocess.run(
    ["bats", *(str(work / suite) for suite in SUITES)],
    check=False,
    capture_output=True,
    text=True,
    cwd=work,
)
failed = [line for line in run.stdout.splitlines() if line.startswith("not ok")]
names = {failed_name(line) for line in failed}
print(
    json.dumps(
        {
            "mutation": name,
            "file": target,
            "replace": old,
            "with": new,
            "mutated_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "exit": run.returncode,
            "expected": expected,
            "expected_failed": all(control in names for control in expected),
            "failed": failed,
        }
    )
)
