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
