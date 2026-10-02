# launch-and-open-k6 — brief

## Goal

A client can:

- launch or activate a named application;
- open a URL in the default browser;
- open a file or folder with its default application or a named one;
- reveal a path in Finder.

This first working increment is the pathfinder for adding provider work under
`provider-architecture`'s settled layout. It has the least native risk, so it
flushes out build, approval, conformance and acceptance plumbing early.

The layout now names `workspace`. Its launch/open/reveal fields require
`workspace:control` AND `desktop:control`, since activation is an allowed
effect. This increment implements the additive framework feature
`additional-capabilities-v1` alongside its first real operation, following
`docs/specs/machine.md#additional-capability-requirements`. It also starts the
concrete operation rows in `docs/specs/workflow-providers.md`.

Consume `first-party-provider-selection-k50` and its settled review chain before
packaging workspace, including integration `first-party-provider-selection-k52`.
`docs/specs/machine.md#first-party-provider-selection` and
`docs/adr/first-party-provider-selection.md` own
the sealed catalogue, approval/version precedence, pre-load selection, candidate
diagnostics and no late retry. Implement its complete selection-acceptance table
through the assigned three seams, using a fresh native host process/marker log
per scenario and purpose-built sealed test hosts for catalogue defects. Include
visible tie fallback, per-candidate staging/quarantine isolation (including legacy
staging), new-update `first-party-selection-v1` refusal on old hosts with renamed
principals, missing-bundle diagnostics during successful replacement, and mixed
releases with disjoint native module/class names. Platform outcomes predicted by
the review remain bounded native/VM evidence here. Replacements retain shipped composition
positions. Own the missing-capability-owner cascade and exact-candidate conformance
profiles, including old-host and extension-host core + desktop, selected updates
and explicit absent/rejected sets. Catalogue baselines must match packaged desktop
and workspace; reserve the four later identities without enabling them early.
Additional-capability denial reports the deterministic first unmet member and
complete set. Baseline desktop operations and error diagnostics remain unchanged;
management candidate metadata is additive. Independent old/new binaries exercise
the feature and refusal paths. Antony approved the catalogue's stable release
signing-identifier check in k52, with distinct fixture identifiers admitted only
by test catalogues; no entitlement or certificate-class change is authorized.

## Done when

- The named launchers for Dia, ChatGPT, Claude, Zed, Visual Studio Code, Jump
  Desktop, Kimi, iTerm, Mail, Notes, Obsidian and Zotero launch or activate from
  a standalone client, whether or not the application was running. An
  application that is not installed is reported as an absent dependency, never
  as success or a stale target.
- Web search's Koine part opens the resulting search URL in the default
  browser. Query entry, Google suggestions and the typed-query fallback are
  recorded as client responsibilities, and no Google proxy lives in Koine.
- Client settings: the configuration directory opens in Zed. Reload and
  relaunch are recorded as client-owned.
- Every operation carries the authority `provider-architecture` allocated.
  Denied and revoked grants are refused through the public operations. The
  operation-to-capability trace gains these rows.
- The three seams accept it:
  - Public GraphQL: the introspected schema and a client driven only by the
    documented contract.
  - Native binary interface: the native loader path, including a new bundled
    provider with its in-app approval, schema design file and conformance if
    the architecture calls for one.
  - Isolated TestAnyware macOS VMs: signed Koine against the real applications
    installed in the VM.
- `Taskfile.yml` gains the reusable build and VM verification tasks this
  increment needs.

## Decomposition

1. `design` — the operations, their inputs and results, and the not-installed
   and no-handler cases.
2. `planning` — cut implementation leaves from the settled design.

`launch-and-open-k29` cut the working increments below. Each leaves Koine
working and verifies its behavior through the three seams. A `review-planning`
step reads the cut before any of it runs, and `launch-and-open-k82` integrates
it.

3. `protected-path-metadata`: the bounded prompt question, answered ahead of
   every path consumer: launch's installation selection, path opening, reveal
   and `app-and-file-search`. It is evidence rather than a working increment,
   so it runs first.
4. `launch-path`: one real launch end to end. It carries the framework minor,
   selection, packaging, conformance, the contract-only client and VM acceptance.
   This is the charter's first implementation slice.
5. `selection-acceptance`: Machine's whole selection matrix, proven while the
   loader is fresh and before later runs rest on it.
6. `application-launchers`: all twelve launchers on a reusable prepared VM,
   which also supplies Dia and Zed to later increments.
7. `web-urls`: URL opening for web search.
8. `document-paths`: documents, directories and the Zed settings directory.
9. `reveal-path`: Finder reveal. It lands the last root, so conformance then
   requires the complete design SDL.
10. `application-installations`: multiple-copy acceptance for launch and
    named-application opening.
11. `workspace-disclosure`: grant-view disclosure before workspace ships.

Spec acceptance rows, by owner. An operation's leaves own its parts of the
cross-cutting rows.

| Spec row | Owners |
| --- | --- |
| Twelve launchers | `launch-path` (one app), `application-launchers` |
| Multiple copies and installation | `workspace-launch` (L/G/N), `application-installations` |
| Browser URL | `web-urls` |
| Documents/directories/settings | `document-paths` |
| Finder reveal | `reveal-path` |
| Input boundary | each operation's leaves |
| Receipt/failure boundary | `workspace-launch`, `launch-vm`; each operation for its receipt |
| Bounded acknowledgment | `workspace-launch`, `launch-vm`, `launchers-vm` (Gatekeeper); each operation's L |
| Authority/revocation and disclosure | each operation's leaves; `workspace-disclosure` |
| Consent and prompts | `launch-vm`, `launcher-apps`, `launchers-vm`, `protected-path-metadata`; each V leaf |
| Packaging/selection | `launch-path`, `selection-acceptance` |

Only the certificate-dependent alternate-team cases may remain pending when this
node closes. They stay live in the late root leaf `alternate-team-signing`.

Conformance grew by root, and the last root has landed: the workspace profile now expects the
complete design SDL, verbatim (`reveal-path-k77`). A missing coordinate always fails; nothing is
silently omitted.

## Notes

The launchers' secondary actions belong to `app-and-file-search`: reveal, copy
path and copy bundle identifier. That increment reuses these operations.
Installing the twelve applications in a VM is preparation that later increments
repeat. If it proves costly, a reusable preparation task in the Taskfile earns
its place here.

## Design handoff

`protected-path-metadata-k73` records its bounded answer in
`docs/verification/protected-path-metadata.md`. The tested first-use metadata and
registered-application route is prompt-free on Desktop, Documents and Downloads;
document file-URL default-handler lookup prompts, including a usable handler
returned after denial. Constrained/unconstrained launch presence, named-app
opening and reveal can use the measured metadata route. Protected default
opening stays live in `document-paths`, pending a human consent/semantics decision;
search must not use that lookup as a readiness read. No consent is added.
Removable/network-volume observations are unavailable, not passing acceptance.

`launch-and-open-k18` delivers `docs/specs/workspace-launch-and-open.md`, the
workspace SDL/client examples in `docs/design/`, and two views in the existing
architecture viewer. The shared workflow trace now names the four mutation
coordinates. Review the design before `launch-and-open-k29` cuts implementation.
The whole Machine selection-acceptance table remains assigned to this increment;
the new spec's acceptance rows supplement it rather than narrowing it.

Launch/open uses bundle identity with an optional registered installation path;
result fields need both control grants and neither read. The receipt contains
only optional process identity under the documented observation rule; installed
paths, bundle identifiers and handler metadata remain workspace read data.
It can feed a separate desktop read. No strong native
window/file identity, rendering completion or rollback follows from the receipt.
The source/SDK support is design evidence; actual launch, Finder acknowledgment,
protected-path prompting, payload classification and kernel-identity observation
are bounded native/VM acceptance questions. New consent or signing posture still
returns to Antony before implementation relies on it.

`launch-and-open-k54` integrates the review. Unconstrained launch/named-app open
allows running-copy reuse; a selected installation disables substitution.
Registration alone does not establish bundle presence; compare constrained
copies by file identity. A present registered copy in Trash remains eligible;
bundle-less programs have no named-selector route. Acknowledgment is distinct
from observed activation. Check cold and warm launch while another app is
frontmost and Koine inactive; a control-only activation failure remains pending,
even when a separately authorized desktop read/focus can recover.

Native acknowledgment waits end after three seconds or earlier cancellation,
without awaiting late callbacks or replaying. The core's request deadline can
still win first. Prepare apps' first-run/Gatekeeper approval for the working
launcher cases, record per-app latency, and test an outstanding Gatekeeper
dialog/late callback separately. Private-adapter provider-local tests exercise
workspace's own error/receipt mapping; composition fakes only cover core/client
handling, and neither replaces the N/V matrix. Error-free result branches are
exclusive; publication errors may suppress an acknowledged action's branch.

Path opening uses the spec's narrow metadata refusal set and ordinary document
handlers, including source files in their default editor. Handler execution and
location-document redirects are disclosed reach, not prevented effects; native
Finder aliases are refused for opening but can be revealed. This increment
owns workspace disclosure in create/approve and existing-grant views and field
descriptions before workspace ships. Schedule the protected-path metadata probe
before launch's installation selection, path-opening implementation or search
consumes that contract.

Expected packaged workspace release/schema is `1.0.0`/`1.0.0`, release signing
identifier `dev.antony.Koine.provider.workspace`. Existing desktop is
`1.0.0`/`1.0.0`, `dev.antony.Koine.provider.desktop`; catalogue values must be
checked against actual signed packaged outputs. Local inspection of the installed
baseline's signature confirmed that desktop identifier (Team ID TA43A4RUP3).
Workspace does not exist as a built artifact yet; its value is a publication
decision, not a measured signature. Test catalogues alone admit fixture identities.

Keep the first implementation slice a real launch path with both framework
authority and selection support, packaging, exact-candidate conformance and
public/native/VM acceptance. The first slice can use one required real app;
later working increments cover all apps and the full assigned selection matrix
before workspace ships. Do not replace pending acceptance by a mock-only or
reduced profile. `task design:workspace-check` validates only design SDL/examples;
`task conformance` must still be extended and run against the actual served schema.

`web-urls-k70` found, and later increments should expect, that Dia's first run is an
account gate: a page opened in it is never shown, so Dia can be observed at delivery only
(acknowledgment, activation, kernel identity) until an account is provided. That case is
`dia-url-page-load-k88` in `account-acceptance`. `Fixtures/UrlBrowser` (a test browser that records
the exact strings it is handed) and `scripts/vm-url-witness-server.mjs` (a guest page server that
reports a browser's own `location.href`, fragment included) are reusable for any increment that
needs to see what an application was handed. The image cannot show a universal-link divergence
(no installed application has a resolvable associated domain, and Safari forwards Apple links to
Maps itself), so a row that wants one inspects the call path instead.

`document-paths-k74` accepted `workspaceOpenPath` at V (`docs/verification/open-path-vm.md`) and
left one case pending, as the protected-path answer required: default opening of a document in
Desktop, Documents or Downloads, which needs Antony's consent decision. It is
`protected-default-open-k89`, a root `design` leaf ahead of `baseline-acceptance`, so that this
node closes without it. Later increments should expect what the image's handlers are: `.py`, `.json`
and `.md` open in Zed, `.swift` in Visual Studio Code, `.js` in Safari, `.sh` in iTerm, `.command` in
Terminal, so a case wanting "a different application from the named one" must choose its type with
that in mind (the run reads and checks them). `scripts/vm-open-path-fixtures.sh` (disposable
documents, links, scripts, Finder aliases and a mode-000 directory, idempotent under the agent's
double-run) is reusable, and the handler's own window, read from the window server with a unique
fixture name and a before-request check, is the witness of what an application was handed;
`reveal-path` needs the Finder equivalent. A V recipe of about forty cases takes about three
hours, because the guest agent costs seconds per command: run it detached
(`python3 subprocess.Popen(..., start_new_session=True)`), since a harness background task is killed
at two hours.

`reveal-path-k77` serves `workspaceRevealPath` (evidence in `docs/verification/reveal-path-vm.md`)
and found one thing only Antony can settle, so it is a root leaf and not prose, as
`protected-default-open-k89` is: revealing a third-party application bundle made macOS post
"Koine was prevented from modifying apps on your Mac". It sits ahead of `baseline-acceptance` as
`reveal-app-bundle-notice-k90`. The reveal itself worked and no consent was requested.

`application-installations-k78` accepted the multiple-copies row at L, G, N and V
(`docs/verification/application-installations-vm.md`). Later increments should expect: Launch
Services drops a registration the instant its bundle is deleted and deregisters a registered copy
within about 50 ms of its move into the Trash, so neither a listed-but-missing copy nor a registered
Trash copy can be put in front of a request on macOS 26.5; it also registers a bundle it finds under
the home folder on its own, so a case about an unregistered copy must unregister it and read the
answer in the same guest process right before the request. `scripts/vm-installation-fixtures.sh`
(one identifier installed at two or more registered locations, plus links, Unicode spellings, an
unregistered, a deleted, an Info.plist-less and an unreadable copy and a bundle with no identifier)
and `scripts/vm-registration-lookup.swift` (what `NSWorkspace` itself answers) are reusable, as is
`scripts/vm-installation-request.py`, which does one request and all its observation in one guest
process: the guest agent costs seconds per exec and reports a false timeout for a quarter of them, so
a case made of many execs takes minutes. `app-and-file-search` acting on a chosen installation uses
the constrained form this increment accepted, and `urlsForApplications` omits a copy that
`urlForApplication` returns (the Trash), so never rely on the list alone.
