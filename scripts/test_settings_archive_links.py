"""Mutation controls for scripts/settings_archive_links.py.

Each test builds a small fixture of the two archives and their recording revision.
It then changes one fact and confirms that the check reports it.
"""

from __future__ import annotations

import hashlib
import importlib.util
import sys
from pathlib import Path
from types import ModuleType

import pytest

SCRIPT = Path(__file__).resolve().parent / "settings_archive_links.py"


def load() -> ModuleType:
    spec = importlib.util.spec_from_file_location("settings_archive_links", SCRIPT)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


links = load()
EVIDENCE: str = links.EVIDENCE
INITIAL = f"{EVIDENCE}/context-initial-inputs"
SECOND = f"{EVIDENCE}/context-second-inputs"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


class Fixture:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.revision: dict[str, bytes] = {}
        predicate, qualify = b"predicate\n", b"filter\n"
        source, changed = b"source at freeze\n", b"run script at freeze\n"
        self.revision[f"{EVIDENCE}/context-predicate.txt"] = predicate
        self.revision[f"{EVIDENCE}/context-qualify-filter.sh"] = qualify
        self.revision["Sources/App.swift"] = source
        self.revision[f"{EVIDENCE}/context-run.sh"] = b"run script after the sample\n"
        manifest = "".join(
            f"{sha(data)}  {path}\n"
            for data, path in [
                (predicate, f"{EVIDENCE}/context-predicate.txt"),
                (qualify, f"{EVIDENCE}/context-qualify-filter.sh"),
                (source, "Sources/App.swift"),
                (changed, f"{EVIDENCE}/context-run.sh"),
                (b"bundle\n", ".build/context/Koine"),
            ]
        ).encode()
        self.revision[f"{INITIAL}/CONTEXT-PLAN.md"] = b"charter\n"
        self.revision[f"{INITIAL}/context-run.sh"] = changed
        self.revision[f"{INITIAL}/context-subjects.sha256"] = manifest
        self.revision[f"{SECOND}/context-run.sh"] = changed
        self.revision[f"{SECOND}/context-qualified-subjects.sha256"] = manifest
        for path, data in self.revision.items():
            if path.startswith(INITIAL) or path.startswith(SECOND):
                self.write(path, data)
        self.write(f"{INITIAL}/context-predicate.txt", predicate)
        self.write(f"{INITIAL}/context-qualify-filter.sh", qualify)
        self.write(
            f"{INITIAL}/READING-AIDS.md", b"context-predicate.txt context-qualify-filter.sh\n"
        )
        self.write(".build/context/Koine", b"bundle\n")

    def write(self, path: str, data: bytes) -> None:
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)

    def names(self, directory: str) -> list[str]:
        prefix = f"{directory}/"
        return sorted(p[len(prefix):] for p in self.revision if p.startswith(prefix))

    def run(self):
        return links.check(links.Tree(self.root, self.revision.get, self.names))


@pytest.fixture
def fixture(tmp_path: Path) -> Fixture:
    return Fixture(tmp_path)


def test_consistent_archive_passes(fixture: Fixture) -> None:
    report = fixture.run()
    assert report.failures == []
    assert any("3 match the recording revision, 1 match the archived overlay" in line
               for line in report.lines)


def test_changed_aid_fails(fixture: Fixture) -> None:
    fixture.write(f"{INITIAL}/context-predicate.txt", b"predicate edited\n")
    report = fixture.run()
    assert any("differs from frozen subject" in f for f in report.failures)
    assert any("1 of 2 reading aids equal" in line for line in report.lines)


def test_missing_aid_fails(fixture: Fixture) -> None:
    (fixture.root / INITIAL / "context-qualify-filter.sh").unlink()
    assert any("reading aid is missing" in f for f in fixture.run().failures)


def test_missing_note_fails(fixture: Fixture) -> None:
    (fixture.root / INITIAL / "READING-AIDS.md").unlink()
    assert any("identification note is missing" in f for f in fixture.run().failures)


def test_note_without_aid_name_fails(fixture: Fixture) -> None:
    fixture.write(f"{INITIAL}/READING-AIDS.md", b"context-predicate.txt\n")
    assert any("does not name context-qualify-filter.sh" in f for f in fixture.run().failures)


def test_changed_charter_fails(fixture: Fixture) -> None:
    fixture.write(f"{INITIAL}/CONTEXT-PLAN.md", b"charter with repaired links\n")
    assert any("CONTEXT-PLAN.md: differs" in f for f in fixture.run().failures)


def test_undeclared_archive_file_fails(fixture: Fixture) -> None:
    fixture.write(f"{SECOND}/context-predicate.txt", b"predicate\n")
    assert any("undeclared file" in f for f in fixture.run().failures)


def test_unreconciled_repository_subject_fails(fixture: Fixture) -> None:
    fixture.revision["Sources/App.swift"] = b"source after the freeze\n"
    assert any("Sources/App.swift: matches neither" in f for f in fixture.run().failures)


def test_aid_is_not_part_of_the_overlay(fixture: Fixture) -> None:
    fixture.revision[f"{EVIDENCE}/context-predicate.txt"] = b"predicate after the freeze\n"
    failures = fixture.run().failures
    assert any("context-predicate.txt: matches neither" in f for f in failures)


def test_changed_local_subject_is_not_checked(fixture: Fixture) -> None:
    fixture.write(".build/context/Koine", b"rebuilt bundle\n")
    report = fixture.run()
    assert report.failures == []
    assert any("NOT CHECKED" in line and "changed since the freeze" in line
               for line in report.lines)
