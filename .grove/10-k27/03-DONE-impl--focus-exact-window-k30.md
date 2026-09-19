# focus-exact-window-k30

## Goal

Complete ModalAnyware's path: `desktopFocusWindow` focuses exactly the window a
reference names, or reports why it did not, and never focuses a substitute.

## Context

- Spec: the `Mutation.desktopFocusWindow` and `DesktopFocusReceipt` rows; the
  last three paragraphs of "Resource references and desktop behavior";
  "Mutation preflight and revocation".
- The identity evidence from `application-identity-and-window-listing-k28` and
  the re-resolution from `reference-lookups-and-accessibility-permission-k29`.
- Modaliser's `WindowManipulator.swift`, to learn from, not copy.

## Done when

- `desktopFocusWindow(ref:)` is served under `desktop:control` and returns
  `DesktopFocusReceipt { ref }`, the submitted reference, under control
  authority alone: a grant with `desktop:control` and no `desktop:read`
  focuses and reads the receipt, and the receipt exposes no window read field.
- Order of work: re-resolve the target, check Accessibility consent, confirm
  identity, and only then act. Missing consent is `permission` /
  `os-permission`; a target that cannot be re-established is `unavailable`.
  Neither activates the application or changes focus.
- The provider may activate the owning application to bring the target into
  view. Every native step's failure is reported as `failed` with a useful
  message, including a failure after activation; none is swallowed. Success
  means the native focus and raise completed against the resolved window.
  Native waits are bounded and the action honours cancellation.
- VM verification against the signed build with real applications, confirming
  the outcome by observing the focused window natively: the chosen one of two
  windows with the same title is focused, in both orders; a window of a
  background application and a minimised window are focused; a window on
  another Space is focused or the failure is reported, whichever the OS allows,
  and recorded; after the window closes, after the application quits, and after
  it restarts (the observable PID-reuse case), the result is `unavailable` and
  focus does not move; ambiguity by the identity leaf's evidence is
  `unavailable`.
- `DesktopChoices` and `FocusDesktopWindow` from
  `docs/design/desktop-operations.graphql` validate and run unchanged against
  the signed build.
- The verification task is in `Taskfile.yml` and the README; the evidence is
  under `docs/verification/`.

## Notes

The engine's preflight, admission and revocation ordering are already proven
against the fixture provider; do not re-prove them here. This leaf proves the
native action.

If focusing turns out to need an API the identity leaf did not examine, and
that API is private, the identity leaf's stop-and-ask rule applies here too.

## Decisions (running log)

- **Success is observed, not inferred from return codes.** `NSRunningApplication.h`
  says `-activateWithOptions:` returns whether the request was *sent* and does
  not guarantee activation. The receipt is returned only once the application
  reports itself frontmost with the held element as its focused window, polled
  for at most three seconds; otherwise `failed`, saying what had already happened.
- **Step order: restore if minimised, make main, raise, then activate**, so the
  application comes forward with the chosen window already in front. All public
  Accessibility API plus `NSRunningApplication.activate(options:)`; nothing
  private, so the stop-and-ask rule was not triggered.
- **The wait runs off the provider's queue**, hopping on for each check: reads by
  other clients are not held behind a focus, and `Task` cancellation is visible
  (a dispatch closure cannot see it). Cancellation is checked before acting and
  ends the wait.
- **One re-resolution for reads and focus**: `held(referencedBy:)` was extracted
  from `window(referencedBy:)`, so focus decides `unavailable` before the trust
  check exactly as `desktopWindow` does, then consent, then the own-window check.
  A window that ends mid-action (`kAXErrorInvalidUIElement`) is `unavailable`;
  `kAXErrorAPIDisabled` mid-action is the os-permission error.
- **The native witness is the existing signed probe**, given a one-shot `focused`
  mode: the system-wide focused application and window, with the private window
  id as witness (test material only, as before). Same-titled windows need no map
  from reference to id: A→B→A must read X→Y→X with X≠Y.
- **Shared desktop VM helpers moved to `scripts/vm-verify-desktop-lib.sh`**, and
  focus got its own script and task: the existing run is already twenty-five
  minutes.
- **Host suite hang, fixed in the harness.** Six more suites constructing servers
  in parallel deadlocked `swift test`: signature validation blocks on work
  Security dispatches to the global queues, and `offPool` used that same bounded
  pool. `Harness.makeServer` now constructs on its own serial queue.
- **A foreign reference needs the foreign provider's control too.** Preflight
  resolves reference authorities from arguments (spec, "Mutation preflight and
  revocation"), so `desktopFocusWindow(ref: koine://fixture/…)` under
  `desktop:control` alone is a capability refusal before any provider is asked.
  The engine was right and the first draft of the host test was wrong; the test
  now holds `fixture:control` and the desktop provider answers `unavailable`.
- **Runs 3 and 4 failed on the witness, not the guest or Koine.** The probe's
  system-wide `kAXFocusedApplication` answers `kAXErrorCannotComplete` from a
  command-line tool in the VM with an application plainly in front. An earlier
  entry here blamed an environment wedge on one occurrence; the second failure at
  the same step, with the VM kept, disproved that. The witness now takes the
  front application from `NSWorkspace` and asks that application for its focused
  window, with the window server's front window as a second witness.
- **AppKit activation is closed to a background service; the application is
  brought forward by setting `AXFrontmost`.** In the VM
  `NSRunningApplication.activate(options: [])` answered `false` for Finder, and
  Koine reported `failed` and moved nothing
  (`docs/verification/desktop-focus/appkit-activation-refused.json`).
  `NSRunningApplication.h` deprecates `activateIgnoringOtherApps` as having no
  effect from macOS 14, and `activate(from:)` needs the active application to
  yield. `AXFrontmost` is public; the header does not say it is settable, which
  the code states, and the observed-focus wait is the proof. Public API, so no
  stop-and-ask. Tried by hand in the kept VM: A→53, B→52, A→53, same title.
- **Identity confirmation and the native steps are one turn on the queue**, so
  no listing can come between them; cancellation is checked before that turn.
- **Run 5 passed A→B→A (53, 52, 53, same title) and then lost an exec, not a
  focus.** TestAnyware reported a focus as timed out twelve times running while
  its output held Koine's correct receipt: the agent's false timeout comes in
  bursts no retry bound absorbs. `guest_json` in `scripts/vm-verify-desktop-lib.sh`
  accepts a complete one-line JSON answer whatever status the agent reports; a
  truncated answer does not parse and still fails (both seen). Opt-in, so the
  earlier verified scripts keep `guest` as it was.
- **Run 6 passed (exit 0, subjects unchanged, no exec exhausted) and is not the
  evidence.** Read item by item, its minimised step could not fail: nothing read
  the window's state after ⌘M, and `minimized: false` afterwards is what a window
  never minimised shows. The probe gained `windows <pid>`; the script now requires
  `minimized == true` before that focus, and that the full-screen window is
  absent from the desktop Space's listing before the other-Space focus. Run 6's
  other readings: other-Space focus succeeded and macOS switched Spaces; the
  window server's front window there is a full-screen backing window (97), not
  the focused window's id (59), so the front-window witness is asserted by
  application, never by number.
- **Run 7 is the focus evidence** (exit 0, subjects unchanged, no exec exhausted;
  `docs/verification/desktop-focus-vm.md`). No ADR: bringing the application
  forward through `AXFrontmost` is a one-line choice, not hard to reverse, so it
  is recorded in the code and the verification document.
- **The existing `app:vm-verify-desktop` is re-run**, because its helpers moved
  and the read path beneath it now goes through `held(referencedBy:)`. Its first
  re-run passed every step up to the Koine restart and ended there on an
  exhausted `open` in `launch` (no assertion failed; not counted as green).
  `launch` no longer dies on that exec's status: the window and the endpoint
  descriptor it then waits for are the proof.
- **`app:vm-verify-desktop` re-run: PASSED**, exit 0, all steps, subjects
  unchanged (`.build/vm-verify/desktop-20260920T042411.log`).
