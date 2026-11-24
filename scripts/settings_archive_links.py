#!/usr/bin/env python3
"""Check the reading aids beside the archived Settings context charters.

The archived charter context-initial-inputs/CONTEXT-PLAN.md links two relative
targets that the k19 archive at the recording revision did not hold. Two
reading aids now sit beside the charter. This check confirms three facts:

- Every archived file keeps the bytes of the recording revision. The archive
  holds no file other than the archived files and the declared aids.
- Each aid holds the exact bytes of its frozen subject in the manifest. The
  identification note names each aid.
- The original overlay audit still reconciles. Each repository subject in a
  manifest matches its bytes at the recording revision, or the archived overlay
  copy of the same name. The aids are not part of that overlay.

A subject outside the repository, such as .build output or a host file, is
checked against the current bytes. When it is absent or different, the check
reports it as NOT CHECKED, and not as a failure.

  scripts/settings_archive_links.py --check
"""

from __future__ import annotations

import argparse
import hashlib
import subprocess
import sys
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
# k19 retained both archives in this commit, settings-context-evidence-k19, 2026-10-28.
RECORDING_REVISION = "e3000cec62880031f4df413144a58efb751506b8"
EVIDENCE = "docs/verification/settings-activation"
NOTE = "READING-AIDS.md"


@dataclass(frozen=True)
class Archive:
    directory: str
    manifest: str
    aids: tuple[str, ...] = ()


ARCHIVES = (
    Archive(
        "context-initial-inputs",
        "context-subjects.sha256",
        ("context-predicate.txt", "context-qualify-filter.sh"),
    ),
    Archive("context-second-inputs", "context-qualified-subjects.sha256"),
)


@dataclass(frozen=True)
class Tree:
    """Reads the working tree and the recording revision."""

    root: Path
    at_revision: Callable[[str], bytes | None]
    names_at_revision: Callable[[str], list[str]]


@dataclass
class Report:
    lines: list[str] = field(default_factory=list[str])
    failures: list[str] = field(default_factory=list[str])

    def fail(self, message: str) -> None:
        self.failures.append(message)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read(path: Path) -> bytes | None:
    return path.read_bytes() if path.is_file() else None


def manifest_entries(text: str) -> list[tuple[str, str]]:
    entries: list[tuple[str, str]] = []
    for line in text.splitlines():
        sha, separator, path = line.partition("  ")
        if not separator or len(sha) != 64:
            raise ValueError(f"malformed manifest line: {line!r}")
        entries.append((sha, path))
    return entries


def check_archive(tree: Tree, archive: Archive, report: Report) -> dict[str, str]:
    """Check the archived bytes. Return the original overlay, name to digest."""
    directory = f"{EVIDENCE}/{archive.directory}"
    archived = tree.names_at_revision(directory)
    overlay: dict[str, str] = {}
    for name in archived:
        recorded = tree.at_revision(f"{directory}/{name}")
        current = read(tree.root / directory / name)
        if recorded is None or current != recorded:
            report.fail(f"{directory}/{name}: differs from the recording revision")
            continue
        overlay[name] = digest(recorded)
    declared = set(archive.aids) | ({NOTE} if archive.aids else set())
    present = {p.name for p in (tree.root / directory).iterdir() if p.is_file()}
    for name in sorted(present - set(archived) - declared):
        report.fail(f"{directory}/{name}: undeclared file in the archive")
    for name in sorted(declared & set(archived)):
        report.fail(f"{directory}/{name}: a declared aid was part of the archive")
    report.lines.append(f"{archive.directory}: {len(overlay)} archived files keep their bytes.")
    return overlay


def check_aids(tree: Tree, archive: Archive, manifest: dict[str, str], report: Report) -> None:
    if not archive.aids:
        return
    directory = f"{EVIDENCE}/{archive.directory}"
    note = read(tree.root / directory / NOTE)
    note_text = note.decode() if note is not None else ""
    if note is None:
        report.fail(f"{directory}/{NOTE}: the identification note is missing")
    matched = 0
    for name in archive.aids:
        subject = f"{EVIDENCE}/{name}"
        current = read(tree.root / directory / name)
        expected = manifest.get(subject)
        if expected is None:
            report.fail(f"{subject}: no frozen subject in {archive.manifest}")
        elif current is None:
            report.fail(f"{directory}/{name}: the reading aid is missing")
        elif digest(current) != expected:
            report.fail(f"{directory}/{name}: differs from frozen subject {subject}")
        else:
            matched += 1
        if note is not None and name not in note_text:
            report.fail(f"{directory}/{NOTE}: does not name {name}")
    report.lines.append(
        f"{archive.directory}: {matched} of {len(archive.aids)} reading aids equal their"
        f" frozen subjects."
    )


def check_overlay(
    tree: Tree, archive: Archive, entries: list[tuple[str, str]], overlay: dict[str, str],
    report: Report,
) -> None:
    revision = overlay_count = local = 0
    not_checked: list[str] = []
    for expected, path in entries:
        if path.startswith("/") or path.startswith(".build/"):
            current = read(Path(path) if path.startswith("/") else tree.root / path)
            if current is not None and digest(current) == expected:
                local += 1
            else:
                state = "absent" if current is None else "changed since the freeze"
                not_checked.append(f"{path} ({state})")
            continue
        recorded = tree.at_revision(path)
        if recorded is not None and digest(recorded) == expected:
            revision += 1
        elif overlay.get(Path(path).name) == expected:
            overlay_count += 1
        else:
            report.fail(f"{path}: matches neither the recording revision nor the overlay")
    report.lines.append(
        f"{archive.directory}: of {len(entries)} frozen inputs, {revision} match the recording"
        f" revision, {overlay_count} match the archived overlay and {local} match current"
        f" local bytes."
    )
    for item in not_checked:
        report.lines.append(f"{archive.directory}: NOT CHECKED outside the repository: {item}")


def check(tree: Tree) -> Report:
    report = Report()
    for archive in ARCHIVES:
        overlay = check_archive(tree, archive, report)
        text = tree.at_revision(f"{EVIDENCE}/{archive.directory}/{archive.manifest}")
        if text is None:
            report.fail(f"{archive.directory}/{archive.manifest}: absent at the revision")
            continue
        entries = manifest_entries(text.decode())
        check_aids(tree, archive, {path: sha for sha, path in entries}, report)
        check_overlay(tree, archive, entries, overlay, report)
    return report


def git_tree(root: Path, revision: str) -> Tree:
    def at_revision(path: str) -> bytes | None:
        result = subprocess.run(
            ["git", "-C", str(root), "show", f"{revision}:{path}"],
            capture_output=True, check=False,
        )
        return result.stdout if result.returncode == 0 else None

    def names_at_revision(directory: str) -> list[str]:
        result = subprocess.run(
            ["git", "-C", str(root), "ls-tree", "--name-only", f"{revision}:{directory}"],
            capture_output=True, check=True, text=True,
        )
        return result.stdout.split()

    return Tree(root, at_revision, names_at_revision)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check the reading aids beside the archived Settings context charters."
    )
    parser.add_argument("--check", action="store_true", required=True)
    parser.parse_args()
    report = check(git_tree(ROOT, RECORDING_REVISION))
    print(f"Recording revision: {RECORDING_REVISION}")
    for line in report.lines:
        print(line)
    for failure in report.failures:
        print(f"FAIL {failure}")
    print("FAILED" if report.failures else "PASSED")
    return 1 if report.failures else 0


if __name__ == "__main__":
    sys.exit(main())
