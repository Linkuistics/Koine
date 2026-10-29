# Strict guest-exec evidence increment

The new guest-exec adapter passes thirteen headless controls. It records one
transport attempt and distinguishes clean command output from unavailable
evidence. It has **not been adopted by the ordinary scenario**. The scenario,
non-exec transports, positive setup/title/process assertions, one-shot downstream
confirmations and finite evaluation caller remain unfinished. No signed subject,
clone, evaluation slot, native acceptance or product repair result is supplied.

This is the first child of settings-ordering-harness-k53. The work decomposes at
an expand-then-migrate boundary: strict exec evidence, complete shared scenario
migration, then finite caller/classifier. Independent adapter review precedes
migration; every earned integration and final harness review precedes runtime.
Settings-ordering-qualification-k54 remains held until that work is complete.

## Implemented seam

[vm-guest-exec-lib.sh](../../../scripts/vm-guest-exec-lib.sh) is source-only.
Sourcing it starts no process or VM. Its two functions delegate structured
recording to [vm-guest-exec.py](../../../scripts/vm-guest-exec.py):

```sh
source scripts/vm-guest-exec-lib.sh
init_guest_evidence "$unused_directory" "$exact_vm_id"
exec_guest_evidence "$directory" read-poll endpoint "$command" \
    '.stdout == "ABSENT" or .stdout == "PRESENT"'
```

Initialization creates a new directory and pins one plain VM identity. It
refuses an existing directory. Each run requires a class, call-site operation,
exact command and explicit jq payload predicate. There is no default predicate,
retry, settling wait, poll loop, launch confirmation or alternate transport.
The caller owns those predicates and the existing state-poll count/delay.
`ABSENT` above illustrates a complete negative payload; the adapter does not
invent it from a failed guest test. The migration must produce and validate each
actual command-specific schema before using this seam.

The three admitted classes are `read-poll`, `one-shot` and `evidence`. A clean
attempt returns zero and emits its guest stdout unchanged. A failed attempt
returns 125, emits no qualified stdout and creates a persistent `unavailable`
file naming the first failure. The file survives command substitutions and
ignored shell return statuses. Later poll/one-shot calls refuse to dispatch.
Explicit read-only evidence collection can still run once per requested call;
its clean result does not clear the latch or restore scenario eligibility.
Class names are caller obligations: the adapter cannot determine whether an
arbitrary guest shell command sends input. K56 must classify and guard every
consumed operation, including input commands outside exec.

A non-blocking OS file lock prevents simultaneous adapter writers; a competing
writer latches unavailable. An ordinal directory without a terminal result
also latches unavailable before subsequent scenario dispatch. This preserves an
interrupted attempt without fabricating completion or replaying its command.
The unfinished-record control covers this recovery decision; it does not test
signal-driven whole-scenario collection or clone containment, which remain k57.
Invocation errors use exit 2. Filesystem/recording errors fail unavailable and
can leave partial records. There is no supported reset or retry operation.

## Retained records and validation

Each six-digit ordinal directory retains:

| File | Meaning |
|---|---|
| `request.json` | Ordinal, exact VM, class/operation, command/argv, payload predicate and UTC start |
| `raw.stdout`, `raw.stderr` | Original CLI streams, written directly without stripping |
| `cli.exit` | Actual completed CLI exit; absent if completion was unavailable |
| `guest.stdout`, `guest.stderr` | Decoded string fields when available, including failed envelopes; presence supplies no qualification |
| `payload.stdout`, `payload.stderr` | Exact validator output and diagnostics when validation reached that step |
| `result.json` | Individual clean/unavailable outcome, reason, CLI status, UTC end and monotonic duration |

An incomplete request/result remains partial. The containing `subject.json`
binds the exact VM and `unavailable` preserves the first failure. An individual
clean collection receipt after failure does not make the root eligible.

The adapter requires one complete JSON object, rejects duplicate fields and
non-JSON NaN/Infinity values, and requires schema version `1.0`, the exact command,
`ok:true`, `timed_out:false`, an integer zero exit and string stdout/stderr.
Dry-run output is rejected. CLI zero is independently required. The caller's
predicate runs on that same envelope and must produce exactly one boolean true;
the validator must actually emit true, so zero-exit `jq halt` is unavailable.
No matching stdout, later boot change or later successful read rescues failure.

The installed CLI reports TestAnyware 2.7.0. Its exec help, local official
`file-exec.json` schema, exec/output implementation and connection resolver were
read. The [v2.7.0 exec implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs)
and [resolver](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/resolve.rs)
are cited beside the corresponding decisions. The JSON success payload uses
top-level fields despite help prose mentioning `details.exit_code`; a clean
spawn does not establish a successful guest command. Explicit `--vm` binds the
request instead of ambient VM/agent flags. No `--connect` route is admitted.

Graph startup refused before project/generation discovery with the existing
pre-coordination/unverified-generation error. Bounded direct reads covered the
scenario, shared/desktop/pointer/resize helpers, signing environment, existing
capture wrapper and saved response. No graph completeness claim is made.

## Controls and verification

The [Bats suite](../../../Tests/scripts/vm-guest-exec.bats) exercises the real
shell facade and Python subprocess boundary against a controlled CLI executable;
it starts no guest. The original twelve controls failed when the backend was
absent. The fixture initially omitted jq's option terminator while logging argv;
that test-only defect was corrected before crediting the passing controls.
Two additional malformed-validator branches were then seen to fail against the
implemented adapter: zero-exit jq halt and Python's permissive NaN/Infinity
decoding. Their repairs now pass the same controls.

The thirteen named controls cover exact raw/guest bytes and VM argv, metadata,
reuse refusal, absent/wrong fields and command/schema mismatch, partial/malformed/
duplicate/multiple JSON, nonzero CLI and guest failure, actual retained timeout
with expected text, missing marker/invalid predicate, concurrent writers, clean
negative poll continuation, failed poll across command substitution, disconnect
followed by clean changed-boot collection, incomplete prior record and invalid
class/uninitialized root. The retained timeout subject is the unchanged
`persisted-01/trace-disabled-after.json`; it remains failed historical evidence.

Run `mise exec -- task check:vm-guest-exec`. This runs shell syntax, ShellCheck,
shfmt, Python compilation, Ruff checks/format, strict pyright and Bats.
The [verification receipt](ordering-transport-evidence/verification.json)
records the final commands, outcomes, subject hashes before/after and per-test
output. These controls establish adapter behavior only. They demonstrate neither
native Settings behavior nor that restart can return clean completion.

## Remaining original duties

The [reviewed protocol](ORDERING-EVALUATION-PLAN.md) and its
[original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
remain unchanged. K56 owns the reachable call-site/schema inventory, migration
of `guest`, `guest_text`, `guest_json`, `guest_once`, discarded CLI results and
all other consumed transports; every one-shot confirmation; unchanged physical
inputs/waits/poll bounds; positive TextEdit/PID/document/menu setup; original-list
title audit; process-loss distinction; screenshots; and exact focused-prefix
extraction through TextEdit quit before resize. All later ordinary duties remain.
K57 owns the finite caller, separate statuses and rejection precedence, item
audits, interruption/collection, exact stop and independent VM inventory.
Further decomposition must preserve those duties if a child proves too large.

No E01/E02/A01/A02/A03 slot runs here. All six causal slots remain held and every
historical cap stays closed. Original candidates, overlays, results, strict false
joins, failed transports and NOT RUN phases remain unchanged. Native cause and
ownership remain unresolved; no product or causal ancestor closes. No release,
notarization or upstream report occurs.
