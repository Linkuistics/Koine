# callback-recorder-protocol-k134

**Integrates:** callback-recorder-protocol-k133

## Goal
Triage k133's review of k132's version-3 recorder protocol and apply the valid
findings before callback-recorder-native-k126 builds and measures against it.

## Context
- The findings are in k133's own task file, anchored to producer commit
  `2848d27`. Read them against the native/causal contracts, `analyze.py`,
  `recorder_v3_controls.py`, the frozen k132 evidence and the recorder views.
- Several findings concern what the checker accepts for honest or dishonest
  executions. Test those claims by constructing traces and running them through
  the analyzer, not by prose alone.
- The artifact is a labelled experiment contract. No native execution, product
  adoption, permission change or freshness claim follows from integration.

## Done when
- Every k133 finding is classified in the running log as valid and applied,
  unclear contract settled, visible accepted trade-off, or rejected with a reason.
- The contract, causal contract, assessment, recorder views/captions, k126 charter
  and k124 brief agree on every applied change. Any analyzer or causal vocabulary
  change is versioned, has failing controls, preserves v1/v2/v3-as-frozen
  meanings (no relabelling of k129/k132 evidence), and renews the complete frozen
  corpus with itemwise maps.
- k126's charter names every new native obligation, control or escalation the
  integration assigns. Every k124/k121 criterion keeps a live owner; no parent
  closes on synthetic consistency.

## Notes
One narrow in-session reviewer is allowed. If a finding requires redesigning the
protocol rather than repairing it, externalise a new design → review chain beside
this leaf, before k126. Any rendering or inspection of the architecture viewer
runs only in a disposable TestAnyware clone, never on the host.

## Decisions (running log)

- Read k133's findings from commit `5b77d7bd`, against producer `2848d27`.
  Tier 2 graph generation `2026-09-23T18:27:55Z` reports matching metadata and
  no recorded gaps for the analyzer, generators and two contracts; exact source
  reads confirm the relevant paths. Unrelated heuristic trace edges are not used.
- Findings 1–3, 6–8 expose a shared state-machine boundary: abort bypasses success
  protocol validation; most bounded waits have no terminal representation;
  completed samples disappear behind abort; sampler cancellation/loop baseline
  and per-peer FIFO need explicit semantics. Reworking these together changes
  the executable contract and canonical executions. Apply the integration
  skill's substantial-redesign rule: create a producer before k126, requiring
  fresh tree review before native use. Keep analyzer/schema/generator/control
  bytes and v1/v2/v3-as-frozen meanings unchanged in this integration. Reproduce
  the old behavior independently and correct claims about its readiness here.
- Finding 10's outcome-map condition is an unclear contract: complete trusted
  audit AND established loop coverage AND confirmed containment are required.
  Correct prose/captions now; preserve k132's frozen JSON byte-for-byte and label
  its abbreviated field name historical. It does not predict an attainable
  positive under the currently unspecified private-coverage mechanism.
- Findings 1–3, 7 and 8 are valid and reproduced in the initial 136-case run:
  premature B/trigger/C posts still report environmental exit 2; unlisted and
  ordinary-C posts survive an abort; `armed` timeout is `abort-reason` (3);
  post-retention abort masks a stale-F contradiction and reports reached=false;
  false/missing/early activation reports exit 2; reversed B receipt delivery
  still reports surplus-input (2). Baseline/stale-F/malformed controls exercise
  exits 0/1/3. Assign the coordinated semantic repair to
  `callback-recorder-state-machine-k135`, preserving current raw meanings.
- Finding 4 is valid as a canonical-producer gap, with qualifications. Source
  confirms omitted after-callback return messages and ordinary completion work;
  inserting them still reports the expected receipt timeout. Startup/later key
  notifications lack a justified history. B resignation before activate(C) is
  not intrinsically impossible: spontaneous activity is explicitly allowed.
  Reject that stronger inference; the exemplar must either identify it as
  spontaneous or actually order it after the claimed cause. Early notifications
  and late active replies are accepted in reproductions, so these are missing
  coverage rather than established rejection bugs. k135 owns complete producer-
  derived traces, including armed-before-trigger abort and alternate deliveries.
- Finding 5: object scope is a valid contract ambiguity for k135. Apple documents
  nil-object subscriptions as unfiltered by sender and window updates as per-
  window notifications; the pre-creation/fault-all-other-objects prescription
  leaves the actual filter unsettled. This is not proof the fixture necessarily
  creates an extra window. Row volume is a visible accepted trade-off: the 512
  limit bounds storage, not honest-run feasibility. Preserve it, disclose no
  sufficiency evidence, and require k126's native row census/overflow control.
  Do not invent a larger number or silently omit update names.
- Finding 6 is valid underspecification, not proof that a single literal `main`
  is wrong. k135 owns the host callout, baseline nesting, modes, stop/timeout
  policy, pending cancellation and measured thread encoding. Private-loop
  coverage remains a separate prerequisite; specifying a baseline cannot prove it.
- Finding 9 is an unclear contract/visible trade-off: local maxima are clipped
  by the already stated outer deadline, so their sum need not fit 30 seconds.
  Four launch helpers plus the B path can consume 40 seconds at individual
  maxima, before finish or C. Explicitly disclose watchdog-incomplete precedence
  and no v3 cleanup reserve. k135 must choose and freeze the useful-work/cleanup
  budget policy; k126 must exercise exhaustion. No existing deadline is extended.
- Finding 10's stray encoding is a valid native-producer gap, assigned to k135
  with raw zero/repeated/user-data values, not guessed into frozen symbolic
  markers. The outcome-condition wording is applied now in current prose and
  newly generated map metadata. Frozen k132 maps remain byte-identical.
  No durable product decision changes: the capture and public-AX ADR set remains
  coherent, and this reversible diagnostic repair does not earn a new ADR.
- Final reproduction matches all 136 expected reports with unchanged per-item
  subjects. Independent assertions inspect premature barrier order, reversed
  FIFO, completed C-valued stale retention and unconditional completion work.
  A separate genuinely pending-armed trace (no arm reply, trigger or sample)
  also returns 3/abort-reason; this distinguishes the unsupported label from
  merely trying to expire a completed gate. Raw traces and task invocation are
  retained under evidence/k134/pending-armed.
- Complete frozen rerun matches 541 outcomes. Every raw record and all 1,082
  canonical case/trace files equal k132 itemwise; analyzer/generator bytes are
  unchanged. Only Taskfile, two contracts and runner metadata differ in the
  measured input map. New outcome maps differ only in the condition-field label.
  All named frozen subjects were rehashed afterward. The analyzer task passes
  543 tests, lint, formatting and strict types. The new reproduction check task
  also passes; its type configuration retains the older reproduction script.
- Three recorder views rendered through Taskfile in disposable clone
  koine-k134-view with unchanged source/manifest/Taskfile/copied-runtime maps.
  Local SVGs match guest bytes and parse as XML. Safari discussion and initial
  viewports for all three diagrams were inspected; no full-size/full-scroll,
  mobile or dark-mode check is claimed. Stop succeeded and the backend inventory
  confirms the clone removed. No native recorder or permission setup ran.
- No narrow reviewer is spent: the replacement design has a mandatory tree
  review, and this integration's evidence claims have direct executable checks.
  k135 and k126 remain live under k124, retaining every original k124/k121
  criterion. Retire only k134; no ancestor closes and no cascade promotion is due.
- Final bounded checks validate 15 new local evidence/assessment links, with
  deliberately missing file/heading controls rejected. Protected k129/k132
  evidence, canonical corpus, analyzer and generators have no diff from
  `2848d27`; current frozen subjects still match their recorded hashes. Graph
  metadata is current for the inspected code/docs; diagram source freshness is
  untracked there, so direct source reads and measured render hashes supply it.
  The three pre-retirement live leaves are k134, k135 and k126. The only
  retirement is k134; the next owner remains the live k135 design producer.
