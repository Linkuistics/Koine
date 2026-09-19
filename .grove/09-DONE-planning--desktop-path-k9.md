# desktop-path-k9

## Goal

Plan the fourth working increment, the one that unblocks ModalAnyware: through
the real desktop provider and the loopback GraphQL boundary, a client with
`desktop:read` and `desktop:control` resolves a running application from its
process identity, lists its windows and focuses exactly the one it chose.

## Context

Spec sections: the desktop signatures table in "Public GraphQL contract",
"Resource references and desktop behavior", the OS-permission paragraphs of
"Application composition and availability", and the VM row of "Test seams and
acceptance". Existing behaviour to learn from, not copy, in
`../Modaliser/Sources/Modaliser/`: `WindowEnumerator.swift`, `WindowCache.swift`,
`WindowManipulator.swift`, `WindowLibrary.swift`, `AppScanner.swift`,
`AccessibilityLibrary.swift`. Read what `native-provider-contribution-k8`
built; the desktop provider is written against that contract alone.

## Done when

The tree holds narrow impl leaves, each verified in TestAnyware VMs against the
signed application with real applications (no application mocks), delivering:

- **Identity evidence first.** The first leaf resolves an application by
  `pid` + `startedAt` (both compared; a recycled PID never selects a new
  application; a missing reliable start instant is an input error) and lists
  its current windows with references that encode process incarnation and
  native window identity. It must establish, with evidence, which native
  identity mechanism upholds "focus exactly this target or report
  `unavailable`". Modaliser's private window-number lookup and title fallback
  are not proof. **If no acceptable mechanism upholds the guarantee — or the
  only one is a private API — stop and put that trade-off to the human; do not
  weaken the contract or adopt a private API silently.**
- **Lookups and permission.** `desktopApplication`,
  `desktopApplicationByReference` and `desktopWindow` agree; an absent process
  is ordinary null; stale, wrong-kind or malformed-remainder references are
  `unavailable`. Without Accessibility consent the result is `permission` /
  `os-permission` naming `accessibility` and Koine, distinct from a missing
  `desktop:read`; a GraphQL read never triggers the consent dialog.
- **Focus.** `desktopFocusWindow` re-resolves, checks consent and identity
  before acting, reports OS failures, returns the control-only receipt, and
  yields `unavailable` after closure, PID reuse, restart or ambiguity. Two
  windows with the same title are never confused.
- **Remembered windows.** Windows seen on other Spaces appear as `REMEMBERED`;
  current enumeration refreshes; observed destruction and termination remove
  them; selection always revalidates. Observation survives the management
  window closing.
- **Native UI status.** Accessibility guidance and consent request from Koine's
  own UI, provider status and service status, plus
  `koineManagement.osPermissions` over GraphQL.

## Notes

Follow `desktop-delivery-k3`'s cutting shape (see `resident-app-manual-grants-k7`).

The identity leaf is deliberately first: it is the largest unproven claim in
the approved contract, and everything after it builds on its reference
encoding. It is an implementation leaf that yields evidence, not a separate
research stage.

Provider OS observation is private state; the engine still caches nothing.
Native waits are bounded and cancellation is cooperative.

Until `grant-enrollment-k10` lands, clients obtain grants through the manual
workflow. That is sufficient for ModalAnyware to begin work against this path.

## Decisions (running log)

**One stage, not several.** Resolve-and-list is useful on its own, but the root
decomposition already fixed this as one increment and one working tree holds
one `.grove/`; the read-only slice is the stage's first leaf instead.

**Cut as stage `desktop-provider-k27`, five impl leaves, risk first.** Identity
and listing, then lookups and the OS-permission classification (the
open-then-constrain pairing of earlier stages), then focus, remembered windows,
and the consent and status UI. Each leaf carries its own signed-build VM
verification, as this leaf's `Done when` requires, so there is no closing VM
leaf. The UI leaf is last because consent can be given in System Settings and
nothing depends on it; ModalAnyware's path works after leaf 3.

**`koineManagement.osPermissions` stays with the UI leaf**, not the permission
leaf: both need the host-supplied permission source, and the core stays free of
macOS.

**No question for the human arose.** The bundle arrangement, signing and
approval were decided in `native-provider-contribution-k8`. The one product
trade-off in sight, a private API for window identity, is a stop-and-ask rule
in the first leaf, where the evidence will exist. No research, prototype or
review leaf is added. Latency and the supported matrix stay with
`release-acceptance-handoff-k11`.
