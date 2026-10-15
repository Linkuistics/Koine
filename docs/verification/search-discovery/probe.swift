import AppKit
import Foundation

/// Diagnostic only: injected into WorkspaceProvider.start in a copied build.
/// The shipped host, identity, entitlements, schema and factory remain unchanged.
@MainActor
enum SearchEvidence {
  static func run() async throws {
    let input = URL(fileURLWithPath: "/tmp/k19-command.json")
    guard FileManager.default.fileExists(atPath: input.path) else { return }
    let config =
      try JSONSerialization.jsonObject(with: Data(contentsOf: input)) as! [String: String]
    let mode = config["mode"]!
    let root = URL(fileURLWithPath: config["root"]!)
    var result: [String: Any] = [
      "mode": mode, "root": root.path, "case": config["case"]!,
      "pid": getpid(), "ppid": getppid(), "time": Date().description,
      "bundleIdentifier": Bundle.main.bundleIdentifier ?? "unknown",
    ]
    do {
      switch mode {
      case "content-control":
        result["bytes"] = try Data(contentsOf: root).count
      case "spotlight":
        let query = NSMetadataQuery()
        query.searchScopes = [root.path]
        query.predicate = NSPredicate(
          format: "%K CONTAINS[cd] %@", NSMetadataItemFSNameKey, "KoineNeedle")
        let started = query.start()
        result["started"] = started
        for _ in 0..<60 {
          if !query.isGathering { break }
          try await Task.sleep(for: .milliseconds(100))
        }
        result["gathering"] = query.isGathering
        query.disableUpdates()
        result["count"] = query.resultCount
        result["paths"] = (0..<query.resultCount).compactMap {
          (query.result(at: $0) as? NSMetadataItem)?.value(forAttribute: NSMetadataItemPathKey)
            as? String
        }
        query.stop()
      case "applications":
        let entries = try FileManager.default.contentsOfDirectory(
          at: root, includingPropertiesForKeys: [.isApplicationKey])
        var apps: [[String: Any]] = []
        for entry in entries {
          let values = try entry.resourceValues(forKeys: [.isApplicationKey])
          guard values.isApplication == true else { continue }
          let identifier = Bundle(url: entry)?.bundleIdentifier
          let registered = identifier.map {
            NSWorkspace.shared.urlsForApplications(withBundleIdentifier: $0).map(\.path)
          }
          apps.append([
            "path": entry.path, "bundleIdentifier": identifier as Any? ?? NSNull(),
            "registeredPaths": registered as Any? ?? NSNull(),
          ])
        }
        result["apps"] = apps
      case "enumerate":
        var pending = [root]
        var paths: [String] = []
        var skipped: [String] = []
        while let directory = pending.popLast(), paths.count < 3000 {
          let entries = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .isPackageKey],
            options: [.skipsHiddenFiles])
          for entry in entries {
            paths.append(entry.path)
            let values = try entry.resourceValues(forKeys: [
              .isDirectoryKey, .isSymbolicLinkKey, .isPackageKey,
            ])
            guard values.isDirectory == true else { continue }
            let protected = ["Desktop", "Documents", "Downloads", "Library"].map {
              FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent($0).path
            }
            if protected.contains(entry.path) || values.isSymbolicLink == true
              || values.isPackage == true
            {
              skipped.append(entry.path)
            } else {
              pending.append(entry)
            }
          }
        }
        result["paths"] = paths
        result["skipped"] = skipped
        result["pending"] = pending.map(\.path)
      default: throw NSError(domain: "SearchEvidence", code: 1)
      }
    } catch {
      let native = error as NSError
      result["error"] = [
        "domain": native.domain, "code": native.code, "message": native.localizedDescription,
      ]
    }
    try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
      .write(to: URL(fileURLWithPath: "/tmp/k19-result.json"), options: .atomic)
  }
}
