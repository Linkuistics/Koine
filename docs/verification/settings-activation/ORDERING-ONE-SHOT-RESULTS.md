# Checked one-shot submissions

k152 supplies source-only checked submissions for the one-shot exec commands of
the Settings scenario, with their downstream confirmations. Each submission
sends its unchanged legacy command once, and an exact grammar parses its
stdout. The shared writer domain of the [shared adapter](ORDERING-NONEXEC-RESULTS.md)
keeps every attempt: one lock, one latch and one ordinal sequence.

These entries extend the read table of the
[checked exec reads](ORDERING-EXEC-READ-RESULTS.md). They also use the checked
reads and polls of the [System Events results](ORDERING-SYSEVENTS-RESULTS.md).
The reviewed [ordering protocol](ORDERING-EVALUATION-PLAN.md) and the earlier
contracts stay binding. No ordinary caller or scenario root changes. No VM,
signed candidate, frozen subject, native availability or product acceptance
follows. An independent review and every earned integration come before k76
consumes this work.

## Interface

Source [the one-shot facade](../../../scripts/vm-exec-one-shot-evidence-lib.sh).
Sourcing only defines functions, and it also sources the System Events facade.
Each call needs a root that `init_guest_evidence` initialised.

| Function | Legacy caller | Result |
|---|---|---|
| `submit_guest_extraction ROOT OP` | `ditto -x` in `install_app` | 0 for a clean submission |
| `launch_guest_koine ROOT OP` | the three `guest_once "open ${INSTALLED}"` | 0 for a clean submission |
| `confirm_guest_launch ROOT OP` | none, after a launch and its endpoint poll | 0 prints the joined identity record, 1 is a clean mismatch |
| `confirm_guest_reopen ROOT OP IDENTITY` | none, after the reopen | 0 when the same process remains, 1 is a clean mismatch |
| `launch_guest_textedit ROOT OP` | `guest "open -a TextEdit" \|\| true` | 0 for a clean submission |
| `quit_guest_textedit ROOT OP` | the TextEdit `quit saving no` | 0 when one clean read finds no TextEdit process, 1 for a clean presence |
| `restart_guest ROOT OP BOOT` | the restart, its wait and its boot poll | 0 prints the changed boot record |
| `request_guest_automation ROOT OP` | the background request in `grant_system_events_automation` | 0 for a clean submission |
| `open_guest_accessibility_pane ROOT OP` | the pane `open` in `grant_accessibility` | 0 for a clean submission |
| `refuse_guest_trace_defaults ROOT OP` | the `KOINE_SETTINGS_TRACE` defaults write | always 125, and nothing is sent |
| `submit_guest_once ROOT OP NAME` | none | one checked submission of a table entry |

Status 1 is a clean false state, and it latches nothing. The caller keeps the
legacy failure. Every other nonzero status means that the submission, the read
or the decision is unavailable, and the backend latches the root. A latched
root refuses each later submission and scenario read without dispatch. Thus no
later read or answer can make a failed submission clean.

## The submissions

The tagged agent runs each command with `/bin/bash -c`. It waits for the bash
process only, writes stdout to a temporary file and removes trailing `\s+`
([ProcessRunner](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift)).
The exec envelope checks of the shared adapter apply first: CLI status 0, `ok`,
the exact command, `timed_out` false and guest exit 0. Then the stdout must equal
the clean stdout below exactly.

| Entry | Guest command, unchanged | Clean stdout |
|---|---|---|
| `extract-bundle` | `ditto -x -k /tmp/Koine.zip /Applications` | empty |
| `open-koine` | `open /Applications/Koine.app` | empty |
| `open-textedit` | `open -a TextEdit` | empty |
| `quit-textedit` | `osascript -e 'tell application "TextEdit" to quit saving no'` | empty |
| `request-automation` | `nohup osascript -e '…get name of every process' >/dev/null 2>&1 &` | empty |
| `open-accessibility-pane` | `open "x-apple.systempreferences:…?Privacy_Accessibility"` | empty |
| `restart` | `echo admin \| sudo -S shutdown -r now` | the two `shutdown` lines below |

Only the one-shot class admits these entries, and they take no argument. The
read-poll and evidence classes refuse them before dispatch. The backend action
`read` builds each command from the [read table](../../../scripts/vm_exec_reads.py),
so no caller can name another guest command through it.

The background request leaves empty stdout, because bash returns at once. Its
clean submission proves only that the shell began the job. The Allow prompt
and the System Events check stay its confirmations.

## The launch identity

The protocol needs the endpoint descriptor and the process identity after each
launch. k154 found that `ps` prints argv[0], which the process sets, so no `ps`
column is an executable identity. The `launch-identity` read therefore asks the
kernel.

<!-- tc: depart synonym-rotation because the process start time is an identity field, not the launch action -->
The read runs one command. An absent descriptor prints `ABSENT`, a clean fact.
Otherwise the command prints the legacy `pgrep -f` selection of the executable
pattern. Then a Python script reads the descriptor and calls `proc_pidinfo` with
`PROC_PIDTBSDINFO` and `proc_pidpath` for its PID. It prints the descriptor
text, the PID, the start time in seconds and microseconds and the executable
path as one JSON line.

The host SDK declares both calls in `libproc.h`. `sys/proc_info.h` defines the
flavour, the path buffer size and the `proc_bsdinfo` fields. The
[source receipt](ordering-one-shot-evidence/official-source.json) keeps the
digests. Each call fails with `ESRCH` for a PID that no longer exists, and the
script reports that as the clean fact `process: null`. The script reads the
start time before and after the path, and a difference is unavailable.

The record is joined when three facts hold:

- The kernel's executable path is `/Applications/Koine.app/Contents/MacOS/Koine`.
- The `pgrep` selection is exactly the descriptor's PID.
- The process exists, so its PID and start time are known.

A stale descriptor, a second process, a missing process and another executable
are clean mismatches. The descriptor keeps the version-1 grammar of the
endpoint read. Any other script status, a malformed line or a process record
with another PID is unavailable.

The reopen confirmation compares the new record with the record that the silent
launch confirmation printed. The instance, the PID, the start time in
microseconds and the executable must be the same. The protocol's "one titled
front/focused window" stays with the window owners.

Python can raise the Command Line Tools prompt on a guest without them. The
read is therefore out of the evidence class. The scenario already runs
`python3` for the enrolment client.

## The TextEdit quit

The protocol needs a clean quit and one clean process-absence observation.
`quit_guest_textedit` sends the quit once. After a clean submission, it reads
the k81 process read once, with the new pattern
`/System/Applications/TextEdit.app/Contents/MacOS`. `NONE` is the absence. A
live TextEdit is a clean presence, and the caller keeps a setup failure.

The `quit` reply of an application can precede its exit. The single read then
finds a presence. The protocol permits no wait or second read, so that case
stays a visible setup failure and never a Koine failure.

## The restart and its boot poll

`restart_guest` keeps the legacy sequence. It sends the restart once. After a
clean submission, it waits the existing 30 seconds. Then it reads the boot at
most 60 times, each unchanged boot followed by five seconds. A changed second
or microsecond ends the poll, and exhaustion is a state failure.

A failed submission is unavailable, and no wait or read follows it. A failed
boot read stops the poll at once.

### The submission grammar

Apple's [shutdown.c](https://github.com/apple-oss-distributions/system_cmds/blob/main/shutdown/shutdown.c)
decides the clean stdout. On the `now` path, the command skips its fork and
prints `Shutdown NOW!`. It writes no `wall` text to stdout. It then prints
`System shutdown time has arrived` between CR LF pairs, with two BEL characters,
and calls `reboot3`. If that call returns, `finish(0)` exits 0.

The agent's stdout is a file, so both lines reach it at exit. The agent removes
the last CR LF, and BEL is not whitespace.

The lock failure path of `reserve_reboot` also exits 0, after the first line
only. The grammar refuses that output, so a refused reboot cannot start the
poll. `sudo -S` writes its prompt to stderr, which no grammar reads. No host can
run this command, so the grammar is source-only. The fetch kept no bytes, and
the guest build is not pinned to the revision that it read.

### Feasibility of a clean poll

k81 left one question: can the boot poll be clean at all? The source answers
it as follows.

- The tagged client makes one connection per request and retries nothing
  ([lib.rs](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-agent-client/src/lib.rs)).
  Thus each exec while the guest is down fails, and the adapter keeps it
  unavailable.
- The agent is a per-user LaunchAgent
  ([golden.rs](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/golden.rs)).
  The guest is therefore unreachable from the teardown of the old session
  until the autologin of the new one starts the agent.
- No boot through autologin fits one 5-second gap between two reads. A clean
  poll therefore needs the whole outage inside the 30-second wait.

Nothing in the source sets the length of that outage. Thus clean completion is
feasible, but its availability is an unmeasured race. The submission races the
teardown of the agent in the same way. The evaluation does not hold before E01
for this reason.

The protocol accepts that availability cost visibly: "restart may never supply
clean submission". A refused poll read stays unavailable, even if the boot later
changes. The restart runs only in the A slots, so this cost can stop the A set
after both E slots qualified.

This decision rests on source reading. A measured outage longer than 30
seconds would make clean completion demonstrably infeasible. That measurement
needs a guest, which this task does not permit.

## The diagnostic defaults write

The protocol keeps `KOINE_SETTINGS_TRACE` unset and permits no enabling
defaults write. `refuse_guest_trace_defaults` records that refusal as a failed
confirmation and latches the root. It sends nothing. k76 replaces the legacy
conditional write with this call, so a set variable stops the slot before the
first launch.

## Callers and their adoption

k76 replaces each caller and keeps its failure message. The
[k81 caller inventory](ordering-exec-read-evidence/callers.txt) lists each line.

| Caller | Adoption |
|---|---|
| `install_app`, `ditto -x` | `submit_guest_extraction`. The signature verification after it stays its confirmation |
| First launch, `guest_once "open ${INSTALLED}"` | `launch_guest_koine`, `await_guest_endpoint launch`, then `confirm_guest_launch` |
| Silent launch after setup | the same three calls, then the existing settling wait |
| Reopen of the running application | `launch_guest_koine`, then `confirm_guest_reopen` with the silent launch's record |
| `guest "open -a TextEdit" \|\| true` | `launch_guest_textedit`. The TextEdit window poll stays its confirmation |
| `guest "osascript … quit saving no" \|\| true` | `quit_guest_textedit` |
| `BOOT_BEFORE`, the restart, `sleep 30` and the boot loop | `read_guest_exec ROOT evidence OP boot`, then `restart_guest` with that record |
| `grant_system_events_automation`, the background request | `request_guest_automation`. The Allow prompt and `expect_guest_system_events` stay its confirmations |
| `grant_accessibility`, the pane `open` | `open_guest_accessibility_pane`. The Add button poll stays its confirmation |
| `KOINE_SETTINGS_TRACE=1` defaults write | `refuse_guest_trace_defaults` |

The protocol adds one identity read after each launch and the reopen, and one
absence read after the TextEdit quit. No other read, wait or retry is added.
The restart keeps its existing wait, read bound and delay.

## Controls and provenance

The [baseline run](ordering-one-shot-evidence/baseline-red.txt) runs the 16 new
controls against legacy semantics, with the
[baseline script](ordering-one-shot-evidence/baseline.sh). The scratch tree
takes `scripts/` from the parent revision. Test-only wrappers replay each legacy
one-shot caller. All 16 controls fail, and each failure has a legacy cause.
For example, a failed `open` returns 0, and a quit has no absence read. A
restart continues after a failed submission, and a boot poll retries a refused
connection.

The [first baseline run](ordering-one-shot-evidence/baseline-run-1.txt) failed
three restart controls on a fixture artefact. The legacy `guest` merges stderr
into the boot value, and the fixture added a synthetic stderr line. A real
successful `sysctl` writes no stderr, so the fixture now writes none for it. One
test of the second run did not stub `sleep`, so its legacy run slept for real.
That run was stopped, and it left no receipt. The test now stubs `sleep`.

The shared fixture now reads each answer as bytes. Its earlier text read
changed CR LF to LF, so it could not carry the `shutdown` output.

The [mutation receipt](ordering-one-shot-evidence/mutations.jsonl) disables one
guard at a time in an isolated copy, with the
[mutation instrument](ordering-one-shot-evidence/mutate.py). Seven of the eight
mutations fail the control that they name. M04 removes the early return after a
failed TextEdit quit, and it survives. The failed quit latches the root, so the
absence read refuses without dispatch. Thus the backend latch, not the early
return, enforces that rule.

The [host suite](../../../Tests/scripts/vm-exec-one-shot-host.bats) runs the
identity command through `/bin/bash -c`, as the agent does. A temporary HOME
holds a descriptor that names a host `sleep` process. The real `pgrep`,
`python3`, `proc_pidinfo` and `proc_pidpath` answer. The record names
`/bin/sleep`, and its start second equals the start that `ps` prints. An exited
process gives `process: null`. No submission runs on the host, so the suite
checks only the bash syntax of each command.

The host is macOS 27.2.1 (26B131). It is not the guest, so the host suite
proves no guest output.

The [green run](ordering-one-shot-evidence/final-verification.txt) runs 17
Taskfile checks with the k81
[measurement instrument](ordering-exec-read-evidence/measure.py). They are the
two new checks and the 15 checks that share the backend, the read table or the
fixture. They pass 269 tests with no failure, and each of the 4462 subjects
stayed the same during the run. The
[run record](ordering-one-shot-evidence/final-verification.txt.json) keeps the
manifest digests.

Run `mise exec -- task check:vm-exec-one-shot-evidence`. The host evidence runs
with `mise exec -- task check:vm-exec-one-shot-host`.

## Limits

The submission grammars follow the source and the tagged agent. A guest that
prints another form holds the harness visibly as unavailable. The restart
grammar rests on an unpinned revision of `shutdown.c`.

The identity read cannot exclude a PID reuse between `pgrep` and the kernel
read, other than through the PID join. The executable path is the kernel's path
of the launched file. It proves no signature, which the k81 reads keep.

A clean submission of `open` proves that LaunchServices accepted the request.
The confirmations prove the launch. A clean background submission proves only
that bash started the job.

The boot poll can be clean only if the guest's outage fits the 30-second wait.
Its length is unmeasured. A refused read stops the slot, and it says nothing
about the product.

Guest output and the restart command can contain secrets, so the whole evidence
root stays private. Do not publish or commit it.

## Remaining duties

k76 owns complete adoption, signals and both held-pointer controls. k67 owns
the positive setup, the title audit and the window consequences. k62, k57 and
k54 keep their original duties.

The availability limits stay binding: the missing snapshot tree, the empty
AXValue and the OCR substring stop. The private secret-bearing roots stay
private. Every original criterion of k75, k71 and k66 survives. No VM,
candidate, freeze, acceptance or ancestor closure follows.
