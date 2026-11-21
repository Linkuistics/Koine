# Settings scenario adoption results

This report belongs to `settings-scenario-adoption-k76`. The complete ordinary
Settings scenario, `scripts/vm-verify-menu-bar.sh`, now sends each transport
through the reviewed strict facades. All transports go into one evidence root,
which the scenario initialises before its first transport. The scenario also
handles INT, TERM and HUP. Both held-pointer cases have controls.

The evidence is source and controls only. No VM ran, and no signed subject was
built or frozen. No runtime slot started. The work establishes no native
behaviour, no scenario readiness and no ancestor closure.

## Interface

The entry point and its Taskfile task stay the same:
`task app:vm-verify-menu-bar`. The strict layer is the source-only library
[`scripts/vm-settings-scenario-lib.sh`](../../../scripts/vm-settings-scenario-lib.sh).
Sourcing it defines functions only. The shared libraries keep their legacy
lanes for the other VM scripts.

| Input | Meaning |
|---|---|
| `KOINE_VM_BASE` | The golden image to clone. It is now required. A missing base latches the root, before any clone request |
| `KOINE_VM_ID` | The clone identity, as before. The default is `koine-verify-PID` |
| `KOINE_VM_EVIDENCE_ROOT` | A new root path. The default is `<log>-evidence` beside the transcript under `.build/vm-verify` |
| `KOINE_VM_DISPLAY` | The guest resolution, as before |
| `KOINE_SETTINGS_TRACE=1` | A refusal before the first launch. The protocol permits no enabling diagnostic write <!-- tc: depart synonym-rotation because VM start and application launch are different operations --> |

The scenario sends no VM stop and deletes nothing. At its end it prints the
root, the work directory, the held-pointer state and the clone. The finite
caller of k57 owns the single exact stop and the inventory, through the same
root. `KOINE_VM_KEEP` therefore has no effect on this scenario.

The root can hold `KOINE_VM_PASSWORD` in raw argv, predicates and responses.
Keep it private. Do not commit or publish it.

## The root and the fence

`settings_begin` is the first act of the scenario. It clears the legacy
cleanup trap of `scripts/vm-verify-lib.sh`, which sends a bare stop. Then it
calls `init_guest_evidence`, which refuses an existing directory. It exports the
absolute root for every facade. Then it installs the traps and the fence.

The fence redefines `testanyware`, `guest`, `guest_text`, `guest_json`,
`guest_once`, `guest_long`, `sysevents` and `snapshot` in the scenario shell. A
call to one of them records a failed confirmation, `legacy-transport`, and sends
nothing. The backend starts the real CLI as a subprocess, so the fence does not
affect it. The fence also maps the legacy `fail` to the strict failure.

## Outcomes and statuses

Each strict function keeps the legacy action, read count, wait, poll bound and
failure message. Two kinds of function exist. A function that a caller reads
with `$(...)` only returns a status. Every other function runs in the scenario
shell and ends the scenario on a failure.

| Status from a facade | Scenario outcome |
|---|---|
| 0 | The scenario continues |
| 1, a clean false state | One `state-failed` receipt, `scenario-assertion`, keeps the legacy message. The scenario exits 1 |
| Any other status | The facade already recorded its own receipt. The scenario keeps the status and exits with it |

The structured receipts keep three outcomes apart. A `state-failed` receipt is
an assertion that saw a clean false state. An `unavailable` receipt is a
transport, payload or local failure. An `interrupted` receipt is a caught
signal. A missing receipt never establishes a product failure.

A failure keeps the legacy failure screenshot as one evidence-class capture
into the root. A signal takes no capture.

A failure message that needs a value from a failed poll reads the newest record
in the root. That is a host file read, not a transport. The label poll, the
menu comparison and the window count use it.

A failed front-window assertion names the same list that it judged. The legacy
message read the list again. This keeps the k67 audit rule, and the failure
path has one read fewer. No other path changes. The front-application read of the first Settings
selection stays before the latch, as k151 requires.

## Signals and held input

INT, TERM and HUP each run one handler. The handler records one failed
confirmation, `scenario-signal-SIG`, in the same writer domain. It sends no
input and no release, and it exits with 128 plus the signal number. If another
process holds the writer lock, the backend records the refusal. That refusal
also latches the root.

A signal can arrive inside a call whose output goes to `/dev/null`. The report
therefore writes to the scenario's own streams, which `settings_begin` keeps on
descriptors 7 and 8. The report ignores later signals while it prints.

The report states the held-pointer state from the ordered receipts. A clean
`resize-down-N` without a later clean `resize-release` is `held`. A failed,
interrupted or partial held point or release is `uncertain`. This line only
reports. k57 inspects the ordered requests and completions itself.

The INT path has two defences against a release. The handler exits as soon as
the interrupted backend returns, before the release branch runs. The signal
record also latches the root, so the backend would refuse a later release.

## Caller table

The table maps each legacy caller to its strict call. Every row keeps the
legacy action, read count, wait and bound unless the row says otherwise.

| Legacy caller | Strict call |
|---|---|
| `_start_vm` start | `inventory_guest_vms absent`, `start_guest_vm`, then `inventory_guest_vms running` |
| `_start_vm` system and Gatekeeper records | `read_guest_exec system` and `gatekeeper` |
| `install_app` uploads of the zip and the client script | `upload_guest_file`, with no read after it |
| `install_app` extraction | `submit_guest_extraction`, then the signature verification as its confirmation |
| `install_app` quarantine, signature, display and assessment | `read_guest_exec quarantine`, `signature`, `signature-display` and `assessment` |
| `record_installed_bundle` | `read_guest_exec installed-inventory`, then an exclusive write of the same text |
| `KOINE_SETTINGS_TRACE=1` defaults write | `refuse_guest_trace_defaults` |
| Enrolment client upload | `upload_guest_file` |
| `grant_system_events_automation` | `request_guest_automation`, `click_guest_allow`, then `expect_guest_system_events` |
| Before the first launch | `check_guest_read defaults`, added by the protocol |
| First and silent launch | `launch_guest_koine`, `await_guest_endpoint launch`, then `confirm_guest_launch` |
| Reopen | `launch_guest_koine`, then `confirm_guest_reopen` with the silent launch's record |
| `await_koine` | `await_guest_endpoint launch` |
| `expect_stopped` | The existing 3-second wait, then `check_guest_read process executable` and `endpoint` |
| `frame`, `read_frame` and `koine_windows` | One `read_guest_windows` each, with a recorded local decision |
| `await_windows` | `await_guest_window_count` |
| `koine_in_front` and `front_windows` | One `read_guest_windows`, with a recorded decision on that list |
| TextEdit launch | `launch_guest_textedit` |
| TextEdit window loop and its final assertion | `await_guest_textedit_window`, once, with no extra read |
| TextEdit quit | `quit_guest_textedit`, with its absence read |
| Window move, focus and close | `act_guest_window` |
| `menu_item_count` | `expect_guest_menu_count` |
| `menu_item_label` echo | `read_guest_exec menu-item-label value` |
| `await_menu_item_label` | `await_guest_menu_label` |
| `open_menu` | `await_guest_menu_frame`, then `click_centre` on the record's `.text` |
| `read_menu` and `expect_menu` | `expect_guest_menu` with a list. The menu still closes before the comparison fails |
| `choose_menu_item` | `await_guest_menu_frame TITLE`, then `click_centre` and the existing 2-second wait |
| `BACKGROUND` and `DOCK` | `expect_guest_background_only` and `expect_guest_no_dock_item` |
| Front-application echo | `read_guest_exec front-application` |
| `enrol` | `submit_guest_enrolment` |
| `element` in `on_screen` | `read_guest_element optional-vertical` |
| `element` in `reveal` and the calibration | `read_guest_element position-y` |
| `value_of` | `read_guest_element value`, with a recorded decision |
| `click` and `reveal_click` | The existing reveal, then `click_guest_element`. `reveal_click` keeps its two reveals |
| Content frame at the least size | `read_guest_element height`, then an exclusive write |
| `scroll_by` and the keyboard inputs | `scenario_input`, unchanged |
| `drag_window_corner` and `click_centre` | The reviewed physical helpers, unchanged, in strict mode |
| `grant_accessibility` | `open_guest_accessibility_pane`, the 15-read Add loop, `click_guest_element`, the inputs, then the list check |
| Screen captures | `capture_guest_evidence read-poll`, as the operation `screenshot-NAME` |
| Boot before the restart, the restart and its poll | `read_guest_exec evidence boot`, then `restart_guest` |
| After the restart | `check_guest_read defaults`, added by the protocol |
| Login descriptor loop | `await_guest_endpoint login`. A clean exhaustion continues, as before |
| Login process assertion | `check_guest_read process bundle` |
| `PORT` read | `check_guest_read endpoint`. The descriptor record carries the port |
| Port refusal loop | One `read_guest_exec port-refusal`. A clean read always ended the loop |
| `cleanup` stop and deletion | None. k57 owns the stop, the inventory and the collection |
| `guest`, `guest_text`, `guest_json` and `guest_once` | Retired from the scenario and fenced |

The Add loop of `grant_accessibility` keeps 15 reads and 14 waits. A read
failure there is unavailable, because a missing tree cannot establish an absent
button.

## Changes outside the scenario

Three existing suites read the scenario script, so they changed with it:

- `Tests/scripts/vm-verify-start.bats` expects status 125 from the strict start
  path. It also accepts the one evidence-class failure capture, but no keepalive
  capture and no growth.
- `Tests/scripts/vm-window-resize.bats` evaluates the same resize section with
  stubs for the strict names. The section's own guards and its exclusive write
  run unchanged.
- `Tests/scripts/vm-input-evidence.bats` checks the legacy `read_menu` directly.
  The scenario's old `expect_menu` wrapper is gone.

`read_menu` in `scripts/vm-verify-lib.sh` now has no caller in any script. It
stays, with its legacy lane, because other scripts share that library.

## Controls and provenance

`task check:vm-settings-scenario` runs the new suite,
`Tests/scripts/vm-settings-scenario.bats`. Most tests run the real entry point
in a copied repository. A simulated backend,
`Tests/scripts/fixtures/settings-scenario-backend.py`, takes the place of
`scripts/vm-guest-exec.py`. Every facade then runs unchanged, and the backend
logs each call. The two held-pointer controls instead use the real backend and
a fixture CLI, so their receipts are the real ordered receipts.

| Control | What it establishes |
|---|---|
| Complete run | The adopted scenario reaches PASSED. `init` is the first backend call, one root holds every call, and the scenario sends no stop |
| Confirmation order | Each confirmation follows its submission, and the reopen reads `launch-identity` |
| One fault per family | 31 injected unavailable answers, one per transport family and position, each stop all later input |
| Legacy message | A failed read keeps the legacy failure message |
| Clean false state | A window that does not come to the front records `state-failed` with the legacy message, after the front-application read |
| Fence | An injected bare CLI call latches the root and reaches no CLI |
| Trace | `KOINE_SETTINGS_TRACE=1` refuses before the first launch |
| Base | A missing base latches before any VM start |
| Reused root | An existing root path stops the scenario before any transport |
| HUP | A HUP in the TextEdit settling wait records the signal and sends nothing more |
| TERM held point | A TERM in the wait after a clean `resize-down-2` leaves `held`, with no later down and no release |
| INT held point | An INT during `resize-down-3` keeps it `interrupted`, leaves `uncertain`, and sends no release |
| Caller inventory | No legacy transport stays in command position. The pre-adoption scenario is the positive control, and one injected call is the mutation control |

The evidence files are in
[`ordering-scenario-evidence/`](ordering-scenario-evidence/):

- `scenario-before.sh` is the pre-adoption scenario, and `red-subjects.sha256`
  holds the digests of the pre-adoption subjects.
- `red.txt` records all twelve first controls failing against the pre-adoption
  scenario.
- `mutations.txt` records four mutations that the controls detect. These are a
  missing TERM trap, a missing CLI fence, an unrecorded assertion, and an
  ignored INT trap together with the legacy release. The file also keeps one
  release-only mutation that the INT control passes. The handler exits before
  the release branch runs, so only both mutations together reach a release.
- `green.txt` is the passing transcript of each affected Taskfile check.
  `green-subjects-before.sha256` and `green-subjects-after.sha256` hold the
  digests of its subjects before and after the run.

The controls also found two defects during development, and the source now
repairs them. First, a failed root initialisation left the legacy cleanup trap
armed, and that trap sent a bare `vm stop`. Second, a signal inside a call
whose output went to `/dev/null` lost the end-of-run report.

## Limits

- The simulated backend models the guest only as far as the scenario needs it.
  It checks the use of the domain, not the payload schemas. The facade suites
  own the schemas.
- No guest ran. The availability limits stay binding: the missing snapshot
  tree, the unverified empty AXValue after a cut, and the OCR substring stop on
  "Don't Allow" or "allowed".
- The restart poll stays an unmeasured race with the agent outage, as k152 and
  k158 record. A refused poll read stays unavailable, even if the boot later
  changes.
- The installed CLI on this host is TestAnyware 2.9.0, and the schemas name
  2.7.0. k54 pins the frozen CLI.

## Remaining duties

These duties stay with their owners:

- k67 owns the positive setup, the title audits on the original lists and the
  same-process liveness.
- k62 owns the exact prefix through the TextEdit quit and the complete duty
  reconciliation.
- k57 owns the finite caller, the stop, the inventory, the collection and the
  per-item audits. It also owns the defaults read after the slot and the
  containment of held input.
- k54 owns the freeze, the readiness and the runtime.

The whole-harness review is a separate `review-impl` leaf, before k62 and the
runtime. No VM, candidate, freeze, acceptance or ancestor closure follows.
