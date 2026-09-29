# Workspace launch and open

**Designed, pending implementation and acceptance.** Workspace supplies the
launchers, browser opening, file/folder opening and Finder reveal required by
the [workflow inventory](../requirements/modaliser-workflows.md#workflow-inventory).
The [workflow spec](workflow-providers.md) owns the cumulative authority trace;
the [Machine contract](machine.md) owns authorization, errors and composition.
The [authority](../adr/provider-authority-follows-effects.md) and
[selection](../adr/first-party-provider-selection.md) decisions bind this design.
Nothing here claims that Koine 0.1.0 serves workspace.

Start with the [request sequence](../design/architecture/index.html#diagram-workspace-open)
and [outcome boundary](../design/architecture/index.html#diagram-workspace-outcomes).
The [workspace SDL](../design/workspace-schema.graphql) and
[client operations](../design/workspace-operations.graphql) fix the public shapes.
The SDL is a contribution, not the complete composed schema.

## Operations

Every root below is nullable and requires **workspace:control AND
desktop:control**, unconditionally. Every nested result and receipt field carries
that same conjunction. Neither read capability is required. There are no
Reference arguments and thus no additional reference-owner requirements here.

| Coordinate | Input | Available value |
| --- | --- | --- |
| `Mutation.workspaceLaunchApplication` | Required `WorkspaceApplicationInput` | `WorkspaceOpenReceipt`: native launch-or-activate request accepted. |
| `Mutation.workspaceOpenURL` | Required absolute HTTP(S) URL string | `WorkspaceOpenReceipt`: URL submitted to the resolved default browser. |
| `Mutation.workspaceOpenPath` | Required absolute local path; optional `WorkspaceApplicationInput` | `WorkspaceOpenReceipt`: file/folder submitted to its default or named app. |
| `Mutation.workspaceRevealPath` | Required absolute local path | `WorkspaceRevealReceipt`: Finder reveal request acknowledged. |

`WorkspaceApplicationInput` contains a nonblank `bundleIdentifier: String!`
and optional `applicationPath: String`. The identifier names an installed app,
not a display name or process incarnation. Without a path constraint, Launch
Services chooses the installed copy at action time. With a path, only a registered
application bundle at that canonical location with the matching identifier is
eligible. Missing registration/bundle is `APPLICATION_NOT_INSTALLED`; an extant
bundle with a different identifier is `APPLICATION_IDENTITY_MISMATCH`. Neither
substitutes another copy. A future search result can pass its identifier/path
without requiring a reference conversion. Registration is native discovery,
not Koine provider approval or an additional application allowlist.

A running copy at the resolved location is reopened/activated. Koine requests
neither a fresh instance nor substitution by a running copy elsewhere. The app
owns its reopen behavior: Koine does not promise a new window, restore every
minimized window, select one of several running instances, or keep the app
frontmost against other activity. Clients needing a specific window use desktop
discovery/focus afterward. Do not report `wasAlreadyRunning` from a racy precheck.

Paths are literal absolute paths on Koine's machine, not file URLs, globs,
tilde expansion or environment substitutions. Reject empty, relative and
NUL-containing paths as input errors; spaces and shell punctuation remain
literal. Resolve symlinks for application-copy comparison. Document paths are
location-based requests with normal symlink semantics, not pinned file identities.
An absent path/dangling link found before submission is `PATH_NOT_FOUND`.
Replacement or handler changes racing submission may fail or open a new
occupant. Search must not imply stronger identity than this contract.

Path opening sends a document/directory to an installed handler; it never
executes the path as a program. Reject application bundles and native executable
files as direct launch payloads, including through symlinks. In the default-handler
form also reject OS-classified executable scripts; the explicit named-app form
may send a script as a document (for example, editing it in Zed). It does not
select an interpreter executable or supply program arguments. The named app owns
its document behavior, which may itself run code. Document packages remain
eligible unless classified as applications. Reveal may select applications or
executables without running them. No operation accepts executable selection,
argv, environment, custom Apple events or shell commands. An application's own
response to a document, directory, page or reopen request is not sandboxed.

URL opening accepts only `http`/`https`, with a host, valid syntax and no
credentials or control characters. Other schemes, including `file`,
`javascript` and custom application schemes, are input errors. Preserve valid
path/query/fragment data. Resolve the default handler for the URL's scheme and
submit explicitly to that app, avoiding universal-link dispatch to a native app.
The receipt identifies the handler used even if the default subsequently changes.
Query entry, suggestions and typed-query fallback remain client-owned; Koine
does not construct searches or contact Google.

Omitted/null `application` on path opening selects the default handler. A named
app need not advertise every supported type: submit the normal open-document
request and classify native refusal as `failed`. Advertised types cannot prove
an app will accept a directory (Zed's required case). No chooser, installation,
default-handler modification or fallback to another app occurs. Client settings
uses the config directory and installed Zed; reload/relaunch remain client-owned.

## Results and failure boundary

The result's `status` is `AVAILABLE` or `DEPENDENCY_UNAVAILABLE`. Exactly one
of `value` and `dependency` is non-null, selected by status. The dependency
object carries a closed reason enum and human guidance; it is not an execution
error. Validate this invariant at public GraphQL: nullable object members alone
cannot express it. Available means native acceptance, not that a document
finished rendering, a page loaded, or Finder selection was independently seen.
A null root always has an execution/input error for these four fields.

`WorkspaceOpenReceipt` contains the chosen `applicationPath`, its optional
bundle identifier, and optional `WorkspaceProcessIdentity` (`pid`, `startedAt`).
These are observations of this action under control authority, not general
application discovery. `startedAt` has the exact desktop input semantics: the
kernel process start instant in UTC with six fractional second digits. Use it
only if the native result's application and PID/start observation can be matched.
Exit, ambiguity or unreadable start time produces `process: null`, never PID-only
identity or the current foreground process. The native application's launch date
is not a substitute for the exact kernel value. Later exit is always possible.

The client copies a non-null identity into `desktopApplication(process:)` under
`desktop:read`, then uses returned desktop references unchanged. Workspace
imports no Desktop SDL type and issues no desktop reference. Absent process and
later reference withdrawal retain the desktop contract's null/error distinction.

`WorkspaceRevealReceipt.path` echoes the submitted path. Reveal uses Finder's
native selection operation with a boolean acknowledgment: false means `failed`.
It does not infer success from a void send or add AX, keystroke or menu checks.
A directory is selected in its parent; the filesystem root is shown as a root
view because it has no parent. Native acceptance is not selection verification.

| Condition after grant admission | Observable outcome |
| --- | --- |
| Application absent/unregistered, including missing constrained copy or Finder | Dependency `APPLICATION_NOT_INSTALLED`; guidance names the app; no action. |
| Constrained bundle has another identifier | Dependency `APPLICATION_IDENTITY_MISMATCH`; no substitution/action. |
| Path missing or dangling link | Dependency `PATH_NOT_FOUND`; no action. |
| Existing path or valid web URL has no default opener | Dependency `NO_DEFAULT_HANDLER`; no chooser/action. |
| Invalid input or direct-execution payload | Existing input error at original response path, no `kind`; this field does not act. |
| Missing/revoked client authority | `permission` / `capability`, before resource inspection. |
| Established OS-consent denial | `permission` / `os-permission`, never dependency absence. |
| Filesystem access denied without established consent cause | `failed`; do not infer absence or invent a consent. |
| Native error/false acknowledgment, timeout, or prerequisite lost after submission | `failed`; effects may have begun; no replay or alternate handler. |

After admission, validate/inspect an open-path target before resolving its
handler or named app. Native handler lookup can return nil for either a missing
file or missing handler; these must not be conflated. Recheck prerequisites on
each action, with no readiness cache. Dependency unavailable certifies that this
action submitted no domain request, not that preceding root actions did nothing.
Provider input checks do not turn whole-mutation authorization into transactional
input validation. Disconnection/cancellation after submission is not rollback;
transport outcome can be unknown even when the app opens successfully.

## Ownership, native design and alternatives

Workspace owns selection, path classification and submission behind a private
native adapter. The Machine core owns grants, preflight, live dispatch, deadlines
and publication. Helpers share no desktop reference registry. The existing
provider composition point enables controlled outcome tests; real independent
binaries and real apps supply native/VM evidence, without a new public test API.

The native design uses NSWorkspace launch/open with activation enabled,
new-instance creation and running-copy substitution disabled, printing/hiding
disabled, no supplied arguments/environment/custom Apple event, and ordinary
error/authentication prompting disabled. Retain normal recent-item behavior.
Reveal uses `selectFile(_:inFileViewerRootedAtPath:)` and its acknowledgment.
No AX, Automation script, input synthesis, shell or menu fallback is part of
these paths. Both grants remain necessary even when activation is not observed.

Apple documents [launch acknowledgment](https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:)),
[running-instance reuse](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/createsnewapplicationinstance),
[copy substitution](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/allowsrunningapplicationsubstitution),
and [Finder selection](https://developer.apple.com/documentation/appkit/nsworkspace/selectfile(_:infileviewerrootedatpath:)).
Its [prompt option](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/promptsuserifneeded)
does not suppress Gatekeeper. App onboarding, page UI or Gatekeeper may appear
after an explicit action. These references and SDK declarations support the
proposed call paths; they are not signed-VM acceptance.

No new entitlement, consent-acquisition route or certificate class is authorized.
Desktop control is client authority, not a requirement for Accessibility consent
on these operations. Verify launch/open/reveal with Accessibility absent/revoked.
Metadata/handler inspection must not request consent, enumerate directory
contents, or open protected contents to probe readiness. If the native mechanism
needs a new consent, settle its identifier, target and setup with Antony before
shipping; do not silently add Automation or Files and Folders. Denial without
that evidence remains `failed`. Existing response deadlines do not bound macOS
completion or undo an already submitted request.

Four operations keep browser, document, application and reveal semantics clearer
than a generic `open(target, options)` dispatcher exposing native options.
Compared with mandatory discovery references, bundle identity permits stopped-app
launch without a read grant. Optional registered-path constraints preserve a
search selection at the cost of an extra input and revalidation. A need for
pinned file identity, command execution or guaranteed foreground windows would
require another contract; none is inferred from these receipts.

## Packaging and compatibility

The first workspace bundle is release `1.0.0`, schema `1.0.0`, signing identifier
`dev.antony.Koine.provider.workspace`. Seal those exact values in the enabled
workspace catalogue entry. The existing desktop baseline declares release/schema
`1.0.0` and signing identifier `dev.antony.Koine.provider.desktop`; the catalogue
must match the actual packaged version, including any implementation-time change.
Assert identifiers from signed bundles, not only manifests. In-app approval uses
the verified host Team ID; per-user updates require their own approval records.
Keep input, menus, iterm and herdr reserved-only. Use distinct provider native
module/class names and the single host framework image. Test signing identifiers
belong only in purpose-built test catalogues.

Workspace manifest and descriptor declare `additional-capabilities-v1` and the
implementing framework minor; newly published first-party updates also declare
`first-party-selection-v1`. The implementation assigns that compatible minor.
The [entire selection matrix](machine.md#selection-acceptance) is part of this
increment, not optional follow-up. Follow its N/G/V assignment, fresh processes,
marker controls, signed catalogue fixtures, quarantine rules and exact diagnostics.

Extend `task conformance` for old-host core + desktop, extension-host core +
desktop, core + desktop + workspace, selected updates and explicit absent/rejected
sets. A required missing provider fails its profile. Pin actual candidate versions
separately from complete canonical SDL/digest equality. Additional management
metadata distinguishes old-host and extension-host profiles. Keep `koine-desktop/1`;
clients discover new coordinates by introspection. Baseline fields/errors/grants
retain their meaning. The [Machine desktop lookup](machine.md#public-graphql-contract)
still accepts only process identity; workspace supplies a new explicit launch
route that can return one.

## Acceptance

Use **G** public GraphQL and a contract-only client, **N** real independently
built native provider/host binaries, **V** signed isolated TestAnyware macOS VMs.
Every row remains pending; add evidence links when accepted. Native predictions
here are bounded questions for those seams, not a claim that implementation exists.

| Case | Seams | Required observation and preparation |
| --- | --- | --- |
| Twelve launchers, stopped and running | G, N, V | Install Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. Record actual IDs, versions and paths; launch/activate each, observe activation and any returned identity. No account-dependent app workflow is needed for this row. |
| Multiple copies | G, N, V | Registered fixture app at two locations: OS choice, exact constraint, another copy running, missing copy and identifier mismatch. No silent substitution. |
| Browser URL | G, N, V | Safari and alternate default Dia; encoded query/fragment and universal-link candidate; client suggestion failure still opens typed-query URL. No Koine Google request. Controlled N/G missing-handler outcome if safely absent handler cannot be prepared in V. |
| Documents/directories/settings | G, N, V | Temporary text file, directory and document package; default open and named Zed; config directory; missing file/parent/link/app/handler; inspection denial; literal spaces/punctuation and symlinks. No handler-setting changes. |
| Finder reveal | G, N, V | File, folder, app bundle and filesystem root; observe actual selection/root view in V. Missing path/Finder and false acknowledgment through controlled outcomes where necessary. Receipt alone does not establish selection. |
| Input boundary | G, N; V for native classification | Blank/malformed selector, relative/NUL paths, non-web schemes, credentials/control characters and prohibited direct-execution payloads including symlinks fail before submission. A script opens as a document in explicitly named Zed but cannot run through the default-script route. No executable/argv/environment/shell API; required app launch still works. |
| Receipt/failure boundary | G, N, V | Exclusive result branches; nullable process after successful acceptance; exact kernel instant accepted by desktop; process exit/reuse; error/deadline/disconnect after submission. No false no-effect claim or replay. Record limits instead of claiming atomic native targeting. |
| Authority/revocation | G, N, V | Neither capability alone works; both controls without reads suffice including receipts. Denial precedes inspection. Aliases/fragments/defaults/skips, multi-action preflight, revoke between actions, first unmet capability plus complete ordered set. V observes no denied launch/focus. |
| Consent and prompts | G, N, V | Accessibility absent/revoked, first protected-path inspection, app onboarding, quarantined app. Inspect actual call paths and prompt behavior. No implicit new consent/signing posture; known consent denial differs from filesystem failure and absence. |
| Packaging/selection | N, G, V as assigned | Complete Machine selection matrix, independent additional-capability old/new binaries, exact candidate and absent/rejected conformance. Mocks, SDL equality alone and old baseline evidence do not close these rows. |

GraphQL/client evidence must retain client ownership of query UI, suggestions,
fallback, chooser/MRU, clipboard and settings reload/relaunch. Reusable build,
fixture, conformance and VM recipes extend the existing Taskfile. Missing app
installations or certificates leave acceptance live; they are not passing absence
tests for the required working paths.
