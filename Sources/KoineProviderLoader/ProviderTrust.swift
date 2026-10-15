import Foundation
import Security

/// An approval record: the provider a user or the application approved, and the
/// signing identity its bundle must carry (docs/specs/machine.md, "Loading and
/// trust"). The identity is an Apple Team ID.
public struct ProviderApproval: Sendable, Equatable, Decodable {
    public let providerId: String
    public let teamIdentifier: String

    public init(providerId: String, teamIdentifier: String) {
        self.providerId = providerId
        self.teamIdentifier = teamIdentifier
    }

    /// The Team ID of this process's own signature; nil when it is unsigned or
    /// ad-hoc signed, as a development build run outside `Koine.app` is.
    public static var hostTeamIdentifier: String? {
        var code: SecCode?
        // The running code must still answer to its signature before what that
        // signature says of it is believed.
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code,
            SecCodeCheckValidity(code, [], nil) == errSecSuccess
        else { return nil }
        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode else {
            return nil
        }
        return CodeSignature.information(of: staticCode)?[kSecCodeInfoTeamIdentifier as String]
            as? String
    }

    /// A Team ID is ten upper-case alphanumerics. It is checked before it is
    /// written into a requirement string.
    var hasWellFormedTeamIdentifier: Bool {
        teamIdentifier.utf8.count == 10
            && teamIdentifier.utf8.allSatisfy { (0x30...0x39).contains($0) || (0x41...0x5A).contains($0) }
    }
}

/// A Koine-owned installation root, supplied by the host, and where its
/// approval records come from.
public struct ProviderRoot: Sendable {
    enum Kind: Sendable {
        case bundled
        case installed
    }

    public let location: URL
    let kind: Kind

    /// The root sealed inside the application bundle. It holds only the bundles
    /// the sealed catalogue designates, and their approval is the host's own:
    /// the Team ID of the verified running signature, never a file
    /// (docs/specs/machine.md, "Reserved identities").
    public static func bundled(_ location: URL) -> ProviderRoot {
        ProviderRoot(location: location, kind: .bundled)
    }

    /// The per-user installed root. Its approval records are files the user
    /// places beside the bundles; Koine writes none.
    public static func installed(_ location: URL) -> ProviderRoot {
        ProviderRoot(location: location, kind: .installed)
    }

    /// Whether this is the in-application root, whose bundles are Koine's own.
    public var isBundled: Bool { kind == .bundled }

    /// The physical origin of every candidate found in this root.
    var origin: ProviderCandidateReport.Origin { kind == .bundled ? .bundled : .perUser }

    public static func approvalRecordName(for providerId: String) -> String {
        "\(providerId).approval.json"
    }

    struct Unapproved: Error {
        let reason: String
    }

    /// The approval record `<providerId>.approval.json` in this per-user root.
    /// A record is never read from the in-application root: its approval is the
    /// host's, and a file there approves nothing.
    func approvalRecord(for providerId: String) throws -> ProviderApproval {
        let name = Self.approvalRecordName(for: providerId)
        // The identifier names a file: it must not name a path.
        guard kind == .installed, !providerId.contains("/"), !providerId.hasPrefix("."),
            let data = try? Data(contentsOf: location.appendingPathComponent(name))
        else {
            throw Unapproved(
                reason: "Provider \(providerId) is not approved: there is no \(name) in the provider root."
            )
        }
        guard let record = try? JSONDecoder().decode(ProviderApproval.self, from: data),
            record.providerId == providerId
        else {
            throw Unapproved(reason: "\(name) is not an approval record for provider \(providerId).")
        }
        guard record.hasWellFormedTeamIdentifier else {
            throw Unapproved(
                reason: "The approval record for provider \(providerId) does not name a Team ID."
            )
        }
        return record
    }
}

/// Static code-signature validation: of files on disk, before any of them is
/// loaded. Nothing here relaxes a check or alters what it checks.
enum CodeSignature {
    /// Why the code at `path` does not carry a valid signature by the approved
    /// identity, or nil when it does.
    static func refusal(of path: String, approvedBy approval: ProviderApproval) -> String? {
        var code: SecStaticCode?
        guard
            SecStaticCodeCreateWithPath(URL(fileURLWithPath: path) as CFURL, [], &code) == errSecSuccess,
            let code
        else { return "it cannot be read as signed code." }
        // Requirement language, and why the Team ID is the leaf certificate's
        // subject.OU under Apple's anchor:
        // https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements
        var requirement: SecRequirement?
        let text = "anchor apple generic and certificate leaf[subject.OU] = \"\(approval.teamIdentifier)\""
        guard SecRequirementCreateWithString(text as CFString, [], &requirement) == errSecSuccess,
            let requirement
        else { return "its approval record does not name a usable identity." }

        let flags = SecCSFlags(
            rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate | kSecCSCheckNestedCode
        )
        let status = SecStaticCodeCheckValidityWithErrors(code, flags, requirement, nil)
        switch status {
        case errSecSuccess: return nil
        case errSecCSUnsigned: return "it is not signed."
        case errSecCSReqFailed:
            return "it is \(signer(of: code)), not by the approved identity, Team ID \(approval.teamIdentifier)."
        default:
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "error \(status)"
            return "its signature is not valid: \(message)."
        }
    }

    /// The code-signing identifier the signature at `path` carries. It is read
    /// from the signature, never the manifest, and is believed only of code
    /// whose signature `refusal(of:approvedBy:)` has already accepted.
    static func identifier(of path: String) -> String? {
        var code: SecStaticCode?
        guard
            SecStaticCodeCreateWithPath(URL(fileURLWithPath: path) as CFURL, [], &code) == errSecSuccess,
            let code
        else { return nil }
        return information(of: code)?[kSecCodeInfoIdentifier as String] as? String
    }

    static func information(of code: SecStaticCode) -> [String: Any]? {
        var information: CFDictionary?
        let flags = SecCSFlags(rawValue: kSecCSSigningInformation)
        guard SecCodeCopySigningInformation(code, flags, &information) == errSecSuccess else {
            return nil
        }
        return information as? [String: Any]
    }

    private static func signer(of code: SecStaticCode) -> String {
        let information = information(of: code)
        if let team = information?[kSecCodeInfoTeamIdentifier as String] as? String {
            return "signed by Team ID \(team)"
        }
        let flags = (information?[kSecCodeInfoFlags as String] as? NSNumber)?.uint32Value ?? 0
        if flags & SecCodeSignatureFlags.adhoc.rawValue != 0 { return "ad-hoc signed" }
        return "signed by an identity with no Team ID"
    }
}

/// Gatekeeper's verdict on a quarantined image, asked before it is loaded.
/// Asked at `dlopen` instead, a refusal is a modal system dialog that holds the
/// caller until someone dismisses it, and providers load while the service
/// starts (docs/specs/machine.md, "Loading and trust").
///
/// Not the `notarized` code requirement: that is an offline lookup of the local
/// ticket store — `isNotarized` in Apple's Security source,
/// https://github.com/apple-oss-distributions/Security/blob/main/OSX/libsecurity_codesigning/lib/notarization.cpp
/// with the flag SecAssessment.h documents as "offline check" — and a provider
/// bundle has no `Contents/CodeResources` for `stapler` to put a ticket in. So
/// a notarized provider fails it until this Mac has looked its ticket up
/// online, which Gatekeeper does and that requirement does not. `spctl` is
/// Gatekeeper's own assessment, online lookup included, and shows no dialog.
enum Gatekeeper {
    static let quarantineAttribute = "com.apple.quarantine"
    /// A bound on the online lookup, which holds the service's startup.
    static let timeout: TimeInterval = 30

    /// Whether `path` itself carries the attribute. A staged copy inherits it
    /// from the bundle it was copied from.
    static func isQuarantined(_ path: String) -> Bool {
        getxattr(path, quarantineAttribute, nil, 0, 0, XATTR_NOFOLLOW) >= 0
    }

    /// Why Gatekeeper would not let the image at `path` be opened, or nil when
    /// it accepts it. The assessment is of the image's own signature, as the
    /// dynamic loader's is.
    static func refusal(of path: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/spctl")
        process.arguments = [
            "--assess", "--type", "open", "--context", "context:primary-signature", "-v", path,
        ]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = output
        process.standardInput = FileHandle.nullDevice
        let finished = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in finished.signal() }
        do { try process.run() } catch {
            return "Gatekeeper could not be asked about it: \(error.localizedDescription)"
        }
        // The verdict is a few short lines, far inside a pipe's buffer, so it is
        // read after the process ends rather than while it runs.
        guard finished.wait(timeout: .now() + timeout) == .success else {
            process.terminate()
            return "Gatekeeper gave no verdict on it within \(Int(timeout)) seconds."
        }
        let text = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        // spctl(8): 0 when the assessment accepts, 3 when it rejects.
        switch process.terminationStatus {
        case 0: return nil
        case 3:
            let source = text.split(separator: "\n").first { $0.hasPrefix("source=") }
            return "Gatekeeper refuses it (\(source.map { String($0.dropFirst("source=".count)) } ?? "rejected"))."
        default:
            let said = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return "Gatekeeper could not assess it: \(said.isEmpty ? "spctl exited \(process.terminationStatus)" : said)"
        }
    }
}
