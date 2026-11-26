# plan-k1

## Goal

Agree with Antony which item of the roadmap in GitHub issue 11 this grove
delivers. Then agree the happy-path scope of that item.

## Context

- The roadmap is GitHub issue 11. Its first item shipped as Koine 0.4.0
  through issue 10. Issue 10 proposed the System Settings catalogue as a
  second cut. The roadmap has no checkbox for that cut. The next open
  checkbox is window layout.
- Antony wrote on 2026-11-26: "Note that the existing Modaliser project
  already has this functionality for MacOS". The session read this as the
  window layout functionality.
- Modaliser is at `~/Development/KeyboardDrivenUI/Modaliser`.
  Its window layer is in `Sources/Modaliser/WindowEnumerator.swift`,
  `WindowManipulator.swift`, `WindowLibrary.swift`, `WindowCache.swift` and
  `ChipPlacement.swift`. Modaliser has no System Settings catalogue.
- Koine identifies a window by a held Accessibility element, as
  `docs/adr/desktop-window-identity-is-a-held-element.md` records.
  Modaliser's private window-number lookup and title fallback are not proof
  of identity in Koine
  (`docs/specs/machine.md#resource-references-and-desktop-behavior`).
- Window layout must disclose the expanded desktop authority before its
  first new operation ships (`docs/specs/workflow-providers.md`, "Authority
  allocation").
- Koine's window identity evidence is
  `docs/verification/desktop-window-identity.md`. On macOS 26.5, it compares
  the held element, the private `_AXUIElementGetWindow` lookup and bounds
  matching against the window server's list.
- Modaliser's `WindowLibrary.swift` notes that `_AXUIElementGetWindow`
  disagrees with the window server's numbers for some applications. For
  those applications, Modaliser matches by owner and bounds instead.

## Done when

- Antony agreed to the roadmap item and its happy-path scope.
- The running log below records each decision that settled.

## Notes

## Decisions (running log)

**Roadmap item.** This grove delivers window layout, the next open checkbox
of the roadmap in issue 11. Antony accepted the recommendation on
2026-11-26 with "your recommendation". The System Settings second cut stays
on the roadmap for a later grove. Window layout needs no new consent or
signing posture. Modaliser's window layer supplies the native mechanics to
port.

**Layout responsibility.** The client computes every layout: thirds,
half-thirds, two-thirds, halves, quarters, maximise, centre and the
proportional move to another display. Koine keeps no frame history for
restore. Antony agreed on 2026-11-26: "I agree - the layouts are not Koine's
role" and "Nor is history required for 'restore'". Koine supplies window and
display geometry and one operation that sets a window's frame. The design
chooses whether that operation takes absolute points or fractions of a
display.

**First-cut scope.** The first cut includes stacking, visibility and display
focus. It also includes the cross-application window list with frames, the
display list, the frame-setting operation and the disclosure of the expanded
desktop authority. Selection uses the existing focus operation. Antony
decided on 2026-11-26: "I want stacking, visibility and display focus in the
first cut." Antony also wrote: "Maybe Koine needs screen recording
permission, because these features are absolutely required."

The method that orders windows and the consent posture are still open.
Display focus must also work without the click fallback that the authority
table forbids.

**Window order and visibility.** Koine orders windows and decides visibility
with Modaliser's mechanism. The private `_AXUIElementGetWindow` lookup gives
each held element's window number, and Koine finds that number in the window
server's list. Where the lookup disagrees with the list, Koine matches by
owner and bounds. Where neither settles an entry, Koine reports the order or
the visibility as unknown, never as visible. Antony accepted the
recommendation on 2026-11-26 with "your recommendation".

These links serve ordering and visibility only. Identity stays the held
element, so every action still goes to the element that a reference names.
Koine needs no Screen Recording. The window identity record and the public
Accessibility record must change to allow the links for ordering only.
The decision rejects public matching with an Accessibility hit test, because
neither Koine nor Modaliser runs it yet. It rejects Screen Recording, because
Screen Recording adds only titles, which are not unique, and a consent that
Koine does not need.

Antony restated the decision on 2026-11-26: "We will use the modaliser
mechanisms where possible - even if this involves private API." The
restatement is broader than the decision, which covers ordering and
visibility. So the session asked Antony whether the principle also reaches
window identity.

**Window identity.** Window identity stays the held element. The principle
in the restatement governs the new mechanisms in this grove, and it does not
change identity. Antony accepted the recommendation on 2026-11-26 with "As
you recommend". The title fallback stays forbidden, because Koine never acts
on a substitute window. A window-number identity would let references
survive a restart of Koine, and it would need its own issue.

**Display focus.** On a display with a window, display focus raises the
front window there, activates its application and moves the pointer to the
display's centre. On a display with no window, it moves the pointer to the
centre and reports that no window took focus. It never clicks, because the
requirements keep input delivery separate from window focus. Antony accepted
the recommendation on 2026-11-26 with "As you recommend". The click, for
clients that also hold input control, becomes an issue for the app input
item.

**Test seams and acceptance.** The work reuses four existing seams and adds
none. Antony agreed on 2026-11-26 with "yes".

The desktop logic tests feed plain values to `DesktopProviderLogic`. The
public GraphQL tests load the real desktop bundle over loopback. The native
compatibility check runs the signed bundle against the new host and the
released 0.4.1 host. A new TestAnyware task accepts the happy path on one
display, with an independent witness.

The VM happy path covers these checks. The window list holds TextEdit and
Finder windows with references and frames. The display list holds full and
visible frames. A frame set to the left half reads back, and so does the
earlier frame that a client restore sets. Order and visibility match the
witness for overlapping windows of two applications and for two TextEdit
windows with equal bounds. Display focus raises the front window and moves
the pointer, and the Settings window states the disclosure.

The VM has one display. So the release ships after the one-display run, with
that limit stated. An issue covers the two-display check: the move to
another display, the repeated resize across displays and display focus on
an empty display.

**Shared understanding.** Antony agreed to the whole first cut on 2026-11-26
with "yes". The cut ships as Koine 0.5.0. The tree has six flat leaves after
this one: design, window geometry, window stacking, display focus,
acceptance and release 0.5.0. The release files two issues: the two-display
check, and the display-focus click with input control.
