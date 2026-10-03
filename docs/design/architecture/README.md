# Koine architecture views

Open [the viewer](index.html) for the views, their outline and SVG/source
exports:

- [workspace launch/open and desktop handoff](index.html#diagram-workspace-open)
  and [native outcome boundary](index.html#diagram-workspace-outcomes);
- [first-use metadata and handler lookup](index.html#diagram-workspace-inspection);
- [search discovery and protected traversal](index.html#diagram-search-discovery);
- [shallow-first traversal and shared descriptors](index.html#diagram-search-traversal);
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
The current-discussion panel presents per-root FIFO breadth-first traversal and
atomic process-wide descriptor admission alongside reviewed transport/compatibility.
The [discovery obligations](../../specs/workspace-search.md#discovery-obligations-before-planning)
require the native canonical-path/resource producers and their load-bearing reviews before planning. Finish shallower admitted
listings before deeper ones, with one current stream/root and a 512-task/384 KiB
pending queue. Frontier overflow counts matchable anchors in one reserved root
group and continues sibling-name examination; depth has a separate group.
The shared account reserves roots + 2 credits/job below the inherited soft limit,
leaving 128 descriptors outside owned search credits and capping those at 72.
Worker-only cleanup retains streams, paths and credits after blocked-call freeze.
Current-stream checks precede every listing turn/read; checked component
walks repeat against the wait. A changed queued prefix/parent stops the root
once rather than allocating a failure per task. Residual check-to-read/open
races remain native acceptance obligations. The named F_GETPATH route cannot
implement maximum accounting paths; canonical-path selection is open. Opaque
empty/nil answers cannot establish absence; resource-call health and an instrument
for transient opens/accept backoff are open too.
Normally launched signed-host listener/store/action serviceability must pass;
static arithmetic, periodic descriptor counts and eventual error-free client
replies are insufficient. Native path/resource producer reviews precede planning. Safari/Finder, protected Library-link calls,
useful home coverage and measured omissions remain pending.
Canonical target names/paths make app ranking independent of link/direct route;
native bundle identity merges one installation without merging distinct copies
with equal identifiers. Reviewed BLOCKED transport keeps null matches and
UNKNOWN consent, subject to field/lifecycle/publication errors. Changed-root or
uncertain inspection is a failure-class reason before prompt risk; it does not
change admission. Search 1.1.0 declares both existing authority/selection features;
current checks move to search-required profiles while retained action-only
binaries/profiles remain distinct under the
[compatibility contract](../../specs/workspace-search.md#compatibility-subjects-and-diagnostic-acceptance).
No reduced home/application baseline is accepted, and existing
framework failure mapping stays fixed.
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

- [Search → finish shallow names before bounded descent](index.html#diagram-search-traversal) — Adds FIFO order, separate descent-bound groups, fresh component walks and shared descriptor credits.
- [Search → scope and coverage](index.html#diagram-search-coverage) — Replaces the reopened DFS path with FIFO work and matchable frontier anchors; adds atomic admission and worker-owned credit cleanup.
- [Search → selection and action handoff](index.html#diagram-search-handoff) — Names the revised traversal/account and frontier omissions while retaining canonical identity and both-control actions.
- [Search contract → resource accounting](../../specs/workspace-search.md#resource-accounting-and-scheduling) — Defines the exact order property, queue count/byte charges, unchanged coverage reservation and the iterative-deepening trade-off.
- [Search contract → process-wide descriptor admission](../../specs/workspace-search.md#process-wide-descriptor-admission) — Adds atomic whole-job credits, soft-limit/reserve rules, native refusal cohorts and explicit platform/serviceability limits.
- [Search contract → capacity examples](../../specs/workspace-search.md#capacity-examples-and-acceptance-threshold) — Gives per-name shallow/deep/later-root subjects and exact wide/depth/descriptor outcomes under unchanged bounds.
- [Coverage decision](../../adr/search-coverage-describes-observations.md) — Defines public observation/group/remainder vocabulary.
- [Traversal decision](../../adr/search-traversal-preserves-shallow-names.md) — Chooses FIFO order with frontier, same-level omission and repeated-prefix-work trade-offs; private resource mechanics remain in the spec.
- [Application identity decision](../../adr/application-search-uses-bundle-identity.md) — Includes queued-task paths in the unified canonical spelling rule.

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

The coverage-clarification/discovery-obligation revision was regenerated with
`task design:search-render` and inspected as librsvg rasters at 1200 pixels
(coverage) and 900 pixels (handoff). Labelled starts, updated group/remainder
meanings, pending-design labels, outcome branches and action arrows were readable
without clipping. This is static light rendering; the earlier Safari, narrow
reflow and dark-mode observations do not validate these revised exports.

The fixed-region/DFS/canonical-identity revision was checked in Safari on the
isolated macOS 26.5/25F71 clone `koine-k101-design`. Fresh coverage/handoff
deep links identified the intended views, with readable labelled starts and
changed traversal/identity labels at a 1600-pixel window width. The 800-pixel
dark discussion panel reflowed with its status, relevant links, changed-view
summaries and outline; wide dark presentation retained readable light SVGs.
The manifest and both changed SVGs had matching per-file SHA-256 values in the
workspace and guest copy. Static full-view rasters were also inspected for
group/outcome and action branches. This checks presentation, not search API,
provider-binary, prompt-free native-call or useful-coverage acceptance.

The transport-integration revision was regenerated with D2 0.9.0 through
`task design:search-render` and inspected as librsvg rasters at 1200 pixels
(coverage) and 900 pixels (handoff). Labelled starts, changed-root/failure
precedence, lifecycle-error guidance and action branches were readable without
clipping. This checks static light rendering only; the earlier Safari, dark-mode
and narrow-window observations do not validate these revised exports. Runtime,
independent binary pairs and native search acceptance remain pending.

The discovery-integration exports were regenerated through
`task design:search-render` and inspected as librsvg rasters at 1200 pixels
(coverage) and 900 pixels (handoff). Labelled starts, the job-wide witness-account
refusal branch, traversal-replacement labels, anchor counts, outcome branches
and action arrows were readable without clipping. This checks static light
presentation; the earlier Safari/dark/narrow-window checks do not validate this
revision. Native calls, useful coverage and independent binary acceptance remain
pending. That earlier presentation check does not validate later traversal revisions.

The FIFO/descriptor revision was inspected in Safari on the isolated macOS
26.5/25F71 clone `koine-k105-design`. Fresh traversal, coverage and handoff links
identified their intended revised views; the focused traversal flow was readable
at a 1900-pixel window width. Coverage's revised admission/traversal labels and
handoff's search contract labels were checked in the browser. The 800-pixel dark
discussion panel reflowed its proposal status, relevant links and three changed
view summaries without clipping. Wide dark presentation retained readable SVG
labels, including the light-background focused flow. The manifest and three
changed exports had matching per-file SHA-256 values in the workspace and guest.
This checks presentation only; source review, adapter/binary acceptance, no-dialog
native calls, useful coverage and normally launched process serviceability stay
pending. Render all four search views with `task design:search-render` (D2 0.9.0,
Dagre); serve this directory with `task design:serve`.

The k107 integration regenerates the traversal/coverage/handoff exports with
turn-before-read revalidation, changed-prefix remainder and repeated-walk costs.
Native canonical paths (k108) and opaque resource calls/serviceability instruments
(k109) require their producers and load-bearing reviews before planning. Their
eventual native evidence must observe transient descriptor events and suppressed
accept backoff; the views and schema checks do not supply it. Older presentation
records above refer to their then-current exports.
