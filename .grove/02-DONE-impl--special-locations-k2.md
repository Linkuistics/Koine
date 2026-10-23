# special-locations-k2

## Goal

Build the workspace provider's read surface end to end, with its first query,
`Query.workspaceSpecialLocations(requests:)`. A client with a `workspace:read`
grant gets the Foundation values of the ten declared location pairs. A person
who grants `workspace:read` sees what it reaches. A host without the disclosure
feature refuses the new provider.

## Context

- The design is in the search spec's sections "Special locations", "Input and
  output validation" and "Public operations and authority". The types are in
  `docs/design/workspace-search-schema.graphql`: `WorkspaceSpecialLocationsResult`,
  `WorkspaceSpecialLocation`, `WorkspaceLocationRequest`, the location kind and
  domain enums, and the coverage types.
- Today `workspaceAdditionalRequirements` in
  `Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift` gives every field
  one unconditional authority: `workspace:control` and `desktop:control`. A read
  field needs `workspace:read` alone, so the registration becomes per field.
- `WorkspaceNative` in `Providers/WorkspaceProvider/Logic/Native.swift` is the
  private adapter. Its real implementation is
  `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`, and
  provider-local tests substitute their own.
- The disclosures are in `Sources/KoineCore/CapabilityDisclosures.swift`. The
  window shows the served catalogue
  (`ManagementClientTests.disclosuresAreTheServedOnesKeyedByCapability`).
- The host features are in `Sources/KoineCore/Composition.swift` and
  `Sources/KoineProviderLoader/ProviderLoader.swift`. The loader refuses a
  provider that requires a feature the host does not advertise. The provider's
  required features are in `Providers/WorkspaceProvider/manifest.json`.
- The served SDL is a design file, verbatim
  (`WorkspaceProviderTests.theServedSDLIsTheCompleteWorkspaceDesignVerbatim`).
  `SchemaConformanceTests` and the `design:*` tasks hold the 1.0.0 and 1.0.1
  design files as profiles. Keep those profiles, and add the new schema's file
  and profile beside them.

## Done when

- The workspace provider serves `Query.workspaceSpecialLocations(requests:)`.
  It returns the ten default pairs in the declared order, or the requested
  pairs. It returns each value with its kind, domain, account, contents
  availability `UNKNOWN` and the source `FOUNDATION_LOCATIONS`. It never lists,
  opens or inspects a location.
- Every reachable field of the query needs `workspace:read` and nothing else.
  The existing action fields keep `workspace:control` and `desktop:control`.
- The core serves a `workspace:read` disclosure that states the reach of this
  query. The host advertises `workspace-native-disclosures-v1`. The manifest
  and the descriptor require it.
- L tests cover the default pairs and each refused request: a duplicate pair,
  an unsupported pair, and more than ten pairs. They also cover an absent native
  value, reported as `UNKNOWN` with `NO_NATIVE_VALUE`.
- G tests cover the authority of every reachable field. Control grants alone
  are refused, and `workspace:read` alone reads. They cover the served
  disclosure, the served SDL against its design file, and the conformance
  profile. A test shows that a host without the feature refuses the workspace
  provider before it loads.
- The ADRs `workspace-native-images-preserve-action-authority` and
  `native-workspace-requires-disclosure-capable-host` say what binds now, as
  the root brief records. Every citation of them agrees. The search spec's
  "Source and binary authority boundary" section agrees with them.
- The search spec's "Special locations" and the trace row "Special locations"
  say what is served, with exact coordinates and the evidence so far. The
  README and the client guide describe the query.
- `swift test`, `task design:workspace-check` and `task conformance:headless`
  pass.

## Notes

- The provider's version changes here, because its schema changes. Read the
  version note in the root brief first.
- The next leaf widens the disclosure to the catalogue. Write this leaf's text
  for this query's reach only.
- Update the example client operations in
  `docs/design/workspace-search-operations.graphql` for the served query, as the
  workflow spec asks of each increment.

## Decisions (running log)

- **Version.** Workspace release 1.0.2 with schema 1.0.2. Release 1.1.0 is the
  selection fixture's, and release 1.2.0 with schema 1.1.0 is the full
  catalogue design's, so neither is free.
- **Features.** The bundled manifest and descriptor require
  `additional-capabilities-v1` and `workspace-native-disclosures-v1`. They do not
  repeat `first-party-selection-v1`, which every host that advertises the new
  feature already advertises. The loader still demands it of a per-user update.
  The ADR says so.
- **Design files.** The served SDL is the new design file
  `docs/design/workspace-special-locations-schema.graphql`: the 1.0.1 action text
  unchanged, plus the types the query reaches, word for word from the search
  design. The composed host file and a new profile sit beside the 1.0.0 and
  1.0.1 ones. `task design:special-locations-check` holds the three together.
- **Result rules.** One item per Foundation value. An absent pair is
  `NO_NATIVE_VALUE`. A value that is not an absolute path of 1 to 8,192 bytes
  without a NUL is withheld with `UNREPRESENTABLE_VALUE`. Items and absences give
  `PARTIAL`. Absences alone give `UNKNOWN`. Withheld values alone give `FAILED`,
  and then `items` raises `failed`. `declaredDomain` is `default special
  locations` or `requested special locations`.
- **Query denial.** A query is denied field by field at execution, with
  `requiredCapability` `workspace:read`. A mutation is denied at preflight with
  its complete set. The G test asserts each of these.
- **ADRs.** Both ADRs gained a "what binds now" part and lost nothing. The
  `design:search-check` task no longer demands the full-design read clause in the
  host ADR, because that ADR now states this cut's reach.
- **Not spent.** The leaf-wide reviewer allowance. The next leaf cuts the
  `review-impl` for the read surface.
