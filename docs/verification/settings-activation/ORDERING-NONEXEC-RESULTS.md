# Shared non-exec evidence boundary

K60 extends the strict guest-exec adapter with supported eligibility inspection,
failed-confirmation recording and non-exec TestAnyware attempts. All use the same
writer lock and ordinal sequence. K63 independently reviews that increment;
k64 integrates its findings below. All 37 adapter controls pass headlessly;
whole-harness review remains due after scenario/caller implementation. No ordinary caller has adopted
the adapter. No VM, signed candidate, freeze or native acceptance occurs.

K56 decomposes into evidence-interface expansion (k60), complete scenario/helper
migration (k61), and exact focused-prefix verification and whole-duty reconciliation
(k62). Only the first increment runs here. K61 retains every signal, transport,
confirmation, setup/title/liveness, screenshot and later ordinary duty. K62 extracts
through TextEdit quit immediately before resize from the changed complete scenario.
K57's finite caller and k54's readiness/runtime stay held. No parent closes.

## Supported interface

Source [the facade](../../../scripts/vm-guest-exec-lib.sh); sourcing starts no
process or VM. Initialize an unused directory and exact VM as in the
[exec report](ORDERING-TRANSPORT-RESULTS.md). The new operations are:

```sh
check_guest_evidence "$root"
cli_guest_evidence "$root" one-shot row-click '.x == 10 and .y == 20' -- input click 10 20
fail_guest_evidence "$root" launch-identity 'wrong executable identity'
```

`check_guest_evidence` validates the initialized subject, prior receipts and
latch under the shared lock. It returns 0 only while eligible, dispatches
nothing and allocates no ordinal. It does not reserve permission for later input:
every later transport must still use a locked adapter, which checks eligibility
again. A bare CLI call after a clean check would bypass this contract.

`cli_guest_evidence ROOT CLASS OPERATION PREDICATE -- COMMAND SUBCOMMAND ARGS...`
submits once, with no host shell or retry. A clean call emits its exact original
JSON bytes and flushes before publishing its terminal receipt. It requires CLI
zero, one strict JSON object, `schema_version:"1.0"`, `ok:true`, no `dry_run`
field, and a mandatory jq predicate yielding exactly one true. Duplicate keys,
NaN/Infinity, multiple/partial objects, invalid predicates, empty/multiple results
and zero-exit `jq halt` remain unavailable.

Non-exec commands share only that base envelope. Pointer input has no exec-style
`timed_out`/`exit_code`/guest-stream fields. The caller must validate the actual
complete command-specific payload. The example checks only a pointer response;
controlled `marker` payloads in tests exercise the validator, not real upload or
screen-size schemas. K61 must enumerate and check every consumed schema before use,
including explicit clean negative facts. Exit zero alone never qualifies output.

Each k61 call site must supply a predicate on its own complete payload schema,
never constant `true`. The controls sometimes use `true` to isolate an adapter
guard; those fixtures qualify no real command schema. Clean negative polls must
use successful list-shaped reads, such as `agent windows`, whose complete payload
can express absence. TestAnyware's `WINDOW_NOT_FOUND`, `ELEMENT_NOT_FOUND` and
`TEXT_NOT_FOUND` errors return CLI 3 and latch unavailable. In particular,
`agent inspect`, `agent wait` and `screen find-text` cannot use those errors as
clean negative polls. This preserves the strict transport rule; it admits no
new tolerated status or poll bound.

Supported families are agent, input, screen, file upload/download and the limited
lifecycle forms below. Endpoint commands receive the pinned `--vm` and `--json`.
Screenshots must use the [checked capture interface](ORDERING-CAPTURE-RESULTS.md);
generic CLI `screen capture` refuses in every class before dispatch. Its unique
output path and complete PNG qualification remain inside the shared lock.
Caller endpoint/output/live-execution overrides and embedded `--` terminators
refuse before dispatch and latch failure. The API's initial `--` only separates
its own arguments. Guest exec must use the stricter `exec_guest_evidence` route.

| Lifecycle form | Binding |
|---|---|
| `vm start OPTIONS...` | Append pinned `--id` and `--json`; reject caller-supplied ID, `--viewer` and `--keep-on-failure`, including equals forms. K57 must explicitly select and audit `--base`. |
| `vm stop EXACT_ID` | Require the positional ID to equal the initialized VM; append `--json`. |
| `vm list OPTIONS...` | Append `--json`; the caller must request/validate complete required inventory and exact stopped identity. |

The base envelope and argv placement were inspected in the local official
`v2.7.0` tag's [output implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/output.rs)
and [argument declarations](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/main.rs),
after its workspace manifest. The internal Cargo version is 0.0.1; the release
tag identifies the inspected source. Online raw-file retrieval was unavailable,
so the mutable checkout was not used as release evidence. The final receipt
records tagged source digests. Code comments cite the official decision sites.

`fail_guest_evidence ROOT OPERATION REASON` records a failed downstream or
artifact check as the next ordinal: transport `confirmation`, class `evidence`,
empty argv, no CLI status and unavailable result. A successfully recorded failure
returns 125. It remains callable during collection and preserves the first latch
reason. It does not perform or retry the check. K61 must stop after a failed check,
record it here, and stop on every nonzero adapter return too. Failure to record
never permits input. Scenario callers must not edit latch files directly.

## Records and limits

Exec and CLI share ordinals, raw streams, exact argv/VM/class/operation/predicate,
times, CLI exit, validator streams, atomic receipts and first-failure latch.
CLI requests use `transport:"cli"`; their guest-shell `command` field is empty
and argv is the complete command. Confirmation events retain their reason without
fabricating transport streams/completion. Exec's strict fields and decoded guest
streams remain unchanged. A refused gate, invalid invocation or contender gets
no dispatched-attempt ordinal. The backend instead appends one JSON record to
`refusals.jsonl`: source, UTC time, exact original argument array and reason.
This includes parser errors with an identifiable initialized root, argv/value
refusals, latched scenario calls, and each competing writer, including failed
confirmation or exact-stop requests. A successful gate allocates no record.
The first latch reason stays unchanged.

The source-only facade separately appends each abnormal backend exit (other
than the ordinary 125 result) to `facade-refusals.log`, retaining status and a
shell-quoted argument vector. This fallback uses Bash builtins so a missing
Python backend cannot prevent it. A parser error can have both records. A facade
exit record does not prove that dispatch never occurred. Both logs use append
mode outside the writer lock; they do not reserve eligibility or alter ordinals.
Unavailable storage or interruption can prevent or truncate a record. Preserve
such partials and the caller's status; no recording failure permits input.

Every entry point takes the same nonblocking lock. CLI and jq children inherit
it, so a killed adapter's surviving child prevents a second dispatch until that
child releases it. A contender refuses and latches. These guarantees are local
to this root and cooperating processes: no remote cancellation, proof of child
internals, or actual executable/spec/endpoint provenance follows. K54 retains
the executable/config/spec/endpoint freeze and audit duties.

For CLI calls, `evidence` admits only `agent windows`, `agent snapshot` without
`--open-menu`, `screen size`, `file download`, `vm list` and
the pinned `vm stop`. All other actions refuse with this class, both before and
after a latch. Snapshot's `--open-menu` option sends VNC clicks in tagged
[agent.rs](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
so both separate and equals forms refuse. Checked evidence-class captures use
the capture backend rather than this generic CLI route. Collection cannot restore eligibility.
Free guest-exec commands still require caller classification: an evidence-class
exec must collect read-only context, never scenario input or configuration.
There is no reset, overwrite or scenario retry.

K57 must handle an orphan-held lock explicitly. All entry points, including
exact-stop and failure recording, refuse while a CLI or validator owns it. The
adapter supplies no holder-discovery or cancellation API. The caller must wait
for its owned holder or end its recorded owned process group before dispatching
exact-clone stop through this same seam. Retain each refusal and every additional
containment action separately. If that cannot be done, cleanup stays unresolved
and every later slot stays NOT RUN; never bypass the lock or clear the latch.
Retain stop response/status and independent inventory as separate outcomes.

Init binds only the clone ID. K57 must pass the declared golden image explicitly
with `--base`, validate the returned base identity and audit the frozen image.
A failed or interrupted `vm start` can leave the pinned clone running even with
`--keep-on-failure` forbidden; SIGINT can kill the CLI before cleanup completes,
and a detached VM does not retain the adapter's lock. K57 must preserve uncertain
creation and contain that exact identity, without a replacement clone. The
v2.7.0 [start implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs)
also shows why `--viewer` is forbidden: it can block for a human after JSON output.

Caught SIGINT during transport produces `interrupted`, retains partial streams
and terminates by SIGINT. TERM/HUP/KILL and signals outside that catch window may
leave only partial records. Every nonzero return stops input regardless of latch
or receipt availability. Facade failures retain an exclusive latch when storage
permits; missing/invalid prior receipts prevent eligibility. K61 still owes the
complete scenario's INT/TERM/HUP handlers; k57 owes interruption collection.

A clean CLI result establishes only transport/payload. Required capture artifacts
still need existence/readability/content checks. Launch/defaults/quit/restart
still need every prescribed downstream confirmation. A failed restart submission
stays unavailable despite a later changed boot. This expansion supplies none of
those caller checks and selects no new route, input, delay or poll bound.

## Controls and verification

The [initial baseline](ordering-nonexec-evidence/baseline-red.txt) shows the first
eight controls failing because the interface was absent. The
[expanded comparison](ordering-nonexec-evidence/baseline-control-red.txt) runs all
eleven new controls against k59's backend/facade copied into an isolated tree.
The [missing-lock mutant](ordering-nonexec-evidence/unlocked-control-red.txt)
fails mixed non-exec orphan/gate/confirmation/exec collection with the lock call
removed from a copy. The [separator control](ordering-nonexec-evidence/separator-red.txt)
fails the first expansion before the terminator guard. Source inputs do not
change during a run; each comparison retains before/after digests.

New controls cover shared bytes/ordinals, failures in both transport directions,
sticky collection, ordinal confirmation failures, malformed/base and payload
rejection, argv conflicts, pinned lifecycle/endpoint argv, parser/facade failures,
surviving-child lock ownership and distinct SIGINT. Existing controls retain
strict exec, saved timeout-with-matching-text, clean negative polling,
disconnect/changed-boot, partial receipt and emission failure coverage. These are
helper controls, not simulated or demonstrated native focus repair.

Run `mise exec -- task check:vm-guest-exec` and the existing pointer/resize checks.
The [k60 receipt](ordering-nonexec-evidence/verification.json) retains each
command/output/status, tagged source digests and before/after input digests.
These checks establish neither native availability nor clean shutdown completion.

## K63 review integration (k64)

Findings were read from the review's own commit `7009a5a4`, against producer
`1d9bd4c6`, then checked against the current adapter and official local v2.7.0
source objects. Graph startup refused before project/generation discovery;
bounded direct reads supply this integration's source evidence. No in-session
reviewer or guest ran. Each disposition follows the existing contract:

| Finding | Disposition and correction |
|---|---|
| P2-1, evidence label permits mutating CLI | Real issue. Enforce the finite collection/exact-stop set, including the snapshot option guard. The [control fails before repair](ordering-nonexec-integration-evidence/evidence-class-red.txt) and [passes after repair](ordering-nonexec-integration-evidence/evidence-class-green.txt). |
| P3-1, lost refusals and orphan containment gap | Real retention issue repaired with backend/facade append logs. [Missing-log controls fail first](ordering-nonexec-integration-evidence/refusals-red.txt) and [pass with the repair](ordering-nonexec-integration-evidence/refusals-green.txt), including exact-stop refusal under contention. Holder resolution and unresolved cleanup remain explicit k57 Done when duties. |
| P3-2, start options and golden identity | Real interface issue. [Viewer/keep-on-failure control fails first](ordering-nonexec-integration-evidence/start-options-red.txt) and [passes after refusal guards](ordering-nonexec-integration-evidence/start-options-green.txt). Explicit base binding/audit and containment after uncertain start remain k57 Done when duties. |
| P3-3, weak ID/lock/facade controls | Real control gap. Add start and endpoint ID forms, assert contention immediately for each entry point and retain its refused request, and assert the facade's own reason. Isolated [ID](ordering-nonexec-integration-evidence/caller-id-guard-red.txt), [check-lock](ordering-nonexec-integration-evidence/check-lock-red.txt), [confirmation-lock](ordering-nonexec-integration-evidence/fail-lock-red.txt) and [facade-reason](ordering-nonexec-integration-evidence/facade-reason-red.txt) mutations each fail the named assertion. |
| H-1, negative-poll and predicate limits | Contract stated unclearly. Preserve CLI-nonzero failure semantics; document successful list-shaped negatives and actual payload predicates above and in k61's Done when. No transport relaxation is made. |

The [mutation definitions](ordering-nonexec-integration-evidence/mutations.json)
retain exact replacements and original/mutated source digests. The initial
`caller-id-red` receipt is a setup failure: the first replacement matched twice
and no control ran. It is not guard evidence; `caller-id-guard-red` records the
corrected experiment. Every red/green receipt records command, status, output
digest and before/after subjects; no measured input changed during those runs.
These are controlled adapter payloads, not real-command schema qualification.

The [fresh verification receipt](ordering-nonexec-integration-evidence/verification.json)
records the adapter, pointer and resize Taskfile checks, their individual test
names/results, output digests and unchanged before/after subjects. Its subject
inventory includes consumed helper/fixture inputs, the report, protocol, caller
duties and retained control evidence. The [tagged-source receipt](ordering-nonexec-integration-evidence/official-source.json)
identifies the inspected source objects. Ordinary callers remain unmigrated;
k61/k62/k57 and whole-harness review still precede k54 readiness/runtime.

Historical candidate/overlay/results bytes, classifications, strict false joins,
NOT RUN phases, all closed caps and six held causal slots remain unchanged.
Native cause, ownership and repair acceptance remain unresolved. No release,
notarization or upstream report occurs.
