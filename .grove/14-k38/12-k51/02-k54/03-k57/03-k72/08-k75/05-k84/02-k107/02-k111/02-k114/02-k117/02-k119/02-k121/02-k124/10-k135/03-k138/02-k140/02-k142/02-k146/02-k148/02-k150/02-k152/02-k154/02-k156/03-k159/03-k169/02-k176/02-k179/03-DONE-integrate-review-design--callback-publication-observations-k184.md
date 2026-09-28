# callback-publication-observations-k184

**Integrates:** callback-publication-observations-k183

## Goal
Triage the fresh review of the k181 publication observation contract and apply
the findings that hold before k182 builds the versioned diagnostic on it.

## Context
Read the review's findings from its own committed leaf and k181's committed
contract sections, assessment and views. The full k179/k176/k169 charters bind.

## Done when
- Every finding has a recorded disposition, and each accepted one is reflected
  in both recorder contracts, the assessment and any affected view.
- k182's brief still owns every unmet k179 executable/version/corpus criterion,
  plus any new obligation that integration hands forward.

## Notes
Design-contract integration only; no executable version, corpus renewal or
native experiment. Render/view only in a disposable TestAnyware clone.

## Decisions (running log)

- Read k183 findings from commit `77e375a8`, against the unchanged k181
  publication proposal. Findings 1, 2 and 4 expose unclear evidence contracts;
  9 omits required negative examples; 11 needs narrower evidence wording; 12
  omits the already available host bounding owner. Repair these here without
  changing executable versions. No native or whole-corpus result follows.
- Findings 3, 5, 6, 7, 8 and 10 are valid but interdependent design work:
  auxiliary byte ownership, stream/coordinate topology, cross-hop aggregation
  and graph construction, legacy publication milestones, post-loss lifecycle
  and representation budgets. Resolving them changes the proposed recorder
  architecture rather than repairing prose. Externalise a producer with a
  mandatory fresh review before k182; mark the proposal incomplete at each
  affected clause. Preserve all original k179/k176/k169 criteria.

## Findings dispositions

Findings are numbered as in k183 commit `77e375a8`; sources are the k181 proposal
in both recorder contracts, the native contract's Broker and preheld-PID
paragraphs, and current direct reads of Trace.create/join_messages,
partial_history, analyzer constants and publication_order.py. Graph generation
2026-09-24T05:52:56Z has changed/untracked metadata for these sources; current
source reads, not stale snippet coordinates, ground the conclusions.

| Finding | Classification and disposition |
|---|---|
| 1 | Contract stated unclearly. A contiguous unclosed tail is partial. Missing source becomes impossible only with decisive exclusion; add the commit-only/N-1 truncated-tail discriminators. A later arbitrary row is not automatically decisive. K185 must instantiate closing rules for its lanes. |
| 2 | Contract stated unclearly; explicit trade-off retained. partial_history excludes the suffix. Apply that trust boundary to support and refutation alike; preserve excluded coordinates/reasons. A covering begin plus excluded -1 remains prefix-relative feasible, with no completion credit. No separately trusted recovery lane is introduced. |
| 3 | Real issue, substantial redesign. Native broker and preheld paragraphs place auxiliary traffic on the sockets and use PID relay provenance. K185 must cover those bytes/ordinals or separate connections, and settle origin/egress/supervisor sender binding. Withdraw the blanket audit-only successor claim. |
| 4 | Contract stated unclearly. Local decision correctness against a trusted local receipt is independent of cross-role source feasibility. Repair both contracts; unsupported joins still cannot establish candidate provenance or composed completion. |
| 5 | Real issue, substantial redesign. Trace.create uses four role sequences with start/end and unique PIDs; the proposal does not choose the new lanes. K185 owns topology, original coordinates, loss cuts and projection/permutation effects. |
| 6 | Real issue, substantial redesign coupled to 3/5. One-hop intervals do not define composed destination status or edge inclusion for unavailable/contradictory hops. K185 must settle aggregation, justified edges and cycle preservation. No precedence rule is silently adopted here. |
| 7 | Real issue, substantial redesign. Commit/completion/receipt selection changes producer obligations. K185 must enumerate/map all inherited publication/drain milestones before k182 implements them. |
| 8 | Real issue, substantial lifecycle repair coupled to 5/7. Existing rows/state view omit late return after abandonment, commit-after-loss and deadline-stopped reassembly. K185 owns the complete state model; mark the current view as a partial illustration and forbid inferred completion/buffer reuse. |
| 9 | Real issue, bounded repair. The prose already forbids the malformed call/interval cases, but the discriminator table omits them. Add forged/overlapping/surplus completion, oversize/unmatched results, duplicate IDs, concurrent calls, wrong offset/suffix and post-zero/error attempts. K182 retains executable controls. |
| 10 | Real issue, design budget left open. MAX_LINE=4096 cannot hold a 4096-byte frame plus row encoding; MAX_RECORDS=256 is real, but the review's approximate largest-history arithmetic is not used as a measured budget. K185 must derive concrete frame/row/lane/case caps including auxiliary and short-write traffic. |
| 11 | Real issue in presentation, not a failed check. publication_order.py supplies both opposite edges and builds Trace directly. Narrow assessment/view claims to illustrative reachability only; preserve original evidence bytes. K185 specifies the observable broker reply/result case and k182 falsifies it, with multiple begins/FIFO and real reader paths. |
| 12 | Contract stated unclearly. The native ownership section already assigns the host runner VM collection/stop. Name it explicitly as the independent bound for blocked supervisor/broker ingress/egress; stop requests prove no actual return/cleanup/termination. Native evidence remains k126. |

## Decisions (continued)

- The contract repairs remain diagnostic proposal text. The capture and public
  Accessibility ADRs and CONTEXT.md still describe the same product boundaries;
  no ADR addition or rewrite is warranted. K179 has live k185/k182 work, so
  retirement of this integration closes no node or ancestor.

## Verification

- `task design:check-publication-order`: Ruff lint/format and strict Pyright
  passed; all five supplied-edge examples matched. All 65 selected repository
  Taskfile/Python/config inputs were unchanged by before/after SHA-256 comparison.
  This checks the unchanged illustration, not new publication semantics.
- Changed diagram metadata parses and source/contract links exist; all twelve
  dispositions are present. Local live order is k184 → k185 → k182. Diff scope
  is documentation/Mermaid/diagram metadata only; no executable or corpus change.
- Both contract sections, assessment, captions and view sources reflect repairs
  or name k185's remaining design obligations. K182 retains every k179 criterion.
  No fresh browser/native run or whole-corpus renewal is claimed. K185 must
  inspect the completed views before its fresh review. No node closes here.
