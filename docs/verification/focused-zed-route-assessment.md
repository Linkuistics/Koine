# What the Zed result establishes, and whether bookmarks can help

**Zed can read the original 1,500-byte-path file through its short same-object
address on the tested system. Bookmarks might recover naming information, but
we have no evidence that they give Zed both the original filename and a usable
long-file address.** The complete Koine route remains unresolved.

Antony accepted the [focused receiver report](focused-zed-receiver-prototype.md)
on 2026-10-06. That accepts the observation; it adopts no production workaround
and commissions no further experiment. This assessment consumes that report
and Antony's subsequent bookmark and cleanup questions.

Antony subsequently answered **"authorized"** on 2026-10-06 to the exact
[finite bookmark diagnostic](#finite-bookmark-diagnostic) below. It remains
unexecuted. The source/charter handoff is k157, the sole prototype is k158 and
returned design k159 retains the complete supported-route obligation under k156.

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

**Authorized on 2026-10-06; unexecuted.** Antony answered **"authorized"** to
this exact four-case local test, one guest, 15-minute cap and zero application
requests. It answers: *can an ordinary, action-local bookmark made from the verified short
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
