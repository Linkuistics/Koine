# provider-architecture-k49

**Integrates:** provider-architecture-k48

## Goal

Triage `provider-architecture-k48`'s review of the cross-cutting provider
architecture, and apply the real findings before `launch-and-open-k18` builds on
it.

## Context

- Read the findings from `provider-architecture-k48`'s own commit. Its
  coordinates name producer commit `53ed64968d40` (`provider-architecture-k5`);
  that review's `leaf-insert` renumbered the `.grove` siblings, so resolve
  handles for current paths.
- `provider-architecture-k5` is the design producer. The artifact is
  `docs/specs/workflow-providers.md`, the extension sections of
  `docs/specs/machine.md`, `docs/adr/provider-authority-follows-effects.md` and
  the reworked server, reference and resilient-framework ADRs.
- `docs/requirements/modaliser-workflows.md` and `plan-k4`'s integrated
  decisions govern scope.

## Done when

Each finding is classified as a contract stated unclearly, a real issue, a
visible trade-off or noise. Justified changes are applied to the spec set and
ADR set as `ADR-FORMAT.md` and `SPEC-FORMAT.md` direct, keeping the downstream
charters consistent with them. The reasoning for findings not applied is
recorded. Any question that changes agreed requirement text, the signing
posture or what `koine-desktop/1` promises existing clients is raised with
Antony, with a recommendation.

## Notes

This is design integration, not implementation. Do not treat the reviewer's
suggested corrections as a preapproved work list. Assess the evidence and choose
the smallest coherent correction. A finding that needs the architecture
rethought rather than repaired becomes a new design review chain, not an
unreviewed redesign here.
