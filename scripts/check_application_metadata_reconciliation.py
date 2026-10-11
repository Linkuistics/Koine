"""Cross-family design drift controls; inherited evidence never passes native acceptance."""
# pyright: strict
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import cast

from application_metadata_episode_certificate import record

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "docs/design/application-metadata-contract.json"
CASES = "docs/verification/native-discovery-acceptance.md"
SUITE = (
    "design:application-metadata-subject-check",
    "design:application-metadata-reader-plan-check",
    "design:application-metadata-operation-ledger-check",
    "design:application-metadata-episode-certificate-check",
    "design:application-metadata-source-root-check",
    "design:application-metadata-owned-storage-check",
    "design:application-metadata-wire-check",
    "design:application-metadata-composition-check",
    "design:search-check",
    "design:localized-boundary-check",
    "design:long-applications-check",
    "design:settings-check",
    "check:docs",
)
SKIP = {".git", ".jj", ".build", "node_modules", "__pycache__", ".pytest_cache",
        ".ruff_cache", ".venv"}


def load(path: str) -> dict[str, object]:
    return record(json.loads((ROOT / path).read_text()))


def contract_errors(subject: dict[str, object]) -> list[str]:
    """Check selected decisions against their independent k217/k231 requirements."""
    errors: list[str] = []
    reader = record(subject["reader"])
    admission = record(subject["admission"])
    qualification = record(subject["qualification"])
    expected_reader: dict[str, object] = {
        "layoutPriority": ["Contents", "Support Files", "Resources", "."],
        "informationBases": ["Contents", "Support Files", "Resources", "."],
        "resourceBases": ["Contents/Resources", "Support Files/Resources", "Resources", "."],
        "informationFiles": ["Info-macos.plist", "Info.plist"],
        "nameFiles": ["InfoPlist-macos.strings", "InfoPlist.strings",
                      "InfoPlist-macos.loctable", "InfoPlist.loctable"],
        "priority": "BASE_FIRST_GLOBAL_THEN_EXACT_DIRECT_PLAN",
        "advanceLayoutOrInformation": "CHECKED_ABSENCE_ONLY",
        "advanceName": "CHECKED_ABSENCE_OR_HEALTHY_NO_NAME_ONLY",
        "nameKeyPriority": ["CFBundleDisplayName", "CFBundleName"],
        "inventories": "INDEPENDENT_COMPLETE_DIRECT_AND_EACH_TABLE",
        "reservedTableKey": "LocProvenance",
        "reservedTableKeyIsLanguage": False,
        "selector": "EXPLICIT_PREFERENCES_EXACT_DEVELOPMENT_FIRST_THEN_BYTE_SORTED",
        "selectorReturns": "ALL_RAW_SLOTS_EXACT_MAP_THEN_ORDERED_DEDUPLICATION",
        "backstops": ["EXACT_OBSERVED_BASE", "EXACT_OBSERVED_DEVELOPMENT"],
        "regularFileBytes": 131072,
        "dictionaryKeys": 4096,
        "lastOrdinaryRootBytes": 1023,
        "firstIndexedRootBytes": 1024,
        "foreignBundleLookup": False,
        "recursiveResourceTraversal": False,
        "crossCopyMetadata": False,
        "fileReads": "EXACT_SIZE_AND_EOF_NO_RETRY",
        "oversize": "PER_OBJECT_AFFECTED_FACT_REFUSAL_RETAIN_CHOICE",
        "refusedNameFallback": "STOP_ALL_LATER_OR_UNLOCALIZED_RESCUE",
    }
    expected_admission: dict[str, object] = {
        "rawURLObservations": 8192, "distinctSpellings": 2048,
        "runningObjects": 2048, "identifierGroups": 2050, "retainedChoices": 2048,
        "indexedTypeValues": 65536, "metadataPlanEntries": 65536,
        "grossBytes": 20971520, "explicitAttempts": 4194304,
        "coreResponseBytes": 8388608, "readDeadlineSeconds": 3,
        "coreDeadlineSeconds": 5, "sharedTrueReturnSlots": 4, "refund": False,
        "sharedExhaustion": "FAILED_NULL_ITEMS",
        "diagnosticSaturation": "CONTINUE_WITH_FIXED_SOURCE_REASON_SUMMARIES",
        "numericScope": "CONTROLLED_RAW_REQUESTS_WRITES_AND_EXPLICIT_OPERATIONS",
        "publicationOwner": "PROVIDER", "runtimeInternalsExcluded": True,
        "unknownExplicitOperandsExcluded": False, "totalHeapOrPeakGuarantee": False,
        "settingsAndLocationGatesChanged": False,
    }
    expected_qualification: dict[str, object] = {
        "readerSemanticsEstablished": True, "usefulFiniteCertificateEstablished": False,
        "consumptionHold": True, "producer": "application-localized-metadata-k215",
        "mandatoryWholeProducerReview": True, "nativeVerdict": "PENDING",
        "outsideQueryObservations": 149, "systemSeedGroups": 2, "nameByteWitness": 129,
        "supportFloor": "macOS 26+ Apple Silicon",
        "historicalCensusQualifiesMacOS27": False, "sourceLocaleOrUsefulCategoryLoss": False,
        "usefulWitnesses": ["Find My English", "Voice Memos English", "German loctable"],
        "requiredSeams": ["PUBLIC_GRAPHQL", "ACTUAL_PROVIDER_HOST_BINARIES",
                          "ISOLATED_SIGNED_SUPPORTED_MACOS_VMS"],
    }
    for label, actual, expected in (
        ("reader", reader, expected_reader), ("admission", admission, expected_admission),
        ("qualification", qualification, expected_qualification),
    ):
        for key, value in expected.items():
            if actual.get(key) != value:
                errors.append(f"{label}.{key} differs from the selected contract")
    return errors


def case_errors(text: str) -> list[str]:
    """Find actual case definitions, rather than trusting a G/N/V range mention."""
    defined = set(re.findall(r"(?m)^(?:\|\s*|)([GNV]\d+)(?=\s|\|)", text))
    expected = {f"{family}{n}" for family, size in (("G", 11), ("N", 8), ("V", 13))
                for n in range(1, size + 1)}
    errors = [f"missing native case definition {case}" for case in sorted(expected - defined)]
    if "every native G/N/V stays pending" not in text:
        errors.append("native acceptance pending boundary missing")
    return errors


def check_family() -> None:
    errors = contract_errors(load(CONTRACT)) + case_errors((ROOT / CASES).read_text())
    for name in ("application-localized-admission", "application-population"):
        historical = load(f"docs/design/{name}.json")
        if (historical.get("currentContract") != "application-metadata-contract.json"
                or historical.get("artifactScope") != "HISTORICAL_REFUTED_COUNTEREXAMPLE_ONLY"):
            errors.append(f"{name}: historical/current contract distinction missing")
    long = load("docs/design/long-application-metadata.json")
    if long.get("currentContract") != "application-metadata-contract.json":
        errors.append("long metadata current contract pointer missing")
    profiles = sorted((ROOT / "docs/design/profiles").glob("*workspace-native*.json"))
    if len(profiles) != 4:
        errors.append("four distinct complete native profiles required")
    for path in profiles:
        profile = record(json.loads(path.read_text()))
        if profile.get("applicationMetadataContract") != "../application-metadata-contract.json":
            errors.append(f"{path.name}: current contract pointer missing")
    composition = load("docs/design/application-metadata-composition.json")
    if (composition["nativeVerdict"] != "PENDING"
            or composition["usefulSubjectCertificateEstablished"] is not False
            or composition["grossGate"] != 20971520):
        errors.append("conditional composition outcome/gate changed")
    runs = record(composition["runs"])
    for name, gross, attempts, partial in (
        ("en-AU,en", 19869316, 950247, 23502420), ("de", 20043423, 983378, 23676527),
    ):
        run = record(runs[name])
        expected: dict[str, object] = {
            "scopedKnownGrossSubterms": gross, "scopedKnownAttemptsUpper": attempts,
            "controlledPathEnclosureGross": partial, "usefulFit": "UNESTABLISHED",
            "scopedWholeJobGrossBytes": None, "scopedWholeJobAttempts": None,
            "actualResponseBytes": None,
        }
        if any(run.get(key) != value for key, value in expected.items()):
            errors.append(f"{name}: failed conservative enclosure or conditional operands changed")
    for path in ("docs/design/workspace-search-schema.graphql",
                 "docs/design/desktop-workspace-native-schema-extension-host.graphql"):
        sdl = (ROOT / path).read_text()
        if any(term not in sdl for term in (
            "strings/loctable", "131072", "20971520", "4194304",
            "provider-owned", "consumption hold",
        )):
            errors.append(f"{path}: selected reader/admission description incomplete")
    # This bounded class check verifies live consumers, not a global absence of
    # old numeric literals (which remain necessary in historical counterexamples).
    for handle in ("k7", "k19", "k191", "k127", "k123", "k30", "k93"):
        candidates = [path for path in (ROOT / ".grove").rglob("*")
                      if re.search(rf"-{handle}(?:\.md)?$", path.name)
                      and "DONE" not in path.name]
        if len(candidates) != 1:
            errors.append(f"{handle}: expected one live consumer charter")
            continue
        path = candidates[0]
        if path.is_dir():
            briefs = list(path.glob("_*.md"))
            if len(briefs) != 1:
                errors.append(f"{handle}: expected one node brief")
                continue
            path = briefs[0]
        text = path.read_text()
        if any(term not in text for term in (
            "Selected application reader and retained consumption hold",
            "131,072", "20,971,520", "LocProvenance", "ProviderValue", "pending",
        )):
            errors.append(f"{handle}: selected contract/hold handoff incomplete")
    if errors:
        raise ValueError("\n".join(errors))
    print("Current family, four profiles, actual 32 native cases and failed enclosure agree.")


def broken_controls() -> None:
    original = load(CONTRACT)
    mutations: tuple[tuple[str, str, object], ...] = (
        ("reader", "regularFileBytes", 65536), ("admission", "grossBytes", 8388608),
        ("reader", "nameFiles", ["InfoPlist-macos.strings", "InfoPlist.strings"]),
        ("reader", "oversize", "FAILED_NULL_ITEMS"),
        ("reader", "refusedNameFallback", "TRY_PLAIN_INFORMATION"),
        ("reader", "reservedTableKeyIsLanguage", True),
        ("reader", "selectorReturns", "FIRST_RESULT_ONLY"),
        ("qualification", "usefulFiniteCertificateEstablished", True),
        ("qualification", "consumptionHold", False),
        ("qualification", "nativeVerdict", "PASSED"),
        ("admission", "unknownExplicitOperandsExcluded", True),
        ("admission", "publicationOwner", "HOST"), ("admission", "refund", True),
        ("admission", "totalHeapOrPeakGuarantee", True),
    )
    for section, key, value in mutations:
        subject = copy.deepcopy(original)
        record(subject[section])[key] = value
        if not contract_errors(subject):
            raise ValueError(f"undetected contract mutation: {section}.{key}")
        print(f"Rejected drift: {section}.{key}")
    text = (ROOT / CASES).read_text()
    for case in ("G11", "N8", "V13"):
        changed = re.sub(rf"(?m)^(\|\s*|){case}(?=\s|\|)", r"\1REMOVED", text)
        if not case_errors(changed):
            raise ValueError(f"undetected actual case omission: {case}")
    with TemporaryDirectory(prefix="koine-reconciliation-links-") as directory:
        scratch = Path(directory)
        (scratch / "scripts").mkdir()
        shutil.copyfile(ROOT / "scripts/check-doc-links.py", scratch / "scripts/check-doc-links.py")
        (scratch / "target.md").write_text("# Target\n")
        source = scratch / "README.md"
        for link, expected in (("target.md#target", 0), ("target.md#missing", 1)):
            source.write_text(f"[Target]({link})\n")
            result = subprocess.run([sys.executable, "scripts/check-doc-links.py"],
                                    cwd=scratch, capture_output=True, check=False)
            if result.returncode != expected:
                raise ValueError("document-link control did not discriminate a broken anchor")
    print("Rejected actual case omissions and broken document anchor; originals pass.")


def frozen_inputs() -> dict[str, str]:
    """Freeze repository subjects and runtime sources used by the declared suite."""
    paths: set[Path] = set()
    for directory, dirs, files in os.walk(ROOT):
        dirs[:] = sorted(name for name in dirs if name not in SKIP)
        for name in files:
            path = Path(directory) / name
            if not path.is_symlink():
                paths.add(path)
    for relative in ("clients/contract-only/node_modules/graphql",
                     ".build/checkouts/GraphQL/Sources/GraphQL"):
        paths.update(path for path in (ROOT / relative).rglob("*") if path.is_file())
    # Include executable contents as well as the lockfiles/runtime source tree.
    for name in ("task", "python3", "node", "d2", "ruff", "uv", "swift"):
        found = shutil.which(name)
        if found is None:
            raise ValueError(f"required executable unavailable: {name}")
        paths.add(Path(found).resolve())
    return {str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path):
            hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(paths)}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite", action="store_true", help="run every inherited frozen check")
    args = parser.parse_args()
    before = frozen_inputs()
    check_family()
    broken_controls()
    if cast(bool, args.suite):
        for name in SUITE:
            print(f"Checking {name}", flush=True)
            subprocess.run(["task", name], cwd=ROOT, check=True)
    after = frozen_inputs()
    output = ROOT / ".build/application-metadata-reconciliation"
    output.mkdir(parents=True, exist_ok=True)
    for name, values in (("before", before), ("after", after)):
        (output / f"{name}.json").write_text(json.dumps(values, indent=2) + "\n")
    if before != after:
        changed = sorted(key for key in before.keys() | after.keys()
                         if before.get(key) != after.get(key))
        raise ValueError("check inputs changed during run: " + ", ".join(changed))
    print(f"Frozen before/after equality: {len(before)} per-item inputs; native verdict PENDING.")


if __name__ == "__main__":
    main()
