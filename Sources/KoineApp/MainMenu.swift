import AppKit

/// A programmatic application has no menu bar until it builds one; without it
/// there is no Quit, no ⌘W and no copy/paste in text fields.
@MainActor
enum MainMenu {
    static func make() -> NSMenu {
        let main = NSMenu()

        let app = NSMenu()
        app.addItem(withTitle: "Hide Koine", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        app.addItem(.separator())
        app.addItem(withTitle: "Quit Koine", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        add(app, to: main)

        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        add(edit, to: main)

        let window = NSMenu(title: "Window")
        window.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        window.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        add(window, to: main)
        NSApp.windowsMenu = window

        return main
    }

    private static func add(_ submenu: NSMenu, to main: NSMenu) {
        let item = NSMenuItem()
        item.submenu = submenu
        main.addItem(item)
    }
}
