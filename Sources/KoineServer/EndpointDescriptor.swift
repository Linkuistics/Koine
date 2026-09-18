import Foundation

/// The version-1 endpoint descriptor. It carries no credential; clients build
/// the literal loopback URL from `port` and `path`.
public struct EndpointDescriptor: Codable, Sendable, Equatable {
    public static let fileName = "endpoint.json"

    public var descriptorVersion = 1
    public var instanceId: String
    public var pid: Int32
    public var port: Int
    public var path = "/graphql"
    public var contractVersion: String

    /// Publishes atomically: a complete 0600 file is renamed over any previous
    /// descriptor, so a reader never sees a partial one.
    func publish(in directory: URL) throws {
        let temporary = directory.appendingPathComponent(".\(Self.fileName).\(instanceId)")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard FileManager.default.createFile(
            atPath: temporary.path, contents: try encoder.encode(self),
            attributes: [.posixPermissions: 0o600]
        ) else { throw CocoaError(.fileWriteUnknown) }
        let destination = directory.appendingPathComponent(Self.fileName)
        guard rename(temporary.path, destination.path) == 0 else {
            try? FileManager.default.removeItem(at: temporary)
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
    }
}
