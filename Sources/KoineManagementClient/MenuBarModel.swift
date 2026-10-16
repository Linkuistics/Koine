import Foundation

/// Whether login launch is on, as the application reads it from
/// `SMAppService.mainApp.status`. Foundation cannot name that type, so the
/// application maps each of its cases onto one of these.
public enum LoginLaunchState: Sendable, Equatable {
    case enabled
    /// Registered, but the user has not allowed it in System Settings: it will
    /// not launch Koine, so it counts as not enabled.
    case requiresApproval
    case notRegistered
    case notFound
    /// A status the application's SDK did not name.
    case unknown

    public var isEnabled: Bool { self == .enabled }
}

/// A part of the settings window the menu bar item can lead to.
public enum SettingsSection: Sendable, Hashable {
    case accessibility
    case requests
}

/// What the menu bar item shows and whether the settings window opens at launch,
/// worked out from the status the console serves and the login-launch state.
/// It holds nothing the window does not also read, so the item, the window and
/// a `koine:manage` client cannot disagree about what waits on the user.
public struct MenuBarModel: Sendable, Equatable {
    /// A condition that waits on the user. Each is a menu item that opens the
    /// settings window at the part that resolves it.
    public enum StatusLine: Sendable, Equatable {
        case reviewGrantRequests(Int)
        case accessibilityNotGranted

        public var title: String {
            switch self {
            case .reviewGrantRequests(1): "Review 1 Grant Request…"
            case .reviewGrantRequests(let count): "Review \(count) Grant Requests…"
            case .accessibilityNotGranted: "Accessibility Not Granted…"
            }
        }

        public var section: SettingsSection {
            switch self {
            case .reviewGrantRequests: .requests
            case .accessibilityNotGranted: .accessibility
            }
        }

        /// The clause the item's accessibility label appends.
        fileprivate var waiting: String {
            switch self {
            case .reviewGrantRequests(1): "1 grant request waiting"
            case .reviewGrantRequests(let count): "\(count) grant requests waiting"
            case .accessibilityNotGranted: "Accessibility not granted"
            }
        }
    }

    /// In menu order, each present only while its condition holds. A status that
    /// could not be read, or that does not report Accessibility, claims nothing.
    public let statusLines: [StatusLine]

    /// Accessibility consent as the host reports it; nil when it does not.
    private let accessibilityGranted: Bool?
    private let loginLaunch: LoginLaunchState

    /// `status` is nil when it could not be read.
    public init(status: ManagementStatus?, loginLaunch: LoginLaunchState) {
        let pending = (status?.requests ?? []).filter { $0.state == "PENDING" }.count
        let accessibility = status?.osPermissions.first { $0.permission == "accessibility" }
        var lines: [StatusLine] = []
        if pending > 0 { lines.append(.reviewGrantRequests(pending)) }
        if accessibility?.granted == false { lines.append(.accessibilityNotGranted) }
        statusLines = lines
        accessibilityGranted = accessibility?.granted
        self.loginLaunch = loginLaunch
    }

    /// The mark: a dot on the icon while any status line is present.
    public var needsAttention: Bool { !statusLines.isEmpty }

    /// States the mark in words, for VoiceOver and for checks that read the
    /// item rather than its pixels.
    public var accessibilityLabel: String {
        (["Koine"] + statusLines.map(\.waiting)).joined(separator: ", ")
    }

    /// Whether the settings window opens at launch: only while setup needs the
    /// user. A login launch is not told from a launch by hand, which
    /// `SMAppService` items do not reliably report.
    public var opensWindowAtLaunch: Bool {
        accessibilityGranted == false || !loginLaunch.isEnabled
    }
}
