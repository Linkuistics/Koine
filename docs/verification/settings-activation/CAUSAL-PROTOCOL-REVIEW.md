# Settings protocol review integration

K41 integrates k40's review at commit ea01a166 against the k38 producer at
b2253f0c. It repairs offline protocol readers and the [current plan](CAUSAL-PLAN.md).
No guest, VM, product-behavior change, signed-subject freeze or ordinary acceptance
runs here. K39 still owns the supported causal-design question before every
route/causal guest; k36 still owns the runtime wrapper and remaining execution.

## Dispositions

| Finding | Classification and action |
|---|---|
| P1-1, launch adds a client row | Real issue. Require and retain one ordinal launch prefix plus one candidate per wrapped interval. Check the complete list, identities, interval order and exact bounds. A retained extract is a regression subject. |
| P2-1, final focus input undefined | Contract stated unclearly. Final takes no focus input and rejects a supplied flag. Earlier successful window-control decisions remain the enclosing caller's required evidence. Final tests their native joins, then permits classification of a measured success or failure. |
| P2-2, mouse readiness delivery undefined | Real issue. Freeze a positive monitored down/up/session/nonce/callback criterion in the plan and implement its offline `mouse` reader. Name the existing stricter `return` reader for readiness-02. |
| P3-1, saved callback getter can retain earlier input | Real trade-off. Weigh the retained mouse observation explicitly before readiness-02. Keep strict Return object identity and its possible route unavailability. Mouse qualifies pair/callback correlation and does not claim callback event identity. |
| P3-2, route/nonce coverage | Real issue. Require an expected route nonce in both delivery CLIs. Add mouse command/transport, geometry and existing-output refusal controls. Actual AppKit tracking dispatch has no executable headless seam and stays an explicit runtime uncertainty. |

No finding supplies a native refusal, cause, external owner or justified product
repair. There is no finding classified as noise merely because runtime is absent.

## Launch-prefix accounting

The full retained [persisted extract](persisted-01/native-path-records.jsonl)
contains these actual-image client rows, all PID 814:

| Extract line | Native continuous tick | Recorded timestamp |
|---|---|---|
| 9 | 1337344730 | 2026-10-27 23:03:54.853131-0700 |
| 20 | 1370028603 | 2026-10-27 23:03:56.214959-0700 |
| 37 | 4338579225 | 2026-10-27 23:05:59.904569-0700 |
| 49 | 4476843871 | 2026-10-27 23:06:05.665596-0700 |

Its [application buffer](persisted-01/events.jsonl) contains activation calls for
selections 0, 1 and 2. The first native row is launch-associated context, about
1.05 s before `show.enter` by the saved wall observations. Its initiating API
is unknown. The [events extract](events-01/native-path-records.jsonl) has six
actual-image rows for five wrapped calls; its first row precedes `buffer.started`.
The [native extract](native-01/native-path-records.jsonl) likewise has six for
five calls in its [trace](native-01/trace.jsonl). These older projections lack
native ticks, so they support cardinality/history only. None establishes a new
historical exact application/native join.

The current frozen model uses the whole ordered client list: N+1 candidates for
N strictly ordered nonoverlapping wrapped intervals. Candidate 0 must strictly
precede the first bracket. It remains visible as `launchPrefixTick`, with all
candidates in `candidateTicks`; candidates 1…N map ordinally to the intervals.
All candidates must match the process, image and boot, with exact integer ticks.
Every interval's metadata is checked. Missing rows, extra rows, duplicate ticks,
invalid order/identity or a prefix that is not earlier fail availability. An
outside ordinal candidate stays OUTSIDE with its exact distance, even when
another row would enclose. No row is selected by its desired enclosure.

This empirical shape deliberately refuses a legitimate future launch with a
different row population. It is not a source attribution or a synchronous-row
contract. Another unexplained call can still confound correlation: neither N+1
nor enclosure is a verified transaction identifier. Each interval must pass,
not just a successful subset. A failed shape gate requires a reviewed protocol
decision; no row deletion, retry, clock fit or widened bounds is allowed.

The retained-extract control passes **all original extract rows** to the reader.
It labels its three interval brackets as synthetic exact ticks around the later
native candidates. It checks prefix retention and ordinal accounting, then
removes a wrapped-call row to prove MISSING rather than a shifted match. These
synthetic controls are not measurements of the old application clock. The
extract is a retained projection, not a completed whole-process rendering; the
separate rendering-completion controls remain mandatory for new input.

## Control and delivery boundaries

`control launch --focus-success` means independent initial window/front/key
observations and transports passed. `control setup --focus-success` means the
same for the setup selection, after the recorded launch decision. PENDING native
joins allow only the fixed provisional inputs. A known bad join stops at once.
The enclosing caller retains those two successful decisions. `control final`
accepts only their two final ENCLOSED joins and **no focus flag**. It does not
read or test measured focus. Measured delivery/join qualification still precedes
causal interpretation. A valid measured failure remains a result.

Readiness-01 uses the positive mouse pair plus callback correlation.
Readiness-02 uses direct Return plus exact callback event-object identity. Both
readers require the expected route nonce, never the receipt's own nonce as its
expected value. Their full criteria are frozen in the plan before observation.
Missing direct input does not become delivery through transport success.

The retained [mouse callback context](EVENTS-RESULTS.md) is default-mode
leftMouseDown about 0.35 s old, following menu close, rather than the ending up
event. This is evidence of getter limitations, not a prediction of Return.
Return identity can fail even for a delivered selection. The strict criterion
is intentionally retained rather than weakened to make qualification possible.
K39 must weigh this risk before choosing runtime; no slot starts here.

## Verification and integrity

The [prefix/policy RED](protocol-review-evidence/prefix-policy-red.txt) and
[delivery RED](protocol-review-evidence/delivery-red.txt) precede their repairs.
The final [headless check](protocol-review-evidence/controls.txt),
[documentation check](protocol-review-evidence/doc-links.txt) and
[measurement](protocol-review-evidence/measurement.json) record the actual
outcomes. The reusable entry remains `mise exec -- task check:settings-causal-protocol`:
Ruff, strict Pyright, Python reader/route/CLI controls, application/test compilation
and selected Swift diagnostics tests. It never launches AppKit or a guest.

The new retained-row, final-policy, nonce, mouse pair, command and stop controls
exercise the actual reader/route boundary. They cannot establish AppKit timer,
monitor, JXA or callback availability. The source AppKit probe is unchanged.
No new claim of timing neutrality, symptom preservation or common native time
for unsampled menu/show/notification rows follows.

The final input manifest and per-item comparison accompany the measurement.
They cover repository/dependency source and retained historical inputs; generated
check reports and Grove bookkeeping are excluded. Compiler/SDK executables and
transient build outputs are not inventoried. This is an offline verification
freeze, not a guest/signed-subject freeze. The historical raw archive, complete
extracted archive and events candidate are checked against their original
inventories. The original proposal and k33/k39/k36 criteria are checked against
the preceding commit. No original measured receipt is rewritten.

## Original duties and next boundary

Every duty in [the original comparison](CAUSAL-PROTOCOL-RESULTS.md#integrity-and-original-duties)
and the full FOCUS/CLOCK/PERSISTED comparisons remains live. K39 must establish
supported matched interventions and finite falsifiers for both competing causal
predictions, or escalate the actual evidence/controllability scope decision.
Row-click necessity alone cannot replace that question. Its design requires
review and earned integration before every guest, including route qualification.

K36 retains the runtime/readiness/freeze/audit/cleanup wrapper, actual signed
candidate/all-input/completed-golden freeze, failed transports/partials/NOT RUN,
exact clone stop and timing qualification. It must obtain positive failed-request/
native-disposition/responsible-context evidence, make a justified product repair
with a useful failing product seam where feasible, and separately declare/freeze
complete ordinary acceptance through `app:vm-verify-menu-bar` with diagnostics
disabled and every outcome retained. One selection must return one front/focused
Settings window. Driver waits, retries or repeated inputs are no repair.

Historical candidates, archives, strict false joins, classifications and closed
caps remain unchanged. Persisted timeout/nonzero transports stay failed and all
later complete phases stay NOT RUN. If external, retain positive evidence and
reproducer with repair unresolved; no upstream report without Antony's approval.
No causal ancestor closes, and no release or notarization occurs here.
