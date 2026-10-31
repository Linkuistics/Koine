# settings-keepalive-record-recovery-k120

**Reviews:** settings-keepalive-record-recovery-k118

## Goal
Independently challenge the bounded record format, the one-use slot accounting
and the original-lock collection-recovery protocol that k118 produced. Decide
whether this schema slice is coherent enough for k119 to consume. Do not treat
it as a qualified numerical profile or an implemented mechanism.

## Context
Read the producer commit and the current requirements of k118 and its parent
brief. The primary artifact is docs/specs/settings-keepalive-records.md. The
owner spec, the producer resource-control contract, KEEPALIVE-RESOURCES.md,
KEEPALIVE-QUALIFICATION.md and the record and storage views define its
surrounding obligations. Re-derive against those artifacts. This is a scoped
schema review, not the eventual whole-design review of the complete parent.

## Done when
- Inspect the complete contract. Identify concrete contradictions or missing
  bounds that would prevent correct implementation. Check the typed fields,
  the referenced original objects and the identity, version and absence
  semantics. Check the encoded-size arithmetic, the record multiplicities and
  the required failure and final capacity.
- Try counterexample traces across every allocation, publication and transfer
  boundary. Include death before a byte is written, torn or ambiguous slots, a
  damaged fence and charged-but-unpublished work. Include retained inherited
  holders, partial collection and caller loss. Test the claimed one-use and
  single-global-sequence properties against the actual proposal, including its
  stated fault model and qualification prerequisites. Check that collection can
  use only proven unattempted items. Check that it cannot manufacture authority,
  charges or refunds.
- Check that pool, bootstrap and reference costs account for themselves. There
  must be no circular integrity dependency and no unbounded failure log.
  Distinguish protocol consistency from unestablished physical metadata,
  visibility and native bounds.
- Check reconciliation with the owner lifecycle, the approved substitutions and
  the current visual contract. Later real-coordinator controls must be precise
  and reachable at approved seams. They cannot be demanded before
  implementation. They must not be confused with S1 or native qualification.
  Preserve exactly the approved collector R3 and R5 scope and its separate audit.
- Record supported findings with exact artifact locations, the consequence and
  the smallest useful correction. If there is no substantive finding, report
  that explicitly. Create an integration only if the findings earn it. Its
  charter points to this review and does not transcribe findings as required
  changes. Place any integration before k119 consumes this artifact.

## Notes
Inspection only. No corrections, native execution, dependency work, VM, candidate,
freeze, acceptance or broader substitution authority. All numerical useful-fit,
whole-workload, external evidence and parent reconciliation duties remain live.
No in-session reviewer ran in k118. This leaf supplies the fresh context. The
producer's current provider receipt was absent, so this leaf invents no Creator
evidence.

## Decisions (running log)

- 2026-11-01: Adopt the mandated review leaf in the jj workspace at clean parent
  c9f80bc2. Read the k118 commit and its whole diff. Read the spec, the owner
  spec, the contract, the report and the plan. Read the glossary, the three
  views, the manifest and the README. Read the k117, k118 and k119 bodies and
  the whole brief chain from the root to k112.
- 2026-11-01: Run no test, build, lint, format, image, VM or coordinator command
  on the artifact. Run only the prose checker. It ran on this file, on the
  integration body and once on the spec for a count. The graph was not
  consulted. Every claim below is a direct read of the working copy at c9f80bc2.
- 2026-11-01: This file failed the prose checker as the producer left it. A
  preparatory commit converts it before this edit. No in-session reviewer runs.
  This leaf is the adversarial read.
- 2026-11-01: Recompute every atom, bundle, frame and worked example. Trace the
  one-use, parity and frontier rules through each ambiguity row and the three
  walkthroughs. The arithmetic and the one-use structure hold. No inherited
  contract is violated. Two accounting gaps and seven narrower defects remain
  inside this slice.
- 2026-11-01: The P2 findings change quantities that k119 must instantiate, so
  they must resolve before k119 consumes the spec. Insert the integration
  before k119, the first later sibling with live work. The cut is
  settings-keepalive-record-recovery-k121 at position 04. K119 moves to 05
  with no content change. The body carries this review's handle, not the
  findings. No Creator line applies, because this leaf finishes no producer.
  Retire this leaf only. K112, k107, k102, k98 and k96 keep live work.

## Findings

Severity: P1 means the schema would lead k119 to violate an inherited
contract. P2 means a material omission or inconsistency inside this slice that
k119 must not consume as settled. P3 means a narrower precision, seam or
legibility defect. No finding supplies a numerical capacity, a storage result
or a mechanism result. Each one concerns the proposal itself.

Line numbers refer to commit c9f80bc2, which the working copy equalled at
adoption. "The spec" is docs/specs/settings-keepalive-records.md. "The owner
spec" is docs/specs/settings-keepalive-owner.md. "The contract" is
docs/specs/settings-capture-resource-contract.md. "The plan" is
docs/verification/settings-activation/KEEPALIVE-QUALIFICATION.md. "The report"
is docs/verification/settings-activation/KEEPALIVE-RESOURCES.md.

### P2-1. Publication observations have no carrier after most dependent writes

The spec requires retention of a dependent write-result observation in the
next semantic record or in a kind 20 (spec :496-498). Only kinds 4, 6, 7, 9,
20 and 29 carry an `F` bundle (spec :198-203, :292, :313). The chain works for
the fence and the binding. Kind 7 carries the fence's publication and kind 9
carries the binding's (spec :201, :203).

It stops there. Child creation depends on the commitment's observed
publication (spec :481-483), but kinds 11 and 13 carry no `F` (spec :283,
:285). The completion frame depends on the terminal disposition's publication
(owner spec :251-257), but kind 19 carries no `F` (spec :291). Normal stop
depends on durable stop intent (owner spec :314-317), but kind 22 carries no
`F` (spec :306). Readiness depends on the generation opening (spec :209-210),
but kind 11 carries no `F`.

Collection dispatch depends on kind 25 and kind 5 (spec :544-546). The next
fence carries only `F prior-publication`, whose referent is unstated (spec
:200). So every one of those transitions needs a kind 20 on the clean path,
or the catalogue lacks fields. The spec states that kind 20 is used only when
the next semantic event cannot carry the observation (spec :292). It treats
`v` as an independent input (spec :374-380, :395). Neither statement makes `v`
at least the number of such transitions on every path.

Consequence: two implementations can disagree about whether a kind 20 follows
each commitment, disposition and stop intent. K119 cannot derive `v`. The S2
row enumeration (spec :662) has no normative count for kind 20. The "Failed
commitment publication" walkthrough (spec :626-635) has no retained record of
the observed commitment flush on its clean branch.

Smallest correction: list the transitions whose publication observation must
be retained. For each, add an `F` field to the next semantic record. Where
that is impossible, state that a kind 20 is mandatory there and that `v`
counts it. The candidates are kinds 5, 11, 19 and 22 and the successor's first
fence. Define the referent of `F prior-publication` in kind 6.

### P2-2. Terminal attachments are preassigned per slot but reserved per row

Terminal original-frame and summary objects are preassigned by `(pool, slot,
object-role, element-index)` with opened identities in the layout (spec
:266-270). A crash burns them with their parent slot (spec :269-270). The
glossary states that a skipped or uncertain slot consumes its attachments
(CONTEXT.md :143-145). So the physical reservation is one attachment set per
slot, including parity-skipped slots.

The accounting states otherwise. The pool description names slot objects,
bootstrap objects and the lock, and no attachments (spec :324-326). Logical
pool bytes are `S * sum(N_lane)` plus bootstrap object bytes (spec :408-409).
The attachments are then "reserved" by the per-row path calculation (spec
:410-413).

With `N_lane >= 2 * rows` (spec :406-407), a per-row count reserves
at most half of the per-slot attachments. The logical byte formula omits them
entirely. `T_data` in the physical formula (spec :417-418) is never defined.

Consequence: k119 following the formulas under-reserves terminal bytes and
objects. The check `available >= transition cost + remaining tail` (spec
:441-442) is then computed against an incomplete total. The S2 accounting
control (spec :662) has no correct expected value.

Smallest correction: state that attachment reservation is per slot. Define
terminal logical bytes as `S * sum(N_lane)`, plus the per-slot maximum
attachment bytes summed over all slots, plus bootstrap objects. Define
`T_data` as that quantity. State that a parity-skipped slot's attachments are
consumed capacity.

### P3-1. Kind 7's terminal-reservation has no meaning under sequential slot choice

Kind 7 carries `V(A,2) terminal-reservation`, where `A` is first, count and
maximum frame bytes (spec :149, :201). Slots are consumed strictly in order,
and the next record takes the first permitted slot after its predecessor
(spec :345-349, :129-131). An attempt's rows interleave with worker phase and
submission rows, so no contiguous range per attempt exists.

Consequence: an implementer either reserves a range that the acceptance rule
forbids, or puts a count in a field named `first`. Smallest correction:
replace the field with the slot and byte quantities the transition computes.
Or delete it and state that terminal reservation is the in-memory tail check.

### P3-2. Expected kinds of reference fields and the profile digest preimage are unstated

Every `R` carries an expected kind that the reader checks (spec :53, :84-86).
The catalogue names each `R` by role only. No row states which record kind or
object type it expects. Examples are kind 1 `pool-layout`, kind 3
`physical-layout` and `bootstrap-manifest`, and type 4 `object-layout` (spec
:195, :197, :238). No object type carries the physical slot layout that
`physical-layout` implies.

The common frame's frozen profile digest (spec :101) has no stated preimage. The manifest rules (spec :212-218) describe what
it must not include, not what it digests.

Consequence: the S2 "wrong type" fixture (spec :661) has no normative expected
value, and two encoders can bind the same field to different objects.
Smallest correction: add the expected kind to each `R` in the catalogue and
object tables. Name the object type for the physical layout. Define the
profile digest's exact input.

### P3-3. The successor lane's first rows and the normal-handoff disposition have no stated order or lane

Recovery writes kind 25 then kind 5 as the successor lane's first rows (spec
:544-546). The caller's containment and holder observations precede lock
acquisition (spec :504-511). Kind 24 and kind 11 rows for that window can
only follow kind 5. Kind 25 names `R original-lock-observation` (spec :309). A
known reference cannot point forward to a later kind 11 (spec :88-90), so that
field must name an attachment. The spec does not state it.

On a normal handoff the caller burns unused slots (spec :366-368). Kind 25 has
a `normal-handoff` mode (spec :158). No lane is named for that row.

Consequence: the S3 recovery-entry control (spec :665) cannot pin an expected
row order, and the `previous` and `causal` chain for the successor's first
rows is undefined. Smallest correction: state the successor lane order. State
that kind 25's lock and holder references are attachments. State that the
normal-handoff kind 25 is the first caller-final record.

### P3-4. Kind 10's multiplicity is ambiguous

Kind 10 is "first failure plus bounded later distinct controls `q`" (spec
:204). The count vector reserves `q` (spec :395), and the accounting defines
`q` as distinct priority controls (spec :375). Consequence: an off-by-one in
the terminal tail. Smallest correction: state that `q` includes the first
failure, or write `1 + q`.

### P3-5. Four barrier positions per terminal write are not in the lifecycle contract

The S3 slot-consumption row names five stop points per write (spec :663):

- before slot choice
- after choice and before the first write
- after a real prefix
- after the full write and before the flush observation
- after the observation and before the dependent record

Two are write-result substitutions the contract approves (contract :231-232).
The other three end the owner process and need barriers. The owner spec names
three barrier positions (owner spec :542-545). The report states that the
approved points are those the lifecycle and scheduling contracts specify
(report :530-531). The k118 commit edited the owner spec without adding these
positions.

Consequence: the spec claims "approved seams" for positions the authoritative
contract does not list. Smallest correction: add the per-write barrier
positions to the owner spec's test-seam section as members of the approved
audited-copy class. Or state in the spec that the implementation manifest
must declare them there first. No new substitution class is involved.

### P3-6. The commitment ceiling now holds three observed publications and a directory creation

Steps 2 to 4 require a fence write, a binding write and a commitment write
before child creation (spec :466-483). Each needs observed write, flush and
visibility results, and the directory creation sits between them. The owner
spec gives two seconds from ownership to published commitment (owner spec
:659-662, :752). The spec names no reconciliation of that ceiling with the
fence width `W` and the flush cost.

Consequence: k119 can instantiate `W` and the phase ceiling independently and
obtain an infeasible profile. Smallest correction: name the ceiling
reconciliation as a k119 input in the remaining-inputs section (spec
:679-685).

### P3-7. The spec fails the prose checker and carries no marker

The spec has 182 hard findings under the technical-communication checker,
mostly semicolons, and no `tc:` marker. Convert it, or mark departures, before
k119 or an integration edits it. The owner spec sentence "Only the owner
assigns event sequence numbers" (owner spec :175) is also stale. The caller
now writes three lanes with slot-index sequences.

### Supported items

These claims hold against the inherited contracts and recomputation. They
need no correction.

- The atom sizes, the 384-byte frame, the eight bundle sizes and the five
  worked size examples recompute exactly (spec :44-55, :95-107, :141-150,
  :294-295, :384-387).
- Namespace assignment is collision-free: core namespaces 1 to 9, field-local
  101 to 129, object-local 202 to 212 and registries from 1000 (spec :151-169,
  :245-248).
- The count vector matches the catalogue multiplicities for every kind except
  the kind 10 ambiguity in P3-4 (spec :394-395).
- The parity rule holds. With one open fence and at least one even row between
  fences, each attempted row costs at most two slots (spec :345-349). So
  `N_lane >= 2 * rows` suffices (spec :406-408).
- One-use holds structurally. A successor burns whole owner ranges, the
  caller's own cursor covers its three lanes, and no verb reopens a slot (spec
  :13-17, :366-371, :561-564). The bootstrap digest rules avoid a cycle (spec
  :212-218).
- The ambiguity table covers every boundary the charter names (spec :566-579).
  The three walkthroughs agree with the ordered steps and the storage view
  (spec :614-648, keepalive-storage.mmd).
- Collection fences are written in plan order, so recovery can dispatch only a
  plan suffix above the last valid collection fence (spec :550-557). The
  "proven unattempted" rule is sound under the visibility prerequisite.
- No path manufactures a charge, a refund, a replacement ordinal or scenario
  authority. Refusal and unstarted cancellation keep their terminal cost (spec
  :446-447).
- The prerequisites table separates protocol consistency from process-loss
  visibility, metadata and native bounds, and the fault model excludes power
  loss (spec :581-602).
- The later-controls table keeps S1 in the plan and adds no executed case to
  the 13-case envelope (spec :652-657). It reproduces the approved R3 and R5
  scope exactly (spec :670).
- The owner spec, contract, plan, report, glossary and README edits in the
  producer commit agree with the spec, apart from the P3-5 and P3-7 items.
- No decision earns an ADR yet. The lane choice records its alternatives
  inline (spec :604-610).

Evidence limits: no project command ran on the artifact. Only the prose
checker ran, on this file, on the integration body and once on the spec for
the count in P3-7. The graph was not consulted. Every claim is a direct read
of the working copy at c9f80bc2.
