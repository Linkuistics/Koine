# Bookmark diagnostic technical evidence — k158-1

The [readable report](bookmark-name-resolution-prototype.md) gives the outcome
and proposed disposition. This document distinguishes preparation evidence from
the entirely unrun native measurement. It changes no previous corpus or route.

## Frozen instrument and run boundary

The binding [charter](focused-zed-route-assessment.md#finite-bookmark-diagnostic)
was authorized on 2026-10-06. The separate [plan](bookmark-name-resolution/plan.md),
[Foundation helper](bookmark-name-resolution/probe.m),
[driver](../../scripts/vm-probe-bookmark-name.py) and
[build recipe](../../scripts/build-bookmark-name-probe.sh) implement its finite
four-case ordering. Taskfile entries are `fixture:bookmark-name-resolution` and
`fixture:bookmark-name-resolution-vm`; their presence grants no rerun permission.

The exact invocation was `task fixture:bookmark-name-resolution-vm
OUTPUT=docs/verification/bookmark-name-resolution/results`, launched through the
harness shell tool without `tty: true`. At `preparation`, `select` reported stdin
readable and `readline()` returned the empty string immediately. The driver
treated that as STOP. Its raw stop text is `supervisor stop at preparation: `.
The [driver log](bookmark-name-resolution/results/driver-log.jsonl) records the
checkpoint at elapsed 18.49 seconds, its empty answer, and the stop. No READY
response, fixture invocation, helper invocation, creation or resolution followed.
The driver and launch were not repaired and the collection was not repeated.

The [summary](bookmark-name-resolution/results/summary.json) records one build,
one collection attempt, zero attempted cases, all four remaining cases, zero
external requests, zero repairs and `complete: false`. Its `firstFailure: null`
means no measured case supplied a native failure; the separate `stop` field
records the preparation failure. All native stages and controls are **unrun**.

## Preparation and disposal evidence

- [Build log](bookmark-name-resolution/results/build-1.txt) and
  [host environment](bookmark-name-resolution/results/host-build-environment.txt):
  Apple clang 21.0.0, SDK 27.0, successful build/signature verification, no host
  execution. Ruff, Python compilation, shellcheck and shfmt passed before collection.
- [Start receipt](bookmark-name-resolution/results/vm-start.json): sole guest
  `koine-k158`, base `koine-launchers-prepared`. No viewer was opened.
- [Guest environment](bookmark-name-resolution/results/guest-environment.out):
  macOS 26.5 / 25F71, Darwin 25.5.0, local APFS Data volume, assessments enabled,
  `dev.antony.Koine.K158Probe`, Team TA43A4RUP3, runtime flag and empty entitlements.
  Its installed executable SHA-256 is
  `f6cd131934e95e877239441cf6041eb4810492ab51e78d0a7f7aec1fc73c6a72`, matching the
  frozen host executable. Installation and environment command outputs, launch
  envelopes, stderr and exit-code files are retained in the results directory.
- [Initial screenshot](bookmark-name-resolution/results/preparation.png) and
  [full agent tree](bookmark-name-resolution/results/preparation-ui.json) were
  captured before the EOF stop. Later inspection shows the Finder desktop; it
  does not retroactively approve a live checkpoint, establish continuous UI
  observation, or prove that native bookmark calls are prompt-free. No UI was acted on.
- [Stop receipt](bookmark-name-resolution/results/vm-stop.json): `ok: true`,
  `stopped: true`; teardown exit zero. [Final VM inventory](bookmark-name-resolution/results/vm-list-after.json)
  contains no `koine-k158`. Elapsed clone-through-disposal time is 19.22 seconds,
  under 900 seconds. The original prepared image was not deleted or modified.

## Inputs, raw corpus and integrity

The [corpus](bookmark-name-resolution/results/corpus.json) and all six per-mode
input JSON files were frozen before cloning. They specify exactly 900/1,500 ASCII
pathname bytes excluding NUL, named originals `K158-original-900.txt` and
`K158-original-1500.txt`, sibling decoys and distinct 23/24-byte target markers.
Host arithmetic checks establish 4/6 directory components, each <=245 bytes,
but provide no guest fixture identity or readability. The root directory was
created during installation; the subjects themselves were not created.

The [before manifest](bookmark-name-resolution/results/subjects-before.json)
and [after manifest](bookmark-name-resolution/results/subjects-after.json)
hold per-file SHA-256 values for the plan/helper/driver/build/transport, signing
inputs, Taskfile, charter, SDK NSURL header, executable/archive/build log, exact
corpus/per-case inputs, and every retained k152/k155 evidence-directory file,
their reports and original build/driver scripts. All 368 subject entries match
individually, not merely in total. The
[output manifest](bookmark-name-resolution/results/output-digests.json) covers
all 30 collected output files before the manifest itself. The signed
[build archive](bookmark-name-resolution/results/probe.zip) is preserved. There
is no `.bookmark` file or case stdout because no native case was invoked.

## Caps and scope

Planned caller-owned caps remain three descriptors, four NSURLs, one bookmark
NSData <=65,536 bytes, stored/logged strings <=8,192 UTF-8 bytes and marker reads
<=64 bytes. The helper counts owned descriptors and uses operand/result/temporary
base URL ownership within the four-URL limit; separate processes release native
case values before the next. These are instrument provisions, **not exercised
runtime measurements**, and do not bound opaque Foundation allocations.

No security-scoped creation/access, private flag, unsupported file-ID preference,
filePathURL/fileReferenceURL conversion, fallback read, protected/remote/user
subject, copy/rename/link/alias fixture, cwd change, document receiver or
open/reveal/launch request ran. The prepared image's pre-existing applications
are not receiver evidence. Saving, Zed naming, Finder selection, native
facts/handlers, long application receipts, production spelling/support and full
action/search acceptance remain outside this stopped attempt.

The bookmark candidate is neither confirmed nor excluded. Antony answered
**"accepted"** on 2026-10-06 to the incomplete report for k159 to assess, with no
retry. No ADR selects a mechanism; no new experiment or contract exception is
commissioned. This completes only k158's scoped prototype and reaction; k159
retains the complete route and the unanswered bookmark question.
