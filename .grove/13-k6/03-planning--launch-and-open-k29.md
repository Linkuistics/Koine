# launch-and-open-k29

## Goal

Cut `launch-and-open`'s implementation from its settled design into vertical
leaves that each leave Koine working and verifiable through the three seams.

## Context

- `launch-and-open-k18`'s design, and `provider-architecture-k5`'s ADR and
  allocation.
- The node brief's `Done when` is the acceptance to cover.
- Consume `docs/specs/workspace-launch-and-open.md`, its SDL/examples and the
  design review chain before cutting implementation. The spec's acceptance
  matrix and Machine's entire selection-acceptance matrix are both mandatory.

## Done when

The node holds ordered `impl` leaves that cover the brief's `Done when`. The
first leaf delivers one real launch path end to end, from provider through
loader, schema and client to the VM. Later leaves widen it and add no dead
layer. Any review judgment is recorded.

## Notes

If the design adds a bundled provider, the first leaf carries the packaging,
approval and conformance changes together with the first working operation.
Neither half is a working increment alone.

That same first slice carries the framework minor and required feature
`additional-capabilities-v1`, the full preflight/dispatch requirement set, and
old/new native binary acceptance from `provider-architecture-k5`. Preserve the
baseline desktop conformance profile and add the exact workspace profile;
missing required providers must fail that profile rather than weaken it.

## Concrete design obligations

- Four operations: `workspaceLaunchApplication`, `workspaceOpenURL`,
  `workspaceOpenPath`, `workspaceRevealPath`. Results and every nested receipt
  field require workspace control plus desktop control. Typed dependency reasons
  are distinct from permission, input and ambiguous native failures. No automatic
  replay/fallback, executable/argv/environment API or read prerequisite for launch.
- Application input is bundle identifier plus optional registered installation
  path. Preserve duplicate-copy selection. Web URLs are HTTP(S) and explicitly
  addressed to the default browser; path input remains a literal local location.
- Independently establish native acknowledgment, no-new-instance/copy-substitution
  configuration, executable/script classification, optional kernel process
  identity and Finder reveal behavior. File/process races and application
  reactions remain limits. The design does not authorize consent/signing changes.
- Record actual installed versions/IDs for all twelve apps, default and alternate
  browsers, Zed config-directory opening, Finder selection and disposable file
  fixtures. A missing installation is live preparation work. App onboarding is
  not account-dependent workflow acceptance. No app-driving test runs on the host.
- Workspace's initial release/schema is 1.0.0/1.0.0 with signing identifier
  dev.antony.Koine.provider.workspace. Pin actual desktop baseline and both signed
  identifiers in the sealed catalogue; reserve four later slots only. In-app
  approval derives from the verified host; updates need per-user approval.
- Carry **every row** of `machine.md#selection-acceptance` with its assigned N/G/V
  seams into implementation coverage. This includes signed desktop/workspace
  updates, release-identifier refusal, normal and renamed-principal old-host
  feature refusal, numeric precedence, successive ties and visible lower fallback,
  candidate-specific staging/quarantine including legacy staging and restart,
  missing-bundle diagnostics even with an active update, reserved claims,
  frozen-choice late failure/no retry, principal collisions, missing-owner fixed
  point versus startup failure, mixed-release native-name inventory, verdict/root
  failures, malformed test catalogues and complete candidate diagnostics.
- Use a fresh host process and fresh initializer/factory/start markers per native
  scenario/order, with successful-marker controls. Build purpose-specific sealed
  catalogue hosts before signing; never alter a notarized seal to simulate a
  catalogue defect. Fixture release identifiers differ from production. Missing
  alternate-team certificates keep the assigned cases pending, not waived.
- Conformance pins candidate versions independently of SDL/digest and covers old
  core+desktop, extension core+desktop, extension desktop+workspace, selected
  updates, and explicit absent/rejected sets. Include additive management fields,
  canonical shipped ordering, complete capability-denial sets and missing-owner
  cascades. No fixture substitutes for required real loader/VM evidence.
- Grow Taskfile build, preparation, fixture and VM recipes from those slices.
  Existing design validation/render tasks are not runtime conformance.
