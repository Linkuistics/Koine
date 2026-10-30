# Keepalive scheduling design evidence

## Scope and disposition

The [owner spec](../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile)
proposes receive-order service, exact deadlines and failure containment.
This is the scheduling slice of k98. K102 retains enforceable resources,
complete workload accounting and whole-design reconciliation. Independent
scheduling review precedes that work. Whole-design review still precedes planning.

No current helper, historical receipt, VM, candidate or acceptance slot changes.
The [accepted scope](KEEPALIVE-DESIGN.md#required-scope-decision) permits these
ownership delays. It preserves input order, explicit waits, poll counts and
one-attempt transports. The proposed internal copied-module barriers remain
subject to the whole-design seam decision from [k100](KEEPALIVE-LIFECYCLE-REVIEW.md#choice-carried-to-k98).

## Source basis and API limits

The inspected [capture loop](../../../scripts/vm-capture-evidence-lib.sh)
places a complete capture after each sleep of twenty seconds. It returns on
capture failure and preserves an observed sleep signal even when recording fails.
The [backend](../../../scripts/vm-guest-exec.py) holds the writer across CLI,
response checks, image checks, output emission and its result receipt.
Its current `subprocess.run` call has no host timeout. Its ordinal allocator
and synchronous validator are not the proposed owner implementation.

The [Allow helper](../../../scripts/vm-click-evidence-lib.sh) sends one OCR
command with timeout 30. It then checks an exact Allow result and performs one
click followed by the existing sleep. The [reviewed route assessment](KEEPALIVE-DESIGN.md#lock-duration-and-connection-activity)
separates that inner interval from whole ownership time. Exec, transfer and
post-CLI validation cannot be credited with VNC activity.

The [PNG inspector](../../../scripts/vm_capture_artifact.py) reads the encoded
file and builds compressed and decoded buffers. A deadline does not bound those
allocations. The resource leaf must establish producer, validator and retention
limits before this schedule can be used.

Apple documents a continuous clock that advances during system sleep and its
nanosecond equivalent, `clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)`.
The scheduling proposal selects that host clock. It does not use application
uptime or a guest/native cross-clock fit.
[Apple clock contract](https://developer.apple.com/documentation/kernel/1646199-mach_continuous_time).

Python documents that `monotonic` on macOS uses `mach_absolute_time`.
That existing duration source is distinct from the selected continuous clock.
Python also permits sleep to return later because of scheduling.
[Python clock and sleep contracts](https://docs.python.org/3/library/time.html#time.monotonic).

Process timeout is not proof of termination. Python documents that process
creation can delay timeout handling, and `communicate` timeout alone does not
kill the child. The proposed independent caller observation and unresolved-holder
outcome account for these limits. No unconditional wait or buffered unlimited
output is justified by a timeout setting.
[Python process contract](https://docs.python.org/3/library/subprocess.html#subprocess.Popen.communicate).

Tier 2 graph discovery found the capture loop and PNG inspector. The capture-loop
trace returned four callees and no callers. That result establishes no caller absence.
The broad capture search returned 15 of 16 hits. Only the exact inspected symbols
support this design, so no exhaustive result is claimed.

Coverage generation was `2026-10-30T11:05:31Z`. Direct reads covered shell parse
gaps at `vm-verify-lib` line 175 and `vm-click-evidence-lib` line 82, plus the relied-on
backend and Bats sources. Bats metadata was untracked. Changed diagram sources
were read directly because their graph parses were partial.

## Alternatives and usefulness

| Policy | Caller burden and internal cost | Disposition |
|---|---|---|
| Receive order with bounded work | Callers submit once. The owner retains queue identity and absolute deadlines. | Proposed. An admitted older request cannot be overtaken. |
| Scenario priority | Inputs can avoid a queued tick, but repeated scenario calls can starve it. | Rejected for this proposal. A fairness exception would add another ordering rule. |
| Tick priority | A newly due tick can overtake existing scenario work. Inputs still wait for active capture qualification. | Rejected. No native liveness evidence justifies that extra input delay. |

The deletion test favours the owner: removing it distributes queue, deadline,
failure and writer knowledge across both producers. Resource reservation remains
a distinct responsibility. A convenient submission API does not establish safe
producer allocation or available storage.

The numbers are engineering service targets. Their usefulness claim is narrow:
they admit these finite, nonzero-duration overlap schedules without a lock refusal.
Times below are illustrative controlled schedules, not measured native timings.

| Schedule | Consequence under the proposal |
|---|---|
| Scenario OCR commits at 0, completes all phases at 36, tick becomes due at 20 | Tick waits 16 seconds, then commits once. The OCR inner timeout remains 30. |
| Capture commits at 0, CLI exits at 12, validation ends at 20, result completes at 24. Input arrives at 13. | Input waits through validation and publication, then commits once at or after 24. |
| Transfer holds for 130 seconds including protocol work. Tick arrives just after commitment. | Tick can still receive service within admission 150. This supplies no safe native idle interval. |
| Holder never supplies its terminal facts | Its phase or whole-operation deadline fails. Later input remains prohibited even if termination fails. |

The longest successful holder is 120 + 22 = 142 seconds. One outstanding
operation per producer prevents a second older holder from joining ahead.
Transfer, admission recording and selection contribute at most six further seconds.
The 150-second admission target therefore covers the conservative 148-second path.
Each separate phase must still pass its own deadline. This is a service-or-failure
argument under the cooperative contract, not a guarantee of OS scheduling.

These delays can change the intermittent symptom. They can exceed the historical
roughly sixty-second connection-free observation. Neither elapsed arithmetic nor
a clean screenshot proves native liveness or new pixels. K102 must demonstrate
that its complete useful workload fits the targets. A failure to do so requires
a reviewed profile change or an explicit unresolved capability question.
No E/A slot may discover replacement limits.

## Required offline controls

Use the real owner, lock, validator and record logic with controlled CLI and sleep.
Preserve every synthetic raw stream and complete/partial artifact. Observe invocation
counts, exact arguments, event/ordinal relationships and later-dispatch refusal.
The existing helper seam supplies external substitutions. Proposed copied-module
barriers reach internal transitions only after the seam decision is settled.

| Boundary | Required result and falsifying mutant |
|---|---|
| Tick due during OCR, exec and transfer, in each arrival order | One queued request, one dispatch, no extra sleep. A competing-writer refusal or younger-request bypass fails. |
| Scenario arrives during capture CLI, validation and publication | No dispatch before the whole capture completes. Unlock-after-CLI mutant fails. |
| Two complete submissions observed together | Scenario wins only that receive tie. A later scenario cannot overtake an already received tick. |
| Every message, admission, phase and whole deadline | Just-before completion can pass. Equality and just-after observation fail. Reset-on-progress and success-before-expiry-check mutants fail. |
| Host clock jumps forward across deadline, wall clock moves backward | Expiry remains binding. Using wall time or sleep-excluding time fails the declared clock contract. |
| Maximum valid holder, then another request | Both receive service or the recorded deadline fails. Continuous younger traffic cannot hide starvation. |
| Normal end during natural sleep, pending tick, commitment, CLI exit, validation and terminal publication | Preserve original deadlines, exact stop join and no extra tick. Reset-at-stop and cancelled-capture-as-clean mutants fail. |
| Backend failure or latch before commitment, after commitment, and after offered payload | Only already committed work may exist. Later clean completion cannot restore eligibility. |
| Creation blocks, TERM fails, KILL has no observed exit, inherited writer remains | Twenty-second containment ends unresolved. No collection through another lock or assumed reap. |
| Owner loss while its child retains writer | Caller keeps scenario closed. Collection requires actual holder settlement and original lock acquisition. |
| Final record, acknowledgement or completion delivery fails | No clean operation/normal stop. Retained payload or exit zero alone is insufficient. |
| INT/TERM/HUP during held-point attempt and settling sleep after clean down | Preserve actual signal and held-input uncertainty. No release or corrective input is sent. |
| Collection failure or exact-stop/inventory disagreement | Keep independent outcomes and block later slots. Collection cannot restore acceptance. |

These controls are specified, not executed. Full resource-boundary and protected
final-record failure controls remain k102's design work. The complete native
workflow stays at the existing TestAnyware seam after all prerequisites.

## Verification and handoff

Document links and browser rendering are checked separately from protocol behaviour.
The [verification receipt](ordering-keepalive-scheduling/verification.json) records
the final document check, its existing archived failures and stable input digests.
The [visual discussion](../../design/architecture/settings-activation/README.md)
links the current scheduling view. K98 and k96 remain open.

The [complete duty table](KEEPALIVE-DESIGN.md#original-duties-and-handoff)
still assigns k89/k81/k76/k67/k62/k57/k54 their original work. Private evidence,
snapshot/AXValue availability, OCR substring, held-frame fallback, closed caps
and every historical outcome remain binding. No native experiment is authorised.
