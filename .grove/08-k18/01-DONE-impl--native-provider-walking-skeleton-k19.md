# native-provider-walking-skeleton-k19

## Goal

Open the thinnest complete native path: a fixture provider bundle, built
outside the package against the resilient `KoineProviderAPI` framework, is
loaded from a configured root at startup and serves one read field over the
public GraphQL API under its read capability. Koine.app still builds, signs and
launches with the framework embedded.

## Context

- Spec: "Native extensions — shared resilient Swift framework" (the framework
  build rules, the bundle contents, principal-class discovery and the framework
  interface table) and the first paragraph of "Composition and operation
  placement".
- ADR: `docs/adr/resilient-provider-framework.md`.
- Read `scripts/build-app.sh`, `scripts/verify-app.sh` and the stage brief's
  notes on what the engine already has.

## Done when

- `KoineProviderAPI` exists with the contract types the spec's table names, at
  the minimum shape this path needs, built as one dynamic framework image with
  library evolution and an emitted textual module interface in debug and
  release. It has one stable module name and install name. No GraphQL-library
  or third-party type appears in its interface. `KoineCore` uses it and still
  has no macOS or concrete-provider dependency.
- The framework build-tooling choice is made and recorded in the README:
  `swift build` with explicit flags, or `xcodebuild` on the package scheme.
  Verify the emitted `.swiftinterface` and the resilience of the built binary
  against the toolchain, not from memory.
- A fixture provider bundle (dylib, declarative manifest, schema SDL) is built
  by its own build definition against the emitted interface and the built
  framework, not as a target sharing the framework's sources. It dynamically
  links the host's framework image and embeds no copy.
- A minimal loader takes a provider root from the host's configuration, loads
  the bundle with `dlopen`, finds the manifest's principal class with
  `NSClassFromString`, requires `ProviderFactory` conformance, and the engine
  composes the descriptor's SDL and registrations. A test over loopback HTTP
  queries the fixture's read field with a grant holding the fixture's read
  capability and gets its value; without the capability it gets the agreed
  `permission` / `capability` error. Introspection shows the fixture's types.
- `task app` embeds the framework in `Contents/Frameworks` with a correct run
  path and signs inside-out; `task app:verify` checks it; `task app:vm-verify`
  still passes, proving the application launches with the dynamic framework.
  The application ships no provider yet.
- New build commands are in `Taskfile.yml` and the README.

## Notes

This leaf carries the stage's toolchain unknowns. If SwiftPM cannot produce a
resilient dynamic framework that an out-of-package build can consume, or the
install name and run path cannot be made stable, stop and raise it against the
contract; do not fall back to compiling the fixture into the package.

Keep the loader minimal: verification before `dlopen`, trust, status reporting
and the composition refusals belong to later leaves. Do not design the whole
ABI surface speculatively; later leaves extend the contract, and nothing is
released until `release-acceptance-handoff-k11`. Do follow the spec's evolution
rules from the first declaration: no frozen types, no implementation-revealing
inlinable code.

## Decisions (running log)

- **Framework build tooling: `swift build` with explicit flags.** Swift 6.4's
  SwiftPM (swiftbuild backend) accepts `unsafeFlags` in a local path package,
  emits `KoineProviderAPI.swiftinterface` recording `-enable-library-evolution`
  in debug and release, and honours a linker `-install_name`. `xcodebuild` on
  the scheme was not needed; it would apply library evolution to every
  dependency and take the application build off `Package.swift`. No toolchain
  limit had to be raised against the contract.
- **The framework is a local sub-package (`ProviderAPI/`).** A target of the
  root package is linked statically into each host image; only another
  package's `.dynamic` product is one shared image.
- **Install name `@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI`,
  a real framework, staged by script.** SwiftPM emits a bare dylib, so
  `scripts/stage-provider-framework.sh` assembles the framework into
  `PackageFrameworks` (already on every SwiftPM product's run path). Accepted
  cost: a bare `swift test` on an unstaged tree dies in dyld; `task test` is the
  entry point and the README says so. The alternative, SwiftPM's default
  `@rpath/libKoineProviderAPI.dylib`, would have worked unstaged but fixes a
  non-framework identity into every built plugin for the whole major.
- **Resilience evidence is a symbol check with a control.** A module built
  without library evolution exports `field offset for` symbols; with it, none.
  The staging script enforces interface flag, install name and that check.
- **Provider SDL is `extend type Query { … }`, composed with the library's
  `extendSchema`** (present in the pinned GraphQL 4.2.0 source). Provider
  registrations become ordinary `FieldRegistration`s with
  `.capability("<id>:read|control")`, so they take the existing authorized path.
- **Provider values cross as plain Swift values inside the engine**; a nested
  field's parent is converted back to `ProviderValue`.
- **The fixture is built by `swiftc` from a shell build definition** against the
  staged framework's `.swiftinterface` and image only. Its SDL constant is
  generated from `schema.graphql` so the bundle's schema file and the
  descriptor cannot drift.
- **Minimal loader failure mode:** a bundle that fails to load throws from
  `KoineServer.init`. Leaf 4 replaces this with `REJECTED` status and an absent
  contribution. Required features, versions and the `Reference` value case are
  left out of the API until the leaves that need them.
- **The application's run paths are `/usr/lib/swift` and
  `@executable_path/../Frameworks`.** Found in the VM: the executable links
  `@rpath/libswiftCompatibilitySpan.dylib`, which only the OS Swift runtime
  directory supplies; removing every build run path stopped the app launching.
  For `binary-compatibility-evidence-k24`: on an OS whose `/usr/lib/swift`
  lacks that library the app would need it embedded, which bears on the stated
  OS baseline (the package declares macOS 13; the VM is macOS 26.5).
