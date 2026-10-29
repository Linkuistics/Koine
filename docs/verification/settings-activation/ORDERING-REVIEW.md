# Ordering design review integration

The k50 findings were read from review commit `1b276dcc`, against producer
`e3194ff8`. K51 repairs the [protocol](ORDERING-EVALUATION-PLAN.md),
[contract](../../specs/settings-activation-discrimination.md), glossary,
presentation and current handoffs. K36 owns the application/scenario/helper
implementation and its verification before any freeze. No guest, product change,
test or build ran in this integration.

## Dispositions

| Finding | Verification and disposition |
|---|---|
| P1-1: hidden transport retries and discarded one-shot results | **Real issue.** The source `guest` retries CLI 255/7 up to twelve times; `guest_text` strips reports; `guest_once` and restart discard completion. `await_windows` conflates failed reads with negative counts. The protocol now explicitly requires replacement at those existing helper/call-site boundaries in both E and A. Three transport classes and the launch, silent-launch, reopen, menu, defaults and restart confirmations are fixed before implementation. |
| P1-1: permit retries for idempotent reads | **Visible trade-off; proposed relaxation not adopted.** A required state read is evidence even when idempotent. Retrying its failed transport until one succeeds would weaken the approved unavailable-evidence rule. Only clean negative state observations continue within existing poll bounds. All failed attempts remain failed and block acceptance. False timeouts can end the sample before a product observation. The helper's approximate historical timeout frequency does not prove every future slot must fail; no passing availability claim is made either. |
| P1-1: restart confirmation | **Visible trade-off.** The existing one-shot shutdown needs clean submission and changed boot identity. A disconnect or missing completion remains unavailable even if reboot occurs. No new expected-error exemption, detached restart or extra delay is introduced. If k36 establishes from implementation evidence that the required completion is unavailable, it holds before E01 and returns that precise gap for a new decision. A new transport standard would exceed this repair. |
| P2-1: missing positive TextEdit setup | **Real issue.** The scenario checks non-Koine front state once and no positive precondition before each reopen. The protocol now mandates the same structured setup checks in the changed full scenario and extracted prefix: zero Koine windows, TextEdit front/PID, one standard Untitled window with unchanged observable geometry and no document actions, no dialog/sheet or open menu. It names the agent-list/System Events oracles, unavailable cases and screenshot audit. The agent list contains no window ID; the protocol claims observable continuity only. The prefix includes TextEdit's existing quit and ends before resize. |
| P3-1: overstated front predicate | **Contract stated unclearly.** `koine_in_front` checks app name and focused on the first non-Notification-Center entry; the count helper counts all Koine windows. Neither checks title. The protocol describes these exactly and adds a required audit of the original front/focus list for one `Koine Settings` entry. An outcome screenshot is retained context, not an automatic acceptance assertion; rejection requires visual corroboration. |
| P3-2: zero windows conflates process loss | **Real issue.** A clean click/menu closure does not rule out Quit misdelivery or a crash. Zero-window rejection now also needs one clean same-process liveness read before intervention. Process loss has its own failed assertion; failed/missing liveness is unresolved. Neither qualifies an ordering recurrence. No crash-versus-misclick or callback claim follows. |
| P3-3: missing glossary entries | **Real issue.** Add qualified recurrence, focused evaluation and ordinary acceptance to `CONTEXT.md`, with links to their normative criteria. |

The setup queries are requirements for k36's existing read-only helper seam,
not claims of guest qualification. Source/fixture checks must expose unsupported
fields before freeze; E01 still owns the finite availability control, with no
replacement if it fails. Supplemental screenshots can invalidate conflicting
setup, but cannot replace a failed structured observation. No new input wait or
human-response pause is selected.

## Evidence boundary and preserved duties

Graph startup refused before project, generation or coverage could be obtained.
Bounded direct reads covered the complete scenario and its guest, menu, window,
poll and pointer helpers. The retained persisted failure window list confirms
`Untitled`, `windowType`, geometry and focus fields, but no PID/window identifier.
Its native response confirms the raw `ok`, `exit_code` and `timed_out` envelope
names. These saved bytes are source/schema evidence, not new qualification.

No API choice or application call order changes in this integration. The
[original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
still binds: one selection/one request/one front-focused window; all excluded
classes; actual signed/all-input/completed-golden freeze; every failed transport,
partial and NOT RUN phase; original/endpoint/golden audits; exact clone stop;
separate complete ordinary acceptance with diagnostics disabled. Two focused and
three ordinary slots, the single candidate, finite convention and rejection
precedence are unchanged. No new slot, replacement or baseline is added.

Historical candidates, source overlays, results, strict false joins and closed
caps are unchanged. All six causal slots remain held. Native cause and ownership
remain unresolved; no product or causal ancestor closes. No ADR is added: these
repairs are reversible and do not meet the hard-to-reverse criterion. No release,
notarization or upstream report follows.

## Verification

The sole narrow fresh-context reviewer examined the amended transport section
against the approved convention and existing helper/restart behavior. It found
no issue in that scope; it treated possible restart infeasibility as an explicit
unresolved outcome, not a promise or permission to weaken the standard. This is
one aimed contract review, not guest or product evidence.

The [verification receipt](ordering-review-evidence/verification.json) records
document checks, source/manifest comparisons and presentation inspection with
their limits. The known archived-context link failures remain k23's separate
work; no historical archive is rewritten to clear them.
