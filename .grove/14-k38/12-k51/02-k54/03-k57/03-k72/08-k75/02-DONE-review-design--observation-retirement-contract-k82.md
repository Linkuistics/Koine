# observation-retirement-contract-k82

**Reviews:** observation-retirement-contract-k81


## Goal

Adversarially inspect the proposed observation/retirement construction against
k80's agreed rule before native investigation consumes it.



## Context

Read the producer's committed spec subsection and reference-lifetime view,
the capture/effect ADRs and k75's unabridged Done when. The proposal deliberately
does not claim native feasibility or product agreement to its refusal costs.

## Done when

- Test whether publication, retirement and actual send initiation have a
  coherent local order without assuming native closure timing or a registration
  barrier that has not been evidenced.
- Challenge old notification versus reused descriptor, closure before
  registration acknowledgment, late reply after cancellation, and ownership
  release while delivery remains queued. Separate sender authentication from
  event freshness and window/capture attribution.
- Check refusal does not become a silent application-support restriction,
  a claim of observed closure, an unbounded leak, or a vacuous successful path.
- Check k75's original capture/transfer/lifecycle/consent/reference/restart/
  version/handoff obligations all retain live owners. Findings only; schedule
  integration before k83 if material repairs are needed.

## Notes

No in-session reviewer. Do not demand excluded end-to-end effect guarantees
or treat the proposed states as new public wire types or native evidence.

## Findings

Read against k81's commit `f1eaa51` (jj `lpxvupwu`): the spec subsection
`docs/specs/machine.md#observation-and-retirement-protocol-proposal`, the
`process-observation` view and caption, the capture and endpoint-effect ADRs,
k80's agreement record and k75's unabridged Done when. Line references are to
`f1eaa51`. Ordered by severity. None asks for an excluded end-to-end effect
guarantee, and none treats the private states as wire types or native evidence.
Integration must repair the artifact before k83 freezes its discriminator.

### 1. Observation loss is a state trigger, but its detectability is nowhere a proof obligation — high

`Usable` exits to `Withdrawn` on "loss of required observation" (`machine.md:1228`,
diagram `Usable --> Withdrawn`), and a remembered row requires "an intact
observation registration" (`:1235`). The evidence table (`:1200-1206`) and the
discriminator (`:1313-1323`) require source, registration, window, freshness and
capture attribution for a delivery that *arrives*. Neither asks whether a
delivery that never arrives is detectable. A notification the target never
sends, or one the delivery path drops (a full queue or a timed-out send, for
example), looks exactly like a window that has not closed. No native gap or
sequence number is proposed that would expose it, and a locally assigned
sequence cannot date or count the target's events (`:1205`).

Consequence: `Withdrawn` fires only for losses the adapter can see, such as
torn-down registrations. The ordinary silent loss goes unseen, and "intact" is
then either unestablishable, which refuses every remembered row, or assumed,
which is the unproved premise under another name. The k80 agreement accepts
that an *undetected* closure may affect another window, but the proposal's
`Withdrawn` and remembered-row rules depend on detecting loss.

Integration must add completeness/loss detection as an explicit native
obligation, or state that loss is undetectable and give the consequences for
`Withdrawn` and remembered rows. k83's discriminator must then include suppressed
and saturated delivery with a control that actually detects a missing closure.

### 2. Read attribution after an undetected closure or descriptor reuse is unagreed — high

The human's k80 choice relaxes *effects*: an undetected closure or reuse "may
still target another window". k80's triage of findings 3 and 4 says no read
relaxation was inferred, and the spec requires descriptor attribution for
synchronous reads (`:1216`). The proposal, though, has no mechanism for that
attribution except complete closure observation. Say a window closes and its
descriptor is reused, and the closure is never observed (finding 1). The next
enumeration lists the same descriptor bytes, and matching by element equality
(as served `HeldWindows.rows` does, and as the proposal leaves unchanged) pairs
them with the old `Usable` record. The listing then reports the new window's
title and presence as `CURRENT` under the old reference. A focus confirmation
read has the same problem. That is a misattributed *read*, not only a wrong-window
effect.

Integration must either name the native evidence that attributes a re-enumerated
descriptor to the existing record's lifetime, or surface this as a separate read
consequence needing explicit agreement (the human, or k87's agreement). The
effect relaxation must not absorb it silently. The glossary's observed-closure
entry and the effect ADR should say which one holds.

### 3. The reply–notification delivery order is assumed, not stated as a premise — medium-high

The interleaving "reply is received, then closure commits before publication"
(`:1282`) and the buffering rule (`:1243-1247`) work only if a closure that
happened before the enumeration or confirmation reply was generated gets
committed before that reply's candidate is published. Replies come in on
per-request reply rights. Notifications come in on the registration's delivery
path. Nothing in the proposal orders a closure notification ahead of a later
reply on a different right. The "registration barrier" is framed as the gap
between registration and enumeration (`:1243-1250`). The discriminator asks
about attribution and isolation (`:1313-1315`), not the cross-channel delivery
order that publication depends on, and not the gap in the other direction for
confirmation reads on already `Usable` records.

The proposal also does not name the candidate registration orders, which leave
different gaps. Registering at application scope before enumerating leaves a
cross-channel ordering gap. Registering per element after enumerating leaves a
reuse gap between the listing and the registration. The next investigation
should choose between them, not discover the difference.

Integration must state the delivery-order premise each order needs, or the
fallback when it is absent (unavailable, as for the barrier). It must add that
premise to k83's frozen discriminator.

### 4. "Actual send initiation" is treated as an instant with a single outcome — medium

The local order is "final state check and actual native send initiation" with no
intervening owner operation (`:1270-1276`), while the owner "does not wait for a
native reply" (`:1192-1193`). Two points are unspecified:

- **Received but uncommitted evidence.** The final check need not first drain
  deliveries that have already arrived. Whether an arrived authenticated closure
  counts as observed then depends on local scheduling. That is permissible under
  the undetected-closure relaxation, but the proposal should say whether the
  check drains the delivery path (with bounded validation) or accepts that gap
  explicitly.
- **A send that blocks or fails to enqueue.** A send to a target-owned queue can
  block or time out. Blocking while holding the owner contradicts `:1192`.
  Handing the send to a worker needs "the same ordering", which the proposal does
  not construct. A timed-out or refused enqueue needs a classification: sent
  nothing, which supports the refusal-before-send claim, or possibly sent, which
  is uncertain. The proposal has no such classification.

Integration must specify bounded initiation and the classification of each send
outcome. It should record, for k83/k86, which native send results actually
establish "not enqueued".

### 5. The single `Preparing` discard exit permits silent omission — medium

The spec's `Preparing` exit is "otherwise discard without publishing" (`:1227`).
The diagram merges "Closure, missing provenance or failed registration" into one
`Discarded — Never published` transition. Only a closure established before
publication justifies leaving the window out. Missing provenance or failed
registration must fail the affected listing as unavailable (`:1238-1240`; k75
"do not silently omit windows"). As drawn, a failure reads like a legitimately
absent window. `Discarded` also appears in the diagram but not in the spec's state
table. Capture death/exec during `Preparing` has no stated exit.

Integration must split the two outcomes in both the spec and the view, and give
capture end during preparation an outcome.

### 6. Withdrawal can be triggered from outside, and its scope and recovery are open — medium

Foreign or obsolete events are discarded. A "malformed or unattributable event on
a current owned registration" withdraws the affected records permanently
(`:1296-1300`). The rule does not say whether the split turns on native source
authentication. If an unauthenticated message on the registration's delivery
path counts as "unattributable", any holder of a send right can withdraw
references. An unattributable event also cannot name its window, so "affected
records" presumably means every record on that registration. Recovery "requires a
new admissible capture/listing" (`:1230`), which leaves open whether the client
must capture again. A remembered row that cannot be established fails the whole
affected listing (`:1238`).

Together, these make availability depend on how an application behaves: whether
its windows on other Spaces answer reads, and whether its notifications conform.
The proposal says it approves no application-support restriction (`:1327`), but
it gives no way to see which applications this refusal removes. That is the
"silent application-support restriction" the k75 charter prohibits.

Integration must key discard versus withdrawal on source authentication, and
state refusal granularity (window, registration or listing) and recovery under
the same capture. It must list the behaviors that trigger refusal so that k87's
availability agreement sees the actual support consequence.

### 7. Reason reporting and allocator scope conflict with bounded reclamation — low-medium

Every later use of a `Withdrawn` record reports "the actual reason" (`:1230`),
and a retired record's known closure is permanent (`:1229`). Reclamation must
still avoid an unbounded tombstone set (`:1260-1263`). A monotonic high-water
mark can reject old identifiers without tombstones, but it cannot recall *which*
terminal state or reason applied. The proposal should say which distinctions
survive reclamation. The allocator's scope (per capture, per provider run) is also
unstated. Withdrawal and relisting churn, which a target can drive (finding 6),
advances it toward the refuse-before-exhaustion point. Integration must bound
that or assign it to k86's resource limits.

### 8. "Retire" means two things — low

The addressing boundary says "Death or exec retires the old capture and
references" (`:1110`). The proposal reserves `Retired` for authenticated closure
and files capture end under `Withdrawn`. Because the visible reason depends on
this distinction, align the wording in the spec, the view and, if it is used, the
glossary's observed-closure entry.

### Checked and holding

- The local order is coherent within one serialized owner. It orders commits, not
  native closure timing, and it does not claim to enclose native execution or
  downstream work (`:1275-1276`).
- Sender authentication is kept separate from registration, window, freshness
  and capture attribution (`:1200-1210`).
- The old-notification, cancelled-late-reply and old-registration interleavings
  have distinct ownership rules.
- Cancellation is kept separate from capture-lifetime observation (`:1287-1289`).
- Release waits for the delivery and local queued work to drain, and an
  unbounded drain is called an incomplete design, not permission to leak
  (`:1290-1294`).
- `Withdrawn` explicitly claims no closure.
- Refusing every window is called a non-successful path.
- PID-only events cannot retire a capture.

Each of k75's original capture, transfer, lifecycle, consent, reference, restart,
version and handoff obligations still has a live owner (k83 to k87, with k87
rechecking all of them). The open questions from findings 1 to 3 have no owner
until integration places them: the k83 discriminator for native premises, and
k87 or the human for the read-attribution consequence.
