# settings-keepalive-workload-inventory-k134

## Goal
Triage the k133 review findings against the k131 workload inventory and apply
the real ones before k132 consumes the inventory.

**Integrates:** settings-keepalive-workload-inventory-k133

## Context
Read the k133 leaf for its findings and clean checks. Read the k131 commit and
KEEPALIVE-WORKLOAD.md with its diagram and both manifest entries. The
inventory's counts matched source on review. Do not re-derive a count unless a
fix touches it.

## Done when
- Each k133 finding has a recorded disposition: applied, rejected with a
  reason, or a visible accepted trade-off.
- Applied fixes change no counted operation, wait or image, and keep every
  missing input explicit.
- The document check still reports only the two existing k23 archive targets.
- The consuming documents and the k132 body agree with the inventory after integration.

## Notes
Design documents only. No VM, native experiment, implementation or cap
expansion. K132 remains the next live sibling after this leaf.

## Decisions (running log)

- 2026-11-01: Adopt k134 at clean parent 9ad322c3. Read k133's findings from that
  commit and the k131 producer commit. Keep the reviewed operation, wait and
  image counts unchanged.
- 2026-11-01: Classify findings 1 and 2 as unclear contracts. K124 already binds
  the four omitted accounting duties. The owner already states the family
  allowances. Make those obligations and their source explicit before k132.
- 2026-11-01: Classify finding 3 as an unclear contract. The pinned input source
  shows scroll pulses, key events and modifier sleeps inside one operation.
  Qualify the proposed per-character wording: newlines are skipped, and uppercase
  conversion can produce several key symbols. Add no owner operation or scenario wait.
- 2026-11-01: Classify findings 4 and 5 as real document issues. Use the worksheet's
  process enumeration and draw failure routes from scenario nodes with solid arrows.
  Keep both manifest captions consistent with that distinction.
- 2026-11-01: Classify finding 6 as a real prose issue. Convert the inventory and
  k132 body before substantive edits, in a separate preparatory change.
  Preserve every value, ordered step and missing input. No new ADR or redesign
  follows from these clarifications. No additional reviewer is needed.
- 2026-11-01: Apply all six findings. Conversion commit ca2babab preserves all
  inline source tokens, numeric values and table-row identities in order.
  The subsequent edits add the family citation, qualified internal-input costs,
  worksheet process list, solid failure routes and explicit k132 duties.
  K132 also names internal input events. No counted operation, wait or image changes.
- 2026-11-01: Use Tier 2 evidence at Koine generation 2026-11-01T04:06:00Z.
  Read the entire Mermaid source because coverage marks lines 1–38 partial.
  Dependency searches returned no input-method matches, so read the pinned input file directly.
  The keymap graph lookup and pinned source establish scroll decomposition.
  Dependency coverage generation 2026-10-29T07:11:24Z records no gaps for those two files.
  This is source evidence, not installed-binary or native qualification.
- 2026-11-01: The document check reports exactly the two existing k23 archive targets.
  Task status remains 201 and checker status remains 1.
  Digests match before and after for all 208 documentation sources, anchor targets,
  task/checker files and selected diagram inputs.
  Counted inventory tokens match the review parent, and a numeric mutation fails that comparison.
  Both manifests resolve to the same source and agree on arrow meaning.
- 2026-11-01: Inspect the current diagram in Chrome through the existing design:serve
  task on port 8813. Port 8812 was occupied and returned no usable page.
  The rendered SVG contains solid scenario failure routes and no local render error.
  The owner, worksheet and presentation handoffs retain the same unresolved inputs.
  K132 remains live, so no ancestor closes. No VM or native control runs.
