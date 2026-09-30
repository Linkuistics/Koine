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
