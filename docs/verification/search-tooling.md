# Tool-backed search mechanism

**Design evidence, not native acceptance.** This finite comparison selects macOS
system find for candidates, Foundation for literal matching and native application
services for metadata/OS-reported locations. No backend was executed and no native
acceptance subject, consent, index, mount, signing or installed application was
changed by this leaf. A disposable browser VM inspected only the visual documents.
The [contract](../specs/workspace-search.md) is conditional on focused human
process/protection, ordering and dataless choices and returned mandatory reviews.
Source claims below identify
facilities; actual signed Koine behavior remains unmeasured.

## Finite comparison

| Route | Candidates/matching | Cost and selection |
| --- | --- | --- |
| Spotlight via NSMetadataQuery or mdfind | Indexed/OS-search candidates and predicate matching | Built in, but query success/count is no index-health or completeness signal. The existing Koine probe's protected query prompted and disabled indexing still returned results. Needs an explicitly accepted indexed-domain contract; reject as current default. |
| System find + Foundation | System name traversal, file/folder/link records; existing native string comparison | Select. One OS command, no downloaded engine or tool-specific ignore/config reads. Adapter owns bounded framing/lifecycle and native metadata; it does not traverse. Child permission and root protection remain decisions. |
| FileManager directory enumerator + Foundation | Existing in-process OS enumeration, hidden/package skip options, skipDescendants and per-URL error handling | Concrete child-refusal alternative. Removes child attribution, pipes/signals/reap/orphans and allows localized errors/pruning. A blocked enumeration/metadata call holds a Koine thread without kill; long-path/error behavior and useful ordering remain unmeasured. Requires returned design/review, not adoption by refusal alone. |
| libc fts + Foundation | Existing in-process preorder traversal, per-entry type/identity/errno and pruning | Lower-level reuse alternative. FTS_NOCHDIR is required in the multithreaded server; whole-path access then inherits PATH_MAX exposure. A chdir-based walk in Koine is unsuitable. Blocking calls cannot be interrupted by killing a child. |
| rg --files + fzf filter | rg lists files; fzf filters supplied records | rg's file list does not supply ordinary directory choices. Supplementing it recreates another candidate route. No selection. |
| fd + fzf, or fzf walker/filter | Established finder/walker plus list filtering | Useful alternatives, but adds distributed executable(s), signing/version/config and matching choices without a need for fuzzy matching. The built-in route is smaller. |
| Custom in-process traversal | Own candidate order, witnesses, accounting and matcher | Rejected by the human reuse requirement; it cannot survive by being renamed an adapter. |

Primary sources checked 2026-10-08:

- Foundation's [directory enumerator](https://developer.apple.com/documentation/foundation/filemanager/enumerator(at:includingpropertiesforkeys:options:errorhandler:))
  supplies native skip options and per-URL error handling. Apple's
  [fts manual](https://github.com/apple-oss-distributions/Libc/blob/main/gen/fts.3)
  specifies preorder visitation, directory order, FTS_NOCHDIR and per-entry errors;
  [find's source](https://github.com/apple-oss-distributions/shell_cmds/blob/main/find/find.c)
  supplies no comparator unless sorting is requested. Their policy/long-path
  costs are comparison evidence, not actual Koine acceptance.

- Apple's [find manual/source](https://github.com/apple-oss-distributions/shell_cmds/blob/main/find/find.1)
  specifies physical-link handling, same-device descent, prune, type tests and
  NUL output. These are command semantics, not pre-access permission guarantees.
- Foundation's [string range API](https://developer.apple.com/documentation/foundation/nsstring/range(of:options:range:locale:))
  supplies literal comparison; the [predicate reference](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html)
  also distinguishes case/diacritic-insensitive substring operators from patterns.
  Select Foundation folding/normalization plus literal range comparison, not a
  dynamically compiled predicate or a custom comparison loop.
- [NSWorkspace application URLs](https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:))
  are per identifier, and [running applications](https://developer.apple.com/documentation/appkit/nsworkspace/runningapplications)
  provide running seeds. Neither is an exhaustive installation inventory.
- [ripgrep guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
  describes recursive filtering and the file-list mode. Its ignore/hidden/link
  policy needs explicit configuration; enumeration must not become content search.
- [fd README](https://github.com/sharkdp/fd/blob/master/README.md) describes finding
  files/directories and exclusions. It is an additional distribution dependency.
- [fzf README](https://github.com/junegunn/fzf/blob/master/README.md) and
  [manual](https://github.com/junegunn/fzf/blob/v0.74.4/man/man1/fzf.1)
  distinguish list filtering from its walker and interactive presentation. Its
  current [0.74.4 release](https://github.com/junegunn/fzf/releases/tag/v0.74.4)
  was observed for comparison; no fzf version/dependency is selected.

The [earlier discovery measurement](search-discovery.md) rejects inferring
healthy empty from Spotlight startup/count; it does not prove find safe.
[Protected metadata](protected-path-metadata.md) and
[lookup-only transit](descriptor-walk-prompt.md) retain their call/identity/OS
bounds. The [old pre-open analysis](search-preopen-boundary.md) explains why a
policy symlink's identity is not its target and why device refusal can occur
only after foreign metadata contact. No new observer, pre-open witness algorithm
or recursive proof program is selected here.

## Invocation and parsing

Proposed executable: the OS-owned /usr/bin/find, supplied by supported macOS.
Use posix_spawn with explicit executable, argv and a sanitized environment,
C locale for command diagnostics, no inherited search/config variables, fixed
working directory and stdin from /dev/null. No shell, PATH lookup, interactive
TTY, exec/delete/action predicate, user-selected command or find replacement.
Use POSIX_SPAWN_CLOEXEC_DEFAULT with explicit file actions for only descriptors
0–2; never rely on racing pipe creation and later FD_CLOEXEC marking. Set an
empty signal mask, default SIGPIPE/SIGTERM and a new owned process group using
the supported spawn attributes. No listener, store, native handle or other job's
pipe survives exec. k127 verifies the exact SDK flags/actions and failure cleanup.
Spawn availability/error checking is an internal prerequisite, not root traversal.
Record OS build and the actual executable's identity at native acceptance.

One admitted root per invocation, in the following trusted argument shape:

```
/usr/bin/find -P -x -f <literal-absolute-root>
  ( -depth 0 -type d -print0 ) -o
  ( -depth +0
    ( ( <exact-policy-path-tests> -print0 -prune ) -o
      ( -name .* -prune ) -o
      ( <known-package-suffix-tests> -print0 -prune ) -o
      ( ( -type f -o -type d -o -type l ) -print0 ) ) )
```

This is an argv/expression outline, not a shell command to interpolate. The
adapter assembles individual arguments; parentheses, fixed suffix patterns and
operators are trusted constants. Exact path operands must escape find-pattern
metacharacters, preserving root punctuation. A root's own policy is checked
before spawn. The first exact-root record is a depth-zero directory marker,
not a match or examinedEntry; its absence never establishes healthy empty.
There is no mindepth option that would suppress that proof. A file/link root,
trailing slash and replacement between qualification and spawn require k191's
explicit qualification rules; do not append a slash to force descent.
No -L/-H, -s/-d or ignore_readdir_race is selected. The single unsorted deep pass
is conditional on k196's ordering choice: a large first subtree can exhaust the
existing bounds before later shallow siblings. A bounded shallow pass before
deep search or immediate-home-child sources are concrete find-backed alternatives,
requiring returned design/review before implementation; neither is selected here.
Prune forbids descent, not earlier anchor metadata contact. Same-device checks
can contact a foreign mount first and emit its directory location. Byte-exact
policy patterns do not cover case/NFC/NFD/Data-root aliases by themselves.
Application recognition admission and a finite per-job native-call budget are
k123's prerequisite, including links whose targets supply their match names;
suffixes never establish bundle identity.

NUL is the only record separator. Spaces, tabs, newlines, quotes, backslashes
and leading punctuation in names are data. Complete records must decode losslessly
as UTF-8 absolute paths within the declared source spelling, with no repaired
bytes or Unicode normalization in output. Parent components must preserve the
literal root. Compare exact UTF-8 bytes with a component boundary, not Swift
String canonical equality/hasPrefix; handle a root's existing slash explicitly.
A mismatched record is protocol failure, not a path to inspect.
Retain at most 8,193 bytes before NUL; overlength tails are drained and counted
as omitted without retaining/fabricating a location. EOF with an unfinished record
is malformed output. Empty stdout means healthy empty only with actual normal
completion and qualified coverage; it is never sufficient alone.

The local setiopolicy_np(3) manual documents an inherited process dataless policy,
with DEFAULT resolving to OFF; [Apple TN3150](https://developer.apple.com/documentation/technotes/tn3150-getting-ready-for-data-less-files)
documents opting out and handling EDEADLK. k196 chooses process-wide OFF pinning
(which affects all Koine work) versus verified inherited policy with refusal when
unknown/enabled. No policy is changed here. Thread policy alone is no established
child setting. k191 defines effective-policy checks, unsupported/error branches
and coverage when a provider withholds a listing; a directory marker plus exit 0
cannot prove that such a listing was complete. Signed hydration controls remain
necessary for opaque services and unknown cloud aliases.

Drain both pipes concurrently, separately retaining bounded stderr. Do not parse
human stderr lines into exact paths, OS consent, errno or absence. Nonzero exit,
any stderr warning, malformed output, capture overflow or failed read/reap makes
coverage incomplete with a source REMAINDER. A localized native adapter error
can name its own candidate; a command warning cannot. Signal exit/EOF during
cleanup is cancellation, not success. A synthetic child is only a controlled
private-seam subject, never proof of system find/native permission.

Native calls use the existing resourceValues/Bundle positives,
LSCopyApplicationURLsForBundleIdentifier with outError and NSWorkspace preferred
lookup, plus generic running-application seeds. The
[earlier SDK/call analysis](search-native-resources.md#call-health-is-separate-from-descriptor-visibility)
records the deprecated error-bearing function's caveats. Its exact checked
not-found/nonmatching branches keep the selected reported-native-fact semantics;
nil/empty errorless data and unchecked/truncated targets stay UNKNOWN. The
returned metadata design must verify actual SDK availability/calls and individual
application resolution before planning, without writing a new search walker.

## Finite acceptance subjects

All subjects use the already agreed G (public GraphQL), N (actual native binary)
and V (isolated normally launched signed Koine) seams. Private command/native
outcomes enable controls inside G/N. V uses the actual OS command/metadata,
independent observers and real applications. An unavailable native subject stays
pending; none is passed by this design. Capture binaries, OS/backend versions,
configuration, granted state, result/errors, provenance and per-item digests.

| Subject | G/N controls and result | V observation/control |
| --- | --- | --- |
| Root proof and withheld listings | File/link roots with and without trailing slash; root replaced after qualification; absent/mismatched directory marker cannot be healthy empty. Marker is excluded from matches/progress/counts. Dataless failure or uncertain empty listing is affecting uncertainty. | Literal root spelling and directory identity/type independently controlled; per-human effective process/native/child policy recorded. No append-slash repair or metadata/exit-zero-only COMPLETE. |
| Exact byte identity | Overlapping NFC/NFD roots may observe one filesystem identity with distinct path bytes; file records merge only byte-equal paths. Prefix controls include a sibling sharing the root's character prefix and multibyte chunk boundaries. | Retained locations compared byte for byte with independently observed command/root spellings; app identity merging tested separately. |
| Spawn inheritance and authority | Only fds 0–2 survive exec; one child's EOF is independent of another blocked child. Empty mask/default SIGPIPE/SIGTERM, owned group and exactly-once reap; action-to-search/process-call guard mutations fail. | Signed host's selected binary boundary and fixed system child observed, no inherited listener/store/other-job pipes. Abrupt-parent broken-pipe and blocked-orphan subjects retain different limits. |
| Native recognition admission | Returned k123 candidate filter/call-budget boundary, target-named links, nested registration expansion and native late-return controls. Exhaustion is ENTRY_LIMIT, not false negative identity or automatic file-name withdrawal. | Twelve launchers/Safari/Finder and non-app/misleading-suffix/link witnesses test useful coverage. Unknown/unavailable native states remain pending, not accepted systematic loss. |
| Ordinary/empty/unavailable | Files and folders, an ordinary empty root, missing optional/explicit roots, missing/incompatible command, empty unavailable OS source, nonzero exit and warning-only exit 0. Only qualified normal empty is healthy empty; distinguish dependency and unknown coverage. | Signed GUI Koine over ordinary roots; independent fixture inventory. System command identity and TCC responsibility recorded, never agent-child proxy. |
| Literal records/matching | Chunk boundaries splitting multibyte bytes/NUL; newline/tab/quote/bracket/backslash names; malformed UTF-8, unfinished record; 256-byte query and 4096-byte root boundaries. NFC/NFD, case/diacritic, whitespace and literal wildcard/regex punctuation with Foundation controls. | Real filesystem literal names and equivalent Unicode witnesses; independent byte comparison. No repaired spelling or shell invocation. |
| Applications | Native bundle identity merging for direct/link/OS routes, two real copies sharing identifier, positive registration, exact error-bearing not-found, stale preferred, nil/empty/conflicting/truncated/errorful metadata, unknown identifier. Supplied roots suppress expansion; missing OS seeds never imply empty inventory. | Twelve configured launchers plus Safari/Finder, conventional and OS-reported locations, moved/deleted/unregistered and duplicate fixtures; checked per-copy identity and existing constrained launch/reveal receipts. Missing native registration states stay pending. |
| Prompt/hydration boundary | Direct protected root pre-spawn refusal; nested protected paths, known cloud/Trash, root-component and final links, renamed/relocated policy targets, Library escape and Data/case/NFC/NFD variants. Execute only the human-selected target-lookup/protection contract. | Fresh consent state under signed Koine; independent whole-run and late-cleanup dialog observer, positive protected-directory read/content controls in the guest. Cloud placeholder hydration observer has a separately deliberate hydration control. Ordinary search never serves as a consent probe. |
| Foreign/mount limits | Unsupported root, nested device boundary, OS-reported foreign application URL and blocked lookup. Unlocalized failures/remainders, no registration negative from refused targets. | Finite local image, removable and controlled network/unresponsive mount subjects where available. Record every probe/late cleanup, dialog and hydration outcome. Missing mounts stay pending, not substituted by a local disk image. |
| Bounded useful coverage | Limit 1/50/200, overlapping roots, 100000/100001 candidate boundary, 1000/1001 native URLs, data/diagnostic/stderr limits, per-source/total deadline, late later-root results and 1023/1024/1500/8192/8193-byte locations. Count truncation differs from unfinished coverage. No FIFO/queue arithmetic assertions. | Realistic wide/deep home and all app defaults; named shallow, same-level, deep and later-root witnesses, including the formerly starved Development shape. Record actual returns/omissions/reasons/latency per witness. k93 owns acceptance of those losses; query-specific early termination is no pass. |
| Lifecycle/serviceability | Four jobs/fifth refusal; spawn/pipe/read/wait failure; both full pipes; TERM-ignoring and blocked child; cancellation/revocation/provider-stop, late native return, one reap/slot retention, no PID reuse signals, provider restart and abrupt-parent limit. Deliberate leak/late-publication/drop-event controls fail. | Actual signed host saturated beside independent fresh listener connections, grant-store work and authorized actions, paired with no-search reference. Correlate owned spawn/pipe/kill/reap/native-call events and outcomes; resource failure/accept backoff fails even after eventual replies. Opaque internal peaks remain unproved. |
| Action/binary transport | Exact search-required composition and retained action-only profiles, independent old/new binaries, errors/aliases/BLOCKED/revocation, 1.0.1 provenance and full candidate pins. | Actual search results passed unchanged to existing launch/default/Zed open/reveal with both controls; client clipboard/MRU local. Long extant locations fail under the accepted action limit, missing remain missing. Independent action fixtures are no search provenance. |

The dialog/hydration controls must demonstrate the observer detects an event.
anchor/mount metadata contact before prune and case/Unicode/Data aliases are
included, not certified safe by local protected-folder lstat. Dataless settings
and their failure/withheld-listing branches need explicit controls. The selected
scan continues after limit+1; test both truncation and independently unfinished
coverage, with client cancellation while all four slots remain occupied.
Quiet screens alone do not pass. Native opaque resource peaks are unproved,
under the retained empirical evidence boundary. The new finite owned-event/
independent-outcome subjects replace custom transient-walk/queue instruments;
they preserve meaningful serviceability evidence without an open-ended filesystem
or formal-model program. No measurements or new implementation leaves are cut here.
