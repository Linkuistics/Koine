# The retained workspace 1.0.0 bundle

The long-location repair ships as workspace release/schema **1.0.1**
([spec](../specs/workspace-launch-and-open.md#subjects-and-versions)). Its old side, the
1.0.0 provider with the `ELOOP`/`ENAMETOOLONG`-as-absence defect still in it, cannot be
recovered once the provider source changes: rebuilding it from changed source, or
relabelling a historical update, retains nothing
([obligations](long-action-native-boundary.md#compatibility-and-implementation-obligations)).
So it is built from a named revision, in a tree of its own, before any source change, and
kept apart. Every later old/new workspace pair cites this build.

## The pin

[`scripts/retained-workspace-1.0.0.json`](../../scripts/retained-workspace-1.0.0.json)
names the revision:

| | |
|---|---|
| release / schema | 1.0.0 / 1.0.0 |
| signing identifier | `dev.antony.Koine.provider.workspace` |
| jj commit | `f24d6290e1f90e5967f88192e3bfa4e4a197e1f7` |
| jj tag | `workspace-1.0.0-baseline` |

The commit is the parent of the leaf that introduced the pin. The workspace provider, the
host, the framework, the build scripts and the tests are unchanged since
`c465b191be` (`workspace-disclosure-k79`), the last commit to touch them; the only change
to the retained SDL file, `docs/design/workspace-schema.graphql`, since then is four
header-comment lines long-location planning added, and the verification compares its
definitions rather than its comments. The build refuses a tag that no longer names the
pinned commit.

**No colocated git repository is needed.** The jj store here is git-backed
(`jj git root`), so the revision is extracted with `git archive` against that store. That
keeps the two symlinks in `Providers/WorkspaceProvider/Logic/` (the desktop provider's
kernel start-instant helper, linked in as source) that `jj file show`, which
`scripts/build-baseline-host.sh` uses for the released desktop, would write out as one-line
files. A repository with no git store behind it cannot rebuild the retained bundle this
way, and the build says so rather than falling back to the working tree.

## Building and verifying

```
task compat:workspace-baseline          # scripts/build-retained-workspace.sh
task compat:workspace-baseline-verify   # scripts/verify-retained-workspace.sh
```

Both take `CONFIGURATION=debug|release`. The build extracts the revision into
`.build/compat/<configuration>/workspace-1.0.0/src`, builds it there by that revision's own
`scripts/build-compat-tree.sh` and `Providers/WorkspaceProvider/build.sh`, seals and approves
the bundles as the application seals them, and keeps them apart:

| Path under `.build/compat/<configuration>/workspace-1.0.0` | Holds |
|---|---|
| `src/` | the extracted revision and its own `.build` |
| `products` | that revision's host (`KoineCompatibilityHost`), staged framework 1.1, fixtures and desktop provider |
| `bundled/` | `Desktop.koineprovider` and `Workspace.koineprovider`, sealed, each with its approval record: the in-application root a host bundles |
| `retained.json` | the record: commit, tag, release, schema, signing identifier, and the SHA-256 of the manifest, SDL and binary, and the code directory hash |

A later leaf pairs `bundled/Workspace.koineprovider` with a host of another revision, or
runs `products/KoineCompatibilityHost` over a root holding a 1.0.1 bundle. Nothing in the
retained bundle reads the working tree's provider source. The unsealed provider build is
byte-reproducible from the pinned tree (two builds, one digest); the sealed digests in
`retained.json` are those of the build that wrote it, and the verification holds the
artifact to them before and after every step that runs against it.

## What the verification holds the bundle to

Each check is preceded by the proof that it can fail.

| Check | Control seen red first |
|---|---|
| The artifact's manifest says 1.0.0/1.0.0 and its signing identifier is the pinned one; its digests equal the record; its seal verifies | the comparison is shown to see a mutated copy of each retained file |
| The bundle's SDL, the 1.0.0 profile and the composed 1.0.0 design are byte-identical to the pinned revision's, and the 1.0.0 workspace SDL's definitions are too | a copy with one line appended |
| The revision's own host, bundling the artifact, serves exactly the composed design SDL and digest of `core-desktop-workspace-extension-host.json`, and the exact provider candidates it pins (desktop and workspace 1.0.0, `BUNDLED`, `SELECTED`) | the revision's own `conformance-lib.sh` controls: ten mutated contracts and five mutated pins, each caught for the reason it names; and a copy of the bundle whose manifest says 1.0.1, resealed, which the pin refuses: `required workspace 1.0.0 (schema 1.0.0, ACTIVE) is not served as expected; the host serves workspace 1.0.1` |
| That revision's workspace suites pass with the artifact as the host's bundled root: the logic suites (L), `WorkspaceCompositionTests` and `WorkspaceInstallationsCompositionTests` (G), the schema, design-contract and catalogue conformance suites, and `WorkspaceProviderTests`, the short-path subjects (N) over the signed bundle | a provider built from a copy of the source in which `ENOENT` no longer means absence, sealed and installed in the same root: `WorkspaceProviderTests` fails exactly the two missing-path subjects, `aMissingPathADanglingLink…ArePathNotFound…` and `…AreNotFoundForReveal…` |

The suites are the retained revision's own, run in its own tree against its own host. They
bound what this proves: the 1.0.0 behaviour it shipped with, short paths included. They
close no long-location row, and no acceptance row of the spec is changed by this build.
