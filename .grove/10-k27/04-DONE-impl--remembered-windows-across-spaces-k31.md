# remembered-windows-across-spaces-k31

## Goal

Preserve useful knowledge across Spaces without claiming complete knowledge:
windows Koine has seen that current enumeration no longer returns are listed
as `REMEMBERED`, are removed when their end is observed, and are always
revalidated on selection.

## Context

- Spec: the third and last paragraphs of "Resource references and desktop
  behavior"; the residency rationale in "Application composition and
  availability"; "observation startup" and cancellation in the native-binary
  row of "Test seams and acceptance".
- Modaliser's `WindowCache.swift` (windows remembered across Spaces), to learn
  from, not copy.
- The provider's `start`/`stop` lifecycle in `KoineProviderAPI` and the
  README's "Lifecycle".

## Done when

- The provider keeps private observation state from `start()` to `stop()`.
  `DesktopApplication.windows` returns currently enumerable windows as
  `CURRENT` and known windows that enumeration omits as `REMEMBERED`, each
  once, with the same reference a window had while current.
- Current enumeration refreshes what is remembered, including titles. Observed
  window destruction and application termination remove entries; a terminated
  application leaves none. Entries for a process incarnation that has ended
  never appear under its successor.
- `desktopWindow` and `desktopFocusWindow` revalidate a remembered window like
  any other: if it no longer exists the result is `unavailable`, never success
  from memory. Focusing a remembered window on another Space behaves as
  `focus-exact-window-k30` recorded.
- The engine still caches nothing: remembered state is reachable only through
  the provider's resolution, and `stop()` ends observation within its bounded
  wait, leaving `KoineServer.stop()` prompt.
- VM verification against the signed build with two Spaces and real
  applications: a window seen, then left on another Space, is `REMEMBERED`;
  returning makes it `CURRENT`; closing it while observable removes it; closing
  the management window leaves observation running, shown by a window opened
  and moved afterwards still being remembered. What is incomplete is recorded
  as such: a Space Koine never observed, and a disappearance that was not
  observable.
- The verification task is in `Taskfile.yml` and the README; the evidence is
  under `docs/verification/`.

## Notes

Which native notifications make destruction and termination observable, and
whether they need Accessibility consent, is for this leaf to establish against
the platform. If the identity leaf's mechanism cannot enumerate windows on
other Spaces at all, remembering is the only source for them; if it can, say
what `REMEMBERED` then adds and keep the contract's meaning.

How a VM script creates a second Space and moves a window to it is an unknown
of this leaf. If TestAnyware cannot drive it, stop and say so rather than
substituting a mock.

## Decisions (running log)

- `REMEMBERED` is a view over the identity table, not a second cache: a row is
  remembered when its element is held and the application's `AXWindows` omits it
  now. Same token, so same reference. The bookkeeping is pure
  (`Logic/HeldWindows.swift`) and host-tested; the host cannot make
  Accessibility calls.
- A held element answers from another Space (k28 evidence), so a remembered row
  is asked directly at listing time and its title refreshed; the stored title is
  the fallback only when the application does not answer. What `REMEMBERED` adds
  is the enumeration itself: `AXWindows` cannot list another Space.
- `desktopWindow` reports the same observation a listing would, by checking
  whether `AXWindows` contains the held element now; one more read, and the
  lookups keep agreeing.
- Observation from `start()` to `stop()`: `NSWorkspace` termination (no consent
  needed) and one `AXObserver` per listed process for
  `kAXUIElementDestroyedNotification`, on the main run loop, handed to the
  provider's queue. It retires a token at once, the defence the identity
  document names. It is not observable through GraphQL apart from the row going,
  which asking the element again also achieves; the probe's `observe` command
  is the native evidence that the notification fires.
- No window-creation observation of applications no client has listed: Koine
  holds only what a listing saw. Proportionate, and Modaliser's cache did the
  same.
- The second Space in a VM is a full-screen window (⌃⌘F, then ⌃←), as
  `focus-exact-window-k30` already drove.
- The leaf's one in-session reviewer is spent on `WindowObservation`: refcon
  lifetime and the hand-over from the main run loop to the provider's queue,
  which no compiler or host test can establish.
- The reviewer's findings, classified. Valid and fixed: `observation?.forget(
  table.forget(…))` skipped the table when there was no observation, so `stop()`
  forgot nothing; a late termination notice could forget a successor that reused
  the PID (the kernel is asked now); no `deinit` removed run loop sources; a dead
  incarnation met only by reference was never forgotten. Visible trade-off: a
  retired watch leaks where no main run loop runs, which is a host without
  consent, where none is made. No second review: the fixes are mechanical.
