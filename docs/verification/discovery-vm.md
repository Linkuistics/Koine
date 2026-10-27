# Discovery reads in a disposable VM

This record covers the V seam of workspace release 1.0.2. It reports one passing run of `task app:vm-verify-discovery` on the development-signed bundle. The run reads the special locations and the application catalogue, and launches one listed application. The first run of the application query found a defect in the search scope. This record describes the defect and the change that fixed it.

## Subjects and procedure

The bundle under test is `.build/app/Koine.app`, signed by Developer ID team TA43A4RUP3. It is not notarised, and Gatekeeper rejects it as "Unnotarized Developer ID". This matches the installation posture of the earlier VM records. The release checks on the notarised build belong to the release leaf.

The recipe is `scripts/vm-verify-discovery.sh`. It clones the TestAnyware image `koine-launchers-prepared` into a new VM. The passing run used the clone `koine-verify-56449`. The guest is macOS 27.0.1 (26A434) on arm64. No application runs on the host.

The contract-only client sends every request. The client finds Koine from the endpoint descriptor alone. It enrols two grants, and the recipe approves each in the Koine window. The read grant holds `workspace:read`. The control grant holds `workspace:control` and `desktop:control`. The schema digest that the client was generated against equals the one that Koine served: `7534c4f66f38a1cdd9dc536ca22f96b872025300b6838e7ec99daaf0d4570501`.

The guest probe `scripts/vm-discovery-index-state.sh` runs before Koine reads anything. It asks the guest's own Spotlight for its state and for the bundles that it lists. A missing application can then be told apart from an index that is still building.

## Result

The run passed. The recipe records no failed check. The raw results are in [`results.json`](discovery-vm/results.json) and the full transcript is in [`transcript.log`](discovery-vm/transcript.log).

| Done-when point | Observed |
|---|---|
| The index state is recorded before the catalogue is read | Four samples at 1, 21, 41 and 62 seconds. Each sample counts 327 application bundles. The index counted as settled after the third equal sample. |
| The catalogue lists Safari, Finder and the twelve launchers | The status is `AVAILABLE` and the source `INDEXED_APPS` is `COMPLETE`. The catalogue lists 327 applications and none is missing. |
| Each of the ten default locations has a value | Every pair has an absolute path from `FOUNDATION_LOCATIONS`. |
| One listed application launches through `workspaceLaunchApplication` | Notes launched with the identifier and path from the catalogue. |
| No permission dialog names Koine during the reads | None appeared after the refused reads, the locations read, the catalogue read or the launch. |

The Safari and Finder lookup is not needed. Both applications are in the settled index, so Koine adds no lookup by registration. The `REGISTRATION` lookup stays unbuilt.

## The index before the read

The guest's Spotlight reported `Indexing enabled.` at 1 second. From 21 seconds it reported `Index is read-only.` The application-bundle count did not change. The sample file is [`index-state.json`](discovery-vm/index-state.json).

## The special locations

The read returns 11 items, and the ten default pairs each have one. The system applications location has two values, because Foundation names a second path on the cryptex volume. The contents availability of every item is `UNKNOWN`. The table by pair is [`locations-by-pair.json`](discovery-vm/locations-by-pair.json).

| Pair | Value in the guest |
|---|---|
| `HOME/USER` | `/Users/admin` |
| `DESKTOP/USER` | `/Users/admin/Desktop` |
| `DOCUMENTS/USER` | `/Users/admin/Documents` |
| `DOWNLOADS/USER` | `/Users/admin/Downloads` |
| `MOVIES/USER` | `/Users/admin/Movies` |
| `MUSIC/USER` | `/Users/admin/Music` |
| `PICTURES/USER` | `/Users/admin/Pictures` |
| `APPLICATIONS/USER` | `/Users/admin/Applications` |
| `APPLICATIONS/LOCAL` | `/Applications` |
| `APPLICATIONS/SYSTEM` | `/System/Applications` and `/System/Cryptexes/App/System/Applications` |

## The application catalogue

Each application below was in the guest index before Koine read, and the catalogue lists it with the same path. The recipe holds the twelve launchers to their exact paths from the launcher inventory. It holds Safari and Finder to their identifiers only. The record by application is [`catalogue-by-application.json`](discovery-vm/catalogue-by-application.json).

| Application | Identifier | Path |
|---|---|---|
| Safari | `com.apple.Safari` | `/Applications/Safari.app` |
| Finder | `com.apple.finder` | `/System/Library/CoreServices/Finder.app` |
| Dia | `company.thebrowser.dia` | `/Applications/Dia.app` |
| ChatGPT | `com.openai.codex` | `/Applications/ChatGPT.app` |
| Claude | `com.anthropic.claudefordesktop` | `/Applications/Claude.app` |
| Zed | `dev.zed.Zed` | `/Applications/Zed.app` |
| Visual Studio Code | `com.microsoft.VSCode` | `/Applications/Visual Studio Code.app` |
| Jump Desktop | `com.p5sys.jump.mac.viewer.web` | `/Applications/Jump Desktop.app` |
| Kimi | `com.moonshot.kimichat` | `/Applications/Kimi.app` |
| iTerm | `com.googlecode.iterm2` | `/Applications/iTerm.app` |
| Mail | `com.apple.mail` | `/System/Applications/Mail.app` |
| Notes | `com.apple.Notes` | `/System/Applications/Notes.app` |
| Obsidian | `md.obsidian` | `/Applications/Obsidian.app` |
| Zotero | `org.zotero.zotero` | `/Applications/Zotero.app` |

## The launch

A grant with `workspace:read` alone cannot launch. It received `capability-denied` and named `workspace:control` first, with the complete set `workspace:control` and `desktop:control`. The recipe checked that no instance of Notes was running afterwards.

The control grant then launched Notes with the identifier and path from the catalogue entry. The client's answer came 247 milliseconds after the request. The independent `LaunchWitness` saw Notes active 269 milliseconds after the request. The receipt that the client printed equals the kernel's process identity: process 1439, with the timestamp `2026-10-27T05:57:43.534693Z`.

## The grant checks

A grant with both controls and no read capability cannot read. Both reads came back with `capability-denied` and named `workspace:read`. The failure arrives as HTTP status 200 with the field null, because the refusal is per field. The files are [`control-locations.json`](discovery-vm/control-locations.json) and [`control-applications.json`](discovery-vm/control-applications.json).

## The defect that the first run found

The first run of the catalogue read returned status `UNKNOWN`, the reason `METADATA_UNKNOWN`, and no items. The guest's own `mdfind` listed 327 bundles at the same time. The adapter set `NSMetadataQueryIndexedLocalComputerScope`, as the design said.

A probe in a fresh guest process shows the cause. The notes are in [`scope-probe.txt`](discovery-vm/scope-probe.txt) and the source is [`scope-probe.swift`](discovery-vm/scope-probe.swift). Under the indexed local computer scope, the finish-gathering notification arrives with no items. The 327 bundles then arrive by update notifications over about 75 seconds. With no scope set, all 327 arrive at the finish notification. The SDK header says that an unset scope has "no limitation on its search scope".

A catalogue call cannot wait 75 seconds, because the provider waits three seconds. The human chose to leave the scope unset. The adapter, its comments, the spec, the three schema descriptions and the coverage `declaredDomain` changed together. The `declaredDomain` is now `indexed applications`. The cause was not found beyond this evidence.

## What this run does not cover

- **Network volumes.** An unset scope can list applications on network volumes and in a remote home folder. This run read none. The served disclosure names both, as issue 13 asked, and the G test pins that wording. No run read a remote location.
- **The host.** No discovery read ran on the host, as the rules require. This record does not show whether the indexed scope fills slowly on a host with a long uptime. It does not show the behaviour of a second query in one process.
- **The deadline.** Issue 12 (the timeout waits behind native work) was not met in this run, because the query finished at once.
- **The root certificate.** The cost certificate still names the indexed local computer scope. The change removes that one call, so its bound still holds.
- **The notarised build.** The release leaf owns those checks.

## Reproduce

Run `task launchers:prepare` once to build the image. Run `task client:capture` and `task client` to refresh the client. Run `task app:vm-verify-discovery` to repeat the check.
