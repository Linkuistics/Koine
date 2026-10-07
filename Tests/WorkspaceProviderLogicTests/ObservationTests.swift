import Foundation
import Testing

@testable import WorkspaceProviderLogic

/// The receipt's observation rule, one mismatch at a time. Each case changes
/// exactly one condition of an application that otherwise satisfies every step,
/// and none may produce an identity: there is no PID-only, launch-date or
/// foreground fallback. PID reuse itself cannot be induced here or in a VM; the
/// rule's two kernel reads and its executable and object comparisons are what
/// this checks.
@Suite struct ObservationTests {
    static let start = ProcessStart(microsecondsSinceEpoch: 1_800_000_000_000_001)
    static let other = ProcessStart(microsecondsSinceEpoch: 1_800_000_000_000_002)
    static let exe = FakeNative.identity("exe")

    /// A native whose PID 4242 runs `exe` and reads `start` on every read.
    static func native(reads: [ProcessLookup] = [.running(start)], live: ObjectIdentity? = exe) -> FakeNative {
        let native = FakeNative()
        native.processStarts(4242, reads)
        native.executable(4242, live)
        return native
    }

    @Test func everyConditionMetYieldsTheKernelInstant() {
        let observed = observeProcess(of: FakeApplication(), native: Self.native())
        #expect(observed == ObservedProcess(pid: 4242, start: Self.start))
        #expect(observed?.start.canonical == "2027-01-15T08:00:00.000001Z")
    }

    @Test(arguments: [Int32(0), -1, Int32.min]) func aNonPositivePidIsNull(pid: Int32) {
        #expect(observeProcess(of: FakeApplication(pids: [pid]), native: Self.native()) == nil)
    }

    @Test func aTerminatedApplicationIsNullAtTheFirstCheck() {
        #expect(observeProcess(of: FakeApplication(terminated: [true]), native: Self.native()) == nil)
    }

    @Test func anApplicationThatTerminatesDuringTheObservationIsNullAtTheLastCheck() {
        #expect(observeProcess(of: FakeApplication(terminated: [false, true]), native: Self.native()) == nil)
    }

    @Test func aPidThatChangesDuringTheObservationIsNull() {
        #expect(observeProcess(of: FakeApplication(pids: [4242, 4243]), native: Self.native()) == nil)
    }

    @Test func anAbsentProcessIsNull() {
        #expect(observeProcess(of: FakeApplication(), native: Self.native(reads: [.absent])) == nil)
    }

    @Test func anUnreadableFirstStartIsNull() {
        #expect(observeProcess(of: FakeApplication(), native: Self.native(reads: [.unreadable("denied")])) == nil)
    }

    @Test func anUnreadableSecondStartIsNull() {
        let native = Self.native(reads: [.running(Self.start), .unreadable("denied")])
        #expect(observeProcess(of: FakeApplication(), native: native) == nil)
    }

    @Test func aProcessThatVanishesBetweenTheReadsIsNull() {
        let native = Self.native(reads: [.running(Self.start), .absent])
        #expect(observeProcess(of: FakeApplication(), native: native) == nil)
    }

    @Test func differentStartSamplesAreNull() {
        let native = Self.native(reads: [.running(Self.start), .running(Self.other)])
        #expect(observeProcess(of: FakeApplication(), native: native) == nil)
    }

    /// The third step on every combination the walk can leave: the two identities are the walk's device and
    /// inode, so equality is the only way through and an unavailable value on either side is never equal to
    /// anything, another unavailable value included. Each row otherwise satisfies every other step.
    @Test(
        arguments: [
            ("equal identities", ObservationTests.exe as ObjectIdentity?, ObservationTests.exe as ObjectIdentity?, true),
            ("different inodes", FakeNative.identity("exe"), FakeNative.identity("someone else's binary"), false),
            ("the same inode on another device", FakeNative.identity("exe"), FakeNative.identity("exe", volume: 2), false),
            ("the object's executable unavailable", nil, ObservationTests.exe, false),
            ("the live executable unavailable", ObservationTests.exe, nil, false),
            ("both unavailable", nil, nil, false),
        ]
    )
    func theExecutablesMustBeTheSameObjectAndAnUnavailableOneIsNeverTheSame(
        what: String, retained: ObjectIdentity?, live: ObjectIdentity?, observed: Bool
    ) {
        let outcome = observeProcess(of: FakeApplication(executable: retained), native: Self.native(live: live))
        #expect(outcome == (observed ? ObservedProcess(pid: 4242, start: Self.start) : nil), Comment(rawValue: what))
    }

    @Test func aFreshLookupThatFindsNothingOrSomethingElseIsNull() {
        let application = FakeApplication()
        application.freshEqual = false
        #expect(observeProcess(of: application, native: Self.native(), settle: .milliseconds(30)) == nil)
    }

    /// Seen on a real cold launch: the callback arrived before the system's record
    /// of the application was complete, and the first fresh lookup was not equal.
    @Test func aFreshLookupThatIsEqualOnlyOnALaterTryYieldsTheKernelInstant() {
        let application = FakeApplication()
        application.freshLookupsUnequal = 3
        let observed = observeProcess(of: application, native: Self.native())
        #expect(observed == ObservedProcess(pid: 4242, start: Self.start))
    }

    @Test func aFreshLookupThatOnlySettlesAfterTheBoundIsNull() {
        let application = FakeApplication()
        application.freshLookupsUnequal = 1_000
        #expect(observeProcess(of: application, native: Self.native(), settle: .milliseconds(30)) == nil)
    }
}
