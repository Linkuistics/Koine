# release-0-6-0-k6

## Goal

Release Koine 0.6.0 with pointer and media through the Homebrew cask.

## Context

- The precedent is the commit of `release-0-5-0-k7`. It shipped Koine 0.5.0
  after six release checks on the notarised bundle and filed the deferred
  issues.
- The section "Release checks on the notarised bundle" of
  `docs/verification/desktop-window-layout-vm.md` shows the checks.

## Done when

- The version is 0.6.0, and the bundle is notarised. The release checks pass
  on the notarised bundle.
- The tag and the GitHub release exist, the cask is bumped, and the Homebrew
  check passes.
- The pointer and media checkbox in issue 11 is ticked.
- Each case that acceptance deferred is a GitHub issue. So is each review
  finding that does not break the happy path.

## Notes

- The human approves each public step: the tag, the release, the cask bump
  and each issue.
- One issue comes from the integration `pointer-media-k8`. In desktop 1.0.1,
  `desktopFocusDisplay` posts its mouse-moved event under the Accessibility
  check alone, without `CGPreflightPostEventAccess`.
- The acceptance `pointer-media-acceptance-k5` defers these cases. Each one
  is a candidate issue, as "What this does not claim" in
  `docs/verification/desktop-pointer-media-vm.md` states it:
  - A witness that a hidden pointer becomes visible again after the nudge.
    Antony chose to release with this limit and to file the issue.
  - The refusal of the nudge while a pointer button is held, in a VM. Only
    the L tests cover it.
  - The media keys with a player other than Music.
  - An upgrade from an installed Koine 0.5.0. A restart stands in for it.
  - A managed Mac that allows Accessibility and denies `PostEvent`.
  - Issue #23 already holds the checks with two screens.
- `task check:docs` fails on one old link, outside this grove:
  `docs/verification/settings-activation/ORDERING-PROVENANCE-RESULTS.md`
  links to a task file of a removed grove tree.
