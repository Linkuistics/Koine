# application-catalogue-k6

**Reviews:** application-catalogue-k3

## Goal

Read the whole served discovery surface of Koine 0.4.0 adversarially. Both queries
are in scope: `Query.workspaceSpecialLocations` from `special-locations-k2` and
`Query.workspaceApplications` from `application-catalogue-k3`. Report findings
only. The paired integrate step owns every fix.

## Context

- The root brief states what the cut must do, and the search spec's sections
  "Special locations", "Application catalogue served in Koine 0.4.0" and
  "Coverage and frozen publication" state how.
- Read these against each other:
  - The served schema (`Providers/WorkspaceProvider/schema.graphql`) and its design
    file (`docs/design/workspace-discovery-schema.graphql`), with the
    descriptions of this release.
  - The authority of each field (`workspaceDescriptor` in
    `Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift`).
  - The disclosure text (`Sources/KoineCore/CapabilityDisclosures.swift`) and the
    host feature `workspace-native-disclosures-v1` that carries it.
  - The meaning of status and coverage for each query
    (`Logic/SpecialLocations.swift`, `Logic/ApplicationCatalogue.swift`).
- The real index adapter, `Providers/WorkspaceProvider/Sources/IndexedApplicationQuery.swift`,
  has not run. The root brief allows real discovery reads only in TestAnyware
  VMs. The V run in `discovery-acceptance-k4` is its first real run. Read it
  against the SDK header `NSMetadata.h`. The header says `startQuery` "must be
  called from the receiver's operationQueue or on the main thread". Read the
  Foundation documentation for `NSMetadataQuery` too. The decisions log in
  `application-catalogue-k3` lists what that leaf chose and why.
- Two failures are known and are not findings. One is the macOS 27 error wording
  in `WorkspaceApplicationLocationTests`. The other is the seven "expected one
  live consumer charter" lines of `task design:application-metadata-reconciliation-check`.

## Done when

- Every finding names its file and line, the input or state that triggers it, and
  the wrong result. A finding without a trigger is noise.
- Issue 10's delivery rule classes each finding. A finding blocks the release
  only if it breaks the happy path. In the happy path, a client with
  `workspace:read` reads the ten locations and the application list. The client
  then launches one listed application with `workspaceLaunchApplication` under
  the control grants. Every other finding becomes a GitHub issue, which the
  integrate step files.
- The review states which of these it checked, and what it found for each:
  1. A control grant alone reaches no field of either query. A read grant
     alone acts on nothing.
  2. The disclosure states the real reach of both queries.
  3. The released 0.3.0 host refuses the new provider before it loads.
  4. An empty, failed or late index answer cannot read as a complete inventory.
  5. The adapter's threading follows the SDK rule and cannot hang the provider
     queue or leak a query.
  6. No read can raise a permission dialog that names Koine, by the reading of
     the code. If the V run shows one, it is a stop for the human.

## Notes

- Inspection only. Run no test, build, lint or format command. Edit no code.
- The served SDL is held to its design by `task design:workspace-discovery-check`
  and by tests in `SchemaConformanceTests` and `WorkspaceProviderTests`. Judge
  whether that holding is enough, and do not redo it.
