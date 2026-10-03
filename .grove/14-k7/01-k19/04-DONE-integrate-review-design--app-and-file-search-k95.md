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

## Decisions (running log)

Read the findings from review commit `fe3283486341`, anchored to producer
`e6f5f16c7980`; the working copy began empty on that review. Tier-2 graph project
`Users-antony-Development-Koine.add-plugins-for-modaliser-requirements` is ready
but its generation remains `2026-09-29T10:36:20Z`. Resolution.swift has matching
metadata; ProviderContribution.swift has changed, conformance/workspace paths
are missing from that generation, and docs are excluded. Current source and
documents, rather than stale graph snippets, establish the affected contracts.

S1 and S2 are real issues. The diagnostic count alone can prevent later default
roots being visited, regardless of the precise local counts; the default roots
and no-symlink-target rule cannot discover Finder/Safari at the review's stated
locations. Fixing default discovery and proving useful coverage requires a
producer design, not an unreviewed mechanism change here. Externalize that work
before planning. Coordinate any proposal to weaken the agreed application/home
coverage with the existing `protected-home-search-k93` decision; arbitrary
bounded samples are not accepted by this integration.

S3 and S5 are real issues. Current `ProviderFailure.osPermission` explicitly
means missing named consent, and current mapping permits an empty name through
the public nil constructor. The proposed minor-2 combination both changes that
meaning and leaves validation combinations unspecified. The enduring ABI choice
has a real schema-level alternative and passes the ADR test. Externalize the
diagnostic choice and its ADR/complete mapping contract as a producer design
before planning. Until it is reviewed, the proposed feature is not a framework
implementation dependency and its old/new binary recipe must not be cut.

S13 is a contract stated unclearly. Add the search-specific domain, coverage,
progress, prompt-risk and location meanings to CONTEXT.md now. They describe
observations and policy, not consent absence, an atomic inventory or a pinned
resource reference.

S4 is a contract stated unclearly. For no-progress results, real native/work
failure wins, then any prompt-risk scope produces BLOCKED, then purely
absent/excluded roots produce DEPENDENCY_UNAVAILABLE. A prompt-risk/absent or
prompt-risk/unsupported mixture does not invent a native failure. Coverage
continues to expose every individual cause; the pending diagnostic producer
settles how BLOCKED is transported without changing this precedence.

S6 is a contract stated unclearly. Keep the action-only SDL and version pins
against a named compatibility host containing the independently retained
workspace 1.0.0/schema 1.0.0 bundle. The current search-serving application must
have a separate exact search-required profile with its own candidate pins.
Neither a subset comparison nor editing the historical expected SDL proves
compatibility. Planning supplies that host and extends the profile matrix.

S7 and S8 are real issues, externalized with S1. The existing extents cannot
honestly coalesce child exclusions/unrepresentable names; the shared value
budget has no arbitration rule. Coverage representation and resource scheduling
must be redesigned together, with exact scope semantics, diagnostic reservation
and match-versus-diagnostic priority. Changing enum labels alone here would not
repair the default-search sampling problem.

S9 is a contract stated unclearly. A positively absent optional *default* home
Applications root has an empty eligible domain: retain its coverage object as
COMPLETE with an explicit OPTIONAL_ROOT_ABSENT intrinsic diagnostic. It makes
no progress. Explicitly supplied missing roots keep ROOT_NOT_FOUND/UNKNOWN,
and uncertain/inaccessible defaults are never treated as absent.

S10 is a real issue. Retain positively unregistered application bundles as
UNREGISTERED matches, preserving known identifiers for copy and paths for reveal.
Only INSTALLED can form a launch choice; UNKNOWN continues to represent failed
or missing metadata, affecting coverage. Known registration absence is explicit
data and does not fabricate an inspection failure or hide the candidate.

S11 is a visible trade-off stated incompletely. The four-worker admission pool
is process-wide for workspace search, including every alias and provider
instance. Provider stop/start never replenishes blocked capacity. Finishing
native work releases its slot; a permanently blocked set needs a full Koine
process restart. Cancellation does not kill native threads or free descriptors
still in use. No fair-share service guarantee is claimed; acceptance separates
normal slot recovery from deliberate permanent saturation and process restart.

S12 is a contract stated unclearly. Match application queries against the raw
filename and its stem after removing exactly one terminal .app extension;
rank by the better tier, so Zed.app precedes Zed Preview.app for "zed" and
".app" still matches filenames. File queries keep the full filename. Fold
query/candidates to canonical Unicode normalization, fixed POSIX case/diacritic
folding, then canonical normalization; canonically equivalent spellings must
match. Returned names/paths and raw tie-breakers retain their original spelling.

Spent the one narrow in-session reviewer on repaired outcome/coverage,
optional-default absence, registration handoff, rank keys and process-wide pool
recovery, with artifact/contract only. Its one finding is a contract stated
unclearly: home cannot be COMPLETE under policy, but is PARTIAL only after
progress and UNKNOWN otherwise (for example a denied home listing). Corrected
the spec/SDL wording. No other concrete counterexample was reported in that
scope; this is not review of the two pending producer decisions, and no second
reviewer is warranted for this wording repair.

Externalized the substantive work as `search-coverage-k96` (S1/S2/S7/S8) and
`search-permission-transport-k97` (S3/S5), beside this integration and before
planning's ancestor sibling. Each producer owns its fresh review chain; neither
choice is claimed settled here. Updated k93 so any reduced application/home
coverage is an explicit human decision there, including work-bound omissions.
The integration reaches its reviewable boundary with all thirteen findings
classified; six require those live producer decisions, six have applied repairs,
and S11 is the stated process-restart/fairness trade-off.

Final verification: `task design:search-check` passed independent/composed search
SDL and both examples, existing action examples, and the removed-root,
wrong-input/unknown-output and foreign-type negative controls. `task
design:search-render` regenerated all three exports; coverage and handoff light
SVG rasterizations were inspected without clipping. Architecture discussion IDs,
source/export paths and local links in the six affected Markdown documents
resolve. A direct Foundation check confirms canonical-equivalent spellings,
Zed's exact tier before Zed Preview's prefix and the `.app` filename match.
Frozen before/after SHA-256 subjects match: Taskfile, search/action/desktop SDL,
search/action examples, three D2 sources and client package/lock files. These
checks establish document/schema consistency, not runtime, native acceptance,
useful default coverage or an ABI guarantee. No production code, provider build,
VM acceptance or signing posture changed. Parent k19 stays open on k96/k97;
there is no node-close cascade to promote in this integration.
