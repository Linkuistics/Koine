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
FIELD_FACTS = {
    "relative": "Fixed-file/copy association; no payload",
    "role": "Information/global/locale role; no serialization",
    "state": "Observed filesystem category; no file bytes",
    "bytes": "Serialized byte count; no payload or encoding",
    "sha256": "Equality check for supplied bytes; no reconstruction",
    "identity": "Captured identity/size/times; no current occupant guarantee",
    "parsed": "Top-level parse category; no serialization or complete typed tree",
    "dictionaryKeys": "Top-level count; no complete keys/types/values",
    "localeKeys": "Dictionary-valued raw keys; no member keys/types/values",
    "otherKeys": "Non-dictionary raw keys; no exact value types/values",
    "localeDictionaryKeys": "Per-dictionary counts; no member keys/types/values",
    "names": "Chosen en/de names; no rejected or other-language candidates",
    "maximumNameBytes": "Chosen-name maximum; no language/key/value tail association",
    "name": "One chosen name; no display/bundle/rejected candidate distinction",
    "identifier": "String value or null; null loses absent/non-string value",
    "identifierNativeType": "Python projected type; no complete original typed value",
    "developmentRegion": "String value or null; no original non-string value",
    "developmentRegionNativeType": "Python projected type; no complete original typed value",
    "flags": "Boolean or null; null conflates absent/non-Boolean key",
    # Illustrative supplied-fact controls only; no recovery schema is selected.
    "payload": "Supplied payload annotation; digest/replay not validated by this inventory",
    "format": "Supplied format annotation; actual format not validated by this inventory",
    "typedEntries": "Supplied typed candidates; completeness/replay not validated here",
}


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


def projection_inventory(files: list[Row]) -> Row:
    """Enumerate all observed fields before classifying retained and missing facts."""
    fields = sorted({field for file in files for field in file})
    unknown = set(fields) - FIELD_FACTS.keys()
    if unknown:
        raise ValueError(f"unclassified projection field: {sorted(unknown)}")
    regular = [file for file in files if file.get("state") == "REGULAR"]
    tables = [file for file in regular if str(file["relative"]).endswith(".loctable")]
    information = [file for file in regular if file.get("role") == "INFORMATION"]
    missing: Row = {
        "fixedFilePayloads": sum("payload" not in file for file in regular),
        "formatTags": sum("format" not in file for file in regular),
        "completeTableTypedValues": sum("typedEntries" not in file for file in tables),
        "individualNameKeyCandidates": sum("typedEntries" not in file for file in regular),
        "ambiguousInformationFlags": {
            key: sum(
                record(file.get("flags", {})).get(key) is None
                and "typedEntries" not in file
                for file in information
            )
            for key in ("LSUIElement", "LSBackgroundOnly")
        },
    }
    return {
        "fields": [
            {"field": field, "observations": sum(field in file for file in files),
             "retainedFactAndLimitation": FIELD_FACTS[field]}
            for field in fields
        ],
        "missingEvidence": missing,
        "scope": "PROJECTED_FACT_PRESENCE_ONLY_NOT_VERIFIED_REPLAY",
    }


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
    inventory = projection_inventory([file for row in baseline for file in rows(row["files"])])
    cohorts: dict[str, list[Row]] = {"system": [], "installedNonSystem": []}
    for ordinal, row in enumerate(baseline):
        files = rows(row["files"])
        regular = [file for file in files if file.get("state") == "REGULAR"]
        tables = [file for file in regular if str(file["relative"]).endswith(".loctable")]
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
        time_pairs = {
            tuple(cast(list[int], file["identity"])[-2:])
            for file in all_files if file.get("state") == "REGULAR"
        }
        summaries[label] = {
            "copies": len(members),
            "partialClassificationEvidence": {
                "anyTrueInformationFlag": sum(
                    any(value is True for value in record(
                        record(row.get("information") or {}).get("flags", {})
                    ).values())
                    for row in members
                ),
                "nestedAppSpellings": sum(".app/" in str(row["path"]) for row in members),
                "independentUsefulCohortEstablished": False,
            },
            "distinctSavedFileTimePairs": len(time_pairs),
            "sharedSavedFileTimePair": list(next(iter(time_pairs)))
            if len(time_pairs) == 1 else None,
            "regularFileRoles": {
                role: sum(f.get("state") == "REGULAR" and f.get("role") == role
                          for f in all_files)
                for role in ("INFORMATION", "GLOBAL_NAME", "LOCALE_NAME")
            },
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
            "fileProjectionInventory": projection_inventory(all_files),
        }
    return {
        "schemaVersion": 2,
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
        "fileProjectionInventory": inventory,
        "missingEvidence": inventory["missingEvidence"],
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
        "referencePopulation": None,
        "templateCohorts": None,
        "usefulClassificationSource": None,
        "multiplicityAssignment": None,
        "subjectDiscriminationControls": "UNBUILT",
        "controlScope": "PACKET_INTEGRITY_NOT_GENERATED_SUBJECT_SHAPE",
        "missingJointFacts": {
            "enumeratedFileFieldLimits": "fileProjectionInventory.fields",
            "independentUsefulClassificationSource": None,
            "referenceAndAssignment": "UNSELECTED",
        },
        "recommendation": "RETAIN_HOLDS_AND_DECIDE_REFERENCE_AND_COHORT_SPECIFIC_EVIDENCE",
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
    # These are packet-integrity comparisons: even a declared rewrite must fail.
    changed = copy.deepcopy(baseline)
    record(changed[0]["information"])["identifier"] = "controlled.rewrite"
    if not projection_errors(baseline, changed):
        raise ValueError("packet integrity comparator accepted a declared rewrite")
    print("Observed rejection: declared identifier rewrite (not shape discrimination)")
    illustrative: Row = {
        "relative": "Info.plist", "role": "INFORMATION", "state": "REGULAR",
        "flags": {"LSUIElement": None, "LSBackgroundOnly": None},
    }
    table: Row = {
        "relative": "InfoPlist.loctable", "role": "GLOBAL_NAME", "state": "REGULAR",
    }
    missing = record(projection_inventory([illustrative, table])["missingEvidence"])
    supplied: list[Row] = [
        {**file, "payload": "controlled bytes", "format": "controlled",
         "typedEntries": {"LSUIElement": "malformed"}}
        for file in (illustrative, table)
    ]
    present = record(projection_inventory(supplied)["missingEvidence"])
    for key, count in (("fixedFilePayloads", 2), ("formatTags", 2),
                       ("completeTableTypedValues", 1), ("individualNameKeyCandidates", 2)):
        if missing[key] != count or present[key] != 0:
            raise ValueError(f"fact-presence control failed: {key}")
    if record(missing["ambiguousInformationFlags"]) != {
        "LSUIElement": 1, "LSBackgroundOnly": 1,
    } or record(present["ambiguousInformationFlags"]) != {
        "LSUIElement": 0, "LSBackgroundOnly": 0,
    }:
        raise ValueError("missing/malformed flag control failed")
    for annotation, payloads, formats in (("payload", 0, 1), ("format", 1, 0)):
        partial = record(projection_inventory([
            {**illustrative, annotation: "controlled fact"},
        ])["missingEvidence"])
        if partial["fixedFilePayloads"] != payloads or partial["formatTags"] != formats:
            raise ValueError(f"independent fact-presence control failed: {annotation}")
    print("Observed independent payload-only and format-only fact presence")
    try:
        projection_inventory([{**illustrative, "newUnclassifiedFact": True}])
    except ValueError as error:
        if "unclassified projection field" not in str(error):
            raise
    else:
        raise ValueError("unclassified field control failed")
    print("Observed rejection: unclassified field; supplied facts count present")
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
