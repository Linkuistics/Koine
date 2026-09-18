import AppKit
import KoineManagementClient
import SwiftUI

@MainActor
final class CreateGrantModel: ObservableObject {
    @Published var label = ""
    @Published var available: [String] = []
    @Published var selected: Set<String> = []
    @Published var problem: String?
    @Published var isWorking = false
    /// The one-time credential, held only while its sheet is up.
    @Published var created: CreatedGrant?

    private let client: ManagementClient
    private let onCreated: @MainActor () async -> Void

    init(client: ManagementClient, onCreated: @escaping @MainActor () async -> Void) {
        self.client = client
        self.onCreated = onCreated
    }

    var canCreate: Bool {
        !isWorking && !label.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func loadCapabilities() async {
        do {
            available = try await client.availableCapabilities()
            selected.formIntersection(available)
        } catch {
            problem = error.localizedDescription
        }
    }

    func create() async {
        isWorking = true
        defer { isWorking = false }
        do {
            created = try await client.createGrant(
                label: label.trimmingCharacters(in: .whitespaces),
                capabilities: available.filter(selected.contains)
            )
            problem = nil
            label = ""
            selected = []
            await onCreated()
        } catch {
            problem = error.localizedDescription
        }
    }

    func forgetCredential() { created = nil }
}

struct CreateGrantView: View {
    @ObservedObject var model: CreateGrantModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create a grant").font(.headline)
            TextField("Client label", text: $model.label)
                .accessibilityIdentifier("grant-label")
            Text("Capabilities").font(.subheadline)
            if model.available.isEmpty {
                Text("None available.").foregroundColor(.secondary)
            }
            ForEach(model.available, id: \.self) { capability in
                Toggle(capability, isOn: binding(for: capability))
            }
            if model.selected.contains("koine:manage") {
                Label(
                    "koine:manage lets the holder of this credential create and revoke "
                        + "other grants, including more koine:manage grants.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.callout.weight(.semibold))
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("manage-warning")
            }
            if let problem = model.problem {
                Text(problem).font(.caption).foregroundColor(.red)
                    .accessibilityIdentifier("grant-problem")
            }
            HStack {
                Spacer()
                Button("Create Grant") { Task { await model.create() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canCreate)
            }
        }
        .task { await model.loadCapabilities() }
        .sheet(
            isPresented: Binding(
                get: { model.created != nil },
                set: { if !$0 { model.forgetCredential() } }
            )
        ) {
            if let created = model.created {
                CredentialSheet(created: created) { model.forgetCredential() }
            }
        }
    }

    private func binding(for capability: String) -> Binding<Bool> {
        Binding(
            get: { model.selected.contains(capability) },
            set: { isOn in
                if isOn { model.selected.insert(capability) } else { model.selected.remove(capability) }
            }
        )
    }
}

private struct CredentialSheet: View {
    let created: CreatedGrant
    let done: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grant created for “\(created.grant.clientLabel)”").font(.headline)
            Text(
                "This credential is shown once. Copy it to the client now; Koine cannot show it "
                    + "again. If it is lost, revoke this grant and create another."
            )
            .fixedSize(horizontal: false, vertical: true)
            Text(created.credential)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .accessibilityIdentifier("grant-credential")
            HStack {
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(created.credential, forType: .string)
                }
                Spacer()
                Button("Done", action: done).keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 460)
    }
}
