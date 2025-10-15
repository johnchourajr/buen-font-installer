# Buen Font Installer

![looper 4](https://github.com/user-attachments/assets/b3bc9d6a-bfa3-4af0-9fba-b087b511a093)




> Have you ever downloaded a new font family and thought, "I just want to install these TTFs right now without opening Font Book"? Or maybe you're drowning in a pile of mixed font files and just need them organized? Well today is your lucky day. Meet Buen Font Installer, the macOS menu bar app for all your font installing and organizing needs.

Buen Font Installer is a macOS menu bar app that lives quietly in your menu bar and lets you drag and drop font files to either install them instantly or organize them into neat folders by type.

Built on the my own shell script [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator).

## Usage

### 1. Download the app

**[Download Latest Release](https://github.com/johnchourajr/buen-fonts-app/releases/latest)**

### 2. Install it

1. Download the `Buen Font Installer-v1.0.dmg` file
2. Open the DMG and drag the app to your Applications folder
3. **First launch:** Right-click (or Control-click) the app and select "Open"
4. Click "Open" when macOS warns you about an unidentified developer
5. The app will launch - find it in your menu bar

**Why this extra step?** This app isn't notarized with Apple ($99/year developer fee). You only need to do this once.

### 3. Use it

**Installing Fonts**

1. Make sure "Auto install" is checked (it's on by default)
2. Drag font files or folders onto the window
3. `.ttf` and `.otf` files are instantly installed to your fonts folder
4. Duplicates are automatically skipped

Default install location is `~/Library/Fonts/`. Want to change it? Click the settings gear and choose your own location.

**Organizing Fonts**

1. Uncheck "Auto install"
2. Drag font files or folders onto the window
3. Fonts are separated into organized folders:
   - `all TTFs/` - TrueType fonts
   - `all OTFs/` - OpenType fonts
   - `all WOFF2s/` - Web fonts (WOFF2)
   - `all WOFFs/` - Web fonts (WOFF)

The organized folders are created in the same directory as your source files.

### 4. Enjoy your organized fonts

Do as you please with those installed or organized fonts.

Also, you can keep running the organize mode over and over and it'll keep refreshing those same folders without making duplicates. Magic.

## Features

**Simple Drag & Drop**
Drop font files or folders anywhere on the window - the entire window is your dropzone.

**Two Modes of Operation**
Auto Install mode installs fonts to your system with automatic duplicate detection. Organize mode separates fonts into organized folders by type without installing.

**Menu Bar Access**
Lives quietly in your menu bar - click to open, right-click for quick actions.

**Customizable**
Choose where fonts get installed, toggle menu bar and dock visibility, and see what fonts were processed with clear status messages.

## File Types Supported

Installs `.ttf` and `.otf` files. Organizes `.ttf`, `.otf`, `.woff2`, and `.woff` files into separate folders.

## Requirements

macOS 13.0 or later

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

This project is licensed under the MIT License - see the LICENSE file for details.

## About

Built on top of the [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator) concept.

