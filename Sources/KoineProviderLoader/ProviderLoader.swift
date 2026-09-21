import Foundation
import KoineProviderAPI
import ObjectiveC

/// What the host supplies to providers: the version of the framework it
/// bundles, and its feature set. The framework ships inside Koine, so the host
/// states its version; a test holds it equal to ProviderAPI/Info.plist.
public struct HostCompatibility: Sendable {
    /// Version 1 supports exactly this framework major.
    public static let frameworkMajor = 1
    public static let frameworkMinor = 0

    public let frameworkMajor: Int
    public let frameworkMinor: Int
    public let features: Set<String>

    public init(features: Set<String>) {
        self.init(
            frameworkMajor: Self.frameworkMajor, frameworkMinor: Self.frameworkMinor,
            features: features
        )
    }

    init(frameworkMajor: Int, frameworkMinor: Int, features: Set<String>) {
        self.frameworkMajor = frameworkMajor
        self.frameworkMinor = frameworkMinor
        self.features = features
    }
}

public struct LoadedProvider: Sendable {
    public let descriptor: ProviderDescriptor
    public let provider: any Provider
}

/// What became of one bundle found in a root. Every bundle has a report,
/// loaded or not.
public struct ProviderBundleReport: Sendable {
    public enum Outcome: Sendable {
        case loaded(LoadedProvider)
        /// An honest bundle this host cannot run. None of its code was loaded.
        case incompatible(String)
        /// A malformed, contradictory or unloadable bundle. It contributes
        /// nothing; if its initializers ran, its image stays mapped.
        case rejected(String)
    }

    /// The manifest's provider identifier, or the bundle's name without one.
    public let provider: String
    public let version: String
    public let schemaVersion: String
    public let outcome: Outcome
}

/// The native loader. It considers every `*.koineprovider` bundle directly
/// inside a root the host was configured with; it searches nowhere else. Every
/// check that can be made without running the bundle's code precedes `dlopen`,
/// and every one after the first is made of the staged copy that is loaded.
public enum ProviderLoader {
    public static let bundleExtension = "koineprovider"

    static let frameworkName = "KoineProviderAPI"
    static let frameworkInstallName =
        "@rpath/KoineProviderAPI.framework/Versions/A/KoineProviderAPI"
    /// The protocol descriptors of `Provider` and `ProviderFactory`. Only an
    /// image that is the framework defines them; an extension of a framework
    /// type, which a plugin may declare, does not.
    static let frameworkOwnSymbols: Set<String> = [
        "_$s16KoineProviderAPI0B0Mp", "_$s16KoineProviderAPI0B7FactoryMp",
    ]

    /// A root that does not exist holds no bundles; one that exists and cannot
    /// be read throws. Bundles are staged under `staging` before they are
    /// verified or loaded.
    public static func loadProviders(
        in root: ProviderRoot, staging: URL, host: HostCompatibility
    ) throws -> [ProviderBundleReport] {
        guard FileManager.default.fileExists(atPath: root.location.path) else { return [] }
        return try FileManager.default
            .contentsOfDirectory(at: root.location, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == bundleExtension }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { report(bundle: $0, in: root, staging: staging, host: host) }
    }

    private struct Refusal: Error {
        let outcome: ProviderBundleReport.Outcome

        static func incompatible(_ reason: String) -> Refusal { Refusal(outcome: .incompatible(reason)) }
        static func rejected(_ reason: String) -> Refusal { Refusal(outcome: .rejected(reason)) }
    }

    private static func report(
        bundle: URL, in root: ProviderRoot, staging: URL, host: HostCompatibility
    ) -> ProviderBundleReport {
        func unidentified(_ reason: String) -> ProviderBundleReport {
            ProviderBundleReport(
                provider: bundle.deletingPathExtension().lastPathComponent, version: "unknown",
                schemaVersion: "unknown", outcome: .rejected(reason)
            )
        }
        // A link out of the root is a bundle from somewhere Koine does not own.
        guard let rootPath = canonicalPath(root.location.path),
            let installed = canonicalPath(bundle.path), installed.hasPrefix(rootPath + "/")
        else { return unidentified("The bundle's location resolves outside its provider root.") }
        guard let staged = try? ProviderStaging.stage(bundleAt: installed, under: staging) else {
            return unidentified("The bundle could not be staged for verification.")
        }
        let manifest: ProviderManifest
        do { manifest = try ProviderManifest(bundle: staged) } catch {
            return unidentified(
                (error as? ProviderManifest.Invalid)?.reason ?? "manifest.json is malformed."
            )
        }
        let outcome: ProviderBundleReport.Outcome
        do {
            // Trust before anything else the bundle says is believed.
            let approval = try approval(for: manifest, in: root)
            try checkSignature(of: staged.path, named: "The bundle", approvedBy: approval)
            try checkCompatibility(of: manifest, with: host)
            let (library, images) = try verifiedLibrary(of: manifest, in: staged)
            // The seal names a nested image by hash, which says who sealed it,
            // not who signed it: each image answers for itself.
            for image in images.sorted() {
                try checkSignature(
                    of: image, named: (image as NSString).lastPathComponent, approvedBy: approval
                )
            }
            // The bundled root's quarantine is the application's, judged when
            // it was first opened.
            if !root.isBundled {
                try checkGatekeeper(images, installed: installed, staged: staged.path)
            }
            try checkPrincipalNameIsFree(manifest.principalClass, for: library)
            outcome = .loaded(try load(library, manifest: manifest))
        } catch let refusal as Refusal {
            outcome = refusal.outcome
        } catch {
            outcome = .rejected("The bundle could not be checked.")
        }
        return ProviderBundleReport(
            provider: manifest.providerId, version: manifest.version,
            schemaVersion: manifest.schemaVersion, outcome: outcome
        )
    }

    // MARK: Before dlopen

    private static func approval(
        for manifest: ProviderManifest, in root: ProviderRoot
    ) throws -> ProviderApproval {
        do { return try root.approval(for: manifest.providerId) } catch {
            throw Refusal.rejected(
                (error as? ProviderRoot.Unapproved)?.reason ?? "The provider is not approved."
            )
        }
    }

    private static func checkSignature(
        of path: String, named name: String, approvedBy approval: ProviderApproval
    ) throws {
        if let reason = CodeSignature.refusal(of: path, approvedBy: approval) {
            throw Refusal.rejected("\(name) is refused: \(reason)")
        }
    }

    /// A quarantined image Gatekeeper would refuse is refused here, before
    /// `dlopen` raises the platform's modal dialog for it. The loader never
    /// clears the attribute; the diagnostic says who can.
    private static func checkGatekeeper(
        _ images: Set<String>, installed: String, staged: String
    ) throws {
        for image in images.sorted() where Gatekeeper.isQuarantined(image) {
            guard let reason = Gatekeeper.refusal(of: image) else { continue }
            throw Refusal.rejected(
                "\((image as NSString).lastPathComponent) is quarantined and \(reason) macOS would refuse to load it. Its author can notarize it; or clear the attribute with `xattr -dr \(Gatekeeper.quarantineAttribute) \(quoted(installed))` and, with Koine stopped, delete its staged copy with `chmod -R u+w \(quoted(staged)) && rm -rf \(quoted(staged))`."
            )
        }
    }

    /// A path as one shell word: the per-user root is under "Application Support".
    private static func quoted(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    /// What the manifest asks of the host. A negotiation after loading cannot
    /// rescue a binary already linked against symbols the host lacks.
    private static func checkCompatibility(
        of manifest: ProviderManifest, with host: HostCompatibility
    ) throws {
        guard manifest.framework.major == host.frameworkMajor else {
            throw Refusal.incompatible(
                "The provider requires provider framework major \(manifest.framework.major); this Koine supplies major \(host.frameworkMajor)."
            )
        }
        guard manifest.framework.minimumMinor <= host.frameworkMinor else {
            throw Refusal.incompatible(
                "The provider requires provider framework \(manifest.framework.major).\(manifest.framework.minimumMinor) or later; this Koine supplies \(host.frameworkMajor).\(host.frameworkMinor)."
            )
        }
        let missing = Set(manifest.requiredFeatures).subtracting(host.features).sorted()
        guard missing.isEmpty else {
            throw Refusal.incompatible(
                "The provider requires host features this Koine lacks: \(missing.joined(separator: ", "))."
            )
        }
        guard manifest.architectures.contains(HostPlatform.architecture) else {
            throw Refusal.incompatible(
                "The provider is built for \(manifest.architectures.joined(separator: ", ")); this Koine runs as \(HostPlatform.architecture)."
            )
        }
        // Validated when the manifest was read.
        let minimumOS = MachOImage.Version(manifest.minimumOS)!
        guard minimumOS <= HostPlatform.operatingSystem else {
            throw Refusal.incompatible(
                "The provider requires macOS \(minimumOS); this is macOS \(HostPlatform.operatingSystem)."
            )
        }
        let minimumRuntime = MachOImage.Version(manifest.minimumSwiftRuntime)!
        guard minimumRuntime <= HostPlatform.swiftRuntime else {
            throw Refusal.incompatible(
                "The provider requires Swift runtime \(minimumRuntime); macOS \(HostPlatform.operatingSystem) supplies \(HostPlatform.swiftRuntime)."
            )
        }
    }

    /// The canonical path of the bundle's library, and of every image in its
    /// dependency closure inside the bundle, once the binary has been shown to
    /// match the manifest and to depend only on what it may.
    private static func verifiedLibrary(
        of manifest: ProviderManifest, in bundle: URL
    ) throws -> (library: String, images: Set<String>) {
        guard let bundlePath = canonicalPath(bundle.path) else {
            throw Refusal.rejected("The bundle's location cannot be resolved.")
        }
        if let copy = try frameworkCopy(in: bundlePath) {
            throw Refusal.rejected(
                "The bundle contains its own copy of the provider framework (\(copy)); a provider links the one Koine supplies."
            )
        }
        let library = try path(manifest.library, from: bundlePath, inside: bundlePath, what: "library")
        let image = try machO(at: library, named: manifest.library)
        let held = image.slices.map(\.architecture)
        guard Set(held) == Set(manifest.architectures) else {
            throw Refusal.rejected(
                "The manifest declares \(manifest.architectures.joined(separator: ", ")) but \(manifest.library) holds \(held.joined(separator: ", "))."
            )
        }
        let slice = try hostSlice(of: image, named: manifest.library)
        if let built = slice.minimumOS, built > MachOImage.Version(manifest.minimumOS)! {
            throw Refusal.rejected(
                "The manifest declares macOS \(manifest.minimumOS) but \(manifest.library) was built for macOS \(built) or later."
            )
        }
        guard slice.dependencies.contains(frameworkInstallName) else {
            throw Refusal.rejected(
                "\(manifest.library) does not link the provider framework Koine supplies (\(frameworkInstallName))."
            )
        }
        var validated: Set<String> = []
        try checkDependencies(
            of: slice, at: library, named: manifest.library, inside: bundlePath,
            validated: &validated
        )
        return (library, validated)
    }

    /// Every dependency is the host's framework image, a system library or a
    /// validated private dependency inside the bundle.
    private static func checkDependencies(
        of slice: MachOImage.Slice, at imagePath: String, named name: String,
        inside bundlePath: String, validated: inout Set<String>
    ) throws {
        guard validated.insert(imagePath).inserted else { return }
        guard slice.definedExternalSymbols.isDisjoint(with: frameworkOwnSymbols) else {
            throw Refusal.rejected(
                "\(name) defines the provider framework's own symbols: it carries a statically linked copy."
            )
        }
        for runPath in slice.runPaths where !isSystemPath(runPath) {
            _ = try path(runPath, from: imagePath, inside: bundlePath, what: "run path")
        }
        for dependency in slice.dependencies {
            if dependency == frameworkInstallName || isSystemPath(dependency) { continue }
            guard (dependency as NSString).lastPathComponent != frameworkName else {
                throw Refusal.rejected(
                    "\(name) links a substitute for the provider framework: \(dependency)."
                )
            }
            let resolved = try path(dependency, from: imagePath, inside: bundlePath, what: "dependency")
            let image = try machO(at: resolved, named: dependency)
            try checkDependencies(
                of: try hostSlice(of: image, named: dependency), at: resolved, named: dependency,
                inside: bundlePath, validated: &validated
            )
        }
    }

    private static func isSystemPath(_ path: String) -> Bool {
        let components = (path as NSString).pathComponents
        guard !components.contains("..") else { return false }
        return path.hasPrefix("/usr/lib/") || path.hasPrefix("/System/Library/")
    }

    /// A path the bundle names, resolved to an existing file or directory that
    /// is canonically inside the bundle. `@loader_path` is the naming image's
    /// directory; a bare relative path is relative to the bundle.
    private static func path(
        _ named: String, from origin: String, inside bundlePath: String, what: String
    ) throws -> String {
        let loaderPrefix = "@loader_path"
        let candidate: String
        if named == loaderPrefix || named.hasPrefix(loaderPrefix + "/") {
            candidate = (origin as NSString).deletingLastPathComponent + named.dropFirst(loaderPrefix.count)
        } else if what == "library", !named.hasPrefix("/"), !named.hasPrefix("@") {
            candidate = (bundlePath as NSString).appendingPathComponent(named)
        } else {
            throw Refusal.rejected(
                "The \(what) \(named) is neither a system library, the provider framework nor inside the bundle."
            )
        }
        guard let resolved = canonicalPath(candidate) else {
            throw Refusal.rejected("The \(what) \(named) does not exist.")
        }
        guard resolved == bundlePath || resolved.hasPrefix(bundlePath + "/") else {
            throw Refusal.rejected("The \(what) \(named) resolves outside the bundle.")
        }
        return resolved
    }

    private static func machO(at path: String, named name: String) throws -> MachOImage {
        do { return try MachOImage(contentsOf: URL(fileURLWithPath: path)) } catch {
            let reason = (error as? MachOImage.Malformed)?.reason ?? "it cannot be read"
            throw Refusal.rejected("\(name) is not a loadable image: \(reason).")
        }
    }

    private static func hostSlice(of image: MachOImage, named name: String) throws -> MachOImage.Slice {
        let slices = image.slices.filter { $0.architecture == HostPlatform.architecture }
        guard let slice = slices.first else {
            throw Refusal.rejected("\(name) holds no \(HostPlatform.architecture) image.")
        }
        // Which of two the dynamic loader maps is its choice; what was checked
        // must be what is mapped.
        guard slices.count == 1 else {
            throw Refusal.rejected("\(name) holds more than one \(HostPlatform.architecture) image.")
        }
        return slice
    }

    /// Anything in the bundle named as the framework is named: a plugin must
    /// not embed another copy, whatever its run paths say.
    /// Names are compared without case, as the file system compares them.
    private static func frameworkCopy(in bundlePath: String) throws -> String? {
        guard let entries = try? FileManager.default.subpathsOfDirectory(atPath: bundlePath) else {
            throw Refusal.rejected("The bundle's contents cannot be listed.")
        }
        let names = [frameworkName.lowercased(), "\(frameworkName).framework".lowercased()]
        return entries.first { names.contains(($0 as NSString).lastPathComponent.lowercased()) }
    }

    /// realpath(3): `URL.resolvingSymlinksInPath` rewrites `/private` away, so
    /// it does not compare equal to the path dyld reports.
    private static func canonicalPath(_ path: String) -> String? {
        guard let resolved = realpath(path, nil) else { return nil }
        defer { free(resolved) }
        return String(cString: resolved)
    }

    /// A principal name another image has already registered is a collision,
    /// and is known before loading. The same image already loaded, by an
    /// earlier server in this process, is not one.
    private static func checkPrincipalNameIsFree(_ name: String, for library: String) throws {
        guard let existing = objc_lookUpClass(name) else { return }
        guard imagePath(of: existing) == library else {
            throw Refusal.rejected(
                "The principal class name \(name) is already registered by another image."
            )
        }
    }

    private static func imagePath(of type: AnyClass) -> String? {
        class_getImageName(type).flatMap { canonicalPath(String(cString: $0)) }
    }

    // MARK: dlopen and after

    private static func load(_ library: String, manifest: ProviderManifest) throws -> LoadedProvider {
        // An absolute path: dlopen never searches for a provider. The image is
        // never closed; a loaded provider stays mapped until process exit,
        // whatever becomes of it below.
        guard dlopen(library, RTLD_NOW | RTLD_LOCAL) != nil else {
            let reason = dlerror().map { String(cString: $0) } ?? "unknown"
            throw Refusal.rejected("The dynamic loader refused \(manifest.library): \(reason)")
        }
        // https://developer.apple.com/documentation/foundation/nsclassfromstring(_:)
        guard let principal = NSClassFromString(manifest.principalClass) else {
            throw Refusal.rejected(
                "\(manifest.library) registers no class named \(manifest.principalClass)."
            )
        }
        guard imagePath(of: principal) == library else {
            throw Refusal.rejected(
                "The principal class \(manifest.principalClass) does not originate in \(manifest.library)."
            )
        }
        guard let factoryType = principal as? any ProviderFactory.Type else {
            throw Refusal.rejected(
                "The principal class \(manifest.principalClass) does not conform to ProviderFactory."
            )
        }
        let factory = factoryType.init()
        let descriptor = factory.descriptor
        guard descriptor.providerId == manifest.providerId,
            descriptor.graphQLPrefix == manifest.graphQLPrefix,
            Set(descriptor.requiredFeatures) == Set(manifest.requiredFeatures)
        else {
            throw Refusal.rejected(
                "The provider's runtime descriptor disagrees with its manifest about its identifier, prefix or required features."
            )
        }
        return LoadedProvider(descriptor: descriptor, provider: factory.makeProvider())
    }
}

/// The platform this process runs on, as the manifest's requirements name it.
enum HostPlatform {
    static var architecture: String {
        #if arch(arm64)
            "arm64"
        #elseif arch(x86_64)
            "x86_64"
        #else
            "unsupported"
        #endif
    }

    static var operatingSystem: MachOImage.Version {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return MachOImage.Version([version.majorVersion, version.minorVersion, version.patchVersion])
    }

    /// On macOS the Swift runtime is an OS component and nothing reports its
    /// version, so it follows from the OS. The Swift project's own table:
    /// https://github.com/swiftlang/swift/blob/main/utils/availability-macros.def
    /// (the `SwiftStdlib` lines; read 2026-09-19). An OS newer than the table
    /// supplies at least its last entry.
    static var swiftRuntime: MachOImage.Version {
        let table: [(os: [Int], runtime: [Int])] = [
            ([13, 0], [5, 7]), ([13, 3], [5, 8]), ([14, 0], [5, 9]), ([14, 4], [5, 10]),
            ([15, 0], [6, 0]), ([15, 4], [6, 1]), ([26, 0], [6, 2]), ([26, 4], [6, 3]),
            ([27, 0], [6, 4]),
        ]
        let os = operatingSystem
        let supplied = table.last { MachOImage.Version($0.os) <= os }
        return MachOImage.Version(supplied?.runtime ?? [5, 7])
    }
}
