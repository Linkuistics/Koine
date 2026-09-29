# providers-k3


## Goal

Turn the agreed workflow requirements into small, independently verifiable
increments that deliver the Koine provider support. Establish which scoped
design or native-evidence work is needed before cutting implementation leaves.

## Context

- `docs/requirements/modaliser-workflows.md` is the agreed scope and acceptance.
- Resolve `plan-k1` for the human's decisions and configuration evidence.
- Resolve `plan-k2` for the requirements review; incorporate any integration
  that the review inserted before this leaf.
- `docs/specs/machine.md` and its cited ADRs define the existing GraphQL,
  authorization, reference and native binary contracts.
- `Taskfile.yml` is the entry point for reusable checks and the existing public,
  native and VM test seams.

## Done when

The tree contains the next concrete, independently useful work, with child
charters tying every accepted workflow family to a public capability or an
explicit client responsibility. The order resolves concrete design and native
evidence questions before dependent implementation. The root brief explains
the decomposition and its acceptance coverage; uncertainty that cannot yet be
phrased stays in the brief rather than in speculative implementation leaves.

## Notes

This is a larger workstream, not a one-sitting implementation. Provider count
and boundaries are deliberately unsettled. Plan vertical increments across the
native plugin and public GraphQL seams, so each can demonstrate useful behavior
without ModalAnyware. Do not partition solely by Swift file or horizontal layer.

Questions already precise enough to place include:

- What evidence is needed for dynamic/context-menu discovery, item validation,
  explicit opening and cleanup under the existing public native boundary?
- How should app-targeted input and multi-request interactions preserve target,
  modifier ownership and interruption behavior within the existing framework?
- Which reusable desktop, launch/search and pointer/media operations serve
  multiple configured workflows, and which app/tool integrations need their own
  native contract or prerequisite setup?
- How will VS Code parts/Grove behavior and nested iTerm/herdr/Zellij/Neovim
  instances be demonstrated through the three agreed seams?

Commission a design leaf where an API or provider boundary needs an agreement
point, and a focused prototype/evidence leaf where native feasibility is the
uncertainty. Reuse the current framework unless a concrete requirement proves
it insufficient. Keep the spec and ADR sets current as design settles.

Do not re-interview the workflow scope, menu choices or test seams. Do not
implement or restart Modaliser or ModalAnyware. Tests must use isolated VMs for
real native effects; missing integration prerequisites must not be passed off
as successful empty results. Record any later proposed scope change explicitly
rather than silently reducing the agreed baseline.
