# launch-and-open-k81

**Reviews:** launch-and-open-k29

## Goal

Adversarially read `launch-and-open-k29`'s implementation decomposition of the
workspace launch-and-open increment before any of it runs. Produce findings,
not fixes.

## Context

- `launch-and-open-k29`'s commit, including its decisions log, the new
  increment nodes and leaves under `launch-and-open-k6`, the updated node
  brief, and the root-level `alternate-team-signing-k80`.
- What the cut must cover:
  - the node brief's `Done when` and "Design handoff";
  - k29's concrete design obligations;
  - `docs/specs/workspace-launch-and-open.md#acceptance`;
  - `docs/specs/machine.md#selection-acceptance`.

## Done when

Each finding is recorded with the leaf or brief it concerns, or the review
states that it found none. An integration step is cut only if a finding is worth
acting on.

## Notes

These are the doubts the producer could not settle alone:

- The charter asked that "the first leaf" deliver one launch path end to end.
  The cut makes that slice a six-leaf node. Is each leaf really verifiable on
  its own, or is the node a horizontal stack whose behavior appears only in its
  last leaf?
- Does every row of both acceptance matrices, and every node `Done when`
  bullet, have a named owner at each assigned seam? The owner tables in the
  node brief and `selection-acceptance`'s brief are the claim to test, against
  the specs rather than against each other.
- The first slice implements the full application input, including the
  installation-path constraint, so that the served SDL stays verbatim.
  Multiple-copy V acceptance then comes late. Is that a dead layer, or a
  justified trade?
- Conformance grows by root, with the design SDL restricted to implemented roots.
  Can that rule let a missing coordinate or description pass?
- Is the order right? The selection matrix runs before the remaining
  operations, and the launcher preparation before URL and path work. Does the
  protected-path probe precede every consumer, including `app-and-file-search`?
- The largest leaves are `workspace-launch`, `provider-selection` and the
  selection harness. Is any of them plainly more than one session at a genuine
  seam that the cut missed?
- Unsigned development and test hosts admit no shipped candidate. Does the cut
  keep the existing suites meaningful through a private seam without creating a
  public test API?
- The certificate-dependent alternate-team cases are placed in a late
  root-level HITL leaf, and the node may close with only them pending. Is that
  consistent with the root brief's rule for pending cases?

## Decisions (running log)

Reviewed the decomposition against producer commit
`2e958cb0350beea2f5bbf7c743955e44728e0a1a`, the workspace and Machine acceptance
matrices, both cited ADRs and the brief chain. This is an inspection-only review;
no tests, builds, lint, formatting or native/VM experiments are run here.

Two findings warrant integration: the selection node permits only V certificate
deferral while its children also defer N/G, and the protected-path probe follows
the first consumer of its application-bundle/file-identity inspection. The
six-leaf first increment is an explicit, defensible session-size trade-off:
framework fixtures, desktop selection, management diagnostics, workspace launch,
VM observations and contract conformance each have an independently verifiable
deliverable. It does not meet the producer's first-leaf wording literally, but
does not require an otherwise dead layer to wait for a later sibling.

## Findings

The paths below are the current paths after inserting the integration step.
The reviewed producer is `launch-and-open-k29` at commit `2e958cb0350b`;
insertion changed sibling positions, not their bodies or stable handles.

### F1 — P2: The certificate exception cannot close the selection node as written

Affected: `selection-acceptance-k62`, `selection-decisions-k63`,
`selection-updates-k65`, and `alternate-team-signing-k80`.

The selection brief permits pending evidence only for a certificate-dependent
**V** case ([brief, line 11](08-k62/_selection-acceptance.md)). But the
alternate-team host's **N and G** parts explicitly remain pending for k80 when a
second team is unavailable ([k63, line 39](08-k62/01-impl--selection-decisions-k63.md)),
and the N/G trust-refusal leaf likewise defers real second-team signing
([k65, line 28](08-k62/03-impl--selection-updates-k65.md)). Its owner table assigns
those N/G parts only to k63/k65 and places k80 in the V column. Meanwhile
alternate-team-signing-k80, original line 24 correctly proposes to
run pending N, G **and** V cases.

Without the second certificate, these leaves can follow their own pending rules
yet leave their parent unable to satisfy its `Done when`. Grove's close check
must then stop or grow more work inside this early node, defeating the intended
late human dependency; treating those N/G parts as accepted would instead
weaken the contract. Reconcile the closure exception and seam ownership for the
exact certificate-dependent cases. Their late placement itself is consistent
with the root's policy: they remain live in k80, and baseline acceptance cannot
close around them. This finding does not ask to waive any pending case.

### F2 — P2: The protected-path probe follows an earlier metadata consumer

Affected: `workspace-launch-k59`, `protected-path-metadata-k73`, and the
`launch-path-k55` / `launch-and-open-k6` ordering.

The first launch implementation already accepts a registered installation path,
resolves symlinks, compares native file identity and checks application-bundle
presence ([k59, line 33](07-k55/04-impl--workspace-launch-k59.md)). Its input has
no exclusion for an application installed in Downloads, Documents or another
protected location. The later probe explicitly investigates these same
symlink, file-identity and application-bundle inspection primitives on first-use
protected locations ([k73, line 10](11-design--protected-path-metadata-k73.md)),
but its ordering and named consumers cover document opening, reveal and search
only. Launch has already been implemented and accepted for one application
before that question runs.

The spec requires metadata inspection to avoid consent prompts
([native policy, line 252](../../docs/specs/workspace-launch-and-open.md#ownership-native-design-and-alternatives)).
Testing the first launcher in `/Applications` does not establish that policy
for the full constrained input already published. This is an ordering gap,
not a claim that macOS will prompt. The bounded evidence question needs to
precede the first implementation that relies on these primitives, including
constrained launch, or the earlier slice needs an explicit independently
established prompt-free boundary. Preserve the settled complete-input/SDL
contract when resolving the dependency.

## Other reviewed choices

- The six-leaf first launch node has independently verifiable outputs at each
  step. The framework feature is exercised through fixtures and independent
  binaries; selection changes an existing desktop loading path; diagnostics
  add observable management behavior. The operation, VM observations and
  contract client then each have their own verification deliverable. Calling
  this expand-first does not itself invoke the mechanical-refactor exception;
  these concrete boundaries justify the cut. The end-to-end first slice is
  the node, as the producer's log explicitly states.
- Complete application input in k59 and later multiple-copy V acceptance in
  k78 are a visible trade-off, with the remaining seams kept pending. The
  implementation can be checked at L/G/N before the broader VM matrix, and
  the design descriptions stay verbatim. It is not a dead layer.
- The conformance rule requires an expected design contribution, verbatim,
  including reachable types and descriptions; k61 requires missing coordinates
  to fail and mutated expectations to be rejected. k77 requires the complete
  design SDL when the last root lands. An implementation deriving its expected
  roots from the served schema would violate that rule, rather than satisfy it.
- The two row-owner tables address the workspace and selection matrices,
  including shared framework/authorization work, exact-candidate profiles,
  old hosts, missing-owner cascades and the private seam for unsigned test
  hosts. F1 concerns the seam-specific pending exception, not absence of the
  late certificate work. Selection acceptance before later operation runs and
  reusable Dia/Zed preparation before URL/document cases are useful ordering
  choices; F2 identifies the earlier inspection dependency that remains.
- The largest leaves are substantial, but their private-adapter and loader
  enabling points provide meaningful verification boundaries. Source inspection
  does not establish that they cannot fit a session. Their executors must still
  decompose at a genuine seam if that proves necessary; no speculative size
  finding is raised here.

## Evidence and review limits

Read the producer's committed file set and decisions, both ancestor briefs,
all newly cut increment briefs and leaves, k80, both acceptance matrices, the
workspace SDL, the two cited ADRs, the workflow trace and existing Taskfile.
The planning commit contains task-tree changes only and records no new runtime
acceptance. No implementation or acceptance pass is claimed by this review.

Tier 2 graph project
`Users-antony-Development-Koine.add-plugins-for-modaliser-requirements` was ready
at generation `2026-09-29T10:36:20Z`. Targeted symbol searches and exact snippets
establish the current loader's per-root load path and the existing bundled-only
desktop composition test. The loader's both-direction depth-two trace returned
12 callees and one caller without truncation. A broad discovery query was
limited and used only to locate symbols; narrower queries supplied the evidence.
Coverage reported matching metadata and no recorded gaps for the inspected
loader/composition source. That is a best-effort signal, not proof of complete
graph coverage. Documentation is excluded; Taskfile/glossary metadata changed
and task-tree paths were untracked by the graph. Those artifacts were read
directly. The integration insertion only renumbers those inspected task paths.

The findings are the review's deliverable. `launch-and-open-k82` is placed
immediately before the first implementation node to triage them. Neither plan
fixes nor production/test-code edits are made in this session. The parent still
has live work, so retiring this review closes no ancestor.
