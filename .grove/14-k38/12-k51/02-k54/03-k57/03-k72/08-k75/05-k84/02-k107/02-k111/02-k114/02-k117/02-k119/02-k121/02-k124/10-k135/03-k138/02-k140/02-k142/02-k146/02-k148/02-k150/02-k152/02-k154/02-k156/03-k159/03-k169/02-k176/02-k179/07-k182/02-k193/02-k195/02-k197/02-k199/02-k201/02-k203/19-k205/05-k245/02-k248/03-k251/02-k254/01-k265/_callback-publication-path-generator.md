# callback-publication-path-generator-k265 — brief

## Goal
Give the census a generator that scales a V18 history by stated parameters. It
emits the k253 input shape: lane-ordered rows, edges with justifications,
receipt bundles with upstream arcs, and distinct ordered queries with physical
endpoints. It checks the history against the envelope. It is proved against the
committed clean file before any scaled graph is trusted.

## Context
The k254 brief (Decomposition and planning Notes) and the k251 brief's
"Promoted from k253" (entry points and computed per-file figures).
publication-path-controls.md "Rows and bytes", "Edge inventory and ownership",
"Upstream join controls" and "Rule-issued query census". The last says the
Q01–Q41 recipe covers these six V18 files only, and that new query families
need explicit rule ownership. publication-replay.md "Selected successor edge
rules" and the justification table in "Dependency ownership and finite path
selection". publication_edges.py (`build`, `Graph`, the records) and
publication_paths.py `select_orders`. In publication_profile.py:
`QUERY_LANES`, `query_classes`, `path_bound`, `lane_violations` and the
legacy census's lane-class tags per order site.

## Done when
- A census function takes a named V18 base and a parameter vector: rows per
  lane, target activities and members, commits and their begins, sampler
  acquisitions, cyclic local edges at stated lane positions, and bad bundles.
  It returns a `Graph` of the shape `publication_edges.build` returns, which
  `select_orders` consumes unchanged. Each query's endpoints come from a named
  rule recipe: a legacy order site or a successor family. No query is sized by
  a count alone.
- At the clean file's parameters the generator reproduces that file. The check
  covers the canonical vertices, the distinct edge pairs, the justifications
  and bundles, the 41 physical query pairs, and the selector's 728 witness refs
  and 728 total. At the multi-cycle parameters it reproduces the 1,033 witness
  refs and the 1,040 total, or the leaf records why no parameter vector
  expresses that defect.
- Envelope check: every generated history passes `lane_violations` and the /2
  kind maxima. A deliberate over-cap vector is refused with the violation
  named.
- At scale (V ≈ 4,138 and thousands of queries), the generated queries per
  lane class equal `query_classes` for the matching `Construction`. Any
  difference is explained family by family; k249's double-charged milestone
  pairs are the expected one. The model's `total` is at most `path_bound`'s
  per-case bound. The run time is recorded.
- Each new check fails under a deliberate mutation: a recipe that drops one
  family, a query with a misplaced endpoint, an over-cap lane, and a cyclic
  edge at the wrong position. `task design:check-publication-profile` is
  green. `EVIDENCE` moves to evidence/k254, and k253's record stays
  byte-identical. No profile constant or document table changes.

## Notes
Keep the generator separate from `path_bound`, and from the selector apart from
the plain data shape, so that each can check the others. If it gets its own
module, extend the Taskfile's ruff and pyright steps to cover it, as k258 did.
The legacy side's queries are the hard part. The clean instrumentation shows 33
legacy pairs, so each per-row legacy site needs a stated endpoint rule for
extra activities and members. Derive the rule from the site, not from the
count. One stronger oracle is available: the generator writes a real
observations file that the unchanged `load_publication` and `build` read. That
would make legality and the edge census the loader's result rather than the
generator's claim. Use it if it fits the session. Otherwise record why the
abstract graph stands in for it. If the generator plus its recipes does not fit
one session, decompose. Put the clean-file reproduction first.

## Decomposition

The generator and its recipes do not fit one session. The clean reproduction
comes first, as the Notes ask. The named V18 base is the frozen fixture trace
(callback-causal-fixture/controls/v18-acquire-resample-workspace-ordinary-none/
trace.jsonl). All six k220 files lift it, so the generator lifts the same trace.
Each later child adds one group of parameters and the checks that belong to it,
and each leaves the census green under evidence/k254.

- callback-publication-generator-clean-k269: lifts the V18 trace into lanes,
  edges, justifications and bundles. Every query comes from a recipe owned by a
  `SITE_LANES` site or a successor family. Matched field by field against
  `build("clean")`, 41 physical pairs, and the selector's 728 / 728.
- callback-publication-generator-cycles-k270: split begins at stated lane
  positions (the cyclic local edges) and the bad bundles they cause. It
  reproduces multi-clean, multi-cycle and upstream-cycle where a vector
  expresses them, including 1,033 / 1,040, or records why no vector does. A
  cyclic edge at the wrong position is caught.
- callback-publication-generator-envelope-k271: the scaling parameters (rows per
  lane, activities and members, commits and begins, acquisitions). Every
  generated history is checked with `lane_violations` and the /2 kind maxima.
  An over-cap vector is refused with the violation named.
- callback-publication-generator-scale-k272: a run at V ≈ 4,138 with thousands
  of queries. Queries per lane class are compared with `query_classes`, family
  by family, and the model's total with `path_bound`. The run time is recorded.
  The leaf also decides the loader oracle (a real observations file) or records
  why the abstract graph stands in for it. Retiring it closes this node.
