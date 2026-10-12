# Byte-complete application reference evidence

[Evidence → Qualify the instrument before the one target pass](../design/architecture/index.html#diagram-native-reference-evidence)
shows the dependency boundary. Graphs enter at the dark Start here node;
numbered edges describe order. This is the **evidence contract and concrete
instrument design with required admission repair**. The target-reading instrument and its independent controls
are not built or qualified, and the one authorized packaging pass has not run.
The [construction boundary](#construction-and-qualification-boundary) keeps the
complete implementation/qualification obligations live under k244. This document
supplies no current payload, role assignment, finite population or native verdict.

Review reference-evidence-admission-k271 and integration k272 identified substantive
authority-consumption, trust-anchor, IPC observation, exact-entry and measured-input
gaps. Requirements reference-evidence-authority-k270 settle the
[delegated authority choices](application-population-metadata-shape.md#authority-and-admission-choices)
before the instrument node;
replacement design reference-evidence-admission-repair-k273 must close those gaps and
cut mandatory whole review/earned integration before construction replanning k269.
K273 is decomposed into authority lifecycle k274, independent anchors k275, full contact
boundary k276, exact packaging/runtime closure k277 and whole reconciliation k278.
The authority lifecycle and independent approval protocol below are concrete design
proposals; complete admission and no-contact coverage remain unavailable until the whole repair is reviewed. None of
these leaves grants authority by existing.

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
| External contact observer/containment | Independently qualified unprivileged full source/filesystem/IPC boundary → contact evidence or unavailable coverage | Direct/child/proxy bypass, process/descriptor association and event loss; a missing event cannot establish no contact |

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
with observed link expansions and directory identities, enforcing the canonical refusal
of outside intermediate operations with held common-ancestor entry. Check the resolved
component-bounded scope, protected/consent-risk handling and checked .app directory
before any listing/content
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
| Scope/resolution | /System, /Applications and /Library on BOTH literal and walk-resolved component prefixes; checked .app directories; the descriptor ADR's kernel semantics/search-only walk/32-link limit; selected protected-content refusal and outside-intermediate refusal with held common-ancestor entry |
| Layout/files | Four ordered layouts, absence-only advance, both information and all four name basenames, all six in every checked direct locale; no language subset or descendant-link following |
| Evidence | Complete raw slots/inventories/original regular-file bytes, complete typed observations or explicit limits, every copy/file/alias/tail association and before/closure check; no clipping to the reader limit |
| Failure/effects | No silent repeat/resume, overwrite, arbitrary recursion, executable acquisition, launch, index/registration change, download, helper, root/sudo collector, new consent/signing/posture or native/VM capture |

The independent reader rejects unknown/missing fields, duplicate JSON members and
any changed value. Compare the full profile against an independently authored expected
value and a field-to-clause concordance with every normative source, including
prohibitions. Review and freeze the concordance first: a hash alone establishes no
semantic equality, and copying the tool's constants is not independence. Compare actual
compiled intents with that expected value during [rehearsal](#fixed-composition-without-target-contact).

The canonical requirements own reference/source/cohort/attempt permission, selected
authority/approval/persistence/privilege/protected-contact clauses and prohibited effects.
The descriptor-relative ADR owns search-only/kernel resolution and the 32-link
rule. This contract owns closed acquisition/layout/association rules derived from that
permission. Each concordance field names its actual source section; absence from the
canonical paragraph cannot become an invented quotation. Freeze delimited normative
extracts from all three sources. The [normative extraction contract](#normative-extraction-and-field-concordance)
defines unambiguous boundaries and independent bindings, separating reporting without a proof/input cycle.
Adding a profile field cannot confer authority.

Freeze the canonical selected-reference/evidence requirements as original UTF-8 text
with explicit section boundaries, source identity and digest. The delimited normative
extract is a measured input; the whole document digest is snapshot provenance. At
admission independently extract the same sections from the current canonical document
and require exact equality. Changed text or ambiguous boundaries refuse. Reporting
edits outside those sections may change the document digest without changing permission.
Changing any normative extract/profile/concordance requires fresh affected qualification.
The profile contains no proof identity and supplies no new authority.

| Partition | Freeze/mutation rule |
| --- | --- |
| Qualified inputs | Retained executable; source/build/compiler/SDK/configuration; permission profile/all normative extracts/concordance; schemas, verifier/runner/native observer/contact collector; complete fixtures/expectations/runtime observations; independently required inventory; complete task/configuration files actually read; verifier interpreter, stdlib and resolved package closure |
| Execution context | Actual OS/build, loaded runtime/tool/image identities, composition/gate selection, argv/environment, working directory and descriptor/fixture bindings; obtain these rather than infer them from source hashes |
| Live authority inputs | Fixed approval register/current accepted revision and actual provisioned receipt/UID/directory identities, checked before reservation; scratch receipts qualify validation only. The live receipt's issuance revision binds unchanged authority; any current correction additionally needs the external correction binding, independent approval and fresh affected qualification, never rewritten receipt bytes |
| Qualification outputs | Original logs, per-coordinate proofs and aggregate verdict, bound to the complete input identities; never hash the aggregate proof into its own inputs |
| Reporting outputs | Prose outside normative extracts, diagrams and promotion references; cannot supply admission facts or change a measured input while inheriting its proof |
| Target outputs | Authoritative attempt header, actual segments/objects and closure; not qualification inputs or authority to acquire again |

Check the declared read set against observed dependencies and reviewed composition.
The observation mechanism and pinned runtime/task closure remain k273 design obligations.
Reading the shared Taskfile makes its whole bytes an input, including global variables,
environment and includes; a recipe-only digest cannot stand in for that read. Unrelated
changes still invalidate such a proof. A frozen separate packaging task is a possible
repair, not selected here. No dynamically resolved Python dependency inherits a source-only
identity. K269 places requalification after the last measured input edit and retains a
live owner through later permission/review/provisioning changes.
If a recipe/verifier reads a reporting document, it becomes an input. Finish all
reconciliation and executable/schema/fixture/task edits before measurement. Afterwards
write proof references only in reporting outputs. Review repairs require requalification;
neither reconciliation nor writing a proof into a pinned document inherits the old run.

## Authoritative attempt evidence

[Admission → Bind one permission to one durable start](../design/architecture/index.html#diagram-native-reference-admission)
shows the proposed permit-consumption and original/derivative lifecycle. One fixed independently owned
local subject must bind the stable identity
`koine.reference-evidence.macos-27.0.1-26A434.1` to an explicit authorization receipt.
A document digest or export name creates no successor. K270's
[canonical delegated choices](application-population-metadata-shape.md#authority-and-admission-choices)
select the exact absolute location in the independent KoineReferenceEvidence namespace,
one explicit initialization, cooperative limits and the approval/correction authority.
Koine's product-data directory is excluded because its documented zap owns that lifecycle.
Actual UID, held directory/ancestor identities and receipt remain unprovisioned; a selected
pathname is neither an identity observation nor an admissible receipt.

Packaging accepts only an export destination; it cannot select an authority subject
or mint permission. All original attempt evidence belongs to the fixed subject; an
export is an independently verified immutable derivative. The receipt must bind actual
location/UID, checked directory/ancestor identities, permission and one-attempt authority.
The [independent approval root](#independent-approval-root) specifies the external
proof/inventory/verifier bindings and anti-substitution protocol. The existing independent whole-design
review/earned integration may approve scope-preserving revisions under the delegation;
the producer cannot approve itself. Qualified provisioning and independent validation
must bind those actual accepted revisions outside regenerated proofs/restorable checkout.
Corrections require independent review/integration and fresh affected qualification;
they never replenish consumed authority. Broader scope, new privilege or a new attempt
requires a new explicit human decision.

**Requirements are settled; actual admission remains unavailable.** K274/k275 specify the
lifecycle and approval protocol for whole-k273 review. No authority directory, receipt,
approval register, approved binding, executable protocol or scratch qualification exists.
K276 must complete the full unprivileged contact boundary and k277 the exact shared
entry/read closure; k278 reconciles them and schedules whole review before k269. The
qualified initializer and independently implemented validator are k269 construction owners
before k245, with live affected requalification after the last measured change.

### Permit receipt and explicit initialization

The fixed subject has two reserved permit names, `unspent.receipt` and `spent.receipt`,
an immutable authority event `consume.intent`, and one original evidence child, `attempt`.
They are siblings: deleting `attempt` never deletes a permit name or the authority event.
An export is outside this subject and cannot select it.
Only the exact independently validated **unspent** name authorizes consumption. A spent
receipt has the same bytes and held-file identity, but its name grants no permission.
Both names present, neither present, an unreadable name, any `consume.intent` from an earlier
invocation or any unexpected initialization prefix refuses. Packaging never copies a spent receipt back, creates a missing receipt,
scans for a relocated subject or interprets a partial initialization as first use.

The closed receipt contains version, stable one-pass permission identity, initialization
nonce, exact absolute subject and actual UID, held subject/ancestor and receipt-file
identities, permission-profile identity, approved anchor revision, and synchronization
contract identity. File identities include device/inode/type and available creation stamps;
controlled authority directories are UID-owned mode 0700 and regular receipt files 0600,
with no symlink or extra hard link. Ancestor ownership/modes are independently validated
against their actual approved observations, not assumed to equal the user's UID. Receipt
bytes never contain their own digest or a qualification-output digest. The separately
anchored validation record must bind their exact bytes and actual file identity; matching
producer-generated hashes cannot supply that record. K275 owns its independent trust root,
correction channel and non-circular approval/provisioning bindings.

Provisioning is a separate explicit one-initialization operation under that approved
channel. It cannot be invoked by packaging or a pure selector. It exclusively creates the
selected subject and staged receipt, records actual identities, and requests independent
validation of the complete closed receipt and selected approval revision. Existing subject,
staged prefix, missing approval or uncertain prior initialization refuses; there is no
automatic recovery/recreation. The validator must establish the proposed final unspent
role and publish its externally anchored binding before the initializer exposes that name.
Exclusive same-directory publication preserves the staged receipt's checked inode. Then
the initializer performs the synchronization sequence below and the validator independently
reopens/rechecks the final named-versus-held subject/receipt and records acknowledgements.
Packaging requires that final validation record, so death between publication and validation
does not admit. No initialization record supplies target evidence. A failed/uncertain
initialization needs explicit new human authority, even if no target was contacted.

### Admission, consumption and original start

The lifecycle owns these transitions; k277 must map them to the actual retained packaging
entry and k276 must independently establish the required contact boundary. They cannot be
credited merely from this specification.

1. Parse the fixed packaging interface and validate the invocation-bound independent
   qualification result, approved bindings, exact build/UID and all required identities.
   Perform only approved preflight reads; never start source/index/content work here.
   No proof or receipt supplied by the export can replace a required binding.
2. Resolve and reserve the **fresh export** before consumption as described below. Any
   preflight failure leaves authority unspent and this invocation ends without acquisition.
3. Open the fixed subject and `unspent.receipt` through held no-follow components, validate
   the independent final binding and closed bytes, and take `flock(LOCK_EX | LOCK_NB)` on
   that receipt's held descriptor. Busy/error refuses rather than waits or retries. Recheck
   every named/held authority identity, the entire receipt, absence of `spent.receipt`,
   `consume.intent` and `attempt` after obtaining the lock. A caller which opened the old name before
   a rival's rename cannot use its still-live descriptor to evade that recheck.
4. Begin the irreversible transition by exclusively creating `consume.intent`, an authority
   event binding receipt/approval, invocation, export and proof/input/image identities.
   Check complete writes and synchronize it and its parent. Even an empty/partial event
   prevents a later caller from treating the original unspent name as fresh authority.
   It is retained permission-consumption evidence, never disposable attempt/export state.
   Then consume with `renameatx_np(subjectFD, "unspent.receipt", subjectFD, "spent.receipt",
   RENAME_EXCL)`. Both arguments are fixed single components in the same held directory;
   destination replacement, copy/unlink fallback, cross-device move and swapping are
   forbidden. Success completes the permit-name transition. Recheck that the unspent
   name is absent and the spent name is the same held receipt with unchanged bytes and
   approved ancestry. Perform the required namespace/full-synchronization acknowledgements.
   Any ambiguous return, failed check or acknowledgement ends without contact; never
   remove the intent or rename back. A successful rename consumes even if all later work is unperformed.
5. Exclusively create `attempt` and its immutable start header using held relative
   operations. The header binds the stable permit/initialization/approval identities,
   spent-receipt and consume-intent identities/digests, invocation nonce, export reservation, exact qualification
   proof/input/image identities, declared source phases and synchronization observations.
   Preserve a short header/prefix on failure; only a complete independently checked and
   synchronized header is a start eligible for contact. Recheck authority/export named
   identities and invocation inputs before release. This does not refund a consumed permit.
6. Release only the declared initial source, acquisitions and closure protocol. Hold the
   receipt lock/authority handles through final original closure and export disposition;
   do not pass their descriptors to source children. Close-on-exec plus explicit spawn
   descriptor actions prevent inherited lock ownership. Record every actual source child
   termination/reap and later unperformed phase. Lock release after death changes no
   namespace fact and cannot permit another attempt.

Once intent creation begins, any failure/death is conservatively consumed or uncertain
authority, even with an unchanged unspent receipt and no query. A failed rename cannot
erase the intent and return to preflight; ambiguous intent creation also refuses without
automatic retry. A later fresh invocation may use only independently validated unspent
authority with no consumption event or attempted transition; it cannot repair uncertainty
by deleting evidence. An already spent or partial attempt is permanently non-acquiring,
including death before the first query. Offline inspection and derivative recovery may
read retained originals only. Lost intent before permit rename is detected where its
retained event/validation evidence exists; deliberate deletion of that authority event
and undetectable restoration is the cooperative authority-tamper limit, never ordinary
attempt/export cleanup. No target contact was eligible before the completed permit rename.

### Persistence operations and their evidence limits

Use exclusive `mkdirat` and `openat(O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC)` for new
evidence, complete checked write loops, exact EOF/length/digest validation and held-file
identity checks. Positive short writes advance only by the actual count; zero/error stops
and preserves the extent. No failed flush, rename or acquisition is retried by default.

For each published regular receipt/intent/header/object/segment: finish writes, check its bytes,
call `fcntl(fd, F_FULLFSYNC)` and require success. For each namespace mutation: require
`fsync` on every affected held parent directory, then `F_FULLFSYNC` on a held regular file
on that same device, and recheck the changed names/held identities. For permit consumption
that regular file is the spent receipt. For subject/attempt/export creation and later
publication it is their checked receipt/header/object. Initializer also synchronizes each
created ancestor's parent in creation order; it never treats a directory close as flush.
Keep raw return/errno, descriptor/device association and operation order in evidence.

The selected assumption is explicit: the local filesystem supports these operations,
directory synchronization covers the specified namespace mutation, and the following
same-device full flush orders it before release. Pin the actual filesystem/device
description and independently reviewed API/source basis; scratch successes alone cannot
establish that assumption. Unknown support/basis, a failed acknowledgement, changed device
or unavailable identity keeps admission unavailable. No network/cloud/removable substitute
or fallback to plain fsync is selected. Current APFS support and namespace semantics
remain an actual provisioning/qualification obligation, not a fact established here.

Apple's archived [fsync manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fsync.2.html)
describes host flushing and the power-loss/reordering gap; its
[fcntl manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html)
describes a device-cache flush request and hardware limits. Neither supplies a current
APFS directory-crash certificate. Apple's pinned
[rename manual source](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/man/man2/rename.2)
states descriptor-relative rename and exclusive-destination semantics on supporting
filesystems; it is an API/source basis, not evidence of the reference kernel. The archived
[flock manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/flock.2.html)
supports cooperative nonblocking exclusion and warns about inherited lock references.

Scratch controls demonstrate actual API acknowledgements, ordering, exclusions and
**process-death retention** on their frozen filesystem. They never demonstrate OS-crash,
kernel-panic or power-loss persistence. The k270-accepted bounded namespace/full-flush
assumption and unobserved storage/hardware failure remain limits, not a universal at-most-
one-across-power-loss claim. Unsupported required semantics receive precise live work
before k245; no VM, root collector or strengthened store is authorized by that gap.

### Export preflight and verified derivative

Require a literal fresh destination under an existing checked, UID-owned local directory;
reject symlink/replaced parents, protected or unsettled-consent locations, and any overlap
with the authority subject, Koine product data or an installed acquisition root. Validation
walks only the proposed output ancestry, not source roots. No arbitrary scope argument is
accepted. `mkdirat` reserves the final component exclusively before permit consumption;
existing output of any kind refuses. Create an exclusive export reservation record binding
the held export/parent identities, invocation and proposed fixed authority, check exact
writes and the required synchronization acknowledgements. Failure to establish a usable
reservation ends before consumption and retains any created prefix; packaging neither
overwrites nor silently deletes it. This tests present writeability, not future capacity.
Two callers requesting the same export cannot both reserve it; different exports still
share the single permit. A losing caller may leave its unconsumed reservation evidence.

Original source streams, segments, objects, prefixes and final closure belong only to the
fixed `attempt` child. After final original freeze, a separately owned offline derivation
operation copies the exact enumerated originals into the reserved export through held
no-follow descriptors. It performs no source query, target reread, native conversion or
role inference. Use new regular files and exact bytes, not hard links; retain every
original record coordinate and original-to-export object/record mapping. The independent
verifier checks the closed schema, the complete sets in both directions, exact lengths/
digests/bytes, all logical associations and before/after original/tool identities. A
schema-valid export with reassigned equal-size objects fails association verification.
Publish its immutable derivative closure only after those checks and synchronization.

A failed/interrupted original can yield only an explicitly incomplete derivative, with
the same missing/prefix/unperformed outcomes. Derivation failure retains original and
export prefixes and gives no verified-export claim; no failure removes or reconstructs
the permit. A later explicit offline derivation may use a different fresh destination
only against frozen retained originals, without an acquisition/resume channel. If the
original has been deleted/moved/unreadable, report the precise lost evidence; an export
cannot certify its own association or admit reacquisition. K245 names the original attempt
identity and independently verified derivative, and k246 consumes those exact coordinates
and explicit missing work. Original-to-generated rewrites remain k246's separate oracle.

### Refusal states and required pure controls

| Observed boundary | Allowed disposition / control |
| --- | --- |
| Invalid/existing export; failed preflight writes | No consumption/contact; retain prefix and require a different fresh destination for any later explicit invocation |
| Partial initialization, lost approval, replaced subject/receipt/ancestor or both permit names | Refuse without initialization/reset; pure replacement and short-write controls identify the exact check |
| Concurrent callers, including a held old unspent descriptor | One successful rename at most; others fail lock/name checks before emitter release |
| Death before intent, during intent/rename, after each flush and during start-header write | Pre-intent preflight leaves unspent authority; retained partial intent or successful rename prevents admission; emitter release needs all acknowledgements; no OS-crash evidence |
| Deleted/moved/partial original attempt or deleted/moved/unreadable export after consumption | Unspent name still absent; no second emitter contact with the unchanged permit bytes |
| Failed/unsupported directory/full flush, unknown device or ambiguous rename | No contact or fallback; preserve actual returns/extent and exact unavailable work; no refund |
| Child inherits/unlocks receipt descriptor; named-versus-held replacement during release | Qualification rejects the enabling point/identity failure; no claim that advisory locking prevents a hostile user |
| Complete or explicitly incomplete original → derivative | Exact per-object/record/association comparison passes; missing/swapped/extra/reordered-coordinate or forged complete outcome fails independently |

These controls join the whole required independent inventory and are unexecuted. They
require actual scratch syscall acknowledgements and independent contact evidence, rather
than a wrapper success flag. Receipt/approval/channel substitution controls additionally
consume k275; complete no-contact credit additionally consumes k276/k277. None of this
partial lifecycle supplies complete instrument admission.

Cooperative enforcement accepts deliberate permit restoration, forged approval/identities,
undetectable whole-authority rollback or tool bypass by the same user/admin as limits.
Detected changes refuse. Ordinary deletion of `attempt` or exports is explicitly covered
and never treated as that exception. Export scans and attempt-only exclusive creation
were rejected because cleanup readmits; a mutable receipt-state overwrite adds torn-state
recovery complexity. Immutable bytes plus destructive name consumption gives one simple
transition at the cost of conservatively losing unused authority after pre-query death.
A stronger monotonic/tamper-resistant store or another attempt needs new human authority.

## Independent approval root

[Approval → Anchor requirements before accepting proofs](../design/architecture/index.html#diagram-native-reference-proof)
shows the trust flow. This is k275's design proposal, subject to whole-k273 review.
No root, accepted revision, receipt or admission channel is provisioned or qualified.

### Register, bootstrap and approval ownership

Select the fixed independent register
`/Users/antony/Library/Application Support/KoineReferenceEvidence/approvals/koine.reference-evidence.macos-27.0.1-26A434.1`.
It is a sibling namespace of `permissions`, outside the permit subject, checkout, proofs,
exports and Koine product data. Controlled directories are actual-UID-owned 0700; records
are exclusive, no-follow, single-link regular files, 0600. Retain checked ancestor/register
identities, not a pathname inference. Register publication uses the lifecycle's checked
writes, namespace/full-flush acknowledgements and bounded assumptions. Unknown support or
partial publication refuses. No argument, environment variable, proof or repository file
selects the register. Its fixed retained bootstrap checker is the admission entry; tasks
can request admission but cannot select another checker or issue approval.

The register retains `bootstrap.accepted`, immutable numbered revision directories,
independent verifier-control acceptance and receipt-validation records. These are authority
evidence, never a reusable qualification flag. Missing root/checker refuses without scan,
initialization or recovery. The checker/registrar's exact artifacts, source/build inputs,
interpreter/stdlib/packages, loader images and observed read closure are bootstrap inputs.

**Independent commissioning is the terminal trust act.** After whole-k273 review/integration
selects the protocol, k269 assigns a separate bootstrap review/registration session,
independent of capture, inventory, verifier and launcher producers. It examines the actual
retained checker/registrar/runtime artifacts against separately authored small known-answer
controls and accepted normative extracts. It acquires original control results itself,
records its source review, then explicitly commissions those artifacts and the fixed root.
The design approves a protocol, not unbuilt identities. Candidate-verifier self-evidence
cannot supply this terminal acceptance; unavailable independent results prevent bootstrap.

An independent reviewer opens a fresh private descriptor channel to the separately owned
registrar and directly accepts exact frozen anchor payload bytes. Producer-supplied review
text, an `--approved` flag, an environment run ID or a matching checkout commit supplies
no acceptance. If findings need integration, the independent integration session supplies
every disposition and the final payload binding over its own registrar channel. Substantive
changes outside the reviewed material need further independent review; a clean review needs
no invented integration. The registrar retains complete reviewed payload bytes, review/run
and source-commit identities, original findings/dispositions, final-byte comparison, scope
and producer/reviewer separation. Skipped review, unresolved findings or changed final
payload has no accepted entry. Whole-design review alone cannot approve future binaries;
actual artifact review/acceptance belongs before final qualification and receipt validation.

Each approval channel is opened explicitly by that independent session, never by the capture
or qualification command, with no reusable bearer file or public socket. Role separation
is cooperative workflow ownership evidenced by those direct records, not OS isolation
between same-UID processes. Deliberate external-register forgery, terminal-checker bypass
or undetectable whole-register rollback by the user/admin retains k270's tamper limit.
Producer-only regenerated files, checkout restoration and ordinary proof/export cleanup
remain covered refusals. No key, privileged service, administrator, new consent or secure
monotonic store is selected; stronger hostile-user protection needs a new human decision.

Compared with producer-local hashes, this external register gives review and required-set
selection separate owners, at the cost of explicit commissioning/correction and conservative
refusal on lost authority. Signing regenerated proof files alone would not establish who
approved their scope; a protected key/privileged monotonic service would add an unselected
trust/privilege arrangement. Revisit this choice only if cooperative enforcement is no
longer acceptable, through a new human decision, never a silent stronger store.

Commissioning exclusively creates the register/staged artifacts and retains a bootstrap
intent. Independent final validation binds actual UID/ancestor/register identities, earlier
finalized artifact/control bytes and acknowledgements in `bootstrap.accepted`. That record
contains no identity/digest of itself: its independently accepted bytes are the terminal
trust input read by the commissioned checker. There is no self-hash proof of that root.
Partial, absent, replaced or uncertain commissioning cannot be resumed or relabelled first
use by packaging. It needs exact live repair and explicit new human authority where prior
initialization is uncertain. It grants no second permit initialization or target contact.

### Closed payloads and acyclic receipt bindings

Proposed register version is `koine.application-reference-approval/1`. All records reject
unknown/missing fields, duplicate members, ambiguous references and lossy encodings. Retain
complete bytes and exact lengths/digests; counts and aggregate verdicts replace no membership.

| Record | Closed binding and independent origin |
| --- | --- |
| Bootstrap acceptance | Stable permission/register identity; actual UID/ancestors/register; checker/registrar/runtime/input identities; independent review, control inventory, original results and acknowledgements |
| Revision payload | Ordinal and predecessor acceptance digest (none for first); stable permission; all normative extracts/locators, expected profile/concordance, complete applicability inventory/reasons, envelope/proof/approval/channel schemas, independent fixtures/expectations/bases, verifier/launcher/coordinator/gate/observer identities, actual task/runtime/read closure and scratch/live domain rules |
| Revision acceptance | Exact earlier payload bytes/digest/held identity; predecessor; directly registered independent review and earned integration/final-byte binding; issuer/channel context and acknowledgements |
| Verifier-control acceptance | Earlier accepted revision and exact checker/verifier/launcher/runtime identities; separately authored bootstrap-control inventory and original results; independent adjudication, actual frozen inputs/process/channel/contact evidence and unavailable coordinates |
| Receipt binding | Earlier accepted revision/control acceptance; exact earlier staged receipt bytes/digest/file identity; actual initialization nonce, UID, subject/ancestor identities, proposed unspent role and synchronization basis |
| Final receipt validation | Earlier receipt binding; independent final named/held unspent receipt/subject identity and byte comparison; complete initializer acknowledgements and terminal result |
| Correction binding | Earlier receipt/final-validation identity; newly accepted revision and fresh affected verifier-control acceptance; unchanged authority facts, observed permit/intent/attempt state, exact approved changes and affected qualification requirements |

Required unavailable observer/runtime identities cannot become successful entries. A proposal
with exact unavailable work may be retained for review but has no admission-eligible role.
Order is bootstrap → payload → revision acceptance → independent verifier-control acceptance
→ staged receipt → external receipt binding → unspent publication → final receipt validation.
Qualification results bind earlier payloads; external acceptance binds results afterwards.
No record contains its own digest, a later acceptance digest, or the final proof as a qualified
input. This fills k274's reserved validation interface without altering exclusive initialization
or consumption. Scratch receipts qualify the interface, never authorize live initialization.

The receipt binds its immutable **issuance revision**. Later scope-preserving corrections
require an independently approved external binding from that issuance receipt to the
**current admission revision**, not changed receipt bytes, identity, nonce or grant. Exact
authority facts stay equal: one attempt, location, UID, selected scope, prohibited effects
and persistence limits. New ancestry/replaced receipts cannot be corrections. Changed
technical extracts/inventory/tools need independent semantic review and affected qualification
before eligibility; broader authority goes to Antony. This distinction is the required
k274 external-validation refinement; k278 owns its whole-producer terminology reconciliation.

Under a cooperative register lock, exclusively reserve each next ordinal and retain update
intent before publication. Require a contiguous complete successor chain and its highest
accepted revision. Pending/partial/duplicate successor, missing predecessor, conflicting
binding or unknown version refuses without fallback. Admission holds a shared register lock
through consumption/start checks; corrections need nonblocking exclusive ownership. Pin
every lock's stable held identity. Failed updates retain uncertainty, not rollback/reset.
Detected changes refuse; undetectable whole-authority rollback retains the accepted limit.
A spent name, consume.intent, partial original or missing unspent authority stays permanently
non-acquiring through every correction. Post-consumption corrections have an offline-only
domain: they cannot initialize, remove intent, restore unspent or reacquire.

### Normative extraction and field concordance

Freeze literal UTF-8 bytes, preserving line endings and links; never render or normalize
them. Each reviewed locator names source identity, exact unique heading line/level, start
inclusive and end exclusive at the next heading of the same/higher level, or explicit EOF.
Headings inside fenced code are excluded. Duplicate/missing/moved-level/overlapping/ambiguous
boundaries refuse. The independent extractor compares current sections byte for byte with
the accepted payload. Whole-document digests/offsets are snapshot provenance. Snapshot
every full source before/after extraction; changed bytes invalidate that invocation.

| Actual source | Exact normative boundary and authority |
| --- | --- |
| Canonical population report | `## Selected reference and evidence requirements` through the next level-two heading; includes permission, delegated choices, classification/assignment and test/handoff subsections |
| Descriptor-relative ADR | `# Filesystem access is descriptor-relative` through EOF; owns search-only held kernel resolution, physical dot rules, 32-link budget and its platform/prompt limits |
| This evidence contract | Complete level-two sections listed below, including all nested subsections; owns derived acquisition, representation, qualification and approval guarantees |

Contract sections: Ownership and alternatives; Selected instrument architecture; Proposed
envelope version and verification interface; Permission inputs and reporting outputs;
Authoritative attempt evidence; Independent approval root; Closed qualification proof and
required inventory; Contact observation outside the producer; Fixed composition without
target contact; Independent decoder expectation classes; Topology and the inherited component
rule; Attempt durability and per-control proof; One-pass acquisition and closure; Evidence
records and association keys; Original bytes and complete typed witnesses; Freeze and replay
limits; Independent controls required before target acquisition. Construction/current-result
summaries and Remaining boundary are reporting; no new normative rule lands there. Extending
the source/section set needs independently reviewed acceptance and affected qualification.

Construction must enumerate every leaf field/enum of the following closed profile families.
Each has an exact extract/clause coordinate, independently authored expected value/derivation
and applicable positive/isolating-negative inventory coordinates. Enumerating only producer
constants fails; every clause also maps back to fields or an explicitly reviewed non-profile
obligation/control/owner. Unmapped clauses, invented values or test-learned applicability refuse.

| Profile family | Actual clause sources and comparison |
| --- | --- |
| Reference/cohorts/role/assignment | Canonical selected-reference introduction, Independent classification and whole-template assignment, Test seams and required handoff; exact build/cohorts and downstream independence |
| Source executable/argv/predicate/framing/terminal/phases | Canonical One bounded reference-packaging pass plus contract Fixed source and terminal protocol; exact vector/raw slots/reap/two phases, no closure repair |
| Permit/location/UID/initialization/attempts/approval/correction/persistence/privilege | Canonical Authority and admission choices plus contract authority/approval sections; exact delegated limits and irreversible consumption |
| Scope/root/link/dot/search-only/protected/intermediate | Canonical permission/protected clauses, full ADR and contract Held roots/Topology; exact inherited rules, no invented Data exclusion |
| Layout/advance/base/file/locale/link states | Canonical file permission plus contract Held roots and the closed acquisition plan/One-pass acquisition and closure; exact four layouts, six basenames and full direct inventory |
| Bytes/types/formats/duplicates/candidates/flags/tables/LocProvenance/tails/associations | Canonical evidence clauses plus contract envelope/record/typed/decoder/freeze sections; full preservation or precise unavailable work |
| Effects/failure/no-retry/export/original/freeze/proof/channel | Canonical prohibitions/handoff plus contract lifecycle/approval/qualification/controls; every prohibited effect and applicable control |
| Schemas/inventory/bases/identities/observer/scratch-live composition | Contract approval/proof/contact/composition/expectation sections under canonical seams/privilege; complete membership, independent provenance and explicit unavailable work |

ADR/contract-derived fields cite their actual source, never invented canonical quotations.
Independent review checks semantic coverage/scope preservation; source hashes do not establish
it. Removing a failed required cell or prohibition and regenerating matching proofs cannot
alter the externally accepted inventory/concordance.

Only the commissioned extractor may treat these closed documents as section inputs. Current
full raw snapshots are invocation evidence; qualified semantic inputs are exact extracts,
locators and extractor identity. Reporting edits outside them pass only through independently
qualified reporting-mutation controls preserving every extract/boundary. Other actual reads,
including tasks/global configuration and Python runtime/packages, require full-byte identity
under k277. Reading reporting for another purpose makes those actual bytes a qualified input.
No arbitrary semantic slicing, unobserved dependency or per-recipe hash inherits this exception.
Proof references belong outside the selected extracts, avoiding a proof inserted into its
own input; snapshot provenance still records reporting changes.

### Invocation channel and verifier-self qualification

The external checker validates the terminal root, highest accepted revision, original
independently adjudicated verifier controls and actual held artifacts. It launches the exact
pinned admission verifier, not an image selected by supplied proofs. Compare interpreter/
runtime/read inputs and require actual launched-process/image correspondence through the
independent mechanism k276/k277 must qualify. A pathname digest before exec supplies no such
proof. Unavailable correspondence refuses; no target launch is a calibration.

Select a new unnamed `socketpair(AF_UNIX, SOCK_STREAM, 0)` for each checker/verifier and
checker/coordinator connection. Apple's archived [socketpair manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/socketpair.2.html)
documents connected unnamed descriptors, not current image authentication. Explicit spawn
descriptor actions pass only the intended endpoint and held inputs; close other endpoints
and set close-on-exec elsewhere. No approval/permit descriptor reaches source children.
No pathname socket, network listener, environment secret or saved success token is accepted.
Peer identity is the independently observed spawned process plus exclusive endpoint ownership,
not a PID in a message.

The external checker supervises both the short-lived verifier and the acquisition
coordinator. It owns the shared register lock until the coordinator's true terminal
return. The coordinator independently checks that supervisor's observed incarnation
before consumption/release; supervisor loss freezes admission without restoring authority.
Normal zero reap before admission applies to the verifier child, never to the still-live
supervisor or coordinator. This avoids waiting for a coordinator to exit before it can act.

The checker obtains a fresh 256-bit nonce with `SecRandomCopyBytes(kSecRandomDefault, 32, ...)`;
non-success refuses. Apple's [random-byte API](https://developer.apple.com/documentation/security/secrandomcopybytes(_:_:_:))
is the selected basis; its actual Security/runtime images and use still need qualification.
Closed versioned length-framed messages carry exact checked length,
kind, sequence and nonce. The challenge binds SCRATCH/LIVE domain, parent/child process
incarnations, accepted revision/control acceptance, permission/extract/concordance/inventory/
proof-object sets, held tool/read/image identities and proposed export/receipt binding.
Exactly one verdict answers that challenge, then the writer closes its write direction.
Require complete frame, no trailing/second frame and read EOF; the checker additionally
requires normal zero verifier-child reap. A checker-to-coordinator endpoint remains open
for coordinator acknowledgement/terminal reporting in the reverse direction, while the
supervisor stays alive with the register lock. Compare every binding independently.
Missing/delayed return, death, unexpected writer or malformed/mismatched bytes refuses.
Construction freezes finite framing/time limits and failure controls; no production quota
changes follow. The result cannot be replayed as a future qualification token.

The checker forwards its recomputed result over a separate coordinator channel. The
coordinator compares held inputs, uses that result once in memory and rechecks root/revision/
images, live receipt and reserved export before consume.intent and before contact release.
SCRATCH cannot become LIVE; fixture authority never admits the live subject. Later checks
retain the binding without retrying acquisition. Leaked/reused endpoints, fork/exec inheritance,
substituted verifier, changed inputs, copied verdict, cross-invocation nonce or cross-domain
result refuses. Full independent no-contact evidence remains k276/k277 work, not socketpair's
guarantee. The exact packaging entry/domain selector belongs to k277; these channels cannot
secretly add a second packaging interface.

The candidate verifier cannot adjudicate its own bootstrap controls. A separately owned
adjudicator runs exact retained checker/verifier/launcher artifacts against separately authored
complete proofs and schema-valid omissions, weakened applicability, swapped images/runtime,
false passes and replay/channel/death specimens. It records actual response bytes and
process/contact outcomes, including the intended reached check. Independent review registers
those original results; the terminal checker requires their accepted exact inventory/identities.
Candidate-produced proof or copied output cannot replace that acceptance. Shared OS/runtime
dependencies are pinned assumptions, not an independent OS implementation. Unavailable controls
or disagreement has no accepted live role. Changed checker/verifier/channel/closure needs fresh
independent review/control acquisition and all affected qualification.

### Required anchor controls and handoff

Required unexecuted controls pair complete acceptance with each isolating counterexample:
matching weakened proof/inventory; changed/ambiguous extracts/concordance; omitted prohibitions/
cells; copied review/skipped integration; swapped root/payload/checker/verifier/runtime;
pending/old revision; forged self-evidence; partial provisioning/final binding; wrong UID/
ancestor/receipt; channel leak/replay/extra frame/cross-domain/death; and corrections after
intent/spending. Reporting-only edits and valid scope-preserving corrections are positives,
with unchanged receipt bytes and no restored authority. Retain exact refusal coordinates
and independent contact evidence; none of these specified controls is an approval record.

K269 assigns separate construction owners for checker/registrar/strict extractor, independent
inventory/profile/concordance/schema authoring, bootstrap-control adjudication, reviewed
revision registration, qualified initializer, actual receipt validation and corrections.
Exact artifacts receive independent implementation review/integration before acceptance.
After final contract/task/runtime edits, place affected requalification, independent acceptance
and closing audit before k245; keep live repair/requalification ownership for later input
changes. Actual receipt binding follows qualified initialization mechanics/control evidence.
K278 reconciles the whole protocol before mandatory review. K275 cuts no construction leaves.
K276 owns realizable full unprivileged contact observation or precise unavailable work;
k277 owns exact entry/observed runtime reads. Until every required identity/control qualifies,
admission remains unavailable, k244/k242 live and k245's pass unused.

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
| subject | Proof/schema/inventory versions/digest; external bootstrap/current accepted revision/verifier-control identities; full permission/extract/concordance/read-set identities; actual retained executable and OS/runtime/image identities; pure composition |
| run | Unique coordinate, task/command/edge, actual before/after input identities, interval, process tree, channel nonce/domain/process/frame/EOF/reap observations, immutable original result/contact objects and performed/unperformed work |
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
The [external approval register](#independent-approval-root) binds the reviewed inventory,
normative extracts, expected profile/concordance and verifier/launcher/runtime identities
before the proof set is produced. Its separate receipt/correction bindings fill the selected
approval interface; actual registration/validation and complete k273 review remain due.
A digest agreeing only
with its own regenerated proof is insufficient; weakening a failed required cell or
substituting a self-certifying verifier must refuse under independently reviewed anchors.
Schema extensions update validator/oracle/fixtures/inventory and rerun/freeze all affected
earlier stages. Old proofs retain their old scope; they cannot admit the extension.

The independent offline verifier has a strict admission entry. The qualification runner
invokes it after stage results; the fixed external checker launches its pinned image on retained
artifacts before the coordinator may persist a start. It derives required coordinates from
the independent inventory, recomputes objects/results/pair outcomes, checks sets in both
directions, provenance/contact coverage and actual input/image/permission equality. One
schema-valid omitted case, ambiguous duplicate, stale runtime result, regression-only
independent expectation, unavailable observer or changed input refuses before contact.

Follow the [invocation-channel contract](#invocation-channel-and-verifier-self-qualification):
external accepted verifier-control evidence precedes candidate admission, and the pinned
checker/verifier/coordinator use separate fresh unnamed descriptor channels. Bind nonce,
SCRATCH/LIVE domain, process ownership, proof/inventory/permission/read-set/revision identities
and held inputs; require complete framing, EOF/reap and one-time in-memory use. Substitute,
replay, channel failure or unavailable actual image identity refuses. Final checks remain
required; this is no hostile-user immutability guarantee. The verifier cannot judge its own
terminal commissioning/control acceptance, and candidate success output cannot mint approval.

## Contact observation outside the producer

External Darwin DTrace syscall-entry/return and process-lifecycle collection remains an
**unqualified partial candidate**, not a complete no-contact proof. The installed manual
and [Apple's SIP description](https://support.apple.com/guide/security/system-integrity-protection-secb7ea06b49/web)
establish no current access/coverage. No collector command, probe discovery or privilege
change is authorized in this design integration.

The required contact boundary includes source/index requests and installed filesystem
access through IPC/Mach/XPC or daemon proxies, not only mdfind exec and pathname syscalls
in the scratch child tree. A gate sees only submitted intents; a bypassed in-process
framework request cannot be cleared by an empty syscall/path trace. K273 must select a
realizable independent observation/containment arrangement for the whole boundary or
retain admission unavailable. Wrapper logs, interposition, mocks and static inspection
cannot replace independently observed bypass controls.

Define required contact classes independently from a pinned kernel/probe/API inventory,
not from primitives the producer happens to reach. Include pathname/identity lookup and
open, listings/attributes, alternate/noncancel syscall routes, inherited-descriptor reads
and mapping, and source/filesystem IPC or proxy effects. Enumerate applicability and
per-class scratch bypass/loss controls before comparing the producer. One sentinel does
not establish coverage of the class it did not exercise.

The candidate must independently demonstrate readiness before child release, process-
incarnation/descendant/thread coverage through spawn/exec/reap, entry/return/error and raw
operands, descriptor creation/dup/inheritance/close and directory associations. Pin all
collector/script/kernel/probe/image inputs and retain original events. Unknown associations,
truncation, loss, attach gaps or missing termination make the coordinate unavailable.
Direct scratch bypass outside all wrappers, child/pipe bypass, inherited-descriptor contact,
wrong filters, disabled collection and induced loss must fail at their intended contact
coordinate, with allowed scratch positives too. No installed-query/root positive is pure.

K270 selects unprivileged pure scope at the user's UID: no root/sudo collector is
authorized and no privileged supplier is appointed. Complete observation remains
unavailable until a realizable unprivileged full boundary independently qualifies.
K273 owns that design or its exact live unavailable work before the first consumer;
any stronger privilege/posture alternative needs a concrete new human decision.
K269 assigns actual authorized capability/calibration before any
real-adapter credit. Replacement needs reviewed design and independently qualified full
contact coverage. No target experiment, new consent or posture change follows from a gap.

## Fixed composition without target contact

[Approval → Anchor requirements before accepting proofs](../design/architecture/index.html#diagram-native-reference-proof)
shows external acceptance before required rehearsal and admission. The rehearsal's exact
enabling point remains k277 work. The same retained executable,
fixed packaging parser/constants, admission, coordinator and real adapters must be credited.
Packaging accepts only a fresh export; it cannot accept arbitrary source/scope/file/language
or adapter choices. K273 must name exactly how sealed scratch qualification reaches the
actual Taskfile/script/parser/composition entry and how live execution rejects that channel.
A separate internal entry cannot credit segments it never reaches; an ambient selector is
an interface that needs explicit live refusal, identity and miswiring controls.

Required rehearsal compares exact fixed intents with independent expectations and maps only
declared fixture identities to scratch descriptors/emitter. Unmapped intents refuse.
Logical /System paths are values, never installed probes. Intent evidence and actual mapped
scratch pipe/descriptor/decoder observations remain separate. Fixture authority/receipt
cannot authorize live contact. The exact fixed-location derivation, UID/receipt discovery,
export preflight and installed-build-check path also need credited shared logic and an
explicit operation/mapping contract. K273 names executed, mapped and unexercised segments;
a fixture location cannot qualify live derivation by itself, nor an installed /System read
serve as a pure positive. Any required unexercised segment leaves admission unavailable.

Every intended native operation must reach the contact gate; the complete independent
boundary above must expose bypass, including IPC/proxy routes. Actual Taskfile/script edges,
pure-to-packaging miswiring, live intents, changed constants, omitted preflight, reused/forged
admission and channel/gate/verifier death need isolating scratch controls. They refuse before
source/index/installed-contents contact, with complete independent evidence rather than a
clean producer log or syscall-only trace. Direct scratch bypass is the observer control,
never a target positive. Mutated copies are separate frozen subjects; final qualification
measures the unchanged retained candidate. Changed actual read inputs invalidate proofs.

These are required design/qualification obligations, not an OS sandbox or an implemented
selector. K273's whole review must establish that the exact packaging path is exercised and
scratch context cannot mint live authority. K269 supplies owners only after that review and
integration. The one target pass cannot be the first wiring/privilege/location experiment.

## Independent decoder expectation classes

| Class | Establishment | Admissible claim |
| --- | --- | --- |
| Format/source-derived | Separately authored bytes with a named specification or explicitly bounded implementation/source basis for each expectation | Original positions and only values/validity supported by that basis; no implicit normative binary/OpenStep/strings/loctable grammar |
| Runtime-corroborated | Separately authored narrow CF observation programme acquires facts directly from pure bytes on pinned OS/loaded images before producer comparison | That image's acceptance/error/format, stored number type, duplicate survivor, coercion, date/real bits and enumeration |
| Regression-only | Expectation first learned from producer output and later frozen | Change detection; cannot close a required independent coordinate |

Author XML/OpenStep encodings and binary object tables/trailers/offsets independently,
not exclusively through CF or normalizing serializers. Inspect serialized duplicate
positions even when CF returns one member. Format inspection cannot predict undocumented
CF rejection or certify preservation of lexical order, stored width or NaN payloads.
Every expectation cites its primary basis and scope. An XML specification supports its
defined grammar; authored binary/OpenStep/.strings/.loctable bytes alone establish none.
Historical implementation-derived facts keep that label and cannot certify the loaded CF
runtime. Without a supported basis, validity/type remains unavailable while bytes/positions
are preserved. Current acceptance/storage/duplicate/coercion requires the separate pinned
runtime programme, even when a historical implementation informed specimen construction.

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
three prefixes on **both** literal and walk-resolved components, with the canonical
[protected/intermediate-contact clauses](application-population-metadata-shape.md#authority-and-admission-choices).
It is not a sealed-System rule or device allowlist. /System/Volumes/Data remains under
/System; no blanket Data exclusion, spelling rewrite or vendor-based outside exception
is selected. Protected-user listing/contents and unsettled consent-risk contact are
unavailable. Tool-controlled out-and-back expansion must refuse before outside lookup/
open; held common ancestors may be used only to enter an admitted prefix. This evidence
permission does not change the production ADR's kernel-semantics decision.

| Independently authored pure specimen | Required result |
| --- | --- |
| /Applications-extra/A.app; relative/uncheckable bytes | Reject literal scope before contents; preserve raw reason |
| /Applications/A.app expanding to /Users/u/A.app | Reject resolved scope, with no root listing/contents |
| /Applications/A.app expanding to /System/Volumes/Data/Applications/A.app | Both prefixes pass; preserve spellings/checked identity, with no sealed-volume claim |
| /System/Volumes/Data/private/Specimen.app | Syntactic scope passes; no invented Data exclusion or consent authority; known/unsettled consent-risk contents refuse before listing/content handles |
| /System/Volumes/Data/Users/u/{Desktop,Documents,Downloads}/X.app, directly or via an admitted link | Preserve prefix calculation/raw slot; protected-user listing/contents refuse before contact, without a prompt or missing-copy omission |
| An admitted link expands outside all prefixes then returns inside | Retain observed link text; refuse before the first tool-controlled outside lookup/open, even if the proposed final spelling is inside; no lexical cleanup hides it |
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
The inherited prefix spelling is not authority to request new consent. K270's delegated
canonical amendment selects protected-content and outside-intermediate refusal, preserving
all raw observations and precise required missing work. Unknown no-consent handling remains
unavailable; no target probe, hidden-contact guarantee or useful-category loss follows.

## Attempt durability and per-control proof

Before target spawn, follow the [authority lifecycle](#admission-consumption-and-original-start):
validate/reserve the export, retain consumption intent, rename the fixed permit to its
spent name, then persist the exclusive original attempt header and all required
acknowledgements. Attempt creation alone cannot consume a reusable receipt. Finalized
objects/observation segments are write-once; retain unfinished temporary segments
and actual prefix extents after
interruption. Record segments belong to the evidence envelope, not a separate
session-status file. The final closure commits only after input freeze and all
item comparisons; the offline verifier never manufactures missing observations.
Unexpected death without a complete closure is interrupted/incomplete even if
some objects are intact. Failure to preserve a record is itself missing evidence.
Existing output, prior consumption intent/spent permit/reservation or an uncertain authority subject refuses
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
specimens. Review k271 found substantive gaps; the sections above expose required repair,
not a complete admission handoff. Human requirements k270 now precede the instrument node;
replacement design node k273 and its mandatory whole review/earned integration precede k269.
Its children independently own authority lifecycle k274, admission roots k275, complete
contact boundary k276, exact entry/runtime closure k277 and whole reconciliation k278.
The lifecycle/anchor proposals do not close contact/entry obligations or admit construction.
The authority requirements are selected in k270; actual receipt/provisioning, independent
approval anchors and full unprivileged external contact capability remain unavailable
prerequisites;
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
K269 must also assign qualified receipt provisioning/independent validation before k245,
export derivation/verification, and live requalification after any changed admission input.
K270's canonical delegated choices precede construction design/qualification, not only
target packaging; the interview produces no receipt. K269 owns the construction slices.

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
export destination. K273 must resolve the exact scratch-entry/live-channel refusal design;
ordinary tests have no live packaging dependency. Packaging checks the exact installed macOS 27.0.1 (26A434)
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

The [export lifecycle](#export-preflight-and-verified-derivative) now specifies invalid-export
refusal before consumption, concurrent exclusive reservation, retained interrupted prefixes
and complete original/derivative verification. It remains a proposal for whole-k273 review
and actual construction/qualification; no export can select or reset authority.
K245/k246 consume the original attempt or its independently verified immutable derivative,
with explicit incomplete work; an unassociated export path supplies no package.

After those preflights, the required acquisition order is independent admission, export
reservation, consumption intent and spent-permit transition, synchronized original start; complete initial
source terminal/reap/framing; initial held-root/layout/inventory/file acquisition;
complete closure source and its held-root associations; full item inventory/identity/
byte rereads and comparison; final input/image freeze; final closure publication.
Failure leaves all later unperformed work explicit. Closure never substitutes for
initial source or acquisition, and final publication cannot precede comparison/freeze.

Reserve the unique export before the irreversible authority transition; create the fixed
original attempt only after that transition and synchronize both before source acquisition.
Never overwrite the historical packets or a prior attempt. The attempt envelope
contains actual acquisition observations and interruption/error evidence; it is
not a separate session-status file. Once consumption intent creation begins, an interrupted,
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
The selected protected-content refusal and outside-intermediate refusal additionally
apply, with only search-only held common-ancestor entry into the three prefixes.
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
| Scope/build positives and faults | Admit the exact build and permitted component-bounded checked roots; reject wrong build, /Applications-extra, outside resolved roots/intermediate operations, protected or unsettled consent-risk contents, raced descendants and arbitrary query/file/language settings before forbidden contact |
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
| Deleted/moved attempt entry with otherwise unchanged authority | Authority remains consumed/unavailable; cleanup cannot admit another pass |
| Partial consumption intent, failed exclusive permit rename or death before query | Retain authority event/spent name; unchanged receipt bytes never authorize reset or another emitter |
| Existing/unusable export versus reserved export, complete/incomplete original and offline derivation | Invalid preflight ends before intent; later failures retain consumed authority/originals; every derivative requires independent exact object/association verification |
| Absent/moved/replaced/unreadable authority; partial header; process death before/after flush acknowledgements | Uncertainty refuses; prefixes retained; no initialization/refund; kills cannot qualify OS-crash persistence |
| Complete proof versus schema-valid omitted case/role/negative pair | Required-inventory coordinate identifies omission; proof's own count/list cannot admit |
| Weakened regenerated inventory/concordance or self-certifying substituted verifier | Fixed externally accepted payload and original independent verifier-control acceptance refuse; matching regenerated hashes cannot admit |
| Direct registered review versus copied/skipped review or unresolved final-payload integration | Only the independently opened registrar channel and exact reviewed bytes can publish acceptance; producer text/run IDs supply none |
| Issuance receipt versus scope-preserving current correction, pending/old revision or correction after spending | Accepted external bridge and affected requalification preserve original receipt; partial/old history refuses and no correction restores unspent authority |
| Fresh framed channel versus leaked endpoint, second frame, missing EOF/reap, wrong domain or process binding | Independent external checker/coordinator reject at the intended channel coordinate; required contact evidence cannot come from the candidate |
| Permission profile matches frozen clauses versus one changed scope/effect/file group | Independent concordance/value comparison refuses before start |
| Reporting-only promotion versus changed measured extract/task/tool or proof inserted into an input | First preserves qualification; latter invalidates it and requires a new run |
| Real scratch pipe/descriptor calls versus direct syscall/child bypass with empty wrapper trace | External original trace detects exact contact, even with a clean producer trace |
| Ready complete observer versus drop/filter/attach/operand/identity loss | Relevant contact coordinate unavailable; no clean no-contact verdict |
| Exact retained entry versus pure→packaging/live intent, omitted admission or IPC/proxy bypass | Full independent contact boundary required; syscall-only clean trace is insufficient; exact entry/task/UID/build/location and channel refusal must be credited |
| Independent native observation versus copied producer tree/regression-only expectation | Corroborated pinned CF fact passes; provenance failure cannot close independent runtime coverage |
| Data-volume/mount/firmlink/cryptex/link specimens | Canonical literal/resolved and protected/intermediate refusal results, held common-ancestor entry and honest simulation/identity limits; no topology-derived scope change or hidden-contact certificate |
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
