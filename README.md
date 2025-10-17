# Buen Font Installer

![looper 4](https://github.com/user-attachments/assets/b3bc9d6a-bfa3-4af0-9fba-b087b511a093)




> Have you ever downloaded a new font family and thought, "I just want to install these TTFs right now without opening Font Book"? Or maybe you're drowning in a pile of mixed font files and just need them organized? Well today is your lucky day. Meet Buen Font Installer, the macOS menu bar app for all your font installing and organizing needs.

Buen Font Installer is a macOS menu bar app that lives quietly in your menu bar and lets you drag and drop font files to either install them instantly or organize them into neat folders by type.

Built on the my own shell script [Font File Separatornator](https://github.com/johnchourajr/font-file-separatornator).

## Usage

### 1. Download the app

**[Download Latest Release](https://github.com/johnchourajr/buen-fonts-app/releases/latest)**

### 2. Install it

1. Download the latest `Buen Font Installer-v*.dmg` file
2. Open the DMG and drag the app to your Applications folder
3. Launch from Applications
4. The app will appear in your menu bar

**No Gatekeeper warnings!** This app is code-signed and notarized with Apple.

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

**Automatic Updates**
Get notified when new versions are available. Download and install updates with one click - no need to manually check.

**Customizable**
Choose where fonts get installed, toggle menu bar and dock visibility, and see what fonts were processed with clear status messages.

**Code Signed & Notarized**
Fully signed and notarized with Apple for security and trust.

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

This project includes full code signing and notarization support with Sparkle auto-updates.

#### Setup Required (One-Time)

**1. Export Your Developer ID Certificate**

From Keychain Access:
1. Find your "Developer ID Application" certificate
2. Right-click → Export → Save as `.p12` file
3. Set a password when exporting

**2. Create App-Specific Password**

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in and go to Security
3. Generate an app-specific password
4. Save it securely

**3. Add GitHub Secrets**

Go to your repo's Settings → Secrets → Actions and add:

- `DEVELOPER_ID_CERTIFICATE_BASE64`: Your certificate in base64
  ```bash
  base64 -i certificate.p12 | pbcopy
  ```
- `DEVELOPER_ID_CERTIFICATE_PASSWORD`: The password you set when exporting
- `KEYCHAIN_PASSWORD`: Any secure password (for temporary keychain)
- `APPLE_ID`: Your Apple ID email
- `APPLE_TEAM_ID`: Your 10-character Team ID from [developer.apple.com/account](https://developer.apple.com/account)
- `APPLE_APP_PASSWORD`: The app-specific password you generated

#### Local Development

**Build without signing (for testing):**
```bash
./build-app.sh
open "Buen Font Installer.app"
```

**Build with signing:**
```bash
export DEVELOPER_ID_CERTIFICATE="Developer ID Application: Your Name (TEAMID)"
./build-app.sh
```

**Notarize the app:**
```bash
export APPLE_ID="your@email.com"
export APPLE_TEAM_ID="ABC123XYZ"
./notarize.sh
```

**Create a distribution DMG:**
```bash
# With signing and notarization
export DEVELOPER_ID_CERTIFICATE="Developer ID Application: Your Name (TEAMID)"
export APPLE_ID="your@email.com"
./create-dmg.sh
```

#### Publishing a Release

1. **Update version** in `Info.plist`:
   ```xml
   <key>CFBundleShortVersionString</key>
   <string>1.1</string>
   ```

2. **Commit and tag**:
   ```bash
   git add Info.plist
   git commit -m "Bump version to 1.1"
   git tag v1.1
   git push origin main --tags
   ```

3. **GitHub Actions automatically**:
   - Builds the app
   - Signs with your Developer ID
   - Notarizes with Apple
   - Creates a DMG
   - Uploads to GitHub Releases

4. **Update appcast.xml**:
   - Download the released DMG
   - Get file size: `ls -l "Buen Font Installer-v1.1.dmg" | awk '{print $5}'`
   - Follow instructions in `APPCAST_UPDATE_GUIDE.md`
   - Add new version entry to `appcast.xml`
   - Commit and push

5. **Users automatically get notified** of the update on their next app launch!

#### Sparkle Auto-Update System

The app uses Sparkle for automatic updates:
- Checks `appcast.xml` on launch (once per day)
- Shows update notification when available
- Users can click "Install Update" to auto-download and install
- Menu bar includes "Check for Updates..." option

See `APPCAST_UPDATE_GUIDE.md` for details on maintaining the appcast file.

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

