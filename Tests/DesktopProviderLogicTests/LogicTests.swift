import Testing

@testable import DesktopProviderLogic

struct ProcessStartTests {
    @Test func theCanonicalFormRoundTripsAtMicrosecondPrecision() {
        let start = ProcessStart(canonical: "2026-09-19T01:02:03.000456Z")
        #expect(start?.microsecondsSinceEpoch == 1_789_779_723_000_456)
        #expect(start?.canonical == "2026-09-19T01:02:03.000456Z")
        #expect(ProcessStart(microsecondsSinceEpoch: 0).canonical == "1970-01-01T00:00:00.000000Z")
        #expect(ProcessStart(canonical: "2024-02-29T23:59:59.999999Z") != nil)
    }

    @Test(arguments: [
        "", "2026-09-19T01:02:03Z", "2026-09-19T01:02:03.456Z", "2026-09-19T01:02:03.0004567Z",
        "2026-09-19T01:02:03.000456z", "2026-09-19t01:02:03.000456Z", "2026-09-19 01:02:03.000456Z",
        "2026-09-19T01:02:03.000456+00:00", "2026-09-19T01:02:03.000456", "2026-02-30T01:02:03.000456Z",
        "2025-02-29T00:00:00.000000Z", "2026-13-01T00:00:00.000000Z", "2026-09-19T24:00:00.000000Z",
        "2026-09-19T01:02:60.000000Z", "1969-12-31T23:59:59.000000Z", " 2026-09-19T01:02:03.000456Z",
        "２026-09-19T01:02:03.000456Z", "1789779723000456",
    ])
    func anythingElseIsNoStartInstant(text: String) {
        #expect(ProcessStart(canonical: text) == nil)
    }
}

struct DesktopReferenceTests {
    let process = ProcessIncarnation(pid: 412, startMicroseconds: 1_789_779_723_000_456)

    @Test func referencesRoundTrip() {
        let application = DesktopReference.application(process)
        #expect(application.uri == "koine://desktop/application/412/1789779723000456")
        #expect(DesktopReference(uri: application.uri) == application)
        let window = DesktopReference.window(process, session: "00ab34cd56ef7890", token: 7)
        #expect(window.uri == "koine://desktop/window/412/1789779723000456/00ab34cd56ef7890/7")
        #expect(DesktopReference(uri: window.uri) == window)
    }

    @Test(arguments: [
        "koine://desktop/", "koine://desktop/application/412", "koine://desktop/application/0412/5",
        "koine://desktop/application/412/5/", "koine://desktop/application/-4/5",
        "koine://desktop/window/412/5/00ab34cd56ef7890", "koine://desktop/window/412/5/00AB34CD56EF7890/7",
        "koine://desktop/window/412/5/short/7", "koine://desktop/window/412/5/00ab34cd56ef7890/+7",
        "koine://fixture/item/1", "koine://desktop/thing/412/5",
    ])
    func anythingElseIsNoReference(uri: String) {
        #expect(DesktopReference(uri: uri) == nil)
    }
}

/// Elements here are numbers; two windows may share a title.
struct HeldWindowsTests {
    let process = ProcessIncarnation(pid: 412, startMicroseconds: 1_789_779_723_000_456)
    let successor = ProcessIncarnation(pid: 412, startMicroseconds: 1_789_779_999_000_000)

    private func table() -> HeldWindows<Int> { HeldWindows(same: ==) }
    private func never(_ element: Int) -> Unlisted {
        Issue.record("a listed window was asked about")
        return .ended
    }

    @Test func aWindowEnumerationOmitsIsRememberedOnceUnderTheTokenItHadWhileCurrent() {
        var held = table()
        let first = held.rows(listing: [(10, "Untitled"), (11, "Untitled")], of: process, ask: never)
        #expect(first == [
            WindowRow(token: 1, title: "Untitled", remembered: false),
            WindowRow(token: 2, title: "Untitled", remembered: false),
        ])
        let away = held.rows(listing: [(11, "Untitled")], of: process) { _ in .window(title: "Renamed") }
        #expect(away == [
            WindowRow(token: 2, title: "Untitled", remembered: false),
            WindowRow(token: 1, title: "Renamed", remembered: true),
        ])
        let back = held.rows(listing: [(10, "Renamed"), (11, "Untitled"), (10, "Renamed")], of: process, ask: never)
        #expect(back.map(\.token) == [1, 2])
        #expect(back.allSatisfy { !$0.remembered })
    }

    @Test func anElementThatDoesNotAnswerIsReportedAsItWasLastSeen() {
        var held = table()
        _ = held.rows(listing: [(10, "Notes")], of: process, ask: never)
        _ = held.rows(listing: [], of: process) { _ in .window(title: "Notes — edited") }
        let rows = held.rows(listing: [], of: process) { _ in .unanswered }
        #expect(rows == [WindowRow(token: 1, title: "Notes — edited", remembered: true)])
    }

    @Test func aWindowThatEndedIsDroppedAndOneThatCannotBeShownIsKeptUnreported() {
        var held = table()
        _ = held.rows(listing: [(10, "A"), (11, "B")], of: process, ask: never)
        let rows = held.rows(listing: [], of: process) { $0 == 10 ? .ended : .notShown }
        #expect(rows.isEmpty)
        #expect(held.element(1, of: process) == nil)
        #expect(held.element(2, of: process) == 11)
        // The token is not issued again.
        #expect(held.rows(listing: [(12, "C")], of: process) { _ in .notShown }.map(\.token) == [3])
    }

    @Test func retiringAndForgettingLeaveNothingForASuccessor() {
        var held = table()
        _ = held.rows(listing: [(10, "A"), (11, "B")], of: process, ask: never)
        held.retire(1, of: process)
        #expect(held.rows(listing: [], of: process) { _ in .unanswered }.map(\.token) == [2])
        held.retire(element: 11, of: process)
        #expect(held.rows(listing: [], of: process) { _ in .unanswered }.isEmpty)
        #expect(held.rows(listing: [], of: successor, ask: never).isEmpty)
        #expect(held.forget { $0.pid == 412 }.contains(process))
        #expect(held.rows(listing: [], of: process, ask: never).isEmpty)
    }
}
