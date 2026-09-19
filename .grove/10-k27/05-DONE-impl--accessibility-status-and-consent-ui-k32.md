# accessibility-status-and-consent-ui-k32

## Goal

Koine owns its OS permission visibly: its own window explains and requests
Accessibility consent and shows provider and service status, and
`koineManagement.osPermissions` reports the same facts over GraphQL.

## Context

- Spec: the OS-permission paragraphs of "Application composition and
  availability"; "Management authority and surface"; `KoineOSPermission` in
  `docs/design/desktop-schema.graphql`.
- The management window as a thin client of the management operations through
  `KoineManagementClient` (`resident-management-k12`), and
  `koineManagement.providers` (`native-providers-k18`).
- `docs/verification/resident-app-vm.md` for the TestAnyware UI-driving
  workarounds.

## Done when

- `koineManagement.osPermissions` is served under `koine:manage` and reports
  `accessibility`, owner Koine, and whether it is granted now, read on each
  request. `KoineCore` stays free of macOS: the host supplies the permission
  source. Reading it never prompts.
- The management window shows Accessibility status with guidance naming Koine
  as the application that needs consent, and a control that makes the OS
  consent request from Koine's own process and leads to the System Settings
  pane. Only this UI action requests consent. The status follows a change made
  in System Settings without restarting Koine, or the window says a restart is
  needed if the platform requires one.
- The window shows each provider's state and diagnostic from
  `koineManagement.providers`, and service status: that the endpoint is
  serving, and where.
- The window takes its facts from the management operations, so the GraphQL
  seam carries the behaviour tests and the VM seam proves the real workflow.
- VM verification against the signed build: with consent absent the window
  shows guidance and `osPermissions` reports `granted: false`; the consent
  request attributes the prompt and the System Settings entry to Koine; after
  consent the window and `osPermissions` agree and a desktop read succeeds;
  after consent is removed both follow. A grant without `koine:manage` cannot
  read `osPermissions`.
- The verification task is in `Taskfile.yml` and the README; the evidence is
  under `docs/verification/`.

## Notes

Attribution of the prompt to the signed, packaged application is the claim the
spec says must be checked in real VMs before it is treated as shipped
behaviour; this leaf is where it is checked for the development-signed build,
and `release-acceptance-handoff-k11` repeats it on the release build.

The install-and-approve UI for third-party providers is not part of this leaf;
it stays on the root brief's horizon.

## Decisions (running log)

- The host supplies `OSPermissionSource`, a `@Sendable () -> [OSPermissionStatus]`
  of plain strings, through `KoineServer.init(osPermissions:)` to `CoreFields`;
  it is called inside the `Query.koineManagement` resolver, so it is read per
  request and never for a caller the capability check refused. A host that
  supplies none serves an empty list.
- `owner` is `koine`, the value the spec gives `extensions.permissionOwner`, so
  a client matches the two without a case rule.
- The window reads `ManagementClient.status()`: one operation for the contract
  version, instance, providers and OS permissions. The port is the one fact it
  takes from the host, because the schema has no field for it and the design SDL
  is not this leaf's to extend.
- Two controls, not one: the consent request (`AXIsProcessTrustedWithOptions`
  with the prompt option, whose dialog offers System Settings itself) and a
  plain "Open Accessibility Settings…", so that opening the pane never covers
  the dialog and the user still has a route when macOS does not show it again.
- Nothing announces a consent change, so the status section re-reads every two
  seconds while the view's task lives.
- The prompt option key is written as its literal value: the imported constant
  is a global `var` that Swift 6 refuses from isolated code. Its value was
  printed from the SDK before it was relied on.
