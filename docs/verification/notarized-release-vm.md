# Notarized release on a Gatekeeper-enforcing VM

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for the one
combination the development-signed runs here lack: a **notarized, stapled**
`Koine.app`, **quarantined** as a download arrives, on a clone whose Gatekeeper
assessments are **enabled**. It closes that gap for
[resident-app-vm.md](resident-app-vm.md),
[signed-app-provider-vm.md](signed-app-provider-vm.md),
[accessibility-status-and-consent-vm.md](accessibility-status-and-consent-vm.md)
and [grant-enrollment-vm.md](grant-enrollment-vm.md), and answers the question about quarantined plugins that
`signed-app-provider-vm.md` does not.

What this run records about the per-user provider — refused at `dlopen` behind a
modal dialog that held the service's startup — is the platform's behaviour
**without** the loader's Gatekeeper check. Koine's loader asks Gatekeeper before
`dlopen` and refuses such a provider itself
([loading and trust](../specs/machine.md#loading-and-trust));
`scripts/vm-verify-notarized.sh` asserts that, and
[provider-quarantine-precheck-vm.md](provider-quarantine-precheck-vm.md) records
that run. Everything else here stands as the current build's behaviour.

## Procedure

```sh
task app                        # build and sign .build/app/Koine.app on the host
task app:notarize               # submit, wait, staple, and zip the release artifact
task app:verify                 # signature, version, staple, and Gatekeeper's verdict
task app:vm-verify-notarized    # fixture:variants, then scripts/vm-verify-notarized.sh
```

The clean clone, the transcript (`.build/vm-verify/notarized-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). Nothing runs the application on the
host. Two things are specific to this run:

- **The guest is started at `1920x2160`** (`KOINE_VM_DISPLAY`). The Gatekeeper
  policy control sits about 1600 pt down the Privacy & Security pane, which does
  not scroll under `input scroll`, and the accessibility tree reports its
  position in an unclipped layout space that does not move with the view. A
  screen tall enough to contain the control is the only reliable way to reach it.
- **Getting the clone to enforce is two switches, not one.** `spctl --status
  --verbose` reports them separately. `sudo spctl --global-enable` flips the
  first; nothing on macOS 26.5 flips the second from the command line
  (`--developer-id-enable` is unrecognized, and `--enable --label "Developer ID"`
  answers "This operation is no longer supported"), so the script sets it in the
  guest's System Settings and leaves the clone in the macOS **default** posture,
  "App Store & Known Developers". It then asserts **both** switches and refuses
  to continue otherwise — with assessments on but developer id off the clone is
  App Store-only, where a *notarized* Developer ID bundle is rejected exactly as
  an unnotarized one is, and a run made in that state would record `rejected` and
  prove nothing.

| Step | How | Expectation checked |
|---|---|---|
| Enforcing clone | `sudo spctl --global-enable`, then "Allow applications from: App Store & Known Developers" in the guest's System Settings | `spctl --status --verbose` reports `assessments enabled` **and** `developer id enabled` |
| Install | `ditto` zip, `testanyware file upload`, `ditto -x`, then `xattr -w -r com.apple.quarantine` explicitly — the upload route sets none | the attribute is present **before** anything launches; `stapler validate` passes on the installed copy |
| Assessment | `spctl -a -t execute -vv` in the VM | `accepted`, `source=Notarized Developer ID`, and **no** `override=` line |
| First launch | plain `open`, never right-click-Open | the first-run dialog is the notarized one — it reports that Apple checked the app and found nothing — and offers **Open**, which is clicked |
| Nothing stripped | `xattr -p` before and after | the attribute survives the launch (its flags field changes, `0181` → `01c1`, as LaunchServices records the approval) |
| Bundled provider | `koineManagement.providers`, and `lsof` on the hardened process | `desktop` `ACTIVE`; its image is mapped from a `Desktop-<digest>` staging copy, and `Contents/PlugIns` holds exactly `Desktop.koineprovider` |
| Quarantined per-user provider | same-team fixture + approval record, given `com.apple.quarantine` explicitly | `REJECTED` with the loader's diagnostic; **and Koine cannot finish starting** until the refusal dialog is dismissed |
| Quarantine cleared on the installed copy | `xattr -d -r` on the bundle in `~/Library/Application Support/Koine/Providers` | still `REJECTED` — the staged copy is reused and still carries the attribute |
| Staged copy invalidated | the `Fixture-<digest>` staging directory removed, nothing else changed | `ACTIVE`; `{ fixtureInfo { greeting } }` is served; the image is mapped from the re-staged copy, which carries no attribute |
| Consent attribution | the window's Request Accessibility Access, read from the screen | the macOS dialog names **Koine** on the notarized build |

## What this does and does not show

- **The first-run dialog is the result, not an obstacle.** A quarantined app gets
  one even when notarized. The notarized dialog says the app was downloaded and
  that "Apple checked it for malicious software and none was detected", and
  offers **Open**. The two refusals this same golden shows — "Apple could not
  verify…" for an unnotarized build, and "not downloaded from the App Store" for
  the App Store-only posture — offer no Open button at all. That is what makes the check discriminating rather than one that
  accepts whatever dialog appears.
- **Without the loader's check, a refused provider stops the service; it does
  not merely fail to load.**
  Providers are `dlopen`ed while the service comes up, and macOS's refusal is a
  modal dialog a person must dismiss, so the server never begins listening until
  someone clicks Done. The run asserts this directly — Koine's process running
  and **no** `endpoint.json` — rather than inferring it from the dialog. A user
  who downloads a third-party provider can therefore stop Koine starting at all,
  with no clue but a system dialog naming a `.dylib`. Koine does not allow that:
  its loader refuses a quarantined, un-notarized provider before `dlopen`
  ([loading and trust](../specs/machine.md#loading-and-trust),
  [provider-quarantine-precheck-vm.md](provider-quarantine-precheck-vm.md)).
- **Clearing quarantine at install time is not a remedy.** Koine stages each
  provider under a digest of its **content**; removing an extended attribute does
  not change content, so the digest is unchanged, the already-staged copy is
  reused, and it still carries the attribute. The proof is the value: the staged
  copy's timestamp and UUID are identical to the ones the run wrote onto the
  installed bundle, so it was inherited at staging time. The staged tree is also
  read-only (`xattr -d` answers `Permission denied`), so a user cannot clear it
  there. Only invalidating the staged copy made the provider load.
- **Notarization is what actually distinguishes the two providers.** The bundled
  desktop provider is staged from a quarantined application and loads anyway,
  because the application's ticket covers `Contents/PlugIns`. The fixture is
  same-team and approved but carries no secure timestamp (`seal.sh` uses
  `--timestamp=none`) and is notarized by nothing, so Gatekeeper judges it on its
  own — downstream of Koine's approval record and team comparison, both of which
  passed. This answers the question
  [signed-app-provider-vm.md](signed-app-provider-vm.md) does not: whether a
  quarantined, un-notarized same-team plugin still passes `dlopen`. It does not.
- **Koine reports the refusal properly.** The provider is `REJECTED` with the
  loader's full diagnostic ending "library load disallowed by system policy", so
  the failure is visible through the management surface and not only as a system
  dialog.
- **The clone is put into the macOS default posture, not a hardened one.** "App
  Store & Known Developers" is what a stock Mac ships with. Nothing was disabled
  to get here, and the App Store-only state the clone passes through on the way
  is stricter rather than weaker.
- **This does not show** the library-validation entitlement, a third-party-team
  provider, or `brew install`; the first two are out of scope for version 1
  ([loading and trust](../specs/machine.md#loading-and-trust)). It is one OS build on one architecture, which is
  the whole of the supported matrix: [latency-and-support-matrix.md](latency-and-support-matrix.md).

## Evidence

Run of 2026-09-20, transcript `notarized-20260920T195359.log`, against
`.build/app/Koine.app` version **0.1.0**, signed `Developer ID Application:
Antony Blakey (TA43A4RUP3)`, notarized as submission
`f50a0c8d-eaf4-4094-90fd-a7cd02b70fc6` (**Accepted** on its first submission) and
stapled. VM: clone of `testanyware-golden-macos-tahoe`, macOS 26.5 (25F71),
arm64, display 1920x2160, Gatekeeper assessments **enabled** and developer id
**enabled**. Result: **passed**, every expectation above.

```
== Put the clone into a Gatekeeper-enforcing state
Before: assessments disabled;
After:  assessments enabled;developer id disabled;
The clone is App Store-only; setting the default posture in System Settings.
After System Settings: assessments enabled;developer id enabled;

== Install the notarized bundle and quarantine it, as a download arrives
Quarantine on the bundle: 0181;6aafad63;Safari;328359D7-3A46-491D-B2D8-788D88AC9D2F
Quarantined files inside it: 29
Processing: /Applications/Koine.app
The validate action worked!

== Gatekeeper's verdict on the quarantined bundle, on its own merits
/Applications/Koine.app: accepted
source=Notarized Developer ID
origin=Developer ID Application: Antony Blakey (TA43A4RUP3)

== First launch of the quarantined copy: plain open, no right-click-Open
  “Koine” is an app downloaded from the Internet. Are you sure you want to open it?
  Safari downloaded this file today at 9:54 AM. Apple checked it for malicious software and none was detected.

== macOS refuses the quarantined plugin, and Koine cannot finish starting until it is dismissed
Koine running with no endpoint descriptor: blocked
  “libFixtureProvider.dylib” Not Opened
  Apple could not verify “libFixtureProvider.dylib” is free of malware that may harm your Mac or compromise your privacy.

== Nothing was stripped: the attribute is still on the launched bundle
Quarantine before launch: 0181;6aafad63;Safari;328359D7-3A46-491D-B2D8-788D88AC9D2F
Quarantine after launch:  01c1;6aafad63;Safari;328359D7-3A46-491D-B2D8-788D88AC9D2F

== The bundled desktop provider loads from Contents/PlugIns under quarantine
[{"provider":"desktop","state":"ACTIVE","diagnostic":null},
 {"provider":"fixture","state":"REJECTED","diagnostic":"The dynamic loader refused
  libFixtureProvider.dylib: dlopen(…/ProviderStaging/Fixture-5877893…/libFixtureProvider.dylib,
  0x0006): … not valid for use in process: library load disallowed by system policy"}]
Koine 822 admin txt REG … …/ProviderStaging/Desktop-120a0ee74a7a046dcdb94962443016f0/libDesktopProvider.dylib

== With the quarantine cleared, as approving an install would, the same provider loads
Quarantine on the installed provider now: … No such xattr: com.apple.quarantine
[{"provider":"desktop","state":"ACTIVE"},{"provider":"fixture","state":"REJECTED"}]

== Clearing the installed copy is not enough: Koine reuses its staged copy, which keeps the attribute
Quarantine on the staged copy:  0181;6aafad82;Safari;5240BA7D-0A39-40FE-B47B-0D083FA83FFD
Quarantine this run installed:  0181;6aafad82;Safari;5240BA7D-0A39-40FE-B47B-0D083FA83FFD

== Invalidating the staged copy is what actually works
[{"provider":"desktop","state":"ACTIVE"},{"provider":"fixture","state":"ACTIVE"}]
Quarantine on the re-staged copy: … No such xattr: com.apple.quarantine
{"data":{"fixtureInfo":{"greeting":"hello from the fixture provider"}}}
Koine 993 admin txt REG … …/ProviderStaging/Fixture-5877893…/libFixtureProvider.dylib

== The Accessibility consent dialog names Koine on the notarized build
[{"confidence":1.0,"text":"\"Koine\" would like to control this computer using", …}]
Shown by: 883 universalAccess

== PASSED
```

Screenshots beside the transcript: `-first-launch.png` (the notarized first-run
dialog), `-plugin-refused.png` (the loader refusal) and `-consent-dialog.png`
(the Accessibility prompt naming Koine).

## Tooling note

Four faults of procedure produce symptoms that point somewhere other than their
cause, and the scripts guard each. Waiting for startup before dismissing a
refusal dialog deadlocks, because the dialog holds startup, so the dismissal
happens inside the wait. A dismissal attempted once and latched leaves the dialog
standing for the whole bound when the click lands early, so it is attempted on
every iteration while the dialog stands. Unsetting `SNAPSHOT_DEPTH` instead of
restoring it aborts under `set -u` inside `element`'s subshell, which surfaces
from a retry loop as "the management window did not appear" while a screenshot
shows the window present and fully rendered. And `testanyware vm list` can report
`Running clones: (none)` for a clone `tart list` reports as `running` and whose
agent answers every call, so a liveness guard uses `tart`'s state column, as the
TestAnyware guidance says.
