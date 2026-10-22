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
