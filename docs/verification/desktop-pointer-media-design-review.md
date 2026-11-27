# Pointer and media design review

**Review:** pointer-media-k7

The review inspected producer commit
`efb56590387b9edd3bca249b11aa3fdf5e6ad9f1`, against the root brief and the
decisions of `plan-k1`. The design is not served yet. One material finding
concerns the consent guard for posting events.

## Findings

### F1 — P2: Accessibility trust does not establish event-posting permission

**Location:** `docs/specs/machine.md:1285`, `:1356`, `:1368` and `:1378`, and
`docs/adr/desktop-automation-uses-public-accessibility.md:35`. The producer's
`pointer-media-k2` running log explicitly selects `AXIsProcessTrusted` as the
guard for the nudge and media keys.

[That function](https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted)
reports trust for the Accessibility API. Apple documents a
separate `PostEvent` privacy service for sending CGEvents. Its
[privacy policy schema](https://github.com/apple/device-management/blob/release/mdm/profiles/com.apple.TCC.configuration-profile-policy.yaml)
defines separate Accessibility and PostEvent entries, each with an allow or
deny policy. An [Apple DTS explanation](https://developer.apple.com/forums/thread/857997)
also distinguishes the services and explains that their shared placement in
Settings does not make them one service. The distinction predates the newer
macOS beta behavior discussed in that thread.

Consider a managed installation where Accessibility is allowed but PostEvent
is denied. The proposed trust check can pass without permission to post.
Following the specified algorithm then calls `CGEvent.post` and returns
`NUDGED` or a media-key receipt, instead of refusing with an OS-permission
failure before attempting either post. The
[posting API](https://developer.apple.com/documentation/coregraphics/cgevent/post(tap:))
returns no permission result to repair that classification afterwards. This is
a counterexample derived from the documented policy separation, not a native
reproduction in this review.

The producer's VM evidence does not exclude that case. The probe records both
`AXIsProcessTrusted()` and `CGPreflightPostEventAccess()`
(`Fixtures/MediaKeyProbe/main.swift:58`), and its caller requires both
(`scripts/vm-check-media-key-music.sh:44`). Both were true in the recorded run.
Their conjunction establishes no implication from the first value to the
second, and the probe is not the signed Koine application.

This is a material risk to the root brief's consent requirement and to the
design's permission-failure contract. The statement that existing window-focus
consent alone establishes the posting posture is too strong. A successful
receipt still need not certify delivery to an application, but that limit does
not replace a check of the relevant OS permission.

**Necessary correction:** Specify a non-prompting event-posting preflight for
the new posted-event operations, with refusal before both posts when that
permission is unavailable. Reconcile the consent statement, failure table and
ADR with the selected check and existing error vocabulary. Preserve the rule
that an ordinary action never requests consent. The later acceptance must
establish the signed Koine application's posting posture; observing both
permissions on the probe does not establish it. No new permission request or
change of the agreed consent scope is authorized by this finding.

## Inspection and limits

The inspection covered the design SDL and example operations, the Taskfile
validator, the changed contract and disclosure text, the authority and trace
rows, the requirements row, the glossary additions, the changed ADR, and the
Music-check instrument and saved evidence. It also followed the existing
pointer-move and native-loader paths through the source ranges below.

- **Authority and output.** The new roots separate read and control authority.
  The nudge receipt carries only its outcome, and the key receipt only the
  submitted key. Neither carries coordinates or player state. The failure table
  requires capability refusal before effects. No additional read-data leak was
  supported by the inspected contract.
- **Pointer behavior.** The design creates both mouse-moved events before
  posting, refuses a button held at its check, and synthesizes no button event.
  It states the remaining check-to-post race and right-edge clipping. Unlike
  the earlier display-focus defect, this sequence requires no intervening
  target-focus wait. This inspection establishes no atomicity or native nudge
  acceptance.
- **Coordinates and unknowns.** The primary-height conversion agrees with
  Modaliser's `CursorLibrary.swift:179` and the existing conversion in
  `Providers/DesktopProvider/Logic/WindowGeometry.swift:74`. Apple documents
  the primary screen at index zero in
  [`NSScreen.screens`](https://developer.apple.com/documentation/appkit/nsscreen/screens).
  The nullable root represents an unestablished position. The witness instead
  reads a null-source CGEvent (`Fixtures/WindowIdentityProbe/main.swift:251`).
  This is no two-display qualification; the root brief assigns that check to
  issue 23.
- **Disclosure and compatibility.** The draft covers new and existing grants,
  the pointer read and nudge, all six keys, system volume and mute, and Music's
  possible launch and activation. The new required feature fits the existing
  loader: it checks manifest features before selecting and loading an update
  (`Sources/KoineProviderLoader/ProviderLoader.swift:392` and `:560`). Current
  host features contain v1, not v2 (`Sources/KoineCore/Composition.swift:66`).
  This supports the refusal design, not a signed compatibility-pass claim.
- **Modules, ADRs and seams.** Plain-value logic, real-bundle GraphQL, signed
  compatibility and isolated-VM evidence reuse the agreed enabling points.
  The proposal adds no persistent provider state or public testing interface.
  Extending the existing automation ADR keeps the decision set compact; F1
  concerns its consent claim. Player response to next and previous, Koine's
  own native behavior and release acceptance remain assigned to later leaves.

The review ran no tests, builds, linters, formatters or GUI operations, and
changed no production code, test code or design artifact. It inspected the
validator rather than rerunning it. The probe and VM log support the Music
disclosure on their declared subject, not Koine runtime conformance.

The graph indexer and coverage command refused to start because a
pre-coordination or unverified CBM generation was active. No graph generation
or clean coverage result was available. Code claims rely on targeted direct
source reads, including the cited ranges, rather than an exhaustive graph
result.
