# Finder reveal: VM acceptance

The "Isolated TestAnyware macOS VMs" seam of the **Finder reveal** row of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md), and of the reveal parts of
its **Input boundary**, **Receipt/failure boundary**, **Authority/revocation** and **Consent and
prompts** rows. It runs the Developer ID signed `Koine.app` (0.1.0, executable digest `a2cbf32b…`,
the one build that the run and the conformance run below both used) in a clone of the prepared image
from [launcher-apps-vm.md](launcher-apps-vm.md): Gatekeeper enforcing, nothing signed in to. The app
under test is **not notarized** and is copied in without a quarantine attribute, as in the earlier VM
acceptances. Nothing runs an application on the host.

**What passed, what is recorded, and what goes to Antony.**

- **Passed.** A file, a folder (also addressed with a trailing slash), an application bundle, a
  Finder alias file, the filesystem root (also spelled `//`), a path with spaces and shell
  punctuation and a symlink were each revealed by the contract-only client under
  `workspace:control` and `desktop:control` alone, and **Finder's own account**, read by an
  independent observer, was in each case the expected folder window with exactly that item selected (the
  root: a window on `/` with nothing selected). The receipt echoed the submitted path every time.
  Ten requests were refused or unavailable and four were denied, and nothing was revealed, launched or
  activated. Accessibility was read as absent at the start and the end, and no consent dialog was
  on screen after any reveal.
- **Recorded, not asserted.** (1) Finder's reading of `/var/..`. (2) That the item forms did not
  bring Finder to the front. (3) The system notice below.
- **Goes to Antony: a system notice attributed to Koine on revealing a third-party application.**
  Revealing `/Applications/Zed.app` made macOS post "Privacy & Security: “Koine” was prevented from
  modifying apps on your Mac." The reveal itself worked. System applications and a refused open of the
  same bundle did not post it. See [The App Management notice](#the-app-management-notice).

## Procedure

```sh
task launchers:prepare   # once: the reusable image
task reveal-path:vm      # scripts/vm-verify-reveal-path.sh, one clone of that image (about 1 hour 20 minutes)
```

`task reveal-path:vm` builds the signed app and the contract-only client, then runs one clone.
`KOINE_REVEAL_ONLY=reveal,refus` runs those sections only. It exits 0 when everything passed and 1
when a case failed. The run in this document is
`.build/vm-verify/reveal-path-vm-20261003T021212.log`; its results are kept in
[reveal-path-vm/results.json](reveal-path-vm/results.json) and a screenshot of each case beside
them. Three earlier runs of the script are **not evidence**: one hung on the observer's consent dialog (an
instrument fault, fixed), one was of provider code that an adversarial review then found wrong (the root
decision, below) and was stopped for it, and one spent about forty minutes a case waiting for a Finder
activation that does not come (so the wait was removed and activation is read once). The run cited is one whole run of the final script, digested at its start and end (ten files:
the script, its fixtures and observer, the three libraries, the alias maker, the client bundle and
Koine's executable), unchanged.

**Every request is made by the contract-only client** ([README](../../clients/contract-only/README.md)),
which enrols its own grants through the settings window, five of them: a manager grant that only reads
Koine's own account of Accessibility, one with both controls, one with `workspace:control` alone,
one with `desktop:control` alone, and one that is created and then revoked. The paths travel in files, read in the
guest with `--path-file`, so that no shell or exec channel can repair what is sent. **`reveal-path`
was written by the implementing leaf, not by a reading-restricted pass**, so its independence from the
repository is not claimed (the README says so).

### What saw what Finder showed

Koine's answer is only Finder's boolean acknowledgment, so it is never the observation. A
separate process reads Finder:

- `scripts/vm-reveal-observe.applescript`, run from the test agent (`testanyware-agent`, which is
  the harness and **not Koine**), asks Finder for the number of its windows, the front window's folder
  and name, and for each selected item its path, kind and name. It reads and changes nothing.
- The first question to Finder makes macOS ask whether `testanyware-agent` may control Finder. That
  consent is the observer's. It is given once, in the disposable clone, **before Koine starts**
  (the dialog is answered by clicking Allow where the accessibility tree puts it), and nothing of
  Koine's depends on it. The transcript records the dialog's words.
- Every case starts from a Finder with no window open (the script closes them all and reads that), so a
  window and a selection afterwards are the request's doing. Calculator is in front and Koine inactive.
- A screenshot of each case is kept ([reveal-path-vm/](reveal-path-vm/)). The root, alias and
  `..` cases were read by eye from them as well.
- `Fixtures/LaunchWitness`, an independent signed tool, reports who is in front and every launch and
  activation, on the guest's clock.

A symlink is the one case Finder's path does not say: the alias coercion resolves a link to its
target, so Finder reports `…/note.txt` for a selected `link-to-note.txt`. The item's **name**
(`link-to-note.txt`) and its **kind** (`Alias`, which Finder shows for a symlink) say that the link
itself was selected, and the script checks the name in every case.

The fixtures ([scripts/vm-reveal-path-fixtures.sh](../../scripts/vm-reveal-path-fixtures.sh)) are made
in the guest, nothing under Desktop, Documents or Downloads: a directory of siblings (`note.txt`,
`other.txt`, `sub folder`, a real Finder alias file `Alias to note`, a file whose name is shell
punctuation, a symlink to the note, a symlink to nothing), so that a selection is visibly one item of
several. Every path a case submits is checked to be what the case says in the guest before it is relied
on, and the real Zed bundle in `/Applications` is the application.

## Revealing

| Case | Submitted | Finder's own account afterwards | Answer |
| --- | --- | --- | --- |
| A file | `…/dir/note.txt` | window `dir`, `note.txt` selected (Plain Text Document) | 171 ms |
| A folder | `…/dir/sub folder` | window `dir`, `sub folder` selected (Folder) | 212 ms |
| A folder with a trailing slash | `…/dir/sub folder/` | the same | 133 ms |
| An application bundle | `/Applications/Zed.app` | window `Applications`, `Zed.app` selected (Application); **Zed was not running afterwards** | 165 ms |
| A Finder alias file | `…/dir/Alias to note` | window `dir`, `Alias to note` selected (kind Alias): the alias itself, not `note.txt` | 121 ms |
| The filesystem root | `/` | window `Macintosh HD` on `/`, nothing selected | 50 ms |
| The root, spelled | `//` | the same | 52 ms |
| Spaces and shell punctuation | `…/lit $HOME ~ * ? [x] ; & ' " # % ! (1).txt` | window `dir`, that file selected (name equal) | 153 ms |
| A symlink | `…/dir/link-to-note.txt` | window `dir`, name `link-to-note.txt`, kind Alias | 144 ms |
| `/var/..` | `/var/..` | **recorded**: window `Macintosh HD`, `var` selected | 120 ms |

Each answer was `AVAILABLE` with `value.path` equal to the submitted path, `selectionObserved:
false` and no error. The answer times are Koine's own part, from the client's request to its answer; one
sample each, one macOS image. A reveal opens nothing: the application-bundle case left Zed unlaunched,
and the alias case did not open or resolve its target.

**Which form served which.** The ordinary cases are the item form, `selectFile(path, inFileViewerRootedAtPath: "")`.
The root is the other documented form, `selectFile(nil, inFileViewerRootedAtPath: "/")`. A probe in the
same image with the other root form, `selectFile("/", "")`, showed Finder selecting the volume inside the
Computer view, which is not a view of the root, so it was not used.

**The root is decided from the filesystem, not the spelling.** `PathFacts.isFilesystemRoot` is whether
`lstat` of the path names the same file as `lstat("/")`, so `/`, `//`, `/.` and `/..` are the root, a
symlink to `/` (`/Volumes/<name>`) is a link, and `/var/..` is `/private` and not the root. A first
version tested the spelling after lexical clean-up, which an adversarial review showed would give
`/var/..` the root view; L now holds the decision's plumbing and the real `lstat` rule was run against
those spellings once on the host (`/` `//` `/.` `/..` `/./` `/Users/..` `/System/..` true, `/var/..`
`/tmp/..` `/etc/..` `/Volumes/<link to />` `/nonexistent` false).

**`/var/..` is Finder's to read.** Koine submits the path as written and inspected: the kernel
resolves `..` physically (`/var` is `/private/var`, so `/var/..` is `/private`), and Finder did not
agree. It showed the root with `var` selected. The contract promises the acknowledgment and the echo
only, so this is recorded as Finder's reading, and the client guide tells a client to send a clean path.

**Activation.** Another application was in front and Koine inactive. The witness saw Finder activated by
the two root views (29 ms and 47 ms after the request) and **not** by the eight item cases, whose Finder
window appeared behind Calculator (the screenshots show it). The contract asks for no activation on a
reveal, so no case turns on it, but the client guide does not tell a client that a reveal brings Finder
forward: it may not, and a client that needs Finder in front launches or reactivates it
(`workspaceLaunchApplication` for `com.apple.finder`).

## Refused inputs, dependencies and denied grants

Ten requests, asked in one batch under one witness with Calculator in front and no Finder window,
and four denied ones:

- **Input errors** at `["workspaceRevealPath"]` in an HTTP 200 answer, with no `kind`, no receipt and
  nothing inspected: an empty path, a relative path, a tilde path, a `file:` URL and a path containing NUL
  (`path must not be empty.`, `path must be an absolute path.`, `path must not contain a NUL
  character.`).
- **`PATH_NOT_FOUND`**, `DEPENDENCY_UNAVAILABLE`, effect `none`: a missing file, a missing parent, a
  symlink to nothing, a path below a file and a file addressed with a trailing slash.
- **Either control alone**: `workspace:control` alone is refused with HTTP 403 at authorization,
  `requiredCapability` `desktop:control` and `requiredCapabilities` `["workspace:control","desktop:control"]`;
  `desktop:control` alone names `workspace:control` and the same set; a revoked grant is HTTP 401; and a
  **missing path under `workspace:control` alone** is refused with 403, so the denial precedes inspection.
- **Nothing happened**: no application launched or activated (the witness's launch and activation
  events were empty), the front application did not change, the window list of the screen was equal
  before and after, and Finder's own account afterwards was no window and no selection.

The input errors' texts are the provider's (they are for a person; the contract fixes the response
path, the absence of a `kind` and the HTTP status). Not exercised at V: Finder missing, a false or late
acknowledgment and cancellation (they are L's, with the adapter substituted: a real Finder cannot be made
to refuse in the image), and inspection denial (L and the unreadable cases in `RevealPathTests`).

## The App Management notice

**Observed in the cited run** (the application-bundle case onward, in the screenshots from
`app.jpg`): macOS posted the notification **"Privacy & Security: “Koine” was prevented from modifying
apps on your Mac."** It is a system notification, not a dialog. It asked for nothing, the reveal
succeeded, and `no_consent_dialog` (the search for "would like to control") correctly found none, so
the run's consent check does not cover it.

**Bounded probe** (`scripts/vm-probe-reveal-notification.sh`, a separate clone, one sample each;
transcript `.build/vm-verify/reveal-notification-probe-*.log`, screenshots
[notification-probe-reveal-of-Notes.app.jpg](reveal-path-vm/notification-probe-reveal-of-Notes.app.jpg) and
[notification-probe-reveal-of-Zed.app.jpg](reveal-path-vm/notification-probe-reveal-of-Zed.app.jpg)). Looked for by
reading the screen for the words, after a baseline with none:

| Step | Notice |
| --- | --- |
| A refused `workspaceOpenPath` of `/Applications/Zed.app` (inspection only) | none |
| Reveal of `/System/Applications/Notes.app` | none |
| Reveal of `/System/Applications/TextEdit.app` | none |
| Reveal of `/Applications/Zed.app` | **seen** |
| Reveal of `/Applications/Zed.app` again | seen (the first banner may still have been on screen; not an independent sample) |

A throwaway tool that called the same `NSWorkspace.selectFile` on `Zed.app` and raised no notice, in the
same image, so the notice is not simply what that call does to a third-party bundle from any process.
The probe says only that **in this image, a reveal of a third-party application bundle by the signed Koine
posts it, and neither system applications nor inspection alone do.** It does not say which operation the
system refused, whether another third-party application behaves the same, or whether it appears for a
Koine that is notarized and quarantined, and no further evidence was chased (the brief bounds evidence
to a stated limit). Koine requests nothing here, adds no entitlement and no consent, and the system's
refusal did not change the outcome, so the contract's rule about a new consent is not triggered; but a
user-visible system message naming Koine, raised by an explicit authorized request, is a posture
decision that is Antony's. It is cut as `reveal-app-bundle-notice-k90` (a `design` leaf, ahead of
`baseline-acceptance`), with the options and a recommendation.

## Accessibility and consent

Koine's own account (`osPermissions`, read under the manager grant) was that Accessibility was **not
granted** at the start and again at the end, so every reveal here was by the two controls alone. After
the reveals no consent dialog was on screen (the words "would like to control"; `universalAccessAuthWarn`
was running, which the transcript records and does not assert on, as in the earlier acceptances). The
only consent dialog the run raised was the **observer's**, for the test agent to control Finder, before
Koine started. Nothing was raised for Koine. The App Management notice above is the one system message
that named Koine.

## The contract-only client and the workspace profile

- The client's `reveal-path` command, its reading (`src/adapter/workspace-reveal.ts`) and its stub
  answers (`test/reveal-stubs.mjs`) were added, with 277 checks of the 1,694 in `task client`,
  against a capture taken from this signed build (`task client:capture`, schema digest
  `3bab3a04…`). `RevealPath` is generated against it; before the root was served, listing it failed
  generation.
- `task conformance` passes **all three profiles** at digest `3bab3a0457329647e795ab04bdd52580d43e35841f0179aea1b83f9eb222a733`
  with the final build, the headless two and the signed application's. The profile's design file is now
  the complete workspace design, the reveal root's removal was seen red (`the workspace reveal root removed:
  red, caught by the report (1 against 0) and the digest`), and
  `SchemaConformanceTests.workspaceCoordinatesNotYetImplemented` is the empty set.

## Limits and what stays pending

- **Pending, for Antony:** the App Management notice above.
- **One image, one sample each.** Finder's behaviour with a window already open on the folder (reuse, a new
  window, or another space), with several windows, in a different view (list, columns, gallery) or on
  another display was not varied; a reveal is a request, and what Finder does with it is Finder's.
- **Not exercised:** a removable or network volume, an iCloud item, a path inside Desktop, Documents or
  Downloads (the metadata route was measured prompt-free there, but no reveal was run), a quarantined or
  notarized Koine, and a reveal while Finder is busy or hung (the three-second bound and the late callback
  are L's).
- **Selection is what Finder showed, not a promise.** The observer reads Finder's own account; it is not a
  claim that every selection will be visible or that a replacement after the check cannot change what is
  selected. The receipt alone never establishes selection (`selectionObserved` is always `false`).
- **Activation** was not required and was seen only for the root view.
- **The observer's consent** is the harness's, given once in a disposable clone, and is not evidence about
  Koine.
