# application-catalogue-k3

## Goal

Serve `Query.workspaceApplications`: the applications that the one fixed index
query reports, with each one's path, name, bundle identifier and source, and the
result's status and coverage. Narrow the advertisement hold to the private
reader.

## Context

- The design is in the search spec's sections "Application sources and native
  facts" and "Coverage and frozen publication". The fixed query, its scope and
  its four-attribute projection are in the first of them. The types are
  `WorkspaceApplicationsResult` and `WorkspaceApplicationChoice` in
  `docs/design/workspace-search-schema.graphql`.
- This cut reads the index only. It adds no running-application supplement, no
  registration expansion and no bundle reader. The Safari and Finder lookup
  belongs to `discovery-acceptance-k4`, and only on evidence.
- `special-locations-k2` built the read surface: per-field authority, the read
  disclosure and the host feature.
- Acceptance case G2 in `docs/verification/native-discovery-acceptance.md`
  states the rule for an empty index result: it is `UNKNOWN`, never a complete
  empty inventory.
- Issues 2 and 3 name the design that stays out of this cut.

## Done when

- The workspace provider serves `Query.workspaceApplications`. Every reachable
  field needs `workspace:read` and nothing else.
- One `NSMetadataQuery` uses the fixed predicate and the indexed-local scope of
  the search spec. It reads the fixed projection from each returned item, and
  it stops after the initial gathering, within a bounded wait.
- Each choice has its path, the index's name, its bundle identifier and the
  source `INDEXED_APPS`. Status and coverage follow the coverage ADR. An empty
  result, a failed query and a late gathering are each told apart from a
  complete answer.
- The `workspace:read` disclosure states the catalogue's reach as well.
- L tests cover the mapping from index items to choices, and each status and
  coverage branch. G tests cover the authority of every reachable field, the
  widened disclosure, the served SDL and the conformance profile.
- The ADR `application-metadata-qualification-precedes-analytic-fit` says that
  the hold covers the private reader only. Every citation of it agrees,
  including the glossary entries that the root brief names.
- The search spec's application sections and the trace rows "Application native
  catalogue" and "Application catalogue — selected actions" say what is served.
  The README and the client guide describe the query.
- `swift test`, `task design:workspace-check` and `task conformance:headless`
  pass.
- The review leaf exists (Notes), cut before this leaf retires.

## Notes

- **Cut the review as the last act of the work.** The human agreed one review
  before the acceptance run. Run `grove-llm leaf-insert --kind review-impl
  discovery-acceptance-k4 application-catalogue`, so that the review runs
  before the acceptance leaf. Write `**Reviews:** application-catalogue-k3`
  under its header. Settle its `**Creator:**` line as `references/retire.md`
  directs.
- **The review's charter.** Ask for an adversarial read of the whole served
  discovery surface, both queries included. It reads the schema, the authority
  of each field, the disclosure text, the host feature, and the meaning of
  status and coverage. It reads them against the root brief and the search
  spec. Issue 10's delivery rule decides what blocks: a finding blocks the
  release only if it breaks the happy path. Each other finding becomes a GitHub
  issue.
- The index may report several copies of one application. Keep each copy as
  its own choice, as `application-search-uses-bundle-identity` requires. Do not
  merge copies by identifier.

## Decisions (running log)

- **Version.** The workspace stays at release 1.0.2 with schema 1.0.2. Release
  1.0.2 has never shipped, so this leaf widens it in place. The host feature stays
  `workspace-native-disclosures-v1`: one version states the reach of both queries,
  and the released 0.3.0 host refuses the bundle either way.
- **Design file names.** The files said "special locations", and they now carry the
  catalogue as well. The design SDL is `workspace-discovery-schema.graphql`, the
  composed host file is `desktop-workspace-discovery-schema-extension-host.graphql`
  and the profile is `core-desktop-workspace-discovery-extension-host.json`. The
  Taskfile check is `design:workspace-discovery-check`. The retained k2 task file
  keeps the old names, as history. The k4 task file has the new profile name.
- **Served choice.** `WorkspaceApplicationChoice` serves `applicationPath`, `name`,
  `bundleIdentifier` and `sources`. It has the design's name and type for each
  field and a description of this release. `metadataSource` waits too: it could
  only ever say `INDEXED_ITEM`, so it adds nothing yet. The Taskfile check holds
  the served choice to a subset of the design's fields with equal types. It holds
  the other served types to the search design word for word.
- **Result rules.** The table in the search spec, "Application catalogue served in
  Koine 0.4.0", is the rule. An empty finished gathering is `UNKNOWN`. An
  unfinished one is `FAILED` with `TIME_LIMIT`, and more than 2,048 items is
  `FAILED` with `ENTRY_LIMIT`. The spec's population rule says the same: it never
  reports a prefix.
- **Diagnostics.** One diagnostic for each reason, with the count in the guidance
  and a null subject, so the 63-record sink cannot fill. The spec's per-item
  subject is not built. A client does not need it to tell the cases apart.
- **Type tree.** The adapter reads `kMDItemContentTypeTree`, as the fixed
  projection says. An item whose tree is present and lacks the application-bundle
  type is withheld with `METADATA_UNKNOWN`. An item with no tree is kept, because
  the predicate already selected it.
- **Threading.** The query lives on its own serial `OperationQueue`. The SDK header
  (NSMetadata.h) says `startQuery` "must be called from the receiver's
  operationQueue or on the main thread". The real adapter has not run on this
  host, as the root brief requires: the V run in `discovery-acceptance-k4` is its
  first real run. A hang there would show as `FAILED` with `TIME_LIMIT`.
- **Wait.** Three seconds, the same as the acknowledgment bound, and a provider
  initialiser parameter so tests can shorten it.
- **Hold scope.** The ADR now says the hold covers the private reader only, and
  that GitHub issue 2 holds it. The other cited documents say "advertisement/consumption
  holds remain" in the context of that reader. They agree and stay as they are.
  The glossary entry **Explicit application metadata reader** and the search spec
  say the scope out loud.
- **Failures that are not from this leaf.** `swift test` has the one macOS 27
  wording failure that k2 recorded. `task design:application-metadata-reconciliation-check`
  fails with "expected one live consumer charter" for seven old leaf keys: they
  name task files that no longer exist in this grove's `.grove/`. Neither touches
  this leaf's files.
- **Not spent.** The leaf-wide reviewer allowance. The review leaf below is the
  scheduled review.
