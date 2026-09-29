# Desktop automation uses public Accessibility

Koine's first deliverable uses public macOS Accessibility APIs for window
listing, focus and notifications. The
[capture decision](desktop-capture-preserves-the-process-incarnation.md) fixes
the process identity a client submits; Koine checks it before AX work and never
substitutes another process under it. Public AX routing is a separate,
best-effort boundary.

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
resources it directly owns. The
[receive experiment](../verification/native-observation-receive.md#pre-copyout-admission-assessment)
explains why later parsing limits cannot be called acquisition bounds.

Koine retains live-grant admission, its own Accessibility consent, refusal of
processes that no longer match their identity, and irreversible reference
withdrawal/non-reuse. A platform closure report may withdraw a reference without
proving physical closure; a later report cannot revive that reference. A failed
call may have acted; mutations are never automatically replayed. The
[spec](../specs/machine.md#native-targeting-discussion) lists the accepted limits.

Koine does not own the private AX endpoint and wire protocol: no inspected
mechanism bounds what that channel acquires before parsing, and rebuilding AX
objects from private tokens crosses process incarnations just as held public
elements do, as the [held-AX counterexample](../verification/retained-ax-binding.md#private-ax-reconstruction-does-not-bind-a-process-either)
shows. No helper, injection, target cooperation or behavioral application
restriction is used.
