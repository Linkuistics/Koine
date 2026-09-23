# callback-sample-witness-k107 — brief


## Goal

Establish or falsify a fresh public foreground sample inside the held task
identity's liveness bracket, with independently witnessed callback ordering.



## Context

Start at `docs/verification/callback-capture-transfer.md`, the sampling section
and witness matrix. Lead 3's pre-held task-name rights remain a candidate, not
evidence. NSRunningApplication's run-loop policy does not by itself prove the
implementation or freshness of NSWorkspace.frontmostApplication. Compare the
public GetFrontProcess/GetProcessPID lead without using PSN as identity.

## Done when

- Identify the exact public source and actual sample point on the supported
  platform, including its thread/run-loop behavior and any logical-app-to-PID
  mapping. Show the sample is inside acquisition-to-postcheck ownership; state
  what primary evidence supplies and what the fixture only observes.
- Freeze the fixture, native dependencies and schedule before execution; run
  only in a disposable TestAnyware clone. A separate witness must establish
  foreground and acquisition/callback order, not merely repeat the sampled API.
- Exercise ordinary live capture, callback delayed across an app switch,
  switching after the sample, death and exec around sampling, stale source data,
  null/dead acquisition and policy refusal. Establish actual PID recycling for
  the naive sample-then-acquire negative control; label any injected mismatch
  separately. Reuse the restoration evidence only within its recorded scope;
  witness capture expiry on an actual successor when claiming that schedule.
- Compare pre-held candidate rights with a bounded acquire-then-fresh-resample
  construction. Refuse missing/ambiguous candidates without changing callback
  targeting or silently sampling later at Koine. Do not claim refusal-only runs
  as successful capture. Preserve a live captured target across a later switch.
- Record source digests, raw outcomes, independent witnesses, failure controls
  and limitations in the existing capture assessment; update its view. Name any
  ModalAnyware foreground-source migration independently from identity and IPC
  changes in the Koine-side owner note; do not edit ModalAnyware.

A remaining concrete feasibility conflict is escalated with a recommendation;
it is not a completed positive construction or permission to weaken freshness.

## Notes

No transfer implementation, AX operation or broader API survey here. If an exact
native discriminator outgrows this leaf, decompose it before running it. Keep
unmet k84 criteria live; final protocol adoption belongs to k87.

## Decisions (running log)

- The existing serial probe samples before acquiring and immediately releases
  its rights; its restoration app supplies lifecycle evidence but no independent
  callback/foreground witness. The native work needs two distinct discriminators:
  source freshness under withheld run-loop delivery, then lifetime attribution
  under death/exec/recycling. Decompose before execution. The first child fixes
  the causal witness protocol and its falsification criteria; later children
  execute the sampling and lifetime schedules. Preserve every original Done when
  in this node and do not turn the experiment design into a positive native result.

## Decomposition

| Child | Independently checkable result |
|---|---|
| callback-witness-design-k110 | Exact causal witness protocol, separated foreground/mapping observations, failure controls, frozen-input rules and limits in the capture assessment. No native feasibility claim. |
| callback-source-freshness-k111 | Loaded public source/mapping inspection and isolated native live/delayed/switched/run-loop cases, comparing both constructions with independent input witnesses. |
| callback-lifetime-attribution-k112 | Death, invalidating exec, actual reuse/restoration and acquisition/policy/ownership cases; reconcile all original criteria and the client-source handoff. |

The first child is design work completed in the decomposing session. The next
children perform the diagnostic experiments as design evidence, not shipping
implementation. k111 first establishes whether there is a usable source to
carry into k112; a failed premise is an evidenced conflict to surface, not a
reason to call this node complete or quietly drop its later obligations.
Every original Done when above remains binding. k84 keeps transfer/admission
and resident protocol work in k108/k109; k87 owns final adoption and k52 the
existing implementation. No new public seam or production implementation leaf.

The source-freshness work in k111 now separates loaded-entry inspection (k113),
the causal fixture and failure controls (k114), and native schedules (k115).
k113 identifies concrete AppKit/LaunchServices paths and unresolved producer/
mapping boundaries; it does not establish a usable fresh source. k112 retains
every lifetime, actual reuse/restoration, acquisition and policy obligation.
