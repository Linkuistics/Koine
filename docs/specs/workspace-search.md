# Application and file search

**Designed, pending implementation and acceptance.** Workspace supplies bounded
name discovery for the agreed [application and file workflows](../requirements/modaliser-workflows.md#workflow-inventory).
The [scope and coverage view](../design/architecture/index.html#diagram-search-coverage)
and [selection handoff](../design/architecture/index.html#diagram-search-handoff)
are the reading entry; the
[canonical observation view](../design/architecture/index.html#diagram-search-canonical)
shows the current native path proposal, and the
[resource boundary comparison](../design/architecture/index.html#diagram-search-resources)
shows the finalized in-process allocation and the remaining construction/review handoff. The [search SDL](../design/workspace-search-schema.graphql)
and [client examples](../design/workspace-search-operations.graphql) define an
additive workspace contribution. They compose with the existing
[launch/open contract](workspace-launch-and-open.md), not a second provider.
The [effect-authority decision](../adr/provider-authority-follows-effects.md)
and [first-party selection decision](../adr/first-party-provider-selection.md)
remain binding. The [prompt-risk decision](../adr/prompt-risk-is-search-data.md)
keeps policy blocking in typed search data. No released or currently served
search behavior is claimed.

**Canonical paths and native allocation are designed; their reviews precede planning.**
Narrow fixed-region Preboot admission permits its measured read-write layout.
Per-root FIFO breadth-first work finishes shallower admitted listings before
deeper ones, preserving later home-root names against an early enormous branch.
The bounded queue reports omitted descent in one reserved root frontier group;
anchor names remain matchable. A process-wide descriptor account reserves job
credits atomically below the inherited soft limit, leaving a non-search reserve.
Normally launched host serviceability remains an acceptance obligation during
platform-native inspection. The selected evidence boundary leaves opaque
internal acquisitions and peaks unproved. The
[canonical directory observation](#canonical-directory-observation) chooses
public fsgetpath with descriptor-derived identity and grouped size refusals;
its load-bearing review is required. The in-process allocation below selects
metadata/resource calls and the observable instrument contract; serviceability
subjects and the complete-resource review remain required. Each
producer requires its own load-bearing review before planning. Current streams
are revalidated before every listing turn; changed queued prefixes stop their
root once. FIFO also repeats component walks against the wait budget. One reserved depth group retains anchor-count
semantics. Applications use
canonical target names/paths and native bundle identity for one choice per
observed installation. The
[discovery obligations](#discovery-obligations-before-planning) remain mandatory
acceptance subjects. Counted groups and independent root budgets retain their observation contract. The
[coverage decision](../adr/search-coverage-describes-observations.md) explains
the public granularity trade-off; the separate
[traversal decision](../adr/search-traversal-preserves-shallow-names.md) owns
ordering/frontier/repeated-walk costs. These are design obligations, not native
acceptance or Antony's acceptance of reduced workflow coverage. Prompt-risk
transport has its reviewed schema-level BLOCKED contract with null matches and
no search-generated execution error, subject to field/lifecycle/publication errors.
The compatibility subjects below require distinct retained and search-release
checks before acceptance. Preserve the outcome precedence below. Protected-home
acceptance must assess measured bound-driven omissions alongside protected
scope before the baseline closes. Arbitrary native-order samples are not accepted.

The [resource feasibility analysis](../verification/search-native-resources.md)
separates a public CFError-bearing registration candidate from hidden-allocation
bounds and signed-host event visibility. It selects no runtime mechanism. The
resource producer is decomposed into feasibility, allocation and constructible
serviceability-subject design; its complete artifact still requires review.
The [allocation decision](#native-allocation-decision) records the operator's
refusal of helper design and retains the single-process posture. The need for
isolation has not been established. Antony subsequently instructed "you decide";
under that delegation, the requirements session independently selected the
native-result meaning and empirical serviceability-evidence boundary in the
[observation contract](#in-process-observation-contract). Registration
and other native facts are reported observations, with disclosed possible
undetected incorrect results; controlled outcomes and complete owned/hook events
leave opaque internal demand unproved. These selections change only those two
guarantees and do not follow from the helper refusal. The final in-process
allocation contract below is settled; serviceability instrument/subject construction
and mandatory review remain live.
The owned-credit formula, two temporary credits, limits, domain, authority,
consent, compatibility and all other native acceptance obligations remain binding.

## Discovery obligations before planning

The admission, identity and breadth-first/resource contracts require the canonical
observation review and native resource design/review before implementation
planning. Shallow-name order is per root, not a
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
make the chosen trade-off testable. FIFO preserves depth-2 project anchors but
can omit later depth-3 project contents; a separate enormous depth-2 listing
also cuts later same-level names and subsequent depth-2 listings short. Repeated
checked component walks can exhaust the wait independently of entry work.
The subjects below name these losses; none is accepted coverage. This informs constructible subjects, not
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

Use the same [canonical directory observation](#canonical-directory-observation)
for admitted region/mount witnesses, resolved roots, current streams, queued
targets, application bundles and opened policy witnesses. Preliminary
component/link resolution supplies a candidate for policy checks, not a public
canonical spelling. Never mix realpath's Data-volume spelling with the chosen
canonical presentation.
Build an ordinary file-entry location from its canonical parent and the lossless
observed entry name; do not resolve a final symlink/alias or Unicode-fold its path.
Firmlink aliases to one root therefore yield equal returned file paths and merge
observed rootIndices under exact-path deduplication. Synthetic protected/cloud
targets use components beneath the canonical home witness without opening
excluded directories merely to canonicalize them; known supplied aliases still
undergo the earlier spelling/identity policy checks. Unknown paths and known
native-size refusals retain the INSPECTION_FAILED/VALUE_LIMIT distinction below.
Signed-host firmlink, case and Unicode witnesses
must establish this route's behavior and prompt-free calls before acceptance.

### Canonical directory observation

One private adapter operation accepts an already owned, no-follow-opened
directory descriptor and its inspection context: admission witness, root,
current stream, walk prefix or target beneath an established parent. It returns
either a lossless observed path with native directory/mount identity, a known
native-size refusal, an observed change, or inspection failure with the captured
native error. Callers apply the scope rules below; they never select another
path spelling or reconstruct a successful canonical directory from input text.
The operation hides native buffers and error decoding behind this single
interface; the existing native-adapter constructor supplies controlled outcomes.
No GraphQL type, provider-framework symbol or new public test seam is added.

The chosen public calls are `fstat`, `fstatfs`, and `fsgetpath`. Retain the owned
descriptor throughout. Obtain the object's `st_dev`, `st_ino` and birth instant
and the mounted filesystem's `f_fsid`, type, flags and mountpoint; pass the
actual `f_fsid` and 64-bit `st_ino` to `fsgetpath`, never a fabricated fsid from
st_dev, a bundle identifier or a queued stale object number. The admitted mount
witness uses `fgetattrlist` with ATTR_VOL_INFO and ATTR_VOL_CAPABILITIES in a
fixed 256-byte attribute buffer, validating its returned length and capability
valid-mask before using a
`VOL_CAP_FMT_PATH_FROM_ID` bit. An unknown capability check is inspection
failure; a missing capability on an otherwise admitted volume leaves discovery
unsupported by this adapter and pending, with INSPECTION_FAILED, rather than
silently excluding its names. These metadata calls need no additional owned
descriptor. The fixed native buffer is charged to the existing scratch account;
opaque kernel/library resource costs remain the native resource design's concern.

Call `fsgetpath` with exactly 8,192 bytes. On success its positive return count
includes the terminating NUL, so native directory text can contain at most
8,191 bytes. Require the reported count to fit, the last byte to be NUL, no
embedded NUL, an absolute component path and a strict, round-tripping UTF-8
decode. Preserve bytes, case and Unicode; no normalization or replacement
characters. Invalid native output is uncertain inspection, never size evidence.
The public 4,096-byte requested / 8,192-byte returned-or-scratch value ceilings
remain unchanged. Joined file locations can reach 8,192 text bytes; a directory
of that text length cannot fit this syscall's NUL-inclusive buffer and receives
an affecting native-size omission. It is still in the eligible domain. This
explicit native limitation is neither a smaller configured limit nor accepted
workflow coverage; no 8,193-byte syscall buffer or private long-path entitlement
is assumed. The [native call analysis](../verification/search-canonical-paths.md)
records the public declarations, limits and remaining acceptance subjects.

After fsgetpath returns, on success **or a non-resource error**, check
cancellation and then repeat `fstat`/`fstatfs` to compare the established
directory identity and mounted-volume observation. Cancelled work does no new
inspection; resource failure follows the existing cohort stop immediately.
Before a target-size group, reacquire the held actual parent's canonical
observation, require its path/identity/policy to be unchanged, and repeat the
child association check. A pre-call check alone does not license that group.
Parent checks use the same operation in parent/current-stream context without
recursively demanding its own parent or opening another descriptor.
Directory content mtime is
not an identity discriminator. When a target has an established parent, bracket
acquisition with no-follow `fstatat` of that parent's observed child name and
compare its directory identity with the held target. The parent itself must
have passed its current canonical/policy check. Compare successful canonical
paths with established frame/task paths and reapply region/mount/protected/cloud
policy before publication, child metadata work or entry/EOF read. Queued tasks
reacquire descriptors by the existing checked component walk, not fsgetpath of
an old inode. Supplied and expanded long paths are resolved component-wise
with bounded no-follow `openat` and checked `readlinkat` steps; the adapter must
not feed an entire long absolute path to a PATH_MAX-limited open, realpath,
Foundation canonicalization or path-based attribute query. The same two
temporary descriptor credits cover these walks, with old walk descriptors
closed on transfer. No third validation descriptor or retained ancestor array.

The public API is an fsid/object lookup, **not descriptor-bound pathname
resolution**. Holding a descriptor and comparing identity/association observations
guards ordinary reuse and detects observed change; it does not make path
acquisition atomic, establish a mount-generation token, prevent ABA between
checks or pin a later action. An unlinked/renamed object or lookup error cannot
establish absence of the supplied root. Kernel movement retries can also end
with ENOENT. Treat a witnessed association/path/mount mismatch as
CHANGED_DURING_SEARCH; without that evidence, non-size lookup failures remain
uncertain. There is no product retry, cached-path success or fallback spelling.
Signed-host tests must check the lookup itself for protected-alias prompts and
hydration; the source/SDK facts supply no consent guarantee. A prompting route
requires redesign before acceptance.

`fsgetpath` returning -1 with captured ENOSPC **at the fixed full buffer**
establishes a native path-size refusal. A second, pre-enqueue proof is the
lossless canonical-parent/name join of an observed ordinary directory: text
length 8,192 or greater cannot fit that same NUL-inclusive buffer. Diagnose it
at the actual parent before finalizing its match or enqueueing; this does not
apply to an ordinary file, final symlink or alias location at exactly 8,192 bytes.
It prevents tasks that are guaranteed to fail solely at the native size boundary.
EINVAL, malformed output, missing
capability, ENOTSUP, ENOENT and EIO do not. EACCES/EPERM retain an observed access
refusal without inferring a named consent; EMFILE/ENFILE retain the existing
resource-failure/cohort handling. A too-small test buffer is an adapter defect,
not legitimate VALUE_LIMIT coverage. Public value overflow of a losslessly
joined path is separately established by its measured byte length.

| Context / evidence | Scope and continuation |
| --- | --- |
| Unresolved root has a known native-size refusal | UNKNOWN, resolvedPath null, one VALUE_LIMIT REMAINDER at its representable requestedPath. No searched record or fabricated canonical path. |
| Admission/home/mount witness cannot supply a canonical path | The existing pre-turn witness refusal yields all roots UNKNOWN/zero counts with requested-path INSPECTION_FAILED REMAINDER; size detail is fixed guidance. Do not drop or invent a policy witness. |
| Current stream or queued walk prefix/parent now exceeds native size | A previously established path that fit this fixed buffer no longer fits: observed path change uses one CHANGED_DURING_SEARCH REMAINDER. If the prior association/path was never established, use one INSPECTION_FAILED REMAINDER. Preserve progress and prior groups; no further read/open or per-dependent-task exceptions. |
| Independent target has a size refusal and an established unchanged representable actual parent and child association | VALUE_LIMIT CHILD_GROUP keyed by actual parent/reason; count that encountered anchor once, omit its name and descendants, continue unrelated siblings/tasks. Do not first finalize the candidate as a match. |
| Target's parent/association is changed or uncertain, including a checked-link target whose actual parent is unestablished | Change or uncertainty takes precedence: one root CHANGED_DURING_SEARCH or INSPECTION_FAILED REMAINDER. An ENOSPC from an unassociated object cannot justify a parent group. |
| Joined path exceeds the public value ceiling, or an ordinary directory join cannot fit the native NUL-inclusive ceiling, before enqueue/publication | VALUE_LIMIT CHILD_GROUP at the established actual parent; no finalized match/queued task and no shortened path. Ordinary file locations at exactly the public ceiling remain representable. |

Groups require no new child identity list and use one fixed native/public
path-size guidance template. Native-size groups can grow only for distinct
established parents, not every dependent queued task beneath one inaccessible
prefix. Existing coverage record/byte exhaustion still stops honestly.
In file search an already finalized directory-name observation can survive a
later dequeue refusal. If the final target unexpectedly returns ENOSPC, do not
retroactively emit a name-omitting CHILD_GROUP: stop the root once with
CHANGED_DURING_SEARCH when its formerly fitting path/association is established,
otherwise INSPECTION_FAILED. That later stop omits unfinished descent, does not
retroactively count the name as unexamined or invent resultsTruncated. A candidate
refused before finalization may set resultsTruncated only after its matching
location/application identity was established, under the existing rule. With
no progress a size remainder remains failure-class before prompt risk.

`F_GETPATH` cannot cover the native long-path subjects; reducing every buffer
to PATH_MAX would add unaccepted omissions. `realpath`/Foundation alternatives
mix presentation spellings and impose separate resolution limits. A manual
parent/name reconstruction needs additional binding, firmlink and descriptor
semantics and is not a successful canonical fallback. Use public fsgetpath's
default firmlink presentation, never private `fsgetpath_ext` or no-firmlink
options. Actual startup-pair, Preboot, case and Unicode spellings must pass the
same adapter/VM subjects. Reopen this choice if those fail or if its measured
size/race/prompt omissions defeat the workflow; no narrower domain is approved.

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
| `CHILD_GROUP` | Exactly `count` encountered child anchors of this representable actual parent have UNREPRESENTABLE_NAME or known native/public path-size VALUE_LIMIT; inspection/matching and any descendants are omitted. Identities are withheld. Descendants are not counted. Never asserts that all children were skipped. |
| `DESCENDANT_GROUP` | Exactly `count` encountered anchors somewhere beneath this root have one intrinsic reason, DEPTH_LIMIT or FRONTIER_LIMIT; identities are withheld. Intrinsic reasons retain their name/domain rules. Depth/frontier bounds omit only eligible descendants: directory anchor names remain matchable. Counts anchors, not descendant names; asserts neither a complete listing nor whole-subtree exclusion. |
| `REMAINDER` | Eligible work beneath this root unfinished at freeze: unread stream tails, queued/unopened descent, held-stream work and unfinished metadata. Excludes established observations and already diagnosed frontier/depth omissions without enumerating them; never asserts the whole root was skipped. Its size is unknown. |

`count` is positive only for the two GROUP extents, null otherwise. A group
contains an observed set, not every same-reason entry in an unread directory.
Group records require identical reason, guidance and `affectsCoverage`.
CHILD_GROUP carries only UNREPRESENTABLE_NAME or
known native/public path-size VALUE_LIMIT, never permission: prompt risk needs an exact ENTRY/SUBTREE
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
ENTRY_LIMIT and DIAGNOSTIC_LIMIT stops use REMAINDER. An individual overlong or native-size-refused
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
`UNREGISTERED` means checked registration inspection reported no entry for that
exact present bundle identity under the selected native-observation meaning;
it does not prove internally healthy service work or exclude a stale-service
false negative. Retain it as a reveal/path-copy candidate and
copy its identifier when known, but never offer constrained launch for it.
`UNKNOWN` means application metadata/registration could not be established;
never silently replace it with another installation. A bundle without an
identifier may appear
as UNKNOWN with a null identifier for reveal/path-copy, and cannot form a launch
selector. Report missing/failed application metadata as partial coverage, not
proof of absence. An empty registration array or nil Bundle identifier never
establishes absence, UNREGISTERED or a missing identifier; both remain UNKNOWN
with affecting coverage even if later stat/access succeeds. Resource exhaustion
can produce the same answer.
The finalized search call/error contract below uses
the [selected observation boundaries](#observation-boundary-decision-questions)
and still requires load-bearing review; existing action acceptance does not clear search.
Both public per-identifier registration answers remain selection inputs where
their inspection is established; registrations alone do not prove presence.
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
VALUE_LIMIT is reserved for an individual public/native path-size refusal,
not total diagnostic space or unclassified lookup failure. The reserved remainder covers that entry's
uncommitted outcome and all remaining work,
not a falsely universal parent SUBTREE. Mandatory diagnosis always wins; no
match can consume coverage space. Ordinary directories add counters, not
records; intrinsic omissions use four root groups, not one record per package.
Only invalid/native-or-public-size child parent groups and independent exact native/policy
failures grow with exceptional targets. Width and depth bounds allocate no
exceptional parent records. A changed queued walk prefix or immediate parent
stops the root once, rather than allocating one record per dependent task.
Independent target failures can still exhaust diagnostics honestly;
neither coarse groups nor reserved depth/frontier counts guarantee useful coverage.

The scheduling unit is at most 64 consumed entries of one root, including
classification and candidate metadata, and at most 32 EOF/open-or-refuse task
transitions. Visit admitted unfinished roots cyclically in input order, one
unit each; all admission/root metadata turns precede listing turns. A root
retains one current stream across its turns. Before every listing turn, including
the first, obtain its current canonical location/identity/mount and reapply
root/protected/cloud/region policy before the next entry or EOF read. Compare
with the frame's established identity/path; observed movement stops the root
with CHANGED_DURING_SEARCH REMAINDER, unestablished checks with INSPECTION_FAILED
REMAINDER. No further read, stale-parent path publication or path-based metadata
inspection follows an observed refusal. Repeat the parent check before any
child metadata open during a turn. The check-to-read/check-to-open window
remains non-atomic and requires actual-call/no-dialog acceptance. Finish that listing to EOF before
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
independently. Component metadata revalidation and current-stream turn checks consume the wait and scratch,
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
scheduled. An individual public/native-size-refused child path uses VALUE_LIMIT CHILD_GROUP and
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
conversion. An absent/changed walk prefix or immediate parent stops the root once with
CHANGED_DURING_SEARCH REMAINDER, including ENOENT/ENOTDIR before the final target
and a replacement whose final parent identity differs. Unestablished prefix/
parent inspection stops it with INSPECTION_FAILED REMAINDER. This precedence is
the same whether observed inside a walk or at the next dequeue; drop remaining
tasks only through worker cleanup, preserving committed omissions. An exact
CHANGED_DURING_SEARCH SUBTREE is used only for an absent/replaced final target
after its immediate parent is established unchanged; continue unrelated tasks.
An uncertain target under such a parent has exact INSPECTION_FAILED SUBTREE.
No new expected-ancestor array is retained. A current stream/held walk parent's
observed movement also stops the root with CHANGED_DURING_SEARCH REMAINDER.
Full-buffer ENOSPC for a formerly fitting canonical path is likewise change
evidence; uncertain prior association instead uses one INSPECTION_FAILED stop.
No later size refusal retroactively groups an already finalized name.
No child open follows observed movement/unknown policy. The remaining
check-to-open prompt window and actual canonical calls require signed-host
acceptance. Rewalking a bounded path does not rescan its ancestors' names, but repeats their
checked opens and canonical/identity/policy calls. A chain listing depths 1…31
requires 1+…+31 = 496 checked component opens, before admission, listing-turn
checks and child metadata. The 32-chain depth-anchor subject needs 15,872 such
opens; sixteen chains need 7,936/job or 31,744/four jobs. Canonical path production
can itself walk/build prefixes. Record component opens, canonical calls, turn
checks and their elapsed share of the unchanged wait separately from entries.
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
the work/retained-value bounds. Choose FIFO's explicit frontier omissions and fresh target revalidation over
repeated name listings. FIFO's repeated component walks can likewise exhaust
the three-second wait, especially in many small directories at depth 8…20;
this is a visible cost, not a claim that FIFO eliminates quadratic prefix work. Revisit only if measured queue
omissions defeat the workflow and a bounded alternative demonstrates better
per-witness coverage without larger budgets or an unapproved domain/setup change.

| Choice | Pending values / streams | Repeated work, groups and freeze |
| --- | --- | --- |
| FIFO breadth-first | One frame/root plus at most 512 queued/in-flight tasks, all within 384 KiB/root; roots + 2 owned descriptor credits/job. | Each name listing once; fresh depth-k task walks repeat k checked components and spend wait/scratch. Turn rechecks also spend wait. One reserved frontier group plus depth group. Queue/stream/unfinished candidate becomes remainder at freeze; worker-only cleanup releases retained paths and credits. |
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
Guidance distinguishes busy worker/credit admission from a latched lower-limit
or resource-failure cohort: “Search inspections disabled until admitted workers
finish cleanup; an indefinitely blocked call requires restarting Koine.” This
uses existing CAPACITY_LIMIT/INSPECTION_FAILED, not a new status or ABI.
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
lock, without holding it across a native call. Let C be the sum of all surviving
jobs' reserved Q credits, including frozen/blocked jobs, not current descriptor
occupancy or this job's Q. If refreshed S′ < C, latch lower-limit refusal for
that admitted cohort: no new native inspections (including opaque metadata)
and no new jobs until its complete worker cleanup and a fresh admission read.
A later higher limit does not unlatch it. Existing unfrozen roots get
CAPACITY_LIMIT REMAINDER when next scheduled; keep earlier progress/groups and
never rewrite already frozen results. If S′ >= C, existing reservations still
fit; a new job needs C + Q <= S′ and a worker atomically. A lower L that leaves
S unchanged does not itself freeze jobs. Unknown refresh instead latches
INSPECTION_FAILED refusal. No worker-owned descriptor is closed externally,
no limit is raised, and all reservations remain charged through cleanup.
Outstanding reservations above S′ are a serviceability limit, not a claim of
continued reserve. With four workers and Q <= 18, descriptor admission can
bind only below L = 200; at L = 256 a fifth job is refused by workers, not credits. An actual native EMFILE/ENFILE despite reservation uses
INSPECTION_FAILED at the observing root; stop further search-open admission
process-wide for the surviving admitted cohort. Other roots/jobs retain earlier
observations and freeze with INSPECTION_FAILED resource remainders when scheduled;
the shared refusal flag prevents every new native inspection in that cohort,
including opaque metadata calls. Already admitted calls may return for cleanup;
already frozen/public results are never rewritten with a later refusal.
No replacement/retry opens occur until that cohort is fully cleaned up and L is
read afresh. New jobs during that refusal cohort get pre-turn CAPACITY_LIMIT,
without opening or joining it. This cannot retroactively isolate unrelated native failures. If one cohort
call never returns, new search remains disabled until process restart even
when other workers are free; provider stop/start cannot recover it. Tests must
combine the resource flag with one indefinitely blocked call, not test those
conditions only separately.

S bounds descriptors Koine explicitly owns, rather than all descriptors a
platform API can allocate internally. Bundle/registration/resource metadata
calls may open unexposed descriptors; execute one such call at a time per job
and treat those internal opens as demand against R, together with listener,
store, other providers/actions and inherited descriptors. R is a chosen budget,
not an OS reservation or proof those consumers use at most 128. The finalized
in-process call/error contract below retains the selected observation limits.
Instrument/subject construction and the complete-resource review precede planning. A ledger sees owned charges only; descriptor polling
or before/after Bundle/registration counts miss transient opens and cannot
attribute demand among concurrent search/listener/store/action threads. An
empty/nil answer cannot certify successful metadata inspection. NIO's async
listener bootstrap uses AcceptBackoffHandler with error forwarding disabled;
accept EMFILE may therefore pause accepts for one second without a public error.
Error-free client replies alone are not a serviceability verdict.

The independently selected [evidence boundary](#observation-boundary-decision-questions)
requires a constructible instrument for complete owned-credit/admission and
listener accept/backoff hook events, exact native-call envelopes and controlled
independent listener/store/action outcomes. The owned transient-open and
suppressed-accept controls must fail when their applicable events are lost.
Opaque internal acquisitions, peaks, lifetimes and swallowed errors remain
unproved; neither a successful span nor an owned ledger supplies that proof.
The host is launched normally with its inherited limit while independent new
connections/queries, durable grant-store operations and authorized launch/open/
reveal run. Record each operation, latency, owned occupancy and observed
resource/backoff events; an independent resource failure or accept backoff fails
conservatively, even if later replies succeed. Lost applicable events, attribution
gaps and inconclusive reference comparisons cannot pass. This resource criterion
adds no general latency target. Combined demand must fit L minus owned search
occupancy; the reserve is not an OS guarantee. Call/instrument contracts below are finalized;
instrument/subject construction and review remain pending. Static caps, polling, simulated
tables and shell-raised hosts cannot substitute for native evidence. Arbitrarily
heavy unrelated clients, system-wide ENFILE and externally lowered limits remain
outside a general serviceability guarantee.

### Native allocation decision

**Scope decision: retain Koine's single-process posture. Helper packaging and
child descriptor-limit changes are not authorized.** The operator declined the
support-process proposal, questioning why a separate process was needed.
Continue allocation design inside Koine. After Antony instructed "you decide",
select the reported-native-result and empirical-evidence boundaries below as
independent decisions under delegated judgment. They replace only the original
proof-of-internal-health requirement for the named native facts and exhaustive
opaque-event/fully-owned-route requirement for serviceability evidence. Resource
budgets, domain, authority, consent, compatibility and the agreed GraphQL,
native-binary and isolated-VM seams remain unchanged. The complete in-process
allocation contract below is finalized as design, pending complete-resource
review, implementation and native acceptance.

The helper was proposed to contain one particular failure: platform metadata
calls can acquire descriptors outside search's owned account, and exhausting
Koine's shared table can prevent unrelated connection or file opens. A separate
finite table could contain that per-process demand. The
[feasibility analysis](../verification/search-native-resources.md) supplies
source/SDK concerns and incomplete observation evidence; it does not demonstrate
a normal-search failure or establish that a separate process is necessary.
Isolation also adds signing, IPC, bootstrap, TCC-responsibility and child-lifetime
obligations, and does not establish healthy metadata or system-wide serviceability.

| Direction | Caller burden and allocation ownership | Selection and cost |
| --- | --- | --- |
| Direct owned inspection | One private native boundary owns checked opens, identity, reads and errors within roots + 2 credits. | A bounded manifest parser does not supply registration or native package/type semantics. Suffixes, a private registration database and UNKNOWN for every launch candidate would change the workflow. |
| Opaque inspection in Koine, within the selected boundaries | Keeps native semantics and single-process composition; checked reported facts and empirical independent outcomes carry explicit internal-health/visibility limits. | Selected design below normalizes results, serializes two-credit walks and defines applicable instrumentation. Construction, review and acceptance remain pending. CFError, polling and eventual replies do not prove opaque safety; signing/launch posture stays unchanged. |
| Finite-table private helper, outside approved scope | A separate descriptor table could contain opaque per-process demand, at the cost of transport and child ownership. | The operator declined this design direction. Necessity is unestablished; separation proves neither metadata health, host spawn demand, system-wide demand nor orphan cleanup. |

The declined proposal was a support executable sealed inside Koine's app,
signed by the same Developer ID team under a distinct fixed signing identifier,
with empty entitlements and launch restricted to admitted search workers. Its
proposed ceiling of 32 descriptors per child and one live or unreaped child per
job, at most four process-wide, never established bootstrap, system-wide demand,
metadata health or useful coverage. Packaging was declined before asking the
dependent child-limit question; neither proposal is authorized. Responsible
TCC identity and prompt behavior were also unestablished. No new consent, usage
key, entitlement, signature or standalone service is approved.

Koine's inherited limit, roots + 2 owned credits and two temporary descriptors
remain binding, including the 128/160/200/256/infinite/unknown cases and
summed-reservation lower-limit latch. No root-credit borrowing or third
temporary descriptor is allowed. The helper comparison exposed extra costs:
`socketpair` transiently uses both host temporaries, a persistent IPC endpoint
cannot coexist with a two-descriptor component walk, and two pipes use four
transient endpoints. These are reasons isolation was not already a complete
allocation contract; they authorize no spawn or transport design here.

The observation boundary must distinguish value, health and lifetime. Public
`LSCopyApplicationURLsForBundleIdentifier` with `outError` is the error-bearing
registration candidate; preserve error domain/code and bounded underlying
resource causes. An unexpected result/error combination or nil/nil is uncertain.
A matching returned URL still needs presence and native-identity checks; it
cannot introduce a discovery root. Under the selected reported-observation
meaning, only the exact checked not-found branch or a fully checked nonempty
no-error array can establish UNREGISTERED as detailed below. Empty arrays,
unexpected errors, incomplete/conflicting observations and nil identifiers
remain uncertain; nil never asserts a missing identifier. Reported or explicitly
associated EMFILE/ENFILE refuses negatives and latches the cohort. Undetected
internal failure or stale service state can still produce a normal-looking
negative, an accepted fact-meaning limit rather than a passed health test.
Later `stat`/`access` and lack of reported error prove no internal health.
All-UNKNOWN launch metadata and incorrect known-witness outcomes still fail
acceptance. The decision covers reported type/package/hidden/alias facts and
positive identifiers as well as registration; the helper refusal supplied none
of this authority.

A direct identifier reader remains an alternative requiring exact layouts,
no-follow policy/identity checks, checked `openat`/`read`/EOF/error handling,
bounded XML/binary-plist parsing and scratch accounting. Only a complete stable
metadata observation can establish a missing key. No arbitrary file contents,
plist-link following, localization/icon reads, content sniffing or hydration is
authorized by this scope decision. Native package/type semantics must survive;
an extension-only replacement is insufficient. The canonical `fstat`,
`fstatfs` and `fsgetpath` choice and native-size obligations remain unchanged.

Freeze cannot reclaim a blocked worker's descriptors. The in-process contract
retains charges through worker-only cleanup, preserves previously finalized
observations and owns late returns and closes exactly once. A resource failure
beside an indefinite call retains disabled-search guidance and prevents new
inspections/jobs; provider restart cannot reset that state. Process-restart
recovery remains an acceptance obligation.

The finalized allocation below supplies reported native result/error rules,
owned versus opaque demand, two-credit ownership and recovery for construction
of serviceability subjects. Its acceptance handoff refuses
negatives with observed/associated resource failure and retains the disclosed
undetectable-failure limit; nil identifiers remain UNKNOWN. Preserve the owned
transient-open and suppressed accept/backoff detection controls, independent
listener/store/action work, cohort/lower-limit cases, retained compatibility
profiles and actual useful Safari/Finder/home coverage. Polling and eventual
error-free replies do not settle these obligations. The rejected helper's
bootstrap, transport overlap and blocked-child-surviving-host-exit controls
remain discriminators for any separately authorized reconsideration, not
required helper tests in the current single-process continuation. No helper
reclamation, parent-death, replacement or timeout-kill claim is accepted.
Mandatory review of the complete resource artifact still precedes planning.
Native, binary and workflow acceptance remain pending.

<a id="proposed-in-process-observation-contract"></a>

#### In-process observation contract

**Final allocation design within the native-result and serviceability-evidence
boundaries selected under Antony's "you decide" delegation. Implementation,
complete-resource review and native acceptance remain pending.** The boundaries
are two independent agent decisions, not two personal yes
answers attributed to Antony. Retain the approved single-process posture and
prefer the native calls below over new content readers or private registration
scraping. The [resolved decisions](#observation-boundary-decision-questions)
replace only the named fact-health and opaque-event guarantees. Reported
observations do not prove internal platform health, and controlled acceptance
does not prove hidden-resource safety. Every other obligation remains binding.

One private inspection boundary owns result/error normalization and exposes
value, uncertainty, observed change or resource refusal to the accumulator.
The existing native constructor is its enabling point for controlled outcomes;
clients supply no call order, locks or resource-health protocol. The runtime
owns process-lifetime reservations and freeze; the accumulator alone finalizes
metadata and coverage together. Native answers cannot introduce discovery roots.

| Responsibility / actual calls | Usable reported observation | Uncertain or failing observation |
| --- | --- | --- |
| Owned listing, identity and path: checked `openat`, `fstatat`/`fstat`, `fstatfs`, `fdopendir`/`readdir`, and the canonical `fsgetpath` operation | Existing policy/identity/location checks and explicit POSIX success/EOF. `fdopendir` transfers an owned descriptor; it creates no second charge. | Captured errno, changed association, invalid output or native-size refusal follows the existing scope rules. Set errno immediately before `readdir`; nil with nonzero errno is failure, never EOF. |
| Native application/package/hidden/alias/type metadata: a fresh `URL.resourceValues(forKeys:)` for `.isApplicationKey`, `.isPackageKey`, `.isHiddenKey`, `.isAliasFileKey`, `.contentTypeKey`, with only keys needed for this entry | Required booleans must actually be supplied; a nonnil type identifier must fit the optional-string account. These are native reported facts, not extension inference. Existing directory identity/canonical checks bracket the call. | A thrown error, missing required value, conflicting facts or unrepresentable optional value yields affecting inspection coverage and unknown fields, or omission when application classification cannot be established. It cannot authorize descent into a possibly hidden/package directory. Native false/no values have the selected residual internal-health limit. |
| Identifier: `Bundle(url:)` followed by `bundleIdentifier`, without executable loading or localized/icon/resource lookup | A supplied nonblank bounded string is an observed identifier, subject to bundle identity/location rechecks. | Nil, blank, wrong type or overlong value means null identifier, UNKNOWN installation and affecting INSPECTION_FAILED coverage. Never assert that the bundle declares no identifier. Later `stat`/`access` does not upgrade nil; no direct Info.plist read is selected. |
| All registrations: `LSCopyApplicationURLsForBundleIdentifier`, with initialized `outError` | A nonempty CFArray with no error supplies reported registration URLs; inspect one at a time, never bridge it into a second growing Swift array. Each candidate URL must be a bounded file URL admitted by the existing policy, then checked for present native bundle identity. A positive exact identity can establish INSTALLED. | Nil/nil, empty array, array plus error, wrong element type or any error except the specifically decoded not-found result is uncertain. Any EMFILE/ENFILE in captured underlying causes latches resource refusal. Never use the action adapter's errorless registration array to prove absence. |
| Preferred per-identifier observation: `NSWorkspace.urlForApplication(withBundleIdentifier:)` | A nonnil URL is a separate selection input only after the same policy, presence and native-identity checks. | Nil is no negative fact. A conflicting positive preferred observation invalidates a tentative negative from the all-registration query. A failed/blocked preferred-target check prevents negative finalization; no fallback retargets the candidate. |
| Type conformance: `UTType(identifier)` and `conforms(to:)` against the existing executable/application/alias refusal types | A supplied native type and established conformance select the existing file disposition; preserve native package/alias semantics. | Failed type construction or missing type remains UNKNOWN with affecting coverage. Neither a suffix nor unknown type alone proves executable status. The native type service has the same opaque-health limit. |

These are search's selected calls, not a claim that the action adapter already
implements them. File-search symlink entries retain UNKNOWN fields without
target/resource inspection; the checked application-link exception still needs
both-spelling policy checks and its actual-call prompt acceptance. Apple
documents the all-registration query's returned URL
array and its nil plus `kLSApplicationNotFoundErr` result, and marks the API
deprecated in favor of NSWorkspace. It remains declared in the inspected SDK.
The error channel is the reason to propose it; deprecation is a migration cost.
The [public API contract](https://developer.apple.com/documentation/coreservices/1449290-lscopyapplicationurlsforbundleid)
does not supply an internal-allocation bound or a completeness/health token.
Fresh Foundation resource-value requests can still use platform caches; fresh
URLs do not create an atomic filesystem snapshot. Prompt-free evidence covers
the [previously measured keys and fixtures](../verification/protected-path-metadata.md),
not the new package/hidden combinations or every link/volume. Any prompting
route fails acceptance; this design supplies no permission to prompt.

Under the selected reported-observation semantics, UNREGISTERED means **the public registration
observation reported no registration for this checked present native identity**.
It could be finalized in only two cases: the all-registration query returned
nil with the allowlisted pair `kCFErrorDomainOSStatus` and
`kLSApplicationNotFoundErr` (−10814), and no observed resource error or preferred
observation matching this candidate's native identity; or a nonempty no-error
array was fully consumed and every relevant URL's identity/absence was established with
none matching, with no preferred observation matching this candidate's identity.
Preserve the actual error domain/code; a numeric code in another domain is not
not-found. Decode
underlying causes one at a time, at most sixteen objects within existing scratch,
detecting cycles/truncation without copying an unbounded tree; an incomplete error
classification is uncertain, never a negative. A policy-blocked, changed,
malformed, too-long or unreadable registration URL, incomplete iteration, wait
expiry or refusal prevents the whole-array negative. A known absent stale URL
can be accounted for; an unreadable one cannot be called absent. The preferred
nil does not supply health for either case. The exact domain/code pair must be
confirmed against the supported runtime in the real-provider subjects.

This retains positive **and** negative registration cases, not positive-only
registration or UNKNOWN for every application. It explicitly admits a residual
false negative if Launch Services returns a normal-looking not-found/incomplete
answer after an undetected internal failure or stale service state. A complete
array also cannot prove absence outside that observed service answer. The
original internal-health requirement is replaced for these facts by the selected
reported-observation meaning. Native type/package/hidden/alias values and positive
identifiers likewise carry a possible undetected incorrect-fact limit; known
incorrect witness outcomes remain acceptance failures. Even an apparently
positive answer is a platform observation, rechecked
at action time, not a certified internally healthy platform snapshot. No
separate no-identifier assertion is selected or exposed through a null field.

##### Bounded native-result consumption

Native objects returned before validation are opaque platform allocations, not
charged copied values and not a hidden RSS/descriptor bound. Initialize the
registration error output to null. Own and release each returned Create/Copy
array/error once on the worker. Obtain the array count once as a checked
nonnegative CFIndex; index it with one checked counter and borrow one element
at a time. The owning array retains its elements until release. Never release
borrowed elements, eagerly bridge the array, sort it, build a deduplication set,
or retain a per-registration identity history. Copied target path/identity and
fixed found/uncertain flags share scratch with the candidate. Release these
copied target values after each check. A fresh array is a new observation,
never an uncharged retry or continuation of a failed one.

Validate CF element type before conversion. Accept only local absolute file
URLs, with no query, fragment, remote host or NUL; URL syntax is not evidence of
target presence. Use CFGetTypeID/CFURLGetTypeID before URL conversion and
CFArrayGetCount/CFArrayGetValueAtIndex for borrowed iteration. Copy filesystem
representation with CFURLGetFileSystemRepresentation through a caller-owned buffer
of 8,193 bytes including NUL, within the existing 8,192-byte text ceiling and
scratch account, then use the existing checked component walk and policy.
No growing absoluteString/path normalization or native-error description is
retained. A refused URL prevents a whole-array negative; a known absent final
target under an established parent can be accounted for. Registration URLs do
not expand admission regions and never resolve Finder alias files. Only the
existing checked application-link rule permits symlink target inspection.

Check cancellation, wait, cohort and refreshed limit before each native call,
each array element and each component transition. Array elements and these
metadata checks consume wait/scratch, not directory-entry credits. There is no
new arbitrary registration-count cutoff: finite arrays may be consumed with
constant retained state only while the existing wait permits. Interrupted or
unrepresentable observations are UNKNOWN with affecting coverage or the existing
stop remainder. A positive matching identity can end the all-registration scan;
a negative requires complete consumption. Returned array order never selects
the discovered application or supplies an exhaustive installed-app inventory.

Validate optional strings before copying within the existing 1,024-byte value
ceiling, including type identifiers, bundle identifiers and error domains.
Use a length precheck and fixed UTF-8 conversion buffer (CFStringGetBytes for
CF strings), refusing incomplete conversion before retaining a Swift copy.
Foundation/UTType-produced objects before this check remain opaque allocations.
No trimming, truncation or alternate identifier is published. A missing/invalid
required boolean cannot be replaced by false. Missing optional type is UNKNOWN
with affecting coverage; a missing identifier never asserts a missing key.
The policy decision still precedes the metadata request. File symlink/alias
targets, document handler lookup, content reads, localized resources, icons,
registration writes and hydration remain outside this read. Fresh URLs and
Bundle values may use opaque caches and preserve the selected health limit.

Error normalization uses domain/code and only supplied underlying-error links,
never localized text or arbitrary userInfo enumeration. Visit at most sixteen
error objects, using bounded identity/queue slots in scratch; inspect supplied
single/multiple underlying causes by index without bridging an unbounded list.
A repeated object/cycle, malformed cause, excessive child count, overlong domain
or unfinished classification makes the classification incomplete. Any recognized
POSIX-domain EMFILE/ENFILE seen before that stop wins and latches the cohort;
incompleteness alone refuses a negative without inventing exhaustion. Numeric
errno values in other domains do not identify a resource error. The allowlisted
not-found pair remains kCFErrorDomainOSStatus/−10814 with no resource cause and
complete error classification; its actual supported-runtime pair is a mandatory
native subject, not a fact established by the SDK declaration alone.

Finalize registration from one bounded candidate observation. A no-error
nonempty array with a checked matching native identity supports INSTALLED only
while no malformed/conflicting input or inspection uncertainty has been observed
in that all-registration observation. Later positives cannot rescue an already
uncertain observation; a positive may stop before unexamined elements.
The two checked negative branches above support UNREGISTERED only after the
separate preferred observation has either returned nil or a checked absent/
different native identity. A preferred identity matching the candidate while
the all-registration result says negative is a conflict: UNKNOWN with affecting
coverage, no fallback. Failed/blocked/changed/malformed preferred-target checking
also prevents a negative. Nil preferred input adds no health proof. Array/error,
empty or nil/nil results never become negatives; a preferred positive cannot
rescue that failed all-registration observation. Metadata uncertainty can retain
a canonical candidate as UNKNOWN for reveal/copy, but useful configured launch
acceptance still requires actual INSTALLED Safari/Finder and distinct-copy cases.

<a id="proposed-allocation-and-lifetime-ownership"></a>

##### Allocation and lifetime ownership

Keep the existing Q = roots + 2, S = min(72, max(0, L − 128)), four workers,
accounts, inherited host limits, domain and no-wait admission. All explicit
opens/dups acquire a temporary or root credit first; in-progress attempts count
against occupancy before entering the syscall. Component walks close the old
descriptor before advancing beyond two temporaries. Registration-target checks
reuse this serial walk; they open no extra persistent stream and cannot borrow
an unused root credit. Release the owning array/error and candidate objects
before the next discovery candidate once their bounded copied values are
accounted for; borrowed elements remain owned by the array until its release.
Do not retain a history of registration URLs, alternative bundle layouts or discarded native identities.

The serial choreography below applies even while all root streams are held.
Root-stream credits never become spare temporary credits. Each retained path,
identity, buffer and wrapper is charged before storage in the same 128 KiB
scratch partition; a candidate plus one target and a two-component walk fit the
existing shape, or refuse with affecting coverage before another allocation.

| Phase | Temporary A / B and retained observation |
| --- | --- |
| Candidate identity and native metadata | Walk with A as checked parent and B as newly opened child; validate child/parent association, then close A before advancing. At the final pair, canonical and metadata checks use those charged descriptors and bounded candidate values. No third validation descriptor. |
| Before registration-target inspection | Record candidate path/identity/identifier in scratch, then close both temporaries. Retain values, never an original candidate descriptor while starting another walk. The root listing streams stay separately charged. |
| Each returned registration or preferred URL | Reuse A/B for a fresh policy-checked component walk. Bracket final target acquisition with the held immediate parent's no-follow association checks, capture checked identity/absence, and close A/B before the next URL. An existing validated root stream may anchor descriptor-relative work without dup; it cannot lend its credit. |
| Before candidate finalization | Release registration/preferred result objects once their bounded verdicts are captured. Reacquire the original candidate with A/B and compare path, mount, native identity/incarnation and parent association with the initial observation. An observed change/uncertainty follows the existing exact-target versus root-remainder rules; no result is finalized from a stale candidate. Hold A/B through the commit/discard decision, then close them on the worker. |
| Next entry, freeze or unwind | Only bounded copied values reach the accumulator. Worker cleanup owns every stream, temporary and native object. A late acquisition follows the same charged cleanup path even when its data cannot be committed. |

The initial and final observations are not an atomic snapshot or protection
against ABA. Native calls are path-based where their public APIs require it;
held-descriptor checks before/after expose observed movement, not a descriptor
binding for Foundation/Launch Services. Long component-resolved locations retain
the original domain/value limits. If an actual public metadata call cannot
inspect a supported long-path witness, diagnose its failure and fail that
workflow subject; do not silently install a shorter domain or a content-reader
fallback. Prompt/canonical subjects must inspect this exact call ordering.

Framework metadata, Bundle, Launch Services, UTType, Foundation conversion and
their caches/Mach replies remain **opaque in-process demand**. Execute one native
inspection at a time per job; concurrent jobs can still make four such calls.
The returned CFArray is itself a platform-owned allocation before Koine can
check its length. Only copied values fall under the existing scratch account;
no whole-array bridge or diagnostic-error-tree copy may escape it. Serial calls
do not bound internal descriptor/RSS demand, asynchronous platform work or
system-wide resources. Native entry/exit events label these spans, not their
internal acquisitions. The selected evidence boundary leaves those acquisitions
unproved rather than claiming the original fully owned route/complete observer
condition was met. R remains a budget, not an OS
reservation. It cannot ensure that another consumer's next open or accept fits.

Refresh the host limit before **every** new native inspection, including opaque
ones, and retain the existing summed-reservation lowered/unknown-limit latch.
At L = 128 no job opens; at 160 only one maximum-root reservation fits; at 200
four maximum-root reservations fit; at 256 a fifth job is worker-refused. Infinite
uses S = 72; failed/unknown inspection refuses without work. A later higher
limit cannot clear an existing refusal cohort. No setrlimit call, helper, IPC,
loader, entitlement or different normal-launch route is selected. ENFILE remains
a system-wide failure; neither Q nor the inherited per-process limit contains it.

Admission of each owned attempt or opaque span has a single linearization point
under the runtime's refusal/freeze check. Calls already admitted when freeze
wins can return later; no call is newly admitted after it. A successful late
open is installed in worker-owned cleanup state even when its data is discarded.
The timer/canceller never closes it. Failed `fdopendir` leaves the original
descriptor worker-owned; successful conversion transfers exactly one owner to
the stream. The worker closes each owned descriptor/stream exactly once and
releases its occupancy and reservation only after unwind. Never retry a close
using a stale numeric fd after a reported failure; ambiguous close health cannot
justify new search admission and requires process recovery. Framework-owned
objects are released by the worker; their hidden lifetimes cannot be certified
by that release. Finite delayed returns test cleanup; an indefinitely blocked
call retains its worker, objects, scratch and full Q.

Observed POSIX/underlying native resource failures retain the existing cohort
latch, freeze unfinalized work and preserve finalized/frozen values. No retry,
replacement worker, alternate metadata call or new job starts until the entire
cohort cleans up and L is read afresh. Provider stop/start reuses the same
process-lifetime owner and cannot erase a surviving job/refusal. One indefinite
call beside another job's resource failure therefore disables new search until
Koine process restart. Restart ends this incarnation's in-process ownership;
it does not prove global resource health or stop remote filesystem/service work.
The next normal process creates an empty owner and rereads its actual L. Existing
grants persist by their current store contract, while failed external work can
still cause refusal. No orphan-child recovery is needed because no child exists.

Admission, candidate/coverage finalization and freeze use the runtime's same
serialization gate. An admitted call has a unique attempt identity and charges
occupancy before leaving the gate; the gate is never held across native work.
The accumulator can commit candidate metadata, rank/root membership and its
diagnostic transition together only while that job/root remains unfrozen and
the cohort permits it. If freeze/refusal wins first, discard the uncommitted
data and retain only worker cleanup state. If finalization wins first, a later
freeze/resource event preserves that finalized observation. Timer/publication
threads freeze bounded snapshots; they never mutate worker-owned native objects
or close descriptors. This specifies the race outcome without a hard deadline
or a claim that an already admitted syscall can be cancelled.

Bounded returned-object error normalization and worker closes/releases are
unwind bookkeeping within the admitted attempt, not permission for another
filesystem/metadata/registration inspection after freeze.
A late failure is still normalized for visible resource causes **before** that
worker releases its cohort membership. It can latch the surviving cohort even
when its own response is already frozen; it cannot rewrite that response. A late
successful open first enters the worker's charged cleanup state, then closes
there without publication. Failed conversion leaves the original fd owned;
successful fdopendir transfers its one charge to closedir. Record one close
attempt per owned fd/stream identity, including numeric-fd reuse across later
attempts. On ambiguous close failure, do not repeat a close on the old number
or claim successful cleanup: retain that job's reservation/refusal and fixed
recovery guidance until process restart. Such a job never frees a replacement
worker or enables new admission. This is a bounded surviving refusal owner,
not an unbounded numeric-fd quarantine or an externally closed stream.

Limit cases are reservations, never estimates of opaque occupancy:

| Refreshed limit | Required admission/refusal behavior |
| --- | --- |
| L = 128 | S = 0; no Q fits, no filesystem/opaque inspection starts. |
| L = 160 | S = 32; one Q = 18 job fits, a second maximum-root job is credit-refused. Smaller Q jobs may fit subject to four workers. |
| L = 200 or 256 | S = 72; four Q = 18 jobs fit; the fifth is worker-refused, including at 256. |
| Infinite | S = 72 without sentinel arithmetic; no platform/system-wide resource bound follows. |
| Unknown initial read | INSPECTION_FAILED for every requested root before native work; neither worker nor Q is admitted. |
| Unknown refresh or S′ below summed surviving C | Latch inspection-failed or lower-limit refusal respectively; stop new calls/jobs, retain reservations and earlier/frozen observations until complete cohort cleanup and a fresh read. A later rise cannot clear it. |
| Lower L with S′ still at least C | Existing reservations fit; new job needs C + Q at most S′ and a free worker. Refresh/readmission never borrows idle root occupancy. |
| EMFILE/ENFILE or uncertain close with an indefinite survivor | Preserve the process-lifetime refusal owner across provider restart. New requests receive the existing disabled-search guidance without work. New normal process ownership can recover only if its actual L and independent/native resources permit it. |

<a id="proposed-observable-acceptance-boundary"></a>

##### Observable acceptance boundary

Keep the already agreed independent real GraphQL/native-provider and normally
launched signed hardened Koine isolated-VM seams. Under delegated judgment,
independently select an empirical evidence boundary replacing exhaustive opaque
descriptor-event certification with an explicitly limited argument: complete owned-credit/admission events; exact native-call
entry/return/value/error/freeze envelopes; and independently observed listener,
grant-store and authorized action outcomes. A private-adapter ledger cannot
certify hidden native calls; raw tracing, if independently validated, remains
supplementary and must disclose decoded families and loss. Polling establishes
no transient-event claim and is not a passing instrument for hidden acquisitions.

The test instrument records pre-backoff accept IOError, selected delay,
schedule/cancel and actual resumed read at the real NIO event points. Preserve
the production bootstrap order, forwarding suppression and delay. A handler
installed only downstream is invalid. Fixed/preallocated event storage with
operation/thread/search/cohort identities, monotone sequences and explicit
overflow/unmatched-span controls avoids logging opens during the subject.
Lost owned/hook events invalidate the subject. This instrumentation is compiled
into the normally signed test build with unchanged entitlements/identity/launch;
it requires no injection or target attachment. The integration and observer
equivalence still need construction and review, not a verdict from this document.

| Discriminator / subject | Required observable outcome under the selected design |
| --- | --- |
| Nil identifier with later successful stat/access; nil/nil, empty/errorful registration or not-found code in another domain | Null identifier/UNKNOWN with affecting coverage, or resource refusal when established. No invented no-identifier fact or UNREGISTERED. |
| Adapter reports not-found/nonmatching array while a resource event is explicitly associated with the observation | Refuse negative finalization and latch the cohort; earlier finalized/frozen candidates stay unchanged. Suppressing the error input must make this control fail. |
| Same normal-looking registration answer with an internal failure invisible at the selected boundary | The selected observation cannot distinguish it from a normal negative. This is the disclosed first decision's residual risk; it must not be labelled a passing hidden-health test. |
| Healthy registered real Safari/Finder; genuinely unregistered fixture and separate copies sharing an identifier | Required launch selectors/checked identity, real UNREGISTERED observation and distinct-copy choices. All-UNKNOWN metadata or reveal-only coverage cannot pass the configured application workflow. |
| Owned transient open/close between occupancy polls; deliberately dropped owned event | Event ledger observes the transient and rejects the dropped-event subject. It proves owned instrumentation only, never opaque completeness. |
| Synthetic pre-backoff accept error suppressed downstream; real accept resource failure | Both the error and actual scheduling/read behavior are visible even if a fresh client later succeeds. Missing/dropped hook events invalidate the run. Real normally launched exhaustion/control remains mandatory, not inferred from injection. |
| Four searches with blocked listing/metadata/canonical work while fresh clients query, change grants and perform authorized launch/open/reveal | Record each independent completion/error and every accept pause. An independent resource failure or accept backoff during this subject fails conservatively; an attribution gap cannot certify isolation. No general latency target or proof of invisible FD peaks is claimed. |
| No-search reference under matched launch, fixture and independent demand | Establish the reference's actual behavior and resource/backoff signals. If it also fails, classify unrelated demand/inconclusive comparison; it cannot convert the search-run failure into a pass. |
| One indefinite native span plus another job's EMFILE/ENFILE, then provider restart and process restart | Disabled guidance, no replacement/retry/new search, retained Q across provider restart; finite late returns close once. Only a new normally launched process resets local ownership, with successful admission conditional on its current L/resources. |
| Finite/infinite/unknown/lowered/higher limits, reserved credits versus current occupancy | The unchanged admission and cohort cases above, including the surviving summed-Q predicate and higher-limit nonrecovery. System-wide demand and unrelated overload remain disclosed limits. |

Useful coverage, prompt behavior, canonical races/size grouping, all original
FIFO/witness/binary/compatibility subjects and the operator's separate measured
home-omissions decision remain mandatory. No observed independent error is waived
because clients eventually reply; the selected change is the **visibility and
scope of the evidence**, not permission to accept observed search-caused failure.
An incomplete opaque trace supplies no hidden-resource proof. Under the selected
empirical boundary, a passing controlled subject certifies only its observed
outcomes and complete applicable owned/hooks events, not absence of transient
opaque demand or all possible native false negatives. Missing applicable events
or inconclusive independent controls still cannot pass.

##### Observation boundary decision questions

Antony instructed "you decide" after the first question was presented. Under
that delegation, resolve the remaining requirements choices separately below;
do not attribute a personal yes to an unasked second question. The decisions
retain native semantics and configured launch usefulness within the approved
posture. Their justification is the documented API boundary and present evidence
gap, not a demonstrated normal-search failure or necessity for isolation.

1. **Selected native-result meaning, including registration and other metadata.**
   UNREGISTERED means the checked reported service observation described above,
   permitting an undetected internal-failure/stale-service false negative without
   proof of internally healthy work. Nil identifier always remains UNKNOWN with
   affecting coverage; malformed/errorful/incomplete/blocked/conflicting results
   cannot establish a negative. Reported or associated resource errors refuse it.
   This selection also covers reported native type/package/hidden/alias values
   and positive identifiers; an undetected incorrect fact could omit a name or
   misclassify its disposition. Known incorrect witnesses and all-UNKNOWN
   configured launch coverage still fail. The exact not-found domain/code and
   actual-call prompt/identity behavior remain native acceptance obligations.
2. **Independently selected serviceability-evidence boundary.** Complete applicable
   owned/hook events, exact native-call envelopes and controlled independent
   real listener/store/authorized-action outcomes may establish empirical
   acceptance while opaque acquisitions, peaks, lifetimes and swallowed errors
   remain unproved. Observed independent resource failure or accept backoff fails
   conservatively, including when later replies succeed. Lost applicable events,
   attribution gaps and inconclusive runs cannot pass. Existing GraphQL,
   native-provider and normally launched signed-host VM seams are retained;
   inspection controls and listener/backoff hooks work inside those seams.

Only these two guarantees change. Q/S, two temporaries, inherited limits,
worker-only freeze/late-return/cleanup/restart ownership, signing, consent,
search domain, authority, public version and compatibility remain binding.
Native prompt acceptance, real Safari/Finder launch usefulness and the separate
measured home-omissions decision remain mandatory. No helper, new content reader,
permission, smaller domain or all-UNKNOWN launch acceptance is selected.
The in-process allocation design above completes the remaining call, copied-value,
two-credit, freeze and recovery contract within these two scopes. The
[native-fact decision](../adr/search-native-facts-are-reported-observations.md)
records its durable public meaning. The observable handoff below gives
the serviceability producer the remaining construction obligations. Subject construction
and mandatory complete-resource review still precede planning. These decisions
are requirements selections, not implementation or native/binary/workflow
acceptance, and no released contract meaning or version changes here.

##### Serviceability construction handoff

The serviceability producer receives this finalized allocation contract, the
canonical-directory contract and the unchanged three test seams. It must
construct the instrument and executable subjects, reconcile their evidence
limits, then cut the mandatory complete-resource review before planning. The
following are required discriminators, not results already obtained:

| Subject / seam | Observable falsifier and required control |
| --- | --- |
| Controlled private adapter through the actual provider binary and independent GraphQL client | Exercise every value/error combination above, exact/foreign-domain not-found, cycle/17th error, oversized strings/URLs, malformed/incomplete arrays, blocked preferred checks and conflicting identities. A negative after uncertainty/resource input fails. Check null fields and affecting coverage together; an unrelated mock accumulator or SDL-only validation cannot pass. |
| Two-temporary ownership and freeze through that same actual provider | Hold every root stream, walk a registration target while the original candidate is released, and reacquire the candidate. Attempt a third temporary/borrowed root credit; mutate the candidate between walks; freeze immediately before and after admission/finalization; return late success and EMFILE. Wrong owner/charge, post-freeze commit, lost late latch, duplicated close, retry or replacement fails. Close-failure controls must retain refusal across provider restart. |
| Native reported results in normally launched signed hardened Koine | Record actual all-registration CFArray/error domain/code and separate preferred result for registered Safari/Finder, a purpose-built genuinely unregistered bundle and distinct copies sharing an identifier. Independent fixtures/witnesses establish expected paths/identifiers and constrained launch. Wrong known witnesses, unsupported not-found normalization or all-UNKNOWN launchers fail; undetectable hidden health remains a disclosed limit, never a passed control. |
| Native policy/identity/domain through independent GraphQL and signed-host VM | Run actual package/hidden/alias/type/Bundle/registration URL checks, protected Library/application links and long/canonical/native-size witnesses under the existing policy. Observe calls and UI, no content/hydration, register writes, alias resolution or consent dialog. A prompt, silently shortened supported domain, canonical fallback or useful-launch loss fails. Retain k93's separately measured home omissions decision. |
| Owned/hook completeness in the normally signed instrumented host | Preallocate a finite event sink before the subject; identify process/thread/attempt/search/root/cohort and independent operation, global or per-producer monotone sequence and explicit overflow. Record attempt reservation/result/transfer/close/release, limit/refusal/worker changes, native entry/return/error/freeze and finalization; a pending span at freeze is explicit rather than silently unmatched. Deliberately omit an owned transient open/close or an accept hook and overflow the sink: each must invalidate the run. Export after the subject; no logging file opens or growing strings during it. |
| Real NIO accept suppression and backoff | Capture upstream IOError before suppression and actual delay selection, scheduling/rescheduling/cancellation and context.read resume, including inactive/removed cases. Use the exact dependency revision and preserve order/delay/suppression. Synthetic error injection proves hook placement; real accept exhaustion in the normally launched signed host proves the socket path. A downstream-only observer, missing applicable event or inference from eventual success fails. |
| Four saturated searches plus independently driven actual listener/store/actions | While finite and indefinite listing/metadata/canonical spans occupy four workers, independent clients make fresh connections and queries, durable grant operations and authorized launch/open/reveal with witnesses. Pair a no-search reference under matched demand/launch/fixtures. Record outcomes and latency without inventing a target. Independent resource error or accept backoff fails conservatively even after later success; failed reference, attribution gaps or incomplete controls are inconclusive, never passing. |
| Limits and refusal recovery through provider and normal process restart | Cover the reservation table, low/high refresh with C distinct from occupancy, finite cleanup, indefinite span beside another job's resource failure and unknown limit. No request joins or retries a latched cohort. Provider restart must retain it; fresh normal process may admit only after reading its current limit. System-wide ENFILE and unbounded unrelated overload remain outside a general serviceability guarantee. |
| Retained action-only and upgraded search binary subjects | Keep retained workspace 1.0.0 host/provider/SDL/profiles independent of search 1.1.0 subjects, with unchanged authority/selection feature and error mapping. A historical capture, rebuilt old subject or subset-schema success cannot clear search compatibility. |

The instrument contract is implementable inside the host and dependency test
build under the existing normal signature and entitlements; it requires no
kernel attachment, injection, helper or diagnostic launch. Subject construction
must show passive-hook equivalence, identify the build/dependency/signing/OS
and frozen inputs, and prove loss controls can fail. Its fixed diagnostic
storage/overhead is test instrumentation, disclosed separately from production
accounts; an instrument that changes pipeline behavior cannot pass by observing
its own replacement behavior. Native-call envelopes and complete applicable
owned/hook events still leave platform descriptors, RSS, asynchronous work and
swallowed errors unproved. Supplementary raw tracing cannot expand that claim
without its own visibility/decoding/loss evidence.

No success here accepts arbitrary sampling, reduced home/application workflows,
new setup/consent/signing, larger accounts or changed limits. The contract is
ready for construction and whole-resource review; all native, compatibility
and useful-coverage verdicts remain pending.

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
| Measured-shape controlled order: home lists Development, five later depth-1 witnesses (Pictures, Zotero, Sites, Applications, nix-migration.md), and four protected anchors. Development has 36 project directories (EarlyBranch at position 12; ModalAnyware, Modaliser, TestAnyware and Koine-workspace after it) plus development-depth2.txt. First eleven projects each have one marker. EarlyBranch has 200,001 entries: Deep first, early-depth3.txt second and 199,999 files; Deep has deep-needle.txt. Later 24 projects collectively have 199,951 files including named per-project markers. The four later ordinary home directories each have one named depth-2 marker. A later explicit root is EarlyBranch/Deep | Development has exactly 400,001 descendants (36 + 1 + 200,001 + 1 + 11 + 199,951). All five depth-1 witnesses, development-depth2.txt, all 36 depth-2 project anchors and the four other home directories' depth-2 markers precede EarlyBranch listing and are observed. With the controlled order/clock, 62 entries precede EarlyBranch, whose first 99,938 entries reach ENTRY_LIMIT: early-depth3.txt is observed; later project depth-3 markers and deep-needle.txt at depth 4 are omitted through home. The explicit Deep root returns deep-needle.txt with only its observed rootIndex. Query each witness individually; native order/wait and omissions are measured separately and remain unaccepted. |
| Separate wide depth-2 sink: the same ten-entry home root; Development lists EarlyBranch, development-depth2.txt, then 199,998 named files. EarlyBranch contains 200,001 files including deep-needle.txt first. Each later Pictures/Zotero/Sites/Applications root-child directory has one depth-2 marker; later explicit root is EarlyBranch | All five later depth-1 witnesses and development-depth2.txt are observed. ENTRY_LIMIT cuts Development after 99,990 entries (99,988 of its files); dev-file-199998 and all four later depth-2 marker files are omitted, as is home deep-needle.txt. Its explicit EarlyBranch root returns deep-needle.txt. This exposes native-order loss within depth 2 and starvation of later depth-2 listings, not only depth-4 loss. These are explicit k93 decision inputs, not accepted coverage. |
| 16 admitted responsive roots, each with a 31-directory chain and a final known file; four jobs | Every root gets cyclic turns and its known deep file; no frontier/depth omission. Q = 18/job, 72 credits total, at most 64 current streams + 8 transient descriptors. At L = 256 the owned account fits, with 184 descriptor slots outside maximum search occupancy; this is arithmetic, not native serviceability. |
| Descriptor allowance below a job reservation | At L = 160, S = 32: one 16-root job reserves 18, a second refuses all roots with CAPACITY_LIMIT and no opens. At L = 128, S = 0: every job refuses. Limit inspection failure instead uses INSPECTION_FAILED. No-progress mixtures with prompt risk obey FAILED precedence. |

Short ASCII fixture paths keep the nonoverflow shapes within traversal and reserved coverage
bounds. Add long-path, invalid-name and native exception variants separately;
invalid/value parent groups and exact failures can exhaust diagnostics even
though the reserved frontier/depth groups cannot. Run individual witness queries
so result-count ranking cannot obscure traversal. Controlled accounting tests use
8,192-byte paths (43 fit, task 44 byte-refused) and the independent 512-task count
boundary with short paths. These maximum values do not establish native directory
reachability. Public fsgetpath's NUL-inclusive buffer returns at most 8,191 text
bytes; the [canonical native subjects](#canonical-path-acceptance-subjects)
instead construct a 4,096-byte root and 4,224-byte child tasks (79 fit, task 80
byte-refused), plus the short-path count boundary. No VM subject is credited for
the synthetic maximum shape. Inject concurrent atomic admissions, open/dup failure, transferred
stream ownership, limit reduction, opaque platform demand and cohort-wide native
resource failure. A controlled ledger proves the accounting rules, not native
isolation. A normally launched host saturation subject must demonstrate listener
requests, grant-store work and authorized actions stay serviceable using the
call/instrument contract required by search-native-resources-k109. Record
effective soft limit, reserve, credits, owned occupancy, complete applicable
owned/hook events, native-call envelopes and independent resource/backoff
outcomes. Opaque acquisitions/peaks remain unproved under the selected evidence
boundary; polling supplies no transient high-water proof.
Combine an indefinitely blocked call with another job's native resource failure
and verify new jobs remain disabled until process restart. Instrument component
walk/canonical/turn-check counts and elapsed shares on all chain and realistic
small-directory subjects; do not infer wait consumption from entry totals.

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

### Canonical path acceptance subjects

All subjects remain pending. Use the existing controlled private adapter, an
independently built real workspace provider through public GraphQL, and the
signed hardened normally launched macOS host in an isolated VM. A diagnostic
build may record barriers/calls but must preserve the host identity, grants,
entitlements and three-second wait. The independent client asserts public
results; a sequence-numbered native trace records actual calls, lengths,
captured errors, association checks, queue charges and checks, reads and
publication. It is an instrument, not a substituted canonicalizer. Its controls
must reject truncated output, a 1,024-byte buffer, fabricated fsids, stale queued
inode lookup, missing rechecks and per-task prefix failure fan-out. Independent
fixture and dialog/hydration observers do not credit Koine's own report of success.

| Subject | Controlled adapter / independent provider-GraphQL assertion | Signed macOS construction and observing instrument |
| --- | --- | --- |
| Root admission and native size | Requested 4,096 accepted and 4,097 rejected before calls. Canonical success counts include NUL; 8,191 text bytes succeeds, full-buffer ENOSPC yields requested-path VALUE_LIMIT remainder/null resolvedPath. EINVAL/EIO/ENOENT, truncated/invalid UTF-8 output and unknown capabilities yield uncertainty, not size/absence. No-progress failure beats PROMPT_RISK. | Component-relative helper builds measured roots above 1,024 and at 4,096 bytes; create short checked aliases to 8,191/8,192/longer directory text without making an overlong kernel pathname argument. Helper and adapter independently record fstat/fstatfs identity, actual syscall size/count/errno and bytes. Unreachable lengths or early wait failures stay pending, never substituted smaller fixtures. |
| Actual-parent size groups and prefix stop | Many full-buffer target refusals beneath one established stable parent produce one VALUE_LIMIT CHILD_GROUP and exact anchor count, no successful candidates. Changed/uncertain association takes precedence. A queued prefix/current stream size refusal stops the root once; 512 dependent tasks do not create 512 INSPECTION_FAILED records. Prior observations/groups survive; no further reads/opens follow observed refusal. | Construct long-component chains and wide sibling sets with mkdirat/openat, checking native component limits. A mover plus diagnostic next-turn/mid-walk barriers relocates a current/prefix directory so its path no longer fits. The trace and GraphQL show one remainder and no post-refusal I/O. Native parent grouping is credited only when the actual parent and full-buffer refusal are independently established. |
| Reachable queue bytes and count | Synthetic 8,192-byte tasks prove 43/44 arithmetic only. Measured 4,224-byte tasks charge 4,736 each: 79 fit, task 80 byte-refused. A separate 128-byte/513-child shape binds at 512 by count. Anchor matches precede queue omission; markers follow the captured admitted order. | Canonical root exactly 4,096 bytes, 100 distinct 127-byte child names with markers: all 100 anchors remain observed, 21 frontier anchors omitted if the fixture completes within the real wait, and first 79 marker subtrees scheduled. Trace observes the actual byte check; independent client queries each marker. A short padded native root makes 128-byte paths for the count subject. A time/resource stop does not certify either boundary. |
| Firmlink, case, Unicode and policy witnesses | Differing preliminary spellings for one unchanged identity produce one canonical path and merged membership. Native text is preserved; invalid bytes are not repaired. Synthetic protected/cloud scopes use canonical-home components without opening excluded directories. | Startup pair home/Data aliases and Applications/Data aliases; actual Preboot Safari and CoreServices Finder; differently cased/NFC/NFD link routes to one permitted bundle. The helper observes actual names/identities and the client checks paths/rootIndices. Trace every root/current/queued/bundle/opened-witness producer to the same fsgetpath route. Independent dialog/hydration witness watches Desktop/Documents/Downloads/Library Mail aliases and intervening component aliases. A dialog requires redesign. |
| Queued/current movement, deletion and identity reuse | Hold the descriptor throughout fsgetpath and before/after fstat/fstatfs. Inject path/identity/mount/association mismatches, ENOENT without mismatch, reused inode/fsid values and cancellation between calls. Never resolve a queued number before reopening/rechecking it; no stale fallback or new call after freeze. | Move current/queued directories across admitted/protected roots at barriers; replace or unlink a target while its descriptor is held and again after queueing closes it. Compare helper before/after identities, adapter call order and returned GraphQL paths. If actual reuse is not obtained, record that limit; the controlled reuse discriminator still must pass. Residual ABA/check-to-open behavior remains a platform limit, not proof of atomic identity. |

Keep per-file input/export digests and per-witness results. The
[call analysis](../verification/search-canonical-paths.md#constructible-subjects-and-instruments)
records construction arithmetic separately from outcomes. These subjects add no
new product seam or native acceptance chain. Resource-call health/serviceability
instrument design remains separate, and all observed omissions remain inputs
to the existing home/application workflow decision.

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
host must establish the selected empirical serviceability acceptance under this
allocation, without certifying opaque acquisition peaks; no limit change is
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
8,192-byte controlled task charges 8,704 bytes, so 43 fit, including the dequeued in-flight
task until inspection completes. A 128-byte task charges 640 bytes, so the
512-task count ceiling wins before the byte ceiling. This is conservative
value-account arithmetic, distinct from the constructible 4,224-byte native
task shape (4,736 charged bytes: 79 fit within 375,040, task 80 does not).
Native execution and the canonical design review remain pending; native
boundaries must be observed rather than inferred from this arithmetic.
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
they establish no atomic binding. A current stream moved between turns is
refused before the next entry/EOF read and path-based metadata; held walk parents
are also checked before child open; descriptor-location inspection itself must be established prompt-free
on the actual moved descriptor. A move after the last check but before open,
symlink races, mount changes and platform metadata behavior remain limits.
The remaining check-to-read/check-to-open race is not accepted as a no-prompt guarantee;
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
| Wide realistic layouts / later-root scheduling | The measured-shape 36-project/position-12 subject returns later depth-1 and all depth-2 project anchors plus four depth-2 home markers before ENTRY_LIMIT; later project depth-3 markers and depth-4 deep-needle are absent through home. Its explicit Deep root returns the needle. The separate flat depth-2 sink omits dev-file-199998 and the four later depth-2 markers. The 5,000-child subject returns all anchors and first 512 markers, FRONTIER_LIMIT count 4,488. Query each witness to avoid ranking loss. | Controlled native order/clock verifies FIFO depth order, both turn ceilings and single name listings. Record repeated component opens/canonical calls/turn checks and elapsed wait: 496 opens/chain, 15,872 in the depth-anchor fixture, 7,936/job for 16 chains before other calls. Verify every named retained/omitted witness, queue charges and thirteen coverage shapes. Exact search-required/action-only profiles remain distinct. | Actual home/default and measured-scale trees record native order, each shallow/same-level/deep/later-root witness, reasons, coverage and elapsed shares of entry work versus component/canonical/turn checks. Use adapter event counters/timestamps, not entry totals as a performance proxy. Real Safari/Finder and protected Library-link calls remain pending; k93 must assess actual queue/entry/depth/value/deadline omissions. |
| Exact scope groups / exhaustion | Invalid/overlong names have actual-parent CHILD_GROUP and omit anchor names. DEPTH_LIMIT and FRONTIER_LIMIT are separately reserved root groups counting observed matchable anchors, not descendants, with depth precedence even for empty anchors. Stop uses REMAINDER/null count; only progress adds a searched record. | 512 short tasks fit; task 513 frontier-refused. Controlled 8,192-byte values admit 43 tasks; task 44 is byte-refused. These are accounting subjects, not evidence of native path reachability. No eviction/retry; siblings stay matchable. Freeze preserves charged queued/in-flight paths and prior diagnostics. Thirteen shapes/16 rootIndices/fifteen witnesses fit; witness overflow refuses all roots before turns. | The [canonical subjects](#canonical-path-acceptance-subjects) separate synthetic 43/44 arithmetic from native 4,224-byte tasks (79/80 byte boundary), 128-byte tasks (512/513 count boundary), and full-buffer size refusals. Canonical review and all native outcomes remain pending. Actual APFS short/wide/depth fixtures use adapter charge/check counters; record each witness/path occurrence and refusal check. Invalid bytes/alternate layouts remain controlled subjects. |
| Shared process descriptor serviceability | At L=256, four 16-root jobs reserve 72 credits; a fifth refuses on workers. At L=160, S=32: one Q=18 job fits and a second refuses on descriptors. At L=128 none fits. A refresh S′ below summed surviving Q reservations latches CAPACITY_LIMIT for scheduled unfinished roots/new jobs even if occupancy is lower; a higher read does not resume that cohort. Native resource failure uses INSPECTION_FAILED and disables new inspections/jobs until cleanup. | Shared owner across provider instances races whole worker/credit acquisition and charges/transfers/closes. Cover 128/160/200/256/infinite/unknown; lower S below reservations while occupancy still fits, then raise it and prove refusal remains until cleanup. Combine EMFILE/ENFILE with one indefinitely blocked cohort call; free workers do not enable new search, provider restart does not recover, fresh process does. Inject opaque failure with empty/nil answers: no positive absence fact. Simulations do not prove serviceability. | Native calls/error normalization and the owned/admission, listener/backoff and native-call instrument contract are finalized above; construction of complete applicable hooks/subjects and the whole-resource review remain pending. The instrument must fail owned transient-open/dropped-event and NIO suppressed-error controls; opaque events/peaks remain unproved under the selected boundary. Normal signed launch retains inherited L; four saturated searches/blocked metadata run beside independent fresh listener connections, grant-store work and authorized actions. Record event/margin/outcome/latency per operation; any search-caused resource failure or accept backoff fails even with later successful responses. Polling/error-free replies/shell-raised limits cannot pass it. |
| Cancellation during a blocked call | Freeze once with TIME_LIMIT when publishable; external cancellation may have no response. Late work changes no counters/matches/groups/coverage. Queue/stream/credits survive until worker cleanup. Resource refusal plus an indefinitely blocked cohort explicitly disables new search until process restart; guidance distinguishes that from ordinary busy admission. | Separately block listing, registration, component and canonical calls with multiple streams/nonempty FIFO; combine one indefinite block and another job resource failure. Release finite calls and verify exactly-once worker close/drop, no late inspection/publication and release only after unwind. Reuse closed descriptor numbers to detect stray closes. Provider restart retains pool/ledger/latch. | Late-return cleanup/no-dialog subjects remain pending; descriptor attribution/serviceability uses k109’s selected instrument. Record owned occupancy, native-call envelopes and independent operations; opaque internal occupancy/lifetimes remain unproved. An indefinite block retains slots/credits and a resource-refusal cohort across provider restart; no replacement threads or external closes. Fresh process restores admission. |
| Current/queued parent moves into protected scope | File-search current streams recheck before every listing turn/read, even with no child opens. Observed current movement uses one root CHANGED_DURING_SEARCH REMAINDER. Changed/missing walk prefix or immediate parent likewise stops the root once; a changed final target gets exact SUBTREE only after its parent is established unchanged. Uncertainty uses INSPECTION_FAILED at the corresponding scope. Preserve progress/prior groups; no post-refusal entry read, stale-path publication or metadata open. | Use diagnostic turn/walk barriers and a sequence-numbered check/read/open/publication trace. Move a 100,000-entry file listing after a 64-entry turn; its next check refuses before reading. Queue 512 tasks beneath one ancestor, then rename/remove/replace it: one remainder, no per-task diagnostic fan-out or DIAGNOSTIC_LIMIT. Inject ENOENT/ENOTDIR at an intermediate parent; separately replace only a target under unchanged parent and continue unrelated tasks. Inject after-check races as limits, not atomic safety. | Actual adapter diagnostic barriers pause before a next-turn listing check and before a mid-walk parent check; an independent mover places current/queued subtrees in Documents/Desktop/Downloads/Library or outside root. Trace actual canonical checks, subsequent entry reads/metadata opens and published paths; no stale-path publication/read follows an observed refusal. Independent dialog/hydration witness tests remaining check-to-read/open windows. Use the fsgetpath identity/association rechecks and size/movement precedence; its load-bearing review and native outcomes remain pending. Prompting routes fail and require redesign. |
| Firmlink/case/Unicode canonical paths | Roots naming home and its Data-volume alias have the same resolvedPath and one file location with both observed rootIndices. App link/direct routes retain one canonical path/native identity, stable rank and false duplicate truncation. RequestedPath retains input spelling; synthetic policy targets use canonical-home components. | Supply differing preliminary realpath and final fsgetpath spellings for one identity; require the single final canonical operation everywhere. Case/component/Unicode route variants cannot fabricate CHANGED_DURING_SEARCH in unchanged observations. Unknown/overlong canonical output has affecting coverage with no fallback. | On the startup APFS pair, use home and /System/Volumes/Data/Users/<user> roots plus /Applications and its Data alias. Create differently cased and NFC/NFD-named link spellings to one permitted bundle; observe actual filesystem identity/name behavior rather than assuming separate Unicode files. Inspect root/frame/bundle/policy path production and per-choice membership with no protected open or dialog. |

Home protected traversal remains a live baseline gap: any change to consent,
entitlements or setup needs Antony's decision before reliance. The already live
protected-default-open and app-reveal-notice decisions are not resolved here.
