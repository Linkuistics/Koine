"""Explicit owned-storage subcertificate; saved bytes only, no native operations.

This proposes requested raw-buffer capacities. It does not measure Swift/CF
layout or compose the missing source/root/bridge/final-response receipts.
"""
# pyright: strict

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path

from application_metadata_episode_certificate import (
    byte_count,
    integer,
    objects,
    record,
    texts,
)
from application_metadata_operation_ledger import ContractViolation, Ledger, Resource

INPUTS = (
    "docs/design/application-metadata-subject.json",
    "docs/design/application-metadata-budget-proposal.json",
    "docs/design/application-metadata-episode-certificate.json",
    "docs/design/application-metadata-source-root-certificate.json",
    "scripts/application_metadata_owned_storage.py",
    "scripts/test_application_metadata_owned_storage.py",
    "scripts/check_application_metadata_owned_storage_mutations.py",
    "scripts/application_metadata_episode_certificate.py",
    "scripts/application_metadata_operation_ledger.py",
    "scripts/application_metadata_reader_plan.py",
    "scripts/application_metadata_source_root.py",
    "scripts/application_metadata_source_root_certificate.py",
    "docs/verification/application-metadata-owned-storage.md",
    "Taskfile.yml",
)

# Explicit proposed 64-bit packed field counts, not MemoryLayout<T> observations.
RECORD_WORDS = {
    "scalar_span": 3, "owner": 4, "source_slot": 8, "copy": 14,
    "locale": 5, "seed": 6, "ordered_domain": 5, "walker": 12,
    "cycle": 8, "diagnostic": 8, "source_summary": 8,
}


def aligned(size: int) -> int:
    if size < 0:
        raise ContractViolation("negative capacity")
    return (size + 15) // 16 * 16


def capacity(payload: int, header: int = 32) -> int:
    if header not in {0, 32}:
        raise ContractViolation("unsupported explicit header")
    return aligned(payload + header)


def total(values: list[int | None]) -> int | None:
    if any(value is None for value in values):
        return None
    return sum(value for value in values if value is not None)


@dataclass(frozen=True)
class Block:
    capacity: int
    payload: int


class Store:
    """Pure event owner; allocation, header and writes spend separate receipts."""

    def __init__(self, ledger: Ledger | None = None) -> None:
        self.ledger = ledger if ledger is not None else Ledger()
        self.blocks: dict[str, Block] = {}
        self.live = 0
        self.peak = 0
        self.serial = 0

    def allocate(self, name: str, payload: int, *, header: int = 32) -> int:
        if name in self.blocks:
            raise ContractViolation("duplicate owned block")
        requested = capacity(payload, header)
        self.ledger.allocate(name, requested)
        self.blocks[name] = Block(requested, payload)
        self.live += requested
        self.peak = max(self.peak, self.live)
        if header:
            self.ledger.copy(header)  # four explicitly initialized UInt64 header fields
        return requested

    def write(self, name: str, size: int) -> None:
        block = self.blocks.get(name)
        if block is None or not 0 <= size <= block.payload:
            raise ContractViolation("write outside requested payload")
        if any(name in resource.dependencies for resource in self.ledger.resources.values()):
            raise ContractViolation("write while immutable input has a parser borrower")
        self.ledger.copy(size)

    def free(self, name: str) -> None:
        block = self.blocks[name]
        self.ledger.dispose(name)
        self.live -= block.capacity
        del self.blocks[name]

    def vector(self, name: str, count: int, stride: int) -> int:
        if count < 0 or stride <= 0 or stride % 8:
            raise ContractViolation("invalid explicit packed vector")
        requested = self.allocate(name, count * stride)
        self.write(name, count * stride)
        return requested

    def grow(self, name: str, count: int, stride: int, used: int) -> int:
        old = self.blocks[name]
        if used < 0 or count <= used or stride <= 0 or used * stride > old.payload:
            raise ContractViolation("invalid vector growth")
        # Allocation and header admission may fail while the old block remains live.
        replacement = name + ".growth"
        requested = self.allocate(replacement, count * stride)
        self.write(replacement, used * stride)
        self.free(name)
        self.ledger.transfer(replacement, Resource(name, "owned.free", representation="OWNED"))
        self.blocks[name] = self.blocks.pop(replacement)
        return requested

    def inputs(self) -> None:
        self.allocate("information", 131072, header=0)
        self.allocate("name", 131072, header=0)
        self.allocate("eof", 2, header=0)
        self.allocate("conversion", 8193, header=0)

    def parsed(self, name: str) -> None:
        if name not in {"information", "name"} or name not in self.blocks:
            raise ContractViolation("parser lacks immutable input")
        parser = Resource("parser." + name, "CFRelease.parser", (name,))
        self.ledger.begin("CFData/plist.opaque-acquisition", (parser,))
        self.ledger.finish((parser.name,))

    def retire_parser(self, name: str) -> None:
        self.ledger.dispose("parser." + name)

    def read_input(self, name: str, size: int, eof: int = 0) -> None:
        if name not in {"information", "name"} or not 0 <= size <= 131072 or eof not in {0, 1}:
            raise ContractViolation("invalid bounded input prefix")
        if name not in self.blocks or any(
            name in resource.dependencies for resource in self.ledger.resources.values()
        ):
            raise ContractViolation("input is absent or still immutable")
        self.ledger.read(size)
        self.ledger.read(eof)

    def project(self, size: int, bound: int, *, complete: bool = True) -> None:
        if bound not in {512, 1024, 8192} or not 0 <= size <= bound:
            raise ContractViolation("scalar outside existing UTF-8 gate")
        self.write("conversion", size)  # actual CFStringGetBytes prefix only
        if complete:
            self.serial += 1
            name = "scalar-" + str(self.serial)
            self.allocate(name, size + 1)
            self.write(name, size + 1)  # retained bytes and one NUL; no adoption fiction

    def cleanup(self) -> None:
        self.ledger.retire_all()
        self.blocks.clear()
        self.live = 0
        self.ledger.return_slot()


def vector_cost(count: int, stride: int) -> tuple[int, int]:
    """Exact requested capacity + header + one populated payload, and four events."""
    return capacity(count * stride) + 32 + count * stride, 4


def projection_cost(size: int) -> tuple[int, int]:
    """One actual scratch prefix + independently retained terminated value."""
    return size + capacity(size + 1) + 32 + size + 1, 5


def hashes(root: Path) -> dict[str, str]:
    return {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in INPUTS}


def derive(root: Path) -> dict[str, object]:
    before = hashes(root)
    subject = record(json.loads((root / INPUTS[0]).read_bytes()))
    proposal = record(json.loads((root / INPUTS[1]).read_bytes()))
    previous = record(json.loads((root / INPUTS[2]).read_bytes()))
    if proposal["subjectSha256"] != before[INPUTS[0]]:
        raise ValueError("selection names a different subject")
    human = record(proposal["humanSelection"])
    if human["applicationGrossBytes"] != 20971520 or human["accounting"] != (
        "CUMULATIVE_GROSS_PER_READ_PER_COPY_NO_REFUND"
    ):
        raise ValueError("selected gross contract changed")
    all_rows = objects(subject["baseline"]) + objects(subject["fixtures"])
    by_path = {str(row["path"]): row for row in all_rows}
    episode_targets = texts(subject["combinedEpisodes"])
    spellings = texts(subject["episodeSpellings"])
    if len(spellings) != 2043 or len(set(spellings)) != 2043:
        raise ValueError("saved distinct alias episodes changed")
    if spellings != previous["episodeSpellings"] or len(episode_targets) != len(spellings):
        raise ValueError("saved episode sequence disagrees")
    common: list[dict[str, object]] = []
    runs: dict[str, object] = {}
    scratch = Store()
    scratch.inputs()
    shared_gross = scratch.ledger.spent_bytes
    shared_capacity = scratch.peak
    scratch.cleanup()
    shared_attempts = scratch.ledger.spent_attempts
    for target, spelling in zip(episode_targets, spellings, strict=True):
        row = by_path[target]
        locales = texts(row["locales"])
        raw_entries = texts(row["rawDirectEntries"])
        tables = [f for f in objects(row["files"]) if str(f["relative"]).endswith(".loctable")]
        keys = [key for table in tables for key in texts(table["localeKeys"])]
        # This is the explicitly selected *local retained projection* design,
        # not the unknown native key/CF ownership or raw rejected-entry contents.
        direct_costs = [projection_cost(byte_count(key)) for key in locales]
        selector_key_costs = [projection_cost(byte_count(key.removesuffix(".lproj")))
                              for key in locales]
        raw_costs = [projection_cost(byte_count(key)) for key in raw_entries]
        table_costs = [projection_cost(byte_count(key)) for key in keys]
        extraction_costs = [vector_cost(len(texts(table["localeKeys"])), 8)
                            for table in tables for _ in range(2)]
        entry: dict[str, object] = {
            "spelling": spelling,
            "resolvedRootBytes": integer(row["resolvedRootBytes"]),
            "maximumObservedNameBytes": max(
                [integer(f.get("maximumNameBytes", 0)) for f in objects(row["files"])]
                + [byte_count(f["name"]) for f in objects(row["files"])
                   if isinstance(f.get("name"), str)] + [0]),
            "directProjectionGross": sum(value[0] for value in direct_costs),
            "rawEntryProjectionGross": sum(value[0] for value in raw_costs),
            "directSelectorKeyProjectionGross": sum(value[0] for value in selector_key_costs),
            "tableProjectionGross": sum(value[0] for value in table_costs),
            "tableExtractionGross": sum(value[0] for value in extraction_costs),
            "projectionAndExtractionAttempts": sum(value[1] for value in
                direct_costs + raw_costs + selector_key_costs + table_costs + extraction_costs),
            "locProvenance": keys.count("LocProvenance"),
            "rejectedEntries": texts(row["rejectedLocaleEntries"]),
            "unknownRejectedEntryTypeOutcome": None if row["rejectedLocaleEntries"] else 0,
        }
        common.append(entry)
    for preferences, value in record(proposal["selectionRuns"]).items():
        plans = objects(record(value)["rows"])
        if [plan["path"] for plan in plans] != episode_targets:
            raise ValueError("selection lost an alias episode")
        rows: list[dict[str, object]] = []
        for target, base, plan in zip(episode_targets, common, plans, strict=True):
            row = by_path[target]
            bases = texts(plan["plannedBases"])
            resource = str(row["resourceBase"])
            wanted = {f"{resource}/{directory}/{family}" for directory in bases for family in (
                "InfoPlist-macos.strings", "InfoPlist.strings",
                "InfoPlist-macos.loctable", "InfoPlist.loctable",
            )}
            files = [f for f in objects(row["files"]) if f["role"] in
                     {"INFORMATION", "GLOBAL_NAME"} or f["relative"] in wanted]
            sizes = [integer(f["bytes"]) for f in files]
            if any(size > 131072 for size in sizes):
                raise ValueError("saved selected files exceed individual input bound")
            reader_terms = [integer(base[key]) for key in (
                "rawEntryProjectionGross", "directProjectionGross",
                "directSelectorKeyProjectionGross", "tableProjectionGross", "tableExtractionGross")]
            rows.append({
                "spelling": base["spelling"],
                "selectedInputWriteUpper": sum(sizes),
                "extraEOFWriteUpper": len(sizes),
                "inputReadAttemptsUpper": 2 * len(sizes),
                "knownLocalGrossUpper": sum(sizes) + len(sizes) + sum(reader_terms),
                "knownLocalAttemptsUpper": 2 * len(sizes)
                    + integer(base["projectionAndExtractionAttempts"]),
                "wholeEpisodeGrossBytes": None,
                "wholeEpisodeAttempts": None,
                "finalScalars": None,
            })
        prior_run = record(record(previous["runs"])[preferences])
        if sum(integer(row["selectedInputWriteUpper"]) for row in rows) != (
            prior_run["selectedInputUpper"]
        ):
            raise ValueError("independent selected input changed")
        runs[preferences] = {
            "rows": rows,
            "knownLocalGrossBytes": shared_gross
                + sum(integer(row["knownLocalGrossUpper"]) for row in rows),
            "knownLocalAttempts": shared_attempts
                + sum(integer(row["knownLocalAttemptsUpper"]) for row in rows),
            "wholeJobGrossBytes": total([shared_gross, None]),
            "wholeJobAttempts": None,
            "responseBytes": None,
        }
    result: dict[str, object] = {
        "schemaVersion": 1, "inputHashes": before,
        "representation": "PROPOSED_EXPLICIT_RAW_BUFFER_CAPACITIES_NOT_SWIFT_LAYOUT",
        "nativeVerdict": "PENDING", "usefulSubjectCertificateEstablished": False,
        "grossGate": 20971520, "attemptGate": 4194304, "responseGate": 8388608,
        "sharedRequestedCapacity": shared_capacity, "sharedGross": shared_gross,
        "sharedAttemptsIncludingFree": shared_attempts,
        "recordWords": RECORD_WORDS,
        "episodeSpellings": spellings, "commonRows": common, "runs": runs,
        "outsidePaths": objects(subject["queryPathsOutsideDirectorySubject"]),
        "unboundTerms": [
            "native_source_scalar_and_type_tree_dimensions",
            "source_overlay_bridge_record_seed_domain_and_owner_operations",
            "expanded_walk_vector_map_cycle_error_and_transfer_operations",
            "direct_raw_rejected_and_selector_return_scalar_dimensions",
            "regional_table_getter_values_and_final_scalar_operations",
            "publication_swift_string_array_dictionary_bridge_COW_and_host_conversion",
            "complete_selected_response_alias_fragment_error_and_escape_accounting",
        ],
    }
    if hashes(root) != before:
        raise ValueError("owned-storage subjects changed during derivation")
    return result


def tabulate(rows: list[dict[str, object]]) -> tuple[list[str], list[list[object]]]:
    columns = list(rows[0]) if rows else []
    if any(list(row) != columns for row in rows):
        raise ValueError("per-item columns changed within a table")
    return columns, [[row[column] for column in columns] for row in rows]


def compact(result: dict[str, object]) -> dict[str, object]:
    """Preserve every cell while storing field names once, like the episode ledger."""
    saved = dict(result)
    spellings = texts(result["episodeSpellings"])

    def associate(value: object) -> list[dict[str, object]]:
        items = objects(value)
        if [row.get("spelling") for row in items] != spellings:
            raise ValueError("per-item spellings lost their complete association")
        return [{key: cell for key, cell in row.items() if key != "spelling"} for row in items]

    columns, rows = tabulate(associate(result["commonRows"]))
    saved["commonColumns"], saved["commonRows"] = columns, rows
    runs: dict[str, object] = {}
    for name, value in record(result["runs"]).items():
        run = dict(record(value))
        columns, rows = tabulate(associate(run["rows"]))
        run["columns"], run["rows"] = columns, rows
        runs[name] = run
    saved["runs"] = runs
    return saved


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Derive explicit owned local subterms from saved JSON; no native/fit verdict.",
        epilog="Example: python3 scripts/application_metadata_owned_storage.py --check\n"
        "Exit 0: reproduced subcertificate; 1: changed/invalid inputs; 2: usage.\n"
        "--write replaces only the derived JSON; it performs no target capture.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    output = root / "docs/design/application-metadata-owned-storage.json"
    try:
        result = derive(root)
        if args.write:
            output.write_text(json.dumps(compact(result), separators=(",", ":")) + "\n")
        elif compact(result) != json.loads(output.read_bytes()):
            raise ValueError("per-item subcertificate changed; inspect and regenerate")
    except (OSError, ValueError, KeyError) as error:
        print(json.dumps({"code": "OWNED_STORAGE_INVALID", "error": str(error),
                          "remediation": "Reconcile saved inputs then rerun; do not capture native "
                          "targets or turn null whole-job terms into zero."}), file=sys.stderr)
        raise SystemExit(1) from error
    print(json.dumps({"nativeVerdict": "PENDING", "usefulSubjectCertificateEstablished": False,
                      "sharedRequestedCapacity": result["sharedRequestedCapacity"],
                      "runs": {key: {name: record(value)[name] for name in (
                          "knownLocalGrossBytes", "knownLocalAttempts", "wholeJobGrossBytes",
                          "wholeJobAttempts", "responseBytes")}
                               for key, value in record(result["runs"]).items()}}))


if __name__ == "__main__":
    main()
