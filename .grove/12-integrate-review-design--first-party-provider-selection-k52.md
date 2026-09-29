# first-party-provider-selection-k52

**Integrates:** first-party-provider-selection-k51


## Goal

Triage the findings of `first-party-provider-selection-k51` against the
first-party selection design from `first-party-provider-selection-k50`. Apply
the real ones to the design artifact, so launch-and-open consumes a settled
contract.

## Context

- The review's findings live in its own leaf and commit, anchored to the producer
  commit. Read them there; this charter deliberately does not restate them.
- The artifact is `docs/specs/machine.md#first-party-provider-selection` and the
  selection rows of `docs/specs/workflow-providers.md`, plus
  `docs/adr/koine-server-and-native-providers.md`,
  `docs/adr/resilient-provider-framework.md`, `CONTEXT.md` and the two selection
  views in `docs/design/architecture/` with their captions.
- The root brief's first-party selection paragraph and the launch-and-open node
  and design leaf cite this contract.

## Done when

- Each finding is classified: applied, rejected with a reason, or a stated
  accepted limit. Nothing is taken on as mandatory merely because the review
  raised it.
- Accepted changes are reflected consistently in the spec, the ADR set as a
  minimum coherent set, the glossary, the diagram sources, their exports and
  captions, and every brief that cites the contract.
- Any change that narrows what an approval record admits, alters signing posture,
  or changes the `koine-desktop/1` promise is raised with Antony, with a
  recommendation, before it is built on.
- The documentation checks and the selection render task pass after the edits.

## Notes

This integration runs before the launch-and-open node, so no consuming design or
planning sees the unsettled contract. Loader implementation and acceptance stay
with launch-and-open. Where a finding rests on platform reasoning rather than an
observation, prefer handing its confirmation to launch-and-open's native evidence
over widening this session.
