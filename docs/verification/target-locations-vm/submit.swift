import AppKit

// Disposable (target-locations-vm, k180). A plain program, not Koine, making the submission Koine
// makes for a target in a protected folder: NSWorkspace.open([url], withApplicationAt:) when an
// application is named, and the default handler when the application is "-". It is built in the
// guest as an ad-hoc-signed app bundle and started through Launch Services, so that it is its own
// responsible process and macOS attributes any consent request to it. Nothing here is Koine.
//
//   submit <path> <application path or ->
let path = CommandLine.arguments[1]
let application = CommandLine.arguments[2]
let url = URL(fileURLWithPath: path)
let configuration = NSWorkspace.OpenConfiguration()
configuration.activates = false
var finished = false
if application == "-" {
    NSWorkspace.shared.open(url, configuration: configuration) { _, error in
        print("default open:", error?.localizedDescription ?? "ok")
        finished = true
    }
} else {
    NSWorkspace.shared.open([url], withApplicationAt: URL(fileURLWithPath: application), configuration: configuration) { _, error in
        print("named open:", error?.localizedDescription ?? "ok")
        finished = true
    }
}
let deadline = Date().addingTimeInterval(120)
while !finished && Date() < deadline { RunLoop.main.run(until: Date().addingTimeInterval(0.2)) }
print(finished ? "completed" : "no completion in 120 s")
