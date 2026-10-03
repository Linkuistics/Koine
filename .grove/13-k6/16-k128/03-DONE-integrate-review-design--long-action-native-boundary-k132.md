# long-action-native-boundary-k132

**Integrates:** long-action-native-boundary-k131

## Goal

Triage the findings of `long-action-native-boundary-k131` against the native
boundary, proposed failure repair and independent subjects from
`long-action-native-boundary-k129`, then apply the real ones.
`long-action-route-k130` must start from a boundary and error contract it can
build on, without rediscovering these defects.

## Context

- Read the findings in the review's own leaf and commit. This charter does not
  restate them. They are anchored to producer `d57d2bae7837`, whose coordinates
  equal the review's tree.
- The artifact:
  - `docs/verification/long-action-native-boundary.md` and its declaration
    probe;
  - `docs/specs/workspace-launch-and-open.md`: the long-location boundary, the
    outcome table and the acceptance rows;
  - the search handoff in `docs/specs/workspace-search.md`;
  - the client guide, the workflow trace, `CONTEXT.md`, the workspace SDL and
    examples, and the architecture viewer;
  - `Taskfile.yml`.
- Code and tests to read, and not to change in this design integration:
  - `Providers/WorkspaceProvider` (native adapter, selection, open, reveal,
    observation);
  - `Tests/KoineServerTests/WorkspaceProviderTests.swift`;
  - the contract-only client adapter.
- Parent `long-search-result-actions-k128` keeps its whole original mandate and
  approval posture.

## Done when

- Each finding is classified as one of:
  - a contract stated unclearly;
  - a real issue, fixed in the design artifacts;
  - a visible accepted trade-off;
  - noise.

  Each classification is recorded in this leaf's running log.
- Every reconciliation a real finding needs lands in this commit: the spec, the
  verification, the guide, the trace, the glossary, the SDL comments and the
  viewer. Changes to code, tests or the contract client are left for planning
  as stated obligations. They are not edited here.
- A decision that belongs to Antony is escalated as a concrete trade-off with a
  recommendation. It is never settled silently. Such decisions include:
  - an incompatible meaning under the unchanged 1.0.0 version;
  - accepting a registered long copy that breaks short launches;
  - a systematic null receipt process for long applications.
- A finding that needs the route rethought rather than repaired becomes a new
  producer review chain. It is not done here, and this leaf completes no route.
- Existing Taskfile checks run on changed artifacts. No native action subject
  runs. `long-action-route-k130` and the search consumers stay after this leaf.

## Notes

No shorter search ceiling, copy-only or disabled baseline, new consent, setup or
entitlement, private policy or accepted workflow loss is approved by this
integration.

## Decisions (running log)

- Read the findings from review commit `76c37327`, against producer
  `d57d2bae7837`. The working copy began empty. The graph CLI refused the active
  unverified generation; no project, generation or coverage verdict was obtained.
  Verification uses the exact native adapter, selection/open/observation logic,
  N fixtures, contract client and cited design documents. No native subject runs.
- **B1 — contract stated unclearly, repaired.** Preserve k75's accepted
  `PATH_NOT_FOUND` for an established cycle and a component established to exceed
  the relevant filesystem's name limit. ELOOP alone does not establish a cycle;
  ENAMETOOLONG alone does not establish an impossible component. Whole/expanded
  path-size refusal and unresolved link-budget exhaustion are `failed`.
  The cycle and 300-byte component fixtures remain required repaired-provider
  regressions, with new evidence for their classification. Historical 1.0.0
  evidence is kept as baseline evidence, not a repaired-provider pass. Planning
  must update the native comment, N fixture provenance, client coverage and its
  findings record; none of those implementations is changed here.
- **B2 — contract stated unclearly, repaired.** A successful applicable native
  acquisition reporting no content type retains the accepted non-refusal; a
  checked bundle with no declared identifier retains mismatch for a named
  selector and eligibility as an identifier-free default handler. Unacquired,
  malformed or observed-failed facts are different outcomes and cannot be
  encoded as those nils. Required type flags/identity never default to false or
  none. The route producer must carry that distinction across the existing
  inspection seam and prove long executable/alias/application refusal.
- **B3 — real scheduling issue, repaired.** Launch-and-open planning owns
  independently constructed long action fixtures and L/G/N/V action acceptance.
  App-and-file-search planning/acceptance owns the additional actual-search
  provenance and end-to-end G/N/V rows. Search design consumes a reviewed route;
  search acceptance consumes an accepted action provider. Neither row closes
  the other, and all original working subjects remain required.
- **B4 — real issue, repaired.** Design the action-only correction as workspace
  release/schema 1.0.1 under `koine-desktop/1`, separately from retained 1.0.0
  and the search release/schema 1.1.0. Preserve the accepted short-cycle,
  impossible-component and established-nil outcomes and all public shapes.
  This is a compatible correction to unjustified negative results, not approval
  to reverse documented working cases. Specify exact description additions in
  a separate repair SDL, require canonical description/digest controls and exact
  candidate pins at implementation. A numeric served digest requires the actual
  host composition and is not invented here. Any unavoidable incompatible
  meaning returns to Antony before adoption.
- **B5 — real issue, repaired as a route obligation.** A registered long copy
  must not break short constrained/unconstrained launch or named open, including
  Finder readiness for reveal. Keep uncertain candidate equality as failure;
  do not solve it by skipping a candidate. Add both enumeration orders and
  preferred-long registration subjects. Any remaining workflow loss requires
  Antony's decision; it is not accepted here.
- **B6 — real issue, repaired as a route obligation.** Default file-URL handler
  discovery is its own native consumer. Its nil has no error provenance in the
  current adapter. Require a supported, applicable acquisition establishing a
  no-handler report; a target presence check alone cannot do so. Unestablished
  lookup is failed. Add first-use long-file/directory prompt subjects, retaining
  the separate protected-default-open decision and no new consent.
- **B7 — real issue, repaired.** Record selected registered application spelling
  separately from the caller's constraint and document/reveal target bytes.
  Selection remains by native identity, not identical text. Include callback
  executable identity, proc_pidpath and live executable identity as receipt
  consumers. Record long-app process receipts and independent identities;
  systematic length-caused null is a defect to repair or an explicit Antony
  trade-off, not silently accepted because the field is nullable.
- **B8 — real evidence overclaim, repaired.** L covers planner behavior for
  supplied adapter outcomes only. N component-created host fixtures exercise
  real errno/Foundation/plist classification; V checks guest behavior. Do not
  add another seam or claim that L tested a classifier below its substitution.
- **B9 — real issue, repaired.** Add explicit dependency and payload-refusal
  branches to the boundary view and a pre-submission uncertainty row to the
  outcome table. Repair the guide conjunction and reconcile its baseline and
  designed meanings.
- **B10 — real issue, repaired.** Require positive controls for long-path
  delivery/selection/identity observers through an independent non-Koine route.
  Observer limitations leave the affected observation pending, never pass/fail
  Koine. Make the nine-import `nm -u` check part of the existing declaration
  task and describe linking as checking SDK stub exports, not guest symbols.
- These are bounded contract/evidence repairs. No supported route is chosen or
  rethought here; the existing k130 producer and parent mandatory review own
  that work. No new ADR meets the hard-to-reverse AND surprising AND trade-off
  test; existing authority/selection ADR decisions remain unchanged. A formal
  model cannot establish opaque native byte limits or guest outcomes; exact
  source, SDL structure checks and pending native subjects are the instruments.
- The new repair check initially failed because its standalone test schema
  omitted Mutation, unlike the existing workspace check. Adding that placeholder
  fixed the check input; the unchanged action shape and three appended
  descriptions then passed with the unchanged-baseline negative control.
- Decline an in-session doubt reviewer: executable SDL/import controls directly
  check this integration's deterministic claims, and k130 must cut the parent's
  final load-bearing review over the complete route/artifact set before any
  consumer. Native acquisition/actionability doubts cannot be discharged by a
  second read of this boundary; they remain explicit producer and N/V obligations.
- Verification passed: `task design:action-repair-check` (including the existing
  workspace check), `task design:search-check`, `task design:workspace-render`,
  `task design:long-action-api-check` and `task check:docs`. Controls rejected
  unknown/foreign fields, an unchanged repair description, removed search root,
  wrong search input/output and a missing intended import. SDK 27.0 / clang
  21.0.0 supplied declaration/stub-link evidence only; the probe was not executed.
  The viewer manifest parses and its discussion IDs resolve; the exported
  boundary diagram was visually inspected, without claiming browser/VM acceptance.
- Check subjects stayed unchanged during their reads: SHA-256 checks covered
  Taskfile, the desktop/action/repair/search SDL and both operation files, the
  four workspace renderer sources, declaration probe and client package/lock
  inputs. The final link check separately froze all non-skipped markdown sources,
  the viewer manifest, link-check script and Taskfile. Both before/after checks
  passed. The working diff contains no provider, native test or contract-client
  implementation changes. The retained action SDL changes comments only.
- All ten findings now have classifications and owned artifact repairs. k130
  stays live and must establish/review the supported route; retiring this leaf
  closes neither k128 nor any ancestor and supplies no long-action native pass.
