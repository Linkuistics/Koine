import KoineManagementClient
import SwiftUI

/// The user's decisions on enrollment requests. The requests themselves are the
/// polled status's; this holds only what the user has unticked and what the
/// server last refused. What may be approved is the server's to say.
@MainActor
final class RequestReviewModel: ObservableObject {
    /// Per request, the requested capabilities the user has unticked. Ticks
    /// start from the request's own set and are never offered anything else.
    @Published private var unticked: [String: Set<String>] = [:]
    @Published private(set) var problem: String?
    @Published private(set) var isWorking = false
    /// The request whose approval with `koine:manage` awaits confirmation.
    @Published var pendingManageApproval: ManagedGrantRequest?

    static let manage = "koine:manage"

    private let client: ManagementClient
    private let onDecided: @MainActor () async -> Void

    init(client: ManagementClient, onDecided: @escaping @MainActor () async -> Void) {
        self.client = client
        self.onDecided = onDecided
    }

    func isTicked(_ capability: String, of request: ManagedGrantRequest) -> Bool {
        !(unticked[request.requestId]?.contains(capability) ?? false)
    }

    func setTicked(_ isOn: Bool, _ capability: String, of request: ManagedGrantRequest) {
        if isOn {
            unticked[request.requestId]?.remove(capability)
        } else {
            unticked[request.requestId, default: []].insert(capability)
        }
    }

    func ticked(of request: ManagedGrantRequest) -> [String] {
        request.requestedCapabilities.filter { isTicked($0, of: request) }
    }

    /// Approving with `koine:manage` still ticked goes through a confirmation.
    func approve(_ request: ManagedGrantRequest) async {
        if ticked(of: request).contains(Self.manage) {
            pendingManageApproval = request
        } else {
            await approveConfirmed(request)
        }
    }

    func approveConfirmed(_ request: ManagedGrantRequest) async {
        let capabilities = ticked(of: request)
        await decide(request, "approved") {
            _ = try await self.client.approveGrantRequest(
                id: request.requestId, capabilities: capabilities
            )
        }
    }

    func deny(_ request: ManagedGrantRequest) async {
        await decide(request, "denied") {
            _ = try await self.client.denyGrantRequest(id: request.requestId)
        }
    }

    /// The lists are re-read afterwards, whatever the outcome, so the window
    /// never shows a request in a state the server did not report.
    private func decide(
        _ request: ManagedGrantRequest, _ verb: String, _ decision: () async throws -> Void
    ) async {
        isWorking = true
        defer { isWorking = false }
        var failure: String?
        do {
            try await decision()
            unticked[request.requestId] = nil
        } catch ManagementError.rejected(_, _, "already-decided", let state?) {
            // Another manager decided it, or it expired, since it was listed.
            failure = "“\(request.clientLabel)” was not \(verb): it is already \(state.lowercased())."
        } catch {
            failure = "“\(request.clientLabel)” was not \(verb). \(error.localizedDescription)"
        }
        await onDecided()
        problem = failure
    }
}

struct RequestReviewView: View {
    @ObservedObject var status: StatusModel
    @ObservedObject var model: RequestReviewModel

    private var pending: [ManagedGrantRequest] {
        (status.status?.requests ?? []).filter { $0.state == "PENDING" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Requests").font(.headline)
            if pending.isEmpty {
                Text("No requests are waiting.").foregroundColor(.secondary)
                    .accessibilityIdentifier("requests-empty")
            }
            ForEach(pending, id: \.requestId) { request in
                row(request)
                Divider()
            }
            if let problem = model.problem {
                Text(problem).font(.caption).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("requests-problem")
            }
        }
        .confirmationDialog(
            "Approve “\(model.pendingManageApproval?.clientLabel ?? "")” with koine:manage?",
            isPresented: Binding(
                get: { model.pendingManageApproval != nil },
                set: { if !$0 { model.pendingManageApproval = nil } }
            ),
            presenting: model.pendingManageApproval
        ) { request in
            // Destructive, so it is never the dialog's default button.
            Button("Approve with koine:manage", role: .destructive) {
                Task { await model.approveConfirmed(request) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { request in
            Text(
                "This client will be able to issue and revoke other grants, including more "
                    + "koine:manage grants. Check that it shows the code \(request.comparisonCode)."
            )
        }
    }

    private func row(_ request: ManagedGrantRequest) -> some View {
        let id = request.requestId
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(request.clientLabel)
                    .accessibilityIdentifier("request-label-\(id)")
                Spacer()
                Text(request.comparisonCode)
                    .font(.system(.body, design: .monospaced))
                    .accessibilityIdentifier("request-code-\(id)")
            }
            Text("Approve only if the client shows the same code.")
                .font(.caption).foregroundColor(.secondary)
            if request.requestedCapabilities.isEmpty {
                Text("Asks for no capabilities.").font(.caption).foregroundColor(.secondary)
            }
            ForEach(request.requestedCapabilities, id: \.self) { capability in
                Toggle(
                    capability,
                    isOn: Binding(
                        get: { model.isTicked(capability, of: request) },
                        set: { model.setTicked($0, capability, of: request) }
                    )
                )
                .accessibilityIdentifier("request-capability-\(id)-\(capability)")
            }
            if request.requestedCapabilities.contains(RequestReviewModel.manage) {
                Label(
                    "This client asks for koine:manage, which permits issuing and revoking "
                        + "other grants, including more koine:manage grants.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.callout.weight(.semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("request-manage-warning-\(id)")
            }
            HStack {
                Spacer()
                Button("Deny") { Task { await model.deny(request) } }
                    .accessibilityIdentifier("deny-\(id)")
                Button("Approve") { Task { await model.approve(request) } }
                    .accessibilityIdentifier("approve-\(id)")
            }
            .disabled(model.isWorking)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("request-\(id)")
    }
}
