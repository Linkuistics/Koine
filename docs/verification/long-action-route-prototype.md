# Long-location route prototype (k134)

**Result: below 1,024 bytes everything works; at the roughly 1,500-byte subjects
every tested public route that submits, classifies, registers or looks up the
location fails or answers nil — only parent-relative POSIX calls work.** One
signed throwaway probe measured one macOS 26.5 guest. It supplies a measured
feasibility picture and a recommendation for Antony's reaction. It is **not**
action or search acceptance, selects no production route, and changes no retained
meaning or working subject. The earlier
[source evaluation](long-action-route.md) and the
[reviewed boundary](long-action-native-boundary.md) stay binding.

Raw evidence: [`long-action-route/results/`](long-action-route/results/); probe
[`probe.m`](long-action-route/probe.m), builder
[`build-long-action-probe.sh`](../../scripts/build-long-action-probe.sh) and driver
[`vm-probe-long-action.py`](../../scripts/vm-probe-long-action.py)
(`task fixture:long-action-route` then `task fixture:long-action-route-vm`).

## What was measured

Paths are component-created with `mkdirat`/`openat` (245-byte components) so no
whole-path call ever built a fixture; signed apps were moved in with `renameat`.
Subjects: a plain document, a witness-handled document, a package, folder, links
(to file, dangling, to dot, a two-link cycle, a 45-link chain, below a file), apps
(a signed fixture, a signed witness, one malformed, one without a plist, one without
an identifier, one with an unreadable plist) and a 300-byte name; each at a
1,498-1,527-byte path. Threshold trees put a witness-document path at 900, 1,000,
1,023, 1,024, 1,025, 1,098 and 1,500 bytes. Short controls and all 79 installed
applications were measured the same way.

| Row | Measured outcome | Reading |
| --- | --- | --- |
| Presence, literal resolution, symlink/dot/trailing semantics | `openat`/`fstatat`/`readlinkat` resolved every case: existing, links, dot-link reused twice (finite), dangling → ENOENT at component 12, below-file/`/`/`/.`/`/..` → ENOTDIR, cycle detected from *active* expansion only, a 45-link chain → budget exhausted, missing → ENOENT. Whole-path `stat`/`realpath` fail with ENAMETOOLONG (63). | Supported, with truthful causes. |
| Impossible component | The 300-byte name: ENAMETOOLONG at its component with `fpathconf(_PC_NAME_MAX)` 255 → established impossible; creating one also fails (63). | Supported for ASCII; not a Unicode proof. |
| Native item flags and content type | `FSMakeFSRefUnicode` built from components fails **-43 (fnfErr)** at the component where the cumulative path passes 1,023 bytes; `FSPathMakeRef` whole, cwd-relative and `./name` also -43; `LSCopyItemInfoForURL` -10810; URL resource keys fail "file name is invalid". `getattrlistat` reads only object type (file/dir). | **No tested public route acquires flags/type.** -43 is also what a missing path returns (`short:missing`), so it cannot be read as absence. |
| Identity comparison | Not reachable: no reference can be built (above). | Pending. |
| Bundle identifier provenance | Component-relative read of `Contents/Info.plist` + property-list parse returned the identifier for both long apps, distinguished missing (ENOENT), malformed/no-identifier (parsed, none) and unreadable (EACCES 13). `Bundle`/`CFBundleCopyInfoDictionaryForURL` on the long URL return nothing. Across all **79** installed apps the identifier agreed with `Bundle` and `CFBundle` for **79**; every one has only the conventional `Contents/Info.plist`. | A candidate; parity shown only for this one layout, not a general guarantee. |
| FSRef parity on a short path | `/Applications/Safari.app` (a symlink into the cryptex volume): component-rebuilt reference fails -1407 while whole-path `FSPathMakeRef` succeeds. | Component rebuilding is not equivalent to the native whole-path reference. |
| Registration | `LSRegisterURL` on the long apps: -10810. `urlsForApplications(withBundleIdentifier:)` lists short and ≤1,023-byte copies (a 908-byte witness copy was found) but never a long one. | Long installations cannot be registered or selected; rows pending. |
| Default-handler lookup | `urlForApplication(toOpen:)` is nil for every existing file ≥ 1,024 bytes (document, link, package) and non-nil below. The long default-open diagnostic then stops with an internal "no-handler" label; it does not submit. | Nil is indistinguishable from "no handler"; that diagnostic label is not an established native negative or default-open result. |
| Open submission (NSWorkspace, explicit application) | Witness document delivered with exact bytes at 900, 1,000 and **1,023** bytes; **fails at 1,024 and above** with `NSCocoaErrorDomain` 256 "miscellaneous error" in about 9 ms; nothing delivered. Same for Zed and a long witness app. Short controls (witness, TextEdit window) positive. | A hard PATH_MAX boundary at the submission API. |
| Launch (constrained, another copy running) | Short cold launch and short-again-while-running returned the same process, executable path observed by the app itself, `proc_pidpath`, and `lsof`. The long copy fails with 256 in about 3 ms, cold or while the short copy runs. | Long launch not possible; short regression holds. |
| Reveal | Short control: accepted, Finder window observed. Long file and folder: `selectFile` returns NO, no window. | Fails with no cause. |
| Receipt identity | Observable only for short controls (callback `executableURL`, `proc_pidpath`, the app's own report and `lsof` agree). No long submission succeeded, so no long receipt exists to observe. | Pending. |
| First-use prompts (Documents) | Short handler lookup prompted (positive control, handler returned after denial). A long file's metadata walk prompted and the denial surfaced as EPERM at the `Documents` component. The long handler lookup answered nil with **no** prompt, because the API refused before reaching consent. | A long-lookup prompt behaviour is unmeasured: the API never got there. The `lsbind` row is void (the probe asked about the wrong item). |

## Limits, stated rather than hidden

- **Submission was probed without the contract's prerequisite gate.** The brief
  permits submission only after flags/type/registration prerequisites are
  established; they were not, so every long submission here is a *diagnostic of
  the API itself*, never an action result. They changed nothing in Koine and ran in a
  disposable VM.
- Pending, not passing: scripts/packages/native aliases/programs/apps
  classification (no flags route), identity comparison, exact-item binding,
  registered selection with a long copy, long receipt identity, long reveal
  observation beyond the failure, and the long-lookup prompt. No alias fixture was
  built.
- Only submission was measured at the exact boundary. The threshold sweep
  (`results/state.json`) submitted `sample.k134w` paths of 1,023, 1,024 and
  1,025 bytes but ran `stat`, `FSPathMakeRef` and handler lookup on the sibling
  `sample.txt`, two bytes shorter: those answered at 1,021, 1,022 and 1,023
  bytes, and their next tested length, 1,098, failed. Registration was tried
  only short and at about 1,500 bytes (`results/register.jsonl`). "1,023 passes,
  1,024 fails" below is exact for submission and bounded for the other services.
- One OS build (26.5/25F71), one SDK (27.0, clang 21.0.0), the probe signed Team
  `TA43A4RUP3` with Koine's entitlements and no usage keys; a reused VM; digest-frozen
  probe, builder, Info.plist/entitlements and archive (before = after in each of
  three runs: acquisition/registration/thresholds/launch/reveal, prompts, document
  submissions). The driver was revised between runs, so each run records its own digest.
- A first acquisition run lost rows to a descriptor leak (LS-launched processes
  have 256); the probe was fixed and the whole matrix rerun. A first `submit`
  attempt used a wrong Finder observer (Automation consent); the window list is the
  observer. Neither earlier result is used.
- Zed was a long submission target; TextEdit supplied a short positive submission
  control. Long default-open rows stopped at nil lookup and submitted nothing.
  No long default-handler delivery or handler-specific behavior is claimed.

## Recommendation for Antony's reaction

This section preserves k134's recommendation, **not an adopted contract**.
Antony later [retained the original requirement and commissioned broader
application research](long-action-route.md#decision-for-antony). No long working
case is dropped and no search actionability field is added.

The measured pattern is a PATH_MAX wall (1,023 passes, 1,024 fails) inside the
public classification, registration, lookup and submission APIs, while the
parent-relative POSIX route proves the item exists and says why it cannot be used.
No tested public route submits a ~1,500-byte location, and the prototype found no
unsupported-API repair inside the mandate (no shortening, alternate copy, file
reference URL, private policy or legacy opener).

**Recommended:** adopt, as an explicit and disclosed limit, *"locations at or over
1,024 bytes are verified to exist by component-relative resolution and then refused
with a distinct truthful failure (cannot be submitted), never reported missing"*.
Search keeps returning such items but marks them not actionable (k93's measured
omission). This is a workflow loss and needs his decision before adoption; the
alternatives are to leave the route pending, or to authorize a further non-public or
shortening route he has so far excluded.
