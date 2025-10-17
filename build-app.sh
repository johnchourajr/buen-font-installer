#!/bin/bash

# Build the app bundle
echo "Building Buen Font Installer..."

# Configuration
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"
SPARKLE_FRAMEWORK=".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"

# Check for code signing identity (optional for local builds)
SIGNING_IDENTITY="${DEVELOPER_ID_CERTIFICATE:-}"
if [ -z "$SIGNING_IDENTITY" ]; then
    echo "ℹ No DEVELOPER_ID_CERTIFICATE environment variable set"
    echo "ℹ Using ad-hoc signing (for local development only)"
    SIGNING_IDENTITY="-"
fi

# Build the executable
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
rm -rf "$APP_NAME"
mkdir -p "$APP_DIR/MacOS"
mkdir -p "$APP_DIR/Resources"
mkdir -p "$APP_DIR/Frameworks"

# Copy executable
cp .build/release/BuenFontInstaller "$APP_DIR/MacOS/"

# Set rpath for Sparkle framework
echo "🔗 Setting rpath for Sparkle..."
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_DIR/MacOS/BuenFontInstaller" 2>/dev/null || true

# Copy Info.plist
cp Info.plist "$APP_DIR/"

# Copy icon assets
cp -r Sources/Resources/Assets.xcassets "$APP_DIR/Resources/"

# Create icns file from the iconset
mkdir -p /tmp/AppIcon.iconset
cp Sources/Resources/Assets.xcassets/AppIcon.appiconset/*.png /tmp/AppIcon.iconset/ 2>/dev/null
iconutil -c icns /tmp/AppIcon.iconset -o "$APP_DIR/Resources/AppIcon.icns" 2>/dev/null
rm -rf /tmp/AppIcon.iconset

# Copy Sparkle framework if it exists
if [ -d "$SPARKLE_FRAMEWORK" ]; then
    echo "📦 Embedding Sparkle framework..."
    cp -R "$SPARKLE_FRAMEWORK" "$APP_DIR/Frameworks/"

    # Remove extended attributes (from Dropbox, etc)
    echo "🧹 Cleaning extended attributes..."
    xattr -cr "$APP_DIR/Frameworks/Sparkle.framework"

    # Sign the framework
    echo "🔐 Signing Sparkle framework..."
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework/Versions/B/Autoupdate" 2>/dev/null
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework/Versions/B/Updater.app" 2>/dev/null
    codesign --force --sign "$SIGNING_IDENTITY" \
        --timestamp \
        --options runtime \
        "$APP_DIR/Frameworks/Sparkle.framework" 2>/dev/null
else
    echo "⚠ Warning: Sparkle framework not found at $SPARKLE_FRAMEWORK"
    echo "   Run 'swift build' first to download dependencies"
fi

# Code sign the main executable
echo "🔐 Signing app executable..."
codesign --force --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller.entitlements \
    "$APP_DIR/MacOS/BuenFontInstaller"

# Code sign the entire app bundle
echo "🔐 Signing app bundle..."
codesign --force --deep --sign "$SIGNING_IDENTITY" \
    --timestamp \
    --options runtime \
    --entitlements BuenFontInstaller.entitlements \
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

echo "✓ App bundle created: $APP_NAME"
echo ""
echo "Next steps:"
if [ "$SIGNING_IDENTITY" = "-" ]; then
    echo "  • For distribution: Set DEVELOPER_ID_CERTIFICATE env var and rebuild"
    echo "  • Then run ./notarize.sh to notarize the app"
fi
echo "  • Test locally: open \"$APP_NAME\""
echo "  • Create DMG: ./create-dmg.sh"

