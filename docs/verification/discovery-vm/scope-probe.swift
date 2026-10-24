import Foundation

// Variants of the one fixed application query, to find why the provider's run finishes with no items.
//   adapter : the adapter's setup, operation queue, %@ predicate, indexed local computer scope
//   literal : the same but with the predicate written as a literal
//   noscope : the same but with no search scope set
//   main    : started on the main thread, delivered on the main run loop
let variant = CommandLine.arguments.dropFirst().first ?? "adapter"
let operations = OperationQueue()
operations.maxConcurrentOperationCount = 1
let query = NSMetadataQuery()
switch variant {
case "literal":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == 'com.apple.application-bundle'")
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
case "noscope":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
case "local":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
    query.searchScopes = [NSMetadataQueryLocalComputerScope]
case "urls":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
    query.searchScopes = [URL(fileURLWithPath: "/Applications"), URL(fileURLWithPath: "/System/Applications")]
case "empty":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
    query.searchScopes = []
case "slow":
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
default:
    query.predicate = NSPredicate(format: "kMDItemContentTypeTree == %@", "com.apple.application-bundle")
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
}
if variant != "main" { query.operationQueue = operations }

let started = Date()
func stamp() -> String { String(format: "%.2fs", Date().timeIntervalSince(started)) }
func report(_ what: String) {
    query.disableUpdates()
    let first = (query.results.first as? NSMetadataItem)?.value(forAttribute: NSMetadataItemPathKey) as? String
    print("\(variant) \(stamp()) \(what): \(query.resultCount) items, first \(first ?? "none")")
    query.enableUpdates()
}
let center = NotificationCenter.default
let queue: OperationQueue? = variant == "main" ? .main : operations
center.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: query, queue: queue) { _ in report("finished") }
center.addObserver(forName: .NSMetadataQueryDidUpdate, object: query, queue: queue) { _ in report("updated") }
center.addObserver(forName: .NSMetadataQueryGatheringProgress, object: query, queue: queue) { _ in report("progress") }

if variant == "main" {
    DispatchQueue.main.async { print("main started: \(query.start())") }
    DispatchQueue.main.asyncAfter(deadline: .now() + 8) { report("after 8s"); exit(0) }
    RunLoop.main.run()
} else {
    operations.addOperation { print("\(variant) started: \(query.start())") }
    Thread.sleep(forTimeInterval: variant == "slow" ? 200 : 8)
    operations.addOperation { report("after 8s") }
    operations.waitUntilAllOperationsAreFinished()
}
