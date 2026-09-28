# callback-publication-generator-clean-k269

## Goal
A census generator that lifts the named V18 base (the frozen fixture trace)
into the k253 input shape: lanes, edges with justifications, receipt bundles
with upstream arcs, and distinct queries with physical endpoints. Every query
comes from a named rule recipe. At the base's own parameters it reproduces the
committed clean file.

## Context
The k265 brief (Goal, Done when, Notes). The clean file and its lift rules in
publication-path-controls.md "Rows and bytes". "Rule-issued query census" and
evidence/k220/legacy-order-calls.txt give the 33 legacy pairs and their call
sites. `SITE_LANES` and `QUERY_LANES` in publication_profile.py.
publication_edges.build is the oracle, never an input.

## Done when
- `generate(base)` returns a `publication_edges.Graph` that `select_orders`
  consumes unchanged. The parameter vector arrives with k270 and k271. It is built from the V18 trace alone:
  no observations file, no doc table, and no archive.
- Each query's consumers and endpoints come from a recipe tagged with its
  `SITE_LANES` key or its successor family. A pair shared by several recipes
  is one query.
- At the base's parameters the graph equals `build("clean")` in canonical
  vertices, lanes, the edge IDs and pairs, the justifications, the bundles, the
  producer map, and the 41 queries (consumers, original and physical pairs).
  The selector's witness refs and total are 728 / 728.
- The census runs this as a failing check. A recipe that drops a family and a
  query with a misplaced endpoint are both caught.
- `task design:check-publication-profile` is green with the new module linted
  and type-checked. `EVIDENCE` moves to evidence/k254, and
  evidence/k253/profile-census.json stays byte-identical.

## Decisions (running log)
- k265 decomposed into k269–k272 (clean, cycles, envelope, scale), with clean
  first. The generator, its recipes, the multi-cycle defect, the envelope and
  the scale run are four independently checkable increments.
- The named base is the frozen V18 fixture trace itself, not the clean file's
  rows. The six k217 files are lifts of it, so matching `build("clean")` tests
  the lift rules rather than copying the file.
- Frame byte lengths (`images`, `contributions`) are not generated. They are
  the loader's; the loader-oracle decision sits with k272. The selector reads
  neither field.
- Query IDs are first-issue order over the recipe table. The table is written
  in the census's own order (delivery, recorder replies, input replies,
  selected callback, enclosure, acquisition, comparisons, membership, capture),
  and a shared pair is one query. The IDs are labels, so a recipe mutation
  shows up as shifted IDs as well as missing pairs.
- Recipes derive endpoints by rule. A peer's reply is its next frame after a
  controller request, and an input's reply is the next send. Activity
  comparisons pair each target activity with B's input and the sampler's
  m_end. Members are a target's activity and input rows. `site_classes`
  checks each issued pair against its sites' `SITE_LANES` tags.
- The generator never imports the selector. The census passes `select` in.
