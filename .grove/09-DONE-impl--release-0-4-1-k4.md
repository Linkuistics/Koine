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

**Attempt 5 (2026-11-26).** Attempt 5 (`menu-bar-20261126T134522`, clone
`koine-041-menu-5`) ran on the same notarised bundle. Both zips still had the
recorded SHA-256. `task app:verify` passed, and the CDHash matched. The caller
stopped the clone. The scenario exited 125 at the guest restart, before the
login-launch assertions.

All four Settings selections passed again. The anchored drag of k7 grew the
window to 703 by 903 and then shrank it to 440 by 352. The scrolling at the least
size, the shortcuts, the client requests, the consent, the silent launch, the
reopen and the Quit with Command-Q passed too.

The restart request (000670) sent `shutdown -r now` to the guest. After 0.35 s,
the CLI exited 1 with `CONNECTION_DROPPED`. The strict helper `restart_guest`
counts a failed submission as unavailable at once, so it read no boot record
after the request. This is the race of issue #17, the lost restart reply.

No retained evidence root in either workspace holds an earlier strict restart
record. So attempt 5 is the first real run of the strict helper. Attempt 1 was
the first run of the menu read, and attempt 3 the first run of the drag. The other VM checks send the
same restart and ignore its reply. An unchanged rerun most likely stops at the
same step, but one run cannot show that the drop repeats.

The assertions after the restart did not run. They are the login launch with
the menu bar item and no window, and the final Quit from the menu. The leaf
used the attempts that Antony allowed, so it asks Antony.

**The restart repair (2026-11-26).** Antony chose to repair the restart before
attempt 6. A lost reply then counts as a restart when a later boot read shows a
changed boot record. The other choices were to rerun unchanged, to accept attempt
5 as it was, or to stop with nothing shipped.

The leaf inserted `settings-restart-reply-k8` ahead of itself. The repair is a
separate slice, with its own guest run, helper change, tests and documents. This
leaf stays live. Attempt 6 runs on the same notarised bundle after k8 retires.

**The other release checks (2026-11-26).** While Antony decided the restart,
the leaf ran the two other release VM checks on the same notarised bundle. The
zip SHA-256 and the CDHash matched before the runs.
`task app:vm-verify-grant-workflows` passed
(`grant-workflows-20261126T135237.log`, clone `koine-041-grant-workflows`).

`task app:vm-verify-release` ran twice. The first run (`release-20261126T135208`,
clone `koine-041-release`) stopped at the first launch of the quarantined copy.
A `jq` read of the agent snapshot found no `windows` array. The second run
(clone `koine-041-release-2`) passed that step, so the fault did not repeat.

The second run stopped at the step that needs two Finder windows with one
title. The native list held the two new "Recents" windows and a third Finder
window, "Utilities". The golden image of today's guest restores that window.
Issue #18 reports it for the menu-bar check, and the screenshot of attempt 5
shows it too. The cause is guest state, not Koine. The assertions after that
step did not run on 0.4.1.

**The Finder repair (2026-11-26).** Antony chose a narrow repair of the release
check. Before the step opens its two Finder windows, it closes the Finder
windows that the golden image restores. The leaf then runs the release check
again, together with attempt 6.

Issue #18 gets the new evidence. The other
choices were an issue with no rerun, or a repair inside k8. The comment
https://github.com/Linkuistics/Koine/issues/18#issuecomment-7183172805 records
the evidence.

**The Finder repair as made (2026-11-26).** Before Command-N, the release check
presses Command-Option-W with Finder active. That closes every Finder window,
the restored "Utilities" window too. The five other scripts close Finder windows
with `osascript`. That route makes macOS ask once for Automation consent, and
the release check asserts that no consent dialog shows. So the repair uses a key
press.

TestAnyware drops an unknown modifier name in silence, so the leaf took the
spelling `option` from the source of its keymap. The one-title witness after
Command-N stays as the judge.

**Attempt 6 (2026-11-26).** Attempt 6 (`menu-bar-20261126T165831`, clone
`koine-041-menu-6`) ran on the same notarised bundle. Both zips still had the
recorded SHA-256. `task app:verify` passed, and the CDHash matched. The caller
stopped the clone. The scenario exited 125 at the guest restart, before the
login-launch assertions.

All four Settings selections passed again. The anchored drag grew the window to
703 by 903 and shrank it to 440 by 352. The scrolling, the shortcuts, the client
requests, the consent, the silent launch, the reopen and the Quit with Command-Q
passed too.

The restart request (000670) reached the guest. Its stdout reads "Shutdown NOW!"
and "System shutdown time has arrived". This time the reply arrived. The CLI
exited 0 with `ok: true`, the outcome kind `cancelled` with
`before_start: false`, exit code -1 and the stderr "Process cancelled".

The read table admits a lost reply only as CLI status 1 with
`CONNECTION_DROPPED`, and a normal reply needs a successful exit. So the backend
recorded the step as unavailable and read no boot record.

At SIGTERM, the TestAnyware agent cancels every running command and replies if
it can (`agents/macos/Sources/testanyware-agent/AgentServer.swift`, "Agent run
and SIGTERM"). So both reply forms come from one race: a closed connection gives
`CONNECTION_DROPPED`, and a cancelled record that gets out first gives this
form. The cause is the harness, not Koine.

The assertions after the restart did not run. The leaf used the attempts that
Antony allowed, so it asks Antony.

**The release check after the Finder repair (2026-11-26).** The third run of
`task app:vm-verify-release` (`release-20261126T170426`, clone
`koine-041-release-3`) passed on the same notarised bundle, after attempt 6.
Finder then had two windows, both "Recents", and every later assertion ran,
through the login launch across the VM restart and the final Quit. With
`task app:vm-verify-grant-workflows`, both other release VM checks now pass on
0.4.1.

**The cancelled reply (2026-11-26).** Antony chose to admit both reply forms.
The restart then also counts after a cancelled reply with `before_start: false`.
A later boot read must show a changed boot record. A diagnostic guest qualifies the rule before attempt 7. The other choices were to
accept attempt 6, to rerun unchanged, or to stop with nothing shipped.

The leaf inserted `settings-restart-cancelled-k9` ahead of itself. The repair is
a separate slice, as k8 was. It has its own guest run, read-table change, tests
and documents. This leaf stays live. Attempt 7 runs on the same notarised bundle
after the repair retires. The release check needs no rerun, because the repair
changes only the menu-bar scenario's restart read.

**Attempt 7 (2026-11-26).** Attempt 7 (`menu-bar-20261126T181134`, clone
`koine-041-menu-7`) ran on the same notarised bundle. Both zips still had the
recorded SHA-256. `task app:verify` passed, and the CDHash matched. The caller
stopped the clone. The scenario exited 0 with "PASSED", and the transcript
reports no NOT RUN step.

All four Settings selections passed. The anchored drag grew the window to 703 by
903 and shrank it to 440 by 352. Each later assertion passed too, through the
login launch and the final Quit from the menu.

The restart reply (000670) was the cancelled form again, with CLI status 0. The
backend recorded a clean cancelled reply. The boot record changed from
1795677095 (000669) to 1795677398 (000671), so the restart counted.

So attempt 7 is the clean run that the leaf needs, and it accepts the candidate.
The claim covers this one run on macOS 27.2.1 with TestAnyware 3.0.0. The leaf
asks Antony before the tag, the GitHub release and the cask update.

**Publishing (2026-11-26).** Antony approved the three publishing steps
together: the annotated tag `v0.4.1` on `1088ce07`, the GitHub release with the
zip and the drafted notes, and the cask update. The other choices were the tag
and the release without the cask, or no publishing yet.

**Published (2026-11-26).** `jj git push --tag v0.4.1` published the tag on
`1088ce07`. It is a lightweight tag, because jj makes no annotated tag. The
GitHub release "Koine 0.4.1" has the zip, and GitHub reports the recorded
SHA-256 for it. The cask commit `1675e318` in `Linkuistics/homebrew-taps`
changes only the version and the SHA-256.

Antony asked for the local installation to be upgraded too.
`brew upgrade --cask linkuistics/taps/koine` replaced 0.4.0 with 0.4.1 in
`/Applications`. The installed bundle has the recorded CDHash, and Gatekeeper
accepts it as "Notarized Developer ID". Koine was not running, so the upgrade
quit nothing and the leaf did not launch it.

**The published cask (2026-11-26).** `task app:vm-verify-homebrew`
(`homebrew-20261126T182512`, clone `koine-041-homebrew`) passed on the published
cask. Homebrew installed 0.4.1 with its quarantine intact, Gatekeeper accepted it
as notarised, and Koine launched and served. The uninstall and `--zap` removed
it. The Background Task Management entry after `--zap` matches the entry that
the Homebrew record shows for 0.4.0. The script stopped its own clone.
