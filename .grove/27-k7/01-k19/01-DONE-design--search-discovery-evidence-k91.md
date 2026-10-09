# search-discovery-evidence-k91


## Goal

Establish the bounded public discovery mechanism and its permission/index
limits before the API design. Measure in an isolated VM inside signed hardened
Koine, consuming the protected-path metadata result without inferring traversal
permission. Compare directory-name enumeration, registered-app validation and
Spotlight with its index disabled.

## Done when

`docs/verification/search-discovery.md` records exact calls, controls, consent,
signatures, raw outcomes and limits. It gives the following design leaf enough
evidence to choose the mechanism, state skipped protected scopes and classify
unknown index/handler state without new consent or entitlement.

## Decisions (running log)

- The test-only workspace startup instrumentation runs in the actual Koine
  executable and process with unchanged identity, Info.plist and entitlements.
  It is built in a copy, leaving production provider sources untouched.
- The copied provider must dereference its shared-source symlinks. The first
  copied build failed on the two desktop-source links; the copy recipe was
  corrected before measurement.
- The retained seventeen-case run is under `docs/verification/search-discovery/measurement`.
  Directory listing of the ordinary fixture and home with exclusions, and
  public app-registration inspection, were prompt-free. Direct traversal of
  all three protected roots prompted and failed after denial. A protected
  Spotlight query also prompted but returned a successful zero after denial.
- Disabled indexing still returned filenames, including a fresh disk-image
  fixture. Neither query startup/count nor the `mdutil` disabled state proves
  search availability. Recommend index-independent name enumeration with
  explicit partial/unknown coverage; let the following design own its bounds,
  race limits and schema rather than treating the probe as product code.
- No new consent, entitlement, usage key or handler substitution is approved.
  The VM attempts are experimental controls only; product reads skip protected
  traversal before native access.
- Review is declined here because the executable positive controls, retained
  native outcomes and before/after subject hashes are the distinct instrument
  for the bounded mechanism claim. A fresh read of the same prose cannot prove
  broader no-prompt or filesystem guarantees; those are explicitly not claimed.
## Notes

Parent `app-and-file-search-k19` carries the full design obligation. This child
delivers only native mechanism/permission/index evidence; `app-and-file-search-k92`
remains live to settle the API before planning. The protected default-opening and
app-reveal-notice questions remain in their existing leaves.
