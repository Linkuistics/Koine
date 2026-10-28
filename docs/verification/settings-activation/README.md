# Settings reopen: recorded activation failure — 2026-10-28

The second instrumented guest reproduced Settings reopen 3 behind TextEdit.
Koine received the Settings callback, showed its window and requested
activation. It recorded no subsequent become-active or become-key notification
for that selection. Earlier selections in the same process recorded both.
This classifies **failed activation in the observed interval**. It supplies no
cause for the unsuccessful request and no product repair.

The first guest completed every scenario assertion. The diagnostic sample stops
at the first classified failure, as [declared before collection](PLAN.md).
Attempt 03 did not start. These results are separate from the historical and
[k4 release comparison](../menu-bar-samples/README.md); they establish no rate,
release regression or external defect ownership. Issue 14's activation outcome
remains unresolved.

## Instrument and subject

The [frozen sources](diagnostic-source/) add opt-in JSON-lines observation to
`AppDelegate`, `MenuBarController` and a small main-actor recorder. The existing
`makeKeyAndOrderFront` → `NSApp.activate()` order is unchanged. Observation
records the Settings/status callbacks, show/activation call boundaries, menu
opening/closure, application active and window key/main notifications, and
workspace activation notifications. Each row includes sequence, selection,
process ID, wall clock, monotonic uptime, active/key/main/visible state, workspace
front process and current run-loop mode. It requests no activation or input.

The guest-only preference `KoineSettingsActivationTrace` names the output file.
The scenario enables it before first launch only when `KOINE_SETTINGS_TRACE=1`.
Ordinary operation leaves it disabled. Synchronous writes, native state queries
and observer registration can alter timing. The recorded failure in 02 shows
the symptom can occur with this instrument; it proves no absence of timing
effects and no equivalence to the released binaries.

The signed current-source candidate identifies itself as 0.4.0 but is **not the
released 0.4.0 bundle**. It was built with `mise exec -- task app` from baseline
`1bdf31bd` plus the saved diagnostic source overlay, with Apple Swift 6.4 and
the checked-in package resolution. The [signature](diagnostic-signature.txt),
[full relative file/link inventory](diagnostic-bundle.txt),
[measured input hashes](diagnostic-subjects.sha256) and
[freeze time](diagnostic-frozen-at.txt) identify the subject. The signed bundle
is retained locally at `.build/settings-activation/diagnostic/Koine.app`; this
report retains its inventory and source overlay, not an archived bundle.

Both guests accepted strict/deep signature verification. Both reported
`Unnotarized Developer ID` at Gatekeeper assessment. The separate
[`app:verify` result](diagnostic-app-verify.txt) also stops at the absent stapled
ticket after passing signature checks. No notarization or release was performed.
The installation route sets no quarantine attribute and does not establish
Gatekeeper first-launch acceptance.

## Every started attempt

Both clones used macOS 27.0.1 / 26A434 / arm64 from
`testanyware-golden-macos-27`, TestAnyware 2.7.0 and a 1920×1080 initial display.
[Tool resolution](tools.txt) and [doctor](doctor.json) retain host details.
01's restart restored 1024×768; 02 stopped before restart at 1920×1080.
Times below are host UTC. No attempt or Settings selection was retried to obtain
a pass. The scenario retains its existing bounded retries for safe guest reads.

| Attempt / clone | Start → scenario end | Scenario / Task exits | Collection / subject audit / stop exits | Outcome |
|---|---|---|---|---|
| [01](diagnostic-01/task.log), `koine-k12-diagnostic-01` | 02:55:55 → 03:10:18 | 0 / 0 | 1 / 1 / 0 | Every scenario assertion passed; final inventory transport failed |
| [02](diagnostic-02/task.log), `koine-k12-diagnostic-02` | 03:11:03 → 03:18:39 | 1 / 201 | 0 / 0 / 0 | Settings reopen 3 failed; activation classified below |

Collection completed at 03:10:48 and 03:19:10 respectively. Each directory
retains original scenario artifacts, raw exec envelopes, trace, timestamps,
separate exits, full host inventories and clone stop result. A collection audit
does not qualify every observer: 02's native snapshot timed out even though its
installed-bundle read succeeded. No run was interrupted or replaced.

## Assertion coverage

PASS means the scenario ran that assertion. NOT RUN gives no acceptance from
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
Its transcript and minimum-size screenshot retain the scroll assertions.
02 supplies no resize, scrolling, consent, shortcut, login or Quit acceptance.

## Classification of the reproduced failure

The [94-row trace](diagnostic-02/trace.jsonl) is one process, PID 706, with
[contiguous sequence numbers](diagnostic-02/trace-integrity.json). Its first
three Settings selections became active and key. Selection 4 is the failing
reopen 3. The [extracted rows](diagnostic-02/failing-selection.tsv) preserve its
exact event order; times below are guest Unix wall-clock seconds.

| Sequence / time | Event | Observed state |
|---|---|---|
| 88 / 1793157517.142921 | Menu did close | Koine inactive; TextEdit frontmost |
| 89 / 1793157517.143379 | Settings callback entry, selection 4 | Window hidden; no key window |
| 90–91 | Show entry and window-show call | Same inactive state |
| 92 / 1793157517.144069 | Window-show call returned | Settings visible; inactive; no key window |
| 93–94 / ending 1793157517.144757 | Activation request and return | Inactive; TextEdit frontmost; no key window |
| 1793157520.533932 | Independent native observer's own timestamp | Returned data says TextEdit active/in front, Koine inactive behind it; exec reports timeout |

No subsequent become-active or become-key notification is recorded for
selection 4. This contrasts with selection 3 in the same process: callback
1793157511.436742 → become-key 1793157511.459822 → become-active
1793157511.465359, followed by an explicit window close before selection 4.
The [first guest's trace](diagnostic-01/trace.jsonl) also demonstrates that an
inactive state at `activate()` return alone does not mean failure: its successful
selections become active later.

The failed selection therefore reached the callback and activation request.
There is no observed successful activation followed by a loss. The classification
uses the monitored notification sequence plus the failed front-window assertion,
[agent windows](diagnostic-02/failure-windows.json),
[original screenshot](diagnostic-02/menu-bar-20261028T141103-failure.png) and
[subsequent screenshot](diagnostic-02/failure-observed.png). These visible and
agent observations agree that TextEdit stayed in front of inactive Settings.
Collection preceded any keyboard, focus, repeated-action or application-launch
intervention.

The [fresh native snapshot](diagnostic-02/failure-native.json) returns complete
agreeing JSON, but reports `timed_out: true`, exit -1 and a timeout on stderr.
It is a failed exec outcome, not a qualified successful native read. It was not
retried. Native notifications are delivered observations, not an atomic
WindowServer history; the trace has no periodic heartbeat after its last row.
The result does not prove that every possible transient native state was
observed or explain why activation did not complete.

The callback's recorded mode is `kCFRunLoopDefaultMode`, and `menu.didClose`
precedes it. A claim that this callback still runs inside menu tracking, or that
waiting for menu closure is the demonstrated repair, does not follow. Apple's
[`activate()` contract](https://developer.apple.com/documentation/appkit/nsapplication/activate())
permits a request not to activate the app. The remaining question is which
application or native activation condition prevents this delivered request from
producing an active, key Settings window. Neither external defect ownership nor
an application repair is established.

## Integrity, controls and continuation

Both attempts' pre/post input checksum checks pass; complete host file/link
inventories match the frozen bundle item by item. Both initial guest inventories
match that bundle. 02's separate post-failure installed read completes without
timeout and its [comparison](diagnostic-02/installed-diff.txt) is empty. 01's
scenario reached its final installed inventory, but the wrapper's independent
[final read](diagnostic-01/installed-after.json) timed out. Its
[returned text comparison](diagnostic-01/timedout-inventory-text-diff.txt) matches;
that does not turn its failed transport into a successful read. These endpoint
comparisons establish no continuous runtime immutability.

[Golden before](golden-before.sha256), [after](golden-after.sha256) and
[comparison](golden-diff.txt) match for config, disk and NVRAM. The
[final subject check](final-subject-check.txt) still matches every frozen input,
and [artifact comparisons](artifact-checks.txt) confirm each retained original
against its collection file. Explicit stop
results for [01](diagnostic-01/stop.json) and [02](diagnostic-02/stop.json),
[VM inventory](vms-after.json) and [Tart states](tart-after.txt) retain cleanup.

The sole [fresh-context review](review.txt) found three capture gaps before
collection. Five focused controls failed against the initial wrapper and pass
after repair: early-failure installed capture, added host file, changed symlink,
changed installed endpoint and interruption with evidence collection. These
checks exercise script outcomes, not native activation reliability. The existing
eight pointer and nine resize controls also pass in the
[final focused checks](final-checks.txt).

`task check:vm-settings-activation` checks the capture seam without a VM.
`task app:vm-settings-activation CLI_ARGS='diagnostic 01'` names one frozen
attempt; started attempts refuse overwrite. **Do not run a third diagnostic
attempt:** the protocol's first-classified-failure stop has been met. The next
Grove child owns causal discrimination, a focused failing check where useful,
an application repair and its own predeclared bounded complete-scenario sample.
A test-driver wait or retry is no product repair. No release or upstream report
was made.
