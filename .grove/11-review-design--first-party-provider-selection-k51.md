# first-party-provider-selection-k51

**Reviews:** first-party-provider-selection-k50


## Goal

Adversarially review the first-party selection contract before launch-and-open
implements it. Find violations of the reserved-identity, explicit-approval,
independent-update, compatibility and no-concealed-failure obligations; produce
findings, not loader changes.



## Context

- The producer commit identified by `first-party-provider-selection-k50`.
- `docs/specs/machine.md#first-party-provider-selection`, composition and trust;
  `docs/specs/workflow-providers.md`, compatibility and selection acceptance.
- `docs/adr/koine-server-and-native-providers.md` and
  `docs/adr/resilient-provider-framework.md`.
- The two selection views in `docs/design/architecture/`, including captions.
- The producer task's goal/done conditions are the contract; the proposed
  algorithm and alternatives are the artifact to challenge.

## Done when

- Check the full candidate decision table, including missing/rejected bundled
  owners, reserved-only slots, untrusted claims, schema/version floors, multiple
  candidates and equal highest releases. Challenge discovery-order independence
  and whether one claimant can evict another outside the intended trust boundary.
- Trace every refusal boundary before and after dlopen; distinguish frozen
  selection, publication, startup and dependency cascades. Challenge paths that
  could load both versions, conceal a failed update, change authority or leave
  diagnostics falsely describing the selected binary.
- Check old/new host and bundle compatibility, canonical ordering/digests,
  additive management fields and exact-provider conformance. Determine whether
  the stated acceptance cases can distinguish policy failures at the three seams.
- Review spec/ADR/diagram/brief consistency and the minimum coherent ADR set.
- If integration is warranted, place it immediately before the launch-and-open
  sibling node under the Grove integration-placement rule, so no consuming
  design or planning runs first. Its charter points to this review's handle.

## Notes

Implementation and acceptance are launch-and-open's work. This review does not
claim the extension is already served. Signing-posture and incompatible desktop
contract changes still require Antony's decision. An absent second real signing
team cannot be replaced with mock acceptance.
