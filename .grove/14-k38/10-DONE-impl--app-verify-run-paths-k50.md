# app-verify-run-paths-k50

## Goal

`task app:verify` passes again on a correctly built, notarized `Koine.app`,
checking run paths that are right for the macOS 26 floor rather than the macOS
13 one.

## Context

- Found by `quarantined-provider-precheck-k49`: after `task app && task
  app:notarize` (submission 51b99a60-9266-409c-bfb3-c41bfb05f65d, Accepted,
  stapled), `scripts/verify-app.sh` fails with "the executable's run paths are
  not exactly /usr/lib/swift and @executable_path/../Frameworks" — the
  executable carries only `@executable_path/../Frameworks`.
- The likely cause is `support-matrix-and-latency-k44` narrowing the floor from
  macOS 13 to 26: `/usr/lib/swift` is the back-deployment run path the compiler
  adds for targets that predate the OS-supplied runtime, and that leaf measured
  a signed, not notarized, build, so `app:verify` may not have been run on the
  narrowed bundle. Confirm the cause from the compiler/driver rather than
  assuming it.
- Blocks `homebrew-distribution-k46`, whose release must pass `app:verify`.

## Done when

- The check in `scripts/verify-app.sh` states the run paths a floor-26 build
  should have, with the reason at the check, and is watched to fail against a
  deliberately wrong run path.
- `task app:verify` passes on a fresh `task app && task app:notarize` build.
- Nothing else in `verify-app.sh` is found stale against the narrowed floor, or
  what is found is fixed in the same way.

## Notes

`scripts/check-minimum-os.sh` is the floor's other checker; if the run-path
expectation can be derived from the same source rather than restated, prefer
that.

## Decisions (running log)

- **Cause confirmed from the driver, not assumed.** swift-driver's
  `StdlibRpathRule` (`Sources/SwiftDriver/Jobs/Toolchain+LinkerSupport.swift`,
  main at bf7d3ee) emits `-rpath /usr/lib/swift` exactly when the frontend's
  `-print-target-info` reports `librariesRequireRPath`. With Swift 6.4
  (swift-driver 1.168.6) that is `true` for arm64-apple-macosx 13.0, 15.0 and
  18.0 and `false` for 26.0, and a one-line `swiftc` link shows `LC_RPATH
  /usr/lib/swift` at 13.0 and 15.0 and none at 26.0. The existing bundle's
  executable imports nothing by `@rpath` but the framework.
- **The expectation is derived, not restated.** `verify-app.sh` asks
  `swiftc -print-target-info -target arm64-apple-macosx${MINIMUM_OS}` (the same
  `MINIMUM_OS` `check-minimum-os.sh` reads from App/Info.plist) and expects
  `/usr/lib/swift` before `@executable_path/../Frameworks` only when it says
  `true`; an answer that is neither is a refusal. `build-app.sh` already keeps
  `/usr/lib/swift` only if the compiler emitted it, so it needed its comment
  corrected and no code change.
- **Stale elsewhere:** README's Resident application paragraph stated the
  macOS-13 run paths and rationale — fixed. `signed-app-provider-vm.md` and
  `binary-compatibility.md` record past runs and are left as the record.
  Nothing else in `verify-app.sh` depends on the floor except through
  `check-minimum-os.sh`.
- **Passes on a fresh notarized build.** `task app && task app:notarize`
  (submission 420193ce-9d80-4c66-9ef0-da073eb3e5e1, Accepted, stapled), then
  `task app:verify` exit 0 with `source=Notarized Developer ID`; the executable's
  only `LC_RPATH` is `@executable_path/../Frameworks`.
- **Watched to fail.** Copies of that bundle, run-path-edited and re-signed with
  the real identity, run through `verify-app.sh` via `KOINE_APP_BUNDLE`: the
  unedited control passes every check (re-signing unchanged content keeps the
  cdhash, so even the stapled ticket still matches), so each failure below is the
  run-path check alone — the macOS-13 shape (`/usr/lib/swift` then Frameworks),
  an extra build-tree run path, and no run path each exit 1 naming expected and
  found. The five scripts and App/Info.plist it read digested the same before the
  build and after the mutations.
