import KoineManagementClient
import SwiftUI

/// The management window: status, grants, the create flow and setup, all
/// through the console's GraphQL operations.
struct ManagementView: View {
    @StateObject private var grants: GrantListModel
    @StateObject private var create: CreateGrantModel
    @StateObject private var status: StatusModel
    @StateObject private var loginLaunch = LoginLaunchModel()
    private let port: Int

    init(client: ManagementClient, port: Int) {
        let grants = GrantListModel(client: client)
        _grants = StateObject(wrappedValue: grants)
        _create = StateObject(
            wrappedValue: CreateGrantModel(client: client) { await grants.refresh() }
        )
        _status = StateObject(wrappedValue: StatusModel(client: client))
        self.port = port
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AccessibilityStatusView(model: status)
                Divider()
                GrantListView(model: grants)
                Divider()
                CreateGrantView(model: create)
                Divider()
                LoginLaunchView(model: loginLaunch)
                Divider()
                ServiceStatusView(model: status, port: port)
            }
            .padding(20)
            .task { await status.follow() }
        }
        .frame(width: 480, height: 680)
    }
}
