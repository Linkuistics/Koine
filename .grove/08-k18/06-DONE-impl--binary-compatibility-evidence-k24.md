# binary-compatibility-evidence-k24

## Goal

Demonstrate, with independently built binaries, that compatible host and
provider binaries upgrade independently, and state the supported binary
baseline as evidence.

## Context

- Spec: the last five paragraphs of "Native extensions — shared resilient Swift
  framework" and the "Native binary interface" row of "Test seams and
  acceptance".
- ADR: `docs/adr/resilient-provider-framework.md`.

## Done when

- A repeatable recipe, run from `Taskfile.yml`, builds the pairs from two
  framework revisions in separate build directories: a baseline, and a newer
  compatible minor that adds a declaration under the spec's evolution rules. No
  binary in a pair is rebuilt against its partner.
- *Old plugin, newer host.* The fixture compiled against the baseline loads in
  a host with the newer framework and resolves, starts, stops and cancels
  correctly, without rebuilding.
- *Newer plugin, old host.* The fixture rebuilt from newer source for the
  baseline, declaring no newer requirement, loads in the baseline host and
  works. The same fixture using the newer declaration declares the newer
  minimum minor and the baseline host refuses it before loading.
- Shared framework identity (one image), factory cast, ARC ownership of values
  across the boundary, async resolution and cancellation are each checked in a
  pair, not only in a same-build run.
- Unsupported major, unavailable minor, missing feature and a mismatched
  signing identity are refused before code loads in the paired setting.
- `docs/verification/` holds the evidence: the recipe, toolchain and OS
  versions, the observed results, and the supported baseline (Swift runtime,
  minimum OS, CPU architectures) with how each was established. Anything the
  pairs could not establish is listed for `release-acceptance-handoff-k11`.

## Notes

The "old host" must run alone, so it is a headless host executable embedding
the server with a given data directory and roots. It is test material and adds
no API; see the stage brief.

If the newer minor exists only to make this evidence, keep it out of the
shipped framework: the published interface is a permanent promise. If a pair
fails for a reason the contract did not foresee, stop and raise it; do not
weaken the pair until it passes.

## Decisions (running log)

- **Two revisions are two copies of the source tree**, each with its own
  `.build`, under `.build/compat/<configuration>/`. The newer one is the copy plus
  an asserted overlay: `Fixtures/CompatibilityPairs/Minor1.swift`, a defaulted
  `Provider.describeInstance()` requirement, `HostCompatibility.frameworkMinor`
  1 and framework version 1.1.0. The evidence-only minor never touches the
  shipped framework. A defaulted protocol requirement was chosen as the added
  declaration because it is the most demanding addition the evolution rules
  allow.
- **The old host is `KoineCompatibilityHost`**, an executable target of the root
  package under `Fixtures/CompatibilityHost` (a separate package could not name
  `ProviderRoot`'s module and would build the root twice). It serves the data
  directory's per-user root, prints port, an all-capability credential and its
  mapped framework images, and stops when stdin ends. `build-app.sh` ships only
  `KoineApp`.
- **The driver is external, over loopback HTTP** (`scripts/verify-compat-pairs.py`):
  two hosts cannot share a process, and HTTP is the seam a client uses.
- **Finding, stated in the spec: a plugin for an older host is compiled against
  that host's framework minor.** The revision-2 fixture source uses nothing new,
  but compiled against 1.1 its `Provider` conformance records the default of the
  requirement 1.1 added and imports two 1.1 symbols; the 1.0 host's dynamic
  loader refuses it (no initializer runs). This is within the spec's rule ("its
  binary uses symbols … available in that host's supported baseline"), so it was
  not raised as a contract limit; the for-baseline plugin is built against the
  1.0 interface, and the built-against-1.1 build is kept as a refusal case.
  Distribution consequence listed for `release-acceptance-handoff-k11`: each
  released minor's framework must stay available to plugin authors.
- **The fixture gained `fixtureAwaitCancellation`**, a resolver that returns only
  on cancellation and counts it, so cancellation is observable across the binary
  boundary.
- **Stop is evidenced by stop returning**, not by the held caller's answer.
  `LoopbackListener` serves connections in unstructured tasks and `stop()` does
  not wait for them, so a host that exits after `stop()` can drop a response in
  flight, contrary to the comment in `KoineServer.stop()`. Not this leaf's work:
  externalised as a new leaf.
