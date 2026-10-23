# Native workspace requires a disclosure-capable host

A native workspace provider requires the host feature `workspace-native-disclosures-v1`. A host advertises the feature only when three surfaces state the actual reach of the native surface. The surfaces are its native grant creation views, its approval and existing-grant views, and its management disclosure catalogue.

## What the feature states in Koine 0.4.0

Koine 0.4.0 advertises the feature and the workspace provider requires it, together with `additional-capabilities-v1`. A per-user update also states `first-party-selection-v1`, as every first-party update does. The disclosure catalogue states two reaches:

- Workspace read returns the special locations that macOS names for the account of Koine. It also lists the applications that Spotlight has indexed on the local disks, with each name, bundle identifier and location. It reads no file contents and lists no folder. A returned location gives no access to it.
- Workspace control launches, opens and reveals. Each of these actions also needs desktop control.

The feature version states this reach and no wider one. A later cut that widens the reach needs a new feature version. Planned widenings are further application metadata, System Settings metadata, background Settings preparation, and selected Settings reveal. The [search spec](../specs/workspace-search.md#compatibility-and-acceptance) holds that plan. Conditional OS consent remains exclusive to the local explaining UI of Koine.

## Why the host must state it

Core owns those disclosures. Earlier selection-aware hosts can load the new images, but they ship the action-only wording, which omits workspace read. A required host feature turns that mismatch into a refusal before load. The refusal is `INCOMPATIBLE` with reason `unsupported-feature`. The refusal applies to a per-user native update too. The retained action-only bundled provider stays selected, with visible refusals.

This costs compatibility with those earlier hosts. Koine 0.4.0 is the first host release with the disclosures, so Koine 0.3.0 refuses the provider before it loads. Loading on an earlier host would under-disclose the new grant reach. Replacement text from a provider cannot change those core UI and management surfaces.

The [finite acceptance profiles](../verification/native-discovery-acceptance.md#exact-identities-and-posture) pin the boundary of the full design. The feature is independent of the conditional Automation signing posture. The G tests establish the served disclosure and the refusal on a host without the feature. The N and V runs of the discovery acceptance leaf establish the signed pair.
