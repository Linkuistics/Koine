# The launch path's public contract

The last increment of the launch path ([`launch-path`](../specs/workspace-launch-and-open.md))
accepts what a stranger sees: the schema the **signed** build serves, held to the
exact core + desktop + workspace profile beside both desktop profiles, and a client
written from the documented contract alone driving the launch in a signed VM. Two
things were run, and this document records each.

## 1. Conformance: three profiles, three hosts

`task conformance` holds three profiles to the schema their hosts serve, each with its
candidates pinned apart from the SDL and the digest. The procedure, the controls and
why each profile is served where it is are in
[schema-conformance-vm.md](schema-conformance-vm.md); this is what the runs showed.

| Profile | Served by | `Koine.schemaDigest` | Candidates served |
|---|---|---|---|
| `core-desktop-old-host` | the released v0.1.0 server (`ee471613…`), built from its own sources, with its own desktop provider bundled | `ee17dfd16a7d00079a9dd1e7523954dba8ced0052096e75d2dc7bdaacb5e2baf`, the digest 0.1.0 shipped | `desktop` 1.0.0 / 1.0.0 `ACTIVE`, over the original five management fields |
| `core-desktop-extension-host` | this tree's headless host, desktop its only bundled provider | `fc0611aec9aec32896c16a2634c7953ac30f418bec662fa3dc8cbbe95b0455dd` | `desktop` 1.0.0 / 1.0.0 `ACTIVE`, `BUNDLED`, `SELECTED` |
| `core-desktop-workspace-extension-host` | the signed `Koine.app` (`dev.antony.Koine`, Developer ID, Team `TA43A4RUP3`) in a clean clone of `testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64 | `a56a3387c7bef91758e31713fd9a7f632855c2b3a9eaaf5f8e5cce1b66d49aea` | `desktop` and `workspace`, each 1.0.0 / 1.0.0 `ACTIVE`, `BUNDLED`, `SELECTED` |

For every profile the served schema matched its design SDL with **no difference**,
the digest of the design file equalled the digest served, and the pin held. Each
check ran only after its controls had been seen red:

- **The design file.** A description removed, a nullability marker removed, an
  argument default introduced (each caught by the report and the digest) and two root
  fields transposed (caught by the digest alone, as declared order is what the
  introspected text cannot carry). For the workspace profile also: the launch root
  removed and a workspace description changed (report and digest), and the launch
  field moved before desktop's (digest alone: declared composition order is part of
  the contract).
- **The pin.** A different release, a required provider that is not served
  (`is missing`), and a served row the profile did not expect (`unexpected row
  desktop`); for the workspace profile also workspace left out of the pin
  (`unexpected row workspace`) and another workspace release pinned (`is not served
  as expected`).

`task conformance` therefore fails for a missing required provider or coordinate, as
the spec requires, and did so for each mutation above. The bundle under test was the
signed application, **not stapled**: the leaf's contract is the signed build, so the
run records the notarization state and requires it only under
`KOINE_CONFORMANCE_REQUIRE_NOTARIZED=1`.

**The released host needed a bundled root to serve desktop.** The released host's
headless driver takes a data directory alone, and the first capture showed the
released server rejecting the released desktop provider as reserved (`desktop is
reserved.`; the digest then was the core's alone). `scripts/compat-released-host-main.swift`
is that driver plus the bundled root the released application has, copied over the
driver in the extracted released tree. The released server code is untouched, and the
digest it then served is the one 0.1.0 shipped.

### In-package guards

`DesignContractConformanceTests` composes desktop's and workspace's own SDL with the
core through the engine and gets the workspace profile's design file, digest
included; and it holds that file to the complete workspace design, so that the only
differences are the three roots not yet implemented and the two types only they
reach (`workspaceCoordinatesNotYetImplemented`). Seen red against a reworded
description and against a dropped root. `ConformanceProfileTests` pins the new
profile: both candidates hold it, either missing fails it, and a different release,
schema, state, origin or selection of workspace is named with what is served instead.

## 2. A client written from the documented contract alone drives the launch

`clients/contract-only` was regenerated from the introspection response the signed
build served for the third profile (`capture/introspection.json`, 48 265 bytes,
digest above), and extended by a session that had only the published documents
(`launch` and the classifications it needs: `clients/contract-only/README.md`). That
session's restriction was an instruction, not a property of what it could reach, as
the earlier client's was ([contract-only-client.md](contract-only-client.md)); the
transcript of its tool calls was searched afterwards for any read of `Sources/`,
`Providers/`, `Tests/`, `Tools/`, `Fixtures/`, `scripts/`, `.grove/`, the conformance
and VM evidence or the profiles, and there was none (11 reads, all of documents and
of `clients/contract-only`). The client reads `workspace-operations.graphql` by
operation name: the file lists three operations this build does not serve, and a
used operation that does not validate against the captured schema stops generation
(watched).

The run is `task app:vm-verify-launch-contract-client`
(`scripts/vm-verify-launch-contract-client.sh`), on the same signed build and VM as
above, transcript `.build/vm-verify/launch-contract-client-20260930T234355.log`.
Every observation of what the system did is an independent witness's
(`Fixtures/LaunchWitness`, which holds no Koine code), never the client's answer.

| Step | What the client is asked | Observed |
|---|---|---|
| Discovery and grants | `probe`; then `enrol` four times, each approved in Koine's window | `service-unavailable` before launch; the endpoint read from the descriptor alone; grants for both controls, `workspace:control` alone, `desktop:control` alone and `desktop:read` alone, each PENDING → APPROVED |
| Schema | `introspect` | `schemaDigestsEqual: true`: the digest served now is the one the client was generated against |
| **Dependency unavailable** | `launch` of `dev.koine.test.NotInstalled` under both controls | `dependency-unavailable`, `status: DEPENDENCY_UNAVAILABLE`, `APPLICATION_NOT_INSTALLED` with the guidance, no error; nothing launched, activated or moved |
| **Capability denial, complete set** | `launch` under `workspace:control` alone; under `desktop:control` alone | HTTP 403, `capability-denied`, `phase: authorization`; first unmet `desktop:control`, then `workspace:control`; in both the complete set `["workspace:control","desktop:control"]`; nothing launched, activated or moved |
| **`failed`** | `launch` of an installed application that cannot be opened (a bundle whose executable is 8 192 bytes of a Mach-O, registered with Launch Services) | `failed` at `["workspaceLaunchApplication"]`: "The application “BrokenLaunch” could not be launched because a miscellaneous error occurred.", `actionEffect: may-have-begun`; sent once and never replayed; nothing launched or moved |
| Cold launch, both controls, no read | `launch` of Notes (4.13, `/System/Applications/Notes.app`) while it is stopped, with TextEdit in front and Koine inactive | `ok`, `AVAILABLE`, a process; answered 120 ms after sending, the witness saw Notes activated 107 ms after it; one instance |
| Receipt against the kernel | the receipt's `{pid, startedAt}` | equals the witness's kernel reading exactly: `{"pid":1316,"startedAt":"2026-09-30T14:12:10.785974Z"}` |
| Handoff, consent absent | `choices` with the receipt's two values, unchanged, under `desktop:read` | `os-permission-denied` at `["desktopApplication","windows"]`: the process was accepted, only the window list was refused |
| Handoff, consent given | the same values | `ok`: Notes and its window |
| Reactivation while running | `launch` again, TextEdit in front | the same process; answered 36 ms after sending, activation 26 ms after it; still one instance and no application launched |
| **Absent process** | Notes quit; `choices` with the old identity | `absent`, ordinary null with no error |
| Stopped service | `probe` after Quit | `service-unavailable` |

The four outcomes the leaf names are told apart, each by its own classification and
fields: dependency unavailability (`dependency-unavailable`, no error), capability
denial (`capability-denied` with `requiredCapability` and the complete ordered
`requiredCapabilities`), `failed` (an error at the action's path, effects possibly
begun) and an absent process (`absent`). The client guesses nothing the documents
leave open without saying so: [launch-contract-client-findings.md](launch-contract-client-findings.md)
lists sixteen places it had to, each repaired in the documents or declined for
version 1 with a reason.

A launch under a grant holding both controls needed no read capability, and the
witness, not the client, established that nothing launched in the three refusals.

## Regression: what was repeated after the changes

This leaf changed shared material, so the runs that depend on it were repeated on the
same signed build, each to a pass:

- `task app:vm-verify-contract-client` (transcript `contract-client-20261001T002144.log`):
  the original five operations, Finder windows and focus, now driven by the
  regenerated client and the helper library extracted from the script.
- `task app:vm-verify-launch` (transcript `launch-20261001T002806.log`): the launch
  acceptance of [launch-vm.md](launch-vm.md), now sourcing the witness and
  first-run helpers extracted to `scripts/vm-verify-launch-lib.sh`.
- `task conformance` as one command, all three profiles (transcript
  `conformance-20261001T013239.log` for the signed application's profile): each
  `CONFORMANT`, each after its controls were red.
- `task test`: 285 + 52 + 21 + 8 tests in their suites, none failing.

While extracting the witness helpers a read in the Gatekeeper preparation
(`spctl -a -vv` of Notes) was found to end a run silently when the agent's false
"timed out" answer came back for it; it is now tolerated, and the lines after it
still assert its content.

## What this does not show

- Only **one** launcher, Notes; the other eleven are `application-launchers`.
- The client's stub tests transcribe the specs' tables and are not evidence of the
  wire; the wire facts above are the VM run's. The suppressed-branch and nested-denial
  shapes are stub and engine facts, not seen on the wire.
- Conformance proves the served schema and candidates; selected updates and explicit
  absent or rejected sets, and the rest of the selection matrix, stay with
  `selection-acceptance`.
- The signed build was not notarized for these runs; the notarized posture is
  [notarized-release-vm.md](notarized-release-vm.md)'s and is not re-established here.
