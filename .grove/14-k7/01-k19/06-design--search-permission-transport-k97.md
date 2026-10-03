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
- `docs/specs/workspace-search.md#extension-only-permission-diagnostics`,
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
