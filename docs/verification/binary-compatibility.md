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
| CPU architecture | arm64 | `lipo -archs` on every host, framework and provider binary; every pair ran on arm64. The loader's refusal of a foreign or mismatched architecture is in `ProviderLoaderTests`. |
| Minimum OS | macOS 13.0 declared | `LC_BUILD_VERSION minos 13.0` in every binary, from `platforms: [.macOS(.v13)]` and the fixture's `-target`. Declared, not run: see below. |
| Swift runtime | The OS's own, at `/usr/lib/swift` | `otool -L`: framework and providers link `libswiftCore` and `libswift_Concurrency` from `/usr/lib/swift` and embed no runtime. macOS 13 ships the Swift 5.7 runtime, the manifest's `minimumSwiftRuntime`. |
| Compiler | Swift 6.4, language mode 6 | The `swift-compiler-version` line of the emitted `.swiftinterface`; both revisions and every provider were built by it. |
| Framework | major 1, minor 0, no host features | `HostCompatibility` and `koineHostFeatures`. |

## Left for `release-acceptance-handoff-k11`

- **x86_64 and universal binaries.** Nothing here was built or run for Intel.
- **macOS 13 to 25.** The deployment target is declared; no pair ran on an OS
  older than 26.6. The host links `@rpath/libswiftCompatibilitySpan.dylib`, a
  toolchain back-deployment library, which a signed build for an older OS must
  carry or do without.
- **A different compiler on each side.** Both revisions were built by Swift 6.4.
  A provider built by an older or newer toolchain than its host is the spec's
  "building with a newer compiler alone does not prove it" case and is unproven.
- **A second real signing identity.** The mismatched identities are an approval
  record naming another Team ID, an ad-hoc signature and no signature. A bundle
  signed by a different Developer ID team needs a second certificate, and with
  the hardened runtime belongs to the signed-build VM verification.
- **The signed application.** These hosts are unsigned SwiftPM executables
  without the hardened runtime, so library validation played no part;
  `signed-app-provider-vm-verification-k25` covers the signed build.
- **Distribution of older framework minors.** Since a provider for an older Koine
  is compiled against that Koine's minor, every released minor's framework and
  interface must stay available to provider authors.
