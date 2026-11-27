# plan-k1

## Goal

Agree with Antony the happy-path scope of app input and its test seams. App
input is the next item of the roadmap in GitHub issue 11. Then write the root
brief and cut the leaves after this one.

## Context

- The roadmap is GitHub issue 11. Three items shipped: app and file search in
  Koine 0.4.0, window layout in Koine 0.5.0, and pointer and media in Koine
  0.6.0. The next open checkbox is "App input: keyboard input to a specific
  app, Space switching, configured app-shortcut rows".
- Antony asked that his current Modaliser configuration and the Modaliser code
  guide what app input requires. The running log below quotes his words.
- The configuration is `~/.config/modaliser/config.scm` with its
  `app-trees/*.scm` files. The "Switch Space" row sends Control and a digit
  from 1 to 9. Each app-shortcut row sends one chord to the front app.
- The app screens of the requirements are Safari, Dia, Finder, Mail, Slack,
  Zed, Signal, Messages, Telegram, Obsidian and Zotero. Each row on them is one
  `send-keystroke` call. Antony deferred the VS Code screens.
- Modaliser's `KeystrokeEmitter.swift` posts each chord at the HID event tap,
  so the chord reaches the front app. It posts each modifier as a key-down
  before the key and as a key-up after it. It tags each posted event, so that
  its own keyboard tap lets the event pass.
- Modaliser chooses the F17 screen from the bundle identifier of the front
  app. Its overlay panels do not activate Modaliser, so the front app keeps
  the keyboard.
- Dia's recent-tab walk holds Control with `send-key-down`. The roadmap gives
  that walk to the held interactions item.
- Modaliser's iTerm library and herdr library also send chords. Some of their
  actions send two chords in a row. Their rows belong to later roadmap items.
- The requirements are in `docs/requirements/modaliser-workflows.md`. The
  section "Requirement: separately grant input, menu invocation and window
  focus" applies. So do the inventory rows "Desktop windows" and Safari to
  Zotero.
- `docs/specs/workflow-providers.md` designs the `input` provider. A keystroke
  needs `input:control`. Space switching needs `input:control` and
  `desktop:control`. It checks the configured binding and refuses a known
  fall-through before it posts.
- The same spec makes input refuse Koine's own process and recognised consent
  or security UI. App input must disclose that input to a terminal can type
  and run commands.
- `docs/adr/provider-authority-follows-effects.md` fixes the provider
  boundary. `docs/adr/desktop-automation-uses-public-accessibility.md` already
  accepts events that Koine posts at the HID event tap. A receipt for such an
  event says only that Koine posted it.
- The sealed catalogue `App/ProviderCatalogue.json` reserves `input` and names
  no bundle for it. So this grove ships the first input provider bundle.
- The VM tooling installs Zed, Zotero, Obsidian and Dia from their casks, as
  `scripts/launcher-apps.json` records. Without an account, Dia stops at a
  work-email gate, and Mail stays behind its Add Account sheet. Obsidian stops
  at its vault chooser.

## Done when

- Antony agreed to the happy-path scope of app input and to its test seams.
- The running log below records each decision that settled.
- The root brief holds the settled scope, and the leaves after this one exist.

## Notes

## Decisions (running log)

**Guide to the requirements.** On 2026-11-27, Antony asked that his current
Modaliser configuration and the Modaliser code guide what app input requires:

<!-- tc: off because these are the human's words, quoted verbatim -->

> You should look at my current modaliser config and the modaliser code as a
> guide to what is required here

<!-- tc: on -->

**Roadmap item and scope.** This grove delivers app input, the next open
checkbox of the roadmap in issue 11, as Koine 0.7.0. It ships the first input
provider. Koine ports Modaliser's keystroke call and its Control-digit Space
row. On 2026-11-27, Antony accepted the proposed scope with one change. The
next entry holds that change.

The accepted scope has these parts:

- Under input control, Koine sends one chord to the target. Modifier key-down
  events come before the key, and modifier key-up events come after it, as in
  `send-keystroke`. The keys are Modaliser's key table.
- Koine checks its Accessibility consent and its posting access before it
  sends, as the media keys do. It asks for no new consent.
- Under input control and desktop control, Koine posts Control and a digit
  from 1 to 9. It reads the shortcut settings first, and it changes nothing.
  It refuses when the shortcut is disabled or remapped, or when the Space does
  not exist.
- Koine refuses its own process and recognised consent or security dialogs as
  targets. Space switching also refuses while one of them is in front.
- A receipt says only that Koine sent the chord.
- Before the release, the Settings window and the field descriptions disclose
  the reach of input control. A chord sent to a terminal can type and run
  commands.
- The app-shortcut rows stay client configuration. Each row becomes one
  keystroke call.
- These are out of scope: held keys, menu invocation, pointer buttons and
  typing a text string. So are keys to an app in the background and the VS
  Code screens.

Two parts of the first proposal depend on how Koine sends a chord. They are
the refusal of chords that macOS catches as system shortcuts, and the marking
of posted events for a client's keyboard tap. The next decision settles them.

**The front-app rule.** On 2026-11-27, Antony restated the rule in his own
words, and he added a requirement:

<!-- tc: off because these are the human's words, quoted verbatim -->

> keys only go to the target if it's frontmost, otherwise refuse. So we should
> eliminate the race between check and post

<!-- tc: on -->

So Koine sends a chord only while the target is the front app. Otherwise it
refuses and sends nothing, and it never activates the target. The race between
the check and the post must go. This requirement replaces the race limit of the
first proposal. The next entry settles the mechanism that removes the race.

**How Koine sends a chord.** On 2026-11-27, Antony chose route A with the
answer "A". This route implements the rule that he restated in the previous
entry.

Koine checks that the target is the front app. Then it sends the chord into
the target's own event stream with `CGEventPostToPid`. The macOS SDK header
documents this call as the way to route an event to a chosen app. It says that
the call posts the event "immediately before any event taps instantiated for
the specified process". Koine never posts an app chord at the HID event tap, so
no other app can receive the chord.

The decision has these consequences:

- The chord skips the session-level point where macOS checks system
  shortcuts. So the keystroke operation needs no list of refused chords. A VM
  probe checks that a Control-2 sent this way switches no Space.
- A keyboard tap of a client at the session level does not see the chord. So
  Koine marks no event for client taps. The VM probe checks this too.
- Route A is not Modaliser's mechanism. Before any implementation, the VM
  probe proves that the configured apps act on a chord in their own stream. If
  an app fails, the probe session stops and asks Antony. No session uses the
  HID post instead.
- The target can stop being frontmost in the instant before it reads the
  chord. Then the target reads the chord as an app that has just gone to the
  background. No other app is involved. The descriptions state this limit.
- Space switching still posts at the HID event tap, because macOS must catch
  its chord. Its race needs the shortcut setting or the Space to change in
  that same instant, and then the chord reaches the front app. The
  descriptions state this limit too.
- Antony rejected route B, which keeps Modaliser's post and adds a Koine
  keyboard tap that drops a misrouted chord. That tap would let Koine see
  every keystroke in the session.

**Rows that the acceptance checks.** On 2026-11-27, Antony left this choice
to the session. He also said that a scheduled test on his Mac is possible:

<!-- tc: off because these are the human's words, quoted verbatim -->

> you decide - but note that we can do some testing on this host machine, as
> long as we schedule it

<!-- tc: on -->

The risk of route A depends mainly on the toolkit of each app. So the session
chose this breadth:

- The VM run checks all 21 rows of Safari and Finder. It also checks one row
  each in Zed, Zotero and Obsidian. So it proves route A for AppKit, for the
  own toolkit of Zed, for the engine of Firefox and for Electron.
- One scheduled check on Antony's Mac sends one harmless chord each to Dia
  and Telegram. A fresh VM cannot run these apps without an account. So this
  check proves route A for Chromium and Qt. It proves the toolkits, not the
  rows.
- Antony sets the time of the host check. He approves its chords before it
  runs.
- An issue holds the other 11 rows of Zed, Zotero and Obsidian. Another issue
  holds the rows of Dia, because its work-email gate stops a fresh install.
- The account-dependent item of the roadmap keeps the rows of Mail, Slack,
  Signal, Messages and Telegram.

A host check is the exception. GUI tests run in TestAnyware VMs unless Antony
schedules a check on his Mac. The requirements say that acceptance does not
use Antony's live desktop. Antony's words above permit a scheduled exception.

**Test seams and plan.** On 2026-11-28, Antony agreed to the test seams and to
the plan of six leaves with the answer "yes". The question also stated the
two limits that the descriptions will state. This answer completes the shared
understanding. The root brief records the agreed seams under its pointers.
The six leaves follow this one in the order of the plan.

The seams reuse Koine's four existing seams: L, G, N and V. The input
provider gets its own logic test target, as desktop and workspace have. A G
test calls the keystroke operation only where Koine refuses before it sends,
and no G test switches a Space. The scheduled check on Antony's Mac is the one
exception to the rule that GUI checks run in VMs.
