# search-traversal-k107

**Integrates:** search-traversal-k106

## Goal

Triage the findings of `search-traversal-k106` against the traversal and
process-descriptor design from `search-traversal-k105`, and apply the real
ones. Implementation planning should then start from a traversal, revalidation,
descriptor-admission and serviceability-evidence contract that it can build and
accept without rediscovering these defects in the adapter.

## Context

- Read the findings in the review's own leaf and commit. This charter does not
  restate them. They are anchored to producer commit `6814ec741fa4`, with
  coordinates equal to that commit's. Some evidence is read-only inspection of
  this Mac and of the checked-out swift-nio and SDK headers. It informs the
  design; it is not native acceptance.
- Artifact: `docs/specs/workspace-search.md`, the search SDL and examples, both
  discovery ADRs, the search terms in `CONTEXT.md`, the client guide's search
  section, the workflow trace rows, the traversal/coverage/handoff views with
  their exports, captions, manifest and README, the brief chain, and the live
  `protected-home-search-k93` context.
- Keep k103's typed BLOCKED, outcome, lifecycle, transport and compatibility
  meanings. Keep k104's worker-only ownership, canonical-parent policy checks,
  unified path spelling and witness accounting, except where a finding shows
  that one of them does not hold under FIFO.
- Approval is unchanged. No new consent, entitlement, usage key, setup,
  descriptor-limit change, smaller search domain or incompatible version is
  approved. Reduced coverage remains `protected-home-search-k93`'s decision
  with Antony.

## Done when

- Every finding of `search-traversal-k106` is applied, accepted as a stated
  limit or trade-off, or rejected with its reason in this leaf's running log.
- Applied changes leave every affected durable contract and summary layer
  consistent, with ADRs reworked in place.
- Every changed rule has constructible subjects at the three agreed seams, and
  native acceptance stays pending. A serviceability or revalidation subject
  names the instrument that would observe its outcome.
- `task design:search-render`, `task design:search-check` and `task check:docs`
  pass on frozen subjects.
- A substantive redesign is externalized as a new producer with its own
  load-bearing review beside this leaf, not absorbed here.

## Notes

This leaf integrates a design review. It does not implement the adapter or
start a native evidence chain. It may spend one narrow in-session reviewer, as
`integrate-review-*` kinds do. Planning (`app-and-file-search-k30`) cannot cut
implementation until this leaf, and anything it externalizes, retires.

## Decisions (running log)

- Read k106's findings from review commit `64bcbf6a`, against producer
  `6814ec741fa4`. The working change is empty above the review. Use Tier 2,
  project `Users-antony-Development-Koine.add-plugins-for-modaliser-requirements`,
  generation `2026-09-29T10:36:20Z`. Docs are excluded; glossary/Taskfile/listener
  metadata changed and NativeWorkspace is untracked by this generation. Read
  those subjects directly. The stale server-start snippet returns unrelated
  current lines, so use current source, not its coordinates; graph trace only
  locates the listener relationship. No completeness/native-acceptance claim.
- T1 is a real issue: FIFO removed file-search's incidental child-open checks.
  Require current-stream location/identity/policy revalidation at every listing
  turn, including its first turn, before another entry/EOF read; repeat before
  any child metadata open. Observed movement stops the root with
  CHANGED_DURING_SEARCH REMAINDER. Instrument the check/read/publication sequence;
  native check-to-read/check-to-open races remain pending acceptance.
- T2 is a real issue requiring substantial redesign: periodic or before/after
  descriptor counts cannot certify transient opaque demand, and NIO's async
  bootstrap suppresses accept resource errors behind backoff. Externalize a
  native-resource producer and mandatory review, requiring an instrument with
  demonstrated transient-open/accept-backoff controls in the normally launched
  signed host. Do not clear serviceability by error-free client responses.
- T3 is a real issue in the proposed reuse of errorless registration/Bundle
  calls. The current action adapter is evidence, not a search implementation.
  Externalize error-observable search-native call selection with T2; empty/nil
  opaque answers alone must never establish UNREGISTERED or missing identity.
  Repair the cohort-disabled guidance and add the indefinite-block plus
  resource-failure subject here; fixed transport/failure meanings are unchanged.
- T4 is a real issue: a shared changed ancestor can fan out queued failures.
  Repair scope precedence: any missing/changed/uncertain walk prefix or immediate
  parent stops the root once with REMAINDER. An exact target SUBTREE is allowed
  only after its parent remains established and unchanged; other tasks continue.
  Test a full 512-task queue under one renamed ancestor, including replacement
  and ENOENT/ENOTDIR, preserving prior groups without diagnostic fan-out.
- T5 is a real trade-off stated incompletely. FIFO lists once but repeats checked
  prefix walks. State 496 opens for a depth-31 chain, 15,872 for the depth-anchor
  subject and 7,936/job (31,744/four jobs) for sixteen chains, before other calls.
  Instrument walk/canonical calls and elapsed wait per witness; retain the
  unchanged three-second wait and the pending human omissions decision.
- T6 is a real issue requiring native-path redesign: the named F_GETPATH route
  has MAXPATHLEN/PATH_MAX 1,024, while accounting permits 8,192. Externalize a
  canonical-path producer and mandatory review; retain the public value caps,
  distinguish controlled 43/44 arithmetic from reachable native boundaries,
  and require grouped path-limit handling. No shorter domain is approved.
- T7 is a real issue in the acceptance fixture. Restore Development's 36-child
  shape with its enormous child at position 12; name preserved depth-2 project
  anchors and omitted depth-3 markers in later projects as well as retained
  shallow/deep/later-root witnesses. Add a separate wide depth-2 listing subject
  that explicitly loses later same-level names; arbitrary samples stay unaccepted.
- T8 is an unclear contract. Define lower-limit refusal against summed reserved
  job credits, latch it until cohort cleanup and fresh admission, and preserve
  per-root frozen results. Name worker refusal at L=256 and descriptor refusal
  at L=160; the descriptor admission gate can bind only below L=200.
- T9 is a real issue in ADR coherence. Keep public coverage granularity in its
  slug, extract traversal order/frontier/repeated-work trade-offs to a separate
  record, and leave reversible private descriptor/cleanup mechanics in the spec.
  Reconcile current citations rather than appending a superseding ADR.
- T10 is an unclear label. Replace “depth first” with “depth check precedes
  frontier” and regenerate the export.

- Externalize T6 as search-canonical-paths-k108 and T2/T3 as
  search-native-resources-k109 beside this leaf. Each producer must cut its
  mandatory load-bearing review; k30 waits for both chains. This integration
  accepts neither a shorter native path domain nor an unmeasurable
  serviceability gate. The spec marks these choices open and distinguishes
  controlled arithmetic from future native subjects.
- Split public traversal/frontier/repeated-work trade-offs into
  docs/adr/search-enumeration-reuses-system-find.md. Reversible private
  descriptor/cleanup mechanics fail the ADR hard-to-reverse test and stay in
  the spec. Reconcile the live brief chain, k93, glossary, guide, trace,
  SDL/examples, captions/manifest/README and D2 sources with all ten dispositions.
  No in-session reviewer is spent; substantial uncertainty is owned by the
  externalized mandatory producer/review chains.
- Freeze all 517 non-Grove tracked files by per-file SHA-256, including Taskfile,
  manifests, scripts, all docs/ADRs/D2/SVG/SDL/examples and source fixtures.
  task design:search-render, task design:search-check and task check:docs each
  exit zero; every before/after subject hash agrees. SDL AST comparison with
  review commit 64bcbf6a, omitting descriptions/locations, is equal: signatures
  and enum values are unchanged. Schema negative controls reject as expected.
  Re-derived fixture totals (400,001; 62 before the early branch; 99,938 branch
  entries to the root stop), repeated-walk totals and L=160/199/200 thresholds
  agree. These are static/accounting checks, not traversal/native acceptance.
- Inspect all three changed SVG exports as 1,200-pixel librsvg rasters: current
  checks, prefix/target distinction, depth-check label and open producer choices
  are visible without clipped labels. The old depth-first label remains in the
  historical k106 finding as a cross-tree control, and is absent from current
  architecture sources/exports. No GUI/native acceptance was run.
- Retire this integration with k108/k109 still live under app-and-file-search-k19;
  the close cascade stops there. Both future producer bodies require their own
  load-bearing review before k30. No live review names this integration as its
  producer, so there is no Creator line to settle here. Seal one focused jj
  change containing artifact repairs, new leaves, live context and retirement.
