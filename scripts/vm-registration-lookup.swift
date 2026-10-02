import AppKit
import Foundation

// Run in the guest. What Launch Services itself answers, which is what the workspace
// provider's native adapter asks (NSWorkspace), so that a registration case records what
// the system said and not what the case assumed.
//
//   registration-lookup <bundle identifier>...        the registered copy and every registered copy
//   registration-lookup --opens <path>...             the default application for each document
//
// One line each: "<id>\t<registered copy or none>\t<every copy, | separated>", and
// "<path>\t<default application or none>\t<its bundle identifier or none>".

var arguments = Array(CommandLine.arguments.dropFirst())
if arguments.first == "--opens" {
    arguments.removeFirst()
    for path in arguments {
        let handler = NSWorkspace.shared.urlForApplication(toOpen: URL(fileURLWithPath: path))
        let id = handler.flatMap { Bundle(url: $0)?.bundleIdentifier } ?? "none"
        print("\(path)\t\(handler?.path ?? "none")\t\(id)")
    }
} else {
    for id in arguments {
        let one = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)?.path ?? "none"
        let all = NSWorkspace.shared.urlsForApplications(withBundleIdentifier: id).map(\.path).joined(separator: "|")
        print("\(id)\t\(one)\t\(all.isEmpty ? "none" : all)")
    }
}
