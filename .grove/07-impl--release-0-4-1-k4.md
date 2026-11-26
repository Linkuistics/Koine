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
  the candidate, within at most three attempts or the further attempts that
  Antony allows.
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

**Attempt 2 (2026-11-25).** Attempt 2 (`menu-bar-20261125T212057`, clone
`koine-041-menu-2`) ran on the same notarised bundle. Both zips still had the
recorded SHA-256, and `task app:verify` passed before the run. The caller stopped
the clone. The scenario exited 1 in the setup of `reopen-1`.

The first Settings selection passed. Its setup read TextEdit's window first and
focused, and the size checks of k5 passed. After the selection, the window list
showed one front, focused "Koine Settings" window, and the Koine menu was closed.

The harness then closed the Settings window. In the next window list (step
000111), TextEdit's window came first with `focused: false`. A System Events read
(000117) still named TextEdit as the front application. The failure screenshot
(000119) shows the TextEdit menu bar and a TextEdit window with grey close
buttons. So the k2 read was accurate: no TextEdit window had focus.

The cause is the scenario, not a Settings return. Before the first selection,
the harness closes the window while TextEdit is the active application, and
TextEdit keeps its focused window. Before each reopen, Koine is the active
application, because the selection before it worked. After that close, macOS
leaves TextEdit in front with no focused window. The reopen loop never gives
TextEdit focus again. The old System Events front read passed in this state, so
the 0.4.0 runs could not see it.

Both call orders end with Koine active and its window key. So 0.4.0 most likely
reached the same state. No retained evidence shows a window list at this point
under 0.4.0, so this is an inference. A rerun with no change stops at the same
setup, as attempt 1 did at its read. The leaf counts attempt 2 and asks Antony
before attempt 3. One attempt remains.

**Reopen focus (2026-11-26).** Antony chose to give TextEdit's window focus
before each reopen, with the test driver's `window-focus` action. The setup
check stays as strict as now, and a diagnostic guest qualifies the step before
attempt 3. The other choices were to relax the reopen setups to the old front
read, or to stop with nothing shipped.

The leaf inserted `settings-reopen-focus-k6` ahead of itself. The repair is a
separate slice, with its own guest run, scenario change, tests and documents.
This leaf stays live with every condition unchanged. Two of its three attempts
are used. Attempt 3 runs on the same notarised bundle after k6 retires.

**Attempt 3 (2026-11-26).** Attempt 3 (`menu-bar-20261126T015033`, clone
`koine-041-menu-3`) ran on the same notarised bundle. Both zips still had the
recorded SHA-256, and `task app:verify` passed before the run. The caller stopped
the clone. The scenario exited 1 at the resize, after the four Settings
selections.

All four Settings selections passed, the first and the three reopens. The focus
step of k6 let each reopen setup pass. After each selection, the scenario found
one front, focused Settings window and continued. So the candidate did not fail
a Settings return.

The resize then failed with "the window did not grow". The check needs a grown
frame of at least 690 by 880. The frame was 681 by 884, at 40, 40.

The drag sends
eleven held points from the corner to 740, 940, then the release. The CLI
delivered each one cleanly, the last two at 740, 940 (000241 and 000242). The
frame matches the ninth point, 717, 920 (000240), with the three-pixel inset. So
the guest did not apply the last held point before the release.

The cause is the input delivery of the guest or the test driver, not Koine. The
window has no maximum size. The window code of 0.4.1 differs from 0.4.0 only in
the order of the two show calls. The same route grew the window to 701 by 901
and 703 by 903 in earlier complete runs.

The assertions after the resize did not run. They are the minimum-size
scrolling, the shortcuts, the client requests, the consent, the silent launch,
the reopen, the login restart and the final Quit.

The leaf used its three attempts without a clean run, so it asks Antony.

**A fourth attempt (2026-11-26).** Antony allowed one more attempt, unchanged,
on the same notarised bundle. The leaf files an issue for the dropped drag
point. If attempt 4 stops for a cause outside Koine, the leaf asks Antony again.
The other choices were to accept attempt 3 as it was, or to stop with nothing
shipped.

The leaf filed #21 for the dropped drag point.

**Attempt 4 (2026-11-26).** Attempt 4 (`menu-bar-20261126T115459`, clone
`koine-041-menu-4`) ran on the same notarised bundle, after the same digest and
`task app:verify` checks. The caller stopped the clone. All four Settings
selections passed again. The resize failed again, with the same frame, 681 by 884
at 40, 40. The drag records match attempt 3, and the frame again matches the
ninth point.

So the dropped point is repeatable, not chance. The route was qualified on
2026-10-28 with TestAnyware 2.7.0 on macOS 27.0.1. The harness moved to
TestAnyware 3.0.0 on 2026-11-23 (k177), and the guest now runs macOS 27.2.1.
Attempts 3 and 4 are the first real runs of the route since then. The most
likely cause is that change, not Koine, but no run has separated the two. The
leaf asks Antony again, as agreed.

**The drag repair (2026-11-26).** Antony chose to repair the drag before
another attempt. A diagnostic guest first runs the drag against a control, to
rule out Koine. One other choice was to accept the Settings evidence of
attempts 3 and 4. The others were to run only the Koine control first, or to
stop with nothing shipped.

The leaf inserted `settings-resize-drag-k7` ahead of itself. The repair is a
separate slice, with its own guest runs, helper change, tests and documents.
This leaf stays live. Attempt 5 runs on the same notarised bundle after k7
retires.
