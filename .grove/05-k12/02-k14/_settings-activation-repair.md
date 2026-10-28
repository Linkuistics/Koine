# settings-activation-repair-k14 — brief


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

## Decisions (running log)

- 2026-10-28: Graph startup again refuses before project/generation discovery.
  Use bounded direct reads of AppDelegate, MenuBarController, trace recorder,
  scenario/helpers and capture wrapper; do not interrupt other graph users.
- 2026-10-28: Apple documents activation as discretionary and the former
  ignoringOtherApps flag as ignored under cooperative activation. The SDK also
  says activate(from:options:) expects the other application to yield first.
  Neither is a justified force-activation repair. Test the narrower ordering
  hypothesis with a separately frozen candidate that requests activation before
  ordering the window. Preserve the unchanged diagnostic bundle and sample.
- 2026-10-28: A new four-guest focused comparison is fixed at original/reversed/
  reversed/original order, four Settings actions per guest, stopping each guest
  at its first failure. This is causal exploration, not repair acceptance.
  Details and cap consequences are in settings-activation/ORDER-PLAN.md.

## Implementation plan

1. Freeze original and activation-before-window candidates separately. Retain
   exact source overlay, bundle inventories and consumed input hashes.
2. Run the declared four focused fresh-guest attempts with the existing scenario
   prefix and unchanged input/focus checks. Preserve failures before intervention.
3. Compare event order and native outcomes. If reversal also fails, reject that
   repair and restore ordinary source. If evidence supports a repair, validate
   ordinary operation without observation in a separately declared complete
   scenario sample. Do not substitute passing counts for a cause.
4. Update evidence and the brief chain. Decompose if causal discrimination and
   repair acceptance prove larger than this session; keep every unmet criterion.

## Ordering comparison handoff

K15 discharges the predeclared focused ABBA comparison without a causal repair.
A01 fails on its first Settings action; B02, B03 and A04 pass all four actions.
This neither disproves the ordering hypothesis nor establishes it as the cause.
The B intervention also moves synchronous trace writes; ordinary behavior has
not been qualified. The void activation call's normal return cannot distinguish
an AppKit request not submitted from a native request declined under system
context. That is the next precise causal question.

B03's final installed read times out despite returning matching inventory text;
its collection/audit exits are 1/1. A01's native failure snapshot and A01/A04's
final environment reads also time out. These are failed transports. All host
subject checks and available clean installed comparisons match; every clone
stops; final golden config/disk/NVRAM hashes match. No measured input changed
during the comparison. The final checks precede the deliberate restoration of
AppDelegate and addition of a no-VM check task. The saved B source and measured
Taskfile retain the exact experiment inputs.

The ordinary AppDelegate is restored byte-for-byte to the diagnostic baseline.
No product repair or complete ordinary-operation acceptance occurred. K14 and
k12 remain open against their original criteria; do not extend either completed
sample. The durable result is settings-activation/ORDER-RESULTS.md.

Settings-activation-native-path-k16 carries the remaining causal question and
every original repair/acceptance obligation. Note that the existing run.sh
enables tracing for both diagnostic and repair stages; its repair stage cannot
silently qualify ordinary behavior with diagnostics disabled.

## Native-path qualification handoff

K16 decomposes after k17's fixed two-guest native-log qualification. Both guests
pass all four Settings actions. Native records correlate the existing NSApp
call with WindowServer's successful front-process change and resume, followed
by active/key notifications. A token-check result of -50 and an inactive-window
ordering warning also occur in success; neither supplies a failed-activation
classifier. No failed native disposition is observed in this bound.

All recorded native startup/stop, final installed/environment and scenario
outcomes are clean; every subject/inventory and golden-image comparison matches
and both clones stop. The full debug streams add substantial load and retain
synchronous application tracing. This instrument has no symptom-preservation
qualification. K18 owns the remaining context discrimination, application repair
and ordinary-operation complete acceptance, including a reduced filter/trace
timing question under a new protocol. No completed sample may be extended.
NATIVE-RESULTS.md retains every outcome and unmet criterion. K14/k12 stay open.

## Reduced-context evidence and original-duty reconciliation

K19 retains the bounded context slice; details and every original criterion are
reconciled in docs/verification/settings-activation/CONTEXT-RESULTS.md. Offline
reduction retains all known native references. Two of three overall guests stop
on preflight defects before Koine launch; the final guest passes four Settings
actions with successful native client/front-change/resume records. Post-trace,
logger-stop, environment and installed transports time out. All failures,
corrective freezes, the first golden digest's four-second overlap and NOT RUN
phases remain explicit. All host/archived overlays and final golden digests match;
every clone stops. None of these controls establish a cause or application repair.

The original recorded callback/failed-activation classification remains met by
diagnostic-02. Responsible actual-path/context discrimination, product repair and
its useful focused seam, and separately declared frozen complete ordinary-operation
acceptance remain unmet. No external ownership is established; no upstream report,
release or notarization. K20 owns the precise missing callback/call and event-context
join without synchronous trace writes plus every original remaining criterion.
This node and its causal/repair ancestors remain open. No completed sample may
be reset, replaced or extended.

## Buffered event evidence and remaining causal work

K21 retains the new bounded memory instrument and the sole events guest in
settings-activation/EVENTS-RESULTS.md, including every original-duty comparison.
All four Settings actions pass with 101 zero-drop callback/call/event records
and enclosed actual client calls followed by native front changes/resumes.
No failed disposition or responsible cause is observed. Collection/native/audit
remain 1/1/1: post-trace parser failure and final endpoint/environment timeouts
are retained. The parser's exact fixture fails before a post-measurement literal
repair; no corrected guest runs. Frozen/archived inputs and completed golden
hashes match; clone stop is clean. Later full-scenario phases are NOT RUN.

K22 owns whether post-scenario native acquisition can retain actual-path records
without the live formatting/output sidecar, and every original positive causal
discrimination, product repair/failing seam and separately declared frozen
complete ordinary-acceptance duty. Diagnostic-02's classification remains met;
all other causal/repair criteria stay open. All samples are closed; no extension,
replacement, external ownership, release/notarization or upstream report.


## Deferred acquisition evidence and remaining actual-path work

K24 retains the sole deferred guest in
`docs/verification/settings-activation/DEFERRED-RESULTS.md`, including every
original-duty comparison. A clean preflight response is rejected because the
new parser requires a trailing newline removed by TestAnyware. Koine never
launches; every application assertion is NOT RUN. Scenario/inner Task are 1/201,
combined native/collection/audit 1/1/1, clone stop 0. Post-trace/environment/
installed reads time out; matching text remains failed transport. The bound is
closed with no corrected guest or replacement.

Post-observation archive acquisition/rendering/packaging is clean and retains
recent loginwindow Info calls, not Koine's actual activation path. Generic
native acquisition is demonstrated; actual-path retention, positive failed
request/disposition discrimination and symptom preservation remain unqualified.
Missing uuid text and native retention limits remain explicit. All original
frozen subjects, exact measured prefix/test overlays and completed golden digests
match; every collected artifact is retained and the clone is stopped. The exact
normalized fixture fails before the narrow parser correction; final focused
controls pass without replaying any guest.

K22 decomposes to completed evidence k24 and actual-path qualification k25.
K25 owns a separately named finite corrected capability protocol plus every
original causal repair/useful failing product seam and separately declared
frozen complete ordinary-operation acceptance duty. Diagnostic-02's historical
classification stays met; all causal/repair ancestors remain open. No closed
sample is extended, no generic native call becomes an app-path control and no
product repair/ordinary acceptance, external ownership, release/notarization or
upstream report is claimed.
