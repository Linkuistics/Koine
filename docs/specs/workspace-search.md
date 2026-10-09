# Native discovery and client-owned search

**Designed; mandatory review, implementation and native acceptance pending.**
Koine supplies OS-known special locations and named application/System Settings
catalogues on macOS 26+ Apple Silicon. Clients own filesystem traversal,
permissions, filtering, ranking, order, budgets, chooser, MRU and clipboard.
Location values grant no access or consent. The [ownership decision](../adr/raw-filesystem-search-belongs-to-clients.md)
and [requirements](../requirements/modaliser-workflows.md#ownership-and-existing-constraints)
govern. The [source report](../verification/native-discovery-sources.md) records
SDK 27 declarations and macOS 26.6.2 shipped data separately from macOS 26.5
comparisons. Those declarations qualify interfaces, not runtime read safety.

Start with [Composition → Own sources and freeze publication](../design/architecture/index.html#diagram-native-discovery-contract)
and [System Settings → Read, prepare, set up, then reveal](../design/architecture/index.html#diagram-native-settings-flow).
The [SDL](../design/workspace-search-schema.graphql) and
[operations](../design/workspace-search-operations.graphql) encode this contract;
they are proposals, not the currently served schema. The
[finite acceptance contract](../verification/native-discovery-acceptance.md)
names every G/N/V subject. The [former raw proposal](../verification/raw-workspace-search-comparison.md)
and [system-find measurements](../verification/search-tooling.md) are comparison
material only. No raw-search roots/query/matching field or fallback remains in
this design.

## Ownership and alternatives

| Module | Owns and hides | Public obligation / enabling point |
| --- | --- | --- |
| Workspace composition | Resolver routing, static authority, bounded job owner | Client selects a named operation; private native adapters are supplied here for contract tests. |
| Location adapter | Foundation account/domain value lookup | Returns values without existence checks or contents access. |
| Application adapter | Indexed breadth, running observations, registration and individual bundle inspection | Per-copy choices, provenance and checked native facts; no exhaustive disk promise. |
| Settings adapter | Fixed trusted target, exact event descriptors, no-prompt reads | Runtime panes/anchors and honest stopped/refused/conditional outcomes. |
| Snapshot owner | Admission, budgets, copied values, diagnostics, freeze and true retirement | Nested fields/aliases never repeat native work. |
| Existing action module | Launch/open/reveal resolution and accepted submission rules | Receives explicit selection and its complete controls; catalogue knowledge grants no action authority. |
| Settings effect module | Background prepare, explicit setup, selected reveal | Separate static authority and finite effect allowlists. |
| Client | Raw search and presentation, explicit choice to prepare/setup/act | Supplies its own filesystem access and independently requests each effect. |

A named source adapter concentrates service semantics and uncertainty below the
resolver; callers need not reconstruct three different native protocols.
Calculation/merging uses bounded immutable observations, separate from query
lifetime and authority. Keeping discovery and effects in separate native images
costs packaging and controlled linkage but preserves the accepted action guard.
A single permissive workspace image would entangle discovery scripting with the
four accepted action paths. A launcher-only app catalogue lacks breadth; a raw
walk restores client-owned responsibility. Neither is selected. Settings uses
app-supplied objects rather than private sidebar files or guessed deep links;
[the decision](../adr/settings-discovery-uses-app-supplied-objects.md) records its
conditional setup cost. Revisit a source only for a measured missing required
choice or failure of the no-prompt/no-hydration policy, once with the concrete
consumer consequence and alternative.

## Public operations and authority

| Coordinate and every reachable result field | Static complete authority | Effects |
| --- | --- | --- |
| Query.workspaceSpecialLocations(requests:) | workspace:read | Value lookup only. |
| Query.workspaceApplications | workspace:read | Fixed application catalogue; no launch/register/setup. |
| Query.workspaceSettings | workspace:read | Existing running target only; exact no-prompt read events. |
| Mutation.workspacePrepareSettings | workspace:control | Validate target; launch stopped target with activation disabled; running target is left alone. No catalogue values. |
| Mutation.workspaceRequestSettingsAutomation(event:) | workspace:control | Explicit permission preflight with asking enabled for one fixed READ or REVEAL event class/ID. No launch, reveal or data publication. |
| Mutation.workspaceRevealSetting(selection:) | workspace:control AND desktop:control | Validate/re-resolve fixed pane/anchor; no-prompt reveal, then explicit activation of the validated target. No launch or automatic setup. |

Authority is immutable per schema field coordinate, never inferred from the
root that reached it. Query objects, preparation/setup objects and reveal
objects are disjoint; in particular diagnostics, permission hints, dependencies
and process identities cannot cross these three authority sets. Enums/scalars
may be shared because they have no resolver fields. Register every reachable
field with its group's complete authority and reject any descriptor/schema
combination that disagrees. The SDL check also rejects a deliberately shared
preparation/reveal process object.

Workspace grant disclosure must name these additions: read returns Koine-account
location values and application/settings metadata, not client filesystem access;
control permits background System Settings preparation and explicit Automation
permission requests; reveal also requires desktop control and requests activation.
Existing launch/open/document-handler disclosures remain complete.

Read is never implied by control. Prepare/setup expose only control-authorized
receipts, readiness or permission outcome, not panes, names or locations; any
future combined operation publishing catalogue data must additionally require
workspace:read throughout. Prepare/setup request no activation, so desktop control
is not allocated from incidental application/OS reactions. Reveal selects an
activation effect and always needs both controls, including its receipt. No
input, menu or desktop read authority is selected. The host performs whole
mutation preflight, live-grant admission at every effect and publication checks
under the [effect rule](../adr/provider-authority-follows-effects.md). Revocation
closes further admissions; already admitted effects may finish, with no rollback.
No operation automatically retries another source, target, installation or effect.

### Input and output validation

Special-location requests are omitted/null for the declared default set, or a
nonempty list of at most ten distinct (kind, domain) pairs. HOME, DESKTOP,
DOCUMENTS, DOWNLOADS, MOVIES, MUSIC and PICTURES admit USER only. APPLICATIONS
admits USER, LOCAL and SYSTEM. Duplicate or unsupported pairs are invalid input
before any lookup. Defaults contain all ten pairs in the preceding order, with
APPLICATIONS ordered USER, LOCAL, SYSTEM. There is no arbitrary path, predicate,
query string, order or caller-supplied native work limit.

Settings selections contain paneId (1…512 UTF-8 bytes) and optional anchorName
(1…512 bytes); empty, NUL and control characters are invalid. They are exact
opaque dictionary keys: no trimming, case folding, Unicode normalization,
substring match, URL construction, script interpolation or expression parsing.
Null anchor means pane; a nonnull anchor means exactly that pane's anchor.
Setup's event enum is READ or REVEAL only. Mutation inputs are validated before
native work. GraphQL variable/type coercion keeps HTTP 400; provider semantic
validation keeps original aliased response paths and existing invalidInput behavior.

Native output strings must be lossless UTF-8, no NUL; IDs/anchor keys also satisfy
the selection rules. Absolute local paths are at most 8,192 UTF-8 bytes, labels
1…1,024, identifiers 1…512; native strings outside these bounds are withheld,
never truncated/repaired into another identity. A missing label may be null with
an affecting diagnostic. No icon, thumbnail, content, arbitrary plist, alias-file
resolution or default document handler lookup is part of a read. The host's
existing value/type/depth checks still reject malformed provider output.

## Special locations

Use NSHomeDirectory for HOME and FileManager.urls(for:in:) for the other named
pairs. Never a create-enabled URL lookup. Return all representable values for a
requested pair with kind/domain, Koine account's UID as accountIdentifier,
contentsAvailability UNKNOWN and FOUNDATION_LOCATIONS provenance. Domain and
account describe Koine's user, not a remote client's user. Native value order is
an observation, not ranking. Do not resolve, stat, list, create, follow links,
read resources, mount, open bookmarks or inspect account/cloud containers merely
to return a value. A nonexistent or inaccessible location can still be a valid
starting value. Absent native values are UNKNOWN with NO_NATIVE_VALUE; they do
not certify absence or a healthy empty filesystem. COMPLETE means every requested
value lookup supplied checked values, never that any directory's contents were
searched. Temporary/container/network/iCloud enumeration is outside this set.

## Application sources and native facts

The breadth source is one NSMetadataQuery with the fixed application-bundle
content-type-tree equality kMDItemContentTypeTree = com.apple.application-bundle
and NSMetadataQueryIndexedLocalComputerScope. Read only kMDItemPath from an
indexed item as its candidate location; indexed name/identifier/suffix never
establish native bundle identity. This fixed predicate's array/type semantics
are qualified against real non-witness application bundles.
No client predicate or explicit directory scope is accepted. Record INDEXED_APPS
provenance; user exclusions, stale index state, unindexed volumes/system locations
and even a remote home may affect this scope. Post-result pruning cannot undo
source contact. The adapter must qualify that exact predicate/scope on signed
supported subjects before it is accepted; it is not silently widened to
LocalComputerScope. A finished gathering notification permits freezing returned
observations, not proof that every application on disk was indexed or healthy.

Supplement with generic NSWorkspace.runningApplications (RUNNING_APPS), and
error-bearing LSCopyApplicationURLsForBundleIdentifier expansion
(REGISTRATION) for identifiers from admitted indexed/running observations plus
the fixed system identifiers com.apple.Safari and com.apple.finder. These recover
known system apps but never define the inventory; the twelve configured launchers
are acceptance witnesses, not a hard-coded production seed list.
Expand each distinct identifier once, no recursive identifier cascade. Record
every returned choice's actual source membership; a registration supplement is
not falsely labelled indexed. Registration and preferred-location lookup are
per-identifier facts, never an enumeration of all registrations. The deprecated
but declared error-bearing API is chosen for meaningful checked negatives;
if unsupported/unusable, diagnose and keep UNKNOWN, preserving unmet useful work.
The source report cites its SDK/primary documentation.

Every published app needs a checked native application-bundle type and established
bundle-directory device/inode from the permitted bounded individual-target
location resolution. Native application resource metadata and Bundle supply
optional localized name and bundle identifier only for that identified target.
No filename suffix establishes type or identity. A refused/unidentified candidate
is omitted with diagnostic and partial/unknown coverage. Preserve representable
long locations after lookup-only identity acquisition, but withhold unsupported
whole-path bundle metadata and diagnose it; never call pathname APIs past their
applicable limits or convert their nil/ENOENT/ENAMETOOLONG to absence.

Merge direct/linked/indexed/running/registered observations only on established
device/inode while the choice is retained. Keep the first finalized resolved
spelling unchanged and union only observed sources. Distinct native copies with
one identifier remain distinct. A changed identity during inspection is refused,
not rescued by a later good field. No unbounded seen-identity set or query-long
pin exists; bytes differing by case/NFC/NFD/firmlink do not themselves merge.
A location can name a replacement later; existing actions re-resolve it. This is
[installation identity](../adr/application-search-uses-bundle-identity.md), not
a process incarnation or resource reference.

| installationState | Required evidence |
| --- | --- |
| INSTALLED | Present identified app, valid identifier, completely checked registration result with no error and a matching present registered identity. Contradictory preferred/native metadata prevents this fact. |
| UNREGISTERED | Present identified app and valid identifier; exact CFError application-not-found result (kCFErrorDomainOSStatus with code kLSApplicationNotFoundErr from the selected API) with no array/contradiction, OR complete error-free checked registration identities all nonmatching. Preferred location must not match or be unexamined/refused/contradictory. |
| UNKNOWN | Missing/invalid identifier, empty errorless/nil result, array plus error, unknown error, capped/unexamined/refused/changed URL, unavailable API, or conflicting preferred evidence. |

Preferred NSWorkspace.urlForApplication is a contradiction check, not a health
token; nil proves nothing independently. A checked negative is a native reported
fact, not internal platform-health proof. Undetected stale/incorrect native state
is possible. Known incorrect witnesses and systematic UNKNOWN launcher metadata
fail acceptance under [the fact decision](../adr/search-native-facts-are-reported-observations.md).
UNKNOWN/UNREGISTERED identified apps remain reveal/copy choices. INSTALLED plus
identifier and applicationPath may feed the existing constrained launch. A client
must preserve both fields, never silently remove a constraint or pick another copy.

## System Settings read and exact target

Use only the installed OS System Settings bundle (com.apple.systempreferences),
with checked Apple platform signing identity, identified canonical system bundle
and observed process incarnation. Do not pick another registered copy or address
only a bundle ID that could auto-launch. Obtain the already-running target's PID
and kernel start, verify its executable/bundle/signature, then build a local
AE address descriptor of typeKernelProcessID. Revalidate before each preflight,
send and acceptance of its reply. A mismatch/refused validation is TARGET_CHANGED;
no side effect or substitute is admitted. Public process check and PID-addressed
Apple events do not provide atomic binding across exit/reuse; disclose that race
and test rejection/late values rather than claim a stronger identity guarantee.

The installed dictionary's pane class is xppb; pane id property is 'ID  ', name
pnam; anchor class xppa and name pnam. Read with core/getd object specifiers:
application's all pane IDs, then each pane selected by unique ID, its name and
all anchor names. Read IDs again before freezing; a changed set invalidates
completeness and supplies CHANGED_DURING_DISCOVERY. Per-pane results must keep
pane association; separately enumerated arrays are never zipped by order.
No NSAppleScript/osascript/ScriptingBridge code compilation is selected. Construct
AE descriptors from validated values. The exact descriptor forms/codes and
reply types are pinned qualification subjects; dictionary declarations do not
prove runtime unique-ID resolution, useful areas or anchors work.

For each core/getd preflight call AEDeterminePermissionToAutomateTarget with
askUserIfNeeded=false, then send with kAEWaitReply, kAENeverInteract and
kAEDoNotPromptForUserConsent, using a timeout no greater than the remaining read
budget. Never wildcard the event class/ID, launch, activate, reveal, authorize a
pane, run timedLoad or change a setting. noErr only admits that exact send;
consent/target may change immediately afterward. errAEEventWouldRequireUserConsent
or errAEEventNotPermitted becomes BLOCKED with exact-event AUTOMATION guidance
and unknown consent, not invented missing Accessibility or automatic setup.
procNotFound/stopped target is UNAVAILABLE/TARGET_NOT_RUNNING. Other returned
errors, malformed reply or timeout are FAILED; useful earlier panes may survive
as PARTIAL only if still individually valid. Native reply receipt is no health,
foreground or useful-completeness proof.

An unestablished anchor response is null, not an empty anchor list, with a pane-scoped diagnostic.
Return every runtime-exposed pane, its exact ID, optional native label and exposed
anchor names. No witness-only filter, private sidebar parser, extension-directory
walk, guessed ID/URL or legacy .prefPane catalogue is allowed. Conditional hardware/
account/managed visibility remains UNKNOWN unless the runtime explicitly reports
it; no inference from a name or absent pane. The supplied dictionary reports no
such availability property, so each observed pane/anchor has availability UNKNOWN.
A complete successful read can be COMPLETE over RUNTIME_EXPOSED_PANES while
category completeness stays UNKNOWN. Network, Sound, Appearance and Displays
are required witnesses, not a fixed inventory. Missing any ordinary area or an
advertised anchor's usable reveal is concrete unmet acceptance, never an accepted
platform omission or reason to silently reduce the category.

## Settings preparation, setup and reveal

### Background preparation

workspacePrepareSettings validates the fixed installed target under the existing
location/bundle/handoff rules. If already running and validated, return a control
receipt with launchRequested=false, readiness RUNNING and optional observed process
incarnation; issue no launch/activation/event. If stopped, submit exactly one
NSWorkspace.openApplication at the checked OS bundle URL, with activates=false,
createsNewApplicationInstance=false, allowsRunningApplicationSubstitution=false,
hides=false, hidesOthers=false, isForPrinting=false, promptsUserIfNeeded=false,
empty arguments/environment and no Apple event. Callback and a revalidated
running target yield RUNNING, launchRequested=true and optional process identity.
No pane read is performed: RUNNING means process readiness, not useful-catalogue
or Automation readiness. Client explicitly follows with workspaceSettings.

Missing target before any launch is DEPENDENCY_UNAVAILABLE with no receipt;
validation/native errors are failed. Wait at most three seconds/core remainder.
A submitted launch with timeout/revocation/cancellation has ambiguous effects;
freeze the result, ignore late callback and never terminate an OS app or replay.
Background flags request foreground preservation; independently witness it with
another app frontmost. Application/OS reaction and timing can still affect focus;
a repeatable foreground loss fails the agreed preparation acceptance and requires
a concrete remedy/decision. The existing launcher retains activation=true and
both controls and cannot acquire this behavior by omission.

### Conditional explicit Automation setup

Try unchanged empty entitlements/no usage key first for exact READ core/getd and
REVEAL misc/mvis. Qualify those separately; permission for one proves nothing
about another. If useful operations require authorization, the k201 agreement
permits only the needed host com.apple.security.automation.apple-events
entitlement and NSAppleEventsUsageDescription plus this explicit setup path.
Do not ship an unused permission. Record a final effective posture and exact
signature/entitlement/Info.plist digest for each actual host. No policy is changed
by this design, and it establishes no event needs or obtains consent.

workspaceRequestSettingsAutomation(READ|REVEAL) validates an already-running
fixed target then calls only AEDeterminePermissionToAutomateTarget for that exact
pair with askUserIfNeeded=true on an owned background worker. It never sends a
catalogue/reveal event, launches/reactivates, changes consent silently, invokes
the dictionary's deprecated authorize command or resets TCC. If the exact event
already passes no-prompt preflight, return ALLOWED with requestMade=false and do
not prompt. An unsupported unchanged posture returns UNAVAILABLE/SETUP_UNSUPPORTED;
installation of a qualified conditional host is explicit deployment, never done
inside a read/action. Outcomes are ALLOWED, DENIED or UNAVAILABLE with bounded
guidance; unknown errors/timeouts are failed, not denied. Permission is a point-in-
time observation; setup grants no Koine capability or guaranteed future delivery.

A setup request may display OS consent and cannot be recalled once admitted.
It has a thirty-second provider ceiling bounded by the core deadline. The
current core freezes a request within five seconds, so the public wait cannot
reach thirty seconds on that host. A late user's
answer may change OS consent after Koine freezes or the grant is revoked.
Retain its owned worker/target until real return; do not retry or dismiss another
process's dialog. Normal reads, prepare and reveal never call this prompting path.

### Effect result invariants

Absent independent execution/publication errors, AVAILABLE has a receipt and no
dependency; DEPENDENCY_UNAVAILABLE has a dependency and no receipt; BLOCKED has
permission guidance and neither. Prepare never returns catalogue values. Setup
returns its separate outcome, not an effect receipt. Unexpected errors/timeouts
raise existing failed at the nullable mutation root. After a domain effect was
submitted, failure cannot become BLOCKED or dependency unavailable. Every nested
field keeps the root's complete static authority and frozen receipt; no nested
field starts another effect.

### Selected reveal

workspaceRevealSetting takes only the exact selection. It requires a running
validated target and no-prompt READ and REVEAL permissions. Re-resolve pane by
unique ID and anchor by exact name within it with core/getd, without publishing
read data. Positive no-such-object before submission is
DEPENDENCY_UNAVAILABLE/SELECTION_UNAVAILABLE, not input error; opaque/malformed/
refused answers are failed or blocked and certify no absence. Construct misc/mvis
with that pane/anchor object as direct parameter, preflight that exact event,
send with no-prompt/no-interaction flags and wait for reply. On a checked
successful reply request activation of the still-validated process once; do not
launch a stopped target, substitute another pane/anchor, open an arbitrary URL
or replay after failure. Both controls are required before either effect.

Receipt echoes selection and revealAcknowledged=true, activationRequested=true,
and optional control-authorized process incarnation. It certifies acknowledged
reveal plus submitted activation, not final visible destination/foreground. A
failed activation or target change after reveal returns failed with effects
ambiguous, never dependency unavailable. No separate catalogue values are in the
receipt. Independent V witnesses must see the selected destination and anchors.
Permission blocks detected before any reveal return BLOCKED with diagnostic,
no receipt; exact named missing-consent facts, if actually established, use the
existing osPermission mapping. After submission, timeout/error/permission or
revocation is an execution error with no retry-safe absence claim. Shared
three-second/core wait bounds publication, not native call duration.

## Coverage and frozen publication

Each result carries status, sources and nullable items. Each source identifies
its fixed source enum, declaredDomain, availability, observation completeness,
category completeness, examined count and bounded diagnostics. Observation
COMPLETE means this finite declared source response was fully checked/copied
within bounds; PARTIAL means a known omission; UNKNOWN means completion could not
be established. Availability is AVAILABLE, BLOCKED, UNAVAILABLE or UNKNOWN.
Category completeness is always UNKNOWN for apps/settings, and for filesystem
contents of location values. Explicit source completion supplies no atomic,
all-disk/index-health or physical-closure guarantee.

| Root status, absent independent execution errors | items and meaning |
| --- | --- |
| AVAILABLE | Nonempty valid observations with no affecting omission, OR a qualified complete empty declared observation domain; items is a list. Category completeness may still be UNKNOWN. |
| PARTIAL | Some valid observations (or independently completed empty source) plus a known omission/failure/block/unavailable component; items is a list, possibly empty. |
| UNKNOWN | No useful observation/qualified empty and only unestablished native value/health; items null, diagnostics explain. |
| BLOCKED | No useful observation/qualified empty, prompt-policy refusal, no failure-class diagnostic; items null, no generated error. |
| UNAVAILABLE | No useful observation/qualified empty and an established source/target prerequisite unavailable; items null, no generated error. |
| FAILED | No useful observation/qualified empty and native/malformed/change/limit failure; items null; each selected items alias raises failed. |

With no progress, precedence is failure → block → unavailable → unknown. A
gathered empty index is a valid empty INDEXED_APPS observation only when its
qualified completion signal and parsing conditions hold; it is never all-app
absence. Empty nil/errorless registration is UNKNOWN. An empty running list is
only empty RUNNING_APPS; a stopped settings app is UNAVAILABLE, never empty.
Empty runtime pane/anchor list can describe its declared interface if qualified,
but missing ordinary witnesses still fails useful-category acceptance.

Diagnostics name source, reason, nullable established location/pane, guidance,
and optional permission (AUTOMATION, exact READ/REVEAL; or PROMPT_RISK with unknown
consent). No path is fabricated from text. Reasons: NO_NATIVE_VALUE,
PROMPT_RISK, TARGET_NOT_RUNNING, TARGET_CHANGED, SOURCE_UNAVAILABLE,
SETUP_UNSUPPORTED, INSPECTION_FAILED, CHANGED_DURING_DISCOVERY,
UNREPRESENTABLE_VALUE, METADATA_UNKNOWN, ENTRY_LIMIT, CALL_LIMIT, VALUE_LIMIT,
DIAGNOSTIC_LIMIT, TIME_LIMIT, CAPACITY_LIMIT. The first/metadata reasons cause
unknown or partial; source/target stopped/setup unsupported cause unavailable;
prompt causes blocked; all remaining reasons are failure-class. No diagnostic
claims actual missing consent without independent evidence. affectsCoverage is
always true for these discovery reasons. Effect diagnostics have distinct
object coordinates, describe only the fixed target/effect and set
affectsCoverage=false; preparation has no permission hint, while reveal may
identify its exact read/reveal preflight. Reserve a final limit diagnostic before filling
the sink. Native error text is bounded guidance, never a parsed errno/location.

One root alias owns one snapshot; repeated root aliases make separate admitted
observations. Every nested alias reads its frozen parent, with no native calls.
For FAILED, each selected items alias independently reports failed at its original
path; omitting items allows status/diagnostic inspection without generated failure.
BLOCKED/UNAVAILABLE/UNKNOWN give ordinary null items and no generated error.
Publication authority/provider lifecycle checks can suppress any selected field
and normal null propagation still applies; a surviving status never cancels
errors. Revocation after snapshot completion may prevent its publication.
resultsTruncated is true only when an observed distinct valid choice was omitted
by entry/value retention, not merely because time expired. No cursor/resumption,
persistent index/cache, stable rank, top-N or cross-query snapshot is promised.

## Native ownership and bounds

One process-wide owner registry admits at most four jobs across reads and settings
effects, with at most one native call/query/launch callback pending per job and
no unbounded queue. Reserve before starting any adapter work. Jobs are separate
from listener/store/action workers; no blocking call runs on the UI/listener or
grant-dispatch serialization queue. The metadata query has its own owned run loop;
read gathering deadline is three seconds/core remainder. Sequential supplements
share that budget; bounded round-robin candidate admission across returned source
batches avoids a witness-seed-only implementation but promises no rank/fairness.
Settings setup has its separate wait above and at most one pending prompt job
process-wide, within the same four slots. Limit exhaustion refuses admission,
never replaces a blocked worker or raises descriptor/materialization limits.

| Per admitted job | Bound and ownership |
| --- | --- |
| Applications | 2,048 candidate URLs across sources, 256 distinct identifier expansions (including two system identifiers), 2,048 retained app choices. More observed values cause ENTRY_LIMIT and partial/failed, no fake completion. |
| Settings | 256 pane IDs, 128 anchors/pane, 4,096 total anchors; return every exposed value within those ceilings. Exceeding them is an explicit incomplete failure/unmet inventory, not a selected smaller category. |
| Native calls | 16,384 admitted source/API/syscall attempts including descriptor-relative lookup steps, metadata, registration/preferred calls and AE preflight/send. Reserve before every owned call, not just a high-level adapter; callback receipt is retirement, not fresh work. |
| Location resolution | Existing individual-target lookup caps remain; all constituent calls additionally charge this job. No directory enumeration/contents read. |
| Owned copied values | 8 MiB total including results, in-progress scalar copies, diagnostics, keys and native copied elements; test gross charges before copying. Labels/keys/paths use the bounds above. |
| Diagnostics | 64/job, each guidance at most 1,024 bytes plus bounded native code; reserve the last record for DIAGNOSTIC_LIMIT. |
| Native objects | One opaque result batch/query plus one temporary reply/descriptor set per pending call, or one pending launch callback per job, plus bounded borrowed-element owner state; dispose/release exactly once on real completion. |

Metadata query uses resultCount and bounded result-at-index access, not an owned
copy of its whole results array. CF arrays/AE reply descriptors are opaque native
allocations: their creation and peaks happen before owned copying can be bounded.
Neither these limits nor a clean listener prove a hard native memory/FD/Mach-right
bound. Inspect count/size before allocating copied values; refuse/cap without
repairing them. Any required framework API that allocates a whole opaque result
retains this disclosed limit and finite serviceability obligation.

Cancellation, client loss, deadline, revocation and provider stop atomically
close further admission/publication. Freeze a returned valid partial snapshot
only when still authorized; cancellation/revocation/lifecycle follows Machine
errors rather than fabricating a healthy result. Stop the owned metadata query
and unregister observers on its owner run loop; late callbacks only retire known
owners. Dispose AE descriptors/CF values after true return; launch callbacks and
permission calls may arrive indefinitely late. Never kill a target app, signal
an arbitrary PID, close another owner's reused descriptor, detach unowned work or
reset the process registry on provider restart. Capacity remains occupied until
query retirement and every in-flight native call/callback has returned and all
owned resources are released. Opaque blocked work can consume all four slots
indefinitely; subsequent requests return CAPACITY_LIMIT promptly. Orderly stop
requests cleanup but cannot promise native return. Abrupt host death has no
selected Koine child/orphan protocol; an admitted native launch/setup/reveal may
outlive it. No parent-death helper or supervision service is introduced.

## Source and binary authority boundary

Preserve the four-action source and whole-image guard in an independently linked
WorkspaceActions native image containing only the existing action logic/adapter
and safe individual-target resolution. The workspace principal image routes
GraphQL and snapshot values; WorkspaceDiscovery owns Foundation/index/running/
registration reads; WorkspaceSettings owns fixed read/prepare/setup/reveal with disjoint resolver
seams; only the read seam is reachable from a catalogue query.
None is a new provider identity or public framework ABI. Source/build dependencies
are one way: principal → action/discovery/settings images; action image must not
link, dynamically look up, receive an effect-capable callback from, or call the
discovery/settings images. A shared value/lookup module may not acquire listing,
scripting, spawning or prompting code.

Retain original action checks on its real source and resulting Mach-O imports,
selectors, exports/dependency closure, with updated path ownership only. Apply
finite source and built-image allowlists to each new module: no subprocess,
directory listing, generic interpreter, arbitrary AE target/event, shell, AX,
input/menu synthesis or handler writes anywhere. The settings module's permitted
launch/preflight/send/activate calls are confined to their exact resolvers and
parameters; read resolver can reach only ask=false/no-prompt core/getd.
Discovery never reaches setup or effects. Factory routing, exported interfaces,
link map, actual native image identity and control-grant call traces are part of
N evidence; finding no forbidden selector alone is insufficient for reachability.

Meaningful failing controls compile a forbidden listing/spawn/script/activation
into action source/image; inject an action→settings dependency or effect callback;
route a read resolver through prompting/launch/reveal; remove additional desktop
control from reveal and read authority from catalogue nested fields. Both source
and actual image/load/runtime checks must reject their appropriate controls,
while the legitimate bounded discovery/settings images pass. Production guard
failure blocks acceptance; deleting/widening the original guard is not a remedy.
This packaging remains proposed until actual independently built binaries verify
it. Existing action-only 1.0.0/1.0.1 images remain independent historical subjects.

## Compatibility and acceptance

Contract version remains koine-desktop/1. This is additive workspace schema
1.1.0, provider release 1.2.0; update fixture release 1.3.0/schema 1.1.0. The
already-used action-only update 1.1.0/schema 1.0.1 is not reused or relabelled.
Both new releases declare framework major 1/minor 1 and required features
additional-capabilities-v1 plus first-party-selection-v1; no diagnostic ABI or new failure accessor.
Native images have disjoint module/class symbols, existing workspace reserved
identity/prefix/approved signing identifier, and the host verifies every packaged
image under its existing provider loading policy. No library-validation exception
is selected. Conditional Automation belongs to the host posture, not an inferred
provider feature; a host lacking it gives honest blocked/setup unsupported results.

The acceptance contract fixes complete bundled/update/retained/refusal compositions,
SDL and candidate pins, signatures and eventual measured schema digests. Never
invent a native digest or alter an old capture to match a new design. N exercises
old compatible host/new provider, new host/retained 1.0.0 and 1.0.1 plus action-only
1.1.0, authority-dependent refusal, feature/minor/major rejection, and actual
selected actions. Fresh native host processes prevent mapped-image substitution.
G/N/V subjects and every native verdict remain pending here. Frozen SDL/example,
link and browser/render checks supply design verification only; source declaration
availability and mocked outcomes are no native pass.
