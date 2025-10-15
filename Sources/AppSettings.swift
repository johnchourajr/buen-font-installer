import AppKit
import SwiftUI

class AppSettings: ObservableObject {
  @Published var installLocation: URL {
    didSet {
      UserDefaults.standard.set(installLocation.path, forKey: "installLocation")
    }
  }

  @Published var showInMenuBar: Bool {
    didSet {
      UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar")
    }
  }

  @Published var showInDock: Bool {
    didSet {
      UserDefaults.standard.set(showInDock, forKey: "showInDock")
      updateDockVisibility()
    }
  }

  init() {
    // Load or set default install location
    if let savedPath = UserDefaults.standard.string(forKey: "installLocation") {
      self.installLocation = URL(fileURLWithPath: savedPath)
    } else {
      self.installLocation = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Fonts")
    }

    // Load menu bar and dock preferences (default: both true)
    self.showInMenuBar = UserDefaults.standard.object(forKey: "showInMenuBar") as? Bool ?? true
    self.showInDock = UserDefaults.standard.object(forKey: "showInDock") as? Bool ?? true

    // Apply dock visibility on launch
    updateDockVisibility()
  }

  func updateDockVisibility() {
    // Delay dock visibility update to ensure NSApp is ready
    DispatchQueue.main.async {
      if self.showInDock {
        NSApp.setActivationPolicy(.regular)
      } else {
        NSApp.setActivationPolicy(.accessory)
      }
    }
  }

  var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  }

  var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
  }
}
