# Desktop automation uses public Accessibility

Koine's first deliverable uses public macOS Accessibility APIs for window
listing, focus attempts and notifications. The
[capture contract](desktop-capture-preserves-the-process-incarnation.md) still
requires a fresh client callback sample and continuously held non-time process
identity. Death or exec invalidating that identity ends the capture and its
references; Koine never reacquires a replacement process identity under it.
Public AX routing is a separate, best-effort boundary.

This accepts wrong-process or wrong-window data and effects during process or
window reuse, stale or misattributed notifications, and mistaken withdrawal of
live references or remembered windows. Koine does not independently authenticate
each AX reply or notification, prove its window lifetime or event age, or
guarantee read freshness. The
[held-AX counterexample](../verification/retained-ax-binding.md) demonstrates why
checking a task identity cannot establish those properties for public AX.
It does not measure the frequency of a normal check-to-use race.

Framework-managed AX reception has no Koine-enforced hard memory or Mach-right
bound before acquisition. Oversized or malformed target traffic may cause
resource pressure or Koine failure, including traffic from the intended target.
Koine must still bound its own records, accepted values, queued work and native
resources it directly owns. The separate capture/right-transfer channel retains
its acquisition, peer-authentication and ownership obligations. The
[receive experiment](../verification/native-observation-receive.md#pre-copyout-admission-assessment)
explains why later parsing limits cannot be called acquisition bounds.

Koine retains live-grant admission, its own Accessibility consent, refusal of
known-dead captures, local callback ownership and irreversible reference
withdrawal/non-reuse. A platform closure report may withdraw a reference without
proving physical closure; a later report cannot revive that reference. Public
focus results must distinguish attempted work, framework-reported observations
and uncertainty. A failed call may have acted; mutations are never automatically
replayed. The [spec](../specs/machine.md#native-targeting-discussion) carries the
remaining capture, lifecycle, reference, restart and acceptance work.

Owning the private AX endpoint and wire protocol was considered and rejected
for the first deliverable: the inspected mechanisms did not establish its
required pre-acquisition budget or complete authenticated observation path, and
that investigation exceeded the capture/list/focus need. Its bounded evidence
remains useful, but no further private exchange, publication-barrier or loss-
recovery experiment is required by this contract. Reopening that path needs an
explicit product requirement and a concrete enforcement lead. No helper,
injection, target cooperation or behavioral application restriction is adopted.
This decision agrees scope; it does not establish capture/transfer feasibility
or authorize the unmodified timestamp implementation for release.
