# Settings workload inventory

## Scope and reading order

This inventory expands the permitted Settings scenario into operations, local
work and retained objects. Read the [workload view](../../design/architecture/settings-activation/keepalive-workload.mmd)
first. Graphs start at the dark **Start here** node. The view explains ordering.
It supplies no model-checking, coordinator or native result.

The [ordering protocol](ORDERING-EVALUATION-PLAN.md) governs the required work.
The [owner contract](../../specs/settings-keepalive-owner.md) governs admission,
failure and stop. The [record schema](../../specs/settings-keepalive-records.md)
governs publication and retention. The [producer contract](../../specs/settings-capture-resource-contract.md)
governs resource units, including work inside one CLI invocation.

The current scripts are a migration baseline. Their twelve-try guest transport,
final curl retry, ignored errors, overwritten keepalive image and destructive
cleanup are not permitted paths. The reviewed strict helpers and protocol supply
the replacement contracts. This inventory adds no input, observation, poll or
wait beyond those contracts. It is a design input, not a frozen executable manifest.

K131 supplies this inventory. K133 reviewed it and k134 integrated the findings.
K132 supplies the [combined scheduling and record derivation](KEEPALIVE-ACCOUNTING.md).
That derivation includes elapsed/tick calculation, carriers, schema and lane costs,
tail requirements, fence constraints and physical-capacity formulas.
K135 reviewed the derivation and k136 integrated its findings. Missing concrete inputs still prevent numerical profile adoption.

K137 supplies the proposed [finite caller plan](KEEPALIVE-CALLER.md), subject to its scoped review and every earned integration.
K125 owns missing evidence scopes. K126 owns final reconciliation. Unknown values below prevent a useful profile. They
are not zeros, defaults or permission to relax requirements.

## Expansion rules

One **operation** is one owner submission that can acquire an attempt ordinal.
One helper can submit many operations. A clean local poll decision is another
operation, even though it invokes no CLI. A lifecycle/control record is not an
operation merely because it consumes terminal space. A producer's internal
frame acquisition is work inside its operation, not another owner submission.

The tables use these primitives:

| Primitive | Required original and result | Proposed family |
|---|---|---|
| `X(command)` | Single exec. Complete raw envelope and command-specific stdout predicate. Guest absence/nonzero domain facts encoded as successful data | Exec, 45/67 seconds CLI/whole |
| `W` | Complete original agent window list, including the list used by the assertion | Read, 30/52 |
| `S(selector)` | Full depth-14 snapshot and the reviewed selected-attribute predicate | Read, 30/52 |
| `I(action)` | One physical input, exact arguments and command-specific acknowledgment | Input, 30/52 |
| `A(action)` | One window move, focus or close and complete action response | Ordinary agent/screen read, 30/52 |
| `C(region)` | One checked logical PNG capture, unique original, validation and result. Optional existing region only | Capture, 30/52 |
| `F(file)` | Exact upload/download input and result, byte count and endpoint identity | Transfer, 120/142 |
| `L(state)` | Original predicate and local status through the poll-step seam, without CLI bytes | Local, 0/22 |
| `D(seconds)` | One unchanged local sleep, with failure/status observation. Successful settling allocates no operation receipt | Local duration. Not another CLI |

These values come from the owner's [operation-family table](../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile).
Window move, focus and close use its ordinary agent/screen read family.

These family values remain provisional until the combined proof. Start has its
own unresolved queue/boot family. No new value is selected here. Every primitive
also needs bounded request/predicate/env bytes, parsing, result delivery and
terminal publications. A caller must not count only its stdout projection.

Each runtime occurrence gets a stable semantic site plus loop index and branch.
The final manifest must bind exact argv, VM, predicate, class, family, source
identity, output roles and all local work for that occurrence. Reusing a
previous original is allowed only where the protocol names that same observation.
It cannot replace an independently scheduled read. Loop maxima below include
clean exhaustion. Failure can retain less output while consuming the full charge.

## Ordered scenario expansion

The source basis is the [ordinary scenario](../../../scripts/vm-verify-menu-bar.sh),
[common helpers](../../../scripts/vm-verify-lib.sh) and
[desktop helpers](../../../scripts/vm-verify-desktop-lib.sh). Helper calls in this
table expand again through the next section. Counts are per started slot, not
multiplied by all five slots as though failure could admit the next one.
The F/O site labels below are phases within a slot. They are not the protocol's
E01/E02 and A01/A02/A03 slot identities.

| Site | Ordered work, including branches and local outputs |
|---|---|
| P00 — Before clone request | Check tools and frozen bundle/inputs. Create the unique private root/transcript and three backing identities. Prepare profile, slots, attachments and collection plan. Establish caller/owner/worker identities and readiness. Retain original/installed/golden audit definitions, full before-slot input inventory and completed golden digests. Local file reads, hashes, directory creation, transcript writer and bootstrap objects need their own bounds. No root means caller-retained refusal, not a fabricated ordinal. |
| P01 — Start | Consume the declared slot immediately before one exact clone-start submission, with the explicit golden/base, display and retained 600-second queue option. Retain requested and actual identity, spec/meta/config and every partial outcome. Worker is ready but has not begun sleep. Clean start enables its first sleep before P02. Queue, provisioning, boot and interrupted-start containment remain separate missing costs. |
| P02 — Environment and installation | Two `X` observations for OS/architecture and Gatekeeper status. Local `ditto` archive creation. Two `F` uploads for archive and verification client. Five `X` operations for extraction, quarantine, signature verification, signature details and assessment. One installed before-inventory `X`, with its full sorted file/link list and completion marker. Upload the enrolment client once. The caller plan additionally uploads and verifies the frozen failure observer before scenario input (one transfer and one exec). Preserve clean domain-negative quarantine/assessment data without allowing failed transport. Bound archive, source, extracted target, transcript and all simultaneous copies. |
| P03 — Diagnostics and Automation | Required effective diagnostic/default/environment reads before first launch. No baseline optional trace-enabling write. One clean Automation-trigger `X`. One Allow OCR invocation. One exact Allow centre click and `D(2)`. One complete System Events confirmation `X`. No second OCR invocation after substring-only or missing exact Allow. <!-- tc: depart synonym-rotation because application launch and worker start name different lifecycle boundaries --> |
| F01 — First launch | One `X(open)`. Endpoint poll. Window-count poll for one. Four further `W` reads in the baseline (printed titles, printed frame, size frame, title assertion). Two System Events `X` reads for background-only and Dock list, one menu-count read, one printed menu-label read, label poll, `read_menu`, then direct first-launch `C`. Launch identity/endpoint confirmation and original-list title audits remain required migration additions. |
| F02 — TextEdit preparation | One `X(open TextEdit)`. The 15-read TextEdit poll plus its unconditional final `W`. `D(8)`. One move to 700,120. `D(1)`. One front-window `W` and one front-application `X`. Freeze the observed TextEdit PID, Untitled geometry and identity facts needed below. No corrective focus or extra settling. |
| F03 — Four selections | For selection indices 0–3: one close, count-zero poll, required positive setup, one `choose_menu_item(Settings…)`, count-one poll, one original front/focus `W`, title audit and route/outcome evidence. Index 0 also has the baseline menu-count read and direct over-TextEdit `C`. The three reopens retain the same document and position. Failure enters ordered collection. It never proceeds to the next close. |
| F04 — Prefix end | One `X(TextEdit quit saving no)` and one clean process-absence confirmation. E ends immediately before resize. Its collection, audits and stop still run. The frozen E source must be the exact repaired A prefix through this quit. |
| O01 — Resize | Move Settings to 40,40. Focus once. Front-window `W`. `D(1)`. Corner drag to 740,940. One frame `W` and growth assertion. Corner drag to 100,100. One frame `W` and minimum-size assertion. One scroll-area `S` and retained content JSON. Direct minimum-size `C`. Both drags expand below. |
| O02 — Scroll and shortcuts | One calibration. Three `reveal` calls for login, grant-label and accessibility. `reveal_click(grant-label)`. Type shortcut. `D(1)`. Value `S`. Three key operations (select/copy/cut). `D(1)`. Empty-string value `S`. Paste. `D(1)`. Restored value `S`. Three keys (select/cut/close). Count-zero poll. Menu-count `X`. Missing AXValue is not empty. |
| O03 — Requests | First enrolment `X`, label poll, `D(6)`, count `W`, `read_menu`, direct 1500,0,420,200 mark `C`. Second enrolment `X`, label poll, `read_menu`, count `W`. Retain both guest client responses, labels and secret-file identities privately. A successful response does not erase failed exec. |
| O04 — Requests navigation and denial | `choose_menu_item(Review 2 Grant Requests…)`. Count-one poll. Front-window `W`. `D(2)`. `read_frame`. `on_screen(request-label)`. Separate displayed-label `S`. Direct requests `C`. Two denial `click` calls, each followed by the existing additional `D(4)`. Label poll. `read_menu`. Keep each click's own two-second settling too. |
| O05 — Accessibility navigation | `reveal(login-launch)`. Close. Count-zero poll. `choose_menu_item(Accessibility Not Granted…)`. Count-one poll. Front-window `W`. `D(2)`. `read_frame`. `on_screen(accessibility-status)`. Preserve original-list title/route/outcome observations for this return. |
| O06 — Consent | One `X(open System Settings pane)`. Add-button poll. System Settings element click. Additional `D(2)`. Password type and Return. `D(4)`. Go to Folder key. `D(2)`. Bundle-path type. `D(2)`. Return. `D(2)`. Add Return. `D(3)`. Koine-list `S`. System Settings Quit key. `D(2)`. Label poll. `read_menu`. Count-one poll. The helper's window target is System Settings only for its snapshot block. |
| O07 — Login option and silent relaunch | `reveal_click(login-launch)`. Status-string `S`. `choose_menu_item(Quit Koine)`. `expect_stopped`. One `X(open)`. Endpoint poll. `D(6)`. Count-zero `W`. Label poll. Separate printed-label `X` and printed-count `W`. The option's clean click and exact status both matter. |
| O08 — Running-app reopen | One `X(open)`. Count-one poll. Original front-window `W` with title and same-process audit. Close. Count-zero poll. No second open or later list replaces a failed outcome. |
| O09 — Quit and restart | `choose_menu_item(Settings…)`. Count-one poll. Original front-window `W`. One Command-Q. `expect_stopped`. Boot-before `X`. One clean restart `X`. `D(30)`. At most 60 boot-after reads, each clean unchanged result followed by `D(5)`. Failed submission stops even if boot later changes. |
| O10 — Login result | At most 24 endpoint reads, each clean absence followed by `D(5)`. Process-list `X`. Endpoint poll. `D(6)`. Menu-count `X`. Label poll. Count-zero `W`. Separate printed-label `X` and printed-count `W`. Background-only `X`. Direct after-login `C`. Retain actual post-restart display and diagnostics persistence. |
| O11 — Final quit and audit | Read the old endpoint port once. `choose_menu_item(Quit Koine)`. `expect_stopped`. One `X(curl)` whose successful payload reports domain code 7. Installed after-inventory `X`. Local item-by-item comparison. The legacy four-try empty-output loop is removed, not counted as permitted polling. Emit final scenario outcome only after all required joins. <!-- tc: depart synonym-rotation because removing a retry loop differs from erasing a failed transport outcome --> |

Baseline failure-message interpolation also re-reads `front_windows` and,
at the first failed Settings return, the front application. Those ad hoc reads
must not precede the protocol's untouched failure observer/window/screenshot
sequence. The repaired caller must bind their retained diagnostic facts to the
ordered collection plan, including any distinct later read it still requires.
Do not remove those facts or count legacy interpolation as an authorised path.

The printed reads in this baseline are real reads. This design does not silently
deduplicate them. A later approved observation reconciliation can share one
original at a named seam. The manifest must record that identity and the removed
duplicate explicitly before taking a smaller count.

## Helper and poll expansion

For a poll with `r` performed reads, record each qualified state decision with
`L`. A failed transport creates no invented clean state. Failed evaluation or
sleep retains its own control and, where possible, local failure record.
Exhaustion adds its named terminal state-failure record. Successful settling
sleeps do not acquire an ordinal. Owner lifecycle reports still cost space.

The migrated window and element interfaces own these distinctions. Pending
confirmation helpers must preserve them too.

| Helper | Expansion and greatest existing local work |
|---|---|
| `await_koine` | At most 15 endpoint `X` reads. `D(2)` after each clean negative, including the last. Add explicit process/executable/start/endpoint joins at the launch contract, not another launch. |
| `await_windows` | At most 10 `W` and 10 state `L`. `D(2)` after each clean negative, including the tenth. Exhaustion once. Counts all Koine windows. Title audit uses the named original separately. |
| TextEdit poll | At most 15 loop `W`, then one unconditional final `W`, including after an early positive. State receipts cover each. Up to 15 `D(2)`. No duplicated final assertion after helper adoption. |
| `await_menu_item_label` | At most 15 System Events `X` reads, with `D(2)` after each clean mismatch, including the last. A missing or malformed answer is unavailable, not a mismatch. |
| `open_menu` | At most five frame `X` reads. Each clean unusable frame takes `D(2)`. The sixth guard fails before any sixth read. One `click_centre` after the first usable frame. |
| `choose_menu_item` | `open_menu`. At most five row-frame `X` reads with `D(1)` after each clean unusable frame. One row `click_centre`. `D(2)`. Add current enabled-target, open-menu image and closed-menu/outcome evidence from the protocol. |
| `read_menu` | `open_menu`. One titles `X`. One Escape. `D(1)`. This is an assertion helper, not a row selection. |
| `click_centre` / `click_at` | Local validated frame/centre. One `screen size`. Move to approach, `D(0.3)`. Move to target, `D(0.3)`. Click, `D(1)`. Invalid geometry stops with a local failure. No pointer target clamping or replacement. <!-- tc: depart synonym-rotation because geometry validation and a checked capture name different operations --> |
| `drag_window_corner` | One frame `W`. One move and `D(0.5)`. Eleven down operations for indices 0–10, with `D(0.2)` after index 0 and ten `D(0.15)` waits. One release and `D(1)`. Total thirteen inputs and 3.2 seconds explicit sleep per completed drag. No failure release on the strict path. |
| `snapshot`, `element`, `value_of`, `on_screen`, `frame`, `front_windows` | Each call performs its own one `S` or `W`, plus local validation/projection. `on_screen` has one optional-vertical snapshot. `value_of` requires the existing string, including actual empty string. Conditional callers preserve read failure separately from false state. |
| `scroll_by` | One scroll input with the current coordinates/direction. `D(1)`. Direction calculation is local. |
| `calibrate_window_scroll` | One frame `W`, before-position `S`, one scroll, after-position `S`, then thirty opposite-direction scrolls. Thus 31 inputs and 31 seconds explicit sleep. Both observed direction branches have those counts. |
| `reveal` | One frame `W`. At most 60 iterations. Each first performs `on_screen` (`S`). A clean false performs a distinct required position `S`, direction calculation, one scroll and `D(1)`. Success returns without that iteration's second read/scroll. Clean exhaustion has at most 120 snapshots and 60 scrolls. Success on read 60 has 119 and 59. Missing target or malformed data stops earlier. |
| `click` | For Koine, first `reveal`. Then one geometry `S`, one direct centre click and `D(2)`. For System Settings, omit only `reveal`. This click has no menu approach moves or screen-size read. |
| `reveal_click` | One explicit `reveal`, followed by Koine `click`, which calls `reveal` again. Preserve both independent bounded searches. They are not one search merely because no explicit input separates them. |
| Add-button poll | At most 15 optional element `S` reads and only 14 `D(2)` negative sleeps. Its failure guard precedes the fifteenth sleep. It is not the unused ten-read `await_element` helper. |
| `expect_stopped` | `D(3)`, one process-absence `X`, one endpoint-absence `X`. Product Quit differs from final clone stop. |
| `enrol` | One guest-client `X` and its complete case/status/response predicate. No replay or stripping a failed transport. |
| `grant_system_events_automation` | The P03 trigger, one OCR invocation, one direct click, `D(2)` and confirmation. No menu approach or extra display read. |
| `grant_accessibility` | The O06 expansion, including the click helper's `D(2)` plus the following additional `D(2)`. It uses seven explicit keyboard/type operations after the Add click. |

The helpers `guest_long`, `launch`, `show_window`, `place_window`, `quit_koine`,
`quit_koine_or_terminate`, `await_element`, `text_of`, `create_grant`,
`revoke_accessibility`, desktop query/witness helpers and `no_consent_dialog`
are not called by this scenario's inspected closure. Their loops, installs,
repeated opens and OCR observations do not supply an extra workload allowance.
Migration must not accidentally import those paths.

The following checks count only complete baseline control flow. They are useful
cross-checks of the expansion, not totals for the repaired scenario:

| Expanded helper or direct artifact | E prefix | Complete A |
|---|---:|---:|
| Direct baseline PNGs | 2 | 6 |
| `await_windows` invocations | 9 | 17 |
| `await_koine` invocations | 1 | 3 |
| `await_menu_item_label` invocations | 1 | 7 |
| `read_menu` invocations | 1 | 5 |
| `choose_menu_item` invocations | 4 | 9 |
| Menu `click_at` invocations, after expansion | 9 | 23 |
| Corner drags | 0 | 2 |
| `reveal` invocations, including nested calls | 0 | 10 |
| Calibration | 0 | 1 |
| `expect_stopped` invocations | 0 | 3 |

The nine A menu choices comprise four prefix Settings choices, Requests,
Accessibility, first Quit, pre-restart Settings and final Quit. The five
`read_menu` calls each add one menu click. Each choice adds two. The ten reveals
comprise three direct reachability checks, two in the shortcut `reveal_click`,
two denial clicks, one before Accessibility navigation and two in login
`reveal_click`. These decompositions expose duplicate-count errors.

## Required additions and internal image work

For each of the four prefix selections, retain the existing original zero-count list.
Retain the positive TextEdit front/PID, Untitled geometry, window subroles/sheets and open-menu enumeration.
Retain a precondition screenshot.

The existing same-list rule can reuse the zero-count list for document geometry. It cannot
invent fields absent from that original. Exact grouping of the System Events
reads, initial identity capture and local decision records must be pinned in the
repaired source. No duplicate extra count poll is permitted.

For every applicable Settings/status selection, retain target identity, enabled
state/frame, derived coordinates, display bounds, open-menu screenshot, closed
menu and original window outcome with title audit. Retain the outcome screenshot
before later input. The ordinary running-app reopen also needs its specified
same-process and titled front-window evidence. The zero-window branch adds one
untouched process-identity comparison. Process loss is a distinct result.

Do not infer a unique new PNG count by adding prose occurrences. Bind each
required image to an exact observation point in the migrated source. An existing
baseline image can discharge an outcome requirement only at that same point,
before any intervening action, with an explicit shared-original binding.
Otherwise both obligations remain.

The six baseline files are first launch,
over TextEdit, least size, mark region, requests and after login. All remain.
The mark crop still follows full-frame acquisition. Failure context and every
due tick add their own unique images.

The external source basis here is TestAnyware v2.7.0 commit
`65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03`, read from immutable local jj objects.
These are source obligations, not installed-binary or native qualification:

| Internal path | Work to retain in the dependency cost model |
|---|---|
| Explicit `C`, including ticks and collection | RFB connection/handshake, wire/decode frame, selected owned frame, crop when requested, PNG encode/output and validation. Preserve simultaneous buffers and the existing held-frame fallback. |
| Allow OCR | One owner operation can contain repeated full-frame capture/PNG encode/recognition/matching cycles on one connection. The pinned screen handler sleeps 500 ms only after an unmatched cycle that has not yet reached its 30-second deadline. It checks the deadline after recognition, so that option is no hard native-call elapsed bound. The successor must count each internal cycle and its temporaries, without adding owner ordinals or a second external OCR invocation. |
| Exact Allow selection | The CLI may finish early on a case-insensitive substring such as Don't Allow. The helper then requires a case-sensitive exact Allow. Failure ends setup. Preserve all returned detections and truncation status. No extra loop to wait for exact Allow. |
| `screen size` in every menu click | The executable handler connects and reads `framebuffer_size`. It does not call the PNG capture helper. Charge connection/frame setup, not an invented saved PNG. Its module comment is not the operation definition. |
| Every physical input | The pinned input handlers call `confirm_input_read` after input. It requests a nonincremental 1×1 update and reads server messages until a framebuffer-update event or its ten-second timeout. Include connection, message/rectangle/decode and temporary work within the input operation. The request size is not an upper bound on actual received messages or allocated frame. Timeout/error warnings remain raw stderr. The CLI keeps its input exit behaviour. This is no extra owner capture or proof of native delivery. A single-axis scroll of magnitude 10 sends 20 pointer events. Typing skips newline characters and sends a down/up pair for each emitted key symbol. Uppercase conversion can emit several symbols for one character. Each shifted character adds Shift down/up events and two 50 ms settles. A nonempty modifier chord adds down/up events for each modifier and two 50 ms settles. These events and sleeps remain internal costs of the existing operation. |
| Snapshot/agent windows | Charge complete response/tree parsing and native agent work. The selected CLI snapshot path calls the agent. It uses no `--open-menu` option and introduces no CLI OCR or PNG capture. Missing trees and empty-AXValue limits still apply. No claim about hidden platform allocations follows. |

The primary decision sites are the pinned [screen handler](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/screen.rs),
[input handlers](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/input.rs),
[input events and confirmation](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/input.rs),
[scroll decomposition](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-rfb/src/keymap.rs),
[connection/warning boundary](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/mod.rs)
and [agent handler](https://github.com/Linkuistics/TestAnyware/blob/65bc05c91cc5d2a6e3d4aa8f81cb2c7c7712fa03/cli-rs/crates/testanyware-cli/src/commands/agent.rs).
The [capture allocation survey](../../research/settings-keepalive-enforcement-a.md#capture-allocations-before-checks)
supplies the deeper codec/lifetime obligations. No dependency implementation is changed here.

## Failure, collection and caller tail

Every scenario boundary has three continuations: qualified progress, clean
negative within its original poll, or terminal failure/unavailability. A failed
transport never takes the clean-negative edge. Interruptions can occur before
assignment, after charge but before commitment publication, during producer work,
or during validation/delivery. Retain each distinct state. An empty directory
does not prove no charge or no execution.

| Path / item | Required work and retained result |
|---|---|
| Start failure or uncertain creation | Keep ticks suppressed, requested exact clone and actual returned identity/partials. Resolve owned holders, then perform only applicable exact-identity collection/stop/inventory. Missing identity or holder proof leaves containment unavailable. No replacement start, guessed clone, alternate writer or unrelated stop. |
| First ordinary failure or signal | Close eligibility and suppress future ticks immediately. Record original failure/control and in-flight/pending identities. A pending unassigned tick has no capture charge. Assigned-but-unpublished ticks retain charge or post-loss uncertainty. Cancellation/refusal still costs terminal records and attachments. |
| Held pointer | Distinguish signal during a down attempt from signal during sleep after clean down. No clean release leaves possible held input. Partial down/release retains uncertainty. Worker stop, failure handling and recovery never issue a release. |
| Holder resolution | Preserve established child/group identity, TERM/KILL/wait outcomes, inherited descriptor observations and actual original-lock acquisition under the one fixed containment window. Unknown targets receive no signal. No unbounded wait or substituted lock. <!-- tc: depart synonym-rotation because fixed describes an unchanged window and does not mean repair --> |
| C01–C03 — Untouched context | When applicable and ownership permits, one independent failure observer, one complete agent window list, one checked screenshot, in that order before other collection. Each is a separate operation/result. Failure of one does not erase it or authorise replay. Later context may be unavailable. The zero-window process comparison belongs in this untouched capture plan without changing the three-item order. |
| C04 — Remaining evidence | Endpoint/process/default/environment observations, installed final inventory, host-input/original/golden audits, required original-to-saved artifact comparisons and retained available archives. The [indexed caller plan](KEEPALIVE-CALLER.md#ordered-collection-plan) expands these duties into exact semantic requests, predicates and original roles. Freeze their executable payloads before implementation consumption. Diagnostics remain disabled and no new native archive is fabricated. Preserve local audit errors separately from guest errors. |
| C05–C06 — Exact containment | One exact requested-clone stop result, then one independent complete VM inventory proving that identity stopped. These do not substitute for product Quit. Additional necessary exact-identity containment is separately declared and charged, never a trial retry or an unbounded fallback. |
| Normal finish | Retain stop intent and pending cancellation if needed. Drain the current sleep or charged tick under its original deadline. Retain matching ack, actual worker exit/reap, all required publications, collection/audits, owner handoff and caller final sequence. No forced sleep shortening or retrospective success label. |
| Failed-owner recovery | The original caller resolves holders and acquires the original lock. It validates backing/frontier and burns failed ranges and uncertain fence members. It writes kinds 25,20,5,20 before delayed observations or a new collection fence. Only plan items proved never fenced may run. One successor. No recovery after caller loss. |
| Final caller | Normal transfer starts final lane with kinds 25,20. Both paths retain kinds 27,20,28. Actual owner response, channel and wait remain separate. Caller return after final publication has no further durable record. Failed final publication or unknown return cannot establish acceptance. |

The [caller specification](KEEPALIVE-CALLER.md) defines 25 ordered collection positions, including conditional failure context, sequence-final golden audit and local classification.

Its original-owner and successor paths share each position once. The caller implementation, frozen executable payloads and qualified local bounds remain missing.
The six summary labels are not six operations.
Each collection item has one plan index, class contribution and applicability
predicate. An already fenced item cannot be repeated by recovery. Normal and
failed tails share duties but do not justify reserving only their successful rows.

## Retained objects and accounting handoff

| Owner / class | Objects and work that must appear in the final expansion |
|---|---|
| Caller bootstrap / terminal | Frozen source/protocol/build/signing/tool/SDK/environment and golden inventories. Exact VM/lock/backing/profile/clock bindings. Fragments, registries, collection plan, tail tables, slot/object layouts. Prepared objects/partials. Transcript and bootstrap process observations. |
| Each assigned ordinary or collection operation | Directory, exact request/argv/env/predicate, raw stdout/stderr, producer request/observations, collector/setup/progress, validated payload, result, compatibility JSON if used, artifacts and all original prefixes. Include bounded raw overshoot/queue contribution and simultaneous temporary capacities. |
| Each pre-assignment submission or control / terminal | Original channel frame, submission/refusal/cancellation/control, status/deadline and process identity. One-use slot and every preassigned attachment, even when no bytes arrive. No phantom operation charge. |
| Captures and OCR | Every required unique PNG and partial. Byte/dimension/checksum/decode evidence. OCR frames/copies/native inputs/results and detection payload. Internal temporary images cost capacity even when they are not saved artifacts. Required originals cannot be deleted or downsampled to fit. <!-- tc: depart synonym-rotation because deleting retained images differs from erasing a failed transport outcome --> |
| Local helpers | Predicate construction, jq/parser/decoder input and output, temporary shell copies, inventory sorting/hashing/comparison, archive construction, sleep/clock/message observations and transcript bytes. Bound lifetime and total work. The CLI count does not cover them. |
| Worker and processes / terminal | Every sleep/phase/tick/stop transition, owned child creation/exit/reap, held-descriptor observation, distinct signal/control, publication carrier and failure fallback. The [completion worksheet](KEEPALIVE-RESOURCES.md#completion-worksheet) names supervisor, owner, worker, sleep child, backend, collector, intermediary/producer and one inherited helper. They can total eight before validators or utilities. Determine which phases overlap. The six-process study envelope is not the workload bound. |
| Final/failed writes | Full consumed slot and attachment reservation, partial setup/objects, bounded write-failure summary, uncertain burned ranges, failed owner/caller observations and missing tail. Settlement/refund or parity-slot reuse is forbidden. |

The accounting successor must derive paths rather than multiply only successful
receipts. It must include every mandatory kind-20 observation and failed-carrier
fallback from the integrated schema, with each write/flush/visibility cost in its
actual lane and deadline. Kind 7 costs `856 + 168u`. No per-attempt terminal range
is added to it. `q` includes first failure and later distinct controls.

Use the schema's `T_data`, data-object and physical-rounding formulas across all
reserved slots, including skipped, failed and uncertain attachments. Supply
finite vector/object maxima, lane-specific path maxima and remaining-tail tables.
Neither the study's 4096-byte slot nor its eight-ordinal fence supplies a default.
No physical metadata, map, native, queue or backing cost is assumed zero.

Start's 600-second queue and bounded boot/provisioning belong before the first
worker sleep. Post-start environment, packaging and uploads belong inside the
tick-active workload. From first sleep intent to tick suppression, bound every
scenario admission/operation, explicit wait and local computation. Count tick
service once: waiting behind the worker is already in scenario admission.

Keep due, assigned/charged and published-commitment tick counts distinct. Include
the longest failing prefix and bounded failure detection, not only the clean
scenario. Stop drain, collection and final tail retain separate time/capacity.
They cannot start another tick after suppression.

The derivation separately bounds time without a live tick for tighter tick sizing.
Its [baseline wait table](KEEPALIVE-ACCOUNTING.md#baseline-explicit-wait-cross-check) includes menu frames, clicks and settling.
Those conservative wait envelopes supply neither full elapsed bounds nor a useful numerical profile.

These exact inputs remain missing:

- The repaired source/confirmation grouping and payloads.
- The implementation of the specified finite caller plan and its frozen request/object manifest.
- Complete local/transcript costs.
- Internal OCR/message/frame limits.
- Producer unit/version/lifetime evidence.
- Intermediary install-map and actual producer exec-setter floors.
- The raw queue and temporary-memory bound.
- Native/service coverage.
- Physical storage metadata, flush/visibility latency and protected-capacity evidence.

K125 scopes the external evidence.
The [combined accounting](KEEPALIVE-ACCOUNTING.md#exact-inputs-still-required)
assigns every remaining input. K126 retains useful-profile fit.

## Evidence boundary and review questions

The bounded source inventory covers the named scenario and its reachable helper
closure, not arbitrary shell evaluation or the repository as a whole. Tier 2
graph search and start traces preceded source checks. Koine coverage generation
`2026-11-01T03:30:50Z` reports partial shell parsing at scenario line 169 and common line 175.
It also reports desktop lines 21/52/60/84/150/156/169/176/183, input facade line 27 and physical facade line 42.
Direct reads covered those ranges and the entire named
scenario/helper bodies.

Graph edges to a documentary `testanyware` symbol are
not executable call evidence. The external graph at `2026-10-29T07:11:24Z` has
no recorded gaps in the producer's original dependency files. Immutable tagged reads,
not that absence, establish the cited source behaviour.

Review must challenge loop endpoints, nested reveal and pointer multiplicities, all six baseline images, internal input-update/OCR work and unchanged waits.
It must challenge same-original reuse versus independently required reads and both failure tails.
It must also reject an unsupported numeric total or any deletion of inherited
work hidden as deduplication. The [raw controls](KEEPALIVE-RAW-CONTROLS.md) and
[recovery controls](KEEPALIVE-RECOVERY-CONTROLS.md) remain reviewed inputs. Their
fixture setup/sentinel/collection work is separately counted in their later
executable manifests, not added to an E/A production slot.

The smaller alternative was to multiply helper calls by one generic cost. It
loses nested polls, local records and indirect frame work. A fully instantiated
byte budget now would require invented caller and native/storage inputs. The
selected inventory preserves source counts and explicit unresolved parameters.
When its exact implementation or qualified evidence arrives, revisit each missing parameter.
Then reconcile each item before profile adoption.

All native/runtime, privacy, history, closed-cap and original-duty holds remain.
This artifact establishes neither useful fit nor Settings repair acceptance.

## Verification

On 2026-11-01, the local viewer rendered the current workload diagram through its
caller-tail and unavailable-profile endpoints. Both topic and parent manifest
entries resolve to the editable source. Manifest checks found no duplicate topic
IDs and checked the current-discussion link.

`mise exec -- task check:docs` returned task status 201 (checker status 1), with
only the two existing missing targets in `context-initial-inputs/CONTEXT-PLAN.md`:
`context-predicate.txt` and `context-qualify-filter.sh`. Those archive defects
remain k23's work. No VM, mechanism control or native experiment ran.
