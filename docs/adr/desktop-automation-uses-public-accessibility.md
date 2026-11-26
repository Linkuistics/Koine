# Desktop automation uses public Accessibility

Koine uses public macOS Accessibility APIs for window listing, focus and
notifications. The
[capture decision](desktop-capture-preserves-the-process-incarnation.md) fixes
the process identity that a client submits. Koine checks it before AX work and
never substitutes another process under it. Public AX routing is a separate
boundary, and Koine keeps it on a best-effort basis.

Koine accepts wrong-process or wrong-window data and effects during process or
window reuse. It also accepts stale or misattributed notifications, and
mistaken withdrawal of live references or remembered windows. Koine does not
independently authenticate each AX reply or notification. It does not prove
the lifetime of a window or the age of an event, and it does not guarantee
that a read is fresh. The
[held-AX counterexample](../verification/retained-ax-binding.md) shows why a
check of a task identity cannot establish those properties for public AX. It
does not measure how often a normal race between check and use happens.

Framework-managed AX reception has no hard memory or Mach-right bound that
Koine enforces before acquisition. Oversized or malformed target traffic may
cause resource pressure or Koine failure, including traffic from the intended
target. Koine must still bound its own records, accepted values, queued work
and the native resources it directly owns. The
[receive experiment](../verification/native-observation-receive.md#pre-copyout-admission-assessment)
explains why later parsing limits are not acquisition bounds.

Koine keeps live-grant admission, its own Accessibility consent, refusal of
processes that no longer match their identity, and permanent reference
withdrawal without reuse. A platform closure report may withdraw a reference
without proof of physical closure. A later report cannot revive that
reference. A failed call may have acted. Koine never replays a mutation
automatically. The [spec](../specs/machine.md#native-targeting-discussion)
lists the accepted limits.

Koine does not own the private AX endpoint and wire protocol. No inspected
mechanism bounds what that channel acquires before parsing. Rebuilding AX
objects from private tokens crosses process incarnations, just as held public
elements do. The
[held-AX counterexample](../verification/retained-ax-binding.md#private-ax-reconstruction-does-not-bind-a-process-either)
shows it. Koine uses no helper, injection, target cooperation or behavioural
restriction of applications.
