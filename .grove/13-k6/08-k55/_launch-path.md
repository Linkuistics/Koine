# launch-path-k55 — brief

## Goal

The first working increment, and the pathfinder's first slice. One real
application launches or activates from a standalone client through the complete
production path:

- a bundled workspace provider, chosen by the sealed catalogue and loaded by the
  selection-aware native loader;
- framework-enforced `workspace:control` AND `desktop:control`;
- the served public schema and a contract-only client;
- a signed isolated VM.

Every later increment widens this path and adds no layer it lacks.

## Done when

- In a signed TestAnyware VM, a standalone client holding only both controls
  launches one required launcher application while it is stopped. It then
  reactivates the application while it runs. Each time, another application is
  frontmost and Koine is inactive. Activation is observed, never inferred from
  acknowledgment. Either control alone, or a revoked grant, is refused before any
  inspection. A returned process identity is accepted unchanged by
  `desktopApplication(process:)` under `desktop:read`.
- The framework minor with `additional-capabilities-v1` is served, and old
  registrations keep exactly their meaning. Independently built old and new
  binaries show the feature working and its pre-load refusal on the old host.
- The sealed catalogue enables desktop and workspace at the versions and signing
  identifiers their signed packaged bundles actually carry, and reserves the
  other four identities. Candidate diagnostics are published as additive
  management metadata.
- The old-host core + desktop profile is preserved. The extension-host
  core + desktop and core + desktop + workspace profiles pass against served
  schemas, with exact candidate versions pinned separately from SDL and digest.
- A client written from the documented contract alone drives the launch.
- The Taskfile carries the reusable build, catalogue-check, conformance and VM
  recipes the path needed.
- Each acceptance row this path establishes links its evidence. Every other row,
  and the rest of every partly covered row, stays pending.

## Decomposition

The charter's "first implementation slice" is this node. It is several sessions
of work, so its leaves are ordered expand-first, and each leaves `task test` and
the signed application green. Each is verifiable at its own seam: fixtures for
the framework feature and desktop candidates for selection. Packaging stays with
the first operation, because neither half is a working increment alone.

1. `additional-capabilities`: the framework minor, the core authority union and
   the missing-owner cascade, verified with fixture providers and old/new binaries.
2. `provider-selection`: loader selection over both roots and the sealed
   catalogue, with desktop enabled and the other five identities reserved.
3. `selection-diagnostics`: management candidate fields, the native window
   grouping and the extension-host core + desktop profile.
4. `workspace-launch`: the workspace bundle with its launch operation, packaged,
   enabled and verified at L, G and N.
5. `launch-vm`: V acceptance of activation, authority, consent, receipt handoff
   and timing. This is the riskiest native question, so it runs before contract work.
6. `launch-contract`: the core + desktop + workspace conformance profile, the
   contract-only client and client-guide coverage.

## Notes

The first launch application is any one of the twelve required launchers whose
first run can be completed without an account. Notes ships with macOS and is
the likely choice. Record the choice and its preparation. Installing all twelve
belongs to `application-launchers`.

The development and `swift test` hosts are unsigned. Under the catalogue's
host-team rule they admit no shipped candidate. The existing suites stay
meaningful only through the loader's private seam, never through a public test
API. Trust acceptance needs real signed hosts.
