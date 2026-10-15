# reference-evidence-open-bracket-selection-k350


## Goal

Specify, inside Antony's k348 "Bracketed entry (Recommended)" clause, how the shared prelude
gate selects state for an inter-checkpoint invocation while its bracket already holds earlier
batches, and how the next checkpoint verifies, cuts and hosts a multi-batch or mixed-kind
bracket. Deliver a coherent C/K/P/report/view repair before reference-evidence-construction-k269.

## Context

K332 (findings in its own commit e398d7df2b0a) reviewed whole k331 at 2d927a83725e. Its G1
is real: k344's closure placed E3b, which exists only after Antony's E1 at a checkpoint,
before every ordinary selection, while the inter-checkpoint gate reuses ordinary selection and
refuses any unaccepted reachable tail. C's durable-disarm rule nevertheless requires a fresh
successor disarm before every change, correction or unchanged-input requalification, so more
than one maintenance batch between two checkpoints is the ordinary correction path. K349's
integration clarified only that E3b never runs between checkpoints and placed an explicit
owned gap in C's [inter-checkpoint entry](../../../docs/verification/application-reference-evidence.md#inter-checkpoint-publication-entry);
its report is application-reference-input-partition.md#k332-integration-and-open-bracket-repair.

K349 tried and withdrew a candidate repair: between checkpoints, an "open-bracket" check
within E3 admits each earlier finalized, completely joined batch bound to the same anchor and
revision as `BRACKET_OPEN` (no root or E1i comparison, no record); only disarm may take a
`BRACKET_OPEN` predecessor; close and revalidation run once per bracket; the next checkpoint's
E3b verifies batches in chain order and a failure carries later batches into one cut. Its one
narrow adversarial check found seven defects, each re-derived against C. These are this
leaf's specific doubts, not a work list; the design may reject the candidate entirely:

- **Disposed predecessors.** A predecessor may be a slot a checkpoint already disposed of
  (hosted failure.disposition), as in the fresh disarm after a hosted disposition. The
  candidate's "bracket-verified" or "published" predicate either refuses it forever or admits
  an undisposed failed batch.
- **Which chain.** Every batch also appends to the shared publication-events chain, and
  publication.intent binds that chain's full finalized predecessor. Define "same-chain"
  exactly, decide whether kinds may interleave in one bracket (for example a fresh disarm then
  receipt revalidation between CP02 visits), and state the cut extent along both chains.
- **Hosting a mixed cut.** C's host table hosts each kind separately (disarm at CP03 or
  CP01; close at repeated CP03; revalidation at repeated CP02). A cut spanning kinds can
  deadlock when one host waits on another. Name one deterministic host rule, with source
  re-entry still first.
- **The bracket's starting record.** cp01.source is written only after ROOT and
  trust.continuity only at CP02–CP05, so a repeated CP01 visit without ROOT, or a visit that
  stops at recovery-only selection, retains no root identity or E3b classification. Name the
  existing record that carries both at every visit, or the exact boundary.
- **Selection order.** validation-events holds the anchor's bootstrap validation and
  revalidation batches, so anchor selection and any check against the selected anchor must
  not be circular.
- **E1i wording.** E1i itself compares identities between checkpoints; any "no comparison
  between checkpoints" rule must name the forbidden comparison precisely (against
  cp01.source/trust.continuity root identities).
- **Accepted-limit wording.** C says a non-original executable's register writes are refused
  at the next checkpoint, but a deliberately forging same-UID substitute (stale E1i, forged E8
  vector, unchanged originals) passes E3b; S keeps deliberate same-UID bypass as the
  cooperative limit. Reconcile C's claim with S without adding a mechanism. If S's own
  selected sentence must change, that is Antony's decision.

## Done when

- One coherent specification in C's inter-checkpoint entry and closed selection/traversal rows
  covers: selection for a later invocation while the bracket holds earlier batches; exact
  predecessor admissibility including disposed slots; chain identity and kind interleaving; E3b
  order, cut extent and one deterministic host per cut; the record carrying the root identity
  and classifications at every checkpoint visit; and a non-circular selection order. Remove
  k349's owned-gap block only when this is specified.
- Every rule has an independently authored positive and isolating negative in C/K/P,
  including two successive disarms, a disposed predecessor, any admitted interleaving or its
  refusal, a failed earlier batch carrying its successors, and a root change across a
  multi-batch bracket.
- No checkpoint, ceremony, human act, observation API, authority, initialization, attempt,
  record kind or LIVE is added and S's selected sections stay byte-identical; a necessary
  change outside that envelope, including any change to S's limit sentence, goes to Antony as a
  bounded trade-off with a recommendation before it is specified.
- R records the classification of each doubt above and the original k348/k331 duties met.
  CONTEXT, root/k242/k244/k245/k246/k247/k269 roll-ups and the seven views stay consistent.
  After the final edits, freeze a new whole documentary membership that keeps k344's
  reference-checkpoint-recovery-membership.json as historical bytes, then run the frozen
  documentary audit with controls seen to fail.
- The closing session names its own provider evidence on the existing review
  reference-evidence-open-bracket-selection-k351, immediately before k269.

## Notes

Design only. No instrument/control execution, provisioning, initialization, authority act,
installed query/contents/protected/topology/process/terminal probe or posture change. Actual
required originals/tools/controls/identities remain unacquired. K244/k242 stay live; the pass
is unused; full k246/k247/useful/additive supported-VM/native/private/product duties and both
holds remain. Post-consumption correction stays offline-only, never renewed eligibility,
appointment, acquisition or a permit reset. A documentary repair qualifies no instrument.
