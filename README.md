# Buen Font Installer

A sleek macOS menu bar app to install and organize font files. Built on top of the [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator) concept.

## Download

**[Download Latest Release](https://github.com/johnchourajr/buen-fonts-app/releases/latest)**

1. Download the `.dmg` file
2. Open it and drag the app to your Applications folder
3. Launch from Applications or click the menu bar icon

## Features

- **Drag & Drop Interface**: Drag font files or folders anywhere on the window
- **Auto Install Mode**: Install fonts to a custom location (default: `~/Library/Fonts/`) with automatic deduplication
- **Organize Mode**: Separate fonts into organized folders by type (TTF, OTF, WOFF, WOFF2)
- **Menu Bar App**: Lives in your menu bar for quick access
- **Customizable Settings**: Control install location and app visibility

## Usage

### Auto Install (Checked)
When "Auto install" is checked:
- Drag font files or folders into the drop zone
- `.ttf` and `.otf` files are automatically installed to `~/Library/Fonts/`
- Existing fonts are automatically skipped (no duplicates)
- Web fonts (`.woff`, `.woff2`) are skipped with a notification

### Organize Mode (Unchecked)
When "Auto install" is unchecked:
- Drag font files or folders into the drop zone
- Fonts are organized into separate folders in the source directory:
  - `all TTFs/` - All TrueType fonts
  - `all OTFs/` - All OpenType fonts
  - `all WOFF2s/` - All WOFF2 web fonts
  - `all WOFFs/` - All WOFF web fonts

## Building

This is a Swift Package Manager project. You can build and run it in multiple ways:

### Option 1: Build App Bundle (Recommended for Distribution)
```bash
# Build a standalone .app with icon
./build-app.sh

# Launch the app
open "Buen Font Installer.app"
```

This creates a double-clickable macOS app with the icon included.

### Option 2: Live Development (Recommended for Development)

**Using Xcode Canvas (Best):**
```bash
# Open in Xcode
open Package.swift
```
Then press `⌥⌘↩` (Option+Command+Return) in `ContentView.swift` to see live preview

**Using Auto-rebuild Watch Script:**
```bash
# Auto-rebuild and relaunch on file changes
./watch.sh
```
Requires `fswatch` (install with `brew install fswatch` for faster watching, or it falls back to polling)

### Option 3: Quick Test Run
```bash
# Run once from source
swift run
```

## Distribution (For Developers)

### Create a Release DMG

```bash
# Build and create DMG installer
./create-dmg.sh
```

This creates a `.dmg` file that users can download and install by dragging to Applications.

### Publishing a Release

1. Update version in `Info.plist`
2. Run `./create-dmg.sh`
3. Create a new release on GitHub
4. Upload the `.dmg` file
5. Users download and install

### Optional: Code Signing & Notarization

For wider distribution without Gatekeeper warnings:
1. Get an Apple Developer account ($99/year)
2. Sign the app with your Developer ID certificate
3. Notarize with Apple
4. See [Apple's notarization guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

## Customizing the Icon

1. Replace `icon.png` with your design (1024x1024 recommended)
2. Open `Package.swift` in Xcode
3. Drag your icon to all AppIcon slots in the asset catalog
4. Rebuild with `./build-app.sh`

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## License

MIT - see LICENSE file

## Credits

Built on top of the [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator) concept.

