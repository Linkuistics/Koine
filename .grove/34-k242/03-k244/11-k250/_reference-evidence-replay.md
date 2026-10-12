# reference-evidence-replay-k250 — brief

## Goal

Deliver an offline version-1 evidence replay tool that validates exact authored
packages and independently verifies their bytes, complete typed expectations and
copy/file/source/alias coordinates. It is usable before any native acquisition.

## Done when

The exhaustive executable schema, usable structural validator and separate semantic
oracle run on immutable hand-authored packages. Missing/foreign/duplicate fields,
lossy values, object/occurrence confusion and coordinate-preserving shape losses
are independently rejected. Complete positives and allowed permutations pass;
every proof names its exact coordinate/reason and freezes inputs before/after.

## Decomposition

Envelope-k251 lands the schema together with a working validator and object replay.
Oracle-k252 adds independently authored full expectations and mutation discrimination.
Both leaves leave an executable offline check working; neither needs a future producer.

## Pointers

Read the durable contract's envelope, record model, typed witnesses and control matrix.
Own scripts/reference_evidence_verify.py, its tests, Fixtures/ReferenceEvidence/replay
and docs/design/application-reference-evidence.schema.json. The verifier may consume
the schema as the format contract but imports no producer logic or expected totals.

## Notes

No installed root, mdfind, Koine reader or generated k246 subject is an input.
Schema-valid failure/partial records must remain distinguishable from complete evidence.
Final proof aggregation and qualification are owned by k263, not this stage.
