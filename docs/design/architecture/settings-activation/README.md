# Settings activation design discussion

The current discussion is [the proposed scheduling profile](../../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile).
The owner serves requests in receive order, after failure and stop controls.
Admission expires after 150 seconds. Ownership continues through complete validation
and result publication. The reviewed lifecycle still requires matched normal-stop
intent, acknowledgement, actual exit and published reap. Enforceable resources
and whole-design reconciliation remain outstanding.

The
[binding hold](../../../specs/settings-activation-discrimination.md#keepalive-coordination-hold)
still prevents adoption and runtime.

The [current contract](../../../specs/settings-activation-discrimination.md#single-request-ordering-design)
defines one shared-method reversal: prepare the retained window and section,
request activation once, then request key/front ordering without deferral.
The [distinct finite protocol](../../../verification/settings-activation/ORDERING-EVALUATION-PLAN.md)
sets two focused guests and, only if both qualify, three separately declared
complete ordinary guests. Both sets use the same newly signed candidate with
application diagnostics disabled. No signed evaluation subject has been built or run.
The [application implementation](../../../verification/settings-activation/ORDERING-APPLICATION-RESULTS.md)
now compiles and passes existing headless controls. Shared harness repairs and
native acceptance remain live.

Antony approved the named empirical scope and finite acceptance convention.
The [review and integration](../../../verification/settings-activation/ORDERING-REVIEW.md)
are complete. K36 implements and verifies the candidate and evidence helpers
before freeze. A qualified recurrence rejects reversal. Any
other required failure or unavailable evidence stops acceptance and all later
slots. No replacement or cap expansion follows.

A complete pass supports only
that sample, not mechanism, risk reduction or general reliability.

Native cause and ownership remain unresolved. All six causal slots remain held.

Both sets use the same repaired scenario: strict single-attempt transport,
positive TextEdit setup, an original-list Settings-title audit and a separate
process-loss outcome. Zero-window rejection needs clean liveness. The focused
prefix includes TextEdit quit and ends before resize. Screenshots retain context.
they are not automatic acceptance assertions. Launch/defaults/restart need clean
submission and their named confirmation.

Restart disconnect remains unavailable despite a later boot. A demonstrably unavailable required completion holds E01
for a new decision. No failed read is repaired by retry.

Run `mise exec -- task design:serve PORT=8803` from the repository root and open
[the current discussion](http://127.0.0.1:8803/settings-activation/#discussion).
The existing task serves only the architecture presentation directory.

<!-- tc: depart synonym-rotation because graph entry differs from application launch -->
Start each graph at the dark **Start here** node.
The sequence starts at its first message. State views start at the initial dot.
The ordering sequence shows the implemented application call order,
not measured native completion. The assessment numbers the assessed original call order before
its dotted reasoning edge. Other graphs describe decisions or outcome rules.

None is a proven causal graph. The sources are editable Mermaid. The viewer
loads Mermaid 12.0.0 from jsDelivr and needs network access.
Reload after editing. No export build is used.

The local index links to the shared viewer, and the
[parent outline](../index.html#diagram-settings-activation-ordering-sequence)
loads these same sources while retaining its separate current discussion.

Current changes:

- [Keepalive → Serve the oldest request within its deadline](http://127.0.0.1:8803/settings-activation/#diagram-keepalive-scheduling) — Adds receive-order arbitration, admission expiry and whole-operation ownership.
- [Keepalive → One owner controls dispatch and evidence](http://127.0.0.1:8803/settings-activation/#diagram-keepalive-owner) — Distinguishes proposed scheduling from unresolved resource enforcement.
- [Scheduling and deadline profile](../../../specs/settings-keepalive-owner.md#scheduling-and-deadline-profile) — Defines phase budgets, stop/drain deadlines and unresolved containment.
- [Scheduling evidence](../../../verification/settings-activation/KEEPALIVE-SCHEDULING.md) — Adds source/API limits, alternatives, useful controlled schedules and required boundary controls.

Unchanged context includes the [worker lifecycle](http://127.0.0.1:8803/settings-activation/#diagram-keepalive-lifecycle)
and [evidence limit](http://127.0.0.1:8803/settings-activation/#diagram-evidence-limit).
The [design evidence](../../../verification/settings-activation/ORDERING-DESIGN-EVIDENCE.md)
links the source/API reads and [verification receipt](../../../verification/settings-activation/ordering-design-evidence/verification.json).
The [raw documentation output](../../../verification/settings-activation/ordering-design-evidence/doc-links.txt)
retains the actual check result. These checks establish document consistency,
not native behaviour, product repair or ordinary acceptance. Earlier receipts
remain historical and unchanged.
