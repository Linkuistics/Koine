# Public file-reference URL acquisition prototype (k149)

**The corrected replacement collection completed all eight cases. Both tested
patterns acquired and locally read the original object at 900 and 1,023 bytes;
neither acquired the original long reference at 1,024 or 1,500 bytes.**
This is bounded evidence for these factories, subjects and local consumer on
macOS 26.5 (25F71), not a universal limit or production action acceptance.

The [authorized charter](long-action-route.md#authorized-file-reference-url-acquisition-diagnostic)
remains the scope. After the first attempt's driver defect, Antony explicitly
answered **"authorized"** to one replacement guest with the identical corpus,
APIs and bounds, overriding the no-guest-retry clause for that replacement only.
No other retry or experiment is commissioned. No production code, SDL, grant,
consent, registration, opener, Finder request or external submission changed.

## Measured result

| Original UTF-8 bytes | Direct reference creation | Component-relative fresh references | Original-item local read and recovered spelling |
| --- | --- | --- | --- |
| 900 | Acquired, reference predicate true, no base | Acquired through the final file, no returned base chain | Both: descriptor matches independent target, differs from decoy; exact marker; exact 900 original bytes |
| 1,023 | Acquired, reference predicate true, no base | Acquired through the final file, no returned base chain | Both: descriptor matches independent target, differs from decoy; exact marker; exact 1,023 original bytes |
| 1,024 | Null; Cocoa 258, underlying POSIX 63 | Null at final file (1,024 bytes); Cocoa 258 | Original-item URL reader/conversion unrun after acquisition failure; short same-object control passes |
| 1,500 | Null; Cocoa 258, no underlying error in record | Null at a directory prefix of 1,253 bytes; Cocoa 258 | Original-item URL reader/conversion unrun after acquisition failure; short same-object control passes |

Raw direct cases: [900](file-reference-url-acquisition/results/run2/direct-900.out),
[1,023](file-reference-url-acquisition/results/run2/direct-1023.out),
[1,024](file-reference-url-acquisition/results/run2/direct-1024.out),
[1,500](file-reference-url-acquisition/results/run2/direct-1500.out).
Raw relative cases: [900](file-reference-url-acquisition/results/run2/relative-900.out),
[1,023](file-reference-url-acquisition/results/run2/relative-1023.out),
[1,024](file-reference-url-acquisition/results/run2/relative-1024.out),
[1,500](file-reference-url-acquisition/results/run2/relative-1500.out).

The relative 1,024-byte case obtained base-free reference anchors through the
1,013-byte parent, then failed converting the final child. The 1,500-byte case
obtained anchors through 1,007 bytes, then failed at the next selected directory.
Neither advanced after its first failed reference stage. Recorded reference
spellings were produced by the public factories, never constructed by the probe.
Relative inputs had the expected borrowed base; successful returned anchors had
none. No returned base chain or URL text/depth ceiling failure was observed.

All eight independently constructed short same-object controls passed URL
acquisition, target/decoy descriptor identity, fixed marker reading, close and
exact short-path conversion. They use `linkat`-created short hard links as
controls only; those names were never supplied as fallback acquisition operands
for an original long case. Their presence limits the fixture population: this
experiment does not characterize items without hard-link controls or general
reference spelling stability. The successful original cases recovered their
original long bytes despite those alternate control names.

The [missing-name control](file-reference-url-acquisition/results/run2/missing-control.out)
returned a null reference with Cocoa 260 and underlying POSIX 2. Separately,
ordinary path-URL conversion returned the exact 39 missing-name bytes. Conversion
supplies no existence/classification/I/O fact. Errors remain typed native reports,
not an accepted production absence or failure-mapping contract.

## Attempts and instrumentation repair

The [first attempt](file-reference-url-acquisition/results/run1/summary.json)
created all four target/decoy pairs and ran the missing-name control, then stopped
before any of the eight acquisition cases. The helper emitted JSON numeric `0`
for `nonNull`; the driver incorrectly required `row.get("nonNull") is False`.
Python integer zero is not the Boolean singleton, so it rejected the valid raw
control. That attempt supplies no long acquisition result. Its original stop
text describes the driver's rejection, not a native control failure.

The exact [executed first driver](file-reference-url-acquisition/driver-run1.py)
is preserved and matches its frozen digest. The corrected driver accepts numeric
zero or Boolean false and still requires a typed error. An offline regression
replayed the actual raw control: it failed with the old condition, then passed
with the correction; four invalid-control rejection cases also pass. This was
the sole instrumentation correction. No helper source/API or signed binary
changed and no second build was needed.

The initial guest was already stopped. Antony authorized the one replacement
rather than treating the repair allowance as an automatic guest retry. The
[replacement summary](file-reference-url-acquisition/results/run2/summary.json)
reports completion, eight acquisition cases, unchanged subjects and successful
teardown. Aggregate actual counts are **one host build, two collections, one
driver correction, two expressly authorized guests, eight acquisition cases**.
Each summary's build/collection/repair fields are invocation-local static metadata;
they do not describe the aggregate history. There was no third collection.

The first clone-through-teardown interval was **19.69 seconds**; the authorized
replacement's interval was **22.20 seconds** under its fresh 15-minute cap. These
are separate intervals around the human decision; no continuous 15-minute
aggregate claim is made across the intervening conversation. No watchdog fired.

## Subjects, provenance and disposal

The [identical corpus](file-reference-url-acquisition/results/run2/corpus.json)
contains four component-created targets at exactly 900/1,023/1,024/1,500 original
ASCII bytes, excluding NUL. Components are at most 245 bytes; selected depths
including the file are 5/6/6/7. Fixed markers are unique, 16 or 17 bytes. Each
same-parent decoy is distinct by full native device/inode identity. Independent
`openat`/`fstat` controls pass in each case and are preserved in its raw record.

The [guest environment](file-reference-url-acquisition/results/run2/guest-environment.out)
records macOS 26.5 (25F71), arm64 / VirtualMac2,1, the root APFS snapshot,
Developer ID signature TA43A4RUP3, hardened runtime and empty entitlements.
Root-volume `diskutil` output is not an independent filesystem-type measurement
of the fixture's Data-volume mount. The fixture root's [native capability masks](file-reference-url-acquisition/results/run2/volume.out)
are preserved with status zero. Compilation used Apple clang 21.0.0 / SDK 27.0,
distinct from the guest OS. Both guests recorded the identical signed executable
SHA-256 `a274fed44ab8ba3a3f9e1e1fa373ba49dc49a00f6bed7fb7786803ecaca5eee5`.

Each attempt preserves exact raw stdout/stderr/exit codes, inputs, launch
receipts, [before](file-reference-url-acquisition/results/run2/subjects-before.json)
and [after](file-reference-url-acquisition/results/run2/subjects-after.json)
source/archive/corpus digests, and [output digests](file-reference-url-acquisition/results/run2/output-digests.json).
Both frozen subject sets stayed unchanged while measured. The corpus matches
byte-for-byte across attempts; the only measurement-subject change was the
host driver's verified predicate correction. Output manifests cover files present
at collection end, excluding each manifest itself and the subsequently written
summary. Current report/charter edits occurred after collection.

Caller-owned descriptor and URL-object ceilings are three; traversal is bounded
to 32 levels and URL logging to 8,192 bytes per value. Swaps own only anchor,
relative child and replacement; base/string inspections borrow rather than
retain URLs. Logging/conversion temporaries are serialized. The helper closes
independent descriptors and URL consumers. Opaque Foundation allocations are
outside these caller-owned bounds. Each invocation has an external guest-shell
30-second watchdog plus five-second termination grace. The final screenshot
and before/per-case UI snapshots are retained; no dialog was observed in those
snapshots. This is sampled UI evidence, not a general no-prompt guarantee.

Both [stop receipts](file-reference-url-acquisition/results/run2/vm-stop.json)
report successful disposal; a fresh inventory showed only the three golden
images. No TCC reset/approval, protected lookup, private-policy operation, cwd
change, external inquiry, bookmark/fd namespace fallback, hand-built identity
spelling or alternate acquisition API was used.

## Human reaction and retained gap

Antony's reaction to k149 on 2026-10-05: "It is an *absolute* requirement
that we work around the path limit. The raison d'etre of Koine fails otherwise."
Long-path support is a non-negotiable product requirement. The measured failures
exclude only these tested candidates; they authorize no shorter/copy-only
baseline, workflow loss or closure with the gap unresolved. Continue toward an
actual workaround under the retained contract. This statement does not itself
select a mechanism or waive the existing public-API, spelling, consent, setup,
receiver and receipt obligations.

The prototype delivers its bounded result and that reaction. K150 must continue
toward a supported workaround, retaining the precise failed-stage evidence and
all original obligations. No further native diagnostic is automatically
commissioned by this prototype; the complete-route task remains live.

A positive here establishes only measured acquisition, local reading/identity
and recovered bytes at the successful lengths. Neither reference nor conversion
passes native type/flags, exact-item binding, long-app registration/selection,
external original-byte delivery, real default/Zed rendering, Finder selection or
executable receipt. No long local-reader outcome is inferred where acquisition
failed. Keep k147/k144/k141/k135/k130/k128 live; k150 still owes the complete route
or exact gap, with the final review and independent action/search acceptance
sets retained. No workflow-loss exception, production route or final review is
earned by this experiment.
