# application-localized-metadata-k237

**Integrates:** application-localized-metadata-k234


## Goal

Triage the whole-producer review of application-localized-metadata-k215 and
apply the real findings to the private qualification design and its family,
before private implementation and app-and-file-search-k7.

## Context

Read the findings from application-localized-metadata-k234's own commit, not a
restatement here. The reviewed producer is k215 as closed by
application-metadata-qualification-boundary-k236 at `62e3b09e`. Its durable
handoff is docs/specs/application-metadata-private-qualification.md under
docs/adr/application-metadata-qualification-precedes-analytic-fit.md and
docs/adr/application-metadata-accounting-covers-explicit-work.md, with
docs/design/application-metadata-contract.json and
docs/verification/application-metadata-reconciliation.md tying the family together.

The review sat at the grove root, so the root siblings after it were renumbered
by this insert; findings cite live charters by handle. K217/K231 selections and
K235's delegated ordering stand. No helper, consent, signing, ABI, quota, amount
or useful-category change is authorized; a finding that needs one is framed for
Antony with a concrete recommendation, alternatives and evidence rather than
adopted here.

## Done when

- Every k234 finding is classified on its merits — real and applied, a stated
  trade-off, or rejected with a reason — and that classification is recorded.
- Accepted repairs land across the whole affected family, live consumer charters
  and editable/rendered views, with controls that fail on the original defect
  where a pure control can see it. Inputs are frozen before/after any check run.
- Substantial redesign is externalized as a new producer review chain before k7
  rather than absorbed here. Private eligibility, advertisement and consumption
  holds, and every native G/N/V verdict remain as the reviewed design states
  unless a finding's repair changes them explicitly.

## Notes

Design integration only: no reader implementation, native probe, VM work,
launch, registration, signing or consent request. One narrow in-session reviewer
is the most this kind may spend.
