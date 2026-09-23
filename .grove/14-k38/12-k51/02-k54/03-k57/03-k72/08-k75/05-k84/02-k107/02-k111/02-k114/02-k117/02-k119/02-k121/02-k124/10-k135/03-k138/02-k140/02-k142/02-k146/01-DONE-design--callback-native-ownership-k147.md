# callback-native-ownership-k147

## Goal
Make the native-right ownership boundary executable and falsifiable: raw call
returns determine ownership; summaries and acknowledgments cannot erase failure.

## Context
Consume v8 at the immutable transcript seam and reuse Trace. Read both recorder
contracts and the original k146/k142 criteria. This is a diagnostic design slice.

## Done when
- Specify versioned begin/return records for task-name acquisition, type checks,
  validation/retention reads and deallocation, with exact raw status/out-values,
  unique calls and per-reference ownership independent of coalesced Mach names.
- Check successful summary joins, null/dead/type/status/count/PID failures,
  partial preheld acquisition, failed release, unmatched blocked calls and
  false empty-ledger/completion acknowledgments. Preserve raw failures and
  known or uncertain cleanup obligations, including on intact partial prefixes.
- Falsify each new boundary through the existing analyzer CLI, cover both
  constructions/sources/schedules, preserve v1–v8 bytes and reports itemwise,
  and renew the complete frozen corpus. Keep structural/controller/candidate
  and loop diagnostics independent, with no native credit.
- Reconcile both contracts, assessment and visual discussion. Give k148 an
  exact ownership interface and remaining source/hint/failure-composition work.
  Keep every original k146/k142 criterion and k144/k126 gate live.

## Notes
No native capture matrix or product adoption. Rendering/viewing runs only in a
disposable TestAnyware clone. No complete sampler claim on this projection.

## Decisions (running log)

- Add explicit right-call observations to the versioned transcript. A local
  checker owns raw call/summary joins and the reference ledger; Trace continues
  to own cross-process order. Keeping status only in an ungraded audit would
  let a failed release disappear behind the old successful release summary.
  Replacing historical semantics would corrupt frozen evidence. This additive
  slice costs one independent report column until k148/k144 compose producers.

- One bounded fresh-context review found a false-cleanup completion after a
  gapped suffix. Reproduced red at the actual CLI, fixed by requiring full local
  stream consumption, and frozen as a new control. Failed type-query wording
  was clarified. No second review in this leaf; k144 retains full-producer review.
- V9's 160 controls plus the entire earlier corpus now pass: 1,864 controls,
  90 permutations, 1,878 tests. Every one of 1,704 earlier report records and
  3,408 earlier case/trace files compares equal. See the v9 assessment and
  evidence/k147 for raw outputs and named before/after input maps.
- The deliverable is the versioned executable contract and ledger projection.
  K148 owns source/hint and failure/late-abort composition, every original
  k146/k142 reconciliation and the complete sampler handoff to k144. Neither
  ancestor closes. The capture/public-Accessibility ADR set remains current.
