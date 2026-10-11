# Application metadata operation and ownership ledger

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

[Reader accounting → Reserve cleanup before acquisition](../design/architecture/index.html#diagram-native-metadata-operation-ledger)
shows the accounting boundary. Graphs start at the dark **Start here** node;
numbered edges express work order. This is the operation grammar for the
[selected reader](application-metadata-reader-plan.md), with a pure executable
trace model. It invokes no filesystem, CF parser/selector, source query or Koine
operation. Platform names in traces are labels, not calls.

**Construction boundary.** This ledger replaces no population certificate and
claims no aggregate fit. Application-metadata-episode-certificate-k223 must
apply it to all 2,043 saved episodes, derive source/storage/gross/wire terms,
and expose missing dimensions. The scoped composition supplies the complete conditional expressions. Whole-family
reconciliation preserves k215's consumption hold, mandatory whole-producer review and
pending G1–G11/N1–N8/V1–V13 remain binding. No accepted budget, file family,
authority, deadline or accounting rule changes here.

The [saved-episode assessment](application-metadata-episode-certificate.md)
now supplies all alias-preserving dimensions and conditional reader API-call
uppers. Its source/root/owned-storage/scalar/wire terms remain unknown, with
native operands/final wire conditional; the useful-fit consumption hold remains.

## Reservation, charge and true return

Before an invocation, admit one call, **all possible owned-output disposals**,
and its maximum possible owned byte charge. Existing resources keep their
disposal capacity reserved. A failing admission invokes nothing and freezes new
optional work as shared CALL_LIMIT/COPY_LIMIT; no partial population publishes.
Reserve both property-list result and CFError disposal before the parser, even
though normal results have only one. Do not rely on the success branch to fund
error cleanup. Local allocations/copies/free events also take one conservative
trace attempt; these are explicit owner-work allowances, not measured syscalls.

An invoked call spends its attempt even when it fails. On its **actual return**,
record returned byte writes/copies and actual owned outputs. Only reservations
for work never performed or outputs never acquired end; no spent byte or attempt
decreases. A failed read returning no bytes has zero performed input, but its
attempt is spent. A short read spends the bytes obtained and refuses the file.
Conservative episode bounds can use the admitted full size instead. A reused
buffer still charges the next read and every actual conversion/copy. Allocation,
read, pointer-vector population and later projection are separate receipts when
each is performed; writing a vector is not made free by its allocation receipt.
Capacity/payload choices and overlap must be derived in k223, never added twice
accidentally or silently removed from the old scratch term.

An owned buffer/vector/record allocation charges its capacity. A borrowed CF
key/value retains its owner's lifetime, acquires no release obligation and cannot
be CFReleased. A created/copied CF object has a release obligation. Its opaque
native representation/peak is recorded separately; zero known projected bytes
is **unknown footprint**, not a zero-byte object or permission to relabel
provider-created projection as native memory. Hidden Foundation/ARC, parser,
selector, query and root-resource acquisitions remain native serviceability
limits, distinct from the explicit attempt/owned ledger.

Cancellation, deadline and lifecycle loss freeze optional work. An outstanding
call keeps its input, possible-output cleanup and job slot until return. Cleanup
then spends its prior reservation despite the freeze. Release selector/plans
before their dictionaries, dictionary before no-copy CFData, CFData before its
buffer. Do not return the shared slot until no invocation, borrower or owned
resource remains. Four jobs still share four true-return slots; three-second
read/five-second core deadlines cannot bound an opaque call's return or peak.
Four 20 MiB allowances are 80 MiB cumulative admission, not resident memory.

## Root, layout and direct directory operations

The two root walks are separate episodes. The first supplies the held root for
metadata; after metadata retirement the second independently checks device/inode.
No third walk, registration re-walk per copy, whole descendant pathname or
foreign Bundle is allowed. Only ordinary roots through 1,023 UTF-8 bytes get the
native application-root type observation; actual indexed tuples supply larger
roots, with UNKNOWN installation state/null flags and independent action refusal.

Exact source fallback read the existing
[LocationWalk](../../Providers/WorkspaceProvider/Logic/LocationWalk.swift).
Its syscall seam uses openat(O_SEARCH), fstatat, fstat, readlinkat, fpathconf and
close. Ordinary intermediate directory visits use named status/open/close;
link visits add link text and containing-fd status, with close/openRoot on an
absolute link. ENAMETOOLONG classification can add fpathconf. Dot/dot-dot,
empty/changed/cyclic/over-budget links, final file/directory and failures are
distinct branches; release closes the actually held fd, including on error.
All expanded visits and copied link/suffix/component/spelling bytes count.
The existing resolver **closes its handles before returning a value**, and its
final directory branch does not open that directory. It cannot hand a metadata
adapter a still-held fd unchanged. The proposed first-walk variant must open and
fstat the terminal directory from its held parent, compare named/held identity,
then transfer the terminal fd and close the parent. Reserve both possible closes
before open. Charge those terminal operations explicitly within the per-visit
derivation; never insert a reconstructed whole-path open or a third walk.
The inherited 6V+4 is a candidate envelope, not source evidence for that variant
or its array/copy costs. K223 must close it against every branch and source term.

Every fixed descent from a held metadata directory has this maximum manifest:
fpathconf(parent), fstatat(name, nofollow), openat(name, nofollow), fstat(child),
fstatat(name, nofollow), and close(child): **six calls**. Compare the named/held
identities locally. Positive parent NAME_MAX is required for metadata components;
root-walk absence semantics remain the existing kernel/errno contract. Failed
limit: one call; absent/wrong-type/link/dataless/denied name: two; open failure:
three; held refusal: four plus close; complete/recheck refusal: six. Reserve
child close before open. A retained child moves the same close reservation to
its owner; the six-call accounting includes its eventual close. Checked ENOENT
alone advances layout/family; all other refusal branches stop affected metadata.
Resources/flat alias an existing base fd rather than duplicate it gratuitously.
Selected resource absence and information/resource refusal have k219's distinct
fact/name consequences. Hold independent information facts through resource loss.

For listing, retain the resource fd; dup a separate listing fd and reserve close
before dup. Dup failure owns nothing. fdopendir success transfers that fd and its
one disposal credit to DIR/closedir; failure keeps caller fd/close ownership.
Count fdopendir itself regardless of outcome. Every readdir attempt counts,
including terminal EOF/error. Check the terminal errno; only healthy EOF completes
the inventory. No readdir retry or reopening after a refused entry. On every
exit close the DIR or untransferred dup exactly once, then the resource fd when
its component reads finish. Every direct raw slot, including non-locale,
duplicate and rejected entries, consumes its shared slot before classification.
Valid lproj entries use the six-call descent above; non-locale entries are never
opened. Copy full NUL-terminated components, suffix-stripped literal keys and
any CF selector inputs separately when actually produced. Direct-key records,
sorting/mapping vectors and plans have explicit owned receipts; unselected keys
are not free and a borrowed pointer never outlives its owner.

## Fixed file and parse operations

The complete non-retrying fixed-file syscall trace is:
fpathconf(parent), fstatat.before, openat, fstat.before, pread(payload, declared
size), pread(one EOF byte), fstat.after, fstatat.after, close: **nine calls**.
Reserve close before open and gross capacity before each read. Type/dataless,
identity, size/time and encoding/component comparisons are local; additional
platform queries would be new charged calls. Both pread invocations occur even
for declared zero bytes; healthy EOF writes zero bytes, extra EOF input charges
one byte and refuses. The input bound is 0…131,072; known oversize before open
refuses without input, or after open closes before reading. Metadata refusal
does not itself freeze the population; shared exhaustion does.

| Actual exit | Calls including close | Performed read bytes at size n |
| --- | ---: | ---: |
| Parent limit refused | 1 | 0 |
| Checked absence / named refusal / named oversize | 2 | 0 |
| Open failure | 3 | 0 |
| Held refusal / held oversize | 5 | 0 |
| Payload error / short payload | 6 | 0 / actual short count |
| EOF error / extra EOF byte | 7 | n / n+1 |
| Post-held failure/change | 8 | n |
| Post-named failure/change / healthy read | 9 | n |

No successful prefix is parsed. Failure after any attempted call spends that
call and disposes actual acquisitions. Errors need no copied strerror/native
description: a bounded fixed diagnostic records stage/reason; its eventual
allocation/wire term remains explicit even after detail saturation.

For admitted immutable input, CFDataCreateWithBytesNoCopy uses kCFAllocatorNull
as bytes deallocator so releasing it cannot free the caller's backing arena.
Reserve CFData release first; nil creates no owner. CFPropertyListCreateWithData
then reserves **two** possible CFRelease outputs. Require an immutable dictionary
using cached CF type IDs and CFDictionaryGetCount before getters. No arbitrary
native error-description copy or second parser. Any unexpected result+error
shape refuses and disposes both. The complete parse-and-retire counts, separate
from file calls and buffer allocation/free, are:

| Parse exit | Explicit calls |
| --- | ---: |
| Nil CFData | 1 |
| Nil result, nil error | 3 |
| Nil result, owned error | 4 |
| Unexpected owned result and error | 5 |
| Wrong result type | 5 |
| Dictionary count refused / healthy dictionary then retirement | 6 |

Healthy information remains retained while borrowed facts/development/fallback
are used. Current name input alone overlaps it; retire that name before the
next file. Each parse row includes eventual CF disposal, not permission to retire
a dictionary before its consumers. Native result memory is opaque and does not
fit a byte gate merely because the input has a file bound.

## Key, getter, preference and selector operations

Cache required CFDictionary/CFArray/CFString/CFBoolean type IDs once per job,
charging each getter actually called. A normal bounded string observation uses
CFGetTypeID, CFStringGetLength, CFStringGetMaximumSizeForEncoding and
CFStringGetBytes: at most **four calls**, with every performed UTF-8 write charged.
Type/length/encoding refusal stops at its actual call; partial conversion still
charges actual writes. Local checks require lossless whole conversion, NUL-free
bytes and bounds (key 1…1,024, identifier 1…512, name 1…1,024). Add a terminator's
owned/write charge where required. Reusing conversion scratch refunds nothing;
final output conversion/copy is a further receipt unless it adopts existing
owned storage without another actual conversion/copy. Empty healthy name
advances; wrong-type/malformed display refuses before bundle-name rescue.

Information's six fact keys each use CFDictionaryGetValue. Missing values need
no value-type getter. Identifier/name/development strings use the bounded string
manifest; a typed Boolean uses CFGetTypeID and CFBooleanGetValue, not NSNumber
coercion. Two missing/empty name keys allow the next dictionary; once a usable
name wins, later keys/families/bases are unperformed. Direct/table empty plans,
Base/development backstops and information-name fallback remain k219's policy.
No CFDictionaryContainsKey call is hidden: null GetValue means absent for
property-list dictionaries. If an adapter adds ContainsKey/retains, count them.

A table first checks top-level type/count. For K raw keys, allocate and populate
two bounded K-pointer vectors before CFDictionaryGetKeysAndValues (one call).
For **every** key/value pair, including unselected keys and LocProvenance, perform
the four-call key-string observation and CFGetTypeID(value). Each dictionary
value additionally uses CFDictionaryGetCount. LocProvenance is reserved after
literal key comparison: observe its type and direct dictionary count if applicable,
never enumerate its contents or select it. Every other value must be a dictionary
within 4,096 keys; its wrong type/count refuses the table even when unselected.
Thus validation is at most **six calls per raw top-level pair** after extraction,
with actual short-circuit prefixes on refusal. Do not conflate that with six
recursive calls per nested key: arbitrary nested contents are not walked.
CFDictionaryGetValue(selected language) adds one call per performed selected
dictionary; then the two name getters and bounded string observations above.
Language values and native keys are borrowed from the retained table. A new
literal UTF-8 key record/map or pointer copy is owned and charged separately.

Snapshot explicit Locale.preferredLanguages once (an opaque native acquisition),
charge its raw count/access/bridge/type/string/projection/disposal operations in
the job source manifest. Never replace explicit healthy empty preferences with
null/main-Bundle preferences. The saved 32 preference records/4,096 payload is
an assumption to verify, not a production language quota or completed bridge cost.

For each nonempty direct/table inventory, form its exact development-first then
byte-sorted possible array and explicit preference CF array. Charge owned pointer
vectors, copies, any CFStringCreateWithBytes per newly materialized key/preference,
CFArrayCreate for each newly created array, and CFRelease for every actual created
string/array. Table keys may be borrowed; direct suffix-stripped strings cannot be
called borrowed native CF objects without an actual owner. Any nil construction
refuses after releasing the already-created prefix. Preference-array reuse is
possible once per job, with no new copy fee unless another copy is performed;
this does not undo its original charge.

Reserve selector-result release before CFBundleCopyLocalizationsForPreferences
(one call). Nil/wrong-type result refuses; healthy empty is distinct. Count
CFGetTypeID(result) and CFArrayGetCount before projection. Each returned raw slot
uses CFArrayGetValueAtIndex plus the four-call bounded-string observation:
**five calls**, including repeated/regional slots before exact mapping and dedup.
Foreign keys refuse; no normalization rescue. Only projected distinct keys enter
owned ordering/plan records; observed Base/development additions use local exact
maps and charge any new record/copy. Empty inventory skips array construction and
selector. Release result and input arrays before their string/key owners, and
plans/borrowers before the table/input arena. CF may perform opaque internal work;
these explicit calls alone establish no selector peak or current-OS matching.

## Failure and publication obligations

At every operation boundary: admit call/bytes/possible cleanup first, then invoke,
observe actual return, charge actual output and classify. Native absence is not
inferred from a count, nil parser/selector or denied component. Individual malformed,
oversize/key/type/input refusal withholds only affected facts and stops the defined
fallback. Root absence/replacement can refuse the copy. Shared count, call, gross
or deadline failure freezes admission/publication and discards all staged choices;
diagnostic saturation alone keeps choices and fixed reason/source summaries.
No optional call follows freeze, but every reserved actual disposal does. Failure
or timeout inside any of the listed stages follows the same owner-dependency
unwind; a call that has not returned cannot be unwound by the caller.

Close returns are charged once even if close reports an error. Do not retry an
ambiguous close (the descriptor may have been reused); retain a bounded cleanup
failure reason. fdopendir failure retains caller ownership. Explicit CFRelease,
close/closedir and owner-free attempts have no success-only free branch. ARC or
native hidden releases cannot be presumed to replace these trace obligations.

## Saved dimensions and remaining certificate work

The full saved subject has 640 baseline directories, 1,275 controlled directories
and 128 distinct alias episodes: 2,043 total. Its all-family census upper is
7,438,626 input bytes, with 17,881 direct locale records and 10,024 table dictionary
keys. Regional selector returns are retained. The saved proposal inspected only
en/de table name values but measured maximum names across languages: exact regional
name/type/getter branches are not available from those two values. Maxima can fund
a sound upper bound; they cannot invent successful regional witness outputs.
The 129-byte name and roots through 1,500 remain required dimensions.

Eight baseline rows contain 16 rejected lproj entries; their exact refused types
are not captured. Under the selected direct-inventory rule they are refusal
observations, never healthy empty/absent languages. The full census/plans are
cost upper bounds; they are not actual successful reader traces or approval to
ignore rejected entries. The 149 other query paths remain source population work,
with unavailable contents; they are no product exclusion. The support-floor and
macOS 26.6.2 historical evidence remain unchanged after the host upgrade.

K223 must derive actual/safe-upper operation multiplicities per episode, not
multiply a new arbitrary 32C/8E/48F. Its source manifest must close U/R/D, indexed
type-tree/raw tuple/scalar access, preferences/bridges/disposals and each root
variant, with every actually expanded visit and allocated/copied spelling byte.
It must partition scratch for two 128 KiB inputs, EOF bytes, key/final-conversion
scratch and walker storage, then account all owned vectors/records/UTF-8 payload
representations and final conversions. No schema for measured Swift/native
allocator footprints or baseline source tuple lengths is present; keep assumptions
visible and the hold until the design is sound. The independent wire derivation
must include final paths/labels/identifiers, alias and selected-field multiplicity,
escaping, diagnostics and root/coverage overhead under the unchanged core 8 MiB.
Fit only 20,971,520 gross and 4,194,304 attempts; actual native/source/VM usefulness,
deadlines, prompts/hydration and listener/store/action serviceability remain pending.

## Reproduction and controls

Run `task design:application-metadata-operation-ledger-check`. The pure model
exercises fixed-file exits, possible parser result/error ownership, descriptor
transfer, raw regional/duplicate/foreign slots, cleanup-first capacity, borrowed
dependencies and cancellation while a call is outstanding. It never parses a
file or invokes a native boundary. Its returned-key trace covers healthy-string
and foreign-map receipts; type/encoding/refused selector branches use the stage
manifest above and k219's policy controls, not a claimed executable CF adapter.
Deliberate isolated mutations remove input charges, call charges, cleanup
reservation, parser error disposal, correct DIR retirement or duplicate inspection;
the relevant real-model tests must fail. Original oversize/baseline/omitted-table
controls remain in subject-check and localized-boundary-check. Inputs are hashed
before/after with no concurrent writer; passing checks establish this accounting
protocol, never aggregate native usefulness or a complete cost fit.

The final frozen check runs ledger-check, reader-plan-check, subject-check,
localized-boundary-check and check:docs. The ledger has 66 passing trace cases
and seven rejected isolated mutations; the inherited reader model has 59 cases,
and the saved-subject regressions seven. Both typed models pass strict pyright.
The original size/input/inventory/omitted-table counterexamples remain reproduced.
Declared repository design inputs and verification tools match before/after item
by item; this is saved-input validation, not a recapture of native targets.
The new view was checked at its fresh browser deep link in desktop and 390×844
mobile presentation, with the viewport restored. Browser dark appearance and
the older whole-family views remain k221's explicit reconciliation work.
