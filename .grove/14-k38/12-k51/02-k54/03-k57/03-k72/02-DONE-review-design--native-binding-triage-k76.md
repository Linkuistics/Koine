# native-binding-triage-k76

**Reviews:** native-binding-triage-k73

## Goal
Adversarially review the corrected native-binding triage and experiment handoff
against the unchanged strict-incarnation contract before native work consumes it.
## Context

Read the producer's committed artifact, current survey, adoption synthesis,
capture ADR and k72 brief. Review the task decomposition as well as the durable
evidence claims. The producer spent its in-session reviewer and corrected
substantive experiment conclusions; this is the fresh read of that boundary,
not another broad survey or a native experiment.

## Done when

- Inspect whether claimed observations can distinguish the stated property,
  including source sampling versus delivery, request admission versus actual
  downstream effect, and local ownership versus outstanding work.
- Check whether the selected partial investigation and remaining contract leaf
  preserve all original parent obligations, the declined-candidate decision and
  k52's position/evidence scope. Challenge any inferred approval or guarantee.
- Produce independent findings with evidence and consequence, or explicitly
  none. No fixes, probes, product adoption or weakened support contract here.
  If integration is needed, pass this review's handle rather than transcribing
  findings into its charter, and place it before the native investigation.

## Notes

The specific doubt is whether the corrected tests still credit a passing but
non-discriminating schedule as a lifetime guarantee, or merely move an unresolved
whole-path premise out of the next leaf's view. Grade against the original
requirements, not against agreement with the producer or its prior reviewer.

## Findings

Inspected commit `dd8d5e6` (the producer's) against the brief chain root→k72,
the capture ADR, the survey, the adoption synthesis, the adoption view, k74, k75
and k52. Survey paths below are `docs/research/native-process-bound-effects-a.md`
and synthesis paths are `docs/verification/ax-endpoint-adoption.md`. No native
program, test, build or GUI was run. The one external read was the raw XNU file
at its pinned commit, needed to check F7's citation.

The answer to the specific doubt is **yes, in part**. No text calls a passing
result a lifetime guarantee. But the corrected tests can still credit a schedule
that could not have discriminated (F1, F4). The selection also moves the gating
whole-path question, G1, and the inhibition dependency behind the native
experiment (F2, F3). Findings are ranked by severity.

### F1 — Stale-request refusals are credited without a same-state positive, and the named fixture makes this concrete (CONFIRMED)

- **Rule.** Survey L484–490 credits "bounded refusal of the stale requests
  submitted in those schedules" when every transition refuses "with the live
  positive passing". Synthesis L226 repeats it. Neither requires that each
  transition state also show an effect that the request can produce and the
  witness can observe.
- **Fixture.** The target named for every arm is `AutoTerm.m` (survey L461–462;
  k74 Context; `Taskfile.yml:44–51`). On every launch it calls
  `makeKeyAndOrderFront:` and `[NSApp activate]`
  (`docs/verification/process-serial-lifetime/AutoTerm.m:23–24`). At 20 s it
  closes its only window and hides (`:25–29`).
- **Restoration.** The preserved restoration command is
  `open -a /tmp/K65AutoTerm.app`, without `-g`
  (`docs/verification/ax-automatic-restoration/noax3-restored.json:2`). In
  `open(1)`, `-g` is "Do not bring the application to the foreground".
- **Confound (a).** The live positive can pass while the target is already
  frontmost from its own launch. It then shows no sensitivity.
- **Confound (b).** In the restored arm, the successor's own launch and `open`
  both make it frontmost. The falsifier "the successor becoming frontmost" after
  a stale-window request (L491–492) can therefore fire spuriously. If the request
  waits until the successor hides, the arm needs its own positive showing that a
  hidden, windowless successor can be activated at all.
- **Confound (c).** In the automatic-termination arm, the live original closed
  the captured window before termination. That arm tests an invalid window
  against a terminated PSN. It does not test a window that ended with its
  process, and survey L321–323 leaves that premise U.
- **Confound (d).** After an ordinary kill or an exec, retirement of the PSN
  explains a refusal just as well. PSN retirement is observed for quit and U for
  kill (L573–577). Only a same-state PSN-only request that is shown to act rules
  this out.
- **Confound (e).** A "refusal" is the absence of an effect, and no observation
  bound is stated. Relaunch of an automatically terminated app is asynchronous,
  and what triggers it is a recorded silence (L667–671).
- **Existing controls.** The survey's sensitivity arm runs only "after automatic
  termination" (L479–480). No document says what follows if that arm produces no
  effect. k74:29 ("Show live activation…") and k74:35 ("Compare PSN-only and
  retained-AppKit activation controls") state neither a non-frontmost
  precondition nor that credit for a stale arm depends on those controls.
- **Consequence.** This is the doubt that k76 was cut for. A schedule in which
  nothing could have changed the frontmost application can be recorded as
  "bounded refusal of stale requests across automatic restoration". It then
  reaches k75 as evidence for premise (b).

### F2 — The native experiment is selected on an inferred authorization, and the gating G1 question is deferred behind it (PLAUSIBLE; it turns on how the human's "proceed" is read)

- **The human's reopen predicate** requires "a specific lead addressing the
  missing receiver/descriptor, downstream-effect and
  admitted-restoration/lifecycle premises" (`03-k57/_process-identity-contract.md:85–87`).
  "Proceed" (`:93–96`) authorizes "finding a specific new native-binding lead" as
  "the next investigation step". The survey (k71) was that step.
- **The survey's own conclusion** is that G1 "has no native lead in scope, so it
  goes to the human" (L27–29). "Only two ways to close G1 … Both change semantics
  the human settled" (L351–354). k72 can decide "To take G1 to the human … It is
  not a native experiment" (L689–691). k72's brief says to hand the question back
  when no credible lead exists (`03-k72/_process-identity-protocol.md:51–53`).
- **What the triage did.** It selects window-qualified activation, which is one
  branch of G2, as "a diagnostic selection under the existing instruction to
  proceed" (`_process-identity-protocol.md:60–64`; synthesis L216–218). It defers
  surfacing the conflict to the human to k75, after k74 (synthesis L257–262;
  k74:55–57; k75:13–17). The capture ADR (L104–110) places the selection directly
  under the reopen predicate, so it reads as though the predicate were met.
- **Unstated dependency.** Any complete route that uses Lead 1 still needs
  restore, main and raise. Those run only in the target's AX handler (survey
  L9–12, L345–348). The only incarnation-bound route to that handler that was
  investigated is the declined direct endpoint. Public PID-addressed AX is
  excluded for effects (L102). A positive k74 therefore helps only if the
  declined route is reopened on a new G1 premise, or if the human changes the
  semantics. The synthesis says the selection "does not adopt the declined direct
  AX endpoint" (L221–222). That is true, but it omits this dependency.
- **Consequence.** The native investigation runs before the one human decision
  that settles whether native effort is useful and toward which lead. Its best
  outcome cannot produce a complete route under the agreed semantics. The human's
  answer could make k74 moot or redirect it (see F3).

### F3 — The ranking against Lead 2 contradicts the survey, and k74's automatic-termination arms bear on the product only under an unstated AX-contact condition (CONFIRMED inconsistency; consequence PLAUSIBLE)

- **The ranking.** Synthesis L232–234 says investigating inhibition first
  "leaves the activation destination and G1 unchanged".
- **The survey says otherwise.** Coordination lasting through admitted
  downstream work "could close the automatic-termination branch of the activation
  hazard in Lead 1, with no WindowServer premise" (L568–572). Leads 1 and 2 are
  "possible partial approaches to the activation downstream" (L578–579). Lead 2
  therefore bears on the same hazard, and the stated reason for preferring Lead 1
  does not hold as written.
- **When the hazard can arise.** Logical activation can only reach a successor
  under the same PSN, so the hazard needs automatic termination and restoration.
  An ordinary quit retires the PSN (L573–577).
- **What AX contact does.** One public `AXRole` read left the fixture
  TAL-ineligible after the reader exited (`ax-automatic-restoration.md:52`).
  Every route to restore, main and raise contacts the target's AX handler (F2).
- **So the AX-free arm has narrow product relevance.** The arm (synthesis
  L219–221; k74 Context) models the product path only before Koine's first AX
  contact with that incarnation, or after an inhibition release that nobody has
  found. Whether such a release exists is Lead 2's question.
- **Consequence.** An AX-free pass or failure can be credited to an activation
  hazard on a path that necessarily contacts AX. The lead best placed to say
  whether that hazard arises was ranked lower because of a misstatement. k75 is
  told to "reassess" the alternatives (k75:18–20), not that k74's relevance
  depends on how long the inhibition lasts.

### F4 — The implementation-evidence alternative for in-flight binding is scoped to WindowServer, but the step that produces a successor is not known to be there (CONFIRMED scope; consequence PLAUSIBLE)

- **The scope.** Survey L337–339 says Lead 1 "could close it only with evidence
  for validation through the actual effect inside WindowServer".
- **The unknown.** Activation reaches both `SLSSetFrontProcessWithInfo` and
  `_LSRequestProcessBecomeFrontmost` (L300–302). Which component relaunches an
  automatically terminated application is a recorded silence (L667–671).
- **The open acceptance.** k74:37–41 and synthesis L243–244 accept
  "authoritative implementation evidence" without saying what it must cover.
- **Consequence.** An argument that WindowServer checks the window at admission
  could be credited as closing in-flight binding. The relaunch path, whether
  Launch Services, the TAL agent or something else, would remain unexamined. That
  credits request admission as the downstream effect.

### F5 — The corrected capture witness excludes the first client's agreed capture method, and nothing records the conflict (CONFIRMED)

- **The new rule.** k73 added "do not substitute a callback-time foreground
  query for the original event target" (survey L634–639).
- **The client's agreed method.** ModalAnyware's agreed interaction context
  (`../ModalAnyware/docs/specs/configuration-ui.md:238–243`) records "the
  frontmost application's identity" at leader key-down, obtained "from native
  AppKit state". That is a foreground read at callback time. The survey cites it
  (L358–360).
- **The gap.** The synthesis, k75 and k52's "Clients" list do not name the change
  this implies for ModalAnyware's capture source, as distinct from its identity
  field. Koine sessions do not edit ModalAnyware; changes reach its owner as a
  note (k38 brief).
- **Consequence.** The contract may come to require event-target attribution
  that the first client's agreed spec does not provide, and this would surface
  only at handoff. Whether "frontmost at key-down" already means the event's
  target is for the human to confirm, not for the triage to assume.

### F6 — `K65Transitions --exec-run` is named as Lead 1's exec transition, but it is the AX admission and effect holder (CONFIRMED)

- **Where it is named.** Survey L473 and k74:14–15.
- **What it does.** In `docs/verification/retained-ax-binding/transition-probe.m`,
  `--exec-run` forks a child running `--exec-target` and calls `transition()` on
  it (`main`, L350–356). Before the exec, `transition()` (L264ff) looks up
  `com.apple.axserver`, runs admission, reads `AXWindows` and writes
  `AXMinimized`.
- **Consequence.** Used as named, the exec arm makes AX contact with its target,
  contrary to "never touches AX" (L452–453). It re-measures the declined
  endpoint's exec behaviour instead of the window-qualified request. Its target
  is a forked child, not a Launch Services launch, so its PSN and window state
  differ from the fixture's. k74's instruction to "read their Taskfile entries and
  frozen evidence before use" reduces the risk but does not correct the claim.

### F7 — The triage's XNU citation "correction" introduced an error (CONFIRMED)

- **The source.** At pinned commit `f6217f8`, `osfmk/kern/ipc_tt.c` (fetched raw;
  SHA-256 `8ea0a7dafcb941ef5da4a99016bf9a0c8fe36b51ec9888c3bb9cf123bd4b3e44`)
  has `ipc_task_init`'s comment starting at line 161. Its definition is at lines
  172–173 and its closing brace at line 293.
- **The error.** The new link cites L161–L274 (`docs/verification/direct-ax-endpoint.md:640`;
  survey L715–719). That range stops inside the exception-port inheritance loop.
  It omits the copies of the host, bootstrap and task-access send rights
  (280–289), which are the part relevant to "ordinary receive-right inheritance".
- **The contradiction.** The survey's Q2 link (L322) still cites L172–L293, which
  was correct. The document now gives two ranges for one function.
- **Consequence.** A durable evidence citation is wrong at its pinned commit, and
  the survey records as a correction a change that was not one.

### Checked without a finding

- **k52.** Its position and evidence-renewal table are unchanged; the diff
  touches one paragraph.
- **The declined candidate.** The spec, ADR, synthesis and view restate the
  declined-candidate decision consistently.
- **k75's obligations.** k75 carries every k54, k57 and k72 Done-when obligation
  by reference, and restates the load-bearing ones. That includes the k52
  handoff, which keeps actual and simulated PID reuse distinct.
- **Corrections that hold.** The read-attribution correction (the sampling point
  must fall inside the bracket) is sound. So is Lead 2's distinction between
  local ownership and outstanding work. The in-flight distinction appears in the
  survey, the synthesis and k74.
