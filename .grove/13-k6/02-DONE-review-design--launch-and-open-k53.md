# launch-and-open-k53

**Reviews:** `launch-and-open-k18`

## Goal

Adversarially review the workspace launch/open design before its API and
acceptance commitments become implementation. Produce findings, not fixes.

## Context

- The producer's commit contains `docs/specs/workspace-launch-and-open.md`,
  workspace SDL/examples, concrete workflow trace rows, visual views and the
  planning handoff. Read against the accepted requirements and both authority
  and first-party selection ADRs, not just the producer's account.
- Specific doubts: can native APIs support the stated bundle/path selection,
  default-browser routing, Finder acknowledgment and optional exact process
  identity without an unapproved consent or an overstated guarantee? Does the
  no-arbitrary-executable boundary preserve required file/editor workflows,
  including script documents, while stating application-reaction limits honestly?
- Challenge the exclusive typed result branches and pre-submission absence
  promise under filesystem/handler/process races, denial and timeout. Check
  control-only output fields, whole-mutation preflight, and the separate desktop
  handoff against the shared framework contract.
- Check that catalogue/approval identities, old/new feature refusal,
  candidate-specific staging, diagnostics, missing-owner behavior and the entire
  Machine N/G/V selection matrix survive into `launch-and-open-k29` without
  narrowing. Design SDL validation is not runtime conformance or VM evidence.

## Done when

Report actionable findings with source coordinates and consequences, or an
explicit no-findings result, following the review-design procedure. Platform
acceptance remains downstream live work; distinguish unsupported design promises
from native predictions explicitly assigned to that evidence.

## Notes

The producer scheduled this fresh-context review instead of spending an
in-session reviewer. The design and SDL pass static validation, but no new
provider is implemented and no launch/open VM acceptance is claimed.

## Decisions (running log)

Reviewed producer commit `16598f4fade8` (`launch-and-open-k18`). The working
copy began as an empty change on it, so there was no drift to reconcile.
Findings only: no spec, SDL, ADR, diagram, Taskfile or code edits, and no test,
build, render, conformance or VM command. Native claims were checked against
declarations in the installed macOS 27.0 SDK headers and against Modaliser's
source; nothing was executed.

The structure holds: four root mutations, an unconditional workspace + desktop
control conjunction, typed pre-submission dependency results, `failed` after
submission, a separate desktop read for the handoff, and a selection handoff
that carries the whole Machine matrix. No finding argues for a different
architecture. They concern one default that contradicts "launch or activate"
(S1), a payload boundary with no classifier (S2), what the receipt may reveal
and when it arrives (S3–S5), a disclosure nobody owns (S6) and a seam named at
the wrong height (S7).

An `integrate-review-design` leaf is warranted immediately before
`launch-and-open-k29`: S1–S4 change what the first implementation slice builds
and accepts. S3 or S4 may settle as a stated native limit, which goes to Antony
under the root brief; none needs a new consent, entitlement or signing change.

## Findings

Coordinates are at the producer commit; the working copy is identical. `spec`
is `docs/specs/workspace-launch-and-open.md`, `SDL` is
`docs/design/workspace-schema.graphql`, `machine.md` and `workflow-providers.md`
are under `docs/specs/`, and `requirements` is
`docs/requirements/modaliser-workflows.md`. Header citations are AppKit's
`NSWorkspace.h`, `NSApplication.h`, `NSRunningApplication.h` and
`UniformTypeIdentifiers/UTCoreTypes.h` in the installed macOS 27.0 SDK.

### S1 — Disabling running-copy substitution turns "activate" into a second instance (high)

The unconstrained form lets Launch Services choose the copy (spec:34-35), then
disables running-copy substitution for every launch (spec:43-44, 147-149;
SDL:80). The SDK defines that option: when a running instance is at a
*different* URL, YES uses it; "Set this to NO if you are letting the user select
between specific versions of an application or letting them choose a particular
installation" (`NSWorkspace.h:178`). `URLForApplicationWithBundleIdentifier`
chooses among copies by "various heuristics" (`NSWorkspace.h:113`), not by what
is running. So whenever the running copy is not the one Launch Services prefers
(`/Applications` and `~/Applications`, a cask or Setapp copy, a trashed copy), a
named launcher starts a second instance instead of activating the running app.

The requirement is "Launch or activate" (requirements:105), "whether or not the
application was running" (node brief `Done when`). Modaliser's `launch-app`,
the evidence of the intended result, calls `openApplication(at:configuration:)`
with a default configuration, so substitution is on
(`Modaliser/Sources/Modaliser/AppLibrary.swift:116-119`). The multiple-copies
acceptance row (spec:222) asserts "another copy running … No silent
substitution", so V would certify the defect. Apps not built for two instances
on one profile or database misbehave or refuse.

Smallest correction: allow substitution in the unconstrained form, which is
launch-or-activate. Keep it disabled only with `applicationPath`, the header's
"particular installation" case. The receipt then reports the running copy's
location and process. Restate the acceptance row: unconstrained activates the
running copy; constrained launches exactly the named copy. Decide deliberately
whether app search's constrained reuse wants the same. This is a design
promise, not a native prediction.

### S2 — The direct-execution boundary has no classifier, and each reading breaks one side (medium)

The default-handler form refuses "OS-classified executable scripts"
(spec:61-63; SDL:84) without saying what classifies. The obvious UTType reading
over-refuses. `public.python-script` conforms to `public.shell-script`, which
conforms to `public.script` (`UTCoreTypes.h:368-375, 413-420, 431-438`), and
`com.netscape.javascript-source` conforms to `public.executable`
(`UTCoreTypes.h:404-411`). Ordinary `.py`, `.sh`, `.applescript` and `.js` files
whose default handler is an editor would be refused. That narrows file search's
"open a selection with its default application" (requirements:107), which
`app-and-file-search` reuses from here. An executable-bit reading has the
opposite fault.

The stated principle, that path opening "never executes the path as a program"
(spec:59-60), is also not met by the refused set:

- **Alias files** (`com.apple.alias-file`, which conforms to
  `com.apple.resolvable`, `UTCoreTypes.h:112-119`) resolve to an application or
  executable, like the symlinks the spec does cover (spec:61).
- **Location documents** such as `.webloc`, `.inetloc`, `.url`
  (`com.apple.internet-location`, `UTCoreTypes.h:1241-1248`) and `.fileloc`
  redirect to any scheme or local target, bypassing `workspaceOpenURL`'s
  HTTP(S)-only rule (spec:71-73).
- **Default handlers that run their document**, such as Terminal for `.terminal`
  and `.command` files and Jar Launcher for `.jar`, remain open.
- **A racing replacement** "may … open a new occupant" (spec:56-57), which can be
  an executable classified as a document a moment earlier.

The acceptance rows test only the refusal side and one named-app script
(spec:224, 226). Nothing checks that an ordinary source file still opens in its
default editor, or how alias and location documents behave.

Smallest correction:

1. State the policy criterion: the refused classes and the signal for each
   (type, executable bit, resolved handler, alias resolution).
2. Either widen the refused set to the stated principle, or narrow the principle
   to what is refused and name the rest as handler reactions (spec:68-69
   already has the words).
3. Add acceptance on both sides: a source file opens with its default editor,
   and alias and location documents behave as stated.
4. Qualify "never" with the race.

The policy is design. Only whether the chosen classifier behaves as intended in
the VM is native evidence (node brief: "payload classification").

### S3 — Activation is requested by a process the user did not interact with (medium)

Activation is part of the native call (spec:147; SDL:80), and activation is the
named-launcher requirement (requirements:105). Koine is a resident background
process acting on another process's key event. The macOS 14 activation APIs are
cooperative. `activate` "does not guarantee that the app will be activated at
all", and the model expects the active app to yield first
(`NSApplication.h:224-244`; `NSRunningApplication.h:133-144`). The spec does not
say whether NSWorkspace's `activates` request from a process that is not active
is subject to that model. A declined activation still returns `AVAILABLE`,
because acknowledgment is not focus (spec:45-47, 93-94), so the launcher
requirement would fail silently. The stopped-and-running row (spec:221) would
observe this, but the design has no position on what happens then.

Smallest correction: name this as a bounded native question for the increment.
Observe re-activation of an already running app while another app is
frontmost, as well as cold launch. Settle the fallback in design now:

- the existing handoff: receipt `process` → `desktopApplication(process:)` →
  `desktopFocusWindow`, already under `desktop:control`;
- a client-side yield, where the client is itself active; or
- a stated limit raised with Antony.

Modaliser's success is weak evidence, since its launching process is the one
that received the key. This native prediction is currently unassigned.

### S4 — The acknowledgment can outlast the 5 s request deadline, and Gatekeeper makes that certain (medium)

`AVAILABLE` waits for the NSWorkspace completion handler (spec:93, 97-105). The
SDK says the handler "will not be invoked until the user dismisses any such UI",
and "Gatekeeper UI is not affected and will always be presented if needed"
(`NSWorkspace.h:155-157`). A first launch of a quarantined app — every freshly
installed app in the twelve-launcher VM row — therefore waits on a human. A slow
cold launch in a VM can also exceed the deadline. Machine answers at 5 s with
`data: null` and one empty-path `failed`, and leaves the resolver running
(machine.md:160-164, 172-177).

The spec treats this only as the ambiguous case (spec:128, 171-172) and says
Gatekeeper "may appear after an explicit action" (spec:160-161). In fact it
gates the acknowledgment. As a result:

- successful launches report `failed`;
- a Gatekeeper dialog left open pins a resolver indefinitely; and
- the V row cannot say whether a first launch passes.

Smallest correction: give the provider its own wait bound below the request
deadline. A pending launch then returns a path-anchored `failed` ("effects may
have begun") rather than a whole-response `data: null`, and the resolver ends.
State Gatekeeper and slow first launch as expected `failed` outcomes, and record
completion latency per app in the twelve-launcher row. Decide whether V
preparation pre-approves each app, making Gatekeeper a separate consent-row
case, or asserts the `failed` path.

### S5 — The control-only receipt reveals installed-application data allocated to `workspace:read` (medium)

`WorkspaceOpenReceipt` returns the chosen `applicationPath` and
`bundleIdentifier` under control alone (spec:97-99; SDL:44-51). For URL and
default-handler opens this is new information: which browser is the default,
and which app handles a file type. For launch, it is the installed location. The
allocation places "Installed-application search, paths and bundle identifiers"
under `workspace:read` (workflow-providers.md:198).

Machine lets a control receipt carry additional control requirements "without
exposing read-protected resource data" (machine.md:388-390). The desktop
precedent echoes only the submitted target (machine.md:271-274). The spec's
justification, "observations of this action … not general application
discovery" (spec:98-99), is an exception Machine does not grant. No requirement
or client step consumes the two fields; the desktop handoff needs only
`process`.

Smallest correction, either:

- drop both fields, as the reveal receipt already echoes only its input; or
- amend Machine explicitly (a receipt may name the application the action
  selected) and add that row to the allocation.

The contract and the design must agree before the SDL freezes.

### S6 — Nobody owns disclosure of `workspace:control`'s reach, and workspace ships first (medium)

Disclosure is assigned to window layout, pointer/media, app input and menu bar
only (workflow-providers.md:222-230, 275; root brief's first-party paragraph).
Machine requires grant disclosure to state the reach that the API exclusion
does not limit (machine.md:1524-1526). This design creates such reach. A named
app may run the document it receives (spec:62-69): a `.command` or `.sh` opened
in Terminal executes. Launch reaches any registered app, and path opening
reaches any document.

Launch-and-open is increment 1, so the first new capability users approve would
be undisclosed. The authority acceptance row (spec:228) checks no grant UI or
description.

Smallest correction: make launch-and-open own `workspace:control` disclosure:
the native create/approve views, the existing-grant view and field
descriptions. It should state that named-app opening can execute scripts and
that launch reaches any installed app. Add that check to the authority row, and
add launch-and-open to the trace's grant-disclosure row.

### S7 — The controlled-outcome seam is named at the wrong height (medium-low)

A missing web handler, missing Finder and a false Finder acknowledgment cannot
be prepared in a real VM, so the spec assigns "controlled outcomes" at N/G
(spec:223, 225). The only enabling point it names is "the existing provider
composition point" (spec:141-145). That point substitutes whole providers for
authorization and order tests (workflow-providers.md:378-381), so it replaces
the workspace mapping these cases exist to test. N is "real independently built
native provider/host binaries" (spec:214-215), which cannot also be controlled.
As written, these rows could pass on a fake that proves nothing about
workspace's classification.

Smallest correction: name the enabling point of the private native adapter
(spec:141): the workspace provider constructed with a substituted adapter in its
own tests. Assign these cases to that seam, not N/G. Keep composition-point
fakes for core and client handling of the result shape.

### S8 — The exclusive-branch invariant omits the error case (low)

The spec says "exactly one of `value` and `dependency` is non-null, selected by
status" (spec:89-92; SDL:59-77). Machine authorizes each output field and
rechecks at publication (machine.md:411-417, 476-478, 484-486). A revocation
that commits between `status` and `value.applicationPath` yields `AVAILABLE`,
null `value` and a permission error at `…/value/applicationPath`. The G row's
"exclusive result branches" (spec:227), and clients generated from these
descriptions, treat that as impossible. Qualify the invariant as "absent an
error at or below this result". State that `status` is authoritative and that a
null branch with an error is suppressed publication, not a different outcome.

### S9 — "Reliable" process identity has no matching rule (low)

`process` is returned only if "the native result's application and PID/start
observation can be matched" (spec:100-105; SDL:49), but no rule is given. One
candidate: read `PROC_PIDTBSDINFO`, then confirm the same executable path and a
non-terminated `NSRunningApplication` after the read. PID reuse cannot be
induced at N or V, so the "process exit/reuse" case (spec:227) is satisfiable
only by inspecting a stated rule. State the rule; the observation remains native
evidence.

### S10 — "Installed" and the path comparison need definitions (low)

- **Stale registrations.** Installation is Launch Services registration
  (spec:32-41, 120). A registration can persist for a trashed or deleted copy
  until re-scan, and the unconstrained form checks nothing before submission.
  It could launch a trashed app, or turn a stale registration into `failed`,
  where the node brief asks for an absent dependency, "never … success or a
  stale target". Define "installed" (not in the Trash, bundle present), check
  the resolved bundle before submission, and add a trashed copy to the
  multiple-copies row.
- **Canonical location** (spec:35-36, 53) is unspecified. String comparison is
  fragile across `/tmp` vs `/private/tmp` and Unicode normalization; compare file
  identity instead.
- **Bundle-less apps.** `bundleIdentifier: String!` is required on input
  (SDL:7-8), yet the receipt admits handlers without one (SDL:47). A search hit
  with no identifier can be neither launched nor opened, because application
  bundles are refused as path payloads. State this as a limit, or give it a
  route.

### S11 — Wording that changes outcomes (low)

- "Native acceptance" means both the OS acknowledgment (spec:93; SDL:13, 43) and
  N-seam evidence (spec:162, 214-217; node brief). Use "native acknowledgment"
  for the former throughout.
- Resolving the handler "for the URL's scheme" (spec:74) is load-bearing.
  `URLForApplicationToOpenURL` returns the app "that would be used to open the
  given URL" (`NSWorkspace.h:119`), so resolving with the actual URL could
  return the universal-link app the design avoids. Say scheme-level resolution
  explicitly.
- "Valid syntax" (spec:71) names no grammar. Foundation parsing can silently
  percent-encode invalid characters, contrary to "preserve valid … data". Name
  the grammar (for example, an RFC 3986 absolute URI, never re-encoded) and the
  handling of non-ASCII and IDN input.
- The "Established OS-consent denial" row (spec:126) has no documented
  `osPermission` identifier, which Machine requires before a consent is reported
  (machine.md:511-512). Mark the row conditional on a consent settled with
  Antony, or remove it.

### S12 — Sequence the protected-path probe early (low, planning)

`PATH_NOT_FOUND` depends on a prompt-free existence check (spec:55, 130-132,
167-171). File search's main roots are TCC-protected folders under home
(requirements:107). If metadata inspection there prompts, the design's only
branch is escalation (spec:168-171), and the path API may change. The evidence
is correctly assigned (spec:229; node brief: "protected-path prompting"). But
k29's first slice is a single-app launch, so schedule this observation before
later slices or `app-and-file-search` rely on `workspaceOpenPath`'s shape.

### Checked and accepted

- **Composition.** Prefixes are owned. There are no foreign types, references,
  unions, interfaces or input defaults. Mutation roots are nullable, and control
  fields are reachable only from mutations (machine.md:343-363). The
  unconditional, ordered static set (workspace:control, then desktop:control)
  fits preflight and dispatch admission (machine.md:380-449). Non-transactional
  input validation across several root actions follows from
  `ProviderFailure.invalidInput` being resolve-time (machine.md:869-873), and
  the spec states it (spec:135-136).
- **The pre-submission promise is sound as specified.** Classification strictly
  precedes submission, everything after submission is `failed`, there is no
  readiness cache, and missing file vs missing handler are kept apart, which the
  SDK lookup conflates (`NSWorkspace.h:119`; spec:130-133).
- **SDK support.** Explicit default-browser routing is supported:
  `requiresUniversalLinks` (`NSWorkspace.h:199`) shows default URL opening can
  dispatch universal links, while `openURLs:withApplicationAtURL:` names the
  app. Arguments, environment and Apple event are real inputs that can be left
  unset (`NSWorkspace.h:181-192`). `selectFile` activates Finder and returns a
  boolean (`NSWorkspace.h:48-50`), which justifies desktop:control for reveal.
- **Desktop handoff.** It is a separate request under `desktop:read`, with no
  Desktop SDL import and identical identity semantics. The edit at
  machine.md:234-238 is accurate. The server-boundary ADR already admits
  launch/open/reveal (`docs/adr/koine-server-and-native-providers.md:43-48`).
- **Selection handoff.** spec:184-210, the node brief and k29:36-78 carry the
  whole Machine matrix by reference ("every row", "complete Machine selection
  matrix"). They also carry catalogue values, reserved-only slots, host-derived
  and per-user approval, feature declarations, disjoint native names, the
  missing-owner cascade, exact-candidate profiles pinned apart from digests,
  and old/new binaries. k29's illustrative list omits the trust-refusal,
  ordinary manifest-collision and host-team rows, but its "every row"
  instruction governs, so this is not a narrowing. Design SDL validation is
  labelled static (spec:17; k18 evidence; k29:77-78).
- **ADR set.** No new record passes the AND test. The consequential
  alternatives (bundle identity vs references, four operations vs a generic
  open) are recorded in the spec. Revisit only if S3 or S4 settles as a
  surprising, hard-to-reverse limit agreed with Antony.
- **Trace and views.** Trace rows name exact coordinates and both capabilities.
  Diagrams and captions agree with the spec.

### Review evidence and limits

Read:

- the producer diff;
- the spec, SDL and examples;
- the cited sections of `machine.md` and `workflow-providers.md`;
- both binding ADRs and the server-boundary ADR;
- the requirements and the glossary;
- k18 and k29;
- Modaliser's `AppLibrary.swift`;
- the SDK headers above.

Not run: tests, builds, renders, `task design:workspace-check`, conformance or
any VM.

Not observed; each is a prediction for its seam:

- cooperative-activation behaviour for NSWorkspace opens (S3);
- completion timing and Gatekeeper blocking (S4);
- Launch Services registration of trashed copies (S10);
- TCC behaviour of metadata checks in protected folders (S12).
