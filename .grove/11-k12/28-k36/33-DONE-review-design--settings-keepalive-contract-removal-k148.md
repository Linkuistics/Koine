# settings-keepalive-contract-removal-k148

**Reviews:** settings-keepalive-contract-removal-k146

## Goal

Read the k146 amendment of the Settings contract independently. Find each duty
that the amendment lost, weakened or added. Find each place where it reaches
further or less far than the ADR `settings-harness-takes-no-keepalive-captures`.
Report the findings. Do not repair them.

## Context

- `docs/adr/settings-harness-takes-no-keepalive-captures.md` holds the decision.
- The running log of settings-keepalive-removal-k145 lists the withdrawn and the
  retained duties. Read it in the commit that retired that leaf.
- k146 landed in two commits. The first commit converts the touched passages of
  `docs/specs/settings-activation-discrimination.md` and
  `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md` to
  controlled English. It claims no change of meaning.
- The second commit withdraws the keepalive requirements and adds the host pin
  and the residual test-driver risk. It also changes `CONTEXT.md`, four history
  documents and the visual README in `docs/design/architecture/settings-activation/`.
- The k146 task file states the done criteria. Its running log records the
  judgement calls of that session. Read the log after your own read, not before.

## Done when

- Each converted passage is compared with its parent text. Each lost or added
  fact, hedge, caveat, link or named term is a finding.
- Each withdrawal is compared with the ADR and the k145 log. A withdrawn duty
  that still binds is a finding. A retained duty that the amendment dropped or
  weakened is a finding.
- The host pin and the residual risk in the spec and the plan are compared with
  the ADR and the task of settings-ordering-qualification-k54.
- The glossary removals are compared with the live briefs, the live tasks, the
  specs and the plan.
- If a finding is worth action, cut an `integrate-review-design` leaf as the
  last act. Its body names this review's handle, not the findings.

## Notes

- This review authorises no VM, slot, freeze, acceptance or release.
- Post nothing on TestAnyware issue 13.

## Findings

No material finding is supported. No integration leaf is needed.

The review compares the controlled-English commit `f94a3345` with its parent
`ed85c000`, and the amendment `b68ca22b` with `f94a3345`. It uses the ADR and
the k145 running log from `ed85c000` as the scope contract. The k146 running
log was read after the independent comparison.

- **Language conversion:** Each changed passage and each table row preserves
  its facts, qualifications, links and named terms. The expansion of persisted
  reopens `2/3` to `2 and 3` preserves the two unrun reopens. The converted
  passages do not change acceptance or authority.
- **Withdrawals:** The removed tick captures, ownership delays, resource
  profile, worker stop, worker supervision and keepalive-only controls match
  the k145 list. The single writer and ordinal domain, capture-validation
  barrier, sticky failure, private originals and partials, signals and both
  held-pointer cases remain. The remaining implementation and review duties
  still precede consumption. The history notes withdraw the rejected design;
  the current contract retains the independent helper and ordinary duties.
- **Resources:** The spec's original-duty row at line 561 says that the harness
  needs no resource profile, limit or capacity reservation. In that row, those
  are the withdrawn owner-profile requirements. This does not remove finite
  storage planning: the k36 brief and the live k76 and k57 tasks still require
  it. K89 also carries the current capture allocation and partial-record
  limitations. Those limitations are disclosed in
  `ORDERING-CAPTURE-RESULTS.md`, lines 140–152; they are not an existing promise
  of enforced caps or guaranteed collection. No new resource mechanism is
  required to preserve these duties.
- **Host and outcome:** The spec and the plan pin macOS 27.2.1 (26B131) and
  Tart 2.42.0, require a new decision on mismatch and preserve the residual
  test-driver failure with no retry. The plan records the host before the
  first clone request. Its passive-keeper rule matches k54 and k145. Neither
  document claims a new runtime result or broad reliability.
- **Glossary and references:** All 33 removed definitions belong to the
  rejected owner. A case-insensitive search that also handles wrapped terms
  found their remaining uses only in withdrawals and the closed k96 brief.
  The search covered the grove texts, current spec sections and evaluation
  plan. The parent glossary supplied a positive control for every removed
  term; a wrapped term and an unrelated replacement checked the matcher.
  The retained Settings sequence caller still names the finite E/A caller.
  The keepalive-coordination-hold heading and its existing anchor remain.

## Decisions (running log)

- 2026-11-21: The potential resource-waiver concern does not meet the repair
  threshold. The owner-profile row removes enforced limits and reservations;
  the independent finite-storage and capture-limitation handoffs remain
  explicit. This review requests no new cap, profile or resource design.
- 2026-11-21: The inspection supports no material finding about the conversion,
  withdrawal, host pin or glossary removal. Do not cut an integration leaf.
  K147 remains the next implementation step; no ancestor closes here.
- 2026-11-21: This was an inspection-only review. No test, build, lint, format,
  VM, freeze or runtime command was run, and no production or test code was
  edited. Graph coverage was checked at generation
  `2026-11-21T11:10:20Z`. Changed document metadata and renamed task paths were
  not fresh in the graph, so the conclusions use direct current-file reads
  and committed diffs. Coverage reports no recorded gap for the checked paths
  or the grove/spec scopes; that is not a completeness guarantee.
