# ax-endpoint-effects-k61 — brief


## Goal
Establish a complete native desktop path through the retained AX endpoint,
including its ownership and process-transition semantics, or deliver the
evidenced feasibility conflict and recommendation required by k59 and k56.



## Context
- Read `docs/verification/direct-ax-endpoint.md`, its raw code scans and review
  reconciliation. Treat that review as input to evaluate, not this leaf's
  charter. Parent criteria and the capture ADR are the contract.
- Signed/hardened macOS 26.5 probes established that an AX port stayed dead
  across actual PID 773 reuse, and a fresh header-only unknown-ID reply carried
  a kernel audit trailer matching retained live task 843. Wrong-task and
  post-death controls rejected. Neither probe sent a direct AX effect.
- Local HIServices inspection found private `_AXMIGCopyAttributeValue`,
  `_AXMIGSetAttributeValue`, `_AXMIGPerformAction`, `getClientPortFromCache`,
  `clientSerializeWrapper` and `_axIPCRequester` code behind public wrappers.
  The stubs/cache helpers are not `dlsym` exports. Scans retain exact branch
  destinations and offsets; no inferred stub signature was called or approved.
- `_AXUIElementRegisterServerWithRunLoop` calls `MSHCreateMIGServerSource` with
  zero port/options in the inspected branch. Its actual creation, registration,
  destruction and any forwarding behavior require source/disassembly and native
  evidence; historical CF/launchd analogies alone are insufficient.
- Tier 2 generation `2026-09-21T12:08:52Z`: provider source coverage matched
  with no recorded gaps; exact `act` and `hasFocus` still use held-window effects
  and fresh PID-created application operations. Refresh graph and coverage.
  Final generation `2026-09-21T12:37:47Z` reports full-body parse gaps in
  endpoint-probe.m (1–86) and endpoint-challenge.m (1–90); both were read directly
  in full. Do not infer their complete behavior from graph symbols.

## Done when
- Define and exercise one actual protocol for read, restore, main selection,
  raise, activation and focus confirmation through the retained endpoint. No
  PID reconstruction/relookup fallback may stand in for effect binding.
- Establish the endpoint's actual receiver ownership and teardown/transfer/
  recovery behavior, including death after admission or between steps, actual
  PID reuse, exec and automatic restoration. Keep evidence bounded by the
  tested platform; generic Mach-port properties alone do not prove AX lifetime.
- Complete the acquisition/attribution rule: a fresh reply followed by retained
  live-task comparison is a tested server-side candidate, not event-handler
  attribution. Confirm a harmless exchange for the supported protocol; do not
  assume the diagnostic's unknown ID can never acquire meaning. Specify refusal
  and every ordering assumption without treating pidversion as permanent identity.
- For a viable route, establish signed/hardened availability, relevant denial
  behavior, resource/ownership rules, consent attribution and realistic version
  maintenance costs sufficient to recommend it. Preserve public client APIs,
  strict process lifetime and arbitrary unmodified targets; no injection,
  privileged helper or new client consent is implicitly authorized.
- Reconcile existing evidence, capture ADR and visual discussion. Supply k57
  with the complete all-effects binding to agree with the human, or present the
  precise conflict, recommendation, alternatives and reversal evidence. The
  original k59/k56 completion criteria continue to bind; do not silently relax
  them, publish schema changes, or start k52 implementation.

## Notes
Use TestAnyware for every native/GUI execution; build on host only. Reuse
`task fixture:ax-endpoint`, `fixture:ax-challenge`, and `fixture:ax-inspector`
for their distinct instruments; rerunning their narrow successes does not
establish an effect protocol. `task design:render-process-identity` includes the
new direct-endpoint view at `http://127.0.0.1:8772/#diagram-process-endpoint`.

## Decomposition

Actual effect transport now has an independently verifiable result. Receiver
transitions and admission/policy still require different native instruments;
the original criteria above remain this node's completion contract.

1. `ax-direct-effect-transport-k62` — preserve the successful direct read/effect/
   confirmation path, independent witness, post-death refusal and bounded ABI.
2. `ax-endpoint-lifetime-and-admission-k63` — settle the remaining lifetime,
   admission, policy and maintenance evidence, then provide the full feasibility
   result for k57 or the evidenced conflict for the human.

## Decisions (running log)

- Test the read/set/action MIG boundary directly with one retained server port.
  Internal entry points are diagnostic-only, selected from inspected branch
  destinations and checked against this guest's code; they are not an approved
  shipping ABI. Preserve serialization separately from effect dispatch and
  never refresh a target endpoint after admission.
- Use the leaf's one fresh-context reviewer for actual AX receiver ownership
  and forwarding paths against primary platform sources, while native protocol
  work runs in TestAnyware clone `koine-k61-effects`. A formal model cannot
  establish the missing closed-platform lifetime premise.
- The signed/hardened direct-stub diagnostic completed at PID 788 with every
  required effect and same-endpoint focus confirmation successful. A separate
  public-AX/NSWorkspace witness observed the state changes; a post-death write
  failed. The first exploratory execution returned a TestAnyware timeout despite
  final records, so only the subsequent explicit exit-0 run is completion
  evidence. Before/after input and guest digests match.
- Split at this demonstrated transport boundary. Keep receiver transitions,
  a harmless audited admission exchange, policy attribution and adoption costs
  as live work; neither this positive result nor the review supplies the full
  arbitrary-target lifetime guarantee. No product or schema change is made.
