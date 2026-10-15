// Guest-side helper for the launcher preparation (scripts/vm-launchers-lib.sh):
//   vm-default-browser get              prints the handler of http and https
//   vm-default-browser set <app path>   asks the system to make that application
//                                       the default browser, then prints as `get`
// `set` blocks until someone answers the system's confirmation ("Keep / Use"), which
// the host answers over VNC: macOS offers no way to change the default browser
// without it. Setting http changes https with it (setting https separately fails
// with permErr after the first has been answered), so only http is set.
import AppKit

let arguments = CommandLine.arguments
if arguments.count > 2, arguments[1] == "set" {
    let application = URL(fileURLWithPath: arguments[2])
    let answered = DispatchSemaphore(value: 0)
    NSWorkspace.shared.setDefaultApplication(at: application, toOpenURLsWithScheme: "http") { error in
        print("set http:", error.map { "\($0)" } ?? "ok")
        answered.signal()
    }
    _ = answered.wait(timeout: .now() + 120)
}
for scheme in ["http", "https"] {
    let handler = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "\(scheme)://example.com")!)
    let identifier = handler.flatMap { Bundle(url: $0)?.bundleIdentifier } ?? ""
    print("\(scheme) -> \(handler?.path ?? "none") \(identifier)")
}
