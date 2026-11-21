"""Apply one named k151 mutation to an isolated copy and run both k151 suites.

Usage: python3 mutate.py NAME WORKDIR, from the repository root. Each mutation
disables one k151 guard. Its record names the controls that must then fail.
The host suite runs real osascript on literals and the real enrolment client
against a local stub. No Apple event reaches System Events.
"""

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

repo = Path.cwd()
READS = "scripts/vm_exec_reads.py"
LIB = "scripts/vm-sysevents-evidence-lib.sh"
SUITES = (
    "Tests/scripts/vm-sysevents-evidence.bats",
    "Tests/scripts/vm-sysevents-host.bats",
)
MUTATIONS = {
    # The default human-readable form replaces the source form.
    "S01-human-form": (
        READS,
        "osascript -s so -e",
        "osascript -s o -e",
        [
            "each read sends the legacy AppleScript in source form with script errors on stdout",
            "real osascript output parses for every System Events read",
        ],
    ),
    # Every read admits a clean absence.
    "S02-absence-everywhere": (
        READS,
        '    return name in {"menu-item-frame", "menu-row-frame"} or arguments == ["poll"]\n',
        "    return True\n",
        [
            "a clean absence is a negative only in the label and frame polls",
            "the Dock assertion reads item names, and a failed Dock read shows nothing",
            "real osascript errors are an absence only in a poll and unavailable elsewhere",
        ],
    ),
    # Every AppleScript error number is an absence.
    "S03-every-error-absent": (
        READS,
        "            if number not in ABSENT_ERRORS:\n",
        "            if False:\n",
        [
            "other AppleScript errors, statuses and malformed answers are unavailable",
            "a failed label read stops the poll at once and is never a negative",
            "real osascript errors are an absence only in a poll and unavailable elsewhere",
        ],
    ),
    # Any status other than 1 reads as a value.
    "S04-any-status": (
        READS,
        '        if not separator or status not in {"0", "1"}:\n',
        "        if not separator:\n",
        ["other AppleScript errors, statuses and malformed answers are unavailable"],
    ),
    # A value of another type passes.
    "S05-types-unchecked": (
        READS,
        "        if not SYSEVENTS_TYPES[name](value):\n",
        "        if False:\n",
        ["count, agent flag, label and front application keep their exact types"],
    ),
    # A string accepts an unknown escape.
    "S06-unknown-escape": (
        READS,
        "                    if escaped not in {'\"', \"\\\\\"}:\n",
        "                    if False:\n",
        ["other AppleScript errors, statuses and malformed answers are unavailable"],
    ),
    # System Events reads enter the evidence class.
    "S07-sysevents-evidence": (
        READS,
        '    return Read(command, parse, valid, False, "an Apple event can start System Events")\n',
        '    return Read(command, parse, valid, True, "an Apple event can start System Events")\n',
        ["System Events reads refuse the evidence class and the enrolment admits only one-shot"],
    ),
    # A row title of any characters reaches the guest command.
    "S08-row-title-open": (
        READS,
        'ROW_TITLE = re.compile("[A-Za-z0-9](?:[A-Za-z0-9 \u2026]*[A-Za-z0-9\u2026])?")\n',
        'ROW_TITLE = re.compile(".+")\n',
        ["row titles, label modes and enrolment arguments refuse before dispatch"],
    ),
    # The label read takes any one mode.
    "S09-label-mode-open": (
        READS,
        '            return arguments in (["value"], ["poll"])\n',
        "            return len(arguments) == 1\n",
        ["row titles, label modes and enrolment arguments refuse before dispatch"],
    ),
    # The enrolment runs in any class.
    "S10-enrol-any-class": (
        READS,
        '        if kind != "one-shot":\n',
        "        if False:\n",
        ["System Events reads refuse the evidence class and the enrolment admits only one-shot"],
    ),
    # The last line of a multi-line answer counts as the client's answer.
    "S11-enrol-last-line": (
        READS,
        '    if "\\n" in stdout or not stdout.startswith("{"):\n',
        '    stdout = stdout.rsplit("\\n", 1)[-1]\n    if not stdout.startswith("{"):\n',
        ["a malformed enrolment answer is unavailable"],
    ),
    # The enrolment answer may hold other fields.
    "S12-enrol-schema-open": (
        READS,
        '        sorted(answer) == ["case", "response", "status"]\n',
        "        True\n",
        ["a malformed enrolment answer is unavailable"],
    ),
    # The enrolment predicate ignores GraphQL errors.
    "S13-enrol-errors-ignored": (
        LIB,
        "        '.status == 200 and ((.response.errors // []) | length == 0)' enrol \"$3\" \"$4\"\n",
        "        '.status == 200' enrol \"$3\" \"$4\"\n",
        ["the enrolment needs one complete JSON line and keeps the legacy predicate"],
    ),
    # The frame poll stops on a negative x.
    "S14-frame-sign-unchecked": (
        LIB,
        "    local predicate='(.absent | not) and (.value[0] | type == \"array\" and .[0] >= 0)'\n",
        "    local predicate='(.absent | not) and (.value[0] | type == \"array\")'\n",
        ["the item frame poll keeps five reads two seconds apart and the legacy digit predicate"],
    ),
    # An unavailable poll read continues the poll as a negative.
    "S15-failure-as-negative": (
        LIB,
        '        [[ "${state}" == 1 ]] || return "${state}"\n',
        '        [[ "${state}" == 1 || "${state}" == 125 ]] || return "${state}"\n',
        ["a failed label read stops the poll at once and is never a negative"],
    ),
    # The menu compares rendered strings, as the legacy assertion did.
    "S16-menu-rendered": (
        LIB,
        '    check_guest_read "${root}" read-poll "${operation}" ".value == ${titles}" menu-titles\n',
        '    check_guest_read "${root}" read-poll "${operation}" "(.value | join(\\", \\")) == (${titles} | join(\\", \\"))" menu-titles\n',
        [
            "a source-form list keeps a title that holds the separator",
            "an empty menu and a menu of one empty title are different lists",
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
