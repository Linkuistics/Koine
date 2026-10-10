"""Pure composition of saved ledgers; no native operations."""
# pyright: strict
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path
from typing import cast

from application_metadata_episode_certificate import integer, objects, record, texts
from application_metadata_operation_ledger import ContractViolation, Ledger, Resource

REPORT = "docs/design/application-metadata-composition.json"
INPUTS = (
    "docs/design/application-metadata-subject.json",
    "docs/design/application-metadata-episode-certificate.json",
    "docs/design/application-metadata-owned-storage.json",
    "docs/design/application-metadata-source-root-certificate.json",
    "docs/design/application-metadata-wire.json",
    "docs/design/application-metadata-wire.graphql",
    "docs/design/application-metadata-budget-proposal.json",
    "docs/design/application-metadata-runtime-admission.json",
    "docs/specs/application-metadata-runtime-admission.md",
    "scripts/application_metadata_composition.py",
    "scripts/test_application_metadata_composition.py",
    "scripts/check_application_metadata_composition_mutations.py",
    "scripts/application_metadata_episode_certificate.py",
    "scripts/application_metadata_operation_ledger.py",
    "scripts/application_metadata_reader_plan.py",
    "scripts/application_metadata_owned_storage.py",
    "ProviderAPI/Sources/KoineProviderAPI/Resolution.swift",
    "Sources/KoineCore/ProviderContribution.swift",
    "Sources/KoineCore/Engine.swift",
    "Sources/KoineCore/RequestPolicy.swift",
    "Providers/WorkspaceProvider/Logic/LocationWalk.swift",
    "docs/specs/application-metadata-source-root.md",
    "docs/verification/application-metadata-composition.md",
    "docs/design/architecture/native-metadata-composition.d2",
    "docs/design/architecture/native-metadata-composition.svg",
    "docs/design/architecture/native-metadata-runtime-admission.d2",
    "docs/design/architecture/native-metadata-runtime-admission.svg",
    "docs/design/architecture/diagrams.json",
    "Taskfile.yml",
)

# Required contributions, not coefficients or new source/cardinality quotas.
EPISODE_OPERANDS = (
    "expanded_first_walk_and_transfer", "root_resource_or_indexed_projection",
    "reader_records_owners_and_selector_returns", "expanded_second_walk",
    "identity_merge_and_final_scalar_publication",
)
JOB_OPERANDS = (
    "preferences_source_snapshots_type_trees_and_raw_slots",
    "once_per_identifier_registration_and_two_system_seeds",
    "seed_ordered_domain_map_growth_comparisons_and_field_updates",
    "outside_path_outcomes_diagnostics_coverage_permissions_and_errors",
)


def sum_terms(values: list[int | None]) -> int | None:
    if any(value is not None and value < 0 for value in values):
        raise ContractViolation("negative contribution")
    if any(value is None for value in values):
        return None
    return sum(value for value in values if value is not None)


def compose_episode(api: int, files: int, local: int, reads: int,
                    gross: int) -> dict[str, int | None]:
    if min(api, files, local, reads, gross) < 0 or reads != 2 * files:
        raise ContractViolation("input-read overlap disagrees with complete file branches")
    if local < reads or api < reads:
        raise ContractViolation("overlap exceeds participating attempt term")
    return {
        "readerApiUpper": api, "localAttemptUpper": local, "inputReadOverlap": reads,
        "knownAttemptsUpper": api + local - reads,
        "knownGrossSubterms": gross,
        "wholeEpisodeAttempts": sum_terms([api + local - reads, None]),
        "wholeEpisodeGrossBytes": sum_terms([gross, None]),
    }


def begin_owned(ledger: Ledger, name: str, capacity: int | None, writes: int,
                *, evidence: str = "EXPLICIT_REQUEST") -> None:
    """Bind a declared transition before acquisition; all names are trace labels."""
    if evidence != "EXPLICIT_REQUEST":
        raise ContractViolation(
            "capacity evidence does not bound requested allocation: " + evidence)
    if capacity is None:
        raise ContractViolation("unbound owned capacity: " + name)
    if capacity < 0 or writes < 0:
        raise ContractViolation("negative acquisition bound")
    ledger.begin(name, (Resource(name, "owned.free", representation="OWNED"),),
                 gross_upper=capacity + writes)


def hashes(root: Path) -> dict[str, str]:
    return {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in INPUTS}


def table(columns: object, rows: object) -> list[dict[str, object]]:
    names = texts(columns)
    if not isinstance(rows, list) or len(set(names)) != len(names):
        raise ContractViolation("invalid compact table")
    result: list[dict[str, object]] = []
    for row in cast(list[object], rows):
        if not isinstance(row, list):
            raise ContractViolation("invalid compact row")
        result.append(dict(zip(names, cast(list[object], row), strict=True)))
    return result


def assess(root: Path) -> dict[str, object]:
    before = hashes(root)
    loaded = [record(json.loads((root / path).read_bytes())) for path in INPUTS[:5]]
    subject, episodes, storage, source, wire = loaded
    spellings = texts(subject["episodeSpellings"])
    if len(spellings) != 2043 or len(set(spellings)) != len(spellings):
        raise ContractViolation("complete alias episode sequence changed")
    for previous in (episodes, storage, wire):
        if previous["episodeSpellings"] != spellings:
            raise ContractViolation("per-item association changed")
    outside = objects(subject["queryPathsOutsideDirectorySubject"])
    if outside != wire["outsidePaths"] or outside != storage["outsidePaths"]:
        raise ContractViolation("outside paths were lost or fabricated")
    runs: dict[str, object] = {}
    for name, value in record(episodes["runs"]).items():
        episode_run = record(value)
        local_run = record(record(storage["runs"])[name])
        wire_run = record(record(wire["runs"])[name])
        api_rows = table(episode_run["columns"], episode_run["rows"])
        local_rows = table(local_run["columns"], local_run["rows"])
        wire_rows = table(wire["columns"], wire_run["rows"])
        if not (len(api_rows) == len(local_rows) == len(wire_rows) == len(spellings)):
            raise ContractViolation("per-item rows omitted")
        combined: list[dict[str, int | None]] = []
        for api, local, selected in zip(api_rows, local_rows, wire_rows, strict=True):
            if api["selectedInputUpper"] != local["selectedInputWriteUpper"]:
                raise ContractViolation("performed input-write upper changed across ledgers")
            row = compose_episode(integer(api["explicitReaderCallsUpper"]),
                                  integer(api["regularFilesUpper"]),
                                  integer(local["knownLocalAttemptsUpper"]),
                                  integer(local["inputReadAttemptsUpper"]),
                                  integer(local["knownLocalGrossUpper"]))
            actual = selected["actualSelectedChoiceBytes"]
            row["actualSelectedChoiceBytes"] = None if actual is None else integer(actual)
            if row["actualSelectedChoiceBytes"] is not None:
                raise ContractViolation("unknown final scalar output was fabricated")
            combined.append(row)
        known_attempts = integer(storage["sharedAttemptsIncludingFree"]) + sum(
            integer(row["knownAttemptsUpper"]) for row in combined)
        known_gross = integer(storage["sharedGross"]) + sum(
            integer(row["knownGrossSubterms"]) for row in combined)
        if known_gross != local_run["knownLocalGrossBytes"]:
            raise ContractViolation("scratch was omitted or counted twice")
        columns = list(combined[0])
        runs[name] = {
            "columns": columns,
            "rows": [[row[column] for column in columns] for row in combined],
            "knownAttemptsUpper": known_attempts, "knownGrossSubterms": known_gross,
            "wholeJobAttempts": sum_terms([known_attempts, None]),
            "wholeJobGrossBytes": sum_terms([known_gross, None]),
            "wholeJobRequestedPeak": None, "actualResponseBytes": None,
            "conditionalSingleWireUpper": wire_run["conditionalSingleBytes"],
            "conditionalFullWireUpper": wire_run["conditionalFullBytes"],
            "usefulFit": "UNESTABLISHED",
        }
    # Enumerate every unknown owned receipt from every saved branch, rather than
    # searching a hand-written pattern list. Opaque acquisitions remain separate.
    unbound: dict[str, list[str]] = defaultdict(list)
    opaque: set[str] = set()
    for name, value in record(source["toyBranchExamples"]).items():
        case = record(value)
        receipts = case["receipts"]
        if not isinstance(receipts, list):
            raise ContractViolation("invalid receipt sequence")
        for receipt in cast(list[object], receipts):
            if not isinstance(receipt, list) or len(cast(list[object], receipt)) != 3:
                raise ContractViolation("invalid receipt")
            cells = cast(list[object], receipt)
            label, kind, amount = cells
            if kind == "opaque":
                opaque.add(str(label))
            elif amount is None:
                unbound[str(label)].append(name)
    runtime = record(json.loads((root / INPUTS[7]).read_bytes()))
    replacements = record(runtime["receiptDisposition"])
    if set(replacements) != set(unbound):
        raise ContractViolation("runtime alternative omitted or invented a source/root receipt")
    if runtime["selection"] != "PENDING_HUMAN_CHOICE":
        raise ContractViolation("unselected runtime accounting was adopted")
    if runtime["strictConstruction"] != "NO_PORTABLE_PRE_CALL_CERTIFICATE_FROM_PUBLIC_ABI":
        raise ContractViolation("public ABI was substituted for a runtime allocation upper")
    result: dict[str, object] = {
        "schemaVersion": 1, "inputHashes": before,
        "purpose": "FAILED_CONSTRUCTION_WITH_KNOWN_DISJOINT_SUBTERMS",
        "nativeVerdict": "PENDING", "usefulSubjectCertificateEstablished": False,
        "grossGate": 20971520, "attemptGate": 4194304, "responseGate": 8388608,
        "episodeSpellings": spellings, "runs": runs, "outsidePaths": outside,
        "controlledPathOnly": source["controlledPathOnly"], "systemSeedGroups": 2,
        "requiredEpisodeOperands": list(EPISODE_OPERANDS),
        "requiredJobOperands": list(JOB_OPERANDS),
        "unboundReceiptLabels": dict(sorted(unbound.items())),
        "opaqueAcquisitions": sorted(opaque),
        "applicationFinalValues": None, "hostMaterializationGross": None,
        "hostEncodingPeak": None,
        "blockingDesignContract": "PRE_CALL_RUNTIME_CAPACITY_AND_PUBLICATION_BINDING",
        "pendingNativeInputs": source["actualNativeDimensions"],
        "runtimeAdmission": runtime,
    }
    if hashes(root) != before:
        raise ContractViolation("composition subjects changed during derivation")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Reproduce a failed owned composition from saved ledgers only.",
        epilog="Examples: %(prog)s --write; %(prog)s --check. "
               "Exit 0: reproduced design result (not useful fit); 1: invalid/stale inputs.",
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true", help="replace the design-only JSON report")
    group.add_argument("--check", action="store_true", help="compare every saved cell and digest")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    try:
        result = assess(root)
        if args.write:
            (root / REPORT).write_text(
                json.dumps(result, separators=(",", ":"), ensure_ascii=False) + "\n")
        elif json.loads((root / REPORT).read_bytes()) != result:
            raise ContractViolation("stale composition; reconcile inputs then rerun --write")
    except (OSError, ValueError, KeyError) as error:
        print(json.dumps({"code": "INVALID_COMPOSITION", "message": str(error)}), file=sys.stderr)
        raise SystemExit(1) from error
    print(json.dumps({"result": "REPRODUCED_FAILED_CONSTRUCTION", "nativeVerdict": "PENDING"}))


if __name__ == "__main__":
    main()
