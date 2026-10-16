# Twelve launchers: VM acceptance

The "Isolated TestAnyware macOS VMs" seam of the **Twelve launchers**, **Bounded
acknowledgment** and **Consent and prompts** rows of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md), for all twelve
named launchers and the pending-Gatekeeper timeout. It runs the Developer ID signed
`Koine.app` (0.1.0) in a clone of the prepared image from
[launcher-apps-vm.md](launcher-apps-vm.md) (Gatekeeper enforcing, each application
installed from its normal distribution and past its first run, nothing signed in to).
One application, Notes, was already accepted alone in [launch-vm.md](launch-vm.md); this
document covers every launcher with the same independent witness. Nothing runs an
application on the host, and no application is mocked.

## Procedure

```sh
task launchers:prepare   # once: the reusable image (about 40 minutes)
task launchers:vm        # scripts/vm-verify-launchers.sh, one clone of that image (about 3 hours)
```

`task launchers:vm` builds the app and the contract-only client, then runs one clone.
`KOINE_LAUNCHERS_ONLY=<name,...>` (or `none`) and `KOINE_LAUNCHERS_SKIP_EXTRA=1` select
cases. It exits 0 when everything passed, 1 when a case failed, and 3 when the only
failures are controls-only activations, which are **pending** and go to Antony.

**Every request is made by the contract-only client** ([launch-contract.md](launch-contract.md)),
which enrols its own grant (`workspace:control` and `desktop:control`, no read
capability) through the settings window and is regenerated from the schema the signed build
serves. Koine has no Accessibility consent in the clone, so activation below is by the
two controls alone. **Activation is never inferred from the acknowledgment**:
`Fixtures/LaunchWitness` (see [launch-vm.md](launch-vm.md#procedure)) reports who is in
front, the running instances of a bundle identifier with the kernel's start instant of
each, and every launch and activation the system announces, on the clock the client
stamps its requests with.

Per application, with TextEdit in front and Koine inactive before each request:

1. stopped: a **cold launch** must return an acknowledged receipt, the witness must see
   the application activated after the request was sent, and exactly one instance must
   exist whose **kernel start instant is after the request**; the receipt's
   `{pid, startedAt}` must equal the kernel's;
2. running, TextEdit in front again: a **reactivation** must be acknowledged, activated
   (seen by the witness), return the same process, make no launch and leave one instance;
3. any system dialog on screen after each request is read: Gatekeeper's, or a permission
   request naming Koine, fails the case; an application's own permission request is
   recorded and declined (below);
4. the application is quit with Command-Q.

## Result

One passing run, transcript `.build/vm-verify/launchers-vm-20261001T221438.log` (macOS 26.5,
arm64; the image's versions are as the preparation recorded them), machine-readable at
[launchers-vm/results.json](launchers-vm/results.json). Latencies are the client's
answer after it sent the request, then the witness's activation after the same instant,
in milliseconds. The one sample per application is a measurement, not a bound.

| Application | Bundle identifier | Version (build) | Path | Cold: answer / activation | Reactivation: answer / activation |
|---|---|---|---|---|---|
| Dia | `company.thebrowser.dia` | 1.50.1 (87750) | `/Applications/Dia.app` | 299 / 293 | 55 / 34 |
| ChatGPT | `com.openai.codex` | 26.928.31416 (12553) | `/Applications/ChatGPT.app` | 303 / 291 | 87 / 38 |
| Claude | `com.anthropic.claudefordesktop` | 2.16120.0 (2.16120.0) | `/Applications/Claude.app` | 319 / 303 | 37 / 21 |
| Zed | `dev.zed.Zed` | 1.22.0 (20260930.150108) | `/Applications/Zed.app` | 163 / 150 | 35 / 27 |
| Visual Studio Code | `com.microsoft.VSCode` | 1.140.0 (1.140.0) | `/Applications/Visual Studio Code.app` | 233 / 223 | 54 / 18 |
| Jump Desktop | `com.p5sys.jump.mac.viewer.web` | 10.15.31.0 (1001365) | `/Applications/Jump Desktop.app` | 159 / 144 | 35 / 27 |
| Kimi | `com.moonshot.kimichat` | 3.2.15 (3.2.15) | `/Applications/Kimi.app` | 243 / 228 | 51 / 33 |
| iTerm | `com.googlecode.iterm2` | 3.7.3 (3.7.3) | `/Applications/iTerm.app` | 226 / 218 | 39 / 20 |
| Mail | `com.apple.mail` | 16.0 (3864.600.51.1.1) | `/System/Applications/Mail.app` | 102 / 97 | 43 / 18 |
| Notes | `com.apple.Notes` | 4.13 (3146.121.7) | `/System/Applications/Notes.app` | 194 / 187 | 41 / 29 |
| Obsidian | `md.obsidian` | 1.13.7 (1.13.7) | `/Applications/Obsidian.app` | 203 / 188 | 34 / 20 |
| Zotero | `org.zotero.zotero` | 10.0.5 (10.0.5) | `/Applications/Zotero.app` | 236 / 224 | 33 / 28 |

All twelve: acknowledged, activated by the witness's account, one instance, receipt
equal to the kernel's identity, reactivation the same process with no launch. Cold
launches were acknowledged in 102-319 ms and activated 97-303 ms after the request.
Reactivations answered in 33-87 ms. No Gatekeeper dialog appeared for any launcher
(the preparation approved each), and no case needed the controls-only activation to
be treated as pending.

### Not installed, and deleted

An identifier no application has (`dev.koine.test.NotInstalled`), and Zotero after it had
been launched and its bundle deleted from the disposable clone (a registration whose
bundle is gone), each return `DEPENDENCY_UNAVAILABLE` with reason
`APPLICATION_NOT_INSTALLED` and guidance, no process, and the witness sees nothing
launched, activated or moved. Neither is `failed`, and neither is the pending case below.

### Gatekeeper held past the bound

The pristine quarantined Obsidian the preparation archived apart (`0181;…;Homebrew\x20Cask`,
never opened) is extracted to a path of its own, registered, and launched through the
contract-only client by that path, with the approved copy untouched.

- The system's dialog is **outstanding** (`Help`, `Cancel`, `Open` on screen) and the
  client's answer arrives at the three-second bound (3223 ms and 3206 ms after the
  request, in the two passes): `failed`, "The system did not acknowledge the launch
  within 3 seconds. It may still complete; the request was not repeated.", action effect
  `may-have-begun`, no process. It is never dependency absence.
- Ten seconds on, still exactly one Gatekeeper dialog, no launch or activation event,
  nothing replayed (the client sent the request once).
- **Declined** (`Cancel`): nothing launches, no instance, no further event. **Accepted**
  (`Open`, in a second pass on a fresh extraction): exactly one launch event, from the
  original submission completing, and one instance. In both, no result is published after
  the answer, and the next ordinary request (Notes) is served normally with its own
  receipt.

## Findings from the runs

- **Kimi raises its own permission request** ("Allow “Kimi” to find devices on local
  networks?") on some launches: after a cold launch in one earlier run, after a
  reactivation in another, and not at all in the passing run. It is Kimi's onboarding, not
  Koine's (the preparation's strict check, which opened Kimi without Koine, did not see it
  either). The recipe records its words and declines it, and fails a case only for
  Gatekeeper's dialog or a request that names Koine. A dialog left standing was what made
  the applications after Kimi fail in that earlier run.
- **The system's launch notification is not a reliable witness of a cold launch.** The
  witness saw no `launched` event for ChatGPT in one run and for Kimi in the final one,
  though each was activated and had a fresh instance. The criterion is the kernel's start
  instant of the single instance, after the request was sent; the events are recorded
  beside it.
- **The agent's "not reached" (status 7) can follow a command that ran.** One earlier run
  repeated the client after the cold launch had already happened, so the second request was
  a reactivation and the recorded send instant came 45 seconds after the process started.
  The recipe now never repeats a client run whose answer file exists, and the kernel-start
  criterion above is what exposed it.
- The recipe's first reading of the kernel's identity compared the receipt with Koine's
  own process (a stale variable in the script); it was a recipe fault and is fixed.

## Limits and what stays pending

- One macOS (26.5), one architecture, one clone, **one sample** of each timing. The applications
  are as the image installed them, at the versions in the table.
- Activation is the witness's account of the system's activation after the request. This
  checks Koine and the application together: Koine's own activation is separated from the
  application's reaction only by the call-path inspection in [launch-vm.md](launch-vm.md).
- No application was signed in to. Kimi's recurring Accessibility (events) request, and iTerm's
  quit confirmation, are answered as in the preparation and are not Koine's.
- "No late result is published" is observed through the public surface only: the answer is
  the request's one response, a second launch event does not appear, and the next request is
  unaffected. The late-callback handling itself is established at L (`LaunchTests`).
- The controls-only activation did **not** fail the requirement for any launcher, so nothing
  goes to Antony from this run.
- Multiple copies (`application-installations`), the other three roots, and disclosure
  (`workspace-disclosure`) are separate.
