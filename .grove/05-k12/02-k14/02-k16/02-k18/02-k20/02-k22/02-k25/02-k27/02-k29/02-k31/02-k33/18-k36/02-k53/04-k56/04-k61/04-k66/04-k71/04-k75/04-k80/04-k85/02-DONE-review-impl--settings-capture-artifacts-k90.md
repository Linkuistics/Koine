# settings-capture-artifacts-k90

**Reviews:** settings-capture-artifacts-k88

## Goal
Independently review the complete capture/keepalive artifact against every
inherited k85/k80/k75/k71/k66 contract before k89/k81/k76 consumption.

## Context
Find the producer commit by settings-capture-artifacts-k88. Read its whole diff,
ORDERING-CAPTURE-RESULTS.md, retained evidence and complete ancestor charters;
consume the current reviewed shared/physical/window/input/snapshot/click reports
and ordering protocol. The complete scenario has not adopted this source-only
interface. No in-session reviewer ran. No VM/candidate/freeze exists.

## Done when
Find substantive defects in the artifact and controls, re-deriving actual
capture fields/encoder shape from the lock-pinned official source. Check unique
artifact paths, complete readable bytes/dimensions/digests, malformed/partial/
failed transports and output delivery; shared lock/latch/ordinal ownership
through payload AND image validation/publication; exact cadence and failure
stops in the background loop; concurrency and signal/partial-record limits.
Check every actual bounded caller, original input/wait/poll preservation,
receipt provenance, meaningful pre-repair failures, final per-test results and
all availability/privacy/downstream duties. Pay particular attention to the
narrow PNG validator's acceptance/rejection boundary and the tests' independent
ability to disprove its claims, and to what background ownership still requires
at adoption. Report concrete findings with source evidence, not fixes or native
acceptance. Every earned integration must precede k89/k81/k76; insert it before
this directory's next live sibling. No guest or ancestor closure.

## Notes
K89 retains file/environment/lifecycle/collection helpers; k81 every exec and
one-shot consequence, k76 complete root/caller adoption and signal handling with
both held-pointer cases, k67/k62/k57/k54 all original duties. Missing trees,
empty AXValue, OCR substring stopping, capture held-frame fallback and private
secret-bearing roots remain explicit limits. Preserve historical red receipts
and every failed transport, classification, closed cap and held runtime slot.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k88 commit 07d632b7 and its whole diff. Read the capture report, its
  receipts, the shared adapter and the legacy keepalive. The working tree
  equals the commit for every reviewed path. Run no test, build, lint, format
  or VM command. Graph tools were not used. Every conclusion below rests on
  direct source reads.
- 2026-10-29: Re-derive the capture contract from the local TestAnyware
  commit 65bc05c9 (tag v2.7.0). The `screen.rs` digest matches the receipt.
  The handler writes `encode_png(&fb, crop)` and returns top-level `path`,
  `width = crop.2` and `height = crop.3` (`screen.rs:96-131`). A region past
  the frame is a nonzero `INTERNAL` error (`capture.rs:129-135`). The three
  registry digests match. The png 0.18.1 writer splits image data only at
  `u32::MAX >> 1` bytes (`encoder.rs:737,888`). One IDAT chunk is therefore
  the realistic shape. The retained 1920x1080 image has IHDR, one IDAT and
  IEND, with row filters 1, 2, 3 and 4 only. A read-only byte inspection of
  `persisted-01/failure-observed.png` shows this.
- 2026-10-29: These claims hold against the code. Payload and image checks
  run inside `run_locked` under the inherited lock descriptor. A failed
  image check latches and writes no `artifact.json`. Stdout follows the
  check. The keepalive cadence is sleep-then-capture with no leading capture.
  The bounded caller inventory matches the menu-bar scenario closure.
- 2026-10-29: F1 and F2 need a decision before k76 adopts the helpers. F3 to
  F5 are narrower. Insert the integration before k89, which is the first
  later live sibling of this review.

## Findings

Severity: P1 means that adoption as handed off cannot meet an existing
duty. P2 means a defect in a strict guarantee that k76, k57 or the
evaluation stop rule would rely on. P3 means a narrower defect, a retention
gap or a control gap.

Line numbers refer to commit 07d632b7.

"The adapter" is `scripts/vm-guest-exec.py`. "The validator" is `scripts/vm_capture_artifact.py`.
"The library" is `scripts/vm-capture-evidence-lib.sh`. "Bats" is
`Tests/scripts/vm-capture-evidence.bats`. "The fixture" is
`Tests/scripts/fixtures/capture-cli.py`. "The report" is
`docs/verification/settings-activation/ORDERING-CAPTURE-RESULTS.md`.

### P1-1. The keepalive under the nonblocking shared lock cannot keep the VNC server alive

The legacy keepalive exists for one reason. Virtualization.framework's VNC
server asserts and takes tart and the guest down when a client connects
after about 60 seconds with none (`scripts/vm-verify-lib.sh:321-326`).

The new loop takes the shared writer lock with `LOCK_EX | LOCK_NB` (adapter
`:434`). A held lock refuses the tick, latches the root and returns 125. The
loop then stops with no further tick (library `:37`). The report accepts this
and tells k76 to "preserve that consequence on adoption" (report `:90-92`).

A tick lands inside any locked dispatch that lasts longer than about 20
seconds. The reviewed Allow read is one such dispatch. It runs
`screen find-text --timeout 30` as one `read-poll` CLI call under the lock
(`scripts/vm-click-evidence-lib.sh:32`). Shorter dispatches collide with a
probability equal to the fraction of time that the scenario holds the lock.
The keepalive's own capture can also refuse the next scenario action. The
pinned capture can wait five seconds for a readable frame, per the report.

Failure scenario: the Automation prompt appears after 25 seconds. The
keepalive tick at 20 seconds refuses and latches. The run is unavailable,
although the scenario read was clean. In every collision the keepalive
stops for the rest of the run. The protection against the VZ idle crash is
then gone. The legacy loop ignores failures and keeps that protection.

The single-writer requirement is inherited (`ORDERING-PHYSICAL-RESULTS.md:147`).
The report states the availability cost, but it does not show that a real
run can complete under it. No control or estimate covers long dispatches.
The integration must decide how the keepalive and the scenario share the
domain before k76 adopts it, or escalate that decision. Examples are a
serialised wait for the keepalive alone, or a keepalive record that does not
latch scenario eligibility. Each changes a reviewed design rule.

### P2-1. The generic CLI route still accepts unchecked captures

The new guarantees hold only for `capture_guest_evidence`. The `cli` action
still sends `screen capture` with a caller-chosen `-o` path and a
caller-supplied predicate. `cli_argv` admits every `screen` action for the
`read-poll` and `one-shot` classes (adapter `:208-212`). It admits
`("screen", "capture")` for the `evidence` class (`:185`). That route runs no
PNG check, no unique-path rule and no dimension check. The existing adapter
test still uses it with `-o 'local image'` (`Tests/scripts/vm-guest-exec.bats:263-266`).

The report says "Callers cannot supply another output path" (`:32`). That is
true only for the new function. The k66 contract requires a readable complete
PNG at a unique path for every capture, with no bypass of the domain
(`ORDERING-PHYSICAL-RESULTS.md:147`). The k85 brief forbids bypass and
overwrite.

Failure scenario: a k76 or k57 adopter writes
`cli_guest_evidence ROOT evidence fail-shot '.ok' -- screen capture -o "${LOG%.log}-failure.png"`.
The receipt is clean, but the PNG is unchecked and the path can overwrite
earlier evidence. No structural refusal or control stops this at adoption.

### P2-2. The controls cannot disprove an over-strict validator

The fixture writes one IDAT chunk, filter byte 0 on every row and the
default `zlib.compress` stream (fixture `:46,53,59`). It writes no ancillary
chunk. The real encoder writes filters 1 to 4 (decision above).

Thus a validator that refuses every nonzero filter passes all fourteen
controls. So does a validator that refuses multiple IDAT chunks or any
ancillary chunk. Each of those validators refuses every real capture. A real run would then
latch on its first capture.

The only acceptance of a real image is the one-off `historical-image`
receipt. The `check:vm-capture-evidence` task does not run it
(`Taskfile.yml:1500-1510`). It is therefore no reusable control.

The rejection side has gaps too. No control reaches these branches:

- chunk before IHDR (validator `:64-65`)
- non-consecutive IDAT (`:73`)
- unexpected critical chunk (`:81`)
- invalid or reserved chunk type
- IEND with a payload
- trailing compressed bytes (`unused_data`, `:95`)
- oversized pixel stream (`unconsumed_tail`)

The report claims some of these, for example
"Trailing compressed bytes are refused" (`:58`) and "rejects unexpected
critical chunks". Each mutation control checks only status 125 and the
outcome (Bats `:85-90`), not the validator reason. So a mode that some other
branch refuses also passes.

### P3-1. Keepalive sleep status is exact only when the lock is free

The library records a failed sleep with `record_guest_poll` (library `:34`).
That call goes through the same nonblocking lock. If the scenario holds the
lock, the record is refused, and the loop returns 125, not the sleep's 129 to
192 status. The status survives only inside `refusals.jsonl`.

The report says
"signal statuses 129–192 return unchanged" (`:78`) without that condition.
A signal sent to the run is exactly the case where a scenario action can be
in flight. No control covers it.

The receipt reason also reads `window poll sleep exit N` (adapter `:314`),
which names the wrong poll for a keepalive failure.

### P3-2. Retention volume, privacy and resource limits are not handed on

Each successful tick keeps one full logical screenshot in the root. The
legacy loop overwrote one file. The retained real image is 233136 bytes.
A 30-minute run therefore keeps about 90 images, about 20 MB, with
secret-bearing screen content. The report does not give k57 or k76 a duty
for this volume or for these private images.

The validator reads the whole file with no size bound (validator `:37`). The
pixel-stream bound is the IHDR claim, which the response can set as high as
2147483647 by 2147483647. A `MemoryError` is not caught (adapter `:340`). The
attempt then has no `result.json`, and the next dispatch latches it as an
unfinished attempt. This fails closed. But it is a partial-record path that
the report does not list.
