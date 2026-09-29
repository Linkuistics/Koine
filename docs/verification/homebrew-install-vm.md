# Homebrew install on a Gatekeeper-enforcing VM

The published cask, installed the way a user installs it:
`brew install --cask linkuistics/taps/koine` on a clean clone whose Gatekeeper
assessments are **enabled**, downloading the tagged release from GitHub. The
run uses nothing built on the host. It shows that Homebrew's download arrives
quarantined, that Gatekeeper accepts it as notarized with nothing stripped, and
that Koine launches and serves. It then measures what Koine leaves behind after
a plain uninstall and after `--zap`, and the cask's `zap` stanza and the
README's "Installing" section are written from that measurement.
[notarized-release-vm.md](notarized-release-vm.md) is the same Gatekeeper
posture with a quarantine the script writes itself. Here Homebrew writes it.

## Procedure

```sh
task app:vm-verify-homebrew     # scripts/vm-verify-homebrew.sh
```

The clean clone, the transcript (`.build/vm-verify/homebrew-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md). The Gatekeeper-enforcing clone and
its `1920x2160` display are those of
[notarized-release-vm.md](notarized-release-vm.md), and the run asserts both
`assessments enabled` and `developer id enabled` before it installs anything.
Nothing runs the application on the host.

| Step | How | Expectation checked |
|---|---|---|
| Homebrew | used from the golden if present, otherwise installed unattended through `SUDO_ASKPASS` | `brew --version` answers |
| Install | `brew install --cask linkuistics/taps/koine` | `/Applications/Koine.app` exists and its `CFBundleShortVersionString` is this tree's version |
| Quarantine | `xattr -p com.apple.quarantine` on the installed bundle | present, as Homebrew wrote it |
| Assessment | `spctl -a -t execute -vv`, `stapler validate` | `accepted`, `source=Notarized Developer ID`, **no** `override=` line; the ticket validates |
| First launch | plain `open`, the first-run dialog's **Open** clicked | the dialog says Apple checked the app and found nothing; Koine writes its endpoint descriptor |
| Login launch | the window's login-launch toggle turned on | the status reads "Koine will start when you log in" |
| Plain uninstall | `brew uninstall --cask koine` with Koine running | Koine quits; `/Applications/Koine.app` is gone; the data directory remains |
| Reinstall | `brew install --cask` again | `/Applications/Koine.app` exists again |
| Zap | `brew uninstall --zap --cask koine` | the application is gone; nothing naming Koine remains under `~/Library`; no defaults domain remains |

Each of the three stages (running, after a plain uninstall and after `--zap`)
records four things:

- every path under `~/Library`, to depth 3, whose name contains `koine` or
  starts with `dev.antony.Koine`;
- whether cfprefsd has a `dev.antony.Koine` domain (`defaults domains`), since
  it can hold a domain it has not yet written to disk;
- Koine's saved window state, resolved by `scripts/vm-verify-saved-state.sh`;
- Koine's Background Task Management entry (`sudo sfltool dumpbtm`).

The run turns window restoration on for the account (`defaults write -g
NSQuitAlwaysKeepsWindows -bool true`) before Koine first launches. That is the
setting that makes AppKit save the most window state, so it measures the
largest footprint any user's setting produces.

## What this does and does not show

- **The cask is a real download, and Gatekeeper judges it as one.** Homebrew
  writes `com.apple.quarantine` with flags `0181` and the agent `Homebrew Cask`,
  which is the same shape a browser writes. The first-run dialog names Homebrew
  Cask as the downloader and reports that Apple checked the app. The cask has
  no `postflight` stripping the attribute, and none is needed.
- **Koine writes one file tree of its own: `~/Library/Application
  Support/Koine`.** It keeps no preferences. No `dev.antony.Koine` defaults
  domain exists at any stage, on disk or in cfprefsd. A plain uninstall leaves
  the data directory, and `--zap` removes it. The cask's `zap trash:` names that
  path and nothing else.
- **macOS keeps Koine's saved window state where no cask can name it.** On
  macOS 26, AppKit does not write `~/Library/Saved Application State/<bundle
  id>.savedState`. It writes `<uuid>.savedState` in talagent's container under
  `~/Library/Daemon Containers`, and `ApplicationMapping.plist` beside it maps
  Koine's signing identity (`dev.antony.Koine`, team `TA43A4RUP3`) to that UUID.
  The UUID belongs to the machine, so a `zap trash:` path cannot name it, and it
  survives both uninstall and `--zap`. With window restoration on, it holds
  `data.data` and `windows.plist` for the management window. With the
  setting at its macOS default (restoration off), a hand probe on another clone
  of the same golden found the directory present but empty.
- **The login-launch registration outlives the application.** Koine registers
  through `SMAppService.mainApp`, so its entry is Background Task Management's,
  not a System Events login item, and the cask's `uninstall` has no stanza that
  reaches it. After a plain uninstall and after `--zap`, the entry is unchanged:
  `Disposition: [enabled, allowed, notified]`, still naming
  `file:///Applications/Koine.app/`.
- **Homebrew's "Trashing files:" line lists what the cask declares, not what
  existed.** Homebrew 6.0.3's `uninstall_trash` prints each declared path whether
  or not a file was found there. The enumeration above is the evidence of what
  was removed. Homebrew's listing is not.
- **Tap trust does not stop an install by full name.** Homebrew 6 warns that
  `linkuistics/taps` is not trusted. It then trusts the one cask named in
  `brew install --cask linkuistics/taps/koine` and installs it, with no prompt.
- **This does not show** what the leftover login-launch entry does at the next
  login with the application gone, whether turning login launch off before
  uninstalling removes the entry, or whether a reinstall finds login launch
  already on. It is one OS build on one architecture, which is the whole of the
  supported matrix: [latency-and-support-matrix.md](latency-and-support-matrix.md).

## Evidence

Run of 2026-09-29, transcript `homebrew-20260929T195105.log`. The host was a
Mac16,5 (Apple M4 Max) on macOS 26.6.2 (25G83), running testanyware 2.1.0 and
tart 2.32.1. The cask was `Casks/koine.rb` in `Linkuistics/homebrew-taps`
at `7dd12d88`, installing release `v0.1.0` (`Koine-0.1.0-aarch64-apple-darwin.zip`,
SHA-256 `26b091d54af3095d4360c95efddb87eb8fdec2c43bd76af7f3cb78d4651603fb`).
The VM was a clone of `testanyware-golden-macos-tahoe`: macOS 26.5 (25F71),
arm64, Homebrew 6.0.3 from the golden, display 1920x2160, with Gatekeeper
assessments **enabled** and developer id **enabled**. Result: **passed**, every
expectation above.

```
== Put the clone into a Gatekeeper-enforcing state
Before: assessments disabled;
After:  assessments enabled;developer id disabled;
The clone is App Store-only; setting the default posture in System Settings.
After System Settings: assessments enabled;developer id enabled;

== Homebrew in the guest
Homebrew 6.0.3

== brew install --cask linkuistics/taps/koine
  | ==> Tapping linkuistics/taps
  | Warning: Skipping linkuistics/taps because it is not trusted. Run `brew trust linkuistics/taps` to trust it.
  | ==> Trusted cask linkuistics/taps/koine
  | ✔︎ Cask koine (0.1.0)
  | ==> Moving App 'Koine.app' to '/Applications/Koine.app'
  | 🍺  koine was successfully installed!
Installed version: 0.1.0

== Homebrew quarantined the download, and nothing stripped it
Quarantine on the bundle: 0181;6abb8a7c;Homebrew\x20Cask;6D6E030A-3C70-4D5C-A133-8623B1121782

== Gatekeeper's verdict on the installed bundle
/Applications/Koine.app: accepted
source=Notarized Developer ID
origin=Developer ID Application: Antony Blakey (TA43A4RUP3)
The validate action worked!

== First launch of the quarantined copy: plain open, no right-click-Open
  “Koine” is an app downloaded from the Internet. Are you sure you want to open it?
  Homebrew Cask downloaded this file today at 9:53 AM. Apple checked it for malicious software and none was detected.
Koine pid: 1791
{"contractVersion":"koine-desktop\/1","descriptorVersion":1,…,"path":"\/graphql","pid":1791,"port":49160}

== Enable login launch in the window, so uninstall has a registration to leave or take
Before: Koine is not registered to start at login. Clients find the service unavailable until you open Koine.
After:  Koine will start when you log in.

== Koine's Background Task Management entry: installed, running, login launch on
          Disposition: [enabled, allowed, notified] (0xb)
           Identifier: 2.dev.antony.Koine
                  URL: file:///Applications/Koine.app/

== What Koine leaves in ~/Library: installed and running
/Users/admin/Library/Application Support/Koine
Defaults domain: (none)
Saved window state: /Users/admin/Library/Daemon Containers/13C3DBF7-…/Data/Library/Saved Application State/45981392-FB2C-4A1F-BA32-5DD95D09D7DB.savedState
  data.data
  windows.plist

== brew uninstall --cask koine, with Koine running
  | ==> Quitting application 'dev.antony.Koine'...
  | Application 'dev.antony.Koine' quit successfully.
  | ==> Removing App '/Applications/Koine.app'
Koine quit and /Applications/Koine.app removed.

== What Koine leaves in ~/Library: after a plain uninstall
/Users/admin/Library/Application Support/Koine
Defaults domain: (none)
Saved window state: …/45981392-FB2C-4A1F-BA32-5DD95D09D7DB.savedState
  data.data
  windows.plist

== Koine's Background Task Management entry: after a plain uninstall
          Disposition: [enabled, allowed, notified] (0xb)
                  URL: file:///Applications/Koine.app/

== Reinstall, then brew uninstall --zap --cask koine
  | ==> Moving App 'Koine.app' to '/Applications/Koine.app'
  | 🍺  koine was successfully installed!
  | ==> Removing App '/Applications/Koine.app'
  | ==> Dispatching zap stanza

== What Koine leaves in ~/Library: after --zap
  (nothing)
Defaults domain: (none)
Saved window state: …/45981392-FB2C-4A1F-BA32-5DD95D09D7DB.savedState
  data.data
  windows.plist

== Koine's Background Task Management entry: after --zap
          Disposition: [enabled, allowed, notified] (0xb)
                  URL: file:///Applications/Koine.app/
```

The cask at `7dd12d88` still declared the preferences plist and the old
saved-state path. The measured result is the same with or without them,
because neither path exists on macOS 26. The screenshot beside the transcript,
`-first-launch.png`, is the first-run dialog.

## Tooling note

`guest()` in `scripts/vm-verify-lib.sh` silently retries an exec that
falsely times out after 30 seconds. That is safe for a read and unsafe for
starting a `brew install`, because a retried launch starts the install twice.
The second install then prints "Not upgrading koine, the latest version is
already installed", truncates the shared log, and can finish first. So
`guest_long` takes a `mkdir` guard before it detaches a script, and the run
asserts that the reinstall put the application back before it runs `--zap`.
