import Testing

@testable import InputProviderLogic

/// The order of the steps of `inputSendKeystroke`. The contract is "Sending a chord" in docs/specs/app-input.md. The
/// closures record what the provider would do, and nothing posts an event.
struct KeystrokeStepTests {
    static let koine = KoineIdentity(pid: 400, bundleIdentifier: "dev.antony.Koine")
    static let safari = AppFacts(localizedName: "Safari", executableName: "Safari", bundleIdentifier: "com.apple.Safari")
    static let target = "koine://input/target/900/1764300000000001"
    static let granted = PostingConsent(accessibility: true, posting: true)

    /// A record of the calls, in order.
    final class Calls {
        var log: [String] = []
        var posts: [(ChordEvent, Int32)] = []
    }

    func run(
        reference: String = Self.target, key: InputKey = .t, modifiers: [InputModifier] = [.command, .shift],
        consent: PostingConsent = Self.granted, lookup: TargetLookup = .live(app: Self.safari), creates: Bool = true,
        calls: Calls
    ) -> Result<KeystrokeOutcome, KeystrokeFailure> {
        Keystroke.perform(
            reference: reference, key: key, modifiers: modifiers, koine: Self.koine,
            consent: {
                calls.log.append("consent")
                return consent
            },
            lookup: { _ in
                calls.log.append("lookup")
                return lookup
            },
            create: { chord in
                calls.log.append("create")
                return creates ? chord : nil
            },
            post: { event, pid in
                calls.log.append("post")
                calls.posts.append((event, pid))
            }
        )
    }

    /// Every check comes before the first post, and the posts are the events of the chord, in order, to the target's
    /// process identifier.
    @Test func aChordToAnAppIsSentAfterEveryCheck() {
        let calls = Calls()
        #expect(run(calls: calls) == .success(.sent))
        #expect(calls.log == ["consent", "lookup", "create"] + Array(repeating: "post", count: 6))
        #expect(calls.posts.map(\.0) == Chord.events(key: .t, modifiers: [.command, .shift]))
        #expect(calls.posts.allSatisfy { $0.1 == 900 })
    }

    /// Without consent, Koine looks at nothing else and sends nothing. The message names the access that macOS
    /// withholds.
    @Test(arguments: [(false, true), (true, false), (false, false)])
    func withoutConsentNothingIsSent(accessibility: Bool, posting: Bool) {
        let calls = Calls()
        let consent = PostingConsent(accessibility: accessibility, posting: posting)
        #expect(run(consent: consent, calls: calls) == .failure(.permission(consent.refusal!)))
        #expect(calls.log == ["consent"])
    }

    /// A malformed or wrong-kind reference is unavailable before any lookup.
    @Test(arguments: ["koine://desktop/application/900/1764300000000001", "koine://input/target/900"])
    func aReferenceThatNamesNoTargetIsUnavailable(reference: String) {
        let calls = Calls()
        #expect(run(reference: reference, calls: calls) == .failure(.unavailable(Keystroke.malformed)))
        #expect(calls.log == ["consent"])
    }

    /// An ended process, or one with another start instant, is unavailable: a stale target.
    @Test func aStaleTargetIsUnavailable() {
        let calls = Calls()
        #expect(run(lookup: .gone, calls: calls) == .failure(.unavailable(Keystroke.gone)))
        #expect(calls.log == ["consent", "lookup"])
    }

    @Test func anUnreadableProcessFails() {
        let calls = Calls()
        #expect(run(lookup: .unreadable("EIO"), calls: calls) == .failure(.unreadable("EIO")))
        #expect(calls.log == ["consent", "lookup"])
    }

    /// Koine itself is the protected target: the outcome is PROTECTED_TARGET, with no error, and Koine creates and
    /// sends nothing. The check holds by process identifier whether or not macOS reports the process as an app, and
    /// by bundle identifier for another copy of Koine.
    @Test(arguments: [
        ("koine://input/target/400/1", TargetLookup.live(app: nil)),
        ("koine://input/target/400/1", TargetLookup.live(app: AppFacts(localizedName: "Koine", executableName: "Koine", bundleIdentifier: "dev.antony.Koine"))),
        ("koine://input/target/401/1", TargetLookup.live(app: AppFacts(localizedName: "Koine", executableName: "Koine", bundleIdentifier: "dev.antony.Koine"))),
    ])
    func koineIsRefusedWithAnOutcome(reference: String, lookup: TargetLookup) {
        let calls = Calls()
        #expect(run(reference: reference, lookup: lookup, calls: calls) == .success(.protectedTarget))
        #expect(calls.log == ["consent", "lookup"])
    }

    /// A process that macOS does not report as an app is unavailable, and Koine sends it nothing.
    @Test func aProcessThatIsNotAnAppIsUnavailable() {
        let calls = Calls()
        #expect(run(lookup: .live(app: nil), calls: calls) == .failure(.unavailable(Keystroke.notAnApp)))
        #expect(calls.log == ["consent", "lookup"])
    }

    /// When macOS does not create every event, Koine sends none of them, so no modifier stays down in the target.
    @Test func anEventThatIsNotCreatedSendsNothing() {
        let calls = Calls()
        #expect(run(creates: false, calls: calls) == .failure(.eventNotCreated))
        #expect(calls.log == ["consent", "lookup", "create"])
        #expect(calls.posts.isEmpty)
    }
}
