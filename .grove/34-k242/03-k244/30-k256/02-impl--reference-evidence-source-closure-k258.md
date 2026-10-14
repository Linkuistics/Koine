# reference-evidence-source-closure-k258

## Goal

Implement initial-versus-closure source comparison retaining every occurrence and
source-slot coordinate, with exact permutation and changed-source outcomes.

## Context

Consume pipe-runner-k257's actual raw event/slot records and the independent oracle.
The declared target attempt later has one initial and one closure fixed-query call;
closure is an integrity observation, never a second source or retry.

## Work and verification

1. Freeze before/after sequences with repeated spellings, empty/outside/malformed
slots and deliberate pure reorderings. Fixture roles do not supply held root identity.
2. Implement SourceClosure.swift and package tests. Compare all spelling bytes,
multiplicities and occurrence correspondence item by item. Identical duplicates
retain separate phase/ordinal coordinates; any ambiguous correspondence is explicit.
Save both raw sequences and any justified permutation rather than raw-equality claims.
3. Test new/missing slots, duplicate deletion and same-cardinality spelling replacement.
Held root identity/physical alias comparison belongs to k262 after k260, not an emitter.
Independently authored expected differences
must identify the intended coordinate; counts/digest totals cannot rescue a loss.
4. Initial failure prevents acquisition and any closure replacement/retry; aborted
closure is recorded unavailable. Closure failure never fills missing initial rows.
Verify declared query contact counts against pure emitter traces.
5. Extend/verify task evidence:reference-source-check with per-item comparison
proofs, before/after tool/expectation hashes and independent permutation positives.

## Done when

Source closure can be demonstrated using two pure emitter observations. Every
source-occurrence-preserving reorder passes while preserving raw order; every applicable
change/failure prevents stable package success without retry. Prior checks pass.

## Notes

This compares emitted bounded observations, not index health or atomic completeness.
Actual target query selection belongs to the later fixed coordinator and k245.
