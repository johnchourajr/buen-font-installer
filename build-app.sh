#!/bin/bash

# Build the app bundle
echo "Building Buen Font Installer..."

# Configuration
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"

# Check for code signing identity (optional for local builds)
SIGNING_IDENTITY="${DEVELOPER_ID_CERTIFICATE:-}"
if [ -z "$SIGNING_IDENTITY" ]; then
    echo "ℹ No DEVELOPER_ID_CERTIFICATE environment variable set"
    echo "ℹ Using ad-hoc signing (for local development only)"
    SIGNING_IDENTITY="-"
fi

# Clean build first
echo "🧹 Cleaning build..."
swift package clean
rm -rf .build

# Build the executable
echo "🔨 Building Swift project..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
echo "📦 Creating app bundle..."
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"

# Copy executable
cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"

# Copy Info.plist
cp Info.plist "$APP_DIR/"

# Copy icon assets from build
echo "🎨 Copying icon assets..."
cp -r .build/arm64-apple-macosx/release/BuenFontInstaller_BuenFontInstaller.bundle/Assets.xcassets "$APP_DIR/Resources/"

# Create ICNS file from asset catalog
echo "🎨 Creating ICNS file..."
mkdir -p /tmp/AppIcon.iconset
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" /tmp/AppIcon.iconset/icon_512x512@2x.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" /tmp/AppIcon.iconset/icon_512x512.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" /tmp/AppIcon.iconset/icon_256x256@2x.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" /tmp/AppIcon.iconset/icon_256x256.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" /tmp/AppIcon.iconset/icon_128x128@2x.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" /tmp/AppIcon.iconset/icon_128x128.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png" /tmp/AppIcon.iconset/icon_32x32@2x.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" /tmp/AppIcon.iconset/icon_32x32.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png" /tmp/AppIcon.iconset/icon_16x16@2x.png 2>/dev/null || true
cp "$APP_DIR/Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" /tmp/AppIcon.iconset/icon_16x16.png 2>/dev/null || true
iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Resources/AppIcon.icns" 2>/dev/null || true
rm -rf /tmp/AppIcon.iconset

# Code sign the main executable
echo "🔐 Signing app executable..."
codesign --force --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller-direct.entitlements \
    "$APP_DIR/MacOS/BuenFontInstaller"

# Code sign the entire app bundle
echo "🔐 Signing app bundle..."
codesign --force --deep --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller-direct.entitlements \
    "$APP_NAME"

if [ $? -eq 0 ]; then
    echo "✓ App signed successfully"

    # Verify the signature
    codesign --verify --verbose "$APP_NAME"

    if [ "$SIGNING_IDENTITY" != "-" ]; then
        echo "✓ Code signing with Developer ID: Ready for distribution"
    else
        echo "ℹ Ad-hoc signed: For local development only"
    fi
else
    echo "⚠ Warning: Code signing failed"
fi

# Clear icon cache and restart Dock
echo "🔄 Refreshing icon cache..."
killall Dock

echo "✓ App bundle created: $APP_NAME"
echo ""
echo "Next steps:"
if [ "$SIGNING_IDENTITY" = "-" ]; then
    echo "  • For distribution: Set DEVELOPER_ID_CERTIFICATE env var and rebuild"
    echo "  • Then run ./notarize.sh to notarize the app"
fi
echo "  • Test locally: open \"$APP_NAME\""
echo "  • Create DMG: ./create-dmg.sh"

