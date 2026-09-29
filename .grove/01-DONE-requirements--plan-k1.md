# plan-k1


## Goal

Establish the Koine plugin requirements from Antony's active Modaliser config,
preserving the workflows he uses and their eventual role in ModalAnyware,
plus his newly requested access to an application's full menu system.

## Context

Read the root brief for the human's request and repository pointers. Determine
which configuration is active before treating configured behavior as required.

## Done when

The human has agreed which existing configured workflows the plugins must
support, the externally observable behavior, and the acceptance boundaries.
Record the requirements durably and hand off through Grove's normal procedure.

## Notes

### Configuration evidence

The installed `/Applications/Modaliser.app` reports version 4.0.0 and was
running when inspected. Its mirrored `sys/scheme/root.scm` selects
`~/.config/modaliser/config.scm`; that file includes sixteen files under
`~/.config/modaliser/app-trees/`. Read those user-owned files, not the seed
or example configurations, for the workflow inventory. The running process
started after the root configuration and all sixteen included files were
last modified. The macOS unified log for that launch records
`Modaliser Scheme runtime initialized (config: loaded)` at local time
2026-09-29 18:52:29.049, so this run loaded the user configuration rather
than the bundled fallback. The loader and its boot callsite were checked
against their exact graph snippets and coverage metadata.

The root config composes global desktop/window/display actions, application
launchers, application/file/web search, system media play/pause, cursor
highlighting and client settings. It chooses a Paneru screen when the Paneru
installation probe succeeds, otherwise the geometry-layout screen. The
inspection shell did not resolve `paneru`; the app's derived tool search path
still needs checking before calling that branch inactive.

The included screens cover Safari, iTerm, herdr, Zellij, Neovim, Dia, Finder,
Mail, Slack, Zed, VSCode, Signal, Messages, Telegram, Obsidian and Zotero.
VSCode includes project/window selection, terminal and editor selection,
strict Explorer focus, VisualJJ focus, editor cycling, live Grove leaf reveal
and conditional cleanup of missing task tabs, and companion installation.
Dia binds ordinary tab operations and a held-modifier recent-tab walk with
distinct confirm/cancel behavior. Its AppleScript tab-list/focus helpers are
defined but unbound. The standalone iTerm focus walk is registered but its
file says no binding reaches it by default. Definitions alone are not evidence
of a used workflow.

### Workflow inventory (configuration evidence)

The root configuration and all sixteen included user files were read directly.
This table records the configuration evidence used in the interview; the agreed
behavioral contract is `docs/requirements/modaliser-workflows.md`. Client-owned
keys, labels, panels, choosers, confirmation dialogs, walk navigation and overlay
styling remain on the client side.

| Configured area | State and operations required by its reachable bindings |
| --- | --- |
| Global desktop | Switch Spaces using the configured Control-digit bindings; list/select windows; apply thirds, half-thirds, two-thirds, halves, quarters, maximise and centre geometry; restore prior geometry; list displays, move a window preserving its fractional visible-area geometry, and focus a display. |
| Application launch | Launch or activate Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. |
| Search | Find applications and files and open the selection; reveal it in Finder or copy its path; copy an application's bundle identifier; open a selected file in Zed; submit a typed or suggested Google search in the default browser. File search defaults to the home directory. Selection, query entry, action menus and MRU ordering remain client-owned. The secondary actions are supplied by the bound launcher constructors and are reachable without extra top-level keys. |
| Media and pointer | System play/pause, addressed through the system media route rather than the foreground app; locate/highlight the pointer, including the configured reveal nudge. The highlight's appearance is client presentation. |
| Client settings | Open the configuration directory in Zed; reload/relaunch the client. The latter remains a client lifecycle action. |
| Safari | New, close and reopen tab; focus address bar; find on page. |
| Dia | New tab; find tab; positional next/previous tab; recent-tab walk with a held Control modifier, forward/backward steps, confirm by release, and cancel by Escape followed by release. The executable recent-walk bindings are `l`/`h`, despite older comments saying `j`/`k`. |
| Finder | New window/folder; go to folder; get info; connect to server; toggle hidden files; icon/list/column/gallery views; Home, Applications, Desktop, Downloads, Recents and Computer destinations. |
| Mail | New message, reply, reply-all, forward, toggle unread, junk, get new mail, search and move selected message to Trash. |
| Slack | Jump, direct messages, search, all unreads, threads, mentions, back/forward and mark read. |
| Zed | File finder, command palette, project search, find in file, project panel and terminal. |
| Signal | New message, search, find in conversation and preferences. The first three chords are explicitly marked unverified in the config; intended results must not be equated with presumed shortcut correctness. |
| Messages | New message, find and repeated next/previous conversation. The two conversation chords are marked unverified. |
| Telegram | Jump to chat; search in chat; next/previous chat and next/previous unread chat. |
| Obsidian | Quick switcher, command palette, new note, search all files, find in file and graph view. |
| Zotero | Quick search and advanced search. |
| iTerm | List/select panes and tabs; directional pane focus, move and split; pane zoom and copy mode; create/rename/close tabs and focus/reorder previous/next tabs; conditional prerequisite configuration. The separately registered focus-walk tree has no configured entry and adds no scope beyond the reachable focus operations. |
| Terminal context | Identify the focused terminal's nested tool context sufficiently for a client to navigate the terminal/herdr/Zellij/Neovim chain and address the intended tool instance. Navigation and screen selection remain client-owned. |
| herdr | List/select panes, tabs, Spaces, worktrees and agents; directional pane focus/split/move, zoom and close; create/rename/close/reorder tabs and Spaces; cycle the appropriate list scope; create/remove/smart-switch worktrees; jump to the next blocked agent; pane copy mode and pane scrollback; detach client versus stop server. Worktree removal is non-forcing and distinct from closing a Space. |
| Zellij | Directional pane focus/split/move, zoom and the wired pane digit-jump facility. |
| Neovim | Directional focus between Neovim windows in the intended running instance. |
| VS Code projects | List open projects/windows, including other Spaces, and focus the selected one. |
| VS Code window parts | List all terminals, including hidden ones, and editor tabs across all groups; expose names, active state, editor dirty state and whether a row can be selected; focus a specific supported part. Unsupported editor kinds remain visible without pretending they can be selected. |
| VS Code commands | Strict Explorer focus; VisualJJ focus; file finder, command palette and project search; focus the active editor group before previous/next editor cycling, crossing groups and wrapping within the window. The removed Terminal/Editor rows are not extra bindings. |
| VS Code and Grove | Reveal the live Grove leaf for the initiating window's worktree and leave Explorer focused; conditional cleanup of that workspace's Grove task tabs runs even when no live leaf remains, closing only clean tabs whose files are definitely missing. Existing files, dirty tabs and uncertain checks stay open; cleanup does not gate reveal. |
| Integration setup | Conditional iTerm configuration and VS Code companion install/update are reachable setup workflows, not permission for this requirements session to alter installed apps. Preserve the supported workflows while leaving the integration mechanism to design. |

The Paneru installation predicate was inspected in the installed Scheme
library. Its tool path derives from `/bin/zsh -lc` and adds
`/opt/homebrew/bin:/usr/local/bin:/usr/sbin`; `command -v paneru` returns no
path through that construction, while the same probe resolves `zsh` to
`/bin/zsh`. The mirrored and bundled `terminal.sld` and `paneru.sld` have
matching SHA-256 digests. This establishes the currently reproducible branch
as the geometry-layout screen; it does not read the already-running engine's
cached load-time decision. Paneru-only strip listing, focus/swap west/east,
grow/shrink and centre remain a conditional alternative, not additional agreed
scope. The unbound Dia AppleScript tab-list/focus helpers likewise add no scope.

### Requirements review

The full interview threshold is met: workflow scope, shortcut-action
semantics, target/lifetime behavior and acceptance depend on one another.
The human agreed to all active bindings and subsequently added full
application-menu access. Do not ask either scope question again.
Unbound helpers and inactive conditional branches are not automatically
requirements. The resumed interview confirmed menu-bar and context-menu
coverage, explicitly requested menu opening for discovery, both screen-point
and keyboard-focus context targets, and stopping/cleanup when the user switches
applications mid-interaction, the required menu metadata, and rejection of
unverifiable stale menu selections. The three existing test seams are agreed.
Antony confirmed that the written requirements capture the shared understanding
and authorized finalization and handoff. See the running decision log for the
settled answers.

Resume by distinguishing requirements from design choices. The observable
workflows come from the agreed active configuration; named semantic app
operations versus reusable native input may be a design decision rather than
another scope question. Do not freeze known shortcut bugs into the contract:
some app bindings are annotated `verify`, and some prose describes older
bindings. The executable configuration determines what is bound; the human
determines the intended result where that remains ambiguous.

The agreed requirements are in
`docs/requirements/modaliser-workflows.md`. The inventory is bounded to the
active user configuration, with reachable constructor actions included.
Menu behavior and acceptance are recorded there from the decisions below.
The human's final shared-understanding check passed. A requirements review
checks the contract before a subsequent planning session decides the
decomposition and commissions design or native evidence where needed.

The previous invocation stopped at the saved configuration/scope checkpoint.
This invocation resumed the requirements interview. Completion of this leaf
will hand off further provider work, not declare the whole grove finished.

### Structural evidence

Tier 2 verification. The current Koine workspace generation is
`2026-09-29T10:36:20Z`, indexed in fast mode;
documentation and scripts are excluded and are read directly. The Modaliser
index generation is `2026-09-16T05:15:24Z`. Exact coverage checks for
`ConfigurationLoader.swift` and `Scheme/root.scm` report no recorded issue and
matching metadata. `SchemeEngine.loadConfiguration` tries the user path, then
the fallback on failure; its inbound trace reaches
`ModaliserAppDelegate.bootConfiguration`. The Paneru Scheme file has untracked
freshness in the graph, so the installed mirror is being read directly.
User-owned configuration files are outside these repository indexes and are
read directly. These are bounded evidence statements, not a completeness claim.

## Decisions (running log)

The root brief already fixes the workstream: derive Koine provider support
from Antony's actual Modaliser usage; ModalAnyware is an eventual client and
is not edited or restarted here. Provider boundaries follow the agreed
workflows. Koine's existing native Swift provider and public GraphQL contracts
remain the starting constraints.

Antony chose **all active bindings** as the requirements baseline. Cover the
configured desktop, launch/search, media/input, VSCode/Grove, terminal/tool,
Dia and app-shortcut workflows. Explicitly distinguish unused definitions and
inactive alternatives rather than treating every defined function as used.

The existing Machine spec already assigns interaction, configuration and the
Machine client to ModalAnyware. Preserve that boundary: key maps, leader
handling, labels, panels, choosers and walk navigation belong to the client;
Koine supplies the reusable state and operations those workflows need. This
is an existing agreement, not a new interview decision or permission to edit
ModalAnyware.

Antony added a requirement beyond the configured workflows: "One feature I
want that modaliser currently doesn't use is access to the full menu system of
an application so I can expose that through Modaliser/ModalAnyware." Preserve
full application-menu access as explicit scope alongside all active bindings.
The intended client use includes discovering menus and invoking their items;
the detailed meaning of "full" remains to be settled. This does not authorize
editing or restarting either client as part of the Koine workstream.

Antony confirmed that full application-menu access includes **both the menu
bar and context menus on UI elements**. Clients must be able to expose actions
available only from an item's context menu as well as the application's menu
bar. Dynamic population, discovery side effects, target selection, metadata
and stale-item behavior still require agreement.

Antony allows **explicit menu opening for discovery** when needed to obtain a
context menu or dynamically populated submenu. A client must explicitly
request that operation; passive inspection must not unexpectedly open menus
or change the desktop. This makes opening and inspection distinct observable
operations without prescribing their schema or implementation. Apple's
[menu-update contract](https://developer.apple.com/documentation/appkit/nsmenudelegate/menuneedsupdate(_:))
permits population and validation as a menu opens, supporting this acceptance
case; it is not evidence that every application's menu is discoverable.

Antony requires context-menu targeting through **both a specified screen point
and the keyboard-focused UI element**. This supports pointer-based and
keyboard-only clients. The menu belongs to the selected target; the precise
reference and discovery interfaces remain design work.

If Antony switches to another application during a context-menu interaction or
Dia's recent-tab walk, **stop and clean up** rather than bring the original
application back. Cancel the interaction and release its held modifiers/dismiss
its menus; do not continue the interaction in the new application. This is a
user-driven switch to another application, not a requirement to treat the
client's own expected presentation as a new target. Design must preserve
Koine's documented native limitations and must not send blind cleanup
keystrokes to whichever application has since become frontmost.

Antony agreed the menu inspection minimum: **hierarchy and order, labels and
separators, enabled/checked state, keyboard shortcuts, and whether a submenu
needs opening**. Menu-item icons are not required. Missing state or shortcut
metadata must not be fabricated; the design must distinguish unavailable
information from an actual unchecked state or absence of a shortcut.

Antony chose **reject stale menu selections and list again**. If the selected
menu item can no longer be validated against what the client listed, report it
unavailable rather than recover by its old label, ordinal or menu path. The
concrete acceptance case is an Open Recent entry replaced before invocation:
the replacement must not be chosen on the old selection's behalf. A fresh
list and a new selection are required; this does not imply rejecting an
unchanged, still-valid item merely because an unrelated sibling changed.

Antony agreed to reuse the existing **public GraphQL, native binary interface
and isolated TestAnyware macOS VM seams**. A standalone client demonstrates the
required workflows without implementing or restarting ModalAnyware. Native
tests check provider loading and binary compatibility; signed Koine is tested
against real applications in the VMs. The existing Machine spec's testing
boundary remains the starting contract, including no mocks of desktop apps.

Antony confirmed that `docs/requirements/modaliser-workflows.md` captures the
shared understanding and chose **finalize and hand off** to requirements review
and planning. The inventory, client/server allocation, menu semantics and test
seams are now agreed. Provider count, detailed APIs and implementation
mechanisms remain downstream design work; no new implementation was performed
by this requirements leaf.
