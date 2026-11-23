# Settings harness reconciliation

This report belongs to `settings-ordering-reconciliation-k171`. It compares each
original duty of k53, k56, k61, k66, k71, k75, k80 and k85 with the current source
and controls. It also checks the k52 application change against Apple's public
contracts.

**No contract sentence stays open, but two owner decisions still precede the k54
freeze.** One is the TestAnyware version. The other is the
[storage allowance](ORDERING-STORAGE-PLAN.md#decision-for-the-owner), because no
proven byte bound exists. No item shows a Koine failure. After this reconciliation,
leaf k174 closed duty D181, leaf k175 closed six baseline and empty-field duties,
and leaf k176 closed five storage and privacy duties.

The evidence is source and controls only. No VM ran, and no clone, signed subject
or runtime slot exists. The work establishes no native behaviour, no native cause
and no scenario readiness. It closes no ancestor.

## Result

The [duty ledger](ordering-reconciliation-evidence/duties.json) holds one row for
each distinct sentence of the eight archived contracts. Each row records its
disposition, source, controls, failing record, owner, authority and note.

| Contract | Met | Owned by k54 | Withdrawn | Limit | Gap | Context | Sentences |
|---|---|---|---|---|---|---|---|
| k53 | 15 | 7 | 0 | 1 | 0 | 28 | 51 |
| k56 | 12 | 4 | 0 | 0 | 0 | 17 | 33 |
| k61 | 21 | 3 | 0 | 0 | 0 | 17 | 41 |
| k66 | 19 | 3 | 0 | 0 | 0 | 20 | 42 |
| k71 | 20 | 8 | 0 | 1 | 0 | 22 | 51 |
| k75 | 13 | 4 | 0 | 5 | 0 | 36 | 58 |
| k80 | 10 | 4 | 1 | 10 | 0 | 25 | 50 |
| k85 | 11 | 4 | 15 | 11 | 0 | 26 | 67 |
| **Total** | **121** | **37** | **16** | **28** | **0** | **191** | **393** |

A repeated sentence counts once, under the first contract that states it. Its row
names the other places.

| Disposition | Meaning |
|---|---|
| Met | Current source delivers the duty, and a named control exercises it |
| Owned by k54 | The live k54 task holds this runtime or readiness duty |
| Withdrawn | The keepalive ADR or an accepted spec amendment withdrew the duty |
| Limit | A reviewed report accepted the shortfall as a visible trade-off |
| Gap | Nothing delivers the duty. A new leaf owns it |
| Context | The sentence states history or routing, and no duty still binds |

## Closed gaps

Leaf k176 closed D215, D216, D270, D275 and D372. `declare` now refuses a sequence
directory that could enter version control. The
[storage plan](ORDERING-STORAGE-PLAN.md) states the location, the retained classes,
the allowance, the free space and the behaviour on a full volume.

Leaf k174 closed D181. The classifier now reports a first essential `interrupted`
receipt as `interrupted`, with or without a signal record. The slot still settles
`unresolved`, so the repair changes the reported outcome only. The
[record](ordering-reconciliation-evidence/interrupted-outcome.txt) holds the failing
run, the classifier comparison and the guard mutations.

Leaf k175 closed D026, D029, D065, D099, D106 and D262. A control now compares the
scenario's inputs, waits, poll bounds and assertions with baseline `f019161b`, and
a scenario control omits AXValue at `shortcut-emptied`. The
[baseline report](ORDERING-BASELINE-RESULTS.md) holds the result and its limits.

## Method

The [ledger check](../../../scripts/check-settings-duty-ledger.py) enumerates every
sentence from the archived bytes, so a row cannot disappear unnoticed. Three
read-only helper sessions classified the sentences against the current source.
This session then read each gap against the source. It also read every `owned` and
`limit` row, and each `context` row from a binding section.

`task check:settings-duty-ledger` resolves each cited symbol, exact control name,
record and authority. Its 15 controls show that it refuses a missing duty, changed
text, a changed contract, a false citation and a missing owner.

A resolved citation proves that the evidence exists. It does not prove that the
evidence supports the disposition. That judgement stays with the classifying
session and this reconciliation.

## Reviews and the k62 comparison

The k36 subtree holds 19 review leaves and 18 integration leaves, and all are
complete. Review k148 found nothing that earned an integration. The last chain is
the whole-harness review [k172](ORDERING-HARNESS-REVIEW.md) and its integration
[k173](ORDERING-HARNESS-INTEGRATION.md). This reconciliation read the source that
k173 changed.

The [k62 comparison](ORDERING-PREFIX-RESULTS.md#method-of-the-duty-comparison) was
written before k165 to k173 changed the harness. This report therefore uses it as
a guide and classifies each duty again. Three of its results change:

- k62 recorded the preserved inputs and waits as met by comparison. This report
  records a gap, because the controls do not detect a change to seven explicit
  waits. The [mutation record](ordering-reconciliation-evidence/wait-mutations.txt)
  holds the runs. Some other waits fail a control, but only because a test
  depends on their literal text. Leaf k175 closed this gap.
- k62 assigned signal classification to k57. The caller delivered it for signal
  records, but not for an interrupted receipt without one. Leaf k174 closed that
  gap.
- k62 assigned finite storage to k57. The k57 split named no owner for it, and no
  later task delivered it. Leaf k176 closed this gap.

## Application API contracts

The [retrieval receipt](ordering-reconciliation-evidence/apple-contracts.json)
records the contracts that this session fetched again. The `activate()` and
`makeKeyAndOrderFront(_:)` responses and the installed SDK header have the same
SHA-256 digests as the k52 receipt.

| Point | Primary source | Current source | Disposition |
|---|---|---|---|
| Self-activation is available | `activate()` is available from macOS 14 | The package requires macOS 26 | Met |
| Activation is a request | "calling this method doesn't guarantee app activation" | The return value gates nothing, and no retry exists | Met |
| Activation may finish later | The SDK header says not to assume immediate activation | The comment at the call states this limit | Met |
| Key and front placement | The window moves to the front "within its level" and becomes key | One request follows activation in the same invocation | Met |
| Key eligibility | `canBecomeKey` is true for a style mask with `titled` | The window style includes `.titled` | Met |
| Pending yields | `activate()` on an active application cancels pending yields by the receiver | The application adds no yield | Met |
| Relative order | Neither contract prescribes an order | The comment calls the order empirical | Met |
| Citation at the decision site | Both URLs | `Sources/KoineApp/AppDelegate.swift:132` and `:133` | Met |

The show method holds one activation request and one key and front request. It
holds no suspension, dispatch, sleep or retry. Its last source change is the k52
commit. This session did not build or launch the application. OS discretion stays
open, and these contracts prove no focus result.

## The `bash -n A B` lines

`bash -n A B` parses only A, because bash reads B as an argument. In the Taskfile,
23 such lines leave 47 files unparsed, and 22 of those files belong to the harness.

**Disposition: keep the lines unchanged.** `shellcheck` runs in the same task for
each of the 22 files, and it fails on a syntax error. Each file also parses when
checked alone. A direct repair would be wrong for the suites, because `bash -n`
rejects valid Bats syntax. The [parse record](ordering-reconciliation-evidence/syntax.txt)
holds these results and their failing controls.

## Limits that stay

- A checked upload proves the local bytes, the remote path and the reported size.
  It does not prove the guest copy of the two uploaded scripts. Reviews k149 and
  k150 kept this limit. A scenario download needs a new human amendment.
- The k55 base suite keeps no failing record. Facade suites keep failing records
  for the same classes, and the past state cannot be recorded again.
- The missing snapshot tree, the empty AXValue, the OCR substring stop and the menu
  oracle stay native availability limits.
- The synthetic guest establishes call order and classification. E01 still
  qualifies each real read.
- The TestAnyware version decision stays a prerequisite of k54.
- No proven byte bound exists for a slot. The owner decides on the storage allowance
  before the k54 freeze.
- A zero exit status from `run` does not show that the caller kept its records. On
  a full volume, the caller can leave a clone running. The storage plan gives the
  recovery steps.

## Outcome separation

The report keeps three outcomes apart. A Koine failure needs a qualified assertion
in a guest, and none exists. A test-driver failure covers the harness and its
tools. An interrupted attempt is unresolved evidence and is neither of those
outcomes. Every E and A assertion is NOT RUN.

## Records

The records are in
[`ordering-reconciliation-evidence/`](ordering-reconciliation-evidence/):

- `duties.json` is the ledger.
- `apple-contracts.json` holds the digests and checked excerpts of the contracts.
- `syntax.txt` holds the parse results, and `syntax-parse.py` and
  `syntax-shellcheck.py` are its instruments.
- `wait-mutations.txt` holds three runs on private copies with changed waits.
- `final-verification.txt` runs the 23 harness checks between two digests of every
  tracked file. `measure.py` is its instrument.
- `interrupted-outcome.txt` holds the k174 failing run, comparison and mutations.
  `interrupted-outcome-measure.sh` and `interrupted-outcome-differential.py` are its
  instruments.

## Handoff

Before the freeze, k54 runs `task check:settings-duty-ledger -- --require-closed`,
which refuses any open gap.
A later change to a source or control reopens its rows and any earned review.
