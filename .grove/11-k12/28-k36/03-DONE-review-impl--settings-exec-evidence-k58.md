# settings-exec-evidence-k58

**Reviews:** settings-exec-evidence-k55

<!-- tc: off because the Goal, Context, Done when and Notes are the producer-authored charter, kept verbatim as the task contract -->

## Goal
Independently review the strict guest-exec adapter and its headless evidence
before shared scenario migration. Read the producer's committed diff from its
handle, not the session transcript.

## Context
The contract is ORDERING-EVALUATION-PLAN.md and ORDERING-REVIEW.md under
docs/verification/settings-activation. ORDERING-TRANSPORT-RESULTS.md describes
this expand increment and its limits; verification.json and per-test logs live
in ordering-transport-evidence. Existing ordinary callers remain legacy. K56
and k57 own migration and finite caller; no native runtime has occurred.

## Done when
- Review scripts/vm-guest-exec.py, its source-only shell facade, Taskfile entry
  and Tests/scripts/vm-guest-exec.bats against the parent evidence contract.
  Try to find wrong acceptance, a hidden retry/dispatch after failure, lost raw
  evidence, incorrect VM binding, overwrite or competing-writer gap.
- Assess exact schema/command and payload validation, clean negative versus
  transport failure, the sticky latch across substitutions/collection, and
  incomplete-record handling. Check claims and controls against actual behavior;
  do not treat simulated CLI or saved envelope checks as native product success.
- Check what the script can and cannot guarantee on interruption or storage
  failure. Separate missing future integration work from defects in this adapter;
  check its interface gives k56 enough evidence to implement the full contract.
- Produce source-anchored actionable findings or state no findings in the
  inspected scope. No fixes, VM, freeze or changed protocol. Any earned integration
  must precede the first later live sibling (currently k56) and runtime.

## Notes
No in-session producer reviewer ran. Thirteen new controls, eight pointer and
nine resize controls pass with unchanged final input digests. Historical bytes,
slots/caps, native cause/ownership and all unresolved parent duties survive.
<!-- tc: on -->

## Decisions (running log)

- 2026-10-29: Adopt the mandated review-impl leaf on the empty jj change
  vwmvtpyx. Its parent is 9ad206f1, the k55 producer commit. Read the brief
  chain, the k53 brief, the k55 task file and the producer diff. Read the
  plan's transport section and the review dispositions. The graph server
  failed to connect, so read the adapter, facade, Bats suite, Taskfile entry
  and receipts directly. Claim no graph coverage. Run no test, build, lint,
  guest or in-session reviewer.
- 2026-10-29: Read the TestAnyware v2.7.0 resolver, flag definitions and exec
  handler at the tag. `--connect` has no environment binding, so an explicit
  `--vm` takes precedence over `TESTANYWARE_VM_ID` and `TESTANYWARE_AGENT`.
  The per-VM spec directory comes from `XDG_STATE_HOME` or `config.rhai`.
  Read the exception path of `subprocess.run` in the installed Python 3.15.
- 2026-10-29: All fifteen digests in verification.json match the committed
  bytes. The same check fails on a deliberately wrong digest.
- 2026-10-29: Three P2 findings, three P3 findings and one handoff gap earn an
  integration. Insert one integrate-review-impl leaf before
  settings-shared-scenario-k56, the first live sibling after this review. This
  session finishes no producer and closes no node, so it writes no Creator line.

## Findings

Severity: P2 means a defect in a guarantee that the adapter or its report
claims, which k56 or k57 would rely on. P3 means a narrower defect or a
retention gap. H means future work that is not an adapter defect.

Line numbers refer to commit 9ad206f1. "py" is `scripts/vm-guest-exec.py`.
"lib" is `scripts/vm-guest-exec-lib.sh`. "bats" is
`Tests/scripts/vm-guest-exec.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-TRANSPORT-RESULTS.md`. "The
plan" is `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.

### P2-1. The competing-writer control passes with the lock removed

The control "competing writers latch unavailable before a second transport can
dispatch" (bats:124-146) starts an `evidence` call. It waits until the fake CLI
runs, then issues a `one-shot` call. It expects status 125 and one CLI call.

Remove the lock (py:196-203) and the second call still lists `000001` without
`result.json` (py:126-131). It latches `unfinished attempt` and refuses,
because its class is not `evidence` (py:132-134). Every assertion still holds.
The control does not read the latch reason, so it cannot tell which guard
refused.

Only the lock guards the case where the second call is also `evidence`. That
class passes both the latch and the unfinished-attempt check, and then
dispatches. No control exercises it. The report still credits the suite with
concurrent-writer coverage (report:49-50, 111).

Consequence: the single-writer guarantee during collection rests on code that
no control saw fail. K57 runs evidence calls in exactly that state.

Smallest correction: make the second call `evidence`. Assert one CLI call and a
latch reason that names the competing writer. Watch the control fail with the
lock removed before crediting it.

### P2-2. The writer lock ends with the adapter process, not with the CLI child

Python opens the lock descriptor without inheritance, and `subprocess.run`
closes other descriptors in the child (py:197, 163-165). The CLI child never
holds the lock. `subprocess.run` kills its child only on an exception that it
can catch. SIGINT arrives as KeyboardInterrupt and takes that path. SIGTERM,
SIGHUP and SIGKILL to the adapter do not.

In those cases the adapter dies and the kernel releases the lock. The CLI continues to
run the guest command. It also keeps writing to `raw.stdout` and `raw.stderr`
of the attempt (py:159-165). The next `evidence` call sees the unfinished
attempt and latches. It then sends a second exec to the same VM while the
orphan is still in flight (py:129-134, 142).

The plan forbids a second writer (plan:311). It treats interruption as a
no-acceptance outcome with partials preserved (plan:347). The report assigns
interruption collection to k57 (report:53-54), and that collection uses this
adapter.

Consequence: a SIGTERM to the adapter, for example from a timeout wrapper or a
cleanup kill, can produce two concurrent execs against one VM. The unfinished
record also continues to change after the adapter classified it.

Smallest correction: tie the lock to the child's lifetime. Pass the lock
descriptor to the child, so that a later writer refuses while the orphan runs.
This also covers SIGKILL of the adapter. Alternatively, handle SIGTERM and
SIGHUP like KeyboardInterrupt: kill and reap the child, then record. Add a
control that sends SIGTERM to the adapter during a delayed fake exec and then issues
an `evidence` call.

### P2-3. Failure exits other than 125 leave no latch and no record

The report states that the latch survives command substitutions and ignored
return statuses (report:41-42). Three failure paths exit without a latch:

- An argument error exits 2 inside argparse, before the `try` in `main`
  (py:239, 241-255). Examples are a missing predicate or an unknown class.
- The facade runs `python3` on a path derived from `BASH_SOURCE` (lib:4, 7). A
  missing or unreachable backend exits 2 and writes nothing.
- The adapter emits clean stdout after `result.json` records `clean` (py:174-188). A
  failed write makes `main` latch a reason without the ordinal (py:251-254).
  A failed buffered flush at interpreter exit gives status 120 and no latch.

An empty operation is also an invocation error, but it latches and exits 125
(py:194-195, 251-255). The report states that invocation errors use exit 2
(report:55).

Consequence: a mis-invoked required read inside a command substitution with an
ignored status leaves no trace. The next one-shot then dispatches. In the
emission case, a per-attempt receipt reads `clean` while the caller received a
failure.

Smallest correction: for `run` on an initialised root, latch on every failure
path, including argument errors. Let the facade latch when the backend exits
with any status other than 0 or 125. Emit and flush stdout before the terminal
receipt, and record the emission outcome in it. State that callers must treat
every nonzero status as unavailable. Amend the exit-2 sentence in the report.

### P3-1. The adapter records an interruption as an ordinary unavailable transport

The adapter catches KeyboardInterrupt during the exec and records it only as
`reason` text. It returns 125 with `outcome` `unavailable`, the same as any
transport failure (py:168-173, 177-186).

Bash's manual states its SIGINT rule. When a foreground child exits normally
after SIGINT, the script does not treat SIGINT as fatal and continues. An INT
trap still runs. The scenario traps only EXIT (`scripts/vm-verify-lib.sh:110`).
The adapter does not catch an interrupt that arrives while it writes the receipt. Python
then dies by SIGINT, so the behaviour depends on timing.

Consequence: k57 must keep interruption separate from transport failure
(plan:257, 347). It can do so only by matching `reason` prose. Without an INT
trap, an operator's Ctrl-C does not stop the scenario.

Smallest correction: record a distinct `interrupted` outcome. After recording,
re-raise SIGINT with the default disposition, so that the shell sees an
interrupted child. Alternatively, state this as an explicit k56 or k57 duty
together with the INT trap that they must install.

### P3-2. A truncated terminal receipt counts as complete

The unfinished-attempt check tests only that `result.json` is a file
(py:130). A clean attempt writes no latch before its receipt (py:172-183).
`write_json` creates the file before it writes the content, without fsync
(py:25-28). An interrupt or crash in that window leaves an empty or partial
`result.json` and no latch. Later scenario calls then dispatch.

Consequence: the incomplete-record guard has a narrow window in which a partial
record reads as terminal.

Smallest correction: require a parseable receipt with a known `outcome`, and
latch otherwise. Write the receipt to a temporary name and rename it into
place.

### P3-3. The record binds neither the CLI executable nor the resolved VM endpoint

The recorded argv starts with the bare name `testanyware`, which PATH resolves
(py:142). The Bats suite works because it puts a fake first on PATH
(bats:12-23). TestAnyware v2.7.0 resolves `--vm <id>` to a spec file under
`XDG_STATE_HOME` or the `config.rhai` state directory. The resolver's
`vms_dir` function does this (cli-rs/crates/testanyware-cli/src/resolve.rs:591-599).

The adapter records no executable path, CLI version, jq version or spec path.
The plan requires the exact VM identity for each attempt (plan:207). It also
requires a freeze of the CLI and decoder versions (plan:307).

Consequence: a record cannot show which CLI binary or which agent endpoint
answered. A stale spec file with the same name stays invisible in the evidence.

Smallest correction: at initialisation, resolve the absolute executable path
and record it in `subject.json`. Use that path for every attempt. Record the
CLI and jq versions and the resolved spec path with its digest. Alternatively,
assign this provenance explicitly to the k54 freeze.

### H-1. The interface covers guest exec only

The latch gates only calls through this adapter (report:45-47). The interface
has no supported operation for three things that k56 needs:

- Read the latch before a non-exec input.
- Latch on a failed non-exec transport or a failed downstream confirmation.
- Record non-exec attempts in the same ordinal and lock domain.

The plan applies the single-attempt rule to agent, input, capture and VM
commands too (plan:211-213). Without these operations, the latch and the lock
cover only part of the scenario's transports.

This is not an adapter defect. Smallest correction: add the gap to k56's Done
when, so that k56 extends the seam and does not write the latch file by hand.

### Checked without a finding

- The envelope check accepts one object only. It rejects duplicate fields,
  NaN and Infinity, wrong types and a command mismatch. It requires
  `schema_version` 1.0, `ok:true`, `timed_out:false`, an integer zero exit, no
  `dry_run` and CLI zero. That matches the v2.7.0 success envelope
  (cli-rs/crates/testanyware-cli/src/commands/file.rs:39-49).
- The retained timeout fixture has `ok:true`, `timed_out:true`, exit -1 and
  the matching marker. Its control therefore tests a real false-success shape.
- The predicate wrapper `[(P)] == [true]`, with `-e` and an exact `true` line,
  rejects empty, multiple, null and false results, `halt` and compile errors.
- The adapter has no retry or loop. Each call creates one ordinal directory
  with `mkdir`. The raw stream files open exclusively.
- At v2.7.0, `--connect` has no environment binding
  (cli-rs/crates/testanyware-cli/src/main.rs:1283-1297). The explicit `--vm`
  flag therefore takes precedence over the ambient VM and agent variables.
- The latch file opens exclusively, so the first failure's reason persists.
  Collection after a failure does not clear it (bats:175-189).
- The Taskfile entry (Taskfile.yml:1462-1472) runs every gate that the report
  names. The fifteen receipt digests match the committed bytes.
