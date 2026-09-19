# desktop-provider-k27 — brief

## Goal

The fourth working Koine, the one that unblocks ModalAnyware: through the real
desktop provider and the loopback GraphQL boundary, a client with
`desktop:read` and `desktop:control` resolves a running application from its
process identity, lists its windows and focuses exactly the one it chose.
Planned by `desktop-path-k9`.

## Done when

Every item is verified in TestAnyware VMs against the signed `Koine.app` with
real applications; there are no application mocks.

- **Identity.** An application resolves by `pid` + `startedAt`, both compared;
  a recycled PID never selects a new application; a missing reliable start
  instant is an input error. Application and window references encode the
  process incarnation, and a window reference its native window identity. The
  native identity mechanism that upholds "focus exactly this target or report
  `unavailable`" is established with recorded evidence.
- **Lookups and permission.** `desktopApplication`,
  `desktopApplicationByReference` and `desktopWindow` agree; an absent process
  is ordinary null; stale, wrong-kind and malformed-remainder references are
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
- **Native UI status.** Accessibility guidance and the consent request come
  from Koine's own UI, with provider status and service status, and
  `koineManagement.osPermissions` is served over GraphQL.
- The desktop provider is a real plugin bundle sealed in `Contents/PlugIns`,
  loaded by the one native loader under its built-in approval, and written
  against `KoineProviderAPI` alone.
- Every new build, sign and verification command is in `Taskfile.yml` and the
  README; each leaf's VM evidence is under `docs/verification/`.

## Decomposition

Ordered by risk, then dependency. Each leaf leaves `task`, `task app` and the
existing suites and VM verifications green, and is verifiable on its own.

1. `application-identity-and-window-listing` — the thinnest real desktop path:
   the bundled provider, `desktopApplication` by process identity, current
   windows with references, and the evidence for the native window-identity
   mechanism. It is the largest unproven claim in the approved contract and
   every later leaf builds on its reference encoding, so it goes first. It
   carries the stop-and-ask rule.
2. `reference-lookups-and-accessibility-permission` — the two by-reference
   lookups, the whole `unavailable` vocabulary for references, and the
   OS-permission classification for reads. Constrains the path leaf 1 opened.
3. `focus-exact-window` — the mutation, on the identity mechanism leaf 1
   proved and the re-resolution leaf 2 completed. With it ModalAnyware's path
   works end to end under a manually created grant.
4. `remembered-windows-across-spaces` — provider-private observation from
   `start()`, `REMEMBERED` rows and their removal. Needs leaf 3 so that
   selecting a remembered window can be shown to revalidate.
5. `accessibility-status-and-consent-ui` — Koine's own consent request and
   guidance, provider and service status in the window, and
   `koineManagement.osPermissions`. Independent of leaves 2–4; last because
   the path is usable without it (consent can be given in System Settings) and
   nothing else depends on it.

## Pointers

- Spec sections: the desktop signatures table in "Public GraphQL contract",
  "Resource references and desktop behavior", the OS-permission paragraphs of
  "Application composition and availability", "Errors and partial data", and
  the VM row of "Test seams and acceptance".
- Design SDL and operations: `docs/design/desktop-schema.graphql`,
  `docs/design/desktop-operations.graphql`.
- ADRs: `docs/adr/machine-references-as-uris.md`,
  `docs/adr/koine-server-and-native-providers.md`,
  `docs/adr/resilient-provider-framework.md`,
  `docs/adr/desktop-window-identity-is-a-held-element.md`.
- Glossary terms in play: provider, provider framework, resource reference,
  snapshot, capability.
- Existing behaviour to learn from, not copy, in
  `../Modaliser/Sources/Modaliser/`: `WindowEnumerator.swift`,
  `WindowCache.swift`, `WindowManipulator.swift`, `WindowLibrary.swift`,
  `AppScanner.swift`, `AccessibilityLibrary.swift`.
- Seam: TestAnyware VMs over the signed build, extending
  `scripts/vm-verify-lib.sh` as `scripts/vm-verify-providers.sh` does. The
  fixture provider's build (`Fixtures/FixtureProvider`) is the model for a
  bundle built against the framework's emitted interface.

## Notes

**The desktop provider is a shipped plugin bundle, not a host target.** The
human's one-loader decision in `native-provider-contribution-k8` binds: it has
its own build definition against the emitted `KoineProviderAPI` interface, is
placed in `Contents/PlugIns` and signed before the application, and the
application's built-in approval list names it. `AppDelegate`'s bundled provider
identifiers are empty today and `scripts/build-app.sh` ships the root empty.
`KoineCore` keeps no macOS or desktop dependency.

**If the provider contract cannot express something the desktop schema needs**
— an input object, the `DesktopProcessStart` scalar, an enum, an input-error
outcome — extend `KoineProviderAPI` additively under its evolution rules and
keep `task compat` green. Nothing is released before
`release-acceptance-handoff-k11`, but the rules apply from the first
declaration. A limit that cannot be met additively is raised with the human.

**Accessibility consent in a VM** is each leaf's own setup until leaf 5 exists,
and remains System Settings' to record afterwards: the first leaf finds the
route (driving System Settings through TestAnyware, or the image's TCC
database) and records it in its verification document for the others to reuse.
The signed identity is stable, so consent survives rebuilds.

**Serve only what is implemented** continues to bind: each leaf adds to the
provider's SDL only the fields it makes real. The composed schema is checked
against the design SDL by `release-acceptance-handoff-k11`, which also owns the
latency report and the supported matrix.

Provider OS observation is private state; the engine still caches nothing.
Native waits are bounded and cancellation is cooperative. The host rule binds:
anything that launches Koine, drives a UI or needs Accessibility runs in a
TestAnyware VM, never on the host.

`application-identity-and-window-listing-k28` is complete. What the later leaves
build on: the identity mechanism and its limits, with a section addressed to the
leaves that re-resolve and focus, in `docs/verification/desktop-window-identity.md`;
the consent route through System Settings, scripted as `grant_accessibility` in
`scripts/vm-verify-desktop.sh` and described in
`docs/verification/desktop-application-and-windows-vm.md`;
`scripts/vm-verify-desktop-client.py` as the guest client that captures a process
identity; `Fixtures/WindowIdentityProbe` for native evidence; typed attribute
reads (`read(_:_:as:)`) that never turn an error into data; and
`ProviderFailure.Kind.invalidInput` for input errors. `DesktopObservation` serves
`CURRENT` alone until leaf 4 makes `REMEMBERED` real. That leaf, which observes
destruction, is also where a token can be retired the moment its window ends.

`reference-lookups-and-accessibility-permission-k29` is complete. What the later
leaves build on: every route to an application or a window ends in one read
(`running` and `row` in `DesktopProvider.swift`), and a window lookup decides
what needs no Accessibility call before the trust check, then asks the held
element again; `focus-exact-window` re-resolves the same way before it acts. In
`scripts/vm-verify-desktop.sh`: `revoke_accessibility` (Koine's switch and the
password; only Koine's next read proves it, the switch reads off early),
`no_consent_dialog` (the dialog's text read from the screen; the process that
shows it is no detector) and `Fixtures/ConsentPromptControl` as its positive
control. `tccutil reset` does not revoke a running Koine in effect. `guest` now
retries TestAnyware's exit 7 as well; a run is about sixty guest execs and
twenty-five minutes. Evidence:
`docs/verification/desktop-references-and-permission-vm.md`.

`focus-exact-window-k30` is complete. What the later leaves build on:
`held(referencedBy:)` in `DesktopProvider.swift` is the one re-resolution, for
reads and for focus, and focus confirms identity and acts in one turn on the
provider's queue, then waits off it until the application reports the held element
focused. AppKit activation answers no to a background service, so the application
is brought forward by setting `AXFrontmost`; a window on another Space focuses
through its held element and macOS switches Spaces, which is what selecting a
`REMEMBERED` row will rely on. For VM work: `scripts/vm-verify-desktop-lib.sh`
holds the shared desktop helpers and `guest_json`, which survives the agent's
bursts of false timeouts for any command answering one JSON line;
`WindowIdentityProbe focused` and `windows <pid>` are the native witness (its
system-wide query does not work in the VM); read a state before acting on it, or
the step cannot fail. `Harness.makeServer` constructs on a serial queue: parallel
signature checks starve the global dispatch pool and hang `swift test`. Evidence:
`docs/verification/desktop-focus-vm.md`.

`remembered-windows-across-spaces-k31` is complete. What the last leaf builds on:
`REMEMBERED` is a view over the window table (`Logic/HeldWindows.swift`, host
tested), not a second cache, and `Sources/WindowObservation.swift` is the
provider's observation from `start()` to `stop()`, delivered on the main run loop
and handed to the provider's queue; it only ever removes. Koine holds only what a
client's listing saw. For VM work: choosing, focusing and the native witness are
in `scripts/vm-verify-desktop-lib.sh`; `WindowIdentityProbe observe` witnesses
destruction notices; a guest background job must be fully detached or its exec
waits for it; ⌃⌘F toggles, so know the Space first, and `open -F` keeps a killed
application from restoring a full-screen one; Koine's window cannot be closed by
the agent from another Space. Evidence:
`docs/verification/desktop-remembered-windows-vm.md`.

`accessibility-status-and-consent-ui-k32` is complete, and with it this node.
The host supplies the OS permission read (`KoineServer.init(osPermissions:)`);
the window's status is one operation, `ManagementClient.status()`, polled; only
the window's request control asks macOS for consent. Evidence:
`docs/verification/accessibility-status-and-consent-vm.md`.

Until `grant-enrollment-k10` lands, clients obtain grants through the manual
workflow. That is sufficient for ModalAnyware to begin work against this path.
