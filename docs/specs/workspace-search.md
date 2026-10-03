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

**Discovery design requires repair before planning.** Its review found that
read-only Cryptex admission excludes the recorded Safari location, parent-keyed
frontier/depth diagnostics can still stop a realistic home scan, and exact-path
deduplication can return two routes to one installation. The
[open discovery obligations](#discovery-obligations-before-planning) require a
fresh design and load-bearing review. Counted intrinsic groups and independent
root budgets retain their observation contract. The
[coverage decision](../adr/search-coverage-describes-observations.md) explains
the public granularity trade-off. These are design obligations, not native
acceptance or Antony's acceptance of reduced workflow coverage. Prompt-risk
transport uses schema-level BLOCKED with null matches and no execution error;
its load-bearing review is pending. Preserve the outcome precedence below. Protected-home
acceptance must assess measured bound-driven omissions alongside protected
scope before the baseline closes. Arbitrary native-order samples are not accepted.

## Discovery obligations before planning

The following defects require a new producer design and load-bearing review,
not conditional implementation acceptance of the rules below:

- Replace read-only mount admission with a narrowly identified startup Cryptex
  application region. The retained [mount inventory](../verification/protected-path-metadata/environment.json)
  describes Preboot as local APFS without read-only; the retained
  [Safari witness](../verification/open-url-vm/results.json) resolves there.
  Neither accepting all local APFS nor silently dropping Safari
  meets the agreed application workflow.
- Settle traversal order and frontier/depth diagnostic aggregation together.
  Four-stream FIFO scheduling can accumulate 4,096 queued directories; each
  rejected parent then consumes the 96 KiB nonreserved coverage partition.
  Root summaries remove ordinary-directory/intrinsic diagnostic growth, but
  exceptional parent groups can still stop deeper discovery with
  DIAGNOSTIC_LIMIT. Weigh depth-bounded traversal and root-level aggregation,
  including retained state, reopened paths and visible omissions. Larger
  arbitrary cutoffs do not establish useful home coverage.
- Settle application deduplication by observed bundle identity, representative
  spelling, ranking and root membership. A checked link and a canonical-root
  path may identify one installation. Exact returned-path deduplication below
  does not merge those routes. Identifier equality alone does not merge actual
  separate copies. File choices retain their location semantics.

These open choices do not approve a smaller domain or native-order sampling.
The useful default Safari/Finder and measured home-coverage cases remain
mandatory; protected and bound-driven omissions still need the existing
operator decision. The admission, traversal and application path rules below
describe the unrepaired proposal, not a settled implementation contract.

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
including its extension. Application search compares both that filename and its
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
and native directory identities before descendant checks. A Cryptex anchor can
resolve into a system-managed Preboot location; admit descendants by the resolved
anchor, not a hard-coded canonical prefix or a guessed boot UUID. No arbitrary
Preboot/system root is thereby admitted. The anchor's canonicalization/classification
is a new acceptance obligation, not measured by the ordinary-root probe.
The latter may be a distinct local read-only system APFS mount: allow that known
presentation region only when public mount metadata establishes local, read-only
APFS without removable/network classification. An arbitrary read-only mount is
not a system-app region. Unknown classification blocks inspection. This new
admission contradicts the recorded read-write Preboot layout and must be
replaced before planning (see the open obligations below); a read-only test
alone cannot provide Safari reachability. File search gains neither region nor general
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
answers. Return the observed link spelling as `applicationPath` and filename
as `name`, so matching/reveal/copy describe the discovered location. The existing
constrained action selector resolves it again. Never inspect target children,
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
| `CHILD_GROUP` | Exactly `count` encountered child anchors of this representable parent are affected by this reason; identities are withheld. FRONTIER_LIMIT/DEPTH_LIMIT omit only eligible descendants: the anchor name can be examined and matched. UNREPRESENTABLE_NAME or overlong-path VALUE_LIMIT omit the anchor's inspection/matching and any descendants. Descendants are not counted. Never asserts that all children were skipped. |
| `DESCENDANT_GROUP` | Exactly `count` encountered intrinsic-exclusion anchors somewhere beneath this root have this reason; identities are withheld. Counts anchors, not descendant names; asserts neither a complete listing nor whole-subtree exclusion. |
| `REMAINDER` | Eligible work beneath this root unfinished at freeze: unread stream tails, queued/unopened directories and unfinished metadata. Excludes established observations without enumerating them; never asserts the whole root was skipped. Its size is unknown. |

`count` is positive only for the two GROUP extents, null otherwise. A group
contains an observed set, not every same-reason entry in an unread directory.
Group records require identical reason, guidance and `affectsCoverage`.
CHILD_GROUP carries only FRONTIER_LIMIT, DEPTH_LIMIT, UNREPRESENTABLE_NAME or
overlong-path VALUE_LIMIT, never permission: prompt risk needs an exact ENTRY/SUBTREE
target. Ordinary hidden, package, symlink-descendant and special-file anchors
coalesce into one DESCENDANT_GROUP per reason/root. A package or symlink anchor
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
independently; matches deduplicate the exact returned path, with all observed matching
root indices retained for each retained path. Unexamined overlapping roots do
not assert membership. No cross-request snapshot, cache or inventory is kept.

The two result types share these outcome semantics:

| `status` | `matches`, `dependency`, and execution error, absent publication denial |
| --- | --- |
| `AVAILABLE` | Non-null list, possibly empty; null dependency. At least one root made progress. Check every coverage object before describing an empty list as complete. |
| `BLOCKED` | Null matches and dependency, with no search execution error, including when matches is selected. No progress, no real native/work failure, and at least one prompt-risk scope; other roots may be absent/excluded. Coverage records each cause. This is a blocked policy outcome, never consent-absence inference or healthy empty. |
| `DEPENDENCY_UNAVAILABLE` | Null matches; dependency `NO_SEARCHABLE_ROOT` with guidance. Every root is missing, not a directory, or excluded/unsupported by the declared domain; no execution error at matches. Coverage gives the exact per-root reasons. |
| `FAILED` | Null matches and dependency; `matches` raises `failed`. No progress and at least one actual native failure, timeout/capacity refusal or unrepresentable root. Prompt risk mixed solely with absence/exclusion is not a native failure. |

If any root made progress, `AVAILABLE` takes precedence and successful matches
coexist with explicit partial/unknown diagnostics. With no progress, FAILED
takes precedence for a real native/work failure, then BLOCKED for any prompt-risk
scope, then DEPENDENCY_UNAVAILABLE for purely absent/excluded roots. For example,
`[Desktop, missing]` and `[Desktop, unsupported-volume]` are BLOCKED;
`[Desktop, access-denied]` is FAILED. A non-TCC access denial has
`ACCESS_DENIED` and no permission object; do not infer a consent from errno or
Cocoa 257 alone. Other unexpected failures are `INSPECTION_FAILED`. In a
blocked result a client may highlight the first prompt-risk root in input order;
coverage retains every cause and target and is the only diagnostic payload.
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

Absent authorization, input, deadline/response-limit or publication errors, every
BLOCKED response object has status BLOCKED, matches null when selected,
dependency null when selected, resultsTruncated false, and one UNKNOWN coverage
object per effective root, except a positively absent optional default retains
its COMPLETE empty-domain state. All roots have zero examinedEntries/completedDirectories
and no searched scopes; at least one skipped scope has PROMPT_RISK with its
permission object, and every root records its own blocking/absence/exclusion
cause. There are no observed matches to truncate. No search resolver returns a
missing-consent failure or synthesizes an error for this branch. Omitting matches
does not change status, coverage or whether an inspection was attempted.

Repeated matches aliases within one root read the same frozen result: BLOCKED
returns null at each alias with no errors; FAILED emits a failed error at each
selected alias, retaining its original response path and nullable-field coverage.
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
additive release, retaining the catalogue identity,
composition position and existing required features. A release number never
substitutes for introspection or a conformance profile.

## Matches, ordering and bounds

Application matches carry an absolute canonical-root-based `applicationPath`,
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
Under the provisional exact-path rule, separate returned paths remain separate
choices; the same identifier does not establish either one installation or
separate installations. The application-identity obligation above must settle
checked-link/canonical duplicates before planning.
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

Rank finalized returnable matching locations by exact folded comparison key, folded prefix,
then folded substring. Applications use the better filename/stem tier, so `zed`
ranks `Zed.app` before `Zed Preview.app`; files use the filename only. Ties use
folded full name in Unicode scalar order, raw name in that order, then raw
absolute path in UTF-8 byte order. Retain the best `limit` returnable locations
by that tuple. Each match has a
fixed reserved slot, so larger metadata cannot evict a better-ranked match in
favor of cheaper lower-ranked ones. Paths exceeding the explicit path bound
are omitted with affecting VALUE_LIMIT coverage, never shortened.
`resultsTruncated` is true exactly
when at least one observed matching location is absent from the final list for
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
| Directory frontier | At most 4 open directory streams plus 4,096 pending directory tasks and 2 MiB charged task/stream bookkeeping per root |
| Result wrappers | 8 KiB per job for aggregate/dependency objects, bounded guidance and outer list slots |
| Scratch | One candidate and component walk at a time; at most two temporary descriptors; individual returned/scratch paths at most 8,192 UTF-8 bytes; names/optional metadata/guidance at most 1,024/1,024/256 bytes |
| Wait | Three seconds from admission, shared by all roots; no hard native-call deadline |

Charge retained strings by their UTF-8 bytes **at each value occurrence**, plus
256 bytes per object and 16 bytes per scalar/list slot. Count wrappers and
nullable/list slots; null has its slot cost and no string bytes. Charge against the owning reserved partition before
insertion/replacement; do not rely on deduplication or an allocator's capacity.
Counters use bounded integers. These are accounting units, not Swift object
sizes or a wire/RSS bound. JSON escaping, GraphQL aliases and the core's separate
8 MiB response materialization ceiling can still cause a whole-response error.

After validating all inputs, reserve twelve coverage record slots and 160 KiB
of each root's partition before filesystem work. This holds the root object,
requested/resolved paths (within their limits), one searched summary, four
intrinsic groups, four exact home policy scopes with permission targets and
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
Exceptional parent groups still grow with encountered parents and can exhaust
diagnostics; their interaction with traversal is an open obligation above.

The scheduling unit is at most 64 entries of one directory, including its
classification and any candidate metadata. Visit admitted unfinished roots
cyclically in input order, one unit each; admission/root metadata is one turn
per root before its first listing turn. Within a root rotate up to four live
streams, one unit each, with FIFO pending directory tasks in observed insertion
order. A free stream slot opens the oldest pending task at the next turn.
Do not recurse synchronously into a newly found child. Roots and directories
that reach EOF are removed; each later root keeps its own entry/coverage/frontier
credits. This schedule is deterministic for fixed native observations, not a
claim that `readdir` order is stable. A large first directory cannot spend the
other roots' credits, and responsive streams rotate rather than one DFS branch
owning the entire job. A blocked native call or shared deadline can still
prevent later turns; no per-root time/progress guarantee is made.

A newly encountered directory is queued only within the frontier count/byte
budget. Otherwise record FRONTIER_LIMIT as CHILD_GROUP at its parent, affecting
coverage, and keep scanning names/other tasks. Do not silently evict an earlier
task or retain an unbounded directory array. Depth refusal similarly uses
DEPTH_LIMIT at the parent; each group counts directory anchors whose descendants
were omitted, not omitted anchor names. Those names remain eligible matches. Pending
tasks store bounded paths, fixed-width inspected device/inode identity and
bounded classification flags, not opaque expanding metadata or live descriptors.
Reopen via checked no-follow component walks and revalidate policy/identity;
a rename/replacement is CHANGED_DURING_SEARCH, never a new target or retry.
Stopping for ENTRY_LIMIT does not read another entry to guess EOF; a root at
that ceiling can remain PARTIAL even if the last consumed entry was physically
last. Other roots continue. Intrinsic domain exclusions do not consume frontier
slots. Relative-depth limits count queued child depth, not scheduling rounds.

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
the separate value-truncation case. Each finalized candidate's metadata is
immutable while retained. Consider at
most the retained list plus one scratch candidate, sort and keep the best
`limit` distinct returned paths. Merge a repeated retained path's ascending
rootIndices; keep its first retained metadata, reporting observed identity
change separately. A path that exceeds the return/scratch limit cannot be
fabricated: record VALUE_LIMIT as CHILD_GROUP at its representable parent and
omit it/its descendants, with resultsTruncated true if its name is a known
match. If even that parent record cannot fit, the reserved root REMAINDER stops
work. Other roots/tasks continue. Count-based eviction never stops scanning or
weakens diagnostics. A .app-link inspection consumes the current entry's turn
and remaining wait; no unbounded registration-discovery queue is created.

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

### Capacity examples and acceptance threshold

These constructed layouts assess the accounting contract, **not native
measurements or latency predictions**. Ordinary-directory counts do not each
consume a searched record. All counts are fixture inputs; runtime acceptance
must report each actual root's examinedEntries/completedDirectories, reasons,
latency and resultsTruncated, and compare individual known names, not totals.

| Layout / query | Expected contract outcome when work completes before the deadline |
| --- | --- |
| Application root: 32 branches × 96 leaf directories × 3 ordinary files, plus 150 app bundles and 75 hidden entries; query a known app | 12,545 entries, 3,105 EOF listings, at most 3,072 pending leaf tasks (under 4,096), COMPLETE eligible domain with one SUBTREE searched record and two intrinsic groups, plus the known installed/unregistered match. App/package contents add no frontier tasks. Long paths must separately fit the 2 MiB frontier account. |
| Home: Development with 32 projects × 96 ordinary leaf directories, each with 3 files and one hidden entry; five home anchors including four protected policy names | 15,397 entries, 3,106 EOF listings; one OBSERVED_DESCENDANTS summary, explicit four protected scopes and one hidden-anchor group. In this constructed layout under the frontier/byte ceilings, PARTIAL is due to policy, not DIAGNOSTIC_LIMIT. Known ordinary filenames at different branches/depths are found. This says nothing about a wider/deeper real home; its domain still needs Antony's decision. |
| First application root has 100,001 nonmatching entries; later defaults contain the required real apps | First root PARTIAL/ENTRY_LIMIT; each responsive later root gets turns/its own credits and returns its app matches. Entry exhaustion alone cannot mark later roots unscheduled. The shared time/native-stall limit can, and must show TIME_LIMIT/REMAINDER there. |
| One directory has 5,000 ordinary child directories | Names can all be examined but some child anchors exceed the frontier; PARTIAL/FRONTIER_LIMIT CHILD_GROUP at that directory with the exact rejected count. If other streams finish tasks during enqueue, count follows that deterministic observed schedule, not a claimed fixed 904. |
| Complete directory has 250 matching ordinary files; limit 50 | COMPLETE/SUBTREE, best 50 returnable paths, resultsTruncated true. A partial scan with no omitted observed match can instead have resultsTruncated false. |

Short ASCII fixture paths keep both wide examples below frontier/coverage byte
bounds; use a long-path variant that exceeds those bounds as a separate refusal
case. Fixed reservations are intentionally larger than these fixture outputs.
Neither the examples nor increased entry budgets prove that a real home or
application installation fits three seconds. Acceptance must also run realistic
mixed trees with project dependencies, many packages/hidden entries, and a large
single directory, plus the installed real applications in **all five defaults**.
Record exact omissions and known filenames at shallow/deep/later-root positions.
If ordinary default coverage is still an arbitrary slice at the deadline or
frontier, it is pending work to revisit here or a concrete trade-off for the
existing protected-home decision; it is never a passing baseline case. Do not
move that decision ahead of implementation merely to assume these measurements.
If a proposed reduced domain must be accepted before implementation can proceed,
reorder that existing decision ahead of the dependence instead.

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
Per job, sixteen roots times four live streams permit at most 64 stream
descriptors plus two temporary component-walk descriptors; pending tasks hold
none. The accumulator, root coverage partitions (at most 4 MiB), match slots
(at most 3.125 MiB) and frontier partitions (at most 32 MiB) belong to that admitted job,
even if its response wait ends. Four admitted jobs can retain those accounts
until native cleanup, without replacement slots after provider restart. These
accounts total about 39 MiB per job and 157 MiB for four retained
jobs, plus bounded scratch; blocked calls can retain all four. They are explicit
ceilings on charged structures, not allocated memory or a hard RSS guarantee. No
Foundation `contentsOfDirectory` or `scandir` sorting array or complete-directory
materialization is used for traversal.

Canonical-root inspection is metadata only. Open admitted directories using
public descriptor-relative operations with no-follow/directory flags; verify
file identity against the classified directory and recheck policy/volume on the
opened descriptor before converting it to a stream. Descendant opens use a
held parent descriptor and a single child name, or a fresh checked
no-follow component walk for queued tasks, never unchecked symlink parents.
Root component walks do the same. Detect/reject
identity changes or new links as `CHANGED_DURING_SEARCH`; do not follow them or
retry a replacement. Mount/classification uncertainty blocks descent. Bundle
and type metadata remain path-based public calls with pre/post identity checks;
they establish no atomic binding. Symlink races, rename of a held directory,
mount changes and platform metadata behavior remain limits. Observed change
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
| Isolated TestAnyware macOS VMs | Actual signed hardened Koine and the new stream adapter, with no new keys/entitlements: applications in default/nested/user roots, duplicate installed copies, missing identifier/unregistered/unreadable candidates; ordinary and empty directories, home partial, every directly supplied protected root and symlink/component alias, Library and known cloud exclusions; missing/mode-denied roots, index disabled with identical ordinary behavior. Large single directory exceeding entry limit, scope/value/depth bounds, cancellation while listing/registration blocks, late completion and worker-capacity recovery, symlink replacement/mount change. Verify no consent dialog or file-content/hydration request from search and inspect all actual calls. Install the required real apps; demonstrate constrained launch, reveal, default ordinary-document open, Zed open and client-owned clipboard/MRU with visible witnesses. Real removable/network/cloud cases stay excluded or pending, never substituted with the ordinary disk-image fixture. Record actual OS/app versions, latency and limits. |

### Compatibility subjects and diagnostic acceptance

Use independently retained binaries, not two rebuilds after a search edit. The
named workspace-actions-1.0-compatibility host is a retained selection-aware
framework-1.1 host bundling workspace provider/schema 1.0.0 and desktop 1.0.0.
Its exact profile is
[core-desktop-workspace-extension-host](../design/profiles/core-desktop-workspace-extension-host.json),
against the unchanged
[action-only composed SDL](../design/desktop-workspace-schema-extension-host.graphql).
Retain its host/framework/provider binaries, source revision and digests before
upgrading search. Existing selection-update purpose-built hosts/profiles remain
their own pinned subjects; a fixture workspace 1.1.0 with schema 1.0.0 is not the
search release merely because its release number matches.

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

| Independently built pair / case | Required observation, pending implementation |
| --- | --- |
| Retained workspace 1.0.0 on workspace-actions-1.0-upgraded-core | All four actions and old named-consent/nil/blank failure mapping remain unchanged; run the unchanged exact action-only profile with that retained provider and catalogue baseline, and retain its binary identity. |
| New search 1.1.0 provider on retained selection-aware framework-1.1 host | Loads under its existing minimum minor/features; additive SDL and BLOCKED success/null values work without a diagnostic feature. Use the search-required exact profile with candidate rows appropriate to the selected new bundle, not action-only bundled pins. No new shared-framework symbol is imported. |
| New search provider on released Koine 0.1.0/framework 1.0 | Existing additional-capabilities-v1 / first-party-selection-v1 requirements cause pre-load refusal with no initializer marker; this is existing incompatibility, not a new prompt-risk feature. |
| Both roots, each wholly protected; coverage-only and two matches aliases | BLOCKED, null matches/dependency, false resultsTruncated, no search execution errors. Coverage retains targets, PROMPT_RISK, null osPermission and UNKNOWN consent. No nested selection schedules native reads. Include optional-absent default plus prompt risk: absent optional coverage remains COMPLETE, not UNKNOWN. |
| Prompt risk + missing/unsupported; prompt risk + actual denied/native/work failure; pure absent/excluded | Respectively BLOCKED without errors, FAILED with failed at each selected matches alias, and DEPENDENCY_UNAVAILABLE without matches errors. Coverage-only FAILED still publishes status/coverage without a selected matches error. |
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
| Default Safari/Finder and controlled alternate layouts | Omitted/null roots expose all five defaults in order; Safari/Finder have observed paths, nonblank identifiers, INSTALLED after established registration; both feed constrained launch. A positively absent Cryptex optional root is COMPLETE/OPTIONAL_ROOT_ABSENT; explicit absence is UNKNOWN/ROOT_NOT_FOUND. | Controlled adapter supplies alternate canonical anchors, absent optional region and real distinct copies versus two routes to one bundle, under the repaired identity/admission design. Exact search SDL and unchanged action-only compatibility subjects remain required. | Required real apps installed; actual Safari and Finder paths are found under default search without dialogs/launch, after the open admission/identity obligations are repaired. Known paths/identifiers and actions have independent witnesses. Test another layout when a concrete supported VM subject exists; otherwise record that condition as not applicable with OS/layout evidence, without claiming native proof of alternate layouts. Actual default/call cases remain mandatory and pending. |
| Application links/aliases | Under the repaired representative-spelling rule, registered .app targets yield INSTALLED and unregistered targets yield UNREGISTERED; denied/protected/dangling or changed targets cannot yield COMPLETE empty. Alias files/non-app symlinks never become launchable apps. File-search symlinks remain UNKNOWN without target inspection. | Controlled adapter supplies matching/mismatched native identities and both registration answers. Path and identifier handoff remains unchanged. | Inspect actual target/link metadata, resolution order and mount checks. Include links to Desktop/Documents/Downloads and a named protected Library sub-area (Mail data), with component aliases. No protected traversal, alias-file resolution, default-handler lookup, registration writes or content/hydration request. Resolution itself must be prompt-free under actual signed Koine; earlier metadata evidence does not establish it. Cryptex admission/races use the actual adapter; no new keys/entitlements. |
| Wide realistic layouts / later-root scheduling | The above known names/states/counts hold for completed work. The repaired traversal/aggregation must avoid a parent-diagnostic cutoff determining a native-order sample. Later roots have independent budgets; real timeout/remainder never claims they were searched. | Real bundle with controlled responsive streams verifies the repaired schedule/frontier/diagnostic rules and all byte ceilings, including more rejecting parents than fit the current 96 KiB partition and a deep name witness. Exact search-required profile detects missing fields; action-only pins unchanged. | Run constructed layouts, realistic wide/deep home trees and large first/single directories in the actual host; record per-root coverage/latency and shallow/deep/later-root name witnesses. Failure to reach required names is pending acceptance, never a conditional pass from local counts. Bound-driven omissions go to the existing human decision. |
| Exact scope groups / exhaustion | Two malformed adapter names with valid siblings have CHILD_GROUP count 2, not SUBTREE. FRONTIER_LIMIT/DEPTH_LIMIT names remain matchable while descendants are omitted; VALUE_LIMIT/UNREPRESENTABLE_NAME anchors are omitted too. Stop produces REMAINDER/null count with or without progress, resolved/requested anchor as specified; only progress adds a searched record. DIAGNOSTIC_LIMIT identifies total diagnostic room, VALUE_LIMIT an individual path. Match truncation is independent. | Controlled entries/EOF verify those reason/extent pairs, no-progress timeout/capacity/overlong-root stops, group keys/count nullability, four reserved policy targets, per-occurrence charging and all sixteen rootIndices. Record-count and byte exhaustion both use DIAGNOSTIC_LIMIT with distinct fixed guidance. Include malformed resolved roots, deep/wide layouts and every bound. Earlier records survive; matches cannot consume diagnostic reservation. | Use valid admitted APFS names, packages/hidden entries, long paths, actual frontier/depth/diagnostic exhaustion and cancellation, without replacement paths. Inspect actual native names/calls. Malformed-byte cases are controlled-adapter obligations, not an unconditional native VM fixture; unsupported volumes are not substitutes. |

Home protected traversal remains a live baseline gap: any change to consent,
entitlements or setup needs Antony's decision before reliance. The already live
protected-default-open and app-reveal-notice decisions are not resolved here.
