# long-search-result-actions-k168

**Integrates:** long-search-result-actions-k166

## Goal

Triage every finding from the load-bearing review of the v1 long-location
action design and apply the real design corrections before implementation
planning. Preserve Antony's settled v1 refusal and descriptor-relative access
decision.

## Context

- Review long-search-result-actions-k166: its findings and evidence are anchored
  to producer commit `21809e6b3a00` (final design session long-action-route-k165).
  Read that review, rather than treating this charter as a transcription.
- The action spec's long-location boundary and
  `docs/adr/filesystem-access-is-descriptor-relative.md`, with their current
  SDL, search handoff, guide, glossary, trace, editable architecture views and
  recorded native evidence.
- The retained provider sources/tests supply the established short-path and
  dependency meanings. The review ran no tests or native experiments and
  changed none of those sources or design artifacts.
- Next consumer long-location-actions-k167 is planning in this directory;
  search consumers k123/k120/k30 follow the reviewed/reconciled contract.

## Done when

- Every finding is classified with evidence. Apply actionable corrections and
  explain dismissed, clarified or accepted-trade-off items in the running log.
- Reconcile the design's affected current-state artifacts and exact SDL
  descriptions without changing public shapes, capabilities, enums or the
  independent 1.0.0 / action-repair 1.0.1 / search 1.1.0 profile contract.
- Preserve accepted short-path outcomes, unchanged selected inputs and copy
  constraints, truthful cause/fact distinctions, native acknowledgment and
  optional receipt meanings, grant/deadline/cancellation/no-replay obligations,
  independent action versus actual-search subjects and the first-use prompt
  acceptance condition.
- Verify the corrected design using applicable existing deterministic tasks.
  Update planning's acceptance subjects where the triage requires it. Native,
  binary, public runtime and signed-VM repair acceptance remains planning's.

## Notes

This is design integration, not implementation or a new native investigation.
No hand-off workaround, shorter search ceiling, consent/signing/private-policy
change or long-path application support is authorized. If substantial redesign
earns a new producer/review chain, place it ahead of k167 under Grove's normal
integration procedure; do not silently transfer an unresolved design into
implementation planning.
