import KoineManagementClient
import SwiftUI

/// The management window: status, requests, grants, the create flow and setup, all
/// through the console's GraphQL operations.
struct ManagementView: View {
    @StateObject private var grants: GrantListModel
    @StateObject private var create: CreateGrantModel
    @StateObject private var status: StatusModel
    @StateObject private var review: RequestReviewModel
    @StateObject private var loginLaunch = LoginLaunchModel()
    private let port: Int

    init(client: ManagementClient, port: Int) {
        let grants = GrantListModel(client: client)
        _grants = StateObject(wrappedValue: grants)
        _create = StateObject(
            wrappedValue: CreateGrantModel(client: client) { await grants.refresh() }
        )
        let status = StatusModel(client: client)
        _status = StateObject(wrappedValue: status)
        // An approval makes a grant, so both lists are re-read after a decision.
        _review = StateObject(
            wrappedValue: RequestReviewModel(client: client) {
                await status.refresh()
                await grants.refresh()
            }
        )
        self.port = port
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AccessibilityStatusView(model: status)
                Divider()
                RequestReviewView(status: status, model: review)
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
