import Testing

@testable import InputProviderLogic

/// The input reference, the rule for an app process and the protection of Koine. The contract is "Targets" in
/// docs/specs/app-input.md.
struct InputReferenceTests {
    @Test func aReferenceNamesTheIncarnation() {
        let process = ProcessIncarnation(pid: 812, startMicroseconds: 1_764_300_000_123_456)
        #expect(InputReference.uri(process) == "koine://input/target/812/1764300000123456")
        #expect(InputReference.process("koine://input/target/812/1764300000123456") == process)
    }

    /// Only a text that the provider produces names a target. A desktop reference is not an input reference, and the
    /// two cannot be converted.
    @Test(arguments: [
        "koine://desktop/application/812/1764300000123456",
        "koine://input/application/812/1764300000123456",
        "koine://input/target/812",
        "koine://input/target/812/1764300000123456/1",
        "koine://input/target/0812/1764300000123456",
        "koine://input/target/+812/1764300000123456",
        "koine://input/target/0/1764300000123456",
        "koine://input/target/-1/1764300000123456",
        "koine://input/target/812/-5",
        "koine://input/target/812/",
        "koine://input/target/99999999999/1",
    ])
    func anyOtherTextIsNoTarget(uri: String) {
        #expect(InputReference.process(uri) == nil)
    }
}

struct TargetProtectionTests {
    static let koine = KoineIdentity(pid: 400, bundleIdentifier: "dev.antony.Koine")

    /// Koine refuses its own process, and any process with its bundle identifier, such as a second copy of Koine.
    @Test func koineIsProtectedByProcessAndByBundleIdentifier() {
        #expect(TargetProtection.of(pid: 400, bundleIdentifier: "dev.antony.Koine", koine: Self.koine) == .protected)
        #expect(TargetProtection.of(pid: 400, bundleIdentifier: nil, koine: Self.koine) == .protected)
        #expect(TargetProtection.of(pid: 401, bundleIdentifier: "dev.antony.Koine", koine: Self.koine) == .protected)
    }

    /// Every other app is a target, the consent and security agents and System Settings included.
    @Test(arguments: [
        "com.apple.Safari", "com.apple.finder", "com.apple.Terminal", "com.apple.systempreferences",
        "com.apple.SecurityAgent", "com.apple.accessibility.universalAccessAuthWarn", "dev.antony.Koine.helper",
    ])
    func everyOtherAppIsAddressable(bundleIdentifier: String) {
        #expect(TargetProtection.of(pid: 900, bundleIdentifier: bundleIdentifier, koine: Self.koine) == .addressable)
        #expect(TargetProtection.of(pid: 900, bundleIdentifier: nil, koine: Self.koine) == .addressable)
    }

    /// A host with no bundle identifier, such as a test runner, protects its own process alone. An app with no bundle
    /// identifier is then not Koine.
    @Test func aHostWithNoBundleIdentifierProtectsItsProcess() {
        let host = KoineIdentity(pid: 400, bundleIdentifier: nil)
        #expect(TargetProtection.of(pid: 400, bundleIdentifier: nil, koine: host) == .protected)
        #expect(TargetProtection.of(pid: 401, bundleIdentifier: nil, koine: host) == .addressable)
    }
}

struct CaptureTests {
    static let process = ProcessIncarnation(pid: 900, startMicroseconds: 1_764_300_000_000_001)

    /// An app gives a target with a reference, its localised name and its bundle identifier.
    @Test func anAppIsAnAddressableTarget() {
        let app = AppFacts(localizedName: "Safari", executableName: "Safari", bundleIdentifier: "com.apple.Safari")
        #expect(
            InputTarget.capture(Self.process, app: app, koine: TargetProtectionTests.koine)
                == InputTarget(
                    ref: "koine://input/target/900/1764300000000001", name: "Safari",
                    bundleIdentifier: "com.apple.Safari", protection: .addressable))
    }

    /// A process that macOS does not report as an app gives null. So Koine never issues a reference to it.
    @Test func aProcessThatIsNotAnAppGivesNoTarget() {
        #expect(InputTarget.capture(Self.process, app: nil, koine: TargetProtectionTests.koine) == nil)
    }

    /// Koine is a target with no reference, so Koine refuses itself before it issues one.
    @Test func koineIsAProtectedTargetWithNoReference() {
        let koine = ProcessIncarnation(pid: 400, startMicroseconds: 1)
        let app = AppFacts(localizedName: "Koine", executableName: "Koine", bundleIdentifier: "dev.antony.Koine")
        let target = InputTarget.capture(koine, app: app, koine: TargetProtectionTests.koine)
        #expect(target?.ref == nil)
        #expect(target?.protection == .protected)
        #expect(target?.name == "Koine")
    }

    /// The name is the localised name. When macOS reports none, it is the name of the executable.
    @Test func theNameFallsBackToTheExecutable() {
        #expect(AppFacts(localizedName: nil, executableName: "helper", bundleIdentifier: nil).name == "helper")
        #expect(AppFacts(localizedName: "Zed", executableName: "zed", bundleIdentifier: nil).name == "Zed")
        #expect(AppFacts(localizedName: nil, executableName: nil, bundleIdentifier: nil).name == "")
    }
}
