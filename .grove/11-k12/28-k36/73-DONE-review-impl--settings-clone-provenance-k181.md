# settings-clone-provenance-k181

**Reviews:** settings-clone-provenance-k180

## Goal

Try to break the clone provenance and declared executable binding before k54
freezes a subject. Report findings, and change no artifact.

## Context

The artifact is the commit of `settings-clone-provenance-k180`. Its source
changes are in `scripts/vm-guest-exec.py`, `scripts/vm-guest-exec-lib.sh`,
`scripts/vm-settings-scenario-lib.sh`, `scripts/settings-ordering-sequence.py`
and `scripts/check-settings-baseline.py`. Its record is
`docs/verification/settings-activation/ORDERING-PROVENANCE-RESULTS.md`.

The contract is the k180 task file, the first item of the k54 `Done when` and
finding P3-3 of the k58 review. Each guest transport of a slot must bind to the
exact spec path, its digest and its agent endpoint. A bare argv VM name is not
endpoint provenance. Each attempt must run the CLI and jq that the caller
declares. The change may add no guest read, wait, retry or wider tolerance.

Read the tagged upstream source with `git -C ../TestAnyware show v3.0.0:<path>`.
Do not edit that clone. The installed tool is
`/opt/homebrew/Cellar/testanyware/3.0.0/bin/testanyware`.

## Done when

- Each question below has an answer with evidence from the tagged source or a
  control.
  - Can a guest transport reach an endpoint other than the one that the
    recorded spec names, without a refusal?
  - Does the resolution of the state directory and the configuration file
    differ from the tagged CLI or app for any input that the harness accepts?
  - Can a changed, replaced or undeclared executable run an attempt that keeps
    a clean receipt?
  - Can a slot qualify, or a recurrence reject the repair, without a valid
    provenance record?
  - Does a new refusal turn a test-driver failure into a Koine failure, or stop
    the exact stop and the inventory of a clone?
  - Does a ledger row or the results record claim more than the source and
    controls support?
- Each finding names the file, the failing input and the consequence for k54.

## Decisions (running log)

- 2026-11-24: Review producer commit `6c0d0dab184c5b04465f0eb13e675b57554fa7b1`
  against k180, k54's provenance duty and P3-3 of k58. Use Tier 2 graph
  discovery with direct source verification. Read the tagged TestAnyware
  `v3.0.0` source through the mandated neighbouring clone. Run no test, build,
  lint, format command or guest, and change no implementation or control.
- 2026-11-24: The check-before-dispatch limitation does not meet k180's strict
  binding condition. The producer discloses the limitation but records no
  owner acceptance of it. The final audit also accepts an incomplete
  provenance record. Both findings directly block the k54 provenance handoff
  and warrant one adjacent integration, which can triage them against the
  committed source and seek the required owner decision if necessary.
- 2026-11-24: The initial provenance also has no comparison with the clean
  start reply's spec path and endpoint. A replacement before the first record
  becomes the accepted baseline. Record that separate, repairable gap alongside
  the ongoing check/dispatch limitation and the incomplete-record audit.

## Review findings

The reviewed implementation is `6c0d0dab184c5b04465f0eb13e675b57554fa7b1`.
All code coordinates below refer to that commit. These are source-derived
counterexamples, not newly executed controls or native observations. P2 means
that the implementation does not establish a required provenance condition
before k54's freeze. Integration must triage the findings; this review changes
no acceptance condition.

### P2-1. The initial spec is not compared with the clone's start reply

In `scripts/vm-guest-exec.py:585-595`, `vm_started` establishes only that a
prior request's argv names `vm start`. The provenance branch at lines 759-766
then records whatever `spec_mapping(vm)` currently reads. Neither branch
compares that mapping with the retained start reply. The caller's
`provenance_check` in `scripts/settings-ordering-sequence.py:1493-1547` checks
that a start precedes the record but also makes no such comparison.

Failing input: the clean start reply names spec path P and agent A. Before
`clone-provenance`, replace P with a well-formed spec naming agent B, while
keeping its VM filename. The new record accepts B. Every subsequent spec check
compares with B and can pass indefinitely. No restoration between checks is
needed. The `vm-after` inventory predicate in
`scripts/vm-lifecycle-evidence-lib.sh:97-109` checks the running clone's name
and count, not equality with the start endpoint.

TestAnyware v3.0.0 already returns the necessary comparison facts:
`cli-rs/crates/testanyware-cli/src/commands/vm.rs:169-201` copies the app's
`StartResult` into the JSON `agent` and `spec_path` fields. The lifecycle helper
retains and validates those fields as part of its clean start response. The
adapter does not use them when establishing provenance.

Consequence for k54: a different endpoint can become the baseline for the
declared clone without any provenance refusal. Later guest observations can
therefore concern another guest while cleanup still names the requested clone.
The report's limitation that an endpoint alone does not prove guest identity
does not explain discarding an available contradictory start record.

Integration should compare the initial mapping with the clean start reply,
retain that comparison, and exercise a mismatching reply/spec control. This
uses existing host evidence and adds no guest read. It does not by itself solve
P2-2.

### P2-2. A clean attempt does not establish the checked spec or executable at use

`scripts/vm-guest-exec.py:697-704` checks the executables and current spec,
then writes the request. Lines 772-774 subsequently launch the CLI by path.
The jq launch occurs still later at lines 484-491. No post-attempt identity
check occurs before the clean result is written.

On macOS, the CLI's `resolve_agent_target_with_env` passes `StreamTarget::Vm`
for `--vm`; it does not send the checked endpoint. In TestAnyware v3.0.0,
`cli-rs/crates/testanyware-cli/src/resolve.rs:409-440` and
`cli-rs/crates/testanyware-app/src/streams.rs:57-116` show that the app reads
the spec independently. `server.rs:526-527` then opens that resolved endpoint.
The adapter's writer lock does not protect that external spec or either
executable pathname.

Failing input: after the adapter checks spec A but before the app reads it,
replace it with a valid spec B. A successful response from B can produce a
clean receipt naming A's provenance. Likewise, replacing a declared executable
after its digest check permits another image at the same pathname to run. If
the original file is put back before the next check and final audit, those
checks need not detect the substitution. With jq, that interval includes the
whole CLI execution before jq is launched.

`ORDERING-PROVENANCE-RESULTS.md` discloses the check/dispatch interval, and k54's
new handoff repeats it. This finding does not allege that the limit was hidden.
The unresolved issue is authority: k180 explicitly says to ask the owner if the
tagged resolver makes strict binding impossible, and not to weaken the duty.
Its decisions record no acceptance of this weaker guarantee. A later refusal
also cannot undo an input already sent to a different endpoint.

Consequence for k54: the current source cannot establish the mandated binding
for each attempt merely by freezing the paths. Before runtime, integration
must either establish the required binding or obtain an explicit owner decision
on the disclosed cooperative/check-before-use limit and reconcile the contract.
The saved controls replace files before a call; they do not establish the
stronger property during this interval. This is an acceptance gap, not a request
for speculative extra guests, waits or retries.

### P2-3. The final provenance audit accepts a record without a digest or endpoint

`scripts/settings-ordering-sequence.py:1527-1554` compares only the ordinal,
VM, state directory, configuration path and spec path. It never validates the
record's agent, spec digest or identity fields, configuration state/digest,
environment or state source. Its only preceding record validation is
`read_object`, which requires one JSON object.

Failing input: retain a clean provenance attempt at ordinal N and replace the
root's `provenance.json`, after the final guest read and before audit, with:

```json
{
  "ordinal": 4,
  "vm": "koine-k49-ordering-e01",
  "state_dir": "/frozen/state/testanyware",
  "config": {"path": "/frozen/config.rhai"},
  "spec": {"path": "/frozen/state/testanyware/vms/koine-k49-ordering-e01.json"}
}
```

Use the real N and frozen paths in place of the example values. With the other
receipts intact, `provenance_check` returns `passed`: every field it compares
still matches. The record has no endpoint and no spec content digest.
`REQUIRED_MEMBERS["provenance"]` is empty at line 117, and `audit_originals`
at lines 1608-1702 supplies no separate check of the root provenance record.
The retained-file manifest records the bytes it finds later; it cannot prove
that the missing facts were retained.

Consequence for k54: invalid required provenance can pass the `subject` phase.
`decide` at lines 902-922 can then qualify an otherwise complete slot or reject
the repair on a corroborated recurrence. That contradicts the claimed rule
that neither outcome is possible without a valid provenance record.

Integration should validate the full required record and its association with
the provenance attempt, with controls for absent or malformed endpoint and
digest fields. The existing controls cover a missing record, other paths and
wrong ordering, but do not establish this condition.

## Answers to the review questions

| Question | Source-based answer |
|---|---|
| Can transport use an endpoint other than the recorded spec names without refusal? | Yes, in P2-2's check/dispatch interval. P2-1 separately permits the wrong initial baseline. |
| Does directory or configuration resolution differ from the tagged source? | No divergence found in the inspected macOS subset: absolute HOME/state/config paths and absent, disabled or comment/empty-map configuration. The adapter rejects other settings. The tagged `paths.rs` and `location.rs` implement the same precedence for that subset. The app's `gate.rs:43-49` rejects differing client/app directories. This is no general Rhai evaluator or cross-platform certification. |
| Can another executable keep a clean attempt receipt? | Yes under P2-2. Persistent changes made before the adapter's check refuse. The receipt names a pathname, not an independently observed executing image. |
| Can a slot qualify or a recurrence reject without valid provenance? | Yes under P2-3. An entirely missing record is refused; a valid JSON object missing its endpoint and digest is not. |
| Do new refusals become Koine failures or prevent exact cleanup? | A failed initial provenance stops the scenario with status 125, as the scenario source and saved control show. Spec refusal skips VM lifecycle checks, so exact stop and independent inventory remain callable. Executable refusal applies to those calls too: if a frozen executable is missing or changed, cleanup can remain unresolved. That is not proof of Koine failure or permission to advance. The source and record disclose no fallback to another executable. |
| Do the report or ledger overclaim? | The report's claim of a valid-provenance qualification/rejection gate is too broad under P2-3. Its binding description also needs P2-1's initial comparison and the owner disposition in P2-2. The saved green checks and mutation outcomes remain evidence for their specific controls, not these stronger properties. |

## Evidence and inspection limits

The saved receipts report 25 successful Task commands, 36 detected mutations
and unchanged subjects. This review checked both transcript digests and the
listed digests of 14 relevant source/control inputs against the current bytes;
all matched. Those inputs were the Taskfile, the five changed harness scripts,
the three provenance Bats suites, the two caller fixture scripts, the measurement
and mutation scripts, and the duty ledger. This is verification of recorded
evidence, not a fresh test run. No native clone or frozen runtime was qualified.

Graph project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14` used generation
`2026-11-24T07:22:57Z`. Relevant searches and one-hop traces were untruncated.
Later coverage reached generation `2026-11-24T08:07:57Z`; implementation source
stayed unchanged. Coverage checks were best effort. The scenario library reports parse gaps at
lines 256, 366, 610 and 669; those ranges were read directly. Bats, task and
evidence files with unavailable or changed freshness were inspected as source.
The lifecycle facade's reported gap at line 31 was also read directly.
Some graph call resolutions were unrelated same-name symbols, so this review
does not credit them as relationships. The material claims above come from
exact source. Upstream claims use `git -C ../TestAnyware show v3.0.0:<path>`;
its current graph coverage is no substitute for the tagged source.
