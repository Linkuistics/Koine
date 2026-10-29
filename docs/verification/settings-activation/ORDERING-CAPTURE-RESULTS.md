# Capture artifact evidence

K88 supplies source-only checked screenshots and the existing background
keepalive loop. K85 remains open with file/environment/lifecycle/collection work
in k89. Independent review and every earned integration precede k89/k81/k76
consumption. No ordinary caller or scenario root is changed. No VM, signed
candidate, frozen subject, native availability or repair acceptance is supplied.

The [ordering protocol](ORDERING-EVALUATION-PLAN.md),
[shared adapter](ORDERING-NONEXEC-RESULTS.md),
[physical](ORDERING-PHYSICAL-RESULTS.md), [window](ORDERING-WINDOW-RESULTS.md),
[input](ORDERING-INPUT-RESULTS.md), [snapshot](ORDERING-SNAPSHOT-RESULTS.md) and
[click](ORDERING-CLICK-RESULTS.md) contracts and reviewed limits remain binding.

## Interface

Source [the capture library](../../../scripts/vm-capture-evidence-lib.sh).
Sourcing only defines functions and loads the source-only facade. Every public
call requires a nonempty root initialized with `init_guest_evidence`. Empty,
missing and uninitialized roots return 125 without dispatch or cwd writes; the
caller must preserve their diagnostic/status because no evidence destination
exists. There is no ambient-root or legacy fallback.

| Function | Operation |
|---|---|
| `capture_guest_evidence ROOT read-poll OPERATION [X,Y,WIDTH,HEIGHT]` | One logical full-screen or region capture while scenario eligibility remains intact. |
| `capture_guest_evidence ROOT evidence OPERATION [X,Y,WIDTH,HEIGHT]` | One read-only contextual capture, including after a latch; it never restores eligibility. |
| `keepalive_guest_evidence ROOT` | Foreground loop for the scenario to own as a background child. Sleep 20, capture once, repeat only after success. |

The backend reserves its next exclusive ordinal directory and selects its
absolute `screen.png` output path. Repeated operation names still get distinct
files. Callers cannot supply another output path, endpoint, physical mode or
extra CLI flags. Region input is four unsigned u32 decimal components with
positive width/height. It preserves the existing `1500,0,420,200` mark crop.
No display read, input, extra poll, wait or retry is introduced. Argument/parser
errors retain the adapter's existing nonzero statuses and latch identifiable
initialized roots.

The new `capture` backend action records `transport:"capture"` in the same
writer/ordinal domain as exec, CLI and local poll steps. Requests preserve exact
pinned VM, operation, class, CLI argv, times and a nonconstant payload predicate.
Raw stdout/stderr, CLI status and validator output remain at the ordinal. The
predicate requires exact output path and positive integer numeric dimensions;
region dimensions must also equal the request. The ordinary strict envelope,
clean CLI completion and no-dry-run rules apply unchanged. Failed completion
never qualifies an image, even if valid image bytes were written.

Payload AND artifact qualification occur before successful stdout emission and
before releasing the writer lock. A fresh-read failure cannot race a cooperating
scenario action through a shell check after unlock. The image must be a readable
regular non-symlink file, stable across the read's file-identity checks. The
[small validator](../../../scripts/vm_capture_artifact.py) requires the inspected
encoder's noninterlaced RGBA8 PNG: signature, header/dimensions, chunk structure
and checksums, consecutive image-data chunks, terminal IEND without trailing
content, complete zlib pixel stream, exact scanline sizes and supported row
filters. It rejects unexpected critical chunks and unsupported image formats.
Ancillary chunks are checksum-checked and otherwise ignored. It verifies pixel
stream readability without rendering or judging pixels. Trailing compressed
bytes are refused under this narrow encoder contract even where a general PNG
decoder could ignore them.

A successful `artifact.json` records absolute path, format, dimensions, byte
length and SHA-256 of the actual read. It is published exclusively under the
same lock before the clean terminal receipt. Missing/unreadable, empty, corrupt,
truncated, mismatched or changed artifacts are unavailable, with a sticky latch
and no qualified stdout. Original image bytes and partial records remain in
place. This proves neither native pixel freshness nor visual focus, native
capture completeness or later immutability. K57 still audits saved artifacts
against originals. The protocol separately requires visual conflict review.

## Background ownership and limits

The keepalive helper preserves the existing `while sleep 20; capture` order.
It adds no leading capture, replacement attempt or success delay. Each successful
tick retains its own image. The first failed capture returns immediately,
latches the shared root and stops before another sleep/capture. An observed
failed sleep records its exact local status and `poll_phase:"sleep"` through
`record_guest_poll`; signal statuses 129–192 return unchanged and ordinary
failures return 125. Successful sleeps add no receipts. A signal killing the
shell before recording may leave only caller status/partials.

K76 must start and own the loop's process, retain/reap its terminal status and
stop it before untouched failure collection; sourcing this library starts no
background job. Its complete INT/TERM/HUP handlers and both held-pointer cases
are still unimplemented. K57 owns orphan-holder resolution and exact-clone
containment through the same writer domain. No bare release, lock/latch reset,
unrecorded stop or bypass is permitted. Deliberate loop cancellation during
cleanup must be recorded separately from a failed tick or scenario outcome.

The shared lock remains nonblocking. A keepalive/scenario overlap therefore
refuses and latches; this implementation adds no queue, scheduling wait or retry
to avoid that availability cost. K76 must preserve that consequence on adoption.
A competitor can latch during a clean in-flight capture; that capture may still
finish clean, but cannot clear the earlier latch. Evidence-class collection is
context only. These are guarantees for cooperating processes in the one root,
not protection from deliberate same-UID mutation or remote cancellation.

## Actual source and caller inventory

The [tagged-source receipt](ordering-capture-evidence/official-source.json)
identifies v2.7.0 objects read via `jj file show`, after workspace/CLI manifests
and the lockfile. The official
[screen handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs)
writes a PNG and returns top-level path/width/height; its
[capture encoder](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-vm/src/capture.rs)
writes `RgbaImage`. Lock-pinned image 0.25.10 and png 0.18.1 registry sources
confirm RGBA8 and default noninterlaced output. Comments cite the decision sites.
The [PNG recommendation](https://www.w3.org/TR/2025/REC-png-3-20250624/)
supplies chunk, checksum, compression and row-filter rules. These sources
establish no installed executable/agent/endpoint/golden provenance.

The tagged capture pipeline can return its held framebuffer when its existing
five-second readable wait expires. A clean readable PNG cannot prove that new
pixels arrived. No change to that internal route or timeout is selected here.

The [bounded inventory](ordering-capture-evidence/callers.json) enumerates every
`testanyware` token in the actual scenario/common/desktop/pointer/resize surface
and classifies capture candidates. Direct source reads cover graph partial shell
ranges; new files/tests have unavailable or untracked metadata. The graph's
`cli_argv` caller points to `run_locked`; its unrelated Swift add/update edges
are not credited as actual calls. This is no dynamic-shell or whole-repo
completeness claim.

| Existing capture caller | Adoption duty |
|---|---|
| Scenario first-launch, over-TextEdit, minimum-size, requests and after-login screenshots | K76 replaces each once, preserving its original point and logical full-screen capture. |
| Scenario mark screenshot | K76 preserves the exact region and its point in the scenario. |
| Common `fail` screenshot | K57/k76 replace ignored failure and reused filename with one evidence-class capture after the prescribed untouched observer/window reads; retain every outcome separately. |
| `start_vm` keepalive and `cleanup` | K76 adopts the owned loop, unique files and terminal-status handoff; k57 retains collection/containment. No discarded error, overwrite or disowned unreaped worker. |
| Protocol setup/menu/outcome/failure captures not yet implemented | K67/k76 apply this same checked capture path at the already agreed observation points. This artifact adds none of those observations itself. |

## Controls and provenance

The [initial pre-repair baseline](ordering-capture-evidence/baseline-red.json)
runs ten initial controls against test-only direct capture and legacy ignored-
failure keepalive semantics. All fail. The wrappers adapt the new signatures;
they do not run a complete scenario. The
[initial green](ordering-capture-evidence/initial-green.json) records the same
controls passing after implementation. Nested invalid variants stop at their
first failed baseline assertion; this does not establish every variant red.

The [expanded run](ordering-capture-evidence/expanded-controls.json) adds the
actual post-CLI image-inspection barrier, mixed ordinals, caught SIGINT and
relative-root checks. It fails only the new relative-root assertion: macOS's
logical `/var` cwd differs from Python's physical `/private/var` cwd. The test
now expects the physical cwd; production is unchanged by that correction.
The [expanded green](ordering-capture-evidence/expanded-green.json) passes all
fourteen controls. The [final-control baseline](ordering-capture-evidence/final-control-baseline.json)
repeats the formatted final tests against those legacy wrappers. Tests 8 and 10
intentionally call the current backend directly and pass; the other controls
fail. These two are not baseline disproofs.

The [initial adapter check](ordering-capture-evidence/adapter-initial.json)
finds one import-harness regression: direct `importlib` loading did not supply
the script directory for the new sibling dependency. All other adapter controls
pass. Adding that directory to this test's module search path supplies the same
context as normal script execution; the
[focused check](ordering-capture-evidence/focused-green.json) passes. Earlier
measurement subject sets omitted the adapter suite's saved timeout fixture, so
those receipts are not credited as complete adapter input audits. The final
verification includes that exact retained response.

The controls use real backend, lock, receipts, jq and PNG validation; only the
external CLI and named sleeps are synthetic. The image-inspection barrier
instruments an isolated copy, after CLI completion, and demonstrates lock
refusal at that boundary. Tests retain raw status/bytes, malformed and partial
responses, unique full/region images, artifact/schema failures, sticky
collection, mixed ordinals, invalid roots/options, exact cadence and local
interruption. Caught SIGINT is tested during capture; this supplies no complete
scenario handler or held-pointer qualification. An unchanged retained failure
screenshot also passes this narrow image check; it is historical data, never a
new native capture or replacement assertion.

Run `mise exec -- task check:vm-capture-evidence`. Final check receipts in
`ordering-capture-evidence/` record each command's complete output/status,
per-test results and unchanged before/after subjects. The shared adapter's
existing consumer checks are also run. Documentation validation retains the
two existing missing archive links owned by k23; it establishes no clean docs
result. No test or source changes during a recorded measurement.

## Remaining duties

K89 retains every remaining original k85 file/environment/lifecycle/collection
helper duty. K81 retains EVERY exec and one-shot consequence, including installed
inventory and exact defaults/launch/restart confirmations; no upload or PNG
receipt substitutes for them. K76 retains complete caller/root adoption,
status propagation, complete signals and both held-pointer controls. K67 retains
all positive setup/title/liveness/outcome work, k62 exact focused prefix through
TextEdit quit and whole-duty reconciliation, k57 finite caller/collection/exact
containment, and k54 readiness/freeze/runtime after all reviews/integrations.

Snapshot missing-tree and empty-AXValue availability, OCR substring stopping and
private secret-bearing evidence roots remain binding. No original k85/k80/k75/
k71/k66 criterion is waived. Historical candidates/results/classifications,
failed transports, strict false joins, NOT RUN phases, closed caps and held
causal slots are unchanged. Native cause, ownership and repair acceptance remain
unresolved. No ancestor closes, release, notarization or upstream report follows.
