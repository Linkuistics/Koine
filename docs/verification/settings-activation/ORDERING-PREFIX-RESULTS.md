# Settings focused prefix results

This report belongs to `settings-focused-prefix-k62`. It delivers two things.
The first is the focused prefix of the complete ordinary Settings scenario,
with a reusable byte check. The second is the comparison of every original
shared-scenario and migration duty with the delivered source and controls.

The evidence is source and controls only. No VM ran, and no signed subject was
built or frozen. No clone was requested, and no runtime slot ran. The work
establishes no native behaviour, no scenario readiness and no ancestor
closure.

## The prefix

The focused set E of the [ordering protocol](ORDERING-EVALUATION-PLAN.md#matched-observable-setup)
runs the complete scenario up to the TextEdit quit and stops before the resize.
The prefix is
[`scripts/vm-verify-menu-bar-prefix.sh`](../../../scripts/vm-verify-menu-bar-prefix.sh).
It holds the first 155 lines of
[`scripts/vm-verify-menu-bar.sh`](../../../scripts/vm-verify-menu-bar.sh),
which are 9,000 bytes. The last of those lines ends the `quit_guest_textedit`
command. The next line that is not blank is the resize step.

The prefix sits beside the scenario, so its repository-root `cd` needs no
change. Every byte therefore matches, including the header comment, which
describes the complete scenario. The prefix also keeps the declarations that
only the later scenario uses, so its ShellCheck run disables SC2034 alone.

The prefix and the scenario source the same libraries. They therefore share
every helper, predicate, setup rule, title rule and liveness rule, as the
protocol requires. The EXIT trap of `scripts/vm-settings-scenario-lib.sh`
reports the status of the prefix. The prefix prints no PASSED line, and it
sends no VM stop.

The Task entry `app:vm-verify-menu-bar-prefix` runs the prefix with the same
wrapper as `app:vm-verify-menu-bar`. It writes the status to
`KOINE_K4_OUT/scenario.exit`, and Task exits with that status. Run it only
under the reviewed finite caller of k57.

## The check

[`scripts/check-settings-prefix.py`](../../../scripts/check-settings-prefix.py)
reads the scenario and finds the boundary in its text. It needs exactly one
line that starts with `quit_guest_textedit` and exactly one resize step. The
quit command ends at the first line that does not end with `||`, `&&`, `|` or
a backslash. Only blank lines may follow it before the resize step.

The expected prefix is every scenario line through the end of the quit
command. The check compares the prefix with those bytes. It also needs the same
execute permission on both files. A difference prints the first differing byte
and line, and the check exits 1. A usage error or an unreadable file exits 2.

The check derives the boundary from the current scenario. A change before the
quit therefore fails the check until a new extraction. A change after the quit
does not touch the prefix. To extract the prefix again, copy the scenario lines
through the end of the quit command. Then run the check.

## Controls

`task check:vm-settings-prefix` runs the check on the real files, the static
checks and the new suite
[`Tests/scripts/vm-settings-prefix.bats`](../../../Tests/scripts/vm-settings-prefix.bats).
The behavioural tests run the prefix and the complete scenario against the
same simulated backend, `Tests/scripts/fixtures/settings-scenario-backend.py`,
in a copied repository. They compare the logged calls and the recorded waits.
The kept calls drop the evidence root. An upload keeps only the file name of
its local path, because each run's work directory has a random name.

| Control | What it establishes |
|---|---|
| Exact bytes | The check passes on the real files. A direct read shows three facts. The prefix is a byte prefix of the scenario, and its last command is the quit. The scenario's next line that is not blank is the resize step |
| Mutated prefix | A changed wait, a missing quit, a run into the resize step, an extra blank line and a missing final newline each fail the check. The restored bytes pass |
| Changed scenario | An added screenshot before the quit fails the check. A new extraction passes. A changed wait after the quit leaves the prefix valid |
| Boundary rules | No quit, two quits, no resize step and a command before the resize step are each refused, with the reason |
| Permission | A prefix without the execute permission fails the check |
| Same calls and waits | The prefix logs exactly the complete run's first calls. Its last three calls are the quit, the clean absence read and its state receipt. The complete run continues with `resize-move`. The waits match in value and order up to the quit. Each of the four selections has its setup reads, its enabled read and its setup screenshot. The report states status 0, with no PASSED line, no stop and no legacy call |
| Same failures | The control injects ten unavailable answers inside the prefix and fifteen flags at the fourth selection. Each case gives the same status, calls, waits and outcome lines in both runs. The answers cover the TextEdit PID, the setup reads, the enabled read and the open-menu screenshot. They also cover the count poll, the closed-menu read, the quit and its absence read. The flags cover each setup fact, the route and every outcome class |
| Same signal | A HUP in the TextEdit settling wait stops both runs at the same call with status 129 |
| Task entry | `app:vm-verify-menu-bar-prefix` writes status 0 for a clean run and status 125 for a failed setup read, and Task fails with it |

The records are in [`ordering-prefix-evidence/`](ordering-prefix-evidence/).
`record.sh` is the k67 record script, unchanged.

- `red.txt` runs the final suite in this tree with two differences. The prefix
  holds the historical boundary, which stops before the quit, and the Taskfile
  has no new task. Seven of nine tests fail. The correspondence, mutation,
  permission, behaviour and Task controls fail for the wrong boundary. The
  failure control fails only at its quit cases. The signal control passes,
  because its signal arrives before the boundary. The subjects stay unchanged
  during the run.
- `mutations.txt` records two mutation controls. The guard of each failure case
  refuses a run that reached the quit's absence read. The check refuses the
  historical `order-prefix.sh` as the focused prefix.
- `final-verification.txt` runs each affected Taskfile check after the change.
  The section [Final verification](#final-verification) gives its result.

The first draft of the failure guard negated a `grep` with `!`, and its pattern
expected a space that `jq -c` does not print. Bats does not fail a test on a
negated command, so the guard tested nothing. ShellCheck reported the negation
before any record. The guard now uses a helper that returns 1, and
`mutations.txt` shows it fail.

## Method of the duty comparison

The comparison covers the archived contracts of k56, k53, k61, k66, k71, k75,
k80 and k85 in
[`grove-tree-structure/original-briefs/`](../grove-tree-structure/original-briefs/).
It also covers every later ordinary assertion beyond the prefix.

Four bounded read-only helper sessions read the contracts, the source, the
suites and the reports. Each one cited a source line and a quoted test name for
each duty. Each checked every test name with `rg -F` against its suite. This
session then checked each claim that decides a disposition. These are the
upload limit, the missing k55 red record, the signal receipt outcome, the
explicit waits and every quoted test name in this report.

Each duty gets one disposition:

- **Met**: delivered source and a control exist.
- **Owned**: a named live task holds the duty, and its task file says so.
- **Withdrawn**: the ADR
  [`settings-harness-takes-no-keepalive-captures`](../../adr/settings-harness-takes-no-keepalive-captures.md)
  withdrew it.
- **Limit**: a reviewed report accepted the shortfall as a visible trade-off.
- **Gap**: nothing delivers it and no owner holds it. Each gap below has a new
  owner.

The tables name the suites by file. Each suite `X.bats` runs under the Taskfile
task `check:X`. Red names the record of the control failing before its repair,
under this directory.

## k56 and k53: the shared scenario and the harness

| Duty | Disposition | Source | Control and red |
|---|---|---|---|
| Migrate the complete scenario and every consumed helper. Replace the legacy transports and discarded results | Met | `vm-verify-menu-bar.sh` 54–346. `settings_fence` in `vm-settings-scenario-lib.sh` | `vm-settings-scenario.bats`: "the adopted scenario runs to PASSED with every call in one root initialised first", "a fenced legacy transport latches instead of dispatching". Red: `ordering-scenario-evidence/red.txt` |
| Enumerate every reachable call site | Met for the scenario and its library. The helper scan is a gap | Caller tables in ORDERING-SCENARIO-RESULTS and ORDERING-OUTCOMES-RESULTS | "the caller inventory finds no legacy transport in the adopted scenario surface" scans the scenario and its library only. See [gap G2](#gaps-and-their-owners) |
| Actual payload schemas. No missing field read as a negative | Met for each facade | `validate_response` in `vm-guest-exec.py`. The grammars in `vm_exec_reads.py`. `settings_title_audit` | `vm-window-evidence.bats`: "window schemas reject incomplete arrays and malformed required or optional fields". `vm-guest-exec.bats`: "missing and wrongly typed envelope fields cannot qualify matching text" |
| H-1: read the latch before non-exec input, latch failed non-exec attempts, one ordinal and writer-lock domain | Met | `run_locked` and `run` in `vm-guest-exec.py`. `fail_guest_evidence` and `record_guest_poll` in `vm-guest-exec-lib.sh` | `vm-guest-exec.bats`: "exec latch and incomplete receipts gate nonexec without dispatch", "nonexec attempts share exec ordinals and retain exact raw JSON". Red: `ordering-nonexec-evidence/baseline-red.txt` |
| H-1: no hand-written latch, no bypass during collection | Met for the scenario. Collection owned by k57 | The scenario writes no latch file. The facade fallback in `_guest_evidence_backend` latches inside the domain, as k59 accepted (P2-3) | "missing backend and unexpected backend exit leave a persistent facade latch". Red: `ordering-transport-integration-evidence/baseline-red.txt` |
| INT, TERM and HUP stop input. Interruption stays separate | Met, with the receipt note in [limit L4](#limits) | `settings_begin` and `settings_signal` | `vm-settings-scenario.bats`: "HUP during a scenario wait records the signal and sends nothing more", "TERM in the settling sleep after a clean held point sends no further input or release", "INT during a held-point attempt keeps it interrupted and sends no release". Red: `ordering-scenario-evidence/red.txt` |
| Preserve signal and partial outcomes. No ignored nonzero status restores eligibility | Met | Sticky latch in `run_locked`. `_physical_sleep` in `vm-physical-evidence-lib.sh` | `vm-guest-exec.bats`: "caught SIGINT records interruption and preserves the signal exit". `vm-settings-scenario.bats`: "a failed settling wait after a clean held point stops input and release without a trap". Red: `ordering-scenario-integration/red.txt` |
| Hand collection and containment to k57 | Owned by k57 | `settings_report` sends no stop | "the adopted scenario runs to PASSED with every call in one root initialised first" refutes a stop |
| Strict exec, agent, pointer, input, capture, upload and lifecycle transports | Met. The stop is owned by k57 | `read_guest_exec`, `read_guest_windows`, `read_guest_element`, `check_guest_read`, `click_at`, `drag_window_corner`, `scenario_input`, `capture_guest_evidence`, `upload_guest_file`, `start_guest_vm`, `inventory_guest_vms` | One family suite each, with red records under `ordering-*-evidence/` |
| A failure latch stops input | Met | `settings_stop` | "an unavailable answer in any transport family stops every later scenario input" injects 37 faults. Red: `ordering-scenario-evidence/red.txt` |
| Clean negative polls continue. A failed read stops at unchanged bounds | Met at each facade. Three strict loops lack a bound control | `await_guest_endpoint`, `_await_guest_windows`, `_sysevents_poll`, `settings_reveal`, the Add loop | `vm-window-evidence.bats`: "only clean list negatives advance the ten by two count poll". See [gap G1](#gaps-and-their-owners) |
| Exact defaults, launch identity, TextEdit quit and absence, restart with a changed boot. Disconnect unavailable <!-- tc: depart synonym-rotation because the launch identity names an application launch, while start names the VM start --> | Met | `settings_expect_defaults`, `confirm_guest_launch`, `confirm_guest_reopen`, `quit_guest_textedit`, `restart_guest` | `vm-exec-one-shot-evidence.bats`: "the TextEdit quit needs a clean submission and then one clean absence read", "a failed restart submission is unavailable even if the boot later changes". Red: `ordering-one-shot-evidence/baseline-red.txt` |
| A demonstrably unavailable completion holds before E01 | Owned by k54 | ORDERING-ONE-SHOT-RESULTS finds infeasibility not demonstrated | k54 task, readiness bullet |
| Positive setup before each of the four selections, with screenshots | Met. The screenshot audit is owned by k54 | `settings_record_textedit`, `settings_expect_setup` | `vm-settings-scenario.bats`: "the positive setup precedes each of the four selections and uses the zero-count list". Red: `ordering-outcomes-evidence/red.txt` |
| Raw count and front lists. The title audit on the same list | Met | `settings_await_windows`, `settings_koine_in_front`, `settings_title_audit` | "a wrong title on the front list is a window-identity failure, for later returns too". Red: `ordering-outcomes-evidence/red-title.txt` |
| Untouched failure observations: after a failed assertion, one observer read, one window read and one screenshot before other collection | Met for the returns, the clean single-read failures, the resize front check, the count polls and the reveal (k165). The observer is NOT RUN before the Automation check. Polls that a facade exhausts are [gap G6](#gaps-and-their-owners) | `settings_return_observations`, `settings_failure_observations`, `settings_fail`, `settings_fail_as`, `settings_expect_front`, `settings_await_windows`, `settings_reveal` | The five k165 controls and "a disabled row is recorded and not clicked". Red: `ordering-prefix-integration-evidence/red.txt` and `red-exhausted.txt` |
| Same-process zero windows versus process loss or unavailable liveness, for later returns too | Met | `settings_expect_return` | "zero windows with the same live process are a same-process recurrence, for later returns too", "a lost or replaced process after zero windows is process loss, not a recurrence" |
| Preserve the physical route, actions, waits and poll bounds | Met by comparison. See [the baseline comparison](#later-ordinary-assertions-and-the-baseline) | `settings_select_return` and the facades | `vm-physical-evidence.bats`: "strict menu route retains exact raw completions, VM, ordinals and unchanged waits" |
| Extract the prefix and check its bytes. E and A share the helpers and the rules | Met by this task | `scripts/vm-verify-menu-bar-prefix.sh`, `scripts/check-settings-prefix.py` | `vm-settings-prefix.bats`, all nine tests. Red: `ordering-prefix-evidence/red.txt` |
| Failing controls for malformed, partial, timeout-with-text, nonzero and missing-marker answers | Met at the facades. The k55 base suite keeps no red record | `validate_response` | Facade red records exist for each class. See [limit L5](#limits) |
| The finite caller: first-failure stop, audits, interrupted collection, exact stop and inventory | Owned by k57 | — | k57 task |
| Taskfile checks. Earned review and every integration before runtime | Met through k162. The whole shared-scenario review follows this task | — | `ordering-outcomes-integration-evidence/final-verification.txt`. Reviews k159 and k161 |

## k61, k66 and k71: the migration

| Duty | Disposition | Source | Control and red |
|---|---|---|---|
| Migrate exec, agent, pointer, capture, upload, lifecycle and collection. Failed transport stops input | Met. Finite collection owned by k57 | `settings_start_vm`, `settings_install_app`, `settings_capture`, `settings_failure_capture` | "an unavailable answer in any transport family stops every later scenario input" |
| No constant-true predicate | Met by reading. No control scans the strict surface | Each call site passes its own predicate | Only `vm-input-evidence.bats` and `vm-click-evidence.bats` assert a predicate that is not constant. See [gap G2](#gaps-and-their-owners) |
| K63: clean negatives come from list-shaped payloads | Met | `_await_guest_windows`, `await_guest_endpoint` | "only clean list negatives advance the ten by two count poll" |
| K63: typed WINDOW_NOT_FOUND, ELEMENT_NOT_FOUND and TEXT_NOT_FOUND are CLI 3 and unavailable | Met for WINDOW_NOT_FOUND. The other two lack a fixture | `validate_response` refuses every nonzero CLI status | `vm-window-evidence.bats`: "failed poll stops immediately despite matching text with no retry or input". See [gap G3](#gaps-and-their-owners) |
| K63: no inspect or wait poll. `find-text` without tolerated errors | Met | `read_guest_text` is one read | `vm-click-evidence.bats`: "failed partial and typed-error OCR stop before click and sleep" |
| K63: the evidence class admits collection and the exact stop only. `snapshot --open-menu` is input. Free exec collection is read-only | Met | `cli_argv` in `vm-guest-exec.py`. `command` in `vm_exec_reads.py` | `vm-guest-exec.bats`: "evidence class refuses mutating CLI actions even after a prior latch". Red: `ordering-nonexec-integration-evidence/evidence-class-red.txt` |
| The root before every transport | Met | `settings_begin` | "an existing evidence root is refused before any transport". Red: `ordering-scenario-evidence/red.txt` |
| Silent launch and running reopen | Met for the reopen. The silent launch has no failure control | `settings_launch`, `confirm_guest_reopen` | "an app reopen that shows no window compares the silent launch's process". See [gap G1](#gaps-and-their-owners) |
| K68: a signal during a held point and during the sleep after a clean `resize-down-N`. No release | Met | `drag_window_corner`, `_physical_sleep`, `settings_signal` | The INT and TERM controls above, and "a failed settling wait after a clean held point stops input and release without a trap". Red: `ordering-scenario-integration/red.txt` |
| A clean down without a later clean release is held. A failed or partial point is uncertain | Met for held and interrupted. Failed and partial points lack a control | `settings_held_pointer` | The TERM and INT controls. See [gap G4](#gaps-and-their-owners) |
| No failed or partial release proves a release. Orphan-lock refusal | Owned by k57 | — | k57 task, physical-helper containment handoff |
| Replace the whole TextEdit block once, with no extra read | Met at the facade. The call site has no count control | `await_guest_textedit_window`, called once | `vm-window-evidence.bats`: "TextEdit always makes the separate assertion read after an early positive". See [gap G1](#gaps-and-their-owners) |
| Exhaustion is state-failed. Local steps keep their statuses | Met | `run_locked` poll steps | "clean exhausted polls retain each list and a separate state confirmation" |
| Background keepalive capture | Withdrawn | `settings_start_vm` starts no loop | `vm-verify-start.bats`: "the Settings scenario start path starts no background screen capture" |
| K78: checked read failures propagate before later input | Met | `settings_reveal`, `settings_expect_menu` | `vm-input-evidence.bats`: "failed snapshot read stops actual click chains in plain and conditional contexts" |
| K78: a clean on-screen negative is status 1, and a read failure is never status 1 | Met in the legacy lane. The strict lane lacks its own control | `settings_on_screen` | `vm-input-evidence.bats`: "on-screen read status one is an error rather than a clean negative". See [gap G1](#gaps-and-their-owners) |
| Private roots. No silent redaction of secret-bearing evidence | Met for the root mode. The consent path lacks a raw-retention control | `initialize` gives mode 700 | `vm-guest-exec.bats`: "init creates a root that only its owner can enter, whatever the umask". See [gap G4](#gaps-and-their-owners) |

## k75, k80 and k85: reads, artifacts and lifecycle

| Duty | Disposition | Source | Control and red |
|---|---|---|---|
| Snapshot, element, window and OCR reads | Met | `read_guest_element`, `read_guest_windows`, `read_guest_text` | `vm-ui-evidence.bats`: "snapshot retains original bytes full tree exact argv VM and shared ordinals". Red: `ordering-snapshot-evidence/` |
| K83: `optional-vertical` for the on-screen read, `position-y` for calibration and reveal, no second read | Met at the facade. The scenario's choice of mode lacks a control | `settings_on_screen`, `settings_calibrate_window_scroll`, `settings_reveal` | "optional vertical reads preserve absence and qualify only consumed screen attributes". See [gap G1](#gaps-and-their-owners) |
| K83: a missing tree is unavailable. The empty AXValue stays unverified natively. Selectors are checked per candidate | Met as limits | `_read_guest_snapshot`, `_ui_element_selection` | "a missing tree in another window refuses a positive and stops a settling poll", "selector qualification depends on candidates and syntax failure follows dispatch" |
| Physical clicks: exact Allow and element centre | Met | `click_guest_allow`, `click_guest_element` | `vm-click-evidence.bats`: "Allow chooses first exact text floors its centre and clicks once" |
| K87: no exact Allow is state-failed. Invalid geometry is unavailable. Exact local signal statuses | Met | `click_guest_allow`, `_click_guest_target` | "clean OCR without exact Allow records state failure without input". Red: `ordering-click-integration/exact-target-red.json` |
| K87: the OCR substring stop of v2.7.0 | Limit, accepted by k87 | `read_guest_text` keeps `--timeout 30` | ORDERING-CLICK-RESULTS, K86 P3-1 |
| Captures: complete artifacts at unique private paths. Generic CLI capture refused. Native PNG bytes accepted | Met | `capture_guest_evidence`. `vm_capture_artifact.py` | `vm-capture-evidence.bats`: "generic CLI capture refuses every class without dispatch or overwriting caller files". Red: `ordering-capture-integration/repair-red.txt` |
| Upload: local identity, remote path and reported size | Met | `upload_guest_file` | `vm-file-lifecycle-evidence.bats`: "upload records exact argv raw receipt and stable local identity before and after dispatch" |
| Upload: the guest copy of the bytes | Limit, accepted by k89 and k149 | The scenario takes no download | ORDERING-FILE-LIFECYCLE-RESULTS "Limits": a download needs a new human amendment. See [limit L2](#limits) |
| Installed files and the installed inventory | Met. Per-item audits owned by k57 | `submit_guest_extraction`, `settings_record_installed_bundle` | `vm-exec-read-evidence.bats`: "the installed inventory keeps the legacy command and needs its exact rows" |
| Environment: system and Gatekeeper records | Met as reads. The comparison with the declared image has no owner | `settings_start_vm` reads `system` and `gatekeeper` | "setup records keep each documented clean status as data". See [gap G5](#gaps-and-their-owners) |
| VM start and independent inventory | Met. The stop and the inventory after it are owned by k57 | `start_guest_vm`, `inventory_guest_vms` | "VM start pins the base wait and identity and qualifies the complete start payload" |
| Collection receipts | Owned by k57. The seam is met | Evidence-class admission in `vm-guest-exec.py` | "latched CLI evidence still admits collection and exact clone stop" |
| Shared writer lock and latch. Allocation failure blocks later input | Met | `run` and `run_locked` | "capture holds shared lock through CLI and refuses competing scenario dispatch" |
| Keepalive cadence, contention and owner design | Withdrawn | — | The ADR |
| Finite storage plan and partial audits | Owned by k57 | — | k57 task, ownership after k140 |

## Later ordinary assertions and the baseline

The protocol's baseline is commit `f019161b`, the k51 integration. A helper
session listed each step of that scenario and its helpers, from the first
launch to the port refusal. It matched each step to the current source. This
session checked the scenario's explicit waits again. They are 8, five
1-second waits, 2, 4, 4 and 2 seconds, and three 6-second settles, in the same
order. The restart
waits of 30 and 5 seconds and the 5-second login poll moved into their facades
with the same values.

No added wait, retry or input was found, and no change of input order. Every
input action, explicit wait and poll bound matches in value and position. The
added reads are the protocol's observations. They lengthen the gaps between
existing inputs. The protocol accepts that cost, and it makes no claim of
timing neutrality.

| Change since the baseline | Class | Reason |
|---|---|---|
| Keepalive capture loop | Removed | The ADR |
| VM stop, work deletion and `KOINE_VM_KEEP` in the cleanup trap | Removed | k57 owns the exact stop, as ORDERING-SCENARIO-RESULTS "Interface" says |
| `KOINE_SETTINGS_TRACE=1` defaults write | Now a refusal | The protocol permits no enabling write |
| `KOINE_VM_BASE` | Now required | The clone needs a declared base, as k64 integrated |
| Count-poll failure messages at each return | Now an outcome class with the judged list | ORDERING-OUTCOMES-RESULTS "Outcome classes" |
| Every failed assertion | Now an observer read and a window read before the failure screenshot. No input follows | The protocol, lines 187–193. [Integration of review k163](#integration-of-review-k163) |
| Front-check messages | Now name the judged list, not a second read | ORDERING-SCENARIO-RESULTS "Outcomes and statuses" |
| TextEdit quit | Now strict, with one absence read and an assertion | The protocol's one-shot table |
| Corner drag after a failed down | No best-effort release in strict mode | ORDERING-PHYSICAL-RESULTS and review k159 P2-1 |
| Minimum content read with no element or height | Now unavailable, not a failed height | ORDERING-SNAPSHOT-RESULTS caller table |
| Field value after cut | A missing AXValue is now unavailable, not empty | ORDERING-SNAPSHOT-RESULTS `value_of` row |
| Request-label echo | Now a required value read | Review k159 P2-2 |
| Restart poll | A refused read now stops at once | The protocol's restart row |
| Port refusal loop of four attempts | Now one read | A clean read always ended the loop |
| Port read | Now asserts `.present == true` | No report names the message. The baseline's errexit stopped there without a message |
| Background-only echo | Now after its assertion, so a failure prints no value | Not cited. Message order only |
| `read_frame` failure message | No longer prints the entry | Not cited. Message text only |
| Click on an element that vanished after its reveal | "was not delivered cleanly", not "no UI element matches" | Not cited. Message text only |

The last four rows change a message or an echo, not an action, a wait, a bound
or a predicate. This report records them so that k57 and the review can see
them. An exhausted poll now exits with status 125 while its receipt says
`state-failed`. k57 classifies the receipt, not the status.

## Gaps and their owners

G1 to G5 are missing controls or comparisons. G6 is missing failure
evidence, which review k163 found in a wider form (P2-1). No gap is a missing
product behaviour in the scenario. The task `settings-scenario-controls` owns
G1 to G4, before k57. k57 owns G5 through its handoff. The task
`settings-exhausted-poll-observations` owns G6, before
`settings-scenario-controls`.

- **G1, scenario-level bounds and call-site counts.** No strict-lane control
  exhausts the reveal loop (60 reads), the calibration (30 scrolls) or the Add
  loop of `settings_grant_accessibility` (15 reads and 14 waits). No control
  counts the TextEdit reads at the scenario's call site. No control pins
  `optional-vertical` and `position-y` at their scenario call sites. No control
  drives a window at the silent launch to its failure. No strict-lane control
  separates a clean on-screen negative from a read failure.
- **G2, surface scans.** The caller inventory scans the scenario and its
  library only. Five legacy-lane calls stay in `vm-input-evidence-lib.sh`,
  `vm-physical-evidence-lib.sh` and `vm-window-resize-lib.sh`. They run only
  without a root, and the scenario always has one. No control scans the strict
  surface for a constant-true predicate.
- **G3, typed errors.** ELEMENT_NOT_FOUND and TEXT_NOT_FOUND with CLI status 3
  have no fixture. WINDOW_NOT_FOUND has one.
- **G4, held state and privacy.** No control gives `uncertain` for a failed or
  partial `resize-release`, or for an unavailable or partial `resize-down-N`.
  No control runs the consent path with a `KOINE_VM_PASSWORD` override and
  checks that the raw text stays in the private root.
- **G5, the declared environment.** The protocol says to check the guest
  environment after boot and to hold on a mismatch. It also rejects injected
  arguments or environment. The scenario reads `system`, `gatekeeper` and the
  process arguments, but nothing compares them with the declaration. The k57
  handoff now names this comparison.
- **G6, observations after a facade's exhaustion.** Four reviewed facades
  record their own state-failed receipt when a poll exhausts. They are the
  launch endpoint poll, the System Events label and frame polls, the TextEdit
  window poll and the exact Allow target. That receipt latches the root, and
  the latch refuses the System Events observer. These failures keep only the
  screenshot. See [the integration of review k163](#integration-of-review-k163).

## Integration of review k163

Review `settings-focused-prefix-k163` is in
[ORDERING-PREFIX-REVIEW.md](ORDERING-PREFIX-REVIEW.md). Integration
`settings-focused-prefix-k165` verified its one finding against the protocol
and the source.

### P2-1: a real issue, repaired

The protocol requires an observer read, a window read and a screenshot after
a failed assertion, before other collection. The returns took them since k67.
Every other failure took only the screenshot. The review named the resize
front check, `settings_fail` and the unavailable resize title audit. This
integration counted the whole class of failed assertions, not only the named
paths. Where the latch is written decides each repair.

| Failure path | Before | Now |
|---|---|---|
| A clean single-read failure, through `settings_fail` or `settings_fail_as` | Receipt, then screenshot | Observer, window list and screenshot under the operation `assertion`, then the receipt |
| A false front or title at `settings_expect_front`, including a false front beside an unavailable audit | Receipt or stop, then screenshot | Observer, window list and screenshot under the check's own operation, then the receipt or the stop, as at a return (k162) |
| An exhausted count poll through `settings_await_windows` | The facade's receipt, then screenshot | The poll's deferred mode. Observer, window list and screenshot, then the same `OPERATION-exhausted` receipt with the same status |
| An exhausted reveal | Receipt, then screenshot | Observer, window list and screenshot, then the receipt |
| An exhausted poll inside a reviewed facade | Receipt, then screenshot | Unchanged. This is gap G6 |
| An unavailable answer, through `settings_stop` | Screenshot | Unchanged. An unavailable answer is not a failed assertion |

The observer is a System Events read. The latch refuses it, because an Apple
event can change the guest. So each repair places the observations before the
state-failed receipt. Simply moving the read after the receipt would record
only a refusal, as the review warned.

Each repair keeps the successful actions, reads, waits and bounds. No input
follows a failure. The receipts keep their names and outcomes. The count
poll's message now counts the windows of the list that its last read judged.
The real run gave the same value from the record file. The legacy lanes of
the facades are unchanged.

### The observer before the Automation check: a visible trade-off

Two clean failures can come before the System Events Automation check passes.
They are the rejected signature and the refused System Events check. There,
the observer read cannot succeed. Its Apple event can also raise the consent
prompt, which changes the guest after the failure.

So the observer is NOT RUN until that check passes, and the scenario prints a
`NOT RUN` line. The window list and the screenshot still run. Every return and every later failure comes
after the check.

### Polls that a facade exhausts: gap G6

Four reviewed facades record their exhaustion receipt themselves, so the root
latches before the scenario can observe. The review did not name them, but
they belong to the same duty. Their repair needs a deferred mode in four
reviewed facade families, as k67 gave the return count poll. That change is
too large for this integration, so the new task
`settings-exhausted-poll-observations` owns it before
`settings-scenario-controls`.

### The other doubts

The review raised three other doubts and no other finding. Each one stays as
the review classified it:

- **The boundary check.** The check is a textual recogniser. A
  here-document can contain a matching quit line. The behavioural control
  catches that omission. Retain both checks. This is a limit.
- **Normalised calls.** The comparison drops the root and reduces upload
  paths to base names. The installed and frozen-input audits stay with k57.
  This is a limit.
- **G1's counts.** A fully exhausted reveal makes 120 element reads and one
  frame read, not 60 reads in total. The calibration makes one probe scroll
  and 30 return scrolls. `settings-scenario-controls` applies these counts.
  The k165 control "an exhausted reveal takes the untouched failure
  observations before its receipt (k165)" reaches that exhaustion with the
  simulator flag `scroll-ignored`.

### Controls and verification

Five new controls in `vm-settings-scenario.bats` carry "(k165)" in their
names. Two existing controls gained order assertions. They are "a disabled
row is recorded and not clicked" and "an unavailable title audit beside a
false front predicate stays unavailable (k162)". Each control failed against
the source before its repair. `red.txt` and `red-exhausted.txt` in
[`ordering-prefix-integration-evidence/`](ordering-prefix-integration-evidence/)
keep those runs. `mutations.txt` shows two observer-gate mutations, each
detected.

The simulator gained three variations. `settings_finder_front` puts a focused
Finder window in front at one read. `settings_close_ignored` keeps the window
open after one close. The flags `resize-ignored`, `scroll-ignored` and
`signature-invalid` stop the resize, the scroll and the signature.

`final-verification.txt` in the same directory runs the nineteen Taskfile
checks of the k62 record. The prefix check passes unchanged, because the
repair changes only the library, which E and A share. No VM, clone or runtime
slot ran.

## Limits

- **L1.** The simulated backend models only the answers that the scenario
  needs. A same-call comparison establishes the shared source path, not native
  behaviour. No guest ran.
- **L2.** A checked upload proves the local bytes, the remote path and the
  reported size, not the guest copy. The installed audit covers the bundle, but
  not the two uploaded scripts. A download needs a new human amendment.
- **L3.** Four availability limits stay binding. They are the missing
  snapshot tree, the unverified empty AXValue after a cut, the OCR substring
  stop and the unverified menu oracle of k162.
- **L4.** The signal record `scenario-signal-SIG` has the outcome
  `unavailable`, like a transport failure. The operation name, the exit status
  128 plus the signal number and the `INTERRUPTED` line keep it separate. A
  receipt says `interrupted` only for a signal inside a backend call.
  ORDERING-SCENARIO-RESULTS states the rule more broadly. k57 classifies the
  signal by its operation name.
- **L5.** The k55 base suite keeps no red record. ORDERING-TRANSPORT-RESULTS
  says in prose that its twelve first controls failed without the backend. The
  facade suites keep red records for the same classes. The past state cannot be
  recorded again.
- **L6.** The prefix records the installed inventory before the first launch
  only. The complete scenario compares it again at its end. For E, the
  installed audit after the slot belongs to k57.

## Final verification

`final-verification.txt` runs nineteen Taskfile checks. They are the eighteen
checks of the k162 record and `check:vm-settings-prefix`. All of them pass,
with 326 passing tests and no failure. None of the 4,533 subjects changed
during the run.

`red-prefix.sh` keeps the historical-boundary prefix of the red run. The
record files, the last entries of the task file and the retirement of the leaf
come after the final run.

## Handoff

- The review `settings-focused-prefix` (review-impl) reads the whole shared
  scenario, the prefix, its check and this comparison before any consumer.
  Integration k165 repaired its finding. See
  [the integration of review k163](#integration-of-review-k163).
- `settings-exhausted-poll-observations` closes G6 before
  `settings-scenario-controls`.
- `settings-scenario-controls` adds the controls of G1 to G4 after the review
  and every earned integration.
- k57 consumes this comparison in its complete pre-runtime reconciliation. It
  also owns G5, the defaults read after each slot, the installed audit after an
  E slot and the classification of signal and exhaustion receipts.
- k54 owns the freeze, the readiness, the screenshot audit and the runtime.
  The frozen subject includes the prefix, the check and the new suite.
