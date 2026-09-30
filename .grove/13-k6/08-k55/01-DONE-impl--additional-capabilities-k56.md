# additional-capabilities-k56

## Goal

Implement the compatible provider-framework minor carrying the required feature
`additional-capabilities-v1`. A field's immutable additional read or control
requirements are then enforced wherever its own requirement is, and contributions
whose capability owners are missing are removed to a fixed point. Every existing
registration keeps exactly its meaning.

## Context

- `docs/specs/machine.md`, "Additional capability requirements", which is the
  whole contract. Also "Mutation preflight and revocation", "Errors and partial
  data", and the evolution rules in "Native extensions".
- `docs/adr/provider-authority-follows-effects.md`.
- `docs/verification/binary-compatibility.md` and the compatibility-pair recipes.

## Done when

- The framework adds new resilient declarations: a capability requirement naming
  a provider identifier with `read` or `control`, and a field-registration
  initializer taking the additional set, empty by default. The framework minor
  advances and old symbols keep their behavior. The host advertises the new
  minor and the feature. Manifest and descriptor both declare the feature, and
  the manifest declares the implementing minimum minor.
- The host rejects a descriptor that uses additional requirements without
  declaring the feature. It refuses core enrollment or management authority in
  the set, and additional control on any query-reachable field.
- One ordered requirement set drives whole-mutation preflight, live dispatch
  admission, and read authorization and publication. The order is the field's
  own capability first, then the additional ones in Unicode code-point order,
  then argument-reference owners, with duplicates removed.
- `requiredCapability` names the first unmet member. The additive
  `extensions.requiredCapabilities` carries the complete ordered set at the
  denied action's original response path. Baseline registrations' errors keep
  their order and content.
- After ordinary rejection, a contribution naming an absent owner is removed,
  and removal repeats in canonical order until the admitted set stops changing.
  Management diagnostics name the missing owner. Valid dependency cycles survive.
  A provider that fails startup after publication keeps its schema and triggers
  no removal.
- G: public-GraphQL tests over fixture contributions cover aliases, fragments,
  argument defaults, nested reference inputs, skip and include, multi-action
  preflight with zero action calls, revocation between actions and read
  republication.
- N: independently built old and new binaries. The old host refuses a provider
  requiring the feature before load, with no initializer marker. An old provider
  and the existing desktop run unchanged on the new host. The new host refuses an
  undeclared use. The recipe that builds the pre-extension host from the released
  revision is reusable.
- Machine's acceptance status and the workflow spec's compatibility row claim
  exactly what this leaf established.

## Notes

Fixture providers are the feature's only consumers until `workspace-launch`.
Today's pair recipes simulate a framework minor with an evidence-only overlay.
Once a real minor lands, that overlay no longer represents "newer". Build the
pre-extension side from the released 0.1.0 sources instead. Selection's old-host
refusal cases reuse that build, so leave it as a Taskfile recipe.

The spec requires field descriptions to state the complete declared set. Decide
whether composition checks this or it stays a publication rule, and record the
choice.

## Decisions (running log)

**Field descriptions stay a publication rule.** Composition does not check that a
field's description states its complete declared set. Prose cannot be verified
faithfully: a substring test passes a description that lies, and a stricter one
refuses valid providers over phrasing. The mechanical guarantee is
`extensions.requiredCapabilities`, which a client reads instead of the prose. Each
provider that ships a set owns a test of its own descriptions (`workspace-launch`
for its fields); the framework only demands the declaration.

**A capability requirement is refused, whole contribution, for four reasons.** A
descriptor that uses the set without declaring `additional-capabilities-v1`
(`undeclaredFeature`, REJECTED not INCOMPATIBLE: the descriptor lied, the host did
not lack anything); a set naming `koine` or a string no provider can be; additional
control on a query-reachable field; an unknown kind. Naming the provider's own
identifier is accepted and adds nothing (deduplicated with its own capability).

**The cascade only removes.** After ordinary rejection the admitted set is filtered
to a fixed point in rounds, and the schema is rebuilt from the survivors without a
second introspection-size admission. A contribution refused for size earlier is
not readmitted because a later removal frees budget (tested with a real budget).
Cycles survive because the check is membership of the admitted set, never a walk
of the dependency graph.

**`Reference` scalar serialization accepts the library's `Map`.** A provider SDL
default of a `Reference` type crashed the host when the schema was printed, because
the library serializes a declared default as a `Map` while a resolver's result is a
`String`. Argument defaults are one of the cases the contract says the requirement
set must handle, so the scalar now accepts both. Found by the first fixture that
declared a `Reference` default.

**`requiredCapabilities` only where the field declares a set.** A baseline
registration's error keeps its exact keys (asserted), so the additive key is not a
change for any existing client.

**The one in-session review was spent on the framework additions and the
composition contract**, a fresh context told to find what is wrong. Classified:
*valid and actionable* — preflight read an action's arguments untyped, so a
reference reaching its owner by a variable's default, a lone value for a list or
an input field's default was missed until dispatch, which would have let an
earlier action run before a later one was refused (the untyped read predates this
leaf, the contract now depends on it; fixed by reading variables with their
defaults and normalizing lists and input defaults where owners are extracted, with
a test per input that fails when the fix is removed); identifiers under the `koine`
prefix were admitted and only later removed as a missing owner, spending
introspection budget on a contribution that can never stay (refused up front);
argument owners were ordered by identifier where the set is ordered by code point
of the capability (`zed1:control` precedes `zed:control`; a field that declares a
set now orders both alike, and a field that does not keeps its baseline order);
a `Reference` default that is no reference would fail introspection for every
client (refused at composition); a set that only repeats the field's own
capability annotated its errors although its effective set was the baseline (now
the baseline); the requirements of one field are checked against one reading of
the principal's authority, so a revocation between two members cannot move the
first unmet member; a manifest naming the feature under minimum minor 0 is
refused by a host that has the feature. *Noise or accepted*: none was dropped.
No second reviewer was spent; the fixes are covered by executable tests.

**One check of the pairs is intermittent and predates this leaf**: the held call
at stop. It is cut as `held-request-answered-at-stop-k83`, ahead of
`provider-selection-k57`, which reuses the pairs.
