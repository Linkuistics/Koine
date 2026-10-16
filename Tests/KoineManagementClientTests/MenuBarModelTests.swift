import Foundation
import KoineManagementClient
import KoineServer
import Testing

/// What the menu bar item shows and whether the settings window opens at launch,
/// from the status the console serves and the login-launch state.
@Suite struct MenuBarModelTests {
    private static func request(_ id: String, state: String = "PENDING") -> ManagedGrantRequest {
        ManagedGrantRequest(
            requestId: id, clientLabel: "client \(id)", comparisonCode: "1234",
            requestedCapabilities: [], state: state
        )
    }

    private static func status(
        pending: Int = 0, decided: Int = 0, accessibility: Bool? = true
    ) -> ManagementStatus {
        ManagementStatus(
            contractVersion: "koine-desktop/1", instanceId: "instance",
            requests: (0..<pending).map { request("p\($0)") }
                + (0..<decided).map { request("d\($0)", state: "APPROVED") },
            osPermissions: accessibility.map {
                [ManagedOSPermission(permission: "accessibility", owner: "koine", granted: $0)]
            } ?? []
        )
    }

    private static func model(
        _ status: ManagementStatus?, _ login: LoginLaunchState = .enabled
    ) -> MenuBarModel {
        MenuBarModel(status: status, loginLaunch: login)
    }

    @Test func nothingWaitingShowsNoLineNoMarkAndThePlainLabel() {
        let model = Self.model(Self.status())
        #expect(model.statusLines.isEmpty)
        #expect(!model.needsAttention)
        #expect(model.accessibilityLabel == "Koine")
    }

    @Test func oneRequestIsSingularAndOpensRequests() {
        let model = Self.model(Self.status(pending: 1))
        #expect(model.statusLines.map(\.title) == ["Review 1 Grant Request…"])
        #expect(model.statusLines.map(\.section) == [.requests])
        #expect(model.needsAttention)
        #expect(model.accessibilityLabel == "Koine, 1 grant request waiting")
    }

    @Test func severalRequestsArePlural() {
        let model = Self.model(Self.status(pending: 2))
        #expect(model.statusLines.map(\.title) == ["Review 2 Grant Requests…"])
        #expect(model.accessibilityLabel == "Koine, 2 grant requests waiting")
    }

    @Test func onlyPendingRequestsWait() {
        let model = Self.model(Self.status(pending: 1, decided: 3))
        #expect(model.statusLines.map(\.title) == ["Review 1 Grant Request…"])
        #expect(!Self.model(Self.status(decided: 3)).needsAttention)
    }

    @Test func missingConsentHasItsLineAndOpensAccessibility() {
        let model = Self.model(Self.status(accessibility: false))
        #expect(model.statusLines.map(\.title) == ["Accessibility Not Granted…"])
        #expect(model.statusLines.map(\.section) == [.accessibility])
        #expect(model.needsAttention)
        #expect(model.accessibilityLabel == "Koine, Accessibility not granted")
    }

    @Test func bothConditionsShowBothLinesRequestsFirst() {
        let model = Self.model(Self.status(pending: 2, accessibility: false))
        #expect(model.statusLines.map(\.title) == ["Review 2 Grant Requests…", "Accessibility Not Granted…"])
        #expect(model.accessibilityLabel == "Koine, 2 grant requests waiting, Accessibility not granted")
    }

    @Test func aStatusThatCouldNotBeReadClaimsNothing() {
        let model = Self.model(nil)
        #expect(model.statusLines.isEmpty && !model.needsAttention)
        #expect(model.accessibilityLabel == "Koine")
    }

    @Test func aHostThatDoesNotReportAccessibilityClaimsNothingAboutIt() {
        let model = Self.model(Self.status(accessibility: nil))
        #expect(model.statusLines.isEmpty)
        #expect(!model.opensWindowAtLaunch)
    }

    // MARK: The launch rule

    @Test func setupCompleteStartsSilently() {
        #expect(!Self.model(Self.status(), .enabled).opensWindowAtLaunch)
    }

    @Test func missingConsentOpensTheWindowEvenWithLoginLaunchOn() {
        #expect(Self.model(Self.status(accessibility: false), .enabled).opensWindowAtLaunch)
    }

    @Test(arguments: [
        LoginLaunchState.requiresApproval, .notRegistered, .notFound, .unknown,
    ])
    func loginLaunchThatIsNotEnabledOpensTheWindow(login: LoginLaunchState) {
        #expect(Self.model(Self.status(), login).opensWindowAtLaunch)
        #expect(Self.model(Self.status(accessibility: false), login).opensWindowAtLaunch)
    }

    @Test func aWaitingRequestNeverOpensTheWindowByItself() {
        // Anonymous enrollment is open to every local process.
        #expect(!Self.model(Self.status(pending: 5), .enabled).opensWindowAtLaunch)
    }

    @Test func onlyEnabledCountsAsEnabled() {
        #expect(LoginLaunchState.enabled.isEnabled)
        for state in [LoginLaunchState.requiresApproval, .notRegistered, .notFound, .unknown] {
            #expect(!state.isEnabled)
        }
    }
}
