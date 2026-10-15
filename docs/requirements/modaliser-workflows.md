# Configured workflows and application menus

These are the agreed behavioral requirements for extending Koine from Antony's
active Modaliser configuration. They await design and implementation and do not
describe functionality already delivered by Koine 0.1.0. The implemented
[desktop contract](../specs/machine.md) remains the current service contract.

## Purpose

Provide one or more native Koine providers supplying the state and operations
needed by the agreed subset of active Modaliser bindings below. Those workflows
will become ModalAnyware requirements when that project restarts. In addition,
provide access to an application's menu bar and context menus so clients can
discover their contents and invoke their actions.

The baseline is the user's configuration, including actions supplied by its
bound constructors and integrations. It is not the full set of operations
defined in Modaliser's libraries, and it is not a seed configuration. Antony
removed Zellij and Neovim support and deferred the VS Code screen workflows;
the Visual Studio Code launcher remains required. Provider count, boundaries,
implementation mechanisms and exact GraphQL fields follow these requirements.

## Ownership and existing constraints

Koine supplies reusable native state and operations through its introspectable
GraphQL contract and native provider framework. The [server boundary](../adr/koine-server-and-native-providers.md),
[provider compatibility](../adr/resilient-provider-framework.md),
[resource references](../adr/machine-references-as-uris.md) and
[grants](../adr/bearer-grants-and-live-revocation.md) remain constraints on the
extension. The [glossary](../../CONTEXT.md) supplies the project's vocabulary.

This extension deliberately lifts the desktop contract's exclusions of
non-running applications and broad discovery only for the agreed launch,
installed-application search, file search and required integration-prerequisite
discovery/setup workflows. The server-boundary ADR's broader-discovery exclusion
does not prohibit those workflows. Design must reconcile the spec's Scope and
that ADR with the extension before implementation. The terminal/herdr context
requirement does not itself mandate shared identity across providers; whether
it needs to reopen that exclusion is a design question. Other existing scope
exclusions remain in force.

Clients own key maps, leader handling, labels, panels, overlays, choosers,
confirmation dialogs, walk navigation, query-entry presentation and MRU
ordering. Client settings and client relaunch remain client responsibilities.
For example, Koine must supply the native pointer access needed for cursor
highlighting; the client draws the ring. Google search's query UI and
suggestion orchestration remain client behavior, with Koine supplying native
URL opening. The configured workflow is retained without requiring a Google
network proxy in Koine.

Raw filesystem search belongs entirely to clients. For v1, Koine supplies
**special locations** from which a client can search, and **native catalogues**
for named metadata categories such as applications and preference panels. It
exposes no general OS metadata-query API in v1. A returned location is a starting
point, not filesystem access, consent or a claim that its contents were inspected.
Clients own traversal, filename filtering, ordering, budgets and their search
process's OS permissions, as well as query presentation, choosers and MRU.
Koine does not supply a raw file-search operation or a recursive-search fallback
behind metadata discovery.

This work targets macOS 26 or later, consistent with Koine's existing Apple
Silicon support matrix. The preference catalogue targets modern System Settings;
there is no older-OS or legacy preference-pane compatibility requirement. The
returned design establishes which supported native destinations macOS 26+
actually exposes and reports any incomplete or unavailable category honestly.

Modern System Settings discovery uses the app-supplied scripting interface,
subject to actual-source qualification. Try unchanged signing posture and
exact-event-allowed, no-prompt reads first. If useful discovery requires
Automation authorization, the design may introduce the necessary host
entitlement/usage description and a separate explicit consent/setup action in
Koine's local explaining UI;
introduce no unused permission. This agreement proves neither that an event
requires consent nor that authorization can be obtained. The
[source boundary](../verification/native-discovery-sources.md#agreed-settings-source-and-preparation)
records the source/posture trade-off and its remaining qualification work.

Only an explicit human action in that UI initiates OS Automation consent. No
client GraphQL operation or bearer management authority can do so. Consent covers
the Koine-host/System Settings target pair, rather than a single event. Native
workspace providers require workspace-native-disclosures-v1: corrected core UI
and management disclosures must ship before the host advertises it; prior
selection-aware hosts refuse before loading and retain action-only fallback where
available. Antony selected both boundaries during native-discovery-k204; the
[host-feature decision](../adr/native-workspace-requires-disclosure-capable-host.md)
records the compatibility cost. Actual implementation and acceptance remain pending.

Clients must be able to explicitly prepare the settings catalogue by launching
System Settings in the background when stopped, preserving the foreground
application. Preparation requests no activation or reveal and does not
reactivate an already-running target. It requires complete effect authority
defined by returned design. Its RUNNING receipt establishes only the process;
cold and warm reads must independently qualify every runtime-exposed pane/anchor.
Repeated replies certify no lazy-object health. Unestablished empties remain
unknown, positive choices stay usable with uncertainty, and missing useful
destinations remain unmet work. No hidden pane-loading effect follows.
An exact selected reveal in a fresh unvisited incarnation must independently
qualify a pane/anchor known from an earlier one. Lazy no-such-object proves no
absence; an honest failed pre-check does not waive useful destination acceptance.
Confirmation timeout may retain uncontradicted complete-first-map positives
with TIME_LIMIT/UNKNOWN, while useful cold/warm qualification still needs both
sweeps within the shared deadline. Diagnostic storage saturation omits guidance,
never otherwise valid choices or the source/root failure outcomes.
Ordinary reads remain separate: they never launch,
activate, reveal, request consent or change settings. A stopped or refused
target has an honest unavailable/blocked read outcome; a read-only caller
cannot acquire preparation or setup authority. Existing launch/open/reveal
actions retain their independent contracts and authority.

The useful settings category returns every pane exposed by the app's runtime
interface. Network, Sound, Appearance and Displays are required acceptance
witnesses, not a hard-coded inventory. Exposed anchors must support nested
destinations, with honest hardware/account-conditional availability. A missing
required ordinary area remains a concrete unmet obligation; it cannot be
accepted by silently narrowing the category. Neither a private sidebar adapter
nor a reduction to individually documented destinations is selected. Actual
native usefulness and selected destinations remain pending acceptance.

The returned design must settle the native catalogue API and each catalogue's
sources, availability and completeness. "All apps" is an intended useful native
discovery result, not permission to claim an exhaustive all-disk inventory from
partial OS-reported seeds. Reuse existing OS facilities or established tools;
the earlier system-find and custom-traversal designs are comparison inputs,
not the selected product boundary. Native metadata and existing explicit
launch/open/reveal actions remain Koine responsibilities.

Long native application choices preserve exact copy spelling/identity, honest
unsupported metadata and selected-action refusal. The
[indexed metadata design](../specs/workspace-search.md#long-application-indexed-metadata)
uses actual fixed-query tuples with explicit provenance; source facts do not
prove current plist or launch eligibility. L1500's actual long-source/usefulness
qualification remains pending. No client-found path can close native provenance,
and no new access policy or useful-choice loss is approved by that design.
K212 selects the explicit fixed-file/direct-localization reader for ordinary
roots through 1,023 bytes, with a 977-byte localized control and 978-byte old-band
copy. Larger roots require actual indexed tuples. Mandatory review and native
G11/N8/V13 must preserve useful localized names, flags and unchanged action limits;
no known-plist-only proof, opacity fallback or narrowed useful category passes.
K213/k214 refuted the old Info.plist sizing, L/input dimensions and strings-only
file plan. The selected complete reader semantics now include platform/plain
information, strings/loctables, 128 KiB files and individual affected-fact refusal.
The scoped accounting ADR preserves 20 MiB raw requested/write gross, explicit
operations and no refund; runtime internals are excluded without heap/RSS/peak
guarantees and real publication remains provider-owned. The candidate supplies
no useful finite fit; the k215 consumption hold and mandatory whole review/earned
integration remain before k7. Known construction failure is not native coverage
loss accepted by k93; all native G/N/V remain pending.

Koine's own location and metadata reads remain prompt-free. They must report
blocked, unavailable, unknown and healthy empty outcomes honestly and avoid
hydration. Any consent/setup change needs its own agreement
and explicit operation/authority. Earlier find-process, bounded lookup-only and
qualified protection permissions do not require retaining a raw-search feature
or approve a new metadata backend, global policy setting or workflow loss.

This work does not edit or restart Modaliser or ModalAnyware. A standalone
client must be able to demonstrate Koine's contribution. A required app-side
integration may be part of the Koine solution; reusing or replacing the current
iTerm setup is a design choice. Where prerequisites are still needed, their
availability and explicit setup path must be discoverable.

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

### Requirement: separately grant input, menu invocation and window focus

Keystroke delivery, menu invocation and window focus SHALL each be grantable
independently of the other two. Permission to list or inspect state, or to focus
a window, does not grant input delivery or menu invocation. These boundaries
apply to the effects regardless of which public operation exposes them.

The boundary covers effects Koine selects through a native API or its parameters,
including the primitive's documented semantics and every preparation or fallback
call. It applies equally to input, menus and tool operations. General keystroke
delivery and menu invocation do not sandbox the receiving application's own
reaction: a menu item may open or focus a window without Koine requesting a
separate focus operation. Antony accepted this limit during design review
integration. It does not permit Koine to conceal an activation call as a reaction.

The current framework assigns read/control capabilities per provider. Design
must choose provider boundaries or an explicit contract change that preserves
the agreed separation; this requirement does not choose either mechanism.
File search, file/URL opening, explicit menu opening and prerequisite setup must
also have documented authority in the operation-to-capability acceptance trace.
Client confirmation UI does not replace Koine's grant checks. Existing live
revocation and native-consent rules continue to apply.

## Workflow inventory

Every row is part of the agreed baseline, with the client responsibilities
above preserved. The inventory names behavior rather than prescribing a
provider layout.

| Area | Required behavior |
| --- | --- |
| Desktop windows | Switch Spaces through the configured Control-digit workflow; list and select windows; place windows in thirds, half-thirds, two-thirds, halves and quarters; maximise, centre and restore geometry. |
| Displays | List displays; move a window to a selected display while preserving its position and size as fractions of the displays' visible areas; focus a display for subsequent desktop interaction. |
| Named application launchers | Launch or activate Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. |
| Application discovery | Koine supplies native application metadata for client filtering and selection; launch or activate a selection, reveal it in Finder, copy its path or copy its bundle identifier. Discovery availability/completeness must be explicit. |
| File search | The client searches under its configured roots, currently the home directory. Koine supplies special starting locations and the existing explicit default/Zed open and Finder-reveal actions; the client owns path copy. |
| Native metadata discovery | V1 supplies special locations and named native catalogues for applications and preference panels. Clients filter/rank choices; no general OS metadata-query API is included in v1. The returned design defines sources, completeness and selection metadata. |
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
| Terminal context | Identify the focused terminal host and its nested herdr context sufficiently to select and address the intended running instance. iTerm is the required host baseline. Clients own navigation into and out of that chain. |
| herdr panes | List/select, cycle, directionally focus/split/move, zoom and close panes. Copy mode selects within the live herdr pane; scrollback opens that pane's buffer in an editor. These are distinct from the host terminal's own copy mode. |
| herdr tabs and Spaces | List/select, cycle, create, rename, close and reorder tabs and Spaces, preserving the applicable containing scope. |
| herdr worktrees | List worktrees; create and remove them; focus the live Space when already open, otherwise open the dormant worktree. Removal is non-forcing; the client retains confirmation. |
| herdr agents and lifetime | List/select and cycle agents; jump to the next blocked agent; distinguish detaching the client, which leaves the server and panes running, from stopping the server. |
| Integration setup | Support explicit prerequisite setup where needed, including the configured iTerm setup workflow or an equivalent solution that removes that prerequisite. |

VS Code's screen workflows are deferred: project/window and terminal/editor
selection, focus and editor commands, Grove leaf reveal and task-tab cleanup,
and companion install/update. They receive no design or acceptance work in this
increment. Its named launcher remains in the baseline above.

The current installation probe supports the geometry-layout screen. Paneru's
alternative strip listing, west/east focus and swap, grow/shrink and strip
centring are not added to the requirements simply because their definitions
remain in the configuration. The unbound Dia AppleScript tab-list/focus helpers
and the separately registered, unreachable iTerm focus-walk entry likewise add
no extra scope.

### State for configured lists and on-screen labels

Koine must expose the native state needed to place the configured client-drawn
labels over desktop windows, iTerm panes and herdr jump targets. This includes
screen-space geometry tied to the selected resource, the window stacking and
visibility information needed to account for occlusion, and enough host/tool
geometry to locate herdr's pane, tab, Space and agent targets on screen. A target
without an available on-screen location must be distinguishable from one with
a known location; do not fabricate coordinates. Clients own label assignment,
placement policy and rendering. Display labels may use client-readable display
geometry; acceptance must identify that client responsibility explicitly.

List state must preserve what the configured screens display: iTerm tab titles
and the current tab; iTerm pane titles with process and working-directory
information for the untitled-pane fallback; herdr row titles/details, focused
or current state, agent status sufficient for status-priority ordering, and
worktree current and switchable state. The resource reference and containing
scope must keep that state associated with the right target even when labels
are equal. Presentation and ordering remain client responsibilities; unknown
state must be distinguishable from a known false value.

## Application-menu requirements

### Requirement: discover the application's menu system

Koine SHALL provide access to the selected application's menu bar and context
menus, including nested and dynamically populated submenus. This is a general
menu facility, not a catalogue of the currently configured shortcut actions.
Application-owned status-item menus in the macOS menu bar and Dock menus are
deferred and receive no design or acceptance work in this increment.

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

#### Scenario: the target loses foreground

If the target process stops being the active application, an interaction with
an explicitly opened context menu or menu-bar submenu stops and cleans up under
the interruption policy below. This observable trigger does not depend on who
caused the activation change. Explicitly declared client presentation is the
exception; design must define its declaration and recognition without treating
a client display label as an authenticated executable identity. It must not
silently choose a new target. Koine does not bring the original application
back or continue the interaction in the newly active one.

### Requirement: validate the selected item before invoking it

Koine SHALL invoke the selected, currently valid menu item or report that the
selection is unavailable. It SHALL NOT substitute a different item by matching
the old title, ordinal or menu path. A selection that cannot be validated
requires a fresh list and a new selection.

#### Scenario: a recent-document item is replaced

If a different document replaces an Open Recent entry after listing, invocation
of the old selection is rejected. The replacement is not opened on its behalf.
An unrelated sibling change need not invalidate an unchanged selection that
can still be validated. Conservative invalidation is also permitted: it must
report the selection unavailable and require a fresh list and selection. This
accepts the extra interaction rather than requiring stable selection across
every menu refresh. Duplicate titles are not sufficient identity.

#### Scenario: disabled, removed or inaccessible selection

An item that has become disabled or disappeared is not invoked as though the
old snapshot still applied. Loss of native consent and loss of client authority
retain their permission classifications. The existing contract's unknown
mutation-outcome and no-automatic-replay rules continue to apply.

## Interaction requirements

### Requirement: preserve the intended target and cancellation behavior

Application, window, workspace and pane operations SHALL preserve the
target selected for the interaction. Discovery must provide enough identity and
state for clients to distinguish equal labels and select the intended resource.
The native limits of the existing contract still apply; providers must not
deliberately retarget by a convenient title or current foreground application.

#### Scenario: Dia recent-tab interaction

Opening the recent-tab walk holds Control and advances once. Forward/backward
steps operate the same interaction. Confirm releases Control to accept the
highlighted tab; cancel dismisses the chooser before release so it does not
commit the preview. A user switch to another application stops the interaction
and cleans up its held modifiers rather than reclaiming focus. The same rule
applies whenever the target loses foreground, with the explicit exception for
declared client presentation above. No Escape or cancel keystroke is sent to the
new foreground application. Releasing only Koine-owned modifiers is permitted
even if that application observes key-up. Normal finish, cancel and interruption
follow the cleanup requirements below.

### Requirement: bound abandoned interactions and clean up owned effects

Dia walks and explicitly opened menus SHALL have Koine-owned cleanup that does
not depend on another successful client request. Revoking the owning grant,
abandonment after a bounded period of inactivity, and orderly Koine shutdown
stop the interaction and release its owned modifiers/dismiss its opened menus.
Client crash or disconnect must not leave an interaction alive indefinitely
between requests; the inactivity bound covers loss that Koine cannot otherwise
observe. Design chooses and documents the bound and how activity renews it.

Cleanup is limited to ending effects of the already admitted interaction. It
must not admit a new client action under a revoked grant, bypass native consent,
reclaim target focus or send Escape/cancel to a newly active application. Only
the release of Koine-owned modifiers is exempt from the prohibition on cleanup
keystrokes reaching that application. It is not permission to release unrelated
modifier holds. Design must reconcile cleanup ownership with the existing
grant/dispatch admission boundary and demonstrate the native behavior.

Normal finish, cancellation and these interruptions must not silently leave
owned effects behind. Failed cleanup is reported as unconfirmed, not successful
cancellation or rollback. An abrupt Koine crash is an accepted residual case:
held modifiers or open menus may remain. The design must provide explicit
recovery guidance and define the recovery mechanism; it must not claim cleanup
succeeded while Koine could not perform or confirm it. Restarting must not
automatically replay the interrupted application action.

## Test seams and acceptance

Native locations and metadata discovery use the already agreed seams: public
results and permission diagnostics through GraphQL, actual provider/host
integration through the native binary interface, and native calls with independent
dialog/hydration observation under signed Koine in isolated VMs. Controls inside
those seams add no new product seam. Location values must be usable starting
points without claiming client access; native catalogue observations, empty/
unavailable/blocked/unknown outcomes, useful application choices and existing
explicit selection actions need acceptance. Client-owned raw-search traversal,
ordering and coverage are client obligations. The [previous search proposal](../specs/workspace-search.md)
requires returned design and mandatory review under this revised ownership.
Earlier raw-search/custom-walk measurements accept no native discovery backend.

Acceptance must cover actual OS-known starting locations without directory
listing or inferred client access; useful native application choices including
the configured launchers, Safari and Finder, with distinct installations and
truthful metadata; and actual macOS 26+ System Settings destinations. Unknown or
unavailable metadata must remain distinct from healthy empty or complete
discovery. Signed-host reads need independent dialog/hydration controls; existing
selected actions retain their own authority and native receipt checks. These
expectations are agreed through the existing three seams; unavailable native
subjects remain pending.

The population design adds [P1024](../verification/native-discovery-acceptance.md#application-population-subjects)
as a finite useful-application witness: >256 distinct useful identifiers,
configured/system launchers, helper pressure and independently recorded native
baseline apps. Shared population overflow is an honest failure, never a smaller
passing native-order sample. Client filtering uses explicit optional native
presentation facts; Koine does not silently remove helpers or unknown choices.
Complete-producer review and actual native qualification remain pending.

For the chosen settings route, those same seams cover an effect-free stopped-
target read and explicit background preparation, denied/revoked preparation
authority, an already-running target without reactivation, exact-event refusal
and any conditional explicit Automation setup. Signed-VM witnesses must pair
the new preparation action with independent foreground observation, reads with
dialog/hydration controls, and actual pane/anchor selections with visible
destinations. The required ordinary areas and applicable hardware/account cases
remain useful-category witnesses, not fabricated native passes. Returned design
defines the exact authority, readiness, failure and late-outcome contracts.

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
- A client with only read or window-focus authority cannot deliver keystrokes
  or invoke menu items. Input and menu invocation can each be granted without
  the other. Test these boundaries through their public operations, including
  denied and revoked grants, and record the authority for every other effect.
- Multiple iTerm/herdr instances, nested context and equal display labels;
  herdr's copy-mode/scrollback and detach/stop distinctions; non-forcing worktree
  removal.
- Window occlusion and stacking, visible and unavailable target geometry, iTerm
  pane labels and herdr jump labels over their corresponding native targets.
  Demonstrate current/focused rows, untitled iTerm pane fallbacks, herdr agent
  status ordering and current/switchable worktrees through the public state.
- Menu bar and both context-target modes; nested/lazy menus; required metadata;
  disabled and duplicate-title items; passive inspection versus explicit
  opening; cancellation and target foreground loss, including activation
  changes not caused by the user and declared client presentation.
- A replaced menu selection must be rejected. After an unrelated sibling
  change, either invoke the validated original item or report it unavailable
  and require a fresh selection; invoking any replacement fails acceptance.
- Dia confirm/cancel and cleanup for Dia, context menus and opened menu-bar
  submenus on foreground loss, grant revocation, client loss/inactivity expiry
  and orderly shutdown. Verify the documented inactivity bound, no new client action
  after revocation, and no Escape/cancel in the newly active app; only owned
  modifier releases may reach it. Exercise abrupt termination and the documented
  recovery path, retaining unconfirmed outcomes where cleanup cannot be proved.
- Missing integrations, unavailable targets, denied/revoked grants and absent
  native consent. An unavailable integration must not masquerade as a healthy
  empty list or count as a demonstrated working workflow.

Account-dependent workflows use dedicated test accounts and data inside the
isolated VMs. This applies to Signal, Slack, Telegram, Messages and Mail,
including conversations and messages needed to exercise their actions. Record
the actual workflow outcomes. If an account or required test data is unavailable,
the affected acceptance cases remain pending; a documented untested limitation
does not pass them. This agreement does not authorize using Antony's live
desktop or substituting mocks.

Acceptance records the actual application/tool versions and supported cases.
The existing supported OS/CPU matrix is the starting point. Any platform or
application limitation discovered during design or testing must be explicit;
it does not silently reduce the agreed baseline. As in the existing desktop
contract, report observed interactive latency rather than inventing an
unagreed numerical target.

The accepted native limits also include the application-reaction boundary
under separate grants above. Native evidence must distinguish Koine's selected
effects from the receiving application's response; observing a focus change
alone does not establish which caused it.

## Evidence and design handoff

The source is `~/.config/modaliser/config.scm` and its sixteen included
`app-trees/*.scm` files. The running installed Modaliser 4.0.0 was verified to
load that configuration after the files' modification times; its launch log
reported `config: loaded` on 2026-09-29. The included screens cover Safari,
iTerm, herdr, Zellij, Neovim, Dia, Finder, Mail, Slack, Zed, VS Code, Signal,
Messages, Telegram, Obsidian and Zotero. The executable bindings govern the
inventory where comments describe older bindings. This source inventory records
what was loaded; the scope reductions above determine what is required now.

Bound launcher constructors contribute secondary actions, and the bound Google
constructor contributes suggestions. Their installed Scheme definitions were
read; the relevant installed and user-mirrored library files matched. The
Paneru predicate was read and its login-shell path plus fallback directories
were probed: Paneru did not resolve while a positive control resolved `zsh`.
That is a reproducible current-installation result, not a read of the running
engine's cached load-time branch. These are bounded configuration observations,
not a claim that every function in the Modaliser repository was audited.

Detailed design must settle provider boundaries, schema composition and
capabilities under the agreed separation, target and menu-reference lifetime,
interrupted interaction ownership/cleanup, the inactivity bound and crash
recovery, declared client presentation, dependency discovery and integration
setup. Native menu population and validation need runtime evidence: Apple's
[menu-update contract](https://developer.apple.com/documentation/appkit/nsmenudelegate/menuneedsupdate(_:))
allows contents to change when a menu opens, and its
[show-menu action](https://developer.apple.com/documentation/applicationservices/kaxshowmenuaction)
describes an explicit contextual-menu effect. Neither establishes that every
application exposes every required menu through one mechanism.

These questions belong to design and planning. The agreed behavioral scope,
client/server boundary and test seams are their inputs and must not be
re-interviewed merely to choose an implementation.

## Grouped refinement and retained hold

The [grouped inventory/key refinement](../verification/application-metadata-grouped-storage.md) replaces complete retained key
partitions with independent linked-slab owners, while preserving the selected
reader semantics, scoped gates, every saved association and the full wire. Its
controlled local/source/two-walk enclosure still exceeds 20 MiB before other
terms; it establishes no useful fit or native pass. Earlier independent-block
numbers remain reproducible comparison. The amended private design boundary is complete; whole-producer review and the
advertisement/consumption holds remain. The [selected qualification order](../adr/application-metadata-qualification-precedes-analytic-fit.md) selects ordering only.
Private construction requires the complete [eligibility conjunction](../specs/application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence);
that predicate, rather than an abbreviated ordering summary, governs builds. Advertisement/downstream consumption remain held until full useful
native operands, actual complete selected responses, required witnesses and
independent serviceability qualify. Failed/refused/unknown required useful cases
and unavailable subjects keep those holds and affected acceptance work live.
Existing whole-producer review, all native G/N/V, actual full operands/response,
useful breadth and independent authority/action/Settings/disclosure/compatibility
duties remain. No repeated strict/scoped selection or new capture leaf follows.
