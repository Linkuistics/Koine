# callback-publication-receipt-bundles-k259

## Goal
Complete the k253 input shape on k258's verified edges. Give each
justification its mandatory receipt dependencies, and build the receipt bundles
with direct edge references and upstream arcs. Then show structurally that the
bad receipts are the archive's in all six files.

## Context
K258's edge records and running log. publication-replay.md "Dependency
ownership and finite path selection": the justification table, and the rule to
build each bundle once, where a direct edge reference does not recurse and only
upstream-receipt references do. publication-path-controls.md "Edge inventory
and ownership": the final paragraph (ingress, relayed-destination, release,
request and helper bundles), and the statement that these files have no
dependency-relation SCC. "Upstream join controls" says the ingress bundle is
clean and the T4 bundle is bad. The archive's `bad_receipts`: none in clean and
the multi-clean pair, T4 in upstream-cycle, and G89, T34, T37 in both
multi-cycle files.

## Done when
- Each justification carries the mandatory receipt dependencies the replay
  table gives its rule: none for local order, and the destination bundle for a
  contributing begin. The relay join carries its ingress bundle. The helper
  production join carries its activation-request bundle. W-input and W-enter
  carry only their admission observations. Every justification whose rule has
  dependencies names its bundle.
- Each receipt bundle holds its direct edge references and its upstream arcs,
  interned once. A supervisor ingress bundle holds only its origin hop. A
  relayed destination adds the ingress arc, the join and every egress
  contributor. The auxiliary bundles hold exactly their applicable references.
  The relation D has no SCC in any file, and the census checks this.
- The structural bad set is every receipt that owns a cyclic Trace edge or
  whose upstream arcs reach one. It equals the archive's `bad_receipts` in all
  six files, and each bad receipt names the cyclic edge behind it. It is
  stated as a structural check, not a selector result.
- Each check fails under a deliberate mutation: give an ingress bundle a
  downstream arc to its relay, drop the relay's upstream arc, and let one
  begin justification omit its bundle. `task design:check-publication-profile`
  is green, with its record under evidence/k253. No profile constant or
  document table changes.

## Notes
Retiring this leaf closes k255. Check the k255 brief's Done when before
retiring. K256's selector consumes this shape but is built independently. The
graph and the selector must not share code beyond the plain data shape.

## Decisions (running log)

- **The dependency layer lives on k258's `Graph`**, in publication_edges.py.
  `justifications` is keyed by edge ID, and each justification carries a rule,
  its receipt dependencies and its observations. `bundles` is keyed by receipt
  vertex, in canonical order. Edge records are unchanged. The selector (k256)
  can read these dicts without importing the builder.
- **Receipts are every `frame_received` row (52 per file).** A receipt's
  sending commit uses the class-2 match (direction, ordinal and byte image to
  the unique actual receipt), now factored as `delivered`. So a bundle's join
  is found without going through the begins. A bundle holds its contributors,
  then its commit's relay or auxiliary join, and nothing more. Its upstream
  arcs are that join's dependencies: the ingress for a relay, and the `request`
  field's receipt (G38) for a helper. Ingress, release and activation-request
  bundles have no arcs.
- **Observations:** release and activation joins carry their admission
  coordinates. W-input carries (post, input). W-enter carries (armed, post,
  enter). None of these rules has a receipt dependency.
- **D acyclicity reuses `Trace.cycle_components` over the receipts.** It is
  the same single SCC pass. D is empty of SCCs in all six files.
- **Structural bad set = archive in all six files. No archive error.** In
  upstream-cycle, T4 owns `relay@G28` (G29→G28). In both multi-cycle files,
  G89 owns `contributor@B27` and T34 owns `contributor@G90` (the split 1-byte
  call). T37 is bad only through its upstream arc to G89.
- **Mutations and the checks that caught them:** the G29 ingress arc to T4 was
  caught by bundle_ownership, dependency_scc and bad_receipts. Dropping T37's
  arc was caught by bundle_ownership and bad_receipts. The first begin
  omitting its bundle was caught by justification_dependencies. K258's
  topology mutations are recorded unchanged.
