import Sparkle
import SwiftUI

// This class provides a simple interface to Sparkle for SwiftUI apps
final class SparkleUpdaterController: ObservableObject {
  private let updaterController: SPUStandardUpdaterController

  init() {
    // Create Sparkle updater controller
    updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
  }

  func checkForUpdates() {
    updaterController.checkForUpdates(nil)
  }

  var canCheckForUpdates: Bool {
    updaterController.updater.canCheckForUpdates
  }
}

// View modifier to add Sparkle update checking to the app
struct SparkleUpdaterView: View {
  @ObservedObject private var updaterController: SparkleUpdaterController

  init(updaterController: SparkleUpdaterController) {
    self.updaterController = updaterController
  }

  var body: some View {
    EmptyView()
  }
}
