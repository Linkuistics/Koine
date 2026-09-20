# Latency and supported matrix

Two release acceptance items of `docs/specs/machine.md`. From "Test seams and
acceptance": *"Measure warm query-to-choices and selection-to-focus latency in the
real keyboard workflow, reporting machine, OS, application and observed
distribution. Residence is not evidence of meeting a numeric latency target."*
And from "Application composition and availability", the supported OS/CPU matrix,
stated from what ran.

**This is a report, not a target.** It introduces no numeric latency target and
passes or fails on no duration: the run fails only when the workflow it measures
did not happen. That Koine is resident is not offered as evidence of any number.

## The supported matrix

**macOS 26 on Apple Silicon (arm64).** Nothing else is claimed.

| What ran | OS | Architecture |
|---|---|---|
| Every TestAnyware VM verification, this latency run included | macOS 26.5 (25F71), a clone of `testanyware-golden-macos-tahoe` | arm64, `Apple M4 Max (Virtual)` |
| The host-side suites: `task test`, `task compat` | macOS 26.6.2 (25G83) | arm64, Mac16,5, Apple M4 Max |

The matrix was chosen by the human when release acceptance was planned. The only
golden image is macOS 26 on arm64, and Intel cannot be virtualized on Apple
Silicon at all, so an x86_64 claim would be unfalsifiable here rather than merely
untested. Offered a second, older golden image or a matrix distinguishing
"verified" from "declared", the human chose to narrow the claim to what can be
run.

**The declared deployment target was narrowed to match**, from macOS 13.0 to
26.0, and the change is a change to a published claim, so it is in the spec's
prose rather than only in a plist:

| Site | Now | How it is kept |
|---|---|---|
| `App/Info.plist` `LSMinimumSystemVersion` | `26.0` | **The source.** `scripts/signing-env.sh` reads it as `MINIMUM_OS`. |
| `Providers/DesktopProvider/build.sh` compiler target | `-target arm64-apple-macos26.0` | Derived from `MINIMUM_OS`. |
| `Providers/DesktopProvider/manifest.json` `minimumOS` | `@MINIMUM_OS@`, substituted at build | Derived from `MINIMUM_OS`. |
| `Package.swift`, `ProviderAPI/Package.swift` | `platforms: [.macOS(.v26)]` | Checked. |
| `ProviderAPI/Info.plist` `LSMinimumSystemVersion` | `26.0` | Checked. |
| `docs/specs/machine.md`, `README.md` | "requires macOS 26 or later on Apple Silicon" | Checked. |
| The assembled bundle: its `Info.plist`, the Mach-O `minos` of the executable, the framework and the desktop provider, and the bundled provider's manifest | `26.0` | Checked, when a bundle is built. |

The provider's compiler target and manifest are derived rather than checked
because they cannot be allowed to disagree even for one build: the loader refuses
a provider whose binary is built for a newer OS than its manifest declares
(`Sources/KoineProviderLoader/ProviderLoader.swift`), so raising one without the
other would make Koine refuse its own bundled provider. Everything that cannot be
derived is compared against the source by `scripts/check-minimum-os.sh` —
`task check:minimum-os`, and on the release path `task app:verify` — which finds
every `Package.swift` in the tree rather than naming two. **It has been seen to
fail:** each of the six source sites was mutated in turn and produced its own
named error and exit 1, and the unmutated tree is clean. Before the bundle was
rebuilt it also failed on all five of the bundle's sites, which is the check
catching a stale bundle rather than a stale source.

The test fixtures — `Fixtures/FixtureProvider`, `Fixtures/WindowIdentityProbe`,
`Fixtures/ConsentPromptControl` — still compile for macOS 13.0, deliberately.
Their declared minimums are the *subject* of the loader's checks (the variants
span 12.0, 13.0 and 99.0), not a statement of what Koine supports, and
`ProviderLoaderTests` expects "was built for macOS 13.0" of one of them.

What the narrowing dissolved — x86_64 and universal binaries, macOS 13 to 25,
`libswiftCompatibilitySpan`, a different compiler on each side, older framework
minors — is recorded as out of scope, with the reason for each, in
[binary-compatibility.md](binary-compatibility.md), together with the one item it
did not dissolve.

## Procedure

```sh
task app                    # build and sign .build/app/Koine.app
task check:minimum-os       # every site agrees with App/Info.plist's floor
task app:vm-verify-latency  # scripts/vm-verify-latency.sh; KOINE_LATENCY_CYCLES=8
```

The run installs the signed bundle in a clean clone, creates **one** grant in
Koine's window with `desktop:read` and `desktop:control` — what a real switcher
client holds — opens two Finder windows with the same title and a TextEdit
document, and gives Koine Accessibility consent in System Settings.

**The workflow is a switch, taken the way a user takes it.** The user is working
in one window, a switcher lists an application's choices, the user picks one, and
that window takes focus; the next switch starts from where the last one landed.
The run drives a fixed rotation of six such switches between Finder's windows A
and B and TextEdit's document T — T→A, A→B, B→T, T→B, B→A, A→T — so each cycle
has four `cross-application` switches, where the target's application is not
frontmost, and two `same-application-window` switches, where it is and another of
its windows has focus. Between switches the user works in the window the last
one landed on, with real keystrokes: typed characters in the document, arrow-key
navigation in Finder. That is what makes this the keyboard workflow and not a
loop over the API.

Each switch is one run of `scripts/vm-verify-latency-client.py` in the guest,
which prints one JSON sample:

1. It opens a keep-alive connection to the endpoint the descriptor names and
   sends one unmeasured request on it.
2. It asserts the state **before** acting: the window-server id the probe reports
   as focused must be the one the last switch landed on. A switch that starts
   anywhere else is not the switch it claims to be, and the sample refuses.
3. It captures the target application's process identity (`pgrep`, then
   `proc_pidinfo` for the start instant), as a client captures it at interaction
   start.
4. **query-to-choices**: `DesktopChoices` for that process, sent with the text
   `docs/design/desktop-operations.graphql` has for it; timed from the request to
   its whole response parsed.
5. It confirms the target reference is among the choices that response listed —
   the selection comes out of the query, not out of the run's memory.
6. **selection-to-focus**: `FocusDesktopWindow` on that reference; timed from the
   request to the receipt parsed.
7. It reads, with the probe, which window has focus, and the run fails if it is
   not the target.

Both durations are taken on the guest's monotonic clock in the process that makes
the request, around that request alone.

**What "warm" means here, and how the run makes it so rather than assuming it:**

- **The connection is open.** Every measured request is on a connection that has
  already carried one, so neither pays for the TCP handshake.
- **The application has been resolved and its windows listed in this run of
  Koine**, so the provider's observation state for it exists. Before any switch,
  each of the three windows is focused once, untimed, to learn its window-server
  id; then the first two switches, T→A and A→T, are marked warm-up and never
  counted, so the first measured query of each application is never a counted one.
- **Koine has been running** since its launch, with consent given and the grant
  made; nothing about its process is cold.

A cold login and a crash are separate availability cases
([release-acceptance-vm.md](release-acceptance-vm.md) covers login launch) and
are not measured here.

**Not counted in either duration**, and reported beside them so a reader can add
them if they choose: the process-identity capture of step 3, and the probe's read
of step 7.

**selection-to-focus ends at the receipt, and the receipt is the focus landing,
not a proxy for it.** The provider returns it only after the target application
reports itself frontmost with that element as its focused window
(`Providers/DesktopProvider/Sources/DesktopProvider.swift`, `focus`); step 7 then
confirms it again from outside Koine. The provider checks that condition
immediately after acting and then every 50 ms (`focusPoll`) up to three seconds,
so a selection-to-focus that did not land on the first check is quantized to
roughly 50 ms steps. That is a property of the provider's wait, not of the
transport, and it shapes the distribution below.

**The state is asserted before the act because TestAnyware repeats commands.**
The agent reports about half of all guest execs as "Process timed out after 30s"
after they have run, and the run's `guest()` retries them. A repeated switch finds
its own target already focused and refuses at step 2; the run then puts the
workflow back with an untimed focus of the window the switch starts from, which is
recorded, and makes the switch again. The lost first run's timing is never seen by
anything. Because the fault is the agent's and is independent of a request that
takes milliseconds, discarding those runs does not select on latency.

## Observed

Run of 2026-09-21; transcript `.build/vm-verify/latency-20260921T160408.log`,
samples beside it in `latency-20260921T160408-samples.jsonl`. **PASSED**, exit 0.

| | |
|---|---|
| Guest | macOS 26.5 (25F71), arm64, `Apple M4 Max (Virtual)`, 4 CPUs, 8 GiB, 1920×1080; a clean clone of `testanyware-golden-macos-tahoe` under tart, TestAnyware 2.1.0 |
| Host | Mac16,5, Apple M4 Max, macOS 26.6.2 (25G83) |
| Application under test | `Koine.app` 0.1.0 at the macOS 26.0 floor, Developer ID signed, hardened runtime, **not notarized** (below); its bundled desktop provider |
| Applications driven | Finder, two windows titled `Recents` (window-server ids 52 and 51); TextEdit, `latency-target.txt` (58) |
| Client | Python 3 in the guest, one keep-alive loopback HTTP connection per switch, one grant with `desktop:read` and `desktop:control` |

Of 75 samples recorded, 48 were counted, 2 were the warm-up and 25 were refusals.
**Every one of the 25 found that switch's own target already focused** — a
TestAnyware repeat of a switch that had already happened, as described above —
and none found any other window. Every counted switch ended with the probe
reading the target focused.

Milliseconds; nearest-rank percentiles, so every figure is a sample that was
actually taken; no mean is reported.

**query-to-choices**

| | n | min | p50 | p75 | p90 | p95 | max |
|---|---:|---:|---:|---:|---:|---:|---:|
| cross-application | 32 | 2.8 | 3.7 | 4.2 | 5.1 | 5.3 | 5.5 |
| same-application-window | 16 | 3.9 | 4.3 | 4.6 | 5.2 | 5.3 | 5.3 |
| all | 48 | 2.8 | 4.0 | 4.5 | 5.1 | 5.3 | 5.5 |

**selection-to-focus**

| | n | min | p50 | p75 | p90 | p95 | max |
|---|---:|---:|---:|---:|---:|---:|---:|
| cross-application | 32 | 56.1 | 59.3 | 60.3 | 61.0 | 64.4 | 100.9 |
| same-application-window | 16 | 19.4 | 21.6 | 23.4 | 27.5 | 32.7 | 32.7 |
| all | 48 | 19.4 | 58.3 | 59.6 | 60.8 | 61.6 | 100.9 |

Beside them, not part of either: capturing the process identity took 8.1–11.4
(p50 10.0), and the probe's read after the receipt 15.9–27.9 (p50 19.6).

What the distribution says, read against how it was produced:

- **query-to-choices is a few milliseconds and scales with what it lists.** A
  TextEdit query (one window) took 2.8–3.7; a Finder query (three windows,
  32 samples) 3.9–5.5.
- **selection-to-focus has two modes, and they are the provider's poll, not the
  applications.** A switch between two of Finder's windows landed in 19–33 ms: the
  focus was already there at the provider's first check, straight after acting. A
  switch to another application landed in 56–65 ms in 31 of 32 samples: not yet
  frontmost at the first check, done at the second, one `focusPoll` (50 ms) later.
  The one 100.9 ms sample took two polls. So the cross-application figure is an
  upper bound set by the poll interval — the focus landed somewhere within the
  50 ms before the check that saw it — and a shorter poll or a notification-driven
  wait would move it; nothing in the spec asks for either.
- **The re-established switches look like the rest.** 14 of the 48 counted
  switches came straight after an untimed re-establish rather than after
  keystrokes. The 34 that followed keystrokes alone give the same medians (3.5 and
  4.3 for query-to-choices, 59.3 and 21.6 for selection-to-focus by class) and the
  same tails.

The per-sample record — class, the window each switch started from and landed
on, the number of choices and both durations, in the order taken — is printed at
the end of the transcript by `scripts/latency-report.py --per-sample`. A re-run is
compared against that record item by item, not against these totals.

**The run's subjects did not move.** SHA-256 before and after, identical: the
bundle's `Info.plist`, executable, framework image, desktop provider image and
manifest; `docs/design/desktop-operations.graphql`; the run's three scripts and
the two libraries and client they use; `scripts/signing-env.sh`; and the probe's
source and binary. The three signed images were:

```
670f9008193d1261cc166014c754e78f46e7decf43534555e5b7da395b24e604  Contents/MacOS/Koine
50397227c9c876e98dafe53369023ecd7a2851753c20948c4435d83c5b88a278  …/KoineProviderAPI.framework/Versions/A/KoineProviderAPI
d0b58d69f43ba1cd07bc68dc4aac295d837aea551ed006abe9ed319f4d72f42e  …/Desktop.koineprovider/libDesktopProvider.dylib
```

## What this does not show

- **Bare metal.** This is macOS virtualized by tart on Apple Silicon, with four
  virtual CPUs, sharing its host with nothing else the run started: no build ran
  on the host while it measured. The distribution is what this VM observed, not
  what a user will see.
- **A target.** None is set, and none is implied by the figures being small.
- **Cold latency.** The first resolution of an application and the first focus of
  a window are in the two warm-up switches and are not reported; a login launch or
  a crash is an availability case.
- **The client's own part of the workflow.** A switcher's hotkey, its palette and
  its drawing are ModalAnyware's. What is measured is Koine's part, from the
  client's side of the loopback connection, including the client's own encoding
  and parsing of JSON.
- **Other applications, or many windows.** Finder and TextEdit, three choices at
  most. An application with many windows lists more and was not measured.
- **The notarized bundle.** The bundle was rebuilt when the floor was narrowed,
  which discards its stapled ticket, and on the day of the run the notary
  credential `koine-notary` was absent from this machine's keychain, so it could
  not be notarized again. The human chose to measure the signed build rather than
  wait. Notarization staples a ticket and cannot alter a code-signed image, so it
  changes no warm request; the three image digests above are what the notarized
  0.1.0 bundle must still carry, and comparing them is how to check that it does.
  Restoring the credential is the human's step, and `homebrew-distribution-k46`
  needs it to publish the release artifact at all.
- **The evidence recorded earlier on the old floor's bundle.** The notarized
  0.1.0 bundle the release acceptance documents before this one cite was built at
  `minos 13.0`. Narrowing the floor changed its images' `minos` and nothing in
  their code, but it is not byte-for-byte the bundle those documents ran.
- **Every macOS 26 minor.** The floor is declared at the major, as the human chose
  the matrix. What ran is 26.5 in every VM and 26.6.2 on the host; nothing ran on
  26.0 to 26.4. Declaring 26.5 would refuse users there on the strength of an
  absence of evidence rather than a failure.
- **Another architecture, another OS, another machine.** One Mac, one arm64 VM
  image; see [binary-compatibility.md](binary-compatibility.md) for what the
  matrix puts out of scope and the one item it does not dissolve.
