# provider-architecture-k48

**Reviews:** provider-architecture-k5


## Goal

Adversarially review the cross-cutting provider architecture against the agreed
workflow requirements before dependent designs build on it. Read the producer's
commit by its stable handle, then reconcile that diff with the current tree.



## Context

- `docs/requirements/modaliser-workflows.md` is the behavioral contract.
- `docs/specs/workflow-providers.md`, the additions to `docs/specs/machine.md`,
  `docs/adr/provider-authority-follows-effects.md`, and the reworked server,
  reference and resilient-framework ADRs are the artifact.
- The root brief and launch/open handoff carry the first implementation owner.
- `docs/design/architecture/README.md` describes the editable visual views and
  their render/serve tasks. Producer verification is in its decision log.

## Done when

Produce findings with evidence and consequence, or explicitly find no material
issue. Challenge the design rather than implement it. In particular:

- Does provider-local process/target capture actually permit input and menu
  operations without desktop control while preserving opacity and selection?
- Does the distinction between Koine-requested native actions and an
  application's reaction satisfy the agreed effect boundary? Try menu items
  that open windows, tool commands that activate, menu cleanup, and input
  fallbacks. Do not assume unknown native behavior is already demonstrated.
- Does the static additional-capability conjunction preserve whole-operation
  preflight, live admission, read publication and control-only receipts? Are
  capability-owner absence, rejection, cycles and startup failure coherent?
- Is the framework change truly additive for old compiled providers and refused
  before loading by old hosts? Is reuse of the current framework otherwise
  preserved, with no implicit incompatible public-contract change?
- Can a standalone client distinguish missing dependency, stale target,
  successful empty result and permission refusal after a readiness/action race,
  without the result suggesting rollback of earlier effects?
- Does the cumulative trace allocate every inventory row and named effect,
  preserve client ownership and scope exclusions, and leave only API/native
  questions that the downstream charters actually own?

Check the visual document against those decisions. The producer rendered and
inspected exports, but browser automation was unavailable: verify actual
deep-link rendering, current-discussion markers, readability and mobile/dark
appearance when browser access is available. Do not misreport this limitation
as a failed native acceptance test.

## Notes

This review is deliberately before `launch-and-open-k18`: several later
increments depend on the authority and compatibility decisions. No implementation
or native workflow acceptance is claimed by the producer. Keep any findings in
this review's own artifact/commit. If integration is needed, its charter points
to this handle rather than copying the findings as a mandatory work list.

## Decisions (running log)

Reviewed the producer's commit `53ed64968d40` (`provider-architecture-k5`).
The working copy began empty on that commit, so there was no drift to
reconcile. This is a findings-only review. It made no production, test,
requirement or design edits, and ran no test, build, lint, format or VM
commands. The browser inspection served the presentation directory read-only
on its own loopback port. It is presentation evidence, not native acceptance.

The main structure holds: six provider identities with independent read/control
pairs, provider-local target capture, a static host-enforced conjunction and
typed dependency results. The findings are gaps in what that structure
authorizes and classifies. None argues for a different layout. An adjacent
`integrate-review-design` leaf is warranted before `launch-and-open-k18`. D7
lands directly on its first slice, and D1–D4 change the rules every later
increment's evidence leaves apply.

## Findings

Coordinates refer to producer commit `53ed64968d40`; the working copy is
identical to it. `spec` is `docs/specs/workflow-providers.md`, `ADR` is
`docs/adr/provider-authority-follows-effects.md` and `requirements` is
`docs/requirements/modaliser-workflows.md`. Resolve `.grove` handles for current
paths.

### D1 — Input and menus can drive Koine's own management UI (high)

`spec:57-62` lets input and menus resolve any captured process incarnation
(also `spec:23-24` and `ADR:21-27`). Nothing excludes Koine's own process, and a
client can capture it. The endpoint descriptor publishes Koine's `pid`
(`machine.md:90-96`), and its start instant is public kernel data. Koine's
windows carry the management trust root. `machine.md:638-645` says direct
interaction with the Koine UI "supplies the initial trust; an incoming request
cannot impersonate a button click". The request-review window has Approve/Deny
buttons and capability toggles (`Sources/KoineApp/RequestReviewView.swift:152-177`).
Grant creation binds Return as its default action
(`Sources/KoineApp/CreateGrantView.swift:90`). The main menu carries Quit
(`Sources/KoineApp/MainMenu.swift:13`).

Consequence: this is a confused deputy. A client holding only `input:control` or
`menus:control`, and no Accessibility consent of its own, can ask Koine to
synthesize exactly the user interaction the contract treats as its root of
trust. That is a route from a provider grant towards management authority, or
at least to quitting or rearranging Koine. It crosses the one boundary
`machine.md` says a request cannot cross. No downstream charter would find it:
`app-input-evidence-k22`, `app-input-k34`, `menu-evidence-k23` and
`menu-bar-k36` ask how delivery works, not what must be refused.

Smallest correction: make it an architecture-level provider obligation that
input, menus and any future provider that synthesizes events or invokes UI
refuse Koine's own process. Classify that refusal, and add a public-seam case:
a grant holding input and menu control cannot approve, create, revoke or quit
through Koine's UI. Decide explicitly whether other trust-bearing surfaces
(system consent and security dialogs) are a stated platform limit or a refusal.

### D2 — Space switching does not fit input's captured-target model (medium)

The allocation gives Control-digit Space switching to `input:control` as
"explicit keystroke delivery" (`spec:126`). The input row obliges input to
"deliver to the captured target without deliberately choosing a new foreground
app" (`spec:23`), and the ADR says input resolves a captured process
incarnation (`ADR:21-22`). The boundary paragraph then uses "delivered
Control-digit input may switch Spaces" as its example of an *application
reaction* that input authority covers (`spec:49-52`).

Control-digit is a system shortcut, not a keystroke to an application. The
Space switch is the requested effect, performed by the system. It
deliberately changes the foreground application and focused window. Its
natural mechanism is a session-level post with no application target. If the
shortcut is disabled or remapped, that post reaches whichever application is
frontmost. The `app-input` node requires Space switching
(`.grove/13-k10/_app-input.md:6`) in the same increment whose first completion
bullet requires input "addressed to the captured target" (`:11`).
`app-input-evidence-k22:26` asks only whether the events switch Spaces.

Consequence: `app-input-k34` must either add an untargeted system-shortcut
operation the architecture neither describes nor bounds, or break the
architecture's input obligation. Untargeted delivery is broader than targeted
delivery because the fall-through reaches an arbitrary foreground app. The
worked example also teaches every later design to file an intended system
effect as an application reaction, weakening the boundary D4 examines.

Smallest correction: allocate Space switching as its own effect. Name its
provider and authority. Decide whether `input:control` alone suffices or
desktop control is also required, since the intended effect is a
foreground/focus change. Decide whether it is a fixed operation limited to the
configured chords rather than generic untargeted delivery. State what happens
when the chord falls through to the foreground app. Replace the Control-digit
example with a genuine application reaction.

### D3 — Synthesized pointer events are not allocated (medium)

The allocation claims to cover "every Koine-requested effect, including hidden
preparation and fallback calls" (`spec:117-120`). The pointer row (`spec:127`)
covers location and nudge. The display-focus row (`spec:125`) excludes only an
"application keystroke or menu fallback". No row classifies synthesized mouse
button events.

The configured display focus uses one. Shift+letter in the active config
(`~/.config/modaliser/config.scm:187-190`) reaches `focus-display` via
`Sources/Modaliser/Scheme/lib/modaliser/display-actions.sld:122`.
`Sources/Modaliser/WindowManipulator.swift:183-236` raises and activates a
window on that display and warps the pointer. When no window is found, it
synthesizes a left click at the display centre. A right-click at a point is
also the obvious fallback for the requirements' screen-point context target,
wherever the show-menu action is unsupported. `menu-evidence-k23:34-35`
examines exactly that. `pointer-and-media-k21:11` asks this architecture
whether pointer movement and media keys "count as input". The spec answers
only by implication and does not mention button events at all.

Consequence: a click is application input. It can press controls, change
selection or activate an application, and at a racing point it lands in
whatever window is there. Without a classification, `window-layout-k31` can
place a click fallback under `desktop:control`, and `context-menus-k25` under
`menus:control`. Each would bypass the separately grantable input authority
that requirements `:74-77` protect "regardless of which public operation
exposes them".

Smallest correction: allocate synthesized pointer moves, pointer button events
and synthesized system-defined keys (media) explicitly. State whether button
events need input authority whatever operation uses them, and whether display
focus may use a click fallback at all.

### D4 — The requested-versus-reaction boundary is two rules, and acceptance cannot tell them apart (medium)

The boundary (`spec:47-55`, `ADR:38-43`) authorizes Koine's requested
primitive and its *documented semantics*, and treats application responses as
reactions. Tool actions use a different test (`spec:96-103`): "if its native
mechanism can *also* activate an app or focus a desktop window", the field
declares desktop control, as downstream evidence finds. The VM seam requires
verifying "no hidden focus/keystroke/menu fallback" (`spec:275`).

Take one effect three ways: select the next iTerm tab by keystroke
(`input:control`), by iTerm's Window-menu item (`menus:control`), or by iTerm's
scripting interface (`iterm:control`, plus `desktop:control` if it "can also"
activate). Suppose evidence shows that pressing a menu item in a background app
activates it. The menu rule calls that a reaction; the tool rule would declare
it. Separately, an application's Window menu lists its windows, and invoking an
entry focuses that window. That is window focus exposed through a public menu
operation without desktop authority. Requirements `:74-77` apply the separation
"to the effects regardless of which public operation exposes them". Classifying
only Koine-requested primitives is probably the only workable reading, and the
ADR states it. But it narrows agreed text, and nothing records Antony agreeing
to that. In a VM, a focus change looks the same whether the application
reacted or Koine activated the application itself. So the "no hidden focus"
row is not falsifiable as written.

Consequence: `iterm-evidence-k26`, `menu-evidence-k23` and `herdr-evidence-k27`
will each observe activation side effects and classify them by whichever rule
they read. The same effect will then carry different authority per provider,
and the acceptance row can pass vacuously.

Smallest correction: state one decision procedure for all providers, including
OS-performed activation caused by a primitive. For example: an effect is
Koine's when Koine selects it (a parameter, a primitive whose documented
semantics include it, or a preparation/fallback call); otherwise it is a
reaction. Name the discriminating evidence for "no hidden call", such as
targets whose reaction changes no focus plus a check that the provider calls no
activation API. Confirm the narrowed reading with Antony and record the reaction
limit beside the accepted native limits (requirements `:336-339`).

### D5 — Cleanup's authority must be settled at admission (low)

The cleanup row (`spec:137`) gives cleanup to the owner of the admitted
interaction, "not a new grant". Menu-only paths must avoid application
keystrokes (`spec:136`). Any keystroke fallback needs input authority "however
the public operation is named" (`ADR:33-36`). The requirements forbid Escape
only towards a *newly active* application (`:264-270`). Escape to the
still-foreground target is therefore a permitted cleanup mechanism whose
authority is unassigned. `menu-evidence-k23:34-35` asks how an opened menu is
dismissed.

Consequence: if some menu can be dismissed only by Escape, the design has no
rule. Either the opening field declares `input:control`, breaking menu-only
grants, or cleanup keystrokes are exempt from the boundary, and
`interaction-lifecycle-k38` would have to choose that against the
architecture's text. Cleanup runs after revocation without admission, so any
authority it relies on can only have been checked when the interaction was
admitted.

Smallest correction: state that a cleanup mechanism's authority belongs to the
static set of the operation that admits the interaction. Alternatively, state
an explicit, bounded exemption: the admitted target only, and Koine-owned
effects only.

### D6 — Native-consent classification rests on a vocabulary naming only Accessibility (medium)

`spec:224` maps missing native consent to the existing `permission` /
`os-permission`. That vocabulary names one consent with Koine as owner
(`docs/client-guide.md:231`; `machine.md:466-469`). The rule that a read never
triggers a consent dialog is stated for Accessibility only (`machine.md:63-68`).
The extension brings new consents: Automation for Apple Events, which
`iterm-evidence-k26` names, and protected-folder access for file search under
the home directory. The file-search row forbids reporting inaccessible roots as
a healthy empty result (`spec:130`), but the result model has only
available-with-list and dependency-unavailable (`spec:205-216`).

Consequences:

- The spec does not say whether new `osPermission` values, and owners, are
  additive under `koine-desktop/1`. An Automation consent is Koine's for a named
  target application. Clients written to the guide treat `os-permission` as
  "Accessibility: see Koine".
- A readiness query or search can raise a system consent prompt through a read,
  which the baseline forbids.
- A search that skipped a protected folder and found nothing looks like an empty
  successful search: the exact confusion requirements `:69-70` rule out.
- Whether an application-side switch, such as iTerm's own API enablement, is
  consent or a missing prerequisite is unassigned.

Smallest correction: state how `os-permission` extends (values, owner,
additivity). Apply the no-prompt-through-read rule to every consent. Require
search results to report coverage: which roots were searched, which were
skipped, and why. Leave the concrete consent inventory to the evidence leaves.

### D7 — Composition rules still assume one bundled provider (medium)

`machine.md:328-329` now composes "desktop first and then by identifier". That
sentence is not marked as extension. The served code orders *bundled* providers
first, then by identifier (`Sources/KoineCore/Composition.swift:111-115`).
Unedited text still says composition is core then "the bundled provider's"
(`machine.md:261-263`). Only `koine` and `desktop` are reserved
(`Composition.swift:404-413`; `machine.md:318-319`). A per-user provider claiming
an unreserved identifier contests it, and both claimants are refused
(`Composition.swift:74-93`). First-party providers "upgrade independently of the
host" through the per-user root (`machine.md:925-926`). The desktop-failure
statement still says only "the desktop path" becomes unavailable
(`machine.md:967-969`).

Consequences:

- The two ordering rules differ whenever a per-user identifier sorts before a
  new bundled one (for example `git` before `herdr`). Root field order, and so
  the digest and the exact-profile conformance comparison (`spec:247-252`),
  depend on which rule is right. The spec now contradicts 0.1.0.
- Installing a newer first-party `input` or `workspace` in the per-user root
  refuses both copies. Through the new owner cascade (`machine.md:400-406`), a
  refusal of `desktop` also removes `workspace` and any provider declaring
  desktop capabilities.
- Desktop failure now reaches every provider that declares desktop
  capabilities, not only the desktop path.

Smallest correction: restate composition for a set of bundled providers. Keep
the code's canonical order or change both deliberately. Reserve the shipped
identities and prefixes. Define precedence between a bundled and a per-user copy
of a first-party provider. Update the failure statement for the cascade.
`launch-and-open` adds the first new bundled provider and the exact conformance
profile, so this lands on its first slice.

### D8 — A capability error names one member of a conjunction (low)

`requiredCapability` is singular (`machine.md:466-469`). The engine checks the
field's own requirement, then reference owners, and reports the first failure
(`Sources/KoineCore/Engine.swift:340-343`; `Sources/KoineCore/Authority.swift:51-57,313`).
The extension adds unconditional conjunctions, such as workspace plus desktop
control, without saying which member is named or in what order. Prose field
descriptions are the only complete statement (`machine.md:384-386`).

Consequence: a client missing both learns one, obtains a new grant, then meets
the other: two human approvals for one operation. Clients cannot rely on which
member is reported.

Smallest correction: define the reported order, or add an additive list beside
it; the contract already adds extension keys this way (`reason`,
`machine.md:676-679`). Say whether a machine-readable statement of a field's
complete set is intended.

### D9 — Grant disclosure has no owner, and input/menu reach is understated (low)

`spec:147-151` and `ADR:73-78` require grant UI and descriptions to disclose the
expanded desktop authority "before the extension ships". No trace row,
increment charter or acceptance case owns that. Scope keeps "arbitrary shell
execution" out (`machine.md:1089`). Yet `input:control` towards a captured
terminal delivers arbitrary typed commands, and `menus:control` reaches any
application's menus.

Consequence: existing `desktop:control` grants widen on upgrade with no
scheduled disclosure. The scope sentence reads as a property of the system when
it is a property of the API shape. A user approving `input:control` is not told
that it can run commands as them.

Smallest correction: give the disclosure an owning increment and an acceptance
case: window-layout or pointer-and-media for desktop, and app-input and
menu-bar for their own grants. Phrase the scope exclusion as "no
shell-execution operation", and state input's reach in its grant description.

### D10 — Presentation (low)

Checked in headless Chromium (Playwright) against a separate loopback server
over `docs/design/architecture` at this commit. What works:

- All three workflow deep links land on and highlight their view.
- The current-discussion panel, its "Updated" list, the `Current`/`Updated`
  badges and the outline markers render.
- The only console error is a missing favicon.
- Dark mode applies the D2 dark theme. The PlantUML sequence stays a light,
  readable panel, as the baseline PlantUML views do.

Observations:

- The new D2 canvases are wide. The viewBoxes are 1666×1325 for authority and
  1478×1110 for providers, against 923×1203 for machine-interface. The
  unconnected Example node sits beside the authority flow. Fit-mode node text
  at 1400px is roughly half the baseline views' size: small but legible.
- At 390px, fit mode is illegible. Native size is legible but opens on blank
  padding with the start node off-screen.
- In dark mode the "Start here" node loses the dark fill the README's cue
  relies on. That is inherited; baseline D2 views behave the same.

These observations concern presentation only; they are not native acceptance.

### Checked and accepted

- **Provider-local capture.** Input and menus resolve an externally captured
  incarnation through their own input types. That fits composition version 1:
  own types, built-in scalars and `Reference` only (`machine.md:331-336`).
  Opacity holds, since no desktop reference is decoded. Menu selections bound to
  menus-owned context capture meet the context-target scenario. Delivery to a
  non-foreground target is rightly left to `app-input-evidence-k22` and
  `menu-evidence-k23`. The app-input node already requires refusal when the
  target is not in the state delivery needs. Accepted, subject to D1 and D2.
- **Static conjunction.** Requirements derive from schema metadata and coerced
  arguments, preserving the static-requirement rule (`machine.md:431-433`). The
  engine already unions own and argument-owner requirements at preflight and at
  execution (`Engine.swift:340-343,480-483`), so this extends an existing union
  rather than adding an admission point. Grants are immutable capability sets,
  so live admission is the active-grant recheck plus the static set. Owner
  removal to a fixed point is monotone and terminates. Cycles are harmless
  because they name authority, not start order. A `FAILED` owner keeps its
  contribution and capabilities published
  (`Sources/KoineCore/ProviderStatus.swift:10-12`), so dependents stay coherent.
  Nothing calls across providers at run time, so there is no "dependent action"
  for `machine.md:409-410` to govern; that sentence could simply go. Accepted,
  subject to D7 and D8.
- **Framework compatibility.** `ProviderFieldRegistration` and
  `ProviderDescriptor` are resilient structs with defaulted initializers
  (`ProviderAPI/Sources/KoineProviderAPI/ProviderDescriptor.swift`). An added
  stored property with a new initializer is therefore additive. The loader
  refuses an unknown required feature before `dlopen`
  (`Sources/KoineProviderLoader/ProviderLoader.swift:201-204`) and cross-checks
  descriptor against manifest (`:416-419`). No `koine-desktop/1` change is
  needed. Accepted; the signed two-minor pair stays open, as `machine.md`
  already records.
- **Dependency results.** These hold together with non-transactional
  multi-action operations:
  - typed available/unavailable objects;
  - stale targets as `unavailable`;
  - an empty list as success;
  - permission before disclosure;
  - a promise covering only the reporting action, with `failed` where it cannot
    be established.

  Accepted, subject to D6's partial-consent case.
- **Trace coverage.** The trace covers all 27 inventory rows plus menu bar,
  context menus, list/label state and interruption/cleanup. Clipboard, Google
  suggestions and settings reload stay client-owned. Zellij, Neovim, the VS Code
  screens, status-item and Dock menus stay excluded. Each named effect in the
  producer's charter has a row, apart from D2 and D3. The "plus effects" phrase
  is explicitly not a completed trace. The deferred questions I checked all have
  owners:
  - the workspace conjunction and feature: `launch-and-open-k18` and `-k29`;
  - lifecycle framework support: `interaction-lifecycle-k38`;
  - the host association: `herdr-k43`;
  - Automation consent and the entitlement: `iterm-evidence-k26`.
- **Spec-set shape and scope.** Two specs, with extension sections marked and
  0.1.0 evidence preserved. The Scope and server-boundary ADR reconciliation
  matches requirements `:32-40`.

### Review evidence and limits

Read directly:

- the producer's diff and running log;
- the complete requirements, workflow spec, new ADR and `machine.md`;
- the reworked ADR, glossary and client-guide diffs;
- the downstream charters cited above.

Code claims rest on direct reads of the cited Swift files in this repository and
in `/Users/antony/Development/Modaliser`, and on the active Modaliser config.
Tier-2 `check_index_coverage` at generation `2026-09-29T10:36:20Z` recorded no
issue for any cited Koine file except `Engine.swift:295` (parse-partial), a line
no claim uses. Docs are excluded from the index and were read. No claim relies
on graph absence.

No test, build or VM was run. Browser artifacts were kept outside the
repository. A pre-existing server on port 8765 was left untouched.
