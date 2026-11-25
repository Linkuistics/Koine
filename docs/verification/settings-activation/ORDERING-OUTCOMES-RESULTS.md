# Settings scenario outcome results

This report belongs to `settings-scenario-outcomes-k67`. The complete ordinary
Settings scenario, `scripts/vm-verify-menu-bar.sh`, now applies the setup,
title and liveness rules of the
[ordering protocol](ORDERING-EVALUATION-PLAN.md#matched-observable-setup). It
checks a positive TextEdit setup before each of the four Settings selections.
Each return records its menu route. The title audit runs on each front list.
Each failed return gets one outcome class.

The integration `settings-scenario-outcomes-k162` changed the menu reads and the precedence of
an unavailable title audit. The section
[Integration of review k161](#integration-of-review-k161) records both
changes, and the tables below list the current reads.

The evidence is source and controls only. No VM ran, and no signed subject was
built or frozen. No runtime slot ran. The work establishes no native
behaviour, no native cause, no callback delivery and no scenario readiness. It
closes no ancestor.

## New checked reads

Six reads join the table in `scripts/vm_exec_reads.py`. Each parse refuses a
missing value, a wrong type or an incomplete enumeration. That evidence is
unavailable, and it latches the root. It is never a negative state. No new
read is in the evidence class.

| Read | Guest command | Clean record | Why it is not in the evidence class |
|---|---|---|---|
| `front-process` | System Events: `{name, unix id}` of the front process | A name and a positive PID | An Apple event can launch System Events |
| `textedit-windows` | System Events: the subrole of each TextEdit window and the roles of its sheets | One subrole and one list of sheet roles for each window | The same |
| `menu-bar-menus` | System Events: the TextEdit menu bar items, and the menus under each item and under the Koine item, by name (k162) | A non-empty name list, one name list for each item, and one name list. The record keeps the count for each item | The same |
| `menu-row-enabled TITLE` | System Events: `enabled` of the Koine menu row | A boolean | The same |
| `koine-menus` | System Events: the names of the menus under the Koine menu bar item (k162) | A name list. The record keeps its count | The same |
| `process-identity PID` | The kernel script of `launch-identity`, for one PID | The PID, and the process entry or `null` | python3 can raise the Command Line Tools prompt |

`process-identity` reuses the script of the launch identity read. A pipe gives
the script a JSON object with the PID in place of the descriptor. The parse
then checks the same process schema. `null` is the clean fact that no process
has the PID. A live process whose path read fails stays unavailable, with
script status 7.

## The deferred count poll

`await_guest_window_count` takes an optional fifth word, `deferred`. The
existing poll latches the root when it runs out, and that latch would refuse
the liveness read of a zero-window failure. A deferred poll prints its final
clean list and returns 1 without its exhaustion receipt. The caller then takes
only its untouched failure reads. It records `OPERATION-exhausted` under the
same name and predicate before any input. `window_count_predicate` gives that
predicate.

A deferred poll keeps the same ten reads, the same waits and the same stop on a
failed read. Without `deferred`, the poll is unchanged. Every clean poll read
now also prints its list when the state is false. Only a deferred exhaustion
passes that list to the caller.

## The positive setup

After the TextEdit preparation, the scenario records the TextEdit PID and the
frame of its one window. The frame comes from the list of the existing
`textedit-front` read, so the scenario adds no window read. One `process textedit` read
gives the PID. Two TextEdit windows or two TextEdit processes are failed setup.

Before each of the four Settings selections over TextEdit, these checks run.
They follow the existing close and count check and the pre-click identity read.
The checks add no wait, and they send no input.

| Fact | Observation | Failed setup | Unavailable setup |
|---|---|---|---|
| No visible Koine window | The zero-count list of the close check. The setup takes no new window read | A Koine window in the list | A TextEdit window without a title |
| One idle Untitled document | The same list: one TextEdit window, `standard`, titled `Untitled`, at the recorded frame | Another count, type, title or frame | The same |
| TextEdit is the front process | `front-process`: TextEdit with the recorded PID | Another name or PID | A failed read or a missing value |
| No dialog or sheet | `textedit-windows`: one `AXStandardWindow` and no sheet | Another subrole, another window or a sheet | A missing subrole or two lengths |
| No open menu | `menu-bar-menus`: no menu under any TextEdit item or under the Koine item | A menu under an item | A missing list, an empty item list or two lengths |

A precondition screenshot, `setup-SELECTION`, follows the checks. A clean
mismatch records `scenario-assertion-setup-failed`, and the scenario exits 1.
Unavailable evidence keeps the status of its facade. Neither outcome opens the
menu, so no repair, focus action or repeated selection follows.

## The route of each return

A return is a selection that must bring the window back. The scenario has
seven menu returns and one app reopen. The menu returns are the four Settings
selections over TextEdit, the requests line, the Accessibility line and the
Settings selection before Command-Q.

Each menu return runs these steps:

1. Read the identity of the Koine process once, with `confirm_guest_launch`. A
   clean mismatch is failed setup.
2. Open the menu and poll the row frame, as before.
3. Read the row's enabled state once. A disabled row records
   `scenario-assertion-menu-item-disabled`, and the scenario sends no click.
4. Take the open-menu screenshot, `menu-SELECTION`.
5. Click the row centre by the existing physical route. The route keeps the
   item frame, the display size, the derived points and each input receipt.
6. Keep the existing 2-second wait.

The outcome checks follow, in this order. The count poll is deferred. The front
predicate and the title audit both run on one front list. A menu return then
reads its menu once, and an open menu records `scenario-assertion-menu-open`.

The outcome screenshot follows, before the next close, focus, keyboard input or
launch. The first selection keeps `over-textedit` as its outcome screenshot.
The requests line keeps `requests`, because only reads and a wait come before
it.

The app reopen takes the identity of the silent launch, which its reopen
confirmation proves. It reads no menu. The two Quit selections keep their
existing route, because they are not returns.

## The title audit

The audit runs on the same full list as the existing front predicate. It needs
exactly one Koine window, titled `Koine Settings`. That entry must also be the
front and focused entry outside Notification Center. Both results keep their
receipts, `OPERATION-front-state` and `OPERATION-front-title-state`. A Koine
window without a title makes the audit unavailable. The resize focus check
also runs the audit, because it uses the same front assertion.

## Outcome classes

Each clean failure of a return records one state-failed receipt,
`scenario-assertion-CLASS`, and the scenario exits 1.

| Class | Condition |
|---|---|
| `zero-window-same-process` | The count poll ends with zero Koine windows. One liveness read finds the PID of the pre-click identity with the same start time and executable. The menu is closed <!-- tc: depart synonym-rotation because "start" names the kernel start time of a process, not the application launch --> |
| `process-lost` | Zero windows, and the liveness read finds no process for that PID, or another start time or executable <!-- tc: depart synonym-rotation because "start" names the kernel start time of a process, not the application launch --> |
| `multiple-windows` | The count poll ends with another nonzero count |
| `not-front` | The front predicate is false |
| `window-identity` | The front predicate holds and the title audit is false |
| `menu-open` | The menu is still open after the click. The outcome is unresolved |
| `menu-item-disabled` | The row is disabled before the click |
| `setup-failed` | A clean mismatch in the positive setup or the pre-click identity |

A zero-window outcome whose liveness read is unavailable keeps the status of
that read. Its message says that the outcome is unresolved. An unavailable
closed-menu read also keeps its status and says the same. No class claims a
native cause, a callback or a crash. A same-process zero-window outcome still
needs the screenshot audit of k54 before it can qualify a recurrence.

## Untouched failure observations

A failed return takes these observations before its first latch, in this order:

1. The liveness read, for a zero-window outcome only.
2. One front-application read, the independent observer of the legacy message.
3. One window list, in the evidence class.
4. One failure screenshot, in the evidence class.
5. The closed-menu read, for a menu return whose process is not lost.
6. The deferred exhaustion receipt, for a count failure.
7. The classified receipt.

A failed observer keeps its own receipt, and the message never uses its text.
After a latch, the backend refuses the observer and records that refusal. The
scenario takes no second screenshot when it stops.

## Caller table additions

| Caller | Strict call |
|---|---|
| TextEdit PID after the preparation | `check_guest_read process textedit`, one selected PID |
| Positive setup | The zero-count list, then `front-process`, `textedit-windows` and `menu-bar-menus`, then `capture setup-SELECTION` |
| Pre-click identity | `confirm_guest_launch SELECTION-identity` |
| Row state | `check_guest_read menu-row-enabled TITLE` |
| Open-menu screenshot | `capture menu-SELECTION` |
| Return count poll | `await_guest_window_count ... 1 deferred` |
| Title audit | One local decision on the front list |
| Closed menu | `check_guest_read koine-menus`, as `RETURN-menu-closed` |
| Liveness | `check_guest_read process-identity PID`, as `RETURN-liveness` |
| Failure observer and list | `read_guest_exec front-application`, then `read_guest_windows evidence` |
| Outcome screenshots | `capture outcome-RETURN` |

## Controls and provenance

`task check:vm-settings-scenario` runs the scenario controls against the
simulated backend. Each new flag of the backend changes one answer at a chosen
return. The facade suites check the grammar of each new read and the deferred
poll.

| Control | What it establishes |
|---|---|
| Setup order | Each of the four selections has the identity read, the setup reads and the screenshot directly before its menu opens. No window read comes between the count poll and the setup |
| Failed setup | A moved frame, another title, another PID, a sheet, a dialog or an open menu stops the scenario before the menu opens. The controls cover the first and later selections |
| Unavailable setup | A missing title or a failed setup read stops with status 125 before the menu opens |
| TextEdit processes | Two TextEdit processes after the preparation are failed setup |
| Route | Each return has its enabled read and its open-menu screenshot before the click, and its closed-menu read after the title audit. The Quit selections have neither |
| Disabled row | A disabled row stops before its screenshot and its click |
| Open menu | A menu that stays open is `menu-open` |
| Title | A wrong title is `window-identity` at the first selection, the requests line and the last Settings selection, while the front predicate holds |
| Missing title | A Koine window without a title is unavailable |
| Two windows | Two Koine windows are `multiple-windows`, after the observations and the closed menu |
| Same process | Zero windows with a live process are `zero-window-same-process`, at the first selection and the Accessibility line. The liveness read is clean, because nothing latched before it |
| Lost process | A process that ends, or a new process under the same PID, is `process-lost`, with no menu read |
| Failed liveness | A failed liveness read is unresolved, with status 125. The backend refuses the observer, and the scenario records no class |
| App reopen | A reopen without a window compares the PID of the silent launch and reads no menu |
| Not front | The existing control now records `not-front` after both predicates and the observations, with one failure screenshot |
| Read grammars | Each new read sends its exact AppleScript, parses its complete values and refuses a missing value or two lengths |
| PID identity | The read pipes the PID to the kernel script. A host run names a live `/bin/sleep` with its `ps` start second, and an exited PID as `null` <!-- tc: depart synonym-rotation because "start" names the kernel start time of a process, not the application launch --> |
| Deferred poll | A deferred exhaustion prints the final list and latches nothing until the caller's receipt. A positive, a failed read and an unknown word keep their behaviour |

The records are in [`ordering-outcomes-evidence/`](ordering-outcomes-evidence/):

- `record.sh` runs one command and writes the transcript, the manifest of its
  subjects before the run and a JSON summary. It is the k160 script, with one
  option. `SUBJECTS=find` digests each file of a tree that no VCS tracks.
- `red.txt` runs the five affected suites in a red tree. That tree is commit
  `c0e0cc02`, with only the new controls and the extended simulated backend
  copied in. Of 108 tests, 24 fail. These are 21 new controls and three
  tightened ones. The tightened ones are the fault list, the `not-front`
  control and the evidence-class list of System Events reads. The subjects
  stay unchanged during the run.
- One new control passed in that red run: the missing-title control. A later
  stop with status 125 satisfied it. The control now needs the audit's own
  receipt and message. `red-title.txt` records its failure in the same red
  tree.
- `final-verification.txt` runs each affected Taskfile check after the
  repairs. These are the eighteen checks of the k160 record. All of them pass,
  with 314 passing tests and no failure. None of the 4,507 subjects changed
  during the run.
- An earlier final run failed one assertion of the setup-order control. That
  assertion expected the wrong count of setup operations. The repaired
  assertion fails a synthetic mutation, and the final run above follows it.

The record files, the last entries of the task file and the retirement of the
leaf come after the final run.

## Primary sources and unverified oracles

The host's System Events dictionary, `SystemEvents.sdef`, defines `unix id` of
a process. It also defines `subrole`, `selected` and `enabled` of a UI element,
and the class `sheet`. The host runs macOS 27.2.1 build 26B131, and the file
has SHA-256 `4d2a6477…`. The guest runs macOS 27.0.1, so E01 qualifies each
read there.

Apple documents `kAXEnabledAttribute` as required on menu items, and false for
a disabled control. Apple documents `kAXStandardWindowSubrole` as a standard
window with a title bar, not an inspector or a sheet.
`NSAccessibility.Attribute.selected` says only whether an element is selected.
No Apple source states that a menu bar item reports its open menu through it.
The open-menu and closed-menu oracles are therefore unverified natively.

The k162 integration replaced both selection reads with the protocol's menu
enumeration. The two limits below about `selected` describe the reviewed
source, not the current source.

These limits follow:

- A menu bar item that does not report `selected` gives a missing value, which
  is unavailable.
- A menu bar item that reports false while its menu is open would pass the
  check. The supplemental screenshots are the only other evidence.
- E01 qualifies the availability of each new read, with no replacement if it
  fails.

The comments at each decision site in `scripts/vm_exec_reads.py` cite these
sources.

Issue #15 qualified a replacement on a real guest (k5). There, System Events named
the menu of each closed item, so the two name reads cannot serve. The scenario now
reads the size of each menu, `menu-bar-menu-sizes` and `koine-menu-sizes`. The
[menu-bar record](../menu-bar-vm.md#the-open-menu-signal) states the evidence. The
tables of this record describe the k162 source.

## Limits

- The simulated backend models only the answers that the scenario needs. The
  facade suites own the grammars.
- No guest ran. The availability limits of the earlier reports stay binding.
  These are the missing snapshot tree, the unverified empty AXValue after a cut
  and the OCR substring stop.
- The setup adds four System Events reads and one identity read before each of
  the four selections. Each return adds an identity read, an enabled read, two
  screenshots and a closed-menu read. The protocol requires these
  observations. No wait changes, and no claim of timing neutrality follows.
- The liveness read uses python3, like the launch identity read. A guest
  without the Command Line Tools would fail the earlier launch identity read
  first.
- A zero-window class establishes neither a crash nor a misdirected Quit. A
  same-process class establishes no native refusal and no lost activation.

## Owners after k67

- k62 extracts the focused prefix through the TextEdit quit from these bytes.
  It verifies the byte correspondence and reconciles every original duty.
- k57 reads the classified receipts and the deferred exhaustion receipts in
  the finite caller. It owns the containment, the stop and the collection.
- k54 owns the freeze, the screenshot audit of each outcome and the runtime.
  It classifies a qualified recurrence from these receipts and the
  screenshots.

The review `settings-scenario-outcomes-k161` read this artifact before k62
and the runtime. The integration `settings-scenario-outcomes-k162` applied its
two findings.

## Integration of review k161

The integration `settings-scenario-outcomes-k162` triaged the two findings of
[the review](ORDERING-OUTCOMES-REVIEW.md). Both findings are real issues, and
the source changed for each. The successful actions, read counts, waits and
bounds stay the same. Each setup and each closed-menu check still takes one
read.

### F1: the menu reads enumerate the menus under each item

The protocol's "No open menu" row names an enumeration of the menus under the
TextEdit and Koine items, with a count for each item. The reviewed source read
`selected` instead. The System Events dictionary defines the `menu` elements of
a menu bar item at lines 1099–1103. No Apple source equates the selection of an
item with an open menu.

Two reads replace the two selection reads:

- `menu-bar-menus` serves the positive setup. It returns the TextEdit items
  and the menus under each item and under the Koine item, by name. The setup
  needs every list of menus to be empty.
- `koine-menus` serves the closed-menu check after a selection. It reads only
  the Koine item, because TextEdit quits before the later returns.

Each parse refuses a missing list, a value of another type and two lengths
that differ. An empty list of TextEdit items is unavailable, because the menu
bar of a running application has at least the Apple menu. Each record keeps
the count of menus for each item. A missing name stays admissible, because the
Koine status menu can have no name.

**Accepted trade-off.** No Apple source states when a menu bar item exposes its
menu. The new oracle is the protocol's oracle, and it stays unverified natively.
If a closed application menu exposes its menu in the guest, each setup fails
cleanly at E01. That failure stops the evaluation. Before E01, the k36 brief's
hold for a demonstrably infeasible completion is the route for a new decision.

The simulated backend assumes the protocol's mapping, so its green controls
establish only that mapping.

### F2: an unavailable title audit keeps its status

In the reviewed source, a clean false front predicate took precedence over an
unavailable title audit. At the app reopen and at the resize focus, the
scenario then exited 1 as `not-front`. Now the audit's own status ends the
scenario. The app reopen still takes its untouched failure observations first.
The resize focus checks the audit's status before it classifies `not-front`. A
wrong title beside a false front stays `not-front`, as before.

### Controls

| Control | What it establishes | Red result |
|---|---|---|
| Menu enumeration | Each of the four setups reads `menu-bar-menus`, each of the seven closed-menu checks reads `koine-menus`, and no read asks for a selection | Failed. In the red tree, the setup reads `open-menus` |
| Failed setup | An open Koine menu before the third selection is failed setup. The existing open TextEdit menu now opens the File menu in the model | Failed. With a menu exposed and the item reporting false, the reviewed source ended PASSED |
| Open menu | The existing control now reads the exposed Koine menu | Failed. The reviewed source ended PASSED |
| Untitled behind | At the app reopen and at the resize focus, a focused Finder window and an untitled Koine window stop with status 125 and no class | Failed. Each case exited 1 as `not-front` |
| Read grammars | Each new read sends its exact AppleScript and refuses a missing list, two lengths, an empty item list and a script error. The two retired reads refuse before dispatch | Failed. The reviewed reads exist and the new ones do not |
| Counts | The records keep the count of menus for each item | Failed. The read does not exist |

The records are in
[`ordering-outcomes-integration-evidence/`](ordering-outcomes-integration-evidence/).
They use the producer's `record.sh`.

- `red.txt` runs the new and changed controls in this tree, before the source
  change. All eight selected tests fail. The scenario controls fail for a broad
  reason, because the new simulated guest does not answer the retired reads.
- `red-shim.txt` and `red-shim-resize.txt` run the scenario controls in a copy
  of that tree. `red-tree-shim.diff` is the only change to the copy. Its
  backend answers each retired selection read with false. These runs expose
  each defect by itself. The resize run puts its case first, because the loop stops
  at its first failure.
- After the red runs, the closed-menu read of the previous return also saw the
  Koine setup flag. The flag now acts on the setup read only. The red runs did
  not depend on that flag.
- `final-verification.txt` runs the eighteen affected Taskfile checks of the
  producer's record after the change. All of them pass, with 317 passing tests
  and no failure. None of the 4,512 subjects changed during the run.

The record files, the last entries of the task file and the retirement of the
leaf come after the final run.

### Handoff

k62 extracts the focused prefix from the changed bytes. The setup and the
closed-menu checks keep their positions and their operation names. Only their
reads change. k57 and k54 carry the native risk of the F1 oracle into the
pre-runtime reconciliation and the readiness. E01 qualifies both new reads,
with no replacement if either fails.
