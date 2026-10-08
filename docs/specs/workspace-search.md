# Application and file search

**Tooling review integrated; human choices, returned design and native acceptance pending.**
Koine reuses macOS system `find` for candidate enumeration, Foundation for literal
name matching, and native application services for bundle metadata and reported
locations. Clients own presentation, chooser, ranking and MRU. The
[reuse requirement](../requirements/modaliser-workflows.md#ownership-and-existing-constraints)
replaces the earlier custom traversal candidate.

Start at the [mechanism view](../design/architecture/index.html#diagram-search-discovery).
The [finite comparison/invocation evidence](../verification/search-tooling.md)
is source analysis, not a new native measurement. Earlier
[discovery](../verification/search-discovery.md),
[metadata](../verification/protected-path-metadata.md) and
[lookup-only transit](../verification/descriptor-walk-prompt.md) observations
retain their exact subjects; none accepts system find under signed Koine.
The [SDL](../design/workspace-search-schema.graphql) and
[examples](../design/workspace-search-operations.graphql) are designed, not served.

The [permission/process decision](#permission-boundary-and-required-decision)
is open. No subprocess, lookup-only exemption, setup, signing change or weaker
protected-target policy is authorized by choosing a mechanism. Mandatory tooling
review and its earned integration precede the search node. The focused human
choices, returned permission contract and remaining applicable design/reviews
precede planning. This design runs no backend or native experiment.

## Solution and ownership

| Module | Owns | Caller contract |
| --- | --- | --- |
| Workspace search | Authorization, source selection, copied-value bounds, coverage, frozen publication | Query, roots, limit; inspect status, coverage and errors |
| Find adapter | Fixed command/arguments, NUL framing, pipes, exit/reap and cancellation | Private enabling point substitutes command outcomes in tests |
| Native application inspection | Bundle identity/name, identifier, registration, OS-reported locations | Positive, checked negative and unknown observations are distinct |
| Foundation matching | Existing normalization, folding and substring operations | Literal name query without an expression language |
| Client | Query entry, chooser, ranking, MRU, clipboard, explicit action selection | Search confers no control authority |

The adapter hides process and parsing complexity that otherwise spreads across
resolvers. It owns no directory queue, recursive walker, index, matcher or
witness catalogue. Enumeration is a finite find expression; matching calls
Foundation rather than copying a matching algorithm. Native metadata remains
in-process, so a tool child does not isolate those allocations/blocking calls.

The [enumeration](../adr/search-enumeration-reuses-system-find.md),
[coverage](../adr/search-coverage-describes-observations.md),
[application identity](../adr/application-search-uses-bundle-identity.md),
[native observation](../adr/search-native-facts-are-reported-observations.md) and
[prompt-risk transport](../adr/prompt-risk-is-search-data.md) decisions govern
search. Existing [effect authority](../adr/provider-authority-follows-effects.md),
[provider selection](../adr/first-party-provider-selection.md) and
[launch/open](workspace-launch-and-open.md) contracts govern integration/actions.

## Queries and inputs

Both nullable roots and every reachable output field require only workspace:read.
Control does not imply read. Denial precedes native work/child launch; publication
checks live authority again. workspaceSearchApplications and workspaceSearchFiles
both take query, optional roots and limit, returning choices with source coverage.

Query is at most 256 UTF-8 bytes without NUL. Empty matches all eligible names;
whitespace is literal. Roots are 1…16 nonempty literal absolute local paths, each
at most 4,096 UTF-8 bytes without NUL. Null/omitted roots uses defaults; an empty
list is invalid. No URL, shell, tilde, environment, glob or regex expansion occurs.
Non-null limit is 1…200, default 50. Invalid input fails at its original root
response path before inspection; variable coercion retains GraphQL HTTP 400.

### Roots and search domain

File default is Koine's actual home. Application conventional defaults are
/Applications, /System/Applications, home Applications, /System/Library/CoreServices
and /System/Cryptexes/App/System/Applications. Default application search adds a
separate OS-reported source. Explicit roots replace conventional defaults and
suppress discovery expansion outside them; an observed application link may
still identify its target under the permission contract.

OS-reported seeds are generic running-application bundle URLs and per-identifier
registration URLs for identifiers obtained from conventional discovery or running
applications. This can supply relocated Safari and other registered copies.
Configured launcher identifiers are acceptance witnesses, not an inventory.
There is no public enumeration of all Launch Services registrations: unseen,
non-running apps with unseeded identifiers may be missed. OS-reported coverage
is always UNKNOWN, even after finite seed processing. Empty/stale service answers
never establish an exhaustive healthy empty inventory. Explicit-root registration
inspection supplies metadata only, never extra out-of-root discovery choices.

Enumeration does not descend across devices, does not follow symlinks and emits
regular files, directories and link locations. Hidden-name subtrees and special
files are intrinsic exclusions. Known package-suffix anchors remain choices but
contents are pruned: .app, .bundle, .framework, .plugin, .appex, .photoslibrary and
.rtfd, case-insensitively. This declared suffix policy does not recognize every
native package. No ignore/config file, content, icon, thumbnail, default handler
or client configuration is read.

Desktop, Documents, Downloads, home Library descendants, known cloud storage,
Trash and unsupported/foreign roots remain policy-excluded. Report rules even
when existence was not checked; they do not prove absent consent. Optional missing
home Applications/Cryptex defaults are COMPLETE empty domains only with positive
absence; explicit missing and uncertain roots remain UNKNOWN. No arbitrary
Preboot scan is selected: an OS-reported application target is individually
inspected under the permission contract, never recursively searched as a volume.

## Permission boundary and required decision

Koine owns policy. Enumeration runs in an Apple-signed system-command child;
Foundation, Bundle and registration work run in Koine. TCC's responsible identity
for the child must be observed under normal signed GUI launch, not inferred from
executable, parent PID or test-agent permissions. Until established, command-read
diagnostics carry unknown responsible identity. A capability grants no OS consent.

Ordinary search never requests consent, invokes setup, changes indexing, mounts
a volume, deliberately hydrates content or probes protected scope to learn consent.
Explicit setup needs its separate agreement/operation. No Full Disk Access,
entitlement, usage key, privilege, custom helper signing or host/child descriptor
limit change is selected.

Four focused choices remain for the human before returned permission design:

1. **Process scope:** recommend permitting one ordinary Apple-signed system-find
   child per admitted job, with unchanged signing/limits. k115 rejected a custom
   isolation helper; k190's reuse requirement did not answer this different
   proposal. The concrete child-refusal alternative is FileManager enumeration with
   Foundation matching: localized errors/pruning and no child attribution/pipes/reap,
   at the cost of unkillable blocked Koine calls and unmeasured long-path behavior.
   libc fts with FTS_NOCHDIR is a lower-level reuse alternative with whole-path
   PATH_MAX costs. Either requires returned design and mandatory review.
2. **Protection scope:** prune/no-follow/same-device flags cannot prove protection
   of relocated sensitive targets, unknown cloud aliases, root-component links
   or replacement races, nor case/Unicode/Data-root spelling aliases. Prune and
   device checks may follow protected-anchor or foreign-mount metadata contact.
   Retain known protected-target identity protection where
   required. Decide whether bounded lookup-only acquisition of policy/application
   target identities is allowed in search and whether the residual platform
   relocation/replacement limit is acceptable. k174 is bounded transit evidence,
   not an exemption. Refusal requires an explicitly agreed setup/domain contract
   or another backend; no silent literal-only blocking or all-home refusal.
3. **Home ordering:** the unsorted preorder deep pass can exhaust the time/record
   budget in one subtree before later shallow siblings. Decide whether to accept
   that explicit order limit or return a reviewed find-backed shallow pass before
   deep search, or immediate-child source scheduling. Those alternatives cost
   repeated processing or source qualification/accounting. Recommend a returned
   shallow-pass design before implementation unless named losses are acceptable.
   No new source structure or workflow loss is selected here. k93 still decides
   actual omissions separately from protected-scope exclusions.
4. **Dataless policy:** choose process-wide materialization OFF, affecting all Koine
   work and future children, versus verifying inherited effective policy and refusing
   unknown/enabled policy. Recommend verification/refusal first, with any required
   global pin separately agreed. The documented default is OFF, not a guarantee
   about opaque services/cloud aliases. k191 must specify child/native settings,
   failure/withheld-listing coverage and hydration controls. No setting is changed here.

The selected route is concrete; its process permission/protection premise is not
approved. The original lookup-only witness question therefore still matters for
policy/native application targets. Custom queue/prefix-replay/mount-generation
algorithms no longer apply to find. A general filesystem proof engine is not a
fallback. Even find's device check may contact/block foreign metadata first.
The returned design must qualify roots and exclusions before any actual query.

## Matching and returned locations

Normalize query/keys to NFC, use Foundation case/diacritic-insensitive folding
with fixed en_US_POSIX, normalize again, then Foundation literal substring
comparison. Files use final name including extension; applications use resolved
target bundle filename and its stem after one terminal .app is removed. User
input never becomes predicate/regex/glob syntax. Native Unicode controls must
verify the library behavior; failure does not authorize a custom matcher.

Return source-observation order; there is no stable lexical, breadth-first,
exact/prefix rank or top-N guarantee. Client ranking/MRU may reorder the bounded
choices. The former ranking and shallow-name order were candidate mechanics,
not a released contract. The current depth-first home pass risks repeated later
shallow-name starvation; k196 decides that premise before implementation.
Real home/default omissions still need human acceptance.

File paths preserve absolute bytes emitted by find. Normalization affects only
matching. No unique canonical filesystem spelling or firmlink-alias collapse is
promised. Exactly equal retained UTF-8 path bytes merge source membership;
Swift String canonical equality is not that comparison. Distinct byte strings
may name one file. Final link locations remain links. Native metadata can race;
paths are observations, not pinned identities or resource references.

Application inspection establishes native bundle directory identity and resolved
target spelling. Link/direct/OS routes to that identity merge while retained;
distinct copies sharing an identifier stay separate. Keep first finalized spelling
and only observed source membership. Refused targets prove neither identity nor
registration absence. Reuse existing bounded location resolution only for individual
application/policy targets after its search use is permitted; it does not enumerate
search trees. Native case/Unicode/firmlink/copy controls remain necessary.

Returned path ceiling remains 8,192 UTF-8 bytes. Overlength/undecodable records
are omitted with VALUE_LIMIT/UNREPRESENTABLE_NAME root REMAINDER, without fabricated
child paths or shortened spellings. Representable file names do not require a
Koine canonical-directory descent. Tool long-name failure is diagnosed, never
absence. Metadata length limits may withhold fields/application identity, but
cannot silently withdraw a representable ordinary file name.

## Native application and file metadata

k123 must define the directory/link/OS records admitted to native recognition and
a finite per-job call budget including component resolution, resourceValues,
Bundle, registration/preferred lookup and expansion. Suffixes only filter
candidates; they never establish native identity. Links require target-based
recognition before matching, so filtering only link names is unsound. Copy/URL
limits and deadlines do not bound blocking calls. ENTRY_LIMIT REMAINDER records
admission exhaustion without withdrawing representable ordinary file names.
The exact candidate set/budget and useful-launch consequence require returned
design and mandatory review before implementation; no smaller domain is accepted.

Public application/type/alias facts and Bundle identifiers remain native.
Use error-bearing per-identifier registration results, cross-checked with preferred
NSWorkspace location. An established present identity with matching registration
supports INSTALLED. Exact checked native not-found, or complete checked nonmatching
results without errors/conflicting preferred observation, support UNREGISTERED
under the [native observation decision](../adr/search-native-facts-are-reported-observations.md).
The selected public registration function is deprecated; verify availability/error
behavior on supported macOS. If unusable, keep UNKNOWN and escalate useful-launch
coverage instead of manufacturing negatives.

Nil identifiers, nil/empty errorless responses, refused/unexamined URLs, malformed/
truncated results, resource errors and conflicts are UNKNOWN with affecting coverage.
They prove neither absence nor service health. Established bundle identities with
unknown metadata stay reveal/copy choices; unestablished target identities are
omitted. Wrong known witnesses and all-UNKNOWN configured launcher metadata fail
acceptance. Reads never register, install or launch applications.

File kind/type/open disposition are optional prompt-free native observations.
Unknown fields never permit inspection of blocked scope. Applications, native
aliases and typed executables are REFUSED for opening; unacquired type is UNKNOWN.
No document default-handler lookup occurs: UNKNOWN handler, null application and
guidance remain uniform. Existing actions reclassify independently.

## Coverage and aggregate outcomes

Coverage rows identify each effective filesystem root and the default OS source.
rootIndex is the row's index; source is FILESYSTEM_ROOT or OS_REPORTED. OS rows
have null requested/resolved paths. examinedEntries counts complete decoded
candidate records/native seed candidates actually considered, not every filesystem
entry or native operation. No completed-directory/EOF count is published. Choice
rootIndices contain only sources that actually observed that retained choice.

Except positive optional-root absence, COMPLETE requires a qualified filesystem
root, the command's exact-root depth-zero directory marker, normal exit 0,
fully drained pipes,
no warning/error and no affecting policy/work/value/metadata omission. It describes
eligible-domain processing on that run, not an atomic snapshot. Such a zero-candidate
root is healthy empty. The marker is neither a match nor examinedEntries progress.
Missing marker or potentially withheld dataless listing cannot establish healthy
empty; k191 supplies link/file/trailing-slash/replacement and effective-policy rules.
A marker cannot pin identity or certify atomicity. PARTIAL means observations plus
omissions. UNKNOWN means
no useful candidate observation or unestablished completeness; OS_REPORTED is
always UNKNOWN. Home remains PARTIAL/UNKNOWN under the protected-scope policy.

Searched SUBTREE describes COMPLETE processing; OBSERVED_DESCENDANTS asserts only
candidate observations. Skipped ENTRY is an independently identified candidate;
SUBTREE is a policy scope; REMAINDER is unfinished/unlocalized source work.
Stderr is diagnostic text, not a reliable path/errno protocol: unlocalized errors
are INSPECTION_FAILED REMAINDER, never guessed ACCESS_DENIED or PATH_NOT_FOUND.
No counted exclusion groups, unseen descendant counts or FRONTIER_LIMIT claims
are inferred. Non-affecting DOMAIN_EXCLUSION describes declared hidden/package/
link/special rules. Prompt/cloud/mount/work/native omissions affect coverage.
The same-device rule declares foreign descendants outside the intrinsic domain;
report that rule without asserting an observed mount or count. Known unsupported
root/target refusals remain affecting MOUNT_BOUNDARY/UNSUPPORTED_VOLUME. Exit 0
alone never proves completeness without the root/policy and full-drain conditions.

### Skip reasons and producers

Each reason supplies guidance and source coverage. Affecting reasons prevent
COMPLETE; without progress their class determines failure → prompt → absence/
dependency precedence. Authorized native qualification is governed by k191, not
an extra lookup permission. Never localize errno from command text.

| Reason | Producer and extent | affectsCoverage; no-progress class |
| --- | --- | --- |
| DOMAIN_EXCLUSION | Declared hidden/package/link-descendant/special/same-device rule; SUBTREE or independently identified ENTRY, no guessed observed mount count. | false; domain only |
| PROMPT_RISK | Known prompting root/anchor listing refusal; SUBTREE or identified target ENTRY, with UNKNOWN-consent permission guidance. | true; prompt |
| CLOUD_SCOPE | Known cloud/FileProvider policy exclusion; SUBTREE or ENTRY. Add PROMPT_RISK where that risk is known. | true; absence/policy |
| UNSUPPORTED_SCOPE | Known unsupported root/target scope, including Trash; SUBTREE or ENTRY. | true; absence/policy |
| UNSUPPORTED_VOLUME | Independently established unsupported root/target volume; SUBTREE or ENTRY. | true; absence/policy |
| MOUNT_BOUNDARY | Independently established disallowed root/target mount; SUBTREE or ENTRY, never a guessed find device refusal. | true; absence/policy |
| ROOT_NOT_FOUND | Authorized native qualification positively establishes missing explicit root; SUBTREE. | true; absence |
| OPTIONAL_ROOT_ABSENT | Positive absence of optional home Applications/Cryptex default; SUBTREE representing empty eligible source. | false; verified optional empty |
| ROOT_NOT_DIRECTORY | Authorized native qualification establishes file/non-admitted link root; ENTRY. | true; absence/invalid source |
| ACCESS_DENIED | Localized native qualification/metadata errno; root SUBTREE or target ENTRY. | true; failure |
| INSPECTION_FAILED | Native/stream/spawn/read/wait error, command warning/nonzero exit, missing marker or unestablished listing; localized ENTRY/SUBTREE only with independent evidence, otherwise REMAINDER. | true; failure |
| CHANGED_DURING_SEARCH | Independently observed root/target identity/type contradiction; ENTRY or root SUBTREE. Vanished find names/stderr alone do not produce it. | true; failure |
| UNREPRESENTABLE_NAME | Lossless UTF-8 decoding failure; REMAINDER with no fabricated path. | true; failure |
| ENTRY_LIMIT | Candidate/URL cap or returned finite native-call admission bound; REMAINDER. | true; failure |
| DIAGNOSTIC_LIMIT | Diagnostic count, stderr capture or diagnostic storage exhaustion; REMAINDER. | true; failure |
| VALUE_LIMIT | Path/copy value exceeds owned ceiling; REMAINDER for unretained path, otherwise identified ENTRY. | true; failure |
| TIME_LIMIT | Source/overall deadline, including later sources blocked by retained work; REMAINDER. | true; failure |
| CAPACITY_LIMIT | No process-wide job slot before work; each source REMAINDER. | true; failure |
| BACKEND_UNAVAILABLE | Fixed executable missing/incompatible before traversal; filesystem-source REMAINDER. Spawn resource errors are INSPECTION_FAILED. | true; dependency |
| NATIVE_SOURCE_UNAVAILABLE | OS seed service observably unavailable/unusable; OS-source REMAINDER. Empty response alone is UNKNOWN, not absence. | true; dependency |

Positive optional-root absence may establish COMPLETE empty eligible processing;
it does not erase another source's omission. Metadata failure affects coverage
even if a file name remains selectable. This table binds all retained SDL reasons;
returned producer changes must reconcile it and the examples.

| Status | Data, absent unrelated execution errors |
| --- | --- |
| AVAILABLE | Some considered candidate or one verified completely processed empty filesystem root. matches is a possibly empty/partial list; dependency is null. |
| FAILED | No progress/healthy empty and a native/change/stream/resource/capacity/work failure. matches is null and each selected matches alias raises failed. |
| BLOCKED | No progress/healthy empty, some prompt risk, no failure-class reason. matches/dependency are ordinary null, without search-generated error; consent remains UNKNOWN. |
| DEPENDENCY_UNAVAILABLE | Otherwise missing backend, no searchable roots or unavailable OS source. matches is null; dependency states cause, never healthy empty inventory. |

Failure precedes prompt risk, which precedes pure absence/exclusion. Progress
retains AVAILABLE with affected coverage unless corruption invalidates earlier
records, which refuses the list. Empty OS answers alone are no progress/healthy
empty. Unavailable OS service beside conventional progress gives UNKNOWN OS
coverage and useful results. Lifecycle, grant publication and core deadlines
retain Machine error paths/null propagation; surviving status never overrides
errors. Nested fields/aliases use one frozen snapshot without new native work.
resultsTruncated means an observed distinct match was omitted by result/value
retention; time/work stops alone prove no additional matching choice.

## Backend invocation and worker cleanup

Resolve the fixed system executable, never PATH, a shell or user config. Supply
one admitted literal root, no-follow/same-device options and a trusted prune/type/
NUL-output expression. The [invocation contract](../verification/search-tooling.md#invocation-and-parsing)
defines the byte protocol. No exec/delete/preview/TTY/interactive matcher/write
is exposed. Missing/incompatible backend is a dependency; no downloaded replacement
or automatic installation. Record actual system build at acceptance.
Spawn inherits only explicit stdin/stdout/stderr file actions under
POSIX_SPAWN_CLOEXEC_DEFAULT, an empty signal mask, default SIGPIPE/SIGTERM and a
new owned process group. k127 verifies supported SDK construction/failure cleanup,
including one job's EOF being independent of another blocked job.

Fixed child creation, signalling only that owned group, and exactly-once reap
are internal workspace:read search effects, including cleanup admitted at start.
They expose no arbitrary process control and add no desktop/input control effect.
The current workspace action source/whole-dylib guard forbids these imports. k127
must settle a separate guarded action/search binary boundary or a demonstrated
reachable-call-path guard with failing controls, under mandatory review before
implementation. Preserve the accepted guard until then; do not simply allow these
imports in its whole-binary check. k7/k30 carry this seam.

At most four jobs are admitted process-wide, one live or unreaped child/job.
Process sources in coverage order; within the three-second overall wait each gets
at most remaining time divided by remaining sources, passing unused time forward.
An unreaped blocked child/native call can prevent later sources starting; they get
TIME_LIMIT REMAINDER. This source scheduler is not a resumable walker or fairness
promise; useful later-root/home coverage needs measurement and human acceptance.
The single unsorted home pass can starve later shallow siblings; its premise is
a separate k196 ordering decision, not an implicit k93 acceptance.

Consume at most 100,000 records/filesystem root and 1,000 native seed/registration
URLs/job. Copied retained values are at most 8 MiB/job (results, diagnostics,
partial records, native copied values), at most 200 matches and 64 diagnostics/source.
Concurrent stdout/stderr drains each use fixed 64 KiB buffers. Partial pathname
storage is at most 8,193 bytes; drain overlength tails to NUL without retaining
them. Stderr capture is 64 KiB/root; overflow is incomplete inspection and stops
scheduling while cleanup drains. These bound owned copies/work, not opaque find/
Foundation/Launch Services memory, FD peaks or process-tree allocation.

The requested result limit keeps first matching choices but does not itself stop
enumeration: observe later distinct matches to set truncation within work/time
bounds, including after the (limit+1)th distinct match. No result-limit early stop
is selected: completion or policy/work/time/error stops determine coverage. k127
must preserve this rule or return a reviewed alternative with its coverage reason.
Clients should cancel superseded as-you-type requests; cancellation retains capacity
through actual cleanup and does not promise immediate admission.
Merge duplicates only against retained choices, without an unbounded
identity history. Reserve a source REMAINDER at diagnostic/data exhaustion. Final
root completion requires real exit and both EOFs; launcher return, one EOF or
signal/timeout never establishes success.

Cancellation, client/grant loss, provider stop and wait expiry close admission
and freeze publication atomically. Close unused pipe ends; TERM the still-owned
child group and KILL after 250 ms if unreaped. Reap exactly once, drain/close I/O
and release the shared slot only after child and native work finish. Serialize
reap/signalling so reused PIDs cannot be signalled. Late output/native values
cannot change the snapshot or start another root. Spawn/pipe/read/wait failures
close all known owned resources and diagnose affecting uncertainty.

Uninterruptible child/native work may retain a slot indefinitely. Provider restart
cannot reset the process-wide registry; all occupied slots give CAPACITY_LIMIT.
Orderly shutdown runs cleanup. Abrupt Koine death gives no macOS parent-death
promise: a blocked orphan can persist until it exits or is terminated. With default
unblocked SIGPIPE it ends at its first broken-pipe write; a blocked call has no
such lifetime bound. Koine's record cap is not a child-side orphan bound. No listener
or other job's pipe survives exec. Disclose/test the limit without a supervising
service. Host/child limits
remain unchanged. Former roots-plus-two, 72-credit and 54.282 MiB traversal claims
are inapplicable. Independent listener/store/action outcomes remain required;
command isolation is no serviceability proof.

## Selection and action handoff

INSTALLED apps with known identifiers pass identifier AND selected installation
path to constrained launch. UNKNOWN/UNREGISTERED apps remain reveal/copy choices;
known identifiers can be copied. File/folder locations pass unchanged to default/
Zed open or reveal. Clients own clipboard/MRU; both controls remain necessary for
actions, and reads never act.

### Long-location action dependency

The [v1 action boundary](workspace-launch-and-open.md#long-location-action-boundary)
stands. Actions resolve locations themselves. Missing paths retain PATH_NOT_FOUND/
APPLICATION_NOT_INSTALLED; extant literal/expanded/resolved spellings of at least
1,024 bytes without NUL fail before application handoff. Longer search locations
stay visible/copyable. Never shorten paths, drop installation constraints or retry
another copy. Protected default opening and app-reveal notice retain their decisions.

## Test seams and acceptance

Use public GraphQL, actual native binary integration and isolated signed-host
TestAnyware VMs. Command/native-inspector substitutions are private enabling
points within these agreed seams. [Finite subjects](../verification/search-tooling.md#finite-acceptance-subjects)
cover healthy empty/unavailable, byte/Unicode records, native copies/OS locations,
permission, bounds, cleanup and independent service outcomes with positive controls.
Ordinary accepted reads causing dialog/hydration fail; unavailable fixtures stay pending.

Retain independently built action-only workspace 1.0.0 and current 1.0.1 binaries/
profiles. Search adds workspace 1.1.0/schema 1.1.0 with existing additional-capabilities-v1
and first-party-selection-v1, no diagnostic ABI/feature. Create exact complete
search-required composition/profile and workspace 1.2.0/schema 1.1.0 update/refusal
variants with all candidate pins and SDL/digest. Historical profiles are not rebuilt
as historical evidence. Exercise old selection-aware host/new provider and new
host/retained provider, 1.0.1 provenance, lifecycle/revocation/aliased BLOCKED/FAILED
and existing action examples. SDL validation proves no native/runtime/binary outcome.

Before planning, consume tooling review/integration, focused human process/protection,
ordering and dataless choices, returned permission contract/node review,
applicable command-lifecycle
and metadata design/reviews, then whole-resource review. Rewritten live charters
discharge real obligations; obsolete algorithms are not marked passed/pruned.
Actual home/default omissions go to protected-home acceptance before baseline closes.

## Out of scope

Persistent indexing, exhaustive all-disk application inventory, content search,
fuzzy/interactive matching in Koine, arbitrary shell execution, custom traversal/
witness engines, automatic setup, privileged helpers and long-path app support.
Spotlight can be reconsidered with an explicitly agreed useful prompt-free indexed
domain. No broader baseline reduction follows from this design.
