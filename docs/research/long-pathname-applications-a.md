# Long pathnames in real applications (survey a)

**Short answer.** Across file managers, editors, launchers, build tools,
archivers, backup and sync tools, and network and virtual file systems, real
systems handle over-limit pathnames in three distinct places. Only the first
was found to work past the limit:

1. **Inside one process.**
   - **The mechanism.** These systems stop handing the kernel a whole string. They
     hold a directory (a cwd, a per-thread cwd or a descriptor) and pass it one
     component or a short suffix.
   - **Who does it.** gnulib/coreutils fts, libarchive (macOS's own `tar`, using
     Apple's per-thread cwd), GNU tar's create walk, Borg's create walk, low-level
     FUSE daemons, and the descriptor walks in Rust, Go and Python.
   - **What remains.** The whole-path limit is gone, but the root is still opened
     by string, and every one of them rebuilds the full string for names,
     messages or replay.
2. **Between cooperating ends of a protocol.**
   - **Arrays of components.** NFS (one segment per LOOKUP, arrays in COMPOUND
     and referrals), 9P (`Twalk` with up to sixteen names per message) and the
     FUSE kernel protocol (node plus one name) carry them.
   - **The answer to "do they have to use an array of paths?"** Yes, there, by
     design: both ends cooperate and the receiving end walks by handle.
   - **Plain strings by choice.** SFTP and SMB carry whole strings.
3. **At a handoff to an arbitrary opener.** Every sourced system rebuilds a full
   string here, or substitutes a short alias:
   - Launch Services and Apple Events take a file URL.
   - Desktop entries take `%f`/`%u` in argv.
   - D-Bus `Open` takes a URI array.
   - ShellExecute takes a string.
   - Linux's document portal accepts a *descriptor* but immediately reads its path
     back through a PATH_MAX buffer.

   **No surveyed system delivers an over-limit location unchanged to a
   path-taking third-party opener.** What they do instead:
   - **Short aliases.** Shorter virtual paths (Linux document portal, Windows
     drive letters and junctions), hashed or flattened layouts (CMake, Bazel,
     npm, pnpm), and 8.3 names.
   - **Refusal, skipping or session abort.** macOS `cp`, rsync, OneDrive, Dropbox,
     iCloud.
   - **Misreported failure.** Emacs on Windows says "no such file", Vim says
     "Illegal file name", KDE says "file not found".
   - **Silent truncation.** Info-ZIP.
   - **Silent reveal failure.** Electron and Zed discard Finder's NO.

**Windows tells the same story with better documentation.** The file APIs were
opened to about 32,767 UTF-16 units in 2016, but:

- **Process creation.** Executable paths and working directories longer than
  MAX_PATH still fail at `CreateProcess` (Go, Git for Windows, Rust,
  Windows Terminal).
- **The shell.** `cmd.exe` rejects the long-path prefix (Bazel). Explorer does not
  opt in (Microsoft's OneDrive documentation).

**On macOS, the public route to long names is ID-shaped.** xnu has a long-path
mode up to 8,192 bytes, set only with a private entitlement. Its legacy
`/.vol/<fsid>/<fileid>` lookup expands an id to a long path without that
entitlement. Both reach long names only through mechanisms Koine's mandate
excludes. No source shows that Launch Services, NSWorkspace or Finder use
either. Microsoft's sync documentation independently lists "macOS Finder 1,024
characters".

**This is bounded evidence, not universal impossibility.** Launch Services and
Finder are closed source. Silences are recorded below rather than filled in.
This survey selects no route and changes no requirement.

This is the research-a half of the independent pair commissioned by
`long-action-route-k137` for returned design `long-action-route-k141`. The Koine
question, measurements and exclusions are in:

- the [route evaluation](../verification/long-action-route.md);
- the [prototype](../verification/long-action-route-prototype.md): 1,023 bytes
  passes, 1,024 fails at submission, classification, registration and lookup,
  while parent-relative POSIX calls reach the roughly 1,500-byte subjects;
- the [native boundary](../verification/long-action-native-boundary.md).

## How this survey was made

- **When.** Gathered 2026-10-04, read-only. No native probe was built or run, and
  no long path was created.
- **Breadth.** Four gatherers worked in parallel, one per use-case family. Each
  returned pinned citations. This session then re-fetched the load-bearing
  quotes and line anchors and checked them against the pinned text.
  - **Pinned sources.** GitHub raw files at a full commit SHA or release tag,
    Savannah cgit at a tag, RFC and 9P manual text, and Microsoft, Apple,
    Dropbox and pnpm documentation pages.
  - **Issue APIs.** GitHub, GNOME GitLab and Qt JIRA.
  - **Local SDK.** `LSConstants.h` in the local macOS 27.0 SDK.
- **Independence.** The other survey of this pair was not read. The earlier
  [prior-art survey](prior-art-long-paths-a.md) was used only as a list of
  leads. Every claim here was sourced afresh, and this survey's question is
  different: what real applications do, rather than which APIs exist.
- **Labels.** Each claim is labelled by kind of evidence. A labelled link such
  as "(N)" after a citation applies to that claim.

| Label | Meaning |
| --- | --- |
| **N** (normative) | A documented or specified promise, or behavior stated in pinned source. |
| **O** (observed) | An issue report, maintainer statement, test report or vendor field note. |
| **I** (inference) | This survey's reading of source or documentation, not executed. |

- **Walk-away check.** For each system: with the tool uninstalled, what remains
  legible?
- **Units.** These are not interchangeable:
  - **macOS.** `PATH_MAX` 1,024 *bytes including NUL*, and `NAME_MAX` 255 bytes
    ([syslimits.h](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/sys/syslimits.h#L103-L111)).
  - **Linux.** 4,096 bytes including NUL, and 255 per component
    ([limits.h](https://github.com/torvalds/linux/blob/v6.12/include/uapi/linux/limits.h#L12-L13)).
  - **Windows.** 260 *UTF-16 units* including NUL, or about 32,767 with `\\?\`
    ([Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)).
  - **Applications.** They add their own limits: Vim's `MAXPATHL`, Apple fts's
    65,535-byte `fts_path`, Git for Windows's 4,096 units, OneDrive's 400
    "decoded" characters.

**Mandate labels**, used in [Applicability to Koine](#5-applicability-to-koine):

| Label | Meaning |
| --- | --- |
| within mandate | Usable under the current public-API, signing and consent posture. |
| excluded: shortening | A shorter alias, link, mapping, hash or relocated copy. |
| excluded: id-spelled | An id or reference spelling submitted in place of the location. |
| excluded: private | A private entitlement, SPI or policy. |
| needs new decision | A new consent, legacy opener or contract change that only Antony can authorize. |

## 1. File managers, editors and document launch

### 1.1 macOS: Launch Services, NSWorkspace, Apple Events, Finder

| Stage | Evidence |
| --- | --- |
| Ingress | NSWorkspace open/launch takes `[URL]` and an application URL ([open(_:withApplicationAt:…)](https://developer.apple.com/documentation/appkit/nsworkspace/open(_:withapplicationat:configuration:completionhandler:)), N). No length is documented. `open(1)` resolves relative arguments against the shell's working directory (local `man 1 open`, N). |
| Wire | An Apple DTS engineer builds `odoc` events from `NSAppleEventDescriptor(fileURL:)` ([forum 751810](https://developer.apple.com/forums/thread/751810), O). That descriptor "stores the specified file URL" ([init(fileURL:)](https://developer.apple.com/documentation/foundation/nsappleeventdescriptor/init(fileurl:)), N). Whether Launch Services itself always sends a file URL rather than an alias or bookmark: no primary source found. |
| Consumer | AppKit delivers `[URL]` to `application(_:open:)`, which suppresses `openFile(s):` ([docs](https://developer.apple.com/documentation/appkit/nsapplicationdelegate/application(_:open:)), N). Older apps receive `NSString` paths. The receiver gets a full location, never a handle or parent descriptor (I). |
| Errors | `kLSUnknownErr = -10810, //!< Unexpected internal error` (local SDK 27.0 `LSConstants.h`, N). k134's long registration failure carries this unspecific code, not a length error. |
| Reveal | `selectFile(_:inFileViewerRootedAtPath:)` returns a bare Bool. `activateFileViewerSelecting(_:)` returns nothing ([selectFile](https://developer.apple.com/documentation/appkit/nsworkspace/selectfile(_:infileviewerrootedatpath:)), [activateFileViewerSelecting](https://developer.apple.com/documentation/appkit/nsworkspace/activatefileviewerselecting(_:)), N). Neither can report a cause. |
| Ids | Apple's File System Programming Guide describes bookmarks as opaque data that re-create a URL ([guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html), N). Apple says "Under no circumstances should your application construct paths within "/.vol"" ([QA1113](https://developer.apple.com/library/archive/qa/qa2001/qa1113.html), N). The kernel's volfs and long-path facts are in [section 4.7](#47-macos-identifiers-and-descriptors). |

Microsoft's OneDrive page lists "macOS Finder 1,024 characters" and macOS Office
"1024 bytes (1024 UTF8-encoded bytes)" ([OneDrive limits](https://support.microsoft.com/en-us/onedrive/what-are-file-path-length-limits), N/vendor).
This is an independent product statement of the ceiling k134 measured. It
explains no mechanism.

**Walk-away.** Inputs and outputs are plain URLs. Bookmarks and file-reference
URLs are opaque.

**Unanswered.**

- What Launch Services sends in `odoc` today.
- Whether it accepts a file-reference or `/.vol` URL.
- Whether bookmark resolution yields a usable 1,500-byte URL.
- No Apple document or DTS post stating a Launch Services or Finder whole-path
  limit was found.

### 1.2 Zed: a private channel for documents, Launch Services for the app

Zed's CLI keeps document paths away from Launch Services:

1. It canonicalizes the argument. If that fails, it walks up to an ancestor that
   canonicalizes and re-appends the rest, because "many zed crates assume
   absolute paths" ([cli/main.rs](https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/cli/src/main.rs#L158-L200), O).
   On macOS, `realpath` fails with ENAMETOOLONG past PATH_MAX, so a long argument
   takes that fallback (I).
2. It launches or activates the app with `LSOpenFromURLSpec`, passing only a
   short `zed-cli://{server_name}` URL ([main.rs](https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/cli/src/main.rs#L586),
   [L1381-L1408](https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/cli/src/main.rs#L1381-L1408)).
3. It sends paths over its own IPC as `CliRequest::Open { paths: Vec<String>, … }`
   ([cli.rs](https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/cli/src/cli.rs#L56-L60)).

This is the clearest surveyed example of a cooperating-receiver side channel on
macOS. It moves the document location *out* of Launch Services and *into* Zed.
Two limits remain:

- **Inside Zed.** Its file I/O uses Rust std, which passes the whole string to
  `open` ([std fs/unix.rs](https://github.com/rust-lang/rust/blob/4ddbc06ea09abcda34f80baf31cc9bc2686b0ae6/library/std/src/sys/fs/unix.rs#L1207-L1222)).
  So opening a 1,500-byte document would fail inside Zed (I).
- **For the app bundle.** The bundle URL still goes through Launch Services.

**Reveal and default open in Zed.**

- `reveal_path` discards Finder's result with `let _: BOOL = …`.
- `open_with_system` runs `open -- <path>` and only logs the exit status
  ([gpui_macos platform.rs](https://github.com/zed-industries/zed/blob/a84689073d296dfd39987bc7dd478e43ef76d83a/crates/gpui_macos/src/platform.rs#L1020-L1056), O).

No Zed issue about whole-path length was found.

### 1.3 Electron and VS Code

- **Electron on macOS.**
  - **Reveal.** `ShowItemInFolder` calls `selectFile`. On NO it only logs
    "NSWorkspace failed to select file" ([platform_util_mac.mm](https://github.com/electron/electron/blob/df79406cecfd393f38d5a18b83379d4ba85cc29b/shell/common/platform_util_mac.mm#L87-L110), O).
    So `shell.showItemInFolder` fails without a caller-visible error.
  - **Open.** `OpenPath` returns "Failed to open path".
- **Electron on Windows.** Reveal parses the full string into a PIDL
  ([platform_util_win.cc](https://github.com/electron/electron/blob/df79406cecfd393f38d5a18b83379d4ba85cc29b/shell/common/platform_util_win.cc#L270-L310)).
- **A long-path report** ([#42634](https://github.com/electron/electron/issues/42634), O).
  Images under paths of 260 or more were not shown while `fs.existsSync` worked.
  A maintainer said "you should be able to include `longPathAware` in your
  manifest. This is not something included by default". The reporter shipped
  8.3 short names instead.
- **VS Code.**
  - **Ingress.** It takes `open-file` paths, NFC-normalizes them and wraps them as
    `URI.file` ([app.ts](https://github.com/microsoft/vscode/blob/4a86ed331f5433b773e307408ad05cee9fa12985/src/vs/code/electron-main/app.ts#L622-L629)).
  - **Second instances.** A second `code` process forwards its arguments as
    strings over the main IPC socket ([main.ts](https://github.com/microsoft/vscode/blob/4a86ed331f5433b773e307408ad05cee9fa12985/src/vs/code/electron-main/main.ts#L390-L467)).
  - **Search on Windows** ([#116303](https://github.com/microsoft/vscode/issues/116303), O, open):
    - It misses files with long paths even with `LongPathsEnabled`, because the
      out-of-process ripgrep fails.
    - The in-process editor opens the same files.
    - The maintainer's interim advice is a symlink or junction, or moving the
      repository closer to the drive root ([comment](https://github.com/microsoft/vscode/issues/116303#issuecomment-938845352)).
      That is a user-made short alias.

### 1.4 Vim and Emacs: refusal, truncation, misreporting

- **Vim's own limit.** `MAXPATHL` is PATH_MAX on Unix, or 1,024 if PATH_MAX is
  absent or small ([os_unix.h](https://github.com/vim/vim/blob/6d862f58dd6d51b292dd26ae658b02fb1e691ca5/src/os_unix.h#L390-L395)).
  - **Refusal.** `readfile` refuses `fnamelen >= MAXPATHL` with "Illegal file
    name" before any system call ([fileio.c](https://github.com/vim/vim/blob/6d862f58dd6d51b292dd26ae658b02fb1e691ca5/src/fileio.c#L350-L358), N).
  - **Truncation.** `vim_FullName` falls back to copying the name "truncate when
    too long" ([filepath.c](https://github.com/vim/vim/blob/6d862f58dd6d51b292dd26ae658b02fb1e691ca5/src/filepath.c#L4419-L4441), N).
    A stored buffer name can be a wrong, shortened path.
- **Emacs on Unix.** File names are unbounded Lisp strings passed whole to
  `openat(AT_FDCWD, …)` ([fileio.c](https://github.com/emacs-mirror/emacs/blob/b5929c4b00b2f2a88d3d8eddd0cf3011ee8ed12c/src/fileio.c#L3224)),
  so the kernel limit applies (I).
- **Emacs on Windows.** It converts names into a `MAX_PATH` UTF-16 buffer and maps
  `ERROR_INSUFFICIENT_BUFFER` to `ENOENT` ([w32.c](https://github.com/emacs-mirror/emacs/blob/b5929c4b00b2f2a88d3d8eddd0cf3011ee8ed12c/src/w32.c#L1764-L1789), N).
  So an over-limit file is reported **as missing**. This is exactly the
  conflation the reviewed Koine boundary forbids.

### 1.5 GLib, Nautilus and freedesktop launch

- **Representation.** A `GLocalFile` is one `char *filename`. Command-line
  arguments are made absolute with `g_build_filename(current_dir, arg)`
  ([glocalfile.c](https://github.com/GNOME/glib/blob/36c60f069c6f3776dafc7f6ce18c8c0b606cd8b5/gio/glocalfile.c#L113-L118),
  [gfile.c](https://github.com/GNOME/glib/blob/36c60f069c6f3776dafc7f6ce18c8c0b606cd8b5/gio/gfile.c#L7658-L7685), N).
- **The consequence has been open since 2017.** "gio cannot handle files in
  directories with strlen(realpath(..)) > PATH_MAX". The report adds that "*All*
  other tools I have at hand manage to handle this situation", because they stay
  relative ([GLib #1245](https://gitlab.gnome.org/GNOME/glib/-/issues/1245), O).
  Making a working relative name absolute turns success into ENAMETOOLONG.
- **One descriptor island.** `g_file_measure_disk_usage` walks with
  `openat`/`fstatat` and keeps a component list only to rebuild names for error
  messages ([glocalfile.c](https://github.com/GNOME/glib/blob/36c60f069c6f3776dafc7f6ce18c8c0b606cd8b5/gio/glocalfile.c#L2981-L2997), N).
- **Launch.**
  - Desktop entries expand `%f` to `g_file_get_path` and `%u` to the URI,
    shell-quoted into argv ([gdesktopappinfo.c](https://github.com/GNOME/glib/blob/36c60f069c6f3776dafc7f6ce18c8c0b606cd8b5/gio/gdesktopappinfo.c#L2505-L2527), N).
  - The spec copies *non-local* files to a temporary local file for `%f`
    ([Exec variables](https://specifications.freedesktop.org/desktop-entry/latest/exec-variables.html), N).
  - D-Bus activation sends "an array of URIs, in UTF-8" ([D-Bus activation](https://specifications.freedesktop.org/desktop-entry/latest/dbus.html), N).
  - Linux argv accepts a single string up to `MAX_ARG_STRLEN` (32 pages), so the
    *receiver's* `open` is where an over-limit path fails (I).
- **Nautilus.** It models a file as a parent directory plus a name, but the
  parent is a whole-path `GFile`. It launches with `g_app_info_launch(_uris)`
  ([nautilus-file-private.h](https://github.com/GNOME/nautilus/blob/e209864bccc239392dc138cfc874748957fea4b1/src/nautilus-file-private.h#L27-L31),
  [nautilus-program-choosing.c](https://github.com/GNOME/nautilus/blob/e209864bccc239392dc138cfc874748957fea4b1/src/nautilus-program-choosing.c#L140-L183)).
  No Nautilus PATH_MAX issue was found.

### 1.6 KDE and Qt: a maintainer's explicit rejection of descriptors

- **The decision.** Qt closed "QFileSystemModel fails to display or access paths
  exceeding PATH_MAX" as Won't Do ([QTBUG-138251](https://bugreports.qt.io/browse/QTBUG-138251), O/maintainer).
  Its maintainer gave three reasons:
  - "You can't do file-descriptor-based API on Windows and a lot of Qt API assumes
    that paths can be resolved fully."
  - "Keeping file descriptors open behind the user's back is also going to cause
    fd exhaustion pretty soon."
  - "Please file issues where an operation mishandled ENAMETOOLONG."

  This is the clearest published statement of the trade-off: whole-path API
  portability and descriptor budget against reachability, with truthful errors as
  the obligation that remains.
- **A KDE report.** Dolphin, KWrite and Gwenview report an over-limit existing file
  as "file not found" or "corrupt" ([KDE 506659](https://bugs.kde.org/show_bug.cgi?id=506659), O,
  unconfirmed).
- **kio-fuse.** It exposes remote URLs to non-KDE applications as local paths
  under a runtime mount ([README](https://github.com/KDE/kio-fuse/blob/4ff9006755050f63d831dbde53878f4e9e1c9d6b/README.md#L100-L101)).
  Its mapping *adds* a prefix ([section 4.8](#48-urls-and-kio)).

### 1.7 Windows shell, Explorer and process launch

- **What the shell carries.**
  - **PIDLs.** An item ID list is "an ordered sequence of one or more item IDs"
    whose bytes are "only meaningful to the associated folder object"
    ([namespace](https://learn.microsoft.com/en-us/windows/win32/shell/namespace-intro), N).
    This is the one *shell* component sequence found.
  - **Converting back to a path.** `SHGetPathFromIDListW` requires a buffer "at
    least MAX_PATH characters in size" ([docs](https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetpathfromidlistw), N).
    `SHGetPathFromIDListEx` adds a length and a short-name option.
  - **ShellExecute.** `SHELLEXECUTEINFO` can identify the target by PIDL
    ([docs](https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-shellexecuteinfow), N).
    The handler is still started with a command line (I).
- **Launch.**
  - `CreateProcessW` limits the module part to MAX_PATH when `lpApplicationName`
    is null ([docs](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw), N).
  - A Windows Terminal maintainer: "`CreateProcessW` does not work for a working
    directory that is longer than `MAX_PATH` … through the labyrinth that is
    `ShellExecute`" ([terminal#19058](https://github.com/microsoft/terminal/issues/19058#issuecomment-3029093394), O).
- **Short names.** `GetShortPathNameW` may "succeed, but … return the long-name
  path" when no short name exists, as on ReFS or NTFS with short names off
  ([docs](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getshortpathnamew), N).
- **Explorer.**
  - No Microsoft staff statement of its numeric limit was found.
  - Microsoft's OneDrive page says "File Explorer doesn't use" the long-path policy.
  - PowerRename was observed pushing files past what Explorer can reach
    ([PowerToys #8748](https://github.com/microsoft/PowerToys/issues/8748), O).

### 1.8 Family conclusion

Every launcher, file manager and editor surveyed delivers documents to another
process as a whole location: a file URL, an argv path, a D-Bus URI or a
ShellExecute string. The receiving application re-imposes its own limit.

The closest thing to an over-limit handoff is a short substitute: a
user-created junction, an 8.3 name, or the Linux portal's virtual path. Zed's
side channel removes Launch Services from the *document* path but not from
Zed's own I/O or its bundle.

Over-limit failures are commonly misreported as absence ("file not found",
`ENOENT`, "Illegal file name") or swallowed on reveal.

## 2. Build, package and repository tools

Windows dominates this family's record. Its build tools fixed their own file I/O
years ago, and the record shows exactly where that fix stops. The baseline is
Microsoft's [Maximum Path Length Limitation](https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation)
page (N):

- **Units.** MAX_PATH is 260 UTF-16 units, including the terminating NUL.
  Directory creation allows MAX_PATH minus 12 (248). A `\\?\` prefix allows about
  32,767 units, but "you cannot use the "\\?\" prefix with a relative path".
- **The opt-in.** From Windows 10 1607, a registry value *and* a `longPathAware`
  manifest lift the limit for a listed set of file and directory functions.
  `CreateProcessW` and the ShellExecute family are not in that list.
- **Shell versus file system.** "It is possible to create a path with the
  Windows API that the shell user interface is not able to interpret properly."

### 2.1 git (upstream, POSIX)

| Stage | Evidence |
| --- | --- |
| Representation | Tree objects store one component per entry. The index stores full repository-relative byte strings. Its 12-bit length field saturates at 0xFFF and the reader falls back to `strlen` ([index format](https://github.com/git/git/blob/8103b446517e0c44e67561b9d0ccce56efa60a71/Documentation/gitformat-index.adoc#L116-L117), N). |
| Traversal | git `chdir`s to the worktree root ([setup.c](https://github.com/git/git/blob/8103b446517e0c44e67561b9d0ccce56efa60a71/setup.c#L1207-L1208)). Checkout then builds `base_dir + ce->name` and calls whole-string `mkdir`, `lstat` and `open` on that relative string ([entry.c](https://github.com/git/git/blob/8103b446517e0c44e67561b9d0ccce56efa60a71/entry.c#L19-L57)). No `openat` walk appears in checkout (I). |
| Limit | The kernel limit applies to the worktree-relative string, not the absolute path: about 4,095 bytes on Linux and 1,023 on macOS (I). Only special inputs are refused, for example `$GIT_DIR` above PATH_MAX−40 ([setup.c](https://github.com/git/git/blob/8103b446517e0c44e67561b9d0ccce56efa60a71/setup.c#L1141-L1142)). |
| Boundary | Hooks, filters and external diff tools receive full strings in argv and the environment (I). |

git has one deliberate cwd trick. A unix-socket address (`sun_path`, about 104
bytes on macOS) is far shorter than PATH_MAX. `unix_sockaddr_init` therefore
`chdir`s into the socket's parent and binds the basename, and the source admits
the cost: "since we have moved the cwd of the whole process … We are better off
to just die" ([unix-socket.c](https://github.com/git/git/blob/8103b446517e0c44e67561b9d0ccce56efa60a71/unix-socket.c#L24-L77)).
That is a cwd-relative workaround for a *protocol* limit, paid for with
process-global state.

Observed failures on POSIX are per-component, not whole-path. One example is a
UTF-8 Thai file name over 255 bytes on Linux ([actions/checkout#923](https://github.com/actions/checkout/issues/923), O).
No primary report of a whole-path checkout failure on Linux or macOS was found.

**Walk-away.** The worktree holds plain paths and a tree object is a readable
component list. Nothing is hashed or flattened.

### 2.2 Git for Windows: `core.longpaths`

- **Mechanism.** At the I/O shim, `handle_long_path` turns a path into an absolute
  `\\?\` or `\\?\UNC\` form when it would exceed MAX_PATH ([mingw.c](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/compat/mingw.c#L4217-L4282)).
- **Its own cap.** The buffers stop at `MAX_LONG_PATH 4096` UTF-16 units, "to
  limit required stack memory", not at NTFS's 32,767 ([mingw.h](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/compat/mingw.h#L83-L88)).
- **The spawn boundary refuses.** "Paths to executables and to the current
  directory do not support long paths" ([mingw.c](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/compat/mingw.c#L2296-L2303)).
  So a hook or helper whose executable or working directory is long fails.
- **Off by default.** The documented reason: "long paths are not supported by
  Windows Explorer, cmd.exe and the Git for Windows tool chain (msys, bash, tcl,
  perl...)" ([core.adoc](https://github.com/git-for-windows/git/blob/2734d898d3517f86af2915a721c356e5987a42ee/Documentation/config/core.adoc#L738-L743), N).
  A maintainer also measured "3-4% to the runtime" ([#2641](https://github.com/git-for-windows/git/issues/2641#issuecomment-2422999866), O).
- **Bootstrap catch-22.** If the config file sits on a long path, git cannot
  read the setting that would let it read long paths ([#3372](https://github.com/git-for-windows/git/issues/3372#issuecomment-901895831),
  [#2576](https://github.com/git-for-windows/git/issues/2576#issuecomment-610589004), O).

**Walk-away.** The files are plain NTFS paths that Explorer and the bundled shell
cannot reach.

### 2.3 npm and pnpm: changing the tree instead

- **npm.** npm 3 installed dependencies "*maximally flat*". The changelog says
  this should "eliminate most cases where Windows users ended up with paths that
  were too long for Explorer and other standard tools" ([CHANGELOG-3](https://github.com/npm/cli/blob/v6.14.18/changelogs/CHANGELOG-3.md#L5117-L5128), N).
  - **Node could already cope.** "Node.js does, in fact, support long Windows
    paths. Unfortunately … a lot of external tooling does not … some (all?)
    versions of Windows Explorer *can literally never delete npm*" ([same file](https://github.com/npm/cli/blob/v6.14.18/changelogs/CHANGELOG-3.md#L2402-L2421)).
  - **The users' failures were downstream.** The consumers they reported failing
    were `DEL`, CLOC, `git clean` and MSBuild ([npm#3697](https://github.com/npm/npm/issues/3697#issuecomment-34394290), O).
- **pnpm.** pnpm hard-links package files from a content-addressed store and
  builds the dependency graph with symlinks ([docs](https://pnpm.io/symlinked-node-modules-structure), N).
  - **Truncation plus hash.** Virtual-store directory names longer than
    `virtualStoreDirMaxLength` (120 on Linux/macOS, 60 on Windows, in UTF-16
    units) are truncated and given a hash suffix ([deps/path](https://github.com/pnpm/pnpm/blob/bac8077715ac5af3857b1df970a014875d89b86c/pnpm11/deps/path/src/index.ts#L261-L281); [settings](https://pnpm.io/settings/node-modules), N).
  - **A short root.** The docs suggest putting the virtual store at a drive root
    for very long paths.

These remove the limit for *every* downstream consumer by never producing the long
path. The price is legibility, or nesting that returns on version conflicts. That
is shortening in Koine's terms.

### 2.4 CMake and Bazel: hashing before the spawn

- **CMake object paths.** CMake shortens an object path that would exceed
  `CMAKE_OBJECT_PATH_MAX` by replacing its leading directory part with an MD5
  ([docs](https://cmake.org/cmake/help/latest/variable/CMAKE_OBJECT_PATH_MAX.html), N).
  - The built-in limit is 250 on Windows and 1,000 elsewhere, in `std::string`
    bytes. 1,000 sits under macOS's 1,024 ([cmLocalGenerator.cxx](https://github.com/Kitware/CMake/blob/5595ef72a927144c1a9346b482403efb1ddccb1d/Source/cmLocalGenerator.cxx#L315-L322)).
  - If the object *directory* alone is already too deep, CMake only warns: "The
    build may not work correctly" ([L4374-L4391](https://github.com/Kitware/CMake/blob/5595ef72a927144c1a9346b482403efb1ddccb1d/Source/cmLocalGenerator.cxx#L4374-L4391),
    [L4535-L4556](https://github.com/Kitware/CMake/blob/5595ef72a927144c1a9346b482403efb1ddccb1d/Source/cmLocalGenerator.cxx#L4535-L4556)).
- **CMake's own I/O.** `cmake.exe` is itself long-path aware. The compiler it
  spawns may not be, which is why the name handed to it is shortened.
- **Bazel's output base.** Bazel names the output base by the MD5 of the
  workspace path ([output directories](https://github.com/bazelbuild/bazel/blob/9e19427a2a5e782d4a106f9b1a4b7b92651b0e18/docs/remote/output-directories.mdx#L42-L53), N).
  Its Windows guide tells users to pick a short `--output_user_root` because
  "the MSVC compiler" has the limit ([windows.mdx](https://github.com/bazelbuild/bazel/blob/9e19427a2a5e782d4a106f9b1a4b7b92651b0e18/docs/configure/windows.mdx#L19-L28), N).
- **Bazel's process creation.** It layers three fallbacks ([util.cc](https://github.com/bazelbuild/bazel/blob/9e19427a2a5e782d4a106f9b1a4b7b92651b0e18/src/main/native/windows/util.cc#L207-L336)):
  1. 8.3 short names, through `GetShortPathNameW`.
  2. If short names are disabled, the `\\?\` form as `lpApplicationName`, which
     "is not subject to MAX_PATH".
  3. Batch files have no fallback: "cmd.exe does NOT allow for the longpath
     prefix".
- **Bazel failures** (O):
  - Short-name failure on a long-path-enabled machine ([#19710](https://github.com/bazelbuild/bazel/issues/19710)).
  - Batch files over 256 characters ([#30431](https://github.com/bazelbuild/bazel/issues/30431)).
  - MSVC's "Cannot open compiler generated file" even under `C:/tmp`, with the
    advice to shorten target names or flatten the package tree ([#4149](https://github.com/bazelbuild/bazel/issues/4149)).

**Walk-away.** CMake's `FULL` trees are mostly readable. The hashed segments and
`SHORT` strategy trees need CMake's generated files to map back. Bazel's tree
below the MD5 output base is readable, but finding it from a workspace needs the
hash.

### 2.5 Language runtimes the tools stand on

- **Windows: the prefix is added inside, and stripped at the boundary.**
  - **Rust.** `maybe_verbatim` adds `\\?\` past 248 units ([path/windows.rs](https://github.com/rust-lang/rust/blob/4ddbc06ea09abcda34f80baf31cc9bc2686b0ae6/library/std/src/sys/path/windows.rs#L78-L160)).
    It also notes that paths "passed to other application" are better
    non-verbatim. At process creation Rust strips the prefix, "because the
    current directory does not support verbatim paths" ([process/windows.rs](https://github.com/rust-lang/rust/blob/4ddbc06ea09abcda34f80baf31cc9bc2686b0ae6/library/std/src/sys/process/windows.rs#L949-L960)).
  - **Go.** `fixLongPath` does the same ([path_windows.go](https://github.com/golang/go/blob/6f5c275ebdc454197fff5f1496521c8f81e20eef/src/os/path_windows.go#L90-L160)).
    The runtime also sets an undocumented PEB long-path bit ([os_windows.go](https://github.com/golang/go/blob/6f5c275ebdc454197fff5f1496521c8f81e20eef/src/runtime/os_windows.go#L414-L439)).
    Even so, `CreateProcess` returns `ERROR_INVALID_NAME` for a working directory
    "longer than `MAX_PATH`, including if the path is prefixed with `\\?\`", and
    "There is nothing that can be done about this on the toolchain level" ([go#78601](https://github.com/golang/go/issues/78601#issuecomment-4235758360), O).
  - **Others.** Node, .NET and OpenJDK add the prefix the same way. CPython
    relies on the registry plus its manifest ([windows.rst](https://github.com/python/cpython/blob/9d22a5334bd5273962adceeb697a1337e9a0ca21/Doc/using/windows.rst#L1319-L1334), N).
- **POSIX: descriptor walking, adopted for safety, not length.**
  - **Rust.** `remove_dir_all` recurses by `openat`/`unlinkat` on one component
    at a time. Its comment: "we do not call any functions involving the full
    path" ([fs/unix.rs](https://github.com/rust-lang/rust/blob/4ddbc06ea09abcda34f80baf31cc9bc2686b0ae6/library/std/src/sys/fs/unix.rs#L2405-L2575)).
  - **Go.** `os.Root` opens each intermediate directory with
    `openDirFunc(dirfd, parts[i])` ([root_openat.go](https://github.com/golang/go/blob/6f5c275ebdc454197fff5f1496521c8f81e20eef/src/os/root_openat.go#L340-L470)).
  - **Python.** `shutil.rmtree` walks with `dir_fd` ([shutil.py](https://github.com/python/cpython/blob/9d22a5334bd5273962adceeb697a1337e9a0ca21/Lib/shutil.py#L730-L879)).
  - **Common shape.**
    - The motivation is TOCTOU and symlink safety; none documents long-path
      support (I).
    - The root is still opened by a whole string.
    - Depth is bounded by descriptors or recursion.
    - Each rebuilds the full string for display: Python's `fullname` for
      errors, and Go's `File.Name()` (I).
- **POSIX: otherwise whole strings.** Ordinary opens pass a whole C string to
  the kernel, and an over-limit one returns ENAMETOOLONG. Node's namespacing is a
  no-op on POSIX ([path.js](https://github.com/nodejs/node/blob/v24.0.0/lib/path.js#L1356-L1358)).

### 2.6 Family conclusion

Every Windows tool here fixed its own I/O and then met the same wall: the
executable path, the working directory, and `cmd.exe` at process creation. The
only mechanisms that served *arbitrary* downstream consumers kept the delivered
path short, by hashing, flattening, 8.3 aliases or a relocated root.

On POSIX, descriptor walking removes the whole-path limit only below a root
opened by string, and only inside the process.

**Silences.**

- No primary source was found on how SwiftPM, Xcode DerivedData or git behave
  on macOS with whole paths of 1,024 bytes or more.
- No build tool was found that automatically splits a long user-supplied root and
  walks it from `/`.

## 3. Archive, copy, backup and sync

The archive formats themselves are not the problem. pax `path` records,
GNU `././@LongLink`, ZIP's 16-bit name length and 7z's UTF-16 names all store a
1,500-byte name. The interesting part is creating the stored name on disk and
handing it on afterwards.

### 3.1 libarchive / bsdtar (macOS `/usr/bin/tar`)

- **Reading a tree.** The disk walker descends one directory at a time with
  `fchdir` or `openat`. It keeps only "the name, depth … and some markers
  indicating how to get back to the parent" ([archive_read_disk_posix.c](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_read_disk_posix.c#L136-L143), I).
  It still grows the full member name as an unbounded string.
- **Storing.** The pax writer adds a `path` record when the name will not fit
  ustar. The ustar writer refuses with "Pathname too long" ([pax](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_set_format_pax.c#L1088-L1094),
  [ustar](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_set_format_ustar.c#L413-L445)).
  The reader accepts names up to 1 MiB ([read tar](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_read_support_format_tar.c#L249)).
- **Extracting.** `edit_deep_directories` does this: "If pathname is longer than
  PATH_MAX, chdir to a suitable intermediate dir and edit the path down to a
  shorter suffix" ([archive_write_disk_posix.c](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_disk_posix.c#L2043-L2087)).
  - It loops `while (strlen(tail) >= PATH_MAX)`.
  - It gives up only on a single over-long component.
  - It changes the *process* working directory.
- **Apple's copy changes the mechanism.** Apple's fork (libarchive-167) uses the
  private per-thread `pthread_fchdir_np` for the same hop ([Apple libarchive](https://github.com/apple-oss-distributions/libarchive/blob/libarchive-167/libarchive/libarchive/archive_write_disk_posix.c#L2118-L2177), I).
  It opens the hop directory with `O_NOFOLLOW_ANY` when secure symlinks are on.
  This is the nearest shipped macOS precedent for acting on 1,500-byte paths: an
  Apple binary doing in-process, thread-scoped relative I/O.
- **Security checks versus depth** (O, and an unresolved question):
  - Long names once evaded the symlink check. The fix made "deep-directory support
    … no longer functional if sandboxing is enabled" ([#744](https://github.com/libarchive/libarchive/issues/744)).
  - The current source still carries that note ([L2921-L2933](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_disk_posix.c#L2921-L2933)).
    Yet the check now walks one component at a time with `fstatat(chdir_fd, head)`.
  - bsdtar turns secure modes on by default. Whether default bsdtar extraction
    succeeds past 1,024 bytes on current macOS is **unanswered**.
- **Deferred directory metadata.** It is replayed through the *unedited* full
  name, relative to the original cwd ([L853-L858](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_disk_posix.c#L853-L858),
  [L2574-L2600](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/libarchive/archive_write_disk_posix.c#L2574-L2600)).
  On failure it goes to `skip_fixup_entry`. So the mode and mtime of an over-limit
  directory are probably dropped without an error (I).
- **The project's own test stays below PATH_MAX.** Kientzle's comment in its
  copy test states the principle: "PATH_MAX is merely a limit on the length of
  the string passed into a system call. By repeatedly calling chdir(), you can
  work with arbitrarily long paths". The test then sizes its tree to stay under
  PATH_MAX ([test_copy.c](https://github.com/libarchive/libarchive/blob/a61db9140707ed638c2ed6785bbfdbe0dc60458b/tar/test/test_copy.c#L23-L72)).
  So it is not over-limit evidence.

**Walk-away.** A standard pax stream that any pax reader can read, with the long
name stored verbatim.

### 3.2 GNU tar

- **Format.** "Archives in gnu format are able to hold file names of unlimited
  length" ([tar.texi](https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/doc/tar.texi?h=v1.35#n9587), N).
  ustar members that cannot be split are "not dumped".
- **Create.** The walk holds one directory fd per level and calls
  `openat(parent->fd, name)` ([create.c](https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/src/create.c?h=v1.35#n1564), I).
  Under fd pressure it reopens parents by their *original whole name*, which
  brings the limit back.
- **Extract (1.35).** Every operation passes the whole member name relative to
  the `-C` fd: `fd = openat (chdir_fd, file_name, openflag, mode)` ([extract.c](https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/src/extract.c?h=v1.35#n1216)).
  ENAMETOOLONG is treated as "couldn't be created; fail now" ([L736-L741](https://cgit.git.savannah.gnu.org/cgit/tar.git/tree/src/extract.c?h=v1.35#n736)).
  So GNU tar *stores* a 1,500-byte name but cannot *extract* it on macOS, member
  by member (I).

### 3.3 coreutils and gnulib versus macOS `cp` and `copyfile`

- **gnulib's virtual cwd.** gnulib fts with `FTS_CWDFD` traverses "via a virtual
  working directory, maintained through the file descriptor member" ([fts.in.h](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/lib/fts.in.h#L170-L177), N).
  It checks dev/ino when climbing.
- **What coreutils promises.** Since 2003, "chgrp, chmod, and chown can now
  process (with -R) hierarchies of virtually unlimited depth. Before, they would
  fail … with a relative name of length PATH_MAX … or longer". `du` got the same
  promise ([NEWS](https://github.com/coreutils/coreutils/blob/a2415242cbb428b6cbf66fe00fceb1eba21af514/NEWS#L6192-L6201), N).
  `chdir_long` is "much like chdir, but without the PATH_MAX limitation", failing
  only on a single over-long component ([chdir-long.c](https://github.com/coreutils/gnulib/blob/92d4a0deb5f8f332d3ea800f8fb41d0b56b4169a/lib/chdir-long.c#L93-L107), N).
- **`cp -r` is the outlier.** It opens sources by concatenated whole path
  ([copy.c](https://github.com/coreutils/coreutils/blob/a2415242cbb428b6cbf66fe00fceb1eba21af514/src/copy.c#L403-L409), I).
  No NEWS entry promises depth for `cp`.
- **Apple fts.** The default mode `chdir`s, so the kernel limit leaves the
  syscall string. The rebuilt `fts_path` is then capped: "We limit fts_pathlen to
  USHRT_MAX to be safe" ([fts.c](https://github.com/apple-oss-distributions/Libc/blob/Libc-1752.100.10/gen/fts.c#L1521-L1536)).
  The limit moves from 1,024 to 65,535 bytes. An environment variable opts into
  a per-thread cwd ([L235-L236](https://github.com/apple-oss-distributions/Libc/blob/Libc-1752.100.10/gen/fts.c#L235-L236)).
  - **macOS `rm`** uses chdir-mode fts and `unlinkat` on a single component
    ([rm.c](https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-479/rm/rm.c#L221-L228), I).
  - **macOS `cp`** uses `FTS_NOCHDIR`, a `PATH_MAX` destination buffer, and an
    explicit ENAMETOOLONG warning that skips the subtree ([cp.c](https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-479/cp/cp.c#L107),
    [L462-L473](https://github.com/apple-oss-distributions/file_cmds/blob/file_cmds-479/cp/cp.c#L462-L473)).
  - **`copyfile(3)`'s recursive mode** uses `FTS_NOCHDIR`, whole-path
    `copyfile(ftsent->fts_path, …)` and `MAXPATHLEN` buffers ([copyfile.c](https://github.com/apple-oss-distributions/copyfile/blob/copyfile-240/copyfile.c#L679)).
    `fcopyfile` works on already-open descriptors for a single file.

On one macOS system, then, `rm -r` reaches what `cp -R` refuses and what
`copyfile` cannot address.

### 3.4 rsync, restic, Borg

- **rsync 3.4.4** keeps full relative strings in `MAXPATHLEN` buffers.
  - **Sender.** It skips an over-length name, "filename overflows max-path len",
    and flags an I/O error ([flist.c](https://github.com/RsyncProject/rsync/blob/v3.4.4/flist.c#L1898-L1907)).
  - **Receiver.** It aborts the whole session through
    `overflow_exit("recv_file_entry")` when a received name exceeds *its own*
    MAXPATHLEN ([flist.c](https://github.com/RsyncProject/rsync/blob/v3.4.4/flist.c#L736-L741)).
  - **Consequence.** A 1,500-byte name legal on a Linux sender would end a
    transfer into macOS (I). The limit is whichever peer is smaller.
- **restic.**
  - **Format.** It stores trees of one-component nodes linked by `subtree` IDs,
    so depth is unbounded in the format ([design.rst](https://github.com/restic/restic/blob/5127c4abf921857fde4ae51f566c86028c8c2911/doc/design.rst#L466-L516), N).
  - **Backup.** It opens by whole path. On Linux an over-limit file was skipped
    with a warning while the snapshot was saved ([#4693](https://github.com/restic/restic/issues/4693), O).
  - **Restore.** It joins `target` and `nodeName` and opens the whole path
    ([restorer.go](https://github.com/restic/restic/blob/5127c4abf921857fde4ae51f566c86028c8c2911/internal/restorer/restorer.go#L198), I).
- **Borg 1.4.5.**
  - **Create.** It reads with `os.open(name, dir_fd=parent_fd)`: "openat will be
    used, path is not used" ([fs.py](https://github.com/borgbackup/borg/blob/1.4.5/src/borg/helpers/fs.py#L326-L353)).
  - **Extract.** It writes to `os.path.join(dest, item.path)` by whole path
    ([archive.py](https://github.com/borgbackup/borg/blob/1.4.5/src/borg/archive.py#L861-L899), I).
    So Borg can back up what it cannot restore, except as a GNU tar export.

### 3.5 Windows copy tools, 7-Zip and Info-ZIP

- **robocopy.** Long paths are on by default, with only an off switch: "/256
  Turns off support for paths longer than 256 characters" ([robocopy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy), N).
  The mechanism is undocumented.
- **7-Zip.** It tries the normal path, then retries with the `\\?\` "super path"
  ([FileIO.cpp](https://github.com/ip7z/7zip/blob/26.03/CPP/Windows/FileIO.cpp#L152-L163)).
  It resolves `.` and `..` itself, because Windows cannot do so after the prefix
  ([FileName.cpp](https://github.com/ip7z/7zip/blob/26.03/CPP/Windows/FileName.cpp#L525-L570)).
- **Info-ZIP UnZip 6.0.** It sizes names by `PATH_MAX`.
  - **At the header.** It truncates with "filename too long--truncating"
    ([fileio.c](https://github.com/madler/unzip/blob/0b82c20ac7375b522215b567174f370be89a4b12/fileio.c#L172)).
  - **On Unix.** It reports "checkdir warning: path too long; truncating" as a
    non-fatal status ([unix.c](https://github.com/madler/unzip/blob/0b82c20ac7375b522215b567174f370be89a4b12/unix/unix.c#L884-L891)).
  - **Effect.** The data lands at a *different* path (I).

  This is the family's clearest negative example of silent shortening. The source
  is Mark Adler's tree of the 6.0 release, not an official Info-ZIP repository.

### 3.6 Sync services: documented ceilings and over-limit behavior

| Service | Documented limit and unit | Over-limit behavior |
| --- | --- | --- |
| OneDrive ([limits](https://support.microsoft.com/en-us/onedrive/what-are-file-path-length-limits), N) | 400 characters decoded; 520 for the sync client. Its table lists "macOS Finder 1,024 characters" and macOS Office "1024 UTF8-encoded bytes". | "sync client quits until the overlimit item is resolved". Also: "Even with the Windows long path Group Policy setting enabled, File Explorer doesn't use it." |
| Dropbox ([names](https://help.dropbox.com/organize/file-names), [macOS File Provider](https://help.dropbox.com/installs/macos-support-for-expected-changes), N) | Fewer than 260 characters, in UTF-16 units. "The current path length limit is 8,096 characters" on the macOS File Provider build. | Long or deeply nested items "won't be synced". |
| iCloud for Windows ([support](https://support.apple.com/en-us/101649), N) | Not numeric; rename below 256 characters. | From 10.8, a long item does not sync while others continue. Earlier versions stopped the folder. |
| Syncthing ([BEP](https://docs.syncthing.net/specs/bep-v1.html), N) | Whole relative UTF-8 string on the wire, with no stated limit. | `\\?\` on Windows ([basicfs.go](https://github.com/syncthing/syncthing/blob/7ad73b408adc792cabeed41d89a37b93e2bd84d0/lib/fs/basicfs.go#L97-L137)). Temporary names over 160 bytes become a SHA-256 ([tempname.go](https://github.com/syncthing/syncthing/blob/7ad73b408adc792cabeed41d89a37b93e2bd84d0/lib/fs/tempname.go#L30-L55)). No POSIX whole-path workaround. |

Microsoft's own sync documentation independently names a 1,024 ceiling for
macOS Finder. That agrees with the k134 Finder measurement, but it is a product
table, not a mechanism statement.

### 3.7 Family conclusion

Every tool here that genuinely operates past 1,024 bytes on macOS does so
*inside its own process*. It uses a process cwd, a per-thread cwd or descriptor
descent, and it rebuilds a whole string for names, messages or metadata replay.
Where an over-limit name must be handed on, the record shows:

- refusal, skipping or session abort (macOS `cp`, rsync, GNU tar);
- per-item sync failure (Dropbox, iCloud);
- a stopped sync (OneDrive);
- silent truncation (UnZip).

No surveyed tool delivers an over-limit location to a path-taking third party.

**Silences.** No primary source was found for:

- `ditto`, which is not in Apple's published sources;
- Time Machine;
- `xcopy`;
- Google Drive for desktop;
- current Syncthing per-item pull handling.

## 4. Remote and virtual namespaces, and protocol handoff

This is the family where component arrays are real. Network file protocols were
*designed* around them, and say why.

### 4.1 NFS: one segment per LOOKUP, an array per COMPOUND

- **Why LOOKUP takes one segment.** RFC 1813 §1.6: "Each call to LOOKUP is used
  to resolve one segment of a pathname. There are two reasons for restricting
  LOOKUP to a single segment: it is hard to standardize a common format for
  hierarchical file names and the client and server may have different mappings
  of pathnames to file systems" ([RFC 1813](https://www.rfc-editor.org/rfc/rfc1813#section-1.6), N).
- **No length limit in the protocol.** §1.7 adds "The protocol does not place any
  artificial limits on the length". The opaque 64-byte file handle is the
  directory anchor.
- **The one string ingress is bounded.** It is MOUNT, with `MNTPATHLEN = 1024`
  bytes ([§5.1.4](https://www.rfc-editor.org/rfc/rfc1813#section-5.1.4)).
- **NFSv4.1.** It drops the mount protocol. A multi-component lookup is a
  COMPOUND of `PUTFH; LOOKUP "pub"; LOOKUP "foo"; …`. Referrals use
  `pathname4`, literally `typedef component4 pathname4<>` ([RFC 8881](https://www.rfc-editor.org/rfc/rfc8881#section-18.13), N).
- **Linux server (knfsd).** It checks each component against `NAME_MAX` and
  rejects a `/` inside one ([nfs4xdr.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/nfsd/nfs4xdr.c#L95-L107)).
- **Linux client.** The string comes back at the edges (N, in source):
  - The client's own `open(2)` copies at most PATH_MAX, which is 4,096 including
    NUL ([namei.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/namei.c#L161-L179)).
  - The mount source is capped, with "NFS: export pathname too long"
    ([fs_context.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/nfs/fs_context.c#L1121-L1127)).
  - A referral's component array is rendered back to a string with an explicit
    `if (len > PATH_MAX) goto too_long` ([nfs4namespace.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/nfs/nfs4namespace.c#L33-L51)).
- **A vendor's field note.** Azure NetApp Files describes NFS total path length
  as "Unlimited" with 4,096 bytes "for transversal". It warns that "a `cd`
  request to a path over the 4,096-byte limit yields a "File name too long"
  error", and that NFS-created paths can exceed what SMB clients reach
  ([path lengths](https://learn.microsoft.com/en-us/azure/azure-netapp-files/understand-path-lengths), O/vendor).

**Walk-away.** The server's data is ordinary files. Client handles mean nothing
without the server.

### 4.2 9P: Twalk carries the array

- **The protocol.** walk(5) defines `Twalk fid newfid nwname nwname*(wname[s])`.
  It allows at most sixteen elements per message, "Despite this restriction, the
  system imposes no limit on the number of elements in a file name, only the
  number that may be transmitted in a single message" ([walk(5)](https://9p.io/magic/man2html/5/walk), N).
- **Linux v9fs client.** It builds `wnames[]` from dentry names and sends them in
  `P9_MAXWELEM` chunks. It never forms a path string for the wire
  ([fid.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/9p/fid.c#L147-L256)).
- **QEMU's 9pfs server.** It does build an unbounded heap string per fid. To open,
  it walks that string component by component with `openat` from a held mount fd
  ([9p-local.c](https://github.com/qemu/qemu/blob/2a0ac9c8ac2d303ca515dc819043409aef18cab5/hw/9pfs/9p-local.c#L61-L96)).
  Whether every operation avoids a whole-string call was not audited.

### 4.3 FUSE: the kernel speaks components; the convenience API rebuilds strings

- **The kernel protocol.** It is `nodeid` plus one name. The only name check is
  per component against `name_max`, which is 1,024 or PATH_MAX−1
  ([fuse/dir.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/fuse/dir.c#L572-L574)).
- **libfuse's high-level API.** It rebuilds the full path for every request in a
  buffer that doubles on demand and fails only on allocation ([fuse.c](https://github.com/libfuse/libfuse/blob/eb7bae84508c520bdcedcfd88175c5afe4c82ecb/lib/fuse.c#L939-L1074)).
  The reference filesystem then calls `open(path)` ([passthrough.c](https://github.com/libfuse/libfuse/blob/eb7bae84508c520bdcedcfd88175c5afe4c82ecb/example/passthrough.c#L318)).
  The limit moves from the caller's syscall to the daemon's syscall (I).
- **libfuse's low-level API.** Its example keeps an `O_PATH` fd per inode and calls
  `openat(lo_fd(req, parent), name, O_PATH | O_NOFOLLOW)` ([passthrough_ll.c](https://github.com/libfuse/libfuse/blob/eb7bae84508c520bdcedcfd88175c5afe4c82ecb/example/passthrough_ll.c#L375)).
  KDE's kio-fuse chose this API because the high-level one "translates the inode
  numbers … to paths" ([DESIGN.md](https://github.com/KDE/kio-fuse/blob/4ff9006755050f63d831dbde53878f4e9e1c9d6b/DESIGN.md), N).
- **Silence.** No primary source was found for macFUSE or FUSE-T internals.

### 4.4 SFTP and SMB: whole strings by choice

- **SFTP chose strings deliberately.** The draft says that "alternative approaches
  that e.g. treat file names as sequences of structured components are quite
  complicated" ([draft-ietf-secsh-filexfer-02 §6.2](https://www.ietf.org/archive/id/draft-ietf-secsh-filexfer-02.txt), N).
- **OpenSSH's sftp-server** passes the whole string to `open(name, flags, mode)`.
  - It maps `ENAMETOOLONG` to `SSH2_FX_BAD_MESSAGE` ([sftp-server.c](https://github.com/openssh/openssh-portable/blob/15289cc38956aa74d4947174a68c10ac9ad2157f/sftp-server.c#L213-L243),
    [L757](https://github.com/openssh/openssh-portable/blob/15289cc38956aa74d4947174a68c10ac9ad2157f/sftp-server.c#L757)).
  - Its realpath and readlink use fixed `PATH_MAX` buffers.
  - A 1,500-byte path therefore works against a Linux server and is a "bad message"
    against a macOS one (I).
- **SMB2 CREATE** carries one share-relative UTF-16 name with a 2-byte length
  ([MS-SMB2 §2.2.13](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/e8fb45c1-a03d-44ca-b7ae-47385cfd7997), N).
  [MS-FSCC](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/ffb795f3-027d-4a3c-997d-3085f2332f6f)
  caps a pathname at 32,760 characters.
- **Samba.** It splits the name into components, but first tries one whole-string
  `openat2`. It falls back to its per-component loop only for
  ENOSYS/ELOOP/ENOTDIR/ENOENT, and `default: goto fail` covers ENAMETOOLONG
  ([files.c](https://github.com/samba-team/samba/blob/9ff8eec2d61d5b5cd5e1f780fe53c318eb65dded/source3/smbd/files.c#L1232-L1299), I).
  So the loop that could reach the file is skipped exactly when it is needed.
- **Apple's smbfs client.** It rebuilds the share path from parent nodes and fails
  at 256 *components*, not bytes ([smbfs_subr.c](https://github.com/apple-oss-distributions/smb/blob/smb-759.40.1/kernel/smbfs/smbfs_subr.c#L98-L160)).
- **Drive letters.** Mapping a deeper share point to a drive letter is the
  documented Windows workaround ([Azure NetApp Files](https://learn.microsoft.com/en-us/azure/azure-netapp-files/understand-path-lengths), O/vendor).
  It shortens what applications see and moves the limit.

### 4.5 Handing a file to a launcher on Linux: the desktop portal

- **The fd crosses the boundary.** xdg-desktop-portal's `OpenURI.OpenFile` is a
  real "give the opener a descriptor" API: its argument is a D-Bus `h` fd
  ([OpenURI.xml](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/data/org.freedesktop.portal.OpenURI.xml#L108-L115), N).
- **The host side turns it straight back into a path.** It reads the path into a
  `PATH_MAX` buffer with `readlink("/proc/self/fd/N", …, PATH_MAX)`
  ([xdp-app-info.c](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/shared/xdp-app-info.c#L608-L616)).
  The kernel's own readlink there uses a PATH_MAX `d_path` and fails beyond it
  ([proc/base.c](https://github.com/torvalds/linux/blob/6addb4f385570ebc11c4eb499a4f1c149f313e84/fs/proc/base.c#L1815-L1837)).
- **The application gets a URI string.** The portal then:
  - re-`stat`s the string to check it is the same file;
  - converts it with `g_filename_to_uri`;
  - launches the handler with `g_app_info_launch_uris`
    ([open-uri.c](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/desktop-portal/open-uri.c#L201-L253),
    [L661](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/desktop-portal/open-uri.c#L661),
    [L755](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/desktop-portal/open-uri.c#L755)).
- **Sandboxed targets get a short virtual path.** The portal re-opens the string
  and registers a document. The app sees `/run/user/UID/doc/<id>/<basename>`.
  - **The daemon.** It is a low-level FUSE filesystem keeping an `O_PATH` fd per
    inode, and below the document root it uses `openat` ([document-portal-fuse.c](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/document-portal/document-portal-fuse.c#L90-L94)).
  - **But the root is a stored path string.** It is reopened with
    `open(doc_domain->doc_path, O_PATH | O_DIRECTORY)` ([L954](https://github.com/flatpak/xdg-desktop-portal/blob/7b17a3297b76c20f65c3f0ebd9f91a7ae669a115/document-portal/document-portal-fuse.c#L954)).
- **What the handles are for.** File handles from `name_to_handle_at(…
  AT_HANDLE_FID)` serve only as identity checks. Opening by handle needs
  `CAP_DAC_READ_SEARCH` ([open_by_handle_at(2)](https://man7.org/linux/man-pages/man2/open_by_handle_at.2.html), N).

**Verdict.** The descriptor crosses the process boundary and the string is
rebuilt one step later. The only representation that reaches an arbitrary
handler shorter than the original is a *virtual short path* served by a resident
daemon. That daemon still opens a whole-string anchor.

### 4.6 Container resolvers: race safety, not length

libpathrs walks component by component from a root fd. After any `..`, and on the
final handle, it checks for escape by reading `/proc/thread-self/fd/N` back as a
string ([opath/imp.rs](https://github.com/cyphar/libpathrs/blob/3abe8bbda057bcae1cd379a05685867684c43353/src/resolvers/opath/imp.rs#L33-L144)).
Its default backend passes the remaining path to `openat2` in one string. Neither
backend therefore survives an absolute depth at or beyond PATH_MAX (I).

### 4.7 macOS identifiers and descriptors

Published xnu-12377.121.6 shows these, all from source (N) unless marked:

- **`F_GETPATH`.** It returns a descriptor's path through a `MAXPATHLEN` (1,024)
  buffer ([kern_descrip.c](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/kern/kern_descrip.c#L3904-L3930)).
  A service receiving an fd over XPC cannot recover a 1,500-byte path this way
  (I). This is the macOS twin of the Linux portal's `/proc/self/fd` step.
- **Long-path mode.** It is up to `MAXLONGPATHLEN` 8,192 and is set only with the
  private entitlement `com.apple.private.vfs.support-long-paths`
  ([kern_resource.c](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/kern/kern_resource.c#L3224-L3256)).
- **Volfs paths (`/.vol/<fsid>/<fileid>`).** The kernel expands them into real
  paths up to 8,192 bytes, "To be consistent with the behavior of openbyid_np,
  which always supports long paths", without that entitlement ([vfs_lookup.c](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_lookup.c#L459-L511)).
  - The same code calls them legacy, which "future versions of the OS may not
    support".
  - A trailing name appended after the id is limited to `MAXPATHLEN` (I).
  - Whether Launch Services accepts such a location is **unanswered**.
- **`openbyid_np`.** It rebuilds the path inside the kernel and then opens it.
  It is gated by a private entitlement or platform-binary status
  ([vfs_syscalls.c](https://github.com/apple-oss-distributions/xnu/blob/xnu-12377.121.6/bsd/vfs/vfs_syscalls.c#L5463-L5560)).
- **Foundation file-reference URLs.** Apple's documentation says they identify
  objects "by reference, not by path" and "should never be persistently stored"
  ([fileReferenceURL()](https://developer.apple.com/documentation/foundation/nsurl/filereferenceurl()), N).
- **XPC descriptor passing.** `xpc_fd_create` passes a `dup` of a descriptor to a
  cooperating process ([xpc_fd_create](https://developer.apple.com/documentation/xpc/xpc_fd_create(_:)), N).
  The receiver can use `fstat`/`openat` on it with no path.

### 4.8 URLs and KIO

- **No overall URI limit.** RFC 3986 sets none. HTTP recommends supporting "at a
  minimum, URIs with lengths of 8000 octets" ([RFC 9110 §4.1](https://www.rfc-editor.org/rfc/rfc9110#section-4.1), N).
- **A file URI is a path in a wrapper.** RFC 8089 makes it percent-encoded UTF-8
  ([RFC 8089](https://www.rfc-editor.org/rfc/rfc8089), N). Encoding can triple
  its byte length, while the decoded path keeps the OS limit (I).
- **Chromium** allows 2 MiB URLs between its processes ([url_constants.h](https://github.com/chromium/chromium/blob/102d0d1a9b57dae89fe712fc79b66cf9272309a8/url/url_constants.h#L69-L71), N).
- **kio-fuse.** It exposes remote URLs as `<mount>/<scheme>/<host>/<path>`, so
  its name mapping *lengthens* local paths ([DESIGN.md](https://github.com/KDE/kio-fuse/blob/4ff9006755050f63d831dbde53878f4e9e1c9d6b/DESIGN.md), N).
  It rebuilds the remote URL from node names per operation ([kiofusevfs.cpp](https://github.com/KDE/kio-fuse/blob/4ff9006755050f63d831dbde53878f4e9e1c9d6b/src/kiofusevfs.cpp#L1784-L1797)).

### 4.9 Family conclusion

So yes, some real systems use an array of components, but only *inside* a
protocol whose both ends cooperate and whose server walks `openat`-style: NFS,
9P, the FUSE kernel protocol, and low-level FUSE daemons.

Every sourced handoff to an *arbitrary* opener goes the other way:

- the string is rebuilt from the array or descriptor, as the Linux portal,
  `F_GETPATH`, the NFS referral renderer and the libfuse high-level API do; or
- a short virtual alias is substituted, as with the document portal, drive
  letters and volfs ids.

A descriptor crossing the boundary does not survive the opener's need for a path.

**Silences.** No primary source was found for:

- macFUSE/FUSE-T internals;
- the macOS NFS client;
- WebDAV server limits;
- the length limits of modern swift-foundation `URL`;
- Windows `subst` over MAX_PATH, on which Microsoft's page is silent;
- the first macOS release with `MAXLONGPATHLEN`. xnu tags show it in 11417 and
  12377 but not in 11215.81.4; the OS mapping was not verified.

## 5. Applicability to Koine

### 5.1 Mechanisms compared

The columns separate three consumers, because the evidence does:

- **In-process I/O.** The tool's own system calls.
- **Cooperating peer.** A process that both sides wrote or that speaks a shared
  protocol.
- **Arbitrary opener.** Launch Services, Finder, a default handler, or Explorer.

| Mechanism | Sourced examples | In-process I/O | Cooperating peer | Arbitrary opener |
| --- | --- | --- | --- | --- |
| Whole string to the kernel | Most editors and launchers, rsync, copyfile, Borg/restic restore, GNU tar 1.35 extract, OpenSSH | Limited by PATH_MAX (or MAX_PATH) on that string. Extra buffers can make it worse (Vim, UnZip, rsync). | The string travels fine (argv, D-Bus, IPC, SMB, SFTP); the receiver re-imposes its limit. rsync's limit is whichever peer is smaller. | **Removes nothing.** |
| Process cwd, then short suffix | libarchive `edit_deep_directories`, Apple fts, gnulib `chdir_long`, git's socket bind | **Removes** the limit; the cwd change is process-global. | A child spawned in that cwd inherits it. Windows `CreateProcess` refuses long working directories. | Not usable. |
| Per-thread cwd | Apple libarchive (`pthread_fchdir_np`), Apple fts opt-in | **Removes** it, thread-safely; private Apple SPI. | No. | No. |
| Descriptor-relative walk | gnulib `FTS_CWDFD`, GNU tar create, Borg create, Rust/Go/Python descriptor walks, low-level FUSE, QEMU 9pfs open, document-portal FUSE | **Removes** it below a root opened by string. Bounded by NAME_MAX, descriptor count and recursion. Adopted mainly for race safety. | Only if descriptors are passed. None of the surveyed tools does so in this role. | Not usable. Qt rejected the model for portability and descriptor exhaustion. |
| Component array on the wire | NFS LOOKUP/COMPOUND/`pathname4`, 9P `Twalk`, FUSE kernel protocol, v9fs `wnames[]` | — | **Removes** it on the wire, when the server walks by handle. | Not applicable. It is rejoined at the edge (NFS referral rendering, FUSE high-level API, client `open`). |
| Descriptor passing | xdg-desktop-portal `OpenFile(h)` and `Documents.Add(h)`; XPC `xpc_fd_create` | **Removes** it for I/O on that object. | **Moves** it. The portal reads the path back through PATH_MAX (`/proc/self/fd`), and macOS `F_GETPATH` uses MAXPATHLEN. | **Moves** it. The handler receives a URI or path. |
| Ids and bookmarks | NFS handles, `open_by_handle_at`, macOS volfs/`openbyid_np`, file-reference URLs, bookmarks, portal document ids | Linux handles need `CAP_DAC_READ_SEARCH`. macOS volfs expands to a string of up to 8,192 bytes in the kernel. | Short and transferable, where the receiver can resolve them. | Unproven on macOS, and Apple discourages `/.vol`. **Excluded: id-spelled.** |
| Virtual short mapping | Document portal `/run/user/UID/doc/<id>/<name>`; drive letters and junctions; desktop-entry temporary copies | The mapping owner still opens a string anchor. | — | **Removes depth dependence** for any path-taking opener. Needs a resident service or admin-made link, and changes the spelling the opener sees. **Excluded: shortening.** |
| Hashing, flattening, relocation | CMake, Bazel, npm 3, pnpm, Syncthing temporary files, Homebrew | Avoids long paths. | Avoids them. | **Avoids them** by never producing the long path; legibility falls. **Excluded: shortening.** |
| Short names (8.3) | Bazel spawn, Electron #42634 | — | Works only when short names exist. | May silently return the long name. **Excluded: shortening.** |
| Raised OS limit | Windows `longPathAware` with registry; xnu long-path iopolicy (8,192) | **Raises** it for that process. | Each process must opt in. | Windows shell and `CreateProcess` stay limited. macOS: private entitlement. **Excluded: private.** |
| Refusal, skip or abort | macOS `cp`, ustar writers, rsync, restic backup, Dropbox, iCloud, OneDrive | Removes nothing. | — | Visible failure, per item or per session. |
| Silent loss | UnZip truncation, Vim name truncation, libarchive deferred metadata skip (I), Electron/Zed reveal | — | — | Data or action lands wrong or nowhere. |

### 5.2 Against the retained Koine cases

Koine's retained working cases need five handoffs to work for a roughly 1,500-byte
location:

- default-application open;
- Zed open;
- Finder reveal;
- constrained launch or named open of the exact selected registered copy;
- a truthful receipt.

Each must keep the supplied location unchanged, establish native facts and
causes, and keep short workflows unchanged.

| Retained need | What the surveyed systems show | Status |
| --- | --- | --- |
| Presence and cause | Descriptor walks, gnulib's `chdir_long` contract and GNU/Apple practice match k134's working `openat` route. Counter-examples are the same misreports the boundary forbids: Emacs on Windows maps size failure to ENOENT; KDE and Vim report "not found" and "Illegal file name". Qt's maintainer names truthful ENAMETOOLONG as the remaining obligation. | **Within mandate.** Supported by broad prior art. |
| Native classification and registration | No surveyed system classifies, registers or binds a handler for an over-limit location through a platform launcher database. Linux and Windows launchers take strings. | **No prior art found.** Neither a route nor a disproof. |
| Default-handler open | Every default-open path surveyed delivers a whole string or URI: Launch Services URL, `%f`/`%u`, D-Bus URIs, ShellExecute, portal URI. The only over-limit-tolerant delivery is a virtual short path (portal) or user-made alias (VS Code, Windows). | **Within-mandate route: none found.** The shortening route is **excluded: shortening**. |
| Zed open | Zed's CLI shows a cooperating side channel: a short Launch Services URL for the app, document paths over private IPC. It removes Launch Services from the document path, but Zed's Rust I/O then opens the whole string (I). | **Within mandate only as a lead**, and as a protocol whose stability Zed does not document. Its long-document outcome is unknown and likely limited inside Zed. |
| Finder reveal | Electron and Zed both call `selectFile` and discard its NO. Microsoft documents "macOS Finder 1,024 characters". No surveyed tool reveals an over-limit item. | **No route found.** A truthful failure is the common best practice, but it is a workflow change that needs Antony. |
| Constrained launch of a long copy | Windows evidence is uniform: long executable paths and working directories fail at process creation, and fixes use 8.3 names or `\\?\` application names (Bazel). No macOS launcher evidence beyond k134 was found. | **No within-mandate route found.** Short-name and alias forms are **excluded: shortening**. |
| Receipt identity | macOS `F_GETPATH` and Linux `/proc/self/fd` both rebuild paths through PATH_MAX buffers (N). No surveyed system observes an over-limit executable path. | **No route found.** Systematic length-caused null remains unaccepted. |

### 5.3 Leads and bounded next questions

None of these is a selected route, and none promises success. Each names the
decision that would have to precede it.

1. **Cooperating-receiver protocol for Zed** (*within mandate as a question*).
   Zed already separates app activation (a short `zed-cli://` URL through Launch
   Services) from document delivery (paths over its IPC). Bounded questions:
   - Is that protocol a supported integration surface?
   - Does Zed open a 1,500-byte document it receives that way?

   This needs a source read of Zed's open path, or acceptance-time evidence. It
   would not help default-handler open, reveal or app launch.
2. **Apple Event `odoc` sent to a named running app** (*needs new decision*). DTS
   sample code builds `odoc` from file URLs. Sending Apple Events to other apps
   implicates sandbox and Automation posture and is a legacy opener path. Its
   long-URL behaviour in a receiver is unsourced.
3. **Volfs or file-reference submission** (*excluded: id-spelled*). xnu expands
   `/.vol/<fsid>/<fileid>` to up to 8,192 bytes without the private entitlement.
   - Apple marks it legacy and tells applications never to construct it.
   - Whether Launch Services accepts it is unknown.
   - Even if accepted, the receiver would see an id spelling, not the supplied
     location.
4. **Virtual short mapping** (*excluded: shortening*). This is the only mechanism
   surveyed that works for arbitrary path-taking openers on Linux (the document
   portal). The macOS analogues would be a link or a mounted view. Each changes
   the delivered spelling and adds a resident component.
5. **Private long-path policy** (*excluded: private*). The entitlement is
   Apple-private. Policy on Koine alone would not reach the separate Launch
   Services and receiver processes.
6. **Disclosed truthful refusal** (*needs new decision*). This is the shape most
   mature tools converge on where they cannot deliver:
   - macOS `cp` warns and skips with ENAMETOOLONG;
   - Qt asks for correct ENAMETOOLONG;
   - iCloud for Windows went from stopping the folder to per-item failure.

   Its adoption is a workflow change Antony has so far declined. It is listed as
   prior art, not a recommendation.

## 6. Evidence gaps and silences

**Searched without finding a primary source:**

- **Apple's closed components.**
  - Launch Services or Finder whole-path limits; the forums and documentation
    were searched for PATH_MAX, 1024, ENAMETOOLONG and -10810.
  - What Launch Services sends in `odoc`.
  - Darwin Foundation's `fileSystemRepresentation` buffer; only
    swift-corelibs-foundation, which uses `PATH_MAX + 1`, was inspected.
  - Bookmark resolution past 1,024 bytes.
  - Which Apple processes set the long-path iopolicy.
  - The first macOS release with `MAXLONGPATHLEN`; tags show it in xnu 11417 and
    12377 but not in 11215.81.4.
- **Applications on macOS past 1,024 bytes:** Zed, VS Code, git, SwiftPM, Xcode
  DerivedData, Homebrew.
- **macOS tools:** `ditto`, which is not in Apple's published sources, and Time
  Machine.
- **Third-party file systems:** macFUSE/FUSE-T internals, the macOS NFS client,
  WebDAV servers.
- **Windows:**
  - `xcopy`.
  - Windows `subst` past MAX_PATH; its page is silent.
  - A Microsoft staff statement of Explorer's numeric limit.
  - The mechanism behind robocopy's long paths.
- **Sync:** Google Drive for desktop.
- **Open by inference only:**
  - Whether default secure-mode bsdtar extracts past 1,024 bytes on current macOS.
    The source and its comment disagree.
  - Restic's exit code for skipped files.
  - Current Syncthing per-item pull handling.
  - Whether every QEMU 9pfs operation avoids whole strings.

**Out of scope here:** no native measurement was run. Every "fails" for an
application in this survey comes from its source or a report, never from a new
probe.

## 7. Walk-away summary

| System | With the tool uninstalled, what is legible? |
| --- | --- |
| Launch Services / Finder | Plain locations; bookmarks and file-reference URLs are opaque. |
| Zed, VS Code, Vim, Emacs, GLib/Nautilus, KDE | Plain paths and URIs in their state files. Vim may hold a truncated name. |
| Windows shell | Plain paths. PIDLs are opaque folder bytes; 8.3 names are volume-specific. |
| git | Plain worktree; trees are readable component lists. |
| npm 3 / pnpm | npm: plain, mostly flat. pnpm: symlinks into truncated-and-hashed names and a content-addressed store. |
| CMake / Bazel | Mostly readable trees with MD5-named segments that need the tool's files to map back. |
| bsdtar / GNU tar / ZIP / 7z | Standard archives with names stored verbatim (pax `path`, `@LongLink`, 16-bit ZIP length). |
| rsync / Syncthing | Plain trees; Syncthing temporary names may be hashes. |
| restic / Borg | Encrypted repositories needing the tool, though both formats are published. restic stores component trees; Borg stores full paths and can export tar. |
| NFS / 9P / FUSE | Server data is plain files; handles and fids are meaningless off-line. |
| Document portal | Plain host paths in its database; document ids are opaque and die with the service. |
| macOS volfs / openbyid | Readable form, but id-spelled and unsupported for applications. |
