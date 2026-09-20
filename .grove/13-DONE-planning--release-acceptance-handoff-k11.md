# release-acceptance-handoff-k11

## Goal

Plan the closing increment: prove the assembled, signed Koine against the
approved contract as a whole, state what is supported, and hand ModalAnyware a
verifiable public contract to build its Machine client against.

## Context

Root brief "Done when"; spec sections "Client handoff", "Test seams and
acceptance" and "Scope and agreement". Earlier stages verified their own
slices; this stage owns only what is a property of the whole.

## Done when

The tree holds narrow leaves delivering:

- **Contract conformance.** The schema introspected from the running signed
  application matches `docs/design/desktop-schema.graphql` in types, fields,
  arguments and nullability, with the agreed descriptions; any intended
  difference is reconciled in the spec, not left as drift. A client written
  only from the documented contract — descriptor, bearer header, the five
  operations in `docs/design/desktop-operations.graphql`, standard codegen from
  introspection — runs the whole obtain-grant, discover, list, focus path.
- **Release acceptance in VMs** on the signed release build: entitlements and
  Accessibility attribution; login launch with no client installed; both grant
  workflows; revocation; absent and revoked OS consent; closure, duplicate
  titles, PID reuse and restart behaviour. Warm query-to-choices and
  selection-to-focus latency measured in a real keyboard workflow and reported
  with machine, OS, application and distribution — a report, not a target.
  The supported OS/CPU matrix is stated from what was actually verified.
- **ModalAnyware handoff.** A Koine-side statement of the contract version a
  client targets and how to verify against it, and the required ModalAnyware
  changes (from the spec's "Client handoff") delivered to that repository's
  owner as an issue or note. Koine sessions do not edit sibling repositories.
- **Documentation current.** README, spec status lines and architecture views
  no longer say nothing is built; acceptance obligations the spec lists as
  unproven are either marked established with their evidence or explicitly
  still open.

## Notes

Follow `desktop-delivery-k3`'s cutting shape (see `resident-app-manual-grants-k7`).

Any acceptance failure here is a finding against an earlier stage's slice: add
a leaf for the repair rather than absorbing it, and never resolve it by
narrowing the contract without the human.

Open-source licensing and distribution policy remain undecided and do not gate
this stage.

## Decisions (running log)

**Notarization is in the stage, and Homebrew distribution with it.** Asked
whether release acceptance should run on a notarized build or accept the
Developer ID-signed bundle and leave Gatekeeper open, the human chose to
notarize, and added that Koine should be installable with Homebrew from
`Linkuistics/homebrew-taps`. Four evidence documents already defer the same gap
to this stage — the golden image has Gatekeeper assessments disabled and the
upload route sets no quarantine attribute — so without notarization "the signed
release build" is the same bundle every earlier stage ran.

**The cask downloads from a public GitHub release, so Koine is published.** A
cask needs a publicly reachable artifact; Koine had no remote, no `LICENSE`, no
tag and no bundle version. Offered a public `Linkuistics/Koine` release, a
private repo with the artifact hosted elsewhere, or building the artifact and
deferring the tap, the human chose the public release. This settles the
open-source distribution question the root brief and this task file both parked:
it is decided, not drifted. The existing `Casks/modaliser.rb` is the shape to
follow, minus its quarantine-stripping `postflight` — a notarized Developer ID
build does not need it, and keeping it would hide a notarization failure.

**Apache-2.0**, the licence every public Linkuistics repository already carries
(Modaliser, TestAnyware, the tap itself). Its explicit patent grant matters for a
published plugin ABI that third parties compile providers against; MIT has none.

**notarytool authenticates with an App Store Connect API key.** No keychain
profile exists on this machine. The human chose an API key (Issuer ID, Key ID,
`.p8`) over an Apple ID and app-specific password, stored once with `xcrun
notarytool store-credentials`. The profile name is read from
`KOINE_NOTARY_PROFILE`, defaulting to `koine-notary` — the same
overridable-with-no-fallback shape `scripts/signing-env.sh` uses for the signing
identity. Creating the key is the human's step and blocks the first leaf.

**The supported matrix is macOS 26 on Apple Silicon, and the declared
deployment target is narrowed to match.** The only golden image is
`testanyware-golden-macos-tahoe` on arm64, and Intel cannot be virtualized on
Apple Silicon at all, so an x86_64 claim is unfalsifiable here rather than merely
untested. Offered a second older golden or a matrix distinguishing verified from
declared, the human chose to narrow the claim. `docs/specs/machine.md` presently
says "requires macOS 13 or later"; that becomes 26. The back-deployment items
`binary-compatibility.md` left — `libswiftCompatibilitySpan`, older framework
minors, a different compiler on each side, x86_64 and universal binaries — become
explicitly out of scope rather than unproven obligations.

**Cut as one stage node of eight impl leaves, not two stages.** Acceptance and
distribution share their whole context — the notarized bundle, the signing
identity, the VM route — so splitting them into two groves would duplicate that
context in two briefs to no benefit. Distribution is the last leaf group inside
the one stage.
