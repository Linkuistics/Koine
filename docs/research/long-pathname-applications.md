# Long pathnames in real applications (combined research)

**Short answer.** Two independent surveys, [A](long-pathname-applications-a.md)
and [B](long-pathname-applications-b.md), traced real applications through
file/editor/launch, build/package/repository, archive/backup/sync and
remote/virtual workflows. This synthesis unions them, re-reads the sources their
load-bearing claims rest on, and attacks the mechanisms they propose. Five
findings survive:

1. **Operating past a whole-path limit happens inside one process, or between
   cooperating ends that walk by handle.** Every over-limit success in the union
   is one of two kinds:
   - a process that holds a directory (a descriptor, the process cwd or a
     per-thread cwd) and passes short suffixes: gnulib/coreutils, libarchive and
     Apple's tar, Apple fts, GNU tar's create walk, Borg's create walk, low-level
     FUSE daemons, and Koine's own
     [k134 parent-relative calls](../verification/long-action-route-prototype.md#what-was-measured);
   - a protocol whose server walks components: NFS, 9P, and the FUSE kernel
     protocol.

   The surveys share only one of these systems, GNU tar. Both read the same
   release, and both describe a recovery branch that in that release never
   works ([correction 1](#4-disagreements-and-corrections)).
2. **Storing a long name is not operating on it, and operating is not passing
   it on.** Archive records, restic's component trees, GLib file objects, URIs,
   bookmarks and Zed's IPC strings all *hold* a 1,500-byte name. Each rebuilds a
   whole string when it materializes, restores, reads or launches.
3. **At an arbitrary application's boundary there are two walls, not one.**
   - **The handoff.** Every sourced macOS and Linux handoff delivers one of three
     things: a whole URL, path or URI; a shortened or virtual alias; or a
     refusal.
   - **The receiver.** Every receiver whose macOS or Unix code either survey
     read opens by whole path: Zed's GUI process, Rust std, Emacs and Vim.
     Delivering a location therefore would not, by itself, make the receiver
     open it.

   The protocol-level exception followed by this synthesis is Windows `DelegateExecute`
   verb, whose handler receives a Shell item array. This synthesis found it; its
   receiver behaviour past MAX_PATH is unsourced. Neither survey followed the
   legacy macOS FSRef item-array counterpart; [returned design](#returned-design-reconciliation)
   narrows that silence without establishing a long route.
4. **For Koine**, one supported lead survives:
   [component-relative presence and cause](#72-supported-promising-leads). It
   carries four qualifications: the descriptor budget, recovery branches,
   reuse of reconstructed strings, and the prompt k134 measured in Documents.
   - **Zed.** Its CLI side channel is a source-derived dead end for a
     1,500-byte document in current Zed.
   - **No within-mandate prior art** covers long classification, registration,
     default-handler lookup, submission, reveal, constrained long launch or
     receipt.
   - **Excluded mechanisms.** Each still needs a new decision from Antony.
   - **Open questions.** The sharpest is whether the retained default-open and
     Zed-open cases can pass at all while receivers read by whole path
     ([Q1](#75-precise-open-questions)).
5. **Most agreement here is correlated, not independent.**
   - **Survey A's framing.** Its headline restates the
     [earlier prior-art survey](prior-art-long-paths-a.md)'s, which it used as
     a lead list.
   - **Shared sources.** Every system both surveys cover was read from the same
     primary source, and no shared behaviour was executed by either survey.
   - **What it supports.** Agreement there corroborates a *reading* of the
     source, not a *behaviour*. This synthesis keeps B's bounded framing: a
     finite corpus does not prove that no interface exists.

**What this synthesis does not do.** It selects no route, changes no
requirement, credits no native action acceptance or production route, and runs
no experiment. Returned design `long-action-route-k141` consumes it.

## How this synthesis was made

- **Inputs.** Survey A (`long-pathname-applications-k138`, research-a) and
  survey B (`long-pathname-applications-k139`, research-b) answered one identical
  brief without reading each other. Koine's own measurements and constraints come
  from the [prototype](../verification/long-action-route-prototype.md), the
  [route evaluation](../verification/long-action-route.md) and the
  [reviewed boundary](../verification/long-action-native-boundary.md). The
  [prior-art survey](prior-art-long-paths-a.md) was read only to test
  correlation.
- **Re-reading.** On 2026-10-04 this session re-read every source that a
  load-bearing mechanism or limit rests on, in the pinned form the survey
  cited. That covers raw GitHub files at the cited commit or tag, the GNU tar
  1.35 release tarball and its cgit tag, the GitHub, Qt JIRA and GNOME GitLab
  issue APIs, live Microsoft, Dropbox and freedesktop pages, and the local macOS
  27.0 SDK headers. [Section 3](#3-citation-checks) lists the result for each
  one.
- **Adversarial search.** For each mechanism proposed as transferable, this
  session looked for contrary primary source, tests or maintainer reports, and
  followed reconstructed strings, metadata and receivers past the point where a
  survey stopped. The findings are in [section 4](#4-disagreements-and-corrections)
  and [section 5](#5-storing-operating-passing-the-mechanisms-under-attack).
- **Limits.** No native probe ran, nothing was built, and no reviewer was spent:
  combine-research carries the adversarial move itself. One user forum thread was
  read as a contrary-evidence search ([section 8](#8-unresolved-silences)).

**Evidence labels.** Each survey's own label is kept when its claim is quoted:
A uses N/O/I, and B uses D/S/T/R. This synthesis labels its own claims as
follows.

| Label | Meaning | Survey equivalents |
| --- | --- | --- |
| **D** | Documented promise or description, bounded by the stated product and version. | A's N (documentation) |
| **S** | Branch read in pinned source; its runtime consequence is inference unless paired with a test or report. | A's N (source), B's S |
| **T/R** | Upstream test, or a reported observation, with its reporter's role. | A's O, B's T/R |
| **I** | This synthesis's reading, not executed. | A's I, B's inference |
| **re-read** | This session fetched the cited pinned source and it says what the survey says. | — |

**Units.** These follow both surveys, and this session re-read them in source.

| Platform | Limit | Source |
| --- | --- | --- |
| macOS | `PATH_MAX` 1,024 bytes including NUL; `NAME_MAX` 255 bytes; `MAXLONGPATHLEN` 8,192 bytes | xnu `syslimits.h` |
| macOS | `PROC_PIDPATHINFO_MAXSIZE` 4 × `MAXPATHLEN`, which is 4,096 | local SDK `sys/proc_info.h` |
| Linux | `PATH_MAX` 4,096 bytes including NUL | `limits.h` |
| Windows | `MAX_PATH` 260 UTF-16 units including NUL; about 32,767 with `\\?\` | Microsoft's path page |

**A 1,500-byte path sits above macOS's limit and below Linux's.** As B states,
a Linux success at 1,500 bytes is no evidence about macOS. Most "long path"
successes in the corpus clear Windows's 260-unit `MAX_PATH`, and transfer to
macOS only as a pattern.

## 1. What the two surveys cover

**The overlap.** Both surveys read these systems, from the same primary source
in every row.

| System | A | B | What each adds |
| --- | --- | --- | --- |
| Zed CLI and editor | [§1.2](long-pathname-applications-a.md#12-zed-a-private-channel-for-documents-launch-services-for-the-app), commit `a8468907` | [§1](long-pathname-applications-b.md#1-zed-a-cooperating-handoff-that-avoids-one-opener-payload), 1.22.0 `76659a55` | A adds reveal and `open` behaviour. B adds the receiver trace, the `--zed` flag and the socket report. |
| GNU tar | [§3.2](long-pathname-applications-a.md#32-gnu-tar), cgit `v1.35` | [§5](long-pathname-applications-b.md#5-gnu-tar-recursive-reads-can-outlive-a-full-lookup-restore-differs), 1.35 tarball | B adds the `..` recovery order and the long-name tests. |
| CMake | [§2.4](long-pathname-applications-a.md#24-cmake-and-bazel-hashing-before-the-spawn), commit `5595ef72` | [§4](long-pathname-applications-b.md#4-cmake-and-ninja-own-the-output-name-cooperate-with-the-compiler), 3.31.6 | A adds Bazel. B adds Ninja. |
| GLib and Nautilus | [§1.5](long-pathname-applications-a.md#15-glib-nautilus-and-freedesktop-launch), commit `36c60f06` | [§3](long-pathname-applications-b.md#3-nautilusgio-objects-and-uris-with-full-path-local-consumers), 2.84.0 / 48.0 | A adds GLib #1245 and the desktop-entry spec. B adds GLib's FUSE substitution. |
| restic | [§3.4](long-pathname-applications-a.md#34-rsync-restic-borg) | [§6](long-pathname-applications-b.md#6-restic-windows-data-success-was-not-metadata-success), 0.17.1 | A adds a Linux report. B adds the Windows metadata regression and its test. |
| OpenSSH SFTP | [§4.4](long-pathname-applications-a.md#44-sftp-and-smb-whole-strings-by-choice) | [§8](long-pathname-applications-b.md#8-openssh-sftp-handles-after-open-full-paths-before-it), 10.0p1 | A adds SMB and Samba. B adds READDIR reconstruction. |
| robocopy | [§3.5](long-pathname-applications-a.md#35-windows-copy-tools-7-zip-and-info-zip) | [§7](long-pathname-applications-b.md#7-robocopy-documented-long-copy-support-with-a-closed-implementation) | Both rest on the same command reference. |
| Windows process creation | [§1.7](long-pathname-applications-a.md#17-windows-shell-explorer-and-process-launch), [§2.5](long-pathname-applications-a.md#25-language-runtimes-the-tools-stand-on) | [§4](long-pathname-applications-b.md#4-cmake-and-ninja-own-the-output-name-cooperate-with-the-compiler) | A adds Go, Terminal, Git for Windows, Bazel and Rust. B adds Ninja's ANSI spawn. |

**Only in survey A.**

- **macOS launch.** Launch Services, NSWorkspace, Apple Events and Finder.
- **Editors and file managers.** Electron and VS Code, Vim and Emacs, KDE and Qt,
  and the Windows shell.
- **Build tools.** Upstream git, Git for Windows, npm and pnpm, Bazel, and the
  language runtimes.
- **Archive and copy.** libarchive and Apple's tar; gnulib, Apple fts, macOS
  `cp`, `rm` and `copyfile`; rsync, Borg, 7-Zip and Info-ZIP.
- **Sync.** OneDrive, Dropbox, iCloud for Windows and Syncthing.
- **Protocols and namespaces.** NFS, 9P, FUSE, SMB, Samba and Apple smbfs; the
  desktop portal; libpathrs; xnu identifiers and descriptors; URLs and KIO.

**Only in survey B.**

- CotEditor's security-scoped bookmarks.
- Ninja's response files and Windows stat guard.
- Zed's remote-socket report and the `--zed` flag.
- restic's Windows metadata regression and `TestRestorerLongPath`.
- OpenSSH's READDIR reconstruction.

**Breadth and depth differ.** A covers about five times as many systems and
answers the brief's "array of paths" question across protocols. B covers fewer
systems, but follows each one further into its receiver, metadata and restore
branches. Neither survey read a macOS document application beyond Zed,
CotEditor, Electron and VS Code. Neither has Finder or Launch Services source,
because none is published.

## 2. Independence: which agreements count

**Survey A inherits a framing.** The earlier prior-art survey (k136, also
research-a) answers that no surveyed system "hands them off as an *array of
path components*", and that "Every hand-off found is a path string, a URL, or
an fd. A receiving portal turns that fd straight back into a string". Survey
A's short answer restates that conclusion. Its xnu, portal, gnulib/coreutils
and rsync material retraces the prior survey's leads (§§1.3–1.5, 1.9 and
2.3–2.6 there). A re-fetched those sources, and this session found them accurate. The
*conclusion*, though, is one framing carried forward, not a second independent
finding. B reached a compatible but explicitly bounded conclusion without that
framing.

**Agreement on a shared source corroborates a reading, not a behaviour.**

| Agreement | Basis | Independence | Weight |
| --- | --- | --- | --- |
| Zed sends documents over IPC; Launch Services sees only `zed-cli://` | Same files, two commits | One source, two readers | Reading confirmed at both pins (re-read). Neither survey executed it. |
| Zed's receiver reads by whole path | A infers from Rust std. B traces `open_listener` and `RealFs::load`. | One project; B follows further | An agreed inference. `RealFs::load` calls `std::fs::read_to_string` (re-read). |
| GNU tar's create walk uses parent descriptors; extract passes the whole member name relative to `-C` | Same release (cgit tag and tarball are identical, checked) | One source | Reading confirmed. Both miss the release's recovery bug (correction 1). |
| CMake hashes an over-long object-path prefix | Same source, two pins | One source | Re-read at both pins. |
| A GLib local file is one whole string | Same source, plus A's 2017 reporter issue | Partly independent | The report is an independent observation of the consequence. |
| OpenSSH's `open` takes the whole path, and ENAMETOOLONG becomes `SSH2_FX_BAD_MESSAGE` | Same source, two pins | One source | Re-read. B's READDIR addition carries an upstream `XXX OVERFLOW ?` comment. |
| restic restores by whole path | Same source | One source | The two cited issues are independent, but report different failures (Linux scan, Windows metadata). |
| robocopy handles paths over 256 characters unless `/256` | One command reference | Not independent | A single vendor statement, mechanism undocumented. |
| Windows process creation stops at `MAX_PATH` for executable and working directory | Microsoft documentation, plus Git for Windows, Rust and Bazel source, a Terminal maintainer, a Go reporter, and Ninja | **Independent implementations** | The strongest agreement in the union. Several codebases hit the wall and code around it. |
| Over-limit failures are commonly reported as absence, an invalid name or a bad request | Emacs, Vim and OpenSSH source; KDE and GLib reports | **Independent implementations** | Strong as a pattern. It supports the reviewed Koine boundary's ban on reporting overlength as missing. |
| In-process directory walking reaches over-limit trees | gnulib's NEWS promise; libarchive, GNU tar, Borg and Apple fts source; k134 | **Independent**, and executed only in k134 | k134's measurement is the only executed macOS over-limit evidence anywhere in the corpus. |
| No arbitrary path-taking opener receives an over-limit location unchanged | A (inherited framing, broad); B (own framing, four handoff systems) | Partly independent | A bounded negative only, and correction 5 narrows it. |

## 3. Citation checks

This table records the result for every re-read source. A row marked
**corrected** is explained in [section 4](#4-disagreements-and-corrections).

| Claim | Survey | Source re-read | Result |
| --- | --- | --- | --- |
| xnu's long-path iopolicy needs `com.apple.private.vfs.support-long-paths`, and returns EPERM without it | A §4.7 | [`kern_resource.c`][X1] | Re-read. |
| volfs `/.vol` paths expand up to 8,192 bytes without that policy; the code calls them legacy, which "future versions of the OS may not support" | A §4.7 | [`vfs_lookup.c`][X2] | Re-read. |
| `openbyid_np` is gated by a private entitlement or platform-binary status | A §4.7 | [`vfs_syscalls.c`][X3] (`com.apple.private.vfs.open-by-id`) | Re-read. |
| `F_GETPATH` reads into a `MAXPATHLEN` buffer | A §4.7 | [`kern_descrip.c`][X4] | Re-read. Correction 3 adds public `fsgetpath`. |
| `PATH_MAX` 1,024, `NAME_MAX` 255, `MAXLONGPATHLEN` 8,192 | A, B | [`syslimits.h`][X5] | Re-read. |
| Apple fts caps `fts_path` at `USHRT_MAX`, and an environment variable opts into a per-thread cwd | A §3.3 | [`fts.c`][X6] | Re-read. The local SDK 27.0 declares no `pthread_fchdir_np`; it marks `FTS_THREAD_FCHDIR` as "(private) use pthread_fchdir_np". |
| macOS `cp` uses `FTS_NOCHDIR`, a `PATH_MAX` destination buffer, and an ENAMETOOLONG warn-and-skip | A §3.3 | [`cp.c`][X7] | Re-read. |
| `copyfile` recursion uses `FTS_NOCHDIR` | A §3.3 | [`copyfile.c`][X8] | Re-read. |
| libarchive's `edit_deep_directories`, the security-check note, and a test sized below PATH_MAX | A §3.1 | [upstream][X9]; [Apple's libarchive-167][X10] | Re-read. Apple's fork calls `pthread_fchdir_np` and `O_NOFOLLOW_ANY`. |
| GNU tar extract calls `openat(chdir_fd, file_name, …)`, and ENAMETOOLONG means "fail now" | A §3.2, B §5 | [`extract.c` v1.35][T1] | Re-read. |
| GNU tar recovers parent descriptors under pressure | A §3.2, B §5 | [`create.c` v1.35][T2], [fix][T3] | **Corrected** (1). |
| GNU tar 1.35 release SHA-256 `4d62ff37…3edc16` | B §5 | Recomputed from the downloaded tarball | Matches. |
| Zed canonicalize fallback, `zed-cli://` launch and `CliRequest::Open { paths: Vec<String> }` | A §1.2, B §1 | Both commits | Re-read. |
| Zed's `reveal_path` discards the `BOOL`, and `open_with_system` only logs | A §1.2 | [`platform.rs`][Z1] | Re-read. |
| Zed `RealFs::load` reads by whole path; the CLI has a "Custom path to Zed.app" flag | B §1 | [`fs.rs`][Z2], [`cli/main.rs`][Z3] | Re-read. |
| NSWorkspace `selectFile` returns a bare `BOOL`, and `activateFileViewerSelectingURLs` returns `void` | A §1.1 | Local SDK 27.0 `NSWorkspace.h` | Re-read. |
| `kLSUnknownErr = -10810` "Unexpected internal error" | A §1.1 | Local SDK 27.0 `LSConstants.h` | Re-read. |
| OpenSSH maps ENAMETOOLONG to `BAD_MESSAGE` and ELOOP to `NO_SUCH_FILE`; READDIR builds an unchecked `PATH_MAX` string | A §4.4, B §8 | [`sftp-server.c` 10.0p1][O1] | Re-read. Upstream marks that line `/* XXX OVERFLOW ? */`. |
| CMake's built-in limit is 250 on Windows and 1,000 elsewhere; MD5 shortening; "The build may not work correctly" | A §2.4, B §4 | Both pins | Re-read. |
| Vim's "Illegal file name" at `fnamelen >= MAXPATHL`, and truncation on failure | A §1.4 | `fileio.c`, `filepath.c` | Re-read. |
| Emacs on Windows maps `ERROR_INSUFFICIENT_BUFFER` to `ENOENT` | A §1.4 | `w32.c` | Re-read. |
| Electron logs "NSWorkspace failed to select file" and returns no error | A §1.3 | `platform_util_mac.mm` | Re-read. |
| The portal's `OpenFile(h)` reads the descriptor's path back through `PATH_MAX` | A §4.5 | `OpenURI.xml`, `xdp-app-info.c` | Re-read. |
| rsync's sender skips "filename overflows max-path len", and its receiver calls `overflow_exit` | A §3.4 | `flist.c` v3.4.4 | Re-read. |
| Samba falls back to its component loop only for ENOSYS/ELOOP/ENOTDIR/ENOENT | A §4.4 | `files.c` | Re-read (`default: goto fail`). |
| GLib passes a FUSE path for `%u`/`%U`, unless `X-GIO-NoFuse` is set | B §3 | [`gdesktopappinfo.c` 2.84.0][G1] | Re-read. **Disagrees with the spec** that A cites (correction 2). |
| CotEditor drops failed bookmark creation and resolution through `try?`/`compactMap` | B §2 | [`DirectoryDocument.swift`][C1] | Re-read. |
| restic's `fixpath` and the twenty-by-twenty-character `TestRestorerLongPath` | B §6 | `file_windows.go`, `restorer_test.go` v0.17.1 | Re-read. |
| Rust strips `\\?\` for the working directory; Git for Windows refuses long executable and cwd paths and caps itself at 4,096; Bazel's three spawn fallbacks | A §2.2, §2.4, §2.5 | Pinned source | Re-read. |
| Microsoft's path page forbids `\\?\` with a relative path and warns about the shell; the opt-in lists omit process creation | A §2, B scope | [Path page][W1] | Re-read. Neither `CreateProcess` nor `ShellExecute` appears anywhere on the page. |
| OneDrive lists "macOS Finder 1,024 characters" | A §1.1, §3.6 | [OneDrive page][W2] | **Corrected** (7). |
| Dropbox: "The current path length limit is 8,096 characters" | A §3.6 | [Dropbox page][W3] | Re-read verbatim (unit "characters"). |
| Qt closed QTBUG-138251 Won't Do, citing Windows, full path resolution, fd exhaustion and correct ENAMETOOLONG | A §1.6 | [Qt JIRA API][Q1] | Re-read; the comments are by Thiago Macieira. The same thread says macOS's default descriptor limit is "256 IIRC", which matches k134's descriptor leak in a Launch Services–launched process. |
| GLib #1245: "*All* other tools I have at hand manage to handle this situation" | A §1.5 | [GNOME GitLab API][G2] | Re-read; a reporter statement, open since 2017-02-16. |
| Go #78601's working-directory quotes | A §2.5 | [GitHub API][R1] | **Corrected** (8). |
| Windows Terminal #19058: "`CreateProcessW` does not work for a working directory that is longer than `MAX_PATH`" | A §1.7 | GitHub API | Re-read; a maintainer (MEMBER) comment. |
| Git for Windows's "3-4% to the runtime" and the long-config catch-22 | A §2.2 | GitHub API | Re-read; maintainer comments. |
| restic #4693 | A §3.4 | [GitHub API][R2] | **Corrected** (9). |
| restic #4953/#4954: the patched build restores the ten files | B §6 | GitHub API | Re-read; a reporter follow-up. |
| VS Code #116303: the contributor's interim advice is a junction or moving the repository | A §1.3 | GitHub API | Re-read (CONTRIBUTOR). |
| Zed #59142: the remote `$HOME` socket path exceeds the 107-character `AF_UNIX` limit | B §1 | GitHub API | Re-read; open, 2026-06-11, Linux remote. |
| Electron #42634, Bazel #19710/#30431/#4149, Ninja #2359/#2266, actions/checkout#923, libarchive#744, PowerToys#8748 | A, B | GitHub API | All exist, with titles matching their characterization. |

**Not re-read.** These keep their surveys' labels: the NFS and 9P protocol
texts; the Linux kernel lines for NFS, FUSE, 9P and namei; QEMU, libfuse,
libpathrs, Borg, 7-Zip, Info-ZIP, Syncthing, npm and pnpm; Apple smbfs; the
iCloud for Windows page; GLib's `glocalfile.c`;
upstream git; the Go and Python descriptor walks; KDE 506659; kio-fuse; and
Chromium. Each illustrates a pattern. None is load-bearing for a macOS Koine
decision.

## 4. Disagreements and corrections

Each item names where the surveys stand and what the source shows. A
disagreement is preserved even where one side looks likely wrong.

1. **GNU tar's parent-descriptor recovery** (A §3.2; B §5).
   - **A says** that under descriptor pressure GNU tar "reopens parents by their
     *original whole name*, which brings the limit back".
   - **B says** that it first tries `openat(childfd, "..")` with a
     device/inode check, and that a whole-name fallback "can move the full-path
     limit back".
   - **The source** ([`create.c` v1.35 L1593-L1629][T2]) confirms B's order. In
     the release both surveys pinned, though, the fallback's identity check calls
     `fstat(parentfd, …)` on the already-failed descriptor instead of the newly
     opened one. A reopened parent is therefore never adopted. Upstream fixed
     this on 2026-03-10 ([`af552a07`][T3], "Fix wrong fd in restore_parent_fd
     fallback path").
   - **Consequence (I).** In 1.35, when `..` fails, the parent stays an error;
     the whole-name reopen is attempted but its result is discarded. On a fixed
     build, that reopen is subject to the whole-path limit, as both surveys say.
   - **For Koine (I).** The descriptor-pressure recovery branch is exactly where
     a mature descriptor walk carried a latent defect. The resolver's recovery
     paths need their own subjects, not only its normal walk.
2. **Desktop-entry `%f`/`%u` for non-local files** (A §1.5; B §3).
   - **A cites the [desktop-entry spec][G3]**: a non-local file is copied to a
     temporary local file for `%f`.
   - **B cites GLib 2.84.0**: `%u`/`%U` become a POSIX path inside the gvfs FUSE
     mount, falling back to the URI, unless `X-GIO-NoFuse` is set ([L2529][G1]).
   - **Reading.** Both are accurate about their own source; the specification
     and its main implementation diverge. For Koine both are excluded, as an
     alternate copy and as a mapped spelling respectively.
3. **Reading a long path back from a descriptor on macOS** (A §4.7 and its §5.1
   table).
   - **A says** `F_GETPATH` is "the macOS twin" of the portal's `/proc/self/fd`
     read-back, and that descriptor passing therefore "moves" the limit to the
     receiver.
   - **This synthesis found** that the public `fsgetpath(2)` accepts buffers up
     to `MAXLONGPATHLEN` with no long-path-policy check ([`vfs_syscalls.c`
     L14350-L14362 and L14440][X11]). Koine's search design and the prior-art
     survey already rely on it.
   - **Reading (I).** A cooperating receiver *can* recover 1,500-byte path text
     from a descriptor's identity. It still cannot hand that text to whole-path
     calls without the private policy. A's "moves" holds for *operations*, not
     for *reading*.
4. **The instrument behind receipt identity** (A §5.2 "Receipt identity"; B
   mechanism comparison).
   - **A** grounds "no route found" in `F_GETPATH` and Linux `/proc/self/fd`.
     Koine's receipt candidates use neither.
   - **Koine's candidates** are the launch callback's `executableURL` and
     `proc_pidpath`. The `proc_pidpath` buffer allows 4,096 bytes; the kernel
     builds the executable's path and then revalidates it with a whole-path
     `vnode_lookup` ([`proc_info.c` L1438-L1461][X12]).
   - **Reading (I), not executed.** For a 1,500-byte executable, the 4,096-byte
     buffer is not the limit; the whole-path lookup is, from a caller without the
     long-path policy. This matches k133's reading in the
     [route evaluation](../verification/long-action-route.md#source-candidates-and-remaining-obligations).
   - **B** only says no IPC status or identifier establishes the receipt.
   - **Outcome.** A's conclusion survives, for a different reason.
5. **"The handler is still started with a command line"** (A §1.7, labelled I).
   - **A infers** that a ShellExecute handler is still started with a command
     line, and its short answer says "every sourced system" rebuilds a full
     string at the opener.
   - **Microsoft documents** that a verb implemented through `DelegateExecute` /
     [`IExecuteCommand`][W4] receives "a Shell item array through
     IObjectWithSelection::SetSelection". That is a sequence of item IDs, not a
     command line, delivered to an arbitrary registered handler.
   - **What remains unsourced.** Whether such a handler, or the shell that builds
     the array, can act on an item beyond `MAX_PATH`. The prior-art survey states
     that a PIDL "is opaque and built from a MAX_PATH-limited string"; if that
     holds here, the array carries the same limit. Neither survey nor this
     synthesis sourced the shell's construction for an over-limit item.
   - **Outcome.** A's universal phrasing is too strong for Windows. Its narrower
     claim, that no surveyed system delivers an over-limit location *unchanged*
     to a *path-taking* opener, still stands. Neither survey followed the legacy
     macOS counterpart identified by [returned design](#returned-design-reconciliation).
6. **How general the negative is** (A short answer and §1.8; B mechanism
   comparison).
   - **A's summary** phrasing slides toward a universal: "every sourced system
     rebuilds a full string here".
   - **B says** its "finite corpus is not proof that no such interface or
     successful application exists".
   - **Outcome.** This synthesis adopts B's bounded form. Correction 5 is the
     reason.
7. **OneDrive's "macOS Finder 1,024 characters"** (A §1.1 and §3.6).
   - **A presents it** as "an independent product statement of the ceiling k134
     measured".
   - **The page itself** ([OneDrive][W2]) gives the figure in *characters*, and
     explains that "Paths with multi-byte Unicode characters could exceed 1,024
     bytes at the file system level". It is restating the filesystem's
     `PATH_MAX` for a third party's product, not observing Finder.
   - **Outcome.** It corroborates neither a Finder mechanism nor k134's byte
     measurement, and is demoted to context.
8. **Go #78601's "nothing can be done … on the toolchain level"** (A §2.5).
   - **A** labels the quote O without naming its author.
   - **The GitHub API** ([comment][R1]) shows it comes from the issue's reporter
     (author association NONE), not from a Go maintainer.
   - **Outcome.** The `CreateProcess` working-directory wall it describes stays
     well supported, independently, by the Windows Terminal maintainer and by
     Git for Windows's source comment.
9. **restic #4693** (A §3.4).
   - **A says** "On Linux an over-limit file was skipped with a warning while
     the snapshot was saved".
   - **The issue** ([#4693][R2]) is titled "Fatal Crash while backing up a deep
     directory tree": a Go runtime memory error, which a maintainer attributed to
     possible memory corruption.
   - **The skip-with-warning** (`file name too long … snapshot saved`) appears
     only in the reporter's later follow-up, after the crash stopped
     reproducing, inside Docker.
   - **Outcome.** A weak observation; it is kept with that context.
10. **Agreements that remain inference.** Both surveys infer, without execution,
    four outcomes: that Zed fails to open a 1,500-byte document, that GNU tar
    cannot extract one on macOS, that OpenSSH returns "bad message" against a
    macOS server, and that restic cannot restore one there. The sources were
    re-read and support each reading. No over-PATH_MAX run of any of these
    exists in either corpus.

## 5. Storing, operating, passing: the mechanisms under attack

The brief asks for three things to be kept apart: *storing* a long name,
*operating* on it, and *passing* it to an arbitrary application. Each mechanism
the surveys propose as transferable is tested against all three.

| Mechanism | Stores | Operates in-process | Passes to a cooperating peer | Passes to an arbitrary application |
| --- | --- | --- | --- | --- |
| Directory descriptor or cwd plus a short suffix | Display text only | **Yes**, below a root opened by string; bounded by `NAME_MAX`, descriptors and recursion | Only if descriptors are passed | No |
| Component array on the wire (NFS, 9P, FUSE kernel) | Yes | Server walks by handle | **Yes**, both ends cooperating | No; rejoined at the edge |
| Descriptor passing (XPC, portal) | — | Yes, on that object | Moves the limit to the receiver's operations; `fsgetpath` can read text up to 8,192 bytes | No macOS opener accepts one |
| Strings over private IPC (Zed CLI) | Yes | The receiver re-reads by whole path | Delivers the string | No |
| Archive or repository records (pax, GNU long names, restic trees) | **Yes** | Materialization goes back to whole paths | Needs a compatible reader | No |
| Bookmarks (CotEditor) and file-reference/volfs ids | Yes, opaque | Resolution yields a URL, then a whole-path read | Receiver must resolve them | Unproven; excluded as id-spelled |
| Windows `\\?\` prefix (restic, Git for Windows, Rust, Go, 7-Zip) | — | Per call that opts in | Stops at `CreateProcess`, `cmd.exe` and Explorer | No |
| Hashing, flattening, junctions, 8.3, virtual short paths | — | Avoids the long path | Avoids it | Avoids it by changing the spelling; excluded as shortening |
| Raised OS limit (`longPathAware`; xnu private policy) | — | Per process | Each process must opt in | macOS: private; Windows: the shell stays limited |
| Truthful refusal (macOS `cp`, iCloud per-item, Qt's request) | — | — | — | A visible failure; a workflow decision |

### 5.1 Component-relative resolution for presence and cause

- **Proposed by** A §5.2 ("Within mandate. Supported by broad prior art.") and B
  lead 2 ("Promising for local resolution/provenance").
- **For it.** k134 executed it on macOS, and it distinguished missing,
  below-file, cycle, budget and impossible-component causes. gnulib promises it
  (NEWS, `chdir_long`), and libarchive, GNU tar, Borg and Apple fts implement it.
- **Attacks.**
  - **Descriptor budget.** Qt's maintainer rejects the model partly for
    "fd exhaustion", citing macOS's low default limit. k134 lost a run to a
    descriptor leak in a process launched with 256 descriptors.
  - **Recovery branches.** GNU tar 1.35's recovery fallback never worked
    (correction 1).
  - **Security checks against depth.** libarchive's symlink hardening disabled
    deep-directory support after long names evaded the check (#744; the source
    note is re-read).
  - **Reconstructed strings re-entering whole-path calls.** Every implementation
    rebuilds a display string: GNU tar's `name_buf`, Python's `fullname`, Go's
    `Name()`, OpenSSH's READDIR. GLib #1245 is the defect where a working
    relative name was made absolute and then failed. Samba skips its working
    component loop exactly on ENAMETOOLONG.
  - **Prompts.** k134's long metadata walk *prompted* at the Documents
    component, and the denial surfaced as EPERM. The prompt-free read rule is
    binding.
  - **Spelling.** Zed's ancestor-canonicalize fallback shows how a convenient
    resolver silently changes symlink and dot semantics (B §1).
- **Verdict.** A supported lead for presence, cause and provenance only. Every
  attack above becomes a design obligation. It establishes no classification,
  registration, handler, submission or receipt fact.

### 5.2 A cooperating receiver's side channel (Zed CLI)

- **Proposed by** A §5.3 lead 1 and B lead 1.
- **Attacks.**
  - **The receiver reads by whole path.** `RealFs::load` calls
    `std::fs::read_to_string(&path)` at B's pin, and both pins canonicalize the
    path first. With no private policy, a 1,500-byte document fails inside Zed
    on macOS (I, from source re-read here).
  - **Launch Services still sees the app.** The application URL still goes
    through Launch Services. The `--zed` path flag targets a copy, but its
    equality with Koine's *registered* selection is unproven (B).
  - **The IPC endpoint has its own limit.** The remote-socket report (#59142) is
    a Linux remote case, not a local document limit.
  - **It changes the contract.** The CLI's semantics are not NSWorkspace named
    open, and a CLI exit status is not Koine's executable-identity receipt.
- **Verdict.** For a 1,500-byte document in current Zed this is a
  **source-derived dead end** (not executed). The channel removes Launch
  Services from the document path, but not Zed's own I/O.

### 5.3 Descriptor passing to another process

- **Proposed by** A §4.5, §4.7 and §5.1 (cooperating peers only), and the
  [route evaluation](../verification/long-action-route.md#representation-and-ownership)
  for Koine's own processes.
- **Attacks.**
  - **Read-back at the boundary.** The portal turns the descriptor back into a
    `PATH_MAX` string one step after receiving it.
  - **No macOS opener interface.** Neither survey, nor this synthesis's search,
    found a Launch Services, Finder or third-party macOS interface that accepts
    a descriptor or a parent-plus-name pair.
  - **`fsgetpath` recovers text, not operations** (correction 3).
- **Verdict.** It works between Koine's own processes. It is not an opener
  route.

### 5.4 Component arrays: "do they have to use an array of paths?"

- **What the evidence shows.** Real systems use component arrays *inside*
  protocols whose servers walk by handle: NFS LOOKUP and COMPOUND, 9P `Twalk`,
  and the FUSE kernel protocol (A §4.1–§4.3).
- **The array is rejoined at the edges.** Linux renders NFS referrals back to a
  string with a `PATH_MAX` check, libfuse's high-level API rebuilds paths, and a
  client's own `open` is whole-path.
- **Not every "array" is one path.** In B, an array means *many complete
  paths* (Zed's `Vec<String>`), *children in a tree* (restic) or *resolver
  working state* (Zed's fallback). None is one location split into components.
- **The Windows exception in this corpus.** `DelegateExecute` carries item
  sequences (correction 5). The returned design's SDK follow-up also identifies
  macOS legacy FSRef item arrays; neither supplies an established long macOS route.
- **Verdict.** No macOS application interface in either corpus accepts a
  component array.

### 5.5 Bookmarks, file-reference URLs and volfs ids

- **Bookmarks.** CotEditor resolves its bookmarks back to URLs, then reads by
  path. It drops failures silently, and its security-scoped variant needs a new
  consent and setup posture (B §2).
- **volfs and `openbyid_np`.** Apple says applications should never construct
  volfs paths and marks them legacy. `openbyid_np` is gated (A §4.7).
- **Verdict.** Excluded as id-spelled, or as a new posture. Even an accepted id
  would leave the opener's and receiver's behaviour unproven.

### 5.6 What the Windows evidence teaches without transferring

On Windows, tools that fixed their own I/O hit three walls: `CreateProcess`
(working directory and executable), `cmd.exe`, and Explorer. That is
independently corroborated (see [section 2](#2-independence-which-agreements-count)).
restic's 0.17.0 regression shows that fixing data reads does not fix metadata
reads (B §6). The lesson transfers to macOS as a *method*: every consumer of the
location needs its own supported long acquisition. The `\\?\` mechanism itself
has no public macOS counterpart.

## 6. Comparison across use cases

| Use case | Representation | Succeeds past the whole-path limit | Shortens, refuses or loses | Process cooperation |
| --- | --- | --- | --- | --- |
| Document launch and editors | URL, argv path, D-Bus URI, ShellExecute string, IPC string | None found on macOS or Linux at the arbitrary-opener step | Emacs on Windows reports ENOENT; Vim refuses or truncates; KDE reports "not found"; Electron and Zed discard the reveal result; VS Code's advice is a junction | Zed's IPC, VS Code's second-instance socket and D-Bus `Open` carry strings |
| Build, package and repository | Strings, hashed or flattened trees, response files | Windows tools past 260 units through `\\?\` inside their own I/O | CMake and Bazel hash; npm flattens; pnpm truncates and hashes; Git for Windows and Bazel stop at process creation | Response files cut aggregate argv only |
| Archive, copy, backup and sync | pax and GNU records, restic trees, relative strings | libarchive's deep-directory extraction (source; default secure-mode bsdtar past 1,024 bytes is unanswered), gnulib, Apple fts, `rm` (I), GNU tar and Borg creation (source), robocopy (documented) | macOS `cp` skips; rsync aborts; GNU tar 1.35 extraction (I); restic and Borg restore (I); UnZip truncates; Dropbox, iCloud and OneDrive skip or stop | Sync services report per item or stop the session |
| Remote and virtual namespaces | Component arrays, handles, descriptors, virtual short paths | NFS, 9P and FUSE kernel traffic; low-level FUSE daemons | The portal reads back through `PATH_MAX`; Samba skips its component loop on ENAMETOOLONG; Apple smbfs caps at 256 components; OpenSSH reports "bad message" | Both ends must cooperate |
| Process creation and launch | Executable path and working directory | None found | Windows `CreateProcess` refuses; k134's long launch fails at NSWorkspace | — |

**Platform and version conditions.**

- **Pinned versions.** All source evidence is pinned to the versions the
  surveys cite. Zed is read at two pins (`a8468907` and 1.22.0); the
  canonicalize fallback and the IPC request type are the same at both.
- **macOS.** xnu shows `MAXLONGPATHLEN` from tag 11417 and in 12377 (A §4.9).
  The mapping to macOS releases is unverified. k134 measured macOS 26.5
  (25F71).
- **Windows.** Long paths require the registry value *and* a manifest per
  process, for the listed file functions only.
- **Linux.** Limits and portal behaviour are pinned to the kernel versions
  (v6.12, v6.14 and one commit) and the portal commit the surveys cite.

**Failure behaviour.** Over-limit failures commonly surface as absence,
invalid input, a bare `NO`, a log line, or silent truncation. The reviewed
Koine boundary's truthful-failure contract is the exception in this corpus, not
the norm.

## 7. Koine applicability map

### 7.1 Retained obligations, unchanged

Nothing in either survey or in this synthesis changes the following:

- **The working cases.** A roughly 1,500-byte ordinary file opened by its
  default handler and by Zed, and revealed in Finder. A long registered
  application, cold- and warm-launched and used for named open by identifier
  *and* path while another copy runs.
- **Locations and copies.** Locations are unchanged. The exact selected
  registered copy is used. There is no shortening, alternate copy or
  identity-spelled submission.
- **Native facts and receipts.** Native facts are acquired with cause
  provenance, never guessed. Receipts are truthful, with executable identity,
  and a systematic length-caused null receipt remains a defect.
- **Controls and consent.** Both controls apply. Reads stay prompt-free. There
  is no new consent, entitlement, setup or private policy.
- **Regressions.** Short-workflow regressions are tested with long registered
  copies.
- **Acceptance subjects.** Launch-and-open's independently component-created
  action fixtures stay separate from app-and-file-search's later actual-search
  G/N/V provenance rows. Retained 1.0.0, action-repair 1.0.1 and search 1.1.0
  remain independent subjects.
- **Review order.** k128's mandatory `long-search-result-actions` review comes
  before search consumers k123/k120/k30 and any implementation consumer.

### 7.2 Supported promising leads

None of these is a route, and none credits an acceptance.

| Lead | Supporting evidence | What it gives Koine | What it does not give |
| --- | --- | --- | --- |
| **L1. Component-relative presence and cause resolver** | k134 (executed); gnulib, libarchive, GNU tar, Borg and Apple fts (source) | Truthful presence, missing, below-file, cycle, budget and impossible-component causes, with provenance | Classification, registration, handler, submission or receipt. Obligations: descriptor budget, recovery-branch subjects, symlink spelling, and the Documents prompt ([section 5.1](#51-component-relative-resolution-for-presence-and-cause)) |
| **L2. Keep display/provenance text apart from lookup operands** | GNU tar's `name_buf` against its parent descriptor; GLib #1245 and Samba as counter-examples | A rule: a reconstructed full string never re-enters a whole-path call, and a size failure is never reported as absence | A route |
| **L3. Audit every consumer separately** | restic's metadata regression; OpenSSH's READDIR; libarchive's deferred metadata through the unedited name | Each fact (flags, type, identifier, registration, handler, receipt) needs its own supported long acquisition, matching k132's boundary | Any acquisition |
| **L4. Public `fsgetpath` as a long-text reader** | xnu source (8,192-byte buffer, no policy check); already in search's design | Display and provenance text for an identity | An operation, a submission or a receipt |
| **L5. Truthful error mapping** | Qt's maintainer ("file issues where an operation mishandled ENAMETOOLONG"); Emacs, KDE, Vim and OpenSSH as counter-examples | Support for the reviewed boundary's overlength ≠ missing rule | A working case |

### 7.3 Excluded choices needing a new human decision

Prior art exists for each. None is adopted, and each needs Antony's explicit
decision before design may rely on it.

| Choice | Prior art | Mandate status |
| --- | --- | --- |
| **E1. Shortening**: a short link, junction-like alias, hashed or flattened layout, relocated copy or virtual short path | npm, pnpm, CMake, Bazel, VS Code's advice, the Linux document portal, drive letters | Excluded: shortening. It changes the delivered spelling. |
| **E2. Id-spelled submission**: volfs, file-reference URL or bookmark handed to the opener | xnu volfs, Foundation file-reference URLs, portal document ids | Excluded: id-spelled. Apple says never to construct volfs paths. |
| **E3. Private policy or SPI**: the long-path iopolicy, `pthread_fchdir_np` | xnu; Apple's libarchive and fts | Excluded: private. It would not reach Launch Services or receiver processes anyway. |
| **E4. New consent or setup**: security-scoped bookmarks; Apple Events `odoc` to a named app | CotEditor; Apple DTS sample code | Needs a new consent/setup or Automation decision. |
| **E5. Alternate content**: a temporary copy or Zed's stdin temporary files | The desktop-entry spec's `%f`; Zed's CLI | Excluded: alternate copy. |
| **E6. Contract change for one app**: the Zed CLI or its IPC in place of NSWorkspace named open | Zed | A different launch call, semantics and receipt; also a dead end ([section 5.2](#52-a-cooperating-receivers-side-channel-zed-cli)). |
| **E7. Disclosed truthful refusal** of long working cases | macOS `cp`, iCloud for Windows per-item, Qt's position | Workflow loss. Antony has declined it once; it is listed as prior art, not recommended. |

### 7.4 Demonstrated dead ends for bounded mechanisms

Each is bounded to the stated mechanism, version and condition, and none is a
universal impossibility.

| Dead end | Evidence | Bound |
| --- | --- | --- |
| **X1.** NSWorkspace open, launch and reveal; Launch Services registration and lookup; component-built FSRefs, at or above 1,024 bytes | k134, executed ([prototype](../verification/long-action-route-prototype.md#what-was-measured)) | macOS 26.5, SDK 27.0, the tested calls; submissions bypassed prerequisites as API diagnostics |
| **X2.** The Zed CLI side channel for a 1,500-byte document | Source at both pins (`RealFs::load`, canonicalize) | Current Zed on macOS without the private policy; not executed |
| **X3.** `F_GETPATH` for paths of 1,024 bytes or more | xnu source | Any caller; `fsgetpath` is the separate reader (L4) |
| **X4.** `proc_pidpath` for an executable path of 1,024 bytes or more | xnu source (whole-path `vnode_lookup` after building the path) | Callers without the long-path policy; not executed; agrees with k133 |
| **X5.** Descriptor or array handoff to the portal-style Linux opener | Portal source (`PATH_MAX` read-back) | Linux portal at the pinned commit |

### 7.5 Precise open questions

These are for returned design k141. None authorizes a new experiment or an
automatic evidence chain, and each names the decision it feeds.

- **Q1. Does a working case pass on delivery, or on the receiver opening the
  document?**
  - **Why it matters.** The reviewed
    [independent subjects](../verification/long-action-native-boundary.md#independent-subjects-for-the-route-design)
    require that the ordinary-file case "independently observe
    delivery/rendering". Every macOS receiver with readable source in the corpus
    reads by whole path, so a Koine route could deliver exact bytes and the
    real default handler or Zed could still fail to open them.
  - **What would settle it.** The design must say which observation closes the
    default-open and Zed-open cases. If rendering by the real application is
    required, then the outcome depends on receivers Koine does not control.
    Acknowledging that dependency, or changing what the case observes, is a
    decision for Antony.
- **Q2. Is there any public macOS opener interface taking a parent reference
  plus a name, or an item sequence?** The Windows `DelegateExecute` Shell item
  array is one such interface on another platform. Neither survey nor this
  synthesis found a macOS counterpart; k134's Launch Services item APIs failed
  past 1,023 bytes. This is a source question for k141, not an experiment.
- **Q3. Can a receipt's executable identity be established by object identity
  rather than path text?** `proc_pidpath` fails past the limit (X4). Whether a
  public interface yields the launched process's executable `(dev, ino)`
  without rebuilding its path is unsourced in both corpora.
- **Q4. Can a long application copy be registered?** No surveyed system
  registers a handler or application at an over-limit location; k134's
  registration failed. Without registration, exact registered-copy selection
  stays pending.
- **Q5. What prompt posture does the long component walk need?** k134's walk
  prompted at Documents. Does lead L1 stay prompt-free in protected locations,
  or does it join `protected-default-open-k89`'s existing human decision?
- **Q6. Does any Apple process run with the long-path iopolicy?** If Finder or a
  default handler held it, the receiver wall would differ. Which Apple processes
  set the policy is a silence (A §6). Excluded mechanisms are unaffected.

## 8. Unresolved silences

These are the union of both surveys' silences, less what this synthesis
resolved, plus its own searches.

- **Apple's closed components.**
  - Launch Services and Finder whole-path behaviour beyond k134's measurement.
  - What Launch Services sends in `odoc`.
  - Bookmark resolution past 1,024 bytes.
  - Darwin Foundation's `fileSystemRepresentation` buffer.
  - Which Apple processes set the long-path iopolicy.
  - The first macOS release with `MAXLONGPATHLEN`.
- **The user forum record.** A search of Apple Community found user threads that
  restate the 1,024 limit for macOS 10.13 and Mojave ([thread][F1]). They contain
  no observed Finder or application behaviour and no Apple staff statement. They
  are folklore, not evidence.
- **macOS applications past 1,024 bytes.** No sourced outcome for Zed, VS Code,
  BBEdit, CotEditor, git, SwiftPM, Xcode DerivedData or Homebrew.
- **Tools.** `ditto`, Time Machine, macFUSE and FUSE-T internals, the macOS NFS
  client, WebDAV servers, Google Drive for desktop, `xcopy`, `subst`, and
  robocopy's mechanism.
- **Inference-only outcomes.**
  - Default secure-mode bsdtar extraction past 1,024 bytes; the source and its
    comment disagree.
  - GNU tar extraction and Borg or restic restore past `PATH_MAX`.
  - Whether OpenSSH READDIR's unchecked truncation ever names another item.
  - Restic's exit code for skipped files.
  - Current Syncthing per-item pull handling.
  - Whether every QEMU 9pfs operation avoids whole strings.
- **Windows.** A Microsoft statement of Explorer's numeric limit, and the
  behaviour of a `DelegateExecute` handler given an item beyond `MAX_PATH`.

## Returned design reconciliation

The [returned design](../verification/long-action-route.md#application-research-reconciliation)
uses this synthesis for local-access ownership, receiver obligations, truthful
cause/fact meaning and bounded evidence. The action/search specs, guide, trace
and glossary now cite that disposition. No complete route or workflow loss is
adopted, and no ADR selects an unestablished mechanism.

Its subsequent SDK 27.0 read narrows Q2: public deprecated
[LSOpenItemsWithRole](https://developer.apple.com/documentation/coreservices/1449783-lsopenitemswithrole)
and LSLaunchFSRefSpec accept arrays of whole FSRefs. They do not accept components
of one pathname or a parent descriptor plus name. Public
[FSGetCatalogInfoBulk](https://developer.apple.com/documentation/coreservices/1566447-fsgetcataloginfobulk)
can return references. The later k143
[acquisition result](../verification/long-action-route.md#native-reference-result-and-remaining-gap)
now shows named references at 1,024 bytes rejected by tested catalog/fact/handler/
directory consumers, with traversal failing before the 1,500-byte objects.
That closes the tested enumeration path as a complete route, not every consumer
or public mechanism. The tested constructors failed; legacy opener parity and the
receiver's later access remain unresolved. These are later source/result
reconciliations; neither independent survey read them, and this reconciliation
runs no new native probe.
The bounded absence of an established macOS route survives; a blanket absence
of native item-array APIs does not.

Q1 retains real-application delivery/rendering and Finder-selection observations;
the public receipt keeps its narrower acknowledgment/identity meaning. The
[remaining decision](../verification/long-action-route.md#decision-for-antony)
preserves Antony's requirement and names the missing platform/receiver capability.
Antony subsequently selected continued [internal investigation](../verification/long-action-route.md#internal-native-reference-investigation),
superseding the unused external inquiry drafts. The new SDK read narrows catalog
enumeration to flat iterators and rejects an unsupported 64-bit-inode-to-UInt32
node shortcut. The finite acquisition diagnostic is complete; Antony accepted
its result. The later [item-array diagnostic](../verification/item-array-submission.md)
measured both consumers: exact spelling delivered at 900/1,023 bytes and -41
with no recorder event at 1,024. Its finite allowance is spent. The
[returned representation assessment](../verification/long-action-route.md#item-array-result-and-representation-assessment)
consumes Antony's directory-handle/component and file-reference URL direction.
It distinguishes internal operands from identity-spelled submission: the E2
exception applies to the external spelling, not all internal reference use.
Public NSURL/CFURL reference factories are distinct from the unsupported FSRef
bridges and from manually constructed volfs strings. The [completed URL diagnostic](../verification/file-reference-url-acquisition-prototype.md)
passes local acquisition/identity/reading/original bytes at 900/1,023 but fails
acquisition at 1,024/1,500. No long local-consumer or later-stage pass follows.
The [completed same-object diagnostic](../verification/same-object-namespace-prototype.md)
measures the pinned XNU local lead: original identity/marker access passes at
900/1,500 bytes. Long application/type facts fail; a missed Zed trust stop leaves
no compliant long receiver or Finder-selection result. Antony accepted the
incomplete report with no retry. The
[focused Zed result and returned assessment](../verification/long-action-route.md#focused-zed-result-and-bookmark-question)
now establish fresh reading of both original files by the exact short Zed copy
after restricted-mode choices. The long buffer shows an inode-only filename;
native application/type acquisition still fails, exact delivery is opaque and
saving is untested. Antony authorized the finite local-only bookmark diagnostic
on 2026-10-06; it remains unexecuted. This source/receiver distinction preserves the surveys' bounded
whole-path readings; it does not infer failure of every short operand. No
production mechanism or exception, complete route, action acceptance or
automatic probe series is claimed.
These later observations/decisions are not part of either independent survey.

## Sources added or re-read by this synthesis

The surveys' own citations remain authoritative for everything else; follow them
from each survey's sections.

[X1]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/kern/kern_resource.c#L3228-L3256
[X2]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_lookup.c#L459-L511
[X3]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_syscalls.c#L5463-L5560
[X4]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/kern/kern_descrip.c#L3904-L3930
[X5]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/sys/syslimits.h#L103-L111
[X6]: https://github.com/apple-oss-distributions/Libc/blob/Libc-1752.100.10/gen/fts.c#L1521-L1536
[X7]: https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-479/cp/cp.c#L462-L473
[X8]: https://github.com/apple-oss-distributions/copyfile/blob/copyfile-240/copyfile.c#L679
[X9]: https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_disk_posix.c#L2043-L2090
[X10]: https://github.com/apple-oss-distributions/libarchive/blob/libarchive-167/libarchive/libarchive/archive_write_disk_posix.c#L2135-L2160
[X11]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_syscalls.c#L14350-L14450
[X12]: https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/kern/proc_info.c#L1438-L1461
[T1]: https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/src/extract.c?h=v1.35#n1216
[T2]: https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/src/create.c?h=v1.35#n1593
[T3]: https://cgit.git.savannah.gnu.org/cgit/tar.git/commit/?id=af552a0769a29d1006df6b842ac8f6225b6d415f
[Z1]: https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/gpui_macos/src/platform.rs#L1020-L1056
[Z2]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/fs/src/fs.rs#L954-L958
[Z3]: https://github.com/zed-industries/zed/blob/76659a55a8c10ed355a070f8764a0b1733e3c115/crates/cli/src/main.rs#L109-L111
[O1]: https://github.com/openssh/openssh-portable/blob/V_10_0_P1/sftp-server.c#L1147-L1161
[G1]: https://github.com/GNOME/glib/blob/2.84.0/gio/gdesktopappinfo.c#L2529-L2550
[G2]: https://gitlab.gnome.org/GNOME/glib/-/issues/1245
[G3]: https://specifications.freedesktop.org/desktop-entry/latest/exec-variables.html
[C1]: https://github.com/coteditor/CotEditor/blob/75df7fc4c7fe472c28880915e2dac351a9dde3f9/CotEditor/Sources/Document/DirectoryDocument.swift#L66-L90
[W1]: https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation
[W2]: https://support.microsoft.com/en-us/onedrive/what-are-file-path-length-limits
[W3]: https://help.dropbox.com/installs/macos-support-for-expected-changes
[W4]: https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iexecutecommand
[Q1]: https://bugreports.qt.io/browse/QTBUG-138251
[R1]: https://github.com/golang/go/issues/78601#issuecomment-4235758360
[R2]: https://github.com/restic/restic/issues/4693
[F1]: https://discussions.apple.com/thread/250275651
