# Configured workflows and application menus

These are the agreed behavioral requirements for extending Koine from Antony's
active Modaliser configuration. They await design and implementation and do not
describe functionality already delivered by Koine 0.1.0. The implemented
[desktop contract](../specs/machine.md) remains the current service contract.

## Purpose

Provide one or more native Koine providers supplying the state and operations
needed by all active Modaliser bindings. Those workflows will become
ModalAnyware requirements when that project restarts. In addition, provide
access to an application's menu bar and context menus so clients can discover
their contents and invoke their actions.

The baseline is the user's configuration, including actions supplied by its
bound constructors and integrations. It is not the full set of operations
defined in Modaliser's libraries, and it is not a seed configuration. Provider
count, boundaries, implementation mechanisms and exact GraphQL fields follow
these requirements.

## Ownership and existing constraints

Koine supplies reusable native state and operations through its introspectable
GraphQL contract and native provider framework. The [server boundary](../adr/koine-server-and-native-providers.md),
[provider compatibility](../adr/resilient-provider-framework.md),
[resource references](../adr/machine-references-as-uris.md) and
[grants](../adr/bearer-grants-and-live-revocation.md) remain constraints on the
extension. The [glossary](../../CONTEXT.md) supplies the project's vocabulary.

Clients own key maps, leader handling, labels, panels, overlays, choosers,
confirmation dialogs, walk navigation, query-entry presentation and MRU
ordering. Client settings and client relaunch remain client responsibilities.
For example, Koine must supply the native pointer access needed for cursor
highlighting; the client draws the ring. Google search's query UI and
suggestion orchestration remain client behavior, with Koine supplying native
URL opening. The configured workflow is retained without requiring a Google
network proxy in Koine.

This work does not edit or restart Modaliser or ModalAnyware. A standalone
client must be able to demonstrate Koine's contribution. A required app-side
integration may be part of the Koine solution; reusing or replacing the current
VS Code companion and iTerm setup are design choices. Where prerequisites are
still needed, their availability and explicit setup path must be discoverable.

The intended result of a configured action is the requirement. Its current
shortcut or script is evidence of the mechanism, not a requirement to retain
that mechanism or reproduce a bug. In particular, unverified Signal and
Messages shortcuts must be checked against their intended results. These
requirements do not by themselves require a public arbitrary-shell executor
or a separate named provider operation for every shortcut.

The existing [process capture](../adr/desktop-capture-preserves-the-process-incarnation.md)
and [public Accessibility boundary](../adr/desktop-automation-uses-public-accessibility.md)
remain applicable. Nothing here strengthens the documented native identity
guarantees into protection against every platform race. Reads remain free of
domain actions; explicit operations perform effects under the appropriate
authority. Permission denial, an absent dependency, a stale selection and an
empty successful result must not become indistinguishable to the client.

## Workflow inventory

Every row is part of the agreed baseline, with the client responsibilities
above preserved. The inventory names behavior rather than prescribing a
provider layout.

| Area | Required behavior |
| --- | --- |
| Desktop windows | Switch Spaces through the configured Control-digit workflow; list and select windows; place windows in thirds, half-thirds, two-thirds, halves and quarters; maximise, centre and restore geometry. |
| Displays | List displays; move a window to a selected display while preserving its position and size as fractions of the displays' visible areas; focus a display for subsequent desktop interaction. |
| Named application launchers | Launch or activate Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. |
| Application search | Find installed applications; launch or activate a selection, reveal it in Finder, copy its path or copy its bundle identifier. Supply the metadata needed for these choices. |
| File search | Find files under the configured roots, currently the home directory; open a selection with its default application, reveal it in Finder, copy its path or open it in Zed. |
| Web search | Retain typed-query and Google-suggestion selection, opening the resulting search in the default browser. Suggestion failure must not prevent searching for the typed query. |
| Media | Send system play/pause through the system media route, rather than selecting the foreground application as the player. |
| Pointer | Locate and reveal the pointer, including the configured nudge, so the client can draw its highlight. |
| Client settings | Open the configuration directory in Zed. Reloading or relaunching the client remains client-owned. |
| Safari | New, close and reopen tab; focus the address bar; find on page. |
| Dia | New tab; find tab; positional next/previous tab; recent-tab walk with forward/backward steps, distinct confirm/cancel outcomes and balanced modifier holds. |
| Finder | New window and folder; go to folder; get info; connect to server; toggle hidden files; icon/list/column/gallery views; Home, Applications, Desktop, Downloads, Recents and Computer destinations. |
| Mail | New message, reply, reply-all, forward, toggle unread, mark junk, get new mail, search and move the selected message to Trash. |
| Slack | Jump, direct messages, search, all unreads, threads, mentions, back/forward and mark read. |
| Zed | File finder, command palette, project search, find in file, project panel and terminal. |
| Signal | New message, search, find in conversation and preferences. |
| Messages | New message, find and repeated next/previous conversation. |
| Telegram | Jump to chat; search in chat; next/previous chat and next/previous unread chat. |
| Obsidian | Quick switcher, command palette, new note, search all files, find in file and graph view. |
| Zotero | Quick search and advanced search. |
| iTerm | List/select panes and tabs; directional pane focus, move and split; pane zoom and copy mode; create, rename and close tabs; previous/next tab focus and reordering; explicit configuration when integration prerequisites require it. |
| Terminal context | Identify the focused terminal and its nested herdr, Zellij or Neovim context sufficiently to select and address the intended running instance. Clients own navigation into and out of that chain. |
| herdr panes | List/select, cycle, directionally focus/split/move, zoom and close panes. Copy mode selects within the live herdr pane; scrollback opens that pane's buffer in an editor. These are distinct from the host terminal's own copy mode. |
| herdr tabs and Spaces | List/select, cycle, create, rename, close and reorder tabs and Spaces, preserving the applicable containing scope. |
| herdr worktrees | List worktrees; create and remove them; focus the live Space when already open, otherwise open the dormant worktree. Removal is non-forcing; the client retains confirmation. |
| herdr agents and lifetime | List/select and cycle agents; jump to the next blocked agent; distinguish detaching the client, which leaves the server and panes running, from stopping the server. |
| Zellij | Directional pane focus, split and move; pane zoom; the configured pane digit-jump facility. |
| Neovim | Directional focus between Neovim windows in the intended running instance. |
| VS Code projects | List open projects/windows, including those on other Spaces, and focus the selected window. |
| VS Code window parts | List all terminals, including hidden ones, and editor tabs across all groups. Expose names, active state, editor dirty state and selectability. Focus a selected supported part; keep unsupported editor kinds visible without pretending they are selectable. |
| VS Code commands | Strict Explorer focus; VisualJJ focus; file finder, command palette and project search. Focus the active editor group before previous/next editor cycling, crossing groups and wrapping within the window. |
| VS Code and Grove | Reveal the live Grove leaf for the initiating window's worktree and leave Explorer focused. Independently clean up only that workspace's clean Grove task tabs whose files are definitely missing, even when no live leaf remains. Existing files, dirty tabs and uncertain checks stay open. Cleanup does not gate reveal. |
| Integration setup | Support explicit prerequisite setup where needed, including the configured iTerm setup and VS Code companion install/update workflows or an equivalent solution that removes those prerequisites. |

The current installation probe supports the geometry-layout screen. Paneru's
alternative strip listing, west/east focus and swap, grow/shrink and strip
centring are not added to the requirements simply because their definitions
remain in the configuration. The unbound Dia AppleScript tab-list/focus helpers
and the separately registered, unreachable iTerm focus-walk entry likewise add
no extra scope.

## Application-menu requirements

### Requirement: discover the application's menu system

Koine SHALL provide access to the selected application's menu bar and context
menus, including nested and dynamically populated submenus. This is a general
menu facility, not a catalogue of the currently configured shortcut actions.

#### Scenario: menu hierarchy and state

When a client inspects an available menu, it receives its hierarchy and order,
labels and separators, enabled/disabled and checked state, keyboard shortcuts,
and whether a submenu still needs opening. Unavailable metadata is distinguished
from actual state; it is not fabricated. Menu-item icons are not required.
Disabled items remain inspectable and cannot be invoked as enabled actions.

#### Scenario: context target

A client can select a context-menu target either by a specified screen point or
by the keyboard-focused UI element. Subsequent discovery and selection remain
associated with that target. A later pointer movement or foreground change
does not silently choose a different target.

### Requirement: explicit opening and cleanup

Koine SHALL allow a client to explicitly open a context menu or submenu when
opening is needed to discover its contents. Passive inspection SHALL NOT
unexpectedly open menus or change the desktop.

#### Scenario: lazy population

A submenu whose contents are not yet available is reported as needing opening,
not as an empty completed list. An explicit opening operation may display it;
the client can then inspect its current contents and finish or cancel browsing.
An inaccessible or unsupported menu is reported as such rather than silently
presented as complete. This reporting rule is not permission to omit required
working menu access from acceptance.

#### Scenario: the user switches applications

If the user switches to another application during a context-menu interaction,
the interaction stops and its menus are dismissed. Koine does not bring the
original application back or continue acting in the new one. The client's own
expected presentation is not a user request to switch targets. Cleanup must
respect the current native boundary and must not blindly send keystrokes to the
new foreground application. A failed cleanup is reported as unconfirmed,
not as successful cancellation.

### Requirement: validate the selected item before invoking it

Koine SHALL invoke the selected, currently valid menu item or report that the
selection is unavailable. It SHALL NOT substitute a different item by matching
the old title, ordinal or menu path. A selection that cannot be validated
requires a fresh list and a new selection.

#### Scenario: a recent-document item is replaced

If a different document replaces an Open Recent entry after listing, invocation
of the old selection is rejected. The replacement is not opened on its behalf.
An unrelated sibling change need not invalidate an unchanged selection that
can still be validated. Duplicate titles are not sufficient identity.

#### Scenario: disabled, removed or inaccessible selection

An item that has become disabled or disappeared is not invoked as though the
old snapshot still applied. Loss of native consent and loss of client authority
retain their permission classifications. The existing contract's unknown
mutation-outcome and no-automatic-replay rules continue to apply.

## Interaction requirements

### Requirement: preserve the intended target and cancellation behavior

Application, window, workspace, pane and editor operations SHALL preserve the
target selected for the interaction. Discovery must provide enough identity and
state for clients to distinguish equal labels and select the intended resource.
The native limits of the existing contract still apply; providers must not
deliberately retarget by a convenient title or current foreground application.

#### Scenario: Dia recent-tab interaction

Opening the recent-tab walk holds Control and advances once. Forward/backward
steps operate the same interaction. Confirm releases Control to accept the
highlighted tab; cancel dismisses the chooser before release so it does not
commit the preview. A user switch to another application stops the interaction
and cleans up its held modifiers rather than reclaiming focus. Normal finish,
cancel and interrupted-interaction paths must not leave an owned modifier held.
Cleanup failures must be reported honestly rather than represented as rollback.

#### Scenario: VS Code's initiating workspace

Changing which window is frontmost must not cause Grove cleanup or leaf reveal
to act in a different workspace. A missing live leaf is a result the client can
explain; it does not prevent conditional cleanup of definitely missing clean
task tabs in the original workspace.

## Test seams and acceptance

Antony agreed to reuse the three seams in the
[desktop contract](../specs/machine.md#test-seams-and-acceptance):

| Seam | Acceptance for this extension |
| --- | --- |
| Public GraphQL | A standalone client built from the documented/introspected contract can obtain the state and perform the native operations required by every inventory row. Client-only steps are identified explicitly. Read/control authorization, revocation, stale references, empty results and failures remain distinguishable under the existing contract. |
| Native binary interface | The new providers use the actual loader and shared framework. Loading, compatibility declarations and supported independent host/provider binary combinations are checked through the existing native seam. |
| Isolated TestAnyware macOS VMs | Signed Koine is exercised against real applications and tools, with relevant native permissions and actual visible outcomes. Tests must not interact with Antony's live desktop or depend on implementing or restarting ModalAnyware. There are no mocks of desktop applications. |

Coverage must include the following cases, in addition to a trace from each
inventory row to its public operations or client responsibility:

- Desktop geometry and restore, display transfer/focus, application and file
  selection, launcher secondary actions, URL opening, pointer reveal and system
  media routing.
- The intended outcomes of configured app shortcuts, with the annotated Signal
  and Messages bindings checked rather than assumed correct.
- Multiple terminal/tool instances, nested context and equal display labels;
  herdr's copy-mode/scrollback and detach/stop distinctions; non-forcing worktree
  removal.
- VS Code projects across Spaces, hidden terminals, multiple editor groups,
  unsupported editor kinds, strict focus and editor cycling. Grove cleanup
  covers clean/missing, dirty/missing, existing and uncertain files, including
  the no-live-leaf case.
- Menu bar and both context-target modes; nested/lazy menus; required metadata;
  disabled and duplicate-title items; passive inspection versus explicit
  opening; cancellation and user-driven application switches.
- A menu selection replaced between listing and invocation, and a still-valid
  selection whose unrelated sibling changed.
- Dia confirm, cancel and focus-loss cleanup, including interruption while a
  modifier is held.
- Missing integrations, unavailable targets, denied/revoked grants and absent
  native consent. An unavailable integration must not masquerade as a healthy
  empty list or count as a demonstrated working workflow.

Acceptance records the actual application/tool versions and supported cases.
The existing supported OS/CPU matrix is the starting point. Any platform or
application limitation discovered during design or testing must be explicit;
it does not silently reduce the agreed baseline. As in the existing desktop
contract, report observed interactive latency rather than inventing an
unagreed numerical target.

## Evidence and design handoff

The source is `~/.config/modaliser/config.scm` and its sixteen included
`app-trees/*.scm` files. The running installed Modaliser 4.0.0 was verified to
load that configuration after the files' modification times; its launch log
reported `config: loaded` on 2026-09-29. The included screens cover Safari,
iTerm, herdr, Zellij, Neovim, Dia, Finder, Mail, Slack, Zed, VS Code, Signal,
Messages, Telegram, Obsidian and Zotero. The executable bindings govern the
inventory where comments describe older bindings.

Bound launcher constructors contribute secondary actions, and the bound Google
constructor contributes suggestions. Their installed Scheme definitions were
read; the relevant installed and user-mirrored library files matched. The
Paneru predicate was read and its login-shell path plus fallback directories
were probed: Paneru did not resolve while a positive control resolved `zsh`.
That is a reproducible current-installation result, not a read of the running
engine's cached load-time branch. These are bounded configuration observations,
not a claim that every function in the Modaliser repository was audited.

Detailed design must settle provider boundaries, schema composition and
capabilities, target and menu-reference lifetime, interrupted interaction
ownership/cleanup, dependency discovery and integration setup. Native menu
population and validation need runtime evidence: Apple's
[menu-update contract](https://developer.apple.com/documentation/appkit/nsmenudelegate/menuneedsupdate(_:))
allows contents to change when a menu opens, and its
[show-menu action](https://developer.apple.com/documentation/applicationservices/kaxshowmenuaction)
describes an explicit contextual-menu effect. Neither establishes that every
application exposes every required menu through one mechanism.

These questions belong to design and planning. The agreed behavioral scope,
client/server boundary and test seams are their inputs and must not be
re-interviewed merely to choose an implementation.
