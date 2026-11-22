# Shared Settings scenario and focused prefix review

This is the findings-only review `settings-focused-prefix-k163` of
`settings-focused-prefix-k62`, commit `f731a906`. One finding meets the
acceptance threshold. Nothing in this review is classified as fixed.
The finding concerns required failure evidence, not a demonstrated Koine
failure. No VM, clone, signed subject or runtime slot was used.

## P2-1: ordinary front-check failures omit the required untouched observations

The [ordering protocol](ORDERING-EVALUATION-PLAN.md#input-and-observation-qualification),
lines 187–193, requires a fresh independent failure-observer read, an
agent-window read and a screenshot after a failed assertion, before other
collection. The shared scenario does not deliver that sequence for the resize
front assertion. The k62 comparison omits this shortfall and describes all
remaining gaps at `ORDERING-PREFIX-RESULTS.md:245` as missing controls or
comparisons. This path needs a scenario evidence repair too.

The concrete path is:

1. `scripts/vm-verify-menu-bar.sh:160` calls
   `settings_expect_front resize-front` after the move and focus submissions.
2. `scripts/vm-settings-scenario-lib.sh:558` reads the original front list and
   audits its title. With a complete list showing a titled Koine window behind
   a different front window, the front predicate and the audit return clean
   false states.
3. At line 566 it calls `settings_fail_as not-front`. That handler, lines
   176–183, records an exhausted receipt, calls `settings_failure_capture`
   and exits. The capture function, lines 215–219, sends only a screenshot.
   This path never calls `settings_return_observations`, the function at
   lines 660–667 that supplies the observer and window read for failed
   Settings returns.

This also has a direct counterpart in the plain assertion handler:
`settings_fail`, lines 163–168, records its latch and takes only a screenshot.
For example, the size assertion at `scripts/vm-verify-menu-bar.sh:169` uses
that handler. For an unavailable resize title audit, lines 563–565 call
`settings_stop`, whose fallback also takes only a screenshot. These are
source-derived paths; this review did not inject a new failure or alter tests.

The nearby controls do not establish this duty. In
`Tests/scripts/vm-settings-scenario.bats:199`, the clean not-front control
checks the first Settings return and requires its observer, fresh list and
screenshot before classification. The control at line 646 checks unavailable
title audits at both `reopen-front` and `resize-front`, but its collection-order
assertion at lines 672–676 covers only the reopen. The successful resize control
at lines 576–577 checks the original predicates, not failure collection.
The first-return control cannot evidence the separate resize handler.

**Effect on E, A and k57:** A can consume a slot and stop without the required
untouched evidence of its failing front or size assertion. E also uses the
generic handlers for assertions inside its prefix. A later caller collection
cannot reconstruct the omitted observations at their original point. k57
therefore cannot mark the original failure-evidence duty met from this
comparison. G1–G5 do not name it, and the k57 collection ownership does not
explicitly delegate this synchronous scenario capture.

Integration should triage this against the protocol, reconcile the common
failure paths and their controls, and correct the duty comparison. Preserve
the successful actions, reads, waits and bounds, the original assertion
results, the no-input-after-failure rule and the restrictions on collection
commands. In particular, simply moving the System Events read after a latch
does not supply the missing observation: that read is currently refused there.
The finite caller and runtime remain held.

## Other doubts and their limits

### The boundary check establishes the current bytes

The current quit is at `scripts/vm-verify-menu-bar.sh:154–155`, followed only
by a blank line before resize at line 157. The prefix ends at line 155. The
byte check and its direct-byte control establish this correspondence; both
entry points source the same library from the same directory.

The check is a textual boundary recogniser, not a shell parser. At
`scripts/check-settings-prefix.py:32–33`, a line inside a here-document can
match a command marker. For example, this valid shell fragment contains a
matching quit line but executes no quit:

```bash
cat <<'quit_guest_textedit'
quit_guest_textedit
step "The window resizes: larger"
```

A file ending after the delimiter is the check's expected byte prefix.
This counterexample follows directly from the regular expressions and the
boundary loop; it was not executed. It disproves a guarantee for every future
shell shape. It does not show a defect in the current extracted prefix. The
separate behavioural control at `Tests/scripts/vm-settings-prefix.bats:235`
requires the real quit, absence read and state receipt as the final calls, so
this particular omission would fail the complete check task. Retain both
checks; do not treat the byte check alone as semantic qualification. No
additional repair obligation is raised for this hypothetical edit.

### Normalised calls are a bounded comparison

At `Tests/scripts/vm-settings-prefix.bats:109`, the comparison removes the
root and reduces each local upload path to its basename. Equal normalised
calls alone cannot prove equal roots or uploaded content. The simulator also
replaces the real backend and validates no upload digest. The current source
correspondence and the shared helper path supply evidence beyond that
normalisation; the real upload facade separately retains local identities.
No current E/A root or upload divergence was found in the inspected paths.
The installed and frozen-input audits remain k57's duties. L2's guest-copy
limit remains explicit; this review does not infer byte identity in the guest.

### Existing gaps have written owners

The live `settings-scenario-controls-k164` task names G1–G4 individually,
including strict loop bounds, call counts, the helper scan, typed errors and
held-state/privacy controls. The `settings-ordering-caller-k57` handoff names
G5, the defaults read after each slot, the installed audit after E and receipt
classification. These are pending duties, not passing controls. G5 still
needs the protocol's comparison at the relevant admission point; recording a
declaration or checking only after input is insufficient.

G1's counts need to be applied to the actual call sequence. At
`scripts/vm-settings-scenario-lib.sh:807–831`, a fully exhausted reveal makes
60 iterations, each with an `optional-vertical` read followed by a distinct
`position-y` read: 120 element reads, plus the initial frame read. The phrase
"60 reads" in the handoff must not become a limit of 60 total element reads.
Calibration has one probe scroll and 30 return scrolls, at lines 787–804.
These details clarify the existing G1 control work; they authorise no change
to the source's actions or counts.

The no-download restriction is recorded in
`ORDERING-FILE-LIFECYCLE-RESULTS.md:223–231` and its k150 integration table,
lines 252–253. The keepalive withdrawal is in the cited ADR. Neither source
withdraws the failure-observation duty in P2-1.

### Later ordinary work and the baseline

Inspection compared the complete scenario with `f019161b`, including resize,
content and scrolling, shortcuts, requests, consent, silent launch, reopen,
restart/login and final Quit/port refusal. No additional successful input,
explicit sleep, poll-bound or required screenshot regression was identified
beyond the changes the producer already lists. This is a bounded source
comparison, not native acceptance or proof of unchanged elapsed timing.
P2-1 is an omitted evidence repair, not a claim that k62 deleted a baseline
input or screenshot.

## Evidence and verification

The review read the k62 contract, k36 brief, ordering protocol and each
archived contract k53, k56, k61, k66, k71, k75, k80 and k85 directly.
It inspected the producer's committed changes, the complete scenario,
shared library, relevant facades, controls and recorded verification.

Graph project:
`Users-antony-Development-AbstractingComputers-Koine.gh-issue-14`.
Tier 2 coverage reported generation `2026-11-22T17:29:46Z`.
Exact source reads covered the reported partial shell ranges, including
scenario-library lines 225, 331, 543 and 597. Bats and archived text lacked
tracked graph metadata; they were read directly. The prefix report had changed
metadata and was read directly. Coverage is best effort. Graph traces helped
locate the failure handlers; source, rather than heuristic call edges,
establishes P2-1.

The task explicitly requests reusable checks, overriding the review family's
usual inspection-only restriction on running tests. This review runs only
`mise exec -- task check:vm-settings-prefix check:vm-settings-scenario`.
The command exits 0: nine prefix tests and 33 scenario tests pass, along with
their syntax, lint, format and type checks. The complete output is in
[`task-checks.txt`](ordering-prefix-review-evidence/task-checks.txt).
These controls do not refute P2-1: they do not require the omitted observations
on its failing path. Implementation and test code are unchanged. Existing
producer records remain unchanged.

`mise exec -- task check:docs` reports the two existing missing targets
`context-predicate.txt` and `context-qualify-filter.sh` from
`context-initial-inputs/CONTEXT-PLAN.md`. They remain k23's work. Its retained
output is [`docs-check.txt`](ordering-prefix-review-evidence/docs-check.txt).
No new link failure is attributed to this review.
