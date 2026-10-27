# plan-k1

## Goal

Establish the scope, completion criteria and test seams for Koine issue 14,
then leave a concrete next task for the work whose cause remains unknown.

## Context

[Koine issue 14](https://github.com/Linkuistics/Koine/issues/14) is the task source
identified by this workspace. The original leaf and root brief were empty
bootstrap templates. The issue has no comments as read on 2026-10-28.

## Done when

- The root brief records the issue's outcomes and release constraint.
- The human has checked the proposed test seams.
- The next work is concrete, bounded and preserves any unresolved diagnostic
  questions without guessing their answers.

## Notes

No VM has been started and no product or verification code has changed in this
requirements session.

## Decisions (running log)

The workspace identifies issue 14, and its open work supplies the requirements:
find why the window sometimes does not come forward and why `input move` gets
`-1`; report or work around the missing title-bar drag; and collect more bounded
samples without claiming that the small historical sample proves a regression.
The explicit issue constraint is retained: these findings do not block 0.4.0.

There are fewer than three interdependent unresolved product decisions. The open
causal questions are engineering investigations, not questions to make the human
answer speculatively. A full grilling is not warranted. The work behind the
issue belongs to implementation leaves after agreement on the test seams.

Source inspection supports preserving the current end-to-end seam. The menu
uses pointer movement followed by a click, front-window checks observe ordering
and the focused flag, and the resize check distinguishes a missing title-bar
drag from a failed minimum-size assertion. The pure helper checks and complete
VM route are recorded in the root brief.

Antony agreed to the proposed test scope: "Yes, use that test scope." It keeps
the real workflow in disposable TestAnyware VMs, focused checks for script
repairs, and resize explicitly unresolved until actual user-input resizing
works. This settles the seam check without changing the product contract or
counting unavailable input as acceptance.

The work is divided into menu-interaction-k2, window-resize-k3 and
menu-bar-samples-k4. No new spec or ADR is needed: this is repair of an existing
verification route, and its durable results belong in the existing menu-bar
verification document. The brief carries the temporary work order and agreed
test seams. No separate requirements review is warranted for this bounded repair
scope; implementation can earn review if its actual changes require it.
