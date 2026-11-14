# settings-snapshot-evidence-k82

**Reviews:** settings-snapshot-evidence-k79

## Goal
Try to disprove the new snapshot/element evidence contract before any caller consumes it.

## Context
Read the producer's committed vm-ui-evidence-lib.sh, Taskfile entry, Bats controls and ORDERING-SNAPSHOT-RESULTS.md with its original receipts. Read the reviewed shared/input/window/physical handoffs and ORDERING-EVALUATION-PLAN.md. K75 is the enclosing mandate and remains open; ordinary caller bytes are unchanged.

## Done when
Inspect the whole artifact against its actual contract: recursive jq field checks and first-match selection, optional absence versus required value/geometry/height, exact raw one-attempt transport/VM/writer/latch behavior, invalid roots/arguments/selectors, local decoder and sleep statuses, preserved ten-by-two bound/final sleep, structured exhaustion versus unavailable/interrupted results, and source-only/no-adoption limits. Challenge the caller inventory, depth/optional-field limits and red/green provenance, including earlier test setup flaws and the final formatted baseline. Source fixtures establish no native availability. Preserve all k75/k71/k66 duties and runtime holds. Produce findings without fixes; cut an adjacent integration only for findings worth acting on, before k80's entry. No duplicate in-session reviewer, VM, candidate or freeze.

## Notes
K80/k81/k76 consume only after this review and every earned integration. K76 still owns complete caller/root adoption and full signals with both held-pointer controls; k67/k62/k57/k54 retain all original duties. No historical/causal-slot changes or ancestor closure. Secret-bearing consent roots stay private.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k79 commit d5e917ca, the shared adapter and the legacy snapshot callers.
  Read the official v2.7.0 CLI, protocol types and macOS agent sources from the
  local TestAnyware commit 65bc05c9. Run no test, build, lint or VM command.
  One `jq builtins` listing shows that the pinned jq 1.8.2 has `isfinite`.
  It is a tool check, not a project test.
- 2026-10-29: P2-1 is a defect against the k79 duty to preserve the consumed
  attributes of actual callers. P3-1 to P3-4 are contract, assumption or
  provenance gaps. Each finding merits triage before k80, k81 or k76 consume the
  readers. Insert the integration before k80, which is the first later live
  sibling of this review.

## Findings

Severity: P2 means a defect in a strict guarantee that k80, k81 or k76 would
rely on. P3 means a narrower defect, a retention gap or a control gap.

Line numbers refer to commit d5e917ca. "The library" is
`scripts/vm-ui-evidence-lib.sh`. "Bats" is `Tests/scripts/vm-ui-evidence.bats`.
"The report" is
`docs/verification/settings-activation/ORDERING-SNAPSHOT-RESULTS.md`. "The
receipts" are the files under
`docs/verification/settings-activation/ordering-snapshot-evidence/`. Agent
lines refer to TestAnyware v2.7.0 (commit 65bc05c9).

### P2-1. No requirement mode fits the attributes that `on_screen` consumes

The `on_screen` helper (`scripts/vm-verify-lib.sh:167-176`) has two outcomes
for a read. A missing match is a clean status 1. A present match must supply
`positionY` and `sizeHeight`. The `reveal` helper (`:207-209`) and
`calibrate_window_scroll` (`:187-189`) consume only `positionY` of a required
match.

The library offers four modes (`:84-90`):

- `optional` checks no attribute of a present match.
- `geometry` requires a match. It also requires `positionX`, `sizeWidth` and a
  positive width and height, which these helpers do not consume.
- `height` does not require `positionY`.
- `value` does not apply.

No mode accepts a missing match and also qualifies the position of a present
match. This has three consequences:

- With `geometry`, a missing request label at `scripts/vm-verify-menu-bar.sh:216`
  becomes unavailable evidence: status 125 and a latch. The scenario currently
  reports this as a product failure ("the window did not scroll to the
  requests").
- With `optional`, the consumed position is not qualified. The legacy `jq -e`
  check then reads a missing `positionY` as a clean off-screen result, because
  `null >= number` is false.
- A second read to qualify the geometry adds a duplicate read, which k71
  forbids.

One-read adoption is still possible with an `optional` read, a local check and
`fail_guest_evidence`. The report does not name that pattern.

The report row for these
helpers (report `:108`) says "Keep clean absence/off-screen distinct from
error, require consumed geometry". It does not say how one qualified read does
both. The k79 Done when requires the enumeration of downstream attributes and the
preservation of their semantics. That duty is not met for these three helpers.

### P3-1. A transient window without a tree ends a settling poll on its first read

The agent finds each window again by app name and exact frame
(`AgentServer.swift:796-811`). When that lookup fails, the agent returns the
window without `elements` (`:158`). The library schema requires `elements` on
every returned window (`:45`).

One such window therefore makes the whole read
unavailable and latches the root. This occurs when any window that matches the
substring `--window` filter moves, resizes or animates between enumeration and
the walk. It occurs even when the selected positive match is present in another
window. It also occurs on the first read of a poll.

The legacy route treated a missing tree as no match and continued the poll. The
Add-button loop (`scripts/vm-verify-desktop-lib.sh:95-101`) exists because "The
pane takes a while to load". The k79 rule that a missing tree is not absence is
correct for negatives. But the report (`:35`) does not record two consequences:

- A positive from a snapshot that is missing a tree is also refused.
- The first transient miss ends a settling poll and latches the scenario.

The native frequency of this case is not known. K80 and k76 need this recorded
before they adopt the Add loop or any other poll during window movement.

### P3-2. The empty-field check depends on agent behaviour that nothing verifies

The report (`:106`) makes `value` mandatory for the ⌘X empty-field check
(`scripts/vm-verify-menu-bar.sh:188`). The agent's `value()` returns nil when
`AXUIElementCopyAttributeValue` for `AXValue` fails
(`AXElementWrapper.swift:91-95`). The encoder then omits the key
(`ElementInfo.swift`, `encodeIfPresent(value…)`). No source, fixture or
receipt establishes that an emptied text field reports `""` instead of a failed
copy.

If the copy fails, a correct cut becomes unavailable evidence and latches
the root. This cannot cause a false pass. But the report states the
requirement as settled caller semantics. It must record the requirement as a
native-unverified assumption, with its consequence, for k76 and k67.

### P3-3. Selector checks depend on the data and occur after dispatch

The report (`:48-50`) says that "a malformed, nonboolean or multiple-result
condition fails qualification". The check (`:64-69`) runs only for each
candidate that has `platformRole`.

- A snapshot with no candidates gives a clean `null` for a nonboolean or
  multiple-result condition. Empty windows and empty element arrays are such
  snapshots, and the loading pane gives them. In that case `await_guest_element
  … absent` succeeds, and `present` exhausts with outcome `state-failed`.
- The adapter finds a syntax error only after it sends the snapshot. The receipt then
  records an unavailable guest read with the reason "command payload predicate
  did not yield true". Its outcome is the same as for a bad guest payload.

The Bats selector test (`:213`) uses only the populated fixture. Every current
selector is a single comparison, so the gap affects no current caller. The report
claim is broader than the code guarantees.

### P3-4. Two committed receipts and one divergent red control are not explained

- `final-baseline-prior-red.json` has test digest `5a078f87…`. It comes between
  the intermediate baseline (`3f4e075c…`) and the final baseline
  (`1642bab0…`). The report (`:131-137`) names only the intermediate and final
  baselines.
- K79 committed `docs-final.json`. The report (`:152`) cites only
  `docs-initial.json`.
- Bats test 16 (`:290-298`) asserts a different statement in baseline mode. Its
  red result is not a failure of the assertion that passes green. The report
  says that each loop stops at its first assertion. It does not name this
  branch.

Both unexplained receipts show the expected results. The prior baseline fails
all 16 tests. `docs-final.json` has the same two k23 links and exit 201. Thus
the gap is incomplete provenance, not a false claim.

### Checked without a finding

- The schema agrees with the official Rust and Swift types. The envelope puts
  `windows` at top level. The `--window` filter, the menu-bar pseudo-window and
  the first-match `platformRole` document order are the same as in the legacy
  `element` route.
- The ten-read poll has a two-second sleep after each negative, including the
  tenth. Exhaustion is ordinal 21 with outcome `state-failed`. Decoder, sleep
  and adapter signal statuses stay distinct. Invalid roots refuse without
  writes to the working directory.
- The final red and green subject digests equal the committed bytes. The red
  failures sit on the intended assertions. The report states the earlier setup
  defects.
- The bounded inventory equals a direct sweep of its three files. The other
  libraries that the scenario sources contain no element reader. Every current
  selector yields exactly one boolean.
- The depth limit, the `childCount` lower bound and the positive size for
  `geometry` are visible trade-offs that agree with the agent's walk.
