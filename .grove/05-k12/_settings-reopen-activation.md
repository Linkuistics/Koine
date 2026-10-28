# settings-reopen-activation-k12 — brief


## Goal

<!-- tc: depart synonym-rotation because "fix" is the human's quoted words -->

Find why the Settings window sometimes reopens behind TextEdit after a menu-bar
selection. Repair it where the cause is in this repository. Antony asked
for this on 2026-10-28, at the finish proposal: "I want you to fix the
settings-reopening failure".

## Context

- The bounded comparison in k4 reproduced the symptom with both released
  bundles. Attempts 01 and 03 failed at Settings reopen 1, and attempt 04
  failed at reopen 3. K3 also reproduced reopen 3 behind TextEdit. No rate or
  regression is established.
- `docs/verification/menu-bar-samples/README.md` and
  `docs/verification/menu-bar-vm.md` name the missing observation. It is a
  time-correlated record across one Settings selection: callback entry,
  window-show and activation calls, and native active and key-window changes.
  The post-failure captures cannot distinguish a missing callback, a failed
  activation and an activation that is lost later.
- `task app:vm-verify-menu-bar` is the end-to-end seam, with focused no-VM
  controls at the helper boundary. These checks are agreed in the root brief.
- K8 found no activation change, focus polling bound or external cause.

## Done when

- Add the missing time-correlated instrument before any repair. It must record
  one Settings selection without keyboard, focus or repeated-action
  intervention. Show that it does not hide the symptom, for example by a
  reproduced failure while it records.
- Classify at least one reproduced failure as a missing callback, a failed
  activation or a lost activation, from the recorded order of events.
- If the cause is in this repository, repair the application, not the test
  driver. A test-only wait or retry does not count as the repair. Add a focused
  check at the existing seam where one can show the repaired logic.
- Check the repair over a bounded set of fresh-guest complete scenarios. Declare
  the set before the first run, record every attempt, and make no claim beyond
  that sample.
- If the cause is outside this repository, retain the reproducer and the
  classification. Leave the outcome explicitly unresolved, and do not report it
  upstream without the human's approval.
- Update the verification documents and the root brief handoff. No release is
  produced.

## Notes

The instrument can change the timing. If the symptom then does not appear in a
declared bound, record that result as a finding. Do not expand the bound to
chase a failure. Decompose instead.

## Decisions (running log)

- 2026-10-28: Graph CLI cannot start because a pre-coordination/unverified
  generation is active. Use bounded source reads; do not stop other sessions.
- 2026-10-28: Instrument the unchanged show/activate order, menu callback and
  menu lifecycle, application active/key/main-window notifications and workspace
  activation. Opt in only in disposable guests. Do not add activation, input,
  waits or retries to the diagnostic path. Synchronous diagnostic writes can
  affect timing; require a recorded failure before selecting a repair.
- 2026-10-28: Diagnostic bound is three fresh macOS 27 guests using the signed
  instrumented current source, each running the existing complete menu scenario
  once, ending at its first failure. Retain every attempt, failure and NOT RUN
  phase. Stop early only once a failure has the required classification. If no
  failure is classified at the cap, decompose rather than extend it.
- 2026-10-28: The sole in-session reviewer found three actionable capture gaps:
  early failures missed installed-after inventory; listed-file hashes missed
  additions/link changes; interruption skipped collection. All were repaired
  before the first diagnostic guest. Five focused controls exercise those paths;
  they failed before repair and pass with the final wrapper. A fixture initially
  emitted invalid JSON for the changed installed endpoint; that fixture was
  corrected and all five controls passed while guest 01 was starting. The
  measured wrapper/source/bundle stayed frozen throughout the run.
- 2026-10-28: Diagnostic 01 completed every assertion, including the four
  TextEdit Settings selections, minimum-size scrolling and login restart. The
  240-row trace has contiguous per-process sequence numbers and records all
  registered notification classes. This is no reproduced failure and no
  qualification that the instrument preserves the symptom. Scenario/Task exits
  are 0/0. Collection/audit exits are 1/1 because the final installed inventory
  exec reports timeout and exit -1 despite returning matching inventory text;
  preserve that failed transport, do not retry or call it a successful native
  read. Host hashes and full host bundle inventory match; clone stop exits 0.

## Decomposition and handoff

K13 delivers the opt-in observation/capture seam, a complete diagnostic pass
and an observed failed activation at reopen 3. The failure preserves the
symptom under observation and meets the diagnostic sample's early stop at 02;
03 must not run. It distinguishes a delivered but unsuccessful activation
request from a missing callback or an observed activation subsequently lost.
The native observer's timeout, absent post-row heartbeat and notification
delivery limits remain explicit in the durable record.

The application/native cause and product repair do not fit in that observation
slice. Settings-activation-repair-k14 owns them, including any further bounded
causal experiment and the final bounded complete-scenario repair acceptance.
Read docs/verification/settings-activation/README.md and raw evidence; do not
replace the failed original sample or treat the complete pass as repair. K12
remains open against every original criterion.

## Implementation plan

1. Add opt-in JSON-lines observation to the existing AppKit callback and
   show/activation boundaries; record native transitions without input.
2. Build/sign the diagnostic bundle through `task app`, freeze source and bundle
   inventories, then run the declared diagnostic sample through the existing
   `app:vm-verify-menu-bar` seam. Save native failure capture before intervention.
3. Classify the recorded failure and test one causal hypothesis. If a repair
   follows, first capture its failing focused check, then change the application.
4. Declare and freeze a bounded fresh-guest complete-scenario repair sample;
   retain all outcomes. Update durable verification and the root handoff.

## Ordering experiment handoff

K14 decomposes after k15's completed four-guest original/reversed/reversed/
original comparison. Original A01 fails at its first Settings action; B02,
B03 and original A04 pass all four actions. Reversal is not disproved and is
not established as the cause or a repair. The original application call order
is restored after the final audit. The remaining question is whether AppKit
submits the request and the native service declines it, or submission is
suppressed before that boundary. A void call's normal return and missing native
notifications cannot tell those apart.

Every host audit and golden hash check matches; every guest stops. B03's final
installed read times out with matching returned text, so collection/audit are
1/1. A01's native snapshot and A01/A04 final environment reads also time out.
No timeout is promoted to a successful read. Resize and every later complete
scenario phase are NOT RUN in all four focused attempts. The result is in
settings-activation/ORDER-RESULTS.md. All original k12 criteria remain in force;
there is still no product repair or ordinary-operation complete acceptance.

## Native-path qualification handoff

K17's two fresh guests pass all four Settings actions with the unchanged signed
diagnostic candidate and native unified-log capture. The logs now supply a
successful actual-NSApp reference: client call, WindowServer front change and
resume, then active/key notifications. No failure occurs under this added
instrument, so cause and repair remain open. Its logging load and synchronous
trace retain the timing limitation. All recorded endpoint/collection/cleanup
outcomes and subject/golden comparisons pass. Full-scenario phases after the
Settings prefix remain NOT RUN.

K16 decomposes to preserve that completed evidence slice and carry the remaining
activation-context discrimination and every original repair/ordinary acceptance
criterion into k18. Do not extend the two-guest native sample or either earlier
completed sample. The durable report is settings-activation/NATIVE-RESULTS.md.
No product change, release, notarization or upstream report occurred; k12 stays
open against its unmet causal repair and complete ordinary-operation criteria.

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
