# Search serviceability subjects

**Construction design, pending implementation and native acceptance.** This is
the instrument and subject definition for the finalized
[in-process allocation](../specs/workspace-search.md#in-process-observation-contract).
The [serviceability view](../design/architecture/index.html#diagram-search-serviceability)
shows its evidence paths. No instrument or runtime result is delivered here.
The [feasibility report](search-native-resources.md) supplies the source/SDK
provenance; the [selected observation boundaries](../specs/workspace-search.md#observation-boundary-decision-questions)
govern every verdict below. Platform-internal acquisitions, peaks, lifetimes,
asynchronous work and swallowed errors remain unproved.

## Subjects and attribution

Use the existing three seams: controlled native dependencies in the **actual
workspace provider binary**, an independently built GraphQL client, and the
normally launched Developer ID signed hardened Koine in an isolated TestAnyware
macOS VM. The native constructor enables controlled dependencies privately;
add no production GraphQL field or framework ABI for instrumentation. The real
subject uses the selected native calls and production owner, listener and store.
Do not replace them with a mock accumulator or a headless service host.

Freeze a per-case manifest before execution. It names the OS/build/filesystem,
Koine binary/provider/framework/catalogue/signature/entitlement digests, NIO and
GRDB revisions, hook patch, fixture paths/identities, client operations, adapter
schedule, instrumentation capacity and control expectations. Digest all inputs
before and after; any changed subject invalidates its reading. Preserve actual
inherited L and the limit reads during execution, never shell/setrlimit overrides.
Export events after the finite observation interval; one run has one writer.
Keep secret credentials out of events and published records.

Every event identifies process incarnation and run, monotone timestamp, thread,
producer sequence, operation/span/parent and event kind. Search events add
job/root/cohort/attempt and descriptor-owner identity; listener events add
server-channel/read-generation and accepted-channel identity; store/action
events add the GraphQL request/alias and operation identity. Worker migration
keeps explicit span identities; thread-local context alone is insufficient.
Attach a child channel to the client nonce only when HTTP decoding establishes
it. Before that, an accept error belongs to the listener, not to a guessed client.
External client connect/send/response spans use their own clocks and nonces;
correlate with server receipt/response, not timestamps alone.

## Event inventory and bounded sink

Allocate 1,048,576 fixed 128-byte event slots (128 MiB), fixed producer counters
and manifest storage **before** the subject. This is disclosed test overhead,
separate from unchanged production search accounts. No growing strings, file
opens, flushes or allocation-heavy logging occur in a hook. Store bounded
numeric/value classifications; full paths and expected values live in the
frozen manifest or public response capture. Append reserves a slot atomically,
publishes a complete record, and never waits for the exporter or overwrites old
events. Exhaustion sets a sticky loss flag; the run cannot pass. A larger sink
is not a production-account increase or evidence that instrumentation is free.
Split independently bounded scenarios rather than silently dropping events.

| Observable owner | Required events and outcomes |
| --- | --- |
| Process-lifetime runtime | Actual L/read failure/infinity; C, S and Q before/after atomic worker+credit try-admit; refusal cause; cohort membership; latch cause; freeze/finalization ordering ticket; worker cleanup and reservation release. Record occupancy separately from reserved Q. |
| Every explicit search acquisition | Credit/attempt reservation before syscall; openat/open/dup/fcntl-dup variant, start/return, result fd or captured errno; install or failed-attempt release. Inventory the final implementation's actual explicit variants before the run. An unhooked variant invalidates completeness. No trace claim covers arbitrary platform opens. |
| Directory ownership | fdopendir start/return and one-charge transfer; failed conversion leaves fd owned; readdir entry/EOF/errno with the specified errno reset; fstat/fstatat/fstatfs/fsgetpath start/return and identity/path-size verdict. Numeric fd, unique owner generation and attempt stay distinct. |
| Worker release | One close/closedir attempt and result per owner; occupancy release only on established cleanup; CF Create/Copy array/error and retained-native-object ownership/release; borrowed-element index and copied-value charge/release. Uncertain close retains Q/refusal, without another close using that fd number. |
| Native inspection | Exact entry/return of resourceValues, Bundle/identifier, all-registration CF query, preferred URL and UTType/conformance; bounded value/error classification, array count/index/iteration-complete or interrupted, candidate/target/recheck phase, policy/identity result and scratch high-water. These are envelopes, not internal FD events. |
| Error normalization and publication | Domain/code classifications and bounded underlying-error index/cycle/truncation; observed resource latch before membership release; tentative verdict, commit/discard with shared-gate ticket, frozen snapshot digest and publication error path. Do not retain localized descriptions or error trees. |
| NIO listener | Real accept attempt/result or error, upstream error kind/errno before suppression; actual selected delay/deadline; read request, existing-schedule no-op, schedule generation, cancel/reschedule cause, task fire, immediate/resumed context.read, inactive/removal and forward/suppress decision. Accepted-socket transfer/init-failure cleanup, child-channel close and request/response envelopes identify independent outcomes; wrapper/channel generations distinguish socket reuse. |
| Real grant store and actions | Transaction entry/commit/rollback and bounded SQLite primary/extended result code or thrown-error class, with operation identity; native launch/open/reveal submission/callback/wait result, resource cause when supplied, and public receipt/error. Private store/native internals stay opaque; these hooks observe outcomes, not every file open. |

Each producer advances its attempted-event sequence **before** writing a slot.
End counters, committed-slot flags, sequences and span pairing independently
check delivery. Retain fixed aggregate site counters independent of the detailed
sink; match acquisition/transfer/close, normalization, commit and NIO branches
against those counters. A sink that loses an entire pair must still fail.
Source-site inventory and known scripted branch expectations cover a hook
omitted before it ever increments a counter; a self-consistent logger alone
cannot prove hook coverage. Exclude neither logging stderr nor loss flags.

Close the finite measurement window by disabling new scenario production and
taking a consistent sink frontier. A still-blocked span is valid only if the
manifest declared it, its start/charge/worker remain visible and its frozen
snapshot is recorded. Mark it OPEN_AT_CUT, not a completed pair. A finite return
continuation starts at the retained frontier and pairs that same attempt;
undeclared missing returns/releases, half-written slots, unmatched schedule
generations, missing producers or counter differences invalidate the subject.
Never await an intentionally indefinite span to export the finite record.
FD reuse is paired by owner generation, never by number alone; ambiguous closes
retain their owner and permit no later search reuse/admission.

## Passive listener hooks and real exhaustion control

The inspected dependency is swift-nio 2.103.0, revision
21de5f08c1a166a6dd293d0e587ad977bf8dac5d. In its async
[Bootstrap](https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOPosix/Bootstrap.swift),
the server initializer precedes AcceptBackOffHandler; the child initializer
passed to bind is **not** that upstream server initializer. Put a passive
error-forwarding observer in the server initializer. Add passive statements at
the original [AcceptBackoffHandler](https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOCore/ChannelHandlers.swift)
branches, and the actual server socket accept/accepted-socket transfer or
initialization-failure cleanup sites; use that patched dependency in the normally
signed test app. The inspected server
[socket-channel path](https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOPosix/SocketChannel.swift)
leaves EMFILE/ENFILE read errors recoverable, allowing the pipeline's backoff
observer to see them. Record socket outcome before the handler; a fresh client
timeout alone does not establish an accept resource error.
Preserve the handler class, placement, default one-second provider, selected
deadline, forwarding flag false and every scheduling/read path. Do not replace
it with a nominally similar handler or infer a scheduled read from an error.

Source diff must consist of bounded observation calls and their test-only sink
wiring. Run original versus hooks-disabled versus hooks-enabled handler through
the same controlled event-loop schedule: IOError, repeated IOError while a read
is pending, non-IOError, read before/after deadline, inactive and removal. Compare
forwarded errors, task deadlines/cancellations and read calls item by item;
handler removal can directly issue a read, whereas inactive cancels without one.
Record no-schedule/forwarding branches too. Source comparison plus these controls
supports behavioral equivalence; it proves neither identical timing nor zero
resource overhead in a native app. Native on/off references retain that limit.

| Detection control | Construction and required rejection |
| --- | --- |
| Owned transient invisible to polls | At the real charged-open seam, open/close an allowed fixture between two commanded occupancy samples, both with identical occupancy. Require distinct acquisition/close records and one owner generation. Remove either record or the whole pair: counters/expected branch manifest must reject. Polls alone must fail the discriminator. |
| FD-number reuse | Close one owner, force the controlled allocator to return that number to another attempt, then release a delayed return. One owner cannot close the other's descriptor. Numeric-only pairing and a duplicated close must fail. A real reuse fixture separately observes actual fd reuse when obtained; injection is not proof of native reuse timing. |
| Sink/hook loss | Drop an owned event, a full pair, an accept error, a schedule or resume event; omit an entire hook site; overflow the sink and leave an uncommitted slot. Each variant must reject through the independent counters/known control or loss/pairing rules. Do not infer completeness merely from successful responses. |
| Synthetic NIO suppression | Fire EMFILE/ENFILE at the real server pipeline upstream of the unchanged handler, request a read, and drive the controlled event loop. Upstream records the error; downstream receives no IOError; actual delay/schedule/resume remain visible. Downstream-only/error-only/backoff-inference instruments must fail. This proves hook placement/logic, not socket exhaustion. |
| Real normally launched accept exhaustion | In a separate diagnostic control case, start Koine normally, establish a control connection, then use an in-host test-demand owner to open /dev/null until a checked EMFILE. Preallocate at most 65,536 fd slots; require actual finite inherited L within that constructible bound and no table-altering limit call. A fresh external connection triggers the real accept path while the slots remain held. Release them through the existing control connection or a prearmed finite cleanup barrier, then record actual scheduled/resumed reads and eventual client result. The resource error/backoff must still reject the serviceability verdict. No undocumented ability to trigger system-wide ENFILE is assumed. |

The diagnostic filler is outside search, labelled TEST_DEMAND, with separate
fixed accounting and exactly-once cleanup; it never borrows Q or legitimizes a
third search temporary. It deliberately breaks serviceability to validate its
observer. Inherited infinity, excessive L, a failed fill, no real accept error,
or inability to correlate the socket path leaves this **native detection
control pending/inconclusive**, never replaced by synthetic success. Choose a
VM whose normal launch actually provides the finite subject, recording that
fact without altering its launch or limit. Real ENFILE remains an observed or
controlled-error case; do not exhaust the VM's system-wide table to fabricate it.

## Actual-provider normalization and ownership subjects

Each controlled schedule runs through an independently built real provider and
client, with the public fields/coverage/aliased error paths asserted together.
The private ledger additionally asserts charges and ordering. Keep the existing
[canonical call subjects](../specs/workspace-search.md#canonical-path-acceptance-subjects)
and repeated-walk counters; mocked canonical paths cannot pass native size tests.

| Subject | Stimulus, falsifier and control |
| --- | --- |
| Registration branches | Supply exact OSStatus/−10814 with complete bounded causes, the same code in another domain, nil/nil, empty/no-error, array/error, matching native identity, fully checked nonmatching identities and stale known-absent targets. Check INSTALLED/UNREGISTERED only in the specified branches. Preferred nil supplies no health; matching preferred identity conflicts with a tentative negative. Blocked/changed/unreadable preferred URL prevents it. Mutate normalization to accept empty/foreign-domain: the independent client must reject its negative. |
| Identifier/native facts | Nil/blank/overlong identifier despite later successful stat/access stays null/UNKNOWN with affecting coverage. Missing booleans/type, contradictory package/alias facts and failed UTType construction cannot become false/suffix inference. Errorful input followed by a positive element cannot rescue an already uncertain observation. A deliberate incorrect known witness fails even if every ledger event pairs. |
| Borrowed-array/copy accounting | The returned Create/Copy array owns borrowed elements. Exercise zero/one/many elements, malformed CF type, remote/non-file/query/fragment/NUL URLs, 8,192/8,193 text-byte paths and 1,024/1,025-byte strings. Require fixed retained state, bounded conversion before copying, no eager bridge/set/history, one owner release, no borrowed-element release and scratch refusal before storage. Interrupt a finite long array at the wait: UNKNOWN/remainder, never a negative. This measures copied values, not platform array RSS. |
| Bounded error causes | Exercise exactly sixteen objects, a seventeenth, cycles, wide/malformed cause arrays and overlong domains. Classification incompleteness refuses negatives; recognized POSIX EMFILE/ENFILE reached before the stop latches even when another branch is incomplete. Foreign-domain numeric errno does not latch. Hide the resource input deliberately: the known control must detect the lost refusal. Invisible internal failure with identical answers is explicitly indistinguishable, never a passing health test. |
| Serial A/B choreography | Hold sixteen root streams per job and charge both temporary slots for candidate walk. Capture candidate values and close A/B before registration/preferred walks, releasing each target before the next. Reacquire original candidate before commit. Attempt pinned-candidate+target, third temporary and unused-root borrowing: refuse before an extra syscall/storage. Mutate candidate identity/path/association between walks: no stale finalized installation; prefix/parent change versus target-only change uses the existing coverage scope rules. |
| Shared gate races | Pause before admission/finalization, then order freeze first and commit first separately, using serialization tickets rather than timestamps. Freeze first permits no newly admitted call/commit; commit first preserves that candidate/coverage/rank/root membership atomically. For an already admitted attempt, return late success, failed fdopendir and late EMFILE after publication. Cleanup is worker-only; error normalization/latch precedes membership/Q release; serialized response bytes/digest remain unchanged. Suppress the late latch or commit after freeze: the independent controls must fail. |
| Uncertain close | Inject close/closedir error with ambiguous ownership. Require one close attempt, retained Q/refusal/worker across provider stop/start, no fd-number retry, no replacement and restart guidance. Do not force a real double-close to claim kernel health. A fresh normal process establishes a new owner and rereads L; old ownership is not represented as successfully cleaned. |

## Limits and combined refusal subjects

Inject limit values only through the private read seam; these are admission
tests, **not** normally launched native serviceability proof. The native subjects
record the actual inherited limit without changing it. Maximum roots mean
Q = 18; smaller-root jobs use their actual Q. Atomically admit worker and Q or
neither, across distinct provider instances/aliases sharing the same owner.

| Read / schedule | Expected observation and discriminator |
| --- | --- |
| 128 | S = 0; no admitted worker/Q or filesystem/opaque call; CAPACITY_LIMIT per root. |
| 160 | S = 32; one Q = 18 fits, second is descriptor-refused despite a free worker. Also admit four Q = 3 jobs to separate credits from worker count. |
| 200 and 256 | S = 72; four Q = 18 fit, fifth is worker-refused. Neither case demonstrates that R reserves OS capacity. |
| Infinite and initial unknown | Infinity uses 72 without sentinel arithmetic. Unknown initial read yields INSPECTION_FAILED/UNKNOWN requested-root remainders before any worker/Q/native admission. |
| C distinct from occupancy | Four admitted jobs reserve C = 72 while only eight owned fds are occupied. Refresh 200→160: S′ = 32 below C latches lower-limit refusal even though occupancy fits. Raise to 256: it remains latched; no new job/call joins. Suppressing the latch or comparing occupancy must fail. |
| Lower limit still fits | C = 18, refresh 256→160: S′ = 32 still fits. Existing work continues; another Q = 18 cannot fit, Q = 3 may fit with a worker. Lowering 256→200 leaves S = 72 and creates no latch. |
| Unknown refresh / finite cleanup | Unknown refresh latches INSPECTION_FAILED; later known/high values do not erase it. Release finite calls, close once and release every surviving Q. Only after full cohort cleanup may a fresh read admit work. Frozen bytes and earlier finalized candidates stay unchanged. |
| Indefinite plus resource failure | Admit four jobs: A is held indefinitely inside a controlled listing/metadata/canonical adapter span; B later reports EMFILE, repeat with ENFILE. C/D unwind finitely. After B/C/D free workers, A retains Q/worker/objects/scratch and the latch. New valid searches return disabled CAPACITY_LIMIT guidance, no native calls/queue/retry/worker replacement. Repeat provider stop/start and aliases: same owner/refusal. End by terminating the VM's Koine process, normal relaunch and successful admission only if current L/resources allow. Indefinite controls are adapter holds, not a claim to have made a public API block forever. |

Record each surviving job/root's transition. Resource-observing scheduled work
uses INSPECTION_FAILED; lower-limit scheduled work uses CAPACITY_LIMIT; new jobs
never join a latched cohort. Prior frozen results retain their original outcome,
including TIME_LIMIT, rather than being rewritten to the later reason. Invalid
input/authority still wins before resource admission. Repeat the indefinite case
with finite release for exactly-once cleanup, no late publication and eventual
fresh admission; the permanent ambiguous-close case cannot take that exit.

## Normally launched independent serviceability

Use a fresh isolated VM clone/process per case, normally launching the sealed
test app with the production identity, hardened runtime and empty entitlements.
No helper, attach/injection, get-task-allow, diagnostic entitlement or special
shell launch is selected. Stage fixtures/accounts/grants and all observers
before measuring; keep authorization and expected effects unchanged. Freeze the
client operation list, including four separately identified search requests,
fresh-connection queries and manager/store/action operations. Existing consent
setup remains explicit and no new search consent is given.

The maximum-root native saturation case needs actual S = 72 (finite L at least
200, or infinity) and four successful reservations. A normally lower limit is
not raised: preserve its native refusal evidence and leave that maximum-root
case pending, or run four smaller-Q jobs as a separately labelled subject when
they fit. Smaller demand cannot substitute for the maximum-root subject.

Run two complementary search variants, each paired with a no-search reference
under the same launch/fixture/client demand and hook configuration:

1. **Controlled saturation with real calls.** Four maximum-root jobs reach
   barriers with root streams/nonempty FIFO retained; overlap blocked listing,
   canonical and metadata return paths in separate cases. Adapter barriers hold
   owned state or a returned native result beyond freeze and keep four worker/Q
   reservations observable. Native-call entry/return events exclude barrier time;
   a return hold is not described as a blocked platform call. Inject the combined
   indefinite/resource case separately. These controlled subjects establish
   scheduling, cleanup and serviceability under declared retained demand.
2. **Unheld native workload.** Real wide/deep fixtures and application discovery
   execute the selected public calls without adapter answers, barriers, fillers
   or fault injection. Burst four jobs from independent clients, record actual
   worker/span overlap and repeat the finite manifest's rounds. Do not claim
   four simultaneous opaque calls if the envelopes do not show them. This
   supplies actual-call and independent-outcome evidence for the observed load;
   controlled saturation cannot replace it or establish arbitrary future load.

During the retained/observed intervals, fresh independent TCP connections issue
an authenticated core query and a workspace action request. A manager creates
a disposable grant, verifies it through a fresh client's read, revokes it and
verifies denial; read back grant state, then confirm persistence after normal
relaunch. Real SQLite commit/rollback codes are observed, not replaced by an
in-memory store. Authorized actions exercise constrained application launch,
default/named document open and Finder reveal, each under workspace:control AND
desktop:control. Existing native witnesses check process incarnation/activation,
document delivery and Finder selection, respectively; a receipt alone fails a
known wrong effect. Record request-to-completion latency without a new target;
retain the existing action waits and core deadline classifications.

The independent coordinator captures connect failures, responses, original
GraphQL errors and witness outcomes even when no server request arrived.
Listener errors cannot be assigned to a particular search thread; correlate
their window with all admitted search/native spans and test-demand records.
The primary search-run rule is conservative: **any independent resource failure
or accept backoff fails that serviceability case, even after successful replies**.
Matched controls help diagnose cause, never waive that failure. A failed or
incomplete no-search reference, unclassified store/action resource error,
missing client attempt or ambiguous attribution cannot produce a pass. Ordinary
latency variation alone has no invented fail threshold. System-wide ENFILE,
unbounded unrelated demand and unobserved platform behavior remain limits.

Compare ordinary signed host, hooks-disabled test build and hooks-enabled test
build under the matched finite manifest. Confirm schema/catalogue/authority,
native selected paths, listener forwarding/read behavior and independent
outcomes are equivalent; disclose fixed sink/observation overhead. Controlled
NIO/source equivalence plus this comparison permits empirical evidence about
the instrumented subject, not identical scheduling or all-host resource safety.
If instrumentation alters the behavior being measured, repair the instrument;
do not pass its replacement behavior. Native backoff detection must also clear
the separate real exhaustion control above.

## Native facts, policy and compatibility remain mandatory

Use registered real Safari/Finder with independently witnessed canonical
paths/identifiers and constrained launch, a present genuinely unregistered
fixture whose actual CF error domain/code is captured, and two native copies
sharing an identifier. Test nonmatching registration arrays and separate
preferred identities where constructible. Wrong not-found normalization,
incorrect known witnesses or UNKNOWN for every launcher fails. Fixture
registration/setup writes occur before measurement; search performs none.

First consume the [path-design dependencies](../specs/workspace-search.md#path-design-dependencies)
and their producer/review outcomes. The current selected calls are not reconciled
with pre-open witness/replay phases or long-path classification; long-result
actions also need their launch/open design/review chain. Queue/size reachability cannot be inferred from
fixture creation or capacity arithmetic. Run the settled resource/package/hidden/alias/type/Bundle/registration/preferred
calls and serial walks against protected application/Library links, supported
long/canonical/native-size fixtures and actual home/default roots. Independent
UI and hydration observers witness no consent dialog/content request. Preserve
the fsgetpath and repeated-walk subjects, without shorter-path/canonical spelling
fallback. Previously measured metadata calls do not accept these new combinations.
The separately live protected-home decision must consume per-witness queue,
entry, depth, value and deadline omissions; no arbitrary sample is accepted.

Keep independently retained action-only host/framework/workspace 1.0.0 binaries,
SDL and exact profiles distinct from search 1.1.0/upgraded-host subjects and
newer update fixtures. Run the
[compatibility cases](../specs/workspace-search.md#compatibility-subjects-and-diagnostic-acceptance)
with binary identities, old failure mapping, both authority/selection features
and exact candidate rows. A rebuilt old fixture, historical capture, subset
SDL or this design's checks cannot clear runtime compatibility.

## Verdict and review boundary

A case passes only for its named finite subject when applicable events are
complete, every deliberate broken control rejects, its independent/reference
outcomes meet the contract and its binary/input identities remain frozen.
Publish per-case records, controls, open-at-cut owners and limits, not totals
alone. Distinguish PASS, FAIL and INCONCLUSIVE/PENDING evidence in the report;
these are verification verdicts, not new search statuses. No verdict proves
opaque health/peaks. Detection controls deliberately cause a failing
serviceability observation; their successful detection is not a passing native
search run. All cases here remain **pending**.

Whole-resource design review must challenge passive hook equivalence/loss
detection, normally inherited real-exhaustion construction, independent outcome
attribution, bounded copied/error accounting, shared-gate late-error ordering
and restart/ambiguous-close ownership. Review the complete allocation and
canonical costs with these subjects, not just the new document. No helper,
content reader, consent, different signature, larger production account,
changed limit/domain or weakened workflow can be installed as a fallback.

## Source evidence

Tier 2 graph discovery used project
Users-antony-Development-Koine.add-plugins-for-modaliser-requirements,
generation 2026-09-29T10:36:20Z. Listener/server metadata had changed;
NativeWorkspace and checked-out dependencies were untracked by that generation;
docs were excluded. Exact present source reads supplied the affected evidence.
The graph's change detector returned getcwd errors, so its changed-file list
supplied no freshness evidence. No exhaustive graph or runtime claim is made.

[LoopbackListener](../../Sources/KoineHTTP/LoopbackListener.swift) uses async
bind; its existing private hook concerns response readiness/idle closure, not
accept/backoff. [KoineServer](../../Sources/KoineServer/KoineServer.swift) starts
providers then the listener; [SQLiteGrantStore](../../Sources/KoineSQLiteStore/SQLiteGrantStore.swift)
uses real transactions, FULL synchronization and fullfsync. Those facts support
the actual-provider, server and durable-store composition subjects; they do not
prove every store-internal open is observable. The
[present action adapter](../../Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)
has array-only registration and optional Bundle metadata; it is not the selected
search implementation. The exact checked-out NIO files above supply the passive
hook and recoverable accept-error locations; native execution remains pending.
