# Application locations through workspace 1.0.1 in a disposable VM

This record owns the finite observations of `application-location-observations-k186`,
within `application-locations-vm-k181`. It distinguishes supplied long-application
refusals and short workflows beside long copies **on disk** from the unproved
subjects requiring a long copy in native registration. Antony accepted the
[native coverage limit](#accepted-native-coverage-limit) for those two subjects;
neither disk-only short success nor planner tests pass them at V.

## Subjects and procedure

The signed packaged `Koine.app` serves workspace release/schema **1.0.1**, with
unchanged public shapes. The contract-only client sends requests with
`workspace:control` and `desktop:control`; Koine has no Accessibility grant.
All application and Finder effects occur in TestAnyware's disposable clone
`koine-verify-86962` of `koine-launchers-prepared`, macOS **26.5 (25F71), arm64**.
Gatekeeper is enforcing. Developer ID team **TA43A4RUP3** signs the bundle; it is
unquarantined and unnotarized, and its recorded `spctl` assessment rejects it as
Unnotarized Developer ID. This is the prepared installation posture used by
the [installation acceptance](application-installations-vm.md), not a notarization test.
No application is launched on the host.

The [fixture builder](../../scripts/vm-long-application-fixtures.py) copies short A
component by component, holding directory descriptors and changing the guest
working directory through `fchdir`. Relative `stat` and `Info.plist` reads establish
two extant applications with identifier `dev.koine.test.InstallationFixture` and
literal path lengths **1,024** and **1,500 bytes**, excluding NUL. Their device is
16777233 and their inodes are 296768 and 296785. Presence never depends on a
whole-path copy or metadata operation at those lengths. Short A and B have the
same identifier but distinct physical bundle paths.

The [section recipe](../../scripts/vm-application-locations-lib.sh) uses the
[installation request observer](../../scripts/vm-installation-request.py): each
guest process takes an atomic request lock, sends once, reads fixture logs since
the send, lists fixture processes before/after and obtains the receipt's kernel
PID/start identity through LaunchWitness. Retrying an agent call cannot replay
the request. Refusals wait **60 seconds** for effects. An independent `open -n -a`
delivery of a **1,023-byte** document controls the observer, with exact document
and copy identity and delivery in **less than 20 seconds**; a wrong-path mutation
is rejected. Independent `open -R` of that same document controls Finder's own
selection observer before the short reveal.

## Native registration: bounded observations, pending acceptance

The [subjects and registration records](application-locations-vm/subjects.json)
retain every attempt and the subsequent NSWorkspace preferred/listed query.
The lookup tool uses the same public NSWorkspace discovery calls as the native
adapter; a registration command's exit status is never treated as discovery.

| Route | 1,024-byte copy | 1,500-byte copy | Subsequent preferred/listed values |
| --- | --- | --- | --- |
| Absolute `lsregister -f` | Exit 0 | Exit 0 | Short A preferred; only A and B listed |
| Held parent descriptor, relative-cwd `lsregister -f Fixture.app` | Exit 0 | Exit 1, relative URL scan error -50 | Short A preferred; only A and B listed |
| Short link targeting the full long bundle pathname | Link construction refused, errno 63 | Link construction refused, errno 63 | Short A preferred; only A and B listed |

These are **six bounded attempts**, including two construction refusals before
registration could run. The later query immediately before the short workflow
section still lists only A/B and prefers A. This establishes what these routes
exposed on this image, not impossibility across macOS or every registration route.

Two original V subjects could not be measured: a short selected copy beside an
actually registered unequal long copy, in both observed enumeration orders;
and a long preferred copy refused cold and with a short copy running. The [bounded prefix-link continuation](prefix-registration-vm.md),
`long-application-registration-k187`, completed all twelve public registration
states with independently established short route/long physical identities.
Every long registration returned scan error -37; every final NSWorkspace query
still lists only A/B and prefers A. Both native subjects remain unproved. Their
raw verdicts remain pending; the following decision changes the acceptance
scope without changing those measurements.

## Accepted native coverage limit

Antony accepted this coverage limit on **2026-10-08** in
`long-application-acceptance-k188` ("accepted"). For workspace release/schema
**1.0.1** on **macOS 26.5 (25F71), arm64**, these two native subjects are no longer
prerequisites for closing the application-location increment:

- A registered unequal long copy, at 1,024 or 1,500 bytes, actually enumerated
  before and after the selected short copy for constrained launch and named open.
- A physically long preferred copy refused for unconstrained launch and named
  open, both cold and with a short copy of the same application running.

Both behaviors remain **unproved at the native seams**. The substituted-adapter
L/G contract checks and the supplied-literal refusals, disk-only short workflows,
kernel-backed receipts and Finder observations above retain their recorded
meaning. None is relabelled as registered-long or preferred-long acceptance.
The [v1 contract](../specs/workspace-launch-and-open.md#long-location-action-boundary)
still requires refusal of every over-limit literal, expanded or resolved
application spelling before a request, with no substitution of another or
running short copy.

This decision accepts the measured fixture unavailability on this OS build,
rather than commissioning more automatic registration experiments. It does not
assert that macOS registration is universally impossible. Reopen the affected
coverage when a concrete native setup exposes either required precondition:
independently establish the physical long bundle's identity and length, then
observe its actual native order or preference immediately before the request,
after any running-copy setup. Measure the corresponding launch/open outcomes at
V with the existing controlled observers. Other OS builds and actual-search
handoff retain their own acceptance requirements; no production delivery route,
consent or signing change is authorized.

The retained raw records, pending verdicts and exit statuses remain unchanged.
The evidence checkers still report unavailable preconditions with exit **3**;
that is evidence of this coverage limit, not a native pass or a remaining
closure prerequisite under the accepted scope.

## Retained observations and verdict correction

The original [results](application-locations-vm/results.json) and
[transcript](application-locations-vm/transcript.txt) are preserved, including
the original eight failed verdicts. Those failures came solely from an incorrect
test matcher requiring the full pathname inside the guidance. The established
`HandOffLimit.refusal` contract identifies the spelling kind—"the application
path as written"—and byte count, and says no request was made. It does not print
the literal pathname. The recorded client selector independently preserves that
exact pathname. No production correction was needed.

The VM run was allowed to finish without changing any measured input. Its
before/after input digest includes the full packaged app, contract client,
Node archive, witness, fixture sources, request and observer libraries, permission
client, signing and staging scripts, and Taskfile. The transcript identifies
each file and reports the unchanged comparison at the end. The subsequent
matcher correction does not retroactively turn the raw recipe's exit 1 into a
successful raw run.
The exact [measured section](application-locations-vm/measured-application-section.sh)
and [measurement/provenance recipe](application-locations-vm/measured-installations.sh)
are retained under their original transcript hashes. The current recipe uses the
corrected shared predicate and also retains reveal's full acknowledgement directly.

The [separate evaluator](../../scripts/reevaluate-application-locations.sh)
applies the corrected predicate to every full retained refusal, verifies the
complete case set without duplicates and checks all six short receipts against
exact bundle/document and kernel identity. Finder and delivery selections and
the [full reveal request](application-locations-vm/reveal-request.json) are
rechecked from their records; permission and dialog results are retained live
assertions. It writes [separate verdicts](application-locations-vm/reevaluated.json),
with each original status and evaluation basis, while preserving the raw records.
Its [input digests](application-locations-vm/reevaluation-inputs.sha256) are equal
before/after; the [output digest](application-locations-vm/reevaluation-output.sha256)
identifies the verdict artifact. Its exit **3** means the native-registration
subjects remain pending.
Re-evaluation records **19 passed observations and two pending subjects**. The
two pending raw subjects now have the explicit coverage limit above; the
re-evaluation artifact is unchanged.

| Measured subject | Cases | Result |
| --- | --- | --- |
| Supplied application length 1,024/1,500; launch/open; cold/short A running | 8 | `failed`, exact literal-kind/count/no-request guidance, null receipt/dependency, no logs or process change |
| Constrained short A/B launch/open, with long copies on disk | 4 | `AVAILABLE`; exact copy, exact opened document, non-null kernel-backed receipt |
| Unconstrained native preferred short A launch/open | 2 | `AVAILABLE`; exact A identity/document and kernel-backed receipt |
| Short reveal beside long copies | 1 | `AVAILABLE`; Finder selects `note-1.koineinstall` |
| Independent 1,023-byte delivery and Finder selection | 2 | Controlled at the admitted boundary |
| Accessibility absent and no system dialog after the section | 2 | Retained live assertions |
| Registered-long/both-order and preferred-long rows | 2 | **Unproved; accepted native coverage limit** |

The [predicate controls](../../scripts/check-application-location-observations.sh)
start with real recorded successful delivery and the
[first real refusal](application-locations-vm/first-refusal.json). They reject
five receipt/delivery mutations (wrong copy, document, null receipt, kernel start,
missing delivery) and eight refusal mutations (spelling kind, count, response
path, dependency, receipt, delivery, process change, selector). The shared Finder
observer was extracted unchanged from the accepted target-stage recipe.

## Repeating and scope

`task application-locations:vm` builds the app/client and measures in a fresh
clone; `application-locations:vm-packaged` uses already built artifacts and
`application-locations:vm-detached` records its actual exit in
`.build/application-locations-vm/done`. Exit 3 preserves the unavailable native
subject verdicts; the accepted coverage limit does not rewrite recipe results.
`task application-locations:fixtures-check` checks the recipe and mutation
controls without a GUI. `task application-locations:reevaluate` checks this
retained evidence without sending requests or starting a VM.

The stopped setup attempts were not counted: one run was stopped before
measurement to incorporate the sole review's exact-copy/document, provenance
and replay fixes; another stopped at the previously uncaught optional symlink
construction refusal. The completed run alone supplies this record. Its clone
is stopped after Koine quits and [no longer present in Tart](application-locations-vm/cleanup.json).
This adds V evidence only for the supplied literal
refusals and disk-only short workflows above. Native candidate ordering and
preferred-long refusal remain unproved under the accepted coverage limit;
planner L/G evidence is not relabelled V.
