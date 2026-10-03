# Prompt risk is search data

Workspace search represents a wholly prompt-risk-blocked read as typed BLOCKED
data, with null matches and dependency and explicit per-root coverage. Its
permission diagnostic reports UNKNOWN consent: Koine declined an inspection
known to be capable of prompting; it did not observe missing consent. The
[search contract](../specs/workspace-search.md#extension-only-permission-diagnostics)
owns the branch invariants and client guidance. Observed missing named consent
retains the framework's permission-error meaning, as specified by the
[Machine contract](../specs/machine.md#errors-and-partial-data).

This makes prompt policy inspectable even in a coverage-only query and preserves
all causes in a mixed-root result. It also makes BLOCKED an enduring schema
obligation: clients must inspect status, coverage and publication errors rather
than relying on GraphQL errors alone. Ordinary ProviderValue objects/nulls carry
it through the [resilient framework](resilient-provider-framework.md), with no
new symbols, framework minor or host feature. Existing
[authority](provider-authority-follows-effects.md), action errors and
[first-party selection](first-party-provider-selection.md) requirements remain binding.

A new compatible structured prompt-risk failure would give generic error-only
clients a notification when they select matches, but would require permanent
kind/consent/target/reason validation, malformed-provider diagnostics and
pre-load feature/version refusal. It would still need typed coverage and status
for unselected matches and partial successful roots. That cost buys no additional
information for the present search consumers. Reconsider it when independent
provider operations need a shared prompt-risk execution failure that their typed
results cannot adequately express. Reusing osPermission with nil or blank
consent is rejected outright: its fixed meaning is missing named consent, and
public construction already permits those legacy values. They cannot acquire
new meaning without changing existing provider behavior.
