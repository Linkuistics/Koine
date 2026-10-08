# Search pre-open proof boundary

**Source and contract analysis; metadata-policy decision required.** This answers
which proofs the selected search route currently supplies before opening a
directory. It selects no replacement call, approves no workflow loss, and adds
no native measurement. The [witness contract](../specs/workspace-search.md#pre-open-proof-boundary)
and [focused view](../design/architecture/index.html#diagram-search-preopen)
carry the boundary. The original witness design remains incomplete; observation
phases, classification, their reviews and complete-resource review still precede
planning.

## What the current calls establish

Apple's [stat manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/stat.2)
distinguishes a link's own status from its target's status. A relative fstatat
uses its containing directory; AT_SYMLINK_NOFOLLOW returns the final link's
status. Search currently selects that no-follow, single-component probe. Thus
its device/inode can reject an unadmitted device or recognize an established
blocked directory, but a policy symlink supplies no target identity. Reading
the link text supplies a route, not an identity or confinement proof.

Apple's [statfs manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/statfs.2)
supplies mounted-filesystem information through a pathname or an already opened
descriptor. Search selects the descriptor form. Its fstatfs/fgetattrlist checks
cannot establish an unknown child's mount classification or path-from-ID
capability before the descriptor exists. Equal st_dev is no mount-generation
token; differing st_dev is no classification of the foreign filesystem.

These are public API semantics, read on 2026-10-08 from upstream main, not the
identity of a supported guest kernel. No SDK compile/link or native call was run
for this analysis. The graph CLI refused an active pre-coordination/unverified
generation; documents were read directly, with no code-completeness claim.

## Mount bootstrap and ordinary transitions

The following are obligations on the returned design, not an executable
bootstrap selected by this analysis.

| Context | Required proof before open | Scope if proof is unavailable |
| --- | --- | --- |
| `/` | An explicitly bounded initial namespace anchor; one owned temporary, no listing. Its first observation has no independent association detector. | All work needing namespace resolution; UNKNOWN/INSPECTION_FAILED, not a broad-root permission. |
| Startup system/data pair | Bind only the fixed supported OS routes to inspected mount observations, establish device correspondence and needed capabilities, and define refresh/replacement checks before a cross-device open. A pathname alone is insufficient. | Roots/targets depending on that member; no inferred system/data pairing or speculative acquisition. |
| OS-supplied actual home | Resolve the actual home through proved startup transit, without granting another user's home or a foreign-volume home. Define initial protected-policy bootstrap without assuming already-filled target witnesses. | Home-dependent admission/policy proofs. Whether another root is independent must be demonstrated, not inferred from its spelling. |
| Fixed Preboot | Establish the fixed mount proof before its first device crossing; allow transit only in fixed Cryptex-anchor mode. Final application-region proof remains separate. | Dependent Cryptex/application work only. No file-search special witness or general Preboot admission. |
| Ordinary root/link/registration/queued/current/dot-dot/restart | Compare the no-follow child device with established, context-permitted witnesses before open. Recheck association and actual mounted metadata after acquisition; never acquire an unknown foreign child just to classify it. | Initial root REMAINDER; checked-link ENTRY; independent queued target SUBTREE under a proved unchanged parent; shared current/prefix proof one root REMAINDER. Registration uncertainty prevents a negative. |

An established unadmitted device uses the existing MOUNT_BOUNDARY/domain
refusal. A missing required witness is INSPECTION_FAILED; an independently
observed replacement is CHANGED_DURING_SEARCH. Do not turn uncertainty into
UNSUPPORTED_VOLUME or ROOT_NOT_FOUND. Already established unsupported
classification retains its domain reason. Initial failure keeps resolvedPath
null and no searched record; progress and earlier finalized observations retain
their existing coverage meanings. Public outcome precedence is unchanged.

The fixed startup or Preboot pathname is not itself a safe bootstrap proof:
using it to authorize an open and only then observing a different filesystem
recreates the foreign-mount problem. The returned design must name the missing
information and the accepted means of obtaining it. This is a gap in the current
specified route, not a claim that every public metadata route is impossible.

## Policy-route links and proof dependencies

| Observation | Permitted conclusion | Required continuation |
| --- | --- | --- |
| Established directory at a protected/cloud route | Block its identity aliases before open; refresh the no-follow association for each dependent decision. | Charge the witness and retain the established reason, including native case/normalization aliases. |
| Target proved confined beneath an established blocked ancestor | The ancestor already blocks access; no duplicate target identity is needed for that confined subtree. | State the confinement proof and dependent roots/candidates. A textual prefix, or merely encountering Library on a route that could later escape via link or `..`, proves no final confinement. |
| Cloud/iCloud link whose walk reaches blocked Library | Refuse that route before opening Library or probing its children. | This proves route refusal, not the ultimate target identity. Explain whether further outside-root alias proof is required; do not silently treat an unresolved escape as confined. |
| Documents/Downloads relocated into ordinary Work/Docs | The policy link is present but its no-follow identity is not Docs. Literal target spelling cannot block case/NFC/NFD/Data aliases. | Establish the target identity without opening the excluded target and without recursively resolving witnesses. Until then its target-alias proof is unsettled. |
| Checked no-follow absence beneath an established permitted parent | That direct policy-route object is absent; synthetic policy coverage remains. | A dangling followed route has different evidence requirements. ENOENT from an unproved prefix, size refusal or service error establishes no target absence. |
| Witness replaced/changed or uncertain | Refuse work requiring the old proof with change or inspection failure. | Identify that dependency explicitly; reuse neither the old identity nor literal-only blocking. A common proof can affect several roots only with a stated overlap reason. |
| Witness value/slot/byte overflow | Existing job-wide pre-turn refusal, every root UNKNOWN/zero counts. | Keep charges and worker cleanup; do not drop aliases or introduce an uncharged target catalogue. |

There is an ordering counterexample for a naive target walk. Let Documents link
to Work/Docs, and let Docs itself redirect to Work. The component walker would
open Work before discovering that Work is the protected target. With two policy
links, resolving one target can likewise require a parent that is the other's
unproved target. A witness-only mode that ignores pending policy proofs hides
this problem; a recursive resolver introduces both a dependency cycle and
uncharged work. Native directory ancestry, not source-text nesting, must justify
any exemption. This does not declare every relocated-home layout unusable; it
identifies what a proposed route must establish.

Do not ship all-home failure as the cure. The current design has no authorized
workflow reduction. Returned design must either establish the required proofs
and their exact dependencies or bring actual missing witnesses/omissions to the
existing protected-home decision. Fail-closed diagnostics describe an observed
failure; they are not acceptance of systematically missing configured work.

## Concrete metadata-policy choices

**Recommendation: permit a narrowly scoped public-metadata design revision,
then require a returned design and its mandatory review.** Approval would allow
design work only, preserving accounts, domain, ceilings, wait, Q/S, two
temporaries, single-process ownership and signing/consent posture. It is not
approval to ship a prompting route, run a probe, or accept reduced coverage.

Two candidate mechanisms make this choice concrete:

- Apple's [getfsstat manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/getfsstat.2)
  describes a caller-sized array; MNT_NOWAIT uses kernel-retained information
  rather than refreshing each filesystem. It may be stale. A design could use
  bounded cached mount observations before fixed bootstrap crossings, retain
  only the existing required witnesses and release the array before walking.
  It must reject incomplete/ambiguous records without resizing/retry, establish
  correspondence to no-follow devices without assuming an fsid/dev cast, and
  state replacement/ABA limits. No buffer size, record cap or safe classifier
  is selected here; all simultaneous state must fit existing scratch/witness
  accounts. MNT_WAIT/DWAIT and a growing mount catalogue are not substitutes.
- A target-following fstatat on a fixed known policy component through an
  established parent could obtain target status without an owned target
  descriptor. That changes the selected no-follow-only policy semantics even
  though the symbol already exists. It lets the kernel resolve links and cross
  devices; absence, link/length bounds, foreign-target metadata and prompt/
  hydration safety need an explicit contract. Earlier measured stat fixtures
  do not accept this variant or cloud/Library/foreign targets. It cannot be
  smuggled in as the existing single-component walk, nor provide an alternate
  general root/link/registration resolver.

The other choice is to retain the selected call policy and demand a complete
alternative pre-open proof design. Neither source above provides that design.
Freezing literal-only blocking or accepting fewer home/default workflows is a
separate operator decision with actual omissions, owned by protected-home
acceptance. New consent/setup is also a separate decision; neither is recommended
by this analysis. Evidence that would remove the escalation is a complete route
within the selected semantics that supplies the missing pre-open facts, handles
the ordering counterexample and preserves every account and workflow obligation.

## Acceptance construction required after design

No subjects below have run. Controlled private outcomes establish ordering and
mapping only. Independently built provider/GraphQL and signed hardened VM runs
must exercise the selected calls; unavailable subjects remain pending.

| Subject | Independent witness and required distinction |
| --- | --- |
| `.app` links and registration/preferred URLs to removable, network and local image mounts | Record no-follow device, witness decision and every attempted open. No unknown foreign target open, metadata fallback or UNREGISTERED from a refused URL. A local image is not removable/network evidence. |
| Foreign mount nested beneath home, including queued/current reacquisition | Pair a refused target with ordinary sibling and independent-root markers. Inject missing versus changed proof separately; one shared prefix refusal must not fan out per task. A mounted root's own probe may already service foreign metadata: observers cover probes as well as opens. |
| Actual startup/data/home and fixed Cryptex/Preboot layout | Record each bootstrap fact, source, acquisition order, fixed-mode transition and post-acquisition comparison. Other Preboot siblings and file-search Cryptex roots remain excluded. Inject absent/unknown/replaced witnesses and account overflow separately. Default Safari/Finder and ordinary home remain useful-coverage witnesses. |
| Library cloud/iCloud links and escaped suffixes | Library must not be opened/listed to construct target witnesses. Prove confined-target and unresolved-escape branches separately; a real cloud client/route is not replaced by a Unicode fixture. |
| Relocated Documents into ordinary Work/Docs | Independent helper records target identity and literal/case/NFC/NFD/Data variants; query a direct target root, an app link and registration target plus unrelated markers. Include Docs redirecting to Work and two interdependent policy links. Trace identity acquisition before any dependent open. |
| Established absence, replacement, uncertainty and bounds | Private controls distinguish no-follow direct absence, unproved/dangling prefix, native errors, witness byte/slot overflow, scratch refusal, wait/freeze and late return. Observe each retained value/owner; no extra descriptor or post-freeze call. |

Independent dialog and hydration observers start before the first bootstrap or
policy probe and outlive worker-owned late cleanup. Their positive controls must
demonstrate detection; a dialog/download fails that route. Pair every native
call envelope with the existing complete owned/hook events and listener/store/
authorized-action witnesses. Preserve fixed sink/loss controls and no retry after
freeze/resource refusal. Record actual versions, paths/identities, per-witness
outcomes and omissions; no mount-table count, exit code or synthetic success is
a native prompt/serviceability/useful-coverage pass.
