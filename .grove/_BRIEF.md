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
12. `baseline-acceptance`.

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

The first-party provider-selection design runs before launch-and-open to settle
reserved shipped identities and independent per-user updates under the existing
trust policy. Launch-and-open implements that contract alongside composition,
complete capability diagnostics and exact-provider conformance. Window layout
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
