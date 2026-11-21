# Checked guest exec reads

k81 supplies source-only checked reads for the exec state of the Settings
harness. Each read sends one fixed guest command and parses its stdout with an
exact grammar. A clean read prints a parsed record, and the root keeps the raw
bytes. The reads use the shared writer domain of the
[shared adapter](ORDERING-NONEXEC-RESULTS.md): one lock, one latch and one
ordinal sequence.

No ordinary caller or scenario root changes. No VM, signed candidate, frozen
subject, native availability or product acceptance follows. An independent
review and every earned integration come before k151, k152 or k76 consumes this
work. The [ordering protocol](ORDERING-EVALUATION-PLAN.md) and the reviewed
[transport](ORDERING-TRANSPORT-RESULTS.md),
[file and lifecycle](ORDERING-FILE-LIFECYCLE-RESULTS.md) and earlier contracts
stay binding.

## Split of the exec duty

k81 owned every remaining exec and one-shot confirmation. This leaf keeps the
first slice: the state reads, the caller inventory and the classification of
free collection commands. settings-system-events-evidence-k151 owns the System
Events and enrolment outputs. settings-exec-one-shots-k152 owns each one-shot
submission and its downstream confirmation. The caller table below names the
owner of each exec line.

## Interface

Source [the exec read facade](../../../scripts/vm-exec-read-evidence-lib.sh).
Sourcing only defines functions. Each call needs a root that
`init_guest_evidence` initialised.

| Function | Result |
|---|---|
| `read_guest_exec ROOT CLASS OPERATION NAME [ARGUMENT]` | One checked read. A clean read prints its record as one JSON line. Every failure returns nonzero and latches the root. |
| `await_guest_endpoint ROOT OPERATION launch` | The `await_koine` poll: 15 reads, each negative followed by `sleep 2`. Exhaustion is a state failure. |
| `await_guest_endpoint ROOT OPERATION login` | The descriptor loop after the restart: 24 reads, each negative followed by `sleep 5`. Exhaustion returns 1 and latches nothing. |

CLASS is `read-poll` or `evidence`. The one-shot class is a parser error,
because a read sends no input. A read-poll read refuses after a latch. An
evidence read stays callable after a latch, collects context only and never
clears the latch.

The backend action `read` builds the command from the
[read table](../../../scripts/vm_exec_reads.py). No caller can name another
guest command through it.

## The reads

The tagged agent runs each command with `/bin/bash -c`. It strips trailing
whitespace from stdout
([ProcessRunner](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/agents/macos/Sources/TestAnywareAgent/ProcessRunner.swift)).
Thus no grammar ends in a newline, and stdout with trailing whitespace is
unavailable. The exec envelope checks of the shared adapter apply first: CLI
status 0, `ok`, the exact command, `timed_out` false and guest exit 0.

| Read | Guest command | Clean payload | Evidence class |
|---|---|---|---|
| `endpoint` | test and `cat` of the descriptor | `ABSENT`, or `PRESENT` and the version-1 descriptor with its six exact fields | yes |
| `process executable` | `pgrep -f '/Applications/Koine.app/Contents/MacOS'`, then two `ps` reads | `NONE`, or the selected PID set, identity rows and argument rows with exactly those PIDs and the same start times | yes |
| `process bundle` | the same with `/Applications/Koine.app` | the same | yes |
| `boot` | `sysctl -n kern.boottime` | the `{ sec = S, usec = U } DATE` structure | yes |
| `port-refusal PORT` | the legacy `curl … ; echo $?` | one curl exit status from 0 to 255 | no |
| `defaults` | `defaults export` of eight domains and the managed preference files | twelve exact sections, each an XML property list or an absent file, and a completion marker | yes |
| `installed-inventory` | the legacy inventory command, unchanged | SHA-256 file rows, then symbolic-link rows, then `KOINE_INVENTORY_COMPLETE` | yes |
| `system` | `sw_vers; uname -m` | the `sw_vers` fields and one architecture | yes |
| `gatekeeper` | `spctl --status` | `assessments enabled` or `assessments disabled` | yes |
| `quarantine` | `xattr` list, then the attribute value if present | `ABSENT`, or `PRESENT` and one value line | yes |
| `signature` | `codesign --verify --strict --deep --verbose=2` and its status | status 0 with the two result lines, or status 1 with a diagnostic | yes |
| `signature-display` | `codesign --display --verbose=2` | one executable, identifier, team and code directory, and an authority | yes |
| `assessment` | `spctl -a -vv` and its status | status 0 `accepted` or status 3 `rejected` | no |

A negative domain fact is a clean payload. An absent descriptor, no process,
curl status 7, an absent defaults key, a failed signature verification and a
rejected assessment are data. The caller asserts the expected value. A failed
transport, a guest nonzero exit, a timeout or a grammar mismatch is unavailable,
never a negative.

The process read joins `pgrep` and two `ps` reads. By default, `pgrep` excludes
its ancestors, so the bash wrapper does not match its own pattern. A host
control demonstrated this. `ps` runs with `LC_ALL=C`, because the start-time format
depends on the locale.

The command prints the `pgrep` selection before the two
`ps` blocks. Each block must hold exactly the selected PIDs. Each row pair must
agree on PID and start time. Thus a selected process that exits before either
`ps` read makes the read unavailable. The record keeps the selection, and each
row keeps `argv0`, `started` and `arguments`. The `comm` column prints argv[0],
which the process sets, so `argv0` is not the executable path.

The status reads keep each tool's documented clean statuses as data. `codesign`
0 and 1 are clean. 2 is an argument error, and 3 needs `-R`, so both are
unavailable. `spctl -a` 0 and 3 are clean. 1, 2 and 4 are unavailable.

The `spctl(8)` page documents only exit 0 for `--status`. A disabled subsystem with
another status is therefore unavailable, which holds the harness visibly.

## Diagnostic defaults

The protocol needs `KoineSettingsActivationTrace` and `KoineSettingsEventBuffer`
absent from the effective defaults, and `KoineSettingsMenuProbe` absent or
false. A failed `defaults read` is not an absence. `defaults export` prints an
empty dictionary for an absent domain, so the read exports each domain. These
are the four current-user domains: the application and global domains, for any
host and for the current host. The read also exports the four any-user domains
by path. They are `/Library/Preferences/dev.antony.Koine` and
`/Library/Preferences/.GlobalPreferences` for the current host, and the same
names in `/Library/Preferences/Network` for any host.

The read also covers four managed preference files: the computer and user files
of the application and global domains. An absent managed file is a clean
`KOINE-ABSENT` section. The backend parses each property list with Python's
`plistlib`. A JSON conversion fails on date and data values, so the guest does
not convert.

CFPropertyList writes C0 control characters in strings without an
escape, and XML 1.0 forbids them. The parser replaces each such character with
U+FFFD. No diagnostic key name or tag holds one, so the presence of a key stays
exact.

<!-- tc: depart synonym-rotation because the application launch and the VM restart are different operations -->
The record lists each source and the diagnostic keys that it holds. It sets
`diagnostics_disabled` only when no source holds the trace or buffer key, and
each probe key is the boolean false. A string such as "0" is not admitted as
false. The argument domain comes from the process read. The one-shot leaf joins
it to the identity of the application launch.

## Free collection commands

The k36 brief needs each free exec collection command classified as read-only.
A generic `run` in the evidence class now refuses before dispatch, and the
refusal latches the root. The adapter cannot know whether an arbitrary guest
command sends input. Collection after a latch therefore uses only the checked
reads that the table marks read-only.

Two reads are read-poll only. The `spctl(8)` page says that an assessment
stores its outcome in the assessment cache unless `--no-cache` is given, and the
legacy command has no `--no-cache`. The port read sends an HTTP request to any
live listener on the old port. The other reads only read files, process tables,
sysctl values, signatures and preferences.

Eight existing adapter tests used the generic evidence route. They now use the
read-poll class, or a checked read where the test needs collection after a latch
or a competing writer. The competing-writer and orphan-lock tests still refuse
for the competing writer.

## Records

Each read keeps the existing records of the shared adapter: `request.json`,
`raw.stdout`, `raw.stderr`, `cli.exit`, `guest.stdout`, `guest.stderr` and
`result.json`. The request records the transport `read`, the read name, its
arguments and the exact command. Only a qualified read writes `read.json`. The
printed line is that record. The poll steps keep the reviewed `poll-step`
receipts. Their generic reason text still says "window poll", and the
structured fields govern.

## Actual callers

The [caller inventory](ordering-exec-read-evidence/callers.txt) lists every
exec line on the Settings scenario surface with its enclosing function. A
function is reached when the scenario's top level calls it, or a reached
function calls it. The instrument matches names in command position, so prose
can over-report. By inspection, the scenario calls none of `client`, `desktop`,
`focus`, `launch`, `place_window` and `show_window`.

A dynamic call is not seen. The positive control found the one exec line in
`guest_once`, and a mutated pattern found nothing.

| Caller | Owner and adoption duty |
|---|---|
| `await_koine` descriptor poll | k81 `await_guest_endpoint launch`. k76 replaces the loop once. |
| `expect_stopped` process and descriptor reads | k81 `process executable` and `endpoint`. k152 owns the quit confirmation that uses them. |
| `record_installed_bundle` | k81 `installed-inventory`. k76 replaces the overwriting write. k57 owns the comparison and the audits. |
| `BOOT_BEFORE` and the boot poll | k81 `boot`. k152 owns the restart and its poll. |
| Login descriptor loop | k81 `await_guest_endpoint login`. k76 replaces the loop once. |
| Login `pgrep -lf` assertion | k81 `process bundle`. |
| `PORT` read | k81 `endpoint`. The descriptor record carries the port, so no read is added. |
| Port refusal loop | k81 `port-refusal`. A clean read is never empty, so the loop ends at its first clean read. |
| `_start_vm` system and Gatekeeper records | k81 `system` and `gatekeeper`. |
| `install_app` quarantine, signature, display and assessment | k81 `quarantine`, `signature`, `signature-display` and `assessment`. |
| Defaults before the first launch, after the restart and after the slot | k81 `defaults`. The protocol adds these reads. k76 and k57 place them. |
| `enrol` through `guest_json` | k151. |
| `sysevents` and its callers | k151. |
| Trace defaults write | k152. The protocol permits no enabling write. |
| The three `guest_once` opens | k152: first launch, silent launch and reopen. |
| TextEdit launch and quit | k152. |
| The restart submission | k152. |
| `ditto -x` extraction | k152. |
| Background automation request | k152. |
| Accessibility pane open | k152. |
| `guest`, `guest_text`, `guest_json` and `guest_once` | k76 retires them from the Settings scenario. The protocol admits no twelve-attempt path. |

## The boot poll after the restart

The protocol keeps the existing 30-second wait and the 60-by-5-second poll for
the changed boot. Each poll read must be clean. While the guest restarts, the
agent can refuse the connection. A refused connection is a transport failure,
so the slot stops. The legacy `guest` retried such a failure inside each poll.

Thus a clean changed-boot poll may be infeasible. This leaf supplies the boot
read and decides nothing about the restart. k152 carries the question. It must
decide from source evidence whether a clean poll is feasible. If clean
completion is demonstrably infeasible, the evaluation holds before E01 for a new
decision.

## Controls and provenance

The [baseline run](ordering-exec-read-evidence/baseline-red.txt) runs the 21
new controls against legacy semantics. The
[baseline script](ordering-exec-read-evidence/baseline.sh) takes the backend and
facade from the parent revision and the new suite from the working copy.
Test-only wrappers replay the legacy `guest` and `guest_text` semantics. All 21
controls fail, and each failure has a legacy cause. Examples are no receipt, no
record, a failed read taken as a negative, a timeout accepted and generic
evidence exec dispatched.

The [green run](ordering-exec-read-evidence/final-verification.txt) runs 13
Taskfile checks: the new check, the host check and the 11 checks that share the
backend. They pass 213 tests with no failure. The fixture CLI is synthetic. The
backend, lock, receipts, parsers and jq are real. No VM, agent or golden image
is contacted. The [measurement instrument](ordering-exec-read-evidence/measure.py)
digests every working-copy file before and after the run, and the subjects
stayed the same.

The [first measured run](ordering-exec-read-evidence/verification-run-1.txt)
failed two capture tests. Each test copies the backend into an isolated
directory with its sibling modules, and the backend now imports the read table.
The tests now copy that module too. The receipt of the failed run stays.

The [mutation receipt](ordering-exec-read-evidence/mutations.jsonl) disables one
guard at a time in an isolated copy, with the
[mutation instrument](ordering-exec-read-evidence/mutate.py). Each mutation
fails its named control. The first run of the trailing-whitespace mutation
survived. Its control used `ABSENT`, which the exact comparison already
rejects. The control now covers a descriptor and a signature display, where only
the whitespace rule rejects the answer.

The [host grammar run](ordering-exec-read-evidence/host-grammar.txt) runs each
state-free read on this Mac through `/bin/bash -c`, as the agent does. Each real
output parsed. That run first found a defect: the signature wrapper added a
second newline before its status marker. The host is macOS 27.2.1 (26B131), the
pinned host version. It is not the guest, so this run proves no guest output.

The [source receipt](ordering-exec-read-evidence/official-source.json) records
the tagged agent and CLI objects and the host manual pages that decide the
grammars and statuses.

Run `mise exec -- task check:vm-exec-read-evidence`. The host evidence runs with
`mise exec -- task check:vm-exec-read-host`, and it needs an installed
`/Applications/Koine.app`.

## Limits

Every grammar follows the tagged agent and host output. A guest that prints
another format holds the harness visibly as unavailable. The process read
cannot see a process that the two patterns do not match. The defaults read
covers the eight persistent domains of the standard search list and the four
managed preference files. The argument, registration and volatile domains live
in the process. The process read carries the argument domain, and source
inspection at the freeze owns the registration and volatile domains.

The descriptor read proves the file at the moment of the read. The one-shot leaf
joins it to the process identity. A read that is unavailable stops the slot. It
says nothing about the product. Guest output can contain secrets, so the whole
evidence root stays private. Do not publish or commit it.

## Review integration

<!-- tc: depart synonym-rotation because "fixed" means set in advance, and "repair" names the correction of a defect -->
The independent review is in
[ORDERING-EXEC-READ-REVIEW.md](ORDERING-EXEC-READ-REVIEW.md). k154 checked each
finding against the source and primary sources, and repaired both. The
[k154 evidence](ordering-exec-read-integration-evidence/) keeps the receipts.
The earlier receipts of k81 stay unchanged.

### P2-1: omitted any-user defaults domains

Disposition: a real issue, and an overstated contract in this report. Apple's
[CF search list](https://github.com/apple-oss-distributions/CF/blob/main/CFApplicationPreferences.c#L391-L436)
adds four any-user domains after the four current-user domains.
[CFPreferences.c](https://github.com/apple-oss-distributions/CF/blob/main/CFPreferences.c#L181-L512)
puts the current-host files in `/Library/Preferences` and the any-host files in
its `Network` directory. The [source receipt](ordering-exec-read-integration-evidence/host-sources.txt)
keeps the digest and the decisive lines of each file.

On the host, `UserDefaults.standard` returns `MultipleSessionEnabled`. Only the
any-user global file holds that key. The host volatile domains are the argument
and registration domains only. The host runs macOS 27.2.1, so these facts are
not guest evidence.

The read now exports the four any-user domains by path. The report claim is
narrower: twelve persistent sources, with the argument, registration and
volatile domains outside the read. Language domains have no documented path in
the CF source, and the read makes no claim about them.

The repair found one more defect on the host. The any-user global domain holds a
time-zone string with raw control characters, and `plistlib` refused it. A guest
with a time zone probably holds the same key. The parser now replaces each
forbidden character before it parses.

### P2-2: lost process selection

Disposition: a real issue. Apple's
[ps source](https://github.com/apple-oss-distributions/adv_cmds/blob/main/ps/ps.c)
keeps each selected process that exists and exits 1 only when none remains. The
host receipt records `ps -p` with one live and one exited PID exiting 0.

The command now prints the selection, and the parser requires each `ps` block
to hold exactly that set. Both blocks print the start time, and each row pair
must agree on it. A disappearing member is unavailable, with no retry.

Apple's [ps print source](https://github.com/apple-oss-distributions/adv_cmds/blob/main/ps/print.c)
prints argv[0] in the `comm` column and skips the saved executable path. The
field that k81 named `executable` is therefore `argv0`. No consumer read it.

These limits stay. The start time has one-second resolution, so a PID reuse in
the same second between the two `ps` reads is not excluded. A reuse between
`pgrep` and the first `ps` is not excluded. Neither the pattern match nor
`argv0` is an executable identity. k152 keeps the join of the descriptor, the
process, its executable and its start time, and it needs another source of the
executable path. The k152 task records this.

### Controls of the repairs

The [baseline](ordering-exec-read-integration-evidence/baseline-red.txt) runs
the repaired suites with the read table of revision 7627bb06. Eight controls
fail. Two host controls run the real commands with one stub each, and they
reproduce both counterexamples. The old process read published a clean record
of one PID from a selection of two. The old defaults read returned
`diagnostics_disabled: true` while the any-user domain held the trace key.

The other six failures come from the new grammars. Two new synthetic controls
pass against the old table, because it rejects the new selection line. Their
power comes from the mutations below, not from the baseline.

The [mutation receipt](ordering-exec-read-integration-evidence/mutations.jsonl)
disables one repair at a time with the
[mutation instrument](ordering-exec-read-integration-evidence/mutate.py). Each
of the five mutations fails its named control. Without the replacement of
control characters, the real host reads fail too.

The [final run](ordering-exec-read-integration-evidence/final-verification.txt)
uses the k81 [measurement instrument](ordering-exec-read-evidence/measure.py).
The same 13 Taskfile checks pass 219 tests with no failure. Every subject stayed
the same during the run. The documentation check still fails on the two archived
links that k23 owns.

## Remaining duties

k151 owns the System Events and enrolment outputs. k152 owns each one-shot
submission, its confirmation and the restart poll question. k76 owns complete
adoption, signals and both held-pointer controls. k67, k62, k57 and k54 keep
their original duties.

The availability limits stay binding: the missing snapshot tree, the empty
AXValue and the OCR substring stop. The private secret-bearing roots stay
private. Every original criterion of k75, k71 and k66 survives. No VM,
candidate, freeze, acceptance or ancestor closure follows.
