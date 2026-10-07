# Long-location route evaluation

**The investigation is closed for v1.** Koine resolves long locations itself and
refuses, truthfully, to hand applications any location too long for macOS's
whole-path services. Making applications accept such locations is deferred past
v1 ([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1)). The
[v1 decision](#v1-decision) below is current; everything after it is the
evaluation record that led there, kept as evidence.

## V1 decision

On 2026-10-07, reacting to the
[separated local naming collection](separated-local-url-naming-prototype.md),
Antony stopped the investigation: Koine's own filesystem code uses a
directory-descriptor abstraction resolving component by component, applications
that cannot take long absolute paths surface the failure, and long-path
application support is deferred until after v1. That supersedes, for v1, his
2026-10-05 [absolute requirement](#non-negotiable-long-path-requirement) and the
[retained working cases](#decision-for-antony). No further native
investigation, external inquiry or workaround is authorized; the
[inquiry drafts](#prepared-capability-inquiry) were never sent.

The current contract is the
[v1 action boundary](../specs/workspace-launch-and-open.md#long-location-action-boundary)
and the [descriptor-relative access decision](../adr/filesystem-access-is-descriptor-relative.md).
What each diagnostic contributed to it:

| Evidence | What it established | Where it lands in v1 |
| --- | --- | --- |
| [k134 prototype](long-action-route-prototype.md) | Component-relative calls reached about 1,500-byte items with truthful causes; submission delivered a 1,023-byte path and failed at 1,024, while metadata and handler lookup answered through 1,023 bytes and failed at the next tested length, 1,098, and long registration failed at about 1,500; a read-mode walk prompted at Documents. | Koine's own resolution; the `PATH_MAX` hand-off limit; search-only handles with a prompt acceptance obligation. |
| [Application surveys](../research/long-pathname-applications.md) | Mature descriptor walks and their failure modes; no macOS opener accepts a descriptor or component list. | The walk's obligations; no hand-off workaround. |
| [Native references](#native-reference-result-and-remaining-gap), [item arrays](item-array-submission.md), [file-reference URLs](file-reference-url-acquisition-prototype.md) | References, item-array submission and URL acquisition all stop at 1,024 bytes. | Rejected hand-off workarounds. |
| [Same-object namespace](same-object-namespace-prototype.md), [focused Zed](focused-zed-receiver-prototype.md) | Local identity access works at 1,500 bytes; native facts fail and Zed reads by whole path, naming the buffer by inode. | Receiver parity is not reachable by a Koine-side spelling. |
| [Bookmark](bookmark-name-resolution-prototype.md), [local naming](local-url-naming-prototype.md), [separated local naming](separated-local-url-naming-prototype.md) | Two stopped attempts, then all eight cases: names survive in URL text, but 1,500-byte bookmarks and parent-reference reads fail. | Rejected hand-off workarounds; the question moves to Koine#1. |

Every measurement keeps its own limits, raw corpus and spent allowance; this
decision repeats none of them and adds no native result.

## Evaluation record

The sections below record the evaluation as it ran, before the v1 decision.
Their "remaining", "retained" and "unresolved" language describes that time.

## Non-negotiable long-path requirement

Antony's reaction to k149 on 2026-10-05: "It is an *absolute* requirement
that we work around the path limit. The raison d'etre of Koine fails otherwise."
Long-path support is a non-negotiable product requirement. The measured failures
exclude only these tested candidates; they authorize no shorter/copy-only
baseline, workflow loss or closure with the gap unresolved. Continue toward an
actual workaround under the retained contract. This statement does not itself
select a mechanism or waive the existing public-API, spelling, consent, setup,
receiver and receipt obligations.

## Source candidates and remaining obligations

| Consumer | Positive public evidence | Unsettled obligation |
| --- | --- | --- |
| Presence and literal resolution | SDK `openat`, `fstatat`, `readlinkat` and `fpathconf` support parent-relative operations; `FSMakeFSRefUnicode` constructs an object reference from a parent reference and a Unicode name. | Preserve byte spellings, symlink expansion, actual directory traversal for dot/dotdot, trailing separators, dangling links and below-file results. New inspection calls need prompt/materialization evidence. A native reference is not a submission location. |
| Payload flags | `LSCopyItemInfoForRef` returns requested native item flags with OSStatus, including application, package, alias and symlink flags. | The alias flag includes symlinks. Resolve POSIX symlinks before acquiring flags for opening, retain the original location for reveal, and establish equivalence with the existing native refusal set. No suffix or executable-bit inference supplies a flag. |
| Content type | `LSCopyItemAttribute` with `kLSItemContentType` is a native UTI acquisition; the SDK documents `kLSAttributeNotFoundErr` for a missing attribute. | A checked applicable missing-attribute report can carry established no-type; an arbitrary NULL or other error cannot. Current UTI/payload parity at long locations is unmeasured. Do not pass an unacquired type through the accepted nil non-refusal. |
| Identity and registration selection | `FSCompareFSRefs` documents equality of native objects, with `errFSRefsDifferent` as a distinct result. `NSWorkspace` supplies preferred and all registered URLs; each exact URL can be inspected component by component without converting an FSRef to a URL. | Check reference construction and comparison errors; preserve registration uncertainty and both enumeration orders. APFS reference performance and races remain native questions. A registration query for an identifier does not establish the selected bundle's currently declared identifier. |
| Bundle identifier | `CFBundleCopyInfoDictionaryForURL` is public and supplies a bundle-information dictionary. Public bundle structures explain conventional application metadata locations. | Neither that dictionary-only API nor the inspected LS item-attribute catalogue provides the needed selected-copy read/parse provenance. Historical CF source has path buffers and empty-dictionary failure branches. Component-relative metadata parsing is a candidate, but native bundle-layout/identifier equivalence and unchanged read behavior must be established before adopting it. |
| Exact-item default handler | `LSGetApplicationForItem` consults the item's binding, including a user override; the SDK documents `kLSApplicationNotFoundErr`. Its app-reference and app-URL outputs are separately optional. | This is a stronger candidate than the existing URL-or-nil result, not a type/extension fallback. Establish target/handler identity, output validity and long-item parity; first-use prompts remain unmeasured. An applicable checked not-found report alone can justify NO_DEFAULT_HANDLER. |
| Submission | The existing public NSWorkspace primitives take an application URL, document URL or Finder path. Reusing them preserves configuration, acknowledgment and the supplied document/reveal location at Koine's call boundary. | Those signatures do not prove processing/delivery of the required long URLs. Application submission must use the exact selected registered URL, with running-copy substitution disabled for a constrained request. Shortened links/file-reference spelling are excluded; a public legacy primitive needs complete configuration, location, acknowledgment, receipt and receiver parity. |
| Receipt executable identity | Public `proc_pidpath` returns executable-path text; component-relative identity lookup could avoid the adapter's subsequent whole-path resource lookup. | The public maximum buffer is 4096 bytes, independently of the 8192-byte search value ceiling. Published XNU also performs whole-path vnode revalidation. Callback executableURL, live path acquisition and identity lookup must each succeed for the required long app. Increasing the buffer does not prove this; systematic length-caused null remains unaccepted. |

These are API contracts and source observations. None establishes that an opaque
service internally avoids converting a reference back into limited path text.
Known incorrect native results still fail acceptance; successful status is a
reported fact, not proof of platform health.

## Measured reconciliation

The source candidates above now have the following bounded native results.
Keep acquisition, diagnostic submission and accepted provider behavior distinct.

| Obligation | Prototype result | Returned design consequence |
| --- | --- | --- |
| Presence and cause | Component-relative POSIX calls reached long subjects and distinguished missing/below-file, active cycle, exhausted link budget and isolated impossible ASCII component. | A usable local mechanism candidate; preserve the reviewed cause interface. Prompt/policy and general native equivalence still require acceptance. |
| Native flags/type and identity | Parent-built FSRef failed once cumulative path length exceeded 1,023 bytes; URL item information/resource keys also failed. Short Safari's component-built reference differed from the whole-path route. | Neither reference representation nor a larger URL string supplies classification. Reference equality and exact-item binding were unreachable, not passing. No suffix, permission-bit or guessed metadata replacement. |
| Identifier | Relative conventional plist reads distinguished errors and matched Bundle for 79 installed apps, all using that layout. | A sample, not native bundle-layout equivalence or approved content-read policy. It does not repair missing flags, registration or submission. |
| Registration/selection | Long registration failed; measured registered enumeration did not expose the long copies. | Constrained long-copy selection is not established. Never omit the path or choose a short copy. Short selection regressions with long candidates remain required. |
| Default handler | Existing long documents returned nil; the default-open diagnostic then stopped and labelled its result "no-handler". | That label is not NO_DEFAULT_HANDLER evidence: no supported applicable lookup was established and no default submission occurred. [Apple's nil contract](https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication(toopen:)-7qkzf) already combines missing target and missing handler. |
| Original-byte submission | Witness delivery at 1,023 bytes matched submitted bytes; 1,024 failed with Cocoa 256 and no witness delivery. Zed open at 1,498 and constrained launch at 1,508 also failed; Finder reveal at 1,498 returned NO. | Tests locate a boundary for those calls/subjects. They bypassed missing prerequisites as API diagnostics, so they pass no action row. Default/Zed/reveal/constrained long working cases remain unmet. |
| Receipt and prompting | No long app launched; exact-item binding and long lookup prompt reachability were not established. | Long receipt identity and first-use handler/prompt subjects remain pending. No systematic null receipt or prompt-free conclusion follows from early API refusal. |

The decisive raw records are [1,023-byte delivery](long-action-route/results/submit-thr-open-1023.json),
[1,024-byte refusal](long-action-route/results/submit-thr-open-1024.json),
[default lookup stop](long-action-route/results/submit-doc-long-default.json),
[Zed submission](long-action-route/results/submit-doc-long-zed.json),
[constrained launch](long-action-route/results/submit-launch-long-cold.json) and
[Finder reveal](long-action-route/results/submit-reveal-long.json).
These records were re-read for this design; no native measurement was repeated.
The prototype's one guest/build, prerequisite bypass, missing alias fixture,
discarded runs and void binding row retain their stated limits.

## Representation and ownership

Separate the public observed pathname from the private operands used to resolve
it. A directory descriptor plus one component is a supported local-access
candidate already measured in k134. Its use inside one action need not change
the public location string or keep a search-time file alive. Component lists
are resolver working state. Exporting retained directory handles would add
server state, expiry/restart/revocation and stale-selection rules; it is a
different public contract and would still require a cooperating opener.
No such change is selected. This is a bounded interface assessment, not proof
that every macOS interface lacks a parent/name input.
The completed application synthesis adds cooperating component protocols and
an explicit receiver boundary. Its [bounded applicability map](../research/long-pathname-applications.md#7-koine-applicability-map)
supplies no complete retained route. The SDK clarification below distinguishes
arrays of whole native items from components of one pathname.

Workspace owns presence, native classification/selection and submission behind
the existing private action adapter. The resolver can hide descriptor lifetime,
link-expansion work and cause provenance from callers. Its descriptor is
process-local and cannot be supplied to NSWorkspace's URL/path APIs. XPC fd
transfer serves cooperating peers; Finder, Zed and arbitrary default handlers
have no demonstrated matching interface. Passing an array or fd moves caller
obligations without satisfying the existing launch/open contract.

The other surveyed representations do not supply an adopted repair:

- Ordinary bookmarks resolve back to URLs; long-item creation/resolution and
  opener delivery are unproved. Security-scoped variants require a new posture.
- Public file-reference URLs may be assessed as transient internal operands.
  Submitting an identity-spelled URL instead of the original selected pathname
  is the excluded spelling change; merely creating a reference internally is
  not that exception. Manually constructing volfs/file-ID spellings remains
  unselected. [Apple's kernel test](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c)
  supports volfs *file opening*, not NSWorkspace delivery/registration/receipt
  behavior; [Apple DTS](https://developer.apple.com/forums/thread/103162)
  cautions against relying on it where fsgetpath is available.
- Short links/aliases, another app copy and the private
  long-path policy remain excluded. Public deprecated openers require complete
  retained-contract parity; deprecation alone does not exclude them. Policy on Koine alone would not establish
  behavior in the separate service and receiver processes.

The survey's unauthorized host leads are not design evidence and were not rerun.
An excluded representation could be reconsidered only by a concrete new decision;
its kernel reachability alone would still leave classification, selection,
delivery, receipt and no-prompt behavior unproved.

## Application research reconciliation

The synthesis's corrections bind this disposition: shared-source agreement is
not independent execution; a Linux 1,500-byte success is below its usual lookup
limit; Windows opt-in and archive-record capacity are different subjects. The
GNU tar descriptor-recovery defect and restic metadata regression show why
recovery and every fact consumer need independent checks. Neither is evidence
that a macOS opener works.

| Mechanism | Supported scope | Remaining retained obligation |
| --- | --- | --- |
| Directory descriptor and short name; component protocols | Owned local access; cooperating NFS/9P/FUSE endpoints walk components. k134 measured the local POSIX route. | Native flags/type, bundle-identifier provenance, registration, exact-item handler, opener and receiver access. Preserve descriptor bounds, recovery, symlink/dot semantics and prompt policy. |
| Zed CLI strings over IPC | A real document side channel at the surveyed pins. | Its receiver canonicalizes and loads by whole path. Delivery alone does not establish the required real Zed document opening, exact registered copy or Koine receipt. |
| Native item-reference arrays | SDK 27.0 declares LSOpenItemsWithRole and LSLaunchFSRefSpec.itemRefs. | Acquire applicable long FSRefs, establish legacy opener parity and receiver handling. These are whole item references, not parent/name or component inputs. |
| fsgetpath | Public long-text observation from native identity, already selected by search. | Text observation supplies neither opener submission nor executable identity of an arbitrary live process. proc_pidpath re-enters whole-path lookup. |
| Bookmarks, identity spelling and short virtual namespaces | Real persistence/cooperating or mapped-namespace mechanisms in the corpus. | Original submission spelling, classification, registration, receiver access, receipt and policy equivalence. Excluded/new-posture choices still need Antony's decision. |

### Opener and receiver are separate obligations

The pinned [Zed real filesystem backend](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs)
loads text with `std::fs::read_to_string`, bytes with `std::fs::read`, and
canonicalizes through `std::fs::canonicalize` on macOS. The
[CLI receiver](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/zed/src/zed/open_listener.rs)
accepts full path strings and opens workspaces/items through that filesystem
boundary. These branches were re-read for k141. Their over-limit consequence
under the retained process posture is source-derived, not a new native Zed run.
Changing Koine's string transport does not replace Zed's filesystem operations.

The [independent working subjects](long-action-native-boundary.md#independent-subjects-for-the-route-design)
retain real default/Zed document delivery/rendering and Finder selection
observations. A witness logging a URL proves only delivery to that witness.
Neither that log nor an acknowledgment closes the real application working case.
This clarifies acceptance, without expanding the public receipt into a guarantee
of rendered content or narrowing acceptance to successful submission.

The reviewed private WorkspaceNative enabling point remains the existing seam.
Workspace owns local resolution, fact acquisition, selection and submission;
the external receiver owns its filesystem work. An adapter substitute cannot
prove external receiver behavior. Exposing components/fds to GraphQL clients
would add obligations without giving NSWorkspace or arbitrary receivers a
matching protocol. No new public seam or generic extension layer is justified.

### SDK item-array clarification

The macOS 27.0 SDK's LSOpenDeprecated.h documents
[LSOpenItemsWithRole](https://developer.apple.com/documentation/coreservices/1449783-lsopenitemswithrole)
as accepting an array of FSRefs and sending an open-documents event. Its
LSLaunchFSRefSpec contains a selected appRef and itemRefs array. Thus a blanket
claim that macOS has no native item-array opener would be incorrect. The
synthesis's macOS counterpart question is narrowed, not credited as a route.

The input to each array is an already constructed whole native item reference.
k134's tested FSPathMakeRef and FSMakeFSRefUnicode constructions failed for
long locations. Public [catalog enumeration](https://developer.apple.com/documentation/coreservices/1566447-fsgetcataloginfobulk)
also returns FSRefs. k143 now measures that branch: an exact-name reference is
returned at 1,024 bytes, while catalog/fact/handler consumers and directory
iteration fail. The 1,500-byte objects are unreached. Neither legacy item-array
opener was executed by k143; later k146 measured both and found exact delivery
at 900/1,023 bytes and -41 with no event at 1,024. That later result is
submission evidence for the short recorder, not inference from catalog failure.
FSRef bytes remain opaque; no handmade
reference is admitted. Deprecation alone rejects nothing, and the tested failures
do not prove every reference-acquisition route impossible. A supported complete
legacy route would still owe the retained configuration, exact-copy, grant,
acknowledgment, receipt and receiver contracts before adoption.

### Disposition of the synthesis's open questions

| Question | Returned design disposition |
| --- | --- |
| Q1: delivery or real document opening? | Retain independent real-application delivery/rendering and selection observations. Public acknowledgment stays narrower. No acceptance weakening is selected. |
| Q2: parent/name or item-sequence opener? | The inspected NSWorkspace open/launch/reveal inputs are whole URLs/paths. Legacy FSRef item arrays exist; long acquisition and end-to-end semantics remain gaps. No parent/name/component opener is established by these headers. |
| Q3: object identity instead of proc_pidpath? | Unresolved. Cwd/root/fd/mapped-region statistics or executable UUID alone do not identify the exact running installation under the retained observation rule. No replacement receipt rule is selected. |
| Q4: long-copy registration? | Unresolved. k134's registration failed; no applicable source or successful registered-copy route is established. |
| Q5: prompt-free component reads? | k134 prompted at Documents. The local mechanism is a candidate beneath the existing policy, not a new protected read approval. Protected default lookup remains its separate human decision. |
| Q6: Apple receiver long-path policy? | Unknown. The published private-policy gate does not establish which closed Apple processes opt in, or change the policy of Zed/default handlers. |

The residual is precise: native fact acquisition and registration/selection;
an unchanged-location opener handoff; the real receiver's subsequent operations;
and exact executable-identity observation. A solution for any one must not be
credited for the others. The current source and measurements leave these
required stages unresolved; this is no theorem about every macOS interface.

### Internal native-reference investigation

Antony's instruction to "continue with our own investigation" supersedes the
external inquiry path. The inquiry texts below remain unused drafts. No sender,
account connection or upstream response is needed to run this investigation.
The new authorization covers bounded public source/SDK work and one disposable
guest diagnostic for the specific acquisition question below. It changes no
working case, input spelling, consent, setup, private policy or receipt rule.

The SDK 27.0 read narrows the alternatives:

| Candidate | Applicable public evidence | Disposition |
| --- | --- | --- |
| Flat catalog enumeration | CarbonCore `Files.h` declares `FSOpenIterator` and `FSGetCatalogInfoBulk`, with returned names, catalog information and opaque FSRefs. Its comment requires `kFSIterateFlat`. Apple's [retired iteration guide](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/FileSystem/Articles/IteratingFiles.html) demonstrates that flat pattern and describes opening further iterators for descent. | k143 followed named fixture children. Enumeration returns references at 1,024 bytes, but the tested consumers reject them and descent stops before 1,500 bytes. Closed as a complete acquisition route for these subjects. The HFS-oriented guide is no current APFS or long-path guarantee. |
| Resolve a native node ID | `Files.h` declares [FSResolveNodeID](https://developer.apple.com/documentation/coreservices/1565623-fsresolvenodeid) with a Carbon volume reference and `UInt32` node ID. | A native catalog volume/node pair is a legitimate diagnostic input. It must first be acquired; this is not an independent descriptor-to-reference route. Never truncate a 64-bit inode or construct FSRef bytes. |
| Obtain that node ID from descriptor attributes | SDK `sys/attr.h` and pinned [XNU attr.h](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/sys/attr.h#L220-L224) say the 32-bit `fid_objno` fields are undefined when the volume advertises `VOL_CAP_FMT_64BIT_OBJECT_IDS`; only `ATTR_CMN_FILEID`/`ATTR_CMN_PARENTID` supply legitimate object IDs there. | The proposed `fgetattrlist` → 32-bit cast → `FSResolveNodeID` shortcut lacks supported identity. A valid 64-bit file ID is not a Carbon node-ID conversion. Record the volume's valid/capability bits and preserve native catalog provenance. |
| Bulk subtree scan | `FSGetCatalogInfoBulk` requires a flat iterator. `FSCatalogSearch` instead requires a subtree iterator rooted at the volume root. | No volume-wide scan is commissioned. It would introduce unrelated traversal, cost and protected-access questions. |
| Volume/parent/name `PBMakeFSRefSync` | The SDK encloses this older entry point in `#if !__LP64__`. | It supplies no arm64 route. This differs from the public deprecated FSRef array openers, which are declared under `TARGET_OS_OSX`. |

The following charter describes the completed k143 diagnostic. Its result and
current decision are below; these bounds commission no repeat.

The focused question was: **can a flat catalog walk return the exact original
file/directory as a usable opaque FSRef at 1,024 and roughly 1,500 bytes, when
the tested path and parent/name constructors fail?** Usability means successful
native comparison/catalog consumption, not a nonzero buffer or URL conversion.
The walk starts from one short fixture-root reference and opens a new flat
iterator only for the selected returned directory. It never reconstructs the
whole long path to advance. Record the first failed acquisition or consumer
stage, returned count, names, `containerChanged`, native status and cumulative
original UTF-8 length. A returned reference does not imply later APIs avoid
whole-path reconstruction.

The finite subject is eight independent, component-created fixtures: an ordinary
file and directory at each of 900, 1,023, 1,024 and 1,500 UTF-8 bytes, excluding
NUL. All individual ASCII names are valid. Use a short same-object reference
control, a same-parent decoy and a completed missing-name iteration control.
Request at most eight entries per batch, four batches per fixture directory,
32 selected-directory levels and one live iterator. Bounds or unexpected
contents terminate the diagnostic as incomplete; they do not prove absence.
Process valid returned entries on `errFSNoMoreItems`, and distinguish that
completed iteration from another error. Close all iterators/descriptors.
The whole diagnostic permits at most two builds, two collection attempts of
this same fixed corpus and one instrumentation repair. Retain every attempt's
raw output and the reason for any repair; never merge runs into a cleaner result.
An external watchdog limits each native-case helper to 30 seconds, with at most
five additional seconds for termination. The guest session, from clone-start
request through teardown, has a 15-minute elapsed cap. Exhaustion, a blocked
call or an uncorrected short-control failure ends as incomplete. No alternative
guest/API route, added subject or later automatic retry is commissioned.

For acquired references, record `FSGetCatalogInfo` and `FSCompareFSRefs`
results and narrowly attempt reference-based item flags/content type and exact-item
preferred-handler lookup. Record each native status independently. Neither a
failed call nor an unacquired/null output proves no type or no handler. Test
`FSResolveNodeID` only using a successfully returned native catalog volume/node
pair, then compare its returned reference with the enumerated reference. This
can test that resolution's consumption behavior, but cannot claim a new way to
acquire the original node ID. Do not convert the long reference to a short
identity spelling or submit it to an application in this probe.

Use one disposable macOS guest and a minimal signed helper with the earlier
prototype's ordinary process/privacy posture. Record OS/build, SDK/compiler,
architecture, filesystem, signing/entitlements, actual volume capability bits,
source/binary digests and observed dialogs. No protected Documents/Desktop tree,
TCC reset/approval, private policy or new long-path entitlement is permitted.
The fixture body is test data, not permission to read production documents.
Unchanged host files are not subjects. A guest/tool or short-control failure
is recorded; it does not trigger another platform or automatic investigation.

The first child `native-reference-acquisition-k142` records this source
disposition and finite charter. `native-reference-acquisition-k143` executes the
throwaway diagnostic and presents the observed result for Antony's reaction;
`long-action-route-k144` consumes it as the retained final design. There is one
probe and one returned-design step, not a repeat-until-success series. The route
node `long-action-route-k141` remains live. A negative/incomplete result returns
the exact residual gap, while a positive result earns only the stages measured.
Long app-copy identity/registration, opener parity, real receiver operations,
Finder selection and receipt identity still owe their original evidence.
Only a complete route earns k128's mandatory final review before consumers.
The commissioning session ran no native measurement. Its one fresh
adversarial charter read identified the missing aggregate execution bound;
the limits above resolve it without changing APIs, subjects or privacy posture.

**Result (k143):** see the [native reference acquisition report](native-reference-acquisition.md). Flat enumeration
returns references past 1,023 bytes, but `FSGetCatalogInfo` (-43), the Launch Services reference calls (-41) and
`FSOpenIterator` on a returned directory (-43) fail from 1,024 bytes, so the 1,500-byte subjects were not reached.
Antony accepted this result; k144 returns the remaining gap.

### Native-reference result and remaining gap

Antony's reaction was **"Accept; k144 returns the gap"**. This closes k143's
finite diagnostic, not the retained route. The
[report](native-reference-acquisition.md) and both raw collections remain intact.
Re-reading the repaired helper and per-case records gives these stage boundaries:

| Subject | Last established stage | First failed consumer / effect on design |
| --- | --- | --- |
| File and directory at 900 and 1,023 bytes | Exact name and same-parent decoy returned; short independent constructor/comparison controls pass. Catalog, flags/type, handler and catalog-derived node resolution succeed; the directory's inner entry is reached. | No acquisition failure in these subjects. No opener was submitted. |
| File and directory at 1,024 bytes | Final flat batch returns both exact names with `errFSNoMoreItems`, two entries and no reported container change. | `FSGetCatalogInfo` returns -43; flags/type and handler calls return -41. Directory `FSOpenIterator` returns -43. These are native fact/directory acquisition failures, not absent items, no type or no handler. |
| File and directory at 1,500 bytes | The walk returns the named intermediate directory at 1,258 / 1,257 bytes. | Catalog consumption there returns -43; the next `FSOpenIterator` returns -43, with no next batch. The final objects and their consumers are unreached. Run 1 stopped at an instrumentation gate; run 2, after the sole repair, establishes this iterator stop. |

At 1,024 bytes the same-byte FSRef copy compares equal and the decoy compares
different. That is native comparison behavior, not an independently acquired
long same-object control or proof that the reference can classify, open or reveal
the object. `summary.json`'s `complete` means the finite collection finished;
`acquired` means a named reference was returned. Neither means a working route.
The attempted next component's cumulative length in a failed iterator record
is not a reached object length.

The process was an ordinary signed accessory helper on macOS 26.5/25F71 arm64,
APFS with valid/set 64-bit object-ID capability, built with SDK 27.0. Both
collections retain their source/binary/environment digests. No protected tree,
new consent or private policy was used; end screenshots show no dialog for
these subjects, not all possible protected reads. Both builds/collections and
the one repair are spent. No further probe ran in k144.

The public SDK supports returning references separately from consuming them.
Its flat-iterator requirement and the retired HFS example do not promise that
each APFS reference consumer supports these lengths. `FSResolveNodeID` still
requires native catalog volume/node provenance: k143 tested it only after a
successful catalog report at or below 1,023 bytes. The failure does not license
an inode cast, opaque-byte reconstruction, volume scan or reference-URL rewrite.

The retained gaps remain independent:

| Required capability | Current evidence / exact gap |
| --- | --- |
| Native facts and cause | Local relative access works; neither tested reference acquisition path supplies all long flags/type/bundle facts. Checked missing/cycle/name-limit and established-nil meanings remain required. |
| Long registered copy and selection | k134's registration failed. k143 creates no apps or registrations and supplies no selected-copy identifier/identity route. |
| Original-location submission | NSWorkspace diagnostic failures remain. k146 later measured both item-array openers: 900/1,023-byte spelling delivered, 1,024-byte calls -41 with no event. k143's walk cannot supply their 1,500-byte inputs. |
| Real receiver and Finder | No long document was delivered by k143. Zed's pinned whole-path backend remains a separate source-derived obstacle. No Finder selection or real default/Zed rendering pass follows from enumeration or witness delivery. |
| Executable identity and receipt | No long app launched. A legacy ProcessSerialNumber or launched FSRef alone does not establish the retained PID/start-instant and executable-identity receipt. |

No source or result establishes the complete retained route. Keep k144 and
k141/k135/k130/k128 live; k147 now owns the retained final returned design.
k128's final review is owed only after that route exists.

<a id="proposed-item-array-submission-diagnostic"></a>

### Completed authorized item-array submission diagnostic

**Completed in k146.** Antony answered **"authorised"** on 2026-10-05 to
this exact finite charter. The [report](item-array-submission.md) retains both
collections and the sole recorder repair. Both openers delivered the original
spelling at 900/1,023 bytes; both returned -41 at 1,024 without a recorder event.
The bounds below describe the spent diagnostic, not permission to repeat it.

SDK 27.0 `LSOpenDeprecated.h` declares two applicable inputs:
`LSOpenItemsWithRole` takes whole FSRefs and optional `LSApplicationParameters`
naming an application; `LSOpenFromRefSpec` takes `LSLaunchFSRefSpec` with appRef
and itemRefs. The first documents `odoc` delivery and optional PSN outputs;
the second returns an optional launched FSRef. The headers recommend
NSWorkspace. Public declaration/deprecation supplies neither long behavior
nor full configuration, cancellation, exact-copy or receipt parity.

The same SDK defines `LSApplicationParameters.version` as zero. With an explicit
application reference, `LSOpenItemsWithRole` ignores the role mask; use
`kLSRolesAll` without asking default-handler selection to supply the receiver.
`LSOpen.h` defines `kLSLaunchDefaults` as open/async and identifies
`kLSLaunchAndDisplayErrors` as UI error reporting. Use the public defaults in
both structures, with optional event/environment/argv/refcon parameters null;
do not substitute a guessed zero flag or error UI. These are declaration and
call-configuration checks, not native behavior or complete production parity.

The concrete diagnostic boundary is:

- One disposable macOS guest, ordinary signed helper and short-path recording
  application; SDK/compiler/OS/build, filesystem, signatures, entitlements,
  source/binary and input/output digests recorded. Test data only in an
  unprotected fixture tree; no consent/reset, private policy, usage keys,
  protected content, long-copy registration, default-handler changes or external inquiry.
- Three independently component-created text files at exactly 900, 1,023 and
  1,024 original UTF-8 bytes excluding NUL, plus same-parent decoys. Reconstruct
  transient references by k143's flat named-child walk in the submitting
  process. No long constructor, URL/reference conversion, shortened path,
  handmade bytes or alternate acquisition advances the walk.
- Exactly one document per call, through each of the two named openers to the
  same explicit short recording-app reference: six calls per collection.
  Verify the short app reference independently. Preserve short same-object,
  decoy and absent-name controls. Use verified public async/default launch
  flags, without error-display UI or a direct Apple Event fallback.
- Record each API's status, timing and valid output independently of listener
  evidence. The recording app logs received URL/path bytes and event counts;
  an independent reader compares them with the component-created fixture's
  original byte spelling and decoy. The 900-byte calls run first as listener
  controls within the six-call corpus. A success status
  without exact delivery is not a delivery pass; missing output is not an
  established failure cause or receipt. Stop on an unexpected dialog.
- At most two builds, two collections of that fixed corpus and one proven
  instrumentation repair: at most 12 opener calls in total, with a second
  collection allowed only after that repair. Retain every attempt and its reason. Bound the
  guest session from clone-start request through teardown to 15 minutes and
  each case to 30 seconds plus five seconds termination grace. Keep k143's
  32-level/eight-entry/four-batch/one-iterator acquisition limits. A short-control,
  tooling or bound failure returns incomplete; no alternate API/guest retry.
- Return the result and a retained-design reconciliation to Antony. A positive
  1,024-byte delivery earns only this consumer/subject. It does not acquire
  1,500-byte references, native facts, default binding, long registration,
  real Zed content access, Finder selection, grant/cancellation parity or long
  receipt identity. A negative closes only these tested opener paths. No
  automatic later probe, implementation leaf, final review or node closure.

This is an API diagnostic with deliberately unestablished production
prerequisites, as in k134, not a Koine action. Its value is resolving a precise
remaining consumer question; its cost is another bounded experiment that cannot
alone satisfy the original route. Keeping the route pending spends no further
measurement but yields no new evidence. Investigating a short same-object
namespace was outside that item-array charter. Antony later authorized only
the exact finite [bare-object diagnostic](#authorized-finite-same-object-namespace-diagnostic);
no production exception or additional setup is adopted.

k144 is decomposed in place: `item-array-submission-k145` completes this
source/charter handoff, `item-array-submission-k146` executes the one throwaway
diagnostic and obtains Antony's reaction, and `long-action-route-k147` consumes
the committed result as the retained final design. The first child's completion
advances the loop only to the prototype; no route node closes. There is no
repeat series or implementation leaf, and k147 still owes the full original
route and k128's mandatory final review before downstream consumers.

### Item-array result and representation assessment

Antony reacted: **"ChatGPT research says we should use (directory handle, path
component) for our representation of file system locations, specifically to
avoid this. We can also use URL/NSURL with file-reference URLs as a mechanism."**
Assess those two candidates under the retained requirement. The reaction
commissions no new native experiment or submission-spelling exception.

The [actual report](item-array-submission.md) and raw records establish a narrow
consumer boundary. In repaired run 2, both 900-byte calls delivered a bookmark
that also coerced to a file URL. At 1,023, both delivered a bookmark whose stored
path matched the fixture exactly; the recorder also logged a resolved path,
but neither reading establishes real receiver content access. Run 1's missing
raw bookmark leaves its 1,023 observations ungraded. At 1,024 both calls return
-41, with no recorder launch/event. SDK 27.0 MacErrors.h names -41 `mFulErr`;
that name proves neither memory exhaustion nor the internal rejecting layer.
The summary's `firstFailedStage: null` is not a pass: the raw call status
establishes submission refusal. Twelve calls, two builds/collections and the
sole recorder repair are spent. No native call was repeated in k147.

| Representation | Owner and caller obligations | What is supported / what remains open |
| --- | --- | --- |
| Original observed pathname plus private directory descriptor/name | Workspace re-resolves at each action, keeps exact input text apart from lookup operands, bounds and closes descriptors before completing; clients continue sending the pathname. | k134 establishes local relative access. Preserve component/link/dot/trailing semantics, cause provenance, prompt policy and no search-time pinning. Native flags/type/bundle facts, registration/handler, external submission, receiver access and receipt remain separate acquisitions. |
| Retained directory handle plus component exposed to clients | Server owns handle lifetimes, process restart/expiry, grant interaction and changing parent/name associations; callers need a stateful protocol. | Could address a cooperating consumer, but changes current location semantics and adds state without an established NSWorkspace/receiver adapter. Not selected; no new public seam is justified by the measured local need. |
| Transient public file-reference URL, with original text retained separately | Workspace owns native creation, actual same-object verification, conversion failures and lifetime. No serialized reference survives a restart/remount and no reference string is handcrafted. | NSURL/CFURL offer supported creation APIs distinct from FSRefs. k149 subsequently passed acquisition/local reading/original bytes at 900/1,023 but failed acquisition at 1,024/1,500. Long local I/O and later native facts/submission were not reached. Sending an identity URL externally still needs a separate spelling decision. |

The SDK's NSURL.h declares `fileReferenceURL`, `filePathURL` and relative file
URL constructors. CFURL.h declares `CFURLCreateFileReferenceURL`, with an error
output, and `CFURLCreateWithFileSystemPathRelativeToBase`. These are not
`CFURLCreateFromFSRef`/`CFURLGetFSRef`, which that SDK marks unsupported.
[Apple's file-reference documentation](https://developer.apple.com/documentation/foundation/nsurl/filereferenceurl%28%29?language=objc)
defines object-oriented URLs, requires reachable objects, allows generation
failure and limits their lifetime across restart/remount. It supplies no
overlength or opener-delivery guarantee. A relative URL is also not a POSIX
directory descriptor: construction/resolution may still recover whole paths.

Historical [CF-1153.18 URL source](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFURL.c#L4486)
attempts file-path conversion when appending a component to a reference URL.
Its absolute-URL code also converts a reference base without a directory slash.
This is concrete counterevidence to assuming a parent-reference append always
retains a short identity anchor, not a claim about current macOS implementation.
The published file-reference factory is a stub in that open-source snapshot;
it cannot establish Darwin's implementation. Source/SDK support therefore
justifies a candidate diagnostic, not a working route or a universal failure.

**Recommendation before k149:** use descriptor/name as the private local-resolution design
candidate, preserve the public observed pathname, and investigate public
file-reference URL acquisition before any external submission. The alternative
is to keep the original route pending without another measurement. Exporting
handles or trying identity-spelled opener submission is a different contract
decision. No ADR selects any unestablished complete mechanism.

<a id="proposed-file-reference-url-acquisition-diagnostic"></a>

### Authorized file-reference URL acquisition diagnostic

**Executed in k149; bounded result, no complete route.** The [actual report](file-reference-url-acquisition-prototype.md)
records the first instrumentation stop and expressly authorized replacement.
Antony answered **"authorized"** on 2026-10-05 to the exact finite proposal. This is one experiment to answer
whether public URL factories can acquire and locally consume the original long
object without an FSRef. It performs no opener, Finder or registration request
and adopts no spelling, setup, consent, private-policy or contract exception.

- One ordinary signed throwaway helper in one disposable macOS guest; record
  OS/build/architecture, filesystem/capability bits, SDK/compiler, signature/
  entitlements and source/binary/input/output digests. No protected content,
  usage keys, TCC reset/approval, private policy, long app/default registration,
  external inquiry, cwd change or production edit. An unexpected dialog stops it.
- Exactly four component-created ordinary text files at 900/1,023/1,024/1,500
  original UTF-8 bytes excluding NUL, valid ASCII components at most 245 bytes,
  unique fixed markers and same-parent decoys. Independent `openat`/`fstat`
  controls establish each target and decoy's full native device/inode identity.
  Keep a short independently constructed same-object control and a missing-name
  conversion control; missing/error outputs never become an absence claim.
- Two acquisition cases per file, eight per collection. First, create a path
  URL with the original spelling and request `CFURLCreateFileReferenceURL`.
  Second, acquire a short root's native reference URL, form each child with
  `CFURLCreateWithFileSystemPathRelativeToBase` using its exact single component
  and known directory flag, then request a fresh native reference for that
  child before advancing. Record each level's reference predicate, returned
  URL/base forms, cumulative original length and CFError; do not advance after
  failure. Check each returned reference anchor has no base URL before using
  it for the next level; an observed retained base chain ends as incomplete.
  Use no appending-path convenience, hand-built file-ID/volfs string, FSRef bridge,
  bookmark fallback, fd namespace or alternate acquisition API.
- A non-null URL or reference predicate is not a usable-object pass. For each
  acquired final reference, separately attempt public
  [NSFileHandle URL opening](https://developer.apple.com/documentation/foundation/nsfilehandle/filehandleforreadingfromurl:error:),
  compare `fstat` of its descriptor with the independently opened target and
  decoy, and read only the fixed fixture marker (at most 64 bytes). Record path
  conversion through `CFURLCreateFilePathURL` separately, including exact
  original-byte comparison; conversion success alone earns no I/O pass. Never
  pass converted whole-path text back into lookup to make a case succeed.
- At most 32 selected levels, three live descriptors (independent parent,
  target/control and URL consumer), and three caller-owned URL objects:
  the current base-free anchor, relative child input and replacement reference
  during a swap. Record then release the child and old anchor before advancing.
  Serialize and release logging/path-conversion temporaries within the same
  three-object ceiling; inspect base URLs without retaining them. These are
  owned-object bounds, not a claim about opaque Foundation allocations.
  Limit recorded URL text to 8,192 bytes per value. Oversize,
  short-control, instrumentation or tooling failure returns incomplete. The
  helper exposes first failed stage, typed errors and bounds, closes owned
  resources and runs under an external 30-second watchdog per acquisition
  case plus five seconds termination grace.
- At most two builds, two collections of the identical corpus and one proven
  instrumentation repair: at most sixteen acquisition cases. A second
  collection follows only that repair, never a different API/subject/guest
  strategy. One clone-through-teardown aggregate cap of 15 minutes; stop and
  retain all attempts on exhaustion. A returned design consumes the result and
  Antony's reaction, without automatically commissioning another experiment.

A positive earns only the measured acquisition/local URL consumer and identity
controls. It supplies no native payload facts, bundle-identifier provenance,
exact-item default binding, long registration/copy selection, external original-
byte delivery, real Zed/default rendering, Finder acknowledgment/selection,
grant/cancellation parity or executable receipt. Restoring the original path
before external submission leaves the known handoff problem; sending a
reference URL instead is expressly outside this charter. A negative is bounded
to these two creation patterns and their local consumer on that guest build.
Keep k147 and every route ancestor live until the retained complete route exists;
the final k128 review and both action/search acceptance sets remain owed.
The authorized source/charter handoff is k148, followed by the single prototype
file-reference-url-acquisition-k149 and retained returned design
long-action-route-k150. Completing the handoff or prototype closes no route node.

### URL result and next workaround

**k149 is complete; the retained route is not.** The
[actual report](file-reference-url-acquisition-prototype.md) and both collections
are the evidence. The first collection stopped before all acquisition cases
because its driver rejected numeric zero as a missing-name failure. The sole
verified correction and expressly authorized replacement ran all eight cases.
Both patterns acquired, locally read and recovered the original bytes at
900/1,023. At 1,024 the direct factory reports Cocoa 258 with underlying POSIX
63; the relative factory fails at the final child after acquiring its 1,013-byte
parent. At 1,500 direct creation reports Cocoa 258 without an underlying cause
in the record; relative creation fails at a 1,253-byte directory prefix. Treat
these as typed native failures of the measured acquisitions, never absence or
proof that every public mechanism fails.

Successful anchors were base-free. The helper's three descriptor/three
caller-owned-URL limits do not bound opaque Foundation allocations. Independent
descriptor/decoy and fixed-marker controls passed. Short hard links were controls
only, not fallback operands; they limit the fixture population. There was one
build, two collections, one driver correction and two expressly authorized
guests. Their 19.69/22.20-second intervals are separate, not one continuous
aggregate measurement. Sampled UI snapshots showed no dialog; they prove no
general prompt-free behavior. Neither factory reached long local consumption,
native facts, registration/handler, submission, receiver/Finder or receipt.
This returned design performs no new native measurement.

| Stage | Current evidence | Concrete work still needed |
| --- | --- | --- |
| Local path resolution and cause | Component-relative access works on k134's long subjects. k149's URL factories fail long acquisition. | Preserve the bounded per-action resolver, original text, no-prompt policy and reviewed absence/failure provenance. |
| Native facts and selection | Tested long fact/handler/reference and registration routes failed or were unreached. | Acquire native flags/type/identifier with cause provenance, exact-item binding and the exact registered long app copy. |
| Handoff and receiver | Tested URL and item-array openers did not deliver long subjects. Pinned Zed reads/canonicalizes by whole path. | Establish a usable operand through the opener and real default/Zed reading; independently observe actual Finder selection. |
| Receipt | No long app launched; existing process/executable acquisition is not repaired. | Preserve PID/start-instant and exact executable identity, including short actions with long registered copies; accept no systematic length-caused null. |

#### Same-object namespace candidate

The pinned [XNU lookup branch](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/vfs/vfs_lookup.c#L373-L447)
recognizes legacy volfs paths and expands its lookup buffer up to MAXLONGPATHLEN
without gating that branch on the process's long-path policy. Its
[parser](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/vfs/vfs_lookup.c#L2312)
accepts a native volume/object pair. Its remaining-filename branch appends with
a fixed MAXPATHLEN bound even after expanded path acquisition; the
parent-object/final-name variant therefore is not the proposed long route. The
[upstream long-path test](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c#L659-L694)
opens an object via `/.vol/<device>/<inode>` and compares full device/inode
identity. The [test dispatch](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c#L1091-L1133)
uses the long-success expectations with policy both off and on. This is pinned
source/upstream-test evidence, not a Koine guest result or a public opener promise.

This gives a specific potential workaround: retain the client's original
observed path, resolve it afresh by components, and use a short native
same-object operand behind the private adapter. The authorized diagnostic uses
`/.vol/<native-device>/<native-target-inode>`, rather than a copied file,
hard link, symlink, renamed
directory or another application copy. Full native identity and marker checks
must establish what each operand actually reaches. No 32-bit Carbon node-ID
cast or fabricated FSRef/file-reference URL is involved.

There are three material limits. This bare operand does not preserve the final
filename/extension: resource classification and exact-item handler behavior must
be measured, never repaired by guessing a type. The kernel itself labels this a compatibility
path that may disappear, and [Apple DTS](https://developer.apple.com/forums/thread/103162)
recommends fsgetpath instead and disclaims lasting volfs support. Also,
[Zed's inspected reader](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs#L954-L970)
and [canonicalizer](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs#L1053-L1065)
may turn a short operand back into the rejected long whole pathname. A native
open success therefore cannot stand in for receiver rendering or save behavior.
This candidate is **outside the retained original-byte external-submission rule
and lacks its required durable supported-API assurance**. It is not selected
as a compliant production route. No native policy toggle or entitlement is
proposed, and no claim that all admitted alternatives are impossible is made.

<a id="proposed-finite-same-object-namespace-diagnostic"></a>

#### Authorized finite same-object namespace diagnostic

**Antony answered "authorized" on 2026-10-05** to this exact finite diagnostic.
That permits investigation of this named native-submission spelling/legacy-support
exception for known harmless fixtures only; it adopts no production exception.
The diagnostic tests a concrete long-object route through actual receivers.
Retain the absolute functional requirement and every original acceptance row.
The source/charter handoff was k151 and the prototype was k152; k153 consumes
its [actual incomplete result](same-object-namespace-prototype.md). The scope
below is the spent authorization record, not permission to repeat its commands.

- One signed throwaway helper in one disposable macOS guest, one collection,
  at most two builds and one proven instrumentation correction before collection.
  One 45-minute clone-through-teardown cap; no guest retry, second collection,
  alternate namespace/API strategy or automatic follow-on. Preserve incomplete
  results on failure/cap exhaustion. An unexpected consent/security dialog stops
  the run. Prepare only ordinary Zed/Finder first-run state already admitted by
  the baseline; unavailable preparation returns incomplete.
- Four independently component-created subjects: one text file and one ordinary
  directory at each of 900/1,500 original UTF-8 bytes excluding NUL. Valid ASCII
  components at most 245 bytes, at most 32 levels. Each directory has a uniquely
  named fixed-marker text child; each subject has a same-parent distinct decoy.
  Independent `openat`/`fstat` and at most 64 marker bytes establish the original
  target, parent and decoy. No short hard-link control, user file, protected path,
  remote mount or changed process cwd. Keep only three live helper descriptors;
  serialize controls, close resources, and log at most 8,192 bytes per value.
- Derive exactly the target-device/full-64-bit-inode operand above. Do not append
  a filename or add another spelling to rescue an unsuccessful case.
  Before any submission, independently reopen it, compare full target and decoy
  identity, and read the fixture marker or directory child. A failed identity or
  900-byte control stops as incomplete. Record path-URL representation, native
  resource flags/type and exact-item default-handler observations separately;
  no guessed extension/permission-bit fact or nil-as-absence mapping. Missing
  facts leave production prerequisites unresolved.
- For each subject attempt at most one default open, one named open to the
  exact known short registered Zed copy, and one Finder reveal: at most twelve
  external requests. Use the existing public NSWorkspace primitives/configuration
  with the proposed short same-object operand. A failed default-handler acquisition
  leaves that default row unrun, not NO_DEFAULT_HANDLER. Named/reveal diagnostic
  requests may bypass unresolved production metadata only for these known harmless
  fixtures and must label that bypass. Record the first failed stage, typed errors,
  exact submitted operand, any recoverable delivered operand and three-second
  acknowledgment/cancellation bounds. No retry under a different spelling/copy.
- Before each external request record a fresh receiver baseline. Close the previous
  fixture buffers/windows and clear Finder selection, then verify the subject/decoy
  is not already displayed or selected. When default and named receivers coincide,
  this reset is still required. If reset cannot be established, only independently
  attributable fresh delivery/read evidence can grade that request; residual UI
  without such evidence is unmeasured. Never inherit another request's rendering.
- Observe actual text/child rendering in default/Zed and actual Finder selection
  independently from acknowledgment or launch. Verify each observation identifies
  the original fixture rather than its decoy; an inaccessible observer returns
  unmeasured. Keep opaque delivered operands opaque. Do not weaken provenance by
  equating a title, witness URL, PSN or callback with successful original-object
  access. Record any pathname normalization and unchanged original marker/identity
  before/after; there is no save/write experiment or inferred save support.
- Record OS/build/architecture, fixture volume/capabilities, installed Zed version,
  SDK/compiler, signature/entitlements, inputs, exact raw outputs, before/after
  per-subject digests and native/UI observation provenance. Sampled no-dialog
  observations are not a general no-prompt promise. Stop/dispose the guest and
  preserve its teardown receipt. A returned design consumes all outcomes and
  Antony's reaction without automatically commissioning more work.

A positive earns only its measured same-object access/handoff/receiver rows
under this expressly investigated exception. It cannot meet the unchanged
original-byte submission rule, establish lasting volfs support, repair long-app
registration/constrained launch/receipt, certify native metadata or save semantics,
or close independent action/search, binary and public acceptance. A negative
closes only this spelling/consumer/build combination. Either outcome leaves
k150 and all route ancestors live until a complete agreed supported route and
k128's mandatory final review exist. Only the source/charter and prototype
children have retired. No repeat or automatic new experiment is authorized;
production implementation remains planning's work.

### Same-object result and remaining route

**The finite diagnostic is complete and its allowance is spent.** Antony
answered “I agree” on 2026-10-06 to accepting the
[incomplete report](same-object-namespace-prototype.md#returned-gap-and-human-reaction)
for this assessment, with no retry authorized. Preserve its one guest/build/
collection, all raw requests and the 91.58-second teardown interval. The
driver missed Zed's **Unrecognized Project** dialog at the second request;
six later requests crossed the required stop boundary. None earns compliant
receiver or selection credit. The seven-row post-UI summary is not the attempted-request
count: eight helper request outputs exist, with the last lacking post-UI capture.
The instrument remains frozen; correction would require a separately authorized
new diagnostic, not a rewritten account of this one.

| Stage | Admitted evidence | Remaining obligation |
| --- | --- | --- |
| Original object access | Independent component-created target/parent/decoy and bare-operand device/inode plus exact-marker checks pass for both files and directories at 900/1,500 bytes, before submission. Inodes in this sample have no high bits. | General races, policy and high-bit/other-volume behavior remain unmeasured; no retained client handle or pinned search object is introduced. |
| Native facts and exact handler | At 900 bytes the measured flags/type and exact-item TextEdit/Finder handler observations complete. At 1,500 some flags complete and handlers return, but application/type acquisition reports Cocoa 256 with underlying POSIX 28. | Required long application/type facts are unacquired. Preserve typed causes; the handler does not repair classification or establish general metadata parity. Bundle identifier and long registration/selection were not tested. |
| Submission and delivery | The sole pre-boundary default file request acknowledges and TextEdit independently renders the 900-byte exact marker. The next named control acknowledges and shows the marker behind unexpected trust UI. | Callbacks establish acknowledgment only. Exact delivered operands are opaque; recovered UI filenames prove no byte-exact delivery. The bare operand changes Koine's submission spelling even for the clean control. |
| Real long receivers and Finder | No compliant long receiver or actual Finder-selection result. Long TextEdit's error is a retained post-boundary observation; long Zed has helper output without after-UI capture. Long directory actions and long reveal were unrun. | Real default/Zed file/directory access and actual Finder selection remain required. Do not turn post-boundary failures into admitted receiver verdicts, or unrun rows into failures. |
| Long application and receipt | No long application, registered-copy selection/constrained launch, bundle identifier or executable-identity receipt subject ran. | Preserve exact selected native copy, registered submission spelling and PID/start-instant/live executable identity; systematic null is not accepted. |
| Lifetime, authority and support | No target copy/move/link or private policy was used. The guest was disposed. Recorded callbacks arrived inside three seconds. | Early cancellation, grants/revocation, independent action/search and binary/public acceptance remain pending. Final inspections were unrun. Volfs's lasting-support and original-byte-submission exceptions are unadopted. |

Keep the existing private native action seam: Workspace owns per-action
resolution, fact provenance, selection and submission; the receiver owns its
subsequent filesystem access. A local same-object pass cannot replace either
side's remaining contract. The
[pinned Zed reader and canonicalizer](#opener-and-receiver-are-separate-obligations)
are still whole-path consumers. The visible 900-byte Zed marker establishes a
control observation at the security stop, not the unmeasured long result or a
prompt-free pass. The real guest version and source pin are distinct evidence.
No formal model would discharge these opaque native/receiver outcomes.

<a id="proposed-focused-zed-receiver-diagnostic"></a>

### Authorized focused Zed receiver diagnostic

**Antony answered "authorized" on 2026-10-06; the diagnostic is now complete
and its report accepted.** Preserve this charter as the scope of the
[actual result](focused-zed-receiver-prototype.md). This finite
two-file receiver diagnostic answers one question: can the exact installed
short Zed copy render the original 1,500-byte file through the bare native-ID
operand, when the known project dialog is dismissed by staying restricted?
This completes no native-fact, default-handler, Finder, long-app or support
obligation. Its alternative is to leave this receiver branch unmeasured and
retain the route live until a different source-supported candidate is selected.
Repeating the broad twelve-request matrix would spend work on already known
local access and unrelated consumers before settling this one missing result.

[Zed's worktree-trust contract](https://zed.dev/docs/worktree-trust) applies to
single-file projects as well as directories. It separates remaining restricted
from granting trust; restricted mode suppresses project settings and related
language/MCP-server execution. The
[actual control screenshot](same-object-namespace/results/after-file-900-named.png)
contains **Stay in Restricted Mode** and the exact control marker behind the
modal. This supports a specific diagnostic interaction, not a promise that the
long case opens or that another Zed build has the same UI.

- One disposable macOS guest, one collection, at most two builds before it and
  a 15-minute clone-through-disposal cap. No repair/recollection after the first
  external request; a failed control or unavailable observer ends incomplete.
  Preserve k152's helper/driver/evidence; a new instrument has a separate plan,
  output directory, version and per-input/output digests. No new golden image,
  survey, external inquiry or automatic follow-on.
- Exactly two independently component-created harmless ASCII text files at
  900/1,500 UTF-8 bytes excluding NUL, each with a same-parent distinct decoy
  and fixed unique marker. Use no project settings, language/MCP configuration,
  user/protected/remote file, copy, rename, hard link, symlink or cwd change.
  Verify original and bare native-device/full-inode identity and at most 64
  marker bytes before and after each request. Serialize the existing maximum
  three owned descriptors and log at most 8,192 bytes per value; opaque native
  allocations are outside that owned bound. Failed identity ends incomplete.
- At most two external document requests: one control, then one long named
  `NSWorkspace.openURLs` request to the exact independently verified short
  registered Zed copy. Retain activation, no new instance, no running-copy
  substitution, prompting disabled and the three-second acknowledgment bound.
  No default open, Finder reveal, long app, retry, alternate spelling or separate
  launch/open preparation request. An unavailable ordinary prepared Zed copy
  ends incomplete. Long application/type failures remain recorded and only
  known fixture submission bypasses those production prerequisites.
- Verify no prior Zed fixture buffer or marker before each request; terminate
  the control receiver before the long request and confirm its disappearance.
  Record the callback PID and independently acquire its kernel start instant and
  live executable identity, checking both callback and live executable identity
  against the selected short registered Zed copy under the existing receipt
  observation rule. Match the post-request UI to that process incarnation.
  Missing/mismatched executable evidence or unestablished reset/UI attribution
  ends incomplete with that receiver row unmeasured. This diagnostic attribution
  earns no long-application receipt credit; no stale-buffer success is admitted.
- The sole authorized security-UI exception is one **Stay in Restricted Mode**
  choice per request on the exact fixture's **Unrecognized Project** dialog.
  Verify receiver ownership and the unique fixture basename/path context before
  that choice; otherwise stop. Do not grant trust, tick either trust checkbox,
  enable `trust_all_worktrees`, edit a trust database or change OS permissions.
  Any other consent/security UI stops immediately before the next effect.
  Capture native outputs, UI tree and screenshot before/after the permitted
  choice. Require supervisor inspection after each request, before the next;
  a wording-only detector cannot authorize continuing. The known modal remains
  an observed dialog and this is never prompt-free production acceptance.
- Independently require the fresh exact target marker, distinct from decoy,
  visible in the real Zed text buffer. A title, callback, process launch or
  dismissed modal alone passes nothing. If the exact marker is visible behind
  a modal but cannot be confirmed afterwards, record only the boundary observation.
  Delivery stays opaque unless a supported observation actually recovers it.
  No receiver instrumentation, save/write test or inferred save semantics.
- Preserve OS/build/volume, SDK/compiler, exact Zed version/registered copy,
  signatures/entitlements, original and submitted inputs, typed failures, raw
  UI/native records, before/after per-subject digests and a teardown receipt.
  Dispose even on failure. Return one report and human reaction; a positive
  would establish only the named-file receiver behavior under the diagnostic
  spelling/UI exception. No production exception, complete route, ADR, final
  review, implementation or automatic continuation follows.

This is a new authorization: k152's finite permission remains spent, its reaction
authorized no retry and its original security-stop rule remains the rule against
which that report is assessed. The new permission covers only the two-request
scope and verified restricted-mode interaction above. The source/charter handoff
is focused-zed-receiver-k154; focused-zed-receiver-k155 runs the sole prototype
and obtains Antony's reaction; long-action-route-k156 assesses its actual report
toward the complete retained route. Preserve a separate plan/instrument/raw
corpus under docs/verification/focused-zed-receiver/ and report at
docs/verification/focused-zed-receiver-prototype.md; k152 remains immutable.
The charter reviewer allowance was already spent on executable-copy attribution,
and that finding is corrected. No second charter reviewer is commissioned.
Every original long working case, short regression, authority, compatibility
and support obligation remains binding. k156 and all route ancestors stay live
until the complete agreed supported route exists; no automatic next experiment,
production exception, implementation or final review follows this authorization.

### Focused Zed result and bookmark question

**k155 completes the named-file receiver question; k156 keeps the full route
live.** Antony accepted the [readable report](focused-zed-receiver-prototype.md)
on 2026-10-06: “I've read the document. I agree.” The one guest/collection made
two requests, then disposed the guest in 152.15 seconds. Both unique original
markers were visible in fresh, unobstructed buffers owned by the exact selected
short registered Zed copy, after one authorized Stay in Restricted Mode choice
per request. Independent identities/decoys, reset, kernel start instant/live
executable and UI-owner evidence support this positive. Neither trust nor a
production consent/spelling exception follows.

The long buffer shows inode **223952**, not the original filename. Long
application and content-type checks report Cocoa 256 / underlying POSIX 28;
they remain unacquired facts. Exact delivered operands are opaque, saving is
untested and default/directory/Finder/long-app/cancellation subjects were unrun.
The [technical evidence](focused-zed-receiver-technical-evidence.md) owns the
raw process/request/control records; k152's missed-stop evidence remains frozen.

Antony then asks whether bookmarks would improve Zed's filename, and whether
their cleanup would be an issue. The
[returned assessment](focused-zed-route-assessment.md#bookmarks-and-zeds-filename)
re-reads the public SDK and pinned Zed URL-string/file-path ingress. An embedded
original name is not a separate display-name input on that inspected path;
resolving to the long original pathname could restore the known consumption
limit. Per-action bookmark data needs no durable registry. Security-scoped
access and file-ID-preference flags are not naming repairs.

The [finite bookmark charter](focused-zed-route-assessment.md#proposed-finite-bookmark-diagnostic)
has four serialized creation/resolution cases, one guest/collection, a 15-minute
cap and zero external application requests. It separately grades stored-name
recovery, actual returned URL and independently verified same-object reading.
Antony authorized it, then accepted k158's
[incomplete report](bookmark-name-resolution-prototype.md) on 2026-10-06. The sole
collection stopped at preparation on closed supervisor input; no fixture or
bookmark case ran. Disposal completed in 19.22 seconds. Stored Name/Path, URL
resolution, whole-path reading and independent controls are all unrun, not
native negatives. The [returned result and next decision](focused-zed-route-assessment.md#stopped-bookmark-result-and-remaining-route)
preserve the spent authorization and propose one new identical local collection
with an acknowledged input preflight before cloning. This proposal is not
authorized. k159 and k156 remain live; no automatic successor is commissioned.
Both acceptance sets, three profiles, original byte spelling,
supported basis, long native facts/exact-copy receipt and k128's final review
remain required. No ADR selects this incomplete route.

## SDK and source provenance

The inspected SDK is macOS 27.0, at the Xcode macOS SDK root. Its public
`Files.h` declares parent/name reference creation and native reference comparison;
`LSInfoDeprecated.h` declares item information, attributes and item binding.
The bounded attribute catalogue in that header lists content type, file type,
creator, extension, display name/kind, handler display name, invisibility,
extension hiding and quarantine. It contains no bundle-identifier attribute.
This is a claim about that catalogue, not every macOS API.

Apple documents [FSRef](https://developer.apple.com/documentation/coreservices/fsref)
as an opaque native object reference and warns about APFS performance with its
32-bit-inode design. Do not inspect its bytes or replace native comparison with
a handcrafted identifier. The public reference functions are deprecated;
deprecation alone does not prove an unavailable or impossible route.

[Reference item information](https://developer.apple.com/documentation/coreservices/1445227-lscopyiteminfoforref)
and [item attributes](https://developer.apple.com/documentation/coreservices/1445023-lscopyitemattribute)
provide native classification candidates. The SDK's attribute result comment
distinguishes an absent attribute from another error. The
[Launch Services binding guide](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/LaunchServicesConcepts/LSCTasks/LSCTasks.html)
describes exact-item preferred-handler lookup. None is a license to manufacture
a missing identifier or silently convert an acquisition failure to nil.

[CFBundle's public dictionary API](https://developer.apple.com/documentation/corefoundation/cfbundlecopyinfodictionaryforurl(_:))
has no error output. Apple's published **CF-1153.18**, commit
`dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3`, is concrete counterevidence to assuming
that a non-null dictionary proves successful identifier acquisition:

- [CFBundle_InfoPlist.c](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFBundle_InfoPlist.c#L421)
  converts directory URLs through a fixed path buffer. Its directory reader can
  produce an empty dictionary after unsuccessful reads or parsing.
- [CFInternal.h](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFInternal.h#L726)
  defines the non-Windows buffer size as 1026 bytes.
- [CFFileUtilities.c](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFFileUtilities.c#L172)
  converts URLs into a fixed path buffer before opening whole paths.

This source is historical, **not the implementation of the current guest**.
Its failure branches explain why changing Bundle to another dictionary-only
API does not source-prove the needed provenance. They do not prove a current
1500-byte native failure. A raw plist reader using public relative I/O and a
native property-list parser is technically a candidate; public
[bundle structures](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html)
do not by themselves establish complete parity with Bundle's layout/cache and
missing-identifier behavior. A new metadata read route also lacks the earlier
prompt-free measurement. Do not guess a sole plist path for every native app.

The SDK's `CFURL.h` explicitly marks CFURLCreateFromFSRef/CFURLGetFSRef as
unsupported. FSGetCatalogInfo's parent/name report is a public candidate for
recovering reference spelling, but its deprecation, Unicode conversion,
spelling/race behavior and long-path results need evaluation. It is not a
permitted shorter submission surrogate.

Published **xnu-12377.1.9**, commit
`f6217f891ac0bb64f3d375211650a4c1ff8ca1ea`, supplies two additional boundaries:

- [Long-path policy](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_resource.c#L3210)
  checks a private entitlement before setting the policy. Its selector is absent
  from the inspected public SDK `sys/resource.h`. Neither a locally defined
  selector nor this entitlement is an admissible repair under the mandate.
- [Executable-path acquisition](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/proc_info.c#L1405)
  obtains a vnode path and then performs whole-path vnode lookup. SDK
  `sys/proc_info.h` sets PROC_PIDPATHINFO_MAXSIZE to four times MAXPATHLEN;
  `libproc.h` declares proc_pidpath. Neither source nor a 4096-byte allocation
  establishes the required receipt observation. Other vnode-info structures
  inspected here describe cwd/root, an fd or a mapped region; no replacement
  executable-identity rule is selected from them.

These published sources are explanatory, not a guest/kernel version measurement.
The existing adapter, selection and observation code was read directly because
the codebase graph could not start; no graph generation or coverage claim is made.

## Cause and fact interface the candidate must satisfy

Keep the existing private native adapter as the substitution point. A completed
inspection must carry acquired native flags, identity and optional facts whose
absence was established; a failed acquisition carries its stage and cause.
Required booleans never default to false. L can substitute these outcomes and
test planner behavior; only N/V can establish real acquisition and provenance.
This interface does not make the currently incomplete candidate implementable.

A parent-relative resolver would have to distinguish:

- ENOENT/ENOTDIR at an actually resolved component, including a dangling link
  or a file followed by dot, dotdot or a separator, from a higher-level wrapper
  whose cause is unknown.
- A stable cycle in **active link expansion** from repeated use of a link
  after its expansion completed. A global set of ever-seen link identities would
  falsely reject finite paths through a link to dot. Record parent/link identity,
  observed link text and active expansion provenance; changed or unestablished
  observations cannot prove the accepted two-link-cycle absence.
- An isolated component established impossible under its parent's filesystem
  name rules from whole/expanded-size failure or a reference/Unicode conversion
  limit. fpathconf plus an isolated native lookup is a candidate for the required
  300-byte ASCII case, not a universal Unicode name-limit proof.
- Completed no-type/no-identifier/no-handler reports from failures to obtain
  those reports. Neither NULL nor an empty bundle dictionary proves none.

Exhausted work/link budgets, unknown causes, observed changes, incomplete data
and size refusal remain failed. Successful component lookup cannot excuse failed
classification, registration equality, handler acquisition or receipt identity.
Existing controls, cancellation between stages, three-second acknowledgment,
earlier core deadline, no replay and possible post-submission effects stay binding.
Scripts/packages retain native document semantics; opening programs, apps and
Finder aliases retains native refusal. Reveal submits their original locations.

## Decision for Antony

**Antony retained the original working requirement and requested broader
application research.** His instruction was "retain the original requirement -
invoke research processes to see how other applications deal with this problem",
clarified as "Specifically how long pathnames are dealt with. This must occur
for other use cases and contexts." The proposed disclosed refusal is not
adopted; all original roughly 1,500-byte working cases and exclusions remain.
No shortening, alternate-copy selection, private policy, new consent, guessed
native facts or systematic length-caused null receipt is authorized.

The commissioned process is complete: both surveys answered the same brief,
and synthesis unions the evidence, corrects claims and exposes correlated sources.
Returned design has consumed them and re-read the applicable receiver and SDK
branches. It has not established a complete retained route.

| Step | Concrete question and deliverable |
| --- | --- |
| Independent application surveys | [A](../research/long-pathname-applications-a.md) and [B](../research/long-pathname-applications-b.md) delivered finite primary-source corpora. Neither established the complete retained route. |
| Synthesis | [Combined research](../research/long-pathname-applications.md) followed reconstructions and receivers, corrected claims and separated shared-source readings from independent behavior. |
| Returned route design | [Mechanism disposition and exact remaining gaps](#application-research-reconciliation), including public item arrays and preserved real-application acceptance. Antony subsequently authorized [internal investigation](#internal-native-reference-investigation), with one finite acquisition probe and returned design. |

For each real system, follow normal and over-limit ingress, representation,
traversal, metadata, external boundary and consumer. Distinguish storing or
showing a pathname from successful operations and application delivery. Cover
macOS, Linux/POSIX and Windows contrasts; state byte/character/UTF-16 units,
NUL inclusion, per-component versus whole/expanded limits, versions/configuration
and failure behavior. Source concrete uses of component sequences, cwd/dirfd,
handles/IDs, virtual mappings or rewriting rather than assuming an API name or
larger buffer establishes success. The earlier survey supplies leads, not a
conclusion to confirm. Missing primary evidence remains an explicit silence.
Excluded mechanisms can be explained as prior art but require a new human
decision before Koine adopts them. Research may find successful strategies,
bounded dead ends or remaining questions; no outcome is predetermined.

The returned-design route nodes remain live. Final design
still owes the complete supported acquisition/submission/receiver route and k128's
mandatory `long-search-result-actions` review before search consumers or
implementation planning. Independent component-created action fixtures and
later actual-search G/N/V provenance remain separate acceptance subjects.
Retained 1.0.0, action-only repair 1.0.1 and search 1.1.0 stay independent.
No ADR selects an unestablished route or an unaccepted workflow loss.

**Both acquisition and item-array diagnostics are complete.** The
[item-array result and representation assessment](#item-array-result-and-representation-assessment)
consume the spent charter and Antony's two candidate representations. Both
openers delivered exact spelling at 900/1,023 and failed at 1,024 before any
recorder event. No complete route or acceptance is established. Antony authorized the
[finite public file-reference URL acquisition diagnostic](#proposed-file-reference-url-acquisition-diagnostic),
limited to internal acquisition/local consumption without any external
submission or adoption, on 2026-10-05. Its [actual result](file-reference-url-acquisition-prototype.md)
is now complete: both patterns pass local acquisition/reading/original bytes at
900/1,023 and fail acquisition at 1,024/1,500. The initial instrument stop, sole
correction and expressly authorized replacement remain distinct. The earlier
"proceed" inquiry choice is superseded;
no external response is a prerequisite and no request has been sent. Internal
investigation resolved only the tested acquisition and item-array branches,
leaving the complete opener and receiver gaps. No complete route is guaranteed.
Acceptance of k143 alone authorized no additional experiment; k146's later
permission covered exactly the fixed opener diagnostic and this returned
design. The representation direction alone commissioned no measurement; the
later explicit decision covers this fixed URL diagnostic and its returned
design only. It preserves every
original working case and authorizes no spelling,
setup, private-policy, consent or contract exception and no automatic probe series.

**Earlier decision:** Antony accepted k152's incomplete
[same-object report](same-object-namespace-prototype.md#returned-gap-and-human-reaction)
on 2026-10-06 with no retry authorized. Its spent permission covered changed
diagnostic spelling and legacy-support investigation only, without production
adoption. The [returned stage assessment](#same-object-result-and-remaining-route)
preserves the local positive, native-fact failures and missing receiver/selection
results. Antony subsequently answered **"authorized"** on 2026-10-06 to the
[focused two-request Zed diagnostic](#authorized-focused-zed-receiver-diagnostic):
one 900-byte control and one 1,500-byte original file, one guest/collection and
15-minute cap, with a fixture-only Stay in Restricted Mode interaction and exact
live-executable attribution. The diagnostic has since completed with the accepted
[focused result](#focused-zed-result-and-bookmark-question). This finite
permission admits only the verified restricted-mode choice, granting no trust;
it rewrites no old stop-rule evidence. k154 hands the charter to prototype k155
and returned design k156. No production exception, automatic next experiment,
implementation, final review or complete-route retirement is earned. Original
client values, objects, every
file/directory/app working case, both controls, cancellation, authority, three
compatibility profiles and independent action/search acceptance remain required.
Native facts/selection, real default/Zed directory/Finder behavior, long
constrained launch, executable receipt, original submission bytes and durable
support remain explicit gaps; the focused receiver positive waives none.

**Prior collection decision:** Antony approved the
[replacement bookmark collection](focused-zed-route-assessment.md#replacement-bookmark-decision)
on 2026-10-06 and asked whether a parent-directory reference followed by the
original final name would let tools such as Zed use that name. The
[source assessment](focused-zed-route-assessment.md#parent-reference-plus-original-name)
separates this candidate from the earlier child-reference factory and records
concrete pathname-expansion hazards without predicting the native result.
The [separate four-case parent group](focused-zed-route-assessment.md#parent-reference-name-diagnostic)
shares the unchanged four bookmark cases' one guest/collection, two precollection
builds, 15-minute cap and zero external requests. Preclone interactive-input
preflight and separate inspected READY checkpoints remain binding. Preserve
all old raw evidence and freeze a distinct new input/output corpus.

Name-bearing construction, stored properties, actual absolute/path resolution,
whole-path same-object reading and real Zed naming remain distinct. k161's
[accepted incomplete report](local-url-naming-prototype.md) records successful
interactive preflight, complete 900-byte fixture controls and a 1,500-byte
trailing-slash parent-control ENAMETOOLONG stop before all eight cases.
Antony answered “Accepted.” on 2026-10-07. The authorization is spent; k158's
EOF and k161's native control failure remain separate immutable attempts.
The [returned assessment](focused-zed-route-assessment.md#local-naming-result-and-control-assessment)
explains the source-consistent suffix hazard and the shared-control coupling.
Antony's 2026-10-07 “authorized” approves the
[separated local naming charter](focused-zed-route-assessment.md#separated-local-naming-proposal):
one new eight-case local collection, with bookmark file controls independent
of parent candidate prerequisites and the original slash-ended directory URL
and exact constructors/reader retained. k159's returned route node k162 now
contains source/charter k163, one fresh-context prototype k164 and returned
complete-route design k165. k164 owns the collection/report/reaction; k165
consumes actual outcomes without presuming success. All eight cases remain unrun.
The final child, k162/k159/k156 and every route ancestor remain live while the
complete supported route is unresolved. Approval authorizes no receiver request,
restricted-mode/trust interaction, repair/recollection or automatic next
investigation, production exception, final review, implementation or route
retirement.

### Prepared capability inquiry

The bounded inquiry is superseded by internal investigation. The common brief below supplies context;
the focused Apple and Zed drafts that follow are the concrete submission texts.
No support request has been sent, and no external issue has been created.

> We need a public macOS route for original local paths around 1,500 UTF-8
> bytes, built component by component with individually valid names. Public
> openat/fstatat/readlinkat reach these items. In one macOS 26.5 (25F71) guest,
> an NSWorkspace witness received exact bytes at 1,023 bytes; the 1,024-byte
> subject returned Cocoa error 256 without witness delivery. Long FSRef
> construction and Launch Services registration/handler lookup also failed.
> Those submissions were API diagnostics, not accepted production actions.
>
> Which currently supported public mechanism can acquire native item/type and
> application facts, register/select the exact application copy, open the
> original item in its default or named application, reveal it in Finder, and
> observe the launched executable's exact installation identity? If legacy
> item-reference arrays or catalog enumeration are relevant, how are the long
> references acquired and consumed without re-entering a limited whole-path
> call? We retain original submission spelling, no private policy, no new
> read consent/setup, and no alternate copy or shorter namespace.
>
> For the named Zed document case, the inspected receiver canonicalizes and
> reads full paths after IPC delivery. What supported receiver mechanism
> preserves this original long item through content reading and subsequent
> document operations? Transport success alone cannot establish that outcome.
> Please distinguish supported scope/version from untested possibilities.

The Apple platform questions and Zed receiver question may be addressed to their
respective owners, using the same bounded packet. An answer about one stage does
not close another. Existing [raw measurements](long-action-route-prototype.md#what-was-measured),
[SDK candidates](#sdk-and-source-provenance) and the
[receiver source](#opener-and-receiver-are-separate-obligations) make the gap
inspectable without a new experiment.

### Inquiry channels

Channel guidance was checked on 4 October 2026. [Apple code-level support](https://developer.apple.com/support/technical/)
asks for one focused API problem per request. Its private request form requires
a developer-program account; [Developer Forums](https://developer.apple.com/support/forums/)
provide a public alternative requiring an Apple Account. Use the opener boundary
as the first platform question, rather than asking Apple to design all four
missing stages or explain Zed internals. A partial answer leaves native facts,
registration/selection, Finder and receipt identity unresolved.

[Zed support](https://zed.dev/support) publishes `hi@zed.dev` for general
inquiries. Its repository's current [discussion categories](https://github.com/zed-industries/zed/discussions), read through the
GitHub API, are Announcements, Feature Requests, Show and tell and Zed GPUI;
there is no general Q&A category. Use the inquiry address for this source-based
capability question. No direct Zed CLI over-limit failure was measured, so the
NSWorkspace diagnostic is not presented as a reproduced Zed bug. GitHub CLI
authentication is available, but supplies neither an Apple nor an email sender.

Previously proposed destinations: Apple Developer Forums for the focused public API
question and `hi@zed.dev` for the receiver inquiry. A private Apple code-level
request is an alternative if Antony prefers it and has program access.
These unused drafts require no publication choice or sender for the current work. No connector
installation, support entitlement, new account or disclosure of the repository
is assumed.

### Apple opener inquiry draft

**Destination:** Apple Developer Forums, or private code-level support if chosen.
**Title:** Supported public route to open an original macOS document path over 1023 bytes

> Is there a supported public macOS mechanism for opening a local document at
> its original absolute path when that path is roughly 1,500 UTF-8 bytes,
> excluding the terminating NUL, and each component is individually valid?
>
> A signed test app in one macOS 26.5 (25F71) guest created the directory tree
> using mkdirat/openat and used public NSWorkspace document opening with an
> explicitly selected short-path witness application. At 1,023 bytes, the
> witness received the submitted path with identical bytes. At 1,024 bytes,
> the callback returned NSCocoaErrorDomain code 256 and nothing was delivered.
> A separate 1,498-byte submission to a short-path Zed installation returned
> the same error class. Component-relative access still reached the documents.
> These were opener diagnostics; prerequisite native item/type/registration
> checks had not passed for the long subjects. They establish no accepted
> application action or universal limit on every public mechanism.
>
> The diagnostic sequence was: create valid ASCII components relative to
> directory descriptors, adjust the leaf depth/name to the measured total
> byte lengths, create the document using openat, then submit its original
> file URL to the selected application through NSWorkspace. The 1,023-byte
> witness delivery was the positive control. No fixture was created by a
> whole-path filesystem call. SDK declarations were checked with macOS SDK
> 27.0; that SDK version is distinct from the guest OS build.
>
> LSOpenItemsWithRole and LSLaunchFSRefSpec accept arrays of whole FSRefs,
> but the tested FSPathMakeRef and parent/name FSMakeFSRefUnicode constructors
> failed for the long items. If catalog enumeration or another public reference
> route is applicable, how should the reference be acquired and submitted
> without re-entering a limited whole-path operation?
>
> We need to preserve the original path spelling and selected application
> installation. Short links, identity-spelled paths, copies, another app
> installation, private APIs/policy and additional read consent or user setup
> do not meet this requirement. Could you name the supported API, its OS scope,
> and any receiver-dependent limitations? If only part is supported, please
> identify that boundary rather than treating URL/string capacity as delivery.

The draft's byte lengths and error class are checked against the existing
[1,023-byte](long-action-route/results/submit-thr-open-1023.json),
[1,024-byte](long-action-route/results/submit-thr-open-1024.json) and
[Zed submission](long-action-route/results/submit-doc-long-zed.json) records.
It includes no raw pathname, account identifier or repository URL. Existing
probe source/logs remain local supporting material; attachments are not selected.

### Zed receiver inquiry draft

**To:** `hi@zed.dev`
**Subject:** Supported Zed mechanism for original macOS document paths around 1500 bytes

> Does Zed currently support opening and reading an existing local macOS
> document at its original absolute path when that path is roughly 1,500 UTF-8
> bytes, excluding the terminating NUL, with individually valid components?
> Is there a supported external delivery mechanism that also preserves that
> same item through content loading and subsequent document operations?
>
> We are separating delivery from the receiver's filesystem work. At source
> commit 76659a55a8c10ed355a070f8764a0b1733e3c115, the CLI receiver accepts
> full path strings, while the real filesystem backend canonicalizes with
> std::fs::canonicalize and loads with std::fs::read_to_string/std::fs::read:
>
> https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/zed/src/zed/open_listener.rs
>
> https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs
>
> That is a source-derived question, not a newly reproduced CLI failure. A
> separate NSWorkspace submission at 1,498 bytes failed upstream with Cocoa
> error 256 in one macOS 26.5 guest; it did not demonstrate that Zed received
> or rejected the document. Public component-relative calls reached the item.
>
> We must retain the original path spelling and exact selected installation,
> without a shorter namespace, another copy, private long-path policy or new
> user setup/read consent. If an existing supported mechanism satisfies this,
> please identify the version, delivery API/protocol and filesystem route
> used after receipt. String transport or a larger input buffer alone would
> not establish content access. If it is unsupported or needs a receiver
> change, that precise scope is useful too.

### What a reply can establish

Record any response with its actual source and date; do not promote a discussion
reply or source inference into native acceptance. A usable lead must name its
supported scope and show where original-path acquisition, delivery and receiver
access occur. Map it back to each outstanding stage separately. No response,
a partial answer or a statement that the workflow is unsupported leaves the
final design live under the retained requirement. A probe beyond the current
internal charter, or changed spelling,
setup, consent or receipt rule still needs its own explicit decision. No polling
schedule, follow-up campaign or new Grove chain is commissioned by this inquiry.

## Deterministic check boundary

The k157 authorized source/charter handoff records Antony's exact decision,
reconciles current approval labels and cuts the one prototype k158 plus returned
design k159 under k156. Its changes are documentation/tree/presentation only.
The fixed cases, bookmark options, reader and bounds are unchanged from the
reviewed proposal. No new native experiment, application request, declaration
check or implementation runs in the handoff. Retire only k157 once its final
document and presentation checks pass; k158/k159 keep k156 and every route
ancestor live, so no parent close or full-route review is earned.

`task design:workspace-render` and `task check:docs` passed for this handoff.
All 495 frozen document/presentation/checker/structural/evidence and local
task/brief subjects matched individually afterward. The authorized charter's
test bullets match the reviewed proposal byte for byte; 357 retained evidence
and structural-check subjects match the preceding checked revision individually,
so its unchanged SDL/example checks remain applicable without a new native or
structural run. The [presentation record](../design/architecture/README.md)
covers the settled light/dark/narrow views, complete exports, transferred-subject
digests and disposal. Final prose recording is checked again on frozen subjects
before retiring and sealing only k157.

The following records apply to earlier design revisions.

k156 consumes the accepted focused Zed report and bounded raw/control/process
evidence. It reconciles current route prose and the editable receiver/bookmark
view while leaving both k152 and k155 corpora immutable. Pinned Zed ingress
and SDK bookmark semantics are source evidence only; no new macOS diagnostic
or application request runs in returned design. Its bookmark charter is a
proposal awaiting Antony's decision. Current validation belongs to document
links, independent retained/repair/search structural tasks and presentation.
All native/binary/public
acceptance remains planning's after a complete supported design and review.

`task design:workspace-render`, `task design:action-repair-check` (including
the retained workspace checks), `task design:search-check` and `task check:docs`
passed. Retained action, repair and search SDL/examples were checked independently
and composed with their existing negative controls. The 491 frozen document,
anchor, manifest, checker, structural and evidence subjects matched their
pre-check digests individually afterward; all 119 k155 output-manifest digests
also matched. These are structural/document checks, not binary/public acceptance.
The [presentation record](../design/architecture/README.md) covers settled light,
dark and narrow browser views, complete exports, matching transferred subjects
and successful disposal of the separate Linux clone. Final prose recording is
followed by another frozen-subject documentation check before describing the
open jj change. k156 is neither retired nor signalled: the full route is unresolved.

The following records apply to earlier design revisions.

k153 consumes the accepted incomplete same-object report, exact native/UI
records and Zed's public restricted-mode contract. It reconciles current prose
and the editable candidate view without changing k152's instrument, report or
raw corpus. The one in-session reviewer identified a missing executable-copy
attribution requirement; the focused charter independently verifies the
kernel start instant and live executable against the selected short copy.
This is a bounded charter correction, not native execution or permission.
Documentation, diagram rendering and independent retained/repair/search
structural checks are the applicable validation surfaces. Native/binary/public
acceptance remains planning's work after the complete supported route and its
mandatory review. Antony's new authorization decomposes k153 into completed
assessment/source-charter k154, the sole prototype k155 and retained returned
design k156. k155/k156 keep every route ancestor live. No automatic retry or
new investigation follows; no native macOS request executes in this handoff.

`task design:action-repair-check` (including retained workspace) and
`task design:search-check` ran sequentially and passed their positive/negative
controls. The frozen Taskfile, SDL/examples, client dependency manifests,
documentation checker, presentation and native-evidence subjects stayed
unchanged item by item through the structural runs and initial document check.
D2 0.9.0 regenerated the candidate export; actual browser/export evidence and
its checked widths are in the [viewer README](../design/architecture/README.md).
Four host/guest viewer/manifest/source/export digests matched individually and
stayed unchanged across that inspection. The Linux presentation clone is disposed.
Final documentation links are checked again after these verification-note edits
on newly frozen subjects; no native macOS diagnostic, production implementation,
declaration check, served digest or binary/public acceptance is claimed here.

The k154 authorized handoff regenerates the candidate view with D2 0.9.0 and
checks it in an isolated Linux Firefox 151.0.3 clone. The fresh light deep link,
settled dark discussion, complete light/dark exports and actual 500 × 600 dark
introductory reflow are inspected; the viewer README records setup corrections
and excluded transient captures. Four host/guest presentation digests match
individually before/after; the clone is disposed. The fourteen current structural
inputs/checker/dependency subjects match the k153 frozen revision that passed
the sequential action-repair/search tasks. The older k150 Taskfile digest differs
because it predates the intervening prototype tasks; that older comparison is
not the verification basis. No structural input changes or new native request
are made in this authorization handoff. Freeze the final document/check/raw
subjects and verify links again before retirement and sealing.

The following records apply to earlier design revisions.

k150 consumes all committed URL attempts and reconciles current prose and the
candidate view. `task design:action-repair-check` and `task design:search-check`
were run sequentially and passed their existing positive/negative controls.
Taskfile, document checker, retained/repair/search/desktop SDL, both operation
files and contract-client dependency manifests stayed unchanged by per-file
SHA-256 throughout those runs. `task design:workspace-render` regenerated the
view with D2 0.9.0; the actual browser/export checks and their limits are in the
[viewer README](../design/architecture/README.md). Documentation links passed
before recording these verification notes and are checked again on the final
frozen subjects. No declaration probe, native macOS diagnostic, production code,
served digest, binary profile or action/search acceptance is supplied here.
At that revision the finite namespace diagnostic was authorized but unexecuted.
The source/charter handoff retired only k151; k152 has since supplied its accepted
incomplete report. K153 keeps k150 and every route ancestor live. No complete-route
review or final-design retirement is earned.

The later k151 authorization handoff changes current charter/prose and the
editable visual discussion to authorized/unexecuted status. The structural
checks above are carried forward for identical subjects: all ten structural
input digests and five carried public SDK headers match. Pinned-source and
native raw-evidence subjects are frozen for the final document check; no native
corpus is rewritten. The newly rendered view's light/dark discussion, fresh
deep links, complete light export and actual 500 × 600 introductory reflow were
inspected as recorded in the viewer README; the complete dark export remains
uninspected. The separate Linux presentation clone is stopped. Final document
links are checked on frozen final subjects before retirement. No new declaration,
macOS execution, production code, complete supported route or public acceptance
is claimed.

The following record applies to the preceding authorized URL handoff.

The authorized URL handoff (k148) changes current-state prose, the finite charter,
child handoffs and the candidate diagram. Structural/native evidence subjects
remain unchanged; the preceding action-repair/search checks are carried forward
only for their identical subjects, not credited as new executions. Render,
browser and final document-link checks verify presentation/structure and supply
no native route or action acceptance. The exact browser evidence and limits are
in the [viewer README](../design/architecture/README.md).

The following check record applies to the preceding proposal revision.

The k147 returned design consumes the committed item-array result and reaction,
reconciles stale execution-pending prose, and assesses the two representations.
Its new charter is proposed, not executed. Public SDK/historical source reads,
document links, unchanged action/repair/search structural contracts and rendered
presentation are the applicable verification surfaces; none establishes native
URL acquisition, a complete route or release acceptance.

`task design:action-repair-check` and `task design:search-check` were rerun
sequentially and passed their existing positive and negative controls. All 299
frozen document, structural-check, presentation, SDK/source and raw-evidence
subjects stayed unchanged across those checks and the document-link check.
After the browser found overlapping edge labels, only the changed D2/SVG were
adjusted and regenerated; structural-check subjects stayed unchanged. The final
rendered browser evidence and its limits are in the
[viewer README](../design/architecture/README.md). No declaration probe was
compiled or executed in k147; native URL acquisition remains unmeasured.

The following record applies to the preceding authorized diagnostic handoff.

The authorized diagnostic handoff (k145) changed current-state prose, SDK call
configuration, child charters and the candidate diagram. Structural/native
subjects remain unchanged; the previously passing action-repair/search and
declaration checks are carried forward only for their identical subjects, not
credited as a new execution. Render, browser and final document-link checks
verify the handoff's presentation/structure and supply no native route or action
acceptance. Exact presentation evidence and limits belong in the
[viewer README](../design/architecture/README.md).

The following returned-result checks apply to the preceding proposal revision.

The k144 returned result changes prose, the proposed finite opener charter
and the candidate diagram. `task design:action-repair-check` and
`task design:search-check` were rerun and passed their existing positive and
negative controls. The Taskfile, retained/repair/search/desktop SDL and operation
examples, declaration probe, client dependency manifests and documentation
checker still match the earlier successful structural-check subjects
item-by-item by SHA-256. No declaration probe or native action ran in k144.
`task design:workspace-render` regenerated the changed export; its current
browser evidence and limits are in the [viewer README](../design/architecture/README.md).
`task check:docs` passed for the final reconciled documentation with all frozen
document, check, presentation and raw-evidence subjects unchanged across the run.
These checks establish structure and presentation, not a complete native route.

The following records apply to preceding revisions.

The k141 reconciliation reran `task design:action-repair-check` and
`task design:search-check`; both passed their existing positive and negative
controls. `task design:long-action-api-check` passed against SDK 27.0 and Apple
clang 21.0.0, including its removed-import control; the probe was not executed.
The Taskfile, SDL/operation subjects, client dependency manifests, check script
and presentation viewer/manifest/changed source/export stayed unchanged by
SHA-256 throughout these checks. `task design:workspace-render` regenerated the
changed candidate SVG; the actual browser checks and their limits are recorded
in the [viewer README](../design/architecture/README.md). `task check:docs`
passed for the reconciled documentation. These checks credit no supported native
route, accepted binary profile or completed working subject.

`task design:long-action-api-check` compiles and links the declaration probe and
checks intended imports against SDK stubs, with a removed-import negative
control. It does not execute the probe or verify symbols on a guest.
`task design:action-repair-check` and `task design:search-check` check retained
versus repaired descriptions, action shapes and examples; they prove no native
route or outcome. `task design:workspace-render` renders the candidate view;
`task check:docs` checks document links. Native working subjects remain pending.

The source-evaluation declaration/import task passed with SDK 27.0 and Apple clang
21.0.0, including the removed-import control. Independent/composed action SDL,
the three-description repair delta and search/action examples passed their
existing negative controls. These results establish declarations and document
structure, not a complete acquisition route. That declaration probe was never
executed; the separate signed k134 prototype supplied the bounded native
measurements above.

The returned design reran `task design:action-repair-check` (including workspace
SDL/examples and the unchanged-baseline control) and `task design:search-check`
(including composed examples and removed-root/input/output/foreign-type controls).
Both passed. The Taskfile, retained/repair/search/desktop SDL and operation
subjects, client dependency manifests, document-check script and presentation
viewer/manifest/changed source/export stayed unchanged by SHA-256 across the
structural run. Documentation links use `task check:docs`; presentation is
checked separately as described in the [viewer README](../design/architecture/README.md).
No numeric served digest, provider implementation, native outcome or binary
profile is credited by these checks. The SDL/examples remain the retained
contracts because no workflow-loss alternative is yet adopted.

The research commission changes prose and the route diagram, not SDL, operations,
check mechanics or client dependencies. Those structural subjects and the viewer
still match the prior successful structural-check revision item-by-item by
SHA-256. The independent survey briefs are identical apart from their handles,
and all commissioned child charters are populated. The revised diagram renders;
its browser presentation evidence is recorded in the linked viewer README.
These are commissioning checks, not research findings or supported-route proof.
