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

## Decisions (running log)

**Three profiles, three serving hosts.** The old-host profile is served by the *released* v0.1.0 server (built from its own extracted source by `build-baseline-host.sh`) with its own desktop provider bundled; the extension-host core + desktop profile by this tree's headless host with desktop as its only bundled provider; core + desktop + workspace by the signed `Koine.app` in a VM. A VM cannot serve core + desktop any more, because the signed application now bundles workspace and altering a signed bundle breaks it. `task conformance` runs all three (`scripts/conformance.sh`); `conformance:headless` and `conformance:vm` run the parts.

**The released host needed a bundled root to serve desktop.** The released `KoineCompatibilityHost` takes a data directory alone, so the released server rejected desktop as reserved (`desktop is reserved.`, seen first). `scripts/compat-released-host-main.swift` is that driver plus the optional bundled root the released application has; `build-baseline-host.sh` copies it over the driver in the extracted tree. The released server code is untouched, and with one argument the driver is the released one. The served digest is the released `ee17dfd1…`.

**The workspace design SDL is the design restricted, never reworded.** `docs/design/desktop-workspace-schema-extension-host.graphql` is the desktop extension-host file plus `workspace-schema.graphql`'s implemented root and every type it reaches. `theWorkspaceProfileIsTheWorkspaceDesignRestrictedVerbatim` compares it with desktop plus the complete workspace design and demands the only differences are the three unimplemented roots and the two types only they reach (`workspaceCoordinatesNotYetImplemented`); each later root leaf removes its coordinates from that set. Seen red against a reworded description and against a dropped root.

**The signed build is what the workspace profile checks, not a notarized one.** The leaf's goal says "signed build". `vm-verify-conformance.sh` now verifies the signature strictly and records whether the ticket is stapled, requiring it only under `KOINE_CONFORMANCE_REQUIRE_NOTARIZED=1`.

**Controls live in `scripts/conformance-lib.sh`, shared by all three profiles.** Four design mutations and three pin mutations for every profile; the workspace profile adds the launch root removed, a workspace description changed, the launch field moved before desktop's (caught by the digest alone) and two workspace pin mutations. All seen red before each green.

**Result, signed build `dev.antony.Koine` (TA43A4RUP3), VM run `conformance-20260930T230050`:** desktop and workspace both `ACTIVE`, `BUNDLED`, `SELECTED`; served digest `a56a3387…` equals the design file's; no differences.

**The client was extended by a session that read only the published documents, and its guesses are findings.** It added `launch` and two classifications (`dependency-unavailable`, `input-error`) and wrote `docs/verification/launch-contract-client-findings.md`, sixteen findings. This leaf's own session had read implementation, so it could not honestly be the author. The restriction was an instruction, not a reach property as the first client's was; the author's tool calls were searched afterwards and no forbidden path appears (11 reads, all documents and the client). The repairs were made here, from its proposals and checked against the engine (F6: a root mutation is admitted once and never re-checked, only nested fields are) or a test (F3) or the wire (F7/F8/F13); F9, F12's timing half and F16 are declined for version 1 with their reasons in the findings' disposition table.

**An installed application that cannot be opened needs a bundle Launch Services registers.** Three fixtures were tried in a scratch VM before the recipe used one. A bundle with no executable, and one whose executable is a text file, are not registered, so the provider correctly answered `APPLICATION_NOT_INSTALLED` (seen in the recipe's first real run). A truncated Mach-O (8 192 bytes of `/usr/bin/true`) registers and fails to open with `-10810`, which the provider reports as `failed`; a script with no shebang gives `-10669`. The recipe uses the truncated Mach-O and asserts `failed` at the action's path, `actionEffect: may-have-begun`, exactly one request and nothing launched.

**Shared recipe material was extracted, and the recipes that depend on it were repeated.** `vm-verify-launch-lib.sh` (the witness helpers and the first-run preparation) and `vm-verify-contract-client-lib.sh` (client calls, window approval, enrolment) now serve both the existing scripts and the new one; `contract_client_once` runs a non-repeatable command once (status 7 only is retried), as the launch recipe did for its Python client. Repeated on the same signed build, each to a pass: `app:vm-verify-contract-client`, `app:vm-verify-launch` and `task conformance`.

**A `set -e` death in the Gatekeeper preparation was made tolerant.** `spctl -a -vv` of Notes, read through `guest`, ended a run silently when the agent's false timeout outlasted the retries; the read (and the status read before it) now tolerate a non-zero exit, and the `grep` assertions on their content are unchanged.

**The spec rows and the node's `Done when` link the evidence.** `docs/verification/launch-contract.md` (new) and `schema-conformance-vm.md`; `workspace-launch-and-open.md`'s Packaging/selection and a new "client from the contract alone" bullet; `machine.md`'s conformance profile table; `_launch-path.md`'s two Done-when bullets.
