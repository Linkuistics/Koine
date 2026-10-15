# Private application metadata qualification

## Boundary and reading order

[Qualification → Review, qualify, then release](../design/architecture/index.html#diagram-native-metadata-qualification)
shows the dependency order. Graphs enter at the dark Start here node; numbered
edges show order. [Admission → Reserve each transition through true return](../design/architecture/index.html#diagram-native-metadata-qualification-admission)
shows the job protocol. This is a complete proposed construction for whole-producer
review, not an implemented reader or a native verdict. Useful fit is unestablished;
advertisement and downstream consumption remain held.

The [ordering decision](../adr/application-metadata-qualification-precedes-analytic-fit.md)
permits this private route. The [accounting decision](../adr/application-metadata-accounting-covers-explicit-work.md)
defines its numeric scope. [Reader semantics](../verification/application-metadata-reader-plan.md),
[runtime recipes](application-metadata-runtime-admission.md),
[source/root grammar](application-metadata-source-root.md),
[grouped ownership](../verification/application-metadata-grouped-storage.md#owners-fields-and-requests)
and [complete expressions](../verification/application-metadata-composition.md#complete-expressions)
are parts of this construction, not optional substitutes. The
[current contract](../design/application-metadata-contract.json) ties the set together.

## One owner and a closed transition protocol

The private discovery adapter owns one serial application job: raw staging,
counts, reservations, native owners, two-walk episodes and real ProviderValue
publication. The caller supplies a catalogue request and receives a frozen value
or failure. It does not arrange buffers, inventories or cleanup. One outstanding
native invocation per job and four process-wide slots remain. Every independent
application root in a GraphQL document owns a separate job; nested aliases
complete the same returned tree in the host.

This spec owns the application transition, reservation, freeze and true-return
protocol. The shared ownership/image design adopts it when connecting the supervisor
and independent native images; it defines shared Settings/location integration,
allowlists and concrete enabling points. It cannot silently replace this application
protocol. A material change needs a precise design repair and its review/integration
before affected construction or qualification. Missing actual operands remain
qualification work, not a second owner of the protocol.

Use the existing supervisor's fixed state and scratch-owner records, with
declared raw counter/reservation/state cells; use embedded owner headers and
separately admitted native-owner descriptors. No recursively allocated owner
table or hidden staging collection is permitted. The two immutable inputs, EOF
storage and conversion scratch request 270,368 bytes once; shared supervisor
augmentation remains 616 gross bytes/nine attempts in the saved recipe. These
are partial contributions, not a whole-job fit claim. Counter, pending-owner,
borrower, dependency, cursor and freeze updates after initialization are extra
charged field writes. A native out-parameter written into caller-controlled
storage (status structs, pointer vectors, conversion/read buffers) has its full
declared writable extent reserved before invocation; opaque native backing is
separately disclosed, never confused with that write.

Each explicit event belongs to exactly one tape and receipt partition. Its
transition records: actual stage/ordinal, operands, requested capacity, initialized
and written ranges, explicit invocations/comparisons/accesses/retains/releases,
owners acquired/transferred, possible outputs, dependencies and cleanup upper.
Bulk initialization is one explicit operation plus its actual written bytes;
separately issued field writes and each loop/access/comparison count separately.
The actual compiled adapter's guard arithmetic, checks and raw bookkeeping also
count. Aggregate counter updates are charged as one declared bulk field write,
with their extent included in that transition, rather than recursively invoking
the guard to account for its own counter writes. Reserve the terminal
freeze/cleanup/return bookkeeping and one complete guard evaluation before starting
optional work. A native
return scalar stored in a raw record is a field write; allocation, initialization,
payload population and retirement never collapse into one free assignment.

### Pre-call admission and actual-return settlement

Let S be irrevocably spent gross/attempts, C the reservation for all live-owner,
borrower, pending-output and terminal cleanup, E the complete failure-publication
reservation for the current staged state, W the next transition's controlled
request/write and explicit-operation upper, and D its additional possible-owner
cleanup. Admit only when both components of **S + C + E + W + D** fit the selected
gate, every shared count fits, authority/lifecycle are live and the three-second
job/five-second core deadline permits new work. Equality admits. Checked
addition/multiplication/alignment precede native contact and allocation; arithmetic
overflow or an unknown explicit operand refuses that transition as shared failure.
Count raw slots before classifying/deduplicating them. Existing C is counted once;
moving a close credit transfers it rather than adding or losing it.

C includes a distinct terminal guard credit H: a compiled-recipe upper for one
complete evaluation, including checked arithmetic/comparisons, unknown/count tests,
clock and authority/lifecycle reads, receipt/counter/freeze raw writes and their
explicit operations. Establish and fund H with fixed bootstrap work before source
contact; an unknown H refuses bootstrap. An admitted evaluation spends its actual
guard cost as part of W and keeps H reserved for the next evaluation. The first
refused evaluation spends its actual guard prefix from H, transfers that prefix
to S and freezes; it does not charge unperformed optional W or possible D. Unknown
operands, arithmetic overflow and deadline/lifecycle refusal consume H too. Sticky
freeze performs no further optional admission evaluation. The final successful
return evaluation consumes H rather than charging it again as W; after it no
optional work remains. Fixed failure-delivery/lifecycle checks and cleanup are
separately reserved terminal work in C. Ending unused credit refunds no spent work,
and no guard recursively admits its own bookkeeping. Exact equality includes H;
without it even an otherwise exact transition is inadmissible.

W includes guard and receipt bookkeeping, all known branches of the single
transition and any possible caller-buffer writes. D includes raw retired/pending/
borrower state writes and explicit close/free/release/drain/stop/remove operations.
E includes the real FAILED/null catalogue's strings, wrappers, object/list
initializations, every insertion/append, fixed summaries/permissions/errors and
possible failed-prefix destruction. Derive it with the same publication recipe
below using bounded closed reasons and already admitted diagnostic/scalar lengths;
never copy an arbitrary native error description. Recompute and reserve any
increase in E before acquiring/staging the next observation, including the next
reason bit or diagnostic. A saturated detail list adds only the fixed summary
updates and canonical DIAGNOSTIC_LIMIT guidance; it never discards choices.
Do not spend C or E on useful work. If bootstrap cannot reserve the complete
fixed failure envelope and terminal bookkeeping, perform no source acquisition
and return the existing failed error. Such an error is no successful catalogue
publication and cannot qualify usefulness; the host's error encoding does not
pay for a provider tree.

On actual return, record and charge every request issued (also a failed allocation
request), performed initialization, successful/failed write prefix and explicit
attempt. Acquired-owner cleanup moves from D to C. Unused possible-output/work
reservation may end only when that invocation actually returns; S never decreases.
If a native write/result exceeds its admitted controlled upper, freeze, report a
guard defect and retain failure/holds; this is never a fitting receipt. A nil
allocation leaves the old owner intact. On ordinary success, dispose inputs in
dependency order, transfer only actual cleanup credits and keep all incurred
charges. Reuse and sharing change future requests, never earlier charges.

Unknown whole-job dimensions do not require a fictitious whole-job pre-reservation.
A returned native collection's internal backing is excluded under the accounting
decision; reserve its explicit acquisition and possible release first, then admit
its count/getter before seeing each child. Once the length/type is known, admit
bounded conversion/extraction/growth before it runs. If the next raw extent still
cannot be established, refuse it. Use actual supplied output-buffer lengths as
writable uppers and charge actual prefixes; a guessed event frequency, a missing
length, a post-call array capacity or the core response cap cannot admit work.

### Freeze, failure prefixes and true return

Revocation, cancellation, stop, job/core deadline or shared count/gross/attempt
exhaustion freezes further optional work and successful publication. Freeze is
sticky. Every actually acquired resource and performed prefix survives in the
receipt and spends previously reserved cleanup. One pending invocation keeps its
inputs, possible outputs and slot; no timeout can destroy its borrower backing.
After actual return, unwind borrower first, then selector/plan, dictionary/error,
CFData, raw input/slabs, descriptors and root/query owners as applicable. Query
stop/observer removal and pool drainage are cleanup, not optional retries. Each
close is attempted once, even if it fails. A cleanup failure is recorded and
prevents successful publication and useful acceptance; it never refunds a charge
or invents successful disposal. Attempt all remaining dependency-safe cleanup once,
destroy any staged success tree under its held credits and, when delivery remains
authorized and within the core deadline, return the complete application
FAILED/null-items envelope with existing INSPECTION_FAILED. Fixed source summaries
retain the failed source(s); bounded diagnostics identify the cleanup stage without
native arbitrary error text. Each selected items alias raises the existing failed
error. Lifecycle/core loss suppresses delivery instead. Both outcomes fail useful
qualification. N5/N8 controlled binary receipts identify the failed close/release,
and G10/V11 independent public outcomes must reject a surviving useful prefix or
success even when detail diagnostics saturate. No new enum, ABI or retry follows.
The slot ends only after actual pending return, all explicit cleanup attempts,
borrower retirement and final publication/failure unwind. Physical native health
after failed disposal remains unproved. Provider restart cannot reset live slots.

An individual file/type/key/metadata refusal retains the admitted copy and healthy
independent facts with affected nulls. A refused preceding name freezes all later
name rescue. A shared failure yields FAILED/null items, never a staged useful
prefix. E allows that complete provider-owned failure envelope when publication
is still authorized; lifecycle/core loss may suppress delivery altogether.
Both are failed useful outcomes. During final success construction, E and all
possible output-destruction credits remain held until the complete tree is frozen
and the final grant/lifecycle/deadline check admits its return. A late tree is
destroyed under its reserved credits. Host completion/encoding may still fail
independently; that keeps qualification held.

## Nine disjoint tapes and controlled requests

The [runtime recipe packet](../design/application-metadata-runtime-admission.json)
names all five episode and four job tapes. The grouped candidate replaces whole
inventory/key/extraction partitions; it preserves input/EOF/API attempts. Every
actual event is assigned once by stage and ordinal, including failed/outside
episodes. The saved API upper is a conservative comparison; actual receipts
record the executed branch, not both the API upper and its individual calls.

| Tape | Controlled construction and explicit work | Owner and admission boundary |
| --- | --- | --- |
| First expanded walk and transfer | Literal, 96-byte state, components/C names, native status out-storage, stack/cycle/link/map/suffix/expanded/resolved blocks; 1,025-byte readlink zeroing and actual prefix are separate; every status/open/link/dot/error/comparison/update | Admit each call's exact buffer/name/record growth and possible descriptors; transfer terminal close once after named/held checks; parent retires. Expanded visits remain actual operands. |
| Root resource or indexed projection | <=1,023 checked root URL/resourceValues explicit calls, typed result/error descriptors and fact writes; >=1,024 consumes only actual staged indexed facts | Reserve both possible result/error owners; no ordinary reader at long roots. Native/Swift internals excluded; invocation, raw projections and cleanup charged. |
| Reader records/owners/selector returns | Layout/resource/file/listing fd records; immutable input/EOF writes; no-copy CFData/plist AND error; independent direct/table slabs, key/value pointer extraction, plans, getters, raw regional/duplicate returns and typed fact writes | Reserve before open/read/parser/selector/extraction/growth. Count LocProvenance and rejected/unselected keys. Metadata owners and every borrower survive until their last access; no reused input underneath them. |
| Independent second walk | A new complete literal/expanded visit tape, status and directory/device/inode comparisons, record/cleanup writes | Run after metadata and first root retire; keep first resolved spelling; no third or per-copy registration walk. |
| Identity merge and final publication | Copy/source/seed associations, discriminants, checked final path/name/ID transcodes; real Swift String/scalar/enum/null/list/object constructors, insertions/appends/freeze and failed-prefix releases | Raw spans remain owned through conversion; provider finishes the entire public tree, counts explicit operations and reserves complete failure/output cleanup. |
| Preferences/source snapshots/type trees/raw slots | Fixed type IDs/predicate/scope, explicit preference strings/pointer array, one indexed query and running snapshot, every raw item/tree member/URL/scalar/policy record and wait/notification operation | Reserve query stop/remove/pool and possible outputs before start; count slots before getters/dedup; retire query/item owners before running, then running before registration. Preferences live through last selector. |
| Once-per-ID registration and two system seeds | Seed string/raw records; CF list AND error; ordered AppKit list plus preferred URL; every returned duplicate URL, type/domain/code observation and projection | Expand every coherent ID once including both system groups; CF outputs retire before AppKit, then preferred; no recursively seeded registration or implicit retry. |
| Seed/domain/grouping/growth/comparisons | 64/112/48/40-byte source/copy/seed/domain records; heap-sorted raw index vectors, exact byte comparisons, binary search, source ordinals/ranks, bitsets and all field updates | Admit new backing/header/copy/transfer/retirement and cleanup together; old/new overlap, failed growth retains old ownership. Loop/access events are additional, not hidden by swap/comparison bounds. |
| Outside outcomes/diagnostics/coverage/permissions/errors | Every declared outside observation (149 in the historical packet), actual root/non-directory/refusal outcomes, bounded 64-byte detail records, fixed summaries, all coverage/domain/permission/error objects | No outside-path exclusion. Reserve summary/error changes before observation and full E before staging. Saturation omits guidance only; all actual failure prefixes and public failure work remain provider-owned. |

Every headed raw block requests align16(64+p), initializes its 64-byte header,
populates actual p/prefix bytes and retires its eight-byte state before free.
Allocation-only receipts omit payload population because another receipt owns it.
Known vectors request stride*count with checked arithmetic; growing vectors use
1,2,4,... capacities, header initialization, used-prefix copies and each transfer
cell write, then old retirement/free. Grouped inventories retain independent
128-byte descriptors, max(256,keyBytes+NUL) byte slabs and 640-byte record slabs;
each five-word record has explicit classification/cursor/used/selector updates.
Slabs remain stable through linking; partial allocation/link/record population
retains pending ownership. Each loctable extracts separately admitted 16*n-byte
key/value pointer storage. No padding is initialized unless its write is charged.
Borrower/lookup traversal, native owner descriptors and raw selector-return copies
are additional tape work. The complete expressions add all nine tapes to the
retained grouped local terms; no omitted explicit operand is excluded or zero.

## Selected reader and real publication

The exact semantic branch construction is the [reader plan](../verification/application-metadata-reader-plan.md#root-and-layout-admission).
Its four layouts remain Contents, Support Files, Resources, flat; information
bases respectively Contents, Support Files, Resources, root and resource bases
Contents/Resources, Support Files/Resources, Resources, root. Only checked absence
advances layout/information. Probe Info-macos.plist then Info.plist. At each global
then selected direct base probe platform/plain strings then platform/plain loctable.
Independent complete inventories, development-first then byte-sorted input,
explicit preferences, every exact regional/duplicate selector return and observed
Base/development backstops remain. A healthy empty name may advance; a preceding
refusal may not. Regular nonlink files admit 0…131,072 bytes, exact-size and EOF
reads without retry, named/held rechecks and immutable no-copy parser inputs.
Per-object 4,096-key limits, literal NAME_MAX and lossless string bounds remain.
No foreign Bundle, recursive listing, descendant whole path or cross-copy rescue.

All final ordinary/indexed typed facts become real ProviderValue values in the
provider. For a choice with p policies, s sources and S issued String constructors,
the existing recipe is S+23+2p+2s explicit operations before raw access/field/
cleanup work. Missing scalars still construct null. Every outer catalogue,
diagnostic, permission, coverage, source and error field gets its actual String
construction, scalar wrapper, object/list initialization/wrapper, insertion and
append. Static keys/enums have their actual job/process enabling construction and
explicit use counted at their owner, never a fictitious fresh raw copy per use.
Empty, individually refused and shared-failure envelopes are complete trees.

Swift/platform constructor backing and compiler ownership traffic remain excluded
costs, not measured zeros. Explicit constructors/accesses/destruction still count;
caller-controlled conversion/owner/field writes are charged. N5 pairs the exact
source/binary recipe with all actual events and detects any omitted prefix or
publication step. Qualification instrumentation's provider-owned raw requests/
writes and explicit calls also count; retain its identity and perturbation in
the evidence. A separate observer's storage is not provider staging and cannot
replace a missing provider operand. No raw tree ABI, helper or public test hook.
Production exports/linkage contain no test injection; controlled branch builds
qualify their branch only, never actual source provenance.

### Evidence correspondence to release images

Receipt recording is private observation at the existing actual provider/host
binary seam, paired with public GraphQL and isolated signed supported-VM witnesses;
it supplies no fourth public interface. The release image contains no test-injection
exports/linkage. Receipt recorder code may be present only in the private test
image, and all its controlled requests/writes/calls are charged and identified.

For each frozen finite subject/profile, compare the ordinary signed release
candidate, hooks-disabled private build and hooks-enabled private build under the
same manifest, toolchain, posture and selected document, following the
[existing three-build rule](../verification/search-serviceability.md#normally-launched-independent-serviceability).
Retain all three source/config/image/signature digests, reviewed source-to-image
correspondence for every adapter branch and explicit recipe, recorder-only deltas
and fixed observer overhead. Compare item-by-item public schema/authority, native
selected sources and metadata, actual complete response, cleanup/failure/lifecycle
outcomes and independent listener/store/action/dialog/hydration results. Timing is
recorded independently; no identical scheduling claim follows. Hooks-disabled must
execute the ordinary recipe, and every required useful case must pass on the
ordinary image too. Hooks-enabled receipts establish the scoped admission evidence
only for that instrumented image, with its charged perturbation; they do not by
themselves prove the ordinary image's event counts or resource cost.

Establish ordinary-image charges at the actual-binary seam by direct observation
or reviewed corresponding receipts with independently matching native operands,
branches and performed prefixes, subtracting only the identified recorder-only
explicit work. An unknown ordinary event, operand, branch or write prefix retains
the holds. Ordinary useful success or matching final public values alone is no
numeric certificate; changed hidden runtime costs remain outside the scoped claim.

Carry evidence to release only with that reviewed branch/recipe correspondence
and the ordinary image's independent outcomes under all applicable gates. A
missing correspondence, altered selected behavior or instrumentation-caused pass
keeps both holds: repair the instrument/recipe then requalify the affected matrix.
A changed adapter, compiler/toolchain, build configuration, linkage, recorder or
release image requires renewed correspondence and affected matched qualification;
no evidence transfers merely because version, schema or totals match. Test branch
injections continue to qualify negative branches only.

The host converts the already real tree, validates depth/types, expands the full
selected fields/response-key merges/nested aliases/errors and encodes the complete
response. The separate 8,388,608-byte cap is applied afterwards. Retain the actual
pre-replacement body bytes and sent response, paired to its request/binaries;
a replacement, encoding/depth/type failure or omitted selection fails usefulness.
Neither body size nor host work funds earlier provider charges or proves peak.

## Eligibility and existing qualification sequence

Private eligibility is a conjunction of completed construction, whole-design review
and all earned integration, a reviewed independent finite metadata-shape subject,
applicable reviewed source/access, image/ownership and normalization designs,
whole discovery-design review/integration and an explicit qualification plan.
A design-established bit supplies only its first term. Eligibility is currently
false: the metadata-shape subject and later prerequisite artifacts are not complete.
Production feature advertisement and ordinary downstream implementation/use remain
held independently.

| Step | Durable completion predicate | Next allowed work |
| --- | --- | --- |
| Whole design | Reviewed complete guarded construction and every accepted repair in this spec and its family | Prerequisite designs may use the reviewed design. No native pass or private implementation yet. |
| Finite subject | Reviewed independent metadata-shape distribution/envelope in the [acceptance subject](../verification/native-discovery-acceptance.md#application-population-subjects), with a named reference population/purpose, independent useful-classification source, reproducible per-copy assignment/rewrite manifest and subject discrimination controls | Cardinality-only fixtures and packet-integrity hashes cannot satisfy this term. Subject discrimination controls remain unbuilt. No native sampling is authorized by this design prerequisite. |
| Source/access | Reviewed [source/access contract](workspace-search.md#application-sources-and-native-facts) and [actual native sources](../verification/native-discovery-sources.md), including earned repairs | Pin actual getters/flags/contact/ordinary read policy and no-dialog/no-hydration controls. Native verdicts stay pending. |
| Ownership/images | Reviewed shared owner/enabling design and [source/image boundaries](../adr/workspace-native-images-preserve-action-authority.md), including earned repairs | Adopt this application's protocol; pin actual allowlists, integration and independent action guard. |
| Normalization | Reviewed [copy/field and ordered-eligibility rules](workspace-search.md#application-sources-and-native-facts), including earned repairs | Pin ordinary/indexed fields, exact copy merging and honest null/refusal outcomes. |
| Whole discovery design | Whole reviewed [workspace native contract](workspace-search.md) and its cumulative source/owner/normalization family with every earned repair | Qualification planning needs no already qualified catalogue. |
| Confined construction and qualification | Reviewed implementation/qualification plan placing the necessary private implementation and actual N5/N8/V11/V13 before ordinary consumer implementation | Build actual private provider/host and closed observer/fixture controls in isolated signed supported VMs, using existing versions/ABI/posture. Do not advertise the native feature on a production host. |
| Release evidence | Complete useful qualification and all applicable G/N/V, authority/disclosure/compatibility obligations | Release only the qualified scope through the usual consumer acceptance; unfulfilled independent Settings/location/core obligations stay live. |

The concrete producer/review/planner sequence lives in the increment's briefs;
the predicates above survive removal of task notes. This is placement within the
existing acceptance programme, not a second source capture. Prerequisite designs/
reviews and private qualification do not depend on ordinary consumption being
complete. This session cuts no implementation leaves. If a qualification result
requires design repair, externalize that precise producer/review work before its
affected consumer rather than repeatedly capturing under a known defect.
No new amount, quota, ABI, helper, posture, signing, consent,
support floor or source/locale/useful-category reduction is authorized.

## Complete finite evidence and release decision

The [native acceptance inventory](../verification/native-discovery-acceptance.md)
owns every G1–G11/N1–N8/V1–V13. Its
[P1024](../verification/native-discovery-acceptance.md#application-population-subjects),
[L1500](../verification/native-discovery-acceptance.md#long-application-source-subject)
and [independent observers](../verification/native-discovery-acceptance.md#independent-observers-and-serviceability)
retain their independent duties. P1024's evidence decision is described in the
[canonical saved-corpus boundary](../verification/application-population-metadata-shape.md).
Its reviewed distribution/envelope must land before private eligibility. Every
native verdict here is PENDING.
The reference instrument's [review integration](../verification/application-reference-evidence.md#review-integration-and-required-decisions)
requires the accepted contact/lookup decisions and complete admission repair with mandatory
whole review before construction replanning. K284 scopes B1–B8 evidence and T1–T7/A1–A3
pre-lookup entries; accepted full contact gaps supply no no-contact proof or finite subject.
Required known identities/controls and all product/native duties remain; this repair
supplies no private eligibility.
The [acceptance/release protocol](../verification/application-reference-evidence.md#chartered-independent-acceptance)
requires Antony's own ready-object trust act after inspection-only review/integration,
independently authored/executed controls, disarmed final requalification, his result
acceptance/audit, a distinct instrument closing owner/step and freshly appointed coexisting
supervisor/checker/acquirer for k245. Receipt, proof, release-record or copied-review
possession supplies no authority or finite subject. K328 finds k323 incomplete; k330 decisions and complete k331/k332 replacement/review/every earned integration precede k269.

The [k328 integration and required replacement](../verification/application-reference-input-partition.md#k328-integration-and-required-replacement)
records every grounded finding against k323 at f4d399f3caa2. K330 records Antony's
approval of proven never-dispatched/no-provisioning bootstrap recovery and human-only
About host/session labels with explicit shared-OS/cooperative provenance limits.
Days/reboot/logout alone do not invalidate Q06 or force CP01; required changed-basis
requalification and every current per-invocation fact remain. No extra initialization,
attempt, checkpoint or observation authority follows. Complete k331, mandatory whole review
k332 and every earned integration precede k269. CP01 publisher wording and the glossary
are repaired; recovery placement, pre-tool selection/holder/fd trust, original launcher
records and repeatable trust slots remain design work. The
[integration-only documentary candidate](../verification/reference-practical-admission-integration-membership.json)
records k329's saved boundary and unresolved duties; later selected edits need k331's new membership. K323's membership is historical. No accepted
construction input, original, control, authority, qualification or finite subject follows.
Normative/actually consumed edits disarm and require affected requalification. K244/k242
stay live, pass unused and all useful/generated/supported-VM/native/private/product duties remain.

The [practical admission design](../verification/application-reference-input-partition.md#coherent-k320-replacement)
is k320's proposal under actual k319, reviewed as defective by k321. K322's
integration places the complete bootstrap/publication/successor/composed-Safari/About/
stream-holder repair in historical k323. K328 finds the protocol incomplete;
k330 decisions, k331 replacement and k332 whole review/every earned integration precede k269. The linked k320 schedule is historical proposal evidence, not a construction identity. The [historical k320 boundary](../verification/application-reference-input-partition.md#coherent-k320-replacement)
compares original duties and precise missing work. Independent SCRATCH bootstrap/tool/
initializer-validator/close-publisher originals are ready before CP01; ARTIFACTS accepts
actual mechanics, ROOT authorizes one initialization and CP02 accepts actual outputs.
Every CP02–CP05 begins with independent retained-original entry/engine/display/runtime/read
continuity recorded in its output. The distinct closer uses its accepted close-only
publisher/channel after CP03 and before CP04. Independently authored/reviewed comparison,
audit and display with a short non-candidate bootstrap entry support Antony's semantic
judgment in five named own-terminal checkpoints outside agent harnesses. Full author/
producer/repairer/runner/own-result and initializer/staged-final validator exclusions and a
distinct instrument close remain. Q10 ends at original Q results; CP03 acceptance/audit and
distinct close follow Q, CP04 accepts eligible basis, CP05 accepts exact entry and freshly
appoints coexisting supervisor/checker/acquirer through true return. Terminal metadata is
cooperative context, not human authentication. Durable disarm precedes changes/Q.

Closed Q/P/C/D and exact T/A rules include finite System framework/version/helper/nested
and Preboot cryptex productions with separate app-position/cryptex-component links and
search-only ancestors. Only the two exact Safari positions may take the checked held-A1-root/immediate-prefix
search-only transition in its own link operand. The [composed Q01 slice](../verification/application-reference-evidence.md#composed-safari-walk-and-q01-specimens)
evaluates the separately admitted nested link, resumes the saved app suffix, checks both
held roots and charges two expansions to one 32 budget; all other outside steps refuse.
K328 finds k323 incomplete; k330 decisions and complete k331/k332 repair/review/every earned integration remains before k269. Finite LV version alternatives
retain exact vendor/structural prefixes and explicit residual refused-copy duties. Complete H/R
exceptions with E default replace fragments/report-driven refresh; full actual consumed
bytes/original/basis/read/phase/absence and original R retained duties remain. Historical
manifests supply no current proof; absent actual originals/controls/identity/read/receipt
facts remain before their consumers. Required refused copies retain exact incomplete
work through k245/k246/k247; full useful breadth/additive VM/native placement/private
ineligibility and both holds remain.

Freeze per supported VM/architecture/OS and exact bundled/update/refusal profile:
host/provider images, signatures/team/IDs, SDK/toolchain, approved posture,
source/observer/client instruments, input GraphQL document and all independent
subject manifests before and after each run. Retain item-by-item digests and
associations; a changed subject invalidates that run. Development-host macOS
26.6.2 dimensions remain historical comparison, not the supported VM's baseline,
an exhaustive disk inventory or macOS 27 qualification.

Record the complete native baseline in the same P1024 workload: 1,024 useful
identifiers (fourteen configured/system witnesses and 1,010 distinct signed UI
apps), 256 signed helper/agent/background copies, 128 controlled aliases and all
actual baseline/registration pressure. Cardinality alone does not define useful
population shape. The subject must pin per-copy information/name-file sizes,
direct locale records/component bytes, each loctable's raw keys/dictionaries,
selected/rejected strings and branch/format/layout associations against the
independent measured real distribution or an explicit justified envelope. Name
the reference population and purpose, distinguish historical template cohorts
from the additive actual supported-VM baseline, and identify the independent
usefulness classification source. Declare multiplicity and all generated-app
rewrites; constructed identities do not become independent measurements. Retain
the tails and correlations, not only means or independently sampled marginals.
Thin metadata-only disk fixtures cannot stand in for that shape. The
[canonical boundary](../verification/application-population-metadata-shape.md#reproducible-boundary-checks)
owns the saved audit's packet-integrity scope. Generated-subject discrimination
controls must independently distinguish permitted rewrites from shape loss.
A pass qualifies only the stated finite shape on its actual supported VM/profile,
never every 1,024-app machine. Do not assume native alias exposure from
disk creation. Keep every direct/table key, raw repeated source slot, unselected
language, preference, regional/duplicate return, rejected observation and repeated
input. Preserve all historical 2,043-row associations per run, 149 outside paths
and both system groups as saved evidence; actual supported-VM counts may differ
and must be independently enumerated, never forced to the historical totals.
Retain all nine actual tapes, successful and failed prefixes, actual file/layout/
selector dimensions, final values/errors/publication and full selected wire.
An observed empty tape has an explicit observed-empty record; absent evidence
is unknown. Pair actual events to exact source/binary branches and all raw recipes;
counter totals alone cannot show that no operation was omitted.

L1500 retains signed 977/978/1,003/1,004/1,023/1,024/1,500-byte roots plus two
short same-ID competitors, the single short-parent reindex allowance and captures
at 10/30/60 seconds. Actual fixed-query tuples, independent directory identities,
correct ordinary localized names/flags and INDEXED_ITEM UNKNOWN/null flags are
required; disk/client/controlled tuples never pass native provenance. Unchanged
selected long launch/named-open/reveal refusal uses both controls and independent
effect observers, beside actual short positive controls. No unconstrained retry.
English Find My/Voice Memos, German loctable, all four layouts, file formats,
selector/backstop/absence/healthy-empty/malformed/denied branches, omitted tables,
129-byte names, repeated aliases and individual/shared failures remain required.

Independent prompt/hydration controls use fresh protected/cloud subjects with
their positive witnesses. Listener latency/liveness, grant-store outcomes and
authorized actions must qualify during actual unheld baseline/P1024/L1500 jobs;
held late-return controls separately test capacity/lifecycle and cannot substitute
for unheld useful serviceability. Require observer mutations detecting a missing
non-witness, wrong name/identity/flag, truncated/native-order prefix, omitted tape/
field/alias, early slot return and an invisible dialog/hydration/action failure.
Opaque acquisition peaks, total heap/RSS and internal native health stay unproved.

Useful release requires a complete evidence matrix, every required useful name/
copy/flag/eligibility outcome correct under its provenance, gross <=20,971,520,
attempts <=4,194,304 without refund, actual complete wire <=8,388,608, all shared
counts, three/five-second deadlines/four true-return slots and independent
serviceability/read policy/action/disclosure/image/compatibility outcomes passing.
Correct individual refusal and shared FAILED/null controls pass those negative
branches only. A required useful refusal/unknown/missing copy, missing operand,
response replacement, deadline failure, failed cleanup or unavailable required
observer/subject keeps both holds and its affected acceptance work live. Partial
success never releases a required case. Actual shared gross/attempt exhaustion on
a required useful baseline/P1024/L1500 subject, like source/access/deadline gaps,
goes once to the bounded human coverage decision. Retain the valid receipts and
consumer consequence; recommend retaining the holds and current scope pending
that decision. Alternatives are an evidence-backed bounded representation repair,
an explicitly approved amount/posture change, or explicitly accepted useful-scope
loss. No automated repeated refinement/capture loop follows valid exhaustion.
A missing/mischarged operand or broken guard is a known construction defect to
repair/review before capture, not a valid exhausted run. No scope reduction
or budget/posture increase follows automatically.

## Verification boundary

Use the existing frozen reconciliation Taskfile suite, including the added
qualification controls. These exercise cleanup and terminal-guard reservation, exact/one-short
admission, unknown operands, performed failure prefixes, sticky freeze/late
return and prerequisite/release eligibility using pure synthetic receipts.
They check consistency of this construction and reject missing tapes/circular
ordering/premature eligibility. They never execute a reader or supply native
operands. Review/integration and remaining prerequisites are independent; no passing
pure check releases advertisement/consumption or establishes useful fit.
