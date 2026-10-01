# Workspace launch and open

**Designed; `workspaceLaunchApplication` is implemented and its L, G and N parts
are recorded under [Acceptance](#evidence-so-far), the other three roots and every
V part pending.** Workspace supplies the
launchers, browser opening, file/folder opening and Finder reveal required by
the [workflow inventory](../requirements/modaliser-workflows.md#workflow-inventory).
The [workflow spec](workflow-providers.md) owns the cumulative authority trace;
the [Machine contract](machine.md) owns authorization, errors and composition.
The [authority](../adr/provider-authority-follows-effects.md) and
[selection](../adr/first-party-provider-selection.md) decisions bind this design.
Nothing here claims that the released Koine 0.1.0 serves workspace.

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
A capability denial reports `requiredCapabilities` in the order
`["workspace:control", "desktop:control"]`, workspace's own capability first, and
`requiredCapability` names the first of them the grant lacks; the set is not
alphabetical and a client never sorts it.

| Coordinate | Input | Available value |
| --- | --- | --- |
| `Mutation.workspaceLaunchApplication` | Required `WorkspaceApplicationInput` | `WorkspaceOpenReceipt`: native launch-or-activate request accepted. |
| `Mutation.workspaceOpenURL` | Required absolute HTTP(S) URL string | `WorkspaceOpenReceipt`: URL submitted to the resolved default browser. |
| `Mutation.workspaceOpenPath` | Required absolute local path; optional `WorkspaceApplicationInput` | `WorkspaceOpenReceipt`: file/folder submitted to its default or named app. |
| `Mutation.workspaceRevealPath` | Required absolute local path | `WorkspaceRevealReceipt`: Finder reveal request acknowledged. |

`WorkspaceApplicationInput` contains a nonblank `bundleIdentifier: String!`
and optional `applicationPath: String`. The identifier names an installed app,
not a display name or process incarnation. Without a path constraint, Launch
Services chooses the installed copy at action time and may reuse a running copy
elsewhere. With a path, only a registered
application bundle at that file identity with the matching identifier is
eligible. Missing registration/bundle is `APPLICATION_NOT_INSTALLED`; an extant
bundle with a different identifier is `APPLICATION_IDENTITY_MISMATCH`. Neither
substitutes another copy. These are the only two reasons a launch reports, and a
missing constrained path is the former; `PATH_NOT_FOUND` and `NO_DEFAULT_HANDLER`
belong to the operations that open a path or a URL. A future search result can pass its identifier/path
without requiring a reference conversion. Registration is native discovery,
not Koine provider approval or an additional application allowlist. Installed
means registered and present as an application bundle when inspected. Check the
resolved bundle before submission, including unconstrained selection; unreadable
metadata is `failed`, not absence. A present registered bundle in the Trash
remains eligible: moving it there is not an uninstall in this contract. Use the
bounded [protected-path metadata route](../verification/protected-path-metadata.md#inspection-results)
for both constrained and unconstrained selection; do not substitute a prompting
file-URL handler lookup for bundle presence or identity. Do not
claim a missing registered copy is present merely because its registration remains.
The named-app selector requires a bundle identifier; bundle-less programs have
no selector route. This does not prevent a default handler without an identifier
from receiving a document. Search must expose this distinction when it is designed.

A running copy is reopened/activation is requested. Koine never requests a fresh
instance. Without `applicationPath`, running-copy substitution is enabled for
launch and named-app opening; with it, substitution is disabled. Application
search uses the constrained form when the user selected a particular installation,
even if another copy is running. The app
owns its reopen behavior: Koine does not promise a new window, restore every
minimized window, select one of several running instances, or keep the app
frontmost against other activity. Clients needing a specific window use desktop
discovery/focus afterward. Do not report `wasAlreadyRunning` from a racy precheck.

Paths are literal absolute paths on Koine's machine, not file URLs, globs,
tilde expansion or environment substitutions. Reject empty, relative and
NUL-containing paths, and a blank identifier (empty or whitespace alone), as input errors; spaces and shell punctuation remain
literal. Resolve symlinks for application-copy comparison and compare native
volume/file resource identity, not spelling, Unicode normalization or a path
prefix. Failure to establish identity is `failed`. Document paths are
location-based requests with normal symlink semantics, not pinned file identities.
An absent path/dangling link found before submission is `PATH_NOT_FOUND`.
Replacement or handler changes racing submission may fail or open a new
occupant. Search must not imply stronger identity than this contract.
The [native prompt boundary](../verification/protected-path-metadata.md#handler-lookup-limit)
applies before submission: successful metadata inspection does not establish
that default-handler lookup is prompt-free. Protected default-document opening
remains pending; named-app opening and reveal do not need that file-handler read.

Path opening submits a document/directory to an installed handler. Its refusal
policy is a metadata check, not proof that the contents cannot execute. After
resolving filesystem symlinks, refuse a target identified as an application
bundle by its native resource metadata, or with a content type conforming to
`com.apple.application-bundle`, `public.unix-executable` or
`com.microsoft.windows-executable`. Do not use the broad `public.executable` or
`public.script` ancestors, or executable permission bits, to reject ordinary
source documents. Unknown type alone does not prove executable content; failed
metadata inspection is `failed`. No content sniffing opens protected bytes.
Refuse native alias files (`com.apple.alias-file`) before handler resolution in
both forms; this API does not resolve Finder aliases or let them bypass the
application-payload check. Reveal can select the alias itself.

Source/script documents may be sent to their default handler or a named app,
including Zed. The chosen app owns the reaction: Terminal may execute a
`.command`/`.sh` or `.terminal` document; Jar Launcher may run a `.jar`.
Location documents (`.webloc`, `.inetloc`, `.url`, `.fileloc`) are ordinary
documents here, and their handler may follow a non-HTTP URL or a local target.
The HTTP(S) restriction applies to `workspaceOpenURL` input, not to links or
commands inside documents or pages. No content or handler sandbox is promised,
and a racing replacement can change the inspected payload before dispatch.
Document packages remain eligible unless classified as applications. Reveal
may select applications or executables without opening them. No operation
accepts an executable selector, argv, environment, custom Apple event or shell
command. Workspace control disclosure must state both this API boundary and
the application's unrestricted response to an authorized open/reopen request.

URL opening uses the ASCII `URI` grammar of
[RFC 3986 section 3](https://www.rfc-editor.org/rfc/rfc3986#section-3), including
its optional query and fragment, with an `http`/`https` scheme, nonempty host,
valid percent escapes, and no credentials, whitespace,
backslashes or control characters. Unicode paths/query text must arrive UTF-8
percent-encoded; internationalized hostnames must arrive as ASCII IDNA labels.
Do not trim, repair, normalize or silently percent-encode invalid input. Other
schemes, including `file`,
`javascript` and custom application schemes, are input errors. Preserve valid
path/query/fragment bytes. Resolve the default handler by the scheme alone,
never by passing the submitted URL to universal-link-aware handler discovery, and
submit explicitly to that app, avoiding universal-link dispatch to a native app.
Default changes after resolution do not retarget or replay this action.
Query entry, suggestions and typed-query fallback remain client-owned; Koine
does not construct searches or contact Google.

Omitted/null `application` on path opening selects the default handler. A named
app need not advertise every supported type: submit the normal open-document
request and classify native refusal as `failed`. Advertised types cannot prove
an app will accept a directory (Zed's required case). No chooser, installation,
default-handler modification or fallback to another app occurs. Client settings
uses the config directory and installed Zed; reload/relaunch remain client-owned.

## Results and failure boundary

The result's `status` is `AVAILABLE` or `DEPENDENCY_UNAVAILABLE`. Absent an error
at or below the result, exactly one of `value` and `dependency` is non-null,
selected by status. A published status remains authoritative if an error
suppresses its branch during publication; a null branch with an error is not a
different operation outcome. Non-null propagation can also remove status or
the entire result. Clients inspect both data and error paths. The dependency
object carries a closed reason enum and human guidance; it is not an execution
error. Validate this invariant at public GraphQL: nullable object members alone
cannot express it. Available means native acknowledgment, not that a document
finished rendering, a page loaded, or Finder selection was independently seen.
A null root always has an execution/input error for these four fields.

A client reports the action's outcome from `status` and the errors separately, and
never collapses them: `AVAILABLE` with an error below the result means the action
was acknowledged and part of the receipt was withheld, not that it did not happen.
A client that finds the invariant broken (a null root with no error, both branches
or neither, an unnamed status) reports `failed`, and a null root for these fields is
never absence.

`WorkspaceOpenReceipt` contains only optional `WorkspaceProcessIdentity`
(`pid`, `startedAt`), the bounded action handoff allowed by the Machine contract.
Installed paths, bundle identifiers and default-handler metadata remain read
data and are not returned in this control-only receipt.
`startedAt` has the exact desktop input semantics: the
kernel process start instant in UTC with six fractional second digits. Use it
only for the application returned by this action's completion callback. Retain
that native application object, require a positive stable PID and non-terminated
state, read the kernel start instant, compare the live process executable's file
identity with that object's executable, then read the start instant again.
The two kernel observations must match; a fresh native application lookup for
the PID must compare equal to the retained object, whose PID and non-terminated
state are checked again. Every unavailable value or mismatch yields null.
This is an observation rule, not atomic binding of the launch/open effect to a
process: replacement between observations and later exit remain possible.
Exit, ambiguity or unreadable start time produces `process: null`, never PID-only
identity or the current foreground process. The native application's launch date
is not a substitute for the exact kernel value. Later exit is always possible.

A null `process` after `AVAILABLE` is expected, not a failure: the action was
acknowledged and its application's identity is not known. A client that then needs
the application's windows locates the process by its own means, since desktop has no
lookup by bundle identifier, and proceeds as for any captured process.

The client copies a non-null identity into `desktopApplication(process:)` under
`desktop:read`, then uses returned desktop references unchanged. Workspace
imports no Desktop SDL type and issues no desktop reference. Absent process and
later reference withdrawal retain the desktop contract's null/error distinction.

`WorkspaceRevealReceipt.path` echoes the submitted path. Reveal uses Finder's
native selection operation with a boolean acknowledgment: false means `failed`.
It does not infer success from a void send or add AX, keystroke or menu checks.
A directory is selected in its parent; the filesystem root is shown as a root
view because it has no parent. Native acknowledgment is not selection verification.

| Condition after grant admission | Observable outcome |
| --- | --- |
| Application absent/unregistered, including missing constrained copy or Finder | Dependency `APPLICATION_NOT_INSTALLED`; guidance names the app; no action. |
| Constrained bundle has another identifier | Dependency `APPLICATION_IDENTITY_MISMATCH`; no substitution/action. |
| Path missing or dangling link | Dependency `PATH_NOT_FOUND`; no action. |
| Existing path or valid web URL has no default opener | Dependency `NO_DEFAULT_HANDLER`; no chooser/action. |
| Invalid input or refused payload metadata | Existing input error at original response path, no `kind`; this field does not act. |
| Missing/revoked client authority | `permission` / `capability`, before resource inspection. |
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
provider composition point enables core authorization/order and client result
handling tests. To test workspace's own mapping, construct the real workspace
provider with a substituted private native adapter in provider-local tests.
That enabling point controls lookup, acknowledgment, clock and observation
results; it is not a new public seam or evidence from a native binary/real app.
Real independent binaries and real apps supply the separate N/V evidence.

The native design uses NSWorkspace launch/open with activation enabled,
new-instance creation disabled, running-copy substitution enabled except for
an explicit application-path constraint, printing/hiding
disabled, no supplied arguments/environment/custom Apple event, and ordinary
error/authentication prompting disabled. Retain normal recent-item behavior.
Reveal uses `selectFile(_:inFileViewerRootedAtPath:)` and its acknowledgment.
No AX, Automation script, input synthesis, shell or menu fallback is part of
these paths. Both grants remain necessary even when activation is not observed.

Observe cold launch and reactivation of an already running app while another
app is frontmost and Koine is inactive. An acknowledgment alone does not pass
the launcher activation case. The existing client recovery route, when a receipt
has a process, is a separate `desktopApplication(process:)` read followed by an
explicit `desktopFocusWindow` on a returned window. It needs `desktop:read`,
desktop control and Accessibility consent under the existing desktop contract;
none is an implicit workspace prerequisite or an automatic server fallback.
If controls-only workspace launch does not meet activation acceptance, keep that
case pending and raise the measured limit with Antony. Do not silently require
client-side yield or weaken the launch-or-activate requirement.

Each native submission has a three-second acknowledgment wait bound. Provider
cancellation or that bound ends the resolver once, with `failed` at the action's
response path when the core can still publish it. Use an asynchronous one-shot
completion/timeout boundary, including Finder's boolean return: a late native
result is ignored and retains no resolver
or credential; never wait for a callback inside cancellation cleanup. Gatekeeper
or slow launch may continue after the caller receives `failed`, which means
effects may have begun. Do not retry. Three seconds is below the core's
five-second request ceiling but cannot replace it: earlier root actions,
preparation or scheduling may consume the request budget first. In that case
the existing whole-response deadline result still applies. Bound concurrent
native submissions and retained callback tokens; a timed-out native call still
counts while outstanding. Exhausted capacity refuses before submission with
`failed`. Do not promise to cancel the OS request or to
bound OS-owned UI/resources by ending the provider wait.

Apple documents [launch acknowledgment](https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:)),
[running-instance reuse](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/createsnewapplicationinstance),
[copy substitution](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/allowsrunningapplicationsubstitution),
and [Finder selection](https://developer.apple.com/documentation/appkit/nsworkspace/selectfile(_:infileviewerrootedatpath:)).
Its [prompt option](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/promptsuserifneeded)
does not suppress Gatekeeper. App onboarding, page UI or Gatekeeper may appear
after an explicit action and can delay its completion callback beyond the
provider wait. Normal launcher acceptance uses apps whose Gatekeeper approval
and first-run preparation were completed in the VM; a separate quarantined-app
case leaves the dialog pending past the bound, checks `failed`, then checks
that a late callback cannot publish again. Record completion latency for each
launcher. These references and SDK declarations support the
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

The [protected-path native evidence](../verification/protected-path-metadata.md)
limits this design's inspection premise: the tested metadata and registered-app
route was prompt-free on first-use Desktop, Documents and Downloads; file-URL
default-handler lookup prompted for documents on all three. A returned handler
after denying that dialog does not satisfy prompt-free inspection. Launch's
installation presence/identity checks, named-app path opening and reveal may use
the recorded metadata route; they gain no general permission to inspect contents.
Default opening of protected documents remains pending a human decision about
consent or handler semantics. Search must not use that file-URL lookup as a
prompt-free read. No new consent identifier, entitlement or setup route is
authorized. Unavailable removable/network-volume observations remain unknown.
This is bounded platform evidence, not acceptance of the workspace operations.

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
implementing framework minor, which is 1 (`minimumMinor: 1`); newly published
first-party updates also declare `first-party-selection-v1`.
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
**L** below is a supporting provider-local test: instantiate the real workspace
provider with its private native adapter substituted. It proves workspace's
classification, not an OS outcome or the independently built binary seam.
Composition-point fakes can separately prove core/client result handling at G.
Every row remains pending; add evidence links when accepted. Native predictions
here are bounded questions for those seams, not a claim that implementation exists.

| Case | Seams | Required observation and preparation |
| --- | --- | --- |
| Twelve launchers, stopped and running | G, N, V | Install Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. Complete first-run/Gatekeeper preparation separately; record actual IDs, versions, paths and callback latency. Cold-launch each and reactivate it with another app frontmost and Koine inactive; observe activation and any returned identity. Acknowledgment without activation does not pass. Exercise the optional desktop handoff separately; a controls-only activation failure stays pending for escalation. No account-dependent workflow is needed. |
| Multiple copies and installation | G, N, V; L for inspection failures | Registered fixture at two locations: unconstrained launch/named-app open reuses a running copy elsewhere; a path constraint addresses exactly the chosen copy. Check missing/unregistered copy, stale registration after deletion, identifier mismatch and a still-registered present copy in Trash (eligible). Check symlink/Unicode path spellings by native file identity and metadata denial as failed. Bundle-less programs have no named-selector route; default handler use remains distinct. |
| Browser URL | G, N, V; L for absent handler | Safari and alternate default Dia; encoded query/fragment, IDNA host and universal-link candidate; inspect scheme-only handler discovery. Invalid escapes/raw Unicode/whitespace/backslashes are refused without repair. Client suggestion failure still opens typed-query URL. No Koine Google request. A controlled absent-handler adapter result proves workspace mapping at L; G fakes prove client handling only. |
| Documents/directories/settings | G, N, V | Temporary text file, directory and document package; default open and named Zed; config directory; missing file/parent/link/app/handler; inspection denial; literal spaces/punctuation and symlinks. No handler-setting changes. |
| Finder reveal | G, N, V; L for unavailable Finder/false acknowledgment | File, folder, app bundle, alias and filesystem root; observe actual selection/root view in V. L runs real workspace mapping for missing Finder and false acknowledgment; G fakes cover client handling only. Receipt alone does not establish selection. |
| Input boundary | G, N, V; L for type/race cases | Blank selector, relative/NUL paths, non-web schemes, credentials/control characters and recognized app/native-executable payloads including symlinks fail before submission. A source script opens in its default editor and explicitly named Zed, irrespective of executable bits; do not reject JavaScript merely for public.executable conformance. Finder aliases to documents/apps are refused before dispatch. In disposable V fixtures, observe Terminal/script and location-document reactions as disclosed, without claiming a sandbox. L varies metadata and replacement outcomes. No executable/argv/environment/shell API; required app launch still works. |
| Receipt/failure boundary | G, N, V; L for deterministic observations | Error-free exclusive branches; publication denial/revocation at status, value and nested process fields with correct partial data/error paths. Receipts contain no installed path/identifier/handler metadata. Nullable process after acknowledgment; exact kernel instant accepted by desktop. L checks different start samples, executable mismatch, terminated/equal-object checks and unavailable values; inspect the rule for PID reuse rather than claim V induces it. V observes real exit and matching kernel identity. No atomic effect-binding claim. |
| Bounded acknowledgment | L, G, N, V | L controls callback before/after three seconds, no callback, cancellation, one-shot completion and bounded outstanding submissions; G checks action-path failure versus the earlier core deadline in multi-action requests. N/V record real completion timing. V holds Gatekeeper open past the bound, confirms failed without replay, then dismisses it and verifies no late result. Slow launch is an expected ambiguous failed outcome, never dependency absence or a passing normal-launch case. |
| Authority/revocation and disclosure | G, N, V | Neither capability alone works; both controls without reads suffice including receipts. Denial precedes inspection. Aliases/fragments/defaults/skips, multi-action preflight, revoke between actions, first unmet capability plus complete ordered set. V observes no denied launch/focus. Before workspace ships, check native create/approve and existing-grant views plus GraphQL descriptions disclose any registered installed app, document execution/redirects by handlers, and both required controls. |
| Consent and prompts | G, N, V | [First-use metadata probe](../verification/protected-path-metadata.md): tested metadata calls were prompt-free; document file-URL default-handler lookup prompted on Desktop, Documents and Downloads. Protected default opening and handler discovery remain pending for a human consent/semantics decision. Removable/network-volume observations were unavailable. Operation acceptance still checks Accessibility absent/revoked, app onboarding and the separate Gatekeeper timeout case. No new consent/signing posture is implied; inspection denial remains failed, not absence or an invented os-permission. |
| Packaging/selection | N, G, V as assigned | Complete Machine selection matrix, independent additional-capability old/new binaries, exact candidate and absent/rejected conformance. Mocks, SDL equality alone and old baseline evidence do not close these rows. |

GraphQL/client evidence must retain client ownership of query UI, suggestions,
fallback, chooser/MRU, clipboard and settings reload/relaunch. Reusable build,
fixture, conformance and VM recipes extend the existing Taskfile. Missing app
installations or certificates leave acceptance live; they are not passing absence
tests for the required working paths.

### Evidence so far

`workspace-launch` shipped the bundled provider serving `workspaceLaunchApplication`
and the types it reaches, verbatim from the design file. The other three roots
and their types are not served until their leaves land. What follows is exactly
what was established; every row above keeps its pending remainder.

- **Twelve launchers, stopped and running.** V for **all twelve**
  ([launchers-vm.md](../verification/launchers-vm.md)), in a clone of the prepared image
  ([launcher-apps-vm.md](../verification/launcher-apps-vm.md)): each of Dia, ChatGPT,
  Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and
  Zotero cold-launched and reactivated by the contract-only client under
  `workspace:control` and `desktop:control` alone, with another application in front and
  Koine inactive; the witness saw each activated, one instance, a receipt equal to the
  kernel's identity, and the reactivation reuse the process. Identifiers, versions, paths
  and callback latency (102-319 ms cold, 33-87 ms reactivation) are recorded. Controls-only
  activation met the requirement for every launcher, so nothing goes to Antony. Earlier,
  Notes alone in [launch-vm.md](../verification/launch-vm.md). Not installed and
  installed-then-deleted report `APPLICATION_NOT_INSTALLED`. Pending: G and N for the real
  installations (`application-installations` for multiple copies).
- **Multiple copies and installation.** L (`SelectionTests`): absent and unregistered
  identifiers, a registration whose bundle is gone, a present copy in the Trash
  (eligible), identifier mismatch with nothing substituted, a chosen copy matched by
  file identity (another spelling matches; another volume does not), a present but
  unregistered copy, an unreadable candidate as `failed`. Running-copy reuse is
  carried as the submitted substitution flag. N (`WorkspaceProviderTests`): the real
  adapter answers an absent identifier, absent constrained paths and a real system
  bundle with another identifier, submitting nothing. Pending: real symlink and
  Unicode spellings, deletion after registration, a real second copy, running-copy
  reuse (V), and `application-installations`.
- **Input boundary.** L and N: a blank identifier and an empty, relative or
  NUL-containing application path are input errors at the original path with no
  `kind`, before any inspection. The other operations' inputs have not landed.
- **Receipt/failure boundary.** G (`WorkspaceCompositionTests`): error-free
  exclusive branches; publication denial at the status, value, process,
  non-null process fields and both dependency fields, with the partial data and
  error paths each leaves; an absent process as null. L (`ObservationTests`): every
  step of the observation rule, one mismatch at a time, and the fifth step's
  bounded settle. V ([launch-vm.md](../verification/launch-vm.md)): the receipt's
  `{pid, startedAt}` equals the kernel's reading by an independent witness,
  `desktopApplication(process:)` accepts it unchanged under `desktop:read`, and
  after the process's real exit answers null. The V run found the process null on
  most cold launches, a race in the fresh lookup's equality, and the settle is its
  fix. Publication denial and revocation at the fields are G's; no atomic
  effect-binding is claimed.
- **Bounded acknowledgment.** L (`LaunchTests`): a negative acknowledgment, a
  missing callback and a late callback (ignored, and releasing its slot exactly
  once), cancellation before and during the wait, one-shot completion, exhausted
  capacity refused before submission and restored by a callback. G: an action's
  own `failed` at its path with later actions still running, against an earlier
  core deadline that answers the whole request and starts no later action. V
  ([launch-vm.md](../verification/launch-vm.md)): real completion timing of one
  application, cold and reactivation, well inside the bound; and
  ([launchers-vm.md](../verification/launchers-vm.md)) all twelve inside it, then a
  quarantined, never-opened application whose Gatekeeper dialog was held open past the
  bound: the answer came at the bound (about 3.2 s), `failed` with effect
  `may-have-begun`, no process, never dependency absence, the request sent once and the
  dialog still the only one ten seconds on. Declined, nothing launched; accepted, exactly
  the one original launch and no second; no result was published after the answer and the
  next request was served normally. Pending: N.
- **Authority/revocation.** G and N (through the real signed bundle): neither
  control alone, and neither read, is enough; both controls without reads reach the
  provider; denial precedes inspection; the first unmet member and the complete set;
  multi-action preflight, aliases and `@skip`, revocation between actions. V
  ([launch-vm.md](../verification/launch-vm.md)): both controls with no read
  capability launch and reactivate; either control alone (HTTP 403 at
  authorization, the first unmet member and the complete set named), `desktop:read`
  alone and a revoked grant (401) launch nothing and move no focus, with the
  application stopped and running. Pending: disclosure (`workspace-disclosure`).
- **Consent and prompts.** The real adapter inspects only through the calls
  the [probe](../verification/protected-path-metadata.md#inspection-results) measured
  prompt-free, and never asks for a file's default handler. V
  ([launch-vm.md](../verification/launch-vm.md)): with Accessibility absent, and
  again after it was given and revoked, launch and reactivation work and no consent
  dialog appears; Notes' first run and Gatekeeper approval are recorded. V
  ([launchers-vm.md](../verification/launchers-vm.md)): none of the twelve launchers
  raised Gatekeeper's dialog or a consent of Koine's from a Koine launch in an
  enforcing image; Kimi's own local-network request, which it raises on some launches,
  is its onboarding, recorded and declined. The Gatekeeper timeout case is closed (see
  Bounded acknowledgment).
- **A client from the documented contract alone.** G and V
  ([launch-contract.md](../verification/launch-contract.md)): `clients/contract-only`,
  regenerated from the signed build's served introspection and written from the
  published documents, enrols its own grants, introspects the schema it was generated
  against (digest equal), launches Notes cold and reactivates it with another
  application in front (activation and the kernel identity observed by an
  independent witness), and tells apart a dependency that is unavailable, a
  capability denial with the complete required set, a `failed` launch and an absent
  process. Every place it had to guess is repaired in the documents or declined for
  version 1 ([launch-contract-client-findings.md](../verification/launch-contract-client-findings.md)).
  Pending: the other operations' examples, which are not served yet.
- **Packaging/selection.** N: the signed bundle, built by its own definition and
  linking only the host framework, loads from the in-application root beside
  desktop through the selection-aware loader, `ACTIVE` and `SELECTED` at
  `1.0.0`/`1.0.0`. `task check:provider-catalogue` holds the catalogue's workspace
  entry to the signed packaged bundle. Conformance: `task conformance` holds three
  profiles to the schemas their hosts serve, each after its design and pin controls
  were seen red, with the candidates pinned apart from the SDL and the digest —
  old-host core + desktop against the released host, extension-host core + desktop
  against this tree's headless host, and core + desktop + workspace, with desktop and
  workspace `1.0.0`/`1.0.0` both bundled, against the signed application in a VM, its
  design SDL the workspace design restricted to the implemented roots and the types
  they reach, verbatim ([schema-conformance-vm.md](../verification/schema-conformance-vm.md),
  [launch-contract.md](../verification/launch-contract.md)). A missing required
  provider or coordinate fails. Pending: the complete selection matrix
  (`selection-acceptance`), old/new binaries with this provider, and selected
  updates and explicit absent/rejected sets in conformance.

