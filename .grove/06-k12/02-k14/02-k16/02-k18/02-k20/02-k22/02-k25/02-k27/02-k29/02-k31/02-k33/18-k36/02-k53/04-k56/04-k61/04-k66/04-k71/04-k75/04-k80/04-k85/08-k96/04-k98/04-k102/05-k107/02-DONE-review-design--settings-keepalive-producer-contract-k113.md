# settings-keepalive-producer-contract-k113

**Reviews:** settings-keepalive-producer-contract-k110


## Goal
Challenge the bounded-producer contract and the approved resource-result test
controls independently, before the native/storage qualification proposal consumes them.

## Context
Review the producer's committed diff and docs/specs/settings-capture-resource-contract.md.
Include its owner-spec, resource-assessment, glossary and visual-discussion changes.
Read the full k107/k102/k98/k96 requirements and the k106 enforcement survey.

The human approved bounded-producer design and the named audited capacity/limit-call/
write-result substitutions. The approval covers no external implementation, issue
filing or experiment. The initial leaf k107 decomposed because the complete profile
exceeds one session. This is a review of child k110, not the required final
whole-design review.

## Done when
- Give an inspection-only findings report with exact artifact locations,
  violated contract, consequence and supporting source evidence. Try to disprove
  the interface, ownership and refusal/retention guarantees. Do not accept the
  producer's narrative, and do not count declared requirements as proven mechanisms.
- Examine request parsing/bootstrap, handshake and non-image paths, raw/ZRLE/
  Tight/JPEG, resize and simultaneous frames, crop/PNG overlap, native OCR and
  output/raw/partial retention. Distinguish contract completeness from dependency
  implementation and native evidence that this slice explicitly does not supply.
- Challenge admission versus commitment versus actual launch observations,
  first failure, deadline/held-frame semantics, one attempt and no extra input.
  Check that the documents imply no unsupported native bound or useful numerical profile.
- Examine each copied capacity/limit-call/write-result enabling point and its
  exact copy audit. Examine real prefix bytes, real transition/error handling,
  unavailable final tails and discriminating mutants. Check that the documents
  neither broaden the human's approval to an allocator/production injection seam
  nor leave it falsely pending.
- Check diagrams and summaries against the prose. Check that k107's original
  criteria, downstream duties and holds remain chartered. K111/k112 are design
  work. Cut no external implementation or speculative Koine implementation leaf.
- Cut an integration only if findings warrant it, ahead of the first later live
  sibling. Its body points to this review rather than transcribing findings as
  its obligations. All earned integration precedes k111 consumption.

## Notes
Source pin and current graph are distinct. Use the survey's exact dependency pin
for historical claims. Record coverage limitations and source fallbacks.

Use no in-session subreviewer, fixes, native qualification, VM or ancestor closure.
The producer has no current provider receipt, and the producer invented no Creator
line. Review policy owns any provider-declaration remedy. The only known doc-check
failures are the two existing k23 missing targets, not a green check.

## Decisions (running log)

- 2026-10-31: Adopt the mandated review leaf in the clean jj workspace at
  46b20291. The working copy equals that commit for every reviewed path. Read the
  k110 commit and its whole diff. Read the contract, the owner spec, the resource
  report and the survey. Read the glossary, the three views, the manifest and the
  README. Read the k110, k111 and k112 bodies, the k107 brief and the whole brief
  chain to the root.
- 2026-10-31: Run no test, build, lint, format, VM or coordinator command on the
  artifact. Run only the prose checker on this file and the integration body.
  Read the pinned TestAnyware sources at 65bc05c9 with git show in the adjacent
  repository. Read the current backend and inspector directly. The graph coverage
  check at generation 2026-10-31T03:53:35Z reports no recorded issue for both
  scripts. It reports changed or untracked metadata for every changed document
  and partial parses for two views. Read all of them directly. No graph
  completeness claim follows.
- 2026-10-31: This file failed the prose checker as the producer left it, with
  eight hard findings. A preparatory commit converts it before this edit. No
  in-session reviewer runs. This leaf is the adversarial read.
- 2026-10-31: Every pinned source claim holds. The contract holds on ownership,
  admission versus commitment versus launch, first failure, held-frame semantics,
  one attempt and the approval scope. Two material gaps remain inside this slice.
  The immutable request does not bind the producer's environment-selected
  encoding set or OCR engine. The raw stream bound has two owners and none on
  the abnormal path. Nine narrower findings follow.
- 2026-10-31: P2-1 and P2-2 need resolution before k111 consumes the contract.
  Insert the integration before k111, the first later sibling with live work.
  The cut is settings-keepalive-producer-contract-k114 at position 03.
  K111 moves to 04 and k112 to 05 with no content change. The body carries this
  review's handle, not the findings. No Creator line applies, because this leaf
  finishes no producer. Retire this leaf only. K107, k102, k98 and k96 keep live
  work.

## Findings

Severity: P1 means the design would lead k111 or k112 to violate an inherited
contract. P2 means a material omission or inconsistency inside this slice that
k111 or k112 must not consume as settled. P3 means a narrower precision, seam or
legibility defect. No finding below supplies a native bound, a number or a
dependency implementation. Each one concerns the contract slice itself.

Line numbers refer to commit 46b20291, which the working copy equalled at
adoption. "The contract" is docs/specs/settings-capture-resource-contract.md.
"The spec" is docs/specs/settings-keepalive-owner.md. "The report" is
docs/verification/settings-activation/KEEPALIVE-RESOURCES.md. "The survey" is
docs/research/settings-keepalive-enforcement-a.md.

"The README" is docs/design/architecture/settings-activation/README.md. "The
backend" is scripts/vm-guest-exec.py. TestAnyware files are at commit 65bc05c9,
the v2.7.0 basis, read with git show. Rust line numbers are those files' own lines.

### P2-1. The immutable request does not bind the producer's environment-selected behaviour

The contract requires one immutable request, checked before connection (contract
:26-27). It says Koine must not depend on a collection of independent environment
defaults (contract :29-30). The Identity and Operation rows list the request
fields (contract :36-37). Neither names the negotiated encoding set or the OCR
engine. The OCR row says "Retain the selected OCR engine" without saying who
selects it or where the selection lives (contract :80). The spec requires
the profile to name the complete child/service set (spec :884-885).

In the pinned producer both selections come from the process environment at run
time. `TESTANYWARE_RFB_ENCODING` forces one primary encoding and changes the
SetEncodings list (connection.rs :194-196, :569, :605-640).
`TESTANYWARE_OCR_FALLBACK=1` replaces in-process Vision with a Python daemon
child, and `TESTANYWARE_OCR_PYTHON` selects its interpreter (engine.rs :112-135,
:141-145, :211-215). The CLI also resolves its target through
`TESTANYWARE_APP_SOCKET` and related variables (commands/mod.rs :166). The
backend passes `--vm` explicitly, but the child inherits the backend's
environment (backend :327-333).

Consequence: the encoding set decides which decoder rows apply (contract :72-77)
and therefore the decode peak. The OCR engine decides whether a second process
exists outside the owned-memory bounds. A request that passes every check at
contract :45-50 can still describe a different process and service set from the
one that runs. K111's launcher and native-containment proposal would then
qualify a membership the request does not fix.

Smallest correction: add the negotiated encoding set and the OCR engine identity
to the Identity or Operation row. Require the producer to refuse when a
behaviour-selecting environment variable is present and differs from the
request. Require the launcher to pass a declared environment and record it in
the launch observation. Name the daemon-versus-in-process distinction at spec
:884-885.

### P2-2. Raw stream bounds have two owners and none on the abnormal path

The Output row puts bounded stdout/stderr in the producer's request (contract
:42). The output-writer row makes the producer check "raw/error/result output"
against budgets (contract :81). A raw stream that reaches its bound fails the
operation at the write boundary, and the writer must not silently discard bytes
(contract :124-126). The test table then lists backend raw writes as a
controlled backend boundary (contract :153). In the existing backend, the
backend creates the raw stream files and passes them to the child as
descriptors (backend :327-333). The producer writes to inherited descriptors
with no budget check of its own.

Bytes the producer's structured writer never sees also reach stderr. Examples
are a Rust panic message or backtrace, an Objective-C exception log from Vision
and a dynamic loader error. The contract accepts that a crash may leave no
complete observation (contract :56-58). It names no bound for those bytes.

Consequence: the raw stream budget has no enforcement point on the path where
the producer is not in control. Unbounded diagnostic text can consume ordinary
storage and metadata after the producer's own checks stop running. The
partial-write control at contract :153 and the mutant list at contract :178-182
cannot test a bound nobody owns.

Smallest correction: assign the raw stream bound to the backend. Capture through
a pipe with a cap or through a pre-sized object. Treat a cap hit as a
write-boundary failure with the retained prefix. State what the producer bounds,
its own structured emission, and what the backend bounds, everything on the
descriptor. Record which bound fired in the observation or the backend result.

### P3-1. "Do not resize down" and the resize path need exact wording

The framebuffer row says "do not resize down or reinterpret a rejected update as
a usable capture" (contract :73). Read one way, it forbids shrinking a bound or a
buffer to fit a budget. Read another way, it forbids honouring a smaller server
DesktopSize. The pinned producer replaces the framebuffer on every DesktopSize,
larger or smaller (connection.rs :477-479). It re-derives the scale from the new
size (connection.rs :222-228). The root brief records the guest resolution changing
from 1920×1080 to 1024×768 after restart.

The OCR poll reuses one connection across captures (screen.rs :173-243). A
resize can therefore fall between two captures of one operation. It changes the
selected-frame size at contract :78 and the scale behaviour at contract :37.

Consequence: a dependency implementer can read contract :73 as a behaviour
change that contract :83-84 forbids. The per-capture re-check of selected-frame
capacity after a resize is implicit only.

Smallest correction: reword contract :73 to name the forbidden action and the
permitted one. State that selection checks run per capture against the geometry
current at that capture.

### P3-2. A worked example cites the wrong document

The contract says the 24,883,200-byte two-frame-plus-crop example is "in the
survey" (contract :104-105). The survey has no such figure. It appears in the
report, written by this same producer (report :85). Cite the report, or move the
figure.

### P3-3. The survey still calls the substitutions unapproved and has no forward bridge

The survey says the existing approval does not approve new limit-call,
allocator, capacity or write substitutions (survey :396-399). Its control table
marks capacity and write substitutions as needing approval (survey :405-411).
Its closing section says other substitutions stay unapproved (survey :463). The
report and the contract record the later approval (report :98-111, contract
:138-144). The survey names neither the contract nor the completion decision.
The ADR placement note asks an adopted research finding for a bridge pointing
both ways.

A reader of the survey alone now holds the wrong approval state. The same
staleness appears in two current-state documents. The report still says "K106
must" after k106 retired (report :151-152, :182-183). The spec says "K102 must"
for work that k112 now owns (spec :687).

Smallest correction: add a short adoption section to the survey that names the
contract and the completion decision. Mark the approval sentences as the state
at the survey's date. Replace "K106 must" and "K102 must" with the current owner
or with a plain statement of what remains.

### P3-4. The design README sends readers to three ports

The README tells the reader to serve on 8804 and open 8804 (README :57-58). It
links the three new views on 8810 (README :78-80). It still links two older
views on 8804 (README :91-93). The Taskfile default is 8765 (Taskfile.yml
:1177-1180). A reader who follows the instruction cannot open the new links.
Use one port in the instruction and every link, or make the links relative.

### P3-5. Koine's internal test controls live in the external dependency contract

The contract specifies the audited copies of Koine's owner, backend and caller,
the copy audit and the mutants (contract :136-183). The contract's stated reader
is the selected dependency (contract :27-28, :219-221). The spec already has a
test seams section (spec :483-555) and now points into the contract for these
rows (spec :521-525, :1006-1010). Two consequences follow. The document handed
to TestAnyware's owner carries Koine test policy that owner cannot act on. A
change to Koine's copy-audit rule edits the dependency contract.

The one paragraph that concerns the producer is contract :185-189. This may be a
deliberate choice to keep both approvals in one place. If so, say so in the
contract. Otherwise move contract :136-183 to the spec's test seams section or to
the report, and leave contract :185-189 with a pointer.

### P3-6. Three names for one role

The glossary defines "Producer launcher" (CONTEXT.md :126-129). The contract
says "owner-side launch adapter" (contract :27-28) and "verified launch adapter"
(contract :201). The contract's table and the report say "backend launcher"
(contract :150, report :306). Use the glossary term, or define the adapter as a
distinct role in the glossary.

### P3-7. The request binding should be opaque

The Identity row binds the request to "root/generation/operation" (contract
:36). The evidence root is private and secret-bearing, as the k78 handoff in the
brief chain records. The producer may echo request fields into diagnostics, and
the observation carries request identity (contract :52-56). State that the
binding is an opaque token issued by the owner, never the root path.

### P3-8. The per-unit schema's owner and version rule are implicit

The Decode and Capture/encode rows ask the request to carry per-encoding decode
intermediates and encoder-internal capacities (contract :40-41). Those are facts
about the dependency's internals. The Identity row includes a "supported
resource contract" version that can carry them (contract :36). The text never
says that the dependency declares the unit schema and that Koine pins values
against that version. The alternatives section weighs three alternatives and
not the split between owner-declared outer bounds and producer-declared
internal units (contract :192-197). The charter requires Koine to know every
unit, so the split is a clarification, not a reversal.

Smallest correction: state that the unit schema belongs to the dependency's
resource-contract version. State that a schema change bumps the version and that
a version mismatch refuses. Record the rejected outer-bounds-only alternative
and the charter reason.

### P3-9. Two mutant lists differ

The contract lists nine mutants (contract :178-182). The report lists five
(report :291-295). "Charging after launch" and "truncating earlier files" appear
only in the report. "Omitting the commitment recheck", "dispatching after a
failed fence" and "accepting a test copy with an unrelated edit" appear only in
the contract. Neither list says it is the superset. Make one list authoritative
and point the other at it.

### Supported items

These claims hold against the pinned source, the agreed scope and the reviewed
lifecycle, scheduling and admission contracts. They need no correction.

- Every pinned source claim the contract rests on holds at 65bc05c9. The
  security reason and the ServerInit name allocate from a u32 length before any
  check (connection.rs :106-111, :154-161). Colour-map entries and cut text
  allocate from wire counts even when discarded (connection.rs :396-409). Raw
  payloads allocate before the bounds check (connection.rs :436-440). ZRLE
  allocates from a u32 length and inflates into an uncapped vector
  (connection.rs :453-457, zrle.rs :66-80). Tight inflates until the expected
  length and can overshoot by one chunk before rejection (tight.rs :217-245).
  JPEG decodes before the dimension check (tight.rs :252-270). DesktopSize
  allocates the new frame before dropping the old one (connection.rs :477-479).
- Scale 1 clones the wire frame, scale 2 downsamples, and physical capture
  clones (capture.rs :59-74, connection.rs :247-254). The crop and output
  vectors follow (capture.rs :137-145). The region check adds unchecked u32
  values (capture.rs :129), which the Geometry row addresses (contract :38). The
  file write uses a default pathname (screen.rs :115-116), which contract
  :117-119 addresses. The held-frame fallback returns the frame already held
  after five seconds (capture.rs :90-98). Vision copies the PNG twice before
  decoding (engine.rs :170-171, vision.rs :54).
- The negotiated encoding set is ZRLE, Tight, CopyRect, Raw, DesktopSize and
  LastRect (connection.rs :623-640). The enforcement table covers every member
  that carries a payload. The producer negotiates no cursor pseudo-encoding.
- Admission, commitment and launch observation stay distinct in the contract
  (contract :19-24, :148-150), the spec (spec :869-881, :965-975) and the
  resource view. The charge is irrevocable at commitment, and admission charges
  nothing. Pending cancellation costs terminal records only.
- The first-failure rule is sticky and triggers no capture, input, reconnect,
  poll or revised cap (contract :131-135). This matches one attempt and both
  held-pointer cases.
- The deadline rule separates resource expiry from the clean held-frame timeout
  and forbids resuming a half-consumed parser (contract :112-115). That matches
  the non-cancel-safe reader (connection.rs :382-386).
- The documents imply no numerical profile. The contract disclaims the example and every
  number (contract :104-106, :212-218). The scheduling numbers stay marked
  proposed.
- Four documents record the approval as design authority plus the named
  substitution class. They are the contract (:10-15, :138-144), the report
  (:42-48, :100-111), the spec (:13-17, :521-525) and the README (:3-10). No
  allocator or production injection seam appears. Only the survey still shows
  the earlier state (P3-3).
- The approved controls keep real transitions, require real prefixes, forbid
  fabricated bytes and fail on missing, duplicate or extra sites (contract
  :156-169). The contract declares them failure-handling evidence only (contract :185-189).
- K107's charter survives in the k107 brief and in the k111 and k112 bodies.
  Both children are design leaves. No implementation leaf exists, and no
  ancestor closed.
- The two new glossary terms are present and used consistently (CONTEXT.md
  :130-137).
- The views match the prose on ownership, request flow, retained partials and
  the review-before-qualification order. The producer view omits the launcher
  step, and its caption says so.
- No decision earns an ADR yet, consistent with k108's reading. The bounded-producer
  decision will meet all three tests at adoption. The whole-design review should
  decide then whether the contract's alternatives section becomes a record.

Evidence limits: every TestAnyware read is at the pinned commit through git show
in the adjacent repository, not the installed binary. The graph coverage check
reports no recorded issue for the two scripts and changed or untracked metadata
for every changed document. I read all of them directly. No project command ran.
The producer's documentation-check receipt was not re-run.
