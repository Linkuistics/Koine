# TestAnyware 3.0.0 amendment review

The amendment does not yet satisfy the strict transport contract. A successful
VNC size wait can conceal a failed connection and its retry. Resolve finding F1
before k54 freezes a subject. This is a test-driver finding, not a Koine failure.

This inspection reviews producer commit
`a6fbabb60270bf25f46827102b14d905845172d9`
(`settings-testanyware-3-amendment-k177`). The upstream subject is tag `v3.0.0`,
commit `097ed8f7337ed9142c1aa8cda926a513c03108a4`. Upstream evidence below was
read with `git -C ../TestAnyware.gh-issue-13 show v3.0.0:<path>`, without using
that worktree's working files.

No test, build, lint, format command, guest, clone or golden build ran in this
review. Existing controls were inspected as source; their execution is not a
new result here. No production or test code changed. Product assertions remain
NOT RUN. The [amendment results](ORDERING-TESTANYWARE-3-RESULTS.md) and
[evaluation protocol](ORDERING-EVALUATION-PLAN.md#required-transport-and-evidence-handling)
remain the producer's record and governing contract.

## F1 — high: a successful size wait can qualify a failed transport

**Locations:** `scripts/vm-guest-exec.py:36`,
`Tests/scripts/vm-guest-exec.bats:468`,
`ORDERING-TESTANYWARE-3-RESULTS.md:83` and ledger rows D031, D066, D090 and D130
in `ordering-reconciliation-evidence/duties.json`.

**Failing input:** let a `vm start` size-wait session fail with
`connection refused`, then let its next session report 1920×1080. The tagged
[wait loop](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/vnc_size_wait.rs#L90-L136)
turns the error into `Reading::Failed`, sleeps 250 ms and opens another
connection. It returns `SizeWait::Waited` on the later successful size. The
existing upstream control `a_failed_session_counts_as_a_stale_read` explicitly
uses `[Err("connection refused"), Ok(TARGET)]` and checks this message:

```text
VNC size wait: the first session read no size (connection refused). Session 2 read ...
```

The adapter rejects only `warning: VNC size wait:` and `VNC size wait skipped:`.
This line matches neither. With an otherwise valid start envelope, the
adapter publishes a clean receipt and the scenario continues. The actual route
is `settings_start_vm` → `start_guest_vm` → `cli_guest_evidence` → `run_locked`;
the lifecycle predicate checks the start identity and endpoints, not the prior
VNC failures.

There is also a less visible case: `[Ok(STALE), Err(error), Ok(TARGET)]`.
`Waited` retains only the first reading, session count and elapsed time, so its
message does not disclose the intervening error. The local benign-diagnostic
control explicitly accepts the three-session message with a clean first
reading. Checking only for `no size` therefore cannot close this gap.

The same failure is accepted through the app route. Tagged
[app start](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-app/src/start.rs#L182-L204)
uses the shared lifecycle and forwards each progress line in a `StartEvent`.
The [app client](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-app-client/src/lib.rs#L328-L383)
passes that line unchanged to the CLI, and
[`commands/vm.rs`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs#L88-L119)
prints it unchanged on stderr before its successful envelope.

**Consequence for k54:** a later size can repair a failed transport without an
unavailable latch. The completed-wait disposition is unsound under the agreed
one-attempt rule. The selected ledger rows' `met` dispositions overclaim the
changed source: the new controls cover expired/skipped waits and the Vision
retry, but leave this startup retry accepted. Integration must settle the
startup admission and its controls, results and affected ledger claims before
freeze. No extra guest or wider tolerance is justified by this finding.

## Answers to the review questions

| Question | Source-based answer |
|---|---|
| Can status 0 conceal a prohibited result? | Yes: F1 establishes a reachable startup failure and retry accepted as clean. This is enough to reject the amendment's current qualification. |
| Do the exact prefixes cover the relevant paths, including the app route? | They cover the expired/skipped size wait, Vision-worker retry and ordinary `input` confirmation warnings inspected in the tag. They miss the successful size wait after a failed session on both startup routes. See N1 for the separate `--open-menu` surface. |
| Does the typed exec check reject a clean real macOS shape? | No mismatch was derived for a valid attached macOS record with exit 0 and two complete UTF-8 streams. Tagged `ExecRecordMapping.swift` sets `legacyProjection` to `macos`; `commands/file.rs` emits `record: agent`, the exact two-key `exited` outcome and the stream keys the adapter checks. A legacy reply, other outcome, incomplete capture or invalid UTF-8 is refused. No real-agent reply was exercised. |
| Can contradictory stream metadata qualify? | The adapter checks only part of the typed record, but the pinned CLI's `AgentClient::exec` first runs `read_exec_reply`; `exec_record.rs::validity_problems` checks the id, stream lengths/digests, lifecycle and legacy projection. No reachable bypass to a clean accepted envelope was derived from the inspected path. The abbreviated local fixtures alone do not establish that full upstream validation. |
| Are input order, reads, sleeps and polls preserved? | The adapter adds no dispatch. `input.rs` is unchanged between the cited tags. Capture still validates the PNG against the emitted dimensions; the menu-bar repair emits `focused: false` and the inspected element helper adds no menu-opening flag. OCR retry results are refused. Startup is the exception: F1 introduces repeated sessions and 250 ms sleeps after a failed read. The accepted completed-wait claim cannot stand. |
| Can INT, TERM or HUP produce false clean exec/download acceptance? | No such path was derived. A nonzero CLI status or absent/partial envelope cannot qualify. SIGINT caught by the adapter records interruption; TERM/HUP killing the adapter leave an unfinished attempt and an inherited writer lock while its CLI survives. Existing signal controls inspect those cases. Scenario traps preserve 130/143/129 and prohibit later input, including release. This is source evidence, not a new signal experiment. See N2 for the download-retention correction. |
| Do the ledger claims exceed the evidence? | Yes: F1 contradicts the no-hidden-retry claims in D031, D066, D090 and D130. The source-based typed-record compatibility above supplies no new runtime acceptance and does not close k54's agent/image readiness duty. |

The typed-record comparison uses these additional tagged sources:
[`ExecRecordMapping.swift`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/agents/macos/Sources/TestAnywareAgent/ExecRecordMapping.swift),
[`commands/file.rs`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/file.rs),
[`AgentClient::exec`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-agent-client/src/lib.rs#L431-L459)
and [`exec_record.rs`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-protocol/src/exec_record.rs).

## Additional observations

**N1 — unconsumed input path:** `scripts/vm-guest-exec.py:38` scopes the
confirmation-warning prefixes to `input`. Tagged
[`commands/agent.rs:168`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs#L158-L172)
also calls `confirm_input_read` after each `snapshot --open-menu` click and
continues to its snapshot on either warning. A one-shot adapter call to that
command with a valid snapshot and either warning is accepted. The evidence
class already refuses `--open-menu`, and the inspected scenario snapshot helper
does not send it. This does not establish another failure on k54's current
snapshot path. It limits the amendment's diagnostic-coverage claim; it earns no
extra runtime or separate completion obligation.

**N2 — download-retention wording:** the statement at
`ORDERING-TESTANYWARE-3-RESULTS.md:63`, “Only SIGKILL leaves it”, is too strong.
For a CLI download with its temporary file already created, SIGHUP uses the
default termination action too. Tagged
[`commands/interrupt.rs`](https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/interrupt.rs)
installs handlers only for SIGINT and SIGTERM; HUP does not drop the download
future through the graceful handler. It can leave the temporary file. Killing
only the adapter with TERM/HUP can instead leave the CLI running under its
writer lock. These cases must stay distinct from signalling the CLI itself.
The adapter does not qualify a failed copy or delete the residual file, so this
is a correction to the retention explanation, not a second demonstrated false
pass. k54 must preserve whatever partials actually exist and settle holders.

## Evidence limits

The graph project was
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, generation
`2026-11-23T11:46:09Z`, using Tier 2 verification. Coverage was checked for the
local evidence paths. The lifecycle helper's line 31, scenario helper's lines
251, 357, 601 and 660, and click helper's line 90 had recorded parse gaps; their
source ranges were read directly. Bats files and the new task paths had no
tracked freshness metadata, so their cited source was read directly too.
Coverage is best effort, not proof of completeness. The exact upstream review
worktree was not a listed graph project; all upstream claims use the mandated
tagged reads instead.

This is a bounded review of the amendment and its load-bearing paths. It makes
no repo-wide absence claim, general reliability claim or native-cause finding.
