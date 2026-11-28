/// The steps of `inputSendKeystroke` (docs/specs/app-input.md, "Sending a chord"). The provider passes the consent
/// checks, the target lookup, the event creation and the post as closures. So `swift test` holds the order of the
/// steps without a post. A chord posted on a host would act in an app of the developer.

/// The values of `InputKeystrokeOutcome`.
enum KeystrokeOutcome: String, Equatable, Sendable {
    case sent = "SENT"
    case protectedTarget = "PROTECTED_TARGET"
}

/// Why a chord failed. In each case, Koine sent nothing.
enum KeystrokeFailure: Error, Equatable, Sendable {
    /// A consent check failed. The value is the message of `PostingConsent.refusal`.
    case permission(String)
    /// The reference names no live app process. The value is the message.
    case unavailable(String)
    /// The kernel did not answer for the process. The value is the reason.
    case unreadable(String)
    /// macOS did not create every event of the chord.
    case eventNotCreated
}

enum Keystroke {
    static let malformed = "The reference does not name an input target."
    static let gone = "The app is no longer running."
    static let notAnApp = "The process is not an app."

    /// The steps of one chord, in the order of the contract:
    ///
    /// 1. When a consent check fails, send nothing.
    /// 2. Resolve the reference. A malformed or wrong-kind reference, an ended process, or a process with another
    ///    start instant is `unavailable`.
    /// 3. When the target is Koine, the outcome is `PROTECTED_TARGET`. Koine checks itself by process identifier
    ///    before the app check, so its own process is refused whether or not macOS reports it as an app.
    /// 4. When macOS does not report the process as an app, it is `unavailable`.
    /// 5. Create every event of the chord. When macOS does not create one, send nothing.
    /// 6. Post every event in order to the target process, with no check between the posts. The outcome is `SENT`.
    ///
    /// Every check comes before the first post, so no refusal can leave a modifier down in the target.
    static func perform<Event>(
        reference: String,
        key: InputKey,
        modifiers: [InputModifier],
        koine: KoineIdentity,
        consent: () -> PostingConsent,
        lookup: (ProcessIncarnation) -> TargetLookup,
        create: ([ChordEvent]) -> [Event]?,
        post: (Event, Int32) -> Void
    ) -> Result<KeystrokeOutcome, KeystrokeFailure> {
        if let refusal = consent().refusal { return .failure(.permission(refusal)) }
        guard let process = InputReference.process(reference) else { return .failure(.unavailable(malformed)) }
        let app: AppFacts?
        switch lookup(process) {
        case .gone: return .failure(.unavailable(gone))
        case .unreadable(let reason): return .failure(.unreadable(reason))
        case .live(let facts): app = facts
        }
        if TargetProtection.of(pid: process.pid, bundleIdentifier: app?.bundleIdentifier, koine: koine) == .protected {
            return .success(.protectedTarget)
        }
        guard app != nil else { return .failure(.unavailable(notAnApp)) }
        let chord = Chord.events(key: key, modifiers: modifiers)
        guard let events = create(chord), events.count == chord.count else { return .failure(.eventNotCreated) }
        for event in events { post(event, process.pid) }
        return .success(.sent)
    }
}
