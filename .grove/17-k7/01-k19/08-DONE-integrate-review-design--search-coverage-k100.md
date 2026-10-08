# search-coverage-k100

**Integrates:** search-coverage-k98

## Goal

Triage the findings of `search-coverage-k98` against the discovery, coverage
and resource design from `search-coverage-k96`. Apply the real ones to the
design artifacts so implementation planning starts from a settled discovery
and coverage contract.

## Context

- The findings are in the review's own leaf and commit, anchored to producer
  commit `7653465b1173`; coordinates are the working copy after
  `search-permission-transport-k97`. Read them there. This charter deliberately
  does not restate them.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/design/workspace-search-{schema,operations}.graphql`,
  `docs/adr/search-coverage-describes-observations.md`, the search entries in
  `CONTEXT.md`, the search rows of `docs/specs/workflow-providers.md`,
  `docs/client-guide.md`'s search section, and the coverage/handoff views with
  their README captions, plus the `task design:search-check` controls.
- Evidence the review cites: `docs/verification/search-discovery.md`,
  `docs/verification/protected-path-metadata.md` and its recorded environment,
  and the Safari paths in the launcher and open-URL verification records.
- `search-permission-transport-k97` owns BLOCKED transport, and its review
  (`search-permission-transport-k99`) runs after this leaf over the same files.
  Keep its sections intact unless a finding requires a change, and record any
  such change so k99 can reconcile it.
- `protected-home-search-k93` holds Antony's protected-home and bound-driven
  omissions decision. Any reduction of the agreed application/home coverage
  goes through that decision, not inference here. Default opening and app-reveal
  notice keep their own decisions.

## Done when

Every finding of `search-coverage-k98` is accepted and applied, accepted as a
stated limit or pending obligation, or rejected with its reason in this leaf's
running log. Applied changes leave the spec, SDL, examples, ADR, glossary,
shared contracts, views and design checks mutually consistent and current-state.
A changed traversal, admission or deduplication decision that earns a record
reworks the ADR set in place. No new consent, entitlement, usage key, setup or
incompatible contract version is introduced. A substantive redesign that
needs its own adversarial read is externalised as a producer/review chain
beside this leaf rather than settled here.

## Notes

The review only inspected. Its host counts, mount flags and scratch filename
probe are inspection evidence for design bounds, not acceptance. Re-run
`task design:search-check`, `task design:search-render` and `task check:docs`
after changing the SDL, examples, views or links.

## Decisions (running log)

- Read the findings from review commit `8fc4a7c5`, against producer
  `7653465b1173` and intervening transport design `7e1b0124f163`. The working
  copy started empty. Taskfile recipes remain the verification entry points.
  Tier 2 graph project/generation confirmed at `2026-09-29T10:36:20Z`;
  coverage reports docs excluded and task/config metadata stale or untracked.
  Direct current documents and retained JSON records supply the evidence;
  no source call-chain or graph-completeness claim is needed.
- R1 is a real issue: the retained k73 mount inventory describes Preboot as
  local APFS without read-only, and the launcher/open-URL records place Safari
  there. The present read-only admission cannot satisfy its default Safari
  acceptance case. Narrow region admission needs a new design decision, not
  removal of a safety predicate without replacement. Externalize it before
  planning; keep the failing premise visible until that producer repairs it.
- R2 is a real issue: parent-keyed frontier/depth groups consume the 96 KiB
  nonreserved diagnostic partition, and exhaustion stops the root. The claimed
  separation from diagnostic volume holds only for intrinsic exclusions.
  Exact host counts/latency are not acceptance, but the structural failure
  follows from the contract. Externalize traversal order and bounded diagnostic
  aggregation for a fresh producer/review chain; do not accept native-order
  sampling or silently enlarge the bounds here.
- R3 is a real issue conditional on R1: distinct link/canonical spellings are
  not necessarily distinct installations. Exact-path deduplication would expose
  both if the new region is admitted. Externalize application identity and
  retained spelling/ranking/rootIndices together with admission; retain file
  location semantics and both-control action handoff.
- R4 and R5 are contracts stated unclearly. CHILD_GROUP counts affected anchors;
  FRONTIER_LIMIT/DEPTH_LIMIT omit descendants, while UNREPRESENTABLE_NAME and
  overlong-path VALUE_LIMIT omit the anchor too. Restrict parent groups to those
  reasons. REMAINDER applies with or without progress, anchored at the resolved
  root or representable requested root; no-progress stops have no searched
  record. Repair spec, SDL, glossary, examples and views together.
- R6 is an acceptance-contract issue. Invalid native bytes and alternate layouts
  are mandatory controlled-adapter subjects, not unconditional native VM cases
  that require an unavailable filesystem/system layout. Keep actual supported
  VM layout/admitted-name cases mandatory; another supported layout is tested
  when a concrete supported subject exists. The review's one-host EILSEQ probe
  does not establish a universal APFS guarantee or impossibility of all future
  supported layouts.
- R7 is a real precision/coverage issue. The protected metadata evidence covers
  only Desktop/Documents/Downloads, not sensitive Library targets. Explicitly
  qualify pre-policy native resolution and require a named protected Library
  sub-area witness, with every resolution call inspected before traversal.
  No inference from the existing probe licenses that route as prompt-free.
- R8 is a contract stated unclearly. DIAGNOSTIC_LIMIT means either coverage
  record-count or total-byte exhaustion, with fixed guidance distinguishing the
  exhausted account. VALUE_LIMIT means an individual path value exceeds its
  bound. Keep their extents and no-progress outcomes explicit.
- R9 is a real evidence-label issue. CoreServices contents and application-link
  layout remain unmeasured design premises awaiting actual-adapter acceptance.
  Cite durable Safari registration/mount records only for what they establish;
  they do not prove discovery or link metadata.
- Preserve the review's accepted coarse granularity, fixed match-slot ceiling,
  independent root credits, k95 repairs and k97 transport/compatibility subjects.
  State the approximately 157 MiB four-job charged ceiling visibly. No new
  consent, entitlement, usage key, setup, contract version or production code.
  No in-session reviewer: substantial redesign is routed to the tree.
- Cut `search-defaults-k101` immediately after this leaf and before k99; it owns
  R1–R3's new admission, traversal/aggregation and application-identity decisions
  and must cut its load-bearing review before planning. Briefs and all public
  roll-ups now identify the unrepaired proposal instead of claiming settled
  Safari reachability or separation from all diagnostic growth.
- R4–R9 applied to the spec, SDL descriptions, example annotations, glossary,
  coverage ADR, cumulative trace, client guide and coverage/handoff views and
  captions. k97's outcome/selection/permission/compatibility sections and its
  diagnostic ADR are intact; only shared Query description qualifiers changed,
  which k99 must reconcile alongside the discovery producer's later edits.
  Mandatory real Safari/Finder/default calls and home witnesses remain pending;
  invalid bytes/alternate layouts are controlled cases, with another native
  layout conditional on a concrete supported subject. No native acceptance ran.
- `task design:search-render` passed. Taskfile and all three D2 inputs had
  matching per-file SHA-256 values before/after rendering. Revised coverage and
  handoff were rasterized with librsvg and inspected at 1200/900 pixels: starts,
  labels, branches and arrows readable without clipping. This is static light
  rendering, not a new Safari/reflow/dark-mode or runtime check.
- `task design:search-check` passed independent/composed SDL and all search and
  existing action examples; removed-root, wrong-input/unknown-output and foreign
  provider-type controls rejected. `task check:docs` exited 0 with no failures.
  All 513 versioned files outside `.grove/` were frozen and compared individually
  by path/SHA-256 before/after both completed checks, including Taskfile, checker,
  Markdown/manifest, schemas/examples, package manifests and generated exports.
  No checked input moved; no production build, branch/binary or native acceptance
  is implied. Taskfile/check controls are unchanged.
- Every R1–R9 finding has a disposition above: R1–R3 are accepted pending design
  obligations in k101; R4–R9 are applied contract/evidence/acceptance repairs,
  with R6's universal impossibility inference rejected. The accepted granularity,
  slots and independent-root trade-offs remain visible. The node still has k101
  and k99 live, so this retirement closes no ancestor or baseline.
