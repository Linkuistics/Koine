# Settings scenario baseline controls

This report belongs to `settings-scenario-baseline-controls-k175`. It closes
duties D026, D029, D065, D099, D106 and D262 of the
[duty ledger](ordering-reconciliation-evidence/duties.json).

**The current scenario keeps the inputs, waits and poll bounds of baseline
`f019161b` on every simulated passing path.** One failure path differs. After a
failed menu comparison, the baseline sent Escape and waited one second. The
current scenario sends neither, because the protocol forbids corrective input
after a failed assertion.

No VM ran. A simulated guest answered both scenarios, so this result establishes
no native behaviour and no Koine result. Every E and A assertion stays NOT RUN.

## The control

`task check:settings-baseline` runs two scripts against one guest model:

- The real baseline script of `f019161b`, through a simulated `testanyware` CLI.
- The current scenario, through the simulated evidence backend.

Each run gives one ordered stream of inputs, window actions, submissions, uploads
and waits. The [retained record](ordering-baseline-evidence/baseline.json) holds
the baseline streams, and a control derives that record again from the commit.

The control has 17 cases. One case completes the scenario. The other 16 each hold
one poll false or falsify one assertion, so their streams show the bound of that
poll. The streams hold 3,054 current events.

The [classification](ordering-baseline-evidence/classification.json) is the
reviewed part of the control. It holds these items:

- The class, reason and citation of each difference.
- The current statement of each of the 17 baseline waits.
- The current statement of each of the 57 baseline assertions.
- The ordered reads, payload contracts and state predicates of the complete run.
- The curl, snapshot and OCR limits, which are not waits.

An unclassified difference fails the control. A classified difference that no
longer occurs also fails it.

## The four early waits

A text search of the baseline scenario finds 17 waits. The k62 comparison did not
name the first four. They are in helpers and in the TextEdit poll:

| Baseline wait | Baseline site | Current statement |
|---|---|---|
| 2 seconds | `await_koine`, after each negative read | `await_guest_endpoint`, `limit=15 delay=2` |
| 6 seconds | `await_settled` | `settings_await_settled` |
| 3 seconds | `expect_stopped` | `settings_expect_stopped` |
| 2 seconds | TextEdit poll, after each negative read | `_await_guest_windows` |

## Differences from the baseline

The streams show three differences. All three are on a failure path.

| Case | Difference | Class | Reason |
|---|---|---|---|
| `menu-titles` | No Escape and no one-second wait after a failed comparison | `no-corrective-input` | [Review k167, P2-2](ORDERING-PREFIX-RESULTS.md#p2-2-a-menu-mismatch-sends-no-corrective-input) and the protocol's failure rule |
| `window-count` | The message names the live process and the front application | `classified-outcome` | [Outcome classes](ORDERING-OUTCOMES-RESULTS.md#outcome-classes) |
| `restart-boot` | The message names a test-driver or guest failure | `restart-classification` | [The protocol's restart row](ORDERING-EVALUATION-PLAN.md#required-transport-and-evidence-handling) |

The classification also holds 18 source differences that a passing stream cannot
show. Examples are the removed keepalive loop and the single transport attempt.
The [prefix report](ORDERING-PREFIX-RESULTS.md#later-ordinary-assertions-and-the-baseline)
gives their history.

## Failing controls

The [mutation record](ordering-baseline-evidence/mutations.txt) holds 19 changes
to private copies. Each change makes the control exit 1 with the expected finding:

- Inputs in the scenario and in a facade, and one added input.
- Waits in the scenario and in two facades.
- The seven later waits that passed every suite in the k171 measurement.
- The bounds of the label, count, login, boot and reveal polls.
- One read limit.
- Assertions in the scenario, a facade and the library, one weaker value read and
  one removed assertion.
- A restored Escape on a failed menu comparison.

## The empty field

A new scenario control omits AXValue from the field at `shortcut-emptied`. The
read is unavailable, the scenario exits 125, no state decision runs and no later
input follows. The same control reads a real empty string and passes. The
[control record](ordering-baseline-evidence/axvalue-control.txt) also shows the
control failing when the read accepts a missing value.

Whether the native field reports an empty AXValue stays an accepted limit. This
work adds no read, wait or retry for it.

## Limits

- The streams cover the paths that the 17 cases drive. A branch that no case
  reaches is pinned only by its source statement, if it has one.
- The pairing of each baseline assertion with its current statement is a reading
  judgement. The control detects a later change to either side. It cannot prove
  that the first pairing is right.
- The control does not compare read counts with the baseline, because the protocol
  adds reads. It claims no timing neutrality.
- The simulated CLI models the guest. It does not reproduce a transport failure
  or the legacy retry of the baseline.

## Records

The records are in
[`ordering-baseline-evidence/`](ordering-baseline-evidence/):

- `baseline.json` is the record derived from the baseline commit.
- `classification.json` is the reviewed classification.
- `mutations.txt` holds the 19 failing mutations.
- `axvalue-control.txt` holds the empty-field control and its failing run.
- `final-verification.txt` runs the affected checks between two digests of every
  tracked file. `measure.py` is its instrument.
