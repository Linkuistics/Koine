# Settings scenario adoption review

Review `settings-scenario-adoption-k159` inspected producer
`83175695a0923b3c6498e1b56ecba0069f850599` against its parent `efc6d390` and
the current source. Four findings need integration triage before k67 consumes
the scenario. They concern failed physical waits, required request-label
evidence, private storage and transcript retention.

This is an inspection-only review. No test, build, lint, format or guest command
ran. Production and test code remain unchanged. The cases below follow from
source; none asserts a guest occurrence, a Koine failure or native acceptance.

## P2-1: Conditional physical calls discard failed waits

`scripts/vm-verify-menu-bar.sh:162` and `:167` now call `drag_window_corner` on
the left side of `||`. Bash disables `errexit` throughout a function called in
that context. The helper still has unchecked sleeps at
`scripts/vm-window-resize-lib.sh:25` and `:34`.

Consider a clean `resize-down-2` followed by a settling `sleep 0.15` that exits
143 because that sleep process received TERM. The scenario shell need not have
received TERM itself, so its trap need not run. The helper discards 143,
continues with `resize-down-3`, and can eventually send `resize-release` and
return zero. No failed-wait receipt latches the root. The pre-adoption scenario
called the resize function plainly, so its `set -e` did not have this new
conditional-call suppression.

The menu route has the same problem. `settings_open_menu` and
`settings_choose_menu_item` call `click_centre` conditionally at
`scripts/vm-settings-scenario-lib.sh:388` and `:415`. Its `click_at` callee has
unchecked approach waits at `scripts/vm-menu-pointer-lib.sh:42` and `:44`.
A failed first approach wait can be followed by the target move and click.

This breaks k76's preservation of every nonzero status, k71's explicit local
sleep-status duty and the protocol's unchanged-wait and interruption rules.
It also prevents k57 from learning that held input followed a failed wait.
The repair must retain the failed wait and stop subsequent input, including a
release, without changing the successful action sequence or its delays.

The current controls miss this case. The real-backend signal driver calls
`drag_window_corner` plainly at `Tests/scripts/vm-settings-scenario.bats:271`,
whereas the scenario calls it conditionally. Both sleep fixtures return zero
after signalling the parent. They test the parent's trap, rather than a
nonzero sleep return without that trap. The retained mutation result for a
release-only change is accurately reported as a survivor; it does not close
this separate status-propagation gap.

## P2-2: Required request-label evidence accepts an absent value

At `scripts/vm-verify-menu-bar.sh:230`, the `requests-label` read selects the
`optional` requirement. `scripts/vm-ui-evidence-lib.sh:84` permits either an
object or null in that mode. Its full-tree schema allows an omitted `value`.
The scenario then prints `[.id, .value]` without checking either result.

A complete snapshot can contain the matching request-label ID but omit its
AXValue. That read is clean, and the echo prints `["request-label-1",null]`.
The scenario still captures the screen and sends the denial click. If the
label disappears between the preceding on-screen read and this read, null is
also accepted and printed as `[null,null]`. The earlier read proves no value
on this later observation.

The reviewed snapshot caller table in
`ORDERING-SNAPSHOT-RESULTS.md:140` requires the request-label echo to preserve
its displayed ID/value evidence. The protocol also requires complete
command-specific evidence, and k76 owns adoption of the consumed attributes.
This read therefore needs to qualify the required value on its existing single
snapshot. A missing value is unavailable evidence, not permission to continue.
The simulated backend always gives this label a string value, so its complete
pass cannot challenge the selected requirement.

## P2-3: Root creation does not establish private storage

`scripts/vm-settings-scenario-lib.sh:50` initialises the caller's root and later
prints a privacy warning. It sets no restrictive permissions and checks no
private-parent precondition. `scripts/vm-guest-exec.py:104` creates the directory
with ordinary `mkdir`, and its receipt writers use ordinary file creation.
The entry point and the sourced setup do not establish a restrictive umask.

For example, with umask 022 and a new root beneath a traversable shared
directory, this accepted interface creates a directory readable and searchable
by other local users, and ordinary receipts readable by them. The consent
input at `scripts/vm-settings-scenario-lib.sh:626` then retains an overridden
`KOINE_VM_PASSWORD` in argv, the predicate and the echoed raw response.
Screenshots and refusal records can contain other secret data as well.

The k76 consent handoff and the specification's unique-private-originals rule
require the whole secret-bearing root to remain private. A warning does not
establish that property for the path the scenario creates. Integration must
establish private storage before the first secret-bearing write, or verify a
concrete private-storage precondition. Required originals must remain intact;
redacting their bytes is not a repair. This finding concerns ordinary local
file access, not protection against a deliberately hostile same-user process.

The reused-root control checks refusal before transport. It does not inspect
permissions under a permissive umask or a shared parent.

## P2-4: Transcript setup can overwrite an earlier run before root refusal

`scripts/vm-verify-menu-bar.sh:30` still sources the transcript setup at
`scripts/vm-verify-lib.sh:24-27` before `settings_begin`. That setup chooses a
name with second-level timestamp precision and opens it with plain `tee`.
It does not reserve the file exclusively. The exclusive installed-inventory
and content writes added in this change do not cover the transcript.

Two invocations that start within the same timestamp second choose the same
log. The second `tee` truncates the first transcript. With the default root,
the later initialisation can then refuse the existing root, after the loss
has already happened. Explicitly distinct evidence roots still leave both
invocations writing the same transcript name. This is a local output-retention
case; no repeated guest input or new runtime attempt is authorised here.

This breaks the protocol's unique-output and original-retention duties and
the adopted scenario's stated preservation of every file. Root reuse must not
destroy the evidence that made the root ineligible. The existing-root test
asserts only nonzero status and no transport, so it can pass after that loss.
The scenario needs an exclusive transcript identity before opening the file,
with a control that verifies the earlier bytes survive refusal.

## Disposition of the seven review doubts

| Doubt | Inspection result |
|---|---|
| Transport bypass before the root or after the end | No additional bypass found in the inspected reachable source. Sourcing performs local setup, but no guest transport precedes `settings_begin`. It removes the legacy EXIT cleanup before initialisation. Reached transports use the strict facades; the report reads host receipts and sends no stop. P2-4 concerns local setup's retention effect. This is a bounded source conclusion, not a general dynamic-shell proof. |
| Actions, counts, waits, bounds and messages | Line-by-line comparison with `ordering-scenario-evidence/scenario-before.sh` retains the ordinary assertions and successful action sequence, subject to P2-1 and P2-2. The added defaults/identity/lifecycle reads follow the reviewed handoffs. The removed failure-path front-list reread and the port loop's first-clean-read rule are declared departures. The TextEdit helper replaces the whole loop and retains its final assertion read. |
| Koine, test-driver and NOT RUN outcomes | No additional classification defect found in the normal inspected paths. Clean false local states, exhausted polls and unavailable transports remain distinguishable in request/result fields. Restart failure is explicitly a driver/guest outcome. P2-1 can erase an interruption before those records exist. Missing receipts alone establish no product failure. The finite caller still owes explicit phase/slot NOT RUN accounting. |
| INT, TERM and HUP, including substitutions and writer contention | The parent traps exit without a release and use the shared failure-recording path. The backend refuses and latches lock contention, retaining a refusal instead of inventing an ordinal. Redirected output uses saved descriptors. No separate trap defect was derived, but P2-1 defeats the broader local-status obligation. The retained fixtures do not establish all Bash 3.2 signal/subshell or orphan-holder histories; this review executes none. |
| Input after a signal or latch; held state | The inspected explicit trap and backend-latch paths stop later physical input. The held-state report conservatively preserves failed/partial downs and releases. P2-1 allows later input after a child sleep's interruption without a shell trap or latch. k57 still must resolve owned holders through the same domain before exact stop. |
| Controls that could pass despite a defect | The complete fake run does model actions, and fault controls require that the named call occurred. The caller regex has positive and injected controls but is a finite static pattern list. P2-1, P2-2, P2-3 and P2-4 name specific untested cases. The two real-backend held-pointer cases are historical evidence for their stated fixtures only. |
| Exclusive writes, work directory and privacy | Inventory/content copies use exclusive writes; `WORK` is retained for the finite caller. P2-3 and P2-4 remain. The keepalive resource profile is withdrawn by the ADR, so this review adds no replacement profile or capacity reservation. |

## Evidence and limits

The recorded `green-subjects-before.sha256` and
`green-subjects-after.sha256` are byte-identical. All thirteen named files match
their recorded SHA-256 values in the reviewed tree. The retained `green.txt`
has SHA-256 `c694162b5c2143756aaa6acae9810fc6dc2ca207848d853cee6cf85de87bf0be`.
These are fresh file comparisons with earlier run evidence, not fresh passing
tests.

Those manifests cover a subset of the run's inputs. For example, the retained
log directly runs `vm-menu-pointer-lib.sh`, `vm-ui-evidence-lib.sh` and
`vm-capture-evidence-lib.sh`, and their Bats suites, but the manifests omit
those files. They cannot establish that every consumed input stayed unchanged
during the earlier run. Preserve the original logs and qualify their provenance;
integration's verification must identify its complete actual subjects.

Tier 2 discovery used graph project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, generation
`2026-11-21T17:18:47Z`. Coverage checks reported partial shell parses and
untracked Bats metadata. Direct source reads covered the relied-on files and
reported ranges, including strict-layer lines 192 and 298. Some graph call
edges resolved shell builtins to unrelated repository symbols; those edges
were not credited. No exhaustive graph-completeness claim follows.

The missing-tree, omitted-AXValue, selector and OCR availability limits remain.
The restart timing and native cause remain unknown. k67 retains positive
setup/title/liveness; k62 retains the exact prefix and complete duty
comparison; k57 retains the finite caller, collection, audits, containment and
NOT RUN accounting; k54 retains readiness, freeze and runtime. Integration
belongs immediately before k67. This review changes no runtime authority,
closed cap, candidate, historical result or ancestor acceptance.
