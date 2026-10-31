# Keepalive scheduling design evidence

## Scope and disposition

The [owner spec](../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile)
proposes receive-order service, exact deadlines and failure containment.
This is the scheduling slice of k98. K102 retains enforceable resources,
complete workload accounting and whole-design reconciliation. Independent
scheduling review k103 and this k104 integration precede that work.
Whole-design review still precedes planning.

No current helper, historical receipt, VM, candidate or acceptance slot changes.
The [accepted scope](KEEPALIVE-DESIGN.md#required-scope-decision) permits these
ownership delays. It preserves input order, explicit waits, poll counts and
one-attempt transports. The copied-module barriers and clock reader carried from
[k100](KEEPALIVE-LIFECYCLE-REVIEW.md#choice-carried-to-k98) received
[Antony's approval](KEEPALIVE-RESOURCES.md#test-seam-and-later-controls) on 2026-10-31.

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

### Command and wait inventory

This inventory maps the inspected helper routes to proposed families. It is not
the frozen operation allowlist. The current generic adapter accepts broader
agent/input/screen actions. Unlisted operations refuse under the proposed owner
until the complete profile maps their exact arguments and predicates.
CLI allowances below exclude the additional 22 seconds of operation phases.

| Command or local work | Known internal wait and source | Proposed CLI allowance |
|---|---|---:|
| Checked `screen capture`, including region and keepalive | Capture library lines 14–17 and 22–43. No whole-capture bound in this source. | 30 seconds |
| `screen size`, immediate `screen find-text` | Physical facade lines 23–26 and click library lines 31–35. No whole-command bound here. | 30 seconds |
| Allow `screen find-text --timeout 30` | Click library line 32. Thirty-second internal OCR poll, with the retained substring early-stop limit. | 45 seconds |
| `input click`, `mouse-down`, `mouse-up`, `move`, `key`, `type`, `scroll` | Physical facade lines 44–56 and input facade lines 7–61. Tagged input confirmation has ten seconds, not a whole-command bound. | 30 seconds |
| `agent windows`, full `snapshot`, `window-move`, `window-focus`, `window-close` | Window library lines 22–83 and UI library lines 18–49. No whole-command bound in these helper calls. | 30 seconds |
| `file exec`, including observer, defaults, install, restart and other guest commands | Backend lines 249–251. Existing guest timeout is 30 seconds. Host transport remains separately bounded. | 45 seconds |
| `file upload`, including Koine.zip, client and enrolment scripts | Common library lines 336–349 and scenario line 83. Bundle byte size and transfer duration are unbounded in the cited caller. | 120 seconds |
| Evidence `file download` | Backend lines 185–202. No byte or elapsed bound in this admission code. | 120 seconds |
| `vm start --wait` | Common library lines 312–334. Tagged CLI gives bare `--wait` a 600-second slot-queue limit, before boot work. | 120 seconds, useful fit unresolved |
| Exact `vm stop` | Backend lines 204–211. No whole-command bound in this admission code. | 120 seconds |
| Independent `vm list` | Backend lines 204–211. Classified as lifecycle inventory, with a separate result. | 120 seconds |
| Successful `poll-step`, failed `poll-step` and `confirmation` | Backend lines 246–247 and 314–329. No CLI. A failure control precedes its evidence-class record. | Zero, 22 seconds total |

<!-- tc: depart synonym-rotation because vm-verify-lib.sh is a file name -->
The common library is [vm-verify-lib.sh](../../../scripts/vm-verify-lib.sh).
The additional sources are the [physical facade](../../../scripts/vm-physical-evidence-lib.sh),
[input facade](../../../scripts/vm-input-evidence-lib.sh),
[window library](../../../scripts/vm-window-evidence-lib.sh),
[UI library](../../../scripts/vm-ui-evidence-lib.sh) and
[scenario](../../../scripts/vm-verify-menu-bar.sh).
These are source locations at k101, not native measurements.

Tagged [main.rs lines 484–487 and 1965–1970](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/main.rs#L484)
sets the bare slot wait to 600 seconds. The
[VM handler](https://github.com/Linkuistics/TestAnyware/blob/65bc05c9/cli-rs/crates/testanyware-cli/src/commands/vm.rs#L79)
passes it as a duration. Thus the review's claim that bare `--wait` is unbounded
does not hold against the complete parser source. Neither the slot limit nor
the proposed family target bounds all native provisioning or proves its useful fit.

The owner covers VM start after its own readiness. Its ready worker starts
sleep only after clean VM start, at the legacy post-start point before uploads.
Owner startup's five seconds do not include VM boot. K102 must account for the
600-second queue option, boot stages and exact-clone containment after interrupted start.
It cannot silently shorten an explicit wait or move start outside the writer domain.

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
| Transfer holds for 130 seconds including protocol work. Tick arrives just after commitment. | Tick can still receive service within admission 152. This supplies no safe native idle interval. |
| Holder never supplies its terminal facts | Its phase or whole-operation deadline fails. Later input remains prohibited even if termination fails. |

The longest successful holder is 120 + 22 = 142 seconds. One outstanding
operation per producer prevents a second older holder from joining ahead.
The waiting request reaches the owner before O + 2. An older request can arrive
just before it, then consume two seconds each for admission and commitment.
Its 142-second operation ends before O + 148. Final selection adds two seconds.

The waiting request's admission overlaps that work. The upper path is therefore
2 + 2 + 2 + 142 + 2 = 150 seconds, with two seconds of budget margin.
The 152-second admission target therefore covers the complete 150-second path.
Each separate phase must still pass its own deadline. This is a service-or-failure
argument under the cooperative contract, not a guarantee of OS scheduling.

These delays can change the intermittent symptom. They can exceed the historical
roughly sixty-second connection-free observation. Neither elapsed arithmetic nor
a clean screenshot proves native liveness or new pixels. K102 must demonstrate
that its complete useful workload fits the targets. A failure to do so requires
a reviewed profile change or an explicit unresolved capability question.
No E/A slot may discover replacement limits.

The first concrete workload conflict is the bundle upload after keepalive starts.
A tick due during a 142-second transfer can wait beyond the historical roughly
sixty-second observation without credited VNC activity from that transfer.
This is a required liveness reconciliation, not a demonstrated native recurrence.
Other connection owners and actual connection history also matter.
K102 must supply actual bundle bytes, transfer work and connection evidence before
claiming usefulness. No safe idle interval follows from the family numbers.

## Required offline controls

Use the real owner, lock, validator and record logic with controlled CLI and sleep.
Preserve every synthetic raw stream and complete/partial artifact. Observe invocation
counts, exact arguments, event/ordinal relationships and later-dispatch refusal.
The existing helper seam supplies external substitutions. Approved audited copies
add barriers and substituted continuous-clock readers for internal transitions
and exact times. Each copy must match production except for declared substitutions.

| Boundary | Required result and falsifying mutant |
|---|---|
| Tick due during OCR, exec and transfer, in each arrival order, plus scenario post-CLI validation | One queued request, one dispatch, no extra sleep. Ownership extends through validation, delivery and publication. CLI-exit release, competing-writer refusal or younger-request bypass fails. |
| Scenario arrives during capture CLI, validation and publication | No dispatch before the whole capture completes. Unlock-after-CLI mutant fails. |
| Two complete submissions observed together | Scenario wins only that receive tie. A later scenario cannot overtake an already received tick. |
| Every message, admission, phase and whole deadline | Use the proposed clock reader at each declared observer. Just-before can pass. Equality and just-after fail. Reset-on-progress and success-before-expiry-check mutants fail. |
| Host clock jumps forward across deadline, wall clock moves backward | Expiry remains binding. Using wall time or sleep-excluding time fails the declared clock contract. |
| Older request arrives just before a request received at O + 2 | Exercise holder admission, commitment, 142-second operation and final selection. The upper path is 150, admission 152. An omitted holder-admission mutant fails. |
| Normal end during natural sleep, pending tick, commitment, CLI exit, validation and terminal publication | Preserve original deadlines, exact stop join and no extra tick. Reset-at-stop and cancelled-capture-as-clean mutants fail. |
| Backend failure or latch before commitment, after commitment, and after offered payload | Only already committed work may exist. Later clean completion cannot restore eligibility. |
| Creation blocks, TERM fails, KILL has no observed exit, inherited writer remains | Twenty-second containment ends unresolved. No collection through another lock or assumed reap. |
| Owner death or live stalled owner while its child retains writer | Advertised deadline plus report limit starts caller containment once. At twenty seconds, active waits end. Missing reap or ownership remains unresolved. |
| Backend CLI exit followed by long validation | Separate continuous-clock phase frames preserve both deadlines. A final payload substituted for the CLI-exit frame fails. Wrong clock, missing frame and late report fail. |
| Failure control while another operation holds the writer | Eligibility closes immediately. Its local evidence record has 22 seconds from failure observation, including holder wait. Reset-at-record-commitment fails. |
| Final record, acknowledgement or completion delivery fails | No clean operation/normal stop. Retained payload or exit zero alone is insufficient. |
| INT/TERM/HUP during held-point attempt and settling sleep after clean down | Preserve actual signal and held-input uncertainty. No release or corrective input is sent. |
| Collection failure or exact-stop/inventory disagreement | Keep independent outcomes and block later slots. Collection cannot restore acceptance. |

These controls are specified, not executed. Full resource-boundary and protected
final-record failure controls remain k102's design work. The complete native
workflow stays at the existing TestAnyware seam after all prerequisites.

## Verification and handoff

Document links and browser rendering are checked separately from protocol behaviour.
The [k101 receipt](ordering-keepalive-scheduling/verification.json) records the
original document check and its original arithmetic. It remains historical.
The [k104 receipt](ordering-keepalive-scheduling-integration/verification.json)
records the repaired arithmetic, document checks and stable inputs.
The [visual discussion](../../design/architecture/settings-activation/README.md)
links the current scheduling view. K98 and k96 remain open.

The [complete duty table](KEEPALIVE-DESIGN.md#original-duties-and-handoff)
still assigns k89/k81/k76/k67/k62/k57/k54 their original work. Private evidence,
snapshot/AXValue availability, OCR substring, held-frame fallback, closed caps
and every historical outcome remain binding. No native experiment is authorised.

## Review integration

K104 grades k103's findings from commit `ff039f13` against k101 at `e9045bf9`.
The current spec incorporates the following repairs. No decision earns an ADR:
these proposals remain reversible before implementation.

| Finding | Classification and reason | Disposition |
|---|---|---|
| P2-1 admission margin | Real issue. The prior path omitted the older request's post-origin admission and commitment. | Preserve serial phases. Use a 150-second upper path and 152-second admission budget. |
| P2-2 internal phase observer | Real issue. Current blocking backend code emits no phase progress and uses a different duration clock. | Specify backend continuous-clock observations, sequenced private progress frames, owner receipt deadlines and independent whole-operation supervision. No code changes here. |
| P2-3 live unresponsive owner | Real issue. Owner death alone does not cover a stalled live lock holder. | Missing advertised progress plus its report limit starts the caller's single twenty-second containment window. Actual ownership and reap remain required. |
| P3-1 normal-stop arithmetic | Unclear rationale, with a visible conservative trade-off. Normal finish cannot retain scenario work. | Record reachable capture/sleep paths of 58/30 seconds. Keep the loose 150-second outer limit without extending any phase. |
| P3-2 clock enabling point | Real issue. CLI and sleep controls cannot produce exact integer-clock equality or simulate host resume. | Propose copied-module clock readers with the existing barriers. Carry the unapproved choice and correspondence cost to k102. |
| P3-3 local failure control/record | Unclear contract. Failure notification must precede admission, while its retained local record uses the ordinal domain. | The owner submits an evidence-class record after closing eligibility. Its 22 seconds start at failure observation and include holder wait. |
| P3-4 waits and useful workload | Real inventory gap. The unbounded bare-wait subclaim is noise from incomplete parser context. | Record the actual 600-second slot wait, unresolved boot/transfer bounds and post-start upload conflict. K102 must reconcile usefulness. |
| P3-5 rationale, terms and captions | Real documentation issue. The current design spans more than its evidence report. | Put rejected priorities in the spec. Add four glossary terms. Align completion-frame ownership and the lifecycle note. |

### Choices and obligations carried to k102

The recommended test enabling point combines copied-module barriers and a
substitutable continuous-clock reader in the owner, backend and caller.
It preserves production interfaces but requires correspondence checks for every copy.
A production callback adds a maintained interface. External CLI/sleep controls
alone leave exact deadline and internal race rows unqualified.
This integration required k102 to obtain the human seam decision and supplied
no approval itself. Antony subsequently
[approved audited test copies](KEEPALIVE-RESOURCES.md#test-seam-and-later-controls)
on 2026-10-31.

One narrow reviewer challenged deadline observation and supervision in the repaired spec.
It found an unclear completion boundary: a deferred echo cannot serve as an
immediate owner-observed receipt. The spec now separates owner send from submitter
receipt under the same absolute deadline. Successful send releases dispatch after
payload acknowledgement and terminal publication. The deferred echo retains receipt
evidence without adding a serial phase. Missing echo still prevents final acceptance.

This clarification preserves the lifecycle's deliberate absence of another acknowledgement.

K102 also retains the exact admitted-operation mapping, full useful workload,
VM-start mismatch, upload liveness reconciliation and all enforceable resource limits.
The local failure record can remain unavailable when holder resolution consumes
its budget. Protected final-record capacity cannot make an unavailable holder usable.
Whole-design review still precedes planning, implementation and k89/k81/k76 consumption.
