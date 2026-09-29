# Quarantined per-user providers, judged before `dlopen`: VM verification

The "Isolated TestAnyware macOS VMs" seam of `docs/specs/machine.md`, for
quarantined per-user providers. Koine does not leave that judgment to `dlopen`:
[notarized-release-vm.md](notarized-release-vm.md) shows that a quarantined,
un-notarized provider that passes every Koine check is refused by macOS at
`dlopen`, behind a modal “libFixtureProvider.dylib” Not Opened dialog that holds
the service from listening, with no `endpoint.json`, until someone clicks Done.
The loader asks Gatekeeper before `dlopen` instead (spec, "Loading and trust").
This run is the inverse of that observation, on the same route, and adds the
case the check must not get wrong: a quarantined provider that **is** notarized.

## Procedure

```sh
task app && task app:notarize   # the bundle carrying the check, notarized and stapled
task app:vm-verify-notarized    # fixture:variants, fixture:notarized, then scripts/vm-verify-notarized.sh
```

`task fixture:notarized` (`Fixtures/FixtureProvider/notarize.sh`) makes the
notarized provider: the plain fixture re-signed with a secure timestamp and the
hardened runtime, submitted and **Accepted**. It is **not** stapled, because a
provider bundle cannot be: a stapled ticket lives only in
`<bundle>/Contents/CodeResources`, a provider bundle is shallow, and
`stapler staple` fails with error 73. So a Mac meeting it must look its ticket up
online.

One Gatekeeper-enforcing clone ("App Store & Known Developers"), the notarized,
quarantined `Koine.app`, and in the per-user root the fixture with Koine's
approval record, quarantined as a download arrives. In order:

1. First launch. The per-user fixture is quarantined and un-notarized.
2. Clear the attribute from the installed bundle only, relaunch.
3. Run the command the diagnostic gives, verbatim, relaunch.
4. Replace the bundle with the notarized copy, quarantine it, relaunch.

Recorded run: `.build/vm-verify/notarized-20260921T175128.log`, kept as
[provider-quarantine-precheck/run.log](provider-quarantine-precheck/run.log).
Before and after it, `shasum -a 256` of the five scripts it runs, the bundle's
executable and both fixture roots' dylibs and approval records were identical.
The notarized bundle is submission 51b99a60-9266-409c-bfb3-c41bfb05f65d. The
notarized fixture is submission 96ef5189-8421-4c37-a653-5344a6cd34f8, CDHash
`048e32b13cd5ad4f8baac0bb4c1498c157cd4292`.

## What this shows

- **Refused before `dlopen`, and the service starts.** `await_service` saw no
  refusal dialog and no held startup; `endpoint.json` was written; the fixture is
  `REJECTED` with
  "libFixtureProvider.dylib is quarantined and Gatekeeper refuses it
  (Unnotarized Developer ID). macOS would refuse to load it. Its author can
  notarize it; or clear the attribute with `xattr -dr com.apple.quarantine
  '…/Providers/Fixture.koineprovider'` and, with Koine stopped, delete its staged
  copy with `chmod -R u+w '…/Fixture-534841e5…' && rm -rf '…/Fixture-534841e5…'`",
  its image is not mapped, and the bundled desktop provider is `ACTIVE`, mapped
  from its `Desktop-` staging copy. The screen at that point:
  [no-dialog-un-notarized.png](provider-quarantine-precheck/no-dialog-un-notarized.png).
- **No system dialog, read by the instrument that captures one.** Every
  window's static text is searched for the dialog's wording ("Not Opened", "could
  not verify") — the same accessibility read that captured the dialog whole in
  notarized-release-vm.md's run. It matches on the wording rather than the
  library's name because Koine's own window shows the diagnostic, which names
  the library: a run of this procedure that matched the name found it there and
  reported a refusal macOS never raised, while its own startup-held witness read
  "no". That was the script (`scripts/vm-verify-gatekeeper-lib.sh`), not Koine.
- **Clearing the installed copy alone does not help, and the refusal is
  Koine's.** With the attribute removed from the installed bundle, the relaunch
  reuses the content-named staged copy, which keeps it, and the provider is
  again `REJECTED` with the same diagnostic — no dialog.
- **The diagnostic's own command works.** The script takes it out of the
  diagnostic verbatim and runs it in the guest. The staging directory is under
  "Application Support", so it works only because the loader quotes the paths;
  no `Fixture-` staging copy was left, and on relaunch the fixture is `ACTIVE`,
  serves `fixtureInfo { greeting }`, and is mapped from a fresh `Fixture-` copy.
- **A quarantined, notarized provider is not refused.** Before Koine started,
  `codesign -v -R=notarized` on it was **not satisfied** on this clone, which had
  never seen it. That is the offline ticket-store lookup the loader
  deliberately does not use. Koine loaded it: `ACTIVE`, no dialog, serving the
  greeting, mapped from `Fixture-61e44e3f…`, whose dylib still carries the
  quarantine value the run wrote, so Gatekeeper's check was asked of a
  quarantined image. `spctl` on that image: `accepted`, `source=Notarized
  Developer ID`. Afterwards `-R=notarized` was **satisfied**: the ticket was now
  cached by an online lookup — Koine's check or the script's own `spctl` just
  before, which this run does not tell apart. Either way, nothing had cached it
  when Koine judged the provider, and Koine accepted it.

## What this does not show

- **A Mac that cannot reach Apple.** Offline, a notarized but unstapleable
  provider is not expected to be accepted by Gatekeeper on first contact, and the
  check would then refuse it; what the platform would have done at `dlopen` in that case was not
  observed either.
- **The 30-second bound.** No run made `spctl` slow; the timeout's refusal is
  read from the code, not seen.
- **A provider signed by another team.** Only Koine-signed providers load
  (README), so the check judges only same-team images.
- **Quarantine on a private dependency.** Every image in the bundle's closure is
  judged, but the fixture used here has none.
