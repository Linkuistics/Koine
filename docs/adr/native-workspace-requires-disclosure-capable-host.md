# Native workspace requires a disclosure-capable host

Native workspace providers require `workspace-native-disclosures-v1`, alongside
`additional-capabilities-v1` and `first-party-selection-v1`. A host advertises the
feature only when its native grant creation, approval and existing-grant views
and management disclosure catalogue state the native surface's actual reach:
workspace read supplies location/app/settings metadata, including fixed application
information/name files and direct localization names, without client filesystem
access; workspace control permits background Settings preparation alone;
launch/open/Finder reveal and selected Settings reveal additionally need desktop
control. Conditional OS consent remains exclusive to Koine's local explaining UI.

Core owns those disclosures. Prior selection-aware hosts can load the new images
but ship the action-only wording that workspace control always requires desktop
control and omit workspace read. Requiring a host feature makes that mismatch a
pre-load `INCOMPATIBLE` / `unsupported-feature` refusal, including a per-user native
update; the retained action-only bundled provider remains selected with visible
refusals. This costs compatibility with those prior hosts and requires a corrected
host release before native providers ship. Loading there would under-disclose the
new grant reach. Provider-owned replacement text cannot correct those core UI and
management surfaces.

The [spec](../specs/workspace-search.md#compatibility-and-acceptance) and
[finite acceptance profiles](../verification/native-discovery-acceptance.md#exact-identities-and-posture)
pin that boundary. The feature is independent of conditional Automation signing
posture. Design validation establishes no shipped disclosure or native loader pass.
