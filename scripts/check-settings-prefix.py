"""Check the focused prefix of the complete Settings scenario, byte for byte.

The focused prefix, scripts/vm-verify-menu-bar-prefix.sh, must hold exactly the
leading bytes of the complete scenario, scripts/vm-verify-menu-bar.sh, through
the line that ends the TextEdit quit command. The next line in the scenario
that is not blank must be the resize step. The check derives the boundary from
the scenario's own text, so a changed scenario needs a new extraction.

Usage: check-settings-prefix.py [SCENARIO PREFIX]

Exit 0: the prefix matches. Exit 1: a mismatch or a boundary that the rules
refuse. Exit 2: a usage error or a file that cannot be read.
docs/verification/settings-activation/ORDERING-PREFIX-RESULTS.md records the
rule and its controls.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

QUIT = re.compile(rb"quit_guest_textedit(\s|$)")
RESIZE = re.compile(rb'step "The window resizes')
# A line that ends with one of these continues the same shell command.
CONTINUATION = (b"||", b"&&", b"|", b"\\")


def boundary(lines: list[bytes]) -> int:
    """The count of scenario lines that the prefix holds."""
    quits = [i for i, line in enumerate(lines) if QUIT.match(line)]
    resizes = [i for i, line in enumerate(lines) if RESIZE.match(line)]
    if len(quits) != 1:
        raise ValueError(
            f"the scenario has {len(quits)} TextEdit quit commands, not one"
        )
    if len(resizes) != 1:
        raise ValueError(f"the scenario has {len(resizes)} resize steps, not one")
    end = quits[0]
    while lines[end].rstrip().endswith(CONTINUATION):
        end += 1
        if end >= len(lines):
            raise ValueError("the TextEdit quit command does not end")
    if resizes[0] <= end:
        raise ValueError("the resize step does not follow the TextEdit quit")
    between = lines[end + 1 : resizes[0]]
    if any(line.strip() for line in between):
        raise ValueError(
            "a line that is not blank separates the TextEdit quit from the resize step"
        )
    return end + 1


def first_difference(left: bytes, right: bytes) -> str:
    offset = next(
        (i for i, (a, b) in enumerate(zip(left, right)) if a != b),
        min(len(left), len(right)),
    )
    line = left[:offset].count(b"\n") + 1
    return f"byte {offset}, line {line}"


def main(argv: list[str]) -> int:
    if len(argv) not in (1, 3):
        print("usage: check-settings-prefix.py [SCENARIO PREFIX]", file=sys.stderr)
        return 2
    scenario = Path(argv[1] if len(argv) == 3 else "scripts/vm-verify-menu-bar.sh")
    prefix = Path(argv[2] if len(argv) == 3 else "scripts/vm-verify-menu-bar-prefix.sh")
    try:
        scenario_bytes, prefix_bytes = scenario.read_bytes(), prefix.read_bytes()
    except OSError as error:
        print(f"FAILED: {error}", file=sys.stderr)
        return 2
    lines = scenario_bytes.splitlines(keepends=True)
    try:
        count = boundary(lines)
    except ValueError as error:
        print(f"FAILED: {scenario}: {error}", file=sys.stderr)
        return 1
    expected = b"".join(lines[:count])
    if prefix_bytes != expected:
        print(
            f"FAILED: {prefix} is not the first {count} lines of {scenario}: "
            f"they differ at {first_difference(prefix_bytes, expected)} "
            f"({len(prefix_bytes)} bytes, expected {len(expected)})",
            file=sys.stderr,
        )
        return 1
    if os.access(prefix, os.X_OK) != os.access(scenario, os.X_OK):
        print(
            f"FAILED: {prefix} and {scenario} differ in their execute permission",
            file=sys.stderr,
        )
        return 1
    print(
        f"{prefix} is the first {count} lines ({len(expected)} bytes) of {scenario}, "
        f"through the TextEdit quit; line {count + 1} onwards is not in the prefix"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
