# Settings harness and finite caller review

Review `settings-ordering-harness-k172` finds three issues that need triage
before reconciliation and runtime. Two can produce an unsupported disposition;
the third can admit a slot after required original evidence has disappeared.
This is an inspection-only review. It makes no product, runtime or native-cause
claim and changes no implementation or tests.

## Artifact and contract

The producer commits are `d339de1c` (`settings-ordering-caller-k57`), `a30aef6b`
(`settings-ordering-containment-k169`) and `38153864`
(`settings-ordering-audits-k170`). The reviewed source is their combined result
at `15b32daa`, the parent of this review's change. The intervening k54 commit
records the TestAnyware version mismatch; it changes no caller code.

The contract is the k36 brief, the [evaluation protocol](ORDERING-EVALUATION-PLAN.md)
and the [accepted spec](../../specs/settings-activation-discrimination.md).
In particular, recurrence requires the frozen subject and qualified setup;
later collection failures cannot erase an already qualified recurrence. Every
required audit and exact-clone cleanup must pass before later admission.
Originals and partials must remain available, with per-item comparisons.

## Findings

### R1 — P1: recovery settlement can invent audits and confirmed cleanup

Location: `scripts/settings-ordering-sequence.py:882–886`, in `settle`.
Related paths: `settled_classification:857–871`, `decide:806–812` and
`cleanup_state:816–823`.

The guard refuses supplied phases only when `containment/phases.json` exists.
That is precisely the file an interrupted run may never write. In its absence,
the command accepts every phase from an operator-supplied JSON file and uses
either the previously frozen classification or a fresh classification of the
root. It checks neither the audited results nor actual stop/inventory receipts.

Concrete failing case: E01's scenario completes with status zero. The caller
records a `complete` classification and then dies before its guest audits,
exact stop and `phases.json`. The caller's runner lock is released, while the
clone can still be running. Supply `settle DIR E01 PHASES` with scenario/task
statuses zero and every result `passed`. The source path records E01 as
`qualified`, reports cleanup `confirmed` and permits E02. No runtime root or
ledger file needs editing. The same public route is exposed by `admit` followed
by `settle`, without a collected run at all.

This is more than the documented same-user ability to rewrite the ledger: an
ordinary supported command performs the transition. The audit report explicitly
acknowledges the exposed verbs, and k54 says to avoid them for runtime, but
`settle` is also retained for a run that dies before writing its phases. That
recovery path must not manufacture qualification or confirmed cleanup from
unverified phase labels.

Control gap: `vm-settings-audits.bats` checks that manual settlement refuses
*after* collected phases exist. `vm-settings-sequence.bats`'s `qualify` helper
exercises the unguarded branch with supplied passed phases. Neither establishes
safe runtime recovery before `phases.json` exists.

### R2 — P1: invalid pre-selection subject or environment can reject the repair

Location: `scripts/settings-ordering-sequence.py:800–803`, in `decide`.
Related paths: `audit_environment:1213–1256`, `audit_installed:1286–1309` and
`Containment.run_audits:1994–2024`.

A `recurrence-candidate` becomes `rejected` solely from the screenshot result
and expected scenario status. Settlement ignores whether the audits establish
the required pre-selection subject and environment. A clean transport with the
wrong guest build or wrong installed bundle does not block
`recurrence_blockers`, because it remains a clean receipt.

Concrete failing case: the frozen declaration requires build `26A434`, but the
clean `system` receipt reports `26A999`. The scenario only prints that record
and can reach a failing Settings selection. Its complete route, liveness,
window and screenshot receipts produce a recurrence candidate. The environment
audit correctly records `failed`, but a passed screenshot audit and scenario
status 1 still produce `rejected`. A mismatch in `installed-before` has the
same consequence. Neither selection occurred under the admitted subject/setup.

This differs from a later failed archive, audit read or cleanup after a valid
recurrence. Those failures retain rejection precedence. Positive evidence that
the installed subject or guest environment was already wrong prevents the
recurrence from qualifying in the first place. The current aggregate phases
retain evidence of the difference but do not use it at settlement.

Control gap: the audit suite checks wrong build/bundle on a complete run and
checks recurrence with a matching synthetic subject. Their combination is
missing. Its existing `run_mode=recurrence` with `guest_build=26A999` describes
the source-derived counterexample; this review did not execute it.

### R3 — P2: loss before the manifest can disappear from the originals audit

Location: `scripts/settings-ordering-sequence.py:1366–1373`, in
`audit_originals`. Related paths: the optional artifact/transfer branches at
`1351–1365`, `write_manifest:2026–2031` and `recheck_manifest:1414–1433`.

The audit chooses guest streams by which files still exist. It does not derive
required membership from the attempt's transport and complete raw response.
The manifest likewise inventories surviving paths. As a result, both checks
can agree after an original or saved stream has disappeared before collection.

Concrete failing case: after a clean `system` read, lose that attempt's
`guest.stdout` before the caller writes its manifest. Keep `request.json`,
`result.json`, `read.json`, `raw.stdout` and `guest.stderr`. Classification
still sees a clean attempt. G5 still reads the correct `read.json`.
`audit_originals` compares only the surviving stderr, and the manifest records
no missing stdout obligation. With the other phases passing, E01 qualifies and
E02 is admitted. Losing both guest streams and `raw.stdout` also avoids this
audit's envelope read. These are missing-evidence cases, not clean equality.

The backend's actual `validate_response` writes both guest streams from a
complete exec/read envelope before completing the attempt
(`scripts/vm-guest-exec.py:187–191`). Their omission is therefore not an
optional receipt shape. Similarly, the artifact branches are entered only if
their metadata survives. A manifest of the remaining files cannot by itself
prove that every required original survived.

Control gap: the audit suite changes a guest stream before collection and
removes a retained file after the manifest. It does not lose required evidence
before manifest creation. The existing mutation controls do not establish that
missing membership is rejected.

## Receipt-shape inspection

The audit inputs were compared with the actual backend and parser definitions,
not only with `file-lifecycle-cli.py`:

| Audit | Actual source shape inspected | Assessment |
|---|---|---|
| Host inputs and stopped golden | `scan_tree` file `path/kind/bytes/sha256`, symlink `path/kind/target`, directory `path/kind` | Per-path equality is implemented; no real Tart image was observed |
| Installed endpoints | `vm_exec_reads.inventory_parse` supplies `files` with `path/sha256` and `symlinks` with `path/target` | The caller's projection matches these fields; R2 concerns their use for recurrence |
| System and Gatekeeper | `system_parse` supplies the four compared version/architecture fields; `gatekeeper_parse` supplies `assessments` | The field comparison matches; a clean mismatch is recorded but R2 still applies |
| Process arguments and defaults | `process_parse` supplies `processes[].arguments`; `defaults_parse` supplies `diagnostics_disabled` | These match the caller's readers; the ordinary scenario retains `login-process` before final Quit |
| Capture originals | Backend capture writes `artifact.json`; `inspect_capture` supplies `bytes/sha256` for `screen.png` | The fixture's abbreviated metadata has the compared fields, but is not a real capture; R3 concerns missing membership |
| Download originals | Backend download writes `transfer.json` with `direction/bytes/sha256` and the saved `download.bin` | Comparison uses the actual field names |
| Guest streams | Backend exec/read retains `raw.stdout` and both decoded `guest.*` streams | Content comparisons match the real envelope; R3 covers skipped missing streams |
| Screenshot judgement | `settle-run` accepts exactly `result/detail` and retains the judgement | This remains an operator judgement, not machine proof of the subject or setup |

The shared source inspection also covered the scenario and extracted prefix,
the strict writer/latch backend, the lifecycle and read facades, physical input,
held resize/release tracking, failure observations and signal paths. A direct
source diff found the prefix equal to the scenario through line 154. That is a
source comparison, not runtime or availability qualification.

## Evidence and limits

No tests, builds, linters, formatters, VMs, clones or signed subjects ran in this
review. The cases above are derived from the source and the inspected controls.
The retained k57/k169/k170 verification receipts report successful checks and
unchanged subjects for those producer runs. They are historical evidence, not
a new verification run or coverage of the counterexamples above.

Tier 2 graph evidence used project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, generation
`2026-11-23T01:26:29Z`. Searches and relevant traces were not truncated. Some
trace edges resolved common names to unrelated symbols, so exact source was
used for the material call paths. Coverage checks reported no recorded gap and
matching metadata for the caller and Python backend/parser. The scenario and
several shell facades have recorded parse gaps; their reported ranges were
read directly. The Bats suites and some saved verification records lacked
tracked freshness metadata and were read directly too. The changed k54 task
was read from disk. Coverage remains a best-effort signal, not proof of a
complete review.

The existing TestAnyware version decision remains k54's prerequisite. These
findings grant no runtime, replacement slot, cap extension or change to the
accepted protocol. Integration must triage them before k171 reconciles the
delivered harness. No product or causal ancestor closes from this review.
