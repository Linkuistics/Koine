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
now specifies complete version-2 traces: unfiltered target key-downs include the
trigger, whose delivered marker selects the callback; readiness, settle and finish
exchanges order both targets' activity. Eight synthetic matrix cells are accepted.
Fresh tree review still precedes k126. Both-schedule loop coverage, combined
outcomes, per-clone permission setup, candidate PID provenance and host recovery
remain native obligations. k124/k121 stay live, k122 retains gates and k115 freshness.

Changed in this discussion:

- [Complete recorder protocol and finite observation](index.html#diagram-process-recorder-protocol) — Adds readiness, settle, arm, trigger, retention and finish exchanges, with every acknowledgment before exit.
- [Callback return at the enclosing native call](index.html#diagram-process-recorder-return) — Ties selection to the delivered trigger and retains both-schedule coverage requirements.
- [Actual app exits and whole-clone containment](index.html#diagram-process-recorder-containment) — Places closed observation and all finish acknowledgments before app exit.
- [Integrated native recorder proposal](../../verification/callback-capture-transfer.md#integrated-native-recorder-proposal) — Records the version-2 synthetic evidence separately from open native obligations.

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

The current recorder views carry k131's integration: v2 activation, activity and
receipt-deviation gaps remain for k132 and its fresh review. Private-loop coverage
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
