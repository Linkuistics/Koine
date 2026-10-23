# Native workspace requires a disclosure-capable host

A native workspace provider requires `workspace-native-disclosures-v1`, alongside `additional-capabilities-v1` and `first-party-selection-v1`.

A host advertises the feature only when three surfaces state the actual reach of the native surface. The surfaces are its native grant creation views, its approval and existing-grant views, and its management disclosure catalogue. Workspace read supplies location, application and settings metadata, including fixed application information and name files and direct localisation names, without client filesystem access. Workspace control permits background Settings preparation alone. Launch, open, Finder reveal and selected Settings reveal additionally need desktop control. Conditional OS consent remains exclusive to the local explaining UI of Koine.

Core owns those disclosures. Earlier selection-aware hosts can load the new images, but they ship the action-only wording. That wording says that workspace control always requires desktop control, and it omits workspace read. A required host feature turns that mismatch into a refusal before load. The refusal is `INCOMPATIBLE` with reason `unsupported-feature`. The refusal applies to a per-user native update too. The retained action-only bundled provider stays selected, with visible refusals.

This costs compatibility with those earlier hosts. A host release with the disclosures must ship before native providers do. Loading on an earlier host would under-disclose the new grant reach. Replacement text from a provider cannot correct those core UI and management surfaces.

The [spec](../specs/workspace-search.md#compatibility-and-acceptance) and the [finite acceptance profiles](../verification/native-discovery-acceptance.md#exact-identities-and-posture) pin that boundary. The feature is independent of the conditional Automation signing posture. Design validation establishes no shipped disclosure and no native loader pass.
