# provider-quarantine-rule-k47

## Goal

Write down the rule that `notarized-release-build-k39` established empirically
and that nothing in Koine's documentation currently states: **a provider bundle
that arrives quarantined must be notarized by its author, or its quarantine
attribute must be cleared when the user approves it — otherwise macOS refuses
the `dlopen` on any Gatekeeper-enforcing Mac, after Koine's own approval and
team checks have already passed.**

## Context

- **The refusal takes the whole service down, not just the provider.** Measured
  on a live clone: Koine's process running, the refusal dialog on screen, and no
  `endpoint.json` in its data directory minutes later. Providers are `dlopen`ed
  while the service comes up and the refusal is a modal dialog a person must
  dismiss, so the server never begins listening until someone clicks **Done**. A
  user who downloads a third-party provider can stop Koine starting at all, with
  no clue but a system dialog naming a `.dylib`. Documenting the rule is
  therefore the floor, not the ceiling: **whether provider loading belongs on the
  startup path at all is a design question for the human**, and this leaf's job
  includes putting that question to them rather than answering it.
- `notarized-release-build-k39` ran the first Gatekeeper-**enforcing** VM
  acceptance and answered the question `signed-app-provider-vm.md` had deferred
  in exactly these words: "whether a quarantined, un-notarized same-team plugin
  still passes `dlopen` is not shown here". It does not. macOS raised
  "“libFixtureProvider.dylib” Not Opened / Apple could not verify
  “libFixtureProvider.dylib” is free of malware that may harm your Mac or
  compromise your privacy", offering **Move to Trash** and **Done**.
  `docs/verification/notarized-release-vm.md` records both that refusal and the
  same provider loading once the attribute is cleared, with nothing else changed.
- **Koine's own provider is not affected**, and saying so is half the point: the
  application's notarization ticket covers `Contents/PlugIns`, so the bundled
  desktop provider is `ACTIVE` on a quarantined, enforcing clone. This is a rule
  about the **per-user root**, `~/Library/Application Support/Koine/Providers`,
  and therefore about third-party provider authors.
- The refusal happens **downstream of everything Koine checks**. The fixture
  carried a valid `fixture.approval.json` naming `TA43A4RUP3` and is signed by
  that team; Koine admitted it and called `dlopen`, and the kernel refused. So
  this is not a bug in the loader and not something the approval record can
  express — which is exactly why it has to be written down rather than fixed.
- The root brief's "On the horizon" already describes a future native UI to
  install a provider bundle, show its signing identity and approve it.
  `provider-trust-and-install-roots-k23` fixed what that UI must produce. This
  leaf adds one more obligation to that future UI's description — clearing
  `com.apple.quarantine` on approval — without building it.

## Done when

- **README** states the rule where it already explains the per-user provider root
  and the approval record ("Lifecycle" and the sections around it): a downloaded
  provider is quarantined, a quarantined un-notarized image is refused at
  `dlopen` by Gatekeeper regardless of Koine's approval, and the two ways out are
  notarization by the provider's author or clearing the attribute at approval
  time. It says plainly that the bundled desktop provider is unaffected and why.
- **`docs/specs/machine.md`** carries the same fact wherever it specifies
  provider admission, as a stated platform constraint on the per-user root rather
  than as a new Koine behaviour. Do not invent a new admission outcome for it:
  Koine admits the provider and the platform refuses the image, and the spec
  should say that, not pretend Koine could have predicted it.
- **The horizon note** for the provider-install UI — wherever
  `provider-trust-and-install-roots-k23` left it — gains clearing the quarantine
  attribute on approval as part of what that UI has to do.

## Notes

**Documentation is this leaf's deliverable; the design question is its
escalation.** The loader needs no edit to record the rule: it did what it was
specified to do and the platform overrode it. Do not add a pre-`dlopen`
quarantine check, a timeout, or off-startup provider loading in passing — each is
a real candidate answer to "should a refused provider be able to stop the service
starting", and that question goes to the human with a recommendation and this
evidence, to be cut as its own leaf if they want it. Answering it inline is the
one thing this leaf must not do.

**Do not weaken anything to make the refusal go away.** `App/Koine.entitlements`
stays empty, and `seal.sh`'s `--timestamp=none` stays as it is: the fixture is
deliberately un-notarized test material, and it being refused is the evidence
this leaf documents rather than a defect to repair.

**Where the rule is checked.** `notarized-release-vm.md` is the evidence; this
leaf must not restate its transcript, only cite it.
`signed-app-provider-vm.md`'s deferred item is already marked answered against
that document by `notarized-release-build-k39`, so there is nothing to do there.

## Decisions (running log)

**The rule includes when to clear, not just that clearing works.** The evidence
shows clearing the attribute on the installed bundle after a refusal leaves the
provider `REJECTED`, because the content-named staged copy is reused and keeps
the attribute. So README, spec and horizon note all say "before Koine first
stages it", and README gives the manual recovery: delete that bundle's
`<Name>-<digest>` staging directory with Koine stopped.

**"Never strip quarantine" is kept and narrowed to the loader, not removed.**
The spec's "Loading and trust" and README both already forbade stripping
quarantine. The new obligation — the future install UI clears it on approval —
reads as a contradiction unless the actor is named: the loader never strips it
to make a refused plugin load; clearing it is the user's act of approval. The
spec sentence now says that.

**No new admission outcome.** The spec states the case is the ordinary
`REJECTED` for a dynamic-loader failure, carrying the loader's message, and
says why there is no separate outcome: nothing checked before `dlopen`
distinguishes it.

**The horizon obligation is written twice, deliberately.** Root brief "On the
horizon" (where `provider-trust-and-install-roots-k23` left the UI's
obligations) and the spec's "A later increment adds … an install and approval
UI" sentence, which is where the durable contract describes that UI.

**The human chose a pre-`dlopen` check** over loading per-user providers off
the startup path and over documenting only. Cut as
`quarantined-provider-precheck-k49`, inserted before
`documentation-and-handoff-k45` because it revises the README and spec text
written here; the stage brief's decomposition names it. The recommendation
rested on the loader already running static `SecStaticCode` validation before
`dlopen`, so the check is one more of the same kind and keeps startup-composed
schema; the `notarized` requirement keyword was flagged to the human as
unverified and the new leaf must verify it first.
