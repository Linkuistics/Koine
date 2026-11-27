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

## Decisions (running log)

**The release commit (2026-11-27).** The release commit is `e937db51`,
"Release 0.6.0: Koine reads the pointer position, nudges the pointer and posts
six media keys". It changes only the two version keys of `App/Info.plist`, as
the 0.5.0 commit did. No other file pins the version.

**The notarised bundle (2026-11-27).** `task app` built and signed the bundle.
`task check:provider-catalogue` and `task check:minimum-os` passed. Apple
accepted submission `4244d9d7-8c00-4bbf-8260-551a69c4a031`, and the ticket is
stapled. `task app:verify` passed with the assessment "Notarized Developer ID".

The CDHash is `92f25cc9dfeff4870904b3db32faeb95159571a7`. The zip SHA-256 is
`14f7d94cd400bf38d50c3fda9013f8ecb0ebdc01d9a252e634becdc53a410600`. A copy of
the zip is in `.build/release-0.6.0`, because `task app` re-signs the bundle and
drops the staple.

**The release checks (2026-11-27).** Six VM checks run on the notarised
bundle, as for 0.5.0. `app:vm-verify-pointer-media` accepts the shipped build
of the new feature, in place of the window layout check. The other five are
`app:vm-verify-release`, `app:vm-verify-grant-workflows`,
`app:vm-verify-notarized`, `app:vm-verify-disclosure` and
`app:vm-verify-menu-bar`. At most two clones run at once, and the leaf names
each clone `koine-060-<check>`.

**The pointer and media check (2026-11-27).** `task app:vm-verify-pointer-media`
(`pointer-media-20261127T160604.log`, clone `koine-060-pointer-media`) passed on
the notarised bundle. The bundle had the recorded CDHash before and after the
run, and both zips had the recorded SHA-256. Koine read the pointer where the
witness read it, at two points.

After the nudge, the pointer was back at its first
position with no button held. Music paused, resumed, went to the next track, restarted
the current track and went to the previous track. Volume and mute changed, and
TextEdit stayed in front. No permission dialog appeared, and the grant rows kept
both desktop disclosures after a restart.

**The release platform check (2026-11-27).** `task app:vm-verify-release`
(`release-20261127T160606.log`, clone `koine-060-release`) passed on the
notarised bundle. The transcript reports no NOT RUN step, and the step with two
Finder windows of one title passed. The bundle had the recorded CDHash after the
run, and both zips had the recorded SHA-256.

**The notarised check (2026-11-27).** `task app:vm-verify-notarized`
(`notarized-20261127T161207.log`, clone `koine-060-notarized`) passed, with no
NOT RUN step. Gatekeeper accepted the quarantined 0.6.0 bundle at first launch,
and its bundled desktop provider 1.0.2 loaded. Apple accepted the fixture
provider as submission `f5bd353e-77fc-47e8-8b2a-f39b37916ca6` for this run.

**The grant workflow check (2026-11-27).** `task app:vm-verify-grant-workflows`
(`grant-workflows-20261127T161114.log`, clone `koine-060-grant-workflows`)
passed on the notarised bundle, with no NOT RUN step. Both release acceptance
checks now pass on 0.6.0.

**The menu-bar check setup (2026-11-27).** Each attempt of
`task app:vm-verify-menu-bar` sets `KOINE_VM_BASE=testanyware-golden-macos-27`,
as the 0.5.0 attempts did. It also sets the resolved paths of the TestAnyware
CLI and of `jq` 1.8.2 from Homebrew. The scenario sends no VM stop, so the
caller stops the clone after the run.

**The disclosure check (2026-11-27).** `task app:vm-verify-disclosure`
(`disclosure-20261127T161457.log`, clone `koine-060-disclosure`) passed on the
notarised bundle, with no NOT RUN step.

**Menu-bar attempt 1 (2026-11-27).** Attempt 1 (`menu-bar-20261127T161620`,
clone `koine-060-menu-1`) ran on the notarised bundle. The scenario exited 0
with "PASSED", and the transcript reports no NOT RUN step. The guest restart
and the login launch passed, and the caller stopped the clone.

So all six release checks pass on the notarised 0.6.0 bundle, on macOS 27.2.1
(26B131) with TestAnyware 3.0.0. After each run, the bundle had the recorded
CDHash, and both zips had the recorded SHA-256.

**Publishing (2026-11-27).** Antony saw the final disclosure text and chose
"Publish all (Recommended)". The leaf files the six issues. Then it publishes
the tag `v0.6.0` on `e937db51`, the GitHub release and the cask update, and
upgrades the local installation. After `task app:vm-verify-homebrew` passes, it
ticks "Pointer and media" in #11. The other choices were the issues, the tag
and the release without the cask, the issues alone, or no publishing yet.

<!-- tc: depart synonym-rotation because "display focus" is the glossary term for the operation, not the verb "show" -->
**The issues (2026-11-27).** The leaf filed six issues. They are #29 (the
hidden pointer reveal), #30 (the refusal with a held button) and #31 (another
player). They are also #32 (the upgrade from 0.5.0), #33 (a Mac that denies
`PostEvent`) and #34 (the posting check of display focus).

**Published (2026-11-27).** `jj git push --tag v0.6.0` published a lightweight
tag on `e937db51`, as for 0.5.0. The GitHub release "Koine 0.6.0" has the zip,
and GitHub reports the recorded SHA-256 for it. Its notes link #29 and #31 for
the two limits. The cask commit `9b946ac3` in `Linkuistics/homebrew-taps`
changes only the version and the SHA-256.

`brew upgrade --cask linkuistics/taps/koine` replaced 0.5.0 with 0.6.0 in
`/Applications`. The installed bundle has the recorded CDHash, and Gatekeeper
accepts it as "Notarized Developer ID". Koine was not running, so the upgrade
quit nothing, and the leaf did not open it.

**The published cask (2026-11-27).** `task app:vm-verify-homebrew`
(`homebrew-20261127T192837.log`, clone `koine-060-homebrew`) passed on the
published cask. Homebrew installed 0.6.0 with its quarantine intact, Gatekeeper
accepted it as notarised, and Koine launched and served. The uninstall and
`--zap` removed it.

**Issue 11 (2026-11-27).** The leaf ticked "Pointer and media" in #11 and
changed nothing else in the body. The first edit added one trailing newline,
and a second edit restored the original bytes.

**The documents (2026-11-27).** `docs/verification/desktop-pointer-media-vm.md`
gains the section "Release checks on the notarised bundle" and keeps the 0.6.0
pointer and media transcript. Its non-claims link #29 to #33, and the non-claim
of a notarised bundle is gone. The README names 0.6.0 as the notarised release
for its six release checks. It also gains the sentence that links the two
pointer and media records, as for window layout.

`task check:docs` reports only the link of #22. A copy of the README with a
broken anchor made the check fail, so the check reads the new anchor.
