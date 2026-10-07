# Reveal's target location (reveal-locations, k174)

**Result: a reveal resolves its target component by component, never reports an
extant location missing, and refuses a location of 1,024 bytes or more at the
application hand-off.** The descriptor walk, the hand-off limit and reveal's
use of both are implemented and accepted at **L, G and N**. The walk's own source
is also tested directly on host fixtures, which supports N and closes none of it.
Every check was seen to fail against a deliberately broken walk, except where
the table below says a mutation cannot be reached through the bundle. What no
host observation can show is named, with its owner, in
[What N could not observe](#what-n-could-not-observe); it is not counted as
passed. First-use prompting was measured first and decided the work could proceed:
[the walk is prompt-free](descriptor-walk-prompt.md).

The contract is the [workspace spec](../specs/workspace-launch-and-open.md#resolving-an-action-location)
and the [descriptor-relative decision](../adr/filesystem-access-is-descriptor-relative.md).
This leaf covers reveal's target stage only (stage 1 of the
[order of stages](../specs/workspace-launch-and-open.md#order-of-target-and-application-stages));
the open-path target, both application stages, receipt identities and release 1.0.1
are later leaves. The retained 1.0.0 binary is untouched and keeps its defect.

## What was built

| Piece | Where | What it does |
| --- | --- | --- |
| The walk | `Providers/WorkspaceProvider/Logic/LocationWalk.swift` | One single-component call at a time from a held `O_SEARCH` handle: `openat`, `fstatat(AT_SYMLINK_NOFOLLOW)`, `readlinkat`, `fstat`, `fpathconf`. At most two handles, all closed before it returns, no file opened, nothing listed, no retry or fallback. Works in bytes, so no spelling is normalized or repaired. Reports the literal spelling, each remaining path after a link expansion, the resolved spelling, the device and inode and the type, or an absence with its cause, or a failure naming the component and cause. |
| The limit | `Providers/WorkspaceProvider/Logic/HandOffLimit.swift` | Compares the literal, every expanded remainder and the resolved spelling in pathname bytes without the NUL: 1,023 is handed over, 1,024 is refused, with guidance naming the stage, the spelling and its byte count and saying no request was made. |
| Reveal's plan | `Providers/WorkspaceProvider/Logic/RevealPath.swift` | Resolve, then the limit, then the root decision, then Finder, then submission. Absent is `PATH_NOT_FOUND` (an impossible component and an established cycle included); a resolution failure and the limit are `failed`. |
| The native seam | `WorkspaceNative.resolveLocation`, `isFilesystemRoot(literalPath:)` | The real adapter calls the walk and, only after the limit, `lstat`s the literal text and `/` for the root rule. |

The shipped code and the code under test are the same file. The walk sits in
`Logic/`, which the provider's build compiles into the bundle and the package
compiles for its tests, so no copy exists. `PathFacts.isFilesystemRoot` and its
two `lstat` calls were removed from `inspectPath`: nothing read them once reveal
stopped calling it, and the open-path leaf rewrites that inspection.

One defect was found by a fresh-context adversarial read of the walk and fixed: a
link whose text ends in a slash (`a` → `a/`, or `x` → `y/` and `y` → `x/`) gained a
slash on every lap, so an exact pending suffix never repeated and the cycle was
reported as the 32-link budget, `failed`. The cycle state now counts a run of
slashes as one, as the kernel does; the spec's wording was corrected with it, and
`LocationWalkTests`, `WorkspaceLongLocationTests` and a mutation cover it. The read
found the rest of the walk's kernel semantics, handle discipline, error classes,
spellings and limit order correct.

Two decisions the spec left open:

- **An "expanded remainder" is the link's text followed by the exact path that
  remained after the link**, as the kernel concatenates them. A link whose text is
  1,000 bytes and a short name after it is therefore refused, where the literal
  is short. This is also the pending suffix in the cycle state.
- **A final `.` is the directory the walk stands in, and a final `..` is examined
  from the current directory and not opened**, so `dir/.` needs search permission
  of `dir` as the kernel requires, and `dir/..` needs none of the parent's.

## Evidence

| Seam | Where | What it holds |
| --- | --- | --- |
| Prompts | [descriptor-walk-prompt.md](descriptor-walk-prompt.md) | 36 walks, 3 single opens and 6 controls in an isolated VM: none of the walk's calls prompted in Desktop, Documents or Downloads; both controls did. |
| Walk, direct (supporting) | `LocationWalkTests` | 21 tests on host fixtures built component by component, at short depth and at about 1,500 bytes: presence and type; absent names, dangling links and names below files; relative and absolute links, the final link followed; `.` and physical `..`; the root and its spellings; 31- and 32-link chains that resolve and a 33-link chain that is the budget; two-link and self cycles; a finite repeated dot-link; a self-extending `a` → `a/x`; one link inode in two directories (this filesystem admits it); a final directory with mode 0600; the 300-byte ASCII impossible component beside extant 300-byte multibyte and combining names (this filesystem admits both) and a non-ASCII over-long name that is `failed`; the 1,022/1,023/1,024/1,025 boundary; a short literal with a long expansion; the resolved spelling alone; handle discipline observed through a recording system; and, through that system, the rows no fixture builds: `fpathconf` returning -1, an unexplained name-length refusal, a link whose text changes between two reads, an unreadable directory. |
| L | `RevealLocationTests` | The planner over the substituted adapter: every absence kind is `PATH_NOT_FOUND`; every unestablished step is `failed` naming component and cause; a later platform absence about a found location is `failed`; 1,023 is submitted and 1,024, 1,500, an expansion and the resolved spelling are refused naming the spelling and byte count; after a refusal or an absence the adapter records no root check, no Finder or registration lookup, no metadata read and no request; the accepted order, the Finder check and the acknowledgment are unchanged; the root decision is asked of the literal text and submitted as it answers. `RevealPathTests` keeps every accepted short outcome. |
| G | `WorkspaceCompositionTests` | A public reveal of an extant path of 1,024, 1,025, 1,500 and 4,000 bytes is `failed` with the guidance at the action's own response path, no result and no dependency, and nothing is revealed; 1,023 bytes is revealed as before. |
| N | `WorkspaceLongLocationTests` | The independently built, signed bundle, loaded by the real loader and asked over loopback HTTP (see below). |
| Call path | `task check:launch-call-path` | Passes with the new checks: the walk makes only `openat` with `O_SEARCH`, `fstatat`, `fstat`, `readlinkat` and `fpathconf` and no whole-path, listing or content call; the planner's order is resolve, limit, root decision, Finder; the bundle imports those calls and no listing call; `realpath`, `stat` and `URL.path` do not address a reveal's location before the limit. |

### N, through the signed bundle

The host's Finder would reveal any present location within the limit, so the
bundle is asked only for rows decided before submission, at short depth and at
about 1,500 bytes:

- **Absent, `PATH_NOT_FOUND`:** a missing name, a dangling link, a name below a
  file, a file with a trailing slash or dot, an established two-link cycle, a
  cycle through a directory component, a link to itself, the 300-byte ASCII
  impossible component as a leaf and as a directory, and missing paths of 1,022,
  1,023, 1,024 and 1,025 bytes (a long path that does not exist is absent, never
  an error of length).
- **`failed`, naming component and cause:** the 33-link chain and the self-extending
  link (32 symbolic links), a directory without search permission in the middle
  of the path (denied), and a non-ASCII name the lookup refuses as too long.
- **Present, then refused after a complete resolution**, so each refusal proves the
  walk reached its object and names the spelling and its byte count: files of
  1,024, 1,025 and 1,500 bytes; a directory with and without a trailing slash; a
  short literal with a long expansion (names the expansion); a short literal and
  short expansions with a long resolved spelling (names the resolved path, and
  its count shows `..` dropped exactly one directory and an absolute link
  restarted at the root); 1-, 31- and 32-link chains to a deep target and 31- and
  32-link chains at depth; a final directory with mode 0600; one link inode in two
  directories whose same text and pending suffix recur; the finite repeated
  dot-link; and 300-byte multibyte, combining-character and emoji names.

### Mutation results

`task check:location-walk-mutations` breaks one decision of the shipped source at
a time in a copy of the tree, rebuilds the copy's tests and its own signed
bundle, and runs each named suite. S is `LocationWalkTests`, L is
`RevealLocationTests`, N is `WorkspaceLongLocationTests`.

| Broken decision | Red | Not reachable |
| --- | --- | --- |
| budget allows a 33rd link | S, N | — |
| budget stops at 31 | S, N | — |
| a repeated state is not a cycle | S, N | — |
| state without the containing directory | S, N | — |
| state without the pending suffix | S, N | — |
| dot dot does not leave the directory | S, N | — |
| an absolute link keeps the old directory | S, N | — |
| a final directory is opened | S, N | — |
| a trailing slash demands nothing | S, N | — |
| slash runs are distinct states | S, N | — |
| a changed link text is not noticed | S | N |
| a non ascii name can be impossible | S, N | — |
| an unreadable name limit is read as absence | S | N |
| every name too long is absent | S, N | — |
| a denial is absence | S, N | — |
| the directory handle is not closed | S | N |
| the limit is one byte too high | S, L, N | — |
| the limit ignores expansions | S, L, N | — |
| the limit counts the terminating nul | S, L, N | — |
| an impossible name or cycle is failed | L, N | S |
| a failed walk is a missing path | L, N | S |
| the limit is not applied | L, N | S |

All 22 were seen. "Not reachable" names the suites a mutation was not asked to turn red because they cannot observe it: a leaked handle and an unnoticed change of link text do not show in a result at N, and the planner mutations do not touch the walk's own tests. Each mutation is applied to a copy of the tree only; the working tree is never edited.

## What N could not observe

A reveal through the host's provider reveals nothing, so a present location within
the limit cannot be sent. These are the outcomes no refusal exposes. They are
**not counted as passed here**: `target-locations-vm-k180` closes each at V, with
the effect, and the walk's own tests above only support them.

- A present 1,023-byte file or directory, handed over and revealed (only the 1,024-byte
  refusal and the absent 1,023-byte path are seen at N).
- Within-limit 31- and 32-link chains, a final directory with mode 0600, one link
  inode in two directories, and multibyte and combining names, each resolved and
  then revealed with its accepted outcome. The walk resolves all of them at depth
  (above), and `LocationWalkTests` resolves them short; the reveal that follows is
  V's.
- **The reveal root decision** for `/`, `//`, `/.`, `/..`, `/var/..` and a link to
  `/` with and without a trailing slash. L checks that the planner asks the
  adapter about the literal text after the limit and submits as it answers
  (`RevealLocationTests`); the real adapter's two `lstat` calls are not in the
  package and are exercised only by the signed application. The walk itself shows
  `/`, `//`, `/.`, `/..` and `/../..` resolve to the root's identity and `/var/..`
  to `/private`.
- Prompt-free first use through the shipped bundle in Desktop, Documents and
  Downloads. The measurement above covers the walk's call sequence in a probe
  signed with Koine's identity and posture, not the provider's own process.
- A handle leaked by the walk, and a link whose text changes between two reads:
  neither is visible through a result. Both are tested at S through the recording
  system, which sees every handle and can change the text.
- Other macOS builds, removable and network volumes, and filesystems that admit
  neither a hard-linked symbolic link nor a 300-byte multibyte name (the
  corresponding rows print `NOT BUILT` and return rather than pass).
