# long-location-actions-k167

## Goal

Cut the implementation and acceptance leaves for the reviewed v1 long-location
action contract in launch-and-open: descriptor-relative location resolution in
the workspace native adapter, the application hand-off limit refusal, the
action-only release/schema 1.0.1 and its independent subjects.

## Context

- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`
  (resolution table, hand-off limit, walk obligations, subjects and versions)
  and `docs/adr/filesystem-access-is-descriptor-relative.md`.
- Review long-search-result-actions-k166 and any integration it earned; plan
  from the design as that chain leaves it, including re-review
  long-search-result-actions-k169 of integration k168 and any integration it
  earns. Integration k168 counts pathname bytes without the NUL (1,023 handed
  over, 1,024 refused); orders a target stage before a supplied or discovered
  application stage, with each location's limit before any pathname call on it
  and never on an unequal registered candidate; keeps retained
  application-location, candidate and Finder outcomes; and adds subjects the
  spec's "Subjects and versions" now lists: 31/32/33-link and self-extending
  chains, a containing-directory cycle state, ASCII-only impossible names beside
  extant multibyte/combining names, a final directory without search permission,
  reveal's `lstat` root rule with and without a trailing slash, and registered
  candidates before and after the match at L.
- Integration long-search-result-actions-k170 made the open-path SDL's refusal
  stage-specific: an over-limit target gets no metadata or discovery read, an
  over-limit `applicationPath` no metadata or registration lookup, and an
  over-limit discovered application (preferred copy or default handler) is
  refused after the discovery read that found it, with no metadata read or
  submission. The spec's L subjects check those counts; "no request" means no
  domain request, never zero reads.
- `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`
  for the retained 1.0.0 / repair 1.0.1 / search 1.1.0 profile split.
- The shipped adapter's `inspectPath`/`inspectApplication` use `realpath`/`stat`
  and map ELOOP/ENAMETOOLONG to absence; that is the defect being replaced.

## Done when

- Leaves are vertical slices through L, N, G and V that each leave Koine
  working, covering every subject the spec's "Subjects and versions" lists,
  including first-use prompt-free resolution in Desktop, Documents and
  Downloads. If that resolution prompts, the slice stops and goes to Antony;
  no whole-path fallback.
- Retained 1.0.0 binaries, SDL and profile stay independent of 1.0.1.
  Actual-search handoff rows stay with app-and-file-search.
- Reusable build/fixture/VM steps land in `Taskfile.yml`.

## Notes

Long-path application support itself is out of scope (Linkuistics/Koine#1).

## Decisions (running log)

- **Cut by stage and operation.** The spec orders target, supplied application,
  discovered application. Each stage leaf replaces whole-path inspection for one
  stage and runs at L, G and N, so each is a working increment. The walk itself
  lands with reveal, whose planner is smallest and which owns the root rule; open-path
  adds its payload refusal on the same walk.
- **Retention first.** A workspace 1.0.0 binary can be kept only before the
  provider source changes, so `retained-workspace-baseline` is leaf 1. The existing
  baseline revision, `v0.1.0`, has no workspace provider, and `current-workspace` in
  the selection fixtures is built from this tree.
- **The prompt question is measured inside leaf 2, first.** A separate gate leaf
  would be evidence without behaviour, and the walk is the thing to measure. The
  leaf's first done-when item stops it on a prompt; V repeats the check in the
  signed app.
- **Release after behaviour.** The repair SDL's descriptions state behaviour, so
  1.0.1 is packaged after the three stage leaves, not with the first. The cost is
  that the served schema says 1.0.0 while behaviour is corrected, which is not a
  contract change (shapes, enums and error kinds are unchanged).
- **V after the release.** Acceptance is of the signed 1.0.1 bundle. The earlier
  prompt measurement bounds the risk that V finds a design-level problem late.
- **What N can observe.** The signed bundle on the host launches and reveals
  nothing, so present outcomes are tested through shared source or refusals that
  follow resolution. Said in the node brief and `reveal-locations`.
- **Review cut.** `review-planning` k171 is placed before the node, as k81 was,
  so it runs first; its integration, if any, is inserted before the node by the
  review.
- **Not cut:** per-leaf `review-impl` chains (earned reactively); search handoff
  (stays with `app-and-file-search`).
