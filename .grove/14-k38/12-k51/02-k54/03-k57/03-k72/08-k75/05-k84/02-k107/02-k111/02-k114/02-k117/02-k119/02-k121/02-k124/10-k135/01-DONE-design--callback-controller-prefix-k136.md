# callback-controller-prefix-k136

## Goal
Make executed controller prefixes and per-peer FIFO checkable before success
or abort classification, as a versioned executable diagnostic slice.

## Context
k134's reproduction and unchanged v3 analyzer/generator are the baseline.
Reuse Trace local/message/event edges; parent k135 retains the complete repair.

## Done when
- Version beyond v3; preserve all v1/v2/v3 canonical bytes and raw reports.
- Check allowed posts and B/trigger/C barriers on success and abort prefixes,
  including partial finish, allowed messages and cleanup sequencing.
- Reject false/missing/early active-reply producers as malformed. Check per-peer
  FIFO from sends and receives, including abort drain traffic.
- Falsify premature/unlisted/ordinary-C posts followed by abort, reversed receipts
  and malformed active replies. Preserve legal inter-peer permutations, pending
  activation/receipt timeouts and partial finish reuse.
- Renew the complete corpus with itemwise preservation and frozen input maps;
  update contracts, assessment, view and native handoff with exact limits.

## Notes
This slice leaves unexpressed waits, sampler lifecycle/cancellation, notification
object scope, numeric marker encoding and abort-hidden candidate evidence to k137
and k138. No native readiness or parent completion. Final producer commissions
fresh tree review before k126. Rendering/viewing uses a disposable clone.

## Decisions (running log)

- Use v4 for the executable prefix slice, preserving earlier meanings. Local
  controller replay enforces request/reply/post prerequisites; per-peer FIFO
  compares local message subsequences and Trace remains the causal engine.
  Reports explicitly say controller-prefix-only and native_protocol_ready=false.
- Keep malformed executed prefixes and active producers at exit 3 even when
  followed by an environmental abort. Preserve late truthful replies and partial
  finish reuse. The red controls exposed the old exit-2 classifications before
  the checks were added. A later source review exposed non-controller exchanges
  escaping replay; eight failing controls reproduced it before the endpoint guard.
- Scope this slice to structurally complete, fault-free paired traces. k138 must
  settle incomplete/fault-path precedence and every remaining wait; k137 must
  preserve candidate evidence independently. Existing sampler histories are
  labelled controller projections, not honest complete producer executions.
- Use the falsified executable transcript seam for these behavioral claims;
  no in-session reader is commissioned. The final k138 artifact still earns its
  mandatory fresh tree review before native use. Neither the code nor rendered
  views establish native coverage, producer truth or capture feasibility.
- Final check: 837 controls match, including 296 new v4 controls; 839 tests,
  Ruff and strict Pyright pass. All 541 legacy raw reports and 1,082 canonical
  files match itemwise; all 1,687 final measured subjects still match after the
  run. Assessment and evidence live under docs/verification, with k136 maps.
  Both presentation clones were removed. k137/k138 remain live, so this
  retirement closes only k136 and no parent node.
