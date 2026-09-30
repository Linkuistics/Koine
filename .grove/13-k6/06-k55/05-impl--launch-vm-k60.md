# launch-vm-k60

## Goal

Accept the launch path at the V seam. Signed Koine in an isolated TestAnyware
macOS VM launches and reactivates one real required launcher application under
workspace and desktop control. The measured outcomes are recorded.

## Context

- The workspace spec's acceptance rows, in their V parts:
  - Twelve launchers, for one application;
  - Receipt/failure boundary;
  - Bounded acknowledgment, for timing;
  - Authority/revocation;
  - Consent and prompts, for Accessibility.
- The existing desktop VM recipes and their independent native witness.

## Done when

- The chosen application has completed first run and Gatekeeper approval in the
  VM. Its actual bundle identifier, version and path are recorded.
- A cold launch and a reactivation while running each happen with another
  application frontmost and Koine inactive. An independent witness observes
  activation. Acknowledgment without activation fails the case. Callback latency
  is recorded for both.
- Reactivation creates no new instance: the running copy is reused. The launch
  call path's actual native primitives and parameters are inspected and recorded
  against the authority trace. This keeps Koine's own activation separate from
  the application's reaction.
- A returned process identity matches the witness's kernel identity. It is
  accepted by `desktopApplication(process:)` under `desktop:read`. The process's
  real exit is then observed.
- Either control alone, and a revoked grant, cause no launch and no focus
  change. Both controls without any read capability suffice.
- With Accessibility absent, and again after it is revoked, launch still works
  and raises no consent prompt.
- The client's optional recovery is exercised separately: a desktop read plus an
  explicit focus, each under its own grants.
- If controls-only activation fails the requirement, the case stays pending. The
  measured limit goes to Antony before the case closes.
- A reusable Taskfile VM recipe exists. An evidence document lands under
  `docs/verification/`, and the spec rows link it.

## Notes

Nothing drives an application on the host. The acknowledgment is not a focus
guarantee, and the workspace path must never silently require a client yield or
a desktop read.
