# release-acceptance-k38 — brief

## Goal

The sixth and last working Koine: a notarized, versioned release of the resident
application, proven against the approved contract as a whole rather than one
slice at a time, with a stated support matrix, a handoff ModalAnyware can build
its Machine client from, and installation by `brew install`. Planned by
`release-acceptance-handoff-k11`.

## Done when

- **Contract conformance** (public GraphQL seam): the schema introspected from
  the running notarized application matches `docs/design/desktop-schema.graphql`
  in types, fields, arguments, nullability and descriptions, as a repeatable
  check rather than a one-time read. Every intended difference is reconciled
  into `docs/specs/machine.md` and the design SDL, never left as drift. A client
  written only from the documented contract — the endpoint descriptor, the
  bearer header, the operations in `docs/design/desktop-operations.graphql`, and
  a schema generated from introspection — runs the whole obtain-grant, discover,
  list, focus path with no knowledge of Koine's internals.
- **A notarized release** (TestAnyware seam): the bundle carries a version,
  is notarized and stapled, and on a **Gatekeeper-enabled** clone a quarantined
  copy launches at first run, is attributed to Koine in the Accessibility
  prompt, and loads a quarantined same-team provider bundle.
- **Release acceptance in VMs** on that build: entitlements and Accessibility
  attribution; login launch with no client installed; both grant workflows;
  revocation, including of an enrolled grant through the window; absent and
  revoked OS consent; window closure, duplicate titles, PID reuse and restart
  behaviour. Warm query-to-choices and selection-to-focus latency measured in a
  real keyboard workflow and reported with machine, OS, application and observed
  distribution — a report, not a target. The supported OS/CPU matrix states what
  actually ran.
- **Documentation current**: `README.md`, the spec's status lines and the
  architecture views no longer describe Koine as unbuilt or partly built; every
  acceptance obligation the spec lists is either marked established with the
  evidence document that establishes it, or explicitly still open.
- **ModalAnyware handoff**: a Koine-side statement of the contract version a
  client targets and how to verify against it, plus the required ModalAnyware
  changes from the spec's "Client handoff", delivered to that repository's owner
  as a note. Koine sessions do not edit ModalAnyware.
- **Installable**: `Linkuistics/Koine` is public under Apache-2.0 with a tagged
  release carrying the notarized artifact, `Casks/koine.rb` is in
  `Linkuistics/homebrew-taps`, and `brew install --cask` of it is seen working
  in a clean VM.

## Decomposition

**Process identity stays `{ pid, startedAt }` for `koine-desktop/1`.** On
2026-09-29 the human judged the no-time identity work (k51 and its impl k52) of
marginal relevance to the release and pruned it, reversing k45's rejection of time
as an identity. The capture ADR, the public Accessibility ADR, the spec's native
targeting discussion, README and the client guide state the kept contract and the
reuse races it accepts. The investigation's verification documents remain as
records. The desktop schema and its digest do not change.

**Publication waits on compact evidence and current-state docs.** On 2026-09-29, when
`homebrew-distribution-k46` asked how to publish, the human refused to put the
~579 MB of callback verification evidence on GitHub. `compact-verification-evidence-k276`
found the callback research line (the pruned k51 subtree) cited only by the
architecture views and, with the human, removed it and every other k51 record the
contract does not cite: the tip is 6.4 MB. The human also ruled that the docs carry
no history or future plans, except non-obvious rejected alternatives framed as
such; `current-state-docs-k277` sweeps the rest before k46 publishes. A filtered
history would pack to ~3.5 MiB against 110.7 MiB unfiltered (k276's log). k46 rewrote
the local history to the tip's paths (3.65 MiB) and published it. The human's
rule is that `main` never carries `.grove/` at its tip: grove works on the
`grove` bookmark, and `main` is a publish commit deleting `.grove/` on top of it.
`homebrew-install-vm-k278` was cut from k46 for the clean-VM install proof when
the host's TestAnyware could not drive a macOS guest.

Fourteen leaves, all impl but one design, ordered by dependency and then by
risk; six of them were cut during the stage rather than when it was planned — `provider-quarantine-rule-k47`
during the first leaf's run, `desktop-receipt-descriptions-k48` during the
second's, as the one finding the conformance check could not reconcile,
`quarantined-provider-precheck-k49` during k47's, as the human's answer to the
design question k47 put to them, and `app-verify-run-paths-k50` during k49's, for
a defect k44's floor narrowing left in `task app:verify`, and
`process-identity-without-time-k51` with its impl `-k52` during k45, as the
human's answer to the contract-only client's first finding. The
notarized build comes first because every later leaf runs on it and it carries
the stage's two unknowns: whether a Gatekeeper-enabled clone can be produced at
all, and the notary credential. Conformance comes next so that any contract
drift is found before five leaves of evidence are written against the wrong
schema.

1. `notarized-release-build-k39` — bundle versioning, `task app:notarize`,
   stapling, and a Gatekeeper-enabled VM clone: quarantined first launch, prompt
   attribution, and a quarantined same-team provider. Closes the gap four
   evidence documents defer to this stage.
2. `schema-conformance-k40` — the introspected schema against the design SDL as
   a repeatable check, and the reconciliation of every difference into the spec.
3. `desktop-receipt-descriptions-k48` — the one difference `schema-conformance-k40`
   found that the served schema owned: `DesktopFocusReceipt` states the field's
   fact on the type and the type's own fact nowhere. Cut during k40 with the
   human's decision recorded in it, and placed **before** the client and the
   evidence leaves because it moves the schema digest they all cite.
4. `contract-only-client-k41` — a client built from the documented contract and
   generated types alone, running the whole path in a VM.
5. `platform-acceptance-k42` — the composed platform run on the notarized build:
   entitlements, attribution, login launch with no client, absent and revoked
   consent, closure, duplicate titles, PID reuse and restart.
6. `grant-workflow-acceptance-k43` — both grant workflows end to end on the
   notarized build, plus the three things `grant-enrollment-vm.md` did not
   drive: a refusal shown in the window, several requests pending together, and
   revoking an enrolled grant through the window.
7. `support-matrix-and-latency-k44` — the latency report in a real keyboard
   workflow, and the supported OS/CPU matrix stated from what ran, with the
   declared deployment target narrowed to match.
8. `provider-quarantine-rule-k47` — the rule `notarized-release-build-k39`
   established on the first Gatekeeper-enforcing clone, written into README, the
   spec and the provider-install UI's horizon note: a quarantined, un-notarized
   provider in the per-user root is refused at `dlopen` by the platform, after
   Koine's approval and team checks have passed, so its author must notarize it
   or approving it must clear the attribute. Koine's own bundled provider is
   covered by the application's ticket and is unaffected. Cut during k39 and
   placed **before** the documentation sweep so that sweep finds the docs already
   consistent.
9. `quarantined-provider-precheck-k49` — the human's answer to k47's question:
   the loader refuses a quarantined, un-notarized per-user provider before
   `dlopen`, as `REJECTED` with a diagnostic naming both ways out, so macOS's
   modal dialog can no longer hold the service's startup. Before the
   documentation sweep because it revises what k47 wrote in README and the spec.
   The `notarized` requirement proved to be an offline lookup a provider bundle
   cannot satisfy by stapling, so the human chose Gatekeeper's own assessment
   (`spctl`) instead.
10. `app-verify-run-paths-k50` — `task app:verify` demands the `/usr/lib/swift`
   run path a macOS 13 floor produced; the floor-26 build has only
   `@executable_path/../Frameworks`, so the check fails on a good notarized
   bundle. Before the documentation sweep and the release, which both rely on
   that task.
11. `documentation-and-handoff-k45` — README, spec status lines and architecture
   views made current; every acceptance obligation marked established or open;
   the contract-version statement and the ModalAnyware handoff note.
12. `process-identity-without-time-k51` (design) — **abandoned.** It was meant to
   replace the time-based process incarnation with one that does not depend on
   time, after the human rejected time in k45 ("You cannot guarantee
   non-collision"). The human pruned it on 2026-09-29 as out of proportion to the
   release; see the note above.
13. `process-identity-without-time-k52` — **abandoned** with k51.
14. `homebrew-distribution-k46` — Apache-2.0, the public repository, the tagged
   release carrying the notarized artifact, the cask, and `brew install`
   verified in a clean VM. Last, because it publishes what the leaves
   before it proved and documented.

## Pointers

- Spec: `docs/specs/machine.md` — "Client handoff", "Test seams and acceptance"
  (every row), "Scope and agreement", and the macOS version claim in
  "Application composition and availability".
- The design contract: `docs/design/desktop-schema.graphql` and
  `docs/design/desktop-operations.graphql`. The digest rule they are checked
  through is the spec's "Schema digest".
- **This stage's input is the deferral sections of the evidence documents**, and
  they are a checkable list rather than a memory exercise. `binary-compatibility.md`
  has "Left for `release-acceptance-handoff-k11`"; `signed-app-provider-vm.md`
  has one too; `resident-app-vm.md`, `accessibility-status-and-consent-vm.md`,
  `grant-enrollment-vm.md`, `desktop-focus-vm.md`,
  `desktop-application-and-windows-vm.md` and
  `desktop-references-and-permission-vm.md` each carry a "what this does not
  show". Read them before cutting any leaf's work, and close or explicitly
  decline each item.
- Seams: public GraphQL for the contract, TestAnyware VMs for everything that
  needs a real signed, notarized, installed Koine.

## Notes

**Four decisions the human settled when this stage was planned**, recorded in
full in `release-acceptance-handoff-k11`'s running log:

- The stage notarizes, and ships through Homebrew. Distribution is no longer
  parked: `Linkuistics/Koine` becomes **public under Apache-2.0**, with the
  notarized artifact on a tagged GitHub release and a cask in
  `Linkuistics/homebrew-taps`. Both the root brief and this stage's planning
  leaf previously said licensing was undecided; it is decided.
- notarytool authenticates with an **App Store Connect API key**, stored once by
  the human with `xcrun notarytool store-credentials`. The profile name is read
  from `KOINE_NOTARY_PROFILE`, default `koine-notary`, overridable with **no
  fallback** — the shape `scripts/signing-env.sh` already uses for the signing
  identity. No profile exists on this machine yet, so the first leaf is blocked
  until the human creates the key; it must fail loudly and say so rather than
  degrade to an unnotarized build.
- The supported matrix is **macOS 26 on Apple Silicon**, and the spec's "requires
  macOS 13 or later" narrows to match. Intel cannot be virtualized on Apple
  Silicon, so x86_64 is unfalsifiable here rather than untested. The
  back-deployment items in `binary-compatibility.md` — `libswiftCompatibilitySpan`,
  older framework minors, a different compiler on each side, universal binaries
  — become out of scope, stated as such, not carried as open obligations.
- Acceptance and distribution are **one stage**, because they share the
  notarized bundle, the signing identity and the VM route.

**The sibling-repository rule has exactly one authorized exception.** Koine
sessions do not edit sibling repositories, and ModalAnyware is still hands-off —
its changes are delivered as a note to its owner. The human explicitly asked for
Koine to be added to `Linkuistics/homebrew-taps`, so the cask commit there is
authorized; nothing else in that repository is.

**An acceptance failure is a finding against an earlier stage, not this stage's
to absorb.** Add a leaf for the repair rather than fixing it inline, and never
resolve one by narrowing the contract without the human. That is the rule the
conformance leaf is most likely to meet, which is why it runs second.

**The human's host rule binds every leaf here** (`resident-app-skeleton-k13`):
anything that launches Koine, drives its UI, or touches the clipboard, the
account's real data directory or login items runs in a TestAnyware VM, never on
the host. That now includes introspecting the running application for
conformance.

**The Gatekeeper-enabled clone is this stage's one real unknown.** Every VM run
so far used a golden whose assessments are disabled, and `spctl` global enable is
restricted on recent macOS. If a clone cannot be put into a Gatekeeper-enforcing
state, that is a question for the human with a recommendation — not a quiet
reversion to the disabled golden, which would make the notarization evidence say
nothing it did not already say.

**Tooling that already exists and should be reused, not rebuilt**: `task app`,
`task app:verify`, `task compat`, and the `app:vm-verify*` family;
`scripts/vm-verify-lib.sh`'s `launch`, `scripts/vm-verify-desktop-lib.sh`'s
`guest_json` and `scripts/vm-verify-accessibility.sh`'s `ask` — the patterns for
a guest read or mutation that survives TestAnyware's false 30s timeouts;
`scripts/vm-verify-enrollment-client.py`, a complete enrolling client;
`scripts/vm-verify-desktop-client.py`, a complete desktop client. Two platform
facts from earlier runs still bind: a SwiftUI confirmation whose action has the
destructive role has no default button on macOS 26.5, and a grant's capabilities
are served as a sorted set.

One `task test` run in `client-enrollment-k33`'s last leaf failed in
`KoineServerTests` and was not reproduced in four further runs; its detail was
not captured. If it recurs here it is a finding worth a leaf.
