import CryptoKit
import Foundation

/// Staging: the loader verifies and loads an immutable copy of a bundle, never
/// the installed bundle itself, so an update written while Koine starts cannot
/// change what was checked (docs/specs/machine.md, "Loading and trust").
///
/// A copy belongs to one candidate: it is named by the bundle's name and a digest
/// of the physical origin, the canonical installed location and the content. An
/// unchanged candidate reuses its copy, and so its dyld image path; an update is a
/// new copy beside the old. Equal bytes or equal names in different candidates
/// never share a copy, so one candidate's quarantine is never inherited by
/// another, and no entry the earlier content-only naming left behind can be
/// reused: its name is not one this scheme produces
/// (docs/specs/machine.md, "Selection before execution"). The copy's signature is
/// verified on every start, and the per-user quarantine assessment is made of the
/// copy that loads on every start, so reuse trusts nothing about it.
package enum ProviderStaging {
    struct Failed: Error {}

    /// Copies the bundle at `bundlePath` under `staging` and returns the copy.
    static func stage(
        bundleAt bundlePath: String, origin: ProviderCandidateReport.Origin, under staging: URL
    ) throws -> URL {
        let files = FileManager.default
        try files.createDirectory(
            at: staging, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700]
        )
        let incoming = staging.appendingPathComponent(".incoming-\(UUID().uuidString)")
        // Extended attributes come with the copy; quarantine is never stripped.
        try files.copyItem(atPath: bundlePath, toPath: incoming.path)
        let staged: URL
        do {
            // Had the installed bundle become a link since its location was
            // resolved, the copy would be that link.
            guard isDirectory(incoming) else { throw Failed() }
            // The digest is of the copy: what is named is what will be checked.
            staged = staging.appendingPathComponent(
                try stagedName(of: incoming, from: bundlePath, origin: origin)
            )
            if !files.fileExists(atPath: staged.path) {
                try setWritable(false, under: incoming)
                // Fails when another server staged the same content first.
                try? files.moveItem(at: incoming, to: staged)
            }
        } catch {
            discard(incoming)
            throw error
        }
        discard(incoming)
        guard isDirectory(staged) else { throw Failed() }
        return staged
    }

    /// A directory itself, not a link to one.
    private static func isDirectory(_ url: URL) -> Bool {
        let kind = try? FileManager.default.attributesOfItem(atPath: url.path)[.type]
        return kind as? FileAttributeType == .typeDirectory
    }

    /// `bundle` is the content to digest; `bundlePath` is the canonical installed
    /// location it was copied from.
    package static func stagedName(
        of bundle: URL, from bundlePath: String, origin: ProviderCandidateReport.Origin
    ) throws -> String {
        let name = ((bundlePath as NSString).lastPathComponent as NSString).deletingPathExtension
        let identity = SHA256.hash(
            data: Data("\(origin.rawValue)\0\(bundlePath)\0\(try digest(of: bundle))".utf8)
        )
        return "\(name)-" + identity.prefix(16).map { String(format: "%02x", $0) }.joined()
    }

    /// SHA-256 over every entry's path, kind and content, and whether a file is
    /// executable, in path order.
    static func digest(of bundle: URL) throws -> String {
        let files = FileManager.default
        var hash = SHA256()
        for entry in try files.subpathsOfDirectory(atPath: bundle.path).sorted() {
            let path = bundle.appendingPathComponent(entry).path
            let attributes = try files.attributesOfItem(atPath: path)
            let kind = attributes[.type] as? FileAttributeType
            let mode = (attributes[.posixPermissions] as? NSNumber)?.intValue ?? 0
            hash.update(data: Data("\(entry)\0".utf8))
            switch kind {
            case .typeDirectory: hash.update(data: Data("d\0".utf8))
            case .typeSymbolicLink:
                hash.update(data: Data("l\(try files.destinationOfSymbolicLink(atPath: path))\0".utf8))
            case .typeRegular:
                let content = try Data(contentsOf: URL(fileURLWithPath: path))
                hash.update(data: Data("f\(mode & 0o111 == 0 ? "-" : "x")\(content.count)\0".utf8))
                hash.update(data: content)
            default: throw Failed()
            }
        }
        return hash.finalize().prefix(16).map { String(format: "%02x", $0) }.joined()
    }

    private static func setWritable(_ writable: Bool, under directory: URL) throws {
        let files = FileManager.default
        for entry in [""] + (try files.subpathsOfDirectory(atPath: directory.path)) {
            let path = directory.appendingPathComponent(entry).path
            let attributes = try files.attributesOfItem(atPath: path)
            // chmod follows a link, and a link's target is an entry of its own.
            guard attributes[.type] as? FileAttributeType != .typeSymbolicLink,
                let mode = (attributes[.posixPermissions] as? NSNumber)?.intValue
            else { continue }
            try files.setAttributes(
                [.posixPermissions: writable ? mode | 0o200 : mode & ~0o222], ofItemAtPath: path
            )
        }
    }

    private static func discard(_ incoming: URL) {
        guard FileManager.default.fileExists(atPath: incoming.path) else { return }
        try? setWritable(true, under: incoming)
        try? FileManager.default.removeItem(at: incoming)
    }
}
