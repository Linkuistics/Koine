# callback-publication-replay-k212

**Reviews:** callback-publication-replay-k211

## Goal
Adversarially verify the completed consumer classifier, evidence domains,
inherited support and resource contract before k205 plans executable delivery.

## Context
Read k211's own commit, k210's dispositions and k209's committed findings.
Re-derive results from the revised artifacts and current source; neither earlier
review nor integration is an assumption of correctness. All original k203 and
ancestor criteria, the unchanged legacy CLI and V1–V26 preservation still bind.

## Done when
- Try to falsify every sample-state/scope branch and U precedence, especially
  open-tail no-enter, core=T with ambiguity=U and closed unordered activity
  versus a missing broker edge. Check the causal state table and R15 agree.
- Check counting versus endpoint eligibility and domain closure with all three
  k209 duplicate histories, semantic closed followed by recording loss,
  open/closed empty domains, repeated boundaries and ordinary C-post absence.
- Challenge inherited frame contributors on an otherwise clean order path,
  raw-F cyclic support under NOT/AND, independent refuters/alternatives and
  R10–R13/R22/R23. Require separate order, frame, composed and raw outcomes.
- Check finite claim/support/path/output budgets, interning, transient storage
  and exact-limit/over-limit failure controls. If k205 owns numeric freezing,
  require named budgets, a derivation obligation and explicit ordering before
  implementation; no input-cap-as-report-bound substitution.
- Require determinate expected results, honest neighbors and isolating mutants
  for each new policy through the existing file seam. Check both contracts,
  evidence/capacity, assessment, views and k205 reflect the same rules. Proposed
  histories and browser checks establish neither executable nor native success.
- Record located falsifiable findings without fixes. Insert any integration
  immediately before the still-live k205 planning sibling. Preserve all original
  criteria and named k180/k177/k143/k144/k126 and k124/k121 duties.

## Notes
Fresh inspection only; no implementation, expectation renewal or native run.
Render/view only in a disposable clone if needed. No ancestor closes here.

## Decisions (running log)

- Read k211 at `09a9703` (parent `c28b604`) against k209 `61d93ad8` and k210's
  dispositions. Inspection only: nothing was run, rendered or regenerated.
  Findings 1–5 are located counterexamples against the revised rules. Findings
  6–7 are precision and test-seam gaps. An integration is needed before k205. Cut
  it immediately before the still-live k205 planning sibling, carrying only this
  review's handle. Created callback-publication-replay-k213 there.

## Findings

Read against k211 commit `09a9703` (parent `c28b604`). Prefixes: `R:`
docs/verification/callback-native-capture/publication-replay.md, `E:`
transport-evidence.md and `L:` transport-lanes.md beside it, `C:`
publication-capacity.md, `K:` callback-causal-fixture/contract.md, `A:`
callback-causal-fixture/analyze.py. Source and documents were read only. No
control, render or native run was performed. Most severe first.

What holds up. The counting table (R:241-247) and the exact-count/at-least
formula (R:256-260) give determinate results for all three k209 histories
(R:281-296). Those results agree with R06/R07/R18. A closed collection implies
every raw row is in replay, because work after end, a fault or a gap prevents
closure (R:262-270). Raw-versus-eligible counting therefore diverges only on
open collections, where it is intended to. The classifier table (R:538-547) is
exhaustive over usable T/F/U. The state view matches it arm for arm, and so do
K:498-507 and E's summary. R15's four histories follow from R:482-534. The
closed-unordered certificate needs every observed receipt to have full
attribution and no unmatched message. That separates a closed, resolved,
disconnected activity (ambiguous) from a broker gap (U → partial) without
turning no-path into F. R26–R28 follow from collection closure and the window
formula (R:300-321). The emergency header arithmetic holds: 32×51 + 2048 < 4096
(R:774-778). The capacity doc (C:197-225) names every R:749-756 dimension, and
k205's Done when orders numeric freezing before implementation. The profile
derivation cites real input multiplicities: 10,240 case rows, 256 producer rows
and 1,280 begins. It does not substitute an input cap for a report bound. Legacy
state classification (A:1779-1790) and the K:490-495 table are unchanged.

### 1. Vertex-keyed receipt inheritance over-masks local lane order and breaks the reviewed monotonicity invariant — medium-high

R:366-369 makes an order claim inherit the bundle of "every receipt vertex on
its selected forward or reverse path, endpoints included". R:374-376 fixes the
shortest canonical path before masking, and forbids a retry. R13 (R:714) confirms
the vertex reading: a receipt with cyclic inherited dependencies on a clean path
makes the order U. Local edges join adjacent physical rows (E:184). A same-lane
segment of any path therefore passes through every receipt row recorded between
its endpoints. It does so whether or not the proof uses that receipt's incoming
message edge.

- **(a) Unrelated receipt taints a local order.** Take a controller lane with
  armed(r1) at 10, an unrelated B ack receipt r2 at 11 and the trigger post at
  12. r2's frame has contributing begins b1 and b2. A wrong relay join makes
  b2→r2 intra-SCC. r2 also has a provenance edge leaving the SCC, so r1 and the
  post are outside the SCC (the R:713 shape). selected_callback's
  B→armed→post→enter path must traverse r1→r2→post over local edges. It
  inherits r2's cyclic bundle and becomes U. So do core and state. The proof
  of armed-before-post is lane order and never uses r2's attribution. The same
  applies to same-role sampler orders (enter→f_begin) through any receipt rows
  between them. This contradicts R:342 ("An unrelated cycle never vetoes the
  query"). Under an edge-keyed reading, inheriting only where the path uses a
  contributing/join edge into the receipt or an admission prerequisite, the
  result would be T. The artifact states no reason for the vertex choice.
- **(b) Adding supported evidence can remove a positive order.** L:228-229 states
  that "An established positive order cannot disappear solely because more
  supported edges were added." Let order(x,y) be T via a four-edge clean path with
  no tainted receipt. Add one honestly supported supervisor edge that creates a
  three-edge clean path through a receipt whose bundle holds a pre-existing
  cyclic contributor. No new cycle is created. The canonical path is now the
  shorter one. Inheritance masks it and no retry is allowed, so usable truth
  falls from T to U. R02 (R:703) is exactly the added-supervisor-order control,
  yet it expects only resolution, never loss. The artifact neither reconciles
  L:228-229 nor lists this non-monotonicity as a trade-off (R:796-805).

No R control separates reaching a receipt by a local lane edge from reaching it
by a contributing/join edge. None pairs added-edge monotonicity with a tainted
receipt either. R10/R11/R13 all route through the receipt's own frame.

### 2. Controller `interpretation` has an undefined phase/tuple scope, so ordinary C posts and C tuple mismatches have two results — medium

R:462-466 makes `interpretation` F on "any positive local refutation" among the
controller's "phase, tuple and locally qualified receipt/decision checks". Step 1
then yields unsupported (R:540). Elsewhere the same observations are specified to
keep an otherwise reached sample:

- R:193-196 enumerates W-input for a forbidden C post in an ordinary path and
  says to report that phase violation independently, "do not erase sound
  evidence by failing the producer first".
- R:557-561: ordinary retention needs exact-count(C posts=0). "Retention F or U
  preserves callback-sample scope." Legacy does the same (A:1724-1735, A:1779-1797):
  a C post under `ordinary` gives retention_order false with reached/callback-sample.
- R07 (R:708): "Tuple mismatch removes W-input and retention credit". Its honest
  core remains reached.

Concrete history: schedule `ordinary`, all four collections closed and honest,
core T and no duplicates, with one in-replay controller C post. If phase
refutation belongs to interpretation, the state is unsupported with scope none.
If it does not, the state is reached with callback-sample scope and retention F.
Both readings satisfy current text. R28 covers only zero posts and a tail post
(where interpretation is already U). The same split applies to a C-target tuple
mismatch after the callback. The artifact must enumerate which controller checks
refute interpretation, versus which only refute their own claims. It must also
add an in-replay forbidden-post control and a controller tuple-mismatch control
with their state.

### 3. The successor reuses legacy state names with different meanings — medium-low

K:494 defines partial as "Some sample observations exist but a required …
premise is missing". The successor assigns partial to interpretation U (R:541)
and to present U (R:543). Both can hold with zero sample observations; R24's
open-tail empty sampler is an example. K:492's unsupported means parsing,
structural reading or malformed controller evidence. R:773, C:222, K:3343 and
the native contract's line 1608 also assign `sample.state=unsupported` to report
resource exhaustion. That is analyzer capacity, not evidence, and it lies outside
the "exhaustive" classifier (R:536). R:455-458 says both classifiers "retain"
these five states. The k211 assessment row for gap 1 says the table agrees
"without changing legacy meanings". A consumer comparing successor and detached
legacy columns sees the same word with a different premise. It cannot tell
"sample observed, premise missing" from "sample presence unknown" or "resource
limit" without reading reason strings. Integration should either give these arms
distinct state names, or explicitly redefine the successor vocabulary and
correct the agreement claims. R24/R31 need expected states that make the
distinction checkable.

### 4. Core's absence and ALL sub-predicates have no assigned domain semantics, so R25's core=T is not derivable — medium-low

R:497-502 declares enclosure/pair/acquisition "prefix-relative facts, not closed
absence claims", using observed-count-one milestones/acquisitions. The migrated
acquisition_validation recipe (A:1676-1698) also contains:

- preheld: `not select("hint")`, an absence claim, and ALL acquisitions before
  enter, an ALL over a sampler domain;
- acquire-resample: `len(acquisitions) == len(hints) == 1`, exact counts
  including hints, which R:500 does not name.

R:446-451 says ALL over an open domain has a U remainder. The R:256-258 exact
count is U for n=k on an open collection. Applied as written, R25's open-tail
acquire-resample history gives acquisition_validation U. Core is then U, not the
"Core T" R25 asserts (R:726). Applying "observed-count-one" instead would make
core T while a lost tail hint or acquisition is unexamined. That contradicts the
algebra's own ALL rule for a reported fact column. State stays partial either
way, because duplicates are U. However, the core column and R25's expected
report are indeterminate. Integration should assign each core sub-predicate
(hint absence, hint count, ALL acquisitions, exact acquisition) to
prefix-relative or closure-aware semantics. It should state R25's resulting core
value and add a preheld open-tail neighbour.

### 5. Duplicate producer coordinates count as independent events; armed counting departs from the raw principle — low-medium

R:236-237: "A duplicate original coordinate counts as two assertions". Suppose
the sampler producer emits enter at producer seq 2 in two physical rows. K202
removes only duplicate *physical* coordinates (publication-files.md:145-146), so
both rows are retained. Enter's count is 2, which gives duplicate-envelope T
(R:247, R:473) and state ambiguous. K:495's ambiguous means "repeated core
milestones". The evidence here is one milestone asserted twice by a faulty
producer: an instrument contradiction already reported under R:103, not a second
callback. The same applies to a B input duplicated at one coordinate. Its
exact-count is F (n>k), so independent_B is *refuted* (R:256) rather than
unproved, with no second delivery evidenced. No R control contrasts a duplicate
at one coordinate with two distinct coordinates. R18 names only "duplicate
producer coordinates retain independent domain findings".

Separately, the stated principle is that raw retained assertions defeat
uniqueness beyond semantic cuts (k211 decision; E's summary). The W-enter armed
set (R:246) counts only qualified receipts "mapped and in replay". A second
well-formed armed receipt after a controller fault is outside replay. It is
diagnosed but does not defeat observed-count-one admission. A tail enter does,
per R18. Closure prevents any credit consequence here: selected_callback needs
closed exact-one armed counts. But R:246's "Do not filter later qualified
receipts out of the count" then reads falsely for tail receipts. Integration
should state both choices and give each a control.

### 6. R30/R31 need an injectable report profile that the single-entry seam does not provide — low-medium

R:35-39: "two file paths in … Callers do not supply grades, edges, prefixes or
expected reports." R30 sizes a stress case and profile "so usage equals its
limit". R31 reruns "the same stress case under a profile one unit below required
usage". Every dimension must be exercised independently (R:731-732). A conservative
frozen profile, such as Q×(V−1) path refs (R:753), is not reachable by one real
history in every dimension at once. R30/R31 therefore need a test-only profile
different from the frozen one. Nothing names where that profile enters or how
production cannot select it: a budget-bypass seam of its own. Nothing says
whether any control runs at the frozen profile's actual limits. Integration or
k205 must name the profile-override seam and its guard. It must also say which
controls bind the frozen values themselves rather than a substituted profile.

### 7. R11/R29's scalar-refuter clause depends on unstated bundle ownership — low

R:440-441 adds a composite's own mandatory support after operand selection and
cannot be masked by OR. R:409-412 and R:444 mask the result to U whenever that
support cycles, including a raw F. R11 (R:712) nevertheless says "An independent
scalar F operand can still refute the conjunction". R29 (R:730) says a scalar
refuter "makes AND F". That holds only if the conjunction owns no cyclic bundle.
R11 does not say whether its composed claim owns the frame bundle. The
composites the classifier actually uses do own such bundles: selected_callback
owns composed armed attribution (R:384); independent_B/C own their "necessary
causal support". Example: turn=0 (scalar F) with a cyclic armed contributor. By
R:440-444, selected_callback is U/cycle-contradicted. R11's sentence suggests F.
Core becomes core-unproved rather than core-refuted. Integration should state
R11's composite ownership and give the scalar-refuter variant's exact result.
