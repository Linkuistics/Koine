# Long-location route evaluation

The evaluated public mechanisms do **not yet justify a complete supported
route** under the retained action contract. They provide useful candidates,
not evidence that the required working cases fail or that every public route
is impossible. No provider implementation or native action ran in this design
session. The [reviewed boundary](long-action-native-boundary.md) and its
independent action/search subjects remain binding.

The selected prototype ran; its measured results and recommendation are in
[long-action-route-prototype.md](long-action-route-prototype.md).

Start with the [candidate and gap view](../design/architecture/index.html#diagram-workspace-route-candidates).
The source evidence below supports a bounded decision, rather than another
open-ended evidence chain. A route, final review and action acceptance remain
required before the search handoff can close.

Antony delegated the prototype-versus-pending choice with "you decide". The
recommended **one bounded native prototype** is selected under the existing
public-API/signing/consent posture. Grove now orders source evaluation k133,
native prototype k134, then returned route design k135 beneath k130. This
selects the finite investigation, not a supported route or native acceptance.

## Supported candidates and remaining gaps

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

**Selected under Antony's "you decide" delegation: one bounded native prototype
before settling the route**, under the existing signing/consent posture and
public APIs only. This changes the source-first ordering for that finite
investigation. Production implementation and full native acceptance remain
planning's work after a supported/reviewed route. The prototype is chartered as
long-action-route-k134, followed by returned design long-action-route-k135;
neither has run in this source-evaluation session.

| Choice | Benefit | Cost and consequence |
| --- | --- | --- |
| **Selected:** one bounded prototype, then return to design | Tests the strongest public candidates against the actual required cases rather than treating undocumented length behavior as established. | One isolated native investigation before an implementation-ready route exists. Any failed or unobserved prerequisite leaves its row pending; no automatic follow-on evidence chain or workflow-loss acceptance. |
| Considered alternative: leave the route pending until stronger supported evidence is supplied | Retains the source-first boundary without adopting a speculative acquisition. | Long-location actions and downstream search consumers would remain live. This would not reject the workflows or claim impossibility. |

Private policy/entitlement, shortening, another app copy, type/extension guesses,
copy-only operation and systematic null receipts are outside both choices.
There is no measured workflow-loss trade-off to approve from this session.

The selected prototype is **one session with one result**, not an implementation
plan: component-create a measured roughly 1500-byte ordinary file and a modern
application bundle, then acquire reference flags/type, selected-copy identifier
with explicit read/parse provenance, registration equality and exact-item binding.
Prepare independent executable-identity observers and measure action receipts
after submission. Compare the candidate metadata route with the
existing native route on short controls, no-type/no-identifier, malformed/denied
metadata, scripts/packages, aliases/programs/apps, cycle/component/link-budget
causes and short selection with long registrations. Explicitly evaluate the
metadata-read scope and conventional/other native bundle-layout parity; do not
adopt a fixture-only layout policy as a general route.

Only if applicable pre-submission prerequisites are established, submit unchanged bytes to default
and Zed open/reveal and constrained cold/warm launch/named open with another
same-identifier copy running. Record source, expanded, registered and submitted
spellings and lengths separately. Positively control independent long-path
delivery, Finder-selection and kernel/executable observers before using them.
Distinguish failed submission, failed receipt acquisition and an unestablished
observer; a native acknowledgment alone cannot establish receipt identity.
Observe first-use reads/handler lookup and stop on a new consent/setup need.
Do not request consent to turn a failure into a pass. A prerequisite failure
must not produce misleading submission or prompt-absence results.

Present supported mechanisms, actual failures and unresolved observations against
those subjects, with a specific recommendation for Antony's reaction. His
delegation settles execution of this prototype; any measured workflow-loss or
read-posture trade-off still requires its own concrete decision before adoption.
Do not grow a second
prototype/evidence leaf automatically. A successful prototype could inform a
route proposal; it would not replace the parent's final review, independent
provider/public/binary/action acceptance, later actual-search G/N/V provenance,
or k93's measured omissions decision. Preserve the exact retained 1.0.0,
action-only 1.0.1 and search 1.1.0 descriptions/digests/candidate profiles.

## Deterministic check boundary

`task design:long-action-api-check` compiles and links the declaration probe and
checks intended imports against SDK stubs, with a removed-import negative
control. It does not execute the probe or verify symbols on a guest.
`task design:action-repair-check` and `task design:search-check` check retained
versus repaired descriptions, action shapes and examples; they prove no native
route or outcome. `task design:workspace-render` renders the candidate view;
`task check:docs` checks document links. Native working subjects remain pending.

The expanded declaration/import task passed with SDK 27.0 and Apple clang
21.0.0, including the removed-import control. Independent/composed action SDL,
the three-description repair delta and search/action examples passed their
existing negative controls. These results establish declarations and document
structure, not a complete acquisition route. The probe was never executed.
