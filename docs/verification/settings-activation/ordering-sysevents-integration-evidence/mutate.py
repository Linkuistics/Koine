"""Apply one named k156 mutation to an isolated copy and run both k151 suites.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one part of the k156 absence-message guard. Its record names the
controls that must then fail. The host suite runs real osascript on literals.
No Apple event reaches System Events.
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
    "Tests/scripts/vm-sysevents-evidence.bats",
    "Tests/scripts/vm-sysevents-host.bats",
)
DENIED = [
    "a denied or unformatted error with an absence number is unavailable in every poll",
    "a denied label read stops the label poll at once and consumes no negative step",
    "a denied item frame read stops the item frame poll at once and consumes no negative step",
    "a denied row frame read stops the row frame poll at once and consumes no negative step",
    "a real denial with an absence number is unavailable in every poll",
]
MUTATIONS = {
    # The number alone makes an absence, as before k156.
    "K01-number-only": (
        READS,
        "            if ABSENCE_MESSAGES[number].fullmatch(error.group(1)) is None:\n",
        "            if False:\n",
        DENIED,
    ),
    # The message need not come from System Events.
    "K03-no-attribution": (
        READS,
        '        r"System Events got an error: Can’t get \\S[^\\n]*\\. Invalid index\\."\n',
        '        r"(?:System Events got an error: )?Can’t get \\S[^\\n]*\\. Invalid index\\."\n',
        [DENIED[0]],
    ),
    # -1728 accepts the -1719 suffix.
    "K04-suffix-unpaired": (
        READS,
        '        r"System Events got an error: Can’t get \\S[^\\n]*(?<! Invalid index)\\."\n',
        '        r"System Events got an error: Can’t get \\S[^\\n]*\\."\n',
        [DENIED[0]],
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
