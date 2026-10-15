"""Saved-input certificate assessment; no target, source, CF or native calls."""
# pyright: strict

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import TypedDict, cast


class Run(TypedDict):
    columns: list[str]
    rows: list[list[int]]
    explicitReaderCallsUpper: int
    selectedInputUpper: int
    inputWithExtraEOFUpper: int


class Assessment(TypedDict):
    schemaVersion: int
    inputHashes: dict[str, str]
    nativeVerdict: str
    usefulSubjectCertificateEstablished: bool
    grossBytes: None
    totalAttempts: None
    responseBytes: None
    missingTerms: list[str]
    dimensions: dict[str, int]
    source: dict[str, int | None]
    commonColumns: list[str]
    commonRows: list[list[int]]
    episodeSpellings: list[str]
    runs: dict[str, Run]


def record(value: object) -> dict[str, object]:
    if not isinstance(value, dict):
        raise ValueError("expected an object in saved evidence")
    return cast(dict[str, object], value)


def objects(value: object) -> list[dict[str, object]]:
    if not isinstance(value, list):
        raise ValueError("expected saved observation rows")
    return [record(item) for item in cast(list[object], value)]


def texts(value: object) -> list[str]:
    if not isinstance(value, list):
        raise ValueError("expected literal string slots")
    if any(not isinstance(item, str) for item in cast(list[object], value)):
        raise ValueError("expected literal string slots")
    return cast(list[str], value)


def integer(value: object) -> int:
    if not isinstance(value, int) or isinstance(value, bool) or value < 0:
        raise ValueError("expected nonnegative dimension")
    return value


def byte_count(value: object) -> int:
    if not isinstance(value, str):
        raise ValueError("expected a saved literal spelling/key")
    return len(value.encode("utf-8"))


def file_envelope(probes: int, sizes: list[int]) -> tuple[int, int, int]:
    if probes < 0 or probes < len(sizes) or any(size < 0 or size > 131072 for size in sizes):
        raise ValueError("file envelope exceeds selected input dimensions")
    # Every absent candidate has two calls; replace each present one by nine.
    # Parse-and-retire is bounded by the six-call dictionary branch, including errors.
    return (2 * probes + 7 * len(sizes), 6 * len(sizes), sum(sizes) + len(sizes))


def json_string_upper(size: int, occurrences: int = 1) -> int:
    if size < 0 or occurrences < 0:
        raise ValueError("negative wire dimension")
    # Six output bytes per UTF-8 input byte safely covers JSON control escapes
    # and surrogate escaping, plus quotes; each selected occurrence is separate.
    return occurrences * (6 * size + 2)


def explicit_calls(
    *, raw: int, locales: int, rejected: int, probes: int, sizes: list[int],
    layout_calls: int, information: bool, strings: int, table_keys: int,
    tables: int, selectors: int, direct_keys: int, returns: int, table_plans: int,
) -> int:
    files, parsers, _ = file_envelope(probes, sizes)
    return (
        layout_calls + raw + 4 + 6 * (locales + rejected)
        + files + parsers + 26 * int(information) + 10 * strings
        + tables + 6 * table_keys + 2 * direct_keys
        + 6 * selectors + 5 * returns + 11 * table_plans
    )


def assess(subject: Path, proposal: Path) -> Assessment:
    root = Path(__file__).resolve().parent.parent
    evidence = [subject, proposal, Path(__file__),
                root / "scripts/application_metadata_operation_ledger.py",
                root / "scripts/application_metadata_reader_plan.py", root / "Taskfile.yml"]
    labels = {path: str(path.resolve().relative_to(root))
              if path.resolve().is_relative_to(root) else str(path.resolve()) for path in evidence}
    inputs = {labels[path]: hashlib.sha256(path.read_bytes()).hexdigest()
              for path in evidence}
    saved = record(json.loads(subject.read_bytes()))
    selected = record(json.loads(proposal.read_bytes()))
    if selected["subjectSha256"] != inputs[labels[subject]]:
        raise ValueError("proposal names a different saved subject; reconcile inputs first")
    human = record(selected["humanSelection"])
    if human["applicationGrossBytes"] != 20971520 or human["accounting"] != (
        "CUMULATIVE_GROSS_PER_READ_PER_COPY_NO_REFUND"
    ):
        raise ValueError("assessment requires Antony's selected cumulative gate")
    base = objects(saved["baseline"]) + objects(saved["fixtures"])
    by_path = {row["path"]: row for row in base}
    observed = [by_path[path] for path in texts(saved["combinedEpisodes"])]
    spellings = texts(saved["episodeSpellings"])
    if len(spellings) != len(observed) or len(set(spellings)) != len(spellings):
        raise ValueError("distinct alias episode sequence is incomplete")
    common: list[list[int]] = []
    dimensions: dict[str, int] = {
        "episodes": len(observed), "distinctSpellings": len(set(spellings)),
        "aliasEpisodes": len(objects(saved["aliases"])),
        "outsideQueryPaths": len(objects(saved["queryPathsOutsideDirectorySubject"])),
        "censusInputBytes": 0, "validLocaleDirectories": 0, "rawTableKeys": 0,
        "rejectedLocaleEntries": 0, "maximumNameBytes": 0, "maximumRootBytes": 0,
        "pathPayloadBytesIncludingNul": sum(byte_count(path) + 1 for path in spellings),
        "observedTargetPathPayloadBytesIncludingNul": 0,
        "rawDirectEntries": 0, "localeComponentBytesIncludingNul": 0,
        "tableKeyBytesIncludingNul": 0, "locProvenanceKeys": 0,
        "singlePathScalarWireUpper": sum(json_string_upper(byte_count(p)) for p in spellings),
        "regularCensusFiles": 0,
    }
    for row, spelling in zip(observed, spellings, strict=True):
        files = objects(row["files"])
        if any(f["state"] != "REGULAR" or f["parsed"] != "DICTIONARY" for f in files):
            raise ValueError("saved file states changed; extend the evidence envelope first")
        sizes = [integer(f["bytes"]) for f in files]
        file_envelope(integer(row["fixedFileCensusProbes"]), sizes)
        locales = texts(row["locales"])
        rejected = texts(row["rejectedLocaleEntries"])
        tables = [f for f in files if str(f["relative"]).endswith(".loctable")]
        keys = [key for table in tables for key in texts(table["localeKeys"])]
        if any(texts(table["otherKeys"]) for table in tables):
            raise ValueError("non-dictionary table dimensions need a new branch assessment")
        raw = len(texts(row["rawDirectEntries"]))
        components = sum(byte_count(key) + 1 for key in locales)
        table_bytes = sum(byte_count(key) + 1 for key in keys)
        maximum = max(
            [integer(f.get("maximumNameBytes", 0)) for f in files]
            + [byte_count(f["name"]) for f in files if isinstance(f.get("name"), str)]
            + [0]
        )
        common.append([
            byte_count(spelling), sum(sizes), len(files), len(locales), len(rejected),
            len(keys), raw, components, table_bytes, keys.count("LocProvenance"),
            integer(row["resolvedRootBytes"]), integer(row["resolvedRootLexicalComponents"]),
            maximum,
        ])
        for key, value in (
            ("censusInputBytes", sum(sizes)), ("validLocaleDirectories", len(locales)),
            ("rawTableKeys", len(keys)), ("rejectedLocaleEntries", len(rejected)),
            ("rawDirectEntries", raw), ("localeComponentBytesIncludingNul", components),
            ("tableKeyBytesIncludingNul", table_bytes),
            ("locProvenanceKeys", keys.count("LocProvenance")),
            ("regularCensusFiles", len(files)),
            ("observedTargetPathPayloadBytesIncludingNul", byte_count(row["path"]) + 1),
        ):
            dimensions[key] += value
        dimensions["maximumNameBytes"] = max(dimensions["maximumNameBytes"], maximum)
        dimensions["maximumRootBytes"] = max(
            dimensions["maximumRootBytes"], byte_count(spelling), integer(row["resolvedRootBytes"])
        )
    # A separate saved worksheet supplies controls, never the first derivation.
    worksheet = record(saved["combinedWorksheet"])
    for ours, theirs in (
        ("censusInputBytes", "allCensusInputBytes"),
        ("validLocaleDirectories", "localizationRecords"),
        ("rawTableKeys", "loctableLocaleRecords"),
        ("rawDirectEntries", "rawDirectEntries"),
        ("localeComponentBytesIncludingNul", "localizationComponentBytesIncludingNul"),
    ):
        if dimensions[ours] != worksheet[theirs]:
            raise ValueError(f"independent aggregate disagrees with saved worksheet: {ours}")
    runs: dict[str, Run] = {}
    for preferences, raw_run in record(selected["selectionRuns"]).items():
        plans = objects(record(raw_run)["rows"])
        if [plan["path"] for plan in plans] != saved["combinedEpisodes"]:
            raise ValueError("saved selection episode sequence is incomplete")
        rows: list[list[int]] = []
        for row, plan in zip(observed, plans, strict=True):
            bases = texts(plan["plannedBases"])
            resource = str(row["resourceBase"])
            wanted = {f"{resource}/{base}/{family}" for base in bases for family in (
                "InfoPlist-macos.strings", "InfoPlist.strings",
                "InfoPlist-macos.loctable", "InfoPlist.loctable",
            )}
            files = [f for f in objects(row["files"]) if f["role"] in (
                "INFORMATION", "GLOBAL_NAME"
            ) or f["relative"] in wanted]
            tables = [f for f in files if str(f["relative"]).endswith(".loctable")]
            table_plans = [p for p in objects(plan["tables"])
                           if p["relative"] in {t["relative"] for t in tables}]
            if len(table_plans) != len(tables):
                raise ValueError("selected table lacks an independent saved plan")
            table_keys = sum(len(texts(t["localeKeys"])) for t in tables)
            direct = texts(plan["directSelected"])
            returns = len(direct) + sum(len(texts(p["selected"])) for p in table_plans)
            table_plan_count = sum(len(texts(p["plannedKeys"])) for p in table_plans)
            locales = texts(row["locales"])
            selectors = int(bool(locales)) + sum(
                any(k != "LocProvenance" for k in texts(t["localeKeys"])) for t in tables
            )
            probes = 2 + 4 * (1 + len(bases))
            sizes = [integer(f["bytes"]) for f in files]
            _, _, input_upper = file_envelope(probes, sizes)
            # Checked layout absences cost two; admitted directory/resource bases six.
            layout = {"Contents": 12, "Support Files": 14, "Resources": 10, ".": 6}
            calls = explicit_calls(
                raw=len(texts(row["rawDirectEntries"])), locales=len(locales),
                rejected=len(texts(row["rejectedLocaleEntries"])), probes=probes, sizes=sizes,
                layout_calls=layout[str(row["informationBase"])],
                information=any(f["role"] == "INFORMATION" for f in files),
                strings=sum(f["role"] != "INFORMATION"
                            and not str(f["relative"]).endswith(".loctable") for f in files),
                table_keys=table_keys, tables=len(tables), selectors=selectors,
                direct_keys=len(locales), returns=returns, table_plans=table_plan_count,
            )
            rows.append([probes, len(files), sum(sizes), input_upper, len(bases),
                         len(tables), table_keys, selectors, returns, table_plan_count, calls])
        runs[preferences] = {
            "columns": ["fileProbesUpper", "regularFilesUpper", "selectedInputUpper",
                        "inputWithExtraEOFUpper", "plannedLocaleBases", "tablesUpper",
                        "tableKeysUpper", "selectorsUpper", "rawReturnsUpper",
                        "plannedTableKeysUpper", "explicitReaderCallsUpper"],
            "rows": rows, "explicitReaderCallsUpper": sum(row[-1] for row in rows),
            "selectedInputUpper": sum(row[2] for row in rows),
            "inputWithExtraEOFUpper": sum(row[3] for row in rows),
        }
    batches = record(saved["controlledSourceBatches"])
    groups = record(batches["identifiers"])
    running = len(texts(batches["running"]))
    raw_urls = len(texts(batches["indexed"])) + running + sum(
        len(texts(record(group)["cf"])) + len(texts(record(group)["appkit"])) + 1
        for group in groups.values()
    )
    result: Assessment = {
        "schemaVersion": 1, "inputHashes": inputs, "nativeVerdict": "PENDING",
        "usefulSubjectCertificateEstablished": False, "grossBytes": None,
        "totalAttempts": None, "responseBytes": None,
        "missingTerms": ["source_operations_and_payloads", "root_walk_visits_and_copies",
                         "owned_representations_and_scratch", "scalar_and_selector_projections",
                         "response_selection_and_fixed_overhead"],
        "dimensions": dimensions,
        "source": {"controlledRawURLSlots": raw_urls, "controlledRunningSlots": running,
                   "controlledIdentifierGroupsIncludingSystem": len(groups) + 2,
                   "actualIndexedTuples": None, "actualSourceAttempts": None,
                   "actualSourceGross": None},
        "commonColumns": ["spellingBytes", "censusInputBytes", "regularCensusFiles",
                          "validLocaleDirectories", "rejectedLocaleEntries", "rawTableKeys",
                          "rawDirectEntries", "localeComponentBytesIncludingNul",
                          "tableKeyBytesIncludingNul", "locProvenanceKeys", "resolvedRootBytes",
                          "resolvedLexicalComponents", "maximumObservedNameBytes"],
        "commonRows": common, "episodeSpellings": spellings, "runs": runs,
    }
    if inputs != {labels[path]: hashlib.sha256(path.read_bytes()).hexdigest()
                  for path in evidence}:
        raise ValueError("saved inputs changed during assessment; rerun after edits settle")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Assess saved episode dimensions and explicit reader calls. JSON v1; "
        "full certificate remains unestablished. No target/source/native I/O.",
        epilog="Examples: python3 scripts/application_metadata_episode_certificate.py --write\n"
        "  python3 scripts/application_metadata_episode_certificate.py --check\n"
        "Exit 0: assessment reproduced (not native/fit pass); 1: invalid/changed evidence; "
        "2: usage. --write replaces only the assessment; safe to rerun.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="write compact per-episode assessment")
    mode.add_argument("--check", action="store_true", help="compare every saved assessment item")
    parser.add_argument("--output", type=Path,
                        default=Path("docs/design/application-metadata-episode-certificate.json"))
    args = parser.parse_args()
    try:
        result = assess(Path("docs/design/application-metadata-subject.json"),
                        Path("docs/design/application-metadata-budget-proposal.json"))
        if args.write:
            args.output.write_text(json.dumps(result, separators=(",", ":")) + "\n")
        elif result != json.loads(args.output.read_bytes()):
            raise ValueError("assessment changed; inspect evidence and regenerate with --write")
    except (OSError, ValueError, KeyError) as error:
        print(json.dumps({"code": "CERTIFICATE_ASSESSMENT_INVALID", "error": str(error),
                          "remediation": "Reconcile saved inputs and assessment; do not recapture "
                          "targets or substitute a native/fit verdict."}), file=sys.stderr)
        raise SystemExit(1) from error
    print(json.dumps({"nativeVerdict": result["nativeVerdict"],
                      "usefulSubjectCertificateEstablished": False,
                      "dimensions": result["dimensions"],
                      "explicitReaderCallsUpper": {key: value["explicitReaderCallsUpper"]
                                                   for key, value in result["runs"].items()},
                      "missingTerms": result["missingTerms"]}))


if __name__ == "__main__":
    main()
