# remote-token-lifetime-k58


## Goal
Determine whether private AX remote-token and data-plus-PID reconstruction bind
an ordinary target's window to one process incarnation, and preserve the native
result and its design consequences.

## Context

The parent retains the full binding contract. This first child completes the
bounded diagnostic begun before decomposition; it does not select a transfer
protocol or weaken the capture/lifetime requirement.

## Done when

- A TestAnyware probe distinguishes live reconstruction, death and actual PID
  reuse, with separate observers witnessing effects and frozen-input hashes.
- The evidence distinguishes signed/hardened diagnostic availability from
  product policy acceptance and covers its untested limits explicitly.
- The capture ADR and visual discussion reflect the result; the direct-port
  question is preserved for `direct-ax-endpoint-k59`.

## Notes

Completed evidence is `docs/verification/retained-ax-binding.md`, under
"Private token and data reconstruction also cross incarnations". The private
probe at PID 787 minimized and restored the successor using the old private
objects. No complete binding is established. The original k56 running decisions
and the one-reviewer reconciliation remain in the parent/evidence document.

## Decisions (running log)

- Reject remote-token and data-plus-PID reconstruction as standalone process
  binding based on native counterexamples. Preserve the public-client and
  strict-process contract; the result does not show universal impossibility.
- Direct AX service acquisition is separate design work. This session ends
  with its concrete lead and unresolved obligations in k59; k56 remains live
  through that child, and k57 still cannot choose a protocol without feasibility.
