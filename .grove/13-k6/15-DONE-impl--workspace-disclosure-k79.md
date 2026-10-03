# workspace-disclosure-k79

## Goal

Before workspace ships, disclose workspace control's reach wherever a person
grants or reviews it. The reach is:

- any registered installed application;
- document execution and redirects by handlers;
- the need for both `workspace:control` and `desktop:control` to launch, open or
  reveal.

## Context

- The workspace spec's disclosure sentences, the Authority/revocation and
  disclosure row, and the workflow spec's grant-disclosure row.
- `docs/adr/provider-authority-follows-effects.md` on disclosed reach.

## Done when

- The native create-grant view, request approval view and existing-grant list
  show the disclosure wherever workspace control is offered or held.
- Management clients receive the same disclosure. If management has no place to
  carry a capability's description, adding one is additive management metadata:
  record the choice, and keep conformance in step.
- The served GraphQL descriptions match the design file.
- A signed build in an isolated VM shows the disclosure for a new grant, a
  pending request and an existing grant, observed in the window.
- The Authority/revocation and disclosure row and the grant-disclosure trace row
  link the evidence.

## Notes

The disclosure of desktop control's expanded reach belongs to `window-layout`;
do not pre-empt it here.

## Decisions (running log)

- **Management carries the text, in the core.** The provider framework has no place for
  a capability description and was not changed. `koineManagement.capabilityDisclosures`
  (`KoineCapabilityDisclosure { capability, disclosure }`) is additive management
  metadata, served from a core catalogue keyed by capability name
  (`CapabilityDisclosures`), whole, whether or not the provider is active, so a grant
  holding a capability whose provider failed still discloses. Requires `koine:manage`.
  Recorded in `docs/specs/machine.md#capability-disclosures` and the client guide.
- **Conformance in step.** The field is in the three extension-host design files and
  `coreSchemaSDL`; the baseline `desktop-schema.graphql` and old-host profile are
  untouched (a released host never served it). `ConformanceProfileTests` now expects
  exactly the candidate fields plus these two coordinates. `task conformance` passed
  all three profiles.
- **One text, three places.** The native create-grant, request and existing-grant views
  show the served text beside `workspace:control`; a revoked grant holds nothing and
  shows none; `desktop:control` shows none (window-layout's disclosure, not pre-empted).
  Not gated: a failed read shows a retried red line rather than disabling grants.
- **The grant form outgrew the window,** so VM scripts that clicked Create Grant
  unscrolled broke (found by `task conformance`). Fixed centrally: `reveal_click` in
  `vm-verify-lib.sh`, used by `create_grant`, `vm-verify.sh` and `vm-verify-providers.sh`.
  Only conformance and the new disclosure script were re-run among the grant-creating
  scripts.
- **Flaky test fixed in passing.** `WorkspaceCompositionTests` failed about half the runs:
  two denial tests selected two sibling non-null fields, which resolve concurrently, against
  the suite's own rule of one branch per scenario. Each now selects one field; ten
  consecutive runs passed. Not caused by this leaf.
- **No review chain cut.** Nothing here is a spec or a load-bearing decomposition, no
  in-session reviewer was spent, and the V run compares the window with the served text.
- **Node `launch-and-open-k6` closes with this leaf.** Its Done-when is delivered by its
  subtree; the live remainder is the root leaves `alternate-team-signing-k80`,
  `protected-default-open-k89` and `reveal-app-bundle-notice-k90`, each cut with its reason.
