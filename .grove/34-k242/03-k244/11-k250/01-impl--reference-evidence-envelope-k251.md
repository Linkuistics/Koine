# reference-evidence-envelope-k251

## Goal

Materialize the exhaustive version-1 schema with a usable independent offline
validator/object replayer on authored packages.

## Context

Read the durable contract's proposed envelope and required record model together.
The proposed name is koine.application-reference-evidence/1; it is not yet an
executable schema. Do not borrow the legacy census schema or its projections.

## Work and verification

1. Author Fixtures/ReferenceEvidence/replay positives and exact negative expectations
before the validator: at least one complete and one absent/refused/unavailable/error
or partial outcome for each applicable record kind. Preserve the authored bytes.
2. Create docs/design/application-reference-evidence.schema.json and
scripts/reference_evidence_verify.py with a format-validation/object-replay operation.
Define every nested required field, variant and relationship for attempt, source,
root, inventory, file, decoded, branch, tail and closure. All record kinds have
version/kind/phase/coordinate/outcome; nested foreign fields are errors. Parse JSON
with duplicate-member and exact-number detection before schema validation.
3. Validate canonical padded base64, exact UTF-16 units, integer/ordinal encodings,
signed-decimal native integers, fixed-width real/date bits, digest syntax and actual
object lengths/hashes. Partial objects retain actual prefix extents/outcomes and
cannot claim complete-file digests. Empty bytes differ from missing bytes.
4. Validate unique coordinates, references, phase boundaries, occurrence ordinals,
every logical role and shared-object relation. Never merge source/file/copy rows
by identifier/digest or erase repeated slots. Failure envelopes remain inspectable
with a separate incomplete verdict; validation success alone is not package success.
5. Add test_reference_evidence_verify.py and task evidence:reference-envelope-check
that runs the offline tests plus existing Python lint/type checks. Watch one broken
variant/field/reference/byte object fail for its intended coordinate before each
corresponding positive passes. Pin the schema/checker/fixtures/configuration and
actual tools before/after; retain immutable per-case proof, not just totals.

## Done when

The schema and its usable validator land together; every record/variant/field group
in the durable contract is mapped to a named executable check and independent
positive/negative specimen. No omitted variant is silently accepted. The Taskfile
entry is verified without target adapters. Document the precise semantic-oracle
boundary left to k252; structural validation alone qualifies no instrument.

## Notes

Offline verifier input is a package plus a frozen expectation when semantic checks
are requested. Its diagnostic output uses stable coordinates and failure classes;
nonzero exits distinguish mismatch from usage/precondition failure. No target contact.
