/// One OS permission's state, as `koineManagement.osPermissions` serves it. The
/// core knows no platform: the host names the permission and its owner, in the
/// vocabulary `extensions.osPermission` and `extensions.permissionOwner` use.
public struct OSPermissionStatus: Sendable, Equatable {
    public let permission: String
    public let owner: String
    public let granted: Bool

    public init(permission: String, owner: String, granted: Bool) {
        self.permission = permission
        self.owner = owner
        self.granted = granted
    }
}

/// The host's read of its OS permissions. It is called on each request that
/// selects them, so it must be cheap, and it must never ask the user anything.
public typealias OSPermissionSource = @Sendable () -> [OSPermissionStatus]
