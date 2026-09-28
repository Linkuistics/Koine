# callback-publication-codec-k194


## Goal
Make the publication frame codec and bounded byte assembly executable at the
existing offline diagnostic seam, without inventing receipt or causal evidence.



## Context
The durable contract is `docs/verification/callback-native-capture/publication-codec.md`;
verification and exact corpus preservation are under `evidence/k194/` beside it.
K195 inherits the full parent charter and this byte boundary.

## Done when
- Exact five-field envelope, bounded identifiers/owners, strict UTF-8 JSON,
  integer-only numbers, nested duplicate rejection, length/frame/payload budgets,
  compact origin encoding and unchanged received byte images are falsified.
- A fixed 8,192-byte reassembly buffer supports split/coalesced frames, bounded
  offers and exact snapshots. Parsing leaves bytes present until explicitly
  consumed; neither buffered nor decoded bytes supply a receipt observation.
  Canonical bounded base64 carries frame and snapshot images without ambiguity.
- Meaningful invalid and adjacent valid controls include exact size boundaries,
  malformed prefixes, trailing documents, noncanonical base64 and complete-plus-
  partial snapshots. Pin/check via Taskfile and renew every V1–V26 report/input
  itemwise against k192 without rewriting fixtures or expectations.
- Record API ownership, limits, alternatives and the executable evidence in the
  diagnostic contract, both recorder contracts, assessment and visual discussion.
  Retain all closed payload/route/row/manifest/schema/loader/Trace/lifecycle/budget
  and original k193/k182/k179 duties in k195. No analyzer version/native credit.

## Notes
This is an executable diagnostic design, not a shipping implementation or the
full transport reader. No native I/O, payload-schema credit, observation rows,
receipt ordinals, F/U/I or causal graph is supplied by the codec. Existing Trace
and V1–V26 stay unchanged. Render/view only in a disposable clone.

## Decisions (running log)

- Keep byte framing and reassembly below message/lane semantics. Return exact
  immutable images and decoded envelope facts; a later validator owns closed
  payloads, routes, admissions and observation append. Peeking cannot remove a
  buffered frame, so an append failure can retain the full snapshot without a
  fabricated receipt. No second graph or generic transport plugin is introduced.

- The byte codec is now specified in `docs/verification/callback-native-capture/publication-codec.md` and executable in `callback-causal-fixture/publication_codec.py`. The pinned check passes 58 codec tests plus 10,176 existing tests; five temporary-copy mutants are detected. The full 8,120-control legacy renewal preserves all reports and 16,241 fixture/expectation files against k192. See `evidence/k194/preservation.json`; large maps/reports are losslessly archived as `.json.gz` with both hashes.
- One fresh read-only review found only a parser-depth test portability defect. The repaired test allows exact acceptance or the documented unsupported-depth result and passes on Python 3.11/3.14. K195 must prove all closed payloads fit that boundary or replace it. No second review is needed for the test-only repair.
- Both contracts, the assessment and editable codec view record the boundary. The full diagram/caption, discussion and fresh deep link were inspected in disposable Safari at 1024×768 light; the clone and temporary server stopped. No native recorder ran. ADRs/glossary retain their product meaning. All four k194 Done when items are covered; k195 remains live and retains every original k193/k182/k179 obligation.
