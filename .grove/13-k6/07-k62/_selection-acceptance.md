# selection-acceptance-k62 — brief

## Goal

Close every row of Machine's selection-acceptance table at its assigned N, G and
V seams before workspace ships. Later bundled providers then rest on an accepted
selection contract rather than on the launch path's principal cases alone.

## Done when

- Every row has evidence at each assigned seam, linked from Machine's
  "Selection acceptance" table. The one exception is a V case needing a second
  Developer ID team's certificate. Such a case is recorded pending with that
  prerequisite and owned by the late root leaf `alternate-team-signing`.
- Conformance adds selected-update profiles and explicit absent/rejected
  profiles, each pinning exact candidate versions.
- Each native scenario, and each alternative order within it, runs in a fresh
  signed host subprocess with a fresh initializer/factory/start marker log.
- Every refused-marker assertion is paired with a successful-marker control.
- Purpose-built test hosts are built with their catalogue before signing.
- Fixture signing identifiers differ from production and are admitted only by
  test catalogues.
- No notarized seal is altered to simulate a defect.

## Decomposition

1. `selection-decisions` (N, G): the pre-load decision rows. Builds the
   signed-host harness.
2. `selection-failures` (N, G): the post-freeze failure boundary, collisions,
   cascade and digest rows.
3. `selection-updates` (N, G): independent old/new binaries, trust refusals,
   staging and mixed releases.
4. `selection-vm` (V): every V-assigned row in signed isolated VMs.

Row owners, in Machine's table order:

| Machine row | N/G owner | V owner |
| --- | --- | --- |
| Old host + old desktop; new host + old baseline | `selection-updates` | `selection-vm` |
| Compatible newer desktop/workspace update | `selection-updates` | `selection-vm` |
| Pre-extension host + new update, normal and renamed principal | `selection-updates` | `selection-vm` |
| Approval/Team ID/seal/location/compatibility/quarantine refusals | `selection-updates` | `selection-vm`; second team: `alternate-team-signing` |
| Same-team fixture under another signing identifier | `selection-updates` | `selection-vm` |
| 1.9.0 vs 1.10.0; malformed; equal/older; schema | `selection-decisions` | — |
| Ties, successive groups, lower duplicates, alias | `selection-decisions` | — |
| Reserved identity/prefix/SDL claimant | `selection-decisions` | — |
| Missing/refused/mismatched designated bundle; unexpected in-app claimant | `selection-decisions` | — |
| Equal bytes in both roots; quarantine; legacy staging | `selection-updates` | `selection-vm` |
| Frozen update fails later | `selection-failures` | — |
| Shipped/ordinary/host-class principal conflicts | `selection-failures` | — |
| Ordinary duplicates with untrusted rivals | `selection-failures` | — |
| Desktop rejected; dependent cascade | `selection-failures` | — |
| Desktop start failure | `selection-failures` | — |
| Same/changed SDL across roots; extra provider | `selection-failures` | — |
| Mixed releases and reused helper source | `selection-updates` | `selection-vm` |
| Restart, removal, verdict change, unreadable root | `selection-failures` | — |
| Malformed catalogue; no-team host; alternate-team host | `selection-decisions` | `alternate-team-signing` |
| Diagnostic completeness | `selection-decisions` | — |

## Notes

The selection code landed in `launch-path`. A defect found here is fixed where
it serves the finding leaf's acceptance goal. Anything larger is cut as new work
ahead of the next leaf. Record native observations without claiming the loader
is a sandbox.
