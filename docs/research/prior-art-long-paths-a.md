# Prior art: acting on over-limit file locations (survey a)

**Short answer to Antony's question.** No. No surveyed system that acts on locations
longer than the platform path limit hands them off as an *array of path components*.

- **How they act on such locations.** Every system that does this carries a
  **directory handle plus a short relative name**. That is the shape of `openat`.
  It covers POSIX `*at`, gnulib/coreutils fts, NT `OBJECT_ATTRIBUTES.RootDirectory`,
  Go `os.Root`, Java `SecureDirectoryStream`, Python `dir_fd`, Rust
  `remove_dir_all`/`cap-std`, Capsicum and WASI.
- **What they carry for identity and display.** They keep one full path string.
- **Where component lists do appear.** Only *inside* resolvers, and in one other
  place: the Windows shell's item ID list (PIDL). A PIDL is opaque and built from a
  MAX_PATH-limited string.
- **How they hand off to another process.** Every hand-off found is a path string,
  a URL, or an fd. A receiving portal turns that fd straight back into a string,
  bounded again by PATH_MAX.

k134's wall is therefore not a macOS oddity. Windows has the same split, and
Microsoft documents it: the file system was opened to long paths in 2016, but the
shell, Explorer and process launch were not. A decade later, tools still steer users
below the shell limit or refuse long paths. On macOS, no public representation was
found that NSWorkspace or Launch Services accept for a location of 1,024 bytes or
more. Two things do reach such items: id-based volfs paths and an entitlement-gated
private kernel policy. Both are mandate exclusions.

This is a read-only survey for route design k135 (`long-action-route-k135`).
It selects no route, accepts no workflow loss and relaxes no exclusion.

The measured starting point is
[the k134 prototype](../verification/long-action-route-prototype.md): 1,023 bytes
passes and 1,024 fails at submission, classification, registration and lookup,
while `openat`/`fstatat`/`readlinkat` resolve the ~1,500-byte subjects with truthful
causes. The retained contract is in [the route evaluation](../verification/long-action-route.md)
and [the native boundary](../verification/long-action-native-boundary.md).

## How this survey was made

- **When.** Gathered 2026-10-04 as four independent web/source surveys, one per
  question cluster below.
- **What counts as a source.** Each claim cites a primary source: documentation, a
  standard, an SDK header, source pinned to a tag or commit, an issue or advisory,
  or a statement by a named project or vendor engineer. Third-party practitioner
  sources are labelled *secondary*.
- **What was re-verified for this write-up.** These were re-checked against their
  text:
  - Apple's `urlForApplication(toOpen:)` nil contract
  - hermes-agent #75011 and #122027
  - xnu-12377.1.9 `tests/vfs/longpaths.c`
  - Apple Libc fts's comment
  - libarchive #744
- **Local SDK.** "SDK 27.0" means the local `MacOSX27.0.sdk` headers and man pages.
- **Silences.** Where a search found nothing, the survey says so. The searches are
  collected in [Silences](#silences).
- **Walk-away check.** Each system answers one question: with the tool or library
  uninstalled, what is still legible?

**Mandate-exclusion labels**, used in [Routes and their exclusion status](#routes-and-their-exclusion-status):

| Label | Meaning |
| --- | --- |
| within mandate | Usable under the current posture. |
| excluded: shortening | Covers symlink-to-short and short aliases. |
| excluded: file-reference/id URL | An id-based location rather than the location itself. |
| excluded: legacy opener | |
| excluded: private policy | |
| excluded: guessed metadata | |
| needs new consent/entitlement | |

Any excluded route needs Antony's explicit relaxation.

## 1. Representation: what do systems carry instead of one string?

### 1.1 POSIX `*at` and the meaning of PATH_MAX

- **Carried.** A directory fd plus a relative pathname string.
- **Limit.** PATH_MAX bounds *one argument*, not filesystem depth.
  [POSIX `limits.h`](https://pubs.opengroup.org/onlinepubs/9799919799/basedefs/limits.h.html)
  contrasts it with SYMLINK_MAX: SYMLINK_MAX covers "data that is stored in the
  file system, as opposed to {PATH_MAX} which is the length of a name that can be
  passed to a function."
- **Error.** `ENAMETOOLONG`. The PATH_MAX case is only a "may fail" error in
  [POSIX `open`](https://pubs.opengroup.org/onlinepubs/9799919799/functions/open.html).
- **What went wrong.** The stated purpose of `*at` is about races, not length:
  "to enable opening files in directories other than the current working directory
  without exposure to race conditions" (same page). Linux's
  [open(2)](https://man7.org/linux/man-pages/man2/open.2.html) adds that the dirfd
  "is a stable reference to the directory, even if the directory is renamed".
- **POSIX requires walkers not to be length-bound.**
  [`find`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/find.html)
  "shall not fail due to path length limitations (unless a path operand specified
  by the application exceeds {PATH_MAX} requirements)".
  [`rm`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/rm.html) says
  the same.
- **Walk-away.** An fd means nothing outside the process. Nothing persists.

### 1.2 macOS kernel and libc

- **Limit.**
  - SDK 27.0 `sys/syslimits.h` defines `PATH_MAX 1024 /* max bytes in pathname */`,
    and `sys/param.h` sets `MAXPATHLEN PATH_MAX`.
  - Apple's own kernel test,
    [xnu-12377.1.9 `tests/vfs/longpaths.c`](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c),
    encodes exactly k134's boundary for whole-path calls (`access`, `fstatat`,
    `open`, `openat`, getattrlist paths and others) with the policy off:
    `/* MAXPATHLEN - 1 */ 0`, then `/* MAXPATHLEN */ ENAMETOOLONG`.
- **Apple acknowledges deeper trees exist.**
  [Libc-1752.120.2 `gen/fts.c`](https://github.com/apple-oss-distributions/Libc/blob/Libc-1752.120.2/gen/fts.c#L1514-L1536)
  says: "Allow essentially unlimited paths; find, rm, ls should all work on any
  tree. Most systems will allow creation of paths much longer than PATH_MAX, even
  though the kernel won't resolve them."
  - fts reaches them by `chdir`, carrying the full `fts_path` (a `u_short`, so below
    65,535) only for display.
  - With `FTS_NOCHDIR`, `fts_accpath` *is* the full path. So the 1,024-byte kernel
    limit should apply. That is inferred from source; no bug report was found.
- **Other Apple statements in SDK 27.0.**
  - `removefile.h` offers `REMOVEFILE_ALLOW_LONG_PATHS`: "Paths may be longer than
    PATH_MAX - requires temporarily changing cwd". Its man page notes that this "may
    change the working directory … making it not thread safe" and does not let the
    path *argument* exceed the limit.
  - EndpointSecurity's `ESMessageCore.h`: "Overlong paths are truncated at a maximum
    length that currently is 16K, though that number is not considered API". Apple's
    own security plane expects paths longer than 1,024 bytes.
- **Walk-away.** Not applicable: these are in-process interfaces.

### 1.3 gnulib and coreutils: `chdir-long`, `openat` emulation, fts

- **Carried.** Still one long string at the API. Internally it becomes chunks plus
  descriptors.
  - [`chdir-long.c`](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/lib/chdir-long.c#L93-L106)
    "handles an arbitrarily long directory name by operating on manageable portions
    of the name". It `openat`s each PATH_MAX-sized chunk relative to the last one
    and fails "only if the specified directory name contains a component that is
    long enough".
  - gnulib fts in `FTS_CWDFD` mode keeps a "virtual working directory, maintained
    through the file descriptor member, fts_cwd_fd"
    ([`fts.in.h`](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/lib/fts.in.h#L170-L177)).
    coreutils forces `FTS_CWDFD` on every fts user.
- **Limit.** Total length is limited only by memory or `size_t`. A single component
  still fails at PATH_MAX.
- **Error.**
  - `ENAMETOOLONG` for an oversized component.
  - Where `openat` must be emulated, the fallback `save_cwd`/`fchdir` is
    process-global. If either step fails, it will "give a diagnostic and exit
    nonzero"
    ([`at-func.c`](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/lib/at-func.c#L63-L68)).
- **What went wrong over two decades.**
  - [CVE-2002-0435](https://cveawg.mitre.org/api/cve/CVE-2002-0435): the pre-fts
    recursive delete could "chdir to a '..' directory that is higher than expected,
    possibly up to the root file system".
  - [coreutils NEWS](https://github.com/coreutils/coreutils/blob/7fc7cf3a314b9177a2a3a0c86d62e0ba6f9ba12a/NEWS)
    lists a series of length bugs:
    - 5.1.0: `chmod -R` and related commands failed on relative names of PATH_MAX
      or more.
    - 8.0: `rm -r` was quadratic in depth.
    - 8.14: `pwd` failed past PATH_MAX/3 components without `openat`.
    - 9.11 (2026): `pwd` "will no longer overflow a buffer when operating in deep
      paths longer than twice the system PATH_MAX."
  - `cp -r` still builds full names. coreutils `TODO` says it "fails unnecessarily
    when the names become very long". In
    [bug#70586](http://www.mail-archive.com/bug-coreutils@gnu.org/msg34499.html),
    `rm -rf` succeeds where `cp -r` fails with "File name too long".
  - gnulib's
    [getcwd notes](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/doc/posix-functions/getcwd.texi)
    list the system `getcwd` as not handling names longer than PATH_MAX on
    "macOS 13" among others.
- **Walk-away.** Diagnostics print the full path string, so they stay legible.
  Nothing persists.

### 1.4 Linux: `openat2`, `O_PATH`, `/proc/self/fd`

- **Carried.** An fd (optionally `O_PATH`) plus a relative string. `openat2` adds
  `RESOLVE_BENEATH`/`RESOLVE_IN_ROOT` scoping
  ([openat2(2)](https://man7.org/linux/man-pages/man2/openat2.2.html)).
- **Limit.** PATH_MAX is 4,096. It is enforced on each user string
  ([v6.12 `fs/namei.c`](https://github.com/torvalds/linux/blob/v6.12/fs/namei.c#L200-L204)).
- **Converting an fd back to a string is bounded again.** `readlink("/proc/self/fd/N")`
  formats into a PATH_MAX buffer
  ([`fs/proc/base.c`](https://github.com/torvalds/linux/blob/v6.12/fs/proc/base.c#L1818-L1831)).
  This is the general lesson of the section: **fd designs turn back into strings at
  their boundaries, and the limit returns there.**
- **What went wrong.** Userspace resolvers kept getting it wrong.
  - The kernel commit adding scoped lookup calls them "prone to foot-guns" with
    "subtle security bugs" in "archive extraction tools, network file servers"
    ([fddb5d4](https://github.com/torvalds/linux/commit/fddb5d430ad9fa91b49b1d34d0202ffe2fa0e179)).
  - Example:
    [CVE-2018-15664](https://bugzilla.redhat.com/show_bug.cgi?id=1714722) (docker cp
    symlink exchange).
- **Walk-away.** An fd or `/proc/self/fd/N` string is valid only inside the
  process, while the fd is open.

### 1.5 Flatpak / xdg-desktop-portal

The portal is the closest Linux analogue to a launcher handing a document to another
application.

- **Carried.**
  - Across D-Bus, an fd: `OpenFile(parent_window, fd h, …)` and the Documents
    `Add(o_path_fd …)`
    ([OpenURI](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.OpenURI.html),
    [Documents](https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Documents.html)).
  - The portal immediately turns the fd back into a host path with
    `readlink("/proc/self/fd/%d")` into a `PATH_MAX + 1` buffer
    ([1.22.1 `xdp-app-info.c`](https://github.com/flatpak/xdg-desktop-portal/blob/1.22.1/src/xdp-app-info.c#L575-L600)).
  - Inside the sandbox, the app sees `/run/user/$UID/doc/$DOC_ID/<basename>`. Host
    depth collapses to a document id plus the basename
    ([`document-portal.c`](https://github.com/flatpak/xdg-desktop-portal/blob/1.22.1/document-portal/document-portal.c#L305-L322)).
- **Limit.** Host PATH_MAX, through the readlink. This is inferred from source; the
  docs say nothing about length.
- **What went wrong.**
  - [GHSA-rqr9-jwwf-wxgj](https://github.com/flatpak/xdg-desktop-portal/security/advisories/GHSA-rqr9-jwwf-wxgj)
    (2026-04-08): the trash portal acted "on a path which can traverse a client
    controlled directory tree, making it susceptible for TOCTOU symlink
    redirections". It was fixed by moving to fd-based operations.
  - The source also records a reversal from O_PATH-only fds to regular fds.
- **Walk-away.** The fd is meaningless outside the process. The document-id path
  exists only while the FUSE portal runs. The store keeps a legible host path, but
  its file-handle bytes are opaque.

### 1.6 Capsicum and WASI: capability designs

- **Capsicum.**
  - Carries dirfds plus *strictly relative* strings. "Access to global name spaces,
    such as file system or IPC name spaces, is prevented"
    ([cap_enter(2)](https://man.freebsd.org/cgi/man.cgi?query=cap_enter&sektion=2)).
  - Each argument is still bounded: FreeBSD
    [open(2)](https://man.freebsd.org/cgi/man.cgi?query=open&sektion=2) fails when
    "an entire path name exceeded 1023 characters", the same 1,024-byte wall as
    macOS.
  - The cost in real use was retrofitting. [D44373](https://reviews.freebsd.org/D44373)
    (2024, still in review) wants to avoid "wholesale refactoring to use *at()
    syscalls".
- **WASI.**
  - "All functions… take a pair of values: a base directory handle, and a relative
    path. Absolute paths are not permitted"
    ([path-resolution.md @90105ff](https://github.com/WebAssembly/WASI/blob/90105ffc2a4eed594909f9df2f473596500b49d2/proposals/filesystem/path-resolution.md)).
  - This is the one place an explicit **component array** appears. The manual host
    algorithm splits paths "into components", opens them "one component at a time"
    with `O_NOFOLLOW`, and prepends a symlink's components to the list. It is a
    *resolver's working state*, not something handed off.
  - What went wrong: resolver bugs, for example
    [RUSTSEC-2026-0269](https://rustsec.org/advisories/RUSTSEC-2026-0269.html)
    (title only verified: "Filesystem sandbox escape when paths or symlinks contain
    trailing slashes").
- **Walk-away.** Descriptors are process-local. WASI preopen names are legible
  strings.

### 1.7 Windows: three layers, three limits

- **File system API.**
  - Carries a UTF-16 string: `\\?\`-prefixed, or plain once the process opts in.
  - The 1607 opt-in needs *both* the `LongPathsEnabled` registry value *and* a
    `longPathAware` manifest. It covers a named list of file and directory functions
    only. "Relative paths are always limited to a total of MAX_PATH characters"
    ([Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)).
  - The same page states the split outright: "The shell and the file system have
    different requirements. It is possible to create a path with the Windows API
    that the shell user interface is not able to interpret properly."
  - Walk-away: a `\\?\` string stays a readable path.
- **NT native API.** This is the Windows `*at`.
  [`OBJECT_ATTRIBUTES`](https://learn.microsoft.com/en-us/windows/win32/api/ntdef/ns-ntdef-_object_attributes)
  takes a `RootDirectory` handle plus an `ObjectName` "relative to the
  RootDirectory directory". The relative name is bounded by `UNICODE_STRING`'s
  16-bit byte length. Go's `os.Root` uses exactly this (§1.8).
- **Shell.** This is where the component array lives, and it did not save the shell.
  - A PIDL is "an ordered sequence of one or more item IDs", each "only meaningful
    to the associated folder object"
    ([namespace intro](https://learn.microsoft.com/en-us/windows/win32/shell/namespace-intro)).
  - In 2007 a Microsoft BCL engineer explained that "Most of shell doesn't have to
    worry about path representation because they use … PIDLs", which let the shell
    add "auto path shrinking" with 8.3 aliases
    ([Kim Hamilton, BCL team](https://learn.microsoft.com/en-us/archive/blogs/bclteam/long-paths-in-net-part-1-of-3-kim-hamilton)).
  - But building a PIDL from a string is itself bounded:
    [`ILCreateFromPathW`](https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-ilcreatefrompathw)'s
    string "should be no more than MAX_PATH characters".
  - The ShellExecute docs are silent on length.
  - Explorer still refuses long paths with LongPathsEnabled set
    ([Microsoft Q&A, 2024](https://learn.microsoft.com/en-us/answers/questions/1615287/why-wont-microsoft-fix-file-explorer-in-windows-10)).
    The voidtools developer: "The Windows shell is still limited to 259 characters.
    (Even with LongPathsEnabled)"
    ([forum](https://www.voidtools.com/forum/viewtopic.php?t=10483)).
  - Jeremy Kuhne (Microsoft, 2016): "The Shell doesn't add support either, but
    previously had limited support utilizing 8.3 filename trickery"
    ([.NET 4.6.2 and long paths](https://learn.microsoft.com/en-us/archive/blogs/jeremykuhne/net-4-6-2-and-long-paths-on-windows-10)).
  - Walk-away: a PIDL is opaque binary, meaningless without the shell namespace
    extension that issued each item.
- **Process launch.**
  - "Setting a current directory longer than MAX_PATH causes CreateProcessW to fail"
    ([SetCurrentDirectory](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setcurrentdirectory)).
  - libuv (2025): "The CreateProcess API on Windows is still not longPathAware, even
    if the process itself is"
    ([#4684](https://github.com/libuv/libuv/issues/4684)). The fix substitutes an
    8.3 short name ([#4685](https://github.com/libuv/libuv/pull/4685)). Short names
    "can be disabled … system-wide or for a specified volume"
    ([Naming a File](https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file)),
    so this is a lossy alias that can silently fail to shorten.
  - Java closed the same failure as External
    ([JDK-8315405](https://bugs.openjdk.org/browse/JDK-8315405)).

**Real-use consequence.** Projects shipped around the shell limit rather than through
it.

- npm 3's flat install "will hopefully eliminate most cases where windows users ended
  up with paths that were too long for Explorer and other standard tools to deal
  with" ([v3.0.0](https://github.com/npm/npm/releases/tag/v3.0.0)).
- Git for Windows keeps `core.longpaths` "disabled by default, as long paths are not
  supported by Windows Explorer, cmd.exe and the Git for Windows tool chain"
  ([core.adoc @2734d89](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/Documentation/config/core.adoc)).
- MSBuild opted in, but "just because MSBuild works, doesn't mean your build will …
  devenv.exe … does not yet opt into support"
  ([msbuild#53](https://github.com/dotnet/msbuild/issues/53#issuecomment-459062618)).

### 1.8 Language runtimes

| Runtime | Carried | Over-limit route | Real-use failure | Walk-away |
| --- | --- | --- | --- | --- |
| Python | string; `dir_fd` on POSIX calls the `*at` variant ([os docs](https://docs.python.org/3/library/os.html)) | `shutil.rmtree`'s fd-based `_rmtree_safe_fd` | symlink attack [gh-48739](https://github.com/python/cpython/issues/48739) (2008, fixed 3.3); recursion still fails on deep trees [gh-89727](https://github.com/python/cpython/issues/89727) (open) | fd process-local |
| Rust | `&Path`; Windows `maybe_verbatim` adds `\\?\` ([1.85.0](https://github.com/rust-lang/rust/blob/1.85.0/library/std/src/sys/path/windows.rs)) | `remove_dir_all` via `openat`/`unlinkat`; `cap-std` `Dir` plus relative path | [CVE-2022-21658](https://blog.rust-lang.org/2022/01/20/cve-2022-21658/) TOCTOU in 1.0–1.58; still unfixable on macOS before 10.10, which lacked the openat family | handle process-local |
| Go | string; Windows `fixLongPath` adds `\\?\` ([go1.24.0](https://github.com/golang/go/blob/go1.24.0/src/os/path_windows.go)) | `os.Root` (1.24, [#67002](https://github.com/golang/go/issues/67002)): Unix `Openat`; Windows `NtCreateFile` with `RootDirectory` ([root.go](https://github.com/golang/go/blob/go1.24.0/src/os/root.go)) | long-path regression surfaced as "cannot find the path" [#64605](https://github.com/golang/go/issues/64605) | handle process-local |
| Java NIO | `Path` string | `SecureDirectoryStream`: "All access to the file is relative to the open directory" ([docs](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/nio/file/SecureDirectoryStream.html)) | **unavailable on macOS until JDK 24** ([JDK-8343020](https://bugs.openjdk.org/browse/JDK-8343020)) | stream process-local |
| Node/libuv | string; Windows `toNamespacedPath` | none for launch; cwd shortened via 8.3 ([libuv#4685](https://github.com/libuv/libuv/pull/4685)) | `fs.promises.realpath` ENOENT on a just-written long file [#51031](https://github.com/nodejs/node/issues/51031); module loader missed the prefix [#50753](https://github.com/nodejs/node/issues/50753) | readable string |

**Pattern.** The runtimes solve over-limit *file operations* with a handle plus a
relative name. None found offers an over-limit *launch* or *open-with-handler*. Where
they launch on Windows, they shorten the path.

### 1.9 git, rsync, tar

- **git on Unix.**
  - The index stores one slash-joined string per entry, with a 12-bit length field
    saturating at `0xFFF`
    ([gitformat-index @c46c1e3](https://github.com/git/git/blob/c46c1e37724f0478939de636ab8ea5a89086d532/Documentation/gitformat-index.adoc#L116-L133)).
  - Checkout opens by full path
    ([`entry.c`](https://github.com/git/git/blob/c46c1e37724f0478939de636ab8ea5a89086d532/entry.c#L106-L116)),
    so the OS limit for each call applies. That is inferred from source; no Unix bug
    report was found.
  - Historical overflows: [1.5.6.4](https://github.com/git/git/blob/c46c1e37724f0478939de636ab8ea5a89086d532/Documentation/RelNotes/1.5.6.4.adoc#L7-L9).
  - Walk-away: fully legible strings.
- **rsync.**
  - File-list names live in `MAXPATHLEN` buffers. An over-limit name is "skipping
    overly long name: %s", and the run exits nonzero
    ([v3.5.1 `flist.c`](https://github.com/RsyncProject/rsync/blob/v3.5.1/flist.c#L1644-L1648)).
  - 3.5.0 (2026) "fixes 33 security issues found during a focused audit of rsync's
    path handling" and moved I/O to an anchor fd with a held-fd stack
    ([NEWS](https://github.com/RsyncProject/rsync/blob/v3.5.1/NEWS.md)). Many of the
    issues were full-path `mkdir`/`opendir` TOCTOUs.
- **tar.**
  - The archive carries a legible string: a ustar `name`/`prefix`, or a pax `path`
    record that "shall override the name and prefix fields"
    ([pax](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/pax.html)).
  - libarchive chopped long names and `chdir`ed through them. Its maintainer then
    found "ENAMETOOLONG gets a free pass" through the symlink checks, a
    security hole. His conclusion: "It does not appear to be worth the trouble trying
    to work around PATH_MAX"
    ([libarchive#744](https://github.com/libarchive/libarchive/issues/744), 2016).
    Deep-directory support is now disabled when security checks are on
    ([v3.8.9](https://github.com/libarchive/libarchive/blob/v3.8.9/libarchive/archive_write_disk_posix.c#L2036-L2082)).
  - Walk-away: the best of all surveyed systems. Any tar, or `strings`, reads the
    path.

## 2. macOS hand-off to other processes

### 2.1 What the public hand-off formats carry

All are path strings or file URLs.

- Apple Events: SDK 27.0 `AEDataModel.h` defines `typeFileURL` as "a UTF-8 encoded
  full path".
- `typeAlias` and `typeFSRef` are "Deprecated; use typeFileURL or typeBookmark data
  to refer to files". Using them is *excluded: legacy opener*.
- Pasteboard: SDK 27.0 `NSPasteboard.h` uses `NSPasteboardTypeFileURL`, and
  `NSFilenamesPboardType` is deprecated in its favour.
- Receivers get URLs or paths. NSDocument apps get `openDocumentWithContentsOfURL:`
  and others get `application:openFiles:`
  ([How Cocoa Applications Handle Apple Events](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_handle_AEs/SAppsHandleAEs.html)).

So even if a launcher could submit a long location, every receiving application gets
a path or URL. It then faces the same 1,024-byte whole-path limit unless it walks
components itself. The surveyed editors (VS Code, Zed) and Electron shell APIs had no
issues on this; see [Silences](#silences).

- **Effective limit.** 1,023 bytes plus the NUL (§1.2).
- **Errors.**
  - SDK 27.0 `LSConstants.h` defines `kLSUnknownErr = -10810, //!< Unexpected
    internal error`. Launch Services has no length-specific code.
  - A Microsoft support page states Office for Mac's "Path limit measured in UTF-8
    bytes, not characters"
    ([file path length limits](https://support.microsoft.com/en-us/onedrive/what-are-file-path-length-limits)).
- **Walk-away.** A path or URL is fully legible.
- **Exclusion status.** Within mandate. Measured not to work at 1,024 bytes or more.

### 2.2 Bookmark data and security-scoped bookmarks

- **Carried.**
  - An opaque blob. SDK 27.0 `AEDataModel.h` defines `typeBookmarkData` as "the bytes
    of a CFURLBookmarkData".
  - Apple documents passing bookmarks between processes: "Your app can pass that
    bookmark to another process, like a launch agent or an XPC service"
    ([Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox)).
- **But resolution yields an `NSURL` again.** SDK 27.0 `NSURL.h` says
  `URLByResolvingBookmarkData:` "fails if the original file or directory could not
  be located". The receiver holds a path-based URL and is back at the wall.
- **Security-scoped bookmarks** require "the appropriate entitlements"
  (`NSURL.h`), so they are *needs new consent/entitlement*.
- **Long items.** No primary source says a bookmark can be created for, or resolved
  to, a location of 1,024 bytes or more.
- **Walk-away.** Opaque without CoreFoundation. A "last known path" is recoverable
  only through CF.
- **Exclusion status.** The plain format is within mandate but unevidenced for long
  items. Security-scoped variants need new consent.

### 2.3 File-reference URLs and volfs (`/.vol/<fsid>/<fileid>`)

- **File-reference URLs.**
  - "A file reference URL's path should never be persistently stored because it is
    not valid across system restarts and across remounts of volumes" (SDK 27.0
    `NSURL.h`).
  - Exclusion status: *excluded: file-reference/id URL*.
- **volfs.** This is the one public, *unentitled* kernel route that reaches long
  items. Apple's kernel test expects `open("/.vol/%d/%llu")` to succeed up to
  `MAXLONGPATHLEN - 1` (8,191) **even with the long-path policy off**:
  `SYSCALL_TEST(open_volfs, common_errno_on, common_errno_on)`
  ([longpaths.c @xnu-12377.1.9](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/tests/vfs/longpaths.c)).
- **Apple's stance on volfs.** Quinn "The Eskimo!" (Apple DTS): "Always use
  `fsgetpath` if it's available. volfs-style paths work just fine on legacy systems
  but we can't guarantee that they'll work forever"
  ([forum thread 103162](https://developer.apple.com/forums/thread/103162), 2018).
- **Unmeasured.** Whether NSWorkspace open, launch or reveal, Launch Services
  classification, or a receiving application accepts a volfs location. See
  [Host leads](#host-leads-not-evidence).
- **Costs.**
  - It is an id, not the location. It names whatever object holds that inode now.
  - It is meaningless after a reformat or fsid change and carries no name.
  - A receiving app would display and save against `/.vol/…`, not the user's path.
- **Walk-away.** A number pair with no name or hierarchy.
- **Exclusion status.** *excluded: file-reference/id URL*, and arguably
  *excluded: shortening*.

### 2.4 Path readers: `fsgetpath`, `getattrlist ATTR_CMN_FULLPATH`, `F_GETPATH`

- **`fsgetpath(2)`.**
  - Public since 10.13 (SDK 27.0 `sys/fsgetpath.h`). The man page allows `buflen` up
    to 8,192 (`EINVAL` "buflen is larger than 8192").
  - In
    [xnu-12377.1.9 `vfs_syscalls.c`](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/vfs/vfs_syscalls.c),
    `fsgetpath_extended` checks only `bufsize > MAXLONGPATHLEN` and builds the path
    with no long-path-policy check.
  - It is a *reader*: it returns a path that no opener accepts. Within mandate as a
    display/identity reader. This is consistent with the search design's existing
    public `fsgetpath` use.
- **`ATTR_CMN_FULLPATH`.** SDK 27.0 `getattrlist.2`: "The attribute data length will
  not be greater than PATH_MAX."
  [`vfs_attrlist.c`](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/vfs/vfs_attrlist.c)
  grows the buffer only when `proc_support_long_paths(p)`. So long results are
  *excluded: private policy*.
- **`F_GETPATH`.** The kernel test says "F_GETPATH must *not* consider the i/o
  policy". It expects `ENOSPC` from `MAXPATHLEN - 1` upward.
- **Walk-away.** Output paths are legible. The `(fsid, inode)` input is not.

### 2.5 The private long-path I/O policy

- **Definition.**
  [`resource_private.h`](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/sys/resource_private.h)
  defines `IOPOL_TYPE_VFS_SUPPORT_LONG_PATHS 13`.
  [`kern_resource.c`](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.1.9/bsd/kern/kern_resource.c)
  gates setting it on `"com.apple.private.vfs.support-long-paths"` and returns
  `EPERM` without it. Under the policy, whole-path calls work to 8,191 bytes
  (`common_errno_on`).
- **Exposure in SDK 27.0.**
  - The public `sys/resource.h` omits it ("Additional private I/O policies are in
    resource_private.h").
  - `setiopolicy_np.3` never mentions it.
  - `sys/attr.h` leaks the name in a comment and the `ATTR_MAX_BUFFER_LONGPATHS`
    macro, which does not compile from public headers.
- **When it appeared.** The private header and entitlement are absent at
  xnu-11215.81.4 and present from xnu-11417.101.15. Mapping that tag to a macOS
  release is inference; no Apple statement was found.
- **Exclusion status.** *excluded: private policy*. It also would not change
  *other* processes: Launch Services and the receiving application are separate
  processes without the entitlement.

### 2.6 XPC descriptor passing

- **Carried.** A descriptor: `xpc_fd_create` (SDK 27.0 `xpc/xpc.h`). It sidesteps
  path length for a *cooperating* peer, which can then use `openat`.
- **Limit.** No primary source shows Launch Services, Finder or third-party apps
  accepting a descriptor-based open request.
- **Exclusion status.** Within mandate only for Koine's own processes. It is not an
  opener.

## 3. Failure meaning: keeping "absent" apart from "too long"

### 3.1 How the signal is lost

It is lost when a higher layer translates the error. Once lost, layers above cannot
recover it.

- **Windows.** Eryk Sun (CPython triager): "STATUS_NAME_TOO_LONG (0xC0000106). This
  gets translated to … ERROR_PATH_NOT_FOUND (0x0003). The CRT error table reduces
  this to ENOENT, so it's not readily distinguishable from ERROR_FILE_NOT_FOUND"
  ([bpo-27729](https://bugs.python.org/issue27729)). That issue is still open. The
  reporter: "you get a FileNotFoundError but no explanation".
- **The same misreport recurs across runtimes.**
  - Python `os.scandir` gives `[WinError 3] The system cannot find the path
    specified` ([bpo-46084](https://bugs.python.org/issue46084)).
  - Go: [#64605](https://github.com/golang/go/issues/64605).
  - Node `realpath` gives ENOENT for a file just written
    ([#51031](https://github.com/nodejs/node/issues/51031)).
  - .NET gives `DirectoryNotFoundException` when the policy is off (Kuhne blog
    comments).
- **Dart returns a bare false.** "File.exists returns false if the file path is
  longer than MAX_PATH … the app will say that file does not exist (even though it
  actually does)" ([dart-lang/sdk#18649](https://github.com/dart-lang/sdk/issues/18649)).
- **rclone's maintainer on why a higher layer can't fix it.** "this is a message
  direct from the OS and as a consequence rclone can't tell that the error is
  because the path is too long. You might think that rclone could just count the
  characters … However that is hard to do correctly"
  ([forum](https://forum.rclone.org/t/display-warnings-for-paths-that-exceed-windows-path-length-limit/26608)).
- **The Windows shell folder picker** says "Path does not exist" for existing paths
  of 276–320 characters ([voidtools](https://www.voidtools.com/forum/viewtopic.php?t=10483)).

macOS has the same shape, and part of it is *documented contract*:

- **`urlForApplication(toOpen:)`.** "Returns `nil` if no app can open the URL, or if
  the file URL does not exist"
  ([Apple](https://developer.apple.com/documentation/appkit/nsworkspace/urlforapplication(toopen:)-7qkzf)).
  - Apple's contract therefore merges *no handler* and *missing*. k134 adds a third
    meaning, *too long*, to the same nil.
  - Field evidence: [hermes-agent#75011](https://github.com/NousResearch/hermes-agent/issues/75011)
    (macOS 26.5.2) found Electron's "No application found to open URL" meant "no
    such file".
  - [#122027](https://github.com/NousResearch/hermes-agent/issues/122027) (macOS
    26.6.1) hit the same class on another path. The remedy was to check existence
    before the call.
- **Distinct codes exist but are not returned.** SDK 27.0 defines `errFSNameTooLong`
  ("File/fork name is too long to create/rename") and `NSFileReadInvalidFileNameError
  = 258`. The measured APIs return `fnfErr` (-43, "File not found"),
  `NSFileReadUnknownError = 256` and `kLSUnknownErr`.

### 3.2 Tools that report truthfully decide length themselves

Truthful tools decide existence and length themselves, before the conflating call.

- **Git for Windows** checks length in its own path conversion. With `core.longpaths`
  off, it "fails with ENAMETOOLONG" itself
  ([`mingw.h` @2734d89](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/compat/mingw.h)),
  so users see "Filename too long", not "not found".
- **hermes-agent** checks existence before `shell.openExternal` (#122027).
- **The cost of self-checking is measuring in the right unit.**
  - IBM Spectrum Protect's Mac client wrongly refused names with "ANS4018E … file
    name too long" because of a UTF-8 byte-counting error
    ([APAR IT18841](https://ibm.com/support/pages/apar/IT18841)).
  - The rclone quote above makes the same point for UTF-16 versus UTF-8.
- **Messages drift when the policy changes.** Kuhne notes .NET's
  `PathTooLongException` text "isn't accurate" once long paths are enabled.

Koine's component-relative walk (k134) is already this pattern. It establishes
presence and cause independently of the conflating API.

### 3.3 Silent omission comes from walkers that ignore per-entry errors

- **Python `os.walk`.** It "ignores OSErrors raised by os.scandir()"; too-deep
  directories "can be treated as files" (Serhiy Storchaka, bpo-46084).
- **fd.** `find` counted 1,695 entries and `fd` counted 31, silently. The error shows
  only with `--show-errors`. The maintainer explained that "fd doesn't use `openat()`
  to avoid PATH_MAX issues" ([fd#1322](https://github.com/sharkdp/fd/issues/1322),
  open).
- **ripgrep.** It prints "File name too long (os error 36)" but finds 0 matches
  where `grep -r` finds 100. The maintainer calls the `openat` refactor "pretty low
  priority" ([ripgrep#3259](https://github.com/BurntSushi/ripgrep/issues/3259)).
- **walkdir.** "library shouldn't be changing process global state … `openat` seems
  like a better path" ([walkdir#23](https://github.com/BurntSushi/walkdir/issues/23)).
- **git clean before 2.23.** It "would abort without an error message, leaving the
  user quite puzzled" ([b09364c](https://github.com/git/git/commit/b09364c47a015dee7735fd2c038d7d710417c2f2)).
- **Dropbox on Windows.** A customer: "you do no sync it, and you do not inform the
  end user about it. In a shared folder setup, this is pretty disastrous"
  ([gist, 2014](https://gist.github.com/olov/8272581); customer report, *secondary*).
- **voidtools Everything delete.** Shift-Del silently did nothing on long paths,
  because `SHFileOperation` "is limited to 260 characters"
  ([forum](https://www.voidtools.com/forum/viewtopic.php?t=4468)).

In every case the fix that shipped was to *report the error* (a warning, `onerror`,
`--show-errors`), not to support long paths.

### 3.4 A truthful error can still stall or lose work

- **Syncthing.** A truthful "file name too long" stopped a whole folder ("All
  remaining files failed to sync") ([#767](https://github.com/syncthing/syncthing/issues/767)).
  Its own temporary-name prefix pushed legal names over the limit
  ([#1786](https://github.com/syncthing/syncthing/issues/1786)). It was fixed by
  hashing temporary names longer than 240 characters.
- **iCloud for Windows.** Before 10.8, one over-long name stopped every file in its
  folder from syncing ([Apple 101649](https://support.apple.com/en-qa/101649);
  version detail paraphrased).

## 4. Limits as designed behaviour

| Tool | Behaviour and wording | What users did | Source |
| --- | --- | --- | --- |
| Windows Explorer | "The file name(s) would be too long for the destination folder … You can shorten the file name and try again or try a location with a shorter path." | shorten; robocopy; zip, copy, extract | [Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/2579625/error-message-the-file-name(s)-would-be-too-long-f) |
| Win32 opt-in | off by default; two gates; "The shell and the file system have different requirements." | registry/GPO plus manifest | [Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation) |
| Git for Windows | `core.longpaths` off by default; "Only enable this if you know what you're doing and are prepared to live with a few quirks." | enable per repo | [core.adoc](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/Documentation/config/core.adoc) |
| .NET ≤ 4.6.1 | "The specified path, file name, or both are too long. The fully qualified file name must be less than 260 characters…" | rename or delete with another tool | [duplicati#3311](https://github.com/duplicati/duplicati/issues/3311) |
| GNU tar | "%s: file name is too long (max %d); not dumped": skipped *and named* | use the posix (pax) format | GNU tar 1.35 `src/create.c` |
| rsync | "skipping overly long name: %s", nonzero exit | — | [flist.c](https://github.com/RsyncProject/rsync/blob/v3.5.1/flist.c#L1644-L1648) |
| SharePoint/OneDrive | "can't contain more than 400 characters" | shorten | [service limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits) |
| Office for Mac | path limit "measured in UTF-8 bytes"; Office 2011 said "naming or permissions error" — the wrong cause | shorten folder names | [Microsoft support](https://support.microsoft.com/en-us/onedrive/what-are-file-path-length-limits), [Apple Community 2725087](https://discussions.apple.com/thread/2725087) |
| macOS generally | users report "a limit of 1023 characters for filepaths"; "OSX' interface is not prepared to handle what is allowed" | scripts to list offenders; `cd` and relative paths | Apple Community [250275651](https://discussions.apple.com/thread/250275651), [8115405](https://discussions.apple.com/thread/8115405) (user posts, *secondary*) |
| borg | truthful `[Errno 36] File name too long` | maintainer: mount at `/m`, or `cd` in and back up `.` | [borg#7794](https://github.com/borgbackup/borg/issues/7794) |

**Patterns.**

- Good refusals name the limit and the remedy (Explorer, tar's "max %d", Git's docs).
  Poor ones name the wrong cause (Office "naming or permissions", Win32 "path not
  found").
- The universal user workaround is **shortening**: move, rename, mount or `cd` closer.
  No surveyed tool automates a long-path hand-off to another application.

## Routes and their exclusion status

This is evidence for k135, not a selection.

| Route | Prior art | What the evidence says | Status |
| --- | --- | --- | --- |
| Directory-handle plus relative-name *inspection* (presence, cause, Info.plist read) | POSIX `*at`, fts, Go `os.Root`, Java SDS, Rust, Capsicum, WASI | The universal answer for in-process work; truthful causes. Apple Libc's fts says the kernel "won't resolve" long paths by whole path. | within mandate (k134 measured it) |
| Pass a component array to an opener | Windows PIDL; WASI resolver state | PIDLs are opaque and built from MAX_PATH strings; no opener found accepts components. | no macOS API found ([Silences](#silences)) |
| Pass an fd to the receiver | Flatpak portals, XPC | The receiver turns it back into a string (PATH_MAX+1 readlink); works only for cooperating peers. | within mandate for Koine's own helpers only; not an opener |
| Bookmark data | Apple sandbox hand-off | Resolves back to a path URL; no long-item evidence. | within mandate (format); unevidenced. Security-scoped: needs new consent |
| volfs `/.vol/<fsid>/<ino>` | Apple kernel test | The kernel opens it unentitled to 8,191; DTS says no guarantee "forever"; opener acceptance unmeasured; the receiver sees an id path. | excluded: file-reference/id URL (and shortening) |
| File-reference URL | — | Not persistent; unevidenced for long items. | excluded: file-reference/id URL |
| Symlink, alias or short name | libuv 8.3 cwd fix; Vista shell auto-shrinking | Lossy, can be disabled, can silently fail to shorten. | excluded: shortening |
| Private long-path policy | xnu, entitlement-gated | Lifts whole-path calls to 8,191 for the entitled process only; LS and receivers are other processes. | excluded: private policy |
| Legacy alias/FSRef Apple Events | — | Deprecated; FSRef measured -43 at long paths in k134. | excluded: legacy opener |
| Designed truthful refusal | Explorer, Git for Windows, tar, rsync, .NET ≤4.6.1, SharePoint | The mature tools' answer when the downstream layer cannot take the path. Best practice: decide length yourself, name the limit and the remedy, never report absence, never omit silently. | within mandate; a workflow loss needing Antony's decision |

**What the prior art adds to k134's recommendation.**

- A refusal is what mature systems ship where the *downstream* layer is the limit.
  Windows has lived with exactly this file-system/shell split since 2016.
- The failure modes to avoid are documented:
  - collapsing "too long" into "not found" (§3.1);
  - silent omission (§3.3);
  - a wrong self-measured unit (IBM);
  - a single long item stalling a batch (Syncthing).
- Whether to accept the loss is Antony's decision. This survey supplies no argument
  that the loss is acceptable for his workflows.

## Host leads (not evidence)

The macOS gatherer ran an unrequested, unentitled probe. It used macOS 26.6.2
(25G83), not k134's 26.5 VM, and a 1,573-byte tree in a session scratch directory.
That was outside this leaf's no-native-execution note. The probe is not retained in
the repository and is **not survey evidence**. It is listed only so k135 knows which
questions a VM run would settle:

- `bookmarkData()` on the long URL failed with "doesn't exist" (Cocoa 260).
- `fileReferenceURL()` returned nil.
- On the volfs path:
  - `stat` and reading succeeded;
  - `LSCopyItemInfoForURL` returned 0;
  - `urlForApplication(toOpen:)` returned TextEdit;
  - content type, parent and canonical-path resource keys failed.
- `fsgetpath` with an 8,192-byte buffer returned the exact 1,573-byte path.
- `F_GETPATH` and `ATTR_CMN_FULLPATH` returned `ENOSPC`.
- NSWorkspace open, launch and reveal with a volfs URL were **not** tried.

## Silences

Searches that found no primary source:

- **Finder, Spotlight (`mds`/`mdfind`), Quick Look, Time Machine.** No Apple
  documentation or tracker entry on locations of 1,024 bytes or more. Searched Apple
  Community, the developer forums, and error strings -43, -36, -8062 and -10810
  with "path".
- **NSWorkspace/Launch Services and length.** No report linking `selectFile` NO,
  error 256 or -10810 to path length. k134 is the only measurement found.
  Electron's showItemInFolder issue #44955 was closed without a repro.
- **Which descriptor type Launch Services puts in `odoc` today.** Archive docs say
  aliases; the SDK deprecates them.
- **`open(1)`.** Its man page says nothing about length.
- **VS Code, Zed, Electron/Chromium.** No issue about macOS paths of 1,024 bytes or
  more. VS Code's ENAMETOOLONG issues are argv-length or Linux name-length.
- **Relative URLs as a submission route.** No primary source on whether NSWorkspace
  or Launch Services resolve a relative file URL against the caller's working
  directory. Windows documents the opposite for its shell: relative paths stay
  limited to MAX_PATH.
- **Windows shell launch by PIDL.** No primary source on whether
  `ShellExecuteEx` with `SEE_MASK_IDLIST` opens a document deeper than MAX_PATH.
  Also silent: `SHParseDisplayName`/`SHCreateItemFromParsingName` with `\\?\`,
  `IFileDialog`, and `AssocQueryString` at long paths. A third-party author reports
  Creators Update made deep shell items work but not document opening
  ([zabkat](https://www.zabkat.com/blog/max-path-programmers-cookbook.htm),
  *secondary*).
- **Microsoft's rationale or timeline for Explorer.** Latest engineer statement
  found: Kuhne, 2017.
- **Backup vendors on the macOS limit.** Backblaze, Carbon Copy Cloner, Arq,
  Dropbox and Google Drive. A Backblaze "1000 characters" figure appeared only in a
  search snippet; the KB page returned 403.
- **GNU tar extraction and git checkout at or over PATH_MAX on Unix.** Behaviour
  inferred from source only.
- **The long-path policy.** No Apple publication: docs, release notes or forum
  posts.
- **POSIX on PATH_MAX and depth.** No normative sentence saying PATH_MAX does not
  bound filesystem depth. Only the `limits.h` rationale quoted in §1.1.
