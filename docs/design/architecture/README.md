# Koine architecture views

Open [the viewer](index.html#discussion) for the current discussion, outline and
SVG/source exports. The agreed future desktop contract now combines non-time
callback capture/expiry with public macOS Accessibility. The complete protocol
and implementation remain open; served-contract diagrams still describe the
existing timestamp API. The [spec](../../specs/machine.md#native-targeting-discussion)
and [ADR](../../adr/desktop-automation-uses-public-accessibility.md) are authoritative.

The scope change accepts wrong-target data/effects during reuse, stale reports,
mistaken reference withdrawal and framework AX reception without Koine's hard
acquisition bound, including resource pressure or failure. Capture-transfer has
separate acquisition obligations. Grants, Koine-owned consent, known-dead capture
refusal, permanent local withdrawal/non-reuse and bounded own state/work remain.

## Current discussion

The [native recorder contract](../../verification/callback-native-capture/contract.md)
is not ready for native use. k137 adds v5 independent sample scope/diagnostics
with terminal outcomes and all native credit withheld. k136 adds v4 controller-prefix, FIFO and active-reply
producer checks. k137 retains independent sampled evidence; k138 completes the
producer lifecycle, all waits and fresh tree review before k126. Their parent
`callback-recorder-state-machine-k135` retains every original criterion. V4 is a
diagnostic slice using inherited sampler histories, not honest full producer
executions. Frozen earlier traces and outcomes keep their meanings.
Complete trusted audit, established loop coverage and confirmed containment
are all prerequisites for native credit. Row caps and the outer deadline are
safety limits; they do not guarantee an honest run will complete.

Changed in this discussion:

- [Recorder protocol](index.html#diagram-process-recorder-protocol) — Adds prefix/FIFO/active-producer checks and names the remaining sample and lifecycle work.
- [Controller contract](../../verification/callback-causal-fixture/contract.md#version-4-controller-prefix-slice) — Defines v4's executed-prefix rules, malformed outcomes and explicit partial scope.

The unchanged return and containment diagrams remain relevant context; their
captions now distinguish v4's controller checks from k137/k138's remaining work.

All original k124/k121 criteria remain live with k126. Coverage precedes full
recorder/matrix construction; one attempt per frozen cell, preparation, PID
provenance, actual exits and host recovery remain required. k122 retains gates,
k115 freshness, k112 lifetime/policy and k108/k109 transfer.

Unchanged context: [external exit observer](index.html#diagram-process-exits),
[post-return retention](index.html#diagram-process-retention),
[ordinary input route](index.html#diagram-process-input-route),
[sampling witnesses](index.html#diagram-process-sampling),
[capture and transfer](index.html#diagram-process-capture),
[resident composition](index.html#diagram-packages),
[targeting boundary](index.html#diagram-process-target-contract),
[scope and remaining work](index.html#diagram-process-adoption) and
[private admission conflict](index.html#diagram-process-receive-admission).

The observation, wire, acquisition-budget and direct-endpoint views preserve
historical investigations. Their findings do not establish a complete native
observation exchange, and their unproved private guarantees are no longer release
gates. The [adoption synthesis](../../verification/ax-endpoint-adoption.md) and
[receive report](../../verification/native-observation-receive.md) retain the
measurements, limits and original criteria. The restoration view still informs
the unresolved AX-contact lifecycle decision; the serial view still explains
why PSN plus boot identity cannot provide strict process lifetime.

Other views cover the resident application, source packages, served desktop
interaction, grants and provider ABI. Graphs begin at their marked start node;
sequences read top to bottom. Captions state evidence limits. No diagram is
formal verification or release acceptance.

## Sources and exports

`diagrams.json` owns introductions, captions, outline groups and discussion/update
markers. Each source has a version-controlled SVG. Regenerate exports from the
source, then inspect them; do not hand-edit SVG. The viewer fetches source and
exports on reload and does not compile them.

From the repository root:

```sh
task design:render-process-identity
task design:render-callback-sampling
task design:render-callback-recorder
task design:render-receive-admission
task design:render-receive-budget
```

These headless PlantUML tasks render SVG beside each source and PNG under
`.build/design-identity`; they do not run native diagnostics. The installed
renderer is PlantUML 1.2026.8. The other sources use D2 0.9.0 and Graphviz 16.1.0;
retain their existing renderer settings when changing them.

## Verification scope

For the historical k129 render, `task design:render-callback-recorder` rendered the protocol, return
and containment views in disposable clone `koine-k129-view`, using PlantUML
1.2026.8. Source/task and named renderer inputs matched before/after; local,
host-served, guest and guest-served source/export/viewer bytes matched. Fresh
Safari deep links and the discussion panel were inspected at a wide light
desktop, including captions, outline and Current/Updated markers. The
[presentation record](../../verification/callback-native-capture/evidence/k129/presentation.json)
links the render results, input maps and screenshots. The renderer reported no
Graphviz executable; all three sequence diagrams rendered successfully. The
named-tool hashes do not freeze every runtime dependency. Mobile and dark
appearance were not checked. No native recorder or permission-setup diagnostic
ran. The clone was stopped and backend removal confirmed. Earlier records below
apply to their own revisions.

For k128, the root render task ran in disposable clone `koine-k128-view` using
PlantUML 1.2026.8. The updated return/containment views and fresh discussion link
were inspected in guest Safari with their captions, outline and Current/Updated
markers. The [presentation evidence](../../verification/callback-native-capture/evidence/k128/)
retains source/task before/after maps, render exit/log and screenshots. This is
light desktop presentation evidence, not native recorder or permission-setup
validation; mobile and dark appearance were not checked. The k125 records below
apply to their earlier bytes. The k128 clone was stopped and backend removal
confirmed.

For the k125 native-recorder proposal, both new PlantUML sequences rendered and their
PNG exports were inspected. Fresh return, containment and discussion deep links
were checked in Safari in disposable clone `koine-k125-view`, including readable
wide-desktop diagrams, topic outline and matching Current/Updated markers. The
[presentation record](../../verification/callback-native-capture/evidence/presentation.json)
retains matched local/served/guest hashes and unchanged inspection inputs; the
[render record](../../verification/callback-native-capture/evidence/render.json)
covers all six source diagrams read by the task. The clone was stopped and its
removal confirmed through the backend. Mobile and dark appearance were not
checked. No native capture or exit diagnostic ran for this presentation.

Earlier native reports and their reproduction sections carry the frozen platform,
input, output and rendering records for those revisions. Earlier Safari checks
apply to their recorded bytes, not automatically to later updates.

For the external-exit update, `task design:render-callback-sampling` rendered
the new sequence. Its PNG and fresh exit/discussion deep links were inspected
in Safari in disposable clone `koine-k123-exits`, including the topic outline
and Current/Updated markers. The
[presentation record](../../verification/callback-exit-observer/evidence/presentation.json)
retains input digests and served-byte checks. This covers light desktop delivery;
mobile and dark appearance were not checked. The separate native exit diagnostic
ran in this clone; no callback capture ran.

For the retained-switch update, `task design:render-callback-sampling` rendered
the new PlantUML sequence. The PNG and fresh retention/discussion deep links
were inspected in Safari in disposable clone `koine-k120-view`, including
the topic outline and Current/Updated markers. The
[presentation record](../../verification/callback-causal-fixture/evidence/retained-switch/presentation.json)
retains input digests and served-byte checks. This is a light desktop delivery
check; mobile and dark appearance were not checked. No capture fixture ran in
this presentation clone.

For the native input-route update, `task design:render-callback-sampling`
rendered both affected sources. The named source/manifest/viewer/Taskfile digests
matched before/after; SVG XML, discussion references and served bytes checked.
The PNGs and Safari's fresh route, sampling and discussion deep links were
inspected in disposable clone `koine-k118-route`. The light desktop view shows
readable diagrams, the topic outline and matching Current/Updated markers.
Mobile and dark appearance were not checked. The
[presentation record](../../verification/callback-input-route/evidence/presentation.json)
and screenshots retain this check. It verifies delivery of the discussion;
the separate [native results](../../verification/callback-capture-transfer.md#native-input-route-discriminator)
state the route's evidentiary limits.

For the causal analyzer update, `task design:render-callback-sampling` completed
with source/Taskfile/manifest/viewer inputs unchanged item by item. The PNG was
inspected; SVG XML, discussion references and served source/export bytes checked.
Safari in disposable clone `koine-k116-view` opened fresh diagram and discussion
deep links, showing the revised content, outline and Current/Updated markers.
This verifies presentation only. Mobile and dark appearance were not checked.
The clone was stopped after inspection. The
[presentation record](../../verification/callback-causal-fixture/evidence/presentation.json)
holds the input digests; the capture assessment holds the analyzer's frozen raw
controls and explicitly outstanding native fixture work.

For the guest foreground entry update, `task design:render-callback-sampling`
completed and source/Taskfile/manifest/viewer digests matched before and after.
The PNG was inspected, SVG XML parsed, and served manifest bytes matched disk.
Safari in disposable clone `koine-k111-source` opened the diagram deep link and
the discussion panel in fresh pages; the rendered revision, outline and
Current/Updated labels were visible. No mobile or dark-theme check was performed.
This browser check verifies presentation, not callback sampling. Native scan
provenance and its limits are in the capture assessment.

For the preceding callback witness design, `task design:render-callback-sampling` completed
with matching before/after digests for its source, Taskfile, manifest and viewer.
The PNG was inspected, manifest/source/export links and SVG XML validated, and
served manifest/source/SVG bytes matched the files. The five SDK headers still
match the recorded digest set. Safari in disposable TestAnyware clone
`koine-k110-view` opened the new diagram deep link in a fresh page; its rendered
diagram, topic outline and Current/Updated labels were visible. This verifies
presentation only, not callback sampling. Mobile and dark-theme checks were not
performed. The clone is stopped after inspection.

For the preceding capture-premises assessment, `task design:render-process-identity`
completed successfully. Its process-view sources, Taskfile, viewer and manifest
matched their pre-run digests item by item. The revised capture PNG was inspected
for layout and legibility; manifest references, SVG XML, edited-document local
links and served manifest/SVG bytes were checked. Missing-file and missing-heading
controls were observed failing. The five inspected SDK headers matched the
[recorded digests](../../verification/callback-capture-transfer/sdk.sha256).
No browser was available to the session, so fresh browser deep-link, mobile and
dark-mode checks remain unperformed. This was source and presentation work;
no new native capture/transfer, AX operation, consent or product acceptance run
is claimed.

For the prior k104 scope update, all three rendering tasks above completed successfully with unchanged
source/manifest/Taskfile/renderer-launcher inputs checked item by item. The seven
changed PNG exports were inspected for legibility and layout. Manifest IDs,
source/export paths, discussion/update references and SVG XML parsed successfully;
relative Markdown links and headings were checked with deliberately missing
file/heading controls. No fresh browser, narrow/mobile or dark-mode check was
performed for this update.

The historical k131 recorder views marked v2 activation, activity and
receipt-deviation gaps for k132. The current views mark the further k133/k134
gaps and k135 redesign/review before k126. Private-loop coverage
is a prerequisite before the full recorder/matrix; no mechanism is specified.
One measured attempt per matrix cell is allowed, with every outcome and not-run
cell reported. Targets start before collectors/UI; supervisor frames remain
audit-only. These corrections establish no native result or parent completion.

For k131, `task design:render-callback-recorder` ran only in disposable clone
`koine-k131-view`. The first render failed because the copied Java runtime lacked
a font-library dependency; the retained failed record shows no output. After
copying the exact transitive library dependencies, all three views rendered,
with unchanged before/after inputs and matching host/guest source/output hashes.
The [render record](../../verification/callback-native-capture/evidence/k131/render.json)
includes commands and tool/dependency digests. SVG XML was validated; no browser
or visual reinspection was performed in this integration. The earlier k129
screenshots describe its older view bytes, not this render.

For k132, `task design:render-callback-recorder` rendered all three v3 sequences
only in disposable clone `koine-k132-view`. Named sources, viewer, manifest,
Taskfile and the copied renderer/runtime inputs matched before and after; the
host and guest source/export hashes also matched. Safari's fresh discussion and
diagram deep links showed the current/updated markers and readable full diagrams
at desktop width. The [presentation record](../../verification/callback-native-capture/evidence/k132/presentation.json)
and screenshots retain this check. The [delivery check](../../verification/callback-native-capture/evidence/k132/delivery-check.json)
records the bounded link, served-byte and SVG checks, including rejected missing
file/heading controls. Mobile and dark appearance were not checked.
A VM-only Safari automation prompt was declined; the VM agent resized its window.
The clone was stopped and its backend removal confirmed. These checks establish
presentation only; k133/k134 subsequently required k135 redesign/review before
k126 can consume the protocol.

For k134, the three recorder sources/exports and captions explicitly mark v3's
remaining gaps and k135 redesign/review. The [render record](../../verification/callback-native-capture/evidence/k134/render.json)
binds the unchanged source/Taskfile/manifest/runtime inputs to matching local
and guest SVGs. Rendering ran only in disposable clone `koine-k134-view`.
Safari's discussion and each diagram's initial desktop viewport were checked;
full-size/full-scroll, mobile and dark appearance were not rechecked. Screenshots
are under the same evidence directory. The clone was stopped and its removal
confirmed. No native recorder, permission setup or capture ran.

For k136, the protocol view adds v4 controller-prefix/FIFO/active-producer checks
and marks k137/k138's remaining work. Return and containment source/export bytes
are unchanged; their captions now state the partial v4 scope. The
[render record](../../verification/callback-native-capture/evidence/k136/render.json)
binds unchanged named inputs to matching guest/local SVGs. Rendering ran only in
disposable clone `koine-k136-view`. Safari's fresh discussion and protocol links
were inspected at desktop width, including the protocol's top, body and bottom.
The [presentation record](../../verification/callback-native-capture/evidence/k136/presentation.json)
links screenshots and VM teardown. A second clone, `koine-k136-responsive`,
checked dark appearance and narrow-window wrapping using the same archived
assets. Dark contrast and discussion wrapping are readable; sequence labels are
small in the narrow fit view, so wide desktop remains the verified reading
surface. Mobile-device usability and the unchanged return/containment views
were not checked. Both clones were stopped and removed. This is presentation
evidence for a partial diagnostic, not native recorder acceptance.

For k137, all three recorder views and captions describe v5's independent
sample scope and preserved contradictions beside terminal aborts. The protocol
names the sample premises; return distinguishes callback sampling from retention;
containment explicitly withholds native credit. The
[render record](../../verification/callback-native-capture/evidence/k137/render.json)
binds unchanged named inputs to matching guest/local SVGs in disposable clone
`koine-k137-view`. The
[presentation record](../../verification/callback-native-capture/evidence/k137/presentation.json)
retains fresh discussion and diagram deep-link checks, wide protocol/containment
sections and the return entry/caption. Narrow dark discussion wrapping is
readable, but sequence labels in the narrow fit view are small. Mobile devices,
every scroll position and dark return/containment views were not checked. The
clone was stopped and removed. Complete native producers and fresh review remain
with k138; this update establishes no native recorder acceptance.
