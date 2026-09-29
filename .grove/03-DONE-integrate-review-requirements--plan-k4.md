# plan-k4

**Integrates:** plan-k2

## Goal

Triage `plan-k2`'s review of the agreed requirements and apply the real
findings to `docs/requirements/modaliser-workflows.md` before `providers-k3`
plans from it. Apply the scope change Antony made during that review as well.

## Context

- Read the findings and the running decision log from `plan-k2`'s own commit.
  This body names the review and does not restate them.
- `plan-k1` holds the configuration evidence and the settled interview
  decisions the findings are graded against.

## Done when

The requirements document reflects the human scope change recorded in
`plan-k2`'s running log. Each finding is classified as a contract stated
unclearly, a real issue, a visible trade-off, or noise, with the document
changed accordingly. Findings whose answer is Antony's are settled with him,
or explicitly left open for design with his agreement. The root brief's
decomposition and pointers stay consistent with the narrowed baseline.

## Notes

Several findings ask Antony for a scope or risk decision rather than an
edit, so expect to stop and ask. Frame each as a trade-off with a
recommendation. The design questions listed in the review are planning's and
design's, not this leaf's; carry them forward rather than answering them here.

The scope change reaches beyond the requirements document. The root brief
still says "all active bindings" (`_BRIEF.md:28`). `providers-k3`'s notes still
ask how to design VS Code parts/Grove and the nested Zellij/Neovim chain.
Align both with the narrowed baseline.

## Decisions (running log)

Read the review and its running log from `plan-k2`'s commit `ba8b387f90e2`.
Its human scope change governs: remove Zellij and Neovim support, narrow
terminal context to the host and herdr, and defer the VS Code screen workflows
while retaining the Visual Studio Code launcher. Apply this to the requirements,
root brief and planning leaf; preserve the earlier leaves as historical evidence.
The deferred workflows receive no design or acceptance work in this increment.

R5 and R6 are real issues: direct reads of the active config and installed
Scheme mirror confirm native geometry and row state that the inventory omitted.
Added requirements for window occlusion/stacking, iTerm pane placement and title
fallbacks, herdr jump-target geometry (including the configured tab/Space/agent
mini-labels), current/focused rows, agent status and worktree switchability.
Rendering, label assignment and ordering stay client-owned. The review's claim
that all geometry is AX-derived is too broad: herdr combines tool layout and
host geometry; the requirement stays independent of that mechanism.

R7 is a contract stated unclearly. The already approved launch/search/setup
workflows lift the existing non-running-application and broad-discovery
exclusions to that extent. Named those extensions without rewriting the served
spec or ADRs as though the new design already existed. Planning must commission
their reconciliation. Cross-provider identity remains a design question, not
an implied new requirement.

R10 is a contract stated unclearly, with a visible accepted trade-off already
present in `plan-k1`'s "need not invalidate" decision. Preserve conservative
invalidation: acceptance now requires either the validated original action or
an explicit unavailable result and fresh selection; substitution fails. Do not
silently strengthen the agreement into guaranteed invocation after a sibling
change.

The review's six design questions stay with planning. Recorded them explicitly
in `providers-k3`, including the closed error vocabulary, passive menu
population, screen-point ownership, clipboard allocation, required iTerm host
and client-presentation declarations. Any incompatible contract version change
still belongs to Antony.

Antony answered **"all recommended"** to the five explicit questions. R1:
keystroke delivery, menu invocation and window focus must be separately
grantable. R8: use dedicated test accounts/data in isolated VMs, with unavailable
accounts leaving the affected cases pending. R9: defer status-item and Dock
menus; application menu bars and context menus remain required.

For R2, Antony accepted cleanup on grant revocation, bounded inactivity and
orderly shutdown, with abrupt-crash residual effects as an explicit limitation
requiring recovery guidance rather than a claim of successful cleanup. Design
chooses and documents the timeout and recovery mechanism. For R3–R4, stop on
observable target foreground loss, with an explicit exception for declared
client presentation. Send no Escape/cancel to the new foreground app; release
only Koine-owned modifiers even if that app observes key-up. The exception's
declaration mechanism belongs to design and must not treat client display
labels as authenticated identities. These decisions settle the pending scope
and risk questions; they do not claim implementation or native feasibility.

## Findings triage

| Finding | Classification and disposition |
| --- | --- |
| R1 | Real issue; repaired with Antony's decision requiring separately grantable input, menu invocation and window focus, plus an authority trace and denied/revoked-grant acceptance. Provider layout remains design work. |
| R2 | Real issue; repaired with cleanup on revocation, bounded abandonment and orderly shutdown. Abrupt-crash residual effects are an explicitly accepted trade-off with recovery guidance and unconfirmed outcomes. Design owns the timeout and recovery mechanism. |
| R3 | Contract stated unclearly; repaired for both Dia and menus. No Escape/cancel reaches the newly active app; Antony explicitly permits release of only Koine-owned modifiers even if the app observes key-up. Acceptance covers the exception. |
| R4 | Contract stated unclearly; repaired with observable target foreground loss, regardless of who caused it, for Dia and all explicitly opened menus. Declared client presentation is an explicit exception; design must define it without trusting client display labels as authenticated identity. |
| R5 | Real issue; repaired by explicit native geometry and visibility requirements and acceptance. The claim that all geometry comes from AX is noise for want of context; herdr also supplies layout. |
| R6 | Real issue; repaired by naming the required list state and acceptance. |
| R7 | Contract stated unclearly; repaired by naming the bounded scope extensions and requiring downstream spec/ADR reconciliation. |
| R8 | Real issue; repaired with dedicated test accounts/data in isolated VMs for the named apps. Antony agreed that unavailable accounts leave affected cases pending rather than passing. |
| R9 | Contract stated unclearly; repaired by Antony's explicit deferral of status-item and Dock menus. Application menu bars and context menus remain required. |
| R10 | Contract stated unclearly; preserved the visible trade-off allowing conservative invalidation and made its passing outcomes explicit. |

## Evidence

Tier 2 verification, Koine graph generation `2026-09-29T10:36:20Z` (fast).
Coverage checked for the glossary, requirements, cited ADRs, relevant Machine
spec, Taskfile and task/brief chain. `docs/` is excluded; task files have changed
or untracked metadata. All relied-on text and spec sections were read directly,
and the review was read from its own commit. This integration makes no structural
claim about Koine's code.

The active user config and installed Scheme mirror are outside this repository
index and were read directly. Relevant evidence: `config.scm:174-205`,
`app-trees/com.googlecode.iterm2.scm:78-117`, `app-trees/herdr.scm:65-115`,
`app-trees/company.thebrowser.dia.scm:115-150`; mirrored library
`blocks/window-list.sld:371-410`, `blocks/iterm-panes.sld:112-196`,
`blocks/iterm-tabs.sld:130-150`, `blocks/herdr-list.sld:72-110,410-479`, and
`muxes/herdr.sld:1030-1120`. These establish the reviewed behavior, not a new
runtime acceptance claim. No live desktop operations were performed.

Verification: `task check:docs` passed on the final requirements. SHA-256
manifests of the repository's Markdown files, `Taskfile.yml` and
`scripts/check-doc-links.py` matched before and after the run. The final diff
was read against R1–R10 and the approved scope/decision changes; the requirements,
root brief and planning handoff agree. Only documentation changed, so native
runtime tests are downstream acceptance rather than this integration's check.
The root still has live `providers-k3`; there is no parent closure to perform.
