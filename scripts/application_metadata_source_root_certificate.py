"""Reproduce the symbolic source/root handoff from saved inputs only."""
# pyright: strict

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path
from typing import Callable

from application_metadata_episode_certificate import byte_count, objects, record, texts
from application_metadata_source_root import (
    Batch,
    IndexedItem,
    RunningItem,
    Scalar,
    Trace,
    Visit,
    indexed,
    preferences,
    registration,
    root_pair,
    running,
    setup,
    walk,
)

INPUTS = (
    "docs/design/application-metadata-subject.json",
    "docs/design/application-metadata-episode-certificate.json",
    "scripts/application_metadata_source_root.py",
    "scripts/application_metadata_source_root_certificate.py",
    "scripts/test_application_metadata_source_root.py",
    "scripts/check_application_metadata_source_root_mutations.py",
    "scripts/application_metadata_episode_certificate.py",
    "scripts/application_metadata_operation_ledger.py",
    "scripts/application_metadata_reader_plan.py",
    "Providers/WorkspaceProvider/Logic/LocationWalk.swift",
    "Taskfile.yml",
)


def hashes(root: Path) -> dict[str, str]:
    return {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in INPUTS}


def example(run: Callable[[Trace], object]) -> dict[str, object]:
    trace = Trace()
    result = run(trace)
    trace.cleanup()
    return {
        "result": result,
        "attemptsIncludingLocalAndCleanup": trace.ledger.spent_attempts,
        "operations": dict(sorted(Counter(trace.operations).items())),
        "knownWriteBytes": trace.known_writes,
        "grossBytes": trace.gross,
        "unresolvedOwnedTerms": trace.unresolved,
        "receipts": [[r.label, r.kind, r.amount] for r in trace.receipts],
        "slotReturned": not trace.ledger.slot_held,
    }


def assess(root: Path) -> dict[str, object]:
    before = hashes(root)
    subject = record(json.loads((root / INPUTS[0]).read_text()))
    episodes = record(json.loads((root / INPUTS[1]).read_text()))
    source = record(subject["controlledSourceBatches"])
    if source["nativeObservation"] is not False:
        raise ValueError("controlled path arrays cannot silently become native tuples")
    ids = record(source["identifiers"])
    per_source: dict[str, list[str]] = {
        "indexed": texts(source["indexed"]), "running": texts(source["running"]),
        "registrationCF": [], "registrationAppKit": [], "preferred": [],
    }
    for value in ids.values():
        group = record(value)
        per_source["registrationCF"].extend(texts(group["cf"]))
        per_source["registrationAppKit"].extend(texts(group["appkit"]))
        if not isinstance(group["preferred"], str):
            raise ValueError("controlled preferred URL must retain its literal slot")
        per_source["preferred"].append(str(group["preferred"]))
    total = sum(len(paths) for paths in per_source.values())
    prior = record(episodes["source"])
    if total != prior["controlledRawURLSlots"]:
        raise ValueError("controlled raw slot derivation changed")
    if len(per_source["running"]) != prior["controlledRunningSlots"]:
        raise ValueError("running slot derivation changed")
    groups = len(ids) + len(("com.apple.Safari", "com.apple.finder"))
    if groups != prior["controlledIdentifierGroupsIncludingSystem"]:
        raise ValueError("system seed reserve omitted")
    cases: dict[str, dict[str, object]] = {}
    cases["job.type-ids"] = example(setup)
    cases["preferences.empty"] = example(lambda t: preferences(t, ()))
    cases["preferences.two"] = example(lambda t: preferences(t, (Scalar(b"en-AU"), Scalar(b"de"))))
    cases["preferences.nil-string"] = example(
        lambda t: preferences(t, (Scalar(b"en-AU"), Scalar(b"de")), fail_at=1)
    )
    for branch in ("INIT_NIL", "START_FALSE", "ERROR", "INCOMPLETE", "EMPTY", "POSITIVE"):
        cases["query." + branch] = example(lambda t, branch=branch: indexed(t, (), branch=branch))
    cases["query.toy-tuple"] = example(lambda t: indexed(t, (
        IndexedItem(Scalar(b"/A.app"), (Scalar(b"com.apple.application-bundle"),),
                    Scalar(b"org.a"), Scalar(b"A")),
    )))
    cases["running.toy-tuple"] = example(
        lambda t: running(t, (RunningItem(Scalar(b"/A.app"), Scalar(b"org.a")),))
    )
    for branch in ("POSITIVE", "EMPTY", "NOT_FOUND", "ERROR", "BOTH", "NIL",
                   "WRONG_TYPE", "INCOMPLETE"):
        cases["registration." + branch] = example(lambda t, branch=branch: registration(
            t, Batch(branch, (Scalar(b"/A.app"),) if branch != "EMPTY" else ()),
            Batch("EMPTY"), None, b"org.a",
        ))
    for failure in ("", "OPEN", "HELD", "CHANGED"):
        cases["root.terminal." + (failure or "OK")] = example(
            lambda t, failure=failure: root_pair(
                t, b"/A.app", (Visit(b"A.app", "DIRECTORY", failure=failure),),
                (Visit(b"A.app", "DIRECTORY"),),
            )
        )
    cases["registration.malformed-error"] = example(lambda t: registration(
        t, Batch("NOT_FOUND", error_state="TYPE"), Batch("EMPTY"), None, b"org.a",
    ))
    cases["root.expanded"] = example(lambda t: root_pair(
        t, b"/alias/A.app",
        (Visit(b"alias", "LINK", text=b"x/y"), Visit(b"x", "DIRECTORY"),
         Visit(b"y", "DIRECTORY"), Visit(b"A.app", "DIRECTORY")),
        (Visit(b"alias", "LINK", text=b"x/y"), Visit(b"x", "DIRECTORY"),
         Visit(b"y", "DIRECTORY"), Visit(b"A.app", "DIRECTORY")),
    ))
    cases["root.long-indexed-required"] = example(lambda t: root_pair(
        t, b"/" + b"a" * 1023, (Visit(b"a" * 1023, "DIRECTORY"),),
        (Visit(b"a" * 1023, "DIRECTORY"),),
    ))
    for literal, visits in ((b"/", ()), (b"/.", (Visit(b".", "DOT"),)),
                            (b"/..", (Visit(b"..", "DOT"),))):
        cases["root.current." + literal.decode()] = example(
            lambda t, literal=literal, visits=visits:
            walk(t, literal, visits, transfer=True) is not None
        )
    result: dict[str, object] = {
        "schemaVersion": 1,
        "purpose": "Pure parametric source/root operation grammar; examples are toy observations",
        "inputHashes": before,
        "nativeVerdict": "PENDING",
        "usefulSubjectCertificateEstablished": False,
        "sourceRootGrossBytes": None,
        "sourceRootAttempts": None,
        "sourceRootOwnedStorage": None,
        "wholeJobGrossBytes": None,
        "wholeJobAttempts": None,
        "responseBytes": None,
        "controlledPathOnly": {
            "rawURLSlots": total,
            "runningSlots": len(per_source["running"]),
            "identifierGroupsIncludingSystemReserve": groups,
            "perSource": {name: {
                "slots": len(paths),
                "literalPathBytesIncludingNul": sum(byte_count(p) + 1 for p in paths),
            } for name, paths in per_source.items()},
        },
        "outsideCensusPaths": objects(subject["queryPathsOutsideDirectorySubject"]),
        "actualNativeDimensions": {
            "indexedTuplesAndTypeTrees": None, "sourceEventAndBranchCounts": None,
            "runningAndRegistrationTuples": None, "preferenceSnapshot": None,
            "expandedWalksAndIdentityOutcomes": None, "rootResourceOutcomes": None,
            "outsideCensusContentsAndWalks": None,
        },
        "remainingDesignWorkForK225": [
            "Bound allocation capacities, headers/alignment/growth and local record-field writes",
            "Choose source/scalar/arena/vector/map representations; trace every bridge/COW copy",
            "Partition walker, two immutable file inputs, EOF, conversion and selector scratch",
            "Compose reader/source/root/final receipts without counting a capacity or read twice",
            "Derive final scalar and complete selected-response escaping/multiplicity terms",
        ],
        "pendingNativeEvidenceIsNotNewDesignWork": [
            "Actual fixed query, running, registration and one-job preferences observations",
            "Actual expanded per-spelling walks, root resource and long indexed tuples",
            "The retained 149 outside census paths and supported signed VM G/N/V acceptance",
        ],
        "toyBranchExamples": cases,
    }
    if hashes(root) != before:
        raise RuntimeError("source/root inputs moved during assessment")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="write the saved-input handoff")
    parser.add_argument("--check", action="store_true", help="compare every derived item")
    args = parser.parse_args()
    if args.write == args.check:
        parser.error("choose --write or --check")
    root = Path(__file__).resolve().parent.parent
    target = root / "docs/design/application-metadata-source-root-certificate.json"
    result = assess(root)
    if args.write:
        target.write_text(json.dumps(result, indent=2) + "\n")
    elif json.loads(target.read_text()) != result:
        raise RuntimeError("source/root handoff changed; regenerate after finishing edits")
    print("Reproduced source/root grammar and controlled dimensions; numeric fit/native pending")


if __name__ == "__main__":
    main()
