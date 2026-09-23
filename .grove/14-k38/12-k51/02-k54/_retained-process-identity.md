# retained-process-identity-k54 — brief


## Goal

Design a feasible non-time native process identity, preserving the client's
capture boundary and strict process lifetime, and settle the full client and
provider contract with the human before k52 implements it.



## Current targeting agreement

In `native-target-contract-k78`, the human selected **endpoint addressing only**.
Capture/reference lifetime remains tied to the original process; Koine never
rebinds its admitted endpoint. Receiver movement, descriptor reuse, forwarding
and downstream effects on another window in the same live process or another
process, including a restored successor, are explicitly outside the effect
guarantee. Read the current capture and
`desktop-effects-use-the-admitted-endpoint` ADRs and
`docs/specs/machine.md#native-targeting-discussion` for the precise boundary.
This qualifies inherited strict-effect criteria below; historical investigation
and decision logs retain the requirements against which they were written.
Public clients, callback-time capture, non-time identity, Koine consent and no
helper/injection/cooperation remain required. No shipping mechanism, lifecycle
policy, restart policy or first release is approved. k79 reviews this agreement;
k75 retains the full protocol and k52 handoff. Read replies and notifications
require authentication, freshness and attribution; unsupported protocol forms
refuse the affected operation without silent omission. Endpoint admission is
distinct from grant/dispatch admission. In k80 the human agreed that authenticated
observed closure permanently retires a window reference; undetected closure or
descriptor reuse may still target another window. Retired references never revive
or get reused. k75 must establish observation and retirement evidence. The parents remain live.

## Context

- Read the parent brief's human decisions and pinned task-right review. Client
  capture is required; server-side foreground selection is rejected. Automatic
  restoration under a new process must invalidate a capture. Those choices
  are settled, not questions to repeat.
- `docs/adr/desktop-capture-preserves-the-process-incarnation.md` records those
  constraints. `docs/verification/process-serial-lifetime.md` demonstrates why
  PSN plus boot UUID fails; public deprecation is not its decisive flaw.
- `docs/specs/machine.md` and the design SDL still describe the currently served
  timestamp input, explicitly awaiting replacement. The native direction is
  **not** an agreed IPC API, restart policy or reference grammar.
- `process-identity-without-time-k52` is the existing implementation leaf; its
  body already names affected source/schema/client surfaces and VM reports.
  Finish that handoff; do not add implementation leaves from a design session.
- Start from the Tier 2 code findings in the parent review, refresh graph
  freshness/coverage, then inspect the specific seams you rely on. The present
  provider checks identity and later constructs AX application targets from
  PID; a retained task right does not reserve that PID. Held-window CFEqual
  evidence is not proof of binding an endpoint across process incarnations.

## Done when

- A concrete native acquisition/transfer mechanism and its feasibility
  evidence are reviewed with the human. Specify where capture linearizes in
  the native key handler, how it is attributed to the observed application,
  and refusal on ambiguity, null/dead rights or policy denial. Merely acquiring
  a right for a previously observed PID can capture a replacement process.
- If rights cross processes, define the actual transfer and ownership/lifetime
  protocol, endpoint discovery, authentication, bearer-grant checks/revocation,
  cleanup and resource bounds. A numeric port name in GraphQL is not a transfer.
  Preserve client-owned adapters, no runtime compilation/private client APIs,
  and Koine ownership of Accessibility consent unless the human explicitly
  agrees to a necessary change.
- Define precise opaque reference grammar, token non-reuse, malformed versus
  absent versus stale results, death/exec behavior, and provider/client/Koine/
  boot restart semantics. The existing application reference survives Koine
  restart; continuously held rights do not obviously preserve that property.
  Seek agreement on any necessary change with the concrete trade-off shown.
- Account for every native effect and confirmation under k78's endpoint-addressing
  boundary: authenticated admission, continuous retention, no destination
  reacquisition, and honest refusal/uncertainty when death races use. Do not
  claim atomic no-substitution for receivers, descriptors or downstream work;
  those guarantees are explicitly excluded. Keep capture/reference expiry strict.
- Update the machine spec, design SDL, published design operations, capture ADR
  (in place), other affected current ADRs, client guide and architecture views
  to the agreed contract. Confirm the prepublication `koine-desktop/1` framing
  with the human alongside the mechanism; it is still unconfirmed.
- Complete k52's provider/schema/reference/tests/capture instructions and
  acceptance evidence renewal, including the automatic-restoration regression,
  delayed client capture across an app switch, native binding and all agreed
  restart boundaries. Keep simulated identity mismatch distinct from actual
  PID recycling.

## Notes

The fallback to beat is a client-retained kernel identity transferred to Koine,
but it is only a direction. The remaining design must resolve a whole usable path,
not accumulate another field substitution. Make platform assumptions explicit
and use targeted native evidence for platform lifetime facts; an abstract model
cannot prove an OS uniqueness premise. If protocol ordering itself has a
checkable uncertainty, model that concrete claim.

All GUI/native execution goes in a disposable TestAnyware clone. The existing
diagnostic fixture builds with `task fixture:process-serial`; its app must not
be launched on the host. `task design:render-process-identity` regenerates the
discussion views. The viewer's stable URL is
`http://127.0.0.1:8772/#discussion` when served from its directory.

## Investigation

The retained-AX candidate is now disproved by native evidence, rather than just
unproved in public documentation. See `docs/verification/retained-ax-binding.md`:
at actually recycled PID 781, an old held window minimized the replacement;
the task right was dead and no fresh AX acquisition occurred in the holder.

## Decomposition

Native effect binding proved to be a separate platform feasibility question
before a transfer protocol could be chosen. The human authorized investigating
private APIs inside Koine while keeping clients public and strict lifetime.
The original completion criteria above continue to bind this node:

1. `retained-ax-lifetime-k55` — preserve the public AX counterexample, correct
   acceptance claims and record the human's next direction.
2. `private-process-binding-k56` — establish a concrete private-server binding
   and its limitations, or surface an evidenced feasibility conflict. Its first
   child disproves private token/data reconstruction; its remaining direct AX
   service-endpoint design must settle feasibility before the contract proceeds.
3. `process-identity-contract-k57` — resolve the adoption conflict, seek a
   concrete new native-binding lead, then agree the complete client/transfer/
   reference/restart contract, reconcile durable docs and finish the existing
   k52 implementation/evidence handoff. Its children separate the settled
   candidate decision, source survey and remaining protocol design.

## Code and API evidence

Tier 2 graph verification refreshed generation `2026-09-21T11:22:48Z`;
coverage for the provider's identity, observation and effect files reported
matching metadata and no recorded gaps. Exact snippets show `resolveAndAct`
reducing the resolved target to PID plus held window; `act` recreates an AX
application for `AXFrontmost`, and `hasFocus` recreates it again. Source reads
confirmed those paths; unrelated heuristic call edges were not evidence.

The installed Xcode 27.0 (27A266a), macOS SDK 27.0 public `AXUIElement.h`
exposes PID-based application creation, element-based actions and PID reporting.
Those declarations do not bind an element to a supplied task-name right or
document cross-incarnation endpoint lifetime. The public documentation alone
does not prove a retained AX object retargets, either.

The one bounded in-session reviewer examined alternative public effect routes.
Reconciliation: its NSRunningApplication lifetime mismatch and missing retained
AX lifetime guarantee are valid/actionable; retain the window's AX parent as
the stronger candidate and test it rather than claiming a universal public-API
impossibility. Apple Events' `typeMachPort` is a real alternate effect transport,
but `AEGetRegisteredMachPort` exposes the calling process's endpoint, not a
task-bound arbitrary target acquisition; arbitrary window focus and consent
equivalence remain unestablished. The obsolete `kAEDontReconnect` flag cannot
be relied on. These are investigation findings, not an approved replacement.

## Decisions (running log)

- Resolve native effect binding before choosing the transfer wire format:
  neither an authenticated native bridge nor a non-reused reference token
  repairs a PID-based native action. Use SDK/primary API evidence and a
  TestAnyware PID-recycling probe for this platform-lifetime question; a model
  that assumes the endpoint binding would not establish it.
- After the held-only PID-recycling counterexample, the human chose
  **investigate server-side private APIs**, preserving strict process lifetime
  and public client APIs. This authorizes investigation inside Koine; it does
  not approve a particular private mechanism, transport, restart policy,
  reference grammar, or weakening of the action guarantee.

## Private-binding feasibility result

k56 closes on its original evidenced-conflict branch. Read
`docs/verification/ax-endpoint-adoption.md`, the capture ADR and the adoption
view before k57's contract discussion. Direct AX transport has bounded native
successes, but receiver/descriptor and downstream lifetimes plus actual admitted
restoration remain unestablished. AX contact inhibits automatic termination in
the matched fixture. Separate Koine policy attribution/denial is untested and
does not resolve those native gaps. No complete binding or private-adapter OS
support set is approved.

The initial adoption decision declined the candidate against the strict effect
requirement. k78 now records the human's explicit choice of endpoint addressing
only. That makes receiver/descriptor and downstream no-substitution excluded
guarantees, without changing the old evidence or adopting a shipping mechanism.
The direct endpoint can be evaluated against the revised boundary after k79's
review. k74's separate activation route is outside that boundary and was explicitly
abandoned by the human. k75 retains capture/transfer, lifecycle and consent evidence,
reference/restart semantics, prepublication agreement and the k52 handoff. Those
original deliverables remain live under the revised effect guarantee.

k75's design subtree now separates an observation-retirement proposal and its
review from native observation, callback capture/transfer, lifecycle, consent
and final protocol agreement. Those live children preserve this node's complete
contract and k52 handoff obligations; no native observation mechanism has been
adopted by the proposal.
