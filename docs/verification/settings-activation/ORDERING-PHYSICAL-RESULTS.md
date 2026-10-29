# Physical helper migration boundary

K65 migrates the existing menu-pointer and paced corner-resize helpers onto the
reviewed evidence adapter when `KOINE_VM_EVIDENCE_ROOT` is explicitly set. The
complete ordinary scenario still uses legacy startup, exec, consent, UI and
collection paths. K61 now contains physical helpers (k65), complete remaining
transports/confirmations/signals (k66) and positive setup/outcomes (k67).
Independent physical-helper review and every earned integration precede further
migration. K62 still owns exact final-prefix verification and whole-duty
reconciliation; k57 owns the finite caller, and k54 owns readiness/runtime.
No VM, signed candidate, freeze, native acceptance or ancestor closure occurs.

## Using the migrated helpers

Source [the pointer helper](../../../scripts/vm-menu-pointer-lib.sh) or
[the resize helper](../../../scripts/vm-window-resize-lib.sh); neither starts a
process, transcript or VM merely by being sourced. Both load the small
[physical facade](../../../scripts/vm-physical-evidence-lib.sh), which consumes
the existing [reviewed adapter](ORDERING-NONEXEC-RESULTS.md).

```sh
source scripts/vm-menu-pointer-lib.sh
init_guest_evidence "$unused_directory" "$exact_vm_id"
KOINE_VM_EVIDENCE_ROOT="$unused_directory"
click_centre '100, 0, 22, 15'
```

This snippet describes the interface; it was not executed against a guest.
The caller must initialize an unused root, select it before every physical
action, check every return and use that same root for its other transports.
An explicitly empty, unknown or failed root never selects legacy transport.
Empty or uninitialized roots refuse before entering the adapter, so they create
no lock/latch in the current directory or another uninitialized directory.
The caller must retain that nonzero status and diagnostic in its own transcript;
there is no initialized evidence destination for an ordinal refusal.
Unset retains existing unrelated VM consumers during this migration. The
ordinary entry point does not yet initialize/select the root, so this increment
alone cannot make either ordering set eligible. No generic legacy command is
reclassified as strict merely because it sources these files.

Every strict physical request uses the shared lock, ordinal, raw stdout/stderr,
CLI status, predicate and terminal receipt. Required geometry reads are
`read-poll` attempts, with no helper retry or new poll loop; input is `one-shot`.
These labels prevent scenario geometry reads after a latch. Collection remains
the finite caller's explicit responsibility, using the adapter's finite
collection set. Free guest-exec collection must remain read-only context.

| Physical call | Command-specific predicate on the original response |
|---|---|
| `click_at` display read | Integer logical width/height, each 2–65535; target must lie inside that display. |
| Approach and target moves; resize preparation | Actual returned numeric `x` and `y` equal the requested coordinates. |
| Menu click | Coordinates equal the request, `button:"left"`, `count:1`. |
| Resize held points and release | Coordinates equal the request and `button:"left"`. |
| Resize frame read | Full `windows` array with required app/type/focus/numeric geometry fields; optional titles have string values. Exactly one entry has the requested title; its size and derived inset corner are usable in the CLI coordinate range. |

The adapter also requires a clean CLI status and its strict base envelope. No
call site uses a constant-true predicate. Resize targets keep the existing title
selection seam; this is not the separate Settings app/title/front audit k67 owes.
The resize read is a required usable-frame assertion, not a count poll that
interprets a missing target as a reason to retry.

Source decisions follow the immutable official `v2.7.0` tag after its workspace
manifest, not a mutable checkout or a guessed schema. The [input handlers](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/input.rs)
emit the actual coordinates/button/count; [screen size](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs)
returns logical dimensions. [WindowInfo](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/window_info.rs)
requires geometry/app/type/focus but permits absent titles. Citations sit beside
the code decisions. The [tagged-source receipt](ordering-physical-evidence/official-source.json)
records source digests. This proves which source was read, not the provenance or
runtime availability of an installed CLI, agent, endpoint or golden image.

With an initialized root, invalid targets/frames and failed local title/display/frame decoding record a
confirmation failure through `fail_guest_evidence`, rather than calling the
legacy failure helper's bare screenshot capture. A failed decoder's emitted
geometry is never consumed. Every nonzero adapter return, including SIGINT 130,
propagates without a replacement attempt; later input remains ineligible. The
adapter's other signal/storage/partial-record limits remain unchanged.

Successful menu coordinates, the two approach/target moves, one click and
0.3/0.3/1-second waits remain unchanged. Successful resize retains its three-pixel
inset, preparation move, eleven held points, final release and
0.5/0.2/ten-times-0.15/1-second waits. After strict transport failure it stops all
input, including a best-effort release. A failed held point may already have
reached the guest. K57 must retain that uncertainty and contain the exact clone;
it must not send an unrecorded release, clear the latch or bypass an orphan-held
writer lock. The unset lane retains the older release behavior for its consumers.

A signal can also end the scenario during a settling sleep between clean
attempts. A clean `resize-down-N` receipt without a later clean
`resize-release` receipt means held input, even when every recorded attempt is
clean and no latch exists. A failed, interrupted, missing or partial held-point
completion can also mean delivered input; a failed or partial release is no
proof of release. K66's signal handling and k57's containment must inspect the
ordered requests and completions, not only the latch or failed receipts. K66
must control a signal during a held-point attempt and a signal in the settling
sleep after a clean held point. Both controls must retain interruption and the
held-input state, stop later scenario input and show no release attempt. K57
must contain the exact clone through the same writer domain in either case.

## K68 review integration

K69 grades the findings at k68's review commit `bfa2342d` against the current
source. P3-1 is a real retention issue: the latency and installation verifiers
source the common library, which loads both physical helpers and their two
facades. Both unconditional subject lists now include
`vm-physical-evidence-lib.sh`, `vm-guest-exec-lib.sh` and the previously omitted
`vm-window-resize-lib.sh`. These verifiers call no physical facade function;
loading the shell adapter only defines functions, so it does not read the Python
backend. That backend remains outside these two lists for this reason. This
fix covers the named omissions, not a complete audit of the older verifiers.

H-1 is a real handoff gap. The receipt rule and k66 controls above now cover
held input after a signal between clean attempts as well as failed transport.
The k57 task carries the same rule, and k66 carries both signal controls. This
integration adds no signal implementation or runtime qualification.

The [integration evidence](ordering-physical-evidence/k69/verification.txt)
retains the syntax/shellcheck Taskfile result, bounded source checks and their
limits. [Pre-edit digests](ordering-physical-evidence/k69/pre-edit.sha256)
identify the repaired subjects. Verification digests taken
[before](ordering-physical-evidence/k69/before.sha256) and
[after](ordering-physical-evidence/k69/after.sha256) the checks identify the
finished subjects and sourced lint dependencies. The same subjects must remain
unchanged during verification. The documentation Taskfile check still fails on
the two missing archive targets in `context-initial-inputs/CONTEXT-PLAN.md`.
The charter bytes and target absence are identical at parent `bfa2342d`; the
existing live settings-archive-links-k23 leaf already owns that packaging gap.
The initial verification is retained under `k69/initial-verification`; the
final verification follows this disclosure. K66/k67/k62/k57/k54 remain open
and whole-harness review still precedes runtime. No guest, signed subject or
acceptance follows.

## Reachable scenario inventory and remaining migration

This is a bounded static call-site inventory of the complete
[ordinary scenario](../../../scripts/vm-verify-menu-bar.sh), its sourced
[common helpers](../../../scripts/vm-verify-lib.sh), the consumed
[desktop helpers](../../../scripts/vm-verify-desktop-lib.sh), and the physical
helpers above. Graph startup refused before project/generation or coverage
discovery. Exact source reads supply the inventory; it is not a graph
completeness claim. Every transport-bearing function in that reachable closure
is classified below. Sourced definitions that this scenario does not call are
outside the migration claim.

| Reachable caller/path | Actual payload/effect and required migration owner |
|---|---|
| `start_vm`; `cleanup` via EXIT | Start has `id/platform/base/vnc/agent/spec_path/meta_path`; stop has exact `id` and `stopped:true`. K66 must record lifecycle submission, guard complete startup/config identity and preserve separate cleanup; k57 must bind the explicit golden, contain uncertain creation and retain independent full inventory. |
| `start_vm` background keepalive; `fail`; scenario captures | Capture has `path/width/height`, plus a readable complete PNG artifact at the requested unique path. K66 must migrate all captures, including background work, without bypassing the shared single-writer domain, ignoring failures or overwriting required evidence. K57 owns untouched failure collection/order and exact containment. |
| `install_app`; scenario enrollment-script upload | Upload has exact `local/remote` and byte count. K66 must check each expected file/artifact and installation/permission/signature outcome; a successful receipt alone is no installed inventory. |
| `guest`, `guest_text`, `guest_once`; `guest_json` via `enrol` | Exec requires exact command, CLI zero, `ok:true`, `timed_out:false`, guest integer zero, string streams and a command-specific complete stdout predicate. K66 replaces retries, stripped text and discarded completion on every reachable use; no later read rehabilitates submission. |
| `record_installed_bundle` before/after | Exec stdout contains the sorted full regular-file/link inventory and terminal marker. K66 must preserve raw attempts and exact marker, compare each item, and attempt final collection after early failure. K57 independently audits host/original/installed/golden inventories. |
| `await_koine`, first launch, silent launch, running reopen; login endpoint loop | Launch is one `open`; endpoint/process/executable/start identity supplies confirmation. Successful absence must be data in a complete exec response, not guest test failure. K66 retains 15-by-2 and login 24-by-5 bounds; k67 applies same-process/title/front outcomes on every return. |
| Optional trace defaults write; required diagnostic-default reads | K66 must enforce diagnostics disabled for ordering and exact effective key/value/absence readback. No enabling diagnostic write is admitted to these sets. |
| `expect_stopped`; TextEdit quit; boot/restart loop; final port read/refusal | K66 must preserve clean one-shot quit/restart completion plus process/descriptor absence, TextEdit absence, changed boot and old-port curl code 7 as successful payload data. Keep the existing fixed waits and 60-by-5 reboot bound; remove failed-transport retries, including the final curl transport loop. Restart disconnect remains unavailable even after boot changes. |
| `grant_system_events_automation` | Exec trigger, OCR `query/engine/detections/returned/total/truncated`, one Allow click and complete System Events confirmation. K66 supplies actual complete predicates; typed CLI errors are unavailable, never negative polls. |
| `sysevents` via menu item count/label, `await_menu_item_label`, `open_menu`, `menu_titles`, `read_menu`, `choose_menu_item`, Dock/background/front reads | Exact scalar/list/frame answers must be complete successful exec payloads; missing values are not negative facts. K66 migrates reads and Escape, preserves existing label/frame bounds and waits; k67 adds enabled-item, closed-menu, route screenshots and setup/menu oracles. |
| Scenario `frame`, title/default-frame assertions, TextEdit window/move/close/focus calls; common `koine_windows`, `await_windows`, `front_windows`, `koine_in_front`, `read_frame` | `agent windows` returns the full `windows` array; window actions return matching `action`, `success:true`, optional message. K66 migrates actual schemas and clean negative lists, preserving TextEdit 15-by-2 and Koine 10-by-2 bounds. K67 retains original count/front lists, title audits and untouched process-loss discrimination. |
| `snapshot`, `element`, `value_of`, `on_screen`, `click`, `reveal`, `reveal_click`, `scroll_by`, `calibrate_window_scroll` | Snapshot returns `windows` with element trees; required consumed element attributes must be present. Successful lists express negative state; inspect/wait typed errors must not. Scroll reports `x/y/dx/dy`. K66 migrates each actual predicate, preserves reveal/calibration bounds and every later scrolling assertion. |
| Scenario shortcut typing/keys; `grant_accessibility` typing/keys/one Settings launch and its element loop | Type reports exact text and character count; key reports key and modifier array. K66 supplies strict receipts and downstream field/window/permission confirmations, preserving existing inputs, waits and pane bound. |
| `enrol` | Guest client emits one `{case,status,response}` object, with the existing HTTP/GraphQL assertion. K66 checks the whole expected enrollment response under strict exec, without `guest_json` stripping or accepting failed completion. |
| `click_at`, `click_centre` via menu helpers | Migrated here when a root is explicitly supplied. K66 must select the root before these calls; k67 still owes complete route/selection/setup evidence. |
| `drag_window_corner` via complete ordinary resize | Migrated here when a root is explicitly supplied. Actual minimum size/content/scroll acceptance remains a VM duty, with all ordinary guards retained. |

The schema inventory follows the official tagged
[agent](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
[file](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs),
[screen](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs),
[input](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/input.rs)
and [VM](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs)
handlers and the local guest enrollment client. K66 must validate every complete
consumed payload at its actual command site, rather than using this family map
as permission for a generic `ok:true` predicate. K57's new caller must separately
check `vm list --all`'s complete `items/returned/total/truncated` result and exact
stop identity. No existing historical wrapper is substituted for that caller.

## Controls and evidence limits

The [pre-repair control run](ordering-physical-evidence/baseline-red.txt) fails
all thirteen initial helper controls against the legacy paths. Its
[receipt](ordering-physical-evidence/baseline-red.json) identifies the exact
subjects and unchanged before/after digests. The
[decoder controls](ordering-physical-evidence/decode-red.txt) separately fail
after the first implementation: shell substitution/read could accept emitted
geometry from a failed local decoder, or return without latching its failure.
Those failures precede the explicit confirmation guards.

An [empty-root regression](ordering-physical-evidence/empty-root-red.txt) also
fails before the physical facade's root guard. Passing an empty path to the
backend had written refusal/lock artifacts into cwd without dispatching input.
Those generated root files were retained under this evidence directory or
removed (the empty lock); the tests now use an isolated cwd and assert that
empty, absent and existing-but-uninitialized roots leave it untouched.

The initial four checks passed before that guard. Their output remains under
`ordering-physical-evidence/initial-verification`; its receipt omitted the
adapter control's saved `persisted-01/trace-disabled-after.json` input, so it is
not credited as the complete final subject audit. The final run includes that
fixture and follows the guard correction, with all source edits complete first.

The [final verification receipt](ordering-physical-evidence/verification.json)
records the physical, adapter, menu-pointer and resize Taskfile checks, individual
test names/results, output hashes and before/after digests of every listed
subject. The physical controls execute the actual helpers and reviewed backend;
only the external CLI and settling sleeps are controlled. They check raw
completions, pinned argv/VM, coordinates/waits, stage-by-stage failure stops,
payload fields, invalid geometry/roots, sticky eligibility, local decoder
failures and distinct adapter SIGINT. No simulated response establishes actual
guest availability, focus repair, clean restart or native behavior.

K66 still owes the complete scenario's INT/TERM/HUP handling and every other
transport/confirmation. K67 still owes all four positive TextEdit setups,
original-list title audits and same-process versus process-loss outcomes,
including later ordinary returns. K62 must byte-check the resulting shared
prefix through TextEdit quit before resize and reconcile every inherited duty.
Whole-harness review and every earned integration still precede k54 readiness.
All E/A slots remain NOT RUN. Historical subjects/results, failed transports,
strict false joins, closed caps and held causal slots remain unchanged. Native
cause, ownership and acceptance remain unresolved; no release, notarization or
upstream report occurs.
