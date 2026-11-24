# release-0-4-1-k4

## Goal

Release Koine 0.4.1 with the activation-first Settings call order. One clean run
of the menu-bar check on the notarised bundle must accept it first.

## Context

- The 0.4.0 release commit `8429aecd` changed only the version in
  `App/Info.plist`. The commits of `release-0-4-0-k5` show the rest of that
  release.
- `task app:notarize` notarises, staples and zips the bundle. `task app:verify`
  checks the signature, the ticket and the Gatekeeper assessment.
- The release VM checks include `task app:vm-verify-release`,
  `task app:vm-verify-grant-workflows` and `task app:vm-verify-menu-bar`.
  `task app:vm-verify-homebrew` checks the published cask.
- The cask is in the `Linkuistics/homebrew-taps` repository.
- GitHub issue 14 records the failures of the menu-bar check on 0.4.0.

## Done when

- The bundle carries version 0.4.1. It is signed, notarised and stapled.
- One clean run of `task app:vm-verify-menu-bar` on the notarised bundle accepts
  the candidate, within at most three attempts.
- Each other release VM check passes. A failure with a cause outside the happy
  path gets a GitHub issue instead.
- After Antony approves, the `v0.4.1` tag, the GitHub release and the cask update
  exist. `task app:vm-verify-homebrew` then passes on the published cask.
- `docs/verification/menu-bar-vm.md` and the spec record the acceptance run and
  its limit.
- Issue 15 is closed with the outcome.
- Four new issues exist. They cover the TextEdit quit race, the lost restart
  reply, the Finder window at first launch and a reliability study of both call
  orders.

If the candidate fails a Settings return, these conditions replace the publishing
conditions above:

- The show path is back in the released order, and nothing ships.
- Issue 15 records the result and stays open.
- The four follow-up issues exist.

## Notes

A clean run passes every assertion of the check, apart from a resize that the
script reports as NOT RUN. A stop or failure with a cause in the harness, the
guest, TextEdit or the test driver is not a Koine failure. In that case, run the
check again. After three attempts without a clean run, ask Antony.

Ask Antony before the tag, before the GitHub release and before the cask update.
Each of these steps publishes.

The release notes state the change and its limit. One clean run passed, and the
notes make no claim that the intermittent symptom is gone.
