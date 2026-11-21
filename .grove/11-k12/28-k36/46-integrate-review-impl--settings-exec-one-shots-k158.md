# settings-exec-one-shots-k158

**Integrates:** settings-exec-one-shots-k157

## Goal

Triage the independent review of k152 and resolve each accepted issue before
k76 consumes the one-shot helpers.

## Context

Read the findings from the commit of settings-exec-one-shots-k157, including
`docs/verification/settings-activation/ORDERING-ONE-SHOT-REVIEW.md` and its
source receipt. Read the producer's committed artifact, its retained controls,
the inherited contracts and the current ordering protocol. The review's
findings are evidence to assess, not this task's prescribed conclusions.

## Done when

Classify every finding against the agreed acceptance and material-risk bar.
Repair each accepted issue within this scope, or record the supported trade-off
or contract decision. Complete the required controls and verification for any
changes. Reconcile the report and k76 handoff with the resulting behaviour.
Keep the original action/read counts, waits, poll bounds and one-attempt rules.
If a required change needs a human scope decision, keep dependent work live.

## Notes

This step precedes settings-scenario-adoption-k76 in the same directory.
It grants no VM, candidate, freeze, additional runtime slot or acceptance.
k76 retains complete adoption, signals and both held-pointer controls.
k67, k62, k57 and k54 retain their original duties. Secret-bearing evidence
roots stay private. Substantial redesign follows the Grove integration rules.
