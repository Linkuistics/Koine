# window-layout-k9

**Integrates:** window-layout-k8

## Goal

Triage the committed findings of `window-layout-k8` against the agreed window
layout acceptance, and apply the findings that earn repair.

## Context

- Read the findings from the review's own commit. Its durable report is
  `docs/verification/desktop-window-layout-design-review.md`.
- The reviewed producer is `window-layout-k2`. Its design, the root brief and
  the human's decisions in `plan-k1` define the contract.
- This leaf precedes `window-geometry-k3`, so implementation consumes the
  reconciled design.

## Done when

- Each finding is verified and classified under the integration procedure's
  acceptance and material-risk threshold.
- Each accepted repair is applied to the artifact and its affected citations
  and downstream task obligations.
- Relevant post-repair verification is recorded, with native acceptance limits
  preserved.
- Rejected findings and accepted trade-offs have explicit reasons.

## Notes

The findings belong to the review's commit, not this charter. This session
may reject a finding after inspecting its evidence. Substantial redesign
follows the integration procedure's producer-chain rule.

## Decisions (running log)

**F1, the late pointer move: a real issue, repaired.** The finding holds. The
existing focus waits up to 3 seconds (`focusWait` in
`Providers/DesktopProvider/Sources/DesktopProvider.swift`). The design checks
the buttons only before that wait. The authority table refuses movement with a
held button, because it is an undeclared drag. This is safety work, so it
binds.

The repair keeps the agreed order: raise, activate, then move. Display
focus checks the buttons again immediately before the move. When a button is
held then, it leaves the pointer where it is.

A new receipt field,
`pointerMoved`, states whether the pointer moved. The outcome keeps the window
part. `POINTER_BUTTON_HELD` keeps its meaning: Koine did nothing. The contract
states the remaining race between the second check and the move, and it
promises no atomicity.

**F2, unknown display geometry: a real issue, repaired in part.** The
producer's own acceptance asks for an unknown form for each value that Koine
may not establish. The visible frame comes from AppKit, and the identifiers
come from Core Graphics. So a display change between the two reads can leave a
listed display with no matching AppKit screen.

`visibleFrame` becomes nullable.
It is null when no AppKit screen has the identifier, or when the converted
frame is not inside the display's frame. The frame and the primary flag stay
non-null.

The SDK header says that `CGDisplayBounds` returns `CGRectZero` for an
invalid display. So an identifier with empty bounds is a display that left
during the read, and the list leaves it out. The primary flag compares the
identifier with `CGMainDisplayID`, which Koine can always establish.

A failed
`CGGetActiveDisplayList` is `failed`, because an empty list would be a false
known value. Koine never uses Modaliser's zero identifier: every listed
identifier comes from the Core Graphics list.

**F3, two rectangles for the point answer: an unclear contract, repaired.** The
spec tests the bounds of the linked entry, and the schema and the glossary test
the window frame. The two can differ by 2 points.

The contract now uses the
bounds of the linked entry everywhere. The window server draws and covers by
bounds, so the whole answer comes from one reading of its list. The bounds
also exist when the link holds by window number with an unknown frame. The
link tolerance decides the link only.

**F4, selection by order: an unclear contract, repaired.** The root brief
already makes display focus choose its window by order, so the dependency was
agreed. The identity record and the link section overstated their claim. They
now separate the two cases.

A reference always resolves to its held element.
Display focus takes no window reference, and it selects a held window by the
order that the links give. A failed link makes it raise nothing. A wrong link
that holds can make it raise a listed window that is not the front one.

That
cost is a selection, never the identity of a reference. The existing record
changes in place, and no new record is necessary.

**No new review round.** Each repair changes a sentence, a field or a
nullability inside the reviewed design. None rethinks the design, so no
producer step or second adversarial review is necessary.

**The trace rows stay unchanged.** The rows in `docs/specs/workflow-providers.md`
name capabilities, and no repair changes a capability. The authority table
there already refuses pointer movement while a button is held.

**Verification after the repairs.** `task design:window-layout-check` passed.
The SDL is valid alone and in both compositions. The example operations are
valid with the new `pointerMoved` field. The task still rejected its 8 mutated
subjects.

A sweep of the whole tree found no stale claim for any of the four findings
outside the review record. Each sweep pattern matched the pre-repair files
first, so the clean result is evidence. The technical-communication checker
reports no hard finding in any changed prose.

This is design evidence only. No build, test or GUI step ran. Runtime and
native acceptance stay with `window-geometry-k3` to
`window-layout-acceptance-k6`, and the one-display limit stands.
