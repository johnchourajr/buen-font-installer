import AppKit
import SwiftUI

struct SettingsView: View {
  @ObservedObject var settings: AppSettings
  let onBack: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header with back button and centered title
      ZStack {
        // Back button on the left
        HStack {
          Button(action: onBack) {
            HStack(spacing: 6) {
              Image(systemName: "chevron.left")
                .font(.system(size: 12, weight: .semibold))
              Text("Back")
                .font(.system(size: 14))
            }
          }
          .buttonStyle(.plain)
          .foregroundColor(.white)

          Spacer()
        }

        // Title centered
        Text("Settings")
          .font(.system(size: 14, weight: .medium))
      }
      .padding(.all, 12)

      // Settings content
      VStack(alignment: .leading, spacing: 20) {
        // Install Location
        VStack(alignment: .leading, spacing: 8) {
          Text("Install Location")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)

          HStack {
            Text(settings.installLocation.path)
              .font(.system(size: 11))
              .foregroundColor(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
              .frame(maxWidth: .infinity, alignment: .leading)
              .onTapGesture {
                chooseInstallLocation()
              }

            Button("Choose...") {
              chooseInstallLocation()
            }
            .buttonStyle(.borderedProminent)
          }
          .padding(12)
          .background(Color.primary.opacity(0.05))
          .cornerRadius(8)
        }

        Divider()

        // Visibility Options
        VStack(alignment: .leading, spacing: 12) {
          Text("Visibility")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)

          Toggle("Show in Menu Bar", isOn: $settings.showInMenuBar)
            .toggleStyle(.checkbox)
          Toggle("Show in Dock", isOn: $settings.showInDock)
            .toggleStyle(.checkbox)
        }

        Divider()

        // About Section
        VStack(alignment: .leading, spacing: 8) {
          Text("About")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)

          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text("Buen Font Installer")
                .font(.system(size: 12))
              Text("Built by John Choura Jr.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
              Text("Version \(settings.appVersion) (Build \(settings.buildNumber))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }

            Spacer()

            Button("GitHub") {
              if let url = URL(string: "https://github.com/johnchourajr/buen-fonts-app") {
                NSWorkspace.shared.open(url)
              }
            }
            .buttonStyle(.link)
            .font(.system(size: 12))
          }
          .padding(12)
          .background(Color.primary.opacity(0.05))
          .cornerRadius(8)
        }
      }
      .padding(.all, 16)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  func chooseInstallLocation() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.allowsMultipleSelection = false
    panel.directoryURL = settings.installLocation
    panel.message = "Choose where fonts should be installed"

    if panel.runModal() == .OK, let url = panel.url {
      settings.installLocation = url
    }
  }
}
