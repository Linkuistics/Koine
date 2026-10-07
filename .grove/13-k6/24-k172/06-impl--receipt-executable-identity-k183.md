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
