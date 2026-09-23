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
its application does not enumerate now, as on another Space, is what the provider
lists as `REMEMBERED`, under the same reference; there is no second record of
windows.

The process component shown above is the currently served timestamp form,
which must change before first release. The
[capture decision](desktop-capture-preserves-the-process-incarnation.md) fixes
client-local capture and strict OS-process lifetime; its replacement encoding
is not yet agreed. Held-window evidence below does not establish cross-process
binding for a native action endpoint. A subsequent
[actual PID-recycling experiment](../verification/retained-ax-binding.md)
shows that a retained AX window can address a replacement process, even with
the original task-name right and AX parent still held. The current scheme
therefore does not establish cross-incarnation no-substitution. The agreed
future [public Accessibility contract](desktop-automation-uses-public-accessibility.md)
accepts wrong-target reads and effects during process or window reuse, stale
notifications and mistaken withdrawal of live references. Held wrappers remain
private observation state, not proof of an unchanged native destination.
Local withdrawal is permanent and identifiers are never reused; a platform
closure report is not authenticated proof of closure. The replacement process
identity, reference grammar and restart rules still need agreement before
release. The ordinary closure evidence below describes the served scheme and
does not prove the replacement's capture/transfer or lifetime handling.

## Trade-off

Only public API is used. The earlier within-process and ordinary-restart tests
observed exact targeting: same titles, retitling,
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
