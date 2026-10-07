# long-search-result-actions-k170

**Integrates:** long-search-result-actions-k169

## Goal

Triage k169's finding and reconcile the exact public open-path description with
the reviewed target/discovery/selected-application stages before planning k167.

## Context

- Review `long-search-result-actions-k169`, anchored to k168's design commit
  `6647c3a6` (`zlnnvywv`). Read its R1 and checked/accepted conclusions; the
  finding is the review's deliverable, not this charter's summary.
- `docs/design/workspace-action-repair-schema.graphql:83` and
  `docs/specs/workspace-launch-and-open.md#order-of-target-and-application-stages`:
  target refusal precedes handler discovery, but an over-limit discovered
  application can only be refused after its location is discovered.
- Search 1.1.0 incorporates the repaired action descriptions. The standalone
  `workspace-search-schema.graphql` is a separate extension; `Taskfile.yml`'s
  `design:search-check` shows the repaired-action composition.
- Planning `long-location-actions-k167` consumes the reconciled design next.
  Native/public/binary/signed-VM acceptance remains that planning chain's work.

## Done when

- Classify R1 against its exact evidence. Apply the actionable correction or
  record a supported dismissal in the running log.
- Make refusal guarantees stage-specific without changing shapes, enums,
  error kinds, capabilities, the settled hand-off bound or independent
  1.0.0 / action-repair 1.0.1 / search 1.1.0 profiles. An over-limit target gets
  no discovery read; a refused discovered application may have the discovery
  read required to learn its location and gets no subsequent pathname metadata
  or domain request. Preserve the no-domain-request guidance.
- Reconcile any affected current-state explanations/composed contract and
  planning's existing L subjects, distinguishing necessary discovery from
  forbidden subsequent calls. Preserve the review's supported short-path,
  candidate, cycle, name-limit, permission, reveal-root and nil semantics.
- Verify the correction through applicable deterministic Taskfile design checks;
  record the results without promoting them to runtime acceptance.

## Notes

This is design integration only. Antony's v1 refusal and descriptor-relative
access decision are settled. No new hand-off workaround, long-path application
support, shorter search ceiling, consent, entitlement or signing change is
authorized. First-use search-only prompt behavior remains pending with the
existing requirement to return to Antony if it prompts.

## Decisions (running log)

- Integrating review k169's single finding R1, read from its own commit
  `0753c65f` (`lvstsrkw`) and anchored to k168's `6647c3a6` (`zlnnvywv`); the
  design files are unchanged since. Started on an empty jj change. Antony's v1
  refusal and the descriptor-relative access decision are settled inputs.
- **R1 — real issue, fix the artifact.** Reproduced from the source: the
  appended `workspaceOpenPath` text in
  `docs/design/workspace-action-repair-schema.graphql` groups target,
  `applicationPath` and selected application under "failed before its metadata,
  handler lookup or any request". Retained `OpenPath.swift`
  `selectPathHandler` calls `defaultApplication(toOpen:)` before
  `inspectApplication(at:)`, and the spec's stages 3–4 and its paragraph on
  supplied versus discovered locations put the discovery read before the
  selected application's limit; a default handler's location is unknown until
  that lookup answers. The search 1.1.0 composition (`design:search-check`)
  reads this same file, so one edit reconciles both profiles. Launch's text
  ("chosen or selected … before its metadata or any request") and reveal's
  ("before any Finder request") make no impossible promise and stay unchanged.
- **Scope of the sweep.** Enumerated every current-state mention of the
  hand-off limit outside `.grove/` and the research surveys (glossary, guide,
  search spec handoff and acceptance, workflow trace, boundary record, README,
  sequence note, long-location view and the viewer's captions/summary). All say
  "no (application) request", which stays true. Two viewer texts in
  `diagrams.json` — the long-location caption and the discussion summary — say
  the limit precedes "any pathname call" without "on that location", the same
  over-broad reading R1 names (the default-handler lookup is itself a pathname
  call on the target), so they are qualified too. The D2 view already draws
  discovery before the selected application's limit and is not re-rendered.
- **Applied.** Repair SDL: the open-path appended text keeps "failed before any
  request" for all three locations and adds the stage-specific order — a target
  before its metadata or handler lookup; an `applicationPath` before its
  metadata or registration lookup; a selected application (matching
  registration, preferred copy or default handler) after the lookup that found
  it, before its metadata. The retained 1.0.0 prefix, shapes, enums, error
  kinds, capabilities, the 1,023/1,024 bound and the three profiles are
  untouched. Spec "Subjects and versions" L now names an over-limit target with
  zero metadata/handler/registration/Finder reads, an over-limit
  `applicationPath` with no metadata or registration read of it, and an
  over-limit discovered application or default handler with exactly its
  discovery read and then no metadata read or submission. `diagrams.json`'s
  long-location caption and discussion summary qualify the limit as "before any
  pathname call on its location, a discovered application's after the read that
  found it". Planning k167's context carries the same correction and names this
  integration. Short-path, candidate, cycle, name-limit, permission, reveal-root
  and nil semantics are unchanged.
- **No in-session reviewer spent.** The correction aligns one description with
  stage text k169 already checked and accepted; nothing new or unexpected is
  claimed.
- **Checks (design only, not runtime acceptance).** Subject digests taken after
  the last edit and re-verified after the runs (repair, retained workspace,
  search and desktop SDLs, `diagrams.json`, action spec: all unchanged).
  `task design:action-repair-check` (with its `design:workspace-check`
  dependency: three appended descriptions with the retained prefix, unchanged
  shape, examples valid, unchanged-baseline control rejected),
  `task design:search-check` (repaired-action composition, controls rejected)
  and `task check:docs` all exit 0 under `pipefail`; `diagrams.json` parses.
  Sweep: "handler lookup or any request" now occurs only in `.grove/` history
  (cross-tree control); every remaining "before any pathname call" is
  qualified by its location, and the unqualified k167 occurrence was seen
  dirty before its fix. No render was needed: no D2/PlantUML source changed and
  the viewer reads captions from `diagrams.json` at runtime.
