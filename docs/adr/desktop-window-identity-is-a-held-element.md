# desktop-window-identity-is-a-held-element

## Decision

The desktop provider identifies a window by the accessibility element itself,
which it holds as private observation state for as long as it runs. A window
reference is `koine://desktop/window/<pid>/<start µs>/<session>/<token>`: the
process incarnation, the provider run that holds the element, and the element's
number in that run. A listed element is recognised as one already held with
`CFEqual`, so a window keeps its reference for the life of the provider. Only an
element that its own content names as its window is ever held. Title, bounds and
order are never part of the identity and are never matched. A held element that
its application does not currently enumerate, as on another Space, is what the provider
lists as `REMEMBERED`, under the same reference; there is no second record of
windows.

The process component is the served `{ pid, startedAt }` identity fixed by the
[capture decision](desktop-capture-preserves-the-process-incarnation.md).
An [actual PID-recycling experiment](../verification/retained-ax-binding.md)
shows that a retained AX window can address a replacement process, even with
the original task-name right and AX parent still held, so this scheme does not
establish cross-incarnation no-substitution. The
[public Accessibility decision](desktop-automation-uses-public-accessibility.md)
accepts that race. Local withdrawal is permanent and identifiers are never
reused; a platform closure report is not authenticated proof of closure.

## Trade-off

Only public API is used. Within-process and ordinary-restart tests observed
exact targeting: same titles, retitling,
minimising, another Space, closure with a look-alike replacement, and restart
([evidence](../verification/desktop-window-identity.md)). The price is that no
window reference survives a restart of Koine; clients list again. The guarantee
also rests on an assumption public API cannot prove for every application: the
identity an application gives a window's element is bound to that window for the
life of its process and is not issued again. Those observations do not cover
the cross-incarnation counterexample above.

## Rejected alternatives

**The window number from `_AXUIElementGetWindow`.** It agreed with the held
element in every case and would survive a restart of Koine, and Modaliser uses
it. It is private API, which a signed product holding the user's Accessibility
consent should not rest on, and the contract names it as no proof of identity.

**`CGWindowListCopyWindowInfo`.** Public, but there is no public route from a
window number to the element that must be raised, names need Screen Recording
consent, and bounds are not unique.

**Title, or the `AXIdentifier` attribute.** Neither is unique among an
application's windows.
