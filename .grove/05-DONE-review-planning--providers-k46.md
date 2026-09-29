# providers-k46

**Reviews:** providers-k3

## Goal

Adversarially read `providers-k3`'s decomposition before any design runs.
Several months of increments build on its ordering, boundaries and charters.
Report findings; do not fix them.

## Context

- `providers-k3`'s commit: the root brief's decomposition and coverage table,
  every new node brief and leaf body, and the running log in the retired
  planning leaf.
- `docs/requirements/modaliser-workflows.md` is the agreed scope and
  acceptance. `plan-k4` holds the narrowed baseline and its decisions.
- `docs/specs/machine.md` and the ADRs define the contract the increments
  extend.

## Done when

A findings report anchored to the planning commit separates real
decomposition defects from accepted trade-offs and noise. Worthwhile findings
reach an adjacent integration leaf through the review kind's procedure. An
empty review cuts nothing.

## Notes

Test these doubts in particular:

- **Working increments.** Does each increment node leave Koine working and
  deliver behavior a standalone client can demonstrate? Is any increment
  really a horizontal layer, or two stages that cannot be green apart, or too
  large to be one stage?
- **Ordering.** The questions are:
  - Is `provider-architecture` rightly first and rightly scoped? It covers
    capability separation, the cross-provider reference rule, error
    classification, scope and clipboard allocation.
  - Is `launch-and-open` the right pathfinder?
  - Does the interaction lifecycle belong in `held-interactions`, ahead of
    `context-menus`?
  - Does `iterm` rightly precede `herdr`?
  - Is placing `account-acceptance` late acceptable, given it is HITL?
- **Coverage.** Does every inventory row, label and list-state requirement,
  menu scenario, interaction requirement and acceptance bullet map to an
  increment and a client responsibility? Check this against the requirements
  themselves, not only the root brief's table.
- **Evidence discipline.** Is every evidence leaf bounded to one named decision,
  with an explicit stop? Are any native-feasibility questions missing, or
  placed after the design that depends on them? Candidates include the signing
  posture, VM display count, TCC-protected search and media routing.
- **Laziness.** Is any leaf speculative? Is any precise question from the
  planning leaf's notes lost, left as fog, or placed where no session will meet
  it?

## Decisions (running log)

Reviewed the committed planning artifact at
`95f41cd613706dd2679c07aed24d2477a6824e02`. The working copy began empty on
that commit, so there was no intervening artifact drift to reconcile. This is
a findings-only review; no production, test, requirement or design changes and
no test, build, lint, format or VM runs belong to it.

The increment order is viable, subject to the acceptance ownership and
completion-contract findings below. Authority-first design, a launch
pathfinder, Dia as the lifecycle's first consumer, iTerm before herdr, and late
account provisioning are accepted choices. The pending-account decision does
not itself authorize closing an unaccepted baseline. An adjacent
`integrate-review-planning` leaf is warranted to triage the findings before
`provider-architecture-k5` runs.

## Findings

All coordinates below refer to planning commit
`95f41cd613706dd2679c07aed24d2477a6824e02`, before this review's integration
insertion renumbers siblings. Resolve the named handles for current paths.

### R1 — Give transferred shortcut rows a receiving acceptance owner (medium)

At `.grove/11-k10/_app-input.md:14-23`, `app-input-k10` may transfer a row
implemented through menu invocation into `menu-bar`, but its next completion
bullet still requires the outcomes for Safari, Finder, Zed, Obsidian, Zotero and
ordinary Dia operations in this earlier increment. If one of those outcomes
needs a menu action, the node cannot satisfy that bullet without waiting for
the later sibling it just delegated to.

The receiving charter does not close the handoff:
`.grove/12-k11/_menu-bar.md:11-34` and
`.grove/12-k11/02-design--menu-bar-k36.md:7-26` cover general menu behavior and
menu validation, but do not take the transferred intended-result table as an
input or require those workflow outcomes. A row needing an explicitly opened
submenu depends on `context-menus-k13` as well, since menu-bar intentionally
does not open menus. Independently, `app-input-k34` sends all "unverified or
account-dependent" rows to account acceptance at
`.grove/11-k10/02-design--app-input-k34.md:29-32`, while
`.grove/17-k16/02-impl--account-acceptance-k45.md:3-6` charters that leaf only
for Signal, Slack, Telegram, Messages and Mail. An unverified Finder or Zed
row, for example, is not an account-provisioning case.

These are conditional handoff defects, not a claim that any particular
shortcut already needs menus or fails. Both routes are expressly allowed by
the plan, so their owners must exist before design chooses them. Otherwise a
node either cannot close independently or leaves a row to be rediscovered by
the final acceptance sweep.

Integration should make row ownership explicit when the mechanism is chosen:
the input increment closes on its delivered and demonstrated subset; receiving
menu/opening increments take the transferred rows and their intended outcomes;
only cases actually requiring accounts wait for account acceptance. Preserve
the full baseline and carry those owners into the root coverage table.

### R2 — Distinguish a pending acceptance report from baseline completion (medium)

At `.grove/18-impl--baseline-acceptance-k17.md:5-8`, the goal allows closing
the baseline with cases merely listed as pending. Its completion contract then
requires a client demonstrating every row (`:18-20`), directs a status change
in the requirements (`:27-28`), and also permits pending account/data cases
(`:31`). Those conditions have different answers when, for example, no
dedicated Messages account is available.

The account subtree explicitly anticipates that situation:
`.grove/17-k16/01-impl--test-accounts-k28.md:13-20` permits an unavailable
account as the provisioning result, and `account-acceptance-k45:19` leaves
the cases pending. That is the accepted human decision, but
`docs/requirements/modaliser-workflows.md:326-333` says an untested limitation
does not pass acceptance. Listing the pending case cannot also demonstrate
every row or close the root's delivery obligation.

Clarify the final leaf's completion rule and the account node's corresponding
closure rule. A partial report may be useful, but the unaccepted cases must
remain identifiable live work or an explicit escalation under Grove's
retirement procedure, with truthful public acceptance status. Do not make a
pending list an alternative passing outcome. This does not require moving
provisioning earlier or changing the agreement about unavailable accounts.

### R3 — Align the app-input completion promise with its bounded evidence task (medium)

At `.grove/11-k10/_app-input.md:11-13`, the completion condition says input
reaches only the captured target and that nothing is sent elsewhere. In the
same node, `.grove/11-k10/01-design--app-input-evidence-k22.md:19-25` expressly
considers session posting after a foreground check and asks what happens when
foreground changes between checking and delivery. Its stop rule (`:35-36`)
allows the result to be a stated native limit.

The requirements preserve the documented native limits and prohibit deliberate
retargeting, rather than promising protection from every platform race
(`docs/requirements/modaliser-workflows.md:64-67,234-239`). An evidence report
that identifies such a race can therefore satisfy the evidence leaf while
leaving the node's unqualified completion condition unsatisfied. The root's
bounded-evidence policy should not depend on a future session quietly weakening
that condition or reopening an unlimited search for stronger native identity.

Align the node's acceptance with the distinction between Koine preserving and
checking the chosen target, refusing known mismatches, and the native delivery
guarantee actually established by evidence. Retain escalation for any proposed
new limitation that changes the agreed baseline. This is a charter ambiguity,
not a finding that a particular keyboard API is unsafe or that the existing AX
decision already settles every synthesized-input race.

### Checked and accepted

- **Authority and pathfinder.** `provider-architecture-k5` names the concrete
  cross-provider reference/capability conflict, covers every effect including
  clipboard allocation and setup, and leaves operation shapes to the
  increments. Resolving it first is justified. `launch-and-open-k29` requires
  packaging, approval, loader, schema, client and real VM behavior with the
  first operation, so the first implementation cannot be a dead framework
  layer. Later implementation remains lazily planned after design.
- **Menu and interaction order.** Passive menu discovery and validated
  invocation are useful before explicit opening. Reporting needs-opening is
  an honest intermediate result; complete lazy-menu access belongs to
  `context-menus-k13`. `held-interactions-k39` expressly lands the lifecycle
  with Dia and every cleanup trigger, rather than shipping an unused service.
  Context menus then reuse it for both point/focused-element targets and
  opened menu-bar submenus. R1 concerns transferred workflow acceptance, not
  this general ordering.
- **Terminal order.** iTerm's design exposes session identity for herdr;
  herdr's evidence checks instance mapping, protocol access and geometry before
  its API design. Multiple/nested instances, equal labels, scoped actions,
  copy-mode versus scrollback, non-forcing removal, detach versus stop, and
  the inherited host-split label bug all have named owners.
- **Late accounts.** Implementing available input behavior before human
  provisioning keeps earlier work useful. Dedicated accounts, real outcomes,
  Signal/Messages verification and explicit pending cases are retained. R2
  concerns completion with pending cases, not their late placement.
- **Bounded native evidence.** TCC-protected search and unavailable indexes
  are assigned to `app-and-file-search-k19`; display count and ambiguous
  stacking association to `window-stacking-evidence-k20`; system media routing
  and cursor reveal to `pointer-and-media-k21`; native menu metadata,
  population, validation and dismissal to `menu-evidence-k23`; modifier
  ownership, foreground attribution and crash recovery to
  `held-input-evidence-k24`; hardened-runtime iTerm mechanisms and new
  entitlement/consent consequences to `iterm-evidence-k26`; herdr reachability
  and geometry to `herdr-evidence-k27`. Each precedes its consuming API design
  or supplies evidence within that design before its decisions. The root
  applies signing-posture escalation to all increments, not only iTerm. These
  are named decision questions rather than speculative implementation leaves.
- **Other inherited planning questions.** Error classification and scope
  reconciliation are in `provider-architecture-k5`; passive population in
  `menu-evidence-k23` and `menu-bar-k36`; screen-point ownership in
  `context-menus-k25`; inactivity, grant cleanup and client-presentation
  declarations in `interaction-lifecycle-k38`; cross-provider terminal
  identity in `provider-architecture-k5` or, under its stated constraint,
  `herdr-k43`. None needs a new evidence chain merely because its answer is
  not known at planning time.

### Coverage read against the requirements

This is planning ownership, not runtime acceptance. Each group below was
checked against the actual inventory, list-state requirements, menu scenarios
and acceptance bullets, not inferred from the root's roll-up alone.

| Requirement group | Planned delivery and client responsibility | Review result |
| --- | --- | --- |
| Windows and displays | `window-layout-k8` supplies layout/restore, transfer/focus, geometry and stacking; `app-input-k10` supplies Space switching. Client owns labels, placement/rendering and MRU. | Covered, subject to R3 for input. |
| Named launchers, web search, client settings | `launch-and-open-k6` supplies activation, URL/path opening and reveal. Client owns keys, suggestions, typed-query fallback, settings reload and relaunch. | Covered. |
| Application and file search | `app-and-file-search-k7` supplies discovery, metadata and secondary actions through launch/open; clipboard ownership is assigned by architecture. Client owns query UI, chooser and MRU. | Covered. |
| Pointer and media | `pointer-and-media-k9` supplies location/reveal and system play/pause. Client draws the highlight. | Covered. |
| Safari, Finder, Zed, Obsidian, Zotero, ordinary Dia | `app-input-k10` chooses mechanisms and supplies input; menu mechanisms can move to later increments. Client keeps key maps. | R1 and R3. |
| Mail, Slack, Signal, Messages, Telegram | Same mechanism design; `account-acceptance-k16` supplies dedicated-account outcome checks. | R1-R3; late acceptance itself accepted. |
| Dia recent-tab walk | `held-interactions-k12` supplies holds, steps, confirm/cancel, interruption and recovery. Client owns navigation keys. | Covered. |
| iTerm and prerequisite setup | `iterm-k14` supplies pane/tab operations, titles, current state, untitled-pane fallback metadata and geometry, discovery/setup. Client owns labels and explicit setup invocation. | Covered. |
| Terminal context and all herdr rows | `herdr-k15` supplies instance targeting, scoped actions, label geometry and row state. Client owns chain navigation, labels/order and removal confirmation. | Covered. |
| Menu hierarchy, metadata, validation, permission failures | `menu-bar-k11` supplies passive discovery and validated invocation; `context-menus-k13` supplies lazy opening. Client presents menus. | Covered; transferred app workflows need R1. |
| Both context targets and opened-menu cleanup | `context-menus-k13`, on the lifecycle from `held-interactions-k12`, includes finish/cancel and every interruption/recovery case. | Covered. |
| Separate grants, authority trace, missing dependencies, three seams, versions and latency | Architecture assigns authority/classification; increments extend the trace and evidence; `baseline-acceptance-k17` consolidates it. | Covered in scope; final completion needs R2. |

## Review evidence and limits

Tier 2, project
`Users-antony-Development-Koine.add-plugins-for-modaliser-requirements`, graph
generation `2026-09-29T10:36:20Z` (fast). `index_status` and `list_projects`
confirmed this workspace. Coverage was checked for the complete planned tree,
the requirements, glossary, cited ADR set, Machine spec and Taskfile, plus the
bounded `.grove` scope. The documents under `docs/` are excluded; the planning
task files are untracked by the index and the root brief has changed metadata.
The scope query has no further page. These results do not establish graph
completeness.

All new node briefs and leaf bodies were read directly, along with the
producer's running log, root brief, integrated scope decisions, complete
requirements and ADR set, and the relevant contract and Taskfile sections.
The producer's diff and file inventory were inspected against the unchanged
starting tree. No structural implementation claim relies on graph absence,
and no source-code or native-feasibility audit is claimed. Runtime evidence is
the scheduled design/implementation work, not something this review reran.

Final inspection of the complete diff confirmed that content changes are this
report and the adjacent `providers-k47` integration charter; later planned
entries only moved. Grove resolves this review as DONE and the integration
immediately before architecture, with the root brief as its brief chain. The
root retains live work, so no ancestor closure or ADR promotion is due. The
insertion's coordinate warnings are the intentionally commit-anchored citations
above, not current-path links.
