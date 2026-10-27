# Declared k4 menu-bar sample — 2026-10-28

This protocol is fixed before the first started attempt. Results belong in
README.md and the main verification record, not in this protocol.

## Subjects and conditions

Use the released, unchanged arm64 Koine bundles downloaded from GitHub:

| Version | Archive SHA-256 | Main executable CDHash |
|---|---|---|
| 0.3.0 | `b6b6f085cd8ff7da61bf5616e07d54714511039f85cfea7085010bc34e930200` | `7703a40869b728450dd84a164bbbb7f803deb3bc` |
| 0.4.0 | `e1cd1481195e41a042a49cc2131d35fb12e34c0655c3e78375a965f7438af4e8` | `160b0f0b39a0541f99b8d656a5c87dc3bad9ef5c` |

Release metadata, host signature descriptions and per-file inventories accompany
this protocol. Extracted inputs live under `.build/menu-samples/releases/<version>/`.
No application repair, rebuild or new release is involved. The guest installation
repackages the selected extracted bundle through the existing ditto route.
It sets no quarantine attribute and gives no Gatekeeper first-launch acceptance.

Each attempt uses a separate clone of `testanyware-golden-macos-27`, expected
macOS 27.0.1 build 26A434, arm64, four CPUs and 4 GiB memory. The initial display
is explicitly 1920×1080 at 1×. Restart is expected to restore the golden's
1024×768 display; retain the actual post-run display and pointer geometry.
The golden config, disk and NVRAM have pre/post SHA-256 inventories. All guests
start from the same stopped golden. No simultaneous sample guests run.

TestAnyware CLI, app and bundle are 2.7.0; Tart is 2.41.1. Doctor reports working
prerequisites apart from the existing disabled TestAnyware host login item.
That host setting remains unchanged. Retain each guest's actual OS/build and
Gatekeeper status. Abort the comparison on a mismatched environment or subject.

## Order, cap and stopping rule

| Attempt | Bundle | Clone |
|---|---|---|
| 01 | 0.3.0 | `koine-k4-01` |
| 02 | 0.4.0 | `koine-k4-02` |
| 03 | 0.4.0 | `koine-k4-03` |
| 04 | 0.3.0 | `koine-k4-04` |

Run sequentially in this order, one full-scenario invocation per attempt, no
scenario retry. Four started attempts is the absolute cap, including setup
failure or interruption. Stop sooner if a finding requires a script, input or
application repair, if the frozen subjects change, or if the environment cannot
be matched. An unexplained activation failure is retained and does not itself
require an invented repair. Never enlarge the sample to chase that failure or
replace a failed run. A future repaired instrument starts a separate measurement.

## Procedure and evidence

Before sampling, run `task check:vm-menu-pointer` and
`task check:vm-window-resize` through mise, plus `task check:vm-menu-sample`.
Capture mise's selected PATH in tool-path.txt and resolve the invoked host tools
under that exact PATH in tool-resolution.txt. The wrapper restores that PATH for
itself and passes it explicitly through mise to the nested Task process; the
inventory resolves and hashes those executables, rather than guessing paths.
Freeze `subjects-before.sha256`
with `inventory.sh` and `links-before.txt` with `links.sh`. The inventory covers
both archives and every extracted regular file, the unchanged full scenario,
all sourced helpers (including signing environment, desktop, pointer and resize),
both uploaded client fixtures, Taskfile, App/Info.plist, this protocol, wrappers,
qualified observer source/binary and the selected host executables. The symlink
inventory preserves paths and targets separately. Hash the golden's three files
before and after the whole sample. Do not edit any measured input while a run is
active. Check every item's hash and re-enumerate after each attempt.

Invoke each attempt once from the repository root, for example:

```sh
mise exec -- task app:vm-sample-menu-bar -- 01 0.3.0
```

The wrapper creates `.build/menu-samples/results/01` exclusively, executes
`task app:vm-verify-menu-bar` with the selected release and keeps its guest.
The task records the actual scenario exit independently of Task's mapped exit.
After a failed scenario, upload the qualified k7 observer, explicitly set its
executable permission and run it once in a fresh process. Retain its full exec
envelope, native active application and CoreGraphics order, agent window list,
original failure screenshot and fresh screen/menu state. Do this before any key,
window focus, repeated menu action or application launch. Read-only observations
are sequential and delayed, not an atomic pre/post trace. No native pre-action
snapshot is added to the unchanged scenario; if the cause needs that observation,
say so explicitly. A failed observer or timeout supplies no negative evidence.

Retain all newly created scenario artifacts, wrapper transcript, actual exits,
timestamps, endpoint inventories, display and guest observations. Explicitly stop
each clone even after failure; verify VM/Tart inventory after collection. The
wrapper's EXIT trap attempts cleanup on error or interruption. Post-run subject
checks aggregate errors only after retaining regular-file and symlink after
inventories and diffs; audit.exit is separate from the scenario and task exits.
Missing terminal
records must be classified as interrupted or incomplete, never a pass.

## Coverage and interpretation

Classify every attempt against all scenario phases: first launch; TextEdit/menu
state; initial Settings action and three reopens; growth/minimum content and
scroll reachability; shortcuts; two requests and no automatic window; Requests
and Accessibility navigation; consent; login enable/Quit/silent manual launch;
running-application reopen; Command-Q/restart; silent login launch; final Quit
and old-port refusal; installed endpoint equality. Mark a partially reached phase
as incomplete/failed and every later unexecuted assertion NOT RUN. A full pass
requires actual resize and all following assertions to run. Compare each
available installed inventory with the selected host bundle, not only its other
endpoint; an early failure may have no installed after read.

This is a finite diagnostic sample of two released bundles under matched current
conditions. Do not pool it with historical runs, the k10 complete pass or the
focused resize trials. It cannot establish a population reliability rate, a
release regression, continuous runtime bundle immutability or an activation
cause. The historical activation failure remains unresolved unless specific
causal evidence and a verified repair are obtained. Preserve k3's corroborated
Settings reopen 3 failure and its unrun assertions regardless of this outcome.
