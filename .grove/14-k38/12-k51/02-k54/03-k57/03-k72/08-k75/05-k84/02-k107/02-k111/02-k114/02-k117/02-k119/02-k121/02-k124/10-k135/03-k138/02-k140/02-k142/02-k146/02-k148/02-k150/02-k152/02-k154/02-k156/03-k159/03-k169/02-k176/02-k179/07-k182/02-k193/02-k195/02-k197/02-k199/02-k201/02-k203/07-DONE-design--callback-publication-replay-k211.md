# callback-publication-replay-k211

## Goal
Complete the publication consumer policy exposed by k209, with determinate
sample-state, counting/closure, inherited-support and report-resource results,
before fresh k212 review and complete executable-delivery planning in k205.

## Context
Read k209's own committed findings (`61d93ad8`) against k208 (`b6e55f39`), and
k210's dispositions in docs/verification/callback-capture-transfer.md. Consume
publication-replay.md (including Unresolved consumer policy after k209),
transport-evidence.md, publication-capacity.md, both recorder contracts and the
causal sample-state table. Current analyzer source is the legacy oracle, not a
successor policy. All original k203 and ancestor criteria remain binding.

## Done when
- Specify the complete sample-state/scope classifier over T/F/U: unsupported,
  unreached, partial, ambiguous, reached, precedence with an earlier U arm,
  and core=T with ambiguity=U. Distinguish evidence gaps from closed-collection
  unordered activity without treating no path as a reverse-order proof. Resolve
  R15 against the causal contract; preserve every frozen legacy state meaning.
- Name the counting domain, eligibility and closure separately for W-input,
  W-enter and duplicate-envelope evidence. Resolve input inside replay plus a
  repeated tail input after fault; one qualified armed plus one undecodable raw
  armed; and one eligible enter plus a tail enter. State each edge, suitability,
  duplicate diagnostic and scope result; repair R06/R07/R18 accordingly.
- Define mandatory-support inheritance for selected paths through receipts and
  its composition with claim-owned support, alternative paths and negation.
  Give R11's order AND frame AND composed verdict, preserving every contributing
  begin where required. R22 already makes raw F with cyclic mandatory support
  usable U; do not leave the set of mandatory edges to implementation inference.
- Specify each activity/input/envelope/C-post-absence domain's valid closing
  boundary and observation_window's T/F/U count/quantifier formula. Resolve a
  semantic closed row followed by physical recording loss, open/closed empty
  domains and missing/duplicate boundaries without suffix-derived closure.
- Freeze a derived finite report/support budget (maximum claims, interned
  edges/paths/support references, transient query storage and encoded output),
  or explicitly name the exact numeric admission budget k205 must freeze and
  its derivation obligations before implementation. State the resource-failure
  result and what partial diagnostics remain, with no silent truncation. Add
  exact-limit/over-limit controls and a budget-bypass mutant. Input/graph bounds
  alone do not discharge this criterion; reconcile publication-capacity.md.
- For every chosen policy, give a determinate expected report, adjacent honest
  history and discriminating mutant in the R inventory, including open-tail
  absence of enter, core=T/ambiguity=U, closed-unordered versus broker-gap,
  tail/unqualified duplicates, inherited cyclic contributors, raw-F masking and
  cut-after-closed. Retain R01–R23 and all original topology/E/L/M/B controls;
  clarify superseded expectations in place, never relabel them passing tests.
- Reconcile publication-replay.md, transport-evidence.md, capacity, both recorder
  sections AND the causal state vocabulary, assessment ownership, k205 handoff
  and affected replay/claim views as one coherent artifact. Render and inspect
  changed views in a disposable TestAnyware clone. K212 reviews this producer;
  any findings integration must precede k205.

## Notes
Design only: no analyzer version, predicate extraction, corpus regeneration or
native experiment. Keep the actual-file seam, one immutable Trace, independent
columns, original coordinates and detached full legacy CLI. Preserve V1–V26
inputs, limits and full reports. K205 still plans the complete executable
successor under unchanged k203; no original ancestor criterion closes. K180/
k177/k143/k144/k126 retain phase/sampler/target/controller/native duties and
every k124/k121 criterion. The scheduled k212 review owns adversarial review;
do not run a competing in-session reviewer. Decompose if this bounded policy
artifact cannot fit one focused session, retaining every criterion and review.

## Decisions (running log)

- Keep one immutable Trace and the actual-file seam. Use explicit truth tables
  and discriminating histories for this fixed-history consumer policy; no new
  temporal model, analyzer version or predicate extraction is justified here.
  K212 owns adversarial review. Graph generation 2026-09-24T05:52:56Z is stale
  for analyze.py; its sampled_evidence snippet has obsolete offsets. Current
  source at 1591–1805 supplies the legacy sample-state and counting evidence.
- Count physically retained raw target inputs and sampler milestones against
  uniqueness even outside stateful replay; eligible endpoints still require
  the replay domain. Count locally qualified armed receipts separately from
  raw armed assertions. Witness edges are prefix-relative observations;
  closed-domain count claims additionally gate candidate credit. This preserves
  tail contradictions without resuming a state machine after its cut.
- Require a complete eligible producer stream and a valid physical lane end
  for candidate counting-domain closure. Semantic closed is the target-window
  endpoint, not proof that the collection has no later duplicate or activity.
  Complete but unordered activity may yield ambiguous with an explicit reason;
  a broker gap or cyclic support yields partial/unproved, never reverse order.
- Every selected causal path inherits all frame contributor/join edges for each
  receipt it traverses, recursively through exact upstream receipt dependencies.
  Select the canonical clean path before applying this mask; do not search for
  a more convenient path after masking. Preserve own mandatory support, raw F,
  alternative proofs and local receipt decisions as distinct evidence.
- Delegate the numeric offline report profile to k205 before implementation,
  with named admission dimensions and derivations from an enumerated rule
  inventory, bounded interned support DAG and serializer. Explicit resource
  failure preserves a bounded diagnostic sidecar and grants no sample scope;
  exact-limit, over-limit and bypass controls are mandatory. This does not
  change any input, transport reserve or frozen legacy budget.

- The complete observed sampler core remains prefix-relative so core=T with an
  open sampler tail is representable. Duplicate ambiguity stays U until the
  sampler collection closes; classifier precedence withholds scope. R25 pairs
  that real-file history with the honest closed tail. All closed count claims
  remain separately visible. Candidate interpretation uses local controller
  evidence, not upstream transport grades; this defines unsupported without
  reintroducing the legacy wire-success gate.
- Freeze the emergency-output envelope now: 4096 bytes, at most 32 fixed section
  IDs of at most 48 ASCII bytes, bounded numeric fields and no input-derived
  strings. K205 verifies the encoding bound and freezes all other named numeric
  report dimensions before implementation. R30–R32 own exact/over-limit,
  overflow, sidecar and surviving-diagnostic controls.
## Verification and handoff

- Complete policy and R01–R32 are in publication-replay.md; capacity fixes the
  named k205 numeric-profile obligation and 4096-byte emergency envelope.
  Transport evidence, both contracts, assessment, parent handoff and k205 agree.
  All seven Done when bullets are addressed as design, not executable delivery.
- `evidence/k211/preservation.json` records 16,311 unchanged selected final-k202
  code/Taskfile/control subjects, two root JSON inputs, three unchanged compressed
  and uncompressed archives, and a detected wrong-digest control. No runtime
  rerun, corpus regeneration or analyzer change is claimed.
- `evidence/k211/verification.json` records document/manifest/anchor/control
  checks, unchanged legacy state and E/B/limit text, original k203 criteria and
  live k212-before-k205 order. Existing Taskfile targets do not cover this
  documentation-only policy; no reusable executable task was added.
- `evidence/k211/presentation.json` binds final assets and 19 captures from
  disposable TestAnyware clone koine-k211-view. All final diagrams/captions were
  inspected in wide light; narrow dark covered replay/claim entry/body and the
  full classifier/caption. Fresh-page deep linking and both discussion layouts
  were checked. Initial classifier overflow was corrected and re-rendered.
  Precise limits are recorded; no mobile/native/executable inference follows.
  Clone and temporary server stopped, existing viewer and unrelated VM remain.
- Current ADRs/glossary still describe the product boundary. K212 remains the
  fresh review, followed by any required integration before k205. K203 still
  has live children, so retirement closes no parent and no ancestor criterion.
