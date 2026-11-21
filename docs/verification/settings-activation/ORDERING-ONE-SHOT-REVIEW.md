# Checked one-shot submission review

Review `settings-exec-one-shots-k157` inspected producer
`b3065ae151186d8430c98472d0b9dd521a7aca34` against parent
`58a1f7b274a1d4b9731b977001e523869e1ff68a`. Two findings need integration
triage before k76 consumes the helpers. They concern a failed identity
observation reported as a clean absence, and a failed reboot request that has
the accepted submission payload. Neither establishes a guest occurrence or a
Koine failure.

This review changes no production or test code and runs no test, build, lint,
format or guest command. It inspects the committed changes, the inherited
contracts, the current protocol, the prior review integrations and retained
receipts. There is no VM, candidate, freeze or native acceptance.

## P2-1: An executable-path failure becomes a clean absent process

`scripts/vm_exec_reads.py:857-872` converts a zero `proc_pidpath` result with
`errno == ESRCH` to `None`. If either process-info read or the path read gives
`None`, the script prints `process: null` and exits zero. It discards any
successful process-info observations in that case. The parser then publishes
a clean record, and `confirm_guest_launch` at
`scripts/vm-exec-one-shot-evidence-lib.sh:52-57` returns the clean mismatch
status 1 without latching unavailable.

Apple's [kernel path implementation](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/proc_info.c#L1378-L1490)
can return ESRCH for executable-vnode acquisition, reference, recycling or
unmount failures. It does not restrict that error to a nonexistent PID. The
[user-space wrapper](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/wrappers/libproc/libproc.c#L263-L282)
turns the failed syscall into zero while retaining errno. Thus ESRCH from
the path call alone cannot establish process absence. This is source evidence;
the pinned guest's frequency of these conditions is unknown.

A concrete source-derived case has both `info()` calls return the same live
PID and start time, while `path()` returns zero with ESRCH. The script still
prints `process: null`, and the host parser accepts it. The required
executable identity is unavailable, but the result says that the process is
absent. The protocol distinguishes a clean setup mismatch from missing
identity evidence. That distinction must survive this helper; the existing
comments and report assert a stronger meaning for ESRCH than its source gives.

The host suite checks a live `/bin/sleep` and a process that has fully exited.
It does not cover a live process-info pair with a failed path observation.
The synthetic suite starts with the final JSON record, after this decision
has already happened. Its `process: null` control therefore cannot challenge
the decision, and M05/M06 mutate only the later selection/path comparisons.
Integration needs to settle this classification and controls before adoption.

## P2-2: A rejected reboot request has the accepted submission payload

`scripts/vm_exec_reads.py:975-993` accepts exactly the two shutdown lines and
returns `submitted: true`. The shared adapter also requires the complete
successful exec envelope and guest exit zero. Those requirements reject
transport failures and the earlier reboot-lock refusal, but they do not
distinguish every failure in the cited command.

Apple's [shutdown implementation](https://github.com/apple-oss-distributions/system_cmds/blob/408bba7453608006b89772db185defbac8fe2fd0/shutdown/shutdown.c#L483-L582)
prints both accepted lines before calling `reboot3`. A nonzero return logs a
failure to syslog, then reaches `finish(0)`. The
[finish function](https://github.com/apple-oss-distributions/system_cmds/blob/408bba7453608006b89772db185defbac8fe2fd0/shutdown/shutdown.c#L725-L731)
exits zero. That failure has the same stdout and exit status as the accepted
submission. The tagged agent's file capture and whitespace removal preserve
this collision. No guest occurrence is asserted.

Consequently, a failed request can produce a clean `read.json` and leave the
root eligible. `restart_guest` at
`scripts/vm-exec-one-shot-evidence-lib.sh:111-117` then waits and polls. With
an unchanged boot, the eventual result is state-failed exhaustion rather than
an unavailable submission. The changed-boot requirement still prevents an
ordinary pass on an unchanged boot; this finding does not claim otherwise.

The protocol requires a clean submission independently of its downstream
confirmation, and forbids a later observation from rehabilitating a failed
submission. The present grammar cannot certify that the reboot request was
accepted. Integration must decide whether this is an implementation gap or
an unclear meaning of submission in the contract. Any necessary amendment
belongs before E01; this review authorizes no relaxed rule, new guest, retry,
delayed shutdown or alternative reboot route.

The controls inject nonzero guest exits, transport errors, timeouts and an
incomplete shutdown banner. None represents the source's failed `reboot3`
branch, which has zero exit and the complete banner. M01 changes the stdout
comparison, and M03 changes continuation after a known failed envelope. Both
can fail their controls while this indistinguishable branch remains.

## Inspection of the remaining contract

The immutable TestAnyware v2.7.0 source supports the outer exec checks. The
agent runs `/bin/bash -c`, waits for that process, captures its streams in
files and removes trailing whitespace. The CLI's JSON mode can exit zero
with a nonzero guest exit inside the envelope; the adapter checks both.
The seven submission commands match their legacy callers. Empty stdout is
only the submission grammar: installation signature checks, the TextEdit
window check, the Allow prompt/System Events check and the Accessibility Add
button remain required consequences. The background shell's completion alone
does not certify successful child execution or Automation consent.

The SDK declarations and `proc_bsdinfo` field sequence match the ctypes
structure, including the final two 64-bit start fields. The kernel path
comes from the executable vnode, rather than mutable argv[0]. The two start
observations surround that path read. Subject to P2-1, the normal joined case
checks the descriptor PID, the sole selected PID and the installed executable
path. A second selected PID or another executable fails the join. The reopen
comparison includes the instance, PID, microsecond start and executable.
The disclosed gap between `pgrep` and the first kernel observation remains;
there is no claim of an atomic identity snapshot or of signature verification
by this path read.

The TextEdit quit submits once and makes exactly one absence read after a
clean submission. A process still exiting can yield clean presence and stop
setup. This availability cost is explicit and follows the protocol's one-read
rule. No additional wait or read is justified by this review.

The restart retains the legacy 30-second wait, sixty-read bound and
five-second delay after each unchanged read, including the final one. A
failed poll stops immediately. The tagged client connects once per request,
and the agent is installed as a per-user LaunchAgent. Source supplies no boot
or autologin duration, and does not demonstrate that a clean transport
completion is impossible. It also does not establish that completion is
feasible on the guest. The report's categorical claim that no outage can fit
a five-second gap has no timing evidence; retain an unknown timing boundary,
not that assertion. This does not independently change the protocol's hold
threshold. P2-2 concerns a separate semantic limitation of the submission.

Each submission is restricted to the one-shot class, and the identity read
is excluded from the evidence class because Python can raise a setup prompt.
The facade uses the shared backend's lock, prior-receipt inspection, latch
and ordinal allocation. A failed exec envelope prevents subsequent scenario
dispatch. The diagnostic defaults facade records a refusal and sends nothing.
These controls do not supply k76's complete signal and caller adoption.

The inherited duties retain these owners:

| Duty | Owner after this review |
|---|---|
| Checked exec state, endpoint/boot reads, persistent defaults, installed inventory and collection classification | k81, with caller placement by k76/k57 |
| System Events outputs, their existing polls and enrolment | k151 and its completed k156 integration |
| One-shot submissions, launch/reopen identity, TextEdit absence and restart confirmation | k152, subject to this review's integration |
| Exact-root adoption before every transport, whole TextEdit-loop replacement, status/signal propagation and both held-pointer controls | k76 |
| Earlier UI, physical, snapshot, click, capture, file and lifecycle helpers | Their reviewed existing artifacts, including k89; complete adoption remains k76 |
| Positive setup/title/liveness, exact prefix, finite caller/audits and readiness/runtime | k67, k62, k57 and k54 respectively |

The keepalive withdrawal is the explicit accepted amendment. No missing-tree,
empty-AXValue, selector, OCR, private-evidence, original ordinary assertion or
held-input requirement is removed by the one-shot handoff.

## Recorded controls and source provenance

The retained second baseline has sixteen failed controls. Its failures expose
legacy ignored statuses, missing receipts/confirmations and continued polling
after failure. The first baseline's three restart artefacts remain recorded.
Changing the fixture to byte decoding preserves internal CR characters as
the agent's capture does. Suppressing synthetic stderr for a successful
`sysctl` removes text that previously made the legacy boot comparison finish
early. The descriptor-presence adaptation also keeps the legacy test wrapper
consistent with the new identity answer. These are fixture changes, not guest
measurements.

The retained mutation receipt has seven detected mutations and one survivor.
M04's survivor is explained by the backend latch refusing the later absence
read; it is not evidence that the early return itself was tested. The two
findings above concern decisions that none of those mutations challenges.

The retained green log contains seventeen Taskfile checks and 269 TAP tests.
Its SHA-256 equals the run record. Recomputing the manifest digest with the
measurement instrument's canonical serialization also matches the record.
The six changed executable subjects still equal their individual manifest
digests: the facade, read table, two Bats suites, shared fixture and Taskfile.
This verifies provenance of the earlier run, not a new passing run. No test
command was executed during review.

The producer's four TestAnyware object digests match direct reads at tag
v2.7.0, commit `65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03`. Its two SDK header
digests match the current files at the recorded SDK path. Apple source used
for these findings is pinned in the links above and in the
[review source receipt](ordering-one-shot-review-evidence/sources.json).
Those revisions are not a provenance claim about the guest binaries.

Tier 2 graph discovery used generation `2026-11-21T15:44:30Z`. Exact coverage
checks reported shell parse gaps and untracked Bats metadata; direct source
reads covered those files and ranges. The external TestAnyware index does not
describe the immutable tagged objects used here, so the review read those
objects directly. No exhaustive graph-completeness claim follows.

Integration belongs immediately before k76. It must triage these findings
against the contract and perform any required repairs and verification. This
inspection supplies no native availability, timing, acceptance or ancestor
closure.
