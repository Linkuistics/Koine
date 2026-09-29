# callback-publication-order-support-k232

## Goal
Raw and usable order over the frozen Trace with receipt bundles, dependency
SCC/badness propagation and interned support, observed through the internal
control entry on the k217 fixtures.

## Context
publication-replay.md "Orders, cycles and independent support", "Dependency
ownership and finite path selection", "Composite truth and obligation
branches"; publication-path-controls.md "Control observers" through
"Isolation, bounds and killing observations".

## Done when
- Receipt bundles from stage-2/3 facts; one dependency-SCC pass; first-discovery
  predecessor forest; clean-justification masks in O(H+D+S+J); raw and usable
  forward/reverse search with shortest-then-canonical witnesses (at most two
  interned paths per query); same-vertex F; three-valued AND/OR/NOT with
  inherited and own masking as an evaluator core.
- `inspect_publication_controls(manifest_path, rows_path, catalogue_id)` for
  `upstream-order/1` and `split-order/1` with fixture digest binding,
  `PublicationControlTestResult`, invocation-local results and the separate
  test overlay budget (9 queries, 32 claims, 512 refs, 6,012 path refs, 1 MiB).
  `require_production_report` refuses the test result at both boundaries.
- Probes P-local, P-short, P-only, P-vertex, P-reverse(+NOT),
  P-reverse-clean(+NOT), P-end-up, P-multi, P-end-multi with clean neighbours;
  mutants: interior vertex inheritance, shortest-forward-then-mask,
  interior SCC-vertex rejection, ignore upstream join, shortest-reverse-then-
  mask, omit G90→T34 (order column), NOT drops dependencies; R09, R10, R12,
  R13 interior variants; catalogue admission/selector/permutation/graph-
  mutation/probe-registration controls.
- Charges max_paths, max_path_edge_refs, max_support_nodes, max_support_refs
  and max_query_work_bytes; production Q is unchanged by test registration.
  Path references are u32 justification IDs under the admitted 8,388,608
  limit (overflow is incomplete-resource, never a cut path); workspace is
  charged by the k224 model from actual V/E/H/D/J (Trace adjacency persistent,
  cycle_components transient, then CSR/pair-choice/BFS/dependency scratch).

## Notes
frame-algebra/1 needs frame claims and arrives with k237.
