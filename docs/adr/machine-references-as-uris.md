# machine-references-as-uris

## Decision

A Machine reference is a URI string, `machine://<provider>/<provider-owned
remainder>`. The engine reads only the authority to route; the provider alone
produces and interprets the remainder, re-resolving it on every use and
retaining no queried state for callers. A provider's root is a reference with
an empty remainder, so every target of a query or command is a reference.
Opacity is a contract backed by a branded TypeScript string, not a property
of the shape. The scheme name follows the Machine project's eventual name.

## Trade-off

One plain value serves inputs, effects, page attributes, logs and a server's
addresses, with nothing for code to build or compare, and a provider restart
is survived by any stable remainder scheme. The price is that a URI is easy
to parse, so opacity rests on the type and the rule; providers must
percent-encode; and identity across providers stays open.

## Rejected alternatives

**A compound `{ provider, key }` object.** The same information as a shape
code had to construct and compare field by field.

**A handle table in the engine mapping opaque tokens to live objects.** State
the engine would have to keep in step with a graph it does not observe, and
which no process restart survives.

**A structured JSON key.** Invites callers to read it.

Recorded by plugin-packages-k6; the behavioural contract around it is in
`docs/specs/machine.md`.

Carried from ModalAnyware (`docs/adr/machine-references-as-uris.md` at commit d666016, plugin-packages-k6) when this project was created on 2026-09-18. The text is unchanged apart from links, which now point back into `../ModalAnyware` wherever the target was not carried.
