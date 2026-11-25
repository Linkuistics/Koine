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

## Decisions (running log)

The release commit is `1088ce07`, "Release 0.4.1: Koine requests activation
before it shows the Settings window". It changes only the two version keys of
`App/Info.plist`, as the 0.4.0 commit `8429aecd` did. No other file pins the
version.

`task app` built and signed the 0.4.1 bundle. `task app:notarize` then stopped
before any upload. The keychain holds no notary profile `koine-notary`, and the
probe outside the sandbox gives the same result. The credential belongs to
Antony, so the leaf waits for Antony to store it or to name another profile.

Antony reported that the profile already existed. A third probe, inside and
outside the sandbox, found it and received the submission history. The cause of
the two earlier failures is unknown. The leaf notarises the bundle that `task app`
built, with no rebuild.

The leaf filed the four follow-up issues:

- #16, the TextEdit quit race.
- #17, the lost restart reply.
- #18, the Finder window at first launch.
- #19, the reliability study of both call orders.

Antony agreed to them in the plan. They do not
depend on the result of the release.

Antony closed issue #14 on 2026-11-24, before the plan of this grove. This leaf
does not change it.

Apple accepted submission `a55c021b-7554-40e6-a60b-5964b9caed3f`. The ticket is
stapled, and `task app:verify` passed with the assessment "Notarized Developer
ID". The CDHash is `70b6c044f60cdc3847a77bd871347edb8069d938`. The zip SHA-256 is
`93a0d04757f2cb8e43f19ff579971a316cd4dedb705becc4705088b0f7008094`. A copy of the
zip is in `.build/release-0.4.1`, because `task app` re-signs the bundle and
drops the staple.

Each menu-bar attempt clones `testanyware-golden-macos-27` with its own clone
name, `koine-041-menu-<n>`. The scenario sends no VM stop, so the caller stops the
clone after each attempt.

The scenario needs `KOINE_TESTANYWARE_CLI` and `KOINE_JQ`, the absolute paths of
the executables. The first invocation did not set them. It stopped before the
evidence root existed. It made no clone and sent no transport, so it is not an
attempt. Each attempt sets both to the resolved paths under
`/opt/homebrew/Cellar`.

Attempt 1 (`menu-bar-20261125T165452`, clone `koine-041-menu-1`) stopped in the
setup before the first selection. No Settings selection ran. The new focus check
of k2 passed, and so did the window and sheet checks. The `menu-bar-menus` read
then named one menu under each TextEdit item and the menu "Koine" under the Koine
item. The predicate requires none. The failure screenshot shows no open menu.

The cause is the oracle of the test, not Koine. System Events names the menu of
a closed menu bar item. The comment on the read in `scripts/vm_exec_reads.py`
says that no Apple source states when an item exposes its menu. It says that E01
was to qualify the oracle on a real guest. E01 stopped at the earlier front read,
so this attempt is the first real run of the read.

The closed-menu check after each selection reads `koine-menus` with the same
assumption. So a rerun stops at the same read, and no attempt can pass while
both reads stay. The leaf counts attempt 1 and asks Antony before attempt 2.

**Menu oracle (2026-11-25).** Antony chose to replace both menu checks with
another signal. A diagnostic guest qualifies the signal before attempt 2. The
other choices were to remove both checks, or to stop with nothing shipped.

The leaf inserted `settings-menu-oracle-k5` ahead of itself. The oracle repair
is a separate slice, with its own guest run, grammar change, tests and documents.
This leaf stays live with every condition unchanged. One of its three attempts
is used. Attempt 2 runs on the same notarised bundle after k5 retires.
