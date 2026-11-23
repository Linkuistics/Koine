# Settings harness reconciliation

This report belongs to `settings-ordering-reconciliation-k171`. It compares each
original duty of k53, k56, k61, k66, k71, k75, k80 and k85 with the current source
and controls. It also checks the k52 application change against Apple's public
contracts.

**The harness is not ready for the k54 freeze.** Twelve contract sentences stay
open. They reduce to three precise pieces of work, and each piece has a new leaf
before k54. No open item shows a Koine failure.

The evidence is source and controls only. No VM ran, and no clone, signed subject
or runtime slot exists. The work establishes no native behaviour, no native cause
and no scenario readiness. It closes no ancestor.

## Result

The [duty ledger](ordering-reconciliation-evidence/duties.json) holds one row for
each distinct sentence of the eight archived contracts. Each row records its
disposition, source, controls, failing record, owner, authority and note.

| Contract | Met | Owned by k54 | Withdrawn | Limit | Gap | Context | Sentences |
|---|---|---|---|---|---|---|---|
| k53 | 13 | 7 | 0 | 1 | 2 | 28 | 51 |
| k56 | 11 | 4 | 0 | 0 | 1 | 17 | 33 |
| k61 | 19 | 3 | 0 | 0 | 2 | 17 | 41 |
| k66 | 19 | 3 | 0 | 0 | 0 | 20 | 42 |
| k71 | 17 | 8 | 0 | 1 | 3 | 22 | 51 |
| k75 | 10 | 4 | 0 | 5 | 3 | 36 | 58 |
| k80 | 10 | 4 | 1 | 10 | 0 | 25 | 50 |
| k85 | 10 | 4 | 15 | 11 | 1 | 26 | 67 |
| **Total** | **109** | **37** | **16** | **28** | **12** | **191** | **393** |

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

## Open gaps

| Leaf | Duties | Missing work | Effect today |
|---|---|---|---|
| `settings-ordering-interrupted-outcome-k174` | D181 | An `interrupted` receipt with no signal record is classified as `unavailable` | The slot settles `unresolved`. It cannot produce an acceptance, but the report merges two separate outcomes |
| `settings-scenario-baseline-controls-k175` | D026, D029, D065, D099, D106, D262 | No control pins the scenario's inputs, waits and later assertions to baseline `f019161b`. No scenario control omits AXValue at `shortcut-emptied` | Earlier sessions compared the baseline by reading. With seven later waits each one second longer, the prefix, scenario and sequence suites still passed |
| `settings-ordering-evidence-storage-k176` | D215, D216, D270, D275, D372 | No finite storage plan exists. `declare` accepts a tracked or published path for a root that can hold the VM password | A run could fill the disk, or an operator could place private evidence in a tracked path |

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
  depends on their literal text.
- k62 assigned signal classification to k57. The caller delivers it for signal
  records, but not for an interrupted receipt without one.
- k62 assigned finite storage to k57. The k57 split named no owner for it, and no
  later task delivered it.

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

## Outcome separation

The report keeps three outcomes apart. A Koine failure needs a qualified assertion
in a guest, and none exists. A test-driver failure covers the harness and its
tools. An interrupted attempt, the subject of gap D181, is unresolved evidence and
is neither of those outcomes. Every E and A assertion is NOT RUN.

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

## Handoff

The leaves k174, k175 and k176 run next. Each one updates its ledger rows. Before
the freeze, k54 runs `task check:settings-duty-ledger -- --require-closed`, which
refuses any open gap. A later change to a source or control reopens its rows and
any earned review.
