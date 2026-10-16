import KoineManagementClient
import ServiceManagement

extension LoginLaunchState {
    /// The service's status, named for the Foundation-only model.
    // https://developer.apple.com/documentation/servicemanagement/smappservice/status-swift.enum
    init(_ status: SMAppService.Status) {
        switch status {
        case .enabled: self = .enabled
        case .requiresApproval: self = .requiresApproval
        case .notRegistered: self = .notRegistered
        case .notFound: self = .notFound
        @unknown default: self = .unknown
        }
    }

    @MainActor static var current: LoginLaunchState { LoginLaunchState(SMAppService.mainApp.status) }
}
