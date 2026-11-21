# Checked System Events and enrolment outputs

k151 supplies source-only checked reads for the System Events outputs of the
Settings scenario, and one checked submission for its enrolment. Each read
sends one fixed guest command, and an exact grammar parses its stdout. The
shared writer domain of the [shared adapter](ORDERING-NONEXEC-RESULTS.md) keeps
every attempt: one lock, one latch and one ordinal sequence.

These reads extend the read table of the
[checked exec reads](ORDERING-EXEC-READ-RESULTS.md). The reviewed
[ordering protocol](ORDERING-EVALUATION-PLAN.md) and the earlier contracts stay
binding. No ordinary caller or scenario root changes. No VM, signed candidate,
frozen subject, native availability or product acceptance follows. An
independent review and every earned integration come before k152 or k76
consumes this work.

## Interface

Source [the System Events facade](../../../scripts/vm-sysevents-evidence-lib.sh).
Sourcing only defines functions, and it also sources the exec read facade. Each
call needs a root that `init_guest_evidence` initialised. Each function keeps
one existing assertion or poll.

| Function | Legacy caller | Result |
|---|---|---|
| `expect_guest_system_events ROOT OP` | the check after the Automation grant | 0 for a nonempty process list, 1 for an empty list |
| `expect_guest_menu_count ROOT OP` | `[ "$(menu_item_count)" = 1 ]` | 0 for the integer 1, 1 for another count |
| `expect_guest_background_only ROOT OP` | `[ "${BACKGROUND}" = true ]` | 0 for true, 1 for false |
| `expect_guest_no_dock_item ROOT OP` | `! grep -q Koine <<<"${DOCK}"` | 0 when no Dock item name contains "Koine" |
| `expect_guest_menu ROOT OP TITLE...` | `expect_menu` | 0 when the menu titles equal the list of arguments |
| `await_guest_menu_label ROOT OP LABEL` | `await_menu_item_label` | 15 reads, each negative followed by `sleep 2` |
| `await_guest_menu_frame ROOT OP` | the frame poll of `open_menu` | 5 reads, each negative followed by `sleep 2` |
| `await_guest_menu_frame ROOT OP TITLE` | the row poll of `choose_menu_item` | 5 reads, each negative followed by `sleep 1` |
| `submit_guest_enrolment ROOT OP SECRET LABEL` | `enrol` | 0 for status 200 and no GraphQL error, 1 for a clean refusal |
| `check_guest_read ROOT CLASS OP PREDICATE NAME [ARG...]` | none | One checked read and one recorded state decision |

Status 1 is a clean false state, and it latches nothing. The caller keeps the
legacy failure. Every other nonzero status means that the read or the decision
is unavailable, and the backend latches the root. A poll exhaustion is a recorded state
failure. Each clean true state prints the record as one JSON line.

The value reads without an assertion use `read_guest_exec` directly. They are
`menu-item-label value`, for the echo of the item label, and
`front-application`.

## The System Events reads

Each read runs this command, where SCRIPT is the legacy AppleScript of its
caller, unchanged:

```bash
o=$(osascript -s so -e 'tell application "System Events" to SCRIPT'); s=$?; printf '%s\nKOINE-OSASCRIPT-STATUS %s' "$o" "$s"
```

| Read | SCRIPT | Clean value | Absence |
|---|---|---|---|
| `sysevents-processes` | `get name of every process` | a list of strings | unavailable |
| `menu-item-count` | `get count of menu bar items of menu bar 2 of process "Koine"` | an integer from 0 | unavailable |
| `menu-item-label value` | `get description of KOINE_ITEM` | a string or missing value | unavailable |
| `menu-item-label poll` | the same | the same | a negative |
| `menu-item-frame` | `get {position, size} of KOINE_ITEM` | two parts, each two integers or missing value | a negative |
| `menu-row-frame TITLE` | `get {position, size} of menu item "TITLE" of menu 1 of KOINE_ITEM` | the same | a negative |
| `menu-titles` | `get title of every menu item of menu 1 of KOINE_ITEM` | a list of strings | unavailable |
| `dock-items` | `get name of every UI element of list 1 of process "Dock"` | a list of strings | unavailable |
| `background-only` | `get background only of process "Koine"` | a boolean | unavailable |
| `front-application` | `get name of first process whose frontmost is true` | a string | unavailable |

KOINE_ITEM is `menu bar item 1 of menu bar 2 of process "Koine"`. A list item
may also be missing value. The caller predicate decides what such an item
means. A row title has letters, digits, spaces and U+2026 only. Thus no title
can leave the AppleScript string or the shell quotes.

### The source form

The host page `osascript(1)` says that the default output form "can introduce
ambiguities". It gives the example that `{"foo", "bar"}` and
`{{"foo", {"bar"}}}` both print `foo, bar`. The `s` modifier prints
"recompilable source form". The `o` modifier prints script errors to stdout,
and other diagnostic output stays on stderr. The source receipt records the
digest of the page.

A host control showed the defect in the legacy form. `{"a, b"}` and
`{"a", "b"}` both print `a, b`, and `{}` and `{""}` both print an empty line.
The legacy menu comparison and the legacy grant check compared these rendered
strings. The source form removes the defect at the source. Each list output now
compares as a parsed list, never as a rendered string.

The parser admits strings, integers, `true`, `false`, `missing value` and lists.
A string escapes only the quote and the backslash. A line break inside a string
stays literal, and the host control showed this. A real, a record and any other
class are unavailable. The list separator is exactly a comma and a space.

### Statuses and error numbers

A host control showed `osascript` exiting 0 with a value and 1 with a script
error. The page documents no exit status, so every other status is unavailable.
Status 1 needs exactly one line of the form `L:C: execution error: TEXT (N)`. A
syntax error has another form, and it is unavailable.

| Error number | Source | Class |
|---|---|---|
| -1728 | Language Guide: "The referenced object doesn't exist" | absence |
| -1719 | Language Guide: "The specified index is invalid or out of range" | absence |
| -1743 | `AppleEvents.h`: `errAEEventNotPermitted` | unavailable |
| -1712 | Language Guide: "The Apple event has timed out" | unavailable |
| -600 | Language Guide: "Application isn't running" | unavailable |
| any other | none | unavailable |

The [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html)
lists the numbers. The SDK of this host has no numeric list for -1728 or -1719.
`AppleEvents.h` in the SDK defines -1743. The source receipt keeps the digest of
the guide page and of the header.

An absence is a clean negative only in the three existing polls. They are the
label poll, the item frame poll of `open_menu` and the row frame poll of
`choose_menu_item`. The legacy loops polled through an empty answer, which the
legacy comment calls "no such element". Each other read treats an absence as
unavailable. Thus an absent menu bar never becomes a Koine failure outside a
poll. Missing required evidence does not establish product failure.

### The frame predicate

The legacy polls ended when the first character of the rendered frame was a
digit. The first item of the rendered frame is the x of the position. Thus the
legacy predicate held exactly when the position was a pair of integers whose x
was not negative. The facade keeps this predicate. A frame with a missing size still passes, as it did. The
record keeps the default rendering in `text`, and `click_centre` still checks
that text.

### The evidence class

No System Events read is in the evidence class. An Apple event can start System
Events, and the first one of a clone raises the Automation consent prompt. Thus
collection after a latch cannot use these reads. The background Automation
request stays with k152.

## Legacy defects

The legacy `guest` merges the stderr of the guest into its output, and legacy
`sysevents` keeps that output as its value. The fixture follows the tagged text
mode of the CLI, so the baseline replays this behaviour. Three legacy assertions
then read an error line as a value:

- The frame polls stopped on an error line, because its first character is a
  digit, as in `12:80:`. Then `click_centre` refused it, and the poll did not wait.
- The grant check passed on a refusal, because the -1743 error line is not
  empty.
- The Dock check read the error line as item names. That line quotes
  `process "Koine"`, so the legacy check reported a Dock icon that no read
  observed.

The checked reads never take an error line as a value.

## The enrolment submission

The client sends a grant request, so the enrolment is a submission, not a read.
The read table marks it, and only the one-shot class admits it. The backend now
admits the one-shot class for such an entry and refuses it for every read.

The guest command is the legacy one:

```bash
python3 $HOME/vm-verify-enrollment-client.py "$HOME/koine-secret-first" enrol "vm-editor" desktop:read
```

The secret argument must be `$HOME/koine-secret-` and lower-case letters. The
label must be a lower-case name. The capability stays `desktop:read`.

The stdout must be exactly one JSON line. Its keys must be `case`, `status` and
`response`, with no duplicate. The case must be `enrol`, the status an integer
from 100 to 599 and the response an object or null. Then the legacy predicate
decides: status 200 and no GraphQL error.

The legacy `guest_json` took the last line that parsed as JSON. It also accepted
JSON after a nonzero exit or a timeout. The checked submission refuses a second
line, a nonzero exit, a timeout and a transport failure. Each failure latches
the root, and a later submission refuses without dispatch. Thus no later text
can make a failed submission clean.

## Callers and their adoption

k76 replaces each caller and keeps its failure message. The
[k81 caller inventory](ordering-exec-read-evidence/callers.txt) lists each line.

| Caller | Adoption |
|---|---|
| `grant_system_events_automation`, the process check | `expect_guest_system_events` |
| `grant_system_events_automation`, the background request | k152 |
| `[ "$(menu_item_count)" = 1 ]`, four calls | `expect_guest_menu_count` |
| `echo "Item: $(menu_item_label)"`, three calls | `read_guest_exec ROOT read-poll OP menu-item-label value` |
| `await_menu_item_label` | `await_guest_menu_label` |
| `open_menu`, the frame poll | `await_guest_menu_frame ROOT OP`, then `click_centre` on `.text` |
| `read_menu` and `expect_menu` | `expect_guest_menu` |
| `choose_menu_item`, the row poll | `await_guest_menu_frame ROOT OP TITLE`, then `click_centre` on `.text` |
| `BACKGROUND`, two reads | `expect_guest_background_only` |
| `DOCK` | `expect_guest_no_dock_item`. The record keeps the names for the echo |
| The front application, two reads | `read_guest_exec ROOT read-poll OP front-application` |
| `enrol` | `submit_guest_enrolment` |

The scenario compares these five menus. Each is a list now:

| Legacy string | List |
|---|---|
| `Accessibility Not Granted…, , Settings…, Quit Koine` | `"Accessibility Not Granted…" "" "Settings…" "Quit Koine"` |
| `Review 1 Grant Request…, Accessibility Not Granted…, , Settings…, Quit Koine` | `"Review 1 Grant Request…" "Accessibility Not Granted…" "" "Settings…" "Quit Koine"` |
| `Review 2 Grant Requests…, Accessibility Not Granted…, , Settings…, Quit Koine` | `"Review 2 Grant Requests…" "Accessibility Not Granted…" "" "Settings…" "Quit Koine"` |
| `Settings…, Quit Koine` | `"Settings…" "Quit Koine"` |

The first list occurs twice in the scenario. The label poll failure message
named the last label. The state receipt of each poll step keeps each read
record, so k76 can name it.

A front-application read in a failure message runs before the failure latches.
If k76 latches first, the read refuses, because it is not in the evidence class.

## Controls and provenance

The [baseline run](ordering-sysevents-evidence/baseline-red.txt) runs the 20
new controls against legacy semantics, with the
[baseline script](ordering-sysevents-evidence/baseline.sh). The scratch tree
takes `scripts/` from the parent revision. Test-only wrappers replay legacy
`sysevents`, its callers, `guest_json` and `enrol`. The fixture renders each
source-form answer with the real host `osascript` and no Apple event. All 20
controls fail, and each failure has a legacy cause.

The first baseline run failed on a fixture artefact. The fixture added a
synthetic stderr line to a successful legacy `osascript`. A real `osascript`
writes no stderr then, so the fixture now writes none. Five tests now lead with
their strongest legacy defect.

The [mutation receipt](ordering-sysevents-evidence/mutations.jsonl) disables
one guard at a time in an isolated copy, with the
[mutation instrument](ordering-sysevents-evidence/mutate.py). Each of the 16
mutations fails each control that it names. In the first run, one mutation did
not apply, because the instrument searched for the escape text of U+2026. Now
the instrument searches for the character, and it ran the whole set again.

The [host suite](../../../Tests/scripts/vm-sysevents-host.bats) runs each
command through `/bin/bash -c`, as the agent does. A test-only `osascript` shim
checks the exact System Events invocation. Then the real `osascript` evaluates
a literal with the same flags. Thus the real tool prints each value, error and
status, and no Apple event reaches System Events. The enrolment runs the real
client against a local stub server under a temporary HOME.

The host is macOS 27.2.1 (26B131). It is not the guest, so the host suite
proves no guest output and no System Events behaviour.

The [green run](ordering-sysevents-evidence/final-verification.txt) runs 15
Taskfile checks with the k81
[measurement instrument](ordering-exec-read-evidence/measure.py). They are the
two new checks and the 13 checks that share the backend or the fixture. They
pass 242 tests with no failure, and each of the 4437 subjects stayed the same
during the run. The [source receipt](ordering-sysevents-evidence/official-source.json) records the
manual page, the guide page and the header.

Run `mise exec -- task check:vm-sysevents-evidence`. The host evidence runs
with `mise exec -- task check:vm-sysevents-host`.

## Limits

The grammars follow the host `osascript` and the client source. A guest that
prints another form holds the harness visibly as unavailable. A position or
size that System Events gives as a real is unavailable. The classification of
-1728 and -1719 rests on an archived guide page. The host SDK does not define
them.

An absence outside a poll is unavailable. Thus an absent menu bar, an absent
Koine process or an absent Dock list never becomes a Koine failure there. It
also never supports a pass. Diagnostic output on stderr does not enter a
grammar.

A read that is unavailable stops the slot, and it says nothing about the
product. Guest output can contain secrets, so the whole evidence root stays
private. Do not publish or commit it.

## Remaining duties

k152 owns each one-shot submission other than the enrolment, the background
Automation request and the restart poll question. k76 owns complete adoption,
signals and both held-pointer controls. k67, k62, k57 and k54 keep their
original duties.

The availability limits stay binding: the missing snapshot tree, the empty
AXValue and the OCR substring stop. The private secret-bearing roots stay
private. Every original criterion of k75, k71 and k66 survives. No VM,
candidate, freeze, acceptance or ancestor closure follows.
