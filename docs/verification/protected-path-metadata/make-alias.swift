// Fixture preparation only: run under the test agent, never the measured probe.
import Foundation

guard CommandLine.arguments.count == 3 else { fatalError("Usage: make-alias target alias") }
let target = URL(fileURLWithPath: CommandLine.arguments[1])
let destination = URL(fileURLWithPath: CommandLine.arguments[2])
let bookmark = try target.bookmarkData(options: .suitableForBookmarkFile)
try URL.writeBookmarkData(bookmark, to: destination)
