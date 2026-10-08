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

Application/file search now consumes search-tooling-k195's selected system-find,
Foundation matching and native application-service design, its mandatory review/
earned integration, then search-tool-permissions-k196. Process permission,
home ordering and materialization are separate human choices; in-process FileManager
enumeration is the concrete child-refusal alternative, not an adopted backend.
Search's fixed child lifecycle belongs to workspace:read, with k127 required to
preserve action source/binary guards before implementation. Protected exclusions
and measured order/work omissions require separate k93 answers. Known anchor/mount
metadata contact and case/Unicode/Data-root aliases remain policy obligations.
Relocated-target/lookup-only policy remains a concrete human decision; k115's custom
helper refusal is not overridden. Returned permission k126/k191/k193, command
lifecycle k127, native metadata/long records k123 and whole-k19 resource review k120
precede planning k30. Custom FIFO/frontier/prefix-witness accounts are obsolete
candidate mechanics, not native passes. Actual signed identity/dialog/hydration,
useful home/default/launcher witnesses, independent serviceability and binary
acceptance remain pending. Protected-home k93 accepts actual per-witness omissions
or a separately agreed setup/domain/backend contract before baseline; no arbitrary
bounded sample or new consent/signing/limit change is accepted.

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

Application/file search requirements and current design are in
`docs/requirements/modaliser-workflows.md`, `docs/specs/workspace-search.md` and
`docs/verification/search-tooling.md`. Search stays in Koine; clients own chooser,
ranking/MRU and clipboard. The system-tool mechanism is selected for review, not
implemented or natively accepted. Root-level k195 review/integration and k196 human
choices precede the reconciled search node. Preserve native metadata, actual action
contracts and agreed G/N/V seams. Closed prior search producers/measurements remain
bounded comparison evidence; rewritten live charters discharge retained obligations.
No live item is pruned or marked passed merely because its old algorithm is obsolete.

`launch-and-open-k6` and its final node `long-locations-k172` deliver the
action-only workspace release/schema 1.0.1: all four operations, the twelve
launchers, installation selection and grant disclosure, independently retained
1.0.0 compatibility, descriptor-relative action/receipt resolution and the
accepted target/application VM slice. Selection V is re-pinned to bundled
workspace 1.0.1 and its 1.1.0/schema 1.0.1 update on notarized hosts
(`docs/verification/selection-vm.md#workspace-101-rerun`). Reuse its operation
and selection/profile contracts for the next providers.

The recorded native coverage limit for workspace 1.0.1 on macOS 26.5 (25F71),
arm64 remains bounded to registered-long ordering and preferred-long refusal
(`docs/verification/application-locations-vm.md#accepted-native-coverage-limit`);
both behaviors remain unproved and their contracts bind. Actual-search G/N/V
handoff belongs to `app-and-file-search`. The previously externalized
`protected-default-open-k89`, `reveal-app-bundle-notice-k90`,
`alternate-team-signing-k80` and account-owned `dia-url-page-load-k88` remain
live work before baseline acceptance, not outcomes closed by launch-and-open.

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


The current search roll-up above replaces earlier custom traversal/witness
prescriptions. Its process/protection decision and returned reviews remain live;
actual-search acceptance belongs to app-and-file-search, while launch/open/reveal's
accepted 1.0.1 action contract and long-location handoff limit stay independent.
