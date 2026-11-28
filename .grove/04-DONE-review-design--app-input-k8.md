# app-input-k8

**Reviews:** app-input-k3

## Goal

Try to break the design of app input for Koine 0.7.0 before the
implementation leaves code against it.

## Context

- The design is in the commit of `app-input-k3`. Read its diff against the
  current tree.
- The artifacts:
  - `docs/design/input-schema.graphql` and
    `docs/design/input-operations.graphql`, with
    `task design:app-input-check` in `Taskfile.yml`.
  - `docs/specs/app-input.md`, the input contract.
  - `docs/specs/machine.md`: the `input:read` and `input:control` rows under
    "Capability disclosures", and the sentence on protected UI targets under
    "Errors and partial data".
  - `docs/specs/workflow-providers.md`: the paragraph "Protected UI targets",
    the authority rows "Application keystrokes" and "Control-digit Space
    switching", and the trace rows "Desktop windows", Safari to Zotero and
    "Grant disclosure".
  - `CONTEXT.md`: front app, input target, chord, protected target, Mission
    Control desktop and Space switch.
  - `docs/adr/desktop-automation-uses-public-accessibility.md`: the
    paragraphs from per-process posting to the count of Mission Control
    desktops.
  - `docs/design/app-input/`: the views, served by
    `task design:app-input-serve`.
- The contract:
  - The "Done when" of the root brief `.grove/_BRIEF.md`.
  - The "Done when" of `.grove/03-DONE-design--app-input-k3.md`.
  - Antony's rulings, in his own words, in the running logs of `plan-k1` and
    `app-input-k3`. In `app-input-k3`, he dropped the front check, chose the
    SkyLight count across all displays, and made every app a target under the
    capabilities.
- The evidence is `docs/verification/keystroke-route-vm.md`, the record of
  the route probe.

## Done when

- The review reports its findings against the contract. Each finding names
  the artifact, the line, the contract item and the evidence.
- The review changes no artifact. It cuts an integration step only for
  findings worth acting on, as the review procedure states.

## Notes

The review answers these questions, among others that it finds:

- Koine refuses only its own process as a target. Can a chord reach another
  surface of Koine, such as another Koine process, and approve a grant there?
- Koine recognises itself by its process identifier and its bundle
  identifier. Does that recognise every copy and build of Koine that can hold
  grants?
- A chord now reaches a target in the background. Does any statement of the
  contract, the disclosure, the descriptions or the views still assume the
  front check?
- Does the `input:control` disclosure state the whole reach of a chord, also
  for consent and security prompts and for System Settings?
- Koine counts the Spaces of type 0 on every display, in the order of the
  SkyLight reply. Does that count match the shortcut "Switch to Desktop N" in
  every display arrangement that macOS allows?
- Can any refusal or failure come after the first event of a chord or a Space
  switch, and leave a modifier key down?
- Is each refusal an outcome or an error by a rule that a client can follow?
- `inputTarget(process:)` gives null for a process that `NSRunningApplication`
  does not report. Does a configured app depend on such a process?
- Without the desktop provider, the missing-owner cascade removes the whole
  input contribution. Does the contract state that consequence where a client
  or a person sees it?
- Is the decision that input needs no disclosure feature of the host true for
  every released host, by "Reserved identities" in the machine contract?
- Antony's ruling changed the rule on protected UI targets in the workflow
  providers spec. Does that rule still bind menus in every other respect?

## Decisions (running log)

**Review boundary.** This review inspects the design from
`991bc79425eff0ebed0005b74c5340cfec6d72f1`, its requirements, the recorded
route probe and the relevant source. It changes no design, production code or
test. It runs no test, build, lint, format or GUI command. The graph CLI
refused `list_projects` because a pre-coordination or unverified generation
was active. Source evidence therefore comes from targeted file reads and
searches; no graph coverage or generation is claimed.

**Handoff.** The findings below meet the acceptance or material-risk threshold.
The flat integration sibling `app-input-k9` will triage them before
`input-keystrokes-k4`. It shares the root brief and needs no new node. Its
body names this review, without making the finding list its charter.

## Findings

Coordinates below refer to the reviewed commit. Each correction describes the
smallest useful response for triage; this review applies none of them.

### F1 — P1: Per-process posting does not bind the captured incarnation

**Location:** `docs/specs/app-input.md:167` and `:172`;
`docs/design/input-schema.graphql:28`;
`docs/adr/desktop-automation-uses-public-accessibility.md:57`.

**Contract:** The root brief's Route item requires that no other app receive
the chord. Its Protected targets item requires refusal of Koine. The capture
decision identifies the target by PID and start instant, rather than PID alone.

**Evidence and consequence:** The design checks the incarnation and protection,
creates the events, then calls `CGEventPostToPid` separately for every event.
Apple's SDK declares that call with a PID and an event only
(`CGEvent.h:372` in the installed Command Line Tools SDK). Its
[public declaration](https://developer.apple.com/documentation/coregraphics/cgevent/posttopid(_:))
also takes only a PID. Neither call carries the checked start instant or a
held destination. If the checked process exits and its PID is reused before
a post, the stated design supplies the replacement's PID to that post. The
replacement has not passed either check. This is a check/use counterexample
derived from the interface, not an observed route-A reproduction. Actual PID
reuse is already evidenced by `docs/verification/retained-ax-binding.md`.

The assertion that remaining events reach no process after target exit is
therefore unsupported, as is unconditional delivery to the captured app only.
The existing accepted limits in `docs/specs/machine.md:2421` concern AX routing;
they do not establish that a raw-PID input post binds an incarnation. This can
also bypass the protection check if a replacement is Koine.

**Smallest useful correction:** Resolve the guarantee explicitly before coding
against it. Establish destination binding for the chosen mechanism, or obtain
explicit acceptance of this input race and reconcile the contract, disclosure,
schema descriptions and ADR. Repeating the check, or restoring a front-app
check, does not make check and posting atomic.

### F2 — P2: The shortcut comparator accepts unqualified modifier bits

**Location:** `docs/specs/app-input.md:228`.

**Contract:** The root brief's Space switching item requires refusal of a
remapped shortcut before posting. The operation must post Control and the
digit only when they name the configured system shortcut.

**Evidence and consequence:** The predicate compares only Shift, Control,
Option and Command. Thus a mask containing Control plus any bit outside those
four passes. The source copied by this design has exactly that predicate at
`Fixtures/KeystrokeProbe/main.swift:138` through `:162`. Apple separately
defines the Fn modifier in `CGEventTypes.h:92` and in its
[Fn flag documentation](https://developer.apple.com/documentation/coregraphics/cgeventflags/masksecondaryfn).
A three-integer entry for key code 19 and mask `262144 | 8388608` passes the
designed predicate even though Koine emits no Fn flag. The design provides no
evidence that such extra bits can be ignored by symbolic-hotkey matching.
The probe record explicitly says that no remapped shortcut was tested.

A read-only inspection of
`/Users/antony/Library/Preferences/com.apple.symbolichotkeys.plist` also found
existing enabled `standard` entries 7 and 8 with parameters
`[65535, 120, 8650752]` and `[65535, 99, 8650752]`. That mask is Control plus
Fn, so the ignored flag already occurs in this preference format. The source's
SHA-256 before and after that inspection was
`6a7e5753bdee829057258c37d22de026058098769905e9efe44643e93e31d8a9`.
This inspection changed no preference and posted no event.

This is a counterexample to the admission predicate, not a VM claim that the
Settings editor creates that particular binding. An unsupported or changed
mask format can be admitted as Control-2 instead of refused; then the front
app can receive the chord without a concurrent settings change.

**Smallest useful correction:** Specify which complete mask forms are admitted.
Reject unrecognised or additional semantic bits before posting unless evidence
establishes that they are irrelevant. Carry the extra-bit case into the agreed
plain-value Space-check seam; do not treat the probe's four-bit assumption as
qualification of all other bits.

### F3 — P2: Skipping a session tap does not hide the chord from all processes

**Location:** `docs/specs/app-input.md:192`;
`docs/design/input-schema.graphql:28`;
`docs/adr/desktop-automation-uses-public-accessibility.md:58`.

**Contract:** The design's descriptions must state the actual input contract
and limits. The route probe is evidence for the routing decision, rather than
evidence for properties it did not inspect.

**Evidence and consequence:** The probe used a session-level tap. The spec
generalises its absence of observations to no other process seeing the chord.
The installed SDK says that a per-process post enters before taps for the
specified process and passes through them (`CGEvent.h:354` through `:365`).
It also exposes process-specific taps to a caller (`:301` through `:319`), as
does Apple's
[process-tap API](https://developer.apple.com/documentation/coregraphics/cgevent/tapcreateforpid(pid:place:options:eventsofinterest:callback:userinfo:)).
The tap's destination is not the identity of the process that installed it.
An appropriately permitted observer can install a tap for the target process.

The route remains useful for avoiding the normal foreground/session path.
It does not supply the blanket observation isolation promised to clients.
A client can also incorrectly assume that every tap it owns is bypassed.

**Smallest useful correction:** Qualify the claim to the session-level taps
actually bypassed. State that destination-process taps remain in the route,
and reconcile the schema description, ADR and view captions. Do not change
the posting route merely to preserve the overstatement.

### F4 — P2: The authority ADR still requires the rejected protection policy

**Location:** `docs/adr/provider-authority-follows-effects.md:22` through `:25`.

**Contract:** The root brief's Protected targets item and Antony's final ruling
in `app-input-k3` admit every app except Koine under the capabilities. The ADR
set must describe one coherent current design.

**Evidence and consequence:** This binding ADR still requires input and menus
to refuse recognised consent/security UI before both reference issuance and
effects. In contrast, `docs/specs/workflow-providers.md:109` through `:122`
and `docs/specs/app-input.md:91` admit those targets. The changed desktop
automation ADR directs the reader to that workflow rule for input and menus.
An implementer following the authority ADR would refuse targets that the
agreed input contract expressly admits. A menus implementer inherits the same
contradiction.

**Smallest useful correction:** Reconcile this existing ADR in place with the
final protection rule and its intended application to menus. Preserve the
other independent menu obligations, including refusal of Koine, separate
references and no focus preparation. No new ADR is needed.

### F5 — P2: The grant disclosure omits static Space-switch fall-through limits

**Location:** `docs/specs/machine.md:2080`, compared with
`docs/specs/app-input.md:294` through `:301`.

**Contract:** The root brief requires disclosure of input control's reach
before release, in the Settings window and field descriptions. A material
limit already identified by the design must remain visible where the person
grants that reach.

**Evidence and consequence:** The final served disclosure states only a
settings-or-Spaces change in the instant before dispatch as the reason that
the front app can receive Control and the digit. The input spec separately
accepts preferences that macOS has not applied and an unqualified numbering
relationship across displays/full-screen Spaces. Both can persist while
nothing changes during dispatch. The Space-switch schema description mentions
different numbering, but the shared native disclosure omits it. The view's
caption in `docs/design/app-input/diagrams.json` also promises refusal of each
fall-through case and then names only the race.

This finding does not assert that global numbering is wrong on a particular
display arrangement. That native question remains unmeasured, as the probe
and design log expressly record. The defect is that the design itself admits
additional fall-through risks but the grant disclosure presents a narrower
condition. A person cannot assess the same reach from the granting UI as from
the input contract.

**Smallest useful correction:** Carry those existing static limits into the
shared disclosure and align the description and view claims. Alternatively,
restrict dispatch to a qualified posture and document that restriction. The
global-count decision and its deferred native checks need not be redesigned
merely to repair this disclosure.

## Review coverage and limits

- **Supported by inspection:** The schema separates read, chord control and
  the two-capability Space switch. Receipts expose only outcomes. The key
  table agrees with Modaliser after removal of modifier keys and aliases.
  The design orders consent, target/protection and complete event creation
  before any post, with no mid-chord refusal or automatic replay.
- **Supported for the shipped app identity:** `App/Info.plist:10` and
  `scripts/signing-env.sh:8` use `dev.antony.Koine`, and the build script
  checks that identity. The proposed bundle-identifier check covers ordinary
  copies with that identifier, not just the serving PID. No supported
  different-identifier grant UI was established by this inspection. F1 remains
  a separate check/use problem; arbitrary modified apps are not evidence of
  a shipped-copy defect.
- **Visible trade-offs:** The whole input contribution disappears without
  the desktop owner. The input spec and authority-view caption say so, and
  the machine contract exposes missing-owner diagnostics. The new input slot
  and existing framework feature supply a pre-load compatibility boundary;
  the declared N seam still must establish the real 0.6.0/new-host pair.
  Background-app reactions and the scheduled Chromium/Qt check retain the
  accepted finite scope. The native multi-display/full-screen and unapplied
  settings cases remain deferred evidence, not acceptance runs performed here.
- **Seams and ownership:** The plain-value logic seam, real-bundle loopback
  seam, signed compatibility pair and independent VM witnesses have concrete
  substitution or integration purposes. Their limits are explicit: the G seam
  refuses before posting, and no G case switches Spaces. F1 and F2 identify
  obligations the current design still leaves unresolved; the review does not
  certify native delivery, runtime conformance or the future acceptance run.
- **Verification performed:** Read the producer diff, current design sources,
  binding requirements/ADRs, Modaliser emitter, probe source/record and the
  relevant app identity/composition rules. Checked Apple's public API
  declarations and installed SDK comments for the disputed API claims. No
  new native reproduction, test result or exhaustive codebase claim is made.
