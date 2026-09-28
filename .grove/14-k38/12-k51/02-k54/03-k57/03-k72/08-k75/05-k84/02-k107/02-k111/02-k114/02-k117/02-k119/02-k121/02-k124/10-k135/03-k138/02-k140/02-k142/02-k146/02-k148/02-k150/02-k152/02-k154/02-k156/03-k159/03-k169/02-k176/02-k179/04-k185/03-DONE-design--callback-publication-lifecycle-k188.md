# callback-publication-lifecycle-k188

## Goal
Complete publication milestones and post-loss lifecycle for the chosen transport.

## Context
Consume k186 lanes, k187 evidence rules and all versioned producer contracts.
K183 findings 7/8 remain design decisions, not k182 implementation discretion.

## Done when
- Enumerate every existing send/publication/drain obligation from the full
  versioned producer contracts and map it explicitly to commit, local completion
  or receiver observation at original coordinates. Include returned/failure
  before host_end, reached publications before terminal response, late ready/
  armed/failure/completion drains, actual replies/input before exit commands,
  startup, armed/selected and continuation cancellation paths.
- Specify outstanding-call immutable-buffer ownership, abandonment, later full/
  short/error return, local completion versus permanent direction loss, queued
  versus newly committed frames after loss, and deadline-stopped reassembly with
  buffered bytes but no EOF/error. Preserve all pending native/object/right work.
- Specify honest app/supervisor/host bounding; requests prove no return, cleanup
  or actual exit. K144 still assigns numeric bounds/reserve; k180 phase recovery.
- Supply exact discriminating histories and independent expected outcomes for
  late results, abandoned calls, stopped readers, queued/new commits and each
  milestone. Reconcile both contracts/assessment/state views, rendering and
  inspecting changed views only in a disposable clone.
- Preserve V1–V26; hand exact row/attempt requirements to k189. No executable
  version, full corpus or native readiness claim; k182 retains those duties.

## Notes
Design only. Use the existing Trace seam. No new public seam, permission change
or native readiness. K126 retains all native exits/containment and original
k124/k121 obligations. K177/k144 retain full sampler/protocol work.

## Decisions (running log)

- Keep three milestones at the existing Trace seam: semantic send is immutable
  commit; synchronous sender progress requires local write completion; remote
  protocol progress and drains require the actual validated local receipt.
  Preserve original producer coordinates through k186's one-to-one map. A lost
  publication leaves its success milestone unmet; explicit loss continuation
  may perform reached cleanup without claiming that milestone or native return.
- Direction seals are permanent even if an outstanding call later accepts the
  full frame. Keep its buffer until actual return or externally established
  termination. A trusted late full result may establish local completion while
  direction loss remains; a short/error result leaves an unsent suffix forever.
  Previously queued and newly required cleanup/publication commits remain
  attributable records with no new begins after loss. Do not issue new useful
  protocol work, reconnect or replay them.
- A deadline stop of reassembly is a local observation boundary, not EOF or
  sender closure. Preserve exact buffered bytes and the next ordinal; bytes
  alone cannot create an undispatched receipt. A blocked read cannot report a
  safe stopped-reader boundary without reaching it. App, supervisor and host
  bounds retain separate observation and recovery obligations.
- Use contract histories at the existing immutable transcript seam; no new
  formal model or causal engine. K189 already owns the complete transport's
  fresh tree review, so this producer adds no competing in-session reviewer.
  K182 retains executable versioning and full corpus renewal, k180 phase
  composition, k144 numeric budgets/reserve and k126 native evidence.
- A pending-call seal must be observed in its writer owner's lane. The
  supervisor's existing independent contexts can seal egress during a pending
  write; an external request cannot fabricate an app-lane seal while that app's
  only synchronous context is blocked. Keep that app prefix pending/unsealed
  until an actual permitted observation. No new app reader/callout is introduced.
