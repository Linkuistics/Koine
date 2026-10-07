# receipt-executable-identity-k183

## Goal

Receipt observation identifies the live process's executable and the retained
application object's executable with the same descriptor-relative walk, in the
same device-and-inode representation, so an acknowledged launch is never turned
into `process: null` by a path that only the whole-path primitives could not
address, and a mismatch is still a mismatch.

## Context

- `docs/specs/workspace-launch-and-open.md#resolving-an-action-location` (the last
  sentence of the absence paragraph: receipt observation resolves the live
  executable's kernel path, `proc_pidpath` up to 4,096 bytes, the same way, with
  the existing null rules) and `#application-hand-off-limit` (the closing sentence
  on `process: null`).
- Review k171 finding R1: neither identity route calls `inspectApplication`, so no
  stage leaf converts them. They are
  `NativeWorkspace.liveExecutableIdentity(of:)`,
  `RunningApplication.executableIdentity` and the shared
  `fileIdentity(ofPath:)` (`URL.resolvingSymlinksInPath` and pathname resource
  values), compared by `Providers/WorkspaceProvider/Logic/Observation.swift`
  `observeProcess` at its third step.
- The walk from `reveal-locations-k174` and the device-and-inode comparison of
  `application-locations-k176`, whose identity representation this leaf must share.
- `docs/verification/launch-vm.md` for the retained observation rule and its
  timings.

## Done when

- Both identities are acquired by the walk and have one representation. The
  retained rule is otherwise unchanged: an unavailable value or a mismatch is
  `nil`, with no PID-only identity, launch-date substitute or foreground fallback,
  and the start-sample, retained-object, terminated and fresh-lookup steps of
  `observeProcess` are untouched.
- **Observation has its own resolution rule, and it is not the hand-off rule.**
  The action was already acknowledged, so the limit does not apply: a present
  executable of any length yields its identity, and every walk outcome other than
  present (absent, cycle, impossible name, link budget, denial, any other
  failure) yields no identity and so the existing `nil` process. Nothing here can
  turn an acknowledged action into a refusal or `failed`. A length-caused `nil`
  for a path the walk resolves is a defect.
- Neither whole-path primitive remains on this route: `fileIdentity(ofPath:)` and
  its two callers use no `resolvingSymlinksInPath`, `realpath` or pathname
  resource value. `task check:launch-call-path` is extended to enumerate them and
  is seen to fail against a mutated source.
- L: a substituted adapter drives `observeProcess` for equal identities, different
  identities, one unavailable and both unavailable, each yielding the retained
  outcome, with different start samples and a terminated object as before.
- N: through the independently built provider, real acquisition for a running
  process whose `proc_pidpath` is reached through a link chain, at short and at
  about 1,500-byte depth where the walk resolves it, for the live and the
  retained identities, and the retained `nil` for a path the walk cannot resolve.
  The check is seen to fail against a mutated walk. It uses no launch on the host
  beyond a process the test itself starts and owns.
- Short launch, named open and reveal receipts keep every accepted outcome
  (`docs/verification/launch-vm.md`). Observation at V for the real launcher
  fixtures is carried by `application-locations-vm-k181`.

## Notes

- If `application-locations-k176` has not yet changed the shared identity type,
  this leaf converts both sides together, because a comparison between a
  Foundation resource identifier and a device and inode can never be equal and
  would make every receipt `nil`.
- `proc_pidpath` already reports a resolved kernel path of up to 4,096 bytes,
  longer than the hand-off limit; reading it needs no new buffer decision.

## Decisions (running log)

- **The shared type is `ObjectIdentity` (device and inode), and `FileIdentity` is gone.** `k176` had not changed it, so both
  sides were converted together as the note said: a Foundation resource identifier can never equal a device and inode, and
  leaving one side behind would have made every receipt `nil`. The test vocabulary (`ApplicationBundle.identity`,
  `FakeNative.identity`, `ObjectIdentity.named`) is an inode derived from a name, so one test file name is one object.
- **Observation's rule is its own file, `Logic/ExecutableIdentity.swift`** (`ExecutableIdentity.of(path:)`), not a branch of
  the stages: it yields the walk's identity for a `.present` location and none for every other outcome, never reads
  `HandOffLimit`, and treats a non-absolute spelling as unavailable (the walk always starts at `/`, so a relative one would
  otherwise be read from the root).
- **Both paths are bytes, never `String`.** The live one is `proc_pidpath`'s buffer up to the NUL; the retained one is the
  URL's `withUnsafeFileSystemRepresentation`, in the free function `identityOfExecutable(at:)` (not `executableIdentity`,
  which `RunningApplication`'s own property would shadow).
- **N is an independent build of the shipped sources, not a call into the signed bundle.** The bundle reaches observation
  only after a launch and exports no symbol (`nm -gU` shows none), so `Fixtures/ReceiptIdentityProbe` compiles `Logic/` and
  `Sources/` as `build.sh` does with a small entry point; the test starts it as a process it owns. `NSRunningApplication.current`
  has no `executableURL` for a plain command-line process, so the probe sets a `prohibited` activation policy (measured:
  no window, no Dock tile).
- **Found: there is no running process at about 1,500 bytes.** The kernel kills a program at exec whose physical path is
  1,024 bytes or more (1,023 runs; 1,200 is refused at spawn). The brief's N row is therefore a running process at short
  depth and at 1,023 through two links, plus the retained route's own conversion on present executables of 1,024 to 4,200
  bytes and through every link form. Recorded in the spec and the record; not a defect, and it is why the limit adds no
  systematic `process: null`.
- **Found: `NSRunningApplication.executableURL` is the spelling the process was started by** (with `/private` dropped), not
  the physical path, so the 1,023-byte row does send the retained walk through two links. The row pins that observation.
- **Found on the real system, and not a defect:** of 139 running applications reporting both identities, 2 are not the same
  file (`com.apple.WebKit.WebContent` reported for a `.EnhancedSecurity` process). The route the walk replaced says the same,
  and N sets the walk against that route's verdict on every running application (0 disagreements).
- **Review spent: one fresh-context read, nothing blocking.** Classified in `docs/verification/receipt-executable-identity.md`:
  the same-path replacement false equal is the spec's stated non-atomic observation; the walk's quadratic list handling and
  `openat` without `O_NOFOLLOW` are k174's accepted behaviour; a non-UTF-8 name is not exercised (fixtures are built from
  `String`) and is left a visible trade-off.
- **Call path:** `check-launch-call-path.sh` has a section enumerating the two routes and the rule, and
  `scripts/check-launch-call-path-mutations.py` (`task check:launch-call-path-mutations`) sees it fail on 13 mutations in a
  throwaway copy. `check-location-walk-mutations.py` gained suites X, V and R and six mutations, and builds the probe.
- **Spec and docs:** status paragraph, receipt sentence, the stale "both application stages ... pending" line, the client
  guide, the ADR's list of consumers and the older analysis table were brought to what is accepted; `docs/verification/receipt-executable-identity.md` is the record.
