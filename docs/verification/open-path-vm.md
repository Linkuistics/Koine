# Documents, directories and settings: VM acceptance

The "Isolated TestAnyware macOS VMs" seam of the **Documents/directories/settings** row of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md), and of the path parts of
its **Input boundary**, **Receipt/failure boundary** (the receipt), **Bounded acknowledgment**
(answer times only: see the limits), **Authority/revocation** and **Consent and prompts** rows. It
runs the Developer ID signed `Koine.app` (0.1.0, executable digest `72069a34…`, built once and not
rebuilt between the acceptance and the conformance run below) in a clone of the prepared image from
[launcher-apps-vm.md](launcher-apps-vm.md): Gatekeeper enforcing, Zed, Visual Studio Code, iTerm
and Safari installed and past their first run, nothing signed in to. The app under test is **not
notarized** and is copied in without a quarantine attribute, so Gatekeeper's own assessment rejects
it (the transcript records `rejected source=Unnotarized Developer ID` and does not treat it as a
failure of this stage), as in the earlier VM acceptances. Nothing runs an application on the host.
To open a document the recipe drives no application's interface: it reads windows and puts
Calculator in front. (It does approve four grants in Koine's own window, compile helpers in the guest
and add a hosts entry, as the URL acceptance does.)

**What passed, what is recorded, and what is not accepted here.**

- Passed: a temporary text file (under `/tmp`, itself a symlink), a directory and a document
  package each opened in their default handler and with Zed named; the configuration directory
  opened in Zed; literal spaces and shell punctuation, decomposed Unicode, a symlink to a file, a
  symlink to a directory and a file through a symlinked parent; source scripts with and without
  their executable bits in their default editor and in named Zed; 25 refused, unavailable or
  failed requests, none of which launched or activated an application; either control alone, a
  revoked grant and a denied request for a missing path, none of which did either; no
  default-handler setting changed. **Inferred, not shown at each open:** Accessibility absent
  throughout (below).
- **Recorded, not asserted: the handlers' reactions.** Terminal ran a `.command` script that had
  its executable bit and no marker appeared for one that had not (Terminal was cold for the first
  and running for the second); iTerm, the image's handler for `.sh`, was asked to open both scripts and
  no marker appeared; Safari followed a `.webloc` to its HTTP page; a
  `.fileloc` was opened by TextEdit, which showed a window for the file it names. This is the disclosure the
  spec asks for, not a claim about a sandbox: there is none.
- **Not accepted here: default opening of a protected document** (Desktop, Documents,
  Downloads). No fixture is there, nothing in the run requests or suppresses the Files and
  Folders prompt, and the consent decision it needs is Antony's
  ([protected-path-metadata.md](protected-path-metadata.md#handler-lookup-limit),
  `protected-default-open-k89`).

## Procedure

```sh
task launchers:prepare   # once: the reusable image (about 40 minutes)
task open-path:vm        # scripts/vm-verify-open-path.sh, one clone of that image (about 2 hours 50 minutes)
```

`task open-path:vm` builds the signed app and the contract-only client, then runs one clone.
`KOINE_OPEN_PATH_ONLY=default,zed,literal,source,refus,react` (any of them) runs those sections
only. It exits 0 when everything passed, 1 when a case failed, and 3 when nothing failed but an
acknowledged open was not seen activating its handler. The run is long because the guest agent
answers each of its commands in seconds, not milliseconds (the harness reads again a command the agent
reports as timed out, as [resident-app-vm.md](resident-app-vm.md) records); the transcript's activation times put
consecutive cases between about half a minute and eleven minutes apart. Koine's own part, from request
to answer, is the 30 to 394 ms below; the rest was not measured.

**Every request is made by the contract-only client** ([launch-contract.md](launch-contract.md),
[open-path-contract-client-findings.md](open-path-contract-client-findings.md)), which enrols its
own grants through the settings window and was regenerated from the schema the signed build serves
(digest `f98a3862c3bb77417c38eef9fe4edccd16e0bf76b6f4b8fc7bdf6708190be32d`, introspected by
`task conformance:vm`, below). Four grants are enrolled: both controls, each control alone, and a
fourth for both controls that a `koine:manage` grant, made in the window first, then revokes. Every
path is sent from a file of its exact bytes (`--path-file`), so no shell, exec channel or terminal
repairs, trims or re-encodes it. **Koine has no Accessibility consent in the clone** and the run
checks Koine's own account of that at the start and at the end, so every open below is by
`workspace:control` and `desktop:control` alone, with no read capability.

### The fixtures, and what saw what was opened

The fixtures are made in the guest by `scripts/vm-open-path-fixtures.sh`, nothing in them under
Desktop, Documents or Downloads: a text file `/tmp/koine-open-path/plain note.txt` (on macOS `/tmp` is a symlink to `/private/tmp`; the transcript does not print that), and in
`~/open-path-fx/` a directory `A Folder`, a package `Package Doc.rtfd`, a file whose name is
`lit $HOME ~ * ? [x] ; & ' " # % ! (1).txt`, a file whose name has a decomposed accent and
Japanese characters, links to a file, to a directory, to nothing and to Zed.app, source files in
Swift, Python and JavaScript with mode 0755 and with mode 0644, a Mach-O program (a copy of
`/bin/ls`), a `setup.exe` holding bytes beginning `MZ`, real Finder alias files (made with
`NSURL`'s bookmark-file writer, as the protected-path probe made them) to a document, a folder and
Zed.app, a file with a type nothing handles, a directory with mode 000 holding a file, scripts that
only write a marker file, a `.webloc` naming a page and a `.fileloc` naming a file, and the
configuration directory `~/.config/modaliser/` with one file. Every path a case submits is checked
in the guest, in one command, to be what the case says it is (the decomposed name by its bytes,
since the exec channel re-normalises Unicode in a command line).

| Witness | What it is | What it sees |
|---|---|---|
| **The handler's window** | `testanyware agent windows`, the window server's list through the test agent | An application's window whose title names the fixture. A window of **that application** already carrying the name **before** an open case's request fails the run, so a case cannot pass on an earlier window of the same application (a name is reused across applications, for the default and the Zed-named open of one item, and the application is part of what is matched). The six reaction cases use their own witnesses and no before-state |
| **`Fixtures/LaunchWitness`** | The signed witness of [launch-vm.md](launch-vm.md): no Koine code, no Accessibility | Who is in front, which instances run, the kernel's start instant of each, and every launch and activation, on the guest's clock |
| **The page server** (`scripts/vm-url-witness-server.mjs`) | The URL acceptance's, with `koine-url.test` an `/etc/hosts` entry for 127.0.0.1 | The request a browser makes for the page a `.webloc` names |
| **Marker files** | Scripts that write a timestamp to `~/open-path-fx/markers/` | That a handler ran a script |

Before each request Calculator is put in front and Koine is inactive. The run digests the ten
files it lists (the script, the fixtures script, the page server, the alias maker, three libraries
of the earlier acceptances, the launcher library, the client bundle and Koine's executable; not
the provider library, the other helper libraries or the witness) before and after, and fails if one
changed under it; the digests are printed at the start of the transcript.

## What the image's handlers are

The run reads, in the clone before anything is opened, which application the system gives each
fixture type (the transcript prints the table below with bundle identifiers). It **asserts three
premises**: `.py` is Zed, `.swift` is Visual Studio Code and the no-handler type has none. The others are
not asserted, but a wrong handler fails its case, since each case requires its handler's own window
and activation. The application versions are those the image's inventory records
([launcher-apps-vm.md](launcher-apps-vm.md)); the run does not print them:

| Fixture | Content type | Default handler |
|---|---|---|
| `.txt`, `.rtfd` | `public.plain-text`, `com.apple.rtfd` | TextEdit |
| a folder | `public.folder` | Finder |
| `.swift` | `public.swift-source` | Visual Studio Code 1.140.0 |
| `.py` | `public.python-script` | Zed 1.22.0 |
| `.js` | `com.netscape.javascript-source` | Safari |
| `.command` | `com.apple.terminal.shell-script` | Terminal |
| `.sh` | `public.shell-script` | iTerm 3.7.3 |
| `.webloc` | `com.apple.web-internet-location` | Safari |
| `.fileloc` | `com.apple.file-internet-location` | TextEdit |
| `.unknownzzz` | a `dyn.` type | none |

So "a source script in its default editor" is the Swift file (Code) and the Python file (Zed,
which is also the application the Zed-named cases use, so those two are default-only), and
JavaScript, whose default is Safari and not an editor, is the Zed-named pair.

## Opening in the default handler and in Zed

Each case: the client's one `open-path`, an acknowledged `AVAILABLE` answer with no error and
HTTP 200, the handler's window naming the fixture, the handler activated (the witness), and the
receipt's `process` **equal to the kernel's identity** of the handler's single instance. Answer
times are after the request was sent. Each handler but Finder was cold for its first case (the
witness saw it launched: TextEdit, Zed, Visual Studio Code, and later Terminal, iTerm and Safari)
and running after it.

| Section | Case | Handler | Window | Answer | Activation |
|---|---|---|---|---|---|
| default | the temporary text file under `/tmp` | TextEdit | `plain note.txt` | 150 ms | 128 ms |
| default | a directory | Finder | `A Folder` | 54 ms | 40 ms |
| default | a document package | TextEdit | `Package Doc.rtfd` | 53 ms | 43 ms |
| Zed named | the temporary text file | Zed | `plain note.txt — plain note.txt` | 175 ms | 166 ms |
| Zed named | the directory | Zed | `A Folder` | 57 ms | 29 ms |
| Zed named | the document package | Zed | `Package Doc.rtfd` | 50 ms | 41 ms |
| Zed named | the configuration directory (Client settings) | Zed | `modaliser` | 71 ms | 56 ms |
| literal | spaces and shell punctuation | TextEdit | `lit $HOME ~ * ? [x] ; & ' " # % ! (1).txt` | 73 ms | 49 ms |
| literal | decomposed Unicode (the name is matched by its Japanese characters) | TextEdit | `café 日本.txt` | 54 ms | 26 ms |
| literal | a symlink to a file | TextEdit | `real-note.txt` | 57 ms | 29 ms |
| literal | a symlink to a directory | Finder | `Link Target` | 48 ms | 19 ms |
| literal | a file through a symlinked parent, Zed named | Zed | `A Folder — inner note.txt` | 41 ms | 34 ms |
| source | Swift, mode 0755, default | Visual Studio Code | `src-exec.swift` | 259 ms | 354 ms |
| source | Swift, mode 0644, default | Visual Studio Code | `src-plain.swift` | 61 ms | 47 ms |
| source | Python, mode 0755, default | Zed | `A Folder — src-exec.py` | 52 ms | 17 ms |
| source | Python, mode 0644, default | Zed | `A Folder — src-plain.py` | 39 ms | 17 ms |
| source | JavaScript, mode 0755, Zed named | Zed | `A Folder — src-exec.js` | 46 ms | 19 ms |
| source | JavaScript, mode 0644, Zed named | Zed | `A Folder — src-plain.js` | 46 ms | 26 ms |
| source | Swift, mode 0755, Zed named | Zed | `A Folder — src-exec.swift` | 30 ms | 18 ms |
| source | Swift, mode 0644, Zed named | Zed | `A Folder — src-plain.swift` | 32 ms | 28 ms |

The decomposed-Unicode case opened the file whose name has those bytes, but **it does not show that
Koine submitted them unnormalised**: the file system treats the composed and decomposed spellings as one
name, so a normalised submission would have opened it too. That Koine submits the path as written rests
on L (`OpenPathTests`). Twenty opens, none refused because of an executable bit, and no dialog on screen after any of
them (the dialogs of Gatekeeper, the permission service and Accessibility were listed after each
case; there were none). A symlink
to a file was shown as the file it names, and a symlink to a folder as the folder it names. The
literal path is what Koine submits (the spec's "location-based requests with normal symlink
semantics"), and the run does not distinguish whether the handler or Koine's own `realpath` in the
inspection resolved the link. Zed reuses its
open window: after the directory case a later file is added to the `A Folder` window and its
title names both, which is why those titles read `A Folder — …`; each named file is still new to
Zed's windows before its request, and the title is how it is read.

## Refused inputs, dependencies and denied grants

These run as one batch in the guest under one witness, with Calculator in front. The witness
reported no launch or activation event over the batch, the front application was the same before
and after (two samples), and the recipe compared the list of windows of every application (other
than Notification Center) before and after and found them equal. **That comparison is weak**: the
lists are not printed, the comparison has no guard against two empty lists, and a leaked open of an
item that already had a window (the refused targets `real-note.txt`, `A Folder` and Zed.app were
opened by earlier cases) would create no new one. The witness was started with a 20-minute bound and
nothing in the run proves it was still alive at the end. So what V adds to "nothing was opened" is
that no application launched or activated; that nothing is submitted when a path is refused, and
"before dispatch" for the aliases, rests on the answers (`actionEffect: none`, no receipt) and on L and
N, where a recording stand-in sees no submission.

Each refusal is HTTP 200 with a single execution error at **`["workspaceOpenPath"]`**, the root
field's own path, **no `kind`**, `classification: input-error`, `actionEffect: none`, no receipt.
The recipe asserts all of that for all fifteen, **and not the message**: the class in the table is read
from the message each answer carried, which the run recorded in
[open-path-vm/results.json](open-path-vm/results.json) (checked against it here, one row per input), and
a recipe that mislabelled one class would not have failed:

| Input | Class | Koine's message |
|---|---|---|
| the empty path | empty | path must not be empty. |
| `open-path-fx/real-note.txt` | relative | path must be an absolute path. |
| `~/open-path-fx/real-note.txt` | a tilde, not expanded | path must be an absolute path. |
| `file:///…/real-note.txt` | a file URL | path must be an absolute path. |
| a path with a NUL byte between `real` and `note.txt` | NUL | path must not contain a NUL character. |
| an existing file, `bundleIdentifier` of one space | a blank application | application.bundleIdentifier must not be blank. |
| `/Applications/Zed.app`, default and with Zed named | an application bundle | The path is an application bundle, which this operation does not open. |
| a symlink to `/Applications/Zed.app` | a link to an application bundle | The path is an application bundle, which this operation does not open. |
| a Finder alias to a document, default and with Zed named | a Finder alias file | The path is a Finder alias, which this operation does not open or resolve. |
| a Finder alias to a folder; a Finder alias to Zed.app | a Finder alias file | The path is a Finder alias, which this operation does not open or resolve. |
| a copy of `/bin/ls`; `setup.exe` | a program | The path is an executable program, which this operation does not open. |

Dependencies (`DEPENDENCY_UNAVAILABLE`, `classification: dependency-unavailable`,
`actionEffect: none`, no receipt):

| Input | Reason |
|---|---|
| a file that does not exist; a file in a directory that does not exist; a symlink to nothing; a path below a file (`real-note.txt/inner.txt`); a file with a trailing `/` | `PATH_NOT_FOUND` |
| a missing file **and** a named application that is not installed | `PATH_NOT_FOUND` (the path wins) |
| an existing file, and an existing folder, with the application `com.example.koine.nothere` | `APPLICATION_NOT_INSTALLED` |
| a file of a type no application handles (`.unknownzzz`) | `NO_DEFAULT_HANDLER` ("…Choose an application to open it with, or set a default for this kind of item in Finder.") |

**Inspection denied:** a file inside a directory with mode 000 answered `failed` at
`["workspaceOpenPath"]` with `kind: failed` and the message "The path could not be inspected:
Permission denied." It is not `PATH_NOT_FOUND` (the recipe asserts `failed` and the results record the message). The
contract-only client's `actionEffect` for any `failed` is `may-have-begun`, its generic reading; the
message says the failure was in the inspection, and the target could not have been opened in any case
(it was inside a directory with no permissions), so this case shows the typed result and not that no
open was attempted. That nothing is submitted when inspection fails is the L and N evidence.

| Grant | Answer |
|---|---|
| `workspace:control` alone | HTTP 403, `capability-denied`, `phase: authorization`; first unmet `desktop:control`; the complete set `["workspace:control","desktop:control"]` in that order |
| `desktop:control` alone | HTTP 403, `capability-denied`; first unmet `workspace:control`; the same complete set |
| a grant for both, revoked by the manager | HTTP 401 (`unauthenticated`) |
| `workspace:control` alone, for a path that does not exist | HTTP 403 `capability-denied`, **not** `PATH_NOT_FOUND`: the denial precedes inspection (one path, one control) |

## What the handlers did with scripts and location documents

Disclosed reach, not prevented effects. Each fixture was sent to its default handler; the case
passes if the open was acknowledged, and what the handler then did is recorded. The witness of
"the handler was asked" is the acknowledgment and the handler's activation, not a window or a
process the handler started; each observation window is fifteen reads two seconds apart plus the
guest round trips (at least 30 seconds, not timed):

| Fixture | Handler | The open | What was observed |
|---|---|---|---|
| `react-term.command`, mode 0755, writes a marker | Terminal | acknowledged, 99 ms; Terminal cold, activated | **the script ran** (the marker appeared) |
| `react-term-plain.command`, mode 0644 | Terminal | acknowledged, 47 ms | the marker did not appear |
| `react-shell.sh`, mode 0755 | iTerm 3.7.3 (the image's `.sh` handler) | acknowledged, 394 ms; iTerm cold, activated | the marker did not appear |
| `react-shell-plain.sh`, mode 0644 | iTerm | acknowledged, 37 ms | the marker did not appear |
| `loc-http.webloc`, naming `http://koine-url.test:8765/from-webloc` | Safari | acknowledged, 96 ms; Safari cold, activated | **the page server received a request for `/from-webloc`**, `Host: koine-url.test:8765`, after Safari was launched (the server logs the user agent; the results keep the target and host only) |
| `loc-file.fileloc`, naming a file | TextEdit | acknowledged, 73 ms | a TextEdit window titled `fileloc target.txt`, the file the document names (this witness has no before-state check) |

So a Koine path open of a `.command` file with an executable bit did run it, and of a `.webloc`
did make a browser request: the API boundary the spec states, that the application owns the
reaction, is as stated and not narrower. iTerm's reaction is not observed here: it was handed the
script and wrote no marker, and the run does not say why (it opened no dialog that it listed).

## No handler setting changed

Before the first open the run reads, with `NSWorkspace.urlForApplication(toOpen:)`, the default
application of eleven fixtures (the table above), the `http` handler, and the digest of the user's
LaunchServices handler settings
(`~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist`); it reads
them again at the end. All are equal: the digest is `2f6dbb058d73…` both times. The operation
sets no default, and no named application became one.

## Accessibility and consent

Koine's own account (`koineManagement.osPermissions`, whose first entry the recipe reads as
Accessibility without asserting its name) said `granted: false` at the start and at the end, and the
screen carried no "would like to control" dialog at the end (the text search ran once). After each
of the 26 opens (20 above and the six reactions) the recipe listed the buttons of Gatekeeper's, the
permission service's and the Accessibility prompt's dialogs: **none**. The process which shows the
consent dialog, `universalAccessAuthWarn`, was running at the end (what started it was not
controlled for; no dialog was listed). That Accessibility was absent at *each* open is an inference
from those two readings and the dialog listings, so it is not counted among the passed cases above.

## The contract-only client and the workspace profile

The client was extended with `open-path` by a reading-restricted pass (it read only the
published contract documents; [open-path-contract-client-findings.md](open-path-contract-client-findings.md)
records the ten places it guessed, and the repairs made to the documents from them). Its checks
(`task client`, re-run for this document: 1,417 `ok` lines, 479 naming `open-path`, the bundle's digest
`0ead0048…` the one the acceptance run printed) ran against a stub server; the pass reports watching
its assertions fail against five deliberately broken clients, and codegen failing for an operation
whose root is not served. The run above is the real wire: the client
opened a document (`plain note.txt`, `real-note.txt`, …) and a directory (`A Folder`, the
configuration directory) through the documented contract and nothing else.

`task client:capture` re-took the introspection of the signed Koine in a clean VM with the path
root in the design file (the digest is `f98a3862c3bb…`), and `task conformance:vm` passed with the
path root present; `task conformance`, the three profiles, is under
[Regression](#regression-and-what-was-re-run).

## Findings from the runs

- **The first runs were of the instrument, not of Koine.** An image check
  `tart list | grep -qx …` failed once by SIGPIPE under `pipefail`; the window match used
  `contains(.)` in a jq pipeline, whose `.` is the title, so every window matched every
  fixture (caught by the before-request check failing with `["plain note.txt"]` already "naming
  `Package Doc`"); an unreadable window list was read as "no window"; the fixtures script, run
  twice by the agent's retry, met its own mode-000 directory; and two fixtures' window names
  collided with an earlier case's (a folder reused for a symlink). Each was fixed in the script
  before the cited run.
- **The image decides the handlers**, and the run's own premises (above) are the evidence of
  which. A different image gives different cases: the premises are checked, not assumed.
- **A `.fileloc` is a document of its handler**, and the handler here (TextEdit, once the file is
  a real property list) opened the file it names.
- **Zed shows a directory and a file in one window**; its title names both.

## Regression and what was re-run

- `task client:capture` (the signed build in a clean VM, introspected), then `task client`:
  codegen validated all the client's operations against the new schema, including
  `OpenDocumentOrDirectory`; typecheck, bundle and 1,417 assertions passed.
- `task conformance` (the three profiles, run after the acceptance above, in the same tree): all
  three conformant. The third, extension-host core + desktop + workspace, against the signed
  application in a clean VM, agrees at digest
  `f98a3862c3bb77417c38eef9fe4edccd16e0bf76b6f4b8fc7bdf6708190be32d` (the design file is exactly the
  schema Koine hashed). Its positive controls turned red, including **the workspace path root
  removed from the design file**, beside the launch root and the URL root removed. The two
  profiles a headless host serves stayed at their digests (`ee17dfd1…`, `fc0611ae…`).
- No Swift source changed in this leaf, so the Swift suites are as `open-path-k75` left them.

## Limits and what stays pending

- The digested subjects include Koine's executable and not its provider bundles
  (`Workspace.koineprovider`, which serves the operation); the app was built once, before the
  acceptance, and not rebuilt after it.
- One macOS (26.5), one architecture, one clone, **one sample** of each timing. Zed 1.22.0,
  Visual Studio Code 1.140.0, iTerm 3.7.3 and Safari 26.5 are as the image holds them.
- **Not accepted: default opening of a protected document.** Nothing here requests or suppresses
  the prompt it can raise; the decision is Antony's.
- **The Terminal and iTerm reactions are one sample each**, observed for 30 seconds by a marker
  file; "did not run" means no marker in that interval. iTerm's behaviour with a `.sh` file is not
  explained here.
- **Bounded acknowledgment, at V, is answer times only.** Every path open answered in under
  400 ms, so none was held past three seconds; the late-callback and bound handling is
  established at L (`OpenPathTests`) and the Gatekeeper-held launch in
  [launchers-vm.md](launchers-vm.md).
- The refusal batch's witness has no liveness control and its window comparison is weak (above);
  "the front application never changed" is two samples.
- **What a handler does with the item is the handler's:** the run shows the document reached the
  application the receipt names (by window and by the kernel's identity), not that the application
  displayed it correctly, and says nothing of a racing replacement between inspection and open
  (the spec does not claim to prevent one).
- A volume that is removable or on the network, an item in iCloud Drive and a path in a
  protected folder were not exercised.
- Multiple copies, reveal and disclosure are other increments.
