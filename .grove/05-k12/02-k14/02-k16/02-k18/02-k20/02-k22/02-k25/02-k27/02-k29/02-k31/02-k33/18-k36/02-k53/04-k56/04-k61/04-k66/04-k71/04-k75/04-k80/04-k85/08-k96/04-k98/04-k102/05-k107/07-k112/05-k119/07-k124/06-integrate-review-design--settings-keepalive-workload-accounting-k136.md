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
