# callback-publication-comparison-differences-k239

## Goal
Labelled successor/legacy differences with coordinates and selected
path/cut/rule, beside the unchanged detached legacy result.

## Context
publication-replay.md "Detached legacy CLI comparison" (difference labels),
"Existing producer families and migration" (staged-C discriminator), V18
inactive-C control.

## Done when
- Labels added-supported-order, cut/lost-order, witness-policy,
  legacy-staging, producer-domain, evidence-negation,
  local-receipt-qualification and new-transport-requirement, never altering
  the legacy result. Extraction reads the parsed legacy result in place,
  inside k227's stage-6 parse lifetime, and writes only preallocated report
  tables.
- Controls: R08 (early wire raise versus success, late C activity path; kill
  shared mutable sampled_evidence and moving legacy C before core), V18
  inactive-C and tuple-mismatch labels, B16 and the missing-observation-37
  topology difference, added/lost-order comparisons on V11–V25 bases.
