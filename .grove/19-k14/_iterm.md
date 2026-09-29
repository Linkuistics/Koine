# iterm-k14 — brief

## Goal

A client lists and acts on iTerm's tabs and panes and places labels over
panes. It can discover, or explicitly set up, any prerequisite the integration
needs. iTerm is the required terminal-host baseline.

## Done when

- The iTerm row is demonstrated through public operations:
  - list and select panes and tabs;
  - directional pane focus, move and split;
  - pane zoom and copy mode;
  - create, rename and close tabs;
  - previous/next tab focus and reordering.
- The list state covers tab titles and the current tab, and pane titles with
  process and working-directory information for the untitled-pane fallback.
  The resource reference and scope keep state with the right target when
  labels are equal. Unknown is distinct from false.
- Pane screen geometry is tied to each pane reference, and an unavailable
  location is distinguishable.
- Prerequisite availability is discoverable. An explicit setup operation
  exists, or a mechanism that removes the prerequisite. A missing prerequisite
  is never a healthy empty list or a demonstrated workflow.
- Readiness never raises a consent prompt. Distinguish application-side API
  enablement from OS consent; document any new consent identifier, target and
  explicit acquisition path only after Antony approves a changed signing
  posture. Classify native effects by the shared selected-effect rule, supported
  by inspected call paths and VM outcomes, not activation observations alone.
- Allocated authority, trace rows, recorded iTerm versions, and VM acceptance
  with several windows, tabs and split panes.

## Decomposition

1. `design` evidence: the integration mechanism under Koine's signing posture.
2. `design`: the API.
3. `planning`: cut implementation leaves.

## Notes

Modaliser drives iTerm through AppleScript and Accessibility frames. It bridges
the two by walk order, and its setup writes eight iTerm key bindings. That is
evidence of the need, not a mechanism to keep. Reusing or replacing the setup
is this increment's design choice. `herdr` builds its terminal context on this
increment's session identity.
