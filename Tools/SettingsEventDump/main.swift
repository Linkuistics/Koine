import Foundation

// This headless helper runs only after the scenario's focus/failure observations.
guard CommandLine.arguments.count == 2 else {
    fputs("usage: settings-event-dump <new output path>\n", stderr)
    exit(2)
}
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let completion = URL(fileURLWithPath: url.path + ".complete")
guard !FileManager.default.fileExists(atPath: url.path), !FileManager.default.fileExists(atPath: completion.path) else {
    fputs("Refusing an output written before this dump request\n", stderr)
    exit(1)
}
// Delivery is not guaranteed. Post once, then observe the output without
// sending another notification or requesting activation.
// https://developer.apple.com/documentation/foundation/distributednotificationcenter
DistributedNotificationCenter.default().postNotificationName(
    Notification.Name("dev.antony.Koine.dumpSettingsEvents"), object: nil,
    userInfo: nil, deliverImmediately: true
)
let deadline = ProcessInfo.processInfo.systemUptime + 5
while !FileManager.default.fileExists(atPath: completion.path), ProcessInfo.processInfo.systemUptime < deadline {
    Thread.sleep(forTimeInterval: 0.1)
}
do {
    guard try Data(contentsOf: completion) == Data("KOINE_SETTINGS_EVENTS_COMPLETE\n".utf8) else {
        fputs("Settings event dump has no complete write marker\n", stderr)
        exit(1)
    }
    let data = try Data(contentsOf: url)
    try FileHandle.standardOutput.write(contentsOf: data)
} catch {
    fputs("Settings event dump unavailable after one request: \(error)\n", stderr)
    exit(1)
}
