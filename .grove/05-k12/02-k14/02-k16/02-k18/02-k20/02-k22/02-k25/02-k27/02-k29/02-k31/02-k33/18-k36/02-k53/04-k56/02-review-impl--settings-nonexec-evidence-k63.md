# settings-nonexec-evidence-k63

**Reviews:** settings-nonexec-evidence-k60


## Goal
Independently challenge the shared evidence interface before complete scenario
migration. Read the producer's committed diff by handle, not its session transcript.



## Context
Read the k56/k53 charters, ORDERING-EVALUATION-PLAN.md, ORDERING-REVIEW.md,
ORDERING-TRANSPORT-RESULTS.md and ORDERING-NONEXEC-RESULTS.md under
docs/verification/settings-activation. The producer changes scripts/vm-guest-exec.py,
its source-only shell facade, Tests/scripts/vm-guest-exec.bats and the existing
Taskfile entry. Evidence is in ordering-nonexec-evidence, including the prior-adapter,
missing-lock and separator failing controls and final verification receipt.

K60 expands the adapter only. Ordinary callers remain legacy; actual per-command
schemas, artifacts, confirmations, scenario signals and positive UI setup are
k61's duties, with exact-prefix reconciliation k62 and finite caller k57. No VM
or frozen subject exists. K54 owns actual executable/spec/endpoint provenance.

## Done when
- Try to find dispatch after failure, cross-transport lock/ordinal gaps, lost raw
  evidence, wrongly accepted partial/base/payload JSON, output-before-completion
  mistakes or a confirmation failure that restores eligibility. Inspect both
  facade and direct backend paths, including parse/storage/emission failures.
- Challenge CLI argv binding against the inspected official v2.7.0 source:
  endpoint versus lifecycle forms, option overrides/terminators, forbidden guest
  exec route and exact clone identity. Separate supported interface guarantees
  from caller obligations that migration must fulfill.
- Assess surviving-child lock lifetime, gate inspection versus dispatch, SIGINT
  versus TERM/HUP/KILL and partial receipts. Check whether the controls actually
  distinguish missing guards and whether the retained receipts match their subjects.
  Controlled marker payloads must not be treated as real command-schema evidence.
- Produce actionable source-anchored findings, or state no findings in the
  inspected scope. No fixes, VM, frozen subject or competing in-session reviewer.
  Any earned integration must be inserted before k61, the next live sibling.

## Notes
Every historical outcome/cap and original k56 duty survives. Interface review
does not replace later whole-harness review or establish repaired native behavior.
No in-session producer reviewer ran. Provider evidence was absent from the
finishing session's environment; no Creator line is supplied.
