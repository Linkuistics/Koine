# reveal-app-bundle-notice-k90

## Goal

Settle with Antony whether `workspaceRevealPath` may raise a system notice that names Koine when it
reveals a third-party application bundle, or whether Koine must avoid or accept it some other way. In
the acceptance image revealing `/Applications/Zed.app` made macOS post **"Privacy & Security: “Koine”
was prevented from modifying apps on your Mac."** The reveal itself worked (Finder showed `Zed.app`
selected and Zed was not launched). Koine requested nothing, added no entitlement and no consent, and
the notice is not a dialog. It is still a user-visible system message that names Koine, raised by an
explicit, authorized request, and the spec says a posture question is Antony's.

## Context

- `docs/verification/reveal-path-vm.md`, "The App Management notice": what was seen, the bounded probe
  (`task reveal-path:probe-notification`) and what it cannot say. In this image, one sample each: a
  refused `workspaceOpenPath` of Zed.app (inspection only), and reveals of Notes.app and TextEdit.app
  (system applications), raised nothing; a reveal of Zed.app raised the notice. A throwaway tool that called
  the same `NSWorkspace.selectFile` on Zed.app and raised nothing. Not known: which operation the system
  refused, whether another third-party application behaves the same, and whether a notarized and
  quarantined Koine does.
- `docs/specs/workspace-launch-and-open.md`, the Consent and prompts row ("No new consent/signing posture
  is implied"; "If the native mechanism needs a new consent ... settle its identifier, target and setup with
  Antony before shipping"), and the native-design paragraph (reveal is `selectFile(_:inFileViewerRootedAtPath:)`
  with no AX, Automation, shell or menu fallback). `docs/client-guide.md`, "Revealing a path in Finder"
  item 9 tells a client this today.
- The brief: a change to Koine's signing posture needs a decision recorded and raised with Antony; adding an
  entitlement or a new consent is such a change.

## Done when

- Antony chooses, and the choice is recorded where the spec and the guide can cite it:
  - **accept and disclose** (the recommendation): the reveal works, nothing is requested, and the notice is
    the system saying it declined something Koine never needed. The spec's Consent row, the client guide and
    the workspace grant disclosure (`workspace-disclosure`) say that revealing a third-party application can
    make macOS show it; or
  - **find the cause first**, as a bounded `impl` leaf with its own VM evidence (one named question: which
    operation the system refused, by the system's own log for that process), then decide again; or
  - **avoid it** for application bundles by a different, separately designed route (for example selecting the
    bundle's containing folder), which changes the contract's "select the item" meaning and needs its own
    design and V acceptance; or
  - **reject** revealing an application bundle through this operation (the contract currently reveals it).
- Whatever is chosen, the Finder reveal row and the Consent and prompts row cite the decision, and
  `baseline-acceptance` does not wait on it unless the choice is to change the mechanism.

## Notes

Cut by `reveal-path-k77` rather than left as prose in the documents, as `protected-default-open-k89` was:
the launch-and-open brief allows only certificate-dependent cases to remain pending when its node closes,
and this is a posture question only Antony can settle. It sits before `baseline-acceptance` so the answer
exists before the baseline is declared. The reveal row is accepted at V without it, because the observation
(Finder showed the item selected) passed and the notice is a side effect, not a failure to reveal.
