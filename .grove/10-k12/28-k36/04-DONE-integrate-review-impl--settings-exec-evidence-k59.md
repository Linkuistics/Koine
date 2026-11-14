# settings-exec-evidence-k59

**Integrates:** settings-exec-evidence-k58

## Goal

Triage the k58 review of the k55 strict guest-exec adapter. Apply the real
findings to the adapter, its controls and its report before k56 migrates the
shared scenario onto it.

## Context

Read the findings in the k58 leaf at its review commit. Their line numbers
refer to the k55 producer commit 9ad206f1. Then read `scripts/vm-guest-exec.py`,
`scripts/vm-guest-exec-lib.sh`, `Tests/scripts/vm-guest-exec.bats` and
`docs/verification/settings-activation/ORDERING-TRANSPORT-RESULTS.md`. The
contract is `ORDERING-EVALUATION-PLAN.md` under
`docs/verification/settings-activation`. Read the parent brief chain.

The review ran no test, build, guest or reviewer. The graph server failed to
connect. K55 supplies no ordinary migration, VM, signed subject or acceptance,
and this integration supplies none either.

## Done when

- Each k58 finding has a recorded disposition with its reason, read from the
  review's own commit.
- Each accepted change to the adapter has a control that fails before the
  change and passes after it. This applies in particular to P2-1, where the
  current control passes with the lock removed.
- The report states the adapter's actual exit contract and its interruption
  and orphan limits.
- H-1 reaches k56's Done when as an explicit duty, or the adapter gains the
  operations that it names.
- `mise exec -- task check:vm-guest-exec` passes, with a fresh receipt that
  digests its subjects before and after the run.
- The existing pointer and resize checks still pass.

## Notes

Do not change historical bytes, closed caps or held causal slots. Do not start a
VM or freeze a subject. K56 and k57 stay live behind this leaf. No ancestor
closes here.
## Decisions (running log)

- 2026-10-29: Read k58's findings from b17080b2 against the k55 adapter,
  controls and transport contract. Graph startup refuses before project or
  generation discovery; use bounded source reads without disturbing CBM.
- 2026-10-29: P2-1 is a real control gap: the second call must be evidence
  collection, with the competing-writer reason checked. Demonstrate failure
  with the lock removed before crediting it. P2-2 is a real lifetime defect:
  pass the writer descriptor to the exec and validator children so an orphan
  keeps the domain locked. This does not prove remote guest completion.
- 2026-10-29: P2-3 is a real failure-path defect. Latch identifiable initialized
  run roots on parse failure and unexpected backend failure; explicitly flush
  stdout before publishing a terminal receipt and retain its emission status.
  Callers must stop on every nonzero exit, including failures to record a latch.
- 2026-10-29: P3-1 and P3-2 are real interruption/partial-record defects.
  Record caught interruption distinctly and propagate SIGINT; validate prior
  terminal receipts and publish new receipts atomically. Uncatchable signals
  and storage failure can still leave partials, which never imply completion.
- 2026-10-29: P3-3 is a real provenance gap assigned to k54's freeze rather
  than adding endpoint-resolution policy to this exec seam. H-1 is future
  integration work: k56 must add supported latch inspection/failure recording
  and non-exec recording in the same lock/ordinal domain. Preserve both as
  explicit Done when duties. No runtime or candidate freeze occurs here.
- 2026-10-29: The lock-removed control now fails on the second evidence
  dispatch; seven new controls fail against k55's failure paths, and a separate
  interrupted-publication control fails against its write_json. The integrated
  21-control suite and Taskfile checks pass. Correct one test-only case-isolation
  error (a previous case's CLI-count file), preserving all first-run receipts.
  Decline an in-session reviewer because these behavioral claims have direct
  executable counterexamples, and later whole-harness review remains required.
- 2026-10-29: Final frozen-input verification passes check:vm-guest-exec
  (21 controls plus syntax/lint/format/type checks), check:vm-menu-pointer
  (8 controls) and check:vm-window-resize (9 controls). The fresh receipt in
  ordering-transport-integration-evidence/verification.json records 26 unchanged
  before/after input digests and per-command output hashes. Item-by-item audit
  matches current bytes and rejects a deliberately wrong digest. Every k58
  disposition and the exit/interruption/orphan limits are in the durable report.
  K56 owns H-1/non-exec and scenario signal integration; k54 owns runtime
  provenance. No VM, frozen candidate, acceptance or ancestor closure occurs.
