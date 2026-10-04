# Workspace launch and open

**Designed; all four roots, `workspaceLaunchApplication`, `workspaceOpenURL`, `workspaceOpenPath`
and `workspaceRevealPath`, are implemented and their L, G and N parts, and the V parts of the URL,
path and reveal roots, the multiple-copies row and the grant disclosure, are recorded under [Acceptance](#evidence-so-far); pending are one part of
the URL root's V evidence, Dia's page load (below), default opening of protected documents (see
[Documents and directories](#evidence-so-far)), and a decision on the system notice that revealing a
third-party application raised (see [Finder reveal](#evidence-so-far)).** Workspace supplies the
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

The designed [application/file search extension](workspace-search.md) feeds these
same inputs: a selected installed application supplies both identifier and
installation path; a file supplies its literal path. Search does not issue a
reference, resolve a default handler, write the clipboard or weaken action-time
revalidation. Its standalone SDL remains separate pending design review repair.
Implementation adds an exact search-required profile for the search-serving
host. The unchanged action-only SDL and workspace 1.0.0/schema 1.0.0 pins run
against a separate compatibility host containing that independently retained
bundle; they do not describe the upgraded bundled search provider.

The [long-location action boundary](#long-location-action-boundary) identifies
an additional unimplemented correction: native size and unresolved-link failures
must not report an extant location missing. A replacement long-location metadata,
classification and submission route is still required; source/SDK analysis alone
does not complete that design or extend the short-path acceptance above.

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
belong to the operations that open a path or a URL; `workspaceOpenURL` reports `NO_DEFAULT_HANDLER` and no other reason. A future search result can pass its identifier/path
without requiring a reference conversion. Registration is native discovery,
not Koine provider approval or an additional application allowlist. Installed
means registered and present as an application bundle when inspected. Check the
resolved bundle before submission, including unconstrained selection; unreadable
metadata is `failed`, not absence. A present registered bundle in the Trash
remains eligible: moving it there is not an uninstall in this contract. (Launch Services does not keep
the registration: see [Multiple copies and installation](#evidence-so-far).) Use the
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
source documents. The content type decides, not the permission bits: a document
with a typed extension (`.sh`, `.js`, `.py`, `.command`) is not refused whatever its
bits, and an extensionless file whose executable bit is set has the type
`public.unix-executable` and is refused as a program. Unknown type alone does not prove executable content; failed
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
| Invalid input or refused payload metadata | Existing input error at original response path, no `kind`; this field does not act. The path is the root field's own, its alias if one was used (`["workspaceOpenURL"]`), an execution error in an HTTP 200 answer. |
| Missing client authority | `permission` / `capability`, before resource inspection. A revoked or unknown credential never reaches admission: it is HTTP 401 (`unauthenticated`). |
| Filesystem access denied without established consent cause | `failed`; do not infer absence or invent a consent. |
| Whole/expanded native path-size refusal, unresolved link-budget exhaustion, or unacquired/malformed prerequisite facts | Designed repair: pre-submission `failed`; guidance names stage/cause and no domain request was submitted. Bare ELOOP/ENAMETOOLONG or higher-level nil/no-such-file cannot establish dependency absence. |
| Native error/false acknowledgment, timeout, or prerequisite lost after submission | `failed`; effects may have begun; no replay or alternate handler. |

After admission, validate/inspect an open-path target before resolving its
handler or named app. Native handler lookup can return nil for either a missing
file or missing handler; these must not be conflated. Recheck prerequisites on
each action, with no readiness cache. Dependency unavailable certifies that this
action submitted no domain request, not that preceding root actions did nothing.
Provider input checks do not turn whole-mutation authorization into transactional
input validation. Disconnection/cancellation after submission is not rollback;
transport outcome can be unknown even when the app opens successfully.

### Long-location action boundary

Search returns locations through 8,192 UTF-8 bytes. That is a discovery value
ceiling, not a new action input bound or a guarantee of native actionability.
Action paths retain their existing literal absolute-path syntax. Distinguish
supplied text, symlink-expanded/native spelling, native classification, file-URL
default-handler discovery, the registered application's submission spelling,
and receipt executable-identity observation. Launch/named open submits the
registered URL selected by native identity; it need not have the same spelling
or length as applicationPath. Document/reveal target bytes remain the caller's.
Neither source length nor a successful controlled adapter result proves the
later stages can act.

The selected error repair is **designed and unimplemented**. Whole/expanded
native path-size refusal and unresolved finite-link-budget exhaustion mean
failed inspection, never PATH_NOT_FOUND or APPLICATION_NOT_INSTALLED. Preserve
PATH_NOT_FOUND for an established unresolvable cycle or a component established
to exceed the relevant filesystem's name limit, as for the accepted short
two-link-cycle and 300-byte-component subjects. ELOOP alone does not prove a
cycle; ENAMETOOLONG alone does not prove an impossible component. Missing/below-file
results establish a dependency only when the relevant lookup resolved that
component/spelling. A higher-level no-such-file wrapper without established
operation/cause is insufficient. Preserve stage/cause in human guidance without
adding an error kind or dependency enum. Pre-submission uncertainty causes no
domain request; post-submission failure retains possible effects and no replay.

Completed native facts and unacquired facts have distinct inspection outcomes.
An applicable supported acquisition that successfully reports no content type,
with required application/alias flags established, retains the accepted no-type
non-refusal. An established absent Info.plist or successful native bundle-information
report with no declared identifier retains APPLICATION_IDENTITY_MISMATCH for a
named selector; an identifier-free default handler remains eligible. Missing
required flags/identity, observed read/parse failure or unsupported acquisition
means failed. Nil alone cannot stand for failed acquisition, nor can it default
required flags to false. The [fact-provenance rules](../verification/long-action-native-boundary.md#fact-provenance-and-established-nils)
require the route to establish these meanings without guessed metadata or new
content reads. Known long program/application/alias subjects must still be refused.

A supported file-URL handler lookup must establish its applicability and a
native no-handler report for the exact target before NO_DEFAULT_HANDLER is
justified. The existing URL-or-nil adapter supplies no error cause; presence
alone does not establish long-URL lookup support. Unestablished handler acquisition
is failed. First-use long-file/directory lookup has independent prompt subjects.
Do not substitute a generic type/extension handler or approve new consent.

Inspection of a registered long copy must not regress short constrained or
unconstrained launch/named open, or Finder readiness for reveal. Unknown candidate
equality remains failed, never a skippable unrelated copy. The route must repair
inspection while retaining exact selection. Receipt observation separately checks
callback and live executable identity, including proc_pidpath and resource-value
path consumers. Record long-app process/null causes; systematic length-caused null
is a defect to repair or an explicit Antony decision, not silently accepted loss.

The existing whole-path metadata route does not support claiming this handoff
complete. Component-relative lookup and canonical path observation are candidate
building blocks, not substitutes for native application/alias/type classification,
bundle identity/identifier or registration checks. A public supported route for
all those prerequisites and the unchanged selected location still needs design
and mandatory review. The [source and SDK analysis](../verification/long-action-native-boundary.md)
records current limitations, candidate API boundaries and independent subjects;
it selects no private policy or deprecated conversion as a repair.

The [returned route evaluation](../verification/long-action-route.md#measured-reconciliation)
consumes the finite prototype, prior-art survey and completed application synthesis. Relative filesystem
operations reached the long items; the tested public native-fact, registration,
handler and submission routes did not complete the retained working subjects.
Exact witness delivery at 1,023 bytes and failure at 1,024 establish a bounded
submission result, not universal impossibility or action acceptance. A nil
long default-handler lookup establishes neither no handler nor default submission.
Directory handles/component lists do not supply the missing opener interface.
Antony [retained the original requirement](../verification/long-action-route.md#decision-for-antony).
Both application surveys and their synthesis are complete; the
[returned disposition](../verification/long-action-route.md#application-research-reconciliation)
separates local access, opener delivery and real receiver access. Zed's inspected
backend still reads by whole path after IPC. Public legacy FSRef item arrays
exist, but a complete long acquisition/submission route and full contract parity
remain unestablished. The authorized
[internal diagnostic result](../verification/long-action-route.md#native-reference-result-and-remaining-gap)
returns exact-name references at 1,024 bytes, rejected by tested catalog/fact/
handler/directory consumers, and cannot reach the 1,500-byte subjects. Antony
accepted that result. The two item-array openers remain unmeasured; the
[finite diagnostic](../verification/long-action-route.md#proposed-item-array-submission-diagnostic)
was authorized on 2026-10-05 for one prototype and retained returned design.
No new native action outcome is established. Node resolution requires native catalog provenance.
External inquiries remain unused drafts. No automatic probe series is authorized. The refusal proposal remains unadopted; all
working cases and exclusions bind.
Keep the supported route, final review and planning obligations live. No route,
new read posture, version change or workflow limitation is adopted.

Retain workspace and desktop controls, prompt-free reads, payload refusals,
exact installation constraints, handler semantics, cancellation and acknowledgment
bounds. Never clip/rewrite a location, remove applicationPath or retry another
copy. Protected default-document opening and the third-party reveal notice remain
their existing decisions. Do not accept a shorter domain, disabled action or
copy-only workflow in place of the required long-file and constrained-app cases.

L uses the existing private action adapter to check planner responses to supplied
outcomes; it does not exercise the errno/Foundation/plist classifier inside the
substituted adapter. N component-created host fixtures exercise that real mapping,
G checks the public contract, independently retained old/new binaries check
compatibility, and V checks signed isolated macOS behavior.

Launch-and-open planning owns independently constructed action fixtures: a
roughly 1,500-byte ordinary file opened by its default handler and Zed and revealed
in Finder, and a long registered application cold/warm launched and used for named
open with identifier and path while another copy runs. App-and-file-search
planning/acceptance owns the additional actual-search G/N/V handoff: search returns
those locations, then unchanged selected values drive the same actions. No injected
search result closes that later row. Search design consumes the reviewed route;
search acceptance consumes the accepted action provider, avoiding a circular
implementation dependency. Both sets of working subjects remain required.
Observe delivery/selection/copy/process independently, first positively controlling
each long-path observer through a non-Koine route. Observer limits and
construction/registration/earlier-stage failure leave their subjects pending;
neither acknowledgment nor old short-path evidence closes them.

The compatible action-only correction is workspace release/schema **1.0.1** under
`koine-desktop/1`, preserving accepted concrete short-cycle/name-limit/established-nil
outcomes, input/result shapes and error kinds. Its
[repair SDL](../design/workspace-action-repair-schema.graphql) supplies exact changed
launch/open/reveal descriptions. On the same host/printer these canonical description
changes must change the composed digest; the numeric digest and full exact-candidate
profiles are captured from actual implementation. Keep independently retained 1.0.0
bundle/SDL/profile unchanged. Search release/schema 1.1.0 incorporates the repaired
descriptions in its separate composed profile. Planning owns the
[implementation/compatibility obligations](../verification/long-action-native-boundary.md#compatibility-and-implementation-obligations).
Any unavoidable incompatible meaning, short-workflow loss or systematic long-app
null receipt goes to Antony before adoption. Measured workflow omissions still
feed the existing operator decision before baseline acceptance.

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
provider with its private native adapter substituted. It proves planner mapping
from supplied inspection outcomes, not the real adapter's errno/Foundation/plist
classification, an OS outcome or the independently built binary seam.
Composition-point fakes can separately prove core/client result handling at G.
Every row remains pending; add evidence links when accepted. Native predictions
here are bounded questions for those seams, not a claim that implementation exists.

| Case | Seams | Required observation and preparation |
| --- | --- | --- |
| Twelve launchers, stopped and running | G, N, V | Install Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero. Complete first-run/Gatekeeper preparation separately; record actual IDs, versions, paths and callback latency. Cold-launch each and reactivate it with another app frontmost and Koine inactive; observe activation and any returned identity. Acknowledgment without activation does not pass. Exercise the optional desktop handoff separately; a controls-only activation failure stays pending for escalation. No account-dependent workflow is needed. |
| Multiple copies and installation | G, N, V; L for inspection failures | Registered fixture at two locations: unconstrained launch/named-app open reuses a running copy elsewhere; a path constraint addresses exactly the chosen copy. Check missing/unregistered copy, stale registration after deletion, identifier mismatch and a still-registered present copy in Trash (eligible). Check symlink/Unicode path spellings by native file identity and metadata denial as failed. Bundle-less programs have no named-selector route; default handler use remains distinct. V: [application-installations-vm.md](../verification/application-installations-vm.md). |
| Browser URL | G, N, V; L for absent handler | Safari and alternate default Dia; encoded query/fragment, IDNA host and universal-link candidate; inspect scheme-only handler discovery. Invalid escapes/raw Unicode/whitespace/backslashes are refused without repair. Client suggestion failure (refused, timed out or unreadable) still opens the typed-query URL, once: the fallback is chosen before the single open, never a second open after a failed one. No Koine Google request. A controlled absent-handler adapter result proves workspace mapping at L; G fakes prove client handling only. V: [open-url-vm.md](../verification/open-url-vm.md). |
| Documents/directories/settings | G, N, V | Temporary text file, directory and document package; default open and named Zed; config directory; missing file/parent/link/app/handler; inspection denial; literal spaces/punctuation and symlinks. No handler-setting changes. V: [open-path-vm.md](../verification/open-path-vm.md). |
| Finder reveal | G, N, V; L for unavailable Finder/false acknowledgment | File, folder, app bundle, alias and filesystem root; observe actual selection/root view in V. L runs real workspace mapping for missing Finder and false acknowledgment; G fakes cover client handling only. Receipt alone does not establish selection. V: [reveal-path-vm.md](../verification/reveal-path-vm.md). |
| Input boundary | G, N, V; L for type/race cases | Blank selector, relative/NUL paths, non-web schemes, credentials/control characters and recognized app/native-executable payloads including symlinks fail before submission. A source script with a typed extension opens in its default editor and explicitly named Zed, irrespective of executable bits (an extensionless file with the bit set is a program by type and is refused); do not reject JavaScript merely for public.executable conformance. Finder aliases to documents/apps are refused before dispatch. In disposable V fixtures, observe Terminal/script and location-document reactions as disclosed, without claiming a sandbox. L varies metadata and replacement outcomes. No executable/argv/environment/shell API; required app launch still works. URL input at V: [open-url-vm.md](../verification/open-url-vm.md#refused-inputs-and-denied-grants); path input at V: [open-path-vm.md](../verification/open-path-vm.md#refused-inputs-dependencies-and-denied-grants); reveal input at V: [reveal-path-vm.md](../verification/reveal-path-vm.md#refused-inputs-dependencies-and-denied-grants). |
| Receipt/failure boundary | G, N, V; L for deterministic observations | Error-free exclusive branches; publication denial/revocation at status, value and nested process fields with correct partial data/error paths. Receipts contain no installed path/identifier/handler metadata. Nullable process after acknowledgment; exact kernel instant accepted by desktop. L checks different start samples, executable mismatch, terminated/equal-object checks and unavailable values; inspect the rule for PID reuse rather than claim V induces it. V observes real exit and matching kernel identity. No atomic effect-binding claim. URL receipts at V: [open-url-vm.md](../verification/open-url-vm.md#opening-in-each-browser); path receipts at V: [open-path-vm.md](../verification/open-path-vm.md#opening-in-the-default-handler-and-in-zed); reveal receipts at V: [reveal-path-vm.md](../verification/reveal-path-vm.md#revealing). |
| Bounded acknowledgment | L, G, N, V | L controls callback before/after three seconds, no callback, cancellation, one-shot completion and bounded outstanding submissions; G checks action-path failure versus the earlier core deadline in multi-action requests. N/V record real completion timing. V holds Gatekeeper open past the bound, confirms failed without replay, then dismisses it and verifies no late result. Slow launch is an expected ambiguous failed outcome, never dependency absence or a passing normal-launch case. URL answer times at V: [open-url-vm.md](../verification/open-url-vm.md#opening-in-each-browser); path answer times at V: [open-path-vm.md](../verification/open-path-vm.md#opening-in-the-default-handler-and-in-zed). |
| Authority/revocation and disclosure | G, N, V | Neither capability alone works; both controls without reads suffice including receipts. Denial precedes inspection. Aliases/fragments/defaults/skips, multi-action preflight, revoke between actions, first unmet capability plus complete ordered set. V observes no denied launch/focus (URL: [open-url-vm.md](../verification/open-url-vm.md#refused-inputs-and-denied-grants); path: [open-path-vm.md](../verification/open-path-vm.md#refused-inputs-dependencies-and-denied-grants); reveal: [reveal-path-vm.md](../verification/reveal-path-vm.md#refused-inputs-dependencies-and-denied-grants)). Native create, approve and existing-grant views plus GraphQL descriptions disclose any registered installed app, document execution/redirects by handlers, and both required controls, observed in the window and compared with the text management serves: [workspace-disclosure-vm.md](../verification/workspace-disclosure-vm.md). |
| Consent and prompts | G, N, V | [First-use metadata probe](../verification/protected-path-metadata.md): tested metadata calls were prompt-free; document file-URL default-handler lookup prompted on Desktop, Documents and Downloads. Protected default opening and handler discovery remain pending for a human consent/semantics decision. Removable/network-volume observations were unavailable. Operation acceptance still checks Accessibility absent/revoked, app onboarding and the separate Gatekeeper timeout case (URL, Accessibility absent: [open-url-vm.md](../verification/open-url-vm.md#accessibility-and-consent); path: [open-path-vm.md](../verification/open-path-vm.md#accessibility-and-consent); reveal: [reveal-path-vm.md](../verification/reveal-path-vm.md#accessibility-and-consent), which also records a system notice naming Koine that revealing a third-party application raised, [pending a decision](../verification/reveal-path-vm.md#the-app-management-notice)). No new consent/signing posture is implied; inspection denial remains failed, not absence or an invented os-permission. |
| Packaging/selection | N, G, V as assigned | Complete Machine selection matrix, independent additional-capability old/new binaries, exact candidate and absent/rejected conformance. Mocks, SDL equality alone and old baseline evidence do not close these rows. |
| Long-location actions, independent of search | L, G, N, V; launch-and-open owns | Execute the [independent action subjects](../verification/long-action-native-boundary.md#independent-subjects-for-the-route-design) after reviewed route implementation: roughly 1,500-byte default/Zed open and reveal, long constrained cold/warm launch/named open, real stage/cause/nil classification, registered spelling and receipt observation, short-workflow regression with long registered candidates, handler prompting, positive observer controls and separate 1.0.0/1.0.1 binary profiles. All remain pending; no actual search implementation is required to close action fixtures. |
| Actual long search-result handoff | G, N, V; app-and-file-search owns | Actual search returns the long file/application; unchanged selected path and identifier drive the accepted actions with independent delivery/selection/copy/process witnesses. [Search acceptance](workspace-search.md#test-seams-and-acceptance) retains this additional provenance requirement. Independent fixtures, injected results or action acceptance cannot close it. |

GraphQL/client evidence must retain client ownership of query UI, suggestions,
fallback, chooser/MRU, clipboard and settings reload/relaunch. Reusable build,
fixture, conformance and VM recipes extend the existing Taskfile. Missing app
installations or certificates leave acceptance live; they are not passing absence
tests for the required working paths.

### Evidence so far

The following records describe the retained action-only 1.0.0 baseline and its
actual short-path subjects. Its broad ELOOP/ENAMETOOLONG mapping is historical
behavior, not the repaired-provider rule. The concrete cycle/impossible-component
outcomes stay required, but 1.0.1 must establish their causes and rerun them with
all established-nil and short-workflow regressions. These records and original
client findings are preserved; none is an action-repair or long-location pass.

`workspace-launch` shipped the bundled provider serving `workspaceLaunchApplication`
and the types it reaches, verbatim from the design file, `open-url` added
`workspaceOpenURL`, `open-path` added `workspaceOpenPath` (each its two lines,
verbatim; neither reaches a new type) and `reveal-path` added `workspaceRevealPath` with
`WorkspaceRevealResult` and `WorkspaceRevealReceipt`, the last root, so the bundle now serves
the complete workspace design verbatim. What follows is exactly
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
- **Multiple copies and installation.** L, G, N and V ([application-installations-vm.md](../verification/application-installations-vm.md)).
  L (`SelectionTests`, `OpenPathTests`): absent and unregistered identifiers, a registration whose
  bundle is gone, a present copy in the Trash (eligible, whether Launch Services reports it through the
  lookup by identifier or through the list of every copy), identifier mismatch with nothing substituted,
  a chosen copy matched by file identity (another spelling matches; another volume does not), several
  registered copies each addressed by their own identity, a present but unregistered copy, an unreadable
  candidate and an unreadable chosen path as `failed`, a bundle-less program never selected, a bundle
  that declares no identifier a mismatch and a default handler that declares none still receiving a
  document. Running-copy reuse is carried as the submitted substitution flag. G
  (`WorkspaceInstallationsCompositionTests`, the real provider over a stand-in with two installed
  copies, the installation a GraphQL variable): the unconstrained form submits Launch Services' copy
  with substitution allowed and a path submits exactly that copy with it forbidden, for a launch and a
  named open, and each dependency and a `failed` reach the client with nothing submitted. N
  (`WorkspaceProviderTests`, the signed bundle, nothing opened): the real adapter resolves a link to a
  bundle, a link to its folder and a decomposed spelling of a name by the bundle itself, a Mach-O
  program is not installed, a bundle with no Info.plist is a mismatch, and a bundle whose contents
  cannot be read, and a path inside an unreadable folder, are `failed`. V, in the prepared image with
  a fixture application ([InstallationFixture](../../Fixtures/InstallationFixture/main.swift), built
  once in the guest and installed at two locations by a reusable recipe) registered under one
  identifier twice: an unconstrained launch and an unconstrained named open **reused the copy running
  at the other location**, starting no second one, and an installation path **addressed exactly the
  chosen copy**, with the other running and with both, for the launch and for the document; a
  symlink to the folder, a symlink to the bundle and composed and decomposed Unicode spellings chose
  their copy by file identity; a missing copy, an unregistered copy, a deleted copy, a bundle that lost
  its Info.plist and a copy of another identifier reported their dependency, by path and by
  identifier, with nothing launched or substituted; an unreadable folder and an unreadable bundle were
  `failed`; a program that is not a bundle has no selector route, a bundle that declares no identifier
  is not reachable by one, and a default handler that declares none received a document. The same run
  recorded that **Launch Services drops a registration the moment its bundle is deleted** and that it
  **deregisters a registered copy within about 50 ms of its being moved into the Trash** (an unconstrained
  and a path-chosen request after the move reported `APPLICATION_NOT_INSTALLED`), so the
  state "registered present copy in the Trash" cannot be reached by a request on macOS 26.5 and is held
  at L and G with the answers arranged as they were observed (the lookup by identifier returns the
  Trash copy and the list of every copy omits it, which this increment found the constrained selection
  mishandled and fixed). A registration that points into an unreadable folder is likewise not
  reachable at V, because Launch Services stops reporting it. Not covered: removable or network
  volumes, and a second installed copy of any of the twelve real applications.
- **Input boundary.** L and N: a blank identifier and an empty, relative or
  NUL-containing application path are input errors at the original path with no
  `kind`, before any inspection (the path root's own input is below). For the URL: L (`WebURLTests`, `OpenURLTests`), G
  (`WorkspaceCompositionTests`, the real provider over a recording native stand-in) and
  N (`WorkspaceProviderTests`, the signed bundle) refuse every class below at the
  original path with no `kind`, before any handler lookup, and nothing reaches the
  handler. For the path (`OpenPathTests`, `WorkspaceCompositionTests`,
  `WorkspaceProviderTests`; none opens anything): an empty, relative, `~`, `$HOME`,
  `file:`-URL, leading-space or NUL-containing path, a non-string path, and an unusable
  application (any of the launch input's cases, an application that is not an object)
  are input errors at the original path with no `kind`, checked before the target is
  inspected, so a missing path with a blank application reports the input. Spaces, shell
  punctuation, percent signs, Unicode and `..` are submitted as written and inspected
  as written. A target classified as an application bundle (resource metadata or its
  content type), an executable (`public.unix-executable`, `com.microsoft.windows-executable`
  or a subtype) or a Finder alias (`isAliasFileKey`, `com.apple.alias-file` or a subtype)
  is the same input error for the default handler and for a named application, with
  no handler lookup, no application inspection and nothing submitted; each class names
  its own reason. A mutated policy that refuses nothing, one that tests the broad
  `public.executable` ancestor, one that skips aliases and one that reads an inspection
  denial as absence each turned L red. Shell, JavaScript, `.command`, `.webloc`, a
  folder and a document package, and a target with no content type, are not refused.
  For the reveal root (`RevealPathTests`, `WorkspaceCompositionTests`, `WorkspaceProviderTests`; nothing is
  revealed on the host) the same input rules hold, at `["workspaceRevealPath"]` (an empty, relative, `~`,
  `$HOME`, `file:`-URL, leading-space or NUL-containing path and a non-string path), with no application to
  be blank.
- **Documents, directories and settings.** L (`OpenPathTests`), G
  (`WorkspaceCompositionTests`, the real provider over a recording native stand-in) and
  N (`WorkspaceProviderTests`, the signed bundle); nothing is opened on the host. The
  target is inspected first and only through the calls
  [measured prompt-free](../verification/protected-path-metadata.md#inspection-results):
  `realpath`, `stat`, and the `isApplicationKey`, `contentTypeKey` and `isAliasFileKey`
  resource values. A missing path, a dangling link, a path below a file (including a file addressed
  with a trailing `/`, which `realpath` alone forgives), a symlink loop and a name too long to
  exist are `PATH_NOT_FOUND` with no handler lookup, no application inspection and nothing
  submitted, whether or not an application is named and whether or not it is installed;
  metadata that cannot be read, or a required application/alias flag the platform
  did not supply, is `failed`,
  never absence. Then the application is
  chosen: omitted and `null` are the same default; the default is found by the
  system's file lookup for that item and must be present as a bundle when inspected,
  else `NO_DEFAULT_HANDLER` (a stale registration is no handler, unreadable metadata is
  `failed`); a named application takes the launch's selection, so `APPLICATION_NOT_INSTALLED`
  and `APPLICATION_IDENTITY_MISMATCH` are as there, a path constraint disables
  running-copy substitution and no default is looked up. A directory reaches a named
  application such as Zed. The literal path is submitted as written, once; a replacement
  after inspection is not re-inspected and is not replayed, a default changed after
  resolution neither retargets nor replays, and the next action inspects afresh. The
  open is bounded, one-shot and counted exactly as launch and the URL root are, with the
  one capacity shared by all three roots; a refusal or dependency never uses capacity.
  G: the root's authority (neither control alone, refusal before any inspection, the first
  unmet member and the complete set), every dependency branch, a failure at the action's
  path, publication denial at the result, preflight across all three roots, aliases and
  `@skip`, revocation between actions, and an earlier core deadline. N: the signed bundle
  serves the root with its design text, both controls are required, and against real
  fixtures the real adapter reports a missing path, a dangling link and a path below a
  file as `PATH_NOT_FOUND`, an absent, mismatched or wrongly pinned named application as
  its dependency, and a link to an application, a link to a Mach-O program, a Windows
  executable and a real Finder alias as input errors, with nothing opened. A call-path
  check (`task check:launch-call-path`) holds the item lookup to the item's own URL and
  the inspection to the three measured resource keys, with no directory listing and no
  content read, each new check first seen red against a mutated source.
  An extensionless file with its executable bit set has content type
  `public.unix-executable` and is refused as a program, while the same file without the bit
  is opened: the type decides, as the Operations paragraph and the Input boundary row now say
  (this was recorded as a known limit while they read differently).
  **Pending, and not accepted here:** default opening of a *protected* document. The
  system's file lookup is the only route to the default application, and in the
  [measurement](../verification/protected-path-metadata.md#handler-lookup-limit) it raised
  a Files and Folders prompt for documents on Desktop, Documents and Downloads and
  returned a handler even after denial; a directory's did not. Nothing here requests or
  suppresses that consent or substitutes another rule, so the operation is accepted for
  unprotected locations and for named applications, and the protected default case stays
  live work for Antony's consent decision (`protected-default-open-k89`).
  **V** ([open-path-vm.md](../verification/open-path-vm.md)), by the contract-only client in a
  clone of the prepared image with Accessibility never granted: a temporary text file under
  `/tmp`, a directory and a document package each opened in their default handler and with Zed
  named, and the configuration directory in Zed; in each, a window of the handler naming the fixture
  (none of that application's windows named it before the request) and the receipt's process equal to
  the kernel's identity of the handler. Literal spaces and shell punctuation, decomposed Unicode, a
  symlink to a file, to a directory and a file through a symlinked parent opened as written. Source
  scripts, each with and without its executable bit, opened in their default editor (Swift in Code,
  Python in Zed) and in named Zed (JavaScript and Swift). Twenty-five requests were refused, unavailable or failed with no
  application launched or activated (a weak window comparison beside it is described in the document): the input errors (empty, relative,
  tilde, file URL, NUL, a blank application) at `["workspaceOpenPath"]` in an HTTP 200 answer, an
  application bundle and a link to one, three Finder alias files, a Mach-O program and a Windows
  executable by type; `PATH_NOT_FOUND` for a missing file, parent, link, a path below a file and a
  trailing slash, and before a missing application; `APPLICATION_NOT_INSTALLED`;
  `NO_DEFAULT_HANDLER`; and a file inside a mode-000 directory `failed`. Either control alone
  (403, the first unmet member and the complete ordered set), a revoked grant (401) and a missing
  path under one control (403: the denial precedes inspection) opened nothing. The handlers' reactions
  were recorded and not prevented: Terminal ran a `.command` script that had its executable bit and
  no marker appeared for one that had not, iTerm wrote no marker for a `.sh` script, Safari requested the page a
  `.webloc` names, and TextEdit opened the file a `.fileloc` names. No default-handler setting changed
  and Accessibility was read as absent at the start and the end, with no consent dialog listed after any open. The workspace
  profile at V includes the path root (`task conformance`, all three profiles, the path root's removal seen red,
  digest `f98a3862…`). One macOS image, one sample of each timing; a protected document, a removable
  or network volume and an iCloud item were not exercised.
- **Finder reveal.** L (`RevealPathTests`), G (`WorkspaceCompositionTests`, the real provider over a recording
  native stand-in), N (`WorkspaceProviderTests`, the signed bundle) and V; nothing is revealed on the host.
  The path is the same literal path as for opening and is inspected by the same measured prompt-free calls,
  first: a missing path, a dangling link, a path below a file (a file with a trailing `/` included), a link loop
  and a name too long to exist are `PATH_NOT_FOUND` with Finder never looked up and nothing submitted, and
  unreadable metadata is `failed`. Then Finder is checked as an installed application bundle (`com.apple.finder`)
  by launch's own selection: unregistered, a registration whose bundle is gone, and a bundle with another
  identifier are all `APPLICATION_NOT_INSTALLED` with guidance naming Finder, and nothing is cached between
  actions. There is **no refusal policy and no handler lookup**: an application bundle, an executable and a
  Finder alias are revealed, not opened. The submission is the one native call
  `selectFile(_:inFileViewerRootedAtPath:)` with Finder's boolean as the acknowledgment, through the same
  bounded one-shot, shared capacity and no-replay path as launch and open: a false answer is `failed`, a missing
  callback ends at the bound, a late callback is ignored and releases its slot once, cancellation ends the wait
  and a refusal or dependency never uses capacity (L). The receipt is `{path}`, the submitted path as written;
  it carries no process, whatever the callback delivers. The filesystem root is the documented root view
  (`selectFile(nil, …RootedAtPath: "/")`), chosen from the filesystem (`lstat` equal to `/`) and never from the
  spelling, so `/var/..` is not the root (L holds the plumbing; V the effect). G: the root's authority (neither
  control alone, a refusal before any inspection, the first unmet member and the complete set), both dependency
  branches, a failure at the action's path, publication denial at the status, value, the non-null path and the
  dependency, preflight across all four roots, aliases and `@skip`, revocation between actions and an earlier
  core deadline. N: the signed bundle serves the root and both new types verbatim from the design file, both
  controls are required, and against real fixtures the real adapter reports a missing path, a dangling link, a
  path below a file and a loop as `PATH_NOT_FOUND`. `task check:launch-call-path` holds the reveal to exactly one
  Finder selection request in two source forms on a global queue, with the bundle carrying that one selector and
  the alternative `activateFileViewerSelecting` forbidden, each check first seen red. **V**
  ([reveal-path-vm.md](../verification/reveal-path-vm.md)), by the contract-only client in a clone of the prepared
  image with Accessibility never granted, **observed by an independent process reading Finder's own account** (its
  front window's folder and the selected item's path, kind and name, from a Finder with no window), with a
  screenshot of each: a file, a folder (also with a trailing slash), an application bundle (selected, Zed not
  launched), a Finder alias file (itself, not resolved), the root and `//` (a window on `/`, nothing selected), a
  literal-punctuation name and a symlink (as the link) were each selected as asked and the receipt echoed the
  path; ten requests were refused or unavailable (the input errors at `["workspaceRevealPath"]`, `PATH_NOT_FOUND`)
  and either control alone (403, the first unmet member and the complete ordered set), a revoked grant (401) and a
  missing path under one control (403) revealed nothing, with no launch or activation and Finder still showing no
  window. **Recorded, not asserted:** Finder read `/var/..` its own way (the root with `var` selected), and with
  another application in front the item reveals did not bring Finder forward (the root views did). **Pending, for
  Antony:** revealing a third-party application bundle (Zed) made macOS post "Koine was prevented from modifying
  apps on your Mac"; system applications and an inspection-only refusal did not
  ([bounded probe](../verification/reveal-path-vm.md#the-app-management-notice)). No consent was requested and
  the reveal worked, so no posture change is made; `reveal-app-bundle-notice-k90` holds the decision. One macOS
  image, one sample of each; Finder with a window already open, a removable or network volume, an iCloud item and
  a protected folder were not exercised.
- **Browser URL.** L, G, N and V. L, G and N drive no browser (below); V is
  [open-url-vm.md](../verification/open-url-vm.md), summarized after this paragraph.
  The grammar is held as a decision over bytes (`WebURLTests`): accepted are an `http`
  or `https` scheme in any case, a host, path, query and fragment with valid percent
  escapes (encoded query and fragment included), ports (empty allowed), IPv4, IPv6 (hex groups of at most four digits, an IPv4 tail without leading zeros) and
  IPvFuture literals, and ASCII IDNA A-labels (RFC 3492 vectors for `bücher`, `münchen`,
  `例え`, `テスト`); each accepted URL is also shown to reach the native layer as the very
  bytes validated. Refused, each class by its own cases, are control characters,
  whitespace, backslashes, raw Unicode in path, query, fragment and host, credentials,
  other schemes (`file`, `javascript`, custom), a missing scheme or host, invalid percent
  escapes, characters RFC 3986 does not allow, percent-encoded or malformed hosts, and
  IDNA violations (an `xn--` label that is not Punycode, decodes to ASCII only or to a
  control character, or does not re-encode, and `--` in the third and fourth positions of another label). Bounded by
  design: whether a decoded label's code points are valid in IDNA 2008 is the browser's
  to decide, and a port has the grammar's `*DIGIT` with no range. A mutated validator that
  admits everything turned the L and G refusal cases red. The handler is found by the
  scheme alone: L records every lookup's only parameter (`http` or `https`), and the
  real adapter passes `http:` or `https:` and nothing from the submitted URL;
  `task check:launch-call-path` inspects exactly that, one lookup and one open request
  addressed to the resolved application with launch's ten configuration settings, each
  new check first seen red against a mutated source. L, with the native adapter
  substituted: an absent handler, a handler whose bundle is gone and a default per scheme
  without fallback are `NO_DEFAULT_HANDLER` with nothing submitted, unreadable handler
  metadata is `failed`, a default changed after resolution neither retargets nor replays
  and the next action resolves afresh, a negative acknowledgment, a missing callback and
  a late callback (ignored, releasing its slot once), cancellation before and during the
  wait, one-shot completion, and exhausted capacity (shared with launches) refused before
  submission and restored by a callback. G: the URL root's authority (neither control
  alone, a refusal before any lookup, the first unmet member and the complete set), its
  branches, an action's own `failed` with later actions still running against an earlier
  core deadline that answers the whole request, preflight across both roots, aliases and
  `@skip`, revocation between actions, and publication denial at the result. N: the signed
  bundle serves the root with its design text, both controls are required, and malformed
  URLs are input errors; no well-formed URL is sent from the host. **V**
  ([open-url-vm.md](../verification/open-url-vm.md)), by the contract-only client in a
  clone of the prepared image with Accessibility never granted: with Safari the default, an
  encoded path, query and fragment (cold browser, then running), an ASCII IDNA host and the
  client's search flow with a suggestion source that refused the connection and one that never
  answered each reached the browser byte for byte (a page server in the guest saw the
  request-target, `Host`, `location.href` and fragment as submitted; the search cases check the
  typed-query target and `location.href`); the same with a test browser made the alternate
  default, which records the exact string it is handed; eighteen
  refused inputs (invalid escapes, raw Unicode, whitespace including a trailing newline,
  backslashes, credentials, other schemes, the empty string) were input errors at
  `["workspaceOpenURL"]` in an HTTP 200 answer with nothing repaired or opened, and either
  control alone (403, the first unmet member and the complete ordered set) and a revoked grant
  (401) opened nothing; the receipt's process was the kernel's for the browser in each of the
  twelve direct opens (the search cases do not compare it); Koine's packets were on loopback only
  in a packet-level capture of two searches, with controls for curl and for a process named
  `Koine` on `URLSession` and Network.framework, and the engine's lookups were made for Safari;
  Accessibility was read as absent at the start and the end, with no consent dialog. **The universal-link candidate** (a Maps link) was
  received by the browser first with no application diverted to on Koine's account, but this
  image cannot show the system's own dispatch diverting a plain `open` (Safari itself forwards
  Apple links to Maps, and no installed application has a resolvable associated domain), so
  the scheme-only lookup rests on `task check:launch-call-path` run on the signed bundle.
  **Pending: Dia's page load.** Dia's first run stops at an account gate, so for Dia the run
  observed that the open was acknowledged, Dia activated and the receipt equal to the kernel's
  identity, and no page: what Dia was handed is not observed; what counts is Antony's to settle (`account-acceptance`'s leaf `dia-url-page-load-k88`).
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
  effect-binding is claimed. The path root answers through the same value builder, so
  the receipt contains no installed path, bundle identifier or handler metadata (L, G).
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
- **Authority/revocation.** G and N (through the real signed bundle), for all three roots: neither
  control alone, and neither read, is enough; both controls without reads reach the
  provider; denial precedes inspection; the first unmet member and the complete set;
  multi-action preflight, aliases and `@skip`, revocation between actions. V
  ([launch-vm.md](../verification/launch-vm.md)): both controls with no read
  capability launch and reactivate; either control alone (HTTP 403 at
  authorization, the first unmet member and the complete set named), `desktop:read`
  alone and a revoked grant (401) launch nothing and move no focus, with the
  application stopped and running. Disclosure: the native create-grant, request and
  existing-grant views and `koineManagement.capabilityDisclosures` carry the same
  workspace-control text, and the served field descriptions are the design file's,
  observed in the window by V
  ([workspace-disclosure-vm.md](../verification/workspace-disclosure-vm.md)).
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
  The same reading-restricted pass added `open-url` and `search`
  ([open-url-contract-client-findings.md](../verification/open-url-contract-client-findings.md)) and
  `open-path` ([open-path-contract-client-findings.md](../verification/open-path-contract-client-findings.md)),
  which opened a document and a directory in the V run above. `reveal-path` was added by the implementing
  leaf and **not** by a reading-restricted pass, so it carries no findings document and its independence is
  not claimed; its reading is `workspace-reveal.ts` (receipt `{ path }`, `selectionObserved` always false).
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
  design SDL the complete workspace design, verbatim ([schema-conformance-vm.md](../verification/schema-conformance-vm.md),
  [launch-contract.md](../verification/launch-contract.md)). A missing required
  provider or coordinate fails. The profile's design file also declares
  `workspaceOpenURL`, with a control that removes it, and the signed application in a VM
  serves exactly that (digest `1815b52f…`, `task conformance` passing all three profiles,
  [open-url-vm.md](../verification/open-url-vm.md#regression-and-what-was-re-run)); with
  `workspaceOpenPath` added the same holds at digest `f98a3862…`, its removal seen red
  ([open-path-vm.md](../verification/open-path-vm.md#regression-and-what-was-re-run)); with `workspaceRevealPath`, the last root, the file is the whole
  design and the same holds at digest `3bab3a04…` with its removal seen red
  ([reveal-path-vm.md](../verification/reveal-path-vm.md#the-contract-only-client-and-the-workspace-profile)). Pending: the complete selection matrix
  (`selection-acceptance`), old/new binaries with this provider, and selected
  updates and explicit absent/rejected sets in conformance.
