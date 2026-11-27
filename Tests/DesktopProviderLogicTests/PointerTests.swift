import Testing

@testable import DesktopProviderLogic

/// Plain values for the pointer position. The contract is "The pointer position" in docs/specs/machine.md.
struct PointerPositionTests {
    /// The y value flips against the full height of the first screen: the bottom-left origin of AppKit becomes
    /// the top-left origin of screen coordinates. The x value stays.
    @Test func theAppKitPositionFlipsAgainstTheHeightOfTheFirstScreen() {
        #expect(PointerPosition.screenPoint(appKit: (100, 800), firstScreenHeight: 900) == ScreenPoint(x: 100, y: 100))
        #expect(PointerPosition.screenPoint(appKit: (0, 900), firstScreenHeight: 900) == ScreenPoint(x: 0, y: 0))
        #expect(PointerPosition.screenPoint(appKit: (0, 0), firstScreenHeight: 900) == ScreenPoint(x: 0, y: 900))
    }

    /// A coordinate can have a fraction, and Koine keeps it.
    @Test func aFractionStays() {
        #expect(
            PointerPosition.screenPoint(appKit: (412.25, 300.5), firstScreenHeight: 1117)
                == ScreenPoint(x: 412.25, y: 816.5))
    }

    /// A display to the left of the primary display has negative x values. A display above it has positive AppKit
    /// y values greater than its height, so its screen y values are negative. A display below it has negative
    /// AppKit y values, so its screen y values are greater than the height.
    @Test func aPositionOnAnotherDisplayKeepsItsSign() {
        #expect(PointerPosition.screenPoint(appKit: (-500, 400), firstScreenHeight: 900) == ScreenPoint(x: -500, y: 500))
        #expect(PointerPosition.screenPoint(appKit: (200, 1500), firstScreenHeight: 900) == ScreenPoint(x: 200, y: -600))
        #expect(PointerPosition.screenPoint(appKit: (200, -300), firstScreenHeight: 900) == ScreenPoint(x: 200, y: 1200))
    }

    /// With no screen, Koine cannot convert the position, so it gives none. It never invents one.
    @Test func withNoScreenThereIsNoPosition() {
        #expect(PointerPosition.screenPoint(appKit: (100, 800), firstScreenHeight: nil) == nil)
    }
}

/// The message of the consent failure names the access that macOS withholds.
struct PostingConsentTests {
    @Test func bothChecksPassedGivesNoRefusal() {
        #expect(PostingConsent(accessibility: true, posting: true).refusal == nil)
    }

    @Test func eachMissingAccessIsNamed() throws {
        let both = try #require(PostingConsent(accessibility: false, posting: false).refusal)
        #expect(both.contains("Accessibility access and event posting access"))
        #expect(both.contains("macOS withholds both."))
        let accessibility = try #require(PostingConsent(accessibility: false, posting: true).refusal)
        #expect(accessibility.contains("macOS withholds Accessibility access."))
        #expect(!accessibility.contains("posting access"))
        let posting = try #require(PostingConsent(accessibility: true, posting: false).refusal)
        #expect(posting.contains("macOS reports Accessibility access, but it withholds event posting access."))
    }
}

/// The order of the nudge steps, with each native effect recorded. The contract is "The pointer nudge" in
/// docs/specs/machine.md. Nothing here posts a real event: an event is the point that it would carry.
struct PointerNudgeTests {
    final class Recorder {
        var steps: [String] = []
        var posted: [ScreenPoint] = []

        func perform(
            consent: PostingConsent = PostingConsent(accessibility: true, posting: true),
            buttonHeld: Bool = false,
            start: ScreenPoint? = ScreenPoint(x: 640, y: 400),
            createsUpTo: Int = 2
        ) async -> Result<PointerNudgeOutcome, PointerNudgeFailure> {
            var created = 0
            return await PointerNudge.perform(
                consent: {
                    steps.append("consent")
                    return consent
                },
                buttonHeld: {
                    steps.append("buttons")
                    return buttonHeld
                },
                start: {
                    steps.append("start")
                    return start
                },
                create: { point -> ScreenPoint? in
                    steps.append("create \(point.x),\(point.y)")
                    guard created < createsUpTo else { return nil }
                    created += 1
                    return point
                },
                post: { point in
                    steps.append("post \(point.x),\(point.y)")
                    posted.append(point)
                }
            )
        }
    }

    /// One point to the right and back: the pointer ends where it started.
    @Test func theNudgeMovesOnePointToTheRightAndBack() async {
        let recorder = Recorder()
        #expect(await recorder.perform() == .success(.nudged))
        #expect(recorder.posted == [ScreenPoint(x: 641, y: 400), ScreenPoint(x: 640, y: 400)])
        #expect(recorder.posted.last == ScreenPoint(x: 640, y: 400))
    }

    /// The consent checks come first, then the buttons, then the start. Both events exist before the first post.
    @Test func theStepsRunInTheOrderOfTheContract() async {
        let recorder = Recorder()
        _ = await recorder.perform(start: ScreenPoint(x: 10.5, y: 20))
        #expect(
            recorder.steps == [
                "consent", "buttons", "start", "create 11.5,20.0", "create 10.5,20.0", "post 11.5,20.0",
                "post 10.5,20.0",
            ])
    }

    /// A held button refuses the nudge with an outcome, not an error. Koine reads no position and posts nothing.
    @Test func aHeldButtonRefusesTheNudgeAndMovesNothing() async {
        let recorder = Recorder()
        #expect(await recorder.perform(buttonHeld: true) == .success(.pointerButtonHeld))
        #expect(recorder.steps == ["consent", "buttons"])
        #expect(recorder.posted.isEmpty)
    }

    /// Without either access, Koine refuses before it reads the buttons, and it posts nothing.
    @Test(arguments: [
        PostingConsent(accessibility: false, posting: true), PostingConsent(accessibility: true, posting: false),
        PostingConsent(accessibility: false, posting: false),
    ])
    func aFailedConsentCheckRefusesBeforeAnyOtherStep(consent: PostingConsent) async throws {
        let recorder = Recorder()
        let refusal = try #require(consent.refusal)
        #expect(await recorder.perform(consent: consent, buttonHeld: true) == .failure(.permission(refusal)))
        #expect(recorder.steps == ["consent"])
        #expect(recorder.posted.isEmpty)
    }

    @Test func anUnknownStartPostsNothing() async {
        let recorder = Recorder()
        #expect(await recorder.perform(start: nil) == .failure(.positionUnknown))
        #expect(recorder.steps == ["consent", "buttons", "start"])
        #expect(recorder.posted.isEmpty)
    }

    /// When macOS creates only the first event, Koine posts neither, so a failure leaves no half nudge.
    @Test(arguments: [0, 1])
    func anEventThatMacOSDoesNotCreatePostsNothing(createsUpTo: Int) async {
        let recorder = Recorder()
        #expect(await recorder.perform(createsUpTo: createsUpTo) == .failure(.eventNotCreated))
        #expect(recorder.posted.isEmpty)
        #expect(!recorder.steps.contains { $0.hasPrefix("post") })
    }
}
