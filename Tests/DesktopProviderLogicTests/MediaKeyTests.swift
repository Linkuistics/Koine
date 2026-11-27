import Testing

@testable import DesktopProviderLogic

/// The event contents of each media key. The contract is "Media keys" in docs/specs/machine.md. Nothing here posts
/// an event: a key posted on this host would change the music or the volume of the developer.
struct MediaKeyEventTests {
    /// The six keys of `DesktopMediaKey`, in the order of the design, each with the key number of the contract.
    @Test func eachKeyHasTheNumberOfTheContract() {
        #expect(MediaKey.allCases.map(\.rawValue) == ["PLAY_PAUSE", "NEXT", "PREVIOUS", "VOLUME_UP", "VOLUME_DOWN", "MUTE"])
        #expect(MediaKey.allCases.map(\.number) == [16, 19, 20, 0, 1, 7])
    }

    /// The states are `NX_KEYDOWN` and `NX_KEYUP`, and the subtype is `NX_SUBTYPE_AUX_CONTROL_BUTTONS`.
    @Test func theStatesAndTheSubtypeAreTheHeaderValues() {
        #expect(MediaKeyState.down.rawValue == 10)
        #expect(MediaKeyState.up.rawValue == 11)
        #expect(MediaKeyPress.subtype == 8)
        #expect(MediaKeyPress.data2 == -1)
    }

    /// The whole `data1` value of each key, down and up, written out, so a change to the packing or to a number
    /// turns this test red.
    @Test(arguments: [
        (MediaKey.playPause, 0x10_0A00, 0x10_0B00),
        (MediaKey.next, 0x13_0A00, 0x13_0B00),
        (MediaKey.previous, 0x14_0A00, 0x14_0B00),
        (MediaKey.volumeUp, 0x00_0A00, 0x00_0B00),
        (MediaKey.volumeDown, 0x01_0A00, 0x01_0B00),
        (MediaKey.mute, 0x07_0A00, 0x07_0B00),
    ])
    func eachKeyPostsDownAndThenUp(key: MediaKey, down: Int, up: Int) {
        #expect(MediaKeyPress.data1(key, .down) == down)
        #expect(MediaKeyPress.data1(key, .up) == up)
        #expect(MediaKeyPress.sequence(key) == [down, up])
    }

    /// The key number is in bits 16 to 23, the state is in bits 8 to 15, and the repeat count in the low byte is 0.
    @Test(arguments: MediaKey.allCases)
    func theFieldsOfData1AreSeparate(key: MediaKey) {
        for state in MediaKeyState.allCases {
            let value = MediaKeyPress.data1(key, state)
            #expect((value >> 16) & 0xFF == key.number)
            #expect((value >> 8) & 0xFF == state.rawValue)
            #expect(value & 0xFF == 0)
            #expect(value >> 24 == 0)
        }
    }
}

/// The order of the steps of one press, with each native effect recorded. Nothing here posts a real event: an
/// event is the `data1` value that it would carry.
struct MediaKeyPressTests {
    final class Recorder {
        var steps: [String] = []
        var posted: [Int] = []

        func perform(
            _ key: MediaKey = .playPause,
            consent: PostingConsent = PostingConsent(accessibility: true, posting: true),
            createsUpTo: Int = 2
        ) -> Result<MediaKey, MediaKeyFailure> {
            var created = 0
            return MediaKeyPress.perform(
                key,
                consent: {
                    steps.append("consent")
                    return consent
                },
                create: { data1 -> Int? in
                    steps.append("create \(data1)")
                    guard created < createsUpTo else { return nil }
                    created += 1
                    return data1
                },
                post: { data1 in
                    steps.append("post \(data1)")
                    posted.append(data1)
                }
            )
        }
    }

    /// The consent checks come first. Both events exist before the first post, and down is posted before up.
    @Test(arguments: MediaKey.allCases)
    func theStepsRunInTheOrderOfTheContract(key: MediaKey) {
        let recorder = Recorder()
        #expect(recorder.perform(key) == .success(key))
        let down = MediaKeyPress.data1(key, .down)
        let up = MediaKeyPress.data1(key, .up)
        #expect(recorder.steps == ["consent", "create \(down)", "create \(up)", "post \(down)", "post \(up)"])
        #expect(recorder.posted == [down, up])
    }

    /// Without either access, Koine refuses before it creates an event, and it posts nothing.
    @Test(arguments: [
        PostingConsent(accessibility: false, posting: true), PostingConsent(accessibility: true, posting: false),
        PostingConsent(accessibility: false, posting: false),
    ])
    func aFailedConsentCheckRefusesBeforeAnyOtherStep(consent: PostingConsent) throws {
        let recorder = Recorder()
        let refusal = try #require(consent.refusal)
        #expect(recorder.perform(consent: consent) == .failure(.permission(refusal)))
        #expect(recorder.steps == ["consent"])
        #expect(recorder.posted.isEmpty)
    }

    /// When macOS creates only the down event, Koine posts neither, so a failure leaves no key held down.
    @Test(arguments: [0, 1])
    func anEventThatMacOSDoesNotCreatePostsNothing(createsUpTo: Int) {
        let recorder = Recorder()
        #expect(recorder.perform(createsUpTo: createsUpTo) == .failure(.eventNotCreated))
        #expect(recorder.posted.isEmpty)
        #expect(!recorder.steps.contains { $0.hasPrefix("post") })
    }
}
