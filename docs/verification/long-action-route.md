# Long-location route evaluation

**The retained long-location route is unresolved after the finite prototypes,
two application surveys and adversarial synthesis.** Parent-relative filesystem
operations can reach the items. The tested public native-fact and opener routes
did not complete the roughly 1,500-byte workflows; the inspected Zed receiver
also performs whole-path filesystem reads after delivery.
This is bounded evidence about tested mechanisms, not universal impossibility.
The completed flat-enumeration diagnostic returns references at 1,024 bytes,
but its tested consumers reject them and its walk cannot reach the 1,500-byte
subjects. Both measured item-array openers also fail at 1,024 bytes before
recorder delivery. No production route or
workflow loss is adopted.

Start with the [local access, handoff and receiver view](../design/architecture/index.html#diagram-workspace-route-candidates)
and the [remaining decision](#decision-for-antony). The
[prototype](long-action-route-prototype.md) supplies the committed native
measurements; the [prior-art survey](../research/prior-art-long-paths-a.md)
answers the representation question. The [reviewed boundary](long-action-native-boundary.md),
independent action/search subjects and separate compatibility profiles remain
binding. The [acquisition result](#native-reference-result-and-remaining-gap)
is consumed here without another native run; it is not action acceptance.

Antony retained the original requirement and requested the now-completed
[application research synthesis](../research/long-pathname-applications.md),
based on independent [survey A](../research/long-pathname-applications-a.md)
and [survey B](../research/long-pathname-applications-b.md). The refusal
recommendation remains unadopted. This returned design follows the mechanisms
through their receivers and narrows SDK acquisition candidates. Antony's later
instruction selected [internal investigation](#internal-native-reference-investigation).
That finite diagnostic is complete and Antony accepted its result. The
[item-array diagnostic](#proposed-item-array-submission-diagnostic) is complete.
The [returned result and representation assessment](#item-array-result-and-representation-assessment)
consume Antony's directory-handle/component and file-reference URL direction.
Antony authorized one finite acquisition-only diagnostic on 2026-10-05, with
one prototype and retained returned design. It remains unexecuted and commissions
no automatic probe series.
No complete route is established. Final review and action acceptance remain required
before the search handoff can close.

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
namespace is a different spelling/setup exception and remains unapproved.

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
| Transient public file-reference URL, with original text retained separately | Workspace owns native creation, actual same-object verification, conversion failures and lifetime. No serialized reference survives a restart/remount and no reference string is handcrafted. | NSURL/CFURL offer supported creation APIs distinct from FSRefs. Long acquisition, URL-consuming local I/O, native facts and subsequent original-byte submission are unmeasured. Sending the identity URL externally would need a separate spelling decision. |

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

**Recommendation:** use descriptor/name as the private local-resolution design
candidate, preserve the public observed pathname, and investigate public
file-reference URL acquisition before any external submission. The alternative
is to keep the original route pending without another measurement. Exporting
handles or trying identity-spelled opener submission is a different contract
decision. No ADR selects any unestablished complete mechanism.

<a id="proposed-file-reference-url-acquisition-diagnostic"></a>

### Authorized file-reference URL acquisition diagnostic

**Authorized, unexecuted.** Antony answered **"authorized"** on 2026-10-05 to
the exact finite proposal. This is one experiment to answer
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
submission or adoption, on 2026-10-05. It remains unexecuted; one prototype and
retained returned design follow. The earlier "proceed" inquiry choice is superseded;
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

The alternative is an explicit decision to investigate one named exception,
such as a short virtual namespace backed by the original objects. That changes
receiver-visible spelling and can need setup; it is unapproved and its macOS
classification/registration, receiver, save, reveal and receipt behavior is
unproved. A symlink/hard link or copy is not presumed equivalent. Any such
investigation would need a finite charter, failure boundary and returned design;
permission to investigate would not adopt its behavior or waive original cases.
The declined refusal proposal is not put forward again.

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
