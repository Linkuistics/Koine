# first-party-provider-selection-k52

**Integrates:** first-party-provider-selection-k51


## Goal

Triage the findings of `first-party-provider-selection-k51` against the
first-party selection design from `first-party-provider-selection-k50`. Apply
the real ones to the design artifact, so launch-and-open consumes a settled
contract.

## Context

- The review's findings live in its own leaf and commit, anchored to the producer
  commit. Read them there; this charter deliberately does not restate them.
- The artifact is `docs/specs/machine.md#first-party-provider-selection` and the
  selection rows of `docs/specs/workflow-providers.md`, plus
  `docs/adr/koine-server-and-native-providers.md`,
  `docs/adr/resilient-provider-framework.md`, `CONTEXT.md` and the two selection
  views in `docs/design/architecture/` with their captions.
- The root brief's first-party selection paragraph and the launch-and-open node
  and design leaf cite this contract.

## Done when

- Each finding is classified: applied, rejected with a reason, or a stated
  accepted limit. Nothing is taken on as mandatory merely because the review
  raised it.
- Accepted changes are reflected consistently in the spec, the ADR set as a
  minimum coherent set, the glossary, the diagram sources, their exports and
  captions, and every brief that cites the contract.
- Any change that narrows what an approval record admits, alters signing posture,
  or changes the `koine-desktop/1` promise is raised with Antony, with a
  recommendation, before it is built on.
- The documentation checks and the selection render task pass after the edits.

## Notes

This integration runs before the launch-and-open node, so no consuming design or
planning sees the unsettled contract. Loader implementation and acceptance stay
with launch-and-open. Where a finding rests on platform reasoning rather than an
observation, prefer handing its confirmation to launch-and-open's native evidence
over widening this session.

## Decisions (running log)

Read findings S1–S10 from review commit `21a28eee42d8`, against producer
`d4043d4142fa`. The session began on its empty successor. Tier-2 graph evidence
uses generation `2026-09-29T10:36:20Z`: loadProviders has one caller and twelve
depth-two callees, with no truncated page. Exact trust/staging snippets and the
loader, composition, app-root and test-source ranges corroborate the review.
Coverage records no issue and matching metadata for those Swift files; docs and
scripts are excluded, and current glossary/brief/Taskfile metadata has changed,
so those surfaces are read directly. These are source findings, not VM results.

S1 is a real trust-contract issue. Proposed to Antony: retain the ID/Team-ID
approval record and require a stable catalogue signing identifier as well;
fixtures use identifiers admitted only by a test host. This distinguishes
accidental fixtures, not malicious code signed under a trusted release identity.
The binding change awaits his answer. Apple TN3127 supports identifier clauses;
no entitlement or certificate-class restriction is proposed.

S2 is a real policy inconsistency: reject each ambiguous highest release group
and continue the pre-load calculation to a unique lower update or the verified
bundle. Keep every refusal visible. This never reopens a frozen selection.

S3 is a real staging-identity defect: candidate origin and canonical installed
location must separate staged copies, including from legacy shared entries.
Keep quarantine on the copy assessed and loaded. The predicted modal consequence
is not yet observed; launch-and-open owns that signed-VM case.

S4 is a real old-host compatibility gap: newly published first-party updates
declare `first-party-selection-v1` in manifest and descriptor. Old hosts already
refuse unsupported features before load; renamed principal classes must be in
the acceptance pair. A packaged old baseline may remain feature-free.

S5 is a contract stated unclearly: assign every case its seams, use a fresh host
process and marker log per scenario, and construct sealed-root defects before
signing purpose-built test hosts. Order reversal belongs at the native seam.

S6 is a real publication hazard: first-party identities publish disjoint Swift
module and Objective-C runtime class names, including private helpers, or use
one host-owned framework image. Do not assert an observed duplicate-class failure;
mixed-release native/VM acceptance remains launch-and-open's work.

S7 is a contract stated unclearly. Complete selection/reason cases, retain a
missing-bundle diagnostic even when an update runs, and use enums for the new
closed-vocabulary fields. Reject reserving the valid provider ID `unknown`:
an impossible-identifier display sentinel can distinguish unidentified rows
without withdrawing an existing valid identity.

S8 is a contract stated unclearly: sort each composition group by identifier,
make overlapping-prefix refusal explicit, derive the signing team from the
verified running host, state the unsigned-host refusal, and distinguish loader
manifest collision checks from core descriptor/SDL checks.

S9 combines an unclear contract and accepted limits. Only pre-load-eligible
ordinary candidates contest manifest collisions. Retain symmetric refusal of
principal conflicts between shipped selections: each already owns an equal
shipped slot; physical origin cannot break that tie after freezing. State its
dependency-cascade cost. Determinism is conditional on verdicts; online assessment
and verification cost can vary and grow with the installed candidate set.

S10 is a documentation-shape repair. Separate update selection into its own
current-state ADR, qualify independent upgrades by host support, reconcile
citations and remove Grove vocabulary from durable decisions. This preserves
the one-loader architecture and does not commission a redesign.

Antony approved S1's identifier check in this session. The catalogue pins each
enabled provider's release signing identifier in addition to existing Team-ID
and explicit per-user approval checks. Fixtures use distinct identifiers in
purpose-built test catalogues; dependencies retain their own signing identifiers
and the existing team/signature checks. No entitlement, hash approval, or
certificate-class restriction is added. Signing under the trusted release
identifier remains a publisher responsibility, not a hostile-team sandbox.

Narrow doubt claim: removing ambiguous highest groups before freezing must leave
one deterministic choice and truthful diagnostics, without a later failure
reopening selection. A counterexample would leave the implementer unable to
reconcile the decision and reporting tables. Spend the integration's one narrow
fresh-context reviewer on that policy/diagnostics surface, using concrete
candidate-set counterexamples rather than re-reading the full review chain.

The narrow reviewer returned no substantive counterexample after checking the
selection and reporting tables against concrete tie, missing-bundle, principal
conflict and late-failure cases. No second review cycle is warranted. All ten
review findings are classified above; S1–S8 and S10 have contract/artifact repairs,
S7's proposed reservation of `unknown` is rejected in favor of an invalid-ID
sentinel, and S9's symmetric principal refusal and variable startup verification
remain visible accepted limits. Native observations remain pending in the
launch-and-open table; this integration does not claim runtime implementation.

## Verification

`task design:selection-render` and `task check:docs` passed after the artifact
edits. The presentation manifest's diagram IDs and source/export paths resolve;
both regenerated SVGs parse. SHA-256 snapshots of all documentation-checker
sources, its script, Taskfile, both selection diagram sources and both exports
were identical before and after the validation run (the per-file snapshots are
temporary verification output, not repository state).

Both light-background SVG exports were rasterized and visually inspected: the
tie loop, missing-bundle branch, frozen choice and publication/failure labels are
legible and unclipped. No browser surface was available, so the interactive
viewer and narrow/dark rendering were not exercised. No runtime code changed;
native/binary/VM acceptance remains explicitly pending in launch-and-open.

The root has live increments beginning with launch-and-open, so retiring this
root-level leaf closes no ancestor node. The approval decision and repaired
selection contract are carried in the root brief and launch-and-open briefs.
