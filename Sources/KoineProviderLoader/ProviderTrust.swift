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
    enum Approvals: Sendable {
        case builtIn([ProviderApproval])
        case recordsInRoot
    }

    public let location: URL
    let approvals: Approvals

    /// The root sealed inside the application bundle. Its approval records are
    /// the host's own, sealed by the application signature with the rest of it.
    public static func bundled(_ location: URL, approvals: [ProviderApproval]) -> ProviderRoot {
        ProviderRoot(location: location, approvals: .builtIn(approvals))
    }

    /// The per-user installed root. Its approval records are files the user
    /// places beside the bundles; Koine writes none.
    public static func installed(_ location: URL) -> ProviderRoot {
        ProviderRoot(location: location, approvals: .recordsInRoot)
    }

    public static func approvalRecordName(for providerId: String) -> String {
        "\(providerId).approval.json"
    }

    struct Unapproved: Error {
        let reason: String
    }

    func approval(for providerId: String) throws -> ProviderApproval {
        let found: ProviderApproval
        switch approvals {
        case .builtIn(let records):
            guard let record = records.first(where: { $0.providerId == providerId }) else {
                throw Unapproved(reason: "This Koine has no built-in approval for provider \(providerId).")
            }
            found = record
        case .recordsInRoot:
            let name = Self.approvalRecordName(for: providerId)
            // The identifier names a file: it must not name a path.
            guard !providerId.contains("/"), !providerId.hasPrefix("."),
                let data = try? Data(contentsOf: location.appendingPathComponent(name))
            else {
                throw Unapproved(
                    reason: "Provider \(providerId) is not approved: there is no \(name) in the provider root."
                )
            }
            guard let record = try? JSONDecoder().decode(ProviderApproval.self, from: data),
                record.providerId == providerId
            else {
                throw Unapproved(
                    reason: "\(name) is not an approval record for provider \(providerId)."
                )
            }
            found = record
        }
        guard found.hasWellFormedTeamIdentifier else {
            throw Unapproved(
                reason: "The approval record for provider \(providerId) does not name a Team ID."
            )
        }
        return found
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
