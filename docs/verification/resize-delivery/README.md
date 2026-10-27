# Fresh-window resize delivery

The matched diagnostic comparison distinguishes the input recipe that failed on
fresh Koine from the qualified paced held-button route. It does not establish an
upstream defect or isolate a pure timing cause. Native qualification and the
complete scenario are recorded in the [main verification document](../menu-bar-vm.md).

## Declared comparison and actual effects

All trials used disposable clones of `testanyware-golden-macos-27`, macOS
27.0.1 build 26A434, arm64, 1920×1080 at 1×, with the unchanged signed Koine
0.4.0 bundle. [Doctor](doctor.json) reports CLI/app/bundle 2.7.0 and working
prerequisites; its failure is the existing disabled login item, left unchanged.
The guest reported Gatekeeper assessments enabled. Installation set no quarantine
attribute, so these runs are not Gatekeeper first-launch acceptance.

Setup completed before trial input. Koine retained its fresh 480×712 frame;
TextEdit's initial size was set to 480×712 through Accessibility, as preparation
only. Each selected window was moved to `(40,40)` and focused. Agent window order,
its focused flag and a fresh process's native front/active application read were
checked before each drag. The native observer is the [existing k7 source](../menu-bar-focus/activation-snapshot.m)
and [retained binary](../window-resize/failure-observer-binary). Koine ran first,
then TextEdit, with Koine moved clear. The ordinary-window comparison therefore
controls starting frame and input, but not app launch age or AX sizing history.

| Trial | Input from the 480×712 frame | Koine after | TextEdit after |
|---|---|---|---|
| [Inset 3](inset-3.log) | move to `(517,749)`, wait 0.5 s, one unpaced 100-step drag to `(740,940)` | 480×712, unchanged | 703×903 |
| [Inset 8](inset-8.log) | move to `(512,744)`, otherwise the same path/destination | 480×712, unchanged | 708×908 |
| [Paced held mask](paced.log) | original inset 3; move, wait 0.5 s, down, wait 0.2 s, ten held points with a 0.15 s sleep after each request, release at `(740,940)` | 703×903 | 703×903 |

Each row ran in its own fresh guest, one trial per app, with no drag retry. The
[comparison runner](compare.sh) and [paced runner](compare-paced.sh) retain the
operands. The `inset-3/`, `inset-8/` and `paced/` directories retain every input
response, agent before/after, native before/after and final screenshot. The
frames are observed effects, not conclusions from exit zero. Both unpaced
insets failed on fresh Koine while succeeding on TextEdit; an eight-pixel inset
alone is not the remedy. The paced held-mask route grew both applications.

TestAnyware's [v2.7.0 source](https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-rfb/src/input.rs#L115-L194)
sends mask 1 for each `mouse-down`, mask 0 for ordinary `move`, and no per-step
delay in combined `drag`. Each CLI request opens a separate connection. The paced
route therefore changes event spacing, point count and connection lifecycle. It
is not a persistent-connection experiment. CLI overhead adds to the requested
sleeps; actual guest event intervals were not measured. It cannot identify which difference
caused the result. It supplies a useful observed user-input route; it supplies
no TestAnyware defect ownership or Koine activation repair. Issue 12 remains a
separate closed connection-reset fault, and no upstream report was sent.

## Setup failures retained

Two preliminary launches supplied no drag trials. [Inset-8 preflight](preflight-8.log)
stopped because the general CLI playbook's `agent wait --id` option is unsupported
by that command. [Inset-3 preflight](preflight-3.log) was terminated during a
repeatedly timed-out read-only `spctl` assessment, before the same readiness call.
Both cleanup traps stopped their guests. The runner was corrected against
`agent wait --help` before the declared comparison ran. These are setup failures,
not failed or passing resize trials.

## Request and error checks

[Red controls](checks-red.txt) show five revised controls failing against the
unpaced helper and the existing preparation-failure control passing. The
[green checks](checks-green.txt) cover six resize cases, the existing eight menu
pointer cases, Bash syntax, ShellCheck and formatting. They check actual helper
requests at the CLI boundary, including an interior held point and the endpoint;
they do not establish guest effects. A failed down attempts release at that point
and returns the original error. A failed final release fails the exercise.

The current helper keeps the original three-pixel inset, sends the paced held
mask path once, then lets the scenario's unchanged dimensions and scroll controls
judge its result. It never substitutes AX frame assignment for resize acceptance.

## Qualification and assertion review

The [first focused run](qualification.log) used the paced helper and the inherited
size assertions. It grew to 703×903, stopped at 440×352 and reached all three
controls by scrolling. Its [installed before](menu-bar-20261028T102656-installed-before.txt)
and [after](menu-bar-20261028T102656-installed-after.txt) inventories agree.
The [initial wrapper](qualify-initial.sh), [host before](qualification-subjects.sha256),
[host after](qualification-subjects-after.sha256), [per-file checks](qualification-subject-check.txt)
and symlink endpoint files retain that subject. This is a focused result, not a
complete menu-bar pass.

The one [fresh-context review](review.txt) found two inherited acceptance gaps:
a `read` could discard a failed frame query, and the outer-frame lower bound
did not itself enforce 320 content pixels. Both were actionable. The
[guard controls before repair](guard-checks-red.txt) rejected neither a failed
frame read that emitted geometry nor an undersized content area. The
[corrected checks](guard-checks-green.txt) pass nine resize controls and the eight
existing pointer controls, with syntax, ShellCheck and helper formatting.
The scenario now checks frame-query status before parsing and separately reads
the scroll area's actual content height. No platform title-bar constant is used
to establish that minimum. The original outer-frame bounds remain in force.

The [final focused wrapper](qualify-final.sh) extracts the real corrected scenario
section. It runs separately from the one complete scenario. Both use
[the final frozen subjects](final-subjects.sha256), including the original signed
release bundle, final helper, actual scenario, wrappers, shared libraries,
fixtures, Taskfile and App/Info.plist. Their results are recorded separately in
the main verification document.

## Measurement limits and source retention

The comparison and paced trials have matching host before/after inventories and
item checks, but no installed before/after inventories. They establish diagnostic
input effects, not bundle runtime immutability. The original comparison inventory
was captured after launching setup and before its first drag; it is not a
pre-setup freeze. The later paced and focused inventories preceded their launches.

[Comparison before](comparison-subjects.sha256), [after](comparison-subjects-after.sha256)
and [checks](comparison-subject-check.txt), plus [paced before](paced-subjects.sha256),
[after](paced-subjects-after.sha256), [checks](paced-subject-check.txt) and
[runner digest](paced-runner.sha256), preserve the item-level evidence. The
[comparison inventory builder](comparison-inventory.sh) and
[initial qualification builder](qualification-inventory.sh) preserve their old
bytes; the [current builder](inventory.sh) adds the final wrapper. Old builders
were recovered and matched to the measured digests after the later additions.
The [initial source](initial-source/) and [final source](final-source/) retain
versions that changed during the investigation. Endpoint inventories prove
endpoint equality only; they do not prove no temporary runtime mutation occurred.

The process outcomes retained during collection were: preflight inset 3 exited
143 after explicit termination; preflight inset 8 exited 2 on the rejected flag;
comparison inset 3, comparison inset 8, paced comparison, initial focused
qualification and final focused qualification each exited 0. The comparison
scripts' cleanup traps stopped their clones, and the shared focused-run cleanup
did the same. [The post-focus inventory](vms-after-focus.json) contains only the
still-running complete-scenario guest from this investigation. Its separate
final outcome and cleanup are recorded in the main document.

The [source archive comparison](archive-check.txt) matches each retained changed
source/runner/builder to its corresponding measured digest. The final focused
run measured 703×903 growth, a 440×352 minimum frame and a 320-pixel scroll area,
then reached the required controls by scrolling. Its
[raw content observation](menu-bar-20261028T103029-least-size-content.json),
[installed endpoints](menu-bar-20261028T103029-installed-after.txt),
[host re-enumeration](final-focus-subjects-after.sha256) and
[item checks](final-focus-subject-check.txt) retain the corrected instrument's
positive result. Input recipe sensitivity is established for these finite
subjects; the internal mechanism behind the unpaced route's failure remains
unresolved because pacing, point count and connection lifecycle changed together.
The parent contract is satisfied by a useful qualified route, without assigning
an unsupported external defect.

## Complete scenario and cleanup

The one [complete scenario](scenario.log) exited [0](scenario.exit), with every
intended assertion run, including minimum-size scrolling, the request/status
menu paths, consent, silent launch, reopening, login restart and final Quit.
Its 1920×1080 initial display reverted to [1024×768 after restart](scenario-final-display.json).
The [host after inventory](scenario-subjects-after.sha256),
[item checks](scenario-subject-check.txt), [installed before](menu-bar-20261028T103051-installed-before.txt)
and [after](menu-bar-20261028T103051-installed-after.txt), plus symlink/manifest
comparison files, match the final before subject. The
[explicit stop](scenario-stop.json), [VM inventory](vms-after.json) and
[tart states](tart-after.txt) show cleanup. All new investigation guests are stopped.
This single positive supplies no reliability rate and leaves the historical
activation cause to k4. Earlier failed and NOT RUN attempts remain as recorded.

The final guard regression was also recreated from the unchanged final Bats
file and helper against the archived old scenario in an isolated test tree.
[Its subjects](guard-red-subjects.sha256) and [after checks](guard-red-subject-check.txt)
identify that control, which fails exactly the two guard cases and leaves its
valid-minimum control green. It makes no GUI input and changes no frozen native
subject.

The [installed-to-input comparison](installed-input-check.txt) also normalizes
the frozen extracted host bundle's regular-file paths and symlink targets to
[the guest inventory format](expected-installed.txt). Both endpoints of each
focused run and the complete scenario match that input, in addition to matching
each other. This associates each installed native subject with the retained
host release input; it still supplies no continuous runtime immutability proof.
