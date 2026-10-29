# Settings ordering: application implementation

The shared Settings show operation now prepares its retained window and requested
section, requests activation once, then requests key/front window placement.
This implements the [reviewed design](ORDERING-REVIEW.md) in
[AppDelegate](../../../Sources/KoineApp/AppDelegate.swift). Compilation and nine
existing headless controls pass. Native repair acceptance remains unresolved.

## Source and public-contract boundary

The implementation moves the existing activation block ahead of the existing
window-ordering block after navigation, keeping each trace boundary with its
call. The readiness guard, one retained window, non-release-on-close lifetime,
size, Space behavior and launch/reopen/menu/status-line callers retain their
existing code. The separate fatal-alert activation path is unchanged.

No conditional second request, suspension, deferral, yield, focus wait, public
interface or new diagnostic instrument is added. This is application invocation
order; it does not establish native completion or guarantee focus.
Both calls are cited at the decision site.

Apple's [activation contract](https://developer.apple.com/documentation/appkit/nsapplication/activate%28%29)
allows the system to decline the request. Its
[window contract](https://developer.apple.com/documentation/appkit/nswindow/makekeyandorderfront%28_%3A%29)
describes key/front placement within the window's level. Neither retrieved
contract prescribes their relative order. The macOS 27 SDK also warns against
assuming immediate activation. The package requires macOS 26 and Swift tools
6.2; the checked compiler is Apple Swift 6.4. The
[retrieval receipt](ordering-application-evidence/apple-contracts.json) records
response hashes and the installed SDK header digest, without retaining full
copyrighted responses.

The [accepted product seam](../../specs/settings-activation-discrimination.md#alternatives-ownership-and-reversal-condition)
has historical real VM failures and no established deterministic local native
RED test. No fake OS response or source-order test is added: either would encode
the hypothesis rather than demonstrate repaired focus. Existing helper tests
below establish their own limited properties only.

## Verification

| Command | Result | Scope |
|---|---|---|
| `mise exec -- task build` | Exit 0; [full output](ordering-application-evidence/build.txt) | Compiles the application and stages the debug provider framework; does not launch AppKit |
| `mise exec -- task check:settings-activation-interval` | Exit 0; nine tests pass; [full output](ordering-application-evidence/headless-tests.txt) | Existing interval and buffer controls, including one operation and no tick reads when measurement is disabled |

The [before inventory](ordering-application-evidence/inputs-before.json) and
[after inventory](ordering-application-evidence/inputs-after.json) compare each
selected local source, test, package manifest/resolution, Taskfile and staging
script byte hash across those checks. Every listed item matches. These are
bounded local-input checks, not the protocol's full build/signing/environment/
golden freeze; dependency checkouts, build caches and the complete SDK are outside
these inventories. The [verification receipt](ordering-application-evidence/verification.json)
records statuses and interpretation limits.

The [documentation check output](ordering-application-evidence/doc-links.txt)
retains Task exit 201 / checker exit 1 for the two previously recorded missing
links in the unchanged archived context charter. No new link error is reported;
the byte-preserving archive repair remains separate work.

Bounded direct source reads cover the delegate, menu callbacks, entry point,
trace/probe disabled branches and interval implementation. With both diagnostic
paths absent, trace initialization returns before observer installation, record
returns without output, and the interval wrapper executes once without sampling
ticks. The menu probe has no directory and returns before creating its timer or
monitor. Existing disabled calls remain in the executable; this supplies no
timing-neutrality claim.

CBM startup refused before project, generation or coverage discovery with the
pre-coordination/unverified-generation error. No CBM session was stopped and
no graph completeness is claimed. No extra implementation review is commissioned
for this local reordering: the whole design and caller effects already received
independent review, and this child adds no further policy or mechanism.

## Remaining evidence and acceptance

No new signed application bundle, evaluation freeze or guest is produced here.
E01/E02 and A01/A02/A03 are all NOT RUN. The reviewed shared transport/setup/
title/liveness repairs and finite caller remain required before freeze, together
with every earned implementation review and integration. Required restart
submission must still be clean; a disconnect cannot be rehabilitated by a later
boot. Demonstrably unavailable completion holds E01 for an explicit decision.

The [finite protocol](ORDERING-EVALUATION-PLAN.md) and
[complete original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
remain binding. Historical failures, classifications, bundles, false clock joins,
closed caps and NOT RUN phases retain their meaning. The six causal slots stay
held. Native cause and ownership remain unresolved. No product or causal
ancestor closes; no release, notarization or upstream report follows.
