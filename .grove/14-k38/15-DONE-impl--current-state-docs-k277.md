# current-state-docs-k277

## Goal

Make Koine's documentation state what Koine *is*, before the repository goes
public in `homebrew-distribution-k46`. On 2026-09-29 the human said: *"Let's not
record any history or future plans in the docs"*, with one exception: *"The
only valid historical data is where we say 'we didn't do ... because ...', and
only then when we are showing something that is non-obvious. That should be
framed as history, but as rejected alternative design/implementation choices."*

## Context

- `compact-verification-evidence-k276` applied this rule only to the passages
  its deletions touched: the architecture views README and manifest, the two
  process ADRs' investigation sentences, two spec paragraphs in "Native
  targeting discussion", and the rewritten `native-observation-receive.md` and
  `retained-ax-binding.md`. Everything else is unswept.
- Known remaining examples: the spec's "records why this was kept for the first
  release", the `#observation-and-retirement-protocol-proposal` section, status
  lines and "still open" acceptance obligations; the evidence documents'
  per-leaf `k<n>` references, "subsequent", "earlier", "remaining work" and
  next-experiment sections (`process-serial-lifetime.md`, the `*-vm.md`
  records); README and client guide phrasing. Find them by reading, not by this
  list.
- Keep test from k276: an evidence document stays only while the spec, an ADR,
  README or the client guide cites it for a current claim or a non-obvious
  rejected alternative. The decision-records skill governs ADR edits.

## Done when

- The spec, ADRs, README, client guide, architecture views and every cited
  verification document describe the current system; leaf keys, dates of
  decisions, "was", "set aside", "next", "remaining", "reopening" and roadmap
  language are gone except inside rejected-alternative statements.
- Every rejected alternative that remains is non-obvious and phrased as
  "Koine does not … because …", citing its evidence.
- Evidence no longer cited after the sweep is removed with its recipes, and the
  relative-link and anchor check k276 used (see its log) is clean apart from
  `homebrew-install-vm.md`, which k46 creates.

## Notes

Where a passage records an acceptance obligation that is genuinely open, that is
current state, not a plan: say what is not established, without saying who will
do it or when.

## Decisions (running log)

- The k276 link/anchor check is now `scripts/check-doc-links.py` behind
  `task check:docs` (`-- --unlinked` lists verification documents no living
  document links to). It reproduces k276's result — only `README.md` →
  `homebrew-install-vm.md` fails — and was seen failing on a planted bad anchor.
- Raw captures (`*.json`, `*.log`, probe sources, screenshots) are left
  byte-identical even where a temp path or clone name carries a leaf key:
  they are the measurement, and rewriting them would falsify it. Only prose
  is swept. Run dates and OS builds in verification records stay as
  provenance of a measurement; dates of *decisions* go.
- The sweep is split across five parallel editors by file group (spec; README,
  CONTEXT and the contract-only client README; ADRs, client guide and
  architecture views; two halves of `docs/verification/`), each on disjoint
  files, then the whole diff is read here before evidence is pruned.
- The architecture views' "AGREED"/"Agreed"/"release one"/"Not selected"
  labels are removed at their sources. The three PlantUML exports are
  regenerated (PlantUML 1.2026.8 reproduces the committed exports
  byte-for-byte from unchanged sources). The three D2 exports cannot be
  regenerated faithfully: D2 0.9.0's bundled dagre and elk layouts give
  1257×1263 and 1135×1493 against the committed 923×1203 (the README's
  Graphviz layout is not installed), so their `<tspan>` labels are edited in
  place to match the sources — the labels are centred, and every new glyph is
  checked present in each file's embedded font subset ("Rejected" needed a
  missing `j`, hence "Not used").
- The schema file's top-level description loses "Agreed". The `schema`
  definition is outside the digest (spec "Schema digest") and no source embeds
  it, so the digest and the served schema are unchanged.
- `native-observation/receive-budget-discriminator.md` stays byte-identical
  although it names `koine-k102-budget` and k101: its SHA-256 is pinned in
  `receive-budget-{before,after}.sha256` and `native-observation-receive.md`
  states those digests match, so it is a measured input, not prose.
  `koine-k51-psn-probe` in `process-serial-lifetime.md` is the literal binary
  name `task fixture:process-serial` builds and the captures show.
- CONTEXT.md's Process incarnation, Public Accessibility boundary and
  Reference withdrawal entries still described the pruned no-time identity
  (callback capture, capture expiry, a capture/right-transfer channel); they
  now state the kept `{ pid, startedAt }` contract, and the four private-AX
  terms no current document uses are dropped.
- Checked editor inferences against the source: the AX messaging timeout is
  set on every element (`WindowTable.swift`), the admission-sources hash
  statement against `admission-primary.sha256`, and the grant-workflow
  script's exact `value` comparison.
- No verification document became uncited (`task check:docs -- --unlinked`
  is empty), so no evidence or recipe is removed.
- Validation: `task check:docs` fails only on README →
  `homebrew-install-vm.md`, and was seen failing on a planted bad anchor; a
  leaf-key token sweep over md/html/d2/puml/graphql/diagrams.json outside
  `.grove/` finds only the two captures above (the same flags find 278
  files in `.grove/`); a history-vocabulary sweep is clean and finds 7, 2
  and 2 hits in the HEAD versions of the spec, README and
  binary-compatibility.md. `task check:minimum-os` passes after re-wrapping
  the spec's floor sentence onto one line, which the check matches;
  `task test` passes (156 + 16 + 8).
