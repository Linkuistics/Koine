# signed-app-provider-vm-verification-k25

## Goal

Verify on the signed `Koine.app`, in a clean TestAnyware VM, that the hardened
runtime with no entitlement exceptions loads an approved same-team provider and
that a differently signed one never loads.

## Context

- Spec: "Loading and trust" and the closing paragraphs of "Test seams and
  acceptance" (verify the signed build, do not extrapolate).
- `docs/verification/resident-app-vm.md` for the scripted run, its evidence
  format and the TestAnyware workarounds. `scripts/vm-verify.sh` is what this
  extends.
- The host rule binds: nothing here launches Koine on the host.

## Done when

- `task app:vm-verify` (or a sibling task) installs the signed application and
  a fixture provider signed with Koine's identity in the per-user root with its
  approval record. After launch, a client with the fixture's read capability
  queries the fixture field over loopback GraphQL, and
  `koineManagement.providers` reports it `ACTIVE`.
- With an ad-hoc signed fixture installed instead, the provider is `REJECTED`
  with a diagnostic, its fields are absent from introspection, and management
  still works.
- With an approved same-team fixture whose manifest demands an unavailable
  framework minor, the provider is `INCOMPATIBLE`.
- The run records the bundle's entitlements (empty), the framework's location
  and signature inside the bundle, and that the plugin resolved the host's
  framework image rather than a copy.
- `docs/verification/` holds the evidence and what remains for
  `release-acceptance-handoff-k11`.

## Notes

The fixture is installed by the verification script as test material; it is not
part of the shipped bundle. Keep this proportionate: behaviour is proven at the
other two seams, and this leaf proves only what a signed, hardened process
changes.

## Decisions (running log)

- A sibling task, `app:vm-verify-providers` (`scripts/vm-verify-providers.sh`),
  not an extension of `app:vm-verify`: the resident run includes a VM restart and
  the provider cases need three Koine launches; one script would make every run
  pay for both. The shared VM helpers moved to `scripts/vm-verify-lib.sh`.
- The three bundles are the existing `fixture`, `adhoc-signed` and
  `unavailable-minor` test material; nothing new is built for the VM.
- One UI-created grant (`koine:manage` + `fixture:read`) serves all three cases.
  The capability toggles gained accessibility identifiers
  (`capability-<name>`) so the script finds them semantically.
- "Resolved the host's framework image" is evidenced by `lsof` in the VM (a
  hardened process refuses `vmmap`) plus the fixture's link and run paths on the
  host; `otool` does not exist in the golden.
- A first attempt failed in its last case on six consecutive TestAnyware
  `file exec` false timeouts; the unchanged re-run passed. Recorded in the
  evidence document as tooling, not Koine.
