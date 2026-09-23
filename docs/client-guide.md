# Writing a Koine client

This is the reading path for anyone writing a program that talks to Koine: a
script, an LLM agent's tool, or an application with its own Machine client. The
[contract](specs/machine.md) is authoritative and this guide never overrides it;
what the guide adds is the order to read it in, the facts a client needs that
the contract states far apart, and the answers to every question a client
written from the contract alone had to guess
([contract-only-client.md](verification/contract-only-client.md)).

Nothing here is specific to one client. A client that follows it needs no
knowledge of Koine's source.

## Contract version

| | |
|---|---|
| Contract | `koine-desktop/1` |
| Schema digest | `ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf` |
| Served by | Koine 0.1.0 with its bundled `desktop` provider and no per-user provider |
| Evidence | [schema-conformance-vm.md](verification/schema-conformance-vm.md) |

**Before the first public release this digest will change.** The process
identity a client submits, `DesktopProcessIdentity.startedAt`, is being replaced
by a mechanism that does not depend on time (see "Process identity" below), and
that changes the schema. A client should read the digest it generates against
from the Koine it generates against, as described next, rather than copy it from
this table.

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
- a per-user provider installed or removed on that Mac, which adds or removes its
  own types and root fields — two Macs running the same Koine can serve
  different digests;
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

**The user creates it** in Koine's window and gives it to the client, which is
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
   Koine's window shows. Treat it as an opaque string.
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
`<providerId>:read` and `<providerId>:control` — for the bundled provider,
`desktop:read` and `desktop:control`. `Koine.availableCapabilities` lists them,
under a grant. A name that is not available is refused when the request is
submitted (`failed`, "Unknown capabilities"), so a misspelling is never put to
the user. A client that uses the desktop path normally asks for both desktop
capabilities; `koine:manage` lets its holder issue and revoke every other grant,
and the user is warned before approving it.

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
  `InspectOwnConnection`. They are the handoff's path, not the whole schema. A
  client may write its own; in particular, the application's `ref`, `name` and
  `bundleIdentifier` resolve without Accessibility consent, but `DesktopChoices`
  also selects `windows`, which does not, so without consent that operation
  returns no application at all. Management operations (`koineManagement`,
  approving, revoking) are published by no operations file: a client that does
  not hold `koine:manage` cannot use them, which is why a client cannot approve
  its own request.

## Process identity

A client captures the application the user is interacting with **at interaction
start**, as a process identity, and resolves it with `desktopApplication`.
Finding the process is the client's job: Koine has no lookup by name or bundle
identifier.

In `koine-desktop/1` as served today the identity is `{ pid, startedAt }`, where
`startedAt` is the kernel's start instant for that process as
`proc_pidinfo(PROC_PIDTBSDINFO)` reports it (`pbi_start_tvsec` and
`pbi_start_tvusec`; `sysctl` `KERN_PROC_PID` reports the same record as
`kp_proc.p_starttime`), compared exactly. No command-line tool reports it at
that precision, and `NSRunningApplication.launchDate` is a later instant that
never matches.

**This is being replaced before Koine's first public release**, because an
identity made of time cannot guarantee that two processes never collide. The
replacement is designed in `process-identity-without-time` and will be stated in
the spec; a client should expect this section, the input type and the digest to
change, and should not build more on `startedAt` than it has to.

The agreed replacement captures the frontmost application when the client's
native callback executes, preserving the original
OS process lifetime. A public process serial number plus boot identity cannot
replace the timestamp: automatic termination can restore the application under
that same pair but a new process. See the
[capture decision](adr/desktop-capture-preserves-the-process-incarnation.md).

The retained-native candidate also has an unresolved action boundary:
[a VM experiment](verification/retained-ax-binding.md) showed a held AX window
acting on a replacement process after actual PID reuse. Treat the native
replacement as unfinished; a task right plus retained AX objects is not an
approved client protocol.

The agreed future effect contract is **endpoint addressing only**. Koine keeps
using the endpoint admitted for the captured process; it does not guarantee
permanent receiver ownership or safe handler/downstream behavior. Receiver
movement, descriptor reuse, forwarding or queued activation may affect another
process, including a restored successor. Capture/reference expiry still follows
the original process. The future operation will expose a focus attempt and
separate request acceptance from an observation; a lost/failed response does not
prove that nothing happened. Do not retry automatically.

No shipping mechanism, lifecycle policy, restart policy or version agreement is
supplied by this choice. The direct adapter and first public release remain
unresolved. The capture decision records the evidence and remaining obligations.

The [native targeting discussion](specs/machine.md#native-targeting-discussion)
states the agreed future contract and its limits. The timestamp schema and focus
receipt documented elsewhere in this guide still describe the served behavior;
they are not the new operation or permission to assume the old exact-target
promise from the future API.

An identity that names no running application — the process ended, or the pid
now belongs to another process — resolves to ordinary `null` with no error. That
is the same answer a client gets for a process that is not an application, and
the contract deliberately does not tell them apart: each is "that application is
not running".

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
| `permission` | Refused for want of authority | `permissionClass`: `capability` (the client's grant lacks it; `requiredCapability` names it when there is one, and `phase` is `authorization` when preflight refused the operation or `execution` when a field was refused as it ran — a read, or a mutation action whose grant was revoked after preflight) or `os-permission` (Koine lacks the user's consent; `osPermission` is `accessibility`, `permissionOwner` is `koine`) |
| `unavailable` | The target is gone, or the reference is not one this provider produces | none |
| `unknown-provider` | A reference names a provider that is not registered | none |
| `failed` | The operation was attempted and did not succeed | `reason` and `requestState` on the management outcomes the spec's table lists |

An error with a non-empty `path` and **no** `kind` is an input error a provider
found in an argument — a `startedAt` in any other form than the one above, a
`pid` that is not positive — and nothing was attempted; the client's request was
wrong. A `kind` outside these four is not served by this contract; a client that
meets one, or an error with an empty `path` and no `kind`, classifies it as `failed`, which
asserts nothing about the resource.

Three rules make these usable:

- **A root lookup that is null with no error is absence**; a root lookup that is
  null with an error is that error, whatever path the error carries — a denied
  non-null field discards its nearest nullable parent, so the error's path may be
  deeper than the null.
- **Tell `os-permission` from `capability`.** The first is sent to the user with
  directions to give *Koine* Accessibility consent in System Settings; a client
  never asks for that permission itself. The second is the client's grant, which
  the user changes in Koine.
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

A `failed` mutation may still have acted. A `failed` error with an **empty
`path`** and `data` null means the operation passed its deadline or its response
exceeded the size limit, and any action in it may have run. A `failed` error at
the action's path can be a provider step that failed — and a focus that fails
after activating the application has still brought it forward — but also a
deadline reached as the action started, or a grant store Koine could not read.
So a client reports every `failed` focus as "not confirmed", not as "did
nothing".

## What version 1 does not do

These were asked for by a client written from the contract alone and are
declined for `koine-desktop/1`, because each changes the served schema or its
behaviour after the release evidence was taken. They are candidates for a later
contract version, not promises:

- an example value or `@specifiedBy` on `DesktopProcessStart` and `Reference`
  (the grammar and the mapping are stated above instead);
- `extensions.kind` as a schema enum (the closed table above is the contract);
- a distinct `kind` for the caller-fixable enrollment outcomes, which stay
  `failed` and are told apart by `extensions.reason`;
- a marker on deadline and response-cap errors (an empty `path` identifies most
  of them, and a client treats every `failed` mutation as unconfirmed);
- `availableCapabilities` readable without a grant (the version-1 set is stated
  above).
