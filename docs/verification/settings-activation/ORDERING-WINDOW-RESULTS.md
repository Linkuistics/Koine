# Strict window transport expansion

K70 adds independently checked, source-only window list, action and bounded-poll
helpers. K66 decomposes into this expansion and the complete remaining migration
in k71. The ordinary scenario has not adopted these helpers or initialized the
strict evidence root. Independent review and every earned integration precede
consumption; whole-harness review still precedes runtime.

The [physical helper handoff](ORDERING-PHYSICAL-RESULTS.md),
[reviewed shared adapter](ORDERING-NONEXEC-RESULTS.md) and
[ordering protocol](ORDERING-EVALUATION-PLAN.md) remain binding. This increment
changes no ordinary input, assertion, wait, subject or historical evidence. It
starts no VM and supplies no native or product acceptance.

## Interface and command schemas

Source [the library](../../../scripts/vm-window-evidence-lib.sh). Sourcing defines
functions only; it starts no process, transcript or VM. Each call takes an explicit
initialized nonempty root, using the adapter's existing `init_guest_evidence`.
There is no ambient-root or legacy fallback. Empty, absent and uninitialized roots
refuse without writing into cwd or the uninitialized directory. The caller must
retain the nonzero status and stderr; there is no initialized evidence destination
in which to record these invalid-root refusals.

| Helper | Contract |
|---|---|
| `read_guest_windows ROOT CLASS OPERATION` | One `agent windows` read; CLASS is `read-poll` or `evidence`. Emits the entire qualified original JSON envelope. |
| `act_guest_window ROOT OPERATION ACTION WINDOW [X Y]` | One `window-focus`, `window-close` or `window-move`; move takes integer X/Y. Uses class `one-shot`. |
| `await_guest_window_count ROOT OPERATION APP COUNT` | Existing ten reads with two-second waits, count 0 or 1. Counts all windows for APP without adding title/focus criteria. |
| `await_guest_textedit_window ROOT OPERATION` | Existing fifteen reads with two-second waits, at least one TextEdit window. Supplies no positive setup qualification. |

Each dispatch uses the reviewed adapter's same writer lock, ordinal sequence,
pinned exact VM, raw streams, CLI status, strict envelope and payload predicate.
Window reads require the full `windows` array and each entry's string `appName`
and `windowType`, boolean `focused` and finite numeric position/size fields.
Titles may be absent; when present they must be strings. Optional `elements`
must be an array when present; this helper does not consume or qualify element
trees. A valid empty array is a successful negative fact. Missing/malformed
arrays and typed errors remain unavailable.

Actions require the requested `action`, `success:true`, and the actual emitted
`message` field, either null or a string. The CLI does not echo target title or
coordinates in these action receipts. The exact request retains those arguments;
the receipt alone cannot confirm the resulting geometry, focus or closure.
The scenario must perform its named downstream checks. These helpers do not add
any focus operation to a Settings menu selection.

These schemas follow the official immutable `v2.7.0`
[WindowInfo](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/window_info.rs)
and [agent handlers](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
read from local tag objects after their workspace manifest. Online raw-file
retrieval failed. The [source receipt](ordering-window-evidence/official-source.json)
records the tag commit and digests. Code comments carry the decision-site links.
This supplies no installed CLI, endpoint or guest provenance or availability.

## Negative polls and failure retention

Only a clean, complete false count continues a poll. Failed transport, malformed
payload, nonzero CLI and adapter SIGINT return immediately without another read
or settling sleep. The fixed loops preserve the final clean-negative sleep as
well as intermediate waits. The previous TextEdit loop's additional post-loop
assertion read is not inside this helper; k71 must migrate that separate existing
call site too, rather than silently omitting it.

Every read retains its full original bytes in its ordinal's `raw.stdout`, including
clean negatives. A successful poll returns the complete final response, with shell
newline normalization; its exact original remains in the evidence store. No
filtered count/front projection replaces that original. K67 must audit the same
original assertion lists, then distinguish title failure, same-process zero-window
recurrence and process loss. Count success here does not discharge those duties.

Clean exhaustion records a separate `OPERATION-exhausted` confirmation after the
ten or fifteen clean read receipts. Its reason names `clean window poll exhausted`,
the fixed bound and state predicate. The failed confirmation latches eligibility;
it does not reclassify preceding clean negatives as failed transport. K71/k67
must preserve this state failure separately from transport failure and apply the
required untouched liveness/outcome classification. No process read or qualified
Settings recurrence is supplied here.

Malformed helper arguments against an initialized root record failure through
the supported adapter, including under `nounset`. Scenario calls after a latch
cannot dispatch. An explicit evidence-class list may collect context after a
failure; a clean collection receipt does not clear the original failure or permit
input. The shared adapter's partial-record, orphan-lock and storage limits remain.

The library preserves adapter SIGINT as status 130. It does not install scenario
INT/TERM/HUP handlers. An interrupted or failed shell sleep also returns nonzero;
the complete scenario must retain that outcome and stop input. K71 still owes both
held-pointer controls: a signal during a held-point attempt and during its settling
sleep after a clean down. K57 must infer held input from ordered requests and clean
completions, even without a latch, and contain the exact clone through the shared
writer domain. No bare release, reset or lock bypass is authorized.

## Controls and remaining work

The [initial red run](ordering-window-evidence/baseline-red.txt) fails all thirteen
initial controls against test-only legacy list/action routes and the actual legacy
count functions extracted from the common library. This is a bounded comparison,
not execution of the complete ordinary scenario. The failed-poll control shows
that the legacy poll can accept a count from CLI 7. Its
[receipt](ordering-window-evidence/baseline-red.json) identifies unchanged subjects.

The [argument regression](ordering-window-evidence/argument-red.txt) fails after
the initial implementation because missing arguments under `nounset` can exit
without recording a failure against the initialized root. Its
[receipt](ordering-window-evidence/argument-red.json) precedes the argument guards.
All fourteen final controls execute the production library and reviewed backend,
substituting only the external CLI and settling sleeps. They cover original-list
retention, pinned argv/ordinals, both unchanged bounds, clean negatives and
exhaustion, malformed schemas, one-shot actions, first-failure stops, sticky
eligibility, collection, invalid roots/arguments and adapter interruption.

The [verification receipt](ordering-window-evidence/verification.json) identifies
the finished subjects, before/after digests, Taskfile outcomes and individual test
results. It retains the new check and shared adapter/physical checks. These are
headless evidence-handling controls, not guest availability or native behavior.

K71 retains every original k66 duty: migrate all remaining actual callers and
transport families, initialize/adopt the exact root before every scenario command,
confirm one-shot effects, preserve every later ordinary assertion, handle complete
signals and hand untouched collection/containment to k57. K67 still owns positive
TextEdit setup and all title/liveness outcomes. K62 owns exact final-prefix and
whole-duty reconciliation. K57/k54 and every E/A slot remain held until complete
implementation, all earned review/integration and readiness. Historical failures,
strict false joins, closed caps and held causal slots remain unchanged. No native
cause, ownership, repair acceptance, ancestor closure, release or upstream report
follows from this increment.
