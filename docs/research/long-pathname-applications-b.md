# Long pathnames in real applications — independent survey B

Real applications use several mechanisms, with different scopes. GNU tar keeps
parent directory descriptors while recording full archive names; restic fixes
Windows path handling at both data and metadata calls; CMake shortens names it
owns; Zed transfers document strings through a cooperating IPC channel. These
are useful positive leads. None of the bounded evidence below establishes all
of Koine's retained macOS classification, exact registered-copy selection,
default/Zed opening, Finder reveal and receipt requirements.

This survey does not select a route or recommend dropping the requirement.
Its strongest lesson is to follow the name through **every operation and
receiver**, including restoration, metadata and diagnostic paths. A name can
survive one representation and fail at the next consumer.

## Scope, provenance and evidence levels

Researched 2026-10-04 for `long-pathname-applications-k139`. The commission
requires roughly 1,500-byte ordinary-file default/Zed opening and Finder reveal,
and constrained long-app launch/named opening for the exact selected registered
copy. Supplied locations, native facts/cause provenance, truthful receipts and
short-workflow regressions remain required. The
[route evaluation](../verification/long-action-route.md),
[prototype](../verification/long-action-route-prototype.md) and
[reviewed boundary](../verification/long-action-native-boundary.md) provide the
local context. Their diagnostic long submissions bypassed missing prerequisites;
they are not passing action rows. No new native probe ran for this survey.

The ancestor briefs, glossary and cited authority/selection ADRs were read.
The older [representation survey](prior-art-long-paths-a.md) supplied leads
only. The paired application survey A was **not read**. This is independent
breadth research, not an adversarial review or synthesis. No reviewer was spawned.
The codebase-memory CLI refused startup because an unverified/pre-coordination
generation was active; no graph project, generation or coverage verdict is
claimed. Local work was bounded document reading, not discovery of Koine code.

Evidence labels used below:

- **D — documented:** an official promise or described behavior, bounded by the
  product/version/configuration stated there.
- **S — source:** a branch read in pinned implementation source. Its execution
  consequence is an inference unless paired with a test/report.
- **T — upstream test:** assertions in the pinned test, not a test run here and
  not a guarantee for every platform.
- **R — reported observation:** a primary issue author's reproduction or follow-up,
  retaining its environment and uncertainty.
- **Gap:** no primary evidence found in the stated bounded search/read.

The corpus is deliberately finite. It covers desktop/document consumers,
build tools, archive/copy/backup and remote/virtual namespaces, with macOS,
Linux/POSIX and Windows contrasts. It does not catalogue every product.

| System and pinned basis | Use case | Positive mechanism | Evidenced boundary or gap |
| --- | --- | --- | --- |
| Zed 1.22.0, commit `76659a55a8c10ed355a070f8764a0b1733e3c115` (2026-09-30) | Editor and CLI/document handoff | Small launch URL followed by IPC carrying document strings | Receiver still canonicalizes/reads full paths; no sourced macOS ≥1,024-byte document success |
| CotEditor 5.0.0, commit `75df7fc4c7fe472c28880915e2dac351a9dde3f9` | macOS document browser/restoration | Per-document security-scoped bookmarks | Resolves to URLs, filters reachability, then reads URL/path; long success unestablished |
| Nautilus 48.0 / GLib 2.84.0 | Linux file manager, local/virtual launch | GFile objects, URI launch, D-Bus or argv | Local backend reconstructs full paths; virtual-to-FUSE handoff can reintroduce lookup limits |
| CMake 3.31.6 / Ninja 1.13.1 | Build graph, generated files and compiler handoff | Hash shortening of owned outputs; response files; conditional Windows long stat | Source/depfile/compiler paths and process limits remain independent |
| GNU tar 1.35 | Archive creation, listing and extraction | Parent-relative recursive reads; GNU/pax long-name records | Extraction uses growing relative names; archive format acceptance is not restore proof |
| restic 0.17.1, with 0.17.0 regression evidence | Backup/restore and virtual repository tree | Windows extended prefixes across data/metadata; hierarchical tree blobs | Actual metadata regression; POSIX backend still receives full strings |
| Robocopy, current Microsoft command reference | Windows local/share copying | Documented support above 256 characters unless `/256` | Closed implementation; exact ceiling/units not specified by command reference |
| OpenSSH Portable 10.0p1 | SFTP process/protocol transfer | Path strings to OPEN, then opaque retained file handles | Server OPEN remains whole-path; READDIR/REALPATH reconstruct into PATH_MAX buffers |

### What “over-limit” means here

A 1,500-byte path is above the tested macOS whole-path boundary but below Linux's
ordinary 4,096-byte lookup buffer. Calling a Linux 1,500-byte success a solution
to macOS's limit would compare different conditions. Linux 6.14 defines
`PATH_MAX` as 4096 including NUL; `getname_flags` returns ENAMETOOLONG when its
bounded copy has not found a terminator. That is one kernel pathname-copy
boundary, not a maximum depth of a component-created tree. **S.**
[Linux limits][L1], [kernel copy branch][L2].

The local Koine evidence states macOS PATH_MAX as **1024 bytes including NUL**:
1,023-byte witness delivery passed, 1,024 failed for the tested submission.
Symlink expansion and redundant dot/separator spelling make source length,
resolved length and submitted length different measurements.
[Measured subjects and limitations](../verification/long-action-route-prototype.md#what-was-measured).

Windows distinguishes the conventional MAX_PATH buffer (260, including terminal
NUL) from extended Unicode paths, with an approximate 32,767-character ceiling
and independently limited components. The namespace prefix may expand; this
is not a promise that exactly 32,767 visible characters work. Windows Unicode
interfaces use UTF-16, so supplementary characters occupy two code units.
Extended `\\?\` paths require absolute spelling and do not perform ordinary
slash/dot normalization; opt-in behavior depends on the particular API,
manifest and OS setting. Filesystem and shell behavior can differ. **D.**
[Microsoft's path-limit contract][W1].

In source, `strlen`/C++ `std::string::size()` count bytes excluding NUL. Go
strings likewise count bytes; a conversion to UTF-16 changes the measurement.
A URI spelling can grow through percent encoding. An argv/protocol message limit
is separate from a filesystem lookup limit. These distinctions are applied
below rather than assuming that a larger allocation establishes support.

## 1. Zed: a cooperating handoff that avoids one opener payload

**Normal trace.** `zed file.txt` parses paths into absolute strings. The
`parse_path_with_position` routine tries whole-path canonicalization; on error,
it walks toward an existing ancestor, stores trailing components and appends
them again. `CliRequest::Open.paths` is `Vec<String>`: multiple complete document
paths, **not components of one pathname**. On macOS, bundle detection itself
canonicalizes the app location and reads `Contents/Info.plist`. The launch branch
passes a `zed-cli://<server-name>` URL with an application URL to
`LSOpenFromURLSpec`; after a handshake the document strings travel through IPC.
Thus the document path need not be in that particular Launch Services payload.
**S.** [CLI ingress and macOS launcher][Z1], [wire types][Z2].

**Receiver trace.** The editor receives `CliRequest::Open`, derives positioned
paths, calls `open_workspaces`/`open_local_workspace` and opens items. It tries
canonicalization again; the real FS backend uses whole-path
`std::fs::canonicalize`, metadata and `read_to_string`/`read`. A successfully
serialized long path therefore encounters another pathname lookup in the GUI
process. Failed canonicalization can leave the original path in place; that is
not proof of successful reading. The CLI can receive error text and an exit
status after workspace/item opening, which is stronger than merely starting a
process, but is not Koine's executable-identity receipt. **S.**
[Receiving branches][Z3], [real filesystem backend][Z4].

The receiver also resolves configured open behavior and can prompt on first run;
that UI/setup behavior cannot be assumed equivalent to Koine's existing controls.
[Open-behavior resolution][Z3].

**Over-limit behavior.** The fallback can construct a string when the first
canonicalization fails. It neither proves the target exists nor changes the
receiver's whole-path access. It also resolves an ancestor then appends children;
that is not a byte-preserving resolver for every symlink/dot spelling. **Inference
from Z1/Z3/Z4.** No primary test/report found here establishes local macOS
≥1,024-byte content opening by this route. On Linux, roughly 1,500 bytes need
not exceed the lookup limit; ≥4,096 bytes is the distinct question.

There is also an independent *IPC endpoint* limit. A Zed remote-development user
reported a 118-byte Linux socket pathname, handshake timeout, and successful
connection after selecting a shorter data directory. This is a report for Zed
1.4.4, not a finding that document names are limited to 107 bytes, and not a
verified current-version diagnosis. It shows a derived helper path can fail
before documents arrive. **R.** [Remote socket report #59142][Z5].

**Limits and walk-away.** The examined macOS launcher still needs an inspectable
app bundle, uses its own launch flags and can reach an existing editor instance.
The CLI also turns stdin/anonymous-fd inputs into temporary files: that is an
alternate-content workflow, excluded as a repair here. Ordinary source files
remain legible with Zed uninstalled; the transient IPC session disappears.
[Launcher/input source][Z1].

**Koine lead and gap.** The official CLI supports `--zed /path/to/Zed.app`.
That makes exact-copy targeting worth understanding, but this survey has not
proved registered-copy equality, running-copy behavior, native payload gates,
unchanged spelling, acknowledgment timing or receipt identity through the CLI.
It supplies no default-handler/Finder route. Do not adopt its legacy launch call
or CLI semantics as a replacement merely because documents use IPC.
[CLI reference][Z6].

## 2. CotEditor: bookmarks restore access, then URLs return

**Normal trace.** In CotEditor 5.0.0, a directory document uses `FileNode(at: URL)`;
the node obtains directory/writable/alias/hidden resource values and lists
children with `FileManager.contentsOfDirectory(at:includingPropertiesForKeys:)`.
Each child is represented by another URL-bearing node. A document read obtains
`Data(contentsOf: url)` and file attributes through `url.path`. **S.**
[Browser nodes][C1], [document read][C2].

**Persistence/handoff.** Restorable state records one security-scoped bookmark
for each open document URL. Restoration resolves each bookmark to a URL, filters
for ancestry/reachability, then reopens the document. Bookmark creation and
resolution use `try?`/`compactMap`, so failed entries are left out of that restored
list. The stale flag is acquired in the inspected resolution closure; that
closure does not itself refresh the bookmark. This is persisted application
state, not a file descriptor submitted to an arbitrary opener. **S.**
[Directory restoration][C3].

**Over-limit trace and limits.** No inspected test or primary report establishes
bookmark creation/resolution or successful document reading at a ≥1,024-byte
macOS location. A long URL can be represented; resource acquisition, bookmark
creation, reachability, document read and attributes are separate consumers.
The code identifies where a failed acquisition can disappear from restoration,
but attributing such a failure to length is an **unmeasured inference**, not an
observed CotEditor bug. A tree of `FileNode`s likewise does not show
component-relative I/O. [Node operations][C1], [restoration][C3], [read][C2].

Apple documents that resolving security-scoped bookmarks yields URLs carrying
sandbox access; this is an authority/persistence mechanism, not a published
long-path opener guarantee. **D.** [Bookmark creation contract][A1].

**Walk-away and Koine.** Original text files remain ordinary files without
CotEditor. Its opaque restoration blobs require compatible bookmark resolution;
they are not a readable substitute for source locations. Security-scoped access
needs an explicitly different consent/setup decision before any Koine adoption.
Even an ordinary bookmark lead would still need supported long creation,
resolution, native facts and final original-location delivery. CotEditor supplies
an actual bookmark workflow, not proof that bookmarks repair the tested opener.

## 3. Nautilus/GIO: objects and URIs with full-path local consumers

**Normal trace.** Nautilus 48.0 collects activation URIs, creates GFiles, and
chooses `g_app_info_launch` for an all-local list or `g_app_info_launch_uris` when
any item is non-local. GLib 2.84.0's local GFile stores one dynamically allocated
canonicalized `char *filename`. Listing opens that filename; child metadata
joins parent and entry with `g_build_filename`. Reading calls `g_open` on the
stored filename and obtains type information from the resulting fd. **S.**
[Nautilus selection/launch][G1], [local backend][G2], [enumerator][G3].

**External boundary.** GDesktopAppInfo supports a D-Bus `Open` message with URI
strings or a spawned program. Desktop Exec `%f/%F` expands to quoted local
path strings; `%u/%U` can also become a POSIX FUSE location when available unless
that conversion is disabled. A remote URI can therefore become a local pathname
for a non-GIO application. D-Bus avoids argv for that branch but does not change
the receiver's I/O implementation. **S.** [Launch/expansion implementation][G4].

**Over-limit trace.** Dynamic allocation permits GFile/URI representation without
proving traversal. The local listing reconstructs full child paths; the open
branch submits a full path. A deep tree above the receiving kernel's lookup
limit is therefore still a problem at those calls. Listing metadata can use
information from directory entries for some requested attributes; it is not
correct to claim every displayed child always required a successful full stat.
Missing-file races are skipped; other acquisition errors follow the enumerator's
error branch. **S and inference.** [Enumerator branches][G3], [local read][G2].

**Identity, limits and walk-away.** GFile identity/spelling and a desktop launcher
are not retained OS handles to the selected object. A pathname may acquire a new
occupant between listing and opening. The inspected backend's lexical
canonicalization is not evidence of equivalent original symlink/dot/trailing
semantics. A list of GFiles is multiple resources, not component arrays for one
resource. Ordinary files and `.desktop` text remain legible without Nautilus;
remote access and virtual mounts require an appropriate implementation/service.
[Local construction][G2], [desktop expansion][G4].

**Gap and applicability.** No specific long-path Nautilus-to-third-party editor
success test was found in this bounded read. GLib supports a useful abstraction
boundary but still has distinct local and remote consumers. A FUSE location is
a mapped namespace, not an unchanged Koine submission location; adopting it
requires a new human decision and does not prove Finder or Launch Services
integration.

For the spawned branch, Linux 6.14 independently bounds each argument string at
32 pages (128 KiB with 4-KiB pages), counting its NUL in the user-string check;
aggregate arguments/environment have another budget. D-Bus avoids that argv
boundary but does not raise the recipient's filesystem lookup limit. **S.**
[Linux exec string check][L3], [per-string constant][L4].

## 4. CMake and Ninja: own the output name; cooperate with the compiler

**CMake normal/long trace.** CMake computes object names from source paths,
normalizes characters in the generated output name and keeps a source-to-object
mapping. When the output's full length would exceed `CMAKE_OBJECT_PATH_MAX`, it
can replace an initial directory portion with a 32-character MD5 string. This
changes a generated object name that CMake owns; it does not rename the input
source. If the build-directory prefix leaves insufficient room or no suitable
portion can be replaced, the source emits a warning that the object cannot be
safely placed and the build may fail. **D/S.**
[Variable contract][B1], [3.31.6 mapping/shortening code][B2].

The implementation compares `std::string` sizes, excluding NUL. Its warning
says “characters,” but that is not a demonstrated UTF-16 measurement. Hashing
shrinks an output pathname; source lookup, depfiles and compiler input remain
separate questions. Compiler delivery is not proved by the existence of the
mapping. [Length arithmetic][B2].

**Ninja normal trace.** Ninja reads build paths as strings, canonicalizes path
syntax, stats inputs/outputs and prepares output/depfile directories. A rule
can supply `rspfile` and `rspfile_content`; Ninja writes that file before starting
the command. The receiving compiler must understand the response-file convention
and still open the individual names within it. Response files reduce aggregate
command length, not a single over-limit filesystem argument. **S.**
[Build/response-file code][B3], [path normalization][B4].

**Actual Windows boundary.** Ninja 1.13.1 queries long-path configuration through
`RtlAreLongPathsEnabled`; without it, its Stat guard rejects certain non-prefixed
paths above MAX_PATH. The branch compares string bytes and excludes NUL, so do
not treat that check as Microsoft's exact Unicode contract. The implementation
uses ANSI Windows calls including `GetFileAttributesExA`; success in one stat
branch does not prove every other operation. Its Windows upstream test creates
an extended-prefixed file and stats prefixed or ordinary spelling depending on
the configuration. That is evidence for a *stat test*, not a build or arbitrary
component length. **S/T.** [Disk operations][B5], [test][B6].

An issue reports actual `GetFullPathNameA` failure in a generated V8 path and asks
about ANSI-to-Unicode migration; another describes 1.11.0-era long-path failures.
These are historical reports, not a claim that those reproductions fail in
1.13.1. **R.** [#2359][B7], [#2266][B8].

**Process/consumer.** Windows Ninja starts the command with `CreateProcessA`
and deliberately avoids inserting `cmd /c`, whose command-length ceiling would
be another bottleneck. Its source reports process errors separately from file
stat errors. It neither passes directory descriptors to compilers nor forces
them to support all names a build graph can store. On POSIX the examined stat
branch calls whole-path `stat`/`stat64`. **S.** [Process creation][B9], [stat][B5].

Microsoft documents a 32,767-character command-line maximum including NUL, but
also limits the executable token to MAX_PATH when `lpApplicationName` is NULL;
that is the form this Ninja branch uses. The ANSI call should not be treated as
a Unicode path solution. Response files leave that executable boundary in place.
**D/S.** [CreateProcess contract][W2], [Ninja call][B9].

**Walk-away and Koine.** CMake-generated build instructions and Ninja manifests
remain readable text; objects remain ordinary files, though hashed names need
the build rules to explain their source mapping. Reproduction still needs a
build engine/compiler. Koine can learn to audit every derived path and receiver;
it cannot borrow hash shortening for caller-selected documents/apps under the
current requirement. Neither response files nor platform opt-in is a macOS
opener protocol. No complete Linux/macOS above-PATH_MAX compiler build was found
in this bounded corpus.

## 5. GNU tar: recursive reads can outlive a full lookup; restore differs

**Source provenance.** Read the official
[GNU tar 1.35 release source archive][T0], SHA-256
`4d62ff37342ec7aed748535323930c7cf94acf71c3591882b26a7ea50f3edc16`.
The exact files/functions below identify the evidence even if the project's
web source viewer is unavailable. That web viewer could not be fetched; release
source was downloaded and read, not built or executed. The digest is verified
in the source-provenance note below.

**Normal and deep-tree creation.** In `src/create.c`, `dump_dir0` keeps the full
archive/display name in `name_buf` but calls `dump_file(parent, entry, fullname)`.
`dump_file0` uses `fstatat(parentfd, name, ...)`; `subfile_open` opens relative to
the directory fd; directory streams derive from fds. Thus a short ingress root
can be walked into a tree whose displayed full name exceeds a whole-path lookup
limit, without submitting that accumulated name at each read. A directly supplied
over-limit top-level operand still has an ingress problem. This is **S/inference**,
not an above-PATH_MAX tar run. [Release `src/create.c`, functions named above][T0].

**Descriptor limits/races.** The same source releases ancestor fds under resource
pressure and attempts restoration through `openat(childfd, "..")`, comparing
saved device/inode. A fallback reopens the original accumulated ancestor name;
that fallback can move the full-path limit back into traversal. File-change
checks are explicitly heuristic. Tar therefore provides a real descriptor-based
application pattern, not unlimited depth, race-free input or Koine-equivalent
policy/classification. [Release `src/create.c`, `restore_parent_fd` and final
`dump_file0` checks][T0].

**Archive transport.** Archive formats have their own limits. V7 rejects names
above 99 bytes in the examined writer; ustar requires a suitable name/prefix
split. GNU uses a long-name record including a terminal NUL; pax carries a `path`
extended header. Those records transmit names/data to another tar implementation,
not an OS document opener. The upstream `tests/long01.at` exercises a
512-byte GNU name payload including its NUL (511 bytes of pathname text), a
historical record-boundary regression; `tests/longv7.at` asserts refusal of the
long member. Neither is an above-kernel-limit test. **S/T.**
[Release `src/create.c`, `write_gnu_long_link`/`write_long_name`, and named tests][T0].

**Extraction/consumer.** `src/misc.c:chdir_do` retains a base fd for `-C`; it does
not literally change cwd at that point. `src/extract.c` still supplies a member's
relative `file_name` to `openat(chdir_fd, ...)`, and missing-parent creation calls
`mkdirat` on growing prefixes. A short extraction base plus an over-limit member
can fail: a dirfd alone does not split that multi-component argument. A large
archive record can therefore be listed yet fail materialization. **S/inference.**
[Release `src/misc.c` and `src/extract.c`][T0].

**Names and walk-away.** Tar can transform archive names and remove leading
slashes, and extraction treats links and parent traversal specially; those are
intentional archive semantics, not a preserved original submission spelling.
Ordinary input files survive uninstallation. GNU/pax archives remain usable by
compatible readers, while a recipient supporting only an older format need not
understand their long names. Reading the archive bytes is not the same as
recovering all original paths on the destination filesystem.

**Koine lead and gap.** Separate full display/provenance text from the short name
used with a verified parent descriptor. That is supported implementation prior
art for owned local traversal. It supplies neither native macOS application/type
facts nor an arbitrary external opener handoff. The examined release has no
above-PATH_MAX creation/extraction result used here; follow all descriptor
recovery and restore branches before claiming transferable success.

## 6. restic: Windows data success was not metadata success

**Normal trace.** The archiver joins parent/name strings for each child,
performs Lstat, opens regular files with no-follow intent and fstats the opened
file to check its type again. The local backend delegates to `os.Open`,
`os.OpenFile`, Stat and Lstat after `fixpath`. On Windows 0.17.1, `fixpath` converts
to absolute spelling and adds `\\?\` or `\\?\UNC\`, preserving an existing
extended prefix. On Unix it returns the supplied string. This is still a
whole-path OS call, not a POSIX descriptor walk. **S.**
[Archiver][R1], [local FS][R2], [Windows conversion][R3], [Unix conversion][R4].

**Observed over-limit failure and repair.** A Windows Server 2012 R2 user reported
that 0.17.0, built with Go 1.22.5, omitted ten previously backed-up files when
named-security metadata access failed. The reproduction used VSS; its summary
and snapshot comparison disagreed about which files remained. The diagnosis
in the issue is the user's inference; the repair is more concrete. PR #4954
applies `fixpath` to security-descriptor and other path operations. The same
reporter confirmed successful backup and reappearance of the ten files after
the patch. **R/S.** [Regression #4953][R5], [patch #4954][R6],
[successful follow-up][R7], [0.17.1 security calls][R8].

The release separately changed behavior when extended metadata is incomplete:
include the item with an explicit warning rather than omit it. That policy is
not permission for Koine to invent native facts or systematic null receipts.
**D.** [0.17.1 changelog][R9].

**Test and units.** `TestRestorerLongPath` constructs twenty 20-character ASCII
directory names, backs up, restores and verifies. Separators add another twenty
bytes to the temporary-root prefix, so the test exceeds Windows's traditional
whole-path threshold while keeping each component short. Those components add
420 bytes; exceeding macOS 1,024 or Linux 4,096 would depend on the temporary-root
prefix and is not established by this test design. The patch author explicitly noted
difficulty making the test fail before the repair; the manual reproduction is
therefore independent evidence that the test alone lacks. **T/R.**
[Pinned restore test][R10], [PR note][R6].

**Virtual representation and restore boundary.** Repository nodes store local
names, metadata, content IDs and subtree IDs. The full live `Path` is not a JSON
field. Tree blobs form a hierarchy, allowing repository representation without
one native pathname per stored object. During restoration the restorer validates
child names and joins them to the target directory string; local materialization
returns to filesystem limits. An object-store key is a repository object ID,
not the original file's native identity or a document path for Finder. **S.**
[Node model][R11], [tree loading][R12], [restore reconstruction][R13].

**Walk-away, limits and Koine.** Source files remain ordinary files; the encrypted,
content-addressed repository needs its keys and a compatible restic-format reader
to recover names/content. It is not directly legible as an ordinary folder tree
with restic uninstalled. Windows prefix support does not lift Unix lookup limits,
component limits or arbitrary receiver restrictions. The useful lesson is to
repair/audit metadata and restoration consumers along with data reads. No source
here establishes restic success on an over-1,024-byte macOS live tree, nor an
unchanged-location desktop opening route.
[Repository format and encryption][R14].

## 7. Robocopy: documented long-copy support with a closed implementation

**Normal/documented long trace.** Robocopy receives source/destination directory
strings plus file patterns, recursively copies according to its options and
can copy to a network share. Its command reference says `/256` disables support
for paths above 256 characters; hence supporting such paths is documented
behavior when that option is absent. It offers full-path logging, data/attribute/
timestamp copying and selectable security metadata; reparse/link behavior depends
on options. The consumer is the destination filesystem/share, not a document
application. **D.** [Microsoft command reference][RC1].

**Evidence limit.** Public source was unavailable in this bounded search. The
reference does not specify the internal path representation, traversal APIs,
retained handles, exact full-string reconstruction points or a Robocopy maximum
including/excluding NUL. Its “256 characters” must not be silently replaced with
Win32's 260-buffer or approximate extended UTF-16 maximum. The general Windows
API contract supplies context, not proof of Robocopy's entire call chain.
[Command reference][RC1], [Windows context][W1].

No new copy test ran. No primary over-limit failure/recovery trace was found
here beyond the documented disable option. The missing implementation is a
recorded limitation rather than an invented dirfd/prefix mechanism. Walk-away:
copied files/directories remain ordinary files; a share still needs its server.
Koine can borrow the distinction between copying and launching, and the need for
per-operation metadata accounting. A second copy or mapped/shortened path remains
excluded as a repair for the retained opening requirement.

## 8. OpenSSH SFTP: handles after OPEN; full paths before it

**Normal trace.** Portable OpenSSH 10.0p1's interactive client keeps a remote
working-directory string. Its `sftp_make_absolute`/path-append calls reconstruct
full remote paths for operations, even after a user `cd`. Client packets encode
pathname strings; the server decodes OPEN into a C string and calls
`open(name, flags, mode)`. Successful OPEN returns an opaque handle backed by a
server fd; subsequent read/write/fstat operations address that handle. READDIR
similarly uses a retained DIR stream. **S.**
[Interactive path construction][S1], [client packets][S2], [server OPEN/handles][S3].

**What cooperating transfer solves.** The filename crosses SSH independently of
the client's local lookup rules. Once opened, file reads do not need another
whole-path lookup. A remote Linux server can process names above the client's
macOS 1,024-byte limit when they fit its own limits; that is an inference from
the separated client/server consumers, not an observed transfer here. It says
nothing about materializing the same name on the client. Packet capacity is
also separate: this implementation sets `SFTP_MAX_MSG_LENGTH` to 256 × 1024
bytes for the entire message, with operation fields consuming part of that
space. It is not an allowed pathname length. **S.** [Message limit][S4].

**Over-limit receiver branches.** Server OPEN still supplies one pathname to the
kernel. REALPATH uses a PATH_MAX destination. More revealingly, READDIR combines
the saved directory name and entry into `char pathname[PATH_MAX]` using
`snprintf`, then lstats that result. It does not check the formatting return for
truncation in this branch. Failed lstat skips the entry; a truncated spelling
that happens to name another item could produce wrong metadata. This is a
**source-derived failure possibility**, not a measured OpenSSH omission or
security finding. A retained directory stream did not eliminate the reconstructed
metadata path. [Server REALPATH/READDIR][S3].

`errno_to_portable` maps ENAMETOOLONG to `SSH2_FX_BAD_MESSAGE`, and ELOOP to
`SSH2_FX_NO_SUCH_FILE`. Protocol status is therefore not the exact underlying
cause taxonomy Koine requires. Symlink following belongs to each server OS
operation; a remote `cd` in the client is not a traversal handle passed with
future child names. [Server mapping][S3], [client construction][S1].

**Walk-away and gaps.** Files remain ordinary files on server/client without the
OpenSSH utilities. The transient session handle is meaningful only to that
server session; it is not persistent identity or an arbitrary opener argument.
No over-PATH_MAX server success was established in this read; Windows OpenSSH
uses a different port/runtime not inspected here. SFTP is useful evidence for
cooperating handle transfer and the danger of metadata reconstruction, not a
macOS default-handler/Finder or registered-app launch solution.

## Mechanism comparison for the retained Koine requirement

| Mechanism in a real workflow | Limit removed or moved | Remaining consumer | Koine applicability under current mandate |
| --- | --- | --- | --- |
| Full text plus short name and parent fd (GNU tar creation) | Avoids repeatedly submitting the accumulated path in owned traversal | Initial root, descriptor recovery, metadata adjuncts, extraction and external consumer | Promising for local resolution/provenance; no native-classification or opener proof |
| Whole strings in cooperating IPC (Zed CLI) | Removes document path from one launch payload; avoids using process argv for the transferred list | GUI canonicalization/read; app detection, IPC endpoint, launch flags and receipt | Supported lead for bounded named-Zed design questions; no complete route selected |
| Opaque handle after pathname OPEN (SFTP) | Removes repeated name resolution for subsequent file I/O | Initial OPEN and reconstructed directory metadata | Useful private/helper pattern; no arbitrary third-party protocol established |
| Security-scoped bookmarks (CotEditor) | Persists access/restoration information | Bookmark creation, URL resolution, reachability and final read | Observed application usage; long support unknown; new consent/setup needs human decision |
| URI/GFile and D-Bus, with possible FUSE mapping (Nautilus/GIO) | Separates namespaces/transport from local argv | Backend and recipient; mapping can reintroduce whole paths | Useful abstraction lesson; mapped submission needs a new decision |
| Windows extended path spelling (restic) | Repairs selected Win32 consumers beyond conventional full-path boundary | Every data/metadata call, component rules and destination/receiver | Concrete cross-platform success; no corresponding macOS opener guarantee |
| Hash shortening of generated names (CMake) | Reduces outputs the producer controls | Source names, compiler and unshortenable base directory | Valid build solution; shortening selected Koine locations is excluded |
| Response files (Ninja) | Reduces aggregate process command length | Response-file lookup and each name read by compiler | Cooperating tool convention, not a single-path or Finder repair |
| Long-name archive/repository representation (tar/restic) | Moves names into GNU/pax records or tree objects | Compatible reader and destination materialization | Valuable storage pattern; copying/restoring is not the required original-item action |

An array can mean *many complete paths* (Zed CLI), *children in a tree* (restic)
or resolver working state (Zed's fallback). None of those findings establishes
an arbitrary macOS opener accepting components for one over-limit location.
Equally, this finite corpus is not proof that no such interface or successful
application exists.

The limits are operation-specific. A descriptor pins an opened object but not
its unchanged spelling; ancestor reopening, link following and path-based
metadata can introduce races again. Neither a repository content ID, a bookmark,
a GFile nor an IPC success status establishes the selected registered native
application identity or live executable receipt required by Koine.

## Supported leads and bounded questions for synthesis/design

1. **Named Zed handoff:** does the documented CLI's cooperating transfer offer a
   supported path through *all* real receiver operations for the retained long
   subject, exact registered copy and original spelling? The source already
   identifies full-path canonicalization/load and distinct app-location lookup.
   Examine those boundaries before proposing any experiment. CLI exit/window
   behavior is not automatically Koine acknowledgment/receipt semantics.
2. **Owned component-relative resolution:** GNU tar gives a concrete application
   example that separates accumulated text from the lookup operand, including
   descriptor-pressure recovery. Can a proposed Koine resolver preserve its own
   symlink/dot/trailing and native cause contract without full-path fallback?
   This question does not waive the unresolved classification/opener consumers.
3. **Metadata and receipts:** restic's repaired regression demonstrates why
   data-open evidence cannot cover named security metadata. Require supported
   acquisition evidence per Koine fact/receipt consumer rather than assigning
   false/nil when another stage fails.
4. **Platform-relative success:** distinguish above-Windows-legacy support,
   above-archive-field support and above-macOS/Linux lookup support. Reconcile
   the units and full receiver chain before treating two “long path” reports
   as corroboration.

These are questions for the already-authorized synthesis and returned design,
not authorization for a new native run or further task chain. No shortening,
alternate copy, identity-spelled submission, private entitlement/policy, new
consent, guessed native metadata or systematic length-caused null receipt is
adopted. Excluded mechanisms require a new human decision. Independent action
fixtures, later actual-search G/N/V provenance, short regressions and the final
mandatory design review remain required.

## Search silences and boundaries

- **Finder/default macOS handler above PATH_MAX:** searched Apple developer
  material for long path/bookmark/Finder/1024 terms. No primary end-to-end
  success evidence located here. The existing single-build Koine diagnostics
  remain bounded negative evidence for their tested calls, not a universal
  theorem. Finder source is not in the available corpus.
- **Bookmarks as a long-path solution:** CotEditor establishes real application
  use and reconstruction, but no above-limit creation/resolution/read test.
  Searches for CotEditor, MacVim and iTerm2 bookmark terms did not supply that
  missing length evidence. No direct persistent-ID opener success is claimed.
- **Other macOS editors:** the bounded BBEdit documentation/release-note search
  found file/remote editing descriptions, not a measured ≥1,024-byte local
  operation chain. No behavior is inferred from product advertising.
- **Nautilus launch receiver:** the inspected manager/library path proves URI/
  argv construction, not an arbitrary installed editor's over-limit success.
- **Robocopy:** source/traversal/precise ceiling unavailable; documented long
  copying is retained as a positive promise with its implementation gaps.
- **GNU tar:** web source viewer unavailable; official release source recovered.
  Examined long-name tests cover archive-record/format limits, not above-PATH_MAX
  live-tree restoration. No native result was manufactured from source shape.
- **POSIX restic and SFTP:** no sourced over-PATH_MAX live-tree success in this
  bounded corpus. The precise reconstructed calls are stronger evidence than
  extrapolation from a repository's capacity or a protocol packet size.
- **Currency:** pinned releases are examples of actual implementations, not
  assertions about every later version. Historical issue reports remain
  historical. Zed's inspected stable commit postdates the older socket report;
  that report is not proof the same failure survives in 1.22.0.

## Source-provenance note

Primary source files were downloaded to session scratch and read; no downloaded
application, test or probe executed. GitHub sources are pinned to release tags
or immutable commits, with function names and line anchors for material branches.
Microsoft and Apple pages are live documentation as accessed 2026-10-04, not
pinned promises about the prototype's guest. Maintainer patches, upstream tests
and reporter follow-ups are explicitly distinguished above. Local document
checks validate links/structure, not external source correctness or a native route.

The recorded release archive digest is the digest of the actual downloaded
`tar-1.35.tar.xz`, not an asserted vendor signature. The release contains the
cited source/tests; the archive was never built. No scratch artifact is needed
to understand this survey: cited public sources and file/function locators
carry its evidence.

[Z1]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/cli/src/main.rs#L159
[Z2]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/cli/src/cli.rs#L56
[Z3]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/zed/src/zed/open_listener.rs#L585
[Z4]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs#L954
[Z5]: https://github.com/zed-industries/zed/issues/59142
[Z6]: https://zed.dev/docs/reference/cli
[C1]: https://github.com/coteditor/CotEditor/blob/75df7fc4c7fe472c28880915e2dac351a9dde3f9/CotEditor/Sources/Document/FileNode.swift#L72
[C2]: https://github.com/coteditor/CotEditor/blob/75df7fc4c7fe472c28880915e2dac351a9dde3f9/CotEditor/Sources/Document/Document.swift#L362
[C3]: https://github.com/coteditor/CotEditor/blob/75df7fc4c7fe472c28880915e2dac351a9dde3f9/CotEditor/Sources/Document/DirectoryDocument.swift#L66
[A1]: https://developer.apple.com/documentation/foundation/nsurl/bookmarkdata(options:includingresourcevaluesforkeys:relativeto:)
[G1]: https://github.com/GNOME/nautilus/blob/48.0/src/nautilus-program-choosing.c#L147
[G2]: https://github.com/GNOME/glib/blob/2.84.0/gio/glocalfile.c#L229
[G3]: https://github.com/GNOME/glib/blob/2.84.0/gio/glocalfileenumerator.c#L367
[G4]: https://github.com/GNOME/glib/blob/2.84.0/gio/gdesktopappinfo.c#L2450
[B1]: https://cmake.org/cmake/help/v3.31/variable/CMAKE_OBJECT_PATH_MAX.html
[B2]: https://github.com/Kitware/CMake/blob/v3.31.6/Source/cmLocalGenerator.cxx#L3902
[B3]: https://github.com/ninja-build/ninja/blob/v1.13.1/src/build.cc#L852
[B4]: https://github.com/ninja-build/ninja/blob/v1.13.1/src/util.cc#L141
[B5]: https://github.com/ninja-build/ninja/blob/v1.13.1/src/disk_interface.cc#L161
[B6]: https://github.com/ninja-build/ninja/blob/v1.13.1/src/disk_interface_test.cc#L102
[B7]: https://github.com/ninja-build/ninja/issues/2359
[B8]: https://github.com/ninja-build/ninja/issues/2266
[B9]: https://github.com/ninja-build/ninja/blob/v1.13.1/src/subprocess-win32.cc#L111
[T0]: https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
[R1]: https://github.com/restic/restic/blob/v0.17.1/internal/archiver/archiver.go#L298
[R2]: https://github.com/restic/restic/blob/v0.17.1/internal/fs/fs_local.go#L20
[R3]: https://github.com/restic/restic/blob/v0.17.1/internal/fs/file_windows.go#L14
[R4]: https://github.com/restic/restic/blob/v0.17.1/internal/fs/file_unix.go#L13
[R5]: https://github.com/restic/restic/issues/4953
[R6]: https://github.com/restic/restic/pull/4954
[R7]: https://github.com/restic/restic/issues/4953#issuecomment-2262183138
[R8]: https://github.com/restic/restic/blob/v0.17.1/internal/fs/sd_windows.go#L131
[R9]: https://github.com/restic/restic/blob/v0.17.1/CHANGELOG.md#L94
[R10]: https://github.com/restic/restic/blob/v0.17.1/internal/restorer/restorer_test.go#L1533
[R11]: https://github.com/restic/restic/blob/v0.17.1/internal/restic/node.go#L79
[R12]: https://github.com/restic/restic/blob/v0.17.1/internal/restic/tree.go#L108
[R13]: https://github.com/restic/restic/blob/v0.17.1/internal/restorer/restorer.go#L177
[R14]: https://github.com/restic/restic/blob/v0.17.1/doc/design.rst
[RC1]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
[S1]: https://github.com/openssh/openssh-portable/blob/V_10_0_P1/sftp.c#L626
[S2]: https://github.com/openssh/openssh-portable/blob/V_10_0_P1/sftp-client.c#L1147
[S3]: https://github.com/openssh/openssh-portable/blob/V_10_0_P1/sftp-server.c#L742
[S4]: https://github.com/openssh/openssh-portable/blob/V_10_0_P1/sftp-common.h#L29
[L1]: https://github.com/torvalds/linux/blob/v6.14/include/uapi/linux/limits.h#L13
[L2]: https://github.com/torvalds/linux/blob/v6.14/fs/namei.c#L189
[L3]: https://github.com/torvalds/linux/blob/v6.14/fs/exec.c
[L4]: https://github.com/torvalds/linux/blob/v6.14/include/uapi/linux/binfmts.h#L15
[W1]: https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation
[W2]: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessa
