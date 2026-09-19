# loader-compatibility-checks-and-status-k22

## Goal

Make the native loader refuse an incompatible or malformed bundle before any of
its code runs, manage a loaded provider's lifecycle, and report every provider's
state through `koineManagement.providers`.

## Context

- Spec: "Native extensions — shared resilient Swift framework" (manifest
  fields, load-time compatibility, principal-class discovery, lifecycle),
  "Loading and trust", and the "Native binary interface" row of "Test seams and
  acceptance".
- Design SDL: `KoineProviderStatus`, `KoineProviderState` in
  `docs/design/desktop-schema.graphql`.
- Read `native-provider-walking-skeleton-k19`'s commit for the minimal loader.

## Done when

- The manifest declares provider ID, GraphQL prefix, plugin and schema versions,
  CPU architecture, minimum OS and runtime, required framework major and
  minimum minor, required host features and the principal-class name. The host
  states its own framework version and feature set.
- Before `dlopen`, the loader checks the manifest, the binary's architecture,
  its dependency closure (every dependency is the host's framework image, a
  system library or a validated private dependency inside the bundle), and the
  framework major, minor and feature requirements. An unsupported major,
  unavailable minor or missing feature is `INCOMPATIBLE`; a malformed manifest,
  a bundled or statically substituted copy of the framework, or a bad
  dependency is `REJECTED`. None of them loads code; a test shows the dylib's
  initializer did not run.
- After loading, the principal class must originate in the verified plugin
  image, conform to `ProviderFactory`, and not collide with an already loaded
  principal name; the runtime descriptor must agree with the manifest. A
  `dlopen` failure is an explicit refusal. A provider that fails after its
  initializers ran stays mapped and contributes nothing.
- Start follows descriptor and schema validation. Start and stop for one
  instance are serialized; resolves overlap once start succeeds; stop admits no
  new resolutions, requests cancellation and waits for outstanding work. The
  host holds no authority or store lock across provider code. A failed start is
  `FAILED` with management still available.
- `koineManagement.providers` is served under `koine:manage` with provider,
  version, schema version, state and diagnostic for every bundle found, active
  or not, including the composition refusals from
  `composition-rules-and-reference-routing-k20`.

## Notes

Signature, approval records, installation roots and staging belong to
`provider-trust-and-install-roots-k23`; leave a clear place for those checks in
the pre-`dlopen` sequence. Tests build deliberately bad bundles from the fixture
with a repeatable script, since each refusal needs a real binary or manifest.

## Decisions (running log)

- **The host states its framework version as a host constant, not as new
  framework API.** The framework ships inside Koine, so host and framework
  always upgrade together; a constant adds no permanent ABI. A test holds it
  equal to `ProviderAPI/Info.plist`'s version so the two cannot drift.
- **The Swift runtime requirement is checked through the OS.** On macOS the
  runtime is an OS component and no API reports its version, so the host maps
  the running OS to the runtime it supplies, from the Swift project's own
  `utils/availability-macros.def` (cited at the table). A requirement above
  what the running OS supplies is `INCOMPATIBLE`.
- **State classification beyond the task's list.** An honest bundle this host
  cannot run (architecture, minimum OS, runtime) is `INCOMPATIBLE`; a manifest
  the binary contradicts (architectures, minimum OS below the binary's own) is
  `REJECTED`, as is a library path that leaves the bundle.
- **Dependency policy.** A dependency is the framework's exact install name, a
  path under `/usr/lib/` or `/System/Library/`, or `@loader_path/…` resolving
  inside the bundle, validated recursively. `LC_RPATH` entries obey the same
  rule. Anything named `KoineProviderAPI` inside the bundle, or framework-module
  symbols defined by the plugin's own image, is a substituted copy.
- **Principal-name collision is decided before `dlopen`** by asking the
  Objective-C runtime whether the name is already registered by another image;
  the same image already loaded (a second server in one process) is not a
  collision.
- **Lifecycle lives in the core**, as a wrapper every registration resolves
  through, so it is testable with in-test providers. A provider that is not
  started answers `unavailable`; its schema stays published, so the digest does
  not depend on a start outcome.
- **The server stops providers before the listener.** The listener's stop waits
  for requests in flight, and one of those may be waiting on a resolve that ends
  only when stop requests cancellation; the other order can hang. The window in
  which a late request sees a provider `unavailable` is the accepted cost.
- **A start failure no longer fails `KoineServer.start()`.** It is that
  provider's `FAILED` status; management stays available, as the spec requires.
