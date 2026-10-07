# long-search-result-actions-k169

**Reviews:** long-search-result-actions-k168
**Creator:** run 4fe4883f-90d0-49ba-b1d9-c81ea7f0fe70

## Goal

Load-bearing adversarial re-read of the v1 long-location action contract as
integration k168 left it, before planning k167 builds on it. Findings only; no
fixes.

## Context

- k168 applied review k166's eight findings, then its one in-session reviewer
  found seven more defects in the rewritten stages, which k168 also fixed. That
  second need is why this review exists: the fixes are substantive and were not
  re-read. Read k168's running log and its commit diff.
- `docs/specs/workspace-launch-and-open.md#long-location-action-boundary`
  (resolution table, name limits, cycles, reveal's root, "Order of target and
  application stages", hand-off limit, subjects),
  `docs/design/workspace-action-repair-schema.graphql` (three appended mutation
  descriptions), `docs/adr/filesystem-access-is-descriptor-relative.md`, the
  client guide, glossary and `workspace-long-locations` view.
- The retained short-path logic and tests are the contract the stages must keep
  below the limit: `Providers/WorkspaceProvider/Logic/Selection.swift`,
  `OpenPath.swift`, `RevealPath.swift`,
  `Providers/WorkspaceProvider/Sources/NativeWorkspace.swift` and
  `Tests/WorkspaceProviderLogicTests/`.
- Antony's v1 refusal and the descriptor-relative access decision are settled;
  review the design that implements them, not the decision.

## Done when

- Every finding names the artifact, the defect and its consequence. Attack these
  doubts in particular:
  - Below the limit, does any retained outcome or precedence still change —
    application-location cycles and impossible names now `failed`, candidates
    compared to the first match, a candidate's metadata no longer read,
    default-handler lookup back on the literal target, reveal's Finder mapping?
  - Is the cycle state (containing directory, link text, exact pending suffix)
    sound and sufficient, and is reporting a self-extending link as the budget
    an honest reading of the boundary's "demonstrably unresolvable cycle"?
  - Does examining the final component with `fstatat` from its parent match the
    accepted `stat` for permissions, trailing slashes, final `.`/`..` and the
    reveal `lstat` root rule, including `/Volumes/<link>/`?
  - Is the ASCII-only impossible-name proof the right conservative line?
  - Do the stage order, hand-off limit placement and SDL descriptions agree
    with each other and with the outcome table, guide and view?
- If findings warrant action, cut the integration where `pick` reaches it next
  (before long-location-actions-k167). Otherwise retire with none.

## Notes

Native, binary, public and signed-VM acceptance stay with planning k167. No hand-off
workaround, shorter search ceiling, consent/signing change or long-path
application support is authorized.

## Decisions (running log)

- Reviewing integration k168's committed artifact at `6647c3a6` (`zlnnvywv`),
  on an initially empty jj change. Read the mandated leaf, root-to-leaf briefs,
  glossary, cited ADRs, k168's running log and focused design diff. This is an
  inspection-only review; no tests, builds, linters, formatters, renderers or
  native probes will run, and no design or implementation fixes belong here.
- Graph Verify was attempted first. `list_projects` and the task-directed
  `check_index_coverage` call both refused before startup with
  `CBM CLI could not start because a pre-coordination or unverified CBM
  generation is active; close all CBM sessions and commands, then retry`.
  No project/generation or coverage could be confirmed. Used exact cited source
  files and bounded source/test reads instead; this supplies no graph-backed or
  repo-wide completeness claim.
- The revised application/candidate stage rules preserve the cited retained
  mappings and first-match precedence. Skipping unequal candidates without
  reading their bundle metadata is an explicitly recorded consequence of the
  settled device/inode comparison, rather than an unknown-equality shortcut.
  The directory/text/exact-suffix cycle state is sufficient for the deterministic
  expansion under the existing observation/race limits. Self-extending links
  remain an explicitly stated conservative budget failure. The ASCII-only
  impossibility proof requires the component lookup to fail first and does not
  reject successful multibyte/combining-name lookups.
- **R1 is actionable:** the repair SDL's open-path description, also incorporated
  into the search-serving composed contract, still promises to refuse an
  over-limit selected application before handler lookup. A default handler must
  be discovered by that lookup before its
  location can be resolved and limited. The staged spec correctly distinguishes
  target refusal before discovery from discovered-application refusal afterwards;
  the public description does not. Record the contradiction as a finding only.
- The directory-local next live sibling was planning k167. Cut the paired
  `integrate-review-design` as `long-search-result-actions-k170` immediately
  before that sibling, so it consumes this
  finding at the reviewed coordinates before planning changes anything. The
  launch-and-open node still has live planning/implementation work; this
  retirement closes no parent node. No design or runtime acceptance is supplied.

## Findings

Anchored to integration commit `6647c3a6` (`zlnnvywv`); artifact coordinates
below refer to that tree. One finding warrants integration before planning.

### R1 — The public open description puts a discovered handler's limit before its discovery (medium)

**Artifact/location:** `docs/design/workspace-action-repair-schema.graphql:83`,
the appended `workspaceOpenPath` description. Search release/schema 1.1.0
incorporates that description through its repaired-action composition
(`Taskfile.yml:306`). The standalone search SDL is a separate extension, not a
second copy of this description.

The description groups an extant target, `applicationPath` and selected
application under one promise: an over-limit spelling is refused before
metadata, handler lookup or any request. Consider a short ordinary target with
no named application, whose default-handler discovery returns a location of
1,024 bytes. The handler's location is unknown until that lookup completes.
Resolution and its limit must therefore follow discovery; refusing this selected
application before handler lookup is impossible.

The spec already gives the correct distinct sequences at
`docs/specs/workspace-launch-and-open.md:335` (target before lookup), `:355`
(discovery before resolving its answer), `:364` (selected-application limit)
and `:379` (explicitly allowing discovery before refusal). The retained
`Providers/WorkspaceProvider/Logic/OpenPath.swift:136` likewise discovers the
handler before inspecting its location. No domain request is sent in either
refusal case, but that does not mean no discovery read occurred.

**Consequence:** the exact public/introspected 1.0.1 description and its 1.1.0
consumer promise an ordering the designed implementation cannot satisfy. A
contract-driven client or acceptance subject can incorrectly require zero
handler lookups for a refused discovered application. The existing schema/delta
checks validate composition and description shape, not this semantic ordering.

**Smallest useful correction:** make the description's promises stage-specific:
an over-limit target stops before target metadata and handler lookup; an
over-limit supplied application stops before its metadata/registration; an
over-limit discovered application stops after discovery and before its own
pathname metadata or submission. Preserve `failed`, the no-domain-request
guarantee, all shapes and enums, and the independent profile versions. Planning's
existing L subject for an over-limit default handler should explicitly distinguish
the necessary discovery read from forbidden subsequent metadata/submission, with
the over-limit-target subject positively checking zero discovery reads. Reconcile
the composed search description and any affected current-state explanation in
integration; this review changes none of them.

## Checked and accepted

- **Short-path stage ownership and precedence — supported.** The target remains
  first; named/default application absence remains distinct; application-location
  cycles and impossible names are `failed`; and Finder's identifier mismatch is
  `APPLICATION_NOT_INSTALLED`. Exact selection/open/reveal sources and their
  relevant tests support these mappings. Constrained candidates stop at the
  first match, retaining the preferred registration's fallback position and
  established-absent skips. No limit applies to an unequal candidate. The
  explicit change to skip an unequal candidate without acquiring unused bundle
  metadata has a reason and L subjects; it is not a claim that unknown equality
  is safe to skip.
- **Cycle state and budget — supported within the stated observation limits.**
  The containing directory, link text and exact pending suffix determine the
  next expansion. Link identity is needed for the stated changed-text check,
  not for the expansion's meaning. Distinct containing directories avoid the
  earlier finite hard-linked-symlink counterexample. Exact suffixes preserve
  finite dot-link progress and trailing-directory demands. Resolution after 32
  expansions succeeds; needing 33 fails. A self-extending link may be logically
  unresolvable without repeating this state, but reporting the actually exhausted
  budget is conservative and explicitly disclosed, not a false absence proof.
- **Terminal metadata, permissions and reveal root — supported as a design;
  native parity remains pending.** A plain terminal directory is inspected from
  its parent without opening it. A remaining `.` or `..` still requires reaching
  the directory through which lookup continues; it is not permission to erase
  those components before deciding descent. The trailing separator requires a
  directory without turning a plain terminal directory into a listing read.
  Reveal retains the literal path's no-follow discriminator, while presence
  follows the final link. Apple's pinned
  [lookup source](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_lookup.c)
  explicitly follows links when a trailing separator requires it and rejects a
  non-directory terminal with that demand. Thus a root link without a slash is
  the link, and with a slash it names the root. The retained native adapter and
  `docs/verification/reveal-path-vm.md` provide the original root rule, including
  physical `/var/..`. The spec adds appropriate mode-0600 and root/link subjects;
  this review supplies no new runtime result.
- **Name-limit proof — supported and deliberately conservative.** Lookup
  success wins. Only a failed component lookup plus a returned finite limit and
  ASCII unit-independent excess proves the specified impossible-name branch;
  non-ASCII and indeterminate-limit failures stay `failed`. Existing absence
  branches remain available for ordinary missing names regardless of encoding.
  No speculative creation or new Unicode validity predicate is introduced.
- **Addressing and retained native facts — supported in the staged spec.**
  Classification and bundle identifiers use the resolved spelling; default
  handler discovery uses the literal target; submission uses the registered
  application and literal target. Required facts stay distinct from established
  optional nils. No-type, no-handler and no-identifier meanings, payload refusal,
  acknowledgment, optional receipt, cancellation/deadline, grants and no replay
  remain stated. R1 is the public description's conflicting ordering promise.
- **ADRs and seams — supported.** The descriptor-relative ADR owns the access
  decision and its prompt/descriptor costs; the liftable application limit stays
  in the spec. No extra public module or substitute protocol is introduced.
  Workspace's existing private native enabling point serves L substitution;
  independent native binaries and signed VMs retain their separate obligations.
  The schema-only 1.0.1 delta, retained 1.0.0 and search 1.1.0 subjects, and action
  fixtures versus actual-search provenance remain distinct.
- **Acceptance limits — unresolved and visible.** Search-only first-use prompts,
  actual descriptor-walk parity, the action boundary and binary/public/signed-VM
  outcomes remain planning's. A prompt still returns to Antony under the settled
  decision; no workaround, new consent, shorter search ceiling or long-path
  application support is inferred.

## Review evidence and limits

Read k168's running log and committed design changes; the brief chain, glossary
and cited ADRs; the relevant workflow requirements; the revised action spec,
exact repair SDL and search composition;
the affected guide/search handoff, editable long-location flow and captions;
the retained selection/open/reveal/native sources and relevant provider tests;
and recorded boundary/prototype/reveal evidence. k168 records its deterministic
design checks as passing; they were inspected, not rerun. No test, build, lint,
format, render or native experiment ran, and no design, production or test file
was changed. Primary kernel source supports the stated lookup semantics, not
new signed-macOS acceptance. Graph startup and coverage were unavailable as
recorded above, so the conclusions are bounded source/document evidence.
