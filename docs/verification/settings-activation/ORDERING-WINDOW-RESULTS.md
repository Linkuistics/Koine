# Strict window transport expansion

K70 adds source-only window list, action and bounded-poll helpers. K72 reviews
producer commit `846e0d91`; k73 integrates that review below. K66 still owns the
complete migration in k71. The ordinary scenario has not adopted these helpers
or initialized the strict root. Whole-harness review still precedes runtime.

The [physical handoff](ORDERING-PHYSICAL-RESULTS.md),
[shared adapter](ORDERING-NONEXEC-RESULTS.md) and
[ordering protocol](ORDERING-EVALUATION-PLAN.md) remain binding. These repairs
preserve the ordinary inputs, assertions, waits and poll bounds. No VM, signed
subject, freeze, native acceptance or ancestor closure follows.

## Interface and command schemas

Source [the library](../../../scripts/vm-window-evidence-lib.sh). Sourcing defines
functions only. Each call takes an explicit initialized nonempty root, created by
`init_guest_evidence`. Empty, absent and uninitialized roots refuse without CLI
input or cwd artifacts. The caller retains their nonzero status and stderr;
there is no initialized destination in which to record an invalid-root refusal.

| Helper | Contract |
|---|---|
| `read_guest_windows ROOT CLASS OPERATION` | One `agent windows` read; CLASS is `read-poll` or `evidence`. Emits the complete qualified original envelope. |
| `act_guest_window ROOT OPERATION ACTION WINDOW [X Y]` | One `window-focus`, `window-close` or `window-move`, using class `one-shot`. Move accepts integer X/Y through `--x=VALUE` and `--y=VALUE`, including negatives. |
| `await_guest_window_count ROOT OPERATION APP COUNT` | Existing ten reads with two-second sleeps after each negative, including the tenth. COUNT is 0 or 1. Counts all APP windows without adding title/focus criteria. |
| `await_guest_textedit_window ROOT OPERATION` | Existing loop of up to fifteen reads, sleeping two seconds after each negative, then the existing unconditional final assertion read. This final read occurs even after an early positive. At exhaustion: sixteen reads and fifteen sleeps. Supplies no positive setup qualification. |

Every dispatch uses the shared writer lock, ordinal sequence, pinned exact VM,
raw streams, CLI status, strict envelope and command-specific payload predicate.
Window reads require the complete `windows` array and each entry's string
`appName` and `windowType`, boolean `focused` and finite numeric geometry.
`title` may be absent; when present it must be a string. Optional `elements`
must be an array; this helper does not qualify element trees. A valid empty array
is clean negative data. Missing/malformed fields and typed errors are unavailable.

Actions require the requested `action`, `success:true`, and the actual `message`
field, null or string. The CLI does not echo the target title or coordinates.
Requests retain those arguments; the receipt alone does not confirm geometry,
focus or closure. The scenario still owes each downstream check. No focus
operation is added to a Settings selection.

These schemas follow official immutable v2.7.0
[WindowInfo](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/window_info.rs)
and [agent handlers](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
read from local tag objects after the workspace manifest. The original
[source receipt](ordering-window-evidence/official-source.json) remains unchanged.
K73 rechecks those digests and reads the tagged move declarations and pinned
clap source; its [source receipt](ordering-window-evidence/k73/official-source.json)
records these inputs. Equals-form values avoid interpreting a negative coordinate
as a short option. Controls inspect emitted argv; they do not execute the real
CLI parser, an endpoint or a guest.

## Poll decisions and failure retention

Only a clean complete false state continues a poll. Failed transport, malformed
payload, nonzero CLI and adapter interruption stop before another read or sleep.
The TextEdit helper now owns the whole legacy preparation block, including the
post-loop assertion; k71 must replace that block once and must not add a duplicate
assertion read. Koine's ten-read bound stays unchanged.

Every read retains exact original bytes in its ordinal's `raw.stdout`. A successful
poll emits its final assertion's complete response, subject to shell newline
normalization; exact bytes stay in the store. No projection replaces that list.
K67 must audit the original assertion lists and distinguish title failure,
same-process zero-window recurrence and process loss. A count success alone
supplies none of those outcomes.

The source-only facade adds
`record_guest_poll ROOT OPERATION PHASE STATUS PREDICATE`. This records a local
step through the same backend, lock, ordinals, atomic receipts and sticky latch.
It submits no CLI and fabricates no raw transport streams. A state evaluation
gets its own receipt immediately after its list; the helper records failed
sleeps and terminal exhaustion through the same interface. Successful sleeps
retain the existing timing and allocate no receipt.

| Local receipt | Request fields | Result and return |
|---|---|---|
| True or false state | `transport:"poll-step"`, `poll_phase:"state"`, exact `state_predicate`, `local_status` 0 or 1 | `outcome:"clean"`, return 0 from recording. The shell uses the retained state status to continue or finish. |
| Clean exhaustion | `transport:"poll-step"`, `poll_phase:"exhausted"`, exact predicate, `local_status:1` | `outcome:"state-failed"`, return 125 and latch. |
| Failed local evaluation or sleep | `poll_phase:"state"` with status other than 0/1, or `poll_phase:"sleep"` with nonzero status | `outcome:"unavailable"`, return 125 and latch, except signal statuses below. |
| Interrupted local evaluation or sleep | Same phase, shell signal status 129–192 retained as `local_status` | `outcome:"interrupted"`, same shell status returned and latch. |

Requests retain operation, VM, ordinal and times as usual; local steps use class
`evidence`, empty argv and no CLI status. That class permits recording failure
context after a latch, never clearing it. A later clean local record cannot
restore scenario eligibility. Prior `state-failed` receipts also latch during
eligibility inspection. Invalid phase/status/predicate arguments refuse and latch
an identifiable initialized root.

Classifiers must inspect both request and result. Exhaustion is identified by
`transport:"poll-step"`, `poll_phase:"exhausted"`, `local_status:1` and terminal
`outcome:"state-failed"`; operation suffixes and reason text are not classifiers.
A failed predicate cannot produce that combination. State failure stops input
just as unavailable evidence does, while retaining a distinct measured outcome.
It is not by itself a qualified Settings recurrence: k67 still owes untouched
liveness, setup, title and screenshot evidence under the protocol.

Malformed public helper arguments latch through the adapter, including under
`nounset`. Scenario reads/actions after a latch cannot dispatch. Evidence-class
window collection can retain context but cannot clear the original failure.
Partial receipts, storage failure and orphan-held locks retain the shared
adapter's limits. The existing orphan-lock control also checks poll-step refusal.

Local signal controls exercise statuses 130, 143 and 129 from the evaluation
and sleep boundaries. They establish the helper's recording/propagation, not
complete shell signal handling. K71 still owes INT/TERM/HUP handlers and both
held-pointer cases: a signal during a held-point attempt and during the settling
sleep after clean down. A signal killing the shell before recording can still
leave a partial or absent local receipt; the caller must retain interruption
and stop input. K57 infers held input from ordered clean down/release receipts
and delivery uncertainty, then contains the exact clone through the same writer
domain. No bare release, reset or lock bypass is authorized.

## K72 findings and dispositions

Each finding is verified against review commit `142b72b6`, the legacy scenario,
the reviewed protocol and the tagged sources. All six are actionable within their
stated limits; none establishes a native product defect.

| Finding | Classification and disposition |
|---|---|
| P2-1, premature TextEdit exhaustion | Real. The helper now includes the unconditional final read, including after early success and after the fifteenth sleep. Controls cover a window first appearing on read sixteen, final clean absence, and failed final transport. K71 replaces the whole legacy block. |
| P3-1, state/evidence ambiguity | Real. Per-state receipts retain predicates and decisions. Exhaustion has structured phase and `state-failed` outcome; evaluation and transport errors remain unavailable/interrupted. Operation names do not determine classification. |
| P3-2, unrecorded local failures | Real. Failed sleeps and erroneous/interrupted state evaluations now record their phase/status, latch and stop without another read or input. Complete shell interruption remains k71's duty. |
| P3-3, negative move coordinates | Real interface defect, though current scenario destinations are positive. Emit equals-form values and check positive and negative argv. No guest/parser availability claim follows. |
| P3-4, changed red controls | Real provenance gap, not evidence of a false pass. State explicitly that the original baseline used an earlier control revision. Retain it unchanged and add a final-control baseline with before/after digests and individual results. |

## Controls and provenance

The original [baseline red](ordering-window-evidence/baseline-red.txt) and
[receipt](ordering-window-evidence/baseline-red.json) used an earlier Bats digest.
Its test 7 had an assertion absent from the final k70 controls. The original
[argument regression](ordering-window-evidence/argument-red.txt) ran only test 14.
Those records and the original [verification receipt](ordering-window-evidence/verification.json)
remain historical, unchanged evidence; they do not show all final controls red.

K73 retains a new [behavior red](ordering-window-evidence/k73/behavior-red.json)
against the reviewed production implementation before the repairs. Its per-test
output shows the new behavior checks failing. The intermediate
[green receipt](ordering-window-evidence/k73/behavior-green.json) records all twenty
passing after repair. The [final-control baseline](ordering-window-evidence/k73/final-baseline-red.json)
runs the formatted final Bats file with `KOINE_WINDOW_BASELINE=1`; every control
fails against the test-only legacy list/action routes and extracted legacy Koine
count function. The TextEdit baseline stub is only one legacy list read; it does
not execute the complete legacy TextEdit preparation. The production behavior-red
run supplies the actual pre-repair TextEdit comparison. No complete ordinary
scenario or native product behavior is simulated or qualified by these runs.

Final Taskfile receipts under `ordering-window-evidence/k73/` record syntax,
lint, formatting, types and individual window, shared-adapter and physical-helper
results, with subject digests before/after and output digests. The docs receipt
retains the two pre-existing archive-link failures owned by k23; it does not
claim a clean documentation check. Existing red evidence is included in the
subject hashes and remains unchanged.

K71 retains every original k66 duty: adopt the exact root before each transport,
migrate every remaining actual caller/family, confirm one-shot effects, retain
every later assertion, implement full signals and hand untouched collection and
containment to k57. K67 retains all positive setup/title/liveness outcomes. K62
owns exact prefix correspondence and whole-duty reconciliation. K57/k54 and every
E/A slot remain held until all harness work, reviews/integrations and readiness
complete. Historical failures, strict false joins, closed caps and held causal
slots remain unchanged. No native cause, ownership, repair acceptance, ancestor
closure, release or upstream report follows.
