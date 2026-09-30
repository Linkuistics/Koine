# Launch path: what a client written from the contract alone had to guess

The contract-only client (`clients/contract-only/`) was extended with a `launch`
command for `Mutation.workspaceLaunchApplication`, regenerated against the
introspection of the signed Koine.app serving core + desktop + workspace (schema
digest `a56a3387c7bef91758e31713fd9a7f632855c2b3a9eaaf5f8e5cce1b66d49aea`, the
workspace part being the launch root alone). This is the record of every place
that pass had to guess, infer, or could not settle from the documents it was
allowed to read.

**Read:** `docs/specs/machine.md`, `docs/specs/workspace-launch-and-open.md`,
`docs/specs/workflow-providers.md`, `docs/client-guide.md`,
`docs/adr/bearer-grants-and-live-revocation.md`, the two operations files and the
workspace SDL under `docs/design/` (the two extension-host SDL files were not
needed), everything under `clients/contract-only/`, and the two earlier client
records (only the opening of `contract-only-client-gaps.md`, for its format). **Not read:** `Sources/`, `Providers/`, `Tests/`, `Tools/`,
`Fixtures/`, `scripts/`, `.grove/`, any other `docs/verification/` file (the
workspace spec links `launch-vm.md`, `protected-path-metadata.md` and
`binary-compatibility.md`; none was followed), `docs/design/profiles/`. One
directory listing of `docs/verification/` (file names only) was made while
looking for the findings file's siblings; no file in it was opened. Nothing was
run against Koine, a VM or the host desktop: every test response is a stub
transcribed from the specs' own tables, so **no claim below was checked against
the real wire**. Where the real wire would settle a question, that is said.

Each finding has the question as it was met, where the documents were searched,
what the client does instead, and a proposal: either a repair in a named
document, with the sentence, or a decline for version 1 with the reason.

---

## F1. How to pick the served operations from a published file that lists unserved ones

**Question.** `workspace-operations.graphql` declares four mutations and one
query. The captured server serves only the launch root, so generating against
the whole file fails validation (`Cannot query field "workspaceOpenURL" on type
"Mutation"`). The task was to use `LaunchInstalledApplication` exactly as the
file has it, from where it is published, and still fail on a used operation that
does not validate. How does a client select?

**Looked.** The file's own header comments (they say what the operations
consume, nothing about being partly served); `workspace-launch-and-open.md`
"Evidence so far" (states the other three roots "are not served until their
leaves land" — a fact about this increment, not a rule for clients);
`client-guide.md` "Generating a client → Operations" (written for the desktop
file: "publishes the five a desktop client needs"; silent on a file that mixes
served and unserved operations); `workflow-providers.md` "Compatibility and
delivery" ("clients use introspection and schemaDigest to discover additions").

**Did.** `codegen.ts` names the operations the client uses
(`WORKSPACE_OPERATIONS_USED = ['LaunchInstalledApplication']`), parses the
published file with graphql-js, takes each named operation's text and the text of
every fragment it spreads (transitively), by source location, so the published
text is not re-printed, and hands that to codegen next to the whole desktop file.
A named operation the file no longer declares fails generation; a selected
operation that does not validate against the captured schema fails generation
(watched: adding `OpenSearchURL` stops codegen with the `workspaceOpenURL` error).
Operations not listed are printed to stderr with whether their root field is in
the captured schema. The alternative of selecting automatically "every operation
whose roots the server serves" was rejected: it would silently drop a used
operation the server stopped serving instead of failing.

**Proposal.** Repair in `docs/client-guide.md` "Generating a client → Operations":
"A published operations file may list operations whose roots a given server does
not serve yet. A client generates the operations it uses, by name, with the
fragments they spread, and lets generation fail if one does not validate against
the introspection it generated from; it does not validate the whole file." And
repair in `workspace-operations.graphql`'s header: one line saying which roots
are served at the time, or split unserved operations into a file per increment.

## F2. `CaptureOpenedApplication` is `DesktopChoices` under another name

**Question.** The workspace operations file publishes a query
`CaptureOpenedApplication($process: DesktopProcessIdentity!)` selecting the same
fields as `DesktopChoices` in the desktop file. Which does a launch client use,
and does the client guide's "publishes the five" still count the operations?

**Looked.** Both `.graphql` files; client guide "Operations".

**Did.** Kept `DesktopChoices` (already sent by `choices`, already validated) and
did not generate `CaptureOpenedApplication`; it is reported as "root served, not
used". The `choices --pid --started-at` path is the handoff.

**Proposal.** Repair in `workspace-operations.graphql`: replace
`CaptureOpenedApplication` with a comment "run `DesktopChoices` from
desktop-operations.graphql with the receipt's two values" (two published
operations with one body is a drift risk), or state that they are the same
operation. Also repair in `client-guide.md` so the operations list is not "the
five".

## F3. Does the client pre-validate `bundleIdentifier` / `applicationPath`, and how do provider input errors arrive?

**Question.** The spec says a blank identifier and an empty, relative or
NUL-containing path are "input errors at the original path with no `kind`,
before any inspection". Should the client check first? And is such an error HTTP
200 (execution) or HTTP 400 (variable coercion, which `machine.md` says returns
400 with no `data`)? What does "blank" mean for a whitespace-only string?

**Looked.** `workspace-launch-and-open.md` "Operations" and the outcome table
("Existing input error at original response path, no `kind`"); `machine.md`
"Errors and partial data" ("an argument a provider found invalid, reported as
input coercion") and "Local transport" ("GraphQL syntax, validation and
variable-coercion failures return HTTP 400 with `errors` and no `data`").

**Did.** No client-side check at all, so the provider's refusal is observable and
the client stays a thin pass-through; `--application-path` is sent verbatim with
no `~` or relative-path handling. The client reads both shapes: HTTP 400 is
`request-error`; HTTP 200 with a kind-less error at a non-empty path is
`input-error` (F4). Only the 200 shape is tested (from the spec's "original
response path" wording). Real behaviour for a blank or relative value was not
observed.

**Proposal.** Repair in `machine.md` "Errors and partial data": "An argument a
provider finds invalid is an execution error: HTTP 200, the original response
path, no `kind`, and the root field null when its type allows; variable-coercion
(HTTP 400) is for what the schema's scalars and non-null types reject." And in
`workspace-launch-and-open.md` define blank ("empty or only whitespace").

## F4. A kind-less error at a non-empty path: which classification?

**Question.** The client guide says such an error is an input error and "nothing
was attempted". The existing client mapped it to `failed` (its comment says it
was a request error), which for a mutation sets "outcome unknown".

**Looked.** Guide "Reading an answer"; `machine.md` error table; the old
`classification.ts`.

**Did.** Added `input-error` (path non-empty, no `kind`) with `actionEffect:
none`; an empty path with no `kind` stays `failed`, as the guide says; a `kind`
outside the four also stays `failed`, as the guide says. Documented in the
README's classification section, because the set had no way to say "nothing was
attempted" for an error.

**Proposal.** Repair in `client-guide.md`: name it: "A kind-less error at a
non-empty path is an *input error*; a client must not report it as `failed`,
because `failed` for a mutation means 'may have acted' and this means it did
not."

## F5. What classification does a response carry when a published status is accompanied by an error that suppresses its branch?

**Question.** "A published status remains authoritative if an error suppresses
its branch; a null branch with an error is not a different operation outcome."
Take `status: AVAILABLE`, `value: null`, and a capability error at
`[workspaceLaunchApplication, value]`. Is the outcome "launched" or "capability
denied"? The documents give the action's outcome (the status) and the error
independently and never say which a one-word client classification should be.

**Looked.** Spec "Results and failure boundary"; SDL descriptions of
`WorkspaceOpenResult`, `WorkspaceOperationStatus`; `machine.md` "Mutation
preflight and revocation" ("a denied output field is not evidence that the
preceding action did not occur") and "Errors and partial data" ("no precedence
among" errors).

**Did.** Two independent facts: `classification` follows the errors (most severe,
as for every command; errors are never dropped); `status` and `actionEffect`
follow the published status (`AVAILABLE` -> `acknowledged`,
`DEPENDENCY_UNAVAILABLE` -> `none`). Plus `branchSuppressed` and
`resultErrorPaths`. A `capability-denied` with `actionEffect: acknowledged` tells
a caller not to re-grant and re-launch blindly. Not observed on the real wire
(whether a publication denial can occur for a launch with both controls required
by preflight is itself unclear, F7).

**Proposal.** Repair in `workspace-launch-and-open.md` "Results and failure
boundary": "A client reports the action's outcome from `status` and reports the
errors separately. `AVAILABLE` with an error below the result means the launch was
acknowledged and part of the receipt was withheld; it is not a launch that did not
happen."

## F6. Does an execution-phase capability error at the action's own path prove the action did not start?

**Question.** For a single-action launch, `phase: execution`, `path:
[workspaceLaunchApplication]`, `data.workspaceLaunchApplication: null`. The
Machine contract says a mutation action "whose grant was revoked after preflight"
is refused as it runs, and that "if revocation commits first, that action cannot
start". Can the same error at the same path also arise from a publication check
after the action ran?

**Looked.** `machine.md` "Mutation preflight and revocation" and "Errors and
partial data"; spec authority row in Acceptance ("revoke between actions"); the
SDL's per-field "Requires workspace:control AND desktop:control".

**Did.** Reported `actionEffect: none` (the dispatch-admission reading). This is
a guess with a risk: if the root field's own publication can be denied after the
native acknowledgment, `none` would be a false "nothing happened". It is the only
place the client asserts "nothing happened" from an error whose path does not
itself prove it. Real behaviour was the thing I wanted and could not read
(`launch-vm.md`, the provider sources).

**Proposal.** Repair in `machine.md` "Mutation preflight and revocation": "A
capability error with `phase: execution` at a root action's own path means
dispatch admission refused that action: it did not start. A denial that follows
an action's acknowledgment appears only below the action's result."

## F7. The shape of a capability denial outside preflight, and whether `requiredCapabilities` is served

**Question.** Preflight (HTTP 403, `phase: authorization`) is fully described.
What do denials at execution look like (status, nested receipt fields)? Do they
carry `requiredCapabilities`? Is the feature served at all, given that the
documents disagree?

**Looked.** `machine.md` "Additional capability requirements" ("Extension —
implemented in framework minor 1"), "Errors and partial data" (the same
requirement under a heading "Workflow extension — pending implementation"),
`client-guide.md` ("Designed workflow extension, not served by 0.1.0": "New
additional-capability fields also return `requiredCapabilities`"); spec
Acceptance and Evidence ("the first unmet member and the complete set").

**Did.** Treated the feature as served (the captured schema serves the field and
the spec's Evidence lists the complete set as established for G and N). Assumed
every capability error on the field and on its nested fields, at either phase,
carries `requiredCapability` and `requiredCapabilities` (the spec says
"Revocation and publication use the same set as preflight"), and reports them per
error and, from the first capability error, at the top level. A missing or
non-string-list `requiredCapabilities` is reported as null rather than invented.
Stub transcription for the nested shape was derived from those sentences, not
observed.

**Proposal.** Repair in `machine.md` "Errors and partial data": move the
"Extension capability errors also carry the complete set" sentence out of the
"pending implementation" block and say "every capability error on a field that
has an additional requirement, at either phase and at any nested path, carries
`requiredCapabilities`". Repair in `client-guide.md`: remove "not served" and add
`requiredCapabilities` to the extensions column of the `kind` table.

## F8. `requiredCapability` versus the set: which is first, and what is the concrete set for launch?

**Question.** Which capability is `requiredCapability`, and in what order is the
set?

**Looked.** `machine.md` ("own capability first, additional capabilities in
lexical Unicode-code-point order, then argument-owner capabilities ...;
`requiredCapability` names the first unmet member in that order; `extensions.requiredCapabilities`
is the complete ordered set"); the workspace spec and workflow spec ("workspace:control
AND desktop:control", "the first unmet member and the complete set").

**Did.** Derived the order: the field's own capability is its provider's control,
`workspace:control`; the additional one is `desktop:control`; so the set is
`["workspace:control", "desktop:control"]`, which is **not** lexically sorted (a
client that sorts it, or reports only the unmet members, would be wrong). The
first unmet member depends on the grant: desktop-only -> `workspace:control`;
workspace-only -> `desktop:control`; neither -> `workspace:control`. The client
never sorts or filters the list it receives. The rule is stated in `machine.md`;
the concrete list for launch appears in no document, and "the field's own
capability" is an inference from "Root mutation fields still require their own
control".

**Proposal.** Repair in `workspace-launch-and-open.md` "Operations": add "Denial
reports `requiredCapabilities: ["workspace:control", "desktop:control"]` in that
order, with `requiredCapability` the first of them the grant lacks."

## F9. Can a client tell a `failed` that happened before submission from one after it?

**Question.** The spec lists `failed` for things that occur before any native
submission: "Filesystem access denied", unreadable bundle metadata, failure to
establish identity, "exhausted capacity refuses before submission", as well as
things after ("native error/false acknowledgment, timeout, prerequisite lost after
submission"). Is any of it distinguishable on the wire? Is a `failed` launch safe
to retry?

**Looked.** Spec "Results and failure boundary" table and "Bounded
acknowledgment"; the operations file header ("Do not replay failed opens");
`machine.md` and the client guide ("a `failed` mutation is not evidence that
nothing happened"); `extensions` for `failed` carry `reason`/`requestState` only
on management outcomes.

**Did.** Every `failed` at the action's path is `actionEffect: may-have-begun`
and `outcomeUnknown: true`; empty path (deadline or response cap) is
`unknown`. Never retried by the client. "Not safe to retry" is stated plainly by
the documents; what is missing is any way to know a particular `failed` was
pre-submission.

**Proposal.** Decline for version 1: a pre-submission discriminator on `failed`
would need a new extension field; the client's conservative treatment is correct
and cheap (a second launch request is the caller's decision, as with focus).

## F10. What a receipt with `process: null` means and what the client does next

**Question.** Does `process: null` mean the app did not launch? How common is it,
and how does a client then reach the app's windows?

**Looked.** Spec "Results and failure boundary" (null on "exit, ambiguity or
unreadable start time"; "Nullable process after acknowledgment"); "Evidence so far"
("the V run found the process null on most cold launches ... the settle is its
fix"); "Design" recovery paragraph ("when a receipt has a process, a separate
`desktopApplication(process:)` read followed by an explicit `desktopFocusWindow`");
client guide ("Koine has no lookup by name or bundle identifier").

**Did.** `process: null` with a receipt is `processState: null-in-receipt`,
`ok: true`, `actionEffect: acknowledged`: the launch was acknowledged and the
identity is simply not available. A process removed by an error is a different
state (`suppressed`). The client does not try to find the app itself after a null
(`choices --application` remains a separate client-owned route). The documents
give the null reasons but not how often a client should expect it, nor what the
client does when it needs the windows anyway: the recovery route is stated only
"when a receipt has a process".

**Proposal.** Repair in `workspace-launch-and-open.md` "Results and failure
boundary": "A null `process` after `AVAILABLE` is expected, not a failure; a
client that needs the application's windows then locates the process by its own
means (desktop has no lookup by bundle identifier) and proceeds as for any
captured process."

## F11. What a client does with a response that breaks the exclusive-branch invariant

**Question.** The spec says to "validate this invariant at public GraphQL" and
"a null root always has an execution/input error for these four fields". What does
a client do when it sees a null root with no error, both branches, neither branch,
an unknown status, or a malformed `process`?

**Looked.** Spec "Results and failure boundary"; `machine.md` ("malformed provider
output" -> `failed`).

**Did.** Classified `failed` with `contractViolation` set and `actionEffect:
unknown`, never `absent` (the earlier client's rule "null root with no error is
absence" would have been wrong here) and never `ok`. A 200 body that is not a
GraphQL response at all takes the same path. Nothing in the documents tells a
client to do this; the `machine.md` table row for "malformed provider output"
supports it in spirit.

**Proposal.** Repair in `workspace-launch-and-open.md` "Results and failure
boundary": "A client that finds the invariant broken reports `failed`; a null root
for these fields is never absence."

## F12. Timing and acknowledgment semantics

**Question.** What do `sentMs` and `receivedMs` measure, what should a client
expect from them, and what client-side timeout is right?

**Looked.** Spec "Bounded acknowledgment" (three-second acknowledgment wait,
five-second core ceiling; "earlier root actions ... may consume the request budget
first"; "the existing whole-response deadline result still applies"); `machine.md`
("execution at 5 seconds"; "a timeout after an action begins does not prove that it
failed"; a deadline is HTTP 200, `data: null`, `failed`, empty path); the client
guide (no numbers).

**Did.** `sentMs` is `Date.now()` immediately before `fetch()` is called: Node's
`fetch` does not expose the moment the request is written, so it includes
connection setup and is earlier than "written". `receivedMs` is `Date.now()`
immediately after `response.text()` resolves (the body is complete). Both are null
when nothing was sent; `receivedMs` is null for a lost answer. Kept the client's
existing 20 s request timeout because it must exceed the 5 s core ceiling or the
client reports `unknown-outcome` for what the server would have answered as a
deadline `failed`; that number is in `machine.md` only, not in the client guide.
A client cannot tell from elapsed time whether the three-second acknowledgment
bound (a `failed` at the action's path) or the five-second deadline fired: the
deadline "can also be met at an action's own path".

**Proposal.** Repair in `client-guide.md` "Mutations": "The server answers within
5 seconds (a deadline is `failed`, HTTP 200). A client timeout shorter than that
loses answers the server would have given; choose a longer one." Decline for
version 1: timing as a discriminator between the two bounds — it would add fields
the server would have to promise.

## F13. Which dependency reasons a launch can report, and whether the enum is open

**Question.** The enum has four values. Which can a launch return?
`applicationPath` naming a path that does not exist: `APPLICATION_NOT_INSTALLED`
or `PATH_NOT_FOUND`?

**Looked.** Spec "Operations" ("Missing registration/bundle is
`APPLICATION_NOT_INSTALLED`; an extant bundle with a different identifier is
`APPLICATION_IDENTITY_MISMATCH`") and the outcome table (a `PATH_NOT_FOUND` row
written for paths); SDL (closed enum, "closed reason" in descriptions).

**Did.** Reported `reason` and `guidance` verbatim as strings, treating the enum
as data, with no branch on a specific value and no action taken on the guidance
("never a shell command to execute automatically"). Stubs cover
`APPLICATION_NOT_INSTALLED` and `APPLICATION_IDENTITY_MISMATCH` only.

**Proposal.** Repair in `workspace-launch-and-open.md` "Operations" table: add a
"Reasons" column: launch reports `APPLICATION_NOT_INSTALLED` and
`APPLICATION_IDENTITY_MISMATCH` only (a missing constrained path is the former).

## F14. Is a dependency result a success?

**Question.** The contract: "a typed result, not an error", "no successful value".
The client's common field `ok` is true only for `classification: ok`.

**Looked.** Spec "Results"; `workflow-providers.md` "Dependency results and
failure classification" (a dependency is neither success nor an error kind);
`machine.md` ("They do not add a fifth error kind or overload `unavailable`").

**Did.** New classification `dependency-unavailable`, `ok: false`, empty `errors`,
`actionEffect: none`, `outcomeUnknown: false`. The documents fix that it is not an
error and not a success value; they do not say how a client's single success flag
should read it.

**Proposal.** Decline for version 1: client presentation. Optionally repair in
`client-guide.md`: "A dependency result is neither success nor an error; a client
reports it as its own outcome."

## F15. The client guide does not describe the workspace surface

**Question.** The guide is the reading path for a client. Does it cover the new
path?

**Looked.** Whole of `client-guide.md`.

**Did.** Worked from the specs instead. Gaps, each of which a reader meets: the
intro and "Contract version" describe only the 0.1.0 baseline and call workflow
providers "pending implementation" although the launch root is served; "Operations"
lists only the desktop file; the `kind` table's `extensions` column omits
`requiredCapabilities` (see F7); "Capabilities in version 1" names only the desktop
pair, while `workspace:read` and `workspace:control` now exist and a launch grant
needs `workspace:control` and `desktop:control` and no read; "What changes the
digest" does not mention that a provider bundled in the application changes it (the
digest here differs from the table's); nothing says a receipt's process identity is
copied into `desktopApplication(process:)`; "Mutations" is written around focus.

**Proposal.** Repair in `client-guide.md`: add a short "Workspace launch" section
covering: the operation file, the two capabilities, the result shape (status,
branches, errors inspected together), the receipt handoff, and the no-replay rule
for `failed` and lost answers.

## F16. Where a client gets a bundle identifier

**Question.** `launch` needs `bundleIdentifier`. How does a client know it, and can
it check it before sending?

**Looked.** Spec ("Application search ... Workspace read discovery remains to be
designed"; "The identifier names an installed app, not a display name").

**Did.** The CLI takes it literally and sends it. A client that does not already
know identifiers has no route in this contract.

**Proposal.** Decline for version 1: search is designed later; a client's own
catalogue (ModalAnyware's twelve launchers) supplies identifiers.

---

## Disposition

Every finding is repaired in the documents or declined for version 1 with its
reason, as [contract-only-client-gaps.md](contract-only-client-gaps.md) does for
the earlier client. The repairs were made by the session that ran the client, not
by its author, from the proposals above and checked against the running server
where that could settle them. "Wire" is what the signed build answered in the VM run
([launch-contract.md](launch-contract.md)); the rest is the engine's or a test's own
statement, named.

| # | Disposition | Where | Checked |
|---|---|---|---|
| F1 | Repaired | `client-guide.md` "Generating a client → Operations"; header of `workspace-operations.graphql` | The client generates `LaunchInstalledApplication` and nothing else from the file, and generation was watched failing on an operation whose root is not served. |
| F2 | Repaired | `workspace-operations.graphql` states `CaptureOpenedApplication` is `DesktopChoices` under another name, instead of deleting a published operation other documents name; `client-guide.md` no longer counts "the five" | — |
| F3 | Repaired | `machine.md` "Errors and partial data"; `workspace-launch-and-open.md` "Operations" defines blank | `WorkspaceProviderTests.aBlankIdentifierAndAnUnusablePathAreInputErrorsAtTheOriginalPathWithNoKind`: original path, no `kind`, null root. The HTTP 400 half is the existing coercion rule. |
| F4 | Repaired | `client-guide.md` "Reading an answer" names the input error; the client classifies it `input-error` | — |
| F5 | Repaired | `workspace-launch-and-open.md` "Results and failure boundary"; `client-guide.md` "Launching an application" step 3 | Engine: a nested result field is re-checked after the action, so the suppressed-branch shape is reachable; not provoked on the wire. |
| F6 | Repaired | `machine.md` "Mutation preflight and revocation" | `Engine.install`: a root mutation is admitted once, before dispatch, and never re-checked; only nested (read) fields are. The proposal's sentence is exactly that. |
| F7 | Repaired | `machine.md` "Errors and partial data" (the capability-set paragraph moved out of the pending block); `client-guide.md` | Wire: served on a preflight denial (HTTP 403, `phase: authorization`). Nested and execution-phase carriage is the engine's `annotating(_:required:)` and `AdditionalCapabilityTests`, not seen on the wire. |
| F8 | Repaired | `workspace-launch-and-open.md` "Operations" | Wire: `["workspace:control","desktop:control"]` in that order; first unmet `desktop:control` for a workspace-only grant and `workspace:control` for a desktop-only one. |
| F9 | Declined for version 1 | `client-guide.md` "What version 1 does not do" | A pre-submission discriminator on `failed` would be a new extension field the server would have to promise; treating every `failed` as possibly begun is correct and cheap. |
| F10 | Repaired | `workspace-launch-and-open.md` "Results and failure boundary"; `client-guide.md` step 6 | — |
| F11 | Repaired | `workspace-launch-and-open.md` "Results and failure boundary" | — |
| F12 | Repaired in part | `client-guide.md` "Mutations" (answers within five seconds); timing as a discriminator between the two bounds is declined for version 1 | The three-second and five-second figures are in the spec; a client cannot tell which fired from elapsed time, and promising that would add fields the server would have to keep. |
| F13 | Repaired | `workspace-launch-and-open.md` "Operations" | Wire: `APPLICATION_NOT_INSTALLED` for an identifier nothing registers. `APPLICATION_IDENTITY_MISMATCH` is the provider-local and G test's. |
| F14 | Repaired in the guide, presentation declined | `client-guide.md` step 3: a dependency result is neither success nor an error, and a client reports it as its own outcome | — |
| F15 | Repaired | `client-guide.md`: current served surface, per-build digests, both providers' capabilities, `requiredCapabilities`, a "Launching an application" section | — |
| F16 | Declined for version 1 | `client-guide.md` "What version 1 does not do" | Discovery is the later search increment's; a client's own catalogue supplies identifiers. |

## Defects found in the earlier client (not document findings)

- A 200 response whose body is not JSON was classified `ok` by the generic path
  (`transport: "response body was not JSON"`, `errors: []`). `launch` does not
  inherit it (F11) but the generic rule is unchanged; it belongs to a later
  client pass.
- The earlier comment in `classifyExecutionError` said a kind-less error is a
  request error decided before execution; it is an input error (F4). Fixed for
  the classification, and the comment replaced.

## No guess needed

Checked and unambiguous in the documents:

- Both `workspace:control` AND `desktop:control` are required for the root and for
  every nested field; neither read capability is; no reference arguments add owner
  requirements.
- Preflight refusal is HTTP 403, `errors`, no `data`, the denied action's response
  alias in `path`, `kind: permission`, `permissionClass: capability`,
  `phase: authorization`; denial precedes any resource inspection.
- Result invariant: absent an error at or below the result, exactly one of `value`
  and `dependency` is non-null, selected by `status`; a published status stays
  authoritative when an error suppresses its branch; non-null propagation can
  remove status or the whole result; a null root always has an error for these
  fields.
- A dependency result certifies only that this action submitted no domain request;
  it says nothing about earlier root actions; it is not an error `kind`.
- `AVAILABLE` is native acknowledgment, not rendered content or foreground state.
- `failed` at the action's path means effects may have begun, with no replay, and
  no alternate handler; a lost answer is an unknown outcome even if the app opened.
- `process`: `{pid, startedAt}` copied unchanged into `desktopApplication(process:)`
  under `desktop:read`; `startedAt` has the exact desktop semantics
  (`YYYY-MM-DDTHH:MM:SS.ffffffZ`); a null `process` never means PID-only identity;
  a process that no longer runs is ordinary null with no error; identity is not an
  atomic binding of the effect to the process.
- `WorkspaceProcessIdentity` is a separate GraphQL type from
  `DesktopProcessIdentity` and `startedAt` is a plain `String` there; the client
  copies the two values rather than reusing a type.
- The four closed `kind` values, the HTTP status table, the credential rules, the
  endpoint descriptor and the digest rule are as before and unchanged by workspace.
- No installed path, bundle identifier or handler metadata is in the receipt.
- Observing activation, focusing a window, or needing Accessibility for
  `DesktopChoices`' `windows` selection is a separate, client-owned step; none is a
  workspace prerequisite.
- A launch is sent once; the client's descriptor re-read is only after a
  connection failure that proves nothing was written.
