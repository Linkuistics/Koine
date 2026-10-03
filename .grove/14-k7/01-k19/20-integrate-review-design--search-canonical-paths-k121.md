# search-canonical-paths-k121

**Integrates:** search-canonical-paths-k110

## Goal

Triage the findings of `search-canonical-paths-k110` against the fsgetpath
canonical-directory design from `search-canonical-paths-k108`, then apply the
real ones. Planning must start from a canonical-path, size-refusal,
link-resolution and subject contract it can build and accept, without
rediscovering these defects in the adapter.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them.
  - They are anchored to the current tree at the review's commit. The k108
    sections there are byte-identical to producer `2e41af85d44f`, shifted by
    +27 lines (canonical observation) and +582 lines (subjects).
  - Some evidence comes from reading the SDK headers, the man pages and xnu
    `main` sources, plus one read-only host `stat` labelled as not guest
    evidence. None of it is native acceptance.
- The artifact:
  - `docs/specs/workspace-search.md`, including k119's in-process call
    contract, which the review found shares text with k108's rules;
  - `docs/verification/search-canonical-paths.md`;
  - both search ADRs and the traversal ADR;
  - the search SDL and examples, the search terms in `CONTEXT.md`, and the
    client guide's search section;
  - the workflow trace rows;
  - the canonical, traversal, coverage and handoff views with their exports,
    captions, manifest and README;
  - the brief chain.
- Keep k103's transport, outcome, lifecycle and compatibility meanings.
- Keep k104's canonical-parent policy checks, unified spelling, witness
  accounting and worker ownership, and k107's turn-before-read checks,
  changed-prefix root remainder and target-only exact exceptions. Depart from
  one only where a finding shows that it does not hold.
- Approval is unchanged. None of the following is authorized: a new consent,
  entitlement, usage key, setup, long-path iopolicy or private API; a raised
  limit; a smaller domain; a shorter public value ceiling; an incompatible
  version.
- Any lost workflow coverage goes to Antony through `protected-home-search-k93`,
  not into the design as accepted.

## Done when

- Classify every finding as one of:
  - a contract stated unclearly;
  - valid and actionable;
  - a visible trade-off;
  - noise.

  Record the verdict and reason in the running log, and apply the actionable
  repairs in place across every affected durable artifact and summary.
- Escalate before relying on any change that alters workflow coverage, approval
  posture or k119's selected call set.
- Regenerate the changed views, and run `task design:search-render`,
  `task design:search-check` and `task check:docs` on frozen inputs.
- A repair may amount to a substantive redesign, such as a new classification
  route or a resolver specification. If so, externalize it as a design producer
  that cuts its own load-bearing review, rather than absorbing it here.
- The complete-resource review `search-native-resources-k120` follows this leaf.
  Any shared k119 text this integration changes must be reconciled before it
  runs.
- Planning `app-and-file-search-k30` still waits on this integration, k120 and
  any chains they earn.

## Notes

This is design triage only: no implementation and no native evidence chain.
All native, binary, prompt and useful-coverage acceptance remains pending.
