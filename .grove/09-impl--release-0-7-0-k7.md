# release-0-7-0-k7

## Goal

Release Koine 0.7.0 with app input through the Homebrew cask.

## Context

- The precedent is the commit of `release-0-6-0-k6`. It shipped Koine 0.6.0
  after six release checks on the notarised bundle, and it filed the deferred
  issues.
- The section "Release checks on the notarised bundle" of
  `docs/verification/desktop-pointer-media-vm.md` lists the checks.

## Done when

- The version is 0.7.0, and the bundle is notarised. The release checks pass
  on the notarised bundle.
- The tag and the GitHub release exist, the cask is bumped, and the Homebrew
  check passes.
- The app input checkbox in issue 11 is ticked.
- One issue holds the other 11 rows of Zed, Zotero and Obsidian. The rows of
  Dia join issue #7, or a new issue holds them.
- Each case that acceptance deferred is a GitHub issue. So is each review
  finding that does not break the happy path.
- The design leaf `app-input-k3` deferred two cases, and each is an issue:
  - A check with two displays and a full-screen app, of how macOS numbers
    the Mission Control desktops against Koine's count.
  - A shortcut setting that macOS has not applied.

## Notes

- Antony approves each public step: the tag, the release, the cask bump and
  each issue.
- `app-input-acceptance-k6` deferred no new case of Koine beyond the list
  above. Its records state what the runs do not claim:
  `docs/verification/app-input-vm.md` and
  `docs/verification/app-input-compatibility.md`.
- That acceptance found a defect of the TestAnyware harness, not of Koine.
  With Koine's Settings window on screen, Apple Vision read whole captures as
  if upside down, and `testanyware screen find-text` found almost nothing. The
  VM record holds the evidence. An issue for the TestAnyware repository is a
  candidate, and Antony decides whether to file it.
