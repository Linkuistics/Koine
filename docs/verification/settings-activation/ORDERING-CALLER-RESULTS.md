# Finite Settings caller: sequence and classifier

This report belongs to `settings-ordering-caller-k57`. That task delivers the
first slice of the finite caller of the
[ordering protocol](ORDERING-EVALUATION-PLAN.md). The slice is
`scripts/settings-ordering-sequence.py`. It holds the five declared slots, admits
them in order, classifies the receipts of each evidence root and settles each
slot.

The evidence is source and controls only. The verbs of this slice start no clone
and send no guest command. No VM ran, and no signed subject exists. No runtime
slot ran. The work establishes no native behaviour, no native cause and no
scenario readiness. It closes no ancestor.

The caller is not complete. k169 adds the `run` verb, and the
[containment report](ORDERING-CONTAINMENT-RESULTS.md) records it. No slot can
qualify until the audits exist. These tasks own the rest:

| Task | Remaining duty |
|---|---|
| `settings-ordering-audits-k170` | The original, installed and golden audits, gap G5 and the defaults after each slot |
| `settings-ordering-reconciliation-k171` | The per-duty and application API reconciliation, after the whole-harness review |

## Interface

Each verb takes the sequence directory, except `classify`.

| Verb | Effect |
|---|---|
| `declare DIR` | Creates a new private directory with the fixed declaration. It refuses an existing directory |
| `ready DIR SET RECEIPT` | Records the digest of one readiness receipt for `focused` or `ordinary` |
| `admit DIR SLOT` | Consumes the next slot. The caller must start that slot immediately afterwards |
| `classify ROOT SET CLONE` | Prints the classification of one evidence root |
| `settle DIR SLOT PHASES` | Records the terminal result of a started slot. It refuses while a live run owns the slot |
| `run DIR SLOT` | Admits, runs, contains and settles one slot, as the [containment report](ORDERING-CONTAINMENT-RESULTS.md) states |
| `report DIR` | Prints each slot, each NOT RUN slot and the outcome |

Status 0 means that the step completed. Status 2 means invalid arguments. Status
3 means a refusal, and the ledger stays the same.

## The sequence

The declaration fixes the slots E01, E02, A01, A02 and A03, in that order. It
also fixes their namespaces, clone IDs, Task entries, output directories and
evidence roots. The golden image is `testanyware-golden-macos-27`. No option can
change these values.

The ledger holds one exclusive file per event. Each step takes one nonblocking
writer lock. A contender is refused, and `refusals.jsonl` records it. Each step
replays the whole ledger through the same rules that admit a new event. A
changed declaration, a stray file, an ordinal gap or a changed disposition
therefore refuses every later step.

Admission needs all of these facts:

- The slot is the next unstarted slot.
- No earlier slot is unsettled.
- Every earlier slot qualified.
- The set of the slot has its readiness receipt.
- The evidence root does not exist, and the output directory is empty.

The ordinary set accepts its readiness receipt only after E01 and E02 qualify.
There is no retry, replacement or sixth slot. The first slot that does not
qualify stops the sequence, and each later slot stays NOT RUN.

## Classification

The classifier reads the ordered `request.json` and `result.json` receipts. It
never infers an outcome from the scenario status alone.

| Kind | Meaning |
|---|---|
| `complete` | Every attempt is clean, nothing latched or refused, and the last receipt is the terminal operation of this set |
| `incomplete` | Every attempt is clean, but the terminal receipt is missing |
| `recurrence-candidate` | A clean recurrence class at a menu return, with its full route. The screenshot audit must still corroborate it |
| `assertion-failed` | Another classified assertion, or an exhausted poll |
| `unresolved-outcome` | An open menu, a recurrence class with a blocker, or a return exhaustion with no class |
| `interrupted` | A `scenario-signal-SIG` receipt, or a signal record that a held lock refused |
| `test-driver` | The restart boot poll ran out. This is not a Koine assertion |
| `unavailable` | A failed, partial or missing receipt, a latch, a refusal or another clone's root |
| `no-root` | The run left no readable root. This claims no Koine failure |

The recurrence classes are `zero-window-same-process`, `multiple-windows` and
`not-front`. A candidate needs a clean identity read, enabled read and open-menu
screenshot. It needs one clean row click after the enabled read, the failure
observations and a clean closed-menu read. A zero-window class also needs its
liveness read.

Every attempt before the class must be clean, except the deferred exhaustion of
the same return. A gap or partial receipt before the class blocks the candidate.
One after the class is retained, and it cannot erase the candidate.

The classifier also reports the pointer state from the `resize-down-N` and
`resize-release` receipts. A clean down without a later clean release is `held`.
A failed, partial or unreadable receipt is `uncertain`. A failed wait is a latch
reason, and it is not a held point.

## Settlement

`settle` takes the scenario and Task statuses and seven separate phase results.
The phases are collection, environment, endpoint, audit, stop, inventory and
screenshots. It applies the protocol's precedence.

| Disposition | Condition |
|---|---|
| `rejected` | A recurrence candidate with status 1 and a passed screenshot audit. Later failures stay recorded and cannot erase it |
| `failed` | Another failed assertion with its expected status. A classified assertion exits 1, and an exhausted poll exits 125 |
| `qualified` | A complete run, status 0 from both the scenario and Task, every phase passed and no held input |
| `unresolved` | Everything else, including a status that conflicts with the receipts |

A scenario status of zero cannot override failed receipts. A failed or
unavailable stop or inventory records `cleanup: unresolved`. A stop that did not
run with a passed inventory records `cleanup: not-requested`. Only E and A slots
that qualify admit a later slot.

## Decisions for review

- An app reopen has no row click, so a failed reopen is a failed assertion. It
  is not a recurrence candidate. The protocol's recurrence names a clean row
  click.
- A failed supplemental observer before a recurrence class makes the outcome
  unresolved. This choice cannot produce a false rejection. It can leave a real
  recurrence unresolved, and that outcome also prevents acceptance.
- The `screenshots` phase carries the k54 screenshot audit. This tool does not
  inspect pixels.

## Controls and provenance

`task check:vm-settings-sequence` runs 36 controls without a VM. The evidence
roots hold real receipts from `scripts/vm-guest-exec.py`. The scenario controls
replay the ordered calls of both real entry points through that backend. The
simulated guest supplied those calls, so they establish the operation order and
no native behaviour.

The records are in [`ordering-caller-evidence/`](ordering-caller-evidence/):

- `red.txt` runs the first 28 controls before the tool exists. All 28 fail, for
  that broad reason.
- `defects-red.txt` runs eight controls that a read of the handoffs added. Six
  fail on the first tool, for the named defects. Two pass, and they guard
  behaviour that must stay.
- `mutations.jsonl` disables 15 guards, one at a time, in isolated copies. Each
  named control passes on the unmutated copy and fails on the mutated copy.
  `mutate.py` is the instrument.
- `final-verification.txt` runs the new check and the prefix check. Its `.json`
  and `.subjects` files record the digests of each subject.

## Limits

- The controls use real receipts but no real guest. E01 still qualifies each
  read and each operation name in a guest.
- The ledger guards against cooperating processes and accidental changes. A
  same-user process can still rewrite the whole directory consistently.
- A `settled` entry is checked against its own recorded classification. A later
  replay does not classify the evidence root again.
- The `bash -n A B` form in 18 existing Taskfile lines parses only A, because
  bash reads B as an argument. `shellcheck` still parses those files. This task
  leaves those lines unchanged, and k171 records the disposition.

## Handoff

k169 added the run verb, and it feeds real phase results to the ledger. k170
feeds the audit and environment phases, and it cuts the whole-harness review.
k171 reconciles every original duty after that review. k54 still owns the
freeze, the readiness receipts, the screenshot audit and the runtime.
