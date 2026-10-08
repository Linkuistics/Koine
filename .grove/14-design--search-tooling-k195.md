# search-tooling-k195


## Goal

Choose an existing OS facility or established tool for Koine's application and
file search, replacing the assumption that Koine will build a search engine
from scratch. Deliver a focused, reviewable mechanism design and reconcile the
earlier custom traversal/witness work before that work resumes.

## Context

- Search-preopen-metadata-k190 records Antony's clarification: search is welcome
  in Koine, permission/dialog behavior must be dealt with, and the search engine
  should reuse other OS tools. He suggested rg/fzf but selected no dependency.
  The earlier client-owned-search suggestion was followed by explicit Koine
  ownership; do not remove file search or reopen the chooser boundary.
- docs/requirements/modaliser-workflows.md, Ownership and existing constraints
  and Test seams and acceptance, are the durable requirements. Koine supplies
  native application discovery/metadata and native actions; client presentation,
  chooser and MRU remain client-owned. Existing action-time path resolution is
  separate from search enumeration and is not rejected by this requirement.
- docs/specs/workspace-search.md and its SDL/examples/views carry the earlier
  candidate. The search node app-and-file-search-k7, native-resource chain k109,
  witness node k126 and subsequent k127/k123/k120/k30 are still live. Read only
  the parts material to backend selection before deciding which work remains.
- Relevant bounded evidence: docs/verification/search-discovery.md,
  protected-path-metadata.md and descriptor-walk-prompt.md. They do not accept a
  tool-backed search route. docs/verification/search-preopen-boundary.md explains
  the old target-inspection questions, foreign-call lifecycle and account limits.
- Prefer primary current sources for existing engines and macOS services. The
  ripgrep guide documents --files and filtering:
  https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md . Fzf's upstream README
  documents list input, its walker and filtering:
  https://github.com/junegunn/fzf/blob/master/README.md . These were read for
  requirements framing, not as an engine selection or native measurement.

## Done when

- Make one finite comparison and select a concrete reuse route for ordinary
  file discovery and macOS application discovery/metadata. Consider native
  services/commands and established tools; justify the smallest adapter. State
  what supplies candidates, what supplies matching, and what remains client
  presentation. Do not design another custom filesystem traversal engine or
  hand-code a replacement search/matching engine under an adapter label.
- For applications, state how conventional and OS-reported installation
  locations, bundle metadata and registration contribute. Spotlight or
  LaunchServices state may be unavailable, stale or incomplete; distinguish that
  from an empty healthy result and state an honest discovery scope. Do not claim
  an exhaustive inventory of every application anywhere on disk without proof.
- Specify backend invocation or library interface, availability/distribution,
  input/output parsing, result limits, cancellation and worker cleanup. If a
  subprocess is selected, reconcile the earlier single-process/helper and
  resource decisions explicitly; do not carry their guarantees over unchanged
  or infer a privileged helper, entitlement, signing change or new consent.
- Preserve the prompt-free read requirement and separate explicit setup from
  ordinary queries. Identify the actual permission boundary and responsible
  identity, including child processes if used. Reuse does not prove no-dialog
  access. Derive necessary excluded scopes/diagnostics and the finite native
  acceptance subjects from the selected route, with independent dialog/hydration
  observation and positive controls. No native experiment or evidence chain is
  part of this design leaf; an approval gap gets a concrete human decision.
- Reconcile the search requirements/spec, SDL/examples, relevant ADRs, guide,
  glossary, workflow trace and visual summaries. Keep launch/open/reveal's
  existing action contracts. Separate product requirements from account, mount,
  traversal and witness mechanics that belonged only to the old candidate.
- Reconcile every live search work item with the chosen route: retain necessary
  native metadata/permission/acceptance work, rewrite applicable charters, and
  identify genuinely obsolete custom-engine work. Do not silently mark old
  obligations passed or prune ambiguous shared work. Explicitly settle whether
  relocated-target protection and lookup-only witness acquisition still need
  k190's original decision; k190 selected neither. If needed, cut a focused
  requirements leaf before its consumer, with the concrete remaining choice.
- Reuse the agreed GraphQL/native-binary/isolated-VM seams. Produce focused
  acceptance subjects, not an open-ended formal/filesystem evidence program.
  Run the affected Taskfile checks on frozen inputs and inspect changed views.
- Cut a mandatory review-design of search-tooling-k195 before
  app-and-file-search-k7 using leaf-insert, with this handle under Reviews. Its
  earned integration must also precede that node. Existing search work resumes
  only against the reconciled reviewed mechanism. This leaf does not implement
  the backend or certify its native behavior.

## Notes

The human approved the reuse requirement, not rg, fzf, Spotlight or a new
permission/setup contract. Target an ordinary, useful search feature with a
small integration layer. Existing observations have their original bounds;
acceptance still exercises the actual signed Koine and backend. Surface a real
platform limit once with a concrete consequence instead of growing a deeper
chain to manufacture a guarantee the platform cannot provide.
