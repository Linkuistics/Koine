# search-coverage-k98

**Reviews:** search-coverage-k96

## Goal

Read the committed discovery/coverage/resource design adversarially before
implementation planning. Judge whether its interfaces and bounds can satisfy
the agreed application/home workflows without a false coverage assertion,
uncounted retained work or an inferred acceptance of arbitrary sampling.
This is inspection only; record findings, not fixes or native acceptance.

## Context

- Locate the producer commit by `search-coverage-k96`; read its complete diff
  and current artifact. `search-permission-transport-k97` can run before this
  review. Reconcile its intervening shared/schema edits deliberately rather
  than attributing that drift to this producer or treating old coordinates as
  current. k97 separately owns compatible BLOCKED transport.
- `docs/specs/workspace-search.md`, additive search SDL/examples, current-state
  ADR `docs/adr/search-coverage-describes-observations.md`, glossary, client
  guide and cumulative workflow trace. Existing launch/open SDL, authority and
  selection ADRs remain the action/authority contract.
- Search coverage/handoff sources, exports, captions/current-discussion manifest
  and README in `docs/design/architecture/`. `task design:search-check`,
  `task design:search-render` and `task check:docs` establish document/schema
  consistency, not runtime behavior. Wide-layout arithmetic is not VM evidence.
- `docs/verification/search-discovery.md` and
  `docs/verification/protected-path-metadata.md` establish only their measured
  calls. Stream traversal, generic CoreServices/Cryptex canonical anchors and
  application-link metadata are explicit signed-host acceptance obligations.
- `protected-home-search-k93` keeps Antony's protected-domain and measured
  bound-driven omissions decision live. Protected default opening and app-reveal
  notice retain their separate existing decisions. No new consent, entitlement,
  usage key, setup or incompatible contract-version change is approved.

## Done when

Find concrete contradictions or missing obligations, anchored to the producer
commit and exact current artifact/source locations. Challenge the coverage
contract with completed/empty roots, partial observations, groups of only some
children, invalid native name bytes, policy targets, long paths, overlapping
roots and unfinished metadata. A root summary must not disguise an all-child
or all-subtree assertion, and an unread remainder must not predict its size.

Challenge real Safari/Finder and other system layouts, canonical Cryptex/Preboot
admission, symlink versus Finder alias semantics, stale registration and link
replacement. Defaults must remain generic discovery rather than a configured-app
catalogue; distinguish a design obligation from a measured no-prompt claim.

Challenge 64-entry cyclic scheduling, independent root budgets, bounded streams
and FIFO frontier, worst-shape reservations/byte charges, match ranking/deduplication,
result truncation and all exhaustion paths. Try a large first root/directory,
wide/deep/long-path trees, repeated errors, many intrinsic exclusions, blocked
native calls, freeze/cancellation and provider restart. Verify the three-seam
cases have observable outcomes and failures stay pending rather than satisfying
the baseline conditionally. Assess whether the coarser root/group granularity
and memory cost are a coherent weighed interface choice with useful defaults.

Preserve the repaired aggregate precedence, Unicode/stem ranking, optional
absence versus explicit missing roots, UNREGISTERED reveal/copy choices, exact
both-control action handoff, unchanged action-only compatibility host/profile
and process-wide blocked-worker accounting. Judge the spec/ADR set and all
citations as current-state artifacts. Findings may reject, clarify or accept
trade-offs; they do not constitute a mandatory repair list.

## Notes

Parent Tier-2 project:
`Users-antony-Development-Koine.add-plugins-for-modaliser-requirements`, generation
2026-09-29T10:36:20Z. Relevant graph searches had no workspace selection symbols;
coverage reports docs/scripts excluded and current workspace native/selection
paths and task notes untracked. Producer read current documents and
`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift` /
`Providers/WorkspaceProvider/Logic/Selection.swift` directly for the measured
metadata route and both registration answers. No authoritative graph call chain
or completeness claim was made. Confirm current project/generation/coverage and
read any reported missed ranges before new source claims.

No in-session reviewer ran; this leaf supplies the mandated fresh context.
Producer checks passed with item-by-item unchanged frozen subjects, and Safari
fresh deep links/light rendering plus a dark coverage raster were inspected.
Narrow-screen presentation was not separately exercised. No production code,
provider build, native acceptance or signing posture changed.

If actionable findings warrant integration, cut it at this review's sequencing
boundary following Grove's directory-local rule; pass this review's handle,
not its findings copied into the integrating leaf's charter.

## Findings

Anchored to producer `7653465b1173` (`search-coverage-k96`). Coordinates are the
current working copy at `7e1b0124f163`, which adds k97's BLOCKED-transport edits
(spec header, outcome table, "Selection and publication invariants", permission
and compatibility sections, SDL result/Query descriptions, D2 labels). None of
k97's edits changes k96's discovery, extent, accounting or scheduling text, so
every finding below is k96's unless it says otherwise. `spec` is
`docs/specs/workspace-search.md`, `SDL` is `docs/design/workspace-search-schema.graphql`,
`ADR` is `docs/adr/search-coverage-describes-observations.md`. Host observations
are read-only inspection of this Mac (macOS 26.6), not acceptance.

### R1 — The Cryptex admission rule refuses the real Preboot layout, so default search still cannot return Safari (high)

spec:118-122 admits the Cryptex region only "when public mount metadata
establishes local, read-only APFS"; spec:127-129 skips other mounts; the link
rule checks the target against "admitted regions and volumes" (spec:147-148).
`/System/Cryptexes/App` is a symlink into `/System/Volumes/Preboot/Cryptexes/App`,
on the Preboot volume. The VM mount table already in the repo
(`docs/verification/protected-path-metadata/environment.json`) records
`/System/Volumes/Preboot (apfs, local, journaled, nobrowse)`: not read-only. On
this host the region shares Preboot's device (distinct from system/data) and
`statvfs` reports it read-write. Registered Safari resolves there
(`docs/verification/launcher-apps/inventory.json:326`,
`docs/verification/open-url-vm/results.json:7`).

As written, the fifth default is refused with an affecting volume reason. The
target of `/Applications/Safari.app` fails the same admission, giving an
affecting ENTRY and no match. The acceptance row (spec:722) expects Safari
found; the design as written guarantees it is not. This is k94's S2 defect,
now with honest PARTIAL coverage instead of false COMPLETE. k96's
"not rejected merely for its canonical spelling" fixed the spelling, not the
volume classification. The read-only test was the guard against admitting
arbitrary mounts. A replacement needs a stated way to identify the Preboot
cryptex region (on a read-write volume) that is narrower than "any local APFS".

### R2 — Frontier overflow writes one diagnostic per parent, so a realistic home stops on a diagnostic bound before depth 6 (high)

spec:479-483 records each overflow as FRONTIER_LIMIT CHILD_GROUP at the parent,
keyed by parent (spec:455-456). Per root, nonintrinsic exceptions get
256 KiB minus the 160 KiB reservation, so 96 KiB (spec:427, 442-446). At
256 bytes per object, 16 per slot, plus path and guidance (spec:434-436), one
CHILD_GROUP charges roughly 400-600 bytes, so about 160-240 fit. The 512-record
bound (spec:427) is unreachable. When the partition is exhausted, the whole root
stops and every queued task is abandoned (spec:457-461).

Inspection counts of `~/Development` on this Mac use `find`, non-hidden entries
and approximate package pruning; they are not acceptance. There are 1,399
visible directories at home depth 5, 8,588 at depth 6 and 9,558 at depth 7.
With FIFO tasks (spec:467-470), the frontier reaches 4,096 after roughly 530
depth-5 listings. Each later depth-5 parent with a subdirectory then adds a
record, and the root stops a few hundred parents later, before any depth-6
directory is opened. No name at depth 7 or deeper under `~/Development` is
examined. Which depth-6 names are examined is fixed by readdir and FIFO order.

This contradicts three statements:

- ADR:14-16 claims the design separates "useful name discovery from diagnostic
  volume".
- spec:545 says "PARTIAL due to policy, not DIAGNOSTIC_LIMIT". That holds only
  for the 3,072-leaf fixture, sized under 4,096.
- spec:724 promises "no per-directory diagnostic cutoff".

It structurally produces the native-order sample the design says it does not
accept (spec:27, 559-561), and rejected subtrees are never revisited.

The spec weighs only "one DFS branch owning the entire job" (spec:475-476).
It does not weigh breadth-first frontier growth against depth-bounded
traversal memory. Nor does it weigh a root-level counted or reserved record for
FRONTIER_LIMIT/DEPTH_LIMIT. Traversal order now decides which names are found,
and neither the spec nor the ADR records that choice.

### R3 — Once R1 is repaired, default search returns Safari twice as "separate installations" (medium)

Both routes reach one bundle. The `/Applications/Safari.app` link returns its
link spelling (spec:152-153). Cryptex-root matches are "canonical-root-based"
(spec:365-366), so the same bundle also appears as
`/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app`. On this
host both spellings have the same device and inode, and the Cryptex region holds
only `Safari.app`.

Deduplication is by exact path only (spec:252-253, 507-509), and spec:379 and
SDL:140 tell clients that same-identifier paths are separate installations. So
clients may not merge them. Two INSTALLED rows take two limit slots, and the
second offers a Preboot path for copy and reveal. Modaliser's intended result
is one choice per application (`AppScanner.swift` deduplicates by name). Link
inspection already compares native identity, so the design has what it needs.
On the inspected layout two mechanisms solve one case. The spec does not weigh
dropping one, merging by native identity, or which spelling a merged match
keeps.

### R4 — CHILD_GROUP anchor semantics depend on the reason, but the contract says anchors are omitted (medium)

spec:216 says "A directory anchor's descendants are omitted too", implying the
anchor itself is omitted, and SDL:28 and CONTEXT.md:138-141 say the same. That
is true for UNREPRESENTABLE_NAME (spec:625-628) and VALUE_LIMIT (spec:510-512).
FRONTIER_LIMIT and DEPTH_LIMIT anchors, however, are examined and matchable
names; only their descendants are dropped (spec:479-483, and spec:547: "Names
can all be examined"). DESCENDANT_GROUP states its own exception (spec:225-226);
CHILD_GROUP does not. A client cannot tell whether a group's anchor name could
have been returned, which is the exact semantics this design was asked for.

### R5 — A root that stops without progress has no defined stop extent, and the SDL forbids the one the spec requires (medium)

SDL:28 defines REMAINDER as "unfinished work after observed progress". Yet
spec:232 gives every root one stop cause in "its pre-reserved REMAINDER", and
spec:546 requires roots a stall or deadline left unvisited to "show
TIME_LIMIT/REMAINDER". CONTEXT.md:143-145 drops the progress condition, so the
glossary and SDL disagree too. These exhaustion paths have no specified extent:

- no-progress TIME_LIMIT, which is FAILED "with coverage" (spec:525-527);
- CAPACITY_LIMIT, raised before filesystem work (spec:580-581);
- a root stopped by VALUE_LIMIT "at its representable requested scope" before
  progress (spec:447-449);
- an admitted root whose first listing never returned.

SUBTREE cannot fill the gap without an explicit decision that it may carry a
stop reason.

### R6 — Two VM obligations have no constructible subject, so they can never pass (medium)

- **Invalid native name bytes** (spec:725 VM column; spec:625-629). The
  admitted domain is startup APFS only (spec:108-131). In a scratch probe on this
  host's APFS data volume, creating names with `\xff`, a lone continuation byte or
  an overlong sequence each failed with EILSEQ (92); a valid control name
  succeeded. Every valid UTF-8 name is a representable GraphQL string, and
  filesystems that accept raw bytes are unsupported volumes. So
  UNREPRESENTABLE_NAME is natively unreachable here; only the controlled adapter
  can exercise it.
- **"Another supported system layout"** (spec:722 VM column). The deployment
  floor is macOS 26.0 (`docs/verification/search-discovery.md:151`). The system
  volume is sealed, and the 26.5 VM and 26.6 host layouts agree. No supported VM
  can supply a different layout.

The root brief says a pending case "stays live work, never a passing outcome,
and the baseline does not close around it". Both cases belong on the
controlled-adapter seams, with a stated platform limit (or an explicit
conditional) in the VM column.

### R7 — The .app-link route resolves the target before policy, using calls measured only for Desktop/Documents/Downloads (low-medium)

spec:147-148 resolves "with the measured metadata route" and only then checks
both spellings. `~/Library` is blocked conservatively and without measurement
(spec:164-166), and the link's literal target text cannot be classified without
native resolution (spec:181-182 forbids lexical normalization). So a link into
a protected Library area (another app's container or group-container data, Mail,
Messages) is resolved before policy applies. `protected-path-metadata.md`
measured lstat/stat/realpath only in Desktop, Documents and Downloads, so
"measured" overstates the route for Library targets. spec:723's VM case says
"blocked before traversal" and names Library generically. The risky step is
resolution, so the case needs a TCC-protected Library sub-area as a named
target. spec:160 already disclaims any prompt-free guarantee, so this is a
precision and acceptance-coverage gap, not a false claim.

### R8 — Partition-exhaustion reasons are ambiguous, and VALUE_LIMIT is overloaded (low)

spec:457-460 writes "DIAGNOSTIC_LIMIT/VALUE_LIMIT" without saying which kind of
exhaustion produces which. If the record bound is unreachable (R2), the native
path may never produce DIAGNOSTIC_LIMIT. VALUE_LIMIT also marks:

- an overlong child path (CHILD_GROUP, spec:510-512);
- an omitted known-match path (spec:408-409);
- a too-long root (spec:447-449).

A client cannot tell "this root ran out of diagnostic room" from "a path was too
long". The native-binary row (spec:725) lists the count, value and diagnostic
limits as separately observable.

### R9 — The new layout premises cite no durable evidence (low)

spec:91-92 ("CoreServices includes Finder and its Applications subdirectory on
the inspected layout") and the Safari-link premise rest on k94's host inspection.
That inspection lives only in `.grove/` notes, which teardown removes.
`search-discovery.md` measured `/Applications` and `/System/Applications` one
level deep. A current-state spec should cite committed evidence, or call these
unmeasured layout premises awaiting the acceptance row.

### Accepted trade-offs and preserved contracts

- **Granularity.** Root summaries plus counted intrinsic groups are a coherent
  public granularity, and the ADR meets the all-three test. This is accepted,
  subject to R2 (volume of nonintrinsic groups) and R4 (their semantics).
- **Fixed match slots.** The 16 KiB slots fit their worst shape: about 10.8 KiB
  for an application and 11.2 KiB for a file, including sixteen index slots.
  They are a simple, deterministic replacement for byte-packed matches. The
  "reserved memory" the ADR names is an accounting ceiling, not an allocation.
  Accepted.
- **Memory ceiling.** Per-job ceilings are stated, but the process-wide product
  is left to the reader: four retained jobs × about 39 MiB charged ≈ 157 MiB.
  This is a visible trade-off; stating it would help k93.
- **Root scheduling.** Cyclic scheduling with independent entry, coverage and
  frontier credits does remove k94's S1 starvation across responsive roots. A
  blocked native call can still starve later roots, as spec:476-477 says.
- **k95 repairs.** All are intact in the current text:
  - no-progress precedence (spec:265-269);
  - Unicode/stem matching and ranking (spec:71-82, 401-405);
  - optional absence versus explicit missing, extended consistently to the
    Cryptex default (spec:99-106);
  - UNREGISTERED reveal/copy (spec:368-372);
  - the both-control handoff (spec:633-639);
  - process-wide blocked-worker accounting (spec:576-588).
- **k97.** Its compatibility subjects keep the action-only host and profile
  unchanged.

## Decisions (running log)

- Resolved the mandate, then read the brief chain, producer diff `7653465b1173`
  and k97's `7e1b0124f163`. k97's edits stay within BLOCKED transport and its
  restatements; nothing of k96's was credited to k97 or the reverse.
- Made no source-code claims, so I did not consult the graph. Evidence is the
  committed documents, verification records, read-only host layout and mount
  inspection, one bounded `find` count, and a scratchpad name-encoding probe,
  whose valid-name control succeeded. I ran no test, build, lint or format
  command and edited no artifact.
- No in-session reviewer: a review kind spends none.
- R1, R2 and R4–R6 are actionable, so I cut the integration at the slot of the
  first live sibling after this review (`search-permission-transport-k99`),
  passing this review's handle only.
