"""Apply one named mutation to an isolated copy and run the exec read suite there.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one repair. Its record names the control that must then fail.
"""

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

repo = Path.cwd()
BACKEND = "scripts/vm-guest-exec.py"
READS = "scripts/vm_exec_reads.py"
FACADE = "scripts/vm-exec-read-evidence-lib.sh"
MUTATIONS = {
    # Generic exec in the evidence class dispatches again.
    "M1-generic-evidence-exec": (
        BACKEND,
        '    if transport == "exec" and kind == "evidence":\n',
        "    if False:\n",
        "not ok 1 ",
    ),
    # The evidence class admits a read that writes guest state.
    "M2-evidence-admits-every-read": (
        READS,
        '    if kind == "evidence" and not read.evidence:\n',
        "    if False:\n",
        "not ok 2 ",
    ),
    # A descriptor with another path qualifies.
    "M3-descriptor-path-unchecked": (
        READS,
        '        and descriptor["path"] == "/graphql"\n',
        "",
        "not ok 5 ",
    ),
    # A checked read skips the exec fields, including timed_out.
    "M4-read-skips-exec-fields": (
        BACKEND,
        '    if transport in {"exec", "read"} and not (\n',
        '    if transport == "exec" and not (\n',
        "not ok 7 ",
    ),
    # Trailing whitespace that the agent strips is accepted.
    "M5-trailing-whitespace-accepted": (
        READS,
        "    if stdout != stdout.rstrip():\n",
        "    if False:\n",
        "not ok 8 ",
    ),
    # A failed poll read becomes a clean negative.
    "M6-failed-poll-read-is-negative": (
        FACADE,
        '    record="$(read_guest_exec "${root}" read-poll "${operation}" endpoint)" || return\n',
        '    record="$(read_guest_exec "${root}" read-poll "${operation}" endpoint)" || return 1\n',
        "not ok 11 ",
    ),
    # The login poll exhaustion becomes a state failure.
    "M7-login-exhaustion-latches": (
        FACADE,
        '    if [[ "${mode}" == launch ]]; then\n',
        "    if true; then\n",
        "not ok 12 ",
    ),
    # Identity and argument rows of different processes are joined.
    "M8-process-rows-unjoined": (
        READS,
        "        if first is None or second is None or first.group(1) != second.group(1):\n",
        "        if first is None or second is None:\n",
        "not ok 14 ",
    ),
    # A string value of the menu probe counts as disabled.
    "M9-probe-string-is-false": (
        READS,
        '        key == "KoineSettingsMenuProbe" and value is False for _, key, value in found\n',
        '        key == "KoineSettingsMenuProbe" for _, key, value in found\n',
        "not ok 17 ",
    ),
    # A symbolic-link row may precede a file row.
    "M10-inventory-order-unchecked": (
        READS,
        "        if file is not None and not links:\n",
        "        if file is not None:\n",
        "not ok 19 ",
    ),
    # codesign's argument-error status counts as clean data.
    "M11-codesign-status-2-clean": (
        READS,
        '    status, text = status_parse(stdout, "KOINE-CODESIGN-STATUS", {0, 1})\n',
        '    status, text = status_parse(stdout, "KOINE-CODESIGN-STATUS", {0, 1, 2})\n',
        "not ok 21 ",
    ),
}
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
    ["bats", str(work / "Tests/scripts/vm-exec-read-evidence.bats")],
    capture_output=True,
    text=True,
)
failed = [line for line in run.stdout.splitlines() if line.startswith("not ok")]
print(
    json.dumps(
        {
            "mutation": name,
            "file": target,
            "replace": old,
            "with": new,
            "mutated_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "exit": run.returncode,
            "expected": expected.strip(),
            "expected_failed": any(line.startswith(expected) for line in failed),
            "failed": failed,
        }
    )
)
