# release-0-5-0-k7

## Goal

Release Koine 0.5.0 through the Homebrew cask, and file the issues that this
grove deferred.

## Context

- The leaves `release-0-4-0-k5` and `release-0-4-1-k4` in the history hold
  the release steps and their Taskfile tasks.

## Done when

- The version is 0.5.0. The build is notarised, its release checks pass on
  the notarised build, and it is tagged.
- The GitHub release is published, the cask is bumped, and the Homebrew check
  passes.
- The release notes state the one-display limit.
- GitHub issues exist for the two-display check and for the display-focus
  click with input control.
- Each review finding that does not break the happy path is a GitHub issue.
- A GitHub issue exists for a partial window list. Today one application that
  does not answer fails the whole list (`window-geometry-k3`).
- The window layout checkbox in issue 11 is ticked.

## Notes

- The human approves each public step: the tag, the GitHub release, the
  cask, the issues and the edit to issue 11.
- The human sees the final disclosure text before publishing.
- File a third issue for the limit of the Dock bar rule
  (`window-layout-acceptance-k6`). A magnified Dock or a Dock folder stack
  draws inside the visible frame, so the point query can answer `ON_TOP` where
  the Dock hides the window. The contract section "Visibility at a point"
  states the limit.
