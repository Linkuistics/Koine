# schema-conformance-k40

## Goal

Check the schema the running notarized application actually serves against
`docs/design/desktop-schema.graphql`, as a repeatable check rather than a
one-time read, and reconcile every difference — into the spec and the design SDL
where it was intended, into a repair leaf where it was not.

## Context

- The design contract: `docs/design/desktop-schema.graphql`. The digest rule it
  is compared through is the spec's "Schema digest" section — SHA-256 over a
  canonical SDL text, directives then named types sorted by name, printed in
  `printSchema` format with descriptions, introspection types and built-ins
  omitted, declared order kept for fields, arguments and enum values.
- `Engine.digest(of:)` in `Sources/KoineCore/Engine.swift` already computes the
  served digest, and `Koine.schemaDigest` serves it.
  `Tests/KoineServerTests/CompositionTests.swift` and
  `FirstAuthenticatedQueryTests.swift` already exercise it for stability across
  restarts and composition order.
- "Serve only what is implemented" has bound every stage: each leaf served the
  fields it made real, and the design SDL was the target rather than something
  to stub. **The whole point of this leaf is that the target is now due.**
- `Sources/KoineCore/CoreFields.swift` pins the served field list per type, and
  `GrantManagementTests` pins `KoineManagement`'s.

## Done when

- **A repeatable check exists** — `task conformance` — that introspects a
  running Koine, prints the canonical SDL, and diffs it against
  `docs/design/desktop-schema.graphql`, reporting differences by type, field,
  argument, nullability, default, deprecation and description. It must be able
  to fail, and be seen failing: mutate the design SDL and watch the check go
  red before trusting a green run.
- **Every difference is classified and none is left**: either the served schema
  is wrong (a finding — cut a repair leaf, do not fix it inline), or the design
  SDL and `docs/specs/machine.md` are what changed during implementation and are
  reconciled here, with the change described where the contract is described,
  not silently applied.
- **Descriptions are in scope**, not skipped as cosmetic: the spec makes them
  part of the digest, so a missing description is a contract difference and a
  client's generated types lose it.
- The introspected schema is taken from the **notarized application running in a
  VM**, not from a unit-test harness — the composed schema includes the bundled
  desktop provider's contributions, and it is the composition that is being
  checked.
- The `Koine.schemaDigest` served by that application is recorded in the
  evidence, so later leaves and the handoff can cite one value.

## Notes

**This leaf is the most likely in the stage to find a finding, which is why it
runs second** — before five leaves of evidence are written against a schema that
turns out to be wrong. The stage brief's rule applies in full: an acceptance
failure is a finding against an earlier stage's slice, gets its own leaf, and is
**never** resolved by narrowing the contract without the human. If the served
schema and the design SDL differ in a way that changes what a client can do,
that is a question for the human with a recommendation, not a quiet edit to the
SDL.

**Reconciling into the spec is not the same as editing the SDL to match
reality.** The test is whether a reader of `docs/specs/machine.md` would have
predicted the served shape. If yes, update the SDL and say so. If no, the spec
changes too, and the human should see the change.

**Do not reimplement the digest.** The canonical printer already exists in
`Engine`; the check should compare against what the spec defines and what the
server serves, not introduce a third printer whose disagreements with `Engine`
would look like schema drift. If the check needs the canonical text of the
*design* file, print it through the same rules.

**Verifying a claim about the schema is a repo-wide claim** in the sense
`references/execute.md` means: a diff that finds nothing looks identical whether
the schemas match or the comparison is misaddressed. Use a positive control —
mutate one description, one nullability marker and one argument default, and
watch each show up — before reporting a clean result.

**Host rule**: introspecting means launching Koine, so this runs in a VM.

## Decisions (running log)

**The digest rule gets one implementation, not two.** `Engine.digest(of:)` was
private and computed the canonical text inline. It moves to
`Sources/KoineCore/CanonicalSDL.swift`, which `Engine` now calls for the served
digest and which the conformance check calls for the canonical text of an SDL
file. The public entry point (`CanonicalSchemaText`) takes and returns *text*, so
KoineCore's public interface still carries no GraphQL-library type. This is the
leaf's "do not reimplement the digest" note, answered by extraction rather than
by a second printer.

**The comparison reads the canonical text, not the schema objects.** Both sides
reach it as SDL text → schema → canonical print → parse, so nothing reported can
come from the two sides having been read differently, and "no differences" and
"the digests are equal" are one claim rather than two that could disagree. It
also avoids `getFields()`/`getInterfaces()`, which GraphQLSwift/GraphQL 4.2.0
makes internal; the AST nodes are fully public.

**Three facts about what this GraphQL library's introspection carries**, each
measured against a running engine (`IntrospectionFidelityProbe`, since removed;
the assertions survive in `SchemaConformanceTests`), not read from the library's
source alone:

- `__Type.fields` and `__Type.inputFields` are returned **sorted by name**, not
  in declared order (`Koine` introspects as availableCapabilities,
  contractVersion, instanceId, ownGrant, schemaDigest). graphql-js returns
  definition order; this library sorts. So the canonical text — which keeps
  declared order — **cannot be recomputed from introspection**, and the check
  must not compare object- or input-field order from the introspected side.
  Argument order and enum-value order *are* preserved and are compared.
- `__InputValue.isDeprecated` has no resolver and returns null, so the standard
  deprecation-aware introspection query
  (`getIntrospectionQuery({inputValueDeprecation: true})`) comes back with
  `Cannot return null for non-nullable field __InputValue.isDeprecated` and a
  null `fields`/`inputFields`. The query the check sends therefore omits it.
- `__InputValue.defaultValue`'s resolver casts to `GraphQLArgumentDefinition`
  only, so an **input-object field's default is dropped** (`input ProbeIn { a:
  Int = 7 }` introspects with `defaultValue: null`), while an argument's default
  is served. Koine's contract declares no input-object field default today, so
  nothing is lost in practice — but the seam cannot carry one.

**So the strong guard is the design SDL's digest, not the rebuilt one.** Let S be
what Koine serves, I what the check rebuilds from introspection, D the design
file. `digest(canonical(D)) == Koine.schemaDigest` says D ≡ S and needs no
introspection fidelity at all; `differences(I, D)` empty says I ≡ D and says
*where* when it is not. The check requires both, so a clean result cannot be
produced by a lossy rebuild: anything introspection drops that D declares shows
up as a difference, and anything D lacks that S has moves the digest.

**Four differences, and only one of them the served schema's.** The whole-contract
check found exactly four, all descriptions. Three are reconciled into
`docs/design/desktop-schema.graphql` and recorded in `docs/specs/machine.md`
beside the table they belong to, because the spec predicts each served shape:
`Koine.schemaDigest` ("equality token… compare, do not interpret" against the
spec's "equality token… clients compare… they do not recompute it"),
`KoineManagement.osPermissions` ("Reading never asks the user for consent"
against "cannot trigger an OS consent dialog through a read"), and
`Mutation.desktopFocusWindow`, whose served text is the spec's own row for that
coordinate while the design SDL carried the mutation-preflight sentence —
a property of every mutation, not of this field. The design SDL also now declares
its root fields in composition order, since the digest keeps declared order.

**The fourth is `DesktopFocusReceipt` and it went to the human.** The provider
puts the spec's description of the *field* `ref` on the *type*, and states the
type's own fact — "it does not expose a window's read fields" — nowhere, so a
client's generated types lose it. Three options were put with a recommendation;
the human chose to restore both sentences, each where the spec puts them. That is
a change to the served schema, so it is `desktop-receipt-descriptions-k48`,
inserted **before** `contract-only-client-k41` because it moves the digest every
later leaf cites. Reconciling it into the SDL instead would have narrowed the
published contract, which the stage brief forbids without the human.

**The human also settled the three seam limits**: state them in the spec, pin
them with tests, cut no repair leaf. All three are in the GraphQL library's own
introspection types — globals Koine cannot override without forking the
dependency — and Koine's contract exercises none of them.

**The fast guard and the notarized bundle agree to the digit.**
`DesignContractConformanceTests` composes `Providers/DesktopProvider/schema.graphql`
in process as the bundled provider and gets `19615f51…`; the notarized
application, having `dlopen`ed its own sealed provider bundle in a VM, served
`19615f51…`. That is what makes the in-package check a usable first line rather
than an approximation: the shipped bundle's SDL is the file in the tree.

**The known issue is an annotation, not a suppression.**
`theServedSchemaIsTheDesignContract` wraps its two expectations in
`withKnownIssue` naming k48, and asserts *outside* the wrapper that the
difference list is exactly the receipt's two descriptions. So the suite is green,
the finding is visible, and Swift Testing's failure for a known issue that stops
happening is what will say the wrapper can go.

**The `KoineServerTests` flake named in the stage brief did not reproduce.** One
`task test` run failed here immediately after a test file was deleted, with no
detail captured; five consecutive runs since — two through `task test` and three
through `swift test --skip-build` — are green. Recorded, not chased.
