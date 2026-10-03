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
remain binding. No released or currently served search behavior is claimed.

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
accepts incomplete home coverage and bounded, potentially slow native calls.
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

The query is a literal substring of the final filename, including its extension,
not a path, bundle identifier, localized name, content, glob, regex or fuzzy
expression. It is at most 256 UTF-8 bytes and contains no NUL. Empty matches all
eligible names; whitespace is literal and is not trimmed. Match using Unicode
case/diacritic-insensitive comparison with a fixed POSIX locale, independent of
the user's language. Canonically equivalent spelling may match, but output
names/paths retain their original Unicode. This comparison does not establish
filesystem identity. No query causes an application or document to open.

### Roots and search domain

Application defaults are `/Applications`, `/System/Applications` and the Koine
user's home `Applications` directory, in that order. The first two are the
measured roots; the home default and recursive inspection still need acceptance.
File default is **Koine's actual home directory**, never the client's home or
the provider's current directory. `requestedPath` exposes each effective default.
No client configuration is read. A missing optional home Applications directory
is reported, not dropped. Supplying roots replaces the defaults.

The first implementation admits ordinary directories on the local startup
system/data APFS volumes within Koine's home, `/Applications`,
`/System/Applications`, and the system's local temporary directory. It does
not admit `/` as a broad traversal root, another user's home, or arbitrary
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
are outside the search domain. Report their encountered exclusions; a hidden
or package root explicitly supplied is likewise excluded. Files include ordinary
files, directories, packages, application bundles, aliases and symbolic-link
entries as selectable **locations**; special devices/sockets are excluded.
An application search yields application-bundle candidates, never package
contents. Nested ordinary folders are traversed. Filename search includes the
name of a package or symlink, even though its descendants are excluded; hidden
entries themselves are not matches. A root's own name is not a match.

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
entry count, searched scopes and skipped scopes. Scope paths are absolute;
`DIRECT_CHILDREN` means a complete listing, `PARTIAL_CHILDREN` an interrupted
listing, and `SUBTREE` is used for a wholly skipped remainder. Searched scopes
never claim a complete subtree while hiding its skipped descendants.

| Root state | Meaning |
| --- | --- |
| `COMPLETE` | Every eligible name in this root's declared domain was examined, no relevant name/classification was unknown, and all listings reached EOF. It is neither an atomic snapshot nor the full filesystem tree. Intrinsic hidden/package/symlink-descendant exclusions are still reported. |
| `PARTIAL` | Some scope was examined, but policy, a work bound, failed inspection/listing or missing required application metadata omitted eligible scope/candidates. Home is necessarily partial under this policy. |
| `UNKNOWN` | No eligible scope was examined or its completeness cannot be established; reason/path still state what blocked or stopped it. An unscheduled root is never complete. |

Each skipped scope has a closed reason, human guidance and `affectsCoverage`.
Only intrinsic domain exclusions (`HIDDEN`, `PACKAGE_CONTENTS`,
`SYMLINK_DESCENDANTS`, `SPECIAL_FILE`) have false; every other reason is true.
Coverage precedence is UNKNOWN when no progress was made, otherwise PARTIAL
when any true reason exists, otherwise COMPLETE. Successfully obtaining one
entry or observing EOF in an empty directory is progress. Missing metadata for
a matched candidate contributes `INSPECTION_FAILED`, even when a location can
still be returned with unknown fields. Duplicate/overlapping roots are examined
independently; matches deduplicate the exact returned path, with all matching
root indices retained. No cross-request snapshot, cache or inventory is kept.

The two result types share these outcome semantics:

| `status` | `matches`, `dependency`, and execution error, absent publication denial |
| --- | --- |
| `AVAILABLE` | Non-null list, possibly empty; null dependency. At least one root made progress. Check every coverage object before describing an empty list as complete. |
| `BLOCKED` | Null matches and dependency; `matches` raises `permission` / `os-permission` when every effective root was stopped solely by known protected-traversal prompt risk. Coverage survives. No consent-absence inference. |
| `DEPENDENCY_UNAVAILABLE` | Null matches; dependency `NO_SEARCHABLE_ROOT` with guidance. Every root is missing, not a directory, or excluded/unsupported by the declared domain; no execution error at matches. Coverage gives the exact per-root reasons. |
| `FAILED` | Null matches and dependency; `matches` raises `failed`. No progress and at least one native failure, timeout/capacity refusal, unrepresentable root, or a mixture of prompt risk with other blocked/failing roots. |

If any root made progress, `AVAILABLE` takes precedence and successful matches
coexist with explicit partial/unknown diagnostics. A non-TCC access denial has
`ACCESS_DENIED` and no permission object; do not infer a consent from errno or
Cocoa 257 alone. Other unexpected failures are `INSPECTION_FAILED`. In an
all-blocked result the error's target is the first root in input order;
coverage retains every target. These are **new search result** rules, not changes
to desktop null/absence behavior. A null search root always has an input,
capability or execution error. Status/coverage/matches are read fields: revocation
may suppress any selected branch through standard non-null propagation. A
published status never overrides errors. An error-free result must satisfy the
table's branch invariant; clients report malformed combinations as failure.
The BLOCKED/FAILED error is raised when `matches` is selected; a status-and-coverage
query can inspect diagnostics without selecting that failing field. It still
carries no successful list. The matches resolver derives its refusal from
status and coverage without another native inspection or an arbitrary GraphQL
error hidden inside provider values.

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

The all-blocked GraphQL error retains `kind: permission`,
`permissionClass: os-permission`, `permissionOwner: koine`, adds
`permissionReason: prompt-risk` and `permissionTarget`, and **omits**
`osPermission` and capability `phase`/`requiredCapability`. It has the selected
`matches` response path, including an alias. Coverage has the same guidance.
Existing clients of new operations must tolerate an absent consent identifier;
they show the message/scope and preserve the permission classification.

This needs a compatible framework **major 1, minor 2** design addition, required
feature `scoped-permission-diagnostics-v1`: optional String accessors
`ProviderFailure.permissionTarget` and `permissionReason`, default nil, with
the existing `osPermission` case. The combination nil `permission`, nonblank
target and reason `prompt-risk` represents this scoped refusal only when the
descriptor/manifest require the feature. The host validates that combination,
maps it without a consent identifier, and rejects malformed/undeclared scoped
failures as `failed` with a provider diagnostic. It must not pass nil through
the current missing-consent string fallback. Ordinary named-consent failures,
all old provider registrations and desktop outputs keep their existing mapping.
This adds no enum case, consent, entitlement, usage key or consent-acquisition
flow, and keeps `koine-desktop/1`. A host lacking minor 2/the feature refuses the
new workspace update before load. Existing workspace actions retain their SDL,
authority and failure behavior. Planning owns this vertical framework dependency
and its independent old/new binary checks; it is not implemented by this spec.
Register the new search output types as read fields separately from the existing
control-only action types; the workspace provider's current all-control helper
is not the authority for search. Publish an additive workspace schema minor and
an independently compatible provider release, retaining the catalogue identity,
composition position and existing required features. A release number never
substitutes for introspection or a conformance profile.

## Matches, ordering and bounds

Application matches carry an absolute canonical-root-based `applicationPath`,
filename `name`, nullable bundle identifier and `installationState`.
`INSTALLED` means an application bundle with a known nonblank identifier and
that exact native file identity present in public registration inspection.
`UNKNOWN` means application metadata/registration could not be established;
never silently replace it with another installation. Positively unregistered
bundles are not installed-app matches. A bundle without an identifier may appear
as UNKNOWN with a null identifier for reveal/path-copy, and cannot form a launch
selector. Report missing/failed application metadata as partial coverage, not
proof of absence. Inspect both public per-identifier registration answers as
the existing constrained selector does; registrations alone do not prove presence.
Separate paths with the same bundle identifier remain separate installations.
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

Retain the best `limit` matches among names actually examined: exact folded
name, folded prefix, then folded substring; ties by folded name in Unicode scalar
order, raw name in that order, then raw absolute path in UTF-8 byte order. Sort
the retained list by that same tuple. No score, MRU or native directory order is
promised to a client. `resultsTruncated` means at least one matching location
was omitted by the result-count/value budget. It is separate from coverage:
complete traversal can still return a truncated top list. Native traversal order
can affect the subset at a work bound; repeated partial scans have no stable
global top-N guarantee. No continuation cursor or pagination snapshot exists.

Per root field: sixteen roots, 200 matches, 20,000 total examined entries,
maximum depth 32, 512 combined searched/skipped records, and 512 KiB of retained
UTF-8 value payload (strings plus 256 bytes per object and 16 bytes per scalar/list
slot charged before insertion).
The byte bound includes paths, match metadata, guidance and diagnostics, not
just the matches. Reserve one fallback diagnostic and input-root record per
root before work; oversized optional metadata stays null and adds an inspection
diagnostic. Coalesce repeated reasons in one directory where their scope is
the same. Stop before a required scope/value record would exceed its budget,
mark the active listing partial and the unvisited remainder/roots with
`DIAGNOSTIC_LIMIT` or `VALUE_LIMIT`; never discard diagnostic scope silently.
Depth limits use `DEPTH_LIMIT`; entry limits use `ENTRY_LIMIT`.

The enumeration wait ends after three seconds or earlier provider cancellation.
A timer freezes a value snapshot once: publish available partial results with
`TIME_LIMIT` if progress exists, otherwise FAILED with coverage and a matches
error. The core's five-second request ceiling may answer first with its existing
whole-response error and no promised partial data. External cancellation may
leave no response. No new I/O is scheduled after cancellation/expiry, late
native results cannot mutate the frozen value, and no retry occurs. Cancellation
cleanup never waits for a blocked syscall. A native call already admitted can
finish later; transport loss is not evidence that it was stopped.

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
unbounded queue. An admitted job remains counted until its native work and
descriptor cleanup finish, even after its wait expires. Capacity refusal returns
FAILED with UNKNOWN coverage and `CAPACITY_LIMIT`, before filesystem work.
Provider stop cancels jobs without waiting for blocked native calls; workers
retain neither credentials nor resolvers. Per-job DFS holds at most 33 directory
streams plus at most two temporary directory descriptors for component walks
and checked descent, not a queue of every child path. Component walks retain
only the current and next descriptor, within the input-path and wait bounds.
Each entry is consumed/classified once before reading the next. No Foundation
`contentsOfDirectory` array, `scandir` sorting array or complete-directory
materialization is used for traversal.

Canonical-root inspection is metadata only. Open admitted directories using
public descriptor-relative operations with no-follow/directory flags; verify
file identity against the classified directory and recheck policy/volume on the
opened descriptor before converting it to a stream. Descendant opens use the
held parent descriptor and a single child name, never a path rebuilt through
unchecked symlink parents. Root component walks do the same. Detect/reject
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
at its representable parent scope, affecting coverage; an unrepresentable
resolved root fails inspection rather than becoming a fabricated path.

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
| Public GraphQL | Both roots and every nested field under workspace read alone; neither control nor desktop read substitutes. Input defaults/null/empty/limits, Unicode/literal matching and rank ties; complete empty versus partial empty, UNKNOWN coverage, duplicate/overlapping roots, top-list truncation independent of coverage. All-blocked retains coverage and error at aliased matches; all absent/unsupported has a dependency branch; unclassified denials/timeouts fail; mixed success preserves failed/blocked scope. Revocation and non-null publication paths; absent search provider/schema detection. A reading-restricted standalone client derives choices and every permitted action using only SDL/spec/introspection. |
| Native binary interface | Extend the actual workspace bundle, not a second namespace; independently built old provider/new minor-2 host, new search provider/old host refusal before load, manifest/descriptor feature agreement and malformed scoped failure refusal. Preserve existing named-consent/desktop errors and all four action contributions exactly. Conformance adds a search-required profile while retaining action-only, desktop-only, absent/rejected and exact-candidate profiles; do not edit action-only expected SDL to claim unserved search. |
| Isolated TestAnyware macOS VMs | Actual signed hardened Koine and the new stream adapter, with no new keys/entitlements: applications in default/nested/user roots, duplicate installed copies, missing identifier/unregistered/unreadable candidates; ordinary and empty directories, home partial, every directly supplied protected root and symlink/component alias, Library and known cloud exclusions; missing/mode-denied roots, index disabled with identical ordinary behavior. Large single directory exceeding entry limit, scope/value/depth bounds, cancellation while listing/registration blocks, late completion and worker-capacity recovery, symlink replacement/mount change. Verify no consent dialog or file-content/hydration request from search and inspect all actual calls. Install the required real apps; demonstrate constrained launch, reveal, default ordinary-document open, Zed open and client-owned clipboard/MRU with visible witnesses. Real removable/network/cloud cases stay excluded or pending, never substituted with the ordinary disk-image fixture. Record actual OS/app versions, latency and limits. |

Supporting private-adapter tests control EOF, ordering, denied metadata, blocked
workers, deadlines and changed identity. They prove mapping and bounds, not
native consent behavior. No numeric interactive-latency target is invented.
Home protected traversal remains a live baseline gap: any change to consent,
entitlements or setup needs Antony's decision before reliance. The already live
protected-default-open and app-reveal-notice decisions are not resolved here.
