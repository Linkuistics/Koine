# Bounded prefix-link application registration in a disposable VM

The one prefix-link route per physical long copy did **not** supply the native
preconditions for registered-long/both-order or preferred-long acceptance on
macOS **26.5 (25F71), arm64**. All twelve declared registration states completed;
every long-copy registration returned scan error **-37**, exit **1**. Every final
NSWorkspace query listed short A then B and preferred A. The original V subjects
remain **pending**; this is measured unavailability of this fixture route, not a
claim that every macOS registration route is impossible.

This continues the [application-location observations](application-locations-vm.md).
Those supplied literal refusals and disk-only short effects/receipts remain the
accepted slice. The prefix experiment adds native registration evidence and no
new launch/open or Finder V acceptance. Planner L/G coverage does not pass the
unavailable native subjects. Their acceptance scope needs Antony's explicit
requirements decision before the application-location node can close.

## Fixtures and fixed public matrix

The signed packaged Koine serves workspace release/schema **1.0.1**, with the
existing Developer ID team TA43A4RUP3, Gatekeeper-enforcing prepared installation
posture, and workspace:control plus desktop:control grants. The disposable
TestAnyware clone is `koine-verify-33852` of `koine-launchers-prepared`. No
application effect occurs on the host.

The [existing component fixture builder](../../scripts/vm-long-application-fixtures.py)
creates two copies from short A without repeating the earlier registration
experiments. Relative component operations read each bundle's device/inode and
Info.plist identifier, `dev.koine.test.InstallationFixture`. The
[prefix fixture/observer](../../scripts/vm-prefix-registration.py) makes exactly
one link to an intermediate directory of each physical copy and appends the
remaining components. Every link target, registration argument and appended
Info.plist pathname is shorter than 1,024 bytes, excluding NUL.

| Physical application bytes | Link target bytes | Registration argument bytes | Info.plist pathname bytes | Device / inode |
| --- | --- | --- | --- | --- |
| 1,024 | 435 | 624 | 644 | 16777230 / 295013 |
| 1,500 | 837 | 698 | 718 | 16777230 / 295030 |

The retained [subjects](prefix-registration-vm/subjects.json) contain exact
spellings and independent component-relative observations of each route. The
short spelling resolves to the physical copy's measured identity and expands
to its 1,024/1,500-byte spelling. A short alias alone is never treated as an
established physical long copy. These links are disposable registration
fixtures, never production delivery routes.

For each length, the declared invocation orders are **ABL, ALB, BAL, BLA, LAB,
LBA**, where L is that length's prefix route. Every state first publicly
unregisters short A, short B and both long routes, then registers the three
copies in the declared order: **84 public operations** across twelve states.
An NSWorkspace preferred/listed query follows every operation and each completed
state. The observer joins every reported native path to independently measured
physical identities; neither invocation order nor a command's exit establishes
native enumeration or preference. Native values can change, which is why the
request observer also reads them immediately before a request, after any
running-copy setup.

[Each evaluated state](prefix-registration-vm/evaluated.json) has a corresponding
`state-<length>-<order>.json` file containing exact commands, stdout/stderr,
native snapshots and independent identity observations
([first state](prefix-registration-vm/state-1024-ABL.json)). The
[raw transcript](prefix-registration-vm/transcript.txt) records the recipe and
final queries.
All long registration commands fail with -37. Long unregistration commands
also return 1; their subsequent queries supply the actual state rather than
an inferred unregister result. Short registration provides the positive native
control: the queries expose A/B identities, and unregistering both exposes none.
Every final state reports only A/B, A first and preferred. Thus neither a long
copy before/after a selected short copy nor a long preferred copy is available.
No Koine launch/open request is issued under those absent preconditions.

## Raw failure, provenance and limits

The [raw transcript](prefix-registration-vm/transcript.txt) ends with exit **1**,
a recipe assertion after the short reveal. The inherited `expect` helper reads
ANSWER, while this recipe passed an ACK filter that addresses `.answer` again.
The [full atomic request](prefix-registration-vm/request-1.json) independently
reports `AVAILABLE`, an acknowledged action, no error/dependency, and the exact
short target. Its request-local native selection still lists only A/B.

The answer-level predicate passes this real request; the wrong-nesting mutation
fails. The future recipe is corrected. **The raw exit is preserved and the
matrix was not repeated.** No final Finder selection observation was retained
after that assertion, and the trailing permission/dialog assertions did not run.
Consequently this run establishes no new Finder-selection V result, no
whole-recipe pass and no whole-run no-dialog claim. The earlier accepted Finder
record remains with k186. The independent delivery/Finder control branches were
reached and their checks completed before the recorded reveal, but their full
control JSON was in the temporary results file removed by cleanup; they are not
published as additional independently re-evaluated passes here. The isolated
observer's existing Finder Automation consent was allowed; Koine's pre-section
Accessibility report was false.

The [post-run input verification](prefix-registration-vm/input-verification.json)
checks **all 55 pre-run digest entries** against the files after termination and
before any correction: all match. They include the full packaged app, client,
Node archive, witness, fixture/request/observer sources, signing/staging scripts,
and Taskfile. The exact measured
[installation recipe](prefix-registration-vm/measured-installations.sh),
[prefix section](prefix-registration-vm/measured-prefix-section.sh) and
[Taskfile](prefix-registration-vm/measured-Taskfile.yml) are retained so the later
mechanical correction cannot overwrite what ran. The [artifact digests](prefix-registration-vm/artifacts.sha256)
identify the retained payloads.

An earlier setup stopped before any matrix state because repeated exec reads of
the fixture JSON did not return. File transfer immediately returned the valid
fixture. Large artifacts and completion files therefore use TestAnyware file
transfer in the measured run. That stopped setup contributes no acceptance.
Both clones are [absent from the final Tart inventory](prefix-registration-vm/cleanup.json).

## Verification and remaining work

`task prefix-registration:fixtures-check` lints/compiles the recipe and runs
component identity controls plus synthetic native/refusal/running-state
corruption controls. They reject wrong identity/order, missing effect arrays,
wrong spelling/count, delivery/process changes, and missing or changed running
incarnations. Synthetic native values establish no V precondition.

`task --exit-code prefix-registration:evidence-check` checks every retained
state's exact argument sequence, raw NSWorkspace values and physical identities,
not merely totals. It freezes its inputs by digest and exits **3** to preserve
both pending native subjects. `prefix-registration:vm-packaged` and
`prefix-registration:vm-detached` remain reusable recipes; the corrected final
reveal assertion has executable recorded-request coverage, but this corrected
whole recipe has not been claimed as another VM run.

No additional automatic registration experiments are authorized by this leaf.
The human continuation must decide the acceptance scope for the unavailable
native subjects, preserving v1's refusal of every long literal, expanded or
resolved spelling and its prohibition on substituting a running short copy.
