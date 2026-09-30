# launch-contract-k61

## Goal

Accept the launch path's public contract:

- conformance checks the signed build's served schema against the exact
  core + desktop + workspace profile, beside both desktop profiles;
- a client written from the documented contract alone drives the launch.

## Context

- The workspace spec's "Packaging and compatibility" section, and Machine's
  "Candidate diagnostics and schema identity" profile rules.
- `docs/verification/contract-only-client.md`, `docs/client-guide.md` and
  `clients/contract-only`.

## Done when

- `task conformance` checks three profiles against the schemas they serve, with
  exact candidate versions pinned separately from SDL and digest:
  - old-host core + desktop, preserved;
  - extension-host core + desktop;
  - core + desktop + workspace, with desktop `1.0.0` and workspace `1.0.0`,
    both bundled.
- The workspace profile expects the design SDL restricted to the implemented
  roots and the types they reach, verbatim. A missing required provider or
  coordinate fails.
- The check is seen red against mutated expectations before a green run is
  credited.
- The contract-only client is regenerated from the served introspection and
  launches the application in the VM through the documented contract. It tells
  apart:
  - dependency unavailability;
  - capability denial, with its complete required set;
  - `failed`;
  - an absent process.
- The client-guide covers what this path added for clients:
  - the control conjunction;
  - `extensions.requiredCapabilities`;
  - typed dependency results;
  - the receipt-to-desktop process handoff.
- Every place the client had to guess is a finding. It is repaired in the
  documents or declined for version 1 with a reason, as the existing evidence
  document does.
- The spec rows and the launch-path node's `Done when` link the evidence.

## Notes

`task design:workspace-check` validates only the design files. It is not runtime
conformance.
