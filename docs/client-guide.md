# Writing a Koine client

<!-- tc: pending because this document has hundreds of findings; a section converts when an edit touches it -->

This is the reading path for anyone writing a program that talks to Koine: a
script, an LLM agent's tool, or an application with its own Machine client. The
[contract](specs/machine.md) is authoritative and this guide never overrides it;
what the guide adds is the order to read it in, the facts a client needs that
the contract states far apart, and the answers to every question a client
written from the contract alone had to guess
([contract-only-client.md](verification/contract-only-client.md)).

Nothing here is specific to one client. A client that follows it needs no
knowledge of Koine's source.

<!-- tc: on -->

This guide describes what a Koine serves today. Koine serves the core and the bundled `desktop` provider. Beside them, it serves the launch, URL, path and reveal operations of the bundled `workspace` provider (["Launching an application"](#launching-an-application), ["Opening a URL"](#opening-a-url), ["Opening a document or folder"](#opening-a-document-or-folder) and ["Revealing a path in Finder"](#revealing-a-path-in-finder)). The [workflow-provider design](specs/workflow-providers.md) names more workspace operations than Koine serves yet. Discover what a given Koine serves from its own introspection. Never infer it from an operation in a design document.

<!-- tc: pending because this document has hundreds of findings; a section converts when an edit touches it -->

## Contract version

| | |
|---|---|
| Contract | `koine-desktop/1` |
| Schema digest | `a56a3387c7bef91758e31713fd9a7f632855c2b3a9eaaf5f8e5cce1b66d49aea` |
| Served by | the signed Koine with its bundled `desktop` and `workspace` providers and no per-user provider |
| Evidence | [schema-conformance-vm.md](verification/schema-conformance-vm.md) |

The digest is per build, because the providers a Koine bundles are part of the
schema it serves. Koine 0.1.0, which bundled `desktop` alone, served
`ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`, and a host that
serves `desktop` with the candidate diagnostics and no `workspace` serves
`fc0611aec9aec32896c16a2634c7953ac30f418bec662fa3dc8cbbe95b0455dd`; each is one of
the three [profiles](design/profiles/) `task conformance` holds a host to.

A client should read the digest it generates against from the Koine it generates
against, as described next, rather than copy it from this table.

### How a client knows it is talking to a compatible Koine

1. **The descriptor's `contractVersion`** is the contract this Koine serves. A
   client that does not target that exact string must not proceed; that is an
   incompatible service, which the client reports as such, not as unavailability
   or as a refusal.
2. **`Query.koine { contractVersion schemaDigest }`**, under any active grant,
   says the same over the connection, and gives the digest of the complete schema
   this Koine serves.
3. **A client records the digest it was generated against**, and compares.
   Equal digests mean the schema is exactly the one the client was generated
   from. Unequal digests under the same contract version mean the client should
   introspect again and regenerate; its operations may well still work, and a
   contract version is what promises that they do.

A client never recomputes the digest from introspection: introspection does not
carry declared order, and the digest does. The spec's "Schema digest" defines it.

### What changes the digest without changing the contract

The digest is an equality token over the whole served schema, so it moves for
things a client's operations never notice:

- a changed description of any type, field, argument or enum value (the
  schema's own description is not digested);
- a provider bundled in or left out of the application, or a per-user provider
  installed or removed on that Mac, which adds or removes its own types and root
  fields — two Macs running the same Koine can serve different digests;
- an additive, optional field in a provider's schema;
- a Koine upgrade whose printer changed, even with the schema unchanged.

Removing a field, changing an input or a nullability, or changing a meaning is a
contract change and gets a new contract version; within `koine-desktop/1` it does
not happen. The spec's "Native extensions" states the rule.

## Finding Koine

Read `~/Library/Application Support/Koine/endpoint.json` when connecting and
again after a connection fails. It is a JSON object:

| Field | JSON type | Use |
|---|---|---|
| `descriptorVersion` | number, `1` | The file's own format. A client that does not know the value must not use the file. |
| `instanceId` | string | Distinguishes runs of Koine (below, "References"). Not authentication. |
| `pid` | number | Koine's own diagnostic. A client cannot take Koine's instance lock, so it can never know whether `pid` is still Koine's; ignore it. |
| `port` | number | The loopback port. |
| `path` | string, `/graphql` | The only request target. |
| `contractVersion` | string | See above. |

Build the URL yourself as `http://127.0.0.1:<port>/graphql`; never take a host or
scheme from the file. A missing file, or one Koine left while it was not running,
is **service unavailable**: Koine is not running, and a client does not launch
it. After a connection failure, read the file once more; if the port changed,
reconnecting is correct, and if it did not, a retry is only the same failure
again. A client never replays a mutation automatically ("Mutations", below).

Use an ordinary non-browser HTTP client. Koine refuses any request carrying an
`Origin` header, including `Origin: null`, and any `Host` other than the literal
`127.0.0.1:<port>`; a browser-shaped HTTP stack that adds those cannot be made to
work. Send `POST`, `Content-Type: application/json`, one GraphQL request object
per request, and `Accept: application/graphql-response+json`. Follow no
redirects; Koine sends none.

## Credentials

A client obtains a credential in one of two ways, and presents it as
`Authorization: Bearer <credential>` on every request afterwards.

**The user creates it** in Koine's settings window (Settings… in its menu bar item) and gives it to the client, which is
simplest for a script. Koine shows it once.

**The client requests it** ("Client-requested grant" in the spec, and README's
"Client-requested grants" for the full sequence):

1. Generate 32 random bytes and encode them as unpadded base64url: that is the
   credential. Keep it, and send the SHA-256 of the 32 **bytes** — not of the
   base64url text — as 64 lower-case hexadecimal digits to `koineRequestGrant`
   with a label and the capabilities wanted. A digest of the text enrols, and
   the credential then never authenticates.
2. **Send enrollment with no `Authorization` header.** Enrollment is anonymous.
   A header naming no live credential is HTTP 401, and one naming a live grant or
   a pending, denied or expired request is refused as `permission`; neither ever
   becomes enrollment. Without a header, anything but a well-formed operation
   whose only root action is `koineRequestGrant` is 401, including one that fails
   validation. Two exceptions: enrollment whose variables do not fit the
   operation is 400, and every anonymous enrollment spends the rate budget
   before it is validated, so over budget even a malformed one is 429.
3. Show the user the returned comparison code, so they can compare it with what
   Koine's settings window shows. Treat it as an opaque string.
4. Poll `koineGrantRequest` **with** the credential as the bearer. Before the
   user decides, after a denial and after expiry, the credential authenticates
   for that one query and nothing else: every other operation is refused, and that is not a
   failure of the client. Once the request is `APPROVED`, the same credential is
   the grant.

A lost enrollment response is recovered by sending the identical request again,
which returns the original receipt. Sending it again with a different label or
capability set is `enrollment-conflict`. A retry spends the anonymous rate budget
like any enrollment and can meet 429, and once the request's status is past its
seven-day retention any retry is `credential-in-use`: start again with a fresh
secret.

**Capabilities** in version 1 are `koine:manage` and, for each active provider,
`<providerId>:read` and `<providerId>:control` — for the bundled providers,
`desktop:read`, `desktop:control`, `workspace:read` and `workspace:control`.
`Koine.availableCapabilities` lists them, under a grant. A name that is not
available is refused when the request is submitted (`failed`, "Unknown
capabilities"), so a misspelling is never put to the user. A client that uses the
desktop path normally asks for both desktop capabilities; a client that launches
applications asks for `workspace:control` **and** `desktop:control` and needs no
read capability (["Launching an application"](#launching-an-application));
`koine:manage` lets its holder issue and revoke every other grant, and the user
is warned before approving it.

Store the credential in the Keychain; a script may use a file only its user can
read. Koine cannot show it again: a lost credential is replaced by revoking its
grant and making another.

## Generating a client

Standard GraphQL code generation works from Koine's introspection.

- **Introspection options.** Koine answers `getIntrospectionQuery` with
  `descriptions`, `specifiedByUrl`, `directiveIsRepeatable`,
  `schemaDescription` and `oneOf`. It does **not** answer
  `inputValueDeprecation`, which fails at `__InputValue.isDeprecated`; nothing
  in the contract is deprecated, so a generator loses nothing by leaving it off.
  `task conformance` asks for the same fields.
- **Record the digest.** No code generator reads `Koine.schemaDigest`, because it
  is an ordinary field, not part of introspection. A generating step reads
  `{ koine { schemaDigest } }` over the same connection as the introspection it
  generates from, and stores it beside the generated code.
- **Scalars.** `Reference` and `DesktopProcessStart` are strings on the wire and
  carry no `@specifiedBy`; map both to a string type. A `Reference` is opaque
  (below). `DesktopProcessStart` is exactly `YYYY-MM-DDTHH:MM:SS.ffffffZ`.
- **Operations.** [`desktop-operations.graphql`](design/desktop-operations.graphql)
  publishes the five a desktop client needs: `DesktopChoices`,
  `FocusDesktopWindow`, `RequestDesktopGrant`, `PollOwnGrantRequest` and
  `InspectOwnConnection`;
  [`workspace-operations.graphql`](design/workspace-operations.graphql) publishes
  the workspace ones, of which `LaunchInstalledApplication`, `OpenSearchURL` and `OpenDocumentOrDirectory` are served today. They
  are the published paths, not the whole schema. A published operations file may
  list operations whose roots a given Koine does not serve yet, so a client
  generates the operations it uses, by name, with the fragments they spread, and
  lets generation fail if one does not validate against the introspection it
  generated from; it does not validate the whole file, and it does not select
  "whatever validates", which would silently drop an operation Koine stopped
  serving. `CaptureOpenedApplication` is `DesktopChoices` under another name: send
  either. A client may write its own; in particular, the application's `ref`, `name` and
  `bundleIdentifier` resolve without Accessibility consent, but `DesktopChoices`
  also selects `windows`, which does not, so without consent that operation
  returns no application at all. Management operations (`koineManagement`,
  approving, revoking) are published by no operations file: a client that does
  not hold `koine:manage` cannot use them, which is why a client cannot approve
  its own request.
- **Capability disclosures.** `koineManagement.capabilityDisclosures` lists, per
  capability that has one, the plain text a person must see where the capability is
  granted or held (today `workspace:control`). A client that creates, approves or
  lists grants shows it beside the capability, and does not decide that a capability
  without an entry is harmless: only the capabilities a catalogue entry exists for
  have been described. A host that predates the field answers the query with a
  GraphQL error, which is not "nothing to disclose".
- **Provider status.** `koineManagement.providers` has one row per discovered
  provider candidate, so a provider identity can have several rows: the copy
  running, and every copy that was refused or passed over. `candidateId`,
  `origin` (`BUNDLED` or `PER_USER`), `selection` (`SELECTED`, `NOT_SELECTED` or
  `UNAVAILABLE`), `selectedCandidateId` and `reason` are nullable and additive;
  group rows by `provider` and treat `reason` as an open, stable code, showing an
  unknown one as it is. A `SELECTED` row names itself, even after a later failure.
  A row with no `candidateId` describes an enabled slot with nothing to run
  (`missing-bundled`, `no-eligible-candidate`), or a catalogue failure under the
  provider name `(unknown)`, which no provider can have. Never show a plain
  success beside a refusal the same provider has.

<!-- tc: on -->

## Process identity

<!-- tc: depart synonym-rotation because "start instant" is the glossary term for the kernel record of a process start, and launchDate is an AppKit identifier -->
A client captures the application that the user works with **when the
interaction starts**, as a process identity. Then it resolves that identity
with `desktopApplication`. The client finds the process itself, because Koine
has no lookup by name or bundle identifier.

In `koine-desktop/1`, the identity is `{ pid, startedAt }`. The value of
`startedAt` is the start instant of the process in the kernel, as
`proc_pidinfo(PROC_PIDTBSDINFO)` reports it in `pbi_start_tvsec` and
`pbi_start_tvusec`. The `sysctl` call `KERN_PROC_PID` reports the same record
as `kp_proc.p_starttime`. Koine compares the instant exactly. No command-line
tool reports it at that precision. `NSRunningApplication.launchDate` is a later
instant, and it never matches.

This identity is the `koine-desktop/1` contract. Capture it when the
interaction starts, and pass it unchanged. Koine never falls back to the PID
alone. The
[capture decision](adr/desktop-capture-preserves-the-process-incarnation.md)
records why Koine does not use an identity without the start instant.

Koine uses public macOS Accessibility to read and act on windows. For window
order and visibility alone, it also uses a private lookup that gives the window
number of a held window. That number never names a window in a reference.
During process or window reuse, Koine may return the data of another target or
act on it. A notification or a
closure report may be stale or attributed to the wrong target.

A withdrawn reference stays unavailable, and Koine never uses it again. After a call may
have run, a failure or a lost response does not prove that nothing happened.
So do not retry mutations automatically. The
[native targeting discussion](specs/machine.md#native-targeting-discussion)
lists these accepted limits.

An identity can name no running application, because the process ended or
another process now has the PID. That identity resolves to ordinary `null`,
with no error. A client gets the same answer for a process that is not an
application. The contract does not tell the two cases apart on purpose: each
means "that application is not running".

<!-- tc: pending because this document has hundreds of findings; a section converts when an edit touches it -->

## Reading an answer

The HTTP status says how far a request got, and the body says the rest.

| Status | Body | Meaning |
|---|---|---|
| 200 | `data`, perhaps with `errors` | Executed. Read `errors` whatever `data` holds. |
| 400 | `errors`, no `data` | A request error: over a limit, unparseable GraphQL, invalid against the schema, or variables that do not fit. Nothing ran. |
| 400 | none | The body was not one JSON request object (malformed JSON, empty, or a batch array). Nothing ran. |
| 401 | none; `WWW-Authenticate: Bearer` | No live credential for this operation. Nothing ran. |
| 403 | `errors`, no `data` | Refused before anything ran, as `permission` with `phase: authorization`: a mutation's capability preflight failed, enrollment was sent with a credential, or a pending request's credential asked for introspection. If Koine's grant store could not be read during preflight, the error is `failed` instead. |
| 403 | none | A transport refusal: an `Origin` header was sent. |
| 429 | `errors`, no `data`, `Retry-After` | Enrollment over its rate limit. The errors carry no `kind`. |
| 404, 405, 413, 415, 421 | none | The request was not a GraphQL request Koine accepts: wrong target, method, size, media type or `Host`. |

Every error carries `message` and `path`; `path` is an empty list when the
error belongs to no field — a request error, a 429, a deadline or response-cap
failure. Every domain error carries `extensions.kind`, which is one of exactly
four values in `koine-desktop/1`:

| `kind` | Meaning | Further `extensions` |
|---|---|---|
| `permission` | Refused for want of authority | `permissionClass`: `capability` (the client's grant lacks it; `requiredCapability` names it when there is one, and `phase` is `authorization` when preflight refused the operation or `execution` when a field was refused as it ran — a read, or a mutation action whose grant was revoked after preflight) or `os-permission` (`permissionOwner` is `koine`; `osPermission` carries the supplied consent string, `accessibility` for served desktop operations; legacy nil maps to an empty string and blanks remain unchanged) |
| `unavailable` | The target is gone, or the reference is not one this provider produces | none |
| `unknown-provider` | A reference names a provider that is not registered | none |
| `failed` | The operation was attempted and did not succeed | `reason` and `requestState` on the management outcomes the spec's table lists |

An error with a non-empty `path` and **no** `kind` is an *input error* a provider
found in an argument — a `startedAt` in any other form than the one above, a
`pid` that is not positive, a blank bundle identifier — and nothing was attempted;
the client's request was wrong. A client reports it as its own outcome and never
as `failed`: for a mutation `failed` means "may have acted", and this means it did
not. A `kind` outside these four is not served by this contract; a client that
meets one, or an error with an empty `path` and no `kind`, classifies it as `failed`, which
asserts nothing about the resource.

**Served by a Koine with the workspace provider:** a field that needs more than one
capability — a launch needs `workspace:control` **and** `desktop:control` — returns,
on every capability error for it, at either phase and at any nested path,
`extensions.requiredCapabilities`: the complete set, in a fixed order, beside
`requiredCapability`, which names the first member of that order the grant lacks. A
client that needs the whole set reads the list and asks for one adequate grant; it
never sorts or filters the list, and the order is not alphabetical (for a launch it
is `["workspace:control", "desktop:control"]`). This does not make field authority
introspectable: a client learns the set from a denial, or from the field's own
description. See the [extension error
contract](specs/machine.md#errors-and-partial-data).

**Designed, not served yet:** new operations can report other consent identifiers
in `osPermission`, still with `permissionOwner: koine`. There is no generic
error-extension `permissionTarget` in the existing framework; native discovery reports
its source/reason as typed result data. Future error target/reason transport
needs a separately designed framework/host extension before use. Treat unfamiliar
identifiers as OS-permission refusals and show Koine's guidance; do not label them
Accessibility. Nil/blank legacy values are unspecified-consent failures; show
their guidance without inventing an identifier, as the
[failure compatibility table](specs/machine.md#provider-failure-compatibility)
requires. Existing desktop operations keep `accessibility`. Reads
never request consent. App-side API enablement is instead an integration
prerequisite, and native discovery reports partial/unknown observations separately from a
complete empty result.

For desktop operations, three rules make these usable; the consent distinction
also applies to other providers:

- **A root lookup that is null with no error is absence**; a root lookup that is
  null with an error is that error, whatever path the error carries — a denied
  non-null field discards its nearest nullable parent, so the error's path may be
  deeper than the null.
- **Tell `os-permission` from `capability`.** Direct the first to Koine with its
  supplied guidance. For the documented `accessibility` consent, direct the user
  to give *Koine* Accessibility consent in System Settings. Preserve other named
  identifiers and unspecified legacy values; never relabel them Accessibility.
  A client never asks for Koine's OS permission itself. The second is the client's
  grant, which the user changes in Koine.
- **One response can carry several errors**, on different branches. The contract
  sets no precedence among them; a client that reduces them to one outcome
  chooses its own order, and should keep every error.

## References

A `Reference` is an opaque `koine://` string. Pass it back exactly as received:
never parse it, build one, or normalise it — `new URL(ref).toString()` and
similar calls change percent-escapes and case, and the result names nothing.

A window reference names a window during one run of Koine. **When the
descriptor's `instanceId` changes, every window reference the client holds is
`unavailable`**, and the client lists again. An application reference survives a
restart of Koine for as long as its process runs. A reference that no longer
names its target is `unavailable`, never another target.

## Mutations

A mutation's answer can be lost, and a lost answer says nothing about whether the
action ran. A client **never replays a mutation automatically**. It reports the
outcome as unknown, and the user or the calling program decides.

For `desktopFocusWindow` that decision is cheap: submitting the same reference
again is a new focus request, not a repair of the old one, and it re-resolves the
window as the first did. Whether to make it is the caller's choice, not the
client library's.

**Koine answers a request within five seconds** (a deadline is a `failed` answer,
HTTP 200, not a dropped connection). A client timeout shorter than that discards
answers Koine would have given, and reports a launch that ran as an unknown
outcome; choose a longer one.

A `failed` mutation may still have acted. A `failed` error with an **empty
`path`** and `data` null means the operation passed its deadline or its response
exceeded the size limit, and any action in it may have run. A `failed` error at
the action's path can be a provider step that failed — and a focus that fails
after activating the application has still brought it forward — but also a
deadline reached as the action started, or a grant store Koine could not read.
So a client reports every `failed` focus as "not confirmed", not as "did
nothing".

<!-- tc: on -->

## Arranging windows

Koine 0.5.0 serves five window layout operations of the [desktop contract](specs/machine.md#window-layout). A Koine 0.4.1 host does not serve them, so introspect the schema before you use the [operations](design/desktop-window-layout-operations.graphql).

Every frame uses screen coordinates. The unit is the point, and the origin is the top-left corner of the primary display. The x value grows to the right, and the y value grows downward. A display to the left of the primary display or above it has negative coordinates.

Call `desktopDisplays` under `desktop:read` to read the displays. Each display has a reference, a frame, a visible frame and a primary flag. The visible frame leaves out the menu bar and the Dock, so compute your layout from it.

```graphql
query DesktopDisplayList {
  desktopDisplays { ref frame { x y width height } visibleFrame { x y width height } primary }
}
```

A visible frame is null when Koine cannot establish it, as can happen during a display change. Then list the displays again. A display reference names its display while it is active. Pass it unchanged.

Call `desktopWindows` under `desktop:read` to list the windows of every application with a Dock icon on the current Space. Each row holds the window with its reference, title, application and frame. A frame is null when Koine cannot read it. Koine never invents a frame.

```graphql
query DesktopWindowList {
  desktopWindows {
    window { ref title application { ref name bundleIdentifier } frame { x y width height } }
    order
    visibility
  }
}
```

Koine links each window to an entry of the window server's list of on-screen windows. The link uses a private window-number lookup first, and then the owner and the bounds. A row with a link is `ON_SCREEN`, and its order is its place front to back. The front window has the order 0, and those rows come first. A minimised window or a window of a hidden application is `OFF_SCREEN`. Every other row is `UNKNOWN`, with a null order.

Never treat `UNKNOWN` as on screen. A window that is `ON_SCREEN` can still be under other windows. A title can contain a document name, a web page title or a message subject, so treat titles as private data.

Call `desktopWindowOnTop` under `desktop:read` to ask whether a window is on top at a screen point. Ask before you place a label on the window, for example.

```graphql
query DesktopWindowOnTopAt($ref: Reference!, $point: DesktopPointInput!) {
  desktopWindowOnTop(ref: $ref, point: $point)
}
```

The answer is `ON_TOP` when the bounds of the window in the window server's list contain the point, and no opaque window covers it there. It is `NOT_ON_TOP` when those bounds do not contain the point, another window covers it there, or the window is off screen. It is `UNKNOWN` when Koine cannot link the window.

The Dock covers only its bar, outside the visible frame of the display. A magnified Dock or a Dock folder stack can still hide a window that reads `ON_TOP`. The bounds can differ from the frame by 2 points. So a point on the edge of the frame can be `NOT_ON_TOP`. Your own label windows cover windows too, so ask before you draw your labels. A stale reference raises `unavailable`.

Call `desktopSetWindowFrame` under `desktop:control` to move and resize one window. Pass the frame in screen coordinates, with a width and a height greater than zero. A frame without a positive size is an input error, and Koine attempts nothing.

```graphql
mutation SetDesktopWindowFrame($ref: Reference!, $frame: DesktopRectInput!) {
  desktopSetWindowFrame(ref: $ref, frame: $frame) { ref }
}
```

The receipt says that the writes completed. It does not say that the window took the frame, because an application can limit its own size. Read the frame again under `desktop:read` to see where the window went. Koine does not raise the window or activate its application.

To restore a window, read its frame before you change it and keep that frame in your client. Then set it again. Koine keeps no frame history. A window reference does not survive a restart of Koine. So a stale reference raises `unavailable`, and Koine never moves a substitute window.

Call `desktopFocusDisplay` under `desktop:control` to focus a display. Pass a display reference from `desktopDisplays`.

```graphql
mutation FocusDesktopDisplay($ref: Reference!) {
  desktopFocusDisplay(ref: $ref) { ref outcome pointerMoved }
}
```

Koine raises the front window on the display and activates its application. Then it moves the pointer to the centre of the display. A window is on the display when the centre of its frame is on the display. Koine never clicks. The outcome says what Koine did with the windows:

- `WINDOW_FOCUSED`: the front window took focus.
- `NO_WINDOW`: no listed window is on the display, so Koine raised nothing.
- `FRONT_WINDOW_UNKNOWN`: Koine cannot establish the front window, so it raised nothing. A window with an unknown frame or an unknown visibility causes this outcome.
- `POINTER_BUTTON_HELD`: a pointer button was held, so Koine did nothing.

The field `pointerMoved` says whether the pointer moved. Koine checks the pointer buttons again just before the move. When a button is held then, the pointer stays where it is. The receipt names no window, so read the window list under `desktop:read` to find the focused window. A display reference that names no active display raises `unavailable`.

## Revealing the pointer

Koine 0.6.0 serves two pointer operations of the [desktop contract](specs/machine.md#pointer-and-media). A Koine 0.5.0 host does not serve them, so introspect the schema before you use the [operations](design/desktop-pointer-media-operations.graphql). Your client draws the highlight ring. Koine supplies the position and the nudge, and it draws nothing.

Call `desktopPointer` under `desktop:read` to read where the pointer is now. The position uses screen coordinates, as for window layout. Each value can have a fraction. The read needs no Accessibility consent.

```graphql
query DesktopPointerPosition {
  desktopPointer {
    location { x y }
  }
}
```

The answer is null when Koine cannot establish the position, as can happen during a display change. Then read it again. Koine never invents a position. To find the display under the pointer, find the display in `desktopDisplays` whose frame contains the point. A frame contains its top and left edges, but not its bottom and right edges. The two reads are separate, so a display change can come between them.

Call `desktopNudgePointer` under `desktop:control` to make a pointer that macOS hid visible again. Koine moves the pointer one point to the right and back, with two mouse-moved events. The pointer ends where it started.

```graphql
mutation NudgeDesktopPointer {
  desktopNudgePointer { outcome }
}
```

The outcome is `NUDGED` when Koine posted both events. It is `POINTER_BUTTON_HELD` when a pointer button was held, so Koine posted nothing. A move while a button is held would be a drag. Koine never clicks. `NUDGED` does not say that the pointer became visible, because Koine cannot detect that. The application under the pointer receives both events, and it can react to them, for example with a hover effect.

The receipt carries no position. Read the position under `desktop:read` before or after the nudge, because the nudge does not change it. Without Accessibility consent or event posting access, the nudge raises a permission error that names `accessibility`, and its message names the missing access. A failed nudge posts nothing.

## Posting media keys

Koine 0.6.0 serves the six media keys of the [desktop contract](specs/machine.md#media-keys). A Koine 0.5.0 host does not serve them, so introspect the schema before you use the [operation](design/desktop-pointer-media-operations.graphql). Your client owns the bindings of the keys.

Call `desktopPostMediaKey` under `desktop:control` to post one key, down and then up, as the matching key of an Apple keyboard sends it. A grant with `desktop:read` alone cannot post a key.

```graphql
mutation PostDesktopMediaKey($key: DesktopMediaKey!) {
  desktopPostMediaKey(key: $key) { key }
}
```

The key is one of these values:

- `PLAY_PAUSE`, `NEXT` and `PREVIOUS` go to the Now Playing app, which is often not the front app.
- `VOLUME_UP` and `VOLUME_DOWN` change the output volume of the Mac by one step.
- `MUTE` switches the mute of the output on or off.

When no app holds Now Playing, macOS can open Music for `PLAY_PAUSE` and bring it to the front. Then `NEXT` and `PREVIOUS` do nothing. No media key is a keystroke, so no key types into the front app.

The receipt names the posted key and nothing else. It does not say which app received the key or what changed, because macOS gives no public way to ask which app holds Now Playing. Without Accessibility consent or event posting access, a key raises a permission error that names `accessibility`, and its message names the missing access. A failed key posts nothing.

## Sending chords to apps

Koine 0.7.0 serves target capture and chords from the [app input spec](specs/app-input.md). A chord is one key with its modifier keys, such as Command-L. A Koine 0.6.0 host does not serve them, so introspect the schema before you use the [operations](design/input-operations.graphql). Your client owns its rows and its bindings, as Modaliser owns its app screens.

First capture a target under `input:read`. Call `inputFrontTarget` to capture the app that macOS reports as active. Call `inputTarget` with a process identity that your client captured, as `{ pid, startedAt }`. Choose your rows by the `bundleIdentifier` of the target.

```graphql
query InputFrontTarget {
  inputFrontTarget { ref name bundleIdentifier protection }
}
```

The front app is null when macOS reports none. A captured process is null when it ended, when its start instant differs, or when it is not an app. A target with `protection` set to `PROTECTED` is Koine itself, and its `ref` is null. Koine never sends a chord to itself.

Then call `inputSendKeystroke` under `input:control` to send one chord to the `ref` of the target. A grant with `input:read` alone cannot send a chord, and `input:control` alone cannot capture a target.

```graphql
mutation ReopenClosedTab($target: Reference!) {
  inputSendKeystroke(target: $target, key: T, modifiers: [COMMAND, SHIFT]) { outcome }
}
```

The key is a value of `InputKey`, which names a key position of the US ANSI layout. With another keyboard layout, the app can read another character for the same key. The modifiers are a set of `CONTROL`, `SHIFT`, `OPTION` and `COMMAND`, in any order. Koine presses the modifiers, sends the key, and releases the modifiers in the reverse order, as Modaliser does.

The app can be in front or in the background. Koine posts the chord into the event stream of the target process, so no other app receives it. Koine never brings the target to the front. An app in the background can ignore a chord, act on a window behind other apps, or come to the front. When your user expects the app in front, focus it first with a desktop operation under `desktop:control`.

The outcome `SENT` says only that Koine sent every event. It does not say what the app did. The outcome `PROTECTED_TARGET` says that the target is Koine, and Koine sent nothing. A stale or wrong-kind reference, or a process that is not an app, raises `unavailable`. Without Accessibility consent or event posting access, a chord raises a permission error that names `accessibility`. A refused chord sends nothing, so no modifier stays down.

A chord to a terminal can type and run commands, and a chord can answer a consent or security prompt of macOS. So ask for `input:control` only when your client needs it, and send only the chords of your rows. A keyboard tap of your client at the session level does not see the chord, but a tap for the target process does.

## Searching for applications and files

Raw filesystem search belongs to the client. The client chooses its traversal engine, permissions, filtering, ordering and budgets. The [native discovery design](specs/workspace-search.md) supplies special locations. It also supplies named catalogues of applications and System Settings on macOS 26+ Apple Silicon. **Koine 0.4.0 serves `workspaceSpecialLocations` and `workspaceApplications`, and nothing else of that design.** The rest of this section describes the full design, which later releases serve.

Introspect the actual schema before you use the [operations](design/workspace-search-operations.graphql). Koine has no generic predicate, root or query API and no raw-search fallback.

Call `workspaceSpecialLocations` under `workspace:read`. A grant of `workspace:control` and `desktop:control` alone cannot call it. Omit `requests` for the ten default pairs. They are HOME, Desktop, Documents, Downloads, Movies, Music and Pictures for the user. They also include the applications folder of the user, of the local domain and of the system domain.

To ask for fewer, pass one to ten distinct pairs of kind and domain. The seven account folders admit USER only. APPLICATIONS admits USER, LOCAL and SYSTEM. A refused request is an `invalidInput` error, and Koine looks nothing up.

```graphql
query StartingLocations($requests: [WorkspaceLocationRequest!]) {
  locations: workspaceSpecialLocations(requests: $requests) {
    status
    items { kind domain accountIdentifier location contentsAvailability }
    sources { source declaredDomain examined diagnostics { reason guidance } }
  }
}
```

Read each item as a fact about the account of Koine, not about your account.

The accountIdentifier is the UID of that account. A location can name a directory that does not exist. It grants no access, no listing and no consent. The contentsAvailability is always UNKNOWN. A pair can give more than one item. The system applications folder gives two.

Read the status before the items.

AVAILABLE means that every pair gave a usable value. PARTIAL means that some pair gave none or gave a value that Koine withheld. The diagnostics name NO_NATIVE_VALUE or UNREPRESENTABLE_VALUE. UNKNOWN means that no pair gave a value, and items is null. FAILED means that every value was withheld. Each selected items then raises `failed`, so omit items to read the status and the diagnostics.

Call `workspaceApplications` under `workspace:read`. It lists the applications that Spotlight has indexed on this Mac's disks, on mounted network volumes and in a remote home folder. A grant of `workspace:control` and `desktop:control` alone cannot call it. The query takes no argument.

```graphql
query Applications {
  apps: workspaceApplications {
    status
    items { applicationPath name bundleIdentifier sources }
    sources { source declaredDomain availability observations category examined diagnostics { reason guidance } }
  }
}
```

Koine 0.4.0 reads the index and nothing else. Each item has the path, the localised name and the bundle identifier that the index reports. The name and the identifier can be null. The source is always INDEXED_APPS.

Koine does not check the path. It does not resolve the path, open it or register the application. A path gives no promise that the application is installed or can launch. Two copies of one application are two items.

Filter, rank and present the items in your client. The order is the order of the index, not a ranking. This release gives no installation state, no running state and no bundle flags. Koine suppresses no helper or accessory application.

To launch a listed application, pass its bundleIdentifier and its applicationPath to `workspaceLaunchApplication`. That needs `workspace:control` and `desktop:control`. Koine resolves both again, so a changed or removed application gives a typed dependency answer. An item with a null identifier cannot be launched this way.

Read the status before the items. AVAILABLE means that the index finished its list and Koine reported every item. PARTIAL means that Koine withheld an item or set a name or an identifier to null, and the diagnostics say which. UNKNOWN means that the index finished with no item, and items is null.

Do not read UNKNOWN as an empty Mac. The index can be disabled, excluded or rebuilding. FAILED means one of four things. The index did not finish in three seconds, or it listed more than 2,048 items. Otherwise the system refused the query, or no item was usable. Items is then null, and each selected items raises `failed`, so omit items to read the status and the diagnostics.

The category completeness is always UNKNOWN, because the index can omit or lag applications. Treat the list as the applications that Spotlight knows, not as an inventory of the disk.

The paragraphs below describe the full design of the catalogue, which later releases serve. Koine 0.4.0 serves only what the paragraphs above describe.

<!-- tc: pending because this document has hundreds of findings; a section converts when an edit touches it -->

Use workspaceApplications under workspace:read, then filter/rank on the client.
Indexed metadata supplies breadth; running observations and per-identifier
registration supplement it. Source completeness is distinct from category
completeness: this is no exhaustive all-disk inventory. Inspect status, sources,
diagnostics, metadata uncertainty and GraphQL errors together. AVAILABLE/PARTIAL
has items; BLOCKED/UNAVAILABLE/UNKNOWN has ordinary null; FAILED raises failed
at each selected items alias. Nested aliases share their frozen result, but
separate root aliases may differ. A surviving status does not erase publication
or provider lifecycle errors.

Application discovery stages the complete bounded native population. A shared
population count/call/copy/deadline overflow returns FAILED with null items and
limit diagnostics; it never supplies a prefix selected by native enumeration
order. An honest failure still leaves useful discovery unmet. Source-local
metadata failures may produce PARTIAL. No all-disk inventory or three-second
completion is promised. Whole-producer review and actual populous acceptance
remain pending before this design is implemented.

Diagnostic storage is bounded separately from choices: DIAGNOSTIC_LIMIT means
additional guidance was omitted after 63 detailed records; it never discards an
otherwise valid catalogue. Source/root outcomes still include every observed
reason, including failures whose detailed record did not fit. Inspect coverage
as well as the retained guidance: the reserved record names every observed
source/reason, without the omitted item details. Saturation alone does not
truncate choices.

For presentation, inspect nullable uiElement/backgroundOnly declarations and
runningActivationPolicies. Null flags mean no explicit usable declaration;
an empty policy set means no running policy was associated with that copy.
Runtime policies can change and do not describe stopped apps. Koine suppresses
no helpers, agents or accessory apps; clients choose their filtering policy.

metadataSource distinguishes BUNDLE_RESOURCE from INDEXED_ITEM type/name/identifier
observations. BUNDLE_RESOURCE uses root resource type and the selected fixed-file/localization
plan through held directories. INDEXED_ITEM comes from an actual fixed-query item
at roots of 1,024 bytes or more; it does not prove current plist contents or bind
the index to the observed inode. INDEXED_ITEM choices keep UNKNOWN installation
state and null bundle flags. Keep their exact path/identifier and copy option.
Ordinary discovery metadata uses the explicit reader through 1,023-byte roots;
descendant total pathname length is not submitted to a whole-path reader. At
1,004…1,023 bytes the retained action's longer Info.plist path remains unsupported,
so installation state stays UNKNOWN. At 1,024 bytes the existing explicit action
handoff refuses. Neither is absence. The selected strings/loctable reader uses 128 KiB regular files, individual
affected-fact refusal and 20 MiB scoped explicit-work admission without refund.
Useful finite fit is unestablished; the consumption hold and mandatory whole
review precede implementation. Runtime internals are excluded with no heap/RSS/
peak bound; publication stays provider-owned. Actual localized/indexed-source
and selected-action qualification remain pending.

Preserve distinct copies with one identifier. For an INSTALLED selected app,
pass both bundleIdentifier and applicationPath into constrained launch; it needs
workspace:control AND desktop:control. UNKNOWN/UNREGISTERED identified choices
remain reveal/copy choices. A later action re-resolves the selected location;
a catalogue does not pin an occupant or grant authority. Never remove a failing
installation constraint or retry another copy automatically.

workspaceSettings under workspace:read reads all runtime-exposed panes and anchors
of an already-running validated System Settings process without prompting,
launching, activation or reveal. A stopped target is UNAVAILABLE, not empty.
If the client explicitly chooses preparation, workspacePrepareSettings requires
workspace:control and launches the stopped target in the background; a running
target is left alone. Its RUNNING receipt certifies process readiness only.
Query the catalogue separately; control does not imply read.

Neither RUNNING nor repeated replies proves that lazy panes/anchors are ready.
The read makes two bounded, ID-associated pane-properties/anchor sweeps, with a
100 ms minimum gap inside its three-second budget. It never loads a pane to
make discovery look complete. Valid positive choices return PARTIAL with
UNKNOWN observation/category completeness and readiness guidance; no positive
panes gives UNKNOWN/null. Empty/unestablished anchors are null, never proof of
no nested destinations. Changed anchors are detected even if pane IDs stayed
equal. Count/call/copy overflow and deadline before a complete first sweep return
FAILED/null. A confirmation timeout retains uncontradicted complete-first-map
choices as PARTIAL/TIME_LIMIT with UNKNOWN readiness, with no late update.
Clients can present positive choices and their uncertainty; an explicit
later read is a fresh observation, not automatic polling or a guaranteed remedy.
Required cold/warm useful choices still need [independent qualification](verification/native-discovery-acceptance.md#settings-cold-and-warm-qualification).

Exact-event refusal directs the user to Koine's local explaining UI. Only an
explicit human action there may request Automation consent, if useful events
need the qualified host's conditional setup. No GraphQL operation or bearer
grant can initiate it. Consent covers the Koine-host/System Settings target pair,
not just READ or REVEAL. The UI shows closed reasons and an in-flight state after
its thirty-second wait; a late answer can still change OS permission. Wait for
true return and explicitly refresh its non-prompting check, then explicitly read
or reveal again. Do not replay a pending request. After denial use Koine's guidance
for manual System Settings → Privacy & Security → Automation adjustment; a denied
reveal is not a repair route. Permission outcomes grant no Koine capability.

Native providers require a host advertising workspace-native-disclosures-v1
with corrected workspace read/control disclosures. A prior selection-aware host
refuses them as unsupported-feature before loading and can retain its action-only
provider with selected-with-refusals; it does not serve the native catalogue.

After explicit selection, workspaceRevealSetting(paneId, optional anchorName)
requires workspace:control AND desktop:control. Send those keys unchanged as
opaque exact strings; never synthesize a custom URL or AppleScript. The operation
revalidates the running fixed target, re-resolves the pane/anchor, sends no-prompt
reveal and requests activation through the fixed bundle's Launch Services open.
Lazy no-such-object in that pre-check is failed/unestablished selection with no
reveal/activation; it proves no absence, including for an MRU from a prior process.
Fresh unvisited-incarnation usefulness still needs independent qualification.
A target that exits between validation and submission can be relaunched; the
operation performs no implicit preparation and refuses an observed stopped target.
A receipt acknowledges submission, not final
visible contents; failed/late effects are ambiguous and never retry-safe.
The existing HTTP(S)-only workspaceOpenURL and filesystem workspaceOpenPath do
not accept pane IDs, anchor keys or arbitrary custom URLs.

Client-found files can use existing default/Zed open and Finder reveal under
both controls. The [v1 handoff limit](specs/workspace-launch-and-open.md#long-location-action-boundary)
remains: missing locations keep dependency outcomes; an extant literal/expanded/
resolved spelling of at least 1,024 bytes without NUL fails before handoff.
Keep longer values copyable without rewriting them. Protected default opening
and app-reveal notice stay separate pending work.

The [finite acceptance contract](verification/native-discovery-acceptance.md)
requires actual GraphQL/native binaries/signed VMs, useful launchers/Safari/Finder
and modern settings witnesses, independent dialog/hydration and serviceability
controls. All native discovery verdicts remain pending. Client raw-search
omissions and retained action captures supply no catalogue pass.

## Launching an application

`workspaceLaunchApplication` launches an installed application or asks for a running
one to be reactivated. [`workspace-operations.graphql`](design/workspace-operations.graphql)
publishes it as `LaunchInstalledApplication`, and the [workspace
spec](specs/workspace-launch-and-open.md) is the contract. What a client needs from
it, in the order it meets them:

1. **Two controls, no read.** The grant needs `workspace:control` **and**
   `desktop:control`, because bringing an application forward is an effect on the
   desktop. It needs neither `*:read` capability, and the receipt is complete
   without one. A grant with either control alone is refused before anything runs:
   HTTP 403, `kind: permission`, `permissionClass: capability`, `phase:
   authorization`, at the action's path, with `requiredCapability` naming the first
   control the grant lacks (`workspace:control` for a desktop-only grant,
   `desktop:control` for a workspace-only one) and `requiredCapabilities` the whole
   set, `["workspace:control", "desktop:control"]`, in that order. Nothing was
   inspected and nothing launched.
2. **Name the application by its bundle identifier**, never by display name. Koine has
   no lookup that turns one into the other; a client supplies identifiers from its
   own catalogue. `applicationPath` is optional and pins one installed copy; without
   it a running copy is reused.
3. **Read the result as a typed outcome.** `status` selects one of two:
   `AVAILABLE` (the native launch call acknowledged; `value` is set) or
   `DEPENDENCY_UNAVAILABLE` (nothing was submitted because a prerequisite failed;
   `dependency` is set with a closed `reason`, `APPLICATION_NOT_INSTALLED` when no
   registered application has that identifier, and a `guidance` sentence to show).
   A dependency result is not an error and not a success: it is its own outcome,
   and `errors` is empty. Read `errors` and `status` together. An error below the
   result can withhold a branch without changing the status, and `AVAILABLE` with
   an error below it means the launch was acknowledged and part of the receipt was
   withheld, never that it did not happen. A null `workspaceLaunchApplication` with
   no error, both branches, neither, or a status this guide does not name is not
   absence: it breaks the contract, and a client reports it as `failed`.
4. **`failed` means it may have happened.** An application that is installed but
   cannot be opened, a native refusal, an acknowledgment that did not come in
   three seconds: each is `kind: failed` at the action's path, and the application
   may already be starting. Do not retry, and do not try another handler; a second
   request is a new launch or a reactivation. A lost answer is the same: an unknown
   outcome, even if the application opened.
5. **`AVAILABLE` is acknowledgment, not activation.** It says nothing about what is in
   front or whether a window has drawn. A client that needs either observes it.
6. **The receipt's process is handed on unchanged.** `value.process` is
   `{ pid, startedAt }` for the launched or reactivated application, where `startedAt`
   is exactly the desktop contract's `DesktopProcessStart`. To read the application,
   copy the two values into `desktopApplication(process:)` under `desktop:read` (the
   `choices --pid --started-at` path of the contract-only client), as a separate
   request. `process` can be null after a successful launch: the application may
   have exited at once, or its start time may not have been readable. That is
   expected, not a failure, and never a licence to fall back to a PID alone; a
   client that needs the application's windows then finds the process by its own
   means. A process that no longer runs resolves to ordinary null with no error,
   which is how a client learns the application has exited. Listing its windows
   needs Koine to hold Accessibility consent, as for any window read, and without
   it `windows` is an `os-permission` refusal while the application itself resolves.

## Opening a URL

`workspaceOpenURL` opens a web URL in the default browser. [`workspace-operations.graphql`](design/workspace-operations.graphql)
publishes it as `OpenSearchURL` (the name is the search flow's use of it: the root opens any
absolute http(s) URL); the [workspace spec](specs/workspace-launch-and-open.md)
is the contract. It answers like a launch, with the same two controls and no read, the
same typed `status`, `value.process` and `dependency`, and the same reading of `failed`
(items 1, 3, 4, 5 and 6 above apply unchanged). What differs:

1. **The client builds the URL; Koine never repairs it.** The URL is one string of
   ASCII: the `URI` grammar of [RFC 3986 section 3](https://www.rfc-editor.org/rfc/rfc3986#section-3)
   with an `http` or `https` scheme (in any letter case), a host, optional query and
   fragment, valid percent escapes (`%` and two hex digits), and no credentials,
   whitespace, backslash or control character. Percent-encode UTF-8 path and query text,
   and give an internationalized host as ASCII labels (`xn--bcher-kva.example`), not
   Unicode and not percent escapes. A URL that does not fit, another scheme (`file`,
   `javascript` and custom schemes included) or a malformed one is an input error with
   no `kind`, **at the root field's own response path** (its alias if one was used, for
   example `["workspaceOpenURL"]`; the provider reports the argument it refused at the
   field, not below it). It is an execution error in an HTTP 200 answer, not an HTTP 400:
   the argument is a `String`, so nothing in GraphQL's own coercion rejects it. Nothing was
   looked up and nothing opened. Valid bytes reach the browser exactly as sent: Koine does
   not trim, normalize or re-encode them.
   - *What is accepted and refused beyond that.* A port is `*DIGIT` (empty allowed, no
     range); the host is a registered name, an IPv4 address, or an IPv6 or IPvFuture
     literal in brackets; an `xn--` label must be valid Punycode that decodes to something
     other than ASCII alone or a control character; whether a decoded label's code points
     are valid in IDNA 2008 is the browser's to decide. Characters RFC 3986 does not allow
     in a path, query or fragment (`[`, `]`, `"`, `<`, `>`, `{`, `}`, `|`, `^`, a backtick)
     are refused.
   - *Putting typed text into a query value.* Percent-encode each UTF-8 byte that is not
     an unreserved character (`A-Z a-z 0-9 - . _ ~`) as `%` and two hex digits (the grammar
     allows either case; upper case is the convention); a space is `%20`, and `%` itself is
     `%25`. `café 日本` becomes `caf%C3%A9%20%E6%97%A5%E6%9C%AC`. Do not Unicode-normalize
     typed text first.
   - *A client's own handling.* A client that exposes the operation to a person or a test
     sends the text it was given, so that the provider's refusal is what is seen; a client
     that builds URLs encodes before it calls. One that reads the URL from a file or a pipe
     sends what it read: a trailing newline is whitespace and makes the URL invalid, so it
     strips only what its caller asked it to.
2. **The default browser opens it, not an application that claims the link.** Koine finds
   the default handler of the scheme alone, then asks that application to open the URL, so
   a link another application would take as a universal link still opens in the browser.
3. **No browser is a dependency, not an error.** With no default browser registered the
   result is `DEPENDENCY_UNAVAILABLE` with `reason: NO_DEFAULT_HANDLER` (the only reason
   this operation reports) and a `guidance` sentence to show; nothing was submitted. A
   default changed after Koine resolved it neither retargets nor replays that action.
4. **Search is the client's.** Query entry, the search engine and its URL template,
   suggestions and the fallback to opening the typed query when suggestions fail stay in the
   client; Koine knows no engine, makes no search request and contacts no search service.
   Whatever a suggestion source does (refuses the connection, times out, answers
   something unreadable), the client still opens the typed-query URL: the fallback is the
   choice of what to open, made *before* the one open request, and is never a second open
   after a failed one.
5. **The receipt names a browser, not a page.** `value.process`, when present, is the
   browser that was asked to open the URL. It names no window, tab or page; a client that
   wants the browser's windows uses it as for a launch, and the browser may show the page in
   any of them. A second request is a second open: there is no idempotency key in version 1.

## Opening a document or folder

`workspaceOpenPath` opens a local file, folder or document package in its default
application or in one you name. [`workspace-operations.graphql`](design/workspace-operations.graphql)
publishes it as `OpenDocumentOrDirectory`; the [workspace spec](specs/workspace-launch-and-open.md)
is the contract. It answers like a launch, with the same two controls and no read, the same
typed `status`, `value.process` and `dependency`, and the same reading of `failed` (items
1, 3, 4, 5 and 6 of [Launching an application](#launching-an-application) apply unchanged).
What differs:

1. **The path is literal.** It is one absolute path on the machine Koine runs on: not a
   file URL, a glob, `~` or `$HOME`. Spaces and shell punctuation are ordinary characters
   and are never expanded. An empty, relative or NUL-containing path, and a blank
   `application.bundleIdentifier`, are input errors at the field's path with no `kind`;
   nothing was inspected and nothing opened. A path is an ordinary `String`, so the
   refusal is an execution error in an HTTP 200 answer, at the root field's own response
   path (its alias if one was used, for example `["workspaceOpenPath"]`), not an HTTP 400.
   Nothing in a path is trimmed, expanded, normalized or resolved before inspection: a
   leading space makes it relative (an input error), while a trailing space, a trailing
   newline or any other control character except NUL, a trailing `/`, `.` and `..`
   segments, `%`, and Unicode in either normalization form are part of the name and are
   inspected as written, so a name that does not exist is `PATH_NOT_FOUND`. A client that
   reads the path from a file or a pipe sends the text it read: a trailing newline is part
   of the name, so it names nothing unless a file really has that name, and a client strips
   only what its own caller asked it to.
2. **A missing path is a dependency, and it is reported first.** `PATH_NOT_FOUND` means
   nothing exists there or the path is a link to nothing, so nothing was submitted. It is
   decided before any application is looked up, so it is never confused with a missing
   handler, and it wins over a named application that is also missing. It says only that
   inspection found nothing openable at that spelling and nothing was submitted: a missing
   item, a link to nothing or a path below a file can report it, and an item created
   a moment later is not seen. Inspection that was denied is `failed`, never
   `PATH_NOT_FOUND`. A link cycle and a component that can never exist on its
   filesystem report it too. The retained 1.0.0 also reports every ELOOP/ENAMETOOLONG
   that way, which is a defect: a long link chain, a long but extant path or a long
   non-ASCII name proves no absence. Workspace 1.0.1 resolves the path component by component and
   returns `failed` for those instead, including an extant location too long to
   hand to an application, as the
   [long-location boundary](specs/workspace-launch-and-open.md#long-location-action-boundary)
   states.
3. **Some things are refused, as input.** After symlinks are resolved, an application
   bundle, a program (a Unix or Windows executable) and a Finder alias file are refused:
   an input error at the field's path with no `kind`, for the default and for a named
   application alike, and nothing opened. This reads metadata only. It does not prove a
   file's contents cannot run, and a replacement after the check is not seen. Ordinary
   source and script documents (`.sh`, `.js`, `.command`) are **not** refused, whatever
   their permission bits; the application you open them in decides what a script does, so
   a Terminal-bound script may run. A script with **no extension** whose executable bit is
   set is classified as a program and refused; give it a typed extension or clear the bit. A `.webloc` or `.url` document may be followed to
   another target by its handler. To show an application or an alias in Finder, reveal it
   rather than open it. The input error's `message` says which check refused the item. It
   is for a person: its wording is not part of the contract, and a client that needs to
   branch checks the payload itself first. A successfully acquired native report
   with no content type retains non-refusal; unavailable classification is
   `failed`, never a made-up no-type value that bypasses executable/alias checks.
4. **`application` is optional.** Omit it or send `null` for the default application; a
   missing one is `DEPENDENCY_UNAVAILABLE` with `NO_DEFAULT_HANDLER` and no chooser. A
   named application uses the same input and installation rules as a launch
   (`APPLICATION_NOT_INSTALLED`, `APPLICATION_IDENTITY_MISMATCH`), and a folder can be
   sent to one, such as an editor. If the named application cannot open the item, that is
   `failed`: no other application is tried and no default is changed. For a long
   target, a nil handler lookup alone does not establish no handler; the pending
   repair requires supported lookup provenance, otherwise `failed` before submission.
   An established no-identifier bundle still mismatches a named selector and can
   still be a default handler; failed identifier acquisition means `failed`.
5. **A location, not a file.** The path is submitted as written and any link in it is
   followed by the application. A file replaced between the check and the open may open
   something else or fail.
6. **Protected folders.** Opening an item in Desktop, Documents or Downloads raises a Files
   and Folders prompt for Koine that Koine does not request. Asking the system for the
   default application of a *document* there did in the measurement, and a verification run
   found that submitting the open does too: a document opened with an application named,
   and a directory opened by default or with Finder named, were each prompted on first use
   ([measured](verification/target-locations-vm.md#first-use-in-the-protected-folders)), as a
   plain program that is not Koine is. Naming an application does not avoid it. A reveal
   (`workspaceRevealPath`) never prompted. Whether and how Koine helps with that consent is
   undecided; until it is, expect a prompt on the first open of a protected item and prefer a
   reveal when selecting it in Finder is enough.
7. **The receipt names an application, not a document.** `value.process`, when present, is
   the application that was asked to open the item (the default handler or the one you
   named). It names no window or document, may be null, and says nothing about whether the
   item rendered. The two executable identities behind it are read without a length limit, so a long
   path alone never makes it null; systematic length-caused null is not an accepted loss of the desktop handoff.
   A second request is a second open: there is no idempotency key in version 1.

## Revealing a path in Finder

`workspaceRevealPath` asks Finder to show a local path: the item selected in its folder, or, for
the filesystem root, a window on the root. [`workspace-operations.graphql`](design/workspace-operations.graphql)
publishes it as `RevealPath`; the [workspace spec](specs/workspace-launch-and-open.md) is the
contract. It needs the same two controls and no read (item 1 of [Launching an
application](#launching-an-application)), has the same typed `status` and `dependency`, and the same
reading of `failed`. What differs:

1. **The receipt is the path, and nothing else.** `value.path` echoes the path you submitted, as
   written. There is no `process`, so there is nothing to hand to a desktop read, and nothing about
   Finder is disclosed. The result type is `WorkspaceRevealResult`, not `WorkspaceOpenResult`; select
   `value { path }`.
2. **`AVAILABLE` is Finder's acknowledgment, never selection.** Koine asks Finder to select the item and
   reports Finder's own yes or no. It does not look at the screen, and it adds no check of its own
   through Accessibility, a keystroke or a menu. A client that must know what Finder is showing has to
   find out for itself; the receipt does not say. A `false` from Finder is `failed`, with the effects
   possibly begun, and the request is not repeated.
3. **The path is the same literal path as for opening.** One absolute path on Koine's machine,
   with the same input errors at the field's path (empty, relative, NUL), nothing trimmed, expanded or
   resolved, and the same inspection first: a missing component, a link to nothing,
   or a path below a file is `DEPENDENCY_UNAVAILABLE` with `PATH_NOT_FOUND`,
   and nothing was submitted. Inspection that was denied is `failed`, never absence.
   The same 1.0.1 correction applies here: established cycles and
   impossible components retain PATH_NOT_FOUND, while unresolved link budgets
   and whole/expanded size refusal mean failed. Raw length alone decides neither
   absence nor actionability.
4. **Nothing is refused for being what it is.** An application bundle, a program and a Finder alias file
   are the very items to reveal rather than open: the application is selected, never launched, and the
   alias is selected itself, never resolved to its target. A symlink is selected as the link. There is no
   `application` argument and no default handler lookup.
5. **Finder missing is `APPLICATION_NOT_INSTALLED`.** If Finder is not registered as an application
   bundle when inspected, that is the dependency, and the `guidance` names Finder. It is checked after the
   path, so a missing path is reported first. The only two reasons a reveal reports are `PATH_NOT_FOUND`
   and `APPLICATION_NOT_INSTALLED`.
6. **A folder is shown in its parent.** A folder is selected in the window of the folder that holds it,
   and the filesystem root, which has no parent, is shown as a root view with nothing selected. Where
   Finder puts the window, and whether a window already open on that folder is reused, is Finder's.
7. **One request, bounded, never replayed.** The wait for Finder's answer ends after three seconds or on
   cancellation, with `failed` and the same "effects may have begun" meaning: a slow Finder may still
   show the item after the answer, and a late acknowledgment is ignored. A client does not retry; a second
   request is a second reveal.
8. **Send a clean path, and do not rely on Finder coming forward.** A path with `.` or `..` segments is
   inspected as the kernel reads it and handed to Finder as written, and Finder reads it its own way:
   in the acceptance run `/var/..` (the kernel's `/private`) showed the root with `var` selected. And
   with another application in front, an item reveal selected the item without Finder taking the
   front, while a reveal of the root brought it forward. The contract asks for neither; a client that
   needs Finder in front launches or reactivates it (`workspaceLaunchApplication` for
   `com.apple.finder`).
9. **Revealing a third-party application may raise a system notice.** In the acceptance image macOS posted
   "Koine was prevented from modifying apps on your Mac" when a third-party application bundle was
   revealed (system applications and the refusal of an open did not). The reveal worked. Whether
   that is acceptable is an open decision
   ([reveal-path-vm.md](verification/reveal-path-vm.md#the-app-management-notice)).

## What version 1 does not do

A client written from the contract alone asked for each of these;
`koine-desktop/1` does not provide them:

- a way to name a file or folder whose own name is not valid UTF-8: a path is a GraphQL
  string, so only the folder that holds it, if that is nameable, can be opened;
- an example value or `@specifiedBy` on `DesktopProcessStart` and `Reference`
  (the grammar and the mapping are stated above instead);
- `extensions.kind` as a schema enum (the closed table above is the contract);
- a distinct `kind` for the caller-fixable enrollment outcomes, which stay
  `failed` and are told apart by `extensions.reason`;
- a marker on deadline and response-cap errors (an empty `path` identifies most
  of them, and a client treats every `failed` mutation as unconfirmed);
- `availableCapabilities` readable without a grant (the version-1 set is stated
  above);
- a way to find a bundle identifier, or to ask which applications are installed: a
  launch client brings its own identifiers;
- a marker on a `failed` answer that says whether the failure came before or after
  the native call, so every `failed` launch is treated as one that may have begun;
- timing as a signal: how long a launch took does not say which bound (the
  three-second acknowledgment wait or the five-second deadline) ended it.

## Grouped refinement and retained hold

The [grouped inventory/key refinement](verification/application-metadata-grouped-storage.md) replaces complete retained key
partitions with independent linked-slab owners, while preserving the selected
reader semantics, scoped gates, every saved association and the full wire. Its
controlled local/source/two-walk enclosure still exceeds 20 MiB before other
terms; it establishes no useful fit or native pass. Earlier independent-block
numbers remain reproducible comparison. The amended private design boundary is complete; whole-producer review and the
advertisement/consumption holds remain. The [selected qualification order](adr/application-metadata-qualification-precedes-analytic-fit.md) selects ordering only.
Private construction requires the complete [eligibility conjunction](specs/application-metadata-private-qualification.md#eligibility-and-existing-qualification-sequence);
that predicate, rather than an abbreviated ordering summary, governs builds. Advertisement/downstream consumption remain held until full useful
native operands, actual complete selected responses, required witnesses and
independent serviceability qualify. Failed/refused/unknown required useful cases
and unavailable subjects keep those holds and affected acceptance work live.
Existing whole-producer review, all native G/N/V, actual full operands/response,
useful breadth and independent authority/action/Settings/disclosure/compatibility
duties remain. No repeated strict/scoped selection or new capture leaf follows.
