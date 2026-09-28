# callback-trace-cycles-k192

## Goal
Add and falsify the reviewed non-raising SCC and cycle-witness interface on
Trace's existing adjacency without changing legacy analyzer semantics.

## Context
Read transport-evidence.md's Trace edge/contradiction contract and k191's
review dispositions. The parent retains the entire publication successor.
The current graph index is stale for analyze.py; read the current source.

## Done when
- Return complete component membership and one deterministic supported closed
  cycle per cyclic component, plus participating edges, without raising on
  cycles or mutating the graph. Handle self-loops and disconnected components.
- Use bounded iterative O(V+E) graph work/storage. Canonical coordinate order
  must determine labels and witnesses independent of collector row order.
- Falsify component/edge/witness errors, permutations, deep graphs and preserving
  unrelated acyclic evidence. Preserve create/acyclic raising behavior.
- Run pinned checks and the complete frozen V1–V26 union; compare all old full
  reports, expectations and fixture bytes itemwise without regenerating them.
- Reconcile both contracts, assessment and the evidence view. Document exact
  input/output obligations, limits and remaining loader/attribution work in k193.

## Notes
Diagnostic design evidence at the existing transcript/Trace seam. No new
executable publication version, native matrix, permissions or product changes.
E20/E21/E24 remain loader discriminators in k193. Render/view only in a
TestAnyware clone; all higher phase/protocol/native owners remain live.

## Decisions (running log)

- Accept an explicit canonical permutation of the existing row indices. This
  keeps physical coordinate validation in the successor reader and avoids
  assuming that the four legacy roles describe five physical lanes. Normalize
  adjacency by integer vertex order using two linear distributions; use
  iterative SCC traversal and one reverse breadth-first tree per component.
  Return original indices so edge provenance stays with the reader. Reject
  malformed graph/order arguments; cycles themselves are ordinary report data.
  The alternative of sorting every adjacency adds avoidable comparison cost;
  a separate graph package would duplicate the existing seam. Exhaustive small
  graphs and discriminating tests are the instrument here, not a second model.

- The graph-only suite first failed because the new API was absent, then passed
  527 cases. Temporary-copy mutants for acyclic-edge inclusion, collector-order
  dependence, dropped self-loops and raising on cycles each failed their intended
  test. One fresh read-only reviewer found no material issue in the algorithm,
  tests or interface contract. Its scope excludes publication-loader selection;
  no second in-session reviewer is needed. The legacy union runs on frozen
  final code/contracts, with unchanged inputs and full-report equality checked
  separately before retirement.

- Final checks pass: Ruff/format/strict Pyright and 10,176 tests; all 8,120
  frozen controls and 3,035 permutations match. All old full reports are
  byte-identical to k178; 16,241 fixture/expectation files and all run inputs
  remain unchanged. The durable k192 assessment maps every child criterion
  and every remaining k182/k179 obligation. Presentation was inspected in a
  disposable clone, stopped afterward. K193 remains live, so retirement closes
  no parent. Capture/public-Accessibility ADRs and glossary remain unchanged.
