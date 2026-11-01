# settings-keepalive-workload-accounting-k135

**Reviews:** settings-keepalive-workload-accounting-k132

## Goal

Challenge the combined workload scheduling and record-accounting derivation before downstream consumption.
Retain every k124 obligation and distinguish derivable constraints from missing qualification inputs.

## Context

Read the producer commit through its stable handle and the complete k124/k119 brief chain.
The primary artifact is docs/verification/settings-activation/KEEPALIVE-ACCOUNTING.md.
Its consuming changes include the owner, record and producer contracts, resource worksheet,
scheduling assessment, workload inventory and architecture discussion.
The inventory derives from k131, its k133 review and k134 integration.
The embedded verification receipt supplies narrow arithmetic and document checks only.

## Done when

- Check complete operation paths against the reviewed inventory and exact helper sources.
  Include poll endpoints, waits, uploads, archives, six baseline captures and migration additions.
  Preserve producer-internal OCR/input/frame work and both caller tails.
- Challenge start's separate 600-second queue family and unknown non-queue stages.
  Keep failed-start identity/containment and post-start 152-second admission constraints intact.
- Challenge the active-time bound across failure cuts and local/control work.
  Distinguish due, charged and published ticks without counting blocked service twice.
- Derive mandatory and fallback carrier counts independently.
  Test the clean 2a+7 identity, coarse failure envelope and fences without assignments.
  Check every publication against its actual lane, shared phase and overlapping deadline.
- Challenge the catalogue sum, fixed parameter count and every supplied size relation.
  Check the preparation/layout dependency, vector maxima and finite simultaneous-solution requirement.
- Check all five lane maxima, parity losses and complete per-slot attachment reservations.
  Include failed, skipped and uncertain slots, both transfer sequences and final summaries.
- Challenge the remaining-tail recurrence and state families, fence width and ordinal frontier.
  Preserve uncertain collection allowances, held-pointer failures and physical metadata costs.
- Identify any source-supported value that the derivation improperly leaves unspecified.
  Conversely, identify any invented finite bound, zero cost or implicit successful join.
  Keep exact evidence scopes with k125 and final numerical fit/reconciliation with k126.
- Report findings against committed source locations and classify their material impact.
  This scoped review does not replace the later whole-design review or perform its integration.

## Notes

Design inspection only. No implementation, VM, native experiment, freeze, acceptance or cap expansion.
Control results remain future obligations after their executable subjects exist.
Retain first-failure stickiness, original/partial evidence and the prohibition on corrective release.
Retain all k89/k81/k76/k67/k62/k57/k54 duties and existing historical failures and closed slots.

## Findings

The derivation agrees with the reviewed inventory, the owner spec, the record
schema and the pinned start helper. Every coefficient, size and identity that I
re-derived matches. The seven findings below name the location, the consequence
and the smallest correction. Finding 1 is medium. The rest are low. None adopts
a capacity or changes a counted operation, wait or image.

- Finding 1, medium. KEEPALIVE-ACCOUNTING.md line 135 charges 152 seconds to
  every post-start `A_i`, and lines 143 to 160 build `B` and `K_due` on it.
  Only a live tick can hold a scenario request past its own six seconds of
  phases. Sleeps and tick lifetimes are disjoint. Every due tick follows one
  complete sleep inside `[t0, ts]`. So `20 * K_due` is at most the scenario
  time with no live tick. That time is at most
  `sum_i (6 + W_i) + D_p + L_p + H_p`. The stated bound therefore adds about
  146 seconds per operation. The inventory expands to thousands of operations,
  for example 1,190 reveal snapshots. That excess multiplies the reserved tick
  slots, attachments and images that k126 must fit. State the tighter bound
  with this argument, or label the stated bound a deliberate envelope. Also
  state at line 134 that `W_i` is at most the family whole allowance.

- Finding 2, low. Line 252 says a fence with no assignment requires the
  schema's fallback treatment. The schema requires a fallback kind 20 only when
  kind 7 or kind 9 cannot retain its predecessor observation
  (settings-keepalive-records.md lines 748 to 751). Lines 756 to 759 make the
  next fence carry the prior fence's observation. No schedule row names kind 6
  as a kind-20 target, so a strict reader rejects such a row. Lines 257, 258
  and 328 build `F6 <= a + f + f_c` on that reading. Either label the extra
  rows deliberate over-reservation. Or amend the carrier schedule and the
  kind-20 target rule to require a final-fence fallback.

- Finding 3, low. Lines 497 to 507 head the missing-input table "Required
  return and owner". The rows for messages and local processes, native
  containment, raw collection and storage name no owner. The k119 handoff says
  k125 consumes this table. Assign each row to k125 or k126.

- Finding 4, low. Line 343 states that the parameter vector has exactly 29
  entries. The schema lists the entries in prose groups at lines 407 to 415.
  "Maximum receive/parser/scan live bytes" reads as one entry or three. The
  receipt's 29-length assertion checks the kind-count vector, not the
  parameter vector. Enumerate the parameter vector one name per entry in the
  schema. Then check that count in the receipt, or say at line 544 that it
  was not machine-checked.

- Finding 5, low. Line 137 leaves `D_p` symbolic. The inventory and the source
  determine every explicit wait. Restart and post-login polls alone reach
  30 + 60 * 5 + 24 * 5 = 450 seconds. Ten reveals add up to 600 seconds,
  calibration 31, both drags 6.4 and 23 menu clicks 36.8. The table at lines
  48 to 65 names sleeps for drags, calibration and reveals but not for clicks,
  menu frames or choices. Add a per-path maximum `D_p` for E and A as a
  baseline cross-check under the existing "not a total" caveat. Include the
  click and menu sleeps in the table.

- Finding 6, low. The derivation relies on due, charged and published ticks,
  publication carriers, fallback carriers, writer lanes and the start family.
  CONTEXT.md lines 65 and 138 define only "Keepalive tick" and "Allocation
  fence". The owner spec, the records spec and the worksheet now use the other
  terms too. Add glossary entries, or name the records spec as their defining
  vocabulary.

- Finding 7, low. KEEPALIVE-RESOURCES.md lines 188 to 189 still call 120/142
  seconds "the current" start target. The owner spec table now has a dedicated
  start row. Reword that sentence or mark it historical.

## Checked and clean

- The coefficient table at lines 48 to 65 matches the inventory's cross-check
  table and helper rows. Menu clicks `2 * choices + reads` give 9 and 23.
  Reveal success on read `r` gives `2r - 1` snapshots and `r - 1` scrolls,
  so ten successes give 1,190 and 590. Restart, post-login, Add-button,
  TextEdit, drag and calibration bounds match scenario lines 52, 116, 271 to
  282 and the desktop helpers.
- The six baseline captures are scenario lines 108, 136, 172, 204,
  218 and 293. The three uploads are the archive and client in `install_app` and the
  enrolment client at scenario line 83. `start_vm` creates the keepalive
  subshell before its first guest read, so cadence precedes P02.
- The start family's 600 seconds matches the pinned CLI and the scheduling
  inventory row. The 22 non-CLI seconds match the owner spec phase table.
- `v(p) = 2a + 7` and `v <= 4a + f + f_c + 8` follow from the carrier table.
  The nine clean carriers match the schema's schedule.
- `R_terminal` follows from the schema's count vector with kinds 14 and 15
  removed. The constant 18 and the `a * (g + 7)` term match.
- `L6 = 772`, `L7 = 856 + 168u`, `L20 = 632`, the K4 constant 396 and
  `K28 = 828 + 80j` match the catalogue.
- The twelve-slot final lane follows from odd lane starts and even-only kinds.
- The 152, 150, 142, 58, 30, 20, 8 and 5-second figures match the owner spec.
  The admission argument `2 + 2 + 2 + 142 + 2 = 150` is the spec's own.
- The five lanes, the successor entry order 25, 20, 5, 20 and both final
  orders match the schema.
- `f <= ceil(a_o / W) + 1` and `f_c <= c` follow from the one-open-fence rule.
  The tail recurrence matches the schema's remaining-tail rule.
- K132 and k134 reflect k133's six findings. The k132 body names the four extra
  counts. The inventory cites the family table and the eight process roles.
- No new seam, dependency operation or ADR appears. The derivation retains all
  k89/k81/k76/k67/k62/k57/k54 duties, held-pointer cases and historical limits.
- The receipt pins 211 unchanged subjects. Its link check reports only the
  two k23 archive targets.

## Decisions (running log)

- 2026-11-01: Adopt k135 at clean parent ffcf9627. Read the two k132 commits
  and the complete brief chain. Read the accounting, inventory, owner spec,
  records spec, worksheet, scheduling evidence, producer contract and receipt.
  Read the start, scenario and capture helpers directly. Spend no in-session
  reviewer.
- 2026-11-01: Re-derive every identity and size. All match. Record one medium
  and six low findings. Cut integrate-review-design under k124. The tighter
  time bound and the schema disagreement are precise corrections. The
  derivation is a load-bearing input to k125 and k126.
