# settings-keepalive-native-evidence-scope-k144

**Integrates:** settings-keepalive-native-evidence-scope-k143

## Goal

Integrate the supported k143 findings into the k125 external evidence scope
before k126 consumes it.

## Context

Read the findings from the commit that retires
settings-keepalive-native-evidence-scope-k143. The artifacts are
`docs/verification/settings-activation/KEEPALIVE-EVIDENCE-SCOPE.md` and
`docs/design/architecture/settings-activation/keepalive-evidence.mmd`, with the
README and both diagram manifests that point to them. The accepted boundary is
`KEEPALIVE-ACCOUNTING.md`, `KEEPALIVE-CALLER.md`, `KEEPALIVE-QUALIFICATION.md`,
`KEEPALIVE-RAW-CONTROLS.md`, `KEEPALIVE-RESOURCES.md` and
`docs/specs/settings-capture-resource-contract.md`.

## Done when

- Classify each of the six findings as a contract question, a real issue, an
  accepted trade-off or noise, with the reason.
- Apply each accepted correction and every linked restatement in the README,
  the diagram and its manifests.
- Route a new family or a changed accepted count to k126 or to a new producer
  and review chain. Keep every count unchanged unless you show a source error.
- Retire only this leaf.

## Notes

Design documents only. This leaf authorises no implementation, VM, input,
Vision or native work, and no external message or authority request. Spend at
most one narrow in-session reviewer. This launch supplied no provider
evidence, so the review carries no Creator line.

## Decisions (running log)

- 2026-11-15: Read k143 from review commit `94a066d7d885881a427debbfd6b74ed786a7df89` and verify its findings against the accepted contracts.
  Keep this integration within design documents. Run no native work and send no external message.
- 2026-11-15: Classify finding 1 as a contract stated unclearly.
  Accounting charges each input occurrence and every OCR cycle, but the checklist omits their required bounds.
  Add both categories without inventing schema units.
- 2026-11-15: Classify finding 2 as a real issue.
  Preserved polling can exceed the planned recognition count. Require a source-derived maximum and a declared frame source before admission.
  Keep four operations and the `1,0,1,1` plan. Route any larger count or new execution family through k126 and fresh design review.
- 2026-11-15: Classify finding 3 as a real issue.
  The fixed R3 bursts cannot establish blocking when either route accepts at least 8192 bytes during the hold.
  Require route-specific capacity evidence and independent blocking observations. Keep both 8192-byte bursts and release without awaiting blocked writes.
  Route an infeasible schedule to k126 or a new producer and review chain.
- 2026-11-15: Classify finding 4 as a real issue in the declared effects.
  Historical ReportCrash processes establish possible service exposure, not pinned-host reporting behaviour.
  Require that behaviour and bounded report retention, or proven declared suppression. Missing evidence keeps the affected case unavailable.
- 2026-11-15: Classify finding 5 as a contract stated unclearly.
  Add the native prerequisite, the nonexecution handoff to k126 and the human-choice route. Describe Fe reconstruction as proposed.
- 2026-11-15: Classify finding 6 as a real prose issue.
  Convert the scope and README before the substantive corrections. Commit that conversion separately, as the controlled English guidance requires.
  No finding requires an accepted trade-off or rejection as noise.
- 2026-11-15: Complete the six corrections and their README, diagram and manifest restatements.
  These are evidence-admission corrections. No new workload family, accepted count, implementation or authority is added.
  No substantial redesign or new ADR is needed. K126 retains numerical reconciliation and whole-design review.
- 2026-11-15: Verify changed links and anchors, both JSON manifests and the required diagram connections.
  Verification of the diagram is static, without rendered Mermaid validation. The prose checker reports zero hard findings and no pending conversion.
  `mise exec -- task check:docs` still fails on two missing context-plan targets: `context-predicate.txt` and `context-qualify-filter.sh`.
  Verify both missing targets against review commit `94a066d7d885881a427debbfd6b74ed786a7df89`, with unchanged checker and context plan.
  Keep this pre-existing failure outside the integration. All changed-document links and anchors pass verification.
