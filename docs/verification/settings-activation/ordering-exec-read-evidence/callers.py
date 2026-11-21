"""List every exec caller on the Settings scenario surface, with reachability.

Usage: python3 callers.py, from the repository root. The surface is the
scenario and every file that it sources. A function is reached when the
scenario's top level calls it, or a reached function calls it. Reachability
matches names in command position, so a dynamic call or a call through `eval`
is not seen.
The output is the bounded inventory that the report classifies.
"""

import hashlib
import re
from pathlib import Path

SURFACE = [
    "scripts/vm-verify-menu-bar.sh",
    "scripts/vm-verify-lib.sh",
    "scripts/vm-verify-desktop-lib.sh",
    "scripts/vm-input-evidence-lib.sh",
    "scripts/vm-menu-pointer-lib.sh",
    "scripts/vm-window-resize-lib.sh",
    "scripts/signing-env.sh",
]
EXEC = re.compile(r"(^|[^_a-z])(guest|guest_text|guest_json|guest_once|sysevents)([^_a-z]|$)|file exec")
DEFINITION = re.compile(r"^([a-z_][a-z0-9_]*)\(\) *\{")


def scan(pattern: re.Pattern[str]) -> list[tuple[str, int, str, str]]:
    """Return (file, line, enclosing function or TOP, text) for each match."""
    found: list[tuple[str, int, str, str]] = []
    for name in SURFACE:
        owner = "TOP"
        for number, text in enumerate(Path(name).read_text().splitlines(), 1):
            definition = DEFINITION.match(text)
            if definition:
                owner = definition.group(1)
            elif text.startswith("}"):
                owner = "TOP"
            stripped = text.lstrip()
            if pattern.search(text) and not stripped.startswith("#"):
                one_line = definition and text.rstrip().endswith("}")
                found.append((name, number, owner, text.strip()))
                if one_line:
                    owner = "TOP"
            elif definition and text.rstrip().endswith("}"):
                owner = "TOP"
    return found


def functions() -> dict[str, list[str]]:
    bodies: dict[str, list[str]] = {}
    for name in SURFACE:
        owner = "TOP@" + name
        for text in Path(name).read_text().splitlines():
            definition = DEFINITION.match(text)
            if definition:
                owner = definition.group(1)
                bodies.setdefault(owner, []).append(text[definition.end() :])
                if text.rstrip().endswith("}"):
                    owner = "TOP@" + name
                continue
            if text.startswith("}"):
                owner = "TOP@" + name
                continue
            if not text.lstrip().startswith("#"):
                bodies.setdefault(owner, []).append(text)
    return bodies


bodies = functions()
defined = {name for name in bodies if not name.startswith("TOP@")}
reached = set()
frontier = ["TOP@scripts/vm-verify-menu-bar.sh"]
while frontier:
    current = frontier.pop()
    text = "\n".join(bodies.get(current, []))
    for name in defined - reached:
        # A call stands in command position: after a line start, blank or
        # shell operator, and before a blank, operator or line end.
        if re.search(rf"(^|[\s;&|(`]){name}([\s;&|)`]|$)", text, re.MULTILINE):
            reached.add(name)
            frontier.append(name)

print("# Bounded exec caller inventory for k81. Surface: the Settings scenario and every file it sources.")
print("# Pattern: guest, guest_text, guest_json, guest_once, sysevents as whole words, or `file exec`.")
print("# Comment lines are skipped. Columns: file:line [enclosing function, reached|unreached] text")
for name in SURFACE:
    print(f"{hashlib.sha256(Path(name).read_bytes()).hexdigest()}  {name}")
print("## exec lines")
for name, number, owner, text in scan(EXEC):
    state = "reached" if owner == "TOP" and name.endswith("menu-bar.sh") else (
        "reached" if owner in reached else ("top-level" if owner == "TOP" else "unreached")
    )
    print(f"{name}:{number} [{owner}, {state}] {text}")
print("## reached functions")
print(" ".join(sorted(reached)))
print("## unreached functions")
print(" ".join(sorted(defined - reached)))
print("## controls")
positive = [hit for hit in scan(EXEC) if hit[2] == "guest_once"]
print(f"positive: {len(positive)} exec line inside guest_once (expected 1)")
mutated = scan(re.compile(r"guest_oncex"))
print(f"mutated pattern 'guest_oncex': {len(mutated)} matches (expected 0, so the instrument can fail)")
