# Byte-complete application reference evidence

[Evidence → Qualify the instrument before the one target pass](../design/architecture/index.html#diagram-native-reference-evidence)
shows the dependency boundary. Graphs enter at the dark Start here node;
numbered edges describe order. This is the **evidence contract and concrete
instrument design**. The target-reading instrument and its independent controls
are not built or qualified, and the one authorized packaging pass has not run.
The [construction boundary](#construction-and-qualification-boundary) keeps the
complete implementation/qualification obligations live under k244. This document
supplies no current payload, role assignment, finite population or native verdict.

The [canonical joint evidence boundary](application-population-metadata-shape.md)
owns the selected reference, cohort requirements, permission and packet-integrity
limits. Its [selected requirements](application-population-metadata-shape.md#selected-reference-and-evidence-requirements)
bind this contract. The [private eligibility conjunction](../specs/application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence)
remains false. The application job protocol, selected reader, nine tapes, amounts,
deadlines, image/source guards and release conditions remain owned by that spec
and its cited family. An evidence instrument is not a Koine reader or a new public
test seam. Both advertisement and ordinary-consumption holds remain.

## Ownership and alternatives

One instrument owns bounded source acquisition, root/scope checks, file and
inventory observations, immutable byte packaging and the final evidence envelope.
It accepts the fixed permission contract and a new output destination; it does
not accept arbitrary query predicates, recursive roots, file lists or languages.
Its internal source/filesystem/decoder enabling points accept controlled pure
inputs during qualification. A separate verifier receives a frozen independent
expectation and packaged bytes; it never uses producer totals as its oracle.
The caller does not assemble layout traversal, parsers or race checks.

Original bytes and observations, decoder-derived facts, independent copy roles
and generated-copy rewrites have separate owners and records. Changing a decoder
cannot silently change original evidence. A reader flag cannot change a role.
Rewriting an identifier cannot inherit a source identity or digest. This keeps
capture mechanism, application purpose and construction policy independent.

| Representation | Caller knowledge and evidence cost | Decision |
| --- | --- | --- |
| Existing sizes/hashes and selected-name projection | Small packet, but callers must invent missing formats, candidates, branches and associations | Comparison only; it cannot recover bytes |
| Normalized parsed dictionaries alone | Easy reuse, but replaces original serialization and hides parser losses | Insufficient as the original evidence |
| Original byte objects, complete observations and separately qualified typed witnesses | Larger package and decoder verification; callers can replay each exact file and trace every derived fact | Selected contract |

The selected form would be reconsidered only if its exact permitted evidence is
unavailable or cannot be represented faithfully. That yields an explicit incomplete
boundary and remaining work, not a normalized substitute, smaller reference,
second target pass or automatic amount/posture change.

## Selected instrument architecture

[Components → Preserve original evidence and independent witnesses](../design/architecture/index.html#diagram-native-reference-instrument)
shows the proposed evidence-tool components and their inputs. It describes source
ownership and observation flow, not deployment containers or a qualified executable.

The selected implementation is one macOS command-line acquisition executable with
an in-process Core Foundation decoder, plus a separately implemented offline
verifier. Qualification supplies fake source and descriptor-operation adapters at
the instrument's composition point. Packaging uses the fixed real adapters; a
test adapter, arbitrary predicate, roots, basenames or language list cannot be
selected through its packaging interface. Native decoder qualification reads
only independently authored pure bytes. This is an evidence tool, with no Koine
provider dependency, installed-app execution, registration or VM seam.

| Owner | Input and result | Hidden decisions / failure obligation |
| --- | --- | --- |
| Attempt coordinator | Fixed permission, qualified tool set, fresh destination → evidence envelope | Phase order, one writer, durable start, freeze and final decision; never retries |
| Source adapter | Fixed argument vector → raw stdout/stderr objects, slot occurrences and terminal event | Byte framing, concurrent pipe draining, actual child termination; no contents contact from an incomplete response |
| Held acquisition adapter | One admitted source occurrence → root/layout/inventory/file observations and bytes | Component lookup, containment, no-follow descendants, absence/refusal distinction and item closure |
| Native decoder | One immutable byte object → complete tagged native tree or explicit typed failure | Native type dispatch, format/error evidence and lossless export; no target pathname or conversion fallback |
| Independent verifier | Frozen specimen expectation and envelope → per-coordinate verdicts | Recomputes bytes, required occurrences, trees, branches, tails and associations; rejects producer-only totals |
| Admission verifier | Required inventory, complete proofs and actual retained artifacts → invocation-bound admission or refusal | Independent completeness, permission equality and image continuity; a producer success bit grants nothing |
| External contact observer | Calibrated kernel events for the pure process tree → contact evidence or unavailable coverage | Wrapper bypass, process/descriptor association and event loss; a missing event cannot establish no contact |

Compared with embedding parsing, traversal and mutation expectations in the legacy
Python capture, this arrangement gives the acquisition tool one deep external
interface and gives the verifier an independent oracle. A normalized plutil export
would simplify interchange but would add conversion/duplicate/type obligations
while still losing original serialization. Direct native decoding is selected;
its unqualified or unrepresentable branches remain explicit failures, not Python
type labels. The choice is reversible and earns no new ADR. These internal seams
implement the previously agreed pure controls, not a fourth product interface.

### Fixed source and terminal protocol

Invoke `/usr/bin/mdfind` directly with exactly `-0` and the predicate
`kMDItemContentTypeTree == 'com.apple.application-bundle'`, with no shell, `-live`,
scope/name override or interpretation option. The installed mdfind manual defines
`-0` as a NUL terminator after each returned path. Save the complete stdout and
stderr streams independently, their read errors, child launch/termination facts
and the exact argument/environment input. Drain both pipes while the child runs;
stdout EOF alone is not terminal success. A launched query requires both stream
closures and the reaped normal zero exit before contents acquisition may begin.
Nonzero exit, signal, pipe failure, missing reap or truncated framing cannot be
rescued by useful-looking output. Stderr is retained even on zero exit; its meaning
is not silently erased or turned into an index-health certificate.

For nonempty stdout, each NUL closes exactly one ordinal slot. The trailing
terminator creates no extra slot; consecutive terminators preserve actual empty
slots. Retain an unterminated suffix as an error fragment. Empty stdout at normal
terminal success yields zero observed slots, never all-disk completeness. Preserve
newlines, non-UTF-8 bytes, repeats and outside/malformed names without decoding,
trimming, sorting or deduplicating. NUL cannot be represented inside a result
pathname by this interface; bytes the tool never emits are not recovered by this
framing design. That source fidelity limit stays separate from losslessness of
the emitted byte stream.

The attempt declares one initial and one closure invocation of this same fixed
query. The closure invocation is an integrity observation, never a retry of a
failed initial response or a second source from which missing initial rows are
filled. An aborted attempt records unperformed closure work as unavailable. New
or missing slots, multiplicity, spellings and root associations are compared
item by item. Pure reordering retains both sequences and their permutation; it
does not fabricate raw-byte equality or alter later workload ordering.

### Held roots and the closed acquisition plan

Validate the literal absolute spelling's components against /System, /Applications
or /Library; `Applications-extra`, embedded NUL, relative paths and uncheckable
components do not authorize acquisition. Root resolution follows the existing
descriptor-relative kernel-semantics decision through search-only held directories,
with observed link expansions and directory identities. Check the resolved
component-bounded scope and checked .app directory before any listing/content
handle is opened. File aliases/non-directories remain raw source observations;
the tool never asks Finder or another application to resolve them.

Retain the ancestry/root handles and compare named-versus-held identities before
each descendant acquisition and again at closure. Probe every layout component
relative to those handles without following descendant links. A raced name cannot
steer an already held base to a replacement root; a fixed-file/base/locale link
or detected ancestry change refuses that occurrence before bytes are acquired.
Record the exact operation failure rather than reopening a changed name. These
checks establish their observation boundary; they cannot certify atomic placement
through an unobserved move-and-restore race, mount health or no opaque kernel
contact. Such limits do not justify a whole-path fallback or outside acquisition.

The ordered information/resource pairs are Contents / Contents/Resources,
Support Files / Support Files/Resources, Resources / Resources, and root / root.
Advance to the next layout only on established missing layout directories.
Denial, unknown type, link or lookup error stops selection with an explicit
unavailable/refused layout; an absent resource base does not select a new
information layout. Package the two information basenames at the selected
information base, the four name basenames at its resource base, and all six
basenames in every checked direct locale. Every probe gets a state record,
including absence. Coincident bases keep distinct logical roles even when they
share physical bytes. No executable, selected-language subset, indirect locale,
nested app search or other basename is acquired.

Inventory only the selected resource base's direct entries. Save returned raw
component bytes and ordinals, including structural dot entries if emitted; do not
descend into them. Classify Base, malformed names, non-locales, links, unknown and
non-directory .lproj entries with explicit reasons. Checked direct .lproj
directories, including Base.lproj, retain the complete six-file evidence; Base's
reader-selection branch remains distinct. Type checking never follows an inventory
entry link. Keep the raw sequence and any separate byte-sort permutation.

Open fixed regular files with no-follow semantics, compare named and held
device/inode/type/size/stamps, then stream to an exclusive evidence object through
exact EOF and recheck the held and named observations. Read failure preserves the
actual prefix/extent and error. A non-regular file is never opened for bytes.
At closure independently repeat the declared inventories, identities and exact
file reads and compare every associated item; equal sizes alone are insufficient.
The 131,072-byte reader branch is recorded without clipping larger authorized
files. A storage/allocation/I/O refusal retains its precise incomplete boundary;
this design selects no new evidence cap or production amount.

### Native typed decoder and fidelity limits

Select `CFPropertyListCreateWithData` with immutable results and its format/error
out-parameters, operating on packaged bytes only. Apple documents the
[data parser](https://developer.apple.com/documentation/corefoundation/cfpropertylistcreatewithdata(_:_:_:_:_:))
and [format cases](https://developer.apple.com/documentation/corefoundation/cfpropertylistformat);
the installed SDK declares OpenStep, XML v1 and binary v1 formats. This selects
the concrete route; actual XML/binary/OpenStep and .strings acceptance still needs
the frozen pure specimen programme. No header guess or file extension substitutes
for the parser's reported format. Keep original header/BOM/encoding evidence and
unknown/unsupported distinctions separately. An undocumented rejection cannot be
asserted to prove malformed input: retain the parser failure and an unestablished
format/validity classification until independently supported.

Walk the entire result using `CFGetTypeID`, checking CFBoolean before numeric
handling, rather than bridging to a language dictionary or NSNumber truth value.
Use ordered entry arrays for every CFDictionary enumeration and ordered arrays
for CFArray; record native enumeration as observed, separately from lexical order.
Export CFString as complete big-endian UTF-16 code units, CFData as exact bytes,
Boolean as its Boolean value, and CFDate as the decoder-observed binary64 absolute
time bits with its 2001 epoch. Strings are never normalized or repaired. Derived
UTF-8 lengths require an exact representable conversion; failure leaves that
length/branch unavailable while preserving the original code units.

For CFNumber, record its observed storage type, byte size and integer/real branch.
Export integer values as signed decimal strings only after exact public conversion
succeeds; verify reconstruction against the observed number. Real values carry
decoder-observed IEEE bits, including signed zero, infinities and NaNs, rather
than JSON numeric literals. Unsupported wider integers, native types or lossy
conversions make the typed observation explicitly incomplete and retain the bytes;
they cannot become a fabricated string value. Apple's
[number documentation](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFPropertyLists/Articles/Numbers.html)
distinguishes stored numeric type from input representation. The export preserves
decoder observations, not a promise that CF preserves original integer width,
NaN payload, lexical date spelling or serialized key order.

Pin the acquisition/decoder executable digest, source and build inputs, compiler
and SDK identities, OS build and the runtime image identities obtainable through
the public loader. An unavailable identity is a stated qualification gap; an SDK
header or historical open-source CF implementation is not proof of the current
loaded runtime. Qualify duplicate serialized keys separately for each admitted
format, preserving original bytes and independently authored duplicate positions,
the observed surviving native entries and resolution/coercion limits. Never claim
the semantic tree contains serialized duplicates. A format or duplicate branch not
qualified is explicitly unqualified; changed images invalidate the affected proof.
These identities and observations are not yet supplied by this design.

## Proposed envelope version and verification interface

The selected envelope version is `koine.application-reference-evidence/1`.
Its executable field schema and exhaustive validator must be materialized and
qualified during construction, before any target acquisition. It has the following
closed record kinds; implementation cannot silently omit a field group from the
earlier [required record model](#evidence-records-and-association-keys).

| Record kind | Closed payload and relationships |
| --- | --- |
| attempt | Permission digest, reference/build, declared phases, tool/input identities, intervals, terminal result and limitations |
| source | Phase, raw stream object references, framing, launch/reap/read outcomes, all ordinal slot bytes and root/reason links |
| root | Source occurrence links, literal/resolved bytes, scope/ancestry/link observations, before/held/after identities, layout/base observations and copy/alias relations |
| inventory | Root/base/phase, raw entry ordinals/bytes/types/classification, stamps, sorted permutation and complete/error outcome |
| file | Root/base/locale/basename role, every probe state, named/held/after facts, complete/prefix extent, object and decoder links |
| decoded | File/object/tool coordinate, original-format evidence, parser format/error, complete tagged tree or exact incomplete coordinate, duplicate/coercion qualification reference |
| branch | Exact file/tree coordinate, named candidate/flag/version/table/LocProvenance branch and full associated tagged value where present |
| tail | Exact root/file/entry/tree coordinate, byte or code-unit measure, representability and branch/selection relation |
| closure | Per-item before/after differences, object/record digests, missing/unavailable work, input/image stability and separate byte/typed/association verdicts |

Every record has version, kind, packet-local coordinate, phase and an explicit
outcome. Outcome variants observed/absent/refused/unavailable/error each have
closed required fields; missing keys are schema failure, not null absence. Native
parse failure has its own decoded outcome. Foreign fields or variants are rejected
at every nesting level; a future extension requires a recognized new version.
JSON duplicate member names, lossy numbers, dangling references and ambiguous
coordinates are errors. Arbitrary original dictionary keys live as typed entry
data, not envelope schema extensions.

Use canonical padded base64 for all raw bytes and UTF-16 units; lengths and
nonnegative ordinals use exact integer encodings. Native integers use decimal
strings and floating/date bits use fixed-width hex strings. SHA-256 references
bind complete immutable objects; partial objects carry prefix length and outcome,
never the complete-file digest. Ordered occurrence arrays preserve repetitions;
canonical JSON object-key ordering does not sort those arrays. The closed tagged
tree variants are dictionary, array, string, Boolean, integer, real, date and data;
an unsupported native type cannot masquerade as a successful tagged extension.

Coordinates include source phase/ordinal, root observation, base role, locale raw
component, basename and tree path. Tree paths identify array positions or dictionary
entry/key code units; an independent comparison may match dictionary members by
exact keys while preserving the observed enumeration separately. Same identifier,
same digest or equal-length tail never merges copies. Physical aliases require
checked root identity and observed relationship; every repeated source occurrence
and helper/alias-target fixture still has complete logical file/branch/tail links.

Helper is an independently authored pure specimen role at this boundary, not a
native helper-purpose or inferred nested-containment field. Current per-copy purpose
is independently established after capture. Helper controls mutate its actual
source/file/tree/tail coordinates; physical alias controls use checked root identity
and occurrence links. Nested bundles are separate emitted slots, without traversal
or an invented containment edge.

The verifier takes two inputs: an immutable package and a separately frozen
expectation. It validates the schema and recomputes byte lengths/hashes/format
evidence, complete required occurrences, tagged trees, reader branches and tail
associations against the expected specimen. The expectation is authored before
the producer runs; no producer report, decoder rerun alone or copied producer tree
supplies it. Binary/XML/OpenStep positives include hand-authored known values and
explicit unsupported/malformed/duplicate limits. Counts are diagnostics only.
Every mismatch reports a stable record/tree coordinate and expected failure class.

## Permission inputs and reporting outputs

These are **design contracts**: no executable schema, authority receipt or passing
proof exists yet. The canonical [bounded permission](application-population-metadata-shape.md#one-bounded-reference-packaging-pass)
remains authoritative. Construction creates a closed permission profile, its strict
independent reader and a frozen requirements extract together, before measurement.
The tool cannot derive its own permission from defaults or a changing report.

| Permission group | Required exact value or rule |
| --- | --- |
| Reference/source | macOS 27.0.1, build 26A434; /usr/bin/mdfind; exactly -0 and the application-bundle predicate stated above; no shell or extra options |
| Attempt/phases | One target attempt; initial and closure only; closure compares, never retries, repairs or fills missing initial evidence |
| Scope/resolution | /System, /Applications and /Library on BOTH literal and walk-resolved component prefixes; checked .app directories; the descriptor ADR's kernel semantics/search-only walk/32-link limit |
| Layout/files | Four ordered layouts, absence-only advance, both information and all four name basenames, all six in every checked direct locale; no language subset or descendant-link following |
| Evidence | Complete raw slots/inventories/original regular-file bytes, complete typed observations or explicit limits, every copy/file/alias/tail association and before/closure check; no clipping to the reader limit |
| Failure/effects | No silent repeat/resume, overwrite, arbitrary recursion, executable acquisition, launch, index/registration change, download, helper, new consent/signing/posture or native/VM capture |

The independent reader rejects unknown/missing fields, duplicate JSON members and
any changed value. Compare the full profile against an independently authored expected
value and a field-to-clause concordance with the canonical requirements, including
prohibitions. Review and freeze the concordance first: a hash alone establishes no
semantic equality, and copying the tool's constants is not independence. Compare actual
compiled intents with that expected value during [rehearsal](#fixed-composition-without-target-contact).

Freeze the canonical selected-reference/evidence requirements as original UTF-8 text
with explicit section boundaries, source identity and digest. The delimited normative
extract is a measured input; the whole document digest is snapshot provenance. At
admission independently extract the same sections from the current canonical document
and require exact equality. Changed text or ambiguous boundaries refuse. Reporting
edits outside those sections may change the document digest without changing permission.
Changing a normative section/profile/concordance requires fresh affected qualification.
The profile contains no proof identity and supplies no new authority.

| Partition | Freeze/mutation rule |
| --- | --- |
| Qualified inputs | Retained executable; source/build/compiler/SDK/configuration; permission profile/extract/concordance; schemas, verifier/runner/native observer/contact collector; complete fixtures/expectations/runtime observations; independently required inventory; Taskfile and every reachable recipe/script actually read |
| Execution context | Actual OS/build, loaded runtime/tool/image identities, composition/gate selection, argv/environment, working directory and descriptor/fixture bindings; obtain these rather than infer them from source hashes |
| Live authority inputs | Independently authorized receipt/location/UID and actual directory identities, checked before reservation; scratch receipts qualify validation behavior, never authorize or require byte equality with a later live receipt. The live receipt must bind the same qualified permission profile; any changed permission requires fresh qualification |
| Qualification outputs | Original logs, per-coordinate proofs and aggregate verdict, bound to the complete input identities; never hash the aggregate proof into its own inputs |
| Reporting outputs | Prose outside normative extracts, diagrams and promotion references; cannot supply admission facts or change a measured input while inheriting its proof |
| Target outputs | Authoritative attempt header, actual segments/objects and closure; not qualification inputs or authority to acquire again |

Check the declared read set against observed dependencies and reviewed composition.
If a recipe/verifier reads a reporting document, it becomes an input. Finish all
reconciliation and executable/schema/fixture/task edits before measurement. Afterwards
write proof references only in reporting outputs. Review repairs require requalification;
neither reconciliation nor writing a proof into a pinned document inherits the old run.

## Authoritative attempt evidence

[Admission → Bind one permission to one durable start](../design/architecture/index.html#diagram-native-reference-admission)
shows the proposed boundary. One fixed local evidence directory is bound to one stable
permission identity by a separately recorded authorization receipt. The stable name
`koine.reference-evidence.macos-27.0.1-26A434.1` identifies this grant; a changed document
digest or export name creates no successor. The proposed subject is the user's
Library/Application Support/Koine/ReferenceEvidence/permissions directory plus that
name, with its actual absolute location/UID bound in the receipt. It is outside the
caller-selected export and a restorable checkout. The receipt binds its absolute location,
checked directory/ancestor identities, permission-profile identity and one-attempt grant.
Packaging accepts only an export destination; it cannot select another authority subject
or mint a new permission identity. All original attempt evidence lives at the fixed subject;
the export is a derivative, never the sole start record.

**Authority remains unresolved.** The existing permission supplies neither this receipt
nor proof that an absent subject means first use rather than deletion. Recommended to
Antony: fail closed and require separate explicit authority for uncertain first-use
initialization. No receipt, initialization, replenished pass or target call is authorized
by this document. Until a decision and actual receipt exist, target admission is
unavailable. The construction plan must retain a concrete authority-decision/receipt
prerequisite before the target consumer, never synthesize an empty receipt by default.

Given explicit authority, the cooperative protocol is:

1. Independently validate the receipt/profile and open its exact evidence subject
   without following replacement links. Missing, moved, replaced, unreadable or
   uncheckable subject/ancestry refuses. Never scan elsewhere, recreate it or reset.
2. Hold an exclusive nonblocking flock on the fixed authorization receipt's held file
   descriptor across admission/publication and recheck named/held identity. This is
   ephemeral synchronization, not a lock-file
   status artifact. Concurrent callers with different exports share the same subject.
3. Exclusively create the single fixed attempt directory. Its immutable header binds receipt,
   permission, invocation and qualified proof/input/image identities. Persist the header,
   acquisition-start reservation and directory entry using qualified file flush/full-flush
   and directory synchronization operations **before** target spawn. No error path
   removes/recreates the attempt.
4. Any existing entry, including an empty/partial/unreadable header, is prior-start or
   uncertainty. Failed durability acknowledgement permits no contact and retains that
   entry. A persisted reservation conservatively consumes the attempt even if death
   precedes the query. Recovery of that possibly unused pass needs explicit new authority.
5. Preserve actual segments and unfinished prefixes at that attempt. Export deletion,
   movement or unreadability cannot reopen admission. Lock release on death does not
   refund permission or authorize resume; closure finalizes evidence only.

Actual scratch qualification must establish locking, exclusive-create and persistence
on the selected filesystem, with two processes, crash points, short writes, directory
replacement and lost/unreadable exports. Unsupported or unknown durability/identity
refuses before contact. This is a cooperative local boundary, not tamper resistance:
the same user/admin can forge/restore the receipt and whole subject, bypass the tool or
run mdfind. Detected loss fails closed; indistinguishable rollback and unobserved
delete/restore remain adversarial limits. No secure monotonic/cross-machine store is
claimed. A stronger service or OS authority needs a new human decision.

Scanning caller-selected exports was rejected: moved/deleted outputs and a second
fresh name defeat the check. A fixed subject concentrates concurrency and durability
at one owner, at the cost of conservative refusal and explicit initialization authority.
A secure monotonic service would strengthen rollback resistance but introduces unselected
authority/helper dependencies; it is not silently substituted. If those limits are
unacceptable, retain unavailable admission until Antony selects the stronger alternative.

## Closed qualification proof and required inventory

Proposed proof version is `koine.application-reference-qualification/1`, separate from
the evidence envelope. Before any coordinator consumes it, construction delivers the
closed executable schema, independently authored required inventory, usable admission
verifier and omission controls. These tables are its design, not its implementation.
Every nesting rejects unknown/missing fields and duplicate members; outcome-specific
fields are required, references unique/resolved and byte/number encodings exact. Empty
lists/null cannot represent unperformed work as passed.

| Proof record | Required payload |
| --- | --- |
| subject | Proof/schema/inventory versions/digest; full permission/extract/concordance/read-set identities; actual retained executable and OS/runtime/image identities; pure composition |
| run | Unique coordinate, task/command/edge, actual before/after input identities, interval, process tree, terminal/reap result, immutable original result/contact objects and performed/unperformed work |
| case | Required coordinate/applicability rule, fixture/expectation identities and provenance, role/format/layout/phase, intended positive/failure, actual coordinate/reason, gate and external-contact links |
| pair | Positive and isolating mutation coordinates, changed operand, evidence it reached the intended check, unaffected checks and matched input context; incidental schema rejection is insufficient |
| observation | Independent runtime/collector tool/input/image identities, original narrow result, coverage/calibration and limitations; producer trace has a different provenance tag |
| verdict | Each required coordinate satisfied/failed/unavailable with reason; exact missing/extra/duplicate/stale coordinates and completeness; counts are diagnostic only |

Author and freeze the inventory from the **whole** contract before the first construction
stage, independently of produced case lists. Enumerate then classify the cross product:
obligation/control; XML/binary/OpenStep/unsupported/malformed; all four/coincident layouts;
ordinary/helper/alias-target/repeated role; initial/closure/failure phase; file/outcome/typed
variants; producer/real-adapter/fixed-composition boundary. Each cell has a stable coordinate,
expectation source, intended mutation, required observer and construction owner. Inapplicable
cells need independent reasons (a source pipe has no layout; parse failure has no successful
tree). No runner derives applicability from tests it happened to find. Every normative
obligation maps to applicable positives and isolating negatives, and each case maps back to
the concrete branch reached. Do not demand meaningless combinations or hide meaningful
ones behind sparse fixtures. Helpers/aliases need their actual file/tree/tail coordinates.

An inventory correction is a reviewed input change, never post-run removal of a failure.
Schema extensions update validator/oracle/fixtures/inventory and rerun/freeze all affected
earlier stages. Old proofs retain their old scope; they cannot admit the extension.

The independent offline verifier has a strict admission entry. The qualification runner
invokes it after stage results; the fixed packaging launcher invokes it again on retained
artifacts before the coordinator may persist a start. It derives required coordinates from
the independent inventory, recomputes objects/results/pair outcomes, checks sets in both
directions, provenance/contact coverage and actual input/image/permission equality. One
schema-valid omitted case, ambiguous duplicate, stale runtime result, regression-only
independent expectation, unavailable observer or changed input refuses before contact.

Bind admission to an invocation nonce and proof/inventory/permission/read-set digests,
retained executable identity and held inputs. Send the result directly over a private
one-use process channel, never a reusable on-disk qualified=true token. The coordinator
checks the binding and identities at use; substitution/channel failure/unavailable identity
refuses. Hold inputs where possible and require final image/input checks too; this does
not prove hostile-user immutability. Verifier/runner/gate are themselves qualified inputs
with independent omission, forged-result, swapped-executable and cross-invocation controls.

## Contact observation outside the producer

Select an **external Darwin DTrace syscall-entry/return and process-lifecycle collector**
as the candidate for real scratch pipe/filesystem contact. Producer wrappers/fault traces
remain diagnostics, not evidence that a bypass made no syscall. The installed DTrace
manual describes a separate collector and published probes; it establishes no current
access/coverage. [Apple's SIP description](https://support.apple.com/guide/security/system-integrity-protection-secb7ea06b49/web)
also prevents assuming administrator rights remove OS restrictions. No collector command,
probe discovery or privilege change is executed in this design session.

First qualify the collector on separately authored scratch emitters/descriptor subjects.
Require readiness before child release; process-incarnation/descendant/thread coverage
through spawn/exec/reap; entry/return/error operands and raw path/component bytes;
descriptor creation/dup/inheritance/close and directory associations; and every actual
lookup/listing/open/read primitive reachable in the compiled adapter, including alternate
syscall routes. Pin collector binary/script, OS/kernel/probe inventory and all inputs.
Unknown descriptor/path association, truncation, event loss, attach gaps or missing
termination make a trace unavailable. Keep original events, not just filtered summaries.
Observe only the scratch process tree; installed-query observation is not a pure control.

A deliberate bypass issues a real scratch sentinel lookup/open/read outside **all** producer
wrappers, including a direct syscall route. Its producer trace is intentionally empty;
the external collector must identify the actual forbidden operation. Also control child
and concurrent-pipe bypasses, disabled collectors, wrong process filters, truncated paths
and induced event loss. Positives show actual allowed contact; negatives fail at that
contact coordinate, not on parser errors/nonzero exit. The sentinel is always scratch,
never mdfind or an installed root. This qualifies contact detection, not prompt/hydration
safety or opaque kernel internals.

**Collector capability is unestablished; required contact coverage is unavailable until
these controls pass.** Existing privileges/probes/coverage are not presumed. If qualification
needs new privilege, disabled SIP, entitlement, helper or VM/native work, retain that precise
unavailable boundary and seek a concrete human decision; none is authorized here. Never
substitute interposition, wrapper traces, static inspection, mocks or target experimentation.
The planner places collector capability/calibration before real-adapter qualification and
a concrete decision owner if it cannot qualify in pure scope. Replacement requires reviewed
design with equivalent independent direct-bypass evidence.

## Fixed composition without target contact

[Proofs → Observe completeness and contact before admission](../design/architecture/index.html#diagram-native-reference-proof)
shows the enabling point. Internally rehearse the **same retained executable**, fixed
packaging parser/constants, admission call, coordinator and real adapter implementations.
Packaging still accepts only a fresh export; no query/root/file/language/adapter overrides.
A separate internal qualification entry selects a sealed scratch context at the composition
point, not another packaging implementation or compiled image.

Every native adapter operation presents its exact intent to an always-present contact
gate immediately before execution. Rehearsal compares the requested fixed constants
against independent expectations, then maps only declared fixture identities to held
scratch descriptors or a pure emitter; unmapped intents refuse. /System/Applications/A.app
is a logical test value, never a /System probe. Scratch mappings are supplied by the sealed
fixture context, never discovered from installed paths. Real pipe draining, descriptor,
durability and decoder operations execute on scratch subjects and are externally observed.
Intercepted production requests are **intent evidence**; mapped calls are **actual scratch
evidence**. Neither establishes installed topology or mdfind output. The authority subject
and receipt used in rehearsal are isolated fixtures too.

The live gate requires the invocation-bound admission result and actual receipt/durable
start. A pure context cannot issue live contact permission, even when a higher layer is
miswired. The gate refuses before execution; the external collector detects actual bypass.
Mocked rehearsal alone cannot qualify real adapters, and gate logs cannot prove no contact.
The seam reduces caller knowledge: one context selects behavior at native contact, while
the same coordinator owns phase order, constants and failure recording.

Exercise the actual Taskfile entry and reachable script/task edges under the sealed pure
context. Deliberately rewire a scratch copy of a pure dependency to packaging, select a live
intent from pure mode, change a predicate/root/basename, omit preflight and reuse/forge
admission. Each reaches its intended gate/admission check and refuses before real mdfind
exec or installed-root syscalls. Preserve gate intents and independent collector evidence;
do not perform target contact as a positive control. Direct **scratch** bypass is the
collector detection control. Gate/verifier death or channel loss still refuses contact.
Changed scripts/tasks/binaries or unqualified observation invalidate the proof; static
reachability inspection is supplementary. Mutations are separate subjects, not qualified
replacement executables; freeze each before/after, then measure the unchanged candidate.

This unbuilt seam is empirical rehearsal, not an OS sandbox for hostile code. Review
must establish that the exact packaging path reaches it and scratch mapping cannot mint
live authority. Inability to exercise that composition with independent no-contact evidence
leaves the coordinate unavailable. The one target pass is never the wiring experiment.

## Independent decoder expectation classes

| Class | Establishment | Admissible claim |
| --- | --- | --- |
| Format-derived | Separately authored original bytes, serialized type/position/duplicate facts and independently derivable values | Original serialization/associations and only the validity/type facts established by the format |
| Runtime-corroborated | Separately authored narrow CF observation programme acquires facts directly from pure bytes on pinned OS/loaded images before producer comparison | That image's acceptance/error/format, stored number type, duplicate survivor, coercion, date/real bits and enumeration |
| Regression-only | Expectation first learned from producer output and later frozen | Change detection; cannot close a required independent coordinate |

Author XML/OpenStep encodings and binary object tables/trailers/offsets independently,
not exclusively through CF or normalizing serializers. Inspect serialized duplicate
positions even when CF returns one member. Format inspection cannot predict undocumented
CF rejection or certify preservation of lexical order, stored width or NaN payloads.

The separate native observation programme shares no producer traversal/exporter/numeric
formatting/expectation code. For fixed small specimens it calls CF directly and records
narrow raw results: parse/error/format, known-key duplicate survivor, CF type ID and number
storage/size, conversion return/value, string units, data and date/real bits. Its known-value,
acceptance/rejection controls and acquisition identities qualify before its observations
become expectations. Run independently and freeze original observations/tools, then compare
producer output through a different export path; never feed it a producer tree or copy one.

Both paths may use the same CF runtime: agreement corroborates the tool's extraction of
that runtime's behavior, not an independent CF implementation or a standard's guarantee.
Separate serialized numeric/date/NaN values from native conversion results. Check exact
values where independently derivable and corroborate storage/coercion/bits separately.
Missing runtime identity/disagreement fails or leaves a coordinate unavailable, rather
than revising its expectation from producer output. Changed images require fresh independent
observations and affected qualification. All programmes/specimens/controls remain unbuilt.

## Topology and the inherited component rule

The [descriptor-relative ADR](../adr/filesystem-access-is-descriptor-relative.md) owns
kernel resolution. Literal, link-expanded and walk-resolved spellings are held-walk
observations; the last is not a universal physical-volume pathname. Scope is exactly the
three prefixes on **both** literal and walk-resolved components. It is not a sealed-System
rule or device allowlist. /System/Volumes/Data is under the inherited /System prefix.
Excluding it, rewriting its spelling, or allowing an outside cryptex path because it is
Apple-owned changes permission and needs Antony's decision. None is selected.

| Independently authored pure specimen | Required result |
| --- | --- |
| /Applications-extra/A.app; relative/uncheckable bytes | Reject literal scope before contents; preserve raw reason |
| /Applications/A.app expanding to /Users/u/A.app | Reject resolved scope, with no root listing/contents |
| /Applications/A.app expanding to /System/Volumes/Data/Applications/A.app | Both prefixes pass; preserve spellings/checked identity, with no sealed-volume claim |
| /System/Volumes/Data/private/Specimen.app | Syntactic scope passes; checked app-directory/layout requirements still bind; no invented Data exclusion |
| Mount below an admitted prefix changing device identity | Record observable transition/identities; device change alone neither widens nor narrows syntactic scope |
| Firmlink redirect without observable link text | Preserve walk spelling/returned identity; no fabricated readlink step or hidden target spelling |
| System/cryptex link within a prefix versus outside all three | Admit former only with all root checks; refuse latter regardless of vendor; no historical-mount whitelist |
| Relative/absolute links, physical .., trailing slash, 32/33 expansions, named/held replacement | Exact ADR semantics and refusal; no lexical cleanup hiding resolved scope/identity changes |

Use controlled topology/identity inputs; run actual scratch symlink/descriptor cases
where possible without mounting or changing the OS. Simulated mount/firmlink cases are
labelled simulation, not evidence of platform implementation. The saved [25F71 mount
record](protected-path-metadata/environment.json) is historical comparison only.
[Apple's volume description](https://support.apple.com/en-euro/guide/security/secd698747c9/web)
distinguishes system/data storage, not current reference paths. No current topology probe.

A held walk observes returned device/inode/type/stamps, explicit links, spellings and
named/held changes. It cannot generally discover hidden redirect targets, prove unchanged
mount topology between checks, atomically certify physical ancestry or prevent opaque
mounted-root contact before refusal. Unobserved move/restore and alias limits remain.
Pure tests qualify honest records/refusal, never historical topology as native completeness.

## Attempt durability and per-control proof

Before target spawn, persist an exclusive attempt header and acquisition-start
reservation at the fixed authoritative subject, independently of the export. Finalized
objects/observation segments are write-once; retain unfinished temporary segments
and actual prefix extents after
interruption. Record segments belong to the evidence envelope, not a separate
session-status file. The final closure commits only after input freeze and all
item comparisons; the offline verifier never manufactures missing observations.
Unexpected death without a complete closure is interrupted/incomplete even if
some objects are intact. Failure to preserve a record is itself missing evidence.
Existing output, a prior reservation or an uncertain authority subject refuses
reacquisition; offline inspection may describe that attempt but may not read a newer
target or resume it. Only k245 owns
the selected pass; invoking a fresh attempt after target start needs new authority.

Pure qualification never invokes mdfind or opens an installed reference root.
It runs the real framing/held-plan/decoder/envelope logic over fake streams,
fault-injected directory operations and repository-authored bytes. Also exercise
the real pipe runner against a pure stream emitter and the real descriptor adapter
against isolated, constructed scratch directories; their internal test composition
supplies fixture handles, never broadens the packaging interface. Mock-only tests
cannot qualify the actual syscall adapter. The fault seam records every lookup,
listing, byte-open and read. Independent allowed
contact expectations identify the first forbidden operation; a refusal verdict
without a matching no-contact trace fails qualification. Include faults between
name/held checks and acquisition, root/descendant replacement, wrong build/scope,
pipe termination, partial reads, tool changes, cleanup and interruption. Exercise
ordinary copies, helpers, repeated roots and alias targets, not useful copies alone.

For each row of the [control matrix](#independent-controls-required-before-target-acquisition),
save the immutable fixture/expectation/tool digests before and after, positive
verdict, deliberately broken counterpart, actual rejection coordinate/reason and
contact trace. A negative that fails incidentally for a schema typo does not pass
its intended association, clipping or type control. Independently expected outcomes
must verify that each mutation reached the relevant check. Observe every applicable
negative fail before crediting its positive; source permutation and complete
dictionary-enumeration permutations have explicit preservation-positive cases.
Changed input/tool identity invalidates the entire run, rather than removing an
item from its totals. Separate runs get separate outputs and item-by-item comparison.

K244 owns original-byte/tree/inventory/copy/alias integrity and every applicable
fault control. K246 owns **generated** thin same-cardinality replacement, declared
identifier/executable/signing rewrite positives and undeclared type/serialization/
branch/tail negatives, across useful/helper/alias relationships. Those generated
controls require complete k245 evidence and independent source-to-generated
coordinate mappings. Original SHA-256 equality is deliberately not that oracle.

## Construction and qualification boundary

The concrete instrument is production-tool implementation-sized. K244 is now a
node retaining its full original Done when. The initial design and planning handoff
proposed five dependency-ordered construction increments. Planning review exposed
cross-cutting admission and qualification gaps. A new admission-design producer with
mandatory whole review and earned integration, then a construction-replanning producer
with planning review and earned integration, precede the first construction increment.
They must resolve authoritative prior-start evidence, frozen permission/input versus
reporting identity, complete proof/inventory ownership, independently observed real
contact, exercised no-target composition, runtime observation provenance and topology
specimens. The sections above now specify their design. Whole-design review/integration
still precede construction replanning. The authority receipt/uncertain-first-use decision
and actual external collector capability remain precise unavailable prerequisites;
selected design mechanisms are neither new permission nor qualified executable behavior.
Their intended handoffs are independently usable offline replay, native byte decoding, lossless
source observations, held-directory evidence acquisition, and durable attempt
coordination with complete pure qualification. The schema and a usable validator
land together. An earned planning review precedes construction; each later stage
retains working earlier checks. No construction stage contacts the selected target.
The original node
cannot close on the design or a plan; the first target query remains after the
completed tool qualification, under k245. Mandatory whole-subject/family review
and earned integration remain due at k247 before private construction and k7.

| Working increment | Independently demonstrable handoff | Required completion evidence |
| --- | --- | --- |
| Offline replay/admission | Closed envelope/proof schemas, independently required inventory and usable independent verifier | Authored complete/failure envelopes, schema-valid missing-proof rejection, exact object replay and full original association/mutation controls |
| Native decoding | Immutable bytes to native tagged tree, complete branches and joint tails | Actual CF formats/types/duplicates/coercion and loaded-image identity, checked by the independent byte/type oracle |
| Source observations | Real concurrent emitter pipes to raw slots and initial/closure comparison | Actual EOF/termination/reap/fault traces, multiplicity and association-preserving permutation proofs |
| Held acquisition | Scratch scope/layout inspector, complete fixed-file/direct-locale evidence and full item closure | Actual descriptor and injected race/no-contact proofs; all six locale files, complete/partial objects and every logical occurrence |
| Qualified attempt | Fixed-authority coordinator, gated exact composition and matched complete qualification | Independent admission, external bypass/contact proof, actual task-edge rehearsal, complete matrix and full original-obligation closure after review/repair/requalification |

Construction uses a standalone Swift evidence-tool package and a separately
implemented Python verifier with independently authored fixtures. Neither depends
on a Koine provider or the legacy lossy capture. Per-stage reusable pure checks
and their actual tests land with the behavior they verify; no dormant schema or
placeholder target recipe is a completed working increment. A pre-closure envelope,
scratch demonstration or schema-valid failure is never a stable qualified package.
Missing/failed controls and unavailable required identities remain live work before
target admission. The revised plan must assign the complete original-obligation check,
early independently required proof inventory, review/repair/requalification and final
reconciliation to explicit owners. The original final-stage assignment remains a
proposal until that repair. An aggregate passing count supplies none of those duties.

The replanning producer assigns distinct owners for: early inventory/proof/admission
construction; byte-specimen authoring and independent native observations; collector
capability and calibration; actual scratch adapters; fixed-composition/gate/task-edge
rehearsal; whole-instrument implementation review and earned integration; final unchanged
candidate measurement; and audit/reconciliation/promotion/closure. Review repairs happen
before final measurement; a distinct live requalification/closing owner survives them.
Unavailable observer, identity or required coordinate cannot be relegated to closing prose.
The separate authority requirements work precedes target packaging; it authorizes no tool
or target by existing. K269 owns the construction slices, rather than this design cutting
implementation leaves.

Source-only closure compares complete spelling/occurrence multiplicities and raw
permutations. Held acquisition closure later associates both source phases with actual
held root identities and checked physical aliases; a stream emitter cannot establish
those facts. Required unqualified branches or controls become precise live repair and
qualification work before affected consumers. An unobtainable required identity calls
for an explicit trade-off, not an unrecorded omission or a passing closure. A schema
extension requires the independent validator/oracle/fixtures/inventory to change and
all affected earlier checks to be rerun with complete before/after input freeze.

Construction must add and verify two distinct Taskfile entry points: pure
qualification with no live target-contact authority, and bounded packaging with only a new
export destination. Pure rehearsal can enter the fixed dispatcher under a sealed scratch
context; ordinary tests have no live packaging dependency. Packaging checks the exact installed macOS 27.0.1 (26A434)
build, complete matched qualified tool/input identities and frozen permission,
rejects arbitrary scope and existing output before contact, persists the start,
and preserves any interrupted attempt. Build changes or unavailable checks admit
no target call. Unmodified pure recipes have no live packaging dependency; deliberate
task-edge mutations run only within the sealed scratch rehearsal. Packaging executes
the retained qualified executable without rebuilding it. A rebuilt candidate must
match the actual qualified binary and all other required identities, or receive
complete fresh qualification; matching source alone is insufficient. Runtime-image
continuity remains an actual checked prerequisite, not a binary-digest inference.
No reproducible binary build is claimed by this design. No placeholder
target command is installed by this design; those executable recipes and their
actual proofs remain k244 construction obligations. The existing render and
documentation checks verify presentation only.

No compiled instrument, executable schema, decoder identity, specimen/verifier
proof output or executed pure-control matrix is delivered here. These are precise
remaining obligations, not a completed instrument or a failed authorized pass.
The one target-pass permission remains unused. K245's payload/independent role
manifest, k246's generated recipes/discrimination, actual supported-VM dimensions
and every native qualification/eligibility/release obligation remain unestablished.

## One-pass acquisition and closure

Qualification uses independent **pure** subjects first. Before the first authorized
target query or contents read, pin the complete instrument, verifier, pure fixtures,
configuration, Taskfile, decoder/executable/tool inputs and their qualification
outputs. Check the installed version and build exactly against macOS 27.0.1
(26A434). A mismatch or unavailable build check authorizes no target acquisition.
The build check alone does not consume a contents pass or qualify a reference.
Current permission is fixed; tests cannot broaden it.

The coordinator's required order is admission and durable start; complete initial
source terminal/reap/framing; initial held-root/layout/inventory/file acquisition;
complete closure source and its held-root associations; full item inventory/identity/
byte rereads and comparison; final input/image freeze; final closure publication.
Failure leaves all later unperformed work explicit. Closure never substitutes for
initial source or acquisition, and final publication cannot precede comparison/freeze.

Reserve the fixed authoritative attempt and a unique immutable export before source acquisition.
Never overwrite the historical packets or a prior attempt. The attempt envelope
contains actual acquisition observations and interruption/error evidence; it is
not a separate session-status file. Once the durable start reservation exists, an interrupted,
refused, changed or incomplete attempt consumes this pass. There is no automatic
retry, resume with newer bytes or second inventory-only acquisition. Preserve the
partial evidence and name the exact missing work; another pass needs a new explicit
authorization. Before/after reads within this declared attempt are its integrity
checks, not another subject construction.

Use the exact indexed application-bundle path predicate
`kMDItemContentTypeTree == 'com.apple.application-bundle'`. The instrument must
qualify lossless source-slot framing, successful terminal response handling and
failure detection before use. Save all returned slots, including duplicates and
unusable/outside entries. A zero exit status or an empty result is not evidence
of all-disk completeness or healthy indexing. Query status, tool output and errors
are original observations, not grounds to drop rows.

Read contents only for checked .app directories whose original spelling is under
/System, /Applications or /Library **and** whose resolved root remains within
those same locations, using component boundaries rather than string prefixes.
Outside, malformed, unavailable and non-directory slots stay in the raw sequence
with a reason, without contents acquisition. Scope checks and held-directory
containment must precede descendants; a symlink/race cannot turn an in-scope
name into permission for an outside read. Nested app bundles are independent
source slots, never found by recursively walking a parent app. File alias objects
that are not checked app directories do not authorize alias resolution or contents.

Observe the ordered Contents, Support Files, Resources and flat layout candidates.
Only established absence advances layout; refusal/unknown is not absence. Pin the
selected information and resource bases, and the observations that selected them.
Package both information files at the selected information base, all four name
files at the selected resource base, and **all six fixed basenames in every checked
direct locale directory** of that resource base. Save every raw direct entry there,
including non-locales, rejected names, Base and non-directory .lproj entries.
Observe direct children only; there is no recursive locale or arbitrary contents
walk. Do not follow a fixed-file or direct-locale symlink to acquire bytes.

The information basenames are Info-macos.plist and Info.plist; the name basenames
are InfoPlist-macos.strings, InfoPlist.strings, InfoPlist-macos.loctable and
InfoPlist.loctable. Platform/plain alternatives and unselected files are evidence
even when the production reader would stop earlier. This instrument does not
apply the reader's selected-language plan. Coincident bases or repeated source
spellings may share a verified physical byte object, but keep every logical
copy/base/file/source occurrence and its observation. Deduplication cannot delete
an association or imply the production job reads that file only once.

## Evidence records and association keys

The versioned manifest must reject unrecognized fields at its validation boundary
or explicitly inventory them for a versioned extension. No parser silently drops
an unknown field. Logical record keys are packet-local observation coordinates,
not product resource references, bundle identifiers or claims of stable identity.
Each record carries an explicit observed/absent/refused/unavailable/error state;
missing records and null values are not interchangeable.

| Record | Required original facts and links |
| --- | --- |
| Attempt | Permission/reference version, actual OS version/build before/after, acquisition interval, source/tool/decoder identities and exact invocation, input/output digests, terminal outcome and completeness limits |
| Source sequence | Separate before/after raw response bytes and framing, ordinal for every slot, exact spelling bytes, repeat multiplicity, terminal status, linked root observation or explicit out-of-scope/refusal reason |
| Root/copy | Original and resolved spelling bytes, scope checks, before/held/after directory device/inode/type and available nanosecond stamps, source-slot links, observed symlink/root-alias relations, selected layout/bases and every failed candidate observation |
| Direct inventory | Base/copy coordinate; complete raw entry sequence with ordinals and exact component bytes; directory/file/link/other/unknown observation; checked locale classification and reasons; before/after observations; no Unicode normalization |
| Fixed-file occurrence | Copy/base/locale coordinate and basename bytes; named/held/after identity/type/size/stamps, file state, complete or partial-read extent and error, immutable byte-object reference, byte length and SHA-256, detected format/encoding evidence and decoder observation |
| Typed observation | Byte-object and file coordinate, exact decoder/tool identity, success/malformed/unsupported/refused/unavailable status, complete tagged tree or explicit failure, typed candidates/flags/table witnesses with tree coordinates, no absent-as-null projection |
| Tail index | Every included file length, direct component byte length and relevant candidate/key/string byte length, linked to its exact copy/file/tree coordinate and selection/rejection branch; maxima are derived references, not unattached padding targets |
| Closure | Item-by-item before/after comparisons and differences, immutable object/manifest digests, missing/refused/changed/unavailable inventory, input/tool stability, decoder limitations, replay/association limits and final completeness decision |

Manifest ordering is explicit. Raw query and directory enumeration order is kept
as observed; any byte-sorted derivative stores the permutation back to the raw
sequence. Repeated source slots retain their separate ordinals. Equality checks
compare complete component/occurrence multisets and copy/file/identity associations,
not merely counts or means. A pure permutation may preserve those facts; store both
sequences and report the ordering change rather than pretending byte-identical raw
responses. Later workload recipes declare their own exact ordering/multiplicity.
Alias equivalence comes from checked root identity plus its observed relationship;
same bundle identifier or equal file digest alone establishes neither a physical
copy nor an alias. Versions derive from the associated information tree and retain
absent/malformed branches. Where identity/alias/version association is unestablished,
leave it explicitly unestablished, never infer it from a basename.

## Original bytes and complete typed witnesses

Store complete original regular-file bytes in immutable byte objects; verify each
object's length and SHA-256 independently. A partial read stores its exact prefix
and actual error, never a complete-file digest. Save empty regular files as zero
bytes, distinct from absent, non-regular, denied, unreadable and malformed files.
The reader's 131,072-byte limit is a **reader branch**, not an evidence clipping
rule. Retain an authorized larger file's complete bytes where the instrument can;
otherwise report the exact refusal and an incomplete package. No implicit new
evidence cap, fabricated padding or sample language is selected.

Format/encoding evidence describes the original object, not a conversion export.
Keep binary/XML/OpenStep/unknown distinctions, original BOM/encoding/header evidence
and the decoder's actual accepted format. An unsupported format is not malformed
merely because a convenient parser rejected it. A conversion may be a separately
pinned decoder witness, never the original payload. Pin every converter and input;
conversion failure or lossy conversion leaves that typed obligation unavailable.

A successful typed witness exhaustively traverses the decoder's returned property
list: each dictionary key/value, array position, string, Boolean, integer, real,
date, data and any supported tagged extension. Preserve lossless string content,
data bytes, numeric representation needed to distinguish Boolean/integer, signed
zero and special reals, and exact decoder-observed dates. Record dictionary
enumeration order separately from serialized order. Original bytes preserve lexical
order, encoding and duplicate serialized-key evidence; a semantic dictionary cannot
claim to reconstruct them. Decoder coercion, duplicate-key resolution or an
unsupported native type must be disclosed and independently qualified; an invented
tree or Python type-name projection cannot stand in for native typed observations.
The instrument child must select and qualify its concrete complete decoder route.

Every information and name file retains both CFBundleDisplayName and CFBundleName
candidates: key absent, present empty string, usable string, non-string with its
full tagged value, malformed parse, and unavailable observation are distinct.
Keep identifier, development-region, executable/version and both LSUIElement and
LSBackgroundOnly branches with full present non-string/non-Boolean values. Preserve
other information keys and values in the complete tree, not just the reader keys.
Selection/rejection witnesses cite that tree; they never delete unselected values.

Every loctable retains **all** raw top-level keys and values, every dictionary's
complete members and types, all languages and both candidates per member dictionary,
including rejected candidates. LocProvenance is retained with its complete typed
contents whether dictionary-valued or otherwise; it is a reserved fact, not a
language chosen for localization. Keep global/per-locale/platform/plain families
and each tail's language/key/file association. A maximum length or en/de projection
cannot substitute for any of these witnesses. The specimen verifier must detect
omission even when top-level counts and all global marginals still agree.

## Freeze and replay limits

For every acquired file compare named and held identities, measured size, actual
read extent, exact EOF and post-read status, then independently recheck the complete
inventories and associated file bytes at closure. Preserve item-by-item before/after
records; a total digest equality cannot locate a reassigned file. Any changed tool,
subject bytes, membership, identity or association invalidates the attempt's stable
package claim. Pin **all** measurement inputs before/after, including verifier,
expectations, fixtures, permission/configuration, manifests and tool executables.
Finish edits before running a measurement; one writer owns each destination.

An original-byte package supports byte replay and decoder-specific fact replay.
It does not certify an atomic filesystem/index snapshot, native query completeness,
native metadata correctness, signing/executable behavior or preservation across
unobserved races. Equal checks cannot rule out an intervening change restored before
the next check. Checked directory identity does not bind a cached index record to
current contents. These limitations are explicit even for a complete bounded pass.

Complete byte packaging, complete qualified typed evidence and independent useful
roles are separate outcomes. A retained unparsed file can satisfy byte preservation
while leaving its typed obligations incomplete. Empty/malformed originals with
established branches are useful **evidence** but do not themselves establish a useful
GUI template. Missing/refused/unknown evidence cannot satisfy the complete finite
subject. A well-formed failed attempt envelope is not a successful package.

## Independent controls required before target acquisition

Each test freezes an independently authored expectation and exact specimen bytes,
inventories and associations. Recompute actual lengths, digests, formats and typed
witnesses from the supplied specimen; do not bless producer-reported dimensions.
Observe each broken control fail for its intended reason before crediting the
positive run. A fault-injected acquisition seam must also demonstrate that forbidden
target reads never occur. These controls are **specified here, not yet executed**.

| Control | Required discrimination |
| --- | --- |
| Scope/build positives and faults | Admit the exact build and permitted component-bounded checked roots; reject wrong build, /Applications-extra, outside resolved roots, raced descendants and arbitrary query/file/language settings before contents contact |
| Raw-source framing and failures | Preserve empty/repeated/newline/non-UTF-8 slots losslessly where emitted; retain outside slots and source failure; truncated framing, incomplete terminal response and duplicate deletion cannot pass |
| Layouts and file states | Cover all four layouts, coincident bases, checked absence versus denial/unknown, empty/absent/non-regular/link/malformed/refused files and all six fixed locale probes; refusal cannot turn into flat fallback |
| Bytes and decoder formats | Exercise complete binary/XML/OpenStep and unsupported/malformed specimens; payload clipping, conversion substituted for original, wrong digest/length, absent/empty collapse and unavailable decoder reported as success fail |
| Full typed trees and candidates | Use both name keys and absent/empty/non-string alternatives, Boolean versus integer flags, nested dictionaries/arrays/data/date/real values and rejected values; omitted or coerced members fail |
| Full table/inventory shape | Remove an unselected language/key/dictionary, LocProvenance or its member, a raw rejected entry or exact component byte; equal counts and en/de outputs cannot rescue the mutation |
| Copy/file/tail associations | Swap files or equal-length tails between copies/languages/keys, lose an alias target or repeated source link while preserving global marginals; each mutation fails the independent association oracle |
| Freeze and attempt failure | Change one tool/input/file/identity/inventory during a controlled attempt, interrupt a read or force closure failure; no successful package, overwrite, silent retry or older/newer-byte substitution follows |
| Thin same-cardinality replacement | Replace every useful and helper tuple with thin fixtures while preserving app/helper/alias counts; fail joint evidence even if the cardinality gate passes |
| Declared rewrite positive and negatives | A permitted identifier/executable/signing rewrite passes **the later generated-shape verifier** with recalculated bytes/digests, explicit changed coordinates and preserved non-rewritten typed branches/tails; undeclared type/format/branch/tail changes fail |

The last two rows span the later generated subject, not original-byte integrity.
Original reference bytes must still match their pinned digests. The generated-copy
verifier compares declared edits and preserved coordinates against independent source
evidence; it cannot demand unchanged whole-row hashes after a permitted rewrite.
Exercise every applicable loss and permitted rewrite on useful and helper templates,
and on alias targets/relations, rather than checking useful templates alone. Alias
records do not invent new payloads or supply independent useful measurements.

### Admission-repair controls

The independent required inventory includes these controls in addition to every original
row above. They are specified, unexecuted, and never qualify from a design bit.

| Required positive / deliberate counterexample | Intended independent result |
| --- | --- |
| Two concurrent scratch callers, different exports | At most one fixed attempt reservation; loser refuses before emitter contact |
| Prior reservation, moved/deleted/unreadable export | Same fixed subject still refuses; no second contact or reset |
| Absent/moved/replaced/unreadable authority; partial header; death before/after persistence | Uncertainty refuses; prefix/start retained; no automatic first-use initialization or refund |
| Complete proof versus schema-valid omitted case/role/negative pair | Required-inventory coordinate identifies omission; proof's own count/list cannot admit |
| Permission profile matches frozen clauses versus one changed scope/effect/file group | Independent concordance/value comparison refuses before start |
| Reporting-only promotion versus changed measured extract/task/tool or proof inserted into an input | First preserves qualification; latter invalidates it and requires a new run |
| Real scratch pipe/descriptor calls versus direct syscall/child bypass with empty wrapper trace | External original trace detects exact contact, even with a clean producer trace |
| Ready complete observer versus drop/filter/attach/operand/identity loss | Relevant contact coordinate unavailable; no clean no-contact verdict |
| Exact retained composition versus miswired pure→packaging/live intent or omitted admission | Gate/admission rejects at intended coordinate before mdfind/installed-root contact; actual reachable task edges observed |
| Independent native observation versus copied producer tree/regression-only expectation | Corroborated pinned CF fact passes; provenance failure cannot close independent runtime coverage |
| Data-volume/mount/firmlink/cryptex/link specimens | Inherited literal/resolved component results and honest simulation/identity limits; no topology-derived scope change |
| Retained image versus rebuilt/swapped image, reused admission channel or changed runtime | Exact identity/invocation rejection; matching source or old proof alone cannot admit |

## Remaining boundary

Build the concrete instrument and independent verifier, qualify the complete pure
matrix and reusable tasks, then use the single target pass. Freeze independent
Apple/vendor-documented and Antony-confirmed roles for those exact copies/versions;
uncertain copies remain stress inputs. Freeze whole-template coverage and balanced
repetition, all rewrites and independent recalculation for 1,010 useful apps,
fourteen witnesses, 256 helpers, 128 alias targets and additive full actual VM
baseline/registration pressure. Report capacity/coverage conflicts without omissions.
Finally reconcile and review the **whole** subject/family before private construction
and app-and-file-search. No native fit, overflow, release or useful loss follows this
contract. The existing N5/N8/V11/V13 placement and every independent duty remain.
