# callback-publication-report-profile-k224

## Goal
Freeze the exact integer successor report profile in publication-capacity.md,
with its derivation, fit of every required case and per-dimension coverage
table, before any impl leaf under k203 runs. This is k205's own numeric duty;
it cannot pass to an implementer.

## Context
publication-replay.md "Report admission and resource failure" (the derivation
table per dimension) and "Internal test profile and production isolation";
publication-capacity.md "Offline report admission profile" and "K217 path-control
input census"; publication-path-controls.md query census and test-overlay
bounds (9 queries, 32 claims, 512 refs, 6,012 path refs, 1 MiB). The rule
inventory must come from source: analyze.py, sampler_*.py, source_calls.py,
native_ownership.py and the transport/lifecycle/evidence rule tables. Read the
k223 decisions and the k225–k242 leaf bodies: they name which leaf charges
which dimension.

## Done when
- One versioned tuple `publication-report-profile/1` with an integer for each
  of max_claims, max_obligations, max_diagnostics, max_edges,
  max_edge_justifications, max_paths, max_path_edge_refs, max_support_nodes,
  max_support_refs, max_query_work_bytes, max_resident_report_bytes,
  max_report_bytes, max_comparison_bytes and max_diagnostic_bytes, each with
  its derivation: rule family, anchor arity, per-role/frame/call/row
  multiplicity and maximum instances at V≤10,240, four semantic domains ≤256,
  160 commits, 1,280 begins and the closed route limits, including failure,
  raw-tail and multi-defect paths and fixed summary rules.
- Global Q derived from all rule arities/anchors (not 41); edge classes and
  parallel justifications bounded separately; H/D/J/S dependency preprocessing
  and workspace bounded with simultaneous lifetimes and pinned runtime/container
  overhead; encoding widths, escaping, separators and every copied string/blob
  multiplicity; full projected legacy stdout/stderr/result charged to
  max_comparison_bytes.
- The 2×Q×(V−1) path-reference bound is resolved explicitly: either frozen as
  the worst case with its byte/workspace consequence, or replaced by a stated
  admitted limit whose overflow is an honest incomplete-resource outcome — with
  the argument, not an implementer's guess.
- Every required honest/mutant topology/E/L/M/B/R/P/Q case, the 88-edge Q34
  witness and the largest retained legacy comparison are shown to fit, or the
  conflicting bound is resolved and the affected leaf bodies are updated.
- Emergency header fixed-field bound verified (≤32 section IDs × 51 bytes plus
  ≤2,048 bytes of fixed fields/framing below 4,096) and the fixed section enum
  listed. Test-overlay object/encoding overhead accounted separately.
- A per-dimension coverage table: which production values real files can
  attain (exact/over-limit control required), which cannot (infeasibility
  argument plus labelled admission-primitive check at the actual value), the
  drift mutant bound to each constant, and the R30/R31 injected stress case.
- k225–k242 bodies still assign every dimension; adjust any the numbers change.
- Decide whether the plan plus profile need a fresh `review-planning` before
  implementation; if so cut it beside this leaf as the last act.

## Notes
Input caps, recorder reserve and V1–V26 limits are not report dimensions and
stay unchanged. A generated census checks the derivation; it does not replace
it. Assumed formula output is not measured usage — measurement belongs to
k240. No executable successor exists yet; design values are expected controls.

## Decisions (running log)

- **Derivation domain is the recorder-attainable envelope, not loader rows.**
  The loader admits 10,240 rows, but the recorder's kind caps (4×256 semantic
  +1 duplicate unit each, 160 commits, 160 receipts/completes, 1,280 begins and
  results, ≤54 local records) plus one B19 overflow unit per cap sum to 4,138
  attainable rows. Every count dimension is the maximum over that envelope. A
  loader-accepted file beyond it (e.g. 2,000 duplicate begins) is analysed until
  a dimension would overflow, then reports honest incomplete-resource.
- **Legacy rules are counted mechanically from source.** An AST census treats
  each check site as at most one claim per anchor, and each order site as
  arity−1 queries, with every loop iterable classified (an unknown or stale
  classification fails the census). All modules and dispatch branches are
  summed with no branch exclusivity, so no single base reaches the total.
- **2Q(V−1) is replaced by an admitted limit of 4,194,304 path references.**
  The worst case is 143,045,694 at the envelope and 354,033,904 at loader V.
  The admitted limit covers all 5,789 lifted V11–V25 base cases under the crude
  per-base bound (max 3,168,152) and any envelope case with ≤506 issued queries.
  Stress fixtures are gated by the same per-case bound at construction (k225).
- **Report tables are fixed-capacity typed columns preallocated from the profile.**
  That pins container overhead (80-byte array header plus width×capacity on
  CPython 3.14). Resident bytes are charged once, before evaluation. The one Trace
  and cycle_components keep their Python objects under a checked object model.
- **Comparison capture is 262,144 stdout plus 65,536 stderr bytes, base64-encoded.**
  The parsed result is also stored. A source bound puts projected legacy stdout
  under ~160 KB: loader seq ≤256 shrinks the duplicate-sequence detail, and
  duplicate keys cannot reach projection. The frozen comparison maximum is
  therefore unattainable.
- **A fresh review-planning is warranted.** The profile's family table, envelope
  argument and admitted path limit are judgement calls that eighteen impl leaves
  will consume. Cut beside this leaf as the last act.
