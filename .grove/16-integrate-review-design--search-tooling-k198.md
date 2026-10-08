# search-tooling-k198

**Integrates:** search-tooling-k197

## Goal

Triage the findings of `search-tooling-k197` against the tool-backed search design
from `search-tooling-k195`, then apply the real ones, so that
`search-tool-permissions-k196` puts to Antony only the choices the reviewed
mechanism actually leaves open — with their concrete alternatives — and later
search design consumes a coherent contract.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `ecaaf6de6fed`, whose coordinates
  equal the review's tree.
- The artifact: `docs/specs/workspace-search.md`, `docs/verification/search-tooling.md`,
  the search SDL/examples, `docs/adr/search-enumeration-reuses-system-find.md` and
  the other search ADRs, `docs/adr/filesystem-access-is-descriptor-relative.md`,
  the workflow trace's authority allocation, search rows and call-path seam,
  `scripts/check-launch-call-path.sh`, Machine's search notes, CONTEXT, the
  client guide's search section, the changed search views/README, and the root,
  k7, k19, k109 and k126 briefs plus the live k196/k191/k193/k127/k123/k120/k30/k93
  leaves that consume this design.
- Approval is unchanged. No child process, lookup-only exemption, consent,
  entitlement, usage key, setup, helper, signing or limit change, smaller domain
  or accepted workflow loss is authorized by integrating findings. Lost coverage
  goes to Antony (k196 or `protected-home-search-k93`), never silently into the
  contract.

## Done when

- Every finding is classified — a contract stated unclearly, valid and
  actionable, a visible accepted trade-off, or noise — with the reason recorded
  in this leaf's running log, and each actionable one is applied where it lives.
- The high findings are settled before k196 runs: the comparison and enumeration
  ADR weigh the in-process OS walkers with their real costs, and k196's refusal
  branch names a concrete alternative (T1); the home ordering consequence is
  stated and either resolved by a find-backed source structure or added to
  k196's choices (T2); the module/call-path and authority-allocation decision for
  spawn, signal and reap effects is made or chartered before implementation, and
  the call-path seam obligation is restored in k7/k30 (T3).
- k196's charter is updated for whatever the integration changes in its premises
  — anchor metadata contact, root spelling aliases, the materialization policy
  and ordering — without pre-answering Antony's choices.
- Downstream charters (k191 root qualification, k127 spawn attributes and
  stopping rule, k123 recognition bound, k93's two separate acceptances) carry
  the obligations the integration assigns rather than applies.
- Frozen design:search-render, design:search-check and check:docs pass on the
  changed inputs, and changed views are inspected. A substantive redesign
  beyond triage is externalized as a new design leaf with its own mandatory
  review before k196, not absorbed here.

## Notes

At most one narrow in-session reviewer. No native experiment, backend run or
implementation. The review's confirmations section lists what it re-derived as
sound; do not reopen those without new evidence.
