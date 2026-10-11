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
from application_metadata_operation_ledger import ContractViolation

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "docs/design/application-metadata-contract.json"
CASES = "docs/verification/native-discovery-acceptance.md"
SUITE = (
    "design:application-metadata-qualification-check",
    "design:application-metadata-subject-check",
    "design:application-metadata-reader-plan-check",
    "design:application-metadata-operation-ledger-check",
    "design:application-metadata-episode-certificate-check",
    "design:application-metadata-source-root-check",
    "design:application-metadata-owned-storage-check",
    "design:application-metadata-wire-check",
    "design:application-metadata-composition-check",
    "design:application-metadata-grouped-check",
    "design:search-check",
    "design:localized-boundary-check",
    "design:long-applications-check",
    "design:settings-check",
    "check:docs",
)
SKIP = {".git", ".jj", ".build", "node_modules", "__pycache__", ".pytest_cache",
        ".ruff_cache", ".venv"}
PRIVATE_PREREQUISITES = (
    "DESIGN", "WHOLE_REVIEW_INTEGRATION", "SOURCE_ACCESS_REVIEW",
    "REVIEWED_FINITE_SUBJECT", "OWNERSHIP_IMAGE_REVIEW", "NORMALIZATION_REVIEW",
    "WHOLE_DISCOVERY_DESIGN_REVIEW", "QUALIFICATION_PLAN",
)
RELEASE_EVIDENCE = (
    "subjects", "nine_tapes", "full_response", "useful_witnesses", "serviceability",
    "read_policy", "authority_images_disclosures_compatibility", "gates_deadlines_slots",
    "population_shape", "release_image_correspondence", "cleanup_outcomes",
)
EPISODE_TAPES = (
    "expanded_first_walk_and_transfer", "root_resource_or_indexed_projection",
    "reader_records_owners_and_selector_returns", "expanded_second_walk",
    "identity_merge_and_final_scalar_publication",
)
JOB_TAPES = (
    "preferences_source_snapshots_type_trees_and_raw_slots",
    "once_per_identifier_registration_and_two_system_seeds",
    "seed_ordered_domain_map_growth_comparisons_and_field_updates",
    "outside_path_outcomes_diagnostics_coverage_permissions_and_errors",
)


def transition_admitted(
    spent: tuple[int, int], cleanup: tuple[int, int], failure: tuple[int, int],
    work: tuple[int | None, int | None], possible_cleanup: tuple[int, int], *,
    limits: tuple[int, int] = (20971520, 4194304), frozen: bool = False,
    terminal_guard: tuple[int, int] = (0, 0),
) -> bool:
    """Pure arithmetic: spec C = cleanup + terminal_guard; W includes admitted checks."""
    if frozen or any(value is None for value in work):
        return False
    if terminal_guard[1] <= 0:
        return False
    terms = (spent, cleanup, failure, cast(tuple[int, int], work), possible_cleanup)
    terms += (terminal_guard,)
    if any(value < 0 for term in terms for value in term):
        return False
    return all(sum(term[index] for term in terms) <= limits[index] for index in (0, 1))


def settle_prefix(
    spent: tuple[int, int], actual: tuple[int, int], upper: tuple[int, int],
) -> tuple[int, int]:
    """Only unused reservation ends; all performed failure prefixes remain spent."""
    if any(value < 0 for value in (*spent, *actual, *upper)) or any(
        actual[index] > upper[index] for index in (0, 1)
    ):
        raise ContractViolation("actual prefix outside admitted upper")
    return spent[0] + actual[0], spent[1] + actual[1]


def settle_guard(
    spent: tuple[int, int], credit: tuple[int, int], actual: tuple[int, int], *,
    admitted: bool, frozen: bool = False,
) -> tuple[tuple[int, int], tuple[int, int], bool]:
    """Admitted checks spend W and retain H; the first terminal check consumes H."""
    if frozen or credit[1] <= 0:
        raise ContractViolation("no guard evaluation after terminal freeze or without credit")
    charged = settle_prefix(spent, actual, credit)
    return charged, credit if admitted else (0, 0), not admitted


def prose_errors(path: str, text: str) -> list[str]:
    """Enumerate each repeated eligibility section; reject its original weaker rule."""
    errors: list[str] = []
    flat = " ".join(text.split())
    weak = ("before analytic fit, after complete design, whole-producer review "
            "and earned integration")
    if weak in flat:
        errors.append(f"{path}: abbreviated private eligibility")
    sections = re.split(r"(?m)^## ", text)
    for section in sections:
        if section.startswith("Grouped refinement and retained hold\n") and (
            "application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence"
            not in section
        ):
            errors.append(f"{path}: grouped summary lacks the canonical eligibility predicate")
    if "until complete useful certification" in flat:
        errors.append(f"{path}: obsolete analytic hold wording")
    return errors


def private_eligible(completed: set[str]) -> bool:
    """Eligibility never depends on the held ordinary consumer or analytic fit."""
    return set(PRIVATE_PREREQUISITES).issubset(completed)


def useful_release(private_ready: bool, evidence: dict[str, bool | None]) -> bool:
    """Synthetic gate exercise; repository native evidence remains PENDING."""
    return private_ready and all(evidence.get(key) is True for key in RELEASE_EVIDENCE)


def load(path: str) -> dict[str, object]:
    return record(json.loads((ROOT / path).read_text()))


def contract_errors(subject: dict[str, object]) -> list[str]:
    """Check selected decisions and the complete k236 private construction."""
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
        "acceptanceOrder": "GUARDED_PRIVATE_QUALIFICATION_BEFORE_ANALYTIC_FIT",
        "analyticFitRequiredBeforePrivateImplementation": False,
        "privateImplementationScope": "EXISTING_N5_N8_V11_V13_QUALIFICATION",
        "privateQualificationDesignEstablished": True,
        "privateImplementationEligibleNow": False,
        "privateImplementationRequiresWholeReviewAndIntegration": True,
        "advertisementHold": True, "releaseRequiresFullUsefulQualification": True,
        "failedRefusedOrMissingRequiredUsefulCasePasses": False,
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
    guard = record(subject.get("privateGuard", {}))
    expected_guard: dict[str, object] = {
        "reserveFailureEnvelope": True, "reserveRawCleanupWrites": True,
        "guardBookkeepingCharged": True,
        "unknownExplicitOperand": "REFUSE_BEFORE_OPTIONAL_INVOCATION",
        "snapshotCountsBeforeDedup": True,
        "pendingSlotEnds": "TRUE_RETURN_AFTER_BORROWERS_AND_CLEANUP",
        "prerequisiteDesignRequiresUsefulQualification": False,
        "planningOwner": "REVIEWED_QUALIFICATION_PLAN",
        "ordinaryConsumptionBeforeQualification": False,
        "reserveTerminalGuardEvaluation": True,
        "terminalGuard": "RETAIN_ON_ADMIT_SPEND_ON_FIRST_REFUSAL_OR_FINAL_RETURN",
        "cleanupFailure": "FAILED_NULL_INSPECTION_FAILED_OR_SUPPRESSED",
        "applicationProtocolOwner": "PRIVATE_QUALIFICATION_SPEC",
        "usefulExhaustionRoute": "ONCE_TO_HUMAN_COVERAGE_DECISION",
        "populationShapeDesignEstablished": False,
        "releaseImageRule": "MATCHED_ORDINARY_DISABLED_ENABLED_AND_REVIEWED_RECIPE_CORRESPONDENCE",
        "prerequisites": list(PRIVATE_PREREQUISITES), "completedPrerequisites": ["DESIGN"],
        "episodeTapes": list(EPISODE_TAPES), "jobTapes": list(JOB_TAPES),
        "releaseEvidence": list(RELEASE_EVIDENCE), "nativeEvidenceComplete": False,
    }
    for key, value in expected_guard.items():
        if guard.get(key) != value:
            errors.append(f"privateGuard.{key} differs from guarded qualification")
    if subject.get("privateQualification") != (
        "../specs/application-metadata-private-qualification.md"
    ):
        errors.append("private qualification construction pointer missing")
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
    # Non-code docs/scripts are excluded from the graph: enumerate this entire
    # prose surface directly, including every repeated section and live charter.
    prose_paths = list((ROOT / "docs").rglob("*.md")) + [ROOT / "CONTEXT.md"]
    prose_paths += [path for path in (ROOT / ".grove").rglob("*.md")
                    if "-DONE-" not in path.name and "-ABANDONED-" not in path.name]
    for path in prose_paths:
        errors += prose_errors(str(path.relative_to(ROOT)), path.read_text())
    runtime = load("docs/design/application-metadata-runtime-admission.json")
    if set(record(runtime["requiredOperandRecipes"])) != set(EPISODE_TAPES + JOB_TAPES):
        errors.append("private construction and runtime packet disagree on the nine tapes")
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
    grouped = load("docs/design/application-metadata-grouped-storage.json")
    if (grouped.get("usefulFitEstablished") is not False
            or grouped.get("nativeVerdict") != "PENDING"
            or grouped.get("episodeSpellings") != composition["episodeSpellings"]
            or grouped.get("outsidePaths") != composition["outsidePaths"]
            or load(CONTRACT).get("groupedCandidate")
            != "application-metadata-grouped-storage.json"):
        errors.append("grouped candidate lost its complete association/hold handoff")
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
        ("qualification", "acceptanceOrder", "ANALYTIC_FIT_BEFORE_IMPLEMENTATION"),
        ("qualification", "analyticFitRequiredBeforePrivateImplementation", True),
        ("qualification", "privateImplementationScope", "GENERAL_PROVIDER_RELEASE"),
        ("qualification", "privateQualificationDesignEstablished", False),
        ("qualification", "privateImplementationEligibleNow", True),
        ("qualification", "privateImplementationRequiresWholeReviewAndIntegration", False),
        ("qualification", "advertisementHold", False),
        ("qualification", "releaseRequiresFullUsefulQualification", False),
        ("qualification", "failedRefusedOrMissingRequiredUsefulCasePasses", True),
        ("admission", "unknownExplicitOperandsExcluded", True),
        ("admission", "publicationOwner", "HOST"), ("admission", "refund", True),
        ("admission", "totalHeapOrPeakGuarantee", True),
        ("privateGuard", "reserveFailureEnvelope", False),
        ("privateGuard", "reserveRawCleanupWrites", False),
        ("privateGuard", "guardBookkeepingCharged", False),
        ("privateGuard", "unknownExplicitOperand", "EXCLUDE"),
        ("privateGuard", "pendingSlotEnds", "CALLER_TIMEOUT"),
        ("privateGuard", "episodeTapes", list(EPISODE_TAPES[:-1])),
        ("privateGuard", "jobTapes", list(JOB_TAPES[:-1])),
        ("privateGuard", "prerequisiteDesignRequiresUsefulQualification", True),
        ("privateGuard", "ordinaryConsumptionBeforeQualification", True),
        ("privateGuard", "nativeEvidenceComplete", True),
        ("privateGuard", "reserveTerminalGuardEvaluation", False),
        ("privateGuard", "cleanupFailure", "PUBLISH_USEFUL_TREE"),
        ("privateGuard", "applicationProtocolOwner", "TWO_DESIGN_OWNERS"),
        ("privateGuard", "populationShapeDesignEstablished", True),
        ("privateGuard", "releaseImageRule", "VERSION_EQUALITY"),
        ("privateGuard", "usefulExhaustionRoute", "AUTOMATIC_REFINEMENT_LOOP"),
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
