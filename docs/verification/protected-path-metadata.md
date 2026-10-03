# Protected-path metadata

**Answer: the tested metadata route was prompt-free; document default-handler
lookup was not.** On macOS 26.5 (25F71), a Developer ID, hardened-runtime probe
with Koine's empty entitlements and usage-key posture inspected first-use Desktop,
Documents and Downloads without prompting for the metadata calls below.
`NSWorkspace.urlForApplication(toOpen:)` prompted for a text file and a native
alias in each location. This limit is raised with Antony; protected default
opening and handler discovery remain pending. No new consent identifier,
entitlement or consent-acquisition route is approved by this evidence.

The [workspace spec](../specs/workspace-launch-and-open.md#operations) and
[workflow read policy](../specs/workflow-providers.md#dependency-results-and-failure-classification)
consume this answer. The [visual comparison](../design/architecture/index.html#diagram-workspace-inspection)
distinguishes metadata from the prompting handler lookup.

## Inspection results

Each cell describes the same result independently observed on **Desktop,
Documents and Downloads**. The raw [105 per-case records](protected-path-metadata/results.jsonl)
retain paths, times, PIDs, values/errors, pre/post consent and captured dialog
trees. Metadata means the specific public call and fixture below, not every
operation that could be called metadata.

| Exact call / input | Result in each location | Prompt |
| --- | --- | --- |
| `lstat`: text file, app bundle, existing symlink, dangling symlink | Present; device/inode/mode returned. Dangling link itself is present. | No |
| `lstat`: missing path | POSIX `ENOENT` (2). | No |
| `stat`: text file, app bundle, existing symlink | Present; follows existing link. | No |
| `stat`: missing path, dangling symlink | POSIX `ENOENT` (2). | No |
| `realpath`: existing symlink / dangling symlink | Resolved text path / POSIX `ENOENT` (2). | No |
| `URL.resolvingSymlinksInPath()`: existing / dangling symlink | Resolved text path / original dangling path. No error channel. This call alone cannot establish presence. | No |
| `URL.resourceValues(forKeys: [.isApplicationKey])`: text, app, alias | False, true, false. | No |
| Same, `.contentTypeKey` | `public.plain-text`, `com.apple.application-bundle`, `com.apple.alias-file`. | No |
| Same, `.volumeIdentifierKey` and `.fileResourceIdentifierKey`, separately | Native identity values for text, app and alias. | No |
| Same, `.isAliasFileKey` | False, false, true. The fixture is a real bookmark-file alias, not a renamed text file. | No |
| `Bundle(url:)` then `bundleIdentifier`: registered app bundle | Correct fixture identifier. | No |
| `NSWorkspace.urlForApplication(withBundleIdentifier:)` | Exact registered compatible fixture app in that location. | No |
| `NSWorkspace.urlForApplication(toOpen:)`: existing directory | Finder URL. | No |
| Same: text file | Files and Folders dialog, then TextEdit URL **after denial**. | **Yes** |
| Same: native alias file | Files and Folders dialog, then nil/indeterminate **after denial**. Opening aliases remains refused before this call. | **Yes** |
| Separate positive control: `Data(contentsOf:)` on text file | Files and Folders dialog, then `NSCocoaErrorDomain` 257 after denial. | **Yes** |

Application bundles were registered before measurement and remained present.
Each has a distinct fixture bundle identifier. The probe and every fixture are
compiled for arm64/macOS 26.0, independently signed under Team `TA43A4RUP3`.
Every registered-app result must match its expected fixture path or the collector
rejects the run. Constrained launch can combine the measured identity and bundle
metadata calls; unconstrained launch can first obtain the registered app and
then perform those same presence/identity checks. Neither route needs the
document default-handler call. This does not test a launch or a race.

## Handler lookup limit

These measurements do not cover the long-location component/native-reference
mechanisms discussed in the [action boundary analysis](long-action-native-boundary.md).
Replacing the whole-path metadata route requires its own signed no-dialog and
classification evidence; the result here cannot be generalized to that route.

Handler discovery is capable of raising consent even when the eventual result
looks usable. Suppressing NSWorkspace **submission** prompts does not establish
that this earlier **lookup** is prompt-free. A handler URL after denial cannot
be treated as proof of permission or a clean inspection. A nil after the alias
dialog cannot establish `NO_DEFAULT_HANDLER`.

The direct observations are visible in the
[Desktop](protected-path-metadata/desktop-handler-prompt.png),
[Documents](protected-path-metadata/documents-handler-prompt.png) and
[Downloads](protected-path-metadata/downloads-handler-prompt.png) screenshots.
The [Desktop content-read control](protected-path-metadata/desktop-content-control.png)
proves that a standalone probe is protected even though its preparing test agent
has Full Disk Access. All three content controls prompted and were denied.

Until the human resolves the trade-off, retain the current no-new-consent policy:
do not use the measured file-URL handler lookup as a prompt-free read or
pre-submission readiness check on protected documents. Protected default
opening remains a live acceptance gap. Named-app opening and reveal do not need
that lookup. Search must expose unknown/blocked handler coverage rather than
attempting it to discover consent; this experiment establishes no traversal or
content-search permission. Access failures remain `failed`, never inferred
absence or a newly invented `os-permission` identifier.

The recommended follow-up is an explicit, separately designed Files and Folders
setup if ordinary protected-document default opening is required. Keeping those
cases pending preserves the existing consent policy but leaves that workflow
unavailable. Type-only default matching is another contract, can ignore a
per-file opener, and is neither a measured fallback nor approved here. No deeper
native evidence chain is needed to answer this leaf's question.

## Scope and provenance

Measured 2026-09-30 in isolated TestAnyware clone `koine-k73`, from the macOS
golden. [Environment/signature/mount inventory](protected-path-metadata/environment.json)
records macOS 26.5/25F71, Developer ID `TA43A4RUP3`, hardened-runtime flag and
empty entitlements. The build uses Koine's Info.plist with only the probe's
identifier and display name changed. The [guest signing posture](protected-path-metadata/signing-posture.txt)
retains strict verification, the empty entitlement XML and the actual Info.plist.
No Files and Folders usage key is added.
The SDK/runtime-version stamp is 27.0.0; the deployment floor is 26.0.
This is one measured OS build, not proof for all supported releases or payloads.

Before **every** case, terminate prior probes, reset the probe's TCC entry, and
verify that its user and system TCC rows are absent. Launch through Launch
Services as a GUI application; every recorded parent PID is 1. Poll for a
matching completed result and inspect system-dialog trees before accepting it.
Deny any observed Files and Folders dialog and retain its text and outcome.
No case grants consent. Both the dialogs and the positive controls establish
that the probe has its own responsible identity; it does not inherit the
preparing agent's Full Disk Access.

[Subject digests before](protected-path-metadata/subjects-before.json) and
[after](protected-path-metadata/subjects-after.json) match for probe source,
alias helper, build script, collector, Koine Info.plist/entitlements and signed
archive. [Guest fixture digests before](protected-path-metadata/fixtures-before.txt)
and [after](protected-path-metadata/fixtures-after.txt) also match, covering
installed probe/fixture executables and plists, documents and aliases. One
collector wrote the results. Pilot runs are not the retained measurement.

| Additional scope | Outcome |
| --- | --- |
| Removable volume | **Unavailable**: this clone exposes an internal virtual disk and system asset mounts, with no external/removable device. An ordinary local disk image is not a removable-volume pass. |
| Network volume | **Unavailable**: no mounted network filesystem or configured share/credentials in the clone. The autofs home mapping is not a network-file inspection. |

No prompt-free conclusion extends to those scopes. Their operation acceptance
remains live where required. Denied POSIX metadata, unusual document types,
different bundle layouts, provider process receipts, real app submission,
Finder selection and directory enumeration were not accepted by this probe.

## Reproduce

Build without launching on the host: `task fixture:protected-path-metadata`.
The [build recipe](../../scripts/build-protected-path-probe.sh) uses the project's
signing identity, entitlements and OS floor. The [probe](protected-path-metadata/probe.swift)
contains the exact inspected calls; the [alias helper](protected-path-metadata/make-alias.swift)
is fixture preparation only.

Start a clean clone with `testanyware vm start --platform macos --id koine-k73`.
Upload `.build/protected-path-metadata.zip`, expand it with `ditto`, and copy
`KoineK73Probe.app` into guest `/Applications`. For each protected location,
make `~/LOCATION/k73`, copy its `FixtureLOCATION.app`, create `sample.txt`,
`link -> sample.txt` and `dangling -> missing`, and invoke the supplied
`make-alias sample.txt sample.alias`. Register each app with the guest's
Launch Services `lsregister -f`; prepare under the test agent, separately from
the probe. Never launch the measured executable as an agent/Terminal child.

Run `task fixture:protected-path-metadata-vm VM=koine-k73 OUTPUT=.build/k73-run`.
The [collector](../../scripts/vm-probe-protected-path.py) refuses an existing
output directory, missing registration, nonempty initial consent, missing
positive-control prompt, mismatched result or changed measurement subjects.
Its exit 0 means the measurement finished, not that every call was prompt-free.
It uses detached guest execution plus atomically published exit markers and
file transfer because the guest agent intermittently reports already completed
shells as timed out. Completion comes from the marker/result, never the launcher.
Semantic refusal actions returned HTTP 400 on this agent; VNC clicks use the
freshly observed refusal button's bounds. Stop the clone when finished with
`testanyware vm stop koine-k73`.
