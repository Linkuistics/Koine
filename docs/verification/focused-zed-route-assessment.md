# What the Zed and stopped bookmark results establish

**Zed can read the original 1,500-byte-path file through its short same-object
address on the tested system. Bookmarks might recover naming information, but
we have no evidence that they give Zed both the original filename and a usable
long-file address.** The complete Koine route remains unresolved.

Antony accepted the [focused receiver report](focused-zed-receiver-prototype.md)
on 2026-10-06. That accepts the observation; it adopts no production workaround
and commissions no further experiment. This assessment consumes that report
and Antony's subsequent bookmark and cleanup questions.

Antony subsequently authorized the exact
[finite bookmark diagnostic](#finite-bookmark-diagnostic) on 2026-10-06. Its
[accepted incomplete report](bookmark-name-resolution-prototype.md) supplies
no bookmark measurement: the sole collection stopped on closed supervisor input
at preparation, before creating fixtures or executing any case. The guest was
disposed after 19.22 seconds. Acceptance grants no retry. Returned design k159
retains the complete supported-route obligation under k156; the
[replacement](#replacement-bookmark-decision) is now approved. Antony also
requested the [parent-reference plus name](#parent-reference-plus-original-name)
question; its separate local cases share the replacement's single collection
and aggregate budget. All new measurements remain unrun.

Start with the [receiver and bookmark view](../design/architecture/index.html#diagram-workspace-route-candidates).
Graphs enter at the dark **Start here** node; numbered edges indicate reading
order. The diagram and the following sections describe evidence and the charter,
not a selected production mechanism.

## The measured receiver positive

The one disposable macOS 26.5 / 25F71 guest ran Zed 1.22.0 at the exact short
registered installation. It made two requests, one for a 900-byte control and
one for a 1,500-byte original path, then disposed the guest in 152.15 seconds.
Each request used a bare device/full-inode address for the original object,
with independent original/short-address identity, unique marker and decoy checks.
No file was copied, moved, renamed or linked.

Zed was absent before each request. Independently acquired PID/kernel start
instant, callback/live/selected executable identities and window-owner records
attributed the fresh buffers to the selected copy. Both callbacks arrived within
three seconds. Each request showed **Unrecognized Project**; the authorized
fixture-only **Stay in Restricted Mode** choice granted no trust. Both target
markers were visible afterward in unobstructed real buffers. This supplies
receiver access beyond an acknowledgment or filename alone.

The long buffer's title was the inode number **223952**, rather than
`K155-target-1500.txt`. Exact delivered operands were not intercepted. Saving,
later editing operations and prompt-free production behavior were not tested.
The [technical evidence](focused-zed-receiver-technical-evidence.md) owns the
process checks, typed causes, limits and raw records; its corpus is unchanged.

## What remains required

| Stage | What this diagnostic establishes | Remaining production obligation |
| --- | --- | --- |
| Original object access | Exact original 900/1,500-byte files and decoy exclusion, before/after the short-address requests | General per-action component resolution, symlink/dot/trailing semantics, policy and cause provenance; no retained client identity |
| Native payload facts | Some file/directory/package/alias/executable flags returned | Long application and content-type acquisition failed with Cocoa 256 / underlying POSIX 28; treat these as unacquired facts, not false or absent. General native refusal/type/identifier parity remains required |
| Exact-item handler | TextEdit URL returned for both fixtures | General native applicability, error/nil provenance and prompt behavior; no default-open action was run |
| Selected-copy receipt | Exact short Zed copy, PID/start instant and executable identity observed for both requests | Exact long registered-app selection, bundle identifier, constrained launch/named opening and long executable receipt; no systematic length-caused null |
| Receiver | Fresh exact contents in Zed after the explicit restricted-mode choices | Original external spelling, default application, directory/settings workflow and actual Finder selection; no generic receiver or no-prompt pass |
| Native address/support | Bare short addresses reached both originals on this guest | Durable supported basis and general volume/full-inode behavior. The long basename was lost; no production spelling or support exception is agreed |
| Lifecycle and acceptance | Both callbacks within three seconds, guest disposed, no recollection | Grants/revocation/cancellation/timeout regressions, binary/public acceptance, independent long action fixtures and later actual-search G/N/V provenance |

Retained action 1.0.0, designed action-only repair 1.0.1 and search 1.1.0 remain
independent subjects. The [reviewed action boundary](long-action-native-boundary.md)
preserves established short-cycle/impossible-component/nil meanings while
distinguishing failed acquisition. k128's complete-route review and subsequent
planning remain owed. Earlier finite failures prove no universal impossibility.

## Bookmarks and Zed's filename

A macOS bookmark is data that can later resolve into a URL to a resource's
current location. It can include requested resource properties that are readable
without resolving the bookmark. These are useful facilities for tracking a file
and recovering information about it; Apple does not promise that they bypass a
whole-path consumer's limit or supply a separate display name to an application.
[Bookmark creation](https://developer.apple.com/documentation/foundation/nsurl/bookmarkdata(options:includingresourcevaluesforkeys:relativeto:)),
[stored resource values](https://developer.apple.com/documentation/foundation/nsurl/resourcevalues(forkeys:frombookmarkdata:)).

The pinned Zed 1.22.0 macOS `openURLs` callback converts each incoming NSURL's
`absoluteString` into a string. Its file ingress strips `file://`, percent-decodes
the remainder and stores a path. **This inspected path does not carry bookmark
properties or an independent original-name field into the editor.** AppKit may
resolve/coerce a bookmark before that callback; such behavior is unmeasured here.
[macOS callback](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/gpui_macos/src/platform.rs#L1488-L1509),
[file parser](https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/zed/src/zed/open_listener.rs#L160-L220).

There are three distinct possible results. A bookmark could retain the original
name but resolve to the long original pathname, leaving the known opener/reader
problem. It could resolve to a readable short identity address while retaining
the number-only basename. Or it could yield a readable, original-name URL; that
would be a promising new result requiring real receiver verification. None is
established for these long subjects. A stored name alone improves Koine's own
display; it does not prove Zed will show that name.

Our [earlier item-array recorder](item-array-submission.md) already received
bookmark descriptors with exact stored path bytes at 900/1,023 bytes. At 1,023,
URL coercion was unreadable even though the stored path could be extracted.
Both openers stopped at 1,024 before recorder delivery. This is a concrete
reason to keep **stored information**, **resolved URL** and **usable receiver
address** separate. It is neither a long-bookmark creation result nor a Zed test.

SDK 27.0 marks `NSURLBookmarkCreationPreferFileIDResolution` unsupported and
says it has no effect on resolution. It is not a switch that preserves a short
file-ID operand. A file-reference URL is also distinct from bookmark data;
k149's failed long URL factories do not answer bookmark creation from the short
same-object address. Security-scoped bookmarks concern sandbox access, not
filename presentation, and add no naming solution under the current posture.
[File-reference URL](https://developer.apple.com/documentation/foundation/nsurl/filereferenceurl()),
[file-ID preference](https://developer.apple.com/documentation/foundation/nsurl/bookmarkcreationoptions/preferfileidresolution).

## Bookmark lifetime

An action-local bookmark can be created after fresh resolution of the client's
observed pathname, used during that action and discarded afterward. Ordinary
in-memory bookmark data needs no persistent registry or garbage-collection
service. A durable bookmark catalogue would instead introduce retention,
staleness, volume availability and eviction decisions, and could change the
current path-revalidation contract. It is not proposed.

If security-scoped access is used, starting and stopping access has a separate
resource lifetime. This diagnostic uses neither security-scoped creation nor
`startAccessingSecurityScopedResource`. The SDK also documents implicit scope
on ordinary bookmarks; the authorized diagnostic explicitly disables its creation
and implicit start. Releasing our data does not establish bounds on opaque
Foundation allocations. [Implicit scope option](https://developer.apple.com/documentation/foundation/nsurl/bookmarkcreationoptions/withoutimplicitsecurityscope),
[NSURL access lifetime](https://developer.apple.com/documentation/foundation/nsurl).

<a id="proposed-finite-bookmark-diagnostic"></a>

## Finite bookmark diagnostic

**Authorized on 2026-10-06; collection stopped before measurement and accepted
incomplete.** Antony answered **"authorized"** to this exact four-case local
test, then **"accepted"** to k158's stopped report. Its allowance is spent;
every case remains unrun and no repair or recollection is authorized. The
original charter below is retained for provenance. Its question is:
*can an ordinary, action-local bookmark made from the verified short
address recover the long file's original name and resolve to a URL that still
reads that same file?* This is a narrower and cheaper question than another Zed
run. A negative or original-name/long-path-only result ends this candidate's
local assessment; it supplies no automatic successor experiment.

- One disposable macOS guest, one collection, at most two builds before it,
  a 15-minute clone-through-disposal cap and no repair/recollection. Use the
  existing prepared image, signing and public SDK posture. Launch no document
  application and make **zero external open/reveal/launch requests**. Unexpected
  security/consent UI stops the collection without interaction.
- Independently component-create one harmless ASCII text file at 900 bytes and
  one at 1,500 bytes, excluding NUL, each with an original named final component,
  a same-parent decoy and distinct fixed marker. Use no protected/remote/user
  files, copy, rename, hard/symbolic link, cwd change or file-backed alias.
  Recheck original and bare device/full-inode identity and at most 64 marker
  bytes before and after each case. A failed identity control ends incomplete.
- Four serialized cases: original-path and verified bare-native-ID NSURL at
  each length. For each, call `bookmarkDataWithOptions` once, requesting only
  `NSURLNameKey` and `NSURLPathKey`, with
  `NSURLBookmarkCreationWithoutImplicitSecurityScope` and no relative base.
  Extract only those stored properties. Resolve once with `WithoutUI`,
  `WithoutMounting` and `WithoutImplicitStartAccessing`, without security scope.
  No retry, file-ID-preference flag, additional creation pattern or private API.
- Record creation/resolution errors with underlying causes, stale flag, returned
  URL spelling/base/reference predicate, stored original-name/path equality and
  final basename. If a base-free file URL is returned, extract its `path` once
  as UTF-8, record those exact bytes and issue one whole-path
  `open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)`, then `fstat` and at most a
  64-byte `read`. Compare device/inode/marker against original and decoy; record
  extraction failure or exact POSIX errno as that stage's failure. Use no
  `filePathURL`, `fileReferenceURL`, canonicalization, NSURL/NSFileHandle content
  reader, component-walk or short-address fallback for this measured read.
  Component walks establish fixture/control identities only. A non-file/base-
  chained result ends incomplete. No opener or inferred Zed result follows.
- Keep at most three caller-owned descriptors and four caller-owned NSURLs
  alive, one serialized bookmark NSData capped at 64 KiB, bounded stored/logged
  strings at 8,192 bytes and each local marker at 64 bytes. Check result size
  before copying/logging; these consumption limits do not bound native allocation
  before return. End incomplete on a returned base chain, oversized/unaccounted
  value or unusable observer. Explicitly release case values before the next.
- Preserve a separate plan/instrument/raw corpus, per-input/output digests,
  counts, first failed stage and teardown receipt. Existing k152/k155 evidence
  stays immutable. Grade stored-name recovery, URL resolution and actual same-
  object reading independently; a successful creation/status is not a pass for
  the other stages. Obtain Antony's reaction to the readable report.

The authorized test preserves the full route requirement. Adopting the bare
namespace now is not recommended:
failed facts, number-only naming and Apple's lasting-support caveat remain.
[Apple DTS on volfs](https://developer.apple.com/forums/thread/103162).

This authorization permits only transient internal bookmarks and already-known
bare-address fixture acquisition. It approves no
production spelling, support, consent, trust, persistent reference protocol,
workflow loss, implementation or automatic follow-on. A promising result would
return to k159 for a separately settled next step; k156 and every route ancestor
stay live until the complete agreed supported route exists.

## Stopped bookmark result and remaining route

The [raw summary](bookmark-name-resolution/results/summary.json) and
[checkpoint log](bookmark-name-resolution/results/driver-log.jsonl) agree:
one build, one collection attempt, zero attempted cases, zero external requests
and zero repairs. At preparation, the driver's `readline()` received EOF instead
of an inspected READY response. It stopped and disposed the guest. This is an
execution failure before the native experiment, not a native bookmark failure.
The [technical evidence](bookmark-name-resolution-technical-evidence.md) owns
the exact instrument, SDK/build provenance, frozen subjects and teardown records.

| Question | 900-byte original / bare address | 1,500-byte original / bare address | Consequence |
| --- | --- | --- | --- |
| Stored original Name/Path | Both unrun | Both unrun | No recovered-name/path observation |
| Resolved URL, spelling and stale flag | Both unrun | Both unrun | No returned address or resolution cause |
| Returned-path open/fstat/marker read | Both unrun | Both unrun | No reader success, errno or object match |
| Original/bare-address/decoy controls | Both unrun | Both unrun | No guest fixture identity or marker control |

The helper was built and installed but never executed. Native ownership, size,
marker and observer provisions were therefore not exercised as case measurements.
The summary's `firstFailure: null` describes the absence of a measured case;
the separate preparation STOP is the first failed stage. Later inspection of
the captured desktop cannot retrospectively approve the missing checkpoint.
Antony's **"accepted"** acknowledges this incomplete report only.

The earlier [stage table](#what-remains-required) still owns the full route
gap. The accepted Zed observation establishes fresh reading by the exact short
registered copy after fixture-only restricted-mode choices; its long filename
is inode-only, delivery is opaque and saving is untested. Native application/type
facts still fail. Original external bytes and durable support, default opening,
directory/settings and Finder workflows, exact long registered-app selection,
constrained launch/named opening and PID/kernel-start/live-executable receipt
remain required, with short regressions, both controls, revocation/cancellation,
three-second acknowledgment and the unchanged consent/setup/private-policy
posture. A local bookmark positive would answer only its measured local stages.

Public observed pathnames remain re-resolved for each action; transient internal
bookmarks confer no retained client identity. Independently component-created
action fixtures and later actual-search G/N/V evidence remain distinct, as do
retained action 1.0.0, designed repair 1.0.1 and search 1.1.0. All route nodes
remain live. A complete supported design must precede k128's mandatory review,
earned integration and planning's native/binary/public acceptance.

## Replacement bookmark decision

**Approved on 2026-10-06.** Antony answered **"approved"** to one replacement
collection of the same four local bookmark cases. This is new permission;
acceptance of k158 alone supplied none. His same message asks whether a parent
directory reference plus the original final name could let tools such as Zed
use that name. The [additional local group](#parent-reference-name-diagnostic)
answers that requested construction question within the same one guest, one
collection and 15-minute aggregate cap. It changes no bookmark case/options
and supplies no receiver, production or complete-route permission.

| Approach | What it answers | Cost and limitation |
| --- | --- | --- |
| One replacement local collection (approved) | Stored Name/Path, actual resolved URL and whole-path same-object reading for the four original cases | One disposable guest, at most 15 minutes; it still supplies no Zed naming, opener parity or production support |
| Source-only reassessment | Reconsiders the already inspected contracts without native execution | No guest cost, but declarations cannot determine these unmeasured native outcomes |
| Leave this candidate unanswered | Preserves the current evidence and complete requirement | No new work; the route and bookmark question remain unresolved |

The approved bookmark group retains these bounds:

1. One new disposable macOS guest and one collection, using the existing
   prepared image, public SDK and signing posture. At most two builds before
   collection, with a 15-minute clone-through-disposal cap and 60 seconds
   reserved for teardown. Zero external open/reveal/launch requests; no receiver,
   security/consent interaction, repair or recollection.
2. Before allocating that guest, launch the supervisor/driver with an actual
   interactive terminal and verify one explicit input round trip within 60
   seconds. Record the terminal predicate, preflight prompt and received token
   in the new corpus.
   EOF, timeout or inability to inspect/respond ends the attempt before cloning.
   This token establishes transport only: fresh guest screenshots and full
   agent-tree inspection remain necessary before each separate READY response.
   Never pre-supply READY or change EOF/timeout into permission to continue.
3. Retain the original four serialized bookmark cases: original-path and verified bare
   device/full-inode NSURL for independently component-created 900/1,500-byte
   ASCII files, each with a named final component, sibling decoy and unique
   marker. Preserve the original/bare-address identities and marker controls
   before and after each case. Use only harmless local disposable subjects;
   no copy, move, rename, link, alias, cwd change or protected/remote/user file.
4. Keep the [original charter's](#finite-bookmark-diagnostic) exact bookmark
   options, only Name/Path properties, one resolution and one returned-path
   UTF-8 extraction followed by whole-path open/fstat/at-most-64-byte read.
   Keep its three-descriptor/four-NSURL/one-64-KiB-bookmark/8,192-byte-string
   limits, no implicit/security-scoped access, conversion, canonicalization or
   fallback, and incomplete stops for control, observer, type, base-chain or
   size failures. These caller consumption limits bound no opaque allocation.
5. Freeze a new plan, instrument and all input subjects before measurement;
   write outputs into a separate new corpus with one writer. Preserve
   k158 and every earlier instrument/raw corpus unchanged; do not overwrite
   the old results or fold the two attempts into one success. Record all typed
   causes, counts, unrun stages, the first failed stage, input digests before
   and after, final output digests and teardown receipt. Return one readable
   report for Antony's reaction. No
   automatic receiver request, successor experiment, persistent registry,
   production exception, final review or implementation follows.

This changes the launch/supervision prerequisite, not the bookmark mechanism
or measurement. The additional parent-reference group is separately identified;
eight local cases share one collection. Native execution belongs to a fresh
prototype after this source/charter handoff; returned design must consume its
readable report and Antony's reaction before any further native work.
Even a stored original name plus successful local read would need a separately
settled real receiver/naming and supported-route step; a finite negative would
exclude only the tested candidate, not prove universal impossibility.

## Parent reference plus original name

Antony asked on 2026-10-06 whether a file URL whose reference identifies the
parent directory, followed by the original name, would let tools such as Zed
use that name. This is a distinct question: **preserving a name in the URL,
reading the same object and displaying that name in Zed are separate stages.**

The public NSURL constructor accepts a file path, an explicit directory flag
and a relative base URL. A directory reference as that base could therefore
produce a relative input whose final component is the original name. This is
an API construction candidate, not a promise about native resolution or readers.
[NSURL relative constructor](https://developer.apple.com/documentation/foundation/nsurl/init(fileurlwithpath:isdirectory:relativeto:)).

The earlier k149 record already contains a `target.txt` relative input based on
a directory reference at 900 bytes. It then invokes the file-reference factory
**on the child** and records an identity-only final URL. Its longer runs fail
that per-component factory. It did not read the unconverted, name-bearing
absolute child URL. Those results therefore do not settle this new question.
[Earlier relative inputs](file-reference-url-acquisition/results/run2/relative-900.out),
[earlier report](file-reference-url-acquisition-prototype.md).

Source gives two concrete cautions, not an unmeasured native verdict:

- Historical public CoreFoundation converts a reference to a path when
  appending a component if conversion succeeds. Its absolute-URL routine has
  a different branch for reference bases that already end in a directory slash.
  The relative constructor is therefore the fixed candidate; no appending API
  or child-reference conversion may silently substitute for it. This old CF
  snapshot is not the guest's current Foundation implementation.
  [Appending](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFURL.c#L4486-L4525),
  [absolute resolution](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFURL.c#L2701-L2775).
- Pinned XNU expands a native device/inode reference to the original pathname;
  for a remaining suffix it appends through `MAXPATHLEN` and can return
  `ENAMETOOLONG`. The parent-ID-plus-name form thus has a concrete long-path
  hazard despite its short input. This source tag is explanatory evidence,
  not an identification or measurement of the guest's exact kernel.
  [Native reference suffix](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/vfs/vfs_lookup.c#L2312-L2455).

The pinned Zed callback and file parser above consume the absolute URL string
as a path and carry no independent display-name field. A short name-bearing
absolute URL that actually reads the original would be promising for this
input route. Foundation/Launch Services delivery, Zed's exact received operand,
its fresh same-object contents and its tab title would still need a separately
settled real receiver test. A constructed name, local read or source branch
alone earns no Zed result. No formal state model can determine these opaque
native/receiver behaviors; the instrument is controlled observation.

## Parent-reference name diagnostic

**Requested on 2026-10-06; all four cases unrun.** Antony's additional question
adds this separately labelled group to the approved replacement collection.
It consumes no second guest, collection, build allowance or time budget.
The bookmark group's four cases and options remain exact; eight total local
cases serialize under the same 15-minute clone-through-disposal cap, with
60 seconds reserved for teardown and the same interactive-input preflight,
inspected READY checkpoints, zero external requests and no repair/recollection.
If time expires, report the remaining stages/cases unrun, without replacement.

| Case at each original file length (900 / 1,500 bytes) | Fixed input and construction | Measured read |
| --- | --- | --- |
| Public parent reference plus original name | From the independently verified bare parent-device/full-inode directory NSURL, call public `CFURLCreateFileReferenceURL` once, preserving its typed error; then `fileURLWithPath:name isDirectory:NO relativeToURL:parentReference` once | One absolute child URL's exact `path` UTF-8 bytes into whole-path open/fstat/marker read |
| Bare parent address plus original name | Use the independently verified `/.vol/<device>/<full-parent-inode>/` directory NSURL as the base; call the same relative constructor once with the original basename | The same fixed absolute-child path consumer |

Use the same harmless independently component-created ASCII 900/1,500-byte
original files, with basenames made only of ASCII letters, digits, dot, dash
and underscore, unique markers and same-parent decoys as the bookmark group.
Verify the original parent directory identity/type as well as original-file,
bare-file-address and decoy identity/marker controls before and after each case.
Control walkers are not the measured reader. Use no protected/remote/user file,
copy, move, rename, hard/symbolic link, alias, cwd change or private API.

For the public case, require the factory's returned URL to be a base-free file
reference with the directory predicate; record its actual spelling and trailing
slash without synthesizing or repairing it. Nil/error is an acquisition-stage
result with later stages unrun; nil without a cause remains unacquired, not
absence. An unexpected returned type/base/directory shape ends incomplete.
For the bare case, record the independently verified parent address exactly.
Do not handcraft a `/.file/id=` reference, append a path component through another
API, convert the child to a reference/path URL, canonicalize or fall back.

Record the relative child's actual relative spelling, reference/file/directory
predicates, original basename equality and base relationship. Do not request
its `absoluteString` before the explicit absolute-URL stage. Its
constructor may already produce a base-free result; otherwise accept exactly
one base identical to the supplied base-free parent and record that shape.
Invoke `absoluteURL` once, requiring a base-free file result before reading.
A nil absolute result is that stage's failure; an unexpected shape ends
incomplete. Only from that returned absolute URL, record its absolute spelling
and reference predicate. For both relative and absolute name observations,
compare names using only the already recorded URL text. A fixed bounded
UTF-8 parser selects its path's final slash-delimited component, percent-decodes
that component once with strict hex validation and compares its exact bytes
with the fixture basename. For a relative string, accept either a relative path
or a syntactically absolute file URL and parse that recorded shape; never use
NSURL/CFURL parsing or name/resource getters. Empty, malformed or unparseable
text supplies an unacquired-name stage, not a name pass or native absence, and
does not substitute for the independent read. In particular forbid
`lastPathComponent`, `CFURLCopyLastPathComponent` and resource-name lookup for
this name-in-URL observation: the historical CF getter itself can resolve a
reference.
[Resolving CF name getter](https://github.com/apple-oss-distributions/CF/blob/dc54c6bb1c1e5e0b9486c1d26dd5bef110b20bf3/CFURL.c#L4388-L4430).
Then extract the absolute URL's `path` once as UTF-8. Issue exactly one
`open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)`, then `fstat` and at most a
64-byte read. Compare device/inode/marker with the original and decoy; preserve
extraction failure or the exact POSIX errno. Do not use NSURL/NSFileHandle
content readers, component walks or a bare-file fallback for this read.
A fixed local stage failure does not retry; later cases can run only while
controls, observation and the aggregate budget remain valid.

Keep the existing three-descriptor/four-NSURL/8,192-byte-string/64-byte-marker
caller limits. The public case can hold parent operand, returned parent reference,
relative child and absolute child (four); release the operand after acquisition
and explicitly release all case values before the next. Borrowed base URLs add
no new retained owner. Use per-case autorelease pools and record aliases/ownership
so an absolute/relative identity alias is not counted as another object.
Release all bookmark objects/data before this group; create no bookmark in it.
Check returned string sizes before copying/logging and terminate incomplete on
oversized/unaccounted values or an unusable observer. These caller limits bound
no opaque native allocation.

Freeze the new plan/instrument and all inputs before the sole collection; keep
one writer and a separate new output corpus. Preserve k158 and every earlier
instrument/raw corpus unchanged. Report the two groups and every stage separately,
including typed causes, counts, first failed stage, skipped/unrun/incomplete
cases, per-subject before/after digests, output digests and teardown receipt.
Return one readable report for Antony's reaction. Original-name equality and
successful same-object reading must both be observed to call a local named
candidate positive. No external Zed request, restricted-mode choice, trust grant,
receiver-name pass, lasting-support verdict, production selection, persistent
registry, final review, implementation or automatic successor follows.

## Verification of the returned assessment

The presentation and 967-subject check below apply to the preceding proposed
replacement revision. The approved combined charter is verified separately
before this source/charter handoff; these earlier checks earn it no credit.

`task design:workspace-render` completed; D2 0.9.0 regenerated the changed
candidate view. Separate initial and final `task check:docs` runs passed.
Every subject in each run's frozen documentation/native-evidence, Taskfile,
document-checker and bookmark-instrument set matched its individual digest
afterward. The final run includes the preflight and verification-note edits;
these edits earn no earlier check's credit.
All k158 output-manifest entries match individually, and its original frozen
before/after subject manifests agree individually. The raw stop log and summary
retain zero cases and the separate preparation failure.

Firefox 151.0.3 in an isolated Linux presentation clone displayed the fresh
candidate deep link, current/updated markers and readable upper graph labels
in light and dark appearance. The complete 1,200-pixel light export was inspected
with its stop, proposal, bounds and unresolved-route branches. The settled dark
discussion displayed all seven context links and the changed-view summary;
its actual 320 × 480 responsive viewport showed the title, proposal status and
introductory prose reflowing without horizontal clipping. The four viewer,
manifest, editable-source and SVG digests match individually between host,
guest and served host bytes. A failed native window-resize command and a
timed-out headless screenshot add no evidence. The full dark export was not
inspected. This is presentation verification, not a macOS bookmark or action run.

Public SDL/examples, compatibility subjects and production code are unchanged
by this assessment. No new macOS diagnostic, application request, native fact,
receiver naming result, binary/public acceptance or complete route is claimed.
The final documentation check is recorded in k159's running decisions; the
complete-route node and all route ancestors remain live. The approved local
prototype and returned route design are separate fresh sessions.

## Approved charter verification

`task design:workspace-render` completed after the approval/parent-reference
revision with D2 0.9.0. The complete updated 1,200-pixel light export was inspected:
the two groups, shared bounds, local consumer, pending receiver and full-route
branches are readable without overlapping labels. Firefox 151.0.3 in the
isolated Linux presentation clone `koine-k160-approved-design` rendered a fresh
candidate deep link in light and dark appearance, with the intended topic,
Current/Updated markers and readable upper labels. The settled dark discussion
showed the approved/eight-unrun status, all seven context links and the actual
changed-view summary. Its real 320 × 480 responsive viewport reflowed the title,
status and introductory text without horizontal clipping. Browser windows were
maximized on the 1,600 × 1,100 guest display; the requested 1,280-pixel launch
width did not determine the observed window size.

The four viewer/manifest/editable-source/SVG subjects match individually between
host, guest and served host bytes. The guest presentation copy contained those
four subjects; other exports were not rerendered there. The complete dark export
was not inspected. An inaccessible initial profile, premature screenshots and a
rejected scroll argument earn no rendering credit. This clone was disposed;
no macOS native naming/reader/receiver case was run by this design session.
The final deterministic documentation and immutable-evidence checks are recorded
in source/charter k160's running log before retirement and commit. The final route
k162 and k159/all route ancestors remain live.
