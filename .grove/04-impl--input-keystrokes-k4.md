# input-keystrokes-k4

## Goal

Ship the first input provider bundle. It serves target capture and the
keystroke operation, and the core serves the input disclosure. Add L and G
tests.

## Context

- The design leaf `app-input-k3` fixes the schema, the descriptions, the
  version numbers and the disclosure text.
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
- Target capture returns a captured target under input read.
- Under input control, the keystroke operation sends one chord with
  `CGEventPostToPid` while the target is the front app. Otherwise it refuses
  and sends nothing.
- Koine refuses its own process and recognised consent or security dialogs as
  targets.
- The core serves the input disclosure text, and the descriptions state the
  reach and the limits.
- L tests in `InputProviderLogicTests` cover the chord events, the key table,
  the front-app decision and the protected targets.
- G tests cover the authority, the descriptions and the served disclosure.
  They call the keystroke operation only where Koine refuses before it sends.
- `swift test` passes, and the documents that the design leaf named describe
  the served state.

## Notes

- No test sends a chord to the front app of the host. The G safety rule of
  the root brief applies.
