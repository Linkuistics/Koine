# settings-keepalive-record-recovery-k120

**Reviews:** settings-keepalive-record-recovery-k118

## Goal
Independently challenge the bounded record format, the one-use slot accounting
and the original-lock collection-recovery protocol that k118 produced. Decide
whether this schema slice is coherent enough for k119 to consume. Do not treat
it as a qualified numerical profile or an implemented mechanism.

## Context
Read the producer commit and the current requirements of k118 and its parent
brief. The primary artifact is docs/specs/settings-keepalive-records.md. The
owner spec, the producer resource-control contract, KEEPALIVE-RESOURCES.md,
KEEPALIVE-QUALIFICATION.md and the record and storage views define its
surrounding obligations. Re-derive against those artifacts. This is a scoped
schema review, not the eventual whole-design review of the complete parent.

## Done when
- Inspect the complete contract. Identify concrete contradictions or missing
  bounds that would prevent correct implementation. Check the typed fields,
  the referenced original objects and the identity, version and absence
  semantics. Check the encoded-size arithmetic, the record multiplicities and
  the required failure and final capacity.
- Try counterexample traces across every allocation, publication and transfer
  boundary. Include death before a byte is written, torn or ambiguous slots, a
  damaged fence and charged-but-unpublished work. Include retained inherited
  holders, partial collection and caller loss. Test the claimed one-use and
  single-global-sequence properties against the actual proposal, including its
  stated fault model and qualification prerequisites. Check that collection can
  use only proven unattempted items. Check that it cannot manufacture authority,
  charges or refunds.
- Check that pool, bootstrap and reference costs account for themselves. There
  must be no circular integrity dependency and no unbounded failure log.
  Distinguish protocol consistency from unestablished physical metadata,
  visibility and native bounds.
- Check reconciliation with the owner lifecycle, the approved substitutions and
  the current visual contract. Later real-coordinator controls must be precise
  and reachable at approved seams. They cannot be demanded before
  implementation. They must not be confused with S1 or native qualification.
  Preserve exactly the approved collector R3 and R5 scope and its separate audit.
- Record supported findings with exact artifact locations, the consequence and
  the smallest useful correction. If there is no substantive finding, report
  that explicitly. Create an integration only if the findings earn it. Its
  charter points to this review and does not transcribe findings as required
  changes. Place any integration before k119 consumes this artifact.

## Notes
Inspection only. No corrections, native execution, dependency work, VM, candidate,
freeze, acceptance or broader substitution authority. All numerical useful-fit,
whole-workload, external evidence and parent reconciliation duties remain live.
No in-session reviewer ran in k118. This leaf supplies the fresh context. The
producer's current provider receipt was absent, so this leaf invents no Creator
evidence.
