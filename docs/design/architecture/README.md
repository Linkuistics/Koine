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

The [guest entry inspection](../../verification/callback-capture-transfer.md#guest-foreground-entry-inspection)
identifies AppKit's KVO helper/property preservation and Process Manager's
LaunchServices shared-memory/reply paths on macOS 26.5. Local field loads do not
date the data producer or establish coherent foreground/PID mapping. The
[witness protocol](../../verification/callback-capture-transfer.md#callback-witness-protocol)
still needs its causal fixture and native callback schedules; neither public
source nor a capture construction is adopted. Transfer admission and resident
protocol work remain separate.

Changed in this discussion:

- [Independent witnesses for fresh callback sampling](index.html#diagram-process-sampling) — Adds inspected paths and marks producer freshness and coherent mapping unresolved.
- [Guest entry inspection](../../verification/callback-capture-transfer.md#guest-foreground-entry-inspection) — Records exact code ranges, image identities, raw scans and remaining boundaries.
- [Client capture migration](../../client-guide.md#process-identity) — Explains why the inspected paths do not yet justify choosing a replacement source.

Unchanged context: [capture and transfer](index.html#diagram-process-capture),
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
task design:render-receive-admission
task design:render-receive-budget
```

These headless PlantUML tasks render SVG beside each source and PNG under
`.build/design-identity`; they do not run native diagnostics. The installed
renderer is PlantUML 1.2026.8. The other sources use D2 0.9.0 and Graphviz 16.1.0;
retain their existing renderer settings when changing them.

## Verification scope

Earlier native reports and their reproduction sections carry the frozen platform,
input, output and rendering records for those revisions. Earlier Safari checks
apply to their recorded bytes, not automatically to later updates.

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
