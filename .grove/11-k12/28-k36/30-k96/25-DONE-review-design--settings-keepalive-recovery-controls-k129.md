# settings-keepalive-recovery-controls-k129

**Reviews:** settings-keepalive-recovery-controls-k123

## Goal
Challenge the expanded record and recovery control design before workload accounting or complete-profile reconciliation consumes it.

## Context
Read the producer's committed diff and docs/verification/settings-activation/KEEPALIVE-RECOVERY-CONTROLS.md.
Read the integrated record schema, owner and producer contracts, qualification baseline and k119 brief chain.
The producer adds two visual views and a document-check receipt with expanded design IDs.
The receipt establishes no coordinator, native or VM result.
No in-session reviewer ran in k123.

## Done when
- Check every k123 completion condition against the complete proposed control contract.
- Challenge preservation of the original eighteen cases and the completeness, uniqueness and meaning of each finite product.
- Trace slot choice, empty uncertainty, actual prefixes, complete writes, flush/visibility observations and dependent effects.
- Check all mandatory carriers, failed embedded-carrier fallbacks, attachment reservations and bounded K29 failure reporting.
- Challenge successor entry, normal transfer, both final paths, causal links and delayed observation order.
- Check original-lock ownership, burned ordinals, unknown charges and the proven unattempted collection suffix.
- Check that named modules and invocation sites reach the intended boundary through an approved seam.
  Inspect the directory-create ownership reconciliation and publication-result field substitutions in particular.
- Challenge case reachability, process parentage, actual simultaneous overlap and the distinction between design IDs and executable invocations.
- Check malformed fixtures, both held-pointer cases, signals, abrupt loss and every retained lifecycle/scheduling obligation.
- Record actionable findings without applying fixes. Cut an integration only when findings earn it, before the first live sibling consumer.

## Notes
This is scoped design review. It supplies no whole-design review, useful numerical profile or runtime authority.
Missing implemented subjects and native bounds remain prerequisites.
K124, k125 and k126 retain their existing duties. No ancestor closes from this slice.

## Decisions (running log)

- 2026-11-01: Adopt the mandated review leaf in the jj workspace at clean parent 2a94515f.
  Read both k123 commits and their whole diff. Read the design, the receipt, both views, both manifests and the README.
  Read the schema, the owner spec, the contract, the plan, the scheduling and resource reports and the raw-control design.
  Read the glossary, the k117 to k128 bodies and the whole brief chain from the root to k119.
- 2026-11-01: Run no test, build, image, VM or coordinator command on the artifact.
  Run the prose checker only on this file and on the integration body.
  Consult no graph. Check the one backend source observation by a direct read.
  No in-session reviewer runs. This leaf is the adversarial read.
- 2026-11-01: Recount every product, the W targets, the terminal-kind coverage, the stop rows, the deadline boundaries and the containment boundaries.
  Trace each k123 completion condition, each owner-spec control row and each scheduling matrix row to its cases.
  The arithmetic, the eighteen identities, the successor order, both final paths and the directory-create reconciliation hold.
  Three P2 findings and four P3 findings remain.
- 2026-11-01: The P2 findings change what k124 may count and what k126 may treat as settled, so they must resolve before k124 consumes the design.
  Insert the integration before k124, the first later sibling with live work. The cut is settings-keepalive-recovery-controls-k130 at position 06.
  K124 to k126 move up one position with no content change. The body carries this review's handle, not the findings.
  No Creator line applies, because this leaf finishes no producer. Retire this leaf only. K119 and its ancestors keep live work.

## Findings

Severity: P1 means a consumer following the design would violate an inherited contract.
P2 means a material omission or inconsistency inside this slice that k124 to k126 must not consume as settled.
P3 means a narrower precision, seam or legibility defect.
No finding supplies a capacity, a storage result or a mechanism result. Each one concerns the design itself.

Line numbers refer to commit 2a94515f, which the working copy equalled at adoption.
"The design" is docs/verification/settings-activation/KEEPALIVE-RECOVERY-CONTROLS.md.
"The schema" is docs/specs/settings-keepalive-records.md.
"The owner spec" is docs/specs/settings-keepalive-owner.md.
"The contract" is docs/specs/settings-capture-resource-contract.md.

"The plan" is docs/verification/settings-activation/KEEPALIVE-QUALIFICATION.md.
"The scheduling report" is docs/verification/settings-activation/KEEPALIVE-SCHEDULING.md.
"The resource report" is docs/verification/settings-activation/KEEPALIVE-RESOURCES.md.
"The receipt" is docs/verification/settings-activation/ordering-keepalive-recovery-controls/verification.json.
"The k96 brief" and "the k98 brief" are the node files of those handles.

### P2-1. The products are not disjoint, and the inventory counts about twenty-five cases twice

The design states that every ID is one independently reportable case (design :15).
It states that the later products do not count the original cases twice (design :81).
Its total row names 1067 disjoint design IDs (design :547).
The W product expands every target over all seven cuts (design :108).
That uniform expansion regenerates most of the original eighteen as members.

Twelve original cases coincide with a W case in module, invocation and cut:

- S3-before-fence is W-fence-choose.
- S3-partial-fence is W-fence-prefix.
- S3-fence-before-assignment is W-fence-observed.
- S3-charge-before-binding is W-binding-empty.
- S3-partial-binding is W-binding-prefix.
- S3-binding-before-directory is W-binding-observed.
- S3-directory-before-commitment is W-commitment-choose.
- S3-commitment-before-execution is W-carrier-observed.
- S4-result-before-disposition is W-terminal-choose.
- S4-ack-before-reap is W-reap-choose.
- S4-handoff-before-final is W-normal-final-choose.
- S6-terminal-prefix is W-terminal-fail-prefix.

Two more are near coincidences.
S4-send-before-echo differs from W-send-observed only in whether the owner wrote the K19 send row.
S5-inherited-holder and G-holder-resolved describe one schedule (design :100, :331).

The expansions also overlap each other.
CF-commitment is W-carrier-fail-zero, because the carrier target is the K20 for the first K9 (design :150, :215).
The schema's fallback rule fires on every failed K7 or K9 carrier (schema :743).
So FB-K7-retained is W-binding-fail-prefix, and FB-K9-retained is W-commitment-fail-prefix (design :232-237).
FB-K7-writer-lost is W-binding-prefix, and FB-K9-writer-lost is W-commitment-prefix.

For the A product, slot choice means reserving the containing event's slot (design :244).
So A-submission, A-recovery and A-final repeat the choose and empty cuts of W-received, W-recover and W-final.
In L-overlap-<holder>-tick-first the owner admits the tick first, so the capture holds and the named holder is the waiting request (design :360-361).
Those three cases repeat L-capture-CLI-clean under a different label.

Consequence: the manifest must bind each design ID to exact invocations (plan :431).
It may not mark a product passing from one representative invocation (design :552).
Under those rules a duplicated case runs twice, or the one-ID-one-invocation binding breaks silently.
K124 derives carriers and costs per ID, so its totals inherit the double count.
The claim at :81 is false as written, and the eighteen lose the separate identity the plan requires.

Smallest correction: keep the original eighteen as canonical IDs. Name each coincident W, G or FB member as an alias of its original.
Remove CF-commitment, the four FB cases and the six A cases from the expansion, or declare them aliases.
Rename the tick-first overlap cases by the holder that actually holds, or fold them into L-capture.
Restate the total as distinct cases plus declared aliases. Do not replace the alias table with a count of itself.

### P2-2. The C product's negative outcomes depend on a controlled result the contract does not list

The C product's observer is the approved named publication-result site (design :190).
For each negative outcome, the target bytes are complete and the copied result reports a failed or unknown flush or visibility field (design :196).
The real calls succeeded, and their results remain separate control evidence (design :196).
The contract approves two controlled shapes at a write site: error before any write, and failure after a real retained prefix (contract :231-235, :246-250).
The resource report records the approval in the same terms (resource report :564).
A complete write followed by a reported flush or visibility failure is neither shape.

The design hedges at :193, where a site that cannot expose that result leaves the case unavailable pending a seam decision.
That sentence concerns exposure, not approval.
The design also states that it substitutes only named write results (design :29).
The contract now states that the design identifies approved copied boundaries and adds no substitution class (contract :285-286).
The k107 charter requires asking Antony before calling a new substitution class approved.

Consequence: forty-eight C cases rest on a controlled-result shape nobody approved, and k124 counts their carriers as settled.
Planning would implement a copied site that contradicts a successful real call, which the contract neither permits nor forbids.
The plan's S3 row already requires failed and unknown flush observations (plan :438). The need stands. The gap is in the contract.

Smallest correction: name the third shape in the contract's controlled-result column.
It is a complete real write with a reported failed or unknown flush or visibility result.
Present that row to Antony as an explicit choice with its copy-audit cost.
Until then, mark the forty-eight negatives unavailable pending that decision.
State in the design which choice the C product assumes. Keep the clean outcome on actual calls.

### P2-3. No case has a tick become due during a scenario's post-CLI validation

The k96 brief requires a control for a due tick during OCR, exec or transfer and during post-CLI validation (k96 brief :26, k98 brief :18).
The design preserves the original owner and scheduling controls (design :355).
L-overlap uses holders OCR, exec and transfer with two arrival orders (design :360).
Its scenario-first schedules admit the tick while the holder's CLI runs.
No schedule has the tick arrive after the holder's CLI exit and before its terminal publication.
L-capture covers the opposite direction only, a scenario arriving during a capture (design :365, owner spec :637).

The owner spec's control row and the scheduling matrix name the same three holders and no validation phase (owner spec :636, scheduling report :175).
So the gap predates k123, but the k96 item is still open and this slice claims to preserve the original controls.

Consequence: a mutant that releases ownership to a due tick at scenario CLI exit passes every L case.
The owner spec forbids that release while a validator, unpublished result or unfinished delivery remains (owner spec :829-830).
K126 could read :355 as closure of the k96 item, which no reviewed slice discharged.

Smallest correction: add a holder phase to L-overlap, or add `L-overlap-validation-scenario-first` with the tick due after the holder's CLI exit.
Reconcile the owner spec's row and the scheduling matrix to the same coverage.
If the item is deliberately deferred, name it as an open k96 obligation in the design and the k126 handoff.

### P3-1. The cut table's failure-carrier clause is wrong for four target classes

The fail-zero and fail-prefix cuts require a failure carrier in a new slot (design :121-122).
For the carrier target the failed record is itself a K20, and no K20 may report another K20's failure (design :150, :217, schema :740).
For the root, profile and pool targets, the K4 publications vector carries the preparation result (schema :720).
For the fence target, no K7 follows a failed K6, so the carrier is a K10 or K29 row, not a fallback.
The design states the exception for K29 targets only (design :127).
For A-bootstrap, the layout preassigns the object and the design defines no slot choice (design :244-245).

Consequence: eight W cases and two A cases carry an oracle that the schema contradicts or leaves open.
Smallest correction: name the failure carrier per target class in the cut table or in a short table below it.
State the choose and empty cuts for the bootstrap object, or exclude those two IDs.

### P3-2. One seventeen-byte prefix leaves the header-complete torn frame untested at the scan

Every partial control writes exactly `P` bytes, and `P` is 17 for every frame (design :47-48).
Seventeen bytes end one byte after the magic, version, kind and flags words (schema :220).
No torn fixture carries a complete root, generation, slot index, `previous` or `causal` field without a valid digest.
The scan refuses an indistinguishable damaged slot and may use a structurally complete, properly linked fence as a conservative frontier (schema :791, :798).
G-torn-odd and G-torn-even use the same seventeen bytes (design :321-322).

Consequence: a scanner that trusts header identity or link fields of a torn frame before the digest check passes every G case.
M-short reaches that frame shape only through the decoder's bounded entry, not through the recovery scan.
Smallest correction: declare a second prefix length for the G torn fixtures, the complete 384-byte header with no payload, and state the expected refusal.

### P3-3. The fault and outcome sets omit checks the schema names

The M product applies eight faults (design :264).
None mutates the magic, the end marker, the major version, a zero `I` identity or a state byte above three (schema :39, :48, :52, :220).
The schema accepts a frame only after marker and version checks (schema :232).
The C product's five outcomes cover flush and visibility but not the `F` bundle's namespace result (design :188, schema :282).

Consequence: a decoder that accepts a wrong end marker or a state byte of four passes every M case.
A writer that ignores a failed namespace result passes every C case.
Smallest correction: add magic, end-marker, major and state faults to M, or name their exclusion.
Add namespace-failed and namespace-unknown to C, or state why no carrier target has a namespace operation.

### P3-4. The successor's directory-create failure has no case

The contract row gives directory creation to the owner and states that the collection successor uses the same transition (contract :233).
S6-collection-create selects the owner's first collection directory (design :102).
W-successor-binding asserts a collection-backed directory as its dependent effect (design :169).
No case fails the successor's create result.

Consequence: a successor that recreates a directory under a burned ordinal, or continues after a create error, is not discriminated.
Smallest correction: add `S6-successor-create`, the successor's first collection directory, with the owner case's oracle.

### Supported items

These claims hold against the inherited contracts and recomputation. They need no correction.

- All eighteen group counts recompute from the tables, and the sum is 1067. The receipt lists the same 1067 unique IDs and groups.
- The W table covers every terminal kind. Its 47 targets include each of kinds 1 to 13 and 16 to 29 at least once (design :133-179).
- The original eighteen match the plan's named S2 to S6 cases one for one (design :86-103, plan :437-441).
- L-stop-01 to L-stop-12 map to the owner's twelve stop rows in order. CT-term-2 to CT-end-20 match the owner's containment window.
- The 31 D boundaries match the owner's declared deadlines, and D-upper-path matches the 150-second path inside 152.
- HP's two phases are the owner's two held-pointer cases, and the transcript rule forbids release and corrective input (design :422-426, owner spec :530).
- G-entry-order, G-normal-final and G-recovery-final match the schema's successor order and both final paths.
- The directory-create reconciliation follows the schema's step 4 and the owner spec (schema :693, owner spec :165, :999). The contract row split reconciles the contract to reviewed documents and adds no class. It edits a row Antony approved, so the integration should keep that edit visible.
- The sentinel oracle, the collection identities and the zero-scenario-invocation rule match the k128 corrections.
- The process inventory of eight, or nine with a holder, matches the raw-control design. The validator and helpers count while alive.
- The prefix rule never fabricates bytes, and an unexpected short write makes the boundary unavailable.
- The owner-spec, schema and plan edits are links and scope sentences. No new seam, collector site or execution authority appears.
- The source observation holds: `run_locked` opens raw.stdout and raw.stderr with `xb` before `subprocess.run` (scripts/vm-guest-exec.py :328-331).
- The receipt records zero hard prose findings, task exit 201 with only the two k23 targets, stable input hashes, and unchecked mobile and dark appearance.
- No decision earns an ADR. The design selects no irreversible mechanism.

Evidence limits: no project command ran on the artifact. The prose checker ran on this file and on the integration body.
No graph was consulted. Every claim is a direct read of the working copy at 2a94515f.
