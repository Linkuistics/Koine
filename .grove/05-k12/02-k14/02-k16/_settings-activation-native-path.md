# settings-activation-native-path-k16 — brief


## Goal

Find the application/native condition that prevents the delivered Settings
activation request from producing an active, key window, then repair it where
this repository owns the cause and qualify ordinary operation.

## Context

Read the parent k14 brief and docs/verification/settings-activation/ORDER-RESULTS.md,
alongside the original README and diagnostic-02 trace. K15 completed its fixed
four-guest focused comparison: A01 original order failed at initial Settings;
B02/B03 reversed order and A04 original order passed all four actions. Both
orders can succeed. This does not establish reversal as a cause or sufficient
repair. Synchronous trace writes move with the experimental call blocks, so
the diagnostic timing limitation remains. Ordinary AppDelegate is restored
byte-for-byte. No product repair or complete ordinary-operation acceptance ran.

The present observation boundary shows a normal return from void NSApp.activate
and subsequent native notifications, not whether AppKit submitted a request or
the native activation system accepted/declined it. That missing distinction,
or an observed user-event/activation-context condition that discriminates it,
is the precise next causal question. Qualify what a native log or other public
instrument actually reports before relying on it; a plausible missing log is
not proof of no request. Do not assume that a request from a different API has
the same native path as the existing NSApp call.

K15's A01 native failure snapshot reports timeout/-1 despite agreeing text;
A01/A04 final environment reads also time out. B03's final installed-inventory
read times out despite matching returned text, retaining collection/audit 1/1.
Every available clean installed endpoint matches; host input/inventory and
golden config/disk/NVRAM audits pass; every guest stops. Raw outcomes remain in
the evidence directories. No timeout becomes a successful native read.

The original diagnostic sample stops at 02; do not run diagnostic 03. The ABBA
comparison stops at four; do not reset or extend it. A new hypothesis needs a
new bounded protocol, candidate identity and frozen actual inputs before its
first guest. Existing bundles remain locally under .build/settings-activation;
do not overwrite the diagnostic or order-a/order-b subjects. Saved overlays and
inventories, not archived bundles, are the durable evidence.

## Done when

- Discriminate the responsible activation path or condition with qualified
  causal evidence. Use official AppKit sources for version-dependent decisions;
  cite non-obvious calls at their decision sites. Neither a menu-tracking
  callback nor a menu-close deferral repair follows from existing traces.
- Preserve each original failure/classification. Any further instrument must
  state its timing effects and be qualified in a predeclared bounded matched
  experiment. Retain every started attempt, unsuccessful outcome and NOT RUN.
- If the cause is here, repair application behavior. A driver wait/retry or a
  repeated activation/input action is no demonstrated repair. Use a focused
  failing seam where feasible before changing the product. One Settings
  selection must return its one window in front and focused.
- Declare a separate finite complete-scenario acceptance set before its first
  fresh guest through task app:vm-verify-menu-bar. Freeze the final ordinary
  subject and all consumed inputs; validate with diagnostics disabled, preserve
  every outcome and address the timing limitation explicitly. The existing
  run.sh exports KOINE_SETTINGS_TRACE=1 for every stage, including repair, so it
  must not silently serve as instrument-free ordinary-operation acceptance.
- If the cause is external, preserve the reproducer and evidence and leave the
  repair outcome explicitly unresolved. No external attribution from absence
  of notifications or successful alternative calls alone; no upstream report
  without Antony's approval.
- Reconcile every original k14/k12 criterion, verification documents and root
  handoff before closing those nodes. No release or notarization required.

## Notes

Graph startup at k15 again refused before establishing a project/generation.
Bounded direct source reads covered AppDelegate, MenuBarController,
SettingsActivationTrace and the existing scenario/helpers/capture wrapper.
Try the graph normally; do not stop other sessions to acquire it. The new
check:vm-settings-order Task passes script syntax/lint and the five existing
capture controls; eight pointer and nine resize controls also pass. Those are
helper checks, not evidence that a native activation repair exists.

## Decisions (running log)

- 2026-10-28: Graph startup refuses list_projects before project/generation
  discovery. Use bounded direct reads; do not interrupt other graph users.
- 2026-10-28: Qualify a separate native unified-log sidecar against the unchanged
  signed diagnostic candidate. Fix two fresh guests, four existing Settings
  actions per guest, stopping each at its first failure. Match native request
  records to successful and unsuccessful selections within the same application
  path; absence of a log is not absence of a request. No product change or
  alternative activation API is selected. Save protocol and actual frozen inputs
  before the first guest. The sidecar adds system load and retains the existing
  synchronous diagnostic timing limitation.
- 2026-10-28: The sole pre-guest reviewer found discarded startup transports
  and acceptance of premature logger completion. Both are actionable and are
  repaired with raw single-exec startup, validated stop envelopes and a guest
  stop helper that rejects prior completion. Six native controls and the five
  existing capture controls pass. An always-successful stop mutant fails all
  three stop controls. No product change is made.
- 2026-10-28: Native 01 passes all four Settings actions. Scenario, Task,
  collection, native collection, host/installed audit and clone stop all exit
  zero. Its native records correlate the actual NSApp interval to a client
  SLSSetFrontProcessWithInfo call, a WindowServer front-process change and native
  resume, followed by active/key notifications. A token result of -50 also
  appears in this successful path and cannot alone diagnose failed activation.
  This supplies successful controls, not the missing failure disposition.
- 2026-10-28: Native 02 also passes all four Settings actions. Every scenario,
  Task, collection, native collection, host/installed audit and stop exit is zero;
  final environment reads are clean in both guests. The fixed two-guest sample
  is discharged without a failure. Native logs supply positive actual-path
  controls, with no failed disposition, cause, product repair or ordinary
  acceptance. Preserve all original unmet criteria. Decompose into completed
  native evidence and the remaining activation-context repair work; qualify a
  reduced native filter and operation without synchronous trace before relying
  on any new bounded measurement. Do not extend any completed sample.
- 2026-10-28: Final subject checks match all 258 frozen entries; both complete
  endpoint inventories and the golden config/disk/NVRAM comparison match. Raw
  native gzip archives restore to the original digests and original collection
  files compare byte-for-byte. A post-measurement test-only strengthening checks
  child readiness and completion before cleanup; six native/five capture checks
  pass again, and the premature-stop mutant fails all three stop controls.

## Implementation plan

1. Add a separately named native-log wrapper/prefix and guest sidecar under
   docs/verification/settings-activation, keeping the existing input and focus
   checks. Reuse full bundle audits, failure capture and cleanup. Add Taskfile
   entries and focused checks; freeze unchanged bundle, scripts and golden image.
2. Run native 01 and 02 once each. Retain every outcome, raw log/transport status,
   trace, screenshot and NOT RUN assertion. Qualify what native records actually
   identify using successful controls before interpreting a failed selection.
3. If the native evidence discriminates a repair, demonstrate its failing seam
   and declare a separate ordinary-operation complete acceptance sample. If the
   native instrument cannot discriminate the cause in its bound, preserve that
   result and decompose the precise remaining question rather than extend it.
4. Reconcile the brief chain, durable evidence and all unmet repair criteria;
   retire only the completed slice and commit through jj.

## Native qualification handoff

K17 delivers the fixed two-guest native-log experiment, capture controls and
positive actual-path reference. Both guests pass all four Settings actions;
all recorded scenario, collection, audit and cleanup outcomes are clean. The
client activation call correlates to WindowServer's front change and native
resume, followed by active/key notifications. No failed native disposition was
observed. The broad debug stream adds substantial logging load while the
synchronous application trace remains enabled, leaving symptom preservation
under this instrument unestablished. A token-check error and inactive-window
warning also occur in success and cannot alone classify the failure.

K18 owns the remaining native activation-context discrimination and every
original repair/ordinary-operation acceptance obligation. Qualify a reduced
native filter against the saved wide streams and address synchronous trace
timing under a new bounded protocol. The native sample is complete and must not
be extended. K16, k14 and k12 stay open. Durable evidence and original-duty
comparison are in settings-activation/NATIVE-RESULTS.md.

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


## Persisted Debug failure and remaining clock/disposition work

K28 retains the sole new persisted guest in
`docs/verification/settings-activation/PERSISTED-RESULTS.md`, including every
original-duty comparison. Initial Settings passes; reopen 1 fails. The 49-row
zero-drop buffer, clean independent native snapshot, agent windows and screenshot
agree on a delivered callback followed by inactive Koine behind active TextEdit.
The changed instrument preserves this symptom; no timing neutrality follows.
Persisted Debug retains successful Koine front/result/resume and failed-selection-
adjacent client/token records. Shared -50/token fields and post-call remote-menu
teardown occur in both outcomes and establish no cause or external owner.

Strict wall-clock joins match neither selection: native client timestamps are
0.399/0.554 ms after buffered after-times. Raw tick/uptime numerical fit is only
provisional. Keep the original failed join, archive clock bytes and all raw
records. K29 first qualifies the existing cross-clock relation offline, then
owns every positive failed-disposition/responsible-context, justified product
repair/useful failing seam and separately predeclared frozen complete ordinary-
acceptance duty. No missing record becomes proof and no unchanged sample is
repeated to chase failure. K27 and all causal/repair ancestors remain open.

Scenario/inner Task are 1/201, native/collection/audit 1/1/1 and outer Task 201.
Post-trace timeout/-1 remains failed despite its marker. Other new raw transports,
failure snapshot, both installed endpoints and final environment are clean.
All 316 frozen inputs, endpoint inventories and completed golden hashes match;
97 artifact checks pass and the correct clone stops. Reopens 2/3 and every later
complete-scenario phase are NOT RUN. Every completed sample stays closed. No
product repair, ordinary acceptance, release/notarization or upstream report.
