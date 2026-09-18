import AppKit

// AppKit owns the process lifecycle; SwiftUI supplies only view content. The
// README ("Resident application") records why, with the Apple references.
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
