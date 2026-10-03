# search-coverage-k96


## Goal
Replace the unsettled default-discovery and coverage/resource proposal in
`docs/specs/workspace-search.md` with a useful, bounded contract for the agreed
application and home-file workflows. Keep omissions explicit without making an
arbitrary native-order sample the accepted baseline.



## Context
- `app-and-file-search-k94`, findings in review commit `fe3283486341`, anchored
  to producer `e6f5f16c7980`; `app-and-file-search-k95` records the integration
  triage and repairs. This producer owns the substantive coverage/discovery
  design that the integration could not safely settle.
- Current `docs/specs/workspace-search.md`, additive search SDL/examples,
  workflow trace, client guide, architecture coverage/handoff views and
  `task design:search-check` / `task design:search-render`.
- `docs/verification/search-discovery.md` and
  `docs/verification/protected-path-metadata.md`: bounded signed-host evidence,
  not acceptance of recursive enumeration, a new adapter or arbitrary aliases.
- Agreed application/file workflows in `docs/requirements/modaliser-workflows.md`.
  Safari is a symlink in /Applications on the inspected host; Finder lives
  outside the proposed defaults. Do not treat these names as the only possible
  system-app layout or solve discovery by a configured-app-only catalogue.
- `search-permission-transport-k97` separately owns BLOCKED transport and the
  enduring ABI choice. Preserve the aggregate precedence repaired in k95.
- `protected-home-search-k93` owns Antony's protected-home decision and any
  proposed weakening of the agreed coverage, including bound-driven omissions.
  Coordinate there; if the decision is needed earlier, reorder that existing
  work ahead of dependence rather than inventing a conflicting decision.

## Done when
- Defaults can discover the configured applications, including Safari and
  Finder, with stated registration, alias and system-layout limits. Compare
  mechanisms on the existing evidence; any new call/prompt claim gets a bounded
  signed-host check or remains an explicit pending acceptance obligation.
- Coverage/resource representation has exact semantics for searched subtrees,
  child-exclusion groups, unrepresentable names and stopped/unvisited remainder.
  A parent summary never claims all its children were skipped when only some
  were. Diagnostic reservation, record/byte accounting, match-versus-diagnostic
  arbitration, root scheduling and result truncation have deterministic rules.
- Useful default coverage is assessed against realistic application/home
  layouts and large single directories, not only the small k91 fixture. The
  design states what its bounds permit and how later default roots avoid
  starvation. Every three-seam acceptance obligation has an observable expected
  result; local directory counts are not native acceptance.
- Preserve the k95 repaired contracts unless a weighed design explicitly
  replaces them: app stem/full-name matching and canonical Unicode equivalence,
  OPTIONAL_ROOT_ABSENT versus explicit missing roots, UNREGISTERED reveal/copy
  choices, complete action handoff and process-wide blocked-worker accounting.
- Reconcile spec/SDL/examples, shared contracts, glossary, views and applicable
  ADRs in place. No new consent, entitlement, usage key, setup or incompatible
  contract version is inferred. Any reduced workflow coverage gets Antony's
  decision through k93 before it is accepted.
- Leave the artifact reviewable, run its design checks/rendering, and cut the
  load-bearing `review-design` as the last work act under this parent, using
  this producer's bare stem and a `**Reviews:** search-coverage-k96` pointer.
  Implementation planning follows the completed repair/review work.

## Notes
This leaf owns a substantive producer redesign, not implementation. Keep the
native evidence question bounded; absent platform guarantees become stated
limits, pending acceptance or the existing human decision, never a deeper
evidence task chain. Do not cut a minor-2 framework dependency from the withdrawn
nil-consent proposal while k97 remains unsettled.

## Decisions (running log)

Bootstrap confirms an empty jj change on k95. Tier-2 graph project is ready at
2026-09-29T10:36:20Z; docs are excluded and current workspace native/selection
paths are not tracked. Read the affected documents and those current sources
directly. Public registration APIs take an identifier; they do not supply a
complete installed-app enumeration. The existing selector compares resolved
native identity and consults both registration answers.

Keep streaming name discovery. Broaden default application roots to generic
CoreServices and Cryptex application directories, and inspect visible terminal
.app symbolic links as individual application candidates after target policy,
volume and identity validation. Never recurse through such a link. This is a
narrow application-only metadata route, not a configured-app catalogue, arbitrary
alias traversal or permission to search protected/system contents. New layout,
link and stream behavior remains a named signed-host acceptance obligation.

Replace per-directory searched logs with a root observation summary: SUBTREE
only after all eligible work finishes, otherwise OBSERVED_DESCENDANTS explicitly
asserts only counted observations. Intrinsic omissions aggregate as counted
DESCENDANT_GROUP anchors; exceptional unnamed children use CHILD_GROUP at their
representable parent. A stopped root uses REMAINDER, never a falsely universal
SUBTREE. This gives each extent one meaning and avoids a diagnostic record for
every ordinary directory or package. Exact exception locations remain bounded.

Use independent root work/diagnostic/frontier budgets and cyclic scheduling,
with bounded round-robin directory streams. Diagnostic reservation precedes
work; mandatory coverage wins over matches, whose separate budget cannot stop
traversal. Compare against DFS/global diagnostics and exhaustive or persistent
indexing in the durable spec. Root fairness is conditional on native calls
returning before the shared deadline, not a hard syscall guarantee. A finite
frontier/work/deadline can still omit eligible names: k93 must assess measured
omissions before accepting the baseline; this design accepts no arbitrary sample.

Fixed match slots are the weighed replacement for variable-byte prefix packing:
reserve 16 KiB per requested match, with explicit string/shape caps. Count-based
ranking can then preserve every retained path's sixteen root-index slots without
needing forgotten matches after metadata size changes. Coverage and frontier
partitions remain separate. The maximum charged job accounts are 4 MiB coverage,
3.125 MiB matches, 32 MiB frontier and 8 KiB wrappers, plus bounded scratch/native
limits; this is a retained-account ceiling, not hard RSS or a wire-size guarantee.
The wide fixtures' ~3,000 simultaneous short-path tasks fit a 2 MiB frontier,
not a 1 MiB account once object overhead is charged. Record the public coverage
and reservation trade-off in one ADR, with a bidirectional evidence citation.

No in-session reviewer: this mandate explicitly commissions the tree-level
load-bearing review, which will challenge the new scope/scheduling/accounting
contract before implementation planning. Another fresh read here would duplicate
that charter. No production implementation, native acceptance, new consent,
entitlement, usage key or incompatible contract version is claimed.

Final contract clarifications: fixed presentation roots resolve to per-query
canonical/native admission anchors, so a Cryptex presentation resolving into
Preboot is not rejected merely for its canonical spelling. That new admission
route remains pending signed-host acceptance. One serialized accumulator owns
counter updates and freeze; there is no second growing value copy after wait
expiry. Unfinished candidates belong to REMAINDER, while finalized matches and
explicit known-match path-value omissions determine result truncation.

Verification: task design:search-check passed independent/composed SDL and both
examples, existing action examples, and removed-root/input/output/foreign-type
negative controls. task design:search-render regenerated the three views.
task check:docs passed after the final prose/example changes. Before/after
SHA-256 values agree item by item for all 77 frozen subjects: Markdown outside
process/build output, Taskfile/checker, search/action/desktop SDL and examples,
viewer/manifest/three D2 sources and client package/lock files. Arithmetic checks
confirm the two wide layouts' entry/EOF counts and a maximum match shape below
its reserved slot; they are static accounting, not native acceptance.
Safari opened fresh coverage/handoff deep links and showed current/updated
markers and the actual diagrams; desktop light layout and native-size control
were checked. A D2 theme-200 rasterization of the coverage source was inspected
without clipped labels. Narrow-screen behavior was not separately exercised;
the existing native-size/pan/reflow limitation remains documented. Preview uses
loopback port 8896 because 8769 was occupied and did not serve a usable response.

The artifact is ready for the mandated review, not implementation/native/default
coverage acceptance. k93 carries final bound-driven omissions alongside the
protected-home decision; k97 still owns compatible BLOCKED transport. The parent
k19 retains that live producer and this producer's forthcoming review, so no
node-close cascade or promotion is due. Cut the bare-stem review last, then
retire and seal this one jj change with its review and Creator provenance.
