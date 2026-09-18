# resident-management-k12 — brief

## Goal

The second working Koine: a person installs and runs the signed, resident Koine
application, creates a grant in its native UI, hands the credential to a script,
and later lists and revokes grants. The same management is available over
GraphQL to a `koine:manage` grant, and revocation is live. Planned by
`resident-app-manual-grants-k7`.

## Done when

- **Management over GraphQL** (public GraphQL seam): `koineManagement.grants`,
  `koineCreateGrant` over HTTP, idempotent durable `koineRevokeGrant`.
  Revocation and action admission share one serialized authority boundary; a
  revoked credential gets 401 on an existing keep-alive connection and after
  restart. Revocation commits durably before success is reported; a store or
  commit failure never reports success; a corrupt or unreadable store fails
  closed and is never replaced by a privileged default. Read fields enforce
  `koine:manage` with the agreed permission error shape and propagation.
- **Resident application**: one per-user process containing the UI and the
  embedded server. Closing the management window leaves the listener running;
  explicit Quit stops it and removes the descriptor. Login launch through
  `SMAppService.mainApp`, enabled by the user during setup. The UI acts through
  the in-process console principal over the same GraphQL management path:
  create a grant (label, capability set, credential shown once), list, revoke.
- **VM verification** (TestAnyware seam): signed installation, login launch
  without any client, the manual grant workflow and revocation driven through
  the real UI, management window closed with the service still answering.
- Lost manual-secret delivery is handled by revoke-and-recreate; no UI or query
  ever re-reads a credential.
- Every new build, sign and verification command is in `Taskfile.yml` and the
  README.

## Decomposition

Ordered by dependency, then by risk. Each leaf is verifiable on its own.

1. `resident-app-skeleton` — the walking skeleton of the application: app
   target, scripted signed bundle, embedded server, window-close and Quit
   lifecycle, create-grant UI with the credential shown once. Depends only on
   k4, and carries the bundling and signing unknowns, so it goes first. It makes
   the UI-framework choice.
2. `grant-listing-and-revocation` — `koineManagement.grants` and
   `koineRevokeGrant` with live revocation, over the public GraphQL seam.
3. `revocation-ordering-and-store-failure` — hardens the path leaf 2 opened:
   the serialized authority boundary under controlled ordering, and the store
   failure cases.
4. `grant-management-ui-and-login-launch` — list and revoke in the UI, and the
   `SMAppService.mainApp` setup affordance. Needs leaves 1 and 2.
5. `resident-app-vm-verification` — the TestAnyware seam over the signed build.
   Needs everything before it.

## Pointers

- Spec sections: "Application composition and availability", "Grants and
  management" (store durability, "User-created grant", "Management authority
  and surface"), "Mutation preflight and revocation", and the management and VM
  rows of "Test seams and acceptance".
- ADR: `docs/adr/bearer-grants-and-live-revocation.md`.
- Design SDL for the target field shapes: `docs/design/desktop-schema.graphql`.
- Seams: public GraphQL for all management behaviour; TestAnyware VMs only for
  the real installed workflow.

## Notes

**Decided by the human in `resident-app-manual-grants-k7`:**

- *Signing identity.* Every bundle is signed with `Developer ID Application:
  Antony Blakey (TA43A4RUP3)`, hardened runtime on, the identity overridable by
  an environment variable. One designated requirement from development through
  release keeps TCC and login-item state stable across rebuilds, gives VMs a
  signature they accept without installing a certificate, and supplies the Team
  ID the later library-validation work needs. No ad-hoc fallback that silently
  changes the designated requirement: a missing identity is an error with an
  actionable message. Notarization is a `release-acceptance-handoff-k11`
  concern, not this stage's.
- *Application build tooling.* A scripted bundle around the Swift package, not
  an Xcode project. `Package.swift` stays the only build definition: an
  executable target for the application, and a script run from the Taskfile
  that assembles `Koine.app` (Info.plist, entitlements, room for `Frameworks/`)
  and signs inside-out. `../Modaliser/scripts/build-app.sh` is the local
  precedent. Accepted trade-off: bundle layout, rpaths and signing order are
  ours to get right, and `native-provider-contribution-k8`'s library-evolution
  framework will probably need `xcodebuild` on the package scheme or explicit
  flags rather than plain `swift build`.

**Keep the UI a thin client of the management operations.** The UI executes
GraphQL through `KoineServer.console`; it does not reach the store or the engine
directly. Behaviour tests live at the GraphQL seam; the VM seam only proves the
real workflow. The create-grant UI takes its capability choices from
`Query.koine.availableCapabilities`, never a hard-coded list — it lists only
core capabilities until a provider is active.

**What k4 left to build on.** `KoineServer(dataDirectory:policy:)` is one run
per object and holds the instance lock from `init` to `stop()`; Quit must
`stop()` it. `Principal.localConsole` already carries `koine:manage` through
`Authority`. `GrantStore` has `insert`, `grants()` and `grant(id:)` and no
revoke; `GrantRecord.state` and `KoineGrantState` already exist.
`koineCreateGrant` is already served. Platform services (AppKit/SwiftUI,
ServiceManagement) stay out of `KoineCore`; keep introspection inside
`RequestPolicy` when adding schema.

**Serve only what is implemented** continues to bind: `KoineManagement` gains
`grants` here and nothing else; requests, provider status and OS-permission
status arrive with the stages that make them real.
