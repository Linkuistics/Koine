# reference-evidence-instrument-k267

**Integrates:** reference-evidence-instrument-k266

## Goal

Triage the findings of review reference-evidence-instrument-k266 against the k249
construction decomposition under k244 and apply the real ones, so the plan is
actionable before reference-evidence-replay-k250 begins construction.

## Context

Read the findings from k266's own commit and its `## Findings` section, not from this
body. Grade each against the committed artifacts: the k249 commit (9563416fcb00), the
complete k244 brief, docs/verification/application-reference-evidence.md and the
canonical permission in application-population-metadata-shape.md. Task files under
k244 may have moved since the review; re-derive coordinates from the current tree.

## Done when

- Every k266 finding is classified as a contract stated unclearly, a real issue, a
  visible trade-off or noise, with the reason recorded in this task's running log.
- Real issues are applied to the construction tree (briefs, leaves, ownership table,
  durable contract where it states the plan) or externalised as new work under k244
  ahead of the affected consumer. Each applied change keeps k244's complete original
  Done when, k245's unused pass and k246/k247's obligations live.
- Where a finding needs a design decision the plan cannot make from the contract, say
  so and ask, naming the trade-off, a recommendation and its evidence.

## Notes

Plan-level only: no instrument, schema, tool, control execution or target contact is
authorized, and nothing here qualifies a tool. A redesign that is real but larger than
a repair becomes a new producer review chain beside this leaf, not an unreviewed
rewrite here.
