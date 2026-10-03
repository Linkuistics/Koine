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

## Four different limits

| Stage | Evidence | What it establishes |
| --- | --- | --- |
| Supplied text | `LocalPath.validated` and `ApplicationRequest.validated` reject empty/relative/NUL paths; no byte-length test exists. Search can return 8,192 UTF-8 bytes. | A syntactically valid action input, not presence or actionability. The search output ceiling is not a new action input ceiling. |
| Resolution and native spelling | `NativeWorkspace.inspectPath` uses whole-path stat, realpath, then stat of resolved text. Application inspection starts with realpath. | These calls can fail before classification. Short source text can expand into a long target; long source text can contain redundant components. Source length cannot predict resolved/native length. |
| Classification and copy selection | Path resource values supply application/alias/type facts; application resource values and Bundle supply identity/identifier. Registered URLs are inspected and compared by native file identity. | Component-relative presence alone supplies none of these native classification/registration facts. A successful fsgetpath report supplies a location, not all action prerequisites. |
| Submission and application reaction | NSWorkspace accepts URL/String inputs and returns completion/boolean acknowledgment. | Representation, inspection and actual submission are separate questions. No documented 8,192-byte end-to-end acceptance guarantee was found in the cited APIs. A successful controlled adapter return proves mapping only. |

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

Selected repair for the eventual action provider: a size/refusal, unresolved
link limit, incomplete/malformed native metadata, or classification failure
without independently established absence is **failed**, not PATH_NOT_FOUND,
APPLICATION_NOT_INSTALLED, identity mismatch or NO_DEFAULT_HANDLER. Preserve
the stage/cause in human guidance; no new public enum or error kind is needed.
ENOENT/ENOTDIR establishes a missing prerequisite only when its operation really
resolved the relevant spelling/component, rather than translating another
stage's failure. Cancellation/deadline and post-submission errors retain their
existing meaning and cannot produce a pre-submission dependency result.

This is a design correction, not a claim that the current 1.0.0 bundle already
implements it. Its existing short-path evidence stays valid for its actual
subjects. The retained baseline must remain independently pinned; the repaired
provider needs its own public description/digest and binary acceptance.

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
| Ordinary long file | Real provider with WorkspaceNative substitution distinguishes lookup, metadata refusal, absent and acknowledged stages; G checks exclusive branches and original alias error paths. | Component-create a measured roughly 1,500-byte text-file location; an actual search returns it. Pass the exact bytes to default open, named Zed open and reveal under both controls. Observe handler delivery/rendering and Finder's selected location independently. Record each call/result/errno, prompt and submitted bytes. No search-result injection closes this row. |
| Long constrained installation | Chosen and registered candidates have equal native identities despite spelling variants; unknown candidate inspection is failed. Wrong identifier is distinguished from failed identifier acquisition. | Component-create and register an actual long fixture app, with another copy of the same identifier running at a short location. Feed the actual search identifier AND applicationPath unchanged to cold/warm launch and named opening. Each copy logs its own identity/delivery; independent process evidence detects substitution. Native registration failure remains a pending subject, not not-installed acceptance of the required working path. |
| Source versus expansion | Short-to-long link, long redundant source to short target, trailing slash/dot below a file, dangling link, component overlength and link-bound exhaustion have separate outcomes. | Guest helper records actual components/target/identity. Any failed construction or earlier native failure leaves the intended boundary pending. Repeat raw 1,023/1,024/1,025 text bytes and public 8,191/8,192-byte locations where constructible, without inferring action support from these lengths. |
| Long payloads | Application, Unix/Windows program and native alias are refused for opening; source scripts and document packages preserve native classification. Reveal remains eligible. | Actual long bundle, package, alias and symlink subjects, with independent identity/classification observations. No guessed extension/type or executable-bit policy substitutes for the existing native refusal contract. |
| Permission and completion | Either control alone refuses before inspection; cancel between stages; false/error/no/late callback, three-second wait and earlier core deadline. | Signed Koine with existing empty entitlements/usage keys, Accessibility absent/revoked and independently observed TCC/dialog/hydration state. Protected default-document lookup and app-reveal notice remain their existing human decisions. No consent is granted to close a new read failure. |
| Compatibility | Old action-only description/digest/profile and new repaired-provider description/digest/profile are separate; same input/result coordinates and existing error kinds. | Independently retained old bundle/host and separately compiled repaired bundle on compatible hosts; exact candidate versions, grants, public errors and short-path regression subjects. Search-serving end-to-end binaries remain distinct from action-only retained compatibility evidence. |

The existing seams remain L (private adapter enabling point), G (public GraphQL),
N (independent provider/host binaries) and V (signed isolated macOS). No new
public seam is proposed. Planning owns executing these subjects after a reviewed
route is established. Failure of the ordinary long-file or constrained-app
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
executing it. It checks SDK signatures and symbol availability only. Its
deprecated declarations are intentional candidates, not chosen production APIs.
The command uses arm64, macOS 26.0 deployment and the currently selected SDK.
The check passed with SDK 27.0 and Apple clang 21.0.0
(`clang-2100.3.34.2`), targeting arm64/macOS 26.0. An `nm -u` check found imports
for all nine intended symbols. The probe was not executed. No fixture, protected
metadata, search, launch, open or reveal was run on the developer machine.
