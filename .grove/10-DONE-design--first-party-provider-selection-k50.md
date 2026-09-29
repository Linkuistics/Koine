# first-party-provider-selection-k50

## Goal

Settle how the workflow extension selects a shipped provider and an independently
updated first-party copy before launch-and-open packages the second bundled
provider. Preserve one loader, explicit approval, independent compatible updates
and the existing signing posture.

## Context

- `provider-architecture-k48`'s D7 in review commit `e968bdd97123`; the integration
  `provider-architecture-k49` repairs canonical order and failure-cascade prose
  but deliberately leaves replacement selection to this bounded design.
- `docs/specs/machine.md`, composition and loading/trust; and
  `docs/specs/workflow-providers.md`, the six shipped identities and compatibility.
- ADRs `koine-server-and-native-providers`, `resilient-provider-framework` and
  `provider-authority-follows-effects`.
- The baseline composes bundled providers first, then per-user providers, each
  group by identifier. It refuses external desktop replacement, and other
  duplicate identifiers/prefixes contest both claims. These rules do not deliver
  independent updates for an identity present in both roots.

## Done when

The spec and minimal ADR set define one deterministic policy for:

- reserved shipped identifiers and prefixes, including a shipped provider that
  is absent or rejected, without letting an external claimant evict it;
- precedence between bundled and explicitly approved same-team per-user copies,
  version/compatibility eligibility, multiple installed candidates, and invalid,
  older or rejected updates;
- which checks and selection occur before `dlopen`, and what may remain mapped
  if descriptor/schema rejection occurs later; no silent downgrade/retry that
  conceals a failed update;
- canonical composition position for the selected replacement, published schema
  and digest, and management diagnostics for selected and refused candidates;
- compatibility with existing desktop operations and conformance profiles, plus
  missing-owner rejection cascades and startup failure;
- concrete old/new bundle, approval, collision and rejection acceptance cases
  through the existing binary/public/VM seams, owned by launch-and-open.

Keep existing signing and approval checks. A changed signing posture or
incompatible `koine-desktop/1` promise is Antony's decision. Reconcile the server
ADR's independent-upgrade statement and all related spec/brief citations.

This is a load-bearing selection/trust design: cut its `review-design` sibling
before the launch-and-open node once the artifact exists; the review commissions
integration there if warranted. The design/review chain must settle before
launch-and-open consumes it. Do not implement loader changes in this leaf.

## Notes

One bounded question, not a new provider manager or installation UI. Use the
existing install roots and explicit approval artifacts. The extension's six
provider responsibilities and static effect conjunction are inputs, not reopened
layout questions.

## Decisions (running log)

The host owns a sealed catalogue of all six reserved identifier/prefix pairs,
independent of which bundles were discovered or admitted. Enabled entries also
name their bundled release/schema baseline. Per-user approval stays the existing
provider-ID/Team-ID artifact; built-in approval never approves a per-user copy.
This belongs in the existing Machine spec and server ADR, not a second loader or
a new provider-manager artifact.

Selection uses verified, compatible candidates before any provider is loaded.
The unique highest per-user release strictly newer than the host's baseline
replaces that slot; equal or older copies cannot displace it. Pre-load refusals
remain individually visible when a lower eligible copy is selected. A tie at the
highest eligible update leaves the slot unavailable. Once selection is frozen,
failure never retries another candidate. An update occupies its shipped slot in
composition regardless of physical root. This preserves canonical schema order.

The design compares numeric release triples and schema versions, with the same
schema major and no schema regression below the host's baseline. Compatibility
claims remain publisher obligations tested through the existing three seams;
version numbers cannot prove semantics. No persistent highest-seen-version store
or automatic rollback policy is introduced. The required review-design sibling
owns adversarial review; no in-session reviewer is added beside it.

Candidate diagnostics extend the existing management status type with nullable
identity/origin/selection/reason fields, retaining the closed state enum. The
schema digest describes served SDL, not binary identity, so conformance also
asserts the expected selected candidates. Launch-and-open owns the full decision
table's binary/public/signed-VM acceptance. These are design obligations, not
runtime results.

Source evidence used Tier 2 graph verification at generation
`2026-09-29T10:36:20Z`. `ProviderLoader.loadProviders` enumerates one root and
immediately maps `report`; `report` verifies then loads each bundle, and
`KoineServer` calls it separately for each root. `ProviderRoot.approval` reads the
existing ID/Team-ID artifact. `ProviderStatus` already reports every found bundle
but has no candidate discriminator. Exact snippets and both-direction depth-2
trace of loadProviders were read (12 callees, one caller, no truncated page).
Coverage reported no recorded source gaps for these files; docs are deliberately
excluded, so specs, ADRs, presentation and Taskfile were read directly. The
design requires moving selection ahead of those current loading effects; no
loader implementation changed here.

## Verification

`task design:selection-render` completed with both exports. `task check:docs`
passed; the presentation manifest's links/IDs and both SVG documents also parsed.
SHA-256 snapshots of docs, grove notes, Taskfile, README, glossary and the link
checker were unchanged during that validation run. Safari displayed the two
views and their deep links; the added unavailable-bundle branch was checked after
regeneration. Desktop/light rendering was inspected; narrow/dark rendering was
not exercised. No runtime selection, binary or VM acceptance is claimed here.
`first-party-provider-selection-k51` is the next root sibling and owns the
required independent review before the launch-and-open subtree.
