# Launch: VM verification

The "Isolated TestAnyware macOS VMs" seam of
[workspace-launch-and-open.md](../specs/workspace-launch-and-open.md) and
[workflow-providers.md](../specs/workflow-providers.md), for the first workspace
operation: `workspaceLaunchApplication`, under `workspace:control` AND
`desktop:control`, launches one real required launcher application while it is
stopped and reactivates it while it runs. It runs on the Developer ID signed
`Koine.app` (0.1.0) with Notes; nothing runs the application on the host, and no
application is mocked.

## Procedure

```sh
task app                     # build and sign .build/app/Koine.app
task check:launch-call-path  # the launch path's native calls (also run first by the next)
task app:vm-verify-launch    # scripts/vm-verify-launch.sh, one clean TestAnyware macOS VM
```

**Activation is never inferred from the acknowledgment.** `Fixtures/LaunchWitness`
(test material, signed, never shipped) holds no Koine code and needs no
Accessibility, so it can observe the runs in which Koine has none. It reports what
the system itself says: the frontmost application as `NSWorkspace` gives it to a
fresh process, with the window server's front ordinary window as a second witness;
the running instances of a bundle identifier with each one's kernel start instant
(`proc_pidinfo`); every launch, activation and termination the workspace announces,
stamped with the guest's clock (the client stamps its request and its answer from
the same clock, so the activation is placed between them); and a process's exit, by
`kqueue`. The client (`scripts/vm-verify-launch-client.py`) sends
`LaunchInstalledApplication` and `CaptureOpenedApplication` with the text
[workspace-operations.graphql](../design/workspace-operations.graphql) has for
them, comments dropped and the fragment sent with it.

A launch request runs **once**: the recipe's agent wrapper retries the agent's false
"timed out" answer, which for a launch would turn the cold launch into a
reactivation. The answer goes to a file that is read back.

Grants: the first (`koine:manage`, `desktop:read`) is made in Koine's window; the
rest are made by it through `koineCreateGrant` (the window's grant form scrolls out
of reach once several grants are listed). One is revoked through `koineRevokeGrant`
after being seen to work.

## Application, first run and Gatekeeper

Notes, `com.apple.Notes`, version 4.13 (build 3146.121.7), at
`/System/Applications/Notes.app`; macOS 26.5 (25F71), arm64. It ships with the
system and needs no account. Its first run is a welcome sheet, completed by its
Continue button; it then shows `Notes – No notes`.

The clone starts with assessments disabled, so the recipe enables them
(`spctl --global-enable`; afterwards `assessments enabled;developer id disabled`).
`spctl -a -vv` then reports `accepted`, `source=Apple System`, `origin=Software
Signing` and no override; Notes carries no quarantine attribute and is signed
`Identifier=com.apple.Notes`, `TeamIdentifier=not set`. Only that one switch is set:
Koine was installed without quarantine, so it is not assessed, and its own
Gatekeeper posture (Unnotarized Developer ID here) belongs to the notarized runs.

## What each step observed

One passing transcript, `.build/vm-verify/launch-20260930T214837.log`, on a clean
clone with Accessibility absent to Koine until the step that gives it. Times are
milliseconds on the guest clock; the answer is the client's, from send to answer.

| Step | Observed |
|---|---|
| Grants | A grant holding `workspace:control` and `desktop:control` is accepted (HTTP 200), revoked, and then refused (HTTP 401). Accessibility is `granted: false` to `koine:manage` alone. |
| Refusals, Notes stopped, TextEdit in front and Koine inactive | The revoked grant: 401, no body. `workspace:control` alone: HTTP 403, `kind: permission`, `permissionClass: capability`, `phase: authorization`, first unmet `desktop:control`, complete set `[workspace:control, desktop:control]`. `desktop:control` alone: 403, first unmet `workspace:control`. `desktop:read` alone: 403. Each time the witness reports no launch and no activation, the same frontmost process, and no Notes instance. |
| Cold launch, both controls and no read capability, TextEdit in front, Koine inactive | Receipt `AVAILABLE` with `process {pid 1067, startedAt 2026-09-30T12:06:53.786700Z}` **165 ms** after the request was sent. The witness saw Notes activated **150 ms** after it (and launched 80 ms after that), then Notes in front with the window server's front window its own, and exactly one instance. |
| The identity | The receipt's `{pid, startedAt}` equals the witness's kernel reading, byte for byte. `desktopApplication(process:)` accepts it unchanged under `desktop:read`: `ref`, `name: Notes`, `bundleIdentifier: com.apple.Notes`. The grant with both controls and no read capability is refused that read (`desktop:read` required), so it launched with no read. |
| Reactivation while running | TextEdit is put in front again (Koine still inactive) and the same request sent: the same `{pid 1067, startedAt}` comes back after **22 ms**, the witness saw Notes activated **9 ms** after the request, no application launched, still exactly one instance: the running copy is reused. |
| Refusals, Notes running in the background | Revoked (401), `workspace:control` alone and `desktop:control` alone (403): no activation, focus unmoved, the one instance untouched. |
| The process's real exit | `killall Notes`: the witness's `kqueue` reports the exit of pid 1067; no instance remains. `desktopApplication(process:)` for that identity answers a plain `null` with no error. |
| Accessibility absent | Every step above ran with Koine having no Accessibility consent. The desktop read of the running application resolves the process and only its `windows` field is refused, as an `os-permission` error naming `accessibility` and owner `koine`. No launch raised a consent dialog: `find-text "would like to control"` finds nothing on screen after each (`universalAccessAuthWarn` was running, as it is whenever an untrusted application asks whether it is trusted, and showed nothing). |
| The client's optional recovery | Consent is given in System Settings (`osPermissions` then reports `granted: true`). A cold launch is made, TextEdit put in front, and a **separate** grant with `desktop:read` reads the launched application (`CaptureOpenedApplication`): its one window `Notes – No notes`, `CURRENT`. A **separate** grant with `desktop:control` alone focuses it (`desktopFocusWindow` returns the reference), and the witness then reads Notes in front, pid 1488. Neither Koine nor the workspace grant did either step. |
| Accessibility revoked | Consent is switched off in System Settings (`osPermissions` reports `granted: false`). A cold launch: receipt with process, answer after **100 ms**, activation observed after **93 ms**; a reactivation: **22 ms** and **9 ms**. No consent dialog after either. |

Callback latencies, as measured (the answer is the whole GraphQL round trip, so the
native callback's own wait is at most that):

| Launch | Answer after | Witness saw activation after |
|---|---|---|
| Cold, Accessibility absent | 165 ms | 150 ms |
| Reactivation, Accessibility absent | 22 ms | 9 ms |
| Cold, Accessibility revoked | 100 ms | 93 ms |
| Reactivation, Accessibility revoked | 22 ms | 9 ms |

Every run answered well inside the three-second bound. These are one sample each
in a VM, not a distribution.

## The launch call path, inspected

`scripts/check-launch-call-path.sh` enumerates the workspace provider's launch path
from source and from the built bundle's own imports. Each pattern is first seen to
match a control it must, and to leave alone text it must not.

- **The primitive.** Exactly one request:
  `NSWorkspace.shared.openApplication(at:configuration:completionHandler:)`
  (selector `openApplicationAtURL:configuration:completionHandler:` in the bundle).
- **Its parameters,** all ten set at the one site
  (`Providers/WorkspaceProvider/Sources/NativeWorkspace.swift`): `activates = true`,
  `createsNewApplicationInstance = false`,
  `allowsRunningApplicationSubstitution` = the request's own flag,
  `hides = false`, `hidesOthers = false`, `isForPrinting = false`,
  `promptsUserIfNeeded = false`, `arguments = []`, `environment = [:]`,
  `appleEvent = nil`. Activation is the primitive's documented semantics, which is
  why workspace declares `desktop:control`.
- **Preparation and cleanup.** Preparation is the selection's read-only inspection
  (`realpath`, three resource values, `Bundle(url:)`, and two Launch Services
  registration lookups); after the callback, `proc_pidinfo`, `proc_pidpath` and
  `NSRunningApplication` reads for the observation rule. No fallback and no
  cleanup call exist.
- **Absent, in source and in the bundle:** any `activate` or `activateWithOptions:`,
  `hide`/`unhide`, `terminate`, `launchApplication:`, `openURL:`/`openFile:`,
  `AXUIElement*`, `CGEvent*`, `CGWindow*`, AppleScript, `Process`/`posix_spawn`.
  The bundle imports only `NSWorkspace`, `NSWorkspaceOpenConfiguration` and
  `NSRunningApplication` from AppKit.

**What this does and does not separate.** Koine-selected activation is the one open
request's `activates = true`. The VM shows the effect (Notes came to the front each
time), but a focus change proves neither the presence nor the absence of a hidden
call, and Notes' own reaction to being launched or reopened cannot be told from the
primitive's activation by observation here. The inspection is what says Koine
adds no activation call beside the request; runtime interception of
`NSWorkspace` was not attempted. No target whose invocation does not itself change
focus was used.

## Finding: the receipt's process was null on cold launches

The first passing-shaped run failed at the identity step: the cold launch
acknowledged in about 100 ms with Notes plainly in front, and the receipt's
`process` was `null`. In the release build three of the first four cold launches did
that; a reactivation always returned the process.

An instrumented build (never committed) logged each step of the observation rule.
Every step passed but the last: the first fresh
`NSRunningApplication(processIdentifier:)` was not `isEqual:` to the object the
callback delivered, and a lookup 0 to 5 ms later always was. A standalone tool that
ran the same steps directly in its callback never saw it, and instrumentation that
touched the disk between steps hid it (one null in thirteen), so this is a race in
the system's own record of a new application, not a process mismatch.

`observeProcess` now retries that one step every 5 ms for at most 250 ms
(`settle`, about fifty times the largest wait seen). Every other step is as before
and a lookup still unequal after `settle` is null. The retry is exercised at L
(`ObservationTests`: equal on a later try yields the identity, seen to fail with
`settle: .zero`; settling only after the bound is null). In the passing run all
three cold launches returned their process.

## Limits and what stays pending

- One application, one clone, one macOS (26.5), one sample of each timing. The
  other eleven launchers, and **Twelve launchers** as a row, stay pending
  (`application-launchers`).
- Notes is Apple's and needs no account; first-run and Gatekeeper preparation of
  the third-party launchers is not exercised.
- **Bounded acknowledgment (V):** Gatekeeper held open past the three-second bound
  was not exercised; only normal completion timing is recorded.
- **Multiple copies**, and the other three roots, are not touched.
- The controls-only activation did **not** fail the requirement here: both cases
  activated with `workspace:control` and `desktop:control` and no read. No measured
  limit needs to go to Antony from this run.
- Disclosure in the native grant views (`workspace-disclosure`) and the
  core + desktop + workspace conformance profile (`launch-contract`) are separate.
- The refusals were observed with the application stopped and running in the
  background; a revocation between actions of one multi-action request is G's, not
  V's.
