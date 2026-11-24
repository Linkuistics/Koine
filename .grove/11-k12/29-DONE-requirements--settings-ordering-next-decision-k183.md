# settings-ordering-next-decision-k183

## Goal

Get Antony's explicit decision on the next step for the Settings repair. The k54
ordering evaluation stopped at E01 with unavailable required evidence. The
protocol gives that run no replacement, so any further runtime needs a new scope
decision.

## Context

Read `docs/verification/settings-activation/ORDERING-QUALIFICATION-RESULTS.md`
first. It holds the freeze, the E01 record, the three outcome classes and the
duty classification. The evaluation contract is
`docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.

The facts that the decision rests on:

- E01 passed first launch and the TextEdit preparation. Two clean reads named
  TextEdit as the front process.
- The scenario then closed the Koine Settings window. About 750 ms later, the
  positive setup read the front process through System Events. The guest
  returned `Can’t get {"loginwindow", 167} whose frontmost = true. (-1728)`.
- The strict grammar accepts -1728 only as a missing element. Thus the read was
  unavailable, and the sequence stopped. About 100 ms later, the failure
  screenshot showed TextEdit in front.
- No Koine failure and no Tart crash occurred. E02, A01, A02 and A03 are NOT RUN.
  The exact stop, every input audit and the closing golden audit passed.
- The first-launch screenshot shows a Finder `Utilities` window in front of the
  Settings window. The plan says that the golden holds no restored application
  or session state. No structured check covers that Finder window.

## Done when

- Antony chooses the next step, and the choice is in this task's decision log.
  Put the trade-off, a recommendation and its evidence to him first.
- These options are known. The session may find others.
  - Amend the setup read of the front process, with independent review before
    any guest. One way is a clean bounded poll. Another way is a source without
    the gap. The protocol now excludes added waits, so a poll is a scope change.
  - Classify this exact -1728 reply as a clean "no front process" state. That
    choice alone turns the stop into failed setup, so it does not make the
    setup available.
  - Keep the repair unresolved, with this harness limit as its recorded state.
- If Antony admits a new evaluation, cut its producer, review and integration
  leaves at precise boundaries. A new run needs a new declared sequence, a new
  freeze and new slot identities. The closed k54 sequence stays closed.
- If the decision touches the golden image, settle the Finder window question
  in the same decision.

## Notes

The 37 duty-ledger rows that k54 owned now name this leaf. Each row keeps its
original text, and the results record classifies each one. A decision here
grants no release, notarisation or upstream report. Native cause and ownership
stay with k12.

## Decisions (running log)

- 2026-11-24: This session adopted the mandated leaf on the empty jj change
  `ktnonxtt`, with parent `56bd78e0`. It read the glossary, the brief chain, the
  keepalive ADR, the results record and the evaluation plan.
- 2026-11-24, observation: the setup read is
  `get {name, unix id} of first process whose frontmost is true` through System
  Events. The E01 reply has no `System Events got an error:` prefix, and it names
  `{"loginwindow", 167}`. The recorded reason is "AppleScript error -1728 does not
  report a missing element". The front read admits no absence either, because it
  is not a poll.
- 2026-11-24, observation from the private attempts: attempt 000074 read the
  agent window list 0.06 s after the close ended. The list shows the TextEdit
  `Untitled` window first, with `focused: true`. Attempt 000081 came 0.66 s after
  the close ended, and the failure capture followed 0.1 s later.
- 2026-11-24, observation: the agent sets `focused` only on the main window of
  the Accessibility focused application. The setup already holds that list. The
  agent closes a window with an Accessibility press of its close button, and it
  requests no activation. Koine has no close handler that changes activation.
- 2026-11-24, observation: the one-shot results record two more availability
  races that the protocol accepts. A TextEdit quit reply can come before the
  exit, and the single absence read then fails the setup. A lost restart reply
  makes a complete slot unavailable. E01 reached neither step.
- 2026-11-24, observation: `main` keeps the released call order,
  `makeKeyAndOrderFront` before `NSApp.activate()`. Only this branch holds the
  candidate order, and no Settings selection has run it on a guest. The branch
  holds 192 commits that are not on `main`.
- 2026-11-24, open: Antony decides first whether this grove runs a new
  evaluation or closes the repair as unresolved. The recommendation is to close
  it as unresolved. The derived questions wait for that answer.
- 2026-11-24, Antony: "I accept, as long as we come back to this via a later
  issue." The Settings repair closes as unresolved, and the E01 harness limit is
  its recorded state. A later GitHub issue brings the work back, so the issue is
  a condition of this decision. No new evaluation runs in this grove.
- 2026-11-24, open: the next question is whether this branch keeps the
  candidate call order or returns to the released order. The issue text follows
  that answer.
- 2026-11-24, Antony: "you decide." This session decides that the branch returns
  to the released call order. The spec requires complete ordinary acceptance for
  the candidate, and the candidate has none. The candidate also changes first
  launch, the Finder reopen and the status-line links. The k52 commit `561dbf6c`
  keeps the candidate for the later issue. The dormant diagnostics stay.
- 2026-11-24, open: the shared understanding and the issue text go to Antony for
  one confirmation. The tree and the issue wait for it.
- 2026-11-25, Antony: "yes." His answer settles the shared understanding and the
  issue text. The release check keeps the strict front read after the merge, and the
  issue owns its change. The 37 duty rows move to k12, with a note that names the
  issue. No ADR is due, because a later issue can reverse both decisions.
- 2026-11-25: [Issue #15](https://github.com/Linkuistics/Koine/issues/15) holds
  the agreed text, with the label `bug`. The stored body matches the draft apart
  from one final newline.
- 2026-11-25, placement: `settings-released-call-order-k184` is a flat `impl`
  sibling after this leaf. It shares the k12 scope, and the code change, the
  build and the tests need their own session. It returns released code, so it
  earns no review leaf. It also owns the two stale status summaries. The index
  needs a full conversion first, and the changed diagram needs a rendering check.
- 2026-11-25: the spec, the results record, the k12 brief and the 37 ledger rows
  state the decision. `task check:settings-duty-ledger` passes with 37 owned rows
  and 0 findings. `task check:docs` exits 201 with only the two archived targets
  that k23 owns. The decision touches no golden image, so the Finder window
  question goes to issue #15.
