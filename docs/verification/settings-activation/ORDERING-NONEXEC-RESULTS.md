# Shared non-exec evidence boundary

K60 extends the strict guest-exec adapter with supported eligibility inspection,
failed-confirmation recording and non-exec TestAnyware attempts. All use the same
writer lock and ordinal sequence. The complete 32-control adapter suite passes
headlessly; this expansion still requires independent tree review and every
earned integration before scenario migration. No ordinary caller has adopted
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
capture schemas. K61 must enumerate and check every consumed schema before use,
including explicit clean negative facts. Exit zero alone never qualifies output.

Supported families are agent, input, screen, file upload/download and the limited
lifecycle forms below. Endpoint commands receive the pinned `--vm` and `--json`.
Caller endpoint/output/live-execution overrides and embedded `--` terminators
refuse before dispatch and latch failure. The API's initial `--` only separates
its own arguments. Guest exec must use the stricter `exec_guest_evidence` route.

| Lifecycle form | Binding |
|---|---|
| `vm start OPTIONS...` | Append pinned `--id` and `--json`; reject caller-supplied ID. |
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
streams remain unchanged. A gate, invalid invocation or refused contender may
have only a root latch, with no fabricated dispatched-attempt ordinal.

Every entry point takes the same nonblocking lock. CLI and jq children inherit
it, so a killed adapter's surviving child prevents a second dispatch until that
child releases it. A contender refuses and latches. These guarantees are local
to this root and cooperating processes: no remote cancellation, proof of child
internals, or actual executable/spec/endpoint provenance follows. K54 retains
the executable/config/spec/endpoint freeze and audit duties.

Class names remain caller obligations. `evidence` permits read-only collection
and containment after failure; it must never bypass the latch for scenario input.
Collection cannot restore eligibility. There is no reset, overwrite or retry.
K57 retains exact-clone containment, independent inventory and separate outcomes.

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
The [final receipt](ordering-nonexec-evidence/verification.json) retains each
command/output/status, tagged source digests and before/after input digests.
These checks establish neither native availability nor clean shutdown completion.

Historical candidate/overlay/results bytes, classifications, strict false joins,
NOT RUN phases, all closed caps and six held causal slots remain unchanged.
Native cause, ownership and repair acceptance remain unresolved. No release,
notarization or upstream report occurs.
