# Checked System Events and enrolment review

Review `settings-system-events-evidence-k155` inspected producer
`2d25459b6e8034e2929733ec562cfab181473d6c` against parent
`9fe514934157b3ebb56cb22de5f165efa2a783da`. One finding needs integration
triage before k152 or k76 consumes these helpers. It concerns a denied read
that the parser accepts as a clean absence. It establishes no occurrence on
the pinned guest and no Koine failure.

This review changes no production or test code and runs no test, build, lint,
format or guest command. It inspects the committed change, the source, the
archived k75/k71/k66 contracts, the current protocol and retained receipts.
No VM, candidate, freeze, native qualification or acceptance follows.

## P2-1: A denied Accessibility read can become a clean negative poll

`scripts/vm_exec_reads.py:713-724` classifies an execution error by its number
and the read's poll mode. Any message ending in -1719 or -1728 becomes
`absent: true` in the label, item-frame and row-frame polls. The parser retains
the message but does not use it to establish that the error concerns a missing
element. This admits a denied Accessibility read as a clean negative.

The [AppleScript error table](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html)
gives generic Apple Event error meanings. It does not establish that System
Events uses -1719 exclusively for a missing index. The page separately directs
readers to an application's documentation for errors that the application
returns.

There is concrete contrary primary evidence. Ross Matsuda's 2023 MacAdmins
presentation, [Scripting the Unscriptable](https://bpb-us-e1.wpmucdn.com/sites.psu.edu/dist/4/24696/files/2023/07/psumac2023-DYQWYU-Scripting-the-unscriptable-GUI-Scripts-in-macOS.pdf#page=51),
shows a System Events read of the contents of the front System Settings
window. On slide 29, PDF page 51, its original Script Editor screenshot shows
a denial of assistive access with error number -1719. This is a read, not a
click or another input command. The presentation identifies its environment
as approximately macOS 13.4.1. It disproves the unconditional meaning assigned
to that number; it does not qualify the pinned macOS 27.0.1 guest.

The source-derived counterexample is an otherwise clean exec envelope whose
stdout is:

```text
12:80: execution error: System Events got an error: testanyware-agent is not allowed assistive access. (-1719)
KOINE-OSASCRIPT-STATUS 1
```

For `menu-item-label poll`, the full error expression matches, -1719 is in
`ABSENT_ERRORS`, and the mode admits absence. The backend therefore publishes
a clean `read.json` with `absent: true`. The predicate in
`await_guest_menu_label` is false. `check_guest_read` records status 1 as a
clean state decision without a latch, and `_sysevents_poll` sleeps and makes
another read. The two frame polls take the same path. A later value can finish
the poll successfully; persistent denial instead becomes the ordinary
state-failed exhaustion. Neither path preserves the first denial as unavailable.
This deduction follows from the source; the counterexample was not executed.

The k151 charter permits only a clean missing-element answer as a negative.
The protocol's Required transport and evidence handling section and the spec's
Finite evaluation and ordinary acceptance section stop on a failed required
read. Permission denial establishes no absence and must not consume another
ordinary state-poll step. This is a material classification defect even though
the new commands preserve their outer exec status: their shell wrapper encodes
the inner failure in stdout, so the inner classifier must keep that distinction.

The controls do not test this collision. The synthetic suite's `se_error`
always puts missing-menu wording around the number. The host error control at
`Tests/scripts/vm-sysevents-host.bats:86-98` explicitly raises -1719 with a
missing-menu message and raises the Automation refusal as -1743. It replaces
the real System Events target with a literal script. It proves formatting and
parsing, but cannot prove what numbers System Events assigns to denied
Accessibility reads. S03 tests errors outside the accepted number set; it does
not challenge a non-absence message inside that set.

Integration needs to settle a defensible absence boundary and controls that
distinguish denial from absence before consumption. This finding authorizes no
new guest, read, retry, wait or relaxed transport rule. It does not prescribe a
replacement implementation.

The report's claim that the host SDK has no numeric definitions also needs
correction in that source assessment. The same SDK's
`CarbonCore.framework/Versions/A/Headers/MacErrors.h:694` defines
`errAEIllegalIndex = -1719`, and line 701 defines
`errAENoSuchObject = -1728`. These generic definitions do not override the
contrary System Events example. The -1743 definition in `AppleEvents.h` remains
valid. No separate finding is raised for this documentation error.

## Inspection of the remaining contract

The host `osascript(1)` page supports the `s` modifier for recompilable source
and the `o` modifier for script errors on stdout. Source form removes the
legacy ambiguity between a list item containing a separator and separate list
items. The parser consumes the whole value and checks its type. Strings,
integers, booleans, missing values and the admitted list shapes have explicit
grammars. Another result class or formatting variant fails closed. The host
literal controls are evidence for that host's formatting, not for guest output
or System Events behavior. Integer-only frames and other guest-format
availability limits remain explicit.

The error parser requires one execution-error line and inner status 1. Syntax
errors, other statuses, absent markers, extra output and unaccepted error
numbers are unavailable. -1712 remains a timeout, -600 remains unavailable,
and -1743 remains an Automation refusal. An absence is unavailable outside the
three declared polls. P2-1 concerns the meaning of an accepted number, not the
location of that poll exception.

Within the admitted integer-frame grammar, the frame predicate preserves the
legacy leading-digit decision: position x must be nonnegative. A missing size
can pass that predicate, as before, and `click_centre` still owns the complete
geometry check. The label poll keeps fifteen reads with two seconds after
each negative. The item-frame poll keeps five reads with two-second sleeps;
the row-frame poll keeps five with one-second sleeps. Exhaustion records a
state failure. A failed read or recorded local error stops the helper. These
are source comparisons, not fresh test results.

The caller table accounts for four menu-count assertions, three label echoes,
the label and frame polls, the menu-title comparisons, two background-only
reads, the Dock list, two front-application reads, the post-grant process read
and the enrolment. The five menu assertions use four distinct title lists;
the first list occurs twice. The report preserves the empty separator element
and exact order. Row titles cannot escape the AppleScript string or the shell
quotes through the admitted argument grammar.

The enrolment command preserves the client, secret path, label and fixed
capability. The client prints one JSON object with case, status and response.
The parser rejects duplicate fields, another case, an incomplete object,
extra lines, invalid status types and invalid response types. The facade keeps
the legacy status-200/no-GraphQL-errors predicate. A grammatical refusal returns
1 for the caller's existing failure handling. The table marks the entry as a
submission and admits only the one-shot class. Ordinary reads do not gain a
one-shot route. The shared envelope validator still rejects a nonzero CLI or
guest status, timeout, foreign command or incomplete envelope before parsing.

No System Events read enters the evidence class. Sending an Apple event can
launch System Events or cause an Automation prompt, so this conservative
classification preserves the post-latch collection restriction. The background
Automation request remains k152's submission. A front-application read used in
a failure message must occur before latching, as the producer discloses.

The shared backend owns the lock during command selection, dispatch, envelope
validation, grammar parsing, `read.json` publication, output flush and terminal
receipt publication. The read and the following state decision are separate
backend calls and separate ordinals. The shell predicate runs outside the
lock; `record_guest_poll` then acquires the same lock to record its status.
This is not one continuous critical section across the facade function. The
current protocol has one foreground writer and the keepalive writer is
withdrawn. No additional actionable dispatch defect is derived from this gap
in this review. Existing first-failure, contention and inherited-lock controls
still apply; no new continuous-lock coverage is credited.

## Controls, provenance and limits

Fresh read-only digest comparisons matched the final output and subject
manifest to their recorded digests. All twelve compared current implementation,
facade, fixture, suites, Taskfile and evidence-instrument inputs match that
manifest. The manifest contains 4437 subjects, including three symbolic links.
The retained output contains fifteen Taskfile groups and 242 passing test
records, with no failing test record. These are the producer's retained
results, not suites rerun or newly certified by this review.

All sixteen mutation records report their named controls failing. A fresh
read-only reconstruction of each replacement matches its recorded mutated
digest, with exactly one replacement target in each current source file. Their
scopes cover output form, poll-only absence, accepted error numbers, statuses,
types, escaping, transport classes, arguments, complete enrolment output,
the GraphQL predicate, frame sign, failed-poll stopping and list comparison.
None tests the same-number denial in P2-1. A green mutation set does not
establish that its selected number-to-meaning mapping is complete.

The baseline retains twenty failures. Some stop at the absence of the new
records and cannot establish the later assertions in that test. Its legacy
row-frame wrapper at `Tests/scripts/vm-sysevents-evidence.bats:114-116` also
has an unconditional break after the digit check, where the actual legacy
helper has `&& break`. The retained row test uses an error line beginning with
a digit, so that observed one-read failure still agrees with the real legacy
branch. The wrapper does not independently establish the legacy negative-frame
poll bound. The direct source comparison above supplies that comparison.

The shared fixture change applies only to legacy `osascript -e` commands with
the new test status marker. It renders successful literals with the real host
tool and puts scripted errors on stderr, matching the legacy text path. Its
other response branches remain unchanged. Removing its synthetic stderr on a
successful literal corrects the disclosed baseline artifact; it is not native
System Events evidence.

The fetched Apple error page matches the producer's recorded digest. The local
manual page, `AppleEvents.h` and enrolment client also match the source receipt.
The additional primary presentation has SHA-256
`0e64f5b9cf8b21c245456cf7d7e876289e71d76cb92957f73cdf77abb157b710`.
The inspected `MacErrors.h` has SHA-256
`0a85b7c817c459796804df88c941b60be963133812ca051860edc7b43ce9489d`.
The presentation screenshot was inspected directly after PDF rendering.

Graph evidence used Tier 2, project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, coverage
generation `2026-11-21T14:32:25Z`. Bounded symbol searches and the backend's
one-hop caller/callee trace have no pending page. The trace includes unrelated
cross-language edges, which are not credited as calls. Coverage reports partial
shell ranges in the new facade, exec facade and legacy helpers/scenario, and
untracked metadata for the Bats suites. Direct reads cover those files and the
reported ranges. The graph supplies no exhaustive caller or correctness claim.

The k81 review and k154 integration remain consumed as source evidence. Their
defaults-domain and selected-process repairs are present. The exact executable
join and restart feasibility remain k152's duties. k76 still owns complete
adoption, status propagation, signals and both held-pointer controls. k67 owns
positive setup, title and liveness; k62 owns the prefix and duty comparison;
k57 owns the finite caller, audits and containment; k54 owns freeze and runtime.
The inherited file/lifecycle and other helper duties keep their existing
owners. The current slice does not claim to complete any of them.

Missing snapshot trees, omitted AXValue, the OCR substring stop, private
secret-bearing roots and the original/installed/stopped-golden audits remain
binding. No ancestor closes through this review. The immediate integration
reads and independently triages this finding from the review's commit before
k152 or k76 consumes the artifact.
