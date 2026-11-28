# app-input-k9

**Integrates:** app-input-k8

## Goal

Triage the findings from the committed app input design review. Apply the
repairs that meet the agreed acceptance or material-risk threshold, so the
implementation can proceed against one coherent contract.

## Context

- Read the findings from the commit of `app-input-k8`, rather than treating
  this task body as a repair list.
- The reviewed producer is `app-input-k3`. The root brief and Antony's final
  rulings in that producer remain the contract.
- This is a flat sibling immediately after the review. It precedes
  `input-keystrokes-k4` so implementation does not move the reviewed sources
  before triage.

## Done when

- Each finding has been verified against its source and classified as an
  unclear contract, a real issue, an accepted trade-off or noise.
- Earned repairs are applied and verified within this kind's remit. Any
  required human decision or substantial redesign follows the integration
  procedure, with the dependent work retained.
- The task records each disposition and the evidence for it. It preserves
  the agreed scope, test seams and live implementation/acceptance remainder.

## Notes

The review performed inspection only. Its native counterexamples are marked
as derived where they were not reproduced. It supplies no new passing test,
build or native acceptance result.

## Decisions (running log)

**Source of the findings.** The findings come from the commit of
`app-input-k8`. No commit came between that review and this leaf, so its
coordinates still hold. Each finding below has its disposition and its
evidence.

**F1, per-process posting and the incarnation: an unclear contract, with an
accepted trade-off.** The finding is true of the interface. The SDK header
declares `CGEventPostToPid` with a process identifier and an event only. So
the incarnation check of a chord binds its posts only while macOS keeps that
process identifier for the target. The spec, the schema description and the
decision record stated the route as absolute.

The residue is not a material risk. macOS issues process identifiers in
sequence, and it issues one again only after it cycles through the whole
range. In the PID-recycling diagnostic of `retained-ax-binding.md`, PID 781
came back after 99,413 allocations. On this Mac, macOS 27.2.1, PIDs from
consecutive spawns rose in order. A reuse between the checks and the last
post therefore needs a whole cycle of the range in that instant.

The decision record already accepts wrong-process effects during process
reuse for Accessibility. Antony's rule in `plan-k1` named the front-app race,
which route A removes.

The SDK marks `CGEventPostToPSN`, the other
per-process call, as deprecated. So the repair states the premise and the
residue in the spec and the decision record. The route does not change. The
served disclosure keeps "No other app receives the chord", as the desktop
disclosures leave out process reuse too. The root brief keeps its Route item,
because it names the routing choice against the HID event tap.

**F2, the shortcut mask: a real issue.** The designed predicate tested only
the shift, control, option and command bits. A mask of Control with the Fn bit
passed it. A read-only inspection of Antony's preferences found what the
review found: entries 7 and 8 hold the mask 8650752, which is Control with Fn.
The entries 118 to 121 hold 262144 exactly, as the probe recorded for the VM.

The file digest stayed
`6a7e5753bdee829057258c37d22de026058098769905e9efe44643e93e31d8a9`. So the
mask must now equal 262144, and any other bit gives `SHORTCUT_REMAPPED`. The L
seam gains a mask with the Fn bit, and `space-switching-k5` carries the case.

**F3, taps for the target process: a real issue.** The SDK header says that a
per-process post enters before the taps for the target process and passes
through them. `CGEventTapCreateForPid` lets a process with the needed access
create such a tap.

The probe tested a tap at the session level only. So the
spec, the schema description, the decision record and the routes caption
change. They now say that a tap at the session level misses the chord. A tap
for the target process sees it. The route does not change.

**F4, the old protection rule: a real issue.** The authority decision record
still refused recognised consent and security UI. A sweep for the same rule
found three more statements of it. They are in the machine contract, a seam
row of the workflow providers spec and the workflow-targets architecture view.

Each statement now
states Antony's ruling: Koine refuses only itself, and every other app is a
target under the capabilities. The obligations of menus to refuse Koine, to
issue its own references and to focus nothing stay. The view also loses its
stale route from a protected target to `unavailable`, because input reports
that refusal as an outcome.

The decision record, the machine contract paragraph and the seam table
converted to controlled English first, in their own commit.

**F5, the static Space-switch limits: a real issue.** The served disclosure
named only the race in the instant before macOS reads the chord. The spec
also accepts a setting that macOS has not applied, and a numbering of several
displays that can differ from the count of Koine. Each lets the front app
receive Control and the digit. So the disclosure and the schema description
now state both. The Solution of the spec and the caption of the Space-switch
view no longer claim that Koine refuses every such case.

**Checks and views.** `task design:app-input-check` now also requires the tap
for the target process, the setting that macOS has not applied and the
numbering of several displays. It passes. A copy of the schema without the
unapplied-setting sentence made it fail with that phrase, and the schema came
back to its checked digest.

`task design:app-input-render` changed only the
Space-switch export. `task design:workflow-render` changed only the
workflow-targets export, rendered by the installed PlantUML 1.2026.10. The
task now names that version. The unconverted architecture README still says
"PlantUML 1.2026.8 where used".

**No new review round.** The repairs qualify claims and tighten one predicate.
They redesign nothing, so they need no further independent challenge. The
live leaves keep their scope and seams, and `space-switching-k5` gains the
mask case.
