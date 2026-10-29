# Snapshot and element evidence expansion

K79 supplies source-only strict snapshot and element readers plus the existing
ten-by-two element poll. K75 remains open with artifact/lifecycle work in k80 and
exec confirmations in k81. K82's review is integrated by k83 below; consume the
current interface and its stated limits. No ordinary scenario or legacy helper has adopted these
readers. There is no initialized scenario root, VM, candidate, freeze or native
acceptance from this work.

The [ordering protocol](ORDERING-EVALUATION-PLAN.md),
[input handoff](ORDERING-INPUT-RESULTS.md),
[window handoff](ORDERING-WINDOW-RESULTS.md),
[physical handoff](ORDERING-PHYSICAL-RESULTS.md) and
[shared adapter](ORDERING-NONEXEC-RESULTS.md) remain binding.

## Interface and payload checks

Source [the library](../../../scripts/vm-ui-evidence-lib.sh). Sourcing defines
functions only; it creates no transcript, process or VM. Every public call takes
an explicit initialized nonempty root from `init_guest_evidence`. Empty, missing
or uninitialized roots refuse with status 125 before dispatch or cwd writes.
Their caller must retain the status and diagnostic because there is no initialized
destination for an ordinal refusal. There is no ambient-root or legacy fallback.

| Function | Qualified result |
|---|---|
| `read_guest_snapshot ROOT CLASS OPERATION WINDOW` | One `agent snapshot --mode full --window WINDOW --depth 14` read; CLASS is `read-poll` or `evidence`. Emits the complete original qualified envelope. |
| `read_guest_element ROOT OPERATION WINDOW CONDITION REQUIREMENT` | One read in class `read-poll`, with the selected-element requirement included in its payload predicate. Emits the first matching element, or `null` in an optional mode. |
| `await_guest_element ROOT OPERATION WINDOW CONDITION STATE` | STATE is `present` or `absent`. Uses optional reads within the existing ten-read/two-second bound; emits no result on success, like legacy `await_element`. |

Each transport uses the reviewed adapter's pinned VM, writer lock, shared ordinal
domain, strict envelope, original streams and CLI status. Full snapshots require
a `windows` array. Every returned window has string application/type, boolean
focus, finite numeric geometry, optional string title and a required element
array. A missing element tree is unavailable evidence, not absence. A valid
empty window list or empty element array can support a bounded negative.

This strict rule also refuses a positive match if any other returned window
lacks its tree. The v2.7.0 macOS agent enumerates windows and then looks each up
again by application name and exact frame; a failed lookup returns that window
without `elements`. Movement, resizing or animation between those steps can
therefore end a settling poll on its first read and latch unavailable, even if
another window contains the target. The legacy projection treated a missing
tree as no match. This is an accepted evidence limit, with unknown native
frequency, not proof of product failure. K80/k76 must retain it when adopting
the Add-button loop; do not retry or treat the omitted tree as an empty tree.

The recursive element checks require string role, boolean enabled/focused,
nonnegative integer child count and a string action array. Optional id, label,
value, description and platform role must be strings when present; optional
showing must be boolean, geometry finite numeric, and children a recursively
checked array. These are field-shape checks, not a reimplementation of the
platform role taxonomy or proof of Accessibility completeness. The fixed depth
can omit descendants; optional child arrays and child counts do not establish
absence beyond that returned tree. No child-count/array-length equality is added.

Selection preserves the existing document order, `platformRole` filter and first
match. CONDITION is caller-supplied jq code, restricted by the caller contract
to the existing single-boolean predicates, including their internal pipelines.
For each candidate with `platformRole`, runtime evaluation requires exactly one
boolean. This is data-dependent, not a general selector validator: with no
candidates, nonboolean, multiple-result or throwing conditions are not evaluated
and can yield a clean negative (or successful absence poll). Syntax errors are
detected only after snapshot dispatch, as unavailable payload qualification,
not a distinct pre-dispatch argument refusal. The characterization controls
retain these limits; a clean empty-tree result cannot validate a new selector.
The existing caller selectors meet the contract. Selection does not add
unique-match semantics or infer target/application identity from the window
argument. Required title/setup/identity audits remain later duties.

| REQUIREMENT | Selected-element contract |
|---|---|
| `optional` | Object or `null`. A missing match is successful data. |
| `optional-vertical` | `null`, or a matching object with finite `positionY` and finite nonnegative `sizeHeight`. For `on_screen`: clean absence/off-screen remains state data; a present match without consumed attributes is unavailable. No x or width is required. |
| `position-y` | Matching object with finite `positionY`. For the required calibration/reveal reads; no height, x, width or value is required. |
| `value` | Matching object with a string value. Empty string is valid; missing value or missing element is unavailable. |
| `geometry` | Matching object with finite x/y/width/height and positive width/height. Coordinate bounds, on-screen placement and requested physical input remain separate checks. |
| `height` | Matching object with finite nonnegative height. The scenario's existing minimum-height assertion remains separate. |

The immutable official v2.7.0 [snapshot handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/agent.rs),
[WindowInfo](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/window_info.rs)
and [ElementInfo](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-protocol/src/element_info.rs)
were read from the official local immutable commit after its manifest. Online
retrieval was unavailable. [Source digests](ordering-snapshot-evidence/official-source.json)
identify the inspected inputs; citations also sit beside the code decision.
This establishes no installed CLI/parser provenance, endpoint or native availability.

The k83 source check also reads the official macOS snapshot lookup, AX value
reader and element encoder at that same commit; the
[agent-source receipt](ordering-snapshot-integration/official-agent-source.json)
identifies those bytes. `value()` returns nil on a failed AXValue copy, and the
encoder omits nil values. Requiring `value:""` after the shortcut cut is a
native-unverified availability assumption. If an actually emptied field omits
AXValue, qualification stops as unavailable; omission never becomes empty.
K76/k67 must retain this distinction and the fixed evaluation's availability
failure rule. Fixtures prove the string check, not native empty-field behavior.

## Poll and local failure outcomes

Only a qualified complete negative advances the element poll. Preserve ten reads
and a two-second sleep after each negative, including the tenth. Transport error,
typed CLI error, malformed/partial payload or nonzero completion stops without
another read or sleep. Polling never sends input or retries a failed submission.

The shared `poll-step` interface records each state decision with its exact
full-snapshot selection predicate and local status. Status 0/1 in phase `state`
means clean true/false, not a transport result. Exhaustion records phase
`exhausted`, local status 1 and outcome `state-failed`; it latches and returns
125. Failed sleeps retain their exact status in phase `sleep`; ordinary failure
returns 125 and local signal statuses 129–192 remain distinct interrupted returns.
Classify these structured fields, not an operation suffix or reason string.

A failed post-validation element decoder emits no usable result and latches.
Ordinary decoder exits are retained in a confirmation reason; signal statuses
are retained structurally as interrupted local state steps and propagated.
Failed decoder output is never used as geometry. Read-poll dispatch after a latch
is refused; evidence-class snapshot collection can preserve context but cannot
restore eligibility. The shared orphan-lock/partial-record limits still apply.
These controls install no complete shell signal handler and do not prove either
held-pointer interruption case.

## Actual callers and adoption boundary

The [bounded candidate inventory](ordering-snapshot-evidence/snapshot-callers.json)
records exact source lines and hashes from the ordinary scenario, common helpers
and desktop helpers, including unused definitions and literal false positives.
It is a direct-source inventory of that surface, not a dynamic-shell or graph
completeness claim. Tier 2 graph lookup and snapshot caller traces preceded source
reads; partial shell parse ranges and unavailable Bats metadata required direct
reads. Original caller bytes stay unchanged in this increment.

| Existing reachable consumer | Required adoption and preserved consequence |
|---|---|
| `snapshot` / `element` | Keep full mode, the current window target, depth 14 and first-match/platformRole traversal. Use optional reads only where clean absence is domain data. |
| `value_of` in shortcut and login-status assertions | Require a matching string value. The shortcut cut must observe the empty string, rather than accept missing data as empty. Keep existing expected strings and inputs/waits. |
| `click` through requests, consent and `reveal_click` | Require complete selected geometry, then validate actual centre coordinates and strict physical click. K80/k76 owe this path; no bare click is qualified here. |
| `on_screen` | Use `optional-vertical` for its one existing read. Return clean status 1 for `null` or a complete off-screen element; propagate unavailable/interrupted reads before evaluation. No second qualification read. |
| `calibrate_window_scroll`, `reveal` | Use `position-y` for each existing required-element read. Keep reveal's distinct preceding `on_screen` read, existing calibration/reveal bounds, scroll actions/waits and k78's checked early returns. Add no read to qualify attributes. |
| Minimum-size scroll-area read | Require the selected height and retain the original minimum-height assertion. No resize or native acceptance follows from a shape check. |
| Request-label echo | Preserve its prefix selector and required displayed id/value evidence; do not let an echo or pipeline hide a failed read. |
| `grant_accessibility` Add-button loop and Koine-list assertion | Preserve the actual selectors and window switch. The Add loop has fifteen reads with fourteen negative sleeps before failure; it is not the ten-by-two helper. Launch and consent confirmations remain k81/k76. |

`await_element`, `text_of`, `place_window`, `create_grant` and
`revoke_accessibility` are shared definitions outside this ordinary scenario's
current reachable closure. The new poll preserves `await_element`'s existing
seam without making it a new caller. `place_window` has a different control-poll
bound; no caller may substitute this ten-read poll for that loop. K76 must map
the final actual callers to their requirements without adding duplicate reads.

## Controls and provenance

The [initial baseline](ordering-snapshot-evidence/baseline-red.json) precedes
production edits and uses the existing bare snapshot/projection routes and the
actual extracted legacy `await_element`. It used an earlier test revision: the
fixture spelled `textfield` incorrectly, and its clean-negative comparison also
included a CLI diagnostic on stderr. Its test 2 failure is not credited as a
behavioral failure. The [corrected baseline](ordering-snapshot-evidence/baseline-corrected-red.json)
fixes those issues and reaches the missing-receipt assertion on clean negatives.
It retains Bats minimum-version warnings from that test revision.

An [intermediate final baseline](ordering-snapshot-evidence/final-baseline-initial-red.json)
also found stderr mixed into the added positive geometry control; that failure
is not credited as a geometry rejection. The control now separates stderr.
The [prior final baseline](ordering-snapshot-evidence/final-baseline-prior-red.json)
records the intervening `5a078f5f…` test revision between the intermediate
`3f4e075c…` revision and the k79 final `1642bab0…` revision. All sixteen tests
fail in that receipt; it is retained as an intermediate run, not the final
formatted subject. The [final-control baseline](ordering-snapshot-evidence/final-baseline-red.json)
uses the k79 final formatted controls and those same test-only bare routes, with
the unchanged legacy poll extracted from the current common helper. It is not a
complete scenario simulation. Each failing loop stops at its first assertion;
neither baseline proves every nested invalid vector independently failed red.
Before/after subject digests and individual results identify each run.

Test 16 deliberately differs between baseline and strict modes. Its baseline
branch calls the bare snapshot with an empty root and expects refusal; its
strict branch checks source-only startup and missing arguments under nounset.
Thus its red is an invalid-root control, not a pre-repair failure of the strict
branch's startup/nounset assertions. No source-only or nounset repair is credited
to that red. The k83 controls are additional tests and do not rewrite these
historical receipts or their subjects.

Passing controls execute the actual new readers, shared adapter, writer store
and jq. Only the external CLI, settling sleep and the explicitly faulted local
projection are substituted. They cover raw bytes/argv/VM/ordinals, empty data,
recursive field types, required attributes, clean and exhausted polls, failed
completion, invalid roots/selectors, sticky failure, collection after failure,
decoder/sleep statuses and adapter interruption. They prove no native response,
window behavior, guest availability or product repair.

The [verification receipt](ordering-snapshot-evidence/verification.json) records
Taskfile commands, full output/status, individual tests and before/after subject
digests. Run `mise exec -- task check:vm-ui-evidence` for this bounded seam.
Both the [initial documentation check](ordering-snapshot-evidence/docs-initial.json)
and the [k79 final documentation check](ordering-snapshot-evidence/docs-final.json) report
the two existing missing archive links in `context-initial-inputs/CONTEXT-PLAN.md`,
already owned by k23. Both nonzero results are retained, not called clean checks.

## K82 review integration

Findings are read from k82's commit `d9a941f8`, against producer `d5e917ca`.
Every finding is accounted for here; no substantial redesign or caller adoption
is included.

| Finding | Disposition and reason |
|---|---|
| P2-1 | Real interface defect. Add `optional-vertical` and `position-y` so each existing read qualifies exactly its consumed attributes while preserving clean absence where allowed. Ordinary caller bytes remain unchanged; k76 must select these modes. |
| P3-1 | Real documentation gap; accept the visible all-tree evidence trade-off. A missing tree refuses positives too and stops a settling poll immediately. Its native frequency is unknown; no weaker negative or retry follows. |
| P3-2 | Real assumption gap. Keep required string values, but state that native empty-field AXValue availability is unverified. Missing AXValue stops qualification and cannot pass the cut assertion. |
| P3-3 | Contract stated too broadly. Narrow selector guarantees to evaluated candidates and state post-dispatch syntax handling. Existing single-boolean selectors need no general jq validator. Characterize empty candidates and syntax failure without changing behavior. |
| P3-4 | Real provenance gap. Link the intervening baseline and docs-final receipt, and distinguish test 16's baseline branch from its strict assertions. Preserve original receipts. |

The [three-control red](ordering-snapshot-integration/vertical-red.json) uses
the unmodified k79 library and the new final formatted controls. Optional
absence and required y-only positive acceptance fail at their intended
assertions. The invalid-attribute control first fails because the unsupported
mode refuses before the expected read. Nested vectors are not each claimed to
have failed red. An [earlier filter run](ordering-snapshot-integration/vertical-red-initial-filter.json)
accidentally selects only two of the three tests; it is retained separately and
supplies no red evidence for the omitted y-only positive control.

The [k83 verification receipt](ordering-snapshot-integration/verification.json)
records the final Taskfile checks, full output, per-test outcomes and stable
before/after subject digests. All 21 UI controls pass, including vertical
absence/zero-height/off-screen/y-only/missing-attribute checks and the two
characterization controls. External CLI and sleeps remain substituted; this
is source/fixture evidence only. The
[k83 documentation check](ordering-snapshot-integration/docs.json) retains the
existing k23 archive-link failures. No native availability, scenario root,
signal qualification or runtime acceptance follows.

## Remaining original duties

K80 retains all remaining OCR, Allow/element physical clicks, captures/background
keepalive, upload/install, environment, lifecycle and collection artifact checks.
K81 retains every exec and clean one-shot confirmation: diagnostics/default exact
values/absence, launch executable/process/start/endpoint identity, silent launch
and same-process reopen, TextEdit quit/absence, clean restart/changed boot,
enrollment/System Events output, installed inventory and final port refusal.
Failed submission cannot be rehabilitated by matching text or later state.
Demonstrated clean-completion infeasibility must hold before E01 for a new
decision without a qualifying guest.

K76 retains complete exact-root adoption and caller migration, reviewed window
helper consumption, whole TextEdit block replacement without duplicate reads,
every assertion/input/wait/bound, complete INT/TERM/HUP handling and both
held-pointer controls. A clean held point without a later clean release means
held input; failed/partial delivery or release retains uncertainty. K57 must
receive ordered untouched receipts and contain the exact clone through the same
writer domain, without bare release, reset or orphan-lock bypass. Secret-bearing
consent roots remain private and must not be published or committed; fixtures
use synthetic data. No redaction weakens required raw evidence.

K67 retains positive TextEdit setup, original-list title audits and separate
same-process zero-window/process-loss outcomes. K62 retains exact final-prefix
correspondence through TextEdit quit before resize and every inherited duty.
K57/k54 and every runtime slot remain held until all harness work, earned
reviews/integrations and whole-harness readiness complete. Historical subjects,
results, strict false joins, failed transports, NOT RUN phases, closed caps and
held causal slots stay unchanged. Native cause, ownership and repair acceptance
remain unresolved; no ancestor closes, release or upstream report follows.
