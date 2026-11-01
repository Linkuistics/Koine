# Finite Settings caller workload

## Contract and current discussion

This specification expands the caller portion of the [workload inventory](KEEPALIVE-WORKLOAD.md).
Start with [Collection → Preserve one ordered plan](../../design/architecture/settings-activation/keepalive-caller.mmd).
Graph views start at the dark **Start here** node. Solid arrows describe order.
Dotted arrows describe prerequisites. The diagram explains the contract, not a
model-checking result.

The proposed plan below replaces C04's unspecified command group. It defines
semantic requests and required results before implementation. It does not claim
that the present CLI or a guest probe implements those results. The
[ordering protocol](ORDERING-EVALUATION-PLAN.md), [owner contract](../../specs/settings-keepalive-owner.md)
and [record schema](../../specs/settings-keepalive-records.md) retain authority.
Their deadlines, original-lock rule, single attempts and first-failure rule apply.

K137 supplies this design. Its scoped review and every earned integration precede
downstream consumption. Numerical fit and whole-design review remain outstanding.

Changed sections:

- [Caller setup](#caller-setup) — Defines preparation, observer readiness and sequence-level audits.
- [Ordered collection plan](#ordered-collection-plan) — Expands each observation and local audit into a distinct indexed item.
- [Recovery and unavailable paths](#recovery-and-unavailable-paths) — Defines the evidence needed before an unattempted item can run.
- [Multiplicity and object accounting](#multiplicity-and-object-accounting) — Separates exact design counts from missing byte and time bounds.
- [Local work and input bounds](#local-work-and-input-bounds) — Names the inputs consumed by parsing, hashing, archive handling and recovery.

## Request and ownership boundary

The caller supplies values: slot identity, exact requested clone, immutable
input inventory, collection plan and expected observations. The owner hides
queueing, ordinal assignment, locking, child supervision and publication.
The caller must not reconstruct those mechanics from filenames or exit text.
The failed-owner successor is the original caller using the schema's recovery
interface. It is not a new scenario sender.

Every indexed item binds this tuple in the private plan before clone start:

```text
plan index, site, applicability rule, prerequisites, target identity,
request version and operands, predicate version, family, storage class,
original roles, local-work limits, full resource contribution
```

Indices are plan positions, not attempt ordinals or terminal slot indices.
Inapplicable items keep their indices. A missing prerequisite is unavailable,
not inapplicable. No compaction or renumbering follows a failure.

The request names below are proposed semantic contracts. For an exec request,
the implementation must freeze the exact command bytes or probe image, argv,
environment and output schema corresponding to that name. It must retain those
bytes in the operation request. They are not permission for an arbitrary shell
command.

K81 owns the guest confirmation implementation. K89 owns file/lifecycle
adapters. K57 owns the caller. K126 checks their correspondence to this plan.

An implementation that needs another submission or a different grouping must
reconcile this inventory and accounting before freeze.

Every external operation retains exact argv/environment, VM binding, raw stdout
and stderr, CLI status, and complete response or original partial.
It also retains producer and collector observations, predicate result, result delivery and publication facts.
The table adds the operation-specific original roles. Private originals remain
private, including endpoints, environment values, source paths and credentials.

`X` means one guest exec through the strict adapter. It requires CLI zero,
`ok:true`, `timed_out:false`, guest exit zero and a complete versioned payload.
Known absence is explicit successful data. A missing field, inaccessible read,
timeout or partial list never means absence.

`L` means one evidence-class local
operation with its own ordinal and result, but no external CLI response.
The existing exec, read, capture, transfer, lifecycle and local families apply.
This specification adds no deadline. Successful local computations inside an
operation are covered by that operation, not charged again as separate `L` calls.

Requests return observations separately from comparisons. An endpoint may be
cleanly absent, a process may have ended, or installed bytes may differ. Those
facts remain available evidence even when the expected comparison fails.
Collection cannot restore scenario eligibility. Each failed collection item
keeps its own result while later independent applicable items may run under the
same owner, once its holder is resolved.

There is at most one outstanding
collection submission and at most one submission per plan index. No extra
scenario submission is made after failure. An already pending submission retains
its refusal or cancellation record.

## Caller setup

The set order and exact clone IDs remain E01, E02, A01, A02, A03 as declared in
the ordering protocol. Each owner/root is per slot. One original sequence caller
maintains the finite set declaration and blocks all later slots on failure.

| Setup index | Exact work and applicability | Required retained result |
|---|---|---|
| B01 | Once before E01: read the declared candidate, source/build/signing inputs, protocol, scenario/prefix/helpers, caller/classifier, observer, tools/decoders and owner/profile inputs. Enumerate regular files and symlink targets relative to their declared roots. | Complete sorted membership, per-item type/length/digest or link target, actual tool/SDK/signature/UUID provenance, exact launch defaults/environment, input errors and completion time. No reconstructed pre-run bytes. <!-- tc: depart synonym-rotation because application launch and clone start name different lifecycle boundaries --> |
| B02 | Once before E01: inventory and hash the stopped golden's exact config, disk and NVRAM objects and retain its stopped-state observation. | Exact golden identity, each original observation and item comparison basis, completed digest time strictly before the first clone request. Read failure prevents E01. |
| B03 | Before every admitted slot: re-enumerate and compare B01's inputs and candidate item by item. Before A01 also repeat B02 and compare with the original golden basis. | Distinct current inventories and comparison results. A01 has its own ordinary-readiness decision on the same candidate. No input count substitutes for membership. |
| B04 | Before every slot: create the unique private root and the profile's exact three backings, original lock, registries, plan, terminal pool and attachments. Establish caller/owner/worker/channel identities and readiness. | Schema bootstrap publications, all originals/partials, exact object identities, bounded transcript destination and preparation results. Do not invent an ordinal before bootstrap. Failed preparation prevents clone start. |
| B05 | Immediately before the one start request: consume this declared slot and bind the requested exact clone. Submit the existing start with golden/base, 1920×1080 and 600-second queue option. | Requested identity before effects, actual returned identity/spec/meta/config and raw result. Uncertain start consumes the slot. No replacement or guessed actual identity. |
| B06 | After clean start and first worker-sleep initiation: perform existing P02 installation, packaging and three uploads. Upload the frozen failure observer once to `/Users/admin/k12-activation-snapshot`. Then use one `X(observer-ready/1)` to make that exact file executable and check its bytes/identity. Complete before P03 and all scenario input. | Original observer source/binary identity, upload local/remote/byte result, exact executable confirmation. Failed setup stops the slot. The observer is not executed as a readiness test. |
| B07 | Before first launch: existing P03 diagnostic/default/environment observations and Automation setup. Preserve all scenario installation, launch and endpoint confirmations. | Actual effective values and explicit absences. No diagnostic enabling write, observer sidecar or native logger. |

B01–B04 are bounded caller/bootstrap work, not scenario operation receipts merely
because they have indices. Any external host query used there belongs to the
frozen preflight manifest, with its own result and local costs. B05 is P01, not a
second start. B06 adds exactly one transfer and one exec to P02. The three
existing uploads remain distinct.

The installed inventory probe can be frozen
inline command bytes, as the current scenario does. This design adds no separate
inventory upload. A changed implementation must account for one if required.

This preparation moves the legacy failure-time observer upload out of the
untouched observation interval. It does not qualify the observer's native
availability. If preparation failed, C01 is unavailable. Collection must not
repair that preparation by uploading, chmodding or launching another observer.

The prelaunch diagnostic probe and C13 below share one request schema, with
different phase operands and independent originals. Each A slot also retains
its existing post-restart diagnostic/display observations. Final collection
does not replace those earlier observations.

## Ordered collection plan

Freeze indices 1–25 in this order in each slot's private plan. These are the
expansion of C01–C06, plus the sequence-ending golden check and local outcome.
All use collection capacity. Terminal supervision and final handoff have their
own lanes and are not additional table operations.

`failure-context` applies when a required scenario/setup assertion, transport or
signal ended the slot after a guest target became observable. Pure pre-start
refusal has no guest-context observations. Uncertain start requires established
exact target identity before any guest read. Normal completion omits indices
1–5. A failure arising later during collection does not restart the prefix.

| Index / site | Request and exact target | Applicability, predicate and extra original roles |
|---|---|---|
| 1 / C01 | `X(failure-observer/1)`, execute only the prepared `/Users/admin/k12-activation-snapshot` on this clone. | Failure-context and B06 ready. Require the complete frozen observer schema. Preserve native PID/window/focus/time data and every raw failure. No upload or corrective input here. |
| 2 / C02 | `agent windows --json`, this clone. | Failure-context. Require the complete windows schema, retain the whole original. Preserve front-window interpolation facts from this list separately from the assertion's earlier list. No later list replaces either. |
| 3 / C03 | One checked full-display capture to this index's unique PNG object. | Failure-context. Require complete readable image and existing capture validation. Preserve raw result and every partial even if 1 or 2 failed. |
| 4 / C04.01 | `X(process-identity/1, executable=/Applications/Koine.app/Contents/MacOS/Koine)`. | Only the failed zero-window selection branch. Return complete matches or explicit absence, PID/start identity/exact executable for each. Compare with the pre-click identity. Loss/change is process loss. Failure or missing pre-click identity is unresolved, never recurrence. Runs after 1–3. |
| 5 / C04.02 | `X(front-application/1)` through the existing System Events read boundary. | Only the initial failed Settings-return interpolation that formerly read the front application. Retain complete name/PID observation even if another observer reports it. No re-read of the failed assertion. |
| 6 / C04.03 | `X(endpoint/1, /Users/admin/Library/Application Support/Koine/endpoint.json)`. | Any established accessible clone. Return exact original bytes plus parsed descriptor, or clean absence. Check schema and joins to the phase's expected endpoint. Do not infer liveness from the file. |
| 7 / C04.04 | `X(process-identity/1, executable=/Applications/Koine.app/Contents/MacOS/Koine)`. | Any established accessible clone. Retain all matches and exact PID/start/path facts or absence. This final endpoint audit is independent of index 4. Compare against the last established scenario incarnation and expected stopped/running state. Early failure grants no invented expected success. |
| 8 / C04.05 | `X(os-version/1)` using `sw_vers`. | Any established accessible clone. Complete product version and build. Compare to macOS 27.0.1/26A434. Retain raw fields and mismatch separately. |
| 9 / C04.06 | `X(architecture/1)` using `uname -m`. | Same target. Complete architecture equals arm64 for matched setup. |
| 10 / C04.07 | `X(gatekeeper-status/1)` using `spctl --status`. | Same target. Retain complete enabled/disabled assessment state and compare with installation/setup evidence. Nonzero/error is unavailable, not disabled. |
| 11 / C04.08 | `screen size --json`, this clone. | Same target. Complete positive dimensions. Compare with the applicable initial or post-restart geometry. A post-restart 1024×768 result is retained under the protocol, never changed by display input. |
| 12 / C04.09 | `X(boot-identity/1)` using the existing `sysctl -n kern.boottime` boundary. | Same target. Complete boot observation with provenance. Compare with known pre/post-restart originals as applicable. This read cannot rehabilitate failed restart submission or qualify native clock conversion. |
| 13 / C04.10 | `X(diagnostics-context/1, phase=final, bundle=dev.antony.Koine)`. | Same target. Complete effective domain/global/managed preference observations for trace, event buffer and menu probe. Actual launch environment/argument evidence, including login persistence when applicable. Require trace environment unset, trace/buffer keys absent, menu probe absent/false, no conflicting injected values. Retain each source/result and inaccessible fields. Never interpret failed defaults access as absence. |
| 14 / C04.11 | `X(installed-inventory/1, /Applications/Koine.app)`. | Clone where installation was attempted, including incomplete install. Complete membership/type/hash/link-target inventory and completion marker, or explicit target absence. Missing before-inventory makes comparison unavailable but does not omit this attempted read. Independent of O11's final inventory. |
| 15 / C04.12 | `L(compare-installed/1)`: index 14, installed-before and frozen host bundle inventory. | Required when installation was attempted. Compare every path/type/digest/link target and detect extras, omissions and duplicates. Retain separate before/final/host comparisons and missing-input reasons. No stripping blank lines to repair malformed input. |
| 16 / C04.13 | `L(host-input-inventory/1)`: all B01 declared roots and consumed inputs. | Every admitted slot, including start failure, when the original writer domain is available. Re-enumerate membership and hash exact current files/links. A digest check on only old paths cannot detect extras. |
| 17 / C04.14 | `L(compare-host-inputs/1)`: B01, B03 and index 16. | Every admitted slot. Retain per-item three-way correspondence and all missing/unreadable inputs. Failed enumeration prevents a clean comparison. |
| 18 / C04.15 | `L(bundle-inventory/1)`: exact frozen `.build/settings-activation/ordering-evaluation/Koine.app`. | Every admitted slot. Independent complete candidate file/link inventory, preserving the historical collector's distinct bundle audit. |
| 19 / C04.16 | `L(compare-bundle/1)`: original candidate, before-slot candidate and index 18. | Every admitted slot. Complete item equality, including extras. Does not substitute for installed endpoint comparisons. |
| 20 / C04.17 | `L(retain-archives/1)`: this slot's immutable permitted archive-role registry. | Every admitted slot. The P02 application package is the one planned archive role. Retain complete bytes or any produced partial and provenance. Native/log archives have zero scheduled roles because logging is disabled. An unexpected existing object is retained as unexpected evidence within its original charged extent, never parsed as a successful required archive. No log collection or new archive construction. |
| 21 / C04.18 | `L(audit-artifacts/1)`: sealed produced-object prefix through index 20 and the immutable expected-role registry. | Every admitted slot. Enumerate exact original/saved identity, byte length, hash and completeness for each available object, plus missing/unknown expected roles. If already retained in place, bind the same object explicitly. If a saved copy is required, compare both complete originals. Never glob a shared output directory or flatten names. |
| 22 / C05 | `vm stop <exact-requested-clone> --json`. | Start was submitted and target ownership/identity is established. One lifecycle-family attempt. Retain full stop response/CLI result. Mismatched returned start identity is not permission to stop another clone. Missing identity or unsafe targeting is unavailable. |
| 23 / C06 | One complete independent VM inventory request through the read adapter. | Start was submitted, whether index 22 succeeded or failed, while owner/lock/target conditions permit. Retain complete inventory and exact-ID state. A clean inventory cannot erase failed stop. Absence needs the implementation's qualified inventory semantics. Omission from a partial list never proves stopped. |
| 24 / sequence end | `L(golden-final/1)`: B02's exact stopped golden objects. | Only the slot that ends the sequence: A03 on all-clean execution, otherwise the first terminating slot. Inventory/hash every item and compare with B02 and any A01 recheck. Run after 22–23 where available. Unknown clone state or storage relation that prevents a safe read leaves this audit unavailable. |
| 25 / outcome | `L(classify-slot/1)`: original scenario/assertion/route/setup results, all applicable collection results and separate Task/status observations. | Every admitted slot whose writer remains available. Preserve recurrence rejection, other assertion failure, unavailable evidence, audit and stop outcomes separately. Mark later phases/slots NOT RUN. Required missing data prevents acceptance. No result text can clear the first failure. |

Indices 1–3 are contiguous guest observations. Failed or inapplicable earlier
items retain their disposition before advancing. There is no intervening guest
read, upload or release. Index 4 is part of untouched failure capture, after
that prefix and before other collection. No scenario input occurs anywhere in
the plan.

Both a signal during resize-down and a signal during its settling
sleep after clean down retain possible held input. Partial release does not
prove release. Neither path adds a release, reset or second capture attempt.

Index 21 cannot include its own future receipt, the later stop/inventory or final
records. It checks a sealed prefix. Each later operation checks and retains
its own originals before its disposition. Index 25 joins those results and the
prefix audit. Handoff and caller-final records follow the schema's publication
carriers and caller-return boundary. There is no recursive archive/hash of a
manifest containing itself and no invented post-return durable receipt.

Index 25 classifies only statuses already observed. In particular, an outer Task
that is waiting for this caller cannot have returned yet. Retain that status as
pending/unknown at publication. The supervising invocation must observe its
actual return before reporting complete acceptance. The caller-return trust
boundary does not permit a fabricated outer Task zero or a second final write.

## Recovery and unavailable paths

Normal scenario completion first requests cooperative worker stop and complete
drain/reap. A live owner with a failed scenario first suppresses ticks and settles
its active holder. Both then use the same plan. Ordinary allowance is never
used as substitute collection capacity.

After owner loss, the original caller has one recovery opportunity. Before any
item, it must establish all of the following:

1. Positively resolve every actual owned holder/descendant within the existing
   containment window and acquire the original lock object. Lock acquisition
   alone does not settle unknown descendants.
2. Check exact root, profile, three backings, pool, object map and full
   predecessor ranges under that lock. Scan every declared slot, including
   empty slots, and retain invalid bytes. Do not stop at the first empty slot.
3. Establish the unique valid ordinal frontier under qualified loss semantics.
   A torn/ambiguous possible fence prevents every new ordinal, including stop.
4. Burn the failed writer's remaining lanes and uncertain fence members. Retain
   known charges. Withhold unknown ordinary and already fenced collection
   allowances without fabricating charges or refunding them.
5. Publish kinds 25, 20, 5, 20 and required delayed holder observations in the
   successor lane before a new collection fence. Entry failure has no retry.
6. For the next applicable index, prove it was never named by a prior collection
   fence. Use complete predecessor evidence, plan order and the established
   frontier. An absent directory, commitment or receipt proves nothing alone.
   Its exact immutable prerequisites, target and disjoint capacity must still
   hold. All earlier indices must have a disposition or be retained as uncertain
   and unrepeated. Dispatch only the proven remaining suffix, in plan order.

Every collection fence binds one plan index under the schema. No fence reserves
a bag of future observations. Thus losing a complete fence before assignment
withholds that item's full contribution once. Its successor may continue with a
later independent item, but cannot complete the missing observation retroactively.
A failed prerequisite means the dependent item is unavailable. It does not
prevent an independent host audit or exact stop when their own prerequisites hold.

If owner loss occurs after observer execution but before a complete result, index 1 is uncertain.
Index 2 may run only if the recovery proofs succeed. The overall context remains incomplete.

Loss during C05 never permits a second
stop under that index. C06 may observe the result independently. Further exact
containment is a separate explicitly declared action. This plan budgets none and
provides no automatic fallback. Later slots remain blocked.

Unknown holders, failed original-lock acquisition, ambiguous frontier, missing
backing capacity or caller death leave collection unavailable. No alternate
root, direct CLI bypass, replacement owner or successor caller is permitted.

Caller observations buffered before lock acquisition retain bounded memory and
their original times. They are published only after lawful ownership.
Final persistent evidence itself may be unavailable.
Before any root exists, retain the bootstrap refusal through the declared caller output if available.
That output is not an owner record and permits no clone start.

The normal final path burns the unused owner/successor lanes and uses caller-final
kinds 25, 20, 27, 20, 28. Failed-owner recovery already used kind 25 in its entry.
Its final lane starts 27, 20, 28. Actual owner response, channel result and wait
stay separate. The unchanged eight-second normal final sequence includes its
publication work. Recovery scan and local audits do not acquire an extra final
stage or a reset containment deadline.

## Multiplicity and object accounting

These counts follow the declared plan, not measurements or new resource limits.
For a path, let `e_i` mean that plan index i is applicable with prerequisites
proved, and `s_i` mean that its one submission actually occurs. Then
`0 <= s_i <= e_i <= 1`. An attempted prior fence may withhold an item even when
`s_i` is unknown after loss. Use that item's full reserved contribution once in
the owner/successor union. Never reserve a second full set for recovery.

| Quantity per started slot | Derivation |
|---|---|
| Collection plan positions | 25 immutable indices. 16 external positions (1–14, 22–23). 9 local positions (15–21, 24–25). |
| Clean nonfinal slot | Indices 6–23 and 25: 19 submissions at most, comprising 11 external and 8 local. Required prerequisites must hold for a clean path. |
| Clean A03 | Same set plus 24: 20 submissions, 11 external and 9 local. |
| Failure envelope | At most 25 submissions, 16 external and 9 local. This is a componentwise envelope: branch/phase applicability may make some combinations unreachable. |
| Observer preparation addition | B06: one transfer plus one exec. No failure-time upload or inventory upload. These are ordinary P02 operations while ticks are active. |
| Complete clean E/A sequence | Five starts. Five B06 pairs. Four 19-item tails and one 20-item tail = 96 collection submissions, of which 55 external and 41 local. This excludes scenario/tick operations and pre-owner work. |
| Failure-stopped sequence | At most four completed 19-item tails plus one 25-item failure envelope = 101 collection submissions. This is conservative, not a claim that every index can coexist in the fifth failure. Never multiply five maximal failed tails. |
| Golden observations | B02 once before E01, B03 once before A01 if reached, index 24 once at sequence end if possible. Failed/unavailable attempts are retained. No replacement digest. |
| Installed inventories | P02 before, O11 after only if reached in A, and collection index 14 independently in every installation-attempted slot. Clean E has two. Clean A has three. |
| PNGs added by this caller | One at index 3 on applicable failure paths. B06 executes no capture. All two E/six A baseline images, additional required scenario images, ticks and internal OCR/input frame work remain separately counted. |

Each assigned collection item needs one collection-backed attempt directory and
its full standard request/raw/result/producer/collector/validation objects from
the schema. Each `L` directory has explicit inapplicable external roles, rather
than fabricated zero-byte CLI success. An index withheld after owner loss keeps
its contribution unavailable, even if its directory is absent. Refused unassigned
items consume terminal rows and attachments without inventing an attempt charge.

The operation-specific role counts are finite:

- One observer result and two window/image originals at 2–3.
- Two possible process reads at 4 and 7, one front-app read and one endpoint read.
- Six context results at 8–13 and one installed inventory.
- Two independent host inventories and their three comparison reports.
- One archive-role report and one artifact correspondence report.
- One stop response and one independent VM inventory.
- One final golden report and one classification report.

This counts
logical results, not storage objects. Raw streams, wrappers, fragments, partials
and preassigned attachments remain additional objects under the record schema.

Let `O_i` be the complete reserved object contribution of position i.
It includes its directory, standard role objects, operation-specific originals and partial capacities.
Collection storage must cover the maximum applicable path sum of
`O_i` with every uncertain predecessor contribution retained. Derive byte and
physical-object bounds from each role's input limits and the schema, rather
than equating 25 plan entries with 25 files. Maximum original/argument/predicate
lengths and physical metadata costs are still missing.

## Local work and input bounds

Every row needs finite input count, per-item length, aggregate bytes, work/time,
temporary memory, process overlap and retained-output bounds before admission.
Reading a known list is not a bound on the objects it names. Use checked integer
arithmetic before allocation. Exceeding a bound preserves produced originals
and partials, stops eligibility and leaves the remaining input unknown.

| Work | Complete input dependencies and retained work |
|---|---|
| Freeze/re-enumeration | Declared root set, directory entry counts, path/component/link lengths, regular-file lengths and aggregate bytes. Count enumeration, sorting, digest reads and comparisons separately. Retain errors and exact membership, including extras. B01, B03, 16 and 18 are distinct passes. |
| Guest payload parsing | Full raw envelope bytes, decoded stdout, response/tree/list counts and nesting/string limits. Include simultaneous raw, decoded and parser values plus predicates and error results. Parsing a projection does not reduce the raw contribution. |
| Process/default probes | Process count and argv/environment lengths, preference domains/key/value lengths, provenance and per-field error records. Exact APIs/commands and completeness evidence belong to k81. Absence is unavailable until that contract is implemented. |
| Hash/comparison | Every file/link byte at both relevant endpoints, sorted inventories, per-item comparison rows and diagnostics. Retain all mismatches rather than a totals-only report. Streaming reduces buffer demand, not total reads or elapsed work. |
| P02 packaging | Complete source bundle bytes and membership, archive output and partials, compressor workspace, simultaneous source/archive/extracted guest copies and uploads. Package creation occurs once after cadence starts. No guessed compression ratio. |
| Archive retention | Registry of one planned app-package role, its actual complete/partial extent and provenance. Retain in place or copy only to its preassigned role. No recursive evidence archive and no native log archive acquisition. Unavailable package remains missing. Discovery does not cause packaging again. |
| Artifact correspondence | Finite profile object map and generated-role occurrences, exact existing extents, saved-copy extents if any, directory membership and per-object hashes. Include unexpected objects within the charged map. No unbounded filesystem search, dropped partial or self-containing digest. |
| Transcript | Each declared producer's raw output plus bounded formatted status text and interprocess buffers. Charge transcript duplication separately when a stream also has an original object. A `tee` process is a writer/holder with lifetime and failure costs, not free logging. No secret-bearing output is made public. |
| Recovery scan | Every slot in both predecessor owner ranges, bootstrap and required referenced objects, complete bindings/fences, full layout and attachments under their declared maxima. Bound bytes actually scanned, parser memory, link checks and comparison work. No empty-slot early termination or scan outside the immutable map. |
| Final classification | Finite five-slot status table, scenario phase/assertion registry, applicable plan results, original-sharing joins and missing/uncertain facts. Retain original outcome precedence and distinct scenario/inner Task/outer Task/collection/endpoint/environment/audit/stop statuses. |

Local children execute serially within their owning operation unless the frozen
implementation explicitly accounts for overlap. The existing worker/sleep,
backend, collector and producer can still overlap with host work. K126 must
derive the actual process/descriptor peaks. Neither the six-process study nor
the eight named roles is a bound. The owner/caller windows do not guarantee a
blocked hash, archive or filesystem read will return. Enforcement gaps remain
unavailable work, not longer authorised waits.

For the [combined derivation](KEEPALIVE-ACCOUNTING.md), B06 adds two ordinary
admission/operation terms to the active interval. Preflight is before cadence.
P02 archive work and B06 are inside it. Collection 1–25 follows suppression and
adds no tick. `L_p` includes only local work not already covered by an operation
or overlapping protocol interval. Tick service is still counted once.

`n`, `a`, fences, carriers and lane-tail vectors must consume this plan and its
failure prefixes. Numeric `O_i`, messages, attachments and `u/r/z/o/j/d` remain
implementation/layout inputs, not values inferred from the table length.

## Alternatives and verification obligations

A generic C04 script has fewer visible calls, but hides which observation failed
and whether recovery repeats it. Giving the caller a fresh collection set after
owner loss duplicates effects and allowances. The selected immutable plan localises
order, applicability and no-repeat decisions in one immutable value. Its cost is
more explicit receipts and a larger bounded manifest. The owner retains the
existing scheduling/recovery mechanism. No new public product interface is added.

Revisit the grouping if implemented probes cannot return complete results under
the existing operation families. The remedy is a reviewed plan/accounting change
before freeze, never an extra runtime read or guessed larger allowance.

At the agreed helper/adapter and audited owner/caller seams, later implementation must exercise these cases:

- Failure at every plan boundary.
- Clean absence versus failed reads.
- Malformed, extra or missing inventory entries.
- Owner loss after fence but before binding.
- Loss at indices 1, 3, 14 and 22.
- One unattempted suffix without duplicate commands.
- Unknown holder/frontier refusal.
- Both held-pointer signal cases with no release.
- Start identity disagreement.
- Artifact partial/copy mismatch.
- Final golden failure and missing final publication.

Every case checks
ordered original identities and actual status, not only a command count.
No controls are run by this design leaf.

## Remaining prerequisites and handoff

| Owner | Required return |
|---|---|
| K57 with k81/k89 | Implement the finite caller and exact frozen probe/CLI payloads. Prove observer preparation, effective defaults/process identity, independent complete VM inventory and one-shot file/lifecycle confirmations. Preserve unavailable outcomes where the actual service cannot supply them. |
| K76/k67/k62, reconciled by k126 | Complete scenario adoption, setup/title/liveness grouping and exact E/A prefix. Bind every independently required screenshot and original-sharing point. This caller design does not supply their final counts. |
| K125 | Scope external queue/start identity/containment, producer-unit and native/service completeness, raw collection and storage/loss evidence. Include host archive/hash/transcript/scan mechanism limits required by the local-work table. No native execution is authorised by this request. |
| K126 | Instantiate frozen request lengths, input cardinalities, process/message counts, per-item object layouts, remaining-tail tables and all numerical time/space maxima. Reconcile B06 and 1–25 with the full workload, family deadlines, record carriers and useful protected capacity. Retain whole-design review before planning. |
| Scoped review of k137 | Challenge every required duty, plan branch, independent original, no-repeat proof and multiplicity before k125/k126 consumption. |

This discharges the caller's semantic expansion, not the implementable manifest
or a useful numerical profile. Missing native/storage/producer evidence remains
missing. No VM, input retry, wait change, new native experiment, cap expansion,
candidate freeze, acceptance or ancestor closure follows.

## Source evidence

The protocol's freeze/audit and transport sections supply the required
observations. The historical [collector](run.sh) retains separate host-input,
bundle and installed audits, final environment/display, artifacts and exact stop.
Its uploads after failure, ignored errors and diagnostic download are historical
behaviour, not adopted execution. The [inventory helper](inventory.sh) supplies
the regular-file/hash and symlink-target basis. Its text format is not a new
complete arbitrary-path schema.

The [scenario](../../../scripts/vm-verify-menu-bar.sh) independently inventories
the installed bundle before and after its complete path. Its final read remains
distinct from caller collection. The [common helper](../../../scripts/vm-verify-lib.sh)
creates the application package, transcript and existing setup operations.

Tier 2 graph evidence used project
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`, coverage
generation `2026-11-01T05:05:04Z`. The historical collector had no recorded gap.
Its inbound edge identifies `finish`. Outbound matches for shell command names
included unrelated documentary symbols and were not treated as executable
dependencies.

Direct reads establish the cited behaviour. Coverage reported
partial shell parsing at scenario line 169 and common-helper line 175. Direct
reads covered both ranges and the material surrounding bodies. This is bounded
evidence, not a repository-wide completeness claim.

## Design verification

On 2026-11-01, a direct check established the consecutive 1–25 indices, external/local partition, clean tail counts and conservative sequence arithmetic. Both architecture manifests have unique diagram IDs, existing editable sources and valid current-discussion references. The browser rendered the caller flow, including its final audit/publication path.

`mise exec -- task check:docs` returned Task status 201, checker status 1, with only the existing two missing targets in `context-initial-inputs/CONTEXT-PLAN.md`: `context-predicate.txt` and `context-qualify-filter.sh`. Those archive defects remain k23's work. These checks establish document consistency only. No coordinator, VM, storage qualification or native experiment ran.
