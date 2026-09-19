/// One run of one process: a PID names it only together with its start instant.
struct ProcessIncarnation: Equatable, Hashable, Sendable {
    let pid: Int32
    let startMicroseconds: Int64
}

/// The remainder of a `koine://desktop/…` reference, which only this provider
/// reads. An application is its process incarnation. A window adds its native
/// identity: the accessibility element this provider holds, named by the
/// provider run that holds it (`session`) and its number in that run (`token`).
/// An element cannot be held across provider runs, so a reference from another
/// session names nothing here and is `unavailable`, never a guess.
enum DesktopReference: Equatable, Sendable {
    case application(ProcessIncarnation)
    case window(ProcessIncarnation, session: String, token: UInt64)

    var uri: String {
        switch self {
        case .application(let process):
            "koine://desktop/application/\(process.pid)/\(process.startMicroseconds)"
        case .window(let process, let session, let token):
            "koine://desktop/window/\(process.pid)/\(process.startMicroseconds)/\(session)/\(token)"
        }
    }

    /// Nil unless `uri` is exactly a text this provider produces.
    init?(uri: String) {
        let prefix = "koine://desktop/"
        guard uri.hasPrefix(prefix) else { return nil }
        let parts = uri.dropFirst(prefix.count).split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count >= 3, let pid = Int32(parts[1]), pid > 0,
            let start = Int64(parts[2]), start >= 0
        else { return nil }
        let process = ProcessIncarnation(pid: pid, startMicroseconds: start)
        switch (parts[0], parts.count) {
        case ("application", 3): self = .application(process)
        case ("window", 5):
            guard let token = UInt64(parts[4]), Self.isSession(parts[3]) else { return nil }
            self = .window(process, session: String(parts[3]), token: token)
        default: return nil
        }
        guard self.uri == uri else { return nil }  // no leading zeros, signs or spaces
    }

    private static func isSession(_ text: Substring) -> Bool {
        text.utf8.count == 16 && text.utf8.allSatisfy {
            (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0)
                || (UInt8(ascii: "a")...UInt8(ascii: "f")).contains($0)
        }
    }
}
