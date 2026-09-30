# workspace-launch-k59

## Goal

Ship the workspace provider as the second bundled provider, serving
`workspaceLaunchApplication` complete to its design. It is verified at L, G and
N: packaged, signed, enabled in the catalogue, loaded by the selection-aware
loader, and served under `workspace:control` AND `desktop:control`.

## Context

- `docs/specs/workspace-launch-and-open.md`: Operations, Results and failure
  boundary, native design, Packaging and compatibility, and the acceptance rows
  named below.
- `docs/design/workspace-schema.graphql` and `workspace-operations.graphql`.
- The desktop provider's own build definition and logic-test target, as the
  pattern for a provider built outside the root package.
- The protected-path answer recorded by `protected-path-metadata-k73`, for the
  inspection selection performs.

## Done when

- The workspace bundle has its own build definition, its own Swift module and
  principal class, and links only the host framework.
- Its manifest and descriptor declare `additional-capabilities-v1` and the
  implementing framework minor. Release and schema are `1.0.0`/`1.0.0`.
- The signing identifier `dev.antony.Koine.provider.workspace` is confirmed from
  the signed bundle.
- The application packages, signs and enables the bundle in the catalogue, and
  the catalogue check covers it.
- The served contribution is the launch root and every type it reaches,
  verbatim from the design file.
- Every root, result and nested receipt field requires workspace control with an
  additional desktop control. Neither read capability is required.
- Selection follows the spec:
  - the input is a bundle identifier with an optional registered installation
    path;
  - installations are compared by native file identity after symlink resolution;
  - presence is checked despite stale registration, and a present copy in the
    Trash stays eligible;
  - a constrained bundle with another identifier is `APPLICATION_IDENTITY_MISMATCH`;
  - a constrained copy is never substituted, and an unconstrained launch reuses a
    running copy.
- Selection inspects only through the calls `protected-path-metadata-k73`
  recorded as prompt-free. A call it recorded as prompting follows Antony's
  answer to that stated limit, and the complete input is kept either way.
- Unreadable metadata is `failed`; absence is `APPLICATION_NOT_INSTALLED`.
- Launch uses no new instance, supplied arguments, environment or Apple events,
  and prompting stays disabled.
- The native acknowledgment is one-shot with a three-second bound. Earlier
  cancellation also ends it, and late callbacks are ignored. Outstanding
  submissions are bounded, and exhausted capacity refuses before submission.
- The receipt's process identity follows the observation rule only; there is no
  PID-only or foreground fallback.
- L: provider-local tests substitute the private native adapter. They cover:
  - absence, identity mismatch and inspection failure;
  - false, late and missing callbacks, and cancellation;
  - capacity exhaustion;
  - every observation-rule mismatch.
- G: composition-point tests cover:
  - error-free exclusive branches;
  - publication denial at the status, value and process fields, with correct
    partial data and error paths;
  - either control alone, and both controls without reads;
  - denial before inspection;
  - the first unmet member plus the complete set;
  - multi-action preflight and revocation between actions;
  - an action's `failed` versus an earlier core deadline in a multi-action request.
- N: the real signed bundle loads from the in-application root beside desktop,
  through the selection-aware loader. No real launch action runs on the host.
- The Named launchers trace row, and the rows' L/G/N parts, record exactly what
  was established. Twelve launchers, Multiple copies and installation, Receipt,
  Bounded acknowledgment and Authority each stay pending for their remaining seams.

## Notes

The kernel start-instant helper may be shared with desktop only as source
compiled into workspace's own module, never as a shared provider image. Serve the
design descriptions verbatim. The native grant-view disclosure belongs to
`workspace-disclosure`. The conformance profile belongs to `launch-contract`.
The bundled baseline need not declare `first-party-selection-v1`; its per-user
updates must.

## Decisions (running log)

**The provider's logic is a package target, its native edge is not.** `Providers/WorkspaceProvider/Logic/` builds both into the bundle (`build.sh` compiles `Logic/*.swift Sources/*.swift`) and as the package target `WorkspaceProviderLogic`, so L tests run the real `WorkspaceProvider` over a substituted `WorkspaceNative`. `Sources/` holds only the real adapter (`NativeWorkspace`) and the `@objc` principal class. Unlike desktop's Logic, this target depends on `KoineProviderAPI`, since the provider class is what L must instantiate.

**The kernel start-instant helper is shared as source by symlink.** `Logic/ProcessStart.swift` and `Logic/ProcessIdentity.swift` are symlinks to desktop's own files, so they compile into workspace's module and no image is shared, as the Notes require. A second copy would let the canonical form drift from the one `desktopApplication(process:)` accepts.

**One shared bundled root for the tests.** `task desktop-provider` became `task bundled-providers`, building both bundles into `BundledProviders` as `Contents/PlugIns` holds them. The shipped catalogue now enables workspace, so a root holding desktop alone would report a `missing-bundled` row and stop being the application's own shape. The compat scripts keep their `DesktopProviders`: that tree is built from the released sources.

**Unconstrained launch checks the registered bundle; constrained launch matches identity.** Registration is never presence. Unconstrained: `urlForApplication(withBundleIdentifier:)`, then inspect that bundle (gone or not an application is `APPLICATION_NOT_INSTALLED`; another identifier is `APPLICATION_IDENTITY_MISMATCH`). Constrained: inspect the path (identifier first, so a present bundle with another identifier is a mismatch even if unregistered), then require a registered copy whose file identity equals it, launching that registered copy's URL. A registered copy that cannot be read makes the choice unknown, so it is `failed` rather than skipped or guessed. A stale neighbour registration is skipped. A path that is not an application at all is not installed.

**Inspection uses only the calls `protected-path-metadata-k73` recorded as prompt-free.** `realpath`, `isApplicationKey` / `volumeIdentifierKey` / `fileResourceIdentifierKey` resource values, `Bundle(url:)`, and the registered-application lookups. No file-URL handler lookup is made anywhere, so Antony's open question about protected default opening does not bear on this root and no consent is added. The mismatch guidance does not name the installed identifier, since that is workspace read data.

**Bounds.** The acknowledgment wait is a `Duration` on the provider (default 3 s), so L tests use short real bounds and hold callbacks by hand. Outstanding submissions are bounded at 16, counted from before the call until its native callback, so a timed-out call still counts. A callback that never comes holds its slot until the provider is restarted: that is the stated limit of "count while outstanding" and the number is a judgement, not a measurement. A request cancelled before submission submits nothing.

**Framework API confirmed against the SDK, not memory.** `NSWorkspaceOpenConfiguration`'s defaults and meanings, `URLsForApplicationsWithBundleIdentifier` (macOS 12) and `NSRunningApplication`'s "use `isEqual:`, not the PID" were read in the macOS 26 SDK headers. The four Apple documentation pages the spec cites could not be fetched as text here; they are cited at the call, and the headers are the source actually read.

**G tests select one branch per scenario.** Sibling fields of one object resolve concurrently, so a status published "before" a value is denied is not the contract's; the first draft of these tests failed roughly one run in three on exactly that. A child is always published after its parent, so each denial is asserted at a single branch, and the partial data and paths that follow are exact. Mutations watched to fail: dropping the additional requirement on the root (19 issues), on one nested field (1), and, for L, the executable comparison (2), the second start read (1), constrained identity (4), the substitution flag (2), the capacity bound (4) and releasing at timeout instead of at the callback (8).

**Every capability class exists for every provider.** `workspace:read` is published though no workspace field requires it. Neither read is asserted absent from the descriptor's requirements (`everyServedFieldRequiresTheSameSet`), which is where the contract states it.

**Scripts that assumed desktop alone.** `verify-app.sh` and `check-minimum-os.sh` now cover both bundled providers (the provider section was run against the built bundle; the rest of `verify-app.sh` needs the notarized ticket). `vm-verify-notarized.sh` now requires both bundles in `Contents/PlugIns`; it has not been rerun, so that is a V matter for `launch-vm`.

**Not done here, by design.** No real launch, open or reveal ran on this host; no VM run; the old-host core + desktop profile and the `task conformance` run against a notarized bundle are untouched, so the shipped application now fails the existing core + desktop profile until `launch-contract` adds core + desktop + workspace (the profile check treats an unlisted row as a failure). The complete selection matrix stays with `selection-acceptance`.
