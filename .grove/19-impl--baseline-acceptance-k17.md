# baseline-acceptance-k17

## Goal

Close the agreed baseline. Every inventory row and acceptance case in
`docs/requirements/modaliser-workflows.md` is traced to its public operations
or explicit client responsibility, and demonstrated through the three seams,
or listed as pending with its reason.

## Context

- The operation-to-capability trace each increment extended.
- The increments' `docs/verification/` evidence and spec sections.
- The root brief's coverage table.

## Done when

- A contract-driven standalone client, built from the documented and
  introspected contract, demonstrates every row in VMs. The client may be the
  existing contract-only client extended, or another.
- The trace is complete, including the authority of every effect.
- Denied, revoked, empty, unavailable and missing-integration cases are shown
  distinguishable.
- Application and tool versions, supported cases, observed interactive
  latency and every platform or application limitation are recorded, and none
  silently reduces the baseline.
- The requirements document's status no longer says the work awaits design
  and implementation.
- The spec's acceptance status, and the client guide where it changed, are
  current.
- Pending cases are listed with the account or data each still needs.

## Notes

This leaf consolidates evidence rather than creating it. A row that fails here
gets a leaf in the increment that owns it.
