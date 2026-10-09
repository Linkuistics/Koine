# Native discovery source boundary

**Source analysis behind the designed contract; native acceptance remains pending.**
The [native design](../specs/workspace-search.md) selects the sources below;
[finite acceptance](native-discovery-acceptance.md) qualifies their actual runtime
behavior and exact new binaries. Public declarations alone are no such pass.
The [v1 ownership agreement](../adr/raw-filesystem-search-belongs-to-clients.md)
requires OS-known starting locations and useful application/modern System
Settings catalogues, with prompt-free, non-hydrating reads. This analysis
establishes candidate sources. The focused human requirements decision below
selects the preferred settings route and permits conditional explicit setup;
it qualifies no backend or native event and implements no signing change,
consent operation, schema or reduced useful inventory.

Start with [Native sources → What each source can establish](../design/architecture/index.html#diagram-native-discovery-sources)
and [System Settings → Agreed source and permission boundary](../design/architecture/index.html#diagram-native-settings-decision).
The archived raw-search [SDL](../design/comparison/workspace-search-schema.graphql),
[examples](../design/comparison/workspace-search-operations.graphql) and
[measurements](search-tooling.md) remain comparison material. They are not a
native catalogue API or acceptance record.

## Evidence and scope

Read-only inspection used the installed public SDK headers and Apple's shipped
System Settings data, not an executable probe. The workstation's system-version
property list reports macOS **26.6.2 (25G83)**; the installed SDK's settings
property list reports **macosx27.0**. These are different subjects. The APIs below
declare availability before macOS 26, but SDK 27 declarations and one macOS 26
source layout do not establish behavior across the supported macOS 26+ Apple
Silicon matrix. The existing macOS 26.5 VM records retain their original bounds.

The inspected SDK surfaces were Foundation's `NSPathUtilities.h` and
`NSMetadata.h`, AppKit's `NSWorkspace.h`, Launch Services' `LSInfo.h`, AE's
`AppleEvents.h`, ServiceManagement's `SMAppService.h` and EndpointSecurity's
`ESClient.h`. The installed application source subjects were
`/System/Applications/System Settings.app/Contents/Resources/`'s
`SystemPreferences.sdef`, `Sidebar.plist` and `Sidebar124.plist`, and the
application's `Contents/Info.plist`. The OS/SDK version property lists identify
the subjects; hashes retained with the local check outputs identify their bytes.

For existing action behavior, bounded source reads covered
[the real native adapter](../../Providers/WorkspaceProvider/Sources/NativeWorkspace.swift),
[selected-application planning](../../Providers/WorkspaceProvider/Logic/ApplicationStage.swift),
[the descriptor and resolver](../../Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift)
and [the shipped manifest](../../Providers/WorkspaceProvider/manifest.json).
The codebase graph CLI refused startup because a pre-coordination/unverified
generation was active. This report therefore uses source fallback and claims no
graph generation, complete graph coverage or repository-wide absence proof.

No metadata query, Apple event, settings launch/reveal, backend subprocess,
permission request, helper, build/signing change or VM experiment was performed.
Public API documentation and source availability are evidence of interfaces,
not no-dialog/no-hydration, useful-category or serviceability passes.

## OS-known starting locations

Foundation supplies home and significant-directory values. The proposed useful
v1 selection is Koine's current-user home plus Desktop, Documents, Downloads,
Movies, Music, Pictures and application directories in declared user/local/system
domains. The client must see the account/domain provenance: Koine's home is not
the remote client's home. Application-directory results may contain several
locations, and the OS's value ordering is not a search recommendation.
[Directory constants](https://developer.apple.com/documentation/foundation/nssearchpathdirectory)
and [location lookup](https://developer.apple.com/documentation/foundation/filemanager/urls(for:in:))
provide the public interface.

Use value lookup, never a create-enabled lookup. Do not resolve, test existence,
list contents, read resources, follow an alias or request a bookmark merely to
return a starting value. A location may not exist or be accessible. Missing or
unrepresentable values need diagnostics, while contents availability remains
unknown. Cloud/redirection/account state can change the later client's access.
This operation does not require choosing a process-wide materialization policy.
Actual prompt-free value lookup remains a signed-host acceptance obligation.

The final contract should accept only named kinds/domains, with no arbitrary
path, predicate or file query. Temporary/application-container paths, network
mount inventories and iCloud account/container enumeration are not selected
by this useful starting set; adding them needs a concrete consumer requirement.

## Native application catalogue

| Candidate | Positive evidence | Limit and consumer consequence |
| --- | --- | --- |
| Indexed Spotlight application-category query | Public metadata query can return application-bundle observations beyond a fixed launcher list. A fixed application content-type predicate and indexed-local scope keep the product category-specific. | Scope includes indexed local volumes and even a remote home. Index exclusions, stale data and omitted system locations mean it cannot certify every app on disk. Prompt/contact/hydration and actual useful choices need qualification. |
| Generic running-application observations | Public running application objects supply observed bundle URLs and identifiers. | Running apps are a useful supplement, not an installed-app inventory. No client query may launch an app to improve this source. |
| Public per-identifier registration lookup | URLs for known identifiers can discover multiple installed copies, including locations outside a conventional application folder. | It requires identifiers from another source. Configured launchers and known system identifiers are witnesses/supplements, not the definition of all apps. |
| Conventional directories, find, recursive enumeration | Could discover filesystem names outside the index. | Reintroduces server-owned raw search as fallback. It is outside the agreed native-only design. |

The relevant public sources are
[metadata query](https://developer.apple.com/documentation/foundation/nsmetadataquery),
[indexed-local scope](https://developer.apple.com/documentation/foundation/nsmetadataqueryindexedlocalcomputerscope),
[running applications](https://developer.apple.com/documentation/appkit/nsworkspace/runningapplications)
and [all registered copies for an identifier](https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:)).
SDK `NSMetadata.h` distinguishes indexed-local scope from local-computer scope;
do not silently replace it with a wider scope. The latter is the route discussed
by the older [Spotlight guide](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/SpotlightQuery/Concepts/QueryingMetadata.html).
That guide documents user exclusions and unindexed classes; it promises no
exhaustive modern all-app inventory.

**Selected by the native contract, runtime qualification pending:** use a fixed indexed application
category as the breadth source, supplemented by generic running observations
and registration expansion for observed identifiers. Keep the two concepts
separate: breadth discovery and validating each observed installation.
Do not implement it until k191's source-specific access contract and later
signed acceptance establish the required read behavior. A protected Desktop
Spotlight query [previously prompted](search-discovery.md#exact-mechanisms-and-results).
That is a concrete counterexample to assuming any metadata query is prompt-free;
it does not prove this different indexed application predicate safe or unsafe.
Post-result pruning cannot undo a prompt or metadata contact already caused by
the native source. If the proposed source cannot meet the read policy, return
that exact gap rather than substitute a launcher-only list.

The existing action adapter's AppKit list-plus-preferred lookup supplies no error-bearing
negative fact. The earlier [SDK analysis](search-native-resources.md#call-health-is-separate-from-descriptor-visibility)
identifies `LSCopyApplicationURLsForBundleIdentifier` with `outError` as a
deprecated but declared alternative. The current SDK retains its documented
not-found error. The [native source contract](../specs/workspace-search.md#application-sources-and-native-facts)
selects the declared error-bearing API for breadth and conservative checked
negatives, accepting its deprecation/qualification cost and keeping UNKNOWN
when it is unusable. Positive eligibility follows the accepted action's ordered
AppKit list plus preferred-only candidate; their disagreement is observed, so
do not treat a preferred-only copy as a contradiction or presume the two APIs
equivalent. Empty AppKit arrays,
nil bundle identifiers, malformed values and failed identity acquisition cannot
establish absence or an unregistered installation.

Preserve distinct same-identifier copies. Only established bundle-directory
identity can merge aliases; failed identity acquisition is unknown, not a merge.
Existing selected actions re-resolve the identifier and path independently.
Bundle metadata inspection is individual-target work with the existing bounded
lookup/contact limits; this report authorizes no contents-listing exemption,
arbitrary metadata-file reader or hydrated placeholder access. A long native
location may remain representable while whole-path bundle metadata and later
action handoff are unsupported. Its admitted indexed-item projection below is
reported native metadata, not a descriptor-relative bundle reader. No incorrect
known witness is accepted as an opaque platform-health limit.

### Long application source construction

Read-only SDK 27 analysis of Foundation NSMetadata.h and Metadata MDItem.h
establishes a pathname-free **calling interface** on an already returned item:
resultAtIndex returns an object; valueForAttribute retrieves its fixed attributes.
MDItem.h declares kMDItemContentTypeTree as an array of native strings,
kMDItemCFBundleIdentifier as a bundle identifier, kMDItemDisplayName as a localized
display name, and kMDItemPath as the item's complete path. Apple's
[metadata-item interface](https://developer.apple.com/documentation/foundation/nsmetadataitem)
and [query update contract](https://developer.apple.com/documentation/foundation/nsmetadataquery/disableupdates())
support this object projection. They promise neither long-location importer
support nor prompt-free getters nor a binding between a cached tuple and a
currently resolved inode. No native query/getter was executed in this design.

Select those four attributes only from actual items returned by the existing
fixed indexed-local application query. The query predicate alone is no type
check: require an exact native com.apple.application-bundle tree member from that
same item, and independently resolve the tuple's literal path to a present
directory before/after its metadata episode. Keep equal device/inode and the
unchanged first finalized resolved spelling. A running bundle identifier and a
registration URL cannot supply missing type/identifier/name for a different copy.
No NSMetadataItem(url:), MDItemCreate, arbitrary attribute/plist, ancestor listing,
new query/scope, private database or short-alias reader is admitted.

The complete localized resource boundary is unresolved after review k210/R2.
The 20-byte known-plist suffix below is necessary but insufficient for an ordinary
Bundle episode that also reads localized dictionaries. For example,
`/Contents/Resources/en.lproj/InfoPlist.strings` adds 46 UTF-8 bytes;
the 1,003-byte bundle control cannot safely address it under the whole-path limit.
Other localization names differ in length, so no universal localized suffix is
derived here. A new design producer/review must derive every admitted reader
pathname, preserve useful localized names and reconcile finite controls and
attempt/copy certificates before implementation. No additional reader is selected.

The indexed route is required when the resolved bundle spelling or its known
20-byte Contents/Info.plist suffix reaches 1,024 bytes; the suffix threshold is
1,004 bundle bytes. This is separate from the retained action limit. Whole-path
Bundle/resource calls are withheld there. Positive indexed type plus lookup-only
identity allows a choice with INDEXED_ITEM metadataSource; name/identifier are
checked optional scalars, agent/background flags null, installationState UNKNOWN.
It does not prove current bundle contents or launch eligibility. Native source
staleness predating the first walk remains an explicit association limit; known
wrong/replaced fixture witnesses fail actual qualification.

The finite [L1500 subject](native-discovery-acceptance.md#long-application-source-subject)
currently declares seven signed copies: five known-plist/handoff boundary bundles at 1,003/1,004/1,023/1,024/1,500
UTF-8 bytes and two short competitors for the long identifiers. Component-relative
fixture construction and independent manifest reading are already demonstrated
by the [long application fixture](../../scripts/vm-long-application-fixtures.py)
and [disk-subject record](application-locations-vm.md#subjects-and-procedure);
that supplies only disk construction, not indexing support. A separate native
observer must actually receive the expected long tuple from the exact query.
Normal indexing plus one explicit short-parent reindex attempt is the finite
preparation programme, not provider behavior. Missing tuples are a native support
gap; do not substitute disk/client/controlled observations or repeat indefinitely.
No registered-long URL is required to test an indexed UNKNOWN choice's explicit
unchanged selected-action refusal. Prior registration coverage remains independent.

Keep source acquisition and these getters under k191's source-specific read policy
and actual signed dialog/hydration/serviceability controls. Public attribute types
are no native support pass. If useful long tuples or prompt-free access cannot be
qualified, k93 records the concrete consumer consequence once and asks Antony;
no silent permission/posture change or useful-choice loss is authorized.

### Application population construction evidence

The population design changes owned admission/accounting, not the selected source
or access posture. Its [machine-readable certificate](../design/application-population.json)
describes finite subjects and the recipe, not a native API guarantee. The previous
256-ID quota could leave an otherwise retained app UNKNOWN merely because of
native enumeration order. A 16,384 call ceiling also did not cover 2,048 apps:
even one eight-component directory walk costs roughly two native operations per
component before metadata, registration and cleanup. The retained action's
per-choice registered-candidate loop would multiply that work if repeated for
every catalogue copy. None of those counts was qualified on a populous VM.

Bounded source fallback reads the actual LocationWalk and ApplicationStage
sources already cited above. A normal directory visit admits fstatat/openat/close;
a symbolic-link visit adds readlinkat and held-directory fstat, and an absolute
link closes/reopens root. Error classification may ask fpathconf. Six explicit
attempts per consumed component plus four fixed start/end/cleanup attempts is a
conservative bound for that walk, including a failing final link/errno branch.
The finite shallow subject counts every visited component, including expanded
link text, within 32. This does not impose a new action depth cap. Native runtime
calls hidden inside Foundation/ARC are opaque work, outside that explicit syscall
certificate, and remain part of serviceability qualification.

The proposal stores job-local resolution **values**, not native object pins,
once per distinct spelling and before/after individual metadata. All choices
interpret the same once-per-ID ordered AppKit list plus preferred-only copy;
the CF list remains separate breadth/negative evidence. A malformed or refused
earlier comparison is not discarded from the ordered domain. An absent/unequal
earlier copy still allows a later match. Registration lists are not re-walked for
each choice, and new identifiers found only in supplements cannot recursively
grow the catalogue. Native changes between these separate observations are
possible; actual later actions always revalidate.

The certificate assigns 32 fixed source/cleanup attempts, 16 per raw URL slot,
5 per running object, 12 per identifier acquisition/count/disposal group, 10 per
individual native metadata inspection, and at most two descriptor walks per
spelling. The metadata recipe uses one resource-type read and the admitted Bundle
identifier/info/localized dictionaries; flags are scalar entries in that same
dictionary. It leaves room for the existing short-path stat/access denial checks.
The additional raw-slot reserve covers three indexed getters, five native tree
checks and six scalar checks/comparisons; the per-spelling reserve adds two
scalar transcodes. Tree count is globally gated at 65,536 before a native
membership lookup; native array acquisition/search internals remain opaque.
One 64-byte fact record and two extra indexed name/identifier copies per spelling,
plus 128 fixed source-summary bytes per job,
raise the shallow gross certificate to 6,816,128 bytes. Duplicate tuples compare
borrowed native values without new owned payload copies. Actual adapter copies
or extra calls outside that construction invalidate the certificate.
Do not apply this certificate to a different reader or repeated per-choice
registration walk. Actual N5 must enumerate getter, syscall and explicit cleanup
attempts, validate each term, and reserve cleanup before resource acquisition.

Apple's [query update contract](https://developer.apple.com/documentation/foundation/nsmetadataquery/disableupdates())
requires disabling live changes for indexed iteration; SDK 27 NSMetadata.h
declares resultCount/resultAtIndex and recommends individual access instead of
the results proxy. Count a stable gathered query on its owner run loop and bound
indexed access before owned copying. Retire/release the query before acquiring
the running batch, and dispose each registration batch after scalar staging
before asking the next API; this preserves the one opaque batch/query ownership
shape. Opaque acquisition occurs before any owned-copy gate, so a native batch
can exceed owned limits before its count is observed. No hard native peak follows.

SDK 27 NSRunningApplication.h declares activationPolicy and documents REGULAR,
ACCESSORY and PROHIBITED behavior, including the correspondence to LSUIElement
and LSBackgroundOnly. Apple's [running-application contract](https://developer.apple.com/documentation/appkit/nsrunningapplication)
warns that time-varying properties remain race-prone. Its
[Launch Services key reference](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html)
describes the two Boolean declarations. Publish only explicit typed flag values
and associated observed policies; no universal user-facing classification,
implicit default, helper suppression or additional ancestor/plist inspection is
justified by those declarations. Unreadable/unsupported metadata stays unknown.

The owned-copy certificate for the shallow subject reserves spelling/choice/
ordinal/identifier/running records, two owned copies of path/name/identifier
payloads, diagnostic records, 128 fixed source-summary bytes and 1 MiB of
one-walk scratch. Its worst-case logical
charge is 6,816,128 bytes, below the unchanged 8 MiB gate. These record/scratch
allowances are a required adapter construction contract, not measured Swift
heap layout. Diagnostic detail saturation is non-fatal: 63 records plus the reserved
DIAGNOSTIC_LIMIT record bound payload storage; four fixed 32-byte source summaries
classify all observations independently of details. No new native call or unbounded
per-item accumulator is admitted. Omitted uncertainty/failure reasons still affect
coverage and precedence; no valid choice is lost solely to fit diagnostic storage.
The final reserved record projects all observed source/reason tokens in canonical
guidance, rendered once from fixed masks at freeze. Its three-source worst case
is 843 UTF-8 bytes within 1,024; fixed scratch and the gross diagnostic allowance
must cover actual rendering copies. No repeated per-observation string allocation
or late rewrite is admitted.
A consumer that cannot keep its actual owned allocations/copies
inside them must revise the certificate and bounds before claiming applicability.
The same subject's single-full-selection JSON bound is 7,929,856 bytes, using
six bytes per escaped UTF-8 byte and explicit fixed-field/diagnostic/coverage
allowances. Multiple roots or aliases remain subject to the core's own 8 MiB
response cap. Larger legal strings can overflow either gate; cardinality does
not imply all combinations of public maxima fit. Overflow publishes no arbitrary
choice prefix, and three-second completion/RSS/opaque health remain unproved.

P1024 acceptance must discover 1,024 distinct useful identifiers, including the
fourteen configured/system witnesses, alongside 256 helper/agent/background
copies, alias pressure and native baseline apps. The baseline is measured rather
than filtered away. Its independent install/identity/metadata manifest, native
source observer and listener/store/action controls must detect missing choices,
incorrect facts and serviceability failure. The exact supported subject must
actually fit and finish; count arithmetic and SDK declarations are no such pass.

## Modern System Settings source decision

### Shipped scripting interface

The installed modern app's `SystemPreferences.sdef` exposes `application.panes`,
each pane's `id` and `name`, pane anchors, and a `reveal` command. The dictionary
names modern System Settings classes; its legacy filename does not make these
objects a `.prefPane` compatibility programme. This is a concrete app-supplied
scripting interface, with potential runtime catalogue and selected-destination
semantics. Reading the dictionary does not establish which objects the running
app actually returns or whether all useful modern destinations are exposed.

The public
[permission preflight](https://developer.apple.com/documentation/coreservices/3025784-aedeterminepermissiontoautomatet)
can check an exact Apple event without sending it. SDK `AppleEvents.h` requires
an **already-running** target. With `askUserIfNeeded=false`, it distinguishes
allowed, not permitted, would require user consent, and target not running.
It is not an inventory API, a grant or a guaranteed bounded call. A successful
preflight also does not bind a later event against consent revocation or target
replacement. Sending would need no-prompt flags and exact-target validation.
The SDK's consent is for the sending application and target application,
not a per-event OS grant. Exact class/ID preflight restricts the selected request;
all trusted providers in Koine's host process share any target-wide consent.

The same header says certain events are allowed without prompting. No event was
sent or preflighted here, so **this analysis does not establish that the exact
pane-read or reveal events require Automation consent on this OS**. Test an
unchanged-posture, no-prompt route first if that is the chosen contract. A
preflight refusal cannot be silently replaced by a prompting request or by
claiming consent is absent. The decision below is about whether the product may
depend on explicit Automation setup if useful discovery needs it, as well as
the running-target prerequisite; it is not a measured mandatory-consent finding.

Apple documents the host's
[Apple Events entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.automation.apple-events)
and required
[usage description](https://developer.apple.com/documentation/bundleresources/information-property-list/nsappleeventsusagedescription).
Koine and Apple's System Settings have different signing teams. Depending on
Automation authorization introduces a signing/usage-key/setup posture decision,
even if ordinary reads never request it. Neither k196's individual filesystem
lookup permission nor its abandoned find permission approves that change.
An explicit consent operation and any explicit launch/reveal must receive
their complete effect authority; a read must never launch or activate the app,
reveal a pane, automatically request consent or replay after denial.

### Settings event forms and association

The additional read-only subjects for this slice are SDK 27
`NSObjectScripting.h`, `NSScriptKeyValueCoding.h`, `AEObjects.h`,
`AERegistry.h`, `AEDataModel.h` and `AEPackObject.h`, plus the included shipped
`CocoaStandard.sdef`. The Settings dictionary declares pane/anchor inheritance
from item, pane ID/name properties and anchors as an element collection. SDK
NSObjectScripting defines scriptingProperties over declared properties/contents;
it does not include to-many elements. Apple's [scriptingProperties documentation](https://developer.apple.com/documentation/objectivec/nsobject-swift.class/scriptingproperties?language=objc)
agrees. Consequently, pane properties can associate ID and name within one
record, but are not an anchor snapshot or a catalogue-ready flag. This is an
inference from those declarations, not a measured Settings reply shape.

[TN2106's standard object/property conventions](https://developer.apple.com/library/archive/technotes/tn2002/tn2106.html)
and the SDK object-specifier constants provide the descriptor construction.
Each direct core/getd parameter is a typeObjectSpecifier record with want/from/
form/seld. Application containment uses typeNull; all panes use want=xppb,
form=indx, seld=typeAbsoluteOrdinal/all. A property specifier uses want=prop,
form=prop, seld=typeType/pALL for properties (or 'ID  '/pnam for those scalars).
An ID-selected pane uses want=xppb, form='ID  ', seld=validated text ID.
All its anchors use want=xppa, form=indx, seld=all, with that pane as container;
their pnam property uses the same property form. SDK AEObjects pins want/from/
form/seld and indx/prop/'ID  '/all; AEDataModel pins list/record ownership.
Exact text encodings/coercions and actual reply types still require N4; no
dictionary code is executable qualification.

| Exact core/getd form | Events for two sweeps, N panes | Association and cost | Readiness/qualification limit |
| --- | --- | --- | --- |
| Existing all IDs, ID-selected name and ID-selected all anchor names, repeated full sweep | 4N+2 (1,026 at 256) | ID-scoped scalar/anchor ownership; bounded small replies; twice the per-pane event work of the chosen form. The old 2N+2 recipe checked IDs twice but anchors only once. | Supported declared scalar properties, but no lazy-load signal; stable IDs alone miss anchor changes. |
| All IDs then ID-selected pALL and all anchor names | 4N+2 | The record checks the selected ID/name together; anchors remain separately contained. Does not reduce event count relative to scalar names. | Per-pane properties can be independently qualified; not an automatic fallback. |
| pALL of all panes, then ID-selected all anchor names; repeat | 2N+2 (514 at 256) | Each returned record carries its ID/name; each anchor event has a single known pane container. One larger opaque pane reply per sweep; no positional zip. Selected design. | Cocoa property support motivates this candidate, not a Settings runtime pass. N4 must verify list-of-records and exact codes; V12 must qualify cold/warm usefulness and latency. |
| Separate all-pane ID/name arrays; flattened names of anchors of all panes, or a list of property specifiers | No admitted reduced count | Independent arrays/flattening lose reliable per-pane association. A list may return specifiers/nesting rather than evaluated paired values; no documented Settings keyed batch contract was established. | Not selected. Do not invent nested-record semantics, zip reply positions, or compile a script to recover association. |

The selected decoder checks each pane record's exact unique ID, optional bounded
text name and class when supplied (xppb), at most sixteen direct record entries,
bounded scalar types and no unexpected nested object graph. Extra property keys
are inspected for bounded shape and discarded, never interpreted as anchors,
availability or readiness. Duplicate IDs/keys, malformed descriptors, oversized
values and changed container associations produce honest diagnostics. The job
owns and disposes outgoing events, reply descriptors and temporary scalar copies;
the target owns extension initialization and its opaque allocations. A bulk
reply can allocate before Koine inspects it: count/copy gates bound owned work,
not Apple's reply peak, extension work or guaranteed native call duration.

### Settings lazy readiness evidence

In the complete inspected System Settings dictionary, the application extension
declares panes, current pane, settings window and deprecated show all; pane
declares id/name/anchors; anchor declares name. There is no readiness/quiescence
property among those declarations. The included Cocoa Standard window/document
properties are not Settings extension-ready signals. Both authorize and timedLoad
are declared deprecated no-ops. NSObjectScripting's property accessor and
NSScriptKeyValueCoding's name/ID access describe resolution, not asynchronous
extension-load completion. This bounded source fact says nothing about private
implementation flags or whether this OS actually populates anchors lazily.

The [cold/warm contract](../specs/workspace-search.md#cold-and-warm-readiness)
therefore distinguishes process RUNNING, successful response decoding and
observed two-sweep quiescence from lazy-object completeness. It selects two
full ID-keyed maps with a 100 ms minimum gap inside three seconds; this detects
some changes without claiming initialization health. Empty panes remain UNKNOWN,
empty anchors null, and stable positive choices PARTIAL with UNKNOWN observations.
No reads perform extension-loading effects. Confirmation deadline after a complete
first sweep retains uncontradicted first-map positives as PARTIAL/TIME_LIMIT with
UNKNOWN readiness; incomplete first-sweep timeout and count/call/copy overflow still
withhold items. No late reply changes that checkpoint. Selected reveal's exact
pre-check uses the same lazy objects: no-such-object certifies no absence and is
failed/unestablished selection, never SELECTION_UNAVAILABLE or an implicit warm-up.
Independent [finite qualification](native-discovery-acceptance.md#settings-cold-and-warm-qualification)
must demonstrate every exposed useful choice before visits, for cold and warm
subjects, detect later lazy additions and reveal a known earlier pane/anchor in a
separate fresh unvisited incarnation. It cannot certify every future process
state. A failed/unconstructible subject stays pending or unmet; it does not permit
a narrower inventory, new posture or alternate private source silently.

### OS-shipped sidebar metadata

The inspected `Sidebar.plist` contains grouped `content` entries and a
`catch_all` group. `Sidebar124.plist` has distinct `ordered_content` and
`sortable_content` groups, another catch-all, and an Apple-account subdestination.
Their entries include hardware/account/managed-only candidates, mutually
different implementations and IDs not ending in `.extension`. An ID list does
not establish installedness, localized labels, current visibility, successful
navigation, all subpanels or the active layout version.

These files are primary evidence of **OS-shipped data**, not a supported public
format contract. No such catalogue contract was established in the examined
SDK/API sources. A parser or extension-directory walk would need explicit
version/format policy and would still lack runtime conditional availability.
Do not infer a generic URL from every ID, merge both layouts as current truth,
or turn catch-all into proof of completeness. Reading this local sealed app data
does not qualify any future native reader's calls, bounds or no-hydration policy.

### Individually documented destinations

SDK `SMAppService.h` documents `openSystemSettingsLoginItems` (macOS 13+).
SDK `ESClient.h` documents the modern Full Disk Access URL
`x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles`.
The [public Login Items method](https://developer.apple.com/documentation/servicemanagement/smappservice/opensystemsettingsloginitems())
and [Apple DTS's SDK explanation](https://developer.apple.com/forums/thread/791996)
support those particular destinations. Opening either is an effect, not a
discovery read. Merely opening the privacy page grants no permission, and this
design proposes no Endpoint Security entitlement or client.

These positive examples establish useful selected targets; they do not form
the required modern settings catalogue. In particular, the Full Disk Access
URL does not document arbitrary extension IDs or anchors. A successful open
acknowledgment must still be paired with an independent visible-destination
witness. The existing HTTP(S)-only `workspaceOpenURL` cannot accept this shape;
`workspaceOpenPath` cannot accept a pane ID. Do not widen their validation or
relabel a settings action as an already accepted operation.

### Agreed settings source and preparation

Antony agreed to **app-supplied scripting**, trying unchanged signing posture
and exact-event-allowed, no-prompt reads first. If useful discovery requires
Automation authorization, final design may introduce the necessary host
entitlement/usage description and an explicit consent/setup path. Add no unused
permission. This permits design of that conditional path; it establishes neither
that any exact event requires consent nor that permission can be obtained.

The app-supplied interface supplies named objects and a reveal command rather
than deriving destinations from undocumented implementation filenames. The
private, macOS-version-bound sidebar/deep-link alternative and narrowing/deferring
the useful category to individually documented destinations were not selected.
Their format, conditional-coverage and useful-category costs explain the choice;
they are not silent fallbacks or pruned obligations.

Antony requires launching System Settings if stopped, in the background while
preserving the foreground application. Final design therefore defines a separate
explicit, control-authorized catalogue-preparation operation. It requests no
activation or reveal and does not reactivate an already-running target. The
existing launcher requests activation and cannot silently acquire this different
contract. Ordinary reads still require an already-running exact-event-allowed
target; they never launch, activate, reveal, request consent or change settings.
Stopped/refused read targets remain honestly unavailable/blocked. Preparation
does not implicitly request Automation consent; any necessary setup is separate.

The agreed useful minimum is every pane exposed by the app's runtime interface,
with Network, Sound, Appearance and Displays required as acceptance witnesses,
not a hard-coded inventory. Exposed anchors support nested destinations;
hardware/account-conditional choices retain honest availability. A missing
required ordinary area leaves a concrete gap to resolve, never permission to
shrink the category or accept known missing choices. Runtime inventory and
navigation have not been measured.

The complete design specifies fixed-target validation, exact events, no-prompt
preflight/send, preparation/setup/reveal authority and parameters, foreground
expectations, bounded ownership and independent serviceability. Actual adapter
construction and signed acceptance must qualify those mechanisms and unchanged
versus consent-dependent host posture through the declared N/V subjects. Source
analysis and design sessions perform no native qualification. Existing native
race/application-reaction limits remain binding.

## Contract and acceptance handoff

The [native discovery spec](../specs/workspace-search.md),
[SDL/examples](../design/workspace-search-schema.graphql) and
[finite acceptance contract](native-discovery-acceptance.md) now define selected
sources, complete static authority, source/status/metadata semantics, frozen
aliases, bounded ownership, true native-return retirement and binary guards.
No runtime API/consent/foreground/source qualification has been performed here.
The inspected SDK 27/OS 26.6.2 subjects remain distinct from supported VM captures.

Settings source events are two bounded direct core/getd sweeps (all xppb pALL
ID/name records, ID-contained xppa names) and misc/mvis selected reveal, to a
validated running OS target. Lazy completeness remains UNKNOWN even after equal
full maps; finite cold/warm native usefulness is independently qualified.
No-prompt preflight/send and target revalidation are exact qualification subjects.
Prepare launches a stopped target with activates=false; it publishes no catalogue
values and needs workspace:control. Setup is an explicit human action only in
Koine’s local explaining UI via a private local-console seam, conditional on
actual exact-event need; consent covers the host/target pair. No GraphQL/bearer
route initiates it. Reveal needs workspace and desktop control. No read
uses a prompting preflight, launch, activation, private sidebar or guessed URL.
All exposed panes/anchors, ordinary areas and hardware/account conditions remain
finite useful-category obligations.

The new provider identities are workspace 1.2.0/schema 1.1.0 and update 1.3.0/
schema 1.1.0, independently of retained action-only 1.0.0/1.0.1 and already-used
1.1.0/schema 1.0.1. Source AND actual action image guards keep forbidden listing,
spawn and scripting; permitted discovery/settings code has separate ownership,
allowlists and compiled cross-boundary failing controls. Both native releases
require workspace-native-disclosures-v1, served only by hosts with corrected core
UI/management disclosures; prior selection-aware hosts refuse before load. No new diagnostic ABI,
custom worker, global materialization policy or descriptor-limit change is selected.

## Reconciled work boundary

The complete root native producer supplies the reconciled population, Settings
readiness and indexed long-metadata design for mandatory review before
app-and-file-search. Retained permission work qualifies exact source/individual
access rules and conditional setup posture; resource work finalizes real native
owner retirement and action/discovery image boundaries; classification finalizes
metadata normalization and useful identity controls. Existing whole-node reviews
and planning remain live with their actual creators named only on completion.
The coverage decision resolves measured native gaps, never client home ordering.
Actual source, binary, signed-VM and independent serviceability/dialog/hydration
outcomes remain pending. No old raw or action capture becomes native acceptance.
