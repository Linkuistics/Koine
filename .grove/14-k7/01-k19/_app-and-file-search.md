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
  planning; the nil-consent minor-2 mapping is withdrawn as an instruction.
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
6. `search-permission-transport-k97` settles compatible BLOCKED transport and
   the ADR/complete mapping contract; its producer cuts its own review.

Both producer/review repairs live in this node, so planning cannot run before
they retire. The durable design explicitly marks those decisions unsettled;
the integration did not accept either arbitrary sampling or the nil-consent ABI.

## Decisions (running log)

- Consume k73's prompt-free metadata route only for its measured calls. Search
  performs no document handler lookup and adds no consent or entitlement.
- Compare bounded directory-name enumeration with Spotlight in the isolated
  VM. A diagnostic workspace bundle runs inside the actual signed hardened
  Koine host; its instrumentation is test-only and does not ship.
- Retain the agreed public GraphQL, native provider binary and isolated VM
  seams. Query entry, chooser, action menu, MRU and clipboard remain client-owned.
