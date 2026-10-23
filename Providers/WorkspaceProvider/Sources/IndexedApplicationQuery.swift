import Foundation

/// One run of the fixed application query over the Spotlight index: the application-bundle content-type-tree
/// equality, the indexed local computer scope and the four-attribute projection of the search spec
/// ("Application sources and native facts"). The query lives on a private serial operation queue and nowhere
/// else. The SDK says `startQuery` "must be called from the receiver's operationQueue or on the main thread"
/// (NSMetadata.h, Foundation, macOS SDK), and a pool thread has no run loop to deliver notifications to.
/// The finished-gathering notification arrives on that queue. There the items are counted and copied with
/// updates disabled, and then the query stops. The signed-bundle and VM seams exercise it, not the
/// provider-local tests.
final class IndexedApplicationQuery: @unchecked Sendable {
    private let operations = OperationQueue()
    private let query = NSMetadataQuery()
    private let finished = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var outcome: IndexedApplicationsRead?
    private let limit: Int

    private init(limit: Int) {
        self.limit = limit
        operations.name = "dev.antony.Koine.provider.workspace.index"
        operations.maxConcurrentOperationCount = 1
        query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
        query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
        query.operationQueue = operations
    }

    /// Runs the query and blocks until its initial gathering finishes or `wait` ends, whichever is first.
    static func read(limit: Int, wait: Duration) -> IndexedApplicationsRead {
        let run = IndexedApplicationQuery(limit: limit)
        return run.run(wait: wait)
    }

    private func run(wait: Duration) -> IndexedApplicationsRead {
        let token = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering, object: query, queue: operations
        ) { [self] _ in gathered() }
        defer { NotificationCenter.default.removeObserver(token) }
        operations.addOperation { [self] in
            if !query.start() { settle(.failed("Spotlight did not start the query.")) }
        }
        let seconds = Double(wait.components.seconds) + Double(wait.components.attoseconds) / 1e18
        if finished.wait(timeout: .now() + seconds) == .timedOut {
            // Settled on the query's own queue, so it cannot interleave with the copy of a gathering that
            // finished at the same moment: whichever runs first decides, and the other finds it settled.
            operations.addOperation { [self] in
                settle(.unfinished)
                query.stop()
            }
            operations.waitUntilAllOperationsAreFinished()
        }
        return lock.withLock { outcome } ?? .failed("The query ended without an outcome.")
    }

    /// Runs on the operation queue when the initial gathering finishes.
    private func gathered() {
        guard lock.withLock({ outcome == nil }) else { return }
        // https://developer.apple.com/documentation/foundation/nsmetadataquery/disableupdates()
        query.disableUpdates()
        let count = query.resultCount
        if count > limit {
            settle(.overLimit)
        } else {
            settle(.gathered((0..<count).map { item(at: $0) }))
        }
        query.stop()
    }

    private func item(at index: Int) -> IndexedApplication {
        guard let item = query.result(at: index) as? NSMetadataItem else {
            return IndexedApplication(path: nil, contentTypeTree: nil, bundleIdentifier: nil, displayName: nil)
        }
        // https://developer.apple.com/documentation/foundation/nsmetadataitem/value(forattribute:)
        // The bundle identifier has no NSMetadataItem key constant, so its attribute name is spelled out.
        return IndexedApplication(
            path: item.value(forAttribute: NSMetadataItemPathKey) as? String,
            contentTypeTree: item.value(forAttribute: NSMetadataItemContentTypeTreeKey) as? [String],
            bundleIdentifier: item.value(forAttribute: "kMDItemCFBundleIdentifier") as? String,
            displayName: item.value(forAttribute: NSMetadataItemDisplayNameKey) as? String)
    }

    /// The first outcome stands.
    private func settle(_ result: IndexedApplicationsRead) {
        lock.withLock { if outcome == nil { outcome = result } }
        finished.signal()
    }
}
