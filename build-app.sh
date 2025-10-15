#!/bin/bash

# Build the app bundle
echo "Building Buen Font Installer..."

# Build the executable
swift build -c release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

# Copy executable
cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"

# Copy Info.plist
cp Info.plist "$APP_DIR/"

# Copy icon assets
cp -r Sources/Resources/Assets.xcassets "$APP_DIR/Resources/"

# Create icns file from the iconset
mkdir -p /tmp/AppIcon.iconset
cp Sources/Resources/Assets.xcassets/AppIcon.appiconset/*.png /tmp/AppIcon.iconset/ 2>/dev/null
iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Resources/AppIcon.icns" 2>/dev/null
rm -rf /tmp/AppIcon.iconset

# Ad-hoc code sign the app
echo "Signing app..."
codesign --force --deep --sign - "$APP_NAME"

if [ $? -eq 0 ]; then
    echo "✓ App signed successfully"
else
    echo "⚠ Warning: Code signing failed, app may not run on other machines"
fi

echo "✓ App bundle created: $APP_NAME"
echo "You can now run it with: open \"$APP_NAME\""

