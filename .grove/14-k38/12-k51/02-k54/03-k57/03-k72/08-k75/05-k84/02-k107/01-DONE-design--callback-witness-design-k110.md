# callback-witness-design-k110


## Goal

Specify an executable, independently witnessed sampling experiment with explicit
evidence limits before native execution. This child supplies the discriminator,
not a successful capture construction.



## Context

Extend the existing capture assessment and its architecture view. The serial
lookup fixture is a sample-then-acquire diagnostic; the automatic-termination
fixture establishes logical-application continuity only. Neither supplies a
callback witness. Use the existing native VM seam, not a new public test API.

## Done when

- Separate actual foreground selection, logical-app-to-PID mapping and getter
  call/return; specify the evidence required for each within continuous ownership.
- Define independent target/input observations and causal acknowledgments,
  including missing, reordered and stale-witness controls. Distinguish delayed
  callback entry from a pause inside the callback and from a deferred worker.
- Specify bounded native schedules for live/delayed/switched sampling and for
  death/exec/reuse/restoration/refusal, with honest pass/fail/inconclusive rules.
- Compare pre-held rights and one acquire-then-resample attempt, freeze rules,
  diagnostic permission scope and limitations. Preserve native execution in
  concrete live children and update the assessment, view and client-owner note.

## Decisions (running log)

- Split foreground selection F from logical-application-to-PID mapping M. A live
  right enclosing getter calls does not prove either observation is fresh or
  that the pair denotes one OS process. Record both evidence obligations; keep
  native implementation inspection and execution in callback-source-freshness-k111.
- Use independently logged target input/activation and acknowledged scheduling
  barriers as the experimental witness. They establish particular event orders,
  not uninterrupted global foreground state. Require primary implementation/API
  evidence for the actual sampling point; agreement between two getters is no
  substitute. No formal model can establish that missing platform premise.
- One bounded fresh-context review of the witness protocol found no material
  issue. Its scope was false success from stale/rebound values, the F/M split,
  causal order and unexecutable schedules. It supplies a prose review, not native
  evidence or a second execution witness. No findings required reconciliation.
