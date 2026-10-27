/// What a person must be told about a capability's reach wherever it is granted
/// or reviewed, served as `koineManagement.capabilityDisclosures` so the native
/// window and a `koine:manage` client show the same words.
///
/// The catalogue is the core's, keyed by capability name, because the provider
/// framework carries no place for a description and an ordinary provider has no
/// disclosure channel. It is served whole, whether or not the provider is
/// active: a grant may hold a capability whose provider failed to load, and its
/// reach is disclosed all the same. Serving a description supplies no authority.
public enum CapabilityDisclosures {
    /// Workspace control: the reach `docs/specs/workspace-launch-and-open.md` and
    /// `docs/adr/provider-authority-follows-effects.md` require disclosed before
    /// workspace ships. Desktop control's expanded reach is disclosed by the
    /// window-layout increment, not here.
    public static let workspaceControl = """
        Launches or reactivates any application registered on this Mac, not only \
        configured shortcuts, and opens documents, folders and web addresses in \
        their default application or a named one. Koine accepts no program, \
        arguments, environment or shell command, but that is not a sandbox: the \
        application that receives a document decides what happens, so a handler \
        can run a script or follow a location document to another address or \
        file. Launching, opening and revealing also need desktop:control, because \
        activation is an allowed effect; neither capability works without the other.
        """

    /// Workspace read: the reach of the two queries it admits today, `Query.workspaceSpecialLocations` and
    /// `Query.workspaceApplications`. A later cut that widens the reach widens this text and
    /// advertises a new host feature (`docs/adr/native-workspace-requires-disclosure-capable-host.md`).
    public static let workspaceRead = """
        Reads the special locations that macOS names for Koine's own account, such as \
        the home, Documents and Applications folders. Lists the applications that \
        Spotlight has indexed on this Mac's disks, on mounted network volumes and in a \
        remote home folder, with each one's name, bundle identifier and location. It \
        reads no file contents and lists no folder. A returned location gives no \
        access to it. Launching or opening a listed application still needs \
        workspace:control and desktop:control.
        """

    /// Every capability with a disclosure, in capability order.
    public static var all: [(capability: String, disclosure: String)] {
        [("workspace:control", workspaceControl), ("workspace:read", workspaceRead)]
    }
}
