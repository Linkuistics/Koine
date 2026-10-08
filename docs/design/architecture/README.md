# Koine architecture views

Open [the viewer](index.html) for the views, their outline and SVG/source
exports:

- [workspace launch/open and desktop handoff](index.html#diagram-workspace-open)
  and [native outcome boundary](index.html#diagram-workspace-outcomes);
- [long-location resolution and application hand-off](index.html#diagram-workspace-long-locations);
- [first-use metadata and handler lookup](index.html#diagram-workspace-inspection);
- [search discovery and protected traversal](index.html#diagram-search-discovery);
- [canonical path observation and native size refusals](index.html#diagram-search-canonical);
- [pre-open mount and policy-target proof boundary](index.html#diagram-search-preopen);
- [serviceability evidence and failure controls](index.html#diagram-search-serviceability);
- [native allocation ownership and observable handoff](index.html#diagram-search-resources)
  and [two-temporary inspection ownership](index.html#diagram-search-inspection);
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

The search implementation is being reassessed under the
[requirement to reuse existing OS facilities or established tools](../../requirements/modaliser-workflows.md#ownership-and-existing-constraints).
Search stays in Koine. These views describe the earlier candidate and its open
questions; they do not authorize a search engine built from scratch. Tooling
design must reconcile the retained contract and native permission obligations
before the mechanism-specific witness work continues.

The earlier discussion is **pre-open target inspection policy**. Start at
[Establish pre-open proofs before acquiring a child](index.html#diagram-search-preopen).
The accepted fixed-layout bootstrap and post-open classifier remain selected.
The [boundary analysis](../../verification/search-preopen-boundary.md) evaluates
lookup-only target acquisition under the ADR/k174 before conditional new metadata.
Its witness-mode exemption and relocated-target protection/prompt premise await
the decision. Library escapes retain the origin limit without independent home
failure; foreign probes can block before device refusal, retaining worker/credits
through freeze. The full 32-path-occurrence account permits no extra retained
target path. Cached-table correlation/truncation and following-status Library/
length/foreign conflicts prevent a blanket new-call recommendation. The original witness design, its
mandatory review, replay/size phases and classification stay live. No new call,
consent, budget or accepted home/default loss is selected.

Current changes:

- [Establish pre-open proofs before acquiring a child](index.html#diagram-search-preopen) — Reconciles fixed bootstrap, lookup-only alternatives, foreign wait limits and witness accounts.
- [Observe a checked directory without alternate spelling](index.html#diagram-search-canonical) — Retains fixed bootstrap and marks target inspection policy pending.
- [Inspect serially with two temporary descriptors](index.html#diagram-search-inspection) — Shows foreign-probe retention through freeze and later replay repair.
- [Keep partial coverage and blocking in typed search data](index.html#diagram-search-coverage) — Keeps Library escape limits from failing independent home work.
- [Pre-open proof boundary](../../specs/workspace-search.md#pre-open-proof-boundary) — Separates the accepted premise from the remaining target decision and native limits.
- [Boundary choices and construction](../../verification/search-preopen-boundary.md#concrete-metadata-policy-choices) — Evaluates the existing walk first and discloses conditional alternatives and reversal evidence.

The unchanged resource, serviceability and protected-metadata views remain
discussion context. Open the focused discussion at
<http://127.0.0.1:8943/#discussion> with `task design:serve PORT=8943`.
Graph reading begins at the dark, labelled Start here node; narrow whole-graph
fit is an overview, with native-size/export zoom and the reflowable spec for detail.

The pre-open revision was inspected in Firefox 151.0.3 in the isolated Ubuntu
24.04.4 clone `koine-preopen-k189`. Fresh pre-open and discussion deep links
reached their intended titles and Current/Updated markers. The focused view
rendered in light and full-width 1,920-pixel dark appearance; all branches were
also checked in a complete light SVG raster. A D2 reserved node name and two
overlapping branch labels were corrected before the final inspection. The
800-pixel responsive dark discussion reflowed its status, recommendation and
relevant links; narrow graph fit remains an overview. Canonical, inspection and
coverage exports were inspected as complete light rasters. Host/guest SHA-256
values matched item by item for index.html, diagrams.json and the four changed
D2/SVG pairs. This is presentation evidence only: no Koine search, metadata,
prompt, hydration, resource or binary acceptance subject ran.

The preceding discussion covered **long locations in v1**. On 2026-10-07 Antony
deferred making applications accept long locations past v1
([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1)) after the
[separated local naming collection](../../verification/separated-local-url-naming-prototype.md).
The [long-location view](index.html#diagram-workspace-long-locations) now draws
the v1 contract: Koine's own location resolution establishes absence or
presence at any length under the
[descriptor-relative access decision](../../adr/filesystem-access-is-descriptor-relative.md),
target first and then a supplied or discovered application, and an extant
location whose spelling is `PATH_MAX` (1,024) bytes or more, not counting its
NUL, is refused at the application hand-off with `failed`, before any request.
Within the limit the accepted short-path route is unchanged. Its mandatory review's
findings are integrated (the count convention, stage order, registered
candidates, cycle state, link budget, name limits and reveal's root); the design
is unimplemented, and native, binary, public and signed-VM acceptance belong to
planning. The [route evaluation](../../verification/long-action-route.md#v1-decision)
keeps every diagnostic as evidence, so the former route-candidates view, which
drew the workaround search, is retired.

Earlier long-location changes:

- [Resolve the location, then check the application hand-off limit](index.html#diagram-workspace-long-locations) — Redrawn for v1 and its review: target and application stages, resolution outcomes, the hand-off limit refusal, and the unchanged short-path route within the limit.
- [Launch or open, then capture desktop state](index.html#diagram-workspace-open) — The inspection note and uncertain-inspection branch now state v1 resolution and the hand-off limit refusal.
- [Keep dependency absence before the submission boundary](index.html#diagram-workspace-outcomes) — The inspection node now says absence comes only from Koine's own resolution and names the v1 refusal.
- [Choose a location, then revalidate through existing actions](index.html#diagram-search-handoff) — The long-location note now states the v1 refusal instead of an unresolved route.
- [Long-location action boundary](../../specs/workspace-launch-and-open.md#long-location-action-boundary) — Replaced the investigation narrative with resolution, hand-off limit, walk obligations, non-actions and subjects.
- [Descriptor-relative access decision](../../adr/filesystem-access-is-descriptor-relative.md) — New record of why Koine resolves locations itself, with search-only handles and the prompt revisit condition.
- [Search action dependency](../../specs/workspace-search.md#long-location-action-dependency) — States what search results receive from v1 actions; search drops nothing.
- [Client selection guidance](../../client-guide.md#searching-for-applications-and-files) — Tells clients to keep long results visible and copyable and to report the refusal.
- [Route evaluation v1 decision](../../verification/long-action-route.md#v1-decision) — Closes the investigation and maps each diagnostic to where it lands.
- [Glossary](../../../CONTEXT.md#language) — Adds location resolution and the application hand-off limit.


The unchanged [canonical path view](index.html#diagram-search-canonical) and
[protected metadata view](index.html#diagram-workspace-inspection) remain relevant
context; they do not establish long-location action acceptance.

The specified [serviceability controls](index.html#diagram-search-serviceability)
remain unchanged context. Q/S, two temporary credits, worker-only cleanup,
freeze/cohort recovery, public ceilings, domain and three-second wait remain
binding. Cached directory spellings can differ without movement: independent
reacquisition/association checks detect observed change, while first unassociated
observations have no independent detector. All file entry kinds use listed
locations; descendants use fresh native reports. Queued native-size refusal
preserves finalized names with VALUE_LIMIT SUBTREE; public overflow omits names
with actual-parent CHILD_GROUP. Native classification reachability remains open,
independently of synthetic 43/44 and conditional listed-task 79/80 arithmetic.
No missing witness/replay phase is supplied by these exports. No call set,
account, domain, consent or accepted workflow coverage changes here.

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

The [evidence report](../../verification/search-discovery.md) and its existing
view remain unchanged mechanism context. The new stream adapter is a design,
not native acceptance or an exhaustive filesystem/index-availability proof.

Serve locally with `task design:serve` and open
<http://127.0.0.1:8765/#diagram-workflow-providers>. The task serves only this
presentation directory. Graphs start at the node labelled “Start here”; sequences
start at their first message.
Use `task design:serve PORT=8767` if the default port is already occupied.

The serviceability revision was inspected in Safari in the isolated macOS
26.5/25F71 clone `koine-k113-design`. Fresh serviceability and resource deep links
reached the intended rendered views; their starts, labels and updated markers
were readable at 1900 pixels. The 800-pixel discussion panel reflowed its status,
relevant links and changed-view summaries in light and dark appearance; the
resource SVG remained readable in wide dark appearance. The manifest and five
changed SVGs had equal per-file SHA-256 values in host and guest. Full-view
librsvg rasters were inspected for serviceability/resource branches and the
changed traversal/coverage/handoff labels. This is presentation evidence only;
no Koine search, resource exhaustion, native-call or binary-compatibility case
ran. The clone was stopped after inspection.

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

Run `task design:workspace-render` to regenerate the workspace sequence,
outcome flow and long-location boundary with the same pinned renderer versions
(ELK for the long-location view, Dagre for the outcome flow). Start with
<http://127.0.0.1:8765/#diagram-workspace-open>.

Run `task design:search-render` for the nine search views with D2 0.9.0,
ELK for the canonical/preopen/resource/inspection/serviceability views and Dagre for the remaining views, light theme 0
and dark theme 200. Open
<http://127.0.0.1:8765/#diagram-search-coverage>.
Run `task design:search-check` for independent/composed SDL and example validation,
with failing schema controls; this does not prove runtime branch invariants.
The final native allocation and two-temporary ownership views were checked in
Safari in the isolated `koine-k119-design` macOS clone. Fresh resource and
inspection links reached their intended titles and Current/Updated markers;
the 1920-pixel light view and complete SVG rasters showed readable branches.
Overlapping paired edge labels were shortened and rerendered before checking
the final exports. The discussion panel reflowed at 640 pixels in dark
appearance. Diagram reading at that width still uses the native-size/export
trade-off above. This is presentation verification, not Koine native search,
consent, binary or serviceability acceptance. Serve the current view with
`task design:serve PORT=8779` and open
<http://127.0.0.1:8779/index.html#diagram-search-resources>.

The earlier in-process observation proposal was checked in Safari in the isolated
`koine-k117-design` macOS clone. Viewer, manifest, source and resource export
were byte-identical to the host files. A fresh resource deep link reached the
intended title and Current/Updated markers; the start node and both decision
branches were readable in the 1920-pixel light view. The lower decision branches
were also checked in dark appearance. A fresh discussion deep link showed the
two unapproved decisions and one changed-view summary; its text reflowed at a
640-pixel window. Narrow diagram reading remains the native-size/export trade-off
above, not a claim of readable whole-graph text at phone width. The clone was
stopped after presentation checking. No Koine native search, permission, binary
or serviceability subject ran. The host presentation is served at
<http://127.0.0.1:8875/#diagram-search-resources>.

Earlier presentation records below refer to their earlier revisions.
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


The resolution revision was inspected in Safari in the isolated macOS
26.5/25F71 clone `koine-path-resolution-k122`. Fresh canonical, traversal,
coverage, handoff, allocation and inspection deep links reached their rendered
views with visible starts/current/updated markers. The 1,900-pixel light views
and canonical dark view were readable; the 800-pixel dark discussion panel
reflowed its status, relevant links and change summaries. Narrow graph fit is
an overview; use the native-size/export reading options as above. The manifest
and six changed D2/SVG pairs matched host/guest SHA-256 item-by-item, including
the final canonical edge order. This is presentation evidence only; no Koine
search, classification, prompt-safety, resource or binary case ran.
