# resident-app-manual-grants-k7

## Goal

Plan the second working increment: a person installs and runs the signed,
resident Koine application, creates a grant in its native UI, hands the
credential to a script, and later lists and revokes grants. The same management
is available over GraphQL to a `koine:manage` grant, and revocation is live.
Cut this stage into narrow impl leaves once `authenticated-endpoint-k4` exists.

## Context

Read what k4 actually built (its commits name the handles) before cutting:
library, store and tooling choices made there shape these leaves. Spec
sections: "Application composition and availability", "Grants and management"
(store durability, "User-created grant", "Management authority and surface"),
"Mutation preflight and revocation", and the management and VM rows of "Test
seams and acceptance".

## Done when

The tree holds narrow impl leaves, each verified through an agreed seam, that
together deliver:

- **Management over GraphQL** (public GraphQL seam): `koineManagement.grants`,
  `koineCreateGrant` over HTTP, idempotent durable `koineRevokeGrant`.
  Revocation and action admission share one serialized authority boundary;
  a revoked credential gets 401 on an existing keep-alive connection and after
  restart. Revocation commits durably before success is reported; a store or
  commit failure never reports success; a corrupt or unreadable store fails
  closed and is never replaced by a privileged default. Read fields enforce
  `koine:manage` with the agreed permission error shape and propagation.
- **Resident application**: one per-user process containing the UI and the
  embedded server. Closing the management window leaves the listener running;
  explicit Quit stops it and removes the descriptor. Login launch through
  `SMAppService.mainApp`, enabled by the user during setup. The UI acts through
  the in-process console principal over the same GraphQL management path:
  create a grant (label, capability set, credential shown once), list grants,
  revoke.
- **VM verification** (TestAnyware seam): signed installation, login launch
  without any client, the manual grant workflow and revocation driven through
  the real UI, management window closed with the service still answering.
- Lost manual-secret delivery is handled by revoke-and-recreate; no UI or
  query ever re-reads a credential.

## Notes

Follow the shape `desktop-delivery-k3` used: `leaf-insert` a stage leaf ahead
of the next stage, `leaf-decompose` it so its body becomes the stage brief,
`leaf-add` the remaining children, then retire this planning leaf.

**Unresolved inputs to settle first, each a question for the human with a
recommendation:**

- *Signing identity.* Accessibility attribution, login items and the later
  library-validation entitlement all depend on a stable code signature.
  Ad-hoc signatures change per build. Which Developer ID (or other stable
  identity) is available for development and VM testing? Nothing in the
  repository answers this.
- *Application build tooling.* An app bundle with entitlements and an embedded
  framework needs more than a bare Swift package. Choose between an Xcode
  project and a scripted bundle around the package, from primary sources.

The UI-framework choice is an implementation decision; keep the UI a thin
client of the management operations so the GraphQL seam carries the behaviour
tests and the VM seam only proves the real workflow.

`availableCapabilities` lists only core capabilities until a provider is
active; the create-grant UI must take its choices from the server, not a
hard-coded list.
