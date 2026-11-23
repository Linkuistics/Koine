# Settings harness review: integration record

This record belongs to `settings-ordering-harness-k173`. It triages the three
findings of the [harness review](ORDERING-HARNESS-REVIEW.md). All three findings
are real issues, and this task repairs each one in the finite caller.

The evidence is source and controls only. No VM, clone or signed subject ran.
The work establishes no native behaviour, no native cause and no runtime
acceptance. It closes no ancestor, and it changes no protocol cap.

## Dispositions

| Finding | Disposition | Failing condition on the old source | Repair |
|---|---|---|---|
| R1, recovery settlement | Real issue | Supplied passed phases settled E01 as `qualified`, with cleanup `confirmed` and no stop | `settle` takes no phases. It records each result phase as `unavailable` |
| R2, wrong subject or setup | Real issue | A wrong guest build or installed bundle still produced `rejected` | A new `subject` phase must pass before a recurrence rejects the repair |
| R3, loss before the manifest | Real issue | A lost `guest.stdout` left the audit `passed`, and E01 qualified | Each clean attempt must hold every file that its transport writes |

[`red.txt`](ordering-harness-integration-evidence/red.txt) holds these results.
They come from the source at commit `53e33b27`.

## The repairs

**R1.** A lost caller has no audit, stop or inventory result. The `settle` verb
now keeps only the strict scenario status and the frozen classification. A
complete root stays `unresolved`, and its cleanup stays `unresolved`. A failed
assertion with its expected status stays `failed`. Every later slot stays NOT
RUN.

**R2.** The `subject` phase reads the `system`, `gatekeeper` and
`installed-before` receipts. It also fails on any process row with undeclared
arguments, because a process keeps its arguments for its whole life.

The protocol requires the frozen subject and setup for a qualified recurrence. It
also says that a later failure cannot erase one. The separate phase keeps both
rules. A failed later read, or a guest change after the selection, leaves the
rejection in place.

**R3.** The originals audit now takes the required files from the transport and
the outcome of each attempt. A manifest written after a loss can no longer agree
with that loss. A failed attempt with a partial response owes no guest stream.

## Accepted trade-offs

- A real recurrence in a run that lost its caller stays `unresolved`. That run
  has no corroborating screenshot audit, so the protocol does not qualify it. The
  ledger keeps the recurrence class for the next decision, and acceptance stays
  prevented.
- An undeclared process argument leaves a recurrence `unresolved`, even if the
  argument did not affect the selection. This cost is a lost rejection, and it
  cannot produce an acceptance.
- A same-user process can still rewrite receipts, the scenario status or the
  whole ledger. The caller guards against accidents and cooperating processes.

## Controls and provenance

The three Taskfile checks now hold 167 controls, and k173 added 23 of them. The
fixture `settings-sequence-settle.py` supplies phases to the decision-table
controls. The product command has no such route.

The records are in
[`ordering-harness-integration-evidence/`](ordering-harness-integration-evidence/):

- `red.txt` reproduces each finding on the old source.
- `mutations.json` breaks each repair 22 ways, one at a time, in private copies.
  A control caught all 22, and the unmutated copy passed. `mutate.py` is the
  instrument.
- `final-verification.txt` runs the affected Taskfile checks between two digests
  of every tracked file. `measure.py` is the instrument.

## Limits

- The controls use a synthetic guest. E01 still qualifies each real read.
- Controls lose real members of `read`, `cli` and `upload` attempts. The `exec`,
  `capture` and `download` rows come from the backend source, and no control
  loses one of their members.
- The real scenario reads `system`, `gatekeeper` and `installed-before` before
  its first selection. The `subject` audit relies on that source order, and it
  does not compare ordinals.

## Handoff to k171

k171 must reconcile these changed subjects:

- `scripts/settings-ordering-sequence.py`
- `Tests/scripts/vm-settings-sequence.bats`
- `Tests/scripts/vm-settings-containment.bats`
- `Tests/scripts/vm-settings-audits.bats`
- `Tests/scripts/fixtures/settings-run-task.sh`
- `Tests/scripts/fixtures/settings-sequence-settle.py`
- the `check:vm-settings-sequence` entry of `Taskfile.yml`

The harness stays unqualified at runtime. The TestAnyware version decision stays
a prerequisite of k54.
