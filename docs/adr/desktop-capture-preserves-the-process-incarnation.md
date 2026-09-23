# Desktop capture preserves the process incarnation

The desktop target is the frontmost application captured by the client's native
event handler when the callback executes. It denotes that OS process incarnation and expires when
the process ends. Restoring the same logical application under a new process
does not keep the capture alive. Koine must not substitute whichever application
is frontmost when its query arrives, or another process that reuses a PID.

The original key event's target is not the capture source. If a queued callback
runs after an application switch, it captures the foreground application at
that callback; if focus changes after capture, the capture stays with its
original process. This preserves the client's AppKit foreground-capture model.
The native mechanism must still establish the foreground sample's freshness,
its linearization point within the callback, and its attribution to the held
identity; cached AppKit state is not automatically a fresh sample.

This boundary preserves ModalAnyware's interaction: a user invokes an operation
in one application and can choose a window after focus has moved elsewhere.
The identity must not depend on time. Timestamp identity remains in the existing
implementation while its replacement is designed; it is not the approved
first-release mechanism. The [machine spec](../specs/machine.md) identifies that
open contract change. Retained native identity is the next design direction,
not yet an approved transport, reference encoding or restart policy.

A public Process Manager serial number plus platform boot identity is rejected
as the process identity. The
[macOS 26.5 counterexample](../verification/process-serial-lifetime.md) shows the
same pair before and after automatic termination/restoration, with different
PIDs and audit-token pidversions. Even a live-process check accepts the restored
process if Koine receives the capture after restoration. This alternative would
need a separate trustworthy incarnation discriminator, or an explicit change to
logical-application semantics, before reconsideration. Deprecation is not the
reason for rejecting it.

Retained task rights alone do not settle target safety: they retain identity,
not ownership of a PID. Capture attribution and the native endpoint of every
effect must bind to the captured incarnation. Checking identity and then acting
through a fresh PID lookup does not meet that obligation. Client capture and
strict process lifetime are settled constraints; the remaining protocol must
establish them before the public schema changes.

Retaining an AX window and its AX application parent also does not supply that
binding. A [macOS 26.5 PID-recycling experiment](../verification/retained-ax-binding.md)
kept both objects and a task-name right while the original process ended. The
task right became dead, but the held window later addressed and minimized a
replacement process at the same PID, without a fresh AX acquisition in the
holder. A task check cannot exclude death between the check and that effect.
This candidate needs an independently established native endpoint binding;
retention plus another pre-check is not a replacement mechanism. Investigation
of private APIs inside Koine is authorized, while clients keep public APIs and
strict process lifetime remains required. No particular private-API solution
or relaxation of the no-substitution guarantee is agreed.

Private AX token or data reconstruction is not the missing binding either.
The [signed/hardened private probe](../verification/retained-ax-binding.md#private-token-and-data-reconstruction-also-cross-incarnations)
shows both reconstructed objects affecting a successor at a recycled PID;
reporting the element's "actual PID" does not distinguish that successor.
These routes add private dependency risk without satisfying strict lifetime.
Reconsider them only with an independently established native binding, not
another encoding or check. Direct acquisition of a retained AX service endpoint
has bounded diagnostic evidence but is not adopted. A
[signed/hardened direct-port probe](../verification/direct-ax-endpoint.md)
found that the retained port stayed dead across actual PID reuse, and a fresh
error reply with a kernel audit trailer matched the retained live task while
rejecting a wrong-task control. This supports contemporaneous responder
authentication, not the complete lifetime guarantee. A
[direct-effect diagnostic](../verification/direct-ax-endpoint.md#direct-effect-path)
also exercised read, restore, main selection, raise, activation and focus
confirmation through one retained endpoint, with an independent witness and
post-death refusal. Its build-specific internal stubs establish transport
feasibility, not a supported shipping ABI. An
[audited read and scheduled-death diagnostic](../verification/direct-ax-endpoint.md#audited-read-admission-and-scheduled-death)
matched a real `AXRole` reply to the retained live task, rejected wrong/dead-task
controls, then exercised same-endpoint effects. Death before/between effects and
actual PID reuse refused every later primitive on the tested Cocoa target.
The [receiver investigation](../verification/direct-ax-endpoint.md#receiver-allocation-and-transitions)
resolves local receive-right allocation, bootstrap send-right registration and
cleanup on the inspected build. A same-PID exec makes both retained rights dead;
all old-endpoint effects refuse and the successor remains unchanged. These are
bounded observations, not immovability or every handler's behavior. Matched
[automatic-restoration controls](../verification/ax-automatic-restoration.md)
expose a lifecycle conflict on the tested Cocoa target: no-AX controls terminate
and restore, while one successful role read leaves the target ineligible after
reader exit. Direct admission and retirement of only the local client port do
not recover eligibility in the measured interval. Target nontermination must
not stand in for a passing admitted-restoration test; changing client-port
ownership is not yet a demonstrated remedy or approved product policy. Public
AX PID reporting can also prefer a presenter PID over the actual receiver.
The [top-level routing investigation](../verification/ax-top-level-routing.md)
traces ordinary AppKit descriptors through local registration and concrete
callbacks. Unmodified TextEdit's Open panel has a local top-level descriptor and
remote children; the current provider's child-to-window test refuses that panel.
Receiver-local data therefore has a bounded usable route, with an availability
cost, not an arbitrary-target guarantee. Application activation reaches
WindowServer/Launch Services after the AX callback; binding that downstream work
through process death is still unestablished. Custom handlers, descriptor lifetime
and arbitrary receiver transfer also remain assumptions. PID reconstruction,
another task check or an implicit support restriction does not close those gaps.

Koine declines the investigated direct AX endpoint as its process binding and
preserves strict process lifetime. The
[adoption synthesis](../verification/ax-endpoint-adoption.md) establishes the
reason: the complete lifetime guarantee remains unestablished. This is a
feasibility conflict, not universal impossibility or a demonstrated direct-port
successor effect. Narrower application support and weaker targeting semantics
are not selected. The cost is that the non-time replacement and first public
release remain unresolved; the timestamp mechanism is not approved for release.
Separate Koine consent/denial and notarized private-path launch are untested;
another consent success alone cannot resolve the lifetime gaps. Existing
public-AX release acceptance does not transfer to the private protocol.

Reopen native investigation only for a specific lead addressing
receiver/descriptor and downstream lifetimes, actual admitted restoration and
its lifecycle policy. The [survey triage](../verification/ax-endpoint-adoption.md#survey-triage-and-next-investigation)
proposes window-qualified activation as a partial downstream diagnostic.
The human requires discussion of a narrower support or targeting contract before
further native work. No particular restriction or weaker guarantee is selected.
Restore/main/raise still need target handlers, and no new
complete route to them has been established. The diagnostic is not adoption of
the declined endpoint. Arbitrary receiver/descriptor lifetime remains without a supported closure; no support
restriction or weaker guarantee is inferred. Adoption would also require
evidence for separate consent and maintainable protocol support. A narrower
target contract requires explicit agreement. Any future private adapter must
own cleanup, bounded work, cancellation uncertainty and exact-version refusal
inside the desktop provider;
internal binary entry points and an owned wire encoder both incur recurring OS
verification costs. The approved private-adapter support set is empty; 25F71 is
diagnostic evidence only. Client capture/transfer, reference/restart semantics
and the prepublication version agreement remain unresolved. No complete
replacement mechanism is approved.
