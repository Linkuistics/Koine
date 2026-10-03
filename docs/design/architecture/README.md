# Koine architecture views

Open [the viewer](index.html) for the views, their outline and SVG/source
exports:

- [workspace launch/open and desktop handoff](index.html#diagram-workspace-open)
  and [native outcome boundary](index.html#diagram-workspace-outcomes);
- [first-use metadata and handler lookup](index.html#diagram-workspace-inspection);
- [search discovery and protected traversal](index.html#diagram-search-discovery);
- [canonical path observation and native size refusals](index.html#diagram-search-canonical);
- [native allocation scope and in-process continuation](index.html#diagram-search-resources);
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
The current-discussion panel presents the
[resource boundary comparison](index.html#diagram-search-resources): the operator
declined helper design, questioning why a separate process was needed. The
source/SDK concern does not demonstrate a normal-search failure or establish
isolation's necessity. Continue inside Koine's process; owned/opaque demand,
two-credit walk ownership, trustworthy negative metadata and worker cleanup/
recovery still require a complete contract.
The [allocation decision](../../specs/workspace-search.md#native-allocation-decision)
keeps those obligations live before selecting a runtime route. The
[feasibility analysis](../../verification/search-native-resources.md) records
the evidence and residual obligations. The unchanged canonical path view,
FIFO and reviewed transport/compatibility provide context.
The [discovery obligations](../../specs/workspace-search.md#discovery-obligations-before-planning)
require the canonical proposal's review and native resource design/review before planning. Finish shallower admitted
listings before deeper ones, with one current stream/root and a 512-task/384 KiB
pending queue. Frontier overflow counts matchable anchors in one reserved root
group and continues sibling-name examination; depth has a separate group.
The shared account reserves roots + 2 credits/job below the inherited soft limit,
leaving 128 descriptors outside owned search credits and capping those at 72.
Worker-only cleanup retains streams, paths and credits after blocked-call freeze.
Current-stream checks precede every listing turn/read; checked component
walks repeat against the wait. A changed queued prefix/parent stops the root
once rather than allocating a failure per task. Residual check-to-read/open
races remain native acceptance obligations. Public fsgetpath uses descriptor-derived
filesystem/object identity with rechecks, not atomic descriptor binding. Its
8,192-byte buffer includes NUL; native directory text is at most 8,191 bytes,
while public joined-file values can still reach 8,192 bytes. Known native/public
size omissions group at a stable actual parent before finalization; formerly
fitting prefixes now too long stop once as change. The canonical proposal needs
load-bearing review. Planned native 4,224-byte tasks bind at 79/80 by bytes;
synthetic 43/44 maximum-value arithmetic is separate. Opaque
empty/nil answers cannot establish absence; resource-call health and an instrument
for transient opens/accept backoff are open too.
Normally launched signed-host listener/store/action serviceability must pass;
static arithmetic, periodic descriptor counts and eventual error-free client
replies are insufficient. Canonical review and native resource design/review precede planning. Safari/Finder, protected Library-link calls,
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

The current update changes these views and summaries:

- [Search → native allocation decision](index.html#diagram-search-resources) — Records the helper scope refusal and keeps native semantics, two-credit ownership, negative-health and worker-recovery obligations live in process.
- [Native allocation contract](../../specs/workspace-search.md#native-allocation-decision) — Retains the single-process posture and every binding budget, metadata, domain and acceptance obligation; the complete native route remains pending.
- [Native resource analysis](../../verification/search-native-resources.md#acceptance-obligations-carried-forward) — Explains the possible shared-table failure, retains in-process negative-fact and serviceability controls, and makes helper-specific falsifiers conditional on separate authorization.

The canonical, traversal, coverage and handoff views remain unchanged context.

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

Run `task design:search-render` for the six search views with D2 0.9.0,
ELK for the canonical/resource views and Dagre for the remaining views, light theme 0
and dark theme 200. Open
<http://127.0.0.1:8765/#diagram-search-coverage>.
Run `task design:search-check` for independent/composed SDL and example validation,
with failing schema controls; this does not prove runtime branch invariants.
The allocation recommendation was inspected in local Safari at
<http://127.0.0.1:8874/#diagram-search-resources>, using the existing static
viewer. A fresh deep link reached the resource title and Current/Updated
markers; its SVG start node, allocation branches and labels rendered in the
light desktop view. The manifest's current discussion and single changed-view
summary matched the source. This presentation check supplies no native call,
consent, helper/signing, binary or resource verdict. Dark appearance was not
checked. Older presentation records below concern their earlier revisions.

The resource feasibility view was checked in Safari in the isolated macOS
26.5/25F71 clone `koine-k111-design`. The manifest, viewer, D2 source and SVG
were byte-identical to the host subjects. A fresh resource deep link reached
the intended title and Current/Updated markers; the SVG start and upper branches
were readable at a 1920-pixel window. The current-discussion panel showed the
feasibility status, relevant context links and the single changed-view summary.
The whole light export was also inspected as a 1600-pixel librsvg raster.
This verifies light presentation only; dark/narrow browser appearance was not
checked. Native inspection/resource acceptance remains pending.
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

The k108 canonical-path revision was inspected in Firefox on the isolated
Ubuntu 24.04 clone `koine-k108-design`. All four changed deep links identified
their intended views at a 1920-pixel window width. Labelled starts, canonical
call/size/parent/root branches, coverage outcomes and action handoff were
readable; tall views use normal vertical scrolling. Light presentation and
dark canonical/coverage/handoff presentation were checked. The discussion's
status, six relevant links, four changed markers/summaries and outline agreed
with the manifest; its dark discussion reflowed at an observed 800-pixel window
width without horizontal clipping. Before/after per-file SHA-256 values stayed
unchanged for index.html, diagrams.json and the canonical/traversal/coverage/
handoff D2/SVG pairs, and each matched the guest copy. ELK was selected for the
new canonical view after comparing its readable call/entry layout with Dagre.
The clone was stopped after the check. This is browser presentation evidence
only; public-call compilation is recorded separately in the
[call analysis](../../verification/search-canonical-paths.md), and design review,
native reachability, prompt behavior, independent binaries and useful coverage
remain pending.
