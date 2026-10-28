# settings-activation-repair-k14


## Goal

Find why the delivered Settings activation request in the recorded failure does
not produce an active, key window. Repair the application if the cause belongs
to this repository and verify it through the parent's agreed seams.

## Context

Read `docs/verification/settings-activation/README.md`, its frozen diagnostic
source overlay, and `diagnostic-02/trace.jsonl`. Observation/evidence k13 is the
preceding child. The parent brief retains Antony's complete repair criteria.

Diagnostic 02 reproduces Settings reopen 3 with observation enabled. In PID 706,
selection 4 records callback entry, show entry, window-show and activation calls.
Settings becomes visible; the app remains inactive with no key window and no
subsequent recorded become-active/key notification. Prior selections in that
same process record both notifications. This classifies failed activation in
the observed interval; it does not establish the application/platform cause.
The callback runs in default run-loop mode after menu.didClose. Do not infer a
still-tracking callback or a demonstrated menu-close deferral repair.

The original and subsequent screenshots and agent windows agree TextEdit is in
front of inactive Koine before intervention. The independent native observer
returns agreeing complete JSON but reports timeout and exit -1; it is not a
successful native read. Notification delivery is observational, not an atomic
WindowServer history, and there is no periodic heartbeat after the last row.

Diagnostic 01 completes every assertion. Its separate final inventory read
times out despite returning matching text; collection/audit exits are 1/1.
Diagnostic 02 scenario/Task exits are 1/201, collection/audit/stop 0/0/0; resize
and all subsequent scenario assertions are NOT RUN. Frozen subject hashes,
full host bundle inventories and golden config/disk/NVRAM hashes match. Both
guests stopped. Five capture, eight pointer and nine resize controls pass.

The diagnostic sample's first-classified-failure stop has been met at 02.
**Do not run diagnostic 03 or reset/extend that sample.** Further causal
experiments need an explicit new bounded protocol suited to their hypotheses,
with changed subjects and unsuccessful outcomes retained. No released-bundle
rate, regression or external ownership follows from these measurements.

Current source retains opt-in diagnostics, disabled in ordinary operation.
The signed diagnostic bundle remains locally at
`.build/settings-activation/diagnostic/Koine.app`; the durable report preserves
its inventory and source overlay, not an archived bundle. It is a signed,
unnotarized current-source candidate labelled 0.4.0, not the released bundle.
Do not modify it to test a repair; build a separately identified candidate.

## Done when

- Use the recorded failure to discriminate the application's native activation
  path. Verify version-dependent AppKit decisions against official source and
  cite non-obvious calls. No activation workaround is selected by k13.
- Preserve the recorded callback/native classification and all original failed
  evidence. Where another instrument is necessary, state what it can change
  and validate it through a bounded, matched experiment before relying on it.
- If the cause belongs here, repair application behavior rather than adding a
  test-driver wait or retry. Demonstrate a focused failing check at a useful
  existing seam before repair where feasible. Keep the original user behavior:
  one Settings menu selection returns its one window in front and focused.
- Before the first repair acceptance run, declare a finite fresh-guest set
  through `task app:vm-verify-menu-bar`, freeze the actual final subject and
  all consumed inputs, and retain every attempt, failure and NOT RUN phase.
  Validate the final ordinary application behavior, addressing the diagnostic
  timing limitation explicitly. No reliability claim beyond the declared set.
- If the cause is external, retain the reproducer and classification and leave
  the repair outcome explicitly unresolved. No upstream report without Antony's
  approval. Do not call a new all-green sample a cause or repair by itself.
- Update verification documents and root handoff; check every original k12
  criterion before closing that node. No release or notarization is required.

## Notes

The graph CLI previously refused list_projects because a pre-coordination or
unverified generation was active. No project or generation was established and
no graph completeness claim was made. Bounded direct reads covered
AppDelegate.showSettingsWindow, its launch/reopen/menu callers,
MenuBarController, and the existing scenario/helpers. Try the graph normally
at session start; do not stop other sessions to acquire it.
