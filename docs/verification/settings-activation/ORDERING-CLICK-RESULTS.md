# OCR and physical click evidence

K84 supplies source-only checked OCR and physical Allow/element click helpers.
K80 remains open: k85 owns captures, background keepalive, files, environment,
lifecycle and collection receipts. Independent review and every earned integration
precede downstream consumption. No ordinary caller or scenario root is changed.
These controls establish no native availability, VM outcome or repair acceptance.

The [ordering protocol](ORDERING-EVALUATION-PLAN.md),
[snapshot contract and k83 integration](ORDERING-SNAPSHOT-RESULTS.md),
[physical handoff](ORDERING-PHYSICAL-RESULTS.md),
[input handoff](ORDERING-INPUT-RESULTS.md) and
[shared writer/adapter](ORDERING-NONEXEC-RESULTS.md) remain binding.

## Interface

Source [the library](../../../scripts/vm-click-evidence-lib.sh). Sourcing defines
functions only. Every public call requires an explicit nonempty root initialized
by `init_guest_evidence`; an invalid root refuses with 125 before CLI dispatch or
cwd writes. The caller must retain this status and diagnostic because no ordinal
destination exists for that refusal. There is no ambient-root or legacy fallback.

| Function | Qualified result and preserved operation |
|---|---|
| `read_guest_text ROOT OPERATION QUERY [30]` | One `screen find-text QUERY` invocation, optionally with the existing `--timeout 30`. Emits the complete original qualified envelope. An empty detection array is clean data. |
| `click_guest_allow ROOT OPERATION` | One OCR invocation for `Allow` with timeout 30, first exact `text == "Allow"` detection, one centre click, then the existing two-second settling sleep. |
| `click_guest_element ROOT OPERATION WINDOW CONDITION` | One reviewed `read_guest_element` with requirement `geometry`, one centre click, then the existing two-second sleep. Call only after the existing caller-owned reveal, when applicable. |

OCR and snapshot reads use `read-poll`; physical clicks use `one-shot`. Both share
the adapter's pinned VM, writer lock, ordinal domain, exact argv, raw stdout/stderr,
CLI completion, predicate and terminal result. A failure latches and prevents
later scenario dispatch. No helper retries a failed completion or adds a read,
input, wait or shell poll. Click helpers emit the original qualified click
response on success, rather than the preceding read. Successful settling adds
no ordinal, matching the other physical helpers.

OCR qualification requires the exact query, a nonempty string engine, a detection
array, `truncated:false` and nonnegative integer `returned` equal to both `total`
and the array length. Every detection has string text, finite numeric x/y/width/
height/confidence and nonnegative width/height. These are field-shape checks;
there is no new confidence threshold or recognition guarantee. Typed CLI errors,
partial JSON, dry-run envelopes and unsuccessful CLI completion are unavailable,
even if they contain matching text. A complete empty array supports the existing
negative consent assertion; absence of an exact Allow cannot satisfy a required
click and latches without input.

The selected target must have positive width/height. Coordinates retain the
original `floor(x + width/2), floor(y + height/2)` formula and must be finite and
within the CLI's inclusive 0–65535 range. Negative rectangle origins can still
produce a valid centre, as before. No display read or new display-membership
assertion is added. The exact click acknowledgment must echo both coordinates,
`button:"left"` and `count:1`. This is the existing direct single click for these
callers; the separate menu pointer route keeps its own approach moves and waits.

Failed local centre decoding emits no usable coordinates. Ordinary decoder
failure records a confirmation failure, including the exact local exit in its
reason. Signal statuses 129–192 instead retain the exact structured local status
as an interrupted `poll-step`. Failed settling records phase `sleep` and the
exact status; ordinary failure returns 125 and signal statuses propagate.
Neither path sends later input or clears the latch. Inspect `poll_phase`,
`local_status` and outcome fields for local interruptions. These checks install
no complete shell signal handler and prove neither held-pointer signal case.

## Source evidence and limits

The immutable official v2.7.0 workspace manifest was read before the
[screen handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs),
[detection value type](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-ocr-client/src/detection.rs)
and [input handler](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/input.rs)
at the local official commit. [Source digests](ordering-click-evidence/official-source.json)
identify the inspected bytes; citations also sit at the code decisions. This is
no installed executable, agent, endpoint, native response or golden provenance.

The screen implementation passes its effective limit, default 100, to the result
serializer even with a query. Its adjacent comment claims query results always
pass an unlimited value, but the executable call path does not. Qualification
uses the actual returned counts and truncation flag. A truncated response stops;
there is no `--all`, replacement capture or retry to obtain complete data. The
existing timeout performs internal 500 ms OCR polling until a match or deadline;
it is retained unchanged within one recorded CLI invocation. No successful
completion can be inferred if that invocation fails.

Element click inherits every reviewed snapshot limit: required trees on all
returned windows, first-match/platformRole traversal, fixed depth and selector
evaluation only on present candidates. Missing trees refuse positives as well
as negatives. During movement/animation the agent's exact-frame lookup can omit
a tree; native frequency is unknown. K76 must retain that immediate unavailable
stop in the Add-button loop, without retry or negative inference. Empty-field
AXValue after cut remains native-unverified: omitted AXValue is unavailable,
never empty. K76/k67 retain that limit and the fixed evaluation stop rule.

## Bounded callers and adoption

The [candidate inventory](ordering-click-evidence/callers.json) identifies exact
lines and original source digests in the ordinary scenario, common library and
desktop library. Tier 2 graph discovery, bidirectional click traces and exact
snippet preceded direct source reads. Coverage generation at initial lookup was
2026-10-29T08:49:50Z; partial shell ranges and unavailable Bats metadata required
direct reads. The trace also contains unrelated callers and a spurious jq edge.
The inventory is bounded source evidence, not a dynamic-shell or whole-graph
completeness claim. Original caller bytes remain unchanged.

| Existing path | Required later adoption |
|---|---|
| `grant_system_events_automation` | Replace only its OCR/Allow-click/two-second-sleep block with `click_guest_allow`. K81/k76 retain the clean single exec trigger and positive complete System Events confirmation; neither is supplied by a click acknowledgment. |
| `no_consent_dialog` (shared, outside the ordinary scenario's current closure) | If this shared helper is adopted, keep its preceding three-second wait and one immediate OCR read for `would like to control`, followed by its existing zero-total assertion and process/context read. Do not add this unused assertion to the ordinary scenario. |
| `click` via scenario denial rows, `reveal_click`, and `grant_accessibility` Add | Replace only the final geometry-read/direct-click/two-second-sleep block with `click_guest_element`. Keep the existing reveal before it for Koine; System Settings skips that reveal. |
| `reveal_click` through shortcut, login and accessibility controls | Preserve its explicit reveal and `click`'s existing additional reveal when no alternate window is selected. Do not remove either or add a new qualification read in this expansion. |
| `grant_accessibility` Add-button loop | K76 still owns its fifteen optional reads and fourteen negative sleeps, followed by the separate existing required geometry read for the click. Do not substitute the ten-by-two generic element poll. |

`create_grant`, `revoke_accessibility` and other shared definitions have additional
click callers outside this ordinary scenario's current reachable closure. They
are not migrated or claimed ready by this increment. K76 retains all snapshot,
value, vertical-position, scroll-chain and caller-status adoption, including
`optional-vertical` and `position-y` without duplicate reads.

## Controls and provenance

The [initial baseline](ordering-click-evidence/baseline-red.json) runs fourteen
controls before production edits against test-only bare OCR/Allow routes and the
unchanged extracted legacy `click`. The exec trigger and confirmation are outside
this comparison. All fourteen fail: raw receipts/pinned argv are absent, or a
required refusal/latch is missing. The comparison is a bounded helper seam,
not a full consent or ordinary scenario simulation.

The [retained initial assertion failure](ordering-click-evidence/initial-sleep-assertion.json)
reproduces a test-only field typo: it checks `phase` where the shared request
actually records `poll_phase`. Only the assertion changed. This is not evidence
of a production sleep-recording repair.

The [final bare-route comparison](ordering-click-evidence/final-baseline-red.json)
uses the final formatted tests: sixteen fail, while the new source-only/nounset
characterization explicitly skips. It provides no legacy startup-repair credit.
Each loop stops at its first failed assertion; neither baseline establishes an
independent red result for every nested malformed vector. Before/after digests
identify every comparison's subjects.

Passing controls execute the real adapter/store, jq, reviewed snapshot reader
and new helpers. Only the external CLI, settling sleep and explicitly faulted
local centre projection are substituted. They cover original bytes, exact VM/
argv/ordinals, complete empty OCR, count/shape/truncation refusal, first exact
Allow, floor-centre coordinate limits, click echo/completion, one required
element snapshot, missing tree/attributes, local decoder/sleep failure and
interruption, sticky refusal, invalid roots/arguments and source-only nounset
startup. They establish no native OCR accuracy, input delivery or scenario readiness.

Run `mise exec -- task check:vm-click-evidence`. The
[verification receipt](ordering-click-evidence/verification.json) records the
Taskfile commands, full outputs/statuses, individual tests and stable before/
after subjects for the new and shared-helper regressions. The
[documentation check](ordering-click-evidence/docs.json) retains its actual
outcome; the existing two missing archived-context targets remain owned by k23.

## Remaining original duties

K85 retains every capture, including background keepalive, unique complete
readable artifacts, upload/install/file identity, environment, lifecycle and
collection receipt. A clean capture payload alone establishes no artifact.
K81 retains every exec/one-shot consequence: defaults exact values/absence,
diagnostics disabled, executable/process/start/endpoint launch identity, silent
launch/same-process reopen, TextEdit quit/absence, clean restart/changed boot,
System Events/enrollment output, installed inventories and final port refusal.
Failed submission is never rehabilitated by matching text or later state.
Demonstrably unavailable required completion holds before E01 for a new decision.

K76 retains complete exact-root adoption, all actual caller migration and
assertions/input/waits/poll bounds, complete INT/TERM/HUP handling and both
held-pointer cases. Clean down without a later clean release means held input;
failed/partial input or release retains uncertainty. K57 receives untouched
ordered receipts and contains the exact clone through the same writer domain,
including orphan-lock refusal, without bare release, reset or bypass.

K67 retains positive setup, original-list title audits and same-process
zero-window versus process-loss outcomes. K62 retains exact final-prefix and
whole-duty reconciliation. K57/k54 and every runtime slot remain held until all
harness work, independent reviews/every earned integration and readiness finish.
Secret-bearing consent roots remain private and must not be published or
committed; these fixtures use synthetic data. Historical subjects/results,
failed transports, NOT RUN phases, strict false joins, closed caps and held
causal slots stay unchanged. Native cause, ownership and repair acceptance
remain unresolved; no ancestor closes or upstream report follows.
