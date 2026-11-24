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
