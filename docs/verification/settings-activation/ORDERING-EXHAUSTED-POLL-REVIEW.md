# Review of the exhausted-poll failure observations

Review task: `settings-exhausted-poll-observations-k167`.
Reviewed commits: k166 `9f5126aacee812afcd7bf9e44c1b6a691d639b93` and
k165 `bd8fa49f4565a543d635d5658558bfa56fc8fd93`.

Two findings meet the acceptance and material-risk threshold. The deferred
interface does not reserve status 1 for clean exhaustion, and one existing
menu assertion still changes the guest before the new failure observations.
Both findings follow from the source. No test, build, lint, format command,
VM, clone or runtime slot ran in this review. No production or test code changed.

## P2-1: a backend exit of 1 reaches the clean-exhaustion branch

Location: `scripts/vm-settings-scenario-lib.sh:201–207`, with
`scripts/vm-click-evidence-lib.sh:87` and
`scripts/vm-guest-exec-lib.sh:24–43`.

`settings_poll_failed` treats every status 1 as clean exhaustion. However,
`_guest_evidence_backend` returns the Python backend's original status even
when it had to write the fallback `unavailable` latch and
`facade-refusals.log`. A backend exit of 1, such as an uncaught backend
exception, is therefore also a possible facade return. The latch records the
failure but does not change that return value.

The shortest counterexample is the Allow OCR read:

1. The backend fails with status 1 for `automation-allow-ocr`.
2. `read_guest_text` returns 1. `click_guest_allow` propagates it at its
   `response=... || return`, without evaluating the exact-target predicate.
3. `settings_grant_system_events_automation` passes 1 to
   `settings_poll_failed`. It takes the failure observations and submits
   `automation-allow-exact-target`, phase `exhausted`, local status 1.
4. If the backend is available for that later local record, it writes
   `state-failed` and returns 125. `vm-guest-exec.py:820–829` submits poll
   records in the evidence class, and `run_locked` admits that class despite
   a prior latch. Thus an unavailable OCR read gains an assertion-failure
   receipt although no clean OCR result established a missing exact target.

The endpoint, System Events and window poll loops also accept a propagated
backend status 1 as a false state. An early occurrence reaches an extra sleep;
an occurrence at the terminal read or state-record boundary can reach deferred
exhaustion. The TextEdit final assertion is one such terminal boundary. A
backend failure while recording a failed sleep can return 1 through the same
interface. A normally recorded transport or sleep failure returns 125, or the
declared interruption status, and takes the correct stop path.

The original unavailable latch remains, so this is not evidence that a failed
transport can produce acceptance. It is a false clean-exhaustion decision and
a conflicting failure receipt. It violates the k36 rule that a failed transport
never becomes negative state, and the k166 contract that only clean exhaustion
takes this observation path. It also undermines the report's claim that an
unavailable read takes no observations.

The new scenario control at `Tests/scripts/vm-settings-scenario.bats:861–879`
injects the simulator's default status 125. It does not cover status 1.
`settings-scenario-backend.py:945–949` already supports an explicit
`settings_fault_status`, so the missing case has an existing seam. The source
counterexample above corresponds to `settings_fault=automation-allow-ocr`
with `settings_fault_status=1`; this review did not execute it. The terminal
poll boundaries need coverage as well as the first read.

Required outcome: keep backend failure distinct from clean false state through
the deferred interface. Retain the original backend status as evidence, the
signal statuses and the first latch reason. No unavailable read or failed
sleep may acquire a clean-exhaustion decision. Integration owns the repair
and controls that fail on this collision.

## P2-2: a menu mismatch sends Escape before its failure observations

Location: `scripts/vm-settings-scenario-lib.sh:459–471`, reached by
`scripts/vm-verify-menu-bar.sh:100`, among other menu checks.

`expect_guest_menu` has already compared the menu titles and recorded a clean
false state when `settings_expect_menu` receives status 1. Nevertheless, the
caller unconditionally sends `OPERATION-close` with the Escape key and waits
one second. Only then does it call `settings_fail`. The k165 change adds the
observer, window list and screenshot inside that final function.

Consequently, a clean menu-title mismatch is captured after corrective input.
Escape can close the offending menu, and the wait lets the guest state change
before all three observations. If Escape itself fails, the scenario stops on
that input failure without reaching the assertion's new observations.
Retaining the earlier raw title list does not make the subsequent observations
untouched.

The protocol at `ORDERING-EVALUATION-PLAN.md:187–193` requires the fresh failure
observations and prohibits corrective input after a failed assertion. k165's
claim that the new `settings_fail` path satisfies that duty for every clean
single-read failure is therefore incomplete. This ordering predates k165;
the finding concerns the duty k165 claims to have repaired, not a new menu
input introduced by k166.

The added k165 plain-failure control injects a resize failure. The common
`input_after` checks usually start at the final `scenario-assertion` receipt,
which is after Escape in this path. Such a check cannot detect this defect.
Required outcome: exercise a clean menu-title mismatch and require untouched
observations before any later input, with no corrective close on failure.
Keep the successful menu-close input and wait unchanged. Reconcile the duty
comparison and the k164/k57 handoff with the actual result.

## Other doubts and evidence

| Question | Inspection result |
|---|---|
| Do the deferred receipts retain the facade's identity? | On clean exhaustion, the launch endpoint, label, item frame, row frame, TextEdit and Allow paths pass the former receipt name and shared predicate to `record_guest_poll`. Its exhausted phase returns 125 and writes `state-failed`. P2-1 limits the claim that every such receipt has clean exhaustion as its cause. |
| Do success paths or legacy lanes change? | The diff retains the same predicates, loop limits, delays and success output. The frame mode is a fourth argument, so a three-argument call whose title is `deferred` remains a row lookup. The TextEdit final assertion remains after its poll. The facade controls inspect these properties, and the recorded prefix check identifies the first 154 lines through TextEdit quit. |
| Can observations replace the original assertion evidence? | The new label path retrieves its failure-message record before adding observation records. The count path uses the last list returned by the poll. The front/title paths keep `SETTINGS_LIST` and `SETTINGS_FRONT`; the failure observer writes separate records and `SETTINGS_OBSERVED_FRONT`. Originals are not replaced by later window lists. |
| Can the observer change the guest? | `vm_exec_reads.py:803–863` explicitly marks System Events reads as capable of starting System Events or raising consent. They are not admitted as evidence-class reads. The existing visible trade-off skips this observer until the Automation check passes and still takes the window list and screenshot. The source gate and its two recorded mutations support that bounded rule; they do not establish native neutrality. |
| Are all failed assertions covered? | Generic and classified failures, count/reveal exhaustion, front/title failures, the Add loop and the listed deferred facade exhaustions reach the observation functions. The menu-mismatch path still changes the guest first, as P2-2 records. Unavailable answers use `settings_stop`, retaining their own failure and a screenshot; P2-1 identifies the status collision that can bypass this distinction. |
| Do the exclusions hide a Koine recurrence? | The restart boot poll explicitly reports a test-driver or guest failure and stops the scenario. It supplies no Koine recurrence or pass. The `await_guest_element` exclusion is supported within the shell-script scope: the graph has no inbound call, and a literal search of `scripts/*.sh` finds its declaration/comment only. The adopted scenario instead uses its own reveal and Add loops. This is not a claim about dynamic callers outside that scope. |
| Would the recorded controls reject their named faults? | The k166 red record has fourteen failures and one pre-existing-property pass. The deferred facade controls check bounds, waits, predicates, final assertion, positive results and argument refusals. The two k166 mutations reject a label message read after the observer and a receipt placed before the observations. The k165 mutations reject opening the observer gate too early or never opening it. These controls do not cover P2-1's backend status 1 or P2-2's menu mismatch. |

The review read the retained red, mutation and final verification records in
`ordering-exhausted-poll-evidence/`, and the k165 mutation records in
`ordering-prefix-integration-evidence/`. The k166 final record contains nineteen
Taskfile sections and 346 `ok` lines. Its JSON receipt records status 0 and
unchanged subjects. A read-only digest comparison confirmed the output log and
subject manifest against that receipt, and confirmed sixteen current source,
facade and test files against the manifest. There were no mismatches among
those sixteen files. This establishes correspondence with the retained run;
it does not reproduce that run or settle the two findings.

## Scope and handoff

Graph evidence used project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, generation
`2026-11-22T19:56:51Z`, at Verify tier. Symbol searches and the relevant traces
were untruncated. Coverage reported partial parsing in the scenario and four
facade libraries, and untracked Bats coverage. The review read the scenario
and reviewed facade libraries directly, including the reported missed ranges,
and examined the controls in source. Broader `scripts` coverage was enumerated, but unrelated
coverage gaps were not audited. No repository-wide completeness claim follows.

The paired integration must triage these findings against this commit and the
protocol, apply bounded repairs and run the appropriate reusable checks. It
must finish before k164 consumes the scenario. k57 still owns the complete
pre-runtime reconciliation; k54 still owns freeze and runtime. No empirical
budget, subject, retry, wait or acceptance duty changes in this review.
