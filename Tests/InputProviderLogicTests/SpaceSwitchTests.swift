import Testing

@testable import InputProviderLogic

/// The checks of `inputSwitchSpace`, from plain shortcut entries and plain lists of Spaces with their types. The
/// contract is "Space switching" in docs/specs/app-input.md. The closures record what the provider would do, and
/// nothing posts an event.
struct SpaceSwitchTests {
    static let koine = KoineIdentity(pid: 400, bundleIdentifier: "dev.antony.Koine")
    static let granted = PostingConsent(accessibility: true, posting: true)
    static let safari = FrontApp(pid: 900, bundleIdentifier: "com.apple.Safari")

    /// One shortcut entry in the form of the route probe and of a real Mac: `enabled`, and three parameters.
    static func entry(enabled: PropertyValue = .boolean(true), parameters: [PropertyValue]) -> PropertyValue {
        .dictionary([
            "enabled": enabled,
            "value": .dictionary(["parameters": .array(parameters), "type": .string("standard")]),
        ])
    }

    /// The parameters of Control and a digit: no character, the key code of the digit, and the mask of Control.
    static func controlDigit(_ keyCode: Int, mask: Int = 262_144) -> [PropertyValue] {
        [.integer(65535), .integer(keyCode), .integer(mask)]
    }

    /// The table with the entries for desktops 1 and 2 on, as the probe left them, beside an unrelated entry.
    static let table: PropertyValue = .dictionary([
        "118": entry(parameters: controlDigit(18)),
        "119": entry(parameters: controlDigit(19)),
        "7": entry(parameters: [.integer(65535), .integer(120), .integer(8_650_752)]),
    ])

    /// One display entry of the SkyLight reply, with Spaces of these types.
    static func display(_ types: [Int]) -> PropertyValue {
        .dictionary([
            "Display Identifier": .string("Main"),
            "Spaces": .array(types.map { .dictionary(["type": .integer($0), "ManagedSpaceID": .integer(1)]) }),
        ])
    }

    /// A record of the calls, in order.
    final class Calls {
        var log: [String] = []
        var posts: [ChordEvent] = []
    }

    func run(
        number: Int = 2, consent: PostingConsent = Self.granted, shortcuts: PropertyValue? = Self.table,
        desktops: PropertyValue? = .array([Self.display([0, 0])]), creates: Bool = true,
        front: FrontApp? = Self.safari, calls: Calls
    ) -> Result<SpaceSwitchOutcome, SpaceSwitchFailure> {
        SpaceSwitch.perform(
            number: number, koine: Self.koine,
            consent: {
                calls.log.append("consent")
                return consent
            },
            shortcuts: {
                calls.log.append("shortcuts")
                return shortcuts
            },
            desktops: {
                calls.log.append("desktops")
                return desktops
            },
            create: { chord in
                calls.log.append("create")
                return creates ? chord : nil
            },
            front: {
                calls.log.append("front")
                return front
            },
            post: { event in
                calls.log.append("post")
                calls.posts.append(event)
            }
        )
    }

    static let everyCheck = ["consent", "shortcuts", "desktops", "create", "front"]

    // MARK: The steps

    /// Every check comes before the first post, and the posts are Control down, the digit down and up with the Control
    /// flag, and Control up.
    @Test func aSwitchPostsControlAndTheDigitAfterEveryCheck() {
        let calls = Calls()
        #expect(run(calls: calls) == .success(.posted))
        #expect(calls.log == Self.everyCheck + Array(repeating: "post", count: 4))
        #expect(
            calls.posts == [
                ChordEvent(keyCode: 59, keyDown: true, flags: 0x0004_0000),
                ChordEvent(keyCode: 19, keyDown: true, flags: 0x0004_0000),
                ChordEvent(keyCode: 19, keyDown: false, flags: 0x0004_0000),
                ChordEvent(keyCode: 59, keyDown: false, flags: 0),
            ])
    }

    /// Each number names entry 117 + N and the digit of the key table.
    @Test(arguments: 1...9)
    func eachNumberUsesItsEntryAndItsDigit(number: Int) {
        let digit = SpaceSwitch.digits[number - 1]
        #expect(digit.rawValue == "DIGIT_\(number)")
        let shortcuts: PropertyValue = .dictionary([String(117 + number): Self.entry(parameters: Self.controlDigit(Int(digit.keyCode)))])
        let calls = Calls()
        let desktops: PropertyValue = .array([Self.display(Array(repeating: 0, count: 9))])
        #expect(run(number: number, shortcuts: shortcuts, desktops: desktops, calls: calls) == .success(.posted))
        #expect(calls.posts.map(\.keyCode) == [59, digit.keyCode, digit.keyCode, 59])
    }

    /// A number outside 1 to 9 is invalid, and Koine attempts nothing, not even the consent checks.
    @Test(arguments: [0, 10, -1, Int.max])
    func aNumberOutsideOneToNineAttemptsNothing(number: Int) {
        let calls = Calls()
        #expect(run(number: number, calls: calls) == .failure(.invalidNumber))
        #expect(calls.log.isEmpty)
    }

    /// Without consent, Koine reads nothing and posts nothing. The message names the access that macOS withholds.
    @Test(arguments: [(false, true), (true, false), (false, false)])
    func withoutConsentNothingIsRead(accessibility: Bool, posting: Bool) {
        let calls = Calls()
        let consent = PostingConsent(accessibility: accessibility, posting: posting)
        #expect(run(consent: consent, calls: calls) == .failure(.permission(consent.refusal!)))
        #expect(calls.log == ["consent"])
    }

    // MARK: The shortcut setting

    /// An absent table, an absent entry and a disabled entry each give SHORTCUT_OFF. A disabled entry gives it
    /// whatever its parameters hold. Koine counts no desktops.
    @Test(arguments: [
        PropertyValue?.none,
        .dictionary([:]),
        .dictionary(["118": SpaceSwitchTests.entry(parameters: SpaceSwitchTests.controlDigit(18))]),
        .dictionary(["119": SpaceSwitchTests.entry(enabled: .boolean(false), parameters: SpaceSwitchTests.controlDigit(19))]),
        .dictionary(["119": SpaceSwitchTests.entry(enabled: .boolean(false), parameters: [])]),
    ])
    func anAbsentOrDisabledShortcutIsOff(shortcuts: PropertyValue?) {
        let calls = Calls()
        #expect(run(shortcuts: shortcuts, calls: calls) == .success(.shortcutOff))
        #expect(calls.log == ["consent", "shortcuts"])
    }

    /// Another key code, or a mask other than Control alone, gives SHORTCUT_REMAPPED. The mask with the Fn bit is the
    /// one that entries 7 and 8 hold on Antony's Mac: 8650752, which is Control with 8388608.
    @Test(arguments: [
        (19, 8_650_752),
        (19, 262_144 | 131_072),
        (19, 262_144 | 1_048_576),
        (19, 0),
        (18, 262_144),
        (83, 262_144),
    ])
    func anotherKeyOrMaskIsRemapped(keyCode: Int, mask: Int) {
        let shortcuts: PropertyValue = .dictionary(["119": Self.entry(parameters: Self.controlDigit(keyCode, mask: mask))])
        let calls = Calls()
        #expect(run(shortcuts: shortcuts, calls: calls) == .success(.shortcutRemapped))
        #expect(calls.log == ["consent", "shortcuts"])
    }

    /// Koine ignores the character, the first parameter.
    @Test func theCharacterIsIgnored() {
        let shortcuts: PropertyValue = .dictionary([
            "119": Self.entry(parameters: [.integer(50), .integer(19), .integer(262_144)])
        ])
        let calls = Calls()
        #expect(run(shortcuts: shortcuts, calls: calls) == .success(.posted))
    }

    /// A table or an entry in another form fails, and Koine posts nothing.
    @Test(arguments: [
        PropertyValue.array([]),
        .dictionary(["119": .array([])]),
        .dictionary(["119": .dictionary(["value": .dictionary(["parameters": .array(SpaceSwitchTests.controlDigit(19))])])]),
        .dictionary(["119": SpaceSwitchTests.entry(enabled: .integer(1), parameters: SpaceSwitchTests.controlDigit(19))]),
        .dictionary(["119": SpaceSwitchTests.entry(enabled: .string("1"), parameters: SpaceSwitchTests.controlDigit(19))]),
        .dictionary(["119": .dictionary(["enabled": .boolean(true)])]),
        .dictionary(["119": SpaceSwitchTests.entry(parameters: [.integer(19), .integer(262_144)])]),
        .dictionary(["119": SpaceSwitchTests.entry(parameters: SpaceSwitchTests.controlDigit(19) + [.integer(0)])]),
        .dictionary(["119": SpaceSwitchTests.entry(parameters: [.integer(65535), .string("19"), .integer(262_144)])]),
        .dictionary(["119": SpaceSwitchTests.entry(parameters: [.integer(65535), .integer(19), .other])]),
    ])
    func aShortcutInAnotherFormFails(shortcuts: PropertyValue) {
        let calls = Calls()
        #expect(run(shortcuts: shortcuts, calls: calls) == .failure(.shortcutUnreadable))
        #expect(calls.log == ["consent", "shortcuts"])
    }

    // MARK: The Mission Control desktops

    /// With one display, the desktops are its Spaces of type 0. A full-screen Space, type 4, is skipped.
    @Test(arguments: [
        ([0, 0], 2, SpaceSwitchOutcome.posted),
        ([0], 2, .noSuchDesktop),
        ([0, 4], 2, .noSuchDesktop),
        ([4, 0, 4, 0], 2, .posted),
        ([0, 0, 0], 3, .posted),
        ([], 1, .noSuchDesktop),
    ])
    func oneDisplayCountsItsDesktops(types: [Int], number: Int, outcome: SpaceSwitchOutcome) {
        let shortcuts: PropertyValue = .dictionary([
            String(117 + number): Self.entry(parameters: Self.controlDigit(Int(SpaceSwitch.digits[number - 1].keyCode)))
        ])
        let calls = Calls()
        let result = run(number: number, shortcuts: shortcuts, desktops: .array([Self.display(types)]), calls: calls)
        #expect(result == .success(outcome))
        if outcome == .noSuchDesktop {
            #expect(calls.log == ["consent", "shortcuts", "desktops"])
            #expect(calls.posts.isEmpty)
        }
    }

    /// With two displays, Koine counts the desktops of both, in the order of the reply.
    @Test(arguments: [
        ([[0], [0]], 2, SpaceSwitchOutcome.posted),
        ([[0, 4], [4, 0]], 2, .posted),
        ([[0, 0], [0]], 3, .posted),
        ([[0, 4], [4]], 2, .noSuchDesktop),
        ([[0], [0]], 3, .noSuchDesktop),
        ([[], [0, 0]], 2, .posted),
    ])
    func twoDisplaysCountTheDesktopsOfBoth(types: [[Int]], number: Int, outcome: SpaceSwitchOutcome) {
        let shortcuts: PropertyValue = .dictionary([
            String(117 + number): Self.entry(parameters: Self.controlDigit(Int(SpaceSwitch.digits[number - 1].keyCode)))
        ])
        let calls = Calls()
        let result = run(
            number: number, shortcuts: shortcuts, desktops: .array(types.map(Self.display)), calls: calls)
        #expect(result == .success(outcome))
        #expect(MissionControlDesktops.count(.array(types.map(Self.display))) == types.flatMap { $0 }.filter { $0 == 0 }.count)
    }

    /// A missing SkyLight symbol, no reply, or a reply in another form fails, and Koine posts nothing.
    @Test(arguments: [
        PropertyValue?.none,
        .dictionary([:]),
        .array([.array([])]),
        .array([.dictionary(["Display Identifier": .string("Main")])]),
        .array([.dictionary(["Spaces": .dictionary([:])])]),
        .array([.dictionary(["Spaces": .array([.integer(0)])])]),
        .array([.dictionary(["Spaces": .array([.dictionary(["ManagedSpaceID": .integer(1)])])])]),
        .array([.dictionary(["Spaces": .array([.dictionary(["type": .string("0")])])])]),
        .array([SpaceSwitchTests.display([0, 0]), .other]),
    ])
    func uncountableDesktopsFail(desktops: PropertyValue?) {
        let calls = Calls()
        #expect(run(desktops: desktops, calls: calls) == .failure(.desktopsUncountable))
        #expect(calls.log == ["consent", "shortcuts", "desktops"])
    }

    // MARK: The events and the front app

    /// When macOS does not create every event, Koine posts none of them, so Control does not stay down.
    @Test func anEventThatIsNotCreatedPostsNothing() {
        let calls = Calls()
        #expect(run(creates: false, calls: calls) == .failure(.eventNotCreated))
        #expect(calls.log == ["consent", "shortcuts", "desktops", "create"])
        #expect(calls.posts.isEmpty)
    }

    /// While Koine is the front app, the outcome is PROTECTED_FRONT_APP and Koine posts nothing. Koine recognises
    /// itself by its process identifier, and another copy of Koine by its bundle identifier.
    @Test(arguments: [
        FrontApp(pid: 400, bundleIdentifier: nil),
        FrontApp(pid: 400, bundleIdentifier: "dev.antony.Koine"),
        FrontApp(pid: 401, bundleIdentifier: "dev.antony.Koine"),
    ])
    func koineInFrontPostsNothing(front: FrontApp) {
        let calls = Calls()
        #expect(run(front: front, calls: calls) == .success(.protectedFrontApp))
        #expect(calls.log == Self.everyCheck)
        #expect(calls.posts.isEmpty)
    }

    /// With no front app, nothing is Koine, so Koine posts.
    @Test func noFrontAppPosts() {
        let calls = Calls()
        #expect(run(front: nil, calls: calls) == .success(.posted))
        #expect(calls.posts.count == 4)
    }
}
