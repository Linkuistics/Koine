# settings-keepalive-record-recovery-k120

**Reviews:** settings-keepalive-record-recovery-k118

## Goal
Independently challenge the bounded record format, one-use slot accounting and
original-lock collection-recovery protocol produced by k118. Determine whether
this schema slice is coherent enough for k119 to consume, without treating it
as a qualified numerical profile or implemented mechanism.

## Context
Read the producer commit and the current requirements of k118 and its parent
brief. The primary artifact is docs/specs/settings-keepalive-records.md. The
owner spec, producer resource-control contract, KEEPALIVE-RESOURCES.md,
KEEPALIVE-QUALIFICATION.md and corresponding record/storage views define its
surrounding obligations. Re-derive against those artifacts; this is a scoped
schema review, not the eventual complete-parent whole-design review.

## Done when
- Inspect the complete contract and identify concrete contradictions or missing
  bounds that would prevent correct implementation. Check the typed fields,
  referenced original objects, identity/version/absence semantics, encoded-size
  arithmetic, record multiplicities and required failure/final capacity.
- Try counterexample traces across every allocation/publication and transfer
  boundary, including death before a byte is written, torn or ambiguous slots,
  a damaged fence, charged-but-unpublished work, retained inherited holders,
  partial collection and caller loss. Test the claimed one-use and single-global-
  sequence properties against the actual proposal, including its stated fault
  model and qualification prerequisites. Verify that collection can only use
  proven unattempted items and cannot manufacture authority, charges or refunds.
- Check that pool/bootstrap/reference costs account for themselves without a
  circular integrity dependency or unbounded failure log. Distinguish protocol
  consistency from unestablished physical metadata, visibility and native bounds.
- Check reconciliation with the owner lifecycle, approved substitutions and
  current visual contract. Later real-coordinator controls must be precise and
  reachable at approved seams; they cannot be demanded before implementation or
  confused with S1/native qualification. Preserve exactly the approved collector
  R3/R5 scope and its separate audit.
- Record supported findings with exact artifact locations, consequence and
  smallest useful correction, or explicitly report no substantive finding.
  Create integration only if findings earn it; its charter points to this review
  rather than transcribing findings as required changes. Place any integration
  before k119 consumes this artifact.

## Notes
Inspection only. No fixes, native execution, dependency work, VM, candidate,
freeze, acceptance or broader substitution authority. All numerical useful-fit,
whole-workload, external evidence and parent reconciliation duties remain live.
No in-session reviewer ran in k118; this leaf supplies the fresh context. The
producer's current provider receipt was absent; no Creator evidence is invented.
