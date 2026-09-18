import AppKit
import KoineManagementClient
import SwiftUI

@MainActor
final class GrantListModel: ObservableObject {
    @Published private(set) var grants: [ManagedGrant] = []
    @Published private(set) var problem: String?
    /// The grant whose revocation awaits the user's confirmation.
    @Published var pendingRevocation: ManagedGrant?

    private let client: ManagementClient

    init(client: ManagementClient) { self.client = client }

    func refresh() async {
        do {
            grants = try await client.grants()
            problem = nil
        } catch {
            problem = "The grant list could not be read. \(error.localizedDescription)"
        }
    }

    /// The list is re-read from the server afterwards, whatever the outcome, so
    /// a row never shows a state the server did not report.
    func revoke(_ grant: ManagedGrant) async {
        var failure: String?
        do {
            _ = try await client.revokeGrant(id: grant.grantId)
        } catch {
            failure = "“\(grant.clientLabel)” was not revoked. \(error.localizedDescription)"
        }
        await refresh()
        if let failure { problem = failure }
    }
}

struct GrantListView: View {
    @ObservedObject var model: GrantListModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grants").font(.headline)
            if model.grants.isEmpty {
                Text("No grants yet.").foregroundColor(.secondary)
            }
            ForEach(model.grants, id: \.grantId) { grant in
                row(grant)
                Divider()
            }
            if let problem = model.problem {
                Text(problem).font(.caption).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("grants-problem")
            }
            Text(
                "Koine never shows a credential again. If one is lost, revoke its grant and "
                    + "create another."
            )
            .font(.caption).foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .task { await model.refresh() }
        // A koine:manage client may have changed the grants over HTTP meanwhile.
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await model.refresh() }
        }
        .confirmationDialog(
            "Revoke “\(model.pendingRevocation?.clientLabel ?? "")”?",
            isPresented: Binding(
                get: { model.pendingRevocation != nil },
                set: { if !$0 { model.pendingRevocation = nil } }
            ),
            presenting: model.pendingRevocation
        ) { grant in
            Button("Revoke “\(grant.clientLabel)”", role: .destructive) {
                Task { await model.revoke(grant) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { grant in
            Text(
                "Its credential stops working immediately and cannot be restored. "
                    + "Grant \(grant.grantId)."
            )
        }
    }

    private func row(_ grant: ManagedGrant) -> some View {
        let isActive = grant.state == "ACTIVE"
        return HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(grant.clientLabel)
                Text(grant.capabilities.isEmpty ? "No capabilities" : grant.capabilities.joined(separator: ", "))
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(grant.state.capitalized)
                .font(.caption).foregroundColor(isActive ? .primary : .secondary)
            Button("Revoke") { model.pendingRevocation = grant }
                .disabled(!isActive)
                .accessibilityIdentifier("revoke-\(grant.grantId)")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("grant-\(grant.grantId)")
    }
}
