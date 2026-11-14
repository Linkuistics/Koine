# resize-input-delivery-k10


## Goal
Isolate why the combined corner recipe works in exploratory interactions but
fails to grow a fresh Koine window, then qualify a useful user-input route or
document the precise remaining limitation under the original parent contract.

## Context

- `docs/verification/menu-bar-vm.md`, User-input corner route, is the current
  outcome. The older macOS 26/Koine 0.3.0 run remains the minimum-size acceptance.
- `docs/verification/window-resize/README.md`, `focused.log`, `revised.log` and
  their inventories preserve the unsuccessful candidates as well as positives.
- The official TestAnyware 2.7.0 source is retained in
  `docs/verification/window-resize/exploratory/upstream-input.rs`; `drag` sends
  interpolation points with a held button and no per-step delay. Ordinary move
  sends mask zero. CLI capabilities are saved beside it. Timing is a lead, not
  a measured cause, and separate CLI move calls are not a held-button path.
- The current source-only helper and complete scenario deliberately fail a
  missing growth; they are an unqualified candidate, not an accepted repair.

## Done when

- Declare a bounded comparison before input: fresh-guest readiness, actual
  front/focused state, exact start geometry, held-button path/timing and an
  independent ordinary-window control. Do not issue input before setup ends.
- Distinguish pointer hit geometry, input delivery/timing and application
  behavior through observations of actual effects. Do not infer delivery from
  exit zero. A persistent-connection paced route is one possible control if
  the installed CLI cannot express timing; no route is prescribed as the cause.
- If a useful route is established, grow the signed settings window, attempt
  shrinking below its 440-wide/320-content-high limit and reach the existing
  required controls by scrolling at the observed minimum, using frozen actual
  subjects. AX frame assignment supplies no resize acceptance.
- If no useful route qualifies, keep resize/minimum-size scrolling explicitly
  NOT RUN, identify the exact failed controls/environment and provide a minimal
  reproducer plus a reviewable upstream report if ownership is established.
  TestAnyware issue 12 was closed for a different input-reset fault; do not
  reopen it or file a new report merely from similar symptoms.
- Settle the reusable script and verification record. Validate the complete
  scenario through its existing seam, retaining any activation failure and all
  assertions not run. K4 owns the broader finite sample and activation cause;
  do not grow a retry cap to seek a passing scenario.

## Notes

Use disposable guests; preserve the host's pointer, foreground and permissions.
A past green exploratory frame does not qualify a new attempt.
All new attempts need exact operands, outcomes, cleanup and honest limits.

## Decisions (running log)

The graph CLI again refuses startup because a pre-coordination/unverified
CBM generation is active. Use bounded direct source reads and leave other
sessions alone. The inherited approved repair plan and user-input seams still
apply; no new product design or ADR is needed.

Before input, declare a four-trial geometry comparison: two new macOS 27 golden
clones, one each for inset 3 and inset 8. In each clone, finish installation,
launch and readiness before any trial input; Koine retains its fresh 480×712
frame, while AX sets TextEdit's initial frame to the same size (setup only).
Each trial moves the selected window to (40,40), explicitly focuses it, checks
agent first/focused and fresh native activation, prepares the pointer, waits
0.5 s, and sends one combined VNC drag to (740,940) with 100 unpaced steps.
Observe the actual frame and screenshot after 1 s. Koine runs first, then
TextEdit; move the other window clear. No retry cap and no minimum-size claim
from these exploratory trials. If geometry alone does not distinguish effects,
plan a separately declared timing control before issuing more trial input.

Both initial comparison launches produced no drag trial. Inset 8 stopped on an
unsupported `agent wait --id` option copied from the tool's general playbook;
its per-command help supports only window readiness. Inset 3 was explicitly
terminated while its read-only spctl assessment kept timing out, before reaching
the same bad readiness call. Their cleanup traps stopped both clones. Correct
the setup-only wait flags before the declared four-trial comparison; retain
both preflight logs separately. This does not consume or repeat a resize trial.

The declared four trials completed: fresh Koine stayed 480×712 at both insets;
matched TextEdit grew to 703×903 (inset 3) and 708×908 (inset 8). Agent focus and
fresh native activation agreed before each drag. Both clones stopped. This
rejects geometry alone as the demonstrated remedy and a blanket VNC-delivery
failure as the diagnosis. It does not distinguish Koine's initial resize state
from event-rate sensitivity; TextEdit's initial size was AX-prepared and it ran
second. Host subject re-enumeration and item hashes agree. These are diagnostic
trials, with no installed endpoint inventories or native minimum-size acceptance.

Declare two more diagnostic trials in one new guest, at the original three-pixel
inset and otherwise the same readiness/geometry/focus checks. Replace the one
unpaced drag request with mouse-down at the start, a 0.2 s dwell, ten linearly
interpolated `mouse-down` requests (RFB mask 1 at every coordinate) spaced by
0.15 s, then mouse-up. This is a held-mask path, unlike ordinary `move` (mask 0).
Each CLI request opens its own connection, so it is not a pure pacing comparison
and must not be called a persistent-connection route. Native effects determine
whether it is useful; exit zero supplies no delivery proof. One trial per app,
no automatic retry. If it works, qualify the route independently before adoption.

The two held-mask trials both grew to 703×903. The useful candidate is now the
paced sequence of button-mask-1 requests, with the same inset and destination.
The comparison does not separate inter-event delay from per-command connection
lifecycle, nor locate an upstream defect. It does establish actual input effects
on a fresh Koine frame without AX resizing Koine. Select this demonstrated
candidate for request/error tests, one frozen fresh resize/scroll qualification,
and one complete scenario against the final recipe. No application change is
justified. All three comparison guests stopped and before/after host hashes agree.

Five revised request/error controls failed against the unpaced helper; the
existing preparation-failure control stayed green. The candidate now sends
11 button-mask-1 points including the initial down, followed by release. A
failed down attempts release at that coordinate and returns its original error;
a failed final release remains a failure. No retry hides an input error.
The upcoming qualification extracts the unchanged dimension/content assertions
from the current scenario, with readiness completed before the segment. Freeze
the actual wrapper, helper, shared scripts and signed bundle before one new guest.

The one frozen focused route passed: growth 703×903, attempted shrink to (100,100)
stopped at 440×352, and login-launch/grant-label/accessibility-status were reached
by scrolling at that frame. Installed before/after regular-file and symlink
inventories and host re-enumeration agree. The guest stopped. Preserve this
actual result and its original frozen assertions.

The one allowed fresh-context review identified two valid actionable weaknesses
in the inherited scenario assertions: unchecked command substitution can discard
a failed frame read, and the lower height bound tests 320 frame pixels rather
than 320 content pixels. Tighten those assertions with focused failing controls
before the final full-scenario attempt. These are acceptance-instrument repairs,
not new input recipes or application changes. A direct content-height observation
is preferable to assuming a fixed platform title-bar height. No second reviewer
is needed for failures conclusively covered by the focused executable seam.

Both acceptance-guard regression controls failed against the inherited section
while its valid-minimum control passed. All nine resize controls plus eight
pointer controls now pass. The final section preserves the outer-frame bounds
and separately enforces at least 320 pixels on the observed AXScrollArea; failed
frame/content reads explicitly fail. The final focused wrapper and the one full
scenario are frozen together with the actual signed bundle, scripts and Taskfile.
These changed-subject runs qualify the corrected guards; they do not replace
the first successful focused candidate or repeat a full attempt to seek green.

The final focused qualification passed against the corrected guards: fresh
480×712 → 703×903 → 440×352, measured scroll-area content height 320, and all
three required controls reached by scrolling. Installed endpoint inventories,
host item hashes/re-enumeration and symlink endpoints agree. The focused guest
stopped. The sole final complete-scenario attempt remains in progress separately;
its first-launch checks passed so far. No reliability rate or activation-cause
claim follows from either focused qualification.

The sole final complete scenario exited 0. It passed first launch, all four
Settings actions, 703×903 growth, 440×352 minimum with measured 320-pixel content,
scrolling, shortcuts, client requests, status navigation, consent, silent launch,
reopen, login restart and final Quit (old-port curl exit 7). Installed bundle
endpoint inventories, host re-enumeration/per-file checks and symlinks agree.
The display began at 1920×1080; the guest restart restored 1024×768, recorded by
the final input log and post-run display read. The retained guest was then stopped;
TestAnyware and tart inventories show no running investigation clone. No assertion
was NOT RUN in this final complete attempt. This single positive does not erase
prior activation failures, establish their cause or supply a reliability rate.
K4 retains the bounded broader sample and activation-cause work.

The normalized host-to-installed comparison also matches both installed
endpoints of each focused run and the complete scenario to the frozen extracted
release input. Local links in the affected verification documents resolve.
The k3 original Done when criteria are checked in its brief and the qualified
route/limits promoted to the root and k4 handoff. No new ADR or glossary term is
needed: this repairs verification input and guards without changing the product
contract. No live review names k10 or k3, so no Creator line is written.
