# Workspace control disclosure: VM verification

The "Isolated TestAnyware macOS VMs" seam of
[`docs/specs/workspace-launch-and-open.md`](../specs/workspace-launch-and-open.md#acceptance)
for the disclosure half of its *Authority/revocation and disclosure* row. The
workspace spec requires, before workspace ships, that every place a person grants
or reviews workspace control tells them its reach:

- any registered installed application can be launched, not only configured
  shortcuts;
- a default or named document handler can execute scripts or follow location
  documents to other schemes and targets, and Koine's path checks are not a
  content sandbox;
- both `workspace:control` and `desktop:control` are needed to launch, open or
  reveal.

It runs on the Developer ID signed `Koine.app`, with no application mocks. The
text is the core's ([`CapabilityDisclosures`](../../Sources/KoineCore/CapabilityDisclosures.swift)),
served as `koineManagement.capabilityDisclosures`
([machine.md](../specs/machine.md#capability-disclosures)); the window and a
`koine:manage` client therefore read the same words, and this run proves it by
comparing what the window shows with what a guest management client is served.
The field's behavior at the public GraphQL seam is
`GrantManagementTests.aManagerReadsTheWorkspaceControlDisclosure` and
`disclosuresNeedManageAndNothingElseDoes`, and the window's read is
`ManagementClientTests.disclosuresAreTheServedOnesKeyedByCapability`. The
served GraphQL field descriptions of workspace are the design file's, which
`SchemaConformanceTests` and `task conformance` hold (see
[schema-conformance-vm.md](schema-conformance-vm.md)); the design file's
`workspaceLaunchApplication` and `workspaceOpenPath` descriptions state the first
two points and every workspace mutation states the third.

## Procedure

```sh
task app                         # build and sign .build/app/Koine.app
task app:vm-verify-disclosure    # scripts/vm-verify-disclosure.sh
```

The guest clients are `scripts/vm-verify-enrollment-client.py`'s, which make their
own secrets into `0600` files and print neither. The settings window opens at
480x680 around scrolling content, so each element is scrolled on screen and
accepted only when its frame lies wholly inside the window's: the accessibility
tree reports elements that are scrolled out of view as well.

| Case | How | Expectation checked |
|---|---|---|
| Served words | a guest manager (enrolled and approved in the window) reads `capabilityDisclosures` | exactly one entry, `workspace:control`, stating "any application registered on this Mac", "run a script or follow a location document" and `desktop:control` |
| **Create-grant view** | the capability list scrolled on screen | the disclosure sits beside `workspace:control`, equals the served text, and `koine:manage`, `desktop:read`, `desktop:control` and `workspace:read` carry none |
| New grant | the label typed, `workspace:control` and `desktop:control` ticked, Create Grant | the manager reads the grant `ACTIVE` with exactly those two capabilities |
| **Request view** | a guest client enrolls for `workspace:control`, `desktop:control` and `desktop:read`; the row is shown | the disclosure is beside `workspace:control` and equals the served text; `desktop:control` and `desktop:read` carry none; a request for `koine:manage` alone carries none |
| **Existing-grant list** | the request approved with all three ticked | the new grant's row and the approved grant's row both show the served text; the manager's row and a `desktop:control` entry show none |
| Restart | Koine quit and started again | the manager's grant list is byte-identical before and after (nothing revoked or reauthorized), and both rows still disclose |
| Revoked grant | Revoke on the new grant, confirmed | its row discloses nothing; the other grant's still does |

[create-offered.png](workspace-disclosure/create-offered.png),
[request-pending.png](workspace-disclosure/request-pending.png),
[grant-list.png](workspace-disclosure/grant-list.png) and
[after-restart.png](workspace-disclosure/after-restart.png) are the window as the
run saw it.

## Recorded run

`PASSED` on a clean macOS Tahoe clone, the signed Developer ID build
(`TeamIdentifier=TA43A4RUP3`, hardened runtime, not notarized), installed by `ditto` with no
quarantine attribute, so Gatekeeper's first-launch check is not exercised here.
The three surfaces each showed the same 590-character paragraph:

> Launches or reactivates any application registered on this Mac, not only
> configured shortcuts, and opens documents, folders and web addresses in their
> default application or a named one. Koine accepts no program, arguments,
> environment or shell command, but that is not a sandbox: the application that
> receives a document decides what happens, so a handler can run a script or follow
> a location document to another address or file. Launching, opening and revealing
> also need desktop:control, because activation is an allowed effect; neither
> capability works without the other.

The comparison instrument was seen to fail before it was trusted: an earlier run
stopped at "the request view is not the text koine:manage clients are served",
because the script had read the element's identifier instead of its text; the
passing run is after that fix to the script (and one earlier fix to a doubled
client argument), with no change to Koine in between.

`task conformance` then passed for all three profiles with the new management
field: the two extension-host profiles and the workspace profile of the signed
bundle serve the design files that carry `capabilityDisclosures`, and the old-host
profile, which a released host serves, is untouched
([schema-conformance-vm.md](schema-conformance-vm.md)). That run also exercised
`create_grant` through the scrolling helpers described next.

The grant form is now longer than the settings window's default size, so the VM scripts'
shared `create_grant` and the two scripts that clicked Create Grant directly
(`vm-verify.sh`, `vm-verify-providers.sh`) scroll each control on screen first
(`reveal_click` in `scripts/vm-verify-lib.sh`). Of the scripts that create a grant
through the window, only this one and `task conformance` were re-run for this
change; the others change only by that helper.

## What this does not claim

- **Desktop control's expanded reach** (windows' geometry, pointer, media) is
  disclosed by `window-layout`; `desktop:control` shows no text here by design.
- **Other providers' capabilities** carry no disclosure channel: the provider
  framework has no place for a description and was not changed. A later provider
  that needs one adds a row to `CapabilityDisclosures`, as `window-layout`,
  `app-input` and `menu-bar` will.
- **Upgrade** is shown by a restart, not by an installed older build: the list is
  rebuilt from the stored grants on every read, and no grant is modified by
  showing it.
- The native window is read as a person would see it; a screen reader's reading
  of the same text is not tested.
