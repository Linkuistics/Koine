import CoreFoundation
import Foundation

/// The two native reads of a Space switch (docs/specs/app-input.md, "Space switching"). `SpaceSwitch` decides
/// everything from the plain values that they return. Neither read writes anything.

/// The whole `AppleSymbolicHotKeys` value of the preferences domain `com.apple.symbolichotkeys`, read again from disk.
/// Nil when the domain holds no such key. The calls are public, and Apple does not document the domain, so the route
/// probe is the evidence for its form (docs/verification/keystroke-route-vm.md). Koine never writes the domain.
/// https://developer.apple.com/documentation/corefoundation/cfpreferencesappsynchronize(_:)
/// https://developer.apple.com/documentation/corefoundation/cfpreferencescopyappvalue(_:_:)
func symbolicHotKeys() -> PropertyValue? {
    let domain = "com.apple.symbolichotkeys" as CFString
    CFPreferencesAppSynchronize(domain)
    return CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString, domain).map(propertyValue)
}

/// The reply of `SLSCopyManagedDisplaySpaces` for the main connection. Nil when a symbol is missing or the call
/// returns nothing.
func managedDisplaySpaces() -> PropertyValue? {
    guard let skyLight else { return nil }
    guard let reply = skyLight.copyManagedDisplaySpaces(skyLight.mainConnectionID())?.takeRetainedValue() else {
        return nil
    }
    return propertyValue(reply)
}

/// A native property-list value as a plain value. A number is an integer only when it is not a floating-point
/// type. A dictionary with a key that is not a string, and every type that the reads do not use, is `other`.
/// https://developer.apple.com/documentation/corefoundation/cfnumberisfloattype(_:)
func propertyValue(_ value: CFTypeRef) -> PropertyValue {
    let type = CFGetTypeID(value)
    if type == CFBooleanGetTypeID() {
        return .boolean(CFBooleanGetValue(unsafeBitCast(value, to: CFBoolean.self)))
    }
    if type == CFNumberGetTypeID() {
        let number = unsafeBitCast(value, to: CFNumber.self)
        var integer: Int64 = 0
        guard !CFNumberIsFloatType(number), CFNumberGetValue(number, .sInt64Type, &integer) else { return .other }
        return .integer(Int(integer))
    }
    if type == CFStringGetTypeID(), let text = value as? String { return .string(text) }
    if type == CFArrayGetTypeID(), let items = value as? [AnyObject] {
        return .array(items.map { propertyValue($0) })
    }
    if type == CFDictionaryGetTypeID(), let entries = value as? [String: AnyObject] {
        return .dictionary(entries.mapValues { propertyValue($0) })
    }
    return .other
}

private typealias MainConnectionID = @convention(c) () -> Int32
private typealias CopyManagedDisplaySpaces = @convention(c) (Int32) -> Unmanaged<CFArray>?

private struct SkyLight: Sendable {
    let mainConnectionID: MainConnectionID
    let copyManagedDisplaySpaces: CopyManagedDisplaySpaces
}

/// No official source: `SLSMainConnectionID` and `SLSCopyManagedDisplaySpaces` are private SkyLight functions that no
/// SDK header declares. Antony chose them for the count (app-input-k3). The signatures are those of the route probe,
/// `Fixtures/KeystrokeProbe/main.swift`, whose run is the evidence for the reply's form
/// (docs/verification/keystroke-route-vm.md, "How Koine can count Spaces"). The reply follows the Copy rule, so Koine
/// releases it. Koine looks the functions up when it first needs them, as the desktop provider looks up its private
/// window lookup. A strong link would stop the whole provider from loading if a macOS release removed a symbol.
/// Without them, a Space switch fails and posts nothing, and chords still work.
private let skyLight: SkyLight? = {
    guard let handle = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY),
        let main = dlsym(handle, "SLSMainConnectionID"), let copy = dlsym(handle, "SLSCopyManagedDisplaySpaces")
    else { return nil }
    return SkyLight(
        mainConnectionID: unsafeBitCast(main, to: MainConnectionID.self),
        copyManagedDisplaySpaces: unsafeBitCast(copy, to: CopyManagedDisplaySpaces.self)
    )
}()
