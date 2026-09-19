# native-providers-k18 — brief

## Goal

The third working Koine: an independently built native Swift provider bundle,
installed in a Koine-owned root and approved, contributes introspectable fields
to the public schema at startup. Koine enforces the provider's read and control
capabilities on every path to its fields, reports provider status through
management, and compatible host and plugin binaries upgrade independently.
Planned by `native-provider-contribution-k8`.

## Done when

- **Provider contract and composition.** `KoineProviderAPI` (`ProviderFactory`,
  `ProviderDescriptor`, `Provider`, `ResolutionRequest`, `ResolutionResult`,
  `ProviderValue`, `ProviderFailure`) is built with library evolution and module
  stability in every build configuration, with no GraphQL-library or
  third-party type in its interface. The core composes a provider's SDL and
  registrations, rejecting collisions, reserved names, bad prefixes, missing
  resolvers, unclassified fields and duplicate identifiers without publishing a
  partial contribution. The `Reference` scalar validates the envelope and routes
  by authority only.
- **Authorization** (public GraphQL seam): every case in the "Public GraphQL
  authorization" row of the spec's test seams holds against a fixture provider
  with call counters and a gateable action, with the agreed error vocabulary,
  original paths and non-null propagation.
- **Native loader** (native binary seam): every check the spec lists precedes
  `dlopen`; principal-class discovery with image-origin and collision checks;
  bundled duplicate frameworks refused; start/stop serialized, resolves overlap;
  diagnostics served as `koineManagement.providers`; schema admission refused
  when full introspection would exceed `RequestPolicy`.
- **Trust.** The loader admits bundles only from Koine-owned roots and only with
  an approval record (provider ID plus signing identity). A differently signed
  or unapproved bundle is refused before any of its code loads.
- **Compatibility evidence** (native binary seam): the independently built pairs
  and refusals in the "Native binary interface" row, from a repeatable recipe,
  and the supported binary baseline (Swift runtime, OS, CPU architectures)
  stated as evidence.
- **Signed build**: the signed `Koine.app`, with its entitlements still empty,
  loads an approved same-team provider and refuses a differently signed one, in
  a TestAnyware VM.
- Every new build, sign and verification command is in `Taskfile.yml` and the
  README.

## Decomposition

Ordered by risk, then dependency. Each leaf leaves `task`, `task app` and the
existing suites green, and is verifiable on its own.

1. `native-provider-walking-skeleton` — the thinnest complete native path: the
   resilient framework, a fixture bundle built outside the package, a minimal
   loader, one fixture read field served over public GraphQL, and the framework
   embedded and signed in `Koine.app`. It carries the toolchain unknowns, so it
   goes first, and it makes the framework build-tooling choice.
2. `composition-rules-and-reference-routing` — the full descriptor and
   registration contract, every composition refusal, the `Reference` scalar and
   `unknown-provider`. Constrains the path leaf 1 opened.
3. `provider-authorization-acceptance` — the authorization acceptance cases
   over the fixture's counters and gateable action. Needs leaf 2's mutation
   registrations.
4. `loader-compatibility-checks-and-status` — manifest, architecture,
   dependency-closure and framework major/minor/feature checks before `dlopen`,
   principal-class checks, lifecycle serialization, and
   `koineManagement.providers`.
5. `provider-trust-and-install-roots` — the in-application and per-user roots,
   canonical location and staging, signature verification and approval records,
   and the application wired to its roots. Needs leaf 4's refusal and status
   machinery.
6. `binary-compatibility-evidence` — the old/new pairs and the baseline. Needs a
   loader whose refusals are complete (leaves 4 and 5).
7. `signed-app-provider-vm-verification` — the TestAnyware seam over the signed
   build. Needs everything before it.
8. `listener-waits-for-responses-in-flight` — found by leaf 6: `stop()` does not
   wait for a response in flight, though `KoineServer.stop()` says it does.
   Independent of the others.

## Pointers

- Spec sections: "Composition and operation placement", "Mutation preflight and
  revocation", "Errors and partial data", "Native extensions — shared resilient
  Swift framework", "Loading and trust", and the authorization and
  native-binary rows of "Test seams and acceptance".
- ADRs: `docs/adr/resilient-provider-framework.md`,
  `docs/adr/koine-server-and-native-providers.md`,
  `docs/adr/machine-references-as-uris.md`.
- Design SDL for `KoineProviderStatus` and `KoineProviderState`:
  `docs/design/desktop-schema.graphql`.
- Seams: public GraphQL for composition and authorization; the native binary
  seam for loading and compatibility; TestAnyware VMs only for the signed build.

## Notes

**Decided by the human in `native-provider-contribution-k8`:**

- *One loader.* The bundled desktop provider loads through the same native
  loader as any other provider, from a provider root sealed inside `Koine.app`.
  It is a real plugin bundle, not a target linked into the host. One production
  path keeps the native seam exercised by the product itself; the accepted cost
  is that the desktop path depends on loader, run path and signing being right
  in the signed build.
- *An approval record, no install UI.* The loader enforces an approval record
  (provider ID plus signing identity) for every root. The in-application root's
  record is built in: the provider ID and Koine's own Team ID, sealed by the
  application signature. A per-user installed root exists and is honoured; its
  approval records are written by a local user operation with no UI in this
  stage — a documented file the user places. An unapproved or differently
  signed bundle is refused and reported `REJECTED`. The install and approve UI
  is a later, separately planned increment; there is no provider-approval
  mutation in the design SDL and none is added here.
- *No library-validation entitlement yet.* The signed build keeps the hardened
  runtime with no exceptions. Providers signed by Koine's Team ID load, bundled
  or per-user, so first-party independent upgrades work. A provider signed by
  another identity is refused by Koine's approval check before `dlopen`.
  **Accepted consequence, to be stated in the spec by leaf 5:** independently
  signed third-party providers are not loadable until a later increment adds
  the entitlement with its own signed-build verification.

**The fixture provider is test material built outside the shipped product.** It
is a separate package (or equivalent) compiled against the framework's emitted
module interface, never a target of the root `Package.swift` that links the
framework's sources. It is what makes this stage verifiable before the desktop
provider exists, and it is the independently built binary the compatibility
pairs reuse. Because it runs across a binary boundary, expose its call counters
and its action gate through its own provider fields or another route that
survives `dlopen`; an in-process Swift reference into the plugin is not
available to a test.

**No fourth public testing interface.** A headless host executable that embeds
the server with a given data directory and provider roots is acceptable test
material if a leaf needs one (the compatibility pairs need an "old host" that
can run alone); it drives the loader and the console, and adds no API.

**An implementation limit found here (toolchain, loader or signing) is raised
against the contract explicitly.** Stop and ask; it must not quietly narrow the
independent-upgrade promise.

**What earlier stages left to build on.** `Engine` already installs a
host-controlled resolver per schema coordinate from an internal
`FieldRegistration` (authority plus resolver), refuses unclassified fields,
preflights root mutation actions with fragment and `@skip`/`@include`
expansion, rechecks reads before publication, and has the internal
`OrderingHook` (`preflightPassed`, `admitted`, `resolved`) that
`RevocationOrderingTests` drives. Provider contributions extend that machinery;
they do not add a second path. `FieldAuthority` has `admitted` and
`capability(String)`. `Koine.availableCapabilities` is a fixed list today and
must gain each active provider's read and control capabilities.
`scripts/build-app.sh` already reserves `Contents/Frameworks` and signs
inside-out; `App/Koine.entitlements` is deliberately empty. The host rule
binds: anything that launches `Koine.app` runs in a TestAnyware VM.

**Serve only what is implemented** continues to bind: `KoineManagement` gains
`providers` here and nothing else. **Keep the GraphQL library private to the
engine**: it must not appear in `KoineProviderAPI`'s interface, stored public
types or inlinable code.
