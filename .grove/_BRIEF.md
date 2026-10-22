# Koine.gh-issue-11 — brief

## Goal

Ship the first cut of app and file search, GitHub issue 10, as Koine 0.4.0
through the Homebrew cask. A client with a `workspace:read` grant reads the
special locations that macOS names for Koine's account. It lists the
applications that the system's index reports, and it can launch one through the
existing workspace action. The human settled this cut in `plan-k1`. This brief
holds its design, and no new spec or ADR restates it.

## Done when

- **Special locations.** `Query.workspaceSpecialLocations(requests:)` serves the
  designed type in full. It returns Foundation values for the ten declared
  account and domain pairs. It never lists, opens or inspects a location.
  Request validation follows the search spec's "Input and output validation".
- **The application catalogue.** `Query.workspaceApplications` lists the
  applications from the one fixed index query of the search spec. Each choice
  has its path, name, bundle identifier and source. The name is the localised
  name that the index reports. The result reports status and coverage, so a
  client can tell an empty answer from an unknown one.
- **Safari and Finder.** If the VM run shows the index without one of them, the
  catalogue asks Launch Services for that fixed identifier only. It labels the
  result `REGISTRATION`. If the index reports both, nothing is added.
- **Authority.** Every reachable field of both queries needs `workspace:read`.
  Control grants alone read nothing. Launch, open and reveal keep their grants
  and their 1.0.0 and 1.0.1 compatibility.
- **Disclosure.** The core serves a `workspace:read` disclosure that states the
  actual reach of both queries. The host advertises
  `workspace-native-disclosures-v1`, and the workspace provider requires it.
  The released 0.3.0 host therefore refuses the new provider before it loads.
- **Packaging.** Both queries are in the existing workspace bundle, with no new
  image.
- The four agreed test seams (Pointers) pass.
- **Docs** describe the current state. Three ADRs change in place (Pointers).
  The search spec, the trace rows, the README, the client guide and the glossary
  say what 0.4.0 serves. The full catalogue design stays as the design of later
  cuts.
- **Koine 0.4.0 is released.** It is notarised, its release checks pass on the
  notarised build, and it is tagged. The GitHub release is published, the cask
  is bumped, and the Homebrew check passes.
- Each review finding that does not break the happy path is a GitHub issue.

## Decomposition

1. `special-locations`: the read surface and its first query, end to end. It
   adds the `workspace:read` disclosure, the host feature and the provider's
   need for it. It makes the image and host-disclosure ADR edits, with L and G
   tests. It goes first because the read surface is new to the workspace
   provider.
2. `application-catalogue`: the index-backed catalogue with status and coverage,
   and L and G tests. It also makes the qualification-hold ADR edit and updates
   the spec and trace rows. It needs 1. Its last act cuts one `review-impl` leaf ahead of 3.
3. `discovery-acceptance`: the N check and the one happy-path VM run on the
   development-signed bundle. It adds the Safari and Finder lookup only if the
   run shows the need. It needs 1, 2 and the review.
4. `release-0-4-0`: version, notarisation, release checks on the notarised
   build, then publishing. The human approves each public step. It needs 3.

## Pointers

- Glossary: **Special location**, **Native catalogue**, **Discovery coverage**,
  **Indexed application metadata**, **Prompt risk**, **Capability**, **Grant**
  (`CONTEXT.md`).
- Specs: `docs/specs/workspace-search.md` is the full catalogue design. Its SDL
  is `docs/design/workspace-search-schema.graphql`, and its operations are
  `docs/design/workspace-search-operations.graphql`.
  `docs/specs/workflow-providers.md` owns the "Operation-to-capability trace"
  and the "Test seams". `docs/specs/workspace-launch-and-open.md` owns the launch
  that the VM run uses.
- ADRs that bind and stay as they are: `raw-filesystem-search-belongs-to-clients`,
  `search-coverage-describes-observations`, `prompt-risk-is-search-data`,
  `application-search-uses-bundle-identity`, `provider-authority-follows-effects`.
- ADRs that this grove changes in place:
  - `application-metadata-qualification-precedes-analytic-fit`: the advertisement
    hold covers the private reader only, which issue 2 holds. The index-backed
    catalogue ships after its happy-path VM run.
  - `workspace-native-images-preserve-action-authority`: the split into
    principal, actions, discovery and settings images binds when System Settings
    scripting or the private reader arrives. Until then, discovery shares the
    workspace image.
  - `native-workspace-requires-disclosure-capable-host`:
    `workspace-native-disclosures-v1` states this cut's reach. A later cut that
    widens the reach needs a new feature version.
- **Test seams, agreed with the human:**
  1. *L*: provider-local tests with `swift test`. They substitute the private
     adapter `WorkspaceNative`. They check how index items become choices. They
     check status and coverage for complete, empty, failed and late gathering.
     They check the location-request rules with the default ten pairs, and the
     Safari and Finder rule if it is built.
  2. *G*: public GraphQL through the embedded server with `swift test`. Every
     reachable field of both queries needs `workspace:read`, and control grants
     alone are refused. The read disclosure is served. The host advertises the
     disclosure feature, and the provider requires it. The served schema equals
     its design file, and the conformance profile has the new fields.
  3. *N*: the compatibility tasks. The new workspace bundle loads in the new
     host, and the released 0.3.0 host refuses it before it loads.
  4. *V*: one TestAnyware VM run on the launchers image, with Gatekeeper
     enforcing, through the contract-only client. The catalogue lists Safari,
     Finder and the twelve launchers. Each of the ten default locations has a
     value. One listed application launches through
     `workspaceLaunchApplication` with its catalogue identifier and path. No
     permission dialog naming Koine appears during the reads. The release checks
     then run on the notarised build.

## Notes

- **The human's delivery rule**, from issue 10:

<!-- tc: off because this is the human's rule, quoted verbatim -->

  > Ship when the happy-path VM test passes. A review finding blocks the release
  > only if it breaks the happy path; anything else becomes an issue.

<!-- tc: on -->

- **A permission dialog naming Koine during a read is a stop.** It is a new
  consent posture, and issue 10 makes each new consent, entitlement or signing
  posture the human's decision. Stop and ask the human. Do not publish around it.
- **Real discovery reads run only in TestAnyware VMs.** A Spotlight query from
  Koine can raise a Files and Folders dialog (`docs/verification/search-discovery.md`).
  L and G use substituted adapters. N loads binaries and reads nothing.
- **GUI work runs only in TestAnyware VMs**, never on the host. That covers
  launching `Koine.app`, driving its UI, taking focus and the clipboard. Builds,
  `swift test` and `codesign` on the host are fine.
- **The served schema takes names and types from the design SDL.** Each type
  serves only the fields that this cut fills from its sources. Fields that the
  index cannot fill wait for the cut that fills them, such as
  `installationState`, `uiElement`, `backgroundOnly` and
  `runningActivationPolicies`. Under `koine-desktop/1`, a later field is an
  addition, and an addition breaks no client.
- **Served descriptions describe 0.4.0.** The design SDL's description of
  `workspaceApplications` carries the whole qualification programme. The served
  description says what this cut does.
- **The read disclosure** uses the draft below as its first version. Fit it to
  the actual reach. The release leaf shows the human the final text before
  publishing.

  > Reads the special locations that macOS names for Koine's own account, such
  > as the home, Documents and Applications folders. Lists the applications that
  > Spotlight has indexed on this Mac, with each one's name, bundle identifier
  > and location. It reads no file contents and lists no folder. A returned
  > location gives no access to it. Launching or opening a listed application
  > still needs workspace:control and desktop:control.
- **Version numbers.** The workspace provider is 1.0.1 today. Workspace 1.1.0
  with schema 1.0.1 is the selection-acceptance update fixture, so do not reuse
  1.1.0. The search spec plans workspace 1.2.0 with schema 1.1.0.
- **The glossary states the advertisement hold** in its entries **Explicit
  application metadata reader** and **Private application qualification**.
  Reconcile them with the ADR edit, and chase each citation of the changed ADRs.
- **Docs edits convert first.** An existing document follows the
  technical-communication rules before an edit. Convert the touched sections as
  their own commit, and put the other sections in `pending` regions. The README
  and the search spec each have several hundred checker findings today.
- **Use the Taskfile.** Each new check gets a task beside the existing ones, as
  every VM check has.
- **Out of scope:** the System Settings catalogue, which is the second cut, and
  issues 1, 2 and 3. This cut's acceptance launches only, so it does not reach
  issue 5 (protected-folder opens) or issue 6 (the reveal notice).
