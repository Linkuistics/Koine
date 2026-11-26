# Koine.gh-issue-11 — brief

## Goal

Ship the first cut of window layout, the next item of the roadmap in GitHub
issue 11, as Koine 0.5.0 through the Homebrew cask. A client with desktop
grants lists windows across applications with their frames, front-to-back
order and visibility. It also lists displays, sets a window's frame and
focuses a display. The client computes every layout from that geometry. The
human settled this cut in `plan-k1`. Its running log holds each decision in
the human's words, and this brief holds the result.

## Done when

- **Window list.** A desktop read lists the windows of every application that
  has a Dock icon, on the current Space. Each row has a window reference, a
  title, the owning application and a frame. A frame that Koine cannot
  establish is unknown, never invented.
- **Order and visibility.** Each listed window carries its place in the
  front-to-back order and whether it is on screen. A client can ask whether a
  window is on top at a screen point. Where Koine cannot establish order or
  visibility, it reports unknown, never visible.
- **Displays.** A desktop read lists the displays. Each has an identity, a
  full frame, a visible frame and a primary flag. The visible frame excludes
  the menu bar and the Dock. All frames use the coordinates of window frames.
- **Frame setting.** One desktop control operation sets a window's frame by
  reference. It disables the Electron accessibility mode during the write.
  After a move to a larger display, it repeats the write until the size
  matches. A stale reference is unavailable, and Koine never acts on a
  substitute window.
- **Display focus.** A desktop control operation focuses a display. On a
  display with a window, it raises the front window there, activates its
  application and moves the pointer to the display's centre. On a display
  with no window, it moves the pointer to the centre and reports that no
  window took focus. It never clicks.
- **Selection** uses the existing focus operation, unchanged.
- **Authority.** Every read needs desktop read. Frame setting and display
  focus need desktop control. A read-only grant cannot act.
- **Disclosure.** The Settings window and the GraphQL descriptions disclose
  the expanded desktop authority before the first new operation ships.
  Acceptance covers a new grant request, an existing grant after the upgrade
  and the field descriptions. No existing grant is revoked or reauthorised.
- **Identity** stays the held element.
- The four agreed test seams (Pointers) pass.
- **Docs** describe the current state. They cover the design schema, the
  desktop contract, the trace rows, the two changed decision records, the
  glossary, the README and the client guide.
- **Koine 0.5.0 is released.** It is notarised, its release checks pass on
  the notarised build, and it is tagged. The GitHub release is published, the
  cask is bumped, and the Homebrew check passes. The window layout checkbox
  in issue 11 is ticked.
- **Issues are filed** for the two-display check and for the display-focus
  click with input control. Each review finding that does not break the happy
  path is a GitHub issue too.

## Decomposition

The leaves are flat siblings under the root, because they share this brief's
one scope. Their positions encode their dependencies.

1. `window-layout` (design): the GraphQL design for every surface above, the
   desktop contract text and the trace rows. It also changes the two decision
   records and the glossary. It goes first, because no design schema covers
   window geometry yet. It decides whether its design needs an adversarial
   review.
2. `window-geometry` (impl): the window list with frames, the display list,
   frame setting and the disclosure, with L and G tests. It needs 1.
3. `window-stacking` (impl): order and visibility with Modaliser's mechanism,
   with L and G tests. It needs 2. Its last act decides whether an
   adversarial review is necessary before acceptance.
4. `display-focus` (impl): display focus, with L and G tests. It needs 3,
   because it chooses a display's front window by order.
5. `window-layout-acceptance` (impl): the N check and the one happy-path VM
   run. It needs 2, 3, 4 and any review.
6. `release-0-5-0` (impl): the version, notarisation, release checks on the
   notarised build, publishing and the two issues. The human approves each
   public step. It needs 5.

## Pointers

- Glossary: **Public Accessibility boundary**, **Process incarnation**,
  **Reference withdrawal**, **Resource reference**, **Capability**,
  **Grant**, **Settings window** (`CONTEXT.md`).
- Requirements: `docs/requirements/modaliser-workflows.md`. The workflow
  inventory rows "Desktop windows" and "Displays" apply. So do "State for
  configured lists and on-screen labels" and "Requirement: separately grant
  input, menu invocation and window focus".
- Specs: `docs/specs/machine.md` is the desktop contract.
  `docs/specs/workflow-providers.md` owns the "Authority allocation", the
  "Operation-to-capability trace" and the "Test seams". Its window layout
  rows are "Desktop windows", "Displays", "List and label state" and "Grant
  disclosure".
- Decision records that bind and stay as they are:
  `desktop-capture-preserves-the-process-incarnation`,
  `provider-authority-follows-effects`, `bearer-grants-and-live-revocation`.
- Decision records that this grove changes in place:
  - `desktop-window-identity-is-a-held-element`: the private window-number
    lookup and bounds matching serve ordering and visibility only, never
    identity. Identity stays the held element, with no title fallback.
  - `desktop-automation-uses-public-accessibility`: Koine uses Modaliser's
    mechanisms where possible, including private API. Window ordering uses
    the private lookup. Every action still goes to the held element.
- Evidence: `docs/verification/desktop-window-identity.md` compares the held
  element, the private lookup and bounds matching on macOS 26.5.
- Modaliser is the reference implementation, at
  `~/Development/KeyboardDrivenUI/Modaliser`. Its window layer is
  `Sources/Modaliser/WindowEnumerator.swift`, `WindowManipulator.swift` and
  `WindowLibrary.swift`. Antony's configuration computes the move to another
  display in `~/.config/modaliser/sys/scheme/lib/modaliser/display-actions.sld`.
- **Test seams, agreed with the human:**
  - *L*: `DesktopProviderLogicTests` feed plain values to the pure
    `DesktopProviderLogic` module. They cover the three ordering steps, the
    visibility rules with unknown in place of visible, display frames in
    window coordinates and the resize repeat.
  - *G*: `KoineServerTests` load the real desktop bundle and query it over
    loopback. They cover authority, stale references, unknown values and the
    disclosure in the descriptions.
  - *N*: the compatibility tasks run the signed bundle against the new host
    and the released 0.4.1 host.
  - *V*: one TestAnyware VM run on one display, through a new Taskfile task,
    with an independent witness. The window list holds TextEdit and Finder
    windows with references and frames. The display list holds full and
    visible frames. A frame set to the left half reads back, and so does the
    earlier frame that a client restore sets. Order and visibility match the
    witness for overlapping windows of two applications. They also match it
    for two TextEdit windows with equal bounds. Display focus raises the front
    window and moves the pointer. The Settings window states the disclosure
    for a new grant request and for an existing grant.

## Notes

- **The human's delivery rule**, from issue 11:

<!-- tc: off because this is the human's rule, quoted verbatim -->

  > Each item becomes its own small grove that ends in a shipped release:
  > happy path first, one VM acceptance of that path, then GitHub issues for
  > edge cases, coverage and hardening.

<!-- tc: on -->

- **Use Modaliser's mechanisms where possible.** The human's words:

<!-- tc: off because these are the human's words, quoted verbatim -->

  > We will use the modaliser mechanisms where possible - even if this
  > involves private API.

<!-- tc: on -->

  The principle covers the new mechanisms of this grove. It does not change
  window identity, and it does not override an authority rule. So display
  focus never clicks, and the title fallback stays forbidden.
- **Layouts and restore belong to the client.** Koine computes no layout and
  keeps no frame history.
- **Where Modaliser assumes visible, Koine reports unknown.** Modaliser
  treats a window as visible when it cannot decide. The requirements need an
  unknown state that stays distinguishable from a known one.
- **A new permission dialog is a stop.** Koine needs Accessibility only, and
  it already holds that consent. A Screen Recording or other dialog that
  names Koine is a new consent posture, which is the human's decision. Stop
  and ask the human.
- **GUI work runs only in TestAnyware VMs**, never on the host. That covers
  moving windows, focusing displays, moving the pointer and starting
  `Koine.app`. Builds, `swift test` and `codesign` on the host are fine.
- **The VM has one display.** TestAnyware 3.0.0 starts a VM with one
  display. So the release states the two-display limit, and the release leaf
  files the two-display issue.
- **Served descriptions describe 0.5.0.**
- **Version numbers.** The application is 0.4.1. The desktop provider is
  1.0.0, with schema 1.0.0, unchanged since Koine 0.1.0. The design leaf
  chooses the new numbers.
- **Docs edits convert first.** An existing document follows the
  technical-communication rules before an edit. Convert the touched sections
  as their own commit, and put the other sections in `pending` regions.
- **Use the Taskfile.** Each new check gets a task beside the existing VM
  tasks, such as `app:vm-verify-desktop-focus`.
- **Out of scope:** Space switching belongs to the app input item. The
  System Settings second cut stays on the roadmap. A window-number identity
  that survives a restart would need its own issue.
