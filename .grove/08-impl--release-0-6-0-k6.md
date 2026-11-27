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
