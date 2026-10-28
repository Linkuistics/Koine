import Foundation
import Testing
@testable import KoineAppDiagnostics

struct SettingsMenuProbeRequestTests {
    @Test func acceptsOnlyOneUUIDWithoutPathComponents() throws {
        let uuid = UUID()
        #expect(SettingsMenuProbeRequest(text: uuid.uuidString)?.id == uuid)
        #expect(SettingsMenuProbeRequest(text: uuid.uuidString + "\n")?.id == uuid)
        for invalid in ["", "../response", uuid.uuidString + "\nextra", " " + uuid.uuidString] {
            #expect(SettingsMenuProbeRequest(text: invalid) == nil)
        }
    }

    @Test func requestIsConsumedOnceWithFiniteLifetimeBudget() throws {
        var requests = SettingsMenuProbeRequests()
        let first = try #require(SettingsMenuProbeRequest(text: UUID().uuidString))
        let accepted = requests.consume(first)
        let duplicate = requests.consume(first)
        #expect(accepted)
        #expect(!duplicate)
        for _ in 1..<16 {
            let accepted = requests.consume(try #require(SettingsMenuProbeRequest(text: UUID().uuidString)))
            #expect(accepted)
        }
        let excess = requests.consume(try #require(SettingsMenuProbeRequest(text: UUID().uuidString)))
        #expect(!excess)
    }
}
