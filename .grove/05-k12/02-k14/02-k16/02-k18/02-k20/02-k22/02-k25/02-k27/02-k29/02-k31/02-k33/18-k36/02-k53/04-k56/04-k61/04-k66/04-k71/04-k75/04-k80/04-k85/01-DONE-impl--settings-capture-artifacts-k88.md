# settings-capture-artifacts-k88

## Goal
Supply source-only checked screenshot and background keepalive helpers sharing
the existing writer, ordinal and sticky failure domain.

## Context
Read the k85/k80/k75/k71/k66 charters, current reviewed adapter/UI/click/physical/
input/window reports and ORDERING-EVALUATION-PLAN.md. K87 integrated k86.

## Done when
Enumerate actual capture schemas/callers, including failure and background
keepalive. Retain raw response/status and unique complete readable image bytes
with path/dimensions/digest before releasing the writer lock. Refuse overwritten,
missing, truncated or mismatched artifacts; no constant predicate or retry.
Preserve the existing logical full/region captures and twenty-second keepalive
cadence; stop/latch on every capture failure. Show pre-repair failing controls
and passing reusable Taskfile checks. Cut independent review and every earned
integration before k89/k81/k76 consumption. No ordinary caller/root adoption,
VM/candidate/freeze/acceptance or ancestor closure. K89 retains every remaining
k85 duty; all inherited criteria, native availability limits and private roots
remain binding.

## Decisions (running log)

- 2026-10-29: Use the existing backend lock for capture payload AND artifact
  qualification, avoiding a shell check after lock release. The backend reserves
  an exclusive ordinal directory and chooses its absolute screen.png path;
  callers cannot override output/endpoint/physical mode. Require the tagged
  encoder's noninterlaced RGBA8 PNG, all chunk CRCs, a complete zlib pixel stream,
  expected row sizes/filter codes, no trailing data and dimensions matching the
  response (and requested region). This checks readability, not visual truth or
  freshness of native pixels. No new runtime dependency is needed.

## Implementation plan

1. Add Bats controls for raw bytes/argv/unique full and region images, malformed
   payload/artifacts, sticky collection, shared concurrency and keepalive failures.
   Run them against test-only direct legacy capture/keepalive routes and retain
   each result and before/after subject digests.
2. Extend vm-guest-exec.py with a capture entry point and small PNG validator;
   validate before successful emission/terminal receipt while holding its lock.
   Add source-only shell helpers and the existing twenty-second loop, returning
   all nonzero statuses without another tick. Ordinary callers remain unchanged.
3. Add check:vm-capture-evidence, verify it and all existing adapter consumers,
   retain stable-input receipts, official-source hashes and a bounded caller
   inventory. Document native/source/signal/concurrency limits and all handoffs.
4. Cut the earned independent review before consumption, retire k88, name the
   finishing attempt's provider evidence and seal the focused jj change. K85
   remains open with k89 and the review live.

- 2026-10-29: Initial ten controls fail against the test-only bare capture and
  ignored-failure keepalive paths, then pass with the checked helper. Expanded
  controls add a post-CLI artifact-inspection lock barrier and SIGINT. Fix two
  test-harness assumptions: direct importlib loading needs the script directory
  for its sibling dependency; relative-root assertions need macOS's physical cwd.
  Production capture behavior is unchanged by those test corrections. Original
  red receipts remain intact. Final verification includes the previously omitted
  saved timeout fixture. A whole-artifact independent review is earned; schedule
  it before k89/k81/k76 consumption and use no in-session reviewer.

- 2026-10-29: Final nine Taskfile checks pass all 166 named controls, with
  unchanged before/after subjects and verified output digests. Final subjects
  include the actual saved timeout fixture and historical PNG. Full documentation
  measurement covers all checker source/anchor inputs and target availability;
  only the two existing k23 archive links fail. No ADR is earned: this reversible
  helper expansion changes no durable product decision. No ordinary caller/root,
  VM/candidate/freeze/acceptance or ancestor closes. Retire k88 only; k85 remains
  open with independent review and k89. No in-session reviewer was used.
