# settings-clone-provenance-k182

**Integrates:** settings-clone-provenance-k181


## Goal

Triage the committed findings of settings-clone-provenance-k181 against k180's
provenance contract. Apply the changes that agreed acceptance or material risk
requires, and establish the finite handoff to k54.



## Context

Read the findings from the review's own commit, rather than treating this task
as a restatement of them. Its producer is settings-clone-provenance-k180 at
`6c0d0dab184c5b04465f0eb13e675b57554fa7b1`. The contract is that task, k54's
first Done when item and P3-3 of settings-exec-evidence-k58. The review sits
immediately before this task, which precedes settings-ordering-qualification-k54.

The implementation and recorded controls are in the five scripts and
ORDERING-PROVENANCE-RESULTS.md named by the review. Read TestAnyware's tagged
`v3.0.0` source with `git -C ../TestAnyware show v3.0.0:<path>`. Do not edit that
clone. The inherited brief chain and finite protocol remain authoritative.

## Done when

- Each finding has a source-based disposition under the integration threshold:
  unclear contract, real issue, visible trade-off or noise. A rejected finding
  needs no repair merely because the review raised it.
- Necessary repairs and their meaningful controls are complete. Record fresh
  verification against the finished source. Before k54 consumes them, reconcile
  the affected duty ledger rows and the provenance handoff.
- Any required owner decision stays explicit and precedes dependent runtime.
  Preserve the contract's prohibition on silently weakening strict binding.
- The source and results record state the supported guarantees and limits.
  Cut further review only when a concrete change needs independent challenge.

## Notes

Start no guest, clone, golden build or evaluation slot. This task does not
authorise an extra read, wait, retry, slot or wider tolerance. Preserve all
historical evidence and the no-runtime boundary of the producer and review.

## Decisions (running log)

- 2026-11-24: read the findings from the review commit `a21edf6b`. Grade them
  against producer `6c0d0dab`, the k180 task, the first k54 `Done when` item
  and P3-3 of k58. Read the tagged TestAnyware source through `../TestAnyware`.
- 2026-11-24: P2-1 is a real issue. The clean `vm start` attempt keeps its reply
  in the same root, and the lifecycle predicate requires its `agent` and
  `spec_path`. The provenance step never compares them with the spec. The
  provenance step now requires exactly one prior start. It compares the start
  reply with the spec path and the agent, and it records that comparison. A
  mismatch refuses the provenance. This adds a host file read only.
- 2026-11-24: P2-3 is a real issue. `provenance_check` compares five fields
  and never checks the agent, the digest or the other fields. The caller now
  checks the complete record. It also compares the record with the start
  reply in the root. A malformed record is unavailable, and a mismatch fails.
- 2026-11-24: P2-2 is a real limit and an unresolved authority question. On a
  macOS host the tagged app reads the spec itself, after the adapter checks
  it, and the harness cannot observe that read. No interface lets the adapter
  pass the checked endpoint with `--vm`. The CLI runs by pathname, so a check
  cannot bind the image that runs. Thus strict binding at the moment of use is
  impossible with the tagged resolver. k180 says to ask the owner in that case,
  and its log records no owner acceptance.
- 2026-11-24: the adapter now also checks the executables and the spec after
  each attempt, before it writes a clean result. A persistent change during an
  attempt then makes that attempt unavailable, and not only the next one. A
  Homebrew upgrade replaced TestAnyware during this grove on 2026-11-23, so
  this case is concrete. The check adds no guest read, wait or retry. A change
  that is undone within one attempt stays undetectable, and a refusal cannot
  recall input that the attempt already sent.
- 2026-11-24: this session does not accept that residual limit for the owner.
  k54 gets an explicit hold before the freeze. The owner accepts the
  check-before-and-after guarantee, or asks for a design that binds the
  endpoint at use. The contract wording stays strict until that decision.
- 2026-11-24: each new control failed before its repair. The k180 record
  control failed on the new `start` entry. The review's five-field record
  passed the old audit, and it is now the first audit case. Each other audit
  case breaks one required form, so a mutation of one guard fails its case.
- 2026-11-24: the test fixtures now send the start reply that the tagged CLI
  sends. Its agent and spec path match the spec that the start writes. The
  scenario and baseline checks use a simulated backend, so the repair does not
  reach them.
- 2026-11-24: the k182 evidence lives in
  `ordering-provenance-integration-evidence/`. The k180 records stay unchanged.
  Three k180 mutation targets changed their text, so the k182 script repeats
  those mutations in the new form.
- 2026-11-24: no ledger row changes. 40 rows cite source inside `run_locked`,
  and no row cites `provenance_check`. The repair adds refusals and a record
  field, and it removes no cited behaviour.
- 2026-11-24: this repair earns no further review round. It adds refusals and
  record checks to a reviewed transport, and each new guard has a red control
  and a mutation. The owner decision on P2-2 stays explicit at k54.
- 2026-11-24, observation: early in this session, `git -C ../TestAnyware show`
  read the tag. Later the clone had no `.git` directory, and the command failed.
  Another session owns the clone, so this session changed nothing there. A
  read-only `jj --ignore-working-copy file show -r v3.0.0` read the same tag at
  `097ed8f7`. Its `paths.rs` gives the spec path `<state_dir>/vms/<id>.json`,
  and `lifecycle.rs` returns that path in the start result.
- 2026-11-24, observation: the first final verification failed one check.
  Pyright found a possibly unbound name in the lifecycle fixture, and no test
  failed. The fixture now creates the parent of the spec path. That repair changed
  a subject, so both measurements ran again on the finished source.
- 2026-11-24, observation: on the rerun, the mutation script applied 21
  mutations, and a control failed for each. The final verification ran 25
  Taskfile commands, and each exited 0. They include the closed ledger check.
  The 4,696 subjects stayed unchanged in both runs. This is no native or guest
  evidence.
