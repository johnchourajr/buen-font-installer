# Buen Font Installer

A simple macOS app to install and organize font files.

## Features

- **Drag & Drop Interface**: Simply drag font files or folders into the app
- **Auto Install Mode**: Install fonts directly to `~/Library/Fonts/` with automatic deduplication
- **Organize Mode**: Separate fonts into organized folders by type (TTF, OTF, WOFF, WOFF2)

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

## Customizing the Icon

The app currently has a placeholder icon (blue gradient with "Aa"). To customize it:

1. Replace the PNG files in `Sources/Resources/Assets.xcassets/AppIcon.appiconset/`
2. Rebuild the app with `./build-app.sh`

Or use any icon design tool to create a new iconset and replace the entire folder.

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## License

MIT

## Credits

Built on top of the [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator) concept.

