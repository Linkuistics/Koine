# long-location-actions-k182

**Integrates:** long-location-actions-k171

## Goal

Triage the findings in review `long-location-actions-k171` and reconcile the
v1 long-location implementation cut before any leaf of `long-locations-k172`
runs. Preserve the settled descriptor-relative resolution and truthful
application hand-off refusal contract.

## Context

- Read the review's findings and evidence from its own committed task, rather
  than treating this charter as a transcription of them. It reviews planning
  producer `long-location-actions-k167`, commit `5454ef59`.
- The planned subtree `long-locations-k172`, the launch-and-open brief, the
  action spec's long-location boundary, descriptor-relative access ADR and
  native boundary's compatibility/implementation obligations.
- Current native adapter and receipt/selection consumers, retained evidence
  and the reviewed k168/k170 contract. Earlier source coordinates in the review
  are anchored to the producer commit; resolve handles for current tree paths.

## Done when

- Classify every review finding with evidence as actionable, unclear contract,
  accepted trade-off or noise; explain dismissals as well as corrections in
  the running log.
- Apply the justified planning corrections and reconcile any affected contract
  or evidence instructions. Each assigned implementation/acceptance slice
  remains independently useful and has observable completion conditions at
  its stated seam.
- Preserve the v1 hand-off bound, unchanged public shapes/enums/capabilities,
  independent retained 1.0.0/action-repair 1.0.1/search 1.1.0 subjects, prompt
  stop, literal selected values and separate actual-search acceptance.
- Verify changed planning/document artifacts with applicable existing tasks.
  Native, binary, public-runtime and signed-VM acceptance remains the future
  implementation leaves' work; this integration supplies no runtime pass.

## Notes

This is planning integration, not provider implementation. No long-path
application support, fallback to a different copy, new public diagnostics, reduced search
ceiling, new consent or signing posture is authorized. If triage requires
substantial new design, externalize its producer/review chain ahead of the
implementation node instead of deciding it inside an implementation charter.

## Decisions (running log)

- Read the findings from review k171's own commit (`3c5a4526`), not this charter.
  Verified each against current source and the spec before classifying. Graph
  tooling was unavailable (`codebase-memory-mcp` connection closed), so evidence
  is targeted source reads; no graph completeness claim.
- **R1 (receipt executable identity unowned): actionable, verified.**
  `NativeWorkspace.liveExecutableIdentity` and `RunningApplication.executableIdentity`
  both go through `fileIdentity(ofPath:)` (`resolvingSymlinksInPath` plus pathname
  resource values) and `observeProcess` compares them; neither calls
  `inspectApplication`, so no leaf converted them. Cut `receipt-executable-identity-k183`
  after the stage leaves and before the release. Its rule: the hand-off limit does not
  apply after an acknowledged action; a present executable of any length gives an
  identity, every other walk outcome gives the existing null process. Added that
  sentence to the spec beside the existing receipt line (a clarification of "existing
  null rules", no public change). k177 now names the route as not its own; k181 observes
  non-null receipts at V.
- **R2 (preferred-long success contradicts the selected-copy gate): actionable.**
  `selectInstallation` chooses only the preferred copy and the spec refuses the selected
  over-limit spelling before the platform, so k181 could not pass and a short running
  copy cannot rescue it. Separated the two cases in k177, k176 and k181 and in the node
  brief; the spec's paragraph after stage 4 now states the preferred-long refusal and
  no-substitution outright; the native boundary record's table carries a v1 reading that
  supersedes its older success row. Substitution of another copy stays a contract change
  for Antony, not a fixture repair.
- **R3 (VM observer prerequisite needs the deferred delivery): actionable.** k180
  required each observer to see the same over-limit subject independently opened. The
  control is now a 1,023-byte subject delivered by a non-Koine route, with no over-limit
  delivery as a prerequisite; goal reworded to the admitted length. Spec V bullet, the
  boundary record's observer paragraph and the node brief say the same.
- **R4 (shared-source walk tests do not close N): actionable.** Agreed that direct tests of
  the walk source do not show the built provider consumes it. k174 now labels them
  supporting evidence that closes no N subject and defines N through the signed bundle:
  results plus refusals that follow resolution, using placement at 1,024+ bytes so the
  refusal's named spelling proves the walk reached the object. The present rows no refusal
  exposes (within-limit 31/32-link chains, mode-0600 directory, two-directory link,
  multibyte names, reveal root decision) are an explicit N gap assigned to V in k180. The
  spec's N bullet records the rule. No new public diagnostic.
- Noise and trade-offs: none dismissed. Not acted on, and why: the review's no-finding
  conclusions (retention order, prompt stop placement, 1.0.1 description ordering, the
  external consumers k89/k90/k93/k17) were re-read against the charters and stand; no
  consumer assumes the 1.0.0 `ELOOP`/`ENAMETOOLONG`-as-absence mapping. Leaf size alone
  is not a finding; k174, k179 and k180 keep their decompose-at-a-seam notes (k180 grew by
  the effect-only rows).
- Preserved: v1 hand-off bound, public shapes/enums/capabilities, independent retained
  1.0.0, action-repair 1.0.1 and search 1.1.0 subjects, prompt stop, literal selected
  values and separate actual-search acceptance. `task check:docs` passes. No native,
  binary, public-runtime or VM pass is claimed; that stays with the implementation leaves.
