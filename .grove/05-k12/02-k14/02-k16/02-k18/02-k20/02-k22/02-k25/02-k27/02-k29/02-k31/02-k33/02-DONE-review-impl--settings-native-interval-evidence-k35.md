# settings-native-interval-evidence-k35

**Reviews:** settings-native-interval-evidence-k34

## Goal
Adversarially inspect the committed native-call recorder and revised causal
protocol against the original k33 requirements before new runtime work.

## Context
Read the producer commit/diff, CAUSAL-PLAN.md/CAUSAL-RESULTS.md, retained raw native
rendering/reproduction, primary API evidence and parent brief chain. Re-derive
material evidence/contract claims from sources; the earlier in-session review is
not this review's charter. No guest or product repair has been qualified.

## Done when
- Check exact-one-call behavior, native-tick enclosure, opt-in metadata/bypass,
  exact encoding and error state, unchanged show/activation order, observer work
  and coverage of the headless controls against the real call-site integration.
- Determine whether the intervention and its necessary-condition predictions are
  independently supported and falsifiable with common mouse-open/foreground
  context and changing timing. Check the actual positive manipulation/clock/
  native-disposition qualification gates and every cap/freeze/transport/cleanup
  obligation. Identify a concrete unusable inference rather than requesting an
  unbounded failure chase or treating alternative-input success as repair.
- Check every original causal, justified product repair/useful failing-seam and
  separate frozen complete ordinary-acceptance duty survives the boundary.
- Produce findings only, with material uncertainties explicit. Do not run GUI/VM
  work or alter source/protocol. If integration is needed, insert it before the
  live settings-modality-disposition-repair-k36 sibling; do not let runtime work
  intervene between review and integration.

## Decisions (running log)
- 2026-10-28: Adopt the mandated review-impl leaf. The jj working copy is
  empty on ac5e03b8, the k34 producer commit. The graph server does not connect,
  so this review uses direct source and evidence reads. It runs no test, build,
  guest or VM work.
- 2026-10-28: The review reads the full saved rendering by its committed gzip,
  decompressed into the session scratchpad. Every tick and line in the
  CAUSAL-RESULTS.md table matches its source row.
- 2026-10-28: The findings below need action before k36 runs a guest.
  Insert one integrate-review-impl leaf before k36.

## Findings

Severity: P1 can make the capped modality set unable to answer its question.
P2 is a protocol or recorder defect that k36 must decide before its freeze.
P3 is a coverage or uncertainty gap. Line numbers refer to commit ac5e03b8.
Rendering lines refer to causal-evidence/persisted-input-context.jsonl.gz.

### P1-1. The matched slot copies the passing position, not the failing one

CAUSAL-PLAN.md:47-73 makes one selection per clone. The selection follows
first launch, one Settings close and the settled TextEdit setup. That is the
position of the historical "Initial Settings action". It passed in
diagnostic-01, diagnostic-02 and persisted-01 (README.md:86-91,
PERSISTED-RESULTS.md:3-4).

Every recorded failure came after at least one
earlier menu selection and window close: persisted reopen 1 and diagnostic-02
reopen 3. menu-bar-vm.md:119-125 also records that the settled TextEdit wait
removed the earlier initial-position failure. The later failures occurred at
reopens with that wait in place.

The plan says that its setup matches the persisted reference. It matches the
passing selection's preceding state, not the failed selection's. The failed
selection followed one Koine activation, key window and close cycle. The plan
omits that cycle. With four slots at this position, four green outcomes are a
likely result. The plan classes that result as inconclusive, and the cap then
closes without a test of the row-click hypothesis.

Uncertainty: three observations at the initial position are not a rate. The
failure can be independent of the earlier cycle. The plan does not state that
choice or give a reason for it. Integration must decide the position. One
option is a prior selection and close as declared setup, with the measured
selection being the reopen. That option needs the earlier outcome retained as
a control, and it must not become a repeated-input chase.

### P1-2. The saved evidence has a paired outcome contrast that the plan omits

CAUSAL-RESULTS.md:28-55 and CAUSAL-PLAN.md:15-22 select row-click modality
from records that occur in both outcomes: rendering lines 311/317/318/321 and
913/919/920/923. The results say that none of these records discriminates
failure. The same rendering holds a positive contrast between the two
outcomes. The comparison table does not show it.

| After the Koine client call | Success-adjacent | Failed-adjacent |
|---|---|---|
| LS/CAS front change | err=0, line 376 | no such record in the rendering |
| TextEdit 53ea7 key appearance for window 32 | inactive, line 424 | active, line 977, 28,741 ticks after the call |
| Koine 403fb key appearance for window 28 | active, line 499 | no such record |
| Koine 403fb OrderWindowGroupFrontConditionally for window 28 | op 1, relative 0, lines 512/515 | op -1, relative 32, line 988 |

The ordering contrast comes from Koine's own connection. The op values are
undocumented SkyLight fields. A missing record does not prove a missing event.

The independent failure snapshot shows Settings behind TextEdit. That snapshot
agrees with the failed row, but it does not establish the op semantics. This
contrast is not a cause. It is the only saved positive difference between the
two outcomes.

The k33 brief asks for an independently supported condition.
The selected condition has support only from records that do not change with
the outcome. CAUSAL-PLAN.md declares no prediction or qualification target for
this sequence. A qualified slot therefore cannot connect its outcome to the
saved difference.

### P2-3. Native ticks cover activate only, and the contrast is outside them

SettingsActivationTrace.swift:126-131 and AppDelegate.swift:131-136 bracket
only NSApp.activate. The historical activate calls lasted about 1.2-1.4 ms of
wall time (PERSISTED-RESULTS.md:91-92), about 30,000 ticks at 125/3 ns per
tick. The Koine ordering records occur 454,033 ticks (about 18.9 ms) and
4,555,162 ticks (about 190 ms) after the client SLSSetFrontProcessWithInfo
record. They are therefore outside any activate bracket.

The other buffered records carry only uptime and unixTime. These records
include makeKeyAndOrderFront before/after, the callback, menu.didClose and the
active/key notifications. The relation of those clocks to native time is
unqualified, and the strict wall-clock joins are false. So k36 cannot place
the ordering and key-appearance requests against makeKeyAndOrderFront or the
notifications in one qualified clock.

One option is a continuous-tick sample
in every buffered record. Another is a second bracket around
makeKeyAndOrderFront. Each adds work inside the activate interval when an
observer runs there, as the plan already discloses.

### P2-4. The containment gate assumes synchronous client emission

CAUSAL-PLAN.md:113-116 requires the Koine client record inside the closed
interval. It rejects a missing or ambiguous candidate. No source or evidence
shows that SkyLight writes SLSSetFrontProcessWithInfo before NSApp.activate
returns. Wall time puts both historical client records after buffered
activate.after: 0.399 ms after the passing call and 0.554 ms after the failed
one (PERSISTED-RESULTS.md:91-92). The provisional tick conversion puts them
inside. If emission follows the return, the gate rejects every interval,
successful ones included.

The plan declares no outcome for a uniquely identified client record that is
in order but outside the bracket. Each slot also opens Settings at first
launch, because setup needs the user (AppDelegate.swift:52-57). That activation
gives a same-guest positive control for containment, but the plan does not
name it as one. Integration must declare both before the freeze.

### P2-5. The competing hypothesis has no falsifying outcome in this set

CAUSAL-PLAN.md:28-32 states the competing hypothesis as a possibility: the
matched context "can produce" the same disposition after either input. A
finite sample cannot refute a possibility. The stated falsifier is "different
positive native processing/disposition". A keyboard arm satisfies that falsifier
by default, because the native input records name their source (`source: mouse`
at lines 311/317/321). The only outcome that separates the two hypotheses is a
qualified Return failure, and that outcome refutes row-click necessity.

Each
mouse outcome agrees with both hypotheses, so the two mouse slots give only
symptom preservation. The k33 brief requires distinct falsifiable competing
predictions. The plan must name the field or disposition comparison that would
refute the competing hypothesis, restricted to the failed request. If it cannot,
it must say that this set tests one hypothesis only. With P1-1, the set has a
low chance of any decisive outcome.

### P2-6. Two qualification gates have no declared criterion before the freeze

CAUSAL-PLAN.md:84-87 and 133-137 reject a stale currentEvent as keyboard
qualification. They name no positive record that qualifies Return delivery.
Examples are a WindowServer input record with a keyboard source, or a keyDown
current event after the transport that matches the Settings callback.
CAUSAL-PLAN.md:76-79 requires a read-only observation of the highlighted row
but names no method. The plan leaves both criteria to k36. A criterion chosen
after the observation conflicts with the freeze-before-launch duty.

CAUSAL-PLAN.md:49-52 also makes each precondition failure consume its slot,
and the set has two Return slots. No separately named and capped route
qualification precedes the set, and k36 says host checks are not guest
qualification. A route defect can therefore consume the decisive arm.

### P3-7. The nine controls do not reach the call-site integration

SettingsActivationIntervalTests.swift tests the helper. The existing buffer
tests cover retention and dump. No headless check reaches
SettingsActivationTrace.swift:126-131. That code holds the enable predicate
(`bufferPath != nil && !dumpRequested`), the legacy-file and after-dump bypass,
the before/interval/after record order and nativeClockError in the encoded
records.

CAUSAL-RESULTS.md:74-76 reports those bypasses as results. Code
inspection finds no defect in them, so the claim rests on inspection and not on the
controls. The trace class is main-actor AppKit code in the KoineApp target,
which has no test seam. Integration must either add a seam or record that
only inspection supports these properties.

### P3-8. The boot identity equivalence has no positive control

SettingsActivationInterval.swift:52-57 reads kern.bootsessionuuid.
CAUSAL-PLAN.md:110-111 matches it with the archive bootUUID and the timesync
boot. causal-evidence/api-sources.txt cites the sysctl export only. No cited
source or host check shows that unified logging uses the same identifier.
A host comparison of the sysctl value with a current log record's bootUUID
can show this.

Uncertainty: the two are probably the same value, but nothing
in the evidence shows it. If they differ, every slot fails identity
qualification.

### Checked without a finding

- measure calls the operation exactly once in both branches. The trace reads
  metadata at initialisation, and it makes no record between the samples and
  the call.
- Ticks encode as decimal strings. The encoder keeps reversed samples, and it
  keeps metadata failure as nativeClockError without a second activation.
- The producer keeps the makeKeyAndOrderFront, then activate order. The code, the
  plan and the results disclose synchronous observer work inside the bracket.
- The plan keeps the cap, freeze, golden, transport, partial-archive, NOT RUN,
  audit and clone-stop duties. It treats a green count and Return success as
  neither cause nor repair.
- The k36 body and the k33 brief carry every original causal, justified
  repair, useful failing-seam and separate frozen ordinary-acceptance duty.
