import Darwin
import Foundation

/// Direct native-tick bounds for one call. This does not identify its native
/// transaction, prove activation, or convert the older uptime-based records.
public struct SettingsActivationInterval: Encodable, Sendable {
    public let beforeTicks: UInt64
    public let afterTicks: UInt64

    public static func measure(
        enabled: Bool,
        readTicks: () -> UInt64 = { mach_continuous_time() },
        operation: () -> Void
    ) -> Self? {
        guard enabled else {
            operation()
            return nil
        }
        // Continuous ticks include sleep; preserve raw units, with no uptime fit.
        // https://developer.apple.com/documentation/kernel/1646199-mach_continuous_time
        let before = readTicks()
        operation()
        let after = readTicks()
        return Self(beforeTicks: before, afterTicks: after)
    }

    private enum CodingKeys: CodingKey { case beforeTicks, afterTicks }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Decimal strings prevent integer rounding in downstream JSON tools.
        try container.encode(String(beforeTicks), forKey: .beforeTicks)
        try container.encode(String(afterTicks), forKey: .afterTicks)
    }
}

/// Read in the observed process, once opt-in memory diagnostics are enabled.
/// A later archive must independently match both identity and tick scale.
public struct SettingsNativeClock: Encodable, Sendable {
    public let bootSessionUUID: String
    public let numerator: UInt32
    public let denominator: UInt32

    public enum CaptureError: Error {
        case bootSessionQuery(Int32)
        case invalidBootSessionUUID
        case timebaseQuery(kern_return_t)
        case invalidTimebase
    }

    public init() throws(CaptureError) {
        // Apple's kernel exports a read-only uuid_string_t (36 bytes plus NUL).
        // https://github.com/apple-oss-distributions/xnu/blob/f6217f891ac0bb64f3d375211650a4c1ff8ca1ea/bsd/kern/kern_sysctl.c
        var bytes = [UInt8](repeating: 0, count: 37)
        var size = bytes.count
        guard sysctlbyname("kern.bootsessionuuid", &bytes, &size, nil, 0) == 0 else {
            throw .bootSessionQuery(errno)
        }
        guard size == bytes.count, bytes.last == 0,
              let boot = String(bytes: bytes.dropLast(), encoding: .utf8) else {
            throw .invalidBootSessionUUID
        }
        // Tick-to-nanosecond fraction from this kernel, not the host/another run.
        // https://developer.apple.com/documentation/kernel/mach_timebase_info_t
        var scale = mach_timebase_info_data_t()
        let status = mach_timebase_info(&scale)
        guard status == KERN_SUCCESS else { throw .timebaseQuery(status) }
        try self.init(bootSessionUUID: boot, numerator: scale.numer, denominator: scale.denom)
    }

    init(bootSessionUUID: String, numerator: UInt32, denominator: UInt32) throws(CaptureError) {
        guard let boot = UUID(uuidString: bootSessionUUID) else { throw .invalidBootSessionUUID }
        guard numerator > 0, denominator > 0 else { throw .invalidTimebase }
        self.bootSessionUUID = boot.uuidString
        self.numerator = numerator
        self.denominator = denominator
    }
}
