# native-provider-contribution-k8

## Goal

Plan the third working increment: an independently built native Swift provider
bundle, installed in a Koine-owned root, contributes introspectable fields to
the public schema at startup. Koine enforces the provider's read and control
capabilities on every path to its fields, reports provider status through
management, and compatible host and plugin binaries upgrade independently.

## Context

Spec sections: "Composition and operation placement", "Mutation preflight and
revocation", "Errors and partial data", "Native extensions — shared resilient
Swift framework", "Loading and trust", and the authorization and native-binary
rows of "Test seams and acceptance". ADR:
`docs/adr/resilient-provider-framework.md`. Read what stages k4 and k7 built,
especially the engine's authorization hook and the application's signing and
bundle arrangement.

## Done when

The tree holds narrow impl leaves that together deliver, in dependency order:

- **Provider contract and composition.** The `KoineProviderAPI` framework
  (`ProviderFactory`, `ProviderDescriptor`, `Provider`, `ResolutionRequest`,
  `ResolutionResult`, `ProviderValue`, `ProviderFailure`) built with library
  evolution and module stability from its first build, with no GraphQL-library
  or third-party type in its interface. The core composes a provider's SDL and
  registrations, rejecting collisions, reserved names, bad prefixes, missing
  resolvers, unclassified fields and duplicate identifiers without publishing
  partial contributions. The `Reference` scalar validates the envelope and
  routes by authority only.
- **Authorization engine acceptance** (public GraphQL seam, driven by a fixture
  provider with call counters and a gateable action): authority by schema
  coordinate across alternate lookups, nested fields, aliases, fragments and
  `@skip`/`@include`; mixed permitted/denied mutations make zero action calls;
  a skipped denied action does not block; revocation between preflight and
  dispatch prevents dispatch; revocation between actions stops the later one
  without undoing the earlier; read results are rechecked before publication.
  The error vocabulary (`unknown-provider`, `unavailable`, `permission` with
  both classes, `failed`), original paths and non-null propagation hold.
- **Native loader** (native binary seam): bundle format (dylib, manifest,
  schema); manifest, canonical location, signature, dependency closure,
  architecture and framework major/minor/feature checks all before `dlopen`;
  `NSClassFromString` principal-class discovery with image-origin and
  collision checks; refusal of bundled duplicate frameworks; start/stop
  serialization and overlapping resolves; diagnostics surfaced as
  `koineManagement.providers`; schema admission refused when full
  introspection would exceed the server's limits.
- **Compatibility evidence** (native binary seam): independently built pairs —
  old plugin with newer host and framework, newer plugin built for the old
  baseline with the old host — plus unsupported major/minor/feature refusal
  and mismatched signing identity refused before code loads. The build recipe
  for these pairs is repeatable. This leaf also states the supported
  binary baseline (Swift runtime, OS, CPU architectures) as evidence, not
  assumption.

## Notes

Follow `desktop-delivery-k3`'s cutting shape (see `resident-app-manual-grants-k7`).

The fixture provider is test material built outside the shipped product; it is
what makes this stage verifiable before the desktop provider exists, and it is
the independently built binary the compatibility pairs reuse.

**Decisions this stage must settle, with the human where they are product
decisions:**

- Whether the bundled desktop provider loads through the same loader from a
  root inside the application. Recommended: yes — one production path keeps
  the native seam honest and the spec already treats a failed desktop provider
  as a reportable provider state. The spec says "bundled" without saying how.
- What "explicitly installed, approved" means for the first deliverable, which
  ships only the bundled provider. The approval record (provider ID plus
  signing identity) is required by the spec; a third-party install/trust UI
  may be the smallest thing that satisfies it or may be deferrable. State the
  question precisely and ask; do not silently drop the trust record.
- The library-validation entitlement is only needed for independently signed
  third-party providers; decide whether the first signed build carries it, and
  verify its behaviour on the signed build, not an unsigned one.

An implementation limit found here (toolchain, loader or signing) must be
raised against the contract explicitly; it must not quietly narrow the
independent-upgrade promise.

## Decisions (running log)

**The human decided all three product questions as recommended.** One loader:
the bundled desktop provider is a real plugin bundle loaded from a root sealed
inside `Koine.app`. An approval record is enforced for every root, with no
install UI in this stage; the per-user root's records are a documented file the
user places. The first signed build carries no library-validation entitlement,
so independently signed third-party providers are not loadable until a later
increment; the spec is to say so. Recorded in `native-providers-k18`'s brief;
`provider-trust-and-install-roots-k23` amends the spec.

**Cut as stage `native-providers-k18`, seven impl leaves, risk first.** The
walking skeleton carries the toolchain unknowns and must re-embed the framework
in `Koine.app`, because the application stops launching once `KoineCore` links
a dynamic framework that the bundle lacks. Composition then authorization, and
loader checks then trust, follow the open-then-constrain pairing of k5/k6 and
k14/k15. A signed-build VM leaf closes the stage because library validation is
invisible to an unsigned test process.

**The install and approve UI is not leafed.** It is outside this stage and the
first deliverable's done-criteria; it stays a horizon note in the root brief.
