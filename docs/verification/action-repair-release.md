# Workspace 1.0.1: the action-only repair, shipped (action-repair-release, k178)

**Result: the signed `Koine.app` packages workspace release/schema 1.0.1 under `koine-desktop/1`. It serves
the [repair SDL](../design/workspace-action-repair-schema.graphql) verbatim, its catalogue entry says so, and a new
bundled profile holds what the signed host serves to its composed design, its digest and its candidates. The
retained 1.0.0 bundle, SDL and profile are untouched and still pass against the retained bundle.** The
behaviour the three new descriptions state was made true by the stage leaves
([reveal](reveal-locations.md), [open](open-path-locations.md), [supplied](application-locations.md) and
[discovered](discovered-applications.md) applications, [receipt identities](receipt-executable-identity.md));
this leaf is the release that names it. Its effect on a real machine is `target-locations-vm` and
`application-locations-vm`'s; its pairs with other hosts are `action-repair-compat`'s.

## What changed

| Piece | 1.0.0 (retained) | 1.0.1 (shipped) |
| --- | --- | --- |
| Provider source | `Providers/WorkspaceProvider/manifest.json` 1.0.0 / 1.0.0 | 1.0.1 / 1.0.1 |
| Served SDL | the 1.0.0 design, verbatim | `Providers/WorkspaceProvider/schema.graphql`: its own three-line header and everything after the repair SDL's header comment, which is identical (`diff`) |
| Catalogue | `App/ProviderCatalogue.json` workspace 1.0.0 / 1.0.0 | 1.0.1 / 1.0.1, the signing identifier `dev.antony.Koine.provider.workspace` unchanged |
| Composed design | `desktop-workspace-schema-extension-host.graphql` | `desktop-workspace-repair-schema-extension-host.graphql`: the retained composition with exactly the three description lines replaced (made by pairing the two SDLs' lines, never by hand) |
| Profile | `core-desktop-workspace-extension-host.json` (workspace 1.0.0 / 1.0.0) | `core-desktop-workspace-repair-extension-host.json` (desktop 1.0.0 / 1.0.0, workspace 1.0.1 / 1.0.1, each `ACTIVE`, `BUNDLED`, `SELECTED`, no reason) |
| Served digest | `3bab3a0457329647e795ab04bdd52580d43e35841f0179aea1b83f9eb222a733` | `0a489328533ad17dcb54f2a81e1828588bfebd203da32cac11da57752e91f8d2` |

Shapes, enums and error kinds are unchanged: `task design:action-repair-check` shows the two SDLs equal once
descriptions are stripped and different in exactly the three action descriptions (launch, open path, reveal),
with an unchanged-baseline control that is rejected. The digests differ on the same host and printer.

## What was run

- **`task app`** built and signed the application (Developer ID, Team `TA43A4RUP3`); the packaged
  `Workspace.koineprovider` carries the manifest 1.0.1 / 1.0.1 and a `schema.graphql` byte-equal to the source.
- **`task check:provider-catalogue`** read each enabled entry's signing identifier from the signed bundle and its
  versions from its manifest, and agreed; its six self-test mutations (release, identifier, absent bundle, reserved
  entry, core-owned name, malformed version) were each reported.
- **`task conformance`** passed all three profiles; the third, held to the new profile, was the signed application
  in a clean TestAnyware clone (transcript `.build/vm-verify/conformance-20261007T202948.log`). It served
  `Providers served: desktop 1.0.0 and workspace 1.0.1, ACTIVE, BUNDLED, SELECTED`, the contract `koine-desktop/1`, and the
  digest above; the report was empty and the design file's canonical digest equalled it. Every control was seen red first:
  - the existing design controls (a description or a nullability marker removed, an argument default introduced, two roots
    transposed, each root removed, a workspace type's description changed, the launch field moved before desktop's);
  - **new for the repair**: the retained 1.0.0 text restored for each of the three actions in turn (each a one-difference report and
    a digest difference), and all three restored (a three-difference report): the served schema cannot keep one old description;
  - the candidate pins: a different release, a missing required provider, an unexpected row, workspace left out, another workspace
    release, and **new**: the retained release 1.0.0 pinned for the repair and the retained schema 1.0.0 pinned for the repair, each
    naming `is not served as expected`. Release and schema are pinned separately from the SDL and digest.
- **`task compat:workspace-baseline-verify`** (the retained bundle, built from the pinned revision) still passes: the
  retained SDL, composed design and profile are byte-equal to the pinned revision's, that revision's host serves the 1.0.0 profile
  over the retained bundle, a copy resealed as 1.0.1 turns the pin red, and its short-path suites pass against the bundle.
- **`task test`** passes, including new tests: the 1.0.1 bundle's composition is the repair design (report empty, digest equal);
  it differs from the retained composition at exactly `Mutation.workspaceLaunchApplication`, `workspaceOpenPath` and
  `workspaceRevealPath`, all as descriptions, with a different digest; the repair profile is the repair design restricted
  verbatim; and the two profiles' pins refuse each other and refuse a mismatched release or schema.
- **The contract-only client** was regenerated from the capture of that same run (`introspection.json` and the digest read in the
  same session, as `task client:capture` writes them, without a second VM run); `task client` generates, typechecks, bundles
  and passes every adapter check. Its README names the new digest and the retained 1.0.0's.

## The findings records

The client's findings records ([launch](launch-contract-client-findings.md), [URL](open-url-contract-client-findings.md),
[path](open-path-contract-client-findings.md)) are the authors' accounts against the capture of their day and are kept as written;
the digests they quote are those captures' and are not the current one. They remain correct about the contract's shapes, which
1.0.1 does not change. The current digest and the coverage are in `clients/contract-only/README.md`, and the descriptions the
client now carries are the repaired ones.

## Not done here

Everything the brief leaves to later leaves: the independent old/new pairs, the retained-host per-user 1.0.1 variant and the
re-pinned selection fixtures (`action-repair-compat`; the update profiles still pin workspace 1.0.0 as the bundled row, and
`task selection:*` and `task compat` have not been re-run against this release); the effect at V, including the N gaps
that only an effect shows (`target-locations-vm`, `application-locations-vm`); and actual-search acceptance. The first `task test`
run of this session recorded a failure in `KoineServerTests` that two later runs of the same tree (426 tests in 29 suites)
did not reproduce; it was not captured, so it is neither explained nor dismissed.
