import KoineManagementClient
import SwiftUI

/// The management window: grants, the create flow and setup, all through the
/// console's GraphQL operations.
struct ManagementView: View {
    @StateObject private var grants: GrantListModel
    @StateObject private var create: CreateGrantModel
    @StateObject private var loginLaunch = LoginLaunchModel()
    private let port: Int

    init(client: ManagementClient, port: Int) {
        let grants = GrantListModel(client: client)
        _grants = StateObject(wrappedValue: grants)
        _create = StateObject(
            wrappedValue: CreateGrantModel(client: client) { await grants.refresh() }
        )
        self.port = port
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GrantListView(model: grants)
                Divider()
                CreateGrantView(model: create)
                Divider()
                LoginLaunchView(model: loginLaunch)
                Divider()
                // This window exists only while the embedded server runs.
                Text("Listening on loopback, port \(String(port)). Closing this window leaves it running.")
                    .font(.caption).foregroundColor(.secondary)
                    .accessibilityIdentifier("service-status")
            }
            .padding(20)
        }
        .frame(width: 480, height: 620)
    }
}
