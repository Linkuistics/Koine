# settings-activation-context-k18


## Goal

Discriminate the responsible activation condition using the actual NSApp native
path, repair the application where this repository owns the cause, and qualify
ordinary operation against every original parent criterion.



## Context

Read docs/verification/settings-activation/NATIVE-RESULTS.md and its raw native
streams alongside the original diagnostic and order results. K17's native 01/02
sample passes all four Settings actions in both guests; all recorded capture,
endpoint and cleanup outcomes are clean. It reaches its cap with no failed case.
The original diagnostic sample remains stopped at 02, and the ABBA comparison
remains stopped at four. Do not reset, replace or extend any completed sample.

For each successful selection, a client SLSSetFrontProcessWithInfo call occurs
inside the original NSApp.activate trace interval. WindowServer records a front
change, err=0/noErr and application resume, followed by active/key notifications.
Correlation uses timestamps and process/connection identity, not a verified
transaction ID. A token-check result of -50 also occurs during successful
activation, as does the inactive-window-order warning; neither alone identifies
the failure's cause. Missing log records cannot prove an absent request.

The wide debug sidecar produces roughly 166/284 MB of output and runs alongside
synchronous tracing. There is no symptom-preservation or timing-neutrality
qualification for that added instrument. A narrower native focus filter can be
qualified offline against the saved wide streams before a new experiment, with
synchronous application tracing disabled to address that known timing limit.
The actual-path successful native records remain the reference; do not assume
a different activation API has the same path. No repair is selected by k17.

The unchanged signed diagnostic bundle remains separately at
.build/settings-activation/native/Koine.app; original diagnostic/order bundles
remain intact. Source retains diagnostics, disabled in ordinary operation.
The existing run.sh enables diagnostics even for its repair stage. Do not use
that stage silently for ordinary acceptance. Native startup and stop helpers
preserve single-call raw transport outcomes and reject premature logger exit.

## Done when

- Qualify the native observation under a new bounded protocol before its first
  guest, freezing the actual candidate and every consumed input. A reduced
  filter or operation without synchronous trace must state what it changes and
  preserve every unsuccessful outcome. Do not expand a cap to seek a failure.
- Obtain positive discriminating evidence for a failed actual-path request,
  native disposition or responsible activation context. Preserve the original
  callback/failed-activation classification and every historical failure. Green
  counts, absent notifications/logs and successful alternative calls alone do
  not establish cause or external ownership.
- Repair application behavior where the cause belongs here. Demonstrate a
  useful focused failing seam where feasible. One Settings selection returns
  its one window in front and focused; driver waits/retries or repeated input
  are no product repair. Verify version-dependent AppKit choices against
  official sources and cite non-obvious calls at their decision sites.
- Before the first final repair acceptance guest, separately declare a finite
  complete fresh-guest set through task app:vm-verify-menu-bar. Freeze the final
  ordinary subject and all inputs; run with diagnostics disabled. Retain every
  attempt, failed transport, failure and NOT RUN phase and address instrument
  timing explicitly. Make no reliability claim beyond that sample.
- If the cause is external, retain the positive evidence and reproducer and
  leave the repair outcome explicitly unresolved. No upstream report without
  Antony's approval. No release or notarization is required.
- Reconcile every original k16/k14/k12 criterion and update verification/root
  handoff before closing those nodes. Decompose a newly precise remaining
  question if the next causal slice exceeds one session.

## Notes

Graph startup still refused before project/generation discovery in k17. Bounded
direct source reads were used; do not interrupt other graph sessions for access.
Six native helper, five capture, eight pointer and nine resize controls pass.
These qualify scripts, not native activation reliability or a product repair.
