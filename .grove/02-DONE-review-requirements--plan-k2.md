# plan-k2

**Reviews:** plan-k1

## Goal

Adversarially review the agreed configured-workflow and application-menu
requirements before planning uses them. Inspect and report findings; do not
implement fixes or reopen settled preferences merely to choose a mechanism.

## Context

- `docs/requirements/modaliser-workflows.md` is the agreed contract.
- Resolve `plan-k1` for the configuration evidence and the running decision log.
- The source baseline is Antony's `~/.config/modaliser/config.scm` and its
  sixteen included `app-trees/*.scm` files, plus the actions supplied by bound
  constructors in the installed/mirrored Scheme libraries.
- `docs/specs/machine.md`, `docs/client-guide.md`, the cited ADRs and `CONTEXT.md`
  carry the existing Koine contract and vocabulary.

## Done when

A finding report anchored to the producer's committed artifacts distinguishes
requirements defects from design questions and accepted trade-offs. The report
tests the doubts below against the source and the human's recorded decisions.
Any worthwhile findings are handed to an adjacent integration leaf through
the review kind's normal procedure; an empty review creates no integration.

## Notes

The artifact is load-bearing across multiple integrations. In particular:

- Check reachable behavior, including launcher secondary actions, Google
  suggestions, generated pane/list choices and integration setup, rather than
  only counting top-level keys. Distinguish unreachable helpers and a
  conditional screen from the agreed active baseline.
- Check the Paneru evidence boundary: the current derived-path installation
  probe is reproducible, but the running engine's cached branch was not read.
  Do not turn that limitation into an unsupported exhaustive claim.
- Check that intended application results are preserved without treating the
  annotated Signal/Messages chords or outdated comments as proof of behavior.
- Check the agreed menu semantics together: both menu types and context target
  modes, explicit opening, required metadata without icons, focus-loss cleanup
  and rejection of unverifiable stale selections. Look for contradictions with
  read purity, authorization, reference identity or the accepted public AX
  limits, especially cleanup after the foreground app changes.
- Check that the client/server allocation and acceptance remain sufficient to
  demonstrate the baseline without implementing or restarting ModalAnyware.
  A future design question is not itself a missing behavioral requirement.

Graph evidence in the producer used Tier 2. Koine generation was
`2026-09-29T10:36:20Z` (fast); Modaliser was `2026-09-16T05:15:24Z`.
Koine docs are excluded and were read directly. User configuration and installed
libraries are outside those indexes; Scheme library paths had untracked
freshness, so direct installed source and mirror comparisons were used.
Refresh project/generation and exact coverage before new structural claims.

## Findings

Artifact: `docs/requirements/modaliser-workflows.md` as committed by `plan-k1`
(commit `9d818cb0`). A bare `:NN` is a line in that file. Library paths
abbreviated `…/lib/` are under `~/.config/modaliser/sys/scheme/lib/modaliser/`.
Every structural statement here is from direct reads of the user config and
the installed Scheme mirror. Both are outside the graph indexes, so no graph
query was used.

Each finding is a **requirements defect** (the integration changes the
artifact, asking Antony where the answer is his) or sits under
**design questions** (planning and design own it; listed so it is not lost).
Checked-and-accepted items close the report.

### Scope change to apply (human decision, not a finding)

Recorded in the running log below. Remove the Zellij (`:95`) and Neovim
(`:96`) rows. Narrow Terminal context (`:90`) and the nested-context
acceptance case (`:225-227`) to the terminal host and herdr. Move into a short
deferred note: the four VS Code rows (`:97-100`), the companion half of
Integration setup (`:101`, `:41-43`), the initiating-workspace scenario
(`:199-204`) and the VS Code acceptance case (`:228-231`). Keep Visual Studio
Code in the launcher row (`:71`). Purpose (`:10-11`) and "every row is part of
the agreed baseline" (`:63`) must then describe the narrowed baseline rather
than all active bindings. The evidence section (`:252-258`) may keep the full
list of included screens as evidence.

### R1 — Authority for the new effects is unstated (requirements defect, high)

`:56-58` says only that explicit operations act "under the appropriate
authority". `:50-51` does not *require* an arbitrary-shell executor, but does
not exclude one. The inventory has Koine:

- synthesise keystrokes into any application (the app-shortcut rows
  `:78-88`, Space switching `:69`, herdr prefix keystrokes `:91`, `:94`);
- invoke any menu item of any application (`:114-116`);
- open files and URLs, and search filenames under home (`:73-74`).

In `koine-desktop/1` a provider has one read and one control capability
(`docs/specs/machine.md:315`, `:340`). Possession of a bearer credential is
sufficient (`docs/adr/bearer-grants-and-live-revocation.md:8`). Today a
control grant can only focus a window. As written, one copied control
credential could type into a terminal, which amounts to shell execution, or
invoke "Empty Trash". The requirements must say whether these high-impact
effects need separately grantable authority, or whether Antony accepts one
control grant for all of them. In v1, capability boundaries are provider
boundaries, so the answer constrains planning. Ask Antony. Recommend making
keystroke and menu invocation grantable separately from listing and focus.

### R2 — Interruptions other than a user app switch are unspecified (requirements defect, high)

`:195-196` requires that "normal finish, cancel and interrupted-interaction
paths must not leave an owned modifier held". The only interruption the
document defines is a user switching applications (`:150`, `:195`). It leaves
three others open:

- **Revocation between steps.** No later action may start under a revoked
  grant (`machine.md:380`). The client therefore cannot send confirm or
  cancel, and an owned Control stays held unless Koine releases it itself.
- **Client crash or disconnect.** Koine sees independent HTTP requests, so
  nothing ends the interaction.
- **Koine quits or crashes.** A synthetic key-down leaves Control logically
  held.

Modaliser self-heals today by releasing Control on the next walk's entry
(`app-trees/company.thebrowser.dia.scm:126-130`). That is evidence stuck
holds happen, and nothing equivalent carries over. An explicitly opened
context menu has the same gap. State the observable outcome: for example,
Koine releases owned holds and dismisses owned menus when the owning grant is
revoked or the interaction is abandoned for a bounded time. Say which residual
cases (such as a Koine crash) are accepted and how they are reported, and
cover them in acceptance `:237-238`.

### R3 — The Dia scenario drops the "no blind cleanup keystrokes" decision (requirements defect, medium)

The recorded decision covers both the context menu and Dia's recent-tab walk
(`01-DONE-requirements--plan-k1.md:201-208`). The requirements carry the
prohibition only in the menu scenario (`:153-155`), not in Dia's (`:195-197`).
Yet Dia's ordinary cancel is an Escape keystroke
(`company.thebrowser.dia.scm:133-136`), which would reach whichever
application is now frontmost. It is also unstated whether releasing the held
Control counts as a blind keystroke; the new frontmost application receives
that key event. As written, "clean up held modifiers" and "send no keystrokes
to the new application" can contradict.

For Dia, state three things:

- on a user switch, no Escape or cancel keystroke is sent;
- whether the modifier release is exempt, or must be delivered so the new
  application does not receive it;
- in acceptance `:237-238`, that no keystroke reaches the new foreground
  application.

### R4 — The focus-loss trigger is an intent, not an observable (requirements defect, medium)

`:150` and `:195` trigger on "the user switches to another application", and
`:152-153` exempt "the client's own expected presentation". Koine cannot
observe who caused an activation. Another application activating itself, a
system dialog, or the target launching something else all look the same as a
user switch. Koine also cannot recognise the client's process, because client
labels are not authenticated identities (`bearer-grants-and-live-revocation.md:15`).
The rule also names only context-menu interactions (`:150`), although explicit
opening applies to menu-bar submenus too (`:135-136`, `:141-143`). Restate the
trigger as a condition Koine can observe: for example, the target process
stops being the active application, other than to a presentation the client
declared. Say whether the rule covers explicitly opened menu-bar submenus.

### R5 — On-screen geometry for the configured chips is missing (requirements defect, medium)

The list rows ask for list and select only (`:69`, `:89`, `:91-92`). The
active config also paints labels over the real objects:

- window chips (`config.scm:185`), placed by walking stacking order and
  subtracting occluding windows (`…/lib/blocks/window-list.sld:385-400`);
- display chips (`config.scm:193`);
- iTerm pane chips (`app-trees/com.googlecode.iterm2.scm:88`, `:111`), which
  use Accessibility frames (`…/lib/blocks/iterm-panes.sld:138-139`, `:179-181`);
- herdr pane and jump chips (`app-trees/herdr.scm:75-77`, `:103`).

The client draws them. But under the ownership split (`:24-34`), window and
pane frames, stacking order and visibility are Accessibility-derived state
only Koine can read. The requirement already reasons this way for the pointer
(`:34-35`). Acceptance "the state … required by every inventory row" (`:213`)
would pass a design that omits them. Add the geometry and visibility needed to
place labels over windows and panes. The client can read display frames
itself.

### R6 — Generated lists do not specify their row state (requirements defect, low)

Only the VS Code window-parts row names its metadata, and it is now deferred.
The active lists also show:

- the focused or current row (herdr, iTerm);
- herdr agent status, with status-priority ordering, and each worktree's
  current and switchable state (`…/lib/blocks/herdr-list.sld:448-470`);
- iTerm pane titles, falling back to process · cwd
  (`…/lib/blocks/iterm-panes.sld:130-134`).

`:185-186` asks only for enough to distinguish equal labels. Name this state,
or require what the current screens display, so acceptance can fail when it is
missing.

### R7 — The extension crosses recorded scope exclusions without saying so (requirements defect, medium)

`:25-29` keeps the ADRs as constraints, and `:5-6` keeps the desktop contract
as the current service contract. But `docs/specs/machine.md:1006` places
"non-running applications, broad installation/configuration discovery" out of
scope, and `docs/adr/koine-server-and-native-providers.md:40-41` excludes
"broader discovery". The extension crosses both, and possibly a third:

- the launchers (`:71`) and application search (`:72`) launch non-running
  applications and discover installed ones;
- file search (`:73`) is broader discovery;
- the terminal-to-herdr chain (`:90`) may need cross-provider identity, which
  v1 leaves open (`docs/adr/machine-references-as-uris.md:21`).

Antony's "all active bindings" decision already implies lifting the first two.
The requirement should name each exclusion it lifts. Design then reworks the
spec's Scope and the ADR trade-off instead of treating them as binding, or
silently contradicting them.

### R8 — Acceptance for account-gated apps is undefined (requirements defect, medium)

The VM seam requires real applications, no mocks and no live desktop
(`:215`). Coverage requires the intended outcomes of the app shortcuts
(`:223-224`). Several apps need an account before those outcomes exist:

- Signal needs a linked phone;
- Slack, Telegram and Messages need signed-in accounts before their
  conversation views exist;
- Mail's reply, forward, junk and trash need messages.

`:244-246` says a limitation "must be explicit; it does not silently reduce
the agreed baseline". It does not say whether an explicit limitation passes
acceptance, or whether test accounts are allowed inside the isolated VMs. Ask
Antony which applies, app by app: test accounts in the VMs, a recorded manual
check, or an explicitly accepted limitation.

### R9 — Which menus "the menu bar" covers is unstated (requirements defect, low)

`:114` covers "the selected application's menu bar and context menus". An
application also owns status-item (menu extra) menus and Dock menus, which are
neither. For a menu-bar-only agent application, the status item is its whole
menu system. Ask whether status-item and Dock menus are in scope.

### R10 — One acceptance case has no expected outcome (requirements defect, low)

"need not invalidate" (`:169-170`) grants a permission, and the recorded
decision is worded the same way. Acceptance `:235-236` lists "a still-valid
selection whose unrelated sibling changed" without a required result, so both
invoking and rejecting pass. Decide whether invocation must succeed in that
case, or drop the case from acceptance.

### Design questions (no requirements change)

- `koine-desktop/1` closes `extensions.kind` to four values
  (`machine.md:413`). That may not keep an absent dependency distinct from a
  stale selection (`:58-59`) without schema-level results or a
  contract-version change. Design says which; a `koine-desktop/2` would be
  Antony's call.
- Is it "changing the desktop" (`:136-137`, `machine.md:338-339`) when a
  passive Accessibility read makes the target application run its
  menu-population code?
- What happens when a screen-point context target (`:128`) lands on another
  application's element, or on the client's own overlay?
- Clipboard writes (copy path, copy bundle identifier, `:72-73`): Koine
  operation or client step? The acceptance trace (`:217-218`) must say.
- Terminal host scope: the config wires only iTerm as a host
  (`config.scm:363`), while `:90` says "the focused terminal". Acceptance needs
  iTerm at least.
- How does a client declare its "expected presentation" (`:152`) when client
  identity is unauthenticated?

### Checked and accepted (no finding)

- **Runtime evidence.** Modaliser 4.0.0, pid 1434, started 18:52:27. The
  unified log at 18:52:29.049 reports `config: loaded`. The newest source file
  is `app-trees/com.microsoft.VSCode.scm`, modified 2026-09-11 21:13:35.
- **Paneru boundary** (`:103-105`, `:263-266`). The derived-path probe still
  finds no `paneru` while it resolves `zsh`, `herdr`, `nvim` and `grove-llm`.
  No paneru process is running, and Spotlight finds only documentation
  mirrors. The requirement's claim is bounded, not exhaustive.
- **Exclusions.** The unbound Dia helpers and the unreachable iTerm focus walk
  are correctly excluded. Dia's executable `l`/`h` bindings correctly govern
  over the stale `j`/`k` comments.
- **Signal and Messages.** The labels state the intended results, and
  `:223-224` checks the chords rather than trusting them.
- **Constructor coverage.** Launcher secondary actions
  (`…/lib/launchers.sld:50-65`, `:97-112`), Google suggestions and the
  typed-query fallback (`…/lib/web-search.sld:222-243`), and the iTerm
  setup row are all covered.
- **Stale menu selections.** Rejecting a stale selection stays within the
  accepted public Accessibility limits (`:55-57`). The rule forbids
  substitution by label, ordinal or path, not validation.
- **Superseded by the scope change.** `:95` lists Zellij's "configured pane
  digit-jump facility", and the producer calls it "wired"
  (`01-DONE-requirements--plan-k1.md:84`). No binding in the active config
  reaches `zellij-pane-digit`: only a `'next terminal:focus-pane-by-digit`
  edge does. Neither `config.scm` nor any app tree has one, and Modaliser's
  Swift sources reference the slot only in tests. The claim in
  `app-trees/zellij.scm:24-25` that "the host's pane-list block fires it" is
  stale. Zellij is now out of scope, so nothing needs applying. This is
  recorded so the evidence claim is not reused.

## Decisions (running log)

During this review Antony narrowed the agreed baseline: "I no longer use
zellij, and don't require neovim support, and we can ignore VSCode for now
because I use it's own keybindings". This is a human scope decision, not a
review finding. Zellij and Neovim leave the requirements entirely. The
Terminal context narrows to the terminal host and herdr.

Antony chose to **keep the Visual Studio Code launcher** in the named-launcher
row. It is the same launch-or-activate operation as the other launchers. He
chose to record the VS Code screen workflows as **deferred** rather than
delete them. They cover projects, window parts, commands, Grove leaf reveal
and cleanup, and companion install/update. A short note keeps them readable
for a later increment. No design or acceptance work is done for them now.
This removes the VS Code rows, the initiating-workspace scenario and the VS
Code acceptance cases from the current baseline.
