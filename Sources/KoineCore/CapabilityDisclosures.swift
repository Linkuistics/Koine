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
    /// Desktop control: the reach of window layout, which Koine 0.5.0 adds to focus, and of the pointer nudge and
    /// the media keys, which Koine 0.6.0 adds (docs/specs/machine.md, "Capability disclosures"). The host
    /// advertises `desktop-disclosures-v2` only with this text and `desktopRead`. The text still states the window
    /// layout reach, so the host advertises `desktop-disclosures-v1` too.
    public static let desktopControl = """
        Focuses a window. Moves and resizes any window of an application with a Dock \
        icon. Focuses a display: Koine raises the front window there, activates its \
        application and moves the pointer to the centre of the display. Nudges the \
        pointer one point to the right and back, so that a hidden pointer becomes \
        visible again. Posts the media keys play/pause, next and previous. macOS sends \
        them to the Now Playing app in Control Center, which is often not the front \
        app. When no app is Now Playing, play/pause can make macOS open Music and bring \
        it to the front. Posts volume up, volume down and mute, which change the output \
        volume of this Mac or mute it. It never clicks, and it never types into an app. \
        While it moves a window, it turns off the enhanced accessibility setting of the \
        application, and then turns it on again. A grant from an earlier Koine version \
        that holds desktop:control gets this reach too.
        """

    /// Desktop read: the reach of the window list and the display list, which Koine 0.5.0 adds to the reads of one
    /// application, and of the pointer position, which Koine 0.6.0 adds.
    public static let desktopRead = """
        Lists the windows of every application with a Dock icon on the current \
        Space. For each window, it reads the title, the application, the position \
        and size, the place in front-to-back order and whether the window is on \
        screen. A title can contain a document name, a web page title or a message \
        subject. It also lists the displays with their positions and sizes, and it \
        reads the position of the pointer. It reads no window contents and takes no \
        screenshots. A grant from an earlier Koine version that holds desktop:read \
        gets this reach too.
        """

    /// Input control: the reach of a chord to any app and of the Space switch, which Koine 0.7.0 adds
    /// (docs/specs/machine.md, "Capability disclosures"). No earlier host serves an input capability, so no earlier
    /// grant gets this reach, and input needs no disclosure feature of the host.
    public static let inputControl = """
        Sends a chord, one key with modifier keys such as Command-L, to a chosen app, in front or in the \
        background. The app acts as if the user pressed the keys. So a chord sent to a terminal can type and \
        run commands as the user. A chord can also make any app do what its keyboard shortcuts do, such as \
        close a window or send a message. It can change a setting in System Settings, and it can answer a \
        consent, password or security prompt of macOS. It types no text string. Koine never brings an app to \
        the front, and it never sends a chord to itself. An app in the background can ignore a chord, act on a \
        window behind other apps, or come to the front. No other app receives the chord. With desktop:control \
        too, it switches to Mission Control desktop 1 to 9 by posting Control and the digit, as the keyboard \
        does. It first checks that the shortcut is on and that the Mission Control desktop exists. The \
        shortcut setting or the Mission Control desktops can change in the instant before macOS reads the \
        chord. Then the front app can receive Control and the digit instead. The front app can also receive \
        them when macOS has not applied a shortcut setting yet. It can receive them too when macOS numbers the \
        desktops of several displays differently from Koine.
        """

    /// Input read: the reach of target capture, which Koine 0.7.0 adds.
    public static let inputRead = """
        Reads which app is the front app, with its name and bundle identifier. Reads the same facts for an app \
        process that a client names. It reads no window titles and no window contents, and it sends no keys. \
        Sending a chord needs input:control.
        """

    /// Workspace control: the reach `docs/specs/workspace-launch-and-open.md` and
    /// `docs/adr/provider-authority-follows-effects.md` require disclosed before
    /// workspace ships.
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
        [
            ("desktop:control", desktopControl), ("desktop:read", desktopRead),
            ("input:control", inputControl), ("input:read", inputRead),
            ("workspace:control", workspaceControl), ("workspace:read", workspaceRead),
        ]
    }
}
