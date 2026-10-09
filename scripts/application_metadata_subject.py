"""Frozen file evidence and disk-only subject construction; never a Koine reader.

No signing, indexing, registration, launch, Bundle API, consent or VM work.
Whole-path file access here is a measurement instrument, not reader admission.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import plistlib
import stat
import subprocess
import sys
from collections.abc import Generator
from contextlib import contextmanager
from pathlib import Path
from typing import Any, cast
from xml.parsers.expat import ExpatError

Record = dict[str, Any]
PREDICATE = "kMDItemContentTypeTree == 'com.apple.application-bundle'"
INFORMATION = ("Info-macos.plist", "Info.plist")
NAMES = (
    "InfoPlist-macos.strings",
    "InfoPlist.strings",
    "InfoPlist-macos.loctable",
    "InfoPlist.loctable",
)
LAYOUTS = (
    ("Contents", "Contents/Resources"),
    ("Support Files", "Support Files/Resources"),
    ("Resources", "Resources"),
    (".", "."),
)
WITNESSES = (
    "Dia",
    "ChatGPT",
    "Claude",
    "Zed",
    "Visual Studio Code",
    "Jump Desktop",
    "Kimi",
    "iTerm",
    "Mail",
    "Notes",
    "Obsidian",
    "Zotero",
    "Safari",
    "Finder",
)
BOUNDARIES = (977, 978, 1003, 1004, 1023, 1024, 1500)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def stamp(path: Path) -> list[int]:
    s = path.lstat()
    return [s.st_dev, s.st_ino, s.st_mode, s.st_size, s.st_mtime_ns, s.st_ctime_ns]


def kind(path: Path) -> str:
    try:
        mode = path.lstat().st_mode
    except FileNotFoundError:
        return "ABSENT"
    if stat.S_ISLNK(mode):
        return "SYMLINK"
    if stat.S_ISDIR(mode):
        return "DIRECTORY"
    if stat.S_ISREG(mode):
        return "REGULAR"
    return "SPECIAL"


def dictionary(data: bytes) -> tuple[Record | None, str]:
    """Parse bytes already read, with no target pathname in the parser call."""
    try:
        value = plistlib.loads(data)
    except (plistlib.InvalidFileException, ValueError, ExpatError):
        parsed = subprocess.run(
            ["/usr/bin/plutil", "-convert", "xml1", "-o", "-", "-"],
            input=data,
            capture_output=True,
            check=False,
        )
        if parsed.returncode:
            return None, "UNPARSED"
        value = plistlib.loads(parsed.stdout)
    return (
        (cast(Record, value), "DICTIONARY")
        if isinstance(value, dict)
        else (None, "NOT_DICTIONARY")
    )


def name(value: Record) -> str | None:
    for key in ("CFBundleDisplayName", "CFBundleName"):
        result = value.get(key)
        if isinstance(result, str) and result:
            return result
    return None


def measure_file(root: Path, relative: str, role: str) -> Record:
    path = root / relative
    row: Record = {"relative": relative, "role": role, "state": kind(path)}
    if row["state"] != "REGULAR":
        return row
    before = stamp(path)
    data = path.read_bytes()
    assert before == stamp(path), f"file changed during read: {path}"
    assert before[3] == len(data), f"short file measurement: {path}"
    value, parsed = dictionary(data)
    row.update(bytes=len(data), sha256=digest(data), identity=before, parsed=parsed)
    if value is None:
        return row
    row["dictionaryKeys"] = len(value)
    if relative.endswith(".loctable"):
        row["localeKeys"] = sorted(
            key for key, item in value.items() if isinstance(item, dict)
        )
        row["otherKeys"] = sorted(
            key for key, item in value.items() if not isinstance(item, dict)
        )
        row["localeDictionaryKeys"] = {
            key: len(value[key]) for key in row["localeKeys"]
        }
        row["names"] = {
            key: name(value[key]) for key in ("en", "de") if key in row["localeKeys"]
        }
        row["maximumNameBytes"] = max(
            (
                len(candidate.encode())
                for key in row["localeKeys"]
                if (candidate := name(value[key])) is not None
            ),
            default=0,
        )
    else:
        row["name"] = name(value)
        identifier = value.get("CFBundleIdentifier")
        region = value.get("CFBundleDevelopmentRegion")
        row["identifier"] = identifier if isinstance(identifier, str) else None
        row["identifierNativeType"] = type(identifier).__name__
        row["developmentRegion"] = region if isinstance(region, str) else None
        row["developmentRegionNativeType"] = type(region).__name__
        row["flags"] = {
            key: value.get(key) if type(value.get(key)) is bool else None
            for key in ("LSUIElement", "LSBackgroundOnly")
        }
    return row


@contextmanager
def within(root: Path, *, create: bool = False) -> Generator[None, None, None]:
    """Single-threaded evidence walk; fixed fixture descendants stay relative."""
    saved = os.open(".", os.O_RDONLY | os.O_DIRECTORY)
    current = os.open("/", os.O_RDONLY | os.O_DIRECTORY)
    try:
        for component in root.absolute().parts[1:]:
            if create:
                try:
                    os.mkdir(component, dir_fd=current)
                except FileExistsError:
                    pass
            following = os.open(component, os.O_RDONLY | os.O_DIRECTORY, dir_fd=current)
            os.close(current)
            current = following
        os.fchdir(current)
        yield
    finally:
        os.fchdir(saved)
        os.close(current)
        os.close(saved)


def measure_bundle(root: Path) -> Record:
    try:
        with within(root):
            row = measure_current_bundle(Path("."))
            row["resolvedRoot"] = os.getcwd()
            row["resolvedRootBytes"] = len(os.fsencode(row["resolvedRoot"]))
            row["resolvedRootLexicalComponents"] = (
                len(Path(row["resolvedRoot"]).parts) - 1
            )
    except NotADirectoryError:
        return {
            "path": str(root),
            "pathBytes": len(os.fsencode(root)),
            "state": "NOT_DIRECTORY",
        }
    row.update(path=str(root), pathBytes=len(os.fsencode(root)))
    return row


def measure_current_bundle(root: Path) -> Record:
    row: Record = {"path": str(root), "pathBytes": len(os.fsencode(root))}
    if kind(root) != "DIRECTORY":
        row["state"] = "NOT_DIRECTORY"
        row["rootKind"] = kind(root)
        return row
    row.update(state="DIRECTORY", rootStamp=stamp(root))
    probes = [(info, resource, kind(root / info)) for info, resource in LAYOUTS]
    row["layoutProbes"] = probes
    selected = next(
        ((info, resource) for info, resource, state in probes if state != "ABSENT"),
        None,
    )
    assert selected is not None
    info, resource = selected
    row.update(informationBase=info, resourceBase=resource)
    if kind(root / info) != "DIRECTORY":
        row["state"] = "REFUSED_LAYOUT"
        return row
    files = [
        measure_file(root, str(Path(info) / file), "INFORMATION")
        for file in INFORMATION
    ]
    row["information"] = next(
        (file for file in files if file["state"] != "ABSENT"), None
    )
    base = root / resource
    row["resourceState"] = kind(base)
    locales: list[str] = []
    entries: list[str] = []
    rejected: list[str] = []
    if kind(base) == "DIRECTORY":
        before = stamp(base)
        entries = sorted(os.listdir(base), key=os.fsencode)
        for entry in entries:
            if entry.endswith(".lproj"):
                (locales if kind(base / entry) == "DIRECTORY" else rejected).append(
                    entry
                )
        files.extend(
            measure_file(root, str(Path(resource) / file), "GLOBAL_NAME")
            for file in NAMES
        )
        for locale in locales:
            files.extend(
                measure_file(root, str(Path(resource) / locale / file), "LOCALE_NAME")
                for file in NAMES
            )
        assert before == stamp(base), f"inventory changed during read: {base}"
    row.update(
        fixedFileCensusProbes=len(files),
        absentFiles=sum(file["state"] == "ABSENT" for file in files),
        files=[file for file in files if file["state"] != "ABSENT"],
        rawDirectEntries=entries,
        locales=locales,
        rejectedLocaleEntries=rejected,
    )
    assert row["rootStamp"] == stamp(root), f"root changed during read: {root}"
    return row


def worksheet(rows: list[Record]) -> Record:
    """A complete fixed-family census, not a selected-language production recipe."""
    files = [
        file
        for row in rows
        for file in row.get("files", [])
        if file["state"] == "REGULAR"
    ]
    information = [
        row["information"]
        for row in rows
        if row.get("information") and row["information"]["state"] == "REGULAR"
    ]
    names = [file for file in files if file["role"] != "INFORMATION"]
    locales = [locale for row in rows for locale in row.get("locales", [])]
    tables = [file for file in names if file["relative"].endswith(".loctable")]
    return {
        "bundleEpisodes": len(rows),
        "informationInputBytes": sum(file["bytes"] for file in information),
        "allFixedNameFileBytes": sum(file["bytes"] for file in names),
        "globalNameFileBytes": sum(
            file["bytes"] for file in names if file["role"] == "GLOBAL_NAME"
        ),
        "loctableBytes": sum(file["bytes"] for file in tables),
        "localizationRecords": len(locales),
        "localizationComponentBytesIncludingNul": sum(
            len(os.fsencode(locale)) + 1 for locale in locales
        ),
        "maximumLocalizationComponentBytes": max(
            (len(os.fsencode(locale)) for locale in locales), default=0
        ),
        "rawDirectEntries": sum(len(row.get("rawDirectEntries", [])) for row in rows),
        "maximumFileBytes": max((file["bytes"] for file in files), default=0),
        "maximumInformationFileBytes": max(
            (file["bytes"] for file in information), default=0
        ),
        "maximumLoctableBytes": max((file["bytes"] for file in tables), default=0),
        "maximumDictionaryKeys": max(
            (file.get("dictionaryKeys", 0) for file in files), default=0
        ),
        "maximumObservedNameBytes": max(
            (
                file.get("maximumNameBytes", len((file.get("name") or "").encode()))
                for file in files
            ),
            default=0,
        ),
        "identifierPayloadBytes": sum(
            len((file.get("identifier") or "").encode()) for file in information
        ),
        "plainNamePayloadBytes": sum(
            len((file.get("name") or "").encode()) for file in information
        ),
        "maximumLoctableLocaleDictionaryKeys": max(
            (
                count
                for file in tables
                for count in file.get("localeDictionaryKeys", {}).values()
            ),
            default=0,
        ),
        "loctableLocaleRecords": sum(
            len(file.get("localeKeys", [])) for file in tables
        ),
        "allCensusInputBytes": sum(file["bytes"] for file in files),
        "fixedFileCensusProbes": sum(
            row.get("fixedFileCensusProbes", 0) for row in rows
        ),
    }


def create_bundle(
    path: Path, identifier: str, flags: Record, layout: str = "Contents"
) -> None:
    with within(path, create=True):
        create_current_bundle(identifier, flags, layout, path.name)


def create_current_bundle(
    identifier: str, flags: Record, layout: str, basename: str
) -> None:
    path = Path(".")
    resource = dict(LAYOUTS)[layout]
    base = path / resource
    for locale in ("en.lproj", "de.lproj", "Base.lproj"):
        (base / locale).mkdir(parents=True, exist_ok=True)
    info = {
        "CFBundleIdentifier": identifier,
        "CFBundleName": "Plain " + basename,
        "CFBundleDevelopmentRegion": "en",
        **flags,
    }
    (path / layout / "Info.plist").write_bytes(
        plistlib.dumps(info, fmt=plistlib.FMT_BINARY)
    )
    for locale in ("en", "de"):
        (base / (locale + ".lproj") / "InfoPlist.strings").write_bytes(
            plistlib.dumps(
                {"CFBundleDisplayName": locale + " Localized " + basename},
                fmt=plistlib.FMT_BINARY,
            )
        )


def construct(fixtures: Path) -> tuple[list[Path], list[Record]]:
    assert ".build" in fixtures.resolve().parts, (
        "fixtures must be inside a .build directory"
    )
    paths: list[Path] = []
    for index in range(1010):
        path = fixtures / "P1024" / f"Useful{index:04}.app"
        create_bundle(
            path, f"test.koine.design.useful{index:04}", {"LSUIElement": False}
        )
        paths.append(path)
    for index in range(256):
        parent = fixtures / "P1024" if index else paths[0] / "Contents" / "Helpers"
        path = parent / f"Helper{index:04}.app"
        create_bundle(
            path,
            f"test.koine.design.helper{index:04}",
            {"LSUIElement": True, "LSBackgroundOnly": bool(index % 2)},
        )
        paths.append(path)
    aliases: list[Record] = []
    for index in range(128):
        alias = fixtures / "P1024" / f"Alias{index:04}.app"
        target = paths[index]
        if not alias.is_symlink():
            alias.symlink_to(target.resolve())
        assert alias.resolve() == target.resolve()
        aliases.append(
            {
                "path": str(alias),
                "target": str(target),
                "pathBytes": len(os.fsencode(alias)),
            }
        )
    for boundary in BOUNDARIES:
        root = fixtures / "L1500" / str(boundary)
        remaining = boundary - len(os.fsencode(root)) - len("/Fixture.app")
        assert remaining > 1
        while remaining:
            length = min(199, remaining - 1)
            if remaining - length - 1 == 1:
                length -= 1
            assert length > 0
            root /= "a" * length
            remaining -= length + 1
        path = root / "Fixture.app"
        assert len(os.fsencode(path)) == boundary
        create_bundle(
            path,
            f"test.koine.design.long{boundary}",
            {"LSUIElement": False, "LSBackgroundOnly": False},
        )
        paths.append(path)
    for boundary in (1024, 1500):
        path = fixtures / "L1500" / f"Short{boundary}.app"
        create_bundle(path, f"test.koine.design.long{boundary}", {"LSUIElement": False})
        paths.append(path)
    return paths, aliases


def require_name_families(names: list[str]) -> None:
    assert "InfoPlist.loctable" in names, "omitted loctable cannot cover shipped names"


def old_defect_controls(value: Record) -> list[str]:
    baseline = value["baselineWorksheet"]
    controls = {
        "old information-file cap": baseline["maximumInformationFileBytes"] <= 65536,
        "old loctable-file cap": baseline["maximumLoctableBytes"] <= 65536,
        "old input dimension": baseline["informationInputBytes"] <= 1000000,
        "old locale dimension": baseline["localizationRecords"] <= 4096,
        "old gross certificate with complete measured dimensions": (
            6816128
            + value["combinedWorksheet"]["informationInputBytes"]
            + 128 * value["combinedWorksheet"]["localizationRecords"]
            <= 8388608
        ),
    }
    for label, passes in controls.items():
        assert not passes, f"deliberately broken control unexpectedly passed: {label}"
    try:
        require_name_families(["InfoPlist-macos.strings", "InfoPlist.strings"])
    except AssertionError:
        controls["omitted shipped loctable"] = False
    else:
        raise AssertionError("deliberately omitted loctable unexpectedly passed")
    return list(controls)


def check(value: Record) -> None:
    assert (
        value["nativeVerdict"] == "PENDING" and not value["completeSupportedVMBaseline"]
    )
    assert value["frozenBeforeAfter"]
    require_name_families(value["censusNameFamilies"])
    baseline = value["baseline"]
    assert value["baselineWorksheet"] == worksheet(baseline)
    assert value["fixtureWorksheet"] == worksheet(value["fixtures"])
    by_path = {row["path"]: row for row in baseline + value["fixtures"]}
    episodes = [by_path[path] for path in value["combinedEpisodes"]]
    assert value["combinedWorksheet"] == worksheet(episodes)
    assert len(value["usefulWitnesses"]) == 14
    assert set(value["usefulWitnesses"]) == set(WITNESSES)
    for path in value["usefulWitnesses"].values():
        assert by_path[path]["state"] == "DIRECTORY" and by_path[path].get(
            "information"
        )
    assert len(value["fixtures"]) == 1275 and len(value["aliases"]) == 128
    useful = [
        row for row in value["fixtures"] if Path(row["path"]).name.startswith("Useful")
    ]
    assert len({row["information"]["identifier"] for row in useful}) == 1010
    assert len(set(value["episodeSpellings"])) == len(episodes)
    for spelling, target in zip(
        value["episodeSpellings"], value["combinedEpisodes"], strict=True
    ):
        assert spelling == target or any(
            alias["path"] == spelling and alias["target"] == target
            for alias in value["aliases"]
        )
    assert value["combinedWorksheet"]["bundleEpisodes"] == len(baseline) + 1275 + 128
    assert value["baselineWorksheet"]["maximumInformationFileBytes"] > 65536
    assert value["baselineWorksheet"]["maximumLoctableBytes"] > 65536
    assert value["baselineWorksheet"]["localizationRecords"] > 4096
    assert value["baselineWorksheet"]["informationInputBytes"] > 1000000
    for basename, plain, english, german in (
        ("FindMy.app", "FindMy", "Find My", "Wo ist?"),
        ("VoiceMemos.app", "VoiceMemos", "Voice Memos", "Sprachmemos"),
    ):
        row = next(row for row in baseline if Path(row["path"]).name == basename)
        assert row["information"]["name"] == plain
        table = next(
            file
            for file in row["files"]
            if file["relative"].endswith("/InfoPlist.loctable")
        )
        assert table["names"]["en"] == english and table["names"]["de"] == german
    long_paths = [
        row["pathBytes"]
        for row in value["fixtures"]
        if Path(row["path"]).name == "Fixture.app"
    ]
    assert sorted(long_paths) == list(BOUNDARIES)
    assert value["controlledSourceBatches"]["nativeObservation"] is False
    old_defect_controls(value)


def query() -> list[str]:
    raw = subprocess.check_output(["/usr/bin/mdfind", "-0", PREDICATE])
    assert not raw or raw.endswith(b"\0"), "fixed query has no complete path terminator"
    return sorted(path.decode("utf-8") for path in raw.split(b"\0")[:-1])


def capture(output: Path, fixtures: Path) -> Record:
    inputs = [
        Path(__file__),
        Path("Taskfile.yml"),
        Path("docs/design/application-population.json"),
        Path("docs/design/application-localized-admission.json"),
        Path("docs/design/long-application-metadata.json"),
        Path("scripts/test_application_metadata_subject.py"),
        Path(sys.executable),
        Path("/usr/bin/plutil"),
        Path("/usr/bin/mdfind"),
    ]
    hashes = {str(path): digest(path.read_bytes()) for path in inputs}
    fixture_paths, aliases = construct(fixtures)
    paths = query()
    accepted: list[Path] = []
    outside: list[Record] = []
    for spelling in paths:
        path = Path(spelling)
        if not any(
            path.is_relative_to(root)
            for root in ("/System", "/Applications", "/Library")
        ):
            outside.append(
                {"path": spelling, "reason": "OUTSIDE_DECLARED_CONTENTS_SCOPE"}
            )
        elif path.suffix != ".app" or kind(path) not in ("DIRECTORY", "SYMLINK"):
            outside.append(
                {
                    "path": spelling,
                    "reason": "NOT_CHECKED_APP_DIRECTORY",
                    "kind": kind(path),
                }
            )
        else:
            if kind(path) == "SYMLINK" and not path.is_dir():
                outside.append({"path": spelling, "reason": "ALIAS_NOT_DIRECTORY"})
                continue
            if not any(
                path.resolve().is_relative_to(root)
                for root in ("/System", "/Applications", "/Library")
            ):
                outside.append(
                    {
                        "path": spelling,
                        "reason": "RESOLVED_OUTSIDE_DECLARED_CONTENTS_SCOPE",
                    }
                )
                continue
            if path not in accepted:
                accepted.append(path)
    baseline = [measure_bundle(path) for path in accepted]
    controlled = [measure_bundle(path) for path in fixture_paths]
    witnesses = {
        label: next(
            row["path"] for row in baseline if Path(row["path"]).name == label + ".app"
        )
        for label in WITNESSES
    }
    episodes = baseline + controlled + [controlled[index] for index in range(128)]
    spellings = [row["path"] for row in baseline + controlled] + [
        alias["path"] for alias in aliases
    ]
    groups: dict[str, list[str]] = {}
    for row in baseline + controlled:
        information: Record = row.get("information") or {}
        identifier = information.get("identifier")
        if isinstance(identifier, str) and identifier:
            groups.setdefault(identifier, []).append(row["path"])
    batches = {
        "nativeObservation": False,
        "purpose": "Explicit controlled source counterpart; not this host's native batches",
        "indexed": spellings,
        "running": [row["path"] for row in controlled[:128]],
        "identifiers": {
            identifier: {"cf": members, "appkit": members, "preferred": members[0]}
            for identifier, members in sorted(groups.items())
        },
    }
    assert paths == query(), "index path set changed; rerun the capture"
    assert baseline == [measure_bundle(path) for path in accepted], (
        "baseline changed; rerun capture"
    )
    assert controlled == [measure_bundle(path) for path in fixture_paths], (
        "fixtures changed; rerun capture"
    )
    assert hashes == {str(path): digest(path.read_bytes()) for path in inputs}, (
        "instrument inputs changed"
    )
    value: Record = {
        "purpose": "Complete bounded development-host file census plus disk-only controlled design subject",
        "nativeVerdict": "PENDING",
        "completeSupportedVMBaseline": False,
        "frozenBeforeAfter": True,
        "inputHashes": hashes,
        "predicate": PREDICATE,
        "platform": subprocess.check_output(["/usr/bin/sw_vers"], text=True).strip(),
        "contentsScope": ["/System", "/Applications", "/Library"],
        "rawQueryPaths": paths,
        "queryPathsOutsideDirectorySubject": outside,
        "censusInformationFamilies": list(INFORMATION),
        "censusNameFamilies": list(NAMES),
        "baseline": baseline,
        "fixtures": controlled,
        "aliases": aliases,
        "schemaVersion": 1,
        "episodeSpellings": spellings,
        "controlledSourceBatches": batches,
        "usefulWitnesses": witnesses,
        "combinedEpisodes": [row["path"] for row in episodes],
        "baselineWorksheet": worksheet(baseline),
        "fixtureWorksheet": worksheet(controlled),
        "combinedWorksheet": worksheet(episodes),
        "pending": [
            "Supported VM baseline and source batches",
            "Actual type/index tuples and registration",
            "Signing and executable useful-app fixtures",
            "Running/presentation and native read safety",
            "Selected reader file/locale precedence and gross-budget construction",
            "All native G/N/V",
        ],
    }
    check(value)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "\n"
    )
    return value


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Capture/check frozen design-only application files. JSON v1; no native verdict.",
        epilog="Examples: python3 scripts/application_metadata_subject.py --capture\n"
        "  python3 scripts/application_metadata_subject.py --check\n"
        "Exit 0: measured/checked; 1: changed subject or failed control; 2: usage.\n"
        "Capture creates/overwrites only .build fixtures and the output; safe to rerun.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument(
        "--capture", action="store_true", help="read declared host fixed files twice"
    )
    mode.add_argument(
        "--check", action="store_true", help="check saved JSON only; no host reads"
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/design/application-metadata-subject.json"),
    )
    parser.add_argument(
        "--fixtures",
        type=Path,
        default=Path.cwd() / ".build/application-metadata-subject",
    )
    args = parser.parse_args()
    try:
        value = (
            capture(args.output, args.fixtures)
            if args.capture
            else json.loads(args.output.read_text())
        )
        check(value)
    except (
        AssertionError,
        OSError,
        StopIteration,
        subprocess.SubprocessError,
        json.JSONDecodeError,
    ) as error:
        print(
            json.dumps(
                {
                    "code": "SUBJECT_INVALID",
                    "error": str(error) or type(error).__name__,
                    "remediation": "Inspect the changed/missing subject; rerun capture after inputs settle.",
                }
            ),
            file=sys.stderr,
        )
        raise SystemExit(1) from error
    print(
        json.dumps(
            {
                "nativeVerdict": "PENDING",
                "baseline": value["baselineWorksheet"],
                "combined": value["combinedWorksheet"],
                "deliberatelyRejectedControls": old_defect_controls(value),
            }
        )
    )


if __name__ == "__main__":
    main()
