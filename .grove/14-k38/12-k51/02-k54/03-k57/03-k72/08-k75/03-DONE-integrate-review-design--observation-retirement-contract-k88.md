# observation-retirement-contract-k88

**Integrates:** observation-retirement-contract-k82

## Goal

Triage k82's review of k81's observation/retirement proposal. Before k83
freezes its native discriminator, apply the valid findings to the proposal,
its reference-lifetime view and k83's charter.

## Context

- The findings are in k82's own task file. Their line references are to k81's
  commit `f1eaa51`. Read them together with that artifact, k80's agreement
  record and k75's unabridged Done when.
- The human agreed only to observed-closure retirement for *effects*.
  Undetected closure may target another window. Do not infer a read-attribution
  relaxation from that (k82 finding 2). Where the extent of the agreement is
  unclear, take the concrete trade-off to the human, framed as
  `references/execute.md` directs, or state it as an explicit agreement item for
  k87.
- The proposal stays labelled. No native feasibility, shipping mechanism,
  public schema, application-support restriction or parent completion follows
  from the integration.

## Done when

- Classify every k82 finding in this file's running log as one of: valid and
  applied, unclear contract and settled or explicitly routed, visible accepted
  trade-off, or rejected with a reason.
- The spec subsection, `process-observation` view/caption, README and glossary
  (where it is touched) agree on these points:
  - how observation loss is detected, or the consequences if it cannot be;
  - the status of read attribution under undetected reuse;
  - the reply–notification delivery-order premise and the candidate
    registration orders;
  - bounded send initiation and the classification of each send outcome;
  - split `Preparing` outcomes;
  - discard versus withdrawal keyed on source authentication, with refusal
    granularity and recovery;
  - reason retention after reclamation and allocator scope;
  - the meaning of "retire".
- k83's frozen discriminator and controls include loss/suppressed delivery, the
  cross-channel ordering premise and the send-outcome evidence the integration
  assigns it. k87 names every new agreement item, including any
  read-attribution consequence and the refusal support consequence. Every k75
  obligation keeps a live owner, and no parent closes.

## Notes

One narrow in-session reviewer is allowed. Substantial redesign found here is
externalized as a new producer review chain beside this leaf, not absorbed.
Anything that renders or inspects the architecture viewer runs in a disposable
TestAnyware clone, never on the host.

## Decisions (running log)

- Findings 1 and 3: valid contract omissions. Require evidence for completeness
  or detectable loss and for cross-channel publication ordering. Name both
  registration orders and their distinct gaps. k83 must discriminate suppressed
  and saturated delivery, delayed closure versus later replies, and reuse during
  registration. Silence is not evidence of intact observation; without the
  necessary premises dependent operations refuse. This is not a native result.
- Finding 2: unclear contract, explicitly routed to k87. k80 permits effects
  after undetected reuse, not replacement-window reads under an old reference.
  Preserve lifetime attribution for CURRENT, REMEMBERED and confirmation; k83
  must evidence it independently of sender identity. If infeasible, k87 must
  present the concrete read consequence for explicit agreement before adoption.
- Finding 4: valid omission. Specify bounded, nonblocking send initiation in
  the owner; no unchecked worker handoff. Distinguish proven not-enqueued,
  enqueued and ambiguous results, including earlier possible sends. Choose a
  bounded ingress cut before dispatch; inability to validate it refuses dispatch.
  Events arriving after the cut may race the send. k83 evidences native result
  meanings; k86 owns maintained bounds and k87 the visible boundary agreement.
- Finding 5: valid inconsistency. Split preparation into authenticated closure
  (unpublished ClosedBeforePublication) versus failure/capture end (Failed,
  affected listing unavailable). No missing-provenance silent omission.
- Finding 6: valid ambiguity. Discard unauthenticated/foreign/obsolete input;
  authenticated but unattributable current-registration input withdraws that
  registration's records. State window/registration/capture scope, whole-listing
  refusal and recovery by a new evidenced registration under the same live
  capture when possible. k87 must assess concrete behavioral support losses.
- Finding 7: valid contradiction. Retain specific reasons only while bounded
  records exist; after reclamation old identifiers remain unavailable without
  invented reason detail. Propose an allocator per provider run, shared across
  captures; k86 bounds churn/exhaustion, k84/k87 still owe cross-run non-collision.
- Finding 8: valid terminology inconsistency. Reserve Retired/retirement for
  authenticated window closure; death/exec ends a capture and withdraws its
  published records. No additional ADR or redesign is needed: clarify the
  current effect ADR and repair the labelled proposal in place.

## Integration and verification

Findings 1 and 3–8 are valid and applied; finding 2 is an unclear contract
explicitly routed to k87, with strict read attribution preserved until then.
The spec, effect ADR, glossary, view/source/export, manifest summary/caption and
README are reconciled. Individual authenticated closure can retire a reference
even when stream completeness is unknown; completeness qualifies dependent
reads, not the truth of an already attributed closure. k83's pre-probe
discriminator now includes the missing premises and controls; k86 owns bounded
resource/send policy; k87 names the read, support, scheduling and reclamation
agreement items. No producer redesign or in-session reviewer was needed.

`task design:render-process-identity` passed in disposable TestAnyware clone
`koine-k88-design`, using PlantUML 1.2026.8 with Smetana and an arm64 Java runtime.
Only the changed observation SVG was copied back. Its full PNG, Safari fresh
observation/discussion deep links, outline and Current/Updated markers were
inspected in desktop light appearance. No mobile/dark or native-binding
acceptance is claimed. The clone was stopped.

Changed Markdown relative paths/heading anchors and viewer manifest IDs/paths
passed validation; deliberately missing path, anchor and discussion-ID controls
failed as expected. The validation script, changed document list, documents,
link targets and k52 comparison inputs were hashed before/after and stable.
Viewer, manifest, observation source and SVG hashes matched host/guest;
HTTP-delivered manifest/SVG bytes matched and guest subjects stayed stable.
Read-only `git diff --check` passed. k52's evidence table is unchanged; no
production source or served schema changed, so no production test rerun applies.

Tier 2 project `Users-antony-Development-Koine` was ready. Coverage generation
`2026-09-23T09:22:43Z` reported matching metadata and no recorded gaps for the
Markdown/manifest, Taskfile, viewer and task/brief evidence paths. PlantUML was
untracked by the graph and SVG excluded; direct source and rendered inspection
cover them. This is best-effort coverage, not completeness proof; the findings
were derived from committed design text, not structural-code graph claims.

k75's unabridged obligations retain owners: k83 observation, k84 callback and
transfer, k85 lifecycle, k86 consent/adapter limits, k87 full protocol/restarts/
version agreement, reconciliation and every k52 renewal instruction. k75 and
k72/k57/k54/k51 remain live. Only k88 retires; no ancestor cascade closes.
