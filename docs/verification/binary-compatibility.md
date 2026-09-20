# Provider framework: binary compatibility pairs

The "Native binary interface" seam of `docs/specs/machine.md`, for what the
same-build suites cannot show: that a compiled provider and a compiled host,
built from different framework revisions and never against each other, load and
work together, and that what must be refused is refused before any of the
provider's code runs. The same-build cases (bundled duplicate frameworks,
collisions, architecture, dependency closure, staging) stay in
`ProviderLoaderTests`.

## Procedure

```sh
task compat                         # compat:build, then compat:verify, in debug
CONFIGURATION=release task compat   # the same in release
```

It needs the signing identity of `scripts/signing-env.sh`, `rsync` and
`python3`. Nothing launches `Koine.app` or touches
`~/Library/Application Support/Koine`: each case runs a headless host over a
temporary data directory.

`scripts/build-compat-pairs.sh` copies the sources into two trees under
`.build/compat/<configuration>/`, each with its own build directory, and builds
each as `task test` builds the repository:

| Tree | Framework | What it builds |
|---|---|---|
| `baseline` | 1.0: the sources as they are | `KoineCompatibilityHost`, the staged framework, the fixture and the loader's variants |
| `newer` | 1.1: `Fixtures/CompatibilityPairs/Minor1.swift` added, the requirement `describeInstance()` added to `Provider` with a default, `HostCompatibility.frameworkMinor` 1, framework version 1.1.0 | the same |
| `later` | — | later revisions of the fixture, from the newer tree's source: `revision2` compiled against the 1.0 framework; `revision2-built-against-newer`, the same source and manifest compiled against 1.1; `minor1`, which uses the 1.1 declarations and declares minimum minor 1 |

Framework 1.1 exists only to make this evidence and is never part of the shipped
framework. Its textual interface differs from 1.0's by the added requirement,
its default and one new function, and by nothing else. The overlay asserts each
line it replaces, so a source change cannot make it silently miss.

`scripts/verify-compat-pairs.py` makes a pair only at run time: it copies one
tree's bundle and approval record into the per-user provider root of a fresh
data directory and starts the *other* tree's host over it, one host process per
case. It drives the host as a client does, over loopback HTTP with a grant. The
host's ready line lists the `KoineProviderAPI` images dyld mapped into it; the
fixture's initializer log shows whether any of the bundle's code ran. It digests
every host, framework and provider binary before and after the run and fails if
one moved, and writes every observation to `results.json` beside the trees.

## Observed

Run again on 2026-09-21 after the floor was narrowed to macOS 26.0, debug: 19
cases, no failed check, every host and framework image at `minos 26.0` and the
fixture providers at `minos 13.0`. The results below are unchanged by it.

Run on 2026-09-19: macOS 26.6.2 (25G83), arm64; Apple Swift 6.4
(swiftlang-6.4.0.34.1), Xcode 27.0 (27A266a); Task 3.53.1; bundles signed by
Developer ID Application, Team ID TA43A4RUP3. Debug and release, 19 cases each,
no failed check, no binary changed during a run. The debug pairs were also run
three more times with the same result.

| Pair | Result |
|---|---|
| **Old plugin, newer host.** The baseline fixture, compiled against 1.0, in the 1.1 host | `ACTIVE`; every check below |
| **Newer plugin, old host.** `revision2`, compiled against 1.0, declaring 1.0, in the 1.0 host | `ACTIVE`, serving revision 2's greeting; every check below |
| **Newer declaration, old host.** `minor1` in the 1.0 host | `INCOMPATIBLE`: "The provider requires provider framework 1.1 or later; this Koine supplies 1.0."; initializer log empty |
| Control: `minor1` in the 1.1 host | `ACTIVE`, serving the greeting the 1.1 function returns; every check below |
| Control: `revision2` in the 1.1 host | `ACTIVE`; every check below |

The checks of a working pair, each made in the pair:

- **Factory cast and observation startup.** `koineManagement.providers` reports
  the provider `ACTIVE` with its manifest's version: the principal class was
  found in the staged image, cast to `ProviderFactory`, its descriptor composed,
  and `start()` returned.
- **Shared framework identity.** The host maps exactly one `KoineProviderAPI`
  image, its own tree's; the plugin brought none and bound to it.
- **Resolution and owned values.** Lists, objects, null and references come out
  of the plugin and nested resolvers are handed the parent it returned; a
  reference and a string argument go in through a mutation; 400 overlapping
  resolutions from eight connections return equal trees and the host survives.
  `unavailable`, `failed` and `osPermission` failures arrive as their kinds.
- **Async resolution.** A resolve held inside the plugin stays suspended while
  another completes, then resumes and answers.
- **Cancellation.** `fixtureAwaitCancellation` returns only when its task is
  cancelled. At the 5-second execution deadline the caller is answered and the
  plugin then counts one cancellation seen. With a second call outstanding, the
  host's `stop()` returns (0–1 ms) and the process exits 0, which it can only do
  once the plugin's task has seen cancellation and finished.
- **Control.** The initializer log holds the staged image's path, so the same
  instrument that reads empty for a refusal is seen to read non-empty.

Refused in the paired setting, baseline variants in the 1.1 host and newer-tree
variants in the 1.0 host alike, each with an empty initializer log, only the
host's own framework image mapped, and no schema contribution:

| Case | State and diagnostic |
|---|---|
| Unsupported major | `INCOMPATIBLE`: requires provider framework major 2 |
| Unavailable minor | `INCOMPATIBLE`: requires provider framework 1.99 or later |
| Missing feature | `INCOMPATIBLE`: requires host features this Koine lacks: time-travel |
| Signed by an identity other than the approved one | `REJECTED`: signed by Team ID TA43A4RUP3, not by the approved identity, Team ID ZZZZZZZZZZ |
| Ad-hoc signed | `REJECTED`: it is ad-hoc signed, not by the approved identity |
| Unsigned | `REJECTED`: it is not signed |

### A plugin is compiled against the oldest minor it declares

`revision2-built-against-newer` is `revision2`'s source and manifest compiled
against 1.1. Its source uses nothing 1.1 added, yet its binary imports the
default implementation and the method descriptor of `Provider.describeInstance()`:
a conformance compiled against a protocol records the default of every
requirement it does not implement. In the 1.0 host it is `REJECTED` by the
dynamic loader ("Symbol not found … describeInstance"), with no initializer
run; in the 1.1 host it is `ACTIVE`. The spec's rule already speaks of the
binary's symbols, not the source's, so this narrows nothing; the spec and the
README now say how to satisfy it. The manifest cannot be checked for this before
`dlopen`, and the refusal stays the explicit one the spec requires when a
manifest lies.

## Supported binary baseline

| | Baseline | How established |
|---|---|---|
| CPU architecture | arm64, the only one supported | `lipo -archs` on every host, framework and provider binary; every pair ran on arm64. The loader's refusal of a foreign or mismatched architecture is in `ProviderLoaderTests`. |
| Minimum OS | macOS 26.0 | `LC_BUILD_VERSION minos 26.0` in both revisions' hosts and framework images, from `platforms: [.macOS(.v26)]` in both packages; the fixture providers are still built for 13.0, as test material (below). The supported matrix is macOS 26 on arm64: [latency-and-support-matrix.md](latency-and-support-matrix.md). |
| Swift runtime | The OS's own, at `/usr/lib/swift` | `otool -L`: framework and providers link `libswiftCore` and `libswift_Concurrency` from `/usr/lib/swift` and embed no runtime. Every macOS 26 runtime is newer than the manifests' `minimumSwiftRuntime`, 5.7. |
| Compiler | Swift 6.4, language mode 6 | The `swift-compiler-version` line of the emitted `.swiftinterface`; both revisions and every provider were built by it. |
| Framework | major 1, minor 0, no host features | `HostCompatibility` and `koineHostFeatures`. |

## Decided at release acceptance

This section replaces a list headed "Left for `release-acceptance-handoff-k11`".
That stage did not do the work the list described; it decided which of it Koine
promises at all. The supported matrix is **macOS 26 on Apple Silicon**, chosen
by the human when the stage was planned, because the only golden image is
`testanyware-golden-macos-tahoe` on arm64 and Intel cannot be virtualized on
Apple Silicon at all — an x86_64 claim would be unfalsifiable here, not merely
untested. The deployment target was narrowed to match
([latency-and-support-matrix.md](latency-and-support-matrix.md)), and four of
the six items below stopped being obligations as a result. They are recorded as
out of scope, not as pending, so that this document does not go on implying work
nobody intends to do.

**Out of scope, by the matrix decision:**

- **x86_64 and universal binaries.** Koine is arm64 only, and says so. Nothing
  was built or run for Intel, and nothing will be under this matrix.
- **macOS 13 to 25.** The floor is macOS 26.0 in every Koine image — the host, the
  framework and the bundled desktop provider — and in both packages' platform
  declarations, `App/Info.plist` and `ProviderAPI/Info.plist`;
  `task check:minimum-os` keeps them together. That is also what made
  `libswiftCompatibilitySpan` a non-question, and it is observed rather than
  argued. It is a toolchain back-deployment library for `Span`, and a host built
  for the old floor links it by `@rpath`: both `KoineCompatibilityHost` builds of
  2026-09-19, at `minos 13.0`, carry `@rpath/libswiftCompatibilitySpan.dylib` in
  `otool -L`, resolved through the run path `/usr/lib/swift`. Rebuilt at
  `minos 26.0`, `Koine.app`'s executable does not link it at all — the compiler
  has nothing to back-deploy to an OS whose own runtime has `Span` — and on macOS
  26 `/usr/lib/swift/libswiftCompatibilitySpan.dylib` is itself only a symlink to
  `libswiftCore.dylib`. The question of whether a signed build for an older OS must
  carry it has no OS left to be asked about.
- **A different compiler on each side.** Both revisions were built by Swift 6.4.
  A provider built by another toolchain than its host is still the spec's
  "building with a newer compiler alone does not prove it" case, and it is still
  unproven — it is declared out of scope for this release, not established. The
  resilient framework (`docs/adr/resilient-provider-framework.md`) is the
  mechanism that is meant to make it work, and a release that promises it would
  need a pair built by two toolchains.
- **Distribution of older framework minors.** 0.1.0 ships framework 1.0, the only
  minor there has ever been, so there is no older minor to distribute. The rule
  in "A plugin is compiled against the oldest minor it declares" stands, and it is
  what makes this the first obligation of the release that raises the minor
  rather than of this one.

**Shown elsewhere:**

- **The signed application.** These hosts are unsigned SwiftPM executables
  without the hardened runtime, so library validation plays no part here. The
  Developer ID signed, hardened `Koine.app` loading an approved same-team provider
  is [signed-app-provider-vm.md](signed-app-provider-vm.md); the notarized build
  loading its bundled desktop provider and a quarantined same-team provider on a
  Gatekeeper-enforcing clone is [notarized-release-vm.md](notarized-release-vm.md).

**Still open, and not dissolved by anything:**

- **A second real signing identity.** The mismatched identities here are an
  approval record naming another Team ID, an ad-hoc signature and no signature.
  No run in this repository has used a bundle signed by a different Developer ID
  team: it needs a second certificate, and
  [signed-app-provider-vm.md](signed-app-provider-vm.md) records that what the
  kernel does with a foreign-team image "is not exercised, by design, and belongs
  to the later increment that adds the library-validation entitlement". Koine's
  own approval check refuses such a bundle before `dlopen`, which is what the
  cases above show; the kernel's refusal behind it is unobserved.
