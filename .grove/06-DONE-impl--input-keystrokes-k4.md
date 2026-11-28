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

## Decisions (running log)

**Order of the Koine check.** A send checks for Koine before it checks for an
app. A probe on this Mac showed that `NSRunningApplication` reports no plain
command-line process and no child of one. The test runner loads AppKit, and
macOS does report it, with no bundle identifier. With the Koine check first,
the refusal of Koine holds whether or not macOS reports the Koine process as
an app. In production, Koine is always an app, so the order changes no result.

The spec gains a step for a process that is not an app, which raises
`unavailable`.

**The input reference.** An input reference is
`koine://input/target/<pid>/<start>`, with the start instant in whole
microseconds, as a desktop application reference holds it. The provider
parses only the exact text that it produces.

**Shared source.** `PostingConsent` moves from `Pointer.swift` to its own file
in the desktop provider. The input provider links it in by symlink, as it links
`ProcessStart.swift` and `ProcessIdentity.swift`. So both providers report the
same `os-permission` message. The desktop code does not change.

**Served schema.** The bundle serves the design body without the Space switch
root, its receipt and its outcome enum. `space-switching-k5` adds those three
blocks. The manifest and the descriptor already name
`additional-capabilities-v1` and framework minor 1. The host accepts a
declared feature that no field uses yet, so the 1.0.0 manifest is final now.

**Composition and profile.** The composed design
`desktop-input-workspace-schema-extension-host.graphql` adds the served input
part to the Koine 0.6.0 composition. Input's roots sit between desktop's and
workspace's. The profile `core-desktop-input-workspace-extension-host` pins
desktop 1.0.2, input 1.0.0 and workspace 1.0.2.

A conformance test holds the
engine's composition to the file, digest included. `vm-verify-conformance.sh`
now holds the signed application to this profile. `space-switching-k5` adds
the Space switch to the same file and profile.

**Selection hosts.** The two production hosts of the selection acceptance now
keep input reserved-only. Their rows concern desktop and workspace, and the
0.6.0 profile still describes them. The selection acceptance did not run in
this leaf. `app-input-acceptance-k6` owns that run.

**Rows in pending tables.** The authority row and the trace rows sit in tables
inside pending regions, and a marker cannot sit between table rows. The tables
hold 28 and 44 hard findings. As `app-input-k3` did for the same rows, this
leaf edits only its own cells and writes them by the rules. The checker finds
no hard finding in those cells alone. The sections in prose converted first,
each in its own change: "Reserved identities", the README introduction and the
glossary entry "Provider".

**G tests on a host without consent.** This Mac withholds Accessibility
consent and posting access from the test runner. So each G send reports
`os-permission`, and the L tests hold the steps after consent. Each G send
test branches on both checks, as the window layout tests branch on one.

**Failures that predate this leaf.** Two checks fail at the parent revision
too. The workspace test `aBundleWithinTheLimitWhoseInfoPlistIsTooLong...`
expects the Foundation text "File name too long", and macOS 27.2.1 words it
otherwise. `task check:docs` reports one evidence link to a task file that the
previous grove's finish removed.

**No review chain.** This leaf implements a design that `app-input-k8`
reviewed and `app-input-k9` integrated. The core's capability checks, which
existing tests hold, enforce the authority. The provider adds one protection
rule, and the L and G tests hold it. `app-input-acceptance-k6` checks the
behaviour in a VM with independent witnesses. The root brief plans no review
for this leaf, and nothing here needs an independent challenge beyond that.
