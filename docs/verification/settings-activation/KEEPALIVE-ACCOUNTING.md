# Settings workload scheduling and record accounting

## Contract and outcome

This derivation connects the reviewed [workload inventory](KEEPALIVE-WORKLOAD.md)
to the [owner](../../specs/settings-keepalive-owner.md) and
[record schema](../../specs/settings-keepalive-records.md).
It supplies path equations, publication costs and the remaining evidence inputs.
It supplies no adopted capacity, implemented coordinator or native result.

The [accounting view](../../design/architecture/settings-activation/keepalive-accounting.mmd)
shows the calculation order. Graphs start at the dark **Start here** node.
Solid arrows show dependencies. The diagram is not a model-checking result.

The owner retains one writer, one ordinal sequence and irreversible operation charges.
The caller supplies the finite workload and privately retains originals.
The producer owns its versioned internal units.
The storage mechanism must independently protect ordinary, collection and terminal capacity.
None of these owners can certify another owner's missing evidence.

K133 reviewed the inventory and k134 integrated its findings before this derivation.
K125 owns external evidence scopes. K126 owns final useful-profile fit and whole-design reconciliation.
This derivation needs scoped review before either consumes it.

## Expand paths before taking maxima

Let `P_E` and `P_A` contain the permitted paths for one declared focused or ordinary slot.
Each includes every reachable failure cut, signal and unavailable observation.
An element records ordered occurrences, not merely a vector of totals.
Each occurrence binds the inventory site, loop index, branch, exact request, predicate,
family, storage class, outputs and local work.

The inventory's [ordered expansion](KEEPALIVE-WORKLOAD.md#ordered-scenario-expansion)
remains the authoritative site list.
P00 and P01 precede cadence. P02 through F04 form the shared prefix.
A then includes O01 through O11. E ends after TextEdit quit and its confirmation.
Collection and the caller tail follow either route where their prerequisites hold.

At each poll, distinguish a qualified positive, a qualified negative and transport or evaluation failure.
Only a clean negative takes another iteration.
Its state receipt, sleep and any exhaustion record retain their own costs.
A failure prefix stops ordinary work at that boundary.
Do not append later successful phases to a failing path.

The following coefficients are derivable now. They are checks of the baseline expansion,
not a total for the repaired scenario.

| Component | Instantiable bound or relation | Work still added separately |
|---|---|---|
| Direct captures | E has 2. Complete A has 6. | Required menu/context captures, collection images and charged ticks. |
| Window polls | E has 9 invocations. A has 17. Each permits 10 reads and state decisions. | Original-list title audits and positive setup. |
| Endpoint polls | E has 1 invocation. A has 3. Each permits 15 reads. | Application identity joins and separate post-restart 24-read poll. |
| Label polls | E has 1 invocation. A has 7. Each permits 15 reads. | Local state receipts and exhaustion evidence. |
| Menu helpers | E has 4 choices and 1 read. A has 9 choices and 5 reads. | Enabled-target, open-menu capture, closed-menu and outcome evidence. |
| Menu clicks | `2 * choices + reads`: E has 9. A has 23. Each has one size read and three inputs. | Frame reads, predicates and their failures. |
| Drags | A has 2. Each has one initial frame read and 13 inputs, with 3.2 seconds explicit sleep. | Separate post-drag reads, growth/minimum checks and held-pointer failures. |
| Calibration | A has one: one window read, two snapshots, 31 scroll inputs and 31 seconds explicit sleep. | Local direction calculation and state records. |
| Reveals | A has 10, including both searches inside each `reveal_click`. | Geometry reads and clicks after a successful search. |
| One reveal | Success on read `r <= 60`: `2r-1` snapshots and `r-1` scrolls. Exhaustion: 120 snapshots and 60 scrolls. | One window read, local decisions and one second after each scroll. |
| TextEdit poll | At most 15 loop reads plus its unconditional final read. | Positive PID, geometry, front and subrole facts. |
| Add-button poll | At most 15 snapshots and 14 negative sleeps of two seconds. | The Add click and its two settling sleeps. |
| Restart | One clean restart, sleep 30, at most 60 boot reads with sleep 5 after each clean unchanged result. | Before/after boot originals, post-login screen geometry and diagnostic checks. |
| Post-login endpoint | At most 24 reads with sleep 5 after each clean absence. | The subsequent ordinary endpoint poll remains separate. |
| Stopped checks | A has 3. Each has sleep 3 and two exec observations. | Final exact-clone stop and independent inventory are different operations. |

For example, ten successful reveals can contribute 1,190 snapshots and 590 scrolls.
These counts exclude calibration and every other snapshot/input site.
A final exhausted reveal can have a larger local prefix than a successful reveal.
Its path omits later work, but still contributes failure and collection costs.
Taking each helper's independent maximum is a safe coarse envelope only after every omitted contribution is bounded.
It is not an executable path or evidence of useful fit.

Every `X`, `W`, `S`, `I`, `A`, `C`, `F` and `L` occurrence contributes its complete family cost.
Successful explicit sleeps have no command ordinal.
Their process, status, clock and failure evidence still consumes capacity.
The original sleeps include both successful settling and the last negative sleeps where specified.
The inventory's printed reads remain distinct unless the protocol explicitly shares the same original.

P02 includes local archive creation and three uploads after worker cadence starts.
Include source bytes, archive bytes, guest extraction, inventories and simultaneous copies.
P03 contains one Allow OCR invocation and one exact selection.
No extra OCR invocation repairs substring-only output.
The six baseline images remain distinct from menu, failure and keepalive images.

For each input occurrence, include internal connection and `confirm_input_read` work.
Its 1×1 update request does not bound received rectangles or frame allocations.
Include internal key/modifier events, scroll decomposition and their sleeps.
For OCR, include every internal capture/encode/recognition cycle and simultaneous buffers.
Those cycles acquire no additional owner ordinal.
Their count, wire work and native costs need the dependency's enforceable unit schema.

## Start, active cadence and final time

### Separate the start family

The retained bare `vm start --wait` has a 600-second queue option in the pinned source.
The [scheduling source assessment](KEEPALIVE-SCHEDULING.md#command-and-wait-inventory)
records that fact and its provisioning limit.
The current common helper starts cadence only after clean start, before environment reads and uploads.

Define finite, separately evidenced CLI stage bounds for pre-queue setup,
provisioning, boot/readiness and post-boot response work.
Their sum is `U_start`. Include local/native work outside the queue in those stages.
The proposed dedicated start family requires:

```text
C_start = 600 seconds + U_start
W_start = C_start + 22 seconds
```

The 22 seconds are the existing non-CLI phase allowances, not free additional publication time.
Each required write and carrier must fit its assigned phase below.
No value for `U_start` is established. Startup therefore remains unavailable.
The earlier 120/142-second lifecycle row no longer describes start's intended contract.
Other lifecycle operations retain that proposed row.

Worker readiness precedes start. It creates no sleep or tick while start is pending or active.
The start request still follows the owner admission and commitment protocol.
Its long execution does not block a tick admission clock because no tick exists yet.
The five-second owner-readiness allowance excludes VM start.
No scenario operation may overlap start or bypass its complete result.

Failure or uncertain start suppresses cadence and retains the requested identity and actual returned facts.
The owner and caller use their unchanged holder-containment windows.
Only established ownership and exact clone identity permit applicable collection, stop and independent inventory.
Missing identity or holder resolution leaves exact-clone containment unavailable.
Neither the 600 seconds nor a proposed whole deadline guarantees native termination.

### Bound the interval in which ticks can become due

Let `t0` be the first worker sleep intent and `ts` the event that suppresses future ticks.
For each path `p`, partition `[t0, ts]` into scenario intervals, explicit waits and other local/control intervals.
Do not count an interval twice because two actors overlap there.
Let `A_i` cover request origin through commitment and `W_i` cover commitment through complete delivery.
Use 152 seconds for each applicable post-start `A_i`.

Let `D_p` sum the unchanged explicit waits.
Let `L_p` bound local computation, archive construction, transcript work, finish delivery and other uncovered control work.
Let `H_p` bound uncovered failure detection and suppression delay.
These parameters must include post-start installation and the longest failing prefix.

```text
B_p = sum_i (A_i + W_i) + D_p + L_p + H_p
B = max over P_E or P_A of B_p
K_due <= floor(B / 20 seconds)
K_published <= K_charged <= K_due
```

For a request that fails before commitment, charge its elapsed admission prefix once in `B_p`.
For an operation cut after commitment, charge its elapsed operation prefix once.
Do not include that same prefix again in `H_p`.
The caller's separate report limit belongs only to the uncovered detection suffix.
No numerical `B` exists until all local and failure-detection terms have finite evidence.

Every due tick needs a distinct completed twenty-second sleep.
The next sleep follows complete tick disposition, so these sleep intervals cannot overlap.
Thus `20 * K_due <= ts - t0 <= B` on a bounded observed path.
Tick service during an explicit wait does not lengthen that unchanged wait.
Tick service blocking a scenario request already consumes its admission interval.
Adding `52 * K_due` to `B` would count that service twice.

At most one due tick is outstanding at suppression.
It may remain unassigned, be charged without a complete commitment, or have a published commitment.
An unassigned cancellation costs terminal records but no capture attempt.
A charged tick retains its full operation allowance even if publication or creation fails.
Ordinal burning after loss proves neither a charge nor execution.
Keep the unavailable prior allowance unavailable instead of reconstructing fictional attempts.

The admission argument remains `2 + 2 + 2 + 142 + 2 = 150 < 152` seconds.
It requires all post-start holder work to fit the 142-second maximum.
Carrier writes, attachment preparation and fence work must fit the stated phases.
Any necessary larger post-start allowance requires a new scheduling proof and review.
Start's separate family supplies no such enlargement.

### Stop, collection and caller intervals

At `ts`, future ticks stop. A charged tick retains its original deadline.
No catch-up tick or another worker sleep follows suppression.
Clean stop retains the 150-second outer target and the original drain subdeadlines.

The capture drain is at most 58 seconds from finish receipt under those targets.
The sleep drain is at most 30 seconds. Intent publication overlaps that drain.

Failure containment has one twenty-second window per existing supervisor role.
Owner and caller observations can differ, so total path accounting uses their actual ordering and overlap.
It must not reset either window after another failure.

The finite caller must bound its own waits and local recovery scan.
No design deadline bounds an unavailable host's physical return.

Let `C(p)` be the ordered applicable collection items proved never fenced.
Each contributes its admission, operation, local work and required records once.
Include one evidence-class local failure record when applicable.
Its 22-second origin is the first owner failure observation, including holder wait.
A late opportunity leaves that record unavailable rather than restarting its allowance.

Normal collection and failed-owner collection share the immutable item plan.
Recovery withholds already fenced items and their allowances, even without a visible binding.
It can use only the proven remaining suffix.
Collection labels C01–C06 are not six commands: C04 still needs a concrete finite expansion.

The total observed run path is:

```text
bootstrap + start admission + W_start + active prefix
  + uncovered stop/containment/recovery intervals
  + applicable collection + final handoff/caller intervals
```

Take the maximum over clean and failing paths, without summing overlapping intervals.
The final handoff remains four two-second stages, eight seconds total.
The added record observations below must fit those stages.
None adds permission to wait longer or guarantees successful collection.

## Derive publication carriers

Use `Kk` for record kind `k`. This is distinct from the tick counts above.
The schema's [carrier schedule](../../specs/settings-keepalive-records.md#publication-carriers)
governs publication before dependent effects.
The following count uses attempted publications, including failed writes and retained prefixes.

For one path, define `Jx` as the number of attempted standalone K20 carriers for target kind `x`.
Define `F6` and `F7` as fallback K20 attempts for fence and binding observations.
Then:

```text
v(p) = J4 + J5 + J9 + J18 + J21 + J23 + J25 + J26 + J27 + F6 + F7
v = max_path v(p)
```

| Target | Path count and embedded alternative | Lane |
|---|---|---|
| Prepared objects, K1–K3, earlier K4 batches | Each preparation result belongs to exactly one later K4 vector. | Bootstrap |
| Final or failed setup K4 | `J4 <= 1`. Its mandatory K20 precedes transfer. | Bootstrap |
| Generation K5 | `J5 <= 2`: owner opening and, if entered, one successor opening. | Owner history or successor |
| Fence K6 | Each K7 carries its fence observation. If that carrier cannot retain it, count its fallback in `F6`. | The writing owner's current lane or successor |
| Binding K7 | K9 carries its observation. If that carrier cannot retain it, count its fallback in `F7`. | The writing owner's current lane or successor |
| Commitment K9 | `J9 <= a`. Its mandatory K20 precedes child creation. | Current operation lane |
| Disposition K18 | `J18 <= a`. Its mandatory K20 precedes completion send. | Current operation lane |
| Stop K21 and worker reap K23 | `J21 <= 1`, `J23 <= 1`. | Owner tail |
| Range disposition K25 | `J25 <= 1`. Normal and failed transfer are alternatives. | Caller final or successor |
| Owner handoff K26 | `J26 <= 1`. Its K20 precedes response and transfer. | Owner tail |
| Owner exit K27 | `J27 <= 1`. Its K20 precedes K28. | Caller final |
| K28, K20, K29 | No recursive K20. Final publication uses the caller-return boundary. | Existing lane |

On a complete normal path with `a` assigned operations, `v(p) = 2a + 7`.
This includes start, scenario, tick and collection operations in `a`.
It includes both normal-transfer and owner-exit carriers.
That identity is a clean-path cross-check, not the failure bound.

A failed carrier and its fallback are separate attempted rows.
A fence followed by no assignment still has a publication outcome requiring the schema's fallback treatment where writing remains possible.
Therefore `F6` cannot be estimated solely from successfully assigned operations.
For conservative accounting, allow at most one fallback per failed or unavailable carrier opportunity.
Count fence-without-binding and binding-without-commitment cuts explicitly.

A loose algebraic envelope is `F6 <= a + f + f_c` and `F7 <= a`.
It permits a fallback at each assignment opportunity and each fence-only tail.
Consequently `v <= 4a + f + f_c + 8` is a coarse envelope under this catalogue.
The profile must still derive the smaller lane-specific reachable counts.
Neither this envelope nor a missing carrier permits another operation.

Writer death can prevent a fallback write, leaving its reserved capacity and observation unavailable.

For setup, let `O_prepare` count publication results for prepared objects and creation evidence requiring K4 coverage.
Let `z` be the finite K4 publication-vector maximum and `b` its batch count.
Earlier K4 batches also need observations in later batches.
Thus `b*z >= O_prepare + p + 2 + (b-1)` is necessary for a complete bootstrap.
Here `p+2` covers K2 fragments, K1 and K3.

This inequality alone does not prove an acyclic, ordered packing.
The final K4 uses K20, avoiding another K4 solely to observe itself.

### Assign every publication to its deadline

Each row below includes attachment construction, bounded parsing, write, flush,
namespace and visibility observations required at that point.
Carrier publication has its own I/O cost even when its payload is small.
All limits remain targets awaiting applicable evidence.

| Work | Owning interval and constraint |
|---|---|
| Profile, slot and attachment preparation | P00's separately bounded preparation interval, before owner creation. Partial preparation has finite capacity and no restart. |
| Owner-creation attachment, final setup K4/K20, lock transfer, owner K5/K20 and worker readiness | The existing five-second startup interval after owner-creation request. Prepared bulk storage is not silently moved into this interval. |
| Request original and K8 received/admitted/refused | Two-second transfer and two-second admission stages, inside the original admission clock. Refusal capacity precedes this work. |
| Fence if needed, K7 attachments/binding, exact directory observation and K9 | The two-second selection/commitment interval, inside admission. No hidden fence-preparation pause. |
| K9 carrier, process/descriptor binding, collector/limit setup and observed CLI creation | The shared two-second creation phase after commitment. A failed carrier forbids backend creation. |
| K13 and original progress reports | The reported phase or its following phase, under the existing two-second report limit and whole deadline. No additional serial allowance. |
| K14, raw objects and K15 validation/result | Their actual backend creation, CLI, validation and emission phases. Preserve all simultaneous object and buffer costs. |
| K16/K17 and original acknowledgement | The two-second offer/acknowledgement phase. |
| K18 and its K20 | The two-second terminal-publication phase, before send. |
| Completion send, its K19 and later echo K19 | Send record fits completion delivery. Echo follows its existing next-request/finish/worker-phase boundary and message limit. It extends no operation. |
| K21 and K20, then cancellation K8 | Stop intent and carrier fit its two-second publication target. Cancellation fits the following existing two-second limit. |
| K22, actual worker wait, K23 and K20 | Existing acknowledgement, exit and reap-publication stages. K23/K20 share the last two seconds. |
| Failure controls, K24, fallback K20 and K29 | Their triggering phase and unchanged containment/stop deadlines. They create no fresh operation clock. |
| Recovery scan, K25 attachments/K20, successor K5/K20 and delayed observations | Explicit bounded recovery-entry work after exclusive original-lock acquisition. Its missing bound prevents complete run fit. It extends no termination window. |
| K26 and K20 | The first two-second final-handoff stage, before response and lock transfer. |
| Normal K25/K20 and caller observations | Caller receipt/transfer stage within the existing eight-second final sequence. Owner wait retains its own stage. |
| K27, K20 and K28 | Final caller publication stage. Normal K25 is already complete. Failed recovery starts this lane with K27. |

The simultaneous earliest deadlines govern shared writer work.
For example, a due-tick K8 cannot wait behind a blocking commitment write beyond its admission-record deadline.
The eventual writer mechanism must satisfy control-loop responsiveness and all overlapping phase ceilings.
If its worst permitted flush blocks longer, the timing profile fails useful fit.
No record rearrangement can silently remove a required observation.

## Counts, lanes and retained objects

### Instantiate what the schema determines

For each complete path, count received submissions `n(p)` and assigned attempts `a(p)` separately.
Start contributes one ordinary submission and at most one assignment.
Ordinary scenario occurrences and due ticks add their own entries.
Collection adds only actual applicable submissions and assignments.
A refusal or cancellation adds K8 rows without adding an attempt.
The four-row-per-submission K8 envelope remains conservative.

Use the schema's catalogue to derive each kind count, with these unresolved inputs:

| Parameter | Derivation requirement |
|---|---|
| `n`, `a` | Maxima over the expanded operation paths, including start, charged ticks and collection. Bound post-failure refused submissions too. |
| `w` | Count each legal worker phase report and terminal report. There are at most `K_due + 1` sleep cycles before suppression. |
| `h`, `t` | Count process/holder observations and distinct target/window pairs by phase, including owner and caller containment. |
| `q` | Count first failure plus every distinct later control. Close malformed channels once. Duplicate notifications add no rows. |
| `g` | Maximum backend/launcher/collector/validator progress reports per attempt under the actual protocol. No invented periodic heartbeat. |
| `p`, `b` | Count bounded profile fragments and the ordered setup batches, including their embedded preparation observations. |
| `f`, `f_c` | Count attempted ordinary and collection fences, including failed fence-only tails. |
| `v` | Derive from the carrier equation above. It is not an independent discretionary allowance. |

The catalogue's conservative total of terminal rows simplifies to:

```text
R_terminal <= 18 + p + b + f + f_c + 4n + q + h + w + a*(g+7) + v + 5t
```

This excludes backend K14/K15 from the terminal pool.
Their attempt storage includes one request and at most two result frames.
The constant includes at most four K29 summaries across bootstrap, owner, successor and caller-final roles.
Owner history and owner tail share that owner's one K29 allowance.
The total is a componentwise envelope. It does not determine any lane length.

The parameter vector has exactly 29 entries, so `m >= 29`.
Schema cardinalities include five layout lanes, three backings, two assigned/burned ranges,
two pending submissions and four terminal status fields.
The remaining maxima need concrete manifests:

| Maximum | Must cover |
|---|---|
| `u` | Every resource cell in a charge, settlement or remaining-tail vector, including the pinned dependency units. |
| `r` | Largest reference vector across fragments, registries, assignments, descriptors, collection prerequisites and tail-state references. |
| `z` | Largest K4 publication batch, consistent with the ordered setup packing. |
| `o` | Largest extent vector, including the complete terminal pool layout and per-operation extents. |
| `j` | Largest required/missing join vector and summaries on clean and failed paths. |
| `d` | Complete operation deadlines, including start and all applicable phase/report limits. |
| Original/object maxima | Exact argv/env/frame/predicate/inventory/summary lengths, wrapper headers, fragment counts and bounded parser/scan memory. |

The pool layout has one extent per reserved terminal slot.
Therefore `o >= N_total` wherever that unfragmented type-6 layout uses the shared maximum.
This exposes a size dependency: `o` can make K4/K13/K18 larger, increasing slot bytes.
Solve the coupled count/layout constraints before accepting record sizes and physical bytes.
Any fragmentation must follow the existing finite manifest format and add its own objects and observations.
Do not silently replace a required full layout with a truncated vector.

Useful exact size checks are `L6 = 772`, `L7 = 856 + 168u` and `L20 = 632` bytes.
K4 costs `396 + 176z + 184o + 80j` bytes.
K28 costs `828 + 80j` bytes.
All other `Lk` follow the catalogue's 384-byte frame plus ordered payload.
`S = max Lk` over permitted terminal kinds. No 4096-byte default follows.

### Reserve every lane and attachment

| Lane | Rows that its path maximum must include |
|---|---|
| Bootstrap | K1, `p` K2, K3, `b` K4 and final K20. Include a possible K29 and partial preparation. |
| Owner history | K5/K20, readiness and process rows, start and ordinary operation rows, all ticks and their sleep/phase reports. |
| Owner tail | First-failure/control records from the closing transition, stop/cancellation, active-operation remainder, containment, original-owner collection, worker reap and handoff with carriers. |
| Successor | K25/K20/K5/K20 before delayed observations or fences. Include the original-holder evidence attachments, bounded scan facts and only never-fenced collection items. |
| Caller final | Normal path: K25/K20/K27/K20/K28. Recovery path: K27/K20/K28. Include its possible K29. |

Moving into the owner tail is irreversible.
The event that closes eligibility belongs to that tail, including failure-time refusal/control evidence.
Before that transition, the tail reserve must already exist.
No successor or caller-final capacity belongs to the original owner.

Let `R_lane` be the greatest attempted-row count in that lane over reachable complete paths.
Reserve an even `N_lane >= 2 * R_lane` and start every lane at an odd global index.
This covers the largest parity skip before each row and a final unused parity slot.
The normal final path needs five even records: ten slots before its possible failure summary.
Including that summary gives a conservative twelve-slot final lane.
The shorter recovery final sequence cannot reduce this shared reservation.

For every reserved slot `i`, reserve its entire attachment-role set `A_i` and encoded byte sum `B_i`.
This includes parity-skipped, failed, empty and uncertain slots.
Failed-owner range burning retains those charges across both owner ranges.
An attachment cannot move to another slot after a crash.
Where a slot can serve several kinds, its layout must support every permitted role for that slot.

The existing formulas then become:

```text
N_total = sum_lane N_lane
T_data = S*N_total + sum_all_slots B_i + B_boot
O_terminal = N_total + sum_all_slots A_i + O_boot
T_phys = T_data + E_round + M_lock + M_dirs + sum M_objects + M_updates + M_backing
```

The lock and directory tree have physical costs outside the data-object count.
All wrappers, reference objects and original prefixes count in their owning layout once.
The profile must solve the layout's own object/reference dependencies without cycles or unbounded fragmentation.
No metadata, rounding, snapshot/copy-on-write or backing term is a guessed zero.

Pool preparation introduces another dependency: more reserved slots and attachments increase `O_prepare`, which can require more K4 batches and bootstrap slots.
Therefore `b`, `N_total`, attachment layouts and preparation observations require a finite simultaneous solution.
The inequalities above are constraints on that solution, not a one-pass sizing algorithm.
The implementation must present a finite candidate and check every inequality against that same candidate.
Increasing a vector or lane after checking invalidates the calculation.
No finite solution is established while preparation costs and object roles remain missing.

For ordinary capacity, sum each assigned start/scenario contribution plus each charged tick's full contribution.
For collection capacity, reserve each immutable plan item's full contribution once.
Withhold an uncertain fenced item's allowance without claiming a known charge.
Attempt contributions include directory metadata, K14/K15, compatibility objects, raw output,
artifacts, partials and every simultaneous temporary object.
References in terminal records do not charge those objects again.

Each raw attempt requires the proposed `Lout + Lerr + 1 + Q` retention contribution.
Collector buffers and bootstrap memory remain separate.
`Q` is an unknown host-dependent queued-byte bound, not zero.
The dependency lifetime proof must include retained wire and selected frames, crop,
codec capacity, old/new resize frames, OCR copies and input-confirmation processing.
No returned image count bounds those internal costs.

### Fence width and frontier

Let `W` be a positive ordinary fence width, distinct from an operation's elapsed allowance.
Let `a_o` bound assigned ordinary attempts on a path and `c` bound collection-plan items.
A clean ordinary path uses `ceil(a_o/W)` fences.
A failing path can attempt an additional fence without assigning its first member.
Thus `f <= ceil(a_o/W) + 1` is a conservative path envelope.
Collection uses width one and `f_c <= c`, across original owner and successor together.

The highest possible reserved frontier is bounded by `W*f + f_c`, with checked integer arithmetic.
Unused or uncertain ordinary suffix members burn without fabricated operation charges.
Every collection fence binds its single plan index before any uncertain execution.
A failed collection fence blocks recovery when the unique frontier cannot be established.

Width one minimises ordinal uncertainty but requires a fence at each assignment.
A wider fence reduces renewal frequency while increasing the uncertain burned suffix and scan/layout obligations.
Neither removes the worst-case fence write from a renewal commitment.
Choose `W` only after its renewal path fits the two-second commitment ceiling and its full capacity/ordinal arithmetic fits.
The qualification study's width eight is not evidence for that choice.
No width can compensate for a required publication whose latency remains unbounded.

## Remaining-tail calculation

The immutable state table must expand the product of workload position and protocol state.
It includes poll indices, active family/phase, worker phase, input-held state, collection index,
writer lane/cursor/parity, fence remainder and publication cut.
Replace continuous observation values with the finite relevant success/failure/unknown classes.
Keep actual evidence and exact timestamps in records.

For resource vector `c(e)` on transition `e: s -> s'`, define:

```text
Tail(terminal) = zero additional work
Tail(s) = componentwise maximum over permitted e of [c(e) + Tail(s')]
available(s) >= c(e) + Tail(s')
```

The vector separates slots, attachment bytes, data objects and qualified metadata by class and lane.
It also tracks irreversible operation allowances and relevant live-memory peaks.
For live memory, use allocation/release transitions and the maximum simultaneous capacities.
Do not sum all released scratch as retained bytes or refund retained storage.
Enumerated loops and one-use roles make the path expansion finite only when every input bound exists.

| State family | Required remaining alternatives |
|---|---|
| Partial bootstrap | Retained objects, final setup carrier where possible and at most one summary. No owner readiness or bootstrap restart. |
| Ready, before start | One start or its refusal/failure, dormant worker evidence and applicable exact-identity collection/tail. |
| Active sleep or pending request | Complete sleep or failure, refusal/cancellation, stop and collection. No capture charge before assignment. |
| Fenced, before assignment | Fence outcome/fallback, possible full range burn, failure/containment and caller tail. |
| Charged, before complete commitment | Full operation charge, real directory/record prefixes, both predecessor-carrier opportunities and no replay. |
| Producer, validator or delivery active | All remaining progress/result/ack/disposition/carrier/completion rows, or each permitted partial failure cut. |
| Pointer down or post-down sleep | Both distinct signal cases retain possible held input, no corrective release, untouched collection and containment. |
| Stop or owner collection | Pending cancellations, original charged tick drain, ack/reap/carriers, every still-applicable collection item and handoff. |
| Failed owner | Holder outcomes, original-lock/frontier scan, entry records and never-fenced collection, or unavailable entry with no substituted writer. |
| Caller final | The prescribed transfer sequence, attachments, possible single summary and final-return unknown. Caller loss has no successor. |

Each row is an expansion requirement, not a complete instantiated type-8 table.
Exact caller operations, message protocols and object layouts remain absent.
Those missing inputs prevent numerical table entries and profile adoption.
The table above specifies where each missing contribution belongs without claiming an executable state enumeration.

## Exact inputs still required

| Missing input | Required return and owner |
|---|---|
| Migrated scenario and confirmations | Exact operation sites, branch/loop grouping, requests, predicates and original-sharing joins. K126 retains reconciliation with k89/k81/k76/k67/k62. |
| Finite caller and collection | Exact C04 commands, inventories, archive applicability, failure interpolation facts, plan indices, local bounds and post-failure submission policy. K126 retains k57's contract. |
| Start | Actual queue/provision/boot/response stage subjects and finite `U_start`, returned identity and interrupted-start containment evidence. K125 scopes mechanisms and K126 fits the family. |
| Messages and local processes | Actual worker/collector/progress transitions, child and holder overlaps, bounded transcript/parser/hash/scan/archive costs. These determine `w,h,q,g,t` and local time. |
| Dependency | Exact contract/unit versions, build, encoding/OCR/environment, input-update and OCR-cycle bounds, allocation/lifetime guards and full control results. K125 scopes this external work. |
| Native containment | Intermediary install-map floor, actual producer exec-setter floor, loader/map/native/service coverage and process membership. No no-op producer substitutes for the real floor. |
| Raw collection | Qualified accepted-byte observation, queue `Q`, collector bootstrap/buffers, descriptor lifetime and retention across loss. |
| Storage | Exact backing/lock identities, object granularity, metadata/update/copy-on-write costs, protected bytes/objects and required flush/visibility latency and loss semantics. |
| Record layout | Concrete fragments, registries, per-slot role sets, object graphs, vector maxima, lane path enumeration and bounded recovery scan. K126 completes numerical fit. |

The future [raw controls](KEEPALIVE-RAW-CONTROLS.md) and
[recovery controls](KEEPALIVE-RECOVERY-CONTROLS.md) retain their approved seams and separate finite manifests.
Count their synthetic setup, sentinels, collection, expected bytes and supervision separately from production E/A workloads.
The separately audited R3/R5 collector copies remain required.
Eight named process roles can overlap before validators or utilities are counted.
Neither that count nor the six-process mechanism envelope bounds the complete coordinator suite.
Results follow implementation and precede downstream consumption.

## Alternatives, limits and review

Multiplying successful receipts by one generic cost loses failures, embedded carriers and empty consumed slots.
Selecting numerical capacities now would require invented caller, native and storage inputs.
The selected path method preserves those unknowns and the existing contracts.
Its cost is an explicit manifest and finite state expansion before startup.
Actual implementations and qualified evidence can reduce conservative envelopes only with a complete correspondence argument.

The existing helper/adapter and audited-copy seams remain unchanged.
No new production injection interface or native experiment is introduced.
Whole-design review still follows the complete profile, then planning, implementation and earned review integrations.
All k89/k81/k76/k67/k62/k57/k54 duties remain.

First failure stays sticky. Both held-pointer cases prohibit corrective release.
Private roots, original/partial retention, snapshot-tree and empty-AXValue limits remain.
OCR substring and held-frame limits remain.
Historical failures, closed slots and caps remain unchanged.
No VM, candidate, freeze, acceptance, cap expansion or release follows.

Scoped review must challenge the failure-prefix time bound, carrier fallbacks before assignment,
lane maxima, self-referential layout sizes and the shared phase ceilings.
It must check that unknown inputs remain prerequisites rather than implied zero costs.
An arithmetic or browser check supplies no useful-fit or mechanism result.

## Verification evidence

The [check receipt](ordering-keepalive-accounting/verification.json) records the inspected input hashes and each result.
Catalogue arithmetic, manifest references and the touched prose checks pass.
Broken coefficient and parity expectations fail their controls.
The first arithmetic probe failed because its expression reader did not parse implicit multiplication such as `4n`.
The repaired probe restarted before producing the recorded results.

`mise exec -- task check:docs` returns task status 201 and checker status 1.
It reports only the existing `context-predicate.txt` and `context-qualify-filter.sh`
targets in `context-initial-inputs/CONTEXT-PLAN.md`. Their historical repair remains outside this leaf.

The local browser renders the accounting diagram and its capacity/unavailable endpoint at port 8842.
Its deep link, topic outline and current/updated markers identify the intended view.
The viewer uses its existing Mermaid 12.0.0 renderer. Mobile and dark appearance were not checked.
Port 8814 was occupied, so this session used a separate loopback listener without stopping it.

Tier 2 graph discovery located `start_vm` and its direct helper edges.
The trace also returned documentary and stub edges, which provide no executable evidence.
Coverage generation `2026-11-01T04:10:00Z` reported partial common/scenario/desktop shell coverage.
Direct reads covered the relevant ranges and the reviewed workload documents.
Later coverage reported changed document metadata and partial Mermaid parsing.
The edited source and browser rendering, rather than that index, establish the document changes.

These checks establish document delivery and bounded arithmetic consistency only.
They establish no coordinator result, useful resource fit or native guarantee.
