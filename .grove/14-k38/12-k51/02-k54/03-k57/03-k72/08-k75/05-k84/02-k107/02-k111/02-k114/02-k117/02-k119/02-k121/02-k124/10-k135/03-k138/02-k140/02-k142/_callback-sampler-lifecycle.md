# callback-sampler-lifecycle-k142 — brief

## Goal
Specify and falsify the sampler producer from host callout through armed
cancellation, callback completion and ownership cleanup.

## Context
Read the full k140/k138/k135 charters, k141 encoding and current contracts.
Preserve all prior versions and reuse Trace. Diagnostic design only.

## Done when
- Define host callout, baseline nesting, invocation lifetime, socket/tap/timer
  modes, measured thread/main/mode/turn encoding and ignored queued B delivery.
- Produce returned only after its matching call returns. Define/falsify real
  invocation timeout, disabled/repeated tap, native call/ownership failures,
  nesting/reentry, armed cancellation and abort delivery after in-flight work.
- Derive executable local paths and causal transcripts for both constructions,
  pairs and schedules. Post-return work is unconditional once reached; later
  controller abort cannot erase required completion/return messages.
- Version changes, renew/falsify controls, preserve independent evidence and
  earlier bytes/reports; keep native audit and private-loop coverage separate.
- Reconcile contracts/views/assessment and give k144 the sampler transition
  interface, bounded failure paths and exact remaining limits.

## Notes
No complete protocol/native claim. Composed waits, deadline policy, target
interaction, partial evidence and final fresh review stay k144; targets k143.

## Decisions (running log)

- Use a versioned local sampler projection at the existing immutable-transcript
  seam, with the existing Trace graph for causal edges. A serialized main-thread
  driver owns one explicit dedicated-mode run invocation. Socket cancellation
  and a finite invocation deadline are serviced in that mode; callback/native
  work is synchronous and cannot be interrupted by a same-thread timer. A
  blocked call is an externally bounded incomplete attempt. Keep framework-private
  coverage independent; this design does not supply its missing mechanism.
- Separate sampler conformance, reached candidate evidence and controller/target
  composition. Ordinary post-return validation, releases and sample-complete
  form an unconditional continuation; after-callback always sends its return
  message before waiting for retention-release or cancellation. Later abort
  cannot erase work already executed or queued. K144 retains the complete
  controller/target composition, deadline precedence and partial-evidence policy.

- Split at the local loop boundary: k145 makes the host/invocation/cancellation
  projection executable; k146 completes native-operation/ownership failures and
  honest late-abort executions. The latter reconciles every original Done when
  above and hands the complete sampler transition interface to k144. No original
  criterion is waived and this node stays live after k145.
- K145's v8 corpus contains 60 local-loop controls; the frozen full run matches
  1,704 cases and preserves all 1,644 earlier report records. Evidence and limits
  are in `docs/verification/callback-native-capture/evidence/k145/` and the v8
  assessment. The controller rejection of local cancellation/timeout examples is
  intentional, not a complete abort producer for k146 to inherit as success.

## Decomposition

- callback-sampler-loop-k145: versioned observed loop boundary and falsification,
  independent of native sampling/ownership failure truth.
- callback-sampler-operations-k146: complete local operation/ownership/failure
  producer, all original k142 criteria and final sampler handoff to k144.
