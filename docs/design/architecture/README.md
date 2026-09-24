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
remains unready for native use. V24 completes the k168 independent-cancellation
union with V21–V23. Ordinary continuation finishes before actual abort receipt;
at the after-callback wait, FIFO determines whether retention was committed.
K169 retains non-stopped results, blocked/transport and complete sampler
reconciliation. K143 owns targets; k144 complete waits, partial evidence and
mandatory fresh review.

Changed in this discussion:

- [Cancellation at the continuation boundary](index.html#diagram-process-recorder-continuation-cancel) — Adds ordinary continuation and both FIFO retention/cancellation outcomes, preserving late drains and independent evidence.
- [Continuation cancellation contract](../../verification/callback-causal-fixture/contract.md#version-24-continuation-and-retention-cancellation) — Specifies issued-work obligations, pending waits, first causes and truthful cleanup across post-return cancellation.

The earlier recorder diagrams are unchanged context.

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
markers. PlantUML/D2 sources have version-controlled SVG exports. Regenerate and inspect
them; do not hand-edit SVG. Mermaid sources render in the viewer with its pinned
Mermaid 12.0.0 module from jsDelivr, requiring network access. Their editable
source is the artifact; browser rendering and inspection run only in a disposable
clone. The viewer fetches sources and exports on reload.

From the repository root:

```sh
task design:render-process-identity
task design:render-callback-sampling
task design:render-callback-recorder
task design:render-callback-history
task design:render-callback-markers
task design:render-callback-loop
task design:render-callback-source
task design:render-callback-startup
task design:render-callback-cancel
task design:render-callback-ready
task design:render-receive-admission
task design:render-receive-budget
```

These headless PlantUML tasks render SVG beside each source and PNG under
`.build/design-identity`; they do not run native diagnostics. The installed
renderer is PlantUML 1.2026.8. The other sources use D2 0.9.0 and Graphviz 16.1.0;
retain their existing renderer settings when changing them.

## Verification scope

For k172, Safari in disposable clone `koine-k172-design` displayed the fresh
continuation-cancellation deep link, the full wide light sequence and caption,
current discussion, and narrow dark diagram/discussion. The
[render record](../../verification/callback-native-capture/evidence/k172/render.json)
binds viewer, manifest and new source across local, guest and both served copies;
the [presentation record](../../verification/callback-native-capture/evidence/k172/presentation.json)
records final inspection and clone teardown. Earlier context assets initially
returned 404 because the transfer was incomplete; the complete directory was
then transferred and the final views checked. Fine labels require wide desktop;
narrow desktop is not mobile-device testing. This is presentation evidence only.

For k165, Safari in disposable clone `koine-k165-design` rendered and displayed
the continuation deep link, wide sequence from adoption through termination,
narrow dark layout, current discussion and revised refusal caption. The
[render record](../../verification/callback-native-capture/evidence/k165/render.json)
binds four presentation inputs across local, guest and served bytes; the
[presentation record](../../verification/callback-native-capture/evidence/k165/presentation.json)
records inspection and teardown. Wide desktop is the readable sequence surface.
This is presentation evidence only.

For k145, [sampler callout, invocation and cancellation](index.html#diagram-process-recorder-loop)
was rendered with the root loop task only in disposable clone `koine-k145-view`.
The [render record](../../verification/callback-native-capture/evidence/k145/render.json)
checks unchanged named inputs and matching served bytes. The
[presentation record](../../verification/callback-native-capture/evidence/k145/presentation.json)
covers fresh Safari discussion/deep links and wide diagram readability.
At 650-pixel width, prose wraps but diagram labels are small. Light appearance
was established; dark/mobile and earlier diagrams were not verified. The clone
was stopped and removed. This is loop-design evidence, not native capture or
permission-setup validation. Earlier records describe their own revisions.

For k141, [native markers and ordinal deliveries](index.html#diagram-process-recorder-markers)
was rendered with the root marker task only in disposable clone `koine-k141-view`.
The [render record](../../verification/callback-native-capture/evidence/k141/render.json)
checks unchanged named inputs and matching served bytes. The
[presentation record](../../verification/callback-native-capture/evidence/k141/presentation.json)
covers fresh Safari discussion/deep links and wide diagram/caption readability.
At 650-pixel width, prose wraps but diagram labels are small. Light appearance
was established; dark/mobile and earlier diagrams were not verified. The clone
was stopped and removed. This is representation-design evidence, not native
capture or permission-setup validation.

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

For k139, the new [partial-history view](index.html#diagram-process-recorder-history)
shows the intact-prefix boundary and separate structural/malformation results.
The [current discussion](index.html#discussion) identifies k140's remaining
producer and review work. Only the new history view is marked updated; the
earlier three recorder sources and exports are unchanged. The
[render record](../../verification/callback-native-capture/evidence/k139/render.json)
binds unchanged named inputs to matching guest/local SVGs in disposable clone
`koine-k139-view`, with matching host-served assets. The
[presentation record](../../verification/callback-native-capture/evidence/k139/presentation.json)
retains wide discussion/history checks and narrow dark discussion/history
screenshots. Discussion and caption wrap at 650-pixel window width; sequence
labels remain small in the narrow fit view. Wide desktop is the verified reading
surface. Mobile devices, every scroll position and the earlier three views were
not rechecked. The clone was stopped and removed. Native credit is withheld.

For k149, [Source calls and returned-object lifetime](index.html#diagram-process-recorder-source)
adds API-specific returns, mapping on the returned coordinate and explicit object
release. The [current discussion](index.html#discussion) names v10 and k150's
remaining composition; only the source view is marked updated. The [render record](../../verification/callback-native-capture/evidence/k149/render.json)
binds unchanged named project/runtime inputs to matching guest/local SVG and
host-served bytes. Rendering ran only in disposable clone `koine-k149-view`.
The [presentation record](../../verification/callback-native-capture/evidence/k149/presentation.json)
retains fresh discussion/diagram links, wide top and bottom sections, and narrow
light/dark views. Narrow prose wraps and diagram labels shrink in fit view;
desktop remains the verified reading surface. Mobile devices and earlier
diagrams were not rechecked. The clone was stopped and removed. K150 and k144
retain composition and fresh review before native use.

For k151, [Before-ready sampler failure and cleanup](index.html#diagram-process-recorder-startup)
shows v11's raw failure notice, synchronous release attempts and distinct clean
or unresolved cancellation response. The [current discussion](index.html#discussion)
names k152's remaining sampler composition; only the startup view is marked
updated. The [render record](../../verification/callback-native-capture/evidence/k151/render.json)
binds six named rendering inputs to unchanged hashes, and compares the guest
project and exported SVG with host and served assets after rendering. It does
not freeze every guest dependency. Rendering ran only in disposable clone
`koine-k151-view`. The [presentation record](../../verification/callback-native-capture/evidence/k151/presentation.json)
retains fresh discussion/startup links, wide sections and narrow light/dark
views. Narrow prose wraps and contrast is readable; sequence labels shrink in
fit view, so desktop remains the verified reading surface. Mobile devices,
every scroll position and earlier diagrams were not rechecked. The clone was
stopped and removed. No native recorder ran; k152 and k144 retain composition
and fresh review before native use.


For k153, [Cancellation before sampler readiness](index.html#diagram-process-recorder-cancel)
adds safe startup polls, completion of started preparation units and truthful
per-reference cleanup replies. The [current discussion](index.html#discussion)
names v12 and k154's remaining composition; only cancellation is marked updated.
The [render record](../../verification/callback-native-capture/evidence/k153/render.json)
binds unchanged named inputs to matching guest/local/host-served assets.
Rendering ran only in disposable clone `koine-k153-view`. The
[presentation record](../../verification/callback-native-capture/evidence/k153/presentation.json)
records fresh discussion/diagram links, readable wide sections and narrow
light/dark wrapping. Narrow fit labels are small; desktop remains the verified
reading surface. Earlier diagrams, every scroll position and mobile devices
were not rechecked. No native recorder or product permission setup ran.


For k155, [Readiness publication racing cancellation](index.html#diagram-process-recorder-ready)
adds separate publication/receipt boundaries, immediate ready-timeout abort,
late readiness draining and truthful cleanup. The [current discussion](index.html#discussion)
names v13 and k156's remaining active sampler; only the new readiness view is
marked updated. The [render record](../../verification/callback-native-capture/evidence/k155/render.json)
binds unchanged named inputs to matching guest/local/host-served assets.
Rendering ran only in disposable clone `koine-k155-view`. The
[presentation record](../../verification/callback-native-capture/evidence/k155/presentation.json)
retains fresh discussion/diagram links, readable wide sections and narrow
light/dark wrapping. Narrow fit labels are small; desktop remains the verified
reading surface. Earlier diagrams, mobile devices and every scroll position
were not rechecked. No native recorder or product permission setup ran.

For k157, [Armed cancellation and actual loop unwind](index.html#diagram-process-recorder-armed)
adds unconsumed armed, explicit reply FIFO, actual stopped return and truthful
cleanup. The [current discussion](index.html#discussion) names v14 and k158/k159's
remaining sampler work; only the armed view is marked updated. The existing
viewer renders its Mermaid source with the pinned 12.0.0 import. The
[render record](../../verification/callback-native-capture/evidence/k157/render.json)
matches final source/viewer/manifest bytes across the worktree and guest/host
serving; it does not freeze all CDN, browser or OS dependencies. The
[presentation record](../../verification/callback-native-capture/evidence/k157/presentation.json)
retains wide light/dark sections, narrow prose and the initial corrected parse
failure. All browser rendering ran in disposable clone `koine-k157-view`.
Narrow fit labels are small; wide desktop remains the verified reading surface.
No native recorder or product permission setup ran.

For k164, [Candidate refusal and per-reference cleanup](index.html#diagram-process-recorder-candidate-refusal)
adds healthy mapping/cardinality joins, actual unwind and clean versus unresolved
cleanup. The [current discussion](index.html#discussion) names v17 and the
k165/k166/k159 residue; only candidate refusal is marked updated. The
[render record](../../verification/callback-native-capture/evidence/k164/render.json)
matches the viewer, manifest and editable Mermaid source across local, guest and
served bytes. The [presentation record](../../verification/callback-native-capture/evidence/k164/presentation.json)
retains fresh deep links, wide light sections, current discussion and narrow dark
diagram/caption checks. Rendering ran only in disposable macOS clones; the final
clone's stop is recorded and both were absent from the final inventory. Narrow
prose wraps; labels shrink in fit view, so wide desktop remains the reading
surface. Mobile devices, wide dark, every scroll position and earlier diagrams
were not rechecked. Browser/CDN/OS are not a frozen renderer toolchain. No native
recorder or product permission setup ran.


For k167, [Preselection failure and actual invocation return](index.html#diagram-process-recorder-preselection)
adds v20 timeout/unexpected-return and observed-guard failure before selection,
truthful cleanup and optional in-flight input. The
[reached-fault caption](index.html#diagram-process-recorder-reached-fault) names
this successor and k168/k169's remaining composition. The
[current discussion](index.html#discussion) shows both changed views and their
exact limits. The [render record](../../verification/callback-native-capture/evidence/k167/render.json)
binds four viewer/manifest/source files across local, guest and HTTP bytes.
The [presentation record](../../verification/callback-native-capture/evidence/k167/presentation.json)
records wide light sequence sections, narrow dark prose/captions and correction
of an initial Mermaid parse error. Rendering ran in disposable macOS clone
`koine-k167-design`, stopped and absent from the final inventory. Narrow fit
labels are small; wide desktop remains the reading surface. Wide dark, mobile
devices, earlier diagrams and every scroll position were not rechecked.
Browser/CDN/OS are not frozen. No native recorder or host GUI ran.

For k170, [Startup failure racing independent cancellation](index.html#diagram-process-recorder-startup-race)
adds v21's distinct controller first observation and sampler first cause, queued
abort versus actual receipt, mandatory publication and truthful cleanup.
[Current discussion](index.html#discussion) names the remaining k171/k172/k169
owners; only the new sequence is marked changed. Sequences read from their first
message. Editable Mermaid uses the existing viewer's pinned Mermaid 12.0.0 import.

For k174, [Selected work before cancellation receipt](index.html#diagram-process-recorder-selected-cancel)
adds V23's preserved selected groups, actual unwind, ordinary and after-callback
receipt boundaries, reached publications and truthful cleanup. The
[render record](../../verification/callback-native-capture/evidence/k174/render.json)
binds viewer/manifest/source across local and both HTTP/guest copies; the
[presentation record](../../verification/callback-native-capture/evidence/k174/presentation.json)
records final wide light/narrow dark checks, the corrected label parse error and
teardown of both disposable clones. The active V22/V23 union closes k171 only;
k172 continuation/retention and k169 whole-sampler work remain. No native evidence.
