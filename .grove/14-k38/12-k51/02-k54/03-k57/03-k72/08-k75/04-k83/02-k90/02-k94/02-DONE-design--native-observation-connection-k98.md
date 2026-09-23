# native-observation-connection-k98


## Goal

Establish whether a legitimate owned client connection can support observation
registration at the retained endpoint, with evidenced scalar, flag and requester
semantics, policy checks and ownership; report a concrete conflict if it cannot.



## Context

Consume k97's `docs/verification/native-observation-requests.md` and the k93
layout dossier. The first
request descriptor is a client connection, not the destination or delivery port.
An arbitrary right of the expected width is not an established connection.

## Done when

- Trace `getClientPortFromCache`, connection creation/target acceptance and
  release on pinned bytes; record exact target/callback/policy dependencies.
  Separate initial endpoint discovery from forbidden destination reacquisition
  beneath an already admitted capture.
- Establish process/element scalar, registration flag and `_axIPCRequester`
  meaning through producer, decoder and consumer; account for voucher/audit
  use and refusal. Identify remote-app/block/custom branches still unsupported.
- Supply a minimal constructible ownership/policy contract for k99, or an exact
  feasibility conflict before it sends. Freeze all measurements; execute native
  diagnostics only in disposable VMs and preserve controls and rights accounting.
- Keep public clients, Koine-owned consent and no helper/injection/cooperation.
  Diagnostic comparison is not an adopted ABI. Surface any new consent or
  workflow conflict without authorizing a support restriction.

## Notes

k99 retains fresh reply/trailer/live-task authentication and every exercised
receive/cleanup path, as well as the witnessed exchange. k86 retains maintained
consent/profile/limits; k91 retains its broader failure and cancellation matrix.

## Decisions (running log)

- Begin with bounded loaded-byte inspection in an isolated VM, using the
  existing read-only scanner and pinned k97 coordinates. Do not run a native
  registration while connection or policy fields remain guessed. A model
  cannot establish these platform premises; retain raw native evidence and
  explicit uninspected branches as the handoff.
- The pinned path creates its client connection locally, separately from PID
  destination lookup. Preserve four explicit owners: destination, connection,
  delivery and fresh reply. Record the conditional constructible contract and
  native scalar/requester/first-add semantics in the evidence report; do not
  elevate them to runtime acceptance. k99 must freeze voucher context and
  exercise receive/cleanup, first-add failure and removal before any exchange
  can be credited. No product decision changes, so no new ADR is warranted.
