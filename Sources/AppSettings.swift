import AppKit
import SwiftUI

class AppSettings: ObservableObject {
  private enum StorageKeys {
    static let installLocationPath = "installLocation"
    static let installLocationBookmark = "installLocationBookmark"
    static let showInMenuBar = "showInMenuBar"
    static let showInDock = "showInDock"
  }

  @Published var installLocation: URL {
    didSet {
      UserDefaults.standard.set(installLocation.path, forKey: StorageKeys.installLocationPath)
    }
  }

  @Published var showInMenuBar: Bool {
    didSet {
      UserDefaults.standard.set(showInMenuBar, forKey: StorageKeys.showInMenuBar)
    }
  }

  @Published var showingSettings: Bool = false

  @Published var showInDock: Bool {
    didSet {
      UserDefaults.standard.set(showInDock, forKey: StorageKeys.showInDock)
      updateDockVisibility()
    }
  }

  init() {
    let defaultLocation = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/Fonts")

    // Prefer a persisted security-scoped bookmark when available.
    if
      let bookmarkData = UserDefaults.standard.data(forKey: StorageKeys.installLocationBookmark),
      let resolvedURL = AppSettings.resolveInstallLocationBookmark(bookmarkData)
    {
      self.installLocation = resolvedURL
    } else if let savedPath = UserDefaults.standard.string(forKey: StorageKeys.installLocationPath) {
      self.installLocation = URL(fileURLWithPath: savedPath)
    } else {
      self.installLocation = defaultLocation
    }

    // Load menu bar and dock preferences (default: both true)
    self.showInMenuBar = UserDefaults.standard.object(forKey: StorageKeys.showInMenuBar) as? Bool ?? true
    self.showInDock = UserDefaults.standard.object(forKey: StorageKeys.showInDock) as? Bool ?? true

    // Apply dock visibility on launch
    updateDockVisibility()
  }

  func setInstallLocation(_ newLocation: URL, persistSecurityScopedAccess: Bool) {
    installLocation = newLocation

    guard persistSecurityScopedAccess else {
      UserDefaults.standard.removeObject(forKey: StorageKeys.installLocationBookmark)
      return
    }

    do {
      let bookmarkData = try newLocation.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      UserDefaults.standard.set(bookmarkData, forKey: StorageKeys.installLocationBookmark)
    } catch {
      print("Failed to persist install location bookmark: \(error)")
      UserDefaults.standard.removeObject(forKey: StorageKeys.installLocationBookmark)
    }
  }

  static func resolveInstallLocationBookmark(_ bookmarkData: Data) -> URL? {
    var isStale = false

    do {
      let url = try URL(
        resolvingBookmarkData: bookmarkData,
        options: .withSecurityScope,
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
      return url
    } catch {
      print("Failed to resolve install location bookmark: \(error)")
      return nil
    }
  }

  func updateDockVisibility() {
    let showInDock = self.showInDock
    Task { @MainActor in
      if showInDock {
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
