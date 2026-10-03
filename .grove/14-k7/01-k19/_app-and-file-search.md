# app-and-file-search-k19 — brief

## Goal

Consume `docs/verification/protected-path-metadata.md` before choosing native
inspection calls. The measured metadata route is prompt-free on the three
protected home roots; document file-URL default-handler lookup prompts.
Handler metadata stays unknown/blocked where a prompt-free route is unestablished.
This result does not establish traversal/content-search consent, and approves no
new entitlement, consent identifier or type-only handler substitution.

Design installed-application search and file search, and how a result feeds
`launch-and-open`'s operations and the clipboard allocation.

## Context

- Durable design: `docs/specs/workspace-search.md`,
  `docs/design/workspace-search-schema.graphql` and
  `docs/design/workspace-search-operations.graphql`; the architecture viewer's
  search coverage and handoff views accompany them. Review integration requires
  fresh default-discovery/resource and prompt-risk transport design before
  planning. Prompt-risk transport is reviewed typed BLOCKED data with null matches/
  dependency and no search-generated error, subject to lifecycle/field errors.
  Existing failure/consent mapping stays fixed; no diagnostic framework addition.
  Search remains pending implementation/acceptance.

- `provider-architecture-k5` and `launch-and-open-k18`.
- Requirement rows Application search and File search, and the empty-result
  versus failure rule in "Ownership and existing constraints".
- Modaliser's launcher constructors show the secondary actions a selection
  offers.

## Done when

Evidence is recorded under `docs/verification/`. It is a bounded check in an
isolated VM, under the signed hardened Koine:

- which public mechanism discovers installed applications, and which finds
  files under a root;
- how TCC-protected folders affect results, and whether Koine needs consent it
  does not hold;
- how the index-unavailable case shows itself.

A guarantee the platform does not give becomes a stated limit.

The spec states:

- query semantics;
- result metadata, including unknown values;
- bounds and ordering;
- how a result becomes an input to the launch, open and reveal operations;
- clipboard behavior or its client allocation;
- authority and errors.

## Notes

Do not chase exhaustive filesystem coverage. The requirement is the configured
roots and an honest report of what the mechanism cannot see.

## Decomposition

1. `search-discovery-evidence-k91` — bounded native mechanisms and permission /
   index observations inside signed hardened Koine.
2. `app-and-file-search-k92` — synthesize the evidence into the API, scope and
   action contract before the increment's existing planning leaf.
3. Fresh `review-design` of k92's load-bearing API, coverage and diagnostic
   contract, before the increment's planning leaf.
4. `app-and-file-search-k95` triages that review and applies bounded repairs.
5. `search-coverage-k96` replaces per-directory logs with exact root observation,
   group and remainder semantics; expands generic system-app defaults and checked
   .app-link metadata; partitions root work/frontier/diagnostic budgets and match
   reservations. Its producer cuts a load-bearing review. All native/default
   coverage cases and Antony's bound-driven omissions decision remain pending.
6. `search-permission-transport-k97` chooses schema-only BLOCKED transport and
   records the enduring diagnostic ADR, legacy mapping, branch/alias/publication
   contract and independent exact-host/profile obligations; its producer cuts
   its own review. No new diagnostic ABI dependency is needed.

`search-coverage-k100` triages the discovery review: scope/remainder/reason and
constructible acceptance clarifications land in place. `search-defaults-k101`
replaces read-only admission with fixed presentation-region/Preboot mount checks,
FIFO frontier with root-cyclic DFS held streams and one reserved root depth group,
and route-dependent app spellings with canonical target names/paths and native
bundle identity. Its load-bearing review must retire before planning. Descriptor
costs, changed observations and actual default/home witnesses remain acceptance
obligations; alias-named links remain file locations, not extra application names.
k99 reconciles shared-file edits without losing its BLOCKED responsibility.
k103 integrates its seven findings: the search manifest/descriptor declare both
existing authority/selection features; current composition/VM/selection consumers
move to exact search-required profiles and workspace 1.2.0/schema 1.1.0 update
fixtures, while historical action-only profiles/retained binaries stay unchanged.
No-progress CHANGED_DURING_SEARCH and uncertain resolution/INSPECTION_FAILED
contribute FAILED; established absence/unsupported classification keeps exclusion.
These reason/outcome clarifications do not alter k101's admission predicates.
Nested lifecycle errors are exempt from error-free BLOCKED invariants. k102 must
reconcile those shared-text repairs while reviewing discovery itself.

k104 integrates k102's bounded repairs: worker-only cleanup, current-parent
location checks before child open, one canonical directory-path operation,
Preboot unknown-class failure and fully charged policy witnesses. The residual
check-to-open prompt window and actual canonical calls remain pending. D1/D2
are real and require `search-traversal-k105`: replace the DFS/descriptor choice,
weigh shallow-first work on the 400,000-entry/200,000-entry early-branch shape,
and protect the shared process descriptor table without changing its limit.
That producer must cut a load-bearing review; planning awaits that chain too.

These producer/review repairs live in this node, so planning cannot run before
they retire. k105 now chooses FIFO breadth-first order with one stream/root, a bounded
512-task/384 KiB pending queue and separately reserved FRONTIER_LIMIT group.
Anchor names remain matchable and sibling scanning continues on overflow.
Atomic roots + 2 descriptor credits/job share min(72, max(0, soft limit − 128))
with the four-worker pool; no limit is raised. Worker cleanup retains every
queue/stream/credit charge after freeze. Fresh checked component rewalks preserve
k104 policy/canonical-path obligations. Native opaque opens and normally launched
listener/store/action serviceability stay mandatory subjects. The producer cuts
its mandatory load-bearing review before planning.

The durable design marks native producer reviews and all runtime/binary acceptance pending;
arbitrary sampling is unaccepted and the diagnostic choice adds no new ABI.

## Decisions (running log)

- Consume k73's prompt-free metadata route only for its measured calls. Search
  performs no document handler lookup and adds no consent or entitlement.
- Compare bounded directory-name enumeration with Spotlight in the isolated
  VM. A diagnostic workspace bundle runs inside the actual signed hardened
  Koine host; its instrumentation is test-only and does not ship.
- Retain the agreed public GraphQL, native provider binary and isolated VM
  seams. Query entry, chooser, action menu, MRU and clipboard remain client-owned.


k107 applies k106's bounded repairs: turn-before-read checks, one changed-prefix/
parent root remainder, target-only exact exceptions, repeated component-walk
costs, restored 36-project/position-12 and explicit same-level loss fixtures,
summed-reservation lowered-limit latching, disabled-cohort recovery guidance and
a traversal ADR separate from coverage vocabulary. Real native path/resource
selection is externalized, not repaired by assumption: search-canonical-paths-k108
owns lossless canonical calls/native size grouping and reachable queue subjects;
search-native-resources-k109 owns opaque error-health signals and constructible
transient-descriptor/accept-backoff serviceability measurement. Both cut mandatory
load-bearing reviews before planning. k93 still owns measured workflow omissions;
all runtime/binary/native acceptance remains pending.

k108 chooses a unified public fsgetpath observation with descriptor-derived
identity, before/after mount/association checks, a fixed 8,192-byte NUL-inclusive
buffer and no alternate spelling. Native directory text is at most 8,191 bytes;
public requested/returned ceilings and the eligible domain remain unchanged.
Known size omissions before finalization use actual-parent groups; a formerly
fitting current/prefix/queued path now too long stops once as change, without
retroactive name omissions. Constructible native 4,224-byte tasks have a 79/80
byte boundary; controlled 43/44 arithmetic remains separate. The spec, call
analysis and canonical view carry the detailed subjects. Its mandatory
load-bearing review, k109 design/review, all native outcomes and k93's measured
workflow-omissions decision remain ahead of planning/acceptance.

k109 is now a design node. k111 records error-channel and tracing feasibility
in docs/verification/search-native-resources.md and the resource comparison;
it selects no runtime route. k112 owns the bounded native allocation decision,
and k113 owns serviceability subject construction and the mandatory review of
the complete k109 artifact. All original k109 completion conditions still bind.
Planning/acceptance, helper packaging/signing, consent, limit changes and any
reduced metadata/domain guarantee remain unapproved.
