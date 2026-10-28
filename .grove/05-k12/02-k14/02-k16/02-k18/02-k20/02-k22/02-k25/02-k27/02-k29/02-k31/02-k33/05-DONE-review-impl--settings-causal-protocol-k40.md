# settings-causal-protocol-k40

**Reviews:** settings-causal-protocol-k38

<!-- tc: depart long-sentence, semicolon, spelling because Goal, Context, Done when and Notes are the producer-authored charter, kept verbatim as the task contract -->

## Goal
Independently review the implemented protocol and scientific interpretation at
k38's committed boundary before k39 design or any k36 runtime freeze/launch.

## Context
Read the producer's commit/diff, CAUSAL-PROTOCOL-RESULTS.md, the full replacement
CAUSAL-PLAN.md and unchanged CAUSAL-PLAN-K34.md proposal. Inspect the AppKit probe,
trace/menu integration, actual route/readers/control policy, Taskfile and all
headless controls, retained RED/final outputs, input manifests and original audit.
Read k33's unchanged charter, CAUSAL-REVIEW.md and the retained native paired
appearance/ordering and host-boot receipts. The full FOCUS/CLOCK/PERSISTED duty
comparisons remain authoritative. All proposed guests are unstarted. No guest,
product repair, final signed subject or ordinary acceptance is claimed.

## Done when
- Inspect the actual committed artifact independently for correctness and useful
  test coverage. Challenge scientific discrimination, matched prior-selection/
  foreground/window setup, concrete highlight/positive-Return qualification,
  timer/monitor/callback semantics and scope, transport failures, native candidate
  cardinality/order/identity/scale/completion, exact containment and first-launch/
  setup/provisional/final stop policy. Do not assume helper tests reach AppKit.
- Check the narrow necessity interpretation and the precise externalized k39
  question against k33's unchanged competing-prediction duty. Ensure no unsupported
  deterministic rival, private op semantics, absent-log proof or all-green cause
  claim. Check whether every guest is properly held behind that unresolved
  design and whether the implementation can qualify the claimed observations.
- Verify every declared setup/slot/cap change and all remaining original duties:
  actual signed-subject/all-input/completed-golden freeze; failed transports,
  partials and NOT RUN; audits/exact clone stop; positive disposition/responsible
  context; justified application repair/useful failing seam; separate finite
  complete ordinary acceptance with diagnostics disabled and timing addressed.
  Old archive/candidate/strict-false joins/classifications/closed caps remain.
- Produce findings without fixes. Cut an earned integrate-review-impl with the
  producer's bare stem at the next directory-local live entry (k39), before
  k36 and every guest. No findings means no integration leaf. No in-session
  reviewer or guest runtime belongs in this review.

## Notes
K38's session had no GROVE_PROVIDER_EVIDENCE receipt in its environment; there is
no invented Creator line. If owner review policy requires provider declaration,
the owner supplies it. Compiler/build/SDK inventories and actual guest coverage
remain outside the saved source-input measurement; no host control qualifies a
guest. The two historical archived-context documentation failures remain k23's.
No causal ancestor closes here; no release/notarization or upstream report.

## Decisions (running log)
- 2026-10-28: Adopt the mandated review-impl leaf. The jj working copy is
  empty on b2253f0c, the k38 producer commit. The graph server does not
  connect, so this review uses direct source and evidence reads. It runs no
  test, build, guest or VM work, and it uses no in-session reviewer.
- 2026-10-28: Compare the containment reader with every retained whole-process
  native extract. Each saved Koine process has one more client row than its
  activation brackets. This is the P1 finding below.
- 2026-10-28: The findings need action before k39 and k36. Insert one
  integrate-review-impl leaf before k39.

## Findings

Severity: P1 can make the capped route or modality set unable to answer its
question. P2 is a protocol or reader defect that integration must decide before
any freeze. P3 is a coverage or uncertainty gap. Line numbers refer to commit
b2253f0c. Paths are relative to docs/verification/settings-activation/.

### P1-1. Launch adds an unwrapped Koine client row, so every slot is AMBIGUOUS

causal-protocol.py:258-269 counts every Koine `SLSSetFrontProcessWithInfo` row
in the whole-process rendering. It compares that count with the count of
`application.activate.interval` records. Unequal counts give MISSING or
AMBIGUOUS. Equal counts map the brackets to the rows by native order.
CAUSAL-PLAN.md:196-198 says that first launch is selection 0 and "must later
have exactly one enclosed actual client record". CAUSAL-PLAN.md:218-221 and
236-243 make that control a gate for the whole slot.

The retained extracts show a different launch. persisted-01/native-path-records.jsonl
lines 9, 20, 37 and 49 are four Koine client rows from PID 814.
persisted-01/events.jsonl has three activation brackets, for selections 0, 1
and 2. The row at line 9 is at 06:03:54.853131 UTC. That is 0.9 ms after
`application.didFinishLaunching` and about 1.05 s before `show.enter`. No
`measureActivation` call encloses it.

events-01 and native-01 show the same
pattern: two launch-time rows, then one row for each selection. In events-01
the first row (05:08:13.206382) precedes `buffer.started` (05:08:13.213662).

The modality and route slots have the persisted-01 structure: first launch,
setup selection 1 and measured selection 2. For that structure, `containment`
gives AMBIGUOUS for selections 0, 1 and 2. `control_policy` then gives
STOP_SLOT at the final stage. route-readiness-01 fails at its first native join,
and the stop rule at CAUSAL-PLAN.md:164-169 then ends all route qualification.
The saved data predicts this result before any guest runs. A capped slot would
be consumed to find it.

A second defect follows from the order mapping. Suppose that one wrapped call
emits no row. Then the counts match, and each later bracket maps to the row of
an earlier call. The reader can then report ENCLOSED or OUTSIDE for the wrong
row, with no error.

The tests do not find this. The native fixture at
Tests/scripts/test_settings_causal_protocol.py:77-88 and 410-430 has exactly
one row for each bracket. No control uses a retained whole-process extract.

Uncertainty: the saved processes ran earlier candidates. k38 does not change
the launch path in AppDelegate.swift. The extra row is an observation. Its
origin, probably AppKit or LaunchServices launch activation, is not
established. Integration must decide how the reader treats the launch row
before any guest. It must not filter rows to the desired bracket, and a new
rule needs evidence from a retained rendering.

### P2-1. The final control stage has an undefined focus input

causal-protocol.py:159-181 requires `focus_success` at every stage, including
`final`. The CLI exposes one `--focus-success` flag (causal-protocol.py:428-431).
CAUSAL-PLAN.md:209-221 says that `control_policy` implements the progression,
but no document defines the flag at the final stage.

If the caller passes the measured outcome, a measured failure gives STOP_SLOT
and `qualified: false`. The policy then rejects the outcome that the Hclick
falsifier needs (CAUSAL-PLAN.md:44). If the caller passes the control outcomes,
the flag repeats the launch and setup stages. The test at
Tests/scripts/test_settings_causal_protocol.py:384-390 passes `True` only.
Integration must define the final-stage input, or remove it, before k36 uses it.

### P2-2. route-readiness-01 has no declared mouse delivery criterion

CAUSAL-PLAN.md:161-166 requires both readiness slots to complete "the intended
delivery evidence". The only delivery reader is `return_invocation`, which
accepts keyCode 36 only. No section declares the positive evidence for the
mouse slot. An example is a monitored leftMouseDown and leftMouseUp after the
nonce, with Settings highlighted, then the callback. The plan also does not
name `return_invocation` as the readiness-02 criterion.

The k38 charter requires the rejection criteria to be fixed before observation.
Without a mouse criterion, route-readiness-01 can pass or fail only by a
judgement made after the guest runs. Hclick does not need mouse delivery
evidence, but the readiness slot does.

### P3-1. Saved callback context bears on the Return identity criterion

The Return criterion needs `NSApp.currentEvent` at the callback to be the same
object as the monitored keyDown (SettingsMenuProbe.swift:84-88). The callback
runs in default mode after `menu.didClose` (PERSISTED-RESULTS.md:75-77).
EVENTS-RESULTS.md:105-107 records that, at each saved mouse callback,
`currentEvent` was a leftMouseDown aged about 0.35 s. It was not the
leftMouseUp that a menu click ends with.

This saved fact does not decide what `currentEvent` holds after a Return. It is
the only retained observation of that getter at this callback. The plan and
results do not weigh it. k39 or k36 must consider it before the decision to
spend route-readiness-02.

### P3-2. The route and Return reader have coverage gaps

The route test at Tests/scripts/test_settings_causal_protocol.py:302-363 runs
the Return mode only. No control checks the mouse `input click X Y` command, the
geometry rejections at causal-protocol.py:346-356, or the refusal of an
existing output directory at causal-protocol.py:307.

`return_invocation` checks the highlight file against its own `requestUUID`
(causal-protocol.py:105). The `return` subcommand takes no expected nonce from
the route. The direct-input session and nonce match limit the effect. A
caller can still pass a highlight file from a different route directory
without an error that names the cause.

The AppKit probe has no executable seam. CAUSAL-PROTOCOL-RESULTS.md:78-83
discloses this correctly.

### Checked without a finding

- The probe runs only with the memory buffer, no file trace and the opt-in
  flag. Ordinary operation creates no file, timer or monitor.
- A request is one UUID of at most 37 bytes. Each UUID is consumed once, with
  a budget of 16. The response is written without overwrite.
- The monitor returns its argument unchanged. The timer runs in the
  event-tracking mode only, stops after 80 polls, a served nonce or a close.
- The 8 s probe window is sufficient. Saved menu-open to callback times are
  2.10-2.21 s for the settled route, and the new route adds about 2 s.
- The coordinate route copies the settled `click_at` approach and waits. The
  saved Settings frame (1648, 71, 242, 24) is inside 1920×1080.
- The transport envelope fields match retained `testanyware` exec output, for
  example window-resize/scenario-failure-native.json.
- The readers keep exact integer ticks and closed bounds, with no widening.
- The plan states that Hshared has no finite falsifier. It assigns no
  semantics to the private op fields and makes no deterministic rival claim.
  k39 carries the precise question, and every guest waits behind it.
- CAUSAL-PLAN.md:13-19 declares each setup, slot and cap change. No historical
  cap opens. The original audit passes. The controls exit 0. The documentation
  check exits 201 with only the two k23 failures.
- The k36 body and the k33 brief carry every original causal, justified
  repair, useful failing-seam and separate frozen ordinary-acceptance duty.
