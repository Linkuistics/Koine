# provider-architecture-k49

**Integrates:** provider-architecture-k48

## Goal

Triage `provider-architecture-k48`'s review of the cross-cutting provider
architecture, and apply the real findings before `launch-and-open-k18` builds on
it.

## Context

- Read the findings from `provider-architecture-k48`'s own commit. Its
  coordinates name producer commit `53ed64968d40` (`provider-architecture-k5`);
  that review's `leaf-insert` renumbered the `.grove` siblings, so resolve
  handles for current paths.
- `provider-architecture-k5` is the design producer. The artifact is
  `docs/specs/workflow-providers.md`, the extension sections of
  `docs/specs/machine.md`, `docs/adr/provider-authority-follows-effects.md` and
  the reworked server, reference and resilient-framework ADRs.
- `docs/requirements/modaliser-workflows.md` and `plan-k4`'s integrated
  decisions govern scope.

## Done when

Each finding is classified as a contract stated unclearly, a real issue, a
visible trade-off or noise. Justified changes are applied to the spec set and
ADR set as `ADR-FORMAT.md` and `SPEC-FORMAT.md` direct, keeping the downstream
charters consistent with them. The reasoning for findings not applied is
recorded. Any question that changes agreed requirement text, the signing
posture or what `koine-desktop/1` promises existing clients is raised with
Antony, with a recommendation.

## Notes

This is design integration, not implementation. Do not treat the reviewer's
suggested corrections as a preapproved work list. Assess the evidence and choose
the smallest coherent correction. A finding that needs the architecture
rethought rather than repaired becomes a new design review chain, not an
unreviewed redesign here.

## Decisions (running log)

Read `provider-architecture-k48` from commit `e968bdd97123`, against producer
`53ed64968d40`. The workspace began empty on the review commit. Tier 2 graph
verification uses generation `2026-09-29T10:36:20Z`; the checked Composition,
Authority and management-UI sources match index metadata. Documentation is
excluded from the graph and has been read directly.

D1 is a real issue: RequestReviewView exposes approval controls through the
same native UI the Machine contract treats as the trust root. Require input,
menu and other UI-driving operations to refuse Koine's own process and known
consent/security targets before effects. This repairs the direct provider route;
it is not a sandbox for arbitrary applications or the accepted native races.

D2 and D3 are real allocation gaps. Space switching is a bounded system
operation, owned by input but requiring desktop control as well; ordinary
application input remains separately grantable. Pointer button synthesis needs
input authority wherever exposed; movement without buttons and system-defined
media events retain desktop authority. Display focus cannot silently click.
Evidence must address fall-through and refusal before a system chord is shipped.

D4 is a real inconsistency. Asked Antony whether to state one selected-effect
rule for all providers and explicitly accept application reactions as a limit.
The requirements and that rule remain unchanged until his answer.

Antony answered **"Accept the clarified boundary (Recommended)"**. Apply one
rule: Koine-selected effects include the native primitive's documented semantics,
parameters, preparation and fallback; application-defined reactions are not
sandboxed. Record that limit in the requirements and apply it to tools as well
as generic input/menu operations. Source inspection of native call paths plus
VM outcomes is the discriminating evidence; a focus change alone is not.

D5 is a contract stated unclearly: admission must include every possible cleanup
mechanism's static authority. Autonomous termination is bounded by that admitted
interaction; it creates no exemption for Escape or pointer input. Menu-only
paths still need a native menu cleanup mechanism.

D6 is a real issue in the extension contract: new consent diagnostics must be
scoped to new operations, leaving baseline desktop values unchanged; all reads
must avoid consent prompts. Search must distinguish complete empty results from
partial coverage and permission refusal. Concrete new consents or entitlements
remain the evidence owners' questions for Antony, not approved by this repair.

D7 is real. Source confirms bundled-first canonical ordering, reserved desktop
identity and duplicate-claim refusal. Repair the ordering and failure-cascade
text here. Selecting independently upgraded first-party bundles changes loader
selection and trust semantics: commission a bounded design/review chain before
launch-and-open rather than inventing that policy inside integration.

D8 is a contract stated unclearly. Preserve the singular diagnostic and define
the extension's deterministic order; add the complete required set alongside it
for clients, without claiming schema introspection exposes field authorization.
D9 is real: assign grant disclosure to the first increment adding each authority,
with explicit acceptance and broad input/menu reach stated in user language.

D10 is a visible presentation trade-off. The review established deep links and
dark-mode rendering. Mobile fit cannot make a whole architecture legible; retain
zoom/native-size navigation, state the textual Start here cue independently of
colour, and reduce avoidable padding where the source layout permits it. This
is presentation evidence only, never workflow acceptance.

Commissioned `first-party-provider-selection-k50` immediately before the
launch-and-open node. It owns the remaining D7 selection/trust design and must
cut its review before launch-and-open consumes it. The shared spec and server
ADR now explicitly expose that unresolved promise instead of implying that
same-team loading already supplies replacement precedence. No signing or
existing desktop-client behavior was changed here.

## Findings triage

| Finding | Classification and disposition |
| --- | --- |
| D1 | Real issue. Specify direct self-target and recognized consent/security-UI refusal, `unavailable` / `protected-target`, and public/VM cases owned by input, menus and context menus. State recognition, platform-race and general application-control limits; do not claim a same-user sandbox. |
| D2 | Real issue. Split bounded system Space switching from captured application input; require input plus desktop control. App-input evidence owns disabled/remapped binding refusal and fall-through evidence; any new limit returns to Antony. |
| D3 | Real issue. Allocate pointer-button synthesis to input wherever exposed, movement without held buttons and system-media events to desktop. Forbid a silent display-focus click fallback and preserve menu-only paths. No general click API added. |
| D4 | Real issue, with an accepted trade-off. Antony accepted the clarified selected-effect/application-reaction boundary. Apply it uniformly and require inspected native call paths plus discriminating VM outcomes. Requirements record the limit. |
| D5 | Contract stated unclearly. Include all supported cleanup mechanisms in admission's static set. No new authority exemption or post-revocation fallback; menu-only cleanup requires a native route. |
| D6 | Real issue. Scope extensible consent diagnostics to new operations, preserve desktop values, forbid prompts through all reads, and require per-root partial/unknown search coverage. App-side enablement is a dependency. Concrete consent/signing decisions remain with their downstream evidence and Antony. |
| D7 | Real issue. Repair bundled-first order, rejection cascade and startup-failure distinction. Externalize first-party reservation/update precedence to the bounded design/review chain at `first-party-provider-selection-k50`; launch-and-open owns implementation after that chain settles. |
| D8 | Contract stated unclearly. Define deterministic first-unmet ordering and additive complete requirements for extension fields; preserve baseline diagnostics. Field descriptions remain the static catalogue, rather than inventing a new introspection surface. |
| D9 | Real issue. Assign grant disclosure and acceptance to window layout, pointer/media, app input and menu bar; add its trace row. The shell exclusion names an API, not protection against terminal input or arbitrary menu effects. |
| D10 | Visible presentation trade-off. Remove the detached authority example, retain its content in the caption, use a textual start cue and document native-size/pan/export reading on mobile. Regenerate and inspect exports. Whole-graph mobile fit and initial padding remain accepted presentation limits. |

The checked-and-accepted review observations do not need a redesign. Clarified
that startup-failed providers retain published capability names and that naming
authority creates no runtime readiness dependency. The framework feature and
native compatibility evidence remain pending implementation as before.

## Verification and handoff

`task check:docs` passed. `task design:workflow-render` regenerated all three
workflow SVGs successfully; their rasterized exports were inspected for layout,
text and the revised contracts. Manifest validation confirmed every declared
source/export and discussion reference. Added-line whitespace checks passed.
SHA-256 manifests of all jj-tracked files matched before and after final link,
manifest, HTTP and whitespace checks; subjects include the Markdown, diagram
sources/exports/manifest, Taskfile and link checker. No input moved during the run.

The default presentation port was occupied. Added a `PORT` override to the
existing serve task and verified `task design:serve PORT=8767` served the exact
current manifest. Fresh browser inspection was unavailable: CUA reported no
in-app browser and its browser inventory was empty. The earlier review's
browser findings remain its evidence; exported-image inspection here does not
claim to recheck mobile/dark/deep-link behavior. No native workflow test or
implementation acceptance is claimed by this documentation integration.

Final consistency read made two implications explicit: ordinary input cannot
dispatch the protected system shortcut through an alternate input-only path,
and protected-target refusal does not strand already owned modifiers by
overriding their accepted release exception. Rechecked links and whitespace on
those final texts with matching before/after hashes.

Graph coverage was checked for the relied-on source and modified artifacts.
Documentation/scripts are excluded and task/Taskfile metadata is changed or
untracked; direct reads and diffs supplied the evidence there. Composition,
Authority, management UI and ProviderStatus source matched the recorded generation;
the bounded Authority trace had no further page. No whole-codebase completeness
claim relies on this fast index.

The current spec, ADRs, requirement clarification, diagrams and live charters
were reconciled against D1–D10. The root retains live `first-party-provider-selection-k50`
and the workflow increments, so retirement closes no parent node. Native refusal,
Space-shortcut feasibility, consent coverage and all required workflow outcomes
remain acceptance obligations for their named increments.
