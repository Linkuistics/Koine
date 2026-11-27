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

## Decisions (running log)

**The release commit (2026-11-26).** The release commit is `8cb2d75e`,
"Release 0.5.0: Koine lists windows and displays, sets a window's frame and
focuses a display". It changes only the two version keys of `App/Info.plist`,
as the 0.4.0 and 0.4.1 commits did. No other file pins the version.

**The notarised bundle (2026-11-26).** `task app` built and signed the bundle.
`task check:provider-catalogue` and `task check:minimum-os` passed. Apple
accepted submission `fce5556e-0bfa-4d2a-a997-46709761e93f`, and the ticket is
stapled. `task app:verify` passed with the assessment "Notarized Developer ID".

The CDHash is `13b4f8eba7d169b5fcfc446051f1d28ca20a76bf`. The zip SHA-256 is
`6db4d9f57b1bae5330749331f902127fb464284fb508239ab77388a02059366c`. A copy of
the zip is in `.build/release-0.5.0`, because `task app` re-signs the bundle and
drops the staple.

**The release checks (2026-11-26).** Six VM checks run on the notarised bundle.
The README names `app:vm-verify-release` and `app:vm-verify-grant-workflows` as
release acceptance.

`app:vm-verify-window-layout` accepts the shipped build of
the new feature. `app:vm-verify-notarized` loads the changed bundled desktop
provider under Gatekeeper. `app:vm-verify-disclosure` reads the desktop
disclosures in the window. `app:vm-verify-menu-bar` follows the 0.4.1 precedent.

At most two clones run at once. The leaf names each clone `koine-050-<check>`.

**The issues (2026-11-26).** The tree defers six issues. The leaf names four:
the two-display check, the display-focus click with input control, the partial
window list and the Dock bar limit. Two test failures from `window-stacking-k4`
to `window-layout-acceptance-k6` wait for the release leaf or the human. They
are the macOS 27 wording of `ENAMETOOLONG` and the short-deadline grant setup.

No review finding stays open. `window-layout-k9` repaired F1 to F4, and the
leaves k4, k5 and k6 ran no adversarial review. The race that F1 leaves between
the second button check and the move is a stated trade-off in the contract.

Modaliser clicks on the desktop only for a display with no window
(`WindowManipulator.focusDisplay`). The click issue states that, not a click
after each move.

**The window layout check (2026-11-26).** `task app:vm-verify-window-layout`
(`window-layout-20261126T233721.log`, clone `koine-050-window-layout`) passed on
the notarised bundle. After the run, the bundle had the recorded CDHash, and
both zips had the recorded SHA-256. Display focus raised the front TextEdit
window and moved the pointer to 960, 540, the centre of the display. The grant
rows kept both desktop disclosures after a restart, and no grant changed.

**The release platform check (2026-11-26).** `task app:vm-verify-release`
(`release-20261126T233722.log`, clone `koine-050-release`) passed on the
notarised bundle. The transcript reports no NOT RUN step. The Finder repair of
`release-0-4-1-k4` held, so the step with two Finder windows of one title passed.

**The grant workflow check (2026-11-26).** `task app:vm-verify-grant-workflows`
(`grant-workflows-20261126T234051.log`, clone `koine-050-grant-workflows`)
passed on the notarised bundle, with no NOT RUN step. Both release acceptance
checks now pass on 0.5.0.

**The notarised check (2026-11-26).** `task app:vm-verify-notarized`
(`notarized-20261126T234322.log`, clone `koine-050-notarized`) passed. Gatekeeper
accepted the quarantined 0.5.0 bundle at first launch, and its bundled desktop
provider 1.0.1 loaded. Apple accepted the fixture provider as submission
`f0fa0012-85c6-403c-bf96-02e5cd6e98aa` for this run.

**The menu-bar check setup (2026-11-26).** The first invocation of
`task app:vm-verify-menu-bar` set no `KOINE_VM_BASE`. It stopped with status 125
before a clone existed, so it is not an attempt. Each attempt sets
`KOINE_VM_BASE=testanyware-golden-macos-27`, as the 0.4.1 attempts did, and the
resolved paths of the CLI and `jq`.

**The disclosure check (2026-11-26).** `task app:vm-verify-disclosure`
(`disclosure-20261126T234550.log`, clone `koine-050-disclosure`) passed on the
notarised bundle, with no NOT RUN step. The k6 run of this check used a build
without the Dock bar rule. This run used the shipped build.

**Menu-bar attempt 1 (2026-11-26).** Attempt 1 (`menu-bar-20261126T234715`,
clone `koine-050-menu-1`) ran on the notarised bundle. The caller stopped the
clone. The scenario exited 125 at the guest restart, before the login-launch
assertions.

Every earlier assertion passed. They include the four Settings
selections and the anchored drag to 703 by 903 and back to 440 by 352. They also
include the shortcuts, the client requests, the consent, the silent launch, the
reopen and the Quit with Command-Q.

The restart reply was lost as `CONNECTION_DROPPED` (000702), the form that k8
admits. The first boot read came 30 s later and got `CONNECTION_REFUSED` from the
agent (000703). The helper counts a refused read as unavailable at once, by
design. The failure screenshot (000704) has the session from before the
restart, with the "Login Item Added" notice. So the guest took longer than the
30-second wait to shut down. In 0.4.1 attempt 7, it was back within the wait.

The cause is the harness timing, not Koine. `app:vm-verify-release` already
passed the login launch across a VM restart on this bundle. The leaf follows the
0.4.1 rule. After a harness stop, it runs the check again. After three attempts
without a clean run, it asks Antony.

**Menu-bar attempt 2 (2026-11-27).** Attempt 2 (`menu-bar-20261126T235519`,
clone `koine-050-menu-2`) ran on the same notarised bundle. Both zips had the
recorded SHA-256 before and after the run, and the CDHash matched. The caller
stopped the clone. The scenario exited 0 with "PASSED", and the transcript
reports no NOT RUN step.

The restart reply was lost as `CONNECTION_DROPPED` again (000704). The first
boot read after the wait (000705) found a changed boot record, from 1795697721
to 1795698116, so the restart counted. Each later assertion passed, through the
login launch and the final Quit from the menu.

So all six release checks pass on the notarised 0.5.0 bundle, on macOS 27.2.1
(26B131) with TestAnyware 3.0.0. A refused boot read after the 30-second wait
stopped attempt 1. That is a sibling of the lost reply in #17, so the leaf
proposes a comment on #17 instead of a new issue.

**Publishing (2026-11-27).** Antony saw the final disclosure text and approved
every public step. The leaf files the six issues and the comment on #17. Then it
publishes the tag `v0.5.0` on `8cb2d75e`, the GitHub release and the cask update,
and upgrades the local installation. After `task app:vm-verify-homebrew` passes,
it ticks "Window layout" in #11. The other choices were fewer issues, the tag and
the release without the cask, or no publishing yet.

**The issues (2026-11-27).** The leaf filed #23 (two displays), #24 (the
display-focus click), #25 (the partial window list), #26 (the Dock bar limit),
#27 (the macOS 27 wording of `ENAMETOOLONG`) and #28 (the short-deadline grant
setup). The comment
https://github.com/Linkuistics/Koine/issues/17#issuecomment-7207537697 records
the refused boot read of attempt 1.

**Published (2026-11-27).** `jj git push --tag v0.5.0` published a lightweight
tag on `8cb2d75e`, as for 0.4.1. The GitHub release "Koine 0.5.0" has the zip,
and GitHub reports the recorded SHA-256 for it. Its notes link #23 and #26 for
the two limits. The cask commit `f298a836` in `Linkuistics/homebrew-taps`
changes only the version and the SHA-256.

`brew upgrade --cask linkuistics/taps/koine` replaced 0.4.1 with 0.5.0 in
`/Applications`. The installed bundle has the recorded CDHash, and Gatekeeper
accepts it as "Notarized Developer ID". Koine was not running, so the upgrade
quit nothing, and the leaf did not launch it.

**The published cask (2026-11-27).** `task app:vm-verify-homebrew`
(`homebrew-20261127T124543.log`, clone `koine-050-homebrew`) passed on the
published cask. Homebrew installed 0.5.0 with its quarantine intact, Gatekeeper
accepted it as notarised, and Koine launched and served. The uninstall and
`--zap` removed it.

**Issue 11 (2026-11-27).** The leaf ticked "Window layout" in #11 and changed
nothing else in the body.

**The documents (2026-11-27).** `docs/verification/desktop-window-layout-vm.md`
gains the section "Release checks on the notarised bundle" and keeps the 0.5.0
window layout transcript. Its non-claims link #23 and #26, and the non-claim of
a notarised bundle is gone. The README names 0.5.0 as the notarised release for
its six release checks. The spec opening stays in its `pending` region.

`task check:docs` reports only the link of #22. A copy of the README with a
broken anchor made the check fail, so the check reads the new anchor.
