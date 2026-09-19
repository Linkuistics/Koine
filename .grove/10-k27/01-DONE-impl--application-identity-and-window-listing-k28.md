# application-identity-and-window-listing-k28

## Goal

Open the thinnest real desktop path and settle its largest unproven claim: the
bundled desktop provider resolves a running application from its process
identity and lists its current windows with references, and recorded evidence
establishes which native identity mechanism upholds "focus exactly this target
or report `unavailable`".

## Context

- Spec: the desktop signatures table and the `DesktopProcessIdentity` paragraph
  in "Public GraphQL contract"; "Resource references and desktop behavior".
- Design SDL: `docs/design/desktop-schema.graphql` for the exact types.
- The stage brief's notes on the bundle arrangement, on extending
  `KoineProviderAPI`, and on Accessibility consent in a VM.
- `Fixtures/FixtureProvider` and `scripts/vm-verify-providers.sh` as the models
  for an out-of-package bundle build and a signed-build VM verification.
- Modaliser's `WindowEnumerator.swift`, `WindowLibrary.swift` and
  `AccessibilityLibrary.swift`, to learn from, not copy.

## Done when

- A desktop provider bundle, built by its own build definition against the
  emitted `KoineProviderAPI` interface, is placed in `Contents/PlugIns` by
  `task app`, signed inside-out, named in the application's built-in approvals
  and reported `ACTIVE` by `koineManagement.providers` in the signed build. It
  registers the `desktop:read` and `desktop:control` capabilities.
- `desktopApplication(process:)` compares both `pid` and `startedAt`. An absent
  process, and a live PID whose start instant differs, return ordinary null. A
  start instant that is malformed or not in the canonical form is an input
  error, never a fallback to PID alone. State where the provider reads the
  start instant and at what precision, since a client must capture the same
  value.
- `DesktopApplication` serves `ref`, `name`, `bundleIdentifier` and `windows`;
  `DesktopWindow` serves `ref`, `title` and `observation` (always `CURRENT`
  here). Only real windows are listed, empty titles are kept, and no row is
  manufactured. References are canonical `koine://desktop/…` URIs encoding the
  process incarnation and, for a window, its native identity plus whatever
  discrimination information the mechanism needs.
- **The identity evidence**, in `docs/verification/`, from the signed build in
  a VM with real applications: for each candidate mechanism, whether it is
  public API, and whether an identity captured at listing time selects the same
  window again, and only that window, after another window with the same title
  exists, after windows are reordered, retitled, minimised or moved to another
  Space, after the window closes, and after the application restarts. Include
  at least one application with duplicate titles and one with untitled windows.
  The evidence names the chosen mechanism, what it cannot distinguish, and
  which of those cases must therefore become `unavailable`.
- A VM verification task in `Taskfile.yml` proves, over loopback GraphQL with a
  manually created grant, resolution of a real application, the mismatched
  `startedAt` null, distinct references for same-titled windows, and the
  missing-`desktop:read` error. Commands are in the README.

## Notes

**Stop and ask.** If no acceptable mechanism upholds the guarantee, or the only
one that does is a private API (Modaliser's window-number lookup is one), stop
and put that trade-off to the human with a recommendation and the evidence. Do
not weaken the contract, adopt a private API or lean on title matching
silently. Title fallback is allowed only where the provider can establish the
same target unambiguously, and the evidence must say when that is.

This is an implementation leaf that yields evidence, not a research stage: the
probe that gathers the evidence may be test material, but the listing it
informs ships. Re-resolving a reference through the public API belongs to
`reference-lookups-and-accessibility-permission`; here it is enough that the
evidence exercises the mechanism natively.

PID reuse cannot be forced on demand. A relaunched application with a different
`startedAt` is the observable case; say so rather than claiming more.

Without Accessibility consent this leaf may report `failed`; the agreed
`os-permission` classification is the next leaf's.

## Decisions (running log)

- **Input error is an additive provider outcome.** A provider-private scalar has
  no host-side coercion, so `ProviderFailure.Kind.invalidInput` was added to
  `KoineProviderAPI` (still pre-release 1.0; resilient enum, the host already had
  `@unknown default`). The host reports it with a path and no `extensions.kind`,
  as the spec's "GraphQL input coercion" row. The fixture's probe serves it.
- **Start instant.** Read with `proc_pidinfo(PROC_PIDTBSDINFO)`
  (`pbi_start_tvsec`/`pbi_start_tvusec`), whole microseconds, which is the
  contract's six digits exactly. The loader-level test captures it by `sysctl
  KERN_PROC_PID` instead and the two agree. `NSRunningApplication.launchDate` is
  a different instant. Only the exact canonical text is accepted.
- **A process that is no `NSRunningApplication`** (a daemon, another account's
  process) is ordinary null: it is no desktop application.
- **The loader now carries a root's origin into composition.** `desktop` is
  reserved to the in-application root, and nothing had yet marked a provider
  loaded from it as `.bundled`.
- **Serve only what is implemented:** `DesktopObservation` has `CURRENT` alone
  until `remembered-windows-across-spaces` makes `REMEMBERED` real.
- **Real windows:** role `AXWindow`, subrole standard, dialog or absent.
  Minimised windows are listed; they are real and focusable.
- **Consent route in the VM.** Writing the image's TCC database was refused by
  the session's permission policy and is not used. Consent is given through
  System Settings, driven by TestAnyware.
- The pure files (`Providers/DesktopProvider/Logic`) are also a package target,
  only so `swift test` reaches them; the bundle is built by `build.sh` alone.
- **Identity mechanism: the held accessibility element (public API).** Agreed
  with the private window id in every case in the VM, so the stop-and-ask
  condition is not met. ADR `desktop-window-identity-is-a-held-element`; evidence
  `docs/verification/desktop-window-identity.md`. Window references do not
  survive a restart of Koine, which the contract allows. Title fallback is never
  used.
- **The leaf's one in-session reviewer was spent on that mechanism**, as it is
  what every later leaf builds on. Classified: *valid and acted on* — a positional
  alias could be tabled if it answered `AXWindow` at capture (now: the element
  must be the one its first child names as its window; run 3 shows Finder's alias
  fails it and real windows pass), no check that a listed element belongs to the
  process asked, the wait bound applied to the application element alone (SDK
  header confirms), read errors became empty titles, pruning on a timeout.
  *Valid, stated as the assumption the guarantee rests on* — identity reuse
  within a process; bounded by a 60-window churn in run 3; retiring a token at
  destruction is `remembered-windows-across-spaces`'s. *Visible trade-offs,
  documented* — tabs inside one window, windows on other Spaces not listed until
  `REMEMBERED` exists, no durable identity slot. *No defect* — consent. The fixes
  are covered by the probe and the VM task, so no review leaf was cut.
- `desktop` is reserved to the in-application root, so the loader-level tests
  load the bundle as a bundled root with a built-in approval, as the app does.
- macOS lists Koine under Accessibility, switched off and with no dialog, once a
  read has asked `AXIsProcessTrusted`. Noted for
  `accessibility-status-and-consent-ui`.
- `scripts/vm-verify.sh`'s last port check repeated an empty guest answer: the
  exec flake had been read as "something still answers".
