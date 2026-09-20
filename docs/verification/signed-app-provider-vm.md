# Signed application and native providers: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, limited to
what a signed, hardened process changes for `native-providers-k18`. Loader,
trust and compatibility behaviour is proven at the native binary seam
(`NativeProviderTests`, [binary-compatibility.md](binary-compatibility.md)) in
unsigned test hosts, where library validation is not in force. Here the host is
the Developer ID signed `Koine.app` under the hardened runtime with empty
entitlements, so the kernel's library validation stands between `dlopen` and
every plugin image. This run shows that an approved same-team provider loads
there, and that Koine's own refusals still come first for the others.

## Procedure

```sh
task app                      # build and sign .build/app/Koine.app on the host
task app:vm-verify-providers  # fixture:variants, then scripts/vm-verify-providers.sh
```

Requirements, the clean clone, the transcript (`.build/vm-verify/providers-<timestamp>.log`),
`KOINE_VM_KEEP=1` and the TestAnyware workarounds are those of
[resident-app-vm.md](resident-app-vm.md); both scripts share
`scripts/vm-verify-lib.sh`. Nothing runs the application on the host.

The fixture bundles are test material from `task fixture:variants`, built
outside the package against the *debug* staged framework, while the application
embeds the *release* framework: host and plugin are independently built here
too. The script installs each as a user would: the bundle and
`fixture.approval.json` placed in
`~/Library/Application Support/Koine/Providers`, with Koine not running. Each
case replaces the root's content, and Koine is quit (⌘Q) and reopened between
cases, since providers load at startup.

| Step | How | Expectation checked |
|---|---|---|
| Bundle | `codesign -d --entitlements`, `codesign --verify --strict` and `-dvv` on the framework, in the VM; `otool -L` of the fixture on the host | recorded: entitlements, the framework's place and signature, `Contents/PlugIns` empty, what the fixture links, that it bundles no framework |
| Approved, same team | plain fixture + approval for `TA43A4RUP3`; grant created in the UI with `koine:manage` and `fixture:read`, credential by Copy and `pbpaste` | `koineManagement.providers` reports `fixture` `ACTIVE`; `{ fixtureInfo { greeting } }` is served; `lsof` shows the plugin image mapped, and exactly one `KoineProviderAPI` image, the application's own |
| Ad-hoc signed | `adhoc-signed` variant under the same approval record | `REJECTED` with a diagnostic; no `fixture*` field on the introspected `Query`; the management query still lists the grant; no `libFixtureProvider` image mapped |
| Unavailable minor | `unavailable-minor` variant (same-team, approved, `minimumMinor` 99) | `INCOMPATIBLE` with a diagnostic; the same three absences |

The one grant, created in the first case, serves all three: grants persist
across Koine restarts, and it stays `ACTIVE` while no provider offers its
`fixture:read`.

## What this does and does not show

- **Library validation is not what refuses the ad-hoc bundle.** Koine's approval
  check refuses it before `dlopen`, as the spec requires, so the kernel is never
  asked. That the image is absent from `lsof` shows no code of it loaded; what
  the kernel would do with a foreign-team image is not exercised, by design, and
  belongs to the later increment that adds the library-validation entitlement.
- **The host's framework image, by `lsof`.** The hardened process cannot be
  inspected with `vmmap` (no `get-task-allow`); `lsof` lists its mapped files.
  One `KoineProviderAPI` path, inside `Koine.app/Contents/Frameworks`, together
  with a fixture that links `@rpath/KoineProviderAPI.framework/…`, has no
  run path but `/usr/lib/swift` and bundles no framework, is the evidence that the plugin
  bound to the host's image through the application's run path.
- **The plugin loads from Koine's staged copy**
  (`…/Koine/ProviderStaging/Fixture-<content digest>/`), not from the root the
  user writes to.
- **The fixture is signed without the hardened-runtime flag** and with no secure
  timestamp (`seal.sh`). Library validation compares Team IDs and does not ask
  for either.
- **Gatekeeper and quarantine** are as in [resident-app-vm.md](resident-app-vm.md):
  off in the golden, not set by the upload. Nothing was disabled to get here.

## Left for `release-acceptance-handoff-k11`

- ~~The same cases against a **notarized** build on a Gatekeeper-enabled image,
  with the provider bundle arriving **quarantined**: whether a quarantined,
  un-notarized same-team plugin still passes `dlopen` is not shown here.~~
  **Answered** in [notarized-release-vm.md](notarized-release-vm.md): it does
  **not**. macOS refuses the image with "library load disallowed by system
  policy", downstream of Koine's approval record and team comparison, and the
  refusal blocks Koine's startup until its dialog is dismissed. Clearing the
  attribute on the installed copy does not help, because Koine reuses its
  content-addressed staged copy, which keeps it. `provider-quarantine-rule-k47`
  carries the rule into README and the spec.
- ~~The bundled desktop provider loading from `Contents/PlugIns` (the
  in-application root is empty until `desktop-path-k9`); this run exercises only
  the per-user root.~~ **Shown** in
  [notarized-release-vm.md](notarized-release-vm.md): `desktop` is `ACTIVE` on a
  quarantined notarized bundle, staged and loaded like any other provider, its
  image mapped from a `Desktop-<digest>` staging copy.
- The supported OS and CPU matrix: this is one OS build on arm64.

## Tooling note

The first complete attempt failed in its last case with six consecutive
`Process timed out after 30s` answers from `file exec` for one client call,
after both earlier cases had passed; `curl -m 5` cannot itself take 30 s, and
the next run, unchanged, passed with no retry exhausted. It is the intermittent
TestAnyware fault already recorded, not Koine.

## Evidence

Run of 2026-09-19 against the bundle built from `4d7b9a7` plus this procedure
(which adds only accessibility identifiers to the capability toggles), signed
`Developer ID Application: Antony Blakey (TA43A4RUP3)`, un-notarized. VM: clone
of `testanyware-golden-macos-tahoe`, macOS 26.5 (25F71), arm64, Gatekeeper
assessments disabled. Result: **passed**, every expectation above.

```
== The signed bundle: entitlements, and the framework inside it
Entitlements: <?xml version="1.0" encoding="UTF-8"?>…<plist version="1.0"><dict></dict></plist>
/Applications/Koine.app/Contents/Frameworks
/Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework
/Applications/Koine.app/Contents/PlugIns
/Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework: valid on disk
/Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework: satisfies its Designated Requirement
Identifier=dev.antony.Koine.ProviderAPI
CodeDirectory v=20500 size=456 flags=0x10000(runtime) hashes=7+3 location=embedded
Authority=Developer ID Application: Antony Blakey (TA43A4RUP3)
TeamIdentifier=TA43A4RUP3
	@rpath/libFixtureProvider.dylib (compatibility version 0.0.0, current version 0.0.0)
	@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI (compatibility version 1.0.0, current version 1.0.0)
	… system libraries only
bundled frameworks: 0

== An approved same-team fixture in the per-user root
Identifier=dev.antony.Koine.provider.fixture
Authority=Developer ID Application: Antony Blakey (TA43A4RUP3)
TeamIdentifier=TA43A4RUP3
{"data":{"koine":{"contractVersion":"koine-desktop\/1","ownGrant":{"clientLabel":"vm-provider-script","capabilities":["fixture:read","koine:manage"],"state":"ACTIVE"}}}}
HTTP 200
{"data":{"koineManagement":{"providers":[{"provider":"fixture","version":"1.0.0","state":"ACTIVE","diagnostic":null}],"grants":[{"clientLabel":"vm-provider-script","state":"ACTIVE"}]}}}
HTTP 200
{"data":{"fixtureInfo":{"greeting":"hello from the fixture provider"}}}
HTTP 200
Koine … txt REG … /Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework/Versions/A/KoineProviderAPI
Koine … txt REG … /Users/admin/Library/Application Support/Koine/ProviderStaging/Fixture-42193c79…/libFixtureProvider.dylib

== An ad-hoc signed fixture instead, under the same approval record
Identifier=dev.antony.Koine.provider.fixture
Signature=adhoc
TeamIdentifier=not set
{"data":{"koineManagement":{"providers":[{"provider":"fixture","version":"1.0.0","state":"REJECTED","diagnostic":"The bundle is refused: it is ad-hoc signed, not by the approved identity, Team ID TA43A4RUP3."}],"grants":[{"clientLabel":"vm-provider-script","state":"ACTIVE"}]}}}
HTTP 200
{"data":{"__schema":{"queryType":{"fields":[{"name":"koine"},{"name":"koineManagement"}]}}}}
HTTP 200
{"errors":[{"message":"Cannot query field \"fixtureInfo\" on type \"Query\".",…}]}
HTTP 400
Koine … txt REG … /Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework/Versions/A/KoineProviderAPI

== An approved same-team fixture whose manifest demands framework minor 99
TeamIdentifier=TA43A4RUP3
{"data":{"koineManagement":{"providers":[{"provider":"fixture","version":"1.0.0","state":"INCOMPATIBLE","diagnostic":"The provider requires provider framework 1.99 or later; this Koine supplies 1.0."}],"grants":[{"clientLabel":"vm-provider-script","state":"ACTIVE"}]}}}
HTTP 200
{"data":{"__schema":{"queryType":{"fields":[{"name":"koine"},{"name":"koineManagement"}]}}}}
HTTP 200
Koine … txt REG … /Applications/Koine.app/Contents/Frameworks/KoineProviderAPI.framework/Versions/A/KoineProviderAPI
```

No behaviour of the signed build differed from the spec in this run.
