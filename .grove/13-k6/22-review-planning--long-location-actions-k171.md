# long-location-actions-k171

**Reviews:** long-location-actions-k167
**Creator:** run d213efd4-5588-4bb4-9473-736d02a5f1ce

## Goal

Adversarially read `long-location-actions-k167`'s cut of the v1 long-location
action contract before any of it runs. Produce findings, not fixes.

## Context

- `long-location-actions-k167`'s commit, its decisions log, the new node
  `long-locations-k172`, its brief and its nine leaves, and the one paragraph
  added to the `launch-and-open-k6` brief.
- What the cut must cover, tested against the sources rather than against
  the node brief's own table:
  - `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`,
    every bullet of "Subjects and versions" and the two acceptance rows added
    for it;
  - `docs/adr/filesystem-access-is-descriptor-relative.md`;
  - `docs/verification/long-action-native-boundary.md#compatibility-and-implementation-obligations`;
  - the k6 brief's integrations k168 and k170, and the long-location paragraphs
    of the `Design handoff` section.

## Done when

Each finding is recorded with the leaf or brief it concerns, or the review
states that it found none. An integration step is cut only if a finding is worth
acting on.

## Notes

These are the doubts the producer could not settle alone:

- Does every L, N, G and V bullet of "Subjects and versions" have exactly one
  named owning leaf, and is each owner able to observe it at that seam? In
  particular the real walk's *present* outcomes cannot be seen through a signed
  bundle on the host without opening or revealing something: the cut assumes a
  shared-source walk tested directly plus refusals that follow resolution. Is
  that an honest N, or does it quietly turn N into L?
- The first-use prompt question decides whether the ADR stands. The cut measures
  it inside the first walk leaf, before the rest of that leaf is built, and again
  in the signed app at V. Is that early enough, and is the stop rule (a prompt
  returns to Antony, no whole-path fallback) written where the executing session
  will meet it?
- The retained 1.0.0 workspace bundle must exist before any source change. Does
  `retained-workspace-baseline` really precede every leaf that edits the provider,
  and does its way of retaining the binary avoid the "rebuilt or relabelled
  baseline" the spec rules out?
- Each stage leaf leaves Koine working, but the 1.0.1 schema descriptions are
  appended only after all three stage leaves. Between them the served schema
  still says 1.0.0 while behaviour is already corrected. Is that a justified
  ordering, or should the release come earlier?
- `reveal-locations` carries the whole walk, every resolution row and the reveal
  limit. Is it more than one session at a seam the cut missed? So are
  `action-repair-release` and `action-repair-compat`, which re-pin the selection
  and conformance fixtures from workspace 1.0.0 to 1.0.1.
- Is the order right with respect to the consumers outside this node:
  `app-and-file-search` (k30/k120/k123) and the root leaves
  `baseline-acceptance-k17`, `protected-default-open-k89`,
  `reveal-app-bundle-notice-k90` and `protected-home-search-k93`? Does anything
  there still assume the 1.0.0 `ELOOP`/`ENAMETOOLONG`-as-absence mapping?

## Decisions (running log)
