# settings-nonexec-evidence-k63

**Reviews:** settings-nonexec-evidence-k60

<!-- tc: off because the Goal, Context, Done when and Notes are the producer-authored charter, kept verbatim as the task contract -->

## Goal
Independently challenge the shared evidence interface before complete scenario
migration. Read the producer's committed diff by handle, not its session transcript.



## Context
Read the k56/k53 charters, ORDERING-EVALUATION-PLAN.md, ORDERING-REVIEW.md,
ORDERING-TRANSPORT-RESULTS.md and ORDERING-NONEXEC-RESULTS.md under
docs/verification/settings-activation. The producer changes scripts/vm-guest-exec.py,
its source-only shell facade, Tests/scripts/vm-guest-exec.bats and the existing
Taskfile entry. Evidence is in ordering-nonexec-evidence, including the prior-adapter,
missing-lock and separator failing controls and final verification receipt.

K60 expands the adapter only. Ordinary callers remain legacy; actual per-command
schemas, artifacts, confirmations, scenario signals and positive UI setup are
k61's duties, with exact-prefix reconciliation k62 and finite caller k57. No VM
or frozen subject exists. K54 owns actual executable/spec/endpoint provenance.

## Done when
- Try to find dispatch after failure, cross-transport lock/ordinal gaps, lost raw
  evidence, wrongly accepted partial/base/payload JSON, output-before-completion
  mistakes or a confirmation failure that restores eligibility. Inspect both
  facade and direct backend paths, including parse/storage/emission failures.
- Challenge CLI argv binding against the inspected official v2.7.0 source:
  endpoint versus lifecycle forms, option overrides/terminators, forbidden guest
  exec route and exact clone identity. Separate supported interface guarantees
  from caller obligations that migration must fulfill.
- Assess surviving-child lock lifetime, gate inspection versus dispatch, SIGINT
  versus TERM/HUP/KILL and partial receipts. Check whether the controls actually
  distinguish missing guards and whether the retained receipts match their subjects.
  Controlled marker payloads must not be treated as real command-schema evidence.
- Produce actionable source-anchored findings, or state no findings in the
  inspected scope. No fixes, VM, frozen subject or competing in-session reviewer.
  Any earned integration must be inserted before k61, the next live sibling.

## Notes
Every historical outcome/cap and original k56 duty survives. Interface review
does not replace later whole-harness review or establish repaired native behavior.
No in-session producer reviewer ran. Provider evidence was absent from the
finishing session's environment; no Creator line is supplied.
<!-- tc: on -->

## Decisions (running log)

- 2026-10-29: Adopt the mandated review-impl leaf on the empty jj change
  qynutntt. Its parent is 1d9bd4c6, the k60 producer commit. Read the brief
  chain, the k56 and k53 briefs, the k60 task file, the producer diff and the
  k60 report. The graph server failed to connect, so read the sources
  directly. Claim no graph coverage. Run no test, build, lint, guest or
  in-session reviewer.
- 2026-10-29: Read the TestAnyware v2.7.0 tag (e37283e3) in the local
  checkout. Its `main.rs` digest equals the digest in the k60 receipt. Read
  the clap declarations, the output envelope, the CLI `vm start` route and the
  detached spawn path. The forbidden options have no short forms. Clap infers
  no long options. Top-level aliases such as `exec` and `upload` fail the
  family check. On macOS, detached VM and keeper processes start with
  `POSIX_SPAWN_CLOEXEC_DEFAULT` (`testanyware-vm/src/detached.rs:117-235`).
  Thus a VM that `vm start` starts does not inherit the writer lock.
- 2026-10-29: All 28 subject digests in verification.json equal the committed
  bytes. The three retained check outputs equal their recorded digests.
- 2026-10-29: One P2 finding, three P3 findings and one handoff gap earn an
  integration. Insert one integrate-review-impl leaf before
  settings-scenario-migration-k61, the first live sibling after this review.
  This session finishes no producer and closes no node, so it writes no
  Creator line.

## Findings

Severity: P2 means a defect in a guarantee that the adapter or its charter
claims, which k61 or k57 would rely on. P3 means a narrower defect, a retention
gap or a control gap. H means future caller work that is not an adapter defect.

Line numbers refer to commit 1d9bd4c6. "py" is `scripts/vm-guest-exec.py`.
"bats" is `Tests/scripts/vm-guest-exec.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-NONEXEC-RESULTS.md`. "The
plan" is `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.
"main.rs" is `cli-rs/crates/testanyware-cli/src/main.rs` at tag v2.7.0.

### P2-1. A class label lets non-exec input and VM start pass the latch

The latch gate refuses a call only when its class is not `evidence`
(py:197-199). The `cli` route admits every `input` action, the mutating
`agent` actions, `file upload` and `vm start` (py:155-167). Thus
`cli ROOT evidence op true -- input click 10 20` dispatches a click after a
failure. The same label lets `vm start` create a clone after a failure.

The k56 charter requires that the failure latch stops input (k56 brief, Done
when, third item). The plan permits only context collection after a latched
failure (plan:219, 248), and it forbids replacement clones (plan:320-321). The
report states that `evidence` must never bypass the latch for scenario input.
It leaves that rule to the caller (report:95-97). For exec, the adapter cannot
classify a free guest command. For `cli`, the adapter already parses the
family and the action, so it can enforce the rule.

The collection control uses only `agent windows` (bats:62-63). No control
sends input or `vm start` with the `evidence` class after a latch.

Consequence: one wrong class name at a k61 or k57 call site sends physical
input or starts a clone after a failure. The adapter records it as a clean
attempt.

Smallest correction: on the `cli` route, admit the `evidence` class only for
read-only actions and for `vm stop`. Examples of read-only actions are
`screen capture`, `screen size`, `agent windows`, `agent snapshot`,
`file download` and `vm list`. Refuse other actions with that class before
dispatch. Add a control that sends `input click` and `vm start` with the
`evidence` class after a latch. That control must find no CLI call.

### P3-1. A refused call leaves no record of its own, and k57 containment has no route

A refused call creates no attempt directory. Contention (py:316-318), an
argv refusal (py:142-166, raised before py:213) and a parser error (py:394-403)
each write only the root latch. The latch keeps the first reason only (py:63-68).
After any earlier failure, a refused call therefore leaves no trace at all. The
report accepts the missing ordinal (report:85-86). It does not state that the
refused request and its reason are lost.

Two cases matter downstream:

- A `fail` call under contention records nothing of its reason. The lock
  control asserts exactly this result (bats:218-227).
- While an orphaned CLI child holds the lock, every k57 call is refused
  (report:88-90). This includes the exact-clone `vm stop` that the plan
  requires, with its response and status (plan:331-334). Nothing records
  that the stop was attempted and refused. The interface gives no supported
  way to wait for the orphan or to contain the clone while the orphan runs.

Consequence: the evidence root cannot show which collection or containment
steps ran after a failure. K57 can report a stop that was refused only from
its own logs.

Smallest correction: append each refusal to a log file in the root, opened in
append mode, with the request arguments and the reason. This log is not a
latch. Do it on each refusal path. In the report, name the orphan-held-lock
case as a k57 duty. K57 must then wait for the orphan or end its process group
before the exact-clone stop. Alternatively, it must record the refused stop as
unresolved cleanup.

### P3-2. `vm start` admits options that change blocking, containment and the golden image

The `vm start` form passes every caller option except the forbidden set
(py:144-157). TestAnyware v2.7.0 declares three options that matter here:

- `--viewer` opens an interactive viewer. The CLI emits the JSON envelope and
  then blocks until a human closes the window (main.rs:1956-1958, `vm.rs:134-148`).
  The adapter then holds the lock and waits for a human.
- `--keep-on-failure` leaves a failed clone running for inspection
  (main.rs:1959-1964). Without this option, TestAnyware removes that clone. The
  adapter records the failed start as unavailable. It does not record that a
  clone with the pinned identity can still run.
- `--base` selects the golden image (main.rs:1945-1946). The subject records
  only the clone identity (py:75). The report table says only `OPTIONS...`
  (report:58).

A SIGINT during `vm start` also makes `subprocess.run` kill the CLI. A clone
that the direct route started can then outlive the record.

Consequence: one lifecycle call can wait for a human, or leave an
uncontained clone. The golden-image identity that the plan audits is a caller
argument that the adapter does not bind.

Smallest correction: refuse `--viewer` and `--keep-on-failure` on the
`vm start` route. Either bind `--base` in `init` or name it in the report as a
caller obligation. In the report, state that an interrupted or failed start can
leave the pinned clone running, and that k57 must stop it.

### P3-3. Three controls do not show the guard that they name

- No control supplies a caller `--id` to `vm start` or to an endpoint command.
  The forbidden-option loop runs only on `input click` (bats:136-144). If `--id`
  is removed from the forbidden set, the fake CLI accepts
  `vm start --id other --id exact-vm`. Clap would probably refuse the repeated
  option, but no control shows the adapter's own guard.
- In the shared-lock control (bats:197-241), `check` returns 125 because of the
  unfinished attempt, and `fail` always returns 125. Only the `run` and `cli`
  calls and the final assertions depend on the lock. The missing-lock receipt
  fails at `run` (`unlocked-control-red.txt`). The control is valid for the
  lock in `run()`. It does not show that `check` or `fail` are refused by the
  lock instead of by the receipt guard.
- The "missing backends" control (bats:176-184) asserts only a nonzero status
  and a latch. It does not assert which reason the facade wrote.

Consequence: a later edit can remove the `--id` guard, or move one entry point
out of the lock, while every control still passes.

Smallest correction: add `vm start --id other` and `input click --id x` to the
refusal controls. Assert no CLI call. In the lock control, assert the latch
reason after the `check` call, before any other call.

### H-1. K61 must know which TestAnyware negatives the interface can express

TestAnyware reports `WINDOW_NOT_FOUND`, `ELEMENT_NOT_FOUND` and
`TEXT_NOT_FOUND` as error envelopes with exit 3 (`output.rs:115-132`). The
adapter treats every nonzero CLI status as unavailable (py:98-99). Thus
`agent inspect`, `agent wait` and `screen find-text` cannot be clean-negative
polls. Each negative result latches the root. The plan requires that a clean
negative poll continues (plan:217). The report asks k61 for explicit clean
negative facts (report:46-48), but it does not state this limit.

The mandatory predicate can also be the constant `true`. The controls use it
for that purpose (bats:47-66). A constant predicate meets the interface and
checks nothing.

Correction: in the report, state that k61 polls must use list-shaped reads,
such as `agent windows`, whose clean result can express absence. State that a
typed not-found error is a failure. State that each k61 call site must supply
a predicate on its own payload schema, not `true`.
