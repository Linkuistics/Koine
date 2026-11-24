# Settings ordering: application implementation

On 2026-10-29, k52 changed the shared Settings show operation. The operation
prepared its retained window and requested section. It then requested activation
once, and then key and front window placement. This implemented the
[reviewed design](ORDERING-REVIEW.md) in [AppDelegate](../../../Sources/KoineApp/AppDelegate.swift).
Compilation and nine existing headless controls passed. Native repair acceptance
stays unresolved.

On 2026-11-25, `settings-released-call-order-k184` returned the operation to the
order that 0.4.0 released. The [return section](#return-to-the-released-order)
below holds that change and its checks. The sections after it record the k52
candidate as it was implemented.

## Return to the released order

`showSettingsWindow` now makes one key and front request, and then one activation
request. Each trace record stays beside its call. The source file differs from
the parent of the k52 commit `561dbf6c` only by a new comment. That comment names
the released order and points to [issue #15](https://github.com/Linkuistics/Koine/issues/15)
and to the [spec](../../specs/settings-activation-discrimination.md#current-decision).
The doc comment of the operation is the released text again.

Antony closed the repair as unresolved after the E01 setup stop. The decision
task `settings-ordering-next-decision-k183` then chose the released order. The
spec requires complete ordinary acceptance for the candidate, and the candidate
has none. The candidate stays in commit `561dbf6c` and in issue #15. The dormant
diagnostics stay. The trace and the menu probe stay off unless their defaults keys
are set.

| Command | Result | Scope |
|---|---|---|
| `mise exec -- task build` | Exit 0. [Full output](ordering-application-evidence/returned-build.txt) | Compiles the returned application and stages the debug provider framework. It does not launch AppKit |
| `mise exec -- task check:settings-activation-interval` | Exit 0. Nine tests pass. [Full output](ordering-application-evidence/returned-headless-tests.txt) | The existing interval and buffer controls |

The [input digests before](ordering-application-evidence/returned-inputs-before.sha256)
and the [input digests after](ordering-application-evidence/returned-inputs-after.sha256)
match. They cover the delegate source, the package manifest and resolution, the
Taskfile and the staging script. The build output shows two compiler warnings in
other files, and this change does not touch them.

These checks cannot observe focus. They prove that the returned source compiles
and that the existing helper controls still pass. They do not show that a Settings
selection returns one front, focused window. No guest ran, and no signed subject
was built. The release check keeps the strict front read until issue #15 changes it.

## Source and public-contract boundary

The implementation moves the existing activation block ahead of the existing
window-ordering block after navigation. Each trace boundary stays with its call.
The readiness guard, the one retained window and the non-release-on-close lifetime
keep their existing code. The size, the Space behaviour and the launch, reopen,
menu and status-line callers keep their existing code too. The separate
fatal-alert activation path is unchanged.

The change adds no conditional second request, suspension, deferral, yield or
focus wait. It adds no public interface and no new diagnostic instrument. This is
the application invocation order. It does not establish native completion or
guarantee focus. Both calls are cited at the decision site.

Apple's [activation contract](https://developer.apple.com/documentation/appkit/nsapplication/activate%28%29)
allows the system to decline the request. Its
[window contract](https://developer.apple.com/documentation/appkit/nswindow/makekeyandorderfront%28_%3A%29)
describes key and front placement within the level of the window. Neither
retrieved contract prescribes their relative order. The macOS 27 SDK also warns
against an assumption of immediate activation.

The package requires macOS 26 and Swift tools 6.2. The checked compiler is Apple
Swift 6.4. The [retrieval receipt](ordering-application-evidence/apple-contracts.json)
records response hashes and the digest of the installed SDK header. It does not
retain the full copyrighted responses.

The [accepted product seam](../../specs/settings-activation-discrimination.md#alternatives-ownership-and-reversal-condition)
has historical real VM failures and no established deterministic local native
RED test. The change adds no fake OS response and no source-order test. Either
would encode the hypothesis instead of a demonstration of repaired focus. The
existing helper tests below establish only their own limited properties.

## Verification

| Command | Result | Scope |
|---|---|---|
| `mise exec -- task build` | Exit 0. [Full output](ordering-application-evidence/build.txt) | Compiles the application and stages the debug provider framework. It does not launch AppKit |
| `mise exec -- task check:settings-activation-interval` | Exit 0. Nine tests pass. [Full output](ordering-application-evidence/headless-tests.txt) | The existing interval and buffer controls. They include one operation and no tick reads when measurement is disabled |

The [before inventory](ordering-application-evidence/inputs-before.json) and the
[after inventory](ordering-application-evidence/inputs-after.json) compare byte
hashes across those checks. They cover each selected local source, test, package
manifest and resolution, the Taskfile and the staging script. Every listed item
matches. These are bounded checks of local inputs, not the full build, signing,
environment and golden freeze of the protocol.

Dependency checkouts, build caches and the complete SDK are outside these
inventories. The [verification receipt](ordering-application-evidence/verification.json)
records the statuses and the limits of interpretation.

The [documentation check output](ordering-application-evidence/doc-links.txt)
retains Task exit 201 and checker exit 1. They come from the two missing links
in the unchanged archived context charter, which an earlier record named. No new
link error is reported. The byte-preserving archive repair stays separate work.

Bounded direct source reads cover the delegate, the menu callbacks and the entry
point. They also cover the disabled branches of the trace and the probe, and the
interval implementation. With both diagnostic paths absent, trace initialisation returns
before observer installation. The record call returns without output. The
interval wrapper executes once without tick samples.

The menu probe has no directory, and it returns before it creates its timer or
monitor. The existing disabled calls stay in the executable. This supplies no
claim of timing neutrality.

CBM startup refused before project, generation or coverage discovery, with the
pre-coordination unverified-generation error. No CBM session was stopped, and no
graph completeness is claimed. No extra implementation review is commissioned
for this local reordering. The whole design and its caller effects already
received independent review, and this child adds no further policy or mechanism.

## Remaining evidence and acceptance

This record produces no new signed application bundle, evaluation freeze or
guest. E01, E02, A01, A02 and A03 are all NOT RUN. The reviewed shared transport,
setup, title and liveness repairs and the finite caller stay required before the
freeze. Every earned implementation review and integration stays required too.
The required restart submission must still be clean. A later boot cannot
rehabilitate a disconnect.

Demonstrably unavailable completion holds E01 for an explicit decision. The
[finite protocol](ORDERING-EVALUATION-PLAN.md) and the
[complete original-duty comparison](../../specs/settings-activation-discrimination.md#original-duty-comparison)
stay binding. Historical failures, classifications, bundles, false clock joins,
closed caps and NOT RUN phases keep their meaning. The six causal slots stay held.

Native cause and ownership stay unresolved. No product or causal ancestor closes.
No release, notarisation or upstream report follows.
