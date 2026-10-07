import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// L: the discovered-application stage (docs/specs/workspace-launch-and-open.md "Order of target and application
/// stages", stages 3 and 4) over the substituted private adapter, through the real provider for each form that
/// discovers its application: an unconstrained launch, a named open without `applicationPath`, the default handler
/// of a document, the default web browser, and Finder for a reveal. A discovery read finds the location; the stage
/// resolves it by the walk, refuses an over-limit spelling, and only then reads the bundle. The adapter answers what
/// the walk would find, including what no fixture can build (a 1,500-byte copy), and records every call, so "exactly
/// the discovery read, then no metadata read and no submission" is observed rather than inferred. The walk is
/// `LocationWalkTests`, and the built provider `WorkspaceDiscoveredApplicationTests`.
@Suite struct DiscoveredApplicationTests {
    /// What a request came to, read from the provider's result.
    enum Outcome: Equatable {
        case available
        case dependency(String)
        case failed(String)
    }

    /// One way the provider finds an application for itself.
    enum Form: CaseIterable, CustomTestStringConvertible {
        case launch, namedOpen, defaultHandler, webBrowser, finder

        var testDescription: String {
            switch self {
            case .launch: "unconstrained launch"
            case .namedOpen: "named open"
            case .defaultHandler: "default handler"
            case .webBrowser: "web browser"
            case .finder: "Finder"
            }
        }

        /// The registered location discovery reports, as the bench arranges it.
        var path: String {
            switch self {
            case .launch: "/System/Applications/Notes.app"
            case .namedOpen: "/Applications/Zed.app"
            case .defaultHandler: "/System/Applications/TextEdit.app"
            case .webBrowser: "/Applications/Safari.app"
            case .finder: RevealPathTests.finderPath
            }
        }

        /// The identifier the arranged bundle declares.
        var identifier: String {
            switch self {
            case .launch: LaunchTests.notes
            case .namedOpen: OpenPathTests.zed
            case .defaultHandler: "com.apple.TextEdit"
            case .webBrowser: "com.apple.Safari"
            case .finder: finderBundleIdentifier
            }
        }

        /// Whether the form requires its handler to declare the identifier it asked for. A default handler that
        /// declares none, or another, still receives its document or URL.
        var checksIdentifier: Bool { self == .launch || self == .namedOpen }

        /// What a stale or missing registration is reported as: the dependency the discovery read stands for.
        var absentReason: String {
            switch self {
            case .launch, .namedOpen, .finder: "APPLICATION_NOT_INSTALLED"
            case .defaultHandler, .webBrowser: "NO_DEFAULT_HANDLER"
            }
        }

        /// What no request did, in the guidance's own words.
        var unaccomplished: String {
            switch self {
            case .launch: "launched"
            case .namedOpen, .defaultHandler, .webBrowser: "opened"
            case .finder: "revealed"
            }
        }

        func bench() -> (native: FakeNative, provider: WorkspaceProvider) {
            let pair: (native: FakeNative, provider: WorkspaceProvider)
            switch self {
            case .launch: pair = LaunchTests.bench()
            case .namedOpen, .defaultHandler: pair = OpenPathTests.bench()
            case .webBrowser: pair = OpenURLTests.bench()
            case .finder: pair = RevealPathTests.bench()
            }
            pair.native.onLaunch = { $0(.acknowledged(nil)) }
            return pair
        }

        func resolve(_ provider: WorkspaceProvider) async -> Outcome {
            let request: ResolutionRequest
            switch self {
            case .launch: request = LaunchTests.request()
            case .namedOpen: request = OpenPathTests.request(application: OpenPathTests.named(OpenPathTests.zed))
            case .defaultHandler: request = OpenPathTests.request()
            case .webBrowser: request = OpenURLTests.request()
            case .finder: request = RevealPathTests.request()
            }
            let result = await provider.resolve(request)
            if let failure = LaunchTests.failure(result) { return .failed(failure.message) }
            guard let fields = LaunchTests.value(result) else { return .failed("no result") }
            if case .string(let reason)? = OpenPathTests.dependencyReason(fields) { return .dependency(reason) }
            return fields["status"] == .string("AVAILABLE") ? .available : .failed("\(fields)")
        }

        /// How many discovery reads the provider made: the one registration, handler or scheme lookup.
        func discoveryReads(_ native: FakeNative) -> Int {
            switch self {
            case .launch, .namedOpen, .finder: native.registrationLookups.count
            case .defaultHandler: native.documentLookups.count
            case .webBrowser: native.handlerLookups.count
            }
        }

        /// Whether the discovery read is the only lookup of any kind the provider made.
        func onlyDiscoveryWasAsked(_ native: FakeNative) -> Bool {
            switch self {
            case .launch, .namedOpen, .finder: native.documentLookups.isEmpty && native.handlerLookups.isEmpty
            case .defaultHandler: native.registrationLookups.isEmpty && native.handlerLookups.isEmpty
            case .webBrowser: native.registrationLookups.isEmpty && native.documentLookups.isEmpty
            }
        }

        func submissions(_ native: FakeNative) -> Int {
            native.launches.count + native.opens.count + native.pathOpens.count + native.reveals.count
        }

        /// The registered location the one submission was addressed to.
        func submittedTo(_ native: FakeNative) -> String? {
            switch self {
            case .launch: native.launches.first?.url.path
            case .namedOpen, .defaultHandler: native.pathOpens.first?.application.path
            case .webBrowser: native.opens.first?.application.path
            case .finder: nil  // Finder is asked by the caller's path, not addressed
            }
        }
    }

    /// A spelling of exactly `count` bytes.
    static func spelling(_ count: Int, _ label: String = "d") -> Spelling {
        Spelling(bytes: Array(("/" + String(repeating: label, count: count - 1)).utf8))
    }

    /// The registered location `form` found, as the walk would report it.
    static func present(
        _ form: Form, literal: Int? = nil, expansions: [Int] = [], resolved: Int? = nil
    ) -> LocationResolution {
        let short = Spelling(bytes: Array(form.path.utf8))
        return .present(
            ResolvedLocation(
                literal: literal.map { spelling($0) } ?? short, expansions: expansions.map { spelling($0, "e") },
                resolved: resolved.map { spelling($0, "r") } ?? short,
                identity: ObjectIdentity(device: 1, inode: 4), type: .directory))
    }

    /// A present directory whose literal and resolved spelling are both `path`, however long.
    static func placed(_ path: String) -> LocationResolution {
        let spelling = Spelling(bytes: Array(path.utf8))
        return .present(
            ResolvedLocation(
                literal: spelling, expansions: [], resolved: spelling, identity: ObjectIdentity(device: 1, inode: 9), type: .directory))
    }

    // MARK: A discovered location is resolved before it is limited, and limited before anything reads it

    @Test(arguments: Form.allCases, [1024, 1025, 1500, 4000])
    func anOverLimitDiscoveredApplicationRecordsOnlyTheDiscoveryReadThenNothing(_ form: Form, _ length: Int) async throws {
        let (native, provider) = form.bench()
        native.location(form.path, as: Self.present(form, literal: length))
        guard case .failed(let message) = await form.resolve(provider) else {
            Issue.record("\(form.testDescription): not failed")
            return
        }
        for needed in [
            "application hand-off", "registered application path as written", "\(length) bytes", "No request was made",
            "nothing was \(form.unaccomplished)",
        ] {
            #expect(message.contains(needed), "\(form.testDescription): \(needed): \(message)")
        }
        #expect(form.discoveryReads(native) == 1, "exactly the discovery read that found it")
        #expect(form.onlyDiscoveryWasAsked(native))
        #expect(native.resolved.contains(form.path), "it was resolved")
        #expect(native.bundleReads.isEmpty, "no metadata read of it")
        #expect(form.submissions(native) == 0, "no domain request")
        #expect(provider.submissionsInFlight == 0)
    }

    @Test(arguments: Form.allCases)
    func aLongExpansionOrResolvedSpellingIsRefusedAtThatSpelling(_ form: Form) async throws {
        for (resolution, spelling) in [
            (Self.present(form, expansions: [1100]), "remaining registered application path after symbolic link 1"),
            (Self.present(form, resolved: 1300), "resolved registered application path"),
        ] {
            let (native, provider) = form.bench()
            native.location(form.path, as: resolution)
            guard case .failed(let message) = await form.resolve(provider) else {
                Issue.record("\(form.testDescription): not failed")
                continue
            }
            #expect(message.contains(spelling), "\(form.testDescription): \(message)")
            #expect(native.bundleReads.isEmpty && form.submissions(native) == 0)
        }
    }

    @Test(arguments: Form.allCases)
    func theLongestSpellingTheApplicationsTakeIsHandedOverAndTheApplicationIsRead(_ form: Form) async throws {
        let (native, provider) = form.bench()
        native.location(form.path, as: Self.present(form, literal: 1023))
        #expect(await form.resolve(provider) == .available)
        #expect(native.bundleReads == [form.path], "its bundle is read from the resolved spelling")
        #expect(form.submissions(native) == 1)
        #expect(form.submittedTo(native).map { $0 == form.path } ?? true, "addressed to its registered location")
    }

    @Test(arguments: Form.allCases)
    func aCycleOrAnImpossibleNameIsFailedNeverAStaleRegistration(_ form: Form) async throws {
        for (absence, why) in [
            (Absence.cycle(link: "loop"), "leads back to itself"),
            (Absence.impossibleComponent(component: "zzz"), "longer than the filesystem allows"),
        ] {
            let (native, provider) = form.bench()
            native.location(form.path, as: .absent(absence))
            guard case .failed(let message) = await form.resolve(provider) else {
                Issue.record("\(form.testDescription): \(absence) is not failed")
                continue
            }
            #expect(message.contains(why), "\(form.testDescription): \(message)")
            #expect(native.bundleReads.isEmpty && form.submissions(native) == 0)
        }
    }

    @Test(arguments: Form.allCases)
    func aStepTheWalkCouldNotEstablishIsFailedNamingTheComponentAndCause(_ form: Form) async throws {
        let (native, provider) = form.bench()
        native.location(form.path, as: .failed(component: "Locked", cause: "Permission denied"))
        guard case .failed(let message) = await form.resolve(provider) else {
            Issue.record("\(form.testDescription): not failed")
            return
        }
        #expect(message.contains("\"Locked\"") && message.contains("Permission denied"), Comment(rawValue: message))
        #expect(native.bundleReads.isEmpty && form.submissions(native) == 0)
    }

    // MARK: The dependencies

    @Test(arguments: Form.allCases)
    func anEstablishedAbsenceIsTheStaleRegistrationDependency(_ form: Form) async throws {
        for absence in [Absence.missing(component: "Notes.app"), .notDirectory(component: "Apps")] {
            let (native, provider) = form.bench()
            native.location(form.path, as: .absent(absence))
            #expect(await form.resolve(provider) == .dependency(form.absentReason), "\(form.testDescription): \(absence)")
            #expect(native.bundleReads.isEmpty, "an absent location is never read")
            #expect(form.submissions(native) == 0)
        }
    }

    @Test(arguments: Form.allCases)
    func aPresentNonApplicationIsThatSameDependency(_ form: Form) async throws {
        let (native, provider) = form.bench()
        native.inspect(form.path, as: .notApplication)
        #expect(await form.resolve(provider) == .dependency(form.absentReason), Comment(rawValue: form.testDescription))
        #expect(native.bundleReads == [form.path], "present, so read once")
        #expect(form.submissions(native) == 0)
    }

    @Test(arguments: Form.allCases)
    func aBundleThatCannotBeReadIsFailedNeverAbsenceOrAnotherIdentifier(_ form: Form) async throws {
        let (native, provider) = form.bench()
        native.location(form.path, as: Self.placed(form.path))  // the walk found it; the read then fails
        native.inspect(form.path, as: .unreadable("Permission denied"))
        guard case .failed(let message) = await form.resolve(provider) else {
            Issue.record("\(form.testDescription): not failed")
            return
        }
        #expect(message.contains("could not be inspected") && message.contains("Permission denied"), Comment(rawValue: message))
        #expect(form.submissions(native) == 0)
    }

    @Test(arguments: Form.allCases)
    func aDiscoveredApplicationWithAnotherOrNoIdentifierIsAMismatchOnlyWhereTheIdentifierWasAsked(_ form: Form) async throws {
        for declared: String? in ["com.example.Other", nil] {
            let (native, provider) = form.bench()
            native.inspect(
                form.path,
                as: .application(
                    ApplicationBundle(
                        url: URL(fileURLWithPath: form.path), bundleIdentifier: declared, identity: FakeNative.identity("other"))))
            let outcome = await form.resolve(provider)
            switch form {
            case .launch, .namedOpen:
                #expect(outcome == .dependency("APPLICATION_IDENTITY_MISMATCH"), "\(form.testDescription): \(String(describing: declared))")
                #expect(form.submissions(native) == 0)
            case .finder:
                // Reveal reports every Finder dependency, a mismatch included, as not installed.
                #expect(outcome == .dependency("APPLICATION_NOT_INSTALLED"), "\(String(describing: declared))")
                #expect(form.submissions(native) == 0)
            case .defaultHandler, .webBrowser:
                #expect(outcome == .available, "\(form.testDescription) needs no identifier: \(String(describing: declared))")
                #expect(form.submissions(native) == 1)
            }
        }
    }

    @Test(arguments: Form.allCases)
    func aSelectedApplicationIsSubmittedAtItsRegisteredLocation(_ form: Form) async throws {
        let (native, provider) = form.bench()
        #expect(await form.resolve(provider) == .available)
        #expect(native.bundleReads == [form.path])
        #expect(form.submissions(native) == 1)
        #expect(form.submittedTo(native).map { $0 == form.path } ?? true)
        switch form {
        case .launch: #expect(native.launches.map(\.substituting) == [true], "a running copy elsewhere may stand in")
        case .namedOpen, .defaultHandler: #expect(native.pathOpens.map(\.substituting) == [true])
        case .webBrowser, .finder: break
        }
    }

    // MARK: A preferred copy that is long is refused, never replaced

    /// The identifier's preferred copy is the long one. An unconstrained launch discovers it, selects it and refuses
    /// its spelling before any request: the short copy that is registered beside it, and may be running, is neither
    /// consulted nor substituted, because the refusal precedes the platform.
    @Test func aLongPreferredCopyIsRefusedAndNoOtherCopyIsSubstituted() async throws {
        let (native, provider) = LaunchTests.bench()
        native.onLaunch = { $0(.acknowledged(FakeApplication())) }
        let short = "/Applications/Notes.app"
        let long = "/Long" + String(repeating: "d", count: 1495) + "/Notes.app"
        native.register(LaunchTests.notes, at: URL(fileURLWithPath: long), default: true)
        native.register(LaunchTests.notes, at: URL(fileURLWithPath: short), default: false)
        native.location(long, as: Self.placed(long))
        native.inspect(
            short,
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: short), bundleIdentifier: LaunchTests.notes, identity: FakeNative.identity("notes"))))
        let failure = try #require(LaunchTests.failure(await provider.resolve(LaunchTests.request())))
        #expect(failure.kind == .failed)
        #expect(
            failure.message.contains("\(long.utf8.count) bytes") && failure.message.contains("nothing was launched"),
            Comment(rawValue: failure.message))
        #expect(native.launches.isEmpty, "no request, so a running short copy is not activated either")
        #expect(native.resolved.contains(long) && !native.resolved.contains(short), "the short copy was not even consulted")
        #expect(native.bundleReads.isEmpty)
        #expect(native.registrationLookups == [LaunchTests.notes], "exactly the discovery read")
    }

    /// The other half of the same rule: when the preferred copy is short, a long copy of the same application
    /// elsewhere on disk, listed or not, is never looked at by an unconstrained launch.
    @Test func aLongUnequalCopyBesideAShortPreferredOneIsNeverTouched() async throws {
        let (native, provider) = LaunchTests.bench()
        native.onLaunch = { $0(.acknowledged(nil)) }
        let short = "/Applications/Notes.app"
        let long = "/Long" + String(repeating: "d", count: 1495) + "/Notes.app"
        native.register(LaunchTests.notes, at: URL(fileURLWithPath: long), default: false)
        native.install(LaunchTests.notes, at: short, file: "short")
        native.location(long, as: Self.placed(long))
        let fields = try #require(LaunchTests.value(await provider.resolve(LaunchTests.request())))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(native.launches.map(\.url.path) == [short])
        #expect(!native.resolved.contains(long), "an unequal long copy is not resolved, let alone refused")
    }

    // MARK: The target settles first

    @Test func aMissingTargetIsReportedBeforeADiscoveredApplicationIsResolved() async throws {
        let (native, provider) = OpenPathTests.bench()
        native.location(OpenPathTests.document, as: .absent(.missing(component: "notes.txt")))
        native.location(Form.defaultHandler.path, as: .absent(.cycle(link: "loop")))
        let fields = try #require(LaunchTests.value(await provider.resolve(OpenPathTests.request())))
        #expect(OpenPathTests.dependencyReason(fields) == .string("PATH_NOT_FOUND"))
        #expect(native.documentLookups.isEmpty && !native.resolved.contains(Form.defaultHandler.path))
    }
}
