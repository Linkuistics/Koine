# Launcher applications: VM preparation

Preparation for the "Twelve launchers" row of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md) and for every
later increment that reuses the same applications (Dia as the alternate default
browser, Zed for settings and documents, the terminal and messaging launchers).
It is **preparation, not acceptance**: it leaves a reusable image in which each of
the twelve named launchers is installed from its normal distribution and has been
opened once past Gatekeeper and its first-run UI, without signing in to anything.
Launching them from Koine, activation, identity and callback latency belong to the
acceptance that consumes this image (`launchers-vm`). Nothing here runs an
application on the host.

## Procedure

```sh
task launchers:prepare     # scripts/vm-prepare-launchers.sh prepare  (about 40 minutes)
task launchers:verify      # scripts/vm-prepare-launchers.sh verify   (about 15 minutes)
task launchers:inventory   # re-read the image into .build/launcher-apps/inventory.json
```

`prepare` clones the platform golden image at `1920x2160` (as
[notarized-release-vm.md](notarized-release-vm.md) needs for the Security pane),
puts Gatekeeper into the enforcing posture (`assessments enabled`, `developer id
enabled`), installs, restarts the guest, drives each first run, and keeps the result
as the tart image **`koine-launchers-prepared`** (`KOINE_LAUNCHERS_IMAGE`
overrides). A later run starts clones of it with
`testanyware vm start --platform macos --base koine-launchers-prepared`, or through
`KOINE_VM_BASE` in the `vm-verify-lib.sh` scripts. The golden image is never
modified. `.build/launcher-apps/inventory.json` is the inventory the run writes
(a copy of the passing run's is kept at
[launcher-apps/inventory.json](launcher-apps/inventory.json), with the first-run
record in it as `firstRunActions`); `.build/vm-verify/launchers-*.log` are the
transcripts, and each application's settled first-run screen is kept beside them as
a PNG.

| File | Role |
|---|---|
| `scripts/launcher-apps.json` | The catalogue: the twelve applications, their distribution, the buttons their first run asks, and where it stops |
| `scripts/vm-launchers-install.py` | Runs in the guest: `brew update`, the casks, the vendor download, quarantine, cleanup |
| `scripts/vm-launchers-inventory.py` | Runs in the guest: the inventory, read from the bundles and the system's own tools |
| `scripts/vm-launchers-lib.sh` | Sourced: answering dialogs, quitting, the default browser, the pending copy, the restart |
| `scripts/vm-default-browser.swift` | Compiled in the guest: reads, and asks the system to change, the default browser |
| `scripts/vm-prepare-launchers.sh` | The recipe: `prepare`, `verify`, `inventory` |

**The first run is driven, not scripted blind.** Every dialog is read from the
accessibility tree (`testanyware agent snapshot`), answered only by a narrow rule
that matches its owner and its button label, and written down as it is answered
(`firstRunActions` in the inventory). A dialog no rule matches is left alone, and an
application that has a window but still shows a button like OK, Cancel or Continue
fails the run, so a window merely being present cannot hide an unanswered question
(that is how Notes' "Turn On iCloud" offer was found). No rule signs in, types an
email address, starts a trial or accepts a purchase. The global rules are Gatekeeper's
**Open**, a system permission request's **Don’t Allow**, and the Accessibility
(events) request's **Deny**.

## Distribution

Ten applications are downloaded and two ship with macOS. A download arrives
quarantined (`com.apple.quarantine`, flags `0181`: downloaded, never opened), which
is the state Gatekeeper's first-open dialog exists for; Homebrew writes it itself
(agent `Homebrew Cask`), and for the one vendor download the recipe writes it as a
browser does.

| Application | Source | Quarantine agent |
|---|---|---|
| Dia, ChatGPT, Claude, Zed, Visual Studio Code, Kimi, iTerm, Obsidian, Zotero | Homebrew Cask (`thebrowsercompany-dia`, `chatgpt`, `claude`, `zed`, `visual-studio-code`, `kimi`, `iterm2`, `obsidian`, `zotero`) | Homebrew Cask |
| Jump Desktop | the vendor's download, `https://jumpdesktop.com/downloads/jdmac` | written by the recipe (Safari) |
| Mail, Notes | macOS | none |

**Jump Desktop is not installed from its cask.** `brew install --cask jump-desktop`
installs 9.1.9 (build 90109, the April 2025 download). On macOS 26.5 it aborts within
a second of launching, every time: `abort()` from an Apple Event handler after an
`NSInternalInconsistencyException` assertion in `NSTitlebarAccessoryViewController.m`
(crash report `Jump Desktop-2026-10-01-044657.ips` in the guest). A launcher that
cannot start is not an installed launcher, so the recipe takes the vendor's own
current download, which runs (10.15.31.0). It is the redirecting `jdmac` link that the
vendor's download page uses, so the version moves with the vendor; the inventory
records what was actually installed. The application runs as a 14-day trial: it shows a
"Start trial or buy now!" banner, needs no account for that, and the trial clock
started when the image was prepared.

**The golden image's Homebrew is months old** (6.0.3 in the golden; 7.0.7 after
`brew update`), and its casks point at downloads the vendors have withdrawn: Dia's
was a 404. The recipe runs `brew update` first.

## What each application's first run needed

Each row is from the recorded `firstRunActions`; "stops at" is where first run ends
without an account, as the settled screenshot shows. Every application also raised
Gatekeeper's **Open** unless stated.

| Application | Needed GUI action | First run stops at |
|---|---|---|
| Dia | Open; microphone request declined | an intro film, then "Welcome to Dia" asking for a work email. Never filled in: that is the account gate. |
| ChatGPT | Open | "Sign in to ChatGPT" |
| Claude | Open | a sign-in window |
| Zed | Open | an empty-project window |
| Visual Studio Code | Open | the Welcome tab |
| Jump Desktop | Open; a permission request declined | an empty computer list with the trial banner |
| Kimi | Open; a permission request declined; Accessibility (events) denied | a log-in sheet. **Kimi asks for Accessibility again within seconds of every Deny**, for as long as it runs; the recipe answers it once and treats its return as the application's behaviour, not an onboarding step. |
| iTerm | Open; a permission request declined; **"Check for updates automatically?" answered Don’t Check on its second launch** | a shell window. iTerm asks the update question only from the second launch on, so its first run is two launches. Quitting asks to confirm with a session open, and that is answered at quit. |
| Mail | none | the read-only inbox behind an **Add Account** sheet. The sheet returns on every launch; its Cancel **quits Mail**, so it is the resting state, not a step. |
| Notes | the welcome sheet's Continue, then the **Turn On iCloud** offer declined with Cancel | an empty notes window |
| Obsidian | Open | the vault chooser (Create / Open / Sign in) |
| Zotero | Open | the library window. **It also opens its welcome page in the default browser**, which starts Safari; the recipe quits Safari afterwards. |

No account, purchase or credential was supplied. The default-browser exercise below
is the only other GUI action.

## Gatekeeper, and a finding about when first runs count

Assessments are enabled and `developer id` is enabled in the image: all ten
downloads are assessed `accepted`, `source=Notarized Developer ID`, and Mail and
Notes `source=Apple System`. After the first run each download's quarantine flags are
`01c1` (the user-approved bit, `0x40`, is set); Mail and Notes carry none.

**A first run made in the boot that did the installing approved nothing that lasted.**
Zed's cask runs the application's own command-line tool while installing (its
postflight tried to write PowerShell completions and failed with `Operation not
permitted @ dir_s_mkdir - /opt/homebrew/share/pwsh`; the install still succeeded). In
that boot Zed then opened with **no Gatekeeper dialog** and its quarantine flag
stayed `0181`. A fresh clone of the saved image raised the dialog the first time Zed
opened. The cause is not established (this evidence does not show Gatekeeper's cache),
but the recipe now **restarts the guest after installing and before the first runs**,
and in the prepared image every download is approved, the verify run's launches
raised no dialog, and Zed's first run answered Open after the restart. The verify
run's strictness (below) exists because of this: a first run that merely opens is not
evidence the next boot will.

## The pristine quarantined copy

The Gatekeeper-pending case needs an application whose dialog is outstanding. The
image carries one, apart from the approved set: **`~/gatekeeper-pending/Obsidian.app.tar.gz`**
in the guest account, archived **before any first run** and never opened. It is a
tar archive because `ditto` zip archives drop `com.apple.quarantine` on extraction,
with or without `--qtn` (tried both). Extracting it with `tar -xzf` restores the
attribute: the verify run records `0181;…;Homebrew\x20Cask;…` on the extracted bundle,
the never-opened state. The approved `/Applications/Obsidian.app` remains separate;
extract the archive elsewhere to get the pending copy. Because it is a second bundle
with the same identifier, extract it only for the Gatekeeper case and remove it
after, so named-launch cases do not see two copies.

## The default browser

Safari is the default (`http` and `https` both resolve to
`/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app`,
`com.apple.Safari`; Safari's bundle is served from the Cryptexes volume, so a
client must not expect `/Applications/Safari.app` to be what the handler lookup returns). Dia can be made
the alternate: `vm-default-browser set /Applications/Dia.app` asks the system, which
raises *"Do you want to change your default web browser to “Dia” or keep using
“Safari”?"* and the change is made by answering **Use “Dia”**. The recipe does this
and back (**Use “Safari”**), and asserts both resulting handlers; it leaves Safari
the default. macOS offers no route that skips the confirmation. Only `http` is
set: setting `https` separately fails with `permErr` once `http` has been answered,
and the change to `http` moves both. `set_default_browser` in
`scripts/vm-launchers-lib.sh` is the reusable half for the browser-URL acceptance.

## The inventory

One passing preparation, transcript `.build/vm-verify/launchers-prepare-20261001T170432.log`
(macOS 26.5, 25F71, arm64; Homebrew 7.0.7). Everything is as the system reports it,
not as the catalogue expects:

| Application | Bundle identifier | Version (build) | Path | Team | Architectures | Min macOS |
|---|---|---|---|---|---|---|
| Dia | `company.thebrowser.dia` | 1.50.1 (87750) | `/Applications/Dia.app` | S6N382Y83G | arm64 | 14.0 |
| ChatGPT | `com.openai.codex` | 26.928.31416 (12553) | `/Applications/ChatGPT.app` | 2DC432GLL2 | arm64 | 13.0 |
| Claude | `com.anthropic.claudefordesktop` | 2.16120.0 | `/Applications/Claude.app` | Q6L2SF6YDW | x86_64, arm64 | 13.0 |
| Zed | `dev.zed.Zed` | 1.22.0 (20260930.150108) | `/Applications/Zed.app` | MQ55VZLNZQ | arm64 | 10.15.7 |
| Visual Studio Code | `com.microsoft.VSCode` | 1.140.0 | `/Applications/Visual Studio Code.app` | UBF8T346G9 | arm64 | 12.0 |
| Jump Desktop | `com.p5sys.jump.mac.viewer.web` | 10.15.31.0 (1001365) | `/Applications/Jump Desktop.app` | 2HCKV38EEC | x86_64, arm64 | 11.0 |
| Kimi | `com.moonshot.kimichat` | 3.2.15 | `/Applications/Kimi.app` | 2J9472RW75 | arm64 | 12.0 |
| iTerm | `com.googlecode.iterm2` | 3.7.3 | `/Applications/iTerm.app` | H7V7XYVQ7D | x86_64, arm64 | 13.0 |
| Mail | `com.apple.mail` | 16.0 (3864.600.51.1.1) | `/System/Applications/Mail.app` | none (Apple System) | x86_64, arm64e | 26.5 |
| Notes | `com.apple.Notes` | 4.13 (3146.121.7) | `/System/Applications/Notes.app` | none (Apple System) | x86_64, arm64e | 26.5 |
| Obsidian | `md.obsidian` | 1.13.7 | `/Applications/Obsidian.app` | 6JSW4SJWN9 | x86_64, arm64 | 12.0 |
| Zotero | `org.zotero.zotero` | 10.0.5 | `/Applications/Zotero.app` | 8LAYR367YV | x86_64, arm64 | 10.9.0 |

Two identifiers are not what the display name suggests, and a client that guesses
them fails: **ChatGPT is `com.openai.codex`** (the cask's download comes from OpenAI's
`codex-app-prod` path; the bundle is named ChatGPT.app but carries that identifier), and **Jump Desktop is
`com.p5sys.jump.mac.viewer.web`**, the non-App-Store build. Mail's identifier is the
lowercase `com.apple.mail`. The inventory also records the resolved real path, the
signing authority, Gatekeeper's verdict, the quarantine flags and agent, the default
browser, and the archive.

**Versions move.** The casks and the vendor link resolve to whatever is current when
`prepare` runs (Zed was 1.21.0 and Zotero 10.0.4 in a cask listing a day before they
installed as 1.22.0 and 10.0.5). An application's own updater can also change it
later, so the image is only as stable as its use: iTerm was told not to check, and the
others are expected to be opened for minutes, not days. Acceptance reads the
inventory it is run against; do not copy these versions elsewhere.

## Verification

The passing run is `.build/vm-verify/launchers-verify-20261001T173733.log`, against
the image the passing preparation kept. `task launchers:verify` starts a **fresh clone** of the saved image and, before it
launches anything:

1. asserts `assessments enabled;developer id enabled`;
2. reads the inventory again in the guest and compares the **stable** part
   (macOS and build, Gatekeeper state, default browser, the archive, and for each
   application its path, real path, identifier, version, build, team, Gatekeeper
   verdict, approval and quarantine agent) with the one preparation wrote:
   *The inventory of the clone matches the recorded one: 12 applications.*;
3. extracts the pending copy and requires the never-opened quarantine on it;
4. opens each of the twelve with **no dialog tolerated**: any Gatekeeper, permission or
   onboarding dialog fails the run. Kimi's recurring Accessibility request and iTerm's
   quit confirmation are the only answers that do not count, and are kept in the
   record. Each application must settle with a window of its own and no unanswered
   question on it, and be quit with Command-Q (a force-kill is recorded and fails the
   run).

The run ended *VERIFIED*: the clone's inventory matched, the pending copy extracted
with `0181` quarantine, and all twelve opened with no first-run dialog to answer (any
recorded answer was a recurring one or a quit-time confirmation) and quit on Command-Q. A re-read that agrees is
the evidence the saved image is what the run reported.
`task launchers:inventory` refreshes the document from the image without repeating
the preparation.

## Limits and what stays pending

- **Acceptance is not done here.** No launcher was launched by Koine, no activation
  was observed and no callback latency was measured; [launchers-vm.md](launchers-vm.md)
  does that against this image.
- **The Gatekeeper-pending timeout** is not exercised here, only prepared for;
  [launchers-vm.md](launchers-vm.md) holds the dialog open.
- **Nothing was signed in to.** Dia, ChatGPT, Claude, Kimi and Obsidian's sync have
  accounts, Jump Desktop a trial, Mail an account sheet. None of that was needed to
  launch, and no account-dependent workflow is in scope.
- **One macOS, one architecture, one sample.** macOS 26.5, arm64, one clone. The
  restart finding is one observation on one application and its cause is unexplained.
- **Versions change** (above) and Jump Desktop's trial clock is running.
- **Zotero starts Safari** at its first run; if a client's browser-URL case runs after
  an application first run, that is the order to expect.
