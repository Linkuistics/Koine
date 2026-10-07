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
  from the design as that chain leaves it.
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
