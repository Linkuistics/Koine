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
  path compared by native file identity. Unconstrained launch/named-app open
  allows running-copy reuse; a selected installation disables substitution.
  Check bundle presence despite stale registration; a registered present copy in
  Trash is eligible. Bundle-less programs have no named-selector route. Web URLs
  use the spec's ASCII RFC 3986 grammar and scheme-only default-handler lookup;
  path input remains a literal local location.
- Independently establish native acknowledgment, no-new-instance/conditional
  substitution, the exact metadata refusal policy, optional kernel-process
  matching rule and Finder acknowledgment. Default source/editor opening must
  work. Document execution and location-file redirects are handler reactions;
  Finder aliases are refused for opening. File/process races remain limits.
  The design does not authorize consent/signing changes.
- In the first launch slice, observe cold/warm activation with another app
  frontmost and Koine inactive. An acknowledgment without activation does not
  pass. A separate desktop read/focus is explicit client recovery with its own
  grants/consent, not an implicit workspace prerequisite. Escalate a measured
  controls-only activation failure before closing the case.
- Bound acknowledgment waits at three seconds or earlier cancellation, release
  the resolver once and ignore late callbacks; bound outstanding native work.
  Test action-path failed versus an earlier core request deadline, including
  several root actions. No replay. Pre-approve/onboard normal launcher fixtures,
  record callback latency for each, and separately hold Gatekeeper pending past
  the wait bound.
- Use the real workspace provider with a substituted private adapter for
  deterministic missing-handler/Finder, false acknowledgment, timing and process
  mismatch cases. Those L checks and G composition fakes do not replace N/V
  evidence. Receipts expose only optional process identity; test error-free
  exclusive branches and publication errors at/below the result.
- Before workspace ships, own grant disclosure in create/approve and
  existing-grant views and GraphQL descriptions: any registered installed app,
  document execution and redirects by handlers, and both control requirements.
- Put prompt-free metadata inspection of first-use protected paths ahead of
  path-opening implementation and app/file search's reliance on its result
  shape. A prompt is a pending case for escalation, not implicit consent setup.
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

## Decisions (running log)

Bootstrapped from an empty working change on `2af6d3b5` (k54). Read the root and
node briefs, the workspace spec, Machine's additional-capability and selection
sections including the whole selection-acceptance table, both ADRs, the glossary,
k18/k54, the Taskfile, and the loader, framework and build definitions.

The first slice is a node, not one leaf. The charter's "first leaf" must carry
the framework minor, selection support, a second bundled provider, packaging,
conformance, a contract-only client and VM acceptance. That is several sessions of
work, and grove's unit is one session. So `launch-path` is the first working
increment. Its six leaves are ordered expand-first, and each leaves `task test`
and the signed app green. Only the node as a whole delivers the end-to-end launch.
None of its leaves is a dead layer, because each is verifiable at its own seam:
fixture providers for the framework feature and desktop candidates for selection.
Packaging stays with the first operation, as the charter requires.

The first slice implements the complete `WorkspaceApplicationInput`, including
the optional installation path, at L/G/N. The alternative was a bundle-identifier-
only input widened later. It would serve a launch field whose design description
cites `applicationPath`, so the served SDL would diverge from the design file.
Multiple-copy V acceptance becomes its own later leaf, which also covers named-app
opening.

Conformance grows by root. Until every workspace root is implemented, the
workspace profile expects the design SDL restricted to the implemented roots and
the types they reach, verbatim. The leaf landing the last root requires the
complete design file. A coordinate missing from the served schema always fails.

Increment order: launch path, then the whole selection matrix, then the
remaining operations, then disclosure. Selection is proven directly after the
path because every later workspace N/V run stands on that loader. Its code is
freshest then, and flushing plumbing out early is the pathfinder's stated
purpose. The twelve-launcher preparation precedes URL and path work because it
installs Dia and Zed, which those increments need. The protected-path
probe precedes both path consumers and, through tree order, app-and-file-search.

Certificate-dependent alternate-team V cases get a late root-level HITL leaf
ahead of `baseline-acceptance`. Placing them in this node would stall the AFK
increments behind a human-held certificate. Leaving them unowned would surface
them only at baseline closure. This node may close with only those cases pending.

This decomposition is load-bearing for about twenty sessions and embodies
interpretive choices: the first-slice node, the conformance growth rule, the
ordering and the certificate placement. It earns a `review-planning` step
inserted ahead of the first increment, rather than an in-session reviewer.
