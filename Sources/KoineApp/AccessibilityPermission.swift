import AppKit
import ApplicationServices
import KoineCore

/// Koine's one OS permission, and the only two things done about it: reading
/// it, which the server does on each request, and asking for it, which only the
/// management window does.
enum AccessibilityPermission {
    static let name = "accessibility"

    /// What `koineManagement.osPermissions` serves. `AXIsProcessTrusted` takes
    /// no options, so this read cannot carry the prompt one:
    /// https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted
    /// The owner is the one `extensions.permissionOwner` names.
    static let source: OSPermissionSource = {
        [OSPermissionStatus(permission: name, owner: "koine", granted: AXIsProcessTrusted())]
    }

    /// The consent request, from this process, so macOS attributes it to Koine.
    /// The prompt option is a value "indicating whether the user will be informed if the
    /// current process is untrusted", and "prompting occurs asynchronously"
    /// (AXUIElement.h). The dialog macOS shows names Koine and offers System
    /// Settings itself. Whether macOS shows it for a second request is not
    /// verified, which is why the window has `openSettings` beside it:
    /// https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions
    @MainActor static func requestConsent() {
        // kAXTrustedCheckOptionPrompt's value. The constant is imported as a global
        // `var`, which Swift 6 will not read from isolated code.
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Privacy & Security > Accessibility, where the request above lists Koine.
    /// No official source found for this URL; it is the one the VM verification
    /// has opened since docs/verification/desktop-application-and-windows-vm.md,
    /// and docs/verification/accessibility-status-and-consent-vm.md checks it
    /// from this button. Verify before relying on it on a new macOS release.
    @MainActor static func openSettings() {
        let pane = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: pane) { NSWorkspace.shared.open(url) }
    }
}
