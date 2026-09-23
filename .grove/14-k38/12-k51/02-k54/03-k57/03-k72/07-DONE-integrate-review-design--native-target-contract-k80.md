# native-target-contract-k80

**Integrates:** native-target-contract-k79

## Goal

Triage the design review of k78's endpoint-addressing contract. Apply the valid
findings to the contract artifact and its rollups before k75 designs the full
protocol against it.

## Context

- The findings are in k79's own task file and commit. Read them there, and read
  k78's committed artifact (`70fec1f`) together with the proposal revision the
  human chose from. The review cites both.
- The human selected B, endpoint addressing only (k78's running log). Triage
  must neither infer a relaxation the human did not agree to nor restore the
  excluded strict effect promise. Where the agreement's extent is unclear, take
  the concrete trade-off to the human, framed as `references/execute.md` directs.
- No shipping mechanism, lifecycle policy, restart policy or first release is
  approved. The integration changes documents and rollups only, not native
  behavior or production code.

## Done when

- Every k79 finding is classified as valid and applied, unclear-contract and
  settled with the human, a visible accepted trade-off, or rejected with a
  reason. Each classification is recorded in this file's running log.
- The spec, capture ADR (or the set it becomes), client guide, glossary, README,
  architecture views, parent rollups and k75's charter agree with the settled
  outcome. Citations are chased wherever the ADR set is reworked.
- k75 remains the owner of the complete capture/transfer/reference/restart
  protocol and of the k52 handoff. No parent closes because of this integration.

## Notes

One narrow in-session reviewer is allowed. Substantial redesign found here is
externalized as a new producer review chain beside this leaf, not absorbed.
Anything that renders or inspects the architecture viewer runs in a disposable
TestAnyware clone, never on the host.

## Decisions (running log)

- Finding 1: valid omission in the agreement paraphrase and rollups. The
  selected option B in revision `17ef8626` explicitly says another window or
  process may be affected; its detailed boundary includes a live original
  process. Restore same-process wrong-window wording without re-asking B.
- Finding 2: unclear contract. Observed closure retirement versus unconditional
  closed-window refusal is put to the human with the concrete descriptor-reuse
  consequence. No closure relaxation is inferred from the effect agreement.
  Source fallback confirms PID-based observer registration and PID-only
  termination delivery in the served `WindowObservation.swift`; that mechanism
  cannot be assumed to satisfy the new observation boundary.
- The human selected **Accept observed-closure retirement**: authenticated
  observed closure permanently retires the reference; undetected closure or
  descriptor reuse may still target another window. This explicitly qualifies
  the inherited unconditional closed-window refusal. k75 must establish the
  observation/attribution mechanism and refusal evidence; no native result or
  shipping implementation is supplied by the agreement. Finding 2 is now an
  unclear contract settled with the human, to be propagated into every rollup.
- Findings 3 and 4: valid contract omissions. Preserve read/observation
  provenance: authenticate every reply used as captured-process data, then
  compare with the continuously retained task while live. Cached PID/version
  values are not identity. Require separate freshness, descriptor attribution
  and notification-provenance evidence; sender authentication alone does not
  prove arbitrary handler data truthful. Mismatch or unknown provenance supplies
  no listing/confirmation and stops later primitives. No read relaxation is
  inferred and no native feasibility is claimed.
- Finding 5: valid overstatement. Refusal before any send means this operation
  sent nothing; possible sends leave uncertainty and earlier work may still act.
- Finding 6: valid missing distinction. Name the private-adapter OS/protocol
  compatibility profile separately from an unselected behavioral application
  profile. Unknown/unsupported protocol forms fail the affected operation as
  unavailable, never silently remove windows or invite a consent grant. k75
  still owns exact wire/error fields and agreement to actual supported forms.
- Finding 7: valid separation of independently reversible decisions. Split
  capture/lifetime and endpoint effect boundary into two current ADRs; preserve
  alternatives and rationale, move open adoption work to the spec, reconcile
  current citations, and retain historical evidence as history.
- Finding 8: valid charter ambiguity. k75 writes the evidence-renewal
  instructions; k52 executes them on rebuilt signed/notarized bytes.
- Finding 9: valid terminology ambiguity. Define endpoint admission separately
  from grant/dispatch admission; neither establishes the other's obligation.

## Integration and verification

All nine findings are applied. Finding 2 was settled with the human as recorded
above; the others repair the existing agreement or its expression. Capture and
endpoint effects have separate current ADRs, with current citations reconciled.
The spec, client guide, glossary, README, architecture views, parent rollups and
k75 now carry same-process wrong-window effects, observed-closure retirement,
retained read/notification provenance, refusal stages and separate admission and
compatibility terminology. Historical experiment conclusions remain bounded to
their original contract; their introductory links distinguish the current one.
No shipping mechanism or native behavior is adopted. No in-session reviewer
was used; these repairs introduce no separate producer redesign.

`task design:render-process-identity` passed inside disposable TestAnyware clone
`koine-k80-design`, using PlantUML 1.2026.8 with its Smetana layout engine and an
arm64 Java runtime. Initial renderer attempts exposed guest runtime/loader
dependencies; after supplying those in the clone the full task exited zero.
Only the two changed SVG exports were copied back. Both full PNG exports and
fresh Safari targeting, adoption and discussion deep links were inspected.
Desktop light appearance was checked; no mobile, dark-mode or native-binding
acceptance is claimed. The clone was stopped.

Relative-link validation passed for the changed Markdown documents, checking
target paths and referenced Markdown heading anchors. Deliberate missing-path
and missing-anchor controls failed, and the known contract anchor passed.
Document/link-target hashes stayed unchanged across that run. In the VM, the
manifest's IDs and source/export paths passed; a missing discussion ID was
rejected. Viewer, manifest, both PlantUML sources and both SVG hashes matched
host/guest and stayed stable during final checks; HTTP-delivered manifest and
SVG bytes matched too. `git diff --check` passed as read-only verification.

Tier 2 project `Users-antony-Development-Koine` was ready at bootstrap. Coverage
generation `2026-09-23T08:51:00Z` reported matching metadata and no recorded gaps
for the changed Markdown/manifest, Taskfile, viewer and WindowObservation.
Graph symbol discovery for WindowObservation returned no candidates, so its
complete source was read directly; the PID registration/delivery finding relies
on that source, not absence from the graph. PlantUML was untracked by the graph
and SVG excluded; direct source reads and full rendered inspection cover them.
Coverage is best effort, not proof of completeness.

k52's existing handoff is byte-identical to the parent revision. No production
source or schema changed, so no production test or native acceptance rerun was
needed. k75 still owns complete capture/transfer, observation, lifecycle,
consent, reference/restart/version agreement and k52's renewal instructions.
Its live leaf prevents any ancestor close; retirement is k80 only.
