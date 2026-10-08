# search-preopen-boundary-k192

**Reviews:** search-preopen-boundary-k189
**Creator:** run ea3c05d4-8020-43ca-bdb8-d83a35e51761

## Goal
Disprove the boundary analysis's missing-proof claims and recommendation before
Antony decides metadata policy. Re-derive the actual selected semantics; finding
a coherent in-policy proof route can remove an unnecessary escalation.

## Context

- Read producer k189's focused commit and current source. Artifact:
  docs/verification/search-preopen-boundary.md, workspace-search's pre-open proof
  boundary and inherited bootstrap/policy/k119 call/account contracts, canonical
  analysis, protected-path-metadata evidence and the four changed visual views.
- The original k126 charter remains live; this producer completes analysis,
  not the witness algorithm. Requirements k190 and returned design k191 follow.
- Public stat/statfs/getfsstat manuals explain semantics, not guest results.
  Graph CLI refused an active unverified generation in the producer; direct
  documents/source supply its evidence, with no implementation/completeness claim.

## Done when

- Challenge whether selected no-follow child and descriptor mount calls really
  leave bootstrap facts missing, including bounded slash/startup/data/home and
  fixed-only Preboot transit. Distinguish device mismatch from mount generation/
  capability, trusted fixed route from speculative open, and explicitly accepted
  platform limits from newly invented stronger guarantees.
- Challenge the policy-target ordering counterexample and confinement rule:
  Work/Docs redirecting to Work, two pending target witnesses, Library cloud
  routes, escaped suffixes and native case/NFC/NFD/Data variants. Is an alias
  proof actually required by the inherited domain/limits at each claimed point?
  Does a selected public call establish it without unsafe or recursive opens?
- Challenge the concrete alternatives without selecting one: whether bounded
  cached getfsstat and fixed-policy following fstatat can reasonably be considered
  within unchanged accounts, and whether approval scope/call-policy changes,
  foreign metadata lookup, native length/hops, stale/absence/resource/prompt
  semantics and reversal evidence are sufficiently disclosed for k190.
- Check dependency-scoped errors, registration negatives, account overflow and
  claimed absence against the current spec. Ensure no systematic home failure,
  literal-only alias blocking, reduced domain, consent, call or native pass was
  adopted. Inspect constructed subjects/observer/late-cleanup obligations and
  summaries, schema comments, guide/glossary/trace/views/briefs for contradictions.
- Produce findings only. If actionable findings exist, insert an
  integrate-review-design of this review's handle immediately before the first
  later live sibling (metadata requirements k190), with its handle rather than
  a transcribed finding list. Otherwise cut no integration. The original node's
  returned design and mandatory whole-artifact review still follow.

## Notes

No in-session reviewer, native experiment or implementation. Frozen render/SDL/
docs checks and isolated Firefox presentation passed on unchanged per-file
inputs; they establish no metadata or native workflow outcome. Do not waive
proof obligations merely because the alternatives are unapproved, and do not
turn the boundary into an exhaustive impossibility claim it explicitly avoids.

## Decisions (running log)

- Adopt the mandate in the stated jj workspace. Producer k189 is `23d6e0e277b5`
  (`mvmqrkvw`); `@` is empty on top of it, so producer and current coordinates
  coincide. `spec` is `docs/specs/workspace-search.md`, `boundary` is
  `docs/verification/search-preopen-boundary.md`, `walk-ADR` is
  `docs/adr/filesystem-access-is-descriptor-relative.md` and `k174` is
  `docs/verification/descriptor-walk-prompt.md`, all at that commit. The
  codebase-memory server failed to connect, so no graph or code claim is made;
  documents and the k124 P2/P3 findings and k125 triage were read directly.
- Inspection only. No task, render, check, probe or native call was run, no
  manual was fetched, and no in-session reviewer was spent. Platform statements
  below are reasoning from the public API shape and the repository's own
  evidence, offered as challenges for the integration, not guest evidence.
- Eight findings warrant triage. The first sibling entry after this review that
  holds live work is `search-preopen-metadata-k190`; integration
  `search-preopen-boundary-k194` is inserted at its slot and carries this
  review's handle only. Retiring this review closes no node: k126 still holds
  k194, k190 and k191.

## Findings

Producer `23d6e0e277b5` (`search-preopen-boundary-k189`). Severity orders the
list. The two high findings each identify an in-policy route the boundary did
not evaluate; if they hold, the k190 escalation shrinks to what remains.

### B1 — The fixed Data/Preboot bootstrap "gaps" demand more than the spec's accepted mount premise, and contradict the still-selected Preboot classifier (high)

- spec:225-231 (unchanged by k189) obtains the Preboot witness by opening the
  fixed `/System/Volumes/Preboot` mountpoint and then classifying the opened
  descriptor. spec:247-253 calls this "not APFS role attestation or a guarantee
  against privileged mount replacement" and makes the fixed presentation/
  mountpoint relationship "an explicit design premise with actual-adapter
  acceptance". spec:519-521 lets fixed-anchor resolution take Preboot transit
  "before its region witness exists".
- k189 now states the opposite without withdrawing either rule: boundary:55-57
  ("The fixed startup or Preboot pathname is not itself a safe bootstrap proof"),
  boundary:44 ("Establish the fixed mount proof before its first device
  crossing") and spec:407-409. Under the selected calls the Preboot proof can only
  be obtained by that crossing, so the spec now holds two incompatible Preboot
  rules. k190's Notes forbid "an open-and-classify bootstrap", which is the rule
  spec:225-231 selects.
- The analysis names no unprivileged way for a different filesystem to appear at
  `/System/Volumes/Data` or `/System/Volumes/Preboot`; both sit in root-owned
  directories on the read-only system volume. The only scenario that "recreates
  the foreign-mount problem" there is privileged replacement, which spec:248
  already accepts. k124 P2's threat was foreign mounts reached through
  registration URLs, links, symlinked roots and nested home mounts, which are
  non-fixed routes the device guard already refuses. The boundary does not
  separate the trusted fixed route from those speculative opens.
- Mount generation and pre-open capability (boundary:24-27; spec:404-407; the
  CONTEXT entry) are called missing without showing they are needed. Capability is
  a per-volume fact spec:728-734 already establishes on the admitted mount witness
  after acquisition. Device equality with an established witness misidentifies
  the mount only after an unmount and device reuse; the startup pair cannot be
  unmounted while the system runs, and a Preboot remount is privileged again. A
  foreign device is refused by mismatch without either fact.
- `/` (boundary:41; spec:409) is listed as an obligation, yet it involves no
  device crossing, and spec:451-455 already selects the bounded rule and discloses
  its first-observation limit.

**Consequence.** The bootstrap half of the escalation may be unnecessary. The
selected calls plus the accepted premise appear to make a complete bootstrap:
open `/`; probe and open the fixed Data and Preboot mountpoints through held
system-volume parents; classify with the selected fstatfs/fgetattrlist; then
admit later transitions by device equality.

**What needs settling.** Show a concrete unprivileged threat at the fixed
mountpoints, then withdraw the selected classifier everywhere it appears.
Otherwise mark these rows as satisfied by the fixed-route premise and keep the
escalation for what is genuinely missing. Sweep spec:23-27 and 398-411, the boundary rows,
CONTEXT, the view's "Fixed pathname is no unknown-device permission" node, its
caption, the README, client guide, SDL comments and the k190/k191/k193 briefs.

### B2 — The ordering counterexample ignores the descriptor-relative ADR and its measured lookup-only walk (high)

- walk-ADR:4-9 binds "search traversal" to component resolution from held
  handles, and walk-ADR:33-35 says "Handles that only resolve a location are
  opened search-only (`O_SEARCH`): they grant lookup, never listing … Search's
  listing streams still read the directories they list, under search's own
  protected-scope policy." spec:2390-2406 applies that decision to search.
- k174 (2026-10-07, macOS 26.5, signed hardened probe, Koine's empty
  entitlements) measured walks that `openat(O_SEARCH)` Desktop, Documents and
  Downloads themselves and then `fstatat`/`readlinkat` inside them: no dialog and
  no TCC row, while read-mode controls prompted.
- The boundary cites neither the ADR nor k174. Its evidence premise (k189
  Context; boundary:14-32) bounds native metadata evidence to
  protected-path-metadata's fixtures, which predates k174.
- boundary:73-81 and spec:419-421 put the harm at having "opened the protected
  target during witness construction". On the ADR's terms the walk's transit open
  of Work is a lookup-only handle that lists nothing, the kind k174 measured
  prompt-free even on the real protected folders. Two interdependent policy links
  are the same case. Each target can be resolved independently with lookup-only
  transit, with no recursion and no pending-proof check. Each run is bounded by
  the existing resolver account (spec:529-531) times a fixed witness count.
  boundary:77-78 rejects "a witness-only mode that ignores pending policy proofs",
  and spec:421 and the caption reject a "policy-exempt witness walk", without
  evaluating that mode.
- Once a target identity is acquired, the existing identity comparison
  (spec:570-581) blocks case/NFC/NFD/Data variants. boundary:68's "literal target
  spelling cannot block … variants" is answered by identity, not a new call.

**Consequence.** The selected openat/fstatat/readlinkat in the ADR's lookup-only
mode, kept behind the existing device guards and the refusal before Library, may
be an in-policy route for ordinary relocated targets. The boundary did not
evaluate it, and that gap is what makes the policy-target half appear to need new
metadata. For this class, candidate 2 (following fstatat) is dominated: it gives
up the per-component device and policy checks and has shown no prompt advantage.

**What needs settling.** Weigh that walk against spec:555-556 ("Do not open/list
a protected directory to acquire its identity"). Either show why lookup-only
transit through a not-yet-identified target still defeats the policy's purpose
(prompt risk; see B3), or present the walk as the in-policy alternative. Its real
residuals belong in acceptance: other OS builds, Library sub-areas, cloud dataless
directories, removable/network volumes and Koine's responsible identity, none of
which k174 covers. Correct the evidence premise.

### B3 — Whether a relocated protected folder's target must be blocked at all is assumed, not derived (medium-high)

- `PROMPT_RISK` means Koine "declined an inspection known to be capable of
  prompting" (docs/adr/prompt-risk-is-search-data.md:4-7). The protected-folder
  block (spec:321-329) exists for that reason.
- The inherited text covers aliases *of* the protected objects: "protected
  Desktop/Documents aliases are covered by the earlier rule" (spec:330-332) and
  comparison "including aliases under other parents" (spec:570-571). When
  `~/Documents` is itself the link, whether its target can prompt is a platform
  fact no cited evidence measures. protected-path-metadata covers links inside the
  folders, and k174 covers walks inside the real folders.
- boundary:68 and 140 and spec:418-421 treat the target as protected and its alias
  proof as required. The only reversal evidence offered is a complete route
  within the selected semantics (boundary:124-126).

**Consequence.** If the target can prompt, blocking is required and B2 applies.
If it cannot, blocking Work/Docs withholds the user's actual documents and
reports PROMPT_RISK for an inspection not known to prompt, contrary to the ADR;
then no target proof is needed. k190 cannot weigh the escalation without knowing
which premise it rests on.

**What needs settling.** Name the premise; list the relocated target's prompt
behaviour as reversal evidence and as an acceptance subject. Add the class the
table omits: a target on a foreign volume, which the device guard refuses on
every route and which therefore needs no target proof.

### B4 — Library cloud-link escapes are left "unsettled" though the inherited limits already answer them (medium)

- Under the selected calls, confinement beneath Library (boundary:66) is provable
  only when the target is Library itself. Proving that the suffix stays confined
  needs probes inside Library, which boundary:67 rightly forbids. Every ordinary
  `~/Dropbox → ~/Library/CloudStorage/…` or iCloud `Mobile Documents` layout,
  which k124 P3 called "not exotic", therefore falls in the unsettled row.
- boundary:67 and spec:415-418 keep "any otherwise-required outside-root alias
  proof as unsettled" and ask the returned design to "Explain whether" it is
  required. Under spec:580-581, unknown relevant identity is INSPECTION_FAILED, so
  read strictly "unsettled" is k124 P3's strict reading: dependent decisions fail
  for these common layouts. No dependency scope is named for it.
- The inherited spec already has the limit: "Unrecognized file-provider locations
  cannot be exhaustively identified" (spec:332-333), and "unrecognized provider
  locations and aliases whose protected origin cannot be established retain
  existing native/policy limits" (spec:590-593). The escaped real location of a
  provider domain is such a location. Library stays blocked, and the other
  witnesses' identities are unaffected.

**Consequence.** k190 receives a question the inherited domain appears to settle.
Meanwhile the interim wording leaves the systematic-failure reading live with no
stated scope.

**What needs settling.** Either apply the inherited limit to escaped suffixes
(refuse the route before Library, with no further proof) or show why it cannot
apply. In both cases, state which roots and candidates depend on the outcome.

### B5 — The getfsstat candidate cannot supply the missing correspondence under its own constraints, and its account fit is unexamined (medium)

- boundary:103-104 requires correspondence between a cached record and a
  no-follow device "without assuming an fsid/dev cast". A record carries a
  mountpoint and an fsid; the probe yields st_dev. Without the cast, the remaining
  links are the mountpoint pathname, which boundary:55-57 rejects as proof, or an
  extra lookup the candidate does not disclose. As constrained, it classifies a
  path rather than the device about to be opened, so the bootstrap gap it is
  recommended for stays open (see also B1).
- macOS `struct statfs` carries two 1,024-byte path fields, about 2.1 KiB per
  record. The scratch partition's conservative shape uses 96 of 128 KiB
  (spec:2297-2299). That leaves room for about fifteen records, or about sixty if
  the whole partition were free. boundary:104 rejects incomplete arrays "without
  resizing/retry". A host with more mounts (simulator runtimes, attached images,
  snapshots, FUSE) would then fail bootstrap deterministically for every dependent
  root, a systematic loss the charter forbids. boundary:106-108 says only that no
  cap is selected.
- The option set omits a candidate nearer the selected calls: descriptor-relative
  `getattrlistat` with FSOPT_NOFOLLOW, the at-form of the selected `fgetattrlist`
  (spec:728-731). It can request the looked-up object's ATTR_CMN_FSID, which
  compares with fstatfs/getfsstat fsids without a cast. Whether it also returns
  volume attributes for a crossed mountpoint before open would need checking
  against the public manual and SDK. This review selects nothing.

**Consequence.** k190 may approve design work on a mechanism that cannot close
its gap and that, under unchanged accounts, can make bootstrap fail outright on
ordinary developer hosts.

**What needs settling.** Name the correspondence mechanism, or concede that the
candidate reduces to fixed-path trust. Do the record-size arithmetic and state
the truncation consequence. List or rule out the descriptor-relative attribute
candidate.

### B6 — P2's indefinite-blocking consequence is dropped: the device guard moves the first foreign call from the open to the probe (medium)

- k124 P2 named two consequences, a consent dialog and "A network or FUSE mount
  root can block the open indefinitely … A stale registration unrelated to the
  query can trigger it."
- The guard works because a no-follow probe of a mountpoint name reports the
  *mounted* filesystem's device (spec:404-406). The probe has therefore already
  crossed into that filesystem and asked it for attributes. boundary:137 concedes
  this for dialogs ("A mounted root's own probe may already service foreign
  metadata").
- Neither the boundary nor the new spec section mentions unresponsive mounts or
  automount triggers. The subjects (boundary:136-141) cover dialogs, opens and
  UNREGISTERED, but not a dead network, FUSE or autofs mount reached by a
  registration URL, a nested home mount or an explicit root.

**Consequence.** A stale, unrelated registration URL on an unresponsive mount can
still hold a worker and its credits. Beside a resource failure it can disable
search until restart, and this is neither disclosed nor subjected.

**What needs settling.** Record the probe's foreign contact as a disclosed
residual with its wait/freeze/late-return/cohort consequence, or as an
obligation. Add an unresponsive-mount subject that observes worker and credit
retention.

### B7 — The target-following fstatat candidate's disclosure misses conflicts k190 needs (medium-low)

Against boundary:109-117:

- For cloud links, a following fstatat makes the kernel traverse `~/Library/…`,
  the route boundary:67 says must be refused "before opening Library or probing
  its children". Either the candidate contradicts that row or it does not help
  the cloud class; the boundary does not say which.
- Kernel resolution crosses devices with no Koine pre-open check. It can trigger
  automounts or block on an unresponsive filesystem (B6), and "foreign-target
  metadata" names this only generically, with no wait/freeze/late-return
  consequence.
- The kernel composes link text within its 1,024-byte path limit, while the
  resolver allows 8,192 bytes of pending text (spec:530). Targets the walker can
  resolve would return ENAMETOOLONG, which means uncertainty and dependent failure.
- For relocated ordinary targets it is dominated by the ADR walk (B2).

**What needs settling.** Disclose these, or narrow the candidate's stated reach.

### B8 — Witness-account overflow is presented as exceptional, but the occurrence ceiling is already exactly used (low-medium)

spec:2285-2296 sizes the witness account at 32 path occurrences: two for each of
six regions, three mount roots, four protected scopes and the known cloud routes,
plus two temporaries. With two cloud routes that is exactly 32. Overflow refuses
the whole job before any turn, leaving every root UNKNOWN (spec:2300-2307).
boundary:71 treats overflow as an existing exceptional refusal and never says
whether a target proof retains a path occurrence. If one retained path is needed,
overflow becomes deterministic for any user with a policy link, refusing every
root of every job, not just home. State that target proofs retain identity only
(the slots are ample), or disclose the account consequence before design relies
on it.

### Re-derived and confirmed, not findings

- Dependency scopes (boundary:45, 47-53; spec:424-431) match the resolver and
  schema scopes (spec:534-541; the VALUE_LIMIT and INSPECTION_FAILED schema docs).
- A refused registration/preferred URL preventing UNREGISTERED is correct. A
  refusal at an intermediate foreign device does not establish the final target's
  identity, since links on that volume can lead back.
- MOUNT_BOUNDARY for an explicit foreign root refused before open sits in the
  same aggregate class as UNSUPPORTED_VOLUME (spec:971), so no public outcome
  changes.
- Established absence (boundary:69) matches the ROOT_NOT_FOUND rule (spec:539-541).
- Observer start and late-cleanup obligations (boundary:143-150) are complete
  apart from B6.
- No literal-only blocking, systematic home failure, reduced domain, consent,
  call change or native pass is adopted. The summaries, SDL comments, guide,
  glossary, trace and views consistently label the candidates unapproved. What
  they propagate are B1's and B2's premises, which an integration must sweep.
