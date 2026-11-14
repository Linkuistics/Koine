# settings-keepalive-scheduling-k101


## Goal
Specify the numerical scheduling and deadline contract for the reviewed owner
lifecycle, including both contention directions, stop and failure containment.



## Context
Consume the k97 lifecycle after k99/k100 and the k98 parent charter. Work only
on scheduling here. The independent resource design remains k102; no numerical
scheduling proposal establishes producer bounds, useful native liveness or startup eligibility.

## Done when
- Define fixed fair arbitration, pending admission and exact operation/validation/
  publication/delivery/stop/reap deadlines, with monotonic origins and expiry behavior.
- Preserve sleep20, all existing input order/waits/polls and one-attempt transports.
  Account for OCR, exec/transfer, post-CLI validation and input during capture.
- Explain useful overlap schedules and show bounded service-or-failure, without
  promising native termination or VNC safety. Specify the timing records and
  offline boundary controls, including both held-pointer cases and orphan locks.
- Update the current spec and visual discussion. Keep the complete resource,
  workload, whole-design reconciliation/review and planning duties in k102/k98.
- Cut independent scheduling review before k102 consumption; retire only this child.

## Notes
Design only. No production source, native experiment, candidate, freeze, runtime,
closed-slot reuse or ancestor closure. Internal copied-module barriers remain a
proposed seam pending the whole-design agreement required by k100.

## Decisions (running log)

- 2026-10-30: Adopt k98 in the clean jj workspace at 6fc7c532, then decompose
  at scheduling versus enforceable producer/validator/storage resources. Execute
  only scheduling k101. K102 retains all remaining k98/k96 duties and must reconcile
  the complete owner before whole-design review and planning.
- 2026-10-30: Propose receive-order service with control precedence and one
  outstanding operation per producer. Set admission to 150 seconds and operation
  bounds to CLI allowance plus 22 seconds of explicit phases. Use host continuous
  time, retaining sleep20 and each original inner timeout. These service targets
  establish no native idle safety or resource enforcement. K102 must reconcile
  them against its complete useful workload before whole-design review.
- 2026-10-30: Keep copied-module transition barriers proposed until the whole-design
  seam decision. Specify their discriminating controls without claiming execution
  or new seam approval. Independent scheduling review must precede k102.
- 2026-10-30: Deadline arithmetic passes. The final documentation check retains
  only the two archived k23 missing targets. All 210 checked document/diagram/tool
  inputs remain stable across that check. The owner spec and scheduling evidence
  have no hard prose findings. Both changed views render at their deep links.
  Desktop light appearance was inspected. No coordinator or native test ran.
