# search-path-resolution-k125

**Integrates:** search-path-resolution-k124

## Goal

Triage the findings of `search-path-resolution-k124` against the resolution,
pre-open policy, spelling and file-name design from
`search-path-resolution-k122`, then apply the real ones. Classification
`search-path-classification-k123` must consume a path contract that it can
build on without rediscovering these defects.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `7ec0af50ea38`, whose coordinates
  equal the review's tree.
- The artifact:
  - `docs/specs/workspace-search.md`, including k119's in-process phase table and
    the selection handoff;
  - `docs/verification/search-canonical-paths.md`;
  - the search ADRs and the traversal ADR;
  - CONTEXT, the SDL and examples, the client guide and the workflow trace;
  - the six search views with their exports, captions, manifest and README;
  - the brief chain.
- One finding touches the separate launch-and-open contract,
  `docs/specs/workspace-launch-and-open.md`. Route any change there through its
  own increment, or escalate it, rather than editing it in place.
- Approval is unchanged. None of the following is authorized:
  - a new consent, entitlement, usage key, setup or private long-path policy;
  - a raised limit or account;
  - a shorter public ceiling or a smaller domain;
  - an incompatible version;
  - a changed k119 call set.
- Lost workflow coverage goes to `protected-home-search-k93` before it becomes a
  dependency.

## Done when

- Classify every finding as one of:
  - a contract stated unclearly;
  - valid and actionable;
  - a visible trade-off;
  - noise.

  Record the verdict and its reason in the running log, and apply the actionable
  repairs in place across every affected durable artifact and summary.
- Escalate before relying on a change that alters workflow coverage, approval
  posture, k119's call set or another increment's contract.
- Regenerate the changed views, and run `task design:search-render`,
  `task design:search-check` and `task check:docs` on frozen inputs.
- A repair may amount to substantive redesign. If so, externalize it as a design
  producer with its own load-bearing review, placed ahead of k123.
- k123 then consumes the reconciled path artifact. k120 and planning k30 still
  wait on k123's chain.

## Notes

Design triage only: no implementation and no native evidence chain. All native,
binary, prompt and useful-coverage acceptance remains pending.

## Decisions (running log)

- Adopt the mandated leaf in the stated jj workspace. The working copy is empty
  on review commit `c0ece7a8`; its findings are read from that commit's k124 leaf,
  against producer `7ec0af50ea38`. The graph CLI `list_projects` refused an active
  pre-coordination/unverified generation. This document-only integration uses
  direct artifact reads and makes no graph, code-completeness or native claim.
- **P1 — valid and actionable; externalize redesign.** The region replay closes
  A/B, but the metadata bracket and final commit require a held candidate; the
  phase table has no replay/reacquisition step. Context-specific replay, identity
  versus spelling membership, root-stream conversion and charged re-establishment
  need a design producer and mandatory review before k123. Mark the selected
  choreography incomplete instead of inventing extra calls or a third descriptor.
- **P2 — valid and actionable; externalize with pre-open witnesses.** Home/cloud
  policy does not establish prompt-free transit onto an unknown foreign mount.
  A no-follow child's device observation can reject an unestablished transition
  before open; bootstrap/startup-pair/Preboot exceptions and uncertainty still
  need an explicit bounded rule. A producer must settle it with removable,
  network, image and nested-mount subjects; no new consent class is approved.
- **P3 — valid and actionable; same witness producer.** A blocked route's symlink
  supplies no target identity. The artifact does not define when its target is
  already blocked by an established ancestor, when another alias proof is
  required, or which work fails without that proof. Literal-only blocking or
  failing all home work would change the contract. Resolve those cases and
  refusal scopes under the existing accounts before k123, with mandatory review.
- **P4 — valid and actionable; disclose and route through launch-and-open.**
  Search permits returned values through 8,192 bytes, while the action inspection
  contract uses PATH_MAX-limited calls and classes overlength as not found.
  Discovery cannot promise those choices actionable. Add the missing handoff
  disclosure and long-result action subjects here; a design producer in the
  launch-and-open increment owns any action-route/error change and its mandatory
  review. No shorter search ceiling, automatic selector fallback, disabled-action
  baseline or workflow loss is accepted; k93 must consume measured loss.
- **P5 — valid and actionable; externalize with replay/observation phases.**
  Native size alone does not establish movement, yet current/prefix refusal
  stops a root where dequeue's independently established target refusal stays
  exact. Target identity/association does not by itself establish every required
  fresh policy proof. The producer must distinguish missing shared proof from
  proved-independent size, preserve names and settle continuation or justify
  the conservative stop with its actual omissions before k123's review chain.
- **P6 — a contract stated unclearly; repair in place.** Apple's public open
  manual explicitly assigns ELOOP to O_NOFOLLOW encountering a symlink. After
  the directory probe, that is the context's changed type/association outcome,
  not proof of a link cycle. Keep bounded-hop guidance for expansion 33 only;
  unexplained errors remain uncertainty. No retry or post-refusal inspection.
- **P7 — valid and actionable; repair the ADR in place.** File queue, descendant
  prefix and exact-path dedup mechanics belong in the search spec. Keep the
  application naming decision, first finalized retained spelling, rejected
  identity-history alternative and a spec citation; add no superseding record.
- Cut `search-preopen-witnesses-k126` then `search-path-observation-phases-k127`
  immediately ahead of k123; each producer must insert its mandatory review
  before its next consumer. Cut `long-search-result-actions-k128` in the earlier
  launch-and-open node, with its mandatory design review before search consumers.
  No redesign is implemented here and no in-session reviewer is spent. The
  briefs/consumers and k93 carry these dependencies and actual omissions.
- Applied P6's no-follow type-change versus expansion-33 wording and construction
  subject, with Apple's public open manual as explanatory evidence. Removed P7's
  file-traversal mechanics from the existing naming ADR; its slug and citations
  remain. The spec, verification, SDL/examples, guide, glossary, workflow trace,
  six viewer sources/captions/manifest/README and all consumer briefs disclose
  unresolved witness/replay/size/action seams. Launch/open's durable contract is
  untouched; no native outcomes, acceptance or changed k119 calls are supplied.
- Verification passed: `task design:search-render` regenerated all eight exports;
  exactly the six revised views changed, all eight parse as SVG XML, and each
  revised export contains its required repair/disclosure labels.
  `task design:search-check` passed independent/composed SDL and search/action
  examples, including removed-root/input-output/foreign-type rejection controls.
  `task check:docs` passed. Per-file SHA-256 before/after comparisons confirmed
  268 frozen subjects unchanged: every non-excluded repository Markdown file,
  all docs files except the eight search SVG outputs, Taskfile.yml, the docs
  checker and contract-client package/lock. Temporary manifests retain each
  filename/digest separately; no run inferred completion from its launcher.
- A parent-versus-current parsed SDL comparison with descriptions removed is
  identical, and jj reports no diff to the launch/open durable spec. These checks
  establish design consistency, not native/prompt/useful-coverage/binary behavior.
  The ADR identity/citations remain unchanged; the docs-link check validates them.
- Retirement can close no ancestor: k19 still holds k126/k127/k123/k120, k7 still
  holds planning k30, and the root holds those and the earlier k128 action chain
  plus other increments. No promotion/close cascade is earned. Commit this
  integration and its tree edits together; the next driver walk reaches k128 in
  launch-and-open before the search producer repairs.
