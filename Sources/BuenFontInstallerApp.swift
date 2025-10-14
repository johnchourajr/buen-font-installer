import AppKit
import SwiftUI

@main
struct BuenFontInstallerApp: App {
    @StateObject private var settings = AppSettings()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .background(WindowAccessor())
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("BUEN FONT INSTALLER")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary.opacity(0.6))
                            .tracking(1.2)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Buen Font Installer") {
                    NSApp.orderFrontStandardAboutPanel()
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup menu bar icon
        setupMenuBar()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "textformat", accessibilityDescription: "Buen Font Installer")
            button.action = #selector(toggleApp)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Create the menu
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Open", action: #selector(openApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func toggleApp() {
        // Left click - show main window
        if let event = NSApp.currentEvent, event.type == .leftMouseUp {
            openApp()
        }
    }

    @objc func openApp() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.isVisible || !$0.isVisible }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.isVisible || !$0.isVisible }) {
            window.makeKeyAndOrderFront(nil)
            // Post notification to show settings
            NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isOpaque = false
                window.backgroundColor = .clear
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.isOpaque = false
            window.backgroundColor = .clear
        }
    }
}
