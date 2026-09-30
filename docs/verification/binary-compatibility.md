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
task compat:baseline                # only the released side: the pre-extension host, framework, fixtures and desktop provider
```

It needs the signing identity of `scripts/signing-env.sh`, `rsync` and
`python3`. Nothing launches `Koine.app` or touches
`~/Library/Application Support/Koine`: each case runs a headless host over a
temporary data directory.

`scripts/build-compat-pairs.sh` builds two independent revisions under
`.build/compat/<configuration>/`, each in a tree of its own with its own build
directory, by the same `scripts/build-compat-tree.sh` that runs the tree's own
scripts as `task test` does:

| Tree | Framework | What it builds |
|---|---|---|
| `baseline` | 1.0: the **released** revision, tag `v0.1.0` (`KOINE_BASELINE_REVISION` names another), extracted from the repository by `scripts/build-baseline-host.sh`, never this tree with edits | that release's `KoineCompatibilityHost`, staged framework, fixture, loader variants and sealed desktop provider |
| `newer` | 1.1: this working tree, which serves `additional-capabilities-v1` | the same, from these sources, and the `KoineConformance` tool |
| `later` | — | later revisions of the fixture, from the newer tree's source, each compiled against the framework its name says (below) |

The `later` fixtures are one source under compile flags and manifest edits:

| Case | Compiled against | Manifest | Descriptor |
|---|---|---|---|
| `revision2` | 1.0 | minor 0, no feature | no feature |
| `revision2-built-against-newer` | 1.1 | minor 0, no feature | no feature |
| `additional` | 1.1, uses `additionalRequirements` | minor 1, the feature | the feature |
| `additional-feature-only` | 1.1, as `additional` | minor 0, the feature | the feature |
| `additional-undeclared` | 1.1, as `additional` | minor 1, no feature | no feature |
| `additional-manifest-omits` | 1.1, as `additional` | minor 1, no feature | the feature |

The `additional` variants also carry one field the plain fixture lacks,
`fixtureRenameItemChecked`, a control action that additionally requires
`fixture:read` (`Fixtures/FixtureProvider/additional.graphql`). The released
tree's build is reusable on its own: any check that needs the pre-extension host
runs `task compat:baseline` and finds it under
`.build/compat/<configuration>/baseline/products`.

`scripts/verify-compat-pairs.py` makes a pair only at run time: it copies one
tree's bundle and approval record into the per-user provider root of a fresh
data directory and starts the *other* tree's host over it, one host process per
case. The desktop case also gives the new host a second directory standing in
for `Contents/PlugIns`, holding the released tree's desktop bundle and its
approval record, so `desktop` loads as the bundled provider it is reserved to be.
It drives the host as a client does, over loopback HTTP with a grant. The
host's ready line lists the `KoineProviderAPI` images dyld mapped into it; the
fixture's initializer log shows whether any of the bundle's code ran. It digests
every host, framework, provider and conformance-tool binary before and after the
run and fails if one moved, and writes every observation to `results.json` beside
the trees.

## Observed

Run on 2026-09-30, debug, on macOS 26.6.2 (25G83), arm64, Apple Swift 6.4
(swiftlang-6.4.0.34.1), Xcode 27.0 (27A266a), Task 3.53.1, bundles signed by
Developer ID Application, Team ID TA43A4RUP3, every host and framework image at
`minos 26.0` and the fixture providers at `minos 13.0`: 24 cases, no failed check,
no binary changed during the run. The baseline was built from `v0.1.0`
(commit `ee4716130bbc`). The same recipe in release (`CONFIGURATION=release`) ran
24 cases with no failed check.

| Pair | Result |
|---|---|
| **Old plugin, newer host.** The released fixture, compiled against 1.0, in the 1.1 host | `ACTIVE`; every check below |
| **Newer plugin, old host.** `revision2`, compiled against 1.0, declaring 1.0, in the released host | `ACTIVE`, serving revision 2's greeting; every check below |
| Control: `revision2` in the 1.1 host | `ACTIVE`; every check below |
| **Compiled against 1.1, declaring 1.0, old host.** `revision2-built-against-newer` in the released host | `ACTIVE`; every check below. See the section after these tables |
| Control: the same in the 1.1 host | `ACTIVE`; every check below |
| **The feature, working.** `additional` in the 1.1 host | `ACTIVE`; every check below, and the four below them |
| **The feature, old host.** `additional` in the released host | `INCOMPATIBLE`: "The provider requires provider framework 1.1 or later; this Koine supplies 1.0."; initializer log empty |
| **The feature alone, old host.** `additional-feature-only`, minimum minor 0, in the released host | `INCOMPATIBLE`: "The provider requires host features this Koine lacks: additional-capabilities-v1."; initializer log empty |
| **Undeclared use, new host.** `additional-undeclared` in the 1.1 host | `REJECTED`: "A field requires additional capabilities, and the descriptor does not declare additional-capabilities-v1."; the bundle was loaded (its initializer ran), no field of it is in the schema, no `fixture:` capability is offered |
| **The feature under a minimum minor that cannot carry it.** `additional-feature-only`, minimum minor 0, in the 1.1 host | `REJECTED` before any code loads: "The manifest requires additional-capabilities-v1 but declares framework minimum minor 0; the feature needs 1.1."; initializer log empty |
| **A descriptor declaring what its manifest does not.** `additional-manifest-omits` in the 1.1 host | `REJECTED`: "The provider's runtime descriptor disagrees with its manifest about its identifier, prefix or required features."; loaded, nothing served |
| **The existing desktop, new host.** The desktop provider built and sealed from the released sources against framework 1.0, bundled, in the 1.1 host | `ACTIVE`; both its capabilities offered; an absent process is an ordinary null without an error; the served schema equals `docs/design/desktop-schema.graphql` with the served digest, by the release's own `KoineConformance` check, which the same run shows red against a design text with one description changed |

The four checks of the feature working, made in the `additional` pair, each
against grants created over HTTP by the host's own all-capability grant:

- **The set is enforced.** `fixtureRenameItemChecked` under a grant holding
  `fixture:control` alone is refused before any action, with HTTP 403 at the
  action's own alias path, `requiredCapability: fixture:read` and
  `requiredCapabilities: [fixture:control, fixture:read]` at `phase:
  authorization`, and the fixture's `renameItem` call count did not move.
- **A registration without the set is unchanged.** `fixtureRenameItem` under a read-only grant is
  refused with exactly the keys `kind`, `permissionClass`, `phase` and
  `requiredCapability`, and no `requiredCapabilities`.
- **With the whole set the action runs**, once.
- **No mocks.** These are the compiled fixture binary's registrations, read by the
  compiled host.

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

**The feature checks were watched to fail.** A copy of the new host's tree with
the registration's additional set replaced by an empty one, rebuilt and run
through the same recipe, failed all three enforcement checks (the refusal came
back HTTP 200, the resolver was called, and the action ran under a grant that
lacked the set). The unit and public-GraphQL cases in `AdditionalCapabilityTests`
were watched to fail the same way, and the copy was restored before the run above.

**The `stop` check was intermittent, and the released host still is.** The check asks
that a caller held in the plugin be answered before the host exits. It failed in
roughly one run in five of `task compat:verify` (`RemoteDisconnected('Remote end
closed connection without response')` on the held call, the host exiting 0 in 0
ms). The listener cleared a connection's `busy` flag after the handler returned
and before the response was written, and `stop()` closes every connection that is
not `busy`; with the held resolve cancelled, the handler returns at once and the
close landed in that gap. The current host keeps `busy` until the write completes,
and `ListenerStopOrderingTests` forces the order (it fails with the old order
restored). 25 consecutive `task compat:verify` runs passed all 100 `stop` checks
of the current host. The **released v0.1.0 host has the same ordering and still
has the defect**: in those 25 runs the `stop` check failed once, against the
baseline host and with the identical symptom, so a run of `compat:verify` can
still fail on the released side of a pair. That is a limit of the released
binary, not a regression.

Refused in the paired setting, released-tree variants in the 1.1 host and
newer-tree variants in the released host alike, each with an empty initializer
log, only the host's own framework image mapped, and no schema contribution:

| Case | State and diagnostic |
|---|---|
| Unsupported major | `INCOMPATIBLE`: requires provider framework major 2 |
| Unavailable minor | `INCOMPATIBLE`: requires provider framework 1.99 or later |
| Missing feature | `INCOMPATIBLE`: requires host features this Koine lacks: time-travel |
| Signed by an identity other than the approved one | `REJECTED`: signed by Team ID TA43A4RUP3, not by the approved identity, Team ID ZZZZZZZZZZ |
| Ad-hoc signed | `REJECTED`: it is ad-hoc signed, not by the approved identity |
| Unsigned | `REJECTED`: it is not signed |

### A plugin is compiled against the oldest minor it declares

The rule, in `docs/specs/machine.md`, is that a plugin built for an older host is
compiled against the oldest framework minor it declares, not merely written
without newer declarations: a conformance compiled against a protocol records the
default implementation and method descriptor of every requirement a newer minor
added, and an older host's dynamic loader then refuses the binary with "Symbol not
found". The hazard is real, and this repository saw it: an earlier revision of
this evidence simulated a minor 1 with an overlay that added a defaulted
`describeInstance()` requirement to `Provider`, and a provider compiled against
that overlay was `REJECTED` by the 1.0 host with no initializer run
(observed 2026-09-21).

That overlay is gone. The real minor 1 adds **no protocol requirement**: it adds a
type, an initializer beside the retained one and a feature name. So
`revision2-built-against-newer`, `revision2`'s source and manifest compiled
against 1.1, needs nothing 1.1 added and the released 1.0 host runs it, `ACTIVE`,
as the table above records. That is a fact about this minor, not a retirement of
the rule: it binds any release that adds a protocol requirement, and the old
overlay case cannot be reproduced against a framework that does not have one. The
initializer is the reason a plugin using `additionalRequirements` gets a manifest
minimum minor of 1: it calls a symbol 1.0 lacks, which the manifest states and the
loader checks before `dlopen`.

## Supported binary baseline

| | Baseline | How established |
|---|---|---|
| CPU architecture | arm64, the only one supported | `lipo -archs` on every host, framework and provider binary; every pair ran on arm64. The loader's refusal of a foreign or mismatched architecture is in `ProviderLoaderTests`. |
| Minimum OS | macOS 26.0 | `LC_BUILD_VERSION minos 26.0` in both revisions' hosts and framework images, from `platforms: [.macOS(.v26)]` in both packages; the fixture providers are built for 13.0, as test material (below). The supported matrix is macOS 26 on arm64: [latency-and-support-matrix.md](latency-and-support-matrix.md). |
| Swift runtime | The OS's own, at `/usr/lib/swift` | `otool -L`: framework and providers link `libswiftCore` and `libswift_Concurrency` from `/usr/lib/swift` and embed no runtime. Every macOS 26 runtime is newer than the manifests' `minimumSwiftRuntime`, 5.7. |
| Compiler | Swift 6.4, language mode 6 | The `swift-compiler-version` line of the emitted `.swiftinterface`; both revisions and every provider were built by it. |
| Framework | major 1, minors 0 (released, 0.1.0) and 1 (this tree); the one host feature `additional-capabilities-v1` since minor 1 | `HostCompatibility` and `koineHostFeatures`; the pairs above. |

## Scope of this evidence

The supported matrix is **macOS 26 on Apple Silicon**
([latency-and-support-matrix.md](latency-and-support-matrix.md)). The only
golden image is `testanyware-golden-macos-tahoe` on arm64, and Intel cannot be
virtualized on Apple Silicon at all, so an x86_64 claim would be unfalsifiable
here, not merely untested.

**Out of scope:**

- **x86_64 and universal binaries.** Koine is arm64 only, and says so. Nothing
  is built or run for Intel.
- **macOS 13 to 25.** The floor is macOS 26.0 in every Koine image — the host, the
  framework and the bundled desktop provider — and in both packages' platform
  declarations, `App/Info.plist` and `ProviderAPI/Info.plist`;
  `task check:minimum-os` keeps them together. At that floor
  `libswiftCompatibilitySpan` does not arise, and that is observed rather than
  argued. It is a toolchain back-deployment library for `Span`, and a host built
  for an older floor links it by `@rpath`: both `KoineCompatibilityHost` builds of
  2026-09-19, at `minos 13.0`, carry `@rpath/libswiftCompatibilitySpan.dylib` in
  `otool -L`, resolved through the run path `/usr/lib/swift`. Built at
  `minos 26.0`, `Koine.app`'s executable does not link it at all — the compiler
  has nothing to back-deploy to an OS whose own runtime has `Span` — and on macOS
  26 `/usr/lib/swift/libswiftCompatibilitySpan.dylib` is itself only a symlink to
  `libswiftCore.dylib`. Whether a signed build for an older OS must carry it is
  not a question any supported OS asks.
- **A different compiler on each side.** Both revisions are built by Swift 6.4.
  A provider built by another toolchain than its host is the spec's "building
  with a newer compiler alone does not prove it" case, and it is unproven: out
  of scope, not established. The resilient framework
  (`docs/adr/resilient-provider-framework.md`) is the mechanism meant to make it
  work; promising it would need a pair built by two toolchains.
- **Distribution of older framework minors.** Each release ships one framework.
  0.1.0 shipped 1.0, and this tree's is 1.1; both are built and paired above, but
  the pairs are between a released and an unreleased tree, on unsigned hosts.
  Nothing distributes 1.0 to a plugin author alongside 1.1, and no run is made
  under the signed application across the two minors. The rule in "A plugin is
  compiled against the oldest minor it declares" stands, and binds any release
  that adds a protocol requirement.

**Shown elsewhere:**

- **The signed application.** These hosts are unsigned SwiftPM executables
  without the hardened runtime, so library validation plays no part here. The
  Developer ID signed, hardened `Koine.app` loading an approved same-team provider
  is [signed-app-provider-vm.md](signed-app-provider-vm.md); the notarized build
  loading its bundled desktop provider and a quarantined same-team provider on a
  Gatekeeper-enforcing clone is [notarized-release-vm.md](notarized-release-vm.md).

**Open:**

- **A second real signing identity.** The mismatched identities here are an
  approval record naming another Team ID, an ad-hoc signature and no signature.
  No run in this repository uses a bundle signed by a different Developer ID
  team: it needs a second certificate, and
  [signed-app-provider-vm.md](signed-app-provider-vm.md) records that what the
  kernel does with a foreign-team image "is not exercised, by design". Koine's
  own approval check refuses such a bundle before `dlopen`, which is what the
  cases above show; the kernel's refusal behind it is unobserved.
