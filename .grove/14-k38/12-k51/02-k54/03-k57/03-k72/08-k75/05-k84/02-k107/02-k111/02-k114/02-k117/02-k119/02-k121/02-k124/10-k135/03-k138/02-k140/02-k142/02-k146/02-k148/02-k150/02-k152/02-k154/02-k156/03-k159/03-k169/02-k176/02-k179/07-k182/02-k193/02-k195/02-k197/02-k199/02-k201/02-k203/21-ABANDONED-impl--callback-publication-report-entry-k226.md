# callback-publication-report-entry-k226

## Goal
The production two-path entry returning a versioned, admitted publication
report whose first sections are storage/cut/map facts, per-role replay domains
and producer invariants — with the frozen profile, admission, emergency header,
sidecar, test-profile hook and production guard all real from the start.

## Context
publication-replay.md "Problem and selected boundary", "Values, indices and
qualification", "Producer invariants and replay limits", "Report admission and
resource failure" and "Internal test profile and production isolation";
publication-capacity.md frozen profile `/2` (k247, superseding k224's `/1`;
path rows per k248); k223's named boundaries.

## Done when
- `publication_report(manifest_path, rows_path)` binds `PRODUCTION_REPORT_PROFILE`
  (values mirrored from publication-capacity.md with a drift check). Its CLI
  accepts exactly two paths; any option, selector or extra argument is a usage
  error with no report. Outer FileError yields interpretation F with no graph;
  ordinary I/O failure is not an evidence report.
- Report tables are fixed-capacity typed columns preallocated from the profile
  at the k224 widths; resident bytes are charged once before evaluation.
  Encoding is compact ASCII JSON with positional integer records within the
  frozen per-record widths, closed-vocabulary strings interned in one table and
  no copied frame image or freeform blob.
- Report kind `publication-report/1` with the fixed 28-ID section enum of
  publication-capacity.md, `ordered-rules` included. Sidecar eligibility
  follows that document's closure rule: the first twelve IDs plus `strings`.
  Their records reference only observations, interned strings and earlier
  eligible records, and admission refuses a graph reference there as a
  placement error. Each section is admitted atomically with its support,
  through a checked-u64 admission primitive, before allocation, table insertion
  and encoding. The exact limit is admitted, the next unit fails, and overflow
  has its own code.
- 4,096-byte emergency header preallocated outside max_report_bytes with the
  fixed schema; bounded sidecar of whole committed sections reserved in
  max_diagnostic_bytes before computation; sink failure is I/O failure.
- `require_production_report` guards the production serializer
  `emit_publication_report` and the consumer `summarize_publication_report`.
  Internal test-support hook `evaluate_with_test_profile(manifest_path,
  rows_path, profile)` takes an immutable `TestReportProfile`, labels its
  report test, and is unreachable from the production module and CLI.
- Sections: k202 storage findings, physical cuts, excluded coordinates and
  reasons, raw-index→vertex and original-coordinate maps, per-role replay
  domains, producer boundary/PID/gap/duplicate/fault findings for every
  V11–V25 base, raw counting-set tags inside/outside replay.
- Controls on real files: R05; R17 domain part (stateful 1–8, physical tail
  retained); R18 boundary/PID/duplicate-coordinate findings; R06 outer-invalid
  embedding-only receive rejected at load with no graph; all R35 vectors
  (ambient profile file, CLI/manifest selector, environment, label erasure,
  test-report emission and consumption refused); R30/R31 for max_diagnostics,
  max_report_bytes and max_diagnostic_bytes via the hook, arithmetic overflow,
  empty-sidecar reserve exhaustion and emergency-sink failure; sidecar closure
  mutants (an ineligible section or a graph-referencing record admitted to the
  sidecar) killed; under
  collector permutations every listed section except the raw-index maps is
  byte-identical, and the maps are compared through physical coordinates:
  the coordinate→vertex relation and excluded-coordinate reasons identical,
  and each permutation's raw-index→vertex map equal to its own original
  line→coordinate map composed with that relation (publication-files.md
  "Selection and result obligations"). Kill a map that ignores line order.

## Notes
The internal observer entry and `PublicationControlTestResult` arrive with
k232; the guard must already refuse that kind. Legacy analyzer untouched.
