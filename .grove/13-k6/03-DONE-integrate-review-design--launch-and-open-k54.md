# launch-and-open-k54

**Integrates:** launch-and-open-k53


## Goal

Triage the findings of `launch-and-open-k53` against the workspace launch/open
design from `launch-and-open-k18`. Apply the real ones to the design artifacts,
so `launch-and-open-k29` cuts implementation from a settled contract.

## Context

- The review's findings live in its own leaf and commit, anchored to producer
  commit `16598f4fade8`. Read them there; this charter deliberately does not
  restate them.
- The artifact: `docs/specs/workspace-launch-and-open.md`,
  `docs/design/workspace-schema.graphql` and
  `docs/design/workspace-operations.graphql`, the launch/open rows of
  `docs/specs/workflow-providers.md`, the workspace note in `docs/specs/machine.md`,
  and the two workspace views in `docs/design/architecture/` with their captions.
- Some findings touch shared contracts rather than only the workspace spec: the
  control-receipt rule in `machine.md#additional-capability-requirements`, and
  the grant-disclosure ownership in `workflow-providers.md`. Any change there
  must stay consistent with `docs/adr/provider-authority-follows-effects.md`.
- The node brief's `Design handoff` and `launch-and-open-k29`'s concrete design
  obligations restate parts of this design. Reconcile them with whatever changes.

## Done when

- Each finding is classified as applied, rejected with a reason, or a stated
  accepted limit. None is mandatory merely because the review raised it.
- Accepted changes are consistent across the spec, SDL descriptions, examples,
  trace rows, views, node brief and the k29 handoff. `task design:workspace-check`
  and `task check:docs` pass. Re-render the views with `task design:workspace-render`
  if their sources change.
- A native limit this design would now state, or any new consent, entitlement or
  signing posture, has been raised with Antony before it is relied on.

## Notes

The review found no reason to change the architecture. Substantial redesign
belongs in a new design review chain beside this leaf, not here. Platform
predictions remain acceptance work for the assigned seams; the integration
settles what the design promises and which seam observes each prediction.

## Decisions (running log)

Read `launch-and-open-k53` from commit `043432ce`, against producer
`16598f4fade8`. The integration began with an empty working change. The four
operations, both control grants, typed pre-submission absence and the complete
selection matrix remain the contract; findings are evaluated against that
contract rather than treated as instructions.

S1 is a real issue: the SDK explicitly distinguishes an unconstrained launcher
from a selected installation. Allow running-copy substitution without a path
constraint, including named-app document opening; keep it disabled with a path.
Search deliberately uses the constrained form when acting on a chosen copy.
Neither form requests a new instance.

S5 is a real issue: remove application path and bundle identifier from the
control receipt, rather than weaken workspace read authority. Keep only the
optional process handoff, and clarify its narrow allowance in Machine. S6 is
also real: this increment owns workspace grant disclosure before it ships.

S7 is a real evidence gap: controlled native outcomes exercise the actual
workspace mapping with its private adapter substituted. Whole-provider fakes
prove core/client handling only; they are not native-binary or VM evidence.
S8 is an unclear contract: branch exclusivity applies only without errors at or
below the result. Publication errors do not reclassify an acknowledged action.

S11's acknowledgment terminology, scheme-level routing and URL grammar need
clarification. Remove the unallocated OS-consent row; no consent identifier is
authorized by this design. S12 is applied to the handoff: probe protected-path
metadata before path-opening implementation or search depends on the contract.

S9's word "reliable" lacks an observable matching rule. The proposed receipt
rule compares the callback's retained native application with two kernel-start
observations and live executable identity, withholding the process on any
mismatch. The claim to test is that these checks justify the documented optional
observation without implying an atomic binding of effects; a mistaken pairing
would misdirect the subsequent desktop handoff. Spend this leaf's one narrow
doubt reviewer on that rule against the SDK and kernel interfaces. The reader
gets the rule and contract, not this conclusion or the earlier finding list.

The narrow reviewer found no actionable issue after reading the native app,
workspace, libproc and process-info declarations. This is declaration evidence,
not runtime freshness or an executable identity comparison; L/N/V acceptance
retains those obligations. No second reviewer is needed for the unchanged rule.

S3 is an unassigned native question, not proof that NSWorkspace activation
fails: the cited cooperative API is not the workspace open API. Assign cold/warm
background-Koine activation explicitly; keep the existing separately authorized
desktop handoff as client recovery. A measured controls-only activation failure
does not pass the launcher requirement and must return to Antony, rather than
quietly make desktop read or client yield mandatory.

S4 identifies a real unbounded-wait risk. End the provider wait at three seconds
or earlier cancellation, ignore late completion and bound outstanding native
submissions. This cannot guarantee an action-path result in a multi-root request
whose five-second core budget expires earlier. Normal V launch cases pre-complete
Gatekeeper/onboarding; separate cases test late completion and the expected
ambiguous failure. The review's claim that every freshly installed application
must wait for Gatekeeper is rejected: quarantine and prior approval vary.

S10 is partly clarification, partly a trade-off. Revalidate registration against
bundle presence and compare constrained locations by file identity, not text.
Reject the proposed universal Trash exclusion: a registered bundle still present
there is eligible under the existing registration-based selector; test and state
that choice. Preserve the existing bundle-identifier input, explicitly excluding
bundle-less programs from named selection while allowing default handler use.
No required launcher is specified as a bundle-less program, and adding a raw
program selector would reopen the agreed boundary.

S2 is a real underspecified policy. The written proposal replaces default-script
refusal with narrow application/native-executable metadata refusal, rejects
Finder aliases, and permits source documents in default editors. It states
document execution and location redirects as handler reactions. This scope
choice was presented to Antony before adoption.

Antony approved normal document handling: default editors remain usable, while
handlers may execute documents or follow redirects. Apply S2 with that stated
limit and retain its grant disclosure and acceptance cases. The design no longer
awaits a policy choice; implementation and native/VM acceptance remain pending.

## Evidence and verification

Tier 2 graph project
`Users-antony-Development-Koine.add-plugins-for-modaliser-requirements` was ready
at generation `2026-09-29T10:36:20Z`. The exact `processStart` source reads the
kernel seconds/microseconds. Its both-direction depth-one trace names
`running`/`isRunning` inbound and `ProcessStart` outbound, without pagination;
coverage reports matching metadata and no recorded gap for
`Providers/DesktopProvider/Sources/ProcessIdentity.swift`. This establishes the
existing representation, not native atomicity. Docs/scripts were excluded and
brief/Taskfile metadata was changed or untracked; those artifacts were inspected
directly. Installed SDK declarations corroborate the substitution, callback,
native-application and content-type premises. The RFC 3986 `URI` production
preserves optional fragments; the narrower `absolute-URI` production is not
the contract.

`task design:workspace-check` passed standalone SDL, baseline composition and
all five examples, with both existing negative controls rejected.
`task check:docs` passed. Every tracked file listed by `jj file list` was
SHA-256-digested before and after these runs, including Taskfile, the checker,
package manifest/lock, baseline/workspace SDL, examples and documentation; the
per-path digests matched. These checks validate the written contract, not served
runtime behavior.

`task design:workspace-render` passed. Both SVG exports were rasterized with
`rsvg-convert` and inspected at readable size: labels, branches and the expanded
notes are legible. Browser preview was unavailable (no enabled browsers), so no
interactive/mobile preview is claimed. The temporary preview server was stopped.
No provider code, signing, consent or native/VM acceptance was changed or run.

After Antony's approval and removal of the proposal notice, both required tasks
passed again: workspace SDL/composition/five examples with both negative controls,
and documentation links. Per-file SHA-256 digests of the complete tracked input
set matched before and after the final checks. Diagram sources did not change
after their successful render and visual inspection. All twelve findings are
disposed of above; the `launch-and-open-k29` planning leaf remains live, so this
retirement does not close the parent node.
