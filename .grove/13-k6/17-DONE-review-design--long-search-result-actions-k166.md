# long-search-result-actions-k166

**Reviews:** long-search-result-actions-k128
**Creator:** run 85cbf064-9cb4-4de9-abca-3dd1d46003a4

## Goal

Mandatory load-bearing adversarial read of the long-search-result-actions
design as it stands after k165: the v1 long-location action contract, the new
descriptor-relative access decision and everything reconciled with them.
Findings only; no fixes.

## Context

- Producer node long-search-result-actions-k128; its final design session is
  long-action-route-k165 (read that leaf's running log and its commit diff).
- Antony's 2026-10-07 reaction in local-url-naming-k164 and GitHub issue
  Linkuistics/Koine#1: surface the failure, defer long-path application support
  past v1, Koine's own filesystem code descriptor-relative. Treat that trade-off
  as settled; review the design that implements it, not the decision itself.
- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`,
  `docs/adr/filesystem-access-is-descriptor-relative.md`,
  `docs/specs/workspace-search.md#long-location-action-dependency`,
  `docs/design/workspace-action-repair-schema.graphql`, the client guide,
  workflow trace, glossary, research bridge and the architecture viewer's
  current discussion. `docs/verification/long-action-route-prototype.md` holds
  the k134 measurements the limit and the prompt obligation rest on.

## Done when

- Every finding names the artifact, the defect and its consequence. In
  particular, attack these doubts the producer could not settle alone:
  - Does resolution really mirror the kernel: cycle detection by a repeated
    link plus remaining path, physical `..`, trailing-slash demands, following
    the final link for reveal, and `fpathconf` name limits for non-ASCII names?
  - Is "literal, every expanded remainder and resolved spelling under
    `PATH_MAX`" the right refusal predicate — could it refuse a location the
    platform would accept, or admit one it rejects, given firmlinks and the
    cryptex-volume links seen for Safari in k134?
  - Does moving copy identity from resource identifiers to the walk's device
    and inode keep every accepted multiple-copies outcome (other spellings
    match, another volume does not, Trash copy eligible)?
  - Is the search-only-handle prompt obligation, with escalation to Antony,
    an honest bound, or does the design depend on an unmeasured property in a
    way that should block planning?
  - Is `failed` with guidance, rather than a new dependency reason, sound for
    1.0.1 compatibility and for clients?
  - Do any current-state artifacts still claim an unresolved route, or did the
    rewrite drop an obligation the earlier briefs carried (short regressions,
    controls, acknowledgment, receipts, separate subjects and profiles)?
- If findings warrant action, cut the integration where `pick` reaches it next
  (before long-location-actions-k167). Otherwise retire with none.

## Notes

Earned review and any integration precede planning (long-location-actions-k167)
and every search consumer (k123/k120/k30). Native, binary, public and signed-VM
acceptance are planning's, not this review's.

## Decisions (running log)

- Review producer commit `21809e6b3a00` (`stwqmurl`) against its unchanged current
  artifacts; this session started on an empty jj change. Antony's v1 deferral
  and descriptor-relative access requirement are settled inputs. This is an
  inspection-only review: no tests, builds, lint, format, rendering or native
  experiments, and no production/design fixes or in-session reviewer.
- The graph CLI's `list_projects` failed because a pre-coordination or unverified
  generation is active. No project, generation, freshness or coverage evidence
  is available. Use exact source/document reads as fallback and make bounded
  claims; do not stop other sessions to repair the graph service.
- The hand-off predicate conflicts with its required 1,023-byte positive
  subject. The name-limit and cycle rules also need stronger evidence before
  they can establish absence. Record actionable findings and place their
  integration before long-location-actions-k167; leave all native acceptance
  with that planning chain.
- Completed the bounded adversarial read with eight actionable findings R1–R8.
  Kept the operator's refusal trade-off, existing seams and explicit prompt
  acceptance condition separate from those defects. Cut
  long-search-result-actions-k168 with **Integrates:** this review, immediately
  before the first live sibling long-location-actions-k167; the insertion
  shifted only planning's position. k6 and the grove root remain live.

## Findings

Coordinates refer to producer commit `21809e6b3a00`, which is also the current
design. `action` means `docs/specs/workspace-launch-and-open.md`; `repair SDL`
means `docs/design/workspace-action-repair-schema.graphql`. These are design
findings, not new native measurements. Each correction belongs to the paired
integration, with runtime verification left to planning.

### R1 — The NUL-inclusive limit rejects the required 1,023-byte positive (high)

**Location:** action:291–301, 365–377; repair SDL:79,83,85;
`docs/client-guide.md:538–551`; `docs/specs/workspace-search.md:2348–2352`;
`docs/design/architecture/diagrams.json:7,292`.

The predicate refuses a spelling needing at least 1,024 bytes **including its
NUL**. A 1,023-byte spelling needs exactly 1,024 with its terminator, so it is
refused. The same section cites successful 1,023-byte submission, and V requires
that document to open in its default handler and Zed and be revealed. The
diagram's "fit PATH_MAX" wording and the guide's client hint at 1,024 UTF-8
bytes introduce another reading. An implementation cannot satisfy both the
predicate and these positive subjects.

**Smallest correction:** state one count convention everywhere: the measured
submission gate accepts up to `PATH_MAX - 1` pathname bytes, or equivalently a
NUL-inclusive size **at most** `PATH_MAX`. Refusal is pathname bytes
`>= PATH_MAX`, equivalently NUL-inclusive bytes `> PATH_MAX`. Reconcile every
current description, caption, guide hint and boundary subject with that rule.
This preserves Antony's refusal decision rather than changing its scope.

The evidence sentence also overstates the shared boundary. k134's frozen
`results/state.json` measures handler/metadata paths at 1,021, 1,022 and 1,023
bytes, paired with submitted witness paths at 1,023, 1,024 and 1,025. Its next
handler negative is 1,098 bytes. `results/register.jsonl` tests short and roughly
1,500-byte registrations (with a 908-byte returned witness), not an exact
1,023/1,024 registration pair. `scripts/vm-probe-long-action.py:267–283` shows
the two different names used in the threshold sweep. Retain the conservative
v1 gate, but describe exact submission evidence separately from the other
services' bounded observations; do not present the gate as a measurement of
every service at both boundary values.

### R2 — fpathconf alone does not establish an impossible Unicode component (high)

**Location:** action:275; `docs/adr/filesystem-access-is-descriptor-relative.md:9–11`;
repair SDL:83,85. Supporting prototype: `docs/verification/long-action-route/probe.m:75–78`
and `docs/verification/long-action-route-prototype.md:34`.

The absence rule names `fpathconf` without defining its units, the lookup that
must fail first, or the treatment of an indeterminate/error result. k134's
actual inference compares UTF-8 **bytes** with `_PC_NAME_MAX`; its report
expressly limits the evidence to ASCII. This cannot be generalized to every
filesystem/name. Apple's HFS implementation returns 255 for both `_PC_NAME_MAX`
and `_PC_NAME_CHARS_MAX`, while its format allows 255 UTF-16 elements. A name
of 100 ordinary three-byte BMP characters is 300 UTF-8 bytes and only 100
UTF-16 elements. A byte-count precheck would report an extant ordinary name
missing, the very defect this repair promises to eliminate. [HFS pathconf
implementation](https://github.com/apple-oss-distributions/hfs/blob/main/core/hfs_vnops.c#L6125-L6142),
[HFS Plus format](https://developer.apple.com/library/archive/technotes/tn/tn1150.html).

Apple's DTS explanation also states why volume encoding and BSD UTF-8 limits
do not provide a universal validity predicate, including APFS. This is primary
design guidance, not a new APFS measurement. [Apple DTS discussion](https://developer.apple.com/forums/thread/726970).

**Smallest correction:** successful component lookup always establishes
presence. Only a failed lookup with a supported, filesystem-aware proof of
impossibility can establish this absence branch; otherwise preserve `failed`.
Define units and `fpathconf == -1` handling, and carry valid multibyte and
combining-name subjects into acceptance alongside the retained impossible
300-byte ASCII subject. Do not implement speculative name creation as a read.

### R3 — A repeated link and suffix omit the relative-resolution context (high)

**Location:** action:267,276; resolver evidence
`docs/verification/long-action-route/probe.m:79–89`.

An inode can have symlink directory entries in different containing
directories. Relative link text is interpreted from that containing directory,
so repeating the link identity and remaining suffix is not a repeated resolver
state. Consider `/r/l` and `/r/next/l` as two hard links to one symlink containing
`next/l`, with `/r/next/next/l` an ordinary file. Resolving `/r/l` encounters the
same symlink inode and empty suffix twice, but reaches the file in two
expansions. The stated rule calls it a cycle and reports `PATH_NOT_FOUND`.
Tracking only active expansions does not remove this counterexample.

This is a logical counterexample, not a fixture run. Apple's `linkat` permits
no-follow source lookup, and its name resolver retains the containing directory
for a relative target; rsync's upstream regression explains the APFS/HFS+
difference in symlink hard-link support. [Apple linkat source](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_syscalls.c#L5947-L5988),
[Apple relative-link resolution](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_lookup.c#L2165-L2183),
[rsync regression source](https://github.com/RsyncProject/rsync/blob/master/testsuite/link-dest-symlink-enotsup_test.py#L1-L14).

**Smallest correction:** define a repeated resolution state including the
containing-directory identity, link identity and exact pending suffix, with
the relevant directory/trailing-separator demands. An identity-only prototype
check is not the production proof. Keep uncertain repeat/change observations
as `failed`, and retain the ordinary two-link cycle and finite dot-link
regressions. Add this finite same-inode/different-parent subject at the real
resolver seam where the filesystem admits its construction.

### R4 — The table refuses after 32 expansions instead of before expansion 33 (medium)

**Location:** action:277; `docs/adr/filesystem-access-is-descriptor-relative.md:10`.

The ADR allows at most 32 link expansions, but the table makes "32 expansions
without such a repeat" itself a failure. An acyclic 32-link chain ending in an
ordinary file therefore receives `failed` even though it is within the stated
budget. Search's current contract already makes the distinction correctly at
`docs/specs/workspace-search.md:484`: expansion 33 is refused before its
readlink. Apple's counter permits the first 32 expansions and refuses the next
one. [Apple link-budget check](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_lookup.c#L2076-L2087).

**Smallest correction:** successful terminal resolution after 32 expansions is
success; discovering that a further expansion is necessary is the budget
failure. State that transition and require positive 31/32 and negative 33
subjects, separately from established cycles.

### R5 — Selection requires platform lookup before the stated universal gate (medium)

**Location:** action:262–263,291–298;
`docs/design/architecture/workspace-long-locations.d2:6–12,30–35`.

The design requires resolving each action target before **any** platform lookup,
and says an over-limit refusal occurs before registration or handler lookup.
An unconstrained launch has only a bundle identifier, so its selected path
exists only after `registeredApplication` returns. A default open likewise
learns the handler's application location only after handler lookup. Yet the
predicate also covers the selected registered application's spelling. The
universal resolve → limit → registration sequence therefore cannot implement
these accepted forms; the new view shows only identifier-plus-applicationPath
launch and hides this case.

**Smallest correction:** define staged ownership and failure ordering: resolve
and gate a supplied document/installation first; discover required registered
application/handler candidates when no location is supplied; resolve candidate
identities; gate the selected application before its pathname-based metadata
and submission. Distinguish discovery reads from the application domain request
whose absence the refusal promises. Specify how a resolved, unequal long
candidate avoids a selected-location gate, preserving the short workflow with
long copies and both enumeration orders. Reconcile the sequence/view with
unconstrained launch, named open, default open and Finder discovery.

### R6 — The repair SDL changes established dependency meanings (medium)

**Location:** repair SDL:79,83; action:62–69,221,274,281–282.

The launch description restricts `APPLICATION_NOT_INSTALLED` to resolution
finding nothing. A present but unregistered bundle and a present non-application
are also established instances of that dependency; the spec still requires
them, as do `SelectionTests.aPresentButUnregisteredCopyIsNotInstalledAndAnotherIsNotSubstituted`
and `aBundleLessProgramHasNoRouteToTheNamedSelector`. No registration returned
for an unconstrained identifier can also establish not-installed without a
pathname walk. This conflates filesystem absence with missing installation
eligibility.

The open description says it resolves the path **and any applicationPath** and
then assigns missing components to `PATH_NOT_FOUND` without preserving the
application distinction. For an existing document and missing named
installation, the established result is `APPLICATION_NOT_INSTALLED`, exactly
as the new resolution table still says. Introspection-driven clients now get
contradictory guidance about the supposedly compatible 1.0.1 output.

**Smallest correction:** distinguish the target path from an application path
in the SDL, and preserve supported no-registration/not-application negatives.
Limit the new prohibition to treating unresolved whole-path/service failures
as filesystem absence. Reconcile the generic later-nil sentence with the
explicit retained handler/identifier/registration nil meanings, without
changing shapes or adding an enum.

### R7 — Following the final link loses the reveal root discriminator (medium)

**Location:** action:268–279,307–308; retained rule
`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift:97–102` and
`docs/verification/reveal-path-vm.md:108–119`.

The new walk follows the final link and returns the resolved object's identity,
type and filesystem-root flag. The accepted reveal flag has a different
meaning: it uses final-component **no-follow** identity. A symlink to `/`,
including a volume link, is selected as the link; it does not use Finder's
`selectFile(nil, ... "/")` root-view form. Its followed identity is nevertheless
the root's. Deriving the new flag from the only documented identity silently
changes an accepted short reveal into a root view.

**Smallest correction:** specify and retain the final no-follow observation
for reveal's root decision while following the final link for presence, type
and hand-off resolution. State the trailing-slash/dot variants separately;
preserving literal submitted bytes alone cannot recover the root flag.
Retain `/`, `//`, `/.`, `/..`, physical `/var/..` and the symlink-to-root
regressions, with an independent witness of item selection versus root view.

### R8 — Positively absent registered neighbours become unknown equality (medium)

**Location:** action:283–285; retained behavior
`Providers/WorkspaceProvider/Logic/Selection.swift:98–109` and
`Tests/WorkspaceProviderLogicTests/SelectionTests.swift`,
`aStaleRegistrationBesideThePresentChosenCopyIsSkipped`.

The new rule makes every registered candidate that the walk cannot resolve
unknown equality and `failed`, "never a skipped copy". That includes a
candidate whose component walk positively establishes `ENOENT`/`ENOTDIR`.
With a present chosen copy and a stale absent candidate encountered first,
selection now fails instead of continuing to the matching registered copy.
The earlier source/tests and action acceptance retain exactly that successful
case. An uninspectable extant long candidate is uncertainty; a checked absent
neighbour is a different outcome.

**Smallest correction:** separate established candidate absence/known
non-equality from denial, hop/spelling/read failure and other unresolved
equality. Keep the latter `failed`; preserve skipping established stale
neighbours, checking both enumeration orders with the retained short-copy
subject. No alternate-copy substitution or whole-path fallback is needed.

## Checked and accepted

- Antony's v1 refusal is a settled trade-off. `failed` with stage/cause guidance
  fits the existing error kind and avoids an output-enum change. R1/R6 concern
  the conflicting boundary/reason descriptions, not a request for a new reason.
- Device/inode equality distinguishes simultaneously mounted volumes and
  alternate spellings within the documented observation/race limits. The
  current design still requires Trash eligibility and no constrained-copy
  substitution. R5/R8 concern selection ordering and negative/unknown
  distinctions, not replacing this identity choice.
- Physical native `..`, directory demands after files, final-link presence
  resolution and literal submission are appropriate obligations. k134's
  textual ancestor-stack pop at `probe.m:71–73` is not a production recipe for
  mount/firmlink parents; search's native `..` contract at search:450–477 is
  stronger. The resolved-spelling predicate must use the actually resolved
  namespace and pending link text rather than that prototype stack or a lexical
  normalizer. The Safari FSRef mismatch is explicitly recorded, not a pass.
- Search-only first-use prompt behavior is unmeasured and honestly conditional.
  The ADR and k167 explicitly require stopping and returning to Antony if it
  prompts. This need not prevent cutting that acceptance work, but neither
  `O_SEARCH` nor the earlier whole-path result proves a prompt-free new walk.
  No new native experiment, consent or fallback is authorized by this review.
- The new ADR earns its place and supplies a research bridge/revisit condition;
  the easy-to-lift application limit is kept in the spec rather than a second
  ADR. The inspected set contains no new competing public seam: the existing
  private WorkspaceNative enabling point owns provider-local substitution,
  with real binaries and isolated signed VMs supplying separate evidence.
- The current spec/guide/trace/glossary/view discussion and evidence status
  sections now state the v1 decision. Historical diagnostic bodies remain
  explicitly historical. The distinct retained 1.0.0, action-only 1.0.1 and
  search 1.1.0 profiles, independent action versus actual-search subjects,
  grants/revocation, cancellation/deadline, three-second acknowledgment,
  optional receipt and no-replay obligations remain stated. Runtime acceptance
  is pending; no historical short pass closes the repair.

## Review evidence and limits

Read the producer's focused commit, k165/k164 records, brief chain and cited
ADRs; the rewritten spec/SDL/guide/trace/glossary, research bridge, evidence
status sections and editable views; and the exact native selection, path,
reveal and receipt sources/tests needed for these claims. Inspected k134's
frozen instrument, driver and threshold/registration results. No test/build/
lint/format/render/probe was run and no design, production or test file was
changed. Primary Apple/rsync sources support semantics and counterexamples,
not new macOS 26.5 acceptance. The GitHub issue page could not be retrieved;
Antony's local k164/k165 reaction records and this review's mandate supply the
settled authorization. Graph availability/coverage limits are recorded above;
this is a bounded source/document review, not a repo-wide completeness claim.
