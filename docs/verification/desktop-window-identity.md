# Desktop window identity: which native mechanism upholds the contract

`docs/specs/machine.md`, "Resource references and desktop behavior", requires
that a window reference is re-resolved on every use and that Koine focuses
*exactly this target or reports `unavailable`*; it leaves "exactly which
public/native identity APIs support this guarantee" as an implementation
acceptance obligation. This document discharges it for
`application-identity-and-window-listing-k28`: the candidates, what each did
with real applications in a VM, the mechanism chosen, and what that mechanism
cannot do.

## Procedure

`Fixtures/WindowIdentityProbe` is test material and is never shipped. It is a
Developer ID signed command-line tool that *holds* accessibility elements across
the steps of a scenario, as the provider's window table does, and answers two
commands: `list <pid>` (the application's `AXWindows`, each element given a
token by `CFEqual` against the elements already held) and `held` (every element
ever listed, asked again now). For every element it also reports the
`CGWindowID` from the private `_AXUIElementGetWindow`. That call appears in the
probe alone, as an independent witness of *which window an element is*, so that
the public mechanism is checked against something other than itself.

```sh
Fixtures/WindowIdentityProbe/build.sh .build/probe   # build and sign, on the host
```

Run in a TestAnyware macOS 26.5 clone (`testanyware vm start --platform macos`):
the probe is uploaded and started with `testanyware file exec`, where it is
Accessibility-trusted because its responsible process, `testanyware-agent`,
holds that consent in the golden image. The windows were driven over VNC
(⌘N, ⌘W, ⌘M, ⌘⇧D, ⌃⌘F, ⌃←) and with `open -a` and `killall`. This scenario was
driven by hand, step by step, and is not a Taskfile task: its value is the
recorded answers, which are in [desktop-window-identity/](desktop-window-identity/)
as the probe wrote them. The shipped behaviour it informs is verified by
`task app:vm-verify-desktop`
([desktop-application-and-windows-vm.md](desktop-application-and-windows-vm.md)).

Applications: **Finder** (three windows all titled "Recents"), **Stickies** (two
notes both titled "Untitled"), **System Information** (its About window has the
empty title `""`) and **TextEdit**. **Terminal**'s three windows were listed and
asked again once, in run 1 (`run1-terminal`, `run1-held-after-new-windows`); it
took no further part.

## Candidates

| | Mechanism | Public API | Result |
|---|---|---|---|
| A | The `AXUIElement` itself, held by the provider, recognised again with `CFEqual` | Yes (`AXUIElementCopyAttributeValue`, `CFEqual`) | Selected the same window, and only it, in every case below. Does not survive a provider restart. |
| B | `CGWindowID` from `_AXUIElementGetWindow` | **No** | Agreed with A in every case. Would also survive a provider restart. Not adopted: private. |
| C | `CGWindowListCopyWindowInfo` window numbers, matched to accessibility windows by bounds or name | Yes | No identity. Window names are `null` without Screen Recording consent, the list holds many layer-0 entries that are no windows (four 1920×30 strips and a 500×500 one per application), and bounds are not unique: a closed note and its replacement had identical bounds. There is no public call from a window number to the element that must be raised. |
| D | The `AXIdentifier` attribute | Yes | No identity. It names the window's *kind*: `_NS:87` for every Stickies note, `FinderWindow` for every Finder window, absent for System Information. |
| — | Title | Yes | No identity: the duplicate titles above. |

## What A and B did, case by case

"Token" is the probe's number for a held element (mechanism A); "id" is the
private window id (mechanism B, the witness).

| Case | Observed | Files |
|---|---|---|
| Another window with the same title exists | Finder tokens 1, 2, 3 ↔ ids 60, 59, 58, all "Recents"; Stickies tokens 5, 6 ↔ 55, 53, both "Untitled". Distinct elements, never `CFEqual`. | `run2-0-*` |
| Relisted | Every window kept its token ↔ id across every later listing. | all |
| Retitled | Finder token 11 ↔ id 81 went from "Recents" to "Desktop"; same token, same id. | `run2-3-finder` |
| Minimised | Token 11 ↔ id 81, `minimized` true; still listed, its subrole now `AXDialog`. | `run2-4-*` |
| Moved to another Space | TextEdit "Untitled 2" (token 13 ↔ id 84) made full screen, which puts it on a Space of its own. On that Space `AXWindows` listed only it; back on the desktop Space `AXWindows` listed only "Untitled" (token 12 ↔ 45). The held token 13 stayed valid and still answered as id 84. | `run2-6-textedit`, `run2-7-*` |
| The window closes | The held element answers `kAXErrorInvalidUIElement` (-25202), permanently. | `run2-1-held`, `run2-9-held` |
| …and a look-alike replaces it | A new Stickies note with the same title, the same bounds `[69,793,300,200]` and the same `AXIdentifier` as the closed one is a new element (token 14 ↔ id 105); closed token 5 stays invalid. Finder likewise (token 11 ↔ 81 replaced closed token 1 ↔ 60 at the same bounds). | `run2-2-*`, `run2-9-*` |
| The application restarts | Every element of the old process answers `kAXErrorCannotComplete` (-25204). The restored windows, with the same titles and bounds, are new elements under the new PID, with new ids. | `run2-10-*` |
| Untitled window | System Information's About window: title `""`, token 9 ↔ id 74 throughout. | `run2-0-sysinfo`, `run2-10-held` |

A window reordered by raising it kept its token; Finder's `AXWindows` order did
not change when its rearmost window was clicked, so that case shows only that
relisting is stable, not that order changed.

PID reuse cannot be forced on demand. The observable case is the restart above:
a relaunched application has another `startedAt`, and its references carry it.

### An element that is not a window can be positional

Finder's `AXWindows` array also holds its desktop: role `AXScrollArea`, no
title, no window id, the whole screen. That element's identity follows its
*position*, not an object:

- Run 1: held while Finder had no windows, the same element later answered as
  role `AXWindow`, "Recents", id 59, after three windows were opened, while
  `CFEqual` said it was not the separately held element of window 59
  (`run1-finder-first-listing`, `run1-held-after-new-windows`, token 4).
- Run 2: held with three windows open, it answered `kAXErrorIllegalArgument`
  (-25201) when a window closed, a different element stood for the desktop, and
  it was the desktop again once a third window was opened (`run2-1-held`,
  `run2-2-held`, tokens 4 and 10).

No element that was a window when captured behaved this way. The listing takes
only elements whose role is `AXWindow`, which also keeps the desktop from
becoming a manufactured row. Role alone is not enough, though: such an alias
answers `AXWindow` for as long as a window holds its position, so one listed at
that instant would be tabled as a window and would mean "whichever window is in
this position" ever after. The listing therefore also asks each element's first
child for its `AXWindow` and requires that to be `CFEqual` the element: **the
element must be the one its own content names as its window**. Run 3 repeats
run 1 with that check reported as `isItsOwnWindow`: the held desktop element,
answering as `AXWindow` "Recents" id 36, is `false`; the element of window 36 and
every other real window of Finder, TextEdit, Stickies and System Information is
`true` (`run3-1-held`, `run3-2-*`). An element with no child to ask is not
listed: its identity cannot be established.

### Does an application reuse an ended element's identity?

`CFEqual` compares an element's process and an opaque token the application
issued; nothing public says a token is never issued twice. If one were, a held
element of a closed window could come to answer for a later one. In run 3 a
Stickies note was held (token 10, id 57) and closed; sixty notes were then opened
and closed and three more left open, one of them at the closed note's exact
bounds. Window ids had reached 244. Token 10 still answered
`kAXErrorInvalidUIElement`, and no held element changed its id (`run3-3-stickies`,
`run3-4-*`). That bounds the risk; it does not remove it, and it is stated below
as the assumption the guarantee rests on.

## Chosen mechanism

**A: the provider holds the window's accessibility element**, as the private
observation state the contract allows a provider, and the reference names it:

```text
koine://desktop/application/<pid>/<start µs>
koine://desktop/window/<pid>/<start µs>/<session>/<token>
```

`<pid>/<start µs>` is the process incarnation. `<session>` is sixteen hex digits
drawn when the provider starts; `<token>` numbers an element within that
session. A listing gives an element already held (by `CFEqual`) its existing
token, so a window's reference is stable for as long as the provider runs. No
title, bounds or order is part of the identity, so none of them is ever matched.

### What it cannot distinguish, and what is therefore `unavailable`

- **Any window reference from an earlier provider run.** An element cannot be
  held across a restart of Koine, and nothing public maps a window back to an
  element. The session does not match and the reference is `unavailable`, even
  though the window may still be open. The contract allows this ("Do not promise
  every window reference survives a provider/server restart"); only the private
  mechanism B would avoid it. The client lists again.
- **A closed window**, and **every window of a process that ended**: the element
  no longer answers, so `unavailable`. A look-alike is never substituted.
- **A reference whose process incarnation is not running**, PID reuse included:
  `unavailable` before the table is consulted.
- **Title fallback is never used.** The evidence gives no case in which a title
  establishes the same target unambiguously once the element is gone.
- **An element that is not its own window is not listed**, and so has no
  reference: a positional alias, and a window with no content to ask.
- **The assumption the guarantee rests on:** for the life of a process, the
  identity an application gives a window's element is bound to that one window
  and is not issued again. It held for every window here, AppKit and Finder,
  across 60 further windows in one process. Public API offers no way to prove it
  for every application. Two defences narrow it: every use of a held element
  checks again that it is still its own window, and
  `remembered-windows-across-spaces`, which observes destruction, can retire a
  token the moment its window ends instead of on the next listing.
- **A window that is one of several tabs inside one window** (Finder, Safari)
  has no reference of its own: the reference names the window, whose title
  follows its selected tab.
- **Windows on another Space are not listed yet.** `AXWindows` reports the
  current Space alone. Their held elements stay valid, which is what
  `remembered-windows-across-spaces` builds `REMEMBERED` rows from; until then a
  listing is of the current Space.
- **A busy application closes nothing.** A held element is dropped only when it
  answers that it no longer exists or is no longer a window, never on a timeout.
  A listing that an application stops answering part-way is reported `failed`,
  not returned short, and a failed read never becomes an empty title.

### For the leaves that re-resolve and focus

Compare the process incarnation against the kernel immediately before acting;
table membership proves nothing about the process. Look the token up only under
the provider's queue. Repeat the own-window check on the held element before
acting on it. Any further witness belongs in the table entry, which is private,
not in the reference.

## Evidence

Probe answers, unedited, in [desktop-window-identity/](desktop-window-identity/).
Runs of 2026-09-19, macOS 26.5 (Tahoe) arm64 VM, probe signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`. Run 1 was ended to bound
the probe's per-element waits; run 2 repeats it from the state run 1 left; run 3,
in a fresh clone, adds the own-window check and the reuse churn.

The mechanism was also put to one adversarial read in a fresh context, given the
source, the contract and these observations. What it found and this leaf acted
on: the own-window check, the check that a listed element belongs to the process
asked, a wait bound that had applied to the application element alone
(`AXUIElement.h`: a timeout set on an element holds for that object only), read
errors that had become empty titles, and pruning on a timeout. What it found and
is stated above instead: identity reuse, tabs, and windows on other Spaces.
