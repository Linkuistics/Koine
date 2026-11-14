# settings-click-evidence-k86

**Reviews:** settings-click-evidence-k84

## Goal
Independently inspect the committed OCR/Allow/element-click evidence artifact
before k85/k81/k76 consumption. Produce findings only.

## Context
Read k84's commit/diff, docs/verification/settings-activation/ORDERING-CLICK-RESULTS.md
and its ordering-click-evidence receipts, current reviewed snapshot/physical/input/
shared handoffs, ORDERING-EVALUATION-PLAN.md and every original k80/k75/k71/k66
charter. The implementation plan and decisions are on k84. No in-session reviewer
ran. K80 decomposed; only its first child k84 executed, with k85 still live.

## Done when
Re-derive actual reachable ordinary/common/desktop OCR/click consumers and unused
definitions. Verify immutable source schemas after the manifest, including the
actual effective-limit call path rather than its contradictory comment. Challenge
complete OCR count/shape/empty/truncation handling; first exact Allow; consumed
element geometry; floor-centre/bounds; precise click echo; no added display/read/
input/wait/poll or retry; existing reveal and separate Add-loop read counts.

Inspect every nonzero/partial/interrupted/local decoder/sleep path, shared writer/
latch/ordinal behavior and later-input refusal. Check malformed/wrong geometry
cannot reach input, valid geometry remains usable, and source-only/root/nounset
refusals cannot write cwd. Reconcile baseline branches, fixture fidelity, all
individual controls, exact subject stability and the test-only poll_phase repair.
The final baseline skips source-only characterization; nested loops credit only
their first red assertion. Documentation check still fails the two k23 links;
its initial narrower-digest receipt and final whole-source/target inventory remain.

Challenge every report/handoff claim against actual code. Preserve missing-tree/
empty-AXValue native availability limits and private secret-bearing roots. K85
retains captures/background/files/environment/lifecycle/collection; k81 all exec/
one-shot consequences; k76 complete adoption/signals/both held-pointer cases;
k67/k62/k57/k54 all original duties. No VM/candidate/freeze/native acceptance or
ancestor closure. Cut every earned integration before the next consuming sibling;
no findings-based implementation in this review.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k84 commit e0a7c5b7, the shared adapter and the reviewed snapshot
  reader. Read the legacy callers and the official v2.7.0 sources at the local
  TestAnyware commit 65bc05c9. Run no test, build, lint, format or VM command. Graph tools
  were not used. Every conclusion below rests on direct source reads.
- 2026-10-29: The following claims hold against the code. The caller inventory
  and its reachability classes match the ordinary scenario, common library and
  desktop library. All six official digests match. The effective limit reaches
  the serialiser with a query (`screen.rs:170,238`), against the comment at
  `:309-311`. The click echo has exactly x, y, button and count
  (`input.rs:174`). The coordinate range is 0 to 65535 inclusive (`:393-404`).
  The receipt digests equal the committed bytes. The eight checks total 149
  individual controls. The production library is the same in the
  initial-sleep-assertion receipt and the final receipt, so the `poll_phase`
  repair is test-only. No read, input, wait, poll or retry is added. The reveal
  and Add-loop counts in the report match `vm-verify-lib.sh` and
  `vm-verify-desktop-lib.sh`.
- 2026-10-29: P2-1 is the same class as k82 P2-1. It merits triage before k85,
  k81 or k76 consume the helpers. Insert the integration before k85, which is
  the first later live sibling of this review.

## Findings

Severity: P2 means a defect in a strict guarantee that k81, k76 or the evaluation
stop rule would rely on. P3 means a narrower defect, a retention gap or a
control gap.

Line numbers refer to commit e0a7c5b7. "The library" is
`scripts/vm-click-evidence-lib.sh`. "Bats" is
`Tests/scripts/vm-click-evidence.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-CLICK-RESULTS.md`. "The plan"
is `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.
TestAnyware lines refer to v2.7.0 (commit 65bc05c9).

### P2-1. A clean OCR read with no exact Allow is recorded as unavailable

The Allow helper sends the clean OCR envelope to `_click_guest_target`
(library `:77-78`). The centre projection is
`[.detections[] | select(.text == "Allow")][0] | select(type == "object" ...)`
(`:51-54`). With no exact Allow, the projection yields nothing, and `jq -e`
exits 4. `_click_evidence_local_failure` (`:37-44`) sends status 4 to
`_ui_evidence_fail`. The backend then records a `confirmation` attempt with
outcome `unavailable` and reason `state exit 4: <predicate>`.

Invalid Allow geometry takes the same path. Zero width, zero height and an
out-of-range centre each yield the same exit 4, the same `-centre` operation,
the same transport and the same outcome. Only the raw OCR receipt of the
preceding attempt differs.

The legacy route treats a missing Allow as a setup failure: "the Automation
prompt for System Events did not appear" (`scripts/vm-verify-lib.sh:371`). The
plan keeps clean domain negatives apart from unavailable data. "A clean
mismatch is failed setup. Missing, conflicting or unreadable required evidence
is unavailable setup" (plan `:116-118`).

"An exhausted clean poll bound is the
named state failure. An errored poll is unavailable" (plan `:225-226`). The
`--timeout 30` OCR is the existing internal poll (`screen.rs:171-245`). A clean
complete payload with no exact Allow is therefore a clean negative, not missing
data. The window report states that operation suffixes and reason text are not
classifiers (`ORDERING-WINDOW-RESULTS.md:92-93`).

Failure scenario: in a native run the Automation prompt does not appear. The
OCR read is clean and complete. The receipt has `transport:"confirmation"`
and `outcome:"unavailable"`. The report's own rule (`:164`) then holds the run
before E01 for a new decision, instead of recording failed setup. An
out-of-range Allow frame gives a receipt with the same structure.

This is the same class as k82 P2-1. There, the `geometry` mode turned a clean
missing request label into unavailable evidence. The report (`:44-45`) says
only that absence "latches without input". It does not state the outcome class
or that the receipt cannot be told apart from invalid geometry.

### P3-1. The 30-second wait ends on any substring match, not on an exact Allow

The official matcher is a case-insensitive substring search within one
detection (`find.rs:47-60`). The poll ends at the first frame with any match
(`screen.rs:211-224`). Thus "Don't Allow", "allowed" or other text that
contains "allow" ends the wait at once, possibly before an exact `Allow`
detection is present. The helper then latches (P2-1).

The legacy route behaves the same way, so this is not a regression. But the
report says the timeout polls "until a match or deadline" (`:79`). It does not
say that the match is a substring match, or that the exact selection follows
only after polling stops. This native availability limit is not carried to
k76 or k81. Other on-screen text, such as a Settings label that contains
"allow", can end the wait early.

### P3-2. The cwd check in the invalid-root control cannot fail

Bats `:303` checks `! -e .writer.lock`. The backend's lock file is `.writer`
(`scripts/vm-guest-exec.py:389`). The control also omits `refusals.jsonl` and
`facade-refusals.log`, which the backend and the facade write
(`vm-guest-exec.py:87`, `vm-guest-exec-lib.sh:41`).

The reviewed UI control
checks `.writer` and `refusals.jsonl` (`Tests/scripts/vm-ui-evidence.bats:231`).
Thus only the `subject.json` and `unavailable` clauses can detect a cwd write.
Test 16 uses `find . -type f` (`:293`), but only for the zero-argument case.
The production code does not write to cwd for these roots. The defect is in
the control, which the report cites as evidence (`:144`, "invalid roots/arguments").

Sibling class outside k84: `Tests/scripts/vm-input-evidence.bats:171` checks
`writer.lock`, which the backend also never creates.

### P3-3. An interrupted query encoder loses its signal status

`read_guest_text` encodes the query with a local `jq` (library `:19-22`). On any
failure it calls `_ui_evidence_fail` and returns 125. A status from 129 to 192
is therefore not kept as an interrupted `poll-step`. The centre decoder
(`:37-44`) and `read_guest_element`'s decoder (`vm-ui-evidence-lib.sh:104-110`)
keep it.

The k86 charter asks for every interrupted local decoder path. The
report (`:55-60`) describes signal preservation only for centre decoding, so it
does not overclaim. But the interface is not consistent, and no control covers
this path.

### P3-4. Report claims about local failure receipts have no control

The report says that ordinary decoder failure "records a confirmation failure,
including the exact local exit in its reason" (`:56-57`). Test 12
(Bats `:226-241`) checks only the status, the click count and the latch. It does
not read the `000002` receipt. Test 6 (`:155-161`) also does not check which
receipt a missing exact Allow produces. Thus the transport, outcome and reason
of P2-1 have no control. A change to that classification would pass every
current control.

### P3-5. Two controls rest on non-official shapes or unrelated red causes

The `error` vector in test 4 (Bats `:136`) uses
`{"ok":false,"error":{"code":"TEXT_NOT_FOUND"}}` with exit 0. The official
error envelope has top-level `code` and `message` (`output.rs:57-69`). It exits
nonzero, and `TEXT_NOT_FOUND` occurs only with `--require-match`
(`screen.rs:228-236`), which the helpers never pass. The vector still proves
that `ok:false` refuses. But the report's "typed CLI errors" claim (`:41`)
rests on a shape the CLI does not emit.

Test 14 (`:258-264`) is red in the final baseline only because the bare route
omits `--vm` and `--json` (`final-baseline-red.json`, test 14). The coordinate
rule is not the cause. The report counts it among the sixteen failures
(`:131-133`) without that qualification. The red therefore proves nothing about
the inclusive bounds or the floor-of-centre rule.
