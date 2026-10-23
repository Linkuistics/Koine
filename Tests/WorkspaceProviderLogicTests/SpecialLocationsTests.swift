import Foundation
import KoineProviderAPI
import Testing

@testable import WorkspaceProviderLogic

/// The real workspace provider over a substituted native adapter: the special-locations query's request
/// rules and how Foundation's answers become a result. Nothing here reads the system.
@Suite struct SpecialLocationsTests {
    typealias Fields = [String: ProviderValue]

    /// The ten default pairs and a value for each, as Foundation would report them for one account.
    static let defaultValues: [(kind: String, domain: String, locations: [String])] = [
        ("HOME", "USER", ["/Users/test"]), ("DESKTOP", "USER", ["/Users/test/Desktop"]),
        ("DOCUMENTS", "USER", ["/Users/test/Documents"]), ("DOWNLOADS", "USER", ["/Users/test/Downloads"]),
        ("MOVIES", "USER", ["/Users/test/Movies"]), ("MUSIC", "USER", ["/Users/test/Music"]),
        ("PICTURES", "USER", ["/Users/test/Pictures"]), ("APPLICATIONS", "USER", ["/Users/test/Applications"]),
        ("APPLICATIONS", "LOCAL", ["/Applications"]),
        ("APPLICATIONS", "SYSTEM", ["/System/Applications", "/System/Cryptexes/App/System/Applications"]),
    ]

    static func pair(_ kind: String, _ domain: String) -> LocationPair {
        LocationPair(kind: LocationKind(rawValue: kind)!, domain: LocationDomain(rawValue: domain)!)
    }

    static func bench(arranging values: [(kind: String, domain: String, locations: [String])] = defaultValues)
        -> (native: FakeNative, provider: WorkspaceProvider)
    {
        let native = FakeNative()
        for value in values { native.locationValues(pair(value.kind, value.domain), value.locations) }
        return (native, WorkspaceProvider(native: native))
    }

    static func request(_ requests: ProviderValue? = nil, parent: ProviderValue? = nil) -> ResolutionRequest {
        ResolutionRequest(
            resolverId: "specialLocations", arguments: requests.map { ["requests": $0] } ?? [:], parent: parent)
    }

    static func entry(_ kind: String, _ domain: String) -> ProviderValue {
        .object(["kind": .string(kind), "domain": .string(domain)])
    }

    static func fields(_ result: ResolutionResult) -> Fields? {
        if case .success(.object(let fields)) = result { return fields }
        return nil
    }

    static func success(_ result: ResolutionResult) -> ProviderValue? {
        if case .success(let value) = result { return value }
        return nil
    }

    static func failure(_ result: ResolutionResult) -> ProviderFailure? {
        if case .failure(let failure) = result { return failure }
        return nil
    }

    static func items(_ fields: Fields) -> [Fields] {
        guard case .list(let list)? = fields["items"] else { return [] }
        return list.compactMap { if case .object(let item) = $0 { item } else { nil } }
    }

    static func coverage(_ fields: Fields) -> Fields? {
        guard case .list(let list)? = fields["sources"], case .object(let first)? = list.first else { return nil }
        return first
    }

    static func diagnostics(_ fields: Fields) -> [Fields] {
        guard let coverage = coverage(fields), case .list(let list)? = coverage["diagnostics"] else { return [] }
        return list.compactMap { if case .object(let item) = $0 { item } else { nil } }
    }

    // MARK: The default set

    @Test func anOmittedRequestReturnsTheTenDefaultPairsInTheDeclaredOrder() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))

        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(fields["resultsTruncated"] == .bool(false))
        let items = Self.items(fields)
        // The system gives two values for the system applications folder, and each is an item of its own.
        // The system gives two values for the system applications folder, and each is an item of its own.
        let pairs = items.map { item -> String in
            guard case .string(let kind)? = item["kind"], case .string(let domain)? = item["domain"] else { return "" }
            return "\(kind)/\(domain)"
        }
        #expect(
            pairs == [
                "HOME/USER", "DESKTOP/USER", "DOCUMENTS/USER", "DOWNLOADS/USER", "MOVIES/USER", "MUSIC/USER",
                "PICTURES/USER", "APPLICATIONS/USER", "APPLICATIONS/LOCAL", "APPLICATIONS/SYSTEM",
                "APPLICATIONS/SYSTEM",
            ])
        #expect(
            LocationPair.defaults.count == 10 && native.specialLocationLog == LocationPair.defaults,
            "each default pair was looked up once, in order")
    }

    @Test func eachValueCarriesItsKindDomainAccountAndFoundationProvenance() async throws {
        let (_, provider) = Self.bench()
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))
        let home = try #require(Self.items(fields).first)
        #expect(
            home == [
                "kind": .string("HOME"), "domain": .string("USER"), "accountIdentifier": .string("501"),
                "location": .string("/Users/test"), "contentsAvailability": .string("UNKNOWN"),
                "sources": .list([.string("FOUNDATION_LOCATIONS")]),
            ])
        for item in Self.items(fields) {
            #expect(item["contentsAvailability"] == .string("UNKNOWN"), "a starting value says nothing of its contents")
        }
    }

    @Test func theSourceReportsACompleteLookupAndNeverCompleteContents() async throws {
        let (_, provider) = Self.bench()
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))
        #expect(
            Self.coverage(fields) == [
                "source": .string("FOUNDATION_LOCATIONS"), "declaredDomain": .string("default special locations"),
                "availability": .string("AVAILABLE"), "observations": .string("COMPLETE"),
                "category": .string("UNKNOWN"), "examined": .int(10), "diagnostics": .list([]),
            ])
    }

    @Test func aQueryOnlyAsksFoundationForValues() async throws {
        let (native, provider) = Self.bench()
        _ = await provider.resolve(Self.request())
        // Nothing was resolved, inspected, read, registered or submitted: a returned value promises no more
        // than the system's word.
        #expect(native.resolved.isEmpty && native.pathInspected.isEmpty && native.bundleReads.isEmpty)
        #expect(native.registrationLookups.isEmpty && native.rootChecks.isEmpty && native.documentLookups.isEmpty)
        #expect(native.launches.isEmpty && native.opens.isEmpty && native.pathOpens.isEmpty && native.reveals.isEmpty)
    }

    // MARK: Requested pairs

    @Test func requestedPairsAreReturnedInTheOrderRequested() async throws {
        let (native, provider) = Self.bench()
        let requests: ProviderValue = .list([Self.entry("APPLICATIONS", "SYSTEM"), Self.entry("HOME", "USER")])
        let fields = try #require(Self.fields(await provider.resolve(Self.request(requests))))
        #expect(fields["status"] == .string("AVAILABLE"))
        #expect(
            Self.items(fields).compactMap { item -> String? in
                if case .string(let location)? = item["location"] { return location } else { return nil }
            } == ["/System/Applications", "/System/Cryptexes/App/System/Applications", "/Users/test"])
        #expect(native.specialLocationLog == [Self.pair("APPLICATIONS", "SYSTEM"), Self.pair("HOME", "USER")])
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["declaredDomain"] == .string("requested special locations") && coverage["examined"] == .int(2))
    }

    @Test func anExplicitNullIsTheDefaultSet() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(Self.fields(await provider.resolve(Self.request(.null))))
        #expect(Self.items(fields).count == 11)
        #expect(native.specialLocationLog == LocationPair.defaults)
    }

    // MARK: Refused requests

    @Test(arguments: [
        ("a duplicate pair", [("HOME", "USER"), ("HOME", "USER")], "more than once"),
        ("an unsupported pair", [("DOCUMENTS", "LOCAL")], "has no LOCAL location"),
        ("a system home", [("HOME", "SYSTEM")], "has no SYSTEM location"),
        ("a duplicate after a valid pair", [("APPLICATIONS", "USER"), ("MUSIC", "USER"), ("MUSIC", "USER")], "more than once"),
    ])
    func aRefusedRequestIsInvalidInputAndAsksTheSystemNothing(
        _ name: String, _ pairs: [(String, String)], _ message: String
    ) async throws {
        let (native, provider) = Self.bench()
        let requests: ProviderValue = .list(pairs.map { Self.entry($0.0, $0.1) })
        let failure = try #require(Self.failure(await provider.resolve(Self.request(requests))), Comment(rawValue: name))
        #expect(failure.kind == .invalidInput)
        #expect(failure.message.contains(message), Comment(rawValue: "\(name): \(failure.message)"))
        #expect(native.specialLocationLog.isEmpty, "a refusal precedes every lookup")
    }

    @Test func moreThanTenPairsAreRefusedByCountBeforeAnyPairIsExamined() async throws {
        let (native, provider) = Self.bench()
        // Only ten distinct pairs exist, so eleven entries must repeat one: the count rule still speaks first.
        let requests: ProviderValue = .list(LocationPair.defaults.map { Self.entry($0.kind.rawValue, $0.domain.rawValue) }
            + [Self.entry("HOME", "USER")])
        let failure = try #require(Self.failure(await provider.resolve(Self.request(requests))))
        #expect(failure.kind == .invalidInput)
        #expect(failure.message.contains("more than 10"), Comment(rawValue: failure.message))
        #expect(native.specialLocationLog.isEmpty)
    }

    @Test func anEmptyListIsRefusedAndTenDistinctPairsAreNot() async throws {
        let (native, provider) = Self.bench()
        let empty = try #require(Self.failure(await provider.resolve(Self.request(.list([])))))
        #expect(empty.kind == .invalidInput)
        let ten = LocationPair.defaults.map { Self.entry($0.kind.rawValue, $0.domain.rawValue) }
        #expect(Self.fields(await provider.resolve(Self.request(.list(ten)))) != nil)
        #expect(native.specialLocationLog.count == 10, "only the accepted request looked anything up")
    }

    @Test(arguments: [
        ProviderValue.string("HOME"), .list([.string("HOME")]), .list([.object(["kind": .string("HOME")])]),
        .list([.object(["kind": .string("ELSEWHERE"), "domain": .string("USER")])]),
    ])
    func aMalformedRequestIsInvalidInput(_ requests: ProviderValue) async throws {
        let (native, provider) = Self.bench()
        let failure = try #require(Self.failure(await provider.resolve(Self.request(requests))))
        #expect(failure.kind == .invalidInput)
        #expect(native.specialLocationLog.isEmpty)
    }

    // MARK: What the system does not give

    @Test func anAbsentNativeValueIsUnknownWithNoNativeValueAndTheRestStandsPartial() async throws {
        let (_, provider) = Self.bench(
            arranging: Array(Self.defaultValues.filter { $0.kind != "MUSIC" }))
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))

        #expect(fields["status"] == .string("PARTIAL"))
        #expect(Self.items(fields).count == 10, "the other nine pairs are all there")
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["availability"] == .string("AVAILABLE") && coverage["observations"] == .string("PARTIAL"))
        #expect(coverage["category"] == .string("UNKNOWN") && coverage["examined"] == .int(10))
        let diagnostics = Self.diagnostics(fields)
        #expect(diagnostics.count == 1)
        #expect(diagnostics[0]["reason"] == .string("NO_NATIVE_VALUE") && diagnostics[0]["source"] == .string("FOUNDATION_LOCATIONS"))
        #expect(diagnostics[0]["affectsCoverage"] == .bool(true))
        #expect(diagnostics[0]["subject"] == .null && diagnostics[0]["permission"] == .null)
    }

    @Test func noNativeValueAtAllIsUnknownWithNullItems() async throws {
        let (_, provider) = Self.bench(arranging: [])
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("UNKNOWN"))
        #expect(fields["items"] == .null)
        let coverage = try #require(Self.coverage(fields))
        #expect(coverage["availability"] == .string("UNKNOWN") && coverage["observations"] == .string("UNKNOWN"))
        #expect(Self.diagnostics(fields).count == 10)
        #expect(Self.diagnostics(fields).allSatisfy { $0["reason"] == .string("NO_NATIVE_VALUE") })
        // An unknown outcome raises nothing at `items`; it is an ordinary null.
        let items = await provider.resolve(
            ResolutionRequest(resolverId: "frozen.items", arguments: [:], parent: .object(fields)))
        #expect(Self.success(items) == .null)
    }

    @Test(arguments: ["relative/path", "", "/with\u{0}nul", "/" + String(repeating: "a", count: 8192)])
    func aValueOutsideTheBoundsIsWithheldNeverRepaired(_ value: String) async throws {
        let (_, provider) = Self.bench(
            arranging: Self.defaultValues.map { $0.kind == "MOVIES" ? ($0.kind, $0.domain, [value]) : $0 })
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))
        #expect(fields["status"] == .string("PARTIAL"))
        #expect(Self.items(fields).count == 10, "the unusable value is not among the eleven")
        #expect(
            Self.items(fields).allSatisfy { $0["kind"] != .string("MOVIES") },
            "no shortened or repaired spelling stands in for it")
        #expect(Self.diagnostics(fields).map { $0["reason"] } == [.string("UNREPRESENTABLE_VALUE")])
    }

    @Test func onlyUnusableValuesAreFailedAndRaiseAtItems() async throws {
        let (_, provider) = Self.bench(arranging: [("HOME", "USER", ["not absolute"])])
        let requests: ProviderValue = .list([Self.entry("HOME", "USER")])
        let fields = try #require(Self.fields(await provider.resolve(Self.request(requests))))
        #expect(fields["status"] == .string("FAILED") && fields["items"] == .null)
        let items = await provider.resolve(
            ResolutionRequest(resolverId: "frozen.items", arguments: [:], parent: .object(fields)))
        let failure = try #require(Self.failure(items))
        #expect(failure.kind == .failed)
        // The status and the diagnostics stay readable without selecting `items`.
        #expect(Self.diagnostics(fields).map { $0["reason"] } == [.string("UNREPRESENTABLE_VALUE")])
    }

    @Test func anAvailableResultHandsItsFrozenItemsToEveryAlias() async throws {
        let (native, provider) = Self.bench()
        let fields = try #require(Self.fields(await provider.resolve(Self.request())))
        let before = native.specialLocationLog.count
        for _ in 0..<2 {
            let items = await provider.resolve(
                ResolutionRequest(resolverId: "frozen.items", arguments: [:], parent: .object(fields)))
            #expect(Self.success(items) == fields["items"])
        }
        #expect(native.specialLocationLog.count == before, "a nested alias reads its frozen parent and asks nothing")
    }
}
