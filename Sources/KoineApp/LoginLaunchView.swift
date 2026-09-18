import AppKit
import ServiceManagement
import SwiftUI

/// Login launch through `SMAppService.mainApp`. The only state is the status
/// last read from the service: nothing here remembers what the user asked for,
/// so the UI cannot claim an enabled state the OS has not reported.
@MainActor
final class LoginLaunchModel: ObservableObject {
    @Published private(set) var status: SMAppService.Status
    @Published private(set) var problem: String?

    // "Use this SMAppService to configure the main app to launch at login":
    // https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp
    private let service = SMAppService.mainApp

    init() { status = service.status }

    func refresh() { status = service.status }

    /// `register()` makes the application launch "on subsequent logins" and
    /// throws when "the service isn't approved by the user", in which case the
    /// status is `requiresApproval` rather than unchanged; `unregister()` leaves
    /// the running application alone. Either way the status is read back, not
    /// assumed: https://developer.apple.com/documentation/servicemanagement/smappservice/register()
    /// https://developer.apple.com/documentation/servicemanagement/smappservice/unregister()
    func setEnabled(_ enabled: Bool) {
        do {
            if enabled { try service.register() } else { try service.unregister() }
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
        refresh()
    }

    /// True for both states in which the service is registered.
    var isRegistered: Bool { status == .enabled || status == .requiresApproval }

    // https://developer.apple.com/documentation/servicemanagement/smappservice/status-swift.enum
    var statusText: String {
        switch status {
        case .enabled:
            "Koine will start when you log in."
        case .requiresApproval:
            "Requires approval in System Settings: allow Koine under Login Items. "
                + "Until then Koine will not start at login."
        case .notRegistered:
            "Koine will not start at login. Clients find the service unavailable until you open Koine."
        case .notFound:
            // Documented as an error, but observed in a macOS 26.5 VM as what a
            // signed bundle reads before its first `register()`; registration then
            // succeeds. A real failure surfaces through `problem`.
            "Koine is not registered to start at login. Clients find the service "
                + "unavailable until you open Koine."
        @unknown default:
            "The system reported a login-item status Koine does not know (\(status.rawValue))."
        }
    }
}

struct LoginLaunchView: View {
    @ObservedObject var model: LoginLaunchModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Setup").font(.headline)
            Toggle(
                "Start Koine at login",
                isOn: Binding(get: { model.isRegistered }, set: { model.setEnabled($0) })
            )
            .accessibilityIdentifier("login-launch")
            Text(model.statusText)
                .font(.caption)
                .foregroundColor(model.status == .requiresApproval ? .orange : .secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("login-launch-status")
            if model.status == .requiresApproval {
                // https://developer.apple.com/documentation/servicemanagement/smappservice/opensystemsettingsloginitems()
                Button("Open Login Items Settings…") { SMAppService.openSystemSettingsLoginItems() }
            }
            if let problem = model.problem {
                Text(problem).font(.caption).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("login-launch-problem")
            }
        }
        // The user may have changed the approval in System Settings meanwhile.
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.refresh()
        }
    }
}
