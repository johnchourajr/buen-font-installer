import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @ObservedObject var settings: AppSettings
  @State private var autoInstall = true
  @State private var isDropTargeted = false
  @State private var statusMessage = ""
  @State private var isProcessing = false
  @State private var showingSettings = false

  var body: some View {
    ZStack {
      // Main installer view
      if !showingSettings {
        mainView
          .frame(minHeight: 500)
          .transition(
            .asymmetric(
              insertion: .opacity.combined(with: .scale(scale: 0.95)),
              removal: .opacity.combined(with: .scale(scale: 1.05))
            ))
      }

      // Settings view
      if showingSettings {
        SettingsView(
          settings: settings,
          onBack: {
            withAnimation(.easeInOut(duration: 0.3)) {
              showingSettings = false
            }
          }
        )
        .frame(minHeight: 500)
        .transition(
          .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 1.05))
          ))
      }
    }
    .frame(width: 500)
    .background(.ultraThinMaterial)
    .animation(.easeInOut(duration: 0.3), value: showingSettings)
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) {
      _ in
      withAnimation(.easeInOut(duration: 0.3)) {
        showingSettings = true
      }
    }
  }

  var mainView: some View {
    ZStack {
      // Entire window is the drop zone
      Rectangle()
        .fill(isDropTargeted ? Color.accentColor.opacity(0.05) : Color.clear)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
          handleDrop(providers: providers)
          return true
        }

      VStack(spacing: 0) {
        Spacer()

        // Content area
        VStack(spacing: 24) {

          // Status Message
          if !statusMessage.isEmpty {
            Text(statusMessage)
              .font(.system(size: 12))
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }

          if isProcessing {
            ProgressView()
              .scaleEffect(0.7)
          }

          // Drop instruction
          if !isProcessing && statusMessage.isEmpty {
            VStack(spacing: 8) {
              Image(systemName: "arrow.down.doc")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.3))

              Text("Drop fonts or folder anywhere")
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.top, 20)
          }

          // Auto Install Checkbox
          Toggle("Auto install", isOn: $autoInstall)
            .toggleStyle(.checkbox)
            .font(.system(size: 14))
            .disabled(isProcessing)
        }

        Spacer()

        // Bottom bezel space
        HStack {
          // Settings button in bottom left corner
          Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
              showingSettings = true
            }
          }) {
            Image(systemName: "gear")
              .font(.system(size: 14))
              .foregroundColor(.secondary.opacity(0.6))
          }
          .buttonStyle(.plain)
          .help("Settings")

          Spacer()
        }
        .frame(height: 20)
        .padding(.all, 8)
      }
      .padding(12)

      // Dotted bezel border
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(
          style: StrokeStyle(lineWidth: 1, dash: [4, 4])
        )
        .foregroundColor(isDropTargeted ? .accentColor : .white.opacity(0.15))
        .padding(EdgeInsets(top: 2, leading: 12, bottom: 12, trailing: 12))
        .allowsHitTesting(false)
    }
  }

  func handleDrop(providers: [NSItemProvider]) {
    isProcessing = true
    statusMessage = "Processing..."

    Task {
      var allFontFiles: [URL] = []
      var sourceDirectory: URL?

      // Collect all font files from providers
      for provider in providers {
        if let url = await loadURL(from: provider) {
          if url.hasDirectoryPath {
            sourceDirectory = url
            let fonts = collectFontFiles(from: url)
            allFontFiles.append(contentsOf: fonts)
          } else if isFontFile(url) {
            allFontFiles.append(url)
            if sourceDirectory == nil {
              sourceDirectory = url.deletingLastPathComponent()
            }
          }
        }
      }

      guard !allFontFiles.isEmpty else {
        await MainActor.run {
          statusMessage = "No font files found"
          isProcessing = false
        }
        return
      }

      // Process fonts
      if autoInstall {
        await installFonts(allFontFiles)
      } else {
        if let sourceDir = sourceDirectory {
          await organizeFonts(allFontFiles, sourceDirectory: sourceDir)
        } else {
          await MainActor.run {
            statusMessage = "Could not determine source directory"
            isProcessing = false
          }
        }
      }
    }
  }

  func loadURL(from provider: NSItemProvider) async -> URL? {
    return await withCheckedContinuation { continuation in
      provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
        if let data = item as? Data,
          let url = URL(dataRepresentation: data, relativeTo: nil)
        {
          continuation.resume(returning: url)
        } else if let url = item as? URL {
          continuation.resume(returning: url)
        } else {
          continuation.resume(returning: nil)
        }
      }
    }
  }

  func collectFontFiles(from directory: URL) -> [URL] {
    var fontFiles: [URL] = []
    let fileManager = FileManager.default

    guard
      let enumerator = fileManager.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
      )
    else {
      return []
    }

    for case let fileURL as URL in enumerator {
      if isFontFile(fileURL) {
        fontFiles.append(fileURL)
      }
    }

    return fontFiles
  }

  func isFontFile(_ url: URL) -> Bool {
    let ext = url.pathExtension.lowercased()
    return ["ttf", "otf", "woff", "woff2"].contains(ext)
  }

  func installFonts(_ fontFiles: [URL]) async {
    let fileManager = FileManager.default
    let fontsDirectory = settings.installLocation

    var installed = 0
    var skipped = 0
    var failed = 0

    // Only install .ttf and .otf files
    let installableFonts = fontFiles.filter { url in
      let ext = url.pathExtension.lowercased()
      return ext == "ttf" || ext == "otf"
    }

    for fontURL in installableFonts {
      let destination = fontsDirectory.appendingPathComponent(fontURL.lastPathComponent)

      // Check if font already exists
      if fileManager.fileExists(atPath: destination.path) {
        skipped += 1
        continue
      }

      do {
        try fileManager.copyItem(at: fontURL, to: destination)
        installed += 1
      } catch {
        failed += 1
      }
    }

    await MainActor.run {
      var message = "Installed: \(installed)"
      if skipped > 0 { message += " | Skipped: \(skipped) (already exists)" }
      if failed > 0 { message += " | Failed: \(failed)" }

      let webFonts = fontFiles.count - installableFonts.count
      if webFonts > 0 {
        message += "\nSkipped \(webFonts) web font(s) (.woff/.woff2)"
      }

      statusMessage = message
      isProcessing = false
    }
  }

  func organizeFonts(_ fontFiles: [URL], sourceDirectory: URL) async {
    let fileManager = FileManager.default

    // Create folders for each type
    let folders = [
      "TTFs": "ttf",
      "OTFs": "otf",
      "WOFF2s": "woff2",
      "WOFFs": "woff",
    ]

    var organized: [String: Int] = [:]

    for (folderName, ext) in folders {
      let folderURL = sourceDirectory.appendingPathComponent("all \(folderName)")

      // Create folder if it doesn't exist
      if !fileManager.fileExists(atPath: folderURL.path) {
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
      }

      // Filter and copy files
      let matchingFiles = fontFiles.filter { $0.pathExtension.lowercased() == ext }
      var copied = 0

      for fontURL in matchingFiles {
        let destination = folderURL.appendingPathComponent(fontURL.lastPathComponent)

        // Remove if exists (to refresh)
        if fileManager.fileExists(atPath: destination.path) {
          try? fileManager.removeItem(at: destination)
        }

        do {
          try fileManager.copyItem(at: fontURL, to: destination)
          copied += 1
        } catch {
          // Silently fail
        }
      }

      if copied > 0 {
        organized[folderName] = copied
      }
    }

    await MainActor.run {
      var message = "Organized: "
      let parts = organized.map { "\($0.value) \($0.key)" }
      message += parts.joined(separator: ", ")

      if organized.isEmpty {
        message = "No fonts organized"
      }

      statusMessage = message
      isProcessing = false
    }
  }
}

#Preview {
  ContentView(settings: AppSettings())
}
