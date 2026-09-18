import Crypto
import Foundation

/// A bearer secret: 32 random bytes, presented as unpadded base64url.
/// Koine stores only `digest`; the encoded secret is shown once, on creation.
public struct Credential: Sendable {
    public static let byteCount = 32

    /// The one-time secret, unpadded base64url.
    public let encoded: String
    /// Lower-case hex SHA-256 of the decoded 32 bytes.
    public let digest: String

    /// Generates a fresh secret from the system's cryptographically secure generator.
    public static func generate() -> Credential {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<byteCount).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        return Credential(encoded: base64url(bytes), digest: hexDigest(of: bytes))
    }

    /// The digest of a presented credential, or nil when the text is not the
    /// canonical unpadded base64url encoding of exactly 32 bytes.
    public static func digest(ofPresented text: String) -> String? {
        var base64 = text.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        guard !text.contains("+"), !text.contains("/"), !text.contains("=") else { return nil }
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64), data.count == byteCount else { return nil }
        let bytes = [UInt8](data)
        // Re-encoding rejects noncanonical forms, such as non-zero trailing bits.
        guard base64url(bytes) == text else { return nil }
        return hexDigest(of: bytes)
    }

    /// Compares two digests without an early exit on the first differing byte.
    public static func constantTimeEqual(_ lhs: String, _ rhs: String) -> Bool {
        let a = Array(lhs.utf8)
        let b = Array(rhs.utf8)
        guard a.count == b.count else { return false }
        var difference: UInt8 = 0
        for index in a.indices { difference |= a[index] ^ b[index] }
        return difference == 0
    }

    private static func base64url(_ bytes: [UInt8]) -> String {
        Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func hexDigest(of bytes: [UInt8]) -> String {
        hex(SHA256.hash(data: bytes))
    }
}

func hex(_ bytes: some Sequence<UInt8>) -> String {
    let digits = Array("0123456789abcdef".utf8)
    var text = [UInt8]()
    for byte in bytes {
        text.append(digits[Int(byte >> 4)])
        text.append(digits[Int(byte & 0x0F)])
    }
    return String(decoding: text, as: UTF8.self)
}
