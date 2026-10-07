# Descriptor-walk first-use prompts (k174)

**Answer: the walk's calls were prompt-free on first-use Desktop, Documents and
Downloads.** On macOS 26.5 (25F71), a Developer ID, hardened-runtime probe with
Koine's empty entitlements and no usage key resolved 12 locations in each folder
component by component, through `openat(O_SEARCH)`, `fstatat` and `readlinkat`,
without a Files and Folders dialog and without a TCC row. The two positive
controls in the same run, a read-mode directory open and a content read, prompted
in every folder. The [descriptor-relative access decision](../adr/filesystem-access-is-descriptor-relative.md)
therefore stands, and no whole-path fallback and no new consent is needed.

This closes the acceptance obligation the ADR and the
[workspace spec](../specs/workspace-launch-and-open.md#obligations-from-earlier-descriptor-walks)
left open ("search-only opens are unmeasured"), for this one OS build and these
call shapes.

## Results

Each cell is the same observation independently made in **Desktop, Documents and
Downloads** (36 walks, 3 single opens, 6 controls: 45 records in
[`results.jsonl`](descriptor-walk-prompt/results.jsonl), each with its call
sequence, return values and `errno`, its pre/post TCC rows and any dialog tree).

| Case (under `~/LOCATION/k174`) | Outcome | Prompt |
| --- | --- | --- |
| Walk to a file; to a relative link; to an absolute link (one link expansion each) | Present file | No |
| Walk to a link through a directory link (`dir-link/inner.txt`) | Present file | No |
| Walk to a file inside a subdirectory, and with `dir/../sample.txt` (physical `..` by `openat(handle, "..")`) | Present file | No |
| Walk to a directory, with and without a trailing slash | Present directory | No |
| Walk with a trailing slash after a file | Absent: not a directory | No |
| Walk to a missing name; to a dangling link | `ENOENT` at its component: absent | No |
| Walk to the folder itself (`~/LOCATION`), whose final component is examined by `fstatat` from `~` and never opened | Present directory | No |
| `open(~/LOCATION, O_SEARCH)`, one call | Handle returned | No |
| Control: `open(~/LOCATION, O_RDONLY\|O_DIRECTORY)` | `EPERM` after a dialog, denied | **Yes** |
| Control: `Data(contentsOf:)` on `sample.txt` | Cocoa 257 after a dialog, denied | **Yes** |

Every walk's `openat(O_SEARCH)` of `Desktop`, `Documents` or `Downloads` itself
returned a handle, and the `fstatat` of `k174` from inside it succeeded: the
descent through the protected folder is what was measured, not just a lookup of
the folder. The only failing calls in the 36 walks were the six `fstatat` calls
for a missing name or a dangling link, each `ENOENT`. The
[Desktop](descriptor-walk-prompt/desktop-read-open-prompt.png),
[Documents](descriptor-walk-prompt/documents-read-open-prompt.png) and
[Downloads](descriptor-walk-prompt/downloads-read-open-prompt.png) screenshots
show the read-mode control's dialog, so the probe could have shown a prompt.

## Scope and provenance

Measured 2026-10-07 in isolated TestAnyware clone `koine-k174` from the macOS
golden. [Environment, signature and mounts](descriptor-walk-prompt/environment.json)
record macOS 26.5/25F71, Developer ID `TA43A4RUP3`, the hardened-runtime flag and
the probe built from Koine's Info.plist with only its identifier and name changed;
the build does not add any usage key. The probe
([source](descriptor-walk-prompt/probe.swift)) makes only the walk's calls and
never lists a directory or opens a file. It was launched through Launch Services
(`open -n`) as a GUI app, never as an agent child, and the guest fixtures were made
by the test agent separately.

Before **every** case the driver terminated prior probes, reset the probe's TCC
entry and confirmed its user and system rows were empty; it denied any dialog it
saw and would have rejected a run whose control did not prompt. The
[subject digests](descriptor-walk-prompt/subjects-before.json) match
[after](descriptor-walk-prompt/subjects-after.json) for the probe, driver, build
script, Info.plist, entitlements and signed archive, and the
[guest fixture digests](descriptor-walk-prompt/fixtures-before.txt) match
[after](descriptor-walk-prompt/fixtures-after.txt).

What this does not show: other OS builds; removable and network volumes (the clone
has neither); a denied or restricted ancestor (the walk of a directory the user
cannot search is a unit-tested `failed` row, and its V observation belongs to
`target-locations-vm`); a Koine process whose responsible identity differs from the
probe's; paths of about 1,500 bytes (the ADR cites k134's component-relative calls
there, and the walk is the same call shapes); and the long-path prompt behaviour of
whole-path handler lookups, which this walk never makes.

## Reproduce

`task fixture:descriptor-walk-prompt` builds and signs
`.build/descriptor-walk-prompt.zip` without launching anything. Start a clean clone
(`testanyware vm start --platform macos --id koine-k174`), upload the zip, expand
it with `ditto -x -k`, copy `KoineK174Probe.app` into `/Applications` and register
it with `lsregister -f`. Then run
`task fixture:descriptor-walk-prompt-vm VM=koine-k174 OUTPUT=.build/k174-run`; the
driver builds the fixtures itself. `task fixture:descriptor-walk-prompt-check`
lints the driver and build script without a guest.
