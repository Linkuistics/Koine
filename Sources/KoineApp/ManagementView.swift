import KoineManagementClient
import SwiftUI

/// Where the menu bar item asks the settings window to scroll. Each request is a
/// new value, so choosing the same section twice scrolls twice.
@MainActor
final class SettingsNavigation: ObservableObject {
    struct Request: Equatable {
        let section: SettingsSection
        let serial: Int
    }

    @Published private(set) var request: Request?
    private var serial = 0

    func show(_ section: SettingsSection) {
        serial += 1
        request = Request(section: section, serial: serial)
    }
}

/// The settings window's content: status, requests, grants, the create flow and
/// setup, all through the console's GraphQL operations. It scrolls, so a small
/// window still reaches every control.
struct ManagementView: View {
    /// The least width and height at which every control stays usable.
    static let minimumSize = CGSize(width: 440, height: 320)
    /// What the window opens at.
    static let defaultSize = CGSize(width: 480, height: 680)

    @ObservedObject var navigation: SettingsNavigation
    @StateObject private var grants: GrantListModel
    @StateObject private var create: CreateGrantModel
    @StateObject private var status: StatusModel
    @StateObject private var review: RequestReviewModel
    @StateObject private var disclosures: DisclosureModel
    @StateObject private var loginLaunch = LoginLaunchModel()
    private let port: Int

    init(client: ManagementClient, port: Int, navigation: SettingsNavigation) {
        self.navigation = navigation
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
        _disclosures = StateObject(wrappedValue: DisclosureModel(client: client))
        self.port = port
    }

    var body: some View {
        ScrollViewReader { proxy in
            content
                .onChange(of: navigation.request) { _, request in scroll(to: request, with: proxy) }
                // A window opened from a status line is built after the request.
                .onAppear { scroll(to: navigation.request, with: proxy) }
        }
        // The hosting controller gives the window its least size from this minimum.
        .frame(minWidth: Self.minimumSize.width, minHeight: Self.minimumSize.height)
    }

    private func scroll(to request: SettingsNavigation.Request?, with proxy: ScrollViewProxy) {
        guard let request else { return }
        // After this pass has laid the sections out.
        DispatchQueue.main.async { withAnimation { proxy.scrollTo(request.section, anchor: .top) } }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AccessibilityStatusView(model: status).id(SettingsSection.accessibility)
                Divider()
                RequestReviewView(status: status, model: review, disclosures: disclosures)
                    .id(SettingsSection.requests)
                Divider()
                GrantListView(model: grants, disclosures: disclosures)
                Divider()
                CreateGrantView(model: create, disclosures: disclosures)
                Divider()
                LoginLaunchView(model: loginLaunch)
                Divider()
                ServiceStatusView(model: status, port: port)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .task { await status.follow() }
            .task { await disclosures.load() }
        }
    }
}
