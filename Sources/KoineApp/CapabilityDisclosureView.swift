import KoineManagementClient
import SwiftUI

/// The capability disclosures the server serves, shared by every view that
/// grants or shows a capability. The text is the server's, never the window's:
/// the window and a `koine:manage` client read the same words.
@MainActor
final class DisclosureModel: ObservableObject {
    @Published private(set) var disclosures: [String: String] = [:]
    @Published private(set) var problem: String?

    private let client: ManagementClient

    init(client: ManagementClient) { self.client = client }

    func disclosure(for capability: String) -> String? { disclosures[capability] }

    func refresh() async {
        do {
            disclosures = try await client.capabilityDisclosures()
            problem = nil
        } catch {
            problem = "What the capabilities reach could not be read, so none is described here. "
                + error.localizedDescription
        }
    }

    /// The text is fixed for a running server, so one read settles it; only a
    /// failed read is retried, until the window closes and the task is cancelled.
    func load() async {
        while !Task.isCancelled {
            await refresh()
            if problem == nil { return }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}

/// A capability's disclosure, in the same place wherever it is shown.
struct CapabilityDisclosureText: View {
    let text: String
    let identifier: String

    var body: some View {
        Label(text, systemImage: "info.circle.fill")
            .font(.caption)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier(identifier)
    }
}

/// The read failure, where a grant is made or reviewed.
struct DisclosureProblemText: View {
    @ObservedObject var model: DisclosureModel

    var body: some View {
        if let problem = model.problem {
            Text(problem).font(.caption).foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("disclosure-problem")
        }
    }
}
