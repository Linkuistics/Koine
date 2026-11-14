# settings-window-transports-k72

**Reviews:** settings-window-transports-k70

## Goal
Independently challenge the strict window transport expansion before any ordinary
scenario consumption. Produce findings, without fixes or runtime.

## Context
Read the committed k70 artifact: scripts/vm-window-evidence-lib.sh, its Bats
controls and Taskfile check, plus docs/verification/settings-activation/
ORDERING-WINDOW-RESULTS.md and ordering-window-evidence. Grade against the k66
parent charter, reviewed ORDERING-EVALUATION-PLAN.md and the actual immutable
v2.7.0 WindowInfo/agent handlers named in the source receipt. The shared adapter
is documented in ORDERING-NONEXEC-RESULTS.md and implemented in vm-guest-exec.py.
Do not treat simulated responses as guest availability or product evidence.

## Done when
- Find substantive mismatches between the artifact and its contract. Inspect
  complete-list retention, actual optional/required fields, action submission
  versus downstream confirmation, explicit-root refusal, shared writer/latch
  participation and eligibility after failure/collection.
- Challenge the negative-poll boundary: only complete clean list negatives may
  advance; no failed matching text, malformed/partial completion, local decoder
  failure or ignored signal may become success. Check fixed bounds/waits and
  separate clean-exhaustion versus transport records, including conditional
  callers and shell substitutions. Compare controls to the real source; identify
  blind spots rather than taking green tests as the contract.
- Check the narrow expansion boundary and preserved obligations: ordinary
  adoption remains live, K71 must migrate the separate post-loop TextEdit read
  and every other original k66 duty, K67 owns positive setup/title/liveness,
  and K62/K57/K54 retain final prefix, containment and readiness. Both held-pointer
  signal cases remain owed; this window helper is not complete signal handling.
- Inspect red/green provenance and final digest/Taskfile receipts. The two known
  archive-link failures are k23's existing work, not permission to rewrite history.
  State verified findings with exact source/contract evidence, or explicitly no
  substantive findings. Every earned integration must precede k71 consumption.

## Notes
No VM, signed subject, freeze, native acceptance, scope relaxation or ancestor
closure. Review the committed producer artifact under the review-impl discipline.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k70 commit 846e0d91 and the shared adapter. Read the official v2.7.0
  sources from the local TestAnyware tag objects. Their digests match the
  k70 source receipt. Read clap_builder 4.6.0, which the v2.7.0 lock pins.
  Run no test, build, lint or VM command.

## Findings

Severity: P2 means a defect in a strict guarantee that k71, k67 or k57 would
rely on. P3 means a narrower defect, a retention gap or a control gap.

Line numbers refer to commit 846e0d91. "The library" is
`scripts/vm-window-evidence-lib.sh`. "The adapter" is `scripts/vm-guest-exec.py`.
"Bats" is `Tests/scripts/vm-window-evidence.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-WINDOW-RESULTS.md`. "The plan"
is `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.

### P2-1. TextEdit exhaustion latches, so k71 cannot migrate the post-loop read

The legacy TextEdit setup makes fifteen reads. After each negative read it
sleeps two seconds, the fifteenth included. Then it makes one more read, which
is the assertion (`scripts/vm-verify-menu-bar.sh:115-121`). Thus a TextEdit
window that appears during the fifteenth sleep passes the legacy setup.

`await_guest_textedit_window` makes the fifteen reads and the fifteen sleeps.
Then it records `OPERATION-exhausted` through `fail_guest_evidence` (library:110,
131). That confirmation latches `unavailable` (adapter:277-278). After the latch,
the adapter refuses every `read-poll` and `one-shot` dispatch (adapter:239-240).
Bats:135-153 asserts this latch for the TextEdit case.

The report (lines 60-63) and the k66 handoff tell k71 to migrate the separate
post-loop read. With this helper, that read cannot dispatch. Only the `evidence`
class passes the latch, and that class is collection, not a scenario assertion.

Consequence: the strict path fails a run at a point where the legacy scenario
continues. This changes the existing TextEdit bound, which k70 had to preserve.
The report states the opposite, so k71 would start from a false premise.

Smallest correction: make the post-loop read part of the helper. That gives
fifteen reads with a sleep after each negative read, then one final read with no
sleep. Latch only when that final read is negative. Alternatively, let the
fifteen-read loop end without a latch and leave the final read as the one call
whose negative result latches. Either correction must also change Bats:135-153
and the report.

### P3-1. Exhaustion has the same structured outcome as unavailable evidence

The plan separates two results: "An exhausted clean poll bound is the named
state failure; an errored poll is unavailable" (plan:225-226). For the Koine
count of one, exhaustion is the zero-window branch of a qualified recurrence
(plan:168-181).

K70 records exhaustion with `fail_guest_evidence`. Its `result.json` has
`outcome: "unavailable"`, and the latch file has the same name (adapter:312-322).
A failed local state predicate (library:123-125) makes a record of the same
shape: transport `confirmation`, outcome `unavailable`. Only the operation
suffix `-exhausted` and the reason text tell the two apart. The caller chooses
the operation names, so the suffix is not a reserved marker. When a poll
succeeds, no receipt records the state predicate that made the earlier reads
negative.

Consequence: a classifier that reads the outcome field cannot tell a measured
zero-window recurrence from failed evidence. It would record the recurrence as
unresolved. The report hands this separation to k71 and k67 (report:74-77). But
it names no structured field for them to use.

Smallest correction: give exhaustion a structured discriminator that a
predicate failure cannot produce. Alternatively, state in the report and the
k71 handoff the exact fields that identify exhaustion. Record the state
predicate in a receipt for each poll.

### P3-2. Failures in the local poll steps have no control and no record

Two steps in `_await_guest_windows` run outside the adapter: the state
predicate `jq -e` (library:118) and `sleep 2` (library:129).

- A failed or interrupted `sleep` returns its status through `|| return`. It
  writes no receipt and no latch. If a signal stops only the sleep, the root
  holds clean negative reads and nothing else. The next scenario call can
  dispatch. A caller that handles the status in a conditional sees an ordinary
  nonzero return.
- If a signal stops only the state `jq`, its status is greater than 1. The
  library then records an ordinary failed confirmation (library:123-125). The
  interruption becomes an ordinary failure.

Bats replaces `sleep` with a function that always succeeds (Bats:42). No control
makes the state predicate return a status other than 0 or 1. The only signal
control interrupts the adapter (Bats:269-278). The k72 charter asks about
ignored signals and local decoder failures. These two paths are not controlled.

The report hands shell interruption to k71 (report:86-88). That handoff is
reasonable. But the helper's own return on a failed sleep has no control, and
the misclassified predicate interruption is not stated.

Smallest correction: add controls for a failing sleep and for a state predicate
status other than 0 or 1. Either record the failed sleep or state in the report
that it leaves no record and no latch. State that k71 must treat it as
interruption.

### P3-3. The move helper admits negative coordinates that the CLI rejects

`act_guest_window` accepts `-?[0-9]+` for X and Y (library:68). It passes them
as separate values: `--x "$5" --y "$6"` (library:72). In v2.7.0,
`AgentWindowMoveArgs` declares `x` and `y` as plain `#[arg(long)]` values
(`cli-rs/crates/testanyware-cli/src/main.rs:1822-1835`). They do not set
`allow_negative_numbers` or `allow_hyphen_values`. The pinned clap_builder
4.6.0 then parses a value such as `-5` as short flags and refuses it
(`src/parser/parser.rs:894-935`).

Consequence: a negative coordinate always fails at argument parsing and latches
the root. The result is fail-closed, so no false success follows. The current
scenario moves only to positive coordinates (`scripts/vm-verify-menu-bar.sh:123,147`).
But the report states that move takes integer X and Y, and no control covers a
negative value.

Smallest correction: accept only non-negative integers, or pass `--x=VALUE`
and `--y=VALUE`. Add a control for the chosen form.

### P3-4. The red run used an earlier control file that is not retained

`baseline-red.json` names Bats digest `57e4831c…`. The final Bats digest is
`ca82979e…` (`verification.json`). No jj snapshot of change `qzrnprrm` holds the
earlier revision. The red output shows that test 7 then asserted
`-z "${output##*unavailable*}"` (`baseline-red.txt`). The final test 7 does not
make that assertion (Bats:190). `argument-red.txt` runs only test 14.

Consequence: no retained run shows the final form of tests 1-13 failing. The
report (lines 96-101) and the receipts do not state that the controls changed
after the red run. This review did not find a final control that would pass
against the legacy routes. The gap is in provenance, not in a known false pass.

Smallest correction: run the final Bats file with `KOINE_WINDOW_BASELINE=1`
against the legacy routes. Retain that run and its digests beside the existing
red run. Do not change the existing red receipts. Alternatively, state the
difference in the report.

### Checked without a finding

- The window schema matches v2.7.0 `WindowInfo`. `title` and `elements` are
  absent when `None`, and the CLI serialises the typed response again. Thus a
  `null` title is correctly a schema failure.
- `emit_action` always writes `action`, `success` and `message`. `message` is
  `null` when absent. `success:false` exits with `ACTION_UNSUPPORTED`. The action
  names and the `--window`, `--x` and `--y` flags match the source.
- The Koine poll matches `await_windows` (`scripts/vm-verify-lib.sh:422-430`):
  ten reads, a sleep after each negative read, then failure. Every dispatch uses
  the shared writer lock, ordinals and latch. The library checks the explicit
  root before any dispatch.
- Each recorded before and after digest matches the committed file. Each run
  output matches its recorded digest. The two missing archive targets in
  `docs-check.txt` belong to k23.
- The report, the k66 brief and the k71 leaf keep every inherited duty. These
  include ordinary adoption and both held-pointer signal controls. They also
  include the k67 setup, title and liveness outcomes and the k62, k57 and k54
  duties.
