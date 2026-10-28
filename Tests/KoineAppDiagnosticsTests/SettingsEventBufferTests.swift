import Foundation
import Testing
@testable import KoineAppDiagnostics

struct SettingsEventBufferTests {
    // Dropping the first record or silently overwriting on overflow loses the
    // callback/call interval that this diagnostic exists to retain.
    @Test func overflowPreservesPrefixAndReportsEveryDroppedRecord() throws {
        var buffer = SettingsEventBuffer<Int>(capacity: 2)
        for number in 1...4 { buffer.append(number) }
        let snapshot = try JSONSerialization.jsonObject(with: buffer.encoded()) as! [String: Any]
        #expect(snapshot["records"] as? [Int] == [1, 2])
        #expect(snapshot["dropped"] as? Int == 2)
        #expect(snapshot["capacity"] as? Int == 2)
    }

    // Record-time output or destructive dumps would invalidate a later dump.
    @Test func outputIsExplicitNonDestructiveAndCannotOverwriteEvidence() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: directory) }
        let output = directory.appendingPathComponent("events.json")
        var buffer = SettingsEventBuffer<String>(capacity: 3)
        buffer.append("callback.settings")
        buffer.append("application.activate.before")
        buffer.append("application.activate.after")
        #expect(!FileManager.default.fileExists(atPath: output.path))
        try buffer.write(to: output)
        let first = try Data(contentsOf: output)
        #expect(first == (try buffer.encoded()))
        #expect(throws: (any Error).self) { try buffer.write(to: output) }
        #expect(try Data(contentsOf: output) == first)
        let snapshot = try JSONSerialization.jsonObject(with: first) as! [String: Any]
        #expect(snapshot["records"] as? [String] == [
            "callback.settings", "application.activate.before", "application.activate.after",
        ])
        #expect(snapshot["dropped"] as? Int == 0)
    }

    @Test func failedDumpKeepsRecordsAvailable() throws {
        var buffer = SettingsEventBuffer<Int>(capacity: 1)
        buffer.append(42)
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        #expect(throws: (any Error).self) { try buffer.write(to: directory.appendingPathComponent("events.json")) }
        let snapshot = try JSONSerialization.jsonObject(with: buffer.encoded()) as! [String: Any]
        #expect(snapshot["records"] as? [Int] == [42])
    }
}
