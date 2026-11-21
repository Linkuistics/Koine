"""Apply one named k154 mutation to an isolated copy and run both read suites.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one k154 repair. Its record names the control that must then fail.
The host suite runs real commands on this Mac and needs /Applications/Koine.app.
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
    "Tests/scripts/vm-exec-read-evidence.bats",
    "Tests/scripts/vm-exec-read-host.bats",
)
MUTATIONS = {
    # A selected process without ps rows is dropped from a clean record.
    "M12-selection-unchecked": (
        READS,
        '    if {entry["pid"] for entry in processes} != set(selected):\n',
        "    if False:\n",
        [
            "a selected process missing from the ps rows makes the process read unavailable",
            "a selected process that exits before ps makes the real process read unavailable",
        ],
    ),
    # Two incarnations of one PID join.
    "M13-start-unjoined": (
        READS,
        "        if first.group(2) != second.group(2):\n",
        "        if False:\n",
        ["process rows with two start times are two incarnations and stay unavailable"],
    ),
    # The command keeps its grammar but reads no any-user domain.
    "M14-any-user-unread": (
        READS,
        """        'printf \\'KOINE-ANY-USER %s\\\\n\\' "$p"; defaults export "$p" -; done; '\n""",
        """        'printf \\'KOINE-ANY-USER %s\\\\n\\' "$p"; defaults export /nonexistent/k154 -; done; '\n""",
        ["an any-user diagnostic default reaches the real defaults read"],
    ),
    # An any-user section may name another path.
    "M15-any-user-header-unchecked": (
        READS,
        '            if (kind, subject) != ("KOINE-ANY-USER", ANY_USER[position - 8]):\n',
        "            if False:\n",
        ["a malformed defaults answer is unavailable, never absence"],
    ),
    # Raw control characters reach the XML parser.
    "M16-control-characters-raw": (
        READS,
        '        text = FORBIDDEN_XML.sub("\\ufffd", "\\n".join(rows[index : end + 1]))\n',
        '        text = "\\n".join(rows[index : end + 1])\n',
        ["raw control characters in a preference string do not hide a diagnostic key"],
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
