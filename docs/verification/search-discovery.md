# Application and file discovery

**Applicability:** This report preserves its original raw/custom-search subjects
and measured limits for comparison. The [native contract](../specs/workspace-search.md)
and [finite acceptance](native-discovery-acceptance.md) own current sources,
resource subjects, exact profiles and pending native verdicts. Useful existing
branch/ownership/independent-observer controls are adapted there; obsolete raw
mechanics or successful historical captures supply no native catalogue pass.

**Reuse-design reconciliation:** the [current tool-backed contract](../specs/workspace-search.md)
and [finite backend evidence](search-tooling.md) replace custom traversal/witness
mechanics below. Retain this document as bounded prior evidence/design analysis,
not an implementation prescription or acceptance of the new backend. Applicable
native fact, permission and serviceability obligations remain live.

**The earlier bounded directory-name enumeration comparison.** It found
ordinary files and application candidates inside the actual signed hardened
Koine host without prompting in this macOS 26.5 VM. Protected directory
enumeration and a Spotlight query scoped to Desktop prompted. Search must skip
such traversal before native access under the current no-new-consent policy.
Neither successful Spotlight startup nor its result count diagnoses index
availability. The [search design](../specs/workspace-search.md) now fixes the API,
coverage types and scoped diagnostics; implementation and acceptance are pending.

The [comparison view](../design/architecture/index.html#diagram-search-discovery)
shows the measured branches. The preceding
[protected metadata experiment](protected-path-metadata.md) remains binding:
its metadata result does not authorize traversal, content reads or document
default-handler lookup. This experiment adds no entitlement, usage key, consent
identifier, setup flow or content-type-only handler substitution.

## Exact mechanisms and results

The retained [per-case records](search-discovery/measurement/results.jsonl)
contain the input, PID, parent PID, native values/errors, prompt trees and
pre/post consent. Every case has a fresh Koine process with parent PID 1 and
`dev.antony.Koine` as its main bundle identifier. There are seventeen cases.

| Public calls / fixture | Outcome | Prompt |
| --- | --- | --- |
| `FileManager.contentsOfDirectory(at:includingPropertiesForKeys:options:)`, ordinary home fixture, `.skipsHiddenFiles`; recurse using `.isDirectoryKey`, `.isSymbolicLinkKey`, `.isPackageKey` | Two text files, one nested directory and one symlink returned. The protected-directory symlink was not traversed. | No |
| Same traversal starting at home, with Desktop/Documents/Downloads/Library excluded before descent; hidden entries, package contents and symlink directories omitted | Sixteen visible entries returned; protected roots and the Photos library package were skipped. Library was hidden and absent from the listing. This is partial home coverage. | No |
| Same listing, an existing empty ordinary directory | Empty list, without an error. | No |
| Directory listing of `/System/Applications`; `.isApplicationKey`, `Bundle(url:)?.bundleIdentifier`, `NSWorkspace.urlsForApplications(withBundleIdentifier:)` | Forty-six top-level application candidates, each with an identifier and a registration URL equal to its candidate path. This count describes the measured fixture, not an exhaustive installed-app inventory. | No |
| Same inspection of `/Applications` | Koine was the one application candidate and its registration matched. | No |
| Directory listing of the `k19` subdirectory independently in Desktop, Documents and Downloads | Files and Folders dialog; denial then `NSCocoaErrorDomain` 257. | **Yes**, each root |
| Positive control: `Data(contentsOf:)`, Desktop text file | Dialog; denial then Cocoa 257. | **Yes** |
| `NSMetadataQuery`, ordinary fixture root; `kMDItemFSName CONTAINS[cd] "KoineNeedle"`; start, await initial gathering, disable updates, read paths, stop | `start() == true`, gathering finished, both fixture files returned. | No |
| Same query, empty ordinary directory | Startup true, gathering finished, zero results. | No |
| Same query, Desktop fixture | Dialog; after denial startup true, gathering finished, zero results and no native query error channel used by this probe. | **Yes** |
| Same query after `mdutil -i off /`; system reported indexing disabled | Startup true, gathering finished, both previously indexed paths still returned. | No |
| Same query on a fresh APFS disk image whose indexing was disabled before its text fixture was written | Startup true, gathering finished, the one filename returned. `mdutil` reported `kMDConfigSearchLevelFSSearchOnly`. | No |
| Ordinary directory traversal and system-app inspection repeated with indexing disabled | The same ordered fixture paths and the same application records as their enabled-index counterparts. | No |
| Directory listing on the disabled-index disk-image fixture | The one filename returned. | No |

The probe performs **name discovery**, not content search. It performs no
document default-handler lookup. Names in protected root entries do not imply
permission to descend into those roots. The direct protected accesses above
are deliberately prompting experimental controls inside the disposable VM;
they are not acceptable product read paths.

Apple documents directory listing and per-identifier application-registration
lookup as public APIs:
[directory listing](https://developer.apple.com/documentation/foundation/filemanager/contentsofdirectory(at:includingpropertiesforkeys:options:)),
[application URLs](https://developer.apple.com/documentation/appkit/nsworkspace/urlsforapplications(withbundleidentifier:)).
The [Spotlight query guide](https://developer.apple.com/library/archive/documentation/Carbon/Conceptual/SpotlightQuery/Concepts/QueryingMetadata.html)
describes scoped asynchronous metadata search and user exclusions. These
references identify mechanisms; the prompt and disabled-index behavior above
is measured on this OS build and is not inferred from those documents.

## Design consequences and limits

**Application discovery.** Enumerate stated application roots, recognize bundle
candidates and validate each identifier/path against public registration data.
Registration lookup is by identifier, not a public enumeration of every
registered application. The measured roots are `/System/Applications` and
`/Applications`, at one level. The API design must state its defaults, nested
folder policy, client-specified roots, duplicate installation identity and
bounds. Applications installed elsewhere, inaccessible folders and unknown
metadata require explicit coverage/unknown outcomes. A path plus identifier
can feed the already specified constrained launch selector; the action still
revalidates installation. Discovery does not register or launch an app.

**File discovery.** Prefer bounded directory enumeration for filename matching,
with explicit scope exclusions. This removes an index-health prerequisite from
the chosen mechanism. No measured claim authorizes a content read. The API must
declare every searched/skipped scope, bounds and ordering, and distinguish an
empty completely searched scope from empty partial/unknown coverage. Home
search is necessarily partial under the current consent policy. This is a
stated limit, not permission to mark the full baseline accepted.

**Protected traversal.** Never call either measured prompting mechanism to
discover whether the user has granted consent. Under the unchanged posture,
skip Desktop, Documents, Downloads and sensitive Library descendants before
descent, including a root supplied directly and a known symlink-resolved route.
Do not assume the absence of Accessibility consent answers Files and Folders.
Exact extension-only consent diagnostics and aggregate permission outcomes must
be settled by the following API design without inventing a consent identifier
or changing desktop fields. If completing protected-home discovery requires a
new consent/setup contract, raise that specific trade-off with Antony before
depending on it. No such change is approved here.

The observed access-denied TCC rows name the three Files and Folders services;
they are measurement facts, not approved Koine public consent identifiers. The
host also recorded an Accessibility denial through its ordinary startup check,
without a dialog. All cases started with no Koine TCC rows and none granted
consent. A native access failure without a positively established public
consent mapping remains an error/unknown cause, never inferred absence.

**Index availability.** Disabling indexing did not produce a failed query or
uniformly empty results, including the fresh disk image. The experiment does
not establish that a missing store, disabled search daemon or excluded scope
has a distinct public NSMetadataQuery outcome; none was separately manufactured.
The measured successful zero after consent denial is already indistinguishable
from healthy empty if a caller reads only startup/count. Do not infer
`INDEX_UNAVAILABLE`, healthy complete coverage or permission from those values.
Do not run `mdutil`/`mdimport`, parse private Spotlight stores or change system
index settings in production. They are fixture preparation/control only.
Directory search needs no index dependency result; if an index-based alternative
is selected later, it must expose unknown coverage unless a concrete supported
availability signal is established.

**Platform limits.** Enumeration is not an atomic filesystem snapshot. Rename,
replacement and symlink races can occur between classification and descent;
the measured exclusions are not a proof against adversarial same-user changes.
The diagnostic stops scheduling another directory once at least 3,000 paths
have been returned. A single Foundation listing materializes all its entries
and can exceed that threshold; it establishes no hard result/memory bound or
syscall deadline. Production bounds and cancellation need separate design.
No result guarantees future existence, readability, launchability or an opener.
The existing handler metadata limit still applies: keep it unknown/blocked where
a prompt-free route is unestablished.

No exhaustive Launch Services inventory, recursive application-root coverage,
unreadable bundle, bundle without an identifier, arbitrary protected location,
cloud placeholder, content search or real network/external physical volume was
accepted. The test volume was an ordinary local disk image, even though
`diskutil` describes it as external/removable. It is not physical removable-media
acceptance. The golden's system applications and Koine suffice for this mechanism
comparison; the following implementation acceptance must install the required
real applications. Query latency and action/clipboard behavior are not measured
by this experiment.

## Design handoff

The [scope/coverage view](../design/architecture/index.html#diagram-search-coverage)
and [action handoff](../design/architecture/index.html#diagram-search-handoff)
consume this report in the [search contract](../specs/workspace-search.md).
The [coverage decision](../adr/search-coverage-describes-observations.md) adopts
this comparison without claiming an index-health signal or exhaustive inventory.
The chosen stream adapter is different from this probe's Foundation array
listing. Its no-follow, resource and cancellation behavior needs its own signed
VM acceptance; this report cannot prove it. The design keeps protected traversal
blocked and adds no consent identifier, entitlement or setup. Earlier references
to the following API design name this consuming step, not shipped functionality.

## Provenance and reproduction

Measured 2026-10-03 in isolated clone `koine-k19`, from the macOS golden,
arm64/macOS 26.5 (25F71). The
[environment](search-discovery/measurement/environment.json) retains the strict
deep signature verification, runtime flag, Developer ID Team `TA43A4RUP3`, empty
entitlements, unchanged Koine Info.plist, mount inventory and both index states.
The deployment floor and runtime signature stamp are 26.0.0. The test-only
instrumented workspace provider runs inside the actual Koine executable and
provider lifecycle; it adds no schema operation and changes no production source.
It is not release conformance or a signed standalone probe borrowed as a proxy.

The copied host's program bytes before its Mach-O `LC_CODE_SIGNATURE` blob
match the production build exactly, and its Info.plist matches the source.
Re-signing the copied bundle changes the signature blob because it seals the
instrumented provider; it does not replace the host program with a probe.

[Subject hashes before](search-discovery/measurement/subjects-before.json) and
[after](search-discovery/measurement/subjects-after.json) match for the probe,
build script, collector, reused transport, Info.plist, entitlements and signed
archive. [Guest fixture hashes before](search-discovery/measurement/fixtures-before.txt)
and [after](search-discovery/measurement/fixtures-after.txt) match for the host
executable/plist, diagnostic provider image and fixture contents. One collector
wrote the retained results. The earlier pilot run is not retained measurement.

The dialog screenshots are
[Desktop enumeration](search-discovery/measurement/desktop-enumerate-prompt.png),
[Documents enumeration](search-discovery/measurement/documents-enumerate-prompt.png),
[Downloads enumeration](search-discovery/measurement/downloads-enumerate-prompt.png),
[Desktop Spotlight](search-discovery/measurement/spotlight-protected-prompt.png)
and the [content control](search-discovery/measurement/desktop-content-control-prompt.png).
Each dialog was observed, captured and denied. The positive control proves
Koine's own responsible identity was subject to TCC even though the preparing
agent could read these fixtures.

Build without launching on the host: `task fixture:search-evidence`. The
[build recipe](../../scripts/build-search-evidence.sh) copies the production
provider with its shared-source symlinks dereferenced, injects the
[diagnostic](search-discovery/probe.swift) into workspace startup, replaces only
that provider in a copied real Koine bundle and signs inside-out with the normal
identity and entitlements. The host application and public contribution stay
unchanged in behavior; its diagnostic bundle must never be distributed.

Start a clean clone: `testanyware vm start --platform macos --id koine-k19`.
Upload `.build/search-evidence/Koine.zip` to `/tmp/Koine.zip` and expand it with
`ditto -x -k /tmp/Koine.zip /Applications/Koine.app` in the guest. Prepare, using
the test agent rather than Koine:

- An ordinary `~/K19SearchEvidence/KoineNeedleA.txt`,
  `nested/KoineNeedleB.txt`, and `protected-link -> ~/Documents`.
- Empty `~/K19Empty`, and `~/Desktop/k19/KoineNeedle.txt`,
  `~/Documents/k19/KoineNeedle.txt`, `~/Downloads/k19/KoineNeedle.txt`.
- A fresh 128 MiB APFS disk image mounted at `/Volumes/K19NoIndex`; disable its
  indexing with `sudo -n mdutil -i off /Volumes/K19NoIndex` **before** writing
  `fixture/KoineNeedleNoIndex.txt`. This preparation is specific to a disposable
  VM. The report does not treat that flag as proof that filename search is absent.
- Ensure `/` reports indexing enabled and run `mdimport` on the ordinary fixture
  root for the initial two-file Spotlight positive control.

Run `task fixture:search-evidence-vm VM=koine-k19 OUTPUT=.build/k19-run` with a
new output directory. The [collector](../../scripts/vm-probe-search.py) resets
Koine TCC before every case, checks the matching completion and responsible
identity, denies observed dialogs and later disables indexing on `/` in this
clone. It reuses the established detached-exec/atomic-marker transport. Exit 0
means collection and its controls finished, not that every mechanism was
prompt-free. Stop the clone when finished: `testanyware vm stop koine-k19`.
