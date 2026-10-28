import Foundation

/// Fixed-directory diagnostic requests carry a UUID, never a path or command.
public struct SettingsMenuProbeRequest: Sendable {
    public let id: UUID

    public init?(text: String) {
        let value = text.hasSuffix("\n") ? String(text.dropLast()) : text
        guard value.utf8.count == 36, let id = UUID(uuidString: value) else { return nil }
        self.id = id
    }
}

/// Bound retained identities and responses over this diagnostic process lifetime.
public struct SettingsMenuProbeRequests {
    private var consumed: Set<UUID> = []

    public init() {}

    public mutating func consume(_ request: SettingsMenuProbeRequest) -> Bool {
        guard consumed.count < 16, !consumed.contains(request.id) else { return false }
        consumed.insert(request.id)
        return true
    }
}
