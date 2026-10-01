# stabilise-dependency-denial-test-k87

## Goal

Make `WorkspaceCompositionTests.denialInsideADependencyWithholdsItsNonNullFieldAndSoTheDependency`
deterministic, or state the contract it can actually hold.

## Context

Found by `open-url-k71`. In a full `swift test` run the test fails intermittently (about two in
five runs there) with `reply.error(at: ["launch", "dependency", "reason"]) != nil` false, and
passes alone eight times in eight. It revokes the grant as `WorkspaceDependencyUnavailable.reason`
is admitted and expects the denial reported at that field, but `reason` and `guidance` are
non-null siblings resolved concurrently, so the error can be reported at `guidance` instead,
with the dependency still withheld. The suite's own comment notes sibling order is not the
contract's. Not attributed to any change: a run at the parent revision to compare could not
load the test frameworks.

## Done when

- The assertion holds whichever sibling's denial is reported, or the scenario selects one
  field, as the other denial tests do.
- Repeated full runs (at least twenty) show no failure of it.
