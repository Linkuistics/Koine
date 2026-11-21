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

## Decisions (running log)

- 2026-11-22: The pinned Apple bytes match the digests of the k157 source
  receipt. Both findings follow from that source.
- 2026-11-22: P2-1 is a real issue. The path call returns ESRCH for some live
  processes, so only a process-information read reports an absent process.
  A failed path read of a live process exits with status 7 and is
  unavailable. The command, the three kernel calls and the read count stay
  the same.
- 2026-11-22: P2-2 is a real trade-off of the unchanged command. The protocol's
  clean exec result can be supplied, so its hold rule does not apply. The
  changed boot stays the only confirmation of the restart. A failed reboot3
  ends as the state failure of the boot poll and is never a Koine failure.
  The comments, the report and the k76 handoff state this limit.
- 2026-11-22: The report's claim about the 5-second gap had no timing
  evidence. The feasibility section now keeps the timing unknown. The hold
  decision does not change.
- 2026-11-22: The fake libproc fixture runs the real identity script, because
  no host process fails its path read on demand. The baseline fails only the
  new ESRCH control. Four mutations each fail their named control. The
  measured green run passes 17 checks and 272 tests with unchanged subjects.
- 2026-11-22: No further review is earned. The repair is local and has
  controls, and k76 cuts the whole-harness review before k62 and runtime.
