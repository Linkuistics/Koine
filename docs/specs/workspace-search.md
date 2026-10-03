# Application and file search

**Designed, pending implementation and acceptance.** Workspace supplies bounded
name discovery for the agreed [application and file workflows](../requirements/modaliser-workflows.md#workflow-inventory).
The [scope and coverage view](../design/architecture/index.html#diagram-search-coverage)
and [selection handoff](../design/architecture/index.html#diagram-search-handoff)
are the reading entry. The [search SDL](../design/workspace-search-schema.graphql)
and [client examples](../design/workspace-search-operations.graphql) define an
additive workspace contribution. They compose with the existing
[launch/open contract](workspace-launch-and-open.md), not a second provider.
The [effect-authority decision](../adr/provider-authority-follows-effects.md)
and [first-party selection decision](../adr/first-party-provider-selection.md)
remain binding. The [prompt-risk decision](../adr/prompt-risk-is-search-data.md)
keeps policy blocking in typed search data. No released or currently served
search behavior is claimed.

**Traversal design requires its load-bearing review before planning.**
Narrow fixed-region Preboot admission permits its measured read-write layout.
Per-root FIFO breadth-first work finishes shallower admitted listings before
deeper ones, preserving later home-root names against an early enormous branch.
The bounded queue reports omitted descent in one reserved root frontier group;
anchor names remain matchable. A process-wide descriptor account reserves job
credits atomically below the inherited soft limit, leaving a non-search reserve.
Normally launched host serviceability remains an acceptance obligation, including
platform-internal descriptors. One reserved depth group retains anchor-count
semantics. Applications use
canonical target names/paths and native bundle identity for one choice per
observed installation. The
[discovery obligations](#discovery-obligations-before-planning) remain mandatory
acceptance subjects. Counted groups and independent root budgets retain their observation contract. The
[coverage decision](../adr/search-coverage-describes-observations.md) explains
the public granularity trade-off. These are design obligations, not native
acceptance or Antony's acceptance of reduced workflow coverage. Prompt-risk
transport has its reviewed schema-level BLOCKED contract with null matches and
no search-generated execution error, subject to field/lifecycle/publication errors.
The compatibility subjects below require distinct retained and search-release
checks before acceptance. Preserve the outcome precedence below. Protected-home
acceptance must assess measured bound-driven omissions alongside protected
scope before the baseline closes. Arbitrary native-order samples are not accepted.

## Discovery obligations before planning

The admission, identity and breadth-first/resource contracts require load-bearing
review before implementation planning. Shallow-name order is per root, not a
promise that all shallow names fit the entry budget or three-second wait.
Queue/entry/depth/value/deadline omissions stay explicit and unaccepted until
measured against the workflows. The process-wide search descriptor account reads
the effective soft limit without raising it, leaves 128 descriptors outside owned
search credits and caps those credits at 72. It bounds search-owned opens;
platform-internal opens and unrelated demand can still exhaust a shared table.
Acceptance must establish independent listener, store and action serviceability
in a normally launched signed host, rather than crediting root-local refusal.
The retained [mount inventory](../verification/protected-path-metadata/environment.json)
describes local APFS Preboot without read-only; the retained
[Safari witness](../verification/open-url-vm/results.json) resolves there.
That evidence rules out read-only admission but establishes neither discovery
nor safe link resolution. Actual default Safari/Finder, protected Library-link
resolution, realistic wide/deep home trees and descriptor-resource failures
remain acceptance obligations across the three seams below.

The queue's frontier group withholds identities and counts observed directory
anchors, not unseen descendants; it does not establish useful discovery within
three seconds. Review's read-only
host inspection found more than 400,000 entries in Development, with an early
branch over 200,000; DFS exhausts the 100,000-entry root budget before later
depth-1 home names. The responsive controlled subject now requires those names
before Development descent; repeated-work and deep/later-root subjects below
make the chosen trade-off testable. This informs constructible subjects, not
native acceptance. Protected and
measured bound-driven omissions need the existing operator decision. Arbitrary
native-order samples remain unaccepted; no smaller workflow domain, new consent,
setup or entitlement follows from this proposal.

## Mechanism and alternatives

Use on-demand directory-name enumeration and application-registration
inspection, without Spotlight, content reads, installation, registration,
downloads, default-handler lookup or consent probing. The
[signed-host experiment](../verification/search-discovery.md) found ordinary
name listing and registered-app inspection prompt-free, protected traversal
prompting, and index-disabled queries still returning matches. The
[metadata evidence](../verification/protected-path-metadata.md) establishes
only its measured calls; it does not authorize traversal or file-handler lookup.

An index-backed interface could find more names quickly but would need honest
UNKNOWN coverage: query startup/count is not index health, and the measured
protected query prompted. It adds a prerequisite whose absence this evidence
cannot diagnose. Reconsider it only with a supported prompt-free mechanism and
availability/coverage signal, or an explicitly agreed weaker coverage contract.
An exhaustive filesystem inventory would need persistent indexing, broader
consent and different resource bounds. It is outside this design. Enumeration
exposes incomplete home coverage and bounded, potentially slow native calls.
Neither alternative justifies silently weakening the agreed baseline.

## Queries and inputs

Both nullable Query roots, and **every output field they reach**, require only
`workspace:read`. They have no additional capability or Reference arguments.
Control never implies read. Denial precedes root inspection; publication
rechecks live read authority under the Machine contract.

| Coordinate | Arguments | Result |
| --- | --- | --- |
| `Query.workspaceSearchApplications` | `query: String!`, `roots: [String!]`, `limit: Int = 50` | `WorkspaceApplicationSearchResult` |
| `Query.workspaceSearchFiles` | Same | `WorkspaceFileSearchResult` |

An omitted or null `roots` uses the defaults below; an explicit empty list is
invalid, as are more than sixteen roots. Each root is a nonempty literal
absolute local path of at most 4,096 UTF-8 bytes, without NUL. No file URL,
glob, shell, tilde or environment expansion occurs. Preserve spaces and
punctuation. Reject invalid values at that root field's original response path
as an existing provider input error (no `kind`), with no filesystem inspection.
Variable coercion retains the existing GraphQL HTTP 400 distinction.
`limit` must be non-null and in 1…200; its omission defaults to fifty.

The query is a literal substring, not a path, bundle identifier, localized name,
content, glob, regex or fuzzy expression. File search compares the final filename
including its extension. Application search uses the metadata-resolved canonical
bundle filename, including for checked .app links, and compares that filename and its
stem with exactly one terminal `.app` extension removed (case-insensitive ASCII
extension comparison); use the better ranking tier of those two keys.
It is at most 256 UTF-8 bytes and contains no NUL. Empty matches all eligible
names; whitespace is literal and is not trimmed. For each comparison key and
the query, normalize to Unicode NFC, apply case/diacritic-insensitive folding
with the fixed `en_US_POSIX` locale, then normalize to NFC again. Compare the
folded Unicode scalar sequences. Canonically equivalent spellings must match;
output names/paths retain their original Unicode. This comparison does not
establish filesystem identity. No query opens an application or document.

### Roots and search domain

Application defaults, in coverage order, are `/Applications`,
`/System/Applications`, the Koine user's home `Applications` directory,
`/System/Library/CoreServices`, and `/System/Cryptexes/App/System/Applications`.
These are generic discovery regions, not a catalogue of configured identifiers.
Nested ordinary directories are searched; application/package contents are not.
Finder beneath CoreServices and relocated apps beneath the Cryptex region are
layout premises awaiting actual-adapter acceptance, as is a visible `.app`
symlink identifying one without traversing its contents. The durable
[Safari registration](../verification/launcher-apps/inventory.json) and
[open-URL witness](../verification/open-url-vm/results.json) place Safari in
Preboot; neither establishes discovery or the link route. The first two
roots' one-level listing is measured; added roots, recursion and link metadata
require signed-host acceptance. Layouts outside these roots/checked links remain
outside the default domain even if Launch Services knows them.
File default is **Koine's actual home directory**, never the client's home or
the provider's current directory. `requestedPath` exposes each effective default.
No client configuration is read. A positively missing optional home Applications
default is reported, not dropped: COMPLETE, zero examined entries, no searched
scopes, and `OPTIONAL_ROOT_ABSENT` with `affectsCoverage: false` at that path.
Its eligible domain is empty and it makes no search progress. The same exception
applies to a positively absent optional Cryptex default on a layout without that
directory. Only these two optional defaults get this empty-domain treatment;
inaccessible/uncertain defaults and explicitly supplied missing roots keep their
ordinary unknown/failure diagnostics. Supplying roots replaces the defaults.

The first implementation admits ordinary directories on the local startup
system/data APFS volumes within Koine's home, `/Applications`,
`/System/Applications`, and the system's local temporary directory. Application
search additionally admits CoreServices and the above Cryptex application region.
Resolve these fixed presentation roots to per-query canonical admission anchors
and native directory identities before descendant checks. The Cryptex exception
requires all of the following, before enumeration or bundle inspection:

- Resolve only the fixed `/System/Cryptexes/App/System/Applications` presentation
  root as the application-region anchor. A client root or registration answer
  cannot nominate an anchor. Positively absent optional default retains its
  empty-domain treatment; uncertain resolution refuses inspection with
  INSPECTION_FAILED unless established absence or unsupported classification
  supplies its own reason. No-progress outcome follows the reason table below.
- Inspect the fixed `/System/Volumes/Preboot` mountpoint without listing it.
  Its no-follow opened directory must be a mount root, with public mount metadata
  reporting that exact mountpoint, local APFS, no network/removable/union
  classification, and an established native device/mount identity. Unknown
  identity or classification is INSPECTION_FAILED; positively established
  unsupported classification is UNSUPPORTED_VOLUME. Read-only is neither required
  nor sufficient. An alternate supported layout can place the anchor on the
  already admitted startup system/data pair instead.
- The canonical application anchor must lie component-wise beneath that fixed
  Preboot mount root on the same inspected mount, or on the startup pair within
  the fixed presentation region. Resolve the trusted presentation path, not a
  guessed UUID or a general Preboot prefix. Establish/recheck its directory
  identity and mounted-volume metadata when opening it. Observed identity/mount
  change refuses with CHANGED_DURING_SEARCH; a nested/other local APFS mount is
  not admitted by this exception. Established unsupported classification uses
  UNSUPPORTED_VOLUME or MOUNT_BOUNDARY, rather than an inferred change.
- Admit only that anchor and its descendants on the same mount for application
  search, including a checked link target there. Preboot's siblings, parent,
  broad mount root and arbitrary APFS mounts remain unsupported. Explicit
  application roots beneath this anchor use the same checks; file search gains
  neither special region.

This is a supported-current-mount-layout classifier, not APFS role attestation
or a guarantee against privileged mount replacement. Public
[filesystem mount metadata](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/statfs.2.html)
supports checking type, flags and mountpoint; native directory identity also
guards opening. It does not by itself prove a boot-volume association.
The fixed OS presentation/mountpoint relationship is an explicit design premise
with actual-adapter acceptance, including the retained read-write Preboot layout.
Unknown layouts refuse rather than admit another local mount. No new signing,
consent, setup or private role-query API is assumed.

Keeping read-only admission excludes the retained Safari layout. Admitting every
local APFS mount or broad Preboot would expand the agreed discovery domain;
a bundle-identifier catalogue would lose generic directory/copy discovery.
Fixed presentation and mount-root identity keep the exception narrow without
requiring a read-only bit. Reopen this classifier for a concrete supported
layout that cannot establish those public witnesses; refusal there remains a
pending default-coverage case, not permission to guess another anchor.

File search gains no general
system-volume traversal. Search does not admit `/` as a broad traversal root, another user's home, or arbitrary
system directories. Outside these supported regions report UNKNOWN with
`UNSUPPORTED_SCOPE`, without enumeration. Mount identity is established by
public filesystem metadata; inability to classify a volume is UNKNOWN, not
permission to inspect it. Network, removable, union mounts, other filesystems
and nested mount transitions are skipped (`UNSUPPORTED_VOLUME` or
`MOUNT_BOUNDARY`). System/data firmlink presentation is treated as the startup
volume pair, not confused with a detachable mount. This restriction is a
declared platform limit, not removable/network acceptance.

Within an admitted root, inspect visible names recursively, with a maximum
relative depth of 32 (root children have depth 1). Hidden entries (dot names or
native hidden metadata), package contents and descendants of symbolic links
are outside the search domain. Report encountered exclusions as counted groups below; a hidden
or package root explicitly supplied is likewise excluded. Files include ordinary
files, directories, packages, application bundles, aliases and symbolic-link
entries as selectable **locations**; special devices/sockets are excluded.
An application search yields application-bundle candidates, never package
contents. Nested ordinary folders are traversed. Filename search includes the
name of a package or symlink, even though its descendants are excluded; hidden
entries themselves are not matches. A root's own name is not a match.

Application-only link exception: a visible symbolic-link name ending in
ASCII-case-insensitive `.app` is a metadata candidate, never a directory task.
Resolve with native metadata before bundle inspection; check both
spellings against protected/cloud policy, admitted regions and volumes. Check
link and target identities before/after inspection; observed change refuses
that candidate with `CHANGED_DURING_SEARCH`. Only a present application target
qualifies; registration compares its native identity using both per-identifier
answers. Return the metadata-resolved canonical target spelling as
`applicationPath` and its final filename as `name`. Application matching and
ranking use that target filename/stem, never the link's alias name. A visible
`Safari Alias.app` link to Safari therefore discovers Safari for `safari`, not
an alias-named application for `alias`; file search can match/copy the link itself.
Both link and direct routes must establish the same canonical target path and
native identity before becoming an app choice. The existing
constrained action selector resolves that selected path again. Never inspect target children,
chase registration answers to discover unrelated names, resolve Finder alias
files, or offer launch for a link to a protected/excluded target. Failed or
blocked target inspection records an affecting ENTRY diagnostic and cannot
produce COMPLETE empty coverage. Known non-app targets are not app matches.
Other links retain intrinsic descendant exclusion. This new application-link
route has no inferred prompt-free guarantee; signed-host acceptance is pending.
Native resolution itself precedes canonical-target policy classification.
The metadata evidence covers only its Desktop/Documents/Downloads fixtures;
it does not establish resolution into sensitive Library areas as prompt-free.
Check an already recognized protected/cloud spelling before any resolution,
then the resolved target before bundle inspection or traversal. A literal link
target whose policy cannot be established without resolution gains no exemption.
Acceptance must inspect every actual resolution call for a link into a named
TCC-protected Library area, such as Mail data, including component/link aliases.
A dialog or hydration request leaves this route pending and requires redesign;
never probe consent through a product read.

Protected policy takes precedence over hidden/package exclusions. Before any
listing, block Desktop, Documents and Downloads under Koine's home and their
descendants with `PROMPT_RISK`. Block the entire home Library with the same
reason, conservatively including sensitive data and cloud containers. These
scopes stay blocked even if Koine may already hold access: no prompt-free public
consent check or setup is established here. Include the four policy scopes in
home-root coverage even when their names are hidden, absent or never enumerated;
the records describe policy, not asserted existence. Explicit roots within them
are blocked without listing. Known cloud-container routes, including common
home Dropbox/OneDrive locations, are excluded with `CLOUD_SCOPE`; Library-based
cloud routes and protected Desktop/Documents aliases are covered by the earlier
rule. Unrecognized file-provider locations cannot be exhaustively identified
from this evidence. Koine requests no hydration/content access; a filesystem
provider's metadata servicing is a stated native limit, not an accepted guarantee
of offline enumeration. A prompting or downloading path found in acceptance
stays pending rather than being accepted as an ordinary read.

Evaluate the supplied spelling and the canonical metadata-resolved root before
descent. A symlink root may resolve to an admitted ordinary location, but a
resolved protected/cloud/out-of-scope root is blocked by that policy. Normalize
`.`/`..` through native resolution, not lexical deletion. Compare path components
and native directory identities for known exclusions, not string prefixes:
`Documents-old` is not `Documents`. Alias files are not resolved as roots.
A missing root is `ROOT_NOT_FOUND`; a file/alias root is `ROOT_NOT_DIRECTORY`;
failed canonicalization without established absence is `INSPECTION_FAILED`.
Unknown canonical paths remain null. There is no trusted arbitrary-path escape
around the exclusion policy.

Use one lossless filesystem-reported directory-path operation for admitted
region/mount witnesses, resolved roots, held frames and application bundles:
the public descriptor-path route, subject to actual-call acceptance. Preliminary
component/link resolution supplies a candidate for policy checks, not a public
canonical spelling. Recheck native identity and mount when obtaining that path;
never mix realpath's Data-volume spelling with the descriptor-path presentation.
Build an ordinary file-entry location from its canonical parent and the lossless
observed entry name; do not resolve a final symlink/alias or Unicode-fold its path.
Firmlink aliases to one root therefore yield equal returned file paths and merge
observed rootIndices under exact-path deduplication. Synthetic protected/cloud
targets use components beneath the canonical home witness without opening
excluded directories merely to canonicalize them; known supplied aliases still
undergo the earlier spelling/identity policy checks. Unknown/overlong native
paths retain the existing INSPECTION_FAILED/VALUE_LIMIT rules, never a second
canonicalization fallback. Signed-host firmlink, case and Unicode witnesses
must establish this route's behavior and prompt-free calls before acceptance.

## Coverage and aggregate outcomes

There is exactly one coverage object per effective input root, in input order,
including duplicates, missing roots and roots never scheduled. It carries its
zero-based `rootIndex`, requested and optional resolved path, state, examined
entry count, completed directory count, searched scopes and skipped scopes.
Counts include obtained native directory entries except `.`/`..`, including
excluded names. EOF in an empty directory makes progress without adding an
entry. `completedDirectories` counts listings that reached EOF, not directories
proved unchanged or error-free. All scope paths are absolute.

Each root has zero searched records before progress and exactly one after it,
anchored at its resolved root. Its extent is `SUBTREE` only for COMPLETE
coverage of the declared eligible domain; otherwise `OBSERVED_DESCENDANTS`
asserts only that counted entry/EOF observations occurred somewhere beneath
that root. It identifies no complete listing, contiguous prefix, named subset
or fully searched subtree. This summary is not a reconstructable traversal
history. A COMPLETE empty directory has SUBTREE and one completed directory;
an absent optional default has neither a searched record nor progress.

Skipped records have a separate extent vocabulary:

| Extent | Exact scope assertion |
| --- | --- |
| `ENTRY` | The named entry's inspection/matching was omitted or uncertain; says nothing about children. |
| `SUBTREE` | This named directory's eligible descendants were not searched. Synthetic policy scopes assert no existence. |
| `CHILD_GROUP` | Exactly `count` encountered child anchors of this representable parent have UNREPRESENTABLE_NAME or overlong-path VALUE_LIMIT; inspection/matching and any descendants are omitted. Identities are withheld. Descendants are not counted. Never asserts that all children were skipped. |
| `DESCENDANT_GROUP` | Exactly `count` encountered anchors somewhere beneath this root have one intrinsic reason, DEPTH_LIMIT or FRONTIER_LIMIT; identities are withheld. Intrinsic reasons retain their name/domain rules. Depth/frontier bounds omit only eligible descendants: directory anchor names remain matchable. Counts anchors, not descendant names; asserts neither a complete listing nor whole-subtree exclusion. |
| `REMAINDER` | Eligible work beneath this root unfinished at freeze: unread stream tails, queued/unopened descent, held-stream work and unfinished metadata. Excludes established observations and already diagnosed frontier/depth omissions without enumerating them; never asserts the whole root was skipped. Its size is unknown. |

`count` is positive only for the two GROUP extents, null otherwise. A group
contains an observed set, not every same-reason entry in an unread directory.
Group records require identical reason, guidance and `affectsCoverage`.
CHILD_GROUP carries only UNREPRESENTABLE_NAME or
overlong-path VALUE_LIMIT, never permission: prompt risk needs an exact ENTRY/SUBTREE
target. Ordinary hidden, package, symlink-descendant and special-file anchors
coalesce into one DESCENDANT_GROUP per reason/root. DEPTH_LIMIT has one separately
reserved DESCENDANT_GROUP per root; it affects coverage and counts only observed
ordinary directory anchors at depth 32, not unobserved descendant names.
FRONTIER_LIMIT has another separately reserved affecting DESCENDANT_GROUP per
root. It counts ordinary directory anchors below depth 32 whose descent tasks
cannot fit the queue count/byte account; their names were examined and remain
matchable. Neither reason requires knowledge of whether the directory is empty.
Apply depth before frontier, so one anchor cannot enter both groups. Do not add
parent-keyed frontier records or silently evict an already queued task.
A package or symlink anchor
may itself be a file match. A directly excluded root/optional absence uses
ENTRY or SUBTREE, not a zero-count group. Unrepresentable children use CHILD_GROUP
at their representable parent, never replacement bytes or parent SUBTREE.
Representable candidate failures use ENTRY; other eligible child-subtree skips
use exact SUBTREE records. Different parents/targets
remain separate. The four synthetic protected scopes stay explicit.
One stop cause per root uses its pre-reserved REMAINDER, with or without progress;
specific earlier failures/policy survive. Anchor it at the resolved root when
established within bounds, otherwise at the representable requested root.
TIME_LIMIT (including an unopened root or blocked first listing), CAPACITY_LIMIT,
ENTRY_LIMIT and DIAGNOSTIC_LIMIT stops use REMAINDER. An individual overlong
resolved root uses VALUE_LIMIT/REMAINDER at the requested root, resolvedPath null.
No-progress stops have UNKNOWN coverage, zero searched records and null count;
the no-progress aggregate failure rule applies. A remainder identifies unfinished
eligible work, not proof that the whole root was skipped or its domain established.
Partial searched observations and a remainder at the same root are compatible.

| Root state | Meaning |
| --- | --- |
| `COMPLETE` | Every eligible name in this root's declared domain was examined, no relevant name/classification was unknown, and all required listings reached EOF; positively absent optional defaults have an empty domain. It is neither an atomic snapshot nor the full filesystem tree. Intrinsic exclusions remain reported. |
| `PARTIAL` | Some scope was examined, but policy, a work bound, failed inspection/listing or missing required application metadata omitted eligible scope/candidates. Home is PARTIAL when progress occurs and UNKNOWN without progress; its policy exclusions prevent COMPLETE. |
| `UNKNOWN` | No eligible scope was examined or its completeness cannot be established; reason/path still state what blocked or stopped it. An unscheduled root is never complete. |

Each skipped scope has a closed reason, human guidance and `affectsCoverage`.
Only intrinsic domain exclusions (`HIDDEN`, `PACKAGE_CONTENTS`,
`SYMLINK_DESCENDANTS`, `SPECIAL_FILE`, `OPTIONAL_ROOT_ABSENT`) have false;
every other reason is true. The positively absent optional default is COMPLETE
without progress; otherwise coverage precedence is UNKNOWN when no progress
was made, otherwise PARTIAL
when any true reason exists, otherwise COMPLETE. Successfully obtaining one
entry or observing EOF in an empty directory is progress. Missing metadata for
a matched candidate contributes `INSPECTION_FAILED`, even when a location can
still be returned with unknown fields. Duplicate/overlapping roots are examined
independently; file matches deduplicate the exact returned path, application
matches the established native bundle identity, with all observed matching
root indices retained for each final choice. Unexamined overlapping roots do
not assert membership. No cross-request snapshot, cache or inventory is kept.

The two result types share these outcome semantics:

| `status` | `matches`, `dependency`, and search-generated execution error, absent other field errors |
| --- | --- |
| `AVAILABLE` | Non-null list, possibly empty; null dependency. At least one root made progress. Check every coverage object before describing an empty list as complete. |
| `BLOCKED` | Null matches and dependency, with no search-generated execution error, including when matches is selected. No progress, no failure-class reason below, and at least one prompt-risk scope; other roots may be absent/excluded. Coverage records each cause. This is a blocked policy outcome, never consent-absence inference or healthy empty. |
| `DEPENDENCY_UNAVAILABLE` | Null matches; dependency `NO_SEARCHABLE_ROOT` with guidance. Every root is missing, not a directory, or excluded/unsupported by the declared domain; no execution error at matches. Coverage gives the exact per-root reasons. |
| `FAILED` | Null matches and dependency; `matches` raises `failed`. No progress and at least one native/identity inspection failure, work-bound/resource refusal or unrepresentable root, as classified below. Prompt risk mixed solely with absence/exclusion is not a failure. |

If any root made progress, `AVAILABLE` takes precedence and successful matches
coexist with explicit partial/unknown diagnostics. With no progress, FAILED
takes precedence for a failure-class reason, then BLOCKED for any prompt-risk
scope, then DEPENDENCY_UNAVAILABLE for purely absent/excluded roots. For example,
`[Desktop, missing]` and `[Desktop, unsupported-volume]` are BLOCKED;
`[Desktop, access-denied]` is FAILED. A non-TCC access denial has
`ACCESS_DENIED` and no permission object; do not infer a consent from errno or
Cocoa 257 alone. Other unexpected failures are `INSPECTION_FAILED`. In a
blocked result a client may highlight the first prompt-risk root in input order;
coverage retains every cause and target and is the only diagnostic payload.

Every skipped reason has a no-progress precedence class; a refused root must
record the established reason, never an unclassified generic refusal:

| Class | Reasons | No-progress aggregate contribution |
| --- | --- | --- |
| Failure | ACCESS_DENIED, INSPECTION_FAILED, CHANGED_DURING_SEARCH, UNREPRESENTABLE_NAME, DEPTH_LIMIT, FRONTIER_LIMIT, ENTRY_LIMIT, DIAGNOSTIC_LIMIT, VALUE_LIMIT, TIME_LIMIT, CAPACITY_LIMIT | FAILED, even alongside PROMPT_RISK. Depth/frontier groups occur only after entry progress in this adapter; pre-turn worker/descriptor admission refusal uses CAPACITY_LIMIT. |
| Prompt risk | PROMPT_RISK | BLOCKED only when no failure-class reason exists. |
| Absence/exclusion | HIDDEN, PACKAGE_CONTENTS, SYMLINK_DESCENDANTS, SPECIAL_FILE, CLOUD_SCOPE, UNSUPPORTED_SCOPE, UNSUPPORTED_VOLUME, MOUNT_BOUNDARY, ROOT_NOT_FOUND, OPTIONAL_ROOT_ABSENT, ROOT_NOT_DIRECTORY | DEPENDENCY_UNAVAILABLE only when no failure or prompt-risk reason exists. OPTIONAL_ROOT_ABSENT retains COMPLETE empty-domain coverage without progress. |

In particular, a root replaced between canonicalization and open records
CHANGED_DURING_SEARCH and contributes failure; `[Desktop, changed-root]` is
FAILED. Uncertain fixed-anchor resolution contributes INSPECTION_FAILED unless
metadata positively establishes absence or an unsupported layout. These outcome
classes do not broaden root admission or authorize retries. After any progress,
all classes remain exact coverage diagnostics under AVAILABLE.

These are **new search result** rules, not changes
to desktop null/absence behavior. A null search root always has an input,
capability or execution error. Status/coverage/matches are read fields: revocation
may suppress any selected branch through standard non-null propagation. A
published status never overrides errors. An error-free result must satisfy the
table's branch invariant; clients report malformed combinations as failure.
The FAILED error is raised when `matches` is selected; a status-and-coverage
query can inspect diagnostics without selecting that failing field. It still
carries no successful list. BLOCKED returns an ordinary successful null value at
matches. FAILED raises the existing failed ProviderFailure at each selected
matches response path. Both derive from the immutable root result without
another native inspection or a GraphQL error hidden inside provider values.

### Selection and publication invariants

Absent any execution error at or above a selected field, every
BLOCKED response object has status BLOCKED, matches null when selected,
dependency null when selected, resultsTruncated false, and one UNKNOWN coverage
object per effective root, except a positively absent optional default retains
its COMPLETE empty-domain state. All roots have zero examinedEntries/completedDirectories
and no searched scopes; at least one skipped scope has PROMPT_RISK with its
permission object, and every root records its own blocking/absence/exclusion
cause. There are no observed matches to truncate. No search resolver returns a
missing-consent failure or synthesizes an error for this branch. Omitting matches
does not change status, coverage or whether an inspection was attempted.
Authorization, input, deadline/response-limit, provider-lifecycle and publication
errors retain their existing handling. A provider stopped after root resolution
can return unavailable at a nested field, including nullable matches; the
surviving status does not override it. Normal non-null propagation can suppress
other fields or the root. No error-free branch invariant is promised there.

Repeated matches aliases within one root read the same frozen result: BLOCKED
returns null at each alias without a search-generated error; FAILED emits a failed
error at each selected alias, retaining its original response path and nullable-field coverage.
Separate aliases of the Query root are independent searches with independent
coverage and shared process-wide capacity accounting; no atomic cross-alias
snapshot is promised. Mixed roots with any progress publish AVAILABLE and a list,
even an empty one, with prompt-risk and other skipped scopes in their own coverage.
Those diagnostics never create a matches permission error.

These guarantees describe only authorized publication. If revocation commits
before a field's publication admission, the existing capability error appears
at that field's original alias/list path. Denial on non-null status/coverage or
a non-null field inside permission propagates to the nearest nullable ancestor;
the permission object itself is nullable, so its denied kind/target can null
that object while other coverage survives. Denial on nullable
matches may leave status/coverage while nulling that list. Root denial nulls that
root. A previously published BLOCKED or AVAILABLE status does not waive later
checks, certify a healthy empty list, or guarantee that coverage survives. Clients
check errors before classifying the surviving branch; they distinguish this
capability refusal from the policy diagnostic. Already published bytes cannot
be recalled. No publication check retries native work or acquires consent.

### Extension-only permission diagnostics

`WorkspaceSearchPermission` fixes `kind: PERMISSION`,
`permissionClass: OS_PERMISSION`, `permissionOwner: KOINE`,
`permissionReason: PROMPT_RISK`, `permissionTarget` to the canonical blocked
scope (requested absolute scope if unresolved), and `consentState: UNKNOWN`.
`osPermission` is nullable and **null in this design**. Include this object only
with `PROMPT_RISK`; it says a known prompting operation was not attempted, not
that permission is absent or denied. No Accessibility field or management enum
is extended. Guidance says this scope is not searched under current Koine policy;
use an ordinary root, and contact Koine's operator for the pending setup decision.
Do not tell a client to trigger a read or acquire an invented consent.

The [diagnostic decision](../adr/prompt-risk-is-search-data.md) chooses schema
data over a new framework failure. Prompt risk is not the fixed version-1
ProviderFailure.osPermission meaning of missing named consent; neither nil nor
blank permission becomes a prompt-risk sentinel. No failure target/reason
accessors, framework minor or diagnostic host feature are added. The
[framework mapping](machine.md#provider-failure-compatibility) preserves every
existing failure kind and constructible nil/blank/named permission value.

An established observation of missing named consent remains a permission error
with that identifier, Koine as owner and the normal response path. It is not
BLOCKED data with UNKNOWN consent. This search mechanism obtains no such
observation: it does not probe protected traversal and ACCESS_DENIED alone does
not identify consent. Adding a reliably observed named-consent state would
require a separately specified diagnostic/schema extension and, for a new
consent/setup, Antony's decision. Clients show PROMPT_RISK as “Scope not searched:
Koine avoids an inspection that may request consent; consent state unknown,”
then its scope and guidance. They show a named-consent error as missing that
documented consent, retaining unfamiliar identifiers and directing the user to
Koine. No new consent, entitlement, usage key, setup route or koine-desktop/1
change is approved.
Register the new search output types as read fields separately from the existing
control-only action types; the workspace provider's current all-control helper
is not the authority for search. Publish workspace provider/schema 1.1.0 as an
additive release, retaining the catalogue identity and composition position.
Both manifest and descriptor declare `additional-capabilities-v1` and
`first-party-selection-v1`; the manifest declares framework major 1/minimum minor 1.
The latter feature is the existing host-selection feature newly declared by this published search
update; it is not a diagnostic feature. A release number never
substitutes for introspection or a conformance profile.

## Matches, ordering and bounds

Application matches carry an absolute metadata-resolved canonical `applicationPath`,
filename `name`, nullable bundle identifier and `installationState`.
`INSTALLED` means an application bundle with a known nonblank identifier and
that exact native file identity present in public registration inspection.
`UNREGISTERED` means registration inspection positively found no entry for that
exact present bundle identity; retain it as a reveal/path-copy candidate and
copy its identifier when known, but never offer constrained launch for it.
`UNKNOWN` means application metadata/registration could not be established;
never silently replace it with another installation. A bundle without an
identifier may appear
as UNKNOWN with a null identifier for reveal/path-copy, and cannot form a launch
selector. Report missing/failed application metadata as partial coverage, not
proof of absence. Inspect both public per-identifier registration answers as
the existing constrained selector does; registrations alone do not prove presence.
One established native bundle identity (mounted volume/device and inode, with
available incarnation metadata checked for change) makes one application choice.
Canonical target filename/path supplies its representative spelling, comparison
keys and rank irrespective of root/link route. Canonicalization uses the same
lossless filesystem-reported directory-path operation as roots, frames and
admission witnesses, requiring actual-call acceptance, never requested-case spelling, Unicode
folding or textual prefix replacement. If that native path cannot be obtained
within its native/value limits, omit the candidate with affecting coverage;
never substitute a link spelling. The canonical filename is that path's final
component. It is not a launch receipt or a query-long pinned file.
Separate native identities sharing an identifier stay separate choices.
An app whose native identity or canonical target path cannot be established is
omitted with affecting inspection coverage; unknown identifier/registration
can still yield UNKNOWN when path and identity are established. Metadata for a
retained identity is its first finalized observation; inconsistent later path,
identifier or incarnation evidence records CHANGED_DURING_SEARCH and neither
creates a second choice nor replaces its metadata. Actions revalidate normally.
The [identity decision](../adr/application-search-uses-bundle-identity.md)
explains why link spelling is not an application naming interface.
There is no exhaustive enumeration of Launch Services registrations.

File matches carry absolute `path`, final filename `name`, `kind` (including
UNKNOWN), nullable content-type identifier and open disposition
`ELIGIBLE`, `REFUSED` or `UNKNOWN`. ELIGIBLE says measured metadata does not
trigger the existing payload refusal, **not** that a default handler exists or
will accept the item. Applications, typed Unix/Windows executables and native
Finder aliases are REFUSED; they remain reveal/copy candidates. Unknown type
alone is not executable proof. Symlink entries are UNKNOWN without target
inspection; actions retain normal symlink semantics. Metadata failure yields
unknown fields and partial coverage. No file contents, icons, thumbnails,
timestamps, localized display name or default application are fetched.

Every file match has `defaultHandlerState: UNKNOWN`, null `defaultApplication`
and guidance explaining that search does not perform the prompting handler
lookup. This remains true for ordinary roots too: one consistent read interface
avoids duplicating action-time default selection. The SDL's nullable named
selector output reserves a meaningful future value, not a type-only fallback.
Unknown default metadata is not `NO_DEFAULT_HANDLER` and does not disable an
explicit attempt through the permitted opening contract.

Rank finalized returnable matching choices by exact folded comparison key, folded prefix,
then folded substring. Applications use the better filename/stem tier, so `zed`
ranks `Zed.app` before `Zed Preview.app`; files use the filename only. Ties use
folded full name in Unicode scalar order, raw name in that order, then raw
absolute path in UTF-8 byte order. Retain the best `limit` returnable locations
by that tuple. Each match has a
fixed reserved slot, so larger metadata cannot evict a better-ranked match in
favor of cheaper lower-ranked ones. Paths exceeding the explicit path bound
are omitted with affecting VALUE_LIMIT coverage, never shortened.
`resultsTruncated` is true exactly
when at least one finalized matching file location or application identity is absent from the final list for
count/path-value reasons. It does not describe unexamined names; partial coverage
can coexist with false result truncation. No MRU or native directory order is
promised. No cross-request top-N guarantee, cursor or pagination exists.

### Resource accounting and scheduling

All bounds below apply to one search root-field resolution, independent of the
GraphQL selection set. Aliases each request a resolution and use the existing
process-wide admission pool. Bounds limit Koine-owned retained values/work,
not native library/kernel allocations or wall-clock syscall duration.

| Account | Bound / ownership |
| --- | --- |
| Roots / matches / relative depth | 16 roots; requested limit 1…200; depth 32 |
| Entry work | 100,000 consumed/classified directory entries **per root**, including nonmatches and intrinsic exclusions; duplicates are independently charged |
| Coverage | 512 searched/skipped records and 256 KiB charged values **per root**; the root object is also charged to its byte account; roots cannot consume each other's partition |
| Matches | `limit` reserved 16 KiB slots, at most 3.125 MiB for 200; paths, metadata, guidance, wrappers and all sixteen root-index slots included |
| Traversal | 384 KiB per root, including one reserved current-stream frame, bounded FIFO pending paths/identities and queue wrappers/slots; at most 512 queued/in-flight tasks and one held stream per root. Count and byte ceilings both apply |
| Owned search descriptors | Process-wide credits at most min(72, max(0, effective soft RLIMIT_NOFILE − 128)); atomically reserve roots + 2 credits per admitted job, at most 18. No limit change, cross-root borrowing or unbounded waiter queue |
| Admission/policy anchors | 320 KiB per job for region/mount, protected and known cloud witnesses, including every retained path occurrence and temporary witness; coverage paths remain separately charged |
| Result wrappers | 8 KiB per job for aggregate/dependency objects, bounded guidance and outer list slots |
| Scratch | 128 KiB charged values per job, one candidate and component walk at a time; at most two temporary descriptors; individual returned/scratch paths and folded comparison keys at most 8,192 UTF-8 bytes; names/optional metadata/guidance at most 1,024/1,024/256 bytes |
| Wait | Three seconds from admission, shared by all roots; no hard native-call deadline |

Charge retained strings by their UTF-8 bytes **at each value occurrence**, plus
256 bytes per object and 16 bytes per scalar/list slot. Count wrappers and
nullable/list slots; null has its slot cost and no string bytes. Charge against the owning reserved partition before
insertion/replacement; do not rely on deduplication or an allocator's capacity.
Counters use bounded integers. These are accounting units, not Swift object
sizes or a wire/RSS bound. JSON escaping, GraphQL aliases and the core's separate
8 MiB response materialization ceiling can still cause a whole-response error.

After validating all inputs, reserve thirteen coverage record slots and 160 KiB
of each root's partition before filesystem work. This holds the root object,
requested/resolved paths (within their limits), one searched summary, four
intrinsic groups, one affecting depth group, one affecting frontier group, four exact home policy scopes with permission targets and
one stop/absence/refusal record. Unused reservation is not lent to another root
or matches. Native values too long for the reserved path space remain unreturned;
stop that root with VALUE_LIMIT at its representable requested scope, resolved
path null if not established within the bound. No fabricated/truncated path.
Optional overlong metadata becomes null with INSPECTION_FAILED before a match
value is finalized. Scalar count/extent updates use reserved slots and cannot
require growing diagnostic strings. Guidance is a fixed bounded template, not
unbounded native error text.

Nonintrinsic exceptions are keyed by exact path/extent/reason; CHILD_GROUP by
parent/reason. Updating a group consumes no new record. Before inspecting the
next entry, keep the stop reservation available. If a required new exception
would exceed the remaining record/byte partition, stop this root, preserve every
previous diagnostic and write DIAGNOSTIC_LIMIT into the reserved REMAINDER for
either total coverage-byte or record-count exhaustion. Fixed guidance identifies
which account was exhausted (record count takes precedence if both would fail).
VALUE_LIMIT is reserved for an individual path exceeding its explicit value
bound, not total diagnostic space. The reserved remainder covers that entry's
uncommitted outcome and all remaining work,
not a falsely universal parent SUBTREE. Mandatory diagnosis always wins; no
match can consume coverage space. Ordinary directories add counters, not
records; intrinsic omissions use four root groups, not one record per package.
Only invalid/overlong-name parent groups and exact native/policy failures grow
with exceptional targets. Width and depth themselves allocate no exceptional
parent records. Such actual failures can still exhaust diagnostics honestly;
neither coarse groups nor reserved depth/frontier counts guarantee useful coverage.

The scheduling unit is at most 64 consumed entries of one root, including
classification and candidate metadata, and at most 32 EOF/open-or-refuse task
transitions. Visit admitted unfinished roots cyclically in input order, one
unit each; all admission/root metadata turns precede listing turns. A root
retains one current stream across its turns. Finish that listing to EOF before
opening the oldest pending directory. Append eligible child-directory tasks to
the tail in observed native entry order; do not open them during the parent's
listing. EOF closes the current stream exactly once; the next task starts a
fresh listing of a previously unlisted directory, not a continuation/replay.
Yield when either unit ceiling is reached, including an empty-directory run.
No sibling array, stream cookie, entry ordinal or completed-listing replay is
retained. A completed/refused root leaves the cycle. A blocked call/shared wait
can prevent later turns; no elapsed-time or per-client fairness promise follows.

The exact order property is: within an unchanged responsive root, every eligible
observed name at depth d in admitted listings is finalized or diagnosed before
any name at depth d+1 is examined. It follows from FIFO parents and finishing
each listing before dequeue. An unadmitted frontier subtree has no observed
descendant names; the property does not imply every name at d exists in the
observations. Across roots, depths need not agree. Work/diagnostic/deadline stops
can cut a level short and prevent all deeper work. No name is repeatedly charged
to reconstruct traversal position; independent overlapping roots still charge
independently. Component metadata revalidation consumes the wait and scratch,
not directory-entry credits; at most 4,096 path components per walk (each needs
at least one byte in the bounded path), with cancellation checked before each
call. This is finite work, not a hard native-call deadline.

Root depth is zero; entries at depths 1…32 are examined. Only directories at
depths 0…31 can be listed. Intrinsic/package/protected/policy classification and
lossless path checks precede descent accounting. An ordinary depth-32 directory
remains matchable and increments the reserved root DEPTH_LIMIT group; do not
open or queue it, even when it is physically empty. For shallower ordinary
directories, commit the anchor's matching/diagnostic outcome and queue decision
as one accumulator transition. Charge and append the task if it fits; otherwise
increment the reserved FRONTIER_LIMIT group, omit only that anchor's descendants
and continue the current listing. Use one fixed guidance template describing
both queue count/byte limits, so differently sized refusals still coalesce into
the same reserved group. Controlled/native instrumentation records which check
refused; no extra public group or reason follows. Later tasks may fit after dequeue; no refused anchor
is retried and no queued task is evicted. Thus all 5,000 shallow child names can
be examined even though only a bounded prefix of their marker descendants is
scheduled. An individual overlong child path uses VALUE_LIMIT CHILD_GROUP and
omits its name too, rather than masquerading as queue exhaustion. A timer freeze
records unread/queued/unfinished work as REMAINDER; already committed frontier
and depth groups survive, with no claim about omitted descendant counts.

Each pending task holds one bounded canonical absolute path, expected target
and immediate-parent identities, relative depth and fixed classification state;
no ancestor path/identity array. On dequeue, retain its charge until inspection
finishes or worker cleanup drops it. Close the completed current stream before
the fresh checked no-follow component walk, using the job's two temporary
credits. Check the admitted root identity and policy and each component's
canonical prefix/volume before opening the next. Immediately before each child
open, obtain the held parent's current canonical location/identity and reapply
protected/cloud/region/mount policy. Compare the final parent/target with the
task's observed identities; revalidate opened identity/policy before stream
conversion. An observed changed queued target uses exact CHANGED_DURING_SEARCH
SUBTREE and continues other tasks; a moved current parent stops that root with
CHANGED_DURING_SEARCH REMAINDER. Unestablished inspection uses INSPECTION_FAILED.
No child open follows observed movement/unknown policy. The remaining
check-to-open prompt window and actual canonical calls require signed-host
acceptance. Rewalking a bounded path does not rescan its ancestors' names.
Stopping at 100,000 consumed entries does not read another entry to guess EOF.

DFS with held ancestors avoids queue overflow but spends 100,000 entries inside
the measured early branch before later home-root names and needs up to 512
streams per job; it fails both reopened obligations. Iterative deepening with
held streams would finish each depth pass before a deeper pass and avoid pending
paths, but must reopen and rescan shallower directories. Every returned entry
would charge again, including pruned/repeated entries; EOF totals would count
repeat listings. A chain reaching depth 32 costs 1+2+…+32 = 528 entries instead
of 32, and repeated passes are separate changing observations. It still needs a
bounded stream stack/descriptor allocation and can exhaust the unchanged wait
before useful deep names. Uncharged rescans or stored visited sets would violate
the work/retained-value bounds. Choose FIFO's explicit frontier omissions and
fresh target revalidation over that repetition. Revisit only if measured queue
omissions defeat the workflow and a bounded alternative demonstrates better
per-witness coverage without larger budgets or an unapproved domain/setup change.

| Choice | Pending values / streams | Repeated work, groups and freeze |
| --- | --- | --- |
| FIFO breadth-first | One frame/root plus at most 512 queued/in-flight tasks, all within 384 KiB/root; roots + 2 owned descriptor credits/job. | Each listing once; one reserved frontier group plus depth group. Queue/stream/unfinished candidate becomes remainder at freeze; worker-only cleanup releases retained paths and credits. |
| Held-stream DFS | No pending queue, but up to 32 frames/root (280 KiB maximum frame shape) and 512 streams + 2 temporary descriptors/job. | Each listing once; depth group only. Early huge branch loses later shallow anchors. A safe shared allowance would refuse this maximum-root shape or require different scheduling; root-local EMFILE is insufficient. |
| Iterative deepening over held streams | No pending queue; the same up-to-32-frame path stack/root and bounded scratch. A cyclic all-root variant again needs up to 512 streams + 2 temporaries; fitting the shared allowance requires fewer simultaneous roots or another turn/admission design. | All returned entries in repeated passes consume the same 100,000-entry account. Internal pass cutoffs cannot pretend to be final depth omissions; final unvisited work still needs an honest remainder. Repeated observed anchor counts would need explicit semantics, rather than a visited set hidden outside the byte account. Freeze retains stacks/scratch/credits until worker-only unwind, as with FIFO. |

Every choice requires the same bounded metadata/scratch and native-call wait
limits; changing traversal does not bound platform allocations or interrupt a
blocked call. The alternatives describe their costs, not additional accepted
implementations or permission to raise limits.

### Process-wide descriptor admission

One process-lifetime workspace search runtime owns the four-worker pool and
descriptor ledger; every factory-created provider instance, alias and request
uses that same owner in the one selected workspace image. Provider stop/start
does not recreate it or unload state while jobs survive. This is a private
composition rule, not a new shared-framework/diagnostic ABI or public seam.
The native constructor substitutes this owner for controlled tests. The
account exposes atomic try-admit/release and charged-open/close guarantees;
callers do not implement locks, fairness or per-root resource arbitration.

Read current soft RLIMIT_NOFILE in the host with
[getrlimit](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/setrlimit.2.html),
never set it. Let L be the effective soft limit, R = 128 the non-search reserve
and S = min(72, max(0, L − R)) the owned search-credit ceiling. An infinite
reported limit uses S = 72 without arithmetic on the sentinel. Unknown/failed
limit inspection refuses every root with INSPECTION_FAILED REMAINDER before
filesystem work. Atomically reserve a worker and Q = effective root count + 2
descriptor credits from S; either both fit or neither changes. Insufficient
room returns CAPACITY_LIMIT for every root, UNKNOWN/zero counts/no searched
record, fixed descriptor-or-worker guidance, no filesystem opens, no queue/retry.
Invalid input/authority checks still precede this admission.

Each root owns one stream credit for its current listing; the job owns two
temporary credits shared serially across anchor admission, component walks,
canonical inspection and bundle-directory inspection. All explicit search
open/dup operations obtain a credit before the syscall, including transient
canonical/bundle witnesses. Descriptor-path inspection on an already charged
descriptor opens none. Failed opens release their attempted occupancy; fd-to-DIR
conversion transfers ownership/charge and is not a second descriptor. Do not
start a component walk or bundle open while another operation holds both
temporary credits. Per-job Q stays reserved until complete worker cleanup,
even when roots finish or the response freezes; unused root credits do not
become extra transient descriptors. There are at most 16 streams + 2 temporary
descriptors/job and 72 owned descriptors across four maximum-root jobs.

Refresh L at admission and before each explicit new open under the account
lock, without holding it across a native call. A lower ceiling never closes a
worker-owned descriptor externally or raises the limit: refuse further opens
with CAPACITY_LIMIT, freeze the observing root's unfinished remainder and let
workers unwind. Outstanding reservations remain charged until cleanup, so a
limit lowered below them is an explicit serviceability limit, not a claim of
continued reserve. An actual native EMFILE/ENFILE despite reservation uses
INSPECTION_FAILED at the observing root; stop further search-open admission
process-wide for the surviving admitted cohort. Other roots/jobs retain earlier
observations and freeze with INSPECTION_FAILED resource remainders when scheduled;
the shared refusal flag prevents every new native inspection in that cohort,
including opaque metadata calls. Already admitted calls may return for cleanup;
already frozen/public results are never rewritten with a later refusal.
No replacement/retry opens occur until that cohort is fully cleaned up and L is
read afresh. New jobs during that refusal cohort get pre-turn CAPACITY_LIMIT,
without opening or joining it. This cannot retroactively isolate unrelated native failures.

S bounds descriptors Koine explicitly owns, rather than all descriptors a
platform API can allocate internally. Bundle/registration/resource metadata
calls may open unexposed descriptors; execute one such call at a time per job
and treat those internal opens as demand against R, together with listener,
store, other providers/actions and inherited descriptors. R is a chosen budget,
not an OS reservation or proof those consumers use at most 128. Before acceptance,
trace the actual call paths and process descriptor high-water under normal launch
and four saturated jobs, including bundle/registration calls and blocked work;
verify independent listener accepts/queries, durable grant-store operations and
authorized launch/open/reveal succeed throughout. If their combined demand does
not fit L − owned search occupancy, or search-attributable opaque opens erase
the margin, the case fails and this allocation/native-call choice must be
reworked before baseline acceptance. Arbitrarily heavy unrelated clients,
system-wide ENFILE and externally lowered limits are outside a serviceability
guarantee. No static cap, simulated table or shell-raised host is native evidence.

### Match retention and freeze

Reserve each match slot at its 16 KiB maximum from the outset, separately from
coverage/frontier budgets. The path/name/optional-string caps and sixteen index
slots must fit that charge; a provider-local accounting test verifies the maximum
shape. Within that slot, charge actual strings/objects/slots by the same formula;
unused room stays reserved. This deliberately costs more than packing variable
size matches, but metadata or new rootIndices cannot force ranked evictions,
consume diagnostics or leave forgotten candidates needed to refill a list.

A matching location is finalized only after classification and its required
coverage outcome commit. An unfinished candidate at a work/diagnostic/deadline
stop belongs to REMAINDER; it does not set result-count truncation merely because
a filename was obtained. The explicit known-match path-value omission above is
the separate value-truncation case. Each finalized candidate's metadata is immutable while retained. Consider at
most the retained list plus one scratch candidate, sort and keep the best
`limit` distinct file paths or application native identities. A retained
identity has the same canonical target name/path and rank through every root
and checked-link route in an unchanged filesystem. Merge its ascending matching
rootIndices; the sixteen index slots are already reserved. Route count never
sets resultsTruncated. Count-based eviction cannot stop scanning or consume
coverage. No history of discarded names, paths or identities is retained.

The threshold only improves. With route-independent rank and stable observed
identity/name/path, an evicted choice cannot later re-enter, so every final
retained choice has kept its observed root membership from its first encounter.
Equal ranking tuples for different identities use the fixed-width native
identity tuple as a final application-only tie-breaker (components compared
lexicographically as unsigned fixed-width values). Distinct copies count
separately even if identifiers agree. The first finalized overflow beyond
`limit` distinct choices sets count truncation; repeated retained routes do not.
A known matching overlong path sets value truncation and VALUE_LIMIT CHILD_GROUP
at its representable parent, omitting that entry/descendants. If the group
cannot fit, root REMAINDER stops work and retains earlier diagnostics. Unfinished
metadata never sets count truncation merely because a name was obtained.

Identity/rank stability is not an atomic snapshot guarantee. Observed change
against retained metadata is diagnosed as above; unretained history cannot detect
all rename, inode reuse or canonical-path changes between visits. In a changing
filesystem top-N and root membership are observations, not a reconstruction of
all historical identities. Acceptance includes these races and must not claim
complete stable inventory from them. The monotone argument concerns fixed native
observations, not unobserved changes. Link inspection uses the current entry's
turn/wait, with no registration-discovery queue.

One serialized accumulator owns counters, retained values and the freeze decision.
Native work has bounded scratch, not another growing accumulator. Freeze transfers
or shares immutable retained values; it does not make a second independently
charged copy while the native job continues. Late work cannot commit values,
change counters or acquire new descriptors after freeze.

The enumeration wait ends after three seconds or earlier provider cancellation.
A timer freezes a value snapshot once: publish available partial results with
`TIME_LIMIT` if progress exists, otherwise FAILED with coverage and a matches
error. The core's five-second request ceiling may answer first with its existing
whole-response error and no promised partial data. External cancellation may
leave no response. No new I/O is scheduled after cancellation/expiry, late
native results cannot mutate the frozen value, and no retry occurs. Cancellation
cleanup never waits for a blocked syscall. A native call already admitted can
finish later; transport loss is not evidence that it was stopped.
The worker is the sole owner of its streams/frames and alone unwinds them.
The timer/canceller can freeze the accumulator and set cancellation, but cannot
close even an idle worker-owned stream. When the call returns, the worker checks
cancellation before using any returned value or scheduling another call, then
closes each owned frame exactly once and releases its charges. No other thread
can reuse a closed frame's descriptor number through a stale frame.

### Capacity examples and acceptance threshold

These constructed layouts assess the accounting contract, **not native
measurements or latency predictions**. Ordinary-directory counts do not each
consume a searched record. All counts are fixture inputs; runtime acceptance
must report each actual root's examinedEntries/completedDirectories, reasons,
latency and resultsTruncated, and compare individual known names, not totals.

| Layout / query | Expected contract outcome when work completes before the deadline |
| --- | --- |
| Application root: 32 branches × 8 leaf directories × 3 ordinary files, plus 150 app bundles and 75 hidden entries; all queued paths ≤128 bytes, query a known app | 1,281 entries, 289 EOF listings; at most 256 pending tasks and one current stream, COMPLETE with one SUBTREE summary and two intrinsic groups. All shallow app names precede branch descent. Link/direct routes to one bundle consume one match slot; distinct copies remain distinct. |
| Home: Development with 32 projects × 8 ordinary leaf directories, each with 3 files and one hidden entry; four protected home anchors and an empty Sites directory; queued paths ≤128 bytes | 1,318 entries, 291 EOF listings; at most 256 pending tasks, one OBSERVED_DESCENDANTS summary, four exact protected scopes and one hidden group. PARTIAL due to policy, no frontier/depth diagnostics. Sites and every other root-child name precede Development descent; known admitted project/leaf names are found. |
| First application root has 100,001 nonmatching entries; later defaults contain the required real apps | First root PARTIAL/ENTRY_LIMIT; later responsive roots receive turns/independent credits and can return apps. Native blocking/shared expiry can prevent later work, with TIME_LIMIT/REMAINDER rather than fictitious searched records. |
| One directory has 5,000 ordinary child directories, each with one marker file; task paths exactly 128 bytes, no child directories below them | All 5,000 directory anchor names are examined before any marker. C = 512 tasks fit: exactly the first 512 markers are examined, and one FRONTIER_LIMIT DESCENDANT_GROUP counts 4,488 anchors (fixed queue-capacity guidance). 5,512 entries, 513 EOF listings, PARTIAL, one current stream. A per-name query returns even the last directory; its marker query is empty with partial coverage. This is a measurable omission, not accepted full descendant discovery. |
| 32 parallel short-name chains to depth 31; first 31 parents have 32 depth-32 ordinary directory anchors, last parent has 8; paths ≤128 bytes; half physically empty, others have an unexamined child | 992 chain entries + 1,000 anchors = 1,992 entries; 993 EOF listings. At most 32 pending tasks and one stream. All 1,000 depth-32 names remain matchable, with one DEPTH_LIMIT group count 1,000 and no frontier group. PARTIAL even for physically empty anchors; child counts remain unknown. |
| Complete directory has 250 matching ordinary files; limit 50 | COMPLETE/SUBTREE, best 50 paths, resultsTruncated true. A partial scan without an omitted observed match can have false truncation. |
| Checked .app link plus canonical root route to Safari; limit 1 | One canonical Safari choice with both matching rootIndices, false count truncation. Another independently installed native copy with the same identifier causes true count truncation and remains independently eligible. |
| Home-shaped controlled order: Development first, then depth-1 Pictures, Zotero, Sites, Applications and nix-migration.md plus four protected anchors. Development lists EarlyBranch first, development-depth2.txt second, then 199,998 nonmatching files. EarlyBranch contains 200,001 files, including deep-needle.txt first. A later explicit root is EarlyBranch itself | Development has 400,001 descendant entries. All five later depth-1 witnesses are finalized before Development opens and returned by individual literal-name queries. development-depth2.txt is observed; deep-needle.txt is unobserved through home because ENTRY_LIMIT cuts Development's own depth-2 listing before EarlyBranch descent. The later root independently returns deep-needle.txt with only its observed rootIndex. Controlled clock allows responsive work through the entry stop; actual native wait must record each witness/omission separately. Bound-driven omissions remain unaccepted. |
| 16 admitted responsive roots, each with a 31-directory chain and a final known file; four jobs | Every root gets cyclic turns and its known deep file; no frontier/depth omission. Q = 18/job, 72 credits total, at most 64 current streams + 8 transient descriptors. At L = 256 the owned account fits, with 184 descriptor slots outside maximum search occupancy; this is arithmetic, not native serviceability. |
| Descriptor allowance below a job reservation | At L = 160, S = 32: one 16-root job reserves 18, a second refuses all roots with CAPACITY_LIMIT and no opens. At L = 128, S = 0: every job refuses. Limit inspection failure instead uses INSPECTION_FAILED. No-progress mixtures with prompt risk obey FAILED precedence. |

Short ASCII fixture paths keep the nonoverflow shapes within traversal and reserved coverage
bounds. Add long-path, invalid-name and native exception variants separately;
invalid/value parent groups and exact failures can exhaust diagnostics even
though the reserved frontier/depth groups cannot. Run individual witness queries
so result-count ranking cannot obscure traversal. Test queue-byte overflow with
8,192-byte paths (43 fit), and the independent 512-task count boundary with short
paths. Inject concurrent atomic admissions, open/dup failure, transferred
stream ownership, limit reduction, opaque platform demand and cohort-wide native
resource failure. A controlled ledger proves the accounting rules, not native
isolation. A normally launched host saturation subject must demonstrate listener
requests, grant-store work and authorized actions stay serviceable, recording
effective soft limit, non-search reserve, reserved credits, actual owned occupancy
and total process high-water, including metadata-internal descriptors.

None predicts native throughput or proves that a real home/default installation
fits three seconds or its descriptor environment. Acceptance also runs realistic
mixed trees with project dependencies, packages/hidden entries, wide depth-6/7
branches and a large first/single directory, plus actual Safari/Finder and
installed apps across their applicable defaults. Record exact omissions and
known names at shallow/deep/later-root positions, comparing each witness rather
than totals. A native-order slice at entry/time/resource limits is pending work
to revisit or a concrete trade-off for the existing protected-home decision,
never a passing baseline. No implementation assumes those future measurements.
If a reduced domain/setup is proposed as a prerequisite, move the existing human
decision ahead of that dependence instead of treating it as already approved.

## Native ownership and race limits

Workspace owns one private search adapter and per-query accumulator: policy,
root admission, filename comparison, bounded top-list calculation, metadata,
coverage and aggregate classification are independent responsibilities behind
one public operation. The Machine core keeps grants, deadlines and publication.
Clients need query/roots/limit and the result contract, not a traversal protocol.
The existing provider composition point and private native-adapter constructor
are the enabling points for controlled failures/clocks; neither is a new product
seam or a fake application's acceptance.

Use a dedicated blocking worker pool of four outstanding search jobs, with no
unbounded queue. This pool and admission accounting belong to the Koine process,
shared by all workspace-search aliases, requests and provider instances.
An admitted job remains counted until its native work and
descriptor cleanup finish, even after its wait expires. Capacity refusal returns
FAILED with UNKNOWN coverage and `CAPACITY_LIMIT`, before filesystem work.
Provider stop cancels jobs without waiting for blocked native calls; workers
retain neither credentials nor resolvers. Provider stop/start does not create
replacement slots or reclaim descriptors a native call still uses. When native
work returns, cleanup releases capacity. If calls never return, affected slots
remain unavailable until a full Koine process restart; CAPACITY_LIMIT guidance
states that recovery and no automatic restart occurs. One client's aliases can
saturate the pool: bounded admission does not promise per-client fairness.
The descriptor account above permits at most one stream per root and two explicit
temporary opens per job, atomically reserved with worker admission; four jobs
use at most 72 owned credits. Platform-internal/unrelated opens consume the
non-search margin, not uncharged explicit-search opens. The normally launched
host must establish serviceability under this allocation; no limit change is
implicit. Native refusal stops further search opens for its admitted cohort.
All worker-owned streams, including idle ones, stay owned and charged across
cancellation until the admitted native call returns and worker-only cleanup
finishes. Provider restart creates no new slot or replacement descriptor for
the retained job.

Coverage partitions total at most 4 MiB, traversal bookkeeping 6 MiB,
match slots 3.125 MiB, anchor witnesses 0.3125 MiB and wrappers 8 KiB per job:
13.446 MiB, or less than 53.782 MiB for four jobs, plus bounded scratch.
Scratch adds at most 128 KiB per job (0.5 MiB for four), so all charged
retained/scratch accounts together are less than 54.282 MiB for four jobs.
These charged values remain the admitted job's even after its response wait
expires; freeze shares/transfers them, never duplicates the accumulator.
A current frame reserves an 8,192-byte path, a 256-byte object and 32 slots
(512 bytes): 8,960 bytes. Queue containers/scheduling state reserve 1,024 bytes;
512 ring slots reserve 8,192 bytes. The remaining 375,040 bytes hold task
objects, each one path + 256-byte wrapper + 16 slots (256 bytes). Charge the
conservative 16-slot shape even when fewer fields are populated. A maximum
8,192-byte task charges 8,704 bytes, so 43 fit, including the dequeued in-flight
task until inspection completes. A 128-byte task charges 640 bytes, so the
512-task count ceiling wins before the byte ceiling.
When a task successfully becomes the current frame, release its queue charge
and transfer the path/identity into the reserved frame without retaining another
uncharged copy. Frozen queue values and worker-owned in-flight values remain
charged; freeze shares state, never allocates another queue.

Thirteen reserved coverage shapes hold root, searched summary, four intrinsic
groups, depth and frontier groups, four policy scopes and stop record. Their
eighteen path occurrences are: two root paths, searched path, four intrinsic
paths, depth path, frontier path, eight policy path/permission-target occurrences
and stop path. One requested path is at most 4,096 bytes; the others at most
8,192, totaling 140 KiB. Twenty object wrappers (5 KiB), 256 scalar/list slots
(4 KiB) and thirteen 256-byte guidance strings (3.25 KiB) total 152.25 KiB,
within the unchanged 160 KiB reservation. A missing group uses no positive count.

A maximum match's path/name/two optional 1,024-byte strings/256-byte guidance,
at most four object wrappers and 64 scalar/list slots charge at most 13.25 KiB;
application native identity fits those slots. Comparison keys are computed in
bounded scratch rather than retained again in each slot. Folded scratch keys
also have an 8,192-byte ceiling; an overlong derived key omits its candidate with
INSPECTION_FAILED instead of truncating comparison. The fixed witness set is:
six admitted regions (home, Applications, System Applications, local temporary
directory, CoreServices and the Cryptex app region); three mount roots (startup
system, startup data and fixed Preboot); four protected home scopes (Desktop,
Documents, Downloads and Library); and the known home Dropbox/OneDrive cloud
routes. Positively absent optional witnesses retain absence, not fabricated
identity. Charge up to two retained presentation/canonical path occurrences per
witness and two temporary witness paths: at most 32 bounded 8,192-byte occurrences,
forty wrappers and 512 slots, totaling 274 KiB within 320 KiB. Fixed literals need
no per-job copy; every actual retained copy still counts. Additional known cloud
aliases/witnesses must fit the same occurrence/wrapper/slot and byte ceilings or
refuse the job, never disappear from policy to save room. Scratch holds
one 16 KiB candidate, at most eight 8,192-byte path/comparison-key occurrences
and 16 KiB other charged state (96 KiB within 128 KiB). Fill the job's anchor
account before any entry/listing turn. If a required witness or temporary value
cannot fit, fail the whole job: each root has UNKNOWN, zero counts/no searched
record and INSPECTION_FAILED REMAINDER at its requested path; resolvedPath is
null because admission did not finalize. Already initialized exact policy
diagnostics remain, using requested scope spellings when canonical targets were
not established; failure still takes precedence over prompt risk. No policy
witness is dropped to continue searching.
This is a job account failure, not inference that any root is absent/unsupported.
Scratch aggregate exhaustion during a root turn stops that root with
INSPECTION_FAILED REMAINDER and fixed resource guidance; no growing platform value is retained
uncharged. Accounting tests must inspect actual value occurrences against these
conservative shapes, including all 16
rootIndices. Four blocked jobs can retain all accounts until cleanup. This is
not allocated memory or hard RSS: libc/kernel and public metadata allocations
are outside the retained-value contract. No complete-directory array is used.

Canonical-root inspection is metadata only. Open admitted directories using
public descriptor-relative operations with no-follow/directory flags; verify
file identity against the classified directory and recheck policy/volume on the
opened descriptor before converting it to a stream. Queued descent uses a fresh
checked component walk after the prior stream closes, retaining at most two
temporary descriptors; every step opens through a held parent and one child
name after the pre-open canonical parent check, never unchecked symlink parents.
Root admission walks do the same. Detect/reject
identity changes or new links as `CHANGED_DURING_SEARCH`; do not follow them or
retry a replacement. Mount/classification uncertainty blocks descent. Bundle
and type metadata remain path-based public calls with pre/post identity checks;
they establish no atomic binding. A parent moved between turns is refused before
child open; descriptor-location inspection itself must be established prompt-free
on the actual moved descriptor. A move after the last check but before open,
symlink races, mount changes and platform metadata behavior remain limits.
The remaining check-to-open race is not accepted as a no-prompt guarantee;
a prompting moved-ancestor case requires redesign rather than a conditional pass.
Observed change
invalidates that scope's completeness; unobserved same-user adversarial races
are not a claimed security guarantee or a no-prompt proof.

The SDK exposes `openat`, `fdopendir`, `readdir`, no-follow and directory flags.
[Apple's directory API documentation](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/opendir.3.html)
supports streaming names; [Apple's libc implementation](https://github.com/apple-oss-distributions/Libc/blob/main/gen/FreeBSD/opendir.c)
also shows that union mounts can cache a whole directory. Reject union mounts
before stream creation, and keep library/kernel allocation and syscall duration
outside the **Koine-owned retained-value** bound. Registration lookups and Bundle
metadata can also allocate inside platform code. No hard RSS, system-call
deadline, race-free traversal or unchanged no-prompt outcome for this new adapter
is inferred from k91's different Foundation listing. Signed-host acceptance
must exercise the actual adapter; a failing guarantee is a pending case.

Return paths and names only when native bytes can be represented losslessly as
GraphQL UTF-8 strings. Never replace undecodable bytes and return a different
location. Omit such an entry and its descendants with `UNREPRESENTABLE_NAME`
as a CHILD_GROUP at its representable parent, affecting coverage; an unrepresentable
resolved root fails inspection rather than becoming a fabricated path.
Malformed bytes are mandatory controlled-adapter cases, including valid siblings
and an unrepresentable resolved root. The admitted APFS VM supplies lossless
valid-name/path witnesses; no invalid-byte filesystem fixture is required or
admitted merely to manufacture a native pass. This does not assert a universal
APFS encoding guarantee. Unsupported raw-byte filesystems remain excluded.

## Selection and action handoff

| Client choice | Input and authority |
| --- | --- |
| Launch/activate an INSTALLED application | Copy **both** known bundle identifier and applicationPath into `WorkspaceApplicationInput`, then `Mutation.workspaceLaunchApplication`; `workspace:control` AND `desktop:control`. Never omit the selected installation path to recover from failure. |
| Reveal an app/file/directory/alias/program | Copy its applicationPath/path to `Mutation.workspaceRevealPath`; both controls. The third-party app notice decision remains pending. |
| Copy path or bundle identifier | Client writes its own clipboard from workspace-read data; unknown identifier disables identifier-copy. Koine adds no pasteboard mutation. |
| Open file with default application | Copy path to `Mutation.workspaceOpenPath`, omit application; both controls. Existing refused payloads remain refused; default handler is resolved at action time, never inferred by search. Protected default-document opening remains pending the existing decision. |
| Open in Zed | Same path, explicit installed Zed selector (`bundleIdentifier: dev.zed.Zed`, and applicationPath if the client selected a particular installation); both controls. No installation, setup or fallback. |

Search paths are locations, not resource references or pinned file identities.
Disappear/replacement after selection receives the launch/open/reveal contract's
dependency, input or failed outcome, not a fabricated `unavailable` search
reference. The action rechecks presence, registration and payload itself.
Classification/handler changes can cause refusal or act on a new occupant;
search promises no stronger identity. An app without an identifier has no launch
route here. Client MRU, chooser labels and secondary-action presentation do not
become server state. Desktop process capture/focus after an action stays the
separate, authorized receipt handoff in the launch/open contract.

## Test seams and acceptance

Reuse the three already agreed seams; implementation/acceptance is planning's
work. The evidence comparison is mechanism input, not search API acceptance.

| Seam | Required cases, all pending for search |
| --- | --- |
| Public GraphQL | Both roots and every nested field under workspace read alone; neither control nor desktop read substitutes. Input defaults/null/empty/limits, mandatory canonical-equivalent Unicode matching, app stem/filename ranking (`zed`, `Zed.app`, `.app`) and rank ties; complete empty versus partial empty, absent optional default versus explicit missing root, UNKNOWN coverage, duplicate/overlapping roots, top-list truncation independent of coverage. Both BLOCKED roots retain exact coverage and null list/dependency without errors, including coverage-only and repeated aliased matches selections. No-progress prompt-risk plus absent/unsupported is BLOCKED; prompt-risk plus real native failure is FAILED at each matches alias; all absent/unsupported has a dependency branch. Mixed successful roots are AVAILABLE with diagnostics and no synthetic matches error. Unregistered apps remain visible for reveal/copy, never launch. Revocation before root and nullable/non-null nested publication has original-path errors/normal propagation; status never overrides them. Absent search provider/schema detection. A reading-restricted standalone client derives choices and every permitted action using only SDL/spec/introspection. |
| Native binary interface | Extend the actual workspace bundle, not a second namespace. Preserve existing named-consent/desktop errors, nil/blank construction/mapping and all four action contributions exactly. Ordinary ProviderValue success/object/null carries BLOCKED through old/new host/provider pairs, with no diagnostic symbols or feature gate. The exact compatibility and search-host subjects below retain desktop-only, absent/rejected and exact-candidate profiles; neither a subset schema check nor historical-profile rewriting proves compatibility. |
| Isolated TestAnyware macOS VMs | Actual signed hardened Koine and the new stream adapter, with no new keys/entitlements: applications in default/nested/user roots, duplicate installed copies, missing identifier/unregistered/unreadable candidates; ordinary and empty directories, home partial, every directly supplied protected root and symlink/component alias, Library and known cloud exclusions; missing/mode-denied roots, index disabled with identical ordinary behavior. Large single directory exceeding entry limit, scope/value/depth and descriptor bounds, cancellation while listing/registration blocks, late completion and worker-capacity recovery, symlink replacement/mount change. Verify no consent dialog or file-content/hydration request from search and inspect all actual calls. Install the required real apps; demonstrate constrained launch, reveal, default ordinary-document open, Zed open and client-owned clipboard/MRU with visible witnesses. Real removable/network/cloud cases stay excluded or pending, never substituted with the ordinary disk-image fixture. Record actual OS/app versions, latency and limits. |

### Compatibility subjects and diagnostic acceptance

Use independently retained binaries, not two rebuilds after a search edit. The
named workspace-actions-1.0-compatibility host is a retained selection-aware
framework-1.1 host bundling workspace provider/schema 1.0.0 and desktop 1.0.0.
Its exact profile is
[core-desktop-workspace-extension-host](../design/profiles/core-desktop-workspace-extension-host.json),
against the unchanged
[action-only composed SDL](../design/desktop-workspace-schema-extension-host.graphql).
Retain its host/framework/provider binaries, source revision and digests before
upgrading search. Existing selection-update evidence and purpose-built subjects
remain historical and must be retained with their original profiles and binary
digests. Their build recipes consume the current tree: rerunning them after a
search edit does not retain the historical subject. In particular, the historical
workspace 1.1.0/schema 1.0.0 update fixture is not the search release merely
because its release number matches.

The search-serving subject is workspace-search-1.1, bundling workspace
provider/schema 1.1.0 and desktop 1.0.0 with the existing framework-1.1 contract.
Implementation must add the exact core-desktop-workspace-search-extension-host
profile and desktop-workspace-search-schema-extension-host composed SDL:
complete core/management + unchanged desktop/actions + this search contribution,
with the actual full candidate rows and those bundled pins. The new profile is
required design work, not a profile already passing here. Do not change the
action-only profile/SDL to make the upgraded bundled host pass it.
For the old-provider/new-host direction, build a dedicated
workspace-actions-1.0-upgraded-core compatibility subject from the upgraded core
with a normally signed sealed catalogue still bundling the retained workspace
1.0.0 baseline. Its exact action-only profile remains unchanged. This is not a
downgrade/override of the shipped search host's 1.1.0 catalogue. Conversely, the
new-provider/old-host direction installs the approved search 1.1.0 bundle as a
per-user update on the independently retained host, with exact SELECTED/PER_USER
and NOT_SELECTED/BUNDLED candidate pins in its search-required profile variant.

Implementation migrates the tree-bound verification consumers explicitly:

| Current consumer | Search-release obligation; historical subject stays unchanged |
| --- | --- |
| Real selection bundle builder (`build-selection-real`) | Its current workspace becomes provider/schema 1.1.0. Newly built workspace updates and renamed updates are release 1.2.0/schema 1.1.0, strictly above that baseline; desktop fixture versions stay independent. Construct and verify feature lists from declared features rather than substituting the old one-feature descriptor literal. Remove the selection feature only from the intentionally refused manifest copies; accepted manifests/descriptors both declare it. |
| Production selection scenarios (`verify-selection-updates`) | Current-production baseline pins move to bundled workspace 1.1.0/schema 1.1.0. Workspace update/refusal pins move to 1.2.0/schema 1.1.0, with new exact search-required baseline, desktop-update, workspace-update, both-update and refused-update profile variants and full candidate rows. Retained pre-search scenarios keep their old binaries/profiles and cannot rebuild them from this tree. |
| Current composition tests (`SchemaConformanceTests`) | The served-core/desktop/current-workspace comparison moves to the new complete search SDL/digest and exact search-required pins. Keep the action-only SDL restriction test and historical profile-model/pin tests as historical contract checks; give them independent fixtures, not the current provider. Add separate search-profile and mutation controls rather than changing historical expected pins. |
| Signed production-app conformance (`vm-verify-conformance`) | Its default subject/profile becomes workspace-search-1.1 and the new exact search-required profile. Action-only runs explicitly select the retained compatibility host or upgraded-core/retained-provider subject and their unchanged profile. Record subject, binaries, catalogue, capture and digests together; a replay of an old capture is not new search evidence. |

Move the consuming check, not its historical profile/SDL. Retain the designated
pre-search host/framework/providers before the first source edit that would
change those binaries. The migration and new profile variants are implementation
obligations, not artifacts already built or passing here.

| Independently built pair / case | Required observation, pending implementation |
| --- | --- |
| Retained workspace 1.0.0 on workspace-actions-1.0-upgraded-core | All four actions and old named-consent/nil/blank failure mapping remain unchanged; run the unchanged exact action-only profile with that retained provider and catalogue baseline, and retain its binary identity. |
| New search 1.1.0 provider on retained selection-aware framework-1.1 host | Loads with minimum minor 1 and both additional-capabilities-v1 and first-party-selection-v1 declared in manifest/descriptor; that retained host supports both. Additive SDL and BLOCKED success/null values work without a diagnostic feature. Use the search-required exact profile with candidate rows appropriate to the selected new bundle, not action-only bundled pins. No new shared-framework symbol is imported. |
| New search provider on released Koine 0.1.0/framework 1.0 | Framework minimum minor 1 and the declared additional-capabilities-v1 / first-party-selection-v1 requirements cause pre-load refusal with no initializer marker. Selection is an existing host feature newly required by this update, not a new prompt-risk feature. |
| Both roots, each wholly protected; coverage-only and two matches aliases | Absent any execution error at or above selected fields: BLOCKED, null matches/dependency, false resultsTruncated, no search-generated errors. Coverage retains targets, PROMPT_RISK, null osPermission and UNKNOWN consent. No nested selection schedules native reads. Include optional-absent default plus prompt risk: absent optional coverage remains COMPLETE, not UNKNOWN. |
| Prompt risk + missing/unsupported; prompt risk + actual denied/native/work failure or changed root; pure absent/excluded | Respectively BLOCKED without search-generated errors, FAILED with failed at each selected matches alias, and DEPENDENCY_UNAVAILABLE without matches errors. Include uncertain fixed-anchor resolution as INSPECTION_FAILED and observed identity/mount change as CHANGED_DURING_SEARCH; established unsupported classification keeps its exclusion reason. Coverage-only FAILED still publishes status/coverage without a selected matches error. |
| Provider stops after a BLOCKED root resolves, before a nested alias resolves | Existing unavailable error at each affected original response path. Nullable matches may leave BLOCKED status/coverage beside that error; non-null field failure propagates normally. No branch invariant overrides the lifecycle error, and no native read is retried. |
| Successful ordinary/empty root + protected root | AVAILABLE with a non-null list, possibly empty, and exact per-root partial/unknown diagnostics; no synthetic matches permission error. |
| Revocation before root or selected nested publication | Capability execution error at the original aliased path; no root work on admission denial. Nullable matches can be null while other data survives. Non-null status or a coverage member propagates to the nullable root; permission.kind denial can null just the nullable permission object, with its original root/coverage/skipped list indices in the error path. Do not assert error-free BLOCKED invariants on the denied response. |
| All existing failure kinds × nil/empty/whitespace/named permission | Verify the Machine mapping unchanged through independently built fixture binaries and original paths, including ignored permission on non-osPermission kinds and resolverMismatch for unknownResolver. No prompt-risk accessor or new malformed diagnostic exists. |

Public GraphQL and the real provider binary establish branch/alias/mapping
behavior with controlled adapter outcomes; the signed hardened VM establishes
the actual policy skips/no-dialog behavior, ordinary plus protected combinations,
and existing actions. Controlled nil/blank/unknown-resolver fixtures establish
compatibility, not a new OS-consent observation. Retain input/output and digest
records for every pair; none of these obligations is established by SDL checks.

Supporting private-adapter tests control EOF, ordering, denied metadata, blocked
workers, deadlines and changed identity. They prove mapping and bounds, not
native consent behavior. No numeric interactive-latency target is invented.
Worker recovery cases distinguish calls that finish after cancellation from
calls held indefinitely: prove saturation persists across provider stop/start,
no replacement threads/descriptors accrue, and a fresh Koine process restores
capacity. The following discovery/coverage cases extend every seam's obligations; all are
pending implementation/acceptance:

| Case | Public GraphQL expected observation | Native binary expected observation | Signed hardened VM expected observation |
| --- | --- | --- | --- |
| Default Safari/Finder and controlled alternate layouts | Omitted/null roots expose all five defaults in order; Safari/Finder have observed paths, nonblank identifiers, INSTALLED after established registration; both feed constrained launch. A positively absent Cryptex optional root is COMPLETE/OPTIONAL_ROOT_ABSENT; explicit absence is UNKNOWN/ROOT_NOT_FOUND. | Controlled adapter supplies alternate canonical anchors, absent optional region and real distinct copies versus two routes to one bundle, under the canonical-target identity and fixed-region admission design. Exact search SDL and unchanged action-only compatibility subjects remain required. | Required real apps installed; actual Safari and Finder paths are found under default search without dialogs/launch, under the reviewed admission/identity contract. Known paths/identifiers and actions have independent witnesses. Test another layout when a concrete supported VM subject exists; otherwise record that condition as not applicable with OS/layout evidence, without claiming native proof of alternate layouts. Actual default/call cases remain mandatory and pending. |
| Application links/aliases | Using canonical target filename/path, registered .app targets yield INSTALLED and unregistered targets yield UNREGISTERED; denied/protected/dangling or changed targets cannot yield COMPLETE empty. Alias files/non-app symlinks never become launchable apps. File-search symlinks remain UNKNOWN without target inspection. | Controlled adapter supplies matching/mismatched native identities, both registration answers and one filesystem-reported canonical path across case/component/link spellings. Limit-1 duplicate routes have false count truncation and merged rootIndices; equal-identifier native copies remain distinct. Canonical target queries match, alias-only app queries do not; file queries retain link names. Inject canonical-path/value failures and rename/reuse observations. Path and identifier action inputs remain unchanged. | Inspect actual target/link metadata, resolution order and mount checks. Include links to Desktop/Documents/Downloads and a named protected Library sub-area (Mail data), with component aliases. No protected traversal, alias-file resolution, default-handler lookup, registration writes or content/hydration request. Resolution itself must be prompt-free under actual signed Koine; earlier metadata evidence does not establish it. Cryptex admission/races use the actual adapter; no new keys/entitlements. |
| Wide realistic layouts / later-root scheduling | The responsive 400,001-entry Development subject returns all five later depth-1 witnesses and development-depth2.txt before ENTRY_LIMIT; deep-needle.txt is absent through home and present through its later explicit root. Individual queries prevent ranking from hiding a witness. The 5,000-child subject returns every anchor name; first 512 markers only, with FRONTIER_LIMIT count 4,488. Native timeout/remainder never claims unseen roots were searched. | Real bundle with controlled native order/clock verifies FIFO depth order, both unit ceilings, no rescans, exact first/last frontier markers, 1,000 depth anchors and all 16 deep roots. Queue count/bytes and the thirteen reserved coverage shapes fit unchanged partitions. Existing exact search-required and action-only profiles remain distinct. | Run actual home/default and prepared measured-scale wide/deep trees; record each shallow/deep/later-root witness, observed native order, omission reason, coverage and latency under the real three-second wait. Real Safari/Finder/defaults and protected Library-link behavior remain pending; queue/entry/depth/value/deadline omissions require the human decision. |
| Exact scope groups / exhaustion | Invalid/overlong names have actual-parent CHILD_GROUP and omit the anchor name too. DEPTH_LIMIT and FRONTIER_LIMIT each use one separately reserved root DESCENDANT_GROUP; both count observed matchable anchors, not descendants. Depth wins when both might apply, including physically empty anchors. Stop uses REMAINDER/null count with or without progress; only progress adds a searched record. | Verify 512 short tasks fit and task 513 gets frontier count; 43 maximum-path tasks fit and task 44 is byte-refused under the same guidance. No rejected task is retried or queued task evicted; siblings remain matchable. Freeze while queued/in-flight paths survive, preserving earlier groups and exact exceptions. Test the thirteen reserved coverage shapes, all sixteen rootIndices, malformed/overlong roots and full fifteen-witness account; pre-turn witness overflow refuses every root with INSPECTION_FAILED. | Actual APFS names, long component paths and wide/depth fixtures record count/byte refusals in instrumentation separately from individual VALUE_LIMIT. Inspect every region/mount/protected/cloud witness occurrence and actual queued/task/scratch charge. Invalid-byte and alternate-layout controlled cases remain distinct from native admitted fixtures. |
| Shared process descriptor serviceability | At L = 256, four 16-root jobs atomically reserve 72 owned credits; additional aliases/providers refuse with CAPACITY_LIMIT and all UNKNOWN roots before opens. At lower limits Q either fits wholly or opens nothing. Native EMFILE/ENFILE is INSPECTION_FAILED and blocks further cohort/new-job opens without retry. | Substitute one shared owner across provider instances; race worker/credit acquisition, inspect every component/canonical/bundle open/dup charge and transfer/close. Exercise L = 128/160/256/infinite/unknown, lowered L, native failures and opaque-call occupancy; reservations and failed-open occupancy are distinct. Simulated descriptors alone prove no serviceability. | Launch signed hardened Koine by its normal LaunchServices/login route with unchanged inherited soft limit. Saturate four searches including blocked listing and actual bundle metadata while an independent client repeatedly makes new listener connections/queries, durable grant create/revoke/read operations and authorized launch/open/reveal. Record effective L, R = 128, S, Q, actual owned/opaque/total descriptor high-water, independent operation outcomes and latencies. Any search-caused independent failure fails acceptance; no shell-raised limit or controlled-only substitute. |
| Cancellation during a blocked call | One immutable TIME_LIMIT result when publishable; external cancellation may have no response. Late work changes no counters, choices, groups or coverage. Queued paths and all worker/descriptor reservations survive freeze until worker cleanup. | Block readdir, registration, component open and canonical inspection separately with multiple root streams and a nonempty FIFO. Freeze/cancel; release the call and verify worker-only exactly-once close/drop, no late I/O/publication, no stale descriptor use and full reservation release only after unwind. Independently reuse closed numbers to detect stray closes. Provider restart keeps the same pool/ledger. | Cancel actual delayed work while independent listener/store/actions continue; record actual owned and platform-internal occupancy before/after late return. Indefinite blocks retain slots/credits across provider restart; no replacement threads, extra queue or external idle-stream closes. |
| Current/queued parent moves into protected scope | A moved current parent stops its root with CHANGED_DURING_SEARCH REMAINDER; a changed queued target uses exact CHANGED_DURING_SEARCH SUBTREE and other tasks continue. With progress AVAILABLE survives; uncertainty uses INSPECTION_FAILED. No child open follows observed movement. | Move a current walk parent to each protected scope before the fresh canonical/policy check; separately replace a queued parent/target between enqueue and dequeue. Verify checked no-follow component walking, expected root/parent/target identities, both temporary credits and pre-open refusal. Inject a move after the final check to expose the residual race rather than asserting atomic safety. | Move ordinary current and queued subtrees into Documents/Desktop/Downloads/Library between turns; inspect actual canonical calls, no child open after observed movement and any dialog/hydration. Actual component rewalks and the remaining check-to-open window must be prompt-free; a prompting route fails and requires redesign. |
| Firmlink/case/Unicode canonical paths | Roots naming home and its Data-volume alias have the same resolvedPath and one file location with both observed rootIndices. App link/direct routes retain one canonical path/native identity, stable rank and false duplicate truncation. RequestedPath retains input spelling; synthetic policy targets use canonical-home components. | Supply differing preliminary realpath and descriptor-path spellings for one identity; require the single final canonical operation everywhere. Case/component/Unicode route variants cannot fabricate CHANGED_DURING_SEARCH in unchanged observations. Unknown/overlong canonical output has affecting coverage with no fallback. | On the startup APFS pair, use home and /System/Volumes/Data/Users/<user> roots plus /Applications and its Data alias. Create differently cased and NFC/NFD-named link spellings to one permitted bundle; observe actual filesystem identity/name behavior rather than assuming separate Unicode files. Inspect root/frame/bundle/policy path production and per-choice membership with no protected open or dialog. |

Home protected traversal remains a live baseline gap: any change to consent,
entitlements or setup needs Antony's decision before reliance. The already live
protected-default-open and app-reveal-notice decisions are not resolved here.
