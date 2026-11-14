# settings-keepalive-admission-k108

**Reviews:** settings-keepalive-admission-k105

## Goal
Independently challenge the resource-admission design and its evidence boundary
before external-enforcement research and complete numerical-profile design.

## Context
Read the producer's committed diff and the full k102/k98/k96 charters. Read
docs/specs/settings-keepalive-owner.md, KEEPALIVE-RESOURCES.md,
KEEPALIVE-DESIGN.md, the lifecycle and scheduling handoffs, and the current
visual resource discussion. The producer completed only k105 after decomposing
k102. K106 researches external mechanisms, and k107 retains the entire combined
profile.

## Done when
- Re-derive whether the design distinguishes producer allocation/write work from
  late validator rejection. Check pinned TestAnyware and XNU claims against primary
  source, including the stated limits of source-to-host correspondence. Challenge
  unjustified claims in either direction about inherited limits and reserved storage.
- Challenge whether resource admission, launcher setup, ordinary/collection/terminal
  allowances, retained evidence and unavailable outcomes can coexist with the
  reviewed lock, ordinal, commitment, publication and containment contracts.
  Find any hidden second writer, capacity borrowing or guarantee after storage loss.
- Check the approved audited-copy test seam, its correspondence obligation and
  internal barriers/clock boundaries. Treat Antony's 2026-10-31 approval as settled.
  Check whether the stated test design respects it and can discriminate its defects.
- Check that the research/full-profile leaves still own every original
  resource/workload and complete-design obligation. This slice cannot claim
  numerical usefulness, qualified native enforcement, implementation or readiness.
- Review the diagram, captions, summaries and source-evidence scope together.
  Report actionable findings with exact source positions. Make no fixes. If findings
  merit integration, cut it immediately before k106 using the producer's bare stem.
  Do not create a redundant whole-design review or speculative implementation work.

## Notes
Tier 2 evidence: Koine project
Users-antony-Development-AbstractingComputers-Koine.gh-issue-14, recorded index
generation 2026-10-30T12:26:51Z. The producer read modified documentation
directly where coverage freshness changed. It read the resource Mermaid source
through its complete recorded parse gap. Initial inspector discovery and actual
backend source establish the Koine boundary. The producer discarded unrelated
outgoing graph edges.

The TestAnyware historical source pin is
65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03. Current graph offsets do not establish it.
The XNU source pin and every open qualification question are in the resource report.
Neither graph coverage nor this slice is an exhaustive producer allocation audit.
The verification receipt establishes document delivery only. No native run,
resource-exhaustion experiment, storage mutation, VM or acceptance slot is authorised.

## Decisions (running log)

- 2026-10-31: Adopt the mandated review leaf in the clean jj workspace at
  04c84236. The working copy equals that commit for every reviewed path. Read
  the k105 commit and its whole diff. Read the current spec, the resource report,
  the resource view, the manifest, the README and the receipt. Read the design
  record, the lifecycle review and the scheduling evidence. Read the k105, k106
  and k107 bodies, the root brief, the k85 to k102 briefs and the glossary. Read
  the backend, the inspector and the capture results directly.
- 2026-10-31: Run no test, build, lint, format, VM or coordinator command on the
  artifact. Run only the prose checker on this file and the integration body.
  Use no graph tool. Download the four pinned TestAnyware files at 65bc05c9 and
  the three pinned XNU files at f6217f89 into the scratchpad. Read the cited
  ranges. Compare the manual claims with Apple's archived setrlimit page and the
  installed manual. Compare the storage claims with Apple's APFS volume guide.
  Compare the receipt's digests with the delivered files.
- 2026-10-31: This file failed the prose checker as the producer left it. A
  preparatory commit converts it before this edit. No in-session reviewer runs.
  This leaf is the adversarial read.
- 2026-10-31: Every pinned source claim holds. The slice holds on producer
  allocation before write, validator insufficiency, retention, approval scope and
  retained duties. Four material gaps remain inside this slice. They are the
  launcher-side floor of an inherited limit and the storage arrangement behind
  the three allowances. The other two are the resource charge point and the
  enabling points of the resource controls. Five narrower findings follow.
- 2026-10-31: P2-1 to P2-4 need resolution before k106 frames its research and
  before k107 consumes the boundary. Insert the integration before k106, the
  first later sibling with live work. The cut is settings-keepalive-admission-k109
  at position 03. K106 moves to 04 and k107 to 05 with no content change. The
  body carries this review's handle, not the findings. No Creator line applies,
  because this leaf finishes no producer. Retire this leaf only. K102, k98 and
  k96 keep live work.

## Findings

Severity: P1 means the design would lead k106 or k107 to violate an inherited
contract. P2 means a material omission or inconsistency inside this slice that
k106 or k107 must not consume as settled. P3 means a narrower precision, seam or
legibility defect. No finding below is a k106 research answer or a k107
numerical obligation. Each one concerns the admission slice itself.

Line numbers refer to commit 04c84236, which the working copy equals. "The
spec" is docs/specs/settings-keepalive-owner.md. "The report" is
docs/verification/settings-activation/KEEPALIVE-RESOURCES.md. "The view" is
docs/design/architecture/settings-activation/keepalive-resources.mmd. "The
manifest" is docs/design/architecture/settings-activation/diagrams.json.

"The README" is docs/design/architecture/settings-activation/README.md. "The
backend" is scripts/vm-guest-exec.py. "The inspector" is
scripts/vm_capture_artifact.py. "The capture results" is
docs/verification/settings-activation/ORDERING-CAPTURE-RESULTS.md. TestAnyware
files are at tag v2.7.0, commit 65bc05c9. XNU files are at commit f6217f89,
which is xnu-12377.1.9 of 2025-10-16.

### P2-1. The launcher cannot lower the address-space limit below its own map size

The report cites the XNU setter and records that it rejects a limit below
existing map use (report :57-58). The source shows the same. The setter hands the
new limit to the calling process's own map (kern_resource.c :1647-1654). The map
refuses any limit below its current size (vm_map.c :22094-22099). A fork copies
the limit to the child map (vm_map.c :13737-13743). An exec copies the process
limit to the new map (kern_exec.c :1531).

The spec requires the producer launcher to install its limits before executing
the external image (spec :839-843). It treats a failed limit call as a refusal.
Under the unchanged transport, the only process that can make that call before
the producer's exec is the backend's forked child. At that moment its map is the
backend's own map.

The backend is a Python interpreter with the shared cache and
allocator reservations mapped. If the chosen producer limit is below that
footprint, the call fails every time. A readback then reports the floor, not the
intent.

Consequence: the installable limit has a source-established floor that the
launcher, not the producer, sets. The report's useful-fit caveat (report :70-71)
and k106's loader-allowance question do not name it. A researcher can answer the
exec-survival question positively from the same source and still miss the floor.
The arrangement options are a minimal exec'd intermediary, a limit call inside the
producer, which is the explicit-producer candidate, or another mechanism.

Two related source facts are absent from the report. The pinned source enforces
RLIMIT_DATA on the same whole-map path as RLIMIT_AS (vm_map.c :3703-3710,
kern_resource.c :1503-1514). The manual describes a data segment instead
(report :50-51). The installed SDK header aliases RLIMIT_RSS to RLIMIT_AS (resource.h
:451-453), so the manual's RSS text describes the same resource number.

State the floor in the report's OS-evidence section and in spec :839-843. Add two
items to k106's first question. They are the install point of the limit and the
backend's own map size on the host. Record the RLIMIT_DATA twin and the RSS alias.

### P2-2. The three allowances, the one ordinal directory and the unchanged producer have no named arrangement

The spec requires three disjoint allowances under one writer authority (spec
:852-858). An established mechanism, not a ledger, must back each reservation
(spec :860-861). Separate storage objects are permitted as part of the root
identity, with no alternate writer, lock or ordinal allocator (spec :862-865).
The owner reserves the next attempt directory under the root (spec :128-129).
The retained backend allocates the ordinal by scanning the root's six-digit
children and creates the attempt directory there (backend :233-235, :260-264).
The producer writes its own output file at the path it is given (screen.rs
:115-116).

Collection screenshots are captures through the same backend, root and ordinal
sequence (spec :57-58, :430-431, :788-791). If the collection allowance is a
separate storage object, that capture's attempt directory has no stated home.
In the ordinary object, an exhausted ordinary allowance blocks the directory
creation, which spec :867-868 charges to ordinary work. In the collection
object, the ordinal sequence spans two objects and the root scan does not see it.
If the allowances share one object, the "cannot consume" property is a ledger,
which spec :860-861 forbids. The producer's file write is then bounded only per
file, which spec :867-868 concedes does not bound the sum.

The same gap covers the owner's own records. Every operation, clean or not,
writes commitment, launch, terminal and completion events (spec :327-332,
:337-351, :873-876). The allowance table names only failure records as terminal
evidence (spec :858). The class that pays for a clean operation's events is
unstated. After owner loss, the collection-only generation holds no ledger (spec
:420-428). Only a mechanism-backed class survives that loss.

Consequence: the spec states a conjunction that its first candidate cannot
satisfy as written. K106's third question asks for an arrangement that keeps
one logical root, writer and ordinal domain (report :114-116). It does not name
the two concrete constraints, so a survey can answer "three volumes" without
meeting the ordinal domain.

State in the spec where a collection capture's attempt directory lives. Name the
allowance that pays for each record kind in the lifecycle table. Add both
constraints to the report's third question and to k106's storage bullet. State
that the disjointness property is a requirement until k106 answers, not a design.

### P2-3. The resource charge point is ambiguous between admission and commitment

The spec admits an operation only when the profile covers its work (spec :828).
It refuses an unknown cost at commitment (spec :837). The ordinary-work row
reserves the full contribution at admission, before launch (spec :856). Charges
are not refunded after cancellation (spec :869-870). Each commitment references
the resource admission event (spec :873). The view collapses both into one node
(view :5).

The scheduling profile separates them. Admission publishes within two seconds.
Commitment can follow up to 152 seconds later (spec :571-576). Read as a charge
at admission, every pending tick that normal stop cancels unstarted consumes one
capture's charge (spec :296-297). The whole-run count names every mandatory
capture and the collection path, not cancelled admissions (spec :870-871).

Read as a charge at commitment, admission carries no resource meaning. A pending
operation refused at commitment for resources then has no event kind. The
submission kinds are received, admitted and cancelled-unstarted, and cancellation
names a stop ID (spec :341).

Consequence: the report's mutant that charges after launch (report :146-147)
cannot be built, because the charge point is unstated. K107's schemas and
count inherit the ambiguity.

Name the charge point. The smaller change is a charge at commitment, the
serialised ordering point, with a resource check at admission that can refuse
but does not charge. Add the event kind for a resource refusal before
commitment. State whether cancelled-unstarted work charges.

### P2-4. The resource controls need enabling points the approval does not name

The report requires four resource controls (report :142-148). They cover
launcher refusal before invocation, ordinary exhaustion with protected capacity
remaining, failure of the protected writes themselves, and unavailable holders. The spec requires those
controls to exercise the real owner and resource-admission code. It rejects
synthetic allocation or write substitutes as proof of native enforcement (spec
:904-909). The approval covers phase barriers and a clock reader in audited
copies of the owner, backend and caller (report :129-134, spec :481-491).

A barrier or a clock cannot make a protected write fail or exhaust an allowance.
Those rows need either a real capped storage object in the test or a declared
write-failure or limit-call-failure substitution in a copied module. The first
waits on k106's mechanism. The second is a substitution class the approval does
not list. The existing deterministic allocation-failure control shows that the
copied-validator technique can host such a substitution (capture results :271).
Nothing in k105 says the resource controls will use it, or that it is inside the
approval.

Consequence: the resource rows are the same defect class as k103's P3-2, the
clock enabling point, which k104 graded real. The brief asks whether the stated
test design can discriminate its defects. For these rows it cannot yet.

Name the enabling point for each resource control. The options are a real
capped object, a declared substitution and the copy that holds it, or an
external CLI control.
Say whether each is inside the 2026-10-31 approval. Hand any new substitution
class to k107 as an explicit choice, not an approved change.

### P3-1. The capture pipeline holds two full frames, and the report counts one

The capture returns an owned framebuffer (capture.rs :59-60). At scale 1 the
accessor borrows the wire framebuffer, and the owned conversion clones it. At
scale 2 the accessor returns an owned quarter-size downsample (connection.rs
:247-253). The connection and its wire framebuffer stay alive until the command
returns, after the encode and the file write (screen.rs :77-125). The encode then
adds the cropped vector and the output vector (capture.rs :137, :143). Before
that, each wire rectangle adds its own payload or compressed and decoded buffers
(connection.rs :437, :456, :460).

The report's pipeline row names one owned framebuffer and one concurrent frame
(report :32). It does not say the owned frame is a copy whose size depends on the
logical or physical choice. The adjacent row says the surfaces must be
distinguished (report :33) but does not connect that to the copy. K106's trace
bullet names handshake, resize, compressed fields, decoder output and encoding,
not the copy.

Consequence: a unit list built from the report undercounts the peak by one full
frame at scale 1. List the owned copy as a unit in the report's row and in k106's
trace bullet. State that the peak holds two frame buffers, and that the second
one's size follows the scale.

### P3-2. Commitment-time and launch-time facts share one reference

The spec says each commitment references the resource admission event, including
limits installed by the launcher and observations (spec :873-876). The owner
publishes commitment before creating the backend child (spec :128-129). The
backend is the launcher, and its CLI inherits the backend group (spec :94-95,
:839). Installed limits and their readback therefore exist only after the launch
observation (spec :343). The same passage calls it an event at :873 and fields
that extend the existing join at :876. The lifecycle table has no row for either
(spec :337-351).

Consequence: a schema built from :873-876 either records a fact before it exists
or leaves the readback without a home. Split the reference. Commitment carries
declared limits, reserved identities and remaining capacity. The launch
observation carries installed limits and readback. Settlement sits in the
terminal disposition. Name the rows, or state that they are fields of existing rows.

### P3-3. Two captions place enforcement before commitment, and the view omits launcher refusal

The README and the manifest describe the view as adding enforcement and
protected-capacity admission before commitment (README :77, manifest :43). The
view's enforcement edge leaves the commitment node (view :16). The spec installs
limits after commitment and before exec (spec :128-129, :839). The spec also
requires controls to distinguish failed launcher admission from failed external
execution (spec :904). The view's only failure edge from the producer is limit,
death or partial output (view :19). The caption names omitted lifecycle joins,
not this omission (manifest :53).

Consequence: a reader of the index alone places enforcement on the wrong side of
commitment, and the view cannot show the control the spec demands. Reword the two
captions. Add a launcher-refusal edge, or name the omission in the caption.

### P3-4. The alternatives table misplaces process and writer ownership

The first candidate row says the launcher owns limit setup while the caller
retains process and writer ownership (report :86). The reviewed lifecycle gives
the writer to the owner and gives the caller only the owner child (spec :37-49,
:84-85). The backend launches the CLI (spec :94-95).

Consequence: a k106 reader can place the launcher in the caller and design the
mechanism at the wrong process. Reword the cell. The backend installs limits
under the owner's commitment, and the owner retains writer and process ownership.

### P3-5. New terms have no glossary entries, and one provenance line disagrees

The spec coins the resource profile, the three allowances, protected capacity,
the resource admission event, settlement and the producer launcher (spec
:827-876). The glossary holds the k100 and k104 terms and none of these
(CONTEXT.md :56-95). K103's P3-5 raised the same pattern, and k104 graded it
real. The report records Koine coverage generation 2026-10-30T12:10:34Z (report
:184). This leaf's notes, written by k105, record 2026-10-30T12:26:51Z. One of
the two is not the generation the report rests on.

Consequence: terms drift, and the evidence provenance has two stamps. Add the
terms to the glossary. Reconcile the stamp.

### Supported items

These claims hold against the source, the agreed scope and the k100 and k104
contracts. They need no correction.

- All four TestAnyware pins hold at tag v2.7.0, whose annotated tag resolves to
  65bc05c9. Capture acquires the full frame, crops after decode and writes last
  (screen.rs :89-125). Dimensions and overflow are checked before allocation
  (framebuffer.rs :24-32). Raw payloads allocate before the bounds check, ZRLE
  allocates from a 32-bit length, and desktop resize allocates another frame
  (connection.rs :434-479).
- All three XNU pins hold at xnu-12377.1.9. The host reports 27.0.1, 26A434 and
  Darwin 27.0.0. No correspondence is claimed, and none is established here.
- The archived setrlimit page lists no RLIMIT_AS. Its FSIZE, SIGXFSZ, DATA and
  RSS text is as the report describes (report :49-53). The installed manual
  repeats it. The APFS guide separates reserve from quota (report :75-77).
- The receipt's digests match all nine delivered subject files. The working copy
  equals the producer commit.
- The backend writes raw streams to unique files and inspects after CLI exit
  (backend :327-345). The inspector reads the whole file, accumulates IDAT and
  decompresses to the header size (inspector :37, :75, :88-92). Neither bounds
  the producer.
- Retention at a limit matches the k93 scope (KEEPALIVE-DESIGN :170-175, spec
  :880-886). Storage loss and unknown holders stay unavailable, not guaranteed.
- No text introduces a second writer, lock or ordinal allocator. The hazard in
  P2-2 is an unnamed arrangement, not a stated alternate path.
- The approval is recorded consistently in the spec, the report, the lifecycle
  review and the scheduling evidence. Each treats it as a test-seam approval only.
- The original-duty table matches the design record (report :158-167,
  KEEPALIVE-DESIGN :408-422). K106 and k107 retain every k102, k98 and k96
  criterion. The slice claims no numerical usefulness, qualified enforcement,
  implementation or readiness.
- One survey for k106 is a stated choice, consistent with the methodology's
  default of one corpus.
- Fork and exec both carry the size limit in the pinned source, so the report's
  survival question has a positive source answer. Host correspondence remains open.
- No decision earns an ADR yet. The choices remain reversible before
  implementation.
