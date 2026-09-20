# support-matrix-and-latency-k44

## Goal

Measure warm query-to-choices and selection-to-focus latency in a real keyboard
workflow and report the distribution, and state the supported OS/CPU matrix from
what actually ran — narrowing the declared deployment target to match.

## Context

- The spec's "Test seams and acceptance", closing paragraph: "Measure warm
  query-to-choices and selection-to-focus latency in the real keyboard workflow,
  reporting machine, OS, application and observed distribution. Residence is not
  evidence of meeting a numeric latency target. A cold login/crash is a separate
  availability case."
- The spec's "Application composition and availability" currently says "It
  requires macOS 13 or later. The actual supported OS/CPU release matrix is a
  release acceptance item, not a claim that every macOS version has been
  verified." `App/Info.plist` carries `LSMinimumSystemVersion` 13.0 to match.
- **The human settled the matrix when this stage was planned**: macOS 26 on
  Apple Silicon, with the declared target narrowed to it. The reasoning is in
  `release-acceptance-handoff-k11`'s running log — the only golden is
  `testanyware-golden-macos-tahoe` on arm64, and Intel cannot be virtualized on
  Apple Silicon at all, so an x86_64 claim is unfalsifiable here rather than
  merely untested.
- `docs/verification/binary-compatibility.md`'s "Left for
  `release-acceptance-handoff-k11`" list is resolved by that decision rather than
  by work: x86_64 and universal binaries, macOS 13–25, a different compiler on
  each side, and distribution of older framework minors all become **out of
  scope, stated as such**. The two items on that list that are *not* dissolved by
  it — a second real signing identity, and the signed application — belong to
  `notarized-release-build-k39` and `platform-acceptance-k42`.
- `desktop-focus-vm.md`: "The latency of a focus is
  `release-acceptance-handoff-k11`'s, with the supported matrix; this run is
  macOS 26.5 on arm64 alone."

## Done when

- **Latency is measured in the real keyboard workflow**, not in a loop over the
  API: warm query-to-choices (resolve the captured process and list its windows)
  and selection-to-focus (submit the returned reference and observe the focus
  land), with enough samples to report a **distribution** — median and tail, not
  a mean — and with the state asserted before each act rather than after.
- **The report states machine, OS build, application under test and
  distribution**, and says plainly that it is a report and not a target. No
  numeric latency target is introduced, and residence is not offered as evidence
  of one.
- **The supported matrix is stated**: macOS 26 on Apple Silicon, from what ran,
  with the OS build recorded.
- **The declared target is narrowed to match**: `LSMinimumSystemVersion` in
  `App/Info.plist`, the Swift package's platform declaration, and the spec's
  "requires macOS 13 or later" all move together. A check or a note keeps them
  from drifting apart again.
- **The dissolved back-deployment items are recorded as out of scope** in
  `docs/verification/binary-compatibility.md` — replacing its "Left for
  `release-acceptance-handoff-k11`" list with what was decided and why, so the
  document does not go on implying open obligations that nobody intends to meet.
  `libswiftCompatibilitySpan` is worth a sentence: it is a toolchain
  back-deployment library the host links by `@rpath` and `/usr/lib/swift`
  supplies, and narrowing the target is what makes it a non-question.
- `docs/verification/latency-and-support-matrix.md` holds the measurement, the
  matrix, and its own "what this does not show".

## Notes

**Measuring is where the instrument lies most easily** (`references/execute.md`,
"The provenance of a measurement"). Finish every edit to the script and the
fixture, then measure; do not adjust anything mid-run. Record the digest of
every file the run reads. One measurement, one writer. And confirm a re-run
item by item, not by matching totals — two runs can agree on a total while
disagreeing about which sample did what.

**"Warm" has to be defined and then held.** Say what is warm — the provider's
observation state, the application already resolved once, the connection already
open — and make the script establish that state explicitly rather than relying
on a previous step having happened to leave it. A cold login or a crash is a
separate availability case and is not measured here.

**A VM's timings are a VM's.** Say so in the report: this is virtualized macOS
under tart on Apple Silicon, not bare metal, and the distribution is reported as
observed rather than as what a user will see. That limitation is honest and does
not undermine the report's purpose, which is to have a number at all.

**Narrowing the target is a contract change the human already approved** — it is
in the running log — but it is still a change to a published claim, so make it
visible in the spec's prose rather than only in a plist value.

## Decisions (running log)

**The narrowing runs before the measurement, and the bundle is re-notarized
between them.** The report is a report about the artifact that ships, and
narrowing the deployment target rebuilds that artifact. Measuring first would
describe a bundle the repository no longer produces, so the order is: narrow,
`task app`, `task app:notarize`, `task app:verify`, then one measurement run on
that bundle and no other.

**`platforms: [.macOS(.v26)]` is available in the toolchain in use**, verified
rather than remembered: a scratch manifest at `swift-tools-version:6.2` built
with Apple Swift 6.4 (swiftlang-6.4.0.34.1) dumps
`{"platformName": "macos", "version": "26.0"}` for `.macOS(.v26)`.

**The declared target lives in more places than the three the brief names, and
two of them are coupled by a runtime check.** The sites found by enumerating
every `macOS 13` / `.v13` / `13.0` token in the tree are `Package.swift:7`,
`App/Info.plist` (`LSMinimumSystemVersion`), `docs/specs/machine.md:38`,
`README.md:147`, `README.md:612`, `Providers/DesktopProvider/manifest.json`
(`minimumOS`) and `Providers/DesktopProvider/build.sh` (`-target
…-apple-macos13.0`). The last two cannot move independently:
`Sources/KoineProviderLoader/ProviderLoader.swift:226` rejects a provider whose
Mach-O `minos` is newer than its manifest's `minimumOS`, so raising the build
target alone would make Koine refuse its own bundled provider. They move
together, and the drift check is what keeps them together.

**Two more sites, and the build found them, not the grep.** `ProviderAPI` is its
own package: `ProviderAPI/Package.swift` declares the platform for the provider
framework, and `ProviderAPI/Info.plist` carries the framework bundle's
`LSMinimumSystemVersion`. Both still said 13.0 after the root package had moved,
and the framework image's `minos` stayed 13.0 — which is how it was noticed. The
first enumeration missed them only because its output was truncated at forty
lines, exactly the narrowing `references/execute.md` warns of. The re-run is
untruncated, and the check below now *finds* every `Package.swift` in the tree
rather than naming two, so a third cannot arrive unchecked.

**The fixtures stay at macOS 13.0, deliberately.** `Fixtures/FixtureProvider`,
`Fixtures/WindowIdentityProbe` and `Fixtures/ConsentPromptControl` compile at
`-target …-apple-macos13.0`, and `ProviderLoaderTests`' `understated-os` case
expects the diagnostic "was built for macOS 13.0". Those are test material whose
declared minimums are the *subject* of the loader's checks — the variants already
span 12.0, 13.0 and 99.0 — not statements of what Koine supports. Linking them
against the now-26.0 framework produces no linker warning and `task test` passes
179 tests, so nothing there is carried along by the narrowing.

**The drift check is `scripts/check-minimum-os.sh`, and it has been seen to
fail.** `App/Info.plist`'s `LSMinimumSystemVersion` is the one source;
`scripts/signing-env.sh` derives `MINIMUM_OS` from it, and
`Providers/DesktopProvider/build.sh` derives both its compiler target and the
`@MINIMUM_OS@` it substitutes into the provider manifest, so those two can no
longer disagree with each other or with the application. What cannot be derived —
both `Package.swift` files, `ProviderAPI/Info.plist`, and the sentences in
`docs/specs/machine.md` and `README.md` — is compared against it, along with the
assembled bundle's `Info.plist`, its three images' Mach-O `minos` and the bundled
provider's manifest. `task check:minimum-os` runs it and `scripts/verify-app.sh`
runs it on the release path. Each of the six source sites was mutated in turn and
watched to produce its own named error and exit 1, with the unmutated tree clean.

**The notary credential is gone from this machine, and the human chose to
measure without it.** Narrowing the floor rebuilt and re-signed the bundle, which
discards the stapled ticket, and `xcrun notarytool history --keychain-profile
koine-notary` then answered "No Keychain password item found" — the item is
absent from the login keychain, although `notarize-0.1.0.log` records a
successful Accepted submission on 2026-09-20. Offered a wait for the credential,
a run on the signed build, or a run plus a stop of the grove, the human chose the
signed build. The reasoning that makes it sound is recorded in the document:
notarization staples a ticket and cannot touch a code-signed Mach-O image, so it
changes no warm request latency, and the three image digests this run records are
what a later notarized bundle must still carry. Restoring the credential is the
human's step and `homebrew-distribution-k46` needs it regardless; the evidence
document says so where a reader of it will meet the question.

**The measurement's shape, settled before anything ran.** One grant with
`desktop:read` and `desktop:control`, which is what a real switcher client holds —
the reader/controller split belongs to `focus-exact-window-k30`, which had to
prove control alone suffices. The workflow is a rotation of six switches between
two same-titled Finder windows and a TextEdit document, each switch starting from
the window the last one landed on, with real keystrokes into that window in
between: typed characters in the document, arrow-key navigation in Finder. Two
classes are reported separately, because they plausibly differ:
`cross-application` (the target's application is not frontmost) and
`same-application-window` (it is, and another of its windows has focus).

**`selectionToFocus` is measured to the receipt, and that is the focus landing
rather than a proxy for it.** `Providers/DesktopProvider/Sources/DesktopProvider.swift`
returns the receipt only after polling until the target application reports
itself frontmost with that element as its focused window. The poll is 50 ms
(`focusPoll`), so the distribution above the first check is quantized at 50 ms —
a property of the provider, not of the network, and the report says so. The probe
reads focus again afterwards and that read is timed but never counted.

**Every sample asserts the window it starts from.** `--from-window` names the
window-server id the probe must report as focused, and a sample that finds
anything else measures nothing and says so. That is what makes the guest command
safe for TestAnyware to repeat after a false 30 s timeout — a repeat finds the
target already focused, refuses, and the run re-establishes the starting window
with an untimed, recorded focus. Refusals and re-establishments are in the record
and never in a counted number.

**`libswiftCompatibilitySpan` is gone from the host, observed rather than
argued.** Both `KoineCompatibilityHost` builds of 2026-09-19 (`minos 13.0`) link
`@rpath/libswiftCompatibilitySpan.dylib`; `Koine.app`'s executable rebuilt at
`minos 26.0` links nothing of the kind, and on macOS 26
`/usr/lib/swift/libswiftCompatibilitySpan.dylib` is a symlink to
`libswiftCore.dylib`. The first draft of the paragraph in
`binary-compatibility.md` said the host "links" it and the OS "supplies" it — true
of the old build only — and was corrected before it could be committed.

**The refusals in the run are TestAnyware repeats, and the design absorbs them
as intended.** Every refusal in the first cycles found that sample's *own target*
already focused (A → 52, B → 51, T → 58): the first exec made the switch, its
output was lost to a false 30 s timeout, `guest()` ran it again, and the repeat
refused. The lost run's timing is never seen by anything, and the switch is then
re-made from a re-established window and measured. The fault is the agent's and
is independent of a millisecond latency, so dropping those runs does not select
on the quantity being measured. A switch retried after a re-establish follows an
untimed Koine focus rather than keystrokes, so the document counts those apart,
with a one-off reader over the frozen samples — `scripts/latency-report.py` is
one of the run's digested subjects and is not edited while it runs.

**`task compat` waits until the VM run has finished.** It would re-verify the
pairs at the new floor, which is worth doing, but it builds two full trees on the
host CPU the VM is sharing while it measures latency.

**The floor is declared at the major, as the human decided, and the document
names the minors that actually ran.** What ran is macOS 26.5 (25F71) in every VM
and 26.6.2 (25G83) on the host for the host-side suites; nothing ran on 26.0–26.4.
Narrowing to 26.5 would follow the same "claim only what ran" reasoning one step
further, and SwiftPM can spell it (`.macOS("26.5")`), but the human's settled
matrix is "macOS 26", and a minor-level floor would refuse users on 26.0–26.4 on
the strength of an absence of evidence rather than a failure. It is not reopened;
it is stated in the document's "what this does not show" as a visible trade-off.

**The run and its reading.** `task app:vm-verify-latency` passed on the one run
made (`.build/vm-verify/latency-20260921T160408.log`), its fifteen subjects'
digests identical before and after: 48 counted switches, 2 warm-up, 25 refusals,
every refusal at that switch's own target. The distribution shows the provider's
50 ms poll plainly — same-application switches land at the first check (19–33 ms),
cross-application ones at the second (56–65 ms, one at 101 ms after two polls) —
so the cross-application figure is recorded as an upper bound set by the poll, not
cut as a leaf: the spec sets no target and asks for no faster wait. The 34
switches that followed keystrokes alone have the same medians and tails as all 48.
`task compat` then passed its 19 cases at the new floor, both compat hosts at
`minos 26.0` with no `libswiftCompatibilitySpan`, and `task test` passed 179 tests
on the final tree.
