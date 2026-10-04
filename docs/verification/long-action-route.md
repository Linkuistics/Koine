# Long-location route evaluation

**The retained long-location route is unresolved after the finite prototype
and requested prior-art survey.** Parent-relative filesystem operations can
reach the items; the tested public classification, registration, handler and
submission APIs cannot complete the required roughly 1,500-byte workflows.
This is bounded evidence about tested mechanisms, not universal impossibility.
No production route or workflow loss is adopted.

Start with the [measured boundary and decision view](../design/architecture/index.html#diagram-workspace-route-candidates)
and the [retained requirement and research commission](#decision-for-antony). The
[prototype](long-action-route-prototype.md) supplies the committed native
measurements; the [prior-art survey](../research/prior-art-long-paths-a.md)
answers the representation question. The [reviewed boundary](long-action-native-boundary.md),
independent action/search subjects and separate compatibility profiles remain
binding. This returned design performs no new native action investigation.

Antony explicitly retained the original requirement and requested broader
research into how real applications deal with long pathnames across use cases
and contexts. The refusal recommendation is not adopted. An independent survey
pair and synthesis are commissioned before returned route design; they will
trace actual representations, operations and process boundaries. No new native
experiment is authorized. A supported route, final review and action acceptance
remain required before the search handoff can close.

## Source candidates and remaining obligations

| Consumer | Positive public evidence | Unsettled obligation |
| --- | --- | --- |
| Presence and literal resolution | SDK `openat`, `fstatat`, `readlinkat` and `fpathconf` support parent-relative operations; `FSMakeFSRefUnicode` constructs an object reference from a parent reference and a Unicode name. | Preserve byte spellings, symlink expansion, actual directory traversal for dot/dotdot, trailing separators, dangling links and below-file results. New inspection calls need prompt/materialization evidence. A native reference is not a submission location. |
| Payload flags | `LSCopyItemInfoForRef` returns requested native item flags with OSStatus, including application, package, alias and symlink flags. | The alias flag includes symlinks. Resolve POSIX symlinks before acquiring flags for opening, retain the original location for reveal, and establish equivalence with the existing native refusal set. No suffix or executable-bit inference supplies a flag. |
| Content type | `LSCopyItemAttribute` with `kLSItemContentType` is a native UTI acquisition; the SDK documents `kLSAttributeNotFoundErr` for a missing attribute. | A checked applicable missing-attribute report can carry established no-type; an arbitrary NULL or other error cannot. Current UTI/payload parity at long locations is unmeasured. Do not pass an unacquired type through the accepted nil non-refusal. |
| Identity and registration selection | `FSCompareFSRefs` documents equality of native objects, with `errFSRefsDifferent` as a distinct result. `NSWorkspace` supplies preferred and all registered URLs; each exact URL can be inspected component by component without converting an FSRef to a URL. | Check reference construction and comparison errors; preserve registration uncertainty and both enumeration orders. APFS reference performance and races remain native questions. A registration query for an identifier does not establish the selected bundle's currently declared identifier. |
| Bundle identifier | `CFBundleCopyInfoDictionaryForURL` is public and supplies a bundle-information dictionary. Public bundle structures explain conventional application metadata locations. | Neither that dictionary-only API nor the inspected LS item-attribute catalogue provides the needed selected-copy read/parse provenance. Historical CF source has path buffers and empty-dictionary failure branches. Component-relative metadata parsing is a candidate, but native bundle-layout/identifier equivalence and unchanged read behavior must be established before adopting it. |
| Exact-item default handler | `LSGetApplicationForItem` consults the item's binding, including a user override; the SDK documents `kLSApplicationNotFoundErr`. Its app-reference and app-URL outputs are separately optional. | This is a stronger candidate than the existing URL-or-nil result, not a type/extension fallback. Establish target/handler identity, output validity and long-item parity; first-use prompts remain unmeasured. An applicable checked not-found report alone can justify NO_DEFAULT_HANDLER. |
| Submission | The existing public NSWorkspace primitives take an application URL, document URL or Finder path. Reusing them preserves configuration, acknowledgment and the supplied document/reveal location at Koine's call boundary. | Those signatures do not prove processing/delivery of the required long URLs. Application submission must use the exact selected registered URL, with running-copy substitution disabled for a constrained request. A shortened link, file-reference URL or legacy open primitive would change the question. |
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

The survey found directory handle plus relative name in systems that perform
over-limit filesystem work. Component lists are resolver working state; the
survey found no admitted macOS opener interface that accepts them. Keep the
public location string: an array at Koine's GraphQL boundary would require
clients to reconstruct the same input and would leave the native handoff gap.
This is an inference from the bounded survey, not proof that no such API exists.
The newly commissioned application surveys will examine concrete workflows
beyond that survey's API/representation coverage; they have not yet delivered
findings and do not change this bounded observation.

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
- File-reference/volfs locations replace the caller's path with an identity
  spelling and are excluded. [Apple's kernel test](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c)
  supports volfs *file opening*, not NSWorkspace delivery/registration/receipt
  behavior; [Apple DTS](https://developer.apple.com/forums/thread/103162)
  cautions against relying on it where fsgetpath is available.
- Short links/aliases, another app copy, legacy openers and the private
  long-path policy remain excluded. Policy on Koine alone would not establish
  behavior in the separate service and receiver processes.

The survey's unauthorized host leads are not design evidence and were not rerun.
An excluded representation could be reconsidered only by a concrete new decision;
its kernel reachability alone would still leave classification, selection,
delivery, receipt and no-prompt behavior unproved.

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

The commissioned process has two independent surveys with the same brief,
followed by synthesis and returned route design. The existing dispatch policy
supplies different providers for the two surveys; it is unchanged. Both survey
sessions seek breadth and primary evidence independently. Synthesis owns the
adversarial move, disagreements and correlated-source checks.

| Step | Concrete question and deliverable |
| --- | --- |
| Independent application survey A | Trace real long-pathname workflows through file managers/editors/launch, build/package/repository tools, archive/copy/backup/sync and remote/virtual namespaces. Deliver `docs/research/long-pathname-applications-a.md`. |
| Independent application survey B | Answer the same brief without reading A, seeking an independent primary-source corpus. Deliver `docs/research/long-pathname-applications-b.md`. |
| Synthesis | Union evidenced coverage, preserve contradictions and silences, test apparently transferable mechanisms against reconstruction/receiver limits and distinguish shared-source agreement from corroboration. Deliver `docs/research/long-pathname-applications.md`. |
| Returned route design | Consume the synthesis, establish the retained supported route and reconcile artifacts, or present the exact remaining gap and concrete proposal to Antony. No further experiment or automatic research chain is selected. |

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

The commissioning increment completes only this authorization, task sequence
and current design record. Its completion signal advances the driver to fresh
research sessions; it does not close the unresolved route nodes. Final design
still owes the complete supported acquisition/submission route and k128's
mandatory `long-search-result-actions` review before search consumers or
implementation planning. Independent component-created action fixtures and
later actual-search G/N/V provenance remain separate acceptance subjects.
Retained 1.0.0, action-only repair 1.0.1 and search 1.1.0 stay independent.
No ADR selects an unestablished route or an unaccepted workflow loss.

## Deterministic check boundary

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
