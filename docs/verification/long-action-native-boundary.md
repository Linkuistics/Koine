# Long-location action boundary

Source/SDK analysis and a proposed error-contract repair, **not native action
acceptance**. This answers why the existing metadata route cannot establish
actionability for every search location. It does not select a replacement
classification/selection route. The remaining route design and its mandatory
review stay live before search consumers. No shorter search ceiling, copy-only
workflow, private policy, new consent or incompatible version is approved.

The [action boundary](../specs/workspace-launch-and-open.md#long-location-action-boundary)
owns the behavioral meaning. The
[search handoff](../specs/workspace-search.md#long-location-action-dependency)
continues to require a complete, reviewed action route.

The [returned route evaluation](long-action-route.md#measured-reconciliation)
consumes the finite prototype and completed application research. Relative lookup
reached long items; tested classification/registration/handler/submission APIs
did not complete the original working cases. The
[retained requirement and remaining decision](long-action-route.md#decision-for-antony)
keep the original cases binding. Both surveys and synthesis are complete;
[returned design](long-action-route.md#application-research-reconciliation)
distinguishes local access, opener delivery and real receiver access, and narrows
the SDK item-array silence. Antony selected continued
[internal investigation](long-action-route.md#internal-native-reference-investigation),
whose finite native-reference diagnostic is complete. The
[returned result and gap](long-action-route.md#native-reference-result-and-remaining-gap)
show that enumeration returns references at 1,024 bytes but tested consumers
reject them; the walk cannot reach the 1,500-byte subjects. The later
[item-array diagnostic](item-array-submission.md) delivers exact spelling at
900/1,023 but both openers fail at 1,024 before recorder delivery. The
[completed URL diagnostic](file-reference-url-acquisition-prototype.md) passes
local acquisition/reading/original bytes at 900/1,023 and fails acquisition at
1,024/1,500. Preserve its instrument stop, correction and expressly authorized
replacement. Long-path support is absolute. The [completed same-object diagnostic](same-object-namespace-prototype.md)
passes local identity/marker access at 900/1,500 bytes; long application/type
facts failed and a missed Zed trust stop leaves no compliant long receiver or
Finder-selection result. Antony accepted the incomplete report with no retry.
The separately completed
[focused Zed result and returned assessment](long-action-route.md#focused-zed-result-and-bookmark-question)
establish fresh reading of both original files by the exact short Zed copy after
restricted-mode choices. Long native application/type facts still fail; the
long buffer has an inode-only filename, exact delivery is opaque and saving is
untested. Antony authorized the finite local-only bookmark diagnostic on
2026-10-06; it remains unexecuted. Complete-route
obligations remain; no production exception or automatic follow-on is commissioned.
Native node-ID provenance cannot be replaced by an inode cast.
External inquiries remain unused drafts.
The refusal proposal is not adopted. No complete route, universal impossibility or native
action acceptance is established.

## Native consumers and distinct limits

| Stage | Evidence | What it establishes |
| --- | --- | --- |
| Supplied text | `LocalPath.validated` and `ApplicationRequest.validated` reject empty/relative/NUL paths; no byte-length test exists. Search can return 8,192 UTF-8 bytes. | A syntactically valid action input, not presence or actionability. The search output ceiling is not a new action input ceiling. |
| Resolution and native spelling | `NativeWorkspace.inspectPath` uses whole-path stat, realpath, then stat of resolved text. Application inspection starts with realpath. | These calls can fail before classification. Short source text can expand into a long target; long source text can contain redundant components. Source length cannot predict resolved/native length. |
| Classification and copy selection | Path resource values supply application/alias/type facts; application resource values and Bundle supply identity/identifier. Registered URLs are inspected and compared by native file identity. | Component-relative presence alone supplies none of these native classification/registration facts. A successful fsgetpath report supplies a location, not all action prerequisites. |
| Default-handler discovery | `defaultApplication(toOpen:)` passes the target file URL to `urlForApplication(toOpen:)`; the adapter returns only URL or nil. | Presence does not establish that this separate service can process a long URL. Nil has no error provenance; a supported applicable lookup must establish a no-handler report before NO_DEFAULT_HANDLER is justified. First-use long-file/directory prompting is unmeasured. |
| Submission and application reaction | NSWorkspace accepts URL/String inputs and returns completion/boolean acknowledgment. Launch/named-open selection submits the registered application's URL after native-identity equality; document open/reveal preserves the caller's target. | Record source, expanded, registered-app and submitted spellings/lengths separately. The registered application spelling need not equal applicationPath; this is identity-preserving selection, not a shorter surrogate. No documented 8,192-byte end-to-end guarantee was found. A controlled success proves mapping only. |
| Receipt observation | `observeProcess` compares the callback object's executable identity with the live process's identity. `proc_pidpath` supplies live text; both identities use `fileIdentity(ofPath:)`, symlink resolution and URL resource values. | A launch can acknowledge while these additional path consumers fail, yielding null process. Record the actual executable spellings, lengths and observation stage. Systematic length-caused null is not an accepted desktop-handoff loss. |

`PATH_MAX` in the installed SDK's public sys/syslimits.h is 1,024 bytes,
including NUL. It is not the maximum constructible filesystem location. The
already specified component-relative fixture construction can create a subject
without asking a whole-path mkdir/open to accept its full spelling. Native
construction and action outcomes for those subjects remain unexecuted here.

## Existing defect and proposed repair

The exact existing path is
`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`:

- `inspectPath` sends the original whole path to stat before realpath. Its
  `unavailable` helper maps ENAMETOOLONG and ELOOP to absent alongside
  ENOENT/ENOTDIR. `planPathOpen` and `planReveal` turn absent into PATH_NOT_FOUND.
- `inspectApplication` already maps non-ENOENT/ENOTDIR realpath failures to
  unreadable. This avoids the same ENAMETOOLONG branch, but does not make a
  roughly 1,500-byte constrained installation inspectable or launchable.
- `isMissing` treats Foundation's no-such-file error as absence without proving
  which underlying path operation failed. Higher-level classification failures
  need provenance too; changing only the POSIX switch is insufficient.
- Selection inspects the chosen bundle and all pertinent registered candidates.
  Failure to inspect a candidate whose equality to the chosen copy is unknown
  is failed. Do not discard that uncertainty as an unrelated missing copy.

The repair preserves the reviewed k75 rationale for a **demonstrably unresolvable
cycle** and a **component established to exceed its filesystem's native name
limit**: neither names an openable target, so open/reveal returns PATH_NOT_FOUND.
The two-link cycle and 300-byte ASCII component in the existing N fixtures stay
required regression subjects. Bare ELOOP cannot distinguish a cycle from an
exhausted finite-link budget; bare ENAMETOOLONG cannot distinguish an impossible
component from an extant long whole/expanded path. Without that distinction,
the result is **failed**. Whole/expanded path-size refusal and unresolved
link-budget exhaustion never prove absence. The route producer must explain
how it establishes each cause; this boundary supplies no new resolver.

ENOENT/ENOTDIR establishes a missing prerequisite only when its operation really
resolved the relevant spelling/component, rather than translating another
stage's failure. A Foundation no-such-file wrapper alone is insufficient where
the failing operation/cause is unestablished. Preserve stage and cause in human
guidance. Cancellation/deadline and post-submission failures retain their
existing meaning; none can produce a pre-submission dependency result.

### Fact provenance and established nils

| Fact | Established report and retained outcome | Failure or uncertainty |
| --- | --- | --- |
| Application/alias flags and file identity | Required native flags and identity acquired for the inspected target; native false is a fact. | Missing flags/identity, unsupported acquisition, malformed data or observed failure means failed, never a default false or absence. In particular nil isApplication cannot establish notApplication. |
| Content type | An applicable supported native metadata acquisition completes successfully for the target and reports no content type, with required flags established. This retains the accepted no-type non-refusal; it does not certify that contents are harmless. | A route that cannot acquire type must report failed, never manufacture contentType nil. Known long Mach-O/Windows/application/alias subjects must retain their native refusals. Successful short-path nil behavior is no evidence that a long acquisition succeeded. |
| Bundle identifier | A supported acquisition establishes a present native application with no declared identifier: an established absent Info.plist or a successfully obtained native bundle-information report with no identifier, without an observed read/parse failure. A named selector returns APPLICATION_IDENTITY_MISMATCH; a default handler needs no identifier. | Unresolved plist path, access/size refusal, observed malformed/unparseable report or failed identifier acquisition means failed. Nil Bundle construction or identifier alone is not enough. An undetected platform fault is not ruled out by a successful reported fact. |
| Registration/equality | Supported native registration reports and acquired native file identities establish membership/equality; selected paths retain their constraint. | An uninspectable candidate of unknown equality is failed, not a skippable missing copy. Repair long-candidate inspection without losing short workflows. |
| File default handler | A supported lookup applicable to the exact inspected target establishes the native no-handler report; a returned handler also passes presence/classification inspection. | Current URL-or-nil carries no failure cause. A present long target plus nil is insufficient by itself; unestablished lookup means failed, not NO_DEFAULT_HANDLER. No generic/type/extension fallback is selected. |

The private inspection outcome must distinguish completed facts (including
established optional nils) from unacquired facts before constructing PathFacts
or ApplicationBundle. Existing unreadable outcomes can carry refusal; L may
substitute them but does not verify the real adapter's acquisition. The route
producer owns the exact supported acquisitions and provenance representation.
No content reads, new prompting route or entitlement is approved by this rule.

### Compatibility and implementation obligations

This is unimplemented. Existing 1.0.0 evidence describes that retained bundle,
including its broad errno mapping; it is not a repaired-provider pass. The
accepted concrete cycle/name-limit/nil outcomes above are retained. A compatible
action-only repair is designated workspace release/schema **1.0.1**, under
`koine-desktop/1`, with unchanged coordinates, nullability, capabilities and
error kinds. Its [exact designed descriptions](../design/workspace-action-repair-schema.graphql)
add provenance requirements to the launch/open/reveal fields. The retained
[1.0.0 SDL](../design/workspace-schema.graphql), captures, profiles and binaries
stay independent. The search release/schema **1.1.0** incorporates the repaired
action descriptions alongside its search contribution; it is a third subject.

Changed canonical descriptions must change the composed schema digest on the
same host/printer. A numeric served digest cannot be specified before that
actual composition exists; a digest also cannot identify which binary ran.
Planning adds an exact action-repair profile/composed SDL with full candidate
rows (bundled workspace 1.0.1/schema 1.0.1, desktop 1.0.0), plus a retained-host
approved per-user 1.0.1 variant with SELECTED/PER_USER and NOT_SELECTED/BUNDLED
1.0.0 pins. Pair independent old/new providers and compatible hosts; neither
rebuilding the baseline nor relabelling a historical update retains it.

The compatibility judgement is a correction of unjustified negatives for
extant/unestablished targets, preserving the documented concrete short-path
and established-nil behavior. If the route requires reversing those outcomes,
an incompatible meaning, short-workflow loss or systematic null long-app
receipts, stop for Antony's decision before adoption. No such trade-off is
accepted here. Planning must reconcile the native errno/Foundation/plist
comments and mapping, N fixture provenance, contract-only client coverage and
its findings record with this contract. Those implementations remain unchanged
in this design integration.

## Primary source and SDK support

[Apple's published realpath implementation](https://github.com/apple-oss-distributions/Libc/blob/main/stdlib/FreeBSD/realpath.c)
allocates PATH_MAX even with a null destination, uses PATH_MAX scratch arrays,
and reports ENAMETOOLONG when input, appended text or expanded links exceed its
buffers. Passing nil does not select an unlimited allocator. This supports the
proposed failure correction; this historical published source is explanatory,
not proof of the guest's libc implementation or errno at a particular length.

[Apple's attribute path builder](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/vfs/vfs_attrlist.c)
starts at MAXPATHLEN and grows only when the process supports long paths.
[Its policy dispatch](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/kern_resource.c)
includes a long-path policy; the installed public sys/resource.h does not
declare its selector. The public sys/attr.h mentions the policy in its buffer
comment. That comment and a larger caller buffer do not authorize manufacturing
the private selector, changing process policy or adding an entitlement.
Nor does this source prove that every NSURL resource query requests a full path.
The precise resource-key implementation and long-path outcomes remain open.

The installed public headers declare openat/fstatat/readlinkat and fsgetpath.
These support component-relative lookup and directory-path observation as
candidate mechanisms. They do not by themselves supply application/alias/type
classification, bundle identifier, registration equality or native submission.
Their new prompt/materialization behavior is unaccepted by the earlier
[protected metadata measurement](protected-path-metadata.md).

The public File Manager/Launch Services headers also declare deprecated
FSMakeFSRefUnicode, FSCompareFSRefs, LSCopyItemInfoForRef and LSCopyItemAttribute.
[Apple describes reference-based item information](https://developer.apple.com/documentation/coreservices/1445227-lscopyiteminfoforref?changes=l_4&language=objc)
and [reference-based attributes](https://developer.apple.com/documentation/coreservices/1445023-lscopyitemattribute?changes=_4_8).
These are candidates to evaluate, not a selected complete action route. In
particular, public CFURL.h marks CFURLCreateFromFSRef and CFURLGetFSRef
deprecated with “Not supported”; merely linking them cannot establish a
supported modern conversion to the existing NSWorkspace submission. The alias
flag also includes symlinks, so equivalence to the existing post-resolution
Finder-alias refusal cannot be assumed. Any candidate must explain acquisition,
resolution, identifier/identity provenance and parity of all native facts.

The current public
[application launch](https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:))
and [Finder selection](https://developer.apple.com/documentation/appkit/nsworkspace/selectfile(_:infileviewerrootedatpath:))
remain the submission design. A different primitive must demonstrate the same
copy constraint, configuration, activation authority and acknowledgment semantics;
legacy LS submission is not an automatic fallback. Never replace the selected
location by a shorter link, /dev/fd path, file-reference spelling, working-directory
change or another installation to claim the original handoff passed.

## Independent subjects for the route design

| Subject | Controlled adapter / real provider | Independent native and signed-VM witness |
| --- | --- | --- |
| Ordinary long file — action acceptance | L real provider with WorkspaceNative substitution checks planner responses to supplied present/absent/unreadable outcomes; G checks exclusive branches and original alias error paths. N exercises real adapter stage/cause mapping on component-created host fixtures. | Launch-and-open owns a component-created measured roughly 1,500-byte text-file location, independent of search. Pass exact fixture bytes to default open, named Zed open and reveal under both controls. Independently observe delivery/rendering and Finder selection; record native stages, cause, prompts and submitted bytes. No acknowledgment alone closes a working case. |
| Long constrained installation — action acceptance | Equal chosen/registered native identities despite spelling variants; unknown equality is failed. Wrong identifier differs from unacquired identifier. L checks planner mapping; N checks real acquisition. | Launch-and-open component-creates/registers a long fixture app with another same-identifier short copy running. Feed measured identifier AND applicationPath to cold/warm launch and named open. Record caller, resolved, registered and submitted spellings, each copy's identity/delivery, receipt process/null stage and independent kernel/executable identity. Registration failure leaves the working case pending. Systematic length-caused null is a defect, not accepted handoff loss. |
| Actual search-to-action handoff | Search G/N subjects use the accepted repaired action provider and preserve selected identifier AND path; no adapter-injected result proves provenance. | App-and-file-search owns additional end-to-end G/N/V cases: actual search returns the roughly 1,500-byte file and long app, then unchanged selected values drive default/Zed open, reveal and constrained cold/warm launch/named open. Retain all independent witnesses. No search-result injection closes these rows; action fixtures alone cannot close them. |
| Source versus expansion | Separate planner outcomes for established missing/below-file/dangling/cycle/impossible-component absence, whole/expanded size refusal, unproven cause and finite link-budget exhaustion failure. L supplies outcomes; N tests real mapping. | Record actual components, target and identity for short-to-long links, long redundant source to short target, trailing slash/dot below file, two-link cycle, an established over-name-limit component and an acyclic chain exceeding the resolver budget. Construction/earlier failure leaves the intended subject pending. Repeat raw 1,023/1,024/1,025 text bytes and 8,191/8,192-byte locations where constructible, without inferring support from lengths. |
| Short workflows with long registered copies | Unknown candidate equality stays failed; no discard, preferred-copy substitution or removal of applicationPath repairs inspection. L supplies both registration orders and preferred-long answers. | N/V register short and long same-identifier copies. Short constrained launch/named open work with either enumeration order; unconstrained launch/named open work when the long copy is preferred. Check Finder readiness/reveal under any long same-identifier registration the guest admits. An unconstructible Finder copy/registration leaves that native subject pending; L does not pass it. Any measured regression requires repair or Antony's explicit loss decision. |
| Default-handler acquisition and prompt boundary | L tests established no-handler versus acquisition failure; N exercises provenance rather than only URL/nil mapping. | First-use long unprotected file/directory with a known handler, plus an independently established no-handler item; measure handler lookup separately from inspection/submission. Long protected file/directory prompt subjects stay with the existing protected-default-open decision; no new consent is granted. A failure before lookup leaves its prompt subject pending. |
| Long payloads | Application, Unix/Windows program and native alias are refused for opening; source scripts and document packages preserve native classification. Reveal remains eligible. | Actual long bundle, package, alias and symlink subjects, with independent identity/classification observations. No guessed extension/type or executable-bit policy substitutes for the existing native refusal contract. |
| Permission and completion | Either control alone refuses before inspection; cancel between stages; false/error/no/late callback, three-second wait and earlier core deadline. | Signed Koine with existing empty entitlements/usage keys, Accessibility absent/revoked and independently observed TCC/dialog/hydration state. Protected default-document lookup and app-reveal notice remain their existing human decisions. No consent is granted to close a new read failure. |
| Compatibility | Independent 1.0.0, action-repair 1.0.1 and search 1.1.0 description/digest/profile subjects; unchanged action shape and error kinds. Description-only delta control does not prove runtime mapping. | Retained old bundle/host versus independently compiled repaired bundle on compatible hosts, with full exact candidate pins and public/grant outcomes. Repeat cycle/component/established-nil subjects and all short workflows. Search-serving end-to-end binaries remain distinct. |

The existing seams remain L (private adapter enabling point), G (public GraphQL),
N (independent provider/host binaries) and V (signed isolated macOS). No new
public seam is proposed. L does not exercise the errno/Foundation/plist mapping
inside the substituted adapter; N host fixtures and V guest fixtures do. Before
crediting any long observation, positively control each delivery, Finder-selection
and identity observer using the same long subject selected/opened/launched by an
independent non-Koine route. Record exact bytes and native identity. The prior
short Finder AppleScript observation is not a long-path control; an observer
limit leaves the observation pending and cannot pass or fail Koine.

Launch-and-open planning owns action implementation/native acceptance after the
reviewed route. Search planning later owns actual-search handoff acceptance;
it consumes that accepted action provider and retains its own mandatory route
design prerequisite. This split preserves the whole workflow without a
search-implementation prerequisite on the earlier action acceptance. Failure of
the ordinary long-file or constrained-app
working case is not an accepted omission; report the measured lost workflow to
the existing operator decision before baseline acceptance. Search's witness,
replay and classification producers remain live and are not resolved here.

## Provenance and deterministic check

The graph CLI refused to start because a pre-coordination or unverified active
generation exists. No project/generation or graph coverage verdict was available;
the exact provider logic, current documents and installed SDK headers were read
directly. No exhaustive codebase claim is made.

`task design:long-action-api-check` compiles/links the
[public declaration probe](long-action-native-boundary/api-check.c) without
executing it. It checks SDK signatures and link resolution against the SDK's
`.tbd` export stubs, not symbol presence or behavior on a guest. Its
deprecated declarations are intentional candidates, not chosen production APIs.
The command uses arm64, macOS 26.0 deployment and the currently selected SDK.
The check passed with SDK 27.0 and Apple clang 21.0.0
(`clang-2100.3.34.2`), targeting arm64/macOS 26.0. The task now includes an
`nm -u` membership check for all nine intended imports; it still never executes
the probe. No fixture, protected
metadata, search, launch, open or reveal was run on the developer machine.
