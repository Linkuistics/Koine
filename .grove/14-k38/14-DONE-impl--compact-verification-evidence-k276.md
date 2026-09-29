# compact-verification-evidence-k276

## Goal

Make Koine's verification evidence small enough to publish on GitHub, so
`homebrew-distribution-k46` can make the repository public. On 2026-09-29, when
k46 asked how to publish, the human said: *"We should not publish those 600MB
blobs"* and *"We need to analyse those blobs to determine a more compact way of
having that evidence. That is too much to have on GH purely as verification
docs I think."*

## Context

- The current tree is ~600 MB. ~579 MB of it is two directories:
  `docs/verification/callback-native-capture/` (~486 MB, 1,766 files; the
  largest are `evidence/k1xx/**/causal-controls*/results.json`, 9–19 MB each)
  and `docs/verification/callback-causal-fixture/` (~93 MB, 16,326 files).
  Everything else is ~20 MB. History blobs total ~607 MB, so the same
  directories dominate the history too.
- Measure with `git ls-tree -r -l HEAD`, grouping by path, rather than from
  this note; the figures above were taken at `999a12c5`.
- The callback-publication research line that produced this evidence is still
  active elsewhere in the tree (recent `callback-publication-*` commits). Its
  documents and Taskfile recipes read these files, so compaction must keep every
  claim they make checkable, or say explicitly which claims it gives up.

## Done when

- **The analysis is written down**: what each large evidence family is, what
  claim it supports, who reads it (docs, `design:*` Taskfile recipes, checks),
  and why it is the size it is (redundancy across `k1xx` runs, repeated
  controls, raw captures versus derived results).
- **A compact form is chosen and applied**: for example, derived summaries plus
  digests of the raw captures, deduplication across runs, compression, or raw
  data moved to a release asset. Every document and recipe that cites the
  evidence still resolves, and the Taskfile checks still pass.
- **The resulting tree size is stated**, and the human agrees it is fit to
  publish.

## Notes

**This does not settle how history is published.** Compacting the tip leaves
the large blobs in the 172 existing commits, so k46 still needs a history
decision: a rewrite, or a separate public history (a snapshot without the
blobs). Record what this leaf finds that bears on that choice, but leave the
choice itself to k46 and the human.

**Deleting evidence is a decision against earlier leaves' records.** Where
compaction would lose information an evidence document relies on, ask the human
rather than decide.

## Decisions (running log)

- Measured at `a10e30a`: the tip checkout is 600 MB, but the whole history
  packs (`git clone --bare --no-local` + `gc --aggressive`) to **110.7 MiB**. By
  path family, the pack is PNG 98.6 MiB, native-capture text evidence 4.3 MiB,
  other 4.3 MiB, the 8,120 fixture controls 1.8 MiB, `.grove/` 1.0 MiB. The
  "600 MB" is working-tree bytes; git's zlib and cross-file deltas already
  compact the JSON ~80×.
- The fixture controls regenerate byte-identically from `make_controls.py`
  (all 8,120 plus `controls.json`, checked in a scratch copy).
- **No gzip** (human, 2026-09-29): it breaks diffing and gains nothing over
  git's own compression, which the pack figures confirm. Untracking the controls
  is dropped for the same reason: 1.8 MiB packed does not pay for the churn.
- **Drop the presentation screenshots** (human, 2026-09-29): the 405 PNGs under
  `callback-native-capture/evidence/` are VNC captures of the research line's
  own review page, read by no script and linked by no document;
  `presentation.json` keeps each view's description and digest.
- The human then widened the question: classify all evidence as *useful* versus
  *transient* (never referred to again), measured against the root brief's
  purpose, before deleting anything.
- The callback research line is the `12-k51` subtree, which has no live leaf
  (121 done, 42 abandoned) since the human's prune in `ab0a0b8`; the "still
  active" note in this leaf's Context was stale by then.
- Reference graph from the living documents (README, spec, ADRs, client guide,
  research, architecture views): `callback-native-capture`,
  `callback-causal-fixture`, `callback-input-route`, `callback-exit-observer`
  and `callback-source-freshness` (~588 MB) are cited **only** by the
  architecture views, never by the spec, ADRs, README or client guide. The
  identity contract's reasons rest on `callback-capture-transfer`,
  `process-serial-lifetime`, `retained-ax-binding`, `native-observation`,
  `desktop-window-identity` and the `ax-*`/`direct-ax-endpoint` records.
- **Remove the callback research line from the tip** (human, 2026-09-29,
  reversing `ab0a0b8`'s "records stay" for these five directories): delete the
  five directories, the Taskfile recipes that serve only them, the
  `process-recorder-*` architecture views and the per-leaf presentation history
  in the views README. Keep everything the spec, ADRs, research and README cite.
  The private history keeps every byte; supersedes the screenshot-only decision.
- **Docs are current-state only** (human, 2026-09-29): *"Let's not record any
  history or future plans in the docs."* The one exception: *"we didn't do …
  because …"*, only where non-obvious, framed as a rejected design or
  implementation alternative rather than as history.
- Consequently the keep test is: cited by the spec, ADRs, README or client guide
  for a current claim or a non-obvious rejected alternative. **Remove the rest of
  the k51 records too** (human): `ax-automatic-restoration`,
  `ax-endpoint-adoption`, `ax-top-level-routing`, `direct-ax-endpoint`,
  `native-observation` and its `-connection`/`-layout`/`-requests` reports,
  `callback-capture-transfer`, `docs/research/`, the 15 historical process views
  and the recipes serving only them. Kept: `retained-ax-binding`,
  `process-serial-lifetime`, `native-observation-receive` with the data it cites,
  and the acceptance records.
- A full current-state sweep of the contract documents is a **separate leaf**
  (human), cut ahead of k46; this leaf fixes only the passages its deletions
  touch.
- The architecture views are the seven application views; the process views go with the k51 records under the current-state rule, and the views README keeps no history section. `native-observation-receive.md` is rewritten as the rejected-alternative record the public-AX ADR cites (measurement, alternatives, provenance); its handoff, reopening and criteria-history sections are dropped.
- Result: the tip is **6.4 MB in 566 files** (was 600 MB), with `.grove/` at
  1.6 MB of that. Checked: the relative-link and `#anchor` check (every `.md`
  and `diagrams.json` href outside `.grove/`) is clean except `README.md` →
  `docs/verification/homebrew-install-vm.md`, which k46 creates; that check was
  seen failing on a planted bad anchor. An `rg --hidden` sweep for every removed
  path, recipe and view name finds nothing outside `.grove/` and 140 files
  inside it. `task check:minimum-os` passes; `task test` passes (156 + 16 + 8
  tests).
- **For k46's history decision:** in the packed history (110.7 MiB), blobs at
  paths that no longer exist account for 106.6 MiB and those at kept paths for
  3.4 MiB. A history rewrite that filters the removed paths would therefore pack
  to roughly 3.5 MiB; publishing the existing history carries the removed
  evidence, including the 405 screenshots, along with it.
- Cut `current-state-docs-k277` ahead of k46 for the full current-state sweep.
