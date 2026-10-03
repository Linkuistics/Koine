# Search native resource feasibility

**Source/SDK analysis only; allocation design and native acceptance remain
pending.** An error-bearing registration API exists, but substituting that API
does not supply a bound or event ledger for platform-internal descriptors.
The [resource boundary comparison](../design/architecture/index.html#diagram-search-resources)
shows the in-process continuation and the unapproved helper alternative. The
[search resource contract](../specs/workspace-search.md#resource-accounting-and-scheduling)
continues to bind, including its original budgets and serviceability obligations.
No inspection route, helper, consent, signing change, smaller domain or reduced
metadata/workflow guarantee is accepted by this analysis. The subsequent
[allocation decision](../specs/workspace-search.md#native-allocation-decision)
records the operator's refusal of the helper proposal and retains the
single-process posture. This analysis has not demonstrated a normal-search
failure or established that isolation is necessary; the continuation must
settle an in-process bounded route or complete approved-posture observation.
These feasibility candidates are not an accepted runtime contract.
The [concrete in-process proposal](../specs/workspace-search.md#proposed-in-process-observation-contract)
now names native calls, owned/opaque demand, freeze/restart ownership and exact
failure discriminators. It requires two separate human decisions on reported
negative-registration semantics and controlled serviceability evidence with
incomplete opaque-event visibility. Neither change is approved or follows from
declining helpers. The original guarantees remain live; this report provides
no hidden-health proof, selected runtime route or native acceptance.

## Call health is separate from descriptor visibility

| Inspected route | Observable result | What it cannot establish |
| --- | --- | --- |
| Current action adapter's NSWorkspace per-identifier registration | Array, without an error result | Empty is not an error-observable negative registration fact. Search cannot infer UNREGISTERED from this alone. |
| Current Bundle identifier, followed on nil by stat/access of Info.plist | Optional identifier; later POSIX presence/readability checks | A readable plist after Bundle returned nil does not prove Bundle read it successfully. EMFILE can fail an earlier open while both later checks succeed. |
| LSCopyApplicationURLsForBundleIdentifier, supplying outError | Returned CFArray or retained CFError | The documented error channel improves diagnosis but does not expose internal opens, their peak demand or every swallowed internal failure. It is a candidate, not an accepted substitution. |
| Streaming listing and descriptor-derived fsgetpath | Explicit owned descriptors and POSIX return/error checks | The ledger does not cover arbitrary platform metadata internals; fsgetpath's identity/race/native-size obligations remain separate. |

The installed macOS SDK's Launch Services LSInfo.h documents that the CF query
returns URLs when found and reports kLSApplicationNotFoundErr through outError
when none is found. It marks the API deprecated in favor of NSWorkspace, with
API_TO_BE_DEPRECATED as the upper endpoint; it remains declared in this SDK.
That is a migration cost, not a reason to erase the error channel. A final
adapter must retain domain/code and bounded underlying-error classification,
rather than treating every CFError as absence. An unexpected array/error
combination or nil/nil remains uncertain.

The published [NSWorkspace API](https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:))
matches the checked-out action adapter's array-only boundary. This analysis
does not modify that adapter or claim action acceptance clears search. The final
design must decide whether a documented not-found error supports UNREGISTERED
given its resource-health evidence; it cannot assume every internal failure has
a distinct public error. Registration still needs presence/native-identity
checks and cannot nominate an admission anchor.

For identifiers, a possible replacement is an explicit bounded metadata-plist
read with checked open/read/EOF/parse results. A successful whole observation
would distinguish a missing key from a failed read. This is **an alternative
requiring design**, not approval to read arbitrary contents, follow plist links,
hydrate items or fetch localized/icon resources. Its layouts, parse accounting,
identity/prompt rules and two-temporary-credit choreography need specification.
Apple's [bundle identifier reference](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html)
identifies CFBundleIdentifier as bundle metadata; it supplies no resource bound
or prompt-free outcome for a direct reader.

No negative metadata fact may be finalized merely because a later stat/access
check succeeded. Resource errors contribute to the surviving cohort's existing
INSPECTION_FAILED refusal. Earlier finalized/frozen observations stay immutable;
uncertainty is partial coverage, not evidence that another installation is suitable.

## Listener error and backoff observation point

The current listener uses async ServerBootstrap bind. In the checked-out NIO
implementation, serverChannelInitializer runs before AcceptBackoffHandler is
appended with shouldForwardIOErrorCaught false. Its default provider returns
one second, sets a next-read deadline and can schedule a later read. A downstream
handler or eventual successful independent client reply can miss the error/pause.

A **candidate observation point** is a passive server-channel handler at that
upstream initializer position: record the IOError, then forward it unchanged.
For backoff selection/scheduling/resumption, an instrumented test build of the
same handler or a proved equivalent event hook is needed. Inferring one second
from an error does not measure scheduled/read behavior. Preserve the production
pipeline's order, delay and suppression. Synthetic pipeline injection validates
observation order; real accept exhaustion validates the socket path. Neither
replaces the other. No production listener change is delivered here.

The inspected [async bootstrap](https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOPosix/Bootstrap.swift)
and [backoff handler](https://github.com/apple/swift-nio/blob/2.103.0/Sources/NIOCore/ChannelHandlers.swift)
explain the call path. Acceptance must identify its actual dependency revision
and build. This point observes listener failure, not opaque metadata opens.

## Trace-tool evidence and limitations

The available /usr/bin/ktrace manual describes raw trace-file capture and
structured event output. It also says release kernels exclude events for
processes that cannot be attached to. No signed hardened Koine capture ran here.
Root observer execution alone does not establish target visibility, complete
syscall arguments or missing-event detection under the approved posture.
No get-task-allow, injection, SIP change, diagnostic entitlement, alternate
signature or special host launch is authorized.

Apple's [fs_usage guide](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/FileSystem/Articles/FileSystemCalls.html)
describes a root-operated event-based filesystem observer. This is useful
supplementary evidence, unlike occupancy polling, but not a complete descriptor
allocation contract. The inspected
[fs_usage source](https://github.com/apple-oss-distributions/system_cmds/blob/408bba7453608006b89772db185defbac8fe2fd0/fs_usage/fs_usage.c)
formats recognized syscall families and pairs entries/exits by thread/syscall.
It warns on buffer overrun and clears correlation state. Some formatted calls
expose useful descriptor/error numbers; output is not a general machine ledger
of all allocation results or imported descriptors. Ignoring stderr loses an
explicit failure signal. A completed capture alone proves no completeness.

This does **not** prove a complete kernel observer impossible. It establishes
that formatted fs_usage and the local ktrace manual are insufficient evidence
for the required instrument. A raw decoder needs every applicable acquisition/
release family: open variants, dup/fcntl, sockets/accept/socketpair/pipes,
descriptor imports and implicit replacement/close. Establish actual return/errno
semantics, process/thread attribution, FD reuse and trace loss. Unmatched spans,
excluded target events, dropped buffers or an undecoded allocation family
invalidate the subject. Table snapshots cannot repair lost transient history.

## Allocation alternatives

The isolation rationale is a possible shared-table failure. Apple's
[resource-limit manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/getrlimit.2.html)
defines RLIMIT_NOFILE per process; its
[connection-accept manual](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/accept.2.html)
documents EMFILE when that table is full and ENFILE for system-wide exhaustion.
Opaque metadata opens inside Koine could therefore interfere with unrelated
client connections. A separate process could contain the per-process demand,
while adding transport, signing and lifecycle costs and still requiring
system-wide and metadata-health evidence. These platform failure semantics
explain the proposal; they do not demonstrate a normal-search failure or prove
that Koine needs a separate process. The operator declined helper design.

| Alternative | Benefit | Load-bearing unresolved obligation |
| --- | --- | --- |
| Opaque calls in Koine with complete raw kernel events | Retains current single-process native API composition | Prove normally signed target visibility and complete allocation/lifetime/error decoding, including hidden opens and accept pause. This analysis does not do so. |
| Direct owned calls with checked metadata outcomes | Exposes opens/errors at the private adapter using existing credits and failure seam | Preserve actual application/type/registration semantics and prompt policy within existing accounts. Direct plist reading supplies no registration query. Dropping INSTALLED or all launch choices changes the workflow. |
| Private signed support process, outside approved scope | Could separate its descriptor table from Koine's | Packaging was declined; necessity is unestablished. Any separately authorized reconsideration still owes IPC/trust, TCC identity, host transient opens, limits, system-wide demand, reply health/negative facts and blocked-child ownership. |

Continue inside the approved process posture. Direct owned calls have less
composition machinery where they preserve required metadata, but do not by
themselves supply registration/type semantics. A complete observer remains an
alternative if its visibility and error/lifetime decoding can be established
under unchanged signing and normal launch. The helper is a comparison outside
approved scope; an observation gap does not prove that it is needed. These
source/SDK alternatives select no runtime mechanism or weaker guarantee.

A socketpair transiently creates **two** host descriptors even if one endpoint
closes immediately after spawn. Holding one for a whole job leaves only one
temporary credit for a checked parent/child walk. Two pipes need four transient
endpoints. Neither may borrow a root credit or increase Q. Short support
processes per inspection avoid some overlap but add repeated spawn costs to
the existing three-second wait. No useful-coverage verdict follows.

Apple's [posix_spawn wrapper](https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/libsyscall/wrappers/spawn/posix_spawn.c)
shows a direct syscall/error route in the inspected source. It is a feasibility
lead, not proof that loader/framework/support work creates no additional
host/system demand on the running OS. An infinite inherited limit is not a
finite child-allocation bound. Resource-limiter, signing or consent changes
require decisions before use. Isolation does not cure silent nil/empty facts or
turn system-wide ENFILE into a host-local property.

## Acceptance obligations carried forward

The allocation comparison names concrete falsifiers for the declined helper
alternative: apparently negative metadata after a swallowed child resource
failure; a persistent host IPC endpoint overlapping a two-descriptor walk;
bootstrap allocations before a proposed finite child limit is enforced; and
an indefinite child surviving host exit while a replacement host attempts
admission. A successful reply/exit, a 32-descriptor child proposal or parent
exit cannot pass those controls. Helper-specific controls apply only if that
direction is separately authorized; they do not require a helper in the current
single-process continuation. Swallowed-error negative facts still require
in-process failure discriminators. The complete allocation design remains live
before serviceability-subject construction. Existing negative-fact, domain,
consent, signing, host-limit and native serviceability obligations bind.

- A transient open/close entirely between occupancy samples must be visible
  wherever the selected argument relies on those events. Omitting it must fail
  the completeness control. If opaque events are outside a bounded argument,
  label the boundary and prove the bound rather than claiming measurement.
- Record pre-backoff accept IOError despite downstream suppression, selected
  delay, scheduled/resumed reads and fresh-connection outcome. Later success
  cannot erase a backoff event.
- Four saturated searches with blocked listing/metadata/canonical calls run
  beside fresh independent connections, durable grant-store operations and
  authorized launch/open/reveal. Correlate operation/search/cohort; distinguish
  attributable failures from unattributed events. Search-caused independent
  resource failure/backoff fails. Attribution gaps are inconclusive, never
  passing; invent no general latency target.
- Combine an indefinite admitted call with another job's resource failure.
  Cover disabled guidance, no retries/replacement, provider restart persistence,
  finite cleanup and fresh-process recovery. Frozen observations stay immutable.
- Cover 128/160/200/256/infinite/unknown soft limits, lower/higher refresh and
  reservations versus occupancy. At 256 four maximum-root jobs reserve 72
  credits and use four workers; a fifth is worker-refused. Descriptor admission
  can bind below 200. A lowered allowance below surviving reservations stays
  latched through a later rise until complete cohort cleanup.

These remain private-adapter, independent real provider/GraphQL and isolated
normally launched signed-host subjects. The [canonical call analysis](search-canonical-paths.md)
remains independent input, including native calls, repeated-walk costs and
reachable queue witnesses. Actual metadata/workflow omissions remain visible
for the operator decision; all-UNKNOWN metadata or an arbitrary sample cannot
accept the baseline. No native/binary/useful-coverage result is supplied here.

## Provenance and verification boundary

The in-process proposal checked the present action adapter and listener against
the same NIO revision and SDK declaration, and verified Apple's
[all-registration contract](https://developer.apple.com/documentation/coreservices/1449290-lscopyapplicationurlsforbundleid).
The documented not-found result is not a claim about every swallowed internal
failure. Proposed identifier inspection keeps Bundle positives and treats every
nil as UNKNOWN with affecting coverage; it neither reads Info.plist directly nor
asserts a missing key. Native package/hidden/type keys and prompt behavior still
need their actual-call subjects. The proposed instrument measures owned events,
call envelopes and pre-suppression accept/backoff hooks; it explicitly cannot
certify opaque transient acquisitions. Only an explicit human evidence decision
can replace the original complete-observer obligation with this narrower claim.
No native failure, absence of a possible observer or need for isolation was proved.

Graph project Users-antony-Development-Koine.add-plugins-for-modaliser-requirements
was ready at generation 2026-09-29T10:36:20Z. Tier 2 discovery/trace/snippet and
coverage checks found listener metadata changed, adapter/dependencies not
tracked and docs excluded. The listener snippet returned stale text for its
recorded range; its trace included unrelated heuristic symbols. Exact current
source reads support the claims here. No exhaustive graph claim is made.

Subjects were NativeWorkspace, LoopbackListener, checked-out NIO 2.103.0
Bootstrap/ChannelHandlers (Package.resolved revision
21de5f08c1a166a6dd293d0e587ad977bf8dac5d), macOS SDK 27.0's Launch Services
header and the local ktrace manual. Published primary sources above support
named decisions; their revisions are not the guest OS identity. No Koine/native
inspection probe launched, protected path was inspected or limit changed on the
developer machine. Design render/SDL/link
checks do not accept native visibility, serviceability, responsible TCC identity,
binary compatibility or useful coverage.
