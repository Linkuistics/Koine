# callback-recorder-protocol-k129

## Goal
Repair the complete four-role recorder protocol so honest trigger and activity
records can produce accepted evidence before k126 builds the native instrument.

## Context
Read k127's findings from commit a20fb3d5 and k128's triage/reproductions, the
native recorder contract, causal contract/analyzer and k121/k124 briefs. The
current proposal is not ready for native acceptance. Enclosing-call return,
held-right ownership and separate containment/status obligations remain binding.

## Done when
- Choose and specify an honest trigger representation, including controller
  post, sampler selection and target receipt, with complete audit joins and no
  expected-marker configuration or filtering of target input. Explicitly reject
  queued B-marker/non-trigger callback selection. Consider the review's options;
  no representation has been selected by integration.
- Specify frozen launch mode/order, post-activation settle exchanges to both
  targets, and post-sample finish exchanges in every schedule. Collect every
  finish acknowledgment before any app exits. Define the observation window and
  post-end notifications explicitly, preserving inconvenient in-window activity.
- Derive complete canonical synthetic traces for ordinary/after-callback × both
  source pairs × both constructions, including startup, arm, trigger, activity,
  return/retention and finish. Execute them through the analyzer. Add failing
  controls for each omitted/misordered edge and trigger join; preserve exact
  diagnostics and itemwise frozen input maps. Synthetic success is not native.
- Prefer the existing causal interface if it can express the honest protocol.
  Any vocabulary change is explicitly versioned, has failing controls, preserves
  prior schedule meanings, and renews the complete frozen analyzer corpus.
- Reconcile the contract, assessment, recorder views, native k126 charter and
  k124 brief. Preserve k128's loop-coverage, combined-outcome, permission-setup,
  candidate-PID and host-recovery repairs; amend them only with stated evidence.
- Insert a review-design leaf for this producer before k126 at session end.
  No in-session reviewer beside that scheduled tree review. Review must challenge
  complete accepted traces against actual proposed producers and all eight k127
  concerns, rather than checking only that the mutants fail.

## Notes
Diagnostic experiment design only, no native capture, product adoption or
permission change. Run presentation rendering/inspection only in a disposable
TestAnyware clone. Native k126 retains all original k121/k124 criteria and must
consume the reviewed protocol before measurement; k122/k115/k112/k108/k109 keep
existing ownership. No parent closes on synthetic success or this contract.

## Decisions (running log)

- Use a version-2 diagnostic transcript for ordinary/after-callback recorder
  runs. Every target key-down is an input, including the trigger; targets have
  no expected-marker configuration. Add the trigger marker to the case and
  the actual delivered marker to callback entry. Version 1 retains all five
  schedule meanings. Audit-only classification would hide a second selection
  policy in the target/exporter; another event class would need new native
  routing evidence. Neither is preferable to explicit honest input records.
- Freeze background launch C, B, sampler, controller; collect readiness, then
  activate B and exchange settle messages with both targets. A barrier orders
  already dispatched notifications, never certifies a drained OS event queue.
  Preserve late activity and let ambiguous sample overlap fail. After sampling,
  close both target observation windows through finish messages and collect
  every role's finish acknowledgment before issuing any exit release. Post-close
  native notifications are outside the declared finite window, not evidence of
  continued foreground ownership. Native audit must verify handler teardown.
- The existing causal graph is the ordering instrument; extend its versioned
  input contract and falsify complete synthetic transcripts, without adding a
  formal model or a second reachability engine. Native producer verification,
  private-loop coverage and containment remain k126 obligations. Review is
  explicitly scheduled in the tree; no in-session reviewer is permitted.
- Version 2 requires the existing returned event in ordinary too, at the same
  enclosing call boundary before retained. Only after-callback sends the return
  acknowledgment and switches to C. The old omission was a version-1 vocabulary
  constraint, not a different native ownership requirement. Version 1 is unchanged;
  missing/early/late/wrong-callback return controls falsify both v2 schedules.
  Loop coverage still withholds positive native credit when missing.
- Completed the full eight-cell synthetic matrix and message omission/reorder,
  trigger, observation-window, return and version controls. The frozen run under
  `docs/verification/callback-native-capture/evidence/k129/causal-controls/`
  matched all 233 exact outcomes, with unchanged itemwise inputs and ten equal
  arrival-order comparisons. All 65 old case/trace pairs retain their original
  bytes. `task design:check-callback-analyzer` passed lint, formatting, strict
  types and all 235 tests. Every outcome keeps freshness unestablished.
- Reconciled the native/causal contracts, assessment, three recorder views,
  native k126 handoff and k124 brief. Added the producer's tree review
  `callback-recorder-protocol-k130` before k126, with all eight k127 concerns
  and honest positive producer executions in scope. No in-session reviewer ran.
  No product spec/ADR changes follow from this diagnostic protocol repair.
- Rendered all three sequences and inspected their fresh browser views and
  discussion in disposable clone `koine-k129-view`; source/tool input maps
  stayed unchanged and local/served/guest bytes matched. Retained screenshots,
  render results and explicit presentation limits under `evidence/k129/`.
  Stopped the clone and confirmed backend removal. No native capture or
  permission setup ran. The scoped check passed 125 document links and all
  29 manifest entries, with missing-file/heading controls observed failing.
- Tier-2 graph coverage refreshed at generation `2026-09-23T17:16:05Z` for
  381 changed/evidence paths: Python and indexed prose had no recorded gaps;
  raw JSONL/PlantUML were not tracked and SVG/PNG were excluded. Direct fixture
  reads during the frozen run, source reads, SVG parsing and visual inspection
  supply those fallbacks. This is bounded evidence, not graph completeness.
  k130 and k126 remain live; no parent closes on this synthetic result.
