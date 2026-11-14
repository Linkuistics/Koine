# settings-window-transports-k70

## Goal
Implement independently checked source-only window list/action/poll helpers on
the reviewed single-attempt evidence adapter, ready for later scenario migration.

## Context
Consume ORDERING-PHYSICAL-RESULTS.md, ORDERING-NONEXEC-RESULTS.md and reviewed
ORDERING-EVALUATION-PLAN.md under docs/verification/settings-activation. The
ordinary scenario and helpers remain legacy until the remaining migration.

## Done when
- Require an explicit initialized nonempty root; preserve raw original full
  agent window lists and exact VM/operation/class/ordinals through the adapter.
  Validate actual required WindowInfo fields, optional title and action receipts
  against the immutable official v2.7.0 source after its manifest.
- Provide one-shot focus, close and move with matching action/success payloads,
  no repeated input and no invented coordinate/title echo in action receipts.
- Express clean count-negative state only in complete successful window arrays;
  preserve Koine's ten-by-two and TextEdit's fifteen-by-two poll bounds and all
  waits. Stop immediately on failed/malformed/partial/nonzero/signal completions;
  retain exhaustion separately as a failed downstream state confirmation.
- Show meaningful failing controls before implementation and passing Taskfile
  checks for original-list retention, schemas, argv, clean negatives, exhaustion,
  first-failure stops, sticky eligibility, invalid roots and SIGINT propagation.
- Document boundaries and cut earned independent review before consumption.
  No ordinary adoption, title/liveness/setup classification, VM or freeze.

## Implementation plan

1. Write Bats controls executing the real reviewed backend with only the
   external CLI and settling sleep controlled; retain the pre-implementation
   failing run and before/after subject digests.
2. Add scripts/vm-window-evidence-lib.sh with explicit-root list, one-shot window
   action and the two unchanged bounded polls. Cite inspected tagged contracts.
3. Add check:vm-window-evidence to Taskfile.yml; verify that task and the shared
   adapter/physical controls against unchanged final subjects.
4. Publish a durable boundary/evidence report and require independent review
   before K71 consumes this artifact. Retire only this child.

## Decisions (running log)

- 2026-10-29: Expand with an explicitly called source-only library rather than
  enabling a partly migrated ordinary scenario. Retain full original envelopes;
  count predicates never add title/focus/process assertions. K67 owns those.
- 2026-10-29: Read the official immutable v2.7.0 manifest, WindowInfo and agent
  handlers from local tag objects after online raw-file retrieval failed. Window
  actions report matching action/success/message without echoing target or frame;
  downstream UI confirmation remains mandatory. Optional titles must stay optional
  here so count checks do not silently become the separate k67 identity audit.
- 2026-10-29: Preserve the existing ten-by-two Koine and fifteen-by-two TextEdit
  loop waits, including the final clean-negative sleep. Return the successful
  full response; retain every attempt's exact original bytes in the shared store.
  Clean exhaustion gets a separate named state-confirmation receipt. A failed
  transport never reaches another read or sleep. Local/shell interruption remains
  a caller signal-handling duty in k71; adapter SIGINT is returned distinctly.
- 2026-10-29: All initial thirteen controls fail against test-only legacy routes;
  the failed-poll control reproduces acceptance of matching text from CLI 7.
  The new missing-argument regression fails before the nounset argument guard.
  Retain both red subjects/results. No VM or ordinary scenario is exercised.
- 2026-10-29: Final Taskfile verification passes fourteen window, thirty-seven
  shared-adapter and sixteen physical-helper controls. Every recorded subject
  matches its before/after digest and the final files item by item. The docs
  check retains only the two existing missing archive targets assigned to k23;
  the charter bytes and target absence match the parent. The durable report and
  verification receipt retain the limits. No native/runtime acceptance follows.
- 2026-10-29: A later watcher refresh supplies a full graph generation at
  2026-10-29T07:09:39Z. Search/snippet/trace identify the new helper path. Coverage
  flags its state-predicate line 118 and existing helper here-string/arithmetic
  ranges; read every reported range directly. Bats remains untracked by graph
  metadata, so source/test execution supplies its evidence. No exhaustive graph
  or repository-wide claim is made.
- 2026-10-29: Schedule an independent tree review before k71 consumption because
  this boundary governs which negative observations may advance scenario input.
  Executable controls qualify behavior at the helper seam; they do not replace
  that fresh read. No competing in-session reviewer is materialized. No ADR is
  earned by this reversible expansion. K66 and all ancestors retain live work.
