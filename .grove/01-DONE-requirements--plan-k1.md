# plan-k1

## Goal

Establish, in the human's own words, what the first cut of app and file search
(GitHub issue 10) ships as the next Koine release. Settle its scope and its open
behaviour questions, agree the test seams, and cut the work.

## Context

- The human's words are the workspace name (`gh-issue-11`) and two GitHub
  issues, quoted below. Issue 11 is the roadmap. Issue 10 is its first open
  item, and it proposes a scope for this grove to settle.

<!-- tc: off because the quotations are the human's words, verbatim -->

> Issue 11, "Roadmap: deliver the remaining Modaliser providers as small
> happy-path releases": "Each item becomes its own small grove that ends in a
> shipped release: happy path first, one VM acceptance of that path, then
> GitHub issues for edge cases, coverage and hardening."
>
> Issue 10, "App and file search: first cut (special locations and application
> catalogue)": "Proposed scope (to confirm when the grove starts)".

<!-- tc: on -->

- Issues 2 and 3 hold the deferred hardening. Each says it was paused so that
  app search can ship a first cut that uses only the system's indexed metadata.
- The precedent is the 0.3.0 grove (commit `32ff91cc`, its `plan-k1`). One
  requirements leaf settled the design and cut three `impl` leaves: the feature,
  the VM checks and the release.
- jj created this workspace on the 0.2.0-era commit `a5eac76d`, seven commits
  behind `main`. This session rebased the working copy onto `main` (`b56ebea2`,
  Koine 0.3.0).
- The current design: `docs/specs/workspace-search.md` describes the full
  catalogue, which no build serves. `docs/design/workspace-search-schema.graphql`
  is its SDL. The trace rows are in `docs/specs/workflow-providers.md`. Two ADRs
  bind the first cut: `native-workspace-requires-disclosure-capable-host` and
  `application-metadata-qualification-precedes-analytic-fit`. The second holds
  advertisement until the private qualification passes.
- The code today: the served workspace schema has launch, open URL, open path
  and reveal only. `workspace:read` is in `availableCapabilities`, but no field
  needs it. `CapabilityDisclosures` has text for `workspace:control` only. No
  code advertises `workspace-native-disclosures-v1`.
- The seam names are L (provider-local tests with the substituted native
  adapter), G (public GraphQL), N (the real provider binary) and V (TestAnyware
  VMs).

## Done when

- The scope and behaviour of the first cut are settled and recorded below, in
  the human's terms.
- The test seams are agreed with the human.
- The work is cut into leaves, or a `planning` leaf holds it if it proves
  larger.

## Notes

## Decisions (running log)

- **This grove delivers issue 10 only.** It ships the first cut of app and file
  search as the next Koine release, and then it finishes. The next roadmap item
  gets a grove of its own. (Human, choosing among issue 10 only, the whole
  roadmap and a different item first.)
- **The scope is issue 10's, as written.** In:
  `Query.workspaceSpecialLocations(requests:)`, which returns Foundation
  location values and never lists their contents. `Query.workspaceApplications`,
  which returns each application's name, bundle identifier and path from the
  system's index, with the localised name that the index reports. The
  `workspace:read` grant, its disclosure text and the GraphQL schema for both
  queries. One happy-path VM acceptance. Out: the System Settings catalogue,
  which is the second cut, and issues 1, 2 and 3. As a consequence, the
  advertisement hold in `application-metadata-qualification-precedes-analytic-fit`
  and in the search spec narrows in place to the private reader. (Human,
  choosing among as written, applications only and adding System Settings. The
  consequence was stated before the choice.)
- **A missing Safari or Finder gets a lookup, and nothing else does.** No
  measurement shows whether the index reports either one. If the happy-path VM
  run shows the index without one, the first cut adds a lookup. At query time,
  it asks Launch Services for `com.apple.Safari` or `com.apple.finder`, and only
  for an identifier that the index did not report. Its result is labelled
  `REGISTRATION`. If the index reports both, the first cut adds nothing. This
  avoids two paths for one application and the identity rules that would
  resolve them. (Human, choosing among a lookup only for what is missing, both
  lookups always, and accepting the gap.)
- **One workspace image for this cut.** Both read queries join the existing
  workspace bundle. This grove rewrites two texts in place: the ADR
  `workspace-native-images-preserve-action-authority` and the search spec's
  authority-boundary section. After the edit, they say that the split into
  principal, actions, discovery and settings images binds when System Settings
  scripting or the private reader arrives. This cut's reads add no scripting,
  consent-prompt or activation route, and issue 3 holds the guard instruments.
  (Human, choosing between one image now and the split now. The consequence was
  stated before the choice.)
- **Four test seams, all existing.** L: provider-local tests with `swift test`.
  They substitute the private adapter `WorkspaceNative` and check how index
  items become choices. They also check status and coverage for complete,
  empty, failed and late gathering. They check the location-request rules with
  the default ten pairs, and the Safari and Finder rule if it is built. G: public GraphQL
  through the embedded server with `swift test`. Every reachable field of both
  queries needs `workspace:read`, and control grants alone are refused. The read
  disclosure is served. The host advertises the disclosure feature, and the
  provider requires it. The served schema equals its design file, and the
  conformance profile has the new fields. N: the compatibility tasks. The new
  workspace bundle loads in the new host, and the released 0.3.0 host refuses it
  before loading. V: one TestAnyware VM run on the launchers image, with
  Gatekeeper enforcing, through the contract-only client. The catalogue lists
  Safari, Finder and the twelve launchers. Each of the ten default locations has
  a value. One listed application launches through `workspaceLaunchApplication`
  with its catalogue identifier and path. No permission dialog naming Koine
  appears during the reads. The release checks then run on the notarised build.
  (Human, choosing all four seams over L, G and V without N.)
- **The human agreed the shared understanding, with these proposals.** (Proposed
  in one final summary, which the human accepted.)
  - *The served schema* takes its names and types from the design SDL. Each
    type serves only the fields that this cut fills from its sources. Special
    locations serve their designed type in full. An application choice serves
    its path, name, bundle identifier and source. Each result serves status and
    coverage, as `search-coverage-describes-observations` requires. Fields that
    the index cannot fill wait for the cut that fills them.
  - *The read disclosure* uses the draft in the summary as its first version. The feature
    leaves fit it to the actual reach. The release leaf shows the human the
    final text before anything is published.
  - *A third ADR edit*: in `native-workspace-requires-disclosure-capable-host`,
    `workspace-native-disclosures-v1` states this cut's reach only. A later cut
    that widens the reach needs a new feature version.
  - *The release* is Koine 0.4.0, by the 0.3.0 route. The release leaf stops
    before each public step and asks the human.
  - *One review*: the application leaf cuts one `review-impl` leaf ahead of the
    acceptance run. Issue 10's delivery rule is its charter.
  - *A stop rule*: a permission dialog naming Koine during a read in the VM is a
    new consent posture. The acceptance leaf then stops and asks the human.
  - *The cut* is four `impl` leaves in order: `special-locations`,
    `application-catalogue`, `discovery-acceptance` and `release-0-4-0`. There
    is no new spec and no new ADR, because the design lives in the root brief.
