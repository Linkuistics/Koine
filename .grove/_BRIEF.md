# Koine.gh-issue-11 — brief

## Goal

This grove ships app input, the next item of the roadmap in GitHub issue 11,
as Koine 0.7.0 through the Homebrew cask. It ships Koine's first input
provider. A client with an input grant sends one chord to an app, but only
while that app is the front app. A chord is one key with its modifier keys,
such as Command-L. A client with input and desktop grants also switches to a
Space with Control and a digit.

Antony settled this scope in `plan-k1`. Its running log holds each decision in
his words, and this brief holds the result.

## Done when

- **Keystrokes.** Under input control, Koine sends one chord to a captured
  target. Modifier key-down events come before the key, and modifier key-up
  events come after it, as in Modaliser's `send-keystroke`. The keys are
  Modaliser's key table.
- **Route.** Koine sends the chord into the target's own event stream with
  `CGEventPostToPid`. It never posts an app chord at the HID event tap, so no
  other app can receive the chord.
- **Front app.** Koine sends a chord only while the target is the front app.
  Otherwise it refuses and sends nothing, and it never activates the target.
- **Space switching.** Under input control and desktop control, Koine posts
  Control and a digit from 1 to 9 at the HID event tap. It reads the shortcut
  settings first, and it changes nothing. It refuses when the shortcut is
  disabled or remapped, or when the Space does not exist.
- **Protected targets.** Koine refuses its own process and recognised consent
  or security dialogs as targets. Space switching also refuses while one of
  them is in front.
- **Authority.** Target capture uses input read, as the workflow providers
  spec allocates it. A chord needs input control, and Space switching needs
  desktop control too. Read-only and desktop-only grants cannot send a chord.
- **Receipts.** A receipt says only that Koine sent the chord.
- **Consent.** Koine checks its Accessibility consent and its posting access
  before it sends, as the media keys do. No new permission dialog appears.
- **Disclosure.** Before the release, the Settings window and the field
  descriptions disclose the reach of input control. A chord sent to a
  terminal can type and run commands. Acceptance covers a new grant request,
  an existing grant after a restart and the field descriptions.
- **Limits.** The descriptions state two limits. The target can stop being
  the front app in the instant before it reads a chord. Then the target reads
  the chord as a background app, and no other app receives it. Space
  switching keeps a race that needs the shortcut setting or the Space to
  change in the same instant.
- The four agreed test seams (Pointers) pass, and so does the scheduled check
  on Antony's Mac.
- **Docs** describe the current state. They cover the design schema, the
  input contract, the authority and trace rows, the requirements rows and the
  glossary. They also cover the decision record on public Accessibility, the
  README and the client guide.
- **Koine 0.7.0 is released.** It is notarised, its release checks pass on
  the notarised build, and it is tagged. The GitHub release is published, the
  cask is bumped, and the Homebrew check passes. The app input checkbox in
  issue 11 is ticked.
- **Issues are filed.** One issue holds the other 11 rows of Zed, Zotero and
  Obsidian. Another issue holds the rows of Dia. Each case that acceptance
  defers is an issue, and so is each review finding that does not break the
  happy path.

## Decomposition

The leaves are flat siblings under the root, because they share this brief's
one scope. Their positions encode their dependencies.

1. `keystroke-route` (impl): the VM probe of route A, with a small signed
   instrument and a Taskfile task. It sends one chord each to Safari, Finder,
   Zed, Zotero and Obsidian with `CGEventPostToPid`. It checks the two route
   properties, and it settles how Koine reads the shortcut settings and
   counts Spaces. It goes first, because its result can change the core of
   the design.
2. `app-input` (design): the design of the input provider from the probe's
   evidence. It writes the schema, the contract text and the authority and
   trace rows. It also writes the disclosure text, the glossary terms and the
   version numbers. It adds per-process posting to the decision record on
   public Accessibility. It decides whether its design needs an adversarial
   review. It needs 1.
3. `input-keystrokes` (impl): the first input provider bundle, with target
   capture, the keystroke operation and the disclosure. It adds L and G
   tests. It needs 2.
4. `space-switching` (impl): Space switching with its checks, and L and G
   tests. It needs 3, because both leaves change the input schema.
5. `app-input-acceptance` (impl): the N check, the VM run and the scheduled
   check on Antony's Mac. It needs 3, 4 and any review.
6. `release-0-7-0` (impl): the version, notarisation, release checks on the
   notarised build, publishing and the issues. Antony approves each public
   step. It needs 5.

## Pointers

- Glossary: **Process incarnation**, **Public Accessibility boundary**,
  **Capability**, **Grant**, **Additional capability requirement**,
  **Shipped provider slot**, **Settings window** (`CONTEXT.md`).
- Requirements: `docs/requirements/modaliser-workflows.md`. The section
  "Requirement: separately grant input, menu invocation and window focus"
  applies. So do the workflow inventory rows "Desktop windows" and Safari to
  Zotero.
- Specs: `docs/specs/workflow-providers.md` designs the input provider. It
  owns the "Authority allocation", the "Operation-to-capability trace" and the
  "Test seams". Its authority rows for this grove are "Application keystrokes"
  and "Control-digit Space switching". Its trace rows are "Desktop windows",
  Safari to Zotero, and "Grant disclosure".
- `docs/specs/machine.md` is the machine contract. Its section "Reserved
  identities" says that a reserved-only catalogue entry cannot load from
  either root. So the released 0.6.0 host refuses an input bundle before
  load.
- Decision records that bind: `provider-authority-follows-effects`,
  `desktop-automation-uses-public-accessibility`,
  `desktop-capture-preserves-the-process-incarnation`,
  `first-party-provider-selection` and `bearer-grants-and-live-revocation`.
  The first fixes the provider boundary, and it requires the disclosure before
  input ships. The second accepts events that Koine posts at the HID event
  tap. The design leaf adds per-process posting to it.
- Modaliser is the reference implementation, at
  `~/Development/KeyboardDrivenUI/Modaliser`.
  `Sources/Modaliser/KeystrokeEmitter.swift` builds and posts a chord, and
  `InputLibrary.swift` exposes `send-keystroke`. Antony's configuration is
  `~/.config/modaliser/config.scm` with its `app-trees/*.scm` files.
- Koine precedents: the commit of `workspace-launch-k59` first bundled the
  workspace provider. It shows each file that a new provider bundle touches.
  `Fixtures/MediaKeyProbe` with `task fixture:media-key-music-vm` is a signed
  probe in a VM. The media key operation of desktop checks the consent and the
  posting access before it posts.
- **Test seams, agreed with Antony:**
  - *L*: a new target `InputProviderLogicTests` feeds plain values to the
    pure input logic module, and nothing sends an event. It covers the events
    of a chord in Modaliser's order, the key table and the refusal of an
    unknown key. It also covers the front-app decision, the protected targets
    and the Space-switch checks, from plain shortcut settings and a Space
    count.
  - *G*: `KoineServerTests` load the real input bundle and query it over
    loopback. Read-only and desktop-only grants cannot send a chord. Input
    control alone cannot switch a Space. A denied or revoked grant refuses.
    The tests also cover the descriptions and the served disclosure. If input
    requires a feature of the host, they cover the refusal by a host without
    it.
  - *G safety*: a G test calls the keystroke operation only where Koine
    refuses before it sends. A stale target and Koine's own process are two
    such cases. Route A keeps even a mistaken send inside the one named process.
    No G test switches a Space.
  - *N*: the compatibility tasks run the signed input bundle against the new
    host and the released 0.6.0 host. The new host loads it, and the 0.6.0
    host refuses it before load.
  - *V*: one TestAnyware VM run through a new Taskfile task, with independent
    witnesses. The Settings window states the disclosure for a new grant
    request, and for an existing grant after a restart. All 21 rows of Safari
    and Finder pass, and one row each in Zed, Zotero and Obsidian. Each app is
    in front for its rows.
  - *V refusals*: Koine refuses a chord for Safari while TextEdit is in front,
    and neither app changes. A Control-2 through the keystroke operation
    switches no Space. Space switching reaches Space 2 when the shortcut is
    enabled, and it refuses when the shortcut is disabled. No permission
    dialog appears.
  - *Host check*: on Antony's Mac, at a time he sets, Koine sends one harmless
    chord each to Dia and Telegram. Antony approves the chords before the
    check runs. The check proves route A for Chromium and Qt, not the rows of
    these apps.

## Notes

- **The human's delivery rule**, from issue 11:

<!-- tc: off because this is the human's rule, quoted verbatim -->

  > Each item becomes its own small grove that ends in a shipped release:
  > happy path first, one VM acceptance of that path, then GitHub issues for
  > edge cases, coverage and hardening.

<!-- tc: on -->

- **Modaliser is the guide.** Antony ruled this in the window layout grove:

<!-- tc: off because these are the human's words, quoted verbatim -->

  > We will use the modaliser mechanisms where possible - even if this
  > involves private API.

<!-- tc: on -->

  In this grove, he made his configuration and the Modaliser code the guide:

<!-- tc: off because these are the human's words, quoted verbatim -->

  > You should look at my current modaliser config and the modaliser code as a
  > guide to what is required here

<!-- tc: on -->

  Koine's authority rules still hold. So Koine closes the race that
  Modaliser's post at the HID event tap leaves open.
- **The front-app rule is Antony's:**

<!-- tc: off because these are the human's words, quoted verbatim -->

  > keys only go to the target if it's frontmost, otherwise refuse. So we
  > should eliminate the race between check and post

<!-- tc: on -->

- **Route A has no fallback.** If a configured app ignores a chord in its own
  event stream, the session stops and asks Antony. No session uses the post
  at the HID event tap for an app chord instead. Antony rejected a Koine
  keyboard tap, because that tap would see every keystroke in the session.
- **A private call is Antony's decision.** No public interface counts
  Spaces. Antony's ruling covers Modaliser's mechanisms, and Modaliser counts
  no Spaces. If the count needs a private call, the design leaf asks Antony
  before it adopts one.
- **A new permission dialog is a stop.** Koine needs its Accessibility
  consent only, and it already holds that consent. A dialog that names Koine
  is a new consent posture, which is Antony's decision.
- **GUI work runs only in TestAnyware VMs**, except for the scheduled check
  below. That covers sending a chord, switching a Space and starting
  `Koine.app`. Builds, `swift test` and `codesign` on the host are fine.
- **The scheduled check on Antony's Mac is the one exception.** His words:

<!-- tc: off because these are the human's words, quoted verbatim -->

  > you decide - but note that we can do some testing on this host machine,
  > as long as we schedule it

<!-- tc: on -->

  Antony sets the time. He approves the exact procedure and its chords
  before it runs. The procedure leaves his installed Koine, its grants and
  his apps as it found them. The check is no account-dependent acceptance,
  because it proves the toolkits and not the rows.
- **Rows that wait.** The VM cannot run Dia past its work-email gate. Issue
  #7 already holds that gate for Dia's page load, so the rows of Dia can join
  it. The account-dependent item of the roadmap keeps the rows of Mail,
  Slack, Signal, Messages and Telegram.
- **Served descriptions describe 0.7.0.**
- **Version numbers.** The application is 0.6.0. Desktop and workspace are
  1.0.2, with schema 1.0.2. The catalogue reserves input with no bundle, so
  this grove enables that slot. The design leaf chooses the new numbers. It
  also decides whether input requires a disclosure feature of the host, as
  desktop 1.0.2 requires `desktop-disclosures-v2`.
- **Docs edits convert first.** An existing document follows the
  technical-communication rules before an edit. Convert the touched sections
  as their own commit, and put the other sections in `pending` regions.
- **Use the Taskfile.** Each new check gets a task beside the existing ones,
  such as `design:app-input-check`, `compat:released-0.6.0` and
  `app:vm-verify-app-input`.
- **Out of scope:** held keys, such as Dia's recent-tab walk, belong to the
  held interactions item. Menu invocation, pointer buttons and typing a text
  string are not part of this grove. Keys to an app in the background, the VS
  Code screens and the chords of the iTerm and herdr libraries are out of
  scope too.
