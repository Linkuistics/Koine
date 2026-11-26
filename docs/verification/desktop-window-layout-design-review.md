# Window layout design review

**Review:** window-layout-k8

## Findings

The review inspected producer commit `58e27688b4ad4edaf6cac8013c37763053980e4b`.
These findings concern the design, which is not yet served.

### F1 — P1: the button check precedes a potentially long focus wait

**Location:** `docs/specs/machine.md:1056` and `:1067`, and
`docs/design/desktop-window-layout-schema.graphql:132`.

The operation checks for held pointer buttons first, then lists windows and
focuses one, then moves the pointer. The existing focus operation can wait for
three seconds (`Providers/DesktopProvider/Sources/DesktopProvider.swift:395`
and `:413`).

Consider a user pressing and holding a button during that wait. Focus succeeds,
and the specified next step moves the pointer without another button check.
The design itself classifies movement with a held button as a drag. This lets
a desktop-only operation request an effect that needs input control.

This breaks the authority boundary in
`docs/specs/workflow-providers.md:197` and `:198`. It also makes a late refusal
impossible to express accurately. `POINTER_BUTTON_HELD` promises that Koine did
nothing, although it may already have raised and focused a window.

**Necessary correction:** Require another button check immediately before
pointer movement. Define the partial-effect result when focus already occurred.
State any remaining check-to-move race explicitly, without promising atomicity.

### F2 — P2: the display contract has no outcome for unknown geometry

**Location:** `docs/design/desktop-window-layout-schema.graphql:107` and
`docs/specs/machine.md:1013` and `:1091`.

The display fields `frame`, `visibleFrame` and `primary` are non-null. Their
rectangle components are non-null too. The failure table requires an unknown
value without an error whenever Koine cannot establish a read value. Its
referenced window table defines no unknown form for these display fields.

Consider a display reconfiguration between enumerating active identifiers and
associating an identifier with an `NSScreen`. Koine may lack the corresponding
visible frame or a consistent primary-display basis for conversion. Apple
documents that screens can change at any time in
[NSScreen.screens](https://developer.apple.com/documentation/appkit/nsscreen/screens).
This is a possible failure scenario, not an observed run in this review.

The implementation cannot represent that uncertainty under the specified
success shape. Inventing a rectangle breaks the geometry requirement. Omitting
a still-active display breaks the complete display-list requirement. Raising
an error conflicts with the stated unknown-without-error rule.

**Necessary correction:** Define unknown display values and enumeration failure
separately. Reconcile the schema, conversion preconditions and failure table.
Do not borrow Modaliser's zero identifier fallback as a known identity.

This concerns the producer's explicit requirement that every unestablished value
has an unknown form, and the root brief's display-list requirement.

### F3 — P2: point containment uses two different rectangles

**Location:** `docs/specs/machine.md:979` and `:1004`, and
`docs/design/desktop-window-layout-schema.graphql:95`.

The link permits the window-server bounds to differ from the known window
frame by two points. The point algorithm tests the window-server bounds.
The GraphQL description instead defines `ON_TOP` using the window frame,
which the glossary defines as the Accessibility frame.

For example, let the frame be `(100, 100, 200, 200)` and the linked bounds be
`(101, 100, 200, 200)`. The link passes. With no covering entry, the point
`(100.5, 150)` is inside the frame but outside the linked bounds. The algorithm
returns `NOT_ON_TOP`, although the exposed frame-based definition requires
`ON_TOP`. The opposite edge can produce the converse disagreement.

This breaks the point-query contract and the requirement that unknown state
remain distinct from a known false value. It is independent of equal-window
ambiguity and requires no failed native call.

**Necessary correction:** Choose the rectangle that defines target containment.
Use that definition consistently, or return `UNKNOWN` where the permitted
disagreement prevents the promised answer. Keep the link tolerance separate
from the point-query guarantee.

### F4 — P2: the identity ADR excludes a dependency that display focus requires

**Location:** `docs/adr/desktop-window-identity-is-a-held-element.md:23` and
`:55`, and `docs/specs/machine.md:988` and `:1064`.

The ADR says that a link never chooses an action target. It also says that a
wrong link never costs a target. Display focus instead selects its window by
the order obtained through those links.

Consider two listed windows on one display. A wrong successful link can rank
the rear window first. Display focus then selects and raises that window,
although both references still address their correct held elements. Holding
the element preserves reference identity but does not correct the selection.

The design therefore requires an implementer to contradict one of its binding
statements. The ADR also understates the consequence of a wrong successful
link. This matters to the agreed requirement to focus the front listed window.

**Necessary correction:** Distinguish native target identity from selecting a
held window by order. Record the action's actual dependency and its failure
policy in the existing ADR and contract. Reconcile their repeated claims.
No additional ADR is needed for this clarification.

## Inspection and limits

The review used direct source and contract inspection. It ran no tests, builds,
linters, formatters or GUI operations, as the review procedure requires.
It changed no production code, test code or design artifact.

The graph indexer and coverage command both refused to start. Each reported
an active pre-coordination or unverified CBM generation. No graph generation
or clean coverage result was available. Source claims above rely on the cited
file ranges, not an exhaustive graph result.

The existing plain-value logic seam and real-bundle GraphQL seam remain
appropriate. Client ownership of layouts and restore history is explicit.
The held-element table still owns window identity. The unresolved interface
and effect obligations are F1–F4.

The recorded layer-0 strips do not support a cover finding. For example,
`docs/verification/desktop-window-identity/run2-0-finder.json:119` marks such
entries off screen. The proposed on-screen-only list excludes them.

The primary-height conversion agrees with Modaliser's formula, including
negative coordinates above the primary display. This inspection establishes
no native two-display acceptance. The root brief explicitly leaves that check
for its release issue.

The disclosure draft covers new and existing grants. The host-feature refusal
agrees with the loader's pre-load feature check. The producer already assigns
the fixture/profile reconciliation to `window-geometry-k3`. This review makes
no compatibility-pass claim for the future provider.
