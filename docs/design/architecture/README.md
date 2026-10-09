# Koine architecture views

Open [the viewer](index.html#discussion) for the topic outline, current discussion,
editable sources and SVG exports. Graphs begin at a dark node labelled Start here;
sequences read from their first message. Native images/source packages are
components within one resident process, not deployment containers. Source is
editable; regenerate exports rather than hand-editing them.

## Current discovery discussion

[Composition → Own sources and freeze publication](index.html#diagram-native-discovery-contract)
shows source/snapshot/image responsibility and the preserved action boundary.
[System Settings → Read, prepare, set up, then reveal](index.html#diagram-native-settings-flow)
shows separate explicit operations and complete static grants.
[Native ownership → Retain capacity until native work really returns](index.html#diagram-native-discovery-lifecycle)
shows freeze and true retirement, including indefinite retained capacity.
The [native contract](../../specs/workspace-search.md),
[source provenance](../../verification/native-discovery-sources.md) and
[finite acceptance](../../verification/native-discovery-acceptance.md) hold the
full API, exact profiles and runtime qualification duties. Mandatory whole-producer
review, implementation and every native G/N/V verdict remain pending.

Changed in this discussion:

- [Composition → Own sources and freeze publication](index.html#diagram-native-discovery-contract) — Added native-image/source ownership and source plus compiled action-boundary controls.
- [System Settings → Read, prepare, set up, then reveal](index.html#diagram-native-settings-flow) — Added separate effect-free read, background prepare, conditional explicit setup and selected reveal paths with complete authority.
- [Native ownership → Retain capacity until native work really returns](index.html#diagram-native-discovery-lifecycle) — Added bounded admission, publication freeze and capacity retained through actual return.
- [Native sources → What each source can establish](index.html#diagram-native-discovery-sources) — Changed candidates to selected interfaces while retaining pending exact runtime qualification.
- [Client-owned search and native discovery](index.html#diagram-search-discovery) — Connected the ownership boundary to the designed contract and pending review/acceptance.
- [Native discovery contract](../../specs/workspace-search.md) — Replaced the raw proposal with native source/status/metadata/authority/ownership contracts.
- [Finite native acceptance](../../verification/native-discovery-acceptance.md) — Defined new provider/profile identities and actual G/N/V witnesses without relabelling old captures.

The [agreed settings source](index.html#diagram-native-settings-decision) is
unchanged requirements context. The other eight search views and
[archived raw proposal](../../verification/raw-workspace-search-comparison.md)
remain labelled comparison; no current native backend/account is selected by them.

## Other architecture topics

The viewer retains [workspace actions](index.html#diagram-workspace-open),
[native outcomes](index.html#diagram-workspace-outcomes),
[long-location action boundary](index.html#diagram-workspace-long-locations),
[metadata/handler boundary](index.html#diagram-workspace-inspection),
[provider selection](index.html#diagram-provider-selection) and
[workflow authority](index.html#diagram-workflow-authority). Their specs/verification
records establish their served/accepted/pending subjects; this presentation adds
no native verdict.

## Sources and exports

D2 0.9.0 uses theme 0/dark-theme 200. Run design:native-discovery-render for
source/contract/lifecycle views with Dagre and the settings flow with ELK;
design:search-render regenerates the ownership sketch plus eight comparison views
with their recorded layouts. The other existing tasks are design:workspace-render,
design:selection-render and design:workflow-render (PlantUML 1.2026.8 where used).

Run design:search-compose before freezing inputs, then design:search-check for
native SDL/examples/complete profiles and retained action examples. check:docs
validates relative links/anchors. These are design checks, not native acceptance.
Run design:serve PORT=8923 and open <http://127.0.0.1:8923/#discussion> or an exact
stable diagram anchor. The static presentation serves only this directory.
