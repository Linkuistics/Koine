# settings-physical-evidence-k68

**Reviews:** settings-physical-evidence-k65

<!-- tc: off because the Goal, Context, Done when and Notes are the producer-authored charter, kept verbatim as the task contract -->

## Goal
Independently inspect k65's physical-helper migration against the accepted strict
evidence and unchanged physical-route contracts. Produce findings only.

## Context
Find the producer by its stable handle in jj history and inspect its committed
diff against current source. Read ORDERING-PHYSICAL-RESULTS.md, the k61/k56/k53
charters, ORDERING-EVALUATION-PLAN.md, ORDERING-REVIEW.md and
ORDERING-NONEXEC-RESULTS.md under docs/verification/settings-activation.

The source-only physical facade and both existing physical helpers are the
artifact; the real backend, Bats controls, Taskfile and retained red/final
receipts supply evidence. Graph startup refused before project/generation in
the producer. Establish graph availability normally and disclose fallback/
coverage limits; do not stop other CBM users. No in-session reviewer ran.

## Done when
- Find contract violations in explicit-root selection versus the unset legacy
  lane, no fallback, actual payload predicates, exact VM/ordinal/raw retention,
  geometry checks and local decode failure handling. Check against official
  immutable v2.7.0 schemas, including optional titles and input button/count.
- Inspect successful coordinates/actions/waits and conditional-caller failure
  propagation through every physical stage. Challenge whether nonzero/signal/
  partial outcomes can permit later input or an unrecorded release. Preserve
  uncertain held input and the finite caller's exact-clone/lock containment duty.
- Inspect the controls and measurement provenance, including the original legacy
  failures, decoder and empty-root failures, fixture inventory and unchanged
  before/after subjects. Do not infer native availability or repair from fixtures.
- Reconcile the intermediate migration boundary: the complete ordinary scenario
  still owes k66/k67, exact-prefix/whole-duty reconciliation k62, finite caller
  k57 and readiness/runtime k54. Identify dropped original duties or claims that
  wrongly admit runtime. Report findings with source evidence and practical impact.
- If findings earn integration, place it before the next live sibling entry
  that could move its cited artifact. Every earned integration precedes k66
  consumption; whole-harness review remains due before runtime.

## Notes
No VM, signed subject, freeze, slot, input retry, native acceptance, external
ownership or ancestor closure is chartered. Do not repair files in this review.
<!-- tc: on -->

## Decisions (running log)

- 2026-10-29: Adopt the mandated review-impl leaf on the empty jj change
  xxqlqmqs. Its parent is 759ef19c, the k65 producer commit. `main` is an
  ancestor of that parent, so the base is current. Read the brief chain and
  the k65, k66 and k57 task files. Read the producer diff and the k65 report.
- 2026-10-29: The graph MCP server failed to connect. The graph CLI refuses
  with the same error that k65 recorded: a pre-coordination or unverified
  generation is active. Stop no other graph session. Read the sources directly
  and claim no graph coverage. Run no test, build, lint, guest or in-session
  reviewer.
- 2026-10-29: Read the TestAnyware v2.7.0 tag (e37283e3, commit 65bc05c9) in
  the local checkout at `../TestAnyware`. The four digests checked against
  `official-source.json` are equal. The handlers and `WindowInfo` agree with
  every k65 predicate. Absent titles are omitted on the wire
  (`skip_serializing_if`), so the optional-title clause matches the schema.
- 2026-10-29: All 35 "after" digests of the final receipt equal the committed
  bytes. A changed digest line fails the same check. The four retained outputs
  equal their recorded hashes, and their test counts equal the test files.
  The k61 Done when in the node brief is byte-identical to the deleted leaf.
- 2026-10-29: One P3 finding and one handoff gap earn an integration. Both
  cite files that k66 can move. Insert one integrate-review-impl leaf before
  settings-scenario-transports-k66, the first live sibling after this review.
  This session finishes no producer and closes no node, so it writes no
  Creator line.

## Findings

Severity: P2 means a defect in a strict guarantee that k66 or k57 would rely
on. P3 means a narrower defect, a retention gap or a control gap. H means a
handoff gap that later work needs closed. This review found no P2.

Line numbers refer to commit 759ef19c. "Facade" is
`scripts/vm-physical-evidence-lib.sh`. "Resize" is
`scripts/vm-window-resize-lib.sh`. "Bats" is
`Tests/scripts/vm-physical-evidence.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-PHYSICAL-RESULTS.md`.

### P3-1. Two frozen subject lists omit the files that the pointer helper now loads

K65 makes `scripts/vm-menu-pointer-lib.sh` load the facade (lines 4-5). The
facade loads `scripts/vm-guest-exec-lib.sh` (facade:4-5). The common library
loads the pointer helper (`scripts/vm-verify-lib.sh:368`). Thus every consumer
of the common library now reads both new files.

Two verifiers freeze their subjects by name. `scripts/vm-verify-latency.sh:44-62`
lists the pointer helper, but not the facade or the adapter facade.
`scripts/vm-verify-installations.sh:72-75` states that it digests "Everything
this run reads or runs". Its list also names the pointer helper and omits the
two new files.

Neither verifier calls `click_at`, `click_centre` or `drag_window_corner`. The
new files only add function definitions at load time. The backend
`scripts/vm-guest-exec.py` runs only when a facade function runs, so these
verifiers do not read it.

Consequence: the printed digests of those verifiers no longer identify every
file that the run reads. A change to either new file does not show in their
receipts. The practical risk is small, because no measured path calls the new
functions.

Smallest correction: add the facade and `scripts/vm-guest-exec-lib.sh` to both
subject lists. The same lists already omitted `scripts/vm-window-resize-lib.sh`
before k65. That older gap is outside the k65 change, and the integration can
decide whether to close it at the same time.

### H-1. The handoff names held input only after a failed transport

The report states that strict failure stops all input, including release.
It then states that "A failed held point may already have reached the guest"
(report:79-85). The k57 handoff uses the same frame: "after failed transport".

A signal can also arrive between two clean attempts. Each clean
`resize-down-N` is followed by `sleep 0.2` or `sleep 0.15` (resize:34). If bash
ends there without a trap, the root holds only clean receipts. It holds no
`resize-release` attempt and no latch, but the button stays held in the guest.
The adapter admits the next call, because nothing latched.

K66 owns INT/TERM/HUP handling and the "uncertain held pointer" handoff, so
the duty survives. But no k65 text tells k66 or k57 how to detect this state
from the receipts.

There is also a control gap. When the adapter itself gets SIGINT at a held
point, the helper takes the same `else` branch as status 255 (resize:35-43).
Thus it sends no release. But the only signal control interrupts the menu
route at stage 2 (bats:267). No control interrupts a held point.

Consequence: a k66 trap or a k57 containment step that reads only the latch,
or only failed receipts, can treat a held button as released.

Smallest correction: state in the report and in the k57 handoff that a clean
`resize-down-N` receipt without a later `resize-release` receipt means held
input. This holds with or without a latch. Give k66's signal work a control
that interrupts a held point and finds no release attempt.

### Inspected without a finding

- Explicit-root selection. A set root selects the strict lane, and an empty,
  unknown or uninitialised root refuses with 125 before the adapter
  (facade:7-38). Nothing falls back to the legacy transport.
- The unset lane. It sends the same argv as before, keeps the legacy `fail`
  and keeps the best-effort release. The legacy pointer and resize test files
  are unchanged, and they pass in the receipt.
- Payload predicates. They agree with the v2.7.0 `input` handlers (`x`, `y`,
  `button`, `count`), `screen size` (logical `width` and `height`) and
  `WindowInfo`. The title is JSON-encoded before it enters the predicate.
- Retention. The adapter pins `--vm` and records ordinals, raw streams, CLI
  status and the predicate. The menu route control compares each raw reply
  with its stored copy.
- Failure stops. Each stage returns the adapter status, and strict failure
  sends no release. A local decoder failure latches through
  `fail_guest_evidence` and never qualifies emitted geometry.
- Coordinates and waits. The menu route keeps 0.3/0.3/1 seconds. The resize
  route keeps 0.5/0.2/ten times 0.15/1 second and eleven held points.
- Controls. The 13 baseline controls fail on their assertions, not on setup.
  The decoder and empty-root controls fail before their guards.
- The call inventory. Every TestAnyware family in the three reachable files
  appears in the report. `no_consent_dialog` uses `screen find-text`, but the
  scenario does not call it.
- The migration boundary. The report and the k61, k66 and k57 texts keep
  k66, k67, k62, k57 and k54 open. No text admits runtime or acceptance.
