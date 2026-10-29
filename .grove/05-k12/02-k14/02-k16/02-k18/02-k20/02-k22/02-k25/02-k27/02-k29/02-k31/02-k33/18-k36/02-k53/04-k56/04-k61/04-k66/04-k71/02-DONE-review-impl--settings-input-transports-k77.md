# settings-input-transports-k77

**Reviews:** settings-input-transports-k74

## Goal
Independently inspect the committed input facade and actual caller migration
before remaining helper migration consumes it.

## Context
Find the producer's commit by settings-input-transports-k74. Read its diff, the
complete k71/k66 charter, ORDERING-INPUT-RESULTS.md and retained evidence, the
reviewed ordering protocol and shared-adapter/physical/window handoffs. This
increment migrates only reachable keyboard/text/scroll calls with an explicit
root; whole-scenario adoption, remaining confirmations and signals are still live.

## Done when
- Try to disprove exact request/response binding for key/modifiers, Unicode
  text/scalar count and scroll x/y/dx/dy against the immutable release source.
- Inspect argument/nounset/root guards, failure latch/shared writer use and
  partial/nonzero/interrupted returns. Check that no failure falls into legacy
  transport or permits later input in each claimed caller chain, including
  conditional contexts where errexit is suppressed. Identify any omitted reachable
  keyboard/text/scroll caller in the bounded inventory.
- Compare successful action argv/order/waits/assertions to the parent. Check that
  legacy definitions outside the claim remain visibly bounded, and that the
  complete root adoption, TextEdit/window replacement, downstream confirmations,
  all later duties and both held-pointer signal cases remain assigned.
- Pressure-test the controls and provenance: corrected final baseline versus the
  first setup-defective/earlier revisions, real caller-function extraction,
  independently specified payloads, retained command outputs and subject digests.
  No fixture establishes native repair or runtime availability.
- Report only findings with evidence; no fixes. If actionable findings exist,
  cut integration where the driver reaches it before k75. No VM, candidate freeze,
  signal qualification, acceptance or ancestor closure.

## Notes
K75/k76 and k67/k62/k57/k54 retain their complete original duties. All runtime
remains held until all implementation and every earned review/integration finish.

## Decisions (running log)

- 2026-10-29: Adopt the mandated review leaf in the clean jj workspace. Read
  the k74 commit 16826c12 and the shared adapter. Read the official v2.7.0
  input handlers, argument declarations and success envelope from the local
  TestAnyware tag objects. Their digests match the k74 source receipt. Run no
  test, build, lint or VM command. One scratch Bash script shows the errexit
  rule behind P2-1. It is a language check, not a project test.

## Findings

Severity: P2 means a defect in a strict guarantee that k75, k76 or k57 would
rely on. P3 means a narrower defect, a retention gap or a control gap.

Line numbers refer to commit 16826c12. "The facade" is
`scripts/vm-input-evidence-lib.sh`. "The adapter" is `scripts/vm-guest-exec.py`.
"Bats" is `Tests/scripts/vm-input-evidence.bats`. "The report" is
`docs/verification/settings-activation/ORDERING-INPUT-RESULTS.md`. "The plan"
is `docs/verification/settings-activation/ORDERING-EVALUATION-PLAN.md`.

### P2-1. The new failure returns let failed reads continue into later input

Bash ignores `set -e` inside a function that runs as a non-final command of a
`||` list. The rule applies to every command in that function body. K74 adds
`|| return "$?"` after three helper calls. This puts each helper in such a
context:

- `click` now runs `[ -n "${SNAPSHOT_WINDOW:-}" ] || reveal "$1" || return "$?"`
  (`scripts/vm-verify-lib.sh:127`). The parent made `reveal` the final command
  of the list, so errexit stayed active inside it.
- `reveal_click` now runs `reveal "$1" || return "$?"`
  (`scripts/vm-verify-lib.sh:210`). The parent ran `reveal` as a plain command.
- `expect_menu` now runs `read_menu || return "$?"`
  (`scripts/vm-verify-menu-bar.sh:47`). The parent ran `read_menu` as a plain
  command.

The scenario sets `set -euo pipefail` (`scripts/vm-verify-menu-bar.sh:15`). In
the parent, a failed read in these bodies therefore stopped the run. Now only
failed input returns explicitly. Other failures continue. A scratch script shows
the rule: `f() { [ -n "" ] || inner; }` exits on a `false` in `inner`, and
`f() { [ -n "" ] || inner || return "$?"; }` runs the rest of `inner` and the caller.

Two concrete paths follow:

- In `reveal`, a failed agent snapshot makes `e=""` at line 197. The test
  `[ "" != null ]` passes. `jq -r '.positionY'` on empty input prints nothing and
  exits 0 (line 199). The comparison `jq -n " > …"` then fails to compile. So
  the `else` branch dispatches `scroll_by` (line 203). The loop can repeat this
  up to 60 times before `fail` (line 206). The snapshot is a legacy read and does
  not latch, so these scrolls dispatch on the strict lane too. This path is
  reachable from `reveal_click` and every Koine-window `click` (scenario lines
  180, 219, 221 and 244).
- In `read_menu`, a failed `open_menu` no longer stops the run (line 400). On the
  strict lane, the physical helper latches. The body then still runs
  `menu_titles` through the legacy guest exec (line 401) before the facade
  refuses Escape. On the unset lane, a failed pointer transport returns nonzero
  through `|| return` (`scripts/vm-menu-pointer-lib.sh:19,41-45`). It does not
  call `fail`. The body then reads the menu and sends Escape. A failed
  `menu_titles` read also continues on both lanes. Escape is then sent on the
  unset lane.

These chains are the ones the leaf claims. The k77 charter asks whether a failure <!-- tc: depart long-sentence because the charter is quoted verbatim -->
"falls into legacy transport or permits later input in each claimed caller
chain, including conditional contexts where errexit is suppressed."

The first path permits later input. The second falls into legacy transport after a
latched failure. The report says the chains stop on failed input (report:68-71)
and that the unset lane keeps its behaviour (report:29-30). The facade's unset
lane is unchanged. But these shared helpers serve other VM consumers too, and
their failure semantics changed for every consumer.

Smallest correction: keep errexit active in the helper bodies. One way is to
call each helper as a plain command, as the parent did, and rely on errexit for
its nonzero return. If a conditional caller needs the status, each read in the
body that can precede input also needs an explicit failure return. Add controls
in which a substituted read fails inside `reveal` and inside `read_menu`. Each
control must show that no later input is dispatched.

### P3-1. The caller-chain controls test a harness context, not the scenario's

Bats tests 12-14 call `scroll_by`, `read_menu`, the scroll callers and
`grant_accessibility` inside `if` conditions (Bats:250, 254, 277, 297). Errexit
is ignored in an `if` condition. The final-control baseline runs the same tests
against the parent functions (`final-control-baseline-red.txt`). Those functions
then continue after the failed input, and the tests fail.

At the real call sites, the parent called these functions as plain commands
under `set -euo pipefail`. Its scenario and consent chains stopped at the failed
input there. So the red result for tests 12-14 shows what the parent did in a
conditional context. No parent caller used that context. It does not show that
the parent scenario continued after a failed input. The report says "Each strict
control fails" against the parent (report:91-96), and does not state this limit.

The same tests substitute every read with a stub that succeeds (Bats:244-248,
267-273, 289-295). No control makes a read fail inside a chain that k74 made
conditional. The tests therefore cannot detect P2-1.

Smallest correction: state in the report that the caller-chain baselines show
only conditional-context behaviour. Add the failing-read controls from P2-1.
Keep the existing red receipts unchanged.

### P3-2. Strict consent input retains the VM password in evidence receipts

`grant_accessibility` types `${VM_PASSWORD}` through the facade
(`scripts/vm-verify-desktop-lib.sh:104`). That value is `KOINE_VM_PASSWORD`, or
`admin` by default (`scripts/vm-verify-desktop-lib.sh:9`). On the strict lane
the adapter writes the password to `request.json` in `argv` and in
`payload_predicate` (adapter:267-268). The CLI echoes it as `text` in
`raw.stdout`. A refused or failed attempt can also copy it to `refusals.jsonl`
(adapter:78) or `facade-refusals.log` (`scripts/vm-guest-exec-lib.sh:41`). The
parent sent the CLI output to `/dev/null`.

The plan requires each attempt to retain its command and complete raw response
(plan:207-208). K57 collects these roots as evidence. With the default image
password the disclosure has no effect. A real `KOINE_VM_PASSWORD` would be
written into the collected evidence. The report does not state this.

Smallest correction: decide whether a secret operand is allowed in a retained
receipt. If not, add a redacted text operation whose predicate checks the scalar
count and a digest, not the text. Alternatively, state in the report that
consent evidence holds the password and must not be published.

### Checked without a finding

- Request and response binding matches v2.7.0. `run_key` echoes the `key` and
  `modifiers` as clap parsed them. `--modifiers` uses `value_delimiter = ','`,
  and the facade's split gives the same ordered array. `run_type` echoes `text`
  and `text.chars().count()`. Jq `length` counts the same Unicode scalars. The
  fixture uses a decomposed `é`, so its count of 9 is an independent check.
  `run_scroll` echoes the clamped `x/y` and `dx/dy`, with `dx` defaulting to 0.
  `success_envelope` merges these fields at the top level, beside
  `schema_version` and `ok`.
- The facade bounds match the CLI. Coordinates are 0-65535, as in
  `clamp_coords`. `dy` is a signed i32. A modifier value that starts with a
  hyphen, or a forbidden flag in that slot, fails closed in clap or in the
  adapter's `cli_argv`.
- Argument and nounset guards hold. Each `$1`, `$2` and `$3` is evaluated only
  after its count check. An explicit root that is empty, missing or not
  initialised refuses with 125 before dispatch and writes no cwd artifact. A
  set root never selects the legacy route.
- Every migrated input keeps its parent arguments, order and waits. The strict
  lane adds only `--vm` and `--json`, which change the output mode, not the
  event.
- The bounded inventory covers every direct key, type and scroll call in the
  three scoped files. Its digests match the committed sources. `create_grant`,
  `revoke_accessibility`, `quit_koine` and `quit_koine_or_terminate` have no
  caller in the complete scenario.
- All 31 subject digests in `verification.json` match the committed files. A
  mutated digest is detected. Each retained output matches its recorded digest.
  The prior-caller digests in the final-control baseline match parent 00320226.
  The two earlier baselines name earlier Bats digests, and the report states
  this.
- The k71 brief, k75 and k76 keep the remaining duties. These are root adoption,
  the TextEdit and window block replacement, the downstream confirmations, full
  INT/TERM/HUP handling and both held-pointer signal cases. K67, k62, k57 and
  k54 keep their duties.
