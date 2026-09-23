# native-process-bound-effects-k71


## Goal

Find source-grounded native-binding leads for strict process-incarnation desktop
control on macOS, or document the bounded search's failure to find one. Deliver
`docs/research/native-process-bound-effects-a.md` for
`process-identity-protocol-k72`; identify a concrete discriminating experiment
for each credible lead rather than designing an implementable protocol by
assuming its platform lifetime properties.

## Context

- The human preserved client-event capture and strict original-process lifetime,
  declined the investigated direct AX candidate, then instructed us to proceed.
  This survey finds a lead; it is not permission to adopt that candidate, change
  application support or targeting semantics, or start k52.
- Read `docs/adr/desktop-capture-preserves-the-process-incarnation.md` and
  `docs/verification/ax-endpoint-adoption.md`. Follow their linked evidence for
  the exact rejected routes and limits. Timestamp identity, PSN plus boot alone,
  retained public AX objects and private object reconstruction are not new leads.
  A retained task right followed by a PID-based effect does not close the race.
- The fallback to beat is the declined direct AX transport: it authenticates
  a contemporaneous responder and has bounded death/reuse/exec successes, but
  receiver/descriptor and downstream lifetimes remain unestablished, and AX
  contact prevented the fixture's admitted-restoration schedule. Separate
  Koine policy attribution is also untested. Do not repeat those experiments.

## Questions for process-identity-protocol-k72

1. Which native API, kernel object or service protocol can bind an actual window
   effect and application activation to the captured process rather than a
   reusable PID, logical application serial or unowned window number? Trace
   acquisition, identity attribution, effect dispatch and downstream service
   targeting separately. An opaque identifier's name or width is not evidence
   of its non-reuse or lifetime.
2. Can a route cover restore, main selection, raise, activation and focus
   confirmation through process death, exec and automatic restoration without
   target injection/modification, a privileged helper or target cooperation?
   Does its scope cover arbitrary unmodified apps, or require a restriction?
   Inspect primary platform sources and independent desktop tools' actual
   targeting paths; distinguish their stated contract from observed behavior.
3. What can a public native client capture at interaction start, and what would
   Koine need to retain or receive to preserve that identity? Preserve actual
   right transfer, public client APIs, client-owned adapters, no runtime
   compilation and Koine ownership of Accessibility consent. Flag conflicts
   instead of silently adding client permissions or a private client dependency.
4. For each credible lead, what precise missing premise could one bounded native
   experiment or authoritative implementation inspection establish or falsify?
   Name the instrument, transition, positive and negative controls, effect
   witness and result that would change the adoption decision. Do not run it in
   this survey, and do not use a formal model to assume the platform premise.

## Done when

- The report compares source-grounded route families and prior tools, with
  primary citations for mechanism and failure-mode claims. Candidate search
  directions include service/connection-bound window and activation operations,
  target-bound application message delivery, and lifecycle coordination; these
  are questions, not claims that such APIs satisfy the contract. The report is
  not limited to those names if stronger evidence identifies another route.
- Keep a clear evidence distinction: documented guarantee, inspected
  implementation, existing bounded native observation, and unproved inference.
  Record source revision and OS scope where material; explicitly note where
  the search found no primary source. Include the required walk-away check per
  prior tool and concrete costs of private-version maintenance or extra consent.
- Recommend at most three credible leads with the discriminating evidence each
  needs, or state that none was found within the named search scope. Repeating
  an identity check, adding another encoding or reproducing ordinary direct-AX
  success does not qualify without a new premise addressing the recorded gap.
- State exactly what k72 can decide from the report and what it still cannot.
  A negative survey is not universal impossibility, product acceptance, a reason
  to start k52, or authority to weaken the agreed requirements.

## Notes

One solo survey is sufficient for finding a next concrete lead; no pair or
review is commissioned. Keep it source-based and finish the report in this
leaf. No task-tree growth or production/schema changes. Do not run native or GUI
experiments; a credible proposed experiment belongs to the subsequent design
disposition. The existing public GraphQL, native provider and isolated-VM seams
remain the boundaries. Do not edit ModalAnyware or other sibling repositories.

## Decisions (running log)

- **Evidence classes.** The report labels every mechanism claim as a documented
  guarantee (Apple headers/docs, POSIX), inspected implementation (open source at
  a pinned revision, independent tools' code), existing bounded native
  observation (this repository's VM reports), or unproved inference. Apple DTS
  forum statements and user reports are cited as such, never as documentation.
- **Reads and effects are separated.** A PID-addressed read can be attributed to
  the captured process when bracketed by a task right acquired before it and
  seen live after it (POSIX PID reuse rule plus XNU exec/death behaviour); an
  effect cannot, because the bracket only detects a wrong delivery afterwards.
  The survey therefore seeks binding for restore, main, raise and activation,
  and treats enumeration and focus confirmation as reads.
- **Arbitrary receiver/handler semantics has no native lead in scope.** Every
  unprivileged route found executes restore/main/raise in the target's own
  handler; the alternatives need Dock injection or other excluded privilege.
  The report hands this to k72 as a support-scope or semantics decision for the
  human rather than as an experiment.
- **Lead set.** Two binding leads and one capture lead, within the limit of
  three. Lead 1 anchors downstream work in WindowServer windows. Lead 2 finds
  the mechanism behind AX-contact automatic-termination inhibition. Leads 1 and
  2 are alternative closures of the logically keyed activation hazard. Lead 3
  covers capture and transfer only: a task-name right held before the event,
  sent over public XPC. The tools survey confirmed that only Dock injection
  (yabai's scripting addition) avoids the target's own handler for window
  ordering, so G1 stays with the human.
