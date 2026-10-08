# Koine architecture views

Open [the viewer](index.html#discussion) for the topic outline, current discussion,
editable sources and SVG exports. Graph views begin at their dark entry node;
sequences read from their first message. Source is the editable artifact; never
hand-edit exports.

## Current discovery discussion

[Client-owned search and native discovery](index.html#diagram-search-discovery)
shows the agreed v1 requirements boundary for macOS 26+. Koine returns special
locations and named application/modern System Settings catalogues. Clients own
raw filesystem search, their permissions, filtering and ranking. Returning a
location grants no filesystem access.

The [requirements](../../requirements/modaliser-workflows.md) and
[ownership decision](../../adr/raw-filesystem-search-belongs-to-clients.md)
govern this boundary. The returned design and mandatory review must establish
native sources, API, availability/completeness and acceptance before
implementation. Public GraphQL, actual provider/host binaries and signed VMs
remain the agreed seams; this presentation runs no native experiment.

The other eight search views retain the previous raw-search proposal for
comparison. Their dark entry nodes, titles and captions identify that status.
They select no current API, child or traversal mechanism. The returned design
must reconcile useful native metadata, per-copy application identity, explicit
actions, binary compatibility and independent serviceability/dialog/hydration
controls; obsolete raw traversal and coverage payloads are not new requirements.

## Other architecture topics

The viewer retains [workspace actions](index.html#diagram-workspace-open),
[native outcomes](index.html#diagram-workspace-outcomes),
[long-location action boundary](index.html#diagram-workspace-long-locations),
[metadata/handler boundary](index.html#diagram-workspace-inspection),
[provider selection](index.html#diagram-provider-selection) and
[workflow authority](index.html#diagram-workflow-authority). Their specs and
verification documents establish what is served, accepted or pending; the
presentation adds no runtime verdict.

## Sources and exports

The manifest owns titles, outline, current discussion and captions. D2 sources
use D2 0.9.0, theme 0/dark-theme 200; PlantUML sources use 1.2026.8. Run the
existing Taskfile recipes: design:search-render (the ownership sketch and eight
comparison views; ELK for permission/canonical/resource/inspection/serviceability,
Dagre for the rest), design:workspace-render, design:selection-render and
design:workflow-render.

design:search-check validates the previous raw-search SDL/examples. It is not
validation of a new native catalogue API. check:docs validates relative links
and anchors. Run design:serve PORT=8876 and open
<http://127.0.0.1:8876/#discussion> or the exact stable diagram anchor.
