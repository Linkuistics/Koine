# Prompt risk remains distinct from missing consent

Koine's native discovery reads must avoid OS consent prompts. Declining an
inspection because it can prompt reports a policy block with unknown consent;
it does not establish that named consent is missing. Native catalogue/location
results must distinguish that block from a healthy empty observation and from
unavailable or incomplete discovery. The
[native design](../specs/workspace-search.md#coverage-and-frozen-publication) defines exact fields, reason
precedence and client guidance within the
[current ownership boundary](raw-filesystem-search-belongs-to-clients.md).

Observed missing named consent retains the framework's permission/os-permission
meaning in the [Machine contract](../specs/machine.md#errors-and-partial-data).
Reinterpreting an osPermission failure with nil or blank consent is rejected:
public construction permits those legacy values, and they cannot acquire new
meaning without changing existing provider behavior. Authorization, lifecycle
and publication errors remain independently observable.

The previous raw-search proposal represented prompt risk as typed BLOCKED data
with null matches and per-root coverage through ordinary ProviderValue objects.
Its exact payload is comparison input, not an adopted native catalogue schema
or a reason to add diagnostic ABI. A generic structured failure would impose
permanent validation, malformed-provider diagnostics and pre-load compatibility
requirements. Reconsider that cost only when the selected native operations
need a shared failure that their typed results cannot adequately express.

Native typed diagnostics preserve this distinction without a new failure ABI.
The [settings decision](settings-discovery-uses-app-supplied-objects.md) permits
conditional explicit setup independently of ordinary no-prompt reads.

This distinction prevents clients from treating a policy refusal as either
permission absence or an empty inventory. The diagnostic representation itself adds no consent, entitlement, setup
operation or automatic retry. Existing
[authority](provider-authority-follows-effects.md), action errors and
[first-party selection](first-party-provider-selection.md) requirements bind.
