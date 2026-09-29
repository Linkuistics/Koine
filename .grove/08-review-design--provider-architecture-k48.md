# provider-architecture-k48

**Reviews:** provider-architecture-k5


## Goal

Adversarially review the cross-cutting provider architecture against the agreed
workflow requirements before dependent designs build on it. Read the producer's
commit by its stable handle, then reconcile that diff with the current tree.



## Context

- `docs/requirements/modaliser-workflows.md` is the behavioral contract.
- `docs/specs/workflow-providers.md`, the additions to `docs/specs/machine.md`,
  `docs/adr/provider-authority-follows-effects.md`, and the reworked server,
  reference and resilient-framework ADRs are the artifact.
- The root brief and launch/open handoff carry the first implementation owner.
- `docs/design/architecture/README.md` describes the editable visual views and
  their render/serve tasks. Producer verification is in its decision log.

## Done when

Produce findings with evidence and consequence, or explicitly find no material
issue. Challenge the design rather than implement it. In particular:

- Does provider-local process/target capture actually permit input and menu
  operations without desktop control while preserving opacity and selection?
- Does the distinction between Koine-requested native actions and an
  application's reaction satisfy the agreed effect boundary? Try menu items
  that open windows, tool commands that activate, menu cleanup, and input
  fallbacks. Do not assume unknown native behavior is already demonstrated.
- Does the static additional-capability conjunction preserve whole-operation
  preflight, live admission, read publication and control-only receipts? Are
  capability-owner absence, rejection, cycles and startup failure coherent?
- Is the framework change truly additive for old compiled providers and refused
  before loading by old hosts? Is reuse of the current framework otherwise
  preserved, with no implicit incompatible public-contract change?
- Can a standalone client distinguish missing dependency, stale target,
  successful empty result and permission refusal after a readiness/action race,
  without the result suggesting rollback of earlier effects?
- Does the cumulative trace allocate every inventory row and named effect,
  preserve client ownership and scope exclusions, and leave only API/native
  questions that the downstream charters actually own?

Check the visual document against those decisions. The producer rendered and
inspected exports, but browser automation was unavailable: verify actual
deep-link rendering, current-discussion markers, readability and mobile/dark
appearance when browser access is available. Do not misreport this limitation
as a failed native acceptance test.

## Notes

This review is deliberately before `launch-and-open-k18`: several later
increments depend on the authority and compatibility decisions. No implementation
or native workflow acceptance is claimed by the producer. Keep any findings in
this review's own artifact/commit. If integration is needed, its charter points
to this handle rather than copying the findings as a mandatory work list.
