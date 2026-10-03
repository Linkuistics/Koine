# search-permission-transport-k99


**Reviews:** search-permission-transport-k97

## Goal

Read the committed prompt-risk transport design adversarially before search
implementation planning. Find where its schema-data outcome, compatibility
promise or shared all-blocked premise fails the agreed read/coverage contract.
This is inspection only: findings and trade-off judgments, not fixes or runtime
acceptance. A producer preference is not an approval the reviewer must preserve.



## Context

- Locate the producer commit by search-permission-transport-k97 and read its
  full diff against the current artifact. search-coverage-k98 runs earlier and
  may have an intervening integration; reconcile shared schema/spec changes
  deliberately rather than treating the producer's coordinates as current.
- docs/specs/workspace-search.md, especially selection/publication invariants,
  extension-only diagnostics and compatibility subjects; search SDL/examples,
  Machine's provider-failure compatibility table, workflow all-blocked premise,
  client guide, glossary and architecture coverage/handoff sources, exports,
  captions, current-discussion panel and README.
- docs/adr/prompt-risk-is-search-data.md and the reworked resilient framework
  record; existing effect-authority and first-party-selection ADRs remain binding.
  Judge this as a minimum coherent current-state set, not a chronology.
- Current ProviderAPI/Sources/KoineProviderAPI/Resolution.swift permits public
  nil/blank failure construction. Sources/KoineCore/ProviderContribution.swift
  maps nil osPermission to an empty string; Authority.swift and Engine.swift
  supply error classification and original paths/publication checks. Read current
  source before judging the documented compatibility table.
- Existing action-only profile is
  docs/design/profiles/core-desktop-workspace-extension-host.json against
  docs/design/desktop-workspace-schema-extension-host.graphql. The retained
  workspace-actions-1.0-compatibility host, dedicated upgraded-core compatibility
  host, new workspace-search-1.1 host and exact search-required profile/variant
  are specified subjects/obligations, not new passing binary evidence here.
  Selection-update fixture 1.1.0/schema 1.0.0 remains a distinct subject.
- protected-home-search-k93 owns new consent/setup or acceptance of partial
  home/bound-driven omissions; protected-default-open-k89 and app-reveal notice
  remain separate. No new consent, usage key, entitlement or incompatible public
  contract version is approved by this diagnostic decision.

## Done when

Challenge schema-only BLOCKED against a compatible new framework diagnostic:
does status/coverage/null matches give clients a coherent failure distinction,
including clients selecting no matches? Is the permanent schema obligation
weighed honestly against framework kind/consent/target/reason validation and
pre-load compatibility cost? UNKNOWN consent must never become observed denial,
Accessibility or healthy empty, and osPermission's fixed meaning must survive.

Check both search roots with wholly protected scope, prompt risk plus missing/
unsupported roots, prompt risk plus actual access/native/work failure, pure
absence/exclusion, optional absent defaults, and any ordinary/empty successful
root. Verify no-progress precedence and every root's coverage invariants,
including COMPLETE optional empty-domain coverage without progress. A mixed
AVAILABLE result must retain exact diagnostics without a synthetic permission
error. Check resultsTruncated in each branch.

Trace coverage-only queries, repeated matches aliases and independent Query
aliases through the provider value/error interface. BLOCKED matches must return
ordinary null without errors or new native reads. FAILED must error at every
selected alias with original paths while nullable coverage survives unless
publication denial propagates. Challenge revocation before root and selected
nullable/non-null publication: status never waives denial; permission.kind may
null the nullable permission object while status/coverage-member denial can
propagate to the root. No result invariant is promised on a denied response.

Compare every existing failure kind with nil, empty, whitespace and named
permission to current source, including ignored permission on other kinds,
unknownResolver's diagnostic and legacy malformed semantic values. There are no
new target/reason accessors or diagnostic host feature to validate. Challenge
both independent old/new binary directions, normal sealed catalogues, exact
candidate/version/schema pins, existing pre-load refusal and the distinction
between exact action-only and search-required profiles. Historical profiles must
not be rewritten to certify the new bundled search release; rebuilt copies do
not replace retained subjects.

Check ADR citations and every summary/SDL/example/client/view against the chosen
route and shared workflow exception. Confirm the three agreed seams have concrete
branch/alias/revocation/native expectations while all runtime/new-binary/search
acceptance remains pending. Anchor actionable findings to producer commit and
exact current source/artifact locations; classify trade-offs and unsupported
concerns explicitly rather than requiring every observation to become a fix.

## Notes

Producer Tier 2 graph project:
Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
generation 2026-09-29T10:36:20Z. search_graph found ProviderFailure and the
ProviderContribution.registrations symbol; outbound trace had heuristic edges
and stale locations. Coverage reports docs excluded, current adapter/Authority/
Engine changed, and Engine's missed parse line 295. Producer used current source
for the full registration/failure mapping, domain errors, publication/error path
and the reported gap. No graph completeness or current authoritative chain was
claimed. Confirm project/generation and check all relied-on paths; read stale,
untracked/excluded scopes and missed ranges before new source claims.

No in-session reviewer ran: this mandated leaf supplies the fresh context under
Grove/doubt-driven-development. Final task design:search-check and task check:docs
passed on item-by-item unchanged subjects; negative schema controls failed as
intended. D2 0.9.0 regenerated exports. Isolated macOS 26.5/25F71 Safari checked
fresh coverage/handoff links, readable wide light views and wide/800-pixel dark
discussion/outline. Manifest/changed SVGs matched guest/workspace digests; SVGs
remained light inside the dark shell. None is runtime or binary acceptance.

Both search repair/review chains must retire before app-and-file-search-k30 cuts
implementation. If findings warrant integration, cut it at this review's
directory-local sequencing boundary and pass this review's handle, not findings
copied into an integrating charter. No Creator line is supplied because this
producer's environment had no HARNESS_DISPATCH_RUN_ID.

## Findings

Anchored to producer `7e1b0124f163` (`search-permission-transport-k97`).
Coordinates are the current working copy at `44233e3defc0`, after
`search-coverage-k98`, `search-coverage-k100` and `search-defaults-k101`. Those
later commits left k97's BLOCKED text unchanged; they add root-refusal cases
that bear on T4. `spec` is `docs/specs/workspace-search.md`. Source claims rest
on direct reads of current files. The graph (generation 2026-09-29T10:36:20Z)
marks ProviderContribution/Authority/Engine changed, Engine 295 parse-partial,
and `scripts/` excluded.

### T1 — Search 1.1.0 keeps "existing required features", so the new-provider/old-host subject is refused before it loads (medium-high)

spec:447-449 publishes workspace 1.1.0 "retaining … existing required features".
spec:889-891 installs that bundle as a per-user update on the retained host.
spec:896 expects it "Loads under its existing minimum minor/features". The
bundle's existing features are `additional-capabilities-v1` alone
(`Providers/WorkspaceProvider/manifest.json:10`, `Logic/WorkspaceProvider.swift:46`).
machine.md:1233-1238 requires every newly published first-party update to
declare `first-party-selection-v1`. An extension host refuses a per-user
shipped-identity candidate without it (`INCOMPATIBLE`/`selection-feature-required`),
as `verify-selection-updates.py:656-669` already asserts for workspace.

Built as worded, the required row-896 pair refuses the bundle, and the bundled
1.0.0 runs. spec:897 and machine.md:966-968 attribute 0.1.0's refusal partly to
an "existing" `first-party-selection-v1` requirement the bundle does not have.
That refusal still holds through framework `minimumMinor: 1` and
`additional-capabilities-v1`. Smallest correction: state that the 1.1.0 manifest
and descriptor declare both features, and correct the "existing" wording in
spec:449, 896-897 and machine.md:966-968. This is an existing host-selection
feature, not a diagnostic one.

### T2 — The "pinned" selection/conformance subjects are rebuilt from this tree and collide with the search release (medium-high)

spec:872-874 says existing selection-update hosts/profiles "remain their own
pinned subjects", and spec:882-883 forbids changing the action-only profile/SDL.
The current subjects are built from this tree, not retained:

- `scripts/build-selection-real.sh:12-24, 97-120` builds `current-workspace`
  from this tree as release 1.0.0. Its "newer" update is a copy of this tree
  with the release edited to `1.1.0` (line 120). A substitution must find the
  literal `requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature]`
  (lines 107-109), or the build exits.
- `scripts/verify-selection-updates.py:619-650` runs the production host with
  this tree's workspace under `core-desktop-workspace-extension-host.json`,
  pinned to 1.0.0 BUNDLED. It expects the 1.1.0 PER_USER update to be selected.
- `Tests/KoineServerTests/SchemaConformanceTests.swift:397-406` requires this
  tree's workspace to compose exactly to the action-only SDL and digest, and
  lines 629-660 pin workspace 1.0.0. `scripts/vm-verify-conformance.sh:39`
  holds the signed app to the same profile.

After search lands, each of these fails. The only edit that keeps them green is
the forbidden profile/SDL rewrite. The update fixture also stops working: by
machine.md:1250-1252 and 1268, a per-user copy at 1.1.0 equals the bundled
search 1.1.0 and never overrides it. If T1 is fixed in source, the substitution
fails too. Smallest correction: name each tree-bound check, and say which
moves to the new search-required profile and which runs only against retained
pre-search binaries. Re-version tree-built update fixtures above 1.1.0 with
schema 1.1.0 and new search-update profiles. Moving a check to a new profile is
not a rewrite of the historical one.

### T3 — Generic consent-error summaries still promise `accessibility` and a `permissionTarget` extension the framework cannot carry (medium)

k97's compatibility text (machine.md:946-961, client-guide:412-415) says an
`os-permission` error can carry `osPermission` as `""`, whitespace or any
provider string, and that clients never synthesize Accessibility from it. The
summary layer still says otherwise:

- machine.md:527-529: "OS errors identify `accessibility`".
- client-guide:271: `osPermission` "is `accessibility`".
- client-guide:312-314: send every `os-permission` to Accessibility consent.

machine.md:537-540 and client-guide:297-300 also design an optional
`permissionTarget` error extension for new operations. `ProviderFailure` has
only `permission` (Resolution.swift:70-74), and Engine.swift:555-558 emits only
`permissionClass`/`osPermission`/`permissionOwner`. k97 itself says targets
cannot be attached to ProviderFailure (machine.md:963-964) and that permission
extensions do not change (machine.md:561-562).

So a client following the guide's table labels a legacy `""` as Accessibility.
A later increment that plans on `permissionTarget` finds no transport for it.
Correction: limit `accessibility` to the desktop operations' served value, and
point generic handling at the compatibility table. Either drop `permissionTarget`
from the error extension or mark it as needing a future framework minor/feature
with the full validation matrix before any operation relies on it.

### T4 — No-progress precedence never classifies a changed or refused root, so BLOCKED versus FAILED is undetermined (low-medium)

FAILED needs "actual native failure, timeout/capacity refusal or unrepresentable
root". DEPENDENCY_UNAVAILABLE needs missing, not-a-directory or
excluded/unsupported roots (spec:350-358). BLOCKED's invariant says every root
records a "blocking/absence/exclusion cause" (spec:384-386). A no-progress root
whose identity changes between canonicalization and open (CHANGED_DURING_SEARCH,
spec:798-802) is in none of these classes. Two more root refusals are unclassed:
k101's Cryptex "Changed identity/mount refuses" (spec:158-159) and "uncertain
resolution refuses inspection" (spec:146), which also name no reason.

`[Desktop, root replaced during open]` can therefore be BLOCKED, with no matches
error, or FAILED, with an error at every alias, and both read as conforming.
Correction: give each reason that can occur on a no-progress root a precedence
class (failure, prompt risk, or absence/exclusion), and add the changed-root
case to spec:899. The Cryptex admission rule itself belongs to k102; only its
outcome class is at issue here.

### T5 — The BLOCKED invariant's error exemptions omit the provider-lifecycle error at nested fields (low)

Every nested result field goes back through `ProviderLifecycle.resolve`
(ProviderContribution.swift:154). A stopped provider answers `unavailable`,
"The workspace provider is not running." (ProviderLifecycle.swift:64-71). The
invariant (spec:379) and acceptance row (spec:898) exempt only authorization,
input, deadline/response-limit and publication errors. On nullable `matches`,
that error leaves a surviving BLOCKED status beside an execution error, which
the row calls impossible. Correction: word the exemption as "absent any
execution error at or above the field", or list the lifecycle case.

### T6 — The glossary equates per-scope prompt risk with the aggregate BLOCKED outcome (low)

CONTEXT.md:154-156 says search "describes [prompt risk] as **Search policy
blocking**". In an AVAILABLE result, prompt risk appears only as PROMPT_RISK
skipped scopes. Search policy blocking (CONTEXT.md:158-160) is the no-progress
aggregate. Correction: search reports prompt risk as a PROMPT_RISK skipped
scope, and the aggregate is Search policy blocking only when no root progressed
and nothing failed.

### T7 — The framework ADR carries a search-specific "did not change me" note that duplicates the prompt-risk ADR (low)

resilient-provider-framework.md:15-18 records that search's outcome "do[es] not
add framework symbols/features". That is a chronology entry about another
decision. Its nil/blank-sentinel sentence repeats prompt-risk-is-search-data.md:27-31.
The framework-level rule is fixed failure meanings, with constructible values
keeping their legacy mapping. That rule fits there without the search back-link,
which leaves one record owning the search rationale.

### Trade-offs and unsupported concerns (no change requested)

- **Enum evolution.** `consentState { UNKNOWN }` and
  `permissionReason { PROMPT_RISK }` are single-valued output enums. The deferred
  named-consent extension (spec:437-439) would add values, and the contract does
  not say whether adding output enum values is compatible (client-guide:72-74
  is silent). The ADR's cost statement omits this. It is a visible deferral,
  not a defect now.
- **Mirrored vocabulary.** `PERMISSION`/`OS_PERMISSION`/`KOINE` in coverage
  invites generic os-permission presenters. `consentState`, `permissionReason`,
  null `osPermission` and the explicit client copy mitigate this. The choice
  dates from k92/k95.
- **Matches-only and error-only clients.** BLOCKED and DEPENDENCY_UNAVAILABLE
  are both error-free nulls, so status must be read. A mixed AVAILABLE `[]`
  needs coverage. Both are the ADR's stated enduring obligation, and the
  rejected framework failure would have changed neither the mixed case nor
  unselected matches. The weighing is honest: a new failure kind would need
  minimum-minor pre-load refusal (machine.md:1009-1011), giving up the
  new-provider/old-host direction.

### Checked and holding

- **Failure-mapping table** (machine.md:936-969) matches current source row by
  row. Nil becomes `""` (ProviderContribution.swift:164-167). Blank and named
  values pass through untrimmed. `unavailable`/`failed` ignore `permission`.
  `invalidInput` becomes a path-only input error (line 168, Engine.swift:549-551).
  `unknownResolver` gives `resolverMismatch` plus a fixed failed message (lines
  169-176). An unknown future kind falls back to failed (line 177). Public nil
  construction exists (Resolution.swift:74-79).
- **Aliases and publication.** Every field is registered (Engine.swift:500-503)
  and receives the parent value, so repeated `matches` aliases project one root
  result. Pre-resolution checks (514) and read republication (525-528) give
  root admission denial with no work, nullable `permission`, and non-null
  status/coverage propagation to the root, as spec:399-410 states.
- **Branch matrix.** Wholly protected roots, prompt risk plus missing or
  unsupported, prompt risk plus access/native/time failure, pure absence, and
  ordinary/empty plus protected are consistent across spec, SDL, examples,
  client guide, workflow exception, glossary and both views.
- **`resultsTruncated`.** False for BLOCKED as stated, and necessarily false for
  FAILED/DEPENDENCY_UNAVAILABLE, because no progress means no finalized match.
- **Optional absent defaults.** The COMPLETE optional-absent BLOCKED case exists
  only for application search with omitted roots, under a controlled adapter,
  which spec:904-909 provides.
- **Citations and views.** ADR anchors resolve. The SDL/example headers, the
  views and the README describe typed BLOCKED and pending acceptance. None
  claims runtime, binary or native acceptance.

## Decisions (running log)

- Resolved the mandate to this leaf. Read the brief chain, the producer diff
  `7e1b0124f163`, and the later k98/k100/k101 changes to the shared files.
  k101's root-refusal additions feed T4, and nothing in them weakened k97's text.
- Read current Resolution.swift, ProviderContribution.swift, Authority.swift,
  Engine.swift (including line 295), ProviderLifecycle.swift, the workspace
  manifest/descriptor, the selection/conformance scripts and SchemaConformanceTests
  directly. Confirmed graph project/generation and coverage. No graph-completeness
  claim is made.
- Seven findings. T1-T3 are worth integrating before planning. T4-T7 are cheap
  clarifications in the same files. Cut `integrate-review-design` with this
  handle at the directory-local boundary, ahead of `search-defaults-k102`, whose
  review reads the same files. Spent no in-session reviewer, since this leaf is
  the adversarial read.
