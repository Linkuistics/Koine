# native-target-contract-k79

**Reviews:** native-target-contract-k78

## Goal

Adversarially inspect k78's native target contract before further native work.
Determine whether its enforceable boundary supports every retained lifetime
guarantee and whether every relaxed guarantee is visible to a client.

## Context

Read the producer's committed artifact and exact human agreement, the capture
ADR, `docs/specs/machine.md#native-targeting-discussion`, client guide, target
contract view, adoption synthesis and survey's G1/G2/G3 map. The human selected
B: endpoint addressing only, expressly accepting receiver movement, descriptor
reuse and queued activation effects on other processes, including a restored
successor. This agreement does not select a shipping adapter, lifecycle policy,
restart policy or first release. Review the retained promise, not the excluded
strict effect contract; neither infer more relaxation nor demand its restoration.

## Done when

- Check enforceable admission, continuous endpoint ownership and refusal under
  the chosen addressing boundary. Distinguish those identity checks from
  assumptions about mutable handlers, receiver movement, descriptor
  non-reassignment and downstream services. Keep a private-protocol OS profile
  separate from an unselected behavioral application-support restriction.
- Check the distinction between an unchanged destination port object,
  contemporaneously authenticated responder and permanent receiver identity.
  Find any post-check or observed-death refusal incorrectly promoted into an
  atomic no-wrong-process-effect guarantee.
- Trace the client-visible meaning of success, uncertainty and refusal through
  references, death/exec, in-flight effects, cancellation and restoration.
  Ensure any permitted effect on another process/window is explicit.
- Verify unchanged capture/public-client/consent/no-cooperation constraints and
  the exact agreement's propagation into ADR/spec/guide/view and parent rollups.
- Check k74/k75's disposition against that agreement, without inferring native
  execution, implementation, a first release or parent completion.

## Notes

Findings only. Create integration before the next live sibling only if findings
need action. This is the review required by k78's charter; no competing
in-session review accompanies it. Existing native reports supply bounded
evidence, not acceptance of a proposed new mechanism.

## Findings

Read against k78's commit `70fec1f` (jj `pymlkryu`) and the proposal revision
the human chose from (`17ef8626`, spec "The choice and recommendation"). Line
references are to `70fec1f`. Ordered by severity. None asks for the strict effect
promise back, and none infers a relaxation the human did not agree to. Where the
agreement is unclear, the finding says what integration must settle.

### 1. Same-process wrong-window effects are in the artifact but missing from the agreement record and client-facing text — high

The spec permits a reused descriptor or custom handler to "select another window
… even while the originally captured process remains alive"
(`docs/specs/machine.md:1114-1115`). The capture ADR says "effects on another
window or process" (`docs/adr/desktop-capture-preserves-the-process-incarnation.md:23`).
The option the human chose was presented with this cost: "Another window or
process … may be affected" (`17ef8626`, option B's "Observable cost").

Everything else describes only effects on **another process**:

- k78's recorded agreement: "descriptor reuse … to affect another process"
  (`04-DONE-…-k78.md:64-67`);
- the four identical "Current targeting agreement" rollups (k51, k54, k57, k72);
- the client guide (`docs/client-guide.md:208-213`);
- the glossary's **Endpoint addressing** (`CONTEXT.md:94-97`);
- the README;
- the target-contract view (`process-target-contract.puml:14`);
- k75's charter: "Make excluded wrong-process effects explicit"
  (`07-design--…-k75.md:58`).

So a client reading its own guide would expect a window reference to focus
either the captured window or something in another process. According to the
spec, it may instead focus a different window of the same application. That
relaxation is the one a user is most likely to see.

Integration must work out whether the human's B includes same-process
wrong-window effects. The option as presented says yes; the logged paraphrase
says no.

- **If it does**, correct the log paraphrase against the presented option. Then
  propagate the wording to every surface above and to finding 2's inherited
  requirements.
- **If it does not**, then descriptor non-reassignment within a live captured
  process is a *retained* guarantee. It needs its own enforceable check and
  evidence, and the spec and ADR over-relax it.

### 2. The future contract doesn't define window-reference lifetime, and the inherited closure requirement is unreconciled — high

The addressing boundary retires references only on process death or exec
(`machine.md:1101`). It says nothing about **window closure** in a live process.
Two things are left open:

- whether a closed window's reference must still produce `unavailable`;
- whether it may resolve to whatever window reuses that descriptor (finding 1).

Existing requirements depend on closure refusal:

- the root brief's inherited server boundary: "report `unavailable` after a
  window closes" (`.grove/_BRIEF.md:54-55`);
- release acceptance: "window closure" (`.grove/14-k38/_release-acceptance.md:29`);
- the acceptance row "Closure, duplicate titles and restart behavior —
  **Established**" (`machine.md:1027`). Unlike the PID-reuse and native-identity
  rows, this row carries no note that the future contract changes it.

The served design has a mechanism for closure, but the new boundary rules it
out. Closure and termination are observed through PID-keyed services:
`AXObserverCreate(process.pid, …)` (`Providers/DesktopProvider/Sources/WindowObservation.swift:81`)
and `didTerminateApplicationNotification` reduced to a pid
(`WindowObservation.swift:51-55`). The survey lists `AXObserverCreate` among
PID-addressed services "whichever process holds the PID"
(`docs/research/native-process-bound-effects-a.md:112`). The boundary forbids
fresh PID lookup under a capture (`machine.md:1096-1097`). Its "All target AX
reads, requested effects and confirmation requests" (`machine.md:1095-1096`)
does not cover two things:

- registering for notifications;
- attributing inbound notifications, which drive retirement and remembered
  windows.

As a result, the stale-window refusal has neither a stated promise nor an
addressing rule. k75's charter does not name it.

Integration should do three things:

- state whether closure refusal is retained, and if it is, what enforces it;
- bring observation (registration and delivery) under the boundary;
- reconcile the root brief, the k38 brief and the acceptance row with the answer.

### 3. Read and observation provenance under receiver movement is optional — medium-high

Only admission requires responder authentication (`machine.md:1092-1093`).
After that, "Reply authentication **can** detect some mismatches"
(`machine.md:1119`). That permits authentication but does not require it.

The agreed relaxation lets a moved receiver or custom handler answer later
requests. All reads use the retained endpoint, so both of these could be served
by another process:

- window enumeration: the `windows` of the captured application, whose
  references are then focusable;
- focus confirmation.

The guardrail "observation needs freshness/provenance" (`machine.md:1127-1129`)
applies only to the focus result. It does not cover listings.

The human agreed to relaxed **effects**. Neither the presented options nor the
agreement said anything about **read data** attributed to the captured
application that came from another responder. The contract states neither
outcome:

- that every reply is authenticated against the retained identity, with what a
  mismatch returns and whether it stops later primitives;
- that this read relaxation is accepted.

Integration should either state per-reply authentication as a retained
obligation for reads and observations, or take the read-provenance consequence
to the human. It should not assume either answer.

### 4. The contract omits the ordering that makes responder authentication non-counter-based — medium

"Authenticate the endpoint's responder against that identity"
(`machine.md:1092-1093`) leaves out the ordering the evidence depends on:

- The synthesis: "new reply right, actual read, kernel trailer, **then** live
  retained-task comparison" (`docs/verification/ax-endpoint-adoption.md:56`).
- The survey's liveness bracket: the right is checked live *after* the reply
  was received (`native-process-bound-effects-a.md:276-290`).

Comparing the trailer against a cached pid/pidversion instead would rest on a
finite 32-bit counter. That is the kind of unguaranteed non-collision the human
rejected time for.

The contract section is what k75 and k52 build from, so it should carry this
linearization, or cite it as binding. The same ordering applies to any reply
used under finding 3.

### 5. "Failure never means that nothing happened" erases refusal-before-send — medium

The sentence at `machine.md:1121-1122` is categorical. The same section
distinguishes two cases:

- refusing admission or subsequent sends on a dead or invalid identity
  (`machine.md:1101-1103`);
- uncertainty "where work may have been sent" (`machine.md:1120-1121`).

The served contract also guarantees that preflight refusal happens before any
action (`machine.md:396`; `docs/client-guide.md:243` "Refused before anything
ran"). The synthesis says cancellation before send removes queued work
(`ax-endpoint-adoption.md:145`).

As written, a pre-send refusal cannot be told apart from post-send uncertainty.
Examples are a dead identity, revocation before dispatch, or an unsupported
adapter. That works against the required separation of acceptance from outcome.
The client guide's "a lost/failed response does not prove that nothing
happened" (`client-guide.md:215-216`) is equally broad for "failed".

The intended meaning is probably this:

- a refusal before any send means *this operation* sent nothing, though earlier
  accepted work may still act;
- a failure after a possible send is uncertain.

### 6. Protocol-form refusal is not separated, in the contract, from the unselected app-support restriction — medium-low

The agreement selects no restricted app support set (`machine.md:252-253`).
The adapter profile, however, accepts only listed descriptor and protocol forms
(`ax-endpoint-adoption.md:183`). It is also inline-only and capped in descriptor
count and size, and "may refuse real targets" (`:130`). The current
child-to-window filter already refuses TextEdit's remote-composed Open panel.

These refusals apply to live, captured applications whatever the OS build. The
synthesis warns that they must not silently become the support contract. The
contract section and the client guide still don't say two things:

- what a client sees when a window or descriptor form is outside the manifest:
  absent from the listing, `unavailable`, or unsupported;
- that such a refusal is a protocol-form limit, not a behavioral support promise.

Without that, k75 could create an application restriction the human did not
select, or silently omit windows.

A related wording problem: "support set" names OS builds in "approved
private-adapter support set" (`capture ADR:95-96`), while "restricted app
support set" names applications. Distinct terms would keep the OS profile
visibly separate from the unselected application profile.

### 7. The capture ADR now carries two independently reversible decisions — low-medium

The title and first section cover capture and incarnation lifetime. "Endpoint
addressing is the effect boundary" (`capture ADR:12-37`) is a separate call. It
has its own alternatives: restricted profiles, strict effects. It also has its
own reopening conditions (`:37-40`), which don't involve capture.

The held-element ADR and the spec send readers to "the capture decision" for
what focus promises. A reader looking for that finds no slug that names it.

"What remains unresolved" (`:77-96`) and the status statements ("still not
adopted", "support set is empty", "not approved for the first public release")
are open-work and status content. The spec's open items already carry it.

ADR-FORMAT's "split one that turned out to cover two independent calls" points
to two changes:

- a separate effect-boundary record, with its citations reconciled;
- the status moved to the spec.

Integration may judge the coupling close enough to keep one record, but should
decide explicitly.

### 8. k75's wording can be read as putting implementation evidence in a design leaf — low

"Complete k52's … instructions and every row of its evidence-renewal table on
rebuilt signed/notarized bytes" (`07-design--…-k75.md:69-70`) can be read as the
design leaf renewing acceptance evidence on rebuilt bytes. That would need k52's
implementation. k72's own criterion frames the same work "as an implementation
handoff".

Suggested rewording: "the instructions for every row, to be run by k52 on
rebuilt signed/notarized bytes."

### 9. "Admission" is overloaded — low

The spec already uses admission for grant and dispatch admission under the
serialized authority boundary (`machine.md:407-420`). The new section uses it for
endpoint authentication ("refuses admission or subsequent sends",
`machine.md:1102`), and the glossary's "endpoint admitted" (`CONTEXT.md:95`)
defines neither sense.

An implementer could assume the Authority's revocation serialization covers
endpoint admission, or the reverse. A distinct term such as "endpoint admission"
with a glossary entry would prevent that.

## Checked without a finding

- **Observed-death promotion.** No post-check or observed-death refusal is
  promoted into an atomic no-wrong-process-effect guarantee. The spec
  (`1101-1105`), ADR (`24-29`, `61-67`), synthesis ("Ordinary post-death refusal
  must not be labelled…"), view (arrow 3) and k75 all keep non-atomicity
  explicit. The final spec drops the proposal's "known" from "known dead", but
  the next sentence keeps the qualification.
- **The three identity notions.** The spec (`1107-1111`) and glossary keep an
  unchanged port object, a contemporaneously authenticated responder and
  permanent receiver ownership apart.
- **Identity checks versus assumptions.** Identity checks stay separate from
  assumptions about handlers, receiver movement, descriptors and downstream
  services, and the private-protocol manifest is kept apart from a behavioral
  restriction in the synthesis. Finding 6 is about the contract and client
  surfaces only.
- **Retained constraints.** Capture, public-client, consent and
  no-helper/injection/cooperation constraints are retained verbatim in the spec,
  ADR and all four parent rollups. The served timestamp behavior is kept
  distinct from the future contract, and the addressing view's caption is
  corrected.
- **k74.** It was abandoned with explicit human approval, recorded in k78's log.
  Its disposition section records what would reopen it, and nothing waits on it.
- **k75.** It preserves every original obligation and names no shipping
  mechanism, first release or parent completion, apart from finding 8's
  wording. k52's evidence-renewal table is unchanged.

## Review evidence

The review is inspection only. No build, test, render or native command ran,
and no file outside this leaf was edited.

Code claims in finding 2 were checked with Tier 2 graph verification of project
`Users-antony-Development-Koine`, generation `2026-09-23T06:46:23Z`:

- `WindowObservation` methods `start` (46-57), `watch` (62-70) and `makeWatch`
  (72-89) were located in the graph and read from source;
- `check_index_coverage` reported matching metadata and no recorded issue for
  `WindowObservation.swift`, `DesktopProvider.swift`, the spec, the capture ADR,
  the client guide, the synthesis and `CONTEXT.md`.

Coverage is best-effort. The PlantUML view is untracked by the graph and was
read directly.
