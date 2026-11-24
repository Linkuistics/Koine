# Settings reopen: recorded activation failure — 2026-10-28

The [concrete ordering design](../../specs/settings-activation-discrimination.md#single-request-ordering-design)
prepares the same retained window and requested section. It then requests
activation once, before key and front window ordering. The [distinct finite protocol](ORDERING-EVALUATION-PLAN.md)
sets two focused fresh guests. Only if both qualify do three separate complete
ordinary guests follow. One newly signed candidate must stay unchanged, with
diagnostics disabled in both sets.

On 2026-11-24, k54 froze one signed subject and ran E01. E01 stopped before the
first selection, because one required setup read was unavailable. E02, A01, A02
and A03 are NOT RUN, and the evaluation ended with no acceptance. The
[qualification results](ORDERING-QUALIFICATION-RESULTS.md) hold the record.
Antony then closed the repair as unresolved. [Issue #15](https://github.com/Linkuistics/Koine/issues/15)
brings the evaluation back, with a new declared sequence, freeze and slot identities.

The [design review and integration](ORDERING-REVIEW.md) are complete. The
[application record](ORDERING-APPLICATION-RESULTS.md) holds the k52 candidate
and its return. On 2026-11-25, the code returned to the order that 0.4.0
released. The show operation makes one key and front request, and then one
activation request. The candidate has no acceptance, and issue #15 can apply it again.

The [strict window transport expansion](ORDERING-WINDOW-RESULTS.md) supplied
checked list, action and poll helpers. K36 later adopted them in the complete
ordinary scenario, after independent review and before the k54 freeze. Both sets
require the same changed helpers: strict single-attempt transport and positive
TextEdit setup. They also require an audit of the original window list for the
Settings title, and liveness before zero-window rejection.

Process loss is separate. The prefix includes the TextEdit quit. Screenshots
retain context, and they are not automatic acceptance. A restart disconnect
stays unavailable despite a later boot. A known inability to obtain the required
clean completion holds E01 for a new decision.

Antony's [approved empirical scope](../../specs/settings-activation-discrimination.md#scope-after-no-candidate)
removes the documented API-use-violation prerequisite for this named hypothesis
only. A qualified recurrence rejects the reversal. Any other required failure or
unavailable evidence stops acceptance and the later slots, with no replacement or
expansion. A passing bound supports only that sample. Raw failed transport stays
retained, and later output does not clear it. The [source and API evidence](ORDERING-DESIGN-EVIDENCE.md)
records caller effects, public-contract limits and the existing test seams.

The [reviewed assessment](CORRECTION-ASSESSMENT.md) stays a bounded finding that
no API-use correction exists. Historical original-order and reversed-order
successes used synchronous file tracing, and its writes moved with the reversal.
Thus no instrument-free comparison or risk reduction follows. Repetition, driver
waits, retries, input workarounds, deferral and speculative yielding stay excluded.
Native cause and ownership stay unresolved. All six causal slots stay held, and
every historical cap stays closed.

The complete original-duty comparison stays in the contract. The assessment,
review and instrument handoffs below keep their earlier boundaries and results.
The new design changes no historical bytes, no classification and no strict
false clock join. It supplies no repair, ordinary-acceptance or ancestor-closure
result. It supplies no release, notarisation or upstream report.

K41's [protocol review integration](CAUSAL-PROTOCOL-REVIEW.md) repairs the offline
launch-prefix accounting, the final-control input and the positive mouse and
Return nonce criteria. No guest or product repair ran. A supported causal design
and its review still come before all route and causal guests. Native disposition
stays live. A justified repair or useful failing product seam and a separate
frozen complete ordinary acceptance stay live too.

The [implemented protocol boundary](CAUSAL-PROTOCOL-RESULTS.md) supplies checked
highlight, Return, transport and containment seams. It also supplies setup and
control policies that it sets in advance. Its narrow necessity question still lacks a finite
falsifier for the unrestricted competing possibility. Producer review and the
precise remaining causal-design work come before every guest, including route
qualification. No new guest, product repair, ordinary acceptance or causal
ancestor closure follows.

The [native-call recorder and input-context slice](CAUSAL-RESULTS.md) adds direct
tick brackets and the boot and timebase metadata of the observed process. It has
nine headless helper and buffer controls. The [review integration](CAUSAL-REVIEW.md)
retains a positive native ordering contrast. It finds the unstarted modality
proposal insufficient. K38's repaired protocol and route, and the review and
integration that they earn, come before k36's runtime freeze or launch.

No new guest, native disposition, product repair or ordinary acceptance follows.
Every earlier outcome and closed cap below and in the linked results stays
unchanged.

The second instrumented guest reproduced Settings reopen 3 behind TextEdit.
Koine received the Settings callback, showed its window and requested
activation. It recorded no later become-active or become-key notification for
that selection. Earlier selections in the same process recorded both. This
classifies **failed activation in the observed interval**. It supplies no cause
for the unsuccessful request and no product repair.

The first guest completed every scenario assertion. The diagnostic sample stops
at the first classified failure, as [declared before collection](PLAN.md).
Attempt 03 did not launch. These results are separate from the historical
results and the [k4 release comparison](../menu-bar-samples/README.md). They
establish no rate, no release regression and no external defect ownership.
Issue 14's activation outcome stays unresolved.

## Instrument and subject

The [frozen sources](diagnostic-source/) add opt-in JSON-lines observation to
`AppDelegate`, `MenuBarController` and a small main-actor recorder. The existing
`makeKeyAndOrderFront` → `NSApp.activate()` order is unchanged. The observation
records the Settings and status callbacks and the show and activation call
boundaries. It also records the menu opening and closure, the application active
and window key and main notifications, and the workspace activation notifications.

Each row includes the sequence, the selection, the process ID, the wall clock and
the monotonic uptime. It also includes the active, key, main and visible state,
the front process of the workspace and the current run-loop mode. The observation
requests no activation or input.

The guest-only preference `KoineSettingsActivationTrace` names the output file.
The scenario enables it before the first launch only when `KOINE_SETTINGS_TRACE=1`.
Ordinary operation leaves it disabled. Synchronous writes, native state queries
and observer registration can change the timing. The recorded failure in 02 shows
that the symptom can occur with this instrument. It proves no absence of timing
effects and no equivalence to the released binaries.

The signed current-source candidate identifies itself as 0.4.0, but it is **not
the released 0.4.0 bundle**. `mise exec -- task app` built it from the baseline
`1bdf31bd` with the saved diagnostic source overlay. The build used Apple Swift
6.4 and the checked-in package resolution. The [signature](diagnostic-signature.txt),
the [full relative file and link inventory](diagnostic-bundle.txt), the
[measured input hashes](diagnostic-subjects.sha256) and the
[freeze time](diagnostic-frozen-at.txt) identify the subject.

The signed bundle stays local at `.build/settings-activation/diagnostic/Koine.app`.
This report retains its inventory and source overlay, not an archived bundle.

Both guests accepted the strict, deep signature verification. Both reported
`Unnotarized Developer ID` at the Gatekeeper assessment. The separate
[`app:verify` result](diagnostic-app-verify.txt) also stops at the absent stapled
ticket after it passes the signature checks. No notarisation or release occurred.
The installation route sets no quarantine attribute, and it does not establish
Gatekeeper first-launch acceptance.

<!-- tc: depart synonym-rotation because a started attempt is a protocol state, while launch names an application launch -->
## Every started attempt

Both clones used macOS 27.0.1 / 26A434 / arm64 from
`testanyware-golden-macos-27`, TestAnyware 2.7.0 and a 1920×1080 initial screen size.
The [tool resolution](tools.txt) and the [doctor output](doctor.json) retain the
host details. The restart of 01 restored 1024×768. 02 stopped before the restart,
at 1920×1080. The times below are host UTC.

No attempt or Settings selection was retried to obtain a pass. The scenario keeps
its existing bounded retries for safe guest reads.

| Attempt / clone | Start → scenario end | Scenario / Task exits | Collection / subject audit / stop exits | Outcome |
|---|---|---|---|---|
| [01](diagnostic-01/task.log), `koine-k12-diagnostic-01` | 02:55:55 → 03:10:18 | 0 / 0 | 1 / 1 / 0 | Every scenario assertion passed. The final inventory transport failed |
| [02](diagnostic-02/task.log), `koine-k12-diagnostic-02` | 03:11:03 → 03:18:39 | 1 / 201 | 0 / 0 / 0 | Settings reopen 3 failed. The activation classification is below |

Collection completed at 03:10:48 and at 03:19:10. Each directory retains the
original scenario artifacts, the raw exec envelopes, the trace and the timestamps.
It also retains the separate exits, the full host inventories and the clone stop
result. A collection audit does not qualify every observer. The native snapshot
of 02 timed out, even though its installed-bundle read succeeded. No run was
interrupted or replaced.

## Assertion coverage

PASS means that the scenario ran that assertion. NOT RUN takes no acceptance from
the other attempt.

| Assertion group | 01 | 02 |
|---|---|---|
| First launch: frame/title, agent status, no Dock icon, one item, label/menu | PASS | PASS |
| TextEdit in front before the requested reopen | PASS | PASS |
| Initial Settings action returns the window in front and focused | PASS | PASS |
| Settings reopen 1 | PASS | PASS |
| Settings reopen 2 | PASS | PASS |
| Settings reopen 3 | PASS | FAIL |
| User-input growth, minimum frame and measured content height | PASS | NOT RUN |
| Minimum-size scrolling to login, grant label and Accessibility | PASS | NOT RUN |
| Typing, select/copy/cut/paste, Command-W and retained item | PASS | NOT RUN |
| Two client requests update the menu without opening a window | PASS | NOT RUN |
| Requests navigation, visible request row and both denials | PASS | NOT RUN |
| Accessibility navigation and visible status | PASS | NOT RUN |
| System Settings consent and removal of warning label/menu line | PASS | NOT RUN |
| Login enable, menu Quit, stopped server and silent manual launch | PASS | NOT RUN |
| Running-application reopen shows/focuses Settings | PASS | NOT RUN |
| Settings focus, Command-Q, stopped server and changed boot time | PASS | NOT RUN |
| Login launch: process/endpoint/item, no window, agent status | PASS | NOT RUN |
| Final Quit, missing process/endpoint and old-port refusal | PASS | NOT RUN |
| Scenario's final installed inventory | PASS | NOT RUN |

01 grew to 703×903 and reached a 440×352 minimum outer frame with
[320 measured content pixels](diagnostic-01/menu-bar-20261028T135555-least-size-content.json).
Its transcript and its minimum-size screenshot retain the scroll assertions.
02 supplies no resize, scrolling, consent, shortcut, login or Quit acceptance.

## Classification of the reproduced failure

The [94-row trace](diagnostic-02/trace.jsonl) is one process, PID 706, with
[contiguous sequence numbers](diagnostic-02/trace-integrity.json). Its first
three Settings selections became active and key. Selection 4 is the failing
reopen 3. The [extracted rows](diagnostic-02/failing-selection.tsv) preserve its
exact event order. The times below are guest Unix wall-clock seconds.

| Sequence / time | Event | Observed state |
|---|---|---|
| 88 / 1793157517.142921 | Menu did close | Koine inactive, TextEdit frontmost |
| 89 / 1793157517.143379 | Settings callback entry, selection 4 | Window hidden, no key window |
| 90–91 | Show entry and window-show call | Same inactive state |
| 92 / 1793157517.144069 | Window-show call returned | Settings visible, inactive, no key window |
| 93–94 / ending 1793157517.144757 | Activation request and return | Inactive, TextEdit frontmost, no key window |
| 1793157520.533932 | Independent native observer's own timestamp | The returned data says that TextEdit is active and in front, with Koine inactive behind it. The exec reports a timeout |

No later become-active or become-key notification is recorded for selection 4.
Selection 3 in the same process differs: callback 1793157511.436742 → become-key
1793157511.459822 → become-active 1793157511.465359. An explicit window close
followed it, before selection 4. The [trace of the first guest](diagnostic-01/trace.jsonl)
also shows that an inactive state at the `activate()` return alone does not mean
failure. Its successful selections become active later.

The failed selection therefore reached the callback and the activation request.
No observed successful activation was followed by a loss. The classification
uses the monitored notification sequence and the failed front-window assertion.
It also uses the [agent windows](diagnostic-02/failure-windows.json), the
[original screenshot](diagnostic-02/menu-bar-20261028T141103-failure.png) and the
[later screenshot](diagnostic-02/failure-observed.png). These visible and agent
observations agree that TextEdit stayed in front of the inactive Settings window.

Collection came before any keyboard, focus, repeated-action or application-launch
intervention.

The [fresh native snapshot](diagnostic-02/failure-native.json) returns complete
agreeing JSON. It also reports `timed_out: true`, exit -1 and a timeout on stderr.
It is a failed exec outcome, not a qualified successful native read. It was not
retried. Native notifications are delivered observations, not an atomic
WindowServer history. The trace has no periodic heartbeat after its last row.

The result does not prove that every possible transient native state was
observed. It does not explain why the activation did not complete.

The recorded mode of the callback is `kCFRunLoopDefaultMode`, and `menu.didClose`
comes before it. It does not follow that this callback still runs inside menu
tracking. It does not follow that a wait for the menu closure is the demonstrated
repair. Apple's [`activate()` contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
permits a request that does not activate the app.

The remaining question is which application or native activation condition
prevents this delivered request from producing an active, key Settings window.
Neither external defect ownership nor an application repair is established.

## Integrity, controls and continuation

The input checksum checks before and after each attempt pass. The complete host
file and link inventories match the frozen bundle item by item. Both initial guest
inventories match that bundle. The separate installed read of 02 after the failure
completes without a timeout, and its [comparison](diagnostic-02/installed-diff.txt)
is empty.

The scenario of 01 reached its final installed inventory. The independent
[final read](diagnostic-01/installed-after.json) of the wrapper timed out. Its
[returned text comparison](diagnostic-01/timedout-inventory-text-diff.txt)
matches. That match does not turn its failed transport into a successful read.
These endpoint comparisons establish no continuous runtime immutability.

The [golden before](golden-before.sha256), the [golden after](golden-after.sha256)
and the [comparison](golden-diff.txt) match for config, disk and NVRAM. The
[final subject check](final-subject-check.txt) still matches every frozen input.
The [artifact comparisons](artifact-checks.txt) check each retained original
against its collection file. The explicit stop results for
[01](diagnostic-01/stop.json) and [02](diagnostic-02/stop.json) retain the cleanup.
The [VM inventory](vms-after.json) and the [Tart states](tart-after.txt) retain it too.

The sole [fresh-context review](review.txt) found three capture gaps before
collection. Five focused controls failed against the initial wrapper and pass
after the repair. They cover the early-failure installed capture, an added host
file, a changed symlink, a changed installed endpoint and an interruption with
evidence collection. These checks exercise script outcomes, not native activation
reliability. The existing eight pointer and nine resize controls also pass in the
[final focused checks](final-checks.txt).

`task check:vm-settings-activation` checks the capture seam without a VM.
`task app:vm-settings-activation CLI_ARGS='diagnostic 01'` names one frozen
attempt, and started attempts refuse overwrite. **Do not run a third diagnostic
attempt.** The protocol met its stop at the first classified failure. The next
Grove child owns causal discrimination and a focused failing check where useful.
It also owns an application repair and its own predeclared bounded complete-scenario sample.

A test-driver wait or retry is no product repair. No release or upstream report
was made.

## Subsequent call-order comparison

The separate [four-guest ordering experiment](ORDER-RESULTS.md) finishes its
declared cap. It has one original-order failure, two reversed-order passes and
one original-order pass. Both orders can produce active and key windows. The
results do not disprove the reversal. They establish neither its sufficiency nor
the cause of the intermittent failure.

The moved synchronous trace writes also keep the timing limitation. The ordinary
application call order was restored after the final subject audit. No
ordinary-operation repair acceptance ran.

The new failed attempt again reaches the callback, the show and the activation,
and it records no later active or key transition. Its native snapshot reports a
timeout and -1, despite agreeing returned text. One passing reversed-order attempt
has a final installed inventory timeout, and it keeps collection and audit at 1/1.
Two final environment reads also time out.

Every available clean installed inventory and all host and golden checks match.
Every clone stops. All four focused attempts leave resize and every later
complete-scenario phase NOT RUN. The full report retains every outcome and the
remaining native request and disposition question. Both completed samples stay
closed to further attempts. Settings activation stays unresolved.

`task check:vm-settings-order` checks the focused scripts and the existing capture
controls without a VM. The `app:vm-settings-order` Task entries retain the exact
finite experiment route. They do not authorise a reset of the completed sample.

## Subsequent native-log qualification

The [separate two-guest native-log qualification](NATIVE-RESULTS.md) passes all
four Settings actions in both guests. It correlates the actual NSApp call to a
native client call, a WindowServer front-process change and resume, and the active
and key notifications. This supplies successful controls for the native path. No
failed case occurs under the added instrument. Thus its request and disposition
behaviour on failure and its preservation of the symptom stay unqualified.

The broad debug stream and the synchronous trace can affect the timing.

Every recorded scenario, native capture, installed and host inventory, golden hash
and clone-stop outcome passes. All full-scenario phases after the Settings prefix
stay NOT RUN. The finite native sample has reached its cap, and it must not grow.
All original failed evidence stays. Settings activation is still unresolved, with
no product repair and no complete ordinary-operation acceptance.

The linked report identifies the remaining question of context and trace timing.
It preserves the raw compressed native logs. No release or upstream report occurred.

## Reduced native-context follow-up

The [reduced-filter, trace-disabled evidence](CONTEXT-RESULTS.md) preserves three
budgeted guests. Two preflight instrument failures came before the application
launch. One focused guest then passed all four Settings assertions. The native
client, front-change and resume records stay successful controls only. Several
final transports time out. The first golden digest overlaps the clone launch by
four seconds.

These limits and both corrective charters are explicit. No failed native
disposition, causal repair, complete ordinary-operation acceptance or external
owner follows. All historical failures, classifications and closed sample caps
stay unchanged.

## Repaired default actual-path retention — k26

The one [retention guest](RETENTION-RESULTS.md) passes four Settings actions. It
retains an actual Koine client call inside every buffered activation interval,
with no live native output reader. That report holds the per-selection collection
lags, the native front-change and foreground records, the raw responses and all
original duties. No failed disposition or causal repair is observed. The symptom
preservation under the reduced load stays unqualified. The sample is closed.

The final environment and installed-bundle transports time out despite agreeing
text, so collection and audit stay failed. The initial raw endpoint, the
acquisition and dump, and the checked stop are clean. The frozen inputs and the
completed golden hashes match. All later complete-scenario phases stay NOT RUN.

K27 owns a supported causal hypothesis and a discriminating protocol. It also owns
every original repair duty and the separately declared complete ordinary-acceptance
duty. No product repair, reliability rate, external ownership, release,
notarisation or upstream report follows.

## Persisted Debug reproduces reopen 1 failure

The [one-guest persisted result](PERSISTED-RESULTS.md) retains a failed reopen.
Memory, native, window and visible observations corroborate it, and it has useful
deferred native Debug output. The strict wall-clock joins fail for both selections.
Thus the clock correlation, the explicit failed disposition and the responsible
context stay unqualified. The shared token results are not a cause. No application
repair or ordinary acceptance follows.

That report retains all earlier failures, failed transports and unrun phases.

## Offline native clock boundary

The [offline clock result](CLOCK-RESULTS.md) establishes the boot-specific native
scale of the retained guest through Apple's decoder. The numerical tick and uptime
enclosure stays conditional, because the application boot, origin and sleep
calibration was not recorded. Exact joins stay unqualified, and the old false
wall-clock result is unchanged. No guest, application change or repair acceptance ran.

The successor carries the measured-clock and native-disposition work. It also
carries every original causal repair duty and the separate complete
ordinary-acceptance duty.

## Independent native focus comparison

The [offline focus comparison](FOCUS-RESULTS.md) finds the terminal viewbridge
marker of TextEdit, adjacent to the failure, before successful Koine native front
changes too. The presence of the marker alone cannot discriminate failure. The
different native instruments do not establish a matched causal comparison. Strict
reusable extraction retains full records and source positions, and it rejects
malformed input.

No guest or product change ran. The full original-duty comparison of the report
keeps four items open. They are the native failed disposition, the old
application clock relation, a justified repair and a separate complete ordinary
acceptance.
