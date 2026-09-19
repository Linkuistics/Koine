import AppKit
import ApplicationServices

// The positive control for "a Koine read shows no consent dialog": the one call
// Koine never makes. Asking with the prompt option is what makes macOS show the
// Accessibility dialog, so the verification's dialog detector is seen to find
// one before its clean reading of Koine is credited.
// https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
print("trusted: \(AXIsProcessTrustedWithOptions(options))")
DispatchQueue.main.asyncAfter(deadline: .now() + 120) { exit(0) }
app.run()
