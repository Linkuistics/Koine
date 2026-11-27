# app-input-k3

## Goal

Design the input provider for Koine 0.7.0 from the evidence of
`keystroke-route-k2`. It covers target capture, the keystroke operation and
Space switching. Write the design into the durable documents that the root
brief's "Docs" item names.

## Context

- The design leaf of the pointer and media grove is the precedent. Its schema
  is `docs/design/desktop-pointer-media-schema.graphql`, and its example
  operations are `docs/design/desktop-pointer-media-operations.graphql`.
  `task design:pointer-media-check` checks them.
- The verification record of `keystroke-route-k2` holds the probe's evidence.
  It says how Koine reads the shortcut settings and counts Spaces.
- `Providers/DesktopProvider/schema.graphql` shows the process identity
  `{ pid, startedAt }` and the receipt of `desktopPostMediaKey`.
- `Sources/KoineCore/CapabilityDisclosures.swift` holds the served disclosure
  texts. `Sources/KoineCore/Composition.swift` names the features of the host,
  such as `desktop-disclosures-v2`.
- The workflow providers spec gives Space switching an additional capability
  requirement for desktop control. The framework feature
  `additional-capabilities-v1` supports it.

## Done when

- A design schema and its example operations cover target capture, the
  keystroke operation and Space switching. A Taskfile task checks them.
- Each operation states its authority, its receipt and its failures. A chord
  goes to the target whether or not it is the front app, as Antony ruled in
  this leaf.
- The design names the refusals for a stale target, a protected target, an
  unknown key, a disabled or remapped shortcut and a missing Space.
- The design states how Koine reads the front app. It states that Koine
  refuses only itself as a target, as Antony ruled in this leaf.
- The input contract states the new surface. The leaf chooses whether that
  contract is a section of `docs/specs/machine.md` or a spec of its own.
- In `docs/specs/workflow-providers.md`, the authority rows and the trace rows
  "Desktop windows", Safari to Zotero and "Grant disclosure" match the design.
- The leaf checks the requirements rows "Desktop windows" and Safari to Zotero
  against the design, and it changes any row that disagrees.
- The disclosure text for input read and input control is final. It says that
  a chord sent to a terminal can type and run commands.
- The descriptions state the two limits of the root brief.
- The glossary names the new concepts, such as the chord, the front app, the
  protected target and the Space switch.
- `desktop-automation-uses-public-accessibility` accepts per-process posting.
  It also accepts how Koine reads the shortcut settings and counts Spaces.
- This task file records the new version numbers, and whether input needs a
  disclosure feature of the host.
- The leaf names the documents that each implementation leaf brings to the
  served state, the README and the client guide among them.
- The leaf decides whether its design needs an adversarial review, and it
  cuts the review leaf if so.

## Notes

- If the count of Spaces needs a private call, ask Antony before the design
  adopts it. His ruling on private calls covers Modaliser's mechanisms, and
  Modaliser counts no Spaces.
- The design chooses the operation shapes. For example, the keystroke
  operation can take a key and a set of modifiers, or a chord string such as
  "cmd+shift+t".
- Target capture can read the front app, as Modaliser reads it to choose a
  screen. A client then sends chords to that captured target.
- A refusal after the first event can leave a modifier key down in the
  target. State whether any refusal can occur after the first event.

## Decisions (running log)

**Contract placement.** The input contract is a spec of its own,
`docs/specs/app-input.md`. Input is a new provider, as workspace was, and
workspace has specs of its own. The machine contract keeps the shared
transport, the errors and the capability disclosures. So the input text in
`docs/specs/machine.md` is the disclosure entries and one changed sentence on
protected targets.

**Refusals are outcomes.** The provider framework has no field for a reason on
an error. `ProviderFailure` carries a kind, a message and a consent name only.
So the refusals that the brief names are enum outcomes of a control receipt,
as `POINTER_BUTTON_HELD` is for the nudge.

A stale target keeps the existing `unavailable` error. An unknown key fails GraphQL validation, because the key
is an enum. A desktop number outside 1 to 9 is an invalid argument. The
workflow providers spec and the machine contract said `unavailable` with a
reason `protected-target`. Both now say outcome.

**Operation shapes.** Two reads capture a target under `input:read`:
`inputFrontTarget` and `inputTarget(process:)`. The second takes the process
identity that the workflow providers spec designed. It also gives the G tests
a target that is never the front app.

The keystroke operation takes a key enum
and a list of modifiers, as `send-keystroke` takes a key and a modifier list.
A chord string would need a parser and a fourth kind of input error. Space
switching takes the desktop number as an integer.

**Front app.** Koine reads the front app with
`NSWorkspace.shared.frontmostApplication`, as Modaliser does. The call is
public. The target is the front app when the process identifier of that app
equals the target's, and the target incarnation is live.

**Shortcut check.** Koine compares the shortcut as the probe compared it. The
entry must be present and enabled. Its key code must be the digit's key code,
and its shift, control, option and command bits must be Control alone. Koine
ignores the character value.

**Protected targets.** Koine refuses its own process, any process with its own
bundle identifier, and eight apps by bundle identifier. The eight are
SecurityAgent, the Local Authentication agent, the Accessibility consent
alert, UserNotificationCenter, the CoreServices UI agent, loginwindow, the
screen saver and System Settings. A read of `Info.plist` on this Mac, macOS
27.2.1, gave each identifier.

The line is an app that grants consent, approves
an action or holds the privacy settings. System Settings is on the list for
that reason, and no configured row needs it. A terminal and a password manager
are not on the list, because the disclosure covers their reach.

The probe did not record which process showed the consent dialog for posting access. A
deferred issue asks which process shows each recognised dialog, and whether
macOS reports it as the front app.

**Target capture of any process.** `inputTarget(process:)` accepts any live
process, also one that is not an app. Such a process is never the front app.
So a G test can drive the whole keystroke path to `NOT_FRONT_APP` with a child
process, and Koine sends nothing.

**Check order.** Consent comes first, as for the nudge and the media keys.
Then come the target, the protection and the creation of every event. The
front check comes last, just before the posts, with no check between the
posts. So no refusal comes after the first event, and no refusal can leave a
modifier down in the target.

**Missing-owner cascade.** `inputSwitchSpace` declares `desktop:control` as an
additional requirement. Under the machine contract, a provider whose declared
owner is not admitted loses its whole contribution. So without the desktop
provider, the chords go too. Workspace has the same dependency on desktop.
The spec states it, and the review can challenge it.

**Version numbers and host feature.** The application becomes 0.7.0. The
input provider is release 1.0.0 with schema 1.0.0, bundle
`Input.koineprovider` and signing identifier `dev.antony.Koine.provider.input`.
Its manifest names framework major 1 with minimum minor 1, and the one
required feature `additional-capabilities-v1`. Desktop and workspace stay at
1.0.2 with schema 1.0.2.

Input needs no disclosure feature of the host. Every released host keeps the
input slot reserved-only, so it refuses an input bundle before load with the
reason `reserved-only`. No host can load input 1.0.0 without the 0.7.0
disclosures. A later input release that widens the reach adds a feature, as
the host-feature decision requires. The core advertises no new feature.

**Disclosure text.** The final `input:read` and `input:control` text is in
"Capability disclosures" of `docs/specs/machine.md`. The control text states
the terminal reach, the reach of app shortcuts and the protected targets. It
also states the first limit and, with `desktop:control`, the Space switch and
its race.

**Glossary.** `CONTEXT.md` gains front app, input target, chord, protected
target, Mission Control desktop and Space switch. "Mission Control desktop"
keeps the word "desktop" alone for the desktop provider.

**Requirements.** The rows "Desktop windows" and Safari to Zotero of
`docs/requirements/modaliser-workflows.md` agree with the design. Each app row
names behaviour that one chord or a repeated chord delivers. The recent-tab
walk of Dia stays with held interactions. So no row changes.

**Workflow providers spec.** The authority rows "Application keystrokes" and
"Control-digit Space switching" now state the design. The trace rows "Desktop
windows", Safari to Zotero and "Grant disclosure" name the coordinates and the
acceptance of each row. The paragraph on protected targets now says outcome.
That paragraph and the one in the machine contract converted first, in their
own change.

**Views.** The discussion views are in `docs/design/app-input`, with the
bundled viewer, four D2 sources and their SVG exports.
`task design:app-input-render` regenerates the exports, and
`task design:app-input-serve` serves them on port 8766. The shared
architecture presentation keeps its own discussion panel unchanged.

**Documents for each implementation leaf.** The leaves bring these documents
to the served state.

- `input-keystrokes-k4`:
  - `docs/specs/app-input.md`: the status, "Targets" and "Chords".
  - `docs/specs/machine.md`: the served text under "Capability disclosures",
    and the enabled slots under "Reserved identities".
  - `docs/specs/workflow-providers.md`: the trace rows Safari to Zotero and
    "Grant disclosure", and the authority row "Application keystrokes".
  - `README.md`: a paragraph on the input provider.
  - `docs/client-guide.md`: a section on target capture and chords.
  - The composed design file and the profile
    `core-desktop-input-workspace-extension-host`.
- `space-switching-k5`:
  - `docs/specs/app-input.md`: "Space switching".
  - `docs/specs/workflow-providers.md`: the trace row "Desktop windows" and
    the authority row "Control-digit Space switching".
  - `README.md` and `docs/client-guide.md`: the Space switch, with the rule for
    a client keyboard tap.
  - The composed design file and the profile.
- `app-input-acceptance-k6`: the verification records of the compatibility
  pairs, the VM run and the host check, and the evidence links of the trace
  rows.
- `release-0-7-0-k7`: the release paragraph in `README.md`, and the release
  checks of the notarised bundle.

**Adversarial review.** The design needs one. It fixes a public contract that
clients code against, and it sets an authority boundary for input to any app.
It also adds a private call if Antony adopts it. The session inserts a
`review-design` leaf before `input-keystrokes-k4`.

<!-- tc: depart synonym-rotation because "display" here names a monitor, a noun, and not the action "show" -->
**Count of Mission Control desktops.** Antony chose the private SkyLight call
and a count across all displays. His answer, in his own words:

<!-- tc: off because these are the human's words, quoted verbatim -->

> SkyLight, and count desktops across all displays.

<!-- tc: on -->

Koine looks up `SLSMainConnectionID` and `SLSCopyManagedDisplaySpaces` with
`dlopen` and `dlsym` when it first needs them. A strong link would stop the
whole provider from loading if a macOS release removed a symbol. When a symbol
is missing, or the reply has another form, a Space switch reports `failed` and
posts nothing. Chords still work.

Koine counts the Spaces of type 0 on every display, in the order of the reply,
and skips every other type. The probe had one display and no full-screen
Space, so this numbering is unproven. A deferred issue asks for a check with
two displays and a full-screen app. A setting that macOS has not applied stays
a stated limit, also with a deferred issue.

**System Settings is not protected.** Antony ruled that the capabilities of
Koine govern a chord to System Settings. His words:

<!-- tc: off because these are the human's words, quoted verbatim -->

> It doesn't exclude system settings - that is a matter for the
> capability-based security system within Koine.

<!-- tc: on -->

So the protected list keeps seven apps. Each grants consent, approves an
action or locks the screen. The `input:control` disclosure states that a
chord can change settings in System Settings. The consent and security
dialogs stay protected, as the root brief requires.

**Chords reach a target in the background.** Antony dropped the front check,
because his goal is a substitute for the computer use of an LLM harness. That
use controls windows that are not in front. His answer, in his own words:

<!-- tc: off because these are the human's words, quoted verbatim -->

> drop the front check. pointer control is a separate item - update the
> issue to add this to the checklist. I want everything available, covered by
> capabilities.

<!-- tc: on -->

Route A keeps every chord inside the target process, so the front check
protected no other app. Koine now sends a chord whether or not the target is
the front app, and it still never brings the target to the front. The outcome
`NOT_FRONT_APP` goes. The first limit of the root brief goes too, because no
check remains to race. A new limit replaces it. An app in the background can
ignore a chord, act on a window behind other apps, or come to the front.

`inputTarget(process:)` now returns null for a process that macOS does not
report as an app. Before, the front check refused such a process. The G
safety case of a child process goes with it.

**Pointer control is a separate roadmap item.** Pointer control of a window
that is not in front needs another mechanism and its own probe. This session
adds it to the checklist of issue 11, as Antony asked. It is not part of this
grove.

**Every app is a target under the capabilities.** The protected list goes.
A consent, password or security prompt of macOS is an ordinary target under
`input:control`, and the disclosure states that reach. So the deferred issue on
the process of each dialog goes.

Koine itself stays refused, with the outcome `PROTECTED_TARGET`. A chord to the
Settings window of Koine could approve the grant request of the client that
sends it. Then `input:control` would give every capability, and the
capabilities would cover nothing. Space switching refuses only while Koine is
the front app.

**The root brief follows these rulings.** The goal, the items "Front app",
"Protected targets" and "Limits", the seams L and V and the scope notes now
state them. This leaf's own "Done when" changes in the same way.
