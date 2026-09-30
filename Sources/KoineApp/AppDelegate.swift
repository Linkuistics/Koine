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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = MainMenu.make()
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
                    showManagementWindow()
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
        if server != nil { showManagementWindow() }
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

    private func showManagementWindow() {
        guard let server, let port else { return }
        if window == nil {
            let view = ManagementView(client: ManagementClient(console: server.console), port: port)
            let window = NSWindow(contentViewController: NSHostingController(rootView: view))
            window.title = "Koine"
            window.styleMask = [.titled, .closable, .miniaturizable]
            // The delegate keeps the window; closing only orders it out.
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func fail(_ message: String, detail: String) {
        server = nil
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message
        alert.informativeText = detail
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
        NSApp.terminate(nil)
    }
}
