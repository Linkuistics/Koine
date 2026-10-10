# Native discovery and client-owned search

**Designed; mandatory review, implementation and native acceptance pending.**
The design includes application population admission and conditional cost arithmetic,
bounded Settings full-response comparison with honest lazy-readiness uncertainty,
and indexed long-application metadata with explicit provenance. Mandatory review
and any earned reconciliation precede implementation. P1024 populous usefulness,
V12 cold/warm Settings usefulness and L1500 long-source/action qualification remain
pending, alongside the other finite native subjects. K212 selects the authorized
explicit application reader: root resource type through 1,023 bytes and held-
directory fixed files/direct-localization plan; larger roots retain actual indexed
tuples. K213/k214 refute its shipped-file closure and useful-subject dimensions;
application-localized-metadata-k215 and mandatory review/earned integration now precede k7. The current application
reader proposal must not be implemented until that redesign settles. The known-plist suffix
cannot admit opaque Bundle localization and no such fallback is selected.
Design consistency establishes
no actual source, timing, resource-peak or binary behavior.
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
location values and application/settings metadata, including fixed application
information/name files and direct localization names, without client filesystem access;
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
an affecting diagnostic. Beyond the fixed application metadata exception below,
no icon, thumbnail, content, arbitrary plist, alias-file
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
and NSMetadataQueryIndexedLocalComputerScope. Read the fixed kMDItemPath,
kMDItemContentTypeTree, kMDItemCFBundleIdentifier and kMDItemDisplayName projection
from the same returned NSMetadataItem. Indexed type/name/identifier are reported
source facts; none establishes bundle-directory identity. No other attribute,
arbitrary item construction or client attribute selection is admitted.
This fixed predicate's array/type semantics
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

Population-wide entry, identifier, call, copied-value or deadline
exhaustion invalidates application publication: status FAILED, items null and
the applicable closed limit reason. Even previously staged useful choices are
withheld. An observed-count overflow alone cannot set resultsTruncated: true
requires an independently checked distinct valid choice actually withheld.
No source-order prefix, witness-only fallback, hidden retry, cursor or lowered
useful category is returned. Source-local unavailability and individual refused
metadata still use the existing honest PARTIAL/UNKNOWN rules when the population
job itself finishes within bounds. Capacity refusal retains the ordinary FAILED
rule. Core response/authority/lifecycle failures keep their independent precedence.
Diagnostic detail saturation follows the independent bounded-guidance policy below;
it never invalidates choices or stops population inspection.

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

Every published app needs positive native application-bundle type and a present
bundle-directory device/inode from bounded individual resolution. At a resolved
root of at most 1,023 lossless UTF-8 bytes, the resource-type/fixed-file episode
below supplies type and optional identifier/localized name/flags (BUNDLE_RESOURCE).
At 1,024 bytes or more, preselect only the associated actual indexed tuple
(INDEXED_ITEM); never attempt a root resource value or foreign Bundle lookup there.
The old 20-byte Info.plist suffix is no ordinary-reader admission proof. Metadata
descendants now use held-directory literal components, including the previously
missed 978…1,003 en-resource band. No suffix, query predicate, running identifier
or client-found path proves type. Refused/untyped candidates have diagnostics and
honest partial/unknown coverage. No unsupported call becomes absence.

### Long application indexed metadata

The fixed query returns NSMetadataItems, not pathname-based metadata readers.
With updates disabled, count the complete batch and inspect its actual returned
objects on the query owner. For a resolved bundle root at least 1,024 UTF-8 bytes,
use only its associated fixed indexed tuple. Below that root boundary the selected
ordinary episode is descriptor-relative; the 1,004-byte known-plist action guard
no longer selects discovery's indexed route. Do not construct NSMetadataItem/MDItem
from a URL, obtain a root resource value beyond its limit, initialize a foreign
Bundle, create a short alias or ask another copy for substitute facts.

Require a native array content-type tree containing an exact native string
com.apple.application-bundle. A bounded native membership lookup checks that
positive member's type; it certifies no unrelated array member or hierarchy
health. Missing, wrong-typed or nonmatching trees establish no negative type;
omit with METADATA_UNKNOWN. Count all raw tree entries, including duplicate
slots, against a shared 65,536-entry limit before the native membership call.
Overflow has population-wide ENTRY_LIMIT/FAILED/null semantics. Do not copy or
enumerate the tree into an owned array; native acquisition/search internals
remain opaque work and are subject to the shared deadline/freeze rules.

Require the exact source path to resolve to a directory. The shared before/after
metadata episode must retain equal device/inode; an observed replacement is
refused. Copy only lossless checked identifier/name scalars under the existing
string/copy gates. Missing or invalid optional scalars stay null with diagnostics;
they do not erase a positively typed identified choice. Repeated indexed tuples
for one spelling must agree on type and nonnull identifier/name; conflicts withhold
the affected optional fact (or the choice for conflicting type) with diagnostics,
never select a convenient tuple. There is no cross-copy metadata borrowing.
Merged aliases retain the metadataSource/state of their first finalized resolved
spelling; an alternate alias cannot upgrade an unsupported selected pathname.
Do the indexed episode while its query is owned; retire it before the running
batch. Retain immutable scalar values only, sharing the existing two-walk allowance.

This associates an index-reported tuple with a presently resolved directory; it
does **not** bind an index record to that inode or prove the occupant's current
Info.plist. A replacement predating the first walk or stale importer values can
escape detection. INDEXED_ITEM makes that source distinction public; actual
wrong witnesses fail qualification, and known conflicts are not hidden as health
uncertainty. Native getter I/O/prompt/hydration and useful long tuples need actual
qualification under the existing access policy. No new permissions or posture
are selected by the declaration.

An INDEXED_ITEM choice remains installationState UNKNOWN: source identifier/type
does not qualify the retained action's whole-path Bundle reader or registration
selection. uiElement/backgroundOnly remain null, with METADATA_UNKNOWN for the
unsupported bundle facts. Associated running policies may still be reported by
checked identity. Keep the first finalized resolved applicationPath and identifier
unchanged; >=1,024-byte locations remain copyable. If explicitly submitted to
launch/named-open/reveal, the existing action contract applies and refuses its
unsupported spelling before requesting an effect. An ordinary BUNDLE_RESOURCE choice at 1,004…1,023 bytes also retains UNKNOWN
installation state: its explicit reader does not qualify the action’s longer
whole-path Info.plist reader. The 1,024-byte action handoff remains independent.

The finite L1500 subject requires **actual** indexed long path/type/identifier/name
tuples, independent current fixture identities and selected-action refusal. Disk
construction, controlled tuples and client discoveries cannot pass that source
precondition. Missing real tuples or wrong values leave an unmet native obligation
for the finite coverage decision, not accepted loss, recursive probing or a
replacement catalogue. The ordinary fixed-file reader does not extend the root resource-type call
beyond its limit; an alias trick adds unqualified support and dropping long choices
reduces usefulness. Keep this actual indexed projection for long roots,
revisiting it with Antony if its actual source/access qualification fails.

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
LSUIElement and LSBackgroundOnly in the same selected fixed information file
inspection. A missing key, malformed non-Boolean value, unavailable dictionary or
unsupported metadata yields null, never an inferred false. Retain useful name and
identity even if these optional facts are unknown; diagnose malformed/refused
metadata. Only the explicit fixed-file/direct-localization exception below is admitted;
there is no ancestor inspection or unrelated contents search.

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

### Localized reader decision

The selected reader uses one observed application copy's root resource type and
explicit fixed metadata files. Antony authorized this target-local contents-read
and direct-localization-listing exception. It adds no helper, OS consent,
entitlement, signing change or useful-category restriction. It lives privately
inside the discovery image; action and shared lookup modules acquire no contents
or listing code. The [facts decision](../adr/search-native-facts-are-reported-observations.md)
and [call manifest](../design/application-localized-admission.json) explain the
trade-off; the [reader view](../design/architecture/index.html#diagram-native-localized-decision)
shows the admission branches. This is a design, subject to mandatory review and
G11/N8/V13 qualification, not an executed native reader.

**Admission and identity.** Preselect by the resolved root's actual lossless UTF-8
byte length. Only URL resourceValues(isApplicationKey) receives the whole target
pathname: root bytes + NUL must be <=1,024. Require a positive checked Boolean
isApplication and present directory identity. At larger roots use only INDEXED_ITEM.
The ordinary episode holds the first resolution's root descriptor until its
fixed reads end, then closes it and performs the second fresh resolution. Equal
before/after device/inode is required; no query-long pin is retained. Metadata
files and layout/localization directories are checked relative to that held root,
with fstatat(no-follow), openat(O_NOFOLLOW), held fstat and post-read name-to-inode
checks. Require directories or regular files respectively; reject links, special
files, denial and known dataless values before reads. Root resolution retains its
existing link policy, but metadata descendants never follow links outside the
observed copy. Replacement, size/time change or conflicting checks withhold the
affected fact (root replacement refuses the choice). The separate native root
resource call, these checks and the final resolution are not atomic: undetected
replacement/read/hydration races remain native qualification limits.

Every supplied component must be lossless UTF-8, contain neither slash nor NUL,
and be neither dot nor dot-dot. Admit its actual bytes against the held
parent's fpathconf(_PC_NAME_MAX) result (NAME_MAX excludes NUL); reserve a separate
terminating byte in owned component storage; indeterminate/refused limits withhold the
metadata, never assume a universal locale length. Descriptor-relative calls
receive a single component, never a reconstructed descendant absolute path.
The root's total length is the only ordinary whole-path admission. Thus the en
file at a 978-byte root is reachable without submitting its 1,024-byte descendant
pathname to a whole-path API. The [suffix counterexamples](../verification/native-discovery-sources.md#localized-reader-admission-evidence)
remain evidence against the former opaque Bundle construction, not thresholds
for this reader.

**Reader consumption hold.** [Shipped-file remeasurement](../verification/application-localized-baseline.md)
refutes the proposed 65,536-byte file gate, useful-subject L/input certificate and
name-file closure: the proposal omits InfoPlist.loctable.
Application-localized-metadata-k215 and its mandatory review/earned integration
must repair that coupled
design before k7 consumes it. The following file/gate recipe is the refuted
proposal, retained for explicit counterexamples; it is not a settled implementable
useful reader. K217 has since selected fixed platform/plain information, strings
and loctable families, 131,072-byte files, the 20 MiB cumulative application gross
gate and individual oversized-file affected-metadata refusal. The
[selected semantic construction](../verification/application-metadata-reader-plan.md)
closes exact base/family order, independent table/direct selection and refusal
semantics. The old file/gate/cost recipe below remains historical counterexample
input until the complete accounting certificate and whole-family reconciliation
land; it does not override that selected plan or lift the hold. No useful loss,
accounting refund, native pass or downstream implementation follows.
The [finite design subject](../verification/application-metadata-subject.md)
adds a frozen bounded development-host census and disk-only P1024/L1500
construction for that decision; it is not an exhaustive supported-VM baseline,
replacement certificate or native acceptance.

**Historical refuted layout/file/cost recipe.** Probe these directory layouts in fixed order:
Contents; Support Files; Resources; flat root. Choose the first present checked
layout. Their resource bases are respectively Contents/Resources, Support Files/
Resources, Resources and the root itself. Information bases are respectively
Contents, Support Files, Resources and the root itself. Only checked absence
advances to the
next layout. Denial, symlink, wrong type or replacement stops that metadata
episode; it cannot select a convenient alternative. Missing resource directory
means checked absence of localized resources, not absence of the app. Probe
Info-macos.plist then Info.plist in the selected information base, and
InfoPlist-macos.strings then InfoPlist.strings in each selected name-resource base.
A checked absent platform file permits the plain file; a present malformed,
refused or oversized preferred file does not. These are the proposed macOS file
families in this refuted proposal, not complete shipped-macOS support; the omitted
InfoPlist.loctable requires an explicit format decision in k215. No product/iOS
variants, executable/icon reads, arbitrary filenames or
foreign Bundle/CFBundle initialization/resource/localization calls are admitted.
This policy supports the named layouts without claiming equivalence to every
private Bundle fallback. An actual useful app outside it is an unmet obligation
for the coverage decision, not accepted loss.

**Localization plan.** Snapshot Locale.preferredLanguages once for the job under
count/string/copy/attempt gates. Enumerate every raw direct entry of the selected
resource directory, including duplicate, nonlocalization and rejected slots,
before selection. Share a 65,536-entry metadata-plan job gate with every preference and selector
result slot, including rejected/duplicate values; never recurse or list ancestors.
Only checked directories whose literal names end in .lproj enter the bounded
inventory. Preserve exact names. Place the information dictionary's development
region first only when it maps exactly and unambiguously to an observed locale;
byte-sort the remaining names. Stripping the suffix forms the possible-localization
array. With no preference match the CF selector can return its first element:
the backstop is therefore the observed development region, or the byte-first
locale when no such region is observed. This is an explicit positional backstop,
not proof of a language match. Optional CFBundleLocalizations is not an inventory
and is not used. Call CFBundleCopyLocalizationsForPreferences with that array and
the explicit nonnull preferences snapshot. Unlike a foreign Bundle getter, this
pure selector has no target pathname or implicit main-bundle context. Count its
result, map each returned name unambiguously to a supplied literal component and
reject foreign/ambiguous values; no native directory order chooses a winner.

The name-file search order is global resource base, selector-returned locales,
Base if present, then the selected information file's CFBundleDevelopmentRegion
if it maps exactly to an observed locale. Deduplicate literal directories. Read
only that finite plan, never all remaining locale files. For each base use the
platform/plain pair above. Within one selected dictionary a usable explicit
display name precedes its usable bundle name. Across planned bases the first
candidate with either usable value wins; a later base's display name never
overrides an earlier base's usable bundle name. Checked absent/healthy empty
applicable resources allow the
next planned base and finally the information file's display/name. Any refused,
malformed, unsupported or incompletely enumerated preceding candidate leaves the
name unknown with diagnostics; do not disguise it with an unlocalized or filename
label. The plan is retained only for this episode; later language/file changes
are not pinned. No hard-coded en/Base/English-only inventory or maximum locale
component length defines useful support.

**Typed facts and parser.** The selected information dictionary supplies only
CFBundleIdentifier, CFBundleDisplayName, CFBundleName, CFBundleDevelopmentRegion,
LSUIElement and LSBackgroundOnly. Name resources supply only display/name; they
cannot override identifier or flags. Scalars must have their exact native types
and satisfy existing lossless string gates; missing/malformed flags stay null,
never false. Do not deep-copy dictionaries or ignored values. Each fixed regular
file is limited to 65,536 bytes and two pread attempts: one exact declared-size
read, then one EOF byte check. A short read, extra byte, changed size/time or
failed check is not a successful prefix and is not retried. Parse immutable
XML/binary/OpenStep property-list bytes with CFPropertyListCreateWithData; require
a dictionary of at most 4,096 keys before scalar getters. CFDataCreateWithBytesNoCopy
uses charged fixed buffers with kCFAllocatorNull. Hold the selected information
buffer/dictionary through name selection so identifier, plain-name fallback and
development-region can remain borrowed; hold at most one current name-file buffer/
dictionary beside it. Retire the latter before reuse and both at episode end.
Transcode only final retained identifier/name values under the existing copy
reserves; never allocate every candidate name or copy the development-region
separately. This also avoids assuming parsed values cannot reference their input. Native parser allocations occur before the owned-copy gate and
have no proved peak; parser I/O/serviceability and actual .strings support remain
N8 obligations. No alternate parser/fallback silently changes this construction.

**Ownership, costs and failure.** The snapshot owner gates every explicit native
attempt and gross allocation/copy, reserves cleanup before acquisition, and freezes
without releasing held resources until actual native return. At most two fixed-file buffers (selected information plus current name file)
and one enumerated resource directory are active; staged query/running/
registration batches keep their existing sequential disposal. Preference, plan,
file bytes and component copies consume the unchanged 8 MiB gross gate. Raw entry,
file/key, call, copy or deadline exhaustion is population-wide FAILED/null; no
per-app locale quota, prefix, hidden retry or helper filtering is admitted. Other
individual metadata refusal can retain positive type/identity with nullable facts
and honest source uncertainty. A known localized witness returning null fails
usefulness even where that API uncertainty is legal.

The [population certificate](../design/application-population.json) records only
conditional arithmetic for the refuted proposal, not useful-subject coverage.
Its recipe is fixed 40; 16U + 5R + 12D; 32C ordinary/indexed staging; 8E raw
metadata-plan slots (directory, preference and selector values); 48F fixed-file
probes; and 2C(6V+4) lookup walks. F <=
4C + 2L, where L counts every retained localization-inventory record per spelling,
including unselected directories; the selected plan is a subset of that inventory.
There is no production L quota: actual calls/copies still share the global gates.
At U=8,192, R=C=2,048, D=2,050, V=32, E=65,536 and the finite shallow L=4,096,
the bound is 2,345,024 attempts under 4,194,304. The finite shallow subject also
requires aggregate fixed-file input <=1,000,000 bytes and localization components
<=32 bytes, with preferences <=32 records/4,096 payload bytes in shared scratch
(qualification dimensions, not universal input limits). With 64L
records, two component copies and existing fixed scratch this derives 8,340,416
gross bytes under 8 MiB; wire remains 7,929,856 under the unchanged core cap.
These dimensions are already refuted by the measured shipped directory subject:
its L is 10,794 and substituting only its information input into the full-envelope
construction gives a 9,131,967-byte certificate subtotal at its old fixed
128-byte locale reservation, not measured allocation. The current 8,340,416 arithmetic
is therefore conditional only, not P1024/L1500 coverage. K215 must replace the
dimensions/construction after the complete required subject is measured.
Extra owned parser copies, repeated plan/name copies or an additional walk
invalidate that construction. [N5/N8](../verification/native-discovery-acceptance.md#n-actual-source-and-provider-binaries)
must account actual calls/allocations term by term and measure these dimensions
with native baseline included. If the required finite useful population does not
fit, k93 records the consumer consequence and seeks the existing coverage decision;
no silent category reduction or host policy increase is authorized.

L1500 now includes a 977-byte ordinary en-localized control and a 978-byte copy
inside the old missed band, plus 1,003/1,004/1,023 ordinary and 1,024/1,500 indexed
copies with actual tuples and distinct same-ID short competitors. Exact localized
names must differ from plain Info names. Ordinary flags come from the selected
information file; indexed flags remain null. At 1,004…1,023 ordinary metadata does
not qualify action Bundle support, so installation state remains UNKNOWN. The
1,024-byte action handoff and independently accepted action evidence remain intact.

Opaque Bundle plus a guessed suffix is rejected because it exposes no complete
pre-call resource plan. Indexed-only metadata avoids contents reads but has no
established useful-name/flag replacement for non-indexed running/registered copies.
Reconsider the explicit reader if actual safety, file-format, localization or
baseline usefulness qualification fails; do not credit this design as a native pass.

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

If the deadline expires after a complete first sweep, including during the gap,
retain that immutable map's uncontradicted positive entries as PARTIAL with
TIME_LIMIT and UNKNOWN observation/category completeness. Accepted second-sweep
evidence of a removed ID or changed name/anchors withholds the affected first-map
entry; discard incomplete second-sweep staging, never union it into the first map.
If no positive entry survives, use FAILED/null for TIME_LIMIT. An incomplete first
sweep has no complete-map checkpoint and deadline expiry withholds its prefix as
FAILED/null. Count/call/copy overflow still fails the population even after the
checkpoint. Target invalidation or authority/lifecycle loss cannot be rescued by
the checkpoint. A completed unequal second map follows the comparison rule above.
Freeze at the shared deadline; late native replies cannot alter the retained map
or start another sweep and ownership survives until true return.

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
block or stopped target follows the table and explicit checkpoint/global-overflow
rules; uncertainty never
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
read data. A no-such-object reply under this lazy interface establishes no absence,
even for an exact pane/anchor selection retained from a prior incarnation. Return
failed at the nullable mutation root with unestablished-selection guidance and no
reveal or activation. Do not report SELECTION_UNAVAILABLE from that reply: the
current source has no authoritative destination-absence signal. Opaque/malformed/
refused answers remain failed or blocked and certify no absence. No retry or
implicit warm-up is admitted. Actual fresh unvisited-incarnation reveal remains
a useful-acceptance obligation, not an accepted loss. Construct misc/mvis
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
Application population-wide count/call/copy/deadline exhaustion and Settings
count/call/copy exhaustion are exceptions to progress-based PARTIAL: they withhold
staged items and return FAILED. A Settings deadline before a complete first sweep
does the same; after it, the uncontradicted-first-map checkpoint rule above applies.
Diagnostic detail saturation never discards choices; reason summaries preserve
the actual source/root precedence. Source-local failures retain the table rules.
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
prompt causes blocked; DIAGNOSTIC_LIMIT marks omitted guidance only, and the
remaining reasons are failure-class. No diagnostic
claims actual missing consent without independent evidence. affectsCoverage is
always true for these discovery reasons. Effect diagnostics have distinct
object coordinates, describe only the fixed target/effect and set
affectsCoverage=false; preparation has no permission hint, while reveal may
identify its exact read/reveal preflight. Reserve a final limit diagnostic before filling
the sink. Native error text is bounded guidance, never a parsed errno/location.

Keep at most 63 detail records plus one reserved DIAGNOSTIC_LIMIT record per job.
When another detail is needed, set the reserved record with null location/pane and
guidance that additional details were omitted, followed by a canonical summary of
all observed source/reason pairs; continue the complete discovery job
without allocating more diagnostic payloads. Per-item/per-pane diagnostic duties
mean a detail while space remains, otherwise this explicit omission. No choice or
anchor is omitted merely to fit the sink; saturation alone leaves resultsTruncated
false. Detail order may reflect native observations, but never determines items,
source availability/completeness or error precedence. Classify every observation
into fixed per-source reason masks and progress/uncertainty/failure flags before
attempting a detail write. Reserve four 32-byte summary slots (128 gross bytes;
at most three source groups in an application job, one in other jobs), including
DIAGNOSTIC_LIMIT's guidance-omission bit. No unbounded per-item summary/counter or
extra native call is needed. Omitted failures still affect the source/root outcome;
a retained uncertainty detail cannot hide a later native failure after saturation.
Detail saturation with positive choices gives the honest PARTIAL outcome, while
without useful progress the summarized underlying reasons decide precedence.
Attach the reserved record to the first source whose detail was omitted. Build its
guidance from the fixed masks, in schema enum order, as
`Additional details omitted. SOURCE:REASON,REASON;SOURCE:REASON`
using exact source/reason tokens, without native
error text or per-item labels. Include every observed reason, including a failure
after saturation; no underlying reason disappears behind uncertainty guidance.
The current closed enums and at most three application source groups fit this
projection within 1,024 UTF-8 bytes; the design check derives the exact worst case.
Other jobs have one source group. This payload uses the reserved record's existing
2,048-byte gross allowance. During discovery record only the saturation flag and
reason masks; render canonical guidance once when freezing the final snapshot,
from bounded reusable scratch into one admitted owned string. Never re-encode it
per observation or allocate a history; actual scratch/transient copies still
charge the existing reservations. Late replies cannot change its frozen text.
Each source's availability/completeness still comes from its own summary. Never
fabricate a global source enum or derive control flow by parsing guidance.

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
| Applications | 8,192 raw URL observations, 2,048 running objects, 2,048 distinct spellings, 2,050 identifier groups including the two system IDs, 2,048 retained choices. Shared staging/overflow semantics above apply; no smaller expansion quota. Separate 65,536 indexed-type entries and 65,536 metadata-plan entries; fixed file 65,536 bytes, dictionary 4,096 keys. |
| Settings | Per sweep: 256 pane records, 128 raw anchor names/pane, 4,096 raw anchors total; two sweeps maximum. Count/call/copy overflow and deadline before a complete first map withhold items as FAILED/null. Confirmation deadline retains uncontradicted first-map positives as PARTIAL/TIME_LIMIT/UNKNOWN, never an incomplete prefix or completeness proof; useful qualification must still finish both sweeps. |
| Native calls | Application ceiling 4,194,304; Settings 131,072 under the two-sweep certificate below; locations 16,384. All explicit descriptor/API/syscall and cleanup attempts count. Reserve cleanup for held resources before acquisition; exhaustion cannot prevent release. Callback receipt/opaque ARC internals are retirement, not a new source call. |
| Location resolution | Existing individual-target lookup caps remain; all constituent calls additionally charge this job. No directory enumeration/contents read in the resolver. Discovery alone holds its episode root for the explicit fixed-file/direct-localization exception; no third walk. |
| Owned copied values | 8 MiB total including results, in-progress scalar copies, diagnostics, keys and native copied elements; test gross charges before copying. Labels/keys/paths use the bounds above. |
| Diagnostics | 64/job, each guidance at most 1,024 bytes plus bounded native code; reserve the last record for DIAGNOSTIC_LIMIT. Saturation continues discovery; four fixed 32-byte source summaries preserve outcomes independently of stored details. Reserve 2,048 gross bytes per diagnostic record/payload. |
| Native objects | One opaque result batch/query plus one temporary reply/descriptor set per pending call, or one pending launch callback per job, plus bounded borrowed-element owner state and the explicit reader’s selected-info/current-name parsed inputs and localization selector state; dispose/release exactly once on real completion. No hard parser/native peak follows. |

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
gross charge certificate is 2[N(512+1,024+128)+A(512+64)] + 2N(512) + 131,072
diagnostic record/payload bytes + 128 source-summary bytes + 131,072 scratch
bytes = 6,094,976 bytes at the envelope,
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

Let U be raw URL observations, R running objects, D identifier groups, C distinct
spellings and V actual component visits per walk including expanded links. Add E
raw metadata-plan slots (all direct directory, preference and selector values) and
L retained localization-inventory records per spelling (including unselected
directories); F fixed-file probes <=4C+2L.
The refuted finite shallow proposal has U<=8,192, R=C<=2,048, D<=2,050, V<=32, E<=65,536 and
L<=4,096, already disproved by the measured system directory inventory. V/L were
proposed qualification dimensions, not production per-path/app quotas.

| Explicit work in the adapter recipe | Maximum attempts |
| --- | --- |
| Fixed source/query/preference acquisition, counts and cleanup | 40 |
| Source element/path and indexed projection/tree/scalar checks | 16U |
| Running URL/identifier/name/policy/termination getters | 5R |
| Once-per-ID CF/AppKit/preferred acquisitions, counts/disposal | 12D |
| Per-spelling root type/layout/directory/selector setup and staging | 32C |
| Raw metadata-plan slot access/check/construction/mapping/disposal | 8E |
| Fixed-file/component/read/parse/getter/transcode/cleanup probes | 48F |
| Before/after walks, links, errno limits and held-handle cleanup | 2C(6V+4) |

At this envelope F<=16,384 and 40+16U+5R+12D+32C+8E+48F+2C(6V+4)<=2,345,024,
under the 4,194,304 gate. The
[source operation table](../verification/native-discovery-sources.md#application-population-construction-evidence)
enumerates each new allowance. This is a caller-visible construction certificate,
not latency, private native pathname closure or opaque internal-work proof.
There is no C×D registration multiplier or third root walk. Deeper/larger inputs
charge actual global work; exhaustion invalidates publication, not existence.
N5/N8 must enumerate actual attempts and reject any recipe exceeding a term.

The refuted [explicit reader proposal](#localized-reader-decision) adds <=1,000,000
gross fixed-file input bytes and 64L records plus two <=32-byte locale components
to the existing 6,816,128 bytes of records/payload/summaries/shared scratch:
8,340,416 under unchanged 8 MiB conditionally. The measured system directory
subject refutes its L/input useful-subject construction; k215 must re-derive it
before consumption. Input/component bounds describe this proposed finite
shallow subject; actual baseline dimensions must be measured without filtering
useful apps. Two 64 KiB fixed buffers and finite preference scratch (<=32 records/4,096 payload bytes) plus fixed plan
scratch reuse the
1 MiB allowance. Final-only scalar transcodes preserve existing payload-copy
reserves. No deep/repeated candidate copies are hidden; native parser allocation
peak is unproved. Wire remains 7,929,856 under unchanged core 8 MiB.

The fourteen extra indexed attempts reserve three fixed attribute getters,
five tree type/count/first-match/member checks, and six identifier/name native
type/length/equality checks. The two transcodes per distinct spelling use reusable
scratch and create only the admitted owned scalar representations; duplicates
compare borrowed native values without allocating new payload copies. Native
membership search/encoding internals are opaque, not a bound on their work. The
65,536 raw tree-value gate is eight entries per worst-case URL slot in the finite
certificate, not a promise that every tree has eight entries; actual totals count
before membership and global overflow withholds all choices. A different adapter
or extra owned duplicate copying invalidates this recipe until reconciled at N5.

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
registration reads and the private fixed-file/direct-localization reader.
WorkspaceSettings owns fixed read/prepare/reveal with disjoint resolver seams and a private setup seam accessible only to Koine's local explaining UI.
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
finite source and built-image allowlists to each new module. Discovery alone
admits fdopendir/readdir/closedir on its one selected resource directory, component-
relative metadata fstatat/openat/fstat/fpathconf/pread/close, no-copy data/property-
list parsing, scalar access and the pure explicit-preference localization selector.
Pin exact fixed files/components and call reachability; these imports alone cannot
prove the scope. Settings/principal/action/shared lookup admit none of that new
contents/listing code. No subprocess, recursive/general listing, generic interpreter,
arbitrary AE target/event, shell, AX, input/menu synthesis or handler writes is
admitted anywhere. The settings module's permitted
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
while the legitimate bounded discovery/settings images pass. Also compile a
general/recursive directory scan, arbitrary file read, foreign Bundle localization
or fixed-reader callback into action/principal/shared lookup and require rejection.
The Discovery image admits only the closed private file/locale plan; a source
control with identical imports but widened paths must fail its reachability guard.
Production guard failure blocks acceptance; deleting/widening the original guard is not a remedy.
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
