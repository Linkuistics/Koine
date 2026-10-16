import AppKit
import KoineManagementClient

/// The one menu bar item, from launch to Quit. It renders `MenuBarModel` and
/// holds nothing of its own: the lines, the dot and the label are the model's.
@MainActor
final class MenuBarController: NSObject {
    private let item: NSStatusItem
    private let openSettings: (SettingsSection?) -> Void
    /// The item shows nothing of login launch; the model takes it for the launch
    /// rule, which `AppDelegate` applies once.
    private let loginLaunch = LoginLaunchState.current
    private var model: MenuBarModel

    init(openSettings: @escaping (SettingsSection?) -> Void) {
        self.openSettings = openSettings
        model = MenuBarModel(status: nil, loginLaunch: loginLaunch)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        // The item is the only way back to the settings window; it is not
        // something the user can drag off the menu bar.
        item.behavior = []
        item.button?.setAccessibilityIdentifier("koine-menu-bar-item")
        render()
    }

    /// Follows the status for as long as the application runs, whether or not
    /// the settings window is open. One in-process console operation per tick.
    func follow(_ client: ManagementClient) async {
        while !Task.isCancelled {
            update(status: try? await client.status())
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    func update(status: ManagementStatus?) {
        let next = MenuBarModel(status: status, loginLaunch: loginLaunch)
        // Rebuilding while the menu is open would drop it from under the user.
        guard next != model else { return }
        model = next
        render()
    }

    private func render() {
        let label = model.accessibilityLabel
        if let button = item.button {
            button.image = Self.icon(marked: model.needsAttention, label: label)
            button.setAccessibilityLabel(label)
            button.toolTip = label
        }
        item.menu = makeMenu()
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        for line in model.statusLines {
            let entry = NSMenuItem(title: line.title, action: #selector(chooseStatusLine(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = line.section
            menu.addItem(entry)
        }
        if !model.statusLines.isEmpty { menu.addItem(.separator()) }
        let settings = NSMenuItem(title: "Settings…", action: #selector(chooseSettings(_:)), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        // Quit goes through the application's terminate path, which stops the
        // server first.
        menu.addItem(withTitle: "Quit Koine", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    @objc private func chooseStatusLine(_ sender: NSMenuItem) {
        openSettings(sender.representedObject as? SettingsSection)
    }

    @objc private func chooseSettings(_ sender: NSMenuItem) { openSettings(nil) }

    /// `character.bubble` as a template image, so the menu bar tints it. The
    /// mark is a dot in the corner, knocked out of the bubble by a ring so it
    /// reads at 18 pt; it is also in the label, which is what is read.
    private static func icon(marked: Bool, label: String) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let symbol = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: label)?
            .withSymbolConfiguration(configuration)
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { bounds in
            if let symbol {
                let drawn = symbol.size
                symbol.draw(in: NSRect(
                    x: (bounds.width - drawn.width) / 2, y: (bounds.height - drawn.height) / 2,
                    width: drawn.width, height: drawn.height
                ))
            }
            if marked {
                let dot = NSRect(x: bounds.maxX - 7, y: bounds.maxY - 7, width: 6, height: 6)
                NSGraphicsContext.current?.compositingOperation = .clear
                NSBezierPath(ovalIn: dot.insetBy(dx: -1.5, dy: -1.5)).fill()
                NSGraphicsContext.current?.compositingOperation = .sourceOver
                NSColor.black.setFill()
                NSBezierPath(ovalIn: dot).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = label
        return image
    }
}
