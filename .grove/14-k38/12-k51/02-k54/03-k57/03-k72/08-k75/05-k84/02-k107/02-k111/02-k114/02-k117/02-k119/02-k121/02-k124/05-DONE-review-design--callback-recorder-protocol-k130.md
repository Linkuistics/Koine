# callback-recorder-protocol-k130

**Reviews:** callback-recorder-protocol-k129

## Goal
Adversarially review the complete recorder protocol against honest native
producers before k126 builds and measures it.

## Context
Read k129's commit, the native recorder and causal contracts, canonical v2
traces, generator/checker and frozen results under
`docs/verification/callback-native-capture/evidence/k129/`. Reconcile current
source with that producer commit. Read k127's eight original findings (commit
`a20fb3d5`), k128's dispositions, and k124/k121's original criteria.

## Done when
- Derive an honest producer execution for each of ordinary/after-callback ×
  both public pairs × both constructions. Compare its complete role streams
  to the accepted traces, including startup activity, arm, distinct trigger,
  enclosing returned, retention, finish and every exit release. Passing mutants
  alone is not evidence that a positive can be produced.
- Challenge the version-2 trigger post/tap/target joins, generic ordinal
  receipts and no expected-marker configuration/filtering in targets. Check
  queued B/non-trigger callback rejection and repeated or unexpected input.
- Challenge background launch, post-activation settle to both targets,
  post-return switch, finite start-to-closed observation and all-ack-before-exit
  rules. Identify any in-window activity that an honest implementation must
  hide to pass, or any native assumption smuggled into a synthetic edge.
- Revisit all eight k127 concerns: trigger representation; activity order;
  owned/private loop coverage and serviced custom-mode control; combined
  outcome precedence/shared graph; per-clone preparation; admitted candidate
  PID provenance; tap selection; host recovery/helper/deadline accounting.
  Preserve k128's repairs unless evidence supports a correction.
- Check explicit versioning and preserved version-1 schedule meanings,
  complete frozen corpus, exact diagnostics and itemwise maps. Check v2
  ordinary's explicit returned requirement against the same native producer.
- Check contract/assessment/views/k126 charter/k124 brief reconciliation.
  No parent closes on synthetic consistency. Native producers, loop coverage,
  statuses and containment stay unestablished until measured by their owner.

## Notes
Findings only under review-design; no native capture, implementation, permission
change, product adoption or in-session reviewer. Any integration must precede
callback-recorder-native-k126. Presentation rendering/inspection, if needed,
runs only in a disposable TestAnyware clone.

## Findings

These findings were read against k129's commit `46b1f62` (jj `oxlnqkzx`). The working copy was empty and matches it. The artifacts read are:
- the native recorder contract, `docs/verification/callback-native-capture/contract.md`, cited as *NC*;
- the causal contract, `docs/verification/callback-causal-fixture/contract.md`, cited as *CC*;
- `analyze.py` and `recorder_controls.py`, with `make_controls.py` for the legacy fixture;
- the canonical v2 traces;
- the k129 frozen run;
- the capture assessment and the three recorder views;
- the k126 charter and the k124 brief;
- k127's findings (commit `a20fb3d5`) and k128's dispositions;
- the k118 route producer, `callback-input-route/{contract.md,route.m,run-guest.sh}`.

Findings are in severity order. None asks for a native result, a product adoption or a freshness claim.

**What holds up**

- **Versioning.**
  - Every line k129 removed from `analyze.py` was generalised rather than dropped: the version choice, the field table, the event-role check and the input count.
  - The only new v2 edge (`analyze.py:568`) and the returned rule (`:614`) are gated on version 2. Version-1 behaviour is therefore unchanged by construction.
  - The frozen `before.json` digests match every committed file they name. The one exception is the interpreter entry, which is not a file.
  - `results.json` matches all 233 entries of `controls.json` on exit, code and reached. `legacy-corpus.json` records the 65 original pairs as byte-identical.
- **The returned boundary.** The enclosing-call producer for returned is the same in ordinary and after-callback (NC:168-190). Requiring returned in ordinary adds evidence, and the ordinary schedule gains no new cross-process dependency from it.
- **Finish and exit ordering.** The finish → closed → finished → exit ordering is sound, and it is fully enforced in the analyzer (`analyze.py:491-501`).
- **Reconciliation.**
  - k128's five smaller repairs appear unchanged in the contract (NC:192-218, 334-355, 233-247, 258-267, 396-431) and in the k126 charter: loop coverage, combined outcome, preparation, PID provenance and host recovery.
  - The contract, the assessment, the protocol view, the k126 handoff and the k124 brief agree with one another.
- **Parent state.** No parent is claimed closed.

### 1. The protocol dropped the only measured activation wait, so honest markers can reach the wrong app — high

The route that k118 measured did not rely on LaunchServices completion. After each target reported ready, the runner reopened the target and **waited for its `NSApplicationDidBecomeActiveNotification`** (`run-guest.sh:17-23`, route contract :11-14). The controller then posted the trigger only after B's receipt showed `active` and `key_window` both true (`route.m:199-203`). The first k118 run failed for exactly this reason: "advisory activation yielded no activation notification" (`callback-capture-transfer.md:538-541`).

The v2 protocol replaces that wait:
- It uses `open -g -n` launches (NC:51-57). This background mode was never measured; k118 launched without `-g` and targets called `[NSApp activate]`, `route.m:257`.
- Activation is `open -a` plus the helper's completion (NC:61-63, 122-124). `open` returns when LaunchServices accepts the request, not when the app becomes active.
- The settle barrier orders only notifications that were already dispatched (NC:69-73). Nothing requires a target to have observed its own activation.

Honest executions that follow from this:
- **B marker.** It is posted after `settled-B`, possibly before B is frontmost. It then reaches the previously frontmost app, which records nothing. The result is `missing-input` or a gate timeout.
- **C marker (after-callback).** After `switched-B/C` there is **no C-side message at all**. The only barrier before the C post is the helper wait, so the C marker can reach B, which is still frontmost. That depends on luck, not on the candidate.
- **The canonical traces.** They place B `activated` before `settled-B` and C `activated` before `inject key-C` (`recorder_controls.py:36-38, 70-74`). Only arrival order puts those rows there; no causal or audit edge does. The routing assumption is carried by the synthetic ordering, not by any producer or edge.

Integration should restore an activation observation before each marker post. It must be the target's own state, not marker configuration. Examples:
- a target reply or receipt only after that target observes itself active and its window key;
- or k118's activation-notification wait, recorded as an audit join.

It should also add the missing C-side barrier after `activate(C)`, and bound these waits in the case deadline. It should add a control in which activation never completes, so the case must end unreached rather than misattributed. The switch to background launch also needs its own route evidence, or a stated reason why k118's foreground-launch evidence carries over.

### 2. The causal `activity` class is not frozen; "every notification" and "no filtering" cannot both hold — high

The contract uses conflicting language about notifications:
- "Record every resulting notification" (NC:56).
- "Key-up, non-key-down input and notifications are retained in audit" (NC:80).
- The activity row is "actual notification ... no filtering of inconvenient activity" (NC:315).
- CC:72 defines `activity` as "activation/resignation/window change".

No text says which notifications become causal `activity` rows and which stay audit-only. The one measured producer used a closed four-name set: did-become/resign-active and did-become/resign-key (`route.m:249-254`). The contract does not carry that set forward.

The canonical kinds `window-created`, `window-ready` and `window-change` (`recorder_controls.py:31, 38, 82`) belong to no named notification. That set is not the k118 set, and `window-created` is not a notification at all.

This matters because the activity rule rejects any activity that is neither before B input nor after `m_end` (`analyze.py:618-624`). If an honest collector read "every notification" literally, it would include per-event notifications such as window/app update or occlusion changes. The B marker keystroke itself can then produce a row inside the B-input→`m_end` interval, and every positive cell would become `ambiguous-activity`. Any narrower selection is a classifier that the target implementer picks after seeing results. That is precisely the hidden filter that the no-filtering rule exists to prevent.

Integration should freeze an enumerated mapping before measurement:
- notification name → causal activity kind, or audit-only;
- the reason each causal kind bears on foreground attribution;
- canonical traces rewritten to use only those kinds;
- controls showing that an in-window row of a causal kind is ambiguous, and that an audit-only name cannot be promoted or demoted after the fact.

This should be settled at the same point as finding 1, because activation and key notifications are the causal kinds that finding depends on.

### 3. Controller reaction and deviation controls do not follow the honest receipt producer; environmental misroutes are graded as contradiction or malformed input — medium

Targets send a generic ordinal receipt for **every** key-down (NC:81-88). The contract never states:
- what the controller does when a receipt's tuple does not match the frozen post;
- what it does when a receipt comes from the wrong target, or when the expected receipt never arrives;
- the names of receipts beyond the second.

In one scenario the controller stops useful work. The case then ends with incomplete streams and missing protocol messages, which is exit 2. In the other, the controller completes the protocol and the analyzer grades the full trace. The same native misroute therefore gets a different category depending on an implementation choice nobody has frozen.

The frozen deviation controls are also not honest-producer traces:
- **`trigger-wrong-recipient`** moves B's trigger input to C but keeps B's `trigger-received` send (`recorder_controls.py:207-208`). An honest B would have no second input to acknowledge, and an honest C would send `C-received`.
- **`extra-key-down` and `trigger-duplicate`** insert input rows with no receipt frame (`:209-210, 225-228`). An honest target would emit a receipt for each, and ordinal naming would shift which input carries the `trigger-received` ID.

The frozen exits compound this:
- `wrong-recipient` is exit 1 (CC:131; `analyze.py:309`), which combined precedence row 5 reports as **candidate-contradiction** (NC:347). A trigger or C marker reaching the wrong target is an activation/routing failure (finding 1), not evidence against the sampled value.
- `extra-input` and `duplicate-marker` are exit 3, which row 3 reports as **schema-invalid** (NC:345), even when the streams are well formed and record a real stray key-down.

Integration should specify the controller's response to each receipt deviation and name the surplus receipt IDs. It should regenerate these controls from the honest per-key-down receipt producer. It should also decide the v2 category for misrouted or surplus native input (exit 2 unreached/ambiguous is the natural fit) while leaving version 1's meanings unchanged.

### 4. Nothing states how many attempts a nondeterministic positive may take — medium

The contract accepts that quiet positive schedules are only possible and that "native probability is unmeasured" (NC:72-73). Findings 1 and 2 add more honest ways to end incomplete. It forbids replacing a cell with "a retry after changing the instrument" and preserves failed attempts (NC:463-466). It does not say whether the **unchanged** frozen case may be rerun in a fresh clone, how many times, or whether a cell is reported from all attempts.

Without a pre-registered attempt budget and reporting rule, k126 has two failure modes:
- It can credit the one pass among N runs, which is selection bias that the frozen corpus cannot see.
- It can treat a single racy incomplete as a blocking result.

Integration should freeze a per-cell attempt budget and stopping rule before measurement. Every attempt should be reported with its combined category, and a cell's result should state its attempt count.

### 5. Loop coverage makes every honest positive instrument-incomplete, and nothing gates the matrix on first resolving it — medium

k128's rule is preserved and should stay: missing coverage withholds positive credit (NC:201-210). However, framework-private coverage "remains unknown unless a concrete mechanism establishes coverage" (NC:196-199), and the contract names no candidate mechanism. The custom-mode control is expected to show either detection or "the actual coverage gap", and a gap does not establish coverage for positive cells (NC:212-218).

On the contract as written, an honest execution of every one of the eight cells therefore lands in combined row 2 (`instrument-incomplete`), however clean its causal trace. The "accepted" synthetic cells are accepted by the analyzer only; no combined-outcome positive exists yet (see also `docs/design/architecture/README.md` "Eight synthetic matrix cells are accepted").

The control ordering (NC:435-461) runs the nested-loop controls alongside the other controls but does not make them a gate. k126 could build the full four-app recorder and spend 16 or more fresh clones before discovering that no cell can earn credit.

Integration should make establishing framework-private coverage an explicit gate before the positive matrix:
- name a candidate mechanism, or state that none is known;
- if none is known, carry out the k128 escalation (conflict plus recommended discriminator) before building the matrix, not after.

This preserves the repair and changes only its sequence.

### 6. Canonical positives carry legacy producer values that contradict the contract — low

k126 must "compare native positive streams itemwise to the canonical role/protocol obligations". The canonical traces are presented as derived from the proposed producers (`recorder_controls.py:15`), but some of their values contradict the contract:
- **Legacy `enter` fields.** They copy the legacy fixture's `enter` with `thread: "tap"`, `turn: 1` and `mode: "default"` (`make_controls.py:50, 59`; for example `recorder-preheld-workspace-after-callback/trace.jsonl:35`). The contract puts the tap callback and every sampler mutation on the **main thread** (NC:168-173). The analyzer ignores `thread`, so acceptance is unaffected, but the baseline k126 compares against disagrees with the contract on a field the audit must check.
- **Non-notification activity kinds.** See finding 2.
- **Redundant order check.** `analyze.py:458` checks an order that the edge added at `:568` makes true by construction, so it cannot fail. The real guard is the armed→post chain at `:448-457`. It is harmless, but it reads as a test.

### 7. Producer-ordering and auxiliary-frame rules need one sentence each — low

- **Start versus collectors.** "Install target input/notification collectors before UI creation" and "`start` begins the observation window" (NC:54-56) do not order `start` against collector installation. A notification collected before `start` could be neither recorded nor dropped legitimately. State that the order is `start`, then collectors, then UI.
- **Auxiliary frames.** The supervisor→sampler candidate-PID relay (NC:261-264) and the controller→supervisor activation requests (NC:61-63) are real frames. The general rule "each app appends send ... and receive" (NC:43-45) would put them in the causal stream. The v2 closed message set rejects any extra exchange (`analyze.py:416`), and the supervisor is not a causal role. Declare these frames audit-only rows joined by the audit verifier, so an honest implementer does not fail schema by following the general rule.
