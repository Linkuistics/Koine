# settings-keepalive-record-recovery-k118

## Goal
Specify the complete bounded record schemas and one-use storage/ordinal recovery
protocol under the original writer lock. Make record costs and ambiguous states
checkable without claiming unavailable storage or native guarantees.

## Context
- docs/verification/settings-activation/KEEPALIVE-RESOURCES.md, Record coverage
  and remaining schema, is the inventory, not the finished schema.
- docs/specs/settings-keepalive-owner.md owns lifecycle, commitments and locking.
- docs/specs/settings-capture-resource-contract.md owns approved substitutions.
- docs/verification/settings-activation/KEEPALIVE-QUALIFICATION.md owns the
  proposed backing arrangement, S1 and later S2–S6 controls.
- k117 records the approved collector sites and TestAnyware issue #13.

## Done when
- Define bounded field encodings, identity/version rules, lengths, checksums and
  predecessor/reference semantics for every root/profile/pool, fence, slot
  binding, submission, commitment, backend/collector, delivery, stop/recovery,
  handoff and caller record required by the complete owner protocol.
  Distinguish missing, zero, unknown and inapplicable facts. Reference original
  evidence without truncation, private-root disclosure or duplicated payloads.
- Account for maximum encoded size, multiplicity and metadata contribution of
  clean and failed rows, partial writes, refusals and unstarted cancellations.
  State any workload-dependent term for k119. Preserve bounded remaining
  failure/stop/recovery/caller capacity at every transition. Avoid an unbounded
  recursive failure log and count the accounting records themselves.
- Specify recoverable one-use assignment and write order for terminal-backed
  global ordinal/fence/storage bindings and collection-backed directories.
  Handle empty, torn, duplicate, stale and ambiguous slots; retained partials;
  uncertain consumed ordinals; unavailable upper frontiers; death between each
  write; and real lock-holder/orphan resolution. Recovery uses the original
  lock and global sequence, permits collection only and never creates scenario
  authority, replacement ordinals or refunds.
- State the storage/atomicity/durability assumptions separately from protocol
  guarantees. Every unestablished mechanism remains a named prerequisite.
  Eight-ordinal fences and 4096-byte study records remain fixture choices unless
  a new whole-workload derivation establishes them.
- Map the schema/recovery boundaries to precise later real-coordinator controls
  at approved seams, including failure before write and a real retained prefix.
  Those test results follow implementation. Do not demand nonexistent code's
  results or equate substitutions with native storage qualification.
- Reconcile the owner contract, qualification plan and storage/record views.
  Provide checkable walkthroughs for clean operation, failed commitment
  publication and collection after owner death. Keep k119's full reconciliation
  and all parent duties live.

## Notes
This question can be answered with symbolic workload multiplicities and explicit
unqualified backing assumptions. It cannot adopt a numerical useful profile or
claim a qualified mechanism. Use the approved R3/R5 sites exactly; implementation
and native execution remain outside this leaf. External dependency work belongs
to its owner under issue #13, not an implementation leaf in Koine. Cut scoped
review only if the completed schema artifact earns it; whole-design review must
wait for the complete parent artifact.

## Decisions (running log)

- 2026-11-01: Adopt k118 in clean jj change lnsomlwn, parent 6a504622.
  Keep the bounded schema and recovery question separate from k119's complete
  workload, useful numerical profile and missing mechanism evidence. Graph
  verification uses generation 2026-10-31T06:37:37Z; current design documents
  have changed metadata and are read directly. Diagram coverage is partial
  and their complete sources are read. The existing run_locked source still
  allocates from a flat ordinary-root scan; no implementation change is made.
- 2026-11-01: Specify one predeclared terminal pool with disjoint owner,
  collection-successor and final-caller lanes. Slot identity comes from the
  immutable layout, so no recursive allocation log is needed. A successor
  burns the failed lane, including apparently empty slots. Ordinal fences
  remain a distinct mechanism and never establish an operation charge.
  This trades retained unused capacity for a bounded recovery rule. All
  layout sizes and metadata costs require the later whole-workload derivation.
- 2026-11-01: Add the durable record specification beside the owner spec.
  Fixed binary atoms and typed payloads bound rows and private original objects;
  symbolic path maxima count every failed/partial write and protected tail.
  Use odd slots for fences and even slots for other records, burning skipped
  slots. This makes a torn non-fence distinguishable without trusting its header.
  Retain one caller-owned successor only. A collection fence binds one plan item
  and ordinal, so recovery cannot repeat possibly attempted collection commands.
  The ordinary fence width and all useful sizes remain workload parameters.
- 2026-11-01: Reconcile owner, producer-control, resource worksheet, qualification
  and visual contracts. Remove stale owner wording that denied the already
  approved collector R3/R5 sites. Preserve their exact scope and audit. No native
  mechanism, numerical useful profile or implemented coordinator is claimed.
  The schema is load-bearing and earns a scoped review before k119; do not spend
  an in-session reviewer beside that tree review. Whole-design review remains
  due only after the complete parent artifact. No ADR is earned by this readily
  revisable, unadopted protocol proposal.
- 2026-11-01: Verification found and corrected the kind-8 example's arithmetic
  total (964 fixed bytes); its field layout did not change. The first scratch
  parser also included private-object tables, so restrict it to record tables.
  The final 29-kind catalogue, five independently calculated examples, 384-byte
  frame, 232-byte process bundle and 511 finite parity schedules now agree.
  These are documentary checks, not coordinator execution or a crash proof.
- 2026-11-01: Run the existing `mise exec -- task check:docs`: Task exits 201
  and checker exits 1, naming only k23's existing missing context-predicate.txt
  and context-qualify-filter.sh archive links. All 221 checker-consumed document,
  task/checker and selected presentation subjects keep identical before/after
  hashes. Both manifests have unique IDs, existing sources and valid changed-view
  references. Inspect the rendered records/storage/completion views in Chrome
  at http://127.0.0.1:8814/settings-activation/#discussion. Their widths are
  within the 844-pixel panel; adjust the storage view's source to fit. No mobile,
  dark-theme, native or coordinator result is claimed. Jujutsu has no diff --check
  option; inspect its patch instead, with no added whitespace/conflict findings.
  Current provider evidence is absent, so the review receives no invented Creator.
- 2026-11-01: Final coverage query reports generation
  2026-10-31T14:15:04Z. Current schema/owner/producer prose is source-read where
  metadata changed. Full edited diagram sources cover the reported partial
  ranges (records 1–25, storage 1–34, completion 1–24). The presentation index
  is untracked in the graph; inspect its served rendering and source directly.
  No exhaustive graph claim follows. The scoped review is the next consumer;
  k119 and all ancestors remain live, so no parent close cascade is applicable.
