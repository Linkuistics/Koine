# Koine architecture views

Open [the viewer](index.html) for the views, their outline and SVG/source
exports:

- [workspace launch/open and desktop handoff](index.html#diagram-workspace-open)
  and [native outcome boundary](index.html#diagram-workspace-outcomes);
- [first-use metadata and handler lookup](index.html#diagram-workspace-inspection);
- [search discovery and protected traversal](index.html#diagram-search-discovery);
- [search scope and coverage](index.html#diagram-search-coverage) and
  [selection and action handoff](index.html#diagram-search-handoff);
- [first-party candidate selection](index.html#diagram-provider-selection) and
  [publication and failure](index.html#diagram-provider-publication);
- the designed extension's [provider boundaries](index.html#diagram-workflow-providers),
  [independent target capture](index.html#diagram-workflow-targets) and
  [complete effect authority](index.html#diagram-workflow-authority);
- [resident composition](index.html#diagram-packages) and
  [source packages](index.html#diagram-source-packages);
- [served desktop interaction](index.html#diagram-addressing);
- [authorization flow](index.html#diagram-machine-interface) and
  [grant lifecycle](index.html#diagram-grants);
- the [provider ABI choice](index.html#diagram-plugin-abi-options) and
  [SDK contributions](index.html#diagram-sdk-contributions).

The served desktop contract identifies a process by PID and kernel start instant
and uses public macOS Accessibility; the
[spec](../../specs/machine.md#native-targeting-discussion) lists the reuse races it
accepts. Graphs begin at their marked start node; sequences read top to bottom.
Captions state evidence limits. No diagram is formal verification or release
acceptance.

The workflow views are reviewed design obligations, pending implementation and
acceptance. First-party bundle selection now has its
[Machine contract](../../specs/machine.md#first-party-provider-selection) and
[selection decision](../../adr/first-party-provider-selection.md). Its review
integration clarifies visible tie fallback, candidate-specific staging and
old-host refusal; implementation and seam-assigned acceptance remain pending.
They accompany [workflow providers](../../specs/workflow-providers.md).
The current-discussion panel focuses on typed prompt-risk BLOCKED outcomes,
with selection handoff, discovery evidence and the metadata/handler view as context.
Generic system-app roots, checked .app-link metadata, exact observation/group/
remainder semantics and independent root budgets await load-bearing review and
native acceptance. BLOCKED uses null matches/dependency and exact coverage without
a search execution error; UNKNOWN consent does not mean missing named consent.
Its load-bearing review and runtime acceptance remain pending. No reduced
home/application baseline is accepted; existing framework failure mapping is fixed.
The [workspace spec](../../specs/workspace-launch-and-open.md)
and its SDL include the design-review corrections; implementation and native
acceptance remain pending. The views distinguish conditional running-copy reuse,
bounded acknowledgment, process-only receipts and publication errors.

The preceding evidence discussion records the
[protected-path prompt boundary](index.html#diagram-workspace-inspection): the
tested metadata route was prompt-free, while document file-URL handler lookup
prompted even when returning an app after denial. The
[evidence report](../../verification/protected-path-metadata.md) contains exact
calls, result/error classes, controls and unavailable volumes. Protected default
opening remains pending a human consent/semantics decision. The updated
[request sequence](index.html#diagram-workspace-open) qualifies its inspection
premise with that limit; the outcome view remains unchanged context.

The current update changes these views:

- [Search → scope and coverage](index.html#diagram-search-coverage) — Added
  null matches/dependency without an execution error for BLOCKED, UNKNOWN
  consent diagnostics and the publication-denial limit.
- [Search → selection and action handoff](index.html#diagram-search-handoff) —
  Added the client’s blocked-scope/unknown-consent display before AVAILABLE
  selection and retained installation-specific action choices.
- [Search contract → selection and publication](../../specs/workspace-search.md#selection-and-publication-invariants) —
  Defined coverage-only/aliased matches, error-free branch invariants, mixed
  roots and live-revocation expectations.
- [Prompt-risk decision](../../adr/prompt-risk-is-search-data.md) — Chose typed
  result data over a new permanent framework diagnostic and stated its reopen condition.
- [Machine → provider failure compatibility](../../specs/machine.md#provider-failure-compatibility) —
  Preserved all existing kinds and nil/blank/named consent mapping without new accessors.

The [evidence report](../../verification/search-discovery.md) and its existing
view remain unchanged mechanism context. The new stream adapter is a design,
not native acceptance or an exhaustive filesystem/index-availability proof.

Serve locally with `task design:serve` and open
<http://127.0.0.1:8765/#diagram-workflow-providers>. The task serves only this
presentation directory. Graphs start at the node labelled “Start here”; sequences
start at their first message.
Use `task design:serve PORT=8767` if the default port is already occupied.

On narrow screens the whole-graph fit view is an overview, not a reading scale.
Use native size and pan to the labelled start, or open the SVG export to zoom.
Native size can initially expose padding; text labels, not a dark fill that the
theme may replace, identify the start. The linked spec supplies the same contract
as reflowable text. This presentation trade-off does not change acceptance.

## Sources and exports

`diagrams.json` owns the introduction, captions and outline groups. Every view
has a PlantUML or D2 source with a version-controlled SVG export beside it.
Regenerate and inspect exports; do not hand-edit SVG. The viewer fetches sources
and exports on reload. PlantUML sources use PlantUML 1.2026.8; D2 sources use
D2 0.9.0 and Graphviz 16.1.0. Retain each source's existing renderer settings
when changing it.

Run `task design:workflow-render` to regenerate the three workflow exports with
D2 0.9.0 (Dagre, light theme 0/dark theme 200) and PlantUML 1.2026.8. Inspect the
served result after source edits; HTTP success is not a rendering check.

Run `task design:selection-render` to regenerate the two selection exports with
the same pinned renderer versions. Start with
<http://127.0.0.1:8765/#diagram-provider-selection>.

Run `task design:workspace-render` to regenerate the workspace sequence and
outcome flow with the same pinned renderer versions. Start with
<http://127.0.0.1:8765/#diagram-workspace-open>.

Run `task design:search-render` for the three search views with D2 0.9.0,
Dagre, light theme 0 and dark theme 200. Open
<http://127.0.0.1:8765/#diagram-search-coverage>.
Run `task design:search-check` for independent/composed SDL and example validation,
with failing schema controls; this does not prove runtime branch invariants.
The preceding discovery-only presentation was checked in the isolated evidence
VM. The current search-design presentation was checked on 2026-10-03 in Safari
on the isolated macOS 26.5 clone `koine-k92-design`, using a byte-identical local
copy of the manifest and SVG exports. Both deep links, the labelled starts and
outcome branches were readable at a wide window size in light and dark
appearance. The discussion, changed markers and outline reflowed at an
800-pixel window width; narrow fit remains an overview as described above.
These are presentation checks; native search acceptance remains pending.
That Safari check predates the review repairs above and does not validate the
current regenerated exports. In k95, the regenerated coverage and handoff SVGs
were rasterized with librsvg and inspected at 1200/900-pixel widths: labelled
starts, outcome branches, arrows and handoff text were readable without clipping.
This checks static light rendering; it is not a new Safari/reflow or dark-mode
check and makes no native search claim.

The typed-BLOCKED revision was checked in Safari on the isolated macOS
26.5/25F71 clone `koine-k97-design`. Fresh coverage/handoff deep links identified
the intended views, with labelled starts, readable outcome branches and action
handoff at a 1600-pixel window width. The discussion panel's links, changed-view
summaries and outline agreed with the manifest in wide and 800-pixel dark-mode
windows. Safari displayed the SVGs with their light background inside the dark
viewer; that rendering remained readable. The manifest and both changed SVGs
had matching SHA-256 digests in the workspace and guest copy. This checks
presentation only; it establishes no runtime branch, binary or native acceptance.
