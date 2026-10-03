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

## Decisions (running log)

- Read k99's findings from its commit `9694eb72`, anchored to producer
  `7e1b0124f163`. Tier 2 graph project matches this workspace, generation
  `2026-09-29T10:36:20Z`. Coverage marks docs/scripts excluded, several current
  sources changed/untracked, and Engine line 295 parse-partial. Read the cited
  current source and the missed range directly; graph traces are discovery aids,
  not a claim of a current exhaustive call chain.
- T1 is a real issue. Search 1.1.0 must declare both
  `additional-capabilities-v1` and `first-party-selection-v1` in manifest and
  descriptor. This uses existing selection support, not a diagnostic ABI feature.
- T2 is a real issue: current build/selection/conformance consumers rebuild this
  tree and pin workspace 1.0.0 or update 1.1.0. Specify their migration to exact
  search-required profiles, a workspace 1.2.0/schema 1.1.0 update fixture, and
  feature edits that do not depend on the old descriptor literal. Keep historical
  action-only profiles/SDL and retained binary subjects unchanged; historical
  profile-model tests remain historical, while current composition/VM checks move.
  Implementation of this migration and independent binary evidence stay pending.
- T3 is a real contract contradiction. Generic OS-permission summaries must
  preserve named/blank legacy values; only served desktop errors identify
  Accessibility. Remove the invented error-extension permissionTarget promise;
  typed search coverage owns its target/reason. Future generic target transport
  needs a separately designed framework/host validation contract.
- T4 is a contract stated unclearly. Classify every skip reason for no-progress
  precedence. Observed root identity/mount change is CHANGED_DURING_SEARCH and
  FAILED; uncertain anchor resolution is INSPECTION_FAILED unless an established
  absence or unsupported classification supplies its own reason. Preserve k101's
  admission predicates for k102 to review; clarify only reasons/outcomes.
- T5 is a contract stated unclearly. Error-free BLOCKED invariants apply absent
  any execution error at or above the selected field, including a stopped
  provider's unavailable error. Add explicit nested-lifecycle acceptance; status
  does not waive execution errors or normal propagation.
- T6 is a contract stated unclearly: per-scope PROMPT_RISK exists in AVAILABLE
  too; Search policy blocking names only the no-progress aggregate.
- T7 is valid ADR maintenance. State fixed framework failure meanings and legacy
  constructible-value mapping in the framework ADR; keep search's ABI choice and
  rationale in the prompt-risk ADR, with no duplicate search-specific note.
- Accept the review's stated trade-offs: matches-only/error-only clients need
  status/coverage, mirrored permission vocabulary is guarded by UNKNOWN/null
  consent and explicit guidance, and future output-enum evolution is deferred
  until its separate extension contract. None establishes new consent or binary
  compatibility. No substantial redesign or in-session reviewer is needed.
- Applied T1/T2 to the release/compatibility contracts, including the four named
  tree-bound consumers and newer workspace update fixtures. Applied T3 to Machine
  and the client guide's generic summaries as well as detailed consent text.
  Applied T4/T5 to spec/SDL/examples, acceptance cases, workflow, client guidance,
  coverage/handoff views and their manifest/README. Applied T6 in CONTEXT and T7
  in the framework ADR; the prompt-risk ADR owns search rationale and explicitly
  defers future enum compatibility. Parent briefs carry the shared-text changes
  forward to k102 without changing discovery/admission predicates.
- Final `task design:search-check`, `task check:docs` and
  `task design:search-render` passed. The schema checks rejected removed-root,
  invalid-input/output and foreign-type controls. An independent AST-to-spec
  check enumerated every skip reason and found exactly one precedence class;
  deleting CHANGED_DURING_SEARCH from the in-memory table failed its control.
  D2 0.9.0 exports were inspected as 1200/900-pixel librsvg rasters: starts,
  outcome/lifecycle labels and action branches are readable without clipping.
  This is static light presentation, not new Safari/dark/reflow/native evidence.
- Frozen subjects are listed with before/after SHA-256 records under ignored
  `.build/k103-design/`: all documentation checker sources, documentation/SDL,
  architecture manifest/sources/exports, profiles, Taskfile, package manifests/
  lockfile and the link-check instrument. Item-by-item comparison was unchanged;
  the checker's actual source enumeration contains no subject missing from that
  manifest. No source/binary migration or historical profile/SDL was changed.
  Independent binary pairs, search runtime/VM acceptance and k102's discovery
  review remain pending before implementation planning; this leaf adds no consent.
- Retirement check: the nearest ancestor still contains live
  `search-defaults-k102`; no parent-chain close or producer-review Creator update
  is due. The transport findings are fully integrated within this leaf's design
  scope, with acceptance obligations left to their existing implementation path.
