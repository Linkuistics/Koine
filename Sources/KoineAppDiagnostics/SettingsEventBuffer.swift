import Foundation

/// The memory-only store behind the opt-in Settings event diagnostic.
public struct SettingsEventBuffer<Record: Encodable> {
    private let capacity: Int
    private var records: [Record] = []
    private var dropped = 0

    public init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        records.reserveCapacity(capacity)
    }

    public mutating func append(_ record: Record) {
        guard records.count < capacity else {
            dropped += 1
            return
        }
        records.append(record)
    }

    private struct Snapshot: Encodable {
        let format = "koine-settings-events/1"
        let capacity: Int
        let dropped: Int
        let records: [Record]
    }

    public func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(Snapshot(capacity: capacity, dropped: dropped, records: records))
    }

    /// Called only by the explicit post-observation dump, never by append.
    public func write(to url: URL) throws {
        try encoded().write(to: url, options: .withoutOverwriting)
    }
}
