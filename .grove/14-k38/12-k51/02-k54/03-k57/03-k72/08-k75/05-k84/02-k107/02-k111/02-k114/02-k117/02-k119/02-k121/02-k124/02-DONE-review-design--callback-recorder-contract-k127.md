# callback-recorder-contract-k127

**Reviews:** callback-recorder-contract-k125

## Goal
Adversarially inspect the diagnostic recorder contract before native execution
uses it as an acceptance instrument.

## Context
Read the producer's commit and docs/verification/callback-native-capture/contract.md,
the existing causal contract/checker, and k124/k121's original criteria. The
proposal has no native result. One in-session review prompted substantive
corrections; this is the required fresh-context tree review before k126.

## Done when
- Check that permitted native executions can actually produce accepted causal
  evidence, including all B/C activity rows, and that apparent success cannot
  bypass real callback unwind, held-right ownership or native input provenance.
- Challenge the observer-mode coverage premise and proposed failure controls:
  determine whether the open premise and its consequence are precise enough to
  investigate without accidentally assuming a native guarantee.
- Check actual exits, bounded collection, host/guest failure and containment
  claims against the original requirements and measured k123 limits. Check the
  source/provenance subjects, private verifier seam and preserved native matrix.
- Report findings only under the review-design procedure. No native execution,
  implementation, product adoption or second in-session reviewer.

## Notes
The artifact is a proposed experiment contract, not a product spec. Review its
current text against requirements; do not treat the prior review's findings as
your charter. Any integration belongs before callback-recorder-native-k126.

## Findings

Read against k125's commit `ef77a75` (jj `yurvqlkz`): the proposal
`docs/verification/callback-native-capture/contract.md`, the causal transcript
contract and `analyze.py` in `docs/verification/callback-causal-fixture/`, the
route and exit-observer contracts, the capture assessment's route/exit/proposal
sections, the activity-barrier evidence, and the k124/k121/k119 briefs. Unless
another file is named, line references are to the proposal as committed there.
Findings are in severity order. None asks for a native result, product adoption
or freshness claim.

What holds up: the returned producer is sound as an unwind argument. A statement
after the matching outer `CFRunLoopRunInMode` returns cannot run while a
callback invoked inside that call is still on the same thread's stack. The
same-invocation and pending-callback checks also exclude a callback delivered
outside the recorder's own call (:77-92). Validation reads through the held
task-name right, and port-name or PID-lookup equality is refused (:140-147).
Actual statuses are kept separate from host containment, and neither stands in
for the other (:205-232). The source pairs, constructions, B retention across C,
exit/cleanup controls and policy attribution in k121/k124 all appear in the
matrix (:252-262).

### 1. The trigger keystroke reaches B, and no representation of it can pass the closed schema — high

The trigger is a key-down posted to the session (:47-53). The route probe
showed it being delivered to the frontmost app: "Ordinary/repeat B also received
the trigger at seq 7" (`callback-capture-transfer.md:519`). B records key-downs
from normal dispatch with no marker expectation (:48, :170), and inconvenient
records may not be filtered (:163, :177). So B's stream contains a second
`input`. The unchanged analyzer requires exactly one `input` and one `inject`
in ordinary cases, and two in after-callback cases (`analyze.py:403-409`). If
either count is off, it reports `extra-input` with exit 3. The controller's
trigger post cannot appear as `trigger` either: outside delayed-entry, that
event is `Unexpected delivery gate` (`analyze.py:419-427`).

Consequence: the proposal gives B no way to record the trigger honestly that
still passes the analyzer. Recording it fails every positive cell with exit 3.
Omitting it breaks the no-filtering rule. B also cannot tell the trigger from
its own marker, because it holds no expected-marker configuration. Nothing in
the proposal says what B does with this event, and none of the synthetic
evidence contains it.

Integration must pick one representation and give it failing controls. Options:
- A versioned additive causal extension, following the pattern `returned` set
  (causal contract :33-36). It would add a controller auxiliary injection and
  its target-side receipt, and require that receipt to come after B's marker
  receipt.
- An audit-only rule, stating how the target's causal `input` row is determined
  without marker configuration.
- A trigger event class, delivered to the tap, that the target does not record
  as marker input. This still has to be recorded somewhere.

Whichever is chosen, the audit verifier must join the target's receipt of the
trigger to the controller's post.

### 2. Activity rows outside the post-return window have no causal order: startup activation, ordinary cases and teardown — high

The unchanged analyzer requires every `activity` row to be causally before B's
receipt or after `m_end`. Otherwise it reports `ambiguous-activity` with exit 2
(`analyze.py:443-448`). The proposal orders only the after-callback post-return
window (:55-62). Three other windows are unordered:

- **Startup.** "Startup/readiness acknowledgments establish order from every
  initial activity record" (:42-44). But B's activation is requested after
  those acknowledgments. The resign and key-window changes that activation
  causes in C (or in B, as late notifications) arrive after the targets have
  acknowledged, so nothing orders them before B's marker receipt. Two things
  are not frozen: the launch order, and whether B/C are launched activating or
  in the background. Both decide whether C ever has such rows.
- **Ordinary cases.** These have no post-sample message into B or C. Any
  activity after B's receipt-send is unordered with `m_end`, and a later
  activation change is an example.
- **Teardown.** No message tells B/C to finish and write `end`. When a role
  quits, the OS can activate a still-running target, and that row is again
  unordered. Notifications that arrive after `end` cannot be recorded at all.
  The proposal does not say whether that is a limitation or silent filtering.

The activity-barrier evidence does not cover these windows. The accepted
`paired-barriers` trace is after-callback only. It has no startup activation
rows, no sampler arm acknowledgment, no trigger and no finish exchange. So
"the unchanged analyzer accepts the paired-barrier trace" does not show that
the specified protocol can produce an accepted transcript.

Consequence: permitted native runs are likely to end in exit 2 in some cells,
especially ordinary ones. The pressure is then to suppress activity, which is
the defect the barriers exist to prevent.

Integration should specify:
- the frozen launch mode and order;
- a post-activation settle barrier to both B and C before B's marker;
- a post-sample finish barrier to B and C in every schedule, with every
  acknowledgment collected before any role exits;
- the explicit status of post-`end` notifications.

Integration should then derive synthetic canonical traces of the complete
specified protocol, for every schedule and construction, and check them against
the unchanged analyzer before k126 builds against it.

### 3. The observer-coverage premise's consequence is imprecise, and its control can pass without testing anything — medium-high

The premise is concrete: observers are per-mode (:94-103). Its consequence is
not:
- "Classify the ordinary loop condition as inconclusive" can be read as the
  `ordinary` schedule or as the normal, unnested loop state. It does not say
  whether after-callback cells are affected, though their getters run in the
  same callback.
- It does not say how "inconclusive" maps onto a matrix cell, which is still
  called a capture (:261-262).
- It does not say whether k126 may then reconcile k124's "record callback
  depth, loop nesting" criterion or must escalate. k119 already says "nested
  servicing that changes the schedule [is] unreached".

Read one way, the open premise blocks every positive cell. Read the other way,
it is a footnote on a credited positive. That is exactly the room for assuming
a native guarantee without saying so.

The premise also merges two questions:
- **Reentrant servicing of recorder-owned sources.** These are the tap, socket
  and timers. It is observable without mode coverage: each owned handler can
  check callback-active depth on entry.
- **Framework-private nested runs** that service only framework sources. These
  bear on getter behaviour and freshness, and freshness is already
  `freshness_established=false`.

Separating the two makes the first a checkable instrument property and turns
the second into a stated limitation with a named consequence.

The unobserved-mode control (:98-99, :259) can pass vacuously.
`CFRunLoopRunInMode` on a mode with no sources or timers returns
`kCFRunLoopRunFinished` without servicing anything, and that looks the same as
"no nesting detected". The control must show that the nested run actually
serviced a source registered in that custom mode before its detection or gap is
credited.

Integration should add:
- an explicit loop-coverage classification column per cell;
- a rule saying whether unestablished coverage withholds positive credit;
- the escalation path if k126 cannot establish it;
- a control that shows the nested run actually ran.

### 4. Two-verifier acceptance has no combined outcome, and it creates a second ordering engine — medium

A native result needs both the analyzer and a new audit verifier (:158-164).
The analyzer's exits 0-3 have fixed meanings (causal contract :139-146). The
proposal defines no combined per-cell classification or precedence:
- analyzer contradiction (1) with an incomplete audit;
- analyzer 0 with an audit rejection;
- a containment-unconfirmed stop.

Yet the Taskfile must "grade the matrix" (:272-273). Every consumer (k126's
grader, the assessment, k122) would have to reconstruct that rule.

The verifier also "checks ledger, loop and broker order using local sequence
and messages only" (:184-186). That re-implements the analyzer's reachability
graph, and the two engines can diverge silently. The smallest correction:
- define one combined outcome table, with precedence across containment,
  instrument or incomplete evidence, schema, contradiction and consistent;
- have the verifier reuse the analyzer's graph construction instead of a second
  implementation.

Keeping the verifier private to the transcript/VM seam is right. There is a
concrete substitution need (synthetic mutants against native streams) and no
public surface.

### 5. Clone-per-case has no specified way to establish the frozen permission profile in each clone — medium

k118 configured the sampler's Input Monitoring and the controller's
Accessibility by hand in one clone (`callback-capture-transfer.md:556-557`).
The proposal needs a fresh clone for each of at least sixteen native cases
(:221, :252-262), each with the same permission profile. It freezes
"permissions" (:264) and records preflights (:115-119, :283). It does not say
how grants reach each clone:
- a base image carrying grants bound to the frozen designated requirement,
- scripted UI, or
- another mechanism.

It also does not say that this step is a Taskfile task, or that the grant
configuration is a provenance subject. The cost statement (:234) omits the
step. A per-clone manual grant would make the matrix irreproducible and put an
unfrozen, uncounted step in front of every case. Integration should name the
mechanism, its Taskfile task and its provenance record. Grant establishment
must also stay outside the case's frozen window, because no role may change
consent during a case (:118).

### 6. The producer of the pre-held candidate PIDs is unspecified — low-medium

Pre-held mode acquires rights for "each independently identified B/C PID"
before entry (:130-132). The field-producer table (:174) covers the acquisition
but not where the input PID comes from. Candidates are the supervisor's kernel
peer PID, B/C `start` rows relayed in a message, or something else. The route
matters. If it is the supervisor, the value crosses an auxiliary exchange that
is not a causal role. A getter-derived PID must be excluded. The audit must
join the PID's provenance to the `acquire` row. Integration should name the
producer and the audit fact.

### 7. No control checks which tap delivery was selected — low

The sampler waits for sample-release. Its tap deliveries meanwhile queue,
including B's own marker, and can run inside the outer invocation before the
trigger. Only selection by the trigger's delivered marker (:171) keeps an
ordinary cell from sampling in a queued, OS-delayed delivery of B's marker.
That would be the delayed-entry schedule under an ordinary label. The mutant
list (:243-250) names "wrong delivered marker" but does not tie it to callback
selection. Add a verifier mutant whose selected callback carries B's marker or
another non-trigger delivery. The audit should record each delivery's marker.

### 8. Host-failure and supervisor-helper accounting are incomplete — low

- "Do not start another clone while leaving an unconfirmed one running" (:232)
  holds only while the host runner lives. A runner crash needs a durable
  pre-run inventory of suite clones, or a case journal.
- The start point of the host's 60-second execution deadline is not stated
  (:197-199). Does it include clone boot?
- The supervisor's own LaunchServices helper processes for launch and
  activation (:39-45) are expected children. The "unexpected children" rule
  (:215-216) should classify them and bound their waits, as k123 did for its
  launch helper.
