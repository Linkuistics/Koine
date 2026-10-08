# search-permission-transport-k97


## Goal
Settle a compatible transport for search's known prompt-risk BLOCKED outcome
without reinterpreting the framework's fixed missing-named-consent failure.
Record the enduring diagnostic decision and rejected alternative in the ADR set
before implementation planning depends on it.



## Context
- `app-and-file-search-k94`, review commit `fe3283486341`, anchored to
  `e6f5f16c7980`; `app-and-file-search-k95` contains the integration triage and
  withdraws the previous nil-consent minor-2 mapping as an implementation rule.
- `docs/specs/workspace-search.md#coverage-and-aggregate-outcomes`,
  search SDL/examples, Machine's error/ABI tables, workflow all-blocked rule,
  client guide, coverage/handoff views and `task design:search-check`.
- `docs/adr/resilient-provider-framework.md`,
  `docs/adr/provider-authority-follows-effects.md` and
  `docs/adr/first-party-provider-selection.md`; rework the minimum coherent set
  rather than appending a superseding record.
- Current source: `ProviderAPI/Sources/KoineProviderAPI/Resolution.swift` fixes
  osPermission as missing named consent, with a public nil-capable constructor;
  `Sources/KoineCore/ProviderContribution.swift` currently maps nil to an empty
  consent string. Read current source, not the stale graph generation.
- `search-coverage-k96` owns mechanism/resource representation, not this ABI
  choice. `protected-home-search-k93` owns any new consent/setup decision;
  `protected-default-open-k89` and `reveal-app-bundle-notice-k90` stay separate.

## Done when
- Compare schema-level BLOCKED data/null matches/coverage against a compatible
  new diagnostic mechanism. State how observed absent consent differs from
  prompt risk with UNKNOWN consent, what clients show, and why the chosen route
  is worth its enduring cost. Existing version-1 cases/meanings remain fixed.
- If framework symbols/features are chosen, define the complete validation and
  mapping matrix for every existing failure kind, nil/blank/named consent,
  nil/blank/nonblank target and reason, recognized/unknown reason and declared/
  undeclared feature. Include named-consent failures with targets/reasons and
  failures of other kinds carrying the new accessors. State legacy nil/blank
  behavior and malformed-provider diagnostics, and required version/feature
  refusal before loading. Do not assume old public values were unconstructible.
- If schema-only transport is chosen, remove unused ABI proposal references,
  amend the workflow premise explicitly and specify error-free BLOCKED branch
  invariants; do not label UNKNOWN consent as observed denial or healthy empty.
- Preserve repaired no-progress precedence: real native/work failure, then any
  prompt risk, then pure absence/exclusion. Mixed successful roots remain
  AVAILABLE with exact per-root diagnostics. Coverage-only/aliased matches and
  publication-revocation behavior have concrete acceptance expectations.
- Reconcile ADRs and their citations, spec/SDL/examples, Machine/framework and
  workflow contracts, client guide, glossary and architecture captions/exports.
  Name exact compatibility-host/profile subjects and independent old/new binary
  obligations only for the chosen design. No new consent/signing posture or
  incompatible contract-version change is silently introduced.
- Run the design checks/rendering and cut this producer's load-bearing
  `review-design` at the last work act under this parent, using the bare stem
  and `**Reviews:** search-permission-transport-k97`. Both repair/review chains
  must finish before `app-and-file-search-k30` cuts implementation.

## Notes
This is a design/ADR producer, not a framework implementation leaf. Keep current
desktop/action mappings as the compatibility baseline. A new consent or setup
is neither necessary nor approved merely to represent a blocked read policy.

## Decisions (running log)

- Choose schema-level BLOCKED with successful null matches/dependency and exact
  coverage. UNKNOWN consent reports unattempted prompt-risk policy, never observed
  denial. The existing ProviderValue success/null path suffices; no diagnostic
  framework symbols, feature or minor are needed. A new structured failure would
  impose permanent cross-kind validation and old-host refusal for no extra search
  information. Record this independent decision in the minimum coherent ADR set.
- Keep observed missing named consent on the existing permission-error route.
  Preserve no-progress precedence (real native/work failure, prompt risk, pure
  absence/exclusion), AVAILABLE after any progress, and normal publication denial.
  Coverage-only selections must describe BLOCKED without errors; every aliased
  BLOCKED matches selection returns null without an error or another native read.
- Verify against current source: framework osPermission permits public nil/blank
  construction; the adapter maps nil to an empty string and retains blank strings.
  Search must not use either as prompt risk. Other kinds ignore permission;
  unknownResolver reports resolverMismatch. This design preserves that baseline.
- Design the first search provider/schema as additive 1.1.0 on the existing
  framework-1.1/features contract. Name workspace-actions-1.0-compatibility,
  workspace-actions-1.0-upgraded-core and workspace-search-1.1 as distinct binary
  subjects. Preserve the exact old action profile/SDL and catalogue baseline;
  require a separate exact search profile plus its per-user-selected variant.
  Existing fixture update 1.1.0/schema 1.0.0 remains separate from search 1.1.0.
- Use the mandated tree review as the fresh-context instrument under Grove and
  doubt-driven-development; no in-session reviewer ran. Implementation planning
  consumes both repair reviews, never this producer alone. New consent/setup,
  default opening, app reveal and bound-driven home acceptance stay live elsewhere.

## Verification

Tier 2 graph project is Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
generation 2026-09-29T10:36:20Z. Discovery found ProviderFailure and the adapter;
its trace is heuristic/stale rather than current authoritative evidence. Coverage
reported the current adapter/Authority/Engine changed, docs excluded and Engine
parse gap 295. Read current Resolution.swift, ProviderContribution's complete
registration/mapping path, Authority's domain errors, Engine's error/publication
path and the reported gap directly. No exhaustive graph claim was made.

Design SDL/example and documentation-link checks passed on frozen subjects;
negative schema controls rejected removed search, wrong input/unknown field and
foreign-provider type. D2 0.9.0 regenerated the search exports. Safari in isolated
macOS 26.5/25F71 inspected coverage/handoff fresh deep links and wide light views,
dark discussion/outline and 800-pixel reflow. Manifest and both changed SVGs were
digest-identical in the guest. SVG images remained light inside the dark shell.
These checks do not establish runtime branch invariants, new binary pairs or
native search/no-dialog acceptance; the spec's three-seam obligations stay pending.
