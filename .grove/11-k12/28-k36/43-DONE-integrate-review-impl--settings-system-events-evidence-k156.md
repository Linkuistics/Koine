# settings-system-events-evidence-k156

**Integrates:** settings-system-events-evidence-k155

## Goal

Independently triage the review settings-system-events-evidence-k155 and apply
the changes that its acceptance and material-risk bar earns. Finish before
k152 or k76 consumes the checked System Events and enrolment artifact.

## Context

Read the findings from the review's own commit and
`docs/verification/settings-activation/ORDERING-SYSEVENTS-REVIEW.md`. Read the
producer settings-system-events-evidence-k151, its report and source, the
ordering protocol and the current inherited contracts. The review supplies
source evidence and retained receipts, not native acceptance.

## Done when

<!-- tc: depart synonym-rotation because "checked" names the artifact class, "verify" a repair and "checks" Taskfile tasks -->
- Classify each finding against the source and the agreed acceptance bar.
  Record the disposition and its evidence. Apply and verify each earned repair.
- Preserve the existing assertions, inputs, read counts, sleeps, poll bounds,
  one-attempt transports, writer domain and first-failure rules. Add no guest,
  retry, substitute route or transport exemption.
- Record meaningful failing controls before repairs and the appropriate
  passing Taskfile checks. Keep the original receipts and their stated limits.
- Keep the original k75/k71/k66 duties with their existing owners. k152, k76,
  k67, k62, k57 and k54 retain their remaining work. Secret-bearing roots stay
  private. No VM, candidate, freeze or native acceptance is permitted.

## Notes

Read the findings from the review's commit, not from this task's body. A finding
that does not survive independent verification may be rejected visibly. This
integration is a flat sibling immediately before k152, so no consumer changes
the reviewed source first.

## Decisions (running log)

- 2026-11-22: Classify P2-1 as a real issue. The parser of 2d25459b
  accepted any message with -1719 or -1728 as an absence in the three polls.
  The cited presentation has the digest that the review recorded. It shows a
  System Events read that System Events refuses for assistive access with
  -1719.
- 2026-11-22: Settle the absence boundary on the host AppleScript formatter.
  A bare -1728 gives "Can’t get REFERENCE.", and a bare -1719 adds "Invalid
  index.". The bytes are the same with no locale. An absence now also needs
  that message, attributed to System Events. Each other message is
  unavailable, and the poll stops at once. Read counts, sleeps, bounds and
  statuses stay the same. A guest with other wording is unavailable, never a
  negative.
- 2026-11-22: Accept the review's correction of the SDK claim.
  `MacErrors.h` defines `errAEIllegalIndex` and `errAENoSuchObject`. The
  report and the code comment now cite both definitions.
- 2026-11-22: The baseline with the read table of 222e89db fails five new
  controls. Each shows the denial as a clean negative that sleeps and then
  completes. Mutations K01, K03 and K04 fail their named controls. The
  measured run passes 15 Taskfile checks and 247 tests, with each subject
  unchanged. The receipts are in
  `docs/verification/settings-activation/ordering-sysevents-integration-evidence/`.
- 2026-11-22: The repair stays bounded and keeps every transport rule, so
  this integration earns no further review round. k152 and k76 may consume the helpers. The
  k75/k71/k66 duties and every runtime hold keep their owners.
