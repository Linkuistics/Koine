# callback-publication-path-candidates-k266

## Goal
Run k253's model on k265's generated histories for the obvious candidate
families at production scale. Record what each one actually stores, and learn
from the runs whether 2^23 is reachable. If it is, find the +1 lever. If not,
find where an infeasibility proof must bite.

## Context
The k254 brief (Goal, Notes, planning Notes) and k265's running log. The k251
brief's Notes: in multi-cycle, a cyclic local edge in B and a bad input-B-2
ingress bundle push Q34–Q36 through the whole sampler lane. That gives 88/87/76
edges against spans of 23/22/11. Also the four outside/overlap comparisons
toward S:29. The k249 same-lane lemma and its cyclic premise. The k250 per-base
headroom and startup ceiling. The capacity doc's dimension table, for every
other dimension that a large Q charges.

## Done when
- Each candidate family is a named generator vector that passes the envelope.
  The families cover four cases: acyclic long same-lane chains, target-lane
  cyclic local edges that force detours through the longest other lane, bad
  ingress bundles that force usable detours, and many activities per target
  (the coverage row's premise of 256). Include their combinations as the runs
  suggest. Each family is swept to the largest size that still fits every
  other dimension by k249/k250's methods, and the dimension that stops it is
  named.
- For each candidate the census records V, E, Q, witness_refs, total,
  shared_total and `path_bound`, and checks that total ≤ bound. It also records
  the witness-length distribution by query family, so the reason a family
  falls short can be seen.
- The leaf ends in one of two ways.
  - Reachable: a candidate's total is at least 8,388,608. It comes with a named
    +1 lever: a change of one row that moves exactly one query's witness by one
    edge. The census checks that no other query's witness, and no SCC or D
    witness, changes under that step.
  - Not reachable: the leaf names the mechanism that caps the best candidate,
    and states a conjectured upper bound that holds on every candidate tried.
    Neither is yet a proof.
- The outcome and the best vector are promoted to the k254 brief for k267.
  `task design:check-publication-profile` is green with its record under
  evidence/k254. Each new check fails under a deliberate mutation. No profile
  constant or document changes.

## Notes
The k254 Notes say: explore before proving. A total built from queries whose
witnesses shift together cannot be tuned. So a lever candidate must be shown
isolated, and it cannot just be asserted. If the sweeps show that another
base, not V18, carries the best candidate, and k265's generator cannot express
it, cut that generator extension as a leaf ahead of k267. Do not absorb it
here.

## Decisions (running log)
- The generator gains one placement parameter, `Pad(owner, anchor, neutral,
  frames, begins)`. It emits rows just after one named base record (role, event,
  message). Neutral rows are semantic (local on the supervisor), and frames are
  unrelayed frames to the supervisor, like the added commits at `end`. Without a
  stated hop, no padding can sit between a query's endpoints. At k272's
  placement, B's added frames come after `closed`, so activities are never more
  than about 250 rows from their comparison endpoints. The empty-pads default
  reproduces all six files and k272's two runs unchanged.
- Exploration, before the census (scratch runs of the model): comparisons are
  about 97 % of every total. Each is a shortest path. For a target activity it
  pays (a) the target lane's rows between that target's last receipt (finish-B
  or finish-C) and the activity, and (b) the connector from the other endpoint
  (b = B's input 101 or m = sampler m_end) to that receipt. Padding frames
  placed after the finish-X receipt are charged by 8 witnesses per activity of
  that target only. That is the "same-lane chains" family, at 5.10M.
- The supervisor lane is a total order of every ingress and egress, so it
  bypasses any funnel that is not itself on the supervisor lane. Controller rows
  (254 neutral rows and 70 frames placed before finish-B) are never on a
  shortest path, and the total fell to 2.44M. Supervisor local rows, placed
  after the last supervisor entry of every route (the controller's
  finished-sampler receipt), are charged by both targets' m-pairs and C's
  b-pairs. They are capped by the controller's parallel route (254 neutral rows)
  and by LOCAL_ROWS: 46 spare local rows add about 0.19M. Frames on a funnel
  leak through their own contributor exits.
- Cycles: multi-cycle's split (armed hoisting input-B-2) makes B's b-pair
  usable witnesses detour through the sampler lane. That adds about 0.28M, and
  raw is unchanged. Every other one-message hoist behind armed, sample-release
  or input-B-1 (36 tried) lowers the total, to between 1.47M and 5.45M. A
  larger SCC turns the activity queries U, so usable witnesses go empty. The
  reversed ready-C join adds 2 (its SCC only).
- A sampler funnel of 202 neutral rows after m_end, in place of the 202
  acquisitions, is charged by every activity's m-pairs. That adds about 0.39M.
- Best tried: 5,906,808, which is 70.4 % of 2^23. It combines target frames
  54/55 at 9 begins, the multi-cycle split, the sampler funnel after m_end, and
  254 controller neutral rows plus 46 supervisor local rows after
  finished-sampler. The case commits (161) stop the frames. Producer seq 256
  stops the activities and the sampler funnel, and LOCAL_ROWS stops the
  supervisor funnel.
- Local rows: `envelope_violations` does not cap local rows (only 2,048 per
  lane), and k272's SCALE uses 829 supervisor local rows. Candidates here hold
  case local rows to LOCAL_ROWS (64), the kind maximum in V. With uncapped local
  rows, the funnel is still bounded by the controller route. A 1,400-row
  supervisor funnel with controller frames reached only 5.85M.
- Controller neutral rows are capped at 228, not 254: its 28 base records hold
  producer seqs, and the eligible seq is 256. The census now checks producer
  seqs (`seq_violations`) and case local rows ≤ LOCAL_ROWS (`candidate_envelope`)
  on top of `envelope_violations`. Both are checks for these candidates only.
  No envelope constant changes.
- Census (`path_candidates`, under evidence/k254), at each family's largest
  fitting size. The figures are the stored total and its per-mille of 2^23.
  many activities 750,494 (89). same-lane chains 4,993,414 (595).
  target-lane cyclic edge 5,261,012 (627). bad ingress bundle (reversed
  ready-C join) 4,993,416 (595). wider cycle (armed hoisting finished-B)
  1,716,699 (204). controller funnel 2,441,078 (290). combined 5,906,808 (704).
  Every total is ≤ its path_bound. The family's size one step beyond is refused
  with the cap named. Target frames stop at case commit 162 > 161 (and case
  receipt). Begins per frame stop at the lane cap 9 × commits. Activities stop
  at B producer seq 257. The sampler funnel stops at sampler producer seq 257,
  and the supervisor funnel at case local 65 > 64. The same-lane sweep (18/19
  and 36/37 frames: 2.19M and 3.59M) is linear in frame rows. Other dimensions
  (claims, diagnostics, support, query work) were not recharged by k249's
  method here. The queries are 2,466–2,668, the same families as k272's 2,413.
- Outcome: not reached. The best is `CANDIDATES["combined"]` at 5,906,808.
  Mechanism: per-target charge. A padding row can lie on a comparison witness
  in only three places. (1) In a target's interior (its lane after the
  finish-X receipt), where it is charged by that target's activities alone
  (8 per activity). (2) In a pad frame's first commit and begin, a witness
  crosses at most EXIT_ROWS = 2 rows of the other interior before leaving by
  the contributor edge. (3) On an exit-free connector row (neutral semantic or
  local rows), charged by at most 4 per activity plus 4 per activity of one
  target. Frames on a connector leak through their own exits. The supervisor
  lane bypasses every connector not on it, and a cycle wide enough to force a
  longer detour empties the usable witnesses.
- Conjectured bound, checked on every candidate as total ≤
  8·Σ n_t·I_t + (4n + 4·max n_t)·X + 8n·EXIT_ROWS + other refs. The premise
  (no witness crosses more than 2 rows of a second interior) is checked on
  every witness. At the envelope's maxima it gives 7,657,312 (91 % of 2^23).
  The inputs are n = 240/247 activities, 2,679 interior rows (all 109 free
  commits as 20-row frames), 786 crossed outside rows (the same-lane chains'
  310, plus 228 controller, 202 sampler and 46 local exit-free rows) and 48,120
  other refs. If both interiors are read as one shared funnel, it gives
  12,800,992, so the infeasibility proof must bite on the per-target premise.
  Mutations caught: interiors read as one (the premise check fires), and the
  bound without its crossed-outside term (combined exceeds it). The per-target
  conjecture fails at the envelope under the shared-interior mutation.
- No +1 lever is named, because no candidate reaches 2^23. V18 carries the
  best candidate. No other base was needed, so no generator-extension leaf is
  cut.
