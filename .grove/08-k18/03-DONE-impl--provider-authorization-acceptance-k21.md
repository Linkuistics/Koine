# provider-authorization-acceptance-k21

## Goal

Prove at the public GraphQL seam that Koine enforces a provider's read and
control capabilities on every path to its fields, and that mutation preflight
and live revocation hold for provider actions.

## Context

- Spec: "Composition and operation placement" (authorization by schema
  coordinate), "Mutation preflight and revocation", "Errors and partial data",
  and the "Public GraphQL authorization" row of "Test seams and acceptance".
- Read `RevocationOrderingTests` and the engine's internal `OrderingHook`; the
  stage brief says what they already cover for core fields.

## Done when

The fixture provider gains call counters and a gateable action, readable and
controllable across the binary boundary. Against it:

- The same resource reached by both lookup paths, through nested fields,
  aliases, fragments and `@skip`/`@include` with coerced variables, enforces
  read authority on every path; a denied resolver is never called.
- A mutation mixing permitted and denied actions, including a denied action
  inside a variable-controlled fragment, makes zero action calls. A skipped
  denied action does not block a permitted one. Preflight resolves reference
  authorities from arguments and performs no provider resolution.
- Revocation between preflight and dispatch prevents that dispatch. Revocation
  between two actions stops the later one without undoing the earlier. A
  provider read whose grant is revoked before publication is not published.
  Orders are forced deterministically, not sampled.
- A control-only grant can run an action and read its control-authorized
  receipt, and is denied read-protected output with the agreed error.
- Errors carry `extensions.kind`, `permissionClass` (`capability` and
  `os-permission`, the latter reported by the fixture), `requiredCapability`,
  and the original response path including aliases and list positions. A denied
  non-null field propagates to its nearest nullable ancestor and other branches
  survive. `unknown-provider`, `unavailable` and `failed` are each produced.
  No error exposes a token or native detail.

## Notes

This is the `revocation-ordering-and-store-failure-k15` pattern: constrain a
path that exists. Where the engine already satisfies a case for provider fields
through shared machinery, a test that shows it is the deliverable; fix only what
fails. Do not duplicate a core-field test that already covers a case
independently of providers; cite it.

## Decisions (running log)

- **The fixture's counters and gate are its own GraphQL fields**
  (`fixtureCalls`, `fixtureCloseGate`, `fixtureOpenGate`), read and driven by a
  separate operator grant. Counting precedes holding, so "a call is inside the
  fixture" is an observable state a test waits for; the counters, the gate and
  their fields are neither counted nor held.
- **Orders are forced with the gate over real HTTP, not the engine's
  `OrderingHook`.** A held action fixes "revoke after action 1 was admitted and
  before action 2's dispatch"; a held read fixes "revoke before publication".
  The hook-forced orders for core fields stay `RevocationOrderingTests`' and
  are not repeated; the test target gains no dependency on the loader.
- **Found and fixed: preflight ignored reference arguments.** The spec has
  preflight resolve "any reference authorities from its arguments". A field
  whose arguments hold a reference owned by another registered provider now
  also requires that owner's capability of the field's class (`<owner>:read` or
  `<owner>:control`). One `FieldRegistration.argumentAuthorities` closure is
  evaluated at preflight, at dispatch and at the publication recheck. An
  unregistered owner stays `unknown-provider` at execution, "after applicable
  capability checks". This narrows k20's "references may cross": they still
  cross, given the owner's capability. The spec states the rule now;
  `ReferenceRoutingTests.argumentsArriveCoerced…` grants `good:read` for it.
- **Preflight reads arguments untyped.** GraphQLSwift 4.2.0 keeps
  `getArgumentValues` internal; the public `valueFromASTUntyped` plus the
  declared argument types and defaults is enough, since a reference is a string
  however it arrives. A value execution would refuse to coerce names no owner,
  and execution refuses it before any action.
- **A revoked grant's held action finishes but its receipt is withheld.** The
  receipt's fields are output reads, checked at admission and publication like
  any read. The test asserts that (`first/ref` is `permission`) and that the
  rename stands, per "a denied output field is not evidence that the preceding
  action did not occur".
- **`FixtureRenameReceipt.affected`** (control, `[FixtureItem!]!`) is how a
  control-only grant reaches read-protected output: it gives the denied
  non-null field under an alias and a list position, and the propagation to
  the nullable action field, in one case.
- **Not repeated, cited:** `unknown-provider` after the capability check,
  malformed provider output as `failed`, and no native detail in a resolver
  mismatch (`ReferenceRoutingTests`); `kind`/`requiredCapability` on a plain
  provider read denial (`NativeProviderTests`). "No token exposed" is checked
  on every reply the new suite receives.
- **Mutation check.** With preflight's owner check and the publication recheck
  each removed, exactly `preflightReadsReferenceOwners…` and
  `aProviderReadRevokedBeforePublication…` failed; the engine was then restored.
