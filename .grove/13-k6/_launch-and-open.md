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
step reads the cut before any of it runs.

3. `launch-path`: one real launch end to end. It carries the framework minor,
   selection, packaging, conformance, the contract-only client and VM acceptance.
   This is the charter's first slice.
4. `selection-acceptance`: Machine's whole selection matrix, proven while the
   loader is fresh and before later runs rest on it.
5. `application-launchers`: all twelve launchers on a reusable prepared VM,
   which also supplies Dia and Zed to later increments.
6. `web-urls`: URL opening for web search.
7. `protected-path-metadata`: the bounded prompt question, answered ahead of
   every path consumer, including `app-and-file-search`.
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

Conformance grows by root. Until the last root lands, the workspace profile
expects the design SDL restricted to the implemented roots and the types they
reach, verbatim. A missing coordinate always fails; nothing is silently omitted.

## Notes

The launchers' secondary actions belong to `app-and-file-search`: reveal, copy
path and copy bundle identifier. That increment reuses these operations.
Installing the twelve applications in a VM is preparation that later increments
repeat. If it proves costly, a reusable preparation task in the Taskfile earns
its place here.

## Design handoff

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
before path-opening implementation or search consumes that contract.

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
