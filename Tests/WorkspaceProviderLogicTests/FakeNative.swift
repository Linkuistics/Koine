import Foundation
import KoineProviderAPI

@testable import WorkspaceProviderLogic

/// The substituted private native adapter: every answer is set by the test, and
/// every call the provider makes is recorded, so "nothing was submitted" and
/// "nothing was inspected" are observed rather than inferred.
final class FakeNative: WorkspaceNative, @unchecked Sendable {
    private let lock = NSLock()
    private var defaultRegistered: [String: URL] = [:]
    private var allRegistered: [String: [URL]] = [:]
    private var inspections: [String: ApplicationInspection] = [:]
    private var starts: [Int32: [ProcessLookup]] = [:]
    private var executables: [Int32: FileIdentity] = [:]
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
    private var inspectionLog: [String] = []
    private var revealLog: [(path: String, root: Bool)] = []
    private var startReads: [Int32: Int] = [:]
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

    /// A present document or directory with the metadata given, and the types it conforms to.
    func document(
        _ path: String, directory: Bool = false, application: Bool = false, alias: Bool = false,
        type: String? = "public.plain-text", conformsTo: [String] = [], root: Bool = false
    ) {
        lock.withLock {
            pathInspections[path] = .present(
                PathFacts(
                    isDirectory: directory, isApplication: application, isAliasFile: alias, contentType: type,
                    isFilesystemRoot: root))
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
    func executable(_ pid: Int32, _ identity: FileIdentity?) { lock.withLock { executables[pid] = identity } }

    static func identity(_ file: String, volume: Int = 1) -> FileIdentity {
        FileIdentity(volume: NSNumber(value: volume), file: file as NSString)
    }

    // MARK: Observation

    var launches: [(url: URL, substituting: Bool)] { lock.withLock { launchLog } }
    var inspected: [String] { lock.withLock { inspectionLog } }
    /// Every scheme the provider asked a default handler about, in order. The lookup has no
    /// other parameter, which is what makes it scheme-only.
    var handlerLookups: [WebURL.Scheme] { lock.withLock { handlerLookupLog } }
    var opens: [(url: URL, application: URL)] { lock.withLock { openLog } }
    /// Every path whose metadata the provider read, in order.
    var pathInspected: [String] { lock.withLock { pathInspectionLog } }
    /// Every document or directory the provider asked a default application about, in order.
    var documentLookups: [URL] { lock.withLock { documentLookupLog } }
    var pathOpens: [(url: URL, application: URL, substituting: Bool)] { lock.withLock { pathOpenLog } }
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
        lock.withLock { defaultRegistered[bundleIdentifier] }
    }

    func registeredApplications(bundleIdentifier: String) -> [URL] {
        lock.withLock { allRegistered[bundleIdentifier] ?? [] }
    }

    func inspectApplication(at path: String) -> ApplicationInspection {
        lock.withLock {
            inspectionLog.append(path)
            return inspections[path] ?? .absent
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

    func inspectPath(_ path: String) -> PathInspection {
        lock.withLock {
            pathInspectionLog.append(path)
            return pathInspections[path] ?? .absent
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

    func processStart(of pid: Int32) -> ProcessLookup {
        lock.withLock {
            let reads = starts[pid] ?? [.absent]
            let index = startReads[pid, default: 0]
            startReads[pid] = index + 1
            return reads[min(index, reads.count - 1)]
        }
    }

    func liveExecutableIdentity(of pid: Int32) -> FileIdentity? { lock.withLock { executables[pid] } }
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
    var executable: FileIdentity?
    var freshEqual = true
    /// The number of fresh lookups that find something else before one is equal.
    var freshLookupsUnequal = 0
    private var freshLookups = 0

    init(pids: [Int32] = [4242], terminated: [Bool] = [false], executable: FileIdentity? = FakeNative.identity("exe")) {
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

    var executableIdentity: FileIdentity? { executable }
    func freshLookupEqualsSelf(pid: Int32) -> Bool {
        lock.withLock {
            freshLookups += 1
            return freshEqual && freshLookups > freshLookupsUnequal
        }
    }
}
