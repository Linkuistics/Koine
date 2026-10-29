# settings-exec-evidence-k58

**Reviews:** settings-exec-evidence-k55

## Goal
Independently review the strict guest-exec adapter and its headless evidence
before shared scenario migration. Read the producer's committed diff from its
handle, not the session transcript.

## Context
The contract is ORDERING-EVALUATION-PLAN.md and ORDERING-REVIEW.md under
docs/verification/settings-activation. ORDERING-TRANSPORT-RESULTS.md describes
this expand increment and its limits; verification.json and per-test logs live
in ordering-transport-evidence. Existing ordinary callers remain legacy. K56
and k57 own migration and finite caller; no native runtime has occurred.

## Done when
- Review scripts/vm-guest-exec.py, its source-only shell facade, Taskfile entry
  and Tests/scripts/vm-guest-exec.bats against the parent evidence contract.
  Try to find wrong acceptance, a hidden retry/dispatch after failure, lost raw
  evidence, incorrect VM binding, overwrite or competing-writer gap.
- Assess exact schema/command and payload validation, clean negative versus
  transport failure, the sticky latch across substitutions/collection, and
  incomplete-record handling. Check claims and controls against actual behavior;
  do not treat simulated CLI or saved envelope checks as native product success.
- Check what the script can and cannot guarantee on interruption or storage
  failure. Separate missing future integration work from defects in this adapter;
  check its interface gives k56 enough evidence to implement the full contract.
- Produce source-anchored actionable findings or state no findings in the
  inspected scope. No fixes, VM, freeze or changed protocol. Any earned integration
  must precede the first later live sibling (currently k56) and runtime.

## Notes
No in-session producer reviewer ran. Thirteen new controls, eight pointer and
nine resize controls pass with unchanged final input digests. Historical bytes,
slots/caps, native cause/ownership and all unresolved parent duties survive.
