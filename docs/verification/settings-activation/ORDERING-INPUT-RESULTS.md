# Keyboard, text and scroll transport migration

K74 migrates the ordinary scenario's existing keyboard/text/scroll callers to an
explicit-root facade. Its headless controls pass through the real shared adapter,
writer lock, ordinal store and jq. The complete scenario has not initialized or
adopted that root throughout. Independent review and every earned integration
precede the next migration batch; whole-harness review still precedes runtime.

The [ordering protocol](ORDERING-EVALUATION-PLAN.md),
[shared adapter](ORDERING-NONEXEC-RESULTS.md),
[physical handoff](ORDERING-PHYSICAL-RESULTS.md) and
[window handoff](ORDERING-WINDOW-RESULTS.md) remain binding. No VM, signed subject,
freeze, native repair acceptance or ancestor closure follows from these controls.

## Interface and actual callers

Source [the input facade](../../../scripts/vm-input-evidence-lib.sh). Sourcing
only defines functions and loads the existing source-only adapter. It starts no
process, transcript or VM. `scenario_input OPERATION ACTION ARGS...` preserves
the existing CLI arguments after the new operation name, which identifies the
attempt in its receipt.

When `KOINE_VM_EVIDENCE_ROOT` is set, it must name an initialized nonempty root
created by `init_guest_evidence`. Explicitly empty, missing or uninitialized
roots refuse with status 125 before dispatch and create no cwd artifacts. The
caller retains their diagnostic/status; there is no initialized destination for
an ordinal refusal. A valid root uses `cli_guest_evidence` with class `one-shot`,
the pinned VM and the shared eligibility check under its writer lock. No failure
selects the legacy route. Unset retains the existing bare input route for other
VM consumers during migration, including its original nonzero status.

| Call shape after OPERATION | Required actual payload |
|---|---|
| `key KEY` | Exact `key`, with `modifiers:[]`. |
| `key KEY --modifiers CSV` | Exact `key` and ordered comma-split modifier array. |
| `type TEXT` | Exact `text` and its Unicode scalar count in `chars`, including empty text. |
| `scroll X Y --dy=N` | Exact numeric `x/y`, `dx:0`, and requested signed `dy`. |

These predicates supplement the shared strict envelope and clean CLI status;
none is constant true. Invalid shapes latch a confirmation failure before CLI
input. Coordinates must be canonical decimal integers from 0 through 65535 and
the delta a canonical signed i32. Keys must be nonempty. Leading-hyphen keys/text
are refused to avoid interpreting payload as CLI options; current callers need
none. Modifier lists cannot contain empty entries. The facade accepts no extra
CLI options or endpoint overrides. A payload receipt confirms submission and its
reported fields; it does not confirm the downstream UI effect.

The immutable official v2.7.0 [input handlers](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/input.rs)
and [argument declarations](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/main.rs)
were read from local tag objects after the workspace manifest. Source citations
sit at the code decisions. The [source receipt](ordering-input-evidence/official-source.json)
records the tag commit and digests. This identifies inspected source, not an
installed CLI, parser execution, endpoint provenance or guest availability.

The [bounded caller inventory](ordering-input-evidence/input-callers.json)
enumerates every direct input action and new facade call in the complete
scenario and its common/desktop helper surfaces, then classifies each candidate.
Imported pointer/resize paths retain their separate physical inventory.

| Migrated caller | Preserved action/order/waits |
|---|---|
| Complete scenario shortcut phase | Type `shortcut`; Cmd-A/C/X, one-second wait, Cmd-V, one-second wait, Cmd-A/X/W. Existing field and window assertions remain. |
| Complete scenario pre-restart Quit | One Cmd-Q before the existing stopped/restart checks. |
| `scroll_by`, through calibration/reveal/reveal-click/click | Same window-centre coordinates, requested dy and one-second sleep. Calibration/reveal bounds remain unchanged. |
| `read_menu`, through `expect_menu` | Same Escape after reading titles, followed by its existing one-second sleep. |
| `grant_accessibility` | Same password type/Return, Cmd-Shift-G, bundle path type, two Returns and Cmd-Q, at their existing waits. |

Migrated input calls return immediately on every nonzero result. Their caller
chains explicitly propagate scroll/menu failures even when shell conditionals
suppress `errexit`; no settling sleep or later action in those tested chains
follows the failed input. The scenario's direct inputs exit with the returned
status. Existing assertions and successful inputs/waits are retained.

Unused shared definitions (`create_grant`, `revoke_accessibility`, `quit_koine`
and `quit_koine_or_terminate`) keep their legacy calls. They are outside this
scenario's reachable input migration; the inventory exposes them. Bare element
and Automation clicks, snapshots, execs, capture, lifecycle and collection remain
later work. This is no claim that the complete scenario stops every possible
input on failure yet.

## Controls and provenance

The [first baseline](ordering-input-evidence/baseline-red.json) runs the initial
controls against test-only bare input routes and original callers before
implementation. It has a setup defect in its argument test: that test sourced
the not-yet-created facade. Its output and receipt remain historical; that failure
is not argument-guard evidence. The [corrected baseline](ordering-input-evidence/baseline-final-red.json)
exports the test-only bare route into the nounset subprocess instead. Both
baselines used an earlier Bats revision.

The [final-control baseline](ordering-input-evidence/final-control-baseline-red.json)
runs the final formatted Bats controls in an isolated copy with original caller
functions from parent `00320226` and a test-only bare `scenario_input`. Each
strict control fails; the unchanged legacy-lane control passes. A loop's first
failed assertion stops that control, so this does not claim every nested invalid
fixture independently failed on the baseline. Source/fixture digests before and
after match. No complete scenario, guest or native response is simulated.

The passing controls cover exact argv and original bytes, modifier order,
Unicode text/scalar count, empty text, signed scrolls, incomplete/mismatching
payloads, nonzero/partial/typed-error/dry-run completions, invalid roots/arguments,
shared sticky failure, adapter SIGINT and unchanged legacy argv/status. They
execute the real adapter and receipt store, substituting only the external CLI
and fixed settling sleeps. Caller-chain controls extract actual functions
without VM startup side effects and substitute preceding read-only/UI setup
boundaries; they prove early return from those input failures, not correctness
of the substituted reads or a full consent workflow.

SIGINT controls establish adapter status 130, retained interruption and refusal
of later input. They do not install complete shell INT/TERM/HUP handling or
prove the two held-pointer interruption cases. K76 still owes those controls,
ordered receipt/held-state retention and untouched handoff to k57.

The bounded inventory's controls find legitimate legacy calls in the shared
helper surface and detect a deliberately restored bare input in a scratch copy
of the changed primary scenario. They check that this particular source scan
works; the inventory makes no dynamic-shell or graph completeness claim. Tier 2
coverage was checked; partial shell parse ranges and unavailable Bats metadata
were handled by direct source reads.

The [verification receipt](ordering-input-evidence/verification.json) records
Taskfile commands, complete outputs/statuses, individual test names/results and
before/after subject digests. Its inventory includes the retained saved timeout
fixture consumed by the adapter controls. The documentation check retains the
existing archive-link failures owned by k23 rather than claiming a clean result.
Run `mise exec -- task check:vm-input-evidence` for this bounded seam.

## Remaining original duties

K71 decomposes into this input migration, k75's remaining UI/artifact/exec/
lifecycle confirmation paths and k76's complete scenario adoption/signals. K75
still owes actual snapshot/element/OCR/click schemas, screenshots and background
keepalive, upload/install/artifact checks, diagnostics/default exact values and
absence, endpoint/process launch identity, silent launch/running reopen, clean
TextEdit quit plus absence and clean restart plus changed boot. Failed submission
stays failed. Demonstrated clean-completion infeasibility holds before E01 for
a new decision without launching a qualifying guest.

K76 must initialize/select the exact root before every transport, consume the
reviewed window helpers and replace the entire TextEdit loop plus unconditional
final assertion once, without another read. It retains structured state-failed
versus unavailable/interrupted outcomes and every nonzero local status. Full
INT/TERM/HUP handling includes both the held-point attempt and the settling sleep
after clean down: no subsequent release/input; clean down without a later clean
release still means held input, and failed/partial release proves no release.
Hand ordered receipts, partials and uncertainty to k57 for collection/exact
containment through the same writer domain, including orphan-lock refusal,
without reset, bypass or bare release.

K67 still owns all positive TextEdit/PID/Untitled/geometry/dialog/sheet/menu
setups, screenshots, original-list title audits and same-process zero-window
versus process-loss outcomes, including later returns. K62 retains exact final
prefix correspondence through TextEdit quit before resize and every inherited
duty. K57 owns the finite caller/collection/containment; k54 owns final readiness
and runtime. Every earned review/integration and whole-harness review precede
runtime. All E/A slots and held causal slots remain unconsumed. Historical
subjects/results, failed transports, strict false joins and closed caps stay
unchanged; native cause, ownership and repair acceptance remain unresolved.
