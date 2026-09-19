import AppKit
import KoineManagementClient
import SwiftUI

/// Accessibility, provider and service status. Every fact but the port comes
/// from one management operation; nothing here asks the OS anything itself, so
/// the window and a `koine:manage` client cannot disagree.
@MainActor
final class StatusModel: ObservableObject {
    @Published private(set) var status: ManagementStatus?
    @Published private(set) var problem: String?

    private let client: ManagementClient

    init(client: ManagementClient) { self.client = client }

    func refresh() async {
        do {
            let read = try await client.status()
            // Publishing an equal value would redraw the window on every poll.
            if read != status { status = read }
            problem = nil
        } catch {
            status = nil
            problem = "Koine's status could not be read. \(error.localizedDescription)"
        }
    }

    /// Consent is System Settings' to record, and nothing announces a change to
    /// it, so the status is re-read while the window shows it. Ends when the
    /// view's task is cancelled.
    func follow() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    var accessibility: ManagedOSPermission? {
        status?.osPermissions.first { $0.permission == AccessibilityPermission.name }
    }
}

/// First in the window: missing consent is the one status the user must act on.
struct AccessibilityStatusView: View {
    @ObservedObject var model: StatusModel

    var body: some View {
        if let accessibility = model.accessibility { section(accessibility) }
    }

    private func section(_ permission: ManagedOSPermission) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Accessibility").font(.headline)
            Text(
                permission.granted
                    ? "Koine has Accessibility access. Clients read and focus windows through it."
                    : "Koine does not have Accessibility access, so clients cannot list or focus "
                        + "windows. Koine is the application that needs it, not its clients: "
                        + "switch Koine on in System Settings, under Privacy & Security, "
                        + "Accessibility. No restart is needed."
            )
            .font(.caption)
            .foregroundColor(permission.granted ? .secondary : .orange)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("accessibility-status")
            if !permission.granted {
                HStack {
                    Button("Request Accessibility Access…") { AccessibilityPermission.requestConsent() }
                        .accessibilityIdentifier("request-accessibility")
                    Button("Open Accessibility Settings…") { AccessibilityPermission.openSettings() }
                        .accessibilityIdentifier("open-accessibility-settings")
                }
            }
        }
    }
}

struct ServiceStatusView: View {
    @ObservedObject var model: StatusModel
    let port: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            providers
            service
        }
    }

    private var providers: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Providers").font(.headline)
            if let status = model.status, status.providers.isEmpty {
                Text("No providers found.").foregroundColor(.secondary)
            }
            ForEach(model.status?.providers ?? [], id: \.provider) { provider in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(provider.provider) \(provider.version)")
                        Spacer()
                        Text(provider.state.capitalized)
                            .font(.caption)
                            .foregroundColor(provider.state == "ACTIVE" ? .primary : .orange)
                    }
                    if let diagnostic = provider.diagnostic {
                        Text(diagnostic).font(.caption).foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("provider-\(provider.provider)")
            }
        }
    }

    private var service: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Service").font(.headline)
            if let status = model.status {
                // This window exists only while the embedded server runs.
                Text(
                    "Serving \(status.contractVersion) at http://127.0.0.1:\(String(port))/graphql. "
                        + "Closing this window leaves it running."
                )
                .font(.caption).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("service-status")
            }
            if let problem = model.problem {
                Text(problem).font(.caption).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("status-problem")
            }
        }
    }
}
