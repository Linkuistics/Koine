# quarantined-provider-precheck-k49

## Goal

A quarantined, un-notarized provider in the per-user root is refused by Koine
**before** `dlopen`, as `REJECTED` with a diagnostic that says what to do, so
macOS never raises its modal "Not Opened" dialog and the service starts and
listens as it does for every other refused provider.

## Context

- Cut by `provider-quarantine-rule-k47`, on the human's decision there (running
  log). That leaf documented the platform rule; this one is the human's chosen
  answer to "should a refused provider be able to stop the service starting":
  no, via a pre-`dlopen` check. The two other answers put to the human and not
  chosen: loading per-user providers off the startup path (reopens the spec's
  "load providers and compose the schema at startup"), and documenting only.
- The failure being removed, from `docs/verification/notarized-release-vm.md`:
  a same-team, approved, un-notarized fixture given `com.apple.quarantine` passes
  every Koine check, then `dlopen` is refused ("library load disallowed by system
  policy") behind a modal dialog, and Koine writes no `endpoint.json` until
  someone clicks **Done**. The bundled desktop provider under a quarantined,
  notarized `Koine.app` loads — the check must leave it alone.
- The shape the human approved: after staging and the existing trust checks, if
  the **staged copy's** library carries `com.apple.quarantine` and does not
  satisfy the code requirement `notarized`, refuse it `REJECTED` with a
  diagnostic naming both ways out — notarize it, or clear the attribute and
  delete its `<Name>-<digest>` staging directory. The staged copy is what is
  checked because it is what is loaded and it inherits the attribute (README,
  "A downloaded provider must be notarized…").
- Where it goes: `Sources/KoineProviderLoader/ProviderTrust.swift` already runs
  `SecStaticCodeCheckValidityWithErrors` against a requirement string before
  `dlopen` (`ProviderLoader.swift`'s `dlopen` call); this is one more static
  validation of the same kind, not a new mechanism.

## Done when

- The loader refuses a quarantined, un-notarized staged provider before
  `dlopen` with that diagnostic, and a unit test in `ProviderLoaderTests` shows
  it, using the fixture's initializer log to prove no code ran — with an
  un-quarantined fixture loading as the control, and the check watched to fail
  (the test red) with the refusal removed.
- A quarantined provider that **is** notarized is not refused by this check.
  This needs a notarized provider; if one cannot be produced (notary credential,
  or a bare provider bundle's ticket being online-only rather than stapled),
  say so and ask the human rather than shipping a check that could refuse good
  bundles unseen.
- A Gatekeeper-enforcing VM run, extending `scripts/vm-verify-gatekeeper-lib.sh`
  / the notarized-release route rather than rebuilding it, shows the quarantined
  fixture `REJECTED` with the new diagnostic, **no** system dialog, and
  `endpoint.json` present — the exact inverse of the observation in
  `notarized-release-vm.md` — with the bundled desktop provider still `ACTIVE`.
- `docs/specs/machine.md` "Loading and trust" and README's paragraph written by
  `provider-quarantine-rule-k47` are revised from "Koine cannot predict it; the
  platform refuses the image" to the new pre-`dlopen` refusal, and the new VM
  evidence document is cited beside `notarized-release-vm.md`. The root brief's
  horizon note about the install UI clearing quarantine still stands.

## Notes

**Verify the requirement keyword against Apple's source, not memory.** That
`notarized` is a code-requirement-language term `SecRequirementCreateWithString`
accepts, and what it evaluates for a bundle whose ticket is not stapled (online
lookup, offline behaviour), was put to the human as unverified. Find Apple's
documentation or the Security framework source first and cite it at the call; if
it does not behave as needed, that is a question for the human, not a quiet
substitute check. Refusing **every** quarantined per-user bundle is not an
acceptable substitute: it would refuse a notarized provider the platform loads.

**Do not strip quarantine, and do not touch `App/Koine.entitlements` or
`seal.sh`'s `--timestamp=none`.** The fixture being un-notarized is the test
material. The loader still never clears the attribute itself.

The host rule binds: anything that launches Koine runs in a TestAnyware VM.

## Decisions (running log)

**`notarized` is verified, and it is an offline check.** Apple's Security
source: the requirement parser accepts the literal `notarized`
(`OSX/libsecurity_codesigning/lib/RequirementParser.cpp`, `LITERAL_notarized`
→ `opNotarized`); the interpreter evaluates it as `isNotarized`
(`reqinterp.cpp`), which is `SecAssessmentTicketLookup(cdhash, …,
kSecAssessmentTicketFlagDefault, …)` (`notarization.cpp`), and
`SecAssessment.h` documents that flag as "default behavior, offline check".
`SecStaticCode::staticValidate` registers a stapled ticket first
(`StaticCode.cpp`), read only from `<bundle>/Contents/CodeResources`
(`notarization.cpp`, `copyStapledTicketInBundle`). The online path,
`kSecCSForceOnlineNotarizationCheck`, is private and checks revocation only.

**A provider bundle cannot be stapled, so `notarized` misjudges a good one.**
Observed on the host, no Koine launched: a copy of the fixture re-signed with a
secure timestamp was notarized (submission f58c9edc-5786-44c2-9d97-482b716bf6ec,
Accepted). `codesign -v -R=notarized` then **failed** on it and its dylib.
`stapler staple` failed (error 73: it looks for `Contents/CodeResources`, which
a shallow bundle has not got), and creating `Contents/` makes the bundle
unrecognisable to codesign. After `spctl --assess --type open --context
context:primary-signature` accepted it (`source=Notarized Developer ID`, an
online lookup), `-R=notarized` **passed** — the ticket is now cached locally.
So the approved shape would refuse a notarized provider on its first start on
any Mac that had not already assessed it online, which the leaf's Notes forbid.
`spctl` of the plain un-notarized fixture: `rejected`, `source=Unnotarized
Developer ID`, exit 3, 0.3 s. Put to the human.

**The human chose to ask Gatekeeper.** Of four answers put to them (ask
Gatekeeper through `spctl`; ship the offline `notarized` check and document its
false refusal; call the private `SecAssessmentCreate` in process; drop the
precheck), they chose the first: for a quarantined staged image in the per-user
root, `/usr/sbin/spctl --assess --type open --context context:primary-signature`
with a timeout, refusing `REJECTED` when it says no. It judges as the platform
does, online lookup included, and shows no dialog. The bundled root is left
alone: its quarantine is the application's, judged at launch.

**The check precedes the principal-name check, and that is what lets it be
watched to fail safely.** Its test loads the plain fixture first (the control),
then a quarantined copy of the same binary under its own content. With the
refusal removed, that copy is refused for its colliding principal name instead,
so the test goes red without the host ever `dlopen`ing a quarantined
un-notarized image — which could raise the very dialog this leaf removes, on the
host, where nothing may.

**Watched red.** With the `checkGatekeeper` call removed, run alone, the test
failed on all six diagnostic fragments and on nothing else: the refusal became
"The principal class name KoineFixtureProviderFactory is already registered by
another image", the control still loaded, and the quarantined copy's
initializers never ran. Restored, green. The first red run also showed the test
armed the initializer log only after the control loaded, which passes in the
suite and fails alone; fixed.

**The diagnostic's commands quote their paths.** The guest's staging directory is
under "Application Support", so an unquoted `chmod -R u+w <staged>` breaks on
the space; the VM run takes the command out of the diagnostic verbatim and runs
it, which is what shows it works.

**`task app:verify` is broken by an earlier leaf, and is cut, not fixed here.**
Rebuilt after this leaf's loader change, the notarized bundle (submission
51b99a60-9266-409c-bfb3-c41bfb05f65d, Accepted, stapled) fails
`scripts/verify-app.sh`: the executable's run paths are only
`@executable_path/../Frameworks`, and the script demands `/usr/lib/swift` too —
which the compiler stops emitting once the floor is macOS 26
(`support-matrix-and-latency-k44`, which measured a signed, not notarized,
build). Not this leaf's goal and not in its way: the VM route checks the staple
itself.

**The first VM run failed on the instrument, not on Koine.** Log
`notarized-20260921T…` (scratchpad `vm1.out`): the un-notarized provider was
refused before `dlopen` with no dialog, as intended, but on the next relaunch
`await_service` reported "macOS refuses the quarantined plugin" while its own
`BLOCKED_STARTUP` read "no" — the text it had matched was Koine's window showing
the loader's diagnostic, which names `libFixtureProvider` as the dialog did.
`await_service` now matches the dialog's wording (`Not Opened|could not verify`),
as `assert_no_system_refusal` already did.

**The second VM run passed** (`notarized-20260921T175128`, subjects digested
unchanged across it; evidence in
`docs/verification/provider-quarantine-precheck-vm.md`). On the clone the
offline `notarized` requirement read "not satisfied" on the notarized provider
before Koine started, and Koine loaded it anyway — the human's choice, seen
working on the case the approved shape would have got wrong.

**No ADR.** The rule and why `notarized` is not the check live in the spec's
"Loading and trust", where `provider-quarantine-rule-k47` put the platform
constraint; no ADR states the loader's checks, and none conflicts.
