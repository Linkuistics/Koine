# desktop-window-identity-is-a-held-element

## Decision

The desktop provider identifies a window by the accessibility element itself.
The provider holds that element as private observation state for as long as
it runs. A window reference is
`koine://desktop/window/<pid>/<start µs>/<session>/<token>`. It names the
process incarnation, the provider run that holds the element, and the number
of the element in that run. The provider compares a listed element with the
held elements by `CFEqual`. So a window keeps its reference for the life of
the provider.

The provider holds only an element that its own content names as its window.
Title, bounds and order are never part of the identity, and the provider never
matches them. An application may not enumerate a held element now, as happens
for a window on another Space. The provider lists that element as
`REMEMBERED`, under the same reference. There is no second record of windows.

The process component is the served `{ pid, startedAt }` identity. The
[capture decision](desktop-capture-preserves-the-process-incarnation.md) fixes
it. An [actual PID-recycling experiment](../verification/retained-ax-binding.md)
shows that a retained AX window can address a replacement process. That
happens even while the provider holds the original task-name right and AX
parent. So this scheme does not establish that Koine never substitutes across
incarnations.

The
[public Accessibility decision](desktop-automation-uses-public-accessibility.md)
accepts that race. Local withdrawal is permanent, and identifiers are never
reused. A platform closure report is not authenticated proof of closure.

## Trade-off

The scheme uses only public API. Tests within one process and across an
ordinary restart observed exact targeting. They covered equal titles,
retitling, minimising, another Space, closure with a look-alike replacement,
and restart ([evidence](../verification/desktop-window-identity.md)). The price
is that no window reference survives a restart of Koine, so clients list again.

The guarantee also rests on an assumption that public API cannot prove for
every application. The assumption is that the identity an application gives
the element of a window stays bound to that window for the life of its
process. It also assumes that the application does not issue that identity
again. Those observations do not cover the cross-incarnation counterexample
above.

## Rejected alternatives

**The window number from `_AXUIElementGetWindow`.** It agreed with the held
element in every case, it would survive a restart of Koine, and Modaliser uses
it. But it is private API. A signed product that holds the user's
Accessibility consent should not rest on it. The contract names it as no proof
of identity.

**`CGWindowListCopyWindowInfo`.** It is public. But no public route leads from
a window number to the element that Koine must raise. Names need Screen
Recording consent, and bounds are not unique.

**Title, or the `AXIdentifier` attribute.** Neither is unique among the windows
of an application.
