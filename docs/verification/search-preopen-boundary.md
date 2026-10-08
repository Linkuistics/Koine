# Search pre-open proof boundary

**Reuse-design reconciliation:** the [current tool-backed contract](../specs/workspace-search.md)
and [finite backend evidence](search-tooling.md) replace custom traversal/witness
mechanics below. Retain this document as bounded prior evidence/design analysis,
not an implementation prescription or acceptance of the new backend. Applicable
native fact, permission and serviceability obligations remain live.

**Reconciled source and contract analysis; target-inspection decision required.**
The selected fixed-layout premise supplies a bootstrap route. Lookup-only target
acquisition is an omitted alternative within the descriptor-relative ADR's call
set; its search-policy authorization and unmeasured target behavior remain open.
This analysis selects no replacement call or witness-mode exemption, approves no
workflow loss, and adds no native measurement. The
[witness contract](../specs/workspace-search.md#permission-boundary-and-required-decision) and
[focused view](../design/architecture/index.html#diagram-search-preopen) carry
this boundary. Returned witness design and mandatory review, observation phases,
classification and complete-resource review still precede planning.

## What the current calls establish

Apple's [stat manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/stat.2)
distinguishes a link's own status from its target's. A relative single-component
fstatat with AT_SYMLINK_NOFOLLOW supplies the child device/identity or the link's
own identity. It can reject an unadmitted device; it cannot identify a symlink's
target. Reading link text supplies a route, not an identity or confinement proof.
Apple's [statfs manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/statfs.2)
explains the selected descriptor mount observations. Capability checks use the
admitted descriptor; capability and mount generation are not new prerequisites
before the trusted fixed bootstrap acquisition. Device equality does not provide
a generation token or remove the existing replacement/ABA limit.

The [descriptor-relative ADR](../adr/filesystem-access-is-descriptor-relative.md)
selects O_SEARCH for handles used only to resolve a location, separate from
search's read-mode listing streams. [k174](descriptor-walk-prompt.md) measured
openat(O_SEARCH), fstatat and readlinkat transit through real Desktop, Documents
and Downloads on macOS 26.5, without a prompt/TCC row and with prompting read-mode
controls. That evidence is newer and broader for lookup transit than
[protected-path metadata](protected-path-metadata.md), but covers neither
relocated policy targets, Library/cloud/dataless routes, foreign volumes, other
builds nor the actual search host's responsible identity. It is evidence to
evaluate a route, not search acceptance.

The public API sources explain semantics, not the supported guest kernel. The
integration read public manuals and installed SDK headers on 2026-10-08; it ran
no compile/link probe or native metadata call. The graph CLI refused an active
pre-coordination/unverified generation, so documents were read directly, with no
code-completeness claim.

## Mount bootstrap and ordinary transitions

The accepted [fixed-layout classifier](../specs/workspace-search.md#roots-and-search-domain)
is a premise, not APFS role attestation or protection against privileged mount
replacement. It permits these narrow acquisitions before their descriptor
classification. It does not allow arbitrary sources to nominate trusted mounts.
The returned design still owes complete bounded ordering, refresh and accounts.

| Context | Selected boundary | Scope if required observation fails |
| --- | --- | --- |
| `/` | Initial no-follow lookup-only namespace anchor, one owned temporary, no listing. Its first observation lacks an independent association detector; no device crossing needs prior classification. | All work needing namespace resolution; UNKNOWN/INSPECTION_FAILED, never broad-root admission. |
| Fixed startup system/Data | Resolve the fixed OS routes through held system-volume parents, probe/open the fixed mountpoints, then check descriptor device/mount classification and capability. The existing fixed-layout/privileged-replacement premise supplies bootstrap authority; no pre-open generation or capability proof is added. | Work depending on that member; unknown layouts refuse, with no inferred general local-APFS admission. |
| OS-supplied actual home | Resolve through established startup transit with non-fixed device guards. Actual home is no fixed-route exemption for a foreign-volume home or another user's home. Initial protected-policy dependency ordering remains returned-design work. | Home-dependent admission/policy proofs; independence must be established. |
| Fixed Preboot | Only fixed Cryptex-anchor mode may probe/open the fixed mountpoint before its region witness exists, then apply the retained mount-root/type/flags/mountpoint and capability checks. | Dependent Cryptex/application work; no general Preboot or file-search exception. |
| Ordinary root/link/registration/queued/current/dot-dot/restart | Compare the no-follow child device with established context-permitted witnesses before open; recheck association and mounted metadata after acquisition. No unknown foreign open merely to classify it. | Initial root REMAINDER; checked-link ENTRY; independent queued target SUBTREE beneath an established unchanged parent; shared current/prefix failure one root REMAINDER. Registration uncertainty prevents a negative. |

An established unadmitted device uses MOUNT_BOUNDARY. Missing required metadata
uses INSPECTION_FAILED; independent replacement evidence uses
CHANGED_DURING_SEARCH. Established unsupported classification retains its domain
reason. Uncertainty is neither unsupported classification nor ROOT_NOT_FOUND.
Initial failure leaves resolvedPath null and no searched record; existing
progress/finalized observations and public outcome precedence remain unchanged.
The bootstrap new-call question is removed: a cached mount table is unnecessary
to restore the already selected fixed classifier. Native layout and useful
Safari/Finder/home acceptance remain pending.

## Policy-route links and proof dependencies

The protected-folder policy conservatively treats an otherwise admitted target
of a relocated Desktop/Documents/Downloads link as protected. Whether listing
that target can prompt is an **unmeasured premise**, not a reported prompt fact.
The [prompt-risk ADR](../adr/prompt-risk-is-search-data.md) makes that behavior
relevant reversal evidence. Keep the inherited policy until the target-inspection
decision reconciles it; do not infer either permission or workflow reduction.

| Observation | Permitted conclusion | Required continuation and dependencies |
| --- | --- | --- |
| Established directory at a protected/cloud route | Block identity aliases before listing/general acquisition, including native case/normalization aliases. | Refresh the no-follow association for dependent decisions; retain existing reason and charged witness. |
| Target proved confined beneath a blocked ancestor | The ancestor blocks that subtree; no duplicate target identity is needed. | State actual confinement, not a textual prefix or an encountered Library component whose suffix could escape. |
| Cloud/iCloud route reaches blocked Library | Refuse before opening Library or probing its children. Its unobserved escaping suffix falls under the inherited unrecognized-provider/origin limit. | No exhaustive outside-root target catalogue or required unknown witness; no all-home/independent-root failure. That candidate/root route is refused; other established identities still block recognized aliases on other routes. |
| Relocated ordinary target, including Docs redirecting to Work | No-follow link identity is insufficient; native target identity can block case/NFC/NFD/Data aliases. Lookup-only transit is a candidate acquisition route. | k190 decides the witness-mode inspection policy and target-prompt premise; k191 owes serial bounded acquisition/refresh and exact dependent roots/candidates. No listing or bundle inspection while filling witnesses. |
| Target route reaches an unadmitted foreign device | The device guard already refuses that route on every source. | No acquired target-alias witness is needed for that foreign class. A refused registration route still cannot establish its final identity/absence or UNREGISTERED; foreign links can lead back. |
| Checked direct no-follow absence under an established permitted parent | The direct policy object is absent; synthetic policy coverage remains. | An unproved prefix, dangling followed route, size refusal or native error establishes no target absence. |
| Required witness changed or uncertain | Refuse only work requiring that proof, using change/inspection failure. | A shared proof can affect several roots only with a demonstrated overlap; unrecognized provider origins are not newly required proofs. |
| Witness value/slot/byte overflow | Job-wide pre-turn refusal, every root UNKNOWN/zero counts. | Preserve charges/worker cleanup; never drop policy identities to continue. |

Documents → Work/Docs → Work and two interdependent policy links demonstrate an
ordering requirement for listing/general resolution, not impossibility of
lookup-only acquisition. The ADR route could resolve each fixed policy target
independently, serially with A/B, device guards and refusal before Library,
without recursion into pending target witnesses. Each walk uses the existing
resolver bounds and the same wait, multiplied by the fixed witness count. Its
exemption from the search-specific prohibition on opening a protected directory
to acquire identity is **unselected**; k190 must settle that policy distinction.
k191 must prove bounded association/refresh, identity comparison before later
listing, and no exemption for general roots/links/registration. A witness's
native identity answers case/normalization/Data variants; text folding does not.

With two known cloud routes the conservative path occurrence shape is exactly
32: 12 region, 6 mount, 8 protected, 4 cloud and 2 temporary occurrences.
There is no spare retained target-path occurrence. A target witness must retain
identity/association metadata in existing charged slots, using and releasing
scratch for its route rather than retaining another full path. k191 must prove
simultaneous bytes/wrappers/slots and refresh fit; a route requiring extra retained
paths cannot rely on systematic job-wide overflow as an accepted implementation.

## Concrete metadata-policy choices

**Recommendation: evaluate the existing lookup-only walk first, with an explicit
search-policy decision.** k190 should separately settle conservative
relocated-target protection and permission to design a serial lookup-only witness mode.
Approval is design only, under existing accounts/domain/ceilings/wait/Q/S/A/B and
signing/consent posture. No prompt, probe or workflow loss is approved. The
alternative is to retain the strict no-target-open policy and consider only a
specific justified metadata revision. The following are conditional alternatives,
not the former blanket recommendation to add bootstrap metadata:

- Cached getfsstat/MNT_NOWAIT is **not a demonstrated solution**. Apple's
  [manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/getfsstat.2)
  describes bounded kernel-retained, potentially stale records. Without an
  fsid/dev cast or another disclosed lookup, the proposed record/device binding
  reduces to fixed-path trust, already available without this call. The installed
  SDK's 64-bit-inode statfs is 2,168 bytes, including two 1,024-byte path fields;
  its [public header](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/mount.h)
  explains the shape. The 32 KiB headroom above the conservative 96 KiB scratch
  shape holds 15 records; even all 128 KiB holds only 60. This is upper-bound
  arithmetic, not a buffer allocation or mount count. Requiring a complete table
  with no resize/retry can deterministically refuse every dependent root on
  mount-rich hosts. Correspondence, truncation/race/ABA and simultaneous account
  fit need a concrete design before this candidate earns reconsideration.
- Descriptor-relative getattrlistat with FSOPT_NOFOLLOW is a possible
  source-evaluation candidate if an actual residual requires it. Apple's
  [attribute manual](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/man/man2/getattrlist.2)
  describes relative lookup and ATTR_CMN_FSID corresponding to statfs's fsid.
  Volume-group logical versus physical identifiers need explicit flag/correlation
  treatment. Useful volume-attribute support at the crossed mountpoint, SDK
  availability, bounded valid-result decoding and foreign-contact/prompt/wait
  behavior remain unproved. It adds a call; no symbol or flag is selected here.
- Fixed-policy target-following fstatat lets the kernel traverse links/devices
  without Koine's component guards. It cannot serve Library/cloud routes whose
  prefixes must be refused before Library access. Native PATH_MAX and link-hop
  semantics differ from the component walk's 8,192-byte pending text and
  32-expansion contract: ENAMETOOLONG/ELOOP can mean dependent uncertainty where
  that walk could succeed, never invented absence. Foreign metadata/automount
  may prompt, hydrate or block indefinitely, with the lifecycle consequence below.
  Earlier stat fixtures do not accept this variant. Evaluate lookup-only transit
  first for ordinary relocated targets; this is no general resolver fallback.

Relocated-target listing prompt behavior can remove or confirm the conservative
protection premise; it must be independently observed and reconciled with the
ADR, not guessed from link spelling. A complete in-policy route with bounded
accounts can remove a call-policy revision. Remaining workflow omissions/new
consent/setup go to their existing explicit decisions; protected-home acceptance
owns actual per-witness loss. Do not ship systematic all-home failure as policy.

## Foreign metadata contact and lifecycle limit

A no-follow mounted-root probe can already ask a foreign filesystem for attributes
or trigger automount before st_dev is returned. The guard prevents the subsequent
unknown-device open, **not that first metadata contact**. This is a disclosed
residual of the existing in-process native-call boundary, not a hard safety or
termination proof. An unresponsive network/FUSE/autofs route can retain its worker,
A/B and reserved credits indefinitely, even for a stale unrelated registration.
The three-second wait freezes publication; it cannot cancel a blocked syscall.
No late call, retry, replacement worker or external close is permitted. A finite
late return is normalized and unwound by its worker; a late resource error latches
the cohort before credit release. Another resource failure beside an indefinite
survivor can disable new search until Koine process restart; provider restart
cannot release that ownership. Observed prompts/hydration still fail acceptance.

## Acceptance construction required after design

No subjects below have run in this integration. Controlled outcomes establish
ordering/mapping only; independent provider/GraphQL and signed hardened VM runs
must exercise actual calls. Unavailable subjects remain pending.

| Subject | Independent witness and required distinction |
| --- | --- |
| App links and registration/preferred URLs to removable, network and image mounts | Record no-follow device, witness decision and every probe/open. No unknown foreign open, fallback or UNREGISTERED from refused URLs; a local image is no removable/network pass. |
| Nested foreign home mount, queued/current reacquisition and foreign relocated target | Pair refusal with ordinary sibling/independent-root markers; distinguish missing/changed proof and device refusal without a target witness. Shared failure has one root remainder, not per-task fan-out. |
| Unresponsive network/FUSE/autofs via explicit root, nested home mount and stale unrelated registration | Independently establish the real unavailable filesystem/automount subject; record first probe envelope, worker/A/B/credit retention, wait/freeze, finite late-return cleanup and resource-failure cohort/restart outcomes. Synthetic barriers are separate ordering controls, not native blocking evidence. Pair listener/store/actions during the wait and retained cohort. |
| Actual startup/Data/home and fixed Cryptex/Preboot | Record fixed premise, probe/open/classifier order and post-acquisition capability/association checks. Non-fixed attempts and other Preboot siblings remain excluded. Inject absent/unknown/replaced witnesses; useful Safari/Finder/home stay required. |
| Library cloud/iCloud and escaped suffixes | Refuse Library before access; distinguish genuinely established confinement from an unobserved escape under the inherited origin limit. Independent ordinary roots continue; a real provider route is no Unicode-fixture substitute. |
| Relocated Documents/Downloads, Docs redirecting to Work and two interdependent links | Independent helper records target identities, literal/case/NFC/NFD/Data variants and actual listing prompt behavior in a disposable subject. Observe lookup-only witness acquisition separately from read-mode controls and subsequent policy refusals, with actual Koine responsible identity. Direct target root/app-link/registration decisions have unrelated markers. |
| Absence, replacement, uncertainty and accounts | Distinguish direct no-follow absence, unproved/dangling prefix, native errors, full 32-occurrence witness shape, identity-only target retention, scratch/slot/byte overflow, wait/freeze and late return. Inspect actual value occurrences and no extra descriptor or post-freeze inspection. |

Dialog/hydration observers start before the first bootstrap/policy probe and
outlive worker late cleanup, with positive detection controls. A dialog/download
fails that route. Pair native envelopes with complete owned/hook events and
listener/store/authorized-action witnesses. Keep sink/loss controls and no retry
after freeze/resource refusal. Record versions, identities, per-witness results
and omissions; no table count, exit code or synthetic success passes native
prompt/serviceability/useful coverage.
