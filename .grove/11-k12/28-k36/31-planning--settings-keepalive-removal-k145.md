# settings-keepalive-removal-k145

## Goal

Plan the remaining k36 harness work without Koine's keepalive captures and
without the k96 owner. Antony approved this on 2026-11-21. The ADR
`docs/adr/settings-harness-takes-no-keepalive-captures.md` records the decision.

## Context

The running log of settings-keepalive-profile-reconciliation-k126 holds the
evidence and Antony's exact words. Pruning k126 closed k96. Its documents stay
as history, and no consumer waits for its design. The harness relies on macOS
27.2.1 (26B131) with Tart 2.42.0. It must not rely on the TestAnyware VNC
keeper, because the next TestAnyware version removes it.

These live texts still require the keepalive or the k96 design:

- The root brief: the k96 owner-design scope under "Decomposition".
- The k12 brief: the later keepalive agreement under "Decomposition and authority".
- The k36 brief: "Why this level exists" and the k96 bullet under "Shared
  harness obligations and owners".
- settings-file-lifecycle-k89: its "Keepalive consumption hold" and k96 prerequisite.
- settings-exec-confirmations-k81 and settings-scenario-adoption-k76: their
  prerequisites on the full k96 design.
- `docs/specs/settings-activation-discrimination.md`: the section "Keepalive
  coordination hold" and its rows in the original-duty comparison.
- `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`: its
  keepalive hold, scope and work references.
- The scripts that contain the legacy keepalive: `scripts/vm-verify-lib.sh`,
  `scripts/vm-capture-evidence-lib.sh`, `scripts/vm-verify-grant-workflows.sh`
  and `scripts/vm-verify-grant-workflow-client.py`.

Keepalive captures were required evidence only because the loop took them.
Their removal removes no scenario observation. Find any assertion or audit
that still depends on them before you remove them.

## Done when

- Each listed text drops its keepalive or k96 requirement and cites the ADR,
  or states why the requirement stays.
- An implementation leaf owns the removal of the keepalive loop. It names the
  exact files, the controls and any earned review. It runs before the first consumer.
- The k54 freeze duties pin the host macOS and Tart versions. They also record
  the residual test-driver risk from the ADR.
- Every withdrawn duty cites the ADR. No original duty disappears silently.
- Every other k36 contract stays binding. Amend a brief or spec only as far as
  the approved decision reaches.

## Notes

- This decision authorises no VM, E/A slot, freeze, acceptance or release.
- A shared script may also serve other verification work. Plan its removal
  without breaking that work, or keep the shared part and stop its Settings use.
- TestAnyware issue 13 belongs to TestAnyware. Post nothing there without
  Antony's explicit approval.
