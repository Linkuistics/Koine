"""Show that the Settings baseline control refuses each kind of change.

Each mutation edits a private copy of the tracked harness and runs
scripts/check-settings-baseline.py against that copy, on the one case that can
see the change. A mutation counts only when the check exits 1 with the expected
finding. Run it from the repository root.

Usage: settings-baseline-mutations.py [NAME...]
"""

from __future__ import annotations

import concurrent.futures
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import NamedTuple

SCENARIO = "scripts/vm-verify-menu-bar.sh"
LIBRARY = "scripts/vm-settings-scenario-lib.sh"
SYSEVENTS = "scripts/vm-sysevents-evidence-lib.sh"
WINDOWS = "scripts/vm-window-evidence-lib.sh"
READS = "scripts/vm-exec-read-evidence-lib.sh"
ONE_SHOT = "scripts/vm-exec-one-shot-evidence-lib.sh"
POINTER = "scripts/vm-menu-pointer-lib.sh"
SNAPSHOT = "scripts/vm-ui-evidence-lib.sh"
BACKEND = "Tests/scripts/fixtures/settings-scenario-backend.py"


class Mutation(NamedTuple):
    name: str
    case: str
    finding: str
    edits: tuple[tuple[str, str, str], ...]


SEVEN = tuple(
    (
        SCENARIO,
        f"settings_sleep {name} {seconds}",
        f"settings_sleep {name} {seconds + 1}",
    )
    for name, seconds in (
        ("shortcut-type", 1),
        ("shortcut-cut", 1),
        ("shortcut-paste", 1),
        ("requests-front", 2),
        ("requests-deny-1", 4),
        ("requests-deny-2", 4),
        ("accessibility-front", 2),
    )
)
MUTATIONS = (
    Mutation(
        "scenario-input",
        "complete",
        "complete: event",
        ((SCENARIO, "window-move TextEdit 700 120", "window-move TextEdit 701 120"),),
    ),
    Mutation(
        "added-input",
        "complete",
        "complete: event",
        (
            (
                SCENARIO,
                "settings_sleep textedit-move 1\n",
                "settings_sleep textedit-move 1\nsettings_input added key escape\n",
            ),
        ),
    ),
    Mutation(
        "facade-input",
        "complete",
        "complete: event",
        (
            (
                POINTER,
                "approach_x=$((x >= 12 ? x - 12 : 0))",
                "approach_x=$((x >= 13 ? x - 13 : 0))",
            ),
        ),
    ),
    Mutation(
        "scenario-wait",
        "complete",
        "complete: event",
        (
            (
                SCENARIO,
                "settings_sleep requests-deny-1 4",
                "settings_sleep requests-deny-1 5",
            ),
        ),
    ),
    Mutation("seven-later-waits", "complete", "complete: event", SEVEN),
    Mutation(
        "facade-wait",
        "complete",
        "complete: event",
        ((LIBRARY, 'settings_sleep "$1" 3', 'settings_sleep "$1" 4'),),
    ),
    Mutation(
        "pointer-wait",
        "complete",
        "complete: event",
        (
            (
                POINTER,
                "_physical_sleep menu-click-wait 1",
                "_physical_sleep menu-click-wait 2",
            ),
        ),
    ),
    Mutation(
        "label-poll-bound",
        "menu-label",
        "menu-label: event",
        (
            (
                SYSEVENTS,
                '"${operation}" 15 2 "${predicate}" menu-item-label',
                '"${operation}" 16 2 "${predicate}" menu-item-label',
            ),
        ),
    ),
    Mutation(
        "count-poll-delay",
        "window-count",
        "window-count: event",
        ((WINDOWS, "sleep 2 || sleep_status=$?", "sleep 3 || sleep_status=$?"),),
    ),
    Mutation(
        "login-poll-bound",
        "login-endpoint",
        "login-endpoint: event",
        ((READS, "3:login:) limit=24 delay=5 ;;", "3:login:) limit=23 delay=5 ;;"),),
    ),
    Mutation(
        "boot-poll-bound",
        "restart-boot",
        "restart-boot: event",
        ((ONE_SHOT, '"${operation}-boot" 60 5', '"${operation}-boot" 59 5'),),
    ),
    Mutation(
        "reveal-bound",
        "reveal",
        "reveal: event",
        (
            (
                LIBRARY,
                "for ((index = 1; index <= 60; index++))",
                "for ((index = 1; index <= 59; index++))",
            ),
        ),
    ),
    Mutation(
        "read-bound",
        "complete",
        "read bound",
        (
            (
                SNAPSHOT,
                '--window "${window}" --depth 14',
                '--window "${window}" --depth 13',
            ),
        ),
    ),
    Mutation(
        "scenario-assertion",
        "complete",
        "assertion 19",
        ((SCENARIO, '[ "${W}" -ge 690 ]', '[ "${W}" -ge 680 ]'),),
    ),
    Mutation(
        "facade-assertion",
        "complete",
        "predicates",
        (
            (
                SYSEVENTS,
                "'.value == 1' menu-item-count",
                "'.value >= 1' menu-item-count",
            ),
        ),
    ),
    Mutation(
        "library-assertion",
        "complete",
        "predicates",
        (
            (
                LIBRARY,
                """read-poll "$1-process" '.selected == []'""",
                """read-poll "$1-process" '.selected | length == 0'""",
            ),
        ),
    ),
    Mutation(
        "weaker-value-read",
        "complete",
        "predicates",
        (
            (
                LIBRARY,
                'element="$(settings_element "$1" "$2" value)"',
                'element="$(settings_element "$1" "$2" optional)"',
            ),
        ),
    ),
    Mutation(
        "removed-assertion",
        "complete",
        "assertion 42",
        (
            (
                SCENARIO,
                'settings_expect_koine_count login-windows 0 "the window opened at login launch though setup is complete"\n',
                "",
            ),
        ),
    ),
    Mutation(
        "restored-escape",
        "menu-titles",
        "menu-titles: event",
        (
            (
                LIBRARY,
                '    echo "Menu: ${menu}"\n    if [[ "${status}" != 0 ]]; then\n',
                '    echo "Menu: ${menu}"\n    if [[ "${status}" != 0 ]]; then\n        settings_input "${operation}-close" key escape\n        settings_sleep "${operation}-close" 1\n',
            ),
        ),
    ),
)


def run(mutation: Mutation) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory(prefix="settings-baseline-mutation-") as name:
        tree = Path(name)
        shutil.copytree("scripts", tree / "scripts")
        (tree / "App").mkdir()
        shutil.copy("App/Info.plist", tree / "App/Info.plist")
        (tree / BACKEND).parent.mkdir(parents=True)
        shutil.copy(BACKEND, tree / BACKEND)
        for path, old, new in mutation.edits:
            target = tree / path
            text = target.read_text(encoding="utf-8")
            if text.count(old) != 1:
                count = text.count(old)
                return (
                    False,
                    f"{mutation.name}: the edit matches {count} times: {old!r}",
                )
            target.write_text(text.replace(old, new), encoding="utf-8")
        result = subprocess.run(
            [
                sys.executable,
                "-I",
                "scripts/check-settings-baseline.py",
                "--tree",
                str(tree),
                "--case",
                mutation.case,
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    lines = result.stdout.splitlines()
    found = [line for line in lines if mutation.finding in line]
    detected = result.returncode == 1 and bool(found)
    shown = re.sub(
        r"/\S*settings-baseline-mutation-\S*",
        "<copy>",
        found[0] if found else result.stderr.strip()[:200],
    )
    return detected, f"{mutation.name}: status {result.returncode}: {shown[:150]}"


def main(names: list[str]) -> int:
    chosen = [item for item in MUTATIONS if not names or item.name in names]
    if names and len(chosen) != len(names):
        print("unknown mutation", file=sys.stderr)
        return 2
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(run, chosen))
    for _, line in results:
        print(line)
    detected = sum(item[0] for item in results)
    print(f"{detected} of {len(results)} mutations detected")
    return 0 if detected == len(results) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
