# Long-location targets: VM acceptance (target-locations-vm, k180)

The V rows of the [long-location action boundary](../specs/workspace-launch-and-open.md#long-location-action-boundary)
for the **target stage** of `workspaceOpenPath` and `workspaceRevealPath`, run against the signed
`Koine.app` that packages workspace release/schema **1.0.1**, in a clone of the prepared image of
[launcher-apps-vm.md](launcher-apps-vm.md) (macOS 26.5, Gatekeeper enforcing, Zed, Visual Studio
Code, iTerm and Safari installed, nothing signed in to). Accessibility was never granted to Koine,
and every request was made by the [contract-only client](launch-contract.md) under
`workspace:control` and `desktop:control`.

**Result: everything this leaf owns is accepted at V.** Koine hands a 1,023-byte document and directory
to their handlers and reveals them, and refuses every extant location of 1,024 bytes or more with `failed`
and the stated guidance while the controlled observers see nothing delivered or selected. The outcomes
that only an effect can show (chains, links, names, a directory without search permission, the root) are
seen. **First-use resolution is prompt-free; the first *open* of a target in Desktop, Documents or
Downloads asks the user once.** Revealing a document or a directory there never prompted. Every open
raised "Koine would like to access files in your … folder", which the brief sends to Antony; his answer was
to run it in the disposable TestAnyware clone and approve the dialog there, so the recipe allows it, and each
open then completed with its effect and a second request was prompt-free ([below](#first-use-in-the-protected-folders)).
Whether Koine should ever help with that consent remains `protected-default-open-k89`'s question.

Two findings the earlier layers could not show are recorded below as well: [a default open of a
chain of more than ten links is `NO_DEFAULT_HANDLER`](#a-chain-of-more-than-ten-links-has-no-default-handler),
because the platform's own handler lookup follows ten links and no more, and [the prompt belongs to
the platform's submission, not to Koine's walk](#first-use-in-the-protected-folders).

## How it was run, and what saw what

```sh
task target-locations:vm-detached     # scripts/vm-verify-target-locations.sh, one clone, several hours, detached
```

The run takes hours because the guest agent answers each command in seconds, so the task starts it
detached (`nohup`) and its transcript is `.build/vm-verify/target-locations-vm-*.log`. It exits 0 when
everything passed, 1 when a case failed, 3 when an observer could not see its control (every
observation is then pending) and 4 when a prompt named Koine. `KOINE_TARGET_ONLY=reach,refus,walk,root,platform,prompt`
runs named sections (the controls run first unless only `platform` and `prompt` are named).

**The long subjects are built by `scripts/vm-long-location-fixtures.py` in the guest, component by
component**: `mkdir`, `open` and `symlink` relative to a directory descriptor, with ancestors of at most
200 bytes, so no whole-path call ever addresses a long location (which the platform would refuse). Each
literal path is exactly 1,023, 1,024 or 1,500 bytes (NUL not counted), written without a newline to a
file the client reads with `--path-file`, so nothing re-encodes it. The guest's own account of every
subject, by descriptors alone, is [descriptor-check.txt](target-locations-vm/run3/descriptor-check.txt):
each subject is present at its length, the two missing ones absent, the 300-byte ASCII name impossible.

### The observers, controlled at the admitted length, before Koine was asked anything

A subject is a *control* only at 1,023 bytes, and only when an **independent, non-Koine route** delivers it:
`open` and `open -R` from the test agent. No subject of 1,024 bytes or more is ever a control: the v1
decision defers over-limit delivery by any route, and k134 found submission failing there. An observer
that could not see its control would have left every observation pending (exit 3); none did.

| Observer | What it is | Controlled by (1,023 bytes) | First seen after the request |
| --- | --- | --- | --- |
| **The witness application** | K134's document handler for `.k134w` ([probe.m](long-action-route/probe.m)): no Koine code, records the exact bytes of the path it is handed (base64) | a witness document opened by `open`: the bytes it logged equal the guest's path | at the first read |
| **The handler's window** | the window server's list through the test agent: a window of TextEdit, Zed or Finder whose title names the subject (every name is unique to its case, and a window already carrying the name before a case fails the run) | a document in its default handler (TextEdit) and in Zed, a directory in Finder and in Zed | at the first read, or 2 s |
| **Finder's own account** | AppleScript run from the test agent ([vm-reveal-observe.applescript](../../scripts/vm-reveal-observe.applescript)): the front window's folder and each selected item with its exact path, whose Automation consent is the observer's and is given before Koine starts | a document and a directory revealed by `open -R`, the selected item's exact path equal to the guest's | 31 s and 1 s |
| **`Fixtures/LaunchWitness`** | the signed witness of [launch-vm.md](launch-vm.md): who is in front, every launch and activation, on the guest's clock | not a control of delivery; it makes "nothing launched or activated" and "focus did not move" observable | — |

The slowest control was seen 31 s after its command ran, so every observation of **nothing** watched for
93 s after the last request (three times that, and at least a minute). Times are counted from the instant
the guest's agent had run the command, which is when the observers start looking, and they include the
agent's own latency: each read of the window list or of Finder goes through an exec channel that can take
seconds, and the tables below show it. Every effect the observers look for **persists** (a window stays
open, a selection stays selected, the witness's log keeps its lines), so a read taken late still sees it.

## What Koine did at 1,023 bytes

Each case, with Calculator in front and Koine inactive, was one request, an acknowledged `AVAILABLE` answer
with no error, and the same observer that had seen the control. Answer times are after the request was sent.

| Case (1,023 bytes) | Observer | Answer | Seen |
| --- | --- | --- | --- |
| a document, default handler | TextEdit's window `k1023-txt-d.txt` | 33 ms | at the first read |
| a document, Zed named | Zed's window `k1023-txt-z.txt` | 43 ms | at the first read |
| a witness document, default handler | the witness's logged bytes equal the path | 33 ms | at the first read |
| a directory, default handler | Finder's window `k1023-dir-d` | 117 ms | at the first read |
| a directory, Zed named | Zed's window `k1023-dir-z` | 55 ms | at the first read |
| a document, revealed | Finder: the document selected, its exact path equal | 125 ms | 1 s |
| a directory, revealed | Finder: the directory selected, its exact path equal | 122 ms | 75 s (the reads were slow, not the effect: the same selection was there on every later read) |

The 1,023-byte limit is therefore the real boundary and not a conservative one: macOS delivered the
document to TextEdit and to Zed, opened the directory in Finder and Zed, handed the witness application
the document's exact bytes, and Finder selected both. The one-byte-longer cases follow.

## What Koine did at 1,024 and about 1,500 bytes

For an extant document, witness document and directory at each of 1,024 and 1,500 bytes, Koine was asked to
open by default, to open with Zed named, and to reveal: **18 requests**, with seven absent ones (below)
in one batch under one watch, Calculator in front and Finder showing no window. Every one answered
**`failed`** at the action's own response path (`workspaceOpenPath` or `workspaceRevealPath`), with no
receipt, no dependency and `actionEffect: may-have-begun` (the client's generic reading of any `failed`; the
guidance says no request was made), and guidance that names the hand-off stage, the spelling and its byte count:

> The application hand-off was refused: the path as written is 1024 bytes, and a path of 1024 bytes or
> more cannot be handed to an application (1023 is the most, not counting the terminating NUL). No request
> was made, so nothing was opened.

(the 1,500-byte answers say 1500 bytes, and a reveal says `revealed`). The recipe asserts the stage, the exact
byte count and the sentence that no request was made for each of the 18 and not only the class. Over the
batch and the **93 s** that followed: no launch and no activation (the witness), no new window of any
application (the list is the same before and after), no document delivered to the witness application, the
front application unchanged, and Finder's own account still no window and no selection. What the controls saw
within a minute, these observers did not see in 93 s for any of 18 requests.

**An absent long path is absent.** A missing file in an extant long directory, at 1,023 and at 1,500 bytes,
and the 300-byte ASCII name that cannot exist, each answered `DEPENDENCY_UNAVAILABLE` with `PATH_NOT_FOUND`
for open (default and Zed named) and for reveal, and the same observation of nothing covers them: absence is
established by the walk at any length, before the limit is ever considered.

## The present outcomes that only an effect shows

Each is within the limit, so the controlled observers see its effect. Fixtures are made by
`vm-long-location-fixtures.py` (the walk root is `~/wfx`).

| Subject | Opened | Revealed |
| --- | --- | --- |
| a **10-link** chain to a document | default handler: TextEdit `w10-target.txt` (86 ms) | Finder selects the link `w10-10.txt` |
| an **11-link** chain | default handler: `NO_DEFAULT_HANDLER` (see below); Zed named: Zed `w11-target.txt` (61 ms) | Finder selects `w11-11.txt` |
| a **31-link** chain | default handler: `NO_DEFAULT_HANDLER`; Zed named: Zed's window (35 ms) | Finder selects `w31-31.txt` |
| a **32-link** chain | default handler: `NO_DEFAULT_HANDLER`; Zed named: Zed's window (37 ms) | Finder selects `w32-32.txt` |
| one link inode with entries in **two directories** (`dA/L` and `dB/L`, one inode), `dA/L/two-dir.txt` | TextEdit `two-dir.txt` (46 ms) | Finder shows `dA/sub` with `two-dir.txt` selected |
| a finite repeated **dot-link** (`wdot/dot/dot/dot/dot-f.txt`) | TextEdit `dot-f.txt` (57 ms) | Finder selects `dot-f.txt` in `wdot` |
| a **300-byte multibyte** name (100 × U+65E5) | TextEdit's window (56 ms) | Finder selects it |
| a **combining-character** name (`cafe` + U+0301 …) | TextEdit's window (63 ms) | Finder selects it |
| an **emoji** name | TextEdit's window (49 ms) | Finder selects it |
| a **final directory with mode 0600** (never searched) | acknowledged (`AVAILABLE`); no window, as for an independent `open` of the same directory | Finder selects `closed-dir` in its parent |

The 32-link chain resolves after its 32nd expansion, as the kernel's limit and the spec say; the one link
inode in two directories is present, not a cycle, because the walk's state includes the containing directory.
The directory with mode 0600 resolves present and is revealed. Opening it is acknowledged and neither route
opens a window, so that row records an effect of *nothing visible*; its positive evidence is the reveal.

### A chain of more than ten links has no default handler

The 11-, 31- and 32-link chains are present and resolved, yet a **default** open of them answers
`NO_DEFAULT_HANDLER` ("No application is registered on this Mac to open this item"), while the 10-link
chain opens in TextEdit and the same chains open with an application named. This is the platform, not
Koine's walk: the recipe also asks `NSWorkspace.urlForApplication(toOpen:)` itself, exactly as Koine's
adapter does, in a plain program ([handler-lookup.swift](target-locations-vm/handler-lookup.swift)), for
the Nth link of one chain:

```
1 TextEdit.app;5 TextEdit.app;9 TextEdit.app;10 TextEdit.app;11 nil;12 nil;16 nil;20 nil;31 nil;32 nil
```

Launch Services follows ten symbolic links when it looks up a handler and answers nil from eleven. The
spec already maps a nil handler for a target the walk found to `NO_DEFAULT_HANDLER`, so Koine is doing what
it says; but a client that sends a 31-link chain by default will be told no handler exists where one does.
Naming an application avoids the lookup and works, as the table shows. This is the spec's
[`NO_DEFAULT_HANDLER`](../specs/workspace-launch-and-open.md#operations) mapping, observed rather than changed, and
is recorded rather than fixed here (the repair is action-only and adds no reason).

## The roots

Reveal, with and without a trailing slash (Finder's own account of its front window):

| Path | Finder shows |
| --- | --- |
| `/`, `//`, `/.`, `/..` | the root view: a window on `/`, nothing selected |
| `/Volumes/Macintosh HD`, a link to `/` | a window on `/Volumes/` with `Macintosh HD` selected: the link itself |
| `/Volumes/Macintosh HD/` | the root view |
| `/var/..` (recorded, not asserted) | a window on `/` with `var` selected (`/private/var/`) |

These are the accepted forms: the root view only when `lstat` of the literal path names the root's own
device and inode. For reference only, an independent `open -R` selects the link in `/Volumes/` for both
spellings, so it reads the trailing slash differently from Koine's accepted rule.

## First use in the protected folders

The brief: *first-use resolution in Desktop, Documents and Downloads is prompt-free in the signed app. If it
prompts, the leaf stops and goes to Antony.* A document and a directory were made in each folder by the test
agent (which has Full Disk Access, so making them prompts nothing). Every case reset Koine's consent first,
so each is a first use.

**The positive control comes first.** A standalone probe ([descriptor-walk-prompt.md](descriptor-walk-prompt.md))
reading a Documents file raised "KoineK174Probe would like to access files in your Documents folder" and the
observer read it, so the observer could have seen a prompt. Koine's rows in the consent databases were read
before and after each case.

**Resolution never prompted; every open did, once.** Run 3 declined each request, and found the open
prompted in all three folders ([run3](target-locations-vm/run3/results.json)). Antony then said to do this in
the disposable clone, where the dialog can be approved, so the recipe now allows it
([run4](target-locations-vm/run4/results.json), the cited run for this table). Each open: the first request
answered `failed` ("did not acknowledge the open request within 3 seconds … the request was not repeated",
the bounded-acknowledgment contract working while a dialog stands); the dialog "Koine would like to access
files in your *folder* folder" was allowed, leaving the row `kTCCServiceSystemPolicy…Folder | dev.antony.Koine | 2`;
**the first request then completed** (Finder's or Zed's window named the item); and a **second request**, from
a clean state, was acknowledged `AVAILABLE`, showed its window at the first read and raised no dialog.

| Request to Koine | Desktop | Documents | Downloads |
| --- | --- | --- | --- |
| reveal a **document** | no prompt | no prompt | no prompt |
| reveal a **directory** | no prompt | no prompt | no prompt |
| open a directory with **Finder named** | prompt, allowed; opened; second request prompt-free | the same | the same |
| open a directory by its **default handler** | the same | the same | the same |
| open a document with **Zed named** | the same (Zed's own request for the document was allowed too) | the same | the same |

A default open of a *document* in these folders was **not** made: its handler lookup is the known,
separately decided prompt (`protected-default-open-k89`).

**What this shows, and what it does not.** Resolution is prompt-free: a reveal runs the same descriptor walk
as an open, and it never prompted in any folder, for a document or a directory. The prompt comes after the
walk, when the request is submitted to the system. A plain program that is not Koine, an ad-hoc-signed app
started through Launch Services ([submit.swift](target-locations-vm/submit.swift)), calling
`NSWorkspace.open` on the same items, raised the same dialog naming *itself*:

| Plain program (not Koine) | Prompt |
| --- | --- |
| a document in `/tmp` handed to Zed | none |
| a document in Desktop, in Documents, in Downloads handed to Zed | "KoineK180Submit would like to access files in your *folder* folder" (and then Zed's own, for the document it was handed) |
| a directory in Desktop opened by its default handler | "KoineK180Submit would like to access files in your Desktop folder" |

So the prompt is the platform's, for any application that hands an item in a protected folder to another
application. It was not caused by 1.0.1's walk, and the repair neither adds nor removes it. What it does
contradict is an assumption written into the earlier layers: that *named-application opening* and a
*directory's* open are prompt-free ([protected-path-metadata.md](protected-path-metadata.md#handler-lookup-limit)
measured the handler lookup and the metadata calls, and left submission unmeasured). A named application does
not avoid the prompt, so the spec and the client guide were corrected. A person using Koine meets the dialog
the first time an open reaches such a folder, and a client that wants to avoid it can reveal instead.
Approving it here is the disposable clone's user, not a Koine consent flow: whether Koine ever asks for that
access itself is `protected-default-open-k89`'s question, whose brief now carries this evidence.

## Evidence and limits

- Transcript: [detached-20261008T044150.log](target-locations-vm/run3/detached-20261008T044150.log) (also
  `.build/vm-verify/target-locations-vm-20261008T044150.log`); the results (97 rows: 84 passed, 4
  recorded, 9 prompted: the prompts declined) are [results.json](target-locations-vm/run3/results.json), and the guest's descriptor
  check, the manifest of subjects and the screenshot of each prompt are beside them in
  [target-locations-vm/run3/](target-locations-vm/run3/). The recipe digested its 15 subjects
  (the script, the fixture builder, the observer, the three diagnostic sources, the libraries, the witness and
  probe archives, the client bundle, Koine's executable and the workspace provider's manifest) before and
  after, and they were equal.
- **Four runs.** The first ran the older recipe and found that its 31- and 32-link chains had links with no
  file extension (the default handler is looked up for the literal name): a fixture fault, not Koine's. The
  second named the links and found the ten-link lookup limit and the prompt matrix; it is kept in
  [run2/](target-locations-vm/run2/). The third is the cited run, after the recipe separated Zed's own prompt
  from Koine's (Zed is quit before each case) and cut the per-case prompt watch to 150 s; it is the cited run for
everything but the open rows of the prompt table. The fourth ran only the `prompt` section after Antony's answer (the
  recipe now allows Koine's request in the clone): 16 rows, all passed, exit 0, transcript
  `.build/vm-verify/target-locations-vm-20261008T120956.log`, kept in [run4/](target-locations-vm/run4/). Run 1's results are in
  [run1/](target-locations-vm/run1/). Nothing here is taken from a run of a recipe that was edited under it.
- One macOS (26.5), one architecture, one clone, **one sample** of each cell. Zed 1.22.0 and the other
  applications are as the image holds them.
- A directory with mode 0600 was *revealed* (positive); its *open* is acknowledged and shows no window by
  either route, so it is recorded and not a positive effect.
- Zed's and TextEdit's delivery is seen by their windows' titles (the control saw the same); the exact bytes of
  a delivered path are seen by the witness application and, for a reveal, by Finder's account. The roughly
  1,500-byte variants of the walk outcomes are seen through the refusal that names the resolved spelling, which
  [reveal-locations.md](reveal-locations.md) and [open-path-locations.md](open-path-locations.md) already
  record, and are not repeated.
- Not covered here: the over-limit **application** path and a long copy of a short application
  (`application-locations-vm`), removable and network volumes, other macOS builds, and a default open of a
  protected *document*.
