import Foundation
import KoineProviderAPI

@testable import WorkspaceProviderLogic

/// How a test arranges an application location: the object at a path, as the filesystem would answer for it.
/// Test vocabulary only; the provider reads a bundle by `readApplicationBundle(of:)`.
struct ApplicationBundle: Sendable {
    var url: URL
    /// Nil for a bundle that declares none.
    var bundleIdentifier: String?
    var identity: ObjectIdentity
}

enum ApplicationInspection: Sendable {
    /// Nothing at the path after symlink resolution: missing, or a dangling link.
    case absent
    /// Present, and not an application bundle.
    case notApplication
    case application(ApplicationBundle)
    /// The metadata could not be read; this is never absence.
    case unreadable(String)
}

/// The substituted private native adapter: every answer is set by the test, and
/// every call the provider makes is recorded, so "nothing was submitted" and
/// "nothing was inspected" are observed rather than inferred.
final class FakeNative: WorkspaceNative, @unchecked Sendable {
    private let lock = NSLock()
    private var defaultRegistered: [String: URL] = [:]
    private var allRegistered: [String: [URL]] = [:]
    private var inspections: [String: ApplicationInspection] = [:]
    private var starts: [Int32: [ProcessLookup]] = [:]
    private var executables: [Int32: ObjectIdentity] = [:]
    private var pendingCompletions: [@Sendable (LaunchCompletion) -> Void] = []
    private var launchLog: [(url: URL, substituting: Bool)] = []
    private var webHandlers: [WebURL.Scheme: URL] = [:]
    private var handlerLookupLog: [WebURL.Scheme] = []
    private var openLog: [(url: URL, application: URL)] = []
    private var pathInspections: [String: PathInspection] = [:]
    private var pathInspectionLog: [String] = []
    private var typeAncestors: [String: Set<String>] = [:]
    private var documentHandlers: [String: URL] = [:]
    private var documentLookupLog: [URL] = []
    private var pathOpenLog: [(url: URL, application: URL, substituting: Bool)] = []
    private var revealLog: [(path: String, root: Bool)] = []
    private var locations: [String: LocationResolution] = [:]
    private var locationLog: [String] = []
    private var roots: [String: FilesystemRootDecision] = [:]
    private var rootLog: [String] = []
    private var registrationLog: [String] = []
    private var bundleReadLog: [String] = []
    private var startReads: [Int32: Int] = [:]
    private var specialValues: [LocationPair: [String]] = [:]
    private var specialLookups: [LocationPair] = []
    /// What a submission (a launch or a URL open) does at once, if anything; the default
    /// holds the callback for the test.
    var onLaunch: (@Sendable (@escaping @Sendable (LaunchCompletion) -> Void) -> Void)?

    // MARK: Arrangement

    /// `listed: false` is a registration that Launch Services reports for the identifier's own
    /// lookup and leaves out of the list of every copy, as it does for a copy moved to the
    /// Trash (observed in docs/verification/application-installations-vm.md).
    func register(_ identifier: String, at url: URL, default isDefault: Bool = true, listed: Bool = true) {
        lock.withLock {
            if listed { allRegistered[identifier, default: []].append(url) }
            if isDefault { defaultRegistered[identifier] = url }
        }
    }

    func inspect(_ path: String, as result: ApplicationInspection) {
        lock.withLock { inspections[path] = result }
    }

    /// A present, registered copy at `path` under `identifier`, with the identity `file`.
    @discardableResult
    func install(_ identifier: String, at path: String, file: String, isDefault: Bool = true) -> ApplicationBundle {
        let bundle = ApplicationBundle(
            url: URL(fileURLWithPath: path), bundleIdentifier: identifier, identity: Self.identity(file)
        )
        register(identifier, at: URL(fileURLWithPath: path), default: isDefault)
        inspect(path, as: .application(bundle))
        return bundle
    }

    /// The default handler of `scheme`, as a present, registered application.
    @discardableResult
    func installBrowser(
        _ identifier: String = "com.apple.Safari", at path: String = "/Applications/Safari.app",
        schemes: [WebURL.Scheme] = [.http, .https]
    ) -> ApplicationBundle {
        let bundle = ApplicationBundle(
            url: URL(fileURLWithPath: path), bundleIdentifier: identifier, identity: Self.identity(path)
        )
        inspect(path, as: .application(bundle))
        lock.withLock { for scheme in schemes { webHandlers[scheme] = bundle.url } }
        return bundle
    }

    /// Changes (or removes) the registered default after it was asked about.
    func setWebHandler(_ scheme: WebURL.Scheme, to url: URL?) { lock.withLock { webHandlers[scheme] = url } }

    /// What the metadata says about `path`; an unarranged path is absent.
    func inspectPath(_ path: String, as result: PathInspection) {
        lock.withLock { pathInspections[path] = result }
    }

    /// What resolving `path` finds, whatever its metadata says. An unarranged path resolves as its
    /// metadata says (`inspectPath(_:as:)`, `document`): present as itself, absent or failed.
    func location(_ path: String, as resolution: LocationResolution) {
        lock.withLock { locations[path] = resolution }
    }

    /// What the walk finds at an application's `path` when it is not arranged with `location(_:as:)`: the
    /// application as `inspect(_:as:)` says. A present copy is the object its `identity` names
    /// (`identity(_:volume:)`: two spellings of one file are one inode), so every earlier arrangement of an
    /// installation resolves without further setup. An absent or unarranged path is absent.
    private func applicationLocation(_ path: String, _ inspection: ApplicationInspection?) -> LocationResolution {
        let spelling = Spelling(bytes: Array(path.utf8))
        func present(_ identity: ObjectIdentity, _ type: ObjectType, resolved: String? = nil) -> LocationResolution {
            .present(
                ResolvedLocation(
                    literal: spelling, expansions: [], resolved: resolved.map { Spelling(bytes: Array($0.utf8)) } ?? spelling,
                    identity: identity, type: type))
        }
        switch inspection {
        case .application(let bundle)?:
            return present(bundle.identity, .directory)
        case .notApplication?:
            return present(ObjectIdentity(device: 1, inode: UInt64(abs(path.hashValue)) | 1 << 40), .regularFile)
        case .unreadable(let reason)?: return .failed(component: path, cause: reason)
        case .absent?, nil: return .absent(.missing(component: path))
        }
    }

    /// What the root decision on the literal `path` answers; unarranged it is not the root.
    func filesystemRoot(_ path: String, as decision: FilesystemRootDecision) {
        lock.withLock { roots[path] = decision }
    }

    /// A present document or directory with the metadata given, and the types it conforms to.
    func document(
        _ path: String, directory: Bool = false, application: Bool = false, alias: Bool = false,
        type: String? = "public.plain-text", conformsTo: [String] = [], root: Bool = false
    ) {
        lock.withLock {
            pathInspections[path] = .present(
                PathFacts(isDirectory: directory, isApplication: application, isAliasFile: alias, contentType: type))
            if root { roots[path] = .root }
            if let type { typeAncestors[type, default: []].formUnion(conformsTo) }
        }
    }

    /// The default application for the document or directory at `path`, as a present, registered application.
    @discardableResult
    func installDocumentHandler(
        for path: String, _ identifier: String = "com.apple.TextEdit", at appPath: String = "/System/Applications/TextEdit.app"
    ) -> ApplicationBundle {
        let bundle = ApplicationBundle(
            url: URL(fileURLWithPath: appPath), bundleIdentifier: identifier, identity: Self.identity(appPath)
        )
        inspect(appPath, as: .application(bundle))
        lock.withLock { documentHandlers[URL(fileURLWithPath: path).path] = bundle.url }
        return bundle
    }

    /// Changes (or removes) the default for `path` after it was asked about.
    func setDocumentHandler(for path: String, to url: URL?) {
        lock.withLock { documentHandlers[URL(fileURLWithPath: path).path] = url }
    }

    func processStarts(_ pid: Int32, _ reads: [ProcessLookup]) { lock.withLock { starts[pid] = reads } }
    func executable(_ pid: Int32, _ identity: ObjectIdentity?) { lock.withLock { executables[pid] = identity } }

    /// The object a test calls `file`: the same name is always the same inode on a volume (FNV-1a over its bytes).
    static func identity(_ file: String, volume: Int = 1) -> ObjectIdentity {
        let inode = Array(file.utf8).reduce(UInt64(0xcbf2_9ce4_8422_2325)) { ($0 ^ UInt64($1)) &* 0x100_0000_01b3 }
        return ObjectIdentity(device: Int32(volume), inode: inode)
    }

    // MARK: Observation

    var launches: [(url: URL, substituting: Bool)] { lock.withLock { launchLog } }
    /// Every scheme the provider asked a default handler about, in order. The lookup has no
    /// other parameter, which is what makes it scheme-only.
    var handlerLookups: [WebURL.Scheme] { lock.withLock { handlerLookupLog } }
    var opens: [(url: URL, application: URL)] { lock.withLock { openLog } }
    /// Every resolved spelling whose metadata the provider read, in order.
    var pathInspected: [String] { lock.withLock { pathInspectionLog } }
    /// Every document or directory the provider asked a default application about, in order.
    var documentLookups: [URL] { lock.withLock { documentLookupLog } }
    var pathOpens: [(url: URL, application: URL, substituting: Bool)] { lock.withLock { pathOpenLog } }
    /// Every resolved spelling whose application bundle the provider read, in order.
    var bundleReads: [String] { lock.withLock { bundleReadLog } }
    /// Every identifier whose registration the provider asked Launch Services about, in order.
    var registrationLookups: [String] { lock.withLock { registrationLog } }
    /// Every location the provider asked to be resolved, in order.
    var resolved: [String] { lock.withLock { locationLog } }
    /// Every literal path the root decision was asked about, in order.
    var rootChecks: [String] { lock.withLock { rootLog } }
    /// Every path Finder was asked to select, in order.
    var reveals: [String] { lock.withLock { revealLog.map(\.path) } }
    /// Whether each reveal was the root view, in order.
    var revealedAsRoot: [Bool] { lock.withLock { revealLog.map(\.root) } }
    var completions: Int { lock.withLock { pendingCompletions.count } }

    /// Answers the `index`th submission's callback now, from the test's thread.
    func answer(_ index: Int = 0, with result: LaunchCompletion) {
        let completion = lock.withLock { pendingCompletions[index] }
        completion(result)
    }

    // MARK: WorkspaceNative

    func registeredApplication(bundleIdentifier: String) -> URL? {
        lock.withLock {
            registrationLog.append(bundleIdentifier)
            return defaultRegistered[bundleIdentifier]
        }
    }

    func registeredApplications(bundleIdentifier: String) -> [URL] {
        lock.withLock {
            registrationLog.append(bundleIdentifier)
            return allRegistered[bundleIdentifier] ?? []
        }
    }

    func launchApplication(
        at url: URL, substitutingRunningCopy: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        lock.withLock {
            launchLog.append((url, substitutingRunningCopy))
            pendingCompletions.append(completion)
        }
        onLaunch?(completion)
    }

    func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL? {
        lock.withLock {
            handlerLookupLog.append(scheme)
            return webHandlers[scheme]
        }
    }

    func openWebURL(
        _ url: URL, withApplicationAt application: URL, completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        lock.withLock {
            openLog.append((url, application))
            pendingCompletions.append(completion)
        }
        onLaunch?(completion)
    }

    func readPathFacts(of location: ResolvedLocation) -> PathInspection {
        let path = location.resolved.text
        return lock.withLock {
            pathInspectionLog.append(path)
            return pathInspections[path] ?? .absent
        }
    }

    func resolveLocation(_ path: String) -> LocationResolution {
        lock.withLock {
            locationLog.append(path)
            if let arranged = locations[path] { return arranged }
            switch pathInspections[path] {
            case .present(let facts)?:
                let spelling = Spelling(bytes: Array(path.utf8))
                return .present(
                    ResolvedLocation(
                        literal: spelling, expansions: [], resolved: spelling,
                        identity: ObjectIdentity(device: 1, inode: UInt64(abs(path.hashValue))),
                        type: facts.isDirectory ? .directory : .regularFile))
            case .unreadable(let reason)?: return .failed(component: path, cause: reason)
            case .absent?, nil: return applicationLocation(path, inspections[path])
            }
        }
    }

    func readApplicationBundle(of location: ResolvedLocation) -> BundleRead {
        let path = location.resolved.text
        return lock.withLock {
            bundleReadLog.append(path)
            switch inspections[path] {
            case .application(let bundle)?: return .application(identifier: bundle.bundleIdentifier)
            case .notApplication?: return .notApplication
            case .unreadable(let reason)?: return .unreadable(reason)
            case .absent?, nil: return .unreadable("its metadata reports nothing there")
            }
        }
    }

    func isFilesystemRoot(literalPath path: String) -> FilesystemRootDecision {
        lock.withLock {
            rootLog.append(path)
            return roots[path] ?? .notRoot
        }
    }

    func contentType(_ identifier: String, conformsTo ancestor: String) -> Bool {
        lock.withLock { identifier == ancestor || typeAncestors[identifier]?.contains(ancestor) == true }
    }

    func defaultApplication(toOpen url: URL) -> URL? {
        lock.withLock {
            documentLookupLog.append(url)
            return documentHandlers[url.path]
        }
    }

    func openPath(
        _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
        completion: @escaping @Sendable (LaunchCompletion) -> Void
    ) {
        lock.withLock {
            pathOpenLog.append((url, application, substitutingRunningCopy))
            pendingCompletions.append(completion)
        }
        onLaunch?(completion)
    }

    func revealPath(_ path: String, filesystemRoot: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void) {
        lock.withLock {
            revealLog.append((path, filesystemRoot))
            pendingCompletions.append(completion)
        }
        onLaunch?(completion)
    }

    /// What Foundation gives for a named location; an unarranged one gives nothing.
    func locationValues(_ pair: LocationPair, _ values: [String]) {
        lock.withLock { specialValues[pair] = values }
    }

    /// The locations asked for, in order: a lookup is the only thing a special-locations query does.
    var specialLocationLog: [LocationPair] { lock.withLock { specialLookups } }

    func specialLocationValues(_ pair: LocationPair) -> [String] {
        lock.withLock {
            specialLookups.append(pair)
            return specialValues[pair] ?? []
        }
    }

    func accountIdentifier() -> String { "501" }

    func processStart(of pid: Int32) -> ProcessLookup {
        lock.withLock {
            let reads = starts[pid] ?? [.absent]
            let index = startReads[pid, default: 0]
            startReads[pid] = index + 1
            return reads[min(index, reads.count - 1)]
        }
    }

    func liveExecutableIdentity(of pid: Int32) -> ObjectIdentity? { lock.withLock { executables[pid] } }
}

/// The application object a callback delivers, every observable set by the test.
/// The observation rule reads the PID and the terminated state twice, before and
/// after its kernel reads, so each is a sequence: the last value repeats.
final class FakeApplication: LaunchedApplication, @unchecked Sendable {
    private let lock = NSLock()
    private let pidSequence: [Int32]
    private let terminatedSequence: [Bool]
    private var pidReads = 0
    private var terminatedReads = 0
    var executable: ObjectIdentity?
    var freshEqual = true
    /// The number of fresh lookups that find something else before one is equal.
    var freshLookupsUnequal = 0
    private var freshLookups = 0

    init(pids: [Int32] = [4242], terminated: [Bool] = [false], executable: ObjectIdentity? = FakeNative.identity("exe")) {
        pidSequence = pids
        terminatedSequence = terminated
        self.executable = executable
    }

    var processIdentifier: Int32 {
        lock.withLock {
            defer { pidReads += 1 }
            return pidSequence[min(pidReads, pidSequence.count - 1)]
        }
    }

    var isTerminated: Bool {
        lock.withLock {
            defer { terminatedReads += 1 }
            return terminatedSequence[min(terminatedReads, terminatedSequence.count - 1)]
        }
    }

    var executableIdentity: ObjectIdentity? { executable }
    func freshLookupEqualsSelf(pid: Int32) -> Bool {
        lock.withLock {
            freshLookups += 1
            return freshEqual && freshLookups > freshLookupsUnequal
        }
    }
}
