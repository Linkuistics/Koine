import AppKit
import KoineManagementClient
import KoineProviderLoader
import KoineServer
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var server: KoineServer?
    private var window: NSWindow?
    private var port: Int?
    private let navigation = SettingsNavigation()
    private var menuBar: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = MainMenu.make()
        // The item exists from launch to Quit, before the server is up; it
        // shows no status until there is one.
        menuBar = MenuBarController { [weak self] section in self?.showSettingsWindow(at: section) }
        do {
            let data = KoineServer.userDataDirectory
            let server = try KoineServer(
                dataDirectory: data,
                providerRoots: Self.bundledProviderRoot + [KoineServer.installedProviderRoot(in: data)],
                providerCatalogue: Self.providerCatalogue,
                osPermissions: AccessibilityPermission.source
            )
            self.server = server
            Task {
                do {
                    port = try await server.start()
                    await finishLaunching(server)
                } catch {
                    fail("Koine could not start its service.", detail: error.localizedDescription)
                }
            }
        } catch KoineServerError.alreadyRunning {
            fail(
                "Koine is already running.",
                detail: "Another Koine holds this account's service. Use that one, or quit it first."
            )
        } catch {
            fail("Koine could not open its data.", detail: error.localizedDescription)
        }
    }

    /// The window opens at launch only while setup needs the user: Accessibility
    /// not granted, or login launch not enabled. A login launch is not told from
    /// a launch by hand; both read the same state. A client's grant request never
    /// opens it, because anonymous enrollment is open to every local process.
    private func finishLaunching(_ server: KoineServer) async {
        let client = ManagementClient(console: server.console)
        let status = try? await client.status()
        menuBar?.update(status: status)
        let launch = MenuBarModel(status: status, loginLaunch: .current)
        if launch.opensWindowAtLaunch { showSettingsWindow(at: nil) }
        Task { await menuBar?.follow(client) }
    }

    /// `Contents/PlugIns`, the root sealed inside the application bundle. It holds
    /// the bundles the catalogue designates; their approval is this host's own
    /// Team ID, derived from its verified signature, so an unsigned development
    /// run has none and admits no shipped candidate.
    private static var bundledProviderRoot: [ProviderRoot] {
        guard let plugIns = Bundle.main.builtInPlugInsURL else { return [] }
        return [.bundled(plugIns)]
    }

    /// The identities Koine ships, sealed with the application:
    /// `Contents/Resources/ProviderCatalogue.json`, from `App/ProviderCatalogue.json`.
    /// Absent or malformed, it admits no provider and says so, rather than
    /// inventing reservations from the bundles found.
    private static var providerCatalogue: Result<ProviderCatalogue, ProviderCatalogue.Invalid> {
        guard let url = Bundle.main.url(forResource: "ProviderCatalogue", withExtension: "json")
        else {
            return .failure(ProviderCatalogue.Invalid(reason: "The application has no ProviderCatalogue.json."))
        }
        return ProviderCatalogue.load(from: url)
    }

    // Returning false keeps the run loop, and so the listener, alive with no
    // windows: https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldterminateafterlastwindowclosed(_:)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    // Sent when the Dock or Finder reactivates the running application. With no
    // document architecture there is no default window to make, so show ours and
    // return false: https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldhandlereopen(_:hasvisiblewindows:)
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if server != nil { showSettingsWindow(at: nil) }
        return false
    }

    // Quit stops the server before the process exits, so the descriptor is
    // withdrawn and the instance lock released rather than left to be found stale.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let server else { return .terminateNow }
        self.server = nil
        Task {
            await server.stop()
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    /// Shows the settings window, comes to the front and, for a status line,
    /// scrolls to the section it names. An agent application is never active
    /// until it activates itself:
    /// https://developer.apple.com/documentation/appkit/nsapplication/activate()
    private func showSettingsWindow(at section: SettingsSection?) {
        guard let server, let port else { return }
        if window == nil {
            let view = ManagementView(
                client: ManagementClient(console: server.console), port: port, navigation: navigation
            )
            // The hosting controller takes the window's least size from the view's
            // minimum, and its first size would be that too: open at the default.
            let window = NSWindow(contentViewController: NSHostingController(rootView: view))
            window.title = "Koine Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(ManagementView.defaultSize)
            // The delegate keeps the window; closing only orders it out.
            window.isReleasedWhenClosed = false
            // Opened from the menu bar, it comes to the Space the user is on.
            window.collectionBehavior.insert(.moveToActiveSpace)
            window.center()
            self.window = window
        }
        if let section { navigation.show(section) }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    private func fail(_ message: String, detail: String) {
        server = nil
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message
        alert.informativeText = detail
        NSApp.activate()
        alert.runModal()
        NSApp.terminate(nil)
    }
}
