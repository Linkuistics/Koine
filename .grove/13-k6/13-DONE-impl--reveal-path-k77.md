# reveal-path-k77

## Goal

Serve `workspaceRevealPath` complete to its design and accept it at L, G, N and
V. Because this lands the last workspace root, the conformance profile then
requires the complete design SDL.

## Context

- `docs/specs/workspace-launch-and-open.md`: the reveal paragraphs, the failure
  table, and the Finder reveal and Input boundary rows.
- The path inspection from `open-path-k75`, and the prepared VM.

## Done when

- A literal absolute path is inspected as for opening. A missing path is
  `PATH_NOT_FOUND`, and missing Finder is `APPLICATION_NOT_INSTALLED`.
- Finder's native selection is requested with its boolean acknowledgment, inside
  the same one-shot three-second bound. A false result is `failed`. There is no
  AX, keystroke or menu check.
- The receipt echoes the submitted path.
- L: with the adapter substituted, cover missing Finder, false acknowledgment,
  late acknowledgment and cancellation.
- G: composition tests cover authority, branches and multi-action behavior.
- N: the real bundle serves the widened contribution.
- V: reveal a file, a folder, an application bundle, an alias and the filesystem
  root. Observe the actual selection or root view, and record that the receipt
  alone is not selection. Accessibility is absent throughout.
- `task conformance` now requires the complete workspace design SDL. The
  contract-only client reveals a path.
- The spec rows link the evidence. So do the trace rows that reuse reveal:
  Application search and File search.

## Decisions (running log)

- **Order and shape.** `planReveal` (Logic/RevealPath.swift) is the whole decision: validate the path as
  input (the same `LocalPath` as opening), inspect it with the same `inspectPath` (absent is
  `PATH_NOT_FOUND`, unreadable is `failed`), then check Finder through launch's own `selectInstallation`
  for `com.apple.finder`, then submit. A missing path therefore wins over a missing Finder, as a missing
  path wins over a missing named application for opening. There is no refusal policy (an application
  bundle, executable or alias is the thing to reveal) and no handler lookup.
- **Finder's reasons collapse to one.** `selectInstallation` can answer `APPLICATION_NOT_INSTALLED` or
  `APPLICATION_IDENTITY_MISMATCH`; the spec gives a reveal only `PATH_NOT_FOUND` and
  `APPLICATION_NOT_INSTALLED`, so a registration whose bundle is gone, an unregistered Finder and a
  bundle with another identifier are all `APPLICATION_NOT_INSTALLED` with Finder-specific guidance. An
  unreadable Finder bundle is `failed`.
- **One native call, two documented forms.** `revealPath(_:completion:)` on the private adapter takes the
  inspected path as written and answers through the same one-shot `LaunchCompletion` as launch and open
  (`.acknowledged(nil)` for true, `.refused` for false), so the three-second bound, cancellation, late
  callbacks and the shared capacity of 16 are not reimplemented. `selectFile` is synchronous and talks to
  Finder, so the adapter runs it on a global queue, never a cooperative thread. The item form is
  `selectFile(path, inFileViewerRootedAtPath: "")` ("the file is selected in the main viewer", per
  NSWorkspace.h) and the root form `selectFile(nil, inFileViewerRootedAtPath: "/")` (a nil path "opens the
  directory specified by rootFullPath, and not select any file"), chosen when the inspection says the path is the filesystem root (first by its standardized spelling, then, after the review below, by file identity).
  A throwaway probe in a VM showed the other root form, `selectFile("/", "")`, selects the volume inside
  the Computer view, which is not a view of the root; the nil form shows `/` with nothing selected.
- **Receipt.** `{status: AVAILABLE, value: {path}, dependency: null}`, the path being the submitted one;
  `process` is never observed (a reveal has no application to observe), so `submit` gained an optional
  receipt builder instead of a second submission path.
- **The root's SDL.** `schema.graphql` is now the design file's body, verbatim, with only its header
  comment its own; N asserts body equality, so any later rewording turns it red. The profile's design
  file gained the root and its two types in the design file's declared order, and
  `workspaceCoordinatesNotYetImplemented` is the empty set (a test says any future root must be named).
- **Call-path check widened, not loosened.** `selectFile` was forbidden outright in the call-path check;
  it is now allowed in exactly two source forms inside one function, run on a global queue, with the
  bundle carrying exactly the one selector, and `activateFileViewerSelecting` took its place on the
  forbidden list. Each new check was seen red against a mutated source (root form, item form, a main-queue
  call, a third request, the forbidden alternative).
- **The contract-only client's reveal was written by this leaf, not by a reading-restricted pass.** It is
  `open-path`'s reading with `{ path }` for `{ process }` (`workspace-reveal.ts`, `reveal-stubs.mjs`), so
  the independence the earlier passes had is not claimed for it, and the README says so.
- **V reads Finder from outside Koine.** What Finder showed is read by an independent observer: Finder's own
  account (AppleScript: front window's folder, selected item's path, kind and name) run from the test
  agent. The first question to Finder raises a consent dialog for `testanyware-agent`, the harness and not
  Koine; it is allowed once, in the disposable clone, before Koine starts. A symlink reads at its target's
  path (the alias coercion resolves it), so the item's name and kind (`Alias`) say it was the link that was
  selected. Each case starts from a Finder with no window, so a window and selection after the request are
  the request's doing.
- **In-session review (the leaf's one allowance), on the reveal's implementation and L tests.** A fresh context
  was given the contract and the code, read-only, and asked to find what was wrong. Valid and fixed: the root
  view was decided by `URL(fileURLWithPath:).standardized` on the *spelling*, so `/var/..` (the kernel's
  `/private`, since `/var` is a symlink) would have been given the root view while the item inspected and echoed
  was another, and a root spelling Foundation did not collapse would have been sent in item form; the decision
  is now `PathFacts.isFilesystemRoot`, read by the inspection from `lstat` equal to `lstat("/")` and passed to
  the native call, so a symlink to `/` is a link and the rule is the filesystem's. Valid test gap, fixed: the
  root-versus-item branch lived only in the adapter, so every mutation of it survived L; it is now data the
  logic passes (`filesystemRoot`), and L holds that `/`, `//`, `/.`, `/..` pass the flag the inspection
  reported, `/var/..` does not, and an ordinary item never does. The real `lstat` rule was run once on the host
  against those spellings (throwaway, not committed) and V saw `/` and `//` as the root view. Visible
  trade-off, accepted: reveal reuses the open inspection, which fails on missing type metadata that a reveal
  does not use (the spec says to inspect as for opening, and `stat` and `realpath` have succeeded by then).
  Valid, trivial, fixed: the capacity message said "launch" for every root, and the spec still called the
  reveal root pending. Held up under its attack: path-first ordering, Finder reported as absence only for
  absence, inspection failures never absent, the one-shot, slot and timer accounting for a synchronous call on
  a global queue, the receipt carrying only the path and never an observed process. Not verified by it:
  whether `selectFile` is safe off the main thread (V saw it work). The fix is covered by executable seams (L,
  V's two root cases and the host rule), so no second review is spent and no `review-impl` leaf is cut.
- **The V run found things the contract did not ask for, recorded and not worked around.** (1) With another
  application in front, the eight item cases did not bring Finder forward (the witness saw no activation and the
  screenshots show Finder behind Calculator) while the two root views did; the contract asks for no activation
  on a reveal, so no case turns on it, the guide says not to rely on it, and the script reads activation once
  instead of waiting 40 s a case on the guest's slow exec channel. (2) Finder reads a `..` in a path its own way
  (`/var/..` showed the root with `var` selected), so the guide says to send a clean path. (3) Revealing a
  third-party application bundle made macOS post "Koine was prevented from modifying apps on your Mac"; a
  bounded probe (system applications and an inspection-only refusal raised none, and a throwaway call of the same
  `selectFile` raised none) is in `reveal-path-vm.md`, and the posture question is cut as
  `reveal-app-bundle-notice-k90` ahead of `baseline-acceptance` with a recommendation to accept and disclose. No
  entitlement, consent or signing change is made.
- **Evidence runs.** Three earlier runs of the V script are not evidence (an instrument fault in the observer's
  consent step, a run of the pre-fix provider code stopped for the review's finding, and a run stopped for the
  activation wait). The cited run is one whole run of the final script, its ten subject files digested before
  and after; `task conformance` passes all three profiles at digest `3bab3a04…` with the same build, the reveal
  root's removal seen red; `task client` passes (277 reveal checks of 1,694); the call-path check passes with the
  new checks each seen red. Full `swift test` runs: two of three entirely green, the third failing only the
  known intermittent `denialInsideADependency…` family (`stabilise-dependency-denial-test-k87`), which also
  failed together with its sibling in the two `task test` runs earlier in the session.
- **Not done here, by design.** The workspace grant disclosure (`workspace-disclosure`), multiple installed
  copies (`application-installations`) and Dia's page load are other leaves'. The ADR set needed nothing: no
  decision here changes a recorded one (the root's existence and authority were in `provider-authority-follows-effects`).
