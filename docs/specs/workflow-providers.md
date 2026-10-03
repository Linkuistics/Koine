# Workflow providers

This is the designed extension for the
[agreed workflows](../requirements/modaliser-workflows.md), pending implementation
and acceptance. It does not claim that Koine 0.1.0 serves the new providers or
operations. The [Machine contract](machine.md) owns the shared transport,
authorization, errors, binary interface and existing desktop surface. This spec
owns workflow-provider responsibilities and the cumulative authority trace.
The [provider authority decision](../adr/provider-authority-follows-effects.md)
records the alternatives and costs.

Start with the [provider composition view](../design/architecture/index.html#diagram-workflow-providers),
then [independent target capture](../design/architecture/index.html#diagram-workflow-targets)
and [complete effect authorization](../design/architecture/index.html#diagram-workflow-authority).
These are design views, not runtime acceptance evidence.

## Provider responsibilities

| Identifier / GraphQL prefix | Owned information and state | Public obligation |
| --- | --- | --- |
| `desktop` / `Desktop` | Process/window references and observation; window/display geometry; pointer position; system-media access | List and manipulate desktop resources under desktop authority. Retain existing reference withdrawal and public Accessibility limits. |
| `workspace` / `Workspace` | Installed application and file discovery; native open/launch/reveal adapters | Search without launching; explicitly open/launch/reveal under workspace and focus authority. Do not turn search into installation, shell execution or automatic setup. |
| `input` / `Input` | Captured application targets; synthesized application input; owned modifier holds; bounded Space-switch requests | Address application input to the captured target without reclaiming focus. Space switching is a separate system operation requiring desktop control too. Own input-interaction state and its cleanup. |
| `menus` / `Menus` | Captured application/context targets; menu snapshots and selections; opened-menu interactions | Inspect without opening; open explicitly; validate selections without substituting titles, positions or paths. Own menu cleanup. |
| `iterm` / `Iterm` | iTerm instances, windows/tabs/panes, integration readiness and setup | Address the selected native resource, expose list/label state and provide explicit bounded setup. |
| `herdr` / `Herdr` | herdr instance and containing scopes, worktrees, agents and host association | Address the intended instance through its iTerm context; preserve containing scope, detach/stop and copy-mode/scrollback distinctions. |

All six use the same native loader and host-supplied framework. The five new
first-party providers ship as separately loadable bundles in Koine's sealed
provider root, with the existing hardened runtime and explicit approval plus
the catalogue's release signing-identifier check. No provider is
linked directly into the host. SDL types remain provider-owned; no provider
imports another provider's GraphQL types. A read/control pair appears in the
capability catalogue while its contribution is admitted, including a startup-failed
provider whose schema remains published. Installation does not
grant a client those capabilities.

The Machine contract's
[first-party selection policy](machine.md#first-party-provider-selection) reserves
all six identity/prefix pairs before discovery; the
[selection ADR](../adr/first-party-provider-selection.md) records the trade-offs.
Enabled shipped slots can select
an explicitly approved newer compatible per-user copy, retaining their canonical
position. A reserved-only identity cannot be enabled by installing a bundle.
Missing/rejected owners stay reserved. Tied highest release groups are visibly
refused before considering lower copies; late rejection never retries another
version. Candidate-specific staging keeps root/quarantine provenance intact, and
new first-party updates require `first-party-selection-v1` for old-host pre-load
refusal. Production catalogues exclude selection fixtures by signing identifier;
test catalogues admit their distinct fixture identifiers. The
[selection view](../design/architecture/index.html#diagram-provider-selection)
shows precedence; its linked failure view distinguishes rejection from startup
failure. Selection support is designed and pending acceptance, not a Koine 0.1.0
capability.

The Machine core owns composition, grant checks and error paths. Providers own
native observation, resource validity and the truth of their declared effects.
Private native helpers may share source mechanics, with provider-unique Swift
module and Objective-C runtime class names, or use one host-owned shared framework
image under its compatibility contract. Independently updated identities cannot
each embed a version of the same module. Helpers confer no authority and must
not create a second loader, service, permission owner or public test seam.
Lifecycle algorithms, inactivity bounds, presentation declarations and crash
recovery are settled by the held-interactions design for both input and menus.
The baseline cleanup obligations already apply; this document does not choose
their mechanism.

## Targets and authority

Apply one decision procedure to every provider. An effect is Koine-selected when
Koine requests it through a native primitive's documented semantics, a parameter,
or a preparation, fallback or cleanup call. Include it in the field's static
authority set even when the OS performs the effect or a particular invocation
does not exhibit it. Otherwise an application's own response is a reaction,
which Koine does not sandbox. An arbitrary menu item may open or focus a window;
a delivered application shortcut may do the same. Neither permits Koine to add
a focus/activation call. A native open/launch request includes activation, so
workspace declares desktop control. The same test applies to an iTerm or herdr
primitive; observation that an app activated does not alone classify the cause.
The [requirements](../requirements/modaliser-workflows.md#requirement-separately-grant-input-menu-invocation-and-window-focus)
record the accepted reaction limit.

Space switching is an intentionally system-directed effect, not a reaction of
a captured application. Its bounded input operation requires `input:control`
AND `desktop:control` and accepts only the configured Space destinations/chords,
not arbitrary session-level input. The native evidence must establish how the
configured shortcut is checked without changing settings, how an unavailable or
remapped binding is refused before posting, and what a check-to-delivery race can
deliver to the foreground app. If this cannot be bounded, return to design and
raise any new native limit with Antony before shipping; do not silently turn it
into generic untargeted delivery. Application-target capture below is a separate
contract and does not pretend to address a Space-switch event.
An input-only field must not route the same chords through system-shortcut
dispatch as an alternate path. If its native delivery mechanism cannot preserve
that separation, refuse that path or use the declared two-capability operation;
do not replace independently grantable application input with it.

An input or menu caller captures the process incarnation at interaction start.
The receiving provider accepts that external identity in its own input type,
using the existing exact PID/start-instant semantics, resolves it under its own
read authority, and returns its own opaque reference. It does not require
desktop read or control. Independent provider-local references are not equal
identities across providers and are not convertible URI strings.

**Protected UI targets.** Input, menus and any UI-driving preparation/fallback
must refuse Koine's own process before target issuance and again before an
effect. Possession of `koine:manage` does not enable this route. The same rule
refuses positively identified system consent or security UI; evidence must state
how such targets are recognized and where it cannot establish safe delivery.
Session-directed input also checks the foreground destination against this rule.
Return `unavailable` with `reason: protected-target` on these new operations,
without performing UI work or presenting an OS consent prompt. This denies the
direct route to Koine's approval, grant creation/revocation and Quit controls.
It does not turn native application control into isolation from malicious
same-user software, prevent every platform retargeting race, or constrain an
application's own privileged actions. A mechanism unable to enforce the direct
self-target refusal is not an acceptable input/menu implementation.
This does not cancel the already admitted exception for releasing Koine-owned
modifiers after foreground loss; refusing a new UI action must not strand a hold.

A subsequent input mutation takes an input reference and requires
`input:control`; a menu mutation takes a menus reference and requires
`menus:control`. Mutation receipts use control-authorized output types so a
caller holding a previously obtained reference can act with control alone.
Obtaining fresh choices normally also needs that provider's read grant.
Read does not imply control, and control does not imply read. Initial lookup
of an absent captured process can return ordinary null; use of a stale issued
reference is an `unavailable` execution error.

Window-specific menu/context targets are obtained through menus' own discovery
or explicit target capture. A point or focused element is tied to the captured
process and validated; current foreground, a moved pointer or an equal title
cannot silently replace the selection. A client cannot import a desktop window
reference by stripping its authority, wrapping it in a string input or changing
its URI prefix. These rules show how an action on an application or its
window-bound UI can use menu authority without desktop control. They do not
promise an arbitrary desktop window reference can be transferred to menus.

The Machine contract's foreign-reference checks still apply when an API really
accepts another provider's reference. In particular, a control field taking a
desktop reference requires desktop control; ordinary input and menu operations
must not use that shape. No internal call from another plugin creates a grant.

Effects determine the complete static requirement set. A workspace launch/open/
reveal field requires `workspace:control` and `desktop:control` unconditionally,
even if a particular invocation happens not to activate anything. This avoids
runtime-dependent authority. Koine issues no separate activation or focus in an
input-only or menu-only operation. If focus preparation is wanted, the client invokes
an explicit desktop operation with its own grant requirement. A combined field
may be offered only with the declared conjunction; it cannot replace the
independently grantable paths.

For tool actions, selecting a tab, pane or herdr Space through the tool's native
protocol is tool control. If that primitive's documented semantics or Koine's
parameters/calls select activation or desktop-window focus, the field additionally
requires desktop control. Application-defined reactions use the same rule as
input and menus above. If the mechanism
delivers keystrokes or invokes an application menu, it additionally requires
input or menus control. The downstream native evidence fixes that effect set
before registration; a provider cannot choose a more privileged fallback after
dispatch. The conservative set covers every supported execution path of that
field. Neither a confirmation dialog nor possession of a target replaces it.

The operation that admits an interaction also declares the authority of every
possible cleanup mechanism. An Escape fallback needs input control at admission;
a native menu dismissal needs menu control. Cleanup after revocation is permitted
only to terminate that admitted interaction's owned effects, within its captured
target and consent limits. It cannot select a new fallback requiring authority
not admitted initially. Only the already agreed release of Koine-owned modifiers
may reach a newly active app. Menu-only paths therefore need native menu cleanup;
a combined input/menu alternative cannot replace them.

The herdr design may establish a bounded association from an iTerm session to a
herdr instance. It must define discovery authority, evidence, lifetime,
revalidation and failure classification; preserve equal-label and nested
instance distinctions; and state the geometry transformation and unknown case.
If the public field takes an iTerm reference, the existing owner read/control
check applies. If it takes an external identity, herdr must independently
validate it and declare any additional read authority needed for host data.
No universal cross-provider identity, atomic snapshot, shared native-object
registry or ref-remainder decoding is authorized by this association.

## Authority allocation

This table allocates **every Koine-requested effect**, including hidden
preparation and fallback calls under the boundary above. It is the
policy input to each concrete operation added to the trace below. Read fields
use their owner's read authority, with any additional read requirements.

| Effect or observation | Owner and required capabilities | Boundary / client responsibility |
| --- | --- | --- |
| Windows, stacking/visibility, display and window geometry | `desktop:read` | Client derives choices, labels and occlusion policy; unknown geometry is explicit. |
| Window focus; window geometry and restore; move between displays; display focus | `desktop:control` | No application keystroke, pointer-button or menu fallback under this grant. Display focus must not click a control or blank desktop as an implicit fallback; a combined operation would need a separately declared input requirement and cannot replace focus-only access. Label policy is client-owned. |
| Control-digit Space switching | `input:control` AND `desktop:control` | Bounded system-directed operation; verify the configured binding, refuse known fall-through before posting, and establish the residual race as above. It is not application-targeted delivery. |
| Pointer location / nudge and movement with no held buttons | `desktop:read` / `desktop:control` | Client draws the reveal ring. Refuse a nudge while buttons are held rather than turning movement into an undeclared drag. |
| Synthesized pointer-button down/up/click/drag, including a context-menu fallback | `input:control`, plus the exposing provider's control and any other selected effects | Application input whatever the public field's name. Capture and revalidate the intended process/context; apply protected-target refusal. Menu-only paths cannot be replaced by right-click synthesis. This allocation does not add a general pointer-button API to the baseline. |
| System media play/pause, including system-defined media-key events | `desktop:control` | A media event addressed to the system-media route is distinct from an application key chord. Any chord alternative requires input authority and does not satisfy the required system route. |
| Installed-application search, paths and bundle identifiers | `workspace:read` | Client owns query entry, chooser, secondary-action menu and MRU. |
| File search under configured roots, currently home | `workspace:read` | Query scope is documented in each operation; do not omit inaccessible roots as healthy empty results. |
| Launch/activate; file/folder/default-app/named-app opening; URL opening; reveal in Finder | `workspace:control` AND `desktop:control` | Activation is requested. Optional action process identity is a control receipt; installed paths/identifiers/default-handler metadata remain read data. Handler reactions can execute documents or follow redirects. No search, grant or prerequisite check implicitly launches or opens. |
| Clipboard writes: path or bundle identifier | Client-owned | Read the value under workspace read; client performs its own pasteboard write. No Koine clipboard mutation is required. |
| Application keystrokes | `input:control` | Target capture/discovery uses input read; no implicit focus or menu invocation. |
| Held-modifier start/step/confirm/cancel | `input:control` | Koine owns the admitted hold and cleanup; client owns walk navigation. |
| Menu hierarchy/state/shortcuts; captured context target state | `menus:read` | Passive inspection cannot open a menu or report unpopulated contents as an empty complete list. |
| Explicit context-menu/submenu opening, menu invocation, explicit finish/cancel | `menus:control` | Menu-only operation paths use native menu operations without application keystroke delivery or focus reclamation. |
| Cleanup on revocation, inactivity, foreground loss and orderly shutdown | Owner of the already admitted input/menu interaction; every cleanup mechanism's capability included at its admission | This is termination of owned effects, not a new grant or client action. No new privileged fallback; only Koine-owned modifier releases may reach the new foreground app; no focus reclaim or Escape/cancel there. Unconfirmed cleanup remains unconfirmed. |
| iTerm state/labels and prerequisite discovery | `iterm:read` | Readiness does not install or configure. Client owns label placement and presentation. |
| iTerm panes/tabs, selection, movement, split, zoom, copy mode, rename/close/reorder | `iterm:control`, plus effect-dependent static additions described above | Native tool selection is distinct from desktop-window focus. Effect additions are fixed per field, not per call. |
| iTerm prerequisite setup | `iterm:control`, plus static additions for focus/input/menu effects if any | Explicit, bounded integration configuration, never arbitrary shell execution. Re-check prerequisites on action. |
| herdr context, panes/tabs/Spaces/worktrees/agents and geometry | `herdr:read`; also `iterm:read` when the field consumes host state | Preserve containing scope, current/focused/switchable and unknown values; clients order and navigate. |
| herdr pane/tab/Space commands, copy mode, scrollback, worktree creation/non-forcing removal/open/focus, agent selection/cycling, detach/stop | `herdr:control`, plus the same static effect additions | Client confirms removal; Koine still refuses forcing. Tool scope must not be inferred from equal labels. |
| herdr prerequisite discovery / explicit setup if required | `herdr:read` / `herdr:control`, plus any static effect additions | No implicit setup in reads; preserve integration and stale-target distinctions. |
| Google query/suggestions/typed-query fallback | Client-owned, then workspace and desktop control for URL opening | No Google proxy in Koine. |
| Client settings reload/relaunch | Client-owned | Opening the config directory in Zed uses workspace and desktop control. |

Existing desktop grants acquire the new desktop geometry/pointer/media surface
when implemented. They acquire neither workspace search/open nor input/menu
authority. The native grant UI and GraphQL descriptions must state this
provider-wide granularity. No capability implies another and requests cannot
combine several credentials.

Launch and open owns workspace control disclosure before workspace ships: any
registered installed application can be launched, and a default or named
document handler can execute scripts or follow location documents to other
schemes/targets. Refusing executable selectors and some payload metadata is not
a content sandbox. Both workspace and desktop control remain required.
Window layout owns disclosure of desktop's expanded provider-wide authority in
the native grant UI and GraphQL descriptions before its first new operation
ships; pointer and media extends that disclosure before its additions ship.
App input must disclose that controlling a terminal can type and execute commands
with the user's authority. Menu bar must disclose access to arbitrary exposed
application menu actions, including destructive ones and application reactions.
These grants are not restricted to the configured shortcut catalogue. Acceptance
checks the create/approve UI, existing-grant display after upgrade, and field
descriptions, without silently revoking or reauthorizing existing grants.

## Operation-to-capability trace

Each row below is an allocated requirement, **not an implemented operation**.
The owning increment replaces the operation cell with exact public coordinates,
complete static requirements (including reference-owner requirements), and
links to its three-seam evidence. Split a row when different mechanisms have
different grants. Keep client responsibilities and unresolved acceptance
visible. API design must resolve a conditional tool effect before implementation;
the phrase “plus effects” is not a completed trace.

| Inventory row | Operation allocation / client step | Increment; acceptance |
| --- | --- | --- |
| Desktop windows | Desktop read/control for list, select/focus, layouts and restore; input + desktop control for bounded Control-digit Space switching | Window layout; app input. Pending. |
| Displays | Desktop read/control for list, proportional transfer and display focus; client display labels | Window layout. Pending. |
| Named application launchers | `Mutation.workspaceLaunchApplication(application:)`; `workspace:control` AND `desktop:control` for all twelve applications, including VS Code. Unconstrained launch allows running-copy reuse; an installation constraint does not. | [Launch/open acceptance](workspace-launch-and-open.md#acceptance), including activation with another app frontmost and bounded acknowledgment. Served by the bundled workspace provider; L, G and N are established for this root, and V (activation, cold and warm, the twelve launchers, and the Gatekeeper timeout) is accepted in [launchers-vm.md](../verification/launchers-vm.md). |
| Application search | Workspace read discovery remains to be designed; reuse `workspaceLaunchApplication` and `workspaceRevealPath`, each `workspace:control` AND `desktop:control`; client clipboard and MRU | App and file search; reused [launch/open actions](workspace-launch-and-open.md#operations). `workspaceRevealPath` is served by the bundled workspace provider with L, G, N and V established ([evidence](workspace-launch-and-open.md#evidence-so-far), [V](../verification/reveal-path-vm.md)); receipt is Finder's acknowledgment, not observed selection. Search pending. |
| File search | Workspace read discovery remains to be designed; reuse `workspaceOpenPath` and `workspaceRevealPath`, each `workspace:control` AND `desktop:control`; client clipboard. Source documents retain default handlers; Finder aliases cannot be opened by this contract but can be revealed. | App and file search; reused [launch/open actions](workspace-launch-and-open.md#operations). Protected-path metadata evidence precedes reliance on path opening. `workspaceRevealPath` is served with L, G, N and V established ([V](../verification/reveal-path-vm.md)): a Finder alias is selected itself, an application is selected and never opened. `workspaceOpenPath` is served by the bundled workspace provider with L, G, N and V established ([evidence](workspace-launch-and-open.md#evidence-so-far), [V](../verification/open-path-vm.md)); protected default opening stays pending (`protected-default-open-k89`). Search pending. |
| Web search | Client query/suggestions/typed-query fallback; `Mutation.workspaceOpenURL(url:)`, `workspace:control` AND `desktop:control` | [Launch/open acceptance](workspace-launch-and-open.md#acceptance). Served by the bundled workspace provider; L, G, N and V are established for this root ([evidence](workspace-launch-and-open.md#evidence-so-far), [VM acceptance](../verification/open-url-vm.md)), except Dia's page load, which stays pending an account decision. Client responsibilities, recorded: query entry, the search engine and its template, suggestions and the typed-query fallback (the one open, chosen before the request) are the client's; Koine makes no search request and has no Google proxy (its network calls over the VM run include no `connect`). The [contract-only client](../../clients/contract-only/README.md) does all of it from the documented contract ([findings](../verification/open-url-contract-client-findings.md)). |
| Media | Desktop control, system route | Pointer and media. Pending. |
| Pointer | Desktop read/control; client ring | Pointer and media. Pending. |
| Client settings | `Mutation.workspaceOpenPath(path:, application:)` selects installed Zed; `workspace:control` AND `desktop:control`; client reload/relaunch | [Launch/open acceptance](workspace-launch-and-open.md#acceptance). Served by the bundled workspace provider; L, G, N and V are established for this root ([evidence](workspace-launch-and-open.md#evidence-so-far)); the configuration directory opened in installed Zed in a prepared VM ([open-path-vm.md](../verification/open-path-vm.md#opening-in-the-default-handler-and-in-zed)). Reload and relaunch stay client-owned. |
| Safari | Input control for verified keystrokes, or menus control for verified menu invocation | App input → menu bar → context menus if opening required. Pending. |
| Dia | Same routing for ordinary commands; input control for the owned recent-tab walk | App input; held interactions; menu routing as above. Pending. |
| Finder | Input control or menus control by verified mechanism | App input → menu bar → context menus if needed. Pending. |
| Mail | Input control or menus control by verified mechanism | Same route; account acceptance. Pending. |
| Slack | Input control or menus control by verified mechanism | Same route; account acceptance. Pending. |
| Zed | Input control or menus control by verified mechanism | Same route. Pending. |
| Signal | Input control or menus control; intended shortcut results must be verified | Same route; account acceptance. Pending. |
| Messages | Input control or menus control; intended find/conversation results must be verified | Same route; account acceptance. Pending. |
| Telegram | Input control or menus control by verified mechanism | Same route; account acceptance. Pending. |
| Obsidian | Input control or menus control by verified mechanism | Same route. Pending. |
| Zotero | Input control or menus control by verified mechanism | Same route. Pending. |
| iTerm | iTerm read/control; record every static addition from native effects; full tab/pane label state | iTerm. Pending. |
| Terminal context | herdr read plus host-read requirements fixed by the association design; client chain navigation | herdr. Pending. |
| herdr panes | herdr read/control plus declared effects; copy mode and editor scrollback remain distinct | herdr. Pending. |
| herdr tabs and Spaces | herdr read/control plus declared effects; scoped selection and reordering | herdr. Pending. |
| herdr worktrees | herdr read/control plus declared effects; client removal confirmation | herdr. Pending. |
| herdr agents and lifetime | herdr read/control plus declared effects; client status ordering; distinguish detach/stop | herdr. Pending. |
| Integration setup | Owning tool's read/control, plus declared effects; no automatic setup | iTerm; herdr if needed. Pending. |
| Application menu bar (additional requirement) | Menus read/control; hierarchy, lazy state, metadata and stale refusal | Menu bar; opened submenus in context menus. Pending. |
| Context menus (additional requirement) | Menus read/control; both point and focused-element capture; same lifecycle | Context menus. Pending. |
| List and label state (cross-cutting requirement) | Desktop, iTerm and herdr reads as applicable; client labeling/rendering/ordering | Window layout; iTerm; herdr. Pending. |
| Interruption and cleanup (cross-cutting requirement) | Koine input/menu owners; bounded cleanup and explicit crash recovery | Held interactions; context menus. Pending. |
| Grant disclosure (cross-cutting requirement) | Native grant creation/approval and existing-grant views plus GraphQL descriptions; disclose provider-wide effects and application reactions | Launch and open for workspace (accepted: [workspace-disclosure-vm.md](../verification/workspace-disclosure-vm.md)); window layout, extended by pointer and media; app input; menu bar. Pending before each of those surfaces ships. |

The standalone acceptance client demonstrates Koine's part and identifies every
client step. Account-dependent results require dedicated VM accounts and data;
missing accounts remain pending live work. Unavailable integration reporting
does not satisfy a required working integration. VS Code screen operations,
Zellij, Neovim, status-item menus and Dock menus are outside this baseline.

## Dependency results and failure classification

New operations that can encounter a missing application, handler or integration
use provider-prefixed schema objects expressing **available** versus
**dependency unavailable**, with a machine-readable reason and human guidance.
The unavailable branch has no successful value; the available branch carries
the operation's result. Exact field names and closed reason enums belong to the
owning increment and must be in its SDL. Ordinary objects, enums and nullable
members suffice; the framework need not add unions or interfaces.

For a list, available with an empty list is success. Dependency unavailable has
no list; it must not be encoded as the same empty list. If submenus need opening,
their explicit population state is neither dependency absence nor an empty
complete list. Unknown state/geometry is similarly represented explicitly.

Search additionally reports coverage for each requested root: searched scope,
skipped scope and reason, and whether coverage is complete, partial or unknown.
Successful matches may coexist with explicit partial coverage; an empty partial
result is not a complete successful search. Consent-blocked roots carry the
`permission` / `os-permission` classification and owner/consent diagnostics in
their coverage outcome. If consent blocks every requested scope, search fails with that
permission error rather than returning a healthy empty list. Missing indexes or
application-side API enablement are dependency prerequisites, not OS consent.
Exact coverage types and reasons belong to app-and-file-search's SDL.

| Situation | Observable contract |
| --- | --- |
| Application not installed, no suitable opener, prerequisite missing or unsupported integration version | Typed dependency-unavailable result with a documented reason, no successful value and no action attempted. |
| Issued target removed/replaced, wrong resource kind or stale captured context | Existing `unavailable` error, with its normal path and null propagation. |
| Successful search/list with nothing matching | Available result with an empty list and no execution error. |
| Missing or revoked client authority | Existing `permission` / `capability`; check before resolving readiness or disclosing resources. |
| Missing native consent | Existing `permission` / `os-permission`; not a missing dependency and not an empty result. |
| Unexpected native/protocol failure, timeout, or dependency lost after effects may have started | Existing `failed`; no assertion that nothing happened and no automatic replay. |
| Provider absent from the served schema | Client detects missing coordinates through introspection; sending them is GraphQL validation failure. An unknown reference authority remains `unknown-provider`. Managers can inspect loader diagnostics. |

The action path checks prerequisites itself after authority admission; a prior
readiness query can become stale. A dependency result on a mutation promises
that **that action** did not begin its domain effects. It says nothing about
earlier root actions in the same operation. Where the provider cannot establish
that promise, return `failed` rather than a reassuring unavailable result.
If target withdrawal and dependency absence overlap, locally established
withdrawal is reported as stale; otherwise a missing prerequisite can be
reported without claiming the old target remains valid. Permission checks still
precede disclosure. Existing desktop error behavior does not change.

All readiness/search/inspection reads must avoid OS consent prompts, not just
Accessibility reads. Where checking or traversing a scope would itself prompt,
do not attempt it: report consent status or coverage as unknown/blocked and
direct the user to Koine's explicit setup guidance. New operations follow the
Machine contract's extension-only consent diagnostics. Their concrete consent
inventory, target application/scope and consent-acquisition path must be settled
by their evidence/design owner. This policy approves no new entitlement or
consent; any signing-posture change is still raised with Antony first.

The [protected-path probe](../verification/protected-path-metadata.md#handler-lookup-limit)
found a concrete limit for workspace: tested first-use metadata and registered-app
inspection was prompt-free on Desktop, Documents and Downloads, but file-URL
default-handler lookup for documents prompted. Application/file search must keep
handler metadata unknown/blocked wherever no prompt-free route has been established,
and must not call that lookup to discover whether consent is needed. Protected
default opening remains pending; this result authorizes no new consent or
content-type-only substitution. The metadata result does not establish prompt-free
directory traversal or content search. Removable/network volumes were unavailable.

The [search-discovery comparison](../verification/search-discovery.md) then
measured directory traversal inside signed hardened Koine. Ordinary directory
listing, a home scan with exclusions and application-registration inspection
were prompt-free in its bounded fixture; direct Desktop/Documents/Downloads
listing and a Desktop Spotlight query prompted. Disabling indexing did not
make filename queries fail. The following API design must consume those limits,
state coverage and avoid prompting discovery probes. No new consent or
entitlement is approved by this evidence, and search remains designed/pending.

## Compatibility and delivery

Keep `koine-desktop/1`. New provider schemas and optional fields are additive;
existing fields, input meaning, nullability and error kinds keep their meaning.
New required behavior in the native framework is governed by
[additional capability requirements](machine.md#additional-capability-requirements).
Provider schemas remain independent of the framework version: loading a binary
does not establish its GraphQL compatibility.

Each increment maintains its provider SDL design artifact and example client
operations, and extends the repeatable conformance task to assemble the core
and **exact active provider set** in canonical composition order. Compare the
complete served SDL/digest, not just the desktop subset. Preserve a core +
desktop conformance profile for old binaries and explicit absent/rejected
provider profiles. A disabled provider's omission must not silently shrink an
acceptance profile that requires it. Clients use introspection and schemaDigest
to discover additions; they do not infer availability from a release version.
Profiles pin expected candidate versions as well as the active identity set:
identical SDL/digests do not prove which binary was selected. Per-user replacements
occupy shipped positions; other per-user providers follow. Keep old-host profiles
separate from extension-host profiles with additive candidate diagnostics.

The framework feature itself is implemented: framework minor 1 with
`additional-capabilities-v1`, enforced at whole-mutation preflight, dispatch
admission and read publication, with the missing-owner cascade, established at
the public seam over in-test contributions and in independently built binaries
(`AdditionalCapabilityTests`,
[binary-compatibility.md](../verification/binary-compatibility.md)). No shipped
provider declared one until the launch-and-open increment's workspace provider,
which is its first consumer: `workspaceLaunchApplication` and every field it
reaches require `workspace:control` with an additional `desktop:control`, composed
and loaded through the existing native seam (`WorkspaceCompositionTests`,
`WorkspaceProviderTests`). Its planning included that vertical dependency. This design adds no implementation leaves. The held-interactions design separately
owns any framework support for grant-bound lifetimes and autonomous cleanup;
such support also needs an explicit minor and required feature before use.

Launch-and-open also implements the Machine contract's
[selection acceptance cases](machine.md#selection-acceptance), including independent
signed desktop/workspace updates, old-host refusal, approval, reserved collisions,
multiple candidates, visible tie fallback, candidate-specific staging, no late
fallback, missing-owner cascades, startup failure, native-name publication and
exact-candidate conformance. That table assigns each case N/G/V seams, requires
fresh native host processes and marker controls, and explains purpose-built
sealed-host fixtures. Every case is pending until its assigned evidence is
recorded; earlier single-bundle compatibility evidence does not close it.

## Test seams

Reuse the three agreed seams. The GraphQL engine's native-provider composition
point selects controlled test providers for authorization/order tests; the real
provider binaries and real applications establish native behavior. These are
existing enabling points, not a new public testing API or mocks of desktop apps.
Workspace also substitutes its private native adapter inside provider-local
tests to exercise its real classification and completion logic. These supporting
checks do not replace the three product seams: a composition fake cannot prove
workspace's native-result mapping, and a substituted adapter cannot prove an OS
outcome or independently built native compatibility.

| Seam | Required evidence for this architecture |
| --- | --- |
| Public GraphQL | Read-only/focus-only cannot send keys or invoke menus. Input-only and menu-only control paths work without desktop control, using their own references and receipts. Workspace-only control cannot launch/open/reveal. Missing any declared additional capability denies the entire selected mutation before all actions; aliases, fragments, input objects, defaults and skipped fields preserve the rule. Revocation before dispatch refuses the next action; read publication rechecks all read requirements. |
| Public GraphQL | Dependency unavailable, stale target, complete empty result, partial/unknown search coverage and both permission classes remain distinguishable, including a prerequisite that vanishes between readiness and action. Existing desktop classifications are unchanged. Protected readiness does not leak through a denied grant. |
| Public GraphQL and isolated VMs | Input/menu grants cannot drive Koine's approval, creation, revocation or Quit controls, including previously obtained targets and session-directed paths. Recognized consent/security targets are refused. Space switching needs both input and desktop control; disabled/remapped bindings exercise refusal and the stated race limit. A display-focus or menu-only grant never acquires a pointer-button fallback. |
| Native binary interface | Old compiled registrations retain old behavior on the new framework; a provider requiring additional-capabilities-v1 is refused before loading on an old host. New-host checks enforce its actual extra requirements. Compare independently built binaries and signed supported pairs; test unavailable capability owners and registration/manifest disagreement. **Established for the framework feature**, with a fixture provider: the released host refuses it before load, the new host enforces its set and refuses an undeclared use and a manifest/descriptor disagreement, and an old provider and the released desktop provider run unchanged on the new host, on independently built unsigned hosts. **Pending**: the workspace provider's own extra requirements, and every signed pair. |
| Native call-path inspection and isolated TestAnyware macOS VMs | Enumerate each primitive, parameter, preparation, fallback and cleanup path against the authority trace. Use targets whose invoked operation does not itself change focus to distinguish Koine's extra activation calls from app reactions, and record both observations and inspected calls. A VM focus change alone proves neither the presence nor absence of a hidden call. Workspace activation requires both grants; real menu-only and application-input-only paths preserve independent grants. Record permissions, app/tool versions, limits and pending account cases. |
| Isolated TestAnyware macOS VMs | Every read remains prompt-free, including first access to protected roots and Automation readiness. Revocation/inactivity cleanup uses only mechanisms admitted at start. Grant UI/descriptions disclose workspace app/document reach, expanded desktop control and broad input/menu reach before each surface ships. |

The module boundary keeps caller obligations to target capture, capability
selection and one operation/result contract. It separates discovery from
effects and client presentation from provider state. Its costs are independent
target lookups, six bundles, the additional-capability framework feature and the
host selection feature. A native
operation whose effect set cannot be fixed before dispatch, or a requirement to
transfer a held target across providers, would disprove the sufficiency of this
design and must return to design before implementation. The accepted platform
races are unchanged; diagrams and source inspection are not native guarantees.
