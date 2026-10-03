# Koine.add-plugins-for-modaliser-requirements — brief

## Goal

Add one or more Koine plugins supporting the existing Modaliser requirements
that Antony actually uses in his active Modaliser configuration. These will
become ModalAnyware requirements when that project is restarted.

Also provide access to application menu bars and context menus, an explicit
human addition beyond Modaliser's currently configured workflows, so clients
can expose those menus and their actions. Status-item and Dock menus are
deferred by agreement.

Human request: "create a new jj workspace `jw switch
add-plugins-for-modaliser-requirements`, and start a grove there to add one or
more plugins to support the existing Modaliser requirements (according to what
I use in my modaliser config), which will become ModalAnyware requirements once
we restart that project."

## Done when

The requirements session establishes the configured workflows and the Koine
capabilities they require, including the agreed application-menu access, with the
human, then the grove delivers the agreed plugin support. Plugin count and
boundaries follow those requirements.

## Decomposition

The human approved `docs/requirements/modaliser-workflows.md` from the active
bindings, then narrowed the baseline during `plan-k2`: Zellij and Neovim support
are removed; VS Code screen workflows are deferred, retaining its launcher.
`plan-k1` records the source evidence and initial interview decisions;
`plan-k2` records the scope change and `plan-k4` integrates it and the review.
Menu access includes the application menu bar and context menus, with explicit
opening, both context target modes, agreed metadata, cleanup and stale-selection
refusal. Status-item and Dock menus are deferred. `plan-k4` also settles separate
grants for input, menu invocation and window focus; bounded cleanup on
revocation, inactivity and orderly shutdown; foreground-loss cleanup with the
owned-modifier-release exception; and explicit abrupt-crash recovery limits.
Account-dependent acceptance uses dedicated test accounts/data in isolated VMs;
unavailable accounts leave affected cases pending. A pending case stays live
work, never a passing outcome, and the baseline does not close around it.

`providers-k3` split the work into dependency-ordered increments. Each is a
node that leaves Koine working and delivers behavior a standalone client can
demonstrate through the three agreed seams. The seams are public GraphQL, the
native binary interface and isolated TestAnyware macOS VMs. `review-planning`
reads this decomposition first. `provider-architecture` then settles what every
increment's authority depends on: provider layout, separately grantable input,
menu invocation and window focus, the allocation of every effect, error
classification, and scope reconciliation. Then, in order:

1. `launch-and-open` — the pathfinder, with the least native risk.
2. `app-and-file-search`.
3. `window-layout`.
4. `pointer-and-media`.
5. `app-input`.
6. `menu-bar`.
7. `held-interactions` — the Koine-owned lifecycle, with Dia as its first
   consumer.
8. `context-menus` — reuses that lifecycle.
9. `iterm`.
10. `herdr` — addressed through the iTerm session.
11. `account-acceptance` — HITL, late so it does not stall AFK work.
12. `alternate-team-signing` — HITL and late for the same reason. It covers the
    selection and trust cases that need a second Developer ID team's certificate.
    `launch-and-open-k29` added it.
13. `baseline-acceptance`.

`app-and-file-search-k92` externalizes `protected-home-search-k93` before
baseline acceptance: Antony must accept/disclose the explicit partial home domain
or approve a separate traversal-consent/setup contract. Review integration k95
also routes any proposed weakening through that decision with explicit final
bound-driven omissions; arbitrary default-search samples are not accepted.
Discovery review k102/k104 led to `search-traversal-k105`'s per-root FIFO
breadth-first work, bounded pending queue with matchable frontier anchors and
atomic process-wide descriptor credits below the inherited soft limit with
non-search reserve. Its load-bearing review must retire before planning. Narrow ownership/canonical-path/policy-account repairs retain native
acceptance; shallow-name loss and unrelated-work descriptor failures are defects
to repair, never accepted omissions. Default discovery/resource design awaits
load-bearing review before search
implementation planning. Prompt-risk transport's k99 review/k103 integration
clarifies no-progress failure classes, lifecycle errors and separate retained
versus search-release verification subjects; binary/runtime acceptance remains
pending. That is distinct from
`protected-default-open-k89`'s handler lookup, but any chosen setup must be
coordinated. No new consent, entitlement or usage key is approved by search.

Each increment resolves its bounded native-evidence question, then its API
design, before a trailing `planning` leaf cuts implementation.

Acceptance coverage. The increment named first supplies Koine's part. Each
row's client part is recorded in that increment's trace.

| Requirement area | Increment | Client responsibility |
| --- | --- | --- |
| Desktop windows | `window-layout`; Space switching in `app-input` | labels, chooser, MRU |
| Displays | `window-layout` | display labels |
| Named launchers | `launch-and-open` | key map |
| Application and file search | `app-and-file-search`, acting through `launch-and-open` | query entry, chooser, action menu, MRU |
| Web search | `launch-and-open` (URL opening) | query UI, suggestions, typed-query fallback |
| Media, pointer | `pointer-and-media` | highlight ring |
| Client settings | `launch-and-open` (open in Zed) | reload and relaunch |
| Safari, Finder, Zed, Obsidian, Zotero | `app-input`; menu-invoked rows in `menu-bar`, or `context-menus` where opening is needed | — |
| Dia | `app-input`, menu-invoked rows as above; the recent-tab walk in `held-interactions` | walk keys |
| Mail, Slack, Signal, Messages, Telegram | `app-input`, menu-invoked rows as above; acceptance in `account-acceptance` | — |
| iTerm and its setup | `iterm` | invoking setup explicitly |
| Terminal context, herdr rows | `herdr` | chain navigation, removal confirmation, status ordering |
| List and label state | `window-layout`, `iterm`, `herdr` | label assignment, placement, rendering, ordering |
| Menu bar | `menu-bar` | presentation |
| Context menus and explicit opening | `context-menus` | presentation |
| Separate grants | `provider-architecture`; tested in each increment | confirmation UI does not replace grants |
| Interruption and cleanup | `held-interactions`, `context-menus` | — |
| Operation-to-capability trace | every increment; closed by `baseline-acceptance` | — |

`provider-architecture-k5`'s design is in
`docs/specs/workflow-providers.md` and
`docs/adr/provider-authority-follows-effects.md`. The shared additions are in
`machine.md` under "Additional capability requirements" and the dependency
error note. All increments extend the workflow spec's cumulative trace with
concrete coordinates, complete grants and acceptance evidence. The pathfinder
implements the additional-capability framework feature together with workspace
launch/open, including old/new binary refusal and conformance profiles. New
operations remain designed/pending until their own acceptance is recorded.

`provider-architecture-k49` integrates that review. Every evidence/design leaf
uses the workflow spec's single selected-effect rule, including native primitive
semantics, parameters, preparation, fallback and cleanup. Antony accepted the
application-reaction limit; VM focus changes alone do not classify authority.
Pair native outcomes with inspection of the actual call paths. Application input
and menu operations refuse Koine's UI and recognized consent/security targets.
Space switching is separately system-directed and needs input plus desktop
control; pointer-button synthesis needs input wherever exposed. Cleanup authority
is included at admission. All reads remain consent-prompt-free.

`first-party-provider-selection-k50` defines reserved shipped identities and
independent per-user updates in the Machine spec's "First-party provider
selection" section and `docs/adr/first-party-provider-selection.md`. The sealed
catalogue survives missing
bundles; approved compatible newer copies keep shipped composition positions;
candidate diagnostics show refusals and selection never retries after a late
failure. Review `first-party-provider-selection-k51` and integration
`first-party-provider-selection-k52` settle the consuming contract before
launch-and-open: visible pre-load tie fallback, candidate-specific staging,
`first-party-selection-v1` old-host refusal, complete candidate diagnostics and
disjoint native module/class publication. Antony approved adding a stable release
signing identifier per shipped slot to the existing ID/Team-ID approval;
fixtures use distinct identifiers admitted only by test catalogues. Shipped
principal conflicts still
refuse both owners; verdict variability and startup cost are stated limits.
Launch-and-open implements the
selection acceptance table with its assigned seams, fresh host processes,
purpose-built signed catalogue fixtures and marker controls, alongside composition,
complete capability diagnostics
and exact-provider conformance. Launch and open
owns workspace grant disclosure, including any registered installed app and
document execution/redirects by handlers. Window layout
owns desktop grant disclosure, pointer/media extends it, and app-input/menu-bar
own their broad input/menu disclosures. Baseline acceptance checks those rows too.

## Pointers

- Existing application: `/Users/antony/Development/Modaliser`.
- Eventual client: `/Users/antony/Development/ModalAnyware`.
- Locate and read Antony's active Modaliser config; sample configs alone are
  not evidence of what he uses.
- Koine's current contract: `docs/specs/machine.md`, `docs/client-guide.md`,
  `docs/adr/`, and `CONTEXT.md`.
- Agreed extension requirements: `docs/requirements/modaliser-workflows.md`.
- Current scope and review integration: `plan-k2` and `plan-k4`; the source
  config still contains removed/deferred workflows and is not the scope by itself.

## Notes

The preceding Koine grove was torn down at commit `fc3b22d3`. This workspace
starts from that commit. Homebrew was updated and Koine 0.1.0 was installed
locally at `/Applications/Koine.app` at the human's request.

This request starts Koine plugin work; restarting or editing ModalAnyware is
not part of it. Read sibling projects as evidence for requirements. Establish
the actual configured behavior before choosing plugin boundaries or adding
functionality.

**Evidence stays bounded.** The preceding grove nested native evidence more
than thirty levels deep chasing guarantees public API cannot give. Its settled
answer was to accept and state the platform's limits, as in "Native targeting
discussion". Every evidence leaf here answers one named question for one named
decision. Where the guarantee is not there, the answer is a stated limit, an
unknown value, or an escalation to Antony, never a deeper chain.

Each increment installs the real applications its VM acceptance needs.
Reusable preparation, build and verification belong in `Taskfile.yml` as they
appear. A change to Koine's signing posture needs a decision recorded and
raised with Antony before it is built on; adding an entitlement or a new
consent is such a change. So does an incompatible contract-version change.
Modaliser's mechanisms are evidence of intended results, never a mechanism to
reproduce or a bug to freeze.


search-traversal-k107 integrates k106's ten findings. Current streams recheck
before every listing turn/read; changed queued prefixes/parents stop their root
once, avoiding per-task diagnostic fan-out. FIFO repeats checked component walks
against the wait; fixtures name preserved shallow project anchors and omitted
same-level/deeper contents. Lower-limit refusal compares summed reservations and
latches until cohort cleanup; one indefinite resource-failure cohort can require
process restart. Public coverage and traversal decisions now have separate ADRs;
private descriptor/cleanup mechanics remain in the spec. Native canonical-path
selection (search-canonical-paths-k108) and opaque resource-call/error plus
serviceability instruments (search-native-resources-k109) are externalized
design producers, each required to cut a load-bearing review before planning.
No native acceptance, shorter domain, new consent/setup or larger limit is
approved; k93 must consume actual per-witness omissions.

k110/k121's canonical review/integration keeps the public fsgetpath proposal
and unchanged value ceilings/domain, but requires resolver/pre-open policy,
cached spelling, representable directory-name/descent and long-path classification
design producers/reviews before k120's complete-resource review/planning.
Held identity self-comparison is not movement detection; ENOSPC alone is not
change. Shared-prefix failure stops one root; independent final-target failure
stays exact and checked-link failure stays per-candidate. Native witness failure
is dependency-scoped; witness-account overflow is job-wide. Queue arithmetic
does not establish classified canonical task reachability. Native/binary/prompt/
useful-coverage outcomes and k93's measured omissions decision stay pending.

The path continuations are `search-path-resolution-k122` then
`search-path-classification-k123`, each with a producer-cut mandatory review
before its next consumer. K120's complete-resource review and k30 planning
consume the reconciled chains, preserving the original approval posture.

The native-resource continuation now uses the independently selected
[observation boundaries](../docs/specs/workspace-search.md#observation-boundary-decision-questions)
from k118 under Antony's "you decide" delegation. Only reported-native-fact
meaning and empirical serviceability evidence change. k119 finalizes the
in-process calls, bounded result consumption, two-temporary ownership, freeze/
late-return/refusal/recovery contract and observable handoff. k113 completes serviceability
instrument/subject construction; mandatory complete-resource review k120,
native acceptance and the separate measured home-omissions decision remain live.


k122 selects one bounded component resolver at every source/length (32 link
expansions, bounded readlink/pending text, derived expanded work and native
absolute/dot-dot/firmlink transitions). Parent AND no-follow child policy checks
use protected/known-cloud identities and native variant lookups before opening.
File-search locations of every kind preserve reported-parent/listed-name joins,
including 8,192 bytes; queued native descent ENOSPC under independently unchanged
parent/association uses VALUE_LIMIT SUBTREE without withdrawing names. Fresh
reports supply descendant prefixes, retained app identities keep first-finalized
spelling, and byte differences alone prove no movement/failure. Current-turn
location reacquisition spends the same two temporaries, scratch and wait; exact
file dedup can leave cache-variant locations distinct. No changed k119 call set,
account, domain, consent, version or native acceptance is supplied.
Review k124 is integrated by k125: pre-open mount/symlink witnesses move to
search-preopen-witnesses-k126, followed by replay/size-refusal phases in
search-path-observation-phases-k127. Both producers must insert mandatory
reviews before their next consumer; k123 classification and its own review,
then k120/k30, consume those reconciled chains. Long-result action support
and truthful overlength failure move to long-search-result-actions-k128 in
the earlier launch-and-open node, with its own mandatory review before search
consumers. The 8,192-byte search ceiling is no actionability guarantee; no
shorter/copy-only baseline, new consent or changed call set is approved. Native classification reachability, all useful/default/no-dialog/
binary
outcomes and k93's actual bound/spelling/rewalk omissions decision remain live.


k128 is now a live node: long-action-native-boundary-k129 records source/SDK
limits, the unimplemented failure correction and independent actual long-result
subjects. Its mandatory review/integration precedes long-action-route-k130, which
must establish supported classification/selection/submission, reconcile the
whole original artifact contract and cut the final node review. The entire
launch-and-open chain precedes search consumers, including k123/k120/k30.
A boundary retirement, successful declaration/link check or earlier short-path
pass completes no action handoff. Native outcomes and k93 measured omissions
remain pending under the original approval posture.
