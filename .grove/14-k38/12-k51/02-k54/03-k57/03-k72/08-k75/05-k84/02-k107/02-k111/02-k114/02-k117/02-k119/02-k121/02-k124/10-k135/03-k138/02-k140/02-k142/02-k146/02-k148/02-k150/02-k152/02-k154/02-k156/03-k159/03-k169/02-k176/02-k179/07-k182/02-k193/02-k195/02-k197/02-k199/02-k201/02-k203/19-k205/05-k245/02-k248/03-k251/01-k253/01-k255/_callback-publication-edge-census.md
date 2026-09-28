# callback-publication-edge-census-k255 — brief

## Goal
Rebuild the edge census for each of the six k220 path-control files in the
census. Use the committed files, the unchanged loader and Trace, and produce
the abstract graph the k253 model takes: lane-ordered rows, edges with
justifications, receipt bundles with upstream arcs, and the 41 distinct ordered
queries. The graph is checked against the archive without a path selector, so
the next leaf starts from a verified input.

## Context
publication-path-controls.md "Edge inventory and ownership" (the five edge
classes, and which classes are absent), "Upstream join controls" and "Rule-issued
query census" (Q01–Q41 with their original and physical pairs).
publication-replay.md "Selected successor edge rules" and the justification
table in "Dependency ownership and finite path selection" (mandatory receipt
dependencies for each rule, and upstream-only ingress ownership). The six
path-controls/ folders. Each coordinates.json is a reading ledger with one label
per row, never a loader input. Its label suffixes mark the row roles: `.K`
relay or auxiliary commit, `.b`/`.r`/`.l` write begin/result/complete, `.I`
supervisor ingress receipt, `.R` auxiliary receipt. Protocol commits and
receipts are `.pN` producer rows. `load_publication` is in
callback-causal-fixture/publication_files.py. `Trace` and
`Trace.cycle_components` are in callback-causal-fixture/analyze.py, which the
census already imports. The evidence/k220 archive's
`topology` (vertices, edges, sccs, bad_receipts, producer_coordinates) and its
manifest's `method` string.

## Done when
- For each file the census builds an abstract graph in the input shape the k253
  brief fixes. Each edge carries its justifications: the rule/anchor ID and the
  mandatory receipt dependencies. Parallel rules on one pair stay distinct.
  Each receipt bundle holds its direct edge references and its upstream-receipt
  arcs, following the ingress/relay/helper ownership rules.
- Checks against the archive, file by file: vertex and edge counts, the Trace
  SCCs from the unchanged `Trace.cycle_components`, the producer coordinates,
  and all 41 queries' physical endpoint pairs. Every consecutive pair in every
  archived raw and usable witness is an edge of the rebuilt graph. The
  upstream-cycle G29→G28 reversed join is present.
- Every justification whose rule the replay table gives dependencies names its
  receipt bundle. The receipts the archive calls bad are exactly those that own
  a cyclic Trace edge, or whose upstream arcs reach one. The census states this
  as a structural check, not as a selector result.
- A deliberate mutation of each check makes it fail: drop one edge class, flip
  the reversed join, and misassign one query's physical pair.
  `task design:check-publication-profile` is green and its record is under
  evidence/k253. No profile constant or document table changes.

## Notes
The k220 derivation lived in scratch code and is not committed. Rebuild it from
the documents. Do not read its results back as inputs. The archive is only the
oracle. Keep the builder separate from `path_bound` and from the selector
(k256), so each can check the others. If a count disagrees with the archive,
find out which is wrong before changing either. Record a real archive error in
the running log for k257 to carry into the documents.

## Decomposition

The archive checks this graph through two independent oracles. The topology
fields (vertex and edge counts, Trace SCCs, producer coordinates, the 41
endpoint pairs, and the witness vertex sequences) check the vertices and edges
alone. `bad_receipts` is the only field that checks the dependency layer:
justifications, receipt bundles and upstream arcs. Each oracle gives an
increment that leaves the census green and has its own mutations. The topology
comes first, because every justification hangs on an edge it has already
verified.

- callback-publication-edge-topology-k258: lane-ordered vertices, the five edge
  classes each tagged with its rule/anchor ID, and the 41 queries mapped from
  the documents' original pairs to physical pairs. It is checked against every
  archive topology field and every archived witness edge. Mutations: drop an
  edge class, flip the reversed join, misassign one physical pair.
- callback-publication-receipt-bundles-k259: the mandatory receipt dependencies
  of each justification, and the receipt bundles with direct edge references
  and upstream arcs. It completes the k253 input shape. The structural
  bad-receipt set must equal the archive's in all six files. Mutations: an
  upstream arc added or dropped against the ownership rules, and a justification
  that omits its bundle. Retiring this leaf closes this node.

Both records go under evidence/k253, as the k253 brief requires.

## Decisions (running log)

- **Split by oracle.** Justifications cannot be checked without the edges they
  label. The topology can be checked without them, because the archived
  witnesses name every consecutive edge. So the topology is a separate first
  increment. It does not wait on its sibling.
- **Children are `impl`.** Both write census code and evidence, not more tree.
  K256 and k257 keep the kind k253 gave them.
