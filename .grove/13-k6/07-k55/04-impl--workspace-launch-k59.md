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
