import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: how the fixed index query's items become
/// choices, and what each end of the query means for status and coverage. Nothing here reads the system.
@Suite struct ApplicationCatalogueTests {
    typealias Fields = [String: ProviderValue]

    static func app(
        _ path: String?, identifier: String? = nil, name: String? = nil,
        tree: [String]? = ["com.apple.application-bundle", "com.apple.bundle", "public.directory"]
    ) -> IndexedApplication {
        IndexedApplication(path: path, contentTypeTree: tree, bundleIdentifier: identifier, displayName: name)
    }

    static let safari = app("/Applications/Safari.app", identifier: "com.apple.Safari", name: "Safari")
    static let finder = app("/System/Library/CoreServices/Finder.app", identifier: "com.apple.finder", name: "Finder")

    static func bench(_ read: IndexedApplicationsRead) -> (native: FakeNative, provider: WorkspaceProvider) {
        let native = FakeNative()
        native.index(read)
        return (native, WorkspaceProvider(native: native, indexWait: .milliseconds(250)))
    }

    static func query(_ provider: WorkspaceProvider) async -> Fields? {
        SpecialLocationsTests.fields(
            await provider.resolve(ResolutionRequest(resolverId: "applications", arguments: [:], parent: nil)))
    }

    static func choices(_ fields: Fields) -> [Fields] { SpecialLocationsTests.items(fields) }
    static func coverage(_ fields: Fields) -> Fields? { SpecialLocationsTests.coverage(fields) }
    static func reasons(_ fields: Fields) -> [ProviderValue?] { SpecialLocationsTests.diagnostics(fields).map { $0["reason"] } }

    // MARK: Items become choices

    @Test func eachIndexedItemIsAChoiceWithItsPathNameIdentifierAndTheIndexSource() async throws {
        let (_, provider) = Self.bench(.gathered([Self.safari, Self.finder]))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("AVAILABLE") && fields["resultsTruncated"] == .bool(false))
        #expect(
            Self.choices(fields) == [
                [
                    "applicationPath": .string("/Applications/Safari.app"), "name": .string("Safari"),
                    "bundleIdentifier": .string("com.apple.Safari"), "sources": .list([.string("INDEXED_APPS")]),
                ],
                [
                    "applicationPath": .string("/System/Library/CoreServices/Finder.app"), "name": .string("Finder"),
                    "bundleIdentifier": .string("com.apple.finder"), "sources": .list([.string("INDEXED_APPS")]),
                ],
            ])
    }

    @Test func theNameIsWhatTheIndexReportsAndIsNeverReadFromThePath() async throws {
        let (_, provider) = Self.bench(.gathered([Self.app("/Applications/Zed Preview.app", identifier: "dev.zed.Zed-Preview", name: "Zed")]))
        let fields = try #require(await Self.query(provider))
        #expect(Self.choices(fields).first?["name"] == .string("Zed"))
    }

    @Test func aCompleteGatheringIsAvailableCompleteAndNeverCompleteForTheCategory() async throws {
        let (_, provider) = Self.bench(.gathered([Self.safari]))
        let fields = try #require(await Self.query(provider))
        #expect(
            Self.coverage(fields) == [
                "source": .string("INDEXED_APPS"), "declaredDomain": .string("indexed local computer applications"),
                "availability": .string("AVAILABLE"), "observations": .string("COMPLETE"),
                "category": .string("UNKNOWN"), "examined": .int(1), "diagnostics": .list([]),
            ])
    }

    @Test func twoCopiesOfOneIdentifierStayTwoChoicesInTheIndexsOrder() async throws {
        let (_, provider) = Self.bench(
            .gathered([
                Self.app("/Applications/Zed.app", identifier: "dev.zed.Zed", name: "Zed"),
                Self.app("/Users/test/Applications/Zed.app", identifier: "dev.zed.Zed", name: "Zed"),
            ]))
        let fields = try #require(await Self.query(provider))
        #expect(
            Self.choices(fields).map { $0["applicationPath"] } == [
                .string("/Applications/Zed.app"), .string("/Users/test/Applications/Zed.app"),
            ])
        #expect(fields["status"] == .string("AVAILABLE"))
    }

    @Test func aBundleWithoutAnIdentifierIsAChoiceWithANullIdentifier() async throws {
        let (_, provider) = Self.bench(.gathered([Self.app("/Applications/Tool.app", name: "Tool")]))
        let fields = try #require(await Self.query(provider))
        #expect(Self.choices(fields).first?["bundleIdentifier"] == .null)
        #expect(fields["status"] == .string("AVAILABLE"), "the index reported none, which is not a withheld value")
    }

    @Test func anItemWithNoTypeTreeIsKeptBecauseTheQueryAlreadySelectedIt() async throws {
        let (_, provider) = Self.bench(.gathered([Self.app("/Applications/Tool.app", identifier: "x.Tool", name: "Tool", tree: nil)]))
        let fields = try #require(await Self.query(provider))
        #expect(Self.choices(fields).count == 1 && fields["status"] == .string("AVAILABLE"))
    }

    // MARK: Withheld values

    @Test(arguments: [nil, "relative/Tool.app", "", "/with\u{0}nul", "/" + String(repeating: "a", count: 8192)] as [String?])
    func anItemWithoutAUsablePathIsWithheldAndTheRestAreStillReported(_ path: String?) async throws {
        let (_, provider) = Self.bench(.gathered([Self.safari, Self.app(path, identifier: "x.Tool", name: "Tool")]))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("PARTIAL"))
        #expect(Self.choices(fields).map { $0["applicationPath"] } == [.string("/Applications/Safari.app")])
        #expect(Self.reasons(fields) == [.string("UNREPRESENTABLE_VALUE")])
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["observations"] == .string("PARTIAL") && coverage["availability"] == .string("AVAILABLE"))
        #expect(coverage["examined"] == .int(2))
    }

    @Test func anItemWhoseTypeTreeLacksTheQueriedTypeIsWithheld() async throws {
        let (_, provider) = Self.bench(
            .gathered([Self.safari, Self.app("/Users/test/notes.txt", name: "notes", tree: ["public.plain-text"])]))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("PARTIAL"))
        #expect(Self.choices(fields).count == 1)
        #expect(Self.reasons(fields) == [.string("METADATA_UNKNOWN")])
    }

    @Test(arguments: [nil, "", "with\u{0}nul", String(repeating: "n", count: 1025)] as [String?])
    func anUnusableNameIsNullAndTheChoiceStaysPartial(_ name: String?) async throws {
        let (_, provider) = Self.bench(.gathered([Self.app("/Applications/Tool.app", identifier: "x.Tool", name: name)]))
        let fields = try #require(await Self.query(provider))
        #expect(Self.choices(fields).first?["name"] == .null, "no name is made up from the path or shortened")
        #expect(fields["status"] == .string("PARTIAL") && Self.reasons(fields) == [.string("METADATA_UNKNOWN")])
    }

    @Test(arguments: ["", "with\u{0}nul", String(repeating: "i", count: 513)])
    func anUnusableIdentifierIsNullAndTheChoiceStaysPartial(_ identifier: String) async throws {
        let (_, provider) = Self.bench(.gathered([Self.app("/Applications/Tool.app", identifier: identifier, name: "Tool")]))
        let fields = try #require(await Self.query(provider))
        #expect(Self.choices(fields).first?["bundleIdentifier"] == .null)
        #expect(fields["status"] == .string("PARTIAL") && Self.reasons(fields) == [.string("UNREPRESENTABLE_VALUE")])
    }

    @Test func eachReasonIsOneDiagnosticWhateverThePopulation() async throws {
        let withheld = (0..<200).map { Self.app("not/absolute/\($0)", name: "n\($0)") }
        let (_, provider) = Self.bench(.gathered([Self.safari] + withheld))
        let fields = try #require(await Self.query(provider))
        #expect(Self.reasons(fields) == [.string("UNREPRESENTABLE_VALUE")], "the detail sink cannot fill")
    }

    @Test func whenNoItemIsUsableTheResultIsFailedAndRaisesAtItems() async throws {
        let (_, provider) = Self.bench(.gathered([Self.app(nil, name: "Ghost")]))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("FAILED") && fields["items"] == .null)
        let items = await provider.resolve(
            ResolutionRequest(resolverId: "frozen.applicationItems", arguments: [:], parent: .object(fields)))
        #expect(SpecialLocationsTests.failure(items)?.kind == .failed)
        // The status and the diagnostics stay readable without selecting `items`.
        #expect(Self.reasons(fields) == [.string("UNREPRESENTABLE_VALUE")])
    }

    // MARK: The ends of the query

    @Test func aFinishedGatheringWithNoItemsIsUnknownNeverAnEmptyInventory() async throws {
        let (_, provider) = Self.bench(.gathered([]))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("UNKNOWN") && fields["items"] == .null)
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["availability"] == .string("UNKNOWN") && coverage["observations"] == .string("UNKNOWN"))
        #expect(coverage["examined"] == .int(0))
        #expect(Self.reasons(fields) == [.string("METADATA_UNKNOWN")])
        // An unknown outcome raises nothing at `items`; it is an ordinary null.
        let items = await provider.resolve(
            ResolutionRequest(resolverId: "frozen.applicationItems", arguments: [:], parent: .object(fields)))
        #expect(SpecialLocationsTests.success(items) == .null)
    }

    @Test func aGatheringThatDidNotFinishIsFailedWithATimeLimitAndNoPrefix() async throws {
        let (_, provider) = Self.bench(.unfinished)
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("FAILED") && fields["items"] == .null)
        #expect(Self.reasons(fields) == [.string("TIME_LIMIT")])
        #expect(fields["resultsTruncated"] == .bool(false), "nothing was observed, so nothing was omitted")
        let items = await provider.resolve(
            ResolutionRequest(resolverId: "frozen.applicationItems", arguments: [:], parent: .object(fields)))
        #expect(SpecialLocationsTests.failure(items)?.kind == .failed)
    }

    @Test func moreItemsThanTheLimitIsFailedWithAnEntryLimitAndNoPrefix() async throws {
        let (native, provider) = Self.bench(.overLimit)
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("FAILED") && fields["items"] == .null)
        #expect(Self.reasons(fields) == [.string("ENTRY_LIMIT")])
        #expect(native.indexedQueries.first?.limit == 2048)
    }

    @Test func aQueryThatDidNotStartIsFailed() async throws {
        let (_, provider) = Self.bench(.failed("no index"))
        let fields = try #require(await Self.query(provider))
        #expect(fields["status"] == .string("FAILED") && fields["items"] == .null)
        #expect(Self.reasons(fields) == [.string("INSPECTION_FAILED")])
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["availability"] == .string("UNKNOWN") && coverage["observations"] == .string("UNKNOWN"))
    }

    // MARK: What the query touches

    @Test func theQueryRunsTheOneFixedIndexQueryAndTouchesNothingElse() async throws {
        let (native, provider) = Self.bench(.gathered([Self.safari]))
        _ = await Self.query(provider)
        #expect(native.indexedQueries.count == 1)
        #expect(native.indexedQueries.first?.wait == .milliseconds(250))
        #expect(native.specialLocationLog.isEmpty)
        #expect(native.resolved.isEmpty && native.pathInspected.isEmpty && native.bundleReads.isEmpty)
        #expect(native.registrationLookups.isEmpty && native.rootChecks.isEmpty && native.documentLookups.isEmpty)
        #expect(native.launches.isEmpty && native.opens.isEmpty && native.pathOpens.isEmpty && native.reveals.isEmpty)
    }

    @Test func anAvailableResultHandsItsFrozenItemsToEveryAliasWithoutAskingAgain() async throws {
        let (native, provider) = Self.bench(.gathered([Self.safari]))
        let fields = try #require(await Self.query(provider))
        for _ in 0..<2 {
            let items = await provider.resolve(
                ResolutionRequest(resolverId: "frozen.applicationItems", arguments: [:], parent: .object(fields)))
            #expect(SpecialLocationsTests.success(items) == fields["items"])
        }
        #expect(native.indexedQueries.count == 1, "a nested alias reads its frozen parent and queries nothing")
    }
}
