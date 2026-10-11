"""Pure linked-slab candidate and saved receipt composition; never native capture."""
# pyright: strict
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import TypedDict

from application_metadata_composition import EPISODE_OPERANDS, JOB_OPERANDS, raw_block_cost, table
from application_metadata_episode_certificate import byte_count, integer, objects, record, texts
from application_metadata_operation_ledger import ContractViolation, Limit

REPORT = "docs/design/application-metadata-grouped-storage.json"
REPLACED = (
    "rawEntryProjectionGross", "directProjectionGross", "directSelectorKeyProjectionGross",
    "tableProjectionGross", "tableExtractionGross",
)
INPUTS = (
    "docs/design/application-metadata-subject.json",
    "docs/design/application-metadata-owned-storage.json",
    "docs/design/application-metadata-composition.json",
    "docs/design/application-metadata-wire.json",
    "docs/design/application-metadata-runtime-admission.json",
    "docs/design/application-metadata-contract.json",
    "docs/adr/application-metadata-accounting-covers-explicit-work.md",
    "docs/verification/application-metadata-grouped-storage.md",
    "docs/design/architecture/native-metadata-grouped-storage.d2",
    "docs/design/architecture/native-metadata-grouped-storage.svg",
    "docs/design/architecture/diagrams.json",
    "scripts/application_metadata_grouped_storage.py",
    "scripts/test_application_metadata_grouped_storage.py",
    "scripts/check_application_metadata_grouped_mutations.py",
    "scripts/application_metadata_composition.py",
    "scripts/application_metadata_owned_storage.py",
    "scripts/application_metadata_operation_ledger.py",
    "Taskfile.yml",
)


class GroupCost(TypedDict):
    gross: int
    attempts: int
    keyCount: int
    records: list[list[int | str]]
    byteSlabs: int
    recordSlabs: int
    receiptTotals: dict[str, list[int]]


class Row(TypedDict):
    ordinal: int
    spelling: str
    target: str
    replacementReceipts: dict[str, int]
    oldScopedBlocks: int
    oldScopedKeyGross: int
    groupedKeyGross: int
    groupedKeyAttempts: int
    retainedInputGross: int
    newKnownGross: int
    newKnownAttempts: int
    controlledFirstWalkSubtotal: int
    controlledSecondWalkSubtotal: int
    oldCells: dict[str, object]
    storageCells: dict[str, object]
    localCells: dict[str, object]
    wireCells: dict[str, object]
    episodeTapes: list[str]


class Run(TypedDict):
    rows: list[Row]
    groupedKnownLocalGross: int
    groupedKnownLocalAttempts: int
    withControlledPathSubtotal: int
    withControlledWalkSubtotal: int
    excessOverGate: int
    completeGross: int | None
    completeAttempts: int | None
    actualResponseBytes: int | None
    jobTapes: list[str]
    conditionalSingleWireUpper: object
    conditionalFullWireUpper: object


class Report(TypedDict):
    schemaVersion: int
    inputHashes: dict[str, str]
    nativeVerdict: str
    usefulFitEstablished: bool
    outcome: str
    grossGate: int
    attemptGate: int
    responseGate: int
    episodeSpellings: list[str]
    outsidePaths: list[dict[str, object]]
    systemSeedGroups: int
    inventories: dict[str, list[dict[str, object]]]
    runs: dict[str, Run]
    controlledPathComparison: dict[str, object]
    requiredEpisodeOperands: list[str]
    requiredJobOperands: list[str]
    pendingNativeInputs: object
    scopedRecipes: object
    requiredOperandRecipes: object
    selectedWireInputHash: str
    changesAdopted: dict[str, bool]


class Group:
    """Design event model: reservation precedes writes, cleanup cannot refund."""

    def __init__(self, *, gross_limit: int = 20971520,
                 attempt_limit: int = 4194304) -> None:
        self.limit = gross_limit
        self.attempt_limit = attempt_limit
        self.spent_gross = 0
        self.spent_attempts = 0
        self.receipts: list[tuple[str, int]] = []
        self.records: list[list[int | str]] = []
        self.byte_slabs = 0
        self.record_slabs = 0
        self.byte_used = 0
        self.record_used = 0
        self.byte_capacity = 0
        self.blocks: list[str] = []
        self.frozen = False
        self.failed = False
        self.pending = False
        self.cancelled = False
        self.slot_held = True
        self._apply([("allocate:owner", 192), ("pending-owner", 8), ("header:owner", 64),
                     ("owner-fields", 128), ("pending-owner-clear", 8)])

    @property
    def live_blocks(self) -> int:
        return len(self.blocks)

    def _apply(self, events: list[tuple[str, int]], fail_after: int | None = None) -> bool:
        additional = sum(name.startswith("allocate:") for name, _ in events)
        possible_freeze = 16 if not self.frozen and not any(
            name == "freeze-state" for name, _ in events
        ) else 0
        entering = any(name == "native-call" for name, _ in events)
        returning = any(name == "explicit-return-release" for name, _ in events)
        borrower_cleanup = 16 if entering else (8 if self.pending and not returning else 0)
        borrower_attempts = 3 if entering else (2 if self.pending and not returning else 0)
        # Reserve all retirement writes/frees and the closing cursor clear.
        if self.spent_gross + sum(size for _, size in events) + (
            8 * (len(self.blocks) + additional) + 8 + possible_freeze + borrower_cleanup
        ) > self.limit:
            raise Limit("COPY_LIMIT")
        if self.spent_attempts + len(events) + 2 * (len(self.blocks) + additional) + (
            1 + possible_freeze // 8 + borrower_attempts
        ) > self.attempt_limit:
            raise Limit("CALL_LIMIT")
        for index, (name, size) in enumerate(events):
            if fail_after is not None and index == fail_after:
                self.failed = True
                return False
            self.spent_gross += size
            self.spent_attempts += 1
            self.receipts.append((name, size))
            if name.startswith("allocate:"):
                self.blocks.append(name.removeprefix("allocate:"))
        return True

    def append(self, key: str, *, direct: bool = False,
               fail_after: int | None = None) -> None:
        if self.frozen or self.failed or self.cancelled or not self.slot_held:
            raise ContractViolation("frozen or failed inventory cannot append")
        n = byte_count(key)
        if not 1 <= n <= 1024 or (direct and not key.endswith(".lproj")):
            raise ContractViolation("key outside selected scalar contract")
        events: list[tuple[str, int]] = []
        byte_new = self.byte_used + n + 1 > self.byte_capacity
        record_new = self.record_used == 16 or self.record_slabs == 0
        for kind, new, count, cap in (
            ("bytes", byte_new, self.byte_slabs, max(256, n + 1)),
            ("records", record_new, self.record_slabs, 640),
        ):
            if new:
                label = f"{kind}.{count}"
                requested = (64 + cap + 15) // 16 * 16
                events.extend([(f"allocate:{label}", requested), ("pending-backing", 8),
                               (f"header:{label}", 64)])
                if count:
                    events.append((f"link:{kind}.previous.next", 8))
                events.extend([(f"tail:{kind}", 8), (f"head:{kind}", 8),
                               (f"slab-count:{kind}", 8), ("pending-backing-clear", 8)])
        slab = self.byte_slabs if byte_new else self.byte_slabs - 1
        offset = 0 if byte_new else self.byte_used
        selector = byte_count(key.removesuffix(".lproj")) if direct else n
        classification = "DIRECT" if direct else (
            "RESERVED" if key == "LocProvenance" else "LITERAL")
        events.extend([
            ("conversion-prefix", n), ("literal-plus-nul", n + 1), ("span-five-words", 40),
            ("byte-used", 8), ("record-count", 8), ("cursor", 8), ("classification", 8),
        ])
        if direct:
            events.extend([("selector-length", 8), ("accepted-direct-count", 8)])
        if not self._apply(events, fail_after):
            return
        if byte_new:
            self.byte_slabs += 1
            self.byte_used = 0
            self.byte_capacity = max(256, n + 1)
        if record_new:
            self.record_slabs += 1
            self.record_used = 0
        self.records.append([slab, offset, n, selector, classification, len(self.records)])
        self.byte_used += n + 1
        self.record_used += 1

    def freeze(self) -> None:
        if self.failed or self.frozen or self.cancelled:
            raise ContractViolation("failed or already frozen inventory")
        self._apply([("final-raw-count", 8), ("freeze-state", 8)])
        self.frozen = True

    def begin_call(self) -> None:
        if not self.frozen or self.pending or self.cancelled:
            raise ContractViolation("borrow requires frozen live inventory")
        self._apply([("borrower-count", 8), ("native-call", 0)])
        self.pending = True

    def cancel(self) -> None:
        self._apply([("cancel-state", 8)])
        self.cancelled = True

    def return_call(self) -> None:
        if not self.pending:
            raise ContractViolation("no pending borrower")
        self._apply([("borrower-count", 8), ("explicit-return-release", 0)])
        self.pending = False

    def close(self) -> None:
        if self.pending:
            raise ContractViolation("borrow retains owners until true return")
        if not self.slot_held:
            raise ContractViolation("already retired")
        self.spent_gross += 8
        self.spent_attempts += 1
        self.receipts.append(("close-cursor", 8))
        for name in reversed(self.blocks):
            self.spent_gross += 8
            self.spent_attempts += 2
            self.receipts.extend([(f"retired:{name}", 8), (f"free:{name}", 0)])
        self.blocks.clear()
        self.slot_held = False
        if self.spent_gross > self.limit:
            raise ContractViolation("cleanup reservation lost")


def group_cost(keys: list[str], direct: list[str]) -> GroupCost:
    if not set(direct).issubset(keys):
        raise ContractViolation("direct inventory invented an entry")
    group = Group()
    for key in keys:
        group.append(key, direct=key in direct)
    group.freeze()
    group.close()
    receipts: dict[str, list[int]] = {}
    for label, amount in group.receipts:
        count, gross = receipts.get(label, [0, 0])
        receipts[label] = [count + 1, gross + amount]
    return {"gross": group.spent_gross, "attempts": group.spent_attempts,
            "keyCount": len(keys), "records": group.records,
            "byteSlabs": group.byte_slabs, "recordSlabs": group.record_slabs,
            "receiptTotals": receipts}


def hashes(root: Path) -> dict[str, str]:
    return {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in INPUTS}


def assess(root: Path, *, freeze: bool = True) -> Report:
    before = hashes(root) if freeze else {}
    loaded = [record(json.loads((root / path).read_bytes())) for path in INPUTS[:5]]
    subject, storage, composition, wire, runtime = loaded
    spellings = texts(subject["episodeSpellings"])
    targets = texts(subject["combinedEpisodes"])
    common = table(storage["commonColumns"], storage["commonRows"])
    by_path = {str(row["path"]): row for row in objects(subject["baseline"])
               + objects(subject["fixtures"])}
    inventories: dict[str, list[dict[str, object]]] = {}
    key_costs: dict[str, tuple[int, int]] = {}
    for target, row in by_path.items():
        raw = texts(row["rawDirectEntries"])
        direct = texts(row["locales"])
        cost = group_cost(raw, direct)
        groups: list[dict[str, object]] = [{
            "kind": "DIRECT", "literalKeys": raw, "acceptedDirect": direct,
            "cost": dict(cost), "rejectedEntries": row["rejectedLocaleEntries"],
        }]
        gross, attempts = cost["gross"], cost["attempts"]
        for item in objects(row["files"]):
            if str(item["relative"]).endswith(".loctable"):
                keys = texts(item["localeKeys"])
                cost = group_cost(keys, [])
                extraction_gross, extraction_attempts = raw_block_cost(16 * len(keys))
                extraction_attempts += 1  # two populated pointer ranges
                gross += cost["gross"] + extraction_gross
                attempts += cost["attempts"] + extraction_attempts
                groups.append({"kind": "TABLE", "relative": item["relative"],
                               "literalKeys": keys, "cost": dict(cost),
                               "extractionGross": extraction_gross,
                               "extractionAttempts": extraction_attempts})
        inventories[target] = groups
        key_costs[target] = gross, attempts
    runs: dict[str, Run] = {}
    for name, value in record(composition["runs"]).items():
        original = record(value)
        old_rows = table(original["columns"], original["rows"])
        local_run = record(record(storage["runs"])[name])
        local_rows = table(local_run["columns"], local_run["rows"])
        selected_wire = record(record(wire["runs"])[name])
        wire_rows = table(wire["columns"], selected_wire["rows"])
        new_rows: list[Row] = []
        for ordinal, (spelling, target, old, local, base, selected) in enumerate(zip(
            spellings, targets, old_rows, local_rows, common, wire_rows, strict=True
        )):
            replacements = {label: integer(base[label]) for label in REPLACED}
            blocks = integer(old["scopedLocalOwnerBlocks"])
            old_key_gross = sum(replacements.values()) + 72 * blocks
            inputs = (integer(local["selectedInputWriteUpper"])
                      + integer(local["extraEOFWriteUpper"]))
            if inputs + old_key_gross != old["scopedKnownGrossSubterms"]:
                raise ContractViolation("replacement overlaps or omits old receipts")
            gross, attempts = key_costs[target]
            # Controlled successful counterpart, not a fabricated expanded native tape.
            walk = raw_block_cost(byte_count(spelling) + 1)[0] + raw_block_cost(96)[0]
            new_rows.append({
                "ordinal": ordinal, "spelling": spelling, "target": target,
                "replacementReceipts": replacements, "oldScopedBlocks": blocks,
                "oldScopedKeyGross": old_key_gross,
                "groupedKeyGross": gross, "groupedKeyAttempts": attempts,
                "retainedInputGross": inputs, "newKnownGross": inputs + gross,
                "newKnownAttempts": integer(old["readerApiUpper"]) + attempts,
                "controlledFirstWalkSubtotal": walk, "controlledSecondWalkSubtotal": walk,
                "oldCells": old, "storageCells": base, "localCells": local,
                "wireCells": selected, "episodeTapes": list(EPISODE_OPERANDS),
            })
        known_gross = 270368 + 616 + sum(row["newKnownGross"] for row in new_rows)
        path = integer(record(composition["controlledPathComparison"])["pathProjectionGross"])
        walks = sum(row["controlledFirstWalkSubtotal"] + row["controlledSecondWalkSubtotal"]
                    for row in new_rows)
        runs[name] = {
            "rows": new_rows, "groupedKnownLocalGross": known_gross,
            "groupedKnownLocalAttempts": 17 + sum(row["newKnownAttempts"] for row in new_rows),
            "withControlledPathSubtotal": known_gross + path,
            "withControlledWalkSubtotal": known_gross + path + walks,
            "excessOverGate": known_gross + path + walks - 20971520,
            "completeGross": None, "completeAttempts": None, "actualResponseBytes": None,
            "jobTapes": list(JOB_OPERANDS),
            "conditionalSingleWireUpper": selected_wire["conditionalSingleBytes"],
            "conditionalFullWireUpper": selected_wire["conditionalFullBytes"],
        }
    result: Report = {
        "schemaVersion": 1, "inputHashes": before, "nativeVerdict": "PENDING",
        "usefulFitEstablished": False,
        "outcome": "GROUPED_CONTROLLED_SUBENCLOSURE_EXCEEDS_GATE_FULL_NATIVE_AND_WIRE_CONDITIONAL",
        "grossGate": 20971520, "attemptGate": 4194304, "responseGate": 8388608,
        "episodeSpellings": spellings,
        "outsidePaths": objects(subject["queryPathsOutsideDirectorySubject"]),
        "systemSeedGroups": 2, "inventories": inventories, "runs": runs,
        "controlledPathComparison": record(composition["controlledPathComparison"]),
        "requiredEpisodeOperands": list(EPISODE_OPERANDS),
        "requiredJobOperands": list(JOB_OPERANDS),
        "pendingNativeInputs": composition["pendingNativeInputs"],
        "scopedRecipes": runtime["scopedRecipes"],
        "requiredOperandRecipes": runtime["requiredOperandRecipes"],
        "selectedWireInputHash": hashlib.sha256((root / INPUTS[3]).read_bytes()).hexdigest(),
        "changesAdopted": {"gate": False, "scope": False, "abi": False,
                           "posture": False, "usefulLoss": False, "holdLifted": False},
    }
    validate(result)
    if freeze and hashes(root) != before:
        raise ContractViolation("grouped inputs changed during derivation")
    return result


def validate(result: Report) -> None:
    if (len(result["episodeSpellings"]) != 2043 or len(result["outsidePaths"]) != 149
            or result["systemSeedGroups"] != 2 or result["usefulFitEstablished"]
            or result["nativeVerdict"] != "PENDING" or any(result["changesAdopted"].values())):
        raise ContractViolation("subject, pending boundary or unchanged contract lost")
    for run in result["runs"].values():
        if ([row["spelling"] for row in run["rows"]] != result["episodeSpellings"]
                or [row["ordinal"] for row in run["rows"]] != list(range(2043))
                or run["completeGross"] is not None or run["completeAttempts"] is not None
                or run["actualResponseBytes"] is not None):
            raise ContractViolation("association or unknown native/publication/wire operands lost")
        if run["jobTapes"] != list(JOB_OPERANDS):
            raise ContractViolation("job tape omitted")
        for row in run["rows"]:
            if (set(row["replacementReceipts"]) != set(REPLACED)
                    or sum(row["replacementReceipts"].values()) + 72 * row["oldScopedBlocks"]
                    != row["oldScopedKeyGross"]
                    or row["newKnownGross"] != row["retainedInputGross"] + row["groupedKeyGross"]
                    or row["episodeTapes"] != list(EPISODE_OPERANDS)):
                raise ContractViolation("replacement receipt or episode tape omitted")


def compact(result: Report) -> dict[str, object]:
    """Store column names once; intern report shapes, never production owners/costs."""
    saved: dict[str, object] = dict(result)
    profiles: list[list[dict[str, object]]] = []
    seen: dict[str, int] = {}
    associations: dict[str, int] = {}
    for target, groups in result["inventories"].items():
        encoded = json.dumps(groups, sort_keys=True, separators=(",", ":"))
        if encoded not in seen:
            seen[encoded] = len(profiles)
            profiles.append(groups)
        associations[target] = seen[encoded]
    saved["inventories"] = associations
    saved["inventoryProfiles"] = profiles
    cells: dict[str, list[str]] = {}
    runs: dict[str, object] = {}
    for name, run in result["runs"].items():
        rows: list[list[object]] = []
        columns = [key for key in run["rows"][0] if key != "spelling"]
        for row in run["rows"]:
            values: dict[str, object] = dict(row)
            for key in ("replacementReceipts", "oldCells", "storageCells", "localCells",
                        "wireCells"):
                nested = record(values[key])
                labels = list(nested)
                if key in cells and cells[key] != labels:
                    raise ContractViolation("compact columns lost a receipt")
                cells[key] = labels
                values[key] = [nested[label] for label in labels]
            rows.append([values[column] for column in columns])
        current: dict[str, object] = dict(run)
        current["columns"] = columns
        current["rows"] = rows
        runs[name] = current
    saved["runs"] = runs
    saved["nestedColumns"] = cells
    return saved


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, epilog="Example: %(prog)s --check. Exit 0 reproduces a failed "
        "design candidate; 1 invalid/stale inputs; 2 usage. No native observations are made.")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true", help="replace derived saved-input JSON")
    mode.add_argument("--check", action="store_true", help="check every cell and input hash")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    try:
        result = assess(root)
        if args.write:
            (root / REPORT).write_text(json.dumps(compact(result), separators=(",", ":"),
                                                ensure_ascii=False) + "\n")
        elif json.loads((root / REPORT).read_bytes()) != compact(result):
            raise ContractViolation("stale grouped report; reconcile then run --write")
    except (OSError, ValueError, KeyError) as error:
        print(json.dumps({"code": "GROUPED_CANDIDATE_INVALID", "error": str(error)}),
              file=sys.stderr)
        raise SystemExit(1) from error
    print(json.dumps({"outcome": result["outcome"], "nativeVerdict": "PENDING",
                      "runs": {name: {key: value for key, value in run.items() if key in {
                          "groupedKnownLocalGross", "withControlledPathSubtotal",
                          "withControlledWalkSubtotal", "excessOverGate"}}
                               for name, run in result["runs"].items()}}))


if __name__ == "__main__":
    main()
