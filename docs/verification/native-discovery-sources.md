# Native discovery source boundary

**Source analysis and agreed settings direction; contract design and native
acceptance remain pending.**
The [v1 ownership agreement](../adr/raw-filesystem-search-belongs-to-clients.md)
requires OS-known starting locations and useful application/modern System
Settings catalogues, with prompt-free, non-hydrating reads. This analysis
establishes candidate sources. The focused human requirements decision below
selects the preferred settings route and permits conditional explicit setup;
it qualifies no backend or native event and implements no signing change,
consent operation, schema or reduced useful inventory.

Start with [Native sources → What each source can establish](../design/architecture/index.html#diagram-native-discovery-sources)
and [System Settings → Agreed source and permission boundary](../design/architecture/index.html#diagram-native-settings-decision).
The former raw-search [SDL](../design/workspace-search-schema.graphql),
[examples](../design/workspace-search-operations.graphql) and
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

**Recommendation, pending qualification:** use a fixed indexed application
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

The existing action adapter's AppKit array-only lookup supplies no error-bearing
negative fact. The earlier [SDK analysis](search-native-resources.md#call-health-is-separate-from-descriptor-visibility)
identifies `LSCopyApplicationURLsForBundleIdentifier` with `outError` as a
deprecated but declared alternative. The current SDK retains its documented
not-found error. A final source design must choose explicitly between its
diagnostic/migration cost and leaving registration unknown. Empty AppKit arrays,
nil bundle identifiers, malformed values and failed identity acquisition cannot
establish absence or an unregistered installation.

Preserve distinct same-identifier copies. Only established bundle-directory
identity can merge aliases; failed identity acquisition is unknown, not a merge.
Existing selected actions re-resolve the identifier and path independently.
Bundle metadata inspection is individual-target work with the existing bounded
lookup/contact limits; this report authorizes no contents-listing exemption,
arbitrary metadata-file reader or hydrated placeholder access. A long native
location may remain representable while bundle metadata and later action
handoff are unsupported. No incorrect known witness is accepted as an opaque
platform-health limit.

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

K202 must qualify the actual fixed target, exact read events, no-prompt preflight/
send behavior and unchanged versus consent-dependent host posture. It must also
design complete preparation/setup/reveal authority from the selected native
primitives and parameters, target/readiness validation, foreground behavior,
blocking/late-return ownership and independent serviceability. Existing native
race/application-reaction limits remain binding; source analysis supplies no
stronger guarantee.

## Contract and acceptance handoff

The final producer remains responsible for the complete API, not just this
source choice. It must replace the raw proposal only after the requirements
decision and source qualification contract are coherent. In particular:

- Keep source provenance and availability separate from metadata and coverage.
  An actually observed empty fixed location kind/source may be healthy empty;
  empty Spotlight/registration or a stopped settings target is no category-wide
  absence proof. Partial choices remain usable with source diagnostics. Failed
  normalization, timeout, refused source, unknown health and unsupported version
  have distinct meanings. Authorization/revocation/publication errors retain
  their own response paths, including aliased frozen nested values.
- Assign work/state to a private source adapter and snapshot owner, with the
  existing provider/host composition as enabling point. Bound admitted jobs,
  native calls, returned copies/bytes and diagnostics. A deadline closes
  publication, not a blocking native call. Retain capacity/ownership until
  actual return or native query retirement, including cancellation, revocation
  and provider stop. Opaque native allocations/peaks remain unproved; they do
  not excuse lost required witnesses or listener/store/action failures.
- Keep read adapters separate from the retained action call paths. Source AND
  actual provider/host binary guards must still reject directory listing,
  process launch and scripting leaking into an action-only path. A future
  permitted discovery/script module gets its own finite allowlist; do not
  remove the old guard to make it pass. Cross-boundary failing controls must
  exercise the actual built images as well as source.
- Define an explicit settings selection action if the chosen destination needs
  one, including fixed target/command validation, stale selection, complete
  `workspace:control` AND `desktop:control` effects, preparation/cleanup and
  ambiguous late acknowledgment. This proposal adds no menu/input authority
  without selecting those effects, no arbitrary AppleScript, scheme or target,
  and no automatic replay. Existing launch/open/reveal and long-location
  resolution/receipt contracts remain independently binding.
- Define the separately authorized background preparation action for a stopped
  System Settings target, including refusal under a read-only or revoked grant,
  already-running behavior, bounded readiness and failed/ambiguous late outcomes.
  Allocate all actual effects before dispatch; neither preparation nor ordinary
  reads may implicitly invoke consent setup. Verify the conditional explicit
  setup path only if the exact events need it, without expanding ordinary reads.
- Define exact new provider release/schema/profile/update/refusal subjects only
  after the chosen API/signing posture is known. Independently retained action
  releases/schemas 1.0.0 and 1.0.1 stay unchanged evidence. Current per-user
  update release 1.1.0/schema 1.0.1 is also an action-only subject, not a free
  native-discovery version or capture. Do not pin the discovery design to an
  already used release without reconciling its binary identity.

Finite acceptance stays within the agreed G/N/V seams. G covers named starting
values and account/domain provenance, catalogue source/status/coverage/metadata,
invalid input, only-read versus only-control grants, revocation and publication.
N covers actual native providers/host loading, exact compatibility subjects,
frozen alias behavior, source AND binary authority boundaries and blocking/
late-return ownership; a substituted source is not native acceptance.
V covers real starting locations, the twelve configured launchers plus
Safari/Finder, an independently installed extra application not in that witness
list, distinct same-identifier copies and aliases, truthful registration facts,
actual modern settings choices and their explicit selected destinations.

Settings subjects must include ordinary modern areas such as Network, Sound,
Appearance and Displays, a nested destination if the chosen interface claims
anchors, and hardware/account-conditional and unavailable subjects. They are
witnesses, not a hard-coded inventory. Where the chosen source cannot expose a
required witness, report the concrete gap for the coverage decision. Pair reads
with independent dialog and hydration positive controls, and catalogue stress/
blocking events with independent listener, grant-store and authorized-action
outcomes. Missing native conditions/fixtures remain pending. Prior raw probe
results and action-only captures supply no pass for these subjects.

Settings preparation additionally needs a stopped-target effect-free read,
denied/revoked preparation grants, cold background launch with another application
frontmost, and an already-running target without reactivation. Independently
observe foreground and readiness, including failure/ambiguous late return;
pair any setup branch with exact-event authorization evidence and explicit-only
consent. These are cases within the agreed G/N/V seams, not a new proof chain.

## Reconciled work boundary

The native-discovery producer has completed bounded source analysis and the
focused human settings direction. Final API/resource/acceptance/artifact
design remains k202's work. Its mandatory whole-producer review and earned integration precede
app-and-file-search consumption. Until then the current spec and raw SDL remain
explicitly pending/comparison rather than a fabricated native contract.

Retained permission work qualifies actual location values, indexed application
scope, per-target registration/bundle inspection, and the chosen settings route;
retained resource work qualifies source/action boundaries and true native return;
retained classification work finalizes source-specific metadata/coverage.
Whole-node resource review and planning remain live. The existing coverage-gap
decision addresses measured native omissions, not the client's home traversal.
The producer's eventual closing session reconciles every mixed charter and
names its own run on its review. Source analysis finishes neither that producer
nor the later nodes, and supplies no Creator identity for them.
