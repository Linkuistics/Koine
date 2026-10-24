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

## Decisions (running log)

- **Evidence.** The review uses the committed source at `49fb168e`, including
  the special-location implementation at `ed7610e0`. The graph CLI refused to
  start because a pre-coordination or unverified generation is active. No
  project, generation or coverage result was available. Source reads and
  targeted text searches therefore supply the evidence. No test, build, lint,
  format command or native discovery read is run by this review.
- **Deadline finding.** The timeout queues its outcome behind the work that
  must finish, then waits without a timeout. A gathering whose attribute copy
  crosses the deadline can win with a successful outcome after the wait has
  expired. A stalled native operation also holds the caller and query cleanup.
  This earns finding R1. It concerns delayed or stalled discovery; it supplies
  no evidence that the ordinary happy-path run must fail.
- **Disclosure finding.** The chosen indexed-local scope includes the user's
  home even when remote. The served disclosure describes local disks alone.
  The SDK declaration and Apple's scope documentation establish the mismatch.
  This earns finding R2. Issue 10 sends this disclosure defect to an issue,
  because it does not prevent the declared read-and-launch happy path.

## Review findings

Two findings merit integration triage. Neither establishes a failure of the
declared happy path, so neither blocks release under issue 10's rule. The
integration step files each accepted finding as a GitHub issue. The pending N
and V acceptance work remains necessary; this review supplies no native pass.

### R1 — P2: The timeout waits behind the native work it must bound

**Location:** `Providers/WorkspaceProvider/Sources/IndexedApplicationQuery.swift:46`,
especially the unbounded queue drain at line 50. The conflicting success path is
at lines 56–66.

**Trigger:** The finish notification begins copying attributes shortly before
the three-second deadline, and one attribute read or the complete copy takes
longer than the remaining time. For example, `gathered()` begins at 2.9 seconds
and finishes at 3.2 seconds. The same ownership defect also matters if
`query.start()`, an attribute read or `query.stop()` stalls indefinitely.

**Wrong result:** At three seconds the semaphore times out, but its timeout
outcome is only queued on the serial queue already doing that work. The caller
then waits for every operation without a timeout. In the finite example,
`gathered()` stores `.gathered` first; the queued `.unfinished` cannot replace
it. The provider can report `AVAILABLE` and `COMPLETE` after the deadline was
exceeded. In the stalled case, the provider's dispatch worker never returns,
the observer is not removed, and cleanup queued behind the stalled operation
cannot stop the query. The core's request deadline does not unblock this
synchronous wait. Also, successful settlement signals the caller before
`query.stop()` runs, so return alone does not establish the adapter's promised
completed stop.

The SDK start-thread rule is satisfied: the assigned operation queue performs
`start()`. This finding concerns deadline settlement and cleanup ownership,
not the choice of a background queue. Apple's
[start documentation](https://developer.apple.com/documentation/foundation/nsmetadataquery/start())
and [operation-queue documentation](https://developer.apple.com/documentation/foundation/nsmetadataquery/operationqueue)
support that distinction. The macOS SDK's `NSMetadata.h:80` and `:85` state
the queue's role and the start-thread rule too.

`ApplicationCatalogueTests` and `WorkspaceApplicationCatalogueTests` substitute
`indexedApplications` with an already computed `.unfinished` result. Their late
answer tests therefore check result mapping, but cannot detect this queue
interleaving or a blocked adapter. No native reproduction was run here.

**Issue 10 class:** Nonblocking issue for delayed or stalled native discovery.
Nothing in this inspection establishes that the normal signed happy-path
subject encounters that state. If acceptance cannot obtain the application
list because of it, that observed happy-path failure blocks release.

### R2 — P2: The read disclosure omits a remote home directory

**Location:** `Sources/KoineCore/CapabilityDisclosures.swift:32`. The selected
scope is `Providers/WorkspaceProvider/Sources/IndexedApplicationQuery.swift:24`.

**Trigger:** Koine's account has a remote home directory with application
metadata in the selected query domain.

**Wrong result:** Every grant creation, approval and review surface using this
catalogue describes applications on the Mac's local disks alone. The actual
scope includes the user's home even when remote. Thus the newly advertised
`workspace-native-disclosures-v1` feature under-discloses an admitted source.
The search spec's general source section and the existing native-source report
already acknowledge this reach, while the release subsection repeats the
local-disk wording.

Apple's [indexed-local scope documentation](https://developer.apple.com/documentation/foundation/nsmetadataqueryindexedlocalcomputerscope)
states the remote-home inclusion. The macOS SDK's `NSMetadata.h:191` states it
as well. The disclosure tests check fragments such as Spotlight and bundle
identifier, and do not detect this narrower description.

**Issue 10 class:** Nonblocking disclosure issue. It does not prevent the ten
location lookups, application-list read or explicit launch in the declared
happy path. The integration step owns filing the accepted issue.

## Required review conclusions

| Required check | Inspected evidence and conclusion |
| --- | --- |
| 1. Control alone reads nothing; read alone acts on nothing | Checked the entire served SDL against every registration in `workspaceDescriptor`. Both roots and all their reachable object fields use `.read` without additional requirements. The four action roots and all their reachable object fields use `.control` plus desktop control. The result objects are disjoint. The G tests exercise control-only denial before native work and read-only mutation denial. No defect found in the registrations or routing. |
| 2. Disclosure states the real reach | Checked `CapabilityDisclosures`, the feature advertisement, both manifest and descriptor requirements, and the G/management tests. The special-location wording and index-only metadata wording describe this cut; R2 records the omitted remote-home reach. There is no bundle reader, registration expansion or Settings scripting in this cut to disclose. |
| 3. Released 0.3.0 refuses the provider before load | Inspected the actual `v0.3.0` tag (`efcc0602`), not merely a simulated old host. Its `Composition.swift` advertises only the additional-capabilities and first-party-selection features. Its loader checks missing manifest features before preparing a loadable image. The new manifest requires `workspace-native-disclosures-v1`, and its descriptor agrees. The current loader test also asserts that the load seam is not reached when this feature is absent. No source defect found. The independently signed N pair remains pending. |
| 4. Empty, failed and late answers cannot claim a complete inventory | Checked `ApplicationCatalogue.swift`, `SpecialLocations.swift`, the frozen-items resolvers, SDL and L/G tests. Empty index gathering is UNKNOWN with null items and UNKNOWN source observations; failed/unfinished/overflow answers are FAILED with null items, UNKNOWN observations and distinct reasons. Each selected FAILED items alias raises independently. Positive index results always retain UNKNOWN category completeness. Nested aliases read frozen values. R1 records the real adapter's ability to turn a deadline overrun into a late successful observation; the result mapper alone is correct for `.unfinished`. |
| 5. Threading follows the SDK and cannot hang or leak a query | Checked `IndexedApplicationQuery` against the local SDK and Apple's Foundation documentation. `start()` is called on the query's assigned serial operation queue, and result processing uses that queue with updates disabled. No violation of the SDK start-thread requirement was found. The stronger bounded-return/cleanup claim fails under R1: the timeout waits on the same native work and cleanup can remain pending indefinitely. |
| 6. Reads cannot raise a Koine permission dialog | Traced the location read to `NSHomeDirectory`, non-creating `FileManager.urls(for:in:)` and `getuid`; traced the application read to the fixed indexed-local query and its four attributes. No read route calls launch/open/reveal, bundle-content inspection, directory listing or an explicit consent request. Source inspection does not establish that Spotlight itself cannot prompt. The earlier protected-directory Spotlight experiment used another scope and predicate and proves neither safety nor failure for this query. Exact signed-subject prompt behavior remains unestablished until V. A Koine-named dialog there still stops for the human, as the root brief requires. |

## Schema and verification limits

The existing holding is suitable for this cut's schema: `WorkspaceProviderTests`
compares served SDL with the design and preserves the action blocks;
`SchemaConformanceTests` compares the composed schema, descriptions, digest and
added coordinates; `design:workspace-discovery-check` holds discovery definitions
to the search design, constrains the choice fields and query signatures, validates
the served operations and includes mutated subjects. These checks address
schema drift. They do not establish native threading, useful application
witnesses or prompt behavior, and this review did not rerun them.

The inspected L/G tests cover the ten default pairs (which may produce more
than ten items), refused requests before lookup, absent and withheld values,
separate copies, source provenance, frozen aliases, status branches and grant
denial. An absent identifier is intentionally retained as null, as its explicit
test and the selected-action trace state; it gives no named launch selector.
No new finding is assigned to that documented behavior.

The two pre-existing failures named in the charter are excluded. The producer's
task notes and test definitions are inspected evidence, not a fresh passing run.
No production or test code was changed. Graph freshness and index coverage could
not be checked because the CLI refused startup; all conclusions above are bounded
to the source, committed changes, specifications and documentation named here.
