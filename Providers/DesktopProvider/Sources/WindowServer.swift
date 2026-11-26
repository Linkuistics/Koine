import ApplicationServices
import CoreGraphics
import Foundation

/// The two native reads behind the window-server link (docs/specs/machine.md, "The window-server link").
/// `WindowStacking` decides everything from the plain values that they return.

/// One reading of the window server's on-screen list, front to back, without desktop elements. Without
/// Screen Recording consent, the entries still carry numbers, owners, bounds, layers and alpha values. No
/// window name is read. When macOS returns no list, every window is unknown.
///
/// Front to back: https://developer.apple.com/documentation/coregraphics/cgwindowlistoption/optiononscreenonly
/// The keys and their value types: CGWindow.h in the macOS SDK.
func windowServerList() -> [ServerEntry] {
    guard
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
            as? [[String: Any]]
    else { return [] }
    return list.compactMap { entry in
        guard let number = (entry[kCGWindowNumber as String] as? NSNumber)?.uint32Value,
            let owner = (entry[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value
        else { return nil }
        let bounds = (entry[kCGWindowBounds as String] as? NSDictionary).flatMap {
            CGRect(dictionaryRepresentation: $0 as CFDictionary)
        }
        return ServerEntry(
            number: number, owner: owner, layer: (entry[kCGWindowLayer as String] as? NSNumber)?.intValue,
            alpha: (entry[kCGWindowAlpha as String] as? NSNumber)?.doubleValue,
            bounds: bounds.map(ScreenRect.init)
        )
    }
}

/// The window number of a held element, or nil when the lookup fails. It orders windows and never
/// identifies them: every action still goes to the held element. No element is rebuilt from a number.
func windowNumber(of element: AXUIElement) -> UInt32? {
    guard let lookup = axUIElementGetWindow else { return nil }
    var number: CGWindowID = 0
    AXUIElementSetMessagingTimeout(element, messagingTimeout)
    guard lookup(element, &number) == .success, number != kCGNullWindowID else { return nil }
    return number
}

private typealias WindowLookup = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError

/// No official source: a private HIServices function that no SDK header declares. The SDK's stub library
/// exports it (`__AXUIElementGetWindow` in HIServices.tbd). Modaliser calls the same function, declared
/// with `@_silgen_name` in its WindowEnumerator.swift. Koine looks it up when it first needs it instead.
/// A strong reference would stop the whole provider from loading if a macOS release removed the symbol.
/// Without it, the link falls back to owner and bounds, and Koine reports the rest as unknown.
/// `dlsym` with RTLD_DEFAULT, which is `(void *)-2` in dlfcn.h, searches every loaded image.
private let axUIElementGetWindow: WindowLookup? =
    dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_AXUIElementGetWindow").map {
        unsafeBitCast($0, to: WindowLookup.self)
    }
