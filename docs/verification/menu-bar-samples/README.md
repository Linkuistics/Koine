# Bounded menu-bar comparison — 2026-10-28

The four declared attempts produced one complete pass and three Settings
activation failures. Both released bundles reproduced the failure. This finite
sample establishes neither a release regression nor a reliability rate. The
activation cause remains unresolved; no application repair or release was made.

## Protocol and actual conditions

The [protocol](PLAN.md) and [freeze time](frozen-at.txt) precede the first attempt.
The order was 0.3.0, 0.4.0, 0.4.0, 0.3.0, one scenario invocation in each fresh
guest. The absolute cap was four started attempts. All four started and reached
scenario assertions; none was interrupted, replaced or retried. The cap ended
the sample. No measured script, input or bundle changed during collection.

The [release 0.3.0 metadata](release-0.3.0.json) and
[release 0.4.0 metadata](release-0.4.0.json) identify the official archives.
Their SHA-256 digests match the protocol. Both host signatures passed strict/deep
verification; [0.3.0](signature-0.3.0.txt) and [0.4.0](signature-0.4.0.txt)
retain their CDHashes and signing identities. The unchanged scenario is the
settled k10 script. No candidate build was substituted for either release.

Every guest cloned `testanyware-golden-macos-27`: macOS 27.0.1 build 26A434,
arm64, four CPUs, 4 GiB RAM. Each start log records 1920×1080 at 1×. Attempt 02's
restart restored [1024×768](02/final-display.json); the failed attempts never
restarted and ended at 1920×1080. TestAnyware CLI/app/bundle were 2.7.0 and Tart
was 2.41.1. [Doctor](doctor.json) retains the existing disabled host login item;
it did not prevent these runs. Gatekeeper assessments were enabled, and the
guest accepted both bundle signatures. Installation set no quarantine attribute,
so this is not Gatekeeper first-launch acceptance.

Run logs record each initial OS/build and Gatekeeper read. Final environment
reads return exit zero without timeout in 01–03. In 04, the final environment
exec emits the same complete text but reports timeout and exit -1; retain that
transport failure rather than claiming a successful final read.

## Every started attempt

Times are host UTC; timestamped scenario filenames use the host's Melbourne
local time. Scenario end precedes post-run observations/audit and clone stop.
Task maps a failed script to 201; the actual script exit is retained separately.

| Attempt / clone | Bundle | Start → scenario end (UTC) | Scenario / Task / audit exits | Result |
|---|---|---|---|---|
| [01](01/task.log), `koine-k4-01` | 0.3.0 | Oct 27 23:57:07 → Oct 28 00:01:31 | [1](01/scenario.exit) / [201](01/task.exit) / [0](01/audit.exit) | Settings reopen 1 fails |
| [02](02/task.log), `koine-k4-02` | 0.4.0 | Oct 28 00:02:32 → 00:20:55 | [0](02/scenario.exit) / [0](02/task.exit) / [0](02/audit.exit) | Complete pass |
| [03](03/task.log), `koine-k4-03` | 0.4.0 | Oct 28 00:22:12 → 00:26:06 | [1](03/scenario.exit) / [201](03/task.exit) / [0](03/audit.exit) | Settings reopen 1 fails |
| [04](04/task.log), `koine-k4-04` | 0.3.0 | Oct 28 00:26:20 → 00:29:26 | [1](04/scenario.exit) / [201](04/task.exit) / [0](04/audit.exit) | Settings reopen 3 fails |

Each directory retains the original scenario log/screenshots, wrapper task log,
start/end records, original exits, endpoint inventories, subject checks and
explicit stop result. There are no unrecorded setup attempts in this sample.

## Assertion coverage

PASS means that assertion completed. NOT RUN means the scenario stopped before
it, with no acceptance inferred from another attempt.

| Assertion group | 01 | 02 | 03 | 04 |
|---|---|---|---|---|
| First launch: default frame/title, agent status, no Dock icon, one item, label/menu | PASS | PASS | PASS | PASS |
| TextEdit in front before the requested reopen | PASS | PASS | PASS | PASS |
| Initial Settings action: window returns in front and focused | PASS | PASS | PASS | PASS |
| Settings reopen 1 | FAIL | PASS | FAIL | PASS |
| Settings reopen 2 | NOT RUN | PASS | NOT RUN | PASS |
| Settings reopen 3 | NOT RUN | PASS | NOT RUN | FAIL |
| User-input growth, minimum frame, actual minimum content height | NOT RUN | PASS | NOT RUN | NOT RUN |
| Minimum-size scroll reachability: login, grant label, Accessibility | NOT RUN | PASS | NOT RUN | NOT RUN |
| Shortcuts: typing, select/copy/cut/paste, Command-W and retained item | NOT RUN | PASS | NOT RUN | NOT RUN |
| Two client requests: label/menu updates and no automatic window | NOT RUN | PASS | NOT RUN | NOT RUN |
| Requests menu navigation, visible row and both denials | NOT RUN | PASS | NOT RUN | NOT RUN |
| Accessibility menu navigation and visible status | NOT RUN | PASS | NOT RUN | NOT RUN |
| System Settings consent and removal of warning label/menu line | NOT RUN | PASS | NOT RUN | NOT RUN |
| Login enable, menu Quit, stopped server and silent manual launch | NOT RUN | PASS | NOT RUN | NOT RUN |
| Reopening the running application shows/focuses its window | NOT RUN | PASS | NOT RUN | NOT RUN |
| Settings focus, Command-Q, stopped server and changed boot time | NOT RUN | PASS | NOT RUN | NOT RUN |
| Login launch: process, endpoint, one item, no window, agent status | NOT RUN | PASS | NOT RUN | NOT RUN |
| Final menu Quit, missing process/endpoint, old-port refusal | NOT RUN | PASS | NOT RUN | NOT RUN |
| Installed after inventory and equality with before/input | NOT RUN | PASS | NOT RUN | NOT RUN |

Attempt 02 grew to 703×903 and stopped at a 440×352 outer frame with
[320 measured content pixels](02/menu-bar-20261028T110232-least-size-content.json).
Its [minimum-size screenshot](02/menu-bar-20261028T110232-least-size-440x352.png),
[Requests screenshot](02/menu-bar-20261028T110232-requests.png),
[after-login screenshot](02/menu-bar-20261028T110232-after-login.png) and
[full transcript](02/menu-bar-20261028T110232.log) retain the complete exercise.
The old-port curl returned 7 after final Quit. No assertion was NOT RUN in 02.
This adds no new resize acceptance for 0.3.0: both of its attempts stopped earlier.

## Failure observations and the remaining diagnostic

In 01 and 03, the original failure assertion, a fresh native observer, independent
CoreGraphics window order, the agent window list and the screenshot agree:
TextEdit is active/in front; Koine is inactive behind it; the menu has dismissed.
The observer executable permission was explicitly set. Both execs returned zero,
without timeout or stderr. Collection preceded any keyboard, window-focus,
repeated menu action or application launch intervention.

| Failure | Native / CoreGraphics | Agent windows | Original / subsequent screenshot |
|---|---|---|---|
| 01, 0.3.0 reopen 1 | [exec envelope](01/failure-native.json) | [windows](01/failure-windows.json) | [original](01/menu-bar-20261028T105708-failure.png) / [subsequent](01/failure-observed.png) |
| 03, 0.4.0 reopen 1 | [exec envelope](03/failure-native.json) | [windows](03/failure-windows.json) | [original](03/menu-bar-20261028T112213-failure.png) / [subsequent](03/failure-observed.png) |
| 04, 0.3.0 reopen 3 | [timed-out exec envelope](04/failure-native.json) | [windows](04/failure-windows.json) | [original](04/menu-bar-20261028T112621-failure.png) / [subsequent](04/failure-observed.png) |

In 04, the observer stdout contains complete JSON agreeing with that state, but
the transport reports `timed_out: true`, exit -1 and `Process timed out after
30s`. This is a failed exec outcome, not a qualified successful native read.
It was not retried. The original and subsequent screenshots and agent ordering
independently retain the visible behind-TextEdit state. None of these observations
is an atomic event trace, and no failed observation proves absence.

The clean 01/03 native captures corroborate the activation symptom on both
releases; an agent ordering disagreement alone does not explain those results.
They do not show whether the Settings action callback ran, whether Koine became
active briefly and lost activation, or whether another input/activation sequence
prevented it. Menu dismissal alone does not prove callback delivery. The settled
TextEdit wait did not prevent these failures, so it is no demonstrated repair.

The precise missing observation is a time-correlated record spanning the single
Settings selection: callback entry, window-show/activation calls, and native
active/key-window transitions through the failing assertion. A separately
identified instrumented candidate could supply that record alongside an unchanged
released control. That would be a new bounded investigation, not an extra attempt
in this sample. Select and verify a repair only after that evidence distinguishes
the paths. No application change, focus retry, longer poll bound, external defect
ownership or upstream report follows from these results. [Issue 14](https://github.com/Linkuistics/Koine/issues/14)
therefore retains its unresolved activation outcome.

## Subject integrity and cleanup

[Before](subjects-before.sha256) and [after](subjects-after.sha256) regular-file
inventories agree item by item, as do [symlink before](links-before.txt) and
[after](links-after.txt). Each attempt also retains complete before/after subject
checks, regenerated hashes and diffs; every audit exits zero. The inventory covers
both release archives and every extracted file, App/Info.plist, Taskfile, the
scenario, all sourced shell helpers, both uploaded client fixtures, observer
source/binary, the protocol, wrappers and selected tools. The
[frozen PATH](tool-path.txt) and [resolved tools](tool-resolution.txt) associate
hashed executables with the invocation environment.

The [installed-input comparison](installed-input-check.txt) matches every available
guest inventory to the selected [0.3.0 input](expected-installed-0.3.0.txt) or
[0.4.0 input](expected-installed-0.4.0.txt). Only 02 reached the installed after
read. The golden [before](golden-before.sha256) and [after](golden-after.sha256)
digests match for its config, disk and NVRAM; the [comparison is empty](golden-diff.txt).
These are endpoint comparisons, not
continuous runtime immutability guarantees.

Explicit stop results for [01](01/stop.json), [02](02/stop.json),
[03](03/stop.json) and [04](04/stop.json), plus the final
[VM inventory](vms-after.json) and [Tart states](tart-after.txt), record cleanup.
No sample guest remains running. [Artifact comparisons](artifact-checks.txt)
verify that the retained scenario files match their original collection files.

## Instrument checks and interpretation

The [final checks](final-checks.txt) pass eight pointer, nine resize and six
wrapper controls. The [pre-freeze checks](checks.txt) and
[wrapper checks](wrapper-checks.txt) are retained separately. The sole
[fresh-context review](review.txt) found two measurement-integrity gaps before
freezing; both fixes are covered by executable controls. Removing both fixes in
an isolated copy makes [exactly those two controls fail](wrapper-mutation-checks.txt).
These checks establish script behavior, not native application reliability.

The complete 0.4.0 pass establishes the full route for that attempt, including
actual minimum-size scrolling. The failures establish that the activation symptom
persists under the settled recipe on both releases. The sample is small,
sequential and confined to one host/image/tool version; it supports no population
rate or comparative regression claim. Safe guest-read retries inherited from the
settled helper are distinct from scenario retries, of which there were none.
Keep these results separate from historical counts, k3's corroborated failed
complete attempt, its unrun assertions, k10's focused trials and its single
complete pass. Those earlier records remain in the [main document](../menu-bar-vm.md).
