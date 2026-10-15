# Opening a document or folder: what a client written from the contract alone had to guess

The contract-only client (`clients/contract-only/`) was extended with one command,
`open-path`, for `Mutation.workspaceOpenPath` (published as
`OpenDocumentOrDirectory`). It was regenerated against the introspection of the signed
Koine.app serving core + desktop + workspace (schema digest
`f98a3862c3bb77417c38eef9fe4edccd16e0bf76b6f4b8fc7bdf6708190be32d`, the workspace part
being the launch, URL and path roots; the reveal root is not served). This is the
record of every place that pass had to guess, infer, or could not settle from the
documents it was allowed to read. It follows
[open-url-contract-client-findings.md](open-url-contract-client-findings.md), which
followed [launch-contract-client-findings.md](launch-contract-client-findings.md).

**Read:** `docs/client-guide.md` (whole, including "Opening a document or folder"),
`docs/specs/workspace-launch-and-open.md` (whole, "Evidence so far" included),
`docs/specs/machine.md` (the headings; "Local transport and discovery", "Mutation
preflight and revocation" and "Errors and partial data" in full; a search for
`workspaceOpenPath` and `input error`), `docs/design/workspace-operations.graphql`,
`docs/design/workspace-schema.graphql`,
`docs/verification/launch-contract-client-findings.md`,
`docs/verification/open-url-contract-client-findings.md`, and everything under
`clients/contract-only/` except `node_modules`: `src/cli.ts`, `src/adapter/`,
`codegen.ts`, `build.mjs`, `package.json`, `README.md`, `test/`, `capture/capture.json`,
and `capture/introspection.json` only through a script that listed the `Mutation`
fields and their argument types. **Not read:** `Sources/`, `Providers/`, `Tests/`,
`Tools/`, `Fixtures/`, `scripts/`, `.grove/`, any other `docs/verification/` file,
`docs/design/profiles/`, `docs/adr/`, `docs/design/desktop-operations.graphql`. Nothing
was run against Koine, a VM or the host desktop, and nothing was opened: every Koine
answer in the tests is a stub transcribed from the specs' own tables, and the only
thing taken from a real Koine is the captured schema (introspection and its digest).
**No claim below was checked against the real wire**; where the real wire would settle
a question, that is said.

One observation about the reading restriction itself, as the earlier passes made it.
The workspace spec is an allowed document, and its "Evidence so far" section is part of
it. That section records behaviour the normative sections and the guide do not state
(which spellings are input errors, what else is `PATH_NOT_FOUND`, that each refusal
"names its own reason"). It was read, since the file was whole, and none of it was used
to decide what the client sends. Where a finding or a test below rests on a fact that
appears only there, the finding says so (F1, F4, F5, F6, F9).

The client guide now has a section for this root ("Opening a document or folder"), and
it answers most of what the earlier passes had to guess: the root's own response path
and HTTP 200 for the input error, the three refused payload classes, the order of
`PATH_NOT_FOUND` against a missing application, the optional `application`, the
protected-folder limit. None of those is a finding here; they are listed at the end
under "No guess needed".

Each finding has the question as it was met, where the documents were searched, what
the client does, and a proposal: either a repair in a named document, with the
sentence, or a decline for version 1 with the reason. The disposition table at the end
gives the recommendation for each. No document was changed by this pass except the
client's own README and this file.

---

## F1. What exactly is a path, beyond "empty, relative or NUL-containing"?

**Question.** The guide says a path is "one absolute path ... not a file URL, a glob,
`~` or `$HOME`. Spaces and shell punctuation are ordinary characters and are never
expanded", and that an "empty, relative or NUL-containing path" is an input error. It
does not say what happens to the cases a harness will try next: a trailing newline or
other control character that is not NUL, leading or trailing spaces, a trailing `/`, `.`
and `..` segments, repeated slashes, a percent sign, a decomposed (NFD) accent against a
composed one, a very long name. Is each of these literal text that is inspected as
written (so usually `PATH_NOT_FOUND`), or an input error?

**Looked.** Guide "Opening a document or folder" item 1; spec "Operations" ("Paths are
literal absolute paths ... Reject empty, relative and NUL-containing paths, and a blank
identifier ... spaces and shell punctuation remain literal"; Unicode normalisation is
mentioned only for comparing application copies); the outcome table; "Input boundary".
**Only in "Evidence so far":** "an empty, relative, `~`, `$HOME`, `file:`-URL,
leading-space or NUL-containing path ... Spaces, shell punctuation, percent signs,
Unicode and `..` are submitted as written and inspected as written", and a path below
a file, a file addressed with a trailing `/` and a name too long to exist are
`PATH_NOT_FOUND`. A leading space follows from "relative"; the rest is stated nowhere
normative. A control character other than NUL, a trailing newline in particular, is
stated nowhere at all.

**Did.** Nothing client-side: no check, trim, expansion, `realpath`, absolute-path
conversion, normalisation or encoding. The text goes into the one variable
byte-for-byte. The tests send twenty spellings (empty, relative, `~`, `$HOME`, a file
URL, a leading and a trailing space, trailing LF and CR LF, a tab, a glob, shell
metacharacters, non-ASCII with an emoji, an NFD accent, percent text, a trailing `/`,
`//` with `.` and `..`, 5000 characters, `--looks-like-an-option`, an application
bundle) and assert that each is sent once and unchanged and echoed in `path`; the stub
answers an input error to all of them, so that assertion is about what the client sent,
not about what Koine would answer. The question matters because a client that "tidied"
any of these would change which item is opened.

**Proposal.** Repair in `client-guide.md` "Opening a document or folder" item 1, one
sentence: "Nothing in a path is trimmed, expanded, normalized or resolved before
inspection: a leading space makes it relative (an input error); a trailing space, a
trailing newline or any other control character except NUL, a trailing `/`, `.` and
`..` segments, `%`, and Unicode in either normalization form are part of the name and
are inspected as written, so a name that does not exist is `PATH_NOT_FOUND`." (If any
of these is an input error instead, say which.) Move the corresponding facts out of
"Evidence so far" (see F9).

## F2. A file name that is not valid Unicode cannot be named

**Question.** A macOS path is a sequence of bytes and a file's name need not be valid
UTF-8. The path argument is a GraphQL `String!`, carried in JSON. Can a client open such
a file at all?

**Looked.** Guide item 1; spec "Operations"; the SDL (`path: String!`). No document
mentions it.

**Did.** `--path-file` reads the file's bytes with a fatal UTF-8 decoder: a file that is
not valid UTF-8 sends nothing and prints `classification: failed` with a `clientError`
(the shape the URL command uses), never a repaired string (U+FFFD would name another
file). `--path` takes the argument as the runtime decoded it. The tests send five
non-UTF-8 files (an invalid byte, a truncated sequence, an overlong NUL, an encoded
surrogate, a Latin-1 name) and assert no request was made. Whether the provider could
have opened a file whose name is not Unicode is unknowable from the documents, and a
client cannot ask.

**Proposal.** Decline for version 1: the contract names paths with GraphQL strings, so
a path that is not valid Unicode is outside it. One sentence in "What version 1 does
not do" would save a harness author the search: "a file whose name is not valid UTF-8
cannot be named by a path; open its folder, or reveal it."

## F3. A path read from a file or a pipe: does its trailing newline belong to it?

**Question.** The guide's URL section settles this for a URL ("a trailing newline is
whitespace and makes the URL invalid, so it strips only what its caller asked it to").
That reasoning does not carry over to a path: a trailing newline is not invalid in a path
as far as any document says, it is a character of the name. A file written by
`echo /tmp/x > f` names `/tmp/x\n`. Does a client that reads a path from a file strip
it, and what happens if it does not? The path section has no equivalent sentence.

**Looked.** Guide item 1 ("Valid bytes ... exactly as sent" is said of URLs only) and
the URL section's "A client's own handling"; spec "Paths are literal"; F3 of the URL
findings.

**Did.** `--path-file` sends exactly the file's text: a trailing LF or CR LF, leading and
trailing spaces, a NUL byte, non-ASCII text and a byte order mark are part of the path.
Twelve file shapes are tested, each sent once and echoed exactly, including a NUL byte
inside and at the end (an argument cannot carry one, which is why the file form exists)
and a file that is only a newline. A file made by `echo` therefore asks for a path
ending in a newline, and the provider answers whatever it answers. The alternative
(strip one trailing newline) is friendlier but is a repair the contract tells Koine not
to make, hides the case a tester needs to see, and is wrong for the rare name that does
end in a newline.

**Proposal.** Repair in `client-guide.md` "Opening a document or folder" item 1 (next to
F1's sentence): "A client that reads the path from a file or a pipe sends the text it
read; a trailing newline is part of the name, so it names nothing (`PATH_NOT_FOUND`)
unless a file really has that name, and a client strips only what its own caller asked
it to." Decline a rule about files themselves for version 1: file input is a convenience
of one client.

## F4. How much does `PATH_NOT_FOUND` say?

**Question.** The guide says `PATH_NOT_FOUND` "means nothing exists there or the path is
a link to nothing, so nothing was submitted". The spec's table says "Path missing or
dangling link". May a client report "the file does not exist"? What does a caller do
with it: create the file, retry, treat it as permanent?

**Looked.** Guide item 2; spec outcome table (`PATH_NOT_FOUND`: "no action"), "After
admission, validate/inspect ... Native handler lookup can return nil for either a missing
file or missing handler; these must not be conflated", and the row "Filesystem access
denied without established consent cause | `failed`; do not infer absence". **Only in
"Evidence so far":** a path below a file, a file addressed with a trailing `/`, a
symlink loop and a name too long to exist are also `PATH_NOT_FOUND`, and a type value
the platform did not supply is `failed`, not absence.

**Did.** Every dependency reason, `PATH_NOT_FOUND` included, is reported the same way and
no more strongly than the contract's own sentence: `dependency.reason` and `guidance`
verbatim, `classification: dependency-unavailable`, `actionEffect: none` (this action
submitted no domain request), `outcomeUnknown: false`, no process, no receipt. The output
carries no field that says a path exists or does not, and the tests assert that, for all
four reasons, by key (a deliberately added `pathExists` field turned five assertions
red). A `failed` is never read as absence, including the stub for denied inspection.
What a caller may conclude beyond "nothing was submitted" is left to the caller: inspection
found nothing it could open at that spelling at that moment, which is wider than "does
not exist" (a loop, a path below a file) and says nothing about a moment later.

**Proposal.** Repair in `client-guide.md` item 2, one sentence: "It says only that
inspection found nothing openable at that spelling and nothing was submitted: a missing
item, a link to nothing, a path below a file, a link loop and a name too long to exist
all report it, and an item created a moment later is not seen. Inspection that was
denied is `failed`, never `PATH_NOT_FOUND`."

## F5. Can a client tell which refusal an input error was?

**Question.** A relative path, a NUL, a blank identifier, an application bundle, a
program and a Finder alias are all "an input error at the field's path with no `kind`".
The guide's advice differs by class ("To show an application or an alias in Finder,
reveal it rather than open it"; "give it a typed extension or clear the bit"). Is the
class machine-readable, so that a program can offer the right advice, or only text?

**Looked.** Guide "Reading an answer" (an input error is `message` and `path`; `kind`
absent) and item 3; spec outcome table; the guide's `kind` table (the
`extensions` for `failed` carry `reason` only on management outcomes). **Only in
"Evidence so far":** "each class names its own reason" (the refused-payload classes),
which does not say whether that is in `message` or in `extensions`.

**Did.** The client reports `errors[].message` verbatim and reads nothing from it: the
class of an input error is not a field of the output, and `classification` is
`input-error` for all of them. A caller that needs the class has to parse a human
sentence the documents do not promise is stable. Not observed.

**Proposal.** Decline a machine-readable reason for version 1 (it would add an
extension field the server would have to keep), and repair `client-guide.md` item 3:
"The input error's `message` says which check refused the item. It is for a person: its
wording is not part of the contract, and a client that needs to branch checks the
payload itself first."

## F6. An extensionless script with its executable bit: the spec and the guide disagree

**Question.** The spec's "Operations" says not to use "executable permission bits, to
reject ordinary source documents", and its "Input boundary" acceptance row says a source
script opens "irrespective of executable bits". The guide's item 3 says "A script with
**no extension** whose executable bit is set is classified as a program and refused".
Which does a client (or its tests) expect?

**Looked.** Spec "Operations" and Acceptance; guide item 3. The spec's "Evidence so far"
acknowledges the conflict ("the type rule above and the 'irrespective of executable bits'
row disagree there, and the rule is applied as written"), which is the only place the two
sentences are reconciled.

**Did.** Nothing: the client does not classify files, so it sends either. It affects a
harness author who writes the expectation from the spec's normative text and is then
refused by what the guide says. The guide's reading is taken as authoritative and no test
asserts either (the stubs cannot know).

**Proposal.** Repair in `workspace-launch-and-open.md` "Operations" and the "Input
boundary" row: "A file's content type decides, not its permission bits; an extensionless
file whose executable bit is set has the type `public.unix-executable` and is refused, so
'irrespective of executable bits' holds for documents with a typed extension." Then the
"Known limit" in "Evidence so far" can say it is a documented rule, not a limit.

## F7. What the receipt's `process` names for a document or folder

**Question.** The spec says the identity is "the application returned by this action's
completion callback". For a URL the guide settles that it names the browser and no tab.
For a path the application is the handler, default or named. Does the identity name the
handler application, a window or document, or Finder for a folder? How often is it null?
What may a client do with it?

**Looked.** Guide item 6 of "Launching an application" (applied "unchanged"), "Opening a
document or folder" (silent), "Opening a URL" item 5; spec "Results and failure
boundary", Operations table ("file/folder submitted to its default or named app");
SDL `WorkspaceOpenReceipt`.

**Did.** Reported exactly as for a launch and a URL: `process` copied unchanged,
`processState` one of `present`, `null-in-receipt`, `suppressed`, `no-receipt`,
`choicesArguments` handed to `choices` unchanged. Nothing is claimed about which
application, window or document it is, or about whether the document rendered. A null
`process` after `AVAILABLE` is `ok`. Not observed.

**Proposal.** Repair in `client-guide.md` "Opening a document or folder", one sentence
after the "same typed `status`, `value.process`" clause: "`value.process`, when present,
is the application that was asked to open the item (the default handler or the one you
named); it names no window or document, and may be null."

## F8. Is opening the same path twice harmless?

**Question.** The harness that runs this client re-runs commands it believes timed out.
A second `workspaceOpenPath` for the same document may be a second window, a second tab,
a second copy of an editor's buffer or nothing. The guide says never replay and a lost
answer is unknown; for a URL it adds "a second request is a second open: there is no
idempotency key in version 1". The path section does not.

**Looked.** Guide "Mutations", "Launching an application" item 4 ("a second request is a
new launch or a reactivation"), "Opening a URL" item 5, "Opening a document or folder";
spec "Do not replay"; operations file header ("Do not replay failed opens").

**Did.** Treated as not repeatable: sent once, never replayed, `unknown-outcome` on a
lost answer (tested: a connection cut after the request was written gives one request,
`actionEffect: unknown`, `outcomeUnknown: true`, with the path and application echoed).
A caller that runs the command twice opens twice; the client keeps no state between runs.
A `failed` answer is never followed by a second request (a client that replayed once was
caught by three assertions).

**Proposal.** Decline: version 1 has no idempotency key, and an application's reaction to
a second open is its own. Repair by one sentence in `client-guide.md` "Opening a document
or folder", as the URL section has it: "A second request is a second open."

## F9. Details that are normative only in "Evidence so far"

**Question.** The facts that decide F1, F4 and F5 appear only in the spec's "Evidence so
far": the spellings that are input errors (`file:` URL, leading space), the ones that are
not (`..`, percent signs, Unicode), the cases that are `PATH_NOT_FOUND` (a path below a
file, a trailing `/` on a file, a loop, a long name) and that each refused class "names
its own reason". Is that section a contract?

**Looked.** Spec "Evidence so far" ("Input boundary", "Documents, directories and
settings"); guide items 1 to 3.

**Did.** Nothing depends on it: the client classifies nothing about a path. A reader who
wanted to predict an answer (to write a test, or to build a path rather than pass one
through) would need the facts and would find them in an evidence list, which says
"exactly what was established".

**Proposal.** Repair as the URL pass's F13 did: move the accepted and refused classes into
the guide's "Opening a document or folder" items 1 to 3 (the sentences proposed in F1, F4
and F5 are the move), or say there that evidence rows are not normative.

## F10. The guide still says only the launch root is served

**Question.** Is the path root served? The guide's introduction says it describes "the
bundled `workspace` provider's launch operation", and "Generating a client" says of the
workspace operations that "`LaunchInstalledApplication` is served today". The same guide
then has full sections for the URL and path roots, and the spec's "Evidence so far" says
all three are implemented.

**Looked.** Guide introduction and "Generating a client → Operations"; spec header and
"Evidence so far"; the captured schema (the `Mutation` field list, which does contain
`workspaceOpenPath`).

**Did.** Generated `OpenDocumentOrDirectory` against the captured schema and let
validation decide, as the guide tells a client to do; "which roots does this Koine serve"
was answered by introspection, not by either sentence. Generation was watched failing for
an operation whose root is not served (`RevealPath`).

**Proposal.** Repair in `client-guide.md`: the introduction and the "Operations" bullet
should say the launch, URL and path roots are served and the reveal root is not (or drop
the list and keep the instruction to read introspection).

---

## Disposition

Proposals only: this pass changed no document except the client's README and this
file. "Recommended" is the author's recommendation; the repairs, if accepted, are for
the session that owns the documents.

| # | Recommended | Where | Evidence the recommendation relies on |
|---|---|---|---|
| F1 | Repair (one sentence) | `client-guide.md` "Opening a document or folder" item 1 | Spellings are from "Evidence so far" only; a control character other than NUL is in no document |
| F2 | Decline for version 1, one sentence | `client-guide.md` "What version 1 does not do" | GraphQL strings are Unicode |
| F3 | Repair (one sentence); file handling declined | `client-guide.md` item 1 | The URL section's sentence does not carry over to a name |
| F4 | Repair | `client-guide.md` item 2 | The wider list is from "Evidence so far" only |
| F5 | Decline a machine-readable reason; repair with one sentence | `client-guide.md` item 3 | "Names its own reason" is from "Evidence so far" only |
| F6 | Repair | `workspace-launch-and-open.md` "Operations" and "Input boundary" row | The conflict is acknowledged only in "Evidence so far" |
| F7 | Repair | `client-guide.md` "Opening a document or folder" | None |
| F8 | Decline; one sentence | `client-guide.md` "Opening a document or folder" | None |
| F9 | Repair | `client-guide.md` items 1 to 3 | This is the finding about "Evidence so far" itself |
| F10 | Repair | `client-guide.md` introduction and "Generating a client" | None |

## What the owning session did with them

`open-path-vm-k76` acted on every proposal, in the documents the proposals name. "Evidence so
far" still lists the same facts as evidence; the guide now states them as the contract.

| # | Disposition | Where |
|---|---|---|
| F1 | Repaired as proposed, with the response path (HTTP 200, the root field's own path) added | `client-guide.md` "Opening a document or folder" item 1 |
| F2 | Declined for version 1, stated as such | `client-guide.md` "What version 1 does not do". The sentence says only the folder that holds a file can be opened when the file's own name is not valid UTF-8; the proposal's "or reveal it" was dropped, since reveal also takes a path string |
| F3 | Repaired as proposed (file handling declined) | `client-guide.md` item 1 |
| F4 | Repaired as proposed | `client-guide.md` item 2 |
| F5 | Machine-readable reason declined; the sentence repaired | `client-guide.md` item 3 |
| F6 | Repaired: the content type decides, and the "known limit" is now a documented rule | `workspace-launch-and-open.md` "Operations", the Input boundary row and the Documents paragraph |
| F7 | Repaired | `client-guide.md` item 7 |
| F8 | Declined (no idempotency key); one sentence | `client-guide.md` item 7 |
| F9 | Repaired by the F1, F4 and F5 sentences | `client-guide.md` items 1 to 3 |
| F10 | Repaired | `client-guide.md` introduction and "Generating a client" |

None of these was checked against the real wire by the pass that raised them. The V run
([open-path-vm.md](open-path-vm.md)) did, and found the messages the guide now describes: the
input error's path is `["workspaceOpenPath"]` in an HTTP 200 answer with no `kind`, a missing path
is `PATH_NOT_FOUND` for a missing parent, a link to nothing, a path below a file and a file with a
trailing `/`, and an inspection that was denied is `failed`.

## Defects found in the existing client (not document findings)

- The URL command's file reading (a fatal UTF-8 decoder that keeps the byte order mark)
  was inline; `open-path` needs the same, so it is now one function, `readExactUtf8`, used
  by both. `open-url`'s behaviour and its tests are unchanged.
- The README said that adding `OpenDocumentOrDirectory` to the used list stops
  generation; that is no longer true since the root is served. It now says the same of
  `RevealPath`, and that was watched: `Cannot query field "workspaceRevealPath" on type
  "Mutation"`.
- `--application-path` without `--bundle-identifier` has no wire form
  (`WorkspaceApplicationInput.bundleIdentifier` is `String!`), so it is a usage error and
  nothing is sent. This is the schema's rule, not a document gap.
- The shared reading in `src/adapter/workspace-open.ts` is unchanged in behaviour: it
  already treated a kind-less error at the root plus an argument name as the action's own
  refusal, and the guide now says the path is the root's own. The tolerance is kept (the
  documents do not say a deeper path cannot be served) and tested at `[root, "path"]` and
  `[root, "application", "bundleIdentifier"]`.

## No guess needed

Checked and unambiguous in the documents (the guide's "Opening a document or folder",
the spec's table, and the SDL):

- `workspaceOpenPath` needs `workspace:control` AND `desktop:control` and no read
  capability; a denial reports `requiredCapabilities` as
  `["workspace:control","desktop:control"]` in that order with `requiredCapability` the
  first unmet member; preflight refusal is HTTP 403 with no `data`, `phase:
  authorization`, at the action's path.
- The result is the launch's: `status`, exactly one of `value` and `dependency` selected
  by it absent an error, a published status authoritative when an error suppresses its
  branch, a null root always has an error, `AVAILABLE` is acknowledgment and not
  rendering, a dependency result is neither success nor an error.
- An invalid input is an input error with no `kind` at the root field's own path (its
  alias if one was used), an execution error in an HTTP 200 answer, and nothing was
  inspected or opened (guide item 1; spec outcome table). The client sends no alias.
- The reasons this root reports are all four of the enum's, each stated in the guide:
  `PATH_NOT_FOUND` (item 2, decided before any application is looked up and winning over
  a named application that is also missing), `NO_DEFAULT_HANDLER` (item 4, no chooser),
  `APPLICATION_NOT_INSTALLED` and `APPLICATION_IDENTITY_MISMATCH` (item 4, the launch's
  rules). Reasons are copied verbatim and none is acted on.
- An application bundle, a program and a Finder alias are refused as input errors for the
  default and for a named application alike (item 3). A script or source document is not.
- `application` omitted and `null` are the same default (item 4); the client omits it.
- If a named application cannot open the item that is `failed`, with no other application
  tried and no default changed (item 4).
- The path is submitted as written and any link in it is followed by the application
  (item 5).
- Opening a document in Desktop, Documents or Downloads with the default application is
  undecided, may raise a Files and Folders prompt for Koine, and the guide says to name an
  application until it is decided (item 6). The client does nothing about it and could not
  tell a caller in advance which paths are protected; what an answer to such an open looks
  like is not specified, and was not guessed.
- `failed` means effects may have begun, with no replay and no alternate handler; a lost
  answer is unknown even if the item opened; the answer comes within five seconds.
- No installed path, bundle identifier or handler metadata is in the receipt.
