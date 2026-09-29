# callback-publication-serializer-k225

## Goal
A deterministic successor fixture writer: a declarative five-lane history in,
exact manifest and observation files out, round-tripping through the k202
loader. Every later publication control is built with it.

## Context
publication-files.md (closed physical vocabulary, embedded producers, exact
bytes), publication-capacity.md "Concrete encoding" and "Capacity derived from
enumerated input", publication-codec.md, publication-protocol.md,
publication-auxiliary.md, publication-path-controls.md "Rows and bytes".

## Done when
- Frames go through the k194 codec with k198/k196 closed payloads; rows are
  compact JSON with canonical base64 and embedded producers; the writer emits
  fixed-coordinate reversed and round-robin collector permutations.
- The six k217 path-control inputs and their permutations are reproduced
  byte-identically from declarative descriptions (drift check against their
  bound digests).
- B09 (4,096 vs 4,097-byte frame; body-prefix disagreement), B10 (11,609-byte
  image+producer row and 12,973-byte snapshot row versus the old 4,096 cap) and
  B20 (exact row limit versus one byte over, including escapes and base64
  padding; next ordinal 81 after receipt 80 versus frame 81 and next 82) run on
  real writer output through the k202 loader.
- Actual serialized row/lane/case/manifest sizes are remeasured against the
  capacity census envelopes (per-lane maxima, 4,721,299-byte whole case,
  16,384-byte manifest); a mismatch fails.
- Profile fit gate: for every fixture the writer emits, the check reports its
  kind counts against the `/2` envelope (4,138 rows; 161 commits/receipts,
  1,281 begins) and its path-reference bound from the census bound function
  (`path_bound` in publication_profile.py: per-query lane-class witness bounds,
  V − 1 per witness unless the fixture's Trace is acyclic, plus V + H + D)
  against the admitted 8,388,608. It also holds the fixture to its row of the
  "Required-construction fit" table in publication-capacity.md. A fragment's
  added rows stay within its class vector on a lifted V11–V25 base. An
  envelope-scale B fixture stays within its startup-ceiling row (kind vector
  and λ). A fixture outside its row or over the limit fails the gate and is
  rebuilt on its row's construction; nothing is deferred to k240 measurement.
- `design:check-publication-report` exists in the Taskfile and runs these
  checks with `design:check-publication-profile`; every existing publication
  and legacy check is unchanged and green.

## Notes
The writer is fixture tooling, not a shipping protocol or a recorder. It
constructs histories; it never computes expected analyzer answers.
