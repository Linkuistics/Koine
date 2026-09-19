# composition-rules-and-reference-routing-k20

## Goal

Complete the provider contract and make composition safe: a provider's whole
contribution is either published or refused with a diagnostic, mutations and
nested fields are contributable, and the `Reference` scalar routes by authority.

## Context

- Spec: "Composition and operation placement", "Schema digest", the
  `unknown-provider` and `unavailable` rows of "Errors and partial data", the
  framework interface table, and "Resource references and desktop behavior" for
  the reference envelope.
- ADR: `docs/adr/machine-references-as-uris.md`.
- Read `native-provider-walking-skeleton-k19`'s commit for the contract and the
  composition path it opened.

## Done when

- `ProviderDescriptor` carries schema, a registration for every contributed
  field (resolver identifier plus authority requirement) and required features;
  `ResolutionRequest` carries resolver identity, coerced arguments and parent
  value; `ResolutionResult`, `ProviderValue` and `ProviderFailure` cover
  scalars, references, lists, bounded value trees, ordinary null and the
  structured failures the error table needs. A provider can contribute root
  query fields, nested object fields and root mutation actions.
- A provider's authority requirements can name only its own read and control
  capabilities. It cannot mark a field public or mint management authority.
  Each active provider's capabilities appear in `Koine.availableCapabilities`
  and are grantable.
- Composition refuses, before publishing anything from that provider: a name
  collision, a reserved name or a core-owned prefix, a type or root field
  without the provider's prefix, a missing resolver, an unclassified field,
  invalid SDL, an extension of another owner's type, and an action outside the
  root `Mutation` type. Two providers claiming one identifier are both refused.
  No provider can claim `desktop`/`Desktop` except the bundled one, or
  `koine`/`Koine` at all. Each refusal yields a diagnostic a later leaf serves
  as provider status; the remaining schema is served intact.
- Schema admission is refused when full introspection of the composed schema
  would exceed `RequestPolicy`.
- `schemaDigest` is identical whatever order the same contributions were
  composed in, and differs when a contribution differs.
- The `Reference` scalar validates the `koine://<provider>/<remainder>`
  envelope at input coercion and the engine reads only the authority. A
  well-formed reference naming an unregistered provider is `unknown-provider`,
  after the applicable capability check. A malformed provider remainder or gone
  target, reported by the provider, is `unavailable`. Malformed provider output
  and a resolver registration mismatch are `failed`.

## Notes

Tests are at the public GraphQL seam, with contributions from the fixture
provider and from small in-test descriptors where a refusal needs a deliberately
bad contribution; a bad descriptor does not need its own dylib.

Extend the engine's existing per-coordinate registration machinery; do not add
a second resolution path. Additions to the framework follow the spec's evolution
rules even before the first release.

## Decisions (running log)

- **Framework additions are additive.** `ProviderDescriptor.requiredFeatures`,
  `ResolutionRequest.requestId`, `ProviderValue.reference`,
  `ProviderFailure.Kind.osPermission`/`.unknownResolver` and
  `ProviderFailure.permission` are new stored properties, cases and
  initializers; every k19 initializer keeps its signature.
- **`Reference` is a core scalar built in code.** GraphQLSwift 4.2.0 fixes a
  scalar's coercion closures at construction and `extendSchema` carries them
  over (`.build/checkouts/GraphQL/.../ExtendSchema.swift`, `extendScalarType`),
  so the core SDL extends a schema that already holds the scalar. It is served
  even with no provider using it.
- **Provider identifier grammar**: a lower-case letter then lower-case letters
  and digits; prefix: a capitalised alphanumeric GraphQL name. The identifier is
  the reference authority, so the envelope's authority has the same grammar.
- **Order-independence comes from a canonical composition order** (bundled
  first, then identifier), because root fields keep declared order in the
  digest's text. Cross-provider collisions are found over every candidate's
  claimed names before composing, and all claimants are refused.
- **Overlapping prefixes are allowed** (`Git` and `GitHub` are both plausible);
  only an equal identifier or prefix is a duplicate. Names under `koine`/`Koine`,
  and `desktop`/`Desktop` for a non-bundled provider, are refused by name.
- **`ActiveProvider.origin`** (`bundled`/`external`, default external) is how
  the core knows who may own `desktop`. Leaf 5 sets it from the install root.
- **Each contribution is validated against the core alone**, so using another
  provider's type is invalid SDL, and refusal does not depend on who else loaded.
- **Interfaces and unions are refused** as not contributable in this version:
  the engine has no type resolution for provider abstract types, and a field
  that can never resolve must not be published.
- **"An action outside the root Mutation type" is checked by authority
  placement**: `control` on `Query` or on a type a query can reach is refused; a
  root `Mutation` field must require `control`. Types reached only from a
  mutation result may require `control` (the receipt pattern).
- **Introspection admission is a synchronous model of the response**, not an
  execution: composition runs in a synchronous `init` and the library executes
  only asynchronously; blocking a cooperative-pool thread on a task deadlocks
  under parallel tests. The model includes every optional standard field, so it
  is an upper bound; a test holds it against the served response.
- **Reference routing**: after the capability check the engine reads the
  provider of every `Reference` argument; an unregistered one is
  `unknown-provider`. A reference naming another *registered* provider is passed
  to the field's provider, which reports `unavailable`: references may cross.
- **Provider output is checked against the field's type in the host resolver**,
  so a malformed value is `failed` rather than an unclassified library error.
  A provider object travels as the `ProviderValue` itself, so a nested resolver
  receives references still typed as references.
- **OS-permission errors** carry `extensions.osPermission` and
  `extensions.permissionOwner: "koine"`; the spec named the content, not the keys.
- **In-test descriptors reach the server through an internal initializer**
  (`@testable import KoineServer`), not a public parameter.
- **The leaf's one in-session review** probed composition with live descriptors.
  Valid and fixed, each under a test: provider SDL now passes the request
  nesting limit before parsing; input-object default values are refused (the
  library expands them without a bound, and they made the introspection model
  under-count); a contribution may use only its own types, built-in scalars and
  `Reference`; `validateSchema` runs on each candidate and on the composed
  schema; an extension of `Query`/`Mutation` may add fields only; arguments are
  converted by declared type, so a fractional `Int` variable never reaches a
  provider; the model pads each default for list and float coercion.
- **Output lists must have non-null elements.** GraphQLSwift 4.2.0 drops null
  elements in `completeListValue`, so `[T]` output is refused at composition
  rather than published broken.
- **Kept as visible trade-offs**: `control` on a type reached only from a
  mutation result (the spec's receipt); a refused descriptor still contests an
  identifier, since the spec refuses both claimants and picks no winner.
  Loader-side origin, per-bundle load failure and `start()` failure are leaves
  4 and 5.
