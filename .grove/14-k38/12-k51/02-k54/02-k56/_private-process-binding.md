# private-process-binding-k56 — brief


## Goal

Establish whether a private server-side native endpoint can bind every desktop
effect to the process captured through public client APIs, preserving strict
process lifetime for arbitrary unmodified target applications. Deliver a concrete
feasibility result for `process-identity-contract-k57`, or an evidenced conflict
for the human if no viable route is established.

## Context

- The human authorized **investigating server-side private APIs**, after the
  public retained-AX candidate failed. This is not approval of a particular
  dependency, weaker identity, client private APIs, or new client consent.
- `docs/verification/retained-ax-binding.md` and its held-only result establish
  actual PID reuse and an effect on the successor. A task right, held AX parent,
  CFEqual, or another pre-check cannot be asserted as the missing binding.
- The installed Xcode 27/macOS 27 SDK's HIServices exports include
  `_AXUIElementCreateWithRemoteToken`, `_AXUIElementRemoteTokenCreate`,
  `_AXUIElementCreateWithDataAndPid`, and `_AXUIElementGetActualPid`.
  WebKit's `NSAccessibilityRemoteUIElement` SPI and cooperating-process token
  transfer are primary-source leads linked in the report. Exports and opaque
  token bytes are not proof of lifetime; investigate whether they merely encode
  PID plus reusable element data. The reconstruction candidates have now been
  tested and failed; the direct AX service lead remains untested.
- Initial code evidence was Tier 2, project `Users-antony-Development-Koine`,
  generation `2026-09-21T11:22:48Z`; provider identity/observation/effect files had
  matching metadata and no recorded gaps. Refresh before using. Exact source
  showed `act` and `hasFocus` create an AX application from PID, while window
  effects use retained objects. Heuristic graph calls into similarly named
  shell functions were not evidence.

## Done when

- For each candidate, identify acquisition from the captured process, endpoint
  ownership, lifetime and matching to the actual task; distinguish public
  client APIs, server-private APIs and assumptions about closed platform code.
- Account for restoration from the Dock, main-window selection, raise,
  application activation and focus confirmation. Include termination after
  admission and between native steps, actual PID recycling, exec replacement
  and automatic restoration. A post-check cannot undo a wrong effect.
- Test the material native lifetime claim with a targeted TestAnyware probe,
  reusing the existing PID-recycling fixture where useful. Keep build facts,
  observations and unproved generalizations distinct. For a viable candidate,
  establish signed/hardened availability and policy failure behavior sufficient
  to recommend it; do not infer that from SDK exports.
- Record the recommendation and trade-offs for the human, including maintenance
  risk and a reversal condition. Injection, privileged helpers and target-app
  cooperation are not authorized merely by allowing server-private investigation.
- Preserve findings in the existing evidence/ADR/design surfaces. A feasible
  result supplies k57 with an action-binding contract; an unresolved conflict
  stays explicit and cannot be silently weakened to best effort.

## Notes

All native/GUI execution is in a disposable TestAnyware clone. Build on the
host only. `task fixture:retained-ax` packages the public counterexample;
`task design:render-process-identity` renders the discussion. Respect the
one-reviewer allowance of this picked leaf; another review of the already
demonstrated public failure is unnecessary. An abstract model cannot prove
a native platform lifetime premise.

## Decomposition

AX wrapper reconstruction and direct transport are distinct platform questions:
the former has a complete native counterexample, while the latter needs actual
endpoint ownership, attribution and wire-protocol evidence.

1. `remote-token-lifetime-k58` preserves the signed/hardened private-wrapper
   PID-reuse counterexample, updates the ADR/discussion and records limitations.
2. `direct-ax-endpoint-k59` evaluates the direct `com.apple.axserver` endpoint
   and closes the original feasibility criteria above before k57's contract work.

## Decisions (running log)

- Investigate remote-token serialization first with a bounded PID-recycling
  diagnostic, keeping target applications unmodified and every native execution
  inside TestAnyware clone `koine-k56-binding`. Inspect the loaded private
  entry points before assigning their undocumented signatures. This is
  feasibility evidence only, not a selected product dependency.
- Spend the leaf's one reviewer on alternate port-addressed acquisition and
  all-effect coverage, while the main session runs the remote-token experiment.
  No additional review of the known public AX failure is needed.
- The signed/hardened VM probe disproves the two AX reconstruction candidates:
  at recycled PID 787, the old token-created window minimizes the successor and
  the old data-plus-PID-created window restores it. The original task is dead;
  `_AXUIElementGetActualPid` still reports 787. Preserve the result as a native
  counterexample, with no claim of universal private-API impossibility.
- Direct per-PID `com.apple.axserver` lookup is a distinct concrete lead from
  the reviewer. Establishing its receive-right lifetime, captured-task matching
  and complete native protocol is larger than this diagnostic session.
  Decompose here: finish the remote-token evidence as the first child and leave
  direct AX endpoint feasibility to a fresh design leaf before k57. The original
  all-effects, public-client and strict-lifetime criteria continue to bind.
