"""Apply one named k152 mutation to an isolated copy and run both k152 suites.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one guard of the checked one-shot submissions or their confirmations.
Its record names the controls that must then fail. The host suite runs the real
identity read against a host process. No submission runs on the host.
"""

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

repo = Path.cwd()
READS = "scripts/vm_exec_reads.py"
LIB = "scripts/vm-exec-one-shot-evidence-lib.sh"
SUITES = (
    "Tests/scripts/vm-exec-one-shot-evidence.bats",
    "Tests/scripts/vm-exec-one-shot-host.bats",
)
MUTATIONS = {
    # A submission accepts any stdout.
    "M01-any-stdout": (
        READS,
        "        if stdout != clean:\n",
        "        if False:\n",
        ["other stdout from a submission is unavailable"],
    ),
    # A submission also admits the read-poll class.
    "M02-read-poll-submission": (
        READS,
        '        if kind != "one-shot":\n',
        '        if kind not in {"one-shot", "read-poll"}:\n',
        ["submissions admit only the one-shot class and take no arguments"],
    ),
    # The boot poll runs after a failed restart submission.
    "M03-restart-continues": (
        LIB,
        '    submit_guest_once "${root}" "${operation}" restart >/dev/null || return\n',
        '    submit_guest_once "${root}" "${operation}" restart >/dev/null || :\n',
        ["a failed restart submission is unavailable even if the boot later changes"],
    ),
    # The absence read runs after a failed TextEdit quit.
    "M04-quit-continues": (
        LIB,
        '    submit_guest_once "$1" "$2" quit-textedit >/dev/null || return\n',
        '    submit_guest_once "$1" "$2" quit-textedit >/dev/null || :\n',
        ["a failed TextEdit quit reads nothing, and an absence cannot make it clean"],
    ),
    # The descriptor's process need only be one of the selected processes.
    "M05-selection-unjoined": (
        READS,
        '        and selected == [descriptor["pid"]]\n',
        '        and descriptor["pid"] in selected\n',
        [
            "a stale descriptor, a second process or another executable is a clean mismatch"
        ],
    ),
    # Any executable named Koine joins.
    "M06-executable-name-only": (
        READS,
        '        and cast(dict[str, object], process)["executable"] == EXECUTABLE\n',
        '        and cast(str, cast(dict[str, object], process)["executable"]).endswith("/Koine")\n',
        [
            "a stale descriptor, a second process or another executable is a clean mismatch"
        ],
    ),
    # The reopen compares the instance only.
    "M07-reopen-instance-only": (
        LIB,
        '        ".present and .joined and ({instance: .descriptor.instanceId, process} == ${before})" \\\n',
        '        ".present and .joined and (.descriptor.instanceId == (${before}).instance)" \\\n',
        ["a reopen keeps the same process: instance, PID, start and executable"],
    ),
    # The restart wait differs from the existing 30 seconds.
    "M08-wait-changed": (
        LIB,
        "    sleep 30 || sleep_status=$?\n",
        "    sleep 20 || sleep_status=$?\n",
        [
            "the restart waits 30 seconds and polls the boot five seconds apart until it changes"
        ],
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
