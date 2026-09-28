# callback-publication-control-observability-k221

**Reviews:** callback-publication-control-observability-k220

## Goal
Adversarially verify that every retained path/composite control can actually
observe its asserted mutant through a specified interface before k205.

## Context
Read the producer's committed artifact, k218 review and k219 dispositions.
Re-derive query issuance from the rule inventory, not merely endpoint reachability.

## Done when
- Check every P-* and composite has an exact rule-instance or isolated-seam
  identity, concrete operands/support and determinate raw/usable results. Run
  each rejected algorithm conceptually against its actual asserted column;
  unchanged sample summaries are not kills. Verify honest neighbors.
- Challenge production isolation, test result identity/consumer guards, bounds,
  and production Q exclusion for arbitrary test queries. No caller-supplied
  adjacency, grade or expected truth may bypass real loading and frozen Trace.
- Independently verify R11 local-ending order/frame distinction, R29 clean
  reverse alternative and every rule-issued query witness/census, including
  B8/B20 window membership and fixed-coordinate collector permutations.
- Verify explicit G90→T34 bundle omission retains all Trace edges; distinguish
  its frame outcome from an unspecified selected-begin mutant. Reconcile both
  contracts, evidence, lanes, capacity, assessment, views and k205.
- Record located findings in this review's own commit and insert integration
  before k205 only if needed. No fixes, execution claims or legacy renewal.

## Notes
Inspection only, no in-session reviewer. Preserve every k203/ancestor criterion,
k205 numeric freeze and all native owners. No ancestor closes.

## Decisions (running log)

- Read k220 at `7991d15` (parent `1c574fe`) with k218's findings (`be55352`)
  and k219's dispositions. Rebuilt every edge from all 18 committed row files
  with a fresh scratch builder. It applies only the stated inclusion rules:
  local order, begin→actual receipt by direction/ordinal with byte equality,
  origin joins, and W-input/W-enter from producer markers. Bundles and masking
  follow R:387-430. No k217/k220 arithmetic or archive was reused as an oracle.
  No repository check, loader, render or successor was run; no artifact edited.
- The finite claims hold. The observation contract is sound in structure. One
  mutant row makes a kill claim its mutant cannot produce, and the delivery
  mutant that motivated Q01/Q02 has no row. The rest are precision gaps. An
  integration is needed before k205: insert
  callback-publication-control-observability integrate-review-design at k205,
  carrying only this review's handle.

## Findings

Read against k220 commit `7991d15`. Prefixes: `P:` publication-path-controls.md,
`R:` publication-replay.md (both in docs/verification/callback-native-capture/).
Most severe first.

What holds up. The independent rebuild reproduces 386/387/389/390 edges and SCCs
{G28,G29} and {T34,T35,B25,B26,B27,G89,G90}. Its bad receipts are T4 and
{G89,T34,T37}. All nine probes match P:431-442 exactly, including P-reverse-clean
raw F/2, usable F/6, and P-end-up/P-end-multi T/T/1. All 41 census rows match
P:602-644 in multi-cycle, and the four-exception T/T statement in the other
files, with clean windows 23/22/11/6. Physical pairs are identical across the six
files. The reversed and round-robin collector files give itemwise-identical
results. The Q36 raw path really uses the bad G89→G98 relay join and G99→T37
contributor; usable is the 76-edge sampler route. Q34/Q35 prepend 12/11 local
edges. Omitting only G90→T34 from D(T34) turns P-multi to T/T and leaves S/W U.
The query inventory is complete. That was re-derived from the rules, not from
the legacy trace: outside/overlap/closed-unordered give four pairs per activity
(R:664-700); the window members are B:4/5/10/12 with C empty (R:314-330); the
enclosure gives six consecutive orders; the hint/acquisition chain gives three;
selected_callback gives three; delivery support gives Q01/Q02 (R:217-222); and
capture/returned/retention give four. Recipe-issued pairs outside legacy's 33
are exactly the six activity and two delivery pairs. The frame-algebra table
agrees with the AND/OR/NOT and masking rules at R:488-535. The production entry,
closed catalogue enum, distinct result kind, two guarded boundaries,
production-report equality and overlay bounds name their observers. 2×9×334 and
2×41×334 are correct. The contracts, lanes, evidence, capacity, the assessment,
k205 and both views agree with P.

### 1. The sequence-number mutant row claims a Q02 kill it cannot produce; the delivery edge-presence mutant has no row — medium

P:564 lists "Sequence number as strict causal order | Production Q15 and Q37
U→T; Q02/Q13 cyclic delivery/ack claims also expose it". Q13 (B25→B26), Q15
(T34→T35) and Q37 (B25…B31) are same-lane local chains, so that mutant turns
each U→T. Q02 is T35→B25, controller to B. Its only path is the W-input edge
itself, which is cyclic. No sequence relation exists across lanes. Comparing
physical observation_seq would even point backward (35 vs 25). The mutant cannot
change Q02. The row also renames P:364's "Local sequence proves strict order
through an SCC": two names for one mutant.

The mutant Q02 actually isolates is the one R:217-222 and P:588-589 give as the
reason for adding Q01/Q02: granting delivery T on W-input edge presence. That
turns Q02 trigger_input.delivery U→T in multi-cycle. Q01 is T either way, so
independent_B is not a kill column. No row names this mutant, its column or
its honest neighbour (multi-clean Q02 T/T/1). Required: drop Q02 from the
sequence row or restate it; add the edge-presence delivery mutant with its Q02
column and neighbour; use one mutant name in both tables.

### 2. Production Q14 and Q16 already expose endpoint-inclusive vertex inheritance and SCC-vertex rejection; only test probes are credited — low

P:558, P:560 and P:654 are affected. In multi-cycle, Q14 (B20→T34) is T/T/11.
Its only usable path ends at bad receipt T34 through local T33→T34. Among
production queries in both cycle files, it is the only one whose usable path
reaches a bad receipt. An endpoint-inclusive vertex-inheritance mutant turns it
T→U. It is the production local-ending order T/frame U at the armed receipt,
beside A(T34)=T/U. Q14 also ends at SCC vertex T34, and Q16 (T35→S17, a
noncyclic W-enter edge) starts at SCC vertex T35. An endpoint-inclusive "reject
any SCC vertex" mutant turns both T→U. P-local and P-vertex exercise interior
vertices only; P-end-up and P-end-multi are test-only. The design's goal
prefers real report claims. Name Q14/Q16 as production observers for the
endpoint variants and keep the probes for interior variants. The conjunction U
still needs the test `required`, because selected_callback is already U via Q15.

### 3. Q34/Q35 name a consumer, "target activity-before-closed rule", that no successor rule defines — low

P:646-647. The legacy source is selected_activity (analyze.py 1884 in
evidence/k220/legacy-order-calls.txt). The successor's window membership over
members(B) already includes activities (R:314-330). No separate
activity-before-closed rule exists in the fact formulas (R:649-700) or elsewhere
in R. P:580-582 requires explicit rule ownership for query families, and k205
counts claims from rule arities. Either delete that consumer or define the rule
and its claim, so k205 need not guess a max_claims term.

### 4. Catalogue admission and cross-catalogue sharing are underdetermined — low

P:386-403, P:431-443 and P:478-482. (a) No table maps catalogue to admitted
fixtures (for example upstream-order/1 → clean and upstream-cycle), although a
catalogue/fixture mismatch must refuse. (b) split-order/1 gives P-multi and
P-end-multi expectations only for multi-cycle and multi-clean; the turn0 pair has
none, although P:506-508 states turn0 invariance for frame-algebra only.
(c) P:479-480 shares results "by query identity if both catalogues run", yet
the entry takes one catalogue_id per call. P:545-548 requires catalogue-order
permutations to change nothing. Sharing therefore implies a cache outliving one
invocation, with no observer, or the phrase is dead. State the admission map
and turn0 expectations; remove sharing or confine it to one invocation.

### 5. Raw support selection for the upstream bare-and/owned-and tie is unspecified — low

P:489-503. In upstream, raw A=F and N=F both refute A AND N. R:518-520 selects the
lowest stable rule ID. P:502-503 orders count.Z before frame.A, but it never
places test composite N relative to frame.A. P:500-501 requires both raw and
usable selections to be retained, while the table lists usable support only.
Give N's stable ID, or a raw support column.
