# callback-recorder-state-machine-k135 — brief

## Goal
Replace v3's partial success/abort description with one executable producer
state machine, preserving frozen evidence, before native recorder k126 uses it.

## Context
Read k134's integration commit and `docs/verification/callback-capture-transfer.md`
under Recorder v3 review integration, including its 136-case reproduction and
itemwise preservation. Read the native/causal contracts and the unchanged v3
analyzer/generator. The reproduction demonstrates current gaps, not a replacement
protocol. k124/k121 keep all original native criteria; coverage has no mechanism.

## Done when
- Specify and enforce controller phase prefixes on all terminal paths, including
  allowed posts, B/trigger/C barriers, every pending gate, helper/sampler failures,
  bounded cleanup and partial-finish reuse. Every bounded wait must have a defined
  incomplete/abort outcome and an exact failing control. A malformed producer
  must not acquire an environmental grade merely by aborting later.
- Specify sampler host callout, expected baseline nesting, socket/tap/timer modes,
  owned-invocation timeout/return policy, ignored queued B delivery and how an
  armed sampler receives cancellation. Separate expected nesting from forbidden
  extra nesting, and freeze measured thread/mode/turn encoding. Preserve the
  independent framework-private coverage gate; do not assume it into existence.
- Preserve reached candidate evidence independently of terminal controller
  outcome/native credit. Define the minimum causally justified sampled scope;
  a `retained` label alone cannot prove it. Falsify stale-F/stale-M and ownership
  contradictions followed by trigger/C/finish aborts, plus genuinely unreached
  and ambiguous samples. Do not suppress raw contradictions or overclaim reach.
- Derive complete honest success and abort executions from those producer rules
  across all eight cells: unconditional post-return sampler work, late in-flight
  messages, early notifications/late activation replies and armed-before-trigger
  cancellation. Explain every activity's origin/order; do not invent startup
  key transitions or quietly hide spontaneous activity to obtain a pass.
- Settle notification object scope with an explicit create/register/show sequence
  or nil-object/audited non-fixture policy, including startup/teardown limits.
  Keep row caps as safety bounds unless a new justified budget is frozen. Define
  native numeric marker encoding for zero, repeated strays and posted markers.
- Align producer-malformation classifications and check per-peer FIFO from local
  send/receive order. Freeze deadline precedence and a cleanup reserve or an
  explicitly justified watchdog-incomplete policy, with late-gate controls.
- Version every semantic/schema change beyond v3. Preserve all v1/v2/v3 canonical
  bytes and reports as frozen; add failing controls, renew the complete corpus,
  compare reports and input maps itemwise. Reuse the analyzer's causal graph;
  no separate cross-process ordering engine. Update native/causal contracts,
  assessment, recorder views/captions and k126/k124 handoff as one coherent artifact.
- Insert a fresh `review-design` leaf with this producer's stem before k126 once
  the artifact exists. Name the doubts above and require honest producer traces,
  not just mutant rejection. Any integration must finish before native use.

## Notes
Diagnostic design only; no product adoption, permission expansion or native
matrix. If this state-machine work cannot fit one focused session, decompose at
an executable vertical seam and retain the complete contract/review handoff.
No parent closes on synthetic consistency. Native evidence stays k126; gates
k122, freshness k115, lifetime/policy k112 and transfer k108/k109. Rendering or
viewing runs only in a disposable TestAnyware clone.

## Decisions (running log)

- The repair spans three independently falsifiable responsibilities: controller
  execution prefixes/FIFO, sampled evidence independent of terminal outcome, and
  complete sampler/target producers with bounded cancellation. Split at those
  executable seams rather than land another all-at-once partial protocol. This
  session supplies the controller-prefix slice; the remaining children retain
  every original criterion and the final fresh review obligation. Version each
  semantic increment beyond frozen v3; intermediate versions are diagnostic
  slices, never native-ready protocols. Reuse the existing Trace graph.

## Decomposition

- callback-controller-prefix-k136: versioned controller-prefix, allowed-post,
  active-producer and FIFO checks before environmental grading.
- callback-sampled-evidence-k137: independently justified sample scope and
  contradictions preserved through terminal aborts.
- callback-recorder-state-machine-k138: complete sampler/target producers and
  wait/cancellation/deadline policy, object/marker lifecycle, honest eight-cell
  traces, full reconciliation and fresh review before k126.

Every original Done when above remains binding. Each child delivers an
independently executable, falsified slice. k138 commissions the fresh review only
after the complete artifact exists; its integration precedes native use. No
native result, coverage mechanism or permission expansion follows from this split.

K138 is now a node. Its first child k139 preserves positive malformation on
schema-readable partial histories; k140 retains complete producers, waits,
lifecycle, partial sample policy, final reconciliation and the mandatory fresh
review. No original criterion is waived and neither k138 nor this node closes.
