# callback-publication-generator-legal-k273 — brief

## Goal
Make the generator's scaled histories loader-legal, and write each one as a
real observations file that the unchanged `load_publication` and `build`
read. Legality and the edge census then become the loader's result rather
than the generator's claim.

## Context
The k272 leaf's loader-oracle decision and its three reasons
(`LOADER_ORACLE` and `rejections` in publication_profile.py). k271's
insertion rules in `scale` and `lift` (publication_generator.py). In
publication_files.py: `_producer`, `_row` and `load_publication`, which covers
the message-producer finding and the ordinal limit of 80. The path-control
files' row and frame shapes (publication-path-controls.md "Rows and bytes").
`build` in publication_edges.py takes its queries from the doc's Q01-Q41
table.

## Done when
- Each inserted producer record is a V18 row that `parse_record_lines`
  accepts. Its fields are taken by rule from a base record of the same event,
  or the leaf states the rule it uses. The neutral `scaled` rows use an event
  that is legal and that no recipe reads. Every recipe's issued pairs are
  unchanged, and so are k272's scale figures.
- Each added app frame is loader-legal: either it has a producer send whose
  embedding matches the frame, or it is an auxiliary frame. The rule for
  choosing between these is stated.
- The generator writes a manifest and observations file for a stated vector
  (the clean vector first, then one scaled vector). `load_publication` reads
  each with no local finding, and `build` equals `generate` in lanes, canonical
  vertices, edges, justifications, bundles and producers. Queries are compared
  on the generated side only, because `build` reads the doc table.
- The census stops recording k272's rejections, or records them as fixed. It
  is green under evidence/k254, and k253's record stays byte-identical.

## Notes
Byte images and ordinals must follow the files' own codec
(publication_codec, publication_protocol, publication_auxiliary). If the
writer does not fit one session, decompose it: first the legal producer
records, then the file writer.

## Decomposition

Legality turned out to have a seam of its own. In a real file every app frame
commit embeds its producer `send`, so an added frame uses a producer seq. The
loader caps an app's seq at 256 (`_producer`). The auxiliary grammar gives an
app only `aux.activate.1-9`, from the controller. So the sampler and the
targets can add a frame only as a send. That puts k272's SCALE sampler at seq
54 + 202 + 40 = 296. Every padded k266 candidate goes over too: in `combined`,
B reaches 18 + 238 + 54 = 310. Neither history can be written legally, even
though each graph is unchanged. So the node splits into the records and then
the file:

- callback-publication-generator-records-k274: each inserted producer record
  and each added frame is a V18 row that parses. Pairs, graphs and k272's
  figures are unchanged. The census records the rejections as fixed, and pins
  which vectors pass the shared seq budget.
- callback-publication-generator-writer-k275: the observations file writer.
  The clean vector first, byte-for-byte against the committed file, then a
  scaled vector inside the seq budget. `load_publication` and `build` read
  both.
