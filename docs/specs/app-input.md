# App input

**This design delivers app input in Koine 0.7.0. This tree serves target
capture and chords, and it does not serve Space switching yet.** App input is
the first input provider, release 1.0.0 with schema 1.0.0. It captures a target
app, and it sends one chord to that app, in front or in the background. It also
switches between the desktops of Mission Control. The design is
in the [input design](../design/input-schema.graphql), with
[example operations](../design/input-operations.graphql), and
`task design:app-input-check` checks both.

The [machine contract](machine.md) owns the transport, the grants, the errors
and the capability disclosures. The
[workflow providers spec](workflow-providers.md#authority-allocation) allocates
the authority of every workflow effect. This spec owns the input surface. The
[app input views](../design/app-input/index.html#discussion) draw its two flows
and its two routes.

## Problem

Modaliser sends a keyboard shortcut to the front app for each row of an app
screen. Antony's configuration has such rows for Safari, Finder, Zed, Zotero,
Obsidian and other apps. Its "Switch Space" row sends Control and a digit, so
that macOS switches to that Mission Control desktop. A Koine client needs both actions, under
grants that a person can give apart from window focus and menu invocation.

Modaliser posts each chord at the HID event tap. There, the chord goes to
whichever app is in front when macOS reads it. So a chord can reach another
app than the one that Modaliser checked. Antony ruled that a chord must reach
only its target. He also wants Koine to stand in for the computer use of an
LLM harness, which controls windows that are not in front.

## Solution

A client captures a target under `input:read`. Then it sends a chord to that
target under `input:control`, whether or not the target is the front app.
Koine posts the events of the chord into the event stream of the target
process with `CGEventPostToPid`. So a chord reaches only the target,
whichever app is in front. The one exception needs macOS to reuse the process
identifier of the target during the posts, as
[Sending a chord](#sending-a-chord) explains.

Space switching is a separate operation under `input:control` and
`desktop:control`. Koine posts Control and the digit at the HID event tap,
because macOS must catch the chord there. Before it posts, it reads the
shortcut setting and the Mission Control desktops. It refuses each case where
these reads show that the chord would reach the front app instead. The
[limits of Space switching](#limits-of-space-switching) name the cases that the
reads cannot show.

Each refusal that sends nothing is an outcome of the receipt, as
`POINTER_BUTTON_HELD` is for the pointer nudge. A provider error carries a
kind and a message, and no reason that a client can read.

## Targets

### Target capture

An input target names one process incarnation. Two reads return one, and each
needs `input:read`:

- `inputFrontTarget` returns the front app. It is null when macOS reports no
  front app.
- `inputTarget(process:)` returns the process incarnation that the client
  captured, as `{ pid, startedAt }`. The identity follows the
  [capture decision](../adr/desktop-capture-preserves-the-process-incarnation.md).
  An absent process, a live process identifier with another start instant,
  or a process that is not an app is ordinary null.

A target gives the name and the bundle identifier of the app, its protection,
and a reference. The name is the localised name that macOS reports. When macOS
reports none, the name is the name of the executable. A client chooses its rows
by the bundle identifier, as Modaliser chooses a screen.

A target is always an app. Koine treats a process as an app when
`NSRunningApplication` reports it. So a command-line tool or another process
that is not an app gives null, and Koine never sends it a chord.

The reference is an input reference, `koine://input/target/<pid>/<start>`. The
start is the start instant in whole microseconds since the Unix epoch. The
reference names the incarnation, and Koine resolves it again on every use. It
is not a desktop reference, and the two cannot be converted. A target that is
protected has no reference.

### Protected targets

Koine refuses one protected target, Koine itself. It recognises Koine by the
process identifier of the Koine process, and by the bundle identifier of
Koine. It refuses Koine before it issues a reference, and again before it
sends a chord. A client can build an input reference for any incarnation, so
the second check is the one that holds.

Koine refuses itself because a chord to its Settings window could approve the
grant request of the client that sends it. Then `input:control` would give
every capability, and the capabilities would cover nothing.

Every other app is a target under the capabilities, as Antony ruled. A chord
can answer a consent, password or security prompt of macOS. It can change a
setting in System Settings, and it can act in a terminal or a password
manager. The `input:control` disclosure states this reach.

## Chords

A chord is one key with its modifier keys, such as Command-L.
`inputSendKeystroke(target:, key:, modifiers:)` sends one chord to one target
under `input:control`.

### The keys

The key is a value of `InputKey`. Each value names one key of the US ANSI
layout by its key code, as Modaliser's key table does. The table below omits
Modaliser's modifier keys and its alternative names. A modifier key alone is a
held key, which belongs to held interactions.

| Values | Key codes |
| --- | --- |
| `A` to `Z`, top row | Q 12, W 13, E 14, R 15, T 17, Y 16, U 32, I 34, O 31, P 35 |
| `A` to `Z`, middle row | A 0, S 1, D 2, F 3, G 5, H 4, J 38, K 40, L 37 |
| `A` to `Z`, bottom row | Z 6, X 7, C 8, V 9, B 11, N 45, M 46 |
| `DIGIT_0` to `DIGIT_9` | 1 18, 2 19, 3 20, 4 21, 5 23, 6 22, 7 26, 8 28, 9 25, 0 29 |
| Punctuation | `EQUAL` 24, `MINUS` 27, `RIGHT_BRACKET` 30, `LEFT_BRACKET` 33, `QUOTE` 39, `SEMICOLON` 41, `BACKSLASH` 42, `COMMA` 43, `SLASH` 44, `PERIOD` 47, `GRAVE` 50 |
| Other keys | `RETURN` 36, `TAB` 48, `SPACE` 49, `DELETE` 51, `ESCAPE` 53, `LEFT` 123, `RIGHT` 124, `DOWN` 125, `UP` 126 |
| Function keys | `F1` 122, `F2` 120, `F3` 99, `F4` 118, `F5` 96, `F6` 97, `F7` 98, `F8` 100, `F9` 101, `F10` 109, `F11` 103, `F12` 111 |

A key is a key position, not a character. With another keyboard layout, the
app can read another character for the same key. An unknown key is not a
value of `InputKey`, so GraphQL validation refuses the request before any
execution.

The modifiers are a list of `InputModifier` values: `CONTROL`, `SHIFT`,
`OPTION` and `COMMAND`. The list is a set. A value that it holds twice counts
once, and the order in the list does not matter.

### The events of a chord

Koine builds the events of a chord as Modaliser's `send-keystroke` builds them:

1. A key-down event for each modifier, in the order Control, Shift, Option and
   Command. Each event carries the flags of the modifiers that are down so far.
2. A key-down event and a key-up event for the key. Both carry the flags of
   every modifier of the chord.
3. A key-up event for each modifier, in the reverse order. Each event carries
   the flags of the modifiers that are still down.

So a chord has between 2 and 10 events, and it ends with every modifier
released. Each event comes from an event source with the combined session
state, as in Modaliser and the probe. Koine puts no tag in the events.

### The front app

The front app is the app that macOS reports as active. It receives the
keyboard. Koine reads it with `NSWorkspace.shared.frontmostApplication`, as
Modaliser does. The call is public. `inputFrontTarget` returns it, and a
Space switch reads it to refuse while Koine is in front. A chord does not read
it.

AppKit keeps the front app from the activation notices of macOS. So the value
that Koine reads can lag a change of the front app for a short time.

### Sending a chord

The provider acts in this order:

1. Without Accessibility consent or without posting access, it reports
   `os-permission` and sends nothing.
2. It resolves the target. A malformed or wrong-kind reference, an ended
   process or a process with another start instant raises `unavailable`.
   Koine sends nothing.
3. When the target is Koine, the outcome is `PROTECTED_TARGET`. Koine
   sends nothing.
4. When macOS does not report the process as an app, it raises
   `unavailable`. Koine sends nothing.
5. It creates every event of the chord. When macOS does not create one, it
   reports `failed` and sends nothing.
6. It posts every event in order with `CGEventPostToPid` to the target
   process, with no check between the events. The outcome is `SENT`.

Koine checks itself before it checks for an app. So it refuses its own process
by the process identifier, whether or not macOS reports that process as an app.

Every check comes before the first event, so no refusal can leave a modifier
down in the target. `CGEventPostToPid` reports no result, so Koine
cannot detect an event that macOS drops.

`CGEventPostToPid` names the process by its process identifier alone, without
the start instant. So the checks of steps 2 to 4 bind the posts only while
macOS keeps that process identifier for the target. If the target ends during
the posts, the remaining events go to a process identifier that no process
holds. They reach another process only if macOS first issues that identifier
to a new process.

macOS issues process identifiers in sequence, and it issues one again only
after it cycles through the whole range. In the
[PID-recycling diagnostic](../verification/retained-ax-binding.md), PID 781 came
back after 99,413 allocations. So between the checks and the last post, a new process
can take the identifier only if macOS cycles through the whole range. Koine
accepts this limit, as the
[public Accessibility decision](../adr/desktop-automation-uses-public-accessibility.md)
accepts process reuse.

Koine never brings the target to the front, and it never focuses a window
first. A client that wants another app in front uses a desktop operation under
its own grant. The app's own reaction to a chord is not a Koine effect. A
chord can make the app open or focus a window, or come to the front.

### What a chord reaches

A chord posted with `CGEventPostToPid` enters the event stream of the target
process, after the session event tap. The
[route probe](../verification/keystroke-route-vm.md) established four
consequences in a VM:

- Safari, Finder, Zed, Zotero and Obsidian acted on such a chord while in front.
- Finder in the background acted on Command-N. It opened a window and came to
  the front. The probe sent no other chord to an app in the background.
- A Control-2 sent this way switched no Space. So a chord skips the system
  shortcuts, and the operation needs no list of refused chords.
- A keyboard tap at the session level did not see the chord. So a tap at the
  session level, a client's tap included, does not see it.

The probe created no tap for the target process. The macOS SDK header says
that a per-process post enters before the taps for the target process, and
that the event passes through them. A process with the needed access can
create such a tap with `CGEventTapCreateForPid`. So a tap for the target
process sees the chord, whichever process created that tap.

### Limits of a chord

- **An app in the background acts in its own way.** It can ignore a chord,
  act on a window behind other apps, or come to the front. The front app does
  not receive the chord instead.
- **A tap for the target process sees the chord.** Only a tap at the session
  level misses it.
- **A reused process identifier.** If macOS issues the identifier of the
  target to a new process during the posts, that process can receive the rest
  of the chord.
- **The keys are US ANSI positions.** Another keyboard layout can give the
  app another character.
- **The receipt says only that Koine sent the chord.** It does not say what
  the app did.

## Space switching

`inputSwitchSpace(number:)` switches to Mission Control desktop 1 to 9. It
needs `input:control` and `desktop:control`. A Mission Control desktop is a
Space that Mission Control names "Desktop N". A full-screen app has a Space
too, but that Space is not a Mission Control desktop.

### The shortcut setting

The "Switch to Desktop N" shortcuts of Mission Control are the entries 118 to
126 of `AppleSymbolicHotKeys` in the preferences domain
`com.apple.symbolichotkeys`. Entry 117 + N is for Mission Control desktop N. Koine reads the entry
with `CFPreferencesAppSynchronize` and `CFPreferencesCopyAppValue`. It never
writes the domain.

The call is public. Apple does not document the domain or its entries, so the
[route probe](../verification/keystroke-route-vm.md#how-koine-can-read-the-shortcut-for-control-and-a-digit)
is the evidence for its form. An entry holds `enabled` and three parameters:
the character, the key code and the modifier mask. Koine compares the entry
more strictly than the probe did:

- An absent entry acts as a disabled one. An absent entry or a disabled one
  gives `SHORTCUT_OFF`.
- The key code must be the key code of the digit in the key table above. The
  mask must equal 262144, which is Control and no other bit. Otherwise the
  outcome is `SHORTCUT_REMAPPED`. Koine ignores the character.
- An entry in another form, such as one without three integer parameters, is
  `failed`.

The mask admits no other bit, because it can hold more modifiers than the four
that Koine posts. On Antony's Mac, the entries 7 and 8 hold the mask 8650752, which is Control
with the Fn bit 8388608. Koine posts no Fn flag. No evidence shows that macOS
ignores such a bit when it matches a shortcut. So Koine refuses the entry,
rather than post a chord that macOS may pass to the front app. In the probe
and on Antony's Mac, each enabled entry from 118 holds the mask 262144 exactly.

### The Mission Control desktops

No public interface counts the Mission Control desktops. Koine counts them with
the private SkyLight call `SLSCopyManagedDisplaySpaces`, as Antony chose.
SkyLight is the private framework of the macOS window server. In the
[route probe](../verification/keystroke-route-vm.md#how-koine-can-count-spaces),
the call gave the live desktops at once after each change.

Koine looks up `SLSMainConnectionID` and `SLSCopyManagedDisplaySpaces` with
`dlopen` and `dlsym` when it first needs them. The desktop provider looks up
its private window lookup in the same way. A strong link would stop the whole
provider from loading if a macOS release removed a symbol. When a symbol is
missing, Koine reports `failed` and posts nothing. Chords do not use the call.

<!-- tc: depart synonym-rotation because "display" here names a monitor, a noun, and not the action "show" -->
The reply holds an entry for each display, and each entry lists its Spaces
with a type. Type 0 is a desktop, and type 4 is a full-screen Space. Koine
counts the Spaces of type 0 on every display, in the order of the reply. It
skips every other type. A reply in another form is `failed`.

The preferences domain `com.apple.spaces` gives a count through a public call.
Koine does not use it, because Apple does not document its form. On Antony's
Mac it kept 19 display entries where SkyLight reported one. In the probe, its
current Space lagged.

### Switching

The provider acts in this order:

1. A number outside 1 to 9 is an invalid argument. Koine attempts nothing.
2. Without Accessibility consent or without posting access, it reports
   `os-permission` and posts nothing.
3. It reads the shortcut entry for the number. The outcome can be
   `SHORTCUT_OFF` or `SHORTCUT_REMAPPED`, and Koine posts nothing.
4. It counts the Mission Control desktops. When Koine cannot count them, it
   reports `failed` and posts nothing. When there are fewer than the number,
   the outcome is `NO_SUCH_DESKTOP`, and Koine posts nothing.
5. It creates four events: Control down, the digit down and up with the
   Control flag, and Control up. When macOS does not create one, it reports
   `failed` and posts nothing.
6. When Koine is the front app, the outcome is `PROTECTED_FRONT_APP`.
   Koine posts nothing.
7. It posts the four events in order at the HID event tap, with no check
   between them. The outcome is `POSTED`.

With the shortcut on and the Mission Control desktop present, macOS takes the digit and
switches the Space. The front app then receives Control down and up only. The
receipt does not say that the Space changed.

The four events pass the session event tap, so a keyboard tap of a client sees
them. Their source process, `kCGEventSourceUnixProcessID`, is Koine. A client
that holds keys back in its own mode passes these events, or it ends that mode
before it calls the operation.

### Limits of Space switching

- **The race.** The shortcut setting or the Mission Control desktops can
  change in the instant before macOS reads the chord. Then the front app can
  receive Control and the digit.
- **A setting that macOS has not applied.** Koine reads what the preferences
  hold. A value written without the step that applies it can differ from what
  macOS does. The probe did not test this case.
<!-- tc: depart synonym-rotation because "display" here names a monitor, a noun, and not the action "show" -->
- **Several displays and full-screen Spaces.** Koine numbers the desktops of
  all displays in the order of the SkyLight reply. The probe had one display
  and no full-screen app, so it did not show how macOS numbers them. If macOS
  numbers them another way, the front app can receive Control and the digit.

## Authority, consent and failures

| Field | Capability |
| --- | --- |
| `inputFrontTarget`, `inputTarget` and every field of `InputTarget` | `input:read` |
| `inputSendKeystroke` and every field of `InputKeystrokeReceipt` | `input:control` |
| `inputSwitchSpace` and every field of `InputSpaceSwitchReceipt` | `input:control` and the additional requirement `desktop:control` |

Read does not imply control, and control does not imply read. A client that
holds a reference can send a chord with `input:control` alone. A capability
error on `inputSwitchSpace` carries `requiredCapabilities` as
`["input:control", "desktop:control"]`. Input declares no other additional
requirement.

The [additional capability rules](machine.md#additional-capability-requirements)
make the desktop provider an owner of the input contribution. If the desktop
provider is not admitted, the missing-owner cascade removes the whole input
contribution, the chords included.

A chord and a Space switch post events under the Accessibility consent of
Koine, as the media keys do. The probe established that `CGEventPostToPid`
needs posting access, as the post at the HID event tap does. So both
operations check `AXIsProcessTrusted` and `CGPreflightPostEventAccess` before
any other step.

Neither check asks for consent, and no operation calls
`CGRequestPostEventAccess`. So no new permission dialog appears. The error
names `accessibility`, and its message names the access that macOS withholds.
The target capture needs no consent.

| Condition | Result |
| --- | --- |
| A capture without `input:read`, a chord without `input:control`, or a Space switch without both control capabilities | `permission`, `capability`. Koine refuses before any effect. |
| An unknown key or modifier | GraphQL validation, or input coercion for a variable. No execution. |
| A number outside 1 to 9 at a Space switch | An invalid argument at the field's path, with no `kind`. Koine attempts nothing. |
| No Accessibility consent or no posting access | `permission`, `os-permission`, `accessibility`. Koine sent nothing. |
| A malformed, wrong-kind or stale input reference, or a process that is not an app, at a chord | `unavailable`. Koine sent nothing. |
| A target that is Koine | The outcome `PROTECTED_TARGET`, with no error. Koine sent nothing. |
| The shortcut is off or absent, or it uses another key | The outcome `SHORTCUT_OFF` or `SHORTCUT_REMAPPED`, with no error. Koine posted nothing. |
| The Mission Control desktop does not exist | The outcome `NO_SUCH_DESKTOP`, with no error. Koine posted nothing. |
| Koine in front at a Space switch | The outcome `PROTECTED_FRONT_APP`, with no error. Koine posted nothing. |
| macOS does not create an event, a shortcut entry has another form, or Koine cannot count the Mission Control desktops | `failed`. Koine posted nothing. |
| No front app, or an absent or non-app captured process, at a capture | Null, with no error. |

The [provider authority decision](../adr/provider-authority-follows-effects.md)
allocates application input and bounded Space switching to input. The
[desktop automation decision](../adr/desktop-automation-uses-public-accessibility.md)
covers the posting route, the shortcut read and the count of Mission Control desktops.

## Versions and composition

- The application is 0.7.0. The input provider is release 1.0.0 with schema
  1.0.0, bundle `Input.koineprovider` and signing identifier
  `dev.antony.Koine.provider.input`. The sealed catalogue enables the input
  slot with them.
- The manifest names framework major 1 with minimum minor 1, and the required
  feature `additional-capabilities-v1`.
- Input requires no disclosure feature of the host. Every released host keeps
  the input slot reserved-only, so it refuses an input bundle before load with
  the reason `reserved-only`. A later input release that widens the reach adds a
  disclosure feature, as the
  [host-feature decision](../adr/native-workspace-requires-disclosure-capable-host.md)
  requires.
- Desktop and workspace stay at release 1.0.2 with schema 1.0.2. The core
  advertises no new host feature.
- In canonical order, input composes between the desktop and workspace providers. The signed
  application serves the conformance profile
  `core-desktop-input-workspace-extension-host`. Its design is the
  [composed schema](../design/desktop-input-workspace-schema-extension-host.graphql).
  This tree composes target capture and chords there, and `space-switching-k5`
  adds the Space switch. A test holds the served composition to that file.

The `input:read` and `input:control` disclosures are in the machine contract,
under [capability disclosures](machine.md#capability-disclosures).

## Test seams

The seams are the four that Antony agreed for this grove:

- **L.** A test target `InputProviderLogicTests` feeds plain values to the pure
  input logic. Nothing sends an event. It covers the events of a chord in
  order, the key table and the set of modifiers. It also covers the refusal
  of Koine and the Space-switch checks, from plain shortcut entries and plain
  lists of Spaces with their types. A mask with an extra bit, such as the Fn
  bit, gives `SHORTCUT_REMAPPED`.
- **G.** `KoineServerTests` load the real input bundle and query it over
  loopback. Read-only and desktop-only grants cannot send a chord. Input
  control alone cannot switch a Space. A denied or revoked grant refuses. The
  tests cover the descriptions and the served disclosures.
- **G safety.** A G test calls the keystroke operation only where Koine
  refuses before it sends. A stale target and the Koine process are two such
  cases. No G test switches a Space.
- **N.** The compatibility tasks run the signed input bundle against the new
  host and the released 0.6.0 host. The new host loads it, and the 0.6.0 host
  refuses it before load.
- **V.** One TestAnyware VM run, with independent witnesses. It checks the
  disclosures, the 21 rows of Safari and Finder, and one row each in Zed,
  Zotero and Obsidian. With TextEdit in front, a chord reaches Safari in the
  background, and TextEdit does not change. The run also checks the refusals
  that the root brief lists. A scheduled check on Antony's Mac sends one
  harmless chord each to Dia and Telegram.

The L and G seams pass for target capture and chords.
[InputProviderLogicTests](../../Tests/InputProviderLogicTests) hold the key
table, the events of a chord, the input reference, the protection of Koine and
the order of the steps. [InputProviderTests](../../Tests/KoineServerTests/InputProviderTests.swift)
hold the authority, the descriptions, the served disclosures and the captures.
They send a chord only where Koine refuses before it sends. On a host without
Accessibility consent, each such send reports `os-permission` first. The
L seam and the G seam of Space switching come with `space-switching-k5`.

## Out of scope

- Held keys, such as Dia's recent-tab walk, belong to held interactions.
- Menu invocation, pointer buttons and typing a text string.
- Pointer control of a window that is not in front. It is its own item in
  issue 11.
- The screens of VS Code, and the chords of the iTerm and herdr libraries.
- A post at the HID event tap for an app chord. Route A has no fallback.
- A Koine keyboard tap. Antony rejected it, because it would see every
  keystroke in the session.
