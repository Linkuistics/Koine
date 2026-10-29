# Ordering design: source and contract evidence

The [current contract](../../specs/settings-activation-discrimination.md#single-request-ordering-design)
and [finite protocol](ORDERING-EVALUATION-PLAN.md) define the proposal. This record
supports its source/API choices; it is not a runtime or repair result.

The [review integration](ORDERING-REVIEW.md) verifies the transport, setup,
predicate and liveness findings against the existing helpers. The current
protocol explicitly requires scenario/helper changes before freeze, shared by
focused and ordinary sets. The source observations below describe the inspected
pre-implementation source; they are not claims that the repaired instrument
already exists. K49's receipts remain historical.

## Inspection boundary

The working copy began empty at jj change `krwtqnvn`, parent `0140ef27`.
`codebase-memory-mcp cli list_projects` refused startup with the same
pre-coordination/unverified-generation error as earlier sessions. No project,
generation or coverage result was available. No graph session was stopped.
The following exact reads are bounded source evidence, not an exhaustive
repository audit. Application/source bytes remained unchanged in that design.
The later [application implementation](ORDERING-APPLICATION-RESULTS.md) supplies
the reviewed reversal and its separate build/control receipt; the source
observations below remain the pre-implementation evidence.

| Input | Material finding |
|---|---|
| [AppDelegate](../../../Sources/KoineApp/AppDelegate.swift), whole file | Main-actor owner retains one window. Launch, reopen and menu closure share show; readiness/construction/navigation precede makeKeyAndOrderFront and one measured NSApp.activate. Closing retains the window. Fatal-alert activation is a separate terminating path. |
| [MenuBarController](../../../Sources/KoineApp/MenuBarController.swift), whole file | Settings and status-line callbacks each invoke the closure once; menu-close observes only. The status follower supplies no activation policy. |
| [Main entry](../../../Sources/KoineApp/main.swift) and [Info.plist](../../../App/Info.plist) | AppKit owns the run loop; LSUIElement is true and the deployment floor is 26.0. |
| [SettingsActivationTrace](../../../Sources/KoineApp/SettingsActivationTrace.swift), initialization and measureActivation | Absent file and buffer preferences return before observer installation. The activation operation still executes once; memory mode alone samples native ticks. Disabled calls remain in the executable. |
| [SettingsMenuProbe](../../../Sources/KoineApp/SettingsMenuProbe.swift), opt-in initialization | Requires memory mode, no file trace and explicit opt-in. The evaluation disables all three. Source applicability is not guest qualification. |
| [Complete scenario](../../../scripts/vm-verify-menu-bar.sh), whole file | Existing first-launch/four-selection prefix; later resize/shortcuts/requests/status navigation/consent/silent launch/reopen/login/Quit phases. The focused design extracts the current prefix; ordinary acceptance runs the complete Task. |
| [VM helpers](../../../scripts/vm-verify-lib.sh), startup/install/menu/window/guest helpers, and [pointer helpers](../../../scripts/vm-menu-pointer-lib.sh), whole file | One physical row click; count polling and one front/focus predicate. guest_once discards status; guest_text strips timeout text; the legacy retry path cannot establish clean evidence. The proposed finite caller must preserve raw outcomes and stop on required transport failure. |
| [Diagnostic wrapper](run.sh), whole file | Exports trace for both named stages. Its repair stage cannot supply diagnostics-disabled ordinary acceptance. Capture/audit/cleanup responsibilities must be carried into the new finite caller, not silently inherited as qualified. |
| [Taskfile](../../../Taskfile.yml), app/build, docs, design:serve and menu/ordering/check entries | Existing deterministic entry points serve the presentation, check docs, build/sign and run the agreed VM scenario. This design adds no executable task or source change. |

The existing end-to-end seam has real historical failures. [ORDER-RESULTS](ORDER-RESULTS.md)
contains original A01 failure and both-order success with synchronous file tracing;
B03 also has a failed final installed-inventory transport. The raw outcomes are
not a passing empirical baseline. The new protocol adopts the approved behavioral
standard and a single diagnostics-disabled candidate; it neither repeats nor
extends that closed comparison.

## Primary contracts

Apple's live Markdown contracts were retrieved on 2026-10-29 after web-tool
retrieval exposed only JavaScript shells and rejected the Markdown content type.
HTTPS retrieval succeeded. The [retrieval receipt](ordering-design-evidence/apple-contracts.json)
records exact URLs, response hashes, sizes and times, plus short checked excerpts.
Full copyrighted responses are not retained. The installed Xcode macOS 27 SDK
NSApplication.h activation declarations were also read and their file digest is
in the [verification receipt](ordering-design-evidence/verification.json).

| Contract | Design consequence |
|---|---|
| [Self activation](https://developer.apple.com/documentation/appkit/nsapplication/activate%28%29) | Available from macOS 14. A self request may be declined; a call on an already-active app cancels its pending outgoing yields. SDK declarations also deny immediate-completion guarantees. Reversal cannot rely on active state at the next statement. |
| [Cooperative activation](https://developer.apple.com/documentation/appkit/passing-control-from-one-app-to-another-with-cooperative-activation) | NSApp is the intended self receiver. An active app supplies cooperation for a transfer; identifying TextEdit supplies no yield. No cooperative transfer is proposed. |
| [Key/front ordering](https://developer.apple.com/documentation/appkit/nswindow/makekeyandorderfront%28_%3A%29) | Requests the target window's key/front placement within its level. The contract supplies no required order relative to self activation. |
| [Key eligibility](https://developer.apple.com/documentation/appkit/nswindow/canbecomekey) | An ordinary titled window satisfies the documented style condition. No new window subclass/override is justified. |
| [Accessory policy](https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy-swift.enum/accessory) | LSUIElement corresponds to accessory behavior and permits programmatic activation. No Dock/policy change is needed for API applicability. |
| [Move to active Space](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/movetoactivespace) | Chooses an activated window's destination. It grants no activation authority. Retaining it avoids an unrelated behavior change; the sample does not qualify multiple-Space configurations. |

The API-use no-candidate finding remains bounded and unchanged. No checked
contract prescribes the proposed relative order; k46's named exception is its
design authority. Future implementation must cite the activation and window
contracts at the non-obvious order decision, explaining its empirical status.

## Design obligations and verification limits

The application delegate keeps lifetime/navigation/request order together; no
caller mode or public interface is added. This removes no existing dependency;
it changes temporal order within one owner. Native focus remains external and
cannot be replaced by a fake that defines the preferred result. Historical
end-to-end failures support a useful failing behavior seam, not deterministic
local reproduction. Helper fixtures qualify capture and classification only.

The two-focused/three-ordinary bounds and first-failure stop rules are stated
before any runtime. They offer finite behavioral acceptance under Antony's
convention, not comparative evidence or statistical confidence. Raw transport
qualification is consequential: the old parsed output alone would allow false
acceptance. Review must examine that rule, the availability/symptom/timing limits,
all caller effects and the complete original-duty comparison as one design.

Document checks and presentation inspection are recorded in the
[verification receipt](ordering-design-evidence/verification.json) and
[raw documentation output](ordering-design-evidence/doc-links.txt). They establish
document consistency only. No product build, native test, signed subject or
guest is produced in this leaf. The existing archive-link repair remains
separate work; historical evidence files and closed causal slots are preserved.
