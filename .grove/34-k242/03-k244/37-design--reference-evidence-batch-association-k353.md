# reference-evidence-batch-association-k353

## Goal

Specify, inside Antony's k348 "Bracketed entry (Recommended)" clause and k350's open-bracket
design, which batch every reachable slot, member, failure.disposition and pre-intent write
belongs to, and what step 2 of the prelude's selection order reads to establish it. Deliver a
coherent C/K/P/report/view repair that closes the owned gap k352 left in C's open-bracket
subsection, before reference-evidence-construction-k269.

## Context

K351 (findings in its own commit a42632d07c4e) reviewed k350 at 0150fea96112. Its G1 is real:
C's open-bracket subsection defines a batch's members as its publication slot plus every slot
whose intent binds its publication.intent, and step 2 partitions every slot from intent
bindings alone. That covers neither the disarm seed release-events/0, finalized before any
publication.intent exists, nor a hosted failure.disposition, which a checkpoint batch writes
into a slot whose immutable intent binds the failed batch, before the host's own intent when
the carrier prefix is used. The predecessor rule nevertheless needs "disposed inside a
checkpoint batch", and the host's terminal must retain those writes. K352's integration and
its report section are in application-reference-input-partition.md#k351-integration-and-open-bracket-repairs;
C's gap block is in its
[open-bracket subsection](../../../docs/verification/application-reference-evidence.md#selection-within-an-open-bracket).

K352 tried and withdrew a candidate repair: a slot's immutable **origin batch** (the batch whose
publication.intent its intent binds; the seed in the batch at publication-events/0) versus a
disposition's **disposing batch** (the hosted checkpoint batch whose intent names the slot in
its expected member set or reached carrier-prefix facts, with the disposition binding the same
checkpoint/substep, cut manifest and nonce); members as publication slot, originated slots and
written dispositions; predecessor admissibility through a checkpoint origin or a checkpoint
disposing batch. Its one narrow adversarial check found seven defects, each re-derived against
C. These are this leaf's specific doubts, not a work list; the design may reject the candidate:

- **Seed when intent 0 fails.** If publication.intent/0 fails (host row "publication.intent
  before an anchor exists"), the repeated-CP01 host's intent lands at /1 and binds the seed;
  batch 0 has no finalized intent, so "the batch at publication-events/0" is no checkpoint batch.
- **Reserved, empty and partial slots.** A reserved-but-empty or partial slot (C's durable
  disarm rule: an empty/partial directory/intent still disarms) binds nothing, so an
  intent-bound origin misses it and it escapes the cut and the host's ready-manifest gate. Can
  the existing expected member set, which names exact slots, supply the origin instead?
- **A batch whose own publication.intent is partial.** It is neither batch kind, so it is
  outside the open bracket and every cut, and no rule names its host when its kind is not
  recorded durably. State its cut membership and one deterministic host, or the exact
  unavailable boundary; a choice outside the k348/k350 envelope goes to Antony.
- **A batch's own publication slot.** Its intent binds the previous publication slot, so
  "the batch whose publication.intent its intent binds" names the wrong batch; both readings
  break admissibility of the first open batch after a checkpoint.
- **Members and terminal retention.** Every chain row lists a conditional failure.disposition
  as a slot member, so a later disposition is counted in both batches, and an origin batch's
  terminal cannot retain a future fact. "Retains exactly those" also over-claims: the terminal
  retains direct acts, manifests and comparisons too.
- **The disposition association.** The publication.intent row has checkpoint/substep and a
  fresh invocation nonce but no failed-cut manifest; trust.disposition binds the ready act's
  manifest/nonce. Name the exact existing fields (for example the hosted ready plan the intent
  binds) and whether the trust expected set names each trust.disposition by chain/ordinal,
  including dispositions in publication-events slots.
- **Other pre-intent writes.** Container, lock and approval-subject reservations at initial
  CP01 and missing reservations at repeated CP01 precede the intent, yet "every write at a
  checkpoint happens inside such a batch". Associate them or state why they are not slot writes.
- **Cut tails (predates k352).** "The cut always ends at the publication-events and
  launcher-events tails" over-claims when a cut batch failed before reserving its launcher slot.

K352 repaired G2–G4 independently: the between-checkpoint rule now defers only the
cross-checkpoint source-root comparison and any E3b verdict; recovery routes read H0 → H1 → H2
(carrier prefix, ordinary envelope, archival join) → H3; the integration membership carries
the whole-cut earliest-host route. Keep those repairs.

## Done when

- One coherent specification in C's open-bracket subsection and closed selection/traversal/
  payload rows gives every reachable slot, member, disposition and pre-intent write exactly one
  association, states exactly what step 2 reads for each, and covers partial/unfinalized
  publication intents with their cut membership and host. Remove k352's owned-gap block only
  when this is specified.
- Every rule has an independently authored positive and isolating negative in C/K/P,
  including initial bootstrap, a failed intent 0 with repeated-CP01 recovery, a reserved empty
  slot in a cut, a fresh disarm after a multi-batch carrier-prefix recovery, and
  wrong/missing/cross-batch association negatives.
- No checkpoint, ceremony, human act, observation API, authority, initialization, attempt,
  record kind, write location or LIVE is added, no original is rewritten and S's selected
  sections stay byte-identical; a necessary change outside that envelope goes to Antony as a
  bounded trade-off with a recommendation before it is specified.
- R classifies every doubt above and the original k350/k348/k331 duties met. CONTEXT, root/
  k242/k244/k245/k246/k247/k269 roll-ups and the seven views stay consistent. After the final
  edits, freeze a new whole documentary membership that keeps k350's and k352's memberships as
  historical bytes, then run the frozen documentary audit with controls seen to fail.
- The closing session names its own provider evidence on the existing review
  reference-evidence-batch-association-k354, immediately before k269.

## Notes

Design only. No instrument/control execution, provisioning, initialization, authority act,
installed query/contents/protected/topology/process/terminal probe or posture change. Actual
required originals/tools/controls/identities remain unacquired. K244/k242 stay live; the pass
is unused; full k246/k247/useful/additive supported-VM/native/private/product duties and both
holds remain. Post-consumption correction stays offline-only, never renewed eligibility,
appointment, acquisition or a permit reset. A documentary repair qualifies no instrument.
