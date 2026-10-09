# Native discovery and client-owned search

**Designed; mandatory review, implementation and native acceptance pending.**
The application population slice now has explicit admission and cost certificates;
its whole-producer review and actual populous native qualification remain pending.
The Settings slice now defines bounded full-response comparison and honest lazy
readiness uncertainty; its cold/warm native qualification remains pending.
Long-application metadata remains unresolved in the same producer. The complete
design is not approved implementation input until
all slices and mandatory review finish. Native acceptance stays pending.
Koine's local explaining UI alone initiates Automation consent. Native provider
releases require `workspace-native-disclosures-v1`; prior hosts refuse them
before code loads rather than serve them under the old grant wording.
Koine supplies OS-known special locations and named application/System Settings
catalogues on macOS 26+ Apple Silicon. Clients own filesystem traversal,
permissions, filtering, ranking, order, budgets, chooser, MRU and clipboard.
Location values grant no access or consent. The [ownership decision](../adr/raw-filesystem-search-belongs-to-clients.md)
and [requirements](../requirements/modaliser-workflows.md#ownership-and-existing-constraints)
govern. The [source report](../verification/native-discovery-sources.md) records
SDK 27 declarations and macOS 26.6.2 shipped data separately from macOS 26.5
comparisons. Those declarations qualify interfaces, not runtime read safety.

Start with [Composition → Own sources and freeze publication](../design/architecture/index.html#diagram-native-discovery-contract)
and [System Settings → Choose read, prepare or reveal; consent stays in Koine’s UI](../design/architecture/index.html#diagram-native-settings-flow).
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
| Workspace composition | Resolver routing, static authority, bounded job owner | Client selects a named operation; production adapters stay inside their owning image, with test-only substitution excluded from shipped linkage. |
| Location adapter | Foundation account/domain value lookup | Returns values without existence checks or contents access. |
| Application adapter | Indexed breadth, running observations, registration and individual bundle inspection | Per-copy choices, provenance and checked native facts; no exhaustive disk promise. |
| Settings adapter | Fixed trusted target, exact event descriptors, no-prompt reads | Runtime panes/anchors and honest stopped/refused/conditional outcomes. |
| Snapshot owner | Admission, budgets, copied values, diagnostics, freeze and true retirement | Nested fields/aliases never repeat native work. |
| Existing action module | Launch/open/reveal resolution and accepted submission rules | Receives explicit selection and its complete controls; catalogue knowledge grants no action authority. |
| Settings effect module | Background prepare, selected reveal; private local-console setup seam | Separate static authority and finite effect allowlists; no remote resolver reaches ask=true. |
| Client | Raw search and presentation, explicit choice to prepare/act | Supplies its own filesystem access, requests each public effect and directs consent setup to Koine. |

A named source adapter concentrates service semantics and uncertainty below the
resolver; callers need not reconstruct three different native protocols.
Calculation/merging uses bounded immutable observations, separate from query
lifetime and authority. Keeping discovery and effects in separate native images
costs packaging and controlled linkage but preserves the accepted action guard;
[the image-boundary decision](../adr/workspace-native-images-preserve-action-authority.md)
records this trade-off and the principal's routing-only responsibility.
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
| Mutation.workspaceRevealSetting(selection:) | workspace:control AND desktop:control | Validate/re-resolve fixed pane/anchor; no-prompt reveal, then fixed-bundle openApplication(activates=true). No preparation or automatic setup; exit during submission can relaunch the target. |

Authority is immutable per schema field coordinate, never inferred from the
root that reached it. Query objects, preparation objects and reveal
objects are disjoint; in particular diagnostics, permission hints, dependencies
and process identities cannot cross these three authority sets. Enums/scalars
may be shared because they have no resolver fields. Register every reachable
field with its group's complete authority and reject any descriptor/schema
combination that disagrees. The SDL check also rejects a deliberately shared
preparation/reveal process object.

Workspace grant disclosure must name these additions: read returns Koine-account
location values and application/settings metadata, not client filesystem access;
control permits background System Settings preparation without desktop control;
launch/open/Finder reveal and selected settings reveal also require desktop
control and may activate. Only Koine's UI requests Automation consent. Preserve
the existing broad launch/open/document-handler disclosures, replacing the false
claim that neither control works without the other. Core owns the text: before
native 1.2.0 ships it must add workspace:read and revise workspace:control in its
served catalogue and all native grant creation/approval/review views. The
[host-disclosure decision](../adr/native-workspace-requires-disclosure-capable-host.md)
binds both new manifests/descriptors and host feature advertisement.

Read is never implied by control. Prepare exposes only control-authorized
receipts and readiness, not panes, names or locations; any
future combined operation publishing catalogue data must additionally require
workspace:read throughout. Preparation requests no activation, so desktop control
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
Permission hints identify READ or REVEAL; there is no public setup input. Mutation
inputs are validated before native work. GraphQL variable/type coercion keeps HTTP 400; provider semantic
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
Expand each distinct coherent seed identifier once, no recursive identifier cascade. Record
every returned choice's actual source membership; a registration supplement is
not falsely labelled indexed. Registration and preferred-location lookup are
per-identifier facts, never an enumeration of all registrations. The deprecated
but declared error-bearing API is chosen for meaningful checked negatives;
if unsupported/unusable, diagnose and keep UNKNOWN, preserving unmet useful work.
The source report cites its SDK/primary documentation.

### Application population admission

An application job stages the complete bounded source response before publishing
choices. Its envelope is 8,192 raw URL observations, 2,048 distinct lossless URL
spellings, 2,048 running objects, at most 2,050 identifier groups (one coherent seed identifier per
spelling plus the two system IDs), and 2,048 distinct identified choices. Raw
observations count repeated entries across the index, running objects, CF
registration list, ordered AppKit list and preferred URL; deduplication does not
refund that work. Distinct spellings share inspection work, but only established
device/inode merges final choices. A whole native batch's count is checked before
owned iteration/copying. Disable metadata-query updates on its owner run loop
before counting/indexed access, then stop/retire that owned query. Gathering
completion is not index-health or category completeness.

Collect the indexed/running spellings and their coherent checked identifiers,
then obtain each identifier's CF list, ordered AppKit list and preferred-only
candidate once. All three domains consume the shared observation/spelling
envelope; there is no smaller identifier quota or per-source survivor quota.
Inspect supplement spellings without recursively expanding new identifiers.
A supplement's missing or conflicting identifier remains unknown with a
diagnostic, rather than creating a new expansion chain or a false eligible copy.
Conflicting identifiers for one spelling do not select a convenient winner.
Only source membership actually observed for a copy is reported.

Within one job, retain bounded immutable resolution outcomes keyed by exact
spelling, and ordered registration membership keyed by identifier. Each spelling
is resolved at most twice: before and after its individual native metadata read;
identity changes refuse that candidate. No native handle/Bundle/process object is
published or pinned for the query lifetime. Shared outcomes let every choice use
the existing action's ordered fail-before-match rule without re-walking the same
registration list for each choice. Earlier unresolved comparisons still prevent
INSTALLED; a later failure does not undo an earlier match. This describes the
frozen observations, never a guarantee about a later action's fresh selection.
Keep resolution and bundle-metadata outcomes separate: the action compares other
registered copies by lookup identity alone. A refused optional metadata read on
an unequal registered copy cannot turn its successful lookup into an unresolved
comparison or block a later match; a real walk failure still does. Metadata
failure prevents publishing an unchecked app choice, not using a checked unequal
lookup as an ordered comparison observation.

Population-wide entry, identifier, call, copied-value, diagnostic or deadline
exhaustion invalidates application publication: status FAILED, items null and
the applicable closed limit reason. Even previously staged useful choices are
withheld. An observed-count overflow alone cannot set resultsTruncated: true
requires an independently checked distinct valid choice actually withheld.
No source-order prefix, witness-only fallback, hidden retry, cursor or lowered
useful category is returned. Source-local unavailability and individual refused
metadata still use the existing honest PARTIAL/UNKNOWN rules when the population
job itself finishes within bounds. Capacity refusal retains the ordinary FAILED
rule. Core response/authority/lifecycle failures keep their independent precedence.

The [finite population subjects](../verification/native-discovery-acceptance.md#application-population-subjects)
include a populous catalogue with over 256 distinct useful identifiers plus
agent/helper pressure and native baseline apps. Every required useful choice must
actually be returned with usable metadata there. These ceilings are a bounded
qualification envelope, not proof that arbitrary machines fit it or finish in
three seconds. A measured ordinary population that overflows, misses witnesses
or misses the deadline is an unmet native obligation for the coverage decision;
it cannot be credited as a passing small catalogue.

Full staging costs temporary bounded state and withholds otherwise useful progress
on global exhaustion. That trade-off keeps native order from deciding catalogue
membership. Keeping the former partial prefix would retain some choices but lose
unexamined useful identifiers arbitrarily. Sorting a capped prefix merely makes
that same omission look deliberate; a universal native user-facing predicate is
also unavailable. Cursor/persistent-cache designs could split larger populations
across reads but introduce a new client/state/identity protocol, outside this
on-demand snapshot contract. Revisit this choice if actual P1024 or an ordinary
measured population cannot meet the shared deadline/gates; do not quietly narrow
the population or raise host policy limits.

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
| INSTALLED | Present checked app, valid identifier and supported handoff spelling; the existing constrained action-selection procedure would select this identity on these observations. Inspect the ordered AppKit registered list plus its preferred-only candidate, stopping at the first identity match. A failure before that match prevents eligibility; later unexamined candidates do not undo a match. |
| UNREGISTERED | Present identified app and valid identifier; the action's full list-plus-preferred domain was checked without a match or unresolved comparison, AND the error-bearing lookup supplies either exact CFError application-not-found (kCFErrorDomainOSStatus/kLSApplicationNotFoundErr, no array) or a complete error-free nonmatching list. No positive or unexamined evidence may contradict this negative. |
| UNKNOWN | Missing/invalid identifier, unsupported handoff spelling, unresolved action-selection comparison, or insufficient/conflicting negative evidence. Empty errorless/nil registration, array plus error, unknown error, capped/unexamined/refused/changed URL or unavailable API cannot establish UNREGISTERED. |

Use the existing action's NSWorkspace.urlsForApplications plus
NSWorkspace.urlForApplication candidate procedure for positive eligibility;
the preferred-only copy is an eligible extra candidate, never a contradiction
merely because the list omitted it. The
[accepted Trash finding](../verification/application-installations-vm.md#what-it-found)
disproves a list-only rule. LSCopyApplicationURLsForBundleIdentifier remains
a breadth supplement and additional conservative negative witness; do not assume
the two APIs equivalent or use it to replace the action's candidate order.
Nil preferred lookup proves nothing independently. A checked negative is a native reported
fact, not internal platform-health proof. Undetected stale/incorrect native state
is possible. Known incorrect witnesses and systematic UNKNOWN launcher metadata
fail acceptance under [the fact decision](../adr/search-native-facts-are-reported-observations.md).
UNKNOWN/UNREGISTERED identified apps remain reveal/copy choices. INSTALLED plus
identifier and applicationPath may feed the existing constrained launch. A client
must preserve both fields, never silently remove a constraint or pick another copy.

### Native facts for client filtering

Choices also expose nullable uiElement and backgroundOnly declarations, from
LSUIElement and LSBackgroundOnly in the same permitted individual Bundle metadata
inspection. A missing key, malformed non-Boolean value, unavailable dictionary or
unsupported metadata yields null, never an inferred false. Retain useful name and
identity even if these optional facts are unknown; diagnose malformed/refused
metadata. No extra plist reader, ancestor inspection or contents listing is added.

runningActivationPolicies is the unique bounded set of REGULAR, ACCESSORY,
PROHIBITED or UNKNOWN observations from running objects whose bundle URL was
associated with this established copy identity. Empty means no associated running
policy observation; UNKNOWN means a returned native value could not be mapped.
Conflicting observed policies remain in the set; they do not merge copies or
override bundle declarations. A running policy is time-varying and cannot predict
the policy of a stopped app. Clients may use these facts for presentation, but
Koine discards no app because it is an agent, background-only, accessory, nested
helper or unknown. Neither policy nor absent flags defines a universal
user-facing-app predicate. Filtering/ranking remains client-owned, and helpers
consume the declared population just like other source candidates.

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
pnam; anchor class xppa and name pnam. Each of two complete core/getd sweeps
reads pALL properties of all application panes, then all anchor names within
each pane selected by its unique ID. The properties reply must be a list of
records containing an exact valid ID and an optional checked name. Each record
supplies its own association; the anchor request supplies its containing pane ID.
No separately enumerated arrays are zipped by order. Properties do not include
the to-many anchor collection. The [source comparison](../verification/native-discovery-sources.md#settings-event-forms-and-association)
weighs the existing separate reads and unassociated flattened batch alternatives.
No NSAppleScript/osascript/ScriptingBridge code compilation is selected. Construct
AE descriptors from validated values. The exact descriptor forms/codes and
reply types are pinned qualification subjects; dictionary declarations do not
prove runtime pALL/unique-ID resolution, useful areas or anchors work. Unsupported
forms are failed/unknown as appropriate; no automatic alternate-form fallback.

### Cold and warm readiness

RUNNING is process readiness only. The admitted dictionary has no catalogue-ready
or anchor-load-complete signal. A get reply can reflect lazy, not-yet-populated
objects; a successful preflight, elapsed delay, identical IDs or identical full
responses cannot establish their health or completeness. Reads perform no reveal,
current-pane assignment, timedLoad, authorize or other extension-loading effect.
Preparation only launches a stopped target and reads no panes. Warm means the
target was already running, not that its extensions were visited or are ready.

The Settings adapter owns descriptor construction, ID association and comparison;
the existing snapshot owner owns admission, clock, gross charges, freeze and
true-return retirement. Finish the first full sweep, wait at least 100 ms on
the owned worker, then start the second. Both sweeps share the unchanged three-
second/core-remainder deadline. The gap is a finite change-detection interval,
not a supported initialization delay. Revalidate target incarnation and live
authority at all existing boundaries, including after the gap. Never wait on
the listener/UI/grant queue. At most two sweeps, one outstanding event per job;
no polling, third sweep, automatic retry or readiness cache across queries.

Compare exact ID-keyed maps of names and pane-scoped anchor-name sets; native
list order is irrelevant, while duplicates, malformed keys and changed
association are errors. Include anchors and optional-label state in comparison.
Changed IDs/labels/anchors give CHANGED_DURING_DISCOVERY and PARTIAL with valid
positive second-sweep choices; if none survives, FAILED/null under change-failure
precedence. Removed first-sweep choices are withheld with that diagnostic;
they cannot certify present destinations. A later failed pane read may retain
individually valid positive observations under the ordinary partial-result rules.
Never union conflicting maps into a fictitious complete snapshot. Count all
received entries before deduplication against the per-sweep ceilings.

Even two equal, fully decoded sweeps leave SETTINGS_RUNTIME observations UNKNOWN:
there is no supported lazy-completeness signal. With positive panes, return PARTIAL
and METADATA_UNKNOWN guidance explaining catalogue readiness; without positive
panes, return UNKNOWN/null items, not AVAILABLE/COMPLETE empty. Preserve every
valid positive pane and anchor, including non-witness destinations. A nonempty
anchor reply supplies those positive exact keys, not a complete anchor inventory.
Source availability AVAILABLE means the running target acknowledged positive
objects, not that its catalogue is ready; without positive objects availability
is UNKNOWN. examined counts raw pane records inspected across both sweeps, not
unique destinations or anchor names. Per-pane availability stays UNKNOWN.
An empty/refused/failed anchor observation remains null with pane-scoped guidance,
never [] as a claim of no anchors. The current source provides no authoritative
empty or conditional-availability signal. These uncertainty diagnostics affect
coverage but do not generate a failed items error. A known native failure, limit,
block or stopped target still follows the ordinary precedence; uncertainty never
hides those outcomes. resultsTruncated is false for readiness uncertainty alone.

The [finite cold/warm subjects](../verification/native-discovery-acceptance.md#settings-cold-and-warm-qualification)
qualify actual useful enumeration without accepting a smaller category. Matching
independent pre-visit cold and warm observations may pass that exact native
subject; it does not upgrade production lazy completeness from UNKNOWN. Missing
ordinary witnesses, newly exposed anchors after a visit, unusable exact forms,
foreground loss or a shared-deadline miss leave usefulness unmet. Unavailable
qualification remains pending. A required new posture or useful-category loss
requires Antony's decision, not a hidden warm-up effect or witness-only filter.

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
The source domain is RUNTIME_EXPOSED_PANES, with observation and category
completeness UNKNOWN under the current lazy-object interface. Network, Sound,
Appearance and Displays
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
REVEAL misc/mvis. Qualify exact-event preflight/send separately; a point-in-time
allowed check for one is no delivery guarantee for another, despite shared OS consent. If useful operations require authorization, the k201 agreement
permits only the needed host com.apple.security.automation.apple-events
entitlement and NSAppleEventsUsageDescription plus this explicit setup path.
Do not ship an unused permission. Record a final effective posture and exact
signature/entitlement/Info.plist digest for each actual host. No policy is changed
by this design, and it establishes no event needs or obtains consent.

Only an explicit human action in Koine's native explaining UI may initiate
setup for READ or REVEAL. This is the local-console principal, not a bearer
credential or a GraphQL mutation, including a koine:manage mutation. The UI
validates an already-running fixed target, checks that exact event with ask=false,
and only if needed and the conditional host posture is qualified calls
AEDeterminePermissionToAutomateTarget for that exact pair with askUserIfNeeded=true
on an owned background worker. Its private host-to-settings seam is unavailable
to provider GraphQL routing. It never sends a catalogue/reveal event, launches,
reactivates, invokes the deprecated authorize command or resets TCC.

Use closed local UI outcome/reason pairs, never parse guidance:
ALLOWED/EXACT_EVENT_ALLOWED (requestMade=false if no ask=true call),
DENIED/EVENT_NOT_PERMITTED, UNAVAILABLE with SETUP_UNSUPPORTED,
TARGET_NOT_RUNNING, TARGET_REFUSED or CAPACITY_LIMIT, FAILED with TARGET_CHANGED
or NATIVE_ERROR, and PENDING/WAIT_EXPIRED. Capacity refusal has requestMade=false
and inFlight=false; WAIT_EXPIRED retains requestMade and inFlight=true until true
return. Every other terminal outcome has inFlight=false and records whether
ask=true was called. A failed validation cannot be relabelled denial. Installation of a
qualified conditional host is explicit deployment, never a read/action effect.
These are private local UI values, not public GraphQL types or new failure ABI.
Permission is a point-in-time observation; setup grants no Koine capability or
guaranteed future delivery.

A setup request preflights one exact event, but the resulting OS Automation
consent authorizes the Koine-host/System Settings pair, not that event alone.
Every trusted provider in the host process shares it; per-field Koine grants
and exact-event adapter restrictions remain separate. Disclose this scope
before setup. A setup request may display OS consent and cannot be recalled once admitted.
The UI wait has a thirty-second ceiling; it is not a GraphQL request and does
not inherit the core's five-second request cutoff. A late user's answer can
change OS consent after the UI wait freezes. Retain the worker/target and prompt
token until real return, suppress stale results and keep in-flight status visible;
do not retry or dismiss another process's dialog. After true return the user may
explicitly refresh exact-event status with ask=false, and the client may explicitly
read or reveal again. Denial directs the user to Koine's explanation and manual
System Settings → Privacy & Security → Automation adjustment, not to a reveal
that itself needs the denied permission. Nothing opens that page automatically.
Normal reads, prepare and reveal never call this prompting path.

### Effect result invariants

Absent independent execution/publication errors, AVAILABLE has a receipt and no
dependency; DEPENDENCY_UNAVAILABLE has a dependency and no receipt; BLOCKED has
permission guidance and neither. Prepare never returns catalogue values. Local UI
setup has no GraphQL result or effect receipt. Unexpected errors/timeouts
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
successful reply revalidate the process and its fixed OS bundle, then submit one
NSWorkspace.openApplication at that checked bundle URL with activates=true,
createsNewApplicationInstance=false, allowsRunningApplicationSubstitution=false,
hides=false, hidesOthers=false, isForPrinting=false, promptsUserIfNeeded=false,
empty arguments/environment and no Apple event. This is the existing launcher's
Launch Services activation primitive, not NSRunningApplication.activate, whose
[background-service refusal is recorded](../verification/desktop-focus-vm.md#what-the-action-does-and-why).
Do not use AX, substitute another pane/anchor or replay after failure. Both
controls are required before either effect.

No launch is submitted for a target already observed stopped. Process validation
and Launch Services submission are not atomic: a target that exits in between
can be relaunched by this primitive, despite the no-new-instance flags. This
primitive limit must be disclosed and tested; it is not an atomic
activate-only operation. Callback must identify the still-validated incarnation
before an acknowledged receipt can be published. A changed target or native
failure after reveal is failed with effects ambiguous, never a substitute reveal
or a claim that no launch occurred.

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
| PARTIAL | Some valid observations (or independently completed empty source) plus an affecting omission/failure/block/unavailable component or Settings lazy-readiness uncertainty; items is a list, possibly empty. |
| UNKNOWN | No useful observation/qualified empty and only unestablished native value/health; items null, diagnostics explain. |
| BLOCKED | No useful observation/qualified empty, prompt-policy refusal, no failure-class diagnostic; items null, no generated error. |
| UNAVAILABLE | No useful observation/qualified empty and an established source/target prerequisite unavailable; items null, no generated error. |
| FAILED | No useful observation/qualified empty and native/malformed/change/limit failure; items null; each selected items alias raises failed. |

With no progress, precedence is failure → block → unavailable → unknown.
Application or Settings population-wide owned-limit/deadline exhaustion is the explicit
exception to progress-based PARTIAL: it always withholds staged items and returns
FAILED as defined above. Source-local failures retain the ordinary table rules.
Gathering completion and successful parsing do not qualify a healthy empty
INDEXED_APPS source. An empty indexed response has availability/observations
UNKNOWN with METADATA_UNKNOWN. If an independently checked registered system
application expected in the declared indexed domain is absent from it, diagnose
that contradiction and keep indexed observations PARTIAL, with availability
UNKNOWN; neither observation proves indexing disabled or internally broken.
Valid running/registration supplements may make the root PARTIAL, never upgrade
this indexed source to COMPLETE/AVAILABLE. Disabled, excluded and rebuilding
subjects must exercise this rule. Empty nil/errorless registration is UNKNOWN. An empty running list is
only empty RUNNING_APPS; a stopped settings app is UNAVAILABLE, never empty.
For SETTINGS_RUNTIME, even equal empty replies establish no catalogue-ready
empty: items is null/UNKNOWN; empty anchors are null. Positive panes give PARTIAL
with observation completeness UNKNOWN and explicit readiness guidance. Missing
ordinary witnesses still fails useful-category acceptance. This source-specific
rule overrides the generic AVAILABLE/qualified-empty branch; it changes neither
application population admission nor location/registration semantics.

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
share that budget. Applications use complete-population staging and fail closed
on a shared owned-budget/deadline overflow; no round-robin survivor sample is
published. Source order remains an observation, not client ranking.
Local UI settings setup has its separate wait above and at most one pending prompt job
process-wide, within the same four slots. Limit exhaustion refuses admission,
never replaces a blocked worker or raises descriptor/materialization limits.

| Per admitted job | Bound and ownership |
| --- | --- |
| Applications | 8,192 raw URL observations, 2,048 running objects, 2,048 distinct spellings, 2,050 identifier groups including the two system IDs, 2,048 retained choices. Shared staging/overflow semantics above apply; no smaller expansion quota. |
| Settings | Per sweep: 256 pane records, 128 raw anchor names/pane, 4,096 raw anchors total; two sweeps maximum. Return every valid exposed value within those ceilings. Population-wide count/call/copy/deadline exhaustion withholds staged Settings items as FAILED/null, never a prefix; useful inventory acceptance remains unmet. |
| Native calls | Application ceiling 1,048,576; Settings 131,072 under the two-sweep certificate below; locations 16,384. All explicit descriptor/API/syscall and cleanup attempts count. Reserve cleanup for held resources before acquisition; exhaustion cannot prevent release. Callback receipt/opaque ARC internals are retirement, not a new source call. |
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

### Settings cost certificate

The [logical certificate](../design/settings-readiness.json) records these
allowances and finite qualification declarations for deterministic design checks.
For N <= 256 pane records and A <= 4,096 raw anchor names per sweep, two
complete sweeps use E <= 2(N+1) = 514 preflighted get events. The 100 ms gap
and every send/decode share three seconds; this count is not a latency promise.
The source's single-ID properties alternative uses up to 1,026 events and is
not an automatic fallback. Two complete maps detect anchor changes for the same
event count as the old single-map/ID-only-repeat recipe, without its readiness
claim. A different native form requires updated qualification and accounting.

| Explicit-attempt reservation in the selected adapter recipe | Maximum |
| --- | --- |
| Initial fixed target/job setup and retirement | 64 |
| Per event: target-incarnation/bundle/signature checks (32), bounded descriptor construction (16), preflight/send/reply handling (8), disposal/cleanup (8) | 64E |
| Per pane record: count/inspect at most sixteen direct keys, validate/extract ID/name/optional class, dispose temporary scalar descriptors | 48(2N) |
| Per anchor: indexed extraction, bounded text conversion/copy and disposal | 4(2A) |

At the envelope, 64 + 64E + 48(2N) + 4(2A) = 90,304 explicit attempts;
round to 131,072. These per-stage allowances are constructible implementation
obligations, not measured SDK costs. The actual native recipe must enumerate
every constituent call and prove it fits, or exhaust the owned gate honestly;
opaque framework/signature/target internals remain outside a caller-visible
attempt count. The prior 16,384 ceiling did not budget two anchor decodes and
all descriptor/disposal work. Locations retain it independently. Reserve
cleanup before acquisition, including descriptor allocations and late replies.

Two compact maps can reuse the second map as the frozen result. Their logical
gross charge certificate is 2[N(512+1,024+128)+A(512+64)] + 2N(512) + 65,536
diagnostic bytes + 131,072 scratch bytes = 6,029,312 bytes at the envelope,
inside the unchanged 8 MiB owned-copy gate. Record/anchor fixed allowances
include indices and bookkeeping; sent selector copies are counted separately.
This requires bounded extraction/discard of unused property fields, at most
sixteen direct record keys, and scalar scratch without recursive copying or
recopying both maps. Count every actual gross copy; a value/type/key/attempt or
scratch overflow fails rather than skipping a choice. The certificate is not a
Swift heap/RSS/native reply peak. Full GraphQL serialization/aliases still charge
the independent 8 MiB response limit; worst-case escaping at the count/string
ceilings need not fit. Overflow fails and leaves usefulness unmet, never returns
a prefix. V12's actual finite subject must fit all gates and the deadline.

### Application cost certificate

Let U be raw URL observations, R running objects, D distinct identifier groups,
C distinct spellings and V actual component visits per descriptor walk, including
expanded links. The finite shallow qualification envelope has U <= 8,192,
R <= 2,048, D <= 2,050, C <= 2,048 and V <= 32. V is a subject description,
not a production path/depth restriction or a change to the action resolver.

| Explicit work in the adapter recipe | Maximum admitted attempts |
| --- | --- |
| Fixed query/run-loop/running-source acquisition and cleanup | 32 |
| Counted source element/path extraction across all URL domains | 2U |
| Running URL/identifier/name/policy/termination getters | 5R |
| Once-per-ID CF/AppKit/preferred acquisition, counts and explicit disposal | 12D |
| Once-per-spelling resource type, Bundle dictionaries/identifier/name/flags and existing short-path denial checks | 8C |
| Before/after descriptor walks, including per-component calls, link handling, errno name-limit and held-handle cleanup | 2C(6V + 4) |

Thus 32 + 2U + 5R + 12D + 8C + 2C(6V + 4) <= 870,456 at the stated
envelope. The next power of two is 1,048,576. The source report explains the walk
bound and why the former 16,384/256 numbers did not cover the choices. This is a
conservative owned-attempt certificate for that recipe/finite subject, not a
latency or opaque-internal-work bound. No C-times-D registration walk term is
permitted. Deeper/longer real candidates charge actual work under the same global
ceiling; inability to finish invalidates publication, not the path's existence.
Actual N accounting must enumerate every adapter attempt and reject a recipe
that exceeds any certificate term before claiming applicability.

The 8 MiB owned-copy gate remains shared by staging, results, diagnostics and walk
scratch, including repeated/transient owned copies. Cardinality and string maxima
are independent ceilings: 2,048 paths of 8,192 bytes do not fit 8 MiB and cannot
all be admitted. Check gross byte charges before every owned allocation/copy;
implementation must expose its record/container and scratch charges at N5, rather
than pretending UTF-8 string lengths bound Swift allocation overhead. The
populous subject supplies a conservative copy certificate and a separate
single-full-selection wire-size certificate. The core's unchanged 8 MiB response
cap still counts aliases/multiple roots/JSON escaping independently. Owned byte
accounting establishes no hard RSS or opaque Foundation/CF allocation peak.

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
registration reads; WorkspaceSettings owns fixed read/prepare/reveal with disjoint resolver
seams and a private setup seam accessible only to Koine's local explaining UI.
Only the read seam is reachable from a catalogue query; no GraphQL route reaches
ask=true, including a management-authorized route.
None is a new provider identity or public framework ABI. Source/build dependencies
are one way: principal → action/discovery/settings images; action image must not
link, dynamically look up, receive an effect-capable callback from, or call the
discovery/settings images, or accept any production effect-capable adapter from
the principal. Construct the production native action adapter inside
WorkspaceActions; export only the four typed action entry points and value
receipts. Private test substitution is test-only and cannot be exported or linked
into the shipped principal. A shared value/lookup module may not acquire listing,
scripting, spawning or prompting code.

Retain original action checks on its real source and resulting Mach-O imports,
selectors, exports/dependency closure, with updated path ownership only. Apply
finite source and built-image allowlists to each new module: no subprocess,
directory listing, generic interpreter, arbitrary AE target/event, shell, AX,
input/menu synthesis or handler writes anywhere. The settings module's permitted
launch/preflight/send calls are confined to their exact resolvers and
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
additional-capabilities-v1, first-party-selection-v1 and
workspace-native-disclosures-v1; no diagnostic ABI or new failure accessor.
Only hosts that serve the corrected workspace read/control disclosures and show
them wherever grants are created/approved/reviewed advertise the new feature.
It is independent of Automation entitlement/usage-key posture. Prior
selection-aware hosts lacking it refuse native bundled/per-user candidates as
INCOMPATIBLE/unsupported-feature before load; a retained eligible action-only
bundle can remain selected-with-refusals. See the complete refusal profile and
G9/N1/V10 disclosure subjects in finite acceptance. No older host is accepted
with incomplete disclosure.
The principal has its own source AND actual-image allowlist: GraphQL routing,
static authority/value composition and bounded owner coordination only. It cannot
construct native action adapters, implement effects, dynamically resolve forbidden
symbols or manufacture effect callbacks. Link maps, production construction paths
and an injected principal-owned action adapter that calls settings must fail N2,
even when the action image's own imports remain clean. Settings activation uses
only the pinned openApplication parameters above; no AppKit activate fallback.

Native images have disjoint module/class symbols, existing workspace reserved
identity/prefix/approved signing identifier, and the host verifies every packaged
image under its existing provider loading policy. No library-validation exception
is selected. Conditional Automation belongs to the host posture, not an inferred
provider feature; a host lacking it gives honest blocked/setup unsupported results.

The acceptance contract fixes complete bundled/update/retained/refusal compositions,
SDL and candidate pins, signatures and eventual measured schema digests. Never
invent a native digest or alter an old capture to match a new design. N exercises
prior host/new native provider refusal, new host/retained 1.0.0 and 1.0.1 plus action-only
1.1.0, authority-dependent refusal, feature/minor/major rejection, and actual
selected actions. Fresh native host processes prevent mapped-image substitution.
G/N/V subjects and every native verdict remain pending here. Frozen SDL/example,
link and browser/render checks supply design verification only; source declaration
availability and mocked outcomes are no native pass.
