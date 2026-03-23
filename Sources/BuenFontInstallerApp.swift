import AppKit
import SwiftUI

enum TabSelection: CaseIterable {
    case main
    case settings

    var title: String {
        switch self {
        case .main: return "MAIN"
        case .settings: return "SETTINGS"
        }
    }

    var icon: String {
        switch self {
        case .main: return "square.and.arrow.down"
        case .settings: return "gear"
        }
    }
}

@main
struct BuenFontInstallerApp: App {
    @StateObject private var settings = AppSettings()
    // @StateObject private var sparkleUpdater = SparkleUpdaterController()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
                .background(WindowAccessor())
                .navigationTitle(Text("Buen Font Installer"))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            ForEach(TabSelection.allCases, id: \.self) { tab in
                                let isActive = (tab == .settings) == settings.showingSettings
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        settings.showingSettings = (tab == .settings)
                                    }
                                }) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(isActive ? .primary : .secondary)
                                        .padding(10)
                                        .background(
                                            Circle()
                                                .fill(
                                                    isActive
                                                        ? Color.primary.opacity(0.15) : Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)

                                if tab != TabSelection.allCases.last {
                                    Divider()
                                        .frame(height: 12)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .windowToolbar)
                .toolbarTitleDisplayMode(.inline)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 500, height: 500)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Buen Font Installer") {
                    NSApp.orderFrontStandardAboutPanel()
                }
            }

        }
    }
}

@MainActor
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
                systemSymbolName: "textformat",
                accessibilityDescription: "Buen Font Installer")
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
                window.appearance = NSAppearance(named: .darkAqua)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
