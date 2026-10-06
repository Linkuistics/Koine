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

This guide describes what a Koine serves today: the core, the bundled `desktop`
provider and, beside it, the bundled `workspace` provider's launch, URL, path and
reveal operations (["Launching an application"](#launching-an-application), ["Opening a URL"](#opening-a-url),
["Opening a document or folder"](#opening-a-document-or-folder) and ["Revealing a path in Finder"](#revealing-a-path-in-finder)). The
[workflow-provider design](specs/workflow-providers.md) names more workspace
operations than are served yet; discover what a given Koine serves from its own
introspection, never from the presence of an operation in a design document.

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

## Process identity

A client captures the application the user is interacting with **at interaction
start**, as a process identity, and resolves it with `desktopApplication`.
Finding the process is the client's job: Koine has no lookup by name or bundle
identifier.

In `koine-desktop/1` the identity is `{ pid, startedAt }`, where
`startedAt` is the kernel's start instant for that process as
`proc_pidinfo(PROC_PIDTBSDINFO)` reports it (`pbi_start_tvsec` and
`pbi_start_tvusec`; `sysctl` `KERN_PROC_PID` reports the same record as
`kp_proc.p_starttime`), compared exactly. No command-line tool reports it at
that precision, and `NSRunningApplication.launchDate` is a later instant that
never matches.

This identity is the `koine-desktop/1` contract. Capture it when the
interaction starts and pass it unchanged; Koine never falls back to the PID
alone. The [capture decision](adr/desktop-capture-preserves-the-process-incarnation.md)
records why Koine does not use a non-time identity.

Koine uses public macOS Accessibility. During process or window reuse it may
return another target's data or act on it, and a notification or closure report
may be stale or misattributed. A withdrawn reference stays unavailable and is
never reused. After a call may have run, failure or a lost response does not
prove nothing happened, so do not retry mutations automatically. The
[native targeting discussion](specs/machine.md#native-targeting-discussion)
lists these accepted limits.

An identity that names no running application — the process ended, or the pid
belongs to another process — resolves to ordinary `null` with no error. That
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
error-extension `permissionTarget` in the existing framework; search reports
its scope/reason as typed coverage data. Future error target/reason transport
needs a separately designed framework/host extension before use. Treat unfamiliar
identifiers as OS-permission refusals and show Koine's guidance; do not label them
Accessibility. Nil/blank legacy values are unspecified-consent failures; show
their guidance without inventing an identifier, as the
[failure compatibility table](specs/machine.md#provider-failure-compatibility)
requires. Existing desktop operations keep `accessibility`. Reads
never request consent. App-side API enablement is instead an integration
prerequisite, and file search reports partial/unknown coverage separately from a
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

## Searching for applications and files

**Designed, not served yet.** The selected
[path design](specs/workspace-search.md#path-design-dependencies) bounds resolution,
checks parent and child policy before opening, and preserves representable names.
Pre-open mount/symlink witnesses and replay/size-phase repairs need mandatory
producer reviews before long-path classification design/review, then the
complete-resource review/planning; long-result action support needs its own
launch/open design and review;
native allocation and
[serviceability instrument/subject construction](verification/search-serviceability.md)
are specified as design; the whole-resource review also precedes planning.
The [resource feasibility analysis](verification/search-native-resources.md)
records error-channel and observer limits. The subject design defines bounded
owned/hook events, passive NIO equivalence/loss controls and matched independent
listener/store/action outcomes; execution remains pending, with no native/binary
acceptance or reduced workflow coverage.
The [allocation scope decision](specs/workspace-search.md#native-allocation-decision)
retains single-process inspection after helper design was declined. The
[in-process observation contract](specs/workspace-search.md#in-process-observation-contract)
names actual native calls, uncertainty/refusal and worker recovery. Under
Antony's "you decide" delegation, two independent requirements decisions select
reported native metadata/registration meaning and empirical serviceability
evidence. An undetected internal failure or stale state can make registration
or another native fact incorrect; opaque allocations/peaks/internal errors remain
unproved. Nil identifier always remains UNKNOWN with affecting coverage.
Malformed/errorful/incomplete observations remain uncertain, observed resource
errors refuse negatives, and known incorrect witnesses or UNKNOWN metadata for
every configured launcher still fail. Allocation ownership and serviceability subject construction are specified;
the selected metadata call set's long-path integration remains unresolved;
implementation, execution and review remain pending; all other workflow, prompt, limit and compatibility
obligations remain binding.
Per-root FIFO breadth-first discovery and atomic
process-wide descriptor credits preserve shallow-name order and bound owned
search opens below the inherited soft limit with a non-search reserve. Their load-bearing reviews
are [required before planning](specs/workspace-search.md#discovery-obligations-before-planning).
Admission, canonical-path and cleanup repairs retain actual-adapter/default
acceptance obligations. Typed BLOCKED transport is reviewed; runtime/binary
acceptance remains pending.
Introspect for `workspaceSearchApplications` and
`workspaceSearchFiles`; do not infer availability from a release number. The
[search contract](specs/workspace-search.md), [SDL](design/workspace-search-schema.graphql)
and [example operations](design/workspace-search-operations.graphql) fix inputs,
root defaults, bounds, ranking and coverage. Both roots and every output field
need `workspace:read` only. Omitted/null roots use Koine's application directories
or home; explicit roots replace them. Application defaults additionally include
generic CoreServices and Cryptex application regions. Checked visible .app links discover canonical bundle target names/paths; they
never authorize target traversal or create alias-named application choices.
Link/direct routes merge by native bundle directory identity. Admitted roots,
frames and bundles share the
[canonical directory observation](specs/workspace-search.md#canonical-directory-observation);
file locations join a canonical parent with the observed entry name, preserving
final symlinks. Firmlink-alias roots merge equal returned paths and observed
rootIndices; requestedPath still shows supplied spelling. Cached native names
can vary: different file-location strings can name one object. Each current
listing uses a fresh reported prefix; earlier locations stay observations.
Retained app identities keep their first finalized reported name/path. Distinct native
copies with equal bundle identifiers stay distinct; each final choice retains
observed matching rootIndices under the spec's stability/observation limits.
Query matching is a literal filename substring: canonical app filename or
`.app`-stripped stem, file full filename (including the file link's own name).
Canonically
equivalent Unicode spellings must match under the specified fixed folding;
`zed` ranks `Zed.app` before `Zed Preview.app`. Complete means the declared
visible-name domain, not everything on disk. A positively absent optional home
Applications or optional Cryptex default has COMPLETE empty-domain coverage with
OPTIONAL_ROOT_ABSENT; an explicitly supplied missing root remains UNKNOWN.

Read `status`, `matches`, each root's `coverage`, `dependency`,
`resultsTruncated` and errors together. Empty matches with PARTIAL/UNKNOWN
coverage is not complete empty. After progress, searched SUBTREE means COMPLETE
eligible-domain coverage; OBSERVED_DESCENDANTS gives only counted observations
somewhere beneath that root. completedDirectories counts EOF listings, not an
unchanged snapshot. Skipped CHILD_GROUP counts invalid/publicly unrepresentable child locations of its actual parent;
the names and descendants are omitted. DESCENDANT_GROUP counts intrinsic or
depth/frontier-bound anchors beneath its root. DEPTH_LIMIT is a single reserved root
group: each depth-32 anchor itself increments the count, even an empty directory
whose EOF is not observed; names remain matchable and only descendants are omitted.
FRONTIER_LIMIT separately counts observed directory anchors whose descent tasks
cannot fit the 512-task/384 KiB traversal account. Their names remain matchable;
sibling names continue to be examined. Depth precedes frontier. Package
or symlink intrinsic anchors can also remain file matches. Neither says all children
were skipped. REMAINDER has null count and describes unfinished work with or
without progress, anchored at the resolved root or representable requested root.
No-progress stops have UNKNOWN coverage and no searched record. DIAGNOSTIC_LIMIT
means total diagnostic room (record/byte account identified in guidance);
VALUE_LIMIT means a known public/native path-size refusal, including the native
NUL-inclusive buffer boundary. Name-omitting groups require an established
unrepresentable candidate location; native descent refusal alone does not omit
a representable directory/package/bundle name. A queued ordinary directory's
known native descent refusal has VALUE_LIMIT SUBTREE at its listed location,
null count and descent-only guidance, without name withdrawal or truncation.
Depth-32 anchors and packages make no child canonical call for descent.
Successful native directory text is at most
8,191 bytes; the public returned value limit stays 8,192 bytes. Joined locations
of every file-search entry kind can use that last byte. Native-size omissions remain affecting
coverage, not accepted workflow loss; paths are never shortened or replaced
by another spelling. ENOSPC alone is size evidence, not movement; a refused
shared current/prefix check stops its root, while target-only failure under an
established unchanged parent stays exact and checked-link failure stays ENTRY.
One resolver handles every length/source with 32 link expansions, bounded
readlink/pending text and native dot/dot-dot semantics. Protected/cloud child
identities and native variant lookups are checked before child open. Exact
accounts/errors are in the spec; these calls still need no-dialog acceptance.
Same-identity spelling differences alone are not change or inspection failure.
Held-descriptor identity self-comparison does not detect movement or inode reuse;
first root/witness and unassociated link-target observations have no independent
movement detector. A failed native witness affects only dependent roots;
witness-account overflow still refuses the job before turns. Independent root budgets prevent
one root spending later roots' credits. Cyclic root turns finish shallower
admitted listings before deeper ones within each root; depths across roots can
differ. A root's 100,000-entry allowance can still cut a wide level short and omit
later names/listings at that same level. FIFO lists names once but repeats
checked component walks; those and listing-turn checks spend the shared wait.
Each current stream is revalidated before its next turn/read. A changed queued
prefix/parent stops its root once; only a changed target under an established
unchanged parent has an exact SUBTREE exception.
Queue overflow, native stalls, descriptor refusal and the shared three-second
wait can leave names unvisited. The owned search descriptor ceiling is
min(72, max(0, soft limit − 128)); each job atomically reserves roots + 2 credits.
Pre-turn worker/descriptor refusal gives every root CAPACITY_LIMIT; actual native
open failure is INSPECTION_FAILED. Lower allowance is compared with summed
surviving job reservations and refusal remains latched until cohort cleanup,
even if the limit rises. At soft limit 256 a fifth job is worker-refused;
descriptor admission binds only below 200. All reservations survive blocked-call freeze
until worker-only cleanup. Platform-internal opens and unrelated demand use
the remaining table; normally launched host serviceability requires native
acceptance. Honest partial coverage does not accept workflow omissions. Exact native
failures/invalid names can still exhaust diagnostics. Home excludes protected traversal. In an
error-free BLOCKED result, matches is null and coverage remains available. Coverage's
PROMPT_RISK object describes unattempted traversal and UNKNOWN consent, never
Accessibility or established consent absence. Absent execution errors at or above
the selected fields, BLOCKED is error-free search data,
including when choices: matches is selected: choices and dependency are null,
resultsTruncated is false, roots have no progress and UNKNOWN coverage (a
positively absent optional default retains COMPLETE empty-domain coverage), and at least
one scope carries PROMPT_RISK. Show “Scope not searched: Koine avoids an inspection
that may request consent; consent state unknown,” followed by the scope/guidance.
Do not show a healthy empty search or ask the user to acquire a named consent.
Observed missing named consent on other operations retains the permission error
and its documented identifier/guidance; an unfamiliar identifier remains an OS
consent failure directed to Koine. Legacy nil/blank identifiers are unspecified
consent errors, never a prompt-risk sentinel. With no
progress, native/identity inspection failure or work/resource refusal wins,
including CHANGED_DURING_SEARCH or uncertain inspection as INSPECTION_FAILED;
then any prompt-risk scope is BLOCKED,
then purely missing/unsupported roots have a dependency outcome. A missing root
alongside prompt risk does not turn the request into a native failure.

Error-free coverage-only queries get the same BLOCKED status/diagnostics without
selecting matches. Absent execution errors at or above selected fields, repeating
matches under two aliases returns null twice without search-generated errors;
FAILED instead raises failed at each selected alias path. Separate root aliases
are independent searches, not one shared snapshot. After any progress, AVAILABLE
may include blocked scopes in coverage without a matches error. Check GraphQL
errors before classifying any branch: revocation can null a nullable list or
propagate a denied non-null coverage/status field to the root. A surviving
status never overrides that denial, and coverage is not promised after it.
The provider can also stop between root and nested resolution: unavailable at
nullable matches may leave status/coverage beside the error; non-null failures
propagate normally. A surviving BLOCKED status never waives a lifecycle error.

Derive choices locally. An INSTALLED application with a known identifier feeds
both that identifier and `applicationPath` to the constrained launch below;
UNREGISTERED means the checked macOS observation reported no registration for
that native bundle identity; it can be wrong after an undetected internal failure
or stale service state. UNREGISTERED and UNKNOWN remain reveal/copy choices and
cannot launch by this route; a known identifier can still be copied. File paths feed
existing open/reveal operations. Null default-app metadata is unknown, not no handler.
Search classification does not pin a file or promise that opening will succeed.
The 8,192-byte search ceiling also does not establish long-result action support:
the existing action inspection uses PATH_MAX-limited calls, and overlength does
not prove an observed location absent. The
[long-location handoff dependency](specs/workspace-search.md#long-location-action-dependency)
requires a supported action-route design and review before this seam is complete.
The [native boundary and error repair](specs/workspace-launch-and-open.md#long-location-action-boundary)
is designed but unimplemented: whole/expanded size, unresolved link-budget and
unacquired-fact failures
must use failed rather than invent a missing path, app, identifier or handler.
It does not establish native long-location support. Keep paths
and selected installation constraints unchanged; no clipped path, alternate
copy, disabled-action baseline or shorter search ceiling is approved. Copy is
client-owned; long-result launch/reveal/default/Zed outcomes remain pending.
Established cycles/impossible components and completed native no-type/no-identifier
reports keep their accepted outcomes. Launch-and-open owns independently created
long action fixtures; search acceptance owns the additional actual-search
handoff. Independent long-path observers require positive controls; fixture
acceptance cannot pass search provenance. The repair is designed as action-only
release/schema 1.0.1, separately from retained 1.0.0 and search 1.1.0.
The [returned route evaluation](verification/long-action-route.md#measured-reconciliation)
leaves the supported route unresolved after the prototype and completed application research:
the tested opener APIs did not complete long actions, while relative filesystem
inspection reached the items. Arrays/descriptors do not establish another opener
handoff. Antony [retained the original requirement](verification/long-action-route.md#decision-for-antony).
The completed research and [returned disposition](verification/long-action-route.md#application-research-reconciliation)
also require real receiver access: Zed's inspected backend reads by whole path
after IPC delivery. Public legacy native item arrays do not supply an established
long acquisition/submission route. The
[completed internal diagnostic](verification/long-action-route.md#native-reference-result-and-remaining-gap)
returned references at 1,024 bytes but tested consumers rejected them; its walk
could not reach the 1,500-byte subjects. Antony accepted the result. The
[completed item-array diagnostic](verification/item-array-submission.md)
delivered exact spelling at 900/1,023 bytes through both openers; both failed
at 1,024 before recorder delivery. This passes no production action.
The [representation assessment](verification/long-action-route.md#item-array-result-and-representation-assessment)
keeps the client's observed pathname input unchanged: internal descriptor/name
lookup does not require a retained-handle protocol. Public file-reference URL
acquisition was measured in the [completed diagnostic](verification/file-reference-url-acquisition-prototype.md):
both factories pass local identity/reading/original bytes at 900/1,023 and fail
acquisition at 1,024/1,500. No long action or receiver pass follows. Long-path
support remains absolute. The [completed same-object diagnostic](verification/same-object-namespace-prototype.md)
passes local identity/marker access at 900/1,500 bytes, but long application/type
facts failed. A missed Zed trust-dialog stop leaves no compliant long receiver
or Finder-selection result. Antony accepted the incomplete report with no
retry authorized. The separately completed
[focused Zed result and returned assessment](verification/long-action-route.md#focused-zed-result-and-bookmark-question)
establish fresh reading of both original files by the exact short Zed copy after
restricted-mode choices. The long buffer shows an inode-only filename; native
application/type checks fail, exact delivery is opaque and saving is untested.
Antony authorized the finite local-only bookmark diagnostic on 2026-10-06. It
remains unexecuted and promises no Zed filename improvement. This changes no client input or accepted
production behavior; the complete route remains unresolved. External
inquiries remain unused drafts; no automatic probe series is authorized. No new actionability field,
production receiver-visible spelling change or working-case loss is approved.
Both controls are required for the later actions; selection does not confer them.
Write copied paths/known identifiers to your own clipboard and keep your own
MRU. Protected default-document opening and the application-reveal notice retain
their pending decisions described below.

Search CAPACITY_LIMIT guidance distinguishes busy admission from native
inspections disabled by a lower-limit/resource-failure cohort. A resource flag
plus one indefinitely blocked cohort call disables all new searches even with
free workers, until process restart. Opaque empty/nil metadata cannot alone
establish UNREGISTERED or absence. The selected native-result boundary allows
only the exact checked not-found or fully checked nonmatching-array branches,
without a conflicting preferred result. The finalized call/error contract
bounds copied values, shares two temporary credits serially and rechecks the
original candidate before finalization; native results still require acceptance.
Search CAPACITY_LIMIT can persist after cancellation: slots are released only
when native work and cleanup finish. If calls never return, recovery requires
restarting the Koine process; provider stop/start does not replenish the pool.
Only the worker closes its frames, after any blocked call returns; cancellation
cannot reclaim even idle streams from another thread. Queued paths and whole-job
descriptor credits also remain charged until cleanup. Four jobs hold less than
54.282 MiB including scratch, with at most 72 explicitly owned descriptors
(one stream/root plus two temporary opens/job). Atomic admission below the
effective soft limit leaves a non-search reserve; opaque platform opens and
unrelated demand still require normally launched empirical serviceability
acceptance through complete applicable owned/hook events and independent
outcomes. Opaque acquisitions and peaks remain unproved. All policy witnesses are
charged; pre-turn anchor-account failure gives every root no-progress
INSPECTION_FAILED. These are proposal/accounting ceilings, not native memory or
useful-coverage acceptance; no descriptor-limit setup is implicit.

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
   `PATH_NOT_FOUND`. The retained 1.0.0 also reports a cycle and an impossible
   component that way; those concrete outcomes remain required. Its broader
   mapping of every ELOOP/ENAMETOOLONG is defective: an unresolved finite-link
   budget or whole/expanded path-size refusal proves no absence. The designed
   1.0.1 correction returns pre-submission `failed` for those uncertainties and
   preserves established cycle/name-limit absence. It is pending the
   [long-location route](specs/workspace-launch-and-open.md#long-location-action-boundary).
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
6. **Protected folders.** Asking the system for the default application of a *document* in
   Desktop, Documents or Downloads can raise a Files and Folders prompt for Koine that
   Koine does not request (a folder's lookup did not in the measurement). Whether and how to open protected
   documents in their default application is undecided; until it is, name an application
   for them.
7. **The receipt names an application, not a document.** `value.process`, when present, is
   the application that was asked to open the item (the default handler or the one you
   named). It names no window or document, may be null, and says nothing about whether the
   item rendered. Long-app executable identity reads are separately pending;
   systematic length-caused null is not an accepted loss of the desktop handoff.
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
   The same pending 1.0.1 correction applies here: established cycles and
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
