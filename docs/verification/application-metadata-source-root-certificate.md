# Application metadata source and root certificate contract

**Current composition scope.** The [selected reader/admission contract](../design/application-metadata-contract.json)
and [scoped accounting ADR](../adr/application-metadata-accounting-covers-explicit-work.md)
govern current admission. This retained subcertificate supplies historical/local
receipts and counterexamples; its original numeric/ownership recipes are not a
whole-job fit. The [complete composition](application-metadata-composition.md)
adds current owner/cleanup/raw recipes, real provider-owned publication and the
explicit/internal exclusion partition. Known partial conservative enclosures fail
to certify useful fit; full native operands/final selected wire stay conditional.
The consumption hold, mandatory whole-producer review and pending native G/N/V
remain. Historical follow-up lists below describe the evidence's derivation;
they commission no repeated accounting model or already-chartered native capture.

[Source accounting → Preserve raw-slot and payload receipts](../design/architecture/index.html#diagram-native-metadata-source-root)
shows source composition;
[Root ownership → Transfer once and recheck independently](../design/architecture/index.html#diagram-native-metadata-two-walks)
shows descriptor ownership. Graphs begin at the dark **Start here** node;
numbered edges give operation order. The
[behavioral contract](../specs/application-metadata-source-root.md),
[reader ledger](application-metadata-operation-ledger.md) and
[saved episodes](application-metadata-episode-certificate.md) compose this design.

**This is a parametric operation contract, not a numeric whole-job certificate.**
The [machine-readable handoff](../design/application-metadata-source-root-certificate.json)
reproduces controlled path dimensions, toy branch receipts and unresolved terms.
The old 40/16U/5R/12D and 6,816,128 source reserve are not adopted charges.
No new fixed coefficient replaces them. Whole gross/attempt/storage/response
sums remain null, k215's consumption hold remains, and native G/N/V is pending.

## Evidence and alternatives

The exact [LocationWalk source](../../Providers/WorkspaceProvider/Logic/LocationWalk.swift)
is the byte/link/dot/error reference. Tier 2 graph generation
2026-09-29T10:36:20Z (fast) is ready but does not track that file or its tests;
docs/scripts are excluded and Taskfile/glossary metadata changed. Exact reads
therefore supply these claims. No graph-wide completeness claim follows.
The source and [its test descriptions](../../Tests/WorkspaceProviderLogicTests/LocationWalkTests.swift)
were read; neither native walk nor installed target was executed.

The [native source analysis](native-discovery-sources.md#long-application-source-construction)
and [selected source contract](../specs/workspace-search.md#application-sources-and-native-facts)
provide API/provenance policy. Apple's
[registration interface](https://developer.apple.com/documentation/coreservices/1449290-lscopyapplicationurlsforbundleid)
documents the independently releasable array/error outputs and reported not-found
result. The grammar's own return-shape controls claim no stronger health contract.

Keeping fixed reserves would require caller knowledge of invisible operations and
silently count malformed/repeated sources as cheaper than actual inspection.
Selecting a packed implementation now could produce finite capacities, but its
bridge, arena and growth plan belongs to the owned/wire construction and cannot
be inferred from path-only arrays. The chosen interface returns explicit symbolic
receipts. It keeps source operations independent from representation policy and
native qualification; the cost is an intentionally unestablished numeric fit.
Reverse that choice only with a complete representation and admission plan whose
successful/failing prefixes and all actual payloads have bounded receipts.

## Receipt algebra and assumptions

The pure [trace model](../../scripts/application_metadata_source_root.py) never
invokes a native label. Its scalar, source, preference, registration and scripted
walk inputs are explicit observations. Toy strings/types/identities are declared
test data, not reconstructed native tuples or a certified useful baseline.

| Receipt | Meaning and remaining parameter |
| --- | --- |
| Invocation | One explicit API, property/bridge/class/count observation or conservative local operation attempt; every error return still spends it |
| Owned allocation | Actual admitted capacity, including headers/alignment/growth when part of the chosen representation; unknown capacity is null |
| Owned write/read/copy | Each performed byte write, input read, conversion prefix, pointer population or copy; not replaced by allocation or storage lifetime |
| Borrow | No new owned release; owner must outlive use; projecting it emits owned work |
| Opaque acquisition | Native CF/Foundation/parser/ARC representation and internal peak unresolved; kept outside the owned sum, never labelled zero memory |
| Retirement | Each actual owned free, CFRelease, ARC release, pool drain, stop or close consumes previously reserved attempt capacity |

For a fully instantiated trace, gross is the sum of allocation capacities and
performed writes/reads/copies. If any owned term is unknown, gross is null; the
known-write subtotal is informational and cannot fund admission. No disposal,
alias merge, empty output or buffer reuse decrements a performed charge.
Storage is the maximum simultaneous owned capacity with dependency lifetimes;
unknown capacities keep it unknown. A native peak is a different unproved quantity.

This local pre-amendment model enforces **attempt/cleanup admission only** through
the existing ledger. Its symbolic byte receipts now compose through the current
scoped raw-block/conversion recipes in the composition report; it is not an adapter allowed to invoke an unbounded
copy and measure afterward. The numeric admission contract still requires the
maximum possible owned byte charge before invocation/allocation. An unavailable
bound is a failed construction, not permission to use the known-write subtotal.

Pointer population uses eight bytes per native pointer on the supported 64-bit
subject. That states a pointer representation assumption, not a record size.
Record field writes, Swift/CF bridge vectors, strings, arrays, maps, set buckets,
arena headers, alignment and growth capacities remain separate null terms.
Native/ARC retention and release attempts are explicit; the compiler's actual
extra retain/copy/autorelease work must be reconciled with these receipts.

Byte-array events nominate a conservative independent-copy payload construction:
allocation capacity unknown, actual declared payload writes exact. Existing Swift
COW assignments may share immutable bytes; this model does not certify that sharing
or amortized capacity. It explicitly deep-copies map/cycle payloads as an upper
proposal and identifies pending shared assignment without another byte copy.
Proving an unperformed copy can remove that proposal term; it refunds no actual
copy. Array/vector/model record owners conservatively survive until job cleanup;
transient UTF-8 scratch and native batches retire earlier. K225 must choose useful
storage lifetimes and exact field/population/growth receipts before any numeric fit.

## Job setup and indexed source grammar

Before any source stage, snapshot the CFString/CFArray/CFURL/CFError/CFBoolean/
CFDictionary type IDs once. Static attribute/scope/type-name constants are borrowed
process-lifetime values; materializing a predicate or vector is owned/opaque work.
Acquire one explicit preference snapshot under the preference grammar below.

The query grammar is:

1. Push a scoped autorelease pool; construct the fixed predicate's UTF-8 value
   and scope vector; construct the native predicate; allocate/init the query.
2. Set that predicate and IndexedLocalComputer scope. Observe the notification
   center and acquire the finish-gathering observer token before starting.
3. Reserve query-stop credit **before** start. False start owns no active query;
   successful start owns one stop obligation. Every owner-run-loop wait/event and
   notification object/class/query-identity observation is a separate operation.
   Toy examples have one event; real event counts are unknown, never a fixed fee.
4. Only established gathering completion admits disableUpdates, resultCount,
   global raw count admission and individual resultAtIndex iteration. No results
   proxy, second query, extra attribute, sort/group/value-list API or wider scope.
5. Every raw slot admits counting before class/type checks and dedup. Within an
   item pool, fetch exactly the path, type tree, bundle identifier and display name
   from that returned item. Each getter/bridge/class/type observation is charged.
6. A checked tree array gets count and **every** indexed member access/string
   observation. Missing/wrong/incomplete trees cannot certify application type.
   Exact membership is local; no recursive UTI/ancestor query. Raw tree lengths
   and all member payloads are independent dimensions, with no assumed tree quota.
7. Project each present scalar through type, length, maximum-encoding-size and
   bounded CFStringGetBytes; account scratch allocation, actual prefix writes,
   projected bytes plus NUL and tuple record fields. Missing/wrong/malformed/
   incomplete scalars stop the relevant observation, preserving refusal/unknown.
8. Retire each item pool, stop the active query, remove the observer and release
   query/predicate/pool before acquiring the running batch. Retained output contains
   owned scalar values, never borrowers into a retired item/query.

Nil query construction, failed start, unavailable/incomplete gathering, healthy
empty, malformed items/trees/scalars, partial conversion and all cancellation
prefixes retire the actually acquired subset. ERROR in the pure query grammar
denotes an observed failed episode; it invents no NSMetadataQuery error accessor.
Swift/Foundation overlay allocations and implicit retained attribute results need
explicit capacity/ARC receipts; calling a projection borrowed does not erase them.

## Running and URL grammar

Acquire the workspace receiver and running batch once in a scoped pool. Its Swift
overlay snapshot/bridge vector has an unknown capacity plus explicit population;
raw count precedes access. Each raw running object gets access, bridge/class check,
bundleURL, bundleIdentifier and activationPolicy observations. Refused objects and
nil/invalid fields contribute inspection work without establishing negative facts.
The policy/source-index/path/identifier associations require an owned record.
They establish no atomic process identity or root match. Retire the batch/pool
before the next source API. Healthy empty, incomplete and error branches remain
distinct; an empty observed list alone establishes no all-disk completeness.

Every actual CF/AppKit/running/preferred URL slot uses the URL grammar before any
equality or dedup: raw count/admission, bridge and URL type, isFileURL, then
CFURLCopyFileSystemPath with release reserved first. Nil copied path refuses;
healthy copied string uses the bounded scalar grammar and retires its CF owner.
Non-file/wrong/nil/malformed/incomplete/partial conversions stop their actual
prefix. A source ordinal/provenance/path-span record is separate owned work.
No URL.path, filesystem alias/bookmark resolution, extra native item or Bundle
reader substitutes for this projection. Invalid path/identifier/name values retain
the selected contract's unknown/refusal outcomes rather than becoming absence.

## Once-per-identifier registration grammar

The coherent seed set is derived from admitted indexed/running observations plus
the two fixed system identifiers. Raw identifier projections, exact comparison,
group/seed-map insertion, reference-vector population and their capacities/writes
are owned local receipts. The pure stage rejects repeated/recursive expansion.
Registered paths introduce no new identifier getter or recursive seed.

For each seed:

- Construct its explicit UTF-8/CF string with prefix cleanup. Invoke
  LSCopyApplicationURLsForBundleIdentifier with **both** possible array/error
  disposals reserved. Check actual output types; a valid array gets count and
  every raw indexed URL access/projection, including repeated URLs.
- Inspect an actual error's type and, only for a checked CFError, domain and code;
  malformed error values retire without CFError getters or a negative fact.
  Copy no unbounded error
  description. Exact OSStatus application-not-found with no array is the selected
  error-bearing negative. Nil/errorless, healthy empty, unknown error, array plus
  error, wrong type, incomplete list or refused URL keeps negative state UNKNOWN.
  Complete positives remain breadth observations; source agreement alone is not
  installation eligibility or physical absence.
- Retire CF array/error before acquiring the ordered AppKit list. Account its
  overlay/bridge vector, count, raw access and every URL projection. Retire that
  batch before preferred lookup; inspect a present preferred-only URL once, then
  retire it. Nil preferred proves no independent negative.
- Build the ordered path-value domain from AppKit order plus a distinct preferred
  candidate, with separate vector/record/copy receipts. Retire pool and seed.
  Installation-state calculation consumes already staged per-spelling resolution
  values under the existing ordered comparison rule. It performs **no** native
  registration re-walk per copy and cannot discard an unresolved earlier candidate.

The pure stage's COMPLETE/UNKNOWN/CHECKED_NOT_FOUND describes source observations,
not INSTALLED/UNREGISTERED. The installation calculation remains the selected
workspace contract. Array/seed construction nil, native outputs, malformed/error/
incomplete slots and any cancellation use actual prefix cleanup, with no native
fallback or broadened query. Representation-specific seed/domain map/copy receipts
remain explicit conditional parameters in current scoped composition, not a hidden
twelve-attempt multiplier.

## Preferences are one explicit job snapshot

Locale.preferredLanguages is one native acquisition and Swift snapshot construction.
Count and bridge it explicitly. For every raw preference: access/bridge, scalar
type/length/encoding bound/conversion, owned prefix and UTF-8 projection. Allocate
the CF pointer vector before population; every successfully created preference
CFString contributes its actual pointer write. Reserve each string release before
create. Then create the explicit CF preference array, including a healthy empty
array for zero preferences, with its release reserved first.

Nil string/array construction or refused scalar retires the acquired prefix and
cannot use main-Bundle/default preferences. The successful immutable array and
string owners remain job-owned until the last direct/table selector returns.
Retire selector inputs/results/borrowers before those owners. The model returns
its construction outcome, not a fallback language. Cancellation retains inflight
inputs/possible outputs and the slot. The former 32 records/4,096 payload is still
an unverified finite-subject assumption, **not** a locale quota; actual snapshot
count/length/overlay capacity must instantiate this grammar without dropping a
language, refunding writes or silently switching to an empty array.

## Exact root visit and ending grammar

Each walk starts with a separately charged literal projection, state record and
openat root acquisition/close reservation. The existing byte parser scans slash
runs without shifting the remainder at every component. Each consumed name has
an Array(component) payload construction; byte slices do not themselves certify
copy-free Swift lifetimes. DarwinWalkSystem.name additionally maps n CChars then
concatenates a separate n+1 NUL array **for each native named call**.

| Source branch | Explicit syscall sequence, apart from final actual cleanup |
| --- | --- |
| Initial root failure | openat root; no acquired close |
| Nonfinal dot | no syscall; component/local parse work still charged |
| Final dot / slash-only / empty pending | fstat current; first variant transfers held directory |
| Nonfinal dot-dot | openat parent; close old current on success; physical stack pop; error classification on failure |
| Final dot-dot | fstatat parent; first variant additionally opens/checks parent and transfers it; second keeps source's lookup-only ending |
| Normal nonfinal directory | fstatat name, openat directory, close old current; stack/reference/owner updates |
| Final directory, second walk | fstatat name, finalize value, release current; no terminal open |
| Final directory, first walk | fstatat before, openat terminal, fstat terminal, fstatat after; compare type/named/held identity; close parent and transfer terminal |
| Final regular/other / below-file / trailing slash | named status; second may report final non-directory; application pair requires directory; below-file/demanded directory refuses |
| Native lookup/open/readlink ENAMETOOLONG | additionally fpathconf on the actually held parent; ASCII/known-limit comparison only can prove impossible component |
| Other lookup errors | source's missing/not-directory/failed classification; denial/unknown errno is not absence |

For successful first named transfer, the two possible descriptors' cleanup is
reserved before open; held/type/identity failure closes both actual handles.
Failed open owns only the parent. Held failure omits named-after; named-after
failure/replacement retires terminal and parent. Close is attempted once even
on cleanup error, with no ambiguous retry. Transfer moves one close credit,
never reacquires it or leaves a parent open. Current-directory ending transfers
the original handle after fstat; it needs no redundant open. Final parent ending
uses the same open/fstat/named comparison from its held child.

Every link first gets named status, then allocates/initializes the 1,025-byte
readlink payload buffer, constructs that call's own C name, invokes readlinkat and
charges reported input bytes. Its actual array capacity/header is still unknown.
Copy the returned prefix. Changed repeated link text refuses before containing
fstat; empty text refuses as missing. Store/compare link identity and text; obtain
containing directory identity; construct the exact slash-collapsed pending suffix.
Compare a cycle key containing directory identity, link text and collapsed suffix.
Repeated state is a cycle; a 33rd expansion is refused **after** the source's
read/text/map/containing-status/suffix checks, before inserting/expanding again.

Each accepted expansion accounts cycle record/text/suffix, Array(rest),
text+rest construction, expansion-vector append and pending ownership assignment.
An absolute link closes current before root reopen and clears the physical stack.
Relative text resumes from its containing directory. Every link/read/containing/
reopen failure retires the actual prefix. Uncollapsed suffix bytes, collapsed
cycle suffix and expansion bytes are different receipts. Lexical path length or
component count does not determine these intermediate visits/copies.

Finalization accounts the component reference vector, joined spelling, leading
slash concatenation and literal/expansion/resolved value records. Their capacities,
growth/header/field writes and COW copies are parameters, not a free stack operation.
Error-component UTF-8 repair/cause/guidance staging and owner-transfer bookkeeping
are local receipt parameters too; raw submitted bytes are never repaired.

The first finalized root's lossless UTF-8 length selects the <=1,023 root-resource
branch. URL construction, optional resource result/error, Swift value projection,
typed optional Bool observation and actual disposals are explicit. Reserve both
possible result/error outputs before the getter. Only TRUE enters the reader
ledger. False/nil/wrong/error retains affected-metadata refusal and still makes
the independent second identity observation. >=1,024 enters INDEXED_ITEM only;
no resource getter, fixed reader, short alias or invented indexed tuple is admitted.

After all metadata-owned descriptors/dictionaries/selectors retire, close the
first root and run the second walk independently from the literal input. Require
directory and equal device/inode; retain the first finalized spelling. Changed
links/absent/failed/wrong-type identity refuse the copy. Native races between
separate status/resource/file checks remain unproved. Registered candidate values
use this spelling's staged before/after outcome, with no third/native re-walk.

## Prefix cleanup and contribution terms

Every optional invocation/allocate/copy admits its attempt, all existing disposal
credits, every possible acquired-output disposal and its maximum owned byte charge
first. On actual return, record acquired owners and all performed prefix bytes.
Cancellation/error/deadline freezes optional work; required stop/remove/release/
close/free operations spend their earlier credits. An outstanding call cannot
unwind inputs/outputs or return the slot until actual return. Four shared slots
still last to true return. CF objects borrowed from batches/dictionaries have no
new CFRelease; explicit CF/ARC acquisition and bridge work remains accounted.

Native source calls have no automatic retry. A constructor/getter/property
failure uses its actual shorter prefix and owner unwind; the model exercises
cancellation at every optional boundary, with a separate inflight-return control.
Healthy empty, malformed/incomplete, exact native negative and failure are
distinct shapes. No optional cleanup failure can refund spent attempts/bytes.

For each source s, define its contribution from actual receipts:

`A_s = invocations_s + acquired-disposals_s + local-operations_s`.

`G_s = sum(allocation-capacity_s) + sum(actual-read/write/copy-bytes_s)`.

For roots, apply the same sums to each actual expanded first/second trace and
resource branch; include failed/outside spellings too. Do not substitute V=32,
two literal path copies or 6V+4 for those sequences. The 32 **link expansion**
budget is source semantics, not a path-depth/expanded-visit bound. Source/type/
preference/group/scalar/write dimensions remain inputs to these expressions.
If any summand is unresolved, that total is unresolved. Source/root plus reader
plus final publication/wire work is the whole-job composition; none is silently
included in two stages or presumed paid by an old 1 MiB scratch term.

## Controlled path-only dimensions

The independent derivation retains every saved duplicate source slot:

| Controlled source | Raw slots | Literal path payload plus NUL |
| --- | ---: | ---: |
| Indexed path counterparts | 2,043 | 222,022 |
| Running path counterparts | 128 | 16,384 |
| CF registration paths | 1,910 | 205,378 |
| AppKit registration paths | 1,910 | 205,378 |
| Preferred paths | 1,871 | 201,809 |

Total raw URL slots are 7,862; identifier groups are 1,871 plus two system reserves,
1,873. These are **path-only controlled dimensions**, not native indexed tuples,
type trees, source errors, preferences, current root-resource outcomes or expanded
walk visits. A pathname payload count establishes no allocation capacity or number
of native/owned copies. System reserves provide no invented returned payload.

The 149 other census paths are preserved individually with their saved reason/kind.
They remain source/root work, not exclusions, automatic directories or missing
values. Their projected payload and refused/lookup branches need actual inputs;
they cannot be merged into the independent controlled counterpart as if captured
there. Roots to 1,500, aliases, required useful apps/helpers and the 129-byte name
remain in the inherited subject. Toy walk inputs do not prove useful native closure.

## Handoff and failed construction

K225 receives the source/root receipt grammar, source branch manifests, first-root
transfer and second observation, exact controlled raw path counts, null aggregate
terms and frozen omission controls. **Sound whole-job construction is unestablished.**
The following historical checklist is resolved at the scoped composition
level; it records the derivation rather than commissioning another model:

1. Specify scalar/record/arena/vector/map/set capacities, alignment/header/growth,
   per-field population and all bridge/COW/UTF-8/final-conversion operations. Bind
   pre-call scalar conversion maxima, actual partial writes and ownership adoption.
2. Partition walker state, two immutable 128 KiB inputs, EOF bytes, conversion/
   selector scratch and overlaps. Assign early-free/retained lifetimes explicitly,
   without double-counting reserved capacity or refunding repeated reads/copies.
3. Compose complete local source/root/reader/final/publication attempt and gross
   receipts for all saved episodes and the source assumptions. Registration seed/
   source ordinal/provenance/ordered-domain records, walker owner updates/error
   strings and all unselected inventory/table key/return work are included.
4. Close final scalars and a complete finite selected GraphQL response, including
   aliases/fragments/roots, escaping, keys/punctuation, diagnostics and fixed
   summaries/errors. Preserve the independent core response guard and alias controls.

Current raw representations/recipes and complete scoped expressions are supplied
by runtime admission/composition; the historical list above adds no live gap. Distinct
native inputs remain pending: actual query tuples/type trees/events, running/
registration output shapes, preferences, expanded walks/resource results, the 149
outside paths' outcomes, long indexed tuples and signed supported-VM G/N/V.
Do not repeatedly cut new leaves for those already explicit acceptance obligations.
Unknown native dimensions may keep a finite useful certificate conditional; they
cannot excuse an unclosed owned representation or change the selected category.

The composition report includes every original k225/k220 close check at its
permitted precise failed-closure boundary. Whole-family reconciliation and
mandatory whole-k215 review/Creator at actual k218/k215 closure. No fragment review,
hold removal, implementation leaf or new budget/posture/useful-loss decision
occurs here. No native peak, all-disk completeness, deadline guarantee or native
G/N/V verdict follows any pure check.

## Reproduction

Run `task design:application-metadata-source-root-certificate` after edits finish.
Then `task design:application-metadata-source-root-check` compares every saved
item, exercises source/root prefixes and rejects isolated omitted charges,
duplicate/tree inspections, error retirement, vector/ARC work, terminal checks,
suffix copies, long-root misuse, system reserves/outside paths and unknown-to-zero.
The instrument hashes its saved subjects, prior episode assessment, source/model/
test/mutation tools, exact LocationWalk and Taskfile before and after. No target,
source query, reader/CF, registration, launch, signing, consent or VM runs.

Retain the inherited reader-plan, operation-ledger, episode, subject and
localized-boundary checks with their original oversize/baseline/omitted-table
controls. Final verification freezes all declared inputs and checks item-by-item
digest equality; passing these commands is no numeric useful fit or native pass.

## Grouped refinement and retained hold

The [grouped inventory/key refinement](application-metadata-grouped-storage.md) replaces complete retained key
partitions with independent linked-slab owners, while preserving the selected
reader semantics, scoped gates, every saved association and the full wire. Its
controlled local/source/two-walk enclosure still exceeds 20 MiB before other
terms; it establishes no useful fit or native pass. Earlier independent-block
numbers remain reproducible comparison. K215 and its consumption hold remain
live. The [selected qualification order](../adr/application-metadata-qualification-precedes-analytic-fit.md)
permits a private guarded implementation for existing N5/N8/V11/V13 qualification
before analytic fit, after complete design, whole-producer review and earned
integration. Advertisement/downstream consumption remain held until full useful
native operands, actual complete selected responses, required witnesses and
independent serviceability qualify. Failed/refused/unknown required useful cases
and unavailable subjects keep those holds and affected acceptance work live.
Existing whole-producer review, all native G/N/V, actual full operands/response,
useful breadth and independent authority/action/Settings/disclosure/compatibility
duties remain. No repeated strict/scoped selection or new capture leaf follows.
