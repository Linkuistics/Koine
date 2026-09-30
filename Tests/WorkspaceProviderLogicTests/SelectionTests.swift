import Foundation
import Testing

@testable import WorkspaceProviderLogic

/// Installation selection, with the private native adapter substituted: absence,
/// identity mismatch and inspection failure, and the rules that keep a copy the
/// caller did not choose from ever being launched. An OS outcome, or the
/// independently built binary, is the N and V seams' to show.
@Suite struct SelectionTests {
    static let notes = "com.apple.Notes"

    func request(_ identifier: String = SelectionTests.notes, path: String? = nil) -> ApplicationRequest {
        ApplicationRequest(bundleIdentifier: identifier, applicationPath: path)
    }

    func expectDependency(_ selection: Selection, _ reason: DependencyReason, sourceLocation: SourceLocation = #_sourceLocation) {
        guard case .dependency(let actual, let guidance) = selection else {
            Issue.record("expected \(reason), got \(selection)", sourceLocation: sourceLocation)
            return
        }
        #expect(actual == reason, sourceLocation: sourceLocation)
        #expect(!guidance.isEmpty, sourceLocation: sourceLocation)
    }

    // MARK: Unconstrained

    @Test func anUnregisteredApplicationIsNotInstalled() {
        expectDependency(selectInstallation(request(), native: FakeNative()), .applicationNotInstalled)
    }

    @Test func aRegistrationWhoseBundleIsGoneIsNotInstalled() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        // Registration remains after deletion; presence is what is checked.
        native.inspect("/Applications/Notes.app", as: .absent)
        expectDependency(selectInstallation(request(), native: native), .applicationNotInstalled)
    }

    @Test func aRegistrationThatNowNamesNoApplicationIsNotInstalled() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        native.inspect("/Applications/Notes.app", as: .notApplication)
        expectDependency(selectInstallation(request(), native: native), .applicationNotInstalled)
    }

    @Test func aPresentCopyInTheTrashIsStillEligible() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Users/a/.Trash/Notes.app", file: "trashed")
        guard case .selected(let url, let substituting) = selectInstallation(request(), native: native) else {
            Issue.record("a present copy in the Trash must be eligible")
            return
        }
        #expect(url.path == "/Users/a/.Trash/Notes.app")
        #expect(substituting, "an unconstrained launch may reuse a running copy elsewhere")
    }

    @Test func aRegisteredBundleWithAnotherIdentifierIsAMismatchAndNothingElseIsTried() {
        let native = FakeNative()
        native.install("com.example.Other", at: "/Applications/Notes.app", file: "n")
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        native.install(Self.notes, at: "/Applications/Elsewhere/Notes.app", file: "e", isDefault: false)
        expectDependency(selectInstallation(request(), native: native), .applicationIdentityMismatch)
        #expect(native.inspected == ["/Applications/Notes.app"], "no other copy is substituted or even consulted")
    }

    @Test func aBundleThatDeclaresNoIdentifierDoesNotMatch() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        native.inspect(
            "/Applications/Notes.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Applications/Notes.app"), bundleIdentifier: nil,
                    identity: FakeNative.identity("n")
                )
            )
        )
        expectDependency(selectInstallation(request(), native: native), .applicationIdentityMismatch)
    }

    @Test func unreadableMetadataIsFailedNeverAbsence() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        native.inspect("/Applications/Notes.app", as: .unreadable("Operation not permitted"))
        guard case .failed(let message) = selectInstallation(request(), native: native) else {
            Issue.record("inspection failure must not read as absence")
            return
        }
        #expect(message.contains("Operation not permitted"))
    }

    // MARK: Constrained

    @Test func aPathSelectsExactlyThatRegisteredCopyAndForbidsSubstitution() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Applications/Notes.app", file: "system")
        native.install(Self.notes, at: "/Users/a/Apps/Notes.app", file: "mine", isDefault: false)
        guard case .selected(let url, let substituting) = selectInstallation(
            request(path: "/Users/a/Apps/Notes.app"), native: native)
        else {
            Issue.record("the chosen copy must be selected")
            return
        }
        #expect(url.path == "/Users/a/Apps/Notes.app")
        #expect(!substituting, "a chosen installation is never replaced by a running copy elsewhere")
    }

    @Test func aPathSpelledThroughASymlinkIsMatchedByFileIdentity() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Users/a/Apps/Notes.app", file: "mine")
        // The spelling the caller supplies resolves to the same file as the registration.
        native.inspect(
            "/Users/a/Link/Notes.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Users/a/Apps/Notes.app"), bundleIdentifier: Self.notes,
                    identity: FakeNative.identity("mine")
                )
            )
        )
        guard case .selected(let url, _) = selectInstallation(request(path: "/Users/a/Link/Notes.app"), native: native)
        else {
            Issue.record("identity, not spelling, decides")
            return
        }
        #expect(url.path == "/Users/a/Apps/Notes.app", "the launch addresses the registered copy that matched")
    }

    @Test func theSameNameOnAnotherVolumeIsAnotherFile() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Applications/Notes.app", file: "same")
        native.inspect(
            "/Volumes/Other/Notes.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Volumes/Other/Notes.app"), bundleIdentifier: Self.notes,
                    identity: FakeNative.identity("same", volume: 2)
                )
            )
        )
        // Present, with the right identifier, but not a copy Launch Services knows.
        expectDependency(
            selectInstallation(request(path: "/Volumes/Other/Notes.app"), native: native), .applicationNotInstalled)
    }

    @Test func aMissingOrNonApplicationPathIsNotInstalled() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Applications/Notes.app", file: "system")
        native.inspect("/Users/a/document.txt", as: .notApplication)
        expectDependency(selectInstallation(request(path: "/Users/a/missing.app"), native: native), .applicationNotInstalled)
        expectDependency(selectInstallation(request(path: "/Users/a/document.txt"), native: native), .applicationNotInstalled)
    }

    @Test func aConstrainedBundleWithAnotherIdentifierIsAMismatchWithoutSubstitution() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Applications/Notes.app", file: "system")
        native.install("com.example.Other", at: "/Users/a/Apps/Other.app", file: "other")
        expectDependency(
            selectInstallation(request(path: "/Users/a/Apps/Other.app"), native: native), .applicationIdentityMismatch)
    }

    @Test func aPresentButUnregisteredCopyIsNotInstalledAndAnotherIsNotSubstituted() {
        let native = FakeNative()
        native.install(Self.notes, at: "/Applications/Notes.app", file: "system")
        native.inspect(
            "/Users/a/Unregistered/Notes.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Users/a/Unregistered/Notes.app"), bundleIdentifier: Self.notes,
                    identity: FakeNative.identity("unregistered")
                )
            )
        )
        expectDependency(
            selectInstallation(request(path: "/Users/a/Unregistered/Notes.app"), native: native),
            .applicationNotInstalled)
    }

    @Test func aRegisteredCopyThatCannotBeReadLeavesTheChoiceUnknownSoItFails() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Notes.app"))
        native.inspect("/Applications/Notes.app", as: .unreadable("Operation not permitted"))
        native.inspect(
            "/Users/a/Apps/Notes.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Users/a/Apps/Notes.app"), bundleIdentifier: Self.notes,
                    identity: FakeNative.identity("mine")
                )
            )
        )
        guard case .failed = selectInstallation(request(path: "/Users/a/Apps/Notes.app"), native: native) else {
            Issue.record("an unreadable candidate must not be guessed at")
            return
        }
    }

    @Test func aStaleRegistrationBesideThePresentChosenCopyIsSkipped() {
        let native = FakeNative()
        native.register(Self.notes, at: URL(fileURLWithPath: "/Applications/Deleted/Notes.app"))
        native.inspect("/Applications/Deleted/Notes.app", as: .absent)
        native.install(Self.notes, at: "/Users/a/Apps/Notes.app", file: "mine", isDefault: false)
        guard case .selected(let url, _) = selectInstallation(request(path: "/Users/a/Apps/Notes.app"), native: native)
        else {
            Issue.record("a stale neighbour must not hide the chosen copy")
            return
        }
        #expect(url.path == "/Users/a/Apps/Notes.app")
    }

    // MARK: Input

    @Test(arguments: ["", " ", "\t\n", "\u{2003}"])
    func aBlankIdentifierIsInput(identifier: String) {
        #expect(throws: InputError.self) {
            try ApplicationRequest.validated(bundleIdentifier: identifier, applicationPath: nil).get()
        }
    }

    @Test(arguments: ["", "relative/Notes.app", "Notes.app", "~/Notes.app", "$HOME/Notes.app", "/Applications/N\u{0}otes.app"])
    func anEmptyRelativeOrNulPathIsInput(path: String) {
        let result = ApplicationRequest.validated(bundleIdentifier: Self.notes, applicationPath: path)
        if case .success = result { Issue.record("\(path.debugDescription) must be refused") }
    }

    @Test func spacesAndPunctuationInAPathStayLiteral() throws {
        let path = "/Users/a/My Apps/Notes (beta) & co.app"
        let request = try ApplicationRequest.validated(bundleIdentifier: Self.notes, applicationPath: path).get()
        #expect(request.applicationPath == path)
    }
}
