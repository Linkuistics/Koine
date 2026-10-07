import Foundation
import KoineProviderAPI
import Testing

@testable import KoineCore
@testable import WorkspaceProviderLogic

/// The "Multiple copies and installation" row at the composition point (G): the real workspace
/// provider, composed through the engine every transport executes through, over a native
/// stand-in with several installed copies of one identifier. A client asks through the public
/// operations, with the installation as a GraphQL variable, and what is asserted is what
/// reached the native submission: which copy, and whether a running copy elsewhere may stand in.
/// Nothing is launched or opened; the real adapter's inspection is the N seam's and the real
/// applications are the V seam's (docs/verification/application-installations-vm.md).
@Suite struct WorkspaceInstallationsCompositionTests {
    static let id = "dev.koine.test.InstallationFixture"
    static let copyA = "/Applications/A/Fixture.app"
    static let copyB = "/Applications/B/Fixture.app"
    static let trashed = "/Users/test/.Trash/Fixture.app"

    /// Installed copies, as Launch Services and the filesystem would report them, and a record of
    /// every submission. Every answer is arranged by the test.
    final class Copies: WorkspaceNative, @unchecked Sendable {
        private let lock = NSLock()
        private var preferred: [String: URL] = [:]
        private var listed: [String: [URL]] = [:]
        private var inspections: [String: ApplicationInspection] = [:]
        private var launchLog: [(url: URL, substituting: Bool)] = []
        private var openLog: [(document: String, application: URL, substituting: Bool)] = []
        var launches: [(url: URL, substituting: Bool)] { lock.withLock { launchLog } }
        var opens: [(document: String, application: URL, substituting: Bool)] { lock.withLock { openLog } }

        /// A present copy, registered; `preferred` is the one Launch Services answers for the
        /// identifier, `inList` whether the list of every copy includes it.
        func install(_ identifier: String, at path: String, file: String, preferred isPreferred: Bool = false, inList: Bool = true) {
            let url = URL(fileURLWithPath: path)
            lock.withLock {
                if isPreferred { preferred[identifier] = url }
                if inList { listed[identifier, default: []].append(url) }
                inspections[path] = .application(
                    ApplicationBundle(
                        url: url, bundleIdentifier: identifier,
                        identity: FileIdentity(volume: NSNumber(value: 1), file: file as NSString)))
            }
        }
        func inspect(_ path: String, as result: ApplicationInspection) { lock.withLock { inspections[path] = result } }
        func register(_ identifier: String, at path: String) { lock.withLock { preferred[identifier] = URL(fileURLWithPath: path) } }

        func registeredApplication(bundleIdentifier: String) -> URL? { lock.withLock { preferred[bundleIdentifier] } }
        func registeredApplications(bundleIdentifier: String) -> [URL] { lock.withLock { listed[bundleIdentifier] ?? [] } }
        func inspectApplication(at path: String) -> ApplicationInspection { lock.withLock { inspections[path] ?? .absent } }
        func launchApplication(
            at url: URL, substitutingRunningCopy: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) {
            lock.withLock { launchLog.append((url, substitutingRunningCopy)) }
            completion(.acknowledged(nil))
        }
        func defaultApplication(forWebScheme scheme: WebURL.Scheme) -> URL? { nil }
        func openWebURL(_ url: URL, withApplicationAt application: URL, completion: @escaping @Sendable (LaunchCompletion) -> Void) {
            completion(.refused("a URL open is not part of this test"))
        }
        func inspectPath(_ path: String) -> PathInspection {
            .present(PathFacts(isDirectory: false, isApplication: false, isAliasFile: false, contentType: "public.plain-text"))
        }
        func resolveLocation(_ path: String) -> LocationResolution {
            let spelling = Spelling(bytes: Array(path.utf8))
            return .present(
                ResolvedLocation(
                    literal: spelling, expansions: [], resolved: spelling,
                    identity: ObjectIdentity(device: 1, inode: 1), type: .regularFile))
        }
        func isFilesystemRoot(literalPath path: String) -> FilesystemRootDecision { .notRoot }
        func contentType(_ identifier: String, conformsTo ancestor: String) -> Bool { identifier == ancestor }
        func defaultApplication(toOpen url: URL) -> URL? { nil }
        func openPath(
            _ url: URL, withApplicationAt application: URL, substitutingRunningCopy: Bool,
            completion: @escaping @Sendable (LaunchCompletion) -> Void
        ) {
            lock.withLock { openLog.append((url.path, application, substitutingRunningCopy)) }
            completion(.acknowledged(nil))
        }
        func revealPath(_ path: String, filesystemRoot: Bool, completion: @escaping @Sendable (LaunchCompletion) -> Void) {
            completion(.refused("a reveal is not part of this test"))
        }
        func processStart(of pid: Int32) -> ProcessLookup { .absent }
        func liveExecutableIdentity(of pid: Int32) -> FileIdentity? { nil }
    }

    static func bench() async throws -> (bench: WorkspaceCompositionTests.Bench, native: Copies, client: Principal) {
        let native = Copies()
        native.install(id, at: copyA, file: "a", preferred: true)
        native.install(id, at: copyB, file: "b")
        let bench = try await WorkspaceCompositionTests.Bench(provider: WorkspaceProvider(native: native))
        let client = try await bench.grant(WorkspaceCompositionTests.controls)
        return (bench, native, client.principal)
    }

    static let launch = """
        mutation($application: WorkspaceApplicationInput!) {
          launch: workspaceLaunchApplication(application: $application) {
            status value { process { pid } } dependency { reason guidance } } }
        """
    static let openPath = """
        mutation($path: String!, $application: WorkspaceApplicationInput) {
          open: workspaceOpenPath(path: $path, application: $application) {
            status value { process { pid } } dependency { reason guidance } } }
        """

    static func application(_ identifier: String = id, path: String? = nil) -> [String: Any] {
        var application: [String: Any] = ["bundleIdentifier": identifier]
        if let path { application["applicationPath"] = path }
        return application
    }

    func reason(_ reply: WorkspaceCompositionTests.Bench.Reply, _ field: String) -> String? {
        ((reply.data?[field] as? [String: Any])?["dependency"] as? [String: Any])?["reason"] as? String
    }

    // MARK: Which copy is addressed

    @Test func anUnconstrainedLaunchSubmitsTheCopyLaunchServicesChoosesAndAllowsARunningCopyToStandIn() async throws {
        let (bench, native, client) = try await Self.bench()
        let reply = try await bench.run(Self.launch, ["application": Self.application()], as: client)
        #expect(reply.errors.isEmpty, Comment(rawValue: "\(reply.errors)"))
        #expect((reply.data?["launch"] as? [String: Any])?["status"] as? String == "AVAILABLE")
        #expect(native.launches.map(\.url.path) == [Self.copyA])
        #expect(native.launches.map(\.substituting) == [true], "a running copy at another location may be used")
    }

    @Test(arguments: [copyA, copyB])
    func aPathAddressesExactlyThatCopyAndForbidsSubstitution(_ path: String) async throws {
        let (bench, native, client) = try await Self.bench()
        let reply = try await bench.run(Self.launch, ["application": Self.application(path: path)], as: client)
        #expect((reply.data?["launch"] as? [String: Any])?["status"] as? String == "AVAILABLE", Comment(rawValue: "\(reply.errors)"))
        #expect(native.launches.map(\.url.path) == [path])
        #expect(native.launches.map(\.substituting) == [false], "a chosen installation is never replaced by a running copy")
    }

    @Test func aNamedOpenFollowsTheSameTwoRules() async throws {
        let (bench, native, client) = try await Self.bench()
        let document = "/Users/test/notes.txt"
        _ = try await bench.run(Self.openPath, ["path": document, "application": Self.application()], as: client)
        _ = try await bench.run(Self.openPath, ["path": document, "application": Self.application(path: Self.copyB)], as: client)
        #expect(native.opens.map(\.application.path) == [Self.copyA, Self.copyB])
        #expect(native.opens.map(\.substituting) == [true, false])
        #expect(native.opens.map(\.document) == [document, document], "the document is submitted as written")
    }

    @Test func aTrashedCopyThatOnlyTheIdentifiersOwnLookupReportsIsEligibleWhenChosen() async throws {
        let (bench, native, client) = try await Self.bench()
        native.install("\(Self.id).Trashed", at: Self.trashed, file: "t", preferred: true, inList: false)
        for application in [Self.application("\(Self.id).Trashed"), Self.application("\(Self.id).Trashed", path: Self.trashed)] {
            let reply = try await bench.run(Self.launch, ["application": application], as: client)
            #expect((reply.data?["launch"] as? [String: Any])?["status"] as? String == "AVAILABLE", Comment(rawValue: "\(reply.errors)"))
        }
        #expect(native.launches.map(\.url.path) == [Self.trashed, Self.trashed])
    }

    // MARK: What is refused, with nothing submitted

    @Test(arguments: [
        ("a missing copy", "/Applications/Gone/Fixture.app", "APPLICATION_NOT_INSTALLED"),
        ("a present copy that is not registered", "/Users/test/Unregistered/Fixture.app", "APPLICATION_NOT_INSTALLED"),
        ("a copy whose registration outlived its bundle", "/Users/test/Stale/Fixture.app", "APPLICATION_NOT_INSTALLED"),
        ("a program that is not a bundle", "/Users/test/bin/program", "APPLICATION_NOT_INSTALLED"),
        ("a copy of another identifier", "/Applications/Other.app", "APPLICATION_IDENTITY_MISMATCH"),
    ])
    func eachFailureIsItsDependencyAndNothingIsSubstituted(what: String, path: String, expected: String) async throws {
        let (bench, native, client) = try await Self.bench()
        native.inspect(
            "/Users/test/Unregistered/Fixture.app",
            as: .application(
                ApplicationBundle(
                    url: URL(fileURLWithPath: "/Users/test/Unregistered/Fixture.app"), bundleIdentifier: Self.id,
                    identity: FileIdentity(volume: NSNumber(value: 1), file: "unregistered" as NSString))))
        native.inspect("/Users/test/bin/program", as: .notApplication)
        native.install("dev.koine.test.Other", at: "/Applications/Other.app", file: "other")

        let launch = try await bench.run(Self.launch, ["application": Self.application(path: path)], as: client)
        #expect(reason(launch, "launch") == expected, Comment(rawValue: what))
        #expect((launch.data?["launch"] as? [String: Any])?["value"] is NSNull)
        let open = try await bench.run(
            Self.openPath, ["path": "/Users/test/notes.txt", "application": Self.application(path: path)], as: client)
        #expect(reason(open, "open") == expected, Comment(rawValue: what))
        #expect(native.launches.isEmpty && native.opens.isEmpty, "neither copy of the identifier stood in for \(what)")
    }

    @Test func aRegistrationThatOutlivedItsBundleIsNotInstalledByIdentifierAlone() async throws {
        let (bench, native, client) = try await Self.bench()
        native.register("\(Self.id).Stale", at: "/Users/test/Stale/Fixture.app")  // nothing is there to inspect
        let reply = try await bench.run(Self.launch, ["application": Self.application("\(Self.id).Stale")], as: client)
        #expect(reason(reply, "launch") == "APPLICATION_NOT_INSTALLED")
        #expect(native.launches.isEmpty)
    }

    @Test func anUnreadableInstallationIsAFailureAtTheActionsPathNeverAbsence() async throws {
        let (bench, native, client) = try await Self.bench()
        native.inspect("/Users/test/Locked/Fixture.app", as: .unreadable("Permission denied"))
        native.register("\(Self.id).Locked", at: "/Users/test/Locked/Fixture.app")
        for (query, variables, field) in [
            (Self.launch, ["application": Self.application(path: "/Users/test/Locked/Fixture.app")], "launch"),
            (Self.launch, ["application": Self.application("\(Self.id).Locked")], "launch"),
            (
                Self.openPath,
                ["path": "/Users/test/notes.txt", "application": Self.application(path: "/Users/test/Locked/Fixture.app")], "open"
            ),
        ] as [(String, [String: Any], String)] {
            let reply = try await bench.run(query, variables, as: client)
            #expect(reply.data?[field] is NSNull)
            #expect(reply.extensions(at: [field])["kind"] as? String == "failed")
        }
        #expect(native.launches.isEmpty && native.opens.isEmpty)
    }
}
