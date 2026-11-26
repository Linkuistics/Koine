# window-layout-acceptance-k6

## Goal

Accept the first cut with the N check and the one happy-path VM run.

## Context

- The root brief's Pointers list the V checks that the human agreed.
- The VM tasks `app:vm-verify-desktop`, `app:vm-verify-desktop-focus` and
  `app:vm-verify-desktop-remembered` hold the pattern, with an independent
  native witness.

## Done when

- The compatibility tasks pass. The new host loads the new desktop bundle.
  The released 0.4.1 host refuses it before load, because it lacks
  `desktop-disclosures-v1`, and the compatibility record states this.
- A new Taskfile task runs the V checks in a TestAnyware macOS VM on the
  signed bundle, and every check passes.
- A record in `docs/verification/` holds the run's evidence and states the
  one-display limit.

## Notes

- A permission dialog other than Accessibility is a stop (root brief,
  Notes).
- `window-geometry-k3` changed `scripts/vm-verify-disclosure.sh` to expect the
  served desktop disclosures in all three views, and nobody has run it since.
  The VM conformance check now uses the
  `core-desktop-window-layout-workspace-extension-host` profile.

## Decisions (running log)

**The released 0.4.1 host comes from its tag.** A third pin,
`scripts/released-0.4.1.json`, names tag `v0.4.1` and its commit.
`scripts/build-retained-workspace.sh` builds that revision in its own tree,
as it builds the released 0.3.0. The pin names its directory,
`released-0.4.1`, because the workspace release of 0.4.1 is 1.0.2 and a
directory name from the workspace release would hide the host.

**Three desktop cases hold the N check.** This tree's host loads this tree's
desktop 1.0.1 and serves the `core-desktop-window-layout-extension-host`
profile. The released 0.4.1 host refuses the same bundle before load when it
is bundled, and no desktop image is mapped. The released 0.4.1 host also
refuses an approved per-user 1.0.1 that states `first-party-selection-v1`, and
its bundled desktop 1.0.0 stays selected, as the contract states. Each refusal
must name `desktop-disclosures-v1`. The record is a new document,
`docs/verification/desktop-window-layout-compatibility.md`, so the two large
compatibility records stay unconverted.

**One VM session holds the V checks.** The new task
`app:vm-verify-window-layout` runs `scripts/vm-verify-window-layout.sh` in one
clean VM. The session also checks the desktop disclosures in the create-grant
view, in the request view and in the grant list before and after a restart.
The workspace precedent proved an upgrade by a restart, because the list is
built from the stored grants on each read.
`Fixtures/WindowIdentityProbe` gains three witness readings: the displays, the
window server's front-to-back order and the pointer position.

**The two changed VM checks run once each.** `app:vm-verify-disclosure` and
`conformance:vm` changed in `window-geometry-k3`, and nobody ran them since.
This leaf runs each once on the same signed bundle and records the result.

**A bundled refusal leaves workspace without its capability owner.** The first
run pinned workspace 1.0.2 as active beside the refused bundled desktop 1.0.1.
The released 0.4.1 host served it as `REJECTED` with
`missing-capability-owner`, because no selected desktop owns
`desktop:control`. That is the designed cascade, so the pin now states it. The
per-user case keeps desktop 1.0.0 selected, and there workspace stays active.

**The N check passed.** The second `task compat` run passed 40 cases with no
failed check, and no subject binary changed during the run. The retained
workspace subjects also passed. The three desktop 1.0.1 cases are among the 40.

**The point query fails under a visible Dock.** The first VM run matched the
witness for the window list, the frames, the display list, frame setting with
restore and the first order check. Then `desktopWindowOnTop` answered
`NOT_ON_TOP` for the front window at a point inside it. A diagnostic VM session
on macOS 27.2.1 (26B131) named the cause.

With default Dock settings, the Dock process owns an entry at layer 20 with
alpha 1 and the bounds of the whole display. The contract counts every opaque
entry in front as a cover, the Dock included. So every window is `NOT_ON_TOP`
at every point while the Dock is visible. The host has no such entry, and
Modaliser applies the same rule. The repair changes the contract, so the human
decides it.

**Every other V check passed.** A scratch copy of the VM script recorded the
point query and asserted the rest
(`window-layout-20261126T224558.log`). The window list, the display list and
frame setting with restore matched. Both order cases matched in both orders.
The minimised window, display focus and the disclosures before and after a
restart matched too. The point query answered `NOT_ON_TOP` in all four calls,
so the two calls on the front window were wrong.

`app:vm-verify-disclosure` passed (`disclosure-20261126T224905.log`).
`conformance:vm` passed with the window layout profile
(`conformance-20261126T225111.log`).

**The human chose the Dock bar rule for the point query.** An entry of the
Dock process covers a point only outside the visible frame of the display that
contains the point. Inside that visible frame it covers nothing. When that
visible frame is unknown, a Dock entry that contains the point gives `UNKNOWN`.
Every other entry covers as before. The options were the Dock bar rule,
ignoring the Dock, `UNKNOWN` under the Dock, and shipping as it is.

The limit becomes a GitHub issue in the release leaf. A magnified Dock or a
Dock folder stack draws inside the visible frame. So Koine can answer `ON_TOP`
there wrongly.

**The Dock bar rule is in the pure rule, with the reads outside it.**
`WindowStacking.onTop` takes the Dock's process identifier and the display list.
The provider reads both before its queue turn, because AppKit gives the visible
frames on the main actor. The display list and the point query share
`readDisplays`. A failed display read leaves each Dock entry undecided.

The served SDL and its descriptions stay as they are. The Dock's invisible
entry is not a window that covers, so the descriptions stay true. The digests
and profiles do not move. The contract section "Visibility at a point" and the
client guide state the rule and its limit.

**Verification of the repair.** The L suite passed 65 tests, five of them new.
Four mutations each turned it red. In them, the Dock always covers, the Dock bar
never covers, an unknown visible frame covers nothing, and any owner follows the
Dock rule. The window layout and schema conformance G suites passed 48 tests.

**The V check passed on the build with the Dock bar rule.** The unmodified
script passed every step on bundle CDHash
`18f4a4f767860dd9f70c2d6608de9d29663d608e`
(`window-layout-20261126T231906.log`), and its digest was the same before and
after the run. The point query answered `ON_TOP` for the front window and
`NOT_ON_TOP` for the back window in both orders. `conformance:vm` passed on the
same bundle (`conformance-20261126T232304.log`). The disclosure run stands on
the earlier build, which differs only in the point query.

**The full `task test` run holds no failure of this leaf.** 463 tests ran, with
21 issues in four suites that this branch does not change. The revocation and
provider lifecycle suites passed alone. The four short-deadline workspace
composition tests failed at grant setup under load, as `display-focus-k5`
records. They passed five times out of five alone. The two
`File name too long` issues are the macOS 27 wording failure that
`window-stacking-k4` records.

**The trace rows stay in their pending region.** The three earlier leaves edited
the same rows in place, and the table has many unconverted rows. The edits name
the two records and keep each touched sentence within the rules.

**No adversarial review before the release.** The repair is one rule in a pure
function, and the human chose it. Four mutations of it went red. The VM run
accepted the live path under an independent witness. A change is a later provider release,
so the decision is not hard to reverse.
