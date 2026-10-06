# Local naming diagnostic — technical evidence

The [readable report](local-url-naming-prototype.md) gives the measured outcome.
This evidence belongs only to k161-1; k158 and every earlier corpus remain separate.

## Frozen instrument and inputs

- [Plan](local-url-naming/plan.md), [native helper](local-url-naming/probe.m),
  [driver](../../scripts/vm-probe-local-url-name.py) and
  [build recipe](../../scripts/build-local-url-name-probe.sh).
- [Fixture corpus](local-url-naming/results/corpus.json) and ten exact JSON inputs:
  fixture/original/bare/parent-public/parent-bare at 900 and 1,500 bytes.
- [Build 1](local-url-naming/results/build-1.txt),
  [build 2](local-url-naming/results/build-2.txt), final
  [signed package](local-url-naming/results/probe.zip),
  [host compiler/SDK](local-url-naming/results/host-build-environment.txt) and
  [instrument checks](local-url-naming/results/instrument-check.txt).
- Individual [before](local-url-naming/results/subjects-before.json) and
  [after](local-url-naming/results/subjects-after.json) SHA-256 manifests:
  672 unique subjects, including the public NSURL/CFURL headers, exact inputs,
  final executable/archive, driver transport, charter/signing/Taskfile and earlier
  native/item-array/URL/same-object/Zed/bookmark corpora and named dependencies.

Both permitted builds passed, using public SDK 27.0 and clang 21.0.0. The native
helper was never executed on the host. Python compilation, Ruff, shellcheck,
shfmt and five local supervisor guard tests passed. The guard tests first failed
against absent boundary behavior, then passed after deadline/disposal corrections.
They exercise partial input, complete input/EOF and stop-timeout/nonzero/surviving-
guest accounting without allocating a VM. These checks establish no native URL
or naming result. The public-parent nil/error correction preceded build 2 and
collection. The instrument remained unchanged afterward.

## Input and preparation observation

[Preflight](local-url-naming/results/preflight.json) records stdin/stdout both
terminal-backed, `/dev/ttys000`, `TERM=xterm-256color`, the actual random prompt
and matching received token. Its round trip took 4.33 seconds, before cloning.
[Driver log](local-url-naming/results/driver-log.jsonl) then records the clone
request, preparation checkpoint and independent READY response: preparation
prompt at elapsed 16.36 seconds, READY at 51.07 seconds. No later READY was sent.

The [fresh screenshot](local-url-naming/results/preparation.png) shows the
ordinary Finder desktop with no consent/security dialog. The supervisor inspected
that screenshot and all returned nodes from the
[full-mode agent snapshot](local-url-naming/results/preparation-ui.json) before
READY. The first verbose tool rendering truncated; a compact traversal of every
returned node was then read in full before responding. The snapshot contains
Notification Center widgets and Finder's menu bar. This is inspection of the
returned full-mode snapshot, not a claim of exhaustive hidden Accessibility
descendants: some entries retain child counts beyond its returned depth.
No word-matching detector or UI action supplied permission to proceed.

[Guest environment](local-url-naming/results/guest-environment.out) reports
macOS 26.5 / 25F71, Darwin 25.5.0 / xnu-12377.121.6, APFS Data volume, Gatekeeper
assessments enabled, Developer ID team TA43A4RUP3, hardened runtime, empty
entitlements and executable SHA-256
`9275a0e2028c091056876721a62854aa1a7a798a12c565e3c3817a04bf931971`.
That digest agrees with the frozen final host executable. The public SDK's
`sys/errno.h` defines errno 63 as `ENAMETOOLONG`; this labels the recorded POSIX
failure without inferring a higher-level URL error.

## First failed native stage and unrun stages

[900-byte fixture output](local-url-naming/results/fixture-900.out) records:

- Original marker: 23 bytes, exact; decoy marker: 20 bytes, exact.
- Parent device/inode 16777231 / 286932, directory mode 16832; the independently
  opened bare parent agrees. Target 286933 and decoy 286934 are distinct regular
  files (mode 33152); bare target agrees and its 23-byte marker is exact.
- Bare parent control `/.vol/16777231/286932/`; bare file control
  `/.vol/16777231/286933`. Full original pathname is recorded at 900 bytes.
- Helper completion with descriptor peak 2 and zero remaining descriptors.
  `urlLexicalMaximum:4` is the declared source bound, not a measured URL peak.

[1,500-byte fixture output](local-url-naming/results/fixture-1500.out) records
an exact 24-byte original marker and exact 21-byte decoy marker, then
`event:incomplete`, `stage:bareParentControlOpen`, `errno:63`. The
[exit record](local-url-naming/results/fixture-1500.code) is 3.
There is no completed controls/fixture/done row for this invocation, no logged
full identity set, no bare-file control, no post-case controls and no measured
descriptor or NSURL peak for the stopped invocation. Its process exits; the
guest is then removed. The source shows that this control appends `/` to the
bare parent address and calls O_RDONLY|O_DIRECTORY|O_NOFOLLOW|O_CLOEXEC open.
No unsuffixed comparison or fallback follows.

The immutable [summary](local-url-naming/results/summary.json) classifies the
driver stop as `supervisionOrControl`, with cause `guest command fixture-1500:
exit 3`. The precise first native failed stage is obtained from the raw row
above; the summary is preserved rather than rewritten with a derived label.

All eight cases remain unrun, in the fixed order recorded by the summary.
Bookmark creation, stored Name/Path extraction, resolution/stale/error reporting,
public parent-reference acquisition, relative construction, relative/absolute
text-name observations, absoluteURL resolution and returned-path open/fstat/
marker reading are unrun. No raw bookmark was produced. This control failure
does not establish an outcome for those candidate stages or any real receiver.

## Counts, disposal and integrity

One macOS clone of `koine-launchers-prepared`, one collection, two precollection
helper builds, two fixture invocations, one READY checkpoint, zero eight-case
attempts, zero external application requests, zero UI interactions, zero repairs
and zero retries. The 30-second helper watchdog was not needed; the failed
control stopped immediately. No collection inputs were edited during the run.

[Stop receipt](local-url-naming/results/vm-stop.json) reports `ok:true`,
`stopped:true`, id `koine-k161`; its command exited zero. The
[final inventory](local-url-naming/results/vm-list-after.json) contains only
three golden images and no clone, with `truncated:false`. Clone-through-disposal
took 55.22 seconds, within the 900-second cap. The prepared image is retained.

All 672 before/after subject entries were compared individually and independently
rehashes agree. Every one of the 45 entries in the
[final output manifest](local-url-naming/results/output-digests.json) agrees with
its file; the manifest excludes itself. Earlier evidence directories account
for 54 native-reference, 51 item-array, 151 file-reference-URL, 216 same-object,
123 focused-Zed and 34 bookmark subjects. Their contents were not altered or
merged with this run. No measured native/production support, original-spelling
action route, receiver filename, long-app selection/receipt or full acceptance
is established. k162 retains those obligations and the complete-route ancestors
remain open. Antony accepted the incomplete readable report on 2026-10-07; no retry or production exception follows.
