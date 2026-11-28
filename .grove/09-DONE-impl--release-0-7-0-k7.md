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

## Decisions (running log)

**The release commit (2026-11-28).** The release commit is `fd068696`,
"Release 0.7.0: Koine sends chords to apps and switches Mission Control
desktops". It changes only the two version keys of `App/Info.plist`, as the
0.6.0 commit did. No other file pins the version.

**The notarised bundle (2026-11-28).** `task app` built and signed the bundle.
`task check:provider-catalogue` and `task check:minimum-os` passed. Apple
accepted submission `8b24ab1d-9095-4601-a6f3-3a7306eb91dd`, and the ticket is
stapled. `task app:verify` passed with the assessment "Notarized Developer ID".

The CDHash is `0ba3f05279d5d8ed08276de753ed79392b375bd0`. The zip SHA-256 is
`36135803f9716f91e747f1c80dd546416a489da847bb119db6d78f039e41165b`. A copy of
the zip is in `.build/release-0.7.0`, because `task app` re-signs the bundle and
drops the staple.

**The release checks (2026-11-28).** Six VM checks run on the notarised
bundle, as for 0.6.0. `app:vm-verify-app-input` accepts the shipped build of
the new feature, in place of the pointer and media check. The other five are
`app:vm-verify-release`, `app:vm-verify-grant-workflows`,
`app:vm-verify-notarized`, `app:vm-verify-disclosure` and
`app:vm-verify-menu-bar`. At most two clones run at once, and the leaf names
each clone `koine-070-<check>`.

**The release platform check (2026-11-28).** `task app:vm-verify-release`
(`release-20261128T192106.log`, clone `koine-070-release`) passed on the
notarised bundle. The transcript reports no NOT RUN step. The bundle had the
recorded CDHash before and after the run, and both zips had the recorded
SHA-256.

**The grant workflow check (2026-11-28).** `task app:vm-verify-grant-workflows`
(`grant-workflows-20261128T192704.log`, clone `koine-070-grant-workflows`)
passed on the notarised bundle, with no NOT RUN step. The bundle had the
recorded CDHash before and after the run, and both zips had the recorded
SHA-256.

**The notarised check (2026-11-28).** `task app:vm-verify-notarized`
(`notarized-20261128T193218.log`, clone `koine-070-notarized`) passed, with no
NOT RUN step. Gatekeeper accepted the quarantined 0.7.0 bundle at first launch.
Its bundled desktop 1.0.2, input 1.0.0 and workspace 1.0.2 were `ACTIVE`.
Apple accepted the fixture provider as submission
`e8f52bb7-8838-47ca-b9ad-7fe8d20b6763` for this run. The bundle had the
recorded CDHash before and after the run, and both zips had the recorded
SHA-256.

**Disclosure attempt 1 failed on a stale assertion (2026-11-28).**
`disclosure-20261128T193515.log` (clone `koine-070-disclosure`) stopped at the served
set. The script required exactly the two desktop and the two workspace
disclosures, and 0.7.0 also serves the two input disclosures. The served input
texts equal the rows of "Capability disclosures" in the machine contract. So
the defect is in the check, and Koine serves the right set. `input-keystrokes-k4` added
the input disclosures and left this check alone.

The repair widens the expected set to six capabilities, as `window-geometry-k3`
widened it for desktop. The script still checks the workspace and desktop
texts in the window. `app:vm-verify-app-input` checks the input texts there.
On the served answer of attempt 1, the new assertion reads true. It reads false
when `input:read` is removed. `bash -n`, `shellcheck` and `shfmt` pass.

**The disclosure check (2026-11-28).** Attempt 2 of `task app:vm-verify-disclosure`
(`disclosure-20261128T193631.log`, clone `koine-070-disclosure-2`) passed on
the notarised bundle with the repaired script, with no NOT RUN step. The bundle
had the recorded CDHash before and after the run, and both zips had the
recorded SHA-256.

**The menu-bar check setup (2026-11-28).** Each attempt of
`task app:vm-verify-menu-bar` sets `KOINE_VM_BASE=testanyware-golden-macos-27`,
as the 0.6.0 attempts did. It also sets the resolved paths of the TestAnyware
CLI and of `jq` 1.8.2 from Homebrew. The scenario sends no VM stop, so the
caller stops the clone after the run.

**Menu-bar attempt 1 refused before transport (2026-11-28).** Attempt 1
(`menu-bar-20261128T193923`) passed the Homebrew symlink paths of the tools.
The scenario requires a regular file, so it refused before any clone existed. It
sent no transport. Attempt 2 passes the Cellar paths of TestAnyware 3.0.0 and
`jq` 1.8.2.

**Menu-bar attempt 2 (2026-11-28).** Attempt 2 (`menu-bar-20261128T193942`,
clone `koine-070-menu-2`) ran on the notarised bundle. The scenario exited 0
with "PASSED", and the transcript reports no NOT RUN step. The guest restart
and the login launch passed, and the caller stopped the clone. The bundle had
the recorded CDHash before and after the run, and both zips had the recorded
SHA-256.

**The app input check (2026-11-28).** `task app:vm-verify-app-input`
(`app-input-20261128T192102.log`, clone `koine-070-app-input`) passed on the
notarised bundle, in a clone of `koine-launchers-prepared` with macOS 27.0.1
(26A434). All 24 rows passed, and each app acted on each chord.

Safari opened a
tab in the background, while TextEdit kept its text and stayed in front.
Control-2 left Desktop 1 current. The Space switch reached Desktop 2,
returned, and refused with the shortcut off. No dialog appeared, and the
restart kept the grants and their input disclosures. The bundle had the
recorded CDHash before and after the run, and both zips had the recorded
SHA-256. The repository keeps the transcript in `docs/verification/app-input-vm/`.

So all six release checks pass on the notarised 0.7.0 bundle. The app input
check ran on macOS 27.0.1 (26A434), and the other five on macOS 27.2.1
(26B131), with TestAnyware 3.0.0.

**Publishing (2026-11-28).** Antony saw the issue titles and the publishing
plan, and he chose "Publish all (Recommended)". The leaf files three issues and
adds the four Dia rows to #7. Then it publishes the tag `v0.7.0` on
`fd068696`, the GitHub release and the cask update, and it upgrades the local
installation without opening it. After `task app:vm-verify-homebrew` passes, it
ticks "App input" in #11. The other choices were the release without the cask,
the issues alone, or no publishing yet.

Antony also chose "File it (Recommended)" for the TestAnyware defect. So the
leaf files one issue in `Linkuistics/TestAnyware`. The other choice kept the
finding in the Koine VM record only.

**The issues (2026-11-28).** The leaf filed three issues. #35 holds the other 11 rows of Zed,
Zotero and Obsidian, and #36 the check with two monitors and a full-screen app.
#37 holds a shortcut setting that macOS has not applied. A comment on #7 adds the four
Dia rows to the account gate. `Linkuistics/TestAnyware` #15 holds the Vision
read that fails with no sign.

**Published (2026-11-28).** `jj tag set` and `jj git push --tag v0.7.0`
published a lightweight tag on `fd068696`, as for 0.6.0. The GitHub release
"Koine 0.7.0" has the zip, and GitHub reports the recorded SHA-256 for it. Its
notes link #35, #7, #36 and #37 for the limits. The cask commit `0c1d3e9` in
`Linkuistics/homebrew-taps` changes only the version and the SHA-256. The tap
uses Git Credential Manager, so the fetch and the push passed `gh` as the
credential helper for those commands only.

`brew upgrade --cask linkuistics/taps/koine` replaced 0.6.0 with 0.7.0 in
`/Applications`. The installed bundle has the recorded CDHash, and Gatekeeper
accepts it as "Notarized Developer ID". Koine was not running, so the upgrade
quit nothing, and the leaf did not open it.

**The published cask (2026-11-28).** `task app:vm-verify-homebrew`
(`homebrew-20261128T202026.log`, clone `koine-070-homebrew`) passed on the
published cask, with no NOT RUN step. Homebrew installed 0.7.0 with its
quarantine intact, Gatekeeper accepted it as notarised, and Koine launched and
served. The uninstall and `--zap` removed it.

**Issue 11 (2026-11-28).** The leaf ticked "App input" in #11 and changed
nothing else in the body. It sent the body through the API, and the stored body
equals the intended body byte for byte.

**The documents (2026-11-28).** `docs/verification/app-input-vm.md` gains the
section "Release checks on the notarised bundle" and keeps the 0.7.0 app input
transcript. Its non-claims name #7, #35, #36 and #37, and the non-claim of a
notarised bundle is gone. The README names 0.7.0 as the notarised release for
its six release checks. It also gains the sentence that links the two app input
records, as for pointer and media.

The trace rows of Zed, Obsidian and Zotero in
`docs/specs/workflow-providers.md` link #35. Those rows sit in a `pending`
region, and the checker finds no hard finding in them.

`workspace-disclosure-vm.md` stays as it is. It records the 0.4.0 run, and the
0.5.0 and 0.6.0 releases also left it alone. A sweep for an unnamed issue in
`docs` and the README is clean. The same search finds the Zed row before the
edit and the design leaf in `.grove/`.

`task check:docs` reports only the link of #22. A copy of the README with a
broken anchor made the check fail, so the check reads the new anchor.
