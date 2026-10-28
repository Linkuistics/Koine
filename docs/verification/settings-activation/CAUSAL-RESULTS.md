# Native call recorder and a bounded selection-path question

The source now has opt-in direct native-tick brackets around the existing
Settings activation call, with observed-kernel boot identity and timebase. Nine
headless checks pass and the application builds. This supplies a tested recorder,
not a reproduced activation failure, native refusal, causal explanation or repair.
No guest starts in this slice and no new signed candidate is selected.

The remaining saved archive was inspected before choosing a new runtime question.
Its native input records support testing whether clicking the Settings row is
necessary for the failure. The [matched modality protocol](CAUSAL-PLAN.md) fixes
four fresh slots, mouse/Return/Return/mouse, with one selection per slot and the
same highlighted row, application/window and foreground setup. It requires
positive failed-path evidence, not a comparison of green counts. Its revised
interpretation receives a separate tree review before any guest starts.

## Independent saved input context

The [broad rendering](causal-evidence/persisted-input-context.jsonl.gz) comes from
the already saved full persisted archive, using Apple's log tool and the fixed
06:05:55–06:06:10 UTC interval. It selects WindowServer, Koine, TextEdit and lsd
without the former message predicate. This is an offline native sequence read,
not a new extraction of k32's focus markers or an application/native clock join.
Source lines below refer to this new full rendering, not the older filtered one.
The [reproduction receipt](causal-evidence/reproduction.json) records exact bytes,
JSON/completion validation and the positive records used here.

| Native observation | Successful-adjacent tick / line | Failed-adjacent tick / line |
|---|---|---|
| Menu-row beginDeferredActivation, source mouse | 4330266472 / 311 | 4468168440 / 913 |
| endUserInteraction, immediate false, source mouse | 4330276603 / 317 | 4468193176 / 919 |
| output orderWindowFront for the input event | 4330276700 / 318 | 4468193378 / 920 |
| Ignoring activation end-user interaction for mouse | 4330278190 / 321 | 4468198962 / 923 |
| Koine client SLSSetFrontProcessWithInfo | 4338579225 / 365 | 4476843871 / 970 |

The successful native sequence positively records LS/CAS front change with
err=0/noErr at 4338594230 (line 376). The failed-adjacent sequence records
TextEdit connection 53ea7 requesting active key appearance for window 32 at
4476872612 (line 977). It later records Koine connection 403fb conditionally
ordering window 28 relative to window 32 at 4477297904 (line 988), followed by
the menu window's immediate endUserInteraction at 4477304826 (line 996).
The native messages spell the identifiers 28/32; the independent snapshot uses
Settings 40/TextEdit 50. A hexadecimal interpretation is consistent with these
values, but this comparison does not establish a native identifier-format
contract. The saved clean
[failure snapshot](persisted-01/failure-native.json), agent windows and screenshot
remain the observed unsuccessful outcome.

Both native sequences contain deferred mouse activation and the same
ignoring-interaction message. Neither message alone discriminates failure or
constitutes a refused application activation. The TextEdit appearance request
and conditional ordering are positive context, not a causal result. The broad
read adds records omitted by the old message predicate; it does not demonstrate
that all relevant native decisions are logged. No absence claim supplies an owner.
The [prior marker counterexamples](FOCUS-RESULTS.md) remain authoritative.

The selected intervention changes only row selection after the same mouse-open
and hover preparation. A positively qualified Return failure could refute the
necessity of clicking the row. It cannot eliminate shared mouse-open context,
nor can Return success establish a repair. Event kind and inherent timing change
together. Native context must be compared and every inconclusive outcome retained.

## Recorder and checks

SettingsActivationInterval samples mach_continuous_time around one operation.
SettingsNativeClock reads kern.bootsessionuuid and mach_timebase_info in the
observed process. [Primary API evidence](causal-evidence/api-sources.txt) and
citations beside the non-obvious calls identify the contracts. Tick endpoints
encode as decimal strings, avoiding downstream integer rounding. Invalid boot
identity/scale fails metadata capture; the trace records an explicit error and
still performs the activation exactly once. Metadata reads occur only during
opt-in memory recorder initialization.

SettingsActivationTrace appends application.activate.interval after the existing
call. The existing window-then-activation order and before/after records remain.
Disabled and legacy-file modes call the same operation without new tick reads.
The wrapper constructs its interval record after the call, but existing
notification observers can run synchronously inside NSApp.activate and record
there. Their overhead is part of the measured call. No capture-free execution,
deferred-notification guarantee or timing neutrality is claimed. The new recorder
has not yet demonstrated symptom preservation or guest/native archive matching.

The [initial RED build](causal-evidence/interval-red.txt) fails because the new
types are absent. The [final controls](causal-evidence/interval-controls.txt) run
through check:settings-activation-interval: exactly-one-call ordering, disabled
clock bypass, lossless UInt64 encoding, real continuous-clock enclosure, rejected
metadata and independent sysctl/timebase agreement, plus the existing buffer
retention/dump controls. These test the recorder, not the product's failed
activation. The application also compiles in the task's build-tests step. The
initial build emitted unrelated existing test warnings; final results are retained.

The [sole reviewer](causal-evidence/review.txt) found two P2 limits. Correct the
overbroad outside-bracket capture claim while preserving observer evidence.
Narrow the causal hypothesis from all deferred mouse context to the necessity of
clicking the row, and require positive keyboard invocation evidence. Because the
latter changes interpretation, schedule fresh tree review before VM execution;
do not spend a second in-session review. No product repair follows from either.

## Reproduction and integrity

```sh
mise exec -- task check:settings-activation-interval
mise exec -- task report:settings-native-input ARCHIVE=.build/settings-activation/persisted/01/archive-audit/deferred-native/system.logarchive
```

The [frozen-input manifest](causal-evidence/subjects.sha256.gz) and
[after-check](causal-evidence/subjects-check.txt) cover the actual local archive,
its extracted regular files, the historical persisted originals and reference
documents, unchanged signed events candidate files, current recorder/call source,
manifests, tests, Taskfile, protocol, API inputs and Apple's decoder executable.
All consumed-input edits finish before final reproduction. The manifest is
[losslessly compressed](causal-evidence/subjects-format.txt) to fit jj's new-file limit. The [original audit](causal-evidence/original-audit.txt)
compares the raw archive digest and complete extracted inventory to historical
records, lossless committed rendering to the archived rendering, and the unchanged
events candidate's regular files/links to its historical inventory. The new
freeze does not claim an older measured manifest still matches the changed source
or Taskfile. No golden is changed and no guest is allocated.

Exploratory failures are retained in api-sources.txt: the first archive path was
absent, one guessed Apple source URL returned 404, and an exploratory jq display
rejected the completion object. Partial text was not treated as a successful
complete analysis. Final reproduction validates the full output independently.
The [documentation check](causal-evidence/doc-links.txt) retains the previously
known archived-context link failures owned by k23.

## Every original duty

The full tables in [FOCUS-RESULTS.md](FOCUS-RESULTS.md#every-original-duty),
[CLOCK-RESULTS.md](CLOCK-RESULTS.md#original-duties-and-remaining-work) and
[PERSISTED-RESULTS.md](PERSISTED-RESULTS.md#every-original-duty-and-remaining-work)
remain authoritative. This boundary checks them without replacing them.

| Original duty and owners | Outcome and remaining work |
|---|---|
| Historical classification, k12/k14/k16 | Diagnostic-02 delivered-callback/failed-activation and persisted corroboration unchanged |
| Clock relation, k29/k31/k33 | Old application relation unqualified; strict wall-clock false/empty joins preserved. New direct native recorder passes headless checks; actual guest/archive boot/scale and interval joins still require qualification |
| Supported condition/finite matched protocol, k33/k31/k29/k27/k25/k22/k20/k18/k16/k14 | Row-click necessity versus modality-independent context selected from saved input evidence and public interaction contracts; finite four-slot plan declared but revised interpretation awaits tree review and actual runtime implementation/freeze |
| Instrument availability/symptom/timing, same owners plus k12 | New recorder compiles; no new runtime outcome. Symptom preservation and target-guest matching unknown; synchronous observers and changed input timing remain explicit |
| Bound/freeze/completed golden before launch, same owners | Offline subjects frozen/audited. No new clone. All historical caps remain closed; future set needs actual signed subject/all inputs and completed golden hashes before its first slot |
| Acquisition/default fallback/lag, k25/k22/k20/k18 | Prior outcomes/lag preserved; broad saved read adds context, not a complete refusal monitor or new retention qualification |
| Retain transports/partials/NOT RUN/audit/stop, same causal owners | All originals preserved. Historical scenario/inner Task 1/201, native/collection/audit 1/1/1, outer Task 201 and timeout/-1 remain failed; clone was stopped. No clone here |
| Positive failed request/disposition/responsible context, same causal owners | Still open. Native input/window messages, shared tokens/-50, missing rows, green counts and a corrected clock relation cannot substitute for positive disposition/cause |
| Justified product repair/useful failing seam, same owners plus k12 | No product repair or final repair subject. Recorder tests are not a failing product seam |
| One selection, one front/focused Settings window, same owners | Persisted initial pass/reopen 1 failure unchanged; no driver wait/retry/repeated-input repair |
| Separate finite complete ordinary acceptance, same owners | NOT RUN. Select/freeze final ordinary subject/all inputs, disable diagnostics, use app:vm-verify-menu-bar, retain all outcomes/timing; focused modality probe is not acceptance |
| External owner/reproducer/approval, same owners | No external owner. Positive evidence/reproducer and unresolved repair required if external; no upstream report without Antony's approval |
| Root/verification/release constraints, same owners | Reconciled in both verification handoffs/root brief; no causal ancestor closes, no release/notarization or upstream report |

For persisted-01, reopens 2/3 and every later complete phase remain NOT RUN:
resize/minimum-size/content-height/scrolling, shortcuts, requests/denials,
Accessibility consent, silent launch, running-app reopen, login restart and Quit.
The new focused protocol does not inherit acceptance from older complete passes.
K33 decomposes at this tested recorder/offline-evidence boundary, with protocol
review before the live successor's matched experiment, disposition, justified
repair and separate complete ordinary acceptance.
