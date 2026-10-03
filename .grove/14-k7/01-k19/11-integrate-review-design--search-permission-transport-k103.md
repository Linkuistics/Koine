# search-permission-transport-k103

**Integrates:** search-permission-transport-k99

## Goal

Triage the findings of `search-permission-transport-k99` against the typed
BLOCKED transport and compatibility design from
`search-permission-transport-k97`. Apply the real ones, so that implementation
planning starts from a transport, failure-mapping and compatibility-subject
contract it can build and test without rewriting retained subjects.

## Context

- The findings are in the review's own leaf and commit. They are anchored to
  producer commit `7e1b0124f163`, with coordinates in the working copy after
  `search-defaults-k101`. Read them there; this charter does not restate them.
- Artifact: `docs/specs/workspace-search.md` (outcomes, invariants, permission
  diagnostics, compatibility subjects and acceptance),
  `docs/design/workspace-search-{schema,operations}.graphql`,
  `docs/adr/prompt-risk-is-search-data.md`,
  `docs/adr/resilient-provider-framework.md`, Machine's errors/extension/
  failure-compatibility/selection sections, the workflow exception, the client
  guide's error and search sections, the search terms in `CONTEXT.md`, and the
  coverage/handoff views and README.
- Current source and tooling the review cites: `ProviderAPI/.../Resolution.swift`,
  `Sources/KoineCore/{ProviderContribution,ProviderLifecycle,Engine}.swift`, the
  workspace provider's manifest and descriptor, `scripts/build-selection-real.sh`,
  `scripts/verify-selection-updates.py`, `scripts/vm-verify-conformance.sh` and
  `Tests/KoineServerTests/SchemaConformanceTests.swift`. Read them directly;
  this is a design integration, not an implementation leaf.
- `search-defaults-k102` reviews discovery over the same files next. Keep
  discovery/admission decisions there, and record any shared-text change so it
  can reconcile.
- No new consent, entitlement, usage key, setup or incompatible contract version
  is approved. Historical profiles and SDL are not rewritten to certify the new
  bundled search release.

## Done when

Every finding of `search-permission-transport-k99` is applied, accepted as a
stated limit or trade-off, or rejected with its reason in this leaf's running
log. Applied changes leave the spec, SDL, examples, ADRs, Machine/workflow
contracts, client guide, glossary and views consistent, including their summary
layers. The design checks and rendering tasks pass on frozen subjects, with any
negative control seen failing. Search implementation, binary pairs and VM
acceptance stay pending. Both search repair/review chains must still retire
before `app-and-file-search-k30` cuts implementation.

## Notes
