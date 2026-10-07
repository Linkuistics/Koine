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

The [long-location action boundary](#long-location-action-boundary) is designed
for v1 and unimplemented. Koine resolves action locations component by component,
so an extant location is never reported missing. A location too long for macOS's
application hand-off is refused with `failed` and a stated cause; making
applications accept it is deferred past v1. None of this extends the short-path
acceptance above.

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
file identity, not spelling, Unicode normalization or a path prefix: the designed
v1 repair takes device and inode from Koine's own
[resolution](#resolving-an-action-location). Failure to establish identity is `failed`. Document paths are
location-based requests with normal symlink semantics, not pinned file identities.
An absent path/dangling link found before submission is `PATH_NOT_FOUND`.
Replacement or handler changes racing submission may fail or open a new
occupant. Search must not imply stronger identity than this contract.
The [native prompt boundary](../verification/protected-path-metadata.md#handler-lookup-limit)
applies before submission: successful metadata inspection does not establish
that default-handler lookup is prompt-free. Protected default-document opening
remains pending; named-app opening and reveal do not need that file-handler read (but a named open of an item in a protected folder is still prompted when it is submitted: see [V](../verification/target-locations-vm.md#first-use-in-the-protected-folders)).

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
identity with that object's executable (each the device and inode the descriptor walk resolves, below), then read the
start instant again.
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
| Extant target or selected application whose literal, expanded or resolved spelling is `PATH_MAX` (1,024) bytes or more, not counting its NUL; link budget exhausted; metadata unacquired or malformed | Designed v1 repair: pre-submission `failed`; guidance names the stage, cause and byte count, and no domain request was made. Only Koine's own [resolution](#resolving-an-action-location) establishes that a location is absent; a later ELOOP, ENAMETOOLONG, nil or no-such-file never does. |
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

**Designed for v1; every stage, the 1.0.1 release and its compatibility pairs implemented. The target stage's effect is accepted at V ([record](../verification/target-locations-vm.md)): the walk is prompt-free in Desktop, Documents and Downloads, and the first *open* there asks the user once through the platform's own prompt (approved in the disposable clone, after which the open completes and a second request is prompt-free). The application stages' V (`application-locations-vm`) is still pending.** The descriptor walk, the hand-off limit and the target stage are accepted at L, G and N
for reveal ([record](../verification/reveal-locations.md)) and for open
([record](../verification/open-path-locations.md)), and the supplied-application stage (a constrained launch's
and a named open's `applicationPath`, with the registered-candidate comparison) at L, G and N
([record](../verification/application-locations.md)), with the present outcomes no refusal or result shows
left to V. The discovered-application stage (an unconstrained launch's or a named open's preferred copy, a default
handler, the default web browser and Finder) is accepted at L and G
([record](../verification/discovered-applications.md)), with its N and V rows left to
`application-locations-vm` because Launch Services' registrations cannot be arranged on a host. The receipt's two
executable identities (the live process's and the retained object's) are acquired by the walk in one device-and-inode
representation, with observation's own rule that no length limit applies, and are accepted at L and N
([record](../verification/receipt-executable-identity.md)); the effect on a real launch's receipt is left to
`application-locations-vm`. The 1.0.1 release is built: the signed `Koine.app` packages workspace release/schema **1.0.1**
serving the [repair SDL](../design/workspace-action-repair-schema.graphql) verbatim, its catalogue entry says so, and the
[1.0.1 profile](../design/profiles/core-desktop-workspace-repair-extension-host.json) holds what the signed host serves to its
composed design, its digest and its candidates ([record](../verification/action-repair-release.md)); the retained 1.0.0
bundle, SDL and profile are untouched and independent of it. The compatibility pairs are accepted at N and G
([record](../verification/workspace-compatibility.md)): the retained 1.0.0 and this tree's 1.0.1 each under both
hosts, the approved per-user 1.0.1 variant over the bundled 1.0.0 on the retained host, the same locations through
every pair (the extant directory of 1,024 bytes or more is the one outcome that differs: `PATH_NOT_FOUND` becomes
`failed`), the retained revision's own short-path suites repeated against 1.0.1, and every selection fixture
re-pinned to 1.0.1 ([selection-updates.md](../verification/selection-updates.md#re-pinned-to-workspace-101)).
Koine resolves every action location
itself, component by component, so it never reports an extant location
missing. It then refuses to hand an application any location whose spelling
is `PATH_MAX` (1,024) bytes or more, with `failed` and a stated cause. Making
applications accept such locations is deferred past v1
([Linkuistics/Koine#1](https://github.com/Linkuistics/Koine/issues/1)); Antony
made that trade-off on 2026-10-07 after the
[separated local naming collection](../verification/separated-local-url-naming-prototype.md).
The [descriptor-relative access decision](../adr/filesystem-access-is-descriptor-relative.md)
binds the resolution; the
[long-location view](../design/architecture/index.html#diagram-workspace-long-locations)
draws the order below.

Search returns locations through 8,192 UTF-8 bytes. That is a discovery and copy
ceiling, not an action input bound: action paths keep their literal
absolute-path syntax, and a long path is valid input. Length is a property of the
application hand-off, not a caller error.

#### Resolving an action location

Each location an action uses is resolved before any pathname-based platform call
addresses it, in the [order below](#order-of-target-and-application-stages).
Resolution starts from a handle on the filesystem root and takes the literal
components in order. It opens each directory it descends through search-only
(`O_SEARCH`), never for listing, and opens no file. The final component is
examined with one `fstatat` from its parent and never opened, so, as with the
accepted `stat`, a final directory needs no search permission of its own. `.` is
skipped, `..` moves to the current directory's physical parent, and a symbolic
link is expanded from its own text, absolute or relative to the directory that
contains the link, exactly as the kernel would. A trailing slash demands a
directory. The final link is followed for presence, type and the hand-off, as the
accepted short-path contract does. Each step uses one single-component call, so
its error names that component.

| Resolution observation | Outcome |
| --- | --- |
| A component does not exist, or a non-directory sits where a directory is required, including a dangling link and a trailing slash after a file | Absent: `PATH_NOT_FOUND` for a target; the application dependency for an application location (below). |
| A component's own lookup fails with `ENAMETOOLONG`, the component is ASCII, and its byte length exceeds the `fpathconf(_PC_NAME_MAX)` value its directory returns | An established impossible component: absent, `PATH_NOT_FOUND`, for a target; `failed` for an application location, as the accepted application inspection treats it. |
| The same link text is read again in the same containing directory with the same pending suffix (a run of slashes counted as one) | An established cycle: absent, `PATH_NOT_FOUND`, for a target; `failed` for an application location, as above. |
| Resolution needs a 33rd link expansion without such a repeat | `failed`: the link budget, not absence. |
| Any other `ENAMETOOLONG` at a component (a non-ASCII name, or one within the returned limit), `fpathconf` returning `-1`, one link read twice with different text, denial, or any other error at a component | `failed`, naming the component and cause; never absence or an invented consent. |
| Every component resolves | Present: the object's device and inode and its type; for reveal, the root decision below; and three spellings: the literal path, each remaining path after a link expansion, and the resolved path. |

**Name limits.** A successful lookup always establishes presence, whatever the
name's length or the limit `fpathconf` reports. Resolution never judges a name
before looking it up and never creates a name to test one. Only the ASCII
comparison establishes impossibility, because it is independent of the
filesystem's unit: for ASCII, bytes, UTF-16 units, characters and every Unicode
normal form count alike. Filesystems count other names differently (HFS+ reports
255 for `_PC_NAME_MAX` yet admits 255 UTF-16 units, which can be 765 UTF-8
bytes), so a non-ASCII `ENAMETOOLONG` is `failed`, not absence.

**Cycles.** A cycle is a repeated resolver state, not a repeated link. Relative
link text is read from the directory containing the link, and one symbolic-link
inode can have entries in two directories, so the same link and pending suffix
can recur on a finite path. The state is therefore the containing directory's
device and inode, the link text, and the pending suffix including any trailing
slash, a run of slashes counted as one because the kernel reads it as one: what
follows an expansion depends on nothing else, so a repeated state would recur at
any budget. A link whose text ends in a slash (`a` → `a/`) gains one on every
lap and is therefore a cycle, where an exact comparison would never repeat. The link's own device and inode serve only to
notice one link read twice with different text, which is a changed observation,
`failed`. Up to 32 expansions are allowed, as the kernel allows: a location that
resolves after its 32nd expansion is present. A cycle the budget ends before it
repeats is the budget, `failed`; that includes a link whose expansion re-enters
itself with a longer pending suffix each time (`a` → `a/x`), which never repeats a
state. Only a repeated state establishes a cycle.

**Reveal's root.** The accepted root rule stands. Finder's root view is used only
when the object `lstat` of the literal path names is the filesystem root's own
device and inode. `lstat` does not follow a final link unless the kernel's own
lookup does, as it does for a trailing slash. So a link to `/`, such as
`/Volumes/<name>`, is selected as the link, while `/Volumes/<name>/` names the
root; `/`, `//`, `/.` and `/..` are the root; `/var/..` is `/private` by the
physical parent and is not. The followed identity still decides presence and the
hand-off.

Absence of a location is established only by this walk. A later platform
`ENOENT`, `ELOOP`, `ENAMETOOLONG` or no-such-file wrapper about a location the
walk found is `failed`. That rule is about location absence: the accepted
completed reports keep their meanings, so no registration for an identifier is
`APPLICATION_NOT_INSTALLED`, a completed nil default-handler report for a
resolved target is `NO_DEFAULT_HANDLER`, and a bundle with no identifier is a
mismatch for a named selector. Receipt observation resolves the live executable's
kernel path (`proc_pidpath`, up to 4,096 bytes) and the retained application
object's executable the same way, in one identity representation, with the
existing null rules. The hand-off limit does not apply to it: the action was
already acknowledged, so a present executable of any length gives its identity,
and any other walk outcome gives no identity and the existing null process, never
a refusal.

#### Order of target and application stages

The accepted order stands: the target is settled before any application is
chosen, so a missing target is never conflated with a missing application or
handler. Every stage resolves a location and applies the
[hand-off limit](#application-hand-off-limit) before any platform call addresses
that location by path.

1. **Target** (open and reveal). Resolve the caller's path: absent is
   `PATH_NOT_FOUND`, a resolution failure is `failed`, an over-limit spelling is
   refused. Only then are the target's type, application and alias flags read and,
   for open, the payload policy applied. Launch has no target.
2. **Supplied application** (a constrained launch or named open). Resolve
   `applicationPath`: absent is `APPLICATION_NOT_INSTALLED`, a resolution failure
   is `failed`, an over-limit spelling is refused before any registration or other
   platform call. Then read the chosen copy's bundle metadata: a present
   non-application is `APPLICATION_NOT_INSTALLED`; another identifier, or none, is
   `APPLICATION_IDENTITY_MISMATCH`. Then compare it with the pertinent registered
   candidates (the identifier's registered copies, then its preferred copy if not
   among them), in that order, stopping at the first match. Each candidate is
   resolved and compared by device and inode alone; its own metadata is not read.
   A candidate the walk establishes absent, or whose device and inode differ, is
   skipped, wherever it is enumerated. A candidate reached before any match whose
   resolution fails, a cycle or impossible name included, leaves equality unknown,
   which is `failed`, never a skipped copy; candidates after the match are not
   examined, as before. A present chosen copy that matches no candidate is
   unregistered: `APPLICATION_NOT_INSTALLED`. The matching registration is the
   selected application.
3. **Discovered application** (a launch or named open without
   `applicationPath`, the default handler, and reveal's Finder). A discovery read finds the location: the
   identifier's preferred registered copy, the default handler for the target that
   passed stage 1, the default web browser for a URL open (found by its scheme alone, as that
   operation already requires), or Finder's registration. No registration is
   `APPLICATION_NOT_INSTALLED` and a completed nil handler report is
   `NO_DEFAULT_HANDLER`. Resolve the discovered location: established absence is
   that same dependency, as a stale registration is today, and a resolution
   failure, a cycle or impossible name included, is `failed`. The discovered
   location is the selected application.
4. **Selected application.** Apply the limit to the selected application's
   spellings, then read the pathname-based metadata it still needs: for a
   discovered application, a present non-application is the stage 3 dependency
   and a named selector's identifier is checked as before. Reveal reports every
   Finder dependency, a mismatch included, as `APPLICATION_NOT_INSTALLED`, as
   before. Then submit: a launch or
   open addresses the selected application's registered location, with the
   caller's literal target bytes for an open; a reveal asks Finder to select the
   caller's literal path, or for the root view.

Candidates are resolved only to compare them. Because equality is now device and
inode, an unequal candidate whose metadata cannot be read is skipped, where the
retained identity read failed it; that failure existed only because equality was
unknown, and resolution now settles it. The limit applies to the chosen copy and
the selected application, never to an unequal candidate, so a long copy of the
same application on disk does not stop a workflow whose selected application is
short. When the long copy is the identifier's preferred one, an unconstrained launch
or named open discovers and selects it and is refused at the limit: no other copy is
substituted, and a short copy already running does not rescue it, because the
refusal precedes the platform. A location the
caller supplied is refused before any platform call on it; a discovered location
is refused after the discovery read that found it and before anything addresses
it by path. Discovery is a read, so in every case no domain request (launch, open
or Finder reveal) was made.

#### Application hand-off limit

After a location resolves, compare the byte length of every spelling the platform
would need: the literal path, every expanded remainder and the resolved path. The
stages above apply this to the target, to a supplied `applicationPath` and to the
selected application. Lengths count the pathname's bytes and never its
terminating NUL. `PATH_MAX` (1,024) is the SDK's buffer size **including** that
NUL, so the longest spelling handed over is 1,023 bytes. A spelling of 1,024
bytes or more is refused: the action is `failed` before submission. Guidance
names the application hand-off stage, the spelling and its byte count, and says
no request was made. Nothing addresses a refused location by path afterwards: a
refused target gets no classification, handler lookup, Finder request or open,
and a refused application no metadata read, launch or open.

The gate is the SDK constant applied to every whole-pathname service, not a
measured threshold of each one. The
[k134 prototype](../verification/long-action-route-prototype.md#what-was-measured)
measured the exact boundary only at submission: a 1,023-byte document path was
delivered with exact bytes and 1,024 and 1,025 failed. Its metadata and handler
lookups answered for 1,021 to 1,023-byte paths and next failed at the tested
1,098 bytes, and registration was tried only short and at about 1,500 bytes.

A supplied application's identifier is read from `Contents/Info.plist`, a path 20 bytes longer than the
bundle's own. Observed on macOS 26.5 through the signed provider
([record](../verification/application-locations.md#the-bundles-own-infoplist-is-twenty-bytes-deeper)): a
bundle whose own path is 1,004 bytes or fewer is read, and one of 1,005 to 1,023 bytes is within the limit and
is not refused at it, but the platform answers `ENAMETOOLONG` for its Info.plist, which is `failed` naming that
cause, never an absence or another identifier. The route is the retained one, which failed the same way.

Below the limit, the accepted short-path route is unchanged. It uses the
[protected-path metadata route](../verification/protected-path-metadata.md#inspection-results)
with its accepted addressing: type, application and alias flags and `Bundle`
identifiers read the resolved spelling, as the accepted `realpath` route did;
registration is looked up by identifier; default-handler lookup keeps the
caller's literal target, as accepted. Submission addresses the selected
application's registered location and carries the caller's literal target bytes
for opening or reveal; acknowledgment and receipt follow it. Their accepted
meanings stand. A nil
handler for a target the walk found is `NO_DEFAULT_HANDLER`. A completed no-type
report is not a refusal. A bundle without an identifier mismatches a named
selector but can still be a default handler. An application, executable or alias
target is refused. Metadata failure is `failed`. Every launched application runs
an executable whose path the kernel accepted, so the limit adds no systematic
`process: null`. That is observed rather than assumed: on the macOS 26 host the kernel kills at exec, and the spawn
service refuses, a program whose physical path is 1,024 bytes or more, so no running process has a path the walk
could not also take
([record](../verification/receipt-executable-identity.md#what-a-running-process-cannot-show)).

#### Obligations from earlier descriptor walks

The [application survey](../research/long-pathname-applications.md#51-component-relative-resolution-for-presence-and-cause)
records how mature walks failed. Each is an obligation here:

- **Descriptor budget.** A walk holds at most two handles, the current directory
  and the next, and closes both before submission. It needs no new budget.
- **No recovery branch.** A failed step is the outcome. There is no whole-path
  fallback, reopen-by-name recovery or retry.
- **No depth-evading checks.** Payload refusal applies to the resolved object at
  any depth. An over-limit location is refused before classification, never
  admitted because classification could not run.
- **No reconstructed long strings.** A spelling reaches a whole-path platform
  call only after it passes the limit.
- **No prompts.** Resolution lists nothing and opens no file. k134's read-mode
  walk prompted at Documents; the search-only walk did not prompt on first-use
  Desktop, Documents or Downloads
  ([measured](../verification/descriptor-walk-prompt.md)), so its first-use
  behaviour stays an acceptance obligation only for the V rows and other OS
  builds. At V the walk itself stayed prompt-free in the signed app (a reveal of a document
  and of a directory in each of the three folders), while every *open* of a target there,
  by default or with an application named, raised the platform's own prompt for Koine when
  the request was submitted: a plain program that is not Koine is prompted the same way
  ([measured](../verification/target-locations-vm.md#first-use-in-the-protected-folders)).
  A prompt goes to Antony, never a whole-path fallback or a shipped
  dialog.
- **No spelling drift.** Resolution follows kernel semantics with no ancestor
  canonicalization, and never rewrites, shortens or normalizes the submitted
  bytes.

#### What v1 does not do

- **No hand-off workaround.** Bookmarks, a parent reference plus name,
  file-reference URLs, `/.vol` addresses, FSRef item arrays, short links, copies or
  aliases, working-directory tricks, private policy and receiver side channels
  are all out. The [route evaluation](../verification/long-action-route.md#v1-decision)
  and its diagnostics found none that delivers a long location to an application
  with its original spelling, native facts and receipt. Zed reads by whole path
  after delivery anyway. Koine#1 owns the question after v1.
- **No new error kind or dependency reason.** The refusal is `failed` with
  guidance, so the action-only repair stays compatible (1.0.1). A distinct reason
  such as `PATH_TOO_LONG` would be a new output enum value for existing clients,
  an incompatible change needing its own decision, for a case v1 clients can
  already report from the guidance.
- **No input bound or shortened search ceiling.** A search result through 8,192
  bytes remains valid input and a valid copy value.
- **No silent loss.** A long location is never dropped, rewritten or retried
  against another copy; the client is told why it cannot be handed over.

#### Subjects and versions

Launch-and-open planning owns independently component-created action subjects;
no search implementation is needed to close them:

- **L** checks the planner's mapping for every resolution row, every stage and
  the limit with the substituted private adapter, including the cases no fixture
  can build: an over-limit target, after which the adapter records no metadata
  read and no handler, registration or Finder lookup; an over-limit
  `applicationPath`, with no metadata read of it and no registration lookup; an
  over-limit discovered application or default handler, which records exactly
  the discovery read that found it and then no metadata read of it and no
  submission; a stale
  absent candidate, an unequal long candidate and an unequal candidate with
  unreadable metadata beside the present chosen copy, each enumerated before and
  after it (skipped); a candidate whose resolution fails before the match
  (`failed`) and after it (not examined, selected); a cycle or impossible name at
  an application location or default handler (`failed`); and a Finder
  registration with another identifier (`APPLICATION_NOT_INSTALLED`).
- **N** exercises the real walk on host fixtures: every resolution row at short
  and roughly 1,500-byte depth; the 1,023/1,024-byte boundary (pathname bytes,
  NUL not counted) for a literal path, a short literal whose link expansion is
  long, and the resolved spelling; acyclic 31- and 32-link chains that resolve
  and a 33-link chain that is the budget; the retained two-link cycle and finite
  repeated dot-link; a self-extending link (`a` → `a/x`), which is the budget;
  one symlink inode with entries in two directories whose path is finite, where a
  filesystem admits that construction; a final directory without search
  permission (mode 0600), which resolves present and keeps its accepted open and
  reveal outcomes; the retained 300-byte
  ASCII impossible component beside extant multibyte (over 255 UTF-8 bytes where
  the filesystem admits it) and combining-character names, which must resolve;
  and the reveal root decision on `/`, `//`, `/.`, `/..`, `/var/..` and a link to
  `/` with and without a trailing slash, compared with the retained `lstat` rule.
  N observes through the independently built provider binary on the host, which
  launches and reveals nothing: a result, or a refusal that follows resolution and
  names the spelling and its byte count. Tests of the walk's own shared source
  support N and never close it. A present outcome that no refusal exposes (a
  within-limit resolving chain, the mode-0600 directory, the two-directory link,
  the multibyte names and the root decision) is observed at V by its effect.
- **G** checks the public outcome: `failed` with guidance at the action's
  response path, never a dependency, for an extant over-limit location.
- **V** uses signed isolated macOS. Each delivery and Finder observer is first
  controlled by an independent non-Koine route delivering a 1,023-byte subject;
  no over-limit delivery is ever a control. A document whose path is 1,023 bytes
  opens in its default handler and in Zed and is revealed. The controlled observers
  then show nothing delivered or selected
  for 1,024-byte and roughly 1,500-byte files and directories. Also check: a
  missing long path is `PATH_NOT_FOUND`, an over-limit constrained application
  path is `failed`, short launch, named open and reveal still work with a long
  copy of the same application on disk, the root and link-to-root reveals keep
  their accepted forms, and first-use resolution in Desktop, Documents and
  Downloads is prompt-free.

App-and-file-search acceptance owns the actual handoff: actual search returns an
over-limit file and application, the unchanged selected values receive this
refusal, and a returned location within the limit acts. Injected results and the
action subjects cannot close it.

The action-only correction is workspace release/schema **1.0.1** under
`koine-desktop/1`, with unchanged input/result shapes, error kinds and enums. Its
[repair SDL](../design/workspace-action-repair-schema.graphql) appends the exact
launch/open/reveal description text, which must change the composed digest on
the same host and printer. Keep the retained 1.0.0 bundle, SDL and profile
unchanged: [the bundle is built from a pinned revision and verified apart](../verification/retained-workspace-baseline.md). Search release/schema 1.1.0 carries the same descriptions in its own
composed profile. Planning owns the native, test and contract-client
[implementation obligations](../verification/long-action-native-boundary.md#compatibility-and-implementation-obligations).
Earlier short-path evidence stays bounded to its subjects; the 1.0.0 mapping of
`ELOOP`/`ENAMETOOLONG` to absence is the defect this replaces.

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
| Consent and prompts | G, N, V | [First-use metadata probe](../verification/protected-path-metadata.md): tested metadata calls were prompt-free; document file-URL default-handler lookup prompted on Desktop, Documents and Downloads. Protected default opening and handler discovery remain pending for a human consent/semantics decision. **At V ([target-locations-vm](../verification/target-locations-vm.md#first-use-in-the-protected-folders)) a named open of an item in these folders and a directory's open were prompted too, at submission (approved in the clone, then completed), and a reveal never was; whether Koine helps with that consent is still the decision `protected-default-open-k89` carries.** Removable/network-volume observations were unavailable. Operation acceptance still checks Accessibility absent/revoked, app onboarding and the separate Gatekeeper timeout case (URL, Accessibility absent: [open-url-vm.md](../verification/open-url-vm.md#accessibility-and-consent); path: [open-path-vm.md](../verification/open-path-vm.md#accessibility-and-consent); reveal: [reveal-path-vm.md](../verification/reveal-path-vm.md#accessibility-and-consent), which also records a system notice naming Koine that revealing a third-party application raised, [pending a decision](../verification/reveal-path-vm.md#the-app-management-notice)). No new consent/signing posture is implied; inspection denial remains failed, not absence or an invented os-permission. |
| Packaging/selection | N, G, V as assigned | Complete Machine selection matrix, independent additional-capability old/new binaries, exact candidate and absent/rejected conformance. Mocks, SDL equality alone and old baseline evidence do not close these rows. |
| Long-location actions, independent of search | L, G, N, V; launch-and-open owns | The [v1 subjects](#subjects-and-versions): every resolution outcome and stage at short and roughly 1,500-byte depth, the 1,023/1,024-byte hand-off boundary (NUL not counted) for literal, expanded and resolved spellings, the 31/32/33-link budget, cycle-state, name-limit, reveal-root and registered-candidate subjects, positively controlled observers showing no delivery or selection for refused locations, short-workflow regression with a long copy on disk, prompt-free first-use resolution in protected folders, and separate 1.0.0/1.0.1 binary profiles. Reveal's target stage: L, G and N accepted ([reveal-locations.md](../verification/reveal-locations.md)); open's target stage and payload refusal on the resolved object: L, G and N accepted ([open-path-locations.md](../verification/open-path-locations.md)); the supplied-application stage (`applicationPath` and the registered-candidate comparison by device and inode): L, G and N accepted, the candidates' comparison at L and G only because Launch Services' registrations cannot be arranged on a host ([application-locations.md](../verification/application-locations.md)); the discovered-application stage is accepted at L and G ([discovered-applications.md](../verification/discovered-applications.md)) and the receipt's executable identities at L and N ([receipt-executable-identity.md](../verification/receipt-executable-identity.md)); the 1.0.1 release, catalogue and profile are accepted against the signed host ([action-repair-release.md](../verification/action-repair-release.md)); the retained-host compatibility pairs, the retained subjects repeated against 1.0.1 and the selection fixtures re-pinned to it are accepted at N and G ([workspace-compatibility.md](../verification/workspace-compatibility.md)); the N gaps closed by effect and V for the target stage are accepted ([target-locations-vm.md](../verification/target-locations-vm.md)): 1,023 bytes opened and revealed, 1,024 and about 1,500 refused with nothing delivered or selected, the walk's present outcomes seen by effect, the root and a link to it, a missing long path, and first-use resolution prompt-free in Desktop, Documents and Downloads (the first *open* there is prompted by the platform and was approved in the clone), with a default open of a chain of more than ten links answering `NO_DEFAULT_HANDLER` because the platform's own lookup stops there; the application stages' V is pending. No search implementation is required. |
| Actual long search-result handoff | G, N, V; app-and-file-search owns | Actual search returns an over-limit file and application; the unchanged selected path and identifier receive the stated `failed` refusal with no delivery, while a returned location within the limit acts, with independent witnesses. [Search acceptance](workspace-search.md#test-seams-and-acceptance) retains this provenance requirement. Independent fixtures, injected results or action acceptance cannot close it. |

GraphQL/client evidence must retain client ownership of query UI, suggestions,
fallback, chooser/MRU, clipboard and settings reload/relaunch. Reusable build,
fixture, conformance and VM recipes extend the existing Taskfile. Missing app
installations or certificates leave acceptance live; they are not passing absence
tests for the required working paths.

### Evidence so far

The following records describe the retained action-only 1.0.0 baseline and its
actual short-path subjects. Its broad ELOOP/ENAMETOOLONG-as-absence mapping is the
defect the v1 [resolution](#resolving-an-action-location) replaces. The concrete
cycle/impossible-component outcomes stay required; 1.0.1 establishes their causes
by resolution and reruns them with the short-workflow regressions. These records and original
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
  live work for Antony's consent decision (`protected-default-open-k89`). **V found the
  prompt is wider than the lookup:** a named application does not avoid it, and a
  directory's open raises it too, because the prompt belongs to the submission, which any
  program is prompted for ([target-locations-vm.md](../verification/target-locations-vm.md#first-use-in-the-protected-folders)).
  Reveal never prompted.
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
- **Long-location actions: the target stage of reveal and of open.** The descriptor walk
  (`Providers/WorkspaceProvider/Logic/LocationWalk.swift`), the hand-off limit
  (`HandOffLimit.swift`) and reveal's use of them are accepted at L
  (`RevealLocationTests`), G (`WorkspaceCompositionTests`) and N
  (`WorkspaceLongLocationTests`, through the independently built, signed bundle on
  the host), with the walk's own source tested on host fixtures at short and
  about-1,500-byte depth (`LocationWalkTests`, supporting evidence only) and every
  check seen to fail against a mutated walk. First-use resolution is
  [prompt-free](../verification/descriptor-walk-prompt.md). The N gaps, the
  present outcomes no refusal exposes, are named with their owner in the
  [record](../verification/reveal-locations.md#what-n-could-not-observe) and closed at V by
  `target-locations-vm`. Open resolves its target by the same walk through the one
  target stage (`TargetStage.swift`) and applies the same limit before any metadata
  read; it then reads the type, application and alias flags from the resolved
  spelling, so the payload refusal holds for the resolved object at any depth. It is
  accepted at L (`OpenLocationTests`), G (`WorkspaceCompositionTests`) and N (the
  same signed-bundle suite, asking an open that is named to an unregistered
  application so nothing can open), and its record is
  [open-path-locations.md](../verification/open-path-locations.md). The supplied- and
  discovered-application stages and the receipt's executable identities are accepted as the status paragraph above records;
  release 1.0.1 is accepted as the status paragraph above records.
