# Checked guest exec read review

Review `settings-exec-confirmations-k153` inspected producer `c3aa47c0`
(`settings-exec-confirmations-k81`) against parent `3a2c131e`. Two findings
need integration triage before k151, k152 or k76 consumes the helpers. They
concern the completeness of defaults and process evidence. Neither finding
establishes a Koine failure or a native occurrence of its counterexample.

This review changes no production or test code. It runs no test, build, lint,
format or guest command. It reads committed source, retained verification
receipts, immutable TestAnyware v2.7.0 source and primary Apple documentation.
No VM, candidate, freeze, native availability or acceptance follows.

## P2-1: The defaults read can declare diagnostics disabled while an omitted domain enables them

`scripts/vm_exec_reads.py:204-222` exports the application and global domains
for the current user, with any-host and current-host variants. It then reads
four managed-preference files. It does not read the ordinary any-user
application or global domains. Managed preferences are a separate source;
reading `/Library/Managed Preferences` does not cover the ordinary system-wide
preference domains.

Apple documents eight ordinary domain combinations, including four any-user
combinations, in its [preference-domain search order](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PreferencePanes/Concepts/Managing.html).
Apple's [standard Core Foundation search-list implementation](https://github.com/apple-oss-distributions/CF/blob/main/CFApplicationPreferences.c#L358-L435)
also adds the any-user application and global domains after the current-user
domains. This is documentary source evidence, not a measurement of the guest.
The missing sources are distinct from the argument and registration domains
that the producer assigns to launch and freeze inspection.

A concrete source-derived counterexample is an ordinary any-user application
preference containing `KoineSettingsActivationTrace` with a usable file path,
with that key absent from every collected source. All eight returned sections
can be complete, empty and grammatical. `defaults_parse` then computes
`diagnostics_disabled: true` at lines 298-308 because it considers only those
sections. Koine instead reads `UserDefaults.standard` at
`Sources/KoineApp/SettingsActivationTrace.swift:59-60`; a non-nil trace path
enters the enabled diagnostic branch. An omitted any-user global value or
buffer preference has the same coverage problem.

This violates the ordering protocol's Diagnostics and timing requirement:
trace and buffer keys must be absent from the effective defaults, including
conflicting global and managed values. It can admit an instrumented subject
under a false disabled-diagnostics result. The producer report's Diagnostic
defaults and Limits sections overstate the sources that its command covers.
Apple also lists language domains in the [NSUserDefaults search list](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AboutPreferenceDomains/AboutPreferenceDomains.html#//apple_ref/doc/uid/10000059i-CH6-SW3);
there is no completeness argument for excluding those from the broader claim.
This review does not assert that a language-domain diagnostic exists in the
pinned guest.

The defaults fixture at `Tests/scripts/vm-exec-read-evidence.bats:395-447`
builds only the same eight sections. Its clean-absence control and M9 mutation
check parsing and boolean treatment within that selected set. Neither can
expose a value in an uncollected ordinary domain. The retained host receipt
likewise shows only the collected sections. Before consumption, the effective
source coverage and its controls need a defensible complete boundary; an
empty selected set is insufficient evidence of effective absence.

## P2-2: A process can disappear without making the process read unavailable

`scripts/vm_exec_reads.py:118-128` obtains a PID set with `pgrep`, passes that
set to two separate `ps` commands and prints only the two `ps` outputs. The
original PID set is not part of the returned grammar. `process_parse` at
lines 138-163 checks agreement between the two returned blocks, but cannot
compare either block with the original selection.

The producer report says that a process exiting between the reads makes `ps`
fail and the read unavailable. That is not true for a multi-PID request.
Apple's [ps selection and exit implementation](https://github.com/apple-oss-distributions/adv_cmds/blob/main/ps/ps.c#L622-L788)
keeps each existing selected process, exits 1 if none remain, and otherwise
prints the retained rows and exits with its error accumulator. It does not
require every requested PID to remain present.

For example, let `pgrep` return PIDs 412 and 413, and let 413 exit before the
first `ps`. Both `ps` commands can return zero with only PID 412. Both blocks
then have one matching row, so the backend publishes a clean `read.json` and
keeps the root eligible. The selected population was incomplete without any
unavailable result. This counterexample follows from the command and parser;
it was not executed during this inspection.

This matters because the read is the planned basis for launch and process
identity, and the protocol rejects partial required observations. A consumer
cannot detect the dropped candidate from this record. The two-command join
also compares only PID: it does not establish that the start/executable row
and argument row came from the same process incarnation if the PID is reused
between those commands. A pattern match itself is not executable identity:
`pgrep -f` can select an unrelated process whose arguments contain the path,
and the patterns contain an unescaped dot. k152's promised exact executable
and descriptor join therefore remains necessary even after a grammatical read.
These observations do not establish that PID reuse or a foreign match occurred.

The process controls at `Tests/scripts/vm-exec-read-evidence.bats:323-353`
provide synthetic final text and one nonzero guest result. They do not execute
the command with a disappearing member of a selected PID set. M8 removes the
join between the two printed blocks; it cannot test the membership that the
command discards. The real host receipt has empty process arrays for both
patterns, so it supplies no positive evidence for this branch either.
Integration needs to resolve the completeness and incarnation boundary before
presenting this record as the required launch-identity input. The report must
also state the actual availability limitation. No retry, extra scenario read
or successful later observation is authorised by this finding.

## Inspection of the remaining contract

The tagged source was read from immutable TestAnyware commit
`65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03` (v2.7.0), using the local official
repository. `ProcessRunner.swift` runs `/bin/bash -c`, strips trailing
whitespace and reports a timeout with exit -1. `AgentServer.swift:431-455`
uses the non-detached path for these calls. The tagged CLI's `run_exec` emits
the command, streams, exit code and timeout in JSON and exits zero after a
successful exchange. These facts agree with the backend's required envelope
fields. A timeout, wrong command, nonzero CLI or guest failure does not reach
read qualification.

The other read grammars were compared with their fixed commands, the endpoint
schema and the retained host/manual evidence. Endpoint JSON rejects duplicate
fields and invalid typed fields. Inventory requires file rows, unique paths,
ordered file/link blocks and its completion marker. Setup parsers distinguish
codesign verification status 1 and assessment rejection status 3 from the
undocumented/error statuses. Different guest formatting fails closed. The
host's macOS 27.2.1 output does not qualify the pinned guest's macOS 27.0.1
output; the producer expressly keeps that availability limit. No additional
finding is made solely because the formats might differ.

The evidence class refuses generic exec and the two reads with guest effects:
`assessment` can update its cache, and `port-refusal` sends a request to a live
listener. The remaining fixed commands collect files, process, boot, signature
or preference facts. They accept no arbitrary command argument. No additional
input or mutating collection route was identified in this bounded table.

The lock is acquired in `run` before `run_locked` selects a read. It remains
held across dispatch, envelope validation, parsing, exclusive `read.json`
publication, stdout flush and terminal receipt publication. Evidence collection
uses the same ordinals and preserves an earlier latch. The changes do not
introduce an unlocked parse/publication path. This is source evidence; the new
controls add no barrier inside the parser itself. Existing contention and
orphan-child controls remain relevant.

`await_guest_endpoint` preserves the fifteen-by-two launch poll and its
state-failed exhaustion. Login preserves twenty-four-by-five, returns 1 on
clean exhaustion and creates no exhaustion latch, matching the old loop's
lack of a final assertion. Each negative retains its existing sleep, including
the last one. A read or local sleep error stops the helper. k76 still owns
complete caller adoption and signals. The boot helper supplies one read only;
it does not decide restart feasibility. That question is explicitly retained
by k152, together with clean restart submission. No new wait or tolerated
transport status has been selected.

The caller inventory over-reports reachability because it also matches prose.
The producer identifies that limit and corrects the six falsely reached helper
names by inspection. The source surface retains ownership of state reads in
k81, System Events/enrolment in k151, submissions and consequences in k152,
and adoption, statuses and both held-pointer controls in k76. k67, k62, k57 and
k54 retain positive setup, prefix/duty reconciliation, finite caller/audits and
freeze/runtime. TextEdit process absence is still a k152 completion duty; the
closed process table currently accepts only the two Koine patterns. No claim
that this slice already implements that absence is credited.

The eight older adapter-test edits either use read-poll to exercise generic exec
validation or use a checked boot read where evidence collection is required.
The contention assertions still require the competing-writer reason. The two
capture-test edits add the new imported module to their isolated backend
copies. They do not change capture assertions.

## Retained verification and limits

Fresh read-only digest comparisons matched the final and earlier output files
and their subject manifests to the recorded digests. All nine compared current
implementation, facade, fixture, suite and Taskfile inputs match the final
manifest. All three tagged source objects match `official-source.json`.

The producer's final receipt records thirteen Taskfile checks and 213 passing
tests. Its earlier receipt retains the two failed isolated capture tests. The
baseline records 21 failing controls, several ending at absent records rather
than reaching every later malformed-payload variant. Eleven retained mutations
fail their named controls; the report discloses the initially surviving
whitespace mutation and its replacement control. These are retained producer
results, not tests rerun or newly certified by this review. They do not
cover the two counterexamples above.

The measurement script digests tracked and nonignored untracked working-copy
files and compares before/after manifests. Ignored outputs, installed tools and
runtime state are outside that set. The host grammar receipt additionally
assumes its installed bundle and host state. Source hashes and tool versions
do not establish continuous native-state identity. The old documentation
check remains failed on the two archived links assigned to k23.

Graph evidence used Tier 2, project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, coverage
generation `2026-11-21T13:13:50Z`. Bounded symbol searches and the run_locked
trace were read without pending pagination. The trace contains unrelated
cross-language edges; they are not credited as calls. Coverage reports partial
shell ranges in the exec facade and scenario/helpers, and untracked Bats
metadata. Direct source reads cover those files and the reported ranges.
Graph counts supply no exhaustive caller or correctness claim. External tagged
source was read directly, rather than attributed to a mutable graph generation.

The archived k75, k71 and k66 contracts and current additive briefs retain all
other duties. Missing snapshot trees, omitted AXValue, OCR substring stopping,
private secret-bearing roots, the stopped-golden audits and every runtime hold
remain binding. No ancestor closes through this review. The findings live in
this review's commit; the immediate integration task independently triages them.
