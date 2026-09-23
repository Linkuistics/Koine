# native-observation-receive-budget-k102


## Goal
Determine whether a fixed inline buffer plus a post-receive OOL cap enforces
the proposed receive acquisition budget, using bounded local native messages.



## Context
Read the receive-envelope report. The sibling owns the real AX exchange.

## Done when
- Freeze a small local-message discriminator, source, binary and platform;
  execute only in a disposable VM, without exposing AX rights or contacting
  an application.
- Preserve actual returned bytes and audit trailer, received OOL representation,
  mapping presence before the payload-policy decision, cleanup and local port accounting. Compare
  a within-budget case, an over-budget case and an inline-too-large control.
- Demonstrate a deliberately omitted destruction is detected before repairing
  the control's leak. State exactly which descriptor/error forms were exercised.
- Record the budget result, alternatives and next prerequisite in the receive
  design and diagram; preserve every original k101/k99/k94 runtime obligation.

## Notes
This is a native receive discriminator, not a shipping adapter or an AX source,
closure, voucher-policy, read-lifetime or loss experiment. Small known payloads
bound the instrument itself; they do not impose a bound on an exposed receiver.

## Decisions (running log)

- The frozen 25F71 local run received a 44-byte message with a 128 KiB OOL
  mapping before rejecting its payload against 64 KiB. The normal run exited
  0; omitted destruction left the mapping present and exited 1, then reclaimed
  it. Fixed inline capacity plus parser rejection is therefore insufficient
  for that acquisition budget. Preserve this bounded counterexample; do not
  claim physical-memory growth or universal native impossibility. k103 retains
  a usable admission policy and the full original AX exchange/preflight.
- Use the native measurement, not a model that assumes copyout semantics.
  One independent review found no actionable issue within this local contract;
  its limits require self-sender-only authentication, whole-span mapping
  evidence and no claim about arbitrary descriptors or partial copyout.
