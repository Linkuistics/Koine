# open-path-vm-k76

## Goal

Accept path opening at V with real handlers and disposable fixtures in the
prepared VM, and widen the public contract checks to the path root.

## Context

- The workspace spec's Documents/directories/settings and Input boundary rows.
- The prepared VM from `application-launchers`.

## Done when

- The fixtures are a temporary text file, a directory and a document package.
  Each opens with its default handler and with Zed named.
- The configuration directory opens in Zed.
- Missing file, parent, link, application and handler cases produce their typed
  results. Inspection denial is `failed`. Literal spaces, punctuation and
  symlinks are honored.
- No handler setting is changed.
- A source script opens in its default editor and in named Zed whatever its
  executable bits. Finder aliases to documents and to applications are refused
  before dispatch.
- In disposable fixtures, Terminal script and location-document reactions are
  observed and recorded as disclosed handler reactions, without claiming a
  sandbox.
- Accessibility is absent throughout, and the operation still works.
- The workspace profile includes the path root, and the contract-only client
  opens a document and a directory.
- The spec rows and the Client settings trace row link the evidence document.

## Decisions (running log)

- **What opened is read from the window server, not from Koine's answer.** The handler's own
  window must appear (`testanyware agent windows`, an application whose title names the fixture),
  every fixture name is unique to its case, and a window already carrying the name before the
  request fails the run (a case that could pass for another's open proves nothing). Probed by
  hand before the script: Zed titles a directory window with the directory's name, a file in an
  open worktree as `dir — file`; TextEdit with the file name; Finder with the folder name; Code
  with the file name. `LaunchWitness` still supplies activation and the kernel's identity for the
  receipt's process, as for the URL.
- **The image's handlers are the cases' premise, and the run checks it.** Read in the clone:
  `.txt` and `.rtfd` TextEdit, folders Finder, `.swift` Visual Studio Code, `.py` `.json` `.md`
  Zed, `.js` Safari, `.sh` and `.zsh` iTerm, `.command` and `.terminal` Terminal, a typed
  `.webloc` Safari, `.fileloc` TextEdit when it is a real property list (Finder for the empty
  placeholder first probed), `.unknownzzz` none. So "a source script in its default editor" is
  Swift (Code) and Python (Zed, which is also the named application there, so its two files are
  default-only and JavaScript is the Zed-named pair); JavaScript's default is Safari, which is
  not an editor. The run fails if `.py`, `.swift` or the no-handler type differ.
- **Fixtures are made in the guest by one idempotent script** (`scripts/vm-open-path-fixtures.sh`):
  the agent's exec channel can run a command twice, and the second run met the first's `locked`
  directory (mode 000), so the script reopens it before removing. The alias files are real
  bookmark-file aliases made by the protected-path probe's `make-alias.swift` (compiled in the
  guest); a name with decomposed Unicode is created and compared by its bytes, since the channel
  re-normalises a Unicode command line. Nothing is under Desktop, Documents or Downloads: the
  protected default case stays pending its consent decision.
- **The refusals run as one batch under one watch**, as the URL's did: 25 requests and 4 denied
  ones, then no application launched or activated, the front application unchanged and the set
  of windows equal before and after. Per-case round trips to the guest cost seconds each.
- **Reactions are recorded, never asserted.** A handler's response to a script or location
  document is the handler's (spec: no sandbox). Each is sent to its default handler with a marker
  or a page-server request or a window as the witness; the case fails only if the open is not
  acknowledged. They are marked `recorded`, and the evidence document says what each did.
- **The contract-only client gained `open-path` from a reading-restricted pass** (as `launch` and
  `open-url` did), against a capture re-taken from the signed build (`task client:capture`, schema
  digest `f98a3862...`, the workspace profile at V passing with the path root in the design file).
  Its ten findings are in `docs/verification/open-path-contract-client-findings.md`.
- **Three script faults found by running it, and fixed before the evidence run:** `grep -q` in
  a pipeline under `pipefail` failed the image check by SIGPIPE; a jq `contains(.)` compared a title
  with itself (every window "matched"); an unreadable window list was taken as "no window". Each
  was a failure of the instrument, not of Koine.
- **Evidence run and what it showed** (`scripts/vm-verify-open-path.sh`, 2 h 48 min, exit 0, transcript
  `.build/vm-verify/open-path-vm-20261002T210940.log`, results kept in
  `docs/verification/open-path-vm/results.json`): 20 opens each with the handler's window naming the fixture
  and the receipt's process equal to the kernel's; 25 refusals/dependencies/failed with the windows equal
  before and after; four denied requests; six recorded reactions (Terminal ran the 0755 `.command` and not the
  0644; iTerm wrote no marker for either `.sh`; Safari requested the `.webloc` page; TextEdit opened the
  `.fileloc` target); handlers and the LaunchServices settings digest unchanged; Accessibility absent with
  no dialog after any of 26 opens. The `task conformance` three profiles pass at digest `f98a3862…` with the
  path root's removal seen red.
- **The pending protected case is a leaf, not prose:** `protected-default-open-k89` (design, root, ahead of
  `baseline-acceptance`), the same reason `dia-url-page-load-k88` exists; the node brief says so.
- **The evidence run takes ~3 h and a harness background task is killed at 2 h**, so the full run was launched
  detached from the harness (`start_new_session`), and its sections were iterated by `KOINE_OPEN_PATH_ONLY`
  first. The partial runs are not evidence; the cited run is one whole run of the final script (digested at
  start and end).
- **In-session review (the leaf's one allowance), on the evidence document.** A fresh context read
  `open-path-vm.md` against the transcript, `results.json`, the recipe and the spec, hunting overclaims
  and vacuous passes; 21 findings, all classified. *Valid and fixed in the documents:* "every fixture
  name is unique to its case" (unique within an application's windows, and the reaction cases have no
  before-state; the spec's copy of the sentence too); the refusal classes (the recipe asserts the
  class, not the message, so the mapping is read from the messages `results.json` recorded, now said
  and checked row by row); the decomposed-Unicode case (APFS treats the spellings as one name, so it
  cannot show the path was not normalised; that rests on L); application versions "read by the run"
  (from the image's inventory; Koine's 0.1.0 and executable digest stated, the run prints neither
  versions nor the schema digest); "fails if the premises do not hold" (three are asserted, the rest
  are caught by each case needing its own handler's window); the `.fileloc` explanation and the
  "empty placeholder gave Finder" history (not in the cited run, removed); the agent-timeout and
  "five minutes a case" claims (the gaps are 30 s to 11 min; removed); Accessibility moved from
  passed to inferred (`osPermissions[0]` is not asserted to be Accessibility; the consent text search ran
  once); the revoked-grant cause; the `universalAccessAuthWarn` explanation; the spec quotation
  ("a location, not a file" is not in the spec; and the run does not tell the handler's link-following
  from Koine's `realpath`); "was handed the document" for the reactions (acknowledgment and activation
  only, Terminal cold for the first and warm for the second, observation window not timed); the
  `inspection-denied` explanation (the target could not have been opened anyway); Koine's own Gatekeeper
  rejection (unnotarized, no quarantine attribute; now disclosed); the digest set not covering the provider
  bundle; the client counts (re-run: 1,417 `ok`, 479 naming `open-path`, bundle digest equal); `/tmp` being
  a symlink and the Windows-executable type (not printed; reworded); the spec summary of source scripts
  (Python is default-only, JavaScript Zed-named); the intro's list of what the recipe does.
  *Valid, and a visible trade-off recorded as a limit:* the refusal batch's witness has no liveness
  control and its window comparison is weak (lists not printed, no non-empty guard, and the refused
  targets already had windows from earlier cases), so V shows only that no application launched or
  activated; nothing submitted on a refusal rests on the answers and L/N. Fixing the instrument would
  mean another three-hour run for a claim L and N already carry. *Noise:* none.
