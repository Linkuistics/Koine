# Keepalive record and recovery control design

## Scope and reading order

This design expands S2–S6 into individually named future controls of the real coordinator.
The [record specification](../../specs/settings-keepalive-records.md) owns encoding, publication carriers, one-use slots and recovery.
The [owner contract](../../specs/settings-keepalive-owner.md#test-seams-and-discriminating-controls) owns transitions, timing, process ownership and approved barriers.
The [producer contract](../../specs/settings-capture-resource-contract.md#approved-koine-test-controls) owns the approved result substitutions and copy audit.

Read the [publication view](../../design/architecture/settings-activation/keepalive-recovery-controls.mmd), then the common oracle and case products below.
The [transfer view](../../design/architecture/settings-activation/keepalive-recovery-transfer.mmd) separates normal handoff from failed-owner recovery.
Graphs start at the dark **Start here** node.
The view explains a proposed test contract. It supplies no model-checking result.

Every canonical ID below denotes one independently reportable design case with a fresh synthetic root.
The explicit alias table maps coincident product members to that canonical case.
An alias adds assertions to its canonical case, not another root, invocation or charge.

A product expands only over its explicitly listed members.
The count is not a runtime budget, executable manifest or permission to run controls.
S1 and the 17 [raw cases](KEEPALIVE-RAW-CONTROLS.md#fixed-case-matrix) retain separate identities and counts.
The thirteen native mechanism cases provide no budget for this suite.

K124 supplies workload-derived maxima, carrier costs and complete tail tables.
K125 supplies the missing native and dependency evidence scopes.
K126 reconciles the complete design before whole-design review.
No value here selects production capacity, changes sleep20 or relaxes an existing requirement.

## Common subjects and decisive oracle

The test harness selects audited copies of the implemented owner, backend and finite caller.
It uses the approved barriers, clock reader, capacity observations and named write results.
The approved complete-write observation substitutions have the exact scope stated in the producer contract.
The external CLI and sleep seams supply finite fixtures without contacting a VM or native OCR service.
The real coordinator owns startup, lock acquisition, allocation, charging, validation, delivery, stop and collection.
No test seeds a live state by replacing that transition code.

The fixture supervisor retains a separately bounded control transcript.
Each site identifies its module, lifecycle or submission identity, record kind, named invocation and before/after observation.
Missing, duplicate, unexpected or unused sites fail the correspondence check.
Any unrelated difference between production and the copied source also fails it.
The harness records actual process creation and external invocations independently of the coordinator's receipts.

Every successful setup reaches real readiness through complete bootstrap.
A controlled CLI start result enables the worker's first controlled sleep.
Setup commands have separate identities, charges and outputs.
They are not free additions to the measured case.
Bootstrap-failure cases stop before readiness.

For each selected publication, retain the exact intended encoded bytes as `E` in the private fixture inventory.
Let `N` be their checked length and `P = min(17, N - 1)`.
The two header-complete recovery fixtures instead use the explicitly declared 376-byte prefix below.
All selected frames and wrapped objects exceed seventeen bytes.

The partial control writes exactly `E[0:P]` into the real assigned object, then reports failure.
An unexpected short underlying write makes that boundary unavailable.
It never invents persisted bytes or retries the failed publication.

The prefix oracle compares object identity, actual bytes, untouched suffix and every earlier object's bytes.
For a precreated slot, the bytes after its prefix remain zero through the fixed extent.
For an attachment, compare its declared original extent and any preallocated zero suffix separately.
An absent write leaves no fabricated frame. A complete frame has exactly `E` and valid padding.

Readability establishes visibility only. It cannot supply a lost flush observation.


Every case also checks these facts:

- The terminal slot, lane, event sequence, parity skips and attachment set remain consumed once selected.
- Assignment retains the original ordinal, full charge, directory identity and operation token.
- Pre-assignment refusal or cancellation has terminal cost and no operation charge.
- First failure remains immutable. Later collection success cannot restore eligibility.
- The selected dependent action occurs zero times when its required publication is failed or unknown.
- Each actual external invocation retains its class, submission identity, ordinal, exact arguments and status.
- Every original and partial object remains private and unchanged.
- Final acceptance requires all joins and the caller's actual final publication result.

After an owner-path failure, submit one distinct scenario sentinel through the existing caller interface when that interface remains available.
Require zero external scenario invocations for its identity.
A broken interface records unavailable submission, rather than a fabricated refusal receipt.
Collection uses separate identities and retains its required order and independent outcomes.
No sentinel repeats failed work or submits corrective input.

## Original eighteen cases

These IDs preserve the [qualification baseline](KEEPALIVE-QUALIFICATION.md#storage-and-process-loss-controls).
Additional products retain coincident members as aliases of these original IDs.
The prefix column describes the selected subject at the cut, not an invented persisted success.

| ID | Module, kind and selected invocation | Control and actual prefix | Decisive additional oracle |
|---|---|---|---|
| S2-clean | Caller/owner/backend, complete lifecycle | Controlled CLI and sleep. All required records complete. | Enumerate clean rows, carriers, attachment reservations, charges and normal final path. |
| S2-failed | Caller/owner/backend, first ordinary failure | CLI exits 7 with finite original output. | Enumerate failure, refusal, pending cancellation, stop, collection, recovery and final costs. A recovery branch gets its own root below. |
| S3-before-fence | Owner, first K6 | End owner before slot choice. No fence bytes. | Genesis frontier permits ordinal 1 only after recovery prerequisites. |
| S3-partial-fence | Owner, first K6 | End owner after the real `P` prefix. | Torn odd slot refuses further allocation. |
| S3-fence-before-assignment | Owner, first K6 | End owner after successful publication, before assignment. | Burn its entire ordinal range without inventing charges. |
| S3-charge-before-binding | Owner, first K7 | End owner after charge and slot choice, before bytes. | Hidden charge remains unknown after death. Prior ordinary allowance stays unavailable. |
| S3-partial-binding | Owner, first K7 | End owner after `P` bytes. | Burn the fence remainder. Retain unknown charge facts and no duplicate assignment. |
| S3-binding-before-directory | Owner, first K7 | End owner after successful publication. | Keep the known charge. Do not recreate the old directory or issue its command. |
| S3-directory-before-commitment | Owner, first K9 | End owner before slot choice, after actual directory creation. | Preserve the exact directory. No inference of execution from it. |
| S3-commitment-before-execution | Owner, first K9 | End owner after publication and its K20, before backend creation. | Intent remains. No resend or invented external execution. |
| S4-result-before-disposition | Owner, first K18 | End owner before slot choice after backend result. | K15 and actual reap cannot substitute for K18. |
| S4-send-before-echo | Owner, first completion send | End owner after actual send, before choosing the K19 send-record slot. | Recipient receipt stays unknown to owner. Both send and echo records remain absent. Final acceptance fails. |
| S4-ack-before-reap | Owner, K23 | End owner after K22 and actual worker wait, before K23. | Actual wait remains distinct from missing published reap. |
| S4-handoff-before-final | Caller, normal K28 | End caller before K28 after handoff and owner wait. | No successor or inferred caller return. |
| S5-inherited-holder | Caller, K25 entry | A controlled child retains the original descriptor after owner exit, then exits under the bounded schedule. | Refuse entry while held. After actual holder resolution, acquire the original lock and permit entry once. |
| S5-backing-mismatch | Caller, K25 entry | Approved capacity/identity observation reports another backing. No K25. | Refuse recovery. Never replace the backing or lock. |
| S6-collection-create | Owner, first collection directory | Approved named directory-create result fails before creation. | Preserve its assignment and charge, unavailable item and later independent outcomes. |
| S6-terminal-prefix | Owner, first K18 | Write `P` real bytes then fail. | Preserve the prefix, no completion permission and no refunded charge. |

## Publication cuts

Case IDs are `W-<target>-<cut>`.
Every target in the following table expands over all seven cuts, subject to the alias table.
The selected invocation is the first occurrence matching the complete table description.
Earlier setup and preceding records follow their real paths.
Each case ends only the directly owned selected writer, once, when its cut requires process loss.
Owner termination never constitutes reap of its grandchildren.

| Cut | Approved site and retained selected bytes | Required distinction |
|---|---|---|
| choose | Barrier before slot choice, then writer loss | Selected object remains unused, but failed-lane recovery burns its uncertain suffix. Bootstrap/caller loss permits no restart. |
| empty | Barrier after slot consumption, before attachments or frame bytes, then loss | Selected slot and its full attachment set stay consumed despite zero frame bytes. |
| prefix | Named result site writes `P` bytes, reports failure, then loss | Retain real prefix and failed live observation if published. Recovery cannot invent the lost observation. |
| complete | Barrier after all frame bytes, before flush observation, then loss | Complete readable bytes do not imply flush success. Dependent action has not occurred. |
| observed | Barrier after successful publication observation, before the next dependent record/action, then loss | Preserve complete bytes. Recovery uses only retained evidence, never the dead writer's lost memory. |
| fail-zero | Named write result fails without writing. Writer stays alive. | Eligibility closes. The target-specific failure rule below applies. Dependent action stays absent. |
| fail-prefix | Named write result writes `P` bytes then fails. Writer stays alive. | Keep prefix and actual failure. No retry, slot reuse or clean continuation. |

The `empty` barrier precedes attachment writes for that selected event.
The `complete` barrier follows completed attachments and the complete frame write.
Attachment-specific cuts appear separately below.
For K29 targets, the triggering earlier publication fails first at its declared site.
Failure of K29 causes no recursive K29 or K20 about K29.
Only independently necessary, already reserved containment and final evidence may follow.

Both live failure cuts use the following carrier rules, where the writer can still publish.
The rules follow the schema's existing schedule and bounded failure summary.
No row permits retry, an invented successful publication or a recursive failure logger.

| Failed target class | Required failure record or retained limit |
|---|---|
| K1, K2, K3 and bootstrap preparation objects | The next K4 preparation vector retains the result. Incomplete setup forbids readiness. |
| K4 | Its required K20 retains the attempt's result. An earlier batch also retains its successor-batch obligation. |
| K5, K9, K18, K21, K23, K25, K26 and K27 | Their mandatory K20 retains the result. Dependent work stays forbidden. |
| K6, including renewed and collection fences | No K7 follows the failed fence. K10 retains first failure. The optional reserved K29 can retain the bounded write-failure summary. |
| K7 or K9 as embedded predecessor carrier | Attempt one fallback K20 for K6 or K7 respectively. K9 also owes its own mandatory carrier. Neither permits dependent work. |
| K20 | Only the reserved K29 failure summary may report this failure. No K20 reports another K20. |
| K28 | The actual caller return observes failure. A readable final frame cannot restore acceptance. |
| K29 | No recursive K29 or K20. Retain its partial or missing result and only independently necessary reserved failure actions. |
| Other terminal kinds | Preserve first failure and the bounded K29 rule. Do not invent a mandatory K20 absent from the schema's schedule. |

The K7/K9 row adds predecessor fallback duties to the target's own applicable rule.
These rules concern record-write failures. Failure of an attachment also leaves its containing event unavailable.

| Target | Module / lane | Kind and selected invocation | Dependent effect or acceptance fact |
|---|---|---|---|
| root | Caller / bootstrap | K1 root declaration | Complete bootstrap |
| profile | Caller / bootstrap | K2 first profile fragment | Complete bootstrap |
| pool | Caller / bootstrap | K3 pool declaration | Complete bootstrap |
| setup | Caller / bootstrap | K4 final setup batch | Writer transfer after K20 |
| open | Owner / history | K5 owner opening | Readiness after K20 |
| fence | Owner / history | K6 first ordinary fence | First assignment |
| binding | Owner / history | K7 first ordinary binding | Exact directory creation |
| received | Owner / history | K8 received | Admission processing |
| commitment | Owner / history | K9 first ordinary commitment | Backend creation after K20 |
| failure | Owner / tail | K10 first failure | Published failure identity, never restored eligibility |
| child | Owner / history | K11 backend creation | Known child/holder join |
| ready | Owner / history | K12 worker readiness | Caller readiness receipt |
| progress | Owner / history | K13 first launcher progress | Known phase/resource join |
| offer | Owner / history | K16 first result offer | Complete offer evidence |
| ack | Owner / history | K17 first payload acknowledgement | Clean terminal disposition |
| terminal | Owner / history | K18 first ordinary disposition | Completion send after K20 |
| send | Owner / history | K19 completion send | Known completion-send join |
| carrier | Owner / history | K20 for first K9 | Backend creation |
| stop | Owner / tail | K21 stop intent | Stop delivery after K20 |
| stop-ack | Owner / tail | K22 matched acknowledgement | Matched reap join |
| reap | Owner / tail | K23 worker reap | Handoff after K20 |
| contain | Owner / tail | K24 first TERM action observation | Known containment fact, never inferred exit |
| recover | Caller / successor | K25 failed-owner entry | Successor K5 after K20 |
| handoff | Owner / tail | K26 handoff | Response and transfer after K20 |
| owner-exit | Caller / final after recovery | K27 owner-exit | K28 after K20 |
| final | Caller / final after recovery | K28 final outcome | Caller return with actual publication result |
| write-failure | Owner / tail | K29 after first K18 failure | Bounded failure summary only |
| successor-open | Caller / successor | K5 collection-only opening | Delayed observations and fence after K20 |
| owner-collection-fence | Owner / tail | K6 first collection item | That item's assignment only |
| successor-fence | Caller / successor | K6 first proven unattempted item | That item's assignment only |
| normal-transfer | Caller / final | K25 normal handoff | K27 after K20 |
| normal-owner-exit | Caller / final | K27 after normal transfer | K28 after K20 |
| normal-final | Caller / final | K28 after normal transfer | Caller return with actual publication result |
| bootstrap-summary | Caller / bootstrap | K29 after final K4 failure | No readiness or recursive summary |
| successor-summary | Caller / successor | K29 after successor K5 failure | No collection or second entry |
| final-summary | Caller / final | K29 after K27 failure | No clean final acceptance or recursive summary |
| successor-binding | Caller / successor | K7 first collection binding | Collection-backed directory |
| successor-commitment | Caller / successor | K9 first collection commitment | Collection backend after K20 |
| successor-terminal | Caller / successor | K18 first collection disposition | Its completion after K20 |
| renewed-fence | Owner / history | K6 after exhausted settled ordinary fence | Contiguous next range |
| setup-batch | Caller / bootstrap | K4 first non-final batch | Next setup batch |
| admitted | Owner / history | K8 admitted | Selection and actual recheck |
| refused | Owner / tail | K8 resource-refused | Known refusal, no operation charge |
| cancelled | Owner / tail | K8 cancelled-unstarted | Stop resolution without capture |
| echo | Owner / history | K19 completion echo | Known recipient receipt, no deadline rescue |
| backend-reap | Owner / history | K11 backend exit | Result offer with actual wait |
| holder | Caller / successor | K11 delayed holder observation | Required recovery evidence before fence |

The caller executes successor command records through its collection-only role.
It does not create another owner or worker.
The table covers every terminal kind. Backend K14/K15 use attempt objects and the separate backend product below.
Repeated K12 phases, K13 progress and K24 containment actions also receive their lifecycle and deadline controls below.

## Publication carriers and attachments

Case IDs `C-<target>-<outcome>` use seven outcomes: `clean`, `flush-failed`, `flush-unknown`, `visibility-failed`, `visibility-unknown`, `namespace-failed` and `namespace-unknown`.
The named target is its first matching publication in that path.
The observer is its live writer at the named publication-result site.
The clean outcome uses actual calls. The six negative outcomes use the producer contract's approved complete-write observation extension.

Antony approved that extension on 2026-11-01. Implementation and correspondence audits still precede execution.
The substituted observation changes no actual I/O call, allocation code or native mechanism evidence.

For `clean`, actual target writes and all required flush, namespace and visibility calls succeed.
The carrier retains those observations before the dependent effect.
For each negative outcome, actual target bytes are complete. The copied publication result reports the named failed or unknown field.
The original real call results remain separate control evidence.
Each negative variant prohibits the dependent effect even if readback returns the complete frame.

For namespace cases, the frozen publication method must require an actual namespace operation at that target.
Precreated in-place objects can need no namespace operation. Then the actual field is inapplicable and both namespace cases remain explicitly inapplicable.
The manifest must state that reason and preserve the conditional coverage obligation if the selected method later requires that operation.

No fixture invents a namespace operation merely to make a case runnable.

| Target | Writer and required carrier | Dependent effect |
|---|---|---|
| setup | Caller, K20 for final K4 | Transfer original writer ownership |
| owner-open | Owner, K20 for K5 | Readiness |
| commitment | Owner, K20 for first K9 | Backend creation |
| disposition | Owner, K20 for first K18 | Completion send |
| stop | Owner, K20 for K21 | Normal stop-ID delivery |
| reap | Owner, K20 for K23 | Claim published reap in K26 |
| recovery | Caller/successor, K20 for K25 | Successor K5 |
| successor-open | Caller/successor, K20 for K5 | Delayed observations or collection fence |
| normal-transfer | Caller/final, K20 for K25 | K27 |
| handoff | Owner/tail, K20 for K26 | Handoff response or transfer |
| owner-exit | Caller/final after recovery, K20 for K27 | K28 |
| normal-owner-exit | Caller/final after normal transfer, K20 for K27 | K28 |

For each target above, `CF-<target>` fails its mandatory K20 before any write, after a successful target publication.
Require a consumed fresh slot, zero dependent effect and at most the reserved K29.
No K20 may report another K20's or K29's failure.
The actual target prefix is complete and unchanged.

The embedded carriers have separate IDs:

| ID | Module / invocation and actual prefix | Decisive oracle |
|---|---|---|
| CE-setup | Caller, first K4 after one failed preparation result. K4 completes. | Its vector reports the failed object. Complete setup remains impossible. |
| CE-batch | Caller, second K4 after the first complete batch. Both complete. | Carry the first batch's actual publication results. No self-flush claim. |
| CE-fence | Owner, first K7. K6 and K7 complete. | K7 carries K6's actual publication before any directory creation. |
| CE-binding | Owner, first K9. K7 and K9 complete. | Observe K7 before directory creation. K9 retains that observation. |
| CE-first | Owner, first K6. Complete frame. | `prior-publication` names its K5, with inapplicable prior fence. |
| CE-renewed | Owner, second K6. Complete frame. | `prior-publication` names the exact prior fence. No unretired overlap. |
| CE-successor | Caller, first successor K6. Complete frame. | Prior fence may be old, but `prior-publication` names the successor K5. |

Cases `FB-<carrier>-<outcome>` use carrier `K7` or `K9`, and outcome `retained`, `fallback-fails` or `writer-lost`.
The predecessor is respectively K6 or K7, with complete bytes and a real successful publication observation.
The selected carrier fails after its real `P` prefix.
For `retained`, one fallback K20 retains that predecessor observation.
For `fallback-fails`, the fallback fails before bytes, with no recursive K20.
For `writer-lost`, end the directly owned writer before fallback slot choice.

The lost observation stays unknown. Every variant forbids dependent work and retains all consumed capacity.

Cases `A-<role>-<cut>` use roles `submission`, `recovery` and `final` with all seven publication cuts, subject to aliases.
Role `bootstrap` uses `prefix`, `complete`, `observed`, `fail-zero` and `fail-prefix`, plus the single `before-write` cut.

The submission target is K8's O1 original, written by the owner. Recovery targets the successor caller's K25 O7 lock summary.
Final targets the final caller's K28 O7 collection summary. Bootstrap targets the caller's first O4 profile object.
For this product, slot choice means reserving the containing event's slot and its immutable attachment set.

For `A-bootstrap-before-write`, end the caller at the barrier before writing the preassigned O4 object.
No O4 bytes, event-slot choice or new allocation is implied. Bootstrap stays incomplete and cannot restart.
The former bootstrap `choose` and `empty` labels alias this one boundary.

Require exact real prefixes, no reference promoted to known before completion, and no reuse of any attachment after loss.
The containing event and its dependent effect remain unavailable when their required object is incomplete.

Cases `BE-<kind>-<cut>` use `K14`, `K15-validation` and `K15-result`, with cuts `fail-zero` and `fail-prefix`.
The backend targets its first measured attempt's assigned object through the approved receipt-write result.
These objects use no terminal slot. Their full attempt charge remains consumed.
Require no clean result offer, no overwritten original and sentinel refusal.

## Encoding and bounded fixtures

Cases `E-K01` through `E-K29` encode and decode one valid instance of each record kind through the real codec.
Cases `E-O01` through `E-O12` do the same for every wrapped object type.
Each fixture uses finite maxima from its declared synthetic profile and valid references to completed synthetic objects.
Check actual byte length against the catalogue formula, digest preimage and exact round trip.
Preserve original argv, environment and byte objects without text normalisation.
These are codec cases, not evidence of transition reachability or useful capacity.

For identities `K01` through `K29` and `O01` through `O12`, cases `M-<identity>-<fault>` apply these ten faults separately:

| Fault | Exact finite mutation | Oracle |
|---|---|---|
| version | Increment the minor version and recompute the enclosing digest. | Reject unsupported version. |
| major | Increment the major version and recompute the enclosing digest. | Reject unsupported version. |
| magic | Flip the first magic byte and recompute the enclosing digest. | Reject the wrong record or object marker. |
| kind | Set record kind or object type to 65533 and recompute digest. | Reject unknown type. |
| reserved | Set the first reserved/flags bit and recompute digest. | Reject reserved bits. |
| short | Remove the final byte. | Retain the received prefix. Reject incomplete frame. |
| excess | Append one nonzero byte after the complete object/frame. | Reject trailing data or nonzero slot padding. |
| length | Set the payload-length field to unsigned 64-bit maximum and recompute digest. | Reject before allocation or offset overflow. |
| digest | Flip one bit of the digest only. | Reject mismatch without interpreting the payload as evidence. |
| bound | Give the complete valid object to a reader whose maximum frame/object bytes is `N-1`. | Reject before accepting or allocating its declared content. |

Cases `M-K01-end-marker` through `M-K29-end-marker` change the first end-marker byte and recompute the digest.
Each must reject the marker despite the valid digest. Wrapped O objects have no end marker, so this product excludes them.

The real decoder receives these fixtures through its bounded input entry.
Malformed fixtures exist only in fresh synthetic roots or channels before the real reader starts.
They never corrupt a live evidence volume or bypass the writer during a running case.
The later manifest freezes exact bytes and expected allocation/read ceilings.
No claimed length requires allocating that many bytes in the fixture builder.

The following additional fixture cases distinguish semantic boundaries:

| ID | Selected fixture and invocation | Required result |
|---|---|---|
| F-states | K18 settlement and joins, four finite rows | Distinguish known zero, missing, unknown and inapplicable. Do not accept a non-known nonzero payload. |
| F-state-range | K23 fixtures set Q raw-wait, K stop and R acknowledgement states separately to 4, then 255, with valid digests | Reject every value outside the closed four-state set. Report each atom/value assertion separately. |
| F-zero-identity | Four K18 fixtures separately zero the required root, generation, writer or pool I field, with valid digests | Reject every zero identity. Do not confuse an I field with an unknown tagged identity. |
| F-reference-kind | K9 assignment reference names K6 instead of K7 | Reject the wrong exact type despite a valid referenced checksum. |
| F-prefix-kind | K18 names a PFX as complete K9 | Reject the complete-record join. Retain the prefix separately. |
| F-reference-root | K9 references another synthetic root's valid K7 | Reject the cross-root join. |
| F-reference-length | K9 reference length differs by one from actual K7 | Reject the join. |
| F-reference-digest | K9 reference digest differs by one bit | Reject the join. |
| F-forward | K9 known reference names an unwritten object | Reject known future evidence. A declared missing expectation stays missing. |
| F-vector-max | K8 check vector at its finite declared maximum | Accept exact size and content. |
| F-vector-over | Same vector count exceeds its maximum by one, with bounded actual bytes | Reject before element allocation. |
| F-vector-short | Count says two entries, bytes contain one | Reject without reading beyond the frame. |
| F-count | O6 redundant count differs from its vector count | Reject inconsistent counts. |
| F-enum | K8 subtype code is outside its closed enum | Reject without treating it as unknown state. |
| F-profile | K1 profile digest omits the O4 wrapper or final digest | Reject the noncanonical digest. |
| F-cycle | O4 fragment map points to a frame carrying its own profile digest | Reject the bootstrap cycle. |
| F-argv | O2 contains absent environment, empty value and multibyte original bytes | Preserve all three distinctions and exact bytes. |
| F-channel | One oversized channel frame followed by another frame | Retain only accepted bounded prefix, close channel once and mark unread tail unknown. |
| F-duplicate-field | A second encoded field follows the fixed ordered payload | Reject excess fields. |
| F-order | Exchange two differently typed fields and recompute digest | Reject invalid order/types. |
| F-clock | A valid phase time carries another boot/API identity | Refuse the timing join. |
| F-status | Terminal status claims known exit and signal simultaneously | Reject the contradictory status. |

Each compound fixture case reports its named assertions separately.
An executable plan may split it into invocations, but must publish that expansion and its costs before execution.
This count measures design cases, not decoder calls.

## Recovery, protection and final paths

The following cases use the original-lock caller entry and complete synthetic setup unless their row names a setup defect.
They use audited barriers or capacity/write observations, controlled owned children, or predeclared malformed fixtures.
No live backing replacement, lock deletion, volume detach or new writer domain creates a failure.

| ID | Module, invocation and actual prefix | Control and decisive oracle |
|---|---|---|
| G-scan-gap | Caller scan, valid later K6 after an empty permitted slot | Scan the full bounded range. Never stop at the first empty slot. |
| G-torn-odd | Caller scan, odd slot contains `P` fence bytes | Refuse all new ordinals. |
| G-torn-even | Caller scan, even slot contains `P` K7 bytes with valid prior fence | Burn uncertainty. Preserve unknown assignment/charge facts. |
| G-torn-odd-header | Caller scan, odd slot contains exactly the first 376 bytes of valid K6, then zero slot padding | Refuse new ordinals. Header identity, links and digest bytes cannot establish the absent payload and end marker. |
| G-torn-even-header | Caller scan, even slot contains exactly the first 376 bytes of valid K7, with valid prior fence | Burn uncertainty. Use slot parity only to exclude a fence, never the torn header as evidence of identity, links or charge. |
| G-conflict | Caller scan, two complete conflicting fence ranges | Refuse frontier and collection. |
| G-predecessor | Caller scan, complete K6 with wrong prior-fence reference | Refuse frontier. |
| G-generation | Caller scan, complete foreign-generation frame | Reject foreign evidence and refuse recovery. |
| G-slot-copy | Caller scan, complete frame copied into another slot | Reject its physical index and identity. |
| G-gap-clean | Owner acceptance scan, unexplained non-parity gap | Refuse clean acceptance despite a valid shorter checksum chain. |
| G-parity | Owner encoder/writer, kind 6 in even slot or other kind in odd slot | Reject both predeclared fixtures. Do not infer kind from damaged bytes. |
| G-lock-identity | Caller entry, copied observation reports replacement lock identity | No K25, writes or collection. |
| G-unknown-holder | Caller entry, known child reports an unestablished inherited holder | Even apparent lock acquisition cannot permit K25 or signalling the unknown target. |
| G-holder-resolved | Caller entry after the known retained child actually exits | Acquire the original lock after holder resolution. Then permit entry once. |
| G-visibility | Caller entry, required process-loss visibility evidence unavailable | Empty slots cannot prove absence. Refuse new ordinals. |
| G-entry-order | Caller, successful failed-owner entry | Require K25, K20, K5, K20 before delayed K24/K11 or K6. Check previous/causal links and original observation times. |
| G-entry-failure | Caller, K20 after successor K5 fails before bytes | No delayed record or fence grants collection. No second entry attempt. |
| G-known-charge | Caller scan, complete K7 and partial K9 | Keep exact charge and directory. Burn through the established fence upper bound. |
| G-unknown-charge | Caller scan, valid fence with empty K7 slot | Keep old ordinary allowance unavailable without inventing a per-operation charge. |
| G-owner-collection | Owner, first collection fence after early scenario closure | Retire unused ordinary suffix without charging it. Bind one item and one new ordinal. |
| G-collection-suffix | Caller scan, item 1 complete, item 2 fenced without K7, item 3 never fenced | Retain item 1. Never repeat items 1 or 2. Item 3 and the remaining proven suffix may each run once. |
| G-collection-torn | Caller scan, partial collection K6 | Refuse the frontier and every remaining item. |
| G-normal-final | Caller, normal transfer | Burn owner and entire successor suffixes. Require K25, K20, K27, K20, K28. No successor K5 or fence. |
| G-recovery-final | Caller, transfer after collection | Burn successor suffix. Require K27, K20, K28 with no second K25. |
| G-caller-loss | End original caller after successor K5's carrier | No new generation, adopted caller or repeated collection. Preserve unavailable final tail. |
| G-final-result | Caller, K28 complete bytes with a reported flush failure under the approved observation extension | Caller must return unavailable. Readback cannot certify its later return. No second K28. Retain actual call results separately. |
| G-attachments | Owner, parity skip then failure before a selected frame | Count every skipped/failed slot's full attachment set. Never lend those objects to a later row. |
| G-history-tail | Owner, last permitted history transition | Real tail calculation refuses consuming reserved tail capacity. Stop/failure history remains available where storage works. |
| G-lane-borrow | Owner, capacity query would require successor/final slots | Refuse transition. No borrowing across writer lanes. |
| G-class-borrow | Owner, ordinary capacity insufficient while protected classes fit | Refuse before charge. Collection/terminal capacity cannot fund ordinary output. |
| G-recheck | Owner, admitted request waits while copied capacity becomes insufficient | Actual commitment recheck refuses before assignment and directory creation. |
| G-no-refund | Owner, assigned operation fails before backend creation | Full charge stays consumed. Later capacity does not refund it. |
| G-protected-tail | Caller, second collection item retains a failed raw prefix, then final K27 write fails before bytes | Preserve both failures separately. This differs from W-owner-exit's one clean collection item. Final evidence remains unavailable. |
| G-summary-failure | Owner, K29 itself fails after `P` bytes | Zero recursive K29/K20. Only independently necessary reserved failure actions may follow once. |

The header length is `16 + 64 + 16 + 32 + 144 + 64 + 8 + 32 = 376` bytes.
The schema's 384-byte framing also includes the eight-byte end marker after the payload.
The scan must check the whole frame before trusting any header field.
An indistinguishable damaged slot that could contain a fence refuses recovery. A known even slot supplies no valid K7 evidence from its torn bytes.

`S6-successor-create` extends protected-publication coverage without replacing either original S6 case.
The original caller first completes failed-owner entry and selects the first proven unattempted collection item.
Its collection-only directory-create result then fails before creation, through the same approved site as the owner case.

Keep the fresh ordinal, full collection charge and burned predecessor range. Attempt no K9, backend creation or directory recreation for that item.
Later independent items require their own proven unattempted identities. No scenario input resumes.

## Lifecycle and scheduling controls

These cases preserve the original owner and scheduling controls alongside S2–S6.
They share the common oracle, real startup and independently counted CLI invocations.
The worker uses the existing controlled sleep executable. Internal schedules use only approved copied-module barriers and clocks.
All required writes retain the applicable catalogue kinds and carriers.

Cases `L-overlap-<holder>-scenario-first` use scenario holders `OCR`, `exec` and `transfer`.
Cases `L-tick-first-<request>` use waiting scenario requests `OCR`, `exec` and `transfer`, with the capture holding ownership first.
Each request uses its family's distinct CLI arguments and result predicate, with one dispatch after the tick completes.
The former tick-first overlap names alias these precise IDs.

The owner admits one request from each producer, in the order named by the case.
Require one queued request, one dispatch per admitted request and no second worker sleep before the tick's complete disposition.
The declared CLI fixture holds its real ownership interval. No screen state changes priority.

Cases `L-capture-<phase>-<result>` use phases `CLI`, `validation`, `publication` and results `clean`, `failed`.
A scenario request arrives while a committed capture occupies that phase.
Here the waiting scenario request is a finite synthetic pointer command, distinct from the three family requests above.
Require zero scenario dispatch until capture qualification, acknowledgement, terminal publication and completion send finish.
The failed variants use CLI exit 7, invalid PNG bytes or failed K18 publication respectively.
Each failure closes eligibility instead of releasing ownership for input.

`L-overlap-validation-scenario-first` makes a tick due after the scenario CLI exits and while its real validator remains at the approved barrier.
The tick stays pending through validation, result delivery, terminal publication and completion send.
Require no tick dispatch or competing-writer refusal before that whole ownership interval ends.
Releasing ownership at scenario CLI exit must fail this case. The inverse capture-validation schedule remains separately required.

Cases `L-stop-01` through `L-stop-12` correspond, in order, to all twelve rows of the owner's
[stop race table](../../specs/settings-keepalive-owner.md#cooperative-normal-stop).
Their selected owner invocation is processing the first finish/stop at that row's phase.
Retain the phase's actual prefix, exact stop ID and existing deadline.
Check the table's cancellation, drain, acknowledgement, actual wait and publication outcome without an extra tick or shortened sleep.
The final prior-failure case keeps its latch despite a matched cooperative exit.

The additional fixed lifecycle cases are:

| ID | Selected schedule and record boundary | Decisive oracle |
|---|---|---|
| L-tie | Owner receives scenario and tick together, K8 | Scenario wins only the receive tie. |
| L-older-tick | Tick already received before scenario, K8 | Later scenario cannot overtake it. |
| L-failure-admitted | Failure after K8 admission, before final control drain | No ordinal, charge or dispatch. |
| L-failure-check | Failure at approved barrier before final commitment recheck | Recheck observes failure and refuses. |
| L-failure-committed | Failure after K9 and K20, before backend creation | Keep charge/ordinal. Suppress unstarted execution. No later scenario dispatch. |
| L-failure-offered | Failure after K16, before payload acknowledgement | Keep offered bytes and first failure. A later matching acknowledgement cannot restore eligibility. |
| L-latch | Backend latches but supplies otherwise clean K15 | Owner remains failed. |
| L-ack-missing | Result offer complete, acknowledgement channel closes before K17 | No clean K18 or later input. |
| L-ack-wrong | Wrong offer/submission/ordinal in first acknowledgement | Preserve original bytes and reject the join. |
| L-completion-missing | K18 and carrier complete, completion send fails | Payload acknowledgement grants no permission. |
| L-echo-wrong | Next frame echoes another K18 | Reject it without dispatch. |
| L-sleep-failed | Controlled sleep exits 7 while normal stop is pending | Keep failure. No clean cancellation or capture. |
| L-exit-zero | Worker exits zero without matched stop | No normal-stop success. |
| L-token | First worker frame has another role token | Close channel and refuse later ticks. |
| L-pid-reused | Copied ownership observation gives stale/reused incarnation | No signal authority or matched reap from PID equality. |
| L-finish-duplicate | Second finish after first K21 | Protocol failure without another stop ID or reset deadline. |
| L-finish-pending | Finish while a scenario submission remains queued | No normal finish or queued input dispatch. |
| L-tick-long | Tick remains pending beyond twenty seconds | No catch-up tick or second sleep. Admission still expires at its original deadline. |
| L-local-failure | Failure control while another operation holds ownership | Close eligibility immediately. Local record retains its original 22-second origin. |
| L-owner-stalled | Live owner misses advertised progress while child holds writer | Caller starts one containment window. No inferred reap or concurrent collection. |
| L-parent-loss | Worker sees parent-channel loss during sleep | Suppress ticks and settle sleep as failure. No normal stop or replacement owner. |
| L-creation-blocked | Backend creation lacks terminal observation at expiry | Uncertainty remains. No unconditional blocking wait. |
| L-term-failed | Established target remains live after failed TERM | KILL follows only within the same existing window and ownership. |
| L-kill-unresolved | No exit observed after KILL | End waits with unresolved containment. No collection. |
| L-collection-failed | First failure observer returns unavailable | Keep its failure and continue only permitted independent collection items in original order. |
| L-stop-inventory | Exact-clone stop response disagrees with independent inventory | Retain separate outcomes and block later slots. |

Cases `SIG-<signal>-<phase>` use signals `INT`, `TERM`, `HUP` and phases `CLI`, `validator`, `publication`.
The supervisor sends the signal once to its directly owned finite caller at the selected barrier.
The real forwarding and containment path retains actual statuses and prefixes, never a normal-stop acknowledgement.

Cases `SIG-direct-<signal>` instead signal the directly owned owner during the CLI phase.
Cases `SIG-group-<signal>` target only the established owned owner session/group with recorded membership.
They retain each process's actual status without inferring one process's wait from another.

Cases `LOSS-CLI`, `LOSS-validator` and `LOSS-publication` end the directly owned owner abruptly at that approved phase barrier.
They retain the actual child status and every earlier prefix.
The caller resolves inherited holders before any recovery write, without inferring grandchild reap.
No new scenario owner or worker follows.

Cases `HP-<signal>-<phase>` use the same three signals and phases `down-attempt`, `settling-sleep`.
The former interrupts the measured down invocation with uncertain delivery.
The latter follows a clean synthetic down receipt and interrupts its unchanged settling sleep.
Require possible-held input through failure collection and exact-clone containment.
The CLI transcript must contain zero release, corrective pointer, keyboard or focus commands.
Synthetic input establishes control behaviour only, never a real held pointer or native containment result.

### Deadline product

Cases `D-<boundary>-<offset>` use offsets `before`, `equal`, `after`, meaning `D-1`, `D`, `D+1` integer nanoseconds.
Each row selects the first matching phase of a fresh valid path.
All other deadlines remain unexpired unless the row tests a whole-operation or dominated outer-stop deadline.
The profile must make that schedule reachable. An impossible schedule is unavailable, never silently replaced.

Before may pass only with every other required fact. Equality and after close eligibility at the named observer.

| Boundary | Observer and selected invocation |
|---|---|
| startup | Caller, owner creation to readiness receipt |
| request | Owner, first complete submission receipt |
| admission | Owner, first K8 admission publication |
| selection | Owner, first selection through K9 publication |
| pending | Owner, pending request's original admission deadline |
| creation | Owner/backend, first backend and CLI creation phase |
| cli | Backend, first CLI exit with complete streams |
| validation | Backend, first complete validation |
| emission | Backend, first receipt/emission completion |
| backend-reap | Owner, first backend terminal wait |
| payload-ack | Owner, first complete acknowledgement |
| terminal | Owner, first K18 publication |
| completion-send | Owner, first complete completion-frame send |
| completion-receive | Submitter, first completion-frame receipt |
| whole | Owner, first operation whole deadline despite a later phase ceiling |
| progress | Owner, first backend frame's observation-plus-report deadline |
| caller-report | Caller, first missing advertised owner report |
| control-frame | Owner, first stop acknowledgement's send-to-receive limit |
| next-sleep | Worker, first sleep start after clean tick disposition |
| sleep | Worker/owner, first natural sleep and report |
| stop-intent | Owner, first finish to K21 publication |
| cancellation | Owner, first pending cancellation after stop intent |
| stop-ack | Owner, acknowledgement after current work resolves |
| worker-exit | Owner, actual worker exit after acknowledgement |
| reap-publication | Owner, K23 publication after exit |
| normal-stop | Owner, outer stop deadline with an already failed inner phase |
| local-record | Owner, evidence-class record from original failure observation |
| handoff | Owner, K26 and carrier within handoff allowance |
| handoff-receive | Caller, actual owner response receipt |
| owner-wait | Caller, actual owner reap |
| final | Caller, K28 publication within final allowance |

`D-resume` advances the copied continuous clock across the active deadline while the owner waits.
`D-wall` moves only the presentation wall-clock value backwards while continuous time reaches expiry.
`D-progress-reset` supplies timely progress without extending admission or whole deadlines.
`D-late-backend` supplies an earlier backend timestamp after its report deadline.
`D-wrong-clock` supplies another boot/API clock identity in progress.

`D-upper-path` exercises the declared 150-second older-holder path inside admission 152, without adding admission or tick service twice.
Each is one additional case. None changes the host clock or qualifies native scheduling.

The normal-stop outer deadline is deliberately larger than the reachable clean drain.
Its three cases preserve the earlier inner failure at every outer offset.
They cannot produce a clean just-before-150 result by extending a shorter phase.

Cases `CT-<boundary>` use boundaries `term-2`, `observe-7`, `kill-9`, `exit-14`, `holders-16`, `lock-18`, `end-20`.
The caller's copied clock advances to that boundary with its required fact unavailable.
Check the existing containment action or unresolved outcome, never a restarted window or invented exit.
At `end-20`, end active waits and prohibit later slots while ownership remains unresolved.

## Process overlap and later executable manifest

The design requires a phase-specific process inventory, not a count of role labels.
The separated live-operation topology has supervisor, finite caller, owner, worker, sleep child, backend, collector and intermediary/emitter: eight processes.
The intermediary execs the emitter in the same incarnation.
A declared inherited-holder child raises the possible overlap to nine.
Combining supervisor and caller reduces these counts only when the implemented subject actually does so.

During validation, a separate validator can replace the exited emitter or add another live process.
Count actual overlap and every inspector/helper, including shells and task runners that remain alive.
The topology cannot assume the six-process mechanism-study ceiling.
Thread stacks, pipes, telemetry, codec fixtures and raw originals have separate memory/storage costs.

After owner loss, the supervisor and original caller can overlap remaining worker/sleep/backend/collector/emitter/holder processes.
That retained topology is not a recovered writer.
Only positively resolved holders and original-lock acquisition permit the caller's successor role.
No successor owner or worker process is created.
Collection can overlap supervisor, caller, backend, collector and intermediary/emitter, plus each actual validator or declared helper.

Codec-only fixtures need their reader and supervisor, unless one process implements both.
Process-loss cases still account for every live setup process before the cut.
The later plan records per-case maxima, actual parentage, descriptor inheritance and bounded teardown.
The backend can reap only its direct child. An orphaned helper needs qualified independent exit evidence.
Unavailable exit evidence leaves resolved containment unavailable.

The later executable manifest must freeze all expanded IDs, implemented subjects, copied source identities, exact fixture bytes and site invocation numbers.
It binds aliases to their canonical case and counts only canonical invocations, including every assertion attached through an alias.
It must instantiate sizes, slot/object counts, tail tables, deadlines, process overlap, raw queue bounds and separately protected metadata.
It must include setup, failed carriers, full attachment reservations, collection items, final caller records and all retained partials.
An executable split adds explicit invocation counts and costs before execution.
No design case borrows an existing native or VM cap.

## Canonical cases and aliases

Each row below maps a former product label to the case that owns its complete schedule and assertions.
Run that canonical case once. Retain the alias mapping in its outcome, including a failure of any inherited assertion.
The explicit mapping, rather than a count of names, governs deduplication.

| Alias | Canonical case |
|---|---|
| W-fence-choose | S3-before-fence |
| W-fence-prefix | S3-partial-fence |
| W-fence-observed | S3-fence-before-assignment |
| W-binding-empty | S3-charge-before-binding |
| W-binding-prefix | S3-partial-binding |
| W-binding-observed | S3-binding-before-directory |
| W-commitment-choose | S3-directory-before-commitment |
| W-carrier-observed | S3-commitment-before-execution |
| W-terminal-choose | S4-result-before-disposition |
| W-reap-choose | S4-ack-before-reap |
| W-normal-final-choose | S4-handoff-before-final |
| W-terminal-fail-prefix | S6-terminal-prefix |
| G-holder-resolved | S5-inherited-holder |
| CF-commitment | W-carrier-fail-zero |
| FB-K7-retained | W-binding-fail-prefix |
| FB-K9-retained | W-commitment-fail-prefix |
| FB-K7-writer-lost | S3-partial-binding |
| FB-K9-writer-lost | W-commitment-prefix |
| A-submission-choose | W-received-choose |
| A-submission-empty | W-received-empty |
| A-recovery-choose | W-recover-choose |
| A-recovery-empty | W-recover-empty |
| A-final-choose | W-final-choose |
| A-final-empty | W-final-empty |
| G-entry-failure | CF-successor-open |
| G-summary-failure | W-write-failure-fail-prefix |
| A-bootstrap-choose | A-bootstrap-before-write |
| A-bootstrap-empty | A-bootstrap-before-write |
| L-overlap-OCR-tick-first | L-tick-first-OCR |
| L-overlap-exec-tick-first | L-tick-first-exec |
| L-overlap-transfer-tick-first | L-tick-first-transfer |

For the aliased binding/commitment prefix-loss cases, end the writer before choosing a predecessor-fallback slot.
The live fail-prefix variants retain the predecessor's fallback observation before stopping dependent work.
These cases keep the distinct K9 mandatory-carrier duty as well.
For W-send-observed, the K19 send row is complete. S4-send-before-echo instead ends before that row's slot choice.

W-owner-exit uses one clean collection item before the K27 failure. G-protected-tail retains a separate failed collection prefix.
The tick-first family cases check distinct waiting commands. L-capture-CLI-clean uses the synthetic pointer request.
No original S obligation, lifecycle schedule or scheduling duty is removed by these identities.

## Accounting, alternatives and handoff

The case count is the sum of the closed sets above. The checked inventory below records each expansion separately.
Counts identify design obligations. They do not establish that any profile can run them.
The complete workload must still reconcile useful limits and every mandatory carrier's actual lane and deadline.

| Design set | Expansion | Cases |
|---|---:|---:|
| Original S2–S6 and successor creation | Original 18 + 1 successor case | 19 |
| W publication cuts | 47 × 7, less 12 aliases | 317 |
| C publication observations | 12 targets × 7 outcomes | 84 |
| CF failed mandatory carriers | 12 targets, less 1 alias | 11 |
| CE embedded carriers | 7 named cases | 7 |
| FB failed embedded-carrier fallback | 2 × 3, less 4 aliases | 2 |
| A original objects | 3 × 7 + 6 bootstrap cuts, less 6 aliases | 21 |
| BE backend objects | 3 kinds × 2 cuts | 6 |
| E valid codecs | 29 records + 12 objects | 41 |
| M malformed codecs | 41 × 10 + 29 record end markers | 439 |
| F semantic fixtures | 22 named cases | 22 |
| G recovery and protection | 34 named labels, less 3 aliases | 31 |
| L overlaps, capture, stop and fixed lifecycle | 6 + 6 + 12 + 26 + 1 validation overlap | 51 |
| SIG signals | 9 phase cases + 3 direct + 3 group | 15 |
| LOSS abrupt owner loss | 3 phase barriers | 3 |
| HP held-pointer schedules | 3 signals × 2 phases | 6 |
| D deadlines and clock schedules | 31 boundaries × 3 offsets + 6 schedules | 99 |
| CT containment boundaries | 7 boundaries | 7 |
| **Total** | Canonical design cases, including conditional cases | **1181** |

The receipt also retains every declared alias. Aliases contribute no additional execution or resource charge.
The 72 negative C cases and G-final-result use the approved complete-write observation extension.
Namespace cases additionally depend on an applicable required namespace operation. They are not silently dropped from the conditional inventory.

The large count comes mainly from codec faults and publication cuts shared across record kinds.
Those products can share harness code, but each expanded identity retains its own outcome.
They are not native experiments or a claim about feasible elapsed time.
The later manifest cannot mark distinct canonical members passing from one representative invocation.
One canonical result can satisfy only its explicitly declared aliases and all their assertions.

The [design-check receipt](ordering-keepalive-recovery-controls/verification.json)
retains the expanded IDs, count checks, manifest checks and document-check output with before/after subject hashes.
The document task reports two existing missing k23 archive targets.
Browser checks cover both new diagrams, their outline markers and deep links.
Mobile and dark appearance remain unchecked. These checks supply no coordinator or native result.

The selected arrangement keeps publication facts and dependent-action permission in the real coordinator.
The harness supplies finite inputs and observations at the approved seams.
Replacing allocation or recovery with a simulator would reduce setup cost but would omit the behaviour these controls must check.
A single end-to-end loss case would be smaller but could not identify which missing carrier or attachment broke recovery.
The explicit products cost more fixture preparation and retained evidence, while sharing one common oracle.

The existing backend's `run_locked` still allocates from attempt directories and writes JSON receipts around its subprocess call.
That inspected path is a migration boundary, not the proposed slot/fence implementation.
Tier 2 graph discovery and its exact snippet support this narrow observation.
Its trace included unrelated name matches, which supply no evidence.
Coverage generation `2026-10-31T16:00:16Z` reported matching metadata for that source.
Full direct reads covered the existing diagrams' partial graph ranges.

Independent scoped design review and every earned integration precede consumption of this control contract.
No in-session reviewer substitutes for that scheduled review.
Whole-design review follows the complete profile, then externalised planning and implementation.
Controls execute after their implementation exists and before downstream consumption.
No coordinator control, native experiment, VM, candidate, acceptance slot or release runs during this design session.

All original duties survive: private originals, snapshot-tree/AXValue limitations, OCR-substring limits and held-frame uncertainty.
Input order, explicit waits, poll counts, single attempts, historical failures and closed causal slots remain unchanged.
Missing mechanisms keep startup unavailable. This slice closes no ancestor.
