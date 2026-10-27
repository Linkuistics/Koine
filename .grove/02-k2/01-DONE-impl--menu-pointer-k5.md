# menu-pointer-k5

## Goal

Repair the menu helper's synthetic negative approach coordinate without changing
valid targets, rejecting malformed observations before input. Preserve a reusable
non-GUI check and real-guest evidence through the existing menu route.

## Done when

- A deterministic regression traces a System Events shaped frame through
  click_centre to the exact old CLI arguments, including the rejected -1.
- Display edges, malformed/missing frames, invalid dimensions and transport
  failures are checked without starting a VM. Valid destinations stay unchanged.
- The repaired helper is exercised on the signed released 0.4.0 bundle in a
  clean macOS 27 VM, with frame/coordinates and the resulting window observation
  recorded. Focus failure remains an explicit unresolved result for the next
  child, not a claimed fix.
- The Taskfile and verification record preserve the recipe, subjects and limits.

## Decisions (running log)

- Extract only click_at/click_centre into a source-only helper; retain all shared
  consumers through vm-verify-lib.sh. Bound only the synthetic approach to the
  actual framebuffer. Refuse out-of-display destinations rather than clamping.
- A frame must contain exactly four bounded unsigned integer fields, with
  non-zero size. This route uses one positive-coordinate framebuffer; negative
  native display origins are refused rather than translated speculatively.
- Baseline Bats controls failed for the y=7 approach, display edges, malformed
  frames and transport errors. Eight repaired controls pass through the Taskfile.
- The focus problem is real in the diagnosis guest: Settings was delivered and
  opened a previously absent window, but TextEdit kept keyboard focus and front
  ordering. Preserve it for the next child; do not change Koine or retry actions.
- Decline an in-session reviewer for pointer arithmetic because executable
  boundary controls directly disprove the old behavior and check the repaired
  geometry and failure paths. The separate focus investigation remains live.
- Added the extracted source to the existing installation and latency measurement
  subject lists, since their shared VM helper now reads it. Both changed recipes
  pass Bash syntax and ShellCheck without starting their guests.
- The shared VM start now uses TestAnyware's documented `--wait` slot protocol;
  the real scenario successfully queued and started its own disposable clone.
- The complete existing Taskfile scenario exited 0 in
  `menu-bar-20261028T084709.log`, with resize explicitly NOT RUN. The helper also
  handled the framebuffer changing from 1920x1080 to 1024x768 after restart.
  Both disposable guests were stopped. Script/zip digests stayed unchanged;
  the extracted bundle passed strict signature checks, but lacked a complete
  pre-run per-file digest. The verification record states that inventory limit.
- The successful existing scenario does not resolve the failed diagnostic
  focus action, check every intermediate reopen, or prove no retried explicit
  reopen. Keep all those parent obligations in menu-focus-k6. Do not count the
  current result as stricter menu-interaction acceptance or as a reliability rate.
