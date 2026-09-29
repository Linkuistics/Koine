# callback-publication-generator-writer-k275

## Goal
Write a generated history as a real manifest and observations file that the
unchanged `load_publication` and `build` read. Legality and the edge census
then come from the loader, not the generator.

## Context
The k273 brief (Done when bullets 3-4), and k274's running log (record rules,
unrelayed-frame messages, the seq budget). publication-path-controls.md "Rows
and bytes": PIDs 100-104, admissions, release, helper, ordinals per directed
writer, call IDs per owner (640 reserved for the split's last byte), and
payloads that copy the input and active tuples. publication_codec,
publication_protocol and publication_auxiliary for the byte images. `build`
reads `CONTROLS / case`. An absolute folder path reaches any folder without
changing `build`.

## Done when
- The clean vector's written file is byte-identical to
  path-controls/clean/observations.jsonl and case.json. The five other
  path-control vectors are also compared, or each difference is stated.
- One scaled vector inside the seq budget (k274) is written. For it,
  `load_publication` reports no local finding, and `build` equals `generate`
  in lanes, canonical, edges, justifications, bundles and producers. Queries
  are compared on the generated side only.
- The census writes to a scratch folder, drops `LOADER_ORACLE`'s stand-in
  decision, and records the loader's result. It is green under evidence/k254,
  and k253's record stays byte-identical.

## Notes
Supervisor neutral rows need a legal supervisor event. publication-files.md
says `registered=false` "is readable and proves no successful admission". So
an unregistered `admission` is the candidate. Decide it and state it.

## Decisions (running log)
- The writer lives in publication_generator.py (`write`, `written`), fed by the lift.
  Each lift frame now carries its physical recipient, its logical route, message and
  payload, and its result and complete rows. Local rows carry their fields (PIDs,
  admissions, the release, the activation request and the helper's rows). The writer
  derives the rest by rule, in lane order:
  - ordinals count per directed writer (commits) and per directed reader (receipts);
  - call IDs count per owner, and a split's last byte takes 640 without advancing the
    count;
  - each begin offers the unwritten suffix, and returns all of it except one byte per
    begin still to come;
  - images come through `encode_protocol` / `encode_auxiliary`. Input and active
    payloads copy their producer row's tuple and seq; the rest are `{}`;
  - producer records are written with sorted keys, and the base's case is renamed
    to `path-controls`.
- The turn0 files differ from their multi-* files only in the sampler's `enter.turn`.
  `write` takes that as a `turn` argument rather than as a vector field, because no
  graph field carries it. So all six files are reproduced, with no stated difference.
- The supervisor's neutral row (`scaled` in the lift until now) is an unregistered
  `admission`: role controller, peer_pid 105 (no app's PID), registered=false. The files
  read false as proof of no successful admission. So it admits nothing, no release
  names it, and no rule reads it. Its kind is still local, so no figure moves.
- Result: all six path-control files, and each manifest, are byte-identical to the
  committed ones. Two in-budget scaled vectors are written: SCALED "one of each",
  which has every insertion kind but pads, and candidate "many activities", at
  production scale with 1,020 rows and 2,668 queries. The loader reads each with no
  local finding, and `build` equals `generate` in every compared field except queries.
  Written, every other vector is refused with `producer-seq`. That refused set is
  exactly `LOADER_SEQ_OVER`, so k274's pinned set is now the loader's own result.
- Stopped 2026-09-29 by the human, before commit: the no-time process identity
  subtree (k51, with its impl k52) is of marginal relevance to the release and is
  pruned. The time-based `{ pid, startedAt }` identity stays for `koine-desktop/1`.
  The writer code was not committed.
