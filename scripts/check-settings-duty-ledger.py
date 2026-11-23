#!/usr/bin/env python3
"""Check the per-duty ledger of the Settings harness against its contracts.

The check enumerates every sentence of the archived contracts again, so a ledger
cannot omit a duty. It then resolves every cited source symbol, control, record
and authority. A resolved citation proves that the evidence exists. It does not
prove that the evidence supports the disposition.

Usage: check-settings-duty-ledger.py [--require-closed] [--archive DIR] [LEDGER]

Run it from the repository root. Status 0 means no finding, status 1 means
findings and status 2 means invalid arguments or an unreadable input.
"""

# pyright: strict
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import cast

Json = dict[str, object]

CONTRACTS = (53, 56, 61, 66, 71, 75, 80, 85)
ARCHIVE = Path("docs/verification/grove-tree-structure/original-briefs")
LEDGER = Path(
    "docs/verification/settings-activation/ordering-reconciliation-evidence/duties.json"
)
DISPOSITIONS = {"met", "owned", "withdrawn", "limit", "gap", "context"}
HANDLE = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*-k[1-9][0-9]*")
TEST_NAME = re.compile(r'^@test "(.*)" \{', re.MULTILINE)
SENTENCE_END = re.compile(r"(?<=[.;:])\s+(?=[A-Z`K])")
IDENTITY = ("id", "sha", "contract", "heading", "text", "also")


def blocks(text: str) -> list[tuple[str, str]]:
    """Split one contract into its paragraphs and list items, with headings."""
    heading = "(preamble)"
    lines: list[str] = []
    result: list[tuple[str, str]] = []
    for line in text.splitlines():
        stripped = line.strip()
        if line.startswith("#") or not stripped:
            if lines:
                result.append((heading, " ".join(lines)))
                lines = []
            if line.startswith("#"):
                heading = line.lstrip("# ").strip()
            continue
        if stripped.startswith("- ") and lines:
            result.append((heading, " ".join(lines)))
            lines = []
        lines.append(stripped.removeprefix("- "))
    if lines:
        result.append((heading, " ".join(lines)))
    return result


def enumerate_duties(archive: Path) -> list[Json]:
    """List each distinct sentence once, and record where it repeats."""
    items: list[Json] = []
    seen: dict[str, int] = {}
    for key in CONTRACTS:
        text = (archive / f"k{key}.txt").read_text(encoding="utf-8")
        for heading, block in blocks(text):
            for part in SENTENCE_END.split(block):
                sentence = re.sub(r"\s+", " ", part).strip()
                if len(sentence) < 4:
                    continue
                digest = hashlib.sha256(sentence.encode()).hexdigest()[:12]
                if digest in seen:
                    also = cast(list[str], items[seen[digest]]["also"])
                    also.append(f"k{key}:{heading}")
                    continue
                seen[digest] = len(items)
                items.append(
                    {
                        "id": f"D{len(items) + 1:03d}",
                        "sha": digest,
                        "contract": f"k{key}",
                        "heading": heading,
                        "text": sentence,
                        "also": [],
                    }
                )
    return items


def entries(row: Json, field: str) -> list[Json]:
    value = row.get(field)
    if not isinstance(value, list):
        return []
    return [
        cast(Json, item) for item in cast(list[object], value) if isinstance(item, dict)
    ]


def text_of(path: Path, cache: dict[Path, str | None]) -> str | None:
    if path not in cache:
        try:
            cache[path] = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            cache[path] = None
    return cache[path]


def check_citations(row: Json, cache: dict[Path, str | None]) -> list[str]:
    findings: list[str] = []
    for source in entries(row, "source"):
        content = text_of(Path(str(source.get("file"))), cache)
        symbol = source.get("symbol")
        if content is None or not isinstance(symbol, str) or symbol not in content:
            findings.append(f"source not found: {source.get('file')}: {symbol}")
    for control in entries(row, "controls"):
        content = text_of(Path(str(control.get("suite"))), cache)
        names = set(TEST_NAME.findall(content)) if content is not None else set[str]()
        if control.get("test") not in names:
            findings.append(
                f"control not found: {control.get('suite')}: {control.get('test')}"
            )
    red = row.get("red")
    for path in cast(list[object], red) if isinstance(red, list) else []:
        if not Path(str(path)).exists():
            findings.append(f"record not found: {path}")
    authority = row.get("authority")
    if (
        isinstance(authority, str)
        and not HANDLE.fullmatch(authority)
        and not Path(authority.split("#")[0]).exists()
    ):
        findings.append(f"authority not found: {authority}")
    return findings


def check_disposition(row: Json) -> list[str]:
    disposition = row.get("disposition")
    if disposition not in DISPOSITIONS:
        return [f"unknown disposition: {disposition}"]
    owner = row.get("owner")
    has_owner = isinstance(owner, str) and HANDLE.fullmatch(owner) is not None
    findings: list[str] = []
    if disposition == "met":
        if not entries(row, "source"):
            findings.append("met without source")
        if not entries(row, "controls"):
            findings.append("met without a control")
    if disposition in {"owned", "withdrawn", "limit"} and not row.get("authority"):
        findings.append(f"{disposition} without an authority")
    if disposition in {"owned", "gap"} and not has_owner:
        findings.append(f"{disposition} without an owner handle")
    if disposition in {"gap", "context"} and not row.get("note"):
        findings.append(f"{disposition} without a note")
    return findings


def check(rows: list[Json], archive: Path, require_closed: bool) -> list[str]:
    findings: list[str] = []
    expected = {str(item["id"]): item for item in enumerate_duties(archive)}
    actual: dict[str, Json] = {}
    for row in rows:
        identifier = str(row.get("id"))
        if identifier in actual:
            findings.append(f"{identifier}: duplicate row")
        actual[identifier] = row
    findings += [f"{name}: missing duty" for name in expected.keys() - actual.keys()]
    findings += [f"{name}: unknown duty" for name in actual.keys() - expected.keys()]
    cache: dict[Path, str | None] = {}
    for name, row in actual.items():
        item = expected.get(name)
        if item is None:
            continue
        if any(row.get(field) != item[field] for field in IDENTITY):
            findings.append(f"{name}: differs from the archived contract")
        problems = check_disposition(row) + check_citations(row, cache)
        findings += [f"{name}: {problem}" for problem in problems]
        if require_closed and row.get("disposition") == "gap":
            findings.append(f"{name}: open gap owned by {row.get('owner')}")
    return sorted(findings)


def main() -> int:
    parser = argparse.ArgumentParser(description="Check the Settings duty ledger.")
    parser.add_argument("--require-closed", action="store_true")
    parser.add_argument("--archive", type=Path, default=ARCHIVE)
    parser.add_argument("ledger", type=Path, nargs="?", default=LEDGER)
    arguments = parser.parse_args()
    try:
        value: object = json.loads(arguments.ledger.read_text(encoding="utf-8"))
        if not isinstance(value, list):
            raise TypeError("the ledger is not a list")
        rows = [cast(Json, row) for row in cast(list[object], value)]
        if not all(isinstance(cast(object, row), dict) for row in rows):
            raise TypeError("a ledger row is not an object")
        findings = check(rows, arguments.archive, arguments.require_closed)
    except (OSError, TypeError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 2
    for finding in findings:
        print(finding)
    counts = Counter(str(row.get("disposition")) for row in rows)
    summary = ", ".join(f"{name} {counts[name]}" for name in sorted(counts))
    print(f"{len(rows)} duties: {summary}; {len(findings)} findings")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
