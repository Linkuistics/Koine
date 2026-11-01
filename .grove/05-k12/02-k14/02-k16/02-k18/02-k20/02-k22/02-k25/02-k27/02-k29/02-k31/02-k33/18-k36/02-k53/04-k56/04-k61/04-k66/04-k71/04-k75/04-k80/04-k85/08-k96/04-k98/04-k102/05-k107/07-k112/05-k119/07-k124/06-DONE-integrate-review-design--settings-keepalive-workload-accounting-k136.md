# settings-keepalive-workload-accounting-k136

**Integrates:** settings-keepalive-workload-accounting-k135

## Goal
Triage the k135 review findings against the k132 accounting derivation and
apply the real ones before k125 and k126 consume it.

## Context
Read the k135 leaf for its findings and clean checks. Read the two k132
commits and KEEPALIVE-ACCOUNTING.md. Read the owner and records specs, the
worksheet and the scheduling evidence. Read the accounting diagram with both
manifest entries.
The derivation's identities and sizes matched on review. Do not re-derive a
value unless a fix touches it.

## Done when
- Each k135 finding has a recorded disposition: applied, rejected with a
  reason, or a visible accepted trade-off.
- Applied fixes adopt no capacity and change no counted operation, wait or
  image. Every missing input stays explicit and owned.
- Any schema change keeps the records spec, the accounting and the diagram
  captions in agreement.
- The document check still reports only the two existing k23 archive targets.
- The consuming documents and the k125/k126 handoffs agree with the derivation
  after integration.

## Notes
Design documents only. No VM, native experiment, implementation or cap
expansion. K124 and all ancestors remain open after this leaf.

## Decisions (running log)

- 2026-11-01: Adopt k136 at clean parent 9669618d. Read k135's findings from that commit and inspect both k132 changes.
  Use Tier 2 graph evidence at generation 2026-11-01T04:50:22Z, with direct reads for partial shell and diagram coverage.
  The glossary's existing semicolon receives a separate preparatory prose change.
- 2026-11-01: Finding 1 identifies a real overestimate in the tick capacity derivation.
  Prepare a bound on time without a live tick, while retaining the existing elapsed-time envelope and admission deadline.
  Spend the one narrow reviewer on that timing argument and the new explicit-wait cross-check.
- 2026-11-01: Finding 2 identifies an unclear contract. Keep the existing carrier schedule.
  Label fence-only fallback capacity as deliberate over-reservation, without authorising an additional publication.
- 2026-11-01: Findings 3, 4 and 6 identify unclear contracts.
  Assign each missing input to k125 or k126. Enumerate the existing parameter vector and define the shared accounting vocabulary.
- 2026-11-01: Findings 5 and 7 identify real documentation gaps.
  Add baseline explicit-wait envelopes from the unchanged helper bounds. Identify 120/142 seconds as the earlier shared start target.
  No counted operation, wait, image, capacity or runtime authority changes.
- 2026-11-01: The narrow timing reviewer reports no findings after direct source checks.
  It checks the six-second admission contribution outside live ticks and the E/A wait envelopes of 374.4/2111.2 seconds.
  Apply finding 1's tighter count. Retain unknown local/control bounds and the unchanged full admission deadline.
  No second reviewer is needed for this integration.
- 2026-11-01: K136 was k124's last live child, but the exact caller/collection expansion remains missing.
  Add settings-keepalive-caller-workload-k137 under k124 to preserve that concrete design work before retirement.
  K125 retains external evidence scopes. K126 retains final numerical fit and whole-design reconciliation.
  No ADR is earned by these corrections to existing contracts.
- 2026-11-01: All seven findings have applied dispositions. The consuming documents, schema and diagram captions agree.
  Parameter, wait-arithmetic, manifest and prose checks pass. Their negative controls reject the intended omissions.
  The document task reports only the two known k23 archive targets. The browser renders the revised accounting diagram.
  The integration-verification.json receipt retains the checks, subject hashes and probe source.
  Separate preparatory commits convert existing glossary and brief prose before this integration commit.
  Retire only k136. K137 remains live, so k124 and every ancestor remain open.

## Review dispositions

| K135 finding | Classification and disposition |
|---|---|
| 1. Tick bound | Real issue, applied. Bound time without a live tick for tick sizing. Keep the full elapsed-time envelope and unchanged admission deadline. |
| 2. Fence-only fallback | Unclear contract, applied. Preserve the carrier schedule and identify the extra fence-only capacity as deliberate over-reservation. |
| 3. Missing-input owners | Unclear contract, applied. Assign every row to k125 or k126 and reconcile their handoffs. |
| 4. Parameter-vector count | Unclear contract, applied. Enumerate all 29 positions, with one combined receive/parser/scan memory value. Check this vector separately from record-kind counts. |
| 5. Explicit waits | Real gap, applied. Include menu/click sleeps and source-grounded E/A baseline envelopes. Preserve all missing non-wait costs. |
| 6. Shared vocabulary | Unclear contract, applied. Define due, charged and published ticks, publication/fallback carriers, writer lane and start family in CONTEXT.md. |
| 7. Start target | Real stale wording, applied. Identify 120/142 seconds as the earlier shared target and preserve the dedicated unresolved start family. |
