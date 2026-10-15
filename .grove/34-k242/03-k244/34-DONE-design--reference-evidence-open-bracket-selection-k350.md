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

## Decisions (running log)

Bootstrap: the mandate resolves to this live leaf; the brief chain, C/K/P/S/R sections,
CONTEXT and k349's log were read. The launch environment carries no
`GROVE_PROVIDER_EVIDENCE` and no legacy run identity, so retirement writes no Creator line
on k351 and records why, as k344 did. The k349 draft (E3o/BRACKET_OPEN) is a starting
doubt only; this design keeps its useful core and repairs each finding.

D1 — The bracket is defined on the shared publication-events chain. Every publication
invocation appends exactly one publication-events slot whose finalized publication.intent
names either a checkpoint purpose (a **checkpoint batch**) or one of the three closed
inter-checkpoint kinds (an **inter-checkpoint batch**). The **bracket base** is the latest
checkpoint batch with a finalized intent; the **open bracket** is every inter-checkpoint
batch after it, in ordinal order. A batch's members are its publication slot and every
slot whose intent binds that publication.intent; its terminal must list exactly them.
This resolves F2's "which chain": batches are totally ordered on one shared chain.

D2 — The record at every visit (F3) is the checkpoint batch's own publication.intent. It
already binds the checkpoint purpose; it now also binds that visit's E1 held source-root
original identities and the classification vector of the inter-checkpoint batches between
the previous checkpoint batch and itself (empty when none, always at initial CP01). Every
write at any visit, including repeated CP01 without ROOT, a recovery-only host and a
carrier-prefix host, happens inside a publication invocation, so every writing visit has
this record. A visit that writes nothing records nothing, consumes nothing and leaves the
bracket open. cp01.source and trust.continuity keep their copies; a copy that differs from
its batch's intent is a failed join; E3b's base is the intent. A field naming in an
existing record, like k344's, is not a new record kind.

D3 — Non-circular order (F5), for every prelude: (1) unchanged closed structural
traversal; (2) batch partition; (3) at a checkpoint only, root comparison of this E1
against the base intent's identities and each open batch's bound E1i observation; (4)
anchor selection from anchors and bootstrap-kind validation slots only, with anchor
applicability checked against the anchor's own bound disarm/correction basis, never an
open-bracket slot; (5) classification against that anchor; (6) kind/ordinary selection.
A revalidation slot never enters anchor selection.

D4 — Between checkpoints the prelude classifies each open batch only as `BRACKET_OPEN`:
complete U-join, no disposition, same anchor/revision as step 4, immediate successor,
admitted under the table in D5. No identity comparison beyond E1i's own check against the
supplier's independent record, and no BRACKET_VERIFIED/SOURCE_REENTRY_REQUIRED/failed-cut
result, exists between checkpoints (F6's precise forbidden comparison).

D5 — Admission. Shared chains always take the immediate predecessor. Kind table: disarm is
admitted after any open batch (after an open disarm it takes that slot as its release
predecessor; after an open close the close goes stale for CP04, which already refuses a
close older than the newest disarm). Revalidation is admitted after open disarms only,
binding the latest as its current disarm basis. Close is admitted only as the first batch
of its bracket: an open disarm is newer than its CP03 generation, an open revalidation
means its receipt basis awaits CP02, and one close per bracket. A second revalidation,
or revalidation after a close, refuses. Provisional use grows by exactly one case: a later
open batch's bound current-disarm basis. No trust consumer changes.

D6 — Predecessor admissibility (F1), by who finalized the slot: written or disposed in a
checkpoint batch (including a hosted disposition); an inter-checkpoint result recorded
BRACKET_VERIFIED by its closing intent; or BRACKET_OPEN within the D5 uses. A recorded
non-verified batch is admissible only through its finalized disposition.

D7 — Cut and host (F2/F7). Root inequality anywhere in step 3 is SOURCE_REENTRY_REQUIRED
for the whole open bracket, hosted at repeated CP01 SOURCE/ARTIFACTS, as k348 said. With
an intact root, batches are checked in ordinal order: those before the first failure are
BRACKET_VERIFIED; the first failing batch and every later batch form one cut, every slot of
those batches on every chain (a suffix of each chain's bracket slots), because every later
batch binds the earlier one's shared-chain slots. The single host is the earliest of the
cut batches' kind hosts (CP01 < CP02 < CP03; a disarm's CP01-or-CP03 host is read from its
bound scope), extending C's existing "whole cut at its earliest required host" rule. The cut
always ends at the publication-events and launcher-events tails, so the existing carrier
prefix disposes those two tails before the host's intent and the ordinary envelope disposes
the rest. A non-host visit therefore cannot write and refuses before any write; the bracket
stays open. A cut recorded by a host batch whose dispositions did not finish binds every
later visit until disposed. Trust consumers stay at their own checkpoints.

D8 — F4: C over-claimed. S's selected text already scopes "refused at the next checkpoint"
to wrong or substituted executables and keeps deliberate same-UID bypass and mutate/restore
as the cooperative limit. C now says an accidental wrong executable fails E3b's binding or
root comparison, while a deliberate forging same-UID substitute or a mutate/restore can pass
it. S stays byte-identical; no question for Antony. S's "since the previous checkpoint" is
read as the previous visit that retained its identity (D2); a visit retaining nothing has
nothing to compare and authorizes nothing.

D9 — Nothing here adds a checkpoint, ceremony, human act, observation API, authority,
initialization, attempt, record kind or LIVE, so no question goes to Antony. No ADR: this is
a reversible pre-provisioning documentary design inside the selected k348 clause, failing
the hard-to-reverse AND surprising AND real-trade-off test.

Specified in C's new "Selection within an open bracket" subsection with its nine control
pairs, the inter-checkpoint entry (owned-gap block replaced, provisional use widened only to
a disarm basis, accepted-limit wording), the prelude selection row, publication.intent,
cp01.source and trust.continuity rows, host table, dependency expansion, schedule and
durable-disarm text; K's and P's controls; R's "Open-bracket selection" section with every
doubt classified, graph definitions, correction routes and original duties; CONTEXT's revised
entry plus Reference open bracket and Reference bracket record; the root, k242, k244, k245,
k246, k247 and k269 roll-ups; the continuity view redrawn, six status lines and seven
captions, the discussion and README. S is byte-identical.

Final verification ran after every edit, the seven-view render and the freeze of
reference-open-bracket-selection-membership.json. A frozen audit (audit.py with freeze.py and
extract.py in this session's scratchpad, output k350-verification.json) digested 2,130
subjects before and after by byte length and SHA-256: every tracked file, the three scripts
and the resolved task, d2, python3, jj and grove-llm executables. All stayed stable. Inside
the freeze, `task check:docs` and the seven-view render exited 0. Checks passed: the changed
set equals the 30 expected paths; changed, added and removed sections per file equal the
lists written before the run; only the expected glossary paragraphs changed; S is
byte-identical; 704 Goal/Done when sections are unchanged; C carries no owned-gap text and
every subsection element; C/K/P carry the five named controls; only the discussion and
seven captions changed in the manifest; every SVG parses and renders all 41–113 of its label
lines; every membership identity and extract recomputes, the five historical memberships
equal their revisions and the tree, k350's original sections equal their creating revision,
every route row is found, the owned gap is closed, edges resolve and are acyclic, and every
actual original is null. Thirteen controls failed as required on deliberately wrong
subjects: an omitted expected path, an unaffected C section, a one-byte S change, a mutated
Done when, a reintroduced owned gap, a removed admission row, a removed K control, another
glossary entry, an unrelated manifest field, an unrendered label, a one-byte R change
against the membership, an inserted graph cycle and a wrong extraction heading. A full copy
of the tracked tree passed the link checker and failed it once the new anchor was renamed,
naming that anchor.

Three instrument bugs were fixed before the final run, none by changing a document: a
historical entry keyed `snapshot` rather than `revision`; the Notes comparison counted the
blank line before this appended log (the splitter artifact k348 recorded), so it now
compares content without trailing newlines; and the admission-row control first removed the
kinds-table row outside the subsection. The link control's first copy also omitted non-doc
link targets. Playwright Chromium at 1,440 px showed the discussion panel with its status and
seven change markers, the continuity view's new clusters and a fresh deep link to the
updated recovery view, with no console warnings. No mobile, dark, Safari or native-size pass
is claimed; k316/k326 viewer limits remain. These establish documentary correspondence only:
no instrument or control execution, original possession, feasibility or authority.

Done when holds: one coherent specification in C's entry and closed rows covers every listed
element and the block is removed; each rule has positive and isolating negatives in C/K/P,
including the five named cases; nothing outside the envelope is added and S is unchanged;
R classifies every doubt and duty, all layers agree, the new whole membership keeps k344's
and k349's as historical bytes, and the frozen audit passed with controls seen to fail. The
launch carried no provider evidence, so no Creator line is written on k351. Retirement closes
no node: k244 keeps k351, k269 and construction. This paragraph follows measurement.
