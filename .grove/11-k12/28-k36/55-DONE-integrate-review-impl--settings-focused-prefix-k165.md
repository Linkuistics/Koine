# settings-focused-prefix-k165

**Integrates:** settings-focused-prefix-k163

## Goal

Triage the findings from the k163 review commit. Apply the work that meets the
acceptance and material-risk threshold before k164 or k57 consumes the shared
scenario.

## Context

Read the review's own commit, including
`docs/verification/settings-activation/ORDERING-PREFIX-REVIEW.md`, against the
k62 producer, the current scenario and the ordering protocol. The archived
contracts and the k36 brief remain binding. The review is findings only.

## Done when

- Check and classify each finding against its source and the agreed contract.
- Apply accepted bounded repairs with meaningful controls and reusable
  Taskfile checks. Reconcile the duty comparison and the handoff to
  k164 and k57 with the actual result.
- Preserve successful input, read counts, waits and bounds, private original
  evidence and all runtime holds. Re-extract and check the prefix if its
  leading scenario bytes change. Decide whether changed work earns review.

## Notes

No VM, clone, signed subject or runtime slot. No finding is a chartered repair
before triage. k164 remains the existing controls owner. k57 retains the
complete pre-runtime reconciliation, and k54 retains freeze and runtime.

## Decisions (running log)

- 2026-11-23: P2-1 of k163 is a real issue. The protocol at
  `ORDERING-EVALUATION-PLAN.md` lines 187–193 requires an observer read, a
  window read and a screenshot after any failed assertion. `settings_fail`,
  `settings_fail_as` outside a return and `settings_expect_front` take only the
  screenshot. Repair them in the scenario library before the state-failed
  receipt. That receipt latches the root, and the latch refuses the System
  Events observer (`vm_exec_reads.py`, `sysevents_read`, evidence flag false).
- 2026-11-23: `settings_expect_front` mirrors the k162 return order. A clean
  false front or title takes the observations under its own operation before
  any stop. An unavailable audit beside a true front stays a stop without them.
- 2026-11-23: Before the System Events automation check passes, the observer
  read is NOT RUN. It cannot succeed there, and its Apple event can raise the
  consent prompt, which changes the guest after a failure. The window read and
  the screenshot still run. Accept this as a visible trade-off.
- 2026-11-23: A poll that a facade exhausts records its state-failed receipt
  itself, so the root latches before the scenario can observe. The endpoint,
  System Events, element, Allow, TextEdit and non-deferred count polls share
  that class. The review did not name it. Its repair needs a deferred mode in
  four reviewed facade families, as k67 gave the return count poll. That is too
  large for this integration, so cut a precise impl leaf before k164.
- 2026-11-23: The library-owned exhaustions belong to the same class and need
  no facade change. The count poll uses the existing deferred mode, and the
  reveal records its own receipt. Repair both here. The cut leaf
  `settings-exhausted-poll-observations-k166` keeps the four facade polls.
- 2026-11-23: Seven controls failed against the source before the repair, and
  two observer-gate mutations were detected. The records are in
  `ordering-prefix-integration-evidence/`.
- 2026-11-23: The k165 change earns no separate review. It applies the
  reviewed k67 and k162 pattern to more failure paths, and controls hold each
  path. If k166 earns a review of its facade change, that review includes the
  k165 library change, because both deliver one duty.
- 2026-11-23: The recorded final run of the nineteen Taskfile checks exits 0,
  with 331 passing tests and no failure. It matches the working run item by
  item, and none of the 4,552 subjects changed. The documentation check keeps
  only the two existing k23 failures. No VM, clone or runtime slot ran.
