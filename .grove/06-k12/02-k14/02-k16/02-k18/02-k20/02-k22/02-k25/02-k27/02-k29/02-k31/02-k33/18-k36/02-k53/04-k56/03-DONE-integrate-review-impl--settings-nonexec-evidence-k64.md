# settings-nonexec-evidence-k64

**Integrates:** settings-nonexec-evidence-k63

## Goal

Triage the k63 review of the k60 shared evidence interface. Apply the real
findings to the adapter, its controls and its report. Finish before k61
migrates the complete scenario onto the interface.

## Context

Read the findings in the k63 leaf at its review commit. Their line numbers
refer to the k60 producer commit 1d9bd4c6. Then read `scripts/vm-guest-exec.py`,
`scripts/vm-guest-exec-lib.sh`, `Tests/scripts/vm-guest-exec.bats` and
`docs/verification/settings-activation/ORDERING-NONEXEC-RESULTS.md`. The
contract is `ORDERING-EVALUATION-PLAN.md` under
`docs/verification/settings-activation`. Read the parent brief chain. The
review read the TestAnyware v2.7.0 tag in the local checkout at
`../TestAnyware`.

The review ran no test, build, guest or reviewer. The graph server failed to
connect. K60 supplies no scenario migration, VM, signed subject or acceptance,
and this integration supplies none either.

## Done when

- Each k63 finding has a recorded disposition with its reason, read from the
  review's own commit.
- Each accepted change to the adapter has a control that fails before the
  change and passes after it.
- Each finding that stays a caller obligation reaches the report and the Done
  when of k61 or k57 as an explicit duty.
- `mise exec -- task check:vm-guest-exec` passes, with a fresh receipt that
  digests its subjects before and after the run.
- The existing pointer and resize checks still pass.

## Notes

Every original k56 duty survives. This integration does not migrate a caller.

## Decisions (running log)

- 2026-10-29: Adopt the mandated integration on empty jj change xtwrzlvw,
  parent 7009a5a4. Read k63's findings from its own committed DONE leaf.
  Read the ancestor briefs, glossary's Settings/evaluation terms, adapter,
  facade, controls, report and ordering contract. Graph list_projects refuses
  before project/generation discovery because an unverified generation is
  active. Use bounded direct source reads; claim no graph coverage and leave
  other CBM sessions alone.
- 2026-10-29: P2-1 is a real issue: the evidence class bypasses the latch for
  parsed mutating CLI actions. Restrict CLI evidence to an explicit collection/
  exact-stop action set. Tagged v2.7.0 agent.rs also shows snapshot --open-menu
  sends VNC clicks; reject that option in evidence calls. Free guest-exec
  commands still require caller classification. Add failing controls first.
- 2026-10-29: P3-1 is a real retention issue plus a caller containment duty.
  Retain refused requests/reasons in a separate append-only root log without
  allocating dispatched ordinals or replacing the first latch. K57 must handle
  an orphan-held lock before exact-stop, or retain unresolved cleanup.
- 2026-10-29: P3-2 is a real lifecycle-interface issue. Refuse viewer and
  keep-on-failure start options. Keep golden-base selection/audit with k57,
  explicitly in its Done when and the report; init binds clone identity only.
  Failed/interrupted start can leave that clone running and requires containment.
- 2026-10-29: P3-3 is a real control gap. Strengthen ID, per-entry lock and facade
  reason controls and demonstrate their failures against isolated mutations.
  H-1 is a contract stated unclearly: nonzero typed not-found stays unavailable;
  k61 must use successful list-shaped reads for clean negatives and payload
  predicates rather than constant true. Preserve the strict transport rule.
- 2026-10-29: Repair each issue with failing/passing helper controls, then update
  the report and caller duties. Finish edits before fresh Taskfile verification
  and digest all inputs before/after. No redesign, reviewer, guest, signed
  subject or native acceptance is needed for these bounded repairs.
- 2026-10-29: P2-1's mutation/input control fails before the guard and both
  refusal and permitted-collection controls pass afterward. P3-1's missing-log
  controls fail before backend/facade append logging and pass afterward,
  including retained refusal of exact-stop under the orphan-held lock. Keep
  backend JSONL and facade shell-quoted fallback logs separate: the latter must
  work when the Python backend is absent. Storage/signals can still leave partial
  evidence and every nonzero return remains unavailable.
- 2026-10-29: P3-2's viewer/keep-on-failure control fails before the option guard
  and passes afterward. P3-3's four isolated mutations each fail the strengthened
  control: missing caller-ID guard, unlocked check, unlocked confirmation, and
  wrong facade latch reason. The first ID mutation setup matched two source
  fragments and aborted; its retained caller-id-red output is a setup error,
  not guard evidence. caller-id-guard-red is the successful mutation experiment.
- 2026-10-29: The full adapter Taskfile check passes all 37 controls, Bash
  syntax/shellcheck/shfmt, Python compilation, Ruff and strict pyright. The
  report now records all five dispositions and both caller Done when sections
  retain the unresolved caller duties. Finish at this bounded repair; the
  executable seams cover the fixes, and scheduled whole-harness review remains
  due after migration/caller work. Take a fresh digested verification receipt
  now that code, controls, report and caller handoffs are settled.
- 2026-10-29: Fresh digested verification passes 37 adapter, eight pointer and
  nine resize controls. Each expected test name matches its individual result;
  all 55 recorded subjects are unchanged before/after and still match at receipt
  assembly. Output digests match. All 20 local report-link targets exist.
  ORDERING-NONEXEC-RESULTS.md records every finding, control and limit; retained
  verification.json is the receipt. No code, control, report or caller duty
  changes after measurement. This final task-log entry is not a test input.
- 2026-10-29: Done when is met for this integration alone. K61 and k62 remain
  live in k56, and k57 remains live in k53; no parent cascade or ancestor close
  is earned. No producer review is cut or finished here, so no Creator line is
  needed. Retire only k64, then seal its one focused jj change. No scenario
  migration, guest, signed subject, freeze, native repair acceptance or release.
