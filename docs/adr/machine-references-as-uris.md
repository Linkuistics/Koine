# machine-references-as-uris

## Decision

A Machine reference is a URI string, `koine://<provider>/<provider-owned
remainder>`. The engine reads only the authority to route; the provider alone
produces and interprets the remainder, re-resolving it on every use and
retaining no queried state for callers. A provider's root is a reference with
an empty remainder, so every target of a query or command is a reference.
Opacity is a contract, not a property of the shape; callers pass the value
unchanged. Its GraphQL representation and client bindings remain design
work. The scheme follows the project's name, Koine.

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

The reference contract applies to the native provider and GraphQL design;
it does not require the inherited generic query/execute wire payload.
