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
