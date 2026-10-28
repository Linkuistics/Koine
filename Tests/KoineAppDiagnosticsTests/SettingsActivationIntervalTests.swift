import Darwin
import Foundation
import Testing
@testable import KoineAppDiagnostics

struct SettingsActivationIntervalTests {
    // Moving either sample inside the operation, or replaying the operation,
    // would invalidate the interval used to locate the native request.
    @Test func samplesEncloseOneOperation() throws {
        var actions: [String] = []
        let interval = try #require(SettingsActivationInterval.measure(
            enabled: true,
            readTicks: {
                actions.append("sample")
                return actions.count == 1 ? 17 : 29
            },
            operation: { actions.append("activate") }
        ))
        #expect(actions == ["sample", "activate", "sample"])
        #expect(interval.beforeTicks == 17)
        #expect(interval.afterTicks == 29)
    }

    // Disabled diagnostics must not suppress/replay activation or sample clocks.
    @Test func disabledMeasurementStillPerformsOperationOnce() {
        var actions: [String] = []
        let interval = SettingsActivationInterval.measure(
            enabled: false,
            readTicks: { actions.append("sample"); return 1 },
            operation: { actions.append("activate") }
        )
        #expect(interval == nil)
        #expect(actions == ["activate"])
    }

    // A Double or an integer-reading JSON consumer can round native ticks.
    @Test func encodingKeepsTicksAsExactDecimalStrings() throws {
        var samples = [UInt64.max, UInt64.max - 1].makeIterator()
        let interval = try #require(SettingsActivationInterval.measure(
            enabled: true, readTicks: { samples.next()! }, operation: {}
        ))
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(interval)) as! [String: String]
        #expect(json["beforeTicks"] == "18446744073709551615")
        #expect(json["afterTicks"] == "18446744073709551614")
        // Preserve reversed samples as invalid evidence; never sort or widen.
        #expect(interval.afterTicks < interval.beforeTicks)
    }

    @Test func realContinuousClockEnclosesAnIndependentRead() throws {
        var inside: UInt64 = 0
        let interval = try #require(SettingsActivationInterval.measure(enabled: true) {
            inside = mach_continuous_time()
        })
        #expect(interval.beforeTicks <= inside)
        #expect(inside <= interval.afterTicks)
    }

    // Missing identity and a zero scale cannot silently become usable metadata.
    @Test func clockMetadataRejectsUnknownBootAndInvalidScale() {
        #expect(throws: SettingsNativeClock.CaptureError.self) {
            try SettingsNativeClock(bootSessionUUID: "unknown", numerator: 125, denominator: 3)
        }
        for (numerator, denominator): (UInt32, UInt32) in [(0, 3), (125, 0)] {
            #expect(throws: SettingsNativeClock.CaptureError.self) {
                try SettingsNativeClock(
                    bootSessionUUID: "2C83AC73-0855-44FD-A8A4-E03E227E1A01",
                    numerator: numerator, denominator: denominator
                )
            }
        }
    }

    @Test func realClockMetadataMatchesIndependentKernelQueries() throws {
        let clock = try SettingsNativeClock()
        var scale = mach_timebase_info_data_t()
        #expect(mach_timebase_info(&scale) == KERN_SUCCESS)
        #expect(clock.numerator == scale.numer)
        #expect(clock.denominator == scale.denom)
        #expect(UUID(uuidString: clock.bootSessionUUID) != nil)
        // Independent command result, not a second call through the recorder.
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/sysctl")
        process.arguments = ["-n", "kern.bootsessionuuid"]
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        #expect(process.terminationStatus == 0)
        #expect(clock.bootSessionUUID == String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }
}
