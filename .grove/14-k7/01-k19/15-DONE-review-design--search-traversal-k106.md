# search-traversal-k106

**Reviews:** search-traversal-k105

## Goal

Adversarially read the committed shallow-first traversal and process-wide
search descriptor design against the unchanged search requirements. Find
counterexamples that prevent implementation or planning from relying on it;
produce findings with evidence, not fixes or native acceptance.

## Context

- Locate the producer commit by the stable handle search-traversal-k105 in jj
  history; compare its diff with current subjects. Prior review search-defaults-k102
  (commit fc360b7c) exposed DFS shallow-name loss and shared descriptor exhaustion;
  search-defaults-k104 externalized this redesign. Preserve k103's typed
  BLOCKED/outcome/lifecycle/transport/compatibility and k104's worker ownership,
  canonical-parent policy checks, unified path spelling and witness accounting.
- Primary artifact: docs/specs/workspace-search.md. Reconcile both search ADRs,
  SDL/examples, CONTEXT.md, client guide, workflow-provider trace, traversal/
  coverage/handoff D2 sources and exports, architecture manifest/captions/README,
  brief chain and protected-home-search-k93's pending human decision.
- Three test seams remain private adapter support, independent composed GraphQL
  integration, and normally launched signed-host/native acceptance. Rendering,
  schema negative controls and docs checks passed on 516 unchanged non-Grove
  file hashes; arithmetic and browser inspection are static/presentation evidence.
  No traversal implementation or native acceptance was performed.
- Tier 2 graph project:
  Users-antony-Development-Koine.add-plugins-for-modaliser-requirements;
  indexed generation 2026-09-29T10:36:20Z. Confirm freshness after launch.
  Docs/scripts are excluded by design and were read directly; current listener/
  glossary/Taskfile metadata needed direct reads. Listener graph traces identify
  KoineServer.start, not runtime descriptor serviceability. Check coverage for
  every relied path and read excluded/stale/missed ranges; make no graph
  completeness claim from this handoff.

## Done when

- Contest the exact per-root FIFO order property under the unchanged entry,
  time, memory, root and concurrency limits: all admitted shallower listings
  must finish before any deeper entry is observed. Distinguish returned shallow
  names from descendant completeness and cross-root fairness. Re-derive the
  400,001-entry Development/200,001-file early-branch fixture and its later
  depth-1 home names, depth-2 marker, omitted deep needle and later explicit-root
  needle. Ask whether any scheduling/deadline assumption silently recreates DFS
  loss. Compare iterative deepening's repeated work and held-stream costs.
- Try to break bounded FIFO storage and truthful coverage with 5,000 wide
  siblings, 1,000 depth-bound anchors (including physically empty anchors),
  16 roots, maximum-length and invalid paths, mixed policy/frontier/depth groups,
  cancellation and freezing. Verify 512 queued/in-flight tasks, 384 KiB/root,
  fixed 18,176-byte reserve, 43 maximum-path tasks and thirteen reserved coverage
  shapes within 160 KiB. Count copies, slots, scratch, frozen ownership and unwind;
  require fixed frontier guidance to coalesce count/byte refusal into one root
  DESCENDANT_GROUP. Omitted descendants are not unseen-entry counts. An unfit
  child remains matchable and does not terminate its parent's listing.
- Contest the one-current-stream/root and two-temporary-descriptor/job claim
  through every component, canonical, directory and bundle path, fresh no-follow
  dequeue walk and identity check. Try moved queued targets, moved current or
  intermediate parents, replacements, policy escape and descriptor failures.
  Check that policy is diagnosed before relevant opens, changes use the right
  SUBTREE or REMAINDER scope and already diagnosed omissions survive. Separate
  logical checks from the remaining native check-to-open/no-dialog race limits.
- Contest a single process-lifetime account across aliases, jobs, provider
  instances and restart: effective soft RLIMIT_NOFILE, non-search reserve 128,
  search cap 72, Q = effective roots + 2, atomic worker/credit acquisition,
  failed opens, fdopendir/dup transfers, lowered/unknown limits and worker-only
  release after blocked native calls. Re-derive four 16-root jobs' 72 credits,
  low-limit admission/refusal and no-progress status. No raised limit or
  uncharged explicit temporary descriptor may make the arithmetic work.
- Test whether EMFILE/ENFILE containment and refusal of new native inspections
  cover opaque platform calls, queued work, surviving jobs and new jobs without
  mutating frozen results or reclaiming a blocked worker's resources. Identify
  hidden Foundation/Bundle/registration descriptors, inherited/listener/store/
  action demand and concurrency assumptions that invalidate serviceability.
  The normally launched signed-host subject must record limits, credits and
  owned/opaque/total high-water use while independent new listener requests,
  durable grant operations and authorized actions remain serviceable. A static
  cap is not this evidence; if the design cannot specify a constructible subject
  or the allocation cannot preserve service, report the defect rather than clear it.
- Verify exact fixtures and expected outcomes at all three existing seams,
  including freeze/cancel/deadline, changed-parent and refusal cases. Confirm
  unchanged budgets, search domain, roots/actions, consent/entitlements/setup,
  public schema signatures, transport and compatibility meanings. Reconcile
  every current summary and visual with the chosen design; do not treat passing
  SDL or browser rendering as acceptance of native branch invariants.
- Record actionable findings against the producer commit and current path/line,
  explaining the counterexample and consequence. Follow the review discipline;
  cut an integration only if findings warrant it, carrying this review's handle
  rather than transcribing its findings into the integration charter.

## Notes

Planning app-and-file-search-k30 still waits on this producer, this mandatory
review and any earned integration. Real Safari/Finder/home/canonical-path,
no-dialog and saturated normally launched host acceptance remain pending;
protected-home-search-k93 owns Antony's omissions decision after measurements.
No native evidence chain, adapter implementation, smaller search domain, new
consent/setup, raised descriptor limit or incompatible version is authorized.

## Decisions (running log)

- Adopt the mandate in the stated jj workspace. Producer is `6814ec741fa4`
  (`rnqsosyq`); `@` is empty on top of it, so every cited file is unchanged
  since the producer and its line numbers are current. Tier 2 graph generation
  is still 2026-09-29T10:36:20Z; `docs/` and `scripts/` are excluded by design,
  and `Sources/KoineHTTP/LoopbackListener.swift` and
  `Sources/KoineServer/KoineServer.swift` report `metadata_changed`, so all of
  them were read directly. No graph-completeness claim is made.
- Inspection only. No task, build, test or render command was run; the
  producer's static checks are taken as recorded, not re-earned. Spend no
  in-session reviewer (`review-*` spends none).
- Re-derived and confirmed, not findings: the per-root FIFO order property
  holds as stated (the queue never holds more than two adjacent depths, and
  frontier/changed-target refusals omit but never reorder); 18,176-byte fixed
  reserve, 375,040 task bytes, 43 × 8,704 and 512 × 640 task charges; thirteen
  reserved shapes at 152.25 KiB; 13.446/53.782/54.282 MiB totals; the
  application (1,281/289/256), home (1,318/291/256), 5,000-wide (5,512/513,
  frontier 4,488), depth (1,992/993, group 1,000), 16-root (Q = 18, 72 credits,
  64 + 8) and L = 160/128 rows; the 400,001-entry fixture's depth-1 witnesses,
  observed `development-depth2.txt`, unobserved home `deep-needle.txt` and its
  later-root rootIndex. SDL diffs are description-only; budgets, domain,
  roots/actions, consent/setup, transport and compatibility text are unchanged.
- Platform facts used as evidence: `launchctl limit maxfiles` on this host
  reports soft 256, so a normally launched Koine has L = 256 and S = 72. The
  SDK's `fcntl(2)` requires a MAXPATHLEN buffer for `F_GETPATH` and
  `F_GETPATH_NOFIRMLINK`, and `sys/syslimits.h` defines `PATH_MAX` 1024.
  `fsgetpath(2)` accepts up to 8,192 bytes but takes an fsid/object id, not a
  descriptor. swift-nio's async `ServerBootstrap.bind` installs
  `AcceptBackoffHandler(shouldForwardIOErrorCaught: false)`
  (`.build/checkouts/swift-nio/Sources/NIOPosix/Bootstrap.swift:727`), whose
  default backoff is one second.
- Ten findings warrant integration. 01-k19 has no sibling after this review, so
  the integration is a plain `leaf-add` with the bare stem, carrying this
  review's handle only.

## Findings

Anchored to producer `6814ec741fa4` (`search-traversal-k105`). `spec` is
`docs/specs/workspace-search.md`; `ADR` is
`docs/adr/search-coverage-describes-observations.md`. Coordinates are current
and equal to the producer's. Severity orders the list.

### T1 — A file-search listing is never revalidated across turns, so a moved current directory is not observed (high)

spec:658-669 keeps one current stream across turns until EOF and opens no child
during it. spec:709-711 and spec:1040 revalidate the held directory only
"immediately before each child open". In file search nothing opens a child
during a listing: descent is queued (spec:662-663), symlinks get no target
inspection (spec:570-571), and type metadata is path-based (spec:1038-1039).
Only application search opens bundle children mid-listing.

- Under DFS, descent into each child directory was a revalidation point. FIFO
  removes all of them, so every file-search listing is now check-free from open
  to EOF. A listing can span thousands of turns; a 100,000-entry listing is
  1,563 turns at 64 entries.
- Counterexample: during a turn boundary in `~/Projects/big`'s listing, the user
  moves `big` into `~/Documents`, or out of the root. The worker keeps reading the
  held descriptor. Every later name is published as canonical parent + name
  (spec:300-301) under the stale `~/Projects/big` spelling, and its path-based
  type metadata targets that stale path, which is absent or now a new occupant.
  Enumeration continues inside a scope policy now blocks. No evidence in
  `docs/verification/` establishes whether `getdirentries` on a descriptor
  opened before the move re-evaluates TCC.
- spec:714 and the GraphQL column at spec:1187 expect "a moved current parent
  stops its root with CHANGED_DURING_SEARCH REMAINDER". Nothing in the algorithm
  can produce that for file search, and "no child open follows observed
  movement" is vacuously true. The VM column moves "current … subtrees …
  between turns", which can only reach this unchecked listing: a component walk
  runs inside one transition, so a between-turn move never lands mid-walk. The
  walk-parent path the native column injects is unreachable in the VM.
- ADR:48-50 states the parent recheck as the mitigation, so the decision record
  inherits the gap.

### T2 — The normally launched serviceability subject has no instrument that can observe its pass/fail quantities (high)

spec:807-814 fails the case if "combined demand does not fit L − owned search
occupancy, or search-attributable opaque opens erase the margin". spec:1185
(VM) records "actual owned/opaque/total descriptor high-water" and fails on
"any search-caused independent failure". spec:913-916 repeats this. No
instrument is named, and the obvious ones cannot see these quantities.

- The ledger sees only owned credits. Periodic descriptor enumeration (for
  example `proc_pidinfo`) misses transient opens that open and close inside one
  `Bundle(url:)` or registration call. Before/after counts around an opaque call
  miss them by construction. "Search-attributable" opaque demand needs
  per-thread attribution against concurrent listener/store/action opens.
  Nothing in the spec says how that is obtained in a signed hardened host
  without a shell-raised limit.
- Client-visible failure is not a usable proxy. The listener is swift-nio's
  async `ServerBootstrap` (`Sources/KoineHTTP/LoopbackListener.swift:64-87`).
  NIO installs `AcceptBackoffHandler(shouldForwardIOErrorCaught: false)`, so an
  accept EMFILE becomes a silent one-second pause in accepting. It is not an
  error. An independent client sees only latency, and spec:1172 declines any
  latency target. A run that starves the listener can therefore record "no
  independent failure".
- At the normal L = 256, S = 72 = 4 × 18, so the descriptor gate can never
  refuse admission: the four-worker pool always binds first. The normally
  launched subject exercises worker refusal only (see T8).
- Consequence: the one gate the design says static arithmetic cannot replace
  (spec:813-814) has no constructible measurement. If it cannot be specified,
  that is the defect the charter says to report, not clear.

### T3 — EMFILE containment cannot see opaque-call failures, and those failures publish positive misclassifications (medium)

spec:789-798 trips the cohort refusal flag only on "an actual native
EMFILE/ENFILE despite reservation" at an observing root. That flag then
"prevents every new native inspection … including opaque metadata calls".

- Owned opens are pre-reserved below S ≤ L − 128. They are the opens least
  likely to see EMFILE, yet they are the only trigger. Opaque calls charged to R
  (spec:800-806) and non-search opens are the likely victims, and neither can
  trip the flag.
- The existing selector code shows the misclassification.
  `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift:14-17` uses
  `urlsForApplications(withBundleIdentifier:)`, which returns an array with no
  error channel. An empty answer under exhaustion is indistinguishable from
  "positively found no entry" (spec:533-535), so a registered app publishes as
  UNREGISTERED and loses its launch route.
- `NativeWorkspace.swift:45-50` reads `Bundle(url:)?.bundleIdentifier` and
  checks denial only by `stat`/`access`, which do not need a descriptor. An
  Info.plist open that failed with EMFILE is therefore reported as "declares no
  identifier". None of these produce INSPECTION_FAILED or affecting coverage.
- Trip the flag once while any cohort worker is indefinitely blocked, and the
  cohort never "fully cleans up" (spec:796-798). Every later search then gets
  CAPACITY_LIMIT until process restart. The guide (`docs/client-guide.md:424`,
  `:474`), the SDL `CAPACITY_LIMIT` description (`workspace-search-schema.graphql:71`)
  and the "fixed descriptor-or-worker guidance" (spec:767) do not tell a client
  that search is disabled, as opposed to busy. No subject combines native
  resource failure with an indefinitely blocked call.

### T4 — Changed-ancestor scope depends on timing, and the queue fans one rename out into per-task exact records (medium)

spec:713-715 gives a "changed queued target" exact CHANGED_DURING_SEARCH
SUBTREE and continues, and stops the root with REMAINDER for a moved "current
parent". spec:639 keys nonintrinsic exceptions by exact path/extent/reason.
Tasks hold no ancestor identities (spec:703-705).

- One physical event gets two public outcomes. A directory renamed while one of
  its descendants' walks is between component checks stops the root with one
  REMAINDER. The same rename between turns makes each queued descendant fail its
  own walk, giving one exact SUBTREE per task. A vanished intermediate component
  (ENOENT) is not classified at all: neither "observed changed target" nor
  "unestablished inspection" names it.
- Fan-out: up to 512 queued tasks under the renamed directory each need a
  distinct record. Only 512 − 13 records and the 96 KiB left after the 160 KiB
  reservation are available. At about 750 charged bytes per short-path record
  (path + 256-byte object + 256-byte guidance occurrence + slots, per spec:618-620),
  roughly 130 such tasks exhaust the byte account. The root then stops with
  DIAGNOSTIC_LIMIT, not CHANGED_DURING_SEARCH, losing every unrelated queued
  task and later sibling.
- DFS turned a moved ancestor into one record. This queue-width-to-records path
  is new, and it contradicts the ADR's premise that width allocates no
  exceptional records (ADR:11-14; spec:652-653). The constructible subjects
  replace only a single queued parent/target (spec:1187).

### T5 — The traversal comparison omits FIFO's own repeated work: a quadratic component rewalk charged only to the wait (medium)

Each dequeue performs a fresh checked walk from the admitted root (spec:705-711).
Every component step is an open plus a canonical-path/identity/volume/policy
check (spec:709-711, 1033-1036), charged to wait and scratch but not to entries
(spec:679-682). The comparison table says FIFO does "each listing once"
(spec:738). The ADR says iterative deepening "repeats shallower scans against
the unchanged entry/wait budget" (ADR:26-27) and does not mention FIFO's walks.

- A depth-k task costs about k checked opens, so a chain costs Σk: 496 for
  depth 31. The 528-entry iterative-deepening cost spec:727-728 cites against
  that alternative is the same quadratic, charged to a different account. The
  descriptor-path call itself builds an O(depth) path at each step.
- The spec's own fixtures show the scale. The 1,000-anchor depth subject does
  about 32 × 496 = 15,872 checked component opens to examine 1,992 entries. The
  16-root subject does about 7,936 per job (31,744 across four) for 512 entries
  per job.
- On node_modules-like trees (many small directories at depth 8–20), rewalks can
  exhaust the three-second wait before the entry budget. That is exactly the
  failure spec:729-730 attributes only to iterative deepening. No subject
  records walk counts or the share of wait they consume, so the trade-off
  spec:66-68 says is "testable" is not.

### T6 — The canonical descriptor-path route cannot produce the 8,192-byte paths the traversal arithmetic and long-path subjects assume (medium)

spec:294-299 uses "the public descriptor-path route" for roots, frames,
queued-task targets and bundles. Every pre-open parent check uses it
(spec:709-711). spec:615 and spec:972-979 size frames and tasks for
8,192-byte paths: 43 maximum tasks, task 44 byte-refused (spec:909, 1184). On
macOS, `F_GETPATH`/`F_GETPATH_NOFIRMLINK` return into a MAXPATHLEN buffer and
`PATH_MAX` is 1,024. The 8,192-byte `fsgetpath(2)` is an fsid/object-id route,
not a descriptor-path route.

- Natively, any directory whose canonical path exceeds about 1,023 bytes cannot
  pass the pre-open parent or post-open revalidation check. Such directories are
  queued (they are under the 8,192-byte VALUE_LIMIT threshold), charge up to
  8,704 bytes each and then fail at walk time. "Unestablished inspection uses
  INSPECTION_FAILED" (spec:715), so each one gets its own exact record instead of
  the parent-keyed VALUE_LIMIT CHILD_GROUP the design relies on to stop
  per-directory diagnostic growth. That reopens k98's per-parent cutoff for
  deep, long-named trees.
- The 43/44 byte boundary and "long component paths … count/byte refusals" in the
  VM column (spec:1184) are not constructible through the named route. With
  ≈1,023-byte paths the reachable native byte boundary is about 244 tasks.
  Requested roots admit 4,096 bytes (spec:109), but natively no root over about
  1,023 canonical bytes can be admitted.

### T7 — The early-branch fixture flattens D2's measured shape and names only the witnesses FIFO keeps (medium)

spec:900 puts 199,998 files directly in Development, making Development's own
depth-2 listing the budget sink. k102's D2 measured something different: 36
Development children, child 12 holding more than 200,000 entries, and later
depth-2 children (ModalAnyware, Modaliser, TestAnyware, this workspace) as lost
witnesses.

- The row names preserved depth-1 names, one early depth-2 name and the deep
  needle. It names none of its own same-depth losses: Development entries after
  about the 99,990th, and every depth-2 name under Pictures/Zotero/Sites/
  Applications. Those four directories are queued behind Development and never
  listed. The fixture gives them no contents, so it cannot show that loss.
- Under FIFO, order within a depth is native order. One wide listing at depth d
  therefore starves later siblings' depth-(d+1) names: the same kind of
  order-decided sample spec:38-39 refuses, one level down. The fixture neither
  models D2's actual depth-2 witnesses nor names the level at which the measured
  home's budget runs out, so k93 cannot see what FIFO actually omits.

### T8 — The lowered-limit predicate is unspecified, and the descriptor gate binds only below L = 200 (low)

spec:783-788 says a "lower ceiling" refuses further opens and freezes "the
observing root". It does not say what the refreshed S′ is compared with:
summed reservations, current owned occupancy, or this job's Q. It also does not
say whether a later higher read lifts the refusal. The three choices diverge:
reservations > S′ freezes every job at its next open, while occupancy-based
refusal lets some continue. The SDL (`workspace-search-schema.graphql:71`) says
a lowered allowance "stops unfinished root work" in general.

Separately, since S = min(72, L − 128) and 4 × 18 = 72, admission can refuse
on descriptors only when L < 200. spec:1185's GraphQL row attributes the
fifth-job CAPACITY_LIMIT at L = 256 to credits, but at that L it is the worker
pool.

### T9 — The coverage ADR now carries independent decisions under a slug that names only one (low)

`search-coverage-describes-observations` records public coverage granularity
(ADR:3-20). It now also records FIFO traversal order with its own revisit
trigger (ADR:22-31), the process-wide descriptor account (ADR:33-43) and
worker cleanup/pre-open checks (ADR:45-50). These have independent reopen
conditions and different reversal costs; the descriptor account is a private
composition rule (spec:753). A session that cites the slug for granularity
inherits resource decisions it cannot find by name. ADR-FORMAT asks for a split
when one record "covers two independent calls", or for the private rule to fail
the record test and live in the spec.

### T10 — The traversal flow labels the depth check "depth first" (low)

`docs/design/architecture/search-traversal.d2:24` (and its SVG) labels
`Anchor -> Depth` as "4 · depth first". It means the depth check precedes the
frontier check, but in the view introducing breadth-first order it reads as the
traversal order this design replaced.
