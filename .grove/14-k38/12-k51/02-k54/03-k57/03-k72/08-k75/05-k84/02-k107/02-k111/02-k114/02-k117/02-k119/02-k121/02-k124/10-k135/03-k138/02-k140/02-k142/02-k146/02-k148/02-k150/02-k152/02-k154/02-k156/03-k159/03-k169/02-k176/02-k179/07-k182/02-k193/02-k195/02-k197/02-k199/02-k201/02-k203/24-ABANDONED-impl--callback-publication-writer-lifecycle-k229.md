# callback-publication-writer-lifecycle-k229

## Goal
Writer/reader lifecycle and budget replay: seals, abandonment, late results,
queued and terminal-unattempted commits, pinned buffers, external bounds and
the post-budget reserve, as reported per-owner facts.

## Context
publication-lifecycle.md "Writer seals, buffers and late results", "Stopped
readers and buffered suffixes", "External bounds and retained work";
publication-capacity.md "Frozen limits and reserve" and "Overflow and
unavailable evidence".

## Done when
- Controls: L05–L08a/L08b, L11–L15, L32, L34; B12 (16 queued plus pinned
  active, seventeenth refused before K), B13 (each resource separately),
  B14, B18, B19 (origin 65, auxiliary 10, physical/direction/owner/case
  attempts).
- Post-budget ingress replayed from real budget_stop histories: the 196-row,
  1,243,044-byte supervisor reserve and the 264-row app reserve exercised with
  actual rows; ordinary admission stops before row 1,537; terminal-unattempted
  mandatory commits keep real ordinals; no receipt, completion or clean exit
  manufactured.
- Frame 80 accepted versus frame 81 refused, reader next 81 versus 82, in
  replayed lifecycle as well as k225's file checks.
- Collector permutations leave milestones, cuts, buffer/lease states and
  vectors identical (L34).
- Every stress history stays inside its row of the "Required-construction
  fit" table in publication-capacity.md and the `/2` envelope, and passes
  k225's gate, so it completes under the production profile.

## Notes
Callback-publication-share-reach-k252 settles which byte-share and full
reserve-tail boundaries a file can attain before this leaf builds them.
Protocol milestones M01–M33 and L20–L31/L33 need controller rules (k235).
Time deadlines/reserve stay k144.
