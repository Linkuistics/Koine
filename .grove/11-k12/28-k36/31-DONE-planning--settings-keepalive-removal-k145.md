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
  or states why the requirement stays. This leaf amends the listed briefs and
  tasks. settings-keepalive-contract-removal-k146 owns the spec and the
  evaluation plan. settings-keepalive-loop-removal-k147 owns the scripts.
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

## Decisions (running log)

- 2026-11-21: The grant-workflow "keepalive" in `vm-verify-grant-workflows.sh`
  and `vm-verify-grant-workflow-client.py` is not the VNC keepalive. It holds
  one HTTP connection across a revocation, which is a product acceptance case.
  It stays. The HTTP keep-alive text in `README.md`, `docs/specs/machine.md`
  and the grant-workflow and latency documents stays for the same reason.
- 2026-11-21: Two VNC keepalive loops exist. The legacy loop in `start_vm` in
  `vm-verify-lib.sh` serves about 30 verification scripts. The strict helper
  `keepalive_guest_evidence` in `vm-capture-evidence-lib.sh` has no caller
  outside its bats tests. The complete scenario `vm-verify-menu-bar.sh` calls
  `start_vm`. Thus both evaluation sets start the legacy loop today.
- 2026-11-21: The removal removes the strict helper and its tests. It keeps the
  shared loop for the other scripts and stops it in the Settings scenario only.
  The ADR covers the Settings harness alone. Removal from every script would
  reach further than the approved decision.
- 2026-11-21: No scenario assertion or audit reads a keepalive capture. The
  legacy loop writes `keepalive.png` in the temporary work directory, and
  cleanup removes it. No check script reads a keepalive operation. The
  implementation leaf checks this with controls before it removes code.
- 2026-11-21: The ADR withdraws these duties:
  - the sleep-20 keepalive loop and its required tick captures
  - per-tick image volume
  - the ownership-delay amendment to the driver-wait exclusion
  - the finite resource profile
  - the cooperative keepalive stop and worker supervision
  - the keepalive-only test seams
  - the k96 chain of design, review, planning and implementation.

  The driver-wait exclusion applies in full again. All other capture, writer,
  latch, retention, signal and held-pointer duties stay.
- 2026-11-21: The spec and the evaluation plan go to a separate `design` leaf.
  Each touched section of both documents is in a `pending` region. Their
  conversion rewrites about 250 lines of binding contract text, which needs
  its own session. The glossary terms and the history notes on the owner
  documents go to the same leaf.
- 2026-11-21: Placement: the design leaf and the implementation leaf are
  ordered siblings under k36, before k89. They share the k36 scope and need no
  new context, so no new node is earned.
- 2026-11-21: The k54 freeze pins the host macOS version and build and the
  Tart version. A mismatch holds before E01 for a new decision, which is the
  ADR's reopen condition. The frozen TestAnyware version may still start its
  passive VNC keeper. The harness neither relies on it nor disables it.
- 2026-11-21: The seven grove texts failed the controlled-English checker with
  144 hard findings. This session converted them first, in their own commit. A
  token comparison found no lost handle, file reference or named term. A
  deliberately removed handle showed that the comparison detects a loss.
- 2026-11-21: Grove allocated settings-keepalive-contract-removal-k146 as the
  `design` leaf and settings-keepalive-loop-removal-k147 as the `impl` leaf.
  Both sit before k89. The root, k12 and k36 briefs and the k89, k81, k76 and
  k54 tasks now cite the ADR. The k36 brief and the k89, k81 and k76 tasks
  name k146 and k147 as the prerequisite.
- 2026-11-21: The spec and the plan keep their keepalive text until k146 runs.
  The k36 brief puts k146 and k147 before every consumer, so no consumer reads
  that text as binding.
- 2026-11-21: A sweep of the live grove texts found keepalive or k96 only in
  withdrawals that cite the ADR and in k146 and k147. Without the filter, the
  same sweep found the term in the terminal k96 files.
- 2026-11-21: This plan earns no `review-planning` leaf. It carries out an
  approved decision with two bounded leaves. k146 decides on an independent
  read of the converted contract text.
