# baseline-acceptance-k17

## Goal

Close the agreed baseline. Every inventory row and acceptance case in
`docs/requirements/modaliser-workflows.md` is traced to its public operations
or explicit client responsibility, and demonstrated through the three seams.
A pending case is never a passing outcome, so the baseline closes only when
none remains.

## Context

- The operation-to-capability trace each increment extended.
- The increments' `docs/verification/` evidence and spec sections.
- The root brief's coverage table.

## Done when

- A contract-driven standalone client, built from the documented and
  introspected contract, demonstrates every row in VMs. The only permitted gap
  is an account-dependent case that `account-acceptance` left pending. The
  client may be the existing contract-only client extended, or another.
- The trace is complete, including the authority of every effect.
- It includes protected-UI refusal, bounded Space switching, pointer-button
  authority, cleanup authority fixed at admission, partial search coverage and
  prompt-free reads. Grant disclosure is accepted for new and existing grants
  before their added effects ship. Native evidence distinguishes selected calls
  from application reactions under Antony's accepted boundary.
- Denied, revoked, empty, unavailable and missing-integration cases are shown
  distinguishable.
- Application and tool versions, supported cases, observed interactive
  latency and every platform or application limitation are recorded, and none
  silently reduces the baseline.
- The requirements document's status no longer says the work awaits design
  and implementation.
- The spec's acceptance status, and the client guide where it changed, are
  current. They name any pending case as pending, never as passed.
- If a case is still pending, the baseline stays open. Each pending case
  remains identifiable live work: a leaf cut after this one, naming the
  account or data it needs and the cases it unblocks. Dropping a pending case
  from the baseline is a scope change only Antony can make. Raise it with a
  recommendation rather than closing around it.

## Notes

This leaf consolidates evidence rather than creating it. A row that fails here
gets a leaf in the increment that owns it.
