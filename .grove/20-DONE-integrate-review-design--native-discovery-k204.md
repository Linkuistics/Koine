# native-discovery-k204

**Integrates:** native-discovery-k203

## Goal

Triage the findings of `native-discovery-k203` against the native discovery
design that `native-discovery-k199` returned (closed by `native-discovery-k202`),
and apply the real ones. app-and-file-search-k7 and its reconciled chain should
consume a coherent contract; any posture question the findings raise should be
put to Antony with a recommendation.

## Context

- Read the findings in the review's own leaf and commit; this charter does not
  restate them. They are anchored to producer `913613ae98c1`, whose coordinates
  equal the review's tree.
- The artifact: `docs/specs/workspace-search.md`,
  `docs/verification/native-discovery-sources.md` and
  `native-discovery-acceptance.md`, the native SDL/examples
  (`docs/design/workspace-search-{schema,operations}.graphql`, the composed
  `desktop-workspace-native-schema-extension-host.graphql`) and native profiles,
  `docs/specs/machine.md` (consent ownership, capability disclosures, native
  profiles), the workflow trace's authority/disclosure rows,
  `docs/client-guide.md`, `docs/specs/workspace-launch-and-open.md`'s native
  handoff rows, CONTEXT, the ADR set (especially
  `settings-discovery-uses-app-supplied-objects` and
  `provider-authority-follows-effects`), the native architecture views, and
  `Sources/KoineCore/CapabilityDisclosures.swift` as the shipped disclosure text.
- Downstream consumers whose charters may need adjusting: root brief, k7, k19,
  k126/k191/k193, k127, k123, k120, k30, k93 and baseline k17.
- Approval is unchanged. Integrating a finding does not authorize a new consent
  route, entitlement, usage key, host feature, signing change, helper, smaller
  useful category or accepted workflow loss. Those go to Antony with a
  recommendation and the evidence, never silently into the contract.

## Done when

- Every finding is classified — a contract stated unclearly, valid and
  actionable, a visible accepted trade-off, or noise — with the reason recorded
  in this leaf's running log. Each actionable one is applied where it lives.
- Any finding that turns on a human posture decision (who may trigger Koine's
  OS consent, whether prior hosts may serve the native surface under their
  shipped disclosure) is put to Antony as a named trade-off with a recommended
  answer, and his answer is recorded before the contract builds on it.
- Durable artifacts stay mutually consistent after the changes: spec, SDL,
  examples, composed SDL, profiles, acceptance, trace, Machine, guide, glossary,
  ADR set and views. Mixed downstream charters receive any duties the changes
  create, and no ambiguous leaf is pruned or credited native-passed.
- Frozen checks appropriate to the changed inputs pass with deliberately failing
  controls (SDL/examples/profiles, links, renders), and they claim no native
  pass. Substantive redesign beyond what this integration can verify becomes a new
  producer review chain beside this leaf, not an in-session rewrite.

## Notes

No implementation, native probe, backend, consent request, signing change or VM
experiment. One narrow in-session reviewer is allowed by the integration
allowance; do not substitute it for a needed producer review chain. Native G/N/V
verdicts remain pending throughout.

## Decisions (running log)

- Bootstrap resolves this live leaf in the mandated jj workspace; the brief
  chain contains the root brief. Review findings were read from `b14a68dbbb26`,
  against producer `913613ae98c1`. The working copy was empty. The graph CLI
  refuses startup for an active pre-coordination/unverified generation, so
  exact bounded source reads replace graph evidence; no generation or coverage
  completeness is claimed.
- N1 is a real unresolved posture decision: the existing UI-only consent rule
  and proposed client mutation conflict. N3 is a real disclosure/compatibility
  defect: core owns disclosures and prior selection-aware hosts can admit the
  new manifests without corrected text. Ask Antony to select consent initiation
  and prior-host policy, recommending local Koine UI and a required
  disclosure-capable host feature respectively. Neither dependent contract is
  changed before his answer. Target-wide Automation scope is a contract
  correction independent of that answer.
- N2 is valid and actionable. The recorded background-service AppKit failure
  defeats the unspecified activation call. Repair reveal with the existing
  fixed-bundle Launch Services opening primitive, activation enabled, and state
  the race-to-launch limit explicitly; preserve both controls, exact target
  validation, no implicit preparation and ambiguous-effect failure.
- N5 is valid and actionable. The accepted selector uses AppKit's ordered
  registered list plus its preferred-only candidate; the Trash evidence
  disproves treating the latter as a contradiction. Catalogue positive
  eligibility will use that same procedure. The error-bearing API supplies
  separate conservative negative evidence, not a competing selection algorithm.
- N6 is a contract stated unclearly. Gathering completion proves the end of an
  observation, not a healthy empty index. Empty or independently contradicted
  indexed breadth remains UNKNOWN/PARTIAL with diagnostics and dedicated
  disabled/excluded/rebuilding acceptance subjects; seed supplements cannot
  upgrade that source to COMPLETE.
- N10 is valid and actionable. The principal must have a routing-only source
  and image guard, and production action-adapter construction must be private
  to WorkspaceActions. Test substitution remains in test-only composition.
  Add a principal-injection failing control and explicit k127 ownership.
- N11 is valid and actionable: four independent images meet all three ADR
  conditions. Record the current packaging decision in a slug ADR and reconcile
  spec/trace/view citations; this creates no implementation or native pass.
- N4, N7 and N8 are real design gaps requiring a new producer/review chain
  before k7. N4 needs a declared populous subject, coherent source/call/identifier
  budgets and admission/filter facts, rather than guessed replacement constants.
  N7 needs a defensible cold/warm pane-and-anchor readiness rule; repeated IDs
  alone cannot establish it, and changing event forms is not a mechanical repair.
  N8's mandatory native type check has no admitted long-path source, so its
  native-catalogue handoff cannot currently be constructed. Neither invent a
  descriptor-relative metadata reader nor silently relabel client-found paths
  as catalogue provenance. Keep these three obligations live, mark the affected
  design provisional, and commission bounded repairs with mandatory review;
  required useful choices and native acceptance remain unchanged.
- N9 is valid and actionable, with its public shape dependent on N1's pending
  initiation decision. Unsupported posture, stopped/refused/changed target,
  capacity, denial and deadline require closed reasons rather than parsed
  guidance. A late answer requires explicit non-prompting status observation;
  denial must direct the user through Koine's explaining UI/manual System
  Settings route, never require an already-denied reveal to repair permission.
  Do not finalize that result/protocol before consent initiation is selected.
- Independent repairs are design-checked: `task design:search-compose` then
  frozen `design:search-check` pass schema/examples/profiles/retained actions,
  removed-root, wrong-input/output, foreign-type and shared-authority controls.
  Every schema/package/Taskfile subject in
  `.build/k204-design-checks/schema-inputs.before.sha256` is unchanged afterward.
  `task check:docs` passes with missing-target and missing-anchor controls each
  observed failing; all 427 exact source/target/exists/type/digest records are
  unchanged across each measurement. `design:native-discovery-render` renders
  all five native views with unchanged source/Taskfile inputs. Chrome at
  `http://127.0.0.1:8924/` displays the updated discussion and both changed SVG
  deep links; 390×844 mobile wraps the caption and provides native-size scrolling
  (keyboard toggle verified), then viewport override is reset. Dark emulation
  is not exposed by the available viewport API and is not claimed. These checks
  supply no native G/N/V pass. N1/N3 answers remain required before retirement.
- Antony's "I aree" accepts both recommendations presented together: only Koine's
  local explaining UI initiates Automation consent; native providers require a
  disclosure-capable host feature. Apply those selected policies now. Remove the
  proposed remote setup mutation/result rather than invent another permission
  route. N9's deficient public result disappears; the local UI still needs
  closed reasons, in-flight/late-answer handling and a manual post-denial remedy.
  The native host feature is `workspace-native-disclosures-v1`, independently
  of conditional signing posture; prior hosts refuse before native code loads.

- N1/N3/N9 are settled and applied after Antony’s answer. The SDL/examples remove
  remote consent and its public result; spec/ADR/Machine/guide/glossary/trace/views
  agree on local UI-only initiation, shared target consent, closed private reasons,
  separate UI wait, true-return ownership and manual post-denial guidance. Core
  disclosure implementation is an explicit k7/k30 duty; this design leaf edits no
  Swift implementation. All native manifests require workspace-native-disclosures-v1
  independently of Automation posture. A fourth complete profile pins prior-host
  unsupported-feature refusal and retained action-only selected-with-refusals.
  G9/N1/V10 accept those actual surfaces/binaries; historical captures remain distinct.
- Doubt-driven claim: the revised public schema admits no consent route and
  native profile pins require corrected-disclosure hosts. Use deliberately failing
  executable schema/profile controls for those checkable design claims. Decline
  the optional narrow reviewer because those controls are the stronger instrument;
  native routing/ownership/disclosure behavior cannot be discharged by rereading
  the prose and is already assigned to fresh k193/k127/k120 reviews and G/N/V.
  Population/readiness/long-metadata redesign gets its own producer/review chain.

- Final selected-policy validation: search-compose regenerated complete native
  SDL; search-check passes all examples, retained actions and four profiles. Its
  removed-root, wrong-input/output, foreign-type, shared-authority-object, remote-
  consent, missing-disclosure-requirement and prior-host-load controls all reject.
  All 12 exact schema/package/Taskfile/profile input digests are unchanged. Five
  native views render with all six source/Taskfile digests unchanged; a malformed
  D2 subject fails the same rendering command. Links pass after both missing-target
  and missing-anchor controls fail; all 429 exact source/target/type/exists/digest
  records remain unchanged, and the fixture is removed. Detailed records are in
  .build/k204-final-checks/. Final recheck confirms those measured inputs unchanged.
- Chrome visually verifies the new local-UI branch and fixed-bundle reveal flow,
  host-feature/principal/private-UI seam view and updated discussion/captions.
  Mobile 390×844 wraps the longer caption; native-size toggle visibly enables
  scrolling and is restored before resetting the viewport. Temporary verification
  tab/server are closed; pre-existing user tabs are untouched. Dark emulation is
  unavailable and unclaimed. No build, native launch, probe, consent request or
  signing/VM experiment occurs; every native G/N/V verdict remains pending.
- Bounded consistency sweep across current spec/Machine/trace/guide/requirements/
  glossary/ADR/views/SDL/acceptance/source report and mixed charters reconciles the
  consent/disclosure authority. A wider docs/tree literal sweep finds the removed
  setup name only in the deliberate Taskfile rejection controls and retired k203
  review; positive current-schema and cross-tree charter witnesses confirm the
  search scope. K93 and baseline k17 consume V9/V10 and corrected-disclosure duties.

- Last work cut: native-discovery-k205 is inserted as a root design producer
  before app-and-file-search-k7. It completes constructible population/readiness/
  long-metadata contracts, carries the accepted UI/disclosure boundaries and
  requires whole-producer review plus earned integration before k7. No review is
  prewritten before the producer exists. Root still has live work; this leaf closes
  no parent node and requires no parent-chain promotion or review Creator change.
