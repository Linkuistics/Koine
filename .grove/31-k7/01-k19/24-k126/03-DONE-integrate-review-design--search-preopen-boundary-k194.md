# search-preopen-boundary-k194

**Integrates:** search-preopen-boundary-k192

## Goal

Triage the findings of `search-preopen-boundary-k192` against the pre-open
boundary analysis from `search-preopen-boundary-k189`, then apply the real ones,
so that metadata requirements `search-preopen-metadata-k190` asks Antony only
the questions the reviewed boundary still leaves open.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `23d6e0e277b5`, whose coordinates
  equal the review's tree.
- The artifact: `docs/verification/search-preopen-boundary.md`, the spec's
  pre-open proof boundary and the sections it touches in
  `docs/specs/workspace-search.md` (roots/domain, component resolution, pre-open
  policy, canonical observation, witness accounts, k119 calls), the cited ADRs,
  CONTEXT, SDL comments/examples, client guide, workflow trace, the focused
  search-preopen view and the other changed views with captions/README, and the
  k126 brief plus the k190/k191/k193 leaves that consume this boundary.
- Approval is unchanged. No new consent, entitlement, usage key, setup, helper,
  raised account, shorter ceiling, smaller domain, incompatible version or
  changed k119 call set is authorized. Lost workflow coverage goes to
  `protected-home-search-k93` before it becomes a dependency.

## Done when

- Classify every finding as a contract stated unclearly, valid and actionable,
  a visible trade-off, or noise; record each verdict and its reason in the
  running log, and apply actionable repairs in place across every affected
  durable artifact and summary layer.
- Where a finding removes or narrows part of the escalation, say so in the
  boundary and reframe k190's leaf to the questions that remain; where it
  confirms the escalation, make the k190 framing carry the missing disclosure.
  Do not select a call, consent or workflow change here — that stays k190's.
- Escalate rather than rely on any repair that would change workflow coverage,
  approval posture, k119's call set or another increment's contract. A repair
  amounting to substantive redesign is k191's, not this integration's.
- Regenerate changed views and run frozen `task design:search-render`,
  `task design:search-check` and `task check:docs`.
- k190 then consumes the reconciled boundary; k191, the mandatory node review
  k193 and k127/k123/k120/k30 keep their order.

## Notes

Design triage only: no implementation, probe or native evidence chain. All
native, prompt, hydration, binary and useful-coverage acceptance stays pending.

## Decisions (running log)

- Adopt the mandated integration in the stated jj workspace, empty on review
  commit `b1ef3706`. Read all eight findings from that commit; the producer is
  `23d6e0e277b5`. CBM `list_projects` refused an active pre-coordination or
  unverified generation, so use exact document/SDK source and claim no graph
  generation, coverage or current implementation result.
- B1 — **contract stated unclearly, actionable**. The retained fixed-layout
  classifier expressly accepts the OS presentation/mountpoint premise and
  privileged-replacement limit. Slash already has a bounded initial-anchor
  rule, and fixed Preboot transit explicitly precedes region proof. Requiring
  generation/capability before those fixed acquisitions contradicts that
  contract. Restore fixed system/Data/Preboot bootstrap with post-acquisition
  classification/capability checks; keep device guards for every non-fixed
  route. Remove that bootstrap call-policy question from k190. Actual-home
  dependency ordering and supported-layout acceptance remain k191 work; this
  is not a complete algorithm or a claim that a fixed pathname admits arbitrary
  registration/link/root devices.
- B2 — **valid and actionable, bounded to the omitted alternative**. The
  descriptor-relative ADR selects O_SEARCH for lookup-only handles; k174
  measured protected-folder transit through openat/fstatat/readlinkat, with
  prompting read-mode controls. Opening Work for lookup alone neither lists it
  nor proves the ordering example unsafe. Independent, serial, fixed-count
  witness walks could resolve both targets without recursion or new calls.
  Evaluate that route first. The search-specific no-open rule still conflicts
  with a witness-mode exemption, so k190 must decide the inspection policy;
  do not silently authorize it here. k174 supplies no cloud/Library, relocated
  target, foreign-volume, other-build or actual-Koine acceptance.
- B3 — **valid and actionable**. The prompt-risk ADR explains the exclusion's
  purpose, but neither k73 nor k174 measures a relocated policy link's target.
  State conservative protection of an otherwise admitted relocated target as
  an unmeasured premise for k190, not a discovered prompt fact. Prompt behavior
  is reversal evidence and a required acceptance subject. Foreign targets are
  already refused on every device-guarded route; they require no acquired
  target-alias witness, though refused registration routes cannot prove a
  negative. Do not drop an inherited protection policy without the decision.
- B4 — **contract stated unclearly, actionable**. Refuse the Library route
  before access; an unobserved escaping suffix falls under the inherited
  unrecognized-provider/origin limit, not a required unresolved identity that
  fails ordinary home or independent roots. Existing established witnesses
  still block recognized aliases on other routes. State this dependency scope
  and remove exhaustive escaped-target proof from k190's question set.
- B5 — **valid and actionable**. The constrained cached-table candidate has
  no disclosed record/device correspondence except fixed-path trust, already
  available without that call. The installed 64-bit-inode SDK statfs shape is
  2,168 bytes: 32 KiB scratch headroom holds 15 records, even an otherwise empty
  128 KiB partition only 60. Requiring a complete bounded table can therefore
  refuse every dependent root on mount-rich hosts. Withdraw it as the
  recommended bootstrap solution. Apple's public getattrlistat manual offers
  relative no-follow object fsid metadata (with volume-group/physical-identity
  caveats); list it only as a conditional source-evaluation candidate, with
  volume-attribute support, SDK availability, errors and prompt/wait safety
  unresolved. No new call is selected or executed.
- B6 — **real trade-off, accepted visibly within the existing native boundary**.
  A mounted-root no-follow probe may service foreign metadata or automount
  before device mismatch is known; device guards cannot provide a native-call
  deadline. Existing k119 wait/freeze/late-return/cohort ownership already
  covers indefinite calls. Disclose retained worker/credits, no post-freeze
  inspection or retry, and process-restart-only recovery if another resource
  failure latches the cohort. Add actual unresponsive network/FUSE/autofs
  subjects; synthetic blocking or prompt-free local images do not pass them.
- B7 — **valid and actionable**. Following fstatat bypasses component policy
  and device guards, cannot be the Library-cloud fallback, can contact/block
  foreign mounts, and inherits native PATH_MAX/hop semantics instead of the
  component walk's 8,192-byte pending-text/32-expansion policy. State dependent
  uncertainty/refusal and lifecycle limits. For ordinary relocated targets,
  evaluate the lookup-only walk first; no blanket new-call recommendation.
- B8 — **contract stated unclearly, actionable**. With two known cloud routes,
  the conservative occurrence count is exactly 32, not spare capacity. Require
  target witnesses to retain identity/association metadata in existing charged
  slots, reusing/releasing scratch rather than adding a retained target path.
  k191 must prove actual simultaneous wrappers/slots/bytes and refresh fit;
  any route needing more cannot rely on exceptional overflow to ship systematic
  job-wide failure. No account is raised by this repair.
- Reconcile the boundary/spec, descriptor-relative ADR, canonical analysis,
  glossary, guide, workflow trace, SDL/example comments, four view sources/
  exports and presentation summaries, ancestor briefs and k190/k191/k193/k127/
  k30/k93 consumers. All eight findings have a verdict above; no replacement
  witness algorithm, inspection exemption or new call is selected. Substantive
  returned design remains k191's; the existing mandatory k193 owns its review.
- Frozen `task design:search-render`, `task design:search-check` and
  `task check:docs` each exited 0. SDL/examples compose independently and with
  the action schemas, existing action examples remain valid and mutation
  controls reject removed roots, invalid inputs/outputs and foreign types.
  Per-file SHA-256 checks match before/after for 144 inputs: repository Markdown
  outside .grove/.git/.jj/build/dependency trees, design SDL/examples,
  architecture D2/manifest, Taskfile.yml, scripts/check-doc-links.py and client
  package manifests. Rendering changes only the four expected SVG exports.
- Inspect the discussion summary and focused pre-open diagram, including
  native-size mode, in isolated Linux Firefox using TestAnyware. Presentation
  inputs/exports have matching before/after digests; the clone is stopped.
  This is layout inspection only, not a native metadata/prompt/hydration,
  serviceability, binary or useful-workflow result. No reviewer was spent.
- k190 now asks only remaining target protection/inspection questions and
  justified conditional metadata evaluation. k191/k193/k127/k123/k120/k30 keep
  their order; retiring this leaf closes no node because k126 still has k190
  and k191 live. No Creator is written for that unfinished node.
