# Desktop automation uses public Accessibility, with a private window order and Space count

Koine uses public macOS Accessibility APIs for window listing, focus, window
frames and notifications. Every action goes to a held public element. The
[capture decision](desktop-capture-preserves-the-process-incarnation.md) fixes
the process identity that a client submits. Koine checks it before AX work and
never substitutes another process under it. Public AX routing is a separate
boundary, and Koine keeps it on a best-effort basis.

Koine also uses Modaliser's mechanisms where it can, including private API.
Window order and visibility come from the private `_AXUIElementGetWindow`
lookup and the window server's on-screen list. Where the lookup disagrees with
the list, Koine matches by owner and bounds. Where neither settles a window,
Koine reports its order and visibility as unknown, never as visible. The
[window identity decision](desktop-window-identity-is-a-held-element.md) keeps
these links out of identity.

Bounds alone cannot tell apart two windows of one application with equal
bounds. The private lookup can, and it needs no new consent. Neither Koine nor
Modaliser has tried public matching with an Accessibility hit test. Screen Recording consent would add only window titles, which
are not unique, and it is a consent that Koine does not need. The price is a
private call that a macOS release can change or remove. Then the bounds match
still orders some windows, and Koine reports the rest as unknown.

Koine also posts events, as Modaliser does. Display focus and the pointer nudge
post mouse-moved events, and the media keys post system-defined events. Koine
posts them at the HID event tap with public calls. A posted event names no
element and no process. macOS routes it as it routes the input of a mouse or a
keyboard. A mouse-moved event goes to the application under the pointer, and a
media key goes to the Now Playing app.

So Koine cannot tell which process received a posted event, and a receipt
says only that Koine posted it. The layout of a media key event is a convention
that Modaliser and other tools rely on, not a documented contract. A macOS
release can change it, as it can change the private window lookup.

macOS keeps a separate access for posted events, the `PostEvent` service of
its privacy policy, and a managed Mac can deny it while it allows
Accessibility. Without that access, macOS can drop a posted event and report
no error. So before the nudge or a media key posts, Koine checks its
Accessibility consent and its posting access. Neither check asks for consent.
When either fails, Koine reports its one OS permission, `accessibility`, and
posts nothing.

Koine asks for no consent beyond Accessibility. A new consent for posting
stays Antony's decision. Display focus keeps the Accessibility check of
desktop 1.0.1. Its pointer move is a warp, and its one posted event follows
that move.

The private MediaRemote framework could name the Now Playing app, and so let a
receipt name the player. Koine does not use it, because Modaliser does not, and
no requirement asks for the name.

Koine sends an app chord in another way, by per-process posting. It posts each
event with `CGEventPostToPid` into the event stream of the input target, after
the event taps of the session. The macOS SDK header documents this call as the
way to route an event to a chosen app. So no other app can receive the chord,
no system shortcut catches it, and the keyboard tap of another process does not
see it. The [route probe](../verification/keystroke-route-vm.md) established
these properties for five apps in a VM.

Modaliser posts its chords at the HID event tap. There a chord goes to the app
that is in front when macOS reads it. That app can differ from the one that
Modaliser checked. Koine sends a chord to the target whether or not it is the
front app, and it never brings the target to the front. An app in the
background can ignore a chord, act on a window behind other apps, or come to
the front. Antony chose this reach, because Koine is to stand in for the
computer use of an LLM harness.

Every app except Koine is a target under the capabilities, system consent and
security prompts included. Koine refuses itself, because a chord to its
Settings window could approve a grant. The
[workflow providers spec](../specs/workflow-providers.md) holds this rule for
input and menus.

Antony rejected the alternative. It keeps the post at the HID event tap, and
a Koine keyboard tap drops a chord that reaches the wrong app. That tap would
see every keystroke in the session. Per-process posting has no fallback to the
HID event tap.

`CGEventPostToPid` needs posting access, as the post at the HID event tap
does. Without it, the probe's chord reached nothing, and macOS asked
the user for consent. So Koine checks its consent and its posting access before
it sends a chord, as it does before a media key.

A Space switch posts Control and a digit at the HID event tap, because macOS
must catch the chord there. Before it posts, Koine reads the shortcut "Switch
to Desktop N" from the preferences domain `com.apple.symbolichotkeys` with the
public CFPreferences calls. Apple does not document the domain or its entries,
and a macOS release can change them. Most changes make Koine refuse or fail.
But an entry that still reads as on after macOS stops using it could let the
chord reach the front app.

No public interface counts the Mission Control desktops. Antony chose the
private SkyLight call `SLSCopyManagedDisplaySpaces`, which Modaliser does not
use. The public preferences domain `com.apple.spaces` also gives a count, but
Apple does not document its form. On Antony's Mac it kept 19 display entries
where SkyLight reported one, and its current Space lagged in the probe.

Koine looks up the SkyLight call when it first needs it, as it looks up the
private window lookup. If a macOS release removes or changes the call, a
Space switch fails and posts nothing, and chords still work. Koine counts the
desktops of every display in the order that SkyLight reports, and skips
full-screen Spaces. The probe had one display, so if macOS numbers desktops
another way, the front app can receive Control and the digit.

Koine accepts wrong-process or wrong-window data and effects during process or
window reuse. It also accepts stale or misattributed notifications, and
mistaken withdrawal of live references or remembered windows. Koine does not
independently authenticate each AX reply or notification. It does not prove
the lifetime of a window or the age of an event, and it does not guarantee
that a read is fresh. The
[held-AX counterexample](../verification/retained-ax-binding.md) explains why a
check of a task identity cannot establish those properties for public AX. It
does not measure how often a normal race between check and use happens.

Framework-managed AX reception has no hard memory or Mach-right bound that
Koine enforces before acquisition. Oversized or malformed target traffic may
cause resource pressure or Koine failure, including traffic from the intended
target. Koine must still bound its own records, accepted values, queued work
and the native resources it directly owns. The
[receive experiment](../verification/native-observation-receive.md#pre-copyout-admission-assessment)
explains why later parsing limits are not acquisition bounds.

Koine keeps live-grant admission, its own Accessibility consent, refusal of
processes that no longer match their identity, and permanent reference
withdrawal without reuse. A platform closure report may withdraw a reference
without proof of physical closure. A later report cannot revive that
reference. A failed call may have acted. Koine never replays a mutation
automatically. The [spec](../specs/machine.md#native-targeting-discussion)
lists the accepted limits.

Koine does not own the private AX endpoint and wire protocol. No inspected
mechanism bounds what that channel acquires before parsing. Rebuilding AX
objects from private tokens crosses process incarnations, just as held public
elements do. The
[held-AX counterexample](../verification/retained-ax-binding.md#private-ax-reconstruction-does-not-bind-a-process-either)
demonstrates it. The private window-number lookup is a call on a held element, not a
channel that Koine owns, and Koine rebuilds no element from its number. Koine
uses no helper, injection, target cooperation or behavioural restriction of
applications.
