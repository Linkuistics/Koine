# notarized-release-build-k39

## Goal

Make the release bundle notarized and stapled, and prove on a Gatekeeper-enforcing
VM that a **quarantined** copy of it launches, is attributed to Koine in the
Accessibility prompt, and loads a quarantined same-team provider. Every later
leaf in this stage runs on the artifact this leaf produces.

## Context

- `scripts/build-app.sh` and `scripts/verify-app.sh` already build and check the
  Developer ID-signed, hardened-runtime bundle inside out, and
  `scripts/signing-env.sh` is the one place the identity is named. Extend that
  shape; do not introduce a second notion of the release bundle.
- `App/Info.plist` already carries `CFBundleShortVersionString` 0.1.0 and
  `CFBundleVersion` 1. They are currently decoration — nothing reads them, no tag
  matches them. This leaf makes the marketing version the single source the
  release tag and the cask will take, and adds whatever check keeps the two from
  disagreeing.
- What four evidence documents defer to this stage, all of it the same gap:
  `resident-app-vm.md` ("No quarantine, and Gatekeeper is off in the golden"),
  `signed-app-provider-vm.md` ("Left for `release-acceptance-handoff-k11`" — a
  notarized build, a quarantined same-team plugin, `dlopen`),
  `accessibility-status-and-consent-vm.md` and `grant-enrollment-vm.md` (both:
  "Gatekeeper assessments are disabled in the golden image and the route sets no
  quarantine attribute").
- `scripts/vm-verify-lib.sh` (`launch`) and `scripts/vm-verify.sh` are the route
  a clean-VM run takes today.

## Done when

- **`task app:notarize`** submits the built bundle with `xcrun notarytool
  submit --wait`, staples the ticket, and verifies it. The credential is a
  stored keychain profile named by `KOINE_NOTARY_PROFILE`, defaulting to
  `koine-notary` — overridable, with **no fallback**, exactly as
  `signing-env.sh` treats the signing identity. A missing profile fails the task
  with the `xcrun notarytool store-credentials` command the human must run,
  naming the App Store Connect API key (Issuer ID, Key ID, `.p8`) it expects. It
  never degrades to an unnotarized artifact.
- **`task app:verify` covers the ticket**: `stapler validate` passes and
  `spctl --assess --type execute` accepts the bundle on its own merits, not
  because assessments are disabled.
- **The version is one value.** The tag, the release artifact name and the cask
  all derive from `CFBundleShortVersionString`; a check catches the two version
  keys drifting apart or a build whose version does not match what is being
  released.
- **A Gatekeeper-enforcing VM run** (`task app:vm-verify-notarized`,
  `scripts/vm-verify-notarized.sh`) shows, on a clone whose assessments are
  **enabled**, with the bundle carrying `com.apple.quarantine`:
  - first launch succeeds with no right-click-Open and nothing stripped;
  - `spctl -a -vv` reports `accepted` with `source=Notarized Developer ID` —
    not `override=security disabled`;
  - the Accessibility consent dialog names **Koine**, closing
    `accessibility-status-and-consent-vm.md`'s attribution item on a notarized
    build;
  - a **quarantined** same-team fixture provider placed in the per-user root is
    approved and `dlopen`ed, closing `signed-app-provider-vm.md`'s first
    deferred item; and the bundled desktop provider loads from
    `Contents/PlugIns`, closing its second.
- **`docs/verification/notarized-release-vm.md`** records the run in the shape
  the other evidence documents use, including its own "what this does not show".

## Notes

**Getting the clone to enforce Gatekeeper is this leaf's real unknown, and it is
load-bearing.** The golden reports `spctl --status` as `assessments disabled`,
and `spctl --global-enable` is restricted on recent macOS — it may need
`csrutil`, a recovery boot, or a fresh golden built with assessments left on.
Find out early. If it cannot be done, **stop and ask the human** with a
recommendation and the evidence; do not quietly re-run on the disabled golden,
because that produces a document that says exactly what the four existing ones
already say. Setting the quarantine attribute is the easy half: `testanyware
file upload` sets none, so set `com.apple.quarantine` explicitly in the guest
after upload, and assert it is present *before* launching.

**The notary profile does not exist on this machine yet.** The human chose an
App Store Connect API key and will create it; if the profile is still missing
when this leaf runs, say so plainly with the exact `store-credentials`
invocation and treat it as a blocker, not a reason to skip notarization.

**Notarization is a network round trip to Apple** and takes minutes, sometimes
longer. Submit once and wait; do not poll a submission you launched in the
background and infer completion from the launcher returning. If a submission is
rejected, `xcrun notarytool log <id>` gives the reason — the likely ones here are
an unsigned nested binary and a missing secure timestamp, both of which are
`build-app.sh`'s to fix, and either is a finding worth recording.

**Do not weaken the entitlements to make something pass.** `App/Koine.entitlements`
is deliberately empty — the hardened runtime with no exceptions — and
`signed-app-provider-vm.md` records that same-team plugins pass library
validation without one. If notarization or `dlopen` appears to need an
exception, that is a finding against an earlier stage and a question for the
human, not an edit to that file.

**The host rule binds**: this all happens in a TestAnyware VM. Building,
signing and notarizing on the host is fine; launching Koine is not.

## Decisions (running log)

**The notary keychain profile still does not exist, and this leaf is blocked on
it.** `xcrun notarytool history --keychain-profile koine-notary` answers "No
Keychain password item found for profile: koine-notary". Nothing here degrades
to an unnotarized artifact, so `task app:notarize` is written to fail with the
exact `store-credentials` invocation, and the Gatekeeper-enforcing VM run —
which needs a notarized, stapled bundle to assess — cannot be performed this
session. Xcode 27.0 supplies notarytool, so the tooling half is ready.

**A clone can be made to enforce Gatekeeper, but "enforcing" is two switches,
not one — and only the first has a CLI.** `spctl --status --verbose` reports
them separately. On a fresh `testanyware` macOS clone (macOS 26.5, arm64, SIP
enabled) `sudo spctl --global-enable` succeeds and flips the first: assessments
go from `disabled` to `enabled`, and the instrument was seen to work, not merely
to read clean — the existing unnotarized bundle went from unassessed to
`rejected / source=Unnotarized Developer ID` (rc=3), launching it raised the real
CoreServicesUIAgent block, and System Settings gained a "“Koine” was blocked to
protect your Mac" row with an Open Anyway button. Apple's restriction on recent
macOS is on *disabling* assessments, not on enabling them, so the leaf's stated
worry about `csrutil` and a recovery boot does not arise for this half.

**The second switch is the trap, and it would have produced silently worthless
evidence.** With assessments enabled the clone also reports `developer id
disabled` — System Settings' "Allow applications from: App Store", not the macOS
default "App Store & Known Developers". The policy database does hold the
`[Notarized Developer ID] P5 allow execute … and notarized` rules, but that
master switch gates them, so a *notarized* Developer ID bundle would be rejected
on this clone exactly as the unnotarized one was, and the block dialog says so in
as many words: "Your security settings allow installation of only apps from the
App Store." A run made in this state would have read `rejected` and proved
nothing about notarization — the same empty result the four existing evidence
documents already carry, reached by a different route.

**No CLI spelling flips the second switch on macOS 26.5.**
`spctl --developer-id-enable` is an unrecognized option; `spctl --enable --label
"Developer ID"` answers "This operation is no longer supported. Please see the
man page"; `--master-enable` and a repeated `--global-enable` leave `developer id
disabled` unchanged. `spctl --help` now documents only `--assess`, `--status` and
`--global-disable`. The remaining routes are the System Settings popup (driven in
the guest) and a golden rebuilt with the default posture left in place; this is
the open question handed back to the human.

**The version is one value, and the check was seen to fail before it was
trusted.** `App/Info.plist`'s `CFBundleShortVersionString` is the source;
`scripts/signing-env.sh` reads it and derives `RELEASE_TAG` (`v0.1.0`) and
`RELEASE_ARTIFACT` (`Koine-0.1.0.zip`) there rather than restating them, so the
tag, the artifact and the cask cannot disagree with the bundle. The two version
keys are held **equal** — the simplest rule under which "the version is one
value" is literally true and mechanically checkable — and the check fired on real
pre-existing drift the moment it was written (`CFBundleShortVersionString` 0.1.0
against `CFBundleVersion` 1), which is why `CFBundleVersion` is now 0.1.0.
`build-app.sh` re-checks the copy that ships and `verify-app.sh` checks the built
bundle against the source, both seen to fail against deliberately mutated
subjects. `LSMinimumSystemVersion` is deliberately untouched: narrowing the
deployment target is `support-matrix-and-latency-k44`'s.

**`task app:verify` now fails on an unnotarized bundle, with no opt-out.** It
checks `stapler validate`, then `spctl --assess --type execute -vv`, and rejects
two ways of passing that would mean nothing: an `override=` line (accepted only
because assessments are off) and any `source=` other than `Notarized Developer
ID`. The accepted trade-off is that the plain `task app` → `task app:verify`
loop now requires a notary round trip; that is what "it never degrades to an
unnotarized artifact" costs, and adding an escape hatch would reintroduce exactly
the silent unnotarized build the stage exists to rule out. If the human wants a
signature-only check for the inner loop, that is a decision to take, not a
default to assume.

**What this session could not do.** `task app:notarize` and
`scripts/vm-verify-notarized.sh` are written and `task app:vm-verify-notarized`
is wired, but **neither has ever been executed against a notarized bundle**,
because no notarized bundle can exist until the credential does. The VM script's
`enforce_gatekeeper` encodes both switches and fails loudly on the App Store-only
state rather than assessing under it. `docs/verification/notarized-release-vm.md`
is deliberately **not** written: there has been no run to record, and an evidence
document describing one would be a fabrication.

**The human chose the System Settings route for the second switch.** Offered
driving System Settings in the guest, rebuilding the golden with the default
posture left in place, or writing the policy database directly, the human chose
the first. So `enable_developer_id` in `scripts/vm-verify-notarized.sh` opens
Privacy & Security in the guest and sets "Allow applications from: App Store &
Known Developers" — the macOS **default**, and still strictly more enforcing than
the golden's assessments-disabled state — rather than the golden image changing
for every other VM run in this repo. The popup sits far below the fold, so the
pane's own search field brings the Security section into view instead of a
scroll to a coordinate: scrolling was tried in the probe VM and the accessibility
tree reported the control's position unchanged. `agent press` refuses these
controls with HTTP 400, the same refusal `vm-verify-lib.sh` already records for
Koine's own SwiftUI controls, so the element is found semantically and clicked at
its centre.

**That choreography is written but unverified, and it is fenced so it cannot lie.**
`enable_developer_id` ends by re-reading `spctl --status --verbose` and failing
unless *both* switches report enabled, so if the UI route is wrong the run stops
there instead of assessing under an App Store-only policy and recording a
`rejected` that says nothing about notarization. Two attempts to drive this by
hand in the probe VM were refused by the harness's permission classifier as
"Security Weaken", so the exact click path has not been executed once.

**The credential now exists and the bundle is notarized and stapled.** The human
created the App Store Connect API key and stored it as `koine-notary`;
`notarytool history` authenticates and shows the team has notarized before.
`task app:notarize` submitted 0.1.0 once and waited: submission
`f50a0c8d-eaf4-4094-90fd-a7cd02b70fc6`, **Accepted** on the first attempt. Neither
of the two failures the task file anticipated occurred — no unsigned nested
binary and no missing secure timestamp — so `build-app.sh`'s inside-out signing
of the framework, the desktop provider and then the sealing bundle is already
notarization-correct and needs no change. The ticket is stapled and the release
artifact is `.build/app/Koine-0.1.0.zip`, zipped after stapling so a downloaded
copy carries its ticket.

**`task app:verify` passes on merits, on a host that is itself enforcing.**
`stapler validate` succeeds and `spctl --assess --type execute -vv` reports
`accepted` with `source=Notarized Developer ID` and no `override=` line. This
host reports `assessments enabled` and `developer id enabled`, so the
`override=` rejection was a live test rather than a vacuous one, and the pair is
a worked example that both switches do hold together — which is the state the VM
clone has to be brought to.

**Reading the version in `signing-env.sh` broke four callers, and the fix is a
self-relative path.** The file was pure data — literals and environment
lookups — and reading `App/Info.plist` by the relative path `App/Info.plist`
silently gave it a dependency on the *caller's* working directory. The eleven
`scripts/*.sh` consumers all `cd "$(dirname "$0")/.."` first and were fine;
`Fixtures/FixtureProvider/seal.sh`, `build-variants.sh`,
`Fixtures/WindowIdentityProbe/build.sh` and
`Fixtures/ConsentPromptControl/build.sh` source it as `${HERE}/../../scripts/...`
and do not, so PlistBuddy found nothing, the version came back empty and the
shape check failed them for a value they never asked for — `task fixture`
exited 1 with no message, because seal.sh's failure was silent. `INFO_PLIST` is
now resolved from `${BASH_SOURCE[0]}`, and all four were exercised from foreign
working directories before this was believed. The general lesson is worth more
than the fix: the one place a fact is stated is sourced from more places than
its own directory, so it may read the tree only by its own location.

**The Gatekeeper-enforcing clone works unattended, and the first-launch dialog is
the evidence rather than an obstacle.** The recipe that runs: start the guest at
`1920x2160` (the "Allow applications from" popup sits ~1600pt down a pane that
does not scroll under `input scroll`, and the accessibility tree reports its
position in an unclipped layout space that does not move, so the only reliable
fix is a screen tall enough to contain it); `sudo spctl --global-enable`; then
the popup and its menu item clicked over VNC at their centres — `agent press`
refuses with HTTP 400, the menu opens into a window of its own, and the menu
bar's items are in the tree too with zero width, so the search is over every
window filtered to items that have a size; then an administrator password into a
sheet that is not a window of its own. On the notarized build the quarantined
copy is **accepted, `source=Notarized Developer ID`, no `override=`**.

A quarantined app gets a first-run dialog even when notarized, and *which*
dialog is the whole result: "“Koine” is an app downloaded from the Internet…
Apple checked it for malicious software and **none was detected**", with a
working **Open** button reached by a plain `open`, never right-click-Open. The
two refusals seen on this same golden while establishing the procedure — "Apple
could not verify" for an unnotarized build and "not downloaded from the App
Store" for the App Store-only posture — offer no Open button at all, which is
what makes this a discriminating check rather than one that accepts any dialog.

**Two measurement lessons, both of which produced a false red.** `screen
find-text` matches **within a line**: the headline wraps across "…an app
downloaded / from the Internet…", so a phrase spanning the break found nothing
while the words were plainly on screen, and OCR read the body as "Trom the
internet" besides. The dialog is now read from the accessibility tree, which
returns each static text whole. And `open` returns **-1712** for a quarantined
bundle rather than 0 — the dialog is blocking the launch it is waiting on — so
that error is the dialog appearing, not a failure to open.

**The bundled desktop provider loads under quarantine; this was probed
separately and is the load-bearing product fact.** With the per-user root empty,
a quarantined notarized Koine launches on the enforcing clone and its window
reports `desktop 1.0.0 Active`: the application's own notarization ticket covers
`Contents/PlugIns`, so Koine's own provider is not affected by any of the below.

**A quarantined, un-notarized same-team provider in the per-user root is refused
at `dlopen`, and that is the answer to a question, not a regression.**
`signed-app-provider-vm.md` deferred this as an open question in exactly these
words — "whether a quarantined, un-notarized same-team plugin still passes
`dlopen` is not shown here" — and the answer is that it does not. macOS shows
"“libFixtureProvider.dylib” Not Opened / Apple could not verify
“libFixtureProvider.dylib” is free of malware…" with **Move to Trash** and
**Done**. The fixture is signed by the same team but deliberately carries no
secure timestamp (`seal.sh` uses `--timestamp=none`) and is not notarized, so
this is Gatekeeper judging the plugin on its own, downstream of Koine's approval
record and team check. The leaf's "Done when" assumed this case would pass; it
does not, and what the acceptance case should therefore assert is a question for
the human rather than this leaf's to settle.

**The human settled both open questions.** Asked what the acceptance case should
assert, given that the deferred question's answer is a refusal, they chose to
**assert both outcomes**: the refusal as the answer, and then the same provider
loading once the quarantine attribute is cleared with nothing else changed —
which is what makes the refusal attributable to quarantine rather than to the
bundle, the team or the approval record. Asked where the product fact belongs,
they chose a **new leaf** rather than folding it into the documentation sweep or
leaving it in the evidence document, following the stage brief's rule that an
acceptance failure is a finding against an earlier stage and gets a leaf.
`provider-quarantine-rule-k47` is cut with `leaf-insert` **ahead of**
`documentation-and-handoff-k45`, so that sweep finds README and the spec already
consistent rather than having to be redone; `_release-acceptance.md`'s
decomposition now lists nine leaves.

**Correction: no clone ever died, and the instrument that said so was the wrong
one.** Three runs were attributed to a dead VM. A probe that watched the clone
through the whole episode shows `tart list` reporting it **running** and
`testanyware agent health` answering **true** at every five-second sample, while
`testanyware vm list` printed "Running clones: (none)" for that same clone. So
`vm list` is not a liveness instrument here, the guard built on it produced a
false "the clone died", and it aborted a run that was fine. Liveness is now read
from `tart list`'s state column — which is what the TestAnyware guidance says to
use — and only three consecutive misses fail the run. The real cause of the
hangs was the undismissed dialog below.

**The refusal does not merely fail the provider: it blocks Koine's startup, and
that is the finding that matters.** Measured directly on a live clone — Koine's
process running as pid 796, the "“libFixtureProvider.dylib” Not Opened" dialog on
screen, and **no `endpoint.json`** in its data directory minutes later, with
`ProviderStaging`, `Providers`, `grants.sqlite` and `instance.lock` all present.
Providers are `dlopen`ed while the service comes up, and macOS's refusal is a
modal dialog a person must dismiss, so the server never begins listening until
someone clicks **Done**. A user who downloads a third-party provider can
therefore stop Koine from starting at all, and the only clue is a system dialog
naming a `.dylib`.

This cost four acceptance runs, in two distinct ways. First the script waited for
the endpoint descriptor *before* dismissing the dialog — a deadlock that looks
exactly like a slow launch. Then, with the dismissal moved inside the wait, it
clicked **Done** once and latched: one click that lands too early leaves the
dialog standing and the service down, and the loop waits out its whole bound on a
dismissal that never happened. Driving the same live clone by hand settled it —
a single Done click dismissed the dialog and `endpoint.json` appeared within four
seconds — so the click works and it was the not-retrying that failed. The
dismissal is now attempted on every iteration while the dialog stands, and the
run asserts the block itself (process up, descriptor absent) rather than only the
dialog's text, so the evidence document reports something the run established.

`provider-quarantine-rule-k47` is written against the weaker fact and should be
strengthened: this is no longer only "document that authors must notarize", it is
"a refused provider takes the service down with it", which is a design question
about whether provider loading belongs on the startup path at all. That question
is the human's, and k47's notes already forbid resolving it inline.

**Clearing quarantine on the installed provider does not make it load, and the
reason is Koine's own staging.** The run establishes this rather than inferring
it. Koine stages each provider under a digest of its **content**; removing an
extended attribute does not change content, so the digest is unchanged, the
directory staged during the first launch is reused, and the copy that gets
`dlopen`ed is still the quarantined one. The proof is the value itself: the
staged copy carries the **identical** timestamp and UUID the run wrote onto the
installed bundle (`0181;6aafa89d;Safari;C50BD7B4-…`), so it was inherited at
staging time, not applied afresh by Koine's process. The staged tree is also
read-only — `xattr -d` on it answers `Permission denied` for every file — so a
user cannot clear it there either. Deleting the staged directory so Koine
re-stages from the cleared source is what actually works, and the run now does
exactly that, with nothing else changed.

The corollary is the part worth carrying into `provider-quarantine-rule-k47`:
**the install-time workaround everyone reaches for first does not work.** Having
an approval UI clear `com.apple.quarantine` on the bundle it installs is not
sufficient on its own; it must also invalidate the staged copy, or Koine must
strip the attribute when staging. The alternative — and the one the bundled
desktop provider demonstrates working — is that the provider be notarized: it is
staged from a quarantined application and loads anyway, because the application's
ticket covers it.

**Two of my own assertions were wrong, not the product.** Providers are
`dlopen`ed from Koine's content-addressed staging copy rather than from the root
they were found in — which `signed-app-provider-vm.md` already records for the
per-user root and which holds for `Contents/PlugIns` too — so asserting the
desktop provider's image came from `Contents/PlugIns` failed against correct
behaviour. And Koine reports the refusal properly: `fixture` is `REJECTED` with
the full loader diagnostic ending "library load disallowed by system policy",
which is better behaviour than the leaf assumed and belongs in the evidence.

**One more self-inflicted failure worth recording, because its symptom lied.**
`enable_developer_id` ended by `unset`ting `SNAPSHOT_DEPTH` instead of restoring
it. Under `set -u` the redefined `snapshot` then aborted inside the subshell
`element` runs it in, and because every caller is a retry loop the failure
surfaced as "the management window did not appear" — twice — rather than as an
unbound variable. The tell was in the artifact rather than the logic: the failure
screenshot showed the window present and fully rendered. A timeout whose own
evidence contradicts it is not a timeout. The depth now carries its default
inside the expansion as well as in the assignment.
