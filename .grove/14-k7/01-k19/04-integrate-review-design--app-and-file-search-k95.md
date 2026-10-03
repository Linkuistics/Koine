# app-and-file-search-k95

**Integrates:** app-and-file-search-k94


## Goal

Triage the findings of `app-and-file-search-k94` against the application/file
search design from `app-and-file-search-k92`. Apply the real ones to the design
artifacts so `app-and-file-search-k30` cuts implementation from a settled
contract.

## Context

- The review's findings are in its own leaf and commit, anchored to producer
  commit `e6f5f16c7980`. Read them there. This charter deliberately does not
  restate them.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/design/workspace-search-{schema,operations}.graphql`, the search rows of
  `docs/specs/workflow-providers.md`, the search notes in `docs/specs/machine.md`
  (error extensions and the framework interface), `docs/specs/workspace-launch-and-open.md`'s
  search paragraph, `docs/client-guide.md`'s search section, and the coverage and
  handoff views in `docs/design/architecture/` with their README captions and
  `task design:search-check` controls.
- Some findings touch shared contracts rather than only the search spec. These
  are the framework `ProviderFailure` meaning and minor-2 accessors, Machine's
  error extensions and failure table, the workflow spec's all-blocked rule, and
  the exact-SDL conformance profiles. Keep any change consistent with
  `docs/adr/provider-authority-follows-effects.md`,
  `docs/adr/resilient-provider-framework.md` and
  `docs/adr/first-party-provider-selection.md`, and reconcile the ADR set if a
  decision earns a record.
- `protected-home-search-k93` holds Antony's protected-home decision.
  `protected-default-open-k89` and `reveal-app-bundle-notice-k90` keep their own
  decisions. Do not resolve any of them here. Coordinate any new human question
  with k93 instead of opening a conflicting one.

## Done when

Every finding of `app-and-file-search-k94` is accepted and applied, accepted as
a stated limit, or rejected with its reason in this leaf's running log. Applied
changes leave the spec, SDL, examples, shared contracts, views and design checks
mutually consistent. Any finding that needs Antony's decision, such as a change
to the agreed search coverage, is raised with him through the existing live
decision or a new one rather than settled by inference. Implementation and
native acceptance remain planning's work.

## Notes

The review read source and platform state directly, without running checks or
the adapter. Its numbers for one Mac's directory counts are inspection evidence
for a design bound, not acceptance measurements. Re-run `task design:search-check`
and `task design:search-render` after changing the SDL or views.
