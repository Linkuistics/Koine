# First-party selection: the signed, isolated VM seam (V)

The V rows of "Selection acceptance" in [the Machine spec](../specs/machine.md#selection-acceptance): the
update and trust rows, in a clean TestAnyware macOS clone whose Gatekeeper is **enforcing**, where N
([selection-updates.md](selection-updates.md)) and G ran on the build Mac.

**Status: established on notarized, stapled hosts, except the parts that need a second real Developer ID team's
certificate, which stay pending in `alternate-team-signing`.** Machine says a V quarantine case uses an *intact
notarized host* with genuinely quarantined downloads, and that a purpose-built V host is signed and notarized first:
every host here is, and the real 1.1.0 desktop and workspace updates are notarized on their own, as a published
update would be. The [2026-10-08 rerun](#workspace-101-rerun) establishes this seam with workspace
1.0.1/schema 1.0.1 as the bundled baseline and workspace 1.1.0/schema 1.0.1 as its update.

## Procedure

```sh
task selection:vm-hosts   # seals, notarizes and staples the six hosts and the two real updates (needs the notary profile)
task selection:vm         # scripts/vm-verify-selection.sh: the clone, the released app, the driver
```

`scripts/vm-verify-selection.sh` starts the clone at `1920x2160` and puts Gatekeeper in the macOS default posture
exactly as [notarized-release-vm.md](notarized-release-vm.md) does (assessments **and** developer id enabled, both
asserted). It then:

1. downloads the **released** Koine v0.1.0 *in the guest* (`curl` from the GitHub release), writes the quarantine a
   browser writes onto the archive, unzips it (which gives the attribute to everything inside), asserts
   `stapler validate` and `spctl` → `source=Notarized Developer ID`, launches it by plain `open` through its
   first-run dialog ("Apple checked it for malicious software and none was detected") and makes a grant
   (`koine:manage`, `desktop:read`, `desktop:control`) in its own window;
2. uploads the harness, the fixtures, the notarization record and the conformance tool, and the purpose-built hosts as a
   quarantined archive that is unzipped (a notarized host is a download too; `stapler validate` and `spctl` →
   `source=Notarized Developer ID` are asserted for every one);
3. runs `scripts/verify-selection-vm.py` **in the guest**, detached, and meanwhile reads the screen every ten
   seconds for a system dialog (`Not Opened`, `could not verify`, `cannot be opened`, `malicious software`).

`scripts/verify-selection-vm.py` imports the N harness (`scripts/selection_harness.py`) and the N driver's checks
(`scripts/verify-selection-updates.py`, whose `main()` is now guarded), so a V scenario is an N scenario with the
same fresh signed host process per scenario, alternative discovery order and restart, the same fresh marker log and
the same control for every refused-marker assertion. What V changes:

| | N / G | V |
|---|---|---|
| A quarantined per-user install | the attribute written onto each image with the user-approved flag pre-set (`00c3`); the verdict is **injected** (`KOINE_FIXTURE_ASSESSMENT`) | `HostRun.download`: the archive carries `0181;…;Safari;<uuid>` and `ditto -x -k` gives it to the extracted bundle. Nothing is written onto the tree, nothing is pre-approved, **nothing is injected**: `spctl` answers, and the driver asks the same question of every staged copy and records the answer beside the paths the process mapped |
| The old host | the v0.1.0 *headless driver* built from its source | the **released, notarized Koine.app**, downloaded in the guest and launched as a user launches it |
| Hosts | debug build, signed, on the build Mac | the same hosts, notarized and stapled, run in the guest after arriving as a quarantined download |

The harness check that governed the injected case now reads "a quarantined copy is judged by Gatekeeper's own
verdict: nothing is injected" (`GENUINE_QUARANTINE`, set only by the V driver).

## What was observed

The original run of 2026-10-01 used workspace 1.0.0. On notarized hosts, transcript
`.build/vm-verify/selection-vm-20261001T140407.log`, driver
transcript and record `.build/selection-vm/results/selection-vm-20261001T142333.{log,json}`: **133 host runs, 2 050
checks, none failed, every never-ran assertion paired with a control, no system dialog seen on screen** (ten-second
polls for the whole run, and once more after it). The notarization record says `"notarized": true`. An earlier run on the same
procedure with signed, un-notarized hosts (`task selection:vm-hosts -- --unnotarized`, which exists only to develop
the drivers) was green too, and observed the refusal half of both equal-bytes orders where this run observes the
accepting half.

- **Old host, old desktop: the released application.** Seven launches of the notarized v0.1.0 over an emptied per-user
  root (grants kept). Its bundled `Desktop-<digest>` copy is the only staged and mapped provider; its desktop
  operations answer as the contract says; `core-desktop-old-host` holds against it.
- **New host over the old baseline.** `desktop-old` (the shipped catalogue around the **released** desktop provider)
  in the guest: `ACTIVE`, catalogue equal to the shipped one, no feature stated, `core-desktop-extension-host` holds.
  The same eleven (and two, with Finder) desktop steps are sent to the released application and to this host and the
  answers are compared whole: identical.
- **Pre-extension host, newly published updates.** The released application is given the real 1.1.0 desktop
  update with the principal class kept and renamed: `INCOMPATIBLE` ("requires host features this Koine lacks:
  first-party-selection-v1"), its image never mapped, the bundled desktop `ACTIVE`, `core-desktop-old-host-update-refused`
  holds. The real workspace update, kept and renamed, is refused before load for the reason the released host meets
  *first*: it needs provider framework 1.1 and this host supplies 1.0, so the feature is not what names it. The
  stand-ins built to need no framework minor (`sk-r1.1.0`, kept and renamed) are refused for the feature alone, each
  binary shown loading where the feature is supplied. **Observed and not assumed at N:** the released host *stages*
  a per-user copy (`upd-<digest>`) before it judges it, and judges it before anything is loaded; the staged copy is
  never mapped.
- **Compatible newer updates and mixed releases, as genuine downloads.** The real 1.1.0 desktop
  over the released baseline on `desktop-old`; the shipped catalogue whole on `production` with the desktop update,
  the workspace update, both, and both under the renamed principal; the feature-less real updates refused and the
  baselines running. Each update is a quarantined, notarized download in the per-user root and Gatekeeper's own
  answer for its staged copy is `accepted` / `source=Notarized Developer ID`, beside `Desktop` and `Workspace`, the
  hosts' own bundles, which carry the attribute of the host they arrived in and are accepted under the host's
  ticket. Image inventory, conformance profiles and "host not rebuilt" as at N.
- **The fixture signing identifier.** The same-team providers claiming `desktop` and `workspace` at 9.0.0 under
  `…desktop.impostor` / `…workspace.impostor` are `REJECTED` / `signing-identifier-mismatch` before load by the
  production catalogue, the real 1.0.0 providers stay selected and answer; the same compiled binaries load as the
  designated baselines of `impostor-host` (the control).
- **Trust refusals of genuinely quarantined downloads.** Each of missing approval, another Team ID, unsigned, ad-hoc,
  altered seal, escaping location, incompatible framework, feature, OS and architecture and failed quarantine
  assessment, for the desktop and the workspace stand-in, alone and beside a healthy lower update, forward and
  reversed. The refused copy is a download; the lower update is not. Every case has the N reason and diagnostic,
  the lower or bundled selection with `selected-with-refusals`, and **no marker for the refused image and no dialog**.
  For the quarantine case the OS is asked of the staged copy and says, verbatim:
  `…/ProviderStaging/bad-<digest>/libFixtureShProvider.dylib: rejected` / `source=Unnotarized Developer ID`.
  Incompatible and unsigned copies are refused before Gatekeeper is asked (the loader's order, `ProviderLoader.swift`), so their quarantine
  attribute is never assessed.
- **A quarantine refusal recovered as its diagnostic says.** Release 1.6.0 (in no host, so with no ticket): refused
  under Gatekeeper's own verdict; clearing the attribute on the **installed** bundle alone changes nothing (the
  content-named staged copy keeps it and is still refused by the same verdict); deleting the staged copy too and
  restarting stages a fresh copy with no attribute, which loads.
- **Equal bytes in both roots, both orders, across the restart; a legacy entry.** Candidate-specific staged names,
  the per-user copy assessed on every start, the bundled copy never inheriting per-user quarantine, a legacy entry
  (quarantined and not) left as it was and never mapped. Recorded for every phase: each staged copy, whether it
  carries the attribute, the verdict, and the paths mapped (`assessments` in the record).

## Equal bytes, and what was recorded for them

A bundle's notarization is a fact about its bytes, so a per-user copy equal to the notarized host's bundle is accepted
by Gatekeeper, and the observable row is `equal-to-bundled`, not `quarantine-refused`; the recorded verdict for
`FixtureSh@user`, `FixtureSh@bundled` and the stale `FixtureSh` copy of the earlier host is `accepted` /
`source=Notarized Developer ID` in every phase, each staged copy beside its quarantine flag and the paths the process
mapped. The refusal half (a quarantined copy Gatekeeper has no ticket for, held across restart) is the recovery
scenario and the trust refusals. The staged copy of a host's own bundle is quarantined exactly when the host is (it
arrived as a download), and the driver holds each one to that.

## Workspace 1.0.1 rerun

On **2026-10-08**, `task selection:vm-hosts` and the unfiltered `task selection:vm` both exited 0.
The fresh TestAnyware clone ran **macOS 26.5 (25F71), arm64**, with Gatekeeper assessments and Developer ID
both enabled. Every purpose-built host arrived quarantined, validated its stapled ticket and was accepted as
`source=Notarized Developer ID`. The released Koine 0.1.0 was downloaded and first-run separately as before.

Transcript: `.build/vm-verify/selection-vm-20261008T175332.log`; driver transcript and JSON:
`.build/selection-vm/results/selection-vm-20261008T180522.{log,json}`. The record contains **133 host runs,
2 090 checks, 0 failed, 0 uncontrolled never-ran assertions and 0 owned reasons unseen**. All 182 never-ran
assertions have controls. Each of the 124 scenario/order runs and nine extra runs was reconciled with the full
driver recipe, not just its total; there are no duplicate run labels. The wrapper observed **0 unexpected
system dialogs** during its screen polls and none in the final check. Its exported JSON equals the result
independently downloaded from the guest. The clone was stopped after verification.

The real-provider observations in both discovery orders are:

| Subject | Workspace selection and profile |
| --- | --- |
| Production catalogue before any update | Bundled **1.0.1/schema 1.0.1**, `ACTIVE`, `SELECTED`; `core-desktop-workspace-repair-extension-host` |
| Newer desktop beside the workspace baseline | Workspace **1.0.1/schema 1.0.1** stays bundled and selected; `core-desktop-workspace-desktop-update-extension-host` |
| Newer workspace beside the desktop baseline | Per-user **1.1.0/schema 1.0.1** is selected; bundled 1.0.1 is `NOT_SELECTED` / `superseded-candidate`; `core-desktop-workspace-workspace-update-extension-host` |
| Both real updates, normal and renamed principals | Workspace **1.1.0/schema 1.0.1** is selected alongside desktop 1.1.0; `core-desktop-workspace-update-extension-host` |
| Updates without the selection feature | Updates refused before load; workspace **1.0.1/schema 1.0.1** stays selected with visible refusals; `core-desktop-workspace-update-refused-extension-host` |
| Fixture signing identifier at release 9.0.0 | Production refuses the fixture; real workspace **1.0.1/schema 1.0.1** remains selected. The distinct test catalogue admits its designated 1.0.1 fixture as the control |

The profiles use the repair SDL, pin release and schema independently, and turn red when workspace rows are
re-pinned to retained 1.0.0 or the retained composed design is substituted. Native images, operations,
approval records and unchanged host binaries satisfy the same checks as the N/G driver. Trust refusals,
quarantine recovery, equal-byte staging, legacy entries, released-host refusals and the desktop-operation
differential also pass in this run. The separate retained-host **1.0.1 per-user compatibility variant** remains
N/G evidence in [workspace-compatibility.md](workspace-compatibility.md); this run does not add V to that row.

With Antony's approval, eight submissions were accepted under `koine-notary`; the six hosts were stapled and
validated. `.build/selection-vm/notarization.json` records `notarized: true`, these IDs and the resealed
code-directory hashes; `.build/selection-vm-hosts-k185.log` records the build and verdicts.

| Submission | Accepted ID |
| --- | --- |
| Host `desktop-old` | `8180a9c3-2ecb-4389-80ac-9426532141b5` |
| Host `production` | `a4902bbe-739e-4070-8782-53832753a1b4` |
| Host `impostor-host` | `75b33eab-527d-49c6-8944-2b097b729379` |
| Host `slot` | `11a70e6c-bd46-4964-af3f-c8070b5ebf2e` |
| Host `two-slots-sorted` | `c1cbcc72-f98a-4bbd-924b-5e6fe030a740` |
| Host `slot-caught-up` | `aaeeeabf-9ce9-4cea-83a9-744a06dabec2` |
| Bundle `desktop-update` | `3b482f68-4084-4c90-9fae-be89f5371c4d` |
| Bundle `workspace-update` | `d0a26af2-379f-4f16-b739-79e68cf4b5e4` |

SHA-256 digests before and after the accepted run match for all 909 build-tree input files: `scripts/`,
`Fixtures/`, `App/`, `Providers/`, `Sources/`, `docs/design/`, `Package.swift`, `Package.resolved`,
`Taskfile.yml`, and the notarized fixture/host trees and record. The 669 staged guest input files also match
after the driver exits, including its actual conformance tool/framework, metadata, profiles, scripts and bundles.
The per-file records are `.build/selection-vm-inputs-{before,after}-k185-rerun.json` and
`.build/selection-vm-inputs-guest-k185-rerun/{before.sha256,after.log,after.exit}`.

The earlier attempt, `.build/vm-verify/selection-vm-20261008T172939.log`, is **discarded evidence**: a false
agent timeout retried an unguarded launch, and two live drivers wrote the same result files. The launcher now
uses the atomic directory guard already used by `guest_bg`. `task selection:vm-check` exercises concurrent
and completed retries of the real launch command: it failed with three writers before the repair, passes with
one after it, and checks that the driver's log and nonzero exit status survive. Syntax and ShellCheck pass too.
The accepted rerun observed one live scenario driver and reused the same notarized artifacts.

## Not closed

- **A bundle signed by a second Developer ID team, and the alternate-team host.** This keychain holds one Developer
  ID team. Owned by `alternate-team-signing`, at V as at N and G.

## Findings

- **Fixtures are built for macOS 26.** They targeted 13.0 and drew a linker warning per build; they now take
  `MINIMUM_OS` from `App/Info.plist` (the manifest says `@MINIMUM_OS@`, because the loader refuses a manifest that
  understates the binary's floor), and the `understated-os` loader test reads "26.0".
- **Harness: a notarized host is itself a download.** Its bundled providers' staged copies inherit its quarantine
  attribute, which the N-era expectations ("not quarantined") did not allow; the V driver holds them to the host's own
  state and excludes them from the count of installed quarantined copies.
- **No defect in the loader.** Every V outcome is the N outcome, with the platform's own verdict in place of the
  injected one.
- **Harness: the old host is launched, not driven.** In an earlier run of this procedure `open` on the released
  application produced no descriptor on its first two launches; the driver now asks LaunchServices again after
  45 seconds, up to three times, and records what ran if it still did not.
- **The released workspace-update refusal reads "framework", not "feature".** Stated above; the feature is isolated by
  the stand-ins.
