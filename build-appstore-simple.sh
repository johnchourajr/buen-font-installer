#!/bin/bash

# Build app for Mac App Store distribution (app bundle only, no .pkg)
set -e

echo "🍎 Building for Mac App Store (App Bundle Only)..."
echo "=================================================="
echo ""

# Load secrets
if [ -f ".env.secrets" ]; then
    source .env.secrets
fi

# Check for Mac App Store certificate
MAC_APP_STORE_CERT=$(security find-identity -v -p codesigning | grep "3rd Party Mac Developer Application" | head -1 | grep -o '"[^"]*"' | tr -d '"')

if [ -z "$MAC_APP_STORE_CERT" ]; then
    echo "❌ No Mac App Store certificate found!"
    echo ""
    echo "To fix this:"
    echo "1. Go to https://developer.apple.com/account/resources/certificates"
    echo "2. Create a 'Mac App Store' certificate"
    echo "3. Install it in your keychain"
    echo ""
    exit 1
fi

echo "✓ Found Mac App Store certificate: $MAC_APP_STORE_CERT"
echo ""

# Set signing identity
export SIGNING_IDENTITY="$MAC_APP_STORE_CERT"

# Build the app (reuse existing build script)
echo "📦 Building app..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle structure
APP_NAME="Buen Font Installer.app"
APP_DIR="$APP_NAME/Contents"
SPARKLE_FRAMEWORK=".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"

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

    # Remove extended attributes
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
    echo "✓ App signed successfully for Mac App Store"
    
    # Verify the signature
    codesign --verify --verbose "$APP_NAME"
else
    echo "❌ Code signing failed"
    exit 1
fi

echo ""
echo "✓ App bundle created: $APP_NAME"
echo ""

# Create a zip file for upload (alternative to .pkg)
echo "📦 Creating zip file for upload..."
ZIP_NAME="Buen Font Installer.zip"
rm -f "$ZIP_NAME"
ditto -c -k --keepParent "$APP_NAME" "$ZIP_NAME"

if [ $? -eq 0 ]; then
    echo "✓ Zip file created: $ZIP_NAME"
    echo ""
    echo "Next steps:"
    echo "1. Download Transporter from Mac App Store"
    echo "2. Drag '$ZIP_NAME' into Transporter"
    echo "3. Click 'Deliver'"
    echo ""
    echo "Or upload via command line:"
    echo "xcrun altool --upload-package \"$ZIP_NAME\" \\"
    echo "  --type macos \\"
    echo "  --username \"your@email.com\" \\"
    echo "  --password \"app-specific-password\" \\"
    echo "  --bundle-id \"dev.muybuen.buen-font-installer\""
else
    echo "❌ Zip creation failed"
    exit 1
fi
