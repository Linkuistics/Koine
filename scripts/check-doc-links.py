#!/usr/bin/env python3
"""Check every relative link and #anchor in the repository's documentation.

Scans each .md file and docs/design/architecture/diagrams.json outside .grove/,
.git/, .jj/ and build output, resolves every relative href against its file,
and reports a target that does not exist or an anchor that no heading in the
target produces. Anchors follow GitHub's slug rule. Exits 1 on any failure.

  scripts/check-doc-links.py            check, print failures
  scripts/check-doc-links.py --unlinked list docs/verification files no
                                        living document links to
"""

import json
import re
import sys
import unicodedata
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
SKIP = {".grove", ".git", ".jj", ".build", "node_modules", ".pytest_cache"}
# The living documents: the ones whose citation keeps an evidence document.
LIVING = [
    "README.md",
    "CONTEXT.md",
    "docs/specs/machine.md",
    "docs/client-guide.md",
    "docs/adr",
    "docs/design",
    "clients/contract-only/README.md",
]
MD_LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)|!\[[^\]]*\]\(([^)\s]+)\)")
REF_LINK = re.compile(r"^\s*\[[^\]]+\]:\s*(\S+)", re.M)
HREF = re.compile(r'"href"\s*:\s*"([^"]+)"')


def sources():
    for path in sorted(ROOT.rglob("*")):
        rel = path.relative_to(ROOT)
        if any(part in SKIP for part in rel.parts):
            continue
        if path.suffix == ".md" or rel.as_posix() == "docs/design/architecture/diagrams.json":
            yield path


def slug(heading):
    text = re.sub(r"`|\*|_(?=\w)|(?<=\w)_|\[([^\]]*)\]\([^)]*\)", lambda m: m.group(1) or "", heading)
    text = unicodedata.normalize("NFKC", text).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


def anchors(path, cache={}):
    if path not in cache:
        found = set()
        counts = {}
        in_fence = False
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.lstrip().startswith("```"):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            match = re.match(r"^#{1,6}\s+(.*?)\s*#*\s*$", line)
            if match:
                base = slug(match.group(1))
                n = counts.get(base, 0)
                counts[base] = n + 1
                found.add(base if n == 0 else f"{base}-{n}")
        found.update(re.findall(r'<a (?:name|id)="([^"]+)"', path.read_text(encoding="utf-8")))
        cache[path] = found
    return cache[path]


def links(path):
    text = path.read_text(encoding="utf-8")
    if path.suffix == ".json":
        return HREF.findall(text)
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", "", text)
    out = [a or b for a, b in MD_LINK.findall(text)]
    out += REF_LINK.findall(text)
    return out


def resolve(path, href):
    if re.match(r"^[a-z][a-z0-9+.-]*:", href, re.I):
        return None
    target, _, anchor = href.partition("#")
    target = unquote(target)
    dest = (path.parent / target).resolve() if target else path
    return dest, anchor


def main():
    failures = []
    linked = set()
    for path in sources():
        rel = path.relative_to(ROOT).as_posix()
        living = any(rel == p or rel.startswith(p + "/") for p in LIVING)
        for href in links(path):
            resolved = resolve(path, href)
            if resolved is None:
                continue
            dest, anchor = resolved
            if living:
                linked.add(dest)
            if not dest.exists():
                failures.append(f"{rel}: missing target {href}")
            elif anchor and dest.suffix == ".md" and anchor not in anchors(dest):
                failures.append(f"{rel}: missing anchor {href}")
    if "--unlinked" in sys.argv:
        for path in sorted((ROOT / "docs/verification").glob("*.md")):
            if path.resolve() not in linked:
                print(path.relative_to(ROOT).as_posix())
        return 0
    for failure in failures:
        print(failure)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
