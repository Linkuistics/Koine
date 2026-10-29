# settings-exec-evidence-k55

## Goal
Add a source-only shell adapter at the guest helper seam that records one exact
VM exec, validates the complete raw envelope and command payload, and retains a
sticky unavailable latch across shell substitutions. Verify it without a VM.

## Context
Read the parent charter, ORDERING-EVALUATION-PLAN.md and ORDERING-REVIEW.md.
The ordinary helper remains legacy until settings-shared-scenario-k56 migrates
it; this expand step supplies no runtime readiness. TestAnyware 2.7.0 has top-level
exec fields; clean spawn/CLI zero does not prove command success.

## Done when
- Retain command/argv, VM, class, operation, ordinal, start/end times, raw stdout,
  raw stderr and CLI status; keep decoded guest streams without stripping.
- Require one complete JSON envelope, exact field types, matching command and
  clean exit/timeout plus a caller-specific payload predicate. No retry.
- Failed execs/payloads permanently prevent later scenario exec/poll dispatch,
  including after subshells. Allow explicit evidence-only collection without
  clearing the original failure. Refuse evidence overwrite and competing writers.
- Demonstrate failing controls before repair: malformed/partial/missing fields,
  matching timeout, nonzero CLI/guest, missing marker, clean negative versus failed
  polling, and disconnect followed by changed boot. Include real retained failure.
- Add a reusable Taskfile check; record exact scope and migration handoff in the
  durable transport report. Consider independent review before migration/runtime.

## Notes
No signed subject, clone, evaluation slot or native acceptance. No historical
bytes, cap or held causal slot changes. Parent remains open.

## Decisions (running log)

- 2026-10-29: Use a small source-only shell facade and a Python backend for
  structured evidence. Each call creates a distinct ordinal directory and records
  raw streams before validation. No default payload predicate is supplied.
- 2026-10-29: Keep clean negative state as caller data. Only read-poll and
  one-shot classes are blocked by the persistent unavailable latch; explicitly
  read-only evidence collection can continue without changing the first failure.
- 2026-10-29: Strict parsing rejects missing/wrongly typed fields, command
  mismatch, duplicate/multiple JSON objects, dry-run and non-JSON numeric values.
  The payload predicate must yield exactly one true value and actual true output;
  jq halt/zero without output fails its RED control before repair.
- 2026-10-29: Python's permissive NaN/Infinity decoding failed the malformed-JSON
  control; reject these constants explicitly. A non-blocking file lock refuses a
  competing writer; incomplete ordinal records prevent later scenario dispatch.
- 2026-10-29: This adapter is an expand increment; existing scenario callers stay
  legacy until k56. It earns independent tree review before migration/runtime,
  with no in-session reviewer. No native success or restart feasibility follows.

## Verification and boundary

`mise exec -- task check:vm-guest-exec` passes all thirteen controls, shell/Python
checks and strict types. Existing pointer eight and resize nine controls also
pass. The fifteen enumerated subject digests match before/after the final run;
docs/verification/settings-activation/ordering-transport-evidence/verification.json
retains commands and per-item evidence. The durable report names every remaining
parent duty. No ordinary migration, VM, signed subject or acceptance occurs.
The new adapter earns independent review before k56; no node closes.
