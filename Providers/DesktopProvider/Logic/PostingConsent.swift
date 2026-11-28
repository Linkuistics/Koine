/// The consent checks before a post. The desktop provider and the input provider share this file: the input
/// provider links it in by symlink as source, so both report the same `os-permission` message.

/// The two checks that come before Koine posts an event: `AXIsProcessTrusted` for Accessibility consent, and
/// `CGPreflightPostEventAccess` for posting access. A device management profile can allow one and deny the other.
struct PostingConsent: Equatable, Sendable {
    let accessibility: Bool
    let posting: Bool

    /// The message of the `os-permission` failure, which names the access that macOS withholds. Nil when both
    /// checks pass. The error identifier stays `accessibility`, because that is the one OS permission that Koine
    /// owns (docs/specs/machine.md, "Grants, consent and failures").
    var refusal: String? {
        switch (accessibility, posting) {
        case (true, true):
            return nil
        case (false, false):
            return "Koine needs Accessibility access and event posting access to post events. "
                + "macOS withholds both."
        case (false, true):
            return "Koine needs Accessibility access to post events. macOS withholds Accessibility access."
        case (true, false):
            return "Koine needs event posting access to post events. macOS reports Accessibility access, "
                + "but it withholds event posting access."
        }
    }
}
