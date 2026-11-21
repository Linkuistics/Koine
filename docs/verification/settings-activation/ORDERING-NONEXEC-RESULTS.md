# Shared non-exec evidence boundary

K60 extends the strict guest-exec adapter. The new parts are supported
eligibility inspection, failed-confirmation recording and non-exec TestAnyware
attempts. All of them use the same writer lock and ordinal sequence. K63 reviews
this increment independently, and k64 integrates its findings below. All 37
adapter controls pass headlessly.

The whole-harness review stays due after the scenario and caller
implementation. No ordinary caller uses the adapter. No VM, signed candidate,
freeze or native acceptance occurs.

K56 decomposes into three increments. They are the evidence-interface
expansion (k60), the complete scenario and helper migration (k61), and the
exact focused-prefix verification and whole-duty reconciliation (k62). Only the
first increment runs here. K61 keeps every signal, transport, confirmation,
setup, title, liveness, screenshot and later ordinary duty.

K62 extracts the prefix from the changed complete scenario. The prefix ends
with the TextEdit quit, immediately before resize. The finite caller of k57 and
the readiness and runtime of k54 stay held. No parent closes.

## Supported interface

Source [the facade](../../../scripts/vm-guest-exec-lib.sh). Sourcing starts no
process or VM. Initialise an unused directory and an exact VM, as the
[exec report](ORDERING-TRANSPORT-RESULTS.md) describes. These are the new
operations:

```sh
check_guest_evidence "$root"
cli_guest_evidence "$root" one-shot row-click '.x == 10 and .y == 20' -- input click 10 20
fail_guest_evidence "$root" launch-identity 'wrong executable identity'
```

`check_guest_evidence` checks the initialised subject, the prior receipts
and the latch under the shared lock. It returns 0 only while the root is
eligible. It dispatches nothing and allocates no ordinal. It does not reserve
permission for later input. Every later transport must still use a locked
adapter, which checks eligibility again. A bare CLI call after a clean check
would bypass this contract.

`cli_guest_evidence ROOT CLASS OPERATION PREDICATE -- COMMAND SUBCOMMAND ARGS...`
submits once, with no host shell or retry. A clean call emits its exact
original JSON bytes. It flushes them before it publishes its terminal receipt.
It requires CLI zero, one strict JSON object, `schema_version:"1.0"`, `ok:true`
and no `dry_run` field. It also requires a mandatory jq predicate that yields
exactly one true.

These results stay unavailable: duplicate keys, NaN or Infinity, multiple or
partial objects, invalid predicates, empty or multiple results and a zero-exit
`jq halt`.

Non-exec commands share only that base envelope. Pointer input has no exec-style
`timed_out`, `exit_code` or guest-stream fields. The caller must check the
actual complete command-specific payload. The example checks only a pointer
response. Controlled `marker` payloads in tests exercise the validator, not real
upload or screen-size schemas.

K61 must enumerate and check every consumed schema before use, including
explicit clean negative facts. Exit zero alone never qualifies output.

Each k61 call site must supply a predicate on its own complete payload schema,
never a constant `true`. The controls sometimes use `true` to isolate an
adapter guard. Those fixtures qualify no real command schema. Clean negative
polls must use successful list-shaped reads, such as `agent windows`. Their
complete payload can express absence.

TestAnyware's `WINDOW_NOT_FOUND`, `ELEMENT_NOT_FOUND` and `TEXT_NOT_FOUND`
errors return CLI 3 and latch unavailable. In particular, `agent inspect`,
`agent wait` and `screen find-text` cannot use those errors as clean negative
polls. This keeps the strict transport rule. It admits no new tolerated status
or poll bound.

The supported families are agent, input, screen, file upload/download and the
limited lifecycle forms below. Endpoint commands receive the pinned `--vm` and
`--json`. Screenshots must use the
[checked capture interface](ORDERING-CAPTURE-RESULTS.md). The generic CLI
`screen capture` refuses in every class before dispatch. Its unique output path
and complete PNG qualification stay inside the shared lock.

File transfers must use the
[checked transfer interface](ORDERING-FILE-LIFECYCLE-RESULTS.md), which k89
added. The generic CLI `file upload` and `file download` refuse in every class
before dispatch. The checked backend digests the upload input and owns the
download path, under the shared lock.

Caller overrides of the endpoint, the output or live execution refuse before
dispatch and latch failure. Embedded `--` terminators do the same. The initial
`--` of the API only separates its own arguments. Guest exec must use the
stricter `exec_guest_evidence` route.

| Lifecycle form | Binding |
|---|---|
| `vm start OPTIONS...` | Append the pinned `--id` and `--json`. Reject a caller-supplied ID, `--viewer` and `--keep-on-failure`, including the equals forms. K57 must explicitly select and audit `--base`. |
| `vm stop EXACT_ID` | Require the positional ID to equal the initialised VM. Append `--json`. |
| `vm list OPTIONS...` | Append `--json`. The caller must request and check the complete required inventory and the exact stopped identity. |

The base envelope and the argv placement come from the local official `v2.7.0`
tag. The inspected files are its
[output implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/output.rs)
and its [argument declarations](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/main.rs),
read after its workspace manifest. The internal Cargo version is 0.0.1. The
release tag identifies the inspected source.

Online raw-file retrieval was unavailable, so this work did not use the
mutable checkout as release evidence. The final receipt records the tagged source digests. Code
comments cite the official decision sites.

`fail_guest_evidence ROOT OPERATION REASON` records a failed downstream or
artifact check as the next ordinal. The record has transport `confirmation`,
class `evidence`, an empty argv, no CLI status and an unavailable result. A
successfully recorded failure returns 125. It stays callable during collection
and keeps the first latch reason. It does not perform or retry the check.

K61 must stop after a failed check and record it here. It must also stop on
every nonzero adapter return. A failure to record never permits input. Scenario
callers must not edit latch files directly.

## Records and limits

Exec and CLI share ordinals, raw streams, exact argv, VM, class, operation and
predicate. They also share times, CLI exit, validator streams, atomic receipts
and the first-failure latch. CLI requests use `transport:"cli"`. Their guest-shell
`command` field is empty, and argv is the complete command. Confirmation events
keep their reason and fabricate no transport streams or completion. The strict
fields and decoded guest streams of exec stay unchanged.

A refused gate, an invalid invocation or a contender gets no
dispatched-attempt ordinal. The backend instead appends one JSON record to
`refusals.jsonl`. The record holds the source, the UTC time, the exact original
argument array and the reason.

These refusals include parser errors with an identifiable initialised root,
argv and value refusals, and latched scenario calls. They also include each
competing writer, including failed confirmation or exact-stop requests. A
successful gate allocates no record. The first latch reason stays unchanged.

The source-only facade separately appends each abnormal backend exit to
`facade-refusals.log`. The ordinary 125 result is not abnormal. The record keeps
the status and a shell-quoted argument vector. This fallback uses Bash builtins,
so a missing Python backend cannot prevent it. A parser error can have both
records.

A facade exit record does not prove that dispatch never occurred. Both logs use
append mode outside the writer lock. They do not reserve eligibility or change
ordinals. Unavailable storage or an interruption can prevent or truncate a
record. Preserve such partials and the caller's status. No recording failure
permits input.

Every entry point takes the same nonblocking lock. CLI and jq children inherit
it. Thus a surviving child of a killed adapter prevents a second dispatch until
that child releases the lock. A contender refuses and latches.

These guarantees are local to this root and to cooperating processes. They
give no remote cancellation and no proof of child internals. They also give no
actual executable, spec or endpoint provenance. K54 keeps the freeze and audit
duties for the executable, the configuration, the spec and the endpoint.

For CLI calls, `evidence` admits only these actions: `agent windows`,
`agent snapshot` without `--open-menu`, `screen size`, `file download`,
`vm list` and the pinned `vm stop`. All other actions refuse with this class,
both before and after a latch. Snapshot's `--open-menu` option sends VNC clicks
in the tagged
[agent.rs](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs).
Thus both the separate and the equals forms refuse.

Checked evidence-class captures use the capture backend, not this generic CLI
route. The evidence class admits `file download` only through the checked download
backend, for the same reason. Collection cannot restore eligibility. Free guest-exec commands still
need caller classification. An evidence-class exec must collect read-only
context, never scenario input or configuration. There is no reset, overwrite or
scenario retry.

K57 must handle an orphan-held lock explicitly. All entry points refuse while a
CLI or validator owns the lock. These include exact stop and failure recording.
The adapter supplies no holder-discovery or cancellation API. The caller must
wait for its owned holder, or end its recorded owned process group. Only then
can it dispatch the exact-clone stop through this same seam.

Keep each refusal and every additional containment action separately. If the
caller cannot do this, cleanup stays unresolved, and every later slot stays NOT
RUN. Never bypass the lock or clear the latch. Keep the stop response and
status and the independent inventory as separate outcomes.

Init binds only the clone ID. K57 must pass the declared golden image explicitly
with `--base`. It must check the returned base identity and audit the frozen
image. A failed or interrupted `vm start` can leave the pinned clone running,
even with `--keep-on-failure` forbidden. SIGINT can kill the CLI before cleanup
completes, and a detached VM does not keep the adapter's lock.

K57 must preserve the uncertain creation and contain that exact identity,
without a replacement clone. The v2.7.0
[start implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs)
also shows why `--viewer` is forbidden. It can block for a human after the JSON
output.

A caught SIGINT during a transport produces `interrupted`. It keeps the partial
streams, and the adapter ends by SIGINT. TERM, HUP, KILL and signals outside that catch
window may leave only partial records. Every nonzero return stops input,
whatever the latch or receipt availability.

Facade failures keep an exclusive latch when storage permits. Missing or
invalid prior receipts prevent eligibility. K61 still owes the INT, TERM and HUP
handlers of the complete scenario. K57 owes the interruption collection.

<!-- tc: depart synonym-rotation because the application launch and the VM start are different operations -->
A clean CLI result establishes only the transport and the payload. Required
capture artifacts still need existence, readability and content checks. Launch,
defaults, quit and restart still need every prescribed downstream confirmation.
A failed restart submission stays unavailable, even after a later changed boot.
This expansion supplies none of those caller checks. It selects no new route,
input, delay or poll bound.

## Controls and verification

The [initial baseline](ordering-nonexec-evidence/baseline-red.txt) shows the
first eight controls failing, because the interface was absent. The
[expanded comparison](ordering-nonexec-evidence/baseline-control-red.txt) runs
all eleven new controls against the backend and facade of k59, copied into an
isolated tree.

The [missing-lock mutant](ordering-nonexec-evidence/unlocked-control-red.txt)
removes the lock call from a copy. It then fails the mixed non-exec orphan,
gate, confirmation and exec collection. The
[separator control](ordering-nonexec-evidence/separator-red.txt) fails the first
expansion before the terminator guard. Source inputs do not change during a
run. Each comparison keeps the before and after digests.

The new controls cover these cases:

- shared bytes and ordinals
- failures in both transport directions
- sticky collection and ordinal confirmation failures
- malformed envelopes, base rejection and payload rejection
- argv conflicts and pinned lifecycle and endpoint argv
- parser and facade failures
- lock ownership by a surviving child
- a distinct SIGINT.

The existing controls keep their coverage of strict exec and of the saved
timeout with matching text. They also cover clean negative polling, disconnect
with a changed boot, partial receipts and emission failure. These are helper controls. They do not simulate
or demonstrate a native focus repair.

Run `mise exec -- task check:vm-guest-exec` and the existing pointer and resize
checks. The [k60 receipt](ordering-nonexec-evidence/verification.json) keeps
each command, output and status, the tagged source digests and the before and
after input digests. These checks establish neither native availability nor
clean shutdown completion.

## K63 review integration (k64)

The findings come from the review's own commit `7009a5a4`, against the producer
`1d9bd4c6`. They were then checked against the current adapter and the official
local v2.7.0 source objects. The graph startup refused before project and
generation discovery. Thus bounded direct reads supply the source evidence of
this integration. No in-session reviewer or guest ran. Each disposition follows
the existing contract:

| Finding | Disposition and repair |
|---|---|
| P2-1, evidence label permits mutating CLI | Real issue. Enforce the finite collection and exact-stop set, including the snapshot option guard. The [control fails before repair](ordering-nonexec-integration-evidence/evidence-class-red.txt) and [passes after repair](ordering-nonexec-integration-evidence/evidence-class-green.txt). |
| P3-1, lost refusals and orphan containment gap | Real retention issue, repaired with backend and facade append logs. The [missing-log controls fail first](ordering-nonexec-integration-evidence/refusals-red.txt) and [pass with the repair](ordering-nonexec-integration-evidence/refusals-green.txt), including the exact-stop refusal under contention. Holder resolution and unresolved cleanup stay explicit k57 Done when duties. |
| P3-2, start options and golden identity | Real interface issue. The [viewer and keep-on-failure control fails first](ordering-nonexec-integration-evidence/start-options-red.txt) and [passes after the refusal guards](ordering-nonexec-integration-evidence/start-options-green.txt). Explicit base binding and audit, and containment after an uncertain start, stay k57 Done when duties. |
| P3-3, weak ID, lock and facade controls | Real control gap. Add the start and endpoint ID forms. Assert contention immediately for each entry point and keep its refused request. Assert the facade's own reason. The isolated [ID](ordering-nonexec-integration-evidence/caller-id-guard-red.txt), [check-lock](ordering-nonexec-integration-evidence/check-lock-red.txt), [confirmation-lock](ordering-nonexec-integration-evidence/fail-lock-red.txt) and [facade-reason](ordering-nonexec-integration-evidence/facade-reason-red.txt) mutations each fail the named assertion. |
| H-1, negative-poll and predicate limits | The contract was unclear. Keep the CLI-nonzero failure semantics. Document successful list-shaped negatives and actual payload predicates above and in the Done when of k61. No transport relaxation occurs. |

The [mutation definitions](ordering-nonexec-integration-evidence/mutations.json)
keep the exact replacements and the original and mutated source digests. The
initial `caller-id-red` receipt is a setup failure. Its first replacement
matched twice, and no control ran. It is not guard evidence. The
`caller-id-guard-red` receipt records the second experiment, whose replacement
matched once.

Every red and green receipt records the command, status, output digest and
before and after subjects. No measured input changed during those runs. These
are controlled adapter payloads, not a qualification of real command schemas.

The [fresh verification receipt](ordering-nonexec-integration-evidence/verification.json)
records the adapter, pointer and resize Taskfile checks. It also records their
individual test names and results, output digests and unchanged before and
after subjects. Its subject inventory includes the consumed helper and fixture
inputs, the report, the protocol, the caller duties and the kept control
evidence.

The [tagged-source receipt](ordering-nonexec-integration-evidence/official-source.json)
identifies the inspected source objects. Ordinary callers stay unmigrated. K61,
k62, k57 and the whole-harness review still come before the k54 readiness and
runtime.

The historical candidate, overlay and results bytes stay unchanged. So do the
classifications, strict false joins, NOT RUN phases, all closed caps and six
held causal slots. Native cause, ownership and repair acceptance stay
unresolved. No release, notarisation or upstream report occurs.
