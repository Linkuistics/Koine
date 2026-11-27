# Koine.gh-issue-11 — brief

## Goal

This grove ships pointer and media, the next item of the roadmap in GitHub
issue 11, as Koine 0.6.0 through the Homebrew cask. A client with desktop
grants reads the pointer position and reveals a hidden pointer with a nudge.
It also sends six media keys through the system media route. The client draws
the highlight ring. The human settled this scope in `plan-k1`. Its running log
holds each decision in the human's words, and this brief holds the result.

## Done when

- **Pointer location.** A desktop read returns the pointer position in screen
  coordinates.
- **Pointer reveal.** A desktop control operation nudges the pointer one point
  to the right and back, with two mouse-moved events, as Modaliser does. The
  pointer ends where it started. While a pointer button is held, Koine
  refuses the nudge and moves nothing. It never clicks.
- **Media keys.** Desktop control operations post six media keys: play/pause,
  next, previous, volume up, volume down and mute. Each key is a
  system-defined event, down then up, as Modaliser posts it. Play/pause, next
  and previous reach the Now Playing app, not the front app. Volume and mute
  change the system output. A receipt says only that Koine posted the key,
  because macOS gives no public way to ask which app holds Now Playing.
- **Authority.** The location read needs desktop read. The nudge and the keys
  need desktop control. A read-only grant cannot act. No input grant is
  involved, and no keystroke reaches the front app.
- **Disclosure.** The Settings window and the GraphQL descriptions disclose
  the wider desktop reach before the release. The text covers the pointer
  position, the nudge, the keys that reach the Now Playing app, and the change
  of volume and mute. It also says that macOS may start Music, if the design
  leaf sees that happen. Acceptance covers a new grant request, an existing
  grant after the upgrade and the field descriptions. No existing grant is
  revoked or reauthorised.
- **Consent.** Koine posts every event under its existing Accessibility
  consent, and no new permission dialog appears.
- The four agreed test seams (Pointers) pass.
- **Docs** describe the current state. They cover the design schema, the
  desktop contract and the "Media" row of the requirements. They also cover
  the authority and trace rows, the glossary, the README and the client guide.
- **Koine 0.6.0 is released.** It is notarised, its release checks pass on
  the notarised build, and it is tagged. The GitHub release is published, the
  cask is bumped, and the Homebrew check passes. The pointer and media
  checkbox in issue 11 is ticked.
- **Issues are filed** for each case that acceptance defers. Each review
  finding that does not break the happy path is a GitHub issue too.

## Decomposition

The leaves are flat siblings under the root, because they share this brief's
one scope. Their positions encode their dependencies.

1. `pointer-media` (design): the GraphQL design for the pointer position, the
   nudge and the six keys. It writes the desktop contract text and the trace
   rows. It widens the "Media" row of the requirements. It writes the disclosure
   text and the glossary terms. It checks in a VM whether play/pause starts
   Music when no app holds Now Playing. It goes first, because no design
   schema covers the pointer or the keys yet. It decides whether its design
   needs an adversarial review.
2. `pointer` (impl): the position read, the nudge and the disclosure, with L
   and G tests. It needs 1.
3. `media-keys` (impl): the six keys, with L and G tests. It needs 2, because
   both leaves change the desktop schema.
4. `pointer-media-acceptance` (impl): the N check and the one happy-path VM
   run. It needs 2, 3 and any review.
5. `release-0-6-0` (impl): the version, notarisation, release checks on the
   notarised build, publishing and the issues. The human approves each public
   step. It needs 4.

## Pointers

- Glossary: **Screen coordinates**, **Display focus**, **Public
  Accessibility boundary**, **Capability**, **Grant**, **Settings window**
  (`CONTEXT.md`).
- Requirements: `docs/requirements/modaliser-workflows.md`. The workflow
  inventory rows "Media" and "Pointer" apply. The coverage list names pointer
  reveal and system media routing. "Requirement: separately grant input, menu
  invocation and window focus" applies too.
- Specs: `docs/specs/machine.md` is the desktop contract. Its "Window layout"
  section holds display focus, which already moves the pointer.
  `docs/specs/workflow-providers.md` owns the "Authority allocation", the
  "Operation-to-capability trace" and the "Test seams". Its rows for this
  grove are "Media", "Pointer" and "Grant disclosure".
- Decision records that bind: `provider-authority-follows-effects`,
  `desktop-automation-uses-public-accessibility` and
  `bearer-grants-and-live-revocation`. The first counts pointer movement
  without held buttons and system media events as desktop effects. It also
  requires the disclosure before the additions ship. The design leaf decides
  whether the second needs a sentence about the posted pointer and media
  events.
- Modaliser is the reference implementation, at
  `~/Development/KeyboardDrivenUI/Modaliser`.
  `Sources/Modaliser/CursorLibrary.swift` reads the position and nudges the
  pointer. `MediaKeyEmitter.swift` builds and posts the media keys, and
  `InputLibrary.swift` exposes them. Antony's configuration binds the ring and
  play/pause in `~/.config/modaliser/config.scm`.
- Koine's desktop provider already checks the held buttons and moves the
  pointer for display focus. In a VM, the witness
  `Fixtures/WindowIdentityProbe` reads the pointer position and the held
  buttons.
- **Test seams, agreed with the human:**
  - *L*: `DesktopProviderLogicTests` feed plain values to the pure
    `DesktopProviderLogic` module, and nothing posts an event. They cover the
    nudge path, one point to the right and then back, and the refusal while a
    button is held. They also cover the conversion of the pointer position
    into screen coordinates and the event contents of each key.
  - *G*: `KoineServerTests` load the real desktop bundle and query it over
    loopback. They cover the authority, the descriptions and the served
    disclosure. They never call the nudge or a key with a control grant.
  - *N*: the compatibility tasks run the signed bundle against the new host
    and the released 0.5.0 host.
  - *V*: one TestAnyware VM run through a new Taskfile task, with an
    independent witness. The Settings window states the disclosure for a new
    grant request, and for an existing grant after a restart. Koine's pointer
    position matches the witness within one point. After a nudge, the witness
    reads the pointer back at its start with no button held. A real player,
    Music by default, plays a local playlist of three short silent tracks in
    the background while TextEdit stays in front. Play/pause pauses the player
    and resumes it. Next and previous change the track. Volume up and down
    change the output volume, and mute switches the mute state. The witness
    reads each state itself. TextEdit receives no keystroke, and no permission
    dialog appears.

## Notes

- **The human's delivery rule**, from issue 11:

<!-- tc: off because this is the human's rule, quoted verbatim -->

  > Each item becomes its own small grove that ends in a shipped release:
  > happy path first, one VM acceptance of that path, then GitHub issues for
  > edge cases, coverage and hardening.

<!-- tc: on -->

- **Use Modaliser's mechanisms where possible.** The human ruled this in the
  window layout grove:

<!-- tc: off because these are the human's words, quoted verbatim -->

  > We will use the modaliser mechanisms where possible - even if this
  > involves private API.

<!-- tc: on -->

  Koine's authority rules still hold. So the nudge refuses while a button is
  held, which Modaliser does not check.
- **The whole media key family is the human's decision:**

<!-- tc: off because these are the human's words, quoted verbatim -->

  > I think we should deliver the whole media keys family, rest I agree with

<!-- tc: on -->

- **Nobody verified the codes for next and previous.** Modaliser posts
  `NX_KEYTYPE_FAST` (19) and `NX_KEYTYPE_REWIND` (20), and it calls that
  choice a judgement call. `NX_KEYTYPE_NEXT` (17) and `NX_KEYTYPE_PREVIOUS`
  (18) are the first alternative to try. The VM run settles which codes a
  player honours.
- **The ring belongs to the client.** Koine supplies the position and the
  nudge, and it draws nothing.
- **A receipt makes no claim about the player.** macOS gives no public way to
  ask which app holds Now Playing. Koine does not use the private MediaRemote
  framework for that, because Modaliser does not, and the requirements do not
  ask for it.
- **A new permission dialog is a stop.** Koine needs Accessibility only, and
  it already holds that consent. A dialog that names Koine is a new consent
  posture, which is the human's decision.
- **GUI work runs only in TestAnyware VMs**, never on the host. That covers
  moving the pointer, posting a media key and starting `Koine.app`. The G
  tests never call the nudge or a key with a control grant. Builds,
  `swift test` and `codesign` on the host are fine.
- **Guest sound reaches the host.** Tart passes the audio of a guest to the
  speakers of the host by default. So the VM run plays silent tracks.
- **A harness limit goes back to the human.** If the VM cannot hold a playing
  app, the media cases stop. Then ask the human. Recommend the close that the
  human accepted for the Settings repair: release with the limit stated, and
  file an issue.
- **Served descriptions describe 0.6.0.**
- **Version numbers.** The application is 0.5.0. The desktop provider is
  1.0.1, with schema 1.0.1. The design leaf chooses the new numbers. It also
  decides whether desktop requires a new disclosure feature of the host, as
  desktop 1.0.1 requires `desktop-disclosures-v1`.
- **Docs edits convert first.** An existing document follows the
  technical-communication rules before an edit. Convert the touched sections
  as their own commit, and put the other sections in `pending` regions.
- **Use the Taskfile.** The VM run gets a task beside the existing VM tasks,
  such as `app:vm-verify-pointer-media`.
- **Out of scope:** pointer-button synthesis and Space switching belong to
  the app input item. Issue #23 holds the checks on a second display. A query
  of the Now Playing app needs private API and is not part of this grove.
