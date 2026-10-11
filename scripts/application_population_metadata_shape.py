"""Audit the saved joint metadata projection; no target access or qualification."""

# pyright: strict
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path
from typing import cast

ROOT = Path(__file__).resolve().parents[1]
SUBJECT = "docs/design/application-metadata-subject.json"
GROUPED = "docs/design/application-metadata-grouped-storage.json"
OUTPUT = "docs/design/application-population-metadata-shape.json"
INPUTS = (
    SUBJECT,
    GROUPED,
    "scripts/application_metadata_subject.py",
    "scripts/application_metadata_grouped_storage.py",
)
Row = dict[str, object]


def record(value: object) -> Row:
    if not isinstance(value, dict):
        raise ValueError("expected object")
    return cast(Row, value)


def rows(value: object) -> list[Row]:
    if not isinstance(value, list):
        raise ValueError("expected rows")
    return [record(item) for item in cast(list[object], value)]


def digest(value: object) -> str:
    return hashlib.sha256(
        json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode()
    ).hexdigest()


def load(path: str) -> Row:
    return record(json.loads((ROOT / path).read_text()))


def projection_errors(reference: list[Row], candidate: list[Row]) -> list[str]:
    """Compare each complete saved row by spelling, independently of marginals/order."""
    expected = {str(row["path"]): digest(row) for row in reference}
    observed = {str(row["path"]): digest(row) for row in candidate}
    errors: list[str] = []
    if len(observed) != len(candidate):
        errors.append("duplicate spelling")
    for path in sorted(expected.keys() | observed.keys()):
        if expected.get(path) != observed.get(path):
            errors.append(f"changed or missing joint evidence: {path}")
    return errors


def build_report() -> Row:
    subject, grouped = load(SUBJECT), load(GROUPED)
    baseline = rows(subject["baseline"])
    spellings = cast(list[str], grouped["episodeSpellings"])
    if len(baseline) != 640 or len(spellings) != 2043:
        raise ValueError("historical subject changed; revise the bounded evidence claim")
    if [str(row["path"]) for row in baseline] != spellings[:640]:
        raise ValueError("baseline/grouped per-copy order differs")
    if cast(list[str], subject["episodeSpellings"]) != spellings:
        raise ValueError("grouped episode associations differ")
    per_copy: list[Row] = []
    missing = {
        "fixedFilePayloads": 0,
        "formatTags": 0,
        "completeTableTypedValues": 0,
        "individualNameKeyCandidates": 0,
    }
    cohorts: dict[str, list[Row]] = {"system": [], "installedNonSystem": []}
    for ordinal, row in enumerate(baseline):
        files = rows(row["files"])
        regular = [file for file in files if file.get("state") == "REGULAR"]
        tables = [file for file in regular if str(file["relative"]).endswith(".loctable")]
        for file in regular:
            missing["fixedFilePayloads"] += int("payload" not in file)
            missing["formatTags"] += int("format" not in file)
            missing["individualNameKeyCandidates"] += int("typedEntries" not in file)
        missing["completeTableTypedValues"] += sum("typedEntries" not in f for f in tables)
        cohort = "system" if str(row["path"]).startswith("/System/") else "installedNonSystem"
        cohorts[cohort].append(row)
        per_copy.append(
            {
                "baselineOrdinal": ordinal,
                "path": row["path"],
                "savedJointRowDigest": digest(row),
                "groupedEpisodeOrdinal": ordinal,
                "groupedInventoryProfile": record(grouped["inventories"])[str(row["path"])],
                "cohort": cohort,
                "regularFixedFiles": len(regular),
                "loctables": len(tables),
                "replayable": False,
            }
        )
    # The complete source rows retain associations; summaries never select a distribution.
    summaries: Row = {}
    for label, members in cohorts.items():
        all_files = [file for row in members for file in rows(row["files"])]
        summaries[label] = {
            "copies": len(members),
            "informationBytes": sum(
                int(cast(int, record(r["information"]).get("bytes", 0)))
                for r in members
                if r.get("information") is not None
            ),
            "allFixedFileBytes": sum(cast(int, f.get("bytes", 0)) for f in all_files),
            "directLocales": sum(len(cast(list[object], r["locales"])) for r in members),
            "rawDirectEntries": sum(
                len(cast(list[object], r["rawDirectEntries"])) for r in members
            ),
            "loctables": sum(str(f["relative"]).endswith(".loctable") for f in all_files),
            "layouts": {
                base: sum(r["informationBase"] == base for r in members)
                for base in ("Contents", "Support Files", "Resources", ".")
            },
        }
    return {
        "schemaVersion": 1,
        "outcome": "CORPUS_INSUFFICIENT",
        "qualificationShapeEstablished": False,
        "privateImplementationEligibleNow": False,
        "nativeVerdict": "PENDING",
        "advertisementHold": True,
        "consumptionHold": True,
        "scope": "SAVED_MACOS_26_6_2_PROJECTION_ONLY",
        "inputHashes": {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in INPUTS},
        "sourcePlatform": subject["platform"],
        "sourcePredicate": subject["predicate"],
        "historicalCombinedEpisodes": len(spellings),
        "cohortDimensions": summaries,
        "missingEvidence": missing,
        "perCopyEvidence": per_copy,
        "requiredPopulation": {
            "usefulApps": 1010,
            "configuredSystemWitnesses": 14,
            "helpers": 256,
            "aliases": 128,
            "baseline": "ALL_ACTUAL_VM_BASELINE_AND_REGISTRATION_PRESSURE",
        },
        "selectedDistribution": None,
        "reproducibleQualificationRecipes": None,
        "qualificationScope": None,
        "missingJointFacts": [
            "exact fixed-file bytes and encoding/format",
            "all dictionary member keys/value types/values",
            "individual display-name/bundle-name and rejected candidates",
            "non-en/de table strings associated to exact language and copy",
            "LocProvenance member types/values",
            "independent useful-app cohort classification",
        ],
        "recommendation": "RETAIN_HOLDS_AND_SEEK_BOUNDED_EVIDENCE_PACKAGING_DECISION",
    }


def report_errors(candidate: Row) -> list[str]:
    expected = build_report()
    return [
        f"changed boundary evidence: {key}"
        for key in expected.keys() | candidate.keys()
        if expected.get(key) != candidate.get(key)
    ]


def check_controls() -> None:
    subject = load(SUBJECT)
    baseline = rows(subject["baseline"])
    if projection_errors(baseline, list(reversed(baseline))):
        raise ValueError("order-independent positive comparison failed")
    controls: dict[str, list[Row]] = {}
    thin = rows(subject["fixtures"])[0]
    changed = copy.deepcopy(baseline)
    for row in changed:
        row["files"] = copy.deepcopy(thin["files"])
        row["information"] = copy.deepcopy(thin["information"])
        row["locales"] = copy.deepcopy(thin["locales"])
        row["rawDirectEntries"] = copy.deepcopy(thin["rawDirectEntries"])
    controls["thin cardinality-only replacement"] = changed
    for label in (
        "omitted tail",
        "omitted loctable",
        "unselected raw key",
        "lost file/copy association",
        "LocProvenance omission",
    ):
        changed = copy.deepcopy(baseline)
        if label == "omitted tail":
            for row in changed:
                for file in rows(row["files"]):
                    if cast(int, file.get("bytes", 0)) > 65536:
                        file["bytes"] = 65536
        elif label == "lost file/copy association":
            changed[0]["files"], changed[1]["files"] = changed[1]["files"], changed[0]["files"]
        else:
            done = False
            for row in changed:
                files = rows(row["files"])
                for file in files:
                    if not str(file["relative"]).endswith(".loctable"):
                        continue
                    keys = cast(list[str], file["localeKeys"])
                    if label == "omitted loctable":
                        row["files"] = [f for f in files if f is not file]
                    elif label == "LocProvenance omission":
                        if "LocProvenance" not in keys:
                            continue
                        keys.remove("LocProvenance")
                    else:
                        removable = [
                            key for key in keys if key not in ("en", "de", "LocProvenance")
                        ]
                        if not removable:
                            continue
                        keys.remove(removable[0])
                    done = True
                    break
                if done:
                    break
            if not done:
                raise ValueError(f"no real mutation witness for {label}")
        controls[label] = changed
    for label, changed in controls.items():
        if not projection_errors(baseline, changed):
            raise ValueError(f"control failed to detect {label}")
        print(f"Observed rejection: {label}")
    original = build_report()
    for key, value in (
        ("qualificationShapeEstablished", True),
        ("nativeVerdict", "PASSED"),
        ("privateImplementationEligibleNow", True),
        ("consumptionHold", False),
    ):
        changed_report = copy.deepcopy(original)
        changed_report[key] = value
        if not report_errors(changed_report):
            raise ValueError(f"control failed to detect false {key}")
        print(f"Observed rejection: false {key}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="write saved projection audit only")
    parser.add_argument(
        "--check", action="store_true", help="verify audit and observe broken controls"
    )
    args = parser.parse_args()
    paths = (
        *INPUTS,
        "scripts/application_population_metadata_shape.py",
        "scripts/test_application_population_metadata_shape.py",
        "Taskfile.yml",
        sys.executable,
    )
    if args.check:
        paths += (OUTPUT,)
    before = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    report = build_report()
    if args.write:
        (ROOT / OUTPUT).write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    if args.check:
        errors = report_errors(load(OUTPUT))
        if errors:
            raise ValueError("\n".join(errors))
        check_controls()
    after = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in paths}
    if before != after:
        raise ValueError("audit inputs changed during execution")
    output = ROOT / ".build/application-population-metadata-shape"
    output.mkdir(parents=True, exist_ok=True)
    (output / "frozen.json").write_text(json.dumps({"before": before, "after": after}, indent=2))
    print(
        "640 joint evidence rows frozen; corpus insufficient; shape unestablished; native PENDING."
    )


if __name__ == "__main__":
    main()
