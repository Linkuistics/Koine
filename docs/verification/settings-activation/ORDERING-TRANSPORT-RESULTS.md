# Strict guest-exec evidence increment

The reviewed guest-exec adapter passes twenty-one headless controls. It records
one transport attempt and distinguishes clean command output from unavailable
evidence. It has **not been adopted by the ordinary scenario**. The scenario,
non-exec transports, positive setup/title/process assertions, one-shot downstream
confirmations and finite evaluation caller remain unfinished. No signed subject,
clone, evaluation slot, native acceptance or product repair result is supplied.

This is the first child of settings-ordering-harness-k53. The work decomposes at
an expand-then-migrate boundary: strict exec evidence, complete shared scenario
migration, then finite caller/classifier. K58 review and k59 integration repair
the adapter before migration; final whole-harness review and every earned
integration precede runtime.
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
attempt returns zero after emitting and flushing its guest stdout unchanged.
A transport, payload or recording failure normally returns 125 and creates a
persistent `unavailable` file naming the first failure. Later poll/one-shot calls
refuse to dispatch. Explicit read-only evidence collection can still run once
per requested call; its clean result does not clear the latch or restore
scenario eligibility. Class names are caller obligations: the adapter cannot
determine whether an arbitrary guest shell command sends input.

The exit contract is:

| Result | Status and caller duty |
|---|---|
| Clean individual attempt | 0; an old root latch still prevents scenario eligibility. |
| Argument-parser error | 2; an identifiable initialized `run ROOT` is latched before exit. Missing or unidentifiable roots cannot receive a latch. |
| Invalid run value, refused dispatch, failed transport/payload/emission or caught recording error | Normally 125; stop input and retain partials. An empty operation is an invalid run value, not an argparse error. |
| Caught SIGINT during exec, validation or emission | An `interrupted` terminal receipt when recording succeeds, followed by SIGINT termination (shell status 130). |
| Missing/unreachable backend or unexpected backend exit | Preserve the nonzero backend status; the shell facade attempts an exclusive first-failure latch without needing Python. |
| Other signal, interpreter or storage failure | May have another nonzero status or no terminal receipt. Every nonzero status is unavailable, regardless of latch/receipt availability. |

Argument errors and unexpected backend failures retain a root latch, not a
fabricated dispatched-attempt receipt. The latch survives command substitutions
and ignored return statuses when storage is writable. The facade cannot persist
one when the root or storage is unavailable. Callers must check every status.
A failed emission can already have delivered a byte prefix; a later receipt
failure can follow a complete stdout write. No output from a nonzero call is
qualified. Flushing proves local delivery to the output stream, not downstream
consumption or downstream confirmation.

A non-blocking file lock prevents simultaneous writers in the same evidence
root, including evidence collection. The CLI and jq validator inherit its open
descriptor, so killing the adapter alone does not release the domain while
those children retain it. A competing call refuses and latches unavailable.
There is no explicit unlock that could release a child's lock early.

This is a local process-lifetime guarantee. It does not cancel remote guest
work, prove that a CLI retained the descriptor internally, or contain commands
submitted outside this root. A killed adapter can leave the CLI and raw streams
live; the inherited lock then refuses collection until its holders exit. Do not
rename the lock, reuse the root, or interpret an orphan's eventual output as a
completed attempt. K57 owns interruption collection, exact-clone containment and
separate outcomes. K56 must install scenario signal handling that stops input;
a caught SIGINT is distinct, but signals outside the catchable recording window
can leave only partials. SIGTERM, SIGHUP and SIGKILL are not normalized into
terminal receipts.

Before later dispatch, every prior terminal receipt must parse as one object
with a known `clean`, `unavailable` or `interrupted` outcome. A missing, truncated
or unknown receipt latches unavailable; non-clean receipts preserve failure.
JSON records are written to exclusive `.partial` files, flushed and fsynced,
then atomically published with an exclusive hard link and the partial name
removed. This avoids overwriting a receipt and publishing a partly written
terminal name. It is not a power-loss durability guarantee: directory entries
are not fsynced. Storage failure or interruption can leave partials, or both
names after publication. Preserve them and stop on the failed call. There is
no supported reset or retry operation.

## Retained records and validation

Each six-digit ordinal directory retains:

| File | Meaning |
|---|---|
| `request.json` | Ordinal, exact VM, class/operation, command/argv, payload predicate and UTC start |
| `raw.stdout`, `raw.stderr` | Original CLI streams, written directly without stripping |
| `cli.exit` | Actual completed CLI exit; absent if completion was unavailable |
| `guest.stdout`, `guest.stderr` | Decoded string fields when available, including failed envelopes; presence supplies no qualification |
| `payload.stdout`, `payload.stderr` | Exact validator output and diagnostics when validation reached that step |
| `result.json` | Individual clean/unavailable/interrupted outcome, reason, CLI status, stdout emission status (`not-attempted`, `flushed`, `failed`), UTC end and monotonic duration |

An incomplete request/result remains partial. The containing `subject.json`
records the requested VM name and `unavailable` preserves the first failure.
It does not identify the executable resolved through PATH or the VM spec/agent
endpoint. K54 must freeze absolute CLI/jq paths, versions/hashes, effective
state/config, and bind each newly created clone to its exact spec path/digest
and endpoint before its first guest transport. Execution and post-run audits
must enforce that mapping; clone creation alone proves no exec provenance.
An individual clean collection receipt after failure does not make the root eligible.

The adapter requires one complete JSON object, rejects duplicate fields and
non-JSON NaN/Infinity values, and requires schema version `1.0`, the exact command,
`ok:true`, `timed_out:false`, an integer zero exit and string stdout/stderr.
Dry-run output is rejected. CLI zero is independently required. The caller's
predicate runs on that same envelope and must produce exactly one boolean true;
the validator must actually emit true, so zero-exit `jq halt` is unavailable.
No matching stdout, later boot change or later successful read rescues failure.

K55 recorded TestAnyware 2.7.0 and inspected its exec help, local official
`file-exec.json` schema, exec/output implementation and connection resolver. The [v2.7.0 exec implementation](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/file.rs)
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

The original thirteen named controls cover exact raw/guest bytes and VM argv, metadata,
reuse refusal, absent/wrong fields and command/schema mismatch, partial/malformed/
duplicate/multiple JSON, nonzero CLI and guest failure, actual retained timeout
with expected text, missing marker/invalid predicate, concurrent writers, clean
negative poll continuation, failed poll across command substitution, disconnect
followed by clean changed-boot collection, incomplete prior record and invalid
class/uninitialized root. The retained timeout subject is the unchanged
`persisted-01/trace-disabled-after.json`; it remains failed historical evidence.

Run `mise exec -- task check:vm-guest-exec`. This runs shell syntax, ShellCheck,
shfmt, Python compilation, Ruff checks/format, strict pyright and Bats.
The [k55 receipt](ordering-transport-evidence/verification.json) retains the
producer's original bytes and measurements. Its hashes describe that commit,
not the reviewed adapter. The [k59 receipt](ordering-transport-integration-evidence/verification.json)
records the integrated commands, outcomes, subject hashes before/after and
per-test output. These controls establish adapter behavior only. They demonstrate neither
native Settings behavior nor that restart can return clean completion.

## K58 review dispositions

Read the findings in k58's review commit `b17080b2`; they refer to producer
`9ad206f1`. Each disposition follows source inspection and executable controls.

| Finding | Classification and disposition |
|---|---|
| P2-1, competing-writer control | Real control defect. The second call is now `evidence`, with one CLI invocation and the competing-writer reason required. The [lock-removed control](ordering-transport-integration-evidence/lock-removed-red.txt) fails with the lock bypassed. |
| P2-2, orphan lock lifetime | Real adapter defect. Pass the writer descriptor to CLI and validator children. The killed-adapter control sends TERM, HUP and KILL while the fake CLI is held; each subsequent evidence call must refuse without dispatch. This establishes local lock inheritance, not remote cancellation. |
| P2-3, unlatching exits and stdout | Real adapter/report defect. Parse errors latch identifiable initialized roots; the facade latches unexpected backend exits. Explicit stdout flush precedes terminal publication, and emission failure is recorded with its ordinal. The table above corrects the exit-2 and output guarantees. |
| P3-1, interruption indistinguishable | Real adapter defect. Caught SIGINT records `interrupted`, then terminates by SIGINT. The controlled signal test checks both receipt and signal status. K56 owns explicit whole-scenario signal traps; K57 retains interruption collection/containment. |
| P3-2, truncated terminal receipt | Real adapter defect. Parse prior receipts and require a known outcome. Publish complete JSON atomically without overwrite. The partial/unknown-record control and [interrupted-publication control](ordering-transport-integration-evidence/receipt-publication-red.txt) fail against k55. |
| P3-3, executable/endpoint provenance | Real provenance gap, repaired in the k54 freeze charter. This seam records a requested name only. Adding a second resolver here would duplicate lifecycle ownership; no runtime is admissible until k54 binds actual binaries/config/spec/endpoint and audits them. |
| H-1, non-exec interface | Contract handoff gap, not an exec-adapter defect. K56's Done when explicitly requires supported latch inspection and failure recording plus non-exec attempts in the same lock/ordinal domain. Direct latch-file edits are not the integration interface. |

The [diagnostic baseline run](ordering-transport-integration-evidence/baseline-diagnostic-red.txt)
shows seven new controls failing against k55 for the intended defects. The
atomic-publication control separately fails against the original backend.
All eight new controls pass with the integrated adapter. The partial-record
control initially reused its own CLI-count file between cases; isolating that
fixture corrected the test without changing the adapter. The complete suite
now passes twenty-one controls. No in-session reviewer is invoked: these
failure-path claims have executable counterexamples, and the complete harness
still earns its own review before runtime.

## Remaining original duties

The [reviewed protocol](ORDERING-EVALUATION-PLAN.md) and its
[original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
remain unchanged. K56 owns supported latch inspection/failure recording and
non-exec attempts in the shared ordinal/lock domain, explicit scenario signal handling, the reachable
call-site/schema inventory, migration of `guest`, `guest_text`, `guest_json`, `guest_once`, discarded CLI results and
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
