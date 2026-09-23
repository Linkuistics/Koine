# callback-recorder-protocol-k133

**Reviews:** callback-recorder-protocol-k132


## Goal
Adversarially review the complete v3 experiment protocol against honest native
producers before k126 consumes it. Find omissions and contradictions in the
contract, analyzer and full canonical success/abort executions.



## Context
Read the producer's committed artifact, the native and causal contracts, the
`recorder_v3_controls.py` generator, analyzer and frozen k132 evidence under
`docs/verification/callback-native-capture/evidence/k132/`. Read k130 findings
1–3/6 and k131 dispositions against their original commits; v1/v2 evidence has
not been relabelled. k124/k121 retain the original native criteria.

## Done when
- Derive an honest complete execution for each of the eight source/construction/
  schedule combinations. Challenge startup/UI/notification and collector-closure
  event order, not just whether known mutants fail. Check target-observed B and
  C active/key replies, already-active handling, late notifications, background
  launch limits and why helper completion cannot authorize a post.
- Challenge the frozen eight-name notification mapping, object scope, canonical
  activity sequences and native bidirectional audit duties. Identify any event
  an honest collector must hide to pass; audit-only omission cannot be disproved
  by causal data alone. Do not infer native reachability from named notifications.
- Derive every-key-down receipts without expected-marker target configuration:
  wrong tuple/target/state, empty Unicode, duplicate marker, absent receipt,
  shifted ordinals, surplus before/after trigger and during/after partial finish.
  Check first-deviation priority, immediate abort, in-flight late receipts,
  timeout phase truth, FIFO joins, closed-boundary reuse and bounded cleanup.
  Look for unchecked alternate legal or malformed traces beyond the generator.
- Verify v3 schema/outcome semantics, reached flag and classification precedence;
  preserve raw candidate contradictions separately from native credit. Compare
  all old case/trace/result entries to k129 and assess the new conditional combined
  map honestly: no native audit or combined outcome ran in k132.
- Challenge main-thread/mode/turn provenance, callback selection and the redundant
  post→enter order assertion. Preserve the private-loop coverage prerequisite,
  one-attempt/no-best-of-N rule, preparation/PID provenance, actual app exits,
  host recovery and containment obligations from k128/k131.
- Check contract, assessment, diagram sources/exports/captions, k126 charter and
  k124 brief agree. Every original native criterion must retain its owner. Report
  findings only; any actionable integration must precede k126.

## Notes
No native recorder execution, permission expansion, product adoption or parent
closure. Rendering/inspection runs only in a disposable TestAnyware clone.
This is the fresh tree review; spend no in-session reviewer. Passing the synthetic
corpus alone is not evidence that the selected native producers can emit it.

## Findings

Read against k132's commit `2848d27`; the working copy was clean and matches it. The artifacts read in full:
- the native contract `docs/verification/callback-native-capture/contract.md` (*NC*);
- the causal contract `docs/verification/callback-causal-fixture/contract.md` (*CC*);
- `analyze.py` and `recorder_v3_controls.py`;
- the canonical v3 traces;
- k132's frozen `causal-controls` run, `v3-outcomes.json` and `legacy-preservation.json`;
- the assessment's v3 sections;
- the three recorder PlantUML sources and the README captions;
- the k126 charter and the k124 brief;
- k130's findings and k131's dispositions;
- k118's `route.m`.

Per the review rules, no analyzer, test or render command was run. Any statement that the analyzer "accepts" or "passes" a trace comes from reading its code, not from running it. Tier-2 coverage (generation 2026-09-23T18:16:02Z) reports matching metadata and no recorded gaps for the analyzer, the generator and both contracts. The sources were read directly as well.

**What holds up**

- **Legacy preservation, checked independently.** All 466 case/trace files under `controls/` at `46b1f62` are byte-identical to the current files. All 233 k129 result records are equal to their counterparts in k132's `results.json`. The 308 v3 controls follow from the generator: 36 per ordinary cell and 41 per after-callback cell. No v1/v2 meaning was relabelled.
- **k128/k131 obligations.** The k132 contract diff removes only v2-specific wording. The following survive, and k126's charter carries them: loop coverage as a gate before the matrix, one attempt per cell, preparation, PID provenance, host recovery, actual exits and containment. Every k124/k121 criterion still names k126 as its native owner, and no parent is claimed closed.
- **Abort-path mechanics.** These are correct as coded:
  - first-deviation priority in controller receive order;
  - immediate abort (`seq + 1`);
  - "a completed gate cannot expire";
  - the rule that an earlier deviation beats a timeout;
  - no useful controller sends after abort;
  - partial-finish closure reuse (`analyze.py:786-802`);
  - release-before-`aborted-sampler`.
- **The redundant post→enter check.** It is now described honestly everywhere (NC:178-181, CC:289-291, assessment). The views and captions agree with the contract.

### 1. The abort path never checks the controller's own protocol, so controller faults are graded as environmental deviations — high

`recorder_v3` raises `Finding(2, reason)` for every abort (`analyze.py:817`). `recorder_protocol` is only reached on the success path (`:896`). The abort path therefore checks none of the following:
- activation → await → active → `active-B` → settle → B post;
- `armed` → trigger post;
- `callback-returned`/switch → `activate(C)` → `active-C` → C post;
- that posted markers are drawn only from the frozen three, in schedule.

Consequences:
- **Premature B post.** A controller that posts the B marker before `active-B`, or before `settled-*`, gets an honest wrong-app receipt. That grades as `input-misroute` or `input-state` (exit 2, "environmental", combined row 4), even though the controller skipped the barrier that makes misroute environmental.
- **Premature trigger post.** A trigger posted before `armed`, followed by any deviating receipt, is graded the same way.
- **Stray marker posts.** A post of an unlisted marker, or of the C marker in an ordinary case, is accepted as a post (`:623-631`). Delivered as B's first input, it matches `expected_ordinal` 1 and `continue`s with no issue (`:651-664`).

NC:473-477 makes environmental exit 2 conditional on honest failure. The checker cannot currently tell an honest failure from a controller that violated the protocol before the deviation.

Integration should apply the prefix of the success ordering, up to the abort cause, in the abort path too. It should also reject posts outside the frozen schedule as malformed (exit 3), and add controls for each case: B post before `active-B`, trigger before `armed`, C post before `active-C`, and an unlisted or ordinary-C post.

### 2. Most bounded waits have no v3 timeout or abort vocabulary, so an honest stall is either malformed or unspecified — high

NC:496 puts "five-second setup/message gates" on every exchange. NC:586 requires a native "Gate timeout" control ("withhold a real acknowledgment"). NC:485-487 says each control must match an exact, pre-frozen raw diagnostic. But v3 names only five gates (NC:199-200, `analyze.py:689-703`) and only the two timeout reasons. The following waits have no representation:
- `ready-*`, `settled-*`, `armed`, `callback-returned`, `switched-*`, `sample-complete`, `finished-*`, `aborted-*`;
- launcher/activation helper timeout or failure (NC:524-527 "timeout stops useful work");
- the sampler's own unreached outcomes (NC:293-297: timeout without the selected callback, disabled tap, nested loop).

A controller that honestly records `timeout {gate: "armed"}` plus an abort gets `abort-reason`, exit 3. That is schema-invalid, the category NC:474-476 forbids for environmental failures. If it records nothing, the outcome depends on whether the sampler emits a `fault` row (Trace.create short-circuits to `instrument-failure` before any abort checking), on truncation, or on the watchdog.

The return view makes the gap concrete: the sampler sends `Fault; no retention authorization` to the controller (`process-recorder-return.puml:36`). No such message exists in the closed exchange set, and no controller reaction is specified.

The k130/k131 category error is therefore fixed only for target receipts and activation. Integration should either:
- give every bounded wait a gate ID, abort reason and failing control, with a specified sampler→controller failure path; or
- state explicitly that these stalls are non-abort incompletes, and freeze the expected raw diagnostic for NC:586.

### 3. Abort precedence discards reached candidate results, and the reached flag is wrong after full retention — medium

The done-when requires raw candidate contradictions to be kept separately from native credit. NC:459-462 promises that a contradiction diagnostic is never overwritten. Yet `recorder_v3` runs first and every abort raises exit 2 with `reached=false` (`analyze.py:817`, `:91`). Nothing grades the sampled values.

Concrete cases:
- **Surplus key-down during finish.** In `surplus-at-finish` (`recorder_v3_controls.py:187-189`), a stray key-down arrives after `retained`, every release and `sample-complete`. The report says `schedule_reached=false` and `ungraded`, although the complete schedule was reached. A stale-F false attribution in the same trace would disappear behind `surplus-input`.
- **Ordinary trigger-phase deviations.** The honest ordinary sampler finishes retention on its own (finding 4a). Any trigger-phase deviation (surplus after the trigger, misroute, wrong tuple) therefore also hides a complete sample.
- **After-callback C-phase aborts.** These hide an already-captured false attribution at `m_end`.

Integration should decide one of two things:
- report candidate/reached evidence as a separate column when an abort follows a completed sample; or
- state explicitly that such aborts discard sampled evidence, and correct NC:459-462 and the reached semantics to match.

A post-retention stray should not report the schedule unreached.

### 4. The "complete honest" executions still omit or invent producer events — medium

The canonical traces are the itemwise baseline for k126. Several are not what the contract's producers would emit. (a)–(d) contradict the contract text; (e) is a coverage gap.

- **(a) After-callback trigger-phase aborts drop a message the sampler always sends.** Per NC:226 and NC:287-290, the sampler sends `callback-returned` at the outer-return statement, whatever B's receipt says. The after-callback misroute-trigger, wrong-tuple, empty-Unicode, inactive-input, absent-trigger, duplicate and surplus-trigger traces record `returned` but never send it. The generator adds that message only on the success path (`recorder_v3_controls.py:163-164`).
- **(b) Ordinary trigger-phase aborts leave the sampler waiting when it would already be done.** Ordinary has no retention release (`analyze.py:436-439`). Per NC:245-247, the honest ordinary sampler goes on after `returned` to `retained` → releases → `sample-complete`. The generator instead parks it after `returned` until `abort-sampler` (`:123-135`, `:58-72`). Compare `v3-preheld-workspace-ordinary-absent-trigger`.
- **(c) Impossible key sequences, and a native assumption.** Startup key notifications (`:99-100`) followed by activation key notifications (`:90-91`) give B, and in after-callback also C, the sequence key → activated → key with no `not-key` in between. That cannot happen for a become/resign pair. NC:128's "Canonical startup includes real-name key notifications" also assumes that a background-launched (`open -g`) window becomes key before activation. The brief forbids inferring native reachability from named notifications.
- **(d) B resigns for no cause.** B's resign rows are emitted unconditionally before `activate(C)` (`:168-171`). The activation-timeout-C trace therefore shows B resigning although nothing activated. The success traces show B resigning before the request that NC:233-234 names as its cause.
- **(e) Honest variants no control exercises.** None contradicts the contract, and each appears accepted by reading, but none is tested:
  - input misrouted to a never-activated C carries `active=true`/`key_window=true` with no C activation or B resignation rows;
  - activation notifications that arrive before `await-active-*` is received. This is the likely honest order, because the controller waits for the helper before sending `await`, and NC:77-78 requires handling it;
  - a late `active-*` reply after an activation timeout;
  - a deviation after `armed` but before the trigger post, which forces an abort into an armed sampler.

Integration should regenerate these executions from the producer rules, not from the legacy sampler slice, and add the missing variants.

### 5. The notification object scope cannot be implemented as ordered, and the audit-only names may exceed the row cap — medium

- **Object scope.** NC:62-63 and NC:101-105 require every observer to be registered before the fixture window exists, yet "window observers identify that fixture window". Window notifications can then only be registered with a nil object, which delivers every window's notifications, and NC:104-105 makes any non-fixture identity an instrument fault. `NSWindowDidUpdateNotification` is posted for each updated window. Any honest AppKit-internal window, or a transient panel, would fault the case. The alternative, registering per-window after creation and before showing, is excluded by the frozen order. Integration should choose one: nil-object registration that records non-fixture deliveries in audit only; or an explicit create → register → show order, justified against startup notifications.
- **Row volume.** The two update names are posted around event-loop update passes. The contract offers no volume argument against the 512-row per-role audit cap, and overflow expires the case (NC:491-496). An honest long case could exhaust the cap. Integration should bound this, raise the cap, or explain why the cap suffices.

### 6. The sampler's run-loop structure is unspecified, so "outer", "nested", "turn" and "thread" have no baseline — low/medium

- **Where the explicit call runs.** The sampler is an accessory NSApplication (NC:62), with socket and tap work on the main thread. Its "explicit outer" `CFRunLoopRunInMode` (NC:277-282) must therefore be invoked from inside an existing callout, such as the `sample-release` handler, within AppKit's own run. It is itself a nested run.
- **What the contract leaves open:**
  - the baseline nesting depth that is not treated as "nested loop … unreached" (NC:296);
  - which modes the socket source is serviced in during the owned invocation, and whether `abort-sampler` can re-enter it;
  - the invocation's timeout and `returnAfterSourceHandled` behaviour when queued B-marker taps arrive first;
  - how abort reaches an armed sampler (see finding 4e).
- **The `thread` value.** The analyzer requires the literal `thread == "main"` (`analyze.py:678-683`). The producer table (NC:427) does not say how the native observation maps to that string. CC:239-242 says values must be observed and never copied, but the only accepted value is a fixed label.

Integration should specify the sampler loop and handler structure and the encoding of each causal field.

### 7. Activation-producer violations are graded exit 2, while receipt-producer violations are exit 3 — low

A target replies only after both reads are true, exactly once, after the request (NC:72-78). The following are therefore producer-contract violations, not unreached evidence:
- a false `active` row;
- a missing `active` row while `active-*` was exchanged;
- an `active` row recorded before `await` was received.

The analyzer grades them `activation-observation`/`activation-order` exit 2 (`analyze.py:566-580`; controls `recorder_v3_controls.py:224-233, 302-303, 312`). The equivalent receipt violations are `receipt-producer` exit 3 (`:600-615`). NC:476 lists fabricated producer records as exit 3. Both categories withhold credit, but row 3 versus row 4 differs, and there is no stated reason. Integration should align the two or record why they differ.

### 8. FIFO delivery is relied on but never checked, even where the causal data could check it — low

Two guarantees rest on per-peer FIFO (NC:194-195, 210-211):
- in-flight receipts are drained before `aborted-<role>`;
- the "first deviation" is taken in a meaningful order.

`join_messages` pairs each message alone (`analyze.py:279-296`). A receive order that reverses the sender's order for the same peer pair can be decided from local sequences, yet it passes unless it happens to create a cycle. The audit fixture list (NC:571-580) names no reordering fixture, despite NC:195. Integration should add the offline per-pair FIFO check with a control, or state why it stays audit-only and add the fixture.

### 9. The gate budget exceeds the case deadline and reserves no time for cleanup — low

The case is bounded by a 30-second guest deadline from first launch (NC:496-497). The sequential waits inside it are:
- four launch helpers, up to 5 s each;
- activation helper plus `active-B`;
- the B and trigger receipts;
- in after-callback, helper plus `active-C` and the C receipt.

Their maximums alone exceed 30 s before any bounded abort cleanup (NC:217-222). A late but legal timeout therefore becomes a watchdog-incomplete result, not the "exact environmental reason", and with one attempt per cell (NC:607-617) that attempt is lost. Integration should freeze the arithmetic: which deadline wins, and how much time cleanup reserves.

### 10. The stray-input encoding is undefined, and the outcome map's condition leaves out coverage — low

- **Stray input.** k118 carries the marker as event user data (`route.m:73, 121`). A true stray key-down therefore has user data 0, but the causal `marker` must be a non-empty string, and no encoding is frozen for unmarked or repeated strays. The generator uses the invented string `"stray"`. Integration should freeze an encoding.
- **Outcome map.** `v3-outcomes.json` labels positives `expected_combined_with_trusted_audit: consistent-native-call-order`, and the assessment says "conditional on complete trusted native audit and containment". Row 6 also requires established coverage. NC:321-330 states that no coverage mechanism exists, so under the current contract every positive would land in row 2. Integration should put coverage in the stated condition, or in the field name, so the map does not read as an attainable expectation.

None of these findings asks for a native result, a permission change or product adoption. Integration must precede k126.
