# input-keystrokes-k4

## Goal

Ship the first input provider bundle. It serves target capture and the
keystroke operation, and the core serves the input disclosure. Add L and G
tests.

## Context

- The design leaf `app-input-k3` fixes the schema, the descriptions, the
  version numbers and the disclosure text. The contract is
  `docs/specs/app-input.md`, and the design is
  `docs/design/input-schema.graphql` with its example operations.
- The running log of `app-input-k3` names the documents that this leaf brings
  to the served state.
- The commit of `workspace-launch-k59` first bundled the workspace provider.
  It shows each file that a new bundle touches. These are the package
  manifest, the provider directory, the sealed catalogue, the tests and the
  build, signing and release scripts.
- `Providers/DesktopProvider/Logic` is the pattern for the pure logic module.
  It takes the native facts as plain values.
- The media key operation of desktop shows the checks of the consent and the
  posting access before a post.

## Done when

- The sealed catalogue enables the input slot with its bundle, versions and
  signing identifier. The app build signs and seals the bundle, and
  `task check:provider-catalogue` passes.
- `inputFrontTarget` and `inputTarget(process:)` return an input target under
  `input:read`. The Koine process has no reference. A process that
  `NSRunningApplication` does not report gives null.
- Under input control, `inputSendKeystroke` sends one chord with
  `CGEventPostToPid`, whether or not the target is the front app. The checks
  come in the order of the spec, and no check comes between the posts.
- Koine refuses its own process as a target, with the outcome
  `PROTECTED_TARGET`. Every other app is a target.
- The core serves the input disclosure text, and the descriptions state the
  reach and the limits.
- L tests in `InputProviderLogicTests` cover the chord events, the key table,
  the refusal of Koine and the rule for an app process.
- G tests cover the authority, the descriptions and the served disclosure.
  They call the keystroke operation only where Koine refuses before it sends.
  Two such cases are a stale target and the Koine process. A child process
  that is not an app gives null at capture.
- `task design:app-input-check` passes, and the served SDL matches the design
  for the roots that this leaf serves.
- `swift test` passes, and the documents that the design leaf named describe
  the served state.

## Notes

- No test sends a chord to an app of the host, in front or in the
  background. The G safety rule of the root brief applies.
