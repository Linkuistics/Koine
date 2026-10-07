# The receipt's executable identities (receipt-executable-identity, k183)

**Result: the receipt's third step compares two executables, the live process's (from `proc_pidpath`) and the
retained application object's (from `executableURL`), and both are now acquired by the descriptor walk and compared
as the walk's device and inode. Neither route uses `resolvingSymlinksInPath`, `realpath` or a pathname resource
value any more, observation applies no length limit, and every walk outcome other than a present executable is
the existing `process: null`. A mismatch is still a mismatch.** It is accepted at **L and N**; the effect on a
real launch's receipt is for `application-locations-vm`. Every check was seen to fail against a deliberately broken
source.

The contract is the [workspace spec](../specs/workspace-launch-and-open.md#resolving-an-action-location) (the last
sentence of its absence paragraph) and the [descriptor-relative decision](../adr/filesystem-access-is-descriptor-relative.md).
The walk is [reveal's](reveal-locations.md), the device-and-inode comparison is the
[supplied stage's](application-locations.md); this leaf is the third consumer of both, and the only one that
runs after the platform has acknowledged an action.

## What was built

| Piece | Where | What it does |
| --- | --- | --- |
| The rule | `Providers/WorkspaceProvider/Logic/ExecutableIdentity.swift` | `ExecutableIdentity.of(path:)`: the walk's identity for an absolute path given as bytes, when the walk finds the object present, and nothing for every other outcome (absent, a cycle, an impossible name, the link budget, a denial, any other failure) and for a spelling that is not absolute. It never reads `HandOffLimit`: the action was acknowledged, so a present executable of any length has an identity and nothing here can turn an action into a refusal or `failed`. |
| The live identity | `NativeWorkspace.liveExecutableIdentity(of:)` | `proc_pidpath` into a 4,096-byte buffer (the SDK's `PROC_PIDPATHINFO_MAXSIZE`), the bytes up to the NUL handed to the rule. The path is never decoded to a `String`. |
| The retained identity | `identityOfExecutable(at:)`, `RunningApplication.executableIdentity` | The object's `executableURL`, from the URL's own filesystem bytes (`withUnsafeFileSystemRepresentation`, never `URL.path`), handed to the same rule. Nil for a URL that is not a file URL. |
| One representation | `Native.swift` | `LaunchedApplication.executableIdentity` and `WorkspaceNative.liveExecutableIdentity(of:)` are both `ObjectIdentity?`, the walk's device and inode. `FileIdentity` (a Foundation volume and file resource identifier, which a device and inode can never equal) is gone. |
| What went | `fileIdentity(ofPath:)`, `FileIdentity` | The symlink-resolving, pathname-resource route both identities used. `observeProcess` is unchanged: the same five steps and the same `nil` for every unavailable value or mismatch. |

Nothing else in the retained rule moved: the start-sample, retained-object, terminated and fresh-lookup steps are
the ones [launch-vm.md](launch-vm.md) measured, and no PID-only identity, launch-date substitute or foreground
fallback was added.

## Evidence

| Seam | Where | What it holds |
| --- | --- | --- |
| L, the rule | `ExecutableIdentityTests` | On real host fixtures built component by component, with the shipped walk: a present executable of 100, 1,023, 1,024, 1,025, 1,500, 4,096 and 4,200 bytes yields the device and inode `fstatat` gives it, so no length is special; a path through relative and absolute links and a final link yields the object's identity and never a link's; a chain of 31 and 32 links resolves and 33 yields none; a missing name, a dangling link, a name below a file, a cycle (two links and a self link), a 300-byte name, a directory without search permission and a step that fails for any other reason (a stand-in that answers `EIO`) each yield none; a relative or empty spelling yields none and is never read from `/`. Two hard links to one file are one identity and a copy of its bytes is another. |
| L, the rule's use | `ObservationTests` | The third step on equal identities, different inodes, the same inode on another device, the object's executable unavailable, the live one unavailable and both unavailable: only equal identities observe, and two unavailable values are not equal. The start-sample, terminated, vanished-process and fresh-lookup rows are unchanged. |
| N | `ReceiptExecutableIdentityTests` | Described below. |
| Call path | `task check:launch-call-path` | A new section enumerates the two routes: no `fileIdentity(ofPath:)`, `FileIdentity`, `resolvingSymlinksInPath`, `realpath`, file or volume resource identifier or `standardizedFileURL` remains in the provider; the live route is `proc_pidpath` once, then the rule; the retained route is the URL's filesystem bytes, then the rule; the rule is called from exactly those two places, resolves by `LocationWalk`, yields an identity for a `.present` location alone and mentions no limit, length or refusal; the seam declares exactly two identities and both are `ObjectIdentity`; observation still compares them. Each pattern is first seen to match a control. |

`task test` builds the probe with the bundles and passes with all of it: 236 provider-logic tests and 423 in
the server suites, with the signed-bundle suites (the walk, the supplied application) unchanged.

### N: how a host test reaches the shipped adapter without a launch

The signed bundle reaches observation only after an acknowledged launch, which a host test must not make, and it
exports no symbol. So `Fixtures/ReceiptIdentityProbe` (`task fixture:receipt-identity-probe`, built with the bundles by
`task test`) compiles the provider's own `Logic/` and `Sources/` exactly as `Providers/WorkspaceProvider/build.sh`
compiles them (same flags, staged framework and deployment floor), linked with a short entry point as an executable
instead of as the provider's dylib. It is an independent build of the shipped sources, never a copy and never a
mutation of them. The test **starts the probe itself, as a process it owns**, from a copy placed in a fixture and by
a spelling it chooses, and the probe prints what `NativeWorkspace.liveExecutableIdentity(of:)` and
`RunningApplication.executableIdentity` answer for itself. `NSRunningApplication.current` has no `executableURL` for a
plain command-line process; the probe sets a `prohibited` activation policy, which gives it one with no window, Dock
tile or activation. The independent observers are the test's own component-relative `fstatat` of the file it placed
and, where the spelling is short enough, the kernel's own `stat`.

| Subject | What it shows |
| --- | --- |
| A running process at short depth | Live and retained identity equal the placed file's device and inode. |
| A running process at the deepest the kernel runs, 1,023 bytes, started through two links | The kernel reports a 1,023-byte path, and the platform reports the retained object's executable as the spelling the process was started by (291 bytes through the links, with a leading `/private` dropped), so the retained walk really goes through two links. Both identities equal the file's. The row pins that observation, which is not documented, so a platform that reports the physical path is noticed. |
| An executable deleted while it runs | The kernel has no path for the process (`proc_pidpath` fails) and the retained object keeps the URL it had, which the walk finds absent: neither is an identity, so the receipt's process would be null, and neither is a stale identity. |
| The retained route's own conversion, at 1,023, 1,024, 1,025, 1,500 and 4,200 bytes and through a relative link, an absolute link, 32 and 33 links, an absent file, a cycle and an impossible name, all at about 1,500 bytes | A present executable yields the device and inode at every length and every link form the budget allows, and every other row yields none. The 32-link chain resolves and the 33-link chain does not. |
| Every application already running on this host (read, never launched or touched) | For each that reports both identities, the walk's verdict, the same file or not, equals the verdict of the route it replaced (a symlink-resolving URL and the platform's resource identifiers), which the probe keeps as its independent observer. On 2026-10-07 on macOS 26.6.2 (arm64): 142 applications, 139 report both, 137 are the same file, 2 are not, and the walk and the route it replaced disagree on none. |

The two that are not the same file are real mismatches the third step exists to catch, and both routes say so:
`NSRunningApplication` reports `com.apple.WebKit.WebContent` as the executable of a process that is actually running
`com.apple.WebKit.WebContent.EnhancedSecurity`, a different file in the cryptex at another inode. The walk gives them
different inodes, as the resource identifiers do, so a receipt for such a process would be null as before. Three other
processes report an `executableURL` that is not an absolute path to a present file, and no identity: the same on both routes.

## What a running process cannot show

The brief asked for a running process at about 1,500 bytes. **There is no such process on this host.** The kernel
kills (`SIGKILL`) a program at exec when its executable's physical path is 1,024 bytes or more, and refuses to spawn
one at 1,200 (`ENAMETOOLONG`); 1,023 bytes runs. This was measured with copies of the probe placed component by
component and started by a short spelling through links, by `posix_spawn` and by fork and exec: 1,023 ran, and 1,024,
1,025, 1,050, 1,090, 1,100 and 1,138 were killed. So no running process has a path longer than the one the walk already
took, which is why the spec says the limit adds no systematic `process: null`; this is the observation behind it.
`proc_pidpath` can report up to 4,096 bytes, and the rule takes them all, but nothing the kernel runs reaches that.

What N shows instead, and states as what it is: running processes at short depth and at 1,023 bytes through a link
chain, for both identities; and the retained route's own conversion, the function `RunningApplication` calls, on a
present executable of 1,024 to 4,200 bytes and through every link form, which is a real acquisition on a real file and
not a running process's. `ReceiptExecutableIdentityTests` keeps a row that starts a process at 1,024, 1,025 and 1,100 bytes
and passes when the kernel kills or refuses it, but requires both identities if a future macOS lets it run.

## Mutation results

`task check:location-walk-mutations` gained suites X (`ExecutableIdentityTests`), V (`ObservationTests`) and R
(`ReceiptExecutableIdentityTests`), and its build step builds the probe. Existing walk mutations that the new suites
reach name them (the link budget ones; an absolute link that keeps the old directory changes only the walk's `resolved` text, never an identity, so X and R cannot see it and do not claim to); six mutations are new. All were seen.

| Broken decision | Red |
| --- | --- |
| the link budget allows a 33rd link, or stops at 31 | S, N, X, R |
| observation applies the hand-off limit | X, R |
| an absent executable has an identity | X, R |
| a relative spelling is read from the root | X |
| an unavailable identity matches an unavailable one | V |
| the live identity reads another process | R |
| a URL longer than the limit is unavailable | R |

`task check:launch-call-path-mutations` (new) breaks one decision of the two identities at a time in a throwaway copy of
what the check reads and requires the check to fail with the message that names it. The unmutated copy passes first.
All thirteen were seen: a symlink-resolving call or a resource identifier reintroduced, either identity not acquired by the
walk, the live path decoded to a `String`, the retained path taken from `URL.path`, the kernel's path read twice, a third
acquisition, the rule applying the limit, the rule not using the walk, the rule reading an absence as an identity, one side in
another representation, and observation no longer comparing.

## Findings of the fresh-context read

One reviewer was given the rule, the walk, the third step and the two adapter functions with the contract and told to find
what is wrong. It found no crash, out-of-bounds read, hang, length limit, PID-only data or `nil == nil` comparison, and
no input where the walk names another object than the kernel's own lookup would. Classified:

- **A visible trade-off, as the spec states:** both identities come from the path as it exists at the read, not from the
  running vnode, so an executable replaced at the same path while the old one still runs is a false equal that the start
  instants do not cover. The spec calls the rule an observation and not an atomic binding, and the replaced route had the
  same property.
- **A visible trade-off, `LocationWalk` as accepted in k174:** the walk's per-component list handling is quadratic in path
  length (4,200 bytes ran in milliseconds), a directory swapped for a link between the walk's `fstatat` and its `openat`
  is followed, and a final object of any type is `present`. None changes what an executable's identity is.
- **Noise:** a filesystem reporting `st_ino` 0 (no such filesystem is a place an application runs from here), and a
  file-reference URL (`NSRunningApplication` does not return one).
- **A contract the reviewer could not check from source, which N does:** that Foundation's filesystem representation does
  not cap at `PATH_MAX` or repair the name. The retained route's rows at 1,024, 1,025, 1,500 and 4,200 bytes yield the
  file's identity, so there is no length cap. A name that is not valid UTF-8 is **not** exercised (the fixtures build
  names from `String`); the URL's representation is the platform's own bytes, and this is left a visible trade-off, as in
  every earlier stage.

## Not changed, and what is left

- Observation at V for the real launcher fixtures, with an actual launch's receipt non-null, is
  `application-locations-vm`. Nothing was launched on this host: the processes N used are the test's own, and the running
  applications were only read.
- A retained object whose platform-reported `executableURL` is not the file the kernel runs (the WebKit content process
  above) is null, as it was.
- An `executableURL` is read as the platform reports it: if it is a relative URL, the filesystem representation is
  whatever Foundation gives it, and the walk finds it absent or present like any other absolute spelling. The three
  processes above that report one are not identified on either route.
- Short launch, named open and reveal receipts keep every accepted outcome: the planners and the stages were not
  touched, and `observeProcess` differs only in the type it compares.
