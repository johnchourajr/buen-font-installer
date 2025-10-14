# Buen Font Installer

A sleek macOS menu bar app for installing and organizing font files with a single drag and drop.

Built on the concept of [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator).

---

## Download

**[⬇️ Download Latest Release](https://github.com/johnchourajr/buen-fonts-app/releases/latest)**

### Installation

1. Download the `Buen Font Installer-v1.0.dmg` file
2. Open the DMG and drag the app to your Applications folder
3. Launch from Applications or find it in your menu bar

---

## Features

**Simple Drag & Drop**
Drop font files or folders anywhere on the window - the entire window is your dropzone.

**Two Modes of Operation**
- **Auto Install**: Installs fonts to your system with automatic duplicate detection
- **Organize**: Separates fonts into organized folders by type without installing

**Menu Bar Access**
Lives quietly in your menu bar - click to open, right-click for quick actions.

**Customizable**
- Choose where fonts get installed
- Toggle menu bar and dock visibility
- See what fonts were processed with clear status messages

---

## How to Use

### Installing Fonts

1. Check "Auto install" (enabled by default)
2. Drag font files or folders onto the window
3. `.ttf` and `.otf` files are instantly installed to your fonts folder
4. Duplicates are automatically skipped

**Default install location:** `~/Library/Fonts/`  
**Change it:** Click the settings gear → Choose install location

### Organizing Fonts

1. Uncheck "Auto install"
2. Drag font files or folders onto the window
3. Fonts are separated into organized folders:
   - `all TTFs/` - TrueType fonts
   - `all OTFs/` - OpenType fonts
   - `all WOFF2s/` - Web fonts (WOFF2)
   - `all WOFFs/` - Web fonts (WOFF)

The organized folders are created in the same directory as your source files.

---

## Requirements

- macOS 13.0 or later

## Support

Found a bug or have a feature request? [Open an issue](https://github.com/johnchourajr/buen-fonts-app/issues) on GitHub.

---

## For Developers

### Building from Source

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

### Distribution

**Create a Release DMG**

```bash
# Build and create DMG installer
./create-dmg.sh
```

This creates a `.dmg` file that users can download and install by dragging to Applications.

**Publishing a Release**

1. Update version in `Info.plist`
2. Run `./create-dmg.sh`
3. Create a new release on GitHub
4. Upload the `.dmg` file
5. Users download and install

**Optional: Code Signing & Notarization**

For wider distribution without Gatekeeper warnings:
1. Get an Apple Developer account ($99/year)
2. Sign the app with your Developer ID certificate
3. Notarize with Apple
4. See [Apple's notarization guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

### Customizing the Icon

1. Replace `icon.png` with your design (1024x1024 recommended)
2. Open `Package.swift` in Xcode
3. Drag your icon to all AppIcon slots in the asset catalog
4. Rebuild with `./build-app.sh`

**Build Requirements**
- macOS 13.0 or later
- Xcode 15.0 or later

## License

MIT - see LICENSE file

## Credits

Built on top of the [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator) concept.

