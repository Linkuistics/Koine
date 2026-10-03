# app-and-file-search-k7 — brief

## Goal

A client can find installed applications, and files under configured roots,
and act on a selection. Application actions are launch or activate, reveal in
Finder, copy path and copy bundle identifier. File actions are open with the
default application, reveal, copy path and open in Zed.

## Done when

- Installed-application search returns the metadata these choices need.
  File search covers client-specified roots, currently the home directory.
  Results are bounded and ordering is stated; MRU ordering stays client-owned.
- An unavailable search mechanism, such as a disabled or missing index, is
  distinguishable from an empty result. Search reaches protected folders only
  as far as Koine's documented permissions allow, and says so.
- Every requested root has explicit complete/partial/unknown coverage, searched
  and skipped scopes and reasons. Partial empty is not complete empty;
  permission-blocked scope retains OS-permission classification, while a missing
  index is a dependency. First access to protected scope must not prompt through
  a read. Define the new consent diagnostics without changing desktop fields;
  raise any new consent/entitlement with Antony before relying on it.
- Selections act through `launch-and-open`'s operations. Clipboard writes
  follow `provider-architecture`'s allocation.
- Authority, trace rows and VM acceptance as in `launch-and-open`.

## Decomposition

1. `design` — the mechanism, with a bounded VM evidence check, and the API.
2. `planning` — cut implementation leaves.

## Notes

The search design is `docs/specs/workspace-search.md`, with the separate additive
`docs/design/workspace-search-schema.graphql` and client examples beside it.
Every search root/output field needs workspace read only; existing action
receipts keep both controls. Planning consumes the design reviews and producer decisions before cutting
implementation. The revised discovery contract has fixed-region Preboot admission
without read-only dependence, depth-first held streams with cyclic root turns and
reserved root depth counts, and canonical target names/paths ranked independently
of link/direct discovery routes. Native bundle identity merges one app installation
while separate copies sharing an identifier stay distinct. `search-defaults-k101`
cuts its load-bearing review before planning; real Safari/Finder, protected
Library-link resolution, useful home coverage and descriptor pressure remain
pending. Invalid/overlong children keep actual-parent groups; depth uses one root
group with matchable anchors. Stops use REMAINDER with or without progress.
Prompt-risk transport is reviewed typed BLOCKED success/null data, with k103's
changed/uncertain-root precedence, lifecycle-error exemptions and explicit
verification-consumer migration. Search 1.1.0 declares both authority/selection
features; current search checks/newer fixtures and retained action-only subjects
stay separate, with binary/runtime acceptance pending.
k104's discovery triage reopens traversal order/process descriptor admission in
`search-traversal-k105`, with a mandatory load-bearing review before planning.
DFS loses later shallow home names at the entry budget; root-local descriptor
refusal cannot protect the listener/store/actions. Worker-only cleanup, fresh
parent-location checks, unified canonical paths, charged policy witnesses and
unknown Preboot failure wording are repaired in place with native acceptance
pending. The current stack/descriptor figures are proposal shapes, not safe
process allowances. Fixed framework meanings stay unchanged and no diagnostic
ABI addition is needed.
Preserve action-only conformance against
an independently retained workspace 1.0.0 compatibility host while adding a
separate exact search-required profile for the upgraded host.
`protected-home-search-k93` keeps Antony's partial-home versus explicit-setup
decision live before baseline acceptance, including eventual bound-driven
omissions; arbitrary bounded samples have not been accepted. Default opening and app reveal keep
their existing separate decisions. The mechanism report does not accept the
new stream adapter, arbitrary protected traversal or unsupported volumes.

This extension deliberately lifts the desktop contract's exclusions of
non-running applications and broad discovery for these workflows only.
`provider-architecture` records the reconciliation this node relies on.
