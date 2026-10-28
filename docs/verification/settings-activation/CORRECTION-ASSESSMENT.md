# Settings activation correction assessment

No correction in the inspected path meets the accepted requirement for an
evidenced API-use mistake or omission. Koine already requests a key/front window
and makes the self-activation request Apple recommends. The failure remains real;
this assessment establishes neither its native cause nor an external owner.
It is a bounded source-and-contract finding, not proof that no correction exists.

The [repair and evidence contract](../../specs/settings-activation-discrimination.md#correction-assessment)
records the result and pending scope choice. No product changes, new tests,
build, signed candidate or guest belong to this assessment. Independent review
must challenge the finding before it becomes the basis of the scope decision.

## Inspection boundary

Source references describe parent revision `b959a684` and the unchanged source
in this assessment. The graph CLI refused `list_projects` before identifying a
project or generation: `CBM CLI could not start because a pre-coordination or
unverified CBM generation is active; close all CBM sessions and commands, then
retry`. No other graph session was interrupted. Consequently, there is no graph
coverage result. The fallback is the exact files and bounded text search below,
not an exhaustive repository or AppKit audit.

| Source | Inspected behavior |
|---|---|
| [AppDelegate](../../../Sources/KoineApp/AppDelegate.swift), lines 7–58, 82–147 | Main-actor owner retains one Settings window. Launch, reopen and the menu closure call the same show method. The method requires server/port, creates a titled window once, retains it across close, requests key/front status, then invokes `NSApp.activate()` once. The separate fatal-alert activation terminates the app and is not a Settings retry. |
| [MenuBarController](../../../Sources/KoineApp/MenuBarController.swift), lines 16–90 | Settings and status-line actions each call the stored show closure once. A real menu owns the items; menu-close records observation and closes the probe. The two-second status follower does not request activation. |
| [SettingsMenuProbe](../../../Sources/KoineApp/SettingsMenuProbe.swift), whole file | Requires memory diagnostics, no file tracing and explicit probe opt-in. It observes highlight/input and returns the same monitored event. Ordinary operation has no probe timer/monitor or files. This is source evidence, not actual menu-dispatch qualification. |
| [SettingsActivationTrace](../../../Sources/KoineApp/SettingsActivationTrace.swift), whole file, and [SettingsActivationInterval](../../../Sources/KoineAppDiagnostics/SettingsActivationInterval.swift), lines 6–26 | Disabled diagnostics still call the operation once. Enabled measurement brackets that operation; existing observers can run inside it. These are observation mechanisms, not activation policy or a product repair seam. |
| [Main entry](../../../Sources/KoineApp/main.swift), [MainMenu](../../../Sources/KoineApp/MainMenu.swift), [Info.plist](../../../App/Info.plist) | AppKit owns the run loop. MainMenu supplies window/key-equivalent actions. `LSUIElement` is true, the principal class is NSApplication and the minimum system version is 26.0. |

The bounded search over `Sources/KoineApp` checked show callers, activation calls,
activation-policy setters, key/main eligibility overrides, window-front calls,
yield and hide/unhide calls. Its positive matches are AppDelegate's three show
call sites, show method, Settings activation and fatal-alert activation. The
negative observations are limited to this source directory. The declaration
and body reads above establish the material path, rather than treating the
search's exit status as proof of completeness.

## Applicable public contracts

Apple's live documentation was read on 2026-10-28. The installed Xcode macOS 27.0
SDK supplies a second primary declaration surface; it is not evidence of what
the old guest executed. The project targets macOS 26 and the historical failed
subject is macOS 27.0.1, so APIs introduced in macOS 14 are available at the
declared deployment boundary.

| Contract | Consequence for this design |
|---|---|
| [Self activation](https://developer.apple.com/documentation/appkit/nsapplication/activate%28%29) and [cooperative activation](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation) | Apple recommends `NSApp.activate()` when the target activates itself. The system considers context and may decline. A yield is supplied by the active app, not manufactured by the inactive target. The inspected path already uses the recommended self request. |
| [Key and front ordering](https://developer.apple.com/documentation/appkit/nswindow/makekeyandorderfront%28_%3A%29) and [key eligibility](https://developer.apple.com/documentation/appkit/nswindow/canbecomekey) | The existing window call requests both visibility/order and key status. The ordinary NSWindow has the documented titled style for key eligibility. These contracts do not prescribe the reverse order relative to application activation. |
| [Accessory policy](https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy-swift.enum/accessory) | `LSUIElement` admits programmatic activation without a Dock entry. It is not the prohibited policy. Changing to a regular application would alter the resident application's presentation without an established correction to this failure. |
| [Running-application activation](https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28options%3A%29) | A different receiver API and a Boolean return do not establish an omitted product step. The web page describes successful activation; the installed header describes successful request sending. Neither supplies evidence that changing APIs makes this failed selection front/focused, and the Boolean must not replace the independent window outcome. |
| [Activation from another app](https://developer.apple.com/documentation/appkit/nsrunningapplication/activate%28from%3Aoptions%3A%29) | Its discussion and SDK declaration require the cooperating app to yield first for cooperative use. Knowing TextEdit is frontmost establishes neither that yield nor authority to issue it on TextEdit's behalf. The web parameter summary is terse; the SDK explicitly describes taking active status from the other app. |
| [Unconditional front ordering](https://developer.apple.com/documentation/appkit/nswindow/orderfrontregardless%28%29) | Can place an inactive app's window in front within its level, while preserving key/main status. It cannot by itself satisfy the required focus outcome. Apple's documented cooperating-display use is not the observed Settings interaction. |
| [WWDC23 cooperative activation](https://developer.apple.com/videos/play/wwdc2023/10054/) and SDK `NSRunningApplication.h` | The old ignoring-other-apps option has no effect under cooperative activation. `activateAllWindows` changes which windows are brought forward; it provides no stronger activation guarantee for the one Settings window. |

The SDK reads covered `NSApplication.h` lines 216–249 and
`NSRunningApplication.h` lines 17–42 and 128–148 under the installed
`MacOSX.sdk/System/Library/Frameworks/AppKit.framework/Headers` directory.
The [verification receipt](correction-evidence/verification.json) identifies
those exact input bytes. Web Markdown retrieval succeeded through HTTPS after
the browser-search tool could not consume Apple's Markdown content type; no
partial web error was treated as a contract.

## Candidate disposition

| Candidate | Missing justification or precondition | Result |
|---|---|---|
| Add self activation or key/front ordering | Both calls already exist and the failed historical callback reaches them. | No omitted step to correct. |
| Reverse activation and window ordering | No checked public contract prescribes it. The closed [ABBA comparison](ORDER-RESULTS.md) shows both orders can succeed; moving synchronous tracing also changed timing. | A viable empirical hypothesis, not an evidenced API-use correction. No repeat or new sample is earned. |
| Replace self activation with `NSRunningApplication.current.activate` | No source/contract mismatch establishes the current receiver is wrong. Return semantics are not a focused-window guarantee. | No qualifying correction. |
| Use `activate(from:options:)` or yield | A prior yield by the active app is unestablished. The inactive Koine process cannot supply TextEdit's cooperation merely by identifying it. | Preconditions unmet; speculative yield also remains excluded. |
| Use ignoring-other-apps or all-windows options | The former is ineffective; the latter affects window selection, while Settings is already explicitly requested. | No justified increase in activation authority. |
| Add `orderFrontRegardless`, raise window level, or use a nonactivating panel | Front placement without application/key focus does not meet the required outcome; changing window role/level changes product behavior. | No supported repair to the front-and-focused contract. |
| Add `makeMain`, another key request or force key eligibility | The window is titled and already receives a key request; the failure is independently observed application inactivity. No evidence shows an eligibility/main-window omission causing that inactivity. | No qualifying correction. |
| Change activation policy, recreate the window, or add unhide/deminiaturize | Accessory activation is permitted; the retained failure has a visible Settings window after a close/reopen. No retained evidence identifies prohibited policy, a lost window, hidden application or miniaturization as this failure. | No qualifying correction for this observed failure; other unexamined states are not declared correct. |
| Add menu-close/later-run-loop deferral, repeated activation or driver input/waits/retries | These remain outside the accepted scope. The historical callback already runs after menu close in default mode. | Not admitted; no experiment runs to justify them retrospectively. |

The tempting inference is that an inactive-window warning makes ordering wrong.
The [native qualification](NATIVE-RESULTS.md) also records that warning in a
successful path. The warning therefore supplies no sufficient failure condition.
The [reviewed native contrast](DISCRIMINATION-REVIEW.md#native-row-comparison)
remains positive context with unresolved direction and private semantics. It
does not turn the reversal into a documented correction.

## Product seam and acceptance consequence

No useful failing headless product check is identified because there is no
supported product correction to exercise. A fake that refuses one API/order and
accepts another would encode the desired hypothesis, not reproduce this native
failure. Existing interval, probe and reader controls establish their own
contracts only. No new public interface or injection seam is justified here.

The accepted end-to-end seam remains `app:vm-verify-menu-bar`: a real signed
application, one genuine Settings selection, independent window/front/focus
observations and screenshots, and the complete ordinary scenario with diagnostics
disabled. A future justified or explicitly re-scoped design must specify its
effects, finite evaluation bound and failure/NOT RUN consequences before runtime,
and keep ordinary acceptance separate. This no-candidate result selects no
subject or cap. The six held route/modality slots cannot be repurposed.

## Original duties after this assessment

The contract's [complete original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
continues to bind. Each row is checked here against this design result.

| Original duty | Result here |
|---|---|
| Callback/failure classification and persisted symptom preservation | Historical classifications and bytes unchanged. |
| Supported condition, intervention and two finite falsifiers | Still unmet; k42 amended this prerequisite for qualifying behavioral repair, not the evidence required for a causal claim. |
| Positive actual failed request/disposition/responsible context | Unresolved, likewise amended only as a behavioral-repair prerequisite. No owner is inferred. |
| Acquisition/configuration/lag and changed-instrument availability/symptom/timing | Historical limits retained. No new instrument or runtime qualification; any future changed instrument must qualify before reliance. |
| Actual signed subject, all consumed inputs, completed golden freeze | No new runtime subject. Still required, completed before any future launch. |
| Every attempt, failed transport, partial archive and NOT RUN | Preserved; matching timeout/nonzero text remains failed. No new attempt. |
| Original/endpoint/golden audits and exact clone stop | Historical results unchanged; all remain mandatory for future runs. No clone used here. |
| Justified repair and useful failing product seam | Unmet. No qualifying candidate or useful failing product seam found in this scope. |
| One selection, one front/focused window, one activation request | Obligation unchanged and still unsatisfied by the failed reopen. |
| Separate finite complete ordinary acceptance | Unmet. Required through the existing scenario, diagnostics disabled, with final signed/all-input/completed-golden freeze and every outcome retained. |
| External evidence/reproducer/approval | No external attribution, no upstream report. An external attribution would still require positive evidence and retain unresolved repair. |
| Historical caps and ordinary phases | All closed caps remain closed. Persisted reopens 2/3 and subsequent ordinary phases remain NOT RUN. All six proposed causal slots remain held/unstarted. |
| Acceptance, release and ancestor closure | No repair/ordinary acceptance, release, notarization or causal/product ancestor closure follows. |

Persisted scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201
and post-trace timeout/-1 remain failed. Its old strict wall-clock false/empty
joins remain unchanged. Its NOT RUN phases remain reopens 2/3,
resize/minimum-size/content-height/scrolling, shortcuts, requests/denials, consent,
silent launch, running-app reopen, login restart and Quit.

## Reversal condition and scope escalation

This finding changes if a reviewer or new primary evidence identifies a concrete
API-use mismatch in this path and a correction with established preconditions.
The candidate would then need its own coherent design and independent review
before implementation. An untested API's existence or a successful alternative
call would not meet that condition.

If the finding survives review, the [pending scope proposal](../../specs/settings-activation-discrimination.md#scope-after-no-candidate)
offers a narrower next decision than an unrestricted workaround search: permit
design of one empirical activation-before-window-ordering evaluation without
requiring a documented API-use violation. The reason to consider it is its small
single-request behavioral difference and historical feasibility, not a proven
mechanism or repair. The cost is that even a finite passing ordinary sample
cannot demonstrate elimination of an intermittent failure. Explicit agreement
on that acceptance limit, then design/review/every earned integration, must
precede any new runtime. Retaining the present hold or ending unresolved remain
human choices. Nothing here selects any of them or abandons repair work.
